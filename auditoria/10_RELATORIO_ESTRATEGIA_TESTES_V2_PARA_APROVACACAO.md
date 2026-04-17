# RELATÓRIO DE APROVAÇÃO
## Estratégia Definitiva de Evolução dos Testes V2

**Data:** 2026-04-17  
**Status:** Proposta para aprovação  
**Escopo:** estabilização, centralização dos testes, migração de validações da interface para serviços, expansão da cobertura combinatória, estratégia híbrida de execução e plano de substituição das baterias atuais

---

## 1. Objetivo

Definir uma solução de testes robusta, desacoplada e progressivamente substitutiva para o sistema V12, com foco em:

1. elevar a confiabilidade dos testes para um nível compatível com estabilização pesada;
2. migrar regras de negócio hoje espalhadas na interface para a camada de serviços;
3. transformar a análise combinatória em cobertura operacional real;
4. criar um módulo de testes novo, independente e integrável sem colisão com as microevoluções em andamento;
5. prever execução rápida, execução assistida com feedback visual e execução de stress;
6. só retirar a bateria atual depois de um período de convivência e comparação controlada.

---

## 2. Fontes analisadas

### Auditoria

- `auditoria/00_SUMARIO_EXECUTIVO.md`
- `auditoria/02_AUDITORIA_INTERFACE_DETERMINISTICA.md`
- `auditoria/04_MATRIZ_MESTRE_DE_TESTES.md`
- `auditoria/05_AUDITORIA_COMBINATORIA_DE_COBERTURA.md`
- `auditoria/07_PADRONIZACAO_DO_TREINAMENTO_E_EXECUCAO_ASSISTIDA.md`
- `auditoria/08_PLANO_DE_MICRODESENVOLVIMENTO_ANTI_REGRESSAO.md`
- `auditoria/09_LACUNAS_ASSUNCOES_RISCOS_E_PRIORIDADES.md`

### Roadmap e governança

- `obsidian-vault/arquitetura/Roadmap-Estabilizacao-V12.md`
- `obsidian-vault/arquitetura/Mapa-Dependencias.md`
- `obsidian-vault/regras/Anti-Regressao.md`
- `obsidian-vault/ai/PIPELINE.md`
- `obsidian-vault/ai/GOVERNANCA.md`
- `obsidian-vault/ai/ESTADO-ATUAL.md`

### Implementação atual

- `vba_export/Svc_Rodizio.bas`
- `vba_export/Svc_PreOS.bas`
- `vba_export/Svc_OS.bas`
- `vba_export/Svc_Avaliacao.bas`
- `vba_export/Repo_Credenciamento.bas`
- `vba_export/Repo_PreOS.bas`
- `vba_export/Repo_OS.bas`
- `vba_export/Repo_Avaliacao.bas`
- `vba_export/Menu_Principal.frm`
- `vba_export/Teste_Bateria_Oficial.bas`
- `vba_export/Central_Testes.bas`
- `vba_export/Central_Testes_Relatorio.bas`
- `vba_export/Teste_UI_Guiado.bas`

---

## 3. Conclusão executiva

### 3.1 Decisão recomendada

**Recomendo aprovar a criação do módulo de testes V2 em paralelo ao legado, sem substituição imediata.**

O caminho mais seguro não é tentar “consertar” incrementalmente a bateria atual até ela virar a solução definitiva. O caminho mais seguro é:

1. congelar a bateria atual como baseline comparativa;
2. criar um módulo V2 novo e desacoplado;
3. mover as validações críticas da interface para os serviços;
4. operar V1 e V2 em shadow mode por algumas releases;
5. só então tornar V2 o padrão e aposentar V1.

### 3.2 Tese central

Hoje o sistema tem **lógica de negócio razoavelmente estruturada no core**, mas a camada de testes ainda sofre com quatro problemas:

1. **fragmentação**: bateria oficial, central, UI guiado e treinamento convivem sem uma taxonomia única;
2. **documentação defasada**: parte da auditoria não reflete mais o código atual;
3. **validações distribuídas**: algumas regras estão na UI, outras no serviço, outras apenas nos repositórios;
4. **cobertura combinatória não operacionalizada**: o espaço de estados foi descrito, mas não foi transformado em geração sistemática de cenários.

