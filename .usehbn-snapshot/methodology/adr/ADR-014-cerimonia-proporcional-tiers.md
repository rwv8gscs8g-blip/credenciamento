---
adr-id: ADR-014
titulo: Cerimônia proporcional ao risco — tiers T0–T3 com rito mínimo por tier e guard de path
status: ACCEPTED
data-deposito: 2026-06-10
id-global: 20260610-23
autor: claude-fable-5 (arquiteto useHBN, corrente C6)
cross-ia-required: Opus + Codex (muda o rito operacional — P10)
hearback-status: confirmado 2026-06-10 (readback 0001 / hearback 0001)
prioridade: P0
temperatura: quente
tier-desta-mudanca: T2 (normativo — ADR; rito integral readback→hearback, dogfood da própria regra)
aplica-a: canônico usehbn (projetos adotam via onda própria; proposta segue via inbox)
relacionado: [ADR-013 (classes A/B — este ADR refina a fronteira), ADR-010 (executor T1), ADR-011 (REGISTRY = audit do T1), knowledge 0022 (firewall — IMUTÁVEL), guards/ (C3)]
evidencia-motivadora: |
  ADR-013 já mediu o sintoma: "itens de faxina pendentes há semanas (A4, F4)
  porque custam o mesmo rito de um ADR". A classe A do ADR-013 resolveu METADE
  do problema (deu trilho barato à manutenção mecânica), mas a fronteira ainda
  é binária: ou é faxina (A) ou paga rito integral (B). Não existe degrau para
  "leitura pura" (hoje paga zero, mas sem declaração disso) nem distinção entre
  doc frio e contrato normativo dentro da classe B. Resultado: cerimônia
  uniforme onde o risco não é uniforme.
---

# ADR-014 — Cerimônia proporcional ao risco: tiers T0–T3

## O problema, em linguagem humana

O protocolo cobra hoje quase o mesmo pedágio para renumerar um índice e para
mudar um schema que governa todos os projetos. Cerimônia cara demais para o
barato gera fila (faxina apodrece); cerimônia barata demais para o caro gera
incidente (por isso existem o firewall 0022 e os guards). Este ADR substitui
o pedágio único por quatro degraus — e dá a um guard de path o trabalho de
dizer, mecanicamente, em qual degrau cada mudança está. Na dúvida, o degrau
de cima: errar para o lado caro custa minutos; errar para o lado barato
custa um incidente.

## Decisão 1 — Quatro tiers, rito mínimo por tier

| Tier | O que é | Rito mínimo | Exemplos |
|---|---|---|---|
| **T0** | Leitura/análise — nenhuma escrita em artefato governado | Nenhum artefato além do output do chat | retomada, dry-run, parecer verbal, grep no archive |
| **T1** | Doc não-normativo / protocolo frio — manutenção mecânica | 1 commit atômico + 1 linha de audit (JSONL do autoevolve OU linha do REGISTRY no mesmo commit) | índice, REGISTRY, CHANGELOG, faxina, arquivamento, triagem de inbox (flip de temperatura), `.hbn/queue/` |
| **T2** | Normativo — muda contrato que outros obedecem | Readback → hearback confirmado → execução | schema, guard, ADR, knowledge, spec core (`core/`, `agents/`), perfil de modelo, workflow CI |
| **T3** | Código de domínio de projeto consumidor | Cerimônia plena atual; **humano aplica** (IA propõe diff, nunca commita) | VBA do Credenciamento, qualquer `src/` de app consumidora |

Regras transversais:

- **Tier do commit = tier do path mais alto tocado.** Um commit que toca
  REGISTRY (T1) e um schema (T2) é um commit T2 inteiro.
- **Na dúvida, promove ao tier acima.** Path não mapeado = T2 por default.
- **T0 não é licença para silêncio**: se a leitura gera conclusão que governa
  algo, a conclusão vira artefato (e aí paga o tier do artefato).

## Decisão 2 — Amarração ao ADR-013 (classes A/B ⊆ tiers)

O ADR-013 definiu QUEM executa e COM QUE freios (classe A = motor autoevolve
com rampa/lote/HUMAN_GATE; classe B = rito integral). Este ADR define QUANTO
rito cada path paga. A costura é de subconjunto:

- **classe A ⊆ T1** — tudo que o motor autoevolve pode tocar é T1 por
  definição; um item de fila que caia em path T2/T3 é automaticamente
  promovido a classe B (consistente com o orçamento de diff do ADR-013, que
  já promovia por tamanho; agora promove-se também por path).
- **classe B ⊆ T2 ∪ T3** — toda mudança normativa é T2; se tocar domínio de
  projeto, é T3.
- `human_gate: true` num arquivo (trava unilateral do ADR-013) promove o
  arquivo a T2 no mínimo, para sempre.

