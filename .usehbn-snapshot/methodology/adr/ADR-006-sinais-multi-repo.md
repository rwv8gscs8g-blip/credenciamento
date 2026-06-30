---
adr-id: ADR-006
titulo: Sinais HBN multi-repo (🌐, ⛓️, 🧊, 🪞, 🟠)
status: ACCEPTED
data-deposito: 2026-05-09
data-ratificacao: 2026-05-10
autor: Claude Opus 4.7 (chat arquiteto-mestre useHBN)
cross-ia-required: Opus + Codex + Antigravity
hearback-status: ratificado por Mauricio 2026-05-10 (boletim em bloco)
prioridade: P1
ordem-cross-ia: após ADRs P0 ratificados
relacionado:
  - 00_BOOTSTRAP_PROTOCOLO_2026_05_09.md §4.6
  - doc 66 v2.0 (Credenciamento) §7.2, §11.3.2
  - ADR-001 (Quarta — usa ⏳ BILLING WINDOW DRIFT)
  - ADR-004 (SemVer — usa ⛓️ PROTOCOL DEP CHANGE)
  - ADR-008 (migração snapshot — usa 🪞 MIRROR DRIFT)
  - core/protocol.md (a atualizar)
  - agents/wave-protocol.md (a atualizar com seção de uso)
---

# ADR-006 — Sinais HBN multi-repo

## Status

**PROPOSED** — depende de ADR-001, ADR-004, ADR-008 ratificados (cada
um introduz pelo menos um sinal novo).

## Contexto

Os sinais HBN existentes em v0.3.0 cobrem operação **single-repo**
(✅ ACTIVE, 🟡 NEEDS HUMAN, ❌ SECURITY BLOCKED, 🔵 HANDOFF READY,
🟣 PEER REVIEW, ⚪ AUDIT-ONLY, 🔴 RELEASE BLOCKER, 🟢 CHECKPOINT CLEAN,
🟠 SOURCE DRIFT, 🟤 LICENSE SPLIT REQUIRED).

Operação multi-repo (useHBN + apps consumidoras + meta-relay) e janela
de faturamento (Quarta) exigem 5 sinais novos. Doc 66 v2.0 §7.2
propôs 4 deles; addendum 02 §C.2 introduziu o 5º (🟠 BILLING WINDOW
DRIFT).

## Decisão

Formalizar 6 sinais multi-repo (5 originais + 1 anti-groupthink, e
resolver colisão visual entre 🟠 SOURCE DRIFT já existente e
~~⏳ BILLING WINDOW DRIFT~~ proposto — agora ⏳):

| Sinal | Origem | Destino | Significado | Disparado por |
|---|---|---|---|---|
| 🌐 **HBN CROSS-REPO LOCK** | qualquer IA | todas | "estou tocando arquivos refletidos em outros repos; aguardar" | IA detecta concorrência potencial em arquivo refletido (ex.: `.usehbn-snapshot/` durante fetch) |
| ⛓️ **HBN PROTOCOL DEP CHANGE** | useHBN | apps consumidoras | "protocolo mudou de SemVer (MAJOR ou MINOR); revisão necessária" | Tag de release no useHBN com bump MAJOR ou MINOR (ADR-004 §1) |
| 🧊 **HBN APP FROZEN** | aplicação consumidora | useHBN + meta | "esta app está em janela de release; não tocar" | Aplicação entra em release window (ex.: Credenciamento V204 desde 2026-05-04) |
| 🪞 **HBN MIRROR DRIFT** | auditor cruzado | ambos | "protocolo canônico divergiu do consumido por X aplicação" | `hbn doctor --target <app>` detecta checksum mismatch entre `.usehbn-snapshot/PROTOCOL_SHA256.txt` e versão real do useHBN |
| ⏳ **HBN BILLING WINDOW DRIFT** | qualquer IA | operador | "janela de faturamento mudou; reajustar Quarta" | IA detecta que parâmetros da janela 12h BRT (ADR-001 §2) não correspondem ao ciclo Anthropic atual (mudança de plano, fuso, etc.) |
| 🔍 **HBN GROUPTHINK ALARM** | métrica de saúde | operador | "cross-IA convergindo demais (`cross_ia_divergencia_pct` < 10%); risco de viés de prompt ou groupthink" | `hbn doctor --health` detecta divergência cronicamente baixa entre IAs auditoras (insight Antigravity em ADR-007) |

### Convenções operacionais

1. **Posicionamento na resposta**: sinais HBN aparecem no início (estado
   atual) ou fim (transição de bastão) de cada turno significativo. Múltiplos
   sinais podem coexistir.

