---
titulo: Procedimento MD-16.4 — Util_PDF.bas + CNPJ + suite determinismo + opções [22] e [23]
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203 → ONDA16.MD4
data: 2026-05-02
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1 (Credenciamento)
---

# MD-16.4 — Procedimento de import (Util_PDF + CNPJ)

## O que entrega

Sistema de geração de PDFs auditáveis com nome humano-legível
incluindo CNPJ da empresa, hash payload determinístico (DJB2), sheet
de controle `RPT_PDFS_GERADOS`, suite `TV2_RunPdfDeterminismo` (5
cenários) e duas novas opções na Central V2: `[22]` (abrir RPT) e
`[23]` (rodar suite PDF determinismo).

| Campo | Valor |
|---|---|
| Onda | 16 (Refatoração testes V12.0.0203 → rc2) |
| Microdelta | MD-16.4 |
| Build label | `f7aa84f+ONDA16.MD4-util-pdf-cnpj-incremental` |
| Manifesto | `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO16.txt` |
| Arquivos modificados | AAW (NOVO), ABM (NOVO), ABG, ABE, AAX, MAPA |
| Espelho src/vba | sincronizado (incluindo 2 arquivos novos) |
| Risco | Médio — módulos novos + integração com Excel `ExportAsFixedFormat` (pode ser lento em macOS) |

## Pre-flight L14 cumprido

- `SHEET_EMPRESAS` + `COL_EMP_ID=1` + `COL_EMP_CNPJ=2` confirmados em `Const_Colunas.bas`
- `Util_NormalizarDocumentoChave` Public Function em `AAE-Util_Planilha.bas`
- `AppRelease_BuildImportado` Public Function em `AAX-App_Release.bas`
- `TV2_InitExecucao` / `TV2_LogAssert` / `TV2_FinalizarExecucao` / `TV2_ExecucaoAtualId` em ABF
- Sem novo `Public Type` — G8 OK
- Sem heurística — G6 enforced
- Sub/Function balanceados: AAW 2/2, ABM 6 sub/6 endsub + 18 func/18 endfunc, ABG 15/15, ABE 8/8
- Hashes batendo em todos os 5 arquivos (src/vba ↔ canônico)

## Padrão de nomeação canônico de PDFs (decidido em hearback)

| Tipo | Padrão | Exemplo |
|---|---|---|
| PRE_OS | `PREOS_<PREOS_ID>_<CNPJ>_<DATA>.pdf` | `PREOS_PRE-2025-001_12345678000199_2026-05-02.pdf` |
| OS | `OS_<OS_ID>_<CNPJ>_<DATA>.pdf` | `OS_2025-001_12345678000199_2026-05-02.pdf` |
| Avaliação | `AVAL_<OS_ID>_<CNPJ>_<DATA>.pdf` | `AVAL_2025-001_12345678000199_2026-05-02.pdf` |
| Ciclo por empresa | `CICLO_<EXEC_ID>_<CNPJ>_<DATA>.pdf` | `CICLO_TV2_xxx_12345678000199_2026-05-02.pdf` |
| Ciclo resumo geral | `CICLO_RESUMO_<EXEC_ID>_<DATA>.pdf` | `CICLO_RESUMO_TV2_xxx_2026-05-02.pdf` |

Regras:
- **CNPJ limpo** (só dígitos, via `Util_NormalizarDocumentoChave`)
- **Data** `YYYY-MM-DD` (ordenável)
- **Sufixo `_NN`** automático em colisão
- **Hash não vai no nome** — vai em metadata interno do PDF (rodapé) + sheet `RPT_PDFS_GERADOS`
- Diretório: `auditoria/04_evidencias/V12.0.0203/pdfs/<EXECUCAO_ID>/`

## Schema da sheet `RPT_PDFS_GERADOS`

| Col | Header | Conteúdo |
|---|---|---|
| A | EXECUCAO_ID | TV2_yyyymmdd_hhnnss |
| B | TIPO | PREOS / OS / AVAL / CICLO / CICLO_RESUMO |
| C | ENTIDADE_ID | PRE_OS_ID, OS_ID, EXEC_ID conforme tipo |
| D | EMP_CNPJ | CNPJ normalizado |
| E | CAMINHO | path absoluto do PDF |
| F | NOME_ARQUIVO | só nome |
| G | HASH_PAYLOAD | DJB2 8 chars hex |
| H | TAMANHO_BYTES | bytes do PDF |
| I | DATA_GERACAO | timestamp |
| J | OBS | notas |

## Hooks automáticos em produção (opcional, default OFF)

