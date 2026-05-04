---
titulo: 37 - Backup V12-202-Z — ancora estavel pos-MD-2.3 (Onda 11 parcial)
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-02
autor: Claude Opus 4.7 (Cowork) com criacao do backup pelo operador
licenca-target: TPGL-v1.1 (Credenciamento)
---

# 37. Backup V12-202-Z — Ancora estavel pos-MD-2.3

## Status

**ANCORA ESTAVEL VIGENTE** a partir de 2026-05-02 03:5x BRT.

Substitui `V12-202-T-onda10` como referencia operacional. Todas as
sessoes futuras (chat-novo-Credenciamento, chat-novo-usehbn) devem
considerar `V12-202-Z` como ponto de retorno em caso de regressao.

## Conteudo do backup

| Item | Valor |
|---|---|
| Arquivo | `V12-202-Z/PlanilhaCredenciamento-Homologacao-V3.xlsm` (operador renomeia conforme convencao local) |
| Build label importado | `f7aa84f+ONDA11.MD2-3-DT3-cleanup-config-incremental` |
| Compile manual | LIMPO (validado em 2026-05-02 03:48 BRT) |
| Trio minimo | `VR_20260502_034422` = APROVADO (V1=171/0; V2 Smoke=14/0; V2 Canonica=20/0) |
| Suite E2E strikes | `TV2_20260502_040156` = OK=64 / FALHA=0 / MANUAL=0 |
| DT-3 status | RESOLVIDO (regra de strikes validada end-to-end via fluxo natural com 3 EMPs) |
| Onda 11 status | EM PAUSA — 5/8 microdeltas concluidos (MD-0, MD-1, MD-2, MD-2.2, MD-2.3) |
| Pendente | MD-3 (DT-1 Quarteto), MD-4 (CSV path), MD-5 (rc1 + CHANGELOG + L16-L18+M7 + ERP + fechamento), tag git |

## O que foi entregue ate aqui (Onda 11 parcial)

### Funcional

A regra de strikes em producao foi validada end-to-end via fluxo
natural do rodizio com 3 empresas. A suite
`TV2_RunRodizioStrikesEndToEnd` passa 64 asserts, capturando:

- Pre-selecao da empresa antes de EmitirPreOS (DIAG_PRESEL)
- Persistencia em PRE_OS (DIAG_PREOS, DIAG_PREOS_INTEGRITY)
- Persistencia em CAD_OS (DIAG_OS)
- Avaliacao com nota baixa/alta + contagem de strikes (DIAG_AVAL_POS)
- Suspensao automatica ao atingir MAX_STRIKES
- Reativacao automatica via DT_FIM_SUSP vencido
- Cobertura completa das Etapas A-J do cenario isolado (ATIV=999)

### Infraestrutura

- 6 arquivos canonicos sincronizados entre `src/vba/` e
  `local-ai/vba_import/001-modulo/` (drift G7 corrigido — Regra de
  Ouro 0002 mantida)
- Helper `TV2_E2E_RestaurarConfigBaseline` (anti-vazamento CONFIG)
- 3 manifestos delta novos: MICRO06, MICRO07, MICRO08, MICRO09 (4
  delta packages sequenciais entregues)
- Importador V3 funcionando em modo Estabilizado para todos os
  microdeltas
- Knowledge canon V2 vigente: `.hbn/knowledge/0004-protocolo-markers-v2.md`

### Documental

- `auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md` — DT-5
  registrado como feature de V12.0.0204
- `auditoria/00_status/36_SPEC_DT6_Validacao_UI_Configuracao_V12_0204.md`
  — DT-6 registrado como feature de V12.0.0204
- `local-ai/Time_AI/2026-05-02-V203-fechamento/` — pacote completo da
  cadeia Antigravity → Codex → Opus (gitignored, processo interno)

## Procedimento de restauracao (caso necessario)

Se uma sessao futura introduzir regressao nao-recuperavel:

1. Operador renomeia o workbook corrompido para
   `V12-202-?-corrompido-YYYYMMDD/`.
2. Copia `V12-202-Z/PlanilhaCredenciamento-Homologacao-V3.xlsm` para
   pasta de trabalho.
3. Abre o workbook restaurado.
4. Valida via `?GetBuildImportado` no Imediato — deve retornar
   `f7aa84f+ONDA11.MD2-3-DT3-cleanup-config-incremental`.
5. Roda `CT_ValidarRelease_TrioMinimo` — deve retornar 171/0+14/0+20/0.
6. Roda `TV2_RunRodizioStrikesEndToEnd` — deve retornar OK=64 FALHA=0.
7. Confirma que `src/vba/` e `local-ai/vba_import/` estao em hash
   igual nos 6 arquivos do dominio strikes (Svc_Avaliacao,
   Repo_Avaliacao, Teste_V2_Roteiros, Util_Config, Svc_PreOS,
   Svc_Rodizio).

## Versao

- v1.0 — 2026-05-02 — backup criado pelo operador apos MD-2.3 verde,
  registrado como ancora estavel para a transicao para 2 chats novos.
