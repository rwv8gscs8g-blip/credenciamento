---
titulo: Auditoria Unificada dos Testes, Cobertura, Documentação, Interface e Proposta de Unificação V1/V2
natureza-do-documento: auditoria técnica e institucional
escopo: bateria oficial V1, suíte V2 (Engine + Roteiros), testes assistidos, documentação `docs/testes/`, interface de testes (`Central_Testes`, `Central_Testes_V2`) e plano de desacoplamento da interface operacional
versao-sistema-referencia: V12.0.0202 (release oficial)
linha-de-implementacao: V12.0.0203
data: 2026-04-21
autoria: Auditoria conduzida por Claude Opus 4.7 a pedido de Luís Maurício Junqueira Zanin
destino: gestores públicos, auditoria externa, mantenedores técnicos, futuras IAs que ampliem a suíte
padrao-narrativo: leitura / matriz / decomposição em blocos / catálogo (pré-condição, ação, resultado esperado, razão), conforme `docs/testes/00_MODELO_DOCUMENTAL_DOS_TESTES.md`
observacao-de-sincronia: documento saneado em 2026-04-21 para refletir os cenários e a trilha cumulativa já validados em workbook na linha `V12.0.0203`
---

# 21. Auditoria Unificada dos Testes — V12.0.0203

> Este documento é uma auditoria institucional única. Ele consolida, em
> uma só leitura, a avaliação de **como** o projeto testa, **o que** o
> projeto testa, **o quanto** ele testa, **como documenta** o que testa,
> **como opera** esses testes pela interface, e **para onde** essa
> arquitetura deve evoluir. O texto foi escrito para ser lido por um
> gestor humano, um auditor externo, um mantenedor técnico e uma futura
> IA — nessa ordem de prioridade. As seções estão numeradas 00 a 15 e
> devem ser lidas em sequência. Citações de arquivos respeitam a árvore
> pública do repositório.

## 00. Veredito executivo

A estratégia de testes da linha pública `V12.0.0202` é **madura, honesta
e suficiente** para sustentar a release oficial estabilizada, mas **não é
ainda o teto de maturidade desejado** para a sucessora `V12.0.0203`.

Em uma frase: o projeto já prova o que precisa provar, com determinismo
e rastreabilidade, mas ainda paga um custo de dispersão entre três
camadas de teste (V1, V2 e assistidos) que descrevem o mesmo modelo de
negócio por vocabulários diferentes. A próxima evolução não precisa
refazer a base; precisa **unificá-la sob um único dicionário canônico**
e **reduzir a dependência do formulário principal** para que novos
cenários sejam baratos de escrever.

Os três pontos de reforço que sustentam esse veredito são:

1. **Determinismo real.** A suíte V2 reconstrói a base operacional a cada
   cenário (`TV2_ResetBaseOperacional`), o que elimina contaminação
   cruzada e permite que duas execuções consecutivas da mesma suíte
   produzam exatamente a mesma sequência de empresas escolhidas. Isso é
   a fundação técnica da auditabilidade da linha pública.
2. **Auditoria como evidência de primeira classe.** `Audit_Log`,
   `RESULTADO_QA`, `RESULTADO_QA_V2`, `HISTORICO_QA_V2` e o relatório
   `RPT_TESTES_V2` tornam cada rodada de teste em um artefato físico
   revisável, e o manifesto em `auditoria/evidencias/V12.0.0202/` liga a
   execução de teste à release oficial com hash verificável.
3. **Narrativa humana já iniciada.** A área `docs/testes/` inaugura a
   leitura institucional da bateria; a proposta canônica
   `PROPOSTA_TESTES_V2_CENARIO_CANONICO.md` cristaliza o padrão
   *leitura/matriz/blocos/catálogo* como vocabulário oficial para todo
   teste futuro — humano ou gerado por IA.

Os três pontos de melhoria estruturais, por ordem de impacto, são:

1. **Dependência residual da interface (`Menu_Principal.frm`).**
   Montagem de payload de avaliação, orquestração de emissão de
   Pré-OS/OS e geração de relatórios ainda vivem no formulário
   principal. Isso encarece teste estrutural e força a suíte V2 a
   emular intenção do usuário em vez de exercitar serviços puros.
2. **Fragmentação entre V1 e V2.** A bateria oficial V1 prova regressão
   funcional pela ótica de blocos temáticos (preparação, rodízio,
   avaliação, matriz combinatória). A suíte V2 prova o mesmo modelo de
   negócio pela ótica de cenários canônicos (`CS_*`, `SMK_*`, `STR_*`,
   `EXP_*`, `ATM_*`). As duas dizem coisas sobrepostas em linguagens
   diferentes; não há ainda um comparador estrutural.
3. **Ausência de trilha cumulativa própria da suíte.** `AUDIT_LOG`
   operacional é zerada entre cenários por design (boa prática para
   determinismo), mas isso implica que o "filme completo" da execução
   precisa ser reconstruído a partir de `RESULTADO_QA_V2` +
   `HISTORICO_QA_V2`. Uma trilha cumulativa dedicada aos testes
   (separada do `AUDIT_LOG` de negócio) é o próximo incremento natural.

A conclusão executiva é simples: **a `V12.0.0202` pode ser publicada
sem retenção de prova**; a `V12.0.0203` deve ser o ciclo que transforma
essa prova em norma.

## 01. Explicação para humanos — o que estamos testando, por que, e para quem

Este capítulo existe para que um gestor público, um auditor jurídico ou
um conselheiro institucional consiga entender, sem conhecer VBA, por que
o sistema é confiável.

### 01.1 O que o sistema faz, em uma frase

O Sistema de Credenciamento e Rodízio de Pequenos Reparos distribui
serviços a empresas credenciadas em rodízio, controlando: quem pode ser
escolhido, quando uma empresa deve ser pulada, quando uma empresa deve
ser suspensa, quando ela volta a ser apta e como isso tudo fica
registrado em auditoria.

### 01.2 O que a bateria de testes prova

A bateria prova, por execução reprodutível, que as regras desse rodízio
não dependem da memória do operador e não podem ser alteradas
silenciosamente por uma modificação futura. Em termos institucionais, a
bateria é a **evidência automatizada de conformidade**: ela mostra que
o sistema se comporta hoje como se comportou ontem, e que qualquer
mudança estrutural rompe um ou mais cenários, sendo portanto visível.

### 01.3 Três perguntas que a bateria responde todos os dias

- **Uma empresa suspensa volta a receber serviço corretamente?**
  Respondida pelos blocos de suspensão (manual e por nota) tanto na V1
  quanto na V2.
- **Quando nenhuma empresa está apta, o sistema trava?**
  Respondida pelo cenário de bloqueio total (CS-07 na V2, bloco de
  rodízio da V1).
- **A fila gira de verdade ou apenas começa do mesmo ponto?**
  Respondida pelo cenário de loop longo (CS-17 na V2, expansão de 5
  ciclos na V1) — o teste de vida do rodízio.

### 01.4 Por que três camadas de teste

O projeto herdou, conscientemente, **três camadas complementares**:

- **Bateria Oficial V1.** Regressão funcional consolidada, escrita na
  linguagem do produto; aceita por humanos como "o teste que a release
  precisa passar". Executada pela `Central_Testes`. Serve ao gestor e
  ao auditor externo.
- **Suíte V2.** Baseline determinística, com reset canônico a cada
  cenário, escrita na linguagem dos serviços (`Svc_Rodizio`,
  `Svc_PreOS`, `Svc_OS`, `Svc_Avaliacao`). Executada pela
  `Central_Testes_V2`. Serve ao mantenedor técnico e à IA.
- **Testes assistidos (UI Guiado e Roteiro Rápido V1).** Verificação
  humana de fluxos visuais. Serve à homologação e ao treinamento de
  operadores novos.

Cada camada foi mantida porque **responde a uma pergunta diferente**,
não porque o projeto não soube escolher. A unificação proposta neste
documento (seção 12) preserva essa distinção funcional ao mesmo tempo
em que une o vocabulário comum.

### 01.5 Para quem este documento fala

- **Para o gestor público.** A leitura que importa é esta seção e a
  seção 00. Ambas dizem, em linguagem institucional, que a bateria
  sustenta a release.
- **Para o auditor externo.** A leitura que importa são as seções 03
  (matriz modelo × testes), 04 (cobertura) e 05 (método).
- **Para o mantenedor técnico.** A leitura que importa são as seções 08
  (catálogo), 09 (novos testes), 10 (interface) e 13 (arquitetura).
- **Para a futura IA.** A leitura que importa é o documento inteiro, em
  ordem; ela precisa reconstruir o racional antes de ampliar a suíte.

## 02. Mapa completo das famílias de testes

### 02.1 Leitura do mapa

O projeto opera três famílias de teste, cada uma com submódulos próprios,
e uma área documental que orienta a leitura humana. Cada família tem
**origem no código**, **ponto de execução**, **aba de evidência** e
**relatório associado**. Um cenário novo precisa encontrar seu lugar em
uma dessas famílias antes de ser escrito; essa disciplina é o que
impede a suíte de virar um arquivo de scripts soltos.

### 02.2 Matriz das famílias

