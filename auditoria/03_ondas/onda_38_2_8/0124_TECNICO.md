---
titulo: Onda 38.2.8 - baseline V2 preserva CONFIG
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-31
---

# Onda 38.2.8 - baseline V2 preserva CONFIG

## Escopo confirmado

Readback: `.hbn/readbacks/0124-rb-onda-38-2-8-config-baseline-v2.json`
Hearback: `.hbn/hearbacks/0124-rb-onda-38-2-8-config-baseline-v2-confirmed.json`

Objetivo: corrigir FT-11/CONFIG, impedindo que o baseline V2 sobrescreva
municipio e gestor salvos pelo operador com valores de teste.

## Alteracoes entregues

- `Teste_V2_Engine.TV2_SetConfigCanonica` deixa de atribuir diretamente
  `COL_CFG_GESTOR = "Gestor Testes V2"` e
  `COL_CFG_MUNICIPIO = "Municipio de Testes V2"`.
- Novo helper privado `TV2_ConfigValorOperadorOuCanonico` retorna o valor ja
  salvo quando ele nao esta vazio; caso contrario, usa o valor canonico de
  teste como fallback.
- Os demais parametros tecnicos do baseline V2 continuam canonicos:
  logo, prazo Pre-OS, recusas, meses de suspensao, UF, secretaria, nota minima,
  strikes e dias de suspensao.
- `TV2_RunConfigBaselineSeguro` valida de forma nao destrutiva que o motor V2
  usa o helper e nao contem mais as atribuicoes diretas antigas.

## Pacote V3

Manifesto:
`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_8_CONFIG_BASELINE_V2.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_8_CONFIG_BASELINE_V2", "fd45a5d+ONDA38.2.8-CONFIG-BASELINE-V2"
```

Pos-import esperado:

1. Importador V3: `M=3 | F=0 | err=0`.
2. VBE > Depurar > Compilar VBAProject: limpo.
3. Janela Imediata: `TV2_RunConfigBaselineSeguro`.
4. Resultado esperado: `OK=3 | FALHA=0 | MANUAL=0`.

## Racional

O caminho operacional da configuracao estava correto: o formulario grava
`COL_CFG_MUNICIPIO`, e a impressao le esse valor antes de montar cabecalhos.
O problema era o baseline V2, que substituia municipio/gestor por textos de
teste sempre que uma suite preparava base canonica.

Com esta onda, rodar testes V2 nao deve mais fazer uma configuracao real voltar
para `Municipio de Testes V2`, desde que o municipio real ja esteja salvo na
aba `CONFIG`.

## Fora do escopo preservado

- `Auto_Open.bas` nao foi tocado.
- `Mod_Types.bas` nao foi tocado.
- `Importador_V3.bas` nao foi tocado.
- `Configuracao_Inicial.frm` e `.frx` nao foram tocados.
- `Menu_Principal`, `Preencher`, `Svc_*` e `Repo_*` nao foram alterados.
- Layout/bordas dos PDFs continuam para onda propria.
- Nao foi declarado freeze V206.
