---
titulo: Prestacao de Contas Tecnica Credenciamento Abril e Maio 2026 (Final)
diataxis: status
hbn-track: fast_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0205
data: 2026-06-18
---

# Prestação de Contas Técnica — Sistema de Credenciamento e Rodízio de Pequenos Reparos

**Período:** Abril e Maio de 2026
**Versão oficial final do período:** V12.0.0205
**Linha atual analisada:** V12.0.0206, em validação iterativa (sem freeze declarado)
**Evidência oficial principal:** `VR_20260523_215637`
**Data de consolidação deste documento:** 18 de junho de 2026

---

## 1. Resumo executivo

O Sistema de Credenciamento e Rodízio de Pequenos Reparos é a ferramenta que organiza, de forma justa e auditável, quais empresas estão aptas a atender pequenos reparos e em que ordem elas são chamadas. Ele cuida do cadastro das empresas, do rodízio de atendimento, da avaliação das ordens de serviço e das regras que penalizam, suspendem ou reativam um prestador conforme o seu desempenho.

Entre abril e maio de 2026, o sistema passou por quatro avanços principais. Primeiro, houve a estabilização funcional da linha V12.0.0203, com reforço de importação, reativação, strikes, filtros, auditoria e relatórios. Em seguida, a linha V12.0.0204 amadureceu com a ampliação das suítes de teste, regras de rollback, integridade de base e uma jornada humana de validação. O terceiro movimento foi o congelamento da V12.0.0205 como versão oficial validada de produção, com nomenclatura profissional de testes, evidências públicas e dossiê de release. Por fim, foi instituída a camada useHBN/HBN como protocolo de governança executável, com relay, readbacks, ERPs, base de conhecimento, guardas locais e verificação automática (CI) de governança.

A versão que ficou oficialmente validada no período é a **V12.0.0205**, com status VALIDADO/OFICIAL, tag `v12.0.0205` e build importado `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix`. Ela foi homologada pelo Gate de Validação de Release (RVS), com a evidência final `VR_20260523_215637`. A linha mais recente analisada, a **V12.0.0206**, está em validação iterativa e ainda não recebeu freeze — ela representa continuidade técnica, não substitui a V12.0.0205 como marco oficial do período.

Os testes e a governança aumentaram a confiabilidade porque transformaram verificações que antes eram manuais e pontuais em baterias repetíveis e em registros auditáveis. Quando uma regra de negócio, uma penalidade ou uma reativação passa a ter prova automatizada, e quando cada entrega deixa rastro de evidência, fica muito mais difícil que um erro silencioso chegue à produção sem ser percebido.

## 2. Explicação simples do sistema

Para quem não acompanha o lado técnico, o sistema pode ser entendido por seis funções do dia a dia.

O **cadastro e credenciamento de empresas** é a porta de entrada: uma empresa é registrada, tem seus dados e suas áreas de atuação (CNAE) conferidos, e passa a constar como apta a participar do atendimento. O **rodízio de atendimento** é o que garante justiça na distribuição: em vez de uma única empresa receber todo o trabalho, o sistema organiza uma fila e distribui as demandas de forma ordenada entre os credenciados.

A **avaliação de ordens de serviço** acontece quando um trabalho é realizado: a ordem é avaliada e esse resultado alimenta o histórico da empresa. A partir desse histórico entram as **regras de suspensão, strikes, reativação e fila**. Um "strike" é uma marca de penalidade; ao acumular strikes, uma empresa pode entrar em uma janela punitiva e ser suspensa por um período. Passado esse prazo, ela pode ser reativada e voltar à fila de rodízio, sempre seguindo regras claras de data e de ordem.

Por fim, os **relatórios, a auditoria e a validação** dão transparência ao processo. O sistema gera relatórios de suspensões, strikes e reativações, registra cada ação com efeito sobre o estado em uma trilha de auditoria, e oferece uma rotina de validação para que um operador humano confira se tudo está correto antes de considerar uma versão pronta.

## 3. Linha do tempo de abril e maio de 2026

### Abril — estabilização, importação, testes V1/V2, Onda 5 e documentação HBN

Abril começou (15 a 17 de abril) com a recuperação de uma base pública versionada e a limpeza de artefatos obsoletos. A partir dela, a linha evoluiu para tratar reativação, importação, filtros e validação, deixando de ser apenas uma planilha com macros para ganhar uma trilha verificável de regressão e um histórico de decisões.

