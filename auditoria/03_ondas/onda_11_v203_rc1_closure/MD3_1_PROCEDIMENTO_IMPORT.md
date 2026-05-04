---
titulo: Procedimento MD-3.1 — Central V2 [20] Quarteto (UX) — Onda 11 V12.0.0203-rc1 closure
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-02
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1 (Credenciamento)
---

# MD-3.1 — Procedimento de import (Central V2 [20] Quarteto)

## O que entrega

Adiciona opção `[20] Validacao release Quarteto` ao menu da
`Central_Testes_V2.CT2_AbrirCentral`. Aplica em ambos canônico
(produção, hoje com [12]-[14]) e src/vba (versão Ondas 2-7,
com [12]-[19]) preservando os slots `[15]-[19]` reservados para
reincorporações das Ondas 12-16 (CNAE/Diag/CFG/IDM/RDZ).

| Campo | Valor |
|---|---|
| Microdelta | MD-3.1 |
| Build label | `f7aa84f+ONDA11.MD3-1-DT1-quarteto-menu-incremental` |
| Manifesto | `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO11.txt` |
| Arquivos modificados | `ABE-Central_Testes_V2.bas` + `AAX-App_Release.bas` |
| Drift G7 | Pré-existente em Central_Testes_V2 (D1) — preservado intencionalmente |
| Risco | Mínimo — 3 linhas de código adicionadas; Trio intocado |

## Passos no Excel

1. Abrir `V12-202-AA-onda11-md3` (ancora pós-MD-3 verde do operador).
2. `?GetBuildImportado` → deve retornar `f7aa84f+ONDA11.MD3-DT1-quarteto-release-gate-incremental`.
3. `ImportarPacoteV3_Delta "MICRO11", "f7aa84f+ONDA11.MD3-1-DT1-quarteto-menu-incremental"`.
4. Compile manual (`Debug → Compile VBAProject`) — esperado: limpo.
5. `?GetBuildImportado` → deve retornar `f7aa84f+ONDA11.MD3-1-DT1-quarteto-menu-incremental`.
6. `CT2_AbrirCentral` — confirmar visualmente que opção `[20] Validacao release Quarteto` aparece.
7. Selecionar `[20]` → executa `CT_ValidarRelease_QuartetoMinimo` (mesmo gate do Imediato).
8. Salvar workbook como `V12-202-AB-onda11-md3-1` (ou convenção local).

## Gate

MD-3.1 fica **APROVADO** quando:

- [ ] Compile manual limpo após import
- [ ] Menu da Central V2 mostra opção `[20] Validacao release Quarteto`
- [ ] Seleção de `[20]` produz VR_<id> APROVADO com sintaxe canônica
- [ ] Build label persistido = `f7aa84f+ONDA11.MD3-1-DT1-quarteto-menu-incremental`

## Rollback

```bash
git checkout src/vba/Central_Testes_V2.bas src/vba/App_Release.bas
git checkout local-ai/vba_import/001-modulo/ABE-Central_Testes_V2.bas
git checkout local-ai/vba_import/001-modulo/AAX-App_Release.bas
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO11.txt
```

Workbook ancora estável: `V12-202-AA-onda11-md3` (pós-MD-3 verde).

## Após APROVADO

Prosseguir para MD-5 (rc1 final). MD-4 (mover CSVs) pode ser
executado em paralelo — não toca código VBA.

## Versão

- v1.0 — 2026-05-02 — procedimento inicial MD-3.1.
