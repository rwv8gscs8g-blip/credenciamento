---
titulo: Prompt de retomada Opus 4.7 — Onda 38.2.3 pós-corrupção workbook + auditorias cruzadas entregues
data: 2026-05-27
predecessor: 114_PROMPT_RETOMADA_SESSAO_OPUS.md
sucessor-esperado: 117_PROMPT_RETOMADA_SESSAO_OPUS.md
hbn-track: fast_track (doc-only)
contexto-critico: workbook V206 corrompeu durante uso operacional; rollback obrigatório; RVS REPROVADO determinístico (mesma falha 2x); auditorias Codex+Antigravity entregues, aguardando consolidação Opus
---

# PROMPT DE RETOMADA — Opus 4.7 (sessão sucessora de 2026-05-27 08:38→09:30)

✅ HBN ACTIVE

Você é Claude Opus 4.7 assumindo continuidade do bastão V12.0.0206. A sessão
predecessora (2026-05-27 04:30→09:30 BRT, ~5h, ~60% contexto) entregou:

- **3 macros temporárias DUMP** validadas com operador
- **Confirmação operacional** que Sheet CREDENCIADOS não tem eventos Worksheet_* (ângulo cego eliminado)
- **Prompt de auditoria cruzada** (`auditoria/00_status/115_PROMPT_AUDITORIA_CRUZADA_INTEGRIDADE_IDEMPOTENCIA.md`)
- **Mauricio executou as 2 auditorias em paralelo** e os outputs já estão no repo:
  - [`.hbn/proposals/0009-codex-auditoria-integridade-idempotencia-v206.md`](../../.hbn/proposals/0009-codex-auditoria-integridade-idempotencia-v206.md) (24KB, **staged**)
  - [`.hbn/proposals/0010-antigravity-auditoria-integridade-idempotencia-v206.md`](../../.hbn/proposals/0010-antigravity-auditoria-integridade-idempotencia-v206.md) (16KB, **commit `8fbdf26`**)
- **Handoff fim-sessão**: `.hbn/messages/20260527-0930-handoff-fim-sessao-opus.md`
- **Protocol-evolutions** (Onda 38.2.2 final pós-corrupção): `.hbn/protocol-evolutions/20260527-0930-onda-38-2-2-final-proposals.md`

## INCIDENTE CRÍTICO da sessão predecessora — CORRUPÇÃO DO WORKBOOK

**Mauricio reportou em 2026-05-27 ~09:00**: o workbook `PlanilhaCredenciamento-Homologacao-V5.xlsm` (com Onda 38.2.2 importada) **travou o Excel durante uso operacional e corrompeu**. Mauricio reverteu para uma cópia que ainda abre — também na versão `a51b191+ONDA38.2.2-V206-FREEZE` (build `2026-05-27 04:09`).

**Implicações**:
1. **Importação V3 da Onda 38.2.2 produziu artefato instável** (pelo menos no XLSM resultante).
2. **Não temos 100% de confiança** de que o workbook atual está em estado limpo — pode haver bytes residuais da corrupção.
3. **Mauricio quer decisão Opus** entre 2 caminhos:
   - **(A) Seguir com o workbook reaberto** (mesma versão 38.2.2-V206-FREEZE)
   - **(B) Rollback adicional** para uma versão ANTERIOR às correções (anchor FIX2-PERF `ee75b30`, ou até antes da Onda 38.2.1-AR1)
4. **Mauricio ofereceu**: exportar todos os forms+módulos do workbook ATUAL para `local-ai/incoming/` para você comparar (`diff`) contra `src/vba/` e identificar drift/discrepâncias.

## RVS REPROVADO DETERMINÍSTICO — 2 falhas confirmadas em 2 execuções