### 3.3 Meta realista

Não é tecnicamente realista prometer cobertura exaustiva do espaço teórico de 25.920 combinações por clique real na interface do Excel.  
**É realista e recomendável buscar:**

- **100%** dos guard rails de serviço;
- **100%** dos estados inválidos críticos;
- **95%+** das classes de equivalência e combinações críticas;
- **100%** dos fluxos smoke principais;
- **stress reprodutível** com invariantes fortes;
- **fumaça visual assistida** para garantir que a interface continua operacional.

---

## 4. Achados principais

### 4.1 O material de auditoria é útil, mas não pode ser tratado como fonte única da verdade

Os documentos de auditoria ajudam muito a mapear risco e intenção, mas estão parcialmente defasados em relação ao código atual. O exemplo mais importante é a cobertura de filtros D e E:

- a auditoria combinatória ainda trata a classe D/E como parcialmente ausente;
- a bateria atual já possui casos dedicados para D, E, persistência e combinação D+E;
- ainda assim, os testes atuais não validam todas as invariantes estruturais da fila.

**Conclusão:** a documentação atual deve virar insumo de desenho, não contrato executável.

### 4.2 O maior gap não é “falta de teste”, e sim “falta de contrato unificado”

O problema central hoje é que o sistema mistura:

- validação de UI;
- validação de serviço;
- persistência em aba;
- auditoria;
- explicação humana do cenário;
- treino/roteiro/manual.

Sem um contrato comum, a cobertura vira difícil de medir.

### 4.3 A nova solução deve nascer em camada 6, não no core

O `Mapa-Dependencias` e o protocolo `Anti-Regressao` mostram que os módulos de teste são tratáveis como camada descartável e isolável. Isso favorece a criação de um conjunto novo de módulos `Teste_V2_*` sem tocar no fluxo produtivo agora.

### 4.4 A migração UI -> serviço é condição para estabilidade extrema

Enquanto parte das regras continuar apenas em `Menu_Principal.frm`, qualquer automação baseada em serviço continuará incompleta, e qualquer automação baseada em clique continuará frágil.

**Logo, a estratégia correta é:**

1. estabilizar contratos de serviço;
2. automatizar em cima deles;
3. usar a interface como camada de validação final, não como fonte primária das regras.

---

## 5. Matriz mestra de regra x implementação x cobertura x evolução

### 5.1 Leitura da matriz

Colunas:

- **Domínio**
- **Regra ou cenário**
- **Onde está implementado hoje**
- **Dependências validadas no serviço?**
- **Cobertura atual**
- **Risco/lacuna**
- **Evolução recomendada no V2**

