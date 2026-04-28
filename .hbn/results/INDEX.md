---
titulo: Results HBN — ERPs vinculados a readbacks
ultima-atualizacao: 2026-04-28
---

# Results HBN — Credenciamento

> Execution Result Records (ERPs) gerados apos hearback confirmado.
> Cada ERP referencia um readback em `.hbn/readbacks/`.

## Convencao

- Nomeacao: `0001-exec-Subject.json`, `0002-exec-Subject.json`, ...
- Schema (alinhado ao `result.schema.json` do `usehbn`):

```json
{
  "execution_id": "...",
  "agent_id": "...",
  "readback_id": "...",
  "action": "...",
  "outcome": "executed | executed_with_risk | rejected",
  "human_status": "confirmed | conditional | pending",
  "intent_risk_profile": "low | medium | high",
  "environment": { ... },
  "created_at": "..."
}
```

## ERPs atuais

| ID | Acao | Outcome | Readback | Data |
|---|---|---|---|---|
| (pendente — sera gerado ao fechar Onda 6) | — | — | `0001-onda06.json` | — |
