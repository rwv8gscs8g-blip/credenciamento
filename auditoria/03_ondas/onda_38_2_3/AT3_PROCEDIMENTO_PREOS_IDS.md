---
titulo: AT-3 Procedimento Pre-OS IDs Textuais
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-05-27
---

# AT-3 Procedimento Pre-OS IDs Textuais

## Objetivo

Corrigir F-NEW6 em `PRE_OS`, onde `EMP_PRESEL=001` era gravado/lido como `EMP_PREOS=1` e reprovava `DIAG_PREOS_INTEGRITY`.

## Escopo importavel

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_3_AT3_PREOS_IDS.txt`

Modulos:

- `local-ai/vba_import/001-modulo/AAL-Repo_PreOS.bas`
- `local-ai/vba_import/001-modulo/AAQ-Svc_PreOS.bas`

## Comando no VBE

Executar na Janela Imediata:

```vb
ImportarPacoteV3_Delta "ONDA38_2_3_AT3_PREOS_IDS", "<sha>+ONDA38.2.3-AT3-PREOS-IDS"
```

Substituir `<sha>` pelo hash curto do commit AT-3 informado pelo Codex.

## Pos-import

1. Verificar que o Importador V3 retornou `M=2 | F=0 | err=0`.
2. Executar `Debug > Compile VBAProject`.
3. Rodar `TV2_RunRodizioStrikesEndToEnd`.
4. Se o teste passar, rodar o RVS Trio conforme gate operacional.

## Resultado esperado

- `DIAG_PREOS_INTEGRITY` nao deve mais falhar por `EMP_PRESEL=001` versus `EMP_PREOS=1`.
- Novas linhas de `PRE_OS` nascem com IDs textuais.
- IDs acima de 999 permanecem completos: `1000` continua `1000`; nao ha truncamento para `000`.

## Decisao operacional

Mauricio confirmou que os dados atuais do workbook sao base de testes e podem ser descartados. Portanto AT-3 nao executa backfill de linhas `PRE_OS` antigas.
