# GUIA DEFINITIVO DE TESTES — CREDENCIAMENTO

**Versão alvo:** V12.0.0206 + Onda QA-V3 (em projeto)
**Status do documento:** DRAFT v0.1 — pendente auditoria cruzada (Codex + Antigravity Gemini 3.5)
**Data:** 2026-05-27
**Audiência:** QA, operadores municipais, gestores, auditores, IAs implementadoras
**Substitui:** *Guia de Testes — Credenciamento V12.0.0202 + Ondas 1-4* (Abril/2026)

---

## SOBRE ESTE DOCUMENTO

Este guia é o ponto de verdade único para validação manual e automatizada do Sistema de Credenciamento e Rodízio. Foi desenhado para servir simultaneamente como:

1. **Manual operacional** para humanos executando bateria de homologação
2. **Especificação de contrato** para IAs que implementam o sistema
3. **Vitrine de robustez** para futura adoção do SaaS por novos municípios
4. **Trilha de auditoria** para órgãos de controle externo

A versão impressa deste guia, junto com a planilha, é suficiente para que um operador sem treinamento prévio entenda os fundamentos, execute a bateria, identifique bugs e produza evidência formal.

---

## 0. RESUMO EXECUTIVO E ENTENDIMENTO DA LÓGICA GERAL DOS TESTES

### 0.1 Para que serve este documento

O Sistema de Credenciamento e Rodízio existe para que prefeituras municipais distribuam, de forma **isonômica, determinística e auditável**, ordens de serviço de pequenos reparos entre empresas previamente credenciadas. O coração do sistema é um algoritmo de rodízio que escolhe a próxima empresa apta para cada solicitação. Se esse algoritmo errar, a prefeitura produz injustiça contestável legalmente. Este guia documenta como verificar que ele NÃO erra.

### 0.2 Como ler este guia (3 caminhos)

| Perfil | Comece em | Tempo |
|---|---|---|
| **Operador novo** | §0.6 (papéis) → §1 (visão) → §3 (regras) → §6 (cenários OBRIGATÓRIOS) | 1 dia útil |
| **QA experiente** | §4 (rodízio contrato crítico) → §6 (todos os cenários) → §11 (aceite) | meio dia |
| **Auditor / certificador** | §0.7 (papéis humanos) → §3 (regras) → §11 (critérios aceite) → Apêndice A (checklist) | 2-3h |
| **IA implementadora** | §0 inteiro → §7 (arquitetura V3) → SUPERPROMPT separado | leitura única |

### 0.3 Variáveis e dimensões do sistema — visão de uma página

O sistema modela 5 entidades primárias com estados finitos. Toda a lógica do rodízio é função desses estados:

| Entidade | Estados | Cardinalidade |
|---|---|---|
| **Empresa** | ATIVA, INATIVA, SUSPENSA_GLOBAL | 3 |
| **Credenciamento** (Empresa × Atividade) | ATIVO, INATIVO, SUSPENSO_LOCAL | 3 |
| **Pré-OS** | AGUARDANDO_ACEITE, ACEITA, RECUSADA, EXPIRADA, CONVERTIDA_OS | 5 |
| **OS** | ABERTA, EM_EXECUCAO, CONCLUIDA, CANCELADA | 4 |
| **Atividade** | ATIVA, INATIVA | 2 |

**Eixos quantitativos** (contadores e datas relevantes):

| Variável | Domínio | Cortes críticos |
|---|---|---|
| `QTD_RECUSAS` | 0..MAX_RECUSAS+overflow | 0, 1, MAX_RECUSAS-1, MAX_RECUSAS, MAX_RECUSAS+1 |
| `DIAS_ATE_LIMITE_ACEITE` | inteiro | <0 (vencido), 0 (hoje), 1, DIAS_DECISAO, >DIAS_DECISAO |
| `MESES_DESDE_SUSPENSAO` | 0..MESES_SUSPENSAO+overflow | 0, MESES-1, MESES (limite), MESES+1 |
| `MEDIA_NOTAS` | 1.0..10.0 | <NOTA_CORTE, =NOTA_CORTE, >NOTA_CORTE, extremos 1.0/10.0 |
| `POSICAO_FILA` | 1..N | 1 (topo), meio, último (N), N=1 (único), N=0 (degenerado) |
| `STRIKE_COUNT` | 0..MAX_STRIKES+overflow | 0, 1, MAX-1, MAX (gatilho), MAX+1 (não deve ocorrer) |

**Combinatória bruta:** 3 × 3 × 5 × 4 × 2 = **360 estados sintáticos** de entidade.
**Combinatória cartesiana total** (com eixos quantitativos): ~172.800 combinações.
**Combinatória semanticamente válida** (excluindo violações de invariantes): estimadas em ~3.000-5.000.

### 0.4 Escolhas feitas nesta bateria

- **Cobertura primária**: 100% dos estados de cada entidade (modelo all-states).
- **Cobertura secundária**: pares de estado relevantes (pairwise) — alvo 80%.
- **Cobertura terciária** (diferida, próximas ondas): triplas relevantes, fuzzing, mutation.
- **Cenários hardcoded vs. parametrizados**: cenários canônicos (CS-00 a CS-22, herdados do guia V202) permanecem hardcoded para reproducibilidade. Cenários expandidos (CS-23+) são parametrizados via DSL de receitas (§7.3).
- **Determinismo absoluto**: dois runs com mesma fixture devem produzir mesma sequência de decisões do rodízio. Variação = bug.
- **Idempotência**: rodar populador 2× = mesmo estado. Apertar botão "Expirar Pré-OS" 2× = primeiro funciona, segundo falha previsivelmente (sem dano).

### 0.5 Variações possíveis (combinatória — síntese)

Cenários cobertos pela bateria V202 (23 CS): **~30 estados primários, ~10 pairs**.
Gap atual em relação ao estado da arte:

| Categoria | Cobertura atual | Alvo Onda QA-V3 |
|---|---|---|
| Estados primários (all-states) | ~85% | 100% |
| Pares relevantes (pairwise) | ~30% | 80% |
| Boundary de variáveis quantitativas | parcial | total (5 pontos por variável) |
| Cenários adversariais | embrionário (Onda 23) | sistemático |
| Cenários de inabilitação com >3 empresas | **NÃO COBERTO** | 5+ empresas, múltiplas inabilitadas |
| Validação de CNPJ (dígitos verificadores) | **NÃO EXISTE** | regra RN-23 implementada e testada |
| Integridade referencial | implícita | explícita com RN-24 |
| Crash recovery | **NÃO COBERTO** | mínimo 3 cenários |

### 0.6 Papéis humanos × IA × automação

A operação do sistema envolve três tipos de agente, com responsabilidades distintas e não-substituíveis:

| Agente | O que faz | O que NÃO faz |
|---|---|---|
| **Operador humano** | Cadastros, decisões de negócio (suspender, descredenciar), avaliações qualitativas, validação de PDFs e atos | Não toca código, não roda baterias, não interpreta AUDIT_LOG cru |
| **Gestor humano** | Configurações (nota de corte, MAX_STRIKES), aprovação de releases, decisão de suspensão manual, certificação final | Não desenvolve, não muda regras de negócio sem ciclo formal |
| **Auditor humano** | Lê AUDIT_LOG, valida PDFs, compara cenário documentado × execução real, assina aprovação | Não opera o sistema produtivamente, não emite Pré-OS |
| **QA humano** | Roda bateria deste guia, marca APROVADO/REPROVADO, reporta bugs com template | Não decide se versão sobe (decisão do gestor) |
| **IA implementadora** (Codex/Opus) | Codifica conforme readback aprovado, mantém compatibilidade, gera evidência CSV | Não decide regras de negócio, não promove gates sem hearback, não toca `Mod_Types.bas` sem plano específico |
| **IA auditora** (Antigravity Gemini) | Lê código + documento, verifica coerência, aponta gaps semânticos | Não implementa, não opera, não substitui aprovação humana |
| **Automação (bateria V1/V2/V3)** | Reproduz cenários determinísticos, gera evidência CSV+PDF, alimenta dashboard | Não interpreta resultado qualitativo, não valida intenção de negócio, não dispensa humano em release |

**Princípio orientador:** automação acelera *evidência*, humanos acelerarem *julgamento*. Nenhum dos dois substitui o outro em produção pública.

### 0.7 Fronteira atual (planilha) × futura (SaaS)

O sistema hoje é uma planilha Excel `.xlsm` com macros VBA. A intenção declarada é migrar para SaaS web preservando a lógica de negócio. Este guia é construído sobre essa premissa: **toda regra documentada aqui deve sobreviver à migração**.

Implicações práticas:
- Regras de negócio (§3) são contrato de domínio, não detalhe de implementação Excel.
- Validações que faltam hoje (CNPJ por dígitos verificadores, integridade referencial) devem ser implementadas no Excel **antes** da migração — porque o SaaS receberá importação a partir da planilha e herdará a dívida.
- Cenários de teste (§6) descrevem comportamento esperado em qualquer implementação — não citam "clique aqui" sem citar primeiro "comportamento esperado".
- Quando este guia diz "AUDIT_LOG", o equivalente SaaS é "tabela de eventos imutável". Mesma semântica.
- O guia futuro do SaaS herda este; mudanças serão por extensão, não substituição.

### 0.8 Este documento como vitrine

Adotar o sistema (planilha ou SaaS) por um município é decisão administrativa formal. O documento que demonstra a robustez da lógica embarcada é **este guia**. Por isso:
- Tem versionamento próprio (DRAFT v0.1 → estabilização → release).
- É auditado por múltiplas IAs antes de virar oficial.
- Será publicado junto com a release no GitHub, acessível via botão **Ajuda** da Configuração Inicial (§13).
- O FAQ (Apêndice G) é mantido vivo no repositório com pull requests dos municípios adotantes.

---

## 1. VISÃO GERAL DO SISTEMA

### 1.1 Para que serve (caso de uso primário)

Prefeitura precisa contratar reparos pontuais (troca de telha, conserto de fechadura, manutenção de bomba). Individualmente são pequenos; no conjunto, somam volume relevante. Em vez de licitação por reparo, ela credencia previamente várias empresas em cada serviço. Quando surge demanda, o sistema escolhe a próxima empresa apta seguindo um RODÍZIO — todas têm a mesma chance ao longo do tempo. Isonomia, simplicidade administrativa, e trilha de auditoria.

### 1.2 Atores

- **Gestor**: configura, cadastra, monitora suspensões, aprova releases.
- **Operador**: emite Pré-OS, converte em OS, registra avaliações, encerra serviços.
- **Empresa credenciada**: aceita/recusa Pré-OS, executa OS, recebe avaliação.
- **Entidade demandante**: escola, posto, secretaria — quem pede o reparo.
- **Auditoria**: revê AUDIT_LOG, valida PDFs, certifica conformidade.

### 1.3 Fluxo macro (8 passos)

