---
titulo: Plano de Estudo Profundo — Typer (incluindo cadeia de dependências)
diataxis: tutorial
hbn-track: knowledge
hbn-status: active
audiencia: humano
data: 2026-05-02
tempo-estimado: 4-6 horas (incluindo Notebook LM)
licenca-target: usehbn (AGPLv3)
ficha-radar: ../radar/_per-technology/typer.md
---

# Plano de Estudo Profundo — Typer

## Por que estudar profundo

Maurício observou: "Typer pareceu-me uma boa ideia, mas preocupa-me a recorrência de dependências como o click e outros que nao foram citados aqui. Preciso que me aprofunde mais."

Esse plano dedica seção específica à **árvore completa de dependências** de Typer + análise de cada uma. Quando você terminar este plano, saberá exatamente o que está sendo trazido para o `hbn-phago` se Typer for fagocitada.

## Visão geral em 3 níveis

### Nível 1 — uma frase
Typer é um framework Python para construir CLIs (Command Line Interfaces) usando type hints, criado pelo mesmo autor do FastAPI.

### Nível 2 — um parágrafo
Sebastián Ramírez (FastAPI, SQLModel) lançou Typer em 2019 como camada sobre Click — biblioteca CLI clássica do Python — adicionando type-driven development. A ideia central: type hints de função Python (`name: str`, `count: int`, `path: Path`) viram automaticamente argumentos validados da CLI, com `--help` gerado de docstrings, autocompletion para shells, e integração com Rich para output bonito. Resultado: CLIs profissionais com 10-20% do código que argparse exigiria.

### Nível 3 — visão arquitetural
Typer é "Click + type-driven UX". Não substitui Click — usa-o internamente. A escolha de empilhar sobre Click (não reimplementar) tem custo (transitive dependencies) e benefício (Click é maduro, testado, documentado). Para o useHBN, importa entender que adotar Typer = adotar Click + Rich + alguns extras transitive — e o que cada um traz.

## Cadeia completa de dependências (resposta à preocupação de Maurício)

### Dependências diretas (declaradas no `pyproject.toml` do Typer v0.12)

```python
[tool.poetry.dependencies]
python = ">=3.7"
click = ">=8.0.0"
typing-extensions = ">=3.7.4.3"
rich = ">=10.11.0"      # opcional via [all]
shellingham = ">=1.3.0" # opcional via [all]
```

### Por dependência — análise de cada uma

#### 1. **Click** ([repo](https://github.com/pallets/click), [docs](https://click.palletsprojects.com/))

| Aspecto | Valor |
|---|---|
| Mantenedor | Pallets Projects (Armin Ronacher + comunidade) — também mantém Flask, Jinja2, Werkzeug |
| Licença | BSD-3-Clause |
| Idade | 2014+ (12 anos em 2026) — projeto maduro, estável |
| Tamanho | ~5 MB instalado |
| Dependências transitivas | **zero** — Click é self-contained |
| Por que existe | Decorator-based CLI parsing (`@click.command`, `@click.option`) — mais ergonômico que argparse |
| Risco | BAIXÍSSIMO — projeto mais maduro e estável do ecossistema CLI Python |

#### 2. **typing-extensions** ([repo](https://github.com/python/typing_extensions))

| Aspecto | Valor |
|---|---|
| Mantenedor | Python core team (mesmo grupo do `typing` stdlib) |
| Licença | PSF |
| Por que existe | Backport de features de `typing` recentes para versões mais antigas de Python |
| Tamanho | <1 MB |
| Dependências transitivas | **zero** |
| Risco | ZERO — é praticamente stdlib |

#### 3. **Rich** ([repo](https://github.com/Textualize/rich), [docs](https://rich.readthedocs.io/))

| Aspecto | Valor |
|---|---|
| Mantenedor | Will McGugan + Textualize (empresa que mantém também Textual) |
| Licença | MIT |
| Idade | 2020+ — mais novo que Click; maduro e amplamente adotado |
| Tamanho | ~10 MB instalado |
| Dependências transitivas | `markdown-it-py`, `pygments` — ambos pequenos e estáveis |
| Por que existe | Output formatado (cores, tabelas, progress bars, syntax highlighting, markdown) |
| Risco | BAIXO — Will McGugan tem trajetória sólida; sponsorships estáveis |
| **Opcionalidade** | Typer funciona sem Rich (degrada graciosamente para output texto puro). Instala via `typer[all]` se quiser. |

