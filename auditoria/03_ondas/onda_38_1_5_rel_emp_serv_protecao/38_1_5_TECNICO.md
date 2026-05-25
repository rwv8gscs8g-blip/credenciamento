---
titulo: Onda 38.1.5 — Replay Rel_Emp_Serv proteção
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-25
---

# Onda 38.1.5 — Replay Rel_Emp_Serv proteção

## Contexto

Mauricio restaurou um workbook de base anterior à Onda 38.1 para aplicar a
restauração 38.1.4 de `Rel_OSEmpresa.frm`. O delta 38.1.4 importou e compilou,
mas seu manifesto continha somente `AAL-Rel_OSEmpresa.frm` e
`AAX-App_Release.bas`.

Como a base restaurada era anterior à 38.1, `Rel_Emp_Serv.frm` permaneceu sem o
ajuste funcional da Onda 38.1 que prepara e restaura a proteção da aba
`RELATORIO`. O sintoma voltou no gate humano: erro de planilha protegida ao
gerar o relatório de Empresas Credenciadas por Serviço.

## Diagnóstico

O problema não está no `Rel_OSEmpresa.frm` restaurado. O compile VBE passou
após a Onda 38.1.4.

O problema é de replay incompleto de delta: ao usar um workbook anterior à
38.1, também é preciso reimportar o form corrigido `Rel_Emp_Serv.frm`. O
repositório já contém esse form no estado correto, com:

- `Util_PrepararAbaParaEscrita` antes da escrita em `RELATORIO`;
- `Util_RestaurarProtecaoAba` nos caminhos de saída e erro;
- limpeza de resíduos e `PrintArea`;
- impressão direta com `Não = cancelar`, sem `PrintPreview`.

## Escopo aplicado

Arquivos funcionais importáveis:

- `local-ai/vba_import/002-formularios/AAK-Rel_Emp_Serv.frm`
- `local-ai/vba_import/001-modulo/AAX-App_Release.bas`

Arquivos de governança:

- `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-5-REL-EMP-SERV-PROTECAO.txt`
- `.hbn/readbacks/0102-onda38-1-5-rel-emp-serv-protecao.json`
- `.hbn/results/0102-exec-onda38-1-5-rel-emp-serv-protecao.json`
- `.hbn/relay/INDEX.md`
- `CHANGELOG.md`

Não foram tocados `Rel_OSEmpresa.frm`, arquivos `.frx`, serviços blindados,
`Menu_Principal.frm` ou `Preencher.bas`.

## Contrato de importação

```vb
ImportarPacoteV3_Delta "ONDA38-1-5-REL-EMP-SERV-PROTECAO", "696a8c2+ONDA38.1.5-rel-emp-serv-protecao"
```

Resultado esperado:

```text
M=1 | F=1 | err=0 | skip=0
```

## Gates humanos

1. Importar o delta acima.
2. Compilar no VBE com `Depurar > Compilar VBAProject`.
3. Abrir `Relatórios > Relatório de Empresas Credenciadas por Serviço`.
4. Selecionar um serviço com empresas cadastradas.
5. Clicar para gerar/imprimir e confirmar que não aparece erro de planilha
   protegida.
6. Rodar `CT_ValidarRelease_TrioMinimo` e confirmar
   `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0`.

## Rollback

Se o import ou compile falhar, não salvar o workbook. Restaurar pelo backup V3
indicado pelo Importador e colar a mensagem exata no chat.
