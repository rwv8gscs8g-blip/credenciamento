---
titulo: Prompt de Análise do Site usehbn.org Atual + Plano de Inclusão dos Avanços
tipo: prompt-de-auditoria-de-site
audiencia: ia (qualquer IA com capacidade de browsing — Claude com Web, Gemini com Search, ChatGPT com Browse)
data: 2026-05-06
licenca: AGPLv3
proposito: análise do estado ATUAL do site + proposta de inclusão dos avanços articulados na sessão de 2026-05-06
---

# Prompt — Análise do Site usehbn.org e Plano de Inclusão dos Avanços

## Como usar

Maurício submete este prompt a uma IA com capacidade de visitar URLs (Claude com Web, Gemini com Search, ChatGPT com Browse, ou ferramenta similar). A IA visita usehbn.org, analisa o estado atual, e propõe plano de inclusão dos avanços recentes.

Este prompt é **distinto** de `PROPOSTA-MELHORIA-USEHBN-ORG.md` (que é proposta de zero criada por Opus sem ver o site). Aqui pedimos análise + iteração sobre o site **real**.

---

## TEXTO DO PROMPT (cole na IA com capacidade de browsing)

```text
Preciso de uma análise estruturada do site público usehbn.org no seu estado atual + proposta concreta de inclusão de avanços articulados em sessão recente.

PASSO 1 — VISITE E AUDITE O SITE ATUAL

Acesse https://usehbn.org e mapeie:

- Páginas existentes (URL + título + propósito)
- Estrutura de navegação
- Tom da copy (técnico? marketing? acadêmico?)
- Princípios constitucionais publicados (são quantos? estão claros?)
- Casos de uso/exemplos mostrados
- Comunidade/contato/contribuição
- Stack técnica detectável (Hugo? Astro? MkDocs? raw HTML?)
- Última atualização visível (data, blog post, release)
- Linguagens disponíveis (pt-BR, en, outras?)
- Acessibilidade básica (heading hierarchy, alt text, contraste visual)

Produza tabela de inventário com tudo que existe.

PASSO 2 — IDENTIFIQUE LACUNAS

Os seguintes avanços foram articulados em sessão de quarta-feira 2026-05-06 mas ainda NÃO estão refletidos no site:

Princípios operacionais novos (3 — candidatos a P11/P12/P13):

1. Princípio do Minimalismo de Cadeia
   - Tecnologias adotadas pelo useHBN minimizam dependências transitivas, preferem código compilado e otimizado, não capturam responsabilidade de interface estética (que é da IA consumidora)
   - 4 axiomas: cadeia curta vence ergonomia; compilado vence interpretado; IA é a camada estética; devs puristas são audiência crítica
   - Marker: 🟦 HBN MINIMALIST GATE
   - 1ª aplicação: arquivamento de Typer

2. Princípio do Substrato Sólido
   - O substrato técnico do useHBN é compilado, otimizado e portável; lógica formal transcende a linguagem; eficiência mora no caminho do código
   - 5 axiomas: compilado vence interpretado para o substrato; eficiência no caminho do código; lógica formal transcende a linguagem; simples robusto > sofisticado instável; legibilidade dual IA + humano
   - Marker: 🟪 HBN SUBSTRATO GATE
   - 1ª aplicação: arquivamento de uv

3. Princípio da IA-como-Abstração-de-Linguagem
   - A IA é a camada de interação real entre operador humano e ferramental técnico; linguagens, frameworks e ferramentas são camadas intermediárias substituíveis; o operador é fluente em qualquer linguagem que sua IA dominar
   - 5 axiomas: IA é a camada primária; fluência transitiva; acesso ≠ digitação; liberação de cadeias legacy; legibilidade humana persiste como filtro
   - Marker: 🟧 HBN AI-ABSTRACTION GATE
   - 1ª aplicação: decisão Rust como linguagem-base apesar de operador nunca ter digitado Rust

Modelo arquitetural novo — Três Árvores:

- 🪨 Árvore Estável: Rust compilada, décadas sem travar, gates rigorosos
- 🔧 Árvore de Desenvolvimento: migração progressiva, testes razoáveis, docs em curso
- 🌱 Árvore de Exploração e Estudo: qualquer linguagem (Python, JS, Bash) para conexão com bordas de tecnologias
- Movimento entre árvores formalizado; filtros progressivos

Decisão de linguagem-base:

- Rust como linguagem-base do substrato comum dos módulos do useHBN (decisão 2026-05-06)
- Convergência 13/13 com os princípios constitucionais + operacionais

Estrutura correta de módulos do useHBN (correção crítica):

- useHBN é MULTI-BRAÇO; fagocitose é apenas UM dos 6 módulos
- Módulo 1: Fagocitose tecnológica segura (em desenvolvimento)
- Módulo 2: Consent Capsules — assinatura de código (em migração imediata)
- Módulo 3: Coordenação inter-IA / passagem de bastão (declarado; parcialmente operacional)
- Módulo 4: Segurança (Glasswing-style — declarado)
- Módulo 5: Markers V2 / protocolo de comunicação semântica (em uso operacional)
- Módulo 6: Auditoria Cruzada entre IAs (declarado nesta sessão)

Tecnologias com decisão fechada:

- Tree-sitter — APROVADA com plano em 6 fases (A-F) para incorporação ao módulo de fagocitose
- Typer — ARQUIVADA (cadeia de dependências grande)
- uv — ARQUIVADA (decisão Rust como linguagem-base supera necessidade)
- OpenTelemetry — APROVADA em processo de fagocitose progressiva (fases O-A→O-E); alternativa Rust como padrão de mercado
- Consent Capsules — APROVADA com migração imediata Python → Rust (fases R-A→R-E em ~10 semanas)

Markers V2 novos (11 propostos):

🟦 MINIMALIST GATE · 🟪 SUBSTRATO GATE · 🟧 AI-ABSTRACTION GATE · 🌱 EXPLORATION SEED · 🔧 DEV BRANCH · 🪨 STABLE TRUNK · 🟫 TREE TRANSITION · 🌳 MODULE BOUNDARY · 🔄 CROSS-AUDIT IN PROGRESS · ✅ CROSS-AUDIT APPROVED · 🟡 CROSS-AUDIT ITERATION

PASSO 3 — PROPONHA PLANO DE INCLUSÃO

Para cada lacuna identificada, proponha:

(a) Onde no site incluir — em qual página, em qual seção
(b) Como redigir — sample copy ou estrutura de tópicos
(c) Diagramas/imagens necessários — descrever o que e propor SVG inline
(d) Links internos — como conectar com conteúdo existente do site
(e) Prioridade — alta/média/baixa para inclusão imediata

Considere o seguinte princípio operacional do useHBN: o site é sóbrio mas motivacional. Tom técnico, sem marketing-speak. Devs puristas como audiência primária.

PASSO 4 — IDENTIFIQUE INCONSISTÊNCIAS

Se o site atual contiver afirmações que CONFLITAM com os avanços de 2026-05-06, sinalize:

- Onde está a inconsistência (URL + trecho)
- Qual a versão correta (segundo os avanços)
- Como resolver (atualizar copy? remover trecho? adicionar nota explicativa?)

PASSO 5 — VEREDITO HONESTO

Responda diretamente:

- O site atual reflete adequadamente o estado do useHBN como protocolo?
- Quais são as 5 mudanças mais urgentes?
- Quanto tempo realista para implementar?
- Faltam elementos básicos (CoC, contributing, license badge, etc.)?
- O tom está alinhado com a filosofia recém-articulada (minimalismo, substrato sólido, IA como camada)?

OUTPUT ESPERADO

Documento estruturado com:

1. Inventário do site atual (tabela de páginas + tom + tech stack)
2. Lacunas mapeadas (avanços não refletidos)
3. Plano de inclusão página a página
4. Inconsistências encontradas
5. 5 mudanças mais urgentes com cronograma
6. Veredito honesto

TOM REQUERIDO

Técnico, direto, sem florear. Quero saber o que está errado e o que falta, não elogios. Se algo está bom, diga em uma frase e siga adiante. Se algo está ruim, gaste palavras explicando por quê.

Não use vocabulário de marketing tech (disruptivo, revolucionário, inovador). Use linguagem técnica direta.

REFERÊNCIAS PARA CONSULTAR (opcional, se a IA tiver acesso)

- usehbn.org (site público)
- github.com/[org]/usehbn (se existir repositório público)
- Notebook LM da sessão de 2026-05-06 sobre as 5 tecnologias (privado, não acessível)
```