1. **Setup** — Gestor cadastra entidades, empresas, atividades (CNAE), serviços, credencia empresas.
2. **Demanda** — Entidade pede reparo; operador abre o sistema.
3. **Indicação** — Operador escolhe entidade + serviço; rodízio escolhe automaticamente a próxima empresa apta e cria Pré-OS.
4. **Resposta da empresa** — Empresa tem N dias (configurável, default 5) para aceitar ou recusar. Se ignorar, expira automaticamente.
5. **OS** — Após aceite, operador emite OS efetiva. Empresa executa o serviço.
6. **Conclusão e avaliação** — Operador encerra OS atribuindo notas (até 10). Média define satisfatoriedade.
7. **Strike e suspensão** — Nota abaixo do corte conta strike. Após N strikes, suspensão automática por X dias.
8. **Auditoria** — Tudo registrado em AUDIT_LOG para revisão posterior.

### 1.4 Por que esses testes existem

O rodízio é o coração da isonomia. Erros nele são contestáveis judicialmente pela empresa lesada. Os cenários deste guia testam **todas as situações que o rodízio precisa tratar corretamente**, com foco especial nas que historicamente causaram bug em versões anteriores. Bug no rodízio = risco legal = bloqueio de release.

---

## 2. GLOSSÁRIO CANÔNICO

### 2.1 Termos de domínio (herdados V202)

| Termo | Significado |
|---|---|
| **Atividade (CNAE)** | Categoria de serviço cadastrada na aba ATIVIDADES, código numérico 3 dígitos (ex.: 001). Vêm de base padrão CNAE importada via "Reset CNAE". |
| **Serviço** | Tipo específico dentro de uma atividade (ex.: "001\|Troca de telha"). Empresas se credenciam em SERVIÇOS, não em atividades cruas. |
| **Empresa** | Pessoa jurídica fornecedora, CNPJ, EMP_ID. Estados: ATIVA, INATIVA, SUSPENSA_GLOBAL. |
| **Entidade** | Órgão público demandante (escola, posto, secretaria), CNPJ, ENT_ID. |
| **Credenciamento** | Vínculo empresa↔atividade. Tem POSIÇÃO na fila (1, 2, 3...) e STATUS_CRED (ATIVO/INATIVO). |
| **Rodízio** | Algoritmo que escolhe próxima empresa apta para Pré-OS, varre fila de baixo para cima, pula inaptos. |
| **Pré-OS (PréSS)** | Solicitação inicial. Prazo de aceite default 5 dias. Estados: AGUARDANDO_ACEITE, ACEITA, RECUSADA, EXPIRADA, CONVERTIDA_OS. |
| **OS (Ordem de Serviço)** | Documento que materializa o serviço em execução, criado a partir de Pré-OS aceita. Estados: ABERTA, EM_EXECUCAO, CONCLUIDA, CANCELADA. |
| **Avaliação** | Conjunto de até 10 notas (0-10) atribuídas após conclusão da OS. |
| **Strike** | Marca contabilizada quando MEDIA < NOTA_CORTE. |
| **Nota de corte** | Valor configurável (default 5,0) abaixo do qual avaliação conta strike. |
| **Máximo de strikes** | Número de strikes (default 3) antes de suspensão automática. |
| **Dias de suspensão por strike** | Período (default 90 dias) de suspensão após MAX_STRIKES. |
| **Suspensão global** | Empresa pulada em TODAS atividades. Motivos: MANUAL, NOTA_BAIXA (strikes), MAX_RECUSAS. |
| **DT_FIM_SUSP** | Data de expiração da suspensão. Quando passa, reativação automática na próxima emissão. |
| **CONFIG** | Aba com parâmetros: gestor, município, prazo Pré-OS, nota de corte, MAX_STRIKES, dias de suspensão. |
| **AUDIT_LOG** | Aba imutável onde toda ação com efeito de estado é registrada. |
| **CADASTROS_INATIVOS** | Abas EMPRESAS_INATIVAS / ENTIDADE_INATIVOS — preservam histórico de inativações. |
| **Snapshot CAD_SERV** | Cópia criada automaticamente antes de Reset CNAE, permite rollback. |
| **Limpar Base** | Operação protegida por senha que zera abas operacionais (EMPRESAS, ENTIDADE, CREDENCIADOS, PRE_OS, CAD_OS), preserva catálogo (ATIVIDADES, CAD_SERV) e configuração (CONFIG). |

### 2.2 Termos da arquitetura V3 (novos)

| Termo | Significado |
|---|---|
| **V1** | Bateria oficial legada — `Teste_Bateria_Oficial.bas`, monolítica em 5 blocos, 171 testes. |
| **V2** | Suítes modulares — `Teste_V2_Engine.bas` + `Teste_V2_Roteiros.bas`, composição por helpers. |
| **V3 (Plataforma)** | Camada que envelopa V1+V2 e adiciona populadores, DSL, PDF, tutorial, menu hierárquico. NÃO substitui — incorpora. |
| **Populador** | Sub idempotente que prepara estado da planilha SEM rodar asserts e SEM resetar (deixa dados visíveis para uso humano). Ex.: `POP_CenarioCanonico`. |
| **Receita** | Linha na sheet `CENARIOS_RECEITAS` com parâmetros que definem um cenário (N empresas, N locais, distribuição, dias offset, etc.). Permite "construir teste próprio" sem código. |
| **DSL de Cenários** | Linguagem declarativa em sheet — colunas viram parâmetros. Não é Turing-completa; é configuração. |
| **Reporter** | Componente que gera saída de teste em múltiplos formatos (sheet QA, CSV, PDF, pasta de auditoria). |
| **Fixture canônica** | Estado pré-definido reusável — atualmente "3 empresas × 3 locais × 1 atividade" (`TV2_PrepararCenarioTriploCanonico`). |
| **Pasta de Auditoria** | Saída completa de uma execução: PDFs gerados, CSVs de evidência, manifesto e narrativa, comprimível para envio a auditor externo. |
| **Modo Tutorial** | Camada didática sobre execução real — 4 modos: TREINO, DEMO, DEBUG, CERTIFICAÇÃO. Substitui o "modo visual/lento" V1, que não cumpria propósito didático. |
| **Pairwise** | Estratégia de cobertura combinatória — testa todos os pares de valores das variáveis (vs. cartesiano completo). Captura ~80% dos bugs com ~5% do esforço. |
| **Mutation testing** | (Onda futura) — altera 1 linha de código de produção e verifica se a bateria pega. Mede qualidade dos testes, não do código. |

---

## 3. REGRAS DE NEGÓCIO (RN-01 a RN-32)

As 32 regras a seguir são o **CONTRATO DE COMPORTAMENTO** do sistema. Os cenários de §6 testam cada uma isoladamente ou em combinação. Se o sistema fizer algo que contradiga uma delas, é BUG.

> **Convenção**: RN-01 a RN-22 são herdadas do guia V202, validadas em produção. RN-23 a RN-32 são novas, levantadas durante a redação da Onda QA-V3 e marcadas como [NOVA — IMPLEMENTAR].

### Cadastros

**RN-01. Cadastro de empresas é por CNPJ único**
CNPJ válido e único. Sistema rejeita duplicidade. EMP_ID gerado automaticamente em sequência (001, 002, 003...).

**RN-02. Cadastro de entidades é por CNPJ único**
Mesma regra das empresas. ENT_ID em sequência. Sem vínculo formal entre entidades.

**RN-03. Atividades vêm de base padrão CNAE**
Aba ATIVIDADES é populada via import CSV padronizado. Reset CNAE cria snapshot CAD_SERV antes de tocar em qualquer coisa.

**RN-04. Reset CNAE remove duplicatas automaticamente**
Deduplica por par (CÓDIGO + DESCRIÇÃO), mantém primeira ocorrência. Quantidade em AUDIT_LOG: campo `DUPLICATAS_REMOVIDAS`.

**RN-05. Reset CNAE preserva histórico de snapshots (housekeeping)**
Snapshot `CAD_SERV_SNAPSHOT_<timestamp>`. Sistema pergunta antes de podar antigos, default mantém 5 mais recentes.

### Credenciamento e Rodízio

**RN-06. Credenciamento liga empresa a atividade com posição na fila**
POSIÇÃO numérica (1 = topo). Empresas novas entram no FIM. Posição só muda por: (a) AvancarFila após OS emitida, (b) descredenciamento que rebobina.

**RN-07. Rodízio escolhe a próxima empresa por aptidão e posição**
Varre fila de baixo para cima (posição 1, 2, 3...), seleciona primeira que NÃO esteja:
(a) inativa cadastralmente
(b) suspensa globalmente com prazo vigente
(c) com OS aberta na atividade
(d) com Pré-OS pendente na atividade
(e) descredenciada do item

**RN-08. Empresa suspensa com prazo vencido é reativada automaticamente**
Antes de avaliar aptidão, rodízio verifica DT_FIM_SUSP. Se passou, STATUS_GLOBAL volta para ATIVA. Empresa volta à fila preservando POSIÇÃO original.

### Ciclo Pré-OS / OS

**RN-09. Pré-OS bloqueia a empresa enquanto AGUARDANDO_ACEITE**
Uma Pré-OS aberta impede a mesma empresa de receber outra Pré-OS na mesma atividade. Cessa quando muda para ACEITA, RECUSADA, EXPIRADA ou CONVERTIDA_OS.

**RN-10. Recusa de Pré-OS avança a fila ANTES da próxima emissão**
Empresa que recusa vai para FIM da fila. Próxima emissão escolhe próxima apta.

**RN-11. Excesso de recusas suspende a empresa globalmente**
Configurável em CONFIG (default `MAX_RECUSAS=3`). Ao atingir, `SUSPENSA_GLOBAL`, motivo `MAX_RECUSAS`, `DT_FIM_SUSP` por meses (default 6).
> **Nota:** o guia V202 dizia "default 1" — a investigação técnica revela `MAX_RECUSAS=3` como default em CONFIG atual ([Util_Config.bas](src/vba/Util_Config.bas)). Confirmar e atualizar.

**RN-12. Aceite de Pré-OS converte em OS, OS abre, fila avança**
Empresa aceita → operador emite OS → Pré-OS muda para CONVERTIDA_OS → OS nasce ABERTA → empresa vai para FINAL da fila via `AvancarFila`.

**RN-13. OS aberta bloqueia a empresa em todas as emissões da MESMA atividade**
Enquanto OS está ABERTA ou EM_EXECUCAO, empresa é pulada SOMENTE na atividade da OS. Pode receber Pré-OS em outras atividades.

**RN-14. Conclusão de OS exige avaliação**
Operador atribui até 10 notas. Média gravada em `CAD_OS.MEDIA`. OS muda para CONCLUIDA. Empresa volta apta na atividade.

### Strikes e Suspensão

**RN-15. Avaliação abaixo da nota de corte conta strike**
Se MEDIA < NOTA_CORTE (default 5,0), incrementa strike. Strike registrado em AUDIT_LOG. Empresa NÃO sai do rodízio ainda — só ao atingir MAX_STRIKES.

**RN-16. Atingir MAX_STRIKES suspende automaticamente**
MAX_STRIKES (default 3) avaliações abaixo → SUSPENSA_GLOBAL, motivo NOTA_BAIXA, DT_FIM_SUSP = hoje + DIAS_SUSPENSAO_STRIKE (default 90).