| RVS | Build | Resultado | Falhas |
|---|---|---|---|
| `VR_20260526_102200` | `ad5b487+ONDA38.2.1-AR1-FIX2-PERF` | **APROVADO** | — |
| `VR_20260527_060519` | `a51b191+ONDA38.2.2-V206-FREEZE` | **REPROVADO** | V2_SMOKE drift + V2_E2E_STRIKES |
| `VR_20260527_085514` | `a51b191+ONDA38.2.2-V206-FREEZE` | **REPROVADO** | V2_SMOKE drift + V2_E2E_STRIKES (mesma) |

**Conclusão**: as 2 falhas só aparecem na Onda 38.2.2; o FIX2-PERF passa limpo (RVS Trio APROVADO). **Caminho (B) — rollback para FIX2-PERF — é tecnicamente válido e bem testado**.

### Falha A — V2_SMOKE drift `Cadastro_Servico.frm`

```
CENARIO=CS_UISMOKE_Cadastro_Servico_V4
OBJETIVO=Comparacao .frm <-> .code-only.txt (gamma) Cadastro_Servico
ESPERADO=Normalizacao gamma identica
OBTIDO=DIVERGE: len_frm=9307 len_co=9179
SIGNIFICADO=Drift estrutural alem do cosmetico - investigar manualmente
```

Causa raiz hipotetizada: hotfixes consecutivos editaram `.frm` sem rodar `publicar_vba_import_v2.sh --apply` para sync. **Fix trivial**: rodar `--apply` antes de qualquer outra coisa.

### Falha B — V2_E2E_STRIKES `DIAG_PREOS_INTEGRITY`

```
CENARIO=DIAG_PREOS_INTEGRITY
OBJETIVO=EMP preselecionada deve coincidir com EMP gravada em PRE_OS
ESPERADO=EMP=001
OBTIDO=EMP_PRESEL=001 EMP_PREOS=1
SIGNIFICADO=Detecta dupla selecao divergente entre observador e EmitirPreOS interno
```

Causa raiz hipotetizada (F-NEW6 sistêmico, levantado em §115): `Repo_PreOS.BuscarPorId:83` e `Repo_Empresa.LerEmpresa:26` ambos usam `CStr(...).Value` sem `Pad3`. Se a célula tem `1` (Long) por ausência de `NumberFormat="@"` na gravação, retorna `"1"`; se tem `"001"` (String), retorna `"001"`. Comparação string direta falha.

## DUMP CREDENCIADOS pós-V1 (estado atual workbook)

Validado por operador via macro DUMP_CRED_DIAG (sessão predecessora):

```
ultimaLinha=5
L1 | header
L2 | (vazio)
L3 | CRED=002 | EMP=001/String | ATIV=999/Double | STATUS=ATIVO/String | NumFmt_M=General
L4 | CRED=003 | EMP=002/String | ATIV=999/Double | STATUS=ATIVO/String | NumFmt_M=General
L5 | CRED=004 | EMP=003/String | ATIV=999/Double | STATUS=ATIVO/String | NumFmt_M=General
```

**Análise**:
- EMP_ID **String** "001/002/003" → caminho UI corrigido ✅
- ATIV_ID **Double** valor 999 → fixture Teste_V2_*/Teste_Bateria_Oficial grava sem `Pad3` nem `NumberFormat="@"` ❌
- STATUS_CRED **String "ATIVO"** ✅ — F-NEW5 NÃO está presente nesse estado (cenário foi limpo pela V1)
- NumFmt_M=`General` (não `@`) — gravação textual funcionou por chance (Excel preservou string "ATIVO")
- Sheet CREDENCIADOS **sem eventos** — ângulo cego eliminado

## SUA PRIMEIRA AÇÃO

**Leitura obrigatória inicial** (na ordem):

1. `.hbn/relay/INDEX.md` — estado vivo
2. `.hbn/messages/20260527-0930-handoff-fim-sessao-opus.md` — handoff completo Opus predecessor
3. `.hbn/proposals/0009-codex-auditoria-integridade-idempotencia-v206.md` — auditoria Codex
4. `.hbn/proposals/0010-antigravity-auditoria-integridade-idempotencia-v206.md` — auditoria Antigravity
5. `auditoria/00_status/115_PROMPT_AUDITORIA_CRUZADA_INTEGRIDADE_IDEMPOTENCIA.md` — escopo da auditoria
6. Este arquivo (116)
7. `.hbn/protocol-evolutions/20260527-0930-onda-38-2-2-final-proposals.md`
8. `AGENTS.md` + `CLAUDE.md`

