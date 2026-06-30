---
titulo: uv
slug: uv
categoria: outros
estado: archived
data-entrada: 2026-05-02
ultima-revisao: 2026-05-06 (arquivada por Maurício após análise — argumento pró-Rust virou pró-linguagem-base-Rust)
proxima-revisao: 2027-05-06
fonte-radar: "local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: MIT OR Apache-2.0 (dual-license)
motivo-arquivamento: argumentation-flip-pro-rust-base-language
pode-reentrar-se: decidirmos manter Python como linguagem-base do hbn-phago E precisarmos de gerenciador moderno
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
decisao-final: ARQUIVADA — argumento pró-uv (escrito em Rust) foi invertido por Maurício para "se a vantagem é Rust, escrevamos a base em Rust"
---

# uv

## Por que está no radar

uv simplifica drasticamente o ambiente de desenvolvimento Python do `usehbn-phago`. Substitui o conjunto `pip + pip-tools + virtualenv + pyenv + pipx` por uma única ferramenta 10-100x mais rápida. Para uma CLI Python que precisa instalar rápido em máquinas novas (Maurício, Codex, contribuidores externos futuros), uv é diferença qualitativa entre "instala em segundos" e "instala em minutos".

Fonte inicial: propostas Codex 103/103b. Stack coesa para Wave 11+ junto com Typer.

## Resumo da tecnologia

uv é um gerenciador de pacotes Python ultrarrápido escrito em Rust pela Astral (mesma empresa do `ruff` linter). Lançado em fevereiro/2024; em 2026 já é amplamente adotado (FastAPI, Pydantic, muitos projetos OSS migraram).

Núcleo técnico:
- Resolução de dependências 10-100x mais rápida que pip (paralelismo agressivo + cache global)
- `uv sync` instala/atualiza ambiente para corresponder ao `pyproject.toml` + `uv.lock`
- Lock file determinístico (`uv.lock`) com cross-platform support (macOS, Linux, Windows)
- Gerencia versões Python via download (substitui `pyenv` — `uv python install 3.12`)
- Suporta scripts standalone com inline metadata (PEP 723): `# /// script\n# dependencies = [...]\n# ///`
- `uvx` para executar tools transientes (substitui `pipx`)
- Compatível com `pyproject.toml` PEP 621 padrão (sem schema próprio)
- Cache global compartilhado entre projetos (reuso de wheels — disco economizado)

Diferencial vs alternativas:
- vs **pip + venv**: 100x mais rápido; lockfile real; gerenciamento de Python
- vs **Poetry**: mais rápido; usa pyproject.toml standard (Poetry tem schema próprio); sem lock-in de schema
- vs **pdm**: mais rápido; mais adoção; mais features
- vs **hatch**: foco diferente (uv = deps + Python; hatch = build + envs)

Licença: dual MIT/Apache-2.0. Mantenedor: Astral (~25 funcionários, VC-backed). Maturidade: produção em projetos grandes desde meados de 2024.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | Gerencia ambiente sem alterar código do projeto; o `uv.lock` é deterministicamente reproduzível. Não toca dependências sem comando explícito. |
| 2 | Documentar antes de executar | sim | `pyproject.toml` + `uv.lock` documentam exatamente o que está instalado em cada commit. Estado do ambiente é arquivo versionado. |
| 3 | Testar antes de refatorar | sim | Cache permite recriar ambiente idêntico em CI para validar regressões. `uv sync --frozen` garante exatamente as versões do lock. |
| 4 | Explicar antes de automatizar | sim | `uv lock --upgrade --dry-run` mostra exatamente o que mudaria sem aplicar. `uv tree` mostra dependências resolvidas. |
| 5 | Humano no controle por padrão | sim | Cada `uv add`, `uv sync`, `uv lock --upgrade` é explícito. Sem auto-instalação, sem auto-upgrade silencioso. |
| 6 | Toda evolução deve ser reversível | sim | `git checkout uv.lock` + `uv sync` recupera estado exato anterior. Reversibilidade trivial via git. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | Gerencia Python; não toca o que está sendo gerenciado pelo Python (código aplicação). |
| 8 | O protocolo importa mais que a ferramenta | sim | `pyproject.toml` é padrão PEP 621; `uv.lock` é específico mas `uv export --format requirements-txt` produz arquivo pip-compatível. Volta para pip é sempre possível. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | Lock-in muito baixo. `uv export` produz fallback pip. Trocar para Poetry/pdm exige migração mas pyproject.toml core é compartilhado. |
| 10 | Segurança e não-regressão > velocidade | sim | Hash verification em wheels (SHA-256); lock determinístico evita supply-chain surprise; suporta `--require-hashes`. |

**Convergência média: 10/10 sim, 0/10 parcial, 0/10 não.** Encaixe arquitetural perfeito.

## Divergências e riscos