| Família | Módulo VBA principal | Ponto de execução | Evidência estrutural | Relatório humano |
|---|---|---|---|---|
| Bateria Oficial V1 | `Teste_Bateria_Oficial.bas` | `Central_Testes` → `CT_IniciarBateria` | `RESULTADO_QA` | `RPT_BATERIA` |
| Roteiro Rápido V1 | `Teste_Roteiro.bas` (P01..P16) | `Central_Testes` → Roteiro Rápido | `ROTEIRO_RAPIDO` | `RPT_ROTEIRO` |
| UI Guiado | `Teste_UI_Guiado.bas` (UI-01..UI-10) | `Central_Testes` → UI Guiado | interação visual + `AUDIT_LOG` | — (manual) |
| CHECKLIST 136 | planilha manual opcional | `Central_Testes` (leitura) | `CHECKLIST_136` | `RPT_CK136` |
| V2 Smoke | `Teste_V2_Roteiros.bas` (`SMK_*`) | `Central_Testes_V2` → Smoke rápido / assistido | `RESULTADO_QA_V2`, `HISTORICO_QA_V2` | `RPT_TESTES_V2` |
| V2 Canônico | `Teste_V2_Roteiros.bas` (`CS_*`) | `Central_Testes_V2` → Canônico | `RESULTADO_QA_V2`, `CATALOGO_CENARIOS_V2` | `RPT_TESTES_V2` |
| V2 Stress | `Teste_V2_Roteiros.bas` (`STR_*`) | `Central_Testes_V2` → Stress | `RESULTADO_QA_V2` | `RPT_TESTES_V2` |
| V2 Atomicidade | `Teste_V2_Roteiros.bas` (`ATM_*`) | `Central_Testes_V2` → Atomicidade | `RESULTADO_QA_V2` | `RPT_TESTES_V2` |
| V2 Expiração Pre-OS | `Teste_V2_Roteiros.bas` (`EXP_*`) | `Central_Testes_V2` → Canônico/Smoke | `RESULTADO_QA_V2` | `RPT_TESTES_V2` |
| V2 Assistido | `Teste_V2_Roteiros.bas` (`ASS_*`) | `Central_Testes_V2` → Assistido | `ROTEIRO_ASSISTIDO_V2` | `RPT_TESTES_V2` |
| Consolidado | agregador | `Central_Testes` → Relatório consolidado | `RPT_CONSOLIDADO` | `RPT_CONSOLIDADO` |

### 02.3 Decomposição por família

- **Bateria Oficial V1.** Organizada em seis blocos: preparação,
  setup canônico, rodízio, inativação/reativação, fluxo completo
  Pré-OS → OS → Avaliação, expansão de cinco ciclos, regressão técnica
  por filtros `A` a `E` e matriz combinatória. Fecha com exportação
  CSV automática apenas em caso de falha e `RESULTADO_QA` sempre
  preservado.
- **Roteiro Rápido V1 (P01–P16).** Passagem humana linear por
  dezesseis passos operacionais. Registra presença ou ausência do
  efeito esperado na aba `ROTEIRO_RAPIDO`. É um cartão de embarque
  para homologação, não substituto da bateria.
- **UI Guiado (UI-01–UI-10).** Cenários visuais curtos com orientação
  de clique; validam que o formulário reage corretamente a eventos.
  Não são testes automatizados — são scripts de inspeção humana.
- **CHECKLIST 136.** Planilha manual opcional, desacoplada da bateria
  a partir da `V12.0.0202`. Hoje é lida pelo relatório
  `RPT_CK136` para consolidação, sem mais sincronização ao vivo.
- **V2 Smoke (`SMK_001`–`SMK_007`, `EXP_001`, `ATM_001`, `MIG_001`–
  `MIG_004`, `MUT_001`).** Saúde rápida da baseline. Prova que os
  serviços migrados não regrediram, que transações atômicas
  comitam/rebatem corretamente e que as guardas essenciais de migração
  continuam firmes.
- **V2 Canônico (`CS_00`–`CS_22`).** Núcleo semântico do novo
  vocabulário. Cada cenário responde a uma regra específica do modelo
  de negócio, com pré-condição explícita, ação nomeada e asserção
  verificável. É a família escolhida como padrão para ampliação
  futura.
- **V2 Stress (`STR_001`).** Loop longo que prova vida da fila em
  execução prolongada — hoje o teste de "giro longo" é `CS_17`
  (canônico), mas `STR_001` permanece como bateria paralela de
  invariantes repetitivas.
- **V2 Atomicidade (`ATM_001`).** Prova mínima de rollback
  transacional: uma falha injetada na metade de uma escrita não pode
  deixar estado parcial.
- **V2 Assistido (`ASS_002`).** Cenários com pausa visual para
  inspeção humana durante a execução determinística — ponte entre
  Roteiro Rápido V1 e V2 canônico.

### 02.4 Catálogo das interfaces de execução

- `Central_Testes` — submenu tradicional da V1. Dois caminhos
  principais: bateria V1 (com confirmação dupla) e V2 (encaminha para
  `Central_Testes_V2`). Botões secundários: Roteiro Rápido, UI Guiado,
  CHECKLIST 136, relatórios, limpeza de artefatos V1.
- `Central_Testes_V2` — submenu de nove opções: Smoke rápido, Smoke
  assistido, Canônico, Stress, Atomicidade, Expiração, Todos,
  Catálogo, Abrir evidência. Cada opção chama o motor
  `Teste_V2_Engine` com um subconjunto diferente de cenários.

### 02.5 Razão de manter múltiplas famílias

Cada família responde a uma pergunta institucional distinta:

- **V1** prova regressão funcional reconhecível por humanos.
- **V2** prova propriedades do modelo de negócio em vocabulário canônico.
- **Assistidos** provam que a camada visual não regride com a lógica.

Unificar isso prematuramente custaria perda semântica. A proposta da
seção 12 mantém as três famílias e apenas **padroniza o dicionário**,
produzindo uma matriz de rastreabilidade entre elas.

## 03. Matriz de cobertura do modelo de negócio

### 03.1 Leitura da matriz

O modelo de negócio do sistema é composto por cinco serviços
(`Svc_Rodizio`, `Svc_PreOS`, `Svc_OS`, `Svc_Avaliacao`, `Svc_Transacao`)
e por duas camadas atravessadoras (`Audit_Log` e `Svc_Cadastro`). Cada
serviço expõe um conjunto de regras catalogadas como **R-01** a **R-59**
na auditoria `03_AUDITORIA_REGRAS_DE_NEGOCIO.md`. A matriz abaixo cruza
cada regra com o(s) cenário(s) de teste que a exercita. A regra é
considerada coberta quando ao menos um cenário automatizado a invoca
com asserção explícita.

A matriz **não é um substituto** da auditoria de regras. Ela é um mapa
de rastreabilidade — responde à pergunta "se esta regra quebrar, qual
teste falha?".

### 03.2 Matriz por serviço

**Svc_Rodizio (11 regras, R-01 a R-11).**

| Regra | Tema | Cenário(s) que cobrem | Observação |
|---|---|---|---|
| R-01 | Ordem da fila por `POSICAO_FILA` | BO_310, CS-03, CS-05, CS-06 | núcleo nominal |
| R-02 | Pulo por `STATUS_CRED <> ATIVO` | BO_410, CS-21 | complementar |
| R-03 | Pulo por `SUSPENSA_GLOBAL` com `DT_FIM > hoje` | BO_320, CS-11, CS-15 | crítico |
| R-04 | Reativação automática por `DT_FIM <= hoje` | CS-13 | crítico |
| R-05 | OS aberta na atividade → move ao fim da fila | BO_330, CS-05 | crítico |
| R-06 | Pré-OS pendente → pular sem mover | BO_340, CS-06, CS-09 | crítico |
| R-07 | `SEM_CREDENCIADOS_APTOS` sem trava | BO_350, CS-07, CS-18 | crítico |
| R-08 | `AvancarFila` move a empresa escolhida ao fim | BO_360, CS-04, CS-17 | núcleo |
| R-09 | `AvancarFila(IsPunido = True)` incrementa `QTD_RECUSAS` | BO_370, CS-09 | sensível |
| R-10 | Rotação circular preserva integridade | BO_380, CS-17 | teste de vida |
| R-11 | Não duplicação de IDs na fila | STR_001 | estrutural |

**Svc_PreOS (14 regras, R-12 a R-25).**

| Regra | Tema | Cenário(s) | Observação |
|---|---|---|---|
| R-12 | Criação gera `AGUARDANDO_ACEITE` | BO_405, CS-03 | núcleo |
| R-13 | Aceite válido muda status para `ACEITA` | BO_412, CS-04 | núcleo |
| R-14 | Recusa exige avanço de fila pré-escrita | BO_418, CS-09 | sensível |
| R-15 | Expiração por `DT_VAL` converte em `EXPIRADA` | EXP_001, CS-10 | crítico |
| R-16 | Conversão em OS produz `PRE_OS.CONVERTIDA_OS` | BO_420, CS-04 | núcleo |
| R-17 | Rejeição de conversão dupla | ATM_001 | atomicidade |
| R-18 | Formato `COD_SERVICO` aceita legado e moderno | BO_430, MIG_001 | migração |
| R-19 | Vínculo serviço × atividade preservado | BO_432, CS-22 | integridade |
| R-20 | Rejeição de atividade inexistente | CS-02 | catálogo |
| R-21 | Rejeição de serviço duplicado | CS-01 | catálogo |
| R-22 | `Audit_Log` registra cada transição | BO_440, SMK_007 | auditoria |
| R-23 | Pré-OS pendente bloqueia empresa em emissões seguintes | CS-06 | sensível |
| R-24 | Status terminal não regressa | ATM_001 | estrutural |
| R-25 | Reemissão após expiração não reaproveita ID | EXP_001 | determinismo |

**Svc_OS (8 regras, R-26 a R-33).**

| Regra | Tema | Cenário(s) | Observação |
|---|---|---|---|
| R-26 | OS aberta vincula empresa e atividade | BO_450, CS-04 | núcleo |
| R-27 | OS aberta bloqueia empresa no rodízio | BO_452, CS-05 | sensível |
| R-28 | Conclusão exige avaliação mínima | BO_460, SMK_007 | auditoria |
| R-29 | Conclusão registra `OS_CONCLUIDA` | BO_462, SMK_007 | auditoria |
| R-30 | Conclusão libera empresa para rodízio | BO_464, CS-08 | crítico |
| R-31 | OS concluída não regressa a aberta | CS-18 | crítico |
| R-32 | OS não pode ser reavaliada | CS-18 | crítico |
| R-33 | Falha na conclusão produz rollback | ATM_001 | atomicidade |

**Svc_Avaliacao (10 regras, R-34 a R-43).**

