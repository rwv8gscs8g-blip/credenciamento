---
titulo: Prompt Cross-Audit Antigravity — 3 questões arquiteturais 2026-05-09
tipo: prompt-de-cross-audit
audiencia: ia (Antigravity / Codex Heavy / Gemini Pro)
data: 2026-05-09
licenca: AGPLv3
foco: design conceitual, robustez de longo prazo, tipologia formal
contexto-canonico: usehbn/audits/AUDITORIA-ARQUITETURAL-2026-05-09.md
par-cross-audit: usehbn/audits/PROMPT-CROSS-AUDIT-CODEX-ARQ-2026-05-09.md
---

# Prompt Cross-Audit Antigravity — Arquitetura useHBN

## Como usar

Maurício submete o conteúdo do bloco `text` abaixo ao Antigravity (ou
equivalente: Codex Heavy variant, Gemini Pro com browsing). Antigravity
devolve relatório estruturado.

Materiais a anexar:

- `usehbn/audits/AUDITORIA-ARQUITETURAL-2026-05-09.md` (estado atual)
- `usehbn/methodology/PRINCIPIOS-CONSTITUCIONAIS.md` (13 princípios)
- `usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md` (arquitetura declarada — em revisão)
- `usehbn/methodology/THREE-TREES-ARCHITECTURE.md`
- `usehbn/modules/INDEX.md` + os 7 módulos
- `auditoria/00_status/43_PLANO_DOCUMENTACAO_V2_USEHBN.md` (v1.1)
- `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md` (V1 — para contraste com V2 multi-braço)
- `usehbn/audits/PROMPT-CROSS-AUDIT-CODEX-ARQ-2026-05-09.md` (prompt par — para evitar duplicação)

---

## TEXTO DO PROMPT (cole no Antigravity)

