---
titulo: Onda 38.2.24 - impressao residual quant borda code-only
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-06
---

# Onda 38.2.24 - impressao residual quant borda code-only

## Escopo

Esta onda fecha o GATE 2 apontado no handoff 127, sem editar workbook/template
manual e sem tocar UserForms, `.frx`, `Auto_Open.bas`, `ThisWorkbook`,
`Mod_Types.bas`, `Importador_V3.bas`, `Teste_V2_Engine.bas` ou
`Teste_V2_Roteiros.bas`.

## Mudancas tecnicas

- `Preencher.bas` altera `AplicarFormatoQuantidade` para formato inteiro
  `"0"`, removendo o formato local `"0,##"` que podia imprimir quantidade
  como `1,`.
- `Preencher.bas` passa a aplicar borda preta continua com peso parametrizado.
  `EMITE_PREOS!C9/C11` preserva `xlThin`; `IMP_AVALIA!A25:A45` recebe
  `xlMedium` apenas na borda externa esquerda.
- `Teste_V2_Impressao_Residual.bas` amplia `TV2_RunImpressaoResidual` de 6
  para 7 asserts:
  - `IR_05_AVALIACAO_BORDA_VERTICAL` agora exige `LineStyle=xlContinuous`,
    `Color=vbBlack` e `Weight=xlMedium` na borda esquerda de `A25:A45`;
  - novo `IR_07_QUANTIDADE_INTEIRA` valida `EMITE_OS!L23/L55`,
    `EMITE_PREOS!L23` e `IMP_AVALIA!L23` com valor `1`, `NumberFormat="0"` e
    texto sem separador decimal residual.
- `App_Release.bas` carimba o build importavel como
  `e157221+ONDA38.2.24-IMP-RES-QTD-BORDA`, mantendo `V12.0.0205` oficial e
  `V12.0.0206` em validacao iterativa.

## Manifesto V3

Arquivo:
`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_24_IMPRESSAO_RESIDUAL_QUANT_BORDA_CODEONLY.txt`.

Comando operacional:

```vb
ImportarPacoteV3_Delta "ONDA38_2_24_IMPRESSAO_RESIDUAL_QUANT_BORDA_CODEONLY", "e157221+ONDA38.2.24-IMP-RES-QTD-BORDA"
```

Itens:

- `M|001-modulo/AAU-Preencher.bas`
- `M|001-modulo/ABT-Teste_V2_Impressao_Residual.bas`
- `M|001-modulo/AAX-App_Release.bas`

## Gate humano validado

Mauricio executou o gate humano em 2026-06-06:

- Importador V3 OK: `modo=Estabilizado | dryRun=Falso | M=3 | F=0 | err=0 | skip=0`.
- Backup FULL registrado pelo importador:
  `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260606_110957-V3-FULL`.
- `VBE > Depurar > Compilar VBAProject` passou limpo.
- `TV2_RunImpressaoResidual` concluiu em `TV2_20260606_111039` com
  `OK=7 | FALHA=0 | MANUAL=0`.
- CSV de falhas: nao exportado.

Veredito: 38.2.24 validada por import, compile e V2 dirigido.

## Observacoes

- O GATE 1/0144 ja foi validado por import, compile e
  `TV2_20260606_104057` com `OK=6 | FALHA=0 | MANUAL=0`.
- Esta onda nao altera contratos de negocio; cobre apenas os dois residuos
  visuais conhecidos do GATE 2.
- A validacao tela a tela da V206 e o proximo loop operacional, sem freeze
  automatico.
