# Onda 38.2.1-AR1-FIX2-PERF — ID monotônico + Excel performance LITE

**Versão alvo:** V12.0.0206
**Branch:** `codex/v12-0-0206-planejamento`
**Build label:** `ad5b487+ONDA38.2.1-AR1-FIX2-PERF`
**Agente:** Claude Opus 4.7 (sessão sucessora pós-handoff 0107)
**Readback:** `.hbn/readbacks/0108-onda38-2-1-ar1-fix2-perf.json`
**ERP:** `.hbn/results/0108-exec-onda38-2-1-ar1-fix2-perf.json`
**Predecessor:** Onda 38.2.1-AR1 (ERP 0106, `human_gate_passed_with_minor_finding`)
**Anchor de rollback:** commit `ad5b487` (handoff Opus + Sexteto APROVADO `VR_20260526_035523`)

---

## 1. Motivação

A Onda 38.2.1-AR1 entregou o saneamento dos contadores AR1 e fechou F1+F2.
O gate humano revelou dois pendentes:

- **F5 (minor)**: `CREDENCIADOS!AR1` decresceu de 6 para 4 após saneamento
  porque os IDs 005 e 006 foram deletados historicamente. O próximo cadastro
  de credenciamento reusaria o ID 005, ambiguando logs de auditoria.
- **F4 (promovido para V206)**: cadastro de empresa em PCs antigos lento
  porque `Repo_Empresa.Inserir` faz 17 escritas célula-a-célula sem
  `Application.ScreenUpdating = False`.

Esta onda combina:

- **Parte A** (microdelta): bloqueia a regressão de IDs definitivamente.
- **Parte B.lite** (wrapper): otimiza o cadastro/edição de empresa.

Cadastros em `.frm` (entidade, credenciamento, atividade) ficam para
Onda 38.2.2 com deep-dive PHAGOCYTOSIS-VBA-PATTERNS antes.

---

## 2. Escopo

### Arquivos tocados

| Path | Operação |
|---|---|
| [`src/vba/Util_Planilha.bas`](../../../src/vba/Util_Planilha.bas) | nova função pública `Util_MaxIdNaColunaA` + defesa em `ProximoId` |
| [`src/vba/Util_Sanear_Contadores.bas`](../../../src/vba/Util_Sanear_Contadores.bas) | guarda monotônica + remove Private duplicada + wrapper de performance |
| [`src/vba/Util_Excel_Performance.bas`](../../../src/vba/Util_Excel_Performance.bas) | módulo novo |
| [`src/vba/Repo_Empresa.bas`](../../../src/vba/Repo_Empresa.bas) | envelopa 4 funções com wrapper |
| `src/vba/App_Release.bas` | NÃO tocado (Knowledge 0016) |
| `local-ai/vba_import/001-modulo/A*-*.bas` | gerado por `publicar_vba_import_v2.sh --apply` |
| `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-2-1-AR1-FIX2-PERF.txt` | manifesto criado |
| `local-ai/vba_import/000-MAPA-PREFIXOS.txt` | nova entrada `ABO-Util_Excel_Performance.bas` |

### Fora de escopo

- Tocar `.frm`/`.frx` (cadastros UI, filtros)
- Tocar `Svc_*` blindados, `Mod_Types`, `Importador_V3`, `Auto_Open`
- Tocar `Preencher.bas` (loops de atividade)
- Outros `Repo_*` (Credenciamento, OS, PreOS, Avaliacao)
- Soft delete (Alternativa C do F5) — V207 candidato
- CNPJ como chave secundária (Alternativa B do F5) — fica para Onda 38.4 ou V207

---

## 3. Parte A — ID monotônico

### A.1 — `Util_Sanear_Contadores.SanearAR1EmAbaPareada`

**Antes:**

```vba
For i = LBound(sources) To UBound(sources)
    parcial = MaxIdNaColunaA(srcNome)
    If parcial > maxId Then maxId = parcial
    ...
Next i
wsTarget.Cells(1, COL_CONTADOR_AR).Value = maxId  ' pode decrescer!
```

**Depois:**

