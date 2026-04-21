---
titulo: Proposta de Cenários V2 — Cenário Canônico (3 empresas, 1 atividade, 1 serviço)
natureza-do-documento: proposta de arquitetura de testes
escopo: suíte V2 (Teste_V2_Engine + Teste_V2_Roteiros)
versao-proposta: 1.0
versao-sistema: V12.0.0202
linha-de-implementacao: V12.0.0203
data: 2026-04-21
autoria: Arquitetura de testes — Claude Opus 4.7 a pedido de Luís Maurício Junqueira Zanin
destino: revisão e aprovação antes da conversão em código V2
---

# Proposta de Cenários V2 — Cenário Canônico

> Este documento **não é código**. É a especificação funcional e operacional
> dos cenários que devem ser implementados como **roteiros V2** na suíte
> `Teste_V2_Roteiros` sobre o motor `Teste_V2_Engine`, contra os serviços
> `Svc_Rodizio`, `Svc_PreOS`, `Svc_OS` e `Svc_Avaliacao` já validados na
> baseline V12.0.0202.

## 1. Leitura do cenário

O sistema precisa provar, de forma determinística e auditável, que, dada uma
configuração canônica mínima — **uma entidade demandante, uma atividade
nova, um serviço novo vinculado a essa atividade e três empresas recém-
credenciadas (A, B, C)** — o rodízio:

1. distribui Pré-OS e OS entre A, B e C na ordem da fila, sem privilegiar
   nenhuma;
2. pula corretamente empresas que estão **inativas no cadastro**,
   **suspensas (manual ou por nota)**, **com OS aberta na atividade** ou
   **com Pré-OS pendente**;
3. retoma cada empresa ao seu lugar na fila assim que o bloqueio cessa
   (conclusão de OS, fim de suspensão, recusa/expiração de Pré-OS);
4. quando **nenhuma** empresa está apta, responde com um motivo
   identificável e **não trava** o fluxo operacional;
5. ao chegar ao final da fila, **dá a volta** e continua distribuindo sem
   travamento nem duplicação;
6. mantém o catálogo consistente: **um CNAE/serviço único**, vinculado à
   **atividade correta**, sem duplicidade de cadastro e sem associação a
   atividade inexistente.

O cenário canônico é intencionalmente mínimo — três empresas são o menor
número que permite observar *simultaneamente* comportamento de cabeça da
fila, meio e cauda, bem como o retorno ao início.

## 2. Matriz de estados

A matriz a seguir é o **dicionário de estados** que os roteiros V2 devem
respeitar. Cada linha corresponde a uma empresa em um instante discreto.
Os roteiros operam sobre combinações desses estados; não sobre estados
implícitos.

| Dimensão | Valores possíveis | Origem |
|---|---|---|
| Estado cadastral da empresa | `ATIVA`, `INATIVA` | `EMPRESA.STATUS_GLOBAL` |
| Estado de suspensão global | `SUSPENSA_GLOBAL` (com `DT_FIM_SUSPENSAO`), `—` | `EMPRESA.STATUS_GLOBAL` + `DT_FIM_SUSPENSAO` |
| Motivo da suspensão | `MANUAL`, `NOTA_BAIXA`, `—` | `EMPRESA.MOTIVO_SUSPENSAO` |
| Estado do credenciamento no item | `ATIVO`, `INATIVO` | `CREDENCIAMENTO.STATUS_CRED` |
| Posição na fila do item | inteiro ≥ 1 | `CREDENCIAMENTO.POSICAO_FILA` |
| Pendência operacional no item | `SEM`, `PRE_OS_PENDENTE`, `OS_ABERTA` | composto de `PRE_OS` e `OS` |
| Última indicação | timestamp ou `—` | `CREDENCIAMENTO.DT_ULTIMA_IND` |

### 2.1 Estados canônicos de A, B, C no instante inicial (CS-00 concluído)

