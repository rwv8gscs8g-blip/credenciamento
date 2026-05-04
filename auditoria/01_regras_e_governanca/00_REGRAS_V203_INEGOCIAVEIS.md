---
titulo: Regras V203 Inegociaveis (versao auditavel publica)
data: 2026-04-28
autoria: consolidacao da auditoria/40 secao 6, ratificada por Mauricio em 2026-04-28
aplica-a: linha V12.0.0203
status: vigente
fonte-canonica: este arquivo (publico) + .hbn/knowledge/0001-regras-v203-inegociaveis.md (operacional)
---

# Regras V203 Inegociaveis

> Constituicao operacional da V12.0.0203. Mudancas exigem release oficial
> com migration plan. Espelho operacional para IAs em
> [`.hbn/knowledge/0001-regras-v203-inegociaveis.md`](../../.hbn/knowledge/0001-regras-v203-inegociaveis.md).

## As 10 regras

1. **Bastao de implementacao** — definido por release. Quem nao tem bastao
   audita, propoe, mas nao edita codigo.
2. **Regra de Ouro do pacote** — tudo importavel mora em `vba_import/`,
   nas pastas com prefixo alfabetico, conforme manifesto. Sem excecao.
3. **Heuristica zero na interface** — controles acessados por nome
   canonico hardcoded. Nada de `InStr(Caption)`, `Top`, `Left`,
   `For Each ctl`.
4. **Idempotencia obrigatoria** — em operacoes administrativas
   (Limpa_Base, Reset_CNAE, snapshot, dedup).
5. **AUDIT_LOG cobre toda acao com efeito de estado** — ausencia de
   evento e bug.
6. **Posicao de fila e imutavel sem motivo operacional declarado** —
   recusa, conclusao com avanco. Suspensao nao move posicao.
7. **Empresa nao e penalizada duas vezes** — apos cumprir suspensao,
   volta a posicao original.
8. **Sem novos modulos arquiteturais ate `0203` fechada** — mudanca
   funcional vai num modulo existente, ou e adiada.
9. **`Mod_Types.bas` pode ser tocado APENAS na Onda 9** — com plano
   documentado e aprovado.
10. **Nenhum arquivo importavel fora de `vba_import/`** — sem excecao.
11. **Codigo de produto na resposta da IA e violacao.** Toda entrega de
    codigo VBA, formula Excel privilegiada, ou conteudo de form sai
    como **arquivo no repositorio** (`local-ai/vba_import/...`) +
    **procedimento atualizado** em `auditoria/03_ondas/onda_NN_*/<NN+1>_PROCEDIMENTO_IMPORT.md`.
    A IA pode incluir na resposta: comandos de shell para o operador
    rodar, tabelas operacionais [arquivo | acao no Excel], saida de
    diagnostico, e referencias por path. **Adicionado no hotfix v2 da
    Onda 6 (2026-04-28)** apos violacao real (ver
    `.hbn/knowledge/0003-glasswing-style-preventive-security.md`
    secao G6).
12. **Toda entrega de arquivo apresentada em tabela canonica de 4
    colunas** (`#`, `Arquivo no repositorio`, `Acao no Excel/sistema`,
    `Tipo de operacao`). Sem prosa solta, sem ausencia de prefixo
    alfabetico. Pre-condicoes obrigatorias: arquivos existem no
    working tree, hash bate entre `src/vba/` e `local-ai/vba_import/`,
    `.code-only.txt` puro com primeira linha `Private/Public Sub` ou
    `Public Function`. Pos-condicoes: a resposta termina com path do
    procedimento + comando de commit + linha de retorno esperado.
    Especificacao completa em `.hbn/knowledge/0004-padrao-resposta-tabela-de-entrega.md`.
    **Adicionado no hotfix v3 da Onda 6 (2026-04-28)** apos aprovacao
    explicita do Mauricio.
13. **Encoding e EOF de `.bas`/`.frm` sao parte da Regra de Ouro.**
    Todo `.bas` e `.frm` versionado deve ter (a) line endings CRLF
    (Windows), (b) ASCII puro em comentarios — proibido em-dash
    (`—` U+2014), ellipsis (`…`), smart quotes — substituir por
    equivalentes ASCII, (c) **EOF terminando com 3 CRLFs**
    (`\r\n\r\n\r\n` apos `End Sub`/`End Function`) — equivalente a 2
    linhas em branco extras obrigatorias. Verificar com
    `tail -c 6 <arquivo> | xxd` (deve retornar `0d0a0d0a0d0a`).
    Violacao causa o bug "Invalido fora de um procedimento" ou
    "Metodo ou membro de dados nao encontrado" quando reimportado no
    VBE. Especificacao completa em
    `.hbn/knowledge/0006-padronizacao-encoding-line-endings-frm.md`.
    **Adicionado no hotfix v5 da Onda 6 (2026-04-28)** apos
    Mod_Limpeza_Base.bas + Preencher.bas terem causado regressao real
    no workbook em homologacao do Mauricio.

## Auditoria de cumprimento

Detalhes operacionais e procedimentos de verificacao na versao espelho
em `.hbn/knowledge/0001-regras-v203-inegociaveis.md`. Resumo: toda onda
fechada deve responder textualmente as 10 perguntas correspondentes.

## Historico

- **2026-04-28** — versao 1.0, ratificada na Onda 6 (consolidacao
  documental). Origem: `auditoria/40_TRANSICAO_RACIONALIZACAO_E_PROMPT_RETOMADA.md`,
  secao 6.
