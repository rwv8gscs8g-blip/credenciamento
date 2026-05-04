---
titulo: Procedimento de import MD-17.1.d.I — Performance gamma conservador
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — sessao 2
licenca-target: TPGL-v1.1
---

# 10 — Procedimento de import MD-17.1.d.I

## Tema

Performance gamma conservador no Engine V2: ativar
Application.Calculation=xlCalculationManual + ScreenUpdating=False +
EnableEvents=False durante execucao de testes; restaurar pos-execucao.
TV2_PausarVisual vira no-op. Alvo HF8: Quarteto <10min (baseline 14m41s).

## Pre-condicoes

| Item | Esperado |
|---|---|
| Workbook ancora | `V12-202-Z003-onda17-md1c-fix3` |
| Build atual | `f7aa84f+ONDA17.MD1C-fix3-gamma-skip-empty-lines` |
| Quarteto pre-import | APROVADO `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0` |
| `src/vba/` ↔ `local-ai/vba_import/` | shasum batendo |

## Garantia de idempotencia (analise documentada)

| Opt | Risco | Verificacao | Status |
|---|---|---|---|
| Calculation manual | Cell.Value stale por formula | grep `.Formula\|.FormulaR1C1` em Repo/Svc = 0 | ✅ SAFE |
| EnableEvents=False | Worksheet_Change skip | grep handlers = 0 (apenas Auto_Open) | ✅ SAFE |
| ScreenUpdating=False | render visual | padrao ja usado | ✅ SAFE |
| TV2_PausarVisual no-op | timing-dependent | so feedback visual | ✅ SAFE |

Idempotencia GARANTIDA POR DESIGN. Defesa em profundidade: validacao
operacional inclui Run 2 consecutivo do Quarteto.

## Sequencia M11

| Arquivo | sha1 |
|---|---|
| `src/vba/Teste_V2_Engine.bas` ↔ ABF | `c5fa3618986c14f908cf6e523dac8fe927c08119` |
| `src/vba/App_Release.bas` ↔ AAX | `dde107a9a1af1e3ebf1e3afedfc91fbfb6194407` |

CRLF preservado. Sub/Function balance 61/61 + 64/64.

## Mudancas resumo

| Arquivo | Tipo | Linhas |
|---|---|---|
| `Teste_V2_Engine.bas` | 3 globals + InitExecucao bloco perf-on + FinalizarExecucao bloco perf-restore + handler erro_fatal_handler + TV2_PausarVisual no-op + 2 helpers Private (TV2_PerfModeOn, TV2_PerfModeRestore) | 3069 → 3142 (+73) |
| `App_Release.bas` | bump label + comentario | 255 → 269 (+14) |

### Diagrama wire-up

```
TV2_RunSmoke (ou outro Run*)
  ├─ TV2_InitExecucao
  │    ├─ gTV2TimerInicio = Timer
  │    └─ Call TV2_PerfModeOn   ← NOVO
  │         (salva Application.* originais; ativa perf mode)
  ├─ ... cenarios rodam ...
  └─ TV2_FinalizarExecucao
       ├─ On Error GoTo erro_fatal_handler   ← NOVO
       ├─ Grava HISTORICO_QA_V2 + DURACAO_MS
       ├─ TV2_FormatarResultadoSheet etc
       ├─ Application.StatusBar = False
       ├─ Call TV2_PerfModeRestore   ← NOVO (ANTES da MsgBox)
       ├─ MsgBox final
       └─ erro_fatal_handler:   ← NOVO
            ├─ Call TV2_PerfModeRestore   ← NOVO (em erro)
            └─ MsgBox vbCritical
```

## Procedimento operacional

### Passo 1 — Resetar VBE

VBE: `Executar > Redefinir`.

### Passo 2 — Import V3 delta

```
ImportarPacoteV3_Delta "MICRO20", "f7aa84f+ONDA17.MD1D1-perf-gamma-conservador"
```

### Passo 3 — Compile manual

VBE: `Depurar > Compilar VBAProject` (0 erros esperado).

### Passo 4 — Validar build

