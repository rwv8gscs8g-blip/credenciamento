---
titulo: Results HBN — ERPs vinculados a readbacks
ultima-atualizacao: 2026-05-04
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
| 0013 | Onda 17 test-first + Quinteto + IntegridadeBase | APROVADO_OPERADOR | `0013-onda17-test-first.json` | 2026-05-04 |
| 0020 | Onda 18 MD-18.1a schema DT_ULT_REATIV | APROVADO_OPERADOR | `0020-onda18-md18-1a-schema.json` | 2026-05-04 |
| 0021 | Onda 18 MD-18.1b janela strikes pos-reativacao | APROVADO_OPERADOR | `0021-onda18-md18-1b-reativ-strikes.json` | 2026-05-04 |
| 0022 | Onda 18 MD-18.3 RPT_BUGS_RESOLVIDOS | APROVADO_OPERADOR | `0022-onda18-md18-3-rpt-bugs-resolvidos.json` | 2026-05-04 |
| 0023 | Onda 18 MD-18.2 statusbar hint treinamento | APROVADO_OPERADOR | `0023-onda18-md18-2-statusbar-hint.json` | 2026-05-04 |
| 0024 | MD-17.5 fechamento conjunto Onda 17+18 rc3 | APROVADO_OPERADOR | `0024-onda17-18-fechamento-rc3.json` | 2026-05-04 |
| 0026 | MICRO30-fix1 ClassificaEmpresa coluna U / R1 final rc4 | APROVADO_OPERADOR | `0026-onda18-micro30-fix1-classifica-empresa-u.json` | 2026-05-04 |
| 0027 | Onda 19 publicacao V203 rc4, treinamento e auditoria V204 | APROVADO_OPERADOR | `0027-onda19-publicacao-v203-treinamento-auditoria-v204.json` | 2026-05-04 |
