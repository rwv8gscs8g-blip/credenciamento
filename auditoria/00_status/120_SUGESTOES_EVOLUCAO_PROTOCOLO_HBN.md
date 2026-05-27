---
titulo: Sugestões de evolução do protocolo HBN — input para próximo PROMPT_ARQUITETO_USEHBN_AUTONOMO
data: 2026-05-27
autoria: claude-opus-4-7 (sessão pós-auditoria cruzada Codex 0012 + Gemini/Antigravity 0011)
gatilho: Mauricio pediu evolução do protocolo para formalizar Cadência D Estendida (Codex implementador + Opus/Antigravity auditores cruzados em contexto novo)
audiencia: próxima sessão do PROMPT_ARQUITETO_USEHBN_AUTONOMO (Claude Opus consumindo este documento como input)
status: CONSOLIDADO — vereditos do arquiteto na onda 0112 (2026-05-27). Ver .hbn/protocol-evolutions/20260527-1300-decisao-evolucoes-onda-38-passagem-bastao.md. Resumo: Tier 1 = P1(mod), P2, P4, P5(como knowledge 0020), P7(renomeado BLOQUEADOR/FORTE/MARGINAL); Tier 2 = P3, P6(comando corrigido), P8, P10(pós-freeze); REFINAR = P9. Aplicado em PROMPT_ARQUITETO v1.4 §12 + knowledge 0019/0020.
---

# Sugestões de evolução do protocolo HBN

> Este documento NÃO altera o protocolo unilateralmente. É input estruturado para o próximo ciclo de auto-evolução do PROMPT_ARQUITETO_USEHBN_AUTONOMO. O próximo Claude que rodar o PROMPT_ARQUITETO deve consumir este arquivo, decidir Promover Tier 1 / Promover Tier 2 / Rejeitar / Refinar para cada item, e produzir as edições oficiais no protocolo.

## Contexto que motivou estas sugestões

Em 2026-05-27, após o incidente de corrupção do workbook da Onda 38.2.2 e duas rodadas de auditoria cruzada (Codex 0009/0012 + Antigravity 0010 + Gemini-como-árbitro 0011), Mauricio decidiu:

1. Transferir a implementação V206 ao Codex (Cadência D plena);
2. Manter Opus 4.7 + Antigravity em auditoria cruzada a cada gate relevante;
3. **Cada auditoria cruzada começa em chat NOVO** — Opus e Antigravity sem contexto absorvido de turnos anteriores, garantindo capacidade máxima de cada IA;
4. Formalizar essa cadência no protocolo HBN para reuso em ondas/projetos futuros.

As lições abaixo emergem da observação empírica desta semana de operação.

---

## Proposta 1 — Cadência D Estendida (formalização)

**Rule**: para sistemas em estabilização pré-release pública com alta exigência de robustez, adotar Cadência D Estendida:

- **1 implementador único** por ciclo de estabilização inteiro (ex: Codex para Ondas 38.2.3+38.2.4+38.2.5)
- **2 auditores cruzados** em contexto novo a cada gate relevante (Opus + Antigravity)
- **Mauricio** como hearback final + executor operacional (Excel, RVS)

**Por que**: distribui a carga cognitiva (implementador concentra contexto de código; auditores chegam frescos a cada gate). Reduz risco de fadiga de contexto (incidente Opus 60% em sessão de 5h da Onda 38.2.2 demonstrou que 1 IA fazendo tudo é insustentável). Aumenta cobertura de revisão (2 olhares independentes por gate).

**Como aplicar**:
- Implementador NÃO pode auditar próprio trabalho (conflito)
- Auditores NÃO podem implementar (mantêm distância)
- Implementador pode propor evoluções de protocolo, mas auditores arbitram
- Mauricio decide qualquer empate ou conflito

**Trade-off conhecido**: mais ciclos = mais elapsed time. Para release pública com risco alto de regressão (V206 corrompeu workbook), o trade-off vale.

