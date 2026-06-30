---
titulo: Superprompt Notebook LM — Tree-sitter (parsing teoria + prática)
diataxis: how-to
hbn-track: knowledge
audiencia: humano
data: 2026-05-02
licenca-target: usehbn (AGPLv3)
---

# Superprompt Notebook LM — Tree-sitter

## Como usar

1. Acesse https://notebooklm.google.com/
2. Crie novo notebook: "useHBN — Tree-sitter Deep Dive"
3. Faça upload das fontes da seção "FONTES PARA UPLOAD" (baixe os PDFs/HTMLs primeiro se preferir)
4. No chat do notebook, cole "CONTEXTO PARA COLAR" como primeira mensagem
5. No painel Studio (direita), clique "Audio Overview" → "Customize" → cole "PERGUNTAS PARA GERAÇÃO" + "PERSONA DE AUDIÊNCIA" → Generate
6. Após Audio Overview pronto, gere também: Briefing document, Mind map, FAQ
7. Escute o Audio Overview (~25-40 min) durante caminhada/exercício

---

## CONTEXTO PARA COLAR (cole isso no chat do Notebook LM)

```text
Estou conduzindo estudo profundo da tecnologia Tree-sitter no contexto do projeto useHBN — um protocolo aberto para "fagocitose tecnológica segura": absorver conhecimento de tecnologias legadas (VBA, COBOL, Pascal, Delphi, Clipper) sem apagar sua identidade original, transformando-as em bibliotecas vivas de conhecimento técnico.

O useHBN tem 10 princípios constitucionais:
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

O caso de uso concreto: o sistema de Credenciamento (50+ módulos VBA em produção) hoje usa regex frágil para parsear código VBA durante refatorações. Tree-sitter é candidata a substituir esse regex por parsing real com gramática formal — extrair regras de negócio sem executar código (P2 + P10 simultâneos), preservar identidade VBA original (P1 + P7), permitir trocar parser depois sem reescrever queries (P9).

Quero entender Tree-sitter em três dimensões:

(a) **Teoria de parsing** — especificamente: por que Tree-sitter escolheu GLR (Generalized LR) em vez de LR(1), LALR(1), Earley ou PEG? Quais as implicações dessa escolha para gramáticas ambíguas (C++, COBOL)? Quando GLR pode ser pior que alternativas?

(b) **Engenharia interna** — como funciona o parsing incremental que torna Tree-sitter competitivo em editores (microssegundos por edição)? Como o error recovery agressivo é implementado? Por que gramáticas são declaradas em JavaScript?

(c) **Aplicação ao useHBN** — como Tree-sitter encarna os 10 princípios? Quais limitações a comunidade reporta para análise de código legado? Como gramáticas de qualidade variável (tree-sitter-vba mantida, tree-sitter-cobol experimental) afetam decisão de adoção?
```

---

## FONTES PARA UPLOAD

### Fontes obrigatórias (5)

