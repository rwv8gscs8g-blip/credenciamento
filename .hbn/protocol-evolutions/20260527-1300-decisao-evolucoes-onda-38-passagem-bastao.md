---
titulo: Decisão do Arquiteto sobre as 10 propostas do doc 120 — Onda de evolução do protocolo (passagem de bastão entre IAs)
diataxis: onda
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
autoria: claude-opus-4-7 (modo ARQUITETO PRINCIPAL do protocolo useHBN — sessão Cowork 2026-05-27 ~13:00 BRT)
gatilho: Mauricio pediu nova onda do PROMPT_ARQUITETO focada em melhorar a passagem de bastão entre IAs, consumindo como input o doc auditoria/00_status/120_SUGESTOES_EVOLUCAO_PROTOCOLO_HBN.md
input: auditoria/00_status/120_SUGESTOES_EVOLUCAO_PROTOCOLO_HBN.md (10 propostas P1-P10 da Opus pós-auditoria cruzada Codex 0012 + Gemini/Antigravity 0011)
readback-associado: .hbn/readbacks/0112-evolucao-protocolo-onda38-passagem-bastao.json
status: PROPOSTO — aguardando hearback de Mauricio antes de qualquer edição do protocolo
---

# Decisão do Arquiteto — Onda de passagem de bastão

> Este documento é a **consolidação do arquiteto** (passo §3.1 / §7.3 do PROMPT_ARQUITETO) sobre as 10 propostas do doc 120. Ele **NÃO edita o protocolo**. Registra o veredito por proposta + o texto canônico que será aplicado **após hearback** via o readback 0112. Fiel à regra "nunca aplicar uma proposta no mesmo turno em que é proposta/consolidada" (§7.3 Restrições).

## 0. Resumo executivo

Das 10 propostas, **5 são o coração da passagem de bastão** (P1, P2, P4, P7, P8) e formam o pacote substantivo desta onda. P3 e P6 são higiene de processo de baixo risco (promovidas Tier 2). P5/L44 é uma lição de verificação real, promovida mas roteada para conhecimento (não é cadência de bastão). P9 fica em REFINAR — concordo com a própria Opus que precisa de teste empírico. P10 é promovida mas adiada para pós-freeze por dependência (PHAGOCYTOSIS).

**Não fui rubber-stamp**: rebaixei a rigidez de P1 ("um implementador para o ciclo inteiro" é um anti-padrão que recria a fadiga que o protocolo combate), apontei uma **colisão de nomenclatura real em P7** (o "P0" de auditoria colide com o "P0" de prioridade de proposta e com o "ADR P0" das proibições), e adicionei custo/mitigação a P2. Sinalizo abaixo onde concordei para que a convergência não vire 🔍 GROUPTHINK.

### Tabela-veredito

| # | Proposta | Status sugerido (Opus) | **Veredito do Arquiteto** | Destino canônico |
|---|---|---|---|---|
| P1 | Cadência D Estendida | TIER 1 | **PROMOVER TIER 1 — COM MODIFICAÇÃO** | PROMPT_ARQUITETO §12 + knowledge 0019 |
| P2 | Auditoria sempre em chat novo | TIER 1 | **PROMOVER TIER 1 — COM MITIGAÇÃO DE CUSTO** | PROMPT_ARQUITETO §12 + knowledge 0019 |
| P3 | Gates intra-onda | TIER 2 | **PROMOVER TIER 2** | PROMPT_ARQUITETO §12 (prática recomendada) |
| P4 | Anti-viés de auto-recomendação | TIER 1 | **PROMOVER TIER 1** | PROMPT_ARQUITETO §12 (checklist de bastão) |
| P5 | L44 — Explore diff cosmético | TIER 1 (em protocol-evolutions) | **PROMOVER — COMO CONHECIMENTO, NÃO COMO CADÊNCIA** | knowledge 0020 + cross-ref CLAUDE.md |
| P6 | Numeração consistente de proposals | TIER 2 | **PROMOVER TIER 2 — COM COMANDO CORRIGIDO** | PROMPT_ARQUITETO §12 + knowledge 0019 |
| P7 | Veto P0 do auditor | TIER 1 | **PROMOVER TIER 1 — RENOMEANDO A SEVERIDADE** | PROMPT_ARQUITETO §12 + knowledge 0019 |
| P8 | Template de output de auditoria | TIER 2 | **PROMOVER TIER 2** | PROMPT_ARQUITETO anexo (§12.A) |
| P9 | Auditoria curta p/ gates triviais | REFINAR | **REFINAR (concordo) — critério amarrado a P7** | não promove ainda; testar em 38.2.3 |
| P10 | Lições V206 → PHAGOCYTOSIS | TIER 2 (pós-freeze) | **PROMOVER TIER 2 — ADIADO PÓS-FREEZE** | onda futura; aloja L44/P5 |