**Status sugerido**: PROMOVER TIER 1 (incorporar como cadência oficial em CLAUDE.md / AGENTS.md).

---

## Proposta 2 — Auditoria cruzada SEMPRE em chat NOVO

**Rule**: sempre que uma IA fizer auditoria cruzada de trabalho de outra IA, ela DEVE começar em chat novo (sem retomar chat existente).

**Por que**: cada IA já consumiu contexto para chegar à entrega atual. Se a auditora apenas "continua" o chat onde já trabalhou, ela:
- Está em modo "executora" mentalmente, não "auditora"
- Tem menos espaço de contexto livre para ler trabalho novo
- Pode ter viés cognitivo de defender decisões prévias suas

Chat novo = capacidade máxima + olhar fresco.

**Como aplicar**:
- Prompt de auditoria cruzada (anexo §X do PROMPT_ARQUITETO) declara: "Você está em chat NOVO. Não tem memória de sessões anteriores."
- IA auditora referencia paths de arquivos via Read (não memória)
- Output da auditoria é o único artefato persistente (commit)

**Status sugerido**: PROMOVER TIER 1.

---

## Proposta 3 — Gates intra-onda obrigatórios para Cadência D Estendida

**Rule**: dentro de uma onda, dividir em sub-fases auditáveis (gates). Ex: Onda 38.2.4 (helpers transversais) tem GATE-B1 (design), GATE-B2 (helpers + testes unitários), GATE-B3 (substituição em Repos), GATE-B4 (remoção duplicatas + L40).

**Por que**: ondas grandes (helpers transversais tocando 5 Repos) são propensas a regressão silenciosa se auditadas só no fim. Gates intra-onda permitem detectar e corrigir cedo.

**Critério para definir um gate**:
- Marco lógico (não tempo): "design pronto", "helpers implementados", "Repo X refatorado"
- Trabalho persistido em commit local
- Output auditável (arquivo .md, evidência CSV, readback fechado)
- Custo de auditoria razoável (não auditar cada commit isolado)

**Heurística**: 3-6 gates por onda. Menos que 3 = onda monolítica (perigo). Mais que 6 = micro-gestão (custo > valor).

**Status sugerido**: PROMOVER TIER 2 (incorporar como prática recomendada na seção §X do PROMPT_ARQUITETO sobre desenho de ondas).

---

## Proposta 4 — Mitigar viés de auto-recomendação em decisões de bastão

**Rule**: quando uma IA é perguntada "a quem passar o bastão", ela DEVE:

1. **Declarar explicitamente** se sua resposta inclui auto-indicação
2. **Listar evidência objetiva** que sustenta a recomendação (não opinião)
3. **Reconhecer viés natural** ("tendo a recomendar-me porque...")
4. **Sugerir mitigações** ao próprio viés (ex: "Mauricio pondere isso comparando com outras 2 IAs")

**Por que**: observado em 2026-05-27:
- Codex 0012 recomendou ele mesmo para implementar 3 ondas
- Antigravity 0011 (em papel de Gemini árbitro) recomendou Antigravity para implementar 2 ondas
- Opus, ao recomendar "Codex implementa + Opus audita", também preservou própria relevância

Sem declaração explícita do viés, decisões de bastão podem ser distorcidas.

**Como aplicar**:
- PROMPT_ARQUITETO inclui template para decisão de bastão com checklist anti-viés
- Auditoria cruzada de 3 IAs (não 2) ajuda — viés de cada uma se compensa

**Status sugerido**: PROMOVER TIER 1.

---

## Proposta 5 — Lição L44: Explore agent diff "cosmético" superficial

**Rule (proposta L44)**: quando um Explore agent reporta diff "cosmético" entre 2 versões de código, isso é SUSPEITO até prova contrária. Inspecionar o pipeline gerador antes de classificar como benigno.

**Evidência empírica**: em 2026-05-27, Opus 4.7 lançou Explore agent para comparar `local-ai/incoming/V206-Rollback-*/Cadastro_Servico.frm` vs `src/vba/Cadastro_Servico.frm`. Agent reportou:

> "Cadastro_Servico.frm: 9 linhas alteradas. Remoção de 4 linhas privadas de estado (mIgnorarFiltro, mTxtBuscaTopo). Adição de 3 linhas em branco ao final. Tipo: Refatoração de estado (limpeza de variáveis desnecessárias)."

Foi classificado como benigno. **Era P0 real**: as variáveis `Private mIgnorarFiltro` e `Private WithEvents mTxtBuscaTopo` faziam parte do contrato do form; o `.code-only.txt` gerado tinha bug em `publicar_vba_import_v2.py:212-248` que para antes das declarações WithEvents quando encontra `Attribute mTxtBuscaTopo.VB_VarHelpID = -1`.

Codex em 0012 inspecionou o pipeline gerador (não só o diff resultante) e detectou o bug. Opus delegou ao Explore agent (que só compara texto) e perdeu.

**Lição transversal**: delegação a sub-agentes corta atalhos em casos onde investigação do pipeline é necessária. "Never delegate understanding" — CLAUDE.md já adverte. L44 reforça em contexto de diff.

**Status sugerido**: PROMOVER TIER 1 como L44 em `.hbn/protocol-evolutions/`.

---

## Proposta 6 — Numeração consistente de proposals

**Rule**: todo proposal em `.hbn/proposals/` segue numeração 00NN- (4 dígitos), começando em 0001, seguindo ordem cronológica de criação. Cada IA prefixa o nome: `0013-codex-<tema>.md`, `0014-opus-<tema>.md`.

**Estado atual**: numeração inconsistente. Ex: temos 0009 (Codex auditoria), 0010 (Antigravity auditoria), 0011 (Gemini árbitro), 0012 (Codex auditoria plano). Próximo livre: 0013.

**Por que**: facilita rastreabilidade. Linkagem cruzada entre proposals torna-se previsível.

**Como aplicar**:
- PROMPT_ARQUITETO inclui regra de numeração
- Ferramentas/scripts podem auto-gerar próximo número via `ls .hbn/proposals/ | sort -n | tail -1`

**Status sugerido**: PROMOVER TIER 2 (consolidar como prática).

---

## Proposta 7 — Auditor cruzado tem direito de veto P0

**Rule**: durante Cadência D Estendida, se um auditor (Opus ou Antigravity) marca um achado como **P0** (Priority Zero — bloqueia progresso), o implementador (Codex) NÃO PODE prosseguir até resolução.

**Como aplicar**:
- Auditoria deve declarar explicitamente P0 vs P1 vs P2
- P0 = bloqueador (segurança, correção, regressão)
- P1 = altamente recomendado (qualidade, manutenibilidade)
- P2 = nice-to-have (DRY, performance marginal)
- Implementador incorpora P0 obrigatoriamente; julga P1 com transparência (incorpora ou justifica não-incorporação); pode ignorar P2

**Conflito P0 × P0 entre auditores**: Mauricio decide (hearback explícito).

**Evidência**: Codex em 0012 levantou 3 P0 no plano Opus. Sem veto P0 formalizado, Codex poderia ter sido sobrescrito por autoridade arquitetural Opus. Veto P0 protege a qualidade técnica.

**Status sugerido**: PROMOVER TIER 1.

---

## Proposta 8 — Padronização de output de auditoria cruzada

**Rule**: todo output de auditoria cruzada segue template:

```markdown
# Auditoria cruzada — GATE-<ID> da Onda <N> — por <IA>

## 1. Veredito
APROVAR / APROVAR com P1 incorporados / BLOQUEAR com P0
(uma frase justificativa)

## 2. P0 obrigatórios (bloqueiam progresso)
(numerados — cada item: descrição + evidência + remediação proposta)

## 3. P1 recomendados (alta prioridade, não bloqueiam)
(numerados)

## 4. P2 marginais (nice-to-have)
(numerados)

## 5. Convergências com seu trabalho original
(o que a auditora endossa)

## 6. Divergências
(o que a auditora discorda — argumento técnico)

## 7. Riscos não cobertos
(lacunas)

## 8. Recomendação de próxima ação
```

