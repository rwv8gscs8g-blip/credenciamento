---
titulo: Execução do arquiteto HBN via Cowork — sandbox vs raiz canônica
data: 2026-06-05
autoria: claude-opus (modo arquiteto, onda 0114) em consulta a Mauricio
aplica-a: toda IA executando o PROMPT_ARQUITETO_USEHBN_AUTONOMO via Cowork (manual ou scheduled task), e todo guard que compara paths literais
revisar-em: 2026-09-05
---

# Execução do arquiteto via Cowork — sandbox vs raiz canônica

## O fato

O Cowork executa bash num sandbox Linux que monta o repositório em
`/sessions/<sessao>/mnt/Projetos/Credenciamento`. O guard
`assert-canonical-root` compara o `git rev-parse --show-toplevel` com o path
literal `/Users/macbookpro/Projetos/Credenciamento` — portanto **falha
estruturalmente** em qualquer execução via Cowork, mesmo com o repositório
íntegro e no lugar certo no Mac do operador.

**Isso NÃO é violação real do protocolo.** É artefato de ambiente. Comprovado
na validação manual de 2026-06-05: o mesmo runner retornou exit 0 no Terminal
do operador e exit 1 no sandbox, sem qualquer mudança no repo.

## O padrão operacional (vigente a partir da onda 0114)

1. **No sandbox (IA/Cowork)**: leitura, diagnóstico, pré-flight informativo,
   escrita de arquivos de protocolo (readbacks, knowledge, docs). O resultado
   do guards-runner no sandbox é **informativo**, nunca conclusivo.
2. **No Terminal do operador (Mauricio)**: validação conclusiva dos guards e
   **todo commit**. A IA entrega o comando em bloco atômico (L27) com
   expectativa + fallback (L28).
3. **Nunca** usar `HBN_GUARDS_BYPASS=1` para contornar a falha de
   canonical-root no sandbox — a falha é o comportamento correto do guard
   fora da raiz canônica.
4. Pré-condição do pré-flight (§2 do prompt mestre) "guards exit 0" é
   satisfeita por **human_report** do operador quando o ciclo roda via Cowork.
5. **Git no sandbox: somente leitura que não toque o index.** Comprovado em
   2026-06-05: `git status` rodado no sandbox criou `.git/index.lock` que o
   próprio sandbox **não consegue remover** (Operation not permitted),
   bloqueando `git add`/`commit` do operador no Terminal até remoção manual
   (`rm .git/index.lock`). No sandbox, preferir `git log`, `git rev-parse`,
   `git diff` sem refresh — e nunca `git add`, `commit`, `stash` ou `status`
   no repo canônico montado.

## Fricções colaterais registradas na mesma validação

- **Colisão de numeração** na knowledge base: existem dois arquivos `0014-*`
  (`0014-protocolo-fim-de-sessao.md` e `0014-protocolo-reprovacao-onda.md`).
  Sanear exige onda própria de higiene — não renumerar casualmente (links
  quebram).
- **Enum `agent_id` do `readback.schema.json` 1.0.0** não contempla
  `claude-opus-4-8`; sessões Opus 4.8 assinam como `claude-opus-4-7` com campo
  adicional `agent_note`. Alimenta o item A5 do backlog (bump 1.1.0).
- **Backlog §4 do prompt mestre estava stale** (A2 marcada "próximo" com
  knowledge 0014 já entregue) — reforça a regra do §3 passo 7: atualizar o
  prompt mestre a cada ciclo.

## Como verificar

No Terminal do operador (deve passar):

```
cd /Users/macbookpro/Projetos/Credenciamento && bash scripts/hbn-guards/hbn-guards-runner.sh
```

No sandbox Cowork (deve falhar em assert-canonical-root — comportamento esperado):

```
cd /sessions/<sessao>/mnt/Projetos/Credenciamento && bash scripts/hbn-guards/hbn-guards-runner.sh
```

Colisão 0014 (deve listar 2 arquivos enquanto não houver onda de higiene):

```
ls /Users/macbookpro/Projetos/Credenciamento/.hbn/knowledge/0014-*
```