| Domínio | Regra / cenário | Onde está implementado hoje | Dependências validadas no serviço? | Cobertura atual | Risco / lacuna | Evolução recomendada no V2 |
|---|---|---|---|---|---|---|
| Configuração | baseline estrutural e parâmetros mínimos | `Util_Config.bas` + bateria oficial | Parcial | Boa | falta contrato de configuração por ambiente | criar testes de contrato `CFG_*` e fixture canônica |
| Cadastro | inserção de empresa canônica | `Repo_Empresa.bas` + helpers da bateria | Parcial | Boa | falta validação semântica mais forte de duplicidade por serviço | separar smoke de cadastro e contratos de persistência |
| Cadastro | inserção de entidade canônica | helpers + planilha | Parcial | Boa | depende de setup correto da aba | criar cenário-padrão reutilizável e contrato por entidade |
| Credenciamento | credenciar empresa em todos os serviços da atividade | `Credencia_Empresa.frm` | Não, regra nasce no form | Média | regra de negócio importante fora do serviço | extrair `Svc_Credenciamento.CredenciarEmpresaNaAtividade` |
| Credenciamento | evitar duplicidade de credenciamento | form + helpers da bateria | Parcial | Boa | sem serviço único | migrar para serviço/repositório com retorno tipado |
| Fila | ordem inicial por atividade | `Repo_Credenciamento.bas` + form de credenciamento | Parcial | Boa | invariantes de fila não são checadas sempre | criar verificador de invariantes de fila por atividade |
| Rodízio | filtro A `STATUS_CRED <> ATIVO` | `Svc_Rodizio.bas` | Sim | Boa | precisa cobertura com combinações múltiplas | testes gerados por catálogo combinatório |
| Rodízio | filtro B suspensão + auto-reativação | `Svc_Rodizio.bas` | Sim | Boa, mas discutida | ainda há lacuna documental e de boundary | promover para suíte de contratos e cenários data-driven |
| Rodízio | filtro C empresa inativa | `Svc_Rodizio.bas` | Sim | Boa | precisa matriz com D/E e cross-atividade | incluir em pairwise crítico |
| Rodízio | filtro D OS aberta na atividade move fila | `Svc_Rodizio.bas` + `Repo_OS.bas` | Sim | Média/Boa | testes atuais focam seleção, não fila persistida | validar `POSICAO_FILA`, não só empresa retornada |
| Rodízio | filtro E Pre-OS pendente pula sem mover | `Svc_Rodizio.bas` + `Repo_PreOS.bas` | Sim | Média | falta asserção estrutural forte | validar invariantes de não-movimento e não-punição |
| Rodízio | indicação atualiza `DT_ULTIMA_IND` | `Svc_Rodizio.bas` | Parcial | Fraca | quase não testado explicitamente | criar contrato `RDZ_IND_*` |
| Rodízio | avanço de fila sem punição | `Svc_Rodizio.bas` | Sim | Boa | atomicidade baixa | envolver em teste de rollback e invariantes |
| Rodízio | avanço de fila com punição | `Svc_Rodizio.bas` + `Repo_Credenciamento.bas` | Sim | Boa | risco de escrita parcial entre abas | criar testes de consistência pós-falha e logging técnico |
| Rodízio | sincronização recusa local x global | `Repo_Credenciamento.bas` + `Repo_Empresa.bas` | Não, apenas executa | Média | risco crítico de atomicidade | criar validação pós-operação e telemetria de divergência |
| Pré-OS | parse de `COD_SERVICO` | `Svc_PreOS.bas` | Sim | Boa | precisa ampliar para formatos inválidos e legados | contratos `PRE_PARSE_*` |
| Pré-OS | entidade existente e coerente | UI + `Svc_PreOS.bas` | Não | Fraca | serviço aceita `ENT_ID` sem checar existência | mover validação para serviço |
| Pré-OS | quantidade estimada > 0 | UI + `Svc_PreOS.bas` | Não | Fraca | serviço aceita quantidade inválida e corrige só por interface | mover regra para serviço |
| Pré-OS | buscar `VALOR_UNIT` canônico | `Svc_PreOS.bas` | Sim | Boa | precedência documental ainda ambígua | formalizar contrato de origem do valor |
| Pré-OS | emissão em estado consistente | `Svc_PreOS.bas` | Parcial | Boa | se falhar na escrita, efeitos anteriores podem já existir | testes de falha/rollback e camada de operação segura |
| Pré-OS | recusar mantendo consistência | `Svc_PreOS.bas` | Parcial | Boa | avança fila antes de persistir status | criar operação transacional simulada / rollback compensatório |
| Pré-OS | expirar mantendo consistência | `Svc_PreOS.bas` | Parcial | Boa | mesmo problema de recusa | idem |
| OS | converter Pre-OS válida em OS | `Svc_OS.bas` | Sim | Boa | falta teste profundo de escrita parcial | testes de persistência cruzada Pre-OS/OS |
| OS | validar data prevista e empenho | UI + `Svc_OS.bas` | Não | Fraca | regra de entrada ainda na interface | mover guard rails para serviço |
| OS | cancelar OS | `Svc_OS.bas` + UI | Sim | Boa | precisa prova de não-avançar fila extra | manter contrato específico e stress de repetição |
| Avaliação | validar vetor 1..10 e notas 0..10 | `Svc_Avaliacao.bas` | Sim | Boa | bom nível atual | manter como contrato base |
| Avaliação | exigir justificativa em divergência | `Menu_Principal.frm` | Não | Média | regra de negócio ainda fora do serviço | migrar para `Svc_Avaliacao` |
| Avaliação | suspender por média abaixo do mínimo | `Svc_Avaliacao.bas` | Sim | Boa | precisa prova de causa na auditoria | incluir evento semântico de suspensão por avaliação |
| Auditoria | registrar eventos críticos | `Audit_Log.bas` + serviços | Parcial | Média | bateria atual não inspeciona log com profundidade | criar suíte `AUD_*` com leitura de eventos |
| Integridade | consistência entre abas após cada fluxo | helpers + relatórios | Parcial | Média | falta suíte de invariantes | módulo `Teste_V2_Invariantes.bas` |
| UI | filtros, botões, navegação | `Menu_Principal.frm` + `Teste_UI_Guiado.bas` | Não | Assistida, não automatizada | ainda heurística e checklist manual | UI adapter estável + smoke visual assistido |
| Testes | central unificada | `Central_Testes.bas` | Não | Média | menu legado misturado com várias eras | `Central_Testes_V2.bas` separado |
| Testes | explicação humana do cenário | bateria atual + treinamento | Parcial | Fraca | o humano entende pouco o porquê de cada caso | catálogo semântico de cenários |

