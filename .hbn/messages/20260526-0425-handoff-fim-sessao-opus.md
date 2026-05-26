---
titulo: Handoff fim-de-sessão Opus 4.7 — sessão 2026-05-26
de: claude-opus-4-7 (sessão 2026-05-26 14:30→04:25, ~14h)
para: claude-opus-4-7 (próxima sessão)
data: 2026-05-26T04:25:00-03:00
protocolo: HBN knowledge/0014-protocolo-fim-de-sessao
gatilho: explicit_request_mauricio (Opção B de pausa)
sinal-hbn: 🔵 HBN HANDOFF READY
---

# Handoff fim-de-sessão Opus — sessão 2026-05-26

## 1. Onda em curso

**Fechadas nesta sessão (4 ondas):**
- 38.2.1 — revert filtros Menu_Principal (commit `e9bcf42`)
- 38.2.1 (housekeeping) — limpeza working tree (commit `7e98926`)
- 38.2.1-AR1 — saneamento contadores AR1 (commit `ffc8e8a`)
- 38.2.1-AR1 hotfix BUMP — destrava Importador V3 (commit `9592e0f`)
- Fechamento ERP 0106 (commit `433f25c`)

**Em curso**: handoff (esta sessão).

**Próxima onda planejada**: a decidir entre 3 candidatas (ver item 6).

## 2. Último readback (ID + status)

- `.hbn/readbacks/0106-onda38-2-1-ar1-sanear-contadores.json` — `human_status: confirmed`
- `.hbn/readbacks/0107-handoff-fim-sessao-opus.json` — `human_status: confirmed` (este handoff)

## 3. Último ERP (ID + outcome)

- `.hbn/results/0106-exec-onda38-2-1-ar1-sanear-contadores.json` — `human_gate_passed_with_minor_finding`
- Sexteto APROVADO: `VR_20260526_035523` BUILD `e9bcf42+ONDA38.2.1-AR1-sanear-contadores`
  - `V1=171/0 + V2_Smoke=34/0 + V2_Canonica=24/0 + E2E_Strikes=76/0 + IntegridadeBase=4/0 + Onda23Adv=27/0`

## 4. Hearbacks pendentes (lista)

Nenhum readback PENDING aguardando confirmação. Tudo confirmed.

## 5. Sinais HBN abertos (🟡 🟠 🔵 sem resposta)

- 🔵 HBN HANDOFF READY — este handoff (resposta = próxima sessão Opus lê)
- (sem 🟡 nem 🟠 abertos)

## 6. Próxima ação obrigatória (1 frase verb-imperativo)

**Mauricio escolhe entre 3 caminhos** no início da próxima sessão:

- **(A)** **38.2.1-AR1-FIX2** (microdelta urgente, ~5 linhas): mudar algoritmo `SanearContadoresAR1` e `Util_Planilha.ProximoId` para nunca regredir IDs (`max(max_existente, AR1_atual)`).
- **(B)** **38.2.2** (planejado): filtros nativos do Menu_Principal (handlers `TextBoxNN_Change` + função pura).
- **(C)** **38.3 / F5-DEEP** (análise arquitetural): chave estável (CNPJ vs ID monotônico vs soft delete) — decisão de fundo sobre política de deleção de linhas.

**Recomendação Opus**: começar pela **(A)** porque é trivial (~5 linhas, custo nulo) e elimina o risco de reuso de IDs já documentado no F5. Depois (B) (filtros, valor visível imediato). Em paralelo, fazer plano da (C) — mas implementação de (C) provavelmente fica para V207 dependendo do custo arquitetural.

**Pré-trabalho obrigatório antes da 38.2.2**: deep-dive PHAGOCYTOSIS-VBA-PATTERNS (M9, L22, L23, L24, M15, M16, M17 leitura completa) — prometido na sessão anterior.

## 7. Arquivos no scope ativo (paths)

Nenhum scope safe_track ativo. O 0107 (este handoff) é fast_track e fecha junto com a sessão.

A próxima onda abrirá novo readback com novo scope.

## 8. Decisões tomadas em chat mas não documentadas em .md (lista)

