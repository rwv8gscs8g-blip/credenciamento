# 07. Plano de Baterias Complementares — V12.0.0189

Este plano propõe cinco baterias (B1..B5) para destravar, validar e expandir a bateria V2, mais uma bateria transversal (B6) dedicada a atomicidade. Para cada bateria: objetivo, pré-condições, cenários, critério de aceitação e esforço estimado.

---

## B1 — Fixer da Baseline Determinística da V2

### Objetivo
Eliminar a falha fatal `EMPRESAS=4 | ENTIDADE=4 | CREDENCIADOS=4 | PRE_OS=1 | CAD_OS=1` na baseline da V2.

### Hipótese-guia
A falha vem da combinação de `TV2_ClearSheet` deixando resíduo em coluna A e `TV2_CountRows` contando por aritmética sobre essa coluna. Documentos 01 e 02 detalham.

### Mudanças propostas no código

**1. Trocar `TV2_CountRows` para semântica via `CountA` na coluna-chave.**

```vb
' Substitui a versao atual em Teste_V2_Engine.bas:828
Public Function TV2_CountRows(ByVal nomeAba As String) As Long
    Dim ws As Worksheet
    Dim col As Long
    Dim rng As Range

    Set ws = ThisWorkbook.Sheets(nomeAba)
    col = TV2_ColunaChave(nomeAba)
    Set rng = ws.Range(ws.Cells(LINHA_DADOS, col), ws.Cells(ws.Rows.Count, col))
    TV2_CountRows = Application.WorksheetFunction.CountA(rng)
End Function

Private Function TV2_ColunaChave(ByVal nomeAba As String) As Long
    Select Case UCase$(nomeAba)
        Case SHEET_EMPRESAS:          TV2_ColunaChave = COL_EMP_ID
        Case SHEET_ENTIDADE:          TV2_ColunaChave = COL_ENT_ID
        Case SHEET_CREDENCIADOS:      TV2_ColunaChave = COL_CRED_ID
        Case SHEET_PREOS:             TV2_ColunaChave = COL_PREOS_ID
        Case SHEET_CAD_OS:            TV2_ColunaChave = COL_OS_ID
        Case Else
            TV2_ColunaChave = 1       ' fallback coluna A
    End Select
End Function
```

**2. Trocar `TV2_NextDataRow` para usar a mesma coluna-chave.**

```vb
Private Function TV2_NextDataRow(ByVal nomeAba As String) As Long
    Dim ws As Worksheet
    Dim col As Long
    Dim ultima As Long

    Set ws = ThisWorkbook.Sheets(nomeAba)
    col = TV2_ColunaChave(nomeAba)
    ultima = ws.Cells(ws.Rows.Count, col).End(xlUp).Row

    If ultima < LINHA_DADOS Then
        TV2_NextDataRow = LINHA_DADOS
    Else
        TV2_NextDataRow = ultima + 1
    End If
End Function
```

**3. Endurecer `TV2_ClearSheet` para limpar pelo menos até `ws.UsedRange`.**

```vb
ultimaLinha = Application.WorksheetFunction.Max(ws.UsedRange.Rows.Count + ws.UsedRange.Row - 1, _
                                                ws.Cells(ws.Rows.Count, 1).End(xlUp).Row)
ultimaColuna = Application.WorksheetFunction.Max(ws.UsedRange.Columns.Count + ws.UsedRange.Column - 1, _
                                                 ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column)
```

Isso garante que o `ClearContents` cubra toda a área que já foi usada, não apenas o que a linha 1 ou a coluna A revelam agora.

### Critério de aceitação
- `CT2_ExecutarSmokeRapido` em planilha com histórico roda até o final sem falha estrutural.
- `TV2_CountRows` retorna 3 para EMPRESAS/ENTIDADE/CREDENCIADOS e 0 para PRE_OS/CAD_OS após `TV2_PrepararCenarioTriploCanonico`.

### Esforço
~3 horas de código + 1 hora de validação no Excel.