### 5.2 Síntese da matriz

**Regras já fortes no serviço**

- filtros A, B, C, D, E;
- transições básicas de Pre-OS;
- transições básicas de OS;
- validação de notas;
- suspensão por média;
- suspensão por recusa.

**Regras ainda fracas porque estão na interface**

- seleção/validade de entidade para Pre-OS;
- quantidade estimada;
- data prevista de término da OS;
- necessidade de justificativa quando há divergência;
- parte da semântica de credenciamento.

**Regras fracas por falta de contrato de integridade**

- atomicidade do avanço de fila;
- sincronização de recusas local/global;
- consistência entre `PRE_OS`, `CAD_OS`, `CREDENCIADOS` e `EMPRESAS`;
- auditoria detalhada pós-operação.

---

## 6. Pontos de evolução possíveis

### 6.1 Alternativa 1 — Evolução incremental da bateria atual

**Descrição**

Continuar expandindo `Teste_Bateria_Oficial.bas`, `Central_Testes.bas` e `Teste_UI_Guiado.bas`.

**Vantagens**

- baixo custo inicial;
- reaproveita código já conhecido;
- menor curva de adoção.

**Desvantagens**

- mantém o acoplamento histórico;
- perpetua naming e responsabilidades confusas;
- dificulta separar modo rápido, assistido, combinatório e stress;
- aumenta a chance de regressão no próprio ambiente legado.

**Conclusão**

Útil só para correções curtas. **Não recomendo como estratégia definitiva.**

### 6.2 Alternativa 2 — Novo módulo V2 paralelo, com integração tardia

**Descrição**

Criar novos módulos de teste desacoplados, mantendo a bateria atual como baseline até a homologação do V2.

**Vantagens**

- melhor isolamento;
- reduz conflito com o Cursor;
- permite redesenhar arquitetura de testes corretamente;
- viabiliza shadow mode;
- facilita futura aposentadoria do legado.

**Desvantagens**

- exige disciplina de catalogação e naming;
- haverá período de duplicidade controlada.

**Conclusão**

**É a alternativa recomendada.**

### 6.3 Alternativa 3 — Automação real por clique como eixo principal

**Descrição**

Tentar transformar a UI do Excel na principal superfície de automação.

**Vantagens**

- alta fidelidade visual;
- detecta regressão de botões, listas, foco e layout.

**Desvantagens**

- frágil;
- lenta;
- custo alto de manutenção;
- modal `MsgBox`/`InputBox` dificulta muito;
- em ambiente desktop Excel é mais instável do que automação de serviço;
- no macOS o custo de automação real tende a ser maior.

**Conclusão**

Boa como **camada complementar de smoke visual**, ruim como espinha dorsal do sistema de testes.

---

## 7. Estratégia aprovada recomendada: modelo híbrido

