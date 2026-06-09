---
titulo: Procedimento de Importacao — Onda 38.2.36 C16 aviso operacional
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-06-08
---

# Procedimento de importacao — 0169

## Pacote

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_36_C16_AVISO_OPERACIONAL_PDF.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_36_C16_AVISO_OPERACIONAL_PDF", "37486b7+ONDA38.2.36-C16-AVISO-OPERACIONAL"
```

## Ordem de importacao esperada

Modulos:

1. `001-modulo/AAX-App_Release.bas`
2. `001-modulo/AAU-Preencher.bas`
3. `001-modulo/ABF-Teste_V2_Engine.bas`
4. `001-modulo/ABG-Teste_V2_Roteiros.bas`

Formularios:

Nenhum.

## Resultado esperado do Importador V3

`M=4 | F=0 | err=0 | skip=0`

## Gate manual obrigatorio

1. VBE > Depurar > Compilar VBAProject.
2. Janela Imediata:

```vb
TV2_RunRelatoriosSuspensoesStrikesReset
```

Resultado esperado:

`OK=11 | FALHA=0 | MANUAL=0`

3. Gerar PDFs de Pre-OS, OS e Avaliacao.
4. Revisar visualmente o aviso `Status da empresa nesta data` em `C16`.

## Observacoes

- Nao rodar VCR neste microdelta.
- Nao tocar `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas` ou
  `ThisWorkbook`.
- A onda nao altera designer nem `.frx`.
- Se o aviso continuar com caracteres artificialmente espacados, abrir fix1
  antes de seguir para 0170.