---

## 1. Decisão sobre "Tier 1 = onde?" (resposta à pergunta aberta do doc 120 e à dúvida de Mauricio)

O doc 120 sugere "Tier 1 = incorporar em CLAUDE.md / AGENTS.md". **Discordo do destino, não do peso.** Justificativa:

`AGENTS.md` e `CLAUDE.md` do Credenciamento são a entrada canônica para uma IA que vai **mexer no código VBA daquele projeto**. As regras de cadência inter-IA (quem implementa, quem audita, em que contexto, com que veto) são **meta-protocolo transversal** — valem para Credenciamento, timelessphoto.art, MAURICIOZANIN-HUB e qualquer projeto futuro. Enterrá-las num arquivo de projeto recria exatamente o anti-padrão da "cópia divergente" diagnosticado em 2026-05-24 (§6 do PROMPT_ARQUITETO).

Por isso defino a seguinte regra de roteamento, coerente com como a v1.3 já foi feita (§7.3 nasceu no PROMPT_ARQUITETO + knowledge, não no AGENTS.md):

- **Tier 1 (regra dura)** → nova **§12 no `PROMPT_ARQUITETO_USEHBN_AUTONOMO.md`** (fonte da doutrina de operação multi-IA) **+ knowledge canônico `0019` no Credenciamento** (casa-mãe). O `AGENTS.md` recebe apenas **um ponteiro de uma linha** para o knowledge 0019 (discoverability), sem virar dono da regra.
- **Tier 2 (prática recomendada)** → texto na **§12 do PROMPT_ARQUITETO** marcado como "recomendado", sem knowledge dedicado.
- **Promoção futura ao canônico `usehbn/`** (Trilha E) acontece depois, quando a cadência tiver ≥ 2 ondas de uso real — não nesta onda.

Resultado prático: o meta-protocolo fica num lugar só, versionado, e cada projeto o herda via PROMPT_ARQUITETO + usehbn, nunca por cópia.

---

## 2. Veredito detalhado por proposta

### P1 — Cadência D Estendida → **PROMOVER TIER 1, COM MODIFICAÇÃO**

Concordo com a estrutura (1 implementador + 2 auditores cruzados em contexto novo + Mauricio como hearback/executor). A evidência é real (incidente de fadiga Opus a 90%/60% em sessões de 5h).

**Modificação obrigatória (divergência técnica):** a redação "1 implementador único por **ciclo de estabilização inteiro** (ex.: Codex para Ondas 38.2.3+38.2.4+38.2.5)" **recria o problema que a cadência quer resolver**. Se um implementador carrega o contexto de 3 ondas seguidas, ele fadiga — é o mesmo mecanismo do incidente Opus. Travar o papel "implementador" numa IA por várias ondas também cria *bus factor* (se o Codex empaca, o ciclo inteiro empaca).

Redação corrigida: **um implementador por onda**, com **continuidade preferencial** (a mesma IA segue enquanto estiver com contexto saudável, < 50%), mas com **handoff de implementador obrigatório entre ondas se o orçamento de contexto (knowledge 0017) for excedido** — e esse handoff de implementador também passa por chat novo + handoff escrito. Assim preservamos a economia de contexto (o implementador concentra o código) sem transformar "implementador único" num ponto único de fadiga/falha.

- **Risco**: mais elapsed time. **Mitigação**: aceitável para release público com risco alto de regressão (V206 corrompeu workbook).