**RN-17. Suspensão por strike usa DIAS, não MESES**
Diferente da suspensão por recusas (meses). AUDIT_LOG registra `BASE=DIAS` para diferenciar.

**RN-18. Reativação após suspensão preserva posição original**
Reativação automática (DT_FIM_SUSP vencida) ou manual: empresa volta para POSIÇÃO original. NÃO entra como último. Penalização já foi cumprida pelo período.

### Bloqueio e Limpeza

**RN-19. Bloqueio total não trava o sistema**
Quando NENHUMA empresa apta existe, sistema responde com `Sucesso=False`, `Motivo=SEM_CREDENCIADOS_APTOS`. NÃO emite Pré-OS, NÃO dá erro fatal. Preserva fila.

**RN-20. Limpar Base preserva catálogo e configuração**
Apaga EMPRESAS, ENTIDADE, CREDENCIADOS, PRE_OS, CAD_OS. PRESERVA ATIVIDADES, CAD_SERV, CONFIG. Protegida por senha.

**RN-21. AUDIT_LOG registra toda ação com efeito de estado**
Cadastro, emissão, conversão, suspensão, reativação, avaliação, reset → 1 linha em AUDIT_LOG com data, tipo, entidade, ID, usuário, detalhes. Trilha legal.

**RN-22. Inatividade cadastral é terminal até reativação manual**
Empresa INATIVA → move para EMPRESAS_INATIVAS → some do rodízio em todas atividades. Só volta com reativação manual explícita do gestor.

### [NOVAS] Integridade de Dados