#### 4. **shellingham** ([repo](https://github.com/sarugaku/shellingham))

| Aspecto | Valor |
|---|---|
| Mantenedor | Tzu-ping Chung (sarugaku) |
| Licença | ISC |
| Por que existe | Detecta qual shell está rodando (bash/zsh/fish/PowerShell) — usado por autocompletion |
| Tamanho | < 100 KB |
| Dependências transitivas | **zero** |
| Risco | BAIXO — dependência minúscula, propósito muito específico |
| **Opcionalidade** | Só necessária para autocompletion. Skip se não precisar. |

### Árvore final completa (com `typer[all]` instalado)

```text
typer (5MB)
├── click (5MB) — BSD-3, Pallets
├── typing-extensions (<1MB) — PSF, Python core
├── rich (10MB) — MIT, Textualize
│   ├── markdown-it-py (~500KB) — MIT
│   │   └── mdurl (~50KB) — MIT
│   └── pygments (~5MB) — BSD-2 — syntax highlighting
└── shellingham (<100KB) — ISC, sarugaku
```

**Total instalado**: ~25 MB. **Transitivas**: 7 packages. **Vendor risk consolidado**: BAIXO — todos os mantenedores são figuras estabelecidas do ecossistema Python.

### Comparativo de footprint

| Stack CLI | Total deps | Tamanho |
|---|---|---|
| argparse (stdlib) | 0 | 0 MB |
| Click puro | 1 | 5 MB |
| Typer mínimo | 2 (click + typing-extensions) | ~6 MB |
| Typer[all] | 7 | ~25 MB |
| FastAPI (referência) | ~10 | ~40 MB |

Typer é **footprint moderado** — bem menos que FastAPI, mais que argparse. Razoável para CLI profissional.

## Pré-requisitos de conhecimento

