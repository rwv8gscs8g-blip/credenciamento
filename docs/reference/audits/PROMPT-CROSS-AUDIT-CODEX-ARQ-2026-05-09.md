---
titulo: Prompt Cross-Audit Codex — 3 questões arquiteturais 2026-05-09
tipo: prompt-de-cross-audit
audiencia: ia (Codex CLI ou Codex Heavy)
data: 2026-05-09
licenca: AGPLv3
foco: viabilidade técnica, mecânica de tooling, padrões open-source
contexto-canonico: usehbn/audits/AUDITORIA-ARQUITETURAL-2026-05-09.md
par-cross-audit: usehbn/audits/PROMPT-CROSS-AUDIT-ANTIGRAVITY-ARQ-2026-05-09.md
---

# Prompt Cross-Audit Codex — Arquitetura useHBN

## Como usar

Maurício submete o conteúdo do bloco `text` abaixo ao Codex CLI
(instruções de acesso em `46_PROMPT_UNIFICADO_CODEX.md` seção
"Como acessar"). Codex devolve relatório estruturado em
`local-ai/Time_AI/codex-erps/<data>-cross-audit-arq-codex.json`
(no repo `~/Projetos/usehbn/`).

Materiais a anexar (paths absolutos):

- `/Users/macbookpro/Projetos/Credenciamento/usehbn/audits/AUDITORIA-ARQUITETURAL-2026-05-09.md`
- `/Users/macbookpro/Projetos/Credenciamento/usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md`
- `/Users/macbookpro/Projetos/Credenciamento/usehbn/methodology/PRINCIPIOS-CONSTITUCIONAIS.md`
- `/Users/macbookpro/Projetos/Credenciamento/usehbn/modules/INDEX.md` (e os 7 módulos)
- `/Users/macbookpro/Projetos/Credenciamento/auditoria/00_status/43_PLANO_DOCUMENTACAO_V2_USEHBN.md`
- `/Users/macbookpro/Projetos/usehbn-phago/README.md` (skeleton Esteira 5)

---

## TEXTO DO PROMPT (cole no Codex)

