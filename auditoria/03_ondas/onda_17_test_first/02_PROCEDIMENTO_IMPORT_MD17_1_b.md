---
titulo: Procedimento de import MD-17.1.b — 5 cenários novos cobertura strikes
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1
---

# 02 — Procedimento de import MD-17.1.b (Onda 17 Test-First)

## Tema

5 cenários novos via `TV2_FixtureFactory` (criado em MD-17.1.a) +
helpers `TV2_FF_AtenderProximaEmpresa` + `TV2_FF_RodadaCompleta` +
**débito formal DT-17-REATIV-STRIKES documentado AMARELO** (não bloqueia
gate; resolução prioritária Onda 18).

## Pré-condições

| Item | Esperado |
|---|---|
| Workbook ancora | `V12-202-Z003-onda17-md1a` (ou nome equivalente após MD-17.1.a verde) |
| Build atual | `f7aa84f+ONDA17.MD1A-fixture-factory-namespacing` |
| Quarteto pré-import | APROVADO (`VR_20260503_010329` ou equivalente) |
| MD-17.1.a | concluída e importada com sucesso |
| `src/vba/` ↔ `local-ai/vba_import/` | shasum batendo (2 arquivos do MICRO17) |

## Sequência canônica respeitada (M11)

`src/vba/` é fonte de verdade; `local-ai/vba_import/` é espelho com
prefixos. Hashes confirmados (sha1, src/vba autoritativo):

