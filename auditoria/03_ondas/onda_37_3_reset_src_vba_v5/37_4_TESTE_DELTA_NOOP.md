---
titulo: Onda 37.4 — Microdelta NOOP teste do fluxo ImportarPacoteV3_Delta
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-25
autor: claude-opus-4-7
parente: onda_37_3_reset_src_vba_v5 (executada sob mesmo readback 0093)
---

# Onda 37.4 — Teste NOOP do ImportarPacoteV3_Delta

## Por que existe

Onda 37.2 e Onda 37.3 usaram `ImportarPacoteV3()` completo (importa 34 mod + 13 forms).
Compile falhou na 37.2 com fantasma de cache; 37.3 fez reset src/vba para V5 puro.
Workbook V5 limpo validou com CT_ValidarRelease_TrioMinimo APROVADO.

Esta micro-onda valida o caminho operacional CORRETO — `ImportarPacoteV3_Delta`
com manifesto pequeno, conforme padrao historico de MICRO01..MICRO62.

Sem este teste, nao podemos devolver o bastao para Codex retomar Onda 38
(correcao Rel_OSEmpresa/Rel_Emp_Serv) com confianca que microdeltas funcionam
no workbook V5 atual.

## Mudancas

Arquivo unico modificado: `src/vba/App_Release.bas` (3 linhas, somente carimbo):

| Constante | Antes | Depois |
|---|---|---|
| `APP_BUILD_IMPORTADO` | `"e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix"` | `"e43352f+ONDA37.4-teste-delta-noop"` |
| `APP_BUILD_BRANCH` | `"codex/v12-0-0205-estabilizacao-docs"` | `"codex/v12-0-0206-planejamento"` |
| `APP_BUILD_GERADO_EM` | `"2026-05-23 16:46"` | `"2026-05-25 00:30"` |

Manifesto novo: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA37-4-TESTE-NOOP.txt`
com unica entrada `M|001-modulo/AAX-App_Release.bas`.

## Procedimento operacional (3 passos)

Passo 1 — terminal, sincronizar espelho:

```
bash local-ai/scripts/publicar_vba_import_v2.sh --apply
```

Esperado: AAX-App_Release.bas no vba_import recebe o novo carimbo (G7 verde).

Passo 2 — VBE Janela Imediata, importar so esse 1 arquivo:

```
ImportarPacoteV3_Delta "ONDA37-4-TESTE-NOOP", "e43352f+ONDA37.4-teste-delta-noop"
```

Esperado: `M=1 | F=0 | err=0 | skip=0`.

Passo 3 — VBE Janela Imediata, validar:

```
?GetBuildImportado
```

Esperado: `e43352f+ONDA37.4-teste-delta-noop`

```
CT_ValidarRelease_TrioMinimo
```

Esperado: APROVADO com mesmos contadores `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0`.

## Resultado esperado

**Se passar tudo**: `_Delta` funciona perfeitamente no workbook V5 atual.
Codex pode retomar Onda 38 via microdeltas.

**Se falhar**: bug real (provavelmente no proprio Importador V3 ou no manifesto).
Cola mensagem aqui e investigamos.

## Lição L33 (a formalizar em knowledge 0018)

`ImportarPacoteV3()` completo gera fantasma de cache de compile no VBE quando
rodado em workbook ja populado (re-import dos 47 itens cria stale references).
Uso normal e operacional do projeto SEMPRE foi via `_Delta` com manifesto
pequeno (vide MICRO01..MICRO62 — 70+ manifestos no repo).

**Debito tecnico**: investigar por que `ImportarPacoteV3()` completo nao
limpa cache adequadamente, ou marca-lo como uso restrito (fresh workbook ou
emergencia). `_Delta` permanece como caminho default.

Documentado em `.hbn/knowledge/0018-uso-delta-vs-completo.md` (a criar em
onda futura).

## Rollback

Se algo der errado:

1. NAO SALVAR o workbook (preserva V5 do disco intacto).
2. Terminal: `git checkout HEAD -- src/vba/App_Release.bas local-ai/vba_import/001-modulo/AAX-App_Release.bas` restaura carimbo anterior.
3. Reabrir workbook V5 do disco — estado original funcional.
4. Documentar no proprio 37_4_TESTE_DELTA_NOOP.md o que falhou.
