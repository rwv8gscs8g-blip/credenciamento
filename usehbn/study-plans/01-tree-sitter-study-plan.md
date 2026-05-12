---
titulo: Plano de Estudo Profundo — Tree-sitter (parsing teoria + prática)
diataxis: tutorial
hbn-track: knowledge
hbn-status: active
audiencia: humano
data: 2026-05-02
tempo-estimado: 6-10 horas (incluindo Notebook LM)
licenca-target: usehbn (AGPLv3)
ficha-radar: ../radar/_per-technology/tree-sitter.md
---

# Plano de Estudo Profundo — Tree-sitter

## Por que estudar profundo

Maurício pediu explicitamente: "Tree sitter pareceu-me absolutamente fundamental, quero que fique no radar. Preciso aprender mais sobre LR parser e sobre GLR parser."

Tree-sitter usa **GLR (Generalized LR)** parsing, escolha não-óbvia que merece entendimento profundo. Este study plan cobre tanto a teoria de parsing quanto o uso prático para o `hbn-phago`.

## Visão geral em 3 níveis

### Nível 1 — uma frase
Tree-sitter é um parser generator que transforma gramáticas declarativas em parsers C ultrarrápidos, usado por editores como Neovim, Helix, Zed para syntax highlighting e por ferramentas como GitHub e Semgrep para análise de código.

### Nível 2 — um parágrafo
Lançado em 2018 por Max Brunsfeld no GitHub para resolver problemas do Atom editor (latência de syntax highlighting em arquivos grandes), Tree-sitter combina três decisões técnicas raras: (a) GLR parsing — lida com gramáticas ambíguas; (b) parsing incremental — só re-parsa o que mudou (microssegundos por edit); (c) error recovery agressivo — produz árvore mesmo com código sintaticamente quebrado. Adoção massiva em editores modernos e ferramentas de código pela combinação rara de velocidade + robustez + portabilidade (gramáticas comunitárias para 50+ linguagens).

### Nível 3 — visão arquitetural
A inovação central é integrar três avanços históricos da pesquisa de parsing — GLR (Tomita 1985), incremental parsing (Wagner 1998), error-correcting parsers (Burke-Fisher 1987) — em uma engine pronta para produção com gramáticas declarativas em JavaScript. O resultado é uma camada de **observabilidade estrutural de código** que escala de editor de texto a infraestrutura de análise estática de código em larga escala.

## Pré-requisitos de conhecimento

| Pré-req | Por que importa | Onde aprender se faltando |
|---|---|---|
| Conceito básico de gramáticas formais | Entender o que GLR resolve | "Crafting Interpreters" cap. 1-3 (gratuito online) |
| Diferença AST vs CST | Tree-sitter produz CST (concrete syntax tree) | Mesmo livro |
| Python intermediário | Bindings que vamos usar | já tem |
| Familiaridade com expressões regulares | Para comparar com queries S-expression | já tem (Importador V3 usa) |

Tempo de leveling-up dos pré-requisitos: **2-3 horas** se faltando algum.

## Conceitos fundamentais a dominar

### Bloco A — Teoria de parsing (3-4h de leitura/escuta)

1. **Hierarquia de Chomsky** (Type 0-3 grammars; regular vs context-free vs context-sensitive)
2. **LL parsing** (recursive descent; LL(1), LL(k), LL(*))
3. **LR parsing**:
   - LR(0) — base
   - SLR(1) — Simple LR
   - LALR(1) — Look-Ahead LR (yacc/bison usam isto)
   - LR(1) — canonical LR (potente mas tabelas enormes)
4. **GLR parsing** (Generalized LR — Tomita 1985):
   - Por que GLR? Lida com gramáticas naturalmente ambíguas (C++ é exemplo clássico)
   - Como funciona: stack de parses paralelos; merges quando convergem
   - Custo: pior caso O(n³); típico O(n)
5. **Earley parsing** (alternativa GLR; usado por Marpa, NLTK):
   - Gramáticas arbitrárias livres de contexto
   - Mais lento que GLR em casos típicos; mais flexível em casos extremos
6. **PEG parsing** (Parsing Expression Grammars; usado por pyparsing, parsec):
   - Determinístico por design (greedy)
   - Não detecta ambiguidade (escolhe a primeira alternativa)
7. **ALL(\*)** parsing (ANTLR 4):
   - Combina LL com lookahead arbitrário e adaptativo
   - Tabelas geradas dinamicamente em runtime
