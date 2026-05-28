---
titulo: L45 — Cross-Audit Output Lock (formalização operacional)
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
autoria: arquiteto USEHBN (micro ciclo L45, contexto fresco)
relaciona-se: .hbn/protocol-evolutions/20260527-2104-l45-auditoria-cross-output-lock.md (proposta inicial); .hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md (§12 Cadência D Estendida); .hbn/knowledge/0020-explore-diff-cosmetico-suspeito.md (L44)
escopo: regra operacional de coordenação inter-IA — NÃO toca código VBA
---

# L45 — Cross-Audit Output Lock (formalização operacional)

> Formaliza a regra L45 já esboçada em
> `.hbn/protocol-evolutions/20260527-2104-l45-auditoria-cross-output-lock.md`.
> Esta é a versão operacional reutilizável: diagnóstico do incidente, regra
> normativa, templates de disparo e de prompt por auditor, e plano de
> incorporação. Não altera código VBA nem reabre GATE-A2/GATE-A3; aplica-se à
> próxima rodada de auditoria cruzada da Cadência D Estendida.

---

## 1. Diagnóstico do incidente 0017 / 0018 / 0019

### O que aconteceu

No GATE-A2 da Onda 38.2.3, a auditoria cruzada (Cadência D Estendida §1: dois
auditores em contexto fresco) foi disparada com um prompt do implementador
(Codex) que **indicava os caminhos de saída por numeração explícita**: `0017`
para Opus e `0018` para Antigravity.

Sequência reconstruída a partir dos próprios artefatos:

1. `0017-opus-auditoria-gate-a2-onda-38-2-3.md` — Opus, 1ª passagem, contexto
   fresco. Veredito: **APROVAR** GATE-A2, residual = F-NEW6. 2 FORTES, 1 MARGINAL.
2. `0018-antigravity-auditoria-gate-a2-onda-38-2-3.md` — Antigravity, contexto
   fresco. Veredito: **APROVAR** GATE-A2, residual = F-NEW6. 2 FORTES, 1 MARGINAL.
   Convergente com 0017, inclusive na elevação de `CREDENCIADOS.ATIV_ID` a FORTE.
3. `0019-opus-reauditoria-gate-a2-onda-38-2-3.md` — Opus, **2ª passagem**.
   Cabeçalho declara explicitamente: *"Esta reauditoria não revoga 0017 nem
   0018 — soma 3 FORTES não capturados e um ajuste de severidade."* Reclassifica
   `CREDENCIADOS.ATIV_ID` de FORTE → MARGINAL (MARG-3), adiciona FORTE-1
   (write-side primária), FORTE-2 (`Repo_PreOS.Inserir:38` gêmeo dormente) e
   FORTE-3 (destino das linhas PRE_OS legadas).

### Causa-raiz da colisão

O `0019` **não estava planejado** no roteamento original (que reservava só
`0017` e `0018`). Quando uma 2ª passagem do Opus foi disparada, o caminho de
saída teve de ser improvisado em runtime: a IA encontrou `0017`/`0018` já
preenchidos e, corretamente, **recusou sobrescrever** (boa conduta defensiva),
mas a numeração `0019` foi escolhida pelo próprio auditor, sem reserva prévia.

O incidente **não** foi de conteúdo — as três auditorias são tecnicamente sólidas
e convergentes no veredito central. O incidente foi de **coordenação de
artefatos**:

- a numeração de proposals (knowledge 0019 §6) é cronológica e *first-come*, logo
  duas escritas concorrentes ou uma passagem extra não planejada competem pelo
  mesmo "próximo número livre";
- o prompt de disparo não declarava política de colisão nem distinguia
  "auditoria planejada" de "reauditoria adicional";
- o auditor teve de **escolher numeração** — exatamente o que a L45 quer proibir;
- resultado: consumo de coordenação humana (Mauricio teve de decidir o caminho
  do `0019` em runtime) e ambiguidade documental temporária sobre se `0019`
  substituía ou somava a `0017`/`0018` (resolvida só pelo cabeçalho explícito que
  o Opus teve a disciplina de escrever).

### Por que isso importa (princípio)

A Cadência D Estendida (knowledge 0019) depende de auditorias **independentes e
não destrutivas**: cada auditor reconstrói estado por `Read` e grava um artefato
único persistente. Se dois auditores podem mirar o mesmo arquivo, ou se um
auditor escolhe a própria numeração, a independência fica à mercê de timing e a
trilha de auditoria fica vulnerável a sobrescrita silenciosa — o oposto do que a
camada executável do HBN (contratos executáveis, Onda 36) busca garantir.

---

## 2. Regra L45 — formato reutilizável

**L45 (normativa).** Toda auditoria cruzada da Cadência D Estendida deve reservar
os caminhos de saída **antes do disparo**, com um prompt separado por auditor e
política de colisão explícita. Especificamente:

1. **Cada auditor recebe um prompt separado.** Nada de prompt compartilhado em
   que os auditores negociem destino entre si.
2. **Cada prompt contém exatamente um `output_path` reservado.** Um auditor,
   um arquivo, um caminho — declarado pelo implementador no momento do disparo.