| Pré-req | Por que importa | Onde aprender |
|---|---|---|
| Python type hints | Typer é type-driven | [PEP 484](https://peps.python.org/pep-0484/) + [docs Python typing](https://docs.python.org/3/library/typing.html) |
| Decoradores Python | Click/Typer são decorator-heavy | [Real Python on decorators](https://realpython.com/primer-on-python-decorators/) |
| `argparse` ou Click prévio | Comparativo enriquece entendimento | [Click docs](https://click.palletsprojects.com/) |

## Conceitos fundamentais

### Bloco A — Click (base) (1.5h)

1. Decoradores `@click.command()` e `@click.group()`
2. `@click.option()` vs `@click.argument()` — diferença semântica
3. Type conversions automáticas
4. Click Context — passar estado entre comandos
5. Subcommands aninhados
6. Echo (`click.echo()`) vs print() — por que importa
7. Error handling (`UsageError`, `ClickException`)

### Bloco B — Typer (2h)

1. Type hints como fonte de verdade dos parâmetros
2. `Annotated[X, typer.Option(...)]` — metadados ricos
3. Subcommands via `app.add_typer(sub_app, name="...")`
4. Help auto-gerado de docstrings (Markdown via Rich)
5. Autocompletion: `--install-completion`, `--show-completion`
6. Test runner `CliRunner` — testar sem subprocess
7. Rich integration: tabelas, syntax, progress bars
8. Exception handling padrão Typer
9. `typer.prompt()`, `typer.confirm()` — interação humana
10. `typer.launch()` — abrir browser/editor

### Bloco C — Rich (1h — opcional mas recomendado)

1. `rich.console.Console` — substituto do print
2. `rich.table.Table` — tabelas formatadas
3. `rich.progress.Progress` — progress bars
4. `rich.syntax.Syntax` — syntax highlighting
5. Theming + estilos customizados

## Fontes primárias

### Documentação
- [Typer Documentation](https://typer.tiangolo.com/) — site oficial; tutoriais excelentes
- [Click Documentation](https://click.palletsprojects.com/) — base de Typer
- [Rich Documentation](https://rich.readthedocs.io/) — output bonito

### Código-fonte
- [Typer GitHub](https://github.com/fastapi/typer) — MIT
- [Click GitHub](https://github.com/pallets/click) — BSD-3
- [Rich GitHub](https://github.com/Textualize/rich) — MIT

### Apresentações e talks
- [Sebastián Ramírez — "Building Beautiful CLIs"](https://www.youtube.com/results?search_query=sebastian+ramirez+typer) — vários talks
- [Will McGugan — Rich talks](https://www.youtube.com/results?search_query=will+mcgugan+rich) — para Rich específico

## Fontes secundárias

### Comparativos
- [Real Python — "Comparing Python Command-Line Parsing Libraries"](https://realpython.com/comparing-python-command-line-parsing-libraries-argparse-docopt-click/)
- [Cyclopts vs Typer](https://github.com/BrianPugh/cyclopts) — alternativa emergente
- [Fire (Google)](https://github.com/google/python-fire) — abordagem mais minimalista

### Cookbooks
- [Awesome Click](https://github.com/click-contrib/awesome-click) — extensões e patterns
- [Building Production CLIs (Stack Overflow Blog)](https://stackoverflow.blog/) — patterns reais

## Hands-on exercises

### Exercício 1 — CLI Hello World (30 min)
```bash
uv init
uv add typer[all]
```
Criar comando `hello` que recebe `name: str` e imprime saudação. Rodar.

### Exercício 2 — Subcommands (1h)
Esqueleto da CLI `hbn`:
- `hbn baton status` (placeholder — print "ownership: opus")
- `hbn radar list --state in-radar` (placeholder — print 3 nomes hardcoded)
- `hbn radar list --state archived`

### Exercício 3 — Validation + Rich output (1h)
- Validar que `--state` é um dos enum permitidos
- Output em tabela Rich
- Erro elegante quando estado inválido

### Exercício 4 — Tests com CliRunner (45 min)
- Escrever 3 tests para os subcommands acima
- Verificar exit codes, stdout, stderr

### Exercício 5 — Autocompletion (30 min)
- `hbn --install-completion zsh`
- Testar autocompletion no terminal real
- Documentar setup necessário

### Exercício 6 — Reading state real (1h)
- Comando `hbn radar list` lê `usehbn/radar/REGISTRY.md` real
- Parse Markdown table → Python dict
- Exibe via Rich
- Bônus: filtro por categoria

## Perguntas para aprofundamento

1. Por que Typer escolheu empilhar sobre Click em vez de reimplementar?
2. Como `typer[all]` difere de `typer` puro? Vale a diferença?
3. Cold start de Typer (~80-150ms) é problema para CLI usada em loops? Quando?
4. `CliRunner` vs subprocess — quando usar cada um para testar?
5. Como Typer compara com Cyclopts em ergonomia e maturidade?
6. Quais limitações de type hints atrapalham (e.g., union types complexos)?
7. Como passar context/state global entre subcommands?
8. Como gerar manpage (man hbn) automaticamente?
9. Como distribuir CLI Typer como executável standalone (PyInstaller/Nuitka)?
10. Qual estratégia para versionar a CLI (`hbn --version`)?

## Conexão com os 10 princípios useHBN

| Princípio | Como Typer encarna |
|---|---|
| **P2 — Documentar antes de executar** | `--help` automático = doc intrínseca |
| **P3 — Testar antes de refatorar** | `CliRunner` torna testes de CLI triviais |
| **P5 — Humano no controle** | CLI = invocação consciente (não auto-run) |
| **P9 — Frameworks descartáveis** | Lock-in baixo (Click underneath, type hints standard) |

## Critérios de "estudei o suficiente"

- [ ] Explicar árvore completa de dependências (Click, Rich, etc.) em 5 min
- [ ] Discutir tradeoffs Typer vs Click puro vs argparse vs Cyclopts
- [ ] Construir CLI esqueleto da `hbn` com 3 subcomandos
- [ ] Escrever testes com `CliRunner`
- [ ] Decidir se vale fagocitar Typer ou usar Click puro

## Sequência sugerida (5 horas distribuídas)

1. **Hora 1** — Click docs (Bloco A) — fundamental para entender Typer
2. **Hora 2** — Typer docs (Bloco B) — primeiro contato + tutoriais
3. **Hora 3** — Notebook LM podcast (gerado pelo superprompt)
4. **Hora 4** — Exercícios 1-3
5. **Hora 5** — Exercícios 4-6 + perguntas

## Versão

- v1.0 — 2026-05-02 — plano inicial após preocupação Maurício com cadeia de dependências.