**Por que**: torna auditoria comparável entre IAs e ondas. Implementador (Codex) sabe exatamente onde olhar para incorporar.

**Status sugerido**: PROMOVER TIER 2.

---

## Proposta 9 — Protocolo de "auditoria curta" para gates triviais

**Rule**: para gates triviais (ex: AT-1 isolado de re-sync), permitir auditoria curta (1 IA, output sub-1000 palavras) em vez de auditoria cruzada plena.

**Critério de "trivial"**:
- Mudança isolada em 1-2 arquivos
- Sem impacto em comportamento de runtime
- Reverso trivial
- Custo de bug = baixo

**Por que**: 12-15 ciclos de auditoria cruzada plena (estimativa V206) é caro. Algumas auditorias podem ser leves sem perder qualidade.

**Mitigação**: Mauricio decide ad-hoc se gate é trivial ou não. Default = auditoria cruzada plena.

**Status sugerido**: REFINAR (não promover ainda — testar empiricamente em 38.2.3 antes).

---

## Proposta 10 — Atualizar `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` com lições da V206

**Rule**: ao final da Onda 38.2.5 (ou GATE-FREEZE), incorporar em PHAGOCYTOSIS-VBA-PATTERNS as lições gerais que emergiram:

- L41 (import 2 fases para multi-hotfix)
- L43 (GATE-USO-PROLONGADO)
- L44 (Explore agent diff cosmético) — se aprovada
- Padrão de helpers `GravarIdTextual`/`LerIdTextual` (se 38.2.4 entregue)
- Padrão de macro descartável de migração (se 38.2.5 entregue)

**Por que**: PHAGOCYTOSIS-VBA-PATTERNS é a base de conhecimento técnica reusável. Lições V206 são genéricas para outros projetos VBA.

**Como aplicar**:
- Onda extra (38.2.6 ou pós-freeze) dedica esforço documental
- Codex implementa documentação (sabe o código)
- Opus + Antigravity auditam clareza didática

**Status sugerido**: PROMOVER TIER 2 (planejar mas não bloqueia GATE-FREEZE).

---

## Sumário para o próximo PROMPT_ARQUITETO

| # | Proposta | Status sugerido |
|---|---|---|
| 1 | Cadência D Estendida formalizada | TIER 1 |
| 2 | Auditoria cruzada SEMPRE em chat novo | TIER 1 |
| 3 | Gates intra-onda obrigatórios | TIER 2 |
| 4 | Mitigar viés de auto-recomendação | TIER 1 |
| 5 | L44 — Explore diff cosmético | TIER 1 (lição em protocol-evolutions) |
| 6 | Numeração consistente proposals | TIER 2 |
| 7 | Veto P0 por auditor | TIER 1 |
| 8 | Template padronizado de output auditoria | TIER 2 |
| 9 | Auditoria curta para gates triviais | REFINAR (testar empiricamente) |
| 10 | Lições V206 → PHAGOCYTOSIS-VBA-PATTERNS | TIER 2 (planejar para pós-freeze) |

## Notas para o próximo Claude

- Você lerá este arquivo como input do PROMPT_ARQUITETO_USEHBN_AUTONOMO
- Pode (e deve) discordar de qualquer item se sua análise apontar caminho diferente
- Veracidade > continuidade — se uma proposta tem furo técnico, marque "REJEITAR" com justificativa
- Após decisões: edite AGENTS.md / CLAUDE.md / .hbn/protocol-evolutions/ conforme cada Tier
- Documente sua decisão por proposta em arquivo novo `.hbn/protocol-evolutions/<timestamp>-decisao-evolucoes-onda-38.md`
- Knowledge 0017 (orçamento 50%) continua aplicável — sinalize handoff se ficar fadigado

---FIM 120---