---

## B2 — Assert Pós-Reset

### Objetivo
Transformar um fatal tardio durante validação em uma falha cedo e precisa, exatamente no ponto de origem.

### Mudança proposta

Em `TV2_ResetBaseOperacional` (`Teste_V2_Engine.bas:381`), após o loop de `TV2_ClearSheet`:

```vb
For Each nome In Array(SHEET_EMPRESAS, SHEET_ENTIDADE, SHEET_CREDENCIADOS, SHEET_PREOS, SHEET_CAD_OS)
    If TV2_CountRows(CStr(nome)) <> 0 Then
        Err.Raise 1004, "TV2_ResetBaseOperacional", _
            "Aba " & nome & " nao zerou apos reset. Resíduo estrutural. " & _
            "Verificar ListObjects, proteção, ou dados fora do UsedRange."
    End If
Next nome
```

### Critério de aceitação
- Em planilha limpa: reset silencioso.
- Em planilha com resíduo conhecido: mensagem de erro clara identificando a aba com problema.

### Esforço
~30 minutos.

---

## B3 — Migração Gated (MIG_001, MIG_002, MIG_003)

### Objetivo
Migrar as três regras de UI para os serviços correspondentes e transformar os cenários `MIG_*` de `LogManual` para assertivos.

### Mudanças propostas

**MIG_001 em `Svc_PreOS.EmitirPreOS`:**

```vb
' antes de qualquer gravacao
If Not Repo_Entidade.EntidadeExisteEAtiva(entId) Then
    Err.Raise 1001, "Svc_PreOS.EmitirPreOS", "Entidade '" & entId & "' inexistente ou inativa."
End If
If qtdEstimada <= 0 Then
    Err.Raise 1002, "Svc_PreOS.EmitirPreOS", "Quantidade estimada deve ser maior que zero."
End If
```

**MIG_002 em `Svc_OS.EmitirOS`:**

```vb
If dtPrevTermino < dtEmissao Then
    Err.Raise 1003, "Svc_OS.EmitirOS", "Data prevista de término não pode ser anterior à emissão."
End If
```

**MIG_003 em `Svc_Avaliacao.AvaliarOS`:**

```vb
If qtExecutada <> qtEstimada And Trim$(justificativa) = "" Then
    Err.Raise 1004, "Svc_Avaliacao.AvaliarOS", "Divergência de quantidade exige justificativa."
End If
```

### Ajustes na UI

Nos handlers da `Menu_Principal.frm`, capturar os erros (`Err.Number`) e exibir `MsgBox` amigável, mantendo a UX atual.

### Ajustes na V2

Em `Teste_V2_Roteiros.bas`, converter os cenários `MIG_*` de `LogManual` para `AssertError` que verifica `Err.Number` ou que captura o raise esperado.

### Critério de aceitação
- Chamadas diretas aos serviços com entrada inválida resultam em erro.
- UI continua funcionando com a mesma UX.
- `MIG_001`, `MIG_002`, `MIG_003` passam como `PASS` assertivos na V2.

### Esforço
~6 horas (2h por migração).

---

## B4 — Shadow Mode V1 × V2

### Objetivo
Garantir que V2 tem cobertura >= V1 antes de decommissionar V1.

### Procedimento

1. Criar `ferramentas/compara_baterias.py` que lê `RPT_BATERIA` (V1) e `RESULTADO_QA_V2` (V2) e emite diff semântico.
2. A cada release em `EM_VALIDACAO`, rodar V1 e V2 no mesmo estado. Anexar diff em `obsidian-vault/shadow/V12.0.0XXX.md`.
3. Adicionar o novo cenário L6 (nota no limiar) em ambas para validar consistência.

### Critério de aceitação
- 5 releases consecutivas com `|divergência| = 0`.
- Todos os `MIG_*` como `PASS`.
- Nenhum falso-positivo na V2 atribuível à estratégia de contagem (deve ter sido eliminado em B1).