### P2 — Auditoria cruzada SEMPRE em chat novo → **PROMOVER TIER 1, COM MITIGAÇÃO DE CUSTO**

Concordo integralmente com o princípio: auditor que "continua" o próprio chat está em modo executor, tem menos contexto livre e carrega viés de defender decisões prévias. Chat novo = olhar fresco.

**Mitigação que adiciono (custo de re-aquisição):** chat novo significa que o auditor precisa reler tudo do zero, o que custa contexto e tempo. Para que isso não estoure o orçamento do próprio auditor, a §12 padroniza um **"prompt de entrada de auditoria"** curto e estável que aponta para os paths canônicos (relay/INDEX, último ERP, readback da onda, diff alvo) — o auditor reconstrói o estado por `Read`, não por memória, e não precisa de um despejo gigante no chat. Registro também a honestidade técnica: chat novo **reduz**, mas não **elimina**, o viés de modelo (mesma família de pesos); por isso P2 anda de mãos dadas com P4 (declaração de viés) e com 2-3 auditores independentes.

### P3 — Gates intra-onda obrigatórios → **PROMOVER TIER 2**

Boa prática. A heurística 3-6 gates por onda é sensata. Mantenho como **recomendada** (não regra dura) porque o número ótimo de gates depende do tamanho real da onda — engessar como obrigatório arrisca micro-gestão nas ondas pequenas. Entra na §12 como guia de desenho de ondas. Observo que gates intra-onda **são** pontos de passagem de bastão (cada gate é um mini-handoff auditável), então a proposta pertence legitimamente a esta onda.

### P4 — Mitigar viés de auto-recomendação → **PROMOVER TIER 1**

Núcleo da passagem de bastão e a proposta com a evidência mais desconfortável/honesta (Codex, Antigravity e Opus, cada um, preservaram a própria relevância ao recomendar o bastão). Promovo como **checklist obrigatório de decisão de bastão** na §12: (1) declarar se há auto-indicação; (2) listar evidência objetiva, não opinião; (3) reconhecer o viés natural; (4) sugerir mitigação. Reforço a mitigação estrutural: **preferir 3 recomendadores independentes** para que os vieses se cancelem, e instruir Mauricio a **pesar evidência objetiva acima da auto-avaliação de qualquer IA**.

### P5 — L44 "Explore diff cosmético é suspeito" → **PROMOVER, MAS COMO CONHECIMENTO**

A lição é válida e a evidência é forte (o bug em `publicar_vba_import_v2.py:212-248` que truncava as declarações `WithEvents` foi classificado como "cosmético" pelo Explore agent e só o Codex, inspecionando o pipeline gerador, pegou). **Mas isto não é cadência de bastão** — é uma regra de verificação/delegação. Roteá-la para `.hbn/protocol-evolutions/` (como o doc 120 sugere) está errado: protocol-evolutions é a área de **propostas em trânsito**, não a casa canônica de uma lição. Promovo L44 para **`.hbn/knowledge/0020-explore-diff-cosmetico-suspeito.md`** + um cross-ref de uma linha no `CLAUDE.md` do Credenciamento ligando ao princípio "Never delegate understanding". Conteúdo técnico definitivo de VBA pode migrar para PHAGOCYTOSIS na P10 (pós-freeze).

### P6 — Numeração consistente de proposals → **PROMOVER TIER 2, COM COMANDO CORRIGIDO**

Higiene útil e barata. **Correção técnica:** o comando sugerido `ls .hbn/proposals/ | sort -n | tail -1` não extrai o número de forma confiável (ordena nomes, não números, e devolve o nome inteiro). Substituo por:

```
ls .hbn/proposals/ 2>/dev/null | grep -oE '^[0-9]{4}' | sort -n | tail -1
```

Regra: todo arquivo em `.hbn/proposals/` segue `NNNN-<ia>-<tema>.md` (4 dígitos, ordem cronológica). Próximo número livre **0013**. Entra na §12 + nota no knowledge 0019.

### P7 — Veto P0 do auditor → **PROMOVER TIER 1, RENOMEANDO A SEVERIDADE**