2. **Persistência**: sinais transitivos (ex.: ⛓️ HBN PROTOCOL DEP CHANGE)
   aparecem por 1 ciclo e somem após adoção. Sinais persistentes (ex.:
   🧊 HBN APP FROZEN) ficam ativos até a janela fechar.

3. **Conflito**: 🌐 HBN CROSS-REPO LOCK + 🧊 HBN APP FROZEN simultâneos
   sobre o mesmo arquivo = nenhum lado escreve. Operador decide qual
   tem precedência.

4. **Registro**: a primeira IA a emitir um sinal multi-repo registra em
   `.hbn/meta/signals-log.jsonl` (append-only). Schema:
   ```json
   {"signal": "🪞 HBN MIRROR DRIFT", "ts": "2026-...", "origin_repo": "...", "destination": "...", "context": "..."}
   ```

5. **Resolução**: cada sinal tem critério de resolução em ADR específico:
   - ⛓️ resolvido quando AGENTS.md da app atualiza `useHBN-version`.
   - 🧊 resolvido quando app finaliza release.
   - 🪞 resolvido quando snapshot é refetch via `bin/usehbn-fetch.sh`.
   - 🟠 resolvido quando ADR-001 ajusta parâmetros da janela.
   - 🌐 resolvido quando a operação concorrente termina.

### Atualizações documentais necessárias após ratificação

- `core/protocol.md` ou `modules/PROTOCOL-CONTRACT.md` (após ADR-003): seção "Marcadores HBN" passa de 10 para 16 sinais.
- `agents/wave-protocol.md`: seção nova "Sinais multi-repo" descreve uso.
- `src/usehbn/runtime.py` (`HBN_STATUS_MARKERS:54-58` + injeção em adapters `186-190`): atualizar de 3 → 16 marcadores. **Bloqueante segundo cross-IA Codex** (`0007-cross-ia-codex-ADR-006.json`).
- `src/usehbn/cli.py` (`run_init` `999-1077`): adicionar criação de `.hbn/meta/` para hospedar `signals-log.jsonl`.
- README seção "Convenções": cita os 6 novos.

### Schema mínimo para `.hbn/meta/signals-log.jsonl`

```jsonl
{"signal": "⏳ HBN BILLING WINDOW DRIFT", "ts": "2026-05-NNTHH:MM:SSZ", "origin_repo": "usehbn", "destination": "operator", "context": "<curto, ≤200 chars>"}
```

Campos obrigatórios: `signal` (string), `ts` (ISO-8601 UTC com `Z`),
`origin_repo` (slug), `destination` (slug ou "operator" / "all"),
`context` (string curta). Append-only; sem migração; um signal por linha.

## Consequências

**Positivas:**
- Coordenação multi-repo ganha vocabulário operacional.
- Auditores cruzados (Antigravity, Codex) podem parsear sinais para
  sincronizar bastão automaticamente.
- 🟤 HBN LICENSE SPLIT REQUIRED (já existente) ganha contraparte
  estrutural (🪞 MIRROR DRIFT) para outros tipos de divergência.

**Negativas:**
- Catálogo de sinais cresce de 10 → 15. Operador precisa internalizar.

## Riscos e mitigação

| # | Risco | Mitigação |
|---|---|---|
| R1 | Sinais multi-repo não detectados por IAs sem treinamento | Lista canônica em `agents/wave-protocol.md` é leitura obrigatória; runtime adapters incluem snippet com a lista |
| R2 | Sinais conflitantes (🌐 vs 🧊) sem resolução automática | Operador é tiebreaker (P5) |
| R3 | `.hbn/meta/signals-log.jsonl` crescer sem controle | Truncate baseado em métrica; ADR-007 monitora |

## Próximo passo

1. ADRs P0 + ADR-005 ratificados.
2. Cross-IA review por Codex (forma operacional, validação contra wave-protocol.md).
3. Hearback humano.
4. Status PROPOSED → ACCEPTED.
5. MD subsequente atualiza core/protocol.md, agents/wave-protocol.md, README.

## Versão

- v1.0 — 2026-05-09 — Opus 4.7 chat arquiteto-mestre — depósito inicial.
- v1.1 — 2026-05-10 — Opus 4.7 chat arquiteto-mestre — MD-J cross-IA. Ajustes: (a) trocar 🟠 BILLING WINDOW DRIFT por ⏳ resolvendo colisão visual com 🟠 SOURCE DRIFT (insight Codex); (b) adicionar 6º sinal 🔍 HBN GROUPTHINK ALARM proveniente de ADR-007 (insight Antigravity); (c) explicitar pontos de injeção em runtime.py + cli.py + ajuste de `.hbn/meta/`; (d) schema mínimo de `signals-log.jsonl`.