## Decisão 3 — T3 e firewall 0022 são IMUTÁVEIS

Declaração explícita, sem ambiguidade: **nenhuma evolução futura de tier pode
rebaixar T3 nem afrouxar o firewall 0022**. Código de domínio é sempre
cerimônia plena com aplicação humana; workflows continuam fast_track-only.
Um ADR futuro que proponha relaxar isto é inválido por construção (mesma
classe de imutabilidade da raiz canônica nos guards — "nunca, nem com
bypass"). Este parágrafo é a âncora que o guard de tier cita ao bloquear.

## Decisão 4 — Guard de tier (especificação; implantação é onda própria)

`guards/assert-tier-rito.sh` — entra no runner após `assert-scope-lock`.
Tabela path→tier em `.hbn/tier-map.txt` (uma linha por regra: `<glob> <tier>`;
primeira que casa vence; sem match = T2). Conteúdo inicial:

```text
methodology/adr/**      T2
schemas/**              T2
guards/**               T2
core/**                 T2
agents/**               T2
.hbn/knowledge/**       T2
.hbn/models/**          T2
.github/workflows/**    T2
src/**                  T2
tests/**                T2
REGISTRY.md             T1
CHANGELOG.md            T1
docs/**                 T1
reports/**              T1
inbox/**                T1
.hbn/queue/**           T1
.hbn/autoevolve/**      T1
.hbn/relay/**           T1
*.vba                   T3
*.bas                   T3
*.cls                   T3
```

Lógica (mesmo padrão dos guards C3 — bash puro, staged no pre-commit,
`HBN_DIFF_BASE...HEAD` em CI via `guard_diff_files()`):

```bash
#!/usr/bin/env bash
# assert-tier-rito.sh — BLOQUEIA commit cujo rito não cobre o tier dos paths
set -euo pipefail
. "$(dirname "$0")/lib/common.sh"
fail() { echo "GUARD-TIER: $1" >&2; exit 1; }

MAX=T0
for f in $(guard_diff_files); do
  t=$(tier_of "$f")              # consulta .hbn/tier-map.txt; sem match => T2
  [ "$t" \> "$MAX" ] && MAX=$t   # T0<T1<T2<T3 (ordem lexicográfica serve)
done

case "$MAX" in
  T0) exit 0 ;;
  T1) # exige 1 linha de audit no MESMO commit: REGISTRY ou JSONL do autoevolve
      guard_diff_files | grep -qE '^(REGISTRY\.md|\.hbn/autoevolve/.*\.jsonl)$' \
        || fail "commit T1 sem linha de audit (REGISTRY ou JSONL) no mesmo commit" ;;
  T2) # exige referência a readback: trailer HBN-Readback: <path> na mensagem,
      # e o path referenciado precisa existir
      RB=$(git log -1 --format=%B 2>/dev/null | awk -F': ' '/^HBN-Readback:/{print $2}')
      [ -n "${RB:-}" ] || fail "commit T2 sem trailer HBN-Readback (readback→hearback é o rito mínimo)"
      [ -f "$RB" ] || fail "readback referenciado não existe: $RB" ;;
  T3) fail "path T3 (código de domínio) em commit de IA — cerimônia plena, HUMANO aplica (ADR-014 Decisão 3, imutável)" ;;
esac
exit 0
```

Limites honestos da mecânica: o guard verifica a EXISTÊNCIA do readback, não
a qualidade do hearback — o hearback continua sendo confirmação humana no
chat, registrada em `.hbn/hearbacks/` (schema C3). Conforme knowledge 0021:
informativo em sandbox, conclusivo no Terminal do operador, terceiro ponto no
Shield (CI).

## Consequências

Positivas: faxina T1 flui sem fila; o rito caro concentra-se onde o contrato
mora; "qual rito esta mudança paga?" vira consulta O(1) a uma tabela; a
fronteira A/B do ADR-013 ganha definição mecânica por path (menos julgamento,
menos viés). Negativas: mais uma tabela para manter (mitigado: ela mesma é
T2 — mudá-la paga readback+hearback; e o default promove, nunca rebaixa);
o trailer `HBN-Readback:` é disciplina nova de mensagem de commit (mitigado:
o guard recusa cedo, no pre-commit).

## DONE-check

Dado um path qualquer, a tabela da Decisão 4 (ou o default T2) responde o
rito mínimo em uma consulta; T3 e firewall 0022 estão declarados IMUTÁVEIS
na Decisão 3; classe A ⊆ T1 e classe B ⊆ T2∪T3 amarradas na Decisão 2.

## Versão

- v1.0 — 2026-06-10 — claude-fable-5, corrente C6 — depósito inicial (PROPOSED).