| Empresa | Cadastral | Suspensão global | Cred. no item | Posição | Pendência | Última ind. |
|---------|-----------|------------------|---------------|---------|-----------|-------------|
| EMP_A   | ATIVA     | —                | ATIVO         | 1       | SEM       | —           |
| EMP_B   | ATIVA     | —                | ATIVO         | 2       | SEM       | —           |
| EMP_C   | ATIVA     | —                | ATIVO         | 3       | SEM       | —           |

### 2.2 Ações do operador previstas nos roteiros

`EmitirPreOS`, `AceitarPreOS`, `RecusarPreOS`, `ExpirarPreOS`, `EmitirOS`,
`ConcluirOS`, `RegistrarAvaliacao`, `SuspenderEmpresa (manual)`,
`ReativarEmpresa (manual)`, `InativarEmpresa`, `ReativarEmpresaGlobal`,
`AvancarFila` (exposto apenas para testes determinísticos).

### 2.3 Saídas esperadas (assertions)

Cada cenário V2 aceita apenas **assertions explícitas**:

- `empresa_selecionada == EMP_X` em `SelecionarEmpresa`;
- `PRE_OS.EMP_ID == EMP_X` + `PRE_OS.STATUS == AGUARDANDO_ACEITE`;
- `OS.EMP_ID == EMP_X` + `OS.STATUS == ABERTA` ou `CONCLUIDA`;
- `CREDENCIAMENTO.POSICAO_FILA` após `AvancarFila`;
- `resultado.Sucesso == False` + `resultado.Motivo == MOTIVO_*`;
- `Audit_Log` contém evento `{tipo, entidade_afetada, identidade}` esperado.

## 3. Decomposição em blocos de cenários

A proposta agrupa cenários em **sete blocos**. Cada bloco é independente no
diagnóstico; os blocos posteriores **reaproveitam setup** dos anteriores
(pré-condição), mas não dependem de efeitos colaterais escondidos.

- **Bloco 0 — Setup estrutural.** Cria catálogo canônico (atividade,
  serviço, entidade, empresas) e prova unicidade e vínculo correto.
- **Bloco 1 — Fluxo nominal.** Distribui Pré-OS e OS para A, B, C na ordem
  da fila, sem bloqueios.
- **Bloco 2 — Bloqueio total por pendências.** Todas as empresas com OS
  aberta ou Pré-OS pendente; sistema responde com motivo sem travar.
- **Bloco 3 — Retomada parcial.** Uma pendência é resolvida; fila retoma
  exatamente do ponto certo.
- **Bloco 4 — Suspensão manual e reabilitação.** Suspensão operada por
  operador; reabilitação explícita; preservação de posição na fila.
- **Bloco 5 — Suspensão por nota e retorno ordenado.** Avaliação abaixo da
  média produz suspensão automática; fim do prazo reabilita sem perda de
  turno.
- **Bloco 6 — Loop e ciclo.** Sequência longa de emissões prova que a
  fila dá a volta sem travar.
- **Bloco 7 — Catálogo e integridade.** Unicidade de CNAE/serviço,
  rejeição de vínculo inválido, comportamento com empresa inativa.

## 4. Catálogo de cenários propostos

> IDs no padrão `CS-NN`. Todos os cenários são **roteiros V2** em
> `Teste_V2_Roteiros`; usam o motor de asserção de `Teste_V2_Engine`;
> gravam evidência em `BateriaOficial_*.csv` com ID explícito.

### Bloco 0 — Setup estrutural

**CS-00 — Setup canônico.**
Pré-condição: base limpa (Preparação V2 zera planilhas operacionais).
Ação: cadastrar `AT_CANON_001` (atividade nova), `SV_CANON_001` (serviço
novo vinculado a `AT_CANON_001`), `ENT_CANON_001` (entidade), `EMP_A`,
`EMP_B`, `EMP_C` (empresas novas); credenciar A, B, C em `AT_CANON_001`
com posições 1, 2, 3.
Resultado esperado: todos os IDs gerados sem colisão; estados conforme
tabela 2.1; `Audit_Log` registra 1 `CADASTRO` por entidade.
Razão: este é o chão comum de todos os outros cenários; sua falha invalida
toda a suíte seguinte.

