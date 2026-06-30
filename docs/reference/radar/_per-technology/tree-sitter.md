---
titulo: Tree-sitter
slug: tree-sitter
categoria: conhecimento-estruturado
estado: in-radar
data-entrada: 2026-05-02
ultima-revisao: 2026-05-06 (estudo profundo concluído por Maurício via Notebook LM)
proxima-revisao: aguardando-conclusao-analise-5-tecnologias
fonte-radar: "auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: MIT
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
status-estudo-mauricio: CONCLUIDO-2026-05-06 (aprovação favorável; quer fagocitar como tecnologia fundadora; ver auditoria/00_status/41)
recomendacao-opus: promover a convergence-mapped após POC parsing VBA real
decisao-promocao-pendente: aguardando análise Maurício das outras 4 (uv, OTel, Consent capsules) antes de prompt unificado ao Codex
papeis-pretendidos: (a) ferramenta técnica - parsing real; (b) linguagem comum - ASTs como notação; (c) justificativa de adoção - argumento "porquê useHBN"
---

# Tree-sitter

## Por que está no radar

Tree-sitter é o caminho natural para o `hbn-phago` parsear código legado (VBA, COBOL, Pascal, Delphi) **sem executá-lo** — gerando árvores sintáticas analisáveis. A alternativa atual no Credenciamento é regex frágil (vide `Importador_V3.bas`). Para escalar a fagocitose para outras linguagens com qualidade industrial, Tree-sitter é a aposta certa.

Fonte inicial: tese 38 §8 lista AST/Tree-sitter como infraestrutura de "conhecimento estruturado". O interesse não é abstrato — há gramáticas Tree-sitter já existentes para várias linguagens-alvo do useHBN.

## Resumo da tecnologia

Tree-sitter é parser generator + biblioteca de runtime para gerar árvores sintáticas concretas (CSTs/ASTs) de código-fonte. Originalmente desenvolvido por Max Brunsfeld no GitHub para o Atom editor (2018); hoje mantido pela Tree-sitter Foundation (2023+) e comunidade. Adoção massiva: Atom, Neovim, Helix, Zed, Lapce, GitHub.com (syntax highlighting), Semgrep, scope-resolution, GitHub Copilot.

Núcleo técnico:
- Gramáticas declaradas em JavaScript (`grammar.js`) e compiladas para C
- Parser gerado é incremental — só re-parsa o que mudou (latência microssegundos em arquivos médios)
- Error recovery agressivo: produz árvore mesmo com código sintaticamente quebrado
- Query language própria (S-expressions) para extrair padrões: `(function_declaration name: (identifier) @name)`
- Bindings em Python (`tree-sitter` PyPI), Rust, JS/TS, Go, Ruby, Java

Diferencial: muitas gramáticas comunitárias maduras (Python, JS, TS, Go, Rust, C/C++, Java, HTML, CSS, JSON, YAML, Markdown, Bash). Para legado: `tree-sitter-vba` (mantido por eirikpre), `tree-sitter-cobol` (mais experimental), `tree-sitter-pascal`, `tree-sitter-fortran`.

Licença: MIT. Foundation neutra. Maturidade: produção em editores de IDE há 7+ anos.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | Parser puro: lê código sem alterá-lo. Árvore é **lateral** ao fonte; identidade do código original mantida bit-a-bit. |
| 2 | Documentar antes de executar | sim | Queries Tree-sitter geram documentação estrutural (lista de funções, variáveis globais, fluxos) **sem rodar nada**. Princípio P2 satisfeito por design. |
| 3 | Testar antes de refatorar | sim | AST estável serve de baseline para diff antes/depois de refactor (golden tests sobre nodes). Mudou node = mudou comportamento. |
| 4 | Explicar antes de automatizar | sim | Visualização da árvore (`tree-sitter playground`) + queries explicitam estrutura para humano antes de qualquer transformação. Conta de Camada 3 (Compreensão) da tese 38. |
| 5 | Humano no controle por padrão | sim | Operação puramente analítica; nenhum side-effect. Humano decide o que fazer com a informação extraída. |
| 6 | Toda evolução deve ser reversível | sim | Análise sem efeito colateral; resultados são arquivos diffáveis (JSON/Markdown). Nada para reverter. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | Tree-sitter é leitor; identidade VBA/COBOL preservada literalmente. Conta de Camada 1 (Contato) e 2 (Leitura segura). |
| 8 | O protocolo importa mais que a ferramenta | sim | Gramáticas são especificação textual portável. Se Tree-sitter morresse, gramática `.js` pode ser portada para LALR(1), Earley, ou ANTLR com esforço médio. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | Lock-in baixo. Saída é AST padrão (estrutura recursiva); gramática é declarativa. Trocar para LSP-based parser é factível. |
| 10 | Segurança e não-regressão > velocidade | parcial | Parser em si é seguro (não executa). Mas error recovery agressivo pode produzir árvores confusas em código malformado, escondendo problemas reais — precisa validar com `MISSING`/`ERROR` nodes em queries. |

