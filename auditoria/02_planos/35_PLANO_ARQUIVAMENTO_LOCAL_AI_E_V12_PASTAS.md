---
titulo: Plano de arquivamento — local-ai legacy + pastas V12-* + vault Obsidian
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0207
data: 2026-05-24
autor: claude-opus-4-7
papel: arquiteto-principal
horizonte-execucao: Fase 3 do roadmap 90 dias (2026-07-23 a 2026-08-22)
pre-requisito: V12.0.0206 fechada
---

# Plano de arquivamento — fagocitose das árvores paralelas

Este plano descreve **como** remover fisicamente do repositório as três
fontes de "verdade competidora" que hoje fazem qualquer IA escolher errado:

1. **Árvore `local-ai/` legacy** — vault Obsidian antiga (214 .md), auditoria
   antiga, `.cursorrules` apontando para V12.0.0180.
2. **Pastas `V12-*/` na raiz** — 5 snapshots manuais de planilha, fora do git,
   sem manifesto.
3. **Vault Obsidian na raiz** — autodeclarada "ponte histórica", apenas 5
   arquivos vivos misturados com cemitério.

**Importante**: este plano NÃO deve ser executado antes da V12.0.0206 estar
fechada e tagueada. Mexer nas pastas legacy enquanto a V206 está em curso
adiciona risco. A execução é tarefa da V207 (Fase 3 do roadmap protocolo).

## Princípios

- **Preservar é diferente de manter ativo.** Tudo o que sai da `main` vai
  para uma **branch arquivo dedicada**, não é deletado do histórico git.
- **Manifesto SHA-256 obrigatório.** Cada lote arquivado produz um manifesto
  versionado com hash de cada arquivo, antes da remoção, em `auditoria/04_evidencias/V12.0.0207/arquivamento/`.
- **Migração antes de deleção.** Conteúdo útil (perene, decisões, lições)
  é migrado para `docs/`, `.hbn/knowledge/` ou ADRs **antes** de qualquer
  remoção.
- **`forbid-legacy-paths.sh` é a defesa permanente.** Mesmo depois do
  arquivamento, o pre-commit recusa qualquer tentativa de recriar essas
  pastas — `.hbn/forbidden-paths.txt` lista os globs proibidos.

## Bloco 1 — `local-ai/obsidian-vault/` e `local-ai/auditoria/`

### Diagnóstico

`local-ai/obsidian-vault/` tem 214 `.md` espelhando uma vault inteira
desativada que ninguém arquivou. Inclui `ai/`, `arquitetura/`, `backlog/`,
`handoff/`, `regras/`, `releases/` (134 release notes!). O `.cursorrules` em
`local-ai/root/` ainda manda as IAs lerem essa vault morta. Documento canônico
da raiz já se autodeclarou "ponte histórica" (`obsidian-vault/MANIFEST.md`).

### Procedimento

```bash
# Pré-condição: V12.0.0206 tagueada, branch main limpa, todos os hooks instalados.

# 1. Criar branch arquivo
git checkout -b archive/local-ai-pre-canonical-2026-08

# 2. Produzir manifesto SHA-256 antes de qualquer mudança
mkdir -p auditoria/04_evidencias/V12.0.0207/arquivamento/
find local-ai/obsidian-vault local-ai/auditoria local-ai/root \
  -type f -print0 | xargs -0 shasum -a 256 \
  > auditoria/04_evidencias/V12.0.0207/arquivamento/local-ai-legacy-manifest.sha256

# 3. Confirmar tamanho (esperado ~250 .md + binários)
wc -l auditoria/04_evidencias/V12.0.0207/arquivamento/local-ai-legacy-manifest.sha256

# 4. Análise humana — identificar conteúdo perene a salvar
#    (ler MANIFESTO ou usar grep para encontrar ADRs, decisões, lições não migradas)

# 5. Migração de conteúdo perene identificado:
#    - Decisões arquiteturais → ADR novo em auditoria/01_regras_e_governanca/
#    - Lições técnicas → .hbn/knowledge/<NNNN>-<lição>.md
#    - Release notes históricas → consolidar em obsidian-vault/releases/historico/ (que vai pra docs/explanation/historico-releases.md)
#    - Padrões reutilizáveis VBA → usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md

# 6. Commitar a migração e o manifesto na branch archive
git add auditoria/01_regras_e_governanca/ .hbn/knowledge/ docs/ auditoria/04_evidencias/
git commit -m "feat(v207): salvar conteudo perene de local-ai/ antes do arquivamento"

# 7. Voltar para main para fazer a remoção controlada
git checkout main

# 8. Remover fisicamente as pastas legacy
git rm -r local-ai/obsidian-vault/ local-ai/auditoria/ local-ai/root/

# 9. Atualizar .gitignore para impedir recriação acidental
echo "" >> .gitignore
echo "# Arquivado em Onda de V207 — Plano 35" >> .gitignore
echo "local-ai/obsidian-vault/" >> .gitignore
echo "local-ai/auditoria/" >> .gitignore
echo "local-ai/root/" >> .gitignore

# 10. Atualizar AGENTS.md / CLAUDE.md removendo qualquer referência a essas pastas

# 11. Atualizar .hbn/forbidden-paths.txt (já tem, validar)

# 12. Commitar via readback HBN
#     (o pre-commit assert-scope-lock vai exigir scope.files_allowed adequado)
```

