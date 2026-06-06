---
titulo: Consolidacao auditoria cruzada 38.2.4 a 38.2.12
diataxis: status
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-01
---

# 0033 - Consolidacao auditoria cruzada 38.2.4 a 38.2.12

## Veredito

**APROVAR COM RESSALVAS os deltas ja importados e testados; BLOQUEAR freeze
V12.0.0206; nao abrir FT-4 como proxima onda de codigo.**

O codigo entregue nas ondas 38.2.4 a 38.2.12 nao pede rollback neste momento:
os deltas sao rastreaveis, foram importados/compilados/testados por Mauricio e
os arquivos blindados do handoff foram preservados. A certificacao, porem,
ainda nao sustenta freeze: parte relevante dos testes dirigidos e estatica,
C1/C4/C5 do parecer 0024 seguem sem fechamento e a auditoria independente
colada por Mauricio identificou falso positivo materializado no cluster de
impressao.

Esta consolidacao nao substitui auditoria independente. Ela registra a leitura
do Codex implementador sobre os pareceres externos e sobre evidencias locais
versionadas, para orientar a proxima onda.

## Fontes usadas

- `.hbn/proposals/0024-Opus3-4-MAX-auditoria-gate-a4-l43-v206.md`
- `.hbn/results/0120-exec-onda-38-2-4-integridade-estado.json` ate
  `.hbn/results/0128-exec-onda-38-2-12-performance-ux-basica.json`
- `auditoria/03_ondas/onda_38_2_13_auditoria_cruzada/0129_PROMPTS_AUDITORIA_HANDOFF.md`
- texto colado por Mauricio no handoff 0129, contendo auditoria cruzada
  independente sobre 38.2.4 a 38.2.12
- `src/vba/Teste_V2_Roteiros.bas`, apenas para confirmar a natureza dos testes
  `TV2_EST_*`

## Achados consolidados

| Severidade | Achado | Evidencia | Decisao |
|---|---|---|---|
| BLOQUEADOR | C1/Achado #0 nao esta atendido | `TV2_RunIntegridadeEstado`, `TV2_RunImpressaoIntegridade`, `TV2_RunLeituraExibicao`, `TV2_RunConfigBaselineSeguro`, `TV2_RunConfigSnapshotV2` e `TV2_RunPerformanceUXBasica` combinam asserts reais com verificacoes por tokens de codigo (`TV2_EST_*`). | Proxima onda deve converter cobertura para comportamento executado, nao abrir FT-4. |
| BLOQUEADOR | Falso positivo ja observado no cluster de impressao | ERP 0122 fechou `TV2_RunImpressaoIntegridade` com OK=6; ERP 0123 registrou PDF com empenho truncado/quebrado e demandante vazio. | Impressao precisa de segunda onda comportamental/PDF antes de freeze. |
| BLOQUEADOR | C3 ficou parcial | Auditoria independente documentada existe para 38.2.4 (`0025`, `0026`); propostas `0027` a `0032` sao de autoria Codex. | Esta 38.2.13 registra a lacuna; futuras ondas relevantes precisam de auditores externos em chat novo. |
| BLOQUEADOR | C4 e C5 nao foram cumpridos apos 38.2.12 | Nao ha RVS sexteto final nem L44 tela-a-tela sobre build `e157221`. | Freeze segue bloqueado. |
| FORTE | BL-4 ainda tem risco residual | 38.2.4 melhorou protecao e houve reteste manual, mas nao ha teste close/reopen nem mexida em `Auto_Open.bas`. | Abrir onda propria para protecao persistente so se Mauricio aceitar tocar esse ponto. |
| FORTE | FT-4 continua pendente e arriscado | 0128 diferiu credenciamento em lote por risco de `CRED_ID`/AR1. | Implementar somente depois da behavioralizacao de IDs em lote/base populada. |
| FORTE | FT-7 continua parcial | Ponte de dados existe, mas PDF apontou empenho estreito/truncado. | Reabrir impressao fase 2 antes de freeze. |
| FORTE | FT-9, FT-10 e FT-11 real nao estao fechados | FT-9/FT-10 nao foram implementados; 38.2.8/38.2.9 trataram baseline/snapshot V2, nao provaram o mecanismo original do 0024 sobre reaplicacao de defaults. | Deixar em fila apos C1/BL-4/impressao ou reclassificar com decisao humana. |
| MARGINAL | Higiene documental ainda tem pequenos desalinhamentos | `CHANGELOG.md` ainda carrega texto historico de 38.2.2 como ultima onda antes do freeze. | Corrigir em onda de higiene de freeze, nao agora. |

## Mapa 0024