Entre 19 e 20 de abril veio a estabilização da importação VBA e da integridade estrutural, com reforço do pacote importável, tratamento de módulos obrigatórios e endurecimento contra colisões e desvios de fonte. A importação passou a ser governada por uma "regra de ouro" operacional, com `src/vba/` como fonte de verdade e `local-ai/vba_import/` como pacote oficial de importação.

De 21 a 26 de abril ocorreu a principal frente técnica do mês: a sprint da V12.0.0203, que transformou correções isoladas em uma release candidata com gate, testes e auditoria. Nesse bloco foram endurecidas a configuração inicial e a limpeza de base, ampliados os cenários de configuração e strikes, e reforçados os snapshots de CNAE e a deduplicação. A Bateria Oficial V1 foi validada em `171/0`, e a Onda 5 foi homologada em 28 de abril com a evidência `VR_20260428_231958`.

Entre 28 e 30 de abril, a Onda 6 consolidou a camada documental e de colaboração entre IAs: a criação do `AGENTS.md` como entrada canônica, os mapas `llms.txt` e `llms-full.txt`, a estruturação da pasta `.hbn/` (relay, knowledge, readbacks e results), a organização Diátaxis em `docs/` e a formalização da segurança preventiva Glasswing. Em paralelo, as Ondas 7 e 8 prepararam o terreno para o Importador V3.

### Maio — Importador V3, V203, V204, V205 oficial e início da V206

Maio abriu (1 de maio) com a Onda 9, que aprovou a primeira fase do Importador V3, trabalhando sobre um conjunto isolado de 35 módulos e 13 formulários, com manifesto e rotina de importação mais controlada, validada pelo trio `VR_20260501_121550`.

Entre 1 e 2 de maio, as Ondas 10 e 11 reincorporaram e estabilizaram a frente de strikes e fecharam a V12.0.0203-rc1, agora com bateria E2E para penalidade, reativação e janela punitiva (evidência `VR_20260502_063028`). Em 4 de maio, as versões rc3 e rc4 trouxeram endurecimento de reativação, integridade e classificação, criaram o bloco `IntegridadeBase` e ampliaram o E2E de Strikes para 71 cenários (evidência `VR_20260504_171048`).

De 5 a 11 de maio veio a V12.0.0204, a fase de hardening mais ampla do período, organizada nas Ondas 20 a 25: reativação via serviço central, resultado estruturado em gravação de status, propagação explícita de falhas, contadores de strikes, rollback de ordens de serviço, rejeição de transação aninhada, backfill de datas de reativação, cenários adversariais de UI, datas de fronteira e limpeza de base autenticada. O gate final da V204 foi `VR_20260511_154433`.

Entre 21 e 23 de maio, a V12.0.0205 foi congelada como versão oficial validada, com nomenclatura profissional de baterias (RVS, SRC e BRL), dossiê de release, roteiro de validação humana, evidências públicas com manifesto e hash, e matriz de regras de negócio. O gate oficial foi aprovado em 23 de maio, com a evidência `VR_20260523_215637`.

A partir de 24 de maio teve início, de forma controlada, a linha V12.0.0206, com foco em planejamento, reconciliação de pendências, melhorias de UI/relatórios e institucionalização do protocolo HBN — incluindo a criação da camada executável de contratos na Onda 36, schemas JSON, guardas locais e CI de governança.

## 4. Versões do período

A leitura de versões para prestação de contas é direta. A **V12.0.0203** foi a linha de estabilização: consolidou correções funcionais, organizou a importação e introduziu as primeiras suítes E2E. A **V12.0.0204** foi o hardening de produção: ampliou as garantias transacionais, a integridade de base e a cobertura adversarial de UI, transação e datas. A **V12.0.0205** é a versão oficial validada do período: não alterou semanticamente as regras de negócio da V204, mas transformou a linha validada em um pacote institucional, auditável e comunicável, com gate RVS aprovado e evidências públicas.

A **V12.0.0206** é a linha atual em validação iterativa, ainda sem freeze. Ela já incorpora ampliações de testes e melhorias visuais e operacionais, mas seu congelamento permanece condicionado ao fechamento de achados visuais em relatórios impressos e ao gate humano.

> **Importante:** a V12.0.0206 não deve ser tratada como versão oficial final. A versão oficial final do período de abril e maio de 2026 é a **V12.0.0205**.

## 5. Correções e novas funcionalidades

**Reativação de empresas.** O serviço central de reativação passou a ser a rota obrigatória, e o formulário de reativação deixou de contornar a regra de negócio. A função `Reativa_Empresa` passou a chamar a rotina central, e a data de última reativação (`DT_ULT_REATIV`) foi incorporada ao raciocínio de integridade e de janela temporal.

