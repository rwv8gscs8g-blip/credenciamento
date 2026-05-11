---
titulo: Results HBN — ERPs vinculados a readbacks
ultima-atualizacao: 2026-05-11
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
| 0028 | Roadmaps V204 pos-auditorias cruzadas 64/65 | APROVADO_OPERADOR | `0028-onda20-roadmaps-v204-pos-auditorias.json` | 2026-05-05 |
| 0029 | Onda 20 V204 P0 UI MICRO31 | APROVADO_OPERADOR | `0029-onda20-v204-p0-ui-micro31.json` | 2026-05-05 |
| 0030 | Onda 21 V204 MICRO32 status empresa estruturado | APROVADO_OPERADOR | `0030-onda21-v204-transacional-micro32.json` | 2026-05-05 |
| 0031 | Onda 21 V204 MICRO33 AvaliarOS propaga falhas | APROVADO_OPERADOR | `0031-onda21-v204-avaliaros-micro33.json` | 2026-05-05 |
| 0032 | Onda 21 V204 MICRO34 ContarStrikes resultado explicito | APROVADO_OPERADOR | `0032-onda21-v204-contarstrikes-micro34.json` | 2026-05-05 |
| 0033 | Onda 21 V204 MICRO35 EmitirOS rollback local | SUPERSEDED_BY_0036 | `0033-onda21-v204-emitir-os-micro35.json` | 2026-05-05 |
| 0034 | Onda 21 V204 MICRO35-fix1 compilacao Repo_OS | SUPERSEDED_BY_0036 | `0034-onda21-v204-emitir-os-micro35-fix1.json` | 2026-05-05 |
| 0035 | Onda 21 V204 MICRO35-fix2 RepoOS_BuscarPorId | SUPERSEDED_BY_0036 | `0035-onda21-v204-emitir-os-micro35-fix2.json` | 2026-05-05 |
| 0036 | Onda 21 V204 MICRO35-fix3 pacote cumulativo Svc_OS | APROVADO_OPERADOR | `0036-onda21-v204-emitir-os-micro35-fix3.json` | 2026-05-05 |
| 0037 | Onda 21 V204 MICRO36 transacao aninhada | APROVADO_OPERADOR | `0037-onda21-v204-transacao-aninhada-micro36.json` | 2026-05-06 |
| 0038 | Onda 22 preflight higiene documental e Onda 26 | APROVADO_OPERADOR | `0038-onda22-preflight-higiene-documental.json` | 2026-05-06 |
| 0039 | Onda 22 V204 MICRO37 backfill DT_ULT_REATIV | APROVADO_OPERADOR | `0039-onda22-md22-1-backfill-dt-ult-reativ-micro37.json` | 2026-05-06 |
| 0040 | Onda 22 V204 MICRO38 ref orfa CAD_OS | APROVADO_OPERADOR | `0040-onda22-md22-2-ref-orfa-cad-os-micro38.json` | 2026-05-06 |
| 0041 | Onda 22 V204 MICRO39 DT_ULT_REATIV invalida | REPROVADO_OPERADOR | `0041-onda22-md22-3-dt-ult-reativ-invalida-micro39.json` | 2026-05-06 |
| 0042 | Onda 22 V204 MICRO39-fix1 Smoke MIG_007 | APROVADO_OPERADOR | `0042-onda22-md22-3-dt-ult-reativ-invalida-micro39-fix1.json` | 2026-05-07 |
| 0043 | Onda 22 V204 MICRO40 bordas temporais strikes | APROVADO_OPERADOR | `0043-onda22-md22-4-bordas-temporais-strikes-micro40.json` | 2026-05-07 |
| 0044 | Onda 23 V204 MICRO41 Adversarial UI read-only | APROVADO_OPERADOR | `0044-onda23-md23-1-adversarial-ui-micro41.json` | 2026-05-07 |
| 0045 | Onda 23 V204 MICRO42 Transacao Interrupt | APROVADO_OPERADOR | `0045-onda23-md23-2-transacao-interrupt-micro42.json` | 2026-05-07 |
| 0046 | Onda 23 V204 MICRO43 Boundary Dates | APROVADO_OPERADOR | `0046-onda23-md23-3-boundary-dates-micro43.json` | 2026-05-09 |
| 0047 | Onda 23 V204 MICRO44 Matriz Rastreabilidade | ENTREGUE_DOC_REVIEW | `0047-onda23-md23-4-matriz-rastreabilidade-micro44.json` | 2026-05-09 |
| 0048 | Onda 23 V204 MICRO45 Sexteto Gate | APROVADO_OPERADOR | `0048-onda23-md23-5-sexteto-gate-micro45.json` | 2026-05-09 |
| 0049 | Onda 24 V204 MICRO46 Limpar_Base seguro | APROVADO_OPERADOR | `0049-onda24-md24-1-limpar-base-seguro-micro46.json` | 2026-05-09 |
| 0050 | Onda 24 V204 MICRO47 Config invalida auditavel | APROVADO_OPERADOR | `0050-onda24-md24-2-config-invalida-micro47.json` | 2026-05-09 |
| 0051 | Onda 24 V204 MICRO48 Avaliacao dual-counter | APROVADO_OPERADOR | `0051-onda24-md24-3-avaliacao-dual-counter-micro48.json` | 2026-05-09 |
| 0052 | Onda 24 V204 MICRO49 SelecionarEmpresa com wrapper publico | REPROVADO_OPERADOR_COMPILE_CRASH | `0052-onda24-md24-4-selecionar-com-efeitos-micro49.json` | 2026-05-09 |
| 0053 | Onda 24 V204 MICRO49-fix1 SelecionarEmpresa sem wrapper publico | REPROVADO_OPERADOR_COMPILE_CRASH | `0053-onda24-md24-4-selecionar-com-efeitos-micro49-fix1.json` | 2026-05-09 |
| 0054 | Onda 24 V204 MICRO49-fix2 estabiliza Smoke 33 | REPROVADO_OPERADOR_BUILD_STALE | `0054-onda24-md24-4-selecionar-com-efeitos-micro49-fix2.json` | 2026-05-09 |
| 0055 | Onda 24 V204 rollback MICRO49 para MICRO48 | APROVADO_OPERADOR_ROLLBACK_MICRO48 | `0055-exec-onda24-md24-rollback-micro48.json` | 2026-05-09 |
| 0056 | Onda 25 V204 MICRO50 rc1 | APROVADO_OPERADOR_RC1 | `0056-onda25-md25-1-v204-rc1-micro50.json` | 2026-05-10 |
| 0057 | Onda 25 V204 MICRO51 higiene final rc1 | EXECUTADO_DOCUMENTAL | `0057-onda25-md25-2-higiene-final-micro51.json` | 2026-05-10 |
| 0058 | Onda 25 V204 MICRO52 auditoria cruzada final | APROVADO_AUDITORIA_SEM_P0P1_COM_P2 | `0058-onda25-md25-3-auditoria-cruzada-final-micro52.json` | 2026-05-10 |
| 0060 | Onda 25 V204 MICRO53 Limpar Base CAD_SERV | ENTREGUE_PENDENTE_GATE_OPERADOR | `0060-exec-onda25-md25-5-correcao-limpar-cad-serv-micro53.json` | 2026-05-11 |
| 0061 | Onda 25 V204 MICRO53-fix1 compile Preencher | ENTREGUE_PENDENTE_GATE_OPERADOR | `0061-exec-onda25-md25-5-correcao-limpar-cad-serv-micro53-fix1.json` | 2026-05-11 |
| 0062 | Onda 25 V204 MICRO53-fix2 baseline CAD_SERV V2 | APROVADO_OPERADOR_FINAL | `0062-exec-onda25-md25-5-correcao-limpar-cad-serv-micro53-fix2.json` | 2026-05-11 |
| 0063 | Onda 25 V204 MICRO54 publicacao oficial | APROVADO_PUBLICADO_GITHUB | `0063-exec-onda25-md25-6-publicacao-v204-micro54.json` | 2026-05-11 |