```text
Codex, peço cross-audit técnico sobre 3 questões arquiteturais
abertas pelo operador Maurício em 2026-05-09. Foco esperado: viabilidade
técnica, mecânica de tooling, padrões open-source consolidados.
Antigravity está fazendo cross-audit paralelo com foco em design
conceitual e robustez de longo prazo. As duas auditorias serão
sintetizadas pelo Opus.

Não é auditoria genérica do protocolo useHBN. É auditoria estreita
de 3 questões específicas. Veja o documento canônico
`usehbn/audits/AUDITORIA-ARQUITETURAL-2026-05-09.md` (anexado) para o
estado atual.

CONTEXTO RÁPIDO

useHBN é protocolo aberto multi-braço para coordenação humano-IA. Em
2026-05-09 três questões arquiteturais foram abertas:

Q1 — Mono-repo `usehbn` com módulos como subpastas vs poly-repo
(`usehbn-phago`, `usehbn-capsules`, `usehbn-otel-rust`, `usehbn-coord`).
Operador sinalizou preferência por mono-repo (justificativa:
permissão por pasta + IAs sem perda de contexto). Decisão poly-repo
declarada em USEHBN-MODULES-ARCHITECTURE.md está em revisão.

Q2 — Confusão sobre tipologia: módulo do protocolo vs aplicação que
usa o protocolo. Credenciamento V12.0.0203 é módulo, aplicação ou
caso fundador? Documentos canônicos atuais ambíguos. Hipóteses A/B/C
listadas no documento de auditoria.

Q3 — Documentação cresceu rápido (12 docs em methodology, 8 em
modules, 7 em auditoria/00_status só de Frente 2, mais radar e
audits). Suspeitas de duplicação:
RADAR-PHAGOCYTOSIS-PIPELINE ↔ FAGOCITOSE+RADAR;
INCORPORATION-PROGRESSIVE-PLAN ↔ FAGOCITOSE;
INTER-CHAT-COORDINATION ↔ COORDENACAO-INTER-IA;
CROSS-IA-AUDIT-PROTOCOL ↔ AUDITORIA-CRUZADA.

ÁREAS DE FOCO TÉCNICO PARA SUA AUDITORIA

1. MONO-REPO vs POLY-REPO (foco mecânica de tooling)

   - Para um protocolo escrito em Rust + Python (substrato Rust;
     POCs Python na Árvore de Exploração), qual modelo entrega
     melhor:
     - Cargo workspace + multiple bin/lib crates para módulos Rust
     - Pyproject workspace (PEP 621) ou uv workspace para módulos Python
     - Pre-commit hooks granulares por subpasta
     - GitHub CODEOWNERS por path (granularidade real de permissão)
     - CI/CD com paths-filter (rodar só o que mudou)
   - O argumento do operador é "permissão por pastas + IAs sem perda
     de contexto". Isso se sustenta tecnicamente em mono-repo? E em
     poly-repo via sub-modules ou git-tree?
   - Migração: o que custa mais — fundir os repos `usehbn` (já
     existente) e `usehbn-phago` (skeleton recém-criado) em um único
     mono-repo? Ou manter poly e linkar via path-deps locais?
   - Que projetos open-source comparáveis (Rust workspaces como
     Tokio, Bevy; Python multi-package como Apache Airflow; mono-repos
     como Babel) ensinam aqui? Padrões consolidados?

2. TIPOLOGIA MÓDULO × APLICAÇÃO (foco padrões de implementação)

   - Como projetos open-source distinguem formalmente "implementação
     do protocolo" de "aplicação que consome o protocolo"?
     Exemplos: HTTP (RFC) vs nginx (impl) vs Wikipedia (consumer);
     LSP (Microsoft spec) vs rust-analyzer (impl) vs VS Code (host);
     MCP (Anthropic) vs servers (impl) vs Claude Desktop (client).
   - Como esses ecossistemas evitam confusão sobre fronteiras?
     Estruturas de repo? Naming conventions? Versionamento separado?
   - Para o caso Credenciamento V12.0.0203: qual das 3 hipóteses
     (A — aplicação, B — módulo, C — caso fundador) tem melhor
     encaixe técnico? Considerar: Credenciamento contém
     `usehbn/methodology/` que é hoje source-of-truth do protocolo;
     contém `.hbn/knowledge/0003-glasswing` que é insumo de
     Segurança; usa markers V2 em produção.
   - Qual o impacto técnico de cada hipótese sobre layout de repos
     (mono-repo) e sobre a migração?

3. SIMPLIFICAÇÃO DOCUMENTAL (foco mecânica de consolidação)

   - Para os pares duplicados listados acima, qual padrão de
     consolidação você recomenda?
     - Fundir tudo no `modules/<NOME>.md` e arquivar
       `methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md` etc.?
     - Manter `methodology/` como insumos longos e
       `modules/` como spec curta + cross-link?
     - Outra abordagem (ex: ADR pattern para decisões; how-to vs
       reference Diataxis)?
   - Conflito de numeração 43/44/45 entre Frente 1 (Credenciamento)
     e Frente 2 (useHBN) em `auditoria/00_status/`. Solução técnica:
     subpastas? prefixo F1_/F2_? renumeração? Padrões de tracking
     que projetos similares adotam (ADR sequential numbering, RFC
     numbered, etc.)?
   - 38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md é a V1 da tese hoje
     fagocitose-cêntrica. Manter como histórico append-only ou
     deprecar formalmente em favor da V2 (ainda em F2 de redação)?
   - Quais docs do `~/Projetos/usehbn/` (HBN-ARCHITECTURAL-REVIEW-2026-04,
     ROADMAP, GOVERNANCE, MAINTAINERS, etc.) são canônicos e quais
     estão obsoletos pós multi-braço?

OUTPUT ESPERADO

ERP estruturado em
`/Users/macbookpro/Projetos/usehbn/local-ai/Time_AI/codex-erps/2026-05-09-cross-audit-arq-codex.json`
com estrutura:

```json
{
  "esteira": "cross-audit-arq-codex",
  "questoes": {
    "Q1_mono_vs_poly": {
      "recomendacao": "mono-repo | poly-repo | hibrido",
      "racional_tecnico": "...",
      "tooling_implicacoes": [...],
      "padroes_open_source_referencia": [...],
      "custo_de_migracao_relativo": "baixo | medio | alto",
      "riscos_residuais": [...]
    },
    "Q2_tipologia": {
      "hipotese_recomendada": "A | B | C | hibrido",
      "racional_tecnico": "...",
      "padroes_open_source_referencia": [...],
      "implicacoes_de_layout": [...],
      "tratamento_credenciamento_recomendado": "..."
    },
    "Q3_simplificacao": {
      "padrao_consolidacao_recomendado": "...",
      "lista_de_acoes_concretas": [
        {"path": "...", "acao": "manter | fundir | arquivar | renomear", "justificativa": "..."}
      ],
      "tratamento_conflito_numeracao": "...",
      "tratamento_v1_tese_38": "preservar_historico | deprecar_formalmente | outro"
    }
  },
  "cross_referencias_uteis": [...],
  "questoes_que_codex_nao_respondeu": [...],
  "marker_atual": "🔍 HBN CROSS-AUDIT IN PROGRESS",
  "marker_proposto_pos_aprovacao": "🤝 HBN CROSS-AUDIT APPROVED"
}
```

Adicionalmente, escrever um relatório em prosa curta (≤ 800 linhas)
em `/Users/macbookpro/Projetos/usehbn/local-ai/Time_AI/codex-erps/2026-05-09-cross-audit-arq-codex-relatorio.md`
com:

1. Sumário executivo
2. Q1 detalhado (mono vs poly) — recomendação + 3 alternativas
   consideradas
3. Q2 detalhado (tipologia) — recomendação + análise das 3 hipóteses
4. Q3 detalhado (simplificação) — lista de ações concretas com
   path + ação + justificativa
5. Roadmap técnico de migração (4-8 semanas) caso mono-repo seja
   confirmado
6. Riscos técnicos não listados em outros lugares

TOM REQUERIDO

Direto, técnico, sem marketing-speak. Cite padrões open-source com
nomes e versões reais quando aplicável. Aponte trade-offs concretos,
não princípios abstratos.

Onde Antigravity tem terreno mais natural (design conceitual,
robustez de décadas), você pode dizer "esta questão tem ângulo melhor
respondido por Antigravity" e seguir adiante.

NÃO EXECUTE NADA NO FILESYSTEM ALÉM DO ERP + RELATÓRIO

Não migre arquivos, não crie repos novos, não delete nada.
Auditoria é apenas leitura + escrita de 2 arquivos no
`/Users/macbookpro/Projetos/usehbn/local-ai/Time_AI/codex-erps/`.
A síntese e o roadmap final ficam com Opus + Maurício.

REFERÊNCIAS

Documento canônico do estado atual:
`/Users/macbookpro/Projetos/Credenciamento/usehbn/audits/AUDITORIA-ARQUITETURAL-2026-05-09.md`

Documento par (cross-audit Antigravity):
`/Users/macbookpro/Projetos/Credenciamento/usehbn/audits/PROMPT-CROSS-AUDIT-ANTIGRAVITY-ARQ-2026-05-09.md`

Aguardando seu ERP + relatório.
```

---

## Como Opus integrará

1. Lê ERP + relatório Codex
2. Lê em paralelo o ERP/relatório Antigravity (par cruzado)
3. Para cada questão (Q1, Q2, Q3): identifica consenso ✅ / divergência 🟡
4. Sintetiza proposta unificada + roadmap em
   `usehbn/audits/SINTESE-CROSS-AUDIT-ARQ-2026-05-09.md`
5. Apresenta a Maurício para decisão final

## Marker

🔍 HBN CROSS-AUDIT IN PROGRESS — auditoria cruzada arquitetural
aberta 2026-05-09; aguardando ERPs Codex + Antigravity.
