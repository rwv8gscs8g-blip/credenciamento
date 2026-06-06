---
titulo: Onda 38.2.23 - impressao residual code-only template
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-03
---

# Onda 38.2.23 - impressao residual code-only template

## Escopo

Esta onda implementa a correcao code-only dos residuos de impressao isolados
pela auditoria cruzada 0142, sem editar workbook manualmente e sem tocar
UserForms, `.frx`, `Auto_Open.bas`, `Mod_Types.bas`, `Importador_V3.bas`,
`Teste_V2_Engine.bas` ou `Teste_V2_Roteiros.bas`.

## Mudancas tecnicas

- `Preencher.bas` passa a escrever o demandante da avaliacao tambem em
  `IMP_AVALIA!L9:P15`, preservando `L8` por compatibilidade.
- `Preencher.bas` passa a preencher o total visual de `EMITE_OS!N63:P63` a
  partir da formula de `M63` quando ela produzir valor util, com fallback para
  `Vl_estimado`.
- `Preencher.bas` reaplica por VBA as bordas criticas:
  `EMITE_PREOS!C9` e `C11` com borda superior preta continua; e
  `IMP_AVALIA!A25:A45` com borda esquerda preta continua.
- Novo modulo isolado `Teste_V2_Impressao_Residual.bas` com
  `TV2_RunImpressaoResidual`, lendo celulas e bordas reais do workbook:
  `IR_01` total visual, `IR_02` idempotencia do total, `IR_03` demandante em
  `L9:P15`, `IR_04` borda Pre-OS, `IR_05` borda vertical da avaliacao e
  `IR_06` ranges contratados.
- `App_Release.bas` carimba o build importavel como
  `e157221+ONDA38.2.23-IMP-RES-CODE`, mantendo `V12.0.0205` oficial e
  `V12.0.0206` em validacao iterativa.

## Manifesto V3

Arquivo:
`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_23_IMPRESSAO_RESIDUAL_CODEONLY_TEMPLATE.txt`.

Comando operacional:

```vb
ImportarPacoteV3_Delta "ONDA38_2_23_IMPRESSAO_RESIDUAL_CODEONLY_TEMPLATE", "e157221+ONDA38.2.23-IMP-RES-CODE"
```

Itens:

- `M|001-modulo/AAU-Preencher.bas`
- `M|001-modulo/ABT-Teste_V2_Impressao_Residual.bas`
- `M|001-modulo/AAX-App_Release.bas`

## Gate humano pendente

1. Importar o delta V3 pelo comando acima.
2. Rodar `VBE > Depurar > Compilar VBAProject`.
3. Executar na Janela Imediata:

```vb
TV2_RunImpressaoResidual
```

Esperado: `OK=6 | FALHA=0 | MANUAL=0` e nenhum CSV
`TesteV2_IMPRESSAO_RESIDUAL_Falhas_*.csv`.

## Observacoes

- A correcao de bordas foi feita por helper VBA estreito, nao por edicao direta
  do template workbook.
- A suite V2 nova cobre explicitamente celulas mescladas e bordas reais, que
  eram a cegueira principal apontada na auditoria 0142.
- A validacao completa tela a tela da V206 continua obrigatoria antes de
  qualquer liberacao; esta onda fecha apenas os residuos concretos de impressao
  ja isolados.