| Regra | Tema | Cenário(s) | Observação |
|---|---|---|---|
| R-34 | Avaliação gera `AVALIACAO_REGISTRADA` | BO_470, SMK_007 | auditoria |
| R-35 | Média abaixo do mínimo → suspensão automática | BO_472, CS-14 | crítico |
| R-36 | Média suficiente → sem suspensão | BO_474, SMK_007 | crítico (ampliado em B1) |
| R-37 | `MOTIVO_SUSPENSAO = NOTA_BAIXA` preenchido | BO_476, CS-14 | auditoria |
| R-38 | `DT_FIM_SUSPENSAO` calculada por janela | BO_478, CS-14 | crítico |
| R-39 | Suspensão por nota equivale a manual em efeito | CS-15 | semântico |
| R-40 | Fim do prazo reabilita sem perda de turno | CS-16 | crítico |
| R-41 | Avaliação exige OS concluída como pré-condição | BO_480 | estrutural |
| R-42 | Notas fora do range são rejeitadas | BO_482 | entrada |
| R-43 | Reavaliação não sobrescreve registro | CS-18 | estrutural |

**Svc_Transacao (6 regras, R-44 a R-49).**

| Regra | Tema | Cenário(s) | Observação |
|---|---|---|---|
| R-44 | `BeginWrite` abre contexto | ATM_001 | atomicidade |
| R-45 | `CommitWrite` consolida | ATM_001 | atomicidade |
| R-46 | `RollbackWrite` reverte mutação parcial | ATM_001 | atomicidade |
| R-47 | Falha dentro do bloco aborta escrita | ATM_001 | atomicidade |
| R-48 | Transação aninhada respeita outermost | — | lacuna |
| R-49 | Log de transação legível em mensagem | ATM_001 | atomicidade |

**Audit_Log (8 regras, R-50 a R-57).**

| Regra | Tema | Cenário(s) | Observação |
|---|---|---|---|
| R-50 | Cada evento tem tipo, entidade, identidade e carimbo | BO_490, SMK_007 | auditoria |
| R-51 | `RODIZIO_INDICOU` em toda seleção bem-sucedida | BO_492, CS-03 | núcleo |
| R-52 | `RODIZIO_BLOQUEADO` em `SEM_CREDENCIADOS_APTOS` | CS-07 | crítico |
| R-53 | `SUSPENSAO_POR_NOTA` em avaliação ruim | CS-14 | crítico |
| R-54 | `OS_EMITIDA` / `OS_CONCLUIDA` simétricos | SMK_007 | auditoria |
| R-55 | `AVALIACAO_REGISTRADA` único por OS | BO_494 | estrutural |
| R-56 | `VALIDACAO_REJEITADA` em catálogo inválido | CS-01, CS-02 | catálogo |
| R-57 | Completude por família de evento (presença mínima) | CS-21 | auditoria |

**Svc_Cadastro (2 regras, R-58 a R-59).**

| Regra | Tema | Cenário(s) | Observação |
|---|---|---|---|
| R-58 | Inativação cadastral é terminal até reativação | BO_210, CS-20, CS-24 | crítico |
| R-59 | Reativação preserva posição absoluta | BO_220, CS-23 | crítico |

### 03.3 Lacunas de cobertura identificadas

A matriz, após os entregáveis já validados na linha `V12.0.0203`,
expõe **uma lacuna objetiva remanescente**: R-48 (transação aninhada).
As antigas lacunas R-31, R-32 e R-43 foram fechadas por `CS-18`, e a
lacuna R-57 foi fechada por `CS-21`. A regra R-49 deixa de ser tratada
como lacuna porque `ATM_001` já devolve mensagem legível de rollback ao
operador. Assim, a única pendência estrutural residual é defensiva e
arquitetural, não mais de regra crítica do negócio.

## 04. Estimativa de cobertura

### 04.1 Leitura da estimativa

Cobertura em projetos VBA deste porte não se mede por linha de
código — a métrica honesta é **cobertura do modelo de negócio**, isto é,
a proporção de regras catalogadas do domínio (R-01 a R-59) que dispõem
de ao menos um teste automatizado com asserção explícita. A soma de
cenários em várias famílias pode inflar a aparência de cobertura; a
métrica usada aqui é conservadora e recusa somar equivalentes.

### 04.2 Matriz de estados por cobertura

| Dimensão | Total | Cobertos | Lacunas | % coberto |
|---|---|---|---|---|
| Regras de `Svc_Rodizio` | 11 | 11 | 0 | 100% |
| Regras de `Svc_PreOS` | 14 | 14 | 0 | 100% |
| Regras de `Svc_OS` | 8 | 8 | 0 | 100% |
| Regras de `Svc_Avaliacao` | 10 | 10 | 0 | 100% |
| Regras de `Svc_Transacao` | 6 | 5 | 1 (R-48) | 83% |
| Regras de `Audit_Log` | 8 | 8 | 0 | 100% |
| Regras de `Svc_Cadastro` | 2 | 2 | 0 | 100% |
| **Consolidado** | **59** | **58** | **1** | **≈ 98,3 %** |

### 04.3 Decomposição da estimativa

- **Núcleo de rodízio (100%).** A única família inteiramente coberta
  por cenários determinísticos em duas camadas (V1 e V2). Isto é
  proposital: o rodízio é o coração do sistema.
- **Pré-OS (100%).** A suíte exercita criação, aceite, recusa,
  expiração, conversão, bloqueio por pendência, vínculo com catálogo
  e auditoria.
- **OS (100%).** O bloco `CS-18` fechou as transições inválidas
  remanescentes de OS concluída e tornou auditáveis as rejeições de
  reavaliação e cancelamento.
- **Avaliação (100%).** A proteção contra reavaliação indevida ficou
  explícita e rastreável em `CS-18`.
- **Transação (83%).** A lacuna de transação aninhada (R-48) é teórica:
  o código atual não encadeia transações. Permanece como prova
  arquitetural pendente.
- **Auditoria (100%).** `CS-21` passou a exigir presença mínima das
  famílias críticas de evento, convertendo completude em critério
  automatizado e não mais em expectativa implícita.
- **Cadastro (100%).** Cobertura plena, com espaço para ampliação via
  frente A3 (ida e volta de inativação/reativação).

### 04.4 Razão do número 98,3%

Esse número **não é declaração de qualidade**. É declaração de
rastreabilidade: 98,3% das regras catalogadas têm ao menos uma
asserção automatizada. O que sustenta a qualidade é a **natureza** dos
cenários — determinísticos, reseteáveis, auditáveis — e não a
percentagem. Um projeto com 100% de cobertura frágil é pior do que um
projeto com 98,3% de cobertura determinística.

### 04.5 Política de ampliação da cobertura

- **R-48** permanece como pendência técnica de prioridade baixa, pois
  o código atual não encadeia transações, mas a prova arquitetural
  continua desejável.
- **R-31, R-32, R-43 e R-57** deixam de ser backlog de cobertura e
  passam a ser ativos já absorvidos pela linha `V12.0.0203`.

## 05. Auditoria metodológica

### 05.1 Leitura metodológica

A metodologia da bateria é a parte mais importante deste documento. É
ela quem define se um teste verde significa alguma coisa. Esta seção
documenta **as escolhas conscientes** que o projeto fez, cada uma com
uma pergunta de auditoria associada.

### 05.2 Matriz de decisões metodológicas

| Decisão | Onde vive | Pergunta de auditoria | Resposta |
|---|---|---|---|
| Reset determinístico por cenário | `Teste_V2_Engine.bas` (`TV2_ResetBaseOperacional`) | Duas rodadas produzem a mesma saída? | Sim, por construção. |
| Asserção explícita obrigatória | `Teste_V2_Engine.bas` (`TV2_LogAssert`) | Há cenários verdes sem asserção? | Não — `TV2_LogAssert` sem asserção falha. |
| Separação entre resultado e evidência | `RESULTADO_QA_V2` × `HISTORICO_QA_V2` | A última execução apagou o histórico? | Não — histórico cumulativo é preservado. |
| CSV automático apenas em falha | `Teste_Bateria_Oficial.bas` + `Teste_V2_Engine.bas` | Execução verde gera ruído? | Não — execução limpa é silenciosa. |
| Separação entre bateria e interface | `Central_Testes` × `Central_Testes_V2` | Posso rodar bateria sem abrir formulário principal? | Sim — as centrais são independentes. |
| Auditoria como evidência estrutural | `Audit_Log` + `AUDIT_LOG` aba | Um evento crítico pode desaparecer? | Não — cada ação com efeito de estado registra evento. |
| Documentação humana paralela | `docs/testes/` | Um novo operador consegue ler a bateria sem abrir VBA? | Sim, desde a `V12.0.0202`. |

### 05.3 Decomposição das escolhas

- **Reset determinístico.** A decisão mais importante da V2. Ela
  implica que cada cenário começa do zero, com catálogo canônico
  reconstruído. Isso é caro (reset custa tempo de execução), mas
  elimina três classes de bug de teste: contaminação cruzada,
  dependência de ordem de execução e "testes que passam quando
  rodados sozinhos". O preço é aceito.
- **Asserção explícita.** O motor V2 recusa cenários sem `TV2_LogAssert`
  efetivo. Um cenário que apenas roda sem crash é rejeitado — o que
  elimina o antipadrão de "teste-smoke-verde-por-acidente".
- **Separação resultado/evidência.** `RESULTADO_QA_V2` responde à
  pergunta "qual foi a última rodada?". `HISTORICO_QA_V2` responde
  "quais foram todas as rodadas?". O operador não precisa escolher
  entre os dois — eles respondem perguntas diferentes. A nota do
  documento `docs/testes/01_*.md` é rigorosa sobre isso.
- **CSV apenas em falha.** Escolha explícita da `V12.0.0202`. Antes,
  toda execução gerava CSV, o que poluía o workspace e diluía o
  sinal. Hoje, CSV é sinônimo de algo que merece atenção.
- **Centrais independentes.** A `Central_Testes` e a `Central_Testes_V2`
  não compartilham estado nem forçam abrir `Menu_Principal.frm` para
  rodar. O operador pode validar a bateria inteira sem passar pela
  interface operacional.
- **Auditoria estrutural.** Todo evento com efeito de estado passa por
  `Audit_Log` com identidade, tipo e carimbo. Isso transforma a aba
  `AUDIT_LOG` em trilha verificável que sobrevive aos testes (pelo
  menos do último cenário, por design determinístico).
- **Documentação humana paralela.** A existência de `docs/testes/`
  rompe a dependência de leitura do código VBA para compreender a
  bateria. Sem isso, um auditor externo teria de ler 2.409 linhas de
  `Teste_Bateria_Oficial.bas` para entender o que a suíte prova.

