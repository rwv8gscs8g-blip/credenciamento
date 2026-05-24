---
titulo: Raiz Canonica Obrigatoria do Projeto
data: 2026-05-24
autoria: Codex
aplica-a: Todas as IAs e todos os ciclos V12.0.0206+
revisar-em: 2026-06-24
---

# Raiz Canonica Obrigatoria do Projeto

## Regra

A unica raiz local autorizada para entregaveis do Sistema de Credenciamento e:

```text
/Users/macbookpro/Projetos/Credenciamento
```

Toda IA deve escrever nessa pasta, inclusive para:

- `src/vba/`
- `local-ai/vba_import/`
- `.hbn/`
- `auditoria/`
- `docs/`
- `obsidian-vault/`
- `backups/`
- evidencias, manifests e pacotes de importacao.

`/private/tmp`, worktrees temporarios, pastas da IDE, downloads e areas de
rascunho podem ser usados apenas para material descartavel. Se algum artefato
precisar ser mantido, ele deve ser migrado para a raiz canonica antes de ser
considerado entregue.

## Falha que originou esta regra

Em 2026-05-24, a branch `codex/v12-0-0206-planejamento` estava presa no
worktree `/private/tmp/cred-v205`, enquanto o workbook apontava para
`\\Mac\Home\Projetos\Credenciamento`. Isso criou duas verdades concorrentes:

- Git/HBN/V206 sendo editados em `/private/tmp/cred-v205`.
- Excel/Importador V3 e backups operacionais lendo
  `/Users/macbookpro/Projetos/Credenciamento`.

O resultado foi correto do ponto de vista de branch, mas errado do ponto de
vista operacional: o importador via `ThisWorkbook.Path` nunca enxergaria os
deltas escritos no tmp.

## Preflight obrigatorio

Antes de ler, editar, importar, documentar ou passar bastao, execute:

```bash
pwd
git rev-parse --show-toplevel
git status --short --branch
git worktree list
```

Critério de aceite:

- `pwd` deve ser `/Users/macbookpro/Projetos/Credenciamento`.
- `git rev-parse --show-toplevel` deve ser
  `/Users/macbookpro/Projetos/Credenciamento`.
- A branch de trabalho V206 deve aparecer na pasta canonica.
- Nenhum readback novo pode declarar `worktree` fora da pasta canonica.

Para tarefas de importacao no workbook, valide tambem na Janela Imediata:

```vb
?ThisWorkbook.Path
ImportarPacoteV3_Status
```

Critério de aceite:

- `ThisWorkbook.Path` deve apontar para `\\Mac\Home\Projetos\Credenciamento`.
- O manifesto esperado pelo importador deve existir em
  `\\Mac\Home\Projetos\Credenciamento\local-ai\vba_import\`.

## Como agir se a regra falhar

Se a IA detectar `/private/tmp` ou qualquer outra raiz como worktree ativo:

1. Pare a implementacao funcional.
2. Registre P0 de governanca em `.hbn/readbacks/`.
3. Preserve evidencias em `backups/raiz_canonica/` dentro da pasta do projeto.
4. Migre os artefatos para `/Users/macbookpro/Projetos/Credenciamento`.
5. Atualize HBN e auditoria explicando a correcao.
6. So retome o roadmap apos `git worktree list` mostrar a branch ativa na raiz
   canonica.

## Como verificar

```bash
pwd
git rev-parse --show-toplevel
git status --short --branch
git worktree list
test -f AGENTS.md
test -f .hbn/relay/INDEX.md
test -f local-ai/vba_import/000-MANIFESTO-V3-PHASE1.txt
```

No VBE:

```vb
?ThisWorkbook.Path
ImportarPacoteV3_Status
```
