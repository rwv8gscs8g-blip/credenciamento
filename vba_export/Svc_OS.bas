Attribute VB_Name = "Svc_OS"
Option Explicit

' Serviço de OS — V10
' Implementa: EmitirOS, CancelarOS.
' EmitirOS converte PRE_OS aceita em OS formal (STATUS=EM_EXECUCAO).
' CancelarOS encerra OS com STATUS=CANCELADA.
' Sem Select/ActiveCell/On Error Resume Next silencioso.
'
' POLÍTICA AvancarFila em EmitirOS (critério 48):
'   Auditoria gravada ANTES de AvancarFila.
'   Se AvancarFila falhar: res.Sucesso=True, res.Mensagem inclui "AVISO:".

Private Const STATUS_OS_EXEC    As String = "EM_EXECUCAO"
Private Const STATUS_OS_CANCEL  As String = "CANCELADA"
Private Const STATUS_PREOS_AGU  As String = "AGUARDANDO_ACEITE"
Private Const STATUS_PREOS_CONV As String = "CONVERTIDA_OS"

' ============================================================
' SEÇÃO 1: EMISSÃO DE OS
' ============================================================

Public Function EmitirOS( _
    ByVal PREOS_ID As String, _
    ByVal DT_PREV_TERMINO As Date, _
    ByVal NUM_EMPENHO As String _
) As TResult
    Dim res As TResult
    Dim linhaPreOS As Long
    Dim preos As TPreOS
    Dim os As TOS
    Dim ws As Worksheet
    Dim resInsert As TResult
    Dim resAv As TResult
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo Erro

    ' 1. Ler e validar PRE_OS (critérios 20-21)
    LerPreOSCompleto PREOS_ID, linhaPreOS, preos

    If linhaPreOS = 0 Then
        res.Sucesso = False
        res.Mensagem = "Pre-OS nao encontrada: PREOS_ID=" & PREOS_ID
        EmitirOS = res
        Exit Function
    End If

    If preos.STATUS_PREOS <> STATUS_PREOS_AGU Then
        res.Sucesso = False
        res.Mensagem = "Pre-OS nao pode ser convertida. STATUS=" & preos.STATUS_PREOS
        EmitirOS = res
        Exit Function
    End If

    If DT_PREV_TERMINO < Date Then
        res.Sucesso = False
        res.Mensagem = "Data prevista de termino nao pode ser anterior a hoje."
        EmitirOS = res
        Exit Function
    End If

    ' 2. Montar TOS a partir da Pré-OS (critério 23)
    os.PREOS_ID = PREOS_ID
    os.EMP_ID = preos.EMP_ID
    os.ATIV_ID = preos.ATIV_ID
    os.SERV_ID = preos.SERV_ID
    os.ENT_ID = preos.ENT_ID
    os.QT_ESTIMADA = preos.QT_ESTIMADA
    os.QT_CONFIRMADA = preos.QT_ESTIMADA
    os.VALOR_UNIT = preos.VALOR_UNIT
    os.VALOR_TOTAL_OS = preos.VALOR_ESTIMADO
    os.NUM_EMPENHO = NUM_EMPENHO
    os.DT_EMISSAO = Now
    os.DT_PREV_TERMINO = DT_PREV_TERMINO
    os.STATUS_OS = STATUS_OS_EXEC
    os.JUSTIF_DIVERGENCIA = ""

    ' 3. Inserir OS via Repo_OS (os.OS_ID preenchido ByRef — critérios 23-24)
    resInsert = Repo_OS.Inserir(os)
    If Not resInsert.Sucesso Then
        res.Sucesso = False
        res.Mensagem = "Falha ao inserir OS: " & resInsert.Mensagem
        EmitirOS = res
        Exit Function
    End If

    ' 4. Atualizar PRE_OS (critério 25)
    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.Sucesso = False
        res.Mensagem = "Nao foi possivel preparar PRE_OS para escrita."
        EmitirOS = res
        Exit Function
    End If
    ws.Cells(linhaPreOS, COL_PREOS_STATUS).Value = STATUS_PREOS_CONV
    ws.Cells(linhaPreOS, COL_PREOS_OS_ID).Value = os.OS_ID
    ws.Cells(linhaPreOS, COL_PREOS_DT_EM_OS).Value = Now

    ' 5. Auditoria ANTES de AvancarFila (critério 27)
    Audit_Log.RegistrarEvento _
        EVT_OS_EMITIDA, ENT_OS, os.OS_ID, _
        "", _
        "STATUS=EM_EXECUCAO; PREOS_ID=" & PREOS_ID & _
        "; EMP_ID=" & os.EMP_ID & "; ATIV_ID=" & os.ATIV_ID & _
        "; ENT_ID=" & os.ENT_ID & "; QT_EST=" & CStr(os.QT_ESTIMADA) & _
        "; VL_TOTAL=" & CStr(os.VALOR_TOTAL_OS) & _
        "; DT_PREV=" & Format$(DT_PREV_TERMINO, "DD/MM/YYYY"), _
        "Svc_OS"

    ' 6. AvancarFila SEM punição (critério 26) — falha = AVISO (critério 48)
    resAv = AvancarFila(preos.EMP_ID, preos.ATIV_ID, False, "ACEITE_OS_EMITIDA")

    AppContext.SetOS os

    res.Sucesso = True
    res.IdGerado = os.OS_ID
    If resAv.Sucesso Then
        res.Mensagem = "OS emitida. OS_ID=" & os.OS_ID & "; PREOS_ID=" & PREOS_ID
    Else
        res.Mensagem = "OS emitida. OS_ID=" & os.OS_ID & "; PREOS_ID=" & PREOS_ID & _
                       " | AVISO: falha ao avançar fila: " & resAv.Mensagem
    End If
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    EmitirOS = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.Sucesso = False
    res.Mensagem = "Erro em EmitirOS: " & Err.Description
    res.CodigoErro = Err.Number
    EmitirOS = res