### 05.4 Riscos metodológicos identificados

- **Reset determinístico apaga a história operacional.** Embora seja a
  decisão certa, o efeito colateral é a perda do "filme completo" na
  aba `AUDIT_LOG` após a execução. A proposta de trilha cumulativa
  dedicada (seção 13) cobre esse risco.
- **Cobertura desigual entre famílias.** Hoje, a V1 cobre o mesmo
  modelo de negócio que a V2, mas com vocabulário diferente. Isso
  significa que uma regra pode estar coberta pela V1 sem asserção
  explícita equivalente na V2 — ou vice-versa. A matriz de
  rastreabilidade da seção 03 mitiga, mas não elimina.
- **Tests assistidos não são assináveis.** UI Guiado e Roteiro Rápido
  V1 dependem de presença humana. Eles são necessários para
  homologação visual, mas não podem ser usados como prova automática
  de regra de negócio.

### 05.5 Razão final

A metodologia é boa porque é **explícita**. Cada escolha tem um
documento que a justifica e um artefato que a prova. O teste pode ser
ampliado sem quebrar o método, e o método pode ser auditado sem
depender do teste.

## 06. Auditoria documental

### 06.1 Leitura documental

Até a `V12.0.0202`, a bateria de testes era compreendida via leitura do
código VBA. A existência de `docs/testes/` é recente e representa um
ponto de inflexão: pela primeira vez, a documentação humana dos testes
virou obrigação de release.

### 06.2 Inventário documental

| Documento | Função | Estado |
|---|---|---|
| `docs/testes/INDEX.md` | Portal de leitura | Vigente |
| `docs/testes/00_MODELO_DOCUMENTAL_DOS_TESTES.md` | Padrão narrativo canônico | Vigente |
| `docs/testes/01_EVIDENCIAS_E_RELATORIOS_DE_TESTE.md` | Regras de evidência | Vigente |
| `docs/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md` | Catálogo canônico CS-00 a CS-22 | Aprovado |
| `auditoria/04_MATRIZ_MESTRE_DE_TESTES.md` | Estrutura pública das camadas | Vigente |
| `auditoria/20_PLANO_SPRINT_2_TESTES_E_DESACOPLAMENTO_V12_0203.md` | Backlog executável | Em execução |
| `auditoria/19_AUDITORIA_PONTOS_FORTES_V12_0202.md` | Auditoria positiva | Vigente |
| `auditoria/21_AUDITORIA_UNIFICADA_TESTES_V12_0203.md` | Este documento | Em criação |

### 06.3 Decomposição por camada documental

- **Camada de padrão.** `docs/testes/00_MODELO_DOCUMENTAL_DOS_TESTES.md`
  estabelece o contrato narrativo mínimo: leitura, matriz,
  decomposição em blocos, catálogo com pré-condição/ação/resultado/
  razão. Este é o dicionário oficial de toda documentação de teste
  futura.
- **Camada de evidência.** `docs/testes/01_EVIDENCIAS_E_RELATORIOS_DE_TESTE.md`
  explica a separação entre `RESULTADO_QA_V2` (última execução) e
  `HISTORICO_QA_V2` (trilha cumulativa), e explicita por que a
  `AUDIT_LOG` pós-execução só reflete o último cenário (efeito
  colateral do reset determinístico). Esse documento é o que impede
  que uma nova IA "conserte" o reset como se fosse um bug.
- **Camada de catálogo.** `docs/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md`
  é a primeira aplicação completa do padrão narrativo. Ele serve como
  referência para a documentação futura de toda a bateria.
- **Camada de auditoria institucional.** A família `auditoria/*.md`
  preserva a memória pública do projeto — fechamento de backlog,
  parecer de licenciamento, auditoria positiva e, agora, esta
  auditoria unificada.

### 06.4 Lacunas documentais

- **Catálogo narrado da Bateria Oficial V1.** Hoje existem 2.409
  linhas de VBA em `Teste_Bateria_Oficial.bas` sem equivalente em
  prosa canônica. A proposta da seção 07 endereça isso.
- **Catálogo narrado da família Smoke V2.** Os cenários `SMK_001`
  a `SMK_007` estão descritos em comentários de código, mas não em
  padrão narrativo. Devem ser documentados.
- **Catálogo narrado dos cenários assistidos.** UI Guiado e Roteiro
  Rápido V1 precisam de leitura humana explícita para auditoria.

### 06.5 Razão de elevar a documentação

O valor marginal da documentação para cada cenário escrito cresce à
medida que a bateria amadurece. Um projeto com 20 cenários pode se
dar ao luxo de documentar por comentário de código; um projeto com
150 cenários (aproximadamente o tamanho atual do conjunto V1 + V2)
precisa de prosa auditável.

## 07. Proposta de padronização documental

### 07.1 Leitura da proposta

A proposta desta seção é **cristalizar o padrão narrativo canônico de
`docs/testes/00_*.md` como contrato universal de documentação**, e
criar três novos documentos em `docs/testes/` para fechar o inventário.

### 07.2 Matriz da padronização

| Documento proposto | Conteúdo | Escopo |
|---|---|---|
| `docs/testes/02_CATALOGO_BATERIA_OFICIAL_V1.md` | Narrativa canônica dos blocos BO_* (preparação, setup, rodízio, inativação, fluxo completo, expansão, regressão técnica) | V1 inteira |
| `docs/testes/03_CATALOGO_SMOKE_V2.md` | Narrativa canônica dos `SMK_*`, `EXP_*`, `ATM_*`, `MIG_*`, `MUT_*` | Smoke V2 |
| `docs/testes/04_CATALOGO_ASSISTIDOS.md` | Narrativa canônica de UI-01 a UI-10 e P01 a P16 | Assistidos |

### 07.3 Decomposição do padrão narrativo canônico

Cada cenário, em qualquer família, será escrito com as mesmas cinco
rubricas:

- **Pré-condição.** Estado inicial assumido, em dicionário da matriz
  de estados (seção 02 do documento de proposta canônica).
- **Ação.** Uma única ação primária nomeada (do dicionário de ações
  dos roteiros V2), sem efeito colateral escondido.
- **Resultado esperado.** Lista de asserções explícitas sobre tabelas,
  eventos de auditoria e estado das empresas.
- **Razão.** Qual regra de negócio o cenário prova, qual regressão ele
  impede e por que a escolha do cenário.
- **Campos opcionais.** Aba de evidência, relação com outros cenários
  da mesma família, fatia do `Audit_Log` esperada.

### 07.4 Catálogo de adoção

**PD-01 — Adoção do padrão em `docs/testes/02_*.md`.**
Pré-condição: `Teste_Bateria_Oficial.bas` vigente na `V12.0.0202`.
Ação: escrever, em prosa canônica, todos os blocos `BO_*` — preparação,
setup canônico, rodízio, inativação/reativação, fluxo completo,
expansão de cinco ciclos, regressão técnica, matriz combinatória.
Resultado esperado: documento consolidado com ao menos um cenário por
bloco seguindo as cinco rubricas; tabela de rastreabilidade
bloco → regra → arquivo VBA.
Razão: transforma 2.409 linhas de código em leitura auditável.

**PD-02 — Adoção do padrão em `docs/testes/03_*.md`.**
Pré-condição: `Teste_V2_Roteiros.bas` vigente.
Ação: narrar `SMK_001` a `SMK_007`, `EXP_001`, `ATM_001`, `MIG_001` a
`MIG_004`, `MUT_001`, `ASS_002` com as cinco rubricas.
Resultado esperado: documento fecha o inventário narrado dos cenários
V2 — o canônico `CS_*` já está coberto pela proposta existente.
Razão: uniformiza o vocabulário entre Smoke, Canônico e Stress.

**PD-03 — Adoção do padrão em `docs/testes/04_*.md`.**
Pré-condição: `Teste_UI_Guiado.bas` e `Teste_Roteiro.bas` vigentes.
Ação: narrar UI-01 a UI-10 e P01 a P16 com ênfase em **verificação
humana** — a rubrica "ação" aqui é um roteiro de clique; "resultado
esperado" é a reação visual.
Resultado esperado: documento explicita que esses cenários não são
prova automática de regra, mas cartão de embarque de homologação.
Razão: impede que alguém confunda teste assistido com teste
automatizado.

**PD-04 — Índice ampliado em `docs/testes/INDEX.md`.**
Pré-condição: PD-01, PD-02 e PD-03 concluídos.
Ação: atualizar o índice para apontar os três novos catálogos.
Resultado esperado: portal completo de leitura humana da bateria.
Razão: fechamento simbólico do inventário.

### 07.5 Razão de padronizar agora

Padronizar a documentação **antes** de ampliar a bateria é a ordem
correta. Se a ampliação vier primeiro, o vocabulário se fragmenta; se
o padrão vier primeiro, cada novo cenário já nasce catalogável.

## 08. Catálogo estruturado dos cenários atuais

### 08.1 Leitura do catálogo atual

Esta seção lista, com curadoria mínima, o que já existe na bateria — em
padrão narrativo canônico, mesmo que comprimido. Ela substitui a
obrigação do auditor externo de ler três arquivos `.bas` para entender
o que o projeto já faz.

### 08.2 Matriz por família

| Família | Cenários catalogados | Cobertura do modelo |
|---|---|---|
| Bateria Oficial V1 | BO_000 (preparação), BO_100 (setup), BO_300 (rodízio núcleo), BO_400 (fluxo completo), BO_500 (expansão e regressão) | 100% das regras R-01 a R-59 que são do núcleo V1 |
| Smoke V2 | SMK_001 a SMK_007 | saúde da baseline |
| Canônico V2 | CS_00 a CS_22 | núcleo semântico |
| Stress V2 | STR_001 | invariantes de fila em execução longa |
| Atomicidade V2 | ATM_001 | rollback transacional |
| Expiração V2 | EXP_001 | Pre-OS expirada e retomada |
| Migração V2 | MIG_001 a MIG_004 | guardas de serviços migrados |
| Mutabilidade V2 | MUT_001 | não-mutação em leituras |
| Assistidos V2 | ASS_002 | inspeção humana determinística |
| UI Guiado | UI-01 a UI-10 | reação visual |
| Roteiro Rápido V1 | P01 a P16 | homologação humana linear |

