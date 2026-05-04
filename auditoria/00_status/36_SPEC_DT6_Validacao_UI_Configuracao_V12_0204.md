---
titulo: 36 - Spec DT-6 (Validacao UI Configuracao_Inicial ↔ regra de strikes parametrizada) — V12.0.0204
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204 (proxima)
data: 2026-05-02
autor: Claude Opus 4.7 (Cowork) com aprovacao operador
licenca-target: TPGL-v1.1 (Credenciamento)
---

# 36. Spec DT-6 — Validacao UI Configuracao_Inicial ↔ regra de strikes parametrizada (V12.0.0204)

## Status

**REGISTRADA POR HEARBACK** em 2026-05-02 durante a Onda 11 (V12.0.0203-rc1
closure). Implementacao deslocada para Onda 12+ ou V12.0.0204 inicial.

## Origem

Identificada pelo operador Luís Maurício Junqueira Zanin durante a
analise do MD-2.3 (cleanup de CONFIG na suite E2E). Pergunta literal:

> "A versao do teste esta registrando um numero fixo de voltas ou esta
> respeitando o numero de strikes e o numero de dias configurados no
> formulario? Pois precisamos que o teste valide esses formularios."

Reconhecimento explicito de uma lacuna que existe desde a Onda 10:
a regra de strikes em producao funciona corretamente para diferentes
valores de MAX_STRIKES e DIAS_SUSPENSAO_STRIKE, mas a suite de teste
**hardcoda** os comportamentos esperados em torno de valores fixos
(MAX_STRIKES=3, DIAS=90 na suite E2E; MAX_STRIKES=1, DIAS=0 nas
suites V1/V2 legadas). Nenhuma suite valida que:

1. O formulario `Configuracao_Inicial` grava corretamente os valores
   na aba CONFIG.
2. A regra de negocio em producao le esses valores via
   `Util_Config.GetMaxStrikes` / `GetDiasSuspensaoStrike` de forma
   correta.
3. Diferentes combinacoes de `MAX_STRIKES` e `DIAS_SUSPENSAO_STRIKE`
   produzem o comportamento parametrizado esperado.

## Lacuna conceitual

| Camada | Status atual | Coberto por |
|---|---|---|
| Codigo de producao (Svc_Avaliacao bloco 7b, Suspender, Reativar) | Validado | TV2_RunRodizioStrikesEndToEnd com valores fixos |
| Util_Config getters (GetMaxStrikes, GetDiasSuspensaoStrike) | Defaults validados | Via testes legados (BO_330) e canonicos (CS_14, CS_16) |
| **CONFIG-ke-aba (read-write programatico)** | **Validado parcialmente** | TV2_SetConfigCanonica grava; getters leem; **caminho UI ausente** |
| **Configuracao_Inicial.frm (UI)** | **Nao validado** | Nenhuma suite simula clique/digitacao no form |
| **Suite parametrizada por valor configurado** | **Nao existe** | Toda suite E2E hardcoda os asserts |

## Objetivo funcional do DT-6

Adicionar suite de teste que:

1. **Abre o formulario** `Configuracao_Inicial` programaticamente
   (via `frm.Show vbModeless` ou seu equivalente).
2. **Simula gravacao** de valores variaveis (ex.: MAX_STRIKES=2,
   DIAS=30; depois MAX_STRIKES=5, DIAS=180; depois MAX_STRIKES=1,
   DIAS=0 - legado).
3. **Le CONFIG** apos cada gravacao para confirmar que o form persistiu
   corretamente.
4. **Roda cenarios E2E parametrizados** — onde os asserts sao funcao
   dos valores que acabaram de ser gravados (ex.: MAX_STRIKES=N →
   esperar suspender no Nth strike).
5. **Valida ciclo completo UI → CONFIG → regra → comportamento.**

## Requisitos minimos

### Casos de teste sugeridos (CS_14_NEW_*)

| Caso | MAX_STRIKES | DIAS | Comportamento esperado |
|---|---|---|---|
| CS_14_NEW_A | 1 | 0 (fallback meses) | Legado: 1 strike → suspende em meses |
| CS_14_NEW_B | 2 | 30 | 2 strikes → suspende 30 dias |
| CS_14_NEW_C | 3 | 90 | 3 strikes → suspende 90 dias (caso atual da E2E) |
| CS_14_NEW_D | 5 | 180 | 5 strikes → suspende 180 dias (limite alto) |
| CS_14_NEW_E | 50 | 3650 | Limite max declarado em GetMaxStrikes (50) e GetDiasSuspensaoStrike (3650 = 10 anos) |