### 7.1 Princípio

O V2 deve combinar quatro superfícies:

1. **contratos de serviço**;
2. **cenários integrados**;
3. **smoke assistido de UI**;
4. **stress com invariantes**.

### 7.2 Taxonomia de tipos de teste

| Tipo | Objetivo | Execução | Prioridade |
|---|---|---|---|
| Smoke | provar que o sistema essencial abre e executa o fluxo principal | automatizada + assistida | P0 |
| Contract | validar pré-condições, pós-condições e erros esperados dos serviços | automatizada | P0 |
| State Transition | validar máquina de estados `PRE_OS`, `OS`, avaliação e suspensão | automatizada | P0 |
| Integration | validar fluxo completo entre serviços e repositórios | automatizada | P0 |
| Invariants | validar consistência das abas depois de cada operação | automatizada | P0 |
| Combinatorial | cobrir classes equivalentes e interações críticas | automatizada | P1 |
| Regression | congelar bugs e comportamentos já corrigidos | automatizada | P1 |
| UI Smoke | validar que a interface continua operacional | assistida e futuramente automatizável | P1 |
| Stress / Soak | validar robustez sob volume, repetição e estados raros | automatizada | P2 |
| Recovery | validar comportamento em falha parcial e retomada | automatizada | P2 |

### 7.3 Modos de execução

| Modo | Público | Escopo | Meta de tempo |
|---|---|---|---|
| Rápido | desenvolvedor / homologação rápida | smoke + contracts + invariants críticos | 2-5 min |
| Completo | estabilização / pré-release | smoke + contracts + integration + combinatorial + regression | 10-25 min |
| Assistido | humano acompanhando na tela | subset agrupado, com pausas, explicação e feedback visual | variável |
| Stress | validação profunda e técnica | cenários sintéticos massivos + invariantes | 15-60 min |

---

## 8. Como subir o percentual de cenários realmente testados

### 8.1 Não atacar o espaço teórico bruto; atacar classes, restrições e interações

O documento combinatório estimou um espaço teórico de 25.920 combinações. O ganho real virá de:

1. **redução por restrições semânticas**;
2. **partição por classes equivalentes**;
3. **pairwise nas dimensões críticas**;
4. **3-wise seletivo nas áreas de maior risco**;
5. **invariantes pós-operação**;
6. **stress com aleatoriedade reprodutível**.

### 8.2 Estratégia formal recomendada

#### Camada A — Cobertura de guard rails

- 100% dos métodos públicos de serviço;
- 100% dos estados inválidos conhecidos;
- 100% das transições proibidas.

#### Camada B — Cobertura combinatória dirigida por risco

Aplicar pairwise e 3-wise nas dimensões:

- `STATUS_GLOBAL`
- `STATUS_CRED`
- `TEM_OS_ABERTA`
- `TEM_PRE_OS_PENDENTE`
- `QTD_RECUSAS`
- `DT_FIM_SUSP vs Today`
- `MEDIA_NOTAS`
- `posição de fila`

#### Camada C — Cobertura por propriedades

Exemplo de propriedades:

1. nunca retornar empresa com `STATUS_GLOBAL=INATIVA`;
2. nunca retornar empresa com OS aberta na mesma atividade;
3. não mover fila no filtro E;
4. mover fila exatamente uma vez nos eventos que exigem giro;
5. não converter `PRE_OS` fora de `AGUARDANDO_ACEITE`;
6. nunca concluir `OS` cancelada;
7. nunca deixar fila com posições duplicadas na mesma atividade;
8. nunca deixar suspensão ativa expirada sem possibilidade de reativação.

### 8.3 Meta de cobertura

| Camada | Cobertura alvo |
|---|---|
| Guard rails de serviço | 100% |
| Fluxos P0 | 100% |
| Classes equivalentes críticas | 95%+ |
| Pairwise crítico | 95%+ |
| 3-wise seletivo | 80%+ |
| UI smoke principal | 100% dos fluxos P0 |

---

## 9. Proposta do novo módulo de testes V2

### 9.1 Arquitetura proposta

**Módulos novos sugeridos**