| Item 0024 | Status consolidado | Observacao |
|---|---|---|
| BL-1 UI Config | Resolvido com ressalva | Controles restaurados e teste runtime `TV2_RunPersistenciaPainel` existe. Falta auditoria historica de quando sumiram. |
| BL-2 `xlGuess` | Resolvido | Diff removeu `xlGuess`; teste ainda e majoritariamente estatico. |
| BL-3 inativacao atomica | Resolvido com ressalva | Rollback implementado e gate manual de Entidades passou; falta cobertura comportamental mais forte para caminho de erro. |
| BL-4 protecao persiste | Parcial | Protecao melhorada; sem close/reopen e sem resolver de forma final a dependencia de `UserInterfaceOnly`/`Auto_Open`. |
| BL-5 clamp impressao | Resolvido | Helper de clamp e unit test real cobrem nota. |
| BL-6 local OS | Resolvido no codigo, nao provado por documento final | Tokens e ponte existem; falta assert no artefato impresso/celulas finais. |
| BL-7 Pre-OS | Resolvido com ressalva | Normalizador existe; PDF de Pre-OS deu bom sinal, mas cluster de impressao gerou defeito irmao em avaliacao. |
| FT-1 paridade lista | Resolvido | 38.2.7 ampliou `C_Lista_Click`. |
| FT-2 limpar cadastro | Parcial | 38.2.12 criou helper para entidade; fluxo completo de entrada/novo cadastro ainda nao foi validado por UI. |
| FT-3 ProgressBar | Resolvido | `Save` embutido e busy-wait removidos. |
| FT-4 credenciamento em lote | Pendente | Deve esperar cobertura comportamental de `CRED_ID`/AR1. |
| FT-5 dados rodizio | Resolvido | 38.2.7 tratou exibicao de nome/telefone. |
| FT-6 filtro Imprime SS | Resolvido | 38.2.7 ligou filtro ao preenchimento. |
| FT-7 empenho OS | Parcial | Dado passa, mas layout/PDF truncou. |
| FT-8 exibir ID | Resolvido | ID visivel antes do CNPJ. |
| FT-9 tempo experiencia | Pendente | Nao tocado. |
| FT-10 designer overlap | Pendente | Nao tocado, salvo `.frx` de Configuracao_Inicial para BL-1. |
| FT-11 regressao parametros | Parcial/desviado | Corrigiu baseline/snapshot V2; nao comprovou mecanismo original de reaplicacao de defaults. |
| MG-1 GitHub Mac | Resolvido | 38.2.12 priorizou `Shell open` no Mac. |
| MG-2 a MG-9 | Pendente aceitavel | Mantidos para V207 ou onda visual posterior. |
| C1 cobertura expandida | Nao atendido | Principal bloqueio atual. |
| C2 bloqueadores resolvidos | Parcial | Codigo dos BLs existe, mas parte da prova e fraca. |
| C3 auditoria cruzada | Parcial | Ausente para varias ondas pos-38.2.4. |
| C4 RVS sexteto + novos roteiros | Nao atendido | Sem RVS final pos-38.2.12. |
| C5 L44 manual | Nao atendido | Sem segunda passada manual sobre build corrigida. |
| C6 higiene documental | Parcial | Houve higiene 38.2.10/38.2.11; falta fechamento de release/evidencias V206. |

## Sequencia recomendada

1. **38.2.14 - Behavioralizacao da bateria/C1.** Converter testes estaticos
   para fluxos executados: base populada, inativacao com caminho de erro,
   impressao em celulas finais/PDF, CONFIG snapshot real e `CRED_ID`/AR1 em
   lote sem reuso.
2. **38.2.15 - BL-4 fechamento real.** Validar protecao apos save/reopen e
   decidir se `Auto_Open.bas` entra por excecao explicita.
3. **38.2.16 - Impressao fase 2.** Resolver empenho truncado, demandante vazio,
   bordas e asserts comportamentais.
4. **38.2.17 - FT-4 credenciamento em lote.** So abrir com teste V2 que valide
   sequencia `CRED_ID`/AR1, base populada e tempo de execucao.
5. **38.2.18 - Designer residual e FT-9/FT-10/FT-11 real.**
6. **38.2.19 - Higiene de freeze candidate.** RVS sexteto, L44, evidencias em
   `auditoria/evidencias/V12.0.0206/`, release notes e CHANGELOG.

## Decisao explicita sobre FT-4

**Nao abrir FT-4 agora.** FT-4 e importante, mas mexe no mesmo subsistema de
IDs/estado que o L43 expôs como sensivel a base populada. Antes de otimizar a
alocacao em lote, a bateria precisa detectar reuso, salto ou quebra de
sequencia `CRED_ID`/AR1 em fluxo executado.

## Freeze V206

O freeze V12.0.0206 continua bloqueado. A regra do parecer 0024 permanece:
sem C1, C2 e C5 nao ha freeze. No estado atual, C1, C4 e C5 nao estao
atendidos; C2 e C3 estao parciais.