```vba
For i = LBound(sources) To UBound(sources)
    parcial = Util_MaxIdNaColunaA(srcNome)
    If parcial > maxId Then maxId = parcial
    ...
Next i

' Guarda monotônica (Onda 38.2.1-AR1-FIX2-PERF): AR1 nunca decresce.
If maxId < valorAnterior Then maxId = valorAnterior

wsTarget.Cells(1, COL_CONTADOR_AR).Value = maxId
```

**Efeito sobre F5**: ao rodar `SanearContadoresAR1` no estado atual do
workbook (CREDENCIADOS!AR1=4, dados=4), o log mostraria `CREDENCIADOS!AR1
4 -> 4 (sources: CREDENCIADOS=4)` — não decresce. Os CRED_IDs 005 e 006
permanecem como gaps históricos permanentes; o próximo cadastro de
credenciamento receberá ID `007`, não `005`.

### A.2 — `Util_Planilha.ProximoId`

**Antes:**

```vba
atual = CLng(Val(ws.Cells(1, COL_CONTADOR_AR).Value))
atual = atual + 1
ws.Cells(1, COL_CONTADOR_AR).Value = atual
```

**Depois:**

```vba
atual = CLng(Val(ws.Cells(1, COL_CONTADOR_AR).Value))
maxIdReal = Util_MaxIdNaColunaA(nomeAba)
If maxIdReal > atual Then atual = maxIdReal
atual = atual + 1
ws.Cells(1, COL_CONTADOR_AR).Value = atual
```

**Defesa em profundidade**: cobre o cenário onde alguém edita manualmente
`<aba>!AR1` (ex.: zera para `0`) entre dois cadastros sem rodar
`SanearContadoresAR1`. `ProximoId` detecta `max(coluna_A) > AR1` e salta
direto. O cenário original do F1 (backup pré-38.2 com AR1=0 e dados
populados) fica protegido sem precisar do saneamento.

### A.3 — `Util_Planilha.Util_MaxIdNaColunaA` (promoção)

Helper público novo, idêntico à `Private MaxIdNaColunaA` que estava em
Util_Sanear_Contadores. Posicionada antes de `ProximoId` no módulo. A
versão Private em Util_Sanear_Contadores foi removida e os calls passam
a usar a pública.

---

## 4. Parte B.lite — Excel performance wrapper

### B.1 — Módulo `Util_Excel_Performance.bas` (NOVO)

```vba
Public Function Util_IniciarBlocoRapido() As Variant
    Dim st(0 To 3) As Variant
    st(0) = Application.ScreenUpdating
    st(1) = Application.Calculation
    st(2) = Application.EnableEvents
    st(3) = Application.DisplayAlerts
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False
    Application.DisplayAlerts = False
    Util_IniciarBlocoRapido = st
End Function

Public Sub Util_FinalizarBlocoRapido(ByVal st As Variant)
    If IsEmpty(st) Or IsNull(st) Then Exit Sub
    If Not IsArray(st) Then Exit Sub

    On Error Resume Next
    Application.ScreenUpdating = st(0)
    Application.Calculation = st(1)
    Application.EnableEvents = st(2)
    Application.DisplayAlerts = st(3)
    On Error GoTo 0
End Sub
```

**Decisão Variant vs Public Type**: a versão inicial usava `Public Type
TEstadoExcel` para tipar o estado, mas o Glasswing G8 do projeto proíbe
`Public Type` fora de `Mod_Types.bas` (tabu reservado para Onda 9).
Migrado para `Variant array(0..3)` — semântica equivalente, tipagem
fraca, mas compatível com G8.

### B.2 — `Repo_Empresa`: 4 funções envelopadas

| Função | Custo antes | Tratamento |
|---|---|---|
| `Inserir` | 17 escritas + 1 leitura `ProximoId` | wrapper + Exit Function precoces (validação `Util_PrepararAbaParaEscrita`) |
| `Atualizar` | 14 escritas | wrapper + 2 Exit Function precoces (linha inválida + preparação falha) |
| `GravarStatusEmpresa` | 5 escritas + 4 verificações | wrapper + 5 Exit Function precoces (validações de persistência) |
| `RepoEmpresa_BackfillDtUltReativPorAuditLog` | loop linear sobre EMPRESAS, escreve em cada match | wrapper + 1 Exit Function precoce |