### Critério de aceite

- `local-ai/obsidian-vault/` e `local-ai/auditoria/` não existem mais na
  `main`.
- Branch `archive/local-ai-pre-canonical-2026-08` existe no remote com tudo
  preservado.
- Manifesto SHA-256 em `auditoria/04_evidencias/V12.0.0207/arquivamento/`.
- AGENTS.md, CLAUDE.md, e qualquer outro doc não cita essas pastas.
- `bash scripts/hbn-guards/forbid-legacy-paths.sh` rejeita tentativa de
  re-adicionar.

## Bloco 2 — Pastas `V12-*/` na raiz

### Diagnóstico

5 pastas-snapshot na raiz, fora do git (xlsm está no `.gitignore`):

| Pasta | Conteúdo |
|---|---|
| `V12-0206-Preparaçao/` | 1 xlsm de 24/05, encoding errado no nome (Preparaçao sem ç correto). Era "preparação" para V206 antes da V5 — agora obsoleto. |
| `V12-2024-Micro54-RC1/` | 1 xlsm de 11/05, nome com erro tipográfico (2024 deveria ser 0204) |
| `V12-204-Micro48/` | 67 arquivos `.bas/.frm/.frx` (export VBA bruto de microdelta histórico) |
| `V12-205-001-Inicial/` | 1 xlsm de 21/05 |
| `V12-205-OficialCongelada/` | 1 xlsm de 24/05 — **esta é a origem da V5 atual, fonte ainda relevante** |

### Decisão arquitetural

- **`V12-205-OficialCongelada/` permanece temporariamente** até a V12.0.0206
  estar tagueada. Depois disso, é migrada para o repo de snapshots.
- **As outras 4 pastas vão para um repositório dedicado**
  `credenciamento-snapshots` (ou git-lfs no mesmo repo, conforme decisão de
  Mauricio). Cada pasta vira uma tag assinada `snapshot/<nome>` no repo de
  snapshots, com manifesto SHA-256 da planilha + commit message explicando
  origem e razão da existência.

### Procedimento

```bash
# Pré-condição: V12.0.0206 tagueada, F1 e F2 do roadmap protocolo concluídas.

# 1. Decidir repo separado vs git-lfs (recomendação Opus: repo separado,
#    mantém o repo principal leve e o controle de acesso CLA mais simples)

# Opção A — Repo separado (recomendada):

mkdir ~/Projetos/credenciamento-snapshots
cd ~/Projetos/credenciamento-snapshots
git init
git lfs install
git lfs track "*.xlsm" "*.frx"
echo "*.xlsm filter=lfs diff=lfs merge=lfs -text" > .gitattributes
echo "*.frx  filter=lfs diff=lfs merge=lfs -text" >> .gitattributes
git add .gitattributes
git commit -m "init: snapshots historicos do Credenciamento"

# Para cada pasta V12-*:
for d in V12-204-Micro48 V12-205-001-Inicial V12-2024-Micro54-RC1 V12-0206-Preparaçao; do
  mkdir -p "snapshots/$d"
  cp -R "~/Projetos/Credenciamento/$d/." "snapshots/$d/"
  shasum -a 256 "snapshots/$d"/* > "snapshots/$d/MANIFEST.sha256"
  cat > "snapshots/$d/README.md" <<EOF
# Snapshot $d

Origem: pasta-snapshot manual da raiz de Credenciamento em 2026-05-24.
Conteúdo: planilha .xlsm + (opcional) export bruto VBA.
Status: histórico congelado — não é versão oficial nem âncora.

Referência: auditoria/02_planos/35_PLANO_ARQUIVAMENTO_LOCAL_AI_E_V12_PASTAS.md
no repo Credenciamento.
EOF
  git add "snapshots/$d/"
  git commit -m "snapshot: $d (histórico congelado, plano 35)"
  git tag -a "snapshot/$d" -m "Snapshot $d preservado para auditoria"
done

# 2. Voltar para o repo Credenciamento e remover as pastas
cd ~/Projetos/Credenciamento
rm -rf V12-204-Micro48 V12-205-001-Inicial V12-2024-Micro54-RC1 V12-0206-Preparaçao
# (V12-205-OficialCongelada por enquanto fica)

# 3. Atualizar .gitignore (já estão fora do git por xlsm filter, mas reforçar)
echo "" >> .gitignore
echo "# Pastas-snapshot migradas para credenciamento-snapshots em Plano 35" >> .gitignore
echo "V12-*/" >> .gitignore

# 4. .hbn/forbidden-paths.txt já tem; validar.

# 5. Commitar via readback HBN.
```

