---
titulo: Procedimento de Importacao — Onda 38.2.34
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-06-08
---

# Procedimento de importacao — 0165

## Pacote

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_34_PREOS_VENCIDAS_RELATORIO_IMPRESSAO.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_34_PREOS_VENCIDAS_RELATORIO_IMPRESSAO", "b33ec4e+ONDA38.2.34-PREOS-VENCIDAS-RELATORIO"
```

## Ordem de importacao esperada

Modulos:

1. `001-modulo/AAX-App_Release.bas`
2. `001-modulo/ABF-Teste_V2_Engine.bas`
3. `001-modulo/ABG-Teste_V2_Roteiros.bas`

Formularios:

Nenhum.

## Resultado esperado do Importador V3

`M=3 | F=0 | err=0 | skip=0`

## Gate manual obrigatorio

1. VBE > Depurar > Compilar VBAProject.
2. Janela Imediata:

```vb
TV2_RunTelaRelatorios
```

Resultado esperado:

`OK=11 | FALHA=0 | MANUAL=0`

## Observacoes

- Nao rodar VCR neste microdelta, salvo decisao humana para checkpoint forte.
- Nao importar nem restaurar 0155.
- Nao tocar `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas` ou
  `ThisWorkbook`.
- A onda nao altera designer nem `.frx`.
- O relatorio de Pre-OS vencidas continua informativo: impressao nao expira,
  nao recusa e nao avanca fila.