### Refatoracao da suite E2E para ser parametrizada

A suite atual `TV2_RunRodizioStrikesEndToEnd` deve ser renomeada para
`TV2_RunRodizioStrikesEndToEnd_Param` aceitando dois parametros:

```
TV2_RunRodizioStrikesEndToEnd_Param(maxStrikes, diasSusp)
```

E os asserts devem ser funcoes desses valores. A versao "fixa"
atualmente em producao vira um wrapper de retrocompatibilidade que
chama `_Param(3, 90)`.

### Helper de simulacao UI

Criar `Teste_UI_Guiado.TUI_GravarConfigStrikes(maxStrikes, diasSusp)`
que:

1. Abre `Configuracao_Inicial.frm`.
2. Localiza textbox/campo de strikes e DIAS.
3. Preenche valores.
4. Aciona botao Salvar (ou equivalente).
5. Fecha form.
6. Retorna TResult com sucesso/falha.

VBA permite manipular controles de UserForm programaticamente — esse
helper e a base do teste de integracao UI.

## Arquitetura sugerida

### Modulo novo `Teste_UI_Configuracao.bas`

API minima:

- `TUI_TestarFluxoCompletoStrikes() As TResult` — roda os 5 casos acima
- `TUI_GravarConfigStrikes(maxStrikes, diasSusp) As TResult` — helper UI
- `TUI_LerConfigStrikes() As TConfigSnapshot` — confirma que persistiu

### Hooks na bateria

- Adicionar opcao `[20] Teste UI Configuracao Strikes` em `Central_Testes_V2`.
- Incluir em `CT_ValidarRelease_TrioMinimo` apos a aprovacao inicial,
  como gate de release pre-publicacao.

## Sprints sugeridas (Onda 12 ou V12.0.0204)

- **MD-12.1:** Helper `TUI_GravarConfigStrikes` + `TUI_LerConfigStrikes`.
- **MD-12.2:** Refatorar `TV2_RunRodizioStrikesEndToEnd` para versao
  `_Param`. Wrapper retrocompativel.
- **MD-12.3:** Suite `Teste_UI_Configuracao.TUI_TestarFluxoCompletoStrikes`
  rodando os 5 casos.
- **MD-12.4:** Integracao em `Central_Testes_V2` (opcao 20).
- **MD-12.5:** Documentacao em `docs/how-to/` para humanos +
  `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` (lessons L16+ sobre
  testes parametrizados de UI).

## Riscos

- **Manipulacao programatica de UserForm em VBA pode ser fragil em
  diferentes versoes do Excel.** Mitigacao: testar em Excel for Mac
  (atual) + Windows + 365.
- **Suite parametrizada pode mascarar bugs** se os parametros nao
  cobrem casos de borda. Mitigacao: incluir limites declarados pelos
  getters (1, 50 para MAX_STRIKES; 0, 3650 para DIAS).
- **Refatoracao pode introduzir regressao** na suite E2E vigente.
  Mitigacao: wrapper retrocompativel + manter TV2_RunRodizioStrikesEndToEnd
  como entrada operacional ate a Onda 12 estar estavel.

## Relacao com DT-5 (PDFs)

DT-5 e DT-6 podem ser combinados em uma unica Onda 12 dedicada a
"validacao auditavel": DT-5 entrega evidencia documental persistente,
DT-6 entrega validacao da integracao UI. Juntos formam o cinturao de
auditoria publica que o sistema precisa para credibilidade externa
(Lei 12.527, Tribunal de Contas).

## Lessao destilada (para PHAGOCYTOSIS apos validacao)

**Anti-padrao identificado:** suite de teste que **escreve em CONFIG**
para forcar o estado desejado, em vez de **validar via fluxo natural**
(grava via UI, depois valida via API). O primeiro testa apenas a
regra; o segundo testa a integracao end-to-end.

**Padrao correto:** toda configuracao testavel deve ter helper UI
+ helper de leitura programatica + suite que valida o ciclo completo.
Asserts parametrizados pelos valores configurados, nao hardcoded.

## Versao

- v1.0 — 2026-05-02 — spec inicial registrada na Onda 11 V12.0.0203-rc1
  closure. Implementacao prevista para Onda 12 ou V12.0.0204.