Concordo com o mecanismo: auditor cruzado pode marcar um achado como bloqueador e o implementador não prossegue até resolver; conflito bloqueador×bloqueador entre auditores → Mauricio decide. A evidência é boa (Codex levantou 3 achados bloqueadores no plano da Opus em 0012; sem veto formal, a autoridade arquitetural da Opus poderia ter sobrescrito).

**Colisão de nomenclatura real (divergência):** o protocolo já usa "P0" em **dois** sentidos — `prioridade_sugerida: P0|P1|P2|P3` no frontmatter de protocol-evolutions, e "ADR P0" / "P0 em HBN" nas proibições (§8 do AGENTS / §2 pré-flight). Introduzir "P0/P1/P2 de auditoria" por cima cria ambiguidade perigosa num protocolo que vive de precisão. Renomeio a severidade de auditoria para um vocabulário próprio e inconfundível:

- **BLOQUEADOR** (ex-"P0"): segurança, correção, regressão — implementador **não prossegue** até resolver.
- **FORTE** (ex-"P1"): qualidade/manutenibilidade — implementador incorpora **ou** justifica por escrito a não-incorporação.
- **MARGINAL** (ex-"P2"): nice-to-have (DRY, perf marginal) — implementador pode ignorar.

O veto vale para **BLOQUEADOR**. Isso preserva a força da proposta sem colidir com o vocabulário existente.

### P8 — Template padronizado de output de auditoria → **PROMOVER TIER 2**

Torna auditorias comparáveis entre IAs e ondas e dá ao implementador um lugar fixo para olhar. Promovo como **anexo §12.A** do PROMPT_ARQUITETO, com **as severidades já renomeadas conforme P7** (BLOQUEADOR/FORTE/MARGINAL em vez de P0/P1/P2). Mantenho as 8 seções da Opus (veredito, bloqueadores, fortes, marginais, convergências, divergências, riscos não cobertos, próxima ação).

### P9 — Auditoria curta para gates triviais → **REFINAR (concordo com a Opus)**

Não promover ainda. O risco de "trivial" virar porta dos fundos para erodir o rigor é real. **Critério afinado, amarrado a P7:** um gate só é elegível a auditoria curta (1 IA, < 1000 palavras) se o **máximo de severidade alcançável for MARGINAL** — ou seja, mudança isolada em 1-2 arquivos, sem impacto em runtime, reversão trivial. Default permanece **auditoria cruzada plena**; Mauricio decide ad-hoc. **Testar empiricamente na Onda 38.2.3** antes de promover.

### P10 — Lições V206 → PHAGOCYTOSIS-VBA-PATTERNS → **PROMOVER TIER 2, ADIADO PÓS-FREEZE**

Boa, mas não é passagem de bastão e depende de ondas que ainda não fecharam (38.2.4/38.2.5). Promovo como item de backlog para **onda documental pós-GATE-FREEZE**, que alojará L41/L43 (já candidatas) + L44 (P5, promovida aqui) + os padrões de helpers/macro descartável quando entregues. Não toca o pacote desta onda.

---

## 3. Texto canônico proposto (a aplicar SÓ após hearback)

> Blocos abaixo são o que o readback 0112 propõe escrever. Nada é aplicado neste turno.

### 3.A — Nova §12 do PROMPT_ARQUITETO_USEHBN_AUTONOMO.md (esqueleto)