### 08.3 Decomposição por bloco da Bateria Oficial V1

**Bloco de preparação (BO_000–BO_099).**
Pré-condição: workbook aberto com macros habilitadas.
Ação: zerar `EMPRESAS`, `ENTIDADE`, `CREDENCIADOS`, `PRE_OS`, `CAD_OS`,
`AUDIT_LOG`, `RESULTADO_QA`.
Resultado esperado: abas operacionais limpas; nenhum resíduo de
execução anterior.
Razão: é o ponto zero do determinismo.

**Bloco de setup canônico (BO_100–BO_199).**
Pré-condição: preparação concluída.
Ação: cadastrar atividades, serviços, entidades e empresas básicas;
credenciar empresas em atividades.
Resultado esperado: base mínima de cadastro completa; posições de
fila inicializadas.
Razão: estabelece o chão comum do restante da bateria.

**Bloco de rodízio (BO_300–BO_399).**
Pré-condição: setup canônico pronto.
Ação: emitir múltiplas Pré-OS em sequência; simular recusas,
expirações, pendências.
Resultado esperado: ordem de seleção reproduz regras R-01 a R-11;
`AvancarFila` chamado nos pontos corretos; `Audit_Log` registra cada
seleção.
Razão: cobre o núcleo do `Svc_Rodizio`.

**Bloco de inativação/reativação (BO_200–BO_299).**
Pré-condição: setup canônico.
Ação: inativar empresa e entidade; reativar; repetir em ordem
diferente.
Resultado esperado: `STATUS_GLOBAL` alternado corretamente; posição
preservada ao reativar; `Audit_Log` registra cada transição.
Razão: impede regressão histórica de "empresa reaparece errada após
reativação".

**Bloco de fluxo completo (BO_400–BO_499).**
Pré-condição: setup canônico.
Ação: Pré-OS → Aceite → OS → Conclusão → Avaliação, com notas variadas.
Resultado esperado: todas as transições de estado acontecem; nota
baixa produz suspensão automática; nota suficiente não suspende;
`Audit_Log` registra cada evento.
Razão: cobre o caminho ponta a ponta do negócio.

**Bloco de expansão (BO_500–BO_510).**
Pré-condição: fluxo completo concluído.
Ação: executar cinco ciclos completos em sequência; exercitar matriz
combinatória de filtros A a E.
Resultado esperado: fila rotaciona cinco vezes sem travamento;
invariantes preservadas em cada ciclo.
Razão: teste de vida clássico da V1, equivalente ao CS_17 da V2.

### 08.4 Decomposição por cenário do núcleo Smoke V2

**SMK_001 — Emissão nominal básica.**
Pré-condição: reset V2 + setup canônico mínimo.
Ação: emitir Pré-OS em atividade canônica.
Resultado esperado: empresa escolhida é a primeira da fila; evento
`RODIZIO_INDICOU`.
Razão: prova que o motor V2 foi bem inicializado.

**SMK_002 a SMK_006 — Variações diretas.**
Cobrem aceite, recusa, expiração, conversão em OS, conclusão.

**SMK_007 — Fechamento com auditoria mínima (reforçado).**
Pré-condição: fluxo completo em andamento.
Ação: concluir OS com nota suficiente; registrar avaliação.
Resultado esperado: `Audit_Log` tem `OS_Fechada`, `Avaliada`;
`STATUS_GLOBAL` continua ativa; `DT_FIM_SUSP` permanece nula.
Razão: prova a ausência de suspensão indevida em fechamento feliz.

**EXP_001 — Pré-OS expirada e retomada da fila.**
Pré-condição: Pré-OS criada, prazo vencido.
Ação: expirar explicitamente; emitir nova Pré-OS.
Resultado esperado: empresa afetada volta a ser tratada; fila
preserva integridade; nova indicação é a próxima apta por posição.
Razão: impede regressão de "empresa fica presa em Pré-OS pendente".

**ATM_001 — Rollback transacional.**
Pré-condição: transação aberta em cenário crítico.
Ação: injetar falha na metade da escrita.
Resultado esperado: nenhum estado parcial; rollback completo;
`Audit_Log` registra tentativa abortada.
Razão: prova a camada de `Svc_Transacao`.

### 08.5 Catálogo canônico V2 consolidado

O catálogo `CS_00` a `CS_22` está em `docs/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md`,
seção 4. Esta auditoria **não duplica** essa descrição; considera-a
adotada como padrão e incorporada por referência. A cobertura
obrigatória é CS_00 a CS_08, CS_11, CS_13, CS_14, CS_16, CS_17,
CS_18, CS_20, CS_21, CS_22 (18 cenários); complementares CS_09,
CS_10, CS_12 e CS_15 (4 cenários). Descartes por redundância
estão enumerados na seção 5.3 daquela proposta.

### 08.6 Razão do catálogo consolidado

Ter um único lugar onde se possa ver, por família, os cenários
disponíveis é o que transforma a bateria de "conjunto de scripts" em
"bateria auditável". A sequência das seções 07 e 08 deste documento
estabelece o ponto de partida dessa consolidação.

## 09. Proposta de novos cenários (ampliação incremental)

### 09.1 Leitura da proposta

A ampliação proposta nesta seção **não inventa família nova**. Ela
fecha a lacuna remanescente identificada na seção 04 e amplia cenários
existentes, conforme o plano já executável em `auditoria/20_*.md`. O
objetivo agora é consolidar arquitetura, comparação entre famílias e
evidência cumulativa sem inflar o catálogo.

### 09.2 Matriz de ampliação

| Código | Família | Tipo | Regra(s) cobertas | Critério de pronto |
|---|---|---|---|---|
| NV-01 | V2 Canônico | entregue | R-31, R-32, R-43 | `CS-18` rejeita mutações inválidas e protege o registro de avaliação |
| NV-02 | V2 Canônico | entregue | R-57 | `CS-21` valida presença mínima das famílias críticas no `Audit_Log` |
| NV-03 | V2 Canônico | entregue | R-58 complementa, R-59 reforça | `CS-23` e `CS-24` fecham ida e volta de inativação/reativação de empresa e entidade |
| AM-01 | Smoke V2 | ampliação | R-36, R-50, R-54 | `SMK_007` valida contagem de avaliações + ausência de suspensão indevida (já incorporado) |
| AM-02 | V2 Atomicidade | ampliação | R-47, R-49 | `ATM_001` valida ausência de mutação em mais de uma aba + mensagem legível de rollback |
| AM-03 | V2 Stress | ampliação | R-08, R-10, R-11 | `STR_001` valida ausência de duplicidade e posições estritamente crescentes |

### 09.3 Decomposição por cenário novo

**NV-01 — Transições inválidas de OS concluída.**
Pré-condição: base canônica + OS concluída com avaliação registrada.
Ação: tentar reavaliar; tentar marcar a OS como aberta; tentar
registrar nova avaliação.
Resultado esperado: `Sucesso = False` em todas as tentativas; estado
da OS permanece `CONCLUIDA`; estado da avaliação inalterado;
`Audit_Log` registra `VALIDACAO_REJEITADA` por tentativa.
Razão: já implementado por `CS-18`; permanece aqui como regra
institucional consolidada, não como backlog.

**NV-02 — Completude do `Audit_Log` por família de evento.**
Pré-condição: execução completa do fluxo nominal (CS-03 → CS-08).
Ação: consolidar os eventos gravados.
Resultado esperado: presença mínima esperada de cada tipo crítico
(`RODIZIO_INDICOU`, `OS_EMITIDA`, `OS_CONCLUIDA`, `AVALIACAO_REGISTRADA`,
`SUSPENSAO_POR_NOTA` quando aplicável); asserção por tipo, não por
contagem bruta.
Razão: já implementado por `CS-21`; prova que a auditoria não perde
categorias.

**NV-03 — Inativação/reativação de empresa e entidade.**
Pré-condição: base canônica limpa.
Ação: executar `CS-23` para ida e volta de empresa e `CS-24` para ida
e volta de entidade, ambos com reaproveitamento do item canônico.
Resultado esperado: `STATUS_GLOBAL` e `POSICAO_FILA` preservados na
empresa; emissão bloqueada e retomada corretamente na entidade; sem
reaparição de registro semântico incorreto; `Audit_Log` registra cada
transição com diferenciação entre empresa e entidade.
Razão: já implementado por `CS-23` e `CS-24`; fecha a regressão
histórica da série `0193` sem reabrir a fragilidade do `Mod_Types`.

### 09.4 Decomposição das ampliações

**AM-01 — `SMK_007` reforçado (já incorporado na branch `0203`).**
Pré-condição: OS aberta e pronta para conclusão com nota suficiente.
Ação: concluir OS; registrar avaliação.
Resultado esperado: evento `OS_Fechada` em `Audit_Log`; evento
`Avaliada` em `Audit_Log`; `STATUS_GLOBAL` da empresa permanece
ativa; `DT_FIM_SUSPENSAO` permanece nula.
Razão: prova que o fechamento feliz não produz suspensão indevida.

**AM-02 — `ATM_001` ampliado (já incorporado na linha `0203`).**
Pré-condição: transação aberta em cenário de Pré-OS → OS.
Ação: injetar falha após mutação parcial em mais de uma aba
operacional.
Resultado esperado: rollback completo; ausência de mutação residual
em `EMPRESAS` e `CREDENCIADOS`; quantidade do item canônico
preservada; mensagem de rollback legível no retorno e em
`Audit_Log`.
Razão: prova que a atomicidade não é ilusória em escrita multi-aba.

**AM-03 — `STR_001` ampliado.**
Pré-condição: base canônica + múltiplos ciclos.
Ação: executar N ciclos mistos (emissão, recusa, expiração,
conclusão) em sequência.
Resultado esperado: nenhum ID duplicado em `PRE_OS`, `CAD_OS` ou
`CREDENCIADOS`; contagem final de itens coerente; posições na fila
estritamente crescentes e únicas.
Razão: robustece a invariante estrutural contra execução prolongada.

### 09.5 Ordem recomendada

A ordem proposta é: NV-01 → NV-02 → AM-01 (já incorporado) → AM-03 →
NV-03 → AM-02. Essa ordem segue a Sprint 2 (seção 15 deste documento)
e prioriza lacunas semânticas (OS concluída, auditoria) antes de
lacunas estruturais (ampliação de stress e atomicidade).