3. **O auditor não escolhe numeração.** A numeração de proposals é
   responsabilidade do roteamento (audit request), não do auditor. O auditor
   nunca roda `ls .hbn/proposals | tail` para decidir onde escrever.
4. **Se o `output_path` já existir, o auditor responde `COLLISION` e para.**
   Não sobrescreve, não renomeia, não inventa `+1`. Resposta literal:
   `COLLISION: <output_path>` e aguarda novo caminho humano (ou usa o
   `fallback_path` somente se ele tiver sido pré-declarado no audit request).
5. **O consolidador não sobrescreve auditoria existente.** Quem consolida
   vereditos (implementador ou Mauricio) escreve em artefato próprio e referencia
   os de auditoria por caminho; jamais edita por cima de `0017`/`0018`/`0019`.
6. **O audit request reserva os paths antes do disparo.** A reserva é o primeiro
   passo: o implementador calcula os números livres, fixa um por auditor (e os
   `fallback_path` para passagens extras previsíveis, como reauditoria), e só
   então dispara os prompts.

Equivalência de severidade herdada de knowledge 0019 §5 (mantida intacta):
`BLOQUEADOR` (veto), `FORTE` (incorpora ou justifica), `MARGINAL` (nice-to-have).

> Nota de reauditoria: o incidente mostra que **passagens extras existem** (o
> `0019` foi legítimo e valioso). A L45 não as proíbe — exige que sejam
> **reservadas como `fallback_path` ou como novo audit request**, nunca
> improvisadas pelo auditor.

---

## 3. Template — "audit request" (reserva de paths antes do disparo)

Bloco de roteamento que o implementador produz **antes** de disparar qualquer
auditor. Recomenda-se persistir junto ao gate (ex.:
`.hbn/audits/<gate_id>-audit-request.yml`) para deixar trilha.

```yaml
audit_request:
  gate_id: GATE-A2                       # marco lógico sendo auditado
  onda: 38.2.3
  implementer_summary_path: .hbn/proposals/0016-codex-at2-diagnostico-fnew5.md
  target_ref: db54ffc                    # commit/artefato sob auditoria

  auditors:
    - role: opus
      output_path: .hbn/proposals/0017-opus-auditoria-gate-a2-onda-38-2-3.md
      fallback_path: .hbn/proposals/0019-opus-reauditoria-gate-a2-onda-38-2-3.md
    - role: antigravity
      output_path: .hbn/proposals/0018-antigravity-auditoria-gate-a2-onda-38-2-3.md
      fallback_path: null

  collision_policy: |
    Se output_path já existir, o auditor NÃO sobrescreve. Responde
    exatamente "COLLISION: <output_path>" e para. Usa fallback_path apenas se
    declarado acima; caso contrário aguarda novo caminho humano. Consolidador
    nunca escreve por cima de auditoria existente.

  expected_status_vocab: [BLOQUEADOR, FORTE, MARGINAL]   # NUNCA P0/P1/P2

  reserved_at: 2026-05-27T22:45:00-03:00
  reserved_by: implementador (Codex)
```

Regra de preenchimento dos números: `output_path` e `fallback_path` são
calculados **uma vez**, no momento da reserva, com
`ls .hbn/proposals/ | grep -oE '^[0-9]{4}' | sort -n | tail -1` + incremento.
Depois disso a numeração está **congelada** para aquele gate.

---

## 4. Template — prompt para auditor **Opus**

```text
✅ HBN ACTIVE — AUDITORIA CRUZADA <GATE_ID> / AUDITOR: OPUS (contexto fresco)

Você é auditor cruzado independente na Cadência D Estendida (knowledge 0019).
Raiz canônica: /Users/macbookpro/Projetos/Credenciamento
Branch: codex/v12-0-0206-planejamento

NÃO implemente. Reconstrua o estado SOMENTE por Read (nunca por memória).

OUTPUT LOCK (L45) — obrigatório:
- output_path reservado: <OPUS_OUTPUT_PATH>
- Antes de escrever, verifique se o arquivo já existe.
- Se existir: responda exatamente "COLLISION: <OPUS_OUTPUT_PATH>" e PARE.
- Você NÃO escolhe numeração. NÃO escreva no arquivo do outro auditor
  (<ANTIGRAVITY_OUTPUT_PATH>). NÃO sobrescreva nada.
- fallback_path (use só se instruído por novo prompt humano): <OPUS_FALLBACK_PATH | none>

Entradas obrigatórias (Read):
- implementer_summary_path: <IMPLEMENTER_SUMMARY_PATH>
- target_ref / artefatos: <TARGET_REF + CSVs/fontes relevantes>
- fontes de código pertinentes ao gate (liste o que efetivamente leu)

Produza UM relatório no template §12.A do PROMPT_ARQUITETO em <OPUS_OUTPUT_PATH>:
1. Veredito (APROVAR / MODIFICAR / REJEITAR o gate)
2. BLOQUEADORES (veto)
3. FORTES
4. MARGINAIS
5. Convergências
6. Divergências reais
7. Riscos não cobertos
8. Próxima ação + checklist anti-viés §12.4 (se houver passagem de bastão)

Vocabulário de severidade: BLOQUEADOR / FORTE / MARGINAL (NUNCA P0/P1/P2).
Toda conclusão deve ser reproduzida independentemente por leitura de fonte.
```