**CS-01 — Unicidade de CNAE/serviço.**
Pré-condição: CS-00 concluído.
Ação: tentar cadastrar `SV_CANON_001` novamente com os mesmos campos
canônicos.
Resultado esperado: `Sucesso = False`; `Motivo = DUPLICIDADE_SERVICO`;
nenhum novo registro em `Cadastro_Servico`; `Audit_Log` registra tentativa
com `tipo = VALIDACAO_REJEITADA`.
Razão: confirma que o catálogo não aceita duplicidade e que a rejeição é
auditada.

**CS-02 — Rejeição de vínculo inválido.**
Pré-condição: CS-00 concluído.
Ação: tentar cadastrar um serviço `SV_X` apontando para atividade
inexistente `AT_INEXISTENTE`.
Resultado esperado: `Sucesso = False`; `Motivo = VINCULO_INVALIDO`; sem
alteração em tabelas; evento `VALIDACAO_REJEITADA`.
Razão: impede catalogação inconsistente entre atividade e serviço.

### Bloco 1 — Fluxo nominal

**CS-03 — Emissão nominal 1 → A.**
Pré-condição: CS-00.
Ação: `EmitirPreOS(ENT_CANON_001, "AT_CANON_001|SV_CANON_001")`.
Resultado esperado: `PRE_OS_1` criada para `EMP_A`;
`PRE_OS.STATUS = AGUARDANDO_ACEITE`; `DT_ULTIMA_IND` de A atualizado;
`CREDENCIAMENTO` de A inalterado em posição (ainda 1).
Razão: estabelece o primeiro elo da fila nominal.

**CS-04 — Aceite e conversão em OS.**
Pré-condição: CS-03.
Ação: `AceitarPreOS(PRE_OS_1)` → `EmitirOS(PRE_OS_1)`.
Resultado esperado: `OS_1` criada para `EMP_A`; `OS.STATUS = ABERTA`;
`PRE_OS.STATUS = CONVERTIDA_OS`; `AvancarFila` chamado; posição de A
movida para o final (POSICAO_FILA = 3), B passa a 1 e C a 2.
Razão: garante que a ordem de fila avança conforme a regra 26 e reflete
OS emitida.

**CS-05 — Emissão nominal 2 → B.**
Pré-condição: CS-04.
Ação: `EmitirPreOS` novamente.
Resultado esperado: `PRE_OS_2` para `EMP_B`; `EMP_A` é **pulada** pelo
rodízio (tem `OS_1` aberta).
Razão: prova que OS aberta bloqueia indicação na mesma atividade e que o
rodízio não punição/reordena ao pular.

**CS-06 — Emissão nominal 3 → C.**
Pré-condição: CS-05, sem concluir OS de A nem aceitar Pré-OS de B.
Ação: `EmitirPreOS`.
Resultado esperado: `PRE_OS_3` para `EMP_C`; `EMP_A` é pulada por OS
aberta; `EMP_B` é pulada por **Pré-OS pendente**.
Razão: prova que Pré-OS pendente também bloqueia indicação.

### Bloco 2 — Bloqueio total por pendências

**CS-07 — Bloqueio total.**
Pré-condição: CS-06. A com OS aberta, B com Pré-OS pendente, C com Pré-OS
pendente.
Ação: `EmitirPreOS`.
Resultado esperado: `Sucesso = False`;
`Motivo = SEM_CREDENCIADOS_APTOS`; nenhuma Pré-OS criada; fila preservada;
`Audit_Log` registra evento `RODIZIO_BLOQUEADO` com
`entidade_afetada = ATIVIDADE`.
Razão: é o teste mais importante da suíte. Se este falhar, o sistema
trava em produção.

### Bloco 3 — Retomada parcial

**CS-08 — Retomada após conclusão de OS.**
Pré-condição: CS-07.
Ação: `ConcluirOS(OS_1_A)` com avaliação neutra (nota ≥ média);
`EmitirPreOS`.
Resultado esperado: `OS_1` → `CONCLUIDA`; A deixa de ter pendência;
`PRE_OS_4` emitida; a empresa escolhida deve ser **A** (cauda da fila
devolveu A para o topo após AvancarFila em CS-04).
Razão: prova que conclusão libera a empresa correta e que a fila mantém a
rotação.

