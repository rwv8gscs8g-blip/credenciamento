---
titulo: Typer
slug: typer
categoria: outros
estado: archived
data-entrada: 2026-05-02
ultima-revisao: 2026-05-06 (arquivada por Maurício após análise — filosofia minimalista de dependências)
proxima-revisao: 2027-05-06
fonte-radar: "local-ai/Time_AI/2026-05-02-V203-fechamento/103*.md"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: MIT
motivo-arquivamento: purista-anti-dependencias-pro-compilacao
pode-reentrar-se: filosofia mudar OU surgir variante zero-deps compatível OU IAs pararem de mediar interface
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
decisao-final: ARQUIVADA — sem promoção a candidate
---

# Typer

## Por que está no radar

Typer é o backbone natural da CLI `hbn` planejada para Wave 11+ (segunda-feira 2026-05-04). Comandos como `hbn baton status`, `hbn drift check`, `hbn radar list --state in-radar`, `hbn weekly-review` são representáveis em Typer com pouca cerimônia. A análise dos princípios sustenta promoção a `candidate`.

Fonte inicial: propostas Codex 103/103b da cadeia 2026-05-02.

## Resumo da tecnologia

Typer é framework Python para construir CLIs usando type hints, criado por Sebastián Ramírez (também criador do FastAPI). Construído sobre Click (a biblioteca CLI Python clássica), Typer adiciona type-driven development: tipos das funções viram argumentos validados automaticamente.

Núcleo técnico:
- Type hints `int`, `str`, `bool`, `Path`, `Optional[X]` definem argumentos e opções da CLI
- Subcommands aninhados via `app.add_typer(sub_app, name="radar")`
- Help auto-gerado de docstrings (suporta Markdown via Rich)
- Autocompletion para shells (bash, zsh, fish, PowerShell) — `--install-completion`
- Rich integrado para output formatado (tabelas, progress bars, syntax highlighting)
- Test runner próprio (`CliRunner`) — testar comando sem subprocess
- Suporta `Annotated[X, typer.Option(...)]` para metadados ricos sem perder type hint

Diferencial vs alternativas:
- vs **argparse**: dispensa boilerplate; type hints viram fonte de verdade
- vs **Click puro**: Typer é Click + type hints + validação Pydantic-style
- vs **fire** (Google): mais explícito, melhor tooling, validação real
- vs **cyclopts**: mais maduro, ecossistema maior

Licença: MIT. Mantenedor: Sebastián Ramírez (tiangolo) + comunidade. Maturidade: estável v0.12+ em maio 2026; breaking changes raros.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | CLI é interface de leitura/comando; lê estado do `usehbn` sem alterar arquivos a não ser quando comando explícito for invocado. |
| 2 | Documentar antes de executar | sim | `--help` automático em cada comando + docstrings = documentação intrínseca. Match P2 quase perfeito. |
| 3 | Testar antes de refatorar | sim | `CliRunner` permite testar comandos sem subprocess; integração natural com pytest. Cobertura facilitada. |
| 4 | Explicar antes de automatizar | sim | Convenção Typer: flag `--dry-run` é trivial de adicionar; output Rich torna efeitos planejados visíveis antes de aplicar. |
| 5 | Humano no controle por padrão | sim | CLI é interface humana por excelência. Cada comando é invocação consciente. Match P5 fundamental. |
| 6 | Toda evolução deve ser reversível | parcial | Framework em si é reversível, mas comandos podem ter side-effects irreversíveis. Responsabilidade do desenho dos comandos (escrita ou leitura), não do framework. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | CLI invoca scripts/APIs sem alterar o que invoca. Comandos são thin wrappers. |
| 8 | O protocolo importa mais que a ferramenta | parcial | Lógica de comandos pode viver fora dos decorators Typer (em funções puras testáveis); decoradores `@app.command()` são específicos. Migração para argparse + lógica preservada é factível em horas. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | Lock-in baixo. Click sob Typer é Python clássico; substituir Typer por argparse + decoradores próprios é factível em 1-2 dias. |
| 10 | Segurança e não-regressão > velocidade | sim | Type hints capturam erros em parse-time; testes via CliRunner são rápidos; sem surpresas em runtime que não tenham sido capturadas em CI. |

**Convergência média: 8/10 sim, 2/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: BAIXO — Sebastián Ramírez é mantenedor consistente (FastAPI, SQLModel, Typer); sponsored projects via GitHub Sponsors com receita estável
- **Velocidade de evolução**: estável; v0.12+ em 2026, releases trimestrais, breaking changes raros (semver respeitado)
- **Cold start**: ~80-150ms (Python overhead). Aceitável para CLI de uso ocasional. **Problemático se `hbn-server` for invocado em loops apertados** — nesse caso usar daemon mode ou MCP server.
- **Lock-in técnico**: BAIXO (Click underneath, Python type hints standard, pode-se separar lógica em funções puras)
- **Compatibilidade AGPLv3**: MIT é compatível (sublicenciável em AGPLv3)
- **Adoção alternativa emergente**: `cyclopts` é mais novo e tem features interessantes (positional vars, melhor error messages); revisitar em 12 meses