### 09.6 Razão da ampliação incremental

Ampliar é barato **porque o padrão narrativo já existe**. Cada cenário
novo herda pré-condição, dicionário de ações e tabela de asserções da
proposta canônica. O custo marginal por cenário novo é essencialmente
o custo de escrever a função VBA — a documentação se escreve quase
sozinha.

## 10. Análise da interface de execução dos testes

### 10.1 Leitura da interface

O operador humano entra em contato com a bateria por **duas centrais
distintas**: a `Central_Testes` (V1 tradicional) e a `Central_Testes_V2`
(suíte nova). Essa separação tem valor — ela reflete vocabulários
diferentes — mas também impõe custo cognitivo: o operador precisa saber
onde começar e precisa lembrar a diferença entre "bateria oficial" e
"suíte determinística".

### 10.2 Matriz da interface

| Central | Opções principais | Público-alvo | Evidência |
|---|---|---|---|
| `Central_Testes` | Bateria Oficial V1 (rápida / assistida), Roteiro Rápido, UI Guiado, CHECKLIST 136, Relatórios, Limpeza | Homologador humano, auditor funcional | `RESULTADO_QA`, `ROTEIRO_RAPIDO`, `CHECKLIST_136`, `RPT_*` |
| `Central_Testes_V2` | Smoke rápido, Smoke assistido, Canônico, Stress, Atomicidade, Expiração, Todos, Catálogo, Abrir evidência | Mantenedor técnico, auditor de código | `RESULTADO_QA_V2`, `HISTORICO_QA_V2`, `CATALOGO_CENARIOS_V2`, `ROTEIRO_ASSISTIDO_V2`, `RPT_TESTES_V2` |

### 10.3 Decomposição do custo cognitivo

- **Duas portas de entrada.** O operador abre o workbook e escolhe
  qual central usar. Não há portal único que explique "para homologar
  use V1, para regressão técnica use V2".
- **Vocabulários diferentes.** "Bateria oficial" (V1) vs. "Suíte
  canônica" (V2). O vocabulário é consistente dentro de cada central,
  mas não entre elas.
- **Dupla confirmação na V1.** A `CT_IniciarBateria` exige duas
  confirmações, o que protege contra execução acidental, mas ninguém
  documenta por quê.
- **Limpeza opcional desacoplada.** A limpeza `CT_LimparArtefatosTesteV1`
  (e a versão ampliada para V2/snapshots) é um item de menu
  independente, não parte da bateria. Isso é correto (separa limpeza
  de execução), mas pode confundir.

### 10.4 Catálogo de atritos observados

**AT-01 — Ausência de portal único.**
Pré-condição: operador novo abre o workbook.
Ação: tentar rodar "a bateria".
Resultado observado: operador descobre que existem duas centrais e
precisa decidir qual. Fricção de aprendizado.
Razão: `docs/testes/INDEX.md` já cobre parcialmente. Falta o espelho
na interface do workbook.

**AT-02 — Nomes assimétricos nos menus.**
Pré-condição: operador experimenta as duas centrais.
Ação: comparar opções.
Resultado observado: "Rápida" e "Assistida" na V1, "Rápido" e
"Assistido" na V2 — vocabulário alinhado por sorte, não por
governança.
Razão: o padrão precisa ser explícito.

**AT-03 — Ausência de atalho para relatório consolidado.**
Pré-condição: execução completa das duas suítes.
Ação: procurar um relatório único.
Resultado observado: `RPT_CONSOLIDADO` existe, mas precisa ser aberto
manualmente. Não há botão no fluxo natural que o gere e o abra em
sequência.
Razão: oportunidade de melhoria simples.

**AT-04 — Confirmação dupla sem explicação.**
Pré-condição: primeira vez rodando a bateria V1.
Ação: ver duas caixas de confirmação.
Resultado observado: fricção, dúvida sobre o que se está confirmando.
Razão: `MsgBox` precisa de texto com mais contexto institucional.

### 10.5 Razão de tratar a interface como parte da bateria

A interface é o ponto de entrega do teste ao operador humano. Uma
bateria excelente com interface fria vira uma bateria que ninguém
usa. Incluir a interface nesta auditoria é um reconhecimento de que
qualidade de teste inclui usabilidade de teste.

## 11. Proposta de design e unificação da interface de testes

### 11.1 Leitura da proposta

A proposta desta seção **não elimina as duas centrais**. Ela cria um
portal comum (`Central_Testes_Portal`) que encaminha para a central
correta, padroniza vocabulário e adiciona os atalhos que faltam.

### 11.2 Matriz do redesign

| Elemento | Estado atual | Proposta |
|---|---|---|
| Portal único | ausente | novo módulo `Central_Testes_Portal` chamando V1 e V2 com texto explicativo |
| Vocabulário | alinhado por sorte | dicionário único publicado em `docs/testes/05_DICIONARIO_INTERFACE.md` |
| Confirmação dupla | texto curto | texto curto + link para `docs/testes/01_*.md` |
| Botão consolidado | ausente | novo botão "Consolidar e abrir relatório" em cada central |
| Limpeza | opcional em menu separado | mantida como está, mas com aviso de escopo (V1 / V2 / snapshots) |

### 11.3 Decomposição do portal único

**PT-01 — Módulo `Central_Testes_Portal`.**
Pré-condição: `Central_Testes` e `Central_Testes_V2` vigentes.
Ação: criar novo módulo que exiba um menu com duas opções principais
("Bateria Oficial V1 — homologação" e "Suíte V2 — regressão técnica"),
cada uma encaminhando para a central correspondente.
Resultado esperado: operador tem ponto de entrada único com texto
institucional; as centrais antigas permanecem funcionais e
independentes.
Razão: elimina a fricção inicial sem quebrar o fluxo de quem já
conhece o sistema.

**PT-02 — Texto institucional no portal.**
Pré-condição: portal criado.
Ação: incluir descrição curta de cada central (para quem serve, em
que momento usar).
Resultado esperado: operador novo entende em 10 segundos qual
caminho escolher.
Razão: reduz carga cognitiva.

**PT-03 — Atalho para consolidado.**
Pré-condição: execução completa das duas suítes.
Ação: incluir botão "Consolidar e abrir relatório" em cada central
que dispare `CT_GerarConsolidado` + `CT_AbrirRelatorio`.
Resultado esperado: consolidação em um clique; relatório abre em aba
dedicada.
Razão: fecha o ciclo de homologação sem navegação lateral.

### 11.4 Catálogo de microajustes

**MA-01 — Enriquecer texto da confirmação dupla.**
Pré-condição: `CT_IniciarBateria` vigente.
Ação: ampliar texto do `MsgBox` para citar "esta execução irá
reconstruir a base operacional e levará aproximadamente X minutos".
Resultado esperado: operador sabe o que se está aceitando.
Razão: transparência institucional.

**MA-02 — Padronizar vocabulário de menus.**
Pré-condição: dicionário publicado em `docs/testes/05_*.md`.
Ação: revisar rótulos de ambas as centrais para usar exatamente os
termos do dicionário.
Resultado esperado: "Rápida" significa a mesma coisa nas duas
centrais; "Assistida" idem.
Razão: rigor semântico.

**MA-03 — Aviso de escopo na limpeza.**
Pré-condição: `CT_LimparArtefatosTesteV1` e variante ampliada.
Ação: incluir `MsgBox` que explicite o que será apagado (V1, V2,
snapshots `SNAPV2_*`).
Resultado esperado: operador tem clareza antes de confirmar.
Razão: proteção contra apagamento acidental.

### 11.5 Razão da proposta

O redesign proposto é conservador: não elimina nada, não renomeia
nada de forma disruptiva, e faz o atrito observado sumir em cinco ou
seis entregas pequenas. É o tipo de melhoria que cabe em um único
sprint e rende valor imediato.

## 12. Análise de unificação V1 e V2

### 12.1 Leitura da unificação

A unificação de V1 e V2 é o ponto mais delicado desta auditoria. A
tentação natural é **unificar código** — fundir `Teste_Bateria_Oficial`
com `Teste_V2_Roteiros` em uma única suíte. Essa tentação deve ser
**recusada**. O que precisa ser unificado é o **vocabulário**, não o
código.

### 12.2 Matriz da unificação

| Dimensão | Estado atual | Proposta |
|---|---|---|
| Código | duas suítes independentes | permanecem independentes (V1 e V2) |
| Vocabulário | paralelo | unificado em dicionário canônico |
| Rastreabilidade | implícita | matriz explícita (seção 03 deste documento) |
| Execução | duas centrais | portal comum (seção 11) |
| Evidência | `RESULTADO_QA` + `RESULTADO_QA_V2` | continuam separadas; passam a apontar para dicionário único |

### 12.3 Decomposição da decisão

- **Por que não fundir código.** A V1 foi escrita em ordem histórica
  (blocos funcionais por ordem de criação); a V2 em ordem semântica
  (blocos por família de regra). Fundir os dois arquivos significa
  perder ou o histórico ou a taxonomia. Nenhuma das perdas vale a
  economia de duplicação.
- **Por que não apagar a V1.** A V1 é o que um auditor funcional
  humano reconhece como "bateria oficial". Apagá-la removeria o
  vínculo institucional com a leitura de release acumulada.
- **Por que não apagar a V2.** A V2 é o que sustenta a evolução
  determinística e auditável do modelo de negócio. Apagá-la
  congelaria a maturidade no patamar atual.
- **Por que unificar vocabulário.** Unificar vocabulário permite que
  um mesmo gestor, um mesmo auditor e uma mesma IA leiam V1 e V2 sem
  trocar de idioma. Permite, também, construir a matriz de
  rastreabilidade (seção 03) que prova "esta regra está coberta
  aqui e também ali".

### 12.4 Catálogo do dicionário canônico

**DI-01 — Vocabulário de estados.**
Estados de empresa (`ATIVA`, `INATIVA`, `SUSPENSA_GLOBAL`), estados
de suspensão (`MANUAL`, `NOTA_BAIXA`), estados de Pré-OS
(`AGUARDANDO_ACEITE`, `ACEITA`, `RECUSADA`, `EXPIRADA`, `CONVERTIDA_OS`),
estados de OS (`ABERTA`, `CONCLUIDA`), estados de avaliação
(`REGISTRADA`).
Razão: uma só fonte de verdade para o que cada estado significa.

