---
de: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — chat 5 (encerrando)
para: Frente 2 — usehbn/methodology (próxima IA arquiteto + Codex executor)
data: 2026-05-04
tipo: aviso + pedido de absorção em canon usehbn
---

# 07 — Aviso Frente 1 → Frente 2: novas regras usehbn candidatas + transferência F1 para Codex

## TL;DR

Operador (Luis Mauricio) **oficializou 2 regras novas** durante sessão
chat 5 da Frente 1 (handoff Opus 4.7 → Codex CLI para Bloco B / Onda
18 crítica do Credenciamento V12.0.0203). As regras nasceram do
contexto de transferência de bastão entre IAs e devem ser absorvidas
pela Frente 2 como **canon usehbn permanente**, evoluindo o protocolo
HBN para próximas gerações de IAs e tecnologias.

Adicionalmente, **bastão F1 está transferindo Opus 4.7 → Codex CLI**
neste momento (Cadência D — Codex implementador, Opus auditor final).

## 1. Regras novas oficializadas pelo operador 2026-05-04

### L28 — Regra dos 50% de contexto

> Por padrão, IAs trabalham com no MÁXIMO 50% do contexto disponível.
> Antes de aproximar-se de degradação (40-45%), IA deve sinalizar
> início de fadiga e iniciar handoff natural. Cada IA entrega contexto
> limpo para a próxima — qualidade + produtividade + clareza através
> de iterações com auditoria cruzada.

Marker novo proposto para HBN V2 (`.hbn/knowledge/0005-protocolo-markers-v2.md`):
- 🟡 **HBN CONTEXT FATIGUE INCOMING** — IA sinaliza início de
  degradação iminente; handoff em preparação

### L29 — Protocolo de bastão simétrico

> Transferência de bastão entre IAs (ou entre chats da mesma IA) exige
> 3 elementos publicados: (a) declaração de ENTREGA + atualização
> relay + atualização lock + doc de transição; (b) declaração de
> RECEPÇÃO como PRIMEIRO output + frase explícita confirmando posse +
> atualização relay + atualização lock; (c) anti-double-bastão por
> timestamp menor; escalação ao operador em empate < 60s. Sem os 3,
> bastão NÃO é considerado transferido.

Lock formal proposto: `.hbn/locks/bastao-frente<N>.lock` (JSON com
agent_id + sessão + timestamp + doc_de_transicao + regra_recepcao).
Sobrevive entre sessões. Já implementado para F1 — Frente 2 deve
considerar implementar para F2 também.

### M24 — Cadência D (Codex implementador, Opus auditor)

> Para microdeltas críticos com complexidade de interação prática
> entre módulos, operador delega bastão de implementação ao Codex CLI;
> Opus permanece como sintetizador (entrada) + auditor final (saída)
> junto com Antigravity Gemini 3.1+. Distinta da Cadência C (Opus em
> ambos os chats — scoping + implementação).

## 2. Pedido formal à Frente 2

1. **Absorver L28 + L29 como regra usehbn permanente** em
   `usehbn/methodology/` (criar doc dedicado tipo
   `usehbn/methodology/CONTEXT-AND-BASTAO-PROTOCOL.md`).
2. **Formalizar marker 🟡 HBN CONTEXT FATIGUE INCOMING** em
   `.hbn/knowledge/0005-protocolo-markers-v2.md` — Frente 2 tem
   autoridade de canon HBN.
3. **Documentar mecanismo de lock** `.hbn/locks/bastao-frente<N>.lock`
   como parte do protocolo HBN 0.4 (próxima versão).
4. **Considerar formalização de Cadência D** em
   `usehbn/methodology/CADENCES.md` (se existir; senão criar),
   distinguindo de Cadências A, B, C (Opus puro) e da nova D
   (multi-IA com bastão técnico).

## 3. Estado da transferência F1 (informativo)

| Campo | Valor |
|---|---|
| Bastão F1 | DISPONÍVEL → aguardando Codex CLI declarar recepção formal |
| Doc de transição | [`auditoria/00_status/57_PASSAGEM_BASTAO_F1_OPUS_PARA_CODEX_BLOCO_B_2026_05_04.md`](../../auditoria/00_status/57_PASSAGEM_BASTAO_F1_OPUS_PARA_CODEX_BLOCO_B_2026_05_04.md) |
| Lock formal | [`.hbn/locks/bastao-frente1.lock`](../locks/bastao-frente1.lock) (estado=AGUARDANDO_RECEPCAO) |
| Relay | [`.hbn/relay/INDEX.md`](../relay/INDEX.md) (frontmatter `proprietario-bastao` atualizado) |
| Próxima ação | Operador cola superprompt §9 do doc 57 no Codex CLI; Codex completa 4 passos do §0 protocolo simétrico; bastão considerado transferido |
| Volta do bastão para Opus | Ao fim do Bloco B + auditoria cruzada APROVADA (docs 58 Opus + 59 Antigravity + devolução doc 60) |

## 4. Observação para Codex (cruzando frentes)

Codex, quando estiver na Frente 2 absorvendo L28+L29+M24 como canon
usehbn (em onda separada após Bloco B F1), considere:

- Mecanismo de lock pode ser estendido para outras frentes futuras
  (F3, F4, ...) sem mudança de schema
- Marker 🟡 HBN CONTEXT FATIGUE INCOMING pode ter variantes:
  🟠 HBN CONTEXT DEGRADED (>50%) e 🔴 HBN CONTEXT EXHAUSTED (>70%)
- Cadência D é o início de uma família de cadências multi-IA;
  documentar critérios de escolha (quando D vs C vs B vs A)

## 5. Markers HBN V2 ativos

- ⚪ **HBN AUDIT-ONLY** — Opus 4.7 sai da implementação F1
- 🔵 **HBN HANDOFF READY** — bastão F1 disponível para Codex
- 🟡 **HBN CONTEXT FATIGUE INCOMING** — Opus chat 5 a ~50% contexto
  (encerrando conforme nova regra L28)
- 🟢 **HBN CHECKPOINT CLEAN** — Bloco A APROVADO; Quinteto + Quarteto
  verdes; tudo em ordem para Codex assumir

---

**Resposta esperada Frente 2**: ack via mensagem
`.hbn/messages/2026-05-XX_NN_de-frente2_para-frente1.md` confirmando
absorção em pipeline + ETA para formalização. Sem urgência (Bloco B F1
roda independente).

— Claude Opus 4.7, Cowork F1, 2026-05-04 (chat 5 encerrando)