## O que precisa para avançar de estado

Para `candidate` (programado 2026-05-04):
- POC: comando `hbn baton status` lendo `.hbn/relay/INDEX.md` e exibindo dono atual + esteira ativa por frente (1h de implementação)
- Confirmar autocompletion funciona em zsh do macOS Sequoia do Maurício
- Avaliar instalação combinada uv + Typer (deve ser `uv add typer[all]`)
- Definir convenção de subcommands: `hbn baton`, `hbn radar`, `hbn drift`, `hbn weekly-review`

Para `phagocytosed`:
- CLI `hbn` no `usehbn-phago/pyproject.toml` declarando entry-point
- 5+ comandos implementados e testados
- Distribuído via `uv tool install hbn` (futuro)

## Histórico de transições

| Data | De | Para | Motivo | Decisor |
|---|---|---|---|---|
| 2026-05-02 | n/a | under-analysis | Entrada inicial no bootstrap E1 do Radar | Codex CLI, sob spec Opus |
| 2026-05-02 | under-analysis | under-analysis | Reescrita E1.1 (Codex — análise template) | Codex CLI |
| 2026-05-02 | under-analysis | under-analysis | Análise profunda Opus — recomenda promoção a candidate em 2026-05-04 | Claude Opus 4.7 (Frente 2) |
| **2026-05-06** | **under-analysis** | **archived** | **Arquivada por Maurício após análise: filosofia minimalista de dependências; risco de cadeia transitiva (Click + Rich + 5 outras = ~25 MB); preconceito de devs puristas; queda de microssegundos em sistemas concretos; saída ao usuário será mediada por IA (não precisa de Rich/cores no terminal); foco em código compilado e melhorias incrementais sucessivas** | **Maurício (palavra final)** |

## Nota de arquivamento — racional Maurício 2026-05-06

Após estudo profundo via NotebookLM, Maurício decidiu arquivar Typer com a seguinte argumentação articulada (citação operacional):

> "O risco de dependências é grande e a queda de performance pode ser concreta em sistemas concretos. Desenvolvedores puristas desistiriam de usar o useHBN pelo simples preconceito de estar acumulando dependências. A ideia é retirar dependências e compilar. Enquanto a primeira (Tree-sitter) trabalhar com Rust e código otimizado, isso (Typer) pode virar uma caixa de pandora. As próprias IAs vão entregar tecnologia e visualização rica sem os custos de colocar isso no projeto. As IAs vão ler código puro, não precisam de coisas ricas. Logo, limpar o ambiente e focar em melhorias incrementais sucessivas, mesmo nos microssegundos, será fundamental para a sustentação da tecnologia. Precisamos de uma base sólida, robusta, auditável, sem perdas estéticas que farão a saída ao usuário final ser mediada pela própria IA como interface, não precisando isso no terminal."

Este racional cunha o **Princípio do Minimalismo de Cadeia** (ver `usehbn/methodology/MINIMALISM-PRINCIPLE.md`), que filtra adoções futuras.

**Implicação técnica para CLI hbn**: usar `argparse` (stdlib, zero deps) ou Click puro (1 dep, BSD-3, zero transitivas) em vez de Typer. Decisão final fica para o prompt unificado ao Codex após análise das 5 tecnologias.

**Reentrada permitida** se: (a) filosofia evoluir; (b) surgir variante zero-deps de Typer compatível com type hints; (c) o paradigma de IA-como-interface for invalidado e terminal voltar a precisar de output rico.

## Referências

- [Documentação oficial](https://typer.tiangolo.com/) — tutorial, exemplos, conceitos
- [Repositório GitHub](https://github.com/fastapi/typer) — MIT License
- [Click (base de Typer)](https://click.palletsprojects.com/) — entender fundamentos
- [Sebastián Ramírez (tiangolo)](https://github.com/tiangolo) — perfil do mantenedor
- [Comparativo CLI Python (2024-2026)](https://realpython.com/comparing-python-command-line-parsing-libraries-argparse-docopt-click/) — argparse vs click vs typer
- [Cyclopts (alternativa emergente)](https://github.com/BrianPugh/cyclopts) — para revisão futura
- Fonte interna: `local-ai/Time_AI/2026-05-02-V203-fechamento/103b-Codex-Protocolo-usehbn-Propostas.md`
