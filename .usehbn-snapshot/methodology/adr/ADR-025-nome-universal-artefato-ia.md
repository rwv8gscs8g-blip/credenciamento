---
adr-id: ADR-025
titulo: Nome universal de artefato de IA — AAAAMMDD-HHMMSS-<agente>-<slug>, incondicional para séries de evento
status: PROPOSED
data-deposito: 2026-06-11
id-global: 20260611-155515-fable5-adr-nome-universal
path: methodology/adr/ADR-025-nome-universal-artefato-ia.md
autor: claude-fable-5 (desenho na consolidação 20260611-131311; depósito pelo implementador da onda 0006, item I-02)
cross-ia-required: Codex + Antigravity (autor Anthropic não audita — ADR-018; cross-audit da onda 0006 cobre)
hearback-status: pendente (adoção = hearback humano da onda 0006, item a item)
prioridade: P0 (F-03 do cross-audit 0036/0037, elevado a BLOQUEADOR pelo humano)
temperatura: quente
tier-desta-mudanca: T2 (normativo — ADR + G-NUM/G-SLF/G-REG/.gitignore na mesma onda, sem vácuo de enforcement)
aplica-a: todos os projetos sob o protocolo
relacionado: [ADR-011 (endereçamento; Decisão 1 parcialmente revogada para séries de evento), ADR-024 (Decisão 5; a condicionalidade D5.1 é revogada), ADR-015 (apelidos de perfil), guards/assert-parallel-id.sh (G-NUM), guards/assert-self-path.sh, guards/assert-registry-line.sh]
evidencia-motivadora: |
  F-03 (BLOQUEADOR, elevado pelo humano): os pareceres 0036/0037 nasceram
  com nome SERIAL por instrução do próprio prompt do consolidador, porque
  duas regras coexistiam — ADR-011 D1 (AAAAMMDD-NN serial) e ADR-024 D5
  (carimbo SÓ em escrita paralela declarada). Regra ambígua ou concorrente
  vence pela plausibilidade: com 35 precedentes seriais no REGISTRY, o
  modelo escolhe o formato mais parecido com o passado (consolidação
  20260611-131310, causa mecânica nº 1). Duas regras = nenhuma regra.
---

# ADR-025 — Nome universal de artefato de IA

## O problema, em linguagem humana

Um artefato de EVENTO (parecer, proposta, mensagem, relatório, prompt) é um
fato no tempo: quem o nomeia por sequência serial precisa consultar um
contador, e dois escritores no mesmo dia colidem (0014×0014; 0001×0001). A
regra do carimbo já existia (ADR-024 D5), mas CONDICIONADA a "escrita
paralela declarada" — e toda condição é uma porta: o ciclo que se declara
serial volta ao formato velho. Esta decisão remove a condição.

## Decisão 1 — Nome incondicional para séries de EVENTO

TODO artefato de evento criado por IA em `.hbn/proposals/`,
`.hbn/results/`, `.hbn/messages/`, `reports/` e `docs/prompts/` nasce:

```
AAAAMMDD-HHMMSS-<agente>-<slug>.<ext>
```

SEMPRE — sem condição de ciclo (revoga a condicionalidade do ADR-024 D5.1;
ciclo serial ou paralelo, tanto faz). `<agente>` é o apelido de perfil
ADR-015 (`.hbn/models/*.json`) ou apelido declarado na `atribuicao` do
STATE. O carimbo é REAL (`TZ=<tz-do-operador> date '+%Y%m%d-%H%M%S'`) e o
`created_at` da linha do REGISTRY deriva do MESMO carimbo (G-NUM regra 2).

## Decisão 2 — Séries-ENDEREÇO intactas; relógio único

1. Séries-endereço continuam estáveis (ADR-024 D5.2): `ADR-NNN`,
   `.hbn/knowledge/NNNN`, `.hbn/readbacks/NNNN`, `.hbn/hearbacks/NNNN`,
   `core/*.md` e demais nomes-endereço. Endereço não é evento.
2. **Relógio único**: todo timestamp de artefato governado (id, created_at,
   reviewed_at) usa a hora LOCAL do operador com offset explícito
   (`-03:00`). **UTC é proibido** em artefato governado (F-02: o 0035
   nasceu com reviewed_at em `Z` e divergiu do REGISTRY).

## Decisão 3 — Enforcement na MESMA onda (sem vácuo)

- **G-NUM regra 1 vira incondicional** para as séries de evento da Decisão 1:
  nome serial NOVO nessas séries = BLOCK citando este ADR; `<agente>`
  desconhecido (fora de `.hbn/models/` + atribuição do STATE staged) = BLOCK.
- **G-NUM regra 2**: `created_at` com sufixo `Z`/UTC em linha nova do
  REGISTRY = BLOCK.
- **G-SLF/G-REG**: padrões aceitam AMBOS os formatos para LER legado
  (`NNNN`/`AAAAMMDD-NN` são só-leitura); artefato NOVO em série de evento
  exige o carimbo e paga linha no REGISTRY.
- **`.gitignore`**: a exceção de `.hbn/results/` cobre o formato novo
  (parecer novo não pode ficar invisível ao git).
- Legado COMMITADO (0001..0035 etc.) NÃO se renomeia — nunca (ADR-011 D5).
  Artefato untracked não é história: renomeia antes do primeiro commit
  (caso vivo: 0036/0037, item I-04 da onda 0006).

## Decisão 4 — Zona de corte (proposta; execução é onda própria)

Corte em `2026-06-11T00:00:00-03:00`: artefato de EVENTO anterior ao corte
que ainda governa ou é NORMALIZADO (front-matter/linha REGISTRY conformes)
ou desce ao módulo `glacier/` com `superseded_by`/`temperatura: frio` no
REGISTRY. Glacier NUNCA entra em read-list, template ou prompt. Desenho
completo: proposta `fable5-proposta-glacier-zona-de-corte` (entregas da
onda 0006, fora do repo até hearback) — execução SÓ após auditoria
adversarial e hearback humano.

## Consequências

Positivas: UMA regra de nome para evento, sem condição — a causa mecânica
nº 1 do descumprimento (regra concorrente) morre; colisão impossível por
construção; ordem temporal legível no próprio nome. Negativas: nomes mais
longos; séries de evento ficam com dois formatos visuais (legado serial
preservado + carimbo novo) — custo aceito para não reescrever história.

## DONE-check

`bash guards/tests/run-guard-tests.sh` verde com os casos: serial novo em
results → BLOCK; agente desconhecido → BLOCK; UTC em created_at → BLOCK;
legado serial modificado (não-adicionado) → PASS. `git check-ignore`
prova que parecer novo no formato carimbo é rastreado.

## Versão

- v1.0 — 2026-06-11 — depósito inicial (PROPOSED) na onda 0006 (I-02).
