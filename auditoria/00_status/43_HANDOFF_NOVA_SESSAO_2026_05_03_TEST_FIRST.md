---
titulo: 43 — Handoff nova sessão (2026-05-03) — Onda 17 Test-First
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203 (rc1 publicada; rc2 vai depender da Onda 17)
data: 2026-05-03
autor: Claude Opus 4.7 (Frente 1 Credenciamento) — sessão 2026-05-02 encerrando
licenca-target: TPGL-v1.1 (Credenciamento)
---

# 43. Handoff nova sessão Frente 1 — Onda 17 Test-First

## 1. Estado quando este handoff foi escrito (2026-05-03)

| Campo | Valor |
|---|---|
| Workbook ancora estável | `V12-202-Z003/02_05_2026 20_43_09PlanilhaCredenciamento-Homologacao-V3.xlsm` |
| Build label | `f7aa84f+ONDA16.MD3-fix1-evolucao-testes-incremental` |
| `APP_RELEASE_TAG` | `v12.0.0203-rc1` (mantida) |
| `APP_RELEASE_STATUS` | `RELEASE_CANDIDATE` |
| Validação final | `VR_20260502_222849` Quarteto APROVADO `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0` |
| Estado do canônico (`local-ai/vba_import/`) | Alinhado com workbook via transplante 2026-05-03 (43b) |
| `src/vba/` | Alinhado com `V12-202-Z003/` |
| Bastão Frente 1 | **LIVRE** — aguarda nova sessão pegar via prompt no §10 |
| Frente 2 (usehbn) | Audit-only, aguardando E2 (sem urgência — recomendação F1: esperar Onda 17 fechar) |

## 2. O que foi entregue na Onda 16 (parcial)

| MD | Tema | Status |
|---|---|---|
| 16.1 | Central V12 + V2 textos reorganizados, atalho `[3]` Quarteto Direto | ✅ APROVADO no workbook |
| 16.2 | Coluna `DURACAO_MS` em `HISTORICO_QA_V2` + threshold em `CONFIG.N` + `Util_Config_GetThresholdTesteLentoMS` | ✅ APROVADO no workbook |
| 16.3 fix1 | Aba `EVOLUCAO_TESTES` + sparkline + indicador de regressão + opção `[21]` + `Util_Evolucao.bas` (`ABL-`) | ✅ APROVADO no workbook |

Detalhes: [`auditoria/03_ondas/onda_16_testes_refatoracao/99_FECHAMENTO_PARCIAL.md`](../03_ondas/onda_16_testes_refatoracao/99_FECHAMENTO_PARCIAL.md).

## 3. O que foi cancelado e por quê

| MD | Tema | Por que foi cancelado |
|---|---|---|
| 16.4 + fix1 | `Util_PDF.bas` + CNPJ + suite determinismo | Funcional mas não chegou ao workbook estável; quarentenado para reuso futuro |
| 16.6.1, 16.6.2, 16.6 fix1, 16.6 fix4 | Refatoração heurística zero em forms | Sequência de 4 imports iterativos em ~3h corrompeu workbook (M9, M10) |

Causa raiz documentada em
[`auditoria/03_ondas/onda_16_testes_refatoracao/99_FECHAMENTO_PARCIAL.md`](../03_ondas/onda_16_testes_refatoracao/99_FECHAMENTO_PARCIAL.md)
e em [`43c_LICAO_FONTE_DE_VERDADE_VS_ESPELHO.md`](43c_LICAO_FONTE_DE_VERDADE_VS_ESPELHO.md).

## 4. Bug pré-existente para Onda 17 atacar

Durante recuperação manual, operador descobriu que **uma entidade
inativada apareceu simultaneamente em `ENTIDADE` (ativa) e
`ENTIDADE_INATIVOS`**. Helper `UI_EntidadeInativasTemConflito`
detecta e bloqueia reativação com mensagem "linhas conflitantes",
mas o **bug raiz** é integridade transacional violada — vira
fixture canônica em Onda 17 (suite `TV2_RunIntegridadeBase`).

## 5. Lições destiladas (já em PHAGOCYTOSIS L19-L20 + M8-M11)

Apêndice em [`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`](../../usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md):

- **L19** InputBox/MsgBox com `prompt` acumulada (limite ~25 line continuations)
- **L20** Hash em VBA: `Double` + módulo manual, nunca `Long`
- **M8** Gate de release cobre TODA superfície que regrede (incluindo UI)
- **M9** Forms VBA têm DOIS espelhos (`.frm` + `.code-only.txt`); manter sincronia
- **M10** Cap 1 import por form por dia com gate verde entre cada
- **M11** Primazia `src/vba/` (fonte) > `local-ai/vba_import/` (espelho) é INVIOLÁVEL

