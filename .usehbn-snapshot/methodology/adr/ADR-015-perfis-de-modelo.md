---
adr-id: ADR-015
titulo: Perfis de capacidade por modelo — doutrina paramétrica em vez de números hard-coded
status: ACCEPTED
data-deposito: 2026-06-10
id-global: 20260610-24
autor: claude-fable-5 (arquiteto useHBN, corrente C7)
cross-ia-required: Opus + Codex (muda como a doutrina referencia limites de modelo — P10)
hearback-status: confirmado 2026-06-10 (readback 0001 / hearback 0001)
prioridade: P1
temperatura: quente
tier-desta-mudanca: T2 (normativo — ADR + schema; rito integral, per ADR-014)
aplica-a: canônico usehbn; Credenciamento recebe PROPOSTA via inbox/credenciamento/ (Q1 — nunca edição direta)
relacionado: [knowledge 0017 do Credenciamento (gatilho de handoff), core/cadence-d.md, agents/architect-autonomous.md §Fim de sessão, agents/role-templates.md, ADR-011 (tabela tipo→pasta), ADR-014 (tier T2)]
evidencia-motivadora: |
  Números de modelo hard-coded na doutrina hoje: core/cadence-d.md:20
  ("continuidade preferencial enquanto contexto <50%"),
  agents/architect-autonomous.md:71 ("## Fim de sessão (50% de contexto)"),
  agents/role-templates.md:58 ("A 50% de contexto (knowledge 0017): pare...").
  Esta sessão roda em claude-fable-5 com janela de 1M tokens (env:
  claude-fable-5[1m]) — o "50%" calibrado para janelas de ~200K significa
  aqui 500K tokens: a doutrina descalibra silenciosamente a cada geração de
  modelo, para mais ou para menos.
---

# ADR-015 — Perfis de capacidade por modelo

## O problema, em linguagem humana

A doutrina decorou os limites de UM modelo e os escreveu na pedra: "pare a
50%", "turnos > 30". São números corretos para a janela em que foram
calibrados — e silenciosamente errados para qualquer outra. Quando chega um
modelo de janela 1M (esta sessão), o protocolo manda parar com 500K tokens
livres; quando chegar um de janela curta, mandará continuar além do seguro.
A correção não é trocar 50 por outro número — é tirar o número da doutrina e
movê-lo para um PERFIL por modelo, versionado e schema-validado, que a
doutrina referencia. A doutrina diz "pare no threshold do perfil ativo"; o
perfil diz quanto é, e prova de onde tirou.

## Decisão 1 — Schema de perfil (`schemas/model-profile.schema.json`)

Campos: janela de contexto (nullable — desconhecido é declarável),
`handoff_threshold`, papéis aptos (vocabulário do state.schema), modos
disponíveis, mapa `verificado` campo→evidência (Truth Barrier) e lista
`nao_verificado` explícita. Duas regras duras embutidas no próprio schema:

1. **`handoff_threshold > 0.5` EXIGE `hearback_ref`** — relaxar o default
   conservador sem evidência de hearback é recusado mecanicamente na
   validação (if/then do JSON Schema). Apertar (<0.5) é livre.
2. **`context_window_tokens: null` EXIGE o campo listado em
   `nao_verificado`** — não saber é permitido; fingir saber, não.

## Decisão 2 — Perfis em `.hbn/models/` + tipo novo na tabela do ADR-011

Quatro perfis iniciais, preenchidos SÓ com o que os relays e o env desta
sessão evidenciam; todo o resto declarado `nao_verificado`:

| Perfil | Janela | Threshold | Papéis com evidência |
|---|---|---|---|
| `fable-5.json` | 1.000.000 (env 2026-06-10) | 0.5 (default) | auditor-arquiteto (C1–C7) |
| `opus-4-8.json` | null (não verificado) | 0.5 | auditor-cruzado, auditor-arquiteto (STATE 0177) |
| `codex.json` | null (não verificado) | 0.5 | implementador, consolidador (STATE 0177) |
| `gemini-3-5.json` | null (não verificado) | 0.5 | auditor-cruzado (proposal 0035) |

Extensão da tabela tipo→pasta do ADR-011 Decisão 2 (uma linha):

| Tipo | Pasta | Numeração | Temperatura default |
|---|---|---|---|
| profile | `.hbn/models/` | nome estável `<apelido>.json` (endereço, não evento — como spec core) | quente; ultrapassado via `superseded_by` |

Preencher um campo hoje `null` é mudança T2 (perfil é normativo): exige
evidência citável (doc oficial do fornecedor ou env de sessão) + hearback.
Memória de modelo NÃO é evidência.

## Decisão 3 — Doutrina referencia o perfil; default permanece 50%

Princípio: **nenhum documento normativo do canônico escreve número de
modelo; escreve "o `handoff_threshold` do perfil ativo (default 0.5)"**.
O modelo ativo da sessão identifica seu perfil em `.hbn/models/`; sem perfil
→ default integral (0.5). Gatilhos secundários (turnos >30, sinais
subjetivos de degradação — rede da knowledge 0017) permanecem ATIVOS sempre,
qualquer que seja o threshold: o perfil parametriza UM gatilho, não desliga
os outros.

Diffs canônicos a aplicar NA RATIFICAÇÃO deste ADR (não aplicados agora —
os três arquivos estão em hearback dos lotes C1/C4 e este ADR não atropela
lote alheio):

- `core/cadence-d.md:20`: `contexto <50%` → `contexto < handoff_threshold do
  perfil ativo (.hbn/models/, default 0.5 — ADR-015)`.
- `agents/architect-autonomous.md:71`: `## Fim de sessão (50% de contexto)` →
  `## Fim de sessão (handoff_threshold do perfil ativo; default 50% — ADR-015)`.
- `agents/role-templates.md:58`: idem, mantendo a referência à 0017.

## Decisão 4 — Credenciamento via inbox (Q1 intacto)

A knowledge 0017 e o §7 do contrato do projeto pertencem ao Credenciamento.
A proposta de torná-los paramétricos vai por
`inbox/credenciamento/20260610-01-0017-parametrica.md` (depósito desta
corrente) e SÓ entra no projeto por onda própria com hearback. Nenhuma linha
do projeto é editada por este ADR.

## Consequências

Positivas: a doutrina sobrevive à troca de geração de modelos sem reescrita;
o relaxamento de limite ganha trava mecânica (schema exige hearback_ref);
"o que este modelo pode?" vira consulta a um JSON validado em vez de
folclore de relay; a lista `nao_verificado` transforma ignorância em estado
declarado. Negativas: mais quatro arquivos para manter (mitigado: perfil só
muda quando há evidência nova, e mudar é T2); risco de perfil desatualizado
governando (mitigado: default conservador quando em dúvida + gatilhos
secundários sempre ativos).

## DONE-check

Os 4 perfis validam contra `schemas/model-profile.schema.json` (validação
executada na corrente C7, evidência no chat); a proposta 0017-paramétrica
existe no inbox e NÃO no projeto; nenhum número novo entrou na doutrina —
só referências ao perfil ativo com default 0.5.

## Versão

- v1.0 — 2026-06-10 — claude-fable-5, corrente C7 — depósito inicial (PROPOSED).
