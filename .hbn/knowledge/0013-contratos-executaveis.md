---
titulo: Contratos executáveis no protocolo HBN (Onda 36)
data: 2026-05-24
autoria: claude-opus-4-7
aplica-a: Todas as IAs e todos os ciclos V12.0.0206+
revisar-em: 2026-08-24 (na transição V206→V207)
---

# Contratos executáveis no protocolo HBN

## Princípio

> Se uma regra do protocolo não vira código que roda automaticamente, ela é
> sugestão, não controle. Os incidentes de 2026-05-02 (Onda 10) e 2026-05-24
> (worktree em `/private/tmp`) provaram que doutrina em markdown não impede
> IAs distraídas de operar fora do escopo.

A Onda 36 introduziu a **camada executável** do protocolo HBN no Credenciamento:

1. **Schemas JSON** em `.hbn/schemas/` que formalizam o contrato do readback,
   hearback, audit-pre e audit-post.
2. **Guards de filesystem** em `scripts/hbn-guards/` que rodam no `pre-commit`
   hook e recusam commits que violem o contrato.
3. **`.hbn/canonical-root`** como arquivo de configuração lido pelos guards
   (single source of truth do path canônico).
4. **`.hbn/forbidden-paths.txt`** como lista versionada de paths legacy
   bloqueados.

## Regra permanente

A partir do readback `0089-onda36-cura-protocolo-opus`, toda IA que toque
arquivo no repositório Credenciamento deve:

1. **Emitir readback ANTES** de qualquer escrita, conforme
   `.hbn/schemas/readback.schema.json`. Em particular: `scope.files_allowed`
   declara os paths/globs que esta onda pode tocar. Para `safe_track`, esse
   campo é obrigatório e não pode ser vazio.

2. **Aguardar hearback humano** explícito (`human_status: confirmed` no
   readback OU `.hbn/hearbacks/<id>.json` com `status: confirmed`) antes de
   tocar qualquer arquivo declarado em `safe_track`. O guard
   `assert-scope-lock.sh` bloqueia commit se o hearback estiver `pending`.

3. **Limitar o diff git** estritamente aos arquivos em `scope.files_allowed`.
   O guard `assert-scope-lock.sh` compara `git diff --cached --name-only`
   contra o array de globs e recusa commit se houver vazamento de escopo.
   Esta é a guarda que faltou em 02/05 e em 24/05.

4. **Operar exclusivamente** na raiz canônica
   `/Users/macbookpro/Projetos/Credenciamento`. O guard
   `assert-canonical-root.sh` verifica `git rev-parse --show-toplevel -P`
   contra `.hbn/canonical-root`. Worktrees em `/tmp`, `/private/tmp`,
   `Downloads/` ou `.Trash/` são rejeitados pelo `forbid-tmp-worktree.sh`.

5. **Não commitar segredos**. `forbid-env-files.sh` recusa qualquer arquivo
   `.env*` (exceto `.env.example/.template/.sample`), `*.dump`, `*.pem`,
   `*.key`, chaves SSH e similares.

6. **Não tocar paths legacy**. `forbid-legacy-paths.sh` lê
   `.hbn/forbidden-paths.txt` e recusa commits que adicionem conteúdo em
   `local-ai/obsidian-vault/`, `local-ai/auditoria/`, pastas `V12-*/`,
   `~$*.xlsm`, `.DS_Store`, etc.

## Bypass de emergência (uso controlado)

Há uma válvula, mas ela deixa rastro. Para usar:

```bash
HBN_GUARDS_BYPASS=1 git commit -m "[bypass-hbn-guards] motivo: …"
```

Requisitos:

1. Prefixo `[bypass-hbn-guards]` no commit message.
2. Nota em `.hbn/bypasses/AAAAMMDD-HHmmss-<motivo>.md` com:
   - Por que foi necessário.
   - Quem autorizou.
   - Qual guard foi bypassed.
   - Plano de remediação (quando a regra será reaplicada).

Bypass sem essas três coisas é violação de processo, tratado como achado P0
na revisão semanal.

## Como evoluir o contrato

Adicionar novo campo ao schema, novo guard, novo path proibido:

1. ADR em `auditoria/01_regras_e_governanca/` propondo a mudança.
2. Atualizar schema bumpando `$id` (`/1.0.0` → `/1.1.0`).
3. Atualizar `scripts/hbn-guards/` se necessário.
4. Hearback humano explícito.
5. Onda safe_track própria com readback declarando o scope da mudança.
6. Atualizar este knowledge 0013.

## Relação com a doutrina HBN existente

Este knowledge **não substitui** os princípios constitucionais P1–P13 do
usehbn, nem a Regra de Ouro 0002 (`vba_import` espelha `src/vba`), nem a
Regra 0012 (raiz canônica). Ele **adiciona** a camada de enforcement que
faltava — converte essas regras em código que valida automaticamente.

A doutrina diz o que é certo. Os guards garantem que o errado não passa.

## Referências

- `.hbn/schemas/README.md` — guia dos schemas
- `scripts/hbn-guards/README.md` — guia dos guards
- `auditoria/00_status/105_AUDITORIA_HANDOFF_V206_V207_USEHBN_CLAUDE_OPUS.md`
  — devolutiva completa que motivou esta regra
- `auditoria/02_planos/34_ROADMAP_PROTOCOLO_90_DIAS_OPUS.md` — roadmap de
  institucionalização
- `auditoria/02_planos/35_PLANO_ARQUIVAMENTO_LOCAL_AI_E_V12_PASTAS.md` —
  fagocitose do legacy
- `.hbn/knowledge/0012-raiz-canonica-projeto.md` — regra precursora
- `.hbn/knowledge/0002-regra-ouro-vba-import.md` — fonte de verdade VBA