**CS-09 — Retomada após recusa de Pré-OS.**
Pré-condição: CS-06 (B com Pré-OS pendente, C com Pré-OS pendente, A livre).
Ação: `RecusarPreOS(PRE_OS_2)` (B recusa); `EmitirPreOS`.
Resultado esperado: `PRE_OS_2` → `RECUSADA`; `AvancarFila` chamado para
B **antes** da nova emissão; nova indicação vai para A (se livre) ou
próxima apta por posição.
Razão: prova a política de `RecusarPreOS`: avanço de fila é pré-condição
da recusa (bloqueante conforme comentário em `Svc_PreOS`).

**CS-10 — Retomada após expiração de Pré-OS.**
Pré-condição: variação do CS-09 com C tendo Pré-OS expirada em vez de
recusada.
Ação: `ExpirarPreOS(PRE_OS_3)`; `EmitirPreOS`.
Resultado esperado: similar a CS-09, com `PRE_OS.STATUS = EXPIRADA` e
evento `RODIZIO_EXPIROU`.
Razão: prova simetria entre recusa e expiração.

### Bloco 4 — Suspensão manual e reabilitação

**CS-11 — Suspensão manual global de A.**
Pré-condição: CS-00 reexecutado (base canônica limpa); sem OS/Pré-OS.
Ação: `SuspenderEmpresa(EMP_A, motivo = "MANUAL", dt_fim = Hoje + 7)`;
`EmitirPreOS`.
Resultado esperado: A pulada; B escolhida (posição 2 vira topo da apta).
A **não** perde posição absoluta (POSICAO_FILA ainda = 1), mas não é
escolhida enquanto `STATUS_GLOBAL = SUSPENSA_GLOBAL` e `DT_FIM_SUSPENSAO > Hoje`.
Razão: separa conceito de *posição* (imutável sem motivo) do conceito de
*aptidão* (filtrada por estado).

**CS-12 — Reabilitação manual explícita.**
Pré-condição: CS-11.
Ação: `ReativarEmpresaGlobal(EMP_A)`; `EmitirPreOS`.
Resultado esperado: A volta ao estado apto e, como ainda é posição 1, é
a próxima indicação — desde que B e C não tenham Pré-OS/OS aberta.
Razão: valida a reabilitação sem perda de turno.

**CS-13 — Reativação automática por DT_FIM_SUSPENSAO.**
Pré-condição: base canônica limpa.
Ação: `SuspenderEmpresa(EMP_A, motivo = "MANUAL", dt_fim = Hoje - 1)`
(prazo já expirado); `EmitirPreOS`.
Resultado esperado: dentro do próprio `SelecionarEmpresa`, A é
**reativada automaticamente** (comportamento documentado em `Svc_Rodizio`,
passo 2.b); A vira apta e é escolhida.
Razão: valida o caminho automático de reativação por vencimento.

### Bloco 5 — Suspensão por nota e retorno ordenado

**CS-14 — Avaliação abaixo da média gera suspensão por nota.**
Pré-condição: CS-08 concluído (OS_1_A concluída com nota neutra). Agora,
emitir e concluir OS para B com nota baixa.
Ação: `EmitirPreOS` → Aceite → `EmitirOS` para B → `ConcluirOS(OS_B, nota = 3)`;
regra interna: média configurada = 7.
Resultado esperado: B recebe `STATUS_GLOBAL = SUSPENSA_GLOBAL`,
`MOTIVO_SUSPENSAO = NOTA_BAIXA`, `DT_FIM_SUSPENSAO = Hoje + janela_configurada`;
`Audit_Log` registra `SUSPENSAO_POR_NOTA`.
Razão: prova o laço entre avaliação e suspensão automática.

**CS-15 — B é pulada enquanto suspensa por nota.**
Pré-condição: CS-14.
Ação: `EmitirPreOS`.
Resultado esperado: B pulada; A ou C indicada conforme fila.
Razão: garante que a suspensão por nota é equivalente, em efeito, à
suspensão manual durante sua vigência.