1. **[Tree-sitter Documentation — Introduction](https://tree-sitter.github.io/tree-sitter/)** — site oficial, página principal
2. **[Tree-sitter Documentation — Creating Parsers](https://tree-sitter.github.io/tree-sitter/creating-parsers)** — escrever gramáticas
3. **[Tree-sitter Documentation — Using Queries](https://tree-sitter.github.io/tree-sitter/using-parsers/queries/index.html)** — query language S-expression
4. **[Strange Loop 2018 talk transcript by Max Brunsfeld](https://www.thestrangeloop.com/2018/tree-sitter---a-new-parsing-system-for-programming-tools.html)** — racional original do projeto
5. **[Crafting Interpreters — Chapter 6: Parsing Expressions](https://craftinginterpreters.com/parsing-expressions.html)** — fundamentos de parsing acessíveis (Robert Nystrom, gratuito online)

### Fontes complementares (escolher 3-5)

6. **[GitHub Engineering blog — How Tree-sitter parses code](https://github.blog/engineering/code-search/)** — adoção em escala real
7. **[Wikipedia — GLR parser](https://en.wikipedia.org/wiki/GLR_parser)** — visão acadêmica concisa
8. **[Wikipedia — LR parser](https://en.wikipedia.org/wiki/LR_parser)** — fundação para entender GLR
9. **[Semgrep — Why Tree-sitter and not LSP](https://semgrep.dev/blog/2020/why-tree-sitter-and-not-language-server-protocol/)** — comparativo arquitetural
10. **[Neovim Tree-sitter wiki](https://github.com/nvim-treesitter/nvim-treesitter/wiki)** — caso de uso massivo
11. **[Tree-sitter Python bindings README](https://github.com/tree-sitter/py-tree-sitter)** — como usar em Python
12. **[Eirikpre — tree-sitter-vba README](https://github.com/eirikpre/tree-sitter-vba)** — gramática VBA específica

### Bônus — para discussão histórica

13. **[Wagner & Graham 1998 — Efficient and Flexible Incremental Parsing (paper)](https://www.cs.berkeley.edu/~kubitron/courses/cs262a-F17/Papers/wagner-incremental-parsing.pdf)** — base do incremental parsing

---

## PERGUNTAS PARA GERAÇÃO (cole no Customize do Audio Overview)

```text
Por favor, criem um Deep Dive de 30-40 minutos cobrindo Tree-sitter de forma técnica mas acessível. Estruturem em três blocos:

BLOCO 1 — Fundamentos de parsing (10 min)
1. Comparem LL, LR, LALR, GLR, Earley e PEG — quando cada um brilha?
2. Por que GLR consegue lidar com gramáticas ambíguas?
3. Qual o custo computacional típico de GLR vs LR(1)?
4. Quando GLR é a escolha errada?

BLOCO 2 — Tree-sitter como engenharia (10-15 min)
5. Por que Tree-sitter declara gramáticas em JavaScript (não DSL própria)?
6. Como funciona o parsing incremental? Por que é microssegundo?
7. Como o error recovery agressivo é implementado?
8. Como o query language S-expression difere de XPath para XML?
9. Quais gramáticas comunitárias são consideradas maduras vs experimentais?

BLOCO 3 — Adoção e tradeoffs (10-15 min)
10. Por que GitHub adotou Tree-sitter para syntax highlighting?
11. Por que Semgrep escolheu Tree-sitter sobre LSP?
12. Quais limitações a comunidade reporta?
13. Como Tree-sitter compara com ANTLR para projetos sérios?
14. Para análise de código legado (VBA, COBOL), quais cuidados específicos?
15. Quais sinais indicam que vale fagocitar Tree-sitter em uma stack?

DESEJO ESPECIAL: Dediquem 2-3 minutos comparando GLR com Earley parsing especificamente — quando preferir cada um?
```

---

## PERSONA DE AUDIÊNCIA (cole no mesmo Customize)

```text
Audiência: arquiteto de software técnico construindo protocolo de evolução de tecnologias legadas. Já programa em Python, conhece regex bem, entendeu autómatos finitos no curso há anos mas nunca escreveu parser. Quer decisão arquitetural, não tutorial step-by-step. Tom: técnico mas conversacional, com analogias quando o conceito for novo. Não evite jargão; explique-o uma vez e use depois. Privilegie tradeoffs e implicações de longo prazo sobre features brilhantes.
```

---

## OUTPUTS SOLICITADOS

Após Audio Overview, gere também:
- [ ] **Briefing document**: resumo executivo + 3 seções (O Quê / Por Quê / Como)
- [ ] **Mind map**: estrutura visual dos conceitos (parsing → variantes → Tree-sitter → aplicações)
- [ ] **FAQ**: 15-20 perguntas técnicas cobrindo desde fundamentos até decisões de adoção

## Versão

- v1.0 — 2026-05-02 — superprompt inicial.