8. **Pratt parsing** (top-down operator precedence):
   - Excelente para expressões com operadores
   - Usado por linguagens como Pratt, parts of TypeScript

### Bloco B — Tree-sitter especificamente (2-3h)

1. **Arquitetura interna**:
   - `grammar.js` (declarativa em JavaScript)
   - `tree-sitter generate` produz parser C
   - Runtime C linkado via FFI (Python, Rust, JS bindings)
2. **Modelo de árvore**:
   - CST (Concrete Syntax Tree) — preserva tokens, comentários, whitespace
   - Nodes têm: type, position (start_byte/end_byte), parent, children
   - `MISSING` e `ERROR` nodes para error recovery
3. **Query language (S-expressions)**:
   - Sintaxe: `(node_type field_name: (child_type) @capture-name)`
   - Predicates: `#eq?`, `#match?`, `#any-of?`
   - Useful para extração de padrões sem percorrer árvore manualmente
4. **Incremental parsing**:
   - `parse(old_tree, new_source)` → árvore atualizada
   - O(modificações), não O(arquivo)
5. **Error recovery**:
   - Cria nodes parciais quando sintaxe falha
   - Permite continuar parsing depois de erro

### Bloco C — Hands-on com Python (2-3h)

1. Instalar bindings: `uv add tree-sitter tree-sitter-python` (ou `tree-sitter-vba`)
2. Parse arquivo simples; navegar árvore
3. Escrever query S-expression para extrair funções
4. Aplicar em `Const_Colunas.bas` real do Credenciamento
5. Comparar saída com regex existente

## Fontes primárias (oficiais)