**CS-16 — Retorno ordenado após fim da suspensão por nota.**
Pré-condição: CS-15; avançar relógio lógico (ou forçar
`DT_FIM_SUSPENSAO = Hoje - 1`).
Ação: `EmitirPreOS`.
Resultado esperado: B reativada automaticamente; **volta à sua posição
original** na fila (não reentra como último), desde que sua `POSICAO_FILA`
não tenha sido alterada por `AvancarFila` no período.
Razão: previne regra injusta de "perder turno" por um evento que já foi
penalizado (a nota baixa já penalizou B por N dias; não deve penalizar
duas vezes).

### Bloco 6 — Loop e ciclo (estresse determinístico)

**CS-17 — Loop de 7 emissões consecutivas.**
Pré-condição: base canônica limpa; nenhuma pendência.
Ação: executar 7 ciclos completos `EmitirPreOS → Aceitar → EmitirOS →
ConcluirOS (nota média)`.
Resultado esperado: sequência das empresas escolhidas segue a rotação
`A → B → C → A → B → C → A`; nenhuma emissão retorna
`SEM_CREDENCIADOS_APTOS`; `AvancarFila` executado 7 vezes sem erro; sem
travamento ao "virar a volta" na 4ª emissão.
Razão: este é o teste de vida do rodízio. Prova que a fila é circular e
não linear.

**CS-18 — Todas suspensas simultâneas (cenário extremo).**
Pré-condição: base canônica limpa.
Ação: suspender A, B, C manualmente; `EmitirPreOS`.
Resultado esperado: `Sucesso = False`; `Motivo = SEM_CREDENCIADOS_APTOS`;
fila preservada; sem exceção não tratada.
Razão: garante que a combinação limite também é tratada sem trava.

**CS-19 — Reabilitação em cadeia preserva ordem original.**
Pré-condição: CS-18.
Ação: reativar A; emitir. Reativar B; emitir. Reativar C; emitir.
Resultado esperado: primeira emissão vai para A (posição 1); segunda vai
para B (posição 2) — note que A tem OS aberta, então B é apta por ser a
próxima por posição; terceira vai para C.
Razão: prova que posição absoluta sobrevive a períodos inteiros de
suspensão e que a ordem canônica é restaurada assim que os bloqueios
saem.

### Bloco 7 — Catálogo e integridade (complementares)

**CS-20 — Empresa inativa no cadastro.**
Pré-condição: base canônica limpa.
Ação: `InativarEmpresa(EMP_A)`; `EmitirPreOS`.
Resultado esperado: A pulada (`STATUS_GLOBAL = INATIVA`, passo 2.a do
algoritmo); B é escolhida.
Razão: prova que inatividade cadastral é terminal até `ReativarEmpresa`.

**CS-21 — Descredenciamento de empresa no item.**
Pré-condição: base canônica limpa.
Ação: marcar `CREDENCIAMENTO` de A com `STATUS_CRED = INATIVO` no item
`AT_CANON_001`; `EmitirPreOS`.
Resultado esperado: A pulada por `STATUS_CRED <> ATIVO`; B escolhida;
nenhuma alteração nos demais credenciamentos de A em outras atividades
(se existirem).
Razão: isola o efeito do descredenciamento por atividade do estado global.

**CS-22 — Associação da atividade preservada em múltiplas emissões.**
Pré-condição: CS-00.
Ação: emitir 3 Pré-OS seguidas com `COD_SERVICO = "AT_CANON_001|SV_CANON_001"`.
Resultado esperado: nenhum registro com `ATIV_ID` diferente de
`AT_CANON_001`; nenhum `SERV_ID` fora de `SV_CANON_001`; `Audit_Log` mostra
`ATIV_ID` idêntico em todas as indicações.
Razão: defensiva contra regressão histórica (V12.0.0193 já mostrou como
um recorte CNAE/CAD_SERV podia regredir o fluxo).

## 5. Cobertura combinatória mínima

### 5.1 Obrigatórios (núcleo da suíte)