Todas documentadas. Resumo das decisões chave:
- **Caminho A** (AR1 antes de 38.2.2) aprovado em chat 2026-05-26 ~15:30.
- **Cleanup categorical a+b+c+d** aprovado (commit 7e98926).
- **Knowledge 0015** (readback opening bootstrap) — aprovado e versionado.
- **Knowledge 0016** (anti-conflito BUMP) — aprovado e versionado.
- **F3** (filtros) — segue plano original Onda 38.2.2.
- **F4** (lentidão cadastros) — **PROMOVIDO** de V207 para V206. Mauricio quer agilidade em PCs antigos.
- **F5** (chave estável) — **PROMOVIDO** para análise arquitetural profunda. CNPJ ou ID monotônico. Análise feita nesta sessão (item 13 abaixo).
- **EMPRESAS_INATIVAS/ENTIDADE_INATIVOS** incluídas como sources do `max(ID)` no `SanearContadoresAR1` (expansão de escopo aceita em chat sem novo hearback formal porque custo marginal = 0).

## 9. Riscos abertos (não fechados pelo rollback_plan)

**Risco R1** — Reuso de IDs em CREDENCIADOS (e potencialmente outras abas):
- CREDENCIADOS!AR1 desceu de 6 para 4 após saneamento (IDs 005 e 006 deletados historicamente).
- Próximo cadastro de credenciamento vai reusar `CRED_ID=005`.
- Logs de auditoria históricos podem ficar ambíguos.
- **Mitigação**: caminho (A) acima — algoritmo monotônico.

**Risco R2** — Lentidão proibitiva em PCs antigos:
- Cadastros de empresa/entidade fazem 15+ escritas célula-a-célula sem `Application.ScreenUpdating = False`.
- Reload completo de lista após cada cadastro.
- **Mitigação**: Onda 38.2.x dedicada à otimização (item 13.B abaixo).

**Risco R3** — F2 (entidade no topo) RESOLVIDO mas não havia diagnóstico de raiz:
- Foi resolvido como efeito colateral do saneamento AR1.
- Não foi confirmado se a causa exata era `ENTIDADE!AR1=0` ou algum bug de ordenação na rotina de preenchimento.
- **Mitigação**: monitorar; se voltar, abrir investigação dedicada.

**Risco R4** — Cobertura inativas não testada (F-NEW1/F-NEW2):
- `EMPRESAS_INATIVAS=0`, `ENTIDADE_INATIVOS=0` no momento do gate da AR1.
- Lógica está pronta, mas não foi exercitada com dados reais.
- **Mitigação**: pedir Mauricio para inabilitar uma empresa de teste na próxima sessão e validar.

## 10. Leituras obrigatórias do sucessor (paths em ordem)

1. [`.hbn/relay/INDEX.md`](.hbn/relay/INDEX.md) — estado vivo
2. **Este handoff** — `.hbn/messages/20260526-0425-handoff-fim-sessao-opus.md`
3. [`auditoria/00_status/106_PROMPT_RETOMADA_SESSAO_OPUS.md`](auditoria/00_status/106_PROMPT_RETOMADA_SESSAO_OPUS.md) — prompt que Mauricio vai colar
4. [`.hbn/results/0106-exec-onda38-2-1-ar1-sanear-contadores.json`](.hbn/results/0106-exec-onda38-2-1-ar1-sanear-contadores.json) — ERP da última onda fechada, contém findings F1-F5
5. [`.hbn/knowledge/0014-protocolo-fim-de-sessao.md`](.hbn/knowledge/0014-protocolo-fim-de-sessao.md) — como ler handoff
6. [`.hbn/knowledge/0015-readback-opening-bootstrap.md`](.hbn/knowledge/0015-readback-opening-bootstrap.md) — bootstrap de novo readback
7. [`.hbn/knowledge/0016-bump-build-label-anti-conflito.md`](.hbn/knowledge/0016-bump-build-label-anti-conflito.md) — anti-conflito BUMP App_Release
8. [`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`](usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md) — deep-dive M9, L22-L24, M15-M17 (pré-trabalho da 38.2.2)
9. [`AGENTS.md`](AGENTS.md) — entrada canônica

