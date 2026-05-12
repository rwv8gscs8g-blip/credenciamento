---
titulo: Superprompt Notebook LM — Typer (incluindo cadeia de dependências)
diataxis: how-to
hbn-track: knowledge
audiencia: humano
data: 2026-05-02
licenca-target: usehbn (AGPLv3)
---

# Superprompt Notebook LM — Typer

## Como usar

1. Acesse https://notebooklm.google.com/
2. Crie novo notebook: "useHBN — Typer + Click + dependências CLI Python"
3. Faça upload das fontes da seção "FONTES PARA UPLOAD"
4. Cole "CONTEXTO PARA COLAR" no chat
5. No painel Studio, gere Audio Overview com "PERGUNTAS PARA GERAÇÃO" e "PERSONA"
6. Gere também Briefing, Mind map, FAQ

---

## CONTEXTO PARA COLAR

```text
Estudo profundo de Typer no contexto do projeto useHBN — protocolo aberto para evolução segura de tecnologias legadas. Vou implementar uma CLI chamada `hbn` em Python (Wave 11+) com comandos como `hbn baton status`, `hbn radar list`, `hbn capsule validate`, `hbn weekly-review`. Typer é candidata como framework principal.

PREOCUPAÇÃO ESPECÍFICA QUE QUERO ABORDAR EM PROFUNDIDADE:

A árvore de dependências de Typer me preocupa. Typer depende de Click, e Click é maduro mas é mais uma camada. Se eu instalar `typer[all]`, recebo Rich (com markdown-it-py, mdurl, pygments) e shellingham. Total: ~7 packages transitivos, ~25 MB instalado. Quero entender:

(a) Cada uma dessas dependências individualmente — quem mantém, qual licença, qual maturidade, qual risco de abandono?
(b) Tradeoff Typer vs Click puro — vale a abstração ou é melhor pular Typer?
(c) Comparativo com alternativas: argparse (stdlib, zero deps), Cyclopts (mais novo, mais leve), Fire (Google, mais minimalista).
(d) typer-slim — variante sem Rich, cadeia mais curta. Quando preferir?

CONTEXTO DO useHBN:
- Protocolo aberto (tese: cápsulas de conhecimento + 10 princípios constitucionais)
- Princípio P9: "Frameworks são descartáveis; princípios são permanentes" — quero saber qual o custo real de trocar Typer depois
- Princípio P8: "Protocolo > ferramenta" — comandos da CLI devem viver em funções puras testáveis, não amarradas a decoradores

Os 10 princípios:
1. Preservar antes de transformar
2. Documentar antes de executar
3. Testar antes de refatorar
4. Explicar antes de automatizar
5. Humano no controle por padrão
6. Toda evolução deve ser reversível
7. Nenhuma tecnologia fagocitada perde sua identidade
8. O protocolo importa mais que a ferramenta
9. Frameworks são descartáveis; princípios são permanentes
10. Segurança e não-regressão > velocidade

A CLI `hbn` será o canal principal pelo qual usuários (humanos e IAs) interagem com o protocolo HBN. Volume baixo (uso ocasional), mas frequente. Cold start de 80-150ms é aceitável; > 300ms começa a incomodar.
```

---

## FONTES PARA UPLOAD

### Fontes obrigatórias (5)

1. **[Typer Documentation](https://typer.tiangolo.com/)** — site oficial completo
2. **[Click Documentation](https://click.palletsprojects.com/)** — base sob Typer
3. **[Rich Documentation](https://rich.readthedocs.io/)** — output formatado
4. **[Sebastián Ramírez sobre Typer (vídeo/post — escolher um da YouTube/blog)](https://www.youtube.com/results?search_query=sebastian+ramirez+typer+talk)** — racional do criador
5. **[Real Python — Comparing Python Command-Line Parsing Libraries](https://realpython.com/comparing-python-command-line-parsing-libraries-argparse-docopt-click/)** — comparativo histórico

### Fontes para análise de cadeia de dependências (4)

6. **[Click on PyPI](https://pypi.org/project/click/)** — verificar dependências, mantenedor, downloads
7. **[Rich on PyPI](https://pypi.org/project/rich/)** — idem
8. **[shellingham on PyPI](https://pypi.org/project/shellingham/)** — idem
9. **[markdown-it-py + mdurl + pygments — verificar PyPI de cada um]** — dependências transitivas de Rich

### Fontes para alternativas (3)

10. **[Cyclopts — alternativa emergente](https://github.com/BrianPugh/cyclopts)** — repo + docs
11. **[Fire (Google)](https://github.com/google/python-fire)** — abordagem mais minimalista
12. **[Python argparse documentation](https://docs.python.org/3/library/argparse.html)** — stdlib, zero deps

---

## PERGUNTAS PARA GERAÇÃO

```text
Por favor, criem um Deep Dive de 30-40 minutos sobre Typer e seu ecossistema. Estruturem em quatro blocos:

BLOCO 1 — Typer e Click (10 min)
1. Por que Typer foi criado se Click já existia?
2. O que Typer adiciona que Click puro não tem?
3. Tradeoff: usar Typer (com Click underneath) ou usar Click direto?
4. Cold start de Typer — quanto tempo? É problema?

BLOCO 2 — Análise de cadeia de dependências (15 min) — FOCO ESPECIAL DESTE PODCAST
5. Qual a árvore COMPLETA de dependências quando instalo `typer[all]`?
6. Para cada dependência (Click, typing-extensions, Rich, shellingham, markdown-it-py, mdurl, pygments): quem mantém, qual a licença, qual a maturidade, qual o risco?
7. typer-slim vs typer[all] — quando preferir cada?
8. Total instalado em MB; razoável vs argparse/fire?
9. Como gerenciar atualizações de transitivas em projetos longevos?

BLOCO 3 — Comparativo com alternativas (8 min)
10. argparse (stdlib): zero deps mas mais boilerplate. Quando vale?
11. Cyclopts: mais novo, ergonomia diferente. Quais decisões de design?
12. Fire (Google): converter qualquer função Python em CLI automaticamente. Quando preferir?

BLOCO 4 — Decisão de adoção em projeto sério (7 min)
13. Como evitar lock-in: estratégia de separar lógica de comandos para fácil migração?
14. CliRunner para testes — qual cobertura realista alcançar?
15. Quando NÃO usar Typer (e usar Click puro)?

DESEJO ESPECIAL: dediquem MUITO tempo ao bloco 2 (análise de dependências), porque é onde minha preocupação está. Sem rasgar Typer — só com clareza.
```

---

## PERSONA DE AUDIÊNCIA

```text
Audiência: arquiteto cuidadoso construindo protocolo de longo prazo (10+ anos pretendidos). Tem trauma de cadeia de dependências que se desfaz após 2-3 anos. Privilegia decisões que minimizam manutenção futura. Conhece Click superficialmente e Python bem. Quer respeitar o princípio "frameworks são descartáveis" — então cada dependência precisa justificar seu custo. Tom: pragmático, não evangelista; explicar tradeoffs sem vender solução.
```

---

## OUTPUTS SOLICITADOS

- [ ] Audio Overview (~30-40 min, com foco no Bloco 2)
- [ ] Briefing document com tabela de dependências
- [ ] Mind map da árvore de dependências
- [ ] FAQ específico sobre alternativas e migração

## Versão

- v1.0 — 2026-05-02 — superprompt inicial focando preocupação Maurício com dependências.
