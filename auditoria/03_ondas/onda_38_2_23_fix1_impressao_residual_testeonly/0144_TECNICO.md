---
titulo: Onda 38.2.23-fix1 - impressao residual testeonly
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-03
---

# Onda 38.2.23-fix1 - impressao residual testeonly

## Diagnostico

Mauricio importou a 0143, compilou o VBAProject e repetiu
`TV2_RunImpressaoResidual` tres vezes. A ultima execucao gerou o CSV
`TesteV2_IMPRESSAO_RESIDUAL_Falhas_TV2_20260603_121844.csv` com uma falha:

```text
IR_03_AVALIACAO_DEMANDANTE_L9P15
L8=
L9_VISUAL=Demandante IR 0143 - Contato IR - (11) 99999-0143
ESPERADO=Demandante IR 0143 - Contato IR - (11) 99999-0143
MERGE_L9=Verdadeiro
```

O bloqueador funcional estava corrigido: o range visual real `L9:P15` continha
o demandante esperado. A falha era um falso negativo do teste, que tambem exigia
`L8=esperado`.

## Mudanca

- `TV2_IR_DemandanteAvaliacaoVisualOk` agora aprova `IR_03` quando o valor
  visual lido de `IMP_AVALIA!L9:P15` for igual ao esperado.
- `L8` continua no detalhe diagnostico do teste, mas nao reprova a suite.
- `Preencher.bas` nao foi alterado neste fix1.
- `App_Release.bas` foi carimbado como
  `e157221+ONDA38.2.23-FIX1-IMP-RES-TEST`.

## Manifesto V3

Arquivo:
`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_23_FIX1_IMPRESSAO_RESIDUAL_TESTEONLY.txt`.

Comando operacional:

```vb
ImportarPacoteV3_Delta "ONDA38_2_23_FIX1_IMPRESSAO_RESIDUAL_TESTEONLY", "e157221+ONDA38.2.23-FIX1-IMP-RES-TEST"
```

Itens:

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

- Este fix1 e test-only; nao muda a correcao funcional de impressao entregue
  em `Preencher.bas` na 0143.
- Se o rerun ainda falhar, o novo CSV deve guiar a proxima decisao; nao declarar
  validacao verde sem `FALHA=0`.