```
?GetBuildImportado
```

Esperado: `f7aa84f+ONDA17.MD1D1-perf-gamma-conservador`.

### Passo 5 — Quarteto Run 1 (medicao de speed-up)

Marcar tempo de inicio (relogio do operador OU `?Timer` no Imediato antes).

```
CT_ValidarRelease_QuartetoMinimo
```

Marcar tempo de fim. Calcular delta vs baseline 14m41s91cs.

Esperado:
- `RESULTADO_GERAL = APROVADO`
- Sintaxe IDENTICA: `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0` (MANUAL=5)
- Tempo total: ~9-11min (speed-up >25%)

### Passo 6 — Validar restore Application.*

Janela Imediato:

```
?Application.Calculation       → esperado: -4135 (xlCalculationAutomatic)
?Application.ScreenUpdating    → esperado: True
?Application.EnableEvents      → esperado: True
?Application.StatusBar         → esperado: False (vazio)
```

Se algum diferente, restore falhou — abrir issue urgente.

### Passo 7 — Quarteto Run 2 (idempotencia empirica)

```
CT_ValidarRelease_QuartetoMinimo
```

Esperado:
- MESMAS contagens OK/FALHA/MANUAL do Run 1
- Mesma sintaxe completa
- Tempo total similar ao Run 1 (idempotente em performance tambem)

### Passo 8 — Salvar workbook

`V12-202-Z003-onda17-md1d1`.

### Passo 9 — Reportar

Cole no chat:
- VR Run 1 + sintaxe + tempo total
- VR Run 2 + sintaxe + tempo total
- Delta vs baseline 14m41s91cs (em segundos OU porcentagem)
- Confirmacao restore Application.* (Passo 6)

## Criterios de sucesso MD-17.1.d.I

1. Compile manual passa limpo.
2. `GetBuildImportado` = `f7aa84f+ONDA17.MD1D1-perf-gamma-conservador`.
3. Quarteto Run 1 APROVADO com sintaxe IDENTICA a baseline.
4. Quarteto Run 2 produz MESMAS contagens (idempotencia empirica).
5. Application.{Calculation,ScreenUpdating,EnableEvents} restaurados pos-execucao.
6. Tempo total reduzido em ≥25% (alvo HF8 <10min preferencial).
7. shasum batendo M11.

Cumpridos os 7: MD-17.1.d.I fechado; proximo eh MD-17.1.d.II (Visibility α).

Se criterio 6 nao for atingido (speed-up <25%): seguir para MD-17.1.d.II
mesmo assim e abrir MD-17.1.d.I.b com refatoracao gamma profunda como
debito tecnico (decisao do operador via Q-MD17.1.d.I.C).

## Rollback

Se Quarteto Run 1 reprovar OU compile error OU Excel travar pos-Quarteto:

```
git restore src/vba/Teste_V2_Engine.bas src/vba/App_Release.bas
git restore local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas local-ai/vba_import/001-modulo/AAX-App_Release.bas
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO20.txt
rm auditoria/03_ondas/onda_17_test_first/10_PROCEDIMENTO_IMPORT_MD17_1_d_I.md
```

Reabrir backup `V12-202-Z003-onda17-md1c-fix3`. Reportar evidencia.

Se Excel ficar travado (Calculation manual residual):
```
' Janela Imediato manual:
Application.Calculation = xlCalculationAutomatic
Application.ScreenUpdating = True
Application.EnableEvents = True
Application.StatusBar = False
```

## Documentos relacionados

- [`.hbn/readbacks/0015-onda17-md17-1-d-I.json`](../../../.hbn/readbacks/0015-onda17-md17-1-d-I.json)
- [`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO20.txt`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO20.txt)
- [`auditoria/03_ondas/onda_17_test_first/09_PROCEDIMENTO_IMPORT_MD17_1_c_fix3.md`](09_PROCEDIMENTO_IMPORT_MD17_1_c_fix3.md) (anterior)

## Versao

- v1.0 — 2026-05-03 — procedimento inicial MD-17.1.d.I.