**DI-02 — Vocabulário de ações.**
`EmitirPreOS`, `AceitarPreOS`, `RecusarPreOS`, `ExpirarPreOS`,
`EmitirOS`, `ConcluirOS`, `RegistrarAvaliacao`, `SuspenderEmpresa`,
`ReativarEmpresa`, `InativarEmpresa`, `ReativarEmpresaGlobal`,
`AvancarFila`.
Razão: uma só lista de verbos operacionais, aplicável a V1 e V2.

**DI-03 — Vocabulário de motivos.**
`SEM_CREDENCIADOS_APTOS`, `DUPLICIDADE_SERVICO`, `VINCULO_INVALIDO`,
`NOTA_BAIXA`, `PRE_OS_PENDENTE`, `OS_ABERTA`, `INATIVACAO_CADASTRAL`.
Razão: motivos de rejeição e bloqueio sem ambiguidade.

**DI-04 — Vocabulário de eventos de auditoria.**
`RODIZIO_INDICOU`, `RODIZIO_BLOQUEADO`, `RODIZIO_EXPIROU`,
`SUSPENSAO_MANUAL`, `SUSPENSAO_POR_NOTA`, `REATIVACAO_MANUAL`,
`REATIVACAO_AUTOMATICA`, `OS_EMITIDA`, `OS_CONCLUIDA`,
`AVALIACAO_REGISTRADA`, `VALIDACAO_REJEITADA`, `CADASTRO`,
`INATIVACAO`, `REATIVACAO`.
Razão: lista canônica contra a qual asserções de auditoria
(`CS-21`, completude mínima por família) são validadas.

### 12.5 Razão da unificação semântica

Unificar vocabulário entrega 80% do benefício da unificação real de
código, com 10% do custo. O resultado é uma bateria que **lê igual**
em V1 e em V2, sem forçar refatoração de arquivos que já provam a
sua função.

## 13. Proposta arquitetural de evolução

### 13.1 Leitura arquitetural

A evolução arquitetural proposta é composta por quatro peças
independentes entre si, mas que juntas elevam a bateria do patamar
atual para o patamar desejado. Cada peça pode ser entregue em sprint
separado.

### 13.2 Matriz da arquitetura alvo

| Peça | Onde vive | Objetivo |
|---|---|---|
| Trilha cumulativa dedicada aos testes | abas `TESTE_TRILHA` + `AUDIT_TESTES` | separar auditoria do negócio da auditoria da suíte |
| Comparador estrutural V1 × V2 | novo módulo `Teste_Comparador` | prova formal de que V1 e V2 não divergem em regra coberta por ambas |
| Helper `Svc_Avaliacao_Payload` | extração de `Menu_Principal.frm` | desacoplamento da interface |
| Orquestrador `Svc_Emissao` | extração de `Menu_Principal.frm` | centralização de emissão Pré-OS/OS sem dependência do formulário |

### 13.3 Decomposição peça a peça

**AR-01 — Trilha cumulativa dedicada (`TESTE_TRILHA` + `AUDIT_TESTES`).**
Pré-condição: motor V2 vigente.
Ação: gravar cada assert em `TESTE_TRILHA` e congelar o `AUDIT_LOG`
operacional de cada cenário em `AUDIT_TESTES`, preservando a
sequência cumulativa sem desativar o reset determinístico entre
cenários.
Resultado esperado: ao final de uma execução completa,
`TESTE_TRILHA` contém o "filme inteiro" da bateria e `AUDIT_TESTES`
contém o espelho operacional capturado por cenário; `AUDIT_LOG`
operacional continua refletindo apenas o último cenário por design.
Razão: remove o único ponto em que o determinismo custava
rastreabilidade. Nesta linha, AR-01 já foi antecipada e absorvida na
Sprint 2.

**AR-02 — Comparador estrutural (`Teste_Comparador`).**
Pré-condição: matriz de rastreabilidade publicada (seção 03).
Ação: criar módulo que, dado um par de cenários V1/V2 que cobrem a
mesma regra, compare as asserções extraídas de `RESULTADO_QA` e
`RESULTADO_QA_V2` e reporte divergências.
Resultado esperado: novo botão na central que emite
`RELATORIO_COMPARADOR` listando regra, cenário V1, cenário V2 e
diferença semântica (se houver).
Razão: elimina risco de "V1 passa e V2 falha na mesma regra" sem
ninguém perceber.

**AR-03 — Helper `Svc_Avaliacao_Payload`.**
Pré-condição: `Menu_Principal.frm` com montagem de avaliação.
Ação: extrair a função que monta o dicionário de avaliação (empresa,
OS, nota, observação, janela de suspensão) para um módulo puro com
entrada explícita e saída previsível.
Resultado esperado: formulário principal só coleta entrada; helper
devolve payload normalizado; testes V2 chamam o helper diretamente.
Razão: desacopla primeira fatia do formulário (é a frente C1 do
plano Sprint 2).

**AR-04 — Orquestrador `Svc_Emissao`.**
Pré-condição: helper AR-03 estável.
Ação: centralizar a orquestração de emissão de Pré-OS e OS em
serviço dedicado; o formulário passa a chamar serviço em vez de
operar `Svc_Rodizio`/`Svc_PreOS`/`Svc_OS` diretamente.
Resultado esperado: emissão testável sem formulário aberto;
comportamento de emissão auditável independente da UI.
Razão: é a frente C2 do plano Sprint 2.

Estado na `V12.0.0203`: primeira fatia já entregue sem criar módulo
novo. `Svc_PreOS` e `Svc_OS` passaram a montar/validar parâmetros
mínimos de emissão, e o `Menu_Principal` ficou restrito à seleção,
confirmação e impressão.

### 13.4 Catálogo de benefícios por peça

- **AR-01** fecha lacuna R-57, permite auditoria completa por
  execução e desbloqueia cenários novos que precisam de "memória
  entre cenários" (ex.: série de ciclos comparada como bloco único).
  Na linha `V12.0.0203`, esta peça já foi antecipada e entregue.
- **AR-02** transforma rastreabilidade em conformidade verificável,
  reduzindo o risco residual de divergência silenciosa entre suítes.
- **AR-03** é pré-requisito para ampliar o conjunto de cenários que
  não dependem de clique humano.
- **AR-04** é pré-requisito para a linha de evolução `V12.0.0204+`
  testar emissão sem acionar o formulário.

### 13.5 Razão da arquitetura alvo

A arquitetura alvo não é ruptura. É evolução incremental com quatro
entregáveis independentes. Cada um prova valor antes do próximo; a
ordem recomendada — AR-01 → AR-03 → AR-02 → AR-04 — alinha com a
Sprint 2 já publicada e com a Sprint 3 prospectada na seção 15.

## 14. Decisões metodológicas permanentes

### 14.1 Leitura das decisões permanentes

Esta seção é o coração institucional do documento. Ela lista as
escolhas que o projeto fez e que **não devem ser revertidas por
conveniência futura**. São as decisões que, se desfeitas, destroem o
valor da bateria. Qualquer IA futura que proponha revertê-las precisa
documentar por escrito a razão em um novo documento de auditoria.

### 14.2 Matriz das decisões permanentes

| Decisão | Onde vive | Consequência de reverter |
|---|---|---|
| Reset determinístico por cenário na V2 | `TV2_ResetBaseOperacional` | retorno da contaminação cruzada; perda de reprodutibilidade |
| CSV automático apenas em caso de falha | Bateria V1 + V2 | volta do ruído em execuções verdes |
| Separação resultado/evidência | `RESULTADO_QA_V2` × `HISTORICO_QA_V2` | perda da trilha cumulativa ou da leitura da última execução |
| Asserção explícita obrigatória | motor V2 | retorno do teste-smoke-verde-por-acidente |
| Duas centrais de testes separadas | `Central_Testes` + `Central_Testes_V2` | perda da distinção entre homologação funcional e regressão técnica |
| Documentação humana paralela obrigatória | `docs/testes/` | perda do acesso auditável sem leitura de VBA |
| Padrão narrativo canônico como contrato | `docs/testes/00_*.md` | fragmentação do vocabulário da bateria futura |
| Matriz de rastreabilidade regra × cenário | seção 03 deste documento | retorno da cobertura implícita (e, portanto, insondável) |
| Limpeza opcional desacoplada da bateria | `CT_LimparArtefatosTesteV1` (e variantes) | risco de apagamento acidental durante execução |
| Unificação apenas semântica entre V1 e V2 | dicionário canônico + centrais separadas | perda da maturidade histórica da V1 ou da evolução determinística da V2 |

### 14.3 Decomposição das razões de permanência

- **Reset determinístico.** É a decisão que separa teste real de teste
  cosmético. Nenhuma alegação de "economia de tempo de execução"
  justifica reverter.
- **CSV em falha.** Execuções verdes devem ser silenciosas. CSV é
  sinal; ruído mata sinal.
- **Resultado × evidência.** A última execução e a trilha cumulativa
  respondem a perguntas diferentes. Juntá-las é perda semântica.
- **Asserção explícita.** Um cenário sem asserção é um cenário que
  testa se o código compila, não se ele funciona.
- **Duas centrais.** Homologação funcional e regressão técnica são
  atividades diferentes com públicos diferentes. Fundir centrais é
  perder essa distinção.
- **Documentação paralela.** Um projeto que exige leitura de VBA para
  ser auditado falhou em sua responsabilidade institucional.
- **Padrão narrativo.** Cada desvio do padrão fragmenta o vocabulário
  e torna a bateria mais difícil de evoluir.
- **Matriz de rastreabilidade.** Sem matriz, "cobertura" vira
  declaração de fé.
- **Limpeza desacoplada.** Um comando destrutivo nunca deve estar na
  rota principal de execução.
- **Unificação semântica.** Unificar código entregaria economia
  local, com custo de perda semântica global.

### 14.4 Razão de registrar isto aqui