`Util_PDF_AutomaticoHabilitado()` lê `CONFIG.O` (linha de valores).
Default `FALSE` — operador habilita escrevendo `TRUE` em `CONFIG!O2`
quando precisar de auditoria forense automática em produção (Q4
hearback).

## Passos no Excel

1. Abrir workbook ancora `V12-202-AC-onda16-md3` (build atual:
   `…ONDA16.MD3-fix1-evolucao-testes-incremental`).
2. `?GetBuildImportado` (esperado: `…MD3-fix1-…`).
3. `ImportarPacoteV3_Delta "MICRO16", "f7aa84f+ONDA16.MD4-util-pdf-cnpj-incremental"`.
4. Compile manual: `Debug → Compile VBAProject` (esperado: limpo).
5. `?GetBuildImportado` (esperado: `f7aa84f+ONDA16.MD4-util-pdf-cnpj-incremental`).
6. **Validação visual da Central V2:**
   - `CT2_AbrirCentral`.
   - Confirmar `[22] RPT_PDFS_GERADOS` em `>> VISUALIZACAO`.
   - Confirmar `[23] PDF determinismo (fixture forense, ~10s)` em `>> SUITES AUXILIARES`.
7. **Validação da suite `TV2_RunPdfDeterminismo`:**
   - Selecionar `[23]` no menu (ou rodar `TV2_RunPdfDeterminismo` direto).
   - Esperado: `Suite V2 concluida. OK=5 | FALHA=0 | MANUAL=0`.
   - Cenários: CT_PDF_001 (hash 8 chars), CT_PDF_002 (idempotência), CT_PDF_003 (mudança detectada), CT_PDF_004 (nome canônico), CT_PDF_005 (caminho não-vazio).
8. **Inspeção dos PDFs gerados:**
   - Abrir Finder/Explorer em `auditoria/04_evidencias/V12.0.0203/pdfs/<EXEC_ID>/`.
   - Confirmar PDF `OS_OS-PDFTEST-001_*_2026-05-02.pdf` (sem CNPJ porque EMPRESAS não tem `OS-PDFTEST-001`).
   - Abrir o PDF: header com build/exec_id, rodapé com `HASH_PAYLOAD: <hex>` e `RESUMO: TIPO=...`.
9. **Validação de [22]:**
   - Selecionar `[22]` no menu da Central V2.
   - Confirmar abertura de `RPT_PDFS_GERADOS` com 1 linha registrada (do CT_PDF_004/005).
10. **Gate de regressão zero (Quarteto canônico):**
    - `CT_ValidarRelease_QuartetoMinimo`.
    - Esperado: APROVADO `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0`.
11. Salvar workbook como `V12-202-AC-onda16-md4` (ou convenção local).

## Gate

MD-16.4 fica **APROVADO** quando:

- [ ] Compile manual limpo
- [ ] Build label persistido = `f7aa84f+ONDA16.MD4-util-pdf-cnpj-incremental`
- [ ] Modulos `Util_Empresa` e `Util_PDF` visíveis no VBE
- [ ] Opções `[22]` e `[23]` aparecem na Central V2
- [ ] `TV2_RunPdfDeterminismo` retorna `OK=5 FALHA=0`
- [ ] PDF gerado em `auditoria/04_evidencias/V12.0.0203/pdfs/<EXEC_ID>/` com nome canônico
- [ ] PDF abre e mostra HASH_PAYLOAD no rodapé
- [ ] `RPT_PDFS_GERADOS` populada
- [ ] Quarteto retorna 171/0+14/0+20/0+64/0 (regressão zero)

## Rollback

```bash
git checkout src/vba/Util_Empresa.bas src/vba/Util_PDF.bas src/vba/Teste_V2_Roteiros.bas src/vba/Central_Testes_V2.bas src/vba/App_Release.bas
git checkout local-ai/vba_import/001-modulo/AAW-Util_Empresa.bas
git checkout local-ai/vba_import/001-modulo/ABM-Util_PDF.bas
git checkout local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas
git checkout local-ai/vba_import/001-modulo/ABE-Central_Testes_V2.bas
git checkout local-ai/vba_import/001-modulo/AAX-App_Release.bas
git checkout local-ai/vba_import/000-MAPA-PREFIXOS.txt
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO16.txt
```

Workbook ancora estável: `V12-202-AC-onda16-md3` (build MD-16.3 fix1).

Para limpar PDFs gerados após rollback, deletar pasta
`auditoria/04_evidencias/V12.0.0203/pdfs/` manualmente (não é
versionada).

## Após APROVADO

Prosseguir para MD-16.5 (Filtros Fase 1 — inventário forms com
filtros + tabela canônica de extensão do padrão Empresa↔Entidade).

## Versão

- v1.0 — 2026-05-02 — procedimento inicial MD-16.4.