### Documentação
- [Tree-sitter Documentation](https://tree-sitter.github.io/tree-sitter/) — site oficial
- [Tree-sitter Specification](https://tree-sitter.github.io/tree-sitter/creating-parsers) — escrever gramáticas
- [Tree-sitter Query Language](https://tree-sitter.github.io/tree-sitter/using-parsers/queries/index.html) — S-expressions
- [Python bindings docs](https://github.com/tree-sitter/py-tree-sitter) — uso Python específico

### Código-fonte
- [Tree-sitter (runtime)](https://github.com/tree-sitter/tree-sitter) — MIT, C
- [tree-sitter-vba (Eirik Predbjørn-Riise)](https://github.com/eirikpre/tree-sitter-vba) — gramática VBA
- [tree-sitter-cobol](https://github.com/yutaro-sakamoto/tree-sitter-cobol) — gramática COBOL (verificar maturidade)
- [tree-sitter-python](https://github.com/tree-sitter/tree-sitter-python) — para experimentos iniciais (bem mantida)

### Papers
- **Brunsfeld, Max (2018) — "Tree-sitter — a New Parsing System for Programming Tools"** — Strange Loop talk + paper companion ([talk](https://www.thestrangeloop.com/2018/tree-sitter---a-new-parsing-system-for-programming-tools.html))
- **Tomita, Masaru (1985) — "Efficient Parsing for Natural Language"** — paper original GLR (livro caro mas há resumos)
- **Wagner & Graham (1998) — "Efficient and Flexible Incremental Parsing"** — base do incremental parsing do Tree-sitter

## Fontes secundárias (livros e tutoriais)

### Livros (escolher 1 dos 3)
- **"Crafting Interpreters" — Robert Nystrom** ([gratuito online](https://craftinginterpreters.com/)) — melhor introdução prática a parsing; cobre LL, Pratt; **comece aqui** se nunca estudou parsing antes
- **"Engineering a Compiler" — Cooper & Torczon** — cobertura acadêmica completa de LR/LALR; mais denso
- **"Compilers: Principles, Techniques, and Tools" (Dragon Book) — Aho/Sethi/Lam/Ullman** — referência canônica; cap. 4 sobre parsing é denso mas autoritativo

### Vídeos
- [Tree-sitter Strange Loop talk (Brunsfeld 2018)](https://www.youtube.com/watch?v=Jes3bD6P0To) — 30 min; **assistir primeiro**
- [GLR Parsing explained (Computerphile)](https://www.youtube.com/watch?v=1IvL_bSSJlU) — visão geral
- [LALR vs LR vs LL parsers (lectures)](https://www.youtube.com/results?search_query=LALR+parser+explained) — vários canais; escolher um
- [Tree-sitter playground demo](https://tree-sitter.github.io/tree-sitter/7-playground.html) — hands-on direto no browser

### Blog posts
- [GitHub Engineering — "How Tree-sitter parses code"](https://github.blog/engineering/code-search/) — context real de adoção
- [Neovim Tree-sitter integration](https://github.com/nvim-treesitter/nvim-treesitter/wiki) — caso de uso massivo
- [Semgrep usa Tree-sitter](https://semgrep.dev/blog/2020/why-tree-sitter-and-not-language-server-protocol/) — comparativo com LSP

## Hands-on exercises (incrementais)

### Exercício 1 — Setup (30 min)
```bash
mkdir tree-sitter-poc && cd tree-sitter-poc
uv init
uv add tree-sitter tree-sitter-python
```
Parsear `print("hello")` e imprimir AST.

### Exercício 2 — Navegar árvore (45 min)
Para um arquivo Python pequeno, percorrer árvore e listar todos os `function_definition` nodes com seus nomes.

### Exercício 3 — Queries S-expression (1h)
Reescrever exercício 2 usando query: `(function_definition name: (identifier) @func-name)`. Comparar concisão e legibilidade.

### Exercício 4 — VBA real (1.5h)
- Instalar `tree-sitter-vba` (clonar repo, compilar)
- Parsear `Const_Colunas.bas` do Credenciamento
- Extrair lista de constantes via query
- Comparar com saída do regex em `Importador_V3.bas`

### Exercício 5 — Error recovery (45 min)
- Criar VBA com erro sintático intencional
- Verificar como parser lida (`MISSING` ou `ERROR` nodes onde?)
- Discutir: serve para análise de código legado mal-formado?

### Exercício 6 — Performance (45 min)
- Parsear arquivos VBA grandes (>1MB se houver, ou concatenar vários)
- Medir tempo cold + tempo incremental
- Comparar com parsing equivalente em Python puro (regex + estado)

## Perguntas para aprofundamento

1. Por que Tree-sitter escolheu GLR e não Earley?
2. Como GLR lida com a ambiguidade `if-else` em C?
3. Qual o overhead típico de error recovery (vs parser sem recovery)?
4. Por que gramáticas Tree-sitter são em JavaScript (e não DSL própria)?
5. Como a query language (S-expressions) compara com XPath para XML?
6. Em que casos LSP (Language Server Protocol) é melhor que Tree-sitter?
7. Como Tree-sitter compara com ANTLR para grandes projetos?
8. O que faz parsing incremental ser microssegundo (não milissegundo)?
9. Por que gramáticas comunitárias variam tanto em qualidade?
10. Como lidar com pré-processadores (C #include, Pascal {$IFDEF})?
11. Tree-sitter resolve ambiguidade ou apenas representa?
12. Como queries S-expression escalam para milhares de matches?

## Conexão com os 10 princípios useHBN

| Princípio | Como Tree-sitter encarna |
|---|---|
| **P1 — Preservar antes de transformar** | Parser é não-destrutivo; produz árvore lateral |
| **P2 — Documentar antes de executar** | Query gera doc estrutural sem rodar código |
| **P7 — Identidade preservada** | VBA continua VBA; árvore é representação, não substituição |
| **P8 — Protocolo > ferramenta** | Gramáticas em JS são spec textual; portáveis |
| **P9 — Frameworks descartáveis** | Saída é AST padrão; trocar por LSP-based é factível |

## Critérios de "estudei o suficiente"

Quando você consegue:

- [ ] Explicar diferença entre LL, LR, LALR, GLR em 5 minutos
- [ ] Justificar por que Tree-sitter usa GLR e não Earley
- [ ] Escrever query S-expression para extrair padrão simples (ex.: todas as funções)
- [ ] Parsear `Const_Colunas.bas` e extrair constantes
- [ ] Explicar tradeoffs entre parser-based (Tree-sitter) e regex-based (Importador V3)
- [ ] Decidir se vale fagocitar Tree-sitter no `hbn-phago` (gates G3 do roadmap)

## Sequência sugerida de estudo (8 horas distribuídas)

1. **Hora 1** — Crafting Interpreters cap 4-6 (parsing intro, escolher Pratt ou recursive descent)
2. **Hora 2** — Strange Loop talk Brunsfeld + leitura do site oficial Tree-sitter
3. **Hora 3** — Notebook LM podcast (gerado pelo superprompt)
4. **Hora 4-5** — Hands-on exercícios 1-3
5. **Hora 6-7** — Hands-on exercício 4 (VBA real)
6. **Hora 8** — Exercícios 5-6 + perguntas para aprofundamento

## Versão

- v1.0 — 2026-05-02 — plano inicial após pedido de Maurício para aprofundar LR/GLR parsing.