**Strikes e janela punitiva.** O fluxo de penalidade, reativação e janela punitiva ganhou bateria E2E própria, que evoluiu até 76 asserts no gate final. Foram automatizados cenários de punição, reativação, contador duplo de strikes no log e datas de fronteira, além do bloqueio de punição com data inválida e dos limites temporais da janela.

**Integridade de base.** Foi criado o bloco `IntegridadeBase`, com varredura estrutural de base, migração controlada de referências órfãs e backfill de datas. A integridade de estado passou a ser verificada, e não apenas o resultado final de cada operação.

**Transações e rollback.** O sistema passou a rejeitar transações aninhadas, a fazer rollback de ordens de serviço e credenciamentos em falhas controladas e a propagar erros de forma explícita por resultado estruturado, preservando o estado nos fluxos de status de empresa.

**Relatórios.** Os formulários e mensagens foram padronizados, e as rotas de impressão e os relatórios ganharam cobertura incremental. Já na V206, foram iniciados ajustes visuais e de legibilidade em relatórios largos — frente que segue em validação, com achados visuais ainda em tratamento.

**Importação VBA.** A importação passou a ser governada pela regra de ouro (`src/vba/` como fonte, `local-ai/vba_import/` como espelho com prefixos), reforçada pelo Importador V3 com manifesto e controle mais robusto, reduzindo o risco de importar caminhos errados ou pacotes incompletos.

**App_Release e identificação de versão.** O módulo `App_Release` passou a apoiar a identificação visual da versão importada diretamente no workbook, facilitando a conferência de qual build está em uso.

**Documentação pública.** Foram organizados o dossiê de release V205, a jornada humana de validação por interface, as regras de negócio públicas e a matriz de cobertura de testes, além dos mapas `llms.txt` e `llms-full.txt`.

**Auditoria e trilha de evidências.** A trilha de auditoria (`AUDIT_LOG`, `AUDIT_TESTES`, trilhas de teste) e as evidências por release foram padronizadas, com a pasta canônica `auditoria/evidencias/V12.0.0205/` reunindo CSV final, hash e índice humano.

## 6. Baterias de testes disponíveis

O catálogo atualizado das baterias está em `docs/reference/testes/10_BATERIAS_TESTES_DISPONIVEIS_V206.md`. De forma simples, cada bateria prova uma coisa diferente:

A **V1 Bateria Oficial** é a regressão funcional ampla, que protege o comportamento histórico do sistema. A **V2 Smoke** é a verificação de sanidade básica e de cenários críticos, rápida de rodar. A **V2 Canônica** cobre os fluxos canônicos de credenciamento, avaliação e rodízio. O **E2E Strikes** percorre, de ponta a ponta, penalidades, reativação, janelas e contadores. O **IntegridadeBase** faz a varredura estrutural da base. O **Onda23Adv** reúne os cenários adversariais de interface, interrupção de transação e datas de fronteira.

No nível de gates de release, o **RVS** (Gate de Validação de Release) é a rota oficial da V205, reunindo V1, V2 Smoke, V2 Canônica, E2E Strikes, IntegridadeBase e Onda23Adv. O **SRC** (Suite de Regressão Consolidada) é a regressão sem o bloco adversarial. O **BRL** (Bateria Rápida Legada) é um gate histórico menor, mantido por compatibilidade. Na linha V206, o **VCR** (Validação Completa de Release) é o gate consolidado atual e pode incluir complementos como `ImpressãoResidual` e `PunicoesDias`. Esses complementos são testes dirigidos: o **ImpressãoResidual** trata da impressão residual de relatórios, e o **PunicoesDias** trata das punições contadas por dias.

Os principais resultados registrados são os seguintes.

Gate oficial V205 (`VR_20260523_215637`):

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