- `vba_export/Teste_V2_Types.bas`
- `vba_export/Teste_V2_Catalogo.bas`
- `vba_export/Teste_V2_Semantica.bas`
- `vba_export/Teste_V2_Fixtures.bas`
- `vba_export/Teste_V2_Invariantes.bas`
- `vba_export/Teste_V2_Contracts.bas`
- `vba_export/Teste_V2_Integration.bas`
- `vba_export/Teste_V2_Combinatoria.bas`
- `vba_export/Teste_V2_Stress.bas`
- `vba_export/Teste_V2_Resultados.bas`
- `vba_export/Teste_V2_Assistido.bas`
- `vba_export/Teste_V2_UIAdapter.bas`
- `vba_export/Central_Testes_V2.bas`
- `vba_export/Central_Testes_V2_Relatorio.bas`

### 9.2 Conceito-chave

O teste deixa de ser “procedimento que só roda” e vira:

1. **cenário catalogado**;
2. **semântica explícita**;
3. **executor parametrizado**;
4. **resultado comparável**;
5. **leitura humana pronta para auditoria**.

### 9.3 Catálogo semântico de cenários

Cada cenário deve ter metadados como:

- `ScenarioId`
- `Titulo`
- `Dominio`
- `Objetivo`
- `PreCondicoes`
- `PassosExecutados`
- `ResultadoEsperado`
- `ResultadoObtido`
- `Interpretacao`
- `Criticidade`
- `ModoPermitido` (`FAST`, `FULL`, `ASSISTIDO`, `STRESS`)
- `ReferenciaCodigo`
- `ReferenciaRegra`

### 9.4 Artefato humano exigido

**Proposta obrigatória:** um arquivo ou aba de semântica legível por humano.

Formato recomendado:

| Campo | Uso |
|---|---|
| ID | identificação única |
| Cenário | nome do caso |
| Contexto | o que precisa existir antes |
| Objetivo | por que esse teste existe |
| Ação executada | o que o runner fez |
| Esperado | resultado correto |
| Obtido | resultado capturado |
| Significado | o que uma falha aqui representa |
| Severidade | impacto de uma falha |
| Código relacionado | serviço, repositório ou form |

Isso atende diretamente ao requisito de o humano entender:

- o que está sendo testado;
- por que está sendo testado;
- o que deveria acontecer;
- o que aconteceu;
- o que a diferença significa.

---

## 10. Modo rápido e modo assistido

### 10.1 Modo rápido

**Finalidade:** feedback imediato de estabilização.

Conteúdo mínimo:

- contratos de `Svc_Rodizio`, `Svc_PreOS`, `Svc_OS`, `Svc_Avaliacao`;
- invariantes críticos;
- fluxo principal `Empresa > Credenciamento > Pre-OS > OS > Avaliação`;
- smoke de cancelamento;
- smoke de reativação.

**Saída**

- resumo executivo curto;
- lista apenas de falhas;
- tempo total;
- status geral por bloco.

### 10.2 Modo assistido

**Finalidade:** permitir que o humano acompanhe a execução, veja o contexto e valide visualmente.

Recursos recomendados:

1. execução em grupos de 3 a 5 cenários;
2. pausa entre grupos;
3. destaque visual da linha/cenário atual;
4. explicação curta do objetivo antes de executar;
5. tela/aba de progresso;
6. indicação clara de `PASS`, `FAIL`, `WARN`, `MANUAL_CHECK`.

**Diferença para o legado**

O legado tem delay visual, mas não tem narrativa semântica nem agrupamento operacional.  
O V2 assistido deve ser realmente um modo de validação guiada, não apenas “o mesmo teste mais lento”.

---

## 11. Estratégia de UI e automação física

### 11.1 O que automatizar por clique real

A automação física de interface deve ficar restrita a:

1. abrir sistema;
2. navegar telas principais;
3. emitir Pre-OS;
4. aceitar/emitir OS;
5. encerrar OS;
6. cancelar OS;
7. reativar empresa;
8. validar relatórios principais.

### 11.2 O que NÃO usar clique real para provar

Não usar clique real como evidência primária para:

- regras de suspensão;
- consistência de fila;
- sincronização entre abas;
- invariantes combinatórias;
- consistência de auditoria;
- comportamento sob stress.

Essas provas devem nascer do core.

### 11.3 Estratégia recomendada para UI

**Curto prazo**

- smoke assistido;
- UI adapter interno, chamando eventos e lendo controles estáveis;
- redução das heurísticas restantes.

**Médio prazo**

- automação desktop pontual para fluxos P0.

**Longo prazo**

- se a migração para SaaS ocorrer, a camada visual migra para Playwright ou equivalente; no Excel ela deve permanecer smoke-oriented.

---

## 12. Stress test proposto

### 12.1 Finalidade

Provar robustez operacional, não apenas funcionalidade nominal.

### 12.2 Estrutura do stress

#### Dataset sintético

- 10, 50, 100, 300 empresas;
- 5, 20, 50 atividades;
- distribuições realistas de credenciamento;
- mistura de empresas ativas, inativas e suspensas;
- sementes fixas para reprodutibilidade.

#### Operações em laço

- selecionar empresa;
- emitir Pre-OS;
- recusar;
- expirar;
- emitir OS;
- cancelar OS;
- avaliar com médias diversas;
- reativar;
- repetir por lote.

### 12.3 Invariantes obrigatórias do stress

Após cada operação, validar:

1. `POSICAO_FILA` única por atividade;
2. sem empresa inelegível sendo eleita;
3. sem `PRE_OS` convertida sem `OS_ID`;
4. sem `OS` concluída e cancelada ao mesmo tempo;
5. sem fila avançando duas vezes no cancelamento;
6. sem divergência entre recusa local e global acima do tolerável;
7. sem `SUSPENSA_GLOBAL` vencida continuar inelegível depois de reprocessamento;
8. sem dupla indicação simultânea indevida.

### 12.4 Tipos de stress

| Tipo | Objetivo |
|---|---|
| Volume | medir comportamento com base grande |
| Sequencial | provar invariantes após muitas operações |
| Boundary | testar limites de recusa, nota, datas e fila |
| Recovery | simular falhas e confirmar consistência remanescente |
| Drift | comparar estado esperado vs estado real após muitas transições |

---

## 13. Operacionalização da nova esteira

### 13.1 Entrada unificada

Criar uma nova central:

- `Central_Testes_V2`

Menu sugerido:

1. Smoke rápido
2. Full suite
3. Assistido
4. Combinatório
5. Stress
6. Histórico
7. Relatório semântico
8. UI smoke

### 13.2 Saídas obrigatórias

- aba de resultados estruturados;
- aba de histórico;
- aba de semântica/explicação;
- CSV com timestamp;
- CSV de falhas;
- relatório imprimível consolidado;
- opcionalmente Markdown exportável.

### 13.3 Regras de operação

1. sempre permitir reset controlado;
2. sempre registrar seed e modo de execução;
3. nunca sobrescrever histórico anterior;
4. sempre separar `FAIL` de `WARN`;
5. sempre permitir rerun de subconjunto;
6. sempre permitir shadow compare com a bateria legada.

---

## 14. Plano de transição sem conflito

### 14.1 É possível trabalhar nisso sem conflito com o Cursor?

**Sim, é viável, desde que o escopo seja isolado por camada e por write set.**

### 14.2 Por que a convivência é viável

1. o próprio protocolo anti-regressão trata os módulos de teste como isoláveis;
2. o roadmap atual do Cursor está concentrado em estabilização funcional e interface/importador;
3. a nova estratégia pode nascer em arquivos novos;
4. a integração com o legado pode ser adiada até o fim do shadow mode.

### 14.3 Write set seguro recomendado

**Pode ser trabalhado em paralelo**

- novos arquivos em `auditoria/`;
- novos módulos `vba_export/Teste_V2_*.bas`;
- `vba_export/Central_Testes_V2.bas`;
- `vba_export/Central_Testes_V2_Relatorio.bas`;
- novas abas de resultado com nomes próprios.

**Evitar, enquanto o Cursor estiver avançando microevoluções**

