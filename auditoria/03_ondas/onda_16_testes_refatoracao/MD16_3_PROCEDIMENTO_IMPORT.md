---
titulo: Procedimento MD-16.3 — EVOLUCAO_TESTES + média móvel + regressão + opção [21]
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203 → ONDA16.MD3
data: 2026-05-02
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1 (Credenciamento)
---

# MD-16.3 — Procedimento de import (EVOLUCAO_TESTES)

## O que entrega

Sheet nova `EVOLUCAO_TESTES` com tracking histórico das execuções V2,
média móvel das últimas 5 execuções por suite, indicador de
regressão (duração > média*1.5) e nova opção `[21]` na Central V2.

| Campo | Valor |
|---|---|
| Onda | 16 (Refatoração testes V12.0.0203 → rc2) |
| Microdelta | MD-16.3 |
| Build label | `f7aa84f+ONDA16.MD3-evolucao-testes-incremental` |
| Manifesto | `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO15.txt` |
| Arquivos modificados | ABL (NOVO), ABF, ABE, AAX, MAPA-PREFIXOS |
| Espelho src/vba | sincronizado (incluindo `Util_Evolucao.bas` novo) |
| Risco | Baixo — módulo isolado; hook silencioso em `TV2_FinalizarExecucao` |

## Pre-flight L14 cumprido

- `gTV2TimerInicio` + `TV2_COL_HIST_DURACAO_MS` reusados de MD-16.2
- `Util_Evolucao_RegistrarExecucao` com `On Error GoTo falhaProc` —
  hook silencioso (não quebra suite chamadora)
- Sem novo `Public Type` — G8 OK
- Sem heurística — G6 enforced
- Sub/Function balanceados em ABL: 3/3 e 3/3
- Espelho src/vba ↔ canônico hashes batendo em 4 arquivos
- Convenção de prefixo respeitada: `ABL-` livre antes do MD-16.3

## Layout esperado em `EVOLUCAO_TESTES` pós-import

| Coluna | Header | Conteúdo |
|---|---|---|
| A | EXECUCAO_ID | TV2_yyyymmdd_hhnnss |
| B | SUITE | Nome da macro chamadora |
| C | DT_EXEC | Timestamp |
| D | DURACAO_MS | Long ms (de MD-16.2) |
| E | OK | nº asserts OK |
| F | FALHA | nº asserts FALHA |
| G | MEDIA_5_MS | Média móvel das últimas 5 execuções da mesma suite |
| H | DELTA_PCT | Variação % vs MEDIA_5_MS (formato `0.0;[Red]-0.0;0.0`) |
| I | REGRESSAO? | Boolean — TRUE se DURACAO_MS > MEDIA_5_MS * 1.5 |

Cor condicional quando `REGRESSAO?=TRUE`: REGRESSAO?, DURACAO_MS e
DELTA_PCT pintadas em vermelho (`#FFC7CE`).

## Comportamento esperado

1. **Primeira execução de qualquer suite** → linha gravada com
   `MEDIA_5_MS=0`, `DELTA_PCT=0`, `REGRESSAO?=FALSE` (sem histórico).
2. **2ª execução da mesma suite** → `MEDIA_5_MS` calculada a partir da
   1ª; DELTA_PCT pode ser positivo/negativo; REGRESSAO? só dispara
   se a 2ª for >150% da 1ª.
3. **A partir da 5ª execução** → média estável das últimas 5 da suite.
4. **Hook silencioso**: se `Util_Evolucao` falhar por algum motivo, a
   suite chamadora não quebra (`On Error GoTo falhaProc`).

## Passos no Excel

1. Abrir workbook ancora `V12-202-AC-onda16-md2` (build atual:
   `…ONDA16.MD2-duracao-ms-incremental`).
2. `?GetBuildImportado` (esperado: `…MD2-duracao-ms-incremental`).
3. `ImportarPacoteV3_Delta "MICRO15", "f7aa84f+ONDA16.MD3-evolucao-testes-incremental"`.
4. Compile manual: `Debug → Compile VBAProject` (esperado: limpo).
5. `?GetBuildImportado` (esperado: `f7aa84f+ONDA16.MD3-evolucao-testes-incremental`).
6. **Validação visual da sheet nova:**
   - `TV2_RunSmoke` no Imediato (~2 min) — primeira execução.
   - Verificar criação de `EVOLUCAO_TESTES` automaticamente.
7. **Repetir Smoke 2-3 vezes** para acumular histórico:
   - Após 2ª execução: `MEDIA_5_MS` aparece, `DELTA_PCT` calculado.
   - Após 3ª: idem com mais dados na média.
8. **Testar opção [21]:**
   - `CT2_AbrirCentral` → digitar `21`.
   - Confirmar que abre `EVOLUCAO_TESTES` com formatação visual
     (header colorido, AutoFilter, AutoFit).
9. **Gate de regressão zero (Quarteto canônico):**
   - `CT_ValidarRelease_QuartetoMinimo`.
   - Esperado: APROVADO `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0`.
   - Notar: 4 linhas novas em `EVOLUCAO_TESTES` após Quarteto
     (V1 não passa pela engine V2; só V2_Smoke + V2_Canonica + E2E_Strikes).
   - Wait — V1_RAPIDA também aparece se chamar V1 via Trio/Quarteto
     pelo wrapper que usa `BO_RodarBateriaOficial` (sem hook V2).
     **Apenas suites V2 são registradas** em `EVOLUCAO_TESTES`.
10. Salvar workbook como `V12-202-AC-onda16-md3` (ou convenção local).

## Gate

MD-16.3 fica **APROVADO** quando:

- [ ] Compile manual limpo
- [ ] Build label persistido = `f7aa84f+ONDA16.MD3-evolucao-testes-incremental`
- [ ] Sheet `EVOLUCAO_TESTES` criada após primeira execução V2
- [ ] Linha gravada com 9 colunas populadas (EXECUCAO_ID a REGRESSAO?)
- [ ] Após 2-3 execuções da mesma suite, `MEDIA_5_MS` populada
- [ ] Cor condicional aplicada quando `REGRESSAO?=TRUE`
- [ ] Opção `[21]` na Central V2 abre a sheet
- [ ] Quarteto retorna 171/0+14/0+20/0+64/0 (regressão zero)

## Rollback

```bash
git checkout src/vba/Util_Evolucao.bas src/vba/Teste_V2_Engine.bas src/vba/Central_Testes_V2.bas src/vba/App_Release.bas
git checkout local-ai/vba_import/001-modulo/ABL-Util_Evolucao.bas
git checkout local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas
git checkout local-ai/vba_import/001-modulo/ABE-Central_Testes_V2.bas
git checkout local-ai/vba_import/001-modulo/AAX-App_Release.bas
git checkout local-ai/vba_import/000-MAPA-PREFIXOS.txt
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO15.txt
```

Workbook ancora estável: `V12-202-AC-onda16-md2` (build MD-16.2).

Para limpar a sheet `EVOLUCAO_TESTES` após rollback, deletá-la
manualmente no workbook (não é importada — é criada lazy).

## Após APROVADO

Prosseguir para MD-16.4 (`Util_PDF.bas` com nomeação humano-legível
incluindo CNPJ + emissão automática + suite `TV2_RunPdfDeterminismo`
+ opção `[22]` + sheet `RPT_PDFS_GERADOS`).

## Versão

- v1.0 — 2026-05-02 — procedimento inicial MD-16.3.