---

## 5. Template — prompt para auditor **Antigravity**

```text
✅ HBN ACTIVE — AUDITORIA CRUZADA <GATE_ID> / AUDITOR: ANTIGRAVITY (contexto fresco)

Você é auditor cruzado independente na Cadência D Estendida (knowledge 0019).
Raiz canônica: /Users/macbookpro/Projetos/Credenciamento
Branch: codex/v12-0-0206-planejamento

NÃO implemente. Reconstrua o estado SOMENTE por Read (nunca por memória).
Foco recomendado: validação sistêmica e integridade de tipos/representação de dados.

OUTPUT LOCK (L45) — obrigatório:
- output_path reservado: <ANTIGRAVITY_OUTPUT_PATH>
- Antes de escrever, verifique se o arquivo já existe.
- Se existir: responda exatamente "COLLISION: <ANTIGRAVITY_OUTPUT_PATH>" e PARE.
- Você NÃO escolhe numeração. NÃO escreva no arquivo do outro auditor
  (<OPUS_OUTPUT_PATH>). NÃO sobrescreva nada.
- fallback_path (use só se instruído por novo prompt humano): <ANTIGRAVITY_FALLBACK_PATH | none>

Entradas obrigatórias (Read):
- implementer_summary_path: <IMPLEMENTER_SUMMARY_PATH>
- target_ref / artefatos: <TARGET_REF + CSVs/fontes relevantes>
- fontes de código pertinentes ao gate (liste o que efetivamente leu)

Produza UM relatório no template §12.A do PROMPT_ARQUITETO em <ANTIGRAVITY_OUTPUT_PATH>:
1. Veredito (APROVAR / MODIFICAR / REJEITAR o gate)
2. BLOQUEADORES (veto)
3. FORTES
4. MARGINAIS
5. Convergências
6. Divergências reais
7. Riscos não cobertos
8. Próxima ação + checklist anti-viés §12.4 (se houver passagem de bastão)

Vocabulário de severidade: BLOQUEADOR / FORTE / MARGINAL (NUNCA P0/P1/P2).
Auditoria independente: não consulte nem espelhe o relatório do outro auditor
antes de fechar o seu.
```

---

## 6. Incorporação futura na base HBN (recomendação — NÃO editar agora)

Quais arquivos deveriam absorver a L45 depois desta formalização, e o quê em cada
um. Nenhuma edição é feita neste micro ciclo; isto é o backlog de incorporação:

1. **`.hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md`** — adicionar
   um item (ex.: §8 "Output lock de auditoria (L45)") com a regra normativa da
   §2 deste relatório. É o lar natural: a Cadência D Estendida já define a
   auditoria cruzada; a L45 é a disciplina de roteamento dela. Atualizar também a
   §6 (numeração) para dizer que o **audit request** reserva os números, não o
   auditor.
2. **`AGENTS.md`** — no ponteiro 9b (linha que cita knowledge 0019), acrescentar
   menção à L45 / output lock, mantendo o princípio "AGENTS.md aponta, não
   duplica".
3. **`PROMPT_ARQUITETO_USEHBN_AUTONOMO.md` §12** (doutrina transversal, fora deste
   repo) — incorporar os templates de §3/§4/§5 como sub-seções §12.A.1
   (audit request) e §12.B (prompt por auditor com output lock). Como o arquivo é
   externo, registrar aqui a recomendação para a próxima revisão (≥ v1.5).
4. **`.hbn/schemas/`** — opcional, mas recomendado: criar
   `audit-request.schema.json` para validar o bloco da §3, alinhado à filosofia
   de contratos executáveis (Onda 36). Permite que um guard futuro recuse disparo
   de auditoria sem paths reservados.
5. **`.hbn/protocol-evolutions/20260527-2104-l45-auditoria-cross-output-lock.md`**
   — marcar como *superseded-by* este arquivo (a proposta inicial foi promovida a
   formalização). Mera atualização de status/ponteiro.
6. **`scripts/hbn-guards/` (horizonte mais longo)** — eventual guard de
   pre-commit que recuse um proposal de auditoria cujo caminho não conste de um
   audit request reservado, fechando o ciclo executável. Anotar como item de
   roadmap, não obrigatório para vigência da L45.

---

## 7. Veredito final

**APROVAR a formalização da L45.**

A regra é de baixo custo, não toca código VBA, ataca uma causa-raiz real e
demonstrada (colisão de roteamento 0017/0018/0019), e é coerente com a camada
executável já existente (contratos executáveis, numeração cronológica de
proposals, Cadência D Estendida). Os templates são reutilizáveis e o vocabulário
de severidade permanece o canônico (BLOQUEADOR/FORTE/MARGINAL). A única ressalva
— não bloqueante — é que a incorporação nos arquivos da §6 deve ser feita em onda
própria, com readback/hearback, e não neste micro ciclo.

---

Arquiteto USEHBN · micro ciclo L45 · contexto fresco · sem toque em código VBA