Todos os cenários de **Bloco 0** (CS-00, CS-01, CS-02), **Bloco 1**
(CS-03, CS-04, CS-05, CS-06), **Bloco 2** (CS-07), **Bloco 3** (CS-08),
**Bloco 6** (CS-17), mais **CS-11, CS-13, CS-14, CS-16, CS-20, CS-22**.
Total: 16 cenários obrigatórios. Este conjunto cobre:

- unicidade e vínculo;
- ordem de fila nominal;
- bloqueio total (trava);
- retomada por conclusão;
- suspensão manual com prazo vigente;
- reativação automática por vencimento;
- suspensão por nota + retorno ordenado;
- loop (volta da fila);
- inatividade cadastral;
- associação correta de atividade.

### 5.2 Complementares (recomendados, não bloqueantes)

CS-09, CS-10, CS-12, CS-15, CS-18, CS-19, CS-21. Estes reforçam o núcleo
e melhoram o sinal diagnóstico, mas cada um tem equivalente parcial no
conjunto obrigatório.

### 5.3 Descartados por redundância (não implementar)

- Combinações de **dois motivos diferentes** de bloqueio simultâneo em uma
  mesma empresa (por exemplo, OS aberta **e** suspensão manual):
  o rodízio pula pelo primeiro critério satisfeito; provar o pulo por cada
  critério separadamente é suficiente.
- **Suspensão por nota de duas empresas ao mesmo tempo**: CS-14 + CS-15
  cobrem o efeito; provar em duas empresas simultâneas não adiciona
  cobertura.
- **Três atividades diferentes com a mesma empresa**: o cenário canônico
  é de **um item**; multi-item é objeto de outro canônico.
- **Emissão com `COD_SERVICO` legado `AAASSS` vs. `ATIV_ID|SERV_ID`**:
  essa dualidade é problema de entrada, não de rodízio; cobrir em suíte de
  parser, não aqui.
- **Exaustão factorial de 3 empresas × 4 estados × 3 pendências**: teria
  36 linhas sem ganho sobre os 16 cenários obrigatórios.

## 6. Ordem recomendada de implementação

Estruturada em **quatro sprints curtos**, cada um entregando valor
publicável como evidência V2.

**Sprint 1 — Fundação (CS-00 a CS-06).**
Objetivo: *provar que a fila nominal funciona*.
Cenários: CS-00, CS-01, CS-02, CS-03, CS-04, CS-05, CS-06.
Evidência esperada: `BateriaOficial_*` verde; roteiro V2 cobrindo todas as
emissões nominais; `Audit_Log` com 6 eventos `RODIZIO_INDICOU`.
Critério de pronto: três Pré-OS seguidas emitidas corretamente para A, B,
C em base nova.

**Sprint 2 — Bloqueios e retomada (CS-07, CS-08, CS-22).**
Objetivo: *provar que o sistema não trava e retoma corretamente*.
Cenários: CS-07, CS-08, CS-22 (associação preservada).
Critério de pronto: CS-07 retorna `SEM_CREDENCIADOS_APTOS` sem exceção;
CS-08 escolhe A na próxima emissão.

**Sprint 3 — Suspensões (CS-11, CS-13, CS-14, CS-16, CS-20).**
Objetivo: *provar o ciclo completo de suspensão e retorno*.
Cenários: CS-11, CS-13, CS-14, CS-16, CS-20.
Critério de pronto: suspensão por nota + retorno ordenado produz a
sequência `A → B (nota baixa) → C → A → B (após retorno) → C` em teste
determinístico.

**Sprint 4 — Loop e complementares (CS-17 + opcionais).**
Objetivo: *provar ausência de travamento em uso prolongado*.
Cenários: CS-17 obrigatório; CS-09, CS-10, CS-12, CS-15, CS-18, CS-19,
CS-21 conforme capacidade do sprint.
Critério de pronto: CS-17 executa 7 ciclos sem erro; sequência
`A B C A B C A` registrada em CSV.

Essa ordem foi desenhada para que, em **cada sprint**, a suíte V2 já
possa ser rodada de ponta a ponta, com os cenários implementados até
então, e produza um **CSV assinável** da bateria. Não há dependência
escondida entre sprints.

