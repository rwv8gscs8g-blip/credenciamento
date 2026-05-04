---
titulo: 33 - Handoff para nova sessao Opus 4.7 (pos-Onda 10)
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-02
autor: Claude Opus 4.7 (sessao Cowork de 2026-04-28 a 2026-05-02)
---

# 33. Handoff para nova sessao Opus 4.7

## Estado quando este handoff foi escrito (2026-05-02 02:50)

- **Onda 10 FECHADA na canonica** com debito DT-3 documentado
- **Workbook ancora**: `V12-202-T-onda10/PlanilhaCredenciamento-Homologacao-V3.xlsm`
  (a salvar pelo operador apos rodar `IV3_BumpBuildLabel "f7aa84f+ONDA10-canonica-fechada-com-debito-strikes"`)
- **Importador V3**: V3.2-Canonica-Onda10-Fechada operando em
  `local-ai/vba_import/` (canonica restaurada)
- **Trio minimo final**: `VR_20260501_233424` 171/0 + 14/0 + 20/0 APROVADO
- **Suite e2e nova**: `TV2_RunRodizioStrikesEndToEnd` com 4/16 asserts (12 falhas - DT-3, candidato a auditoria externa)

## Documento de handoff (PROMPT para colar na nova sessao)

```
Contexto: estamos retomando o projeto Credenciamento V12.0.0203 apos
fechamento da Onda 10 em 2026-05-02. A sessao anterior (Claude Opus 4.7)
acumulou 11 ondas + estabilizacao + correcao de erro arquitetural
grave (pasta canonica). Esta nova sessao foca em (a) iniciar Onda 11
ou (b) preparar pacote para auditoria externa multi-IA, conforme
sua prioridade.

LEIA NESTA ORDEM (obrigatorio):

1. AGENTS.md (entrada canonica para IAs)
2. .hbn/relay/INDEX.md (quem tem o bastao)
3. .hbn/knowledge/0002-regra-ouro-vba-import.md (REVALIDADA em Onda 10 - LEIA INTEIRA)
4. auditoria/00_status/32_ERRO_E_CORRECAO_PASTA_CANONICA.md (vitrine de transparencia - LEIA INTEIRA)
5. auditoria/03_ondas/onda_10_reincorporacao_onda01/70_FECHAMENTO_ONDA_10.md (resumo executivo)
6. .hbn/results/0010-exec-onda10.json (ERP completo Onda 10)
7. usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md (licoes L1-L15 + M1-M6)
8. auditoria/00_status/27_ROADMAP_REINCORPORACAO_INCREMENTAL_V203.md (roadmap)
9. auditoria/00_status/33_HANDOFF_NOVA_SESSAO_OPUS.md (este documento)

ESTADO ATUAL:
- Onda 10 FECHADA NA CANONICA com debito DT-3 documentado
- Workbook V12-202-T-onda10 estavel (ou prestes a ser salvo)
- 5 debitos tecnicos abertos (DT-1 a DT-5) — ver lista abaixo
- 6 licoes L+ canonicas + 1 licao M+ documentadas em PHAGOCYTOSIS

REGRAS INVIOLAVEIS:
- Pasta canonica de import: local-ai/vba_import/ — UNICA fonte
- NUNCA criar pastas paralelas tipo vba_import_v3_phaseN
- G6 enforced: nenhum codigo VBA solto em chat
- Pre-flight check obrigatorio antes de gerar codigo (L14)
- Todo microdelta com gate compile + suite oficial (L13, M6)
- Cada onda: 1 readback + 1 ERP

PROXIMA ACAO (SUA PRIORIDADE - escolher uma):

OPCAO A — Iniciar Onda 11 (Reincorporacao Onda 2 - CNAE)
  Tema: TV2_RunCnae + opcao [15] em Central V2
  Esforco: ~5 microdeltas, 3-4h de trabalho operador
  Pre-requisito: pre-flight check de assinaturas/tipos antes de gerar codigo

OPCAO B — Preparar pacote auditoria externa (Antigravity, Codex)
  Tema: documento listando o que cada IA pode auditar
  Foco principal: DT-3 (testes de strikes)
  Esforco: ~1h de organizacao

OPCAO C — Atacar DT-3 diretamente (correcao do diagnostico de strikes)
  Tema: por que ContarStrikesPorEmpresa retorna 0 mesmo apos avaliacoes?
  CSV de evidencia: TesteV2_STRIKES_E2E_Falhas_TV2_20260501_221038.csv
  Hipotese atual: avaliacao persiste mas com EMP_ID diferente do esperado
  Esforco: indeterminado, dependendo da causa raiz

OPCAO D — Implementar DT-5 (geracao de PDFs por ciclo de rodizio)
  Tema: Util_PDF.bas + hooks em EmitirPreOS/EmitirOS/AvaliarOS
  Util para depuracao do DT-3 + feature em si
  Esforco: ~4 microdeltas

DEBITOS TECNICOS ABERTOS:
- DT-1 (ALTA): Smoke teste alertando false-positives — pos-Onda 10
- DT-2 (MEDIA): Padronizar todas baterias V1/V2 para padrao TV2-14 e2e
- DT-3 (ALTA): Diagnostico das 12 falhas em TV2_RunRodizioStrikesEndToEnd
- DT-4 (BAIXA): Limpeza semantica de vba_import (apenas codigo de import; doc em docs/)
- DT-5 (MEDIA): Geracao de PDFs por ciclo de rodizio

CHECKLIST DA NOVA SESSAO:
[ ] Li AGENTS.md
[ ] Li relay/INDEX.md
[ ] Li 32_ERRO_E_CORRECAO_PASTA_CANONICA.md (vitrine de transparencia)
[ ] Li PHAGOCYTOSIS-VBA-PATTERNS.md (L1-L15 + M1-M6)
[ ] Li 70_FECHAMENTO_ONDA_10.md
[ ] Confirmei que vou operar em local-ai/vba_import/ (canonico)
[ ] Confirmei que vou fazer pre-flight check antes de gerar codigo
[ ] Mauricio escolheu opcao A/B/C/D para esta sessao

Modo: consultivo controlado. G6 enforced. Cada onda = 1 readback + 1 ERP.
Hearback obrigatorio antes de escrever qualquer arquivo.
```

