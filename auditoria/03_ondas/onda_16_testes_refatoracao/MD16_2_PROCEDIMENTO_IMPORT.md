---
titulo: Procedimento MD-16.2 — DURACAO_MS em HISTORICO_QA_V2 + threshold em CONFIG
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203 → ONDA16.MD2
data: 2026-05-02
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1 (Credenciamento)
---

# MD-16.2 — Procedimento de import (DURACAO_MS + threshold)

## O que entrega

Granularidade temporal nas execuções V2: cada `TV2_Run*` agora grava
duração em milissegundos na coluna J de `HISTORICO_QA_V2`, com cor
condicional baseada em threshold parametrizável em `CONFIG.N`
(default 500 ms).

| Campo | Valor |
|---|---|
| Onda | 16 (Refatoração testes V12.0.0203 → rc2) |
| Microdelta | MD-16.2 |
| Build label | `f7aa84f+ONDA16.MD2-duracao-ms-incremental` |
| Manifesto | `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO14.txt` |
| Arquivos modificados | `AAB-Const_Colunas.bas`, `AAD-Util_Config.bas`, `ABF-Teste_V2_Engine.bas`, `AAX-App_Release.bas` |
| Espelho src/vba | sincronizado em todos os 4 arquivos |
| Risco | Baixo — coluna nova isolada; código existente preservado |

## Pre-flight L14 cumprido

- `SHEET_CONFIG` + `LINHA_CFG_VALORES` constantes existentes em `Const_Colunas.bas`
- `TV2_InitExecucao` (linha 50 ABF) e `TV2_FinalizarExecucao` (linha 84 ABF) Public Sub preservados
- `TV2_EnsureHistoricoSheet` (Private, ABF) já tinha 9 colunas; adicionada 10ª (J = DURACAO_MS)
- `TV2_FormatarHistoricoSheet` (Private, ABF) estendida: AutoFit/AutoFilter J + cor condicional
- `Timer` é função nativa VBA (precisão sub-segundo via fração decimal)
- Sem novo `Public Type` — G8 OK
- Sem heurística — G6 enforced
- Sub/Function balanceados em ABF: 51/51 e 60/60
- Espelho src/vba ↔ canônico hashes batendo

## Layout esperado em `HISTORICO_QA_V2` pós-import

| Coluna | Header | Conteúdo |
|---|---|---|
| A | EXECUCAO_ID | TV2_yyyymmdd_hhnnss |
| B | SUITE | Nome da macro chamadora |
| C | DATA_HORA | timestamp da finalização |
| D | OK | nº asserts OK |
| E | FALHA | nº asserts FALHA |
| F | MANUAL | nº asserts pendentes assistidos |
| G | TOTAL | OK + FALHA + MANUAL |
| H | CSV_FALHAS | path do CSV de falhas (se houver) |
| I | OBS_EXPORTACAO | observação |
| **J** | **DURACAO_MS** | **duração em ms (Timer * 1000)** |

Cor condicional na coluna J:
- Verde (`#C6EFCE`) se < threshold/2 (default 250 ms)
- Amarelo (`#FFEB9C`) entre threshold/2 e threshold (250-500 ms)
- Vermelho (`#FFC7CE`) se >= threshold (500 ms)

## Layout esperado em `CONFIG`

Coluna nova `N` (`COL_CFG_THRESHOLD_TESTE_LENTO_MS`):
- Linha 1: header (livre — operador pode escrever "THRESHOLD_TESTE_LENTO_MS")
- Linha 2 (`LINHA_CFG_VALORES`): valor em ms (ex.: `500`)
- Vazio = fallback default 500 ms

## Passos no Excel

1. Abrir workbook ancora `V12-202-AC-onda16-md1` (build atual:
   `f7aa84f+ONDA16.MD1-central-textos-incremental`).
2. `?GetBuildImportado` (esperado: `…MD1-central-textos-incremental`).
3. `ImportarPacoteV3_Delta "MICRO14", "f7aa84f+ONDA16.MD2-duracao-ms-incremental"`.
4. Compile manual: `Debug → Compile VBAProject` (esperado: limpo).
5. `?GetBuildImportado` (esperado: `f7aa84f+ONDA16.MD2-duracao-ms-incremental`).
6. `?GetThresholdTesteLentoMS` (esperado: `500`).
7. **Validação visual da coluna nova:**
   - `TV2_RunSmoke` no Imediato (~2 min).
   - Abrir `HISTORICO_QA_V2` (opção `[9]` da Central V2).
   - Confirmar coluna J `DURACAO_MS` populada com valor numérico (ex.: ~120000 ms).
   - Confirmar cor condicional aplicada (provavelmente vermelha, > 500 ms).
8. **Opcional — testar threshold parametrizável:**
   - Editar `CONFIG!N2` para outro valor (ex.: `200000`).
   - Rodar nova execução e ver cor mudar.
9. **Gate de regressão zero (Quarteto canônico):**
   - `CT_ValidarRelease_QuartetoMinimo`.
   - Esperado: APROVADO `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0`.
   - DURACAO_MS aparece em todas as 4 linhas de Smoke/Canonica/E2E (V1 não passa pela engine V2).
10. Salvar workbook como `V12-202-AC-onda16-md2` (ou convenção local).

## Gate

MD-16.2 fica **APROVADO** quando:

- [ ] Compile manual limpo
- [ ] Build label persistido = `f7aa84f+ONDA16.MD2-duracao-ms-incremental`
- [ ] `GetThresholdTesteLentoMS` retorna valor (default 500)
- [ ] HISTORICO_QA_V2 mostra header `DURACAO_MS` em J
- [ ] Linhas novas de execução têm DURACAO_MS populado
- [ ] Cor condicional aplicada (verde/amarelo/vermelho)
- [ ] Quarteto retorna 171/0+14/0+20/0+64/0 (regressão zero)

## Rollback

```bash
git checkout src/vba/Const_Colunas.bas src/vba/Util_Config.bas src/vba/Teste_V2_Engine.bas src/vba/App_Release.bas
git checkout local-ai/vba_import/001-modulo/AAB-Const_Colunas.bas
git checkout local-ai/vba_import/001-modulo/AAD-Util_Config.bas
git checkout local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas
git checkout local-ai/vba_import/001-modulo/AAX-App_Release.bas
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO14.txt
```

Workbook ancora estável: `V12-202-AC-onda16-md1` (build MD-16.1).

## Após APROVADO

Prosseguir para MD-16.3 (Aba `EVOLUCAO_TESTES` + sparkline +
indicador de regressão + opção `[21]` na Central).

## Versão

- v1.0 — 2026-05-02 — procedimento inicial MD-16.2.
