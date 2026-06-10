---
titulo: Onda 38.2.42 — aviso em linha inferior e relatorios largos
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-09
---

# 0175 — Onda 38.2.42

## Contexto

A 0174 foi importada e compilada pelo operador, com
`TV2_20260609_231627` retornando `OK=14 | FALHA=0 | MANUAL=0`.
A revisao visual dos PDFs `022.pdf` a `030.pdf` mostrou dois problemas
remanescentes:

1. o aviso operacional em `B24` ainda ficava apertado e competia com a grade de
   servicos;
2. os relatorios usavam pouco a largura direita da pagina, deixando a tabela
   pequena.

## Alteracao

Em `Preencher.bas`, o aviso operacional dos impressos Pre-OS/OS passa a ser
gravado em `B30:K30`, com fonte 7, sem `WrapText` e sem `ShrinkToFit`. O ponto
`B24` fica limpo para remover residuo da 0174. `LimparOS` e `LimparPREOS`
limpam `B24` e `B30`.

Em `Util_Config.bas`, o helper comum `Rel_ConfigurarPagina` reduz as margens
laterais de `0.5 cm` para `0.2 cm`, preservando A4 paisagem e `FitToPagesWide =
1`. O ajuste aumenta a largura util dos relatorios sem tocar formularios `.frm`
ou `.frx`.

## Testes

`TV2_RunRelatoriosSuspensoesStrikesReset` passa de 14 para 16 cenarios:

- `RELSSR_15_IMPRESSOS_AVISO_RODAPE_LEGIVEL`
- `RELSSR_16_RELATORIOS_LARGURA_UTIL`

Os cenarios existentes `RELSSR_13` e `RELSSR_14` foram atualizados de `B24` para
`B30`, mantendo `B24` como local legado a limpar.

## Gate Humano Esperado

1. Importar pelo manifesto V3 da 0175.
2. Compilar no VBE.
3. Rodar `TV2_RunRelatoriosSuspensoesStrikesReset`.
4. Revisar PDFs equivalentes a 022-030.

Resultado esperado:

```text
Importador V3: M=5 | F=0 | err=0 | skip=0
TV2_RunRelatoriosSuspensoesStrikesReset: OK=16 | FALHA=0 | MANUAL=0
```

## Riscos

O ajuste de margem melhora a largura util comum, mas pode nao resolver sozinho
todos os relatorios muito densos. Se o operador ainda enxergar compressao
excessiva, a proxima onda deve redistribuir colunas especificas do relatorio
observado, com novo readback.

## Arquivos

- `src/vba/App_Release.bas`
- `src/vba/Util_Config.bas`
- `src/vba/Preencher.bas`
- `src/vba/Teste_V2_Engine.bas`
- `src/vba/Teste_V2_Roteiros.bas`
- `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_42_AVISO_RODAPE_RELATORIOS_LARGOS.txt`

Sem formularios, sem `.frx`, sem VCR e sem alteracao no motor de rodizio.