```
## 12. Cadência D Estendida — passagem de bastão entre IAs

(P1) Papéis por ciclo de estabilização pré-release:
  - 1 IMPLEMENTADOR por onda (continuidade preferencial enquanto < 50% de
    contexto; handoff de implementador obrigatório entre ondas se o orçamento
    do knowledge 0017 estourar, com chat novo + handoff escrito).
  - 2 AUDITORES CRUZADOS em contexto novo a cada gate relevante.
  - Mauricio: hearback final + executor operacional (Excel, RVS).
  - Implementador NÃO audita o próprio trabalho. Auditores NÃO implementam.

(P2) Auditoria cruzada SEMPRE em chat novo. Anexo §12.B traz o "prompt de
  entrada de auditoria": aponta paths canônicos (relay/INDEX, último ERP,
  readback da onda, diff alvo); o auditor reconstrói estado por Read, não por
  memória. Chat novo reduz — não elimina — viés de modelo; por isso combina
  com P4 e com 2-3 auditores independentes.

(P3, recomendado) Gates intra-onda: dividir a onda em 3-6 sub-fases auditáveis
  por marco lógico (design / helpers / refactor / remoção). < 3 = monolítico;
  > 6 = micro-gestão.

(P4) Checklist anti-viés de decisão de bastão. Toda IA perguntada "a quem
  passar o bastão" DEVE: (1) declarar auto-indicação; (2) listar evidência
  objetiva; (3) reconhecer viés natural; (4) sugerir mitigação. Preferir 3
  recomendadores independentes; Mauricio pesa evidência acima de auto-avaliação.

(P7) Severidade de auditoria e veto:
  - BLOQUEADOR: segurança/correção/regressão — implementador NÃO prossegue.
  - FORTE: qualidade — incorpora OU justifica por escrito.
  - MARGINAL: nice-to-have — pode ignorar.
  Conflito BLOQUEADOR×BLOQUEADOR entre auditores → Mauricio decide (hearback).

(P6) Numeração: .hbn/proposals/ segue NNNN-<ia>-<tema>.md (4 dígitos,
  cronológico). Próximo livre via:
    ls .hbn/proposals/ | grep -oE '^[0-9]{4}' | sort -n | tail -1

(P9, EM TESTE — não vigente) Auditoria curta (1 IA, <1000 palavras) só se o
  máximo de severidade alcançável for MARGINAL. Default = cruzada plena.
```

### 3.B — Anexo §12.A: template de output de auditoria cruzada (P8)

```
# Auditoria cruzada — GATE-<ID> da Onda <N> — por <IA> (chat novo)
## 1. Veredito  (APROVAR / APROVAR com FORTE incorporados / BLOQUEAR)
## 2. BLOQUEADORES (impedem progresso) — descrição + evidência + remediação
## 3. FORTES (alta prioridade, não bloqueiam)
## 4. MARGINAIS (nice-to-have)
## 5. Convergências com o trabalho original
## 6. Divergências (argumento técnico)
## 7. Riscos não cobertos
## 8. Recomendação de próxima ação + checklist anti-viés (P4) se houver indicação de bastão
```

### 3.C — knowledge 0019 (Tier 1 canônico no Credenciamento) e 0020 (L44)

- `.hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md` — formaliza P1(mod), P2, P4, P6, P7 como regra permanente do projeto; ponteiro a partir do AGENTS.md.
- `.hbn/knowledge/0020-explore-diff-cosmetico-suspeito.md` — L44 (P5) + cross-ref no CLAUDE.md ("Never delegate understanding").

---

## 4. O que esta onda NÃO faz

- Não edita o protocolo neste turno (só após hearback de Mauricio).
- Não toca código de domínio (`src/vba/`, `local-ai/vba_import/`).
- Não consolida a decisão A vs B da Onda 38.2.2 nem abre a 38.2.3 (linha separada; ver handoff 20260527-0930).
- Não promove ainda P9 (REFINAR) nem aplica P10 (pós-freeze).
- Não migra nada para `usehbn/` canônico (Trilha E fica para depois de ≥ 2 ondas de uso da cadência).

## 5. Perguntas abertas para Mauricio (no hearback)

1. Aceita a **modificação de P1** (implementador por onda com handoff, em vez de implementador único por 3 ondas)? É a minha divergência mais relevante.
2. Aceita renomear a severidade de auditoria para **BLOQUEADOR / FORTE / MARGINAL** (P7), evitando a colisão com os vários "P0" já existentes?
3. Confirma o roteamento **meta-protocolo no PROMPT_ARQUITETO + knowledge 0019**, com AGENTS.md só apontando — em vez de gravar a cadência dentro do AGENTS.md como o doc 120 sugeria?

## 6. Sinal HBN

🔵 HBN HANDOFF READY — decisão consolidada; aguardando hearback de Mauricio em `.hbn/readbacks/0112-evolucao-protocolo-onda38-passagem-bastao.json` (human_status: confirmed) ou ajuste pedido.
