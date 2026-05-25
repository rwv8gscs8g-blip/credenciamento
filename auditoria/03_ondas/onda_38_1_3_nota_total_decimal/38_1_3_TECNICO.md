---
titulo: Onda 38.1.3 — Nota Total com duas casas decimais
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-25
---

# Onda 38.1.3 — Nota Total com duas casas decimais

## Contexto

Mauricio validou a Onda 38.1.2: importacao delta, compile VBE, RVS completo e
geracao funcional do PDF de OS por Empresa. No PDF gerado, a coluna `NOTA
TOTAL` exibia alguns valores inteiros e um valor decimal `8,7`; a preocupacao
operacional era evitar mistura visual entre numero e texto.

Decisao humana desta onda:

- manter o cabecalho `NOTA TOTAL`;
- nao alterar calculos;
- aplicar apenas apresentacao com duas casas decimais.

## Implementacao

Arquivo alterado: `src/vba/Rel_OSEmpresa.frm`.

Mudancas:

- `Var8` passou de `String` para `Variant`, evitando transformar a nota em texto
  antes de gravar no relatorio;
- a celula da coluna H recebe `Util_Conversao.ToDouble(Var8)` quando ha valor;
- a faixa `H2:H<n>` recebe `NumberFormat = "0.00"` e alinhamento a direita.

`NumberFormat = "0.00"` foi escolhido por ser a mascara invariavel do modelo de
objetos do Excel. Em ambiente pt-BR, a exibicao final usa virgula decimal; em
ambiente en-US, usa ponto decimal, sem depender de `NumberFormatLocal`.

## Escopo

Tocados:

- `src/vba/Rel_OSEmpresa.frm`
- `src/vba/App_Release.bas`
- espelhos oficiais em `local-ai/vba_import/`
- manifesto delta da Onda 38.1.3
- artefatos HBN/auditoria/changelog desta onda

Nao tocados:

- `Svc_Avaliacao.bas`
- `Svc_OS.bas`
- `Rel_Emp_Serv.frm`
- qualquer `.frx`
- `Menu_Principal.frm`
- `Preencher.bas`

## Gate humano

Comando unico de import:

```vb
ImportarPacoteV3_Delta "ONDA38-1-3-NOTA-TOTAL-DECIMAL", "35775b3+ONDA38.1.3-nota-total-decimal"
```

Resultado esperado:

- `M=1 | F=1 | err=0 | skip=0`
- compile VBE limpo
- `CT_ValidarRelease_TrioMinimo` aprovado sem mudanca de contadores
- PDF de OS por Empresa com `NOTA TOTAL` exibida com duas casas decimais

## Proxima onda

Com a correcao visual minima entregue, o roadmap deve voltar para a parte de
PDF automatico: Onda 39 (`Util_PDF.bas` central), preservando a regra de nao
incluir testes PDF nas 6 baterias do RVS.