## Lista para auditoria externa (Antigravity, Codex)

Quando o pacote para auditoria externa for preparado, sugerir os
seguintes pontos focais:

### Para Antigravity

- Revisar lições L1-L15 + M1-M6 em `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`
  - Sao classificacoes corretas?
  - Sao generalizaveis para outros projetos VBA?
  - Faltam licoes nao documentadas?
- Revisar metodologia "fagocitose" do protocolo usehbn:
  - O ciclo Encontro -> Diagnostico -> Validacao -> Destilacao -> Propagacao funciona?
  - O que pode ser melhorado?
- Revisar arquitetura V3.2-Canonica-Onda10-Fechada do Importador V3:
  - Capacidade delta + bump auto e robusta?
  - Os guards (L1-L9) sao suficientes?
  - Fix9 (COD_SERVICO formato ATIV|SERV) revela problema de design no projeto?

### Para Codex

- DT-3: por que `ContarStrikesPorEmpresa("001", notaMin)` retorna 0
  apos `TV2_E2E_AtenderProximaEmpresa` chamar `EmitirPreOS`,
  `EmitirOS`, `AvaliarOS` para EMP="001" com nota baixa?
- Hipotese atual: a OS avaliada nao tem `COL_OS_EMP_ID = "001"`,
  mas alguma outra empresa selecionada pelo rodizio. Confirmar
  empiricamente lendo `CAD_OS` apos cada `TV2_E2E_RodadaCompleta`.
- CSV de falhas: `TesteV2_STRIKES_E2E_Falhas_TV2_20260501_221038.csv`
- Codigo da suite: `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas` linhas 1421-1758
- Codigo de `EmitirPreOS`: `local-ai/vba_import/001-modulo/AAQ-Svc_PreOS.bas` linhas 108-234
- Codigo de `SelecionarEmpresa`: `local-ai/vba_import/001-modulo/AAP-Svc_Rodizio.bas` linhas 39-150

## Estado dos debitos pendentes (snapshot)

| ID | Tema | Prioridade | Esforco estimado | Auditoria externa? |
|---|---|---|---|---|
| DT-1 | Smoke teste alertando false-positives | ALTA | Media | Util |
| DT-2 | Padronizar baterias V1/V2 para padrao TV2-14 e2e | MEDIA | Alta | Util |
| DT-3 | Diagnostico 12 falhas TV2_RunRodizioStrikesEndToEnd | ALTA | Indeterminado | **Recomendada** |
| DT-4 | Limpeza semantica vba_import | BAIXA | Baixa | Nao |
| DT-5 | Geracao de PDFs por ciclo de rodizio | MEDIA | Media | Util |

## Roadmap proximas ondas (sumario)

| Onda | Tema | Prioridade |
|---|---|---|
| 11 | Reincorporacao Onda 2 (CNAE snapshot/dedup) | Media |
| 12 | Reincorporacao Onda 3 (CNAE dedup automatico) | Baixa |
| 13 | Reincorporacao Onda 4 (Diag rodizio + form) | Media |
| 14 | Phase A.6 - auditoria caso-a-caso divergentes residuais | Media |
| 15 | Reincorporacao Onda 7 (IDM_*/RDZ_*) | Alta |
| 16 | Reincorporacao Onda 8 (heuristica zero forms) | Media |
| 17 | DT-3 + DT-5 (correcao testes strikes + PDFs) | Alta |
| 18 | DT-1 + DT-2 (smoke reforcado + padronizacao) | Media |
| 19 | Auditoria externa multi-IA (Antigravity, Codex) | Alta |
| FECH | Build label v12.0.0203-rc1 + CHANGELOG + tag + push GitHub | Final |

## Onde encontrar tudo (mapa rapido)

| O que | Onde |
|---|---|
| Codigo fonte VBA | `src/vba/` |
| Pasta de import canonica | `local-ai/vba_import/` |
| Backups forenses + historico | `auditoria/04_evidencias/V12.0.0203/` |
| Documentacao tecnica por onda | `auditoria/03_ondas/onda_NN_<tema>/` |
| Status e roadmaps | `auditoria/00_status/` |
| Coordenacao HBN | `.hbn/` |
| Licoes canonicas (fagocitose) | `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` |
| Conhecimento HBN local | `.hbn/knowledge/` |
| Workbook ancora pos-Onda 10 | `V12-202-T-onda10/PlanilhaCredenciamento-Homologacao-V3.xlsm` |

## Versao

- v1.0 — 2026-05-02 — handoff inicial pos-Onda 10