## 11. Comando único para validar estado ao retomar

```bash
cd /Users/macbookpro/Projetos/Credenciamento && \
git log --oneline -6 && \
git status -s && \
bash scripts/hbn-guards/hbn-guards-runner.sh
```

Esperado:
- HEAD em commit `<últimocommit>` (será o de handoff)
- Working tree limpo (zero alterações pendentes)
- 5/5 guards verdes

## 12. Sinal 🔵 HBN HANDOFF READY

Marcado em `.hbn/relay/INDEX.md` no cabeçalho YAML. Próxima IA Opus consome este handoff antes de qualquer ação.

---

## 13. Análise técnica F4 + F5 (entrada extra além dos 12 itens)

### 13.A — F4 análise: causa raiz da lentidão

**Causa confirmada por grep:**

```bash
grep -rln "Application.ScreenUpdating" src/vba/
# Retorna: APENAS arquivos de teste e Configuracao_Inicial.
# Nenhuma rotina de produção (Repo_Empresa.Inserir, Repo_Empresa.Atualizar,
# Cadastros, Preencher*) desliga ScreenUpdating ou Calculation.
```

**`Repo_Empresa.Inserir`** ([src/vba/Repo_Empresa.bas:215-275](src/vba/Repo_Empresa.bas#L215-L275)):
- Faz **17 escritas célula-a-célula** sequenciais
- Cada `ws.Cells(novaLinha, COL_XXX).Value = ...` triggera:
  - Recalc da aba (Calculation = Automatic)
  - Repaint (ScreenUpdating = True)
  - Eventos Change/SelectionChange (EnableEvents = True)
- Em PC antigo isso multiplica a latência por 17x ou mais

**Mesmas características em**: `Repo_Empresa.Atualizar`, fluxos de cadastro de entidade, serviço, etc.

**Soluções propostas para nova sessão (estimativas):**

#### S1 — Quick win: wrapper de otimização Excel

Criar `src/vba/Util_Excel_Performance.bas`:
```vba
Public Type TEstadoExcel
    screenUpdating As Boolean
    calculation As XlCalculation
    enableEvents As Boolean
    displayAlerts As Boolean
End Type

Public Function Util_IniciarBlocoRapido() As TEstadoExcel
    Dim st As TEstadoExcel
    st.screenUpdating = Application.ScreenUpdating
    st.calculation = Application.Calculation
    st.enableEvents = Application.EnableEvents
    st.displayAlerts = Application.DisplayAlerts
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False
    Application.DisplayAlerts = False
    Util_IniciarBlocoRapido = st
End Function

Public Sub Util_FinalizarBlocoRapido(ByRef st As TEstadoExcel)
    Application.ScreenUpdating = st.screenUpdating
    Application.Calculation = st.calculation
    Application.EnableEvents = st.enableEvents
    Application.DisplayAlerts = st.displayAlerts
End Sub
```

Aplicar wrapper em todas as funções de cadastro/preenchimento/saneamento. **Estimativa: 10-30x mais rápido em PCs antigos.** Custo: ~50 chamadas a inserir em ~10 rotinas.

#### S2 — Escrita em bloco (médio prazo)

Substituir as 17 escritas célula-a-célula por **uma única atribuição de array**:

```vba
Dim valores(1 To 1, 1 To 17) As Variant
valores(1, COL_EMP_ID) = novoID
valores(1, COL_EMP_CNPJ) = cnpjVal
' ... (15 mais)
ws.Range(ws.Cells(novaLinha, 1), ws.Cells(novaLinha, 17)).Value = valores
```

**Estimativa: 5-10x adicional sobre S1.**

#### S3 — Lazy reload de listas

Após cadastro, em vez de reconstruir a ListBox inteira:
- Apenas `ListBox.AddItem` da nova linha
- Manter ordem com ressort local se necessário

**Estimativa: 3-5x mais rápido em listas grandes.**

**Recomendação combinada**: S1 imediatamente (Onda 38.2.x-perf), S2+S3 como microdeltas seguintes ou agrupar.

### 13.B — F5 análise: política de chaves estáveis + deleção de linhas

**Mapeamento da deleção real no código** ([Util_Planilha.bas:92-129](src/vba/Util_Planilha.bas#L92-L129)):

`Util_ExcluirLinhaSegura` é chamada em **4 fluxos de produção**:

| Caller | Aba | Motivo |
|---|---|---|
| `Svc_Entidade.ReativarEntidadePorChave:137` | ENTIDADE_INATIVOS | reativação (remove da inativa após copiar para ativa) |
| `Svc_Entidade.ReativarEntidadePorChave:167` | ENTIDADE | rollback em erro |
| `Reativa_Empresa.frm:346` | EMPRESAS_INATIVAS | reativação |
| `Reativa_Empresa.frm:367` | EMPRESAS | rollback |
| `Menu_Principal.frm:151` (`A_Excluir_Click`) | ATIVIDADE ESCOLHIDA | exclusão de atividade |

**Insight crítico**: o fluxo de **reativação** REMOVE a linha de INATIVAS após copiar pra ativa. Quando alguém é inabilitada → reativada → inabilitada de novo, a linha vai e volta mas mantém o mesmo `EMP_ID`. **Não há mudança de ID neste fluxo.**

**Onde acontece reuso de ID?** Apenas em dois cenários:
1. **Deleção manual** do operador na planilha (Shift+Delete em linha) — bypassa o fluxo. Caso CREDENCIADOS!AR1 6→4.
2. **Bug ou exceção** que apague mais do que devia.

**Hipóteses para o relato do Mauricio** ("cada vez que é inabilitada e reabilitada herda nova numeração"):
- **(H1)** Mauricio observou o ID 001 do cadastro novo (que era da regressão F1, agora resolvida) e atribuiu erradamente ao fluxo de inabilitação. Hipótese plausível: F1 e F5 foram conflados.
- **(H2)** Há um caminho oculto de deleção que reseta o AR1. **Verificar na próxima sessão**.

### 13.C — F5 alternativas para chave estável

#### Alternativa A — ID sequencial monotônico (recomendada como primeira camada)

**Mudança**: `Util_Planilha.ProximoId` e `Util_Sanear_Contadores.SanearContadoresAR1` usam:
```vba
maxId = max(max(coluna_A_em_todas_as_sources), CLng(Val(AR1_atual)))
AR1 = maxId
ProximoId retorna Format$(AR1 + 1, "000")  ' incrementa
```

Em outras palavras: AR1 **nunca decresce**.

- **Custo**: ~5-10 linhas modificadas em 2 funções.
- **Vantagem**: IDs nunca são reusados; histórico íntegro.
- **Desvantagem**: gaps na sequência (CRED_IDs 005 e 006 ficam como "buracos"). Aceitável.
- **Onda**: 38.2.1-AR1-FIX2 (microdelta de 5 linhas).

#### Alternativa B — CNPJ como chave secundária estável (para relatórios/auditoria)

Mantém EMP_ID como chave da aba (rápida, curta, usada por SQL-like lookups). Adicionalmente:
- Relatórios **sempre incluem CNPJ** ao lado de EMP_ID.
- Logs de auditoria (`Audit_Log.bas`) **gravam CNPJ junto com EMP_ID**.
- Rastreabilidade histórica: "EMP_ID=005 do RELATÓRIO_2024-03 referencia CNPJ=12.345.678/0001-90" — mesmo se EMP_ID=005 for reusado, o CNPJ identifica a empresa original.

- **Custo**: médio (atualizar formato de logs + relatórios). Não toca lógica do rodízio.
- **Vantagem**: rastreabilidade histórica preservada mesmo com reuso de ID.
- **Onda**: 38.4 ou similar (escopo médio).

#### Alternativa C — Soft delete (não deletar linhas físicas)

Mudar todos os `Util_ExcluirLinhaSegura` para marcar `STATUS=EXCLUIDO` em coluna nova.

- **Custo**: alto (toca 5 callers + lógica de filtragem em todo lugar que itera as abas).
- **Vantagem**: histórico nunca se perde, sem necessidade de tabela INATIVAS.
- **Desvantagem**: tabelas crescem indefinidamente, performance degrada lentamente, refactor amplo.
- **Risco**: pode introduzir bugs em rotinas que assumem que ler de EMPRESAS retorna apenas ativas.
- **Onda**: provavelmente V207 (não V206).

#### Alternativa D — UUID/GUID — DESCARTADA

VBA não tem suporte ergonômico; performance pior; mudança radical.

### 13.D — Validação exaustiva (Mauricio pediu)

Bateria de testes propostos para a próxima sessão:

| ID | Cenário | Pré-condição | Ação | Esperado |
|---|---|---|---|---|
| T1 | Inabilitar e reabilitar empresa | Empresa 1 ativa | Inabilita → Reabilita | Mesma empresa, mesmo ID, mesmo CNPJ |
| T2 | Inabilitar empresa de maior ID, cadastrar nova | EMPRESAS tem 4 empresas (IDs 001-004) | Inabilita 004 → cadastra nova | Nova empresa ID=005 (não 004) — **valida F-NEW1** |
| T3 | Deletar manualmente empresa 003 da planilha, cadastrar nova | EMPRESAS tem 4 | Shift+Delete linha 003 → cadastra nova | Após `SanearContadoresAR1`, AR1 ainda em 4 com algoritmo monotônico (Alt. A) |
| T4 | Rodízio com empresa inabilitada | 3 empresas ativas + 1 inabilitada | Rodar `SelecionarEmpresa(ativ_id)` | Inabilitada NÃO é escolhida (FILTRO B/C aplicam) |
| T5 | Reabilitar empresa que tinha OS aberta | Empresa 002 inativa com OS_ID=X | Reabilita | OS_ID=X permanece linkada à mesma empresa |
| T6 | Stress test cadastro (10 empresas seguidas) | EMPRESAS vazia | Cadastrar 10 sem fechar form | Cada uma com ID sequencial e tempo razoável (com S1 aplicado) |
| T7 | Performance medida em PC antigo | Setup Mauricio | Cadastrar 1 empresa antes e depois de S1 | Tempo final < 2s (objetivo) |

### 13.E — Sequência proposta para a próxima sessão

```
38.2.1-AR1-FIX2 (microdelta ~5 linhas)
    → ID monotônico em ProximoId + saneamento
    → resolve R1 definitivamente

38.2.x-perf (otimização Excel)
    → S1 (wrapper Util_Excel_Performance) em rotinas críticas
    → resolve R2

38.2.2 (filtros nativos Menu_Principal)
    → handlers TextBoxNN_Change + função pura
    → resolve F3
    → PRÉ-TRABALHO: deep-dive PHAGOCYTOSIS

38.2.3 (testes T1-T7 + cobertura F-NEW1/F-NEW2)
    → bateria exaustiva inabilitar/reabilitar/rodízio
    → resolve R3, R4

38.4 (CNPJ em relatórios/logs de auditoria)
    → Alternativa B (chave secundária estável)
    → opcional V206; pode ir V207

Freeze V12.0.0206 + tag pública GitHub
```

---

## Memory updates relevantes para próxima sessão

- Onda 38.2.1 + 38.2.1-AR1 fechadas com Sexteto APROVADO.
- F1+F2 resolvidos; F3 deferido p/ 38.2.2; F4+F5 promovidos para V206.
- Knowledges HBN novas: 0015 (readback bootstrap) + 0016 (anti-conflito BUMP).
- Pattern emergente: deixar `App_Release.bas` no estado da onda anterior para que o Importador V3 faça BUMP corretamente.
- Pattern emergente: incluir abas pareadas inativas como sources do `max(ID)` no saneamento.

## Encerramento

Bastão permanece com **Claude Opus 4.7**. Próxima sessão começa com o prompt de retomada em
`auditoria/00_status/106_PROMPT_RETOMADA_SESSAO_OPUS.md` colado por Mauricio no primeiro turno.

Working tree limpo. RVS Sexteto válido como anchor funcional. Pronto para retomar com sessão fresca.

🔵 HBN HANDOFF READY
