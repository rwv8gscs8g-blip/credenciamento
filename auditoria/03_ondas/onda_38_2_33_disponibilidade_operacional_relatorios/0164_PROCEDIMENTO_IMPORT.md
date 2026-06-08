---
titulo: Procedimento de Importacao — Onda 38.2.33
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-06-08
---

# Procedimento de importacao — 0164

## Pacote

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_33_DISPONIBILIDADE_OPERACIONAL_RELATORIOS.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_33_DISPONIBILIDADE_OPERACIONAL_RELATORIOS", "293e44c+ONDA38.2.33-DISPONIBILIDADE-RELATORIOS"
```

## Ordem de importacao esperada

Modulos:

1. `001-modulo/AAX-App_Release.bas`
2. `001-modulo/AAU-Preencher.bas`
3. `001-modulo/ABV-Rel_Rodizio_Status.bas`
4. `001-modulo/ABF-Teste_V2_Engine.bas`
5. `001-modulo/ABG-Teste_V2_Roteiros.bas`

Formularios:

1. `002-formularios/AAM-Menu_Principal.frm`
2. `002-formularios/AAK-Rel_Emp_Serv.frm`
3. `002-formularios/AAL-Rel_OSEmpresa.frm`

## Resultado esperado do Importador V3

`M=5 | F=3 | err=0 | skip=0`

## Gate manual obrigatorio

1. VBE > Depurar > Compilar VBAProject.
2. Janela Imediata:

```vb
TV2_RunRelatoriosSuspensoesStrikesReset
```

Resultado esperado:

`OK=10 | FALHA=0 | MANUAL=0`

Regressao recomendada:

```vb
TV2_RunTelaRelatorios
```

Resultado esperado:

`OK=10 | FALHA=0 | MANUAL=0`

## Observacoes

- Nao rodar VCR neste microdelta, salvo decisao humana para checkpoint forte.
- Nao importar nem restaurar 0155.
- Nao tocar `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas` ou
  `ThisWorkbook`.
- A onda nao altera designer nem `.frx`.
- Fluxos destrutivos continuam fora do teste automatico desta onda.
