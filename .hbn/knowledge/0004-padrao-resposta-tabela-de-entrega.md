---
titulo: Padrao de resposta — tabela de entrega de arquivos
data: 2026-04-28
autoria: Luis Mauricio Junqueira Zanin (aprovacao explicita) + Claude Opus 4.7 (Cowork) na hotfix v3 da Onda 6
aplica-a: toda IA que entrega arquivo no repositorio para uso operacional pelo Mauricio
revisar-em: fechamento estavel da V12.0.0203
status: vigente
fonte-canonica: este arquivo + auditoria/01_regras_e_governanca/00_REGRAS_V203_INEGOCIAVEIS.md regra 12
---

# Padrao de resposta — tabela de entrega de arquivos

## A regra

**Toda vez que uma IA entrega arquivo(s) que o Mauricio precise importar,
substituir, ou aplicar no Excel ou em qualquer outro sistema, a resposta
deve apresentar a entrega numa tabela de 4 colunas, nao em prosa.**

## A tabela canonica

```
| # | Arquivo no repositorio | Acao no Excel/sistema | Tipo de operacao |
|---|------------------------|-----------------------|------------------|
```

Cada coluna:

- **#** — numero sequencial da entrega na onda corrente (1, 2, 3, ...).
- **Arquivo no repositorio** — path **completo** a partir da raiz do
  repositorio, incluindo prefixo alfabetico quando aplicavel
  (`local-ai/vba_import/001-modulo/AAX-App_Release.bas`,
  nao `App_Release.bas`).
- **Acao no Excel/sistema** — descricao operacional curta:
  "substituir codigo do modulo X", "importar modulo NOVO",
  "substituir somente Sub Y", "substituir codigo do form Z".
- **Tipo de operacao** — categoria tecnica para o operador:
  `substituir` / `File > Import` / `substituir Sub` / `substituir codigo do form`.

## Exemplo correto (Onda 5)

| # | Arquivo no repositorio | Acao no Excel | Tipo de operacao no VBE |
|---|---|---|---|
| 1 | `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | substituir codigo do modulo `App_Release` | substituir |
| 2 | `local-ai/vba_import/001-modulo/ABJ-Mod_Limpeza_Base.bas` | importar modulo NOVO | File > Import |
| 3 | `local-ai/vba_import/001-modulo/AAU-Preencher.bas` | substituir SOMENTE a `Sub Limpa_Base()` | substituir Sub |
| 4 | `local-ai/vba_import/002-formularios/AAC-Configuracao_Inicial.code-only.txt` | substituir codigo atras do form `Configuracao_Inicial` | substituir codigo do form |

## O que e proibido na resposta (regra V203 reforcada)

- Listar arquivos em prosa solta. Errado: "Voce precisa atualizar
  App_Release e Mod_Limpeza_Base e Preencher e Configuracao_Inicial".
- Omitir o prefixo alfabetico do arquivo. Errado: "atualize
  `App_Release.bas`". Certo:
  `local-ai/vba_import/001-modulo/AAX-App_Release.bas`.
- Misturar codigo VBA na resposta (regra 11 + Glasswing G6).
- Pedir ao Mauricio para "decidir qual arquivo mexer" — a IA decide
  e apresenta tabela; Mauricio aprova ou rejeita.

## Pre-condicao da tabela

Antes de apresentar a tabela, a IA precisa ter:

- Os arquivos **ja escritos** em `local-ai/vba_import/` na pasta correta
  com prefixo correto.
- O `.frm` e seu `.frx` consistentes com o workbook em homologacao
  (sem reimport do `.frx`).
- O `.code-only.txt` de cada form modificado **puro** — primeira linha
  deve ser uma `Private Sub` ou `Public Sub` ou `Public Function`, sem
  cabecalho FRM, sem cabecalho de instrucoes em comentarios.
- Hash `md5sum` batendo entre `src/vba/Nome.bas` e
  `local-ai/vba_import/001-modulo/AAX-Nome.bas` (Regra de Ouro).

Se qualquer pre-condicao falha, a IA **nao apresenta tabela** — ela
reporta o problema e propoe correcao primeiro.

## Pos-condicao apos a tabela

A resposta da IA termina com **3 elementos operacionais**, em ordem:

1. **Path do procedimento detalhado** em
   `auditoria/03_ondas/onda_NN_*/<NN+1>_PROCEDIMENTO_IMPORT.md` que o
   operador deve abrir e seguir.
2. **Comando de commit** (shell, no terminal local do operador) com
   `git add` listando exatamente os arquivos da tabela + `git commit -m`
   com mensagem padronizada `onda(NN)/<acao>: <resumo>`.
3. **Linha de retorno esperado:** o que a IA precisa que o operador
   reporte no proximo turno (compilacao OK / erro X / trio minimo
   verde / etc.).

## Como verificar

Toda IA, antes de enviar a resposta com tabela, deve responder "sim" a:

1. A tabela tem exatamente 4 colunas (`#`, path, acao, tipo de operacao)?
2. Todos os paths sao a partir da raiz do repo, com prefixo alfabetico?
3. Cada arquivo da tabela existe fisicamente no working tree
   (verificavel com `ls`)?
4. Para cada `.bas` listado, hash `md5sum` bate entre `src/vba/` e
   `local-ai/vba_import/001-modulo/`?
5. Para cada `.code-only.txt` listado, primeira linha e `Private Sub`,
   `Public Sub`, ou `Public Function` (nao `VERSION 5.00` nem `Begin
   {GUID}` nem aspa simples)?
6. A resposta termina com path do procedimento + comando de commit +
   linha de retorno esperado?

Se qualquer resposta for "nao", a IA **nao envia** a resposta — corrige
o pre-requisito primeiro.

## Aplicabilidade

Esta regra vale para **toda entrega operacional** em qualquer onda do
projeto Credenciamento. Tambem vale como categoria A integrada ao HBN
(ver `usehbn/agents/agents.md` apos a proxima atualizacao).
