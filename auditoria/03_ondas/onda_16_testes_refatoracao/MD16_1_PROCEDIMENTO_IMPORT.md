---
titulo: Procedimento MD-16.1 — Central V12 + Central V2 (textos reorganizados, Quarteto destacado)
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203-rc1 → ONDA16.MD1
data: 2026-05-02
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1 (Credenciamento)
---

# MD-16.1 — Procedimento de import (Central V12 + V2 textos)

## O que entrega

Reorganização hierárquica das mensagens da Central de Testes V12 e V2,
com Quarteto destacado como gate oficial e build atual no cabeçalho.
Sem novo form. Apenas texto do `InputBox` + 1 novo `Case "3"` na V12
para atalho direto ao Quarteto.

| Campo | Valor |
|---|---|
| Onda | 16 (Refatoração testes V12.0.0203 → rc2) |
| Microdelta | MD-16.1 |
| Build label | `f7aa84f+ONDA16.MD1-central-textos-incremental` |
| Manifesto | `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO13.txt` |
| Arquivos modificados | `AAZ-Central_Testes.bas`, `ABE-Central_Testes_V2.bas`, `AAX-App_Release.bas` |
| Espelho src/vba | sincronizado em todos os 3 arquivos |
| Risco | Baixo — apenas texto + 1 case novo |

## Pre-flight L14 cumprido

- `AppRelease_BuildImportado()` — Public Function existente em
  `AAX-App_Release.bas` (linha 48)
- `CT_ValidarRelease_QuartetoMinimo` — Public Sub em
  `ABH-Teste_Validacao_Release.bas` linha 95 (entregue MD-3 Onda 11)
- Handlers `CT2_Executar*` existentes preservados
- Nenhum `Public Type` novo — G8 OK
- Sem heurística — G6 enforced

## Layout esperado dos menus pós-import

### Central V12 / Transição (`CT_AbrirCentral`)

```
=== CENTRAL DE TESTES V12 / TRANSICAO ===
Build: f7aa84f+ONDA16.MD1-central-textos-incremental
Gate oficial de release: [3] Quarteto Minimo

>> GATES DE RELEASE
[3] Quarteto Direto: V1 + V2_Smoke + V2_Canonica + E2E_Strikes (~12 min)  *** OFICIAL rc1+ ***

>> ENTRY POINTS
[1] Bateria Oficial V1 (legado, rapida ~5 min / assistida ~8 min)
[2] Central de Testes V2 (suites detalhadas + utilitarios)

Digite o numero: [3]
```

### Central V2 (`CT2_AbrirCentral`)

```
=== CENTRAL DE TESTES V2 ===
Build: f7aa84f+ONDA16.MD1-central-textos-incremental
Gate oficial: [20] Quarteto Minimo

>> GATES DE RELEASE
[12] Trio: V1 + V2_Smoke + V2_Canonica (~10 min)
[20] Quarteto: V1 + V2_Smoke + V2_Canonica + E2E_Strikes (~12 min)  *** OFICIAL ***

>> SUITES DE TESTE
[1] Smoke rapido (~2 min)
[2] Smoke assistido (~3 min)
[5] Suite canonica (fundacao, ~3 min)
[3] Stress deterministico (~3 min)
[4] Stress assistido (~5 min)
[13] Filtros deterministicos (~1 min)
[14] Strikes na avaliacao E2E (~2 min)

>> VISUALIZACAO (abrir aba)
[7] RESULTADO_QA_V2
[8] CATALOGO_CENARIOS_V2
[9] HISTORICO_QA_V2
[10] TESTE_TRILHA
[11] AUDIT_TESTES

>> UTILITARIOS
[6] Roteiro assistido V2

Digite o numero: [20]
```

## Passos no Excel

1. Abrir workbook ancora `V12-202-AB-onda11-rc1` (build atual:
   `f7aa84f+v12.0.0203-rc1`).
2. `?GetBuildImportado` no Imediato (esperado:
   `f7aa84f+v12.0.0203-rc1`).
3. `ImportarPacoteV3_Delta "MICRO13", "f7aa84f+ONDA16.MD1-central-textos-incremental"`.
4. Compile manual: `Debug → Compile VBAProject` (esperado: limpo).
5. `?GetBuildImportado` (esperado: `f7aa84f+ONDA16.MD1-central-textos-incremental`).
6. **Validação visual da Central V12:**
   - `CT_AbrirCentral` no Imediato.
   - Confirmar novo menu com `[3] Quarteto Direto *** OFICIAL rc1+ ***` no
     topo, default `[3]`.
   - Cancelar (não rodar agora).
7. **Validação visual da Central V2:**
   - `CT2_AbrirCentral` no Imediato.
   - Confirmar novo menu hierárquico em 4 seções (`>> GATES DE RELEASE`,
     `>> SUITES DE TESTE`, `>> VISUALIZACAO`, `>> UTILITARIOS`).
   - `[20] Quarteto *** OFICIAL ***` em destaque, default `[20]`.
   - Cancelar.
8. **Gate de regressão zero (Quarteto canônico):**
   - `CT_ValidarRelease_QuartetoMinimo`.
   - Esperado: `VR_<id>` APROVADO com sintaxe
     `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0`.
9. Salvar workbook como `V12-202-AC-onda16-md1` (ou convenção local).
10. Reportar de volta: VR_id do Quarteto + status APROVADO + screenshots
    dos novos menus.

## Gate

MD-16.1 fica **APROVADO** quando:

- [ ] Compile manual limpo após import
- [ ] Build label persistido = `f7aa84f+ONDA16.MD1-central-textos-incremental`
- [ ] Central V12 mostra `[3] Quarteto Direto` com cabeçalho de build
- [ ] Central V2 mostra hierarquia em 4 seções com Quarteto destacado
- [ ] `CT_ValidarRelease_QuartetoMinimo` retorna 171/0+14/0+20/0+64/0 (regressão zero)

## Rollback

```bash
git checkout src/vba/Central_Testes.bas src/vba/Central_Testes_V2.bas src/vba/App_Release.bas
git checkout local-ai/vba_import/001-modulo/AAZ-Central_Testes.bas
git checkout local-ai/vba_import/001-modulo/ABE-Central_Testes_V2.bas
git checkout local-ai/vba_import/001-modulo/AAX-App_Release.bas
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO13.txt
```

Workbook ancora estável: `V12-202-AB-onda11-rc1` (build rc1).

## Após APROVADO

Prosseguir para MD-16.2 (Coluna `DURACAO_MS` em `RESULTADO_QA_V2` +
threshold em CONFIG).

## Versão

- v1.0 — 2026-05-02 — procedimento inicial MD-16.1.
