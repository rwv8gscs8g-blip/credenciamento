---
titulo: scripts/hbn-guards — guards executáveis de governança HBN
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
---

# scripts/hbn-guards/

Hooks executáveis que **convertem o protocolo HBN textual em verificação
mecânica**. Antes da Onda 36, a única defesa contra IA gravando em pasta
errada eram parágrafos em `AGENTS.md`. Os incidentes de 2026-05-02
(`auditoria/00_status/32`) e 2026-05-24 (`auditoria/00_status/98`)
demonstraram que parágrafos não bloqueiam IAs. Esta pasta existe para
resolver isso.

## Princípio

> Se uma regra não vira código que roda no pre-commit, ela é sugestão.

Cada guard é um shell script independente que:

1. Lê estado do repositório (git, filesystem, `.hbn/`).
2. Avalia uma condição binária (passa / falha).
3. Em falha, explica a causa e propõe a correção.
4. Em sucesso, fica calado (apenas uma linha de OK).

## Guards vigentes

| Guard | Falha quando… | Severidade | Documento de origem |
|---|---|---|---|
| `assert-canonical-root.sh` | `git rev-parse --show-toplevel` ≠ `.hbn/canonical-root` | hard-fail | auditoria/00_status/98 |
| `forbid-tmp-worktree.sh` | `git worktree list` contém path em `/tmp`, `/private/tmp`, `Downloads/`, `.Trash/` | hard-fail | auditoria/00_status/32, 98 |
| `forbid-env-files.sh` | Staged inclui `.env*` (exceto `.env.example`), `*.dump`, `*.pem`, chaves | hard-fail | doutrina geral de segredos |
| `forbid-legacy-paths.sh` | Staged inclui paths listados em `.hbn/forbidden-paths.txt` | hard-fail | plano de fagocitose `auditoria/02_planos/35` |
| `assert-scope-lock.sh` | Para `safe_track`: arquivos staged fora do `scope.files_allowed` do readback ativo, ou `human_status≠confirmed` | hard-fail | gap identificado pela análise Opus 2026-05-24 |
| `validate-readback.sh` | Um JSON em `.hbn/readbacks/` viola `.hbn/schemas/readback.schema.json` | hard-fail (apenas quando invocado explicitamente) | `.hbn/schemas/README.md` |

Compostos por `hbn-guards-runner.sh` na ordem acima (fail-fast).

## Como instalar nos hooks git

A partir da raiz canônica do projeto:

```bash
bash scripts/hbn-guards/install.sh
```

O instalador:

- Faz backup do `.git/hooks/pre-commit` atual (se existir e não for o nosso).
- Instala um novo `pre-commit` que executa, nesta ordem:
  1. `scripts/hbn-guards/hbn-guards-runner.sh` (governança HBN)
  2. O hook Glasswing G7+G8 (`local-ai/scripts/publicar_vba_import_v2.sh --check`)
     que já existia (sem perder o que estava funcionando).

## Meta-paths sempre permitidos

Independente do `scope.files_allowed` declarado no readback ativo, o
`assert-scope-lock.sh` **sempre permite** estes paths (são artefatos de
coordenação do próprio protocolo, não trabalho substantivo):

- `.hbn/hearbacks/<readback_id>-*.json` — hearback humano do readback ativo
- `.hbn/hearbacks/<readback_id>-*.md` — versão em markdown (se preferir)
- `.hbn/bypasses/**` — notas de bypass de guards (deixar rastro É a regra)
- `.hbn/messages/**` — mensagens inter-IA (mantém audit trail)
- `.hbn/relay/INDEX.md` — atualização do bastão e próxima ação

Isso resolve o paradoxo cíclico onde, para confirmar uma onda, o operador
precisaria primeiro autorizar a si próprio a confirmar a onda. O hearback
do `0089` cai automaticamente nessa regra (`READBACK_NUM=0089`).

## Bypass de emergência

Toda regra precisa de uma válvula. Mas a válvula precisa deixar rastro:

```bash
HBN_GUARDS_BYPASS=1 git commit -m "[bypass-hbn-guards] motivo: …"
```

Requisitos para usar o bypass:

1. Prefixo `[bypass-hbn-guards]` no commit message.
2. Nota em `.hbn/bypasses/AAAAMMDD-HHmmss-<motivo>.md` com:
   - Por que o bypass foi necessário (em uma frase clara).
   - Quem autorizou.
   - Qual guard foi bypassed.
   - Plano de remediação (quando a regra será reaplicada).
3. Tag no commit do tipo `bypass/AAAAMMDD-<motivo>` (opcional mas recomendado para
   auditoria).

O CI semanal deve listar bypasses sem nota correspondente em `.hbn/bypasses/`
e abrir issue automática.

## Testes (smoke)

Para testar os guards sem fazer commit real:

```bash
# Testa raiz canônica:
bash scripts/hbn-guards/assert-canonical-root.sh

# Testa scope lock (precisa de arquivo staged):
git add docs/algum_arquivo.md
bash scripts/hbn-guards/assert-scope-lock.sh

# Testa runner completo:
bash scripts/hbn-guards/hbn-guards-runner.sh
```

## Como evoluir

Adicionar novo guard:

1. Criar `scripts/hbn-guards/<novo-guard>.sh` seguindo o padrão dos existentes
   (source `lib/common.sh`, suporte a bypass, mensagem clara de erro).
2. Acrescentar nome do guard no array `GUARDS=(...)` em `hbn-guards-runner.sh`
   na posição correta (raiz primeiro, scope depois).
3. Documentar nesta tabela.
4. Atualizar `auditoria/02_planos/34_*` (roadmap protocolo) com data de
   ativação.
5. Testar via smoke acima.
6. Commitar via readback novo (este guard novo deve ser citado em
   `scope.files_allowed`).

## Camada CI (onda 0116, 2026-06-05)

Além do pre-commit local, `.github/workflows/hbn-guards-ci.yml` roda em todo
push (main, codex/**) e PR, usando os scripts de `ci/`:

- `ci/validate-contracts.py` — contratos × schemas em modo **ratchet**
  (estrito só nos contratos tocados no range; passivo legado reportado sem
  bloquear; JSON-parse e coerência canonical-root sempre bloqueantes).
- `ci/scope-lock-range.py` — scope-lock POR COMMIT com resolução histórica do
  readback ativo. **Fonte canônica da semântica: `assert-scope-lock.sh`** —
  qualquer mudança no guard local DEVE ser replicada no script de CI.

`assert-canonical-root`/`forbid-tmp-worktree` ficam fora do CI por serem
environment-bound (knowledge 0021). Registro: `auditoria/00_status/125`.
