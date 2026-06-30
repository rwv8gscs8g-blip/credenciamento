---
titulo: Plano de Estudo Profundo — uv (gerenciador Python ultrarrápido)
diataxis: tutorial
hbn-track: knowledge
hbn-status: active
audiencia: humano
data: 2026-05-02
tempo-estimado: 3-5 horas (incluindo Notebook LM)
licenca-target: usehbn (AGPLv3)
ficha-radar: ../radar/_per-technology/uv.md
---

# Plano de Estudo Profundo — uv

## Por que estudar profundo

Maurício: "O UV está completamente aderente ao que quero fazer, preciso também de plano de estudo e aprofundamento. Esse pode ficar no radar."

uv é a tecnologia da lista com **convergência 10/10** — encaixe perfeito com os princípios. Mas adoção sem entendimento da história e tradeoffs gera dependência cega. Este plano cobre uv em profundidade + comparativos + transição vinda de pip/Poetry.

## Visão geral em 3 níveis

### Nível 1 — uma frase
uv é um gerenciador de pacotes e ambientes Python escrito em Rust pela Astral, 10-100x mais rápido que pip e que substitui o conjunto pip + virtualenv + pyenv + pipx em uma ferramenta única.

### Nível 2 — um parágrafo
Lançado em fevereiro de 2024 pela Astral (mesma empresa do linter `ruff`), uv foi desenhado para resolver fricções históricas do ecossistema Python: instalação lenta, lockfiles inconsistentes, gerenciamento de versões Python via terceiros (pyenv, conda), ferramentas dispersas (pip + virtualenv + pip-tools). Em 18 meses, virou padrão de fato em projetos OSS modernos (FastAPI, Pydantic, muitos times grandes migraram). A combinação Rust + paralelismo agressivo + cache global produz performance que muda qualitativamente o workflow — `uv sync` em 3 segundos vs `pip install -r requirements.txt` em 60 segundos.

### Nível 3 — visão arquitetural
A aposta da Astral é consolidar o ecossistema Python sob ferramentas escritas em linguagens compiladas (Rust). Já entregaram `ruff` (linter+formatter) e `uv` (env+packages); planejam expansão. O modelo de negócio é misto: core OSS (MIT/Apache permite fork-friendly), recursos pagos planejados para enterprise (Astral Sky — 2025+). Para o useHBN, importa: lock-in técnico é mínimo (PEP 621 standard, `uv export` gera fallback pip), vendor risk médio mas mitigável.

## Pré-requisitos

| Pré-req | Por que importa |
|---|---|
| Familiaridade com pip | Para entender o que uv substitui |
| `pyproject.toml` (PEP 621) | uv usa este formato (não inventou outro) |
| Conceito de lockfile | Diferença entre `requirements.txt` e lock determinístico |
| Virtualenv básico | Para apreciar a integração que uv faz |

## Conceitos fundamentais

### Bloco A — Histórico do ecossistema Python (1h)

1. **Era pip** (2008-): instala packages, sem isolamento — caos
2. **Era virtualenv** (2010+): isolamento por projeto, mas manual
3. **Era pip-tools** (2014+): `pip-compile` gera `requirements.txt` lockfile
4. **PEPs modernos**: PEP 517 (build system), PEP 518 (`pyproject.toml`), PEP 621 (project metadata), PEP 660 (editable installs), PEP 723 (inline script metadata)
5. **Era Poetry** (2018+): primeiro all-in-one moderno, mas lento e schema próprio
6. **Era pdm/Rye/hatch** (2020+): tentativas variadas
7. **Era uv** (2024+): Rust + velocidade + PEP-compliance

### Bloco B — Comandos uv essenciais (1.5h)

```bash
# Project lifecycle
uv init                          # cria pyproject.toml, .venv, .python-version
uv add typer pydantic            # adiciona dep + atualiza lock + instala
uv remove pydantic               # remove dep
uv sync                          # instala exatamente o que está no lock
uv sync --frozen                 # erro se lock divergir do pyproject (CI)
uv lock --upgrade                # atualiza lock para versões mais novas

# Execução
uv run python script.py          # roda no env do projeto
uv run pytest                    # roda comando do env
uv run --with httpx python ...   # adiciona dep transiente

# Python management
uv python install 3.12           # baixa Python 3.12
uv python list                   # lista versões disponíveis/instaladas

# Tool management (substitui pipx)
uv tool install ruff             # instala como ferramenta global isolada
uv tool run black .              # roda sem instalar
uvx black .                      # alias de tool run

# Pip-compatibility
uv pip install requests          # modo compatibilidade pip
uv pip compile pyproject.toml    # gera requirements.txt
uv export --format requirements-txt > req.txt  # fallback
```

### Bloco C — Comparativo com alternativas (1h)

| Aspecto | pip+venv | Poetry | pdm | uv |
|---|---|---|---|---|
| Velocidade resolve | lenta | lenta | média | **muito rápida** |
| Lockfile | manual (pip-tools) | sim (poetry.lock) | sim (pdm.lock) | sim (uv.lock) |
| pyproject.toml standard? | sim | **não** (schema próprio) | sim | sim |
| Gerencia Python | não | não | parcialmente | sim |
| Substitui pipx | não | não | não | sim (uvx) |
| Cache global | não | não | parcial | sim |
| Linguagem | Python | Python | Python | Rust |
| Maturidade | máxima | alta | média | crescente |
| Lock-in | nenhum | médio | baixo | baixo |

## Fontes primárias