- **Vendor risk**: MÉDIO — Astral é startup VC-backed (~$60M Series A em 2024); modelo de negócio em construção (alguns recursos pagos planejados; core uv permanece OSS). Fork-friendly se Astral pivotar (MIT/Apache permite)
- **Velocidade de evolução**: ACELERADA — releases mensais; breaking changes possíveis em comandos beta (avaliar `uv build`, `uv publish` antes de adotar)
- **Performance**: o ponto forte; nenhum risco operacional aqui
- **Lock-in técnico**: MUITO BAIXO (volta para pip facilmente via `uv export`)
- **Compatibilidade AGPLv3**: MIT/Apache-2.0 são compatíveis (sublicenciáveis em AGPLv3)
- **Adoção corporativa**: alguns ambientes enterprise ainda dependem de pip + custom indexes; uv suporta mas validar com proxy/firewall
- **Ecossistema de plugins**: pip tem plugins legados que uv não cobre (raro, mas possível)

## O que precisa para avançar de estado

Para `candidate` (programado 2026-05-04):
- POC trivial: `uv init` em diretório de teste + `uv add typer pydantic` + medir tempo (esperado: 2-5s vs 30-60s com pip)
- Confirmar funcionamento em macOS Sequoia + Apple Silicon do Maurício (`uv --version`)
- Validar que `uv lock` produz `uv.lock` estável e reprodutível em re-runs
- Decidir se vai usar `uv sync --frozen` em CI (recomendado para reprodutibilidade)

Para `phagocytosed`:
- `usehbn-phago/pyproject.toml` + `uv.lock` checked-in no repo
- README documentando: "instale com `uv sync`"
- CI usa `uv sync --frozen` para garantir reprodutibilidade

## Histórico de transições

| Data | De | Para | Motivo | Decisor |
|---|---|---|---|---|
| 2026-05-02 | n/a | under-analysis | Entrada inicial no bootstrap E1 do Radar | Codex CLI, sob spec Opus |
| 2026-05-02 | under-analysis | under-analysis | Reescrita E1.1 (Codex — análise template) | Codex CLI |
| 2026-05-02 | under-analysis | under-analysis | Análise profunda Opus — recomenda promoção a candidate em 2026-05-04 | Claude Opus 4.7 (Frente 2) |
| **2026-05-06** | **under-analysis** | **archived** | **Maurício arquivou: argumento pró-uv (escrito em Rust) foi INVERTIDO — "se a grande vantagem é Rust, por que não escrevemos a base do useHBN em Rust direto?". Implicação: decisão arquitetural maior pendente sobre TROCAR linguagem-base de Python para Rust/Go/Swift/Zig. uv só faria sentido se mantivermos Python; se mudarmos plataforma, uv vira irrelevante.** | **Maurício (palavra final)** |

## Nota de arquivamento — racional Maurício 2026-05-06

Após análise inicial via Notebook LM, Maurício articulou inversão arquitetural radical (citação operacional):

> "Se a grande vantagem é que ele foi escrito em Rust, para uma linguagem compilada, por que não voltamos nossa base de comunicação criando uma linguagem com alicerces sólidos em Rust, Go, Swift ou outra linguagem moderna que permita uma reconstrução estrutural profunda e sólida? Em seis meses a fricção do processo de desenvolvimento será superado pela escrita de código por IAs, como estamos fazendo agora. Logo, a interface de abstração é a de utilizarmos o máximo de linguagem compilada com microestruturas documentadas e de comportamento seguro. Precisamos evitar o spaghetti code e a metástase de dependências."

Esse racional cunha o **Princípio do Substrato Sólido** (ver `usehbn/methodology/SUBSTRATO-SOLIDO-PRINCIPLE.md`) — complementar ao Princípio do Minimalismo de Cadeia (formalizado em 2026-05-06 manhã após arquivamento de Typer).

**Decisão arquitetural maior pendente**: trocar linguagem-base do `usehbn-phago` de Python para linguagem compilada. Comparativo de candidatas em `usehbn/methodology/LANGUAGE-PLATFORM-COMPARISON.md`. Decisão final virá no prompt unificado ao Codex após análise das 5 tecnologias.

**Reentrada permitida** se: (a) mantivermos Python como linguagem-base — então uv volta a ser relevante; (b) Astral entregar uv compilado standalone (Rust nativo binário) que não exija Python instalado — torna uv tool universal independente de plataforma.

## Referências

- [Documentação oficial](https://docs.astral.sh/uv/) — guia completo, comandos, configuração
- [Repositório GitHub](https://github.com/astral-sh/uv) — MIT/Apache-2.0
- [Anúncio inicial Astral (fev/2024)](https://astral.sh/blog/uv) — racional + benchmarks
- [PEP 621 — pyproject.toml standard](https://peps.python.org/pep-0621/)
- [PEP 723 — inline script metadata](https://peps.python.org/pep-0723/)
- [Comparativo uv vs Poetry vs pdm vs hatch](https://docs.astral.sh/uv/concepts/projects/) — seção "alternatives"
- [Astral (empresa)](https://astral.sh/) — também responsável por `ruff`
- Fonte interna: `local-ai/Time_AI/2026-05-02-V203-fechamento/103b-Codex-Protocolo-usehbn-Propostas.md`