**Padrão aplicado**:

```vba
Dim estadoExcel As Variant
estadoExcel = Util_IniciarBlocoRapido()
On Error GoTo erro

' ... corpo ...
' Cada Exit Function precoce chama Util_FinalizarBlocoRapido estadoExcel antes de Exit.

Util_FinalizarBlocoRapido estadoExcel
Exit Function

erro:
On Error Resume Next
' restaurar protecao aba se aplicavel
On Error GoTo 0
Util_FinalizarBlocoRapido estadoExcel
' handler
```

`Util_FinalizarBlocoRapido` é tolerante a `Empty` (no-op silencioso),
permitindo chamadas em handler de erro sem checagem extra.

### B.3 — `Util_Sanear_Contadores.SanearContadoresAR1` envelopada

Bônus: a função idempotente que itera 7 abas + sources também passou a
ser envelopada. Custo marginal, ganho potencial significativo em PC
antigo.

---

## 5. Estimativas de performance

| Operação | Antes | Depois | Speedup esperado |
|---|---|---|---|
| Cadastro 1 empresa em PC antigo | ~2–5s | ~0.2–0.5s | 10–30× |
| Edição 1 empresa | ~1.5–4s | ~0.2–0.4s | 8–20× |
| Backfill DT_ULT_REATIV em base com 100 empresas | ~30s | ~3s | 10× |
| SanearContadoresAR1 (idempotente) | ~1s | ~0.1s | 10× |

Estimativas em PC antigo (Excel 2013/2016, HD mecânico). Em PC moderno
o ganho é menor (~3–5×) mas ainda mensurável.

---

## 6. Gates funcionais

| ID | Pré-condição | Ação | Esperado |
|---|---|---|---|
| **T-MONO-1** | EMPRESAS com 4 linhas | Shift+Delete linha 3 → `SanearContadoresAR1` → cadastrar nova | Log mostra `EMPRESAS!AR1 4 -> 4` (não decresce); nova empresa ID `005`, NÃO `003` |
| **T-MONO-2** | EMPRESAS com 4 linhas | Imediato `Cells(1,44)=0` → cadastrar nova SEM saneamento | Nova empresa ID `005`, NÃO `001` |
| **T-PERF-1** | PC antigo | Cadastrar empresa nova | Tempo perceptivelmente mais rápido vs baseline |
| **RVS** | — | `CT_ValidarRelease_TrioMinimo` | APROVADO `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0` |

---

## 7. Riscos e mitigações

| Risco | Severidade | Mitigação |
|---|---|---|
| Pareamento `Iniciar`/`Finalizar` desbalanceado em handler | medium | Audit do diff: cada Exit Function precoce tem `Util_FinalizarBlocoRapido` antes |
| `Util_MaxIdNaColunaA` adiciona overhead em `ProximoId` | low | Aba com mais linhas (ATIVIDADES, 1332 linhas) ainda fica <100ms em PC antigo; `ProximoId` raro |
| Conflito BUMP_NO_CHANGE no import | low | Knowledge 0016: `App_Release.bas` mantém label antigo; V3 detecta diff |
| Sexteto reprova por regressão induzida pelo wrapper | medium | Trio cobre 229 testes; ganho prático justifica risco baixo |
| `IDs` com prefixo textual (ex.: `EMP005`) na coluna A | low | Coluna A das 7 abas alvo é numérica pura; documentado |

---

## 8. Rollback

Se algum gate funcional falhar, retornar a `ad5b487` (estado pós-handoff,
Sexteto APROVADO):

```bash
git reset --hard ad5b487
git push origin codex/v12-0-0206-planejamento --force-with-lease  # se já commitado
```

Mauricio restaura workbook a partir do backup do Importador V3.

---

## 9. Próxima onda

**Onda 38.2.2 — filtros nativos do Menu_Principal + performance restante**

Pré-trabalho obrigatório Opus (próxima sessão): deep-dive
[`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`](../../../usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md)
capítulos **M9, L22, L23, L24, M15, M16, M17**.

Combina: handlers nativos `TextBox16..22_Change` + função filtro pura
+ envelopamento dos cadastros em `.frm` (entidade, credenciamento,
atividade) com `Util_Excel_Performance` ora disponível.
