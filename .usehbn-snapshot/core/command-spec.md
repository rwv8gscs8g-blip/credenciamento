# Command Specification

## Command Identity

HBN uses three related command surfaces:

- semantic trigger: `usehbn`
- semantic trigger: `use hbn`
- operational CLI: `hbn`
- canonical semantic references: `usehbn.com` and `usehbn.org`

Matching of the semantic trigger is case-insensitive and may occur inside a longer sentence.

The domains are identity anchors and semantic references. Adapters and future integrations should normalize them to HBN protocol intent rather than treating them as plain URLs by default.

## Primary CLI Commands

The current local runtime exposes:

- `hbn version`
- `hbn init [--target <path>] [--runtime <auto|claude-code|codex|copilot|cursor>]`
- `hbn inspect [--target <path>]`
- `hbn install --runtime <runtime> [--target <path>] [--force]`
- `hbn refresh [--target <path>]`
- `hbn relay status [--target <path>]`
- `hbn handoff --to <agent_id> --summary <text> [--target <path>]`
- `hbn attention --mode <sound|flash|silent> [--target <path>]`
- `hbn attention --choice <a|b> [--target <path>]`
- `hbn notify --event <security_blocked_suggestion|human_decision> [--target <path>]`
- `hbn run "<sentence>"`
- `hbn readback <exec_id> ...`
- `hbn hearback [<exec_id>] --status <status> [--last]`
- `hbn result <exec_id> ... [--env-key key=value]`

`usehbn` remains available as a compatibility alias to the same CLI.

For runtime-contract refresh after a local HBN update:

- `hbn refresh --target <path>` refreshes all installed adapters at once
- `hbn install --runtime <runtime> --target <path> --force` refreshes a single adapter

## Relay Coordination

The relay layer tracks baton ownership between agents and the human:

- `hbn relay status` reports the current baton owner, active iterations, and last handoff record from `.hbn/relay/state.json`.
- `hbn handoff` validates that no pending readbacks exist with unresolved hearback, archives resolved relay files to `.hbn/relay-archive/`, updates `.hbn/relay/state.json`, and modifies `.hbn/relay/INDEX.md` with the new baton owner.
- Handoff is blocked if any readback in `.hbn/readbacks/` has `hearback_status: pending`. This prevents abandoning incomplete safety gates during agent transitions.

The relay state file (`.hbn/relay/state.json`) tracks:

- `baton_owner`: current agent or `human`
- `baton_since`: ISO 8601 timestamp
- `active_iterations`: list of active relay file names
- `pending_decisions`: count of outstanding human decisions
- `last_handoff`: record of the most recent baton transfer

## Execution Pipeline

The present HBN runtime follows this sequence:

1. `activation`
   The input is recognized as an HBN request.
2. `intent_capture`
   The request is normalized into objective, constraints, risks, and validation requirements.
3. `truth_barrier`
   Unsupported claims, overconfidence, and weak uncertainty handling are flagged.
4. `guardian`
   Validation gaps and risky output patterns are flagged.
5. `track_classification`
   Work is classified as `fast_track` or `safe_track`.
6. `readback`
   Safe-track work records understanding, invariants, and action plan before execution.
7. `hearback`
   Human confirmation or rejection is recorded.
8. `execution`
   The runtime produces structured output and local traces.
9. `erp_result`
   The final result record is linked to the execution and, when required, to the readback.

## Output Contract

`hbn run` returns structured JSON containing:

- activation status
- current stage
- intent object
- truth barrier result
- guardian result
- contribution consent protocol status
- validation summary
- execution metadata

The protocol subcommands also return structured JSON for readback, hearback, initialization, version, and ERP creation.

Runtime adapters should make HBN-governed cycles visibly distinct from ordinary assistant chatter by surfacing one of these markers early in the response:

- `✅ HBN ACTIVE`
- `❌ HBN SECURITY BLOCKED SUGGESTION`
- `🟡 HBN NEEDS HUMAN DECISION`

The preferred human-facing HBN section titles are:

- `🧠 Entendimento e Escopo`
- `🧭 Caminho Oficial`
- `🛠️ Ação Executada`
- `👨‍💻 Resultado DEV`
- `🚦 Aprovação ou Bloqueio`
- `➡️ Próximo Passo`
- `📝 Documentado em`

When a cycle requires human attention, the runtime may also emit a local non-intrusive alert:

- `sound`: terminal bell intended as a light leak/ping
- `flash`: visual terminal flash sequence when supported
- `silent`: no alert side effect

Human-facing shortcut:

- `Digite A para retirar o aviso sonoro ou digite B para apenas piscar a tela quando terminar.`

## Safety Constraints

- no hidden behavior
- no bypass of validation logic
- no background processing for consent capture
- safe-track ERP creation is blocked without confirmed hearback
- handoff is blocked when pending readbacks have unresolved hearback
- human review remains authoritative