```text
Antigravity, peço cross-audit conceitual sobre 3 questões arquiteturais
abertas pelo operador Maurício em 2026-05-09. Foco esperado: design
conceitual, robustez de longo prazo (5-10 anos), tipologia formal,
crítica de comparação com protocolos abertos consolidados.

Codex está fazendo cross-audit paralelo com foco em viabilidade
técnica e mecânica de tooling. As duas auditorias serão sintetizadas
pelo Opus (Frente 2 useHBN) em proposta + roadmap.

Esta NÃO é auditoria genérica do useHBN. É estreita: 3 questões
específicas listadas em
`usehbn/audits/AUDITORIA-ARQUITETURAL-2026-05-09.md`.

Você já fez cross-audit anterior em 2026-05-09 sobre os 6 módulos
recém-formalizados (relatório em
`usehbn/audits/RELATORIO-ANTIGRAVITY-MODULOS-2026-05-09.md`).
Veredito foi 🟡 ITERATION; Opus aplicou 9 iterações; status pós-iteração
🤝 APPROVED. Aquele cross-audit fica como contexto.

CONTEXTO RÁPIDO

useHBN é protocolo aberto multi-braço para coordenação humano-IA, com
13 princípios constitucionais, 6 módulos paralelos + Radar transversal,
Rust como linguagem-base do substrato, modelo das 3 Árvores
(Estável/Desenvolvimento/Exploração), 21 marcadores canônicos,
Cápsulas de Consentimento como infraestrutura transversal, Auditoria
Cruzada formal entre IAs.

Em 2026-05-09 três questões arquiteturais foram abertas após a
Esteira 5 (skeleton `usehbn-phago` criado como repo separado):

Q1 — Mono-repo `usehbn` único vs poly-repo. Operador sinalizou
preferência por mono-repo (justificativa: permissão por pasta + IAs
sem perda de contexto). Decisão poly-repo declarada em
USEHBN-MODULES-ARCHITECTURE.md em revisão.

Q2 — Tipologia confusa: o Credenciamento V12.0.0203 é módulo do
useHBN, aplicação que usa o protocolo, ou caso fundador? Hipóteses A
(aplicação), B (módulo de aplicação real), C (caso fundador) listadas
no documento de auditoria.

Q3 — Documentação cresceu rápido. Suspeitas de duplicação:
RADAR-PHAGOCYTOSIS-PIPELINE ↔ FAGOCITOSE+RADAR;
INCORPORATION-PROGRESSIVE-PLAN ↔ FAGOCITOSE;
INTER-CHAT-COORDINATION ↔ COORDENACAO-INTER-IA;
CROSS-IA-AUDIT-PROTOCOL ↔ AUDITORIA-CRUZADA. Plus conflito numeração
43/44/45 entre Frente 1 (Credenciamento) e Frente 2 (useHBN) em
auditoria/00_status/.

ÁREAS DE FOCO CONCEITUAL PARA SUA AUDITORIA

1. MONO-REPO vs POLY-REPO (foco design e robustez)

   - Qual modelo melhor protege os 13 princípios constitucionais a
     longo prazo?
     - P6 (toda evolução reversível) — qual modelo torna mais
       barato remover um módulo?
     - P9 (frameworks descartáveis) — qual modelo torna mais óbvio
       que módulos são descartáveis?
     - P11 (Minimalismo de Cadeia) — qual modelo evita explosão de
       acoplamentos transversais?
     - P12 (Substrato Sólido) — qual modelo dá maior estabilidade
       ao núcleo Rust?
   - O argumento "permissão por pastas + IAs sem perda de contexto"
     é tecnicamente sólido OU é racionalização de uma preferência
     que tem outro motivo? Crítica honesta.
   - Risco de mono-repo virar mono-pile: como projetos open-source
     de longo curso (Linux kernel — mono; Babel — mono; Kubernetes —
     poly fragmentado depois consolidado) gerenciam essa tensão?
   - Reversibilidade: mono → poly é mais barato que poly → mono?
     Ou vice-versa? Qual decisão é menos amarrada?

2. TIPOLOGIA MÓDULO × APLICAÇÃO (foco design conceitual)

   - Em ciência da computação, qual a distinção formal entre:
     - Protocolo (spec abstrata)
     - Implementação de referência do protocolo
     - Implementação alternativa do protocolo
     - Aplicação que consome o protocolo
     - Caso de estudo / artefato fundador onde o protocolo nasceu
   - Aplicar esta distinção ao caso Credenciamento V12.0.0203:
     - Contém todo o `usehbn/methodology/` como source-of-truth
     - Contém `.hbn/knowledge/0003-glasswing` que é insumo de
       Segurança
     - Usa markers V2 em produção
     - É o lugar onde a fagocitose foi descoberta empiricamente
       (PHAGOCYTOSIS-VBA-PATTERNS L1-L18, M1-M7)
     - Tem código (VBA) que NÃO é parte do protocolo
   - Qual das 3 hipóteses (A — aplicação, B — módulo, C — caso
     fundador) tem melhor encaixe conceitual? Defenda com analogia
     a protocolos abertos consolidados.
   - Tipologia formal proposta: como nomear cada categoria
     ("aplicação", "instância", "caso fundador") de modo que a
     distinção fique clara em documentos públicos do useHBN v1.0?
   - Há precedente em RFCs IETF, W3C TR, Anthropic MCP, ou outros
     protocolos abertos sobre como descrever os "primeiros usuários"
     de um protocolo recém-formalizado?

3. SIMPLIFICAÇÃO DOCUMENTAL (foco crítica editorial)

   - Para um protocolo aberto que pretende publicação v1.0 no GitHub:
     - Qual o tamanho saudável da documentação core (em número de
       documentos canônicos)? Compare com HTTP RFCs, MCP spec,
       Verifiable Credentials W3C, gRPC.
     - Os 12 docs em methodology/ + 8 em modules/ + 7 em
       auditoria/00_status/ Frente 2 = 27 documentos. Excessivo,
       saudável, ou insuficiente para a complexidade real?
   - Padrões editoriais consolidados:
     - Diataxis (tutorial / how-to / reference / explanation) — o
       useHBN usa parcialmente. Adoção plena ajudaria?
     - ADR (Architecture Decision Records) — o useHBN usa
       informalmente em commits e auditoria/. Formalização ajudaria?
     - Single source of truth por conceito — qual o critério para
       decidir "X é canônico, Y é insumo"?
   - Para os pares duplicados listados, qual padrão de consolidação
     você sugere? Crítica do critério de Opus (que sugeriu fundir os
     5 documentos methodology/ duplicados em insumos longos vs
     modules/ spec curtas).
   - 38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md (V1) como tratar:
     preservar como histórico, deprecar formalmente, ou reescrever?
     Análogo: como W3C trata especificações suplantadas?
   - Conflito de numeração entre Frentes em auditoria/00_status/:
     proposta de partição (subpastas? prefixo? renumeração?) que seja
     conceitualmente robusta, não só técnica.

OUTPUT ESPERADO

Documento estruturado em prosa (Markdown) entregue como mensagem aqui
ou como arquivo:

1. Sumário executivo (1 parágrafo)
2. Q1 — recomendação + crítica do argumento do operador + comparação
   com 3 protocolos abertos consolidados
3. Q2 — tipologia formal proposta + recomendação de hipótese A/B/C +
   precedente em outros protocolos
4. Q3 — crítica editorial + lista priorizada de docs a manter, fundir
   ou deprecar + padrão de consolidação recomendado
5. Riscos sistêmicos não listados (5-10 anos)
6. Veredito: 🤝 APPROVED (recomendação Opus pode prosseguir como está)
   / ⚖️ ITERATION (divergência substantiva pede nova rodada) / ❌
   RETURN (questão precisa ser reformulada)

TOM REQUERIDO

Sincero, crítico, sem complacência. Não validar; testar. Onde Codex
tem terreno melhor (mecânica de tooling, padrões de código), você
pode dizer "esta questão tem ângulo melhor respondido por Codex" e
focar onde sua perspectiva agrega.

Use linguagem técnica direta. Cite RFCs, W3C TR, papers, projetos
open-source com nomes e datas.

NÃO USE LINGUAGEM DE PRODUTO

Evite vocabulário de marketing tech. Se o useHBN está reinventando
algo conhecido, diga. Se está inovando de fato, diga onde.

REFERÊNCIA CRUZADA

Você fez cross-audit anterior dos 6 módulos. Não repita aquele escopo.
Foque nas 3 questões novas.

Codex está rodando cross-audit paralelo com foco técnico. Não
duplique seu trabalho — onde houver convergência, basta marcar
"Codex provavelmente cobrirá este ângulo" e seguir.

Aguardando seu output.
```

---

## Como Opus integrará

1. Lê output Antigravity
2. Lê em paralelo o ERP+relatório Codex
3. Para cada questão (Q1, Q2, Q3): identifica consenso ✅ / divergência 🟡
4. Sintetiza proposta unificada + roadmap em
   `usehbn/audits/SINTESE-CROSS-AUDIT-ARQ-2026-05-09.md`
5. Apresenta a Maurício para decisão final

## Marker

🔍 HBN CROSS-AUDIT IN PROGRESS — auditoria cruzada arquitetural
aberta 2026-05-09; aguardando outputs Codex + Antigravity.