## 7. Critérios de aceite

A suíte V2, após absorver esta proposta, será considerada **forte o
bastante** quando todos os itens a seguir forem verdadeiros em uma mesma
execução:

1. **Cobertura mínima.** Todos os 16 cenários obrigatórios passam em
   `Teste_V2_Engine` com asserção verde e evidência textual em
   `BateriaOficial_*.csv`.
2. **Determinismo.** Duas execuções consecutivas da suíte, com o mesmo
   seed e a mesma base canônica, produzem a **mesma sequência** de
   empresas escolhidas. Divergência = falha.
3. **Ausência de travamento.** Nenhum cenário retorna erro não tratado
   (`Err.Raise` fora do caminho esperado); o cenário CS-07 retorna
   `Sucesso = False` com motivo explícito; o cenário CS-17 completa 7
   emissões sem quebra.
4. **Auditoria íntegra.** Toda ação com efeito de estado gera evento em
   `Audit_Log` com identidade (empresa, atividade, OS/Pré-OS), tipo
   (`RODIZIO_INDICOU`, `RODIZIO_BLOQUEADO`, `SUSPENSAO_*`, `OS_EMITIDA`,
   `OS_CONCLUIDA`, `AVALIACAO_REGISTRADA`) e carimbo temporal.
5. **Não regressão.** A execução da suíte V2 antes da bateria oficial
   deixa a bateria oficial verde; isso prova que V2 não polui o estado do
   workbook de forma irreversível.
6. **Integridade de catálogo.** CS-01 e CS-02 rejeitam duplicidade e
   vínculo inválido com motivos explícitos; CS-22 prova que a atividade
   vinculada permanece consistente em múltiplas emissões.
7. **Evidência assinável.** Ao final da execução, a suíte grava um
   `MANIFEST.md` em `auditoria/evidencias/V12.xx/` listando nome do
   cenário, timestamp, hash do CSV gerado e status (`OK` ou `FALHA`);
   ausência de `MANIFEST.md` após execução é considerada falha
   automática.
8. **Retomada ordenada comprovada.** CS-16 prova que uma empresa suspensa
   por nota **não perde turno** ao retornar — se a posição absoluta
   mudar entre CS-14 e CS-16 sem AvancarFila explícito, a suíte falha.

## Apêndice — Dicionário rápido de IDs

| ID | Nome curto | Bloco | Obrigatório |
|----|------------|-------|-------------|
| CS-00 | Setup canônico | 0 | Sim |
| CS-01 | Unicidade de CNAE/serviço | 0 | Sim |
| CS-02 | Rejeição de vínculo inválido | 0 | Sim |
| CS-03 | Emissão nominal 1 → A | 1 | Sim |
| CS-04 | Aceite e conversão em OS | 1 | Sim |
| CS-05 | Emissão nominal 2 → B (pula A) | 1 | Sim |
| CS-06 | Emissão nominal 3 → C (pula A e B) | 1 | Sim |
| CS-07 | Bloqueio total | 2 | Sim |
| CS-08 | Retomada após conclusão de OS | 3 | Sim |
| CS-09 | Retomada após recusa | 3 | Não |
| CS-10 | Retomada após expiração | 3 | Não |
| CS-11 | Suspensão manual global | 4 | Sim |
| CS-12 | Reabilitação manual | 4 | Não |
| CS-13 | Reativação automática | 4 | Sim |
| CS-14 | Suspensão por nota baixa | 5 | Sim |
| CS-15 | Pulo de empresa suspensa por nota | 5 | Não |
| CS-16 | Retorno ordenado após nota | 5 | Sim |
| CS-17 | Loop de 7 emissões | 6 | Sim |
| CS-18 | Todas suspensas simultâneas | 6 | Não |
| CS-19 | Reabilitação em cadeia | 6 | Não |
| CS-20 | Empresa inativa | 7 | Sim |
| CS-21 | Descredenciamento no item | 7 | Não |
| CS-22 | Associação preservada em múltiplas emissões | 7 | Sim |

Obrigatórios: 16. Complementares: 6. Descartados por redundância:
enumerados em 5.3.
