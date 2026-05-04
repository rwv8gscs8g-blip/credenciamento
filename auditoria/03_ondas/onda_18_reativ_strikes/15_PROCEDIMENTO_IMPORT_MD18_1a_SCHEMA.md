---
titulo: Procedimento de importacao — Onda 18 MD-18.1a schema DT_ULT_REATIV
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-04
---

# 15. Procedimento de Import — MD-18.1a Schema DT_ULT_REATIV

## Objetivo

Importar o MICRO25 para adicionar a coluna `DT_ULT_REATIV` ao schema de
`EMPRESAS` e `EMPRESAS_INATIVAS`, preparando a Onda 18 para a janela de
strikes da MD-18.1b. Este pacote nao altera ainda a regra de punicao.

Nota pos-falha 2026-05-04 02:00: a primeira tentativa abortou porque
`Menu_Principal.code-only.txt` entrou como `M|` e porque `Mod_Types` foi
pulado pelo tabu C4 do V3 em modo Estabilizado. O procedimento abaixo usa
o V3 `V3.3-Onda18-C4`, entrada `ImportarPacoteV3_DeltaC4`, e remove forms
deste delta.

Nota pos-compile 2026-05-04 02:15: o MICRO25 corrigido importou com
`M=7/F=0/err=0/skip=0`, mas o compile manual falhou em
`Preencher.Limpa_Base` por chamada qualificada a
`Mod_Limpeza_Base.LimpaBaseTotalReset`. O pacote operacional passa a ser
`MICRO25-fix2`, rollup completo com `Preencher.bas`.

## Arquivos

| # | Arquivo no repositorio | Acao no Excel/sistema | Tipo de operacao |
|---|---|---|---|
| 1 | `local-ai/vba_import/001-modulo/AAA-Mod_Types.bas` | substituir codigo do modulo `Mod_Types` | substituir |
| 2 | `local-ai/vba_import/001-modulo/AAB-Const_Colunas.bas` | substituir codigo do modulo `Const_Colunas` | substituir |
| 3 | `local-ai/vba_import/001-modulo/ABA-Teste_Bateria_Oficial.bas` | substituir codigo do modulo `Teste_Bateria_Oficial` | substituir |
| 4 | `local-ai/vba_import/001-modulo/AAO-Repo_Empresa.bas` | substituir codigo do modulo `Repo_Empresa` | substituir |
| 5 | `local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas` | substituir codigo do modulo `Teste_V2_Engine` | substituir |
| 6 | `local-ai/vba_import/001-modulo/ABJ-Mod_Limpeza_Base.bas` | substituir codigo do modulo `Mod_Limpeza_Base` | substituir |
| 7 | `local-ai/vba_import/001-modulo/AAU-Preencher.bas` | substituir codigo do modulo `Preencher` | substituir |
| 8 | `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | substituir codigo do modulo `App_Release` | substituir |

Arquivo preparatorio fora do manifesto: `local-ai/vba_import/001-modulo/ABK-Importador_V3.bas`.
Ele precisa ser reimportado manualmente uma vez para expor a entrada C4.

## Passos

1. Abrir o workbook ancora `V12-202-Z011-onda17-fechada`.
2. No VBE, executar `Redefinir` antes de qualquer import.
3. Reimportar manualmente `Importador_V3` a partir de
   `local-ai/vba_import/001-modulo/ABK-Importador_V3.bas`.
4. Na Janela Imediata, conferir:

```vb
ImportarPacoteV3_Status
```

Resultado esperado: cabecalho `V3.3-Onda18-C4`.

5. Rodar o Importador V3 com C4 pre-aprovado:

```vb
ImportarPacoteV3_DeltaC4 "MICRO25-fix2", "f7aa84f+ONDA18.MD18.1a-schema-dt-ult-reativ-fix2-preencher"
```

6. Compilar manualmente em `Depurar > Compilar VBAProject`.
7. Conferir `GetBuildImportado`: deve retornar
   `f7aa84f+ONDA18.MD18.1a-schema-dt-ult-reativ-fix2-preencher`.
8. Rodar `CT_ValidarRelease_QuintetoMinimo`.
9. Se o Quinteto aprovar, salvar workbook como checkpoint pos-MD-18.1a.

## Resultado Esperado

| Gate | Esperado |
|---|---|
| Compile manual | 0 erros |
| Build importado | `f7aa84f+ONDA18.MD18.1a-schema-dt-ult-reativ-fix2-preencher` |
| Quinteto | APROVADO |
| DT-17-REATIV-STRIKES | continua ABERTO ate MD-18.1b |
| CS_INT_04 | pode continuar ABERTO; e debito independente de schema |

## Rollback

Rollback unico: voltar ao workbook `V12-202-Z011-onda17-fechada`.
O pacote MICRO25 contem todos os arquivos tocados pela MD-18.1a.

## Evidencia a Reportar

Retornar: compile OK/falha, build retornado por `GetBuildImportado`,
resultado do Quinteto, e se `RPT_BUGS_CONHECIDOS` manteve apenas
`DT-17-REATIV-STRIKES` + `INT-CAD-OS-REF-ORFA`.