End Function

' ============================================================
' SEÇÃO 2: CANCELAMENTO DE OS
' ============================================================

Public Function CancelarOS( _
    ByVal OS_ID As String, _
    ByVal motivo As String _
) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim i As Long
    Dim linhaOS As Long
    Dim statusAtual As String
    Dim empId As String
    Dim ativId As String
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo Erro

    linhaOS = 0
    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_OS)
        If IdsIguais(ws.Cells(i, COL_OS_ID).Value, OS_ID) Then
            linhaOS = i
            statusAtual = CStr(ws.Cells(i, COL_OS_STATUS).Value)
            empId = CStr(ws.Cells(i, COL_OS_EMP_ID).Value)
            ativId = CStr(ws.Cells(i, COL_OS_ATIV_ID).Value)
            Exit For
        End If
    Next i

    If linhaOS = 0 Then
        res.Sucesso = False
        res.Mensagem = "OS nao encontrada: OS_ID=" & OS_ID
        CancelarOS = res
        Exit Function
    End If

    If statusAtual <> STATUS_OS_EXEC Then
        res.Sucesso = False
        res.Mensagem = "OS nao pode ser cancelada. STATUS=" & statusAtual
        CancelarOS = res
        Exit Function
    End If

    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.Sucesso = False
        res.Mensagem = "Nao foi possivel preparar CAD_OS para escrita."
        CancelarOS = res
        Exit Function
    End If

    ws.Cells(linhaOS, COL_OS_STATUS).Value = STATUS_OS_CANCEL
    ws.Cells(linhaOS, COL_OS_JUSTIF_DIV).Value = motivo
    ws.Cells(linhaOS, COL_OS_DT_FECHAMENTO).Value = Now

    Audit_Log.RegistrarEvento _
        EVT_OS_CANCELADA, ENT_OS, OS_ID, _
        "STATUS=EM_EXECUCAO", _
        "STATUS=CANCELADA; MOTIVO=" & motivo & _
        "; EMP_ID=" & empId & "; ATIV_ID=" & ativId, _
        "Svc_OS"

    AppContext.Invalidate

    res.Sucesso = True
    res.Mensagem = "OS " & OS_ID & " cancelada."
    res.IdGerado = OS_ID
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    CancelarOS = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.Sucesso = False
    res.Mensagem = "Erro em CancelarOS: " & Err.Description
    res.CodigoErro = Err.Number
    CancelarOS = res
End Function

' ============================================================
' SEÇÃO 3: HELPER PRIVADO
' ============================================================

Private Sub LerPreOSCompleto( _
    ByVal PREOS_ID As String, _
    ByRef linhaOut As Long, _
    ByRef preosOut As TPreOS _
)
    Dim ws As Worksheet
    Dim i As Long
    Dim codServ As String
    Dim rawDt As Variant

    linhaOut = 0
    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_PREOS)
        If IdsIguais(ws.Cells(i, COL_PREOS_ID).Value, PREOS_ID) Then
            linhaOut = i
            preosOut.PREOS_ID = PREOS_ID
            preosOut.ENT_ID = CStr(ws.Cells(i, COL_PREOS_ENT_ID).Value)
            codServ = CStr(ws.Cells(i, COL_PREOS_COD_SERV).Value)
            preosOut.ATIV_ID = CStr(ws.Cells(i, COL_PREOS_ATIV_ID).Value)
            preosOut.SERV_ID = ExtrairServId(codServ, preosOut.ATIV_ID)
            preosOut.EMP_ID = CStr(ws.Cells(i, COL_PREOS_EMP_ID).Value)
            preosOut.QT_ESTIMADA = CDbl(Val(ws.Cells(i, COL_PREOS_QT_EST).Value))
            preosOut.VALOR_UNIT = CCur(Val(ws.Cells(i, COL_PREOS_VL_UNIT).Value))
            preosOut.VALOR_ESTIMADO = CCur(Val(ws.Cells(i, COL_PREOS_VL_EST).Value))
            preosOut.STATUS_PREOS = CStr(ws.Cells(i, COL_PREOS_STATUS).Value)
            rawDt = ws.Cells(i, COL_PREOS_DT_LIMITE).Value
            If IsDate(rawDt) Then
                preosOut.DT_LIMITE_ACEITE = CDate(rawDt)
            Else
                preosOut.DT_LIMITE_ACEITE = CDate(0)
            End If
            Exit For
        End If
    Next i

fim:
End Sub

Private Function ExtrairServId(ByVal codServ As String, ByVal ativId As String) As String
    Dim p As Long
    Dim s As String
    Dim a As String

    s = Trim$(CStr(codServ))
    a = Trim$(CStr(ativId))
    If s = "" Then Exit Function

    p = InStr(1, s, "|", vbBinaryCompare)
    If p > 1 Then
        ExtrairServId = Trim$(Mid$(s, p + 1))
        Exit Function
    End If

    If a <> "" Then
        If Left$(s, Len(a)) = a Then
            ExtrairServId = Mid$(s, Len(a) + 1)
            Exit Function
        End If
    End If

    ' Fallback legado AAASSS
    If Len(s) >= 4 Then
        ExtrairServId = Mid$(s, 4)
    End If
End Function

' IdsEquivalentesOS removida — usar Util_Planilha.IdsIguais (V12-CLEAN).