| Arquivo | sha1 |
|---|---|
| `src/vba/Teste_V2_Roteiros.bas` ↔ `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas` | `5dac02f138a63d029f042cc2731c90d4539bacfc` |
| `src/vba/App_Release.bas` ↔ `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | `4ee7564f96de12e2892a6a1ebf23f08e2e574726` |

CRLF preservado em todos os 4 arquivos. **Engine (ABF) NÃO tocado nesta MD.**

## Mudanças resumo (2 arquivos no pacote VBA + 1 doc novo)

| Arquivo | Tipo | Linhas |
|---|---|---|
| `Teste_V2_Roteiros.bas` | +3 cenários V2_Canonica (CS_BORDA_MAX2/MAX5/NOTA_ZERO); +2 cenários E2E_Strikes (CS_E2E_REATIV2STRIKES AMARELO + CS_E2E_5EMPS verde); +2 helpers Private (TV2_FF_AtenderProximaEmpresa + TV2_FF_RodadaCompleta) | 1882 → 2269 (+387) |
| `App_Release.bas` | bump APP_BUILD_IMPORTADO + GERADO_EM | 190 → 194 (+4) |
| `auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md` (novo) | Documento dedicado com spec da resolução Onda 18 | n/a (novo) |

Detalhe técnico completo no manifesto
[`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO17.txt`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO17.txt)
e no documento de débito
[`auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md`](../../00_status/44_DEBITO_DT_17_REATIV_STRIKES.md).

## Cenários novos esperados em RESULTADO_QA_V2

| Suite | Cenário | Status esperado | Tema |
|---|---|---|---|
| `CANONICO` | `CS_BORDA_MAX2` | `OK` (verde) | Borda MAX_STRIKES=2: 1 strike mantém ATIVA, 2 strikes SUSPENSA_GLOBAL |
| `CANONICO` | `CS_BORDA_MAX5` | `OK` (verde) | Borda MAX_STRIKES=5: 4 strikes mantém ATIVA, 5 strikes SUSPENSA_GLOBAL |
| `CANONICO` | `CS_NOTA_ZERO` | `OK` (verde) | Regressão L12: nota=0 conta como strike (filtro `> 0` removido) |
| `STRIKES_E2E` | `CS_E2E_REATIV2STRIKES` | **`MANUAL_ASSISTIDO` (AMARELO)** | Débito DT-17-REATIV-STRIKES — documenta comportamento atual sem janela temporal pós-reativação. **Não bloqueia gate.** Resolução prioritária Onda 18. |
| `STRIKES_E2E` | `CS_E2E_5EMPS` | `OK` (verde) | Rodízio com 5 EMPs MAX_STRIKES=2 + 3 voltas com suspensão durante volta 2 |

Sintaxe Quarteto esperada: `V1=171/0+V2_Smoke=14/0+V2_Canonica=23/0+E2E_Strikes=66/0`
(ou similar conforme contagem real de asserts internos por cenário).

## Procedimento operacional

### Passo 1 — Resetar VBE (sempre, L7)

VBE: `Executar > Redefinir` (ou Ctrl+Pause/Break). Garante que
`Depurar > Compilar` está habilitado.

### Passo 2 — Rodar o import V3 delta

Janela Imediato:

```
ImportarPacoteV3_Delta "MICRO17", "f7aa84f+ONDA17.MD1B-cenarios-novos-borda-strikes"
```

Importa 2 arquivos modificados:

- `001-modulo/ABG-Teste_V2_Roteiros.bas` (substitui)
- `001-modulo/AAX-App_Release.bas` (substitui)

### Passo 3 — Compile manual

VBE: `Depurar > Compilar VBAProject`. Esperado: zero erros.

Sintomas que indicariam regressão:

| Sintoma | Causa provável |
|---|---|
| `Sub or Function not defined: TV2_FF_AtenderProximaEmpresa` | Roteiros não importou; refazer Passo 2 |
| `Sub or Function not defined: TV2_LimparNamespace` ou `TV2_FixtureFactory` | Engine (MD-17.1.a) não está importado; esta MD-17.1.b depende dele. Refazer MD-17.1.a primeiro. |
| `Compile error: Variable not defined` em qualquer ponto | Mismatch L14 não detectado — abortar e reportar |

### Passo 4 — Validar build importado

```
?GetBuildImportado
```

Esperado: `f7aa84f+ONDA17.MD1B-cenarios-novos-borda-strikes`.

### Passo 5 — Quarteto Mínimo (gate principal)

Janela Imediato ou Central V12 [3]:

```
CT_ValidarRelease_QuartetoMinimo
```

Esperado:

- `RESULTADO_GERAL = APROVADO`
- `V1=171/0` (regressão zero V1)
- `V2_Smoke=14/0` (regressão zero Smoke)
- `V2_Canonica=23/0` (eram 20; +3 cenários novos passando)
- `E2E_Strikes=66/0` (eram 64; +1 cenário novo verde, +1 cenário AMARELO contado em MANUAL=1, **não soma em FALHA**)

### Passo 6 — Verificar AMARELO esperado

Abrir aba `RESULTADO_QA_V2`. Filtrar pelo cenário `CS_E2E_REATIV2STRIKES`.

Esperado:

- Coluna STATUS = `MANUAL_ASSISTIDO`
- Coloração amarela (cor padrão de MANUAL_ASSISTIDO em `TV2_FormatarResultadoSheet`)
- Coluna OBS contém referência a `auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md`
- Coluna OBTIDO mostra estado factual: `STRIKES_TOTAL_HISTORICO=<X>`, `STATUS_POS_REATIV_E_1NOTA=<Y>`

**Esse é o resultado correto da Onda 17.** Não é falha; é débito declarado.

### Passo 7 — Salvar workbook ancora

Salvar como `V12-202-Z003-onda17-md1b` (ou convenção local) **somente após
Quarteto APROVADO**.

### Passo 8 — Reportar VR ao Claude

Cole no chat:

- ID da validação (`VR_<timestamp>`)
- Sintaxe completa do Quarteto
- Status do `CS_E2E_REATIV2STRIKES` (esperado: MANUAL_ASSISTIDO)
- `?GetBuildImportado`

## Critérios de sucesso MD-17.1.b

1. Compile manual passa limpo.
2. `GetBuildImportado` = `f7aa84f+ONDA17.MD1B-cenarios-novos-borda-strikes`.
3. `CT_ValidarRelease_QuartetoMinimo` APROVADO (regressão zero).
4. 3 cenários V2_Canonica (CS_BORDA_MAX2/MAX5/NOTA_ZERO) com STATUS=OK.
5. CS_E2E_5EMPS com STATUS=OK.
6. **CS_E2E_REATIV2STRIKES com STATUS=MANUAL_ASSISTIDO** (amarelo, não bloqueia).
7. Sintaxe E2E_Strikes mostra valor MANUAL=1 separado de FALHA=0.

Cumpridos todos os 7: MD-17.1.b fechado, próximo é MD-17.1.c (TV2_RunUiSmokeReadOnly).

## Rollback

Se Quarteto reprovar (qualquer FAIL>0) ou Excel crashar:

```
git restore src/vba/Teste_V2_Roteiros.bas
git restore src/vba/App_Release.bas
git restore local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas
git restore local-ai/vba_import/001-modulo/AAX-App_Release.bas
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO17.txt
rm auditoria/03_ondas/onda_17_test_first/02_PROCEDIMENTO_IMPORT_MD17_1_b.md
# auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md fica preservado
# (registro de débito é independente do código)
```

Reabrir backup `V12-202-Z003-onda17-md1a` (operador). Reportar
evidência no chat.

## Documentos relacionados

- [`.hbn/readbacks/0013-onda17-test-first.json`](../../../.hbn/readbacks/0013-onda17-test-first.json)
- [`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO17.txt`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO17.txt)
- [`auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md`](../../00_status/44_DEBITO_DT_17_REATIV_STRIKES.md) (spec Onda 18)
- [`auditoria/03_ondas/onda_17_test_first/01_PROCEDIMENTO_IMPORT_MD17_1_a.md`](01_PROCEDIMENTO_IMPORT_MD17_1_a.md) (MD anterior)
- [`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`](../../../usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md) (L12, L13, L18, L16, M11)

## Versão

- v1.0 — 2026-05-03 — procedimento inicial MD-17.1.b.