**Comando único de verificação ao retomar**:

```bash
cd /Users/macbookpro/Projetos/Credenciamento && \
git log --oneline -10 && \
git status -s && \
bash scripts/hbn-guards/hbn-guards-runner.sh
```

**Esperado**:
- HEAD em `8fbdf26` (commit Antigravity) ou mais novo se Opus predecessor commitou os 3 artefatos de handoff
- Working tree: pode haver `.hbn/proposals/0009-*.md` staged + CSVs `TesteV2_*Falhas*.csv` + arquivo retomada
- Guards 5/5 verde
- `AAX-App_Release.bas` modificado (Knowledge 0016: deixar)

## SUA TAREFA SUBSTANTIVA — Consolidação das auditorias cruzadas

Produza `auditoria/00_status/117_ANALISE_AUDITORIA_INTEGRIDADE_IDEMPOTENCIA.md` consolidando as 2 auditorias (estrutura igual à `111_ANALISE_AUDITORIA_CRUZADA_V207.md`):

### Seções do 117

1. **Convergências entre Codex + Antigravity** (8-12 itens)
2. **Divergências reais** (não cosméticas) — se houver
3. **Hipótese F-NEW6 — validada, refutada, ou refinada?** Cada IA opinou. Síntese Opus.
4. **Decisão arquitetural caminho A vs B**: seguir com 38.2.2 ou rollback adicional? Baseie-se nos achados das auditorias. Recomendação Opus.
5. **Escopo proposto Onda 38.2.3** (AT-1, AT-2, AT-3...) — pré-confirmação Mauricio
6. **Roadmap atualizado** 38.2.4, 38.2.5, ..., até GATE-FREEZE
7. **Riscos identificados + mitigações**
8. **Pedido de hearback** com 3 hipóteses para Mauricio decidir

### Após 117 confirmed

Abrir readback `0112-rb-onda-38-2-3-<escopo>` com `decisions_preconfirmed` dos elementos já alinhados via hearback.

## DECISÕES PENDENTES MAURICIO (a apresentar após 117)

**Hipótese A — Seguir com workbook atual (38.2.2-V206-FREEZE reaberto)**:
- Pró: já foi importado, RVS Trio passa em V1+V2_Smoke+V2_Canonica (problemas isolados em V2_E2E_STRIKES)
- Contra: workbook teve incidente de corrupção; pode haver instabilidade residual

**Hipótese B — Rollback para FIX2-PERF (anchor `ee75b30`)**:
- Pró: RVS Trio APROVADO no `VR_20260526_102200`; estado conhecido limpo
- Contra: perde Onda 38.2.2 inteira (5 hotfixes, 8 módulos, AT-1 a AT-5)
- Onde recomeçar: re-aplicar 38.2.2 com a sequência correta (sem hotfixes intercalados) E corrigir Repo_PreOS junto

**Hipótese C — Rollback ainda mais atrás (antes da Onda 38.2.1-AR1)**:
- Pró: estado pré-mudanças sistêmicas em IDs/contadores
- Contra: perde Util_Sanear_Contadores (que resolveu F1 do bug "ID=001 sempre")
- Provavelmente descartada — sem motivo técnico forte

**Recomendação preliminar Opus predecessora**: B com escopo expandido (corrigir F-NEW6 em Repo_PreOS junto com re-aplicação 38.2.2).

## OFERTA OPERACIONAL DE MAURICIO

Mauricio ofereceu **exportar todos os forms+módulos do workbook ATUAL** para `local-ai/incoming/`. Isso permite:

- `diff` byte-a-byte contra `src/vba/` → detectar drift (V2_SMOKE!)
- Validar que workbook NÃO tem código órfão (eventos Worksheet, módulos ocultos)
- Confirmar `Cadastro_Servico.frm` real do workbook vs git

**Se você decidir pelo Caminho A** (seguir com workbook atual), peça essa exportação ANTES de qualquer fix — você precisa do diff para entender de onde vêm os 128 caracteres extras.

## ESCOPO PROPOSTO ONDA 38.2.3 (versão preliminar)

Baseado no que sabíamos antes das auditorias cruzadas chegarem. **A onda final será refinada pela leitura das 2 auditorias.**

- **AT-1**: re-sync `Cadastro_Servico.frm` ↔ `.code-only.txt` via `publicar_vba_import_v2.sh --apply` (resolve V2_SMOKE drift)
- **AT-2**: aplicar `NumberFormat = "@"` + `Pad3` em todos os pontos de gravação de IDs em `Repo_PreOS.bas`, `Repo_OS.bas`, `Repo_Avaliacao.bas` (resolve V2_E2E_STRIKES + F-NEW6 sistêmico)
- **AT-3** (provável): introduzir `Util_Planilha.GravarIdTextual(ws, linha, col, idValue)` como helper centralizado — substitui dispersão em uma única função
- **AT-4** (provável, baseado em Antigravity): macro `AuditarIntegridadeReferencial` que roda antes do freeze e bloqueia se invariantes não baterem
- **AT-5** (operacional): teste E2E novo cobrindo fluxo manual de Mauricio (atividade nova → credenciar → emitir Pre-OS → validar empresa selecionada)

Ordem provável: AT-1 isolado em microonda 38.2.3 (trivial); AT-2/3 em 38.2.4 (médio-grande); AT-4/5 em 38.2.5 (suite testes + meta-validação L40).

## RESTRIÇÕES INVIOLÁVEIS

- ✅ HBN ACTIVE
- Bastão com Opus 4.7 até homologação V206
- "FREEZE" só após GATE-FREEZE aprovado em hearback explícito (L39)
- Tabus permanecem (Svc_*, Mod_Types, Importador_V3, Auto_Open, Repos não-Empresa, 10 forms blindados, .frx direto)
- Importação operacional somente via `ImportarPacoteV3_Delta`
- Knowledge 0016 vigente
- L40 ativa — meta-validação dos testes obrigatória antes de freeze

## ORÇAMENTO 50/30/20

Aplicar knowledge 0017 — sinalizar handoff a ~50% contexto. Esta sessão predecessora cumpriu o orçamento (handoff iniciado a ~60%, dentro da exceção documentada por incidente externo + tarefa substantiva grande).

## REFERÊNCIAS

- Handoff origem: [`.hbn/messages/20260527-0930-handoff-fim-sessao-opus.md`](../../.hbn/messages/20260527-0930-handoff-fim-sessao-opus.md)
- Auditorias: [`.hbn/proposals/0009-codex-*.md`](../../.hbn/proposals/0009-codex-auditoria-integridade-idempotencia-v206.md) + [`.hbn/proposals/0010-antigravity-*.md`](../../.hbn/proposals/0010-antigravity-auditoria-integridade-idempotencia-v206.md)
- Prompt origem da auditoria: [`auditoria/00_status/115_PROMPT_AUDITORIA_CRUZADA_INTEGRIDADE_IDEMPOTENCIA.md`](115_PROMPT_AUDITORIA_CRUZADA_INTEGRIDADE_IDEMPOTENCIA.md)
- Relay vivo: [`.hbn/relay/INDEX.md`](../../.hbn/relay/INDEX.md)
- Predecessor 114: [`114_PROMPT_RETOMADA_SESSAO_OPUS.md`](114_PROMPT_RETOMADA_SESSAO_OPUS.md)
- Anchor V206 funcional: `ee75b30` + RVS Trio APROVADO `VR_20260526_102200`
- Anchor de rollback Onda 38.2.2: `179bac5`

---PROMPT FIM---