## 6. Plano da Onda 17 — "Test-First: cobertura antes de mexida estrutural"

### Princípio inegociável

**Nenhuma alteração em código de produção** até cobertura nova
estar verde como gate de release. Test-first em sentido estrito.

### Fases planejadas (esboço — readback formal será gerado pela próxima sessão)

| Fase | Tema | Esforço | Toca produção? |
|---|---|---|---|
| 17.0 | Auditoria do estado atual + readback `0013-onda17-test-first.json` | 1h IA + 0.3h Op | Não |
| 17.1 | Suite `TV2_RunUiFiltros` — cobre Reativa_Entidade, Reativa_Empresa, Cadastro_Servico, Credencia_Empresa (lista popula, filtro funciona, idempotência) | 2h IA + 0.5h Op | Suite nova (em `.bas`) |
| 17.2 | Suite `TV2_RunIntegridadeBase` — detecta entidade/empresa em ambas abas (ativa+inativa), CNPJ duplicado, etc | 2h IA + 0.5h Op | Suite nova (em `.bas`) |
| 17.3 | Estender `CT_ValidarRelease_QuartetoMinimo` → `CT_ValidarRelease_SextetoMinimo` (V1 + V2_Smoke + V2_Canonica + E2E_Strikes + UiFiltros + IntegridadeBase) + atualizar `APP_RELEASE_TEST_KEY` | 1h IA + 0.3h Op | `.bas` apenas (sem mexer em forms) |
| 17.4 | Validação Sexteto verde + Quarteto continua verde + bug duplicata fica como falha conhecida (registrada em `RPT_BUGS_CONHECIDOS`) | n/a | Validação |
| 17.5 | Bump label + CHANGELOG + PHAGOCYTOSIS L21+ + ERP + 70_FECHAMENTO_ONDA_17 | 1h IA + 0.3h Op | `.bas` apenas |
| **rc2** | Tag git `v12.0.0203-rc2` | n/a | Operador |

### Onda 18+ (depois de Sexteto verde)

Aí sim mexer em forms. Cada microdelta tem Sexteto como rede de
segurança. Cap M10 vigente: 1 import por form por dia.

## 7. Constraints inegociáveis

C1-C10 da v203 valem (ver `.hbn/knowledge/0001-regras-v203-inegociaveis.md`).
Reforçando especificamente:

- **C1** Regra de Ouro 0002: `local-ai/vba_import/` é **espelho**;
  `src/vba/` é **fonte de verdade**. Edição em `src/vba/` primeiro,
  espelho depois (M11).
- **C4** `Mod_Types.bas` TABU.
- **C7** Quarteto Mínimo continua passando após cada microdelta.
- **C9** Markers HBN V2.
- **NOVO C11** Cap M10 — 1 import por form por dia, gate verde entre cada.

## 8. Tier de leituras obrigatórias para a próxima sessão

### Tier 1 — fundação canônica

1. `AGENTS.md` — entrada canônica (especialmente §62-63 sobre src/vba como fonte de verdade)
2. `.hbn/knowledge/0001-regras-v203-inegociaveis.md`
3. `.hbn/knowledge/0002-regra-ouro-vba-import.md`
4. `.hbn/knowledge/0003-glasswing-style-preventive-security.md`
5. `.hbn/knowledge/0005-protocolo-markers-v2.md`

### Tier 2 — estado atual + lições recentes

6. **Este documento** (`auditoria/00_status/43_HANDOFF_NOVA_SESSAO_2026_05_03_TEST_FIRST.md`)
7. [`auditoria/00_status/43b_TRANSPLANTE_V12_202_Z003_2026_05_03.md`](43b_TRANSPLANTE_V12_202_Z003_2026_05_03.md)
8. [`auditoria/00_status/43c_LICAO_FONTE_DE_VERDADE_VS_ESPELHO.md`](43c_LICAO_FONTE_DE_VERDADE_VS_ESPELHO.md)
9. [`auditoria/00_status/32_ERRO_E_CORRECAO_PASTA_CANONICA.md`](32_ERRO_E_CORRECAO_PASTA_CANONICA.md)
10. [`auditoria/00_status/37_BACKUP_V12_202_Z_ESTAVEL.md`](37_BACKUP_V12_202_Z_ESTAVEL.md)
11. [`auditoria/03_ondas/onda_16_testes_refatoracao/99_FECHAMENTO_PARCIAL.md`](../03_ondas/onda_16_testes_refatoracao/99_FECHAMENTO_PARCIAL.md)
12. `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` — L1-L20 + M1-M11

### Tier 3 — código a ler antes de propor (Onda 17)