**Convergência média: 9/10 sim, 1/10 parcial, 0/10 não.**

## Divergências e riscos

- **Qualidade variável de gramáticas comunitárias**: `tree-sitter-vba` é razoavelmente mantido (Eirik Predbjørn-Riise); `tree-sitter-cobol` ainda é experimental (validar coverage com COBOL real antes de adotar)
- **Toolchain**: gramáticas precisam compilar C nativo; em CI requer gcc/clang. Não é problema em macOS/Linux mas adiciona complexidade
- **API Python recém-estabilizada**: bindings v0.21+ tem breaking changes de versões anteriores; pinar versão no `pyproject.toml`
- **Memória em arquivos grandes**: arquivos > 1MB podem consumir RAM significativa em parse incremental
- **Vendor risk**: BAIXO — Foundation neutra, comunidade grande
- **Compatibilidade AGPLv3**: MIT é compatível (pode ser sublicenciado em AGPLv3)

## O que precisa para avançar de estado

Para `convergence-mapped` (recomendação Opus):
- POC: usar `tree-sitter-vba` para parsear `Const_Colunas.bas` do Credenciamento e extrair lista de constantes via query S-expression
- Comparar com extração regex existente (Importador V3) — Tree-sitter precisa ganhar em robustez ou perder marginalmente em velocidade para valer
- Validar que `tree-sitter-vba` cobre 100% da sintaxe usada no Credenciamento (rodar parser em todos os `.bas` e checar `ERROR` nodes)
- Documentar como instalar gramática + bindings Python no `usehbn-phago`

Para `candidate`:
- Após POC verde, decisão de Maurício
- Confirmar gramáticas de outras linguagens-alvo (COBOL, Pascal) têm mantenedor ativo

Para `phagocytosed`:
- Tree-sitter virar dependência declarada em `usehbn-phago/pyproject.toml`
- Comando `hbn parse <file>` na CLI usar Tree-sitter por padrão

## Histórico de transições

| Data | De | Para | Motivo | Decisor |
|---|---|---|---|---|
| 2026-05-02 | n/a | in-radar | Entrada inicial no bootstrap E1 do Radar | Codex CLI, sob spec Opus |
| 2026-05-02 | in-radar | in-radar | Reescrita E1.1 (Codex — análise template) | Codex CLI |
| 2026-05-02 | in-radar | in-radar | Análise profunda Opus (sob demanda Maurício) — recomenda promoção | Claude Opus 4.7 (Frente 2) |

## Referências

- [Documentação oficial](https://tree-sitter.github.io/tree-sitter/) — guia, gramática, queries
- [Repositório principal](https://github.com/tree-sitter/tree-sitter) — MIT License, runtime + CLI
- [Bindings Python](https://github.com/tree-sitter/py-tree-sitter) — bindings oficiais para Python 3.10+
- [Gramática VBA (eirikpre)](https://github.com/eirikpre/tree-sitter-vba) — relevante para Credenciamento
- [Talk Strange Loop 2018 — Max Brunsfeld](https://www.thestrangeloop.com/2018/tree-sitter---a-new-parsing-system-for-programming-tools.html) — design rationale
- [Tree-sitter Foundation](https://github.com/orgs/tree-sitter/discussions) — governança comunitária
- Fonte interna: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:221-229`
