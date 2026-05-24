---
titulo: Schemas HBN executáveis — contratos validáveis por máquina
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
---

# Schemas HBN executáveis

Esta pasta contém os contratos JSON Schema que **validam mecanicamente** os
artefatos de coordenação inter-IA do projeto Credenciamento. A regra é:

> Se uma regra do protocolo HBN não vira schema, ela não existe — vira sugestão.

Os schemas aqui não substituem a doutrina em `usehbn/methodology/` nem o
relay/knowledge. Eles **enforçam** o subconjunto crítico que, se violado,
permite regressão silenciosa ou perda de contexto entre IAs.

## Schemas vigentes

| Arquivo | Valida | Local dos artefatos | Quando é validado |
|---|---|---|---|
| `readback.schema.json` | Readback emitido pela IA executora antes da execução | `.hbn/readbacks/NNNN-*.json` | `scripts/hbn-guards/validate-readback.sh` e no pre-commit |
| `hearback.schema.json` | Hearback humano (confirma/rejeita o readback) | `.hbn/hearbacks/NNNN-*.json` | `scripts/hbn-guards/validate-hearback.sh` e no pre-commit (em safe_track) |
| `audit-pre.schema.json` | Auditoria pré-execução (ex.: Gemini/Antigravity adversarial) | `.hbn/audits/NNNN-pre.json` | `scripts/hbn-guards/validate-audit.sh` |
| `audit-post.schema.json` | Auditoria pós-execução do diff | `.hbn/audits/NNNN-post.json` | `scripts/hbn-guards/validate-audit.sh` |

## Por que JSON Schema draft-07

- Compatível com `python3 -m jsonschema` (já disponível em qualquer máquina com
  Python 3) e com `ajv` (Node) se for necessário evoluir.
- Permite definição de `required`, `pattern`, `enum`, `additionalProperties`,
  o suficiente para o subconjunto crítico do protocolo.
- Não exige instalar dependências exóticas — pode rodar em pre-commit local
  sem CI.

## Princípio de campo obrigatório vs opcional

Campo **obrigatório** = sem ele a IA executora não tem permissão de tocar
arquivo. Campo **opcional** = enriquece a auditabilidade mas não bloqueia.

Em particular, `scope.files_allowed` em `readback.schema.json` é
**obrigatório** para `track: safe_track`. Isso é o que impede a IA de
escrever em pasta errada.

## Como evoluir um schema

1. Abrir ADR em `auditoria/01_regras_e_governanca/` propondo o ajuste.
2. Atualizar o schema mantendo retrocompatibilidade quando possível.
3. Bumpar `schema_version` (campo `$id` no schema).
4. Atualizar readbacks/audits novos para a nova versão; antigos continuam
   válidos sob a versão antiga.
5. Registrar a mudança em `CHANGELOG.md` e em `.hbn/knowledge/`.