Checkpoint V206 (linha em validação iterativa, evidência `VR_20260609_082732`):

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0+ImpressaoResidual=7/0+PunicoesDias=8/0
```

Os agentes de IA podem preparar, documentar e auditar essas baterias, mas a execução dos testes no Excel/VBE é sempre feita pelo operador humano.

## 7. Ampliação dos testes ao longo do período

A evolução da quantidade de verificações é uma das provas mais objetivas de esforço técnico no período. A Bateria V1 manteve uma regressão ampla e estável em `171/0`. A V2 Smoke cresceu de `14/0` para `34/0`. A V2 Canônica passou de `20/0` para `24/0`. O E2E de Strikes foi criado e chegou a `76/0`. O `IntegridadeBase` saiu de inexistente para `4/0`. A Onda 23 acrescentou `27/0` asserts adversariais. E, já na V206, foram adicionados os blocos dirigidos de impressão residual (`7/0`) e punições por dias (`8/0`).

| Marco | V1 | V2 Smoke | V2 Canônica | E2E Strikes | IntegridadeBase | Onda23Adv | Complementos |
|---|---:|---:|---:|---:|---:|---:|---|
| Abril (Onda 5) | 171/0 | 14/0 | 20/0 | — | — | — | CONFIG, CNAE, rodízio |
| V203 rc1 | 171/0 | 14/0 | 20/0 | 64/0 | — | — | Strikes E2E |
| V203 rc4 | 171/0 | 27/0 | 23/0 | 71/0 | 3/0 | — | Reativação e integridade |
| V204 final | 171/0 | 34/0 | 24/0 | 76/0 | 4/0 | 27/0 | UI adversarial, transação, datas |
| V205 oficial | 171/0 | 34/0 | 24/0 | 76/0 | 4/0 | 27/0 | RVS/SRC/BRL e evidências públicas |
| V206 checkpoint | 171/0 | 34/0 | 24/0 | 76/0 | 4/0 | 27/0 | ImpressãoResidual 7/0, PunicoesDias 8/0 |

## 8. Avanços do useHBN/HBN

No contexto deste projeto, o **useHBN** (protocolo HBN — Human Brain Net) é a camada de governança que coordena o trabalho entre diferentes inteligências artificiais e o operador humano. Em termos práticos, ele é o conjunto de regras e de registros que mantém todos "na mesma página", de forma rastreável, sobre o que foi decidido, o que foi feito e o que ainda falta.

O useHBN ajudou a **preservar a memória técnica** do projeto. Em vez de depender da lembrança de uma sessão de trabalho, cada decisão importante virou um registro permanente. O **relay** (`.hbn/relay/INDEX.md`) indica quem está com o "bastão" e qual é o estado corrente. Os **readbacks** registram o contrato de cada onda de trabalho antes de qualquer alteração, e os **ERPs** registram o resultado depois da execução. A **base de conhecimento** (`.hbn/knowledge/`) guarda regras permanentes e decisões reutilizáveis. Juntos, esses elementos reduzem a perda de contexto entre uma etapa e outra, e entre uma IA e outra.

A camada de **guards executáveis** aumentou a segurança operacional ao transformar regras em código que roda automaticamente. Em vez de confiar apenas na disciplina, o projeto passou a ter verificações no momento de gravar (pre-commit) que recusam, por exemplo, trabalho fora da raiz canônica do projeto, alterações fora do escopo declarado para aquela onda, ou a inclusão de arquivos sensíveis. Como resume a doutrina interna: a documentação diz o que é certo, e os guards garantem que o errado não passe.

A **integração multi-IA** tornou o trabalho mais auditável. O projeto passou a operar com papéis definidos — um implementador por onda e auditores cruzados que revisam o trabalho em contexto novo — e com uma escala de severidade (BLOQUEADOR, FORTE e MARGINAL) que organiza como cada achado deve ser tratado. Isso significa que nenhuma entrega relevante avança sem revisão independente registrada.

Por fim, o projeto passou a ter um **protocolo de passagem de bastão** (a chamada Cadência D Estendida): quando uma IA encerra sua participação ou atinge metade do seu contexto, ela produz um handoff escrito e estruturado, de modo que a próxima IA — ou o próprio operador — retome o trabalho sem perder histórico. Em resumo, o useHBN tornou o projeto mais rastreável, mais seguro e mais robusto, porque cada passo importante deixa um rastro verificável.

## 9. Robustecimento do sistema em três camadas

O robustecimento alcançado no período pode ser lido em três camadas que se reforçam.

A **camada funcional** é o próprio comportamento do sistema: as regras de negócio, a reativação por serviço central, o tratamento de strikes e janela punitiva, o rodízio e os relatórios ficaram mais consistentes e mais difíceis de burlar por caminhos alternativos.

A **camada de testes** é a rede de proteção: o crescimento das baterias (V1, Smoke, Canônica, E2E Strikes, IntegridadeBase, Onda23Adv e os complementos dirigidos da V206) ampliou a cobertura de riscos que antes eram pouco verificáveis, como transação interrompida, datas de fronteira e integridade de base.

A **camada de governança** é o que mantém as duas primeiras sob controle ao longo do tempo: o protocolo HBN, as evidências por release, os guards executáveis, a documentação Diátaxis e o protocolo de passagem de bastão garantem que cada mudança seja registrada, revisada e rastreável.

## 10. Evidências e comprovação de esforço técnico

Este documento não converte commits ou validações em horas numéricas, pois o repositório não contém apontamento administrativo de horas por pessoa. Em vez disso, o esforço técnico do período é comprovável por blocos de trabalho com rastro auditável.

As **versões entregues** (V203, V204 e a oficial V205) e os **microdeltas** que as compõem estão registrados no `CHANGELOG.md` e na documentação de ondas. Os **gates aprovados** e as **evidências VR** (`VR_20260428_231958`, `VR_20260501_121550`, `VR_20260502_063028`, `VR_20260504_171048`, `VR_20260511_154433` e, como marco oficial, `VR_20260523_215637`) comprovam a validação de cada etapa. A **ampliação de testes** está documentada nas matrizes de cobertura e no catálogo de baterias. A **documentação** pública (dossiê V205, jornada humana, regras de negócio e referência de testes) comprova o trabalho de comunicação e auditoria. A **importação, o compile e a validação humana** no workbook estão registrados nos procedimentos de import e nas evidências de cada onda. E a **integração useHBN** deixa trilha própria em readbacks, ERPs, relay e base de conhecimento.

| Bloco de trabalho | Evidência auditável |
|---|---|
| Correções VBA e importação | CHANGELOG, builds importados, Importador V3, pacote `local-ai/vba_import/` |
| Regras de negócio e serviços | CHANGELOG V203/V204, suítes E2E Strikes, IntegridadeBase e Onda23Adv |
| Testes automatizados | Resultados `VR_*`, matrizes de cobertura e catálogo de baterias |
| Validação humana | Jornada V205, gate RVS final, manifesto de evidências |
| Documentação pública | `docs/`, release notes, dossiê V205, regras V205 |
| Governança multi-IA | `AGENTS.md`, `.hbn/`, schemas, guards, relay e ERPs |
| useHBN | Base de conhecimento, padrões de fagocitose VBA e Cadência D |

Sugestão de enquadramento administrativo: as horas declaradas pelo operador podem ser separadas em frentes de trabalho — desenvolvimento VBA, testes/QA, documentação, governança HBN, validação humana e estabilização de release — usando os marcos acima como comprovantes técnicos.

## 11. Conclusão

Nos meses de abril e maio de 2026, o Sistema de Credenciamento e Rodízio de Pequenos Reparos evoluiu de uma linha em consolidação para uma linha oficial validada. O principal resultado entregue foi a **V12.0.0205**, com gate RVS final aprovado (`VR_20260523_215637`), evidências versionadas e documentação de uso, regra e teste. Em paralelo, os testes foram significativamente ampliados, a documentação tornou-se auditável e a governança técnica ganhou uma camada executável por meio do protocolo useHBN/HBN.

A linha **V12.0.0206** segue em validação iterativa, demonstrando continuidade de melhoria, mas sem freeze declarado — e, portanto, sem substituir a V12.0.0205 como marco oficial do período. O conjunto entrega uma base mais confiável, mais bem documentada e mais rastreável para a continuidade do projeto, seja por outras IAs, seja por mantenedores humanos.

---

### Limites declarados e pontos para validação humana

- A V12.0.0205 está congelada como oficial e não deve receber alteração sem nova decisão de release; a V12.0.0206 segue em validação iterativa.
- O agente não executa Excel/VBE nem substitui o gate humano de importação, compile e RVS/VCR. Nenhum teste foi executado na produção deste documento.
- A V206 tem histórico de achados visuais em relatórios impressos, que precisam ser fechados antes de qualquer freeze.
- Há uma divergência entre duas fontes internas no registro do hash SHA-256 do CSV de evidência da V205 (`obsidian-vault/releases/V12.0.0205.md` e `auditoria/00_status/127_RELATORIO_PRESTACAO_CONTAS_ABRIL_MAIO_2026.md`). Recomenda-se conferência humana do hash a partir do arquivo `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260523_215637.csv` antes de citá-lo formalmente.

### Fontes principais utilizadas

- `auditoria/00_status/127_RELATORIO_PRESTACAO_CONTAS_ABRIL_MAIO_2026.md`
- `docs/reference/testes/10_BATERIAS_TESTES_DISPONIVEIS_V206.md`
- `docs/reference/testes/INDEX.md`
- `obsidian-vault/releases/V12.0.0205.md`
- `.hbn/knowledge/0013-contratos-executaveis.md`
- `.hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md`
- `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`
- `.hbn/relay/INDEX.md`
- `AGENTS.md`
