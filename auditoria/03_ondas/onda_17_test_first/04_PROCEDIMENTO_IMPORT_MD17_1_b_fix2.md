---
titulo: Procedimento de import MD-17.1.b-fix2 — Re-aplicação Roteiros (cenários novos faltantes)
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1
---

# 04 — Procedimento de import MD-17.1.b-fix2

## Tema

Re-aplicação do `ABG-Teste_V2_Roteiros.bas` (com os 5 cenários novos
da MD-17.1.b) que ficou de fora do fix1 por erro de coordenação.
**Nenhum código VBA novo escrito** — apenas import do que já existe
em `src/vba/` e `local-ai/vba_import/` (com hash batendo).

## Causa raiz do fix2 (transparência)

| Item | Estado |
|---|---|
| Quarteto `VR_20260503_025114` | APROVADO ✅ mas **incompleto** |
| Sintaxe observada | `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0` |
| Sintaxe esperada (com cenários da MD-17.1.b) | `V1=171/0+V2_Smoke=14/0+V2_Canonica=23/0+E2E_Strikes=66/0` |
| Causa | Plano fix1 assumiu Opção B (manter workbook MD-17.1.b importado). Operador escolheu Opção A (mais limpa, restaurar para MD-17.1.a). Manifesto fix1 não foi atualizado para incluir Roteiros — só importou Engine + App_Release. |
| Workbook atual | Engine fix1 ✅ + Roteiros MD-17.1.a (sem cenários novos) ❌ |
| Solução | Re-importar Roteiros (que já está com 5 cenários) + bump label |

## Pré-condições

| Item | Esperado |
|---|---|
| Workbook | `03_05_2026 02_01_40PlanilhaCredenciamento-Homologacao-V3` (estado atual após fix1 — Quarteto APROVADO mas incompleto) |
| Build atual | `f7aa84f+ONDA17.MD1B-fix1-ativid-numerico-hash` |
| Quarteto pré-fix2 | APROVADO `VR_20260503_025114` (estado fix1) |
| `src/vba/` ↔ `local-ai/vba_import/` | shasum batendo (2 arquivos do MICRO17-fix2) |

## Hashes confirmados (sha1, src/vba autoritativo M11)

| Arquivo | sha1 |
|---|---|
| `src/vba/Teste_V2_Roteiros.bas` ↔ `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas` | `5dac02f138a63d029f042cc2731c90d4539bacfc` |
| `src/vba/App_Release.bas` ↔ `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | `2aa0eeabbca78d4682a114adf65b91bb6a67c84b` |

## Procedimento operacional (curto)

| # | Comando |
|---|---|
| 1 | VBE: `Executar > Redefinir` |
| 2 | Janela Imediato: `ImportarPacoteV3_Delta "MICRO17-fix2", "f7aa84f+ONDA17.MD1B-fix2-cenarios-aplicados"` |
| 3 | `Depurar > Compilar VBAProject` (zero erros esperado) |
| 4 | `?GetBuildImportado` → `f7aa84f+ONDA17.MD1B-fix2-cenarios-aplicados` |
| 5 | `CT_ValidarRelease_QuartetoMinimo` |
| 6 | Esperado: `RESULTADO_GERAL=APROVADO`, `V1=171/0+V2_Smoke=14/0+V2_Canonica=23/0+E2E_Strikes=66/0` (com MANUAL=1 separado em E2E_Strikes) |
| 7 | Conferir RESULTADO_QA_V2: 5 cenários novos visíveis (3 OK em CANONICO + 1 OK + 1 MANUAL_ASSISTIDO em STRIKES_E2E) |
| 8 | Salvar como `V12-202-Z003-onda17-md1b-fix2` (após APROVADO) |
| 9 | Reportar VR + sintaxe + status do AMARELO |

## Critérios de sucesso MD-17.1.b-fix2

1. Compile passa limpo.
2. `GetBuildImportado` = `f7aa84f+ONDA17.MD1B-fix2-cenarios-aplicados`.
3. **`V2_Canonica=23/0`** (era 20/0 antes).
4. **`E2E_Strikes=66/0`** (era 64/0 antes).
5. **`CS_E2E_REATIV2STRIKES` AMARELO** em RESULTADO_QA_V2 com `STRIKES_TOTAL_HISTORICO > 0` (ciclo real executado).
6. Quarteto `RESULTADO_GERAL=APROVADO`.

Cumpridos os 6 → MD-17.1.b fechado de fato → próximo é MD-17.1.c.

## Lição candidata para PHAGOCYTOSIS (a destilar em MD-17.5)

**M14 (meta)**: planos de fix em onda multi-microdelta devem considerar todas as
opções de rollback do operador. Ao oferecer "Opção A (restaurar para microdelta
N-2)" e "Opção B (sobrescrever no estado atual N-1)", o manifesto do fix
precisa ser **válido para ambas opções** — caso contrário, depende da
escolha do operador para estar completo. Solução: incluir todos os arquivos
modificados desde N-2 no manifesto do fix, mesmo que alguns "já estejam
importados" na Opção B (V3 substitui idempotente).

## Documentos relacionados

- [`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO17-fix2.txt`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO17-fix2.txt)
- [`auditoria/03_ondas/onda_17_test_first/03_PROCEDIMENTO_IMPORT_MD17_1_b_fix1.md`](03_PROCEDIMENTO_IMPORT_MD17_1_b_fix1.md) (fix1 — apenas Engine)
- [`auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md`](../../00_status/44_DEBITO_DT_17_REATIV_STRIKES.md)

## Versão

- v1.0 — 2026-05-03 — fix2 inicial.