**RN-23. [NOVA — IMPLEMENTAR] Validação de CNPJ por dígitos verificadores**
Todo CNPJ (empresa ou entidade) DEVE passar por validação matemática mod-11 dos dígitos verificadores, não apenas remoção de formatação. CNPJs como "11.111.111/1111-11" devem ser rejeitados com mensagem clara `CNPJ_INVALIDO`.
> **Estado atual:** apenas `NormalizarCNPJ()` existe — remove `.`, `/`, `-` mas NÃO valida dígitos. Bug `INT-EMP-CNPJ-DUP` registrado em [Teste_V2_Roteiros.bas:4616](src/vba/Teste_V2_Roteiros.bas#L4616).
> **Implementação:** função `ValidarCNPJ(cnpj As String) As Boolean` em novo `Util_Validacao.bas`. Chamada obrigatoriamente em frmCadastraEmpresa e frmCadastraEntidade antes de aceitar.
> **Justificativa SaaS:** planilha será porta de entrada/saída do SaaS futuro; sem validação no Excel, dívida é herdada.

**RN-24. [NOVA — IMPLEMENTAR] Integridade referencial entre cadastros**
Não pode existir:
- Credenciamento apontando para empresa que não existe em EMPRESAS nem EMPRESAS_INATIVAS.
- Credenciamento apontando para atividade que não existe em ATIVIDADES.
- Serviço em CAD_SERV apontando para atividade inexistente.
- Pré-OS apontando para empresa, entidade ou serviço inexistente.
- OS apontando para Pré-OS inexistente.
> **Validador:** Sub `Util_Integridade_Verificar()` executado: (a) ao abrir workbook, (b) antes de cada export para SaaS, (c) como gate no RVS.
> **Saída:** sheet `INTEGRIDADE_REFS` com linhas de violação, se houver. Se vazia, OK.

### [NOVAS] Contrato do Rodízio

**RN-25. [NOVA — FORMALIZAR] Determinismo do rodízio**
Dado um estado idêntico de EMPRESAS + CREDENCIADOS + PRE_OS + CAD_OS, duas chamadas consecutivas ao rodízio para a mesma atividade DEVEM produzir o mesmo EMP_ID escolhido. Sem aleatoriedade, sem dependência de timestamp interno, sem dependência de ordem de iteração não-determinística.
> **Teste de determinismo:** CS-99 (novo) — duplica workbook após CS-00, roda mesma sequência de emissões em ambas as cópias, compara EMP_IDs escolhidos. Divergência = bug crítico.

**RN-26. [NOVA — FORMALIZAR] Idempotência de operações de mutação**
Operações que devem ser idempotentes:
- `POP_CenarioCanonico` — rodar 2× = mesmo estado.
- `Reset CNAE` — rodar 2× sem dados novos = estado igual.
- `Limpar Base` — rodar 2× = vazio (sem erro).

Operações que NÃO devem ser idempotentes (por contrato):
- `EmitirPreOS` — segunda emissão produz nova Pré-OS (ou rejeita por RN-09).
- `RecusarPreOS` — segunda recusa sobre mesma Pré-OS rejeita (status já não é AGUARDANDO_ACEITE).
- `ExpirarPreOS` — idem.

### [NOVAS] Comportamento de Pré-OS

**RN-27. [NOVA — DOCUMENTAR] Expirar Pré-OS — efeitos exatos**

A função `ExpirarPreOS(PREOS_ID)` em [Svc_PreOS.bas:392-465](src/vba/Svc_PreOS.bas#L392) faz, na ordem:

1. Localiza Pré-OS por ID.
2. Valida `STATUS = AGUARDANDO_ACEITE`. Se não, retorna erro (idempotência protetiva).
3. Chama `AvancarFila(EMP_ID, ATIV_ID, IsPunido=True, "PRAZO_EXPIRADO")` ANTES de mutar a Pré-OS.
4. Se `AvancarFila` falhar, NÃO grava nada. Pré-OS permanece AGUARDANDO_ACEITE.
5. Grava `STATUS=EXPIRADA`, `MOTIVO="PRAZO_EXPIRADO"`.
6. Registra `EVT_PREOS_EXPIRADA` em AUDIT_LOG com EMP_ID e ATIV_ID.

**Efeitos colaterais via `AvancarFila(IsPunido=True)`:**
- Empresa vai para FIM da fila.
- `QTD_RECUSAS` é incrementado.
- Se `QTD_RECUSAS >= MAX_RECUSAS`, dispara `Suspender(EMP_ID)` → empresa SUSPENSA_GLOBAL com motivo `MAX_RECUSAS`.
- Auditoria adicional: `EVT_RODIZIO_AVANCOU` e (se aplicável) `EVT_SUSPENSAO_AUTOMATICA`.

**Condição para usar:** prazo de aceite vencido (DT_LIMITE_ACEITE < hoje).
**Quem dispara:** operador via botão, ou rotina de manutenção automática (se existir agendamento).

**RN-28. [NOVA — DOCUMENTAR] Rejeitar Pré-OS — efeitos exatos**

A função `RecusarPreOS(PREOS_ID, motivo)` em [Svc_PreOS.bas:308-386](src/vba/Svc_PreOS.bas#L308) faz, na ordem:

1. Localiza Pré-OS por ID.
2. Valida `STATUS = AGUARDANDO_ACEITE`. Se não, retorna erro.
3. Chama `AvancarFila(EMP_ID, ATIV_ID, IsPunido=True, "RECUSA_EXPLICITA")` ANTES de mutar.
4. Se `AvancarFila` falhar, NÃO grava nada.
5. Grava `STATUS=RECUSADA`, `MOTIVO=<texto do operador>`.
6. Registra `EVT_PREOS_RECUSADA` em AUDIT_LOG com MOTIVO armazenado.

**Efeitos colaterais:** IDÊNTICOS a RN-27 (chama mesmo `AvancarFila(IsPunido=True)`).

**RN-29. [NOVA — FORMALIZAR] Equivalência de punição Expirar ↔ Rejeitar**

Do ponto de vista da fila e dos contadores, **Expirar e Rejeitar produzem o mesmo efeito**: empresa vai para fim da fila, QTD_RECUSAS incrementa, pode suspender. A diferença é **semântica/auditorial**:

- **Rejeitar**: ação explícita do operador/empresa. `MOTIVO` é texto livre.
- **Expirar**: tempo vencido. `MOTIVO` fixo = `PRAZO_EXPIRADO`.

**Implicação para o usuário:** ambos contam contra a empresa. Não há "ação suave" — ambos são tratados como recusa para fins de MAX_RECUSAS.

**Pergunta de design em aberto** (auditoria cruzada): faz sentido punição ser idêntica? Argumento "sim" — empresa que ignora o prazo se comporta como quem recusa. Argumento "não" — empresa pode ter razão de força maior; expiração silenciosa não é o mesmo que recusa ativa. Decisão diferida para deliberação humana.

### [NOVAS] Outros

**RN-30. [NOVA — FORMALIZAR] AUDIT_LOG é append-only e imutável**
- Nenhuma operação do sistema pode UPDATE ou DELETE em AUDIT_LOG.
- Edição manual por usuário é permitida tecnicamente (não há proteção forte da aba) mas é tratada como violação de auditoria.
- No SaaS futuro, equivalente é tabela com `INSERT only` e write-protection no banco.

**RN-31. [NOVA — FORMALIZAR] Aceitar e Emitir OS não é punição**
A função `EmitirOS()` em `Svc_OS.bas` chama `AvancarFila(EMP_ID, ATIV_ID, IsPunido=False, "ACEITE_OS_EMITIDA")`. Empresa avança para fim da fila SEM incremento de QTD_RECUSAS e SEM risco de suspensão.

**RN-32. [NOVA — IMPLEMENTAR] Pasta de auditoria por execução**
Toda execução do gate RVS (manual ou automatizada) gera uma pasta de auditoria conforme §8. Operador pode reconfigurar o caminho raiz e a política de retenção via sheet `CONFIG_TESTES` (§7.6).

---

## 4. O RODÍZIO — CONTRATO CRÍTICO

> Este capítulo é dedicado por decisão do gestor (B11.2): "a regra mais importante de todas é a garantia do funcionamento blindado, determinístico e idempotente da regra de rodízio".

### 4.1 Por que o rodízio é o coração

A justa distribuição entre empresas credenciadas é o que diferencia este sistema de uma licitação fragmentada. Se o rodízio:
- escolher empresa errada → **empresa lesada tem direito a contestar judicialmente**.
- travar quando todas estão ocupadas → **prefeitura fica sem capacidade de emitir** e operação para.
- penalizar duas vezes (suspender E perder turno) → **multa indevida**, contestável.
- variar entre execuções com mesmo estado → **fim da auditabilidade** (não dá para reproduzir decisão).

Portanto, o rodízio precisa ser: **correto** (escolhe certo), **resiliente** (não trava), **justo** (não pune em dobro), **determinístico** (reproduzível) e **idempotente** (efeitos colaterais previsíveis).

### 4.2 Especificação determinística passo-a-passo

Algoritmo formal (referência canônica para qualquer reimplementação, inclusive SaaS):

```
FUNÇÃO RodizioEscolherProxima(atividade_id, entidade_id):
  candidatos := todas as empresas em CREDENCIADOS com (ATIV_ID = atividade_id) E (STATUS_CRED = ATIVO)
  candidatos := candidatos ORDENADO ASCENDENTE por POSICAO_FILA

  PARA CADA candidato EM candidatos:
    empresa := candidato.empresa_ref

    # Reativação automática (RN-08)
    SE empresa.STATUS_GLOBAL = SUSPENSA_GLOBAL E empresa.DT_FIM_SUSP < HOJE:
      empresa.STATUS_GLOBAL := ATIVA
      LOG EVT_REATIVACAO_AUTOMATICA

    # Filtros de aptidão (RN-07)
    SE empresa.STATUS_GLOBAL ≠ ATIVA: continuar
    SE empresa em EMPRESAS_INATIVAS: continuar
    SE empresa tem OS com STATUS ∈ {ABERTA, EM_EXECUCAO} na mesma atividade: continuar
    SE empresa tem Pré-OS com STATUS = AGUARDANDO_ACEITE na mesma atividade: continuar
    SE candidato.STATUS_CRED ≠ ATIVO: continuar

    # Encontrou apta
    RETORNAR (Sucesso=True, EMP_ID=empresa.id)

  # Nenhuma apta
  RETORNAR (Sucesso=False, Motivo=SEM_CREDENCIADOS_APTOS)
```

**Invariantes da função:**
- I1: Iteração sempre na mesma ordem (`ORDER BY POSICAO_FILA ASC`).
- I2: Reativação automática é side-effect previsível e auditado.
- I3: Nunca lança exceção fatal — sempre retorna `(Sucesso, Motivo)`.
- I4: NÃO muta POSICAO_FILA (mutação só em `AvancarFila`, chamada depois).
- I5: Função é pura quanto à ordem de retorno (mesmo input = mesmo output).

### 4.3 Invariantes globais do sistema (NUNCA podem ser violados)

| ID | Invariante | Verificação |
|---|---|---|
| INV-01 | Empresa nunca tem 2 OS ATIVAS na mesma atividade simultaneamente | Query `COUNT(*) WHERE EMP_ID=x AND ATIV_ID=y AND STATUS ∈ {ABERTA, EM_EXECUCAO}` ≤ 1 |
| INV-02 | Pré-OS AGUARDANDO_ACEITE e OS ABERTA da mesma empresa+atividade não coexistem | Query cruzada PRE_OS × CAD_OS |
| INV-03 | POSICAO_FILA é única dentro do par (atividade, status=ATIVO) | `DISTINCT(POSICAO_FILA)` por atividade |
| INV-04 | DT_FIM_SUSP ≥ DT_INICIO_SUSP | Comparação em EMPRESAS |
| INV-05 | Empresa SUSPENSA_GLOBAL com motivo NOTA_BAIXA tem QTD_STRIKES ≥ MAX_STRIKES | Cross-check em EMPRESAS |
| INV-06 | Empresa SUSPENSA_GLOBAL com motivo MAX_RECUSAS tem QTD_RECUSAS ≥ MAX_RECUSAS | idem |
| INV-07 | AUDIT_LOG é monotonicamente crescente em data/hora | `ORDER BY DT_EVENTO ASC` deve ser permutação trivial |
| INV-08 | Todo registro em PRE_OS tem EMP_ID que existe em EMPRESAS ou EMPRESAS_INATIVAS | RN-24 |
| INV-09 | Toda OS tem PRE_OS_REF válida em PRE_OS | RN-24 |
| INV-10 | NOTA_CORTE ∈ [0.0, 10.0], MAX_STRIKES ≥ 1, DIAS_SUSPENSAO ≥ 1 | Validação em CONFIG |

Esses invariantes devem ser verificáveis por uma única função `Util_Integridade_Verificar()` (RN-24) e fazer parte do gate RVS.

### 4.4 Cenários históricos de regressão (regressões já vistas)

O guia V202 referencia bugs históricos. Documentamos aqui o que NUNCA pode voltar:

1. **CS-22 / V12.0.0193** — Recorte CNAE/CAD_SERV regredia o fluxo: `ATIV_ID` aparecia trocado entre emissões. Defesa: CS-22 testa associação atividade↔serviço preservada em múltiplas emissões.
2. **CS-07 / pré-V12.0.0200** — Bloqueio total travava com erro fatal. Defesa: CS-07 testa SEM_CREDENCIADOS_APTOS.
3. **CS-06 / pré-Onda 1** — Empresa B recebia 2 Pré-OS sem responder a primeira. Defesa: CS-06 testa que Pré-OS pendente bloqueia.
4. **CS-16 / Onda 1** — Empresa que cumpriu suspensão por strikes perdia turno ao voltar. Defesa: CS-16 testa retorno ordenado.

### 4.5 Cenários de regressão obrigatórios para Onda QA-V3

Adicionar ao gate RVS oficial após implementação:

- **CS-99 — Determinismo do rodízio**: duplicar workbook após CS-00, rodar mesma sequência em ambos, comparar EMP_IDs. Divergência = bug crítico.
- **CS-100 — Idempotência de populadores**: rodar `POP_CenarioCanonico` 2× e comparar estado.
- **CS-101 — Crash recovery**: matar Excel no meio de strike, reabrir, verificar consistência (PRE_OS órfã? OS sem PRE_OS_REF?).
- **CS-102 — Concorrência de cadastro**: simular 2 cadastros simultâneos de mesmo CNPJ (impossível em VBA single-thread, mas no SaaS é real — preparar contrato agora).

---

## 5. SETUP DO AMBIENTE DE TESTE

### 5.1 Pré-requisitos

- Arquivo `.xlsm` da versão alvo (V12.0.0206 + Onda QA-V3) com macros habilitadas.
- Senha de Limpar Base (do gestor).
- CSV padrão de CNAE em caminho esperado.
- Diário de Teste em branco (planilha auxiliar ou caderno).
- Apêndice A (Checklist) impresso ou em monitor secundário.

### 5.2 Backup obrigatório

Antes de qualquer execução, copiar o `.xlsm` para `backups/PlanilhaCredenciamento-Homologacao_<YYYY-MM-DD>_inicio-teste.xlsm`. Sem backup, não inicia.

### 5.3 Sequência de setup canônico (CS-00 expandido)

1. Backup feito (item 5.2).
2. Abrir planilha, habilitar macros.
3. Verificar versão na tela inicial — anotar build exato.
4. Configurações Iniciais → **Limpar Base** (senha).
5. Configurações Iniciais → **Reset CNAE** (anotar duplicatas removidas).
6. Configurações Iniciais → confirmar: `NOTA_CORTE=5,0`, `MAX_STRIKES=3`, `DIAS_SUSPENSAO_STRIKE=90`, `MAX_RECUSAS=3`, `DIAS_DECISAO=5`.
   > **[ITEM A7 — IMPLEMENTAR NA INTERFACE]:** atualmente `DIAS_DECISAO=5` e `MAX_RECUSAS=3` existem em CONFIG mas NÃO aparecem no form de Configurações Iniciais. Adicionar campos editáveis com validação `>=1`. Considerar janela "Mais configurações" para parâmetros menos frequentes.
7. Cadastrar 1 entidade (ex.: `ENT-CANON-001` / Escola Teste / CNPJ válido — RN-23 obrigatória).
8. Cadastrar 5 empresas (mudança: era 3, agora 5 para suportar CS-23+).
   > **Justificativa da mudança:** com 5 empresas, é possível ter 2 inabilitadas e ainda manter rotação de 3. Permite cenários CS-30+ de cobertura de inabilitação sem degenerar o teste.
9. Editar Catálogo: criar serviço "001|Servico-Canon-001".
10. Credenciar 5 empresas no serviço (A, B, C, D, E nas posições 1, 2, 3, 4, 5).
11. Salvar.

### 5.4 Convenções deste guia

| Convenção | Significado |
|---|---|
| Empresa A, B, C, D, E | 5 empresas canônicas, posições 1, 2, 3, 4, 5 |
| Atividade canônica | 001 |
| Serviço canônico | "001\|Servico-Canon-001" |
| Entidade canônica | ENT-CANON-001 |
| "Limpe a base, refaça CS-00" | Rodar Configurações → Limpar Base e repetir §5.3 |
| [OBRIGATÓRIO] | Falha bloqueia release |
| [COMPLEMENTAR] | Falha gera bug mas não bloqueia |
| [NOVO — V3] | Cenário introduzido na Onda QA-V3 |

---

## 6. ROTEIROS DE TESTE MANUAL

> **Importante:** os 23 cenários CS-00 a CS-22 são MANTIDOS do guia V202 com revisão de pré-condições para suportar 5 empresas (A-E). Onde o cenário original usava 3 empresas, agora roda igualmente com 5 (empresas D e E ficam livres).
>
> Cenários CS-23 a CS-40 são novos da Onda QA-V3.

### Cenários V202 (mantidos)

[Bloco 0 — Setup e validação] CS-00, CS-01, CS-02
[Bloco 1 — Fluxo nominal] CS-03, CS-04, CS-05, CS-06
[Bloco 2 — Bloqueio total] CS-07
[Bloco 3 — Retomadas] CS-08, CS-09, CS-10
[Bloco 4 — Suspensão manual] CS-11, CS-12, CS-13
[Bloco 5 — Suspensão por nota/Strikes] CS-14, CS-15, CS-16
[Bloco 6 — Loop e ciclo] CS-17, CS-18, CS-19
[Bloco 7 — Catálogo e integridade] CS-20, CS-21, CS-22

**Conteúdo integral dos CS-00 a CS-22:** reaproveitado do guia V202 (Apêndice F do anexo PDF). Para evitar duplicação textual, esse conteúdo é incorporado por referência. Diferenças e atualizações estão na seção §6.X abaixo.

### 6.X Atualizações dos cenários V202 para a Onda QA-V3

| Cenário | Mudança |
|---|---|
| CS-00 | Cadastrar 5 empresas (A-E) em vez de 3. Tabela de validação ampliada para 5 linhas em CREDENCIADOS. |
| CS-07 | Bloqueio total exige ocupar/suspender as 5 — emissão adicional para D e E antes da emissão que deve falhar. |
| CS-17 | Loop de 11 emissões em vez de 7 (A→B→C→D→E→A→B→C→D→E→A) para verificar ciclo com 5 elementos. |
| CS-18 | Suspender 5 em vez de 3. |
| CS-19 | Reabilitação em cadeia das 5. |

### Bloco 8 — Integridade Estendida [NOVO — V3]

#### CS-23 — Sistema rejeita cadastro de CNPJ com dígitos verificadores inválidos [OBRIGATÓRIO]
**Pré-condição:** CS-00 concluído.
**Passos:**
1. Tentar cadastrar empresa nova com CNPJ "11.111.111/1111-11" (formatado correto mas matematicamente inválido).
2. Confirmar.
**Resultado esperado:**
- Sistema REJEITA com mensagem `CNPJ_INVALIDO`.
- Linha NÃO é criada em EMPRESAS.
- AUDIT_LOG registra `VALIDACAO_REJEITADA` com motivo `CNPJ_INVALIDO`.
**Razão:** RN-23. Hoje o sistema ACEITA (bug `INT-EMP-CNPJ-DUP`). Após implementação, deve rejeitar.

#### CS-24 — Sistema rejeita CNPJ duplicado mesmo com formatação diferente [OBRIGATÓRIO]
**Pré-condição:** CS-00. Empresa A já cadastrada com CNPJ "22.222.222/2222-22".
**Passos:**
1. Tentar cadastrar nova empresa com CNPJ "22222222222222" (sem formatação).
2. Confirmar.
**Resultado esperado:**
- Sistema REJEITA por duplicidade (após normalização).
- `NormalizarCNPJ` é aplicado antes da comparação.
**Razão:** RN-01 + RN-23. Pega bug onde normalização não é aplicada na comparação.

#### CS-25 — Verificador de integridade referencial detecta órfãos [OBRIGATÓRIO]
**Pré-condição:** CS-00 + cadastro adicional manual: editar diretamente CREDENCIADOS para apontar a uma empresa que NÃO existe (`EMP_ID=999`).
**Passos:**
1. Executar Configurações → Verificar Integridade (a implementar).
**Resultado esperado:**
- Sheet `INTEGRIDADE_REFS` é criada/atualizada com 1 linha: `CRED_xxx aponta para EMP_ID=999 inexistente`.
- MsgBox alerta sobre violações encontradas.
- Sistema continua funcional (não trava).
**Razão:** RN-24.

### Bloco 9 — Documentação de Pré-OS (Expira/Rejeita) [NOVO — V3]

> Motivação: B11.5 do gestor — "os botões de 'expira pré ss' e 'rejeita pré ss' eu não entendo exatamente". Aqui validamos a documentação.

#### CS-26 — Expirar Pré-OS produz efeitos documentados em RN-27 [OBRIGATÓRIO]
**Pré-condição:** CS-00 + Pré-OS aberta para empresa A com DT_LIMITE_ACEITE = ontem.
**Passos:**
1. Operador clica em "Expirar Pré-SS".
2. Conferir estado.
**Resultado esperado:**
- Pré-OS de A: STATUS=EXPIRADA, MOTIVO=PRAZO_EXPIRADO.
- A foi para fim da fila.
- QTD_RECUSAS de A foi incrementado em 1.
- A NÃO foi suspensa (1 recusa só, MAX_RECUSAS=3).
- AUDIT_LOG: EVT_PREOS_EXPIRADA + EVT_RODIZIO_AVANCOU.
- Nenhum EVT_SUSPENSAO_AUTOMATICA.
**Razão:** RN-27 documentado.

#### CS-27 — Rejeitar Pré-OS produz efeitos documentados em RN-28 [OBRIGATÓRIO]
**Pré-condição:** CS-00 + Pré-OS aberta para empresa A.
**Passos:**
1. Operador clica em "Rejeitar Pré-SS" e informa motivo "ocupado com outro serviço".
2. Conferir estado.
**Resultado esperado:**
- Pré-OS de A: STATUS=RECUSADA, MOTIVO="ocupado com outro serviço".
- A foi para fim da fila.
- QTD_RECUSAS de A incrementado em 1.
- AUDIT_LOG: EVT_PREOS_RECUSADA.
**Razão:** RN-28 documentado.

#### CS-28 — Equivalência de punição Expirar↔Rejeitar [OBRIGATÓRIO]
**Pré-condição:** CS-00. Empresa A em posição 1, fila A-B-C-D-E.
**Passos:** dois sub-cenários paralelos partindo do mesmo estado canônico:
- **Variante X**: 3 expirações consecutivas de Pré-OS de A.
- **Variante Y**: 3 rejeições consecutivas de Pré-OS de A.
**Resultado esperado:** ambas as variantes produzem estado equivalente:
- A: SUSPENSA_GLOBAL, motivo MAX_RECUSAS, DT_FIM_SUSP = hoje + MESES_SUSPENSAO.
- QTD_RECUSAS = 3 nos dois casos.
- AUDIT_LOG difere apenas em EVT_PREOS_RECUSADA vs EVT_PREOS_EXPIRADA (3 cada).
**Razão:** RN-29 (equivalência semântica formalizada).

#### CS-29 — Idempotência protetiva de Expirar/Rejeitar [COMPLEMENTAR]
**Pré-condição:** CS-26 concluído (Pré-OS já EXPIRADA).
**Passos:**
1. Clicar em "Expirar Pré-SS" outra vez sobre a mesma Pré-OS.
**Resultado esperado:**
- Sistema retorna erro `STATUS_INVALIDO` ou similar.
- Pré-OS permanece EXPIRADA.
- Nenhum efeito colateral adicional (sem novo AvancarFila, sem novo strike).
- AUDIT_LOG: opcionalmente registra tentativa rejeitada.
**Razão:** RN-26 (idempotência protetiva).

### Bloco 10 — Cobertura ampliada com 5 empresas [NOVO — V3]

#### CS-30 — Duas empresas inabilitadas, três operacionais [OBRIGATÓRIO]
**Pré-condição:** CS-00 (5 empresas, posições A-B-C-D-E).
**Passos:**
1. Inativar empresa B (cadastralmente).
2. Suspender empresa D (manualmente, DT_FIM_SUSP futura).
3. Emitir 9 Pré-OS consecutivas (com aceite-OS-conclusão entre cada).
**Resultado esperado:**
- Sequência de empresas indicadas: A, C, E, A, C, E, A, C, E.
- B e D nunca aparecem.
- Sistema não trava em momento algum.
**Razão:** Cobertura de fila degenerada (3 aptos em 5) — gap atual.

#### CS-31 — Inabilitação durante ciclo ativo [COMPLEMENTAR]
**Pré-condição:** CS-00 + Pré-OS aberta para A.
**Passos:**
1. Antes de A responder, inativar A cadastralmente.
2. Emitir nova Pré-OS.
**Resultado esperado:**
- Pré-OS aberta de A permanece visível na aba PRE_OS (não é apagada).
- Nova Pré-OS sai para B.
- AUDIT_LOG documenta inativação de A com Pré-OS pendente (caso de borda).
**Razão:** Comportamento sob race condition (mesmo single-thread, operador pode causar).

### Bloco 11 — Determinismo e Idempotência [NOVO — V3]

#### CS-32 — Determinismo do rodízio (CS-99 canonizado) [OBRIGATÓRIO]
**Pré-condição:** CS-00.
**Passos:**
1. Salvar workbook como `cópia_A.xlsm`.
2. Salvar workbook como `cópia_B.xlsm`.
3. Em A: emitir 7 Pré-OS, anotar EMP_IDs.
4. Em B: emitir 7 Pré-OS, anotar EMP_IDs.
5. Comparar sequências.
**Resultado esperado:** sequências IDÊNTICAS.
**Razão:** RN-25. Bug crítico se diferir.

#### CS-33 — Idempotência de POP_CenarioCanonico [OBRIGATÓRIO]
**Pré-condição:** Workbook em estado qualquer.
**Passos:**
1. Rodar `POP_CenarioCanonico` (5 empresas, 3 locais, 1 atividade).
2. Snapshot do estado.
3. Rodar `POP_CenarioCanonico` outra vez.
4. Comparar com snapshot.
**Resultado esperado:** estados idênticos (mesmas linhas em EMPRESAS, ENTIDADE, CAD_SERV, CREDENCIADOS).
**Razão:** RN-26.

### Bloco 12 — Pasta de Auditoria e PDF [NOVO — V3]

#### CS-34 — Geração de pasta de auditoria completa em RVS [OBRIGATÓRIO]
**Pré-condição:** Workbook com cenário canônico populado.
**Passos:**
1. Configurações → CONFIG_TESTES → marcar "exportar pasta de auditoria".
2. Rodar RVS Sexteto Mínimo.
3. Verificar pasta criada.
**Resultado esperado:** pasta no caminho configurado com subpastas conforme §8.3, MANIFESTO.md preenchido, NARRATIVA.md em português, todos os PDFs gerados, CSVs em `02_evidencias_csv/`.
**Razão:** RN-32 + §8.

### Bloco 13 — Cobertura Combinatória Pairwise [NOVO — V3]

#### CS-35 a CS-40 — Matriz pairwise dos eixos primários
**Geração:** automatizada via ferramenta externa (PICT da Microsoft ou equivalente).
**Output:** sheet `CENARIOS_RECEITAS_PAIRWISE` com ~20-30 receitas cobrindo 100% dos pares dos 5 eixos primários × 5 eixos quantitativos com cortes críticos.
**Implementação:** Onda QA-V3 sprint 7.

---

## 7. ARQUITETURA V3 (PROPOSTA — A IMPLEMENTAR)

### 7.1 Princípio: V3 envelopa, não substitui

V3 é uma **plataforma** que executa V1 e V2 internamente e adiciona capacidades novas. Decisão do gestor (B2, B11.9): nenhum teste V1/V2 é removido nesta onda. V3 absorve por consunção em ondas futuras (Onda QA-V3.X) quando 100% dos cenários V1/V2 tiverem equivalente V3 com mutation score comprovado.

### 7.2 Camadas

```
┌──────────────────────────────────────────────────────────┐
│           V3 = PLATAFORMA DE TESTES                       │
│                                                            │
│  ENGINE V3 (shared) — log unificado, status global        │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  POPULADORES (idempotentes, não geram evidência)    │  │
│  │  POP_CenarioCanonico, POP_Volumetrico, POP_Receita  │  │
│  │  POP_LimparOperacional, POP_LimparAuditoria, ...    │  │
│  └─────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  DSL DE RECEITAS (sheet CENARIOS_RECEITAS)          │  │
│  │  Cada linha = parâmetros + nome + descrição         │  │
│  └─────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  SUITES                                              │  │
│  │  V1 (legada, intacta)                                │  │
│  │  V2 (mantida)                                        │  │
│  │  V3.Smoke, V3.Combinatorial, V3.Adversarial         │  │
│  └─────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  REPORTERS (saída multi-formato)                    │  │
│  │  Sheet QA + CSV + PDF + Pasta de Auditoria + MD     │  │
│  └─────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  MODO TUTORIAL (Gerador, 4 modos)                   │  │
│  │  TREINO / DEMO / DEBUG / CERTIFICAÇÃO               │  │
│  └─────────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  MENU V3 HIERÁRQUICO (sheet MENU_TESTES_V3)         │  │
│  └─────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

### 7.3 DSL de Receitas (sheet `CENARIOS_RECEITAS`)

Cada linha define um cenário parametrizado. Colunas mínimas:

| Coluna | Tipo | Significado |
|---|---|---|
| RECEITA_ID | string | Único, ex.: `CEN_010` |
| NOME | string | Curto, exibível |
| DESCRICAO | string | 1-2 linhas explicando |
| N_EMPRESAS | int | Quantas empresas criar |
| N_LOCAIS | int | Quantas entidades demandantes |
| N_ATIVIDADES | int | Quantas atividades distintas |
| DIST_CNAES | enum | `uniforme` / `concentrado` / `aleatorio-seed` |
| RECUSAS_INIT | int | QTD_RECUSAS inicial nas empresas |
| STRIKES_INIT | int | QTD_STRIKES inicial |
| DIAS_OFFSET | int | Quantos dias antes/depois para datas iniciais |
| EMPRESAS_INATIVAS | int | Quantas marcadas inativas |
| EMPRESAS_SUSPENSAS | int | Quantas suspensas |
| MEDIA_INICIAL | float | MEDIA pré-populada (ex.: para testar gatilho) |
| CASO_DE_USO | string | "Treino", "Stress", "Boundary", "Adversarial" |

**Seed inicial (10 receitas):**

| ID | Nome | Caso |
|---|---|---|
| CEN_001 | Canônico mínimo (5 empresas) | Treino |
| CEN_002 | Canônico + 2 inativas | Treino |
| CEN_003 | Canônico + suspensão por strikes pendente | Boundary |
| CEN_010 | Volumétrico médio (30 empresas, 10 locais) | Stress |
| CEN_011 | Volumétrico grande (100 empresas) | Stress |
| CEN_020 | Pré-rodízio adversarial (recusas iniciais) | Adversarial |
| CEN_021 | Boundary de strikes (2 strikes prévios) | Boundary |
| CEN_022 | Boundary de recusas (MAX-1 recusas) | Boundary |
| CEN_023 | Fila degenerada (1 empresa apta entre 10) | Adversarial |
| CEN_030 | Cenário pairwise base (auto-gerado) | Cobertura |

### 7.4 Populadores idempotentes

Princípio: **rodar 2× = mesmo estado**. Não geram evidência QA. Não resetam dados existentes — apenas garantem o estado-alvo.

Lista mínima:
- `POP_CenarioCanonico(nEmpresas=5, nLocais=3, nAtividades=1)`
- `POP_CenarioVolumetrico(n, m, k)`
- `POP_CenarioBoundary(tipo)` — strikes/recusas/datas no limite
- `POP_CenarioPorReceita(receitaId)` — lê da sheet
- `POP_LimparOperacional()` — wrapper de `CT_LimparTestesAntigos`
- `POP_LimparAuditoria()` — apenas RESULTADO_QA, HISTORICO, TRILHA (preserva AUDIT_LOG operacional)
- `POP_LimparSnapshotsAntigos(diasMin=30)` — sheets sufixadas
- `POP_LimparTudo()` — confirmação tripla
- `POP_Snapshot(nome)` — backup nomeado
- `POP_RestaurarSnapshot(nome)`
- `POP_PreVisualizarLimpeza()` — lista o que seria apagado, sem apagar

### 7.5 Modo Tutorial — 4 modos (B11.4)

Modelo de **gerador de tutorial**: a partir de uma sequência declarativa de passos, o engine produz o tutorial em 1 dos 4 modos.

```vba
Public Sub TUT_GerarTutorial(tourId As String, modo As TutorialModo)
    ' Lê sheet TOUR_PASSOS WHERE TOUR_ID = tourId
    ' Para cada passo, executa em ordem com:
    '   - TM_TREINO: MsgBox completo, espera OK, narração rica
    '   - TM_DEMO: status bar + espera 2-3s, narração resumida
    '   - TM_DEBUG: pausa + dump de estado em sheet ESTADO_DEBUG
    '   - TM_CERTIFICACAO: produz PDF de evidência por passo, sem MsgBox
End Sub
```

**Sheet `TOUR_PASSOS`** (DSL de tutorial):

| TOUR_ID | PASSO_NUM | TITULO | DESCRICAO | ACAO_VBA | ACAO_ESPERADA |
|---|---|---|---|---|---|
| TUR_CRED | 1 | Cadastrar Local | "Local é onde a OS é executada" | `TV2_CadastrarEntidadeCanonica "001","Local 1"` | "Nova linha em ENTIDADE" |
| TUR_CRED | 2 | Cadastrar Empresa | "Empresa fornece serviço" | `TV2_CadastrarEmpresaCanonica "001","Empresa 1"` | "Nova linha em EMPRESAS" |

**Tours iniciais (MVP):**
1. **TUR_CRED** — Fluxo de credenciamento (12 passos)
2. **TUR_RODIZIO** — Rodízio com strikes (15 passos)
3. **TUR_PREOS_FLUXO** — Pré-OS → OS → Avaliação → PDF (10 passos)
4. **TUR_EXPIRA_REJEITA** — Pré-OS Expirar vs Rejeitar com efeitos (8 passos) — atende B11.5

**MVP em módulo paralelo** (B9 + B11.10): o gerador de tutorial nasce como módulo `Tutorial_V3.bas` separado, **podendo evoluir em workbook próprio** (`Credenciamento_Tutorial.xlsm`) que importa estado do principal. Quando estabilizado, acopla na planilha principal via import.

**Esforço estimado MVP:**
- Engine + sheet TOUR_PASSOS + 1 tour completo: **1 sprint** (3-5 dias úteis IA implementadora)
- 4 tours + 4 modos completos: **3 sprints**

### 7.6 Sheet `CONFIG_TESTES` — configuração de testes (B11.3)

Nova sheet (não sobrepõe CONFIG de regras de negócio). Coloca parâmetros de execução de teste sob controle do usuário:

| CHAVE | VALOR_DEFAULT | DESCRIÇÃO |
|---|---|---|
| `pasta_auditoria_root` | `<workbook>/auditoria_execucao/` | Onde salvar pasta de auditoria |
| `pasta_auditoria_dias_retencao` | 90 | Apaga pastas mais antigas que N dias |
| `pasta_auditoria_apagar_no_inicio` | NO | Se SIM, apaga antigas antes de cada gate |
| `pdf_gerar_em_rvs` | YES | Geração de PDF em RVS automático |
| `pdf_gerar_em_smoke` | NO | (performance) |
| `tutorial_modo_default` | TM_TREINO | Quando o usuário não escolhe |
| `csv_companion_gerar` | YES | CSV resumido para leitura por IA (B11.8) |
| `compactar_apos_rvs` | NO | Cria .zip da pasta após RVS |
| `numero_empresas_canonico` | 5 | Default no setup |

### 7.7 Menu V3 hierárquico (proposta detalhada)

Reorganização do menu de Central_Testes_V2 (atualmente 21 opções lineares). Via sheet `MENU_TESTES_V3` editável (B4 — menus de navegação por categoria).

```
═══════════════════════════════════════════════════════════════
   CENTRAL DE TESTES V3 — Credenciamento
═══════════════════════════════════════════════════════════════

▼ GATES OFICIAIS (release)
  [1] RVS  — Validação Release (336+ testes, ~8min)
  [2] SRC  — Regressão Consolidada
  [3] BRL  — Bateria Rápida Legada
  [4] Smoke Pré-Commit (~30s)

▼ SUITES POR DOMÍNIO
  [5] V1 Bateria Oficial (legada, intacta)
  [6] V2 Canônico Fundação
  [7] V2 Stress
  [8] V2 Filtros Determinísticos
  [9] V2 Strikes E2E
 [10] V2 Adversarial (UI + Interrupt + Boundary)
 [11] V3 Smoke (envelopa Smoke V2 + cenários novos CS-23+)
 [12] V3 Combinatorial Pairwise
 [13] V3 Determinismo (CS-32, CS-33)

▼ POPULADORES (preparar planilha)
 [14] Canônico (5 empresas × 3 locais)
 [15] Volumétrico (N × M, parametrizável)
 [16] Por Receita (escolher da sheet)
 [17] Construtor Customizado (UI)
 [18] Restaurar Snapshot

▼ MODO TUTORIAL
 [19] Tour Guiado — Credenciamento (4 modos disponíveis)
 [20] Tour Guiado — Rodízio + Strikes
 [21] Tour Guiado — Pré-OS Fluxo Completo
 [22] Tour Guiado — Expirar vs Rejeitar Pré-OS (B11.5)
 [23] Reprise — re-roda último cenário em modo lento

▼ AUDITORIA & EVIDÊNCIA
 [24] Abrir Resultado QA
 [25] Abrir Trilha (sequência narrada)
 [26] Abrir Histórico + Evolução
 [27] Exportar Pasta de Auditoria (manual)
 [28] Compactar e preparar para envio externo
 [29] Verificar Integridade Referencial

▼ HIGIENE
 [30] Limpar dados operacionais (preserva auditoria)
 [31] Limpar auditoria (preserva operacional)
 [32] Limpar snapshots antigos (>N dias)
 [33] Limpar TUDO (confirma 3x)
 [34] Pré-visualizar limpeza
 [35] Snapshot manual (backup nomeado)

▼ CONFIG & AJUDA
 [36] Abrir CONFIG_TESTES
 [37] Abrir CONFIG (regras de negócio)
 [38] Ajuda — abrir guia GitHub + FAQ
```

---

## 8. PDFs E PASTA DE AUDITORIA (DETALHADO — RESPOSTA B8)

### 8.1 Estado atual e gap

**Hoje:** PDF não é gerado nativamente. Sistema usa `PrintOut` (impressora física) em sheets formatadas A4. `ExportAsFixedFormat` (export PDF nativo Excel) NÃO está implementado.

**Documentação histórica resgatada** (investigação):
- Padrão nomenclatura definido em [docs/reference/testes/ESPEC_PDF_AUTOMATICO_V205.md](docs/reference/testes/ESPEC_PDF_AUTOMATICO_V205.md): `V2_VALIDACAO_HUMANA_RVS_V12_0_0205_<VALIDATION_ID>.pdf`
- Requisitos de cabeçalho/rodapé em [auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md](auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md): hash SHA-1, build label, timestamp RFC 3339, resumo estruturado `RESUMO: [N OSes] [M strikes] [K suspensões] [STATUS=...]`
- Util_PDF.bas foi PROPOSTO em V205 mas não implementado (estado V205: fallback manual)

### 8.2 Proposta de nomenclatura (ampliada a partir do histórico)

**Sigla curta por tipo de documento:**

| Sigla | Tipo |
|---|---|
| `PRESS` | Pré-Solicitação de Serviço (Pré-OS) |
| `OS` | Ordem de Serviço |
| `AVAL` | Avaliação |
| `RPT_ROT` | Relatório Roteiro Rápido |
| `RPT_BAT` | Relatório Bateria Oficial |
| `RPT_CK136` | Validação Humana 136 critérios |
| `RPT_CONS` | Relatório Consolidado |
| `ATO_CRED` | Ato de Credenciamento |
| `ATO_SUSP` | Ato de Suspensão |
| `ATO_REAT` | Ato de Reativação |
| `ATO_INAT` | Ato de Inativação |
| `MAN_EXEC` | Manifesto de Execução de Teste |

**Padrão de nome:**
`<SIGLA>_<EMP_ID_OR_RVSID>_<YYYYMMDD>_<HHMMSS>.pdf`

Exemplos:
- `PRESS_E001_20260527_143022.pdf` — Pré-OS para Empresa 001
- `OS_E001_20260527_150115.pdf` — OS emitida
- `RPT_BAT_V12.0.0206_20260527_201530.pdf` — Relatório de bateria
- `ATO_SUSP_E001_20260601_090000.pdf` — Ato de suspensão de E001

### 8.3 Estrutura de pasta de auditoria

```
auditoria_execucao/
└─ RVS_V12.0.0206_E20260527-091532_20260527_091532/
   ├─ 00_MANIFESTO.md              ← índice + metadados + hash SHA-1 do workbook
   ├─ 00_NARRATIVA.md              ← explicação humana (PT) do que aconteceu
   ├─ 00_RESUMO.csv                ← CSV companion (B11.8) — economia de tokens IA
   ├─ 01_dados_operacionais/       ← snapshot CSV das abas no fim da execução
   │   ├─ EMPRESAS.csv
   │   ├─ ENTIDADE.csv
   │   ├─ CREDENCIADOS.csv
   │   ├─ PRE_OS.csv
   │   ├─ CAD_OS.csv
   │   └─ AUDIT_LOG.csv
   ├─ 02_evidencias_csv/           ← CSVs de teste gerados
   │   ├─ TesteV2_SMOKE_Falhas_*.csv
   │   ├─ ValidacaoReleaseRVS_*.csv
   │   └─ Strikes_E2E_*.csv
   ├─ 03_pdfs_gerados/             ← cada documento como PDF (ExportAsFixedFormat)
   │   ├─ press/
   │   │   ├─ PRESS_E001_20260527_143022.pdf
   │   │   └─ PRESS_E002_20260527_143155.pdf
   │   ├─ os/
   │   ├─ aval/
   │   ├─ atos/
   │   └─ relatorios/
   │       ├─ RPT_BAT_V12.0.0206_20260527_201530.pdf
   │       └─ RPT_CONS_V12.0.0206_20260527_201530.pdf
   ├─ 04_screenshots/              ← (opcional) capturas de tela das etapas
   ├─ 05_explicacoes/              ← MDs por cenário CS-XX
   │   ├─ CS-00_setup.md
   │   ├─ CS-03_primeira_emissao.md
   │   ├─ CS-07_bloqueio_total.md
   │   └─ ...
   └─ 99_reexecucao/               ← (NOVO) scripts para reproduzir
       ├─ replay.json              ← lista ordenada de ações
       └─ replay_humano.md         ← passo-a-passo para humano reproduzir
```

### 8.4 CSV companion (B11.8 — economia de tokens IA)

Arquivo `00_RESUMO.csv` com schema otimizado para leitura por IA:

| Coluna | Descrição |
|---|---|
| TIMESTAMP | UTC ISO 8601 |
| EVENTO | EVT_PREOS_EMITIDA, EVT_OS_CONCLUIDA, etc. |
| EMP_ID | Empresa afetada |
| ENT_ID | Entidade |
| ATIV_ID | Atividade |
| STATUS_ANTES | Estado antes da ação |
| STATUS_DEPOIS | Estado depois |
| QTD_RECUSAS | Contador no momento |
| QTD_STRIKES | Contador no momento |
| POSICAO_FILA | Posição no momento |
| OBSERVACAO | Texto curto |

Esse CSV é "denso" — um RVS inteiro cabe em ~200 KB versus megabytes de PDFs. IA auditora lê esse para verificar coerência e só baixa PDF específico se precisar.

### 8.5 Compactação e portabilidade (B11.8 — uso em outra máquina)

Sub `AUDIT_CompactarPasta(pastaRaiz) → caminho.zip`:
- Gera arquivo `.zip` com toda a pasta.
- Nome do .zip: `RVS_<BUILD>_<EXEC_ID>_<TIMESTAMP>.zip`
- Tamanho típico estimado: 5-20 MB (planilha pequena), 50-100 MB (volumétrica).
- Acompanhado de `README_EXTERNO.md` (template) explicando como ler em outra máquina sem o `.xlsm`.

### 8.6 Reexportação narrativa de cenário (B11.8)

Sub `AUDIT_ReexportarCenarioComoNarrativa(execId) → MD`:
- Reconstrói, a partir de `AUDIT_LOG.csv` e `00_RESUMO.csv`, uma narrativa em prosa:

```markdown
# Reexecução do cenário RVS_V12.0.0206_E20260527

## Sequência de ações reconstruída

1. **14:30:22** — Operador emitiu Pré-OS para a Empresa E001 (Empresa 1),
   entidade ENT-001 (Local 1), serviço "001|Servico-Canon-001".
   Estado da fila antes: [E001:1, E002:2, E003:3, E004:4, E005:5]
   Resultado: Pré-OS 042 criada, AGUARDANDO_ACEITE.

2. **14:31:55** — Empresa E001 aceitou. Operador emitiu OS 015.
   Avanço de fila: E001 vai para posição 5. Nova fila: [E002:1, ..., E001:5].

3. ...
```

Útil para: auditor externo entender execução sem abrir Excel; IA processar texto natural; comprovação legal.

### 8.7 Esforço estimado para implementação completa

| Sprint | Entregável | Esforço |
|---|---|---|
| QA-V3.PDF.1 | `Util_PDF.bas` + ExportAsFixedFormat funcionando | 2-3 dias |
| QA-V3.PDF.2 | Nomenclatura SIGLA_ID_TIMESTAMP em todos os PDFs gerados | 1-2 dias |
| QA-V3.PDF.3 | Estrutura de pasta + MANIFESTO + NARRATIVA + CSV_COMPANION | 3-5 dias |
| QA-V3.PDF.4 | Compactação + reexportação narrativa | 2 dias |
| **TOTAL** | **Pasta de auditoria completa** | **8-12 dias úteis** |

---

## 9. GERADOR DE TUTORIAL (DETALHADO — RESPOSTA B11.4)

### 9.1 4 modos de uso

| Modo | Audiência | UI | Tempo |
|---|---|---|---|
| **TM_TREINO** | Operador novo | MsgBox completa, narração rica, espera OK | 30-60min por tour |
| **TM_DEMO** | Visita de auditor / fornecedor | Status bar + 2-3s entre passos | 10-15min |
| **TM_DEBUG** | Suporte técnico investigando bug | Dump de estado em sheet a cada passo, pausa configurável | sob demanda |
| **TM_CERTIFICACAO** | Auditor externo gerando evidência | Sem MsgBox; produz PDF por passo + log estruturado | automático |

### 9.2 MVP em módulo paralelo

Decisão (B9): MVP em workbook próprio `Credenciamento_Tutorial.xlsm` que importa estado do `.xlsm` principal. Vantagens:
- Itera sem afetar produção
- Pode quebrar sem risco
- Quando estabilizado, vira módulo `Tutorial_V3.bas` na planilha principal

### 9.3 Esforço estimado

| Fase | Entregável | Esforço |
|---|---|---|
| MVP-1 | Engine + sheet TOUR_PASSOS + TUR_CRED em TM_TREINO | 3 dias |
| MVP-2 | + TM_DEMO e TM_DEBUG | 2 dias |
| MVP-3 | + 3 tours adicionais (RODIZIO, PREOS, EXPIRA_REJEITA) | 4 dias |
| MVP-4 | + TM_CERTIFICACAO com geração PDF por passo | 3 dias |
| Acoplamento | Importar módulo na planilha principal | 1 dia |
| **TOTAL MVP completo** | | **13 dias úteis** |

### 9.4 Capítulo especial — TUR_EXPIRA_REJEITA (B11.5)

Tour dedicado a explicar visualmente os botões "Expira Pré-SS" e "Rejeita Pré-SS":

**Passos (8):**
1. Mostrar Pré-OS aberta de empresa A na sheet PRE_OS. Narrar: "Esta é uma Pré-OS aguardando resposta. Empresa A tem 5 dias para decidir."
2. Mostrar contador QTD_RECUSAS de A = 0.
3. **CAMINHO REJEITAR**: Operador clica Rejeitar, informa motivo.
4. Mostrar mudanças: STATUS=RECUSADA, QTD_RECUSAS=1, A vai para fim da fila. AUDIT_LOG mostra EVT_PREOS_RECUSADA.
5. Reset cenário para mesma posição inicial.
6. **CAMINHO EXPIRAR**: Operador clica Expirar (com DT_LIMITE_ACEITE = ontem forçada).
7. Mostrar mudanças: STATUS=EXPIRADA, QTD_RECUSAS=1, A vai para fim. AUDIT_LOG mostra EVT_PREOS_EXPIRADA.
8. **Conclusão narrada**: "Os dois caminhos produzem mesmo efeito na fila e no contador. A diferença é semântica: Rejeitar é decisão explícita; Expirar é prazo automático. Ambos contam para MAX_RECUSAS=3 antes de suspensão global."

---

## 10. MAPA DE VARIÁVEIS E COBERTURA

(Conteúdo completo em §0.3 e Apêndice C. Aqui, a tabela de cobertura atual × alvo.)

### 10.1 Cobertura por entidade

| Entidade | Estados | Cobertos V202 | Cobertos V3 alvo |
|---|---|---|---|
| Empresa | 3 | 3 ✓ | 3 ✓ |
| Credenciamento | 3 | 3 ✓ | 3 ✓ |
| Pré-OS | 5 | 4 ✓ (falta ACEITA isolado) | 5 ✓ |
| OS | 4 | 2 (ABERTA, CONCLUIDA) | 4 ✓ (incluir EM_EXECUCAO e CANCELADA) |
| Atividade | 2 | 2 ✓ | 2 ✓ |

### 10.2 Cobertura de pares (pairwise) — alvo Onda QA-V3 sprint 7

Geração automatizada via PICT. Apêndice D conterá matriz completa após implementação.

---

## 11. CRITÉRIOS DE ACEITE GLOBAIS

Versão V12.0.0206 + Onda QA-V3 será APROVADA quando TODOS os critérios abaixo forem verdadeiros:

1. **Cobertura mínima.** Todos os 16 cenários OBRIGATÓRIOS herdados V202 (CS-00, 01, 02, 03, 04, 05, 06, 07, 08, 11, 13, 14, 15, 16, 17, 20, 22) passam com APROVADO.
2. **Cobertura nova.** Todos os cenários OBRIGATÓRIOS V3 (CS-23, 24, 25, 26, 27, 28, 30, 32, 33, 34) passam.
3. **Determinismo.** CS-32 prova reproducibilidade. Duas execuções idênticas → mesma sequência de empresas.
4. **Idempotência.** CS-33 prova que populadores não acumulam.
5. **Ausência de travamento.** Nenhum cenário gera erro fatal de Excel. Bloqueios previstos (CS-07, CS-18) respondem com mensagem clara.
6. **Auditoria íntegra.** AUDIT_LOG completo, append-only, sem linhas em branco. INV-07 verificado.
7. **Integridade referencial.** `Util_Integridade_Verificar()` retorna 0 violações.
8. **Validação CNPJ.** CS-23 e CS-24 passam — RN-23 implementada.
9. **Não regressão.** RVS automatizado (V1 + V2 + V3 Smoke) continua passando após execução manual.
10. **Pasta de auditoria.** CS-34 prova geração completa e abrível.
11. **Tutorial mínimo.** TUR_CRED em TM_TREINO funciona end-to-end (avaliação subjetiva do gestor).
12. **Retorno ordenado comprovado.** CS-16 valida que empresa suspensa por strikes NÃO perde turno ao voltar.
13. **Equivalência Expira/Rejeita.** CS-28 valida RN-29.
14. **Documentação publicada.** Este guia (versão DRAFT pós-auditoria cruzada) está em `docs/reference/testes/` no repositório e acessível via botão Ajuda.

---

## 12. COMO REPORTAR RESULTADOS

(Conteúdo herdado do guia V202, §8 — mantido integralmente.)

### 12.1 Diário de Teste
Planilha auxiliar com colunas: ID, Data/hora, Testador, Resultado (APROVADO/REPROVADO/BLOQUEADO), Observações, Anexos.

### 12.2 Severidade dos defeitos
- **CRÍTICO**: travamento, perda de dado, rodízio violado. Bloqueia release.
- **ALTO**: divergência sem perda de dado. Bug de regra. Bloqueia release.
- **MÉDIO**: mensagem confusa, fluxo trabalhoso. Não bloqueia.
- **BAIXO**: tipográfico. Não bloqueia.

### 12.3 Evidências mínimas por bug
- Print de tela do sintoma.
- Últimas 10 linhas de AUDIT_LOG.
- Estado das abas relevantes em CSV.
- ID do cenário e passo exato.
- **[NOVO V3]**: pasta de auditoria da execução (gerada automaticamente).

### 12.4 Tabela de mensagens conhecidas
(Conforme §8.4 do guia V202, expandida com mensagens novas.)

| Mensagem | Quando aparece | É bug? |
|---|---|---|
| `SEM_CREDENCIADOS_APTOS` | Bloqueio total esperado | Não — verificar fila preservada |
| `DUPLICIDADE_SERVICO` | Cadastro duplicado de serviço | Não |
| `VINCULO_INVALIDO` | Serviço sem atividade pai | Não |
| `CNPJ_INVALIDO` [NOVO] | Dígitos verificadores falham (RN-23) | Não |
| `CNPJ_DUPLICADO` [NOVO] | Normalização revela duplicidade | Não |
| `INTEGRIDADE_REF_VIOLADA` [NOVO] | Verificador acha órfão (RN-24) | Não — investigar causa |
| `STATUS_INVALIDO` [NOVO] | Tentativa de operação em status incompatível (RN-26) | Não — proteção idempotente |
| `Erro 1004 (planilha protegida)` | Sistema tentou escrever em aba protegida | **SIM** |
| `Erro 9 / 91` | Subscript out of range, Object not set | **SIM** |
| MsgBox sem mensagem clara | Popup vago | **SIM** UX |

---

## 13. FAQ (a manter vivo em GitHub — B11.1)

> Esta seção é seed para o FAQ que viverá no repositório do projeto. Cada município adotante pode contribuir com PR adicionando perguntas. Acesso direto via **botão Ajuda** na Configuração Inicial.

**Q1: Por que o sistema escolheu a empresa B se A está em posição 1?**
R: A só é escolhida se estiver APTA. Se A tem OS aberta (RN-13), Pré-OS pendente (RN-09), está suspensa (RN-07b), inativa (RN-22), ou descredenciada da atividade (RN-07e), é pulada. AUDIT_LOG mostra o motivo. Veja §4.2 (algoritmo).

**Q2: Empresa cumpriu suspensão por strikes. Por que ela voltou para a posição 3 e não para o fim da fila?**
R: Por RN-18 — suspensão já foi a penalização. Empresa preserva sua posição original ao retornar. Punir duas vezes (suspender E perder turno) seria contestável legalmente. Veja CS-16.

**Q3: Posso editar AUDIT_LOG?**
R: Tecnicamente sim (a aba não tem proteção forte), mas isso viola RN-30 e invalida a auditoria. Em produção real, considere proteger por senha. No SaaS futuro, será impossível.

**Q4: O que acontece se eu apertar Expirar Pré-OS duas vezes?**
R: A primeira funciona (Pré-OS → EXPIRADA, fila avança). A segunda falha com `STATUS_INVALIDO` — proteção idempotente. Nenhum efeito colateral adicional. Veja CS-29.

**Q5: A empresa recusou. Por que ela ainda aparece na fila?**
R: Recusa avança a empresa para o FIM da fila (RN-10). Ela permanece credenciada e ainda pode receber Pré-OS depois das outras. Só sai da fila se: inativada, suspensa, ou descredenciada.

**Q6: Como sei se o sistema está com bug ou estou operando errado?**
R: §12.4 lista mensagens esperadas vs. bugs reais. Em dúvida, abra ticket com evidência mínima (§12.3).

**Q7: Posso rodar a bateria de teste em ambiente de produção?**
R: NÃO. A bateria popula dados de teste. Use sempre cópia de homologação. Veja §5.2.

**Q8: O CSV de evidência tem dados sensíveis?**
R: Em homologação, não (são dados fictícios). Em produção, sim — trate com mesmo cuidado de qualquer relatório administrativo.

**Q9: Onde fica o histórico de execuções?**
R: Em `auditoria_execucao/` (pasta configurável em CONFIG_TESTES). Política de retenção default = 90 dias.

**Q10: Posso integrar com Jira/email/Slack para receber alertas?**
R: Não na versão planilha. Sim no SaaS futuro (roadmap).

---

## APÊNDICES

### Apêndice A — Checklist completo de execução

(Tabela com 23 cenários herdados V202 + 18 novos V3 — total 41. Coluna Obrigatório?, Status, Observações.)

| ID | Cenário | Obrigatório? | Origem |
|---|---|---|---|
| CS-00 | Setup canônico (5 empresas) | Sim | V202 atualizado |
| CS-01 | Rejeita serviço duplicado | Sim | V202 |
| CS-02 | Rejeita serviço sem atividade | Sim | V202 |
| CS-03 | Primeira emissão vai para A | Sim | V202 |
| CS-04 | Aceite gera OS, A vai pro fim | Sim | V202 |
| CS-05 | Segunda pula A (OS aberta) | Sim | V202 |
| CS-06 | Terceira pula A e B (Pré-OS) | Sim | V202 |
| CS-07 | Bloqueio total sem trava | Sim | V202 |
| CS-08 | Retomada após OS concluída | Sim | V202 |
| CS-09 | Retomada após RECUSA | Não | V202 |
| CS-10 | Retomada após EXPIRAÇÃO | Não | V202 |
| CS-11 | Suspensão manual de A | Sim | V202 |
| CS-12 | Reativação manual de A | Não | V202 |
| CS-13 | Reativação automática | Sim | V202 |
| CS-14 | Strike 1 de 3 | Sim | V202 |
| CS-15 | 3 strikes suspende 90d | Sim | V202 |
| CS-16 | Retorno ordenado | Sim | V202 |
| CS-17 | Loop A→B→C→D→E (11 emissões) | Sim | V202 atualizado |
| CS-18 | Todas suspensas, bloqueio | Não | V202 |
| CS-19 | Reabilitação em cadeia | Não | V202 |
| CS-20 | Empresa inativa é pulada | Sim | V202 |
| CS-21 | Descredenciamento por atividade | Não | V202 |
| CS-22 | ATIV_ID consistente em N emissões | Sim | V202 |
| CS-23 | Rejeita CNPJ inválido (dígitos) | Sim | V3 |
| CS-24 | Rejeita CNPJ duplicado normalizado | Sim | V3 |
| CS-25 | Verificador de integridade ref. | Sim | V3 |
| CS-26 | Expirar Pré-OS efeitos | Sim | V3 |
| CS-27 | Rejeitar Pré-OS efeitos | Sim | V3 |
| CS-28 | Equivalência Expira↔Rejeita | Sim | V3 |
| CS-29 | Idempotência protetiva | Não | V3 |
| CS-30 | 2 inabilitadas, 3 operacionais | Sim | V3 |
| CS-31 | Inabilitação em ciclo ativo | Não | V3 |
| CS-32 | Determinismo do rodízio | Sim | V3 |
| CS-33 | Idempotência POP_CenarioCanonico | Sim | V3 |
| CS-34 | Pasta de auditoria completa | Sim | V3 |
| CS-35–40 | Pairwise (6 cenários iniciais) | Sim (após geração) | V3 |

### Apêndice B — Template de bug report

(Herdado do guia V202 §B — sem mudanças.)

### Apêndice C — Mapa de variáveis de domínio (combinatória)

(§0.3 expandida com tabela cartesiana — gerada na sprint 7.)

### Apêndice D — Matriz pairwise

(A ser gerada automaticamente por PICT na sprint 7 e adicionada aqui.)

### Apêndice E — Nomenclatura PDF resgatada

(Conteúdo do §8.2 + referências [ESPEC_PDF_AUTOMATICO_V205.md](docs/reference/testes/ESPEC_PDF_AUTOMATICO_V205.md) e [35_SPEC_DT5_PDFs_V12_0204.md](auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md))

### Apêndice F — 12 Exercícios de Configuração da Planilha (PENDENTE)

> **Status:** conteúdo não obtido — Notion não retornou conteúdo via WebFetch (provavelmente render JS).
>
> **URL referência:** https://bumpy-rifle-d9c.notion.site/12-Exerc-cios-Teste-de-Configura-o-da-Planilha-124e8747bbd580f48e9bf158176308dd
>
> **Próximo passo (B11.7):** gestor cola o conteúdo no próximo turn ou exporta a página para PDF. Cada exercício será mapeado para um CS-XX (sequência CS-50 a CS-61) e adicionado ao checklist do Apêndice A. Esses 12 exercícios serão **obrigatórios na certificação** do município adotante.

### Apêndice G — FAQ vivo (link)

URL: `https://github.com/<org>/<repo>/blob/main/docs/reference/testes/FAQ.md` (placeholder até publicação).

### Apêndice H — Roadmap Onda QA-V3 (sprints)

| Sprint | Tema | Esforço |
|---|---|---|
| QA-V3.1 | Fundação Engine V3 | 3-4 dias |
| QA-V3.2 | Populadores idempotentes | 2-3 dias |
| QA-V3.3 | DSL de Receitas | 3-4 dias |
| QA-V3.4 | Util_PDF + Pasta de Auditoria | 8-12 dias |
| QA-V3.5 | Modo Tutorial (MVP em paralelo) | 13 dias |
| QA-V3.6 | Menu V3 hierárquico | 2 dias |
| QA-V3.7 | Cobertura combinatória pairwise | 5-7 dias |
| QA-V3.8 | RN-23 (CNPJ) + RN-24 (Integridade) + cenários CS-23/24/25 | 4-6 dias |
| QA-V3.9 | Determinismo (CS-32) + Idempotência (CS-33) | 2 dias |
| QA-V3.10 | Fechamento, documentação, publicação | 3-4 dias |
| **TOTAL** | | **~50 dias úteis IA (com hearback)** |

Ondas futuras (após V3 estabilizada e antes de migrar para SaaS):
- **Onda QA-V4** — Mutation testing piloto (B11.10)
- **Onda QA-V5** — Property-based testing
- **Onda QA-V6** — Crash recovery e chaos engineering
- **Onda SaaS-1** — Tradução de regras de negócio para schema web

---

## CONTROLE DE VERSÃO DESTE DOCUMENTO

| Versão | Data | Autor | Mudança |
|---|---|---|---|
| 0.1 DRAFT | 2026-05-27 | Claude Opus 4.7 (1M ctx) | Redação inicial, baseada em anexo V202 + investigação código + decisões gestor (sessão 27/05) |
| 0.2 | (pendente) | Codex auditor + Antigravity Gemini 3.5 | Auditoria cruzada |
| 0.3 | (pendente) | Claude Opus 4.7 | Consolidação pós-auditoria |
| 1.0 | (pendente) | Gestor (hearback) | APROVADO para produção |

**Próximo passo:** auditoria cruzada (ver `PROMPT_AUDITORIA_CRUZADA.md` na mesma pasta).