Sem este registro, cada nova geração de mantenedores (ou cada nova
IA colaboradora) chega ao projeto com o impulso natural de
"simplificar". A simplificação é bem-vinda quando preserva o método;
é destrutiva quando o sacrifica. Este documento é o freio explícito
contra a segunda.

## 15. Plano de evolução em sprints

### 15.1 Leitura do plano

O plano de evolução cobre as três sprints seguintes à `V12.0.0202`:
**Sprint 2 (em execução)**, **Sprint 3 (prospecto)** e **Sprint 4
(prospecto)**. Cada sprint entrega valor publicável como evidência
independente; nenhuma depende do encerramento da anterior para gerar
benefício.

### 15.2 Matriz consolidada por sprint

| Sprint | Frente | Entregáveis | Critério de saída |
|---|---|---|---|
| 2 (vigente) | Testes + desacoplamento | A0 família `CS_*`, A1 `EXP_001`, A2 transições inválidas, A4 `Audit_Log` completo, AR-01 trilha cumulativa, B1 `SMK_007` reforçado, B3 `STR_001` ampliado, C1 extração de payload de avaliação | família canônica verde, trilha cumulativa vigente, 1 fatia fora do formulário |
| 3 (prospecto) | Arquitetura | AR-02 comparador V1×V2, AR-03 helper avaliação (conclusão C1) | comparador gera relatório assinável e helper reduz dependência do formulário |
| 4 (prospecto) | Unificação semântica | PD-01, PD-02, PD-03, PD-04, DI-01 a DI-04, PT-01 a PT-03 | `docs/testes/` fechado, portal único, dicionário publicado |

### 15.3 Decomposição da Sprint 2 (em execução)

**Frente A — Novos cenários.**
A0 (família canônica `CS_*`): primeiro lote `CS_00`–`CS_08` já
executável; segundo lote `CS_11`, `CS_13`, `CS_14`, `CS_16`, `CS_20`
já validado; terceiro lote `CS_17` já validado; `CS_18` e `CS_21`
já fecham, respectivamente, transições inválidas e completude do
`Audit_Log`. Resta consolidar manifesto e evidência para release.
A1 (`EXP_001`): já incorporado.
A2 (transições inválidas de OS concluída — NV-01 desta auditoria):
entregue por `CS_18`.
A4 (completude do `Audit_Log` — NV-02): entregue por `CS_21`.

**Frente AR — Trilha cumulativa.**
AR-01 (`TESTE_TRILHA` + `AUDIT_TESTES`): já incorporada na Sprint 2.
Ela antecipa parte da antiga Sprint 3 e resolve o problema de
preservar a narrativa cumulativa da execução sem violar o reset
determinístico da `AUDIT_LOG` operacional.

**Frente B — Ampliação de cenários existentes.**
B1 (`SMK_007` reforçado — AM-01): incorporado.
B3 (`STR_001` ampliado — AM-03): incorporado com checagem explícita de IDs canônicos, quantidade final do item e posições crescentes.
B2 (`ATM_001` ampliado — AM-02): incorporado com checagem explícita de ausência de mutação residual em `EMPRESAS` e `CREDENCIADOS`, preservação da contagem do item canônico e mensagem legível de rollback.

**Frente C — Desacoplamento da interface.**
C1 (helper avaliação — AR-03): primeira extração incorporada;
normalização das notas e montagem do payload já saíram parcialmente de `Menu_Principal.frm`.
C2 e C3 (orquestrador de emissão, relatórios): prospectados na
Sprint 3.

**Critério de saída da Sprint 2.** O critério já está publicado em
`auditoria/20_*.md` (seção "Critério de saída da Sprint 2") e deve
ser reproduzido aqui por referência: família `CS_*` verde e
determinística, `NV-01` e `NV-02` absorvidos, trilha cumulativa
vigente, V1 e V2 verdes e pelo menos uma fatia concreta de lógica
saindo do formulário principal.

### 15.4 Decomposição da Sprint 3 (prospecto)

**Objetivo.** Entregar a arquitetura alvo descrita na seção 13 deste
documento.

**Entregáveis principais.**

- AR-01: trilha cumulativa (`TESTE_TRILHA` + `AUDIT_TESTES`).
  Critério de pronto: execução completa preenche a trilha; executor
  não precisa reconstruir trilha a partir de `RESULTADO_QA_V2` +
  `HISTORICO_QA_V2` para auditoria por família de evento.
- AR-02: comparador estrutural V1 × V2. Critério de pronto:
  relatório `RELATORIO_COMPARADOR` é gerado ao final da execução das
  duas suítes e aponta divergências (ou ausência delas).
- AR-03: helper `Svc_Avaliacao_Payload` concluído. Critério de
  pronto: `Menu_Principal.frm` não contém mais montagem de avaliação;
  o payload é testável isoladamente.
- Ampliação AM-02 (`ATM_001` multi-aba + mensagem legível) incorporada.

**Critério de saída da Sprint 3.** Trilha cumulativa vigente;
comparador produz relatório assinável; primeira fatia grande do
formulário removida.

### 15.5 Decomposição da Sprint 4 (prospecto)

**Objetivo.** Cristalizar a unificação semântica descrita nas seções
11 e 12 deste documento.

**Entregáveis principais.**

- PD-01: `docs/testes/02_CATALOGO_BATERIA_OFICIAL_V1.md` escrito.
- PD-02: `docs/testes/03_CATALOGO_SMOKE_V2.md` escrito.
- PD-03: `docs/testes/04_CATALOGO_ASSISTIDOS.md` escrito.
- PD-04: `docs/testes/INDEX.md` ampliado.
- DI-01 a DI-04: dicionário canônico publicado em
  `docs/testes/05_DICIONARIO_INTERFACE.md`.
- PT-01 a PT-03: portal comum `Central_Testes_Portal` publicado.
- MA-01 a MA-03: microajustes de texto e escopo.

**Critério de saída da Sprint 4.** Documentação humana da bateria
fechada (V1, V2 e assistidos); dicionário único publicado; portal
comum vigente; microajustes incorporados.

### 15.6 Catálogo de riscos de cronograma

**RC-01 — Atraso na frente C (desacoplamento).**
A frente C depende de disponibilidade de janelas de refatoração no
formulário principal. Risco mitigado por tamanho pequeno de cada
fatia.

**RC-02 — Variação de escopo na AR-01.**
A trilha cumulativa pode gerar expectativa de "trilha que substitui
`AUDIT_LOG` operacional". A Sprint 3 deve documentar claramente que
AR-01 é **adicional**, não substitutiva.

**RC-03 — Explosão de escopo na Sprint 4.**
A padronização documental pode levar à tentação de revisar
retroativamente cenários antigos. A Sprint 4 deve restringir-se a
catalogar o que já existe, não refatorar testes.

### 15.7 Razão do plano em três sprints

A divisão em três sprints respeita o ritmo histórico do projeto: cada
sprint tem entregável independente, cada entregável vira release
pública com evidência. Nenhum sprint depende de outro para ter valor,
o que preserva a opção de replanejamento sem perda.

## Apêndice A — Referências cruzadas

| Referência | Papel |
|---|---|
| `CHANGELOG.md` | rastro público da evolução entre `V12.0.0202` e `V12.0.0203` |
| `auditoria/00_SUMARIO_EXECUTIVO.md` | status executivo da linha oficial |
| `auditoria/03_AUDITORIA_REGRAS_DE_NEGOCIO.md` | regras R-01 a R-59 catalogadas |
| `auditoria/04_MATRIZ_MESTRE_DE_TESTES.md` | camadas públicas de teste |
| `auditoria/17_PARECER_LICENCIAMENTO_TPGL_v1_1.md` | licença pública e CLA |
| `auditoria/18_AUDITORIA_PUBLICACAO_OFICIAL_V12_0202.md` | auditoria de publicação |
| `auditoria/19_AUDITORIA_PONTOS_FORTES_V12_0202.md` | auditoria positiva |
| `auditoria/20_PLANO_SPRINT_2_TESTES_E_DESACOPLAMENTO_V12_0203.md` | backlog executável da Sprint 2 |
| `docs/testes/INDEX.md` | portal de leitura humana |
| `docs/testes/00_MODELO_DOCUMENTAL_DOS_TESTES.md` | padrão narrativo canônico |
| `docs/testes/01_EVIDENCIAS_E_RELATORIOS_DE_TESTE.md` | regras de evidência |
| `docs/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md` | catálogo `CS_00`–`CS_22` |

## Apêndice B — Dicionário mínimo para o leitor novo

- **Bateria Oficial V1.** Suíte histórica escrita em blocos
  temáticos; reconhecível pelo auditor funcional; critério mínimo de
  release.
- **Suíte V2.** Suíte determinística com reset canônico por cenário;
  reconhecível pelo mantenedor técnico; baseline de evolução.
- **Testes assistidos.** Roteiros com validação visual humana; UI
  Guiado (UI-01 a UI-10) e Roteiro Rápido V1 (P01 a P16).
- **Cenário canônico (`CS_*`).** Cenário V2 que pertence ao catálogo
  formal aprovado em `docs/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md`.
- **Reset determinístico.** Reconstrução completa das abas
  operacionais antes de cada cenário V2, por `TV2_ResetBaseOperacional`.
- **Asserção explícita.** Chamada de `TV2_LogAssert` com condição e
  mensagem; não é opcional no motor V2.
- **Trilha cumulativa.** AR-01 entregue: abas `TESTE_TRILHA` +
  `AUDIT_TESTES`, preservando histórico de eventos da suíte inteira
  sem sofrer reset entre cenários.

## Fechamento

Este documento é a auditoria unificada dos testes na transição da
linha oficial `V12.0.0202` para a linha evolutiva `V12.0.0203`. Ele
registra o veredito, descreve o método, cataloga o que já existe,
propõe o que falta, explica por que as duas suítes convivem, desenha
o redesign da interface, cristaliza o dicionário canônico, endereça
o desacoplamento da interface operacional e entrega um plano de três
sprints para a evolução.

A bateria atual sustenta a release pública com prova automatizada. A
bateria da próxima release deve sustentar a mesma prova com mais
profundidade, menos ruído, e linguagem comum entre todas as suas
camadas. O material contido nas seções 00 a 15 é suficiente para que
um mantenedor humano ou uma IA futura executem essa evolução sem se
perder.