### Critério de aceite

- 4 pastas removidas da raiz; tags `snapshot/*` existem no repo de snapshots
  com manifesto SHA-256.
- Repo de snapshots tem pelo menos 1 release publicada com instruções de
  recuperação ("como reconstituir a planilha V12-204-Micro48").
- `forbid-legacy-paths.sh` rejeita criação de novas pastas `V12-*/` na raiz.

## Bloco 3 — Vault Obsidian na raiz (`obsidian-vault/`)

### Diagnóstico

A vault na raiz tem apenas:

- `00-DASHBOARD.md` (mantido em dia — perene)
- `MANIFEST.md` (autodeclarado "ponte histórica" — confissão de cemitério)
- `2026-05-09.md` (vazio, 0 bytes — daily note órfão)
- `Sem título.base` (40 bytes) e `Sem título.canvas` (2 bytes) — criados por engano
- `metodologia/` (4 docs perenes — bons)
- `releases/` (3 docs vigentes + `historico/` com 53 release notes)
- Sem MOC, sem wikilinks `[[...]]`, sem tags, sem dataview

### Decisão arquitetural

- **Conteúdo perene** (`00-DASHBOARD.md`, `metodologia/*`, `releases/V12.0.020*.md` vigentes)
  migra para `docs/` (estrutura Diataxis):
  - `00-DASHBOARD.md` → `docs/reference/dashboard-projeto.md` (gerado por script a partir dos KPIs reais, não copiado)
  - `metodologia/*` → `docs/explanation/metodologia/`
  - `releases/V12.0.0205.md`, etc. → `docs/reference/releases/`
  - `releases/historico/*` → ou consolida em `docs/explanation/historico-releases.md`, ou move para repo de snapshots
- **Conteúdo de log/cemitério** (daily notes vazios, base/canvas vazios) é
  deletado.
- **A pasta `obsidian-vault/` na raiz deixa de existir.**
- Vault Obsidian PESSOAL de Mauricio nasce em `~/ObsidianVault/Pessoal/`
  (fora dos repos) — com MOC, daily notes via Templater, wikilinks reais,
  links bidirecionais para os arquivos `docs/` dos projetos (referência por
  path, não cópia).

### Procedimento

Migração delicada. Recomendação: fazer em onda **safe_track exclusiva**, com
readback declarando `scope.files_allowed` exato e auditor (Gemini ou outro
Opus) revisando antes do commit. Sem atalhos.

```bash
# Onda V207 dedicada — readback NNNN-onda-fagocitose-obsidian.json

# 1. Manifesto antes
shasum -a 256 obsidian-vault/**/*.md > auditoria/04_evidencias/V12.0.0207/arquivamento/obsidian-vault-manifest.sha256

# 2. Migrar perene (cada arquivo é uma cópia validada por humano)
mkdir -p docs/explanation/metodologia/ docs/reference/releases/
cp obsidian-vault/metodologia/*.md docs/explanation/metodologia/
cp obsidian-vault/releases/V12.0.020*.md docs/reference/releases/
# ... (caso a caso)

# 3. Remover vault
git rm -r obsidian-vault/

# 4. Atualizar referências (grep por "obsidian-vault/" em todo o repo)
grep -r "obsidian-vault/" --include="*.md" --include="*.json" -l \
  | xargs sed -i.bak 's|obsidian-vault/metodologia/|docs/explanation/metodologia/|g'
# (revisão humana de cada substituição)

# 5. Atualizar AGENTS.md (item 7 da lista de leitura obrigatória) e CLAUDE.md

# 6. .hbn/forbidden-paths.txt adicionar:
echo "obsidian-vault/**" >> .hbn/forbidden-paths.txt

# 7. Commitar via readback HBN (vai disparar muitos guards — bom!)
```