### Documentação
- [uv Documentation](https://docs.astral.sh/uv/) — site oficial completo
- [Getting Started](https://docs.astral.sh/uv/getting-started/) — primeiro contato
- [Concepts/Projects](https://docs.astral.sh/uv/concepts/projects/) — workflow de projeto
- [Reference/Settings](https://docs.astral.sh/uv/reference/settings/) — toda configuração

### Código-fonte
- [uv GitHub](https://github.com/astral-sh/uv) — MIT/Apache-2.0
- [Astral company](https://astral.sh/) — sobre a empresa

### Anúncios oficiais
- [Anúncio inicial uv (fev/2024)](https://astral.sh/blog/uv) — racional original
- [uv 1.0 announcement](https://astral.sh/blog/uv-unified-python-packaging) — consolidação
- [Roadmap Astral](https://astral.sh/blog) — visão de futuro

### PEPs relevantes
- [PEP 517 — A build-system independent format](https://peps.python.org/pep-0517/)
- [PEP 518 — pyproject.toml](https://peps.python.org/pep-0518/)
- [PEP 621 — Storing project metadata](https://peps.python.org/pep-0621/)
- [PEP 723 — Inline script metadata](https://peps.python.org/pep-0723/)

## Fontes secundárias

### Comparativos
- [Hynek Schlawack — "Production-ready Python with uv"](https://hynek.me/articles/) — patterns reais
- [Rye vs uv vs Poetry comparison](https://docs.astral.sh/uv/concepts/projects/) — seção alternatives
- [Real Python on uv](https://realpython.com/python-uv/)

### Vídeos
- [uv tutorial — vários canais](https://www.youtube.com/results?search_query=uv+python+package+manager)
- [Charlie Marsh (Astral founder) — Talk on Astral vision](https://www.youtube.com/results?search_query=charlie+marsh+ruff+uv)

### Casos reais
- [FastAPI migrou para uv](https://fastapi.tiangolo.com/) — verificar `pyproject.toml`
- [Pydantic migrou para uv](https://github.com/pydantic/pydantic) — verificar workflow

## Hands-on exercises

### Exercício 1 — Instalação (15 min)
```bash
# macOS
curl -LsSf https://astral.sh/uv/install.sh | sh
# verificar
uv --version
```

### Exercício 2 — Bootstrap usehbn-phago real (30 min)
```bash
cd ~/Projetos/usehbn-phago
uv init  # se ainda não está iniciado
uv add typer[all]
uv add tree-sitter
uv sync
```
Verificar criação de `.venv/`, `uv.lock`. Comparar tempo com `pip install`.

### Exercício 3 — Lock determinístico (30 min)
- Apagar `.venv/`
- `uv sync` — deve recriar idêntico
- Compartilhar `uv.lock` para outra máquina (ou container) — mesma resolução

### Exercício 4 — Inline scripts PEP 723 (30 min)
Criar `script.py`:
```python
# /// script
# dependencies = ["httpx"]
# ///
import httpx
print(httpx.get("https://api.github.com").status_code)
```
Rodar: `uv run script.py` — deve baixar httpx, executar, descartar.

### Exercício 5 — Tool management (30 min)
- `uv tool install ruff`
- `ruff check .`
- Comparar com `uvx ruff check .` (transient)

### Exercício 6 — Migração de pip+venv (1h)
Pegar projeto Python existente seu (qualquer um) com `requirements.txt`. Migrar para uv:
```bash
uv init
# converter requirements.txt para pyproject.toml deps
uv add --requirements requirements.txt
uv lock
uv sync
```

### Exercício 7 — CI integration (30 min)
Configurar GitHub Actions:
```yaml
- uses: astral-sh/setup-uv@v3
- run: uv sync --frozen
- run: uv run pytest
```

## Perguntas para aprofundamento

1. Como uv consegue ser 10-100x mais rápido que pip? (paralelismo, Rust, cache)
2. Por que `uv.lock` é cross-platform mas `requirements.txt` muitas vezes não é?
3. Modelo de negócio da Astral: como sustentável a longo prazo?
4. Quando preferir Poetry sobre uv?
5. Como lidar com packages que não tem wheels (precisam compilar)?
6. uv suporta extras ([standard], [all], etc.)?
7. Como configurar índice privado (Artifactory, devpi)?
8. Migração reversa: como sair de uv se necessário?
9. Performance em monorepos (vários projetos no mesmo repo)?
10. Comparativo com conda para data science workloads?

## Conexão com os 10 princípios useHBN

| Princípio | Como uv encarna |
|---|---|
| **P1 — Preservar antes de transformar** | Lockfile determinístico = ambiente reproduzível |
| **P2 — Documentar antes de executar** | `pyproject.toml` + `uv.lock` = doc viva versionada |
| **P3 — Testar antes de refatorar** | `--frozen` em CI garante reprodutibilidade |
| **P5 — Humano no controle** | Sem auto-upgrade silencioso |
| **P6 — Reversibilidade** | `git checkout uv.lock` + `uv sync` = volta no tempo |
| **P9 — Frameworks descartáveis** | `uv export` produz `requirements.txt` para fallback pip |
| **P10 — Segurança** | Hash verification em wheels |

## Critérios de "estudei o suficiente"

- [ ] Bootstrap do `usehbn-phago` com uv funcional
- [ ] Explicar diferença entre `uv sync` e `uv sync --frozen`
- [ ] Executar `uv lock --upgrade --dry-run` e interpretar output
- [ ] Discutir vendor risk e mitigação (fork OSS)
- [ ] Decidir se uv vira fagocitada (G2 do roadmap)

## Sequência sugerida (4 horas distribuídas)

1. **Hora 1** — Docs oficiais Getting Started + Concepts
2. **Hora 2** — Notebook LM podcast (gerado pelo superprompt)
3. **Hora 3** — Exercícios 1-4
4. **Hora 4** — Exercícios 5-7 + perguntas

## Versão

- v1.0 — 2026-05-02 — plano inicial.
