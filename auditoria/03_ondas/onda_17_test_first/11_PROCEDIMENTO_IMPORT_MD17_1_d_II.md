---
titulo: Procedimento de import MD-17.1.d.II — Visibility alfa (status bar rica)
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — sessao 2
licenca-target: TPGL-v1.1
---

# 11 — Procedimento de import MD-17.1.d.II

## Tema

Visibility alfa: status bar rica durante execucao de Quarteto e suites V2.
Resolve sensacao de "Quarteto travado" durante ~13min de execucao silenciosa.
Operador acompanha progresso em tempo real no StatusBar (canto inferior
esquerdo do Excel). Idempotencia trivial — zero efeito em business logic.

## Pre-condicoes

| Item | Esperado |
|---|---|
| Workbook ancora | `V12-202-Z003-onda17-md1d1` |
| Build atual | `f7aa84f+ONDA17.MD1D1-perf-gamma-conservador` |
| Quarteto pre-import | APROVADO `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0` |
| `src/vba/` ↔ `local-ai/vba_import/` | shasum batendo |

## Sequencia M11

| Arquivo | sha1 |
|---|---|
| `src/vba/Util_Config.bas` ↔ AAD | `0d262b3d07752763c2b4f9c4503cc6e7396d63b0` |
| `src/vba/Teste_V2_Engine.bas` ↔ ABF | `af5427ab72e7b0ee08d365fceb31420e98649b27` |
| `src/vba/App_Release.bas` ↔ AAX | `f7be9367d56ee37877960c8c613ec0bf3573d805` |

CRLF preservado. Sub/Function balance Engine 62/62 + 64/64; Util_Config 3/3 + 15/15.

## Mudancas resumo

| Arquivo | Tipo | Linhas |
|---|---|---|
| `Util_Config.bas` | Public Function GetStatusBarVerbosity() (default 2; range 0-3) | +29 |
| `Teste_V2_Engine.bas` | 2 globals + Public Sub TV2_StatusBar + InitExecucao Optional totalCenarios + LogLinha StatusBar SEMPRE + FinalizarExecucao TV2_StatusBar concluido | +89 |
| `App_Release.bas` | bump label + comentario | +12 |

## Verbosity levels (controlado via Util_Config.GetStatusBarVerbosity, default 2)

| Nível | Comportamento |
|---|---|
| **0** | silent (no-op; StatusBar nao atualiza) |
| **1** | so transicoes de suite ('iniciando' / 'concluido OK=X FALHA=Y MANUAL=Z') |
| **2** (default) | 'V2 [SMOKE] X: CS_xxx = OK' (X = OK+FALHA+MANUAL atual) |
| **3** | 'V2 [SMOKE] X: CS_xxx = OK [etapa]' (etapa opcional) |

## Procedimento operacional

### Passo 1 — Resetar VBE

VBE: `Executar > Redefinir`.

### Passo 2 — Import V3 delta

```
ImportarPacoteV3_Delta "MICRO21", "f7aa84f+ONDA17.MD1D2-visibility-status-bar-rica"
```

### Passo 3 — Compile manual

VBE: `Depurar > Compilar VBAProject` (0 erros esperado).

### Passo 4 — Validar build + verbosity

```
?GetBuildImportado          → "f7aa84f+ONDA17.MD1D2-visibility-status-bar-rica"
?GetStatusBarVerbosity      → 2 (default)
```

### Passo 5 — Quarteto + observar StatusBar

```
CT_ValidarRelease_QuartetoMinimo
```

DURANTE execucao, observe o canto inferior esquerdo do Excel
(barra de status). Voce deve ver mensagens como:

```
V2 [SMOKE] iniciando
V2 [SMOKE] 1: SMOKE_001 = OK
V2 [SMOKE] 2: SMOKE_002 = OK
...
V2 [SMOKE] concluido OK=14 FALHA=0 MANUAL=0
V2 [CANONICO] iniciando
V2 [CANONICO] 1: CS_xxx = OK
...
```

### Passo 6 — Validar resultado

Esperado APROVADO com sintaxe:
```
V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0  (MANUAL=5)
```

Tempo similar ao MD-17.1.d.I (~13min) — sem regressao perf.

### Passo 7 — Salvar

`V12-202-Z003-onda17-md1d2`.

### Passo 8 — Reportar

VR + sintaxe + confirmacao visual ("vi StatusBar atualizando durante o Quarteto").

## Criterios de sucesso MD-17.1.d.II

1. Compile manual passa limpo.
2. `GetBuildImportado` = `f7aa84f+ONDA17.MD1D2-visibility-status-bar-rica`.
3. `GetStatusBarVerbosity` = 2.
4. Quarteto APROVADO sintaxe IDENTICA.
5. **Confirmacao visual**: operador ve StatusBar atualizando durante execucao.
6. Tempo similar a MD-17.1.d.I (~13min; sem regressao).
7. shasum batendo M11 (3 arquivos).

Cumpridos os 7: MD-17.1.d.II fechado; proximo eh MD-17.1.e (Limpeza C3).

## Customizacao opcional pelo operador

Se operador quer mudar verbosity:

- **Verbosity 0 (silencioso)**: adicionar coluna 99 em CONFIG, valor 0
- **Verbosity 3 (verbose)**: adicionar coluna 99 em CONFIG, valor 3
- Sem coluna OU valor invalido: default 2

Coluna formal sera adicionada em Const_Colunas em MD futura.

## Rollback

```
git restore src/vba/Util_Config.bas src/vba/Teste_V2_Engine.bas src/vba/App_Release.bas
git restore local-ai/vba_import/001-modulo/AAD-Util_Config.bas local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas local-ai/vba_import/001-modulo/AAX-App_Release.bas
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO21.txt
rm auditoria/03_ondas/onda_17_test_first/11_PROCEDIMENTO_IMPORT_MD17_1_d_II.md
```

Reabrir backup `V12-202-Z003-onda17-md1d1`.

## Documentos relacionados

- [`.hbn/readbacks/0016-onda17-md17-1-d-II.json`](../../../.hbn/readbacks/0016-onda17-md17-1-d-II.json)
- [`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO21.txt`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO21.txt)
- [`10_PROCEDIMENTO_IMPORT_MD17_1_d_I.md`](10_PROCEDIMENTO_IMPORT_MD17_1_d_I.md) (anterior)

## Versao

- v1.0 — 2026-05-03 — procedimento inicial MD-17.1.d.II.