### Critério de aceite

- `obsidian-vault/` não existe na `main`.
- Conteúdo perene acessível em `docs/`.
- Nenhuma referência morta a `obsidian-vault/` em qualquer `.md` ou `.json`
  versionado.
- Vault Obsidian pessoal de Mauricio existe em `~/ObsidianVault/Pessoal/`
  com MOC funcional.

## Bloco 4 — `Credenciamento/usehbn/` → submódulo

### Diagnóstico

`Credenciamento/usehbn/` é uma cópia parcial e desatualizada do canônico em
`/Projetos/usehbn/`. Faltam `ADR-AND-MD-PRIMER.md`, `MATURITY-MATRIX.md`,
`adr/`, `templates/`. Tem `CASE-STUDY-CREDENCIAMENTO.md` referenciado em
`obsidian-vault/metodologia/02-INTEGRACAO-USEHBN.md` linhas 136 e 150 mas
**inexistente** no `usehbn/docs/` local.

### Procedimento

```bash
# Pré-condição: o repo /Projetos/usehbn/ tem uma tag estável (ex.: v0.3.1)

# 1. Remover a cópia atual
git rm -r usehbn/

# 2. Adicionar como submódulo (substitui leitura cópia por referência)
git submodule add ../usehbn.git usehbn
cd usehbn
git checkout v0.3.1   # pin de tag
cd ..
git add .gitmodules usehbn

# 3. AGENTS.md, CLAUDE.md, README.md atualizados para "submódulo apontando para tag v0.3.1"

# 4. Commitar via readback
```

### Critério de aceite

- `usehbn/` é um submódulo git, pinado em tag específica.
- `git submodule status` mostra hash limpo (sem `+` ou `-`).
- Qualquer mudança no protocolo HBN exige bump de tag + atualização do submódulo
  via PR explícito.

## Bloco 5 — Limpeza geral final

```bash
# Remover lockfiles esquecidos
git rm --cached "~\$PlanilhaCredenciamento-Homologacao*.xlsm" 2>/dev/null || true

# Remover .DS_Store
find . -name ".DS_Store" -not -path "./.git/*" -exec git rm --cached {} \;

# Reforçar .gitignore
cat >> .gitignore <<'EOF'

# Reforço final Plano 35
~$*.xlsm
~$*.xls
~$*.xlsx
.DS_Store
**/.DS_Store
*.tmp.frm
*.bak
EOF
```

## Ordem de execução recomendada na Fase 3

1. **Semana 9**: Bloco 1 — `local-ai/obsidian-vault/` + `local-ai/auditoria/` (vault morta, baixo risco)
2. **Semana 9–10**: Bloco 4 — submódulo `usehbn/` (operação atômica, baixo risco)
3. **Semana 10–11**: Bloco 3 — `obsidian-vault/` raiz (delicado, exige migração)
4. **Semana 11**: Bloco 2 — pastas `V12-*/` (depende de setup do repo de snapshots)
5. **Semana 12**: Bloco 5 — limpeza geral + verificação dos hooks rejeitando re-criação

## Riscos específicos

| Risco | Mitigação |
|---|---|
| Quebrar referências cross-doc | grep exaustivo antes de qualquer remoção + redirect 404 documentado |
| Perder uma lição não migrada | manifesto SHA-256 sempre antes; branch arquivo sempre depois; tudo recuperável |
| Mauricio precisar consultar pasta arquivada | `git checkout archive/local-ai-pre-canonical-2026-08` resolve em segundos |
| Submódulo usehbn dessincronizar | CI semanal valida que `git submodule status` é limpo |
| Pastas-snapshot serem requisitadas pelo cliente | repo separado tem release pública com instrução de recuperação |

## Compromissos do Opus

- Cada um dos 5 blocos vira **uma onda HBN dedicada** com readback, audit-pre,
  hearback, audit-post, ERP. Não é "uma comissão de limpeza" — é processo
  governado.
- Em caso de descoberta de conteúdo perene não previsto, **parar a onda** e
  abrir nova decisão humana (não decidir unilateralmente).
- Antes da F3 começar, revalidar este plano contra estado real do repo (que
  pode ter mudado nos 60 dias de F1+F2).

— Claude Opus 4.7, 2026-05-24