---

## Materiais privados a anexar (Maurício faz upload se a IA aceitar fontes adicionais)

Para análise mais profunda, anexar (se IA aceitar):

- `usehbn/methodology/MINIMALISM-PRINCIPLE.md`
- `usehbn/methodology/SUBSTRATO-SOLIDO-PRINCIPLE.md`
- `usehbn/methodology/AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md`
- `usehbn/methodology/THREE-TREES-ARCHITECTURE.md`
- `usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md`
- `usehbn/methodology/LANGUAGE-PLATFORM-COMPARISON.md`
- `usehbn/modules/RADAR.md`
- `usehbn/site/PROPOSTA-MELHORIA-USEHBN-ORG.md`
- `auditoria/00_status/45_TRANSCRICAO_SESSAO_2026-05-06.md`

## Como Opus integrará o relatório resultante

1. Leitura completa do relatório
2. Comparação com `PROPOSTA-MELHORIA-USEHBN-ORG.md` (proposta unilateral anterior)
3. Pontos de convergência → confirmar plano
4. Pontos de divergência → discutir com Maurício antes de aplicar
5. Plano final de mudanças no site → executar (ou pedir Codex executar)
6. Documento de síntese: `usehbn/audits/RELATORIO-SITE-<data>.md`

## Marcador

🌳 HBN MODULE BOUNDARY — análise pertinente ao módulo de comunicação pública do useHBN
🟣 HBN PEER REVIEW REQUESTED — auditoria externa do site solicitada