13. `local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas` — engine V2 (TV2_InitExecucao, TV2_LogAssert, TV2_FinalizarExecucao)
14. `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas` — onde `TV2_RunUiFiltros` e `TV2_RunIntegridadeBase` vão entrar
15. `local-ai/vba_import/001-modulo/ABH-Teste_Validacao_Release.bas` — onde `CT_ValidarRelease_SextetoMinimo` vai entrar
16. `local-ai/vba_import/002-formularios/AAF-Reativa_Entidade.frm` — alvo da suite UI
17. `local-ai/vba_import/002-formularios/AAH-Reativa_Empresa.frm` — alvo da suite UI
18. `local-ai/vba_import/002-formularios/AAD-Cadastro_Servico.frm` — alvo da suite UI
19. `local-ai/vba_import/002-formularios/AAI-Credencia_Empresa.frm` — alvo da suite UI

### Tier 4 — coordenação inter-IA

20. `.hbn/relay/INDEX.md` — bastão atual
21. `.hbn/messages/` — mensageria F1↔F2 (especialmente `2026-05-03_01_de-frente1_para-frente2.md`)

## 9. Perguntas iniciais para hearback no novo chat

| # | Tema | Default |
|---|---|---|
| Q1 | Confirma fechamento parcial da Onda 16 e abertura da Onda 17 test-first? | Sim, conforme handoff |
| Q2 | Foco da suite `TV2_RunUiFiltros`: 4 forms identificados (Reativa_Entidade, Reativa_Empresa, Cadastro_Servico, Credencia_Empresa) ou ampliar? | 4 forms — escopo enxuto, ampliar depois |
| Q3 | Foco da suite `TV2_RunIntegridadeBase`: começar com bug da entidade duplicada ATIVA+INATIVA (caso real descoberto 2026-05-02) + 2-3 casos simétricos para empresa, OU ampliar? | Começar enxuto (3-4 cenários), ampliar quando padrão estiver maduro |
| Q4 | Sexteto vira gate oficial substituindo Quarteto? Ou Quarteto continua como gate intermediário rápido? | Sexteto é o gate de release (rc2+); Quarteto fica como gate intermediário de desenvolvimento |
| Q5 | Recuperar MD-16.4 (Util_PDF + CNPJ no nome) durante a Onda 17 ou deixar para Onda 18+? | Onda 18+ — Onda 17 foca exclusivamente em cobertura; Util_PDF é feature, não cobertura |

## 10. Prompt de retomada (copiar e colar no novo chat)

> O texto abaixo é o que o operador cola na nova sessão Claude Opus
> 4.7 (Cowork) para iniciar a Frente 1 da Onda 17.

