---
titulo: Dossiê de Release V12.0.0205
diataxis: tutorial
hbn-track: safe_track
hbn-status: active
audiencia: auditores
versao-sistema: V12.0.0205
data: 2026-05-21
sha256-derivado-docx: 8ca82b4fc247ac59ae247f8ceaf90ca09fa3826269bb5b390968c756cf822598
---

# Dossiê de Release — V12.0.0205

Este é o dossiê fonte da V12.0.0205. O arquivo Markdown é a fonte primária.
DOCX e PDF são artefatos derivados.

## Identidade

| Campo | Valor |
|---|---|
| Versão | V12.0.0205 |
| Natureza | Estabilização para produção |
| Base | V12.0.0204 VALIDADO/OFICIAL |
| Status | VALIDADO/OFICIAL após Gate RVS final `VR_20260523_215637` |
| Planilha de homologação | `PlanilhaCredenciamento-Homologacao-V4.xlsm` |

## Escopo

- Nomenclatura profissional RVS/SRC/BRL.
- Central de Testes mais clara.
- Evidências V205 padronizadas.
- Jornada de Validação Humana.
- Dossiê e documentação pública.
- CI/CD de release atualizado.

## Não Escopo

- PDF automático VBA.
- Refatoração profunda.
- Renomeação de símbolos VBA.
- Preparação SaaS.

## Gate Funcional

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

Resultado validado em homologação interna:

| Campo | Valor |
|---|---|
| Validation ID | `VR_20260523_215637` |
| Build | `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix` |
| Resultado | `APROVADO` |
| CSV | `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260523_215637.csv` |
| SHA-256 | `7146912436ab0ef3080e90d7183c614699226a65047330a2730718f2cfffbc60` |

## Evidências

As evidências finais ficam em `auditoria/evidencias/V12.0.0205/` e são listadas
no manifesto com `sha256`. O CSV do RVS já está registrado e é a evidência
funcional bloqueante da release. PDF e print manuais são evidências
complementares de auditoria humana; se anexados antes da tag, seus hashes devem
ser adicionados ao manifesto.

## Auditoria Cruzada Final

A V205 será submetida a uma última auditoria cruzada positiva antes do
congelamento público. O objetivo é verificar que a documentação do GitHub
funciona como vitrine institucional da ferramenta, sem inconsistência de
numeração, versão, caminhos de arquivos ou protocolo.

Documentos de prompt:

- `auditoria/00_status/77_PROMPT_AUDITORIA_POSITIVA_V205_CLAUDE_OPUS.md`
- `auditoria/00_status/78_PROMPT_AUDITORIA_DOCS_GITHUB_V205_GEMINI.md`
- `auditoria/00_status/79_PROMPT_CONSOLIDACAO_FINAL_V205_CODEX.md`

Relatórios finais:

- `auditoria/00_status/80_AUDITORIA_FINAL_POSITIVA_V205_CLAUDE_OPUS.md`
- `auditoria/00_status/81_AUDITORIA_FINAL_DOCS_GITHUB_V205_GEMINI.md`
- `auditoria/00_status/82_CONSOLIDACAO_FINAL_FREEZE_V205_CODEX.md`

## Débitos Diferidos Para V12.0.0206

- PDF automático robusto.
- Ajustes incrementais que surgirem em testes manuais.
- Pequenos débitos técnicos e lapidações prorrogadas.

## Linha Seguinte Recomendada

V12.0.0207 fica reservada, salvo decisão posterior de roadmap, para code review
profundo, performance, componentização e preparação arquitetural para evolução
SaaS.