### Esforço
~4 horas de script + execução recorrente por 3-5 sprints.

---

## B5 — Stress e Edge Cases

### Objetivo
Cobrir as lacunas L4, L5, L7, L8, L10, L11 levantadas em 06§4.

### Cenários novos a adicionar em `Teste_V2_Roteiros.bas`:

| ID | Descrição | Cobre |
|----|-----------|-------|
| `EDG_001` | Reativação após `DT_FIM_SUSPENSAO` passada (vencida) | L4 |
| `EDG_002` | Credenciamento SUSPENSO enquanto empresa ATIVA | L5 |
| `EDG_003` | Empresa em última posição com recusa máxima | L7 |
| `EDG_004` | Duas empresas empatadas em POSICAO_FILA | L8 |
| `EDG_005` | Avaliação sobre OS cancelada | L10 |
| `EDG_006` | Cancelamento de OS de empresa já suspensa | L11 |
| `EDG_007` | Nota exatamente no limiar mínimo | L6 |
| `STR_002` | 100 iterações de rodízio com recusas aleatórias | Stress real |
| `STR_003` | Carga inicial com 50 empresas e 30 atividades | Performance |

### Critério de aceitação
- Todos os `EDG_*` passam ou `FAIL` com mensagem semântica.
- `STR_002` completa sem deadlock visível.
- `STR_003` conclui em < 2 minutos.

### Esforço
~10 horas.

---

## B6 — Atomicidade (transversal)

### Objetivo
Detectar e prevenir estados divergentes entre abas.

### Abordagem

1. Criar `Svc_Transacao.bas` com padrão UnitOfWork:

```vb
Public Sub Transacao_Iniciar(ByVal idOp As String)
Public Sub Transacao_RegistrarWrite(ByVal aba As String, ByVal linha As Long, ByVal col As Long, ByVal valorAnterior As Variant)
Public Sub Transacao_Commit()
Public Sub Transacao_Rollback()
```

2. Reescrever `IncrementarRecusa` usando `Transacao_*` para gravar simultaneamente `CREDENCIADOS` e `EMPRESAS`.

3. Criar cenários V2 `ATM_001`..`ATM_005`:

| ID | Descrição |
|----|-----------|
| `ATM_001` | `IncrementarRecusa` com `CREDENCIADOS` protegido (deve reverter antes de escrever `EMPRESAS`) |
| `ATM_002` | `EmitirPreOS` com `PRE_OS` protegido (não deve deixar `POSICAO_FILA` avançada) |
| `ATM_003` | `AvaliarOS` com falha em `CAD_OS` não deve incrementar recusas |
| `ATM_004` | `Suspender` com falha em cascata de `CREDENCIADOS` não deve marcar empresa como SUSPENSA em `EMPRESAS` |
| `ATM_005` | Reativação falhando em `EMPRESAS_INATIVAS` não deve criar duplicata em `EMPRESAS` |

### Critério de aceitação
- Todos os `ATM_*` passam.
- Auditoria na `SHEET_AUDIT` registra início e fim de cada transação.

### Esforço
~12-15 horas (é a mais custosa).

---

## Resumo e ordem de execução

| Ordem | Bateria | Destrava | Custo | Risco de não fazer |
|-------|---------|----------|-------|---------------------|
| 1 | **B1** | V2 rodar | 3h+1h | V2 permanece inutilizável |
| 2 | **B2** | Diagnóstico rápido de resíduos | 30min | Debug caro no futuro |
| 3 | **B3** | MIG_* assertivos | 6h | Regra só na UI, bloqueia SaaS |
| 4 | **B5** | Cobertura de edge cases | 10h | Bugs escapam para produção |
| 5 | **B4** | Confiança para decommissionar V1 | 4h + tempo | Dependência dupla eterna |
| 6 | **B6** | Garantia de atomicidade | 12-15h | Estados divergentes silenciosos |

**Soma total:** ~36-40 horas de engenharia, executáveis em 2-3 sprints.