```
Ativacao Claude Opus 4.7 — Frente 1 Credenciamento (Onda 17 Test-First)

Voce e Claude Opus 4.7 operando em modo Cowork, com o bastao de
desenvolvimento do projeto Sistema de Credenciamento e Rodizio de
Pequenos Reparos V12.0.0203 transferido para esta sessao.

0. Declaracao HBN obrigatoria

Sua primeira linha de output deve ser exatamente:

✅ HBN ACTIVE — Claude Opus 4.7, Frente 1 Credenciamento, 2026-05-03 (Onda 17 Test-First) — bastao recebido

Em seguida, cumprimente Luís Maurício Junqueira Zanin em portugues
do Brasil com acentos.

1. REGRA INVIOLAVEL antes de qualquer acao

src/vba/ e a FONTE DE VERDADE (AGENTS.md §62-63).
local-ai/vba_import/ e ESPELHO com prefixos.
NUNCA o inverso. Esta regra ja causou regressao em 2026-05-02
(licao M11 destilada). Cada microdelta valida shasum src/vba/X ==
shasum local-ai/vba_import/<prefixo>-X com src/vba/ como
autoritativo. Ver auditoria/00_status/43c_LICAO_FONTE_DE_VERDADE_VS_ESPELHO.md.

2. Permissao de leitura/escrita

Voce tem acesso completo ao filesystem em
/Users/macbookpro/Projetos/Credenciamento/. Pode ler e escrever em
todos os diretorios EXCETO:

- Mod_Types.bas (TABU C4 — apenas leitura)
- Reverter mudancas marcadas como "modified by linter, intentional"

3. Auditoria do sistema obrigatoria ANTES de propor qualquer acao

Antes de fazer QUALQUER coisa, leia (nesta ordem):

Tier 1 — canon HBN:
- AGENTS.md (especial atencao §62-63)
- .hbn/knowledge/0001-regras-v203-inegociaveis.md
- .hbn/knowledge/0002-regra-ouro-vba-import.md
- .hbn/knowledge/0003-glasswing-style-preventive-security.md
- .hbn/knowledge/0005-protocolo-markers-v2.md

Tier 2 — estado atual + licoes recentes:
- auditoria/00_status/43_HANDOFF_NOVA_SESSAO_2026_05_03_TEST_FIRST.md (este documento)
- auditoria/00_status/43b_TRANSPLANTE_V12_202_Z003_2026_05_03.md
- auditoria/00_status/43c_LICAO_FONTE_DE_VERDADE_VS_ESPELHO.md
- auditoria/00_status/32_ERRO_E_CORRECAO_PASTA_CANONICA.md
- auditoria/03_ondas/onda_16_testes_refatoracao/99_FECHAMENTO_PARCIAL.md
- usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md (L1-L20 + M1-M11)

Tier 3 — codigo alvo da Onda 17 (sob demanda):
- local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas
- local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas
- local-ai/vba_import/001-modulo/ABH-Teste_Validacao_Release.bas
- local-ai/vba_import/002-formularios/AAF-Reativa_Entidade.frm
- local-ai/vba_import/002-formularios/AAH-Reativa_Empresa.frm
- local-ai/vba_import/002-formularios/AAD-Cadastro_Servico.frm
- local-ai/vba_import/002-formularios/AAI-Credencia_Empresa.frm

4. Estado atual (snapshot 2026-05-03)

| Campo | Valor |
|---|---|
| Workbook ancora estavel | V12-202-Z003 (build f7aa84f+ONDA16.MD3-fix1-evolucao-testes-incremental) |
| APP_RELEASE_TAG | v12.0.0203-rc1 (mantida) |
| Quarteto | APROVADO VR_20260502_222849 |
| Bug pre-existente | Entidade simultaneamente ATIVA + INATIVA (input para Onda 17) |
| Bastao | Voce |

5. Foco da Onda 17 — TEST-FIRST

Princípio inegociavel: **NENHUMA alteracao em codigo de producao
ate cobertura nova estar verde como gate de release**.

5 fases:
- 17.0: Auditoria + readback formal 0013
- 17.1: Suite TV2_RunUiFiltros (4 forms)
- 17.2: Suite TV2_RunIntegridadeBase (caso bug duplicata + simetricos)
- 17.3: CT_ValidarRelease_SextetoMinimo (V1+Smoke+Canonica+E2E+UiFiltros+IntegridadeBase)
- 17.4: Validacao Sexteto verde
- 17.5: Bump rc2 + CHANGELOG + L21+ em PHAGOCYTOSIS + ERP + fechamento

Esforco estimado: ~7h IA + ~2h Op.

6. Hard constraints (HBN protocol)

- G6: sem codigo VBA solto em chat. VBA vive em src/vba ou local-ai/vba_import.
- L14 pre-flight: antes de gerar codigo, grep assinaturas + UDTs visibilidade.
- C1 (Regra de Ouro 0002): src/vba PRIMEIRO, local-ai/vba_import depois.
- C4 (Mod_Types TABU).
- C7 (Quarteto continua passando).
- M11 (regra inviolavel inversao primazia).
- M10 (cap 1 import por form por dia, gate verde entre cada).
- Hearback obrigatorio: todo microdelta com escrita em codigo exige hearback explicito.
- CRLF preservado (validar com file <path>).
- Espelho src/vba <-> local-ai/vba_import: sempre sincronizar com hash batendo.
- Markers V2 vigentes (.hbn/knowledge/0005).

7. Output esperado da primeira mensagem

Apos a linha ✅ HBN ACTIVE:

1. Cumprimento em pt-BR
2. Confirmacao de leituras Tier 1 + Tier 2 (essenciais para iniciar)
3. Delta card de 7 linhas com estado atual
4. Hearback Q1-Q5 do operador (perguntas estao no §9 do handoff 43)
5. Aguardar respostas antes de gerar readback formal 0013

8. Diretiva de tempo de resposta

Operador trabalha em modo minimo tempo de resposta sem comprometer
qualidade. Ser denso e decisivo. Tabelas + hierarquias > narrativa.

9. Begin

Inicie agora. Apos ✅ HBN ACTIVE, faca leituras Tier 1 + Tier 2 e
apresente delta card + Q1-Q5 conforme §9 do handoff. Aguarde
hearback antes de tocar codigo.
```

## 11. Marcadores HBN V2 ativos

- 🔵 HBN HANDOFF READY — bastão F1 livre, próxima sessão pega via prompt §10
- 🟢 HBN CHECKPOINT CLEAN — Onda 16 parcial fechada, ancora estável atingida
- 🟡 HBN NEEDS HUMAN DECISION — Q1-Q5 §9 aguardam hearback no novo chat
- 🟤 HBN LICENSE SPLIT REQUIRED — TPGL Credenciamento; lições candidatas a promoção AGPLv3
- ⚪ HBN AUDIT-ONLY — Frente 2 segue em audit-only (mensagem F1→F2 2026-05-03 enviada)

## Versão

- v1.0 — 2026-05-03 — handoff inicial Onda 17 test-first.