- `Menu_Principal.frm`
- `Preencher.bas`
- `Importador_VBA.bas`
- `App_Release.bas`
- `Util_Conversao.bas`
- `obsidian-vault/ai/ESTADO-ATUAL.md`
- `obsidian-vault/ai/GOVERNANCA.md`

### 14.4 Momento de integração

Tocar no legado só em três momentos:

1. expor alguns contratos mínimos de serviço, se necessário;
2. adicionar atalho para abrir `Central_Testes_V2`;
3. trocar a central padrão no fim da homologação.

---

## 15. Roadmap recomendado do V2

### Fase 0 — Reconciliação documental

Objetivo:

- alinhar auditoria, código e cobertura real;
- congelar baseline da bateria atual.

Entregas:

- matriz reconciliada;
- lista oficial de cenários P0/P1;
- inventário de validações ainda presas à UI.

### Fase 1 — Contratos e invariantes

Objetivo:

- criar fundação do V2.

Entregas:

- `Teste_V2_Types`
- `Teste_V2_Catalogo`
- `Teste_V2_Invariantes`
- `Teste_V2_Contracts`

### Fase 2 — Runner rápido e relatório semântico

Entregas:

- `Central_Testes_V2`
- runner rápido;
- histórico;
- relatório semântico;
- CSV com timestamp.

### Fase 3 — Integração e combinatória

Entregas:

- `Teste_V2_Integration`
- `Teste_V2_Combinatoria`
- geração pairwise / 3-wise seletiva;
- modo full.

### Fase 4 — Assistido e UI smoke

Entregas:

- `Teste_V2_Assistido`
- `Teste_V2_UIAdapter`
- modo visual com pausas e feedback.

### Fase 5 — Stress e recovery

Entregas:

- `Teste_V2_Stress`
- seeds reprodutíveis;
- relatórios de invariantes.

### Fase 6 — Shadow mode e retirada do legado

Condições para aposentadoria da bateria atual:

1. V2 cobrir todos os cenários P0/P1 do legado;
2. V2 ter histórico estável em pelo menos 2-3 releases;
3. divergências entre V1 e V2 resolvidas;
4. central V2 homologada por humano.

Só então:

- `Central_Testes.bas` vira ponte;
- `Teste_Bateria_Oficial.bas` entra em modo legado/deprecado;
- `Teste_UI_Guiado.bas` e `Treinamento_Painel.bas` viram acervos ou apêndices.

---

## 16. Decisões para aprovação

### Aprovar agora

1. criação do módulo V2 em paralelo;
2. migração sistemática de validações da UI para os serviços;
3. taxonomia única de testes;
4. catálogo semântico obrigatório;
5. execução em quatro modos: rápido, completo, assistido e stress;
6. shadow mode antes da retirada da bateria atual.

### Não recomendar agora

1. substituir imediatamente a bateria atual;
2. usar clique real como eixo principal;
3. mexer nos arquivos que o Cursor está evoluindo sem coordenação de write set;
4. concentrar a solução toda em `Menu_Principal.frm`.

---

## 17. Parecer final

**É tecnicamente viável construir um módulo de testes independente, robusto e funcional, capaz de substituir a bateria atual, com nível de segurança muito superior ao estado presente.**

Mas a substituição segura exige três premissas:

1. **o V2 deve nascer desacoplado**;
2. **a regra de negócio precisa subir da UI para os serviços**;
3. **a retirada do legado deve ocorrer apenas após convivência controlada**.

Se essas três premissas forem respeitadas, a proposta é compatível com:

- estabilização forte;
- aumento real de cobertura;
- automação híbrida;
- análise combinatória operacional;
- feedback humano claro;
- baixa chance de conflito com as microevoluções atuais.

---

## 18. Próximo passo sugerido

Se aprovado, o próximo artefato natural é:

1. **Mapa de testes V2** com a lista oficial de cenários P0/P1/P2;
2. **catálogo semântico inicial**;
3. **desenho dos módulos `Teste_V2_*`** com responsabilidade por arquivo;
4. **plano de write set** para execução em paralelo sem conflito.

