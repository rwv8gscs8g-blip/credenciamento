---
titulo: Procedimento de Importacao - Onda 38.2.43
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-06-10
---

# 0176 - Procedimento de Importacao

## Pacote

Comando no Imediato do VBE:

```vb
ImportarPacoteV3_Delta "ONDA38_2_43_AVISO_DUAS_LINHAS_RELATORIOS_ZOOM", "8078e73+ONDA38.2.43-AVISO-2LINHAS-REL-ZOOM"
```

Resultado esperado:

```text
modo=Estabilizado | dryRun=False | M=6 | F=3 | err=0 | skip=0
```

## Ordem do Delta

1. `001-modulo/AAX-App_Release.bas`
2. `001-modulo/AAD-Util_Config.bas`
3. `001-modulo/AAU-Preencher.bas`
4. `001-modulo/ABV-Rel_Rodizio_Status.bas`
5. `001-modulo/ABF-Teste_V2_Engine.bas`
6. `001-modulo/ABG-Teste_V2_Roteiros.bas`
7. `002-formularios/AAM-Menu_Principal.frm`
8. `002-formularios/AAK-Rel_Emp_Serv.frm`
9. `002-formularios/AAL-Rel_OSEmpresa.frm`

## Gate Manual

1. VBE > Depurar > Compilar VBAProject precisa passar limpo.
2. No Imediato:

```vb
TV2_RunRelatoriosSuspensoesStrikesReset
```

Esperado:

```text
OK=16 | FALHA=0 | MANUAL=0
```

3. Gerar PDFs equivalentes a 031-038 e revisar:
   - Pre-OS/OS: `C16` limpo, `B24` limpo e aviso legivel em `B29:K30`.
   - Relatorios: menos vazio lateral direito, texto mais legivel e colunas sem
     conteudo oculto.

## Nao Executar

Nao rodar VCR nesta microcorrecao. Nao importar `.frx`. Nao tocar
`Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas` ou `ThisWorkbook`.
