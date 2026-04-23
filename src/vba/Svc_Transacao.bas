Attribute VB_Name = "Svc_Transacao"
Option Explicit

' Transacao minima para rollback de writes cruzados entre abas.
' Nesta fase a solucao e propositalmente pequena: registrar valores anteriores
' e restaurar em ordem reversa quando uma etapa posterior falhar.

Private gTransacaoAtiva As Boolean
Private gTransacaoId As String
Private gTransacaoWrites() As Variant
Private gTransacaoWriteCount As Long

Public Sub Transacao_Iniciar(Optional ByVal idOperacao As String = "")
    gTransacaoAtiva = True
    If Trim$(idOperacao) <> "" Then
        gTransacaoId = Trim$(idOperacao)
    Else
        gTransacaoId = "TX_" & Format$(Now, "yyyymmdd_hhnnss")
    End If
    Erase gTransacaoWrites
    gTransacaoWriteCount = 0
    RegistrarEvento _
        EVT_TRANSACAO, ENT_CRED, gTransacaoId, _
        "STATUS=NOVA; WRITES=0", _
        "STATUS=ABERTA", _
        "Svc_Transacao"
End Sub

Public Function Transacao_EstaAtiva() As Boolean
    Transacao_EstaAtiva = gTransacaoAtiva
End Function

Public Function Transacao_IdAtual() As String
    Transacao_IdAtual = gTransacaoId
End Function

Public Sub Transacao_RegistrarWrite( _
    ByVal nomeAba As String, _
    ByVal linha As Long, _
    ByVal coluna As Long, _
    ByVal valorAnterior As Variant _
)
    Dim payload(1 To 4) As Variant

    If Not gTransacaoAtiva Then Exit Sub

    payload(1) = nomeAba
    payload(2) = linha
    payload(3) = coluna
    payload(4) = valorAnterior
    gTransacaoWriteCount = gTransacaoWriteCount + 1
    ReDim Preserve gTransacaoWrites(1 To gTransacaoWriteCount)
    gTransacaoWrites(gTransacaoWriteCount) = payload
End Sub

Public Sub Transacao_Commit()
    If gTransacaoAtiva Then
        RegistrarEvento _
            EVT_TRANSACAO, ENT_CRED, gTransacaoId, _
            "STATUS=ABERTA; WRITES=" & CStr(Transacao_QtdWrites()), _
            "STATUS=COMMIT", _
            "Svc_Transacao"
    End If

    gTransacaoAtiva = False
    gTransacaoId = ""
    Erase gTransacaoWrites
    gTransacaoWriteCount = 0
End Sub

Public Function Transacao_Rollback() As Boolean
    Dim i As Long
    Dim payload As Variant
    Dim ws As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim abaPreparada As Boolean

    On Error GoTo falha

    If gTransacaoWriteCount = 0 Then
        Transacao_Rollback = True
        GoTo finalizar
    End If

    For i = gTransacaoWriteCount To 1 Step -1
        payload = gTransacaoWrites(i)
        Set ws = ThisWorkbook.Sheets(CStr(payload(1)))
        abaPreparada = False

        If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
            Err.Raise 1004, "Svc_Transacao.Transacao_Rollback", _
                      "Nao foi possivel preparar a aba '" & CStr(payload(1)) & "' para rollback."
        End If
        abaPreparada = True

        ws.Cells(CLng(payload(2)), CLng(payload(3))).Value = payload(4)
        Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
        abaPreparada = False
    Next i

    Transacao_Rollback = True
    RegistrarEvento _
        EVT_TRANSACAO, ENT_CRED, gTransacaoId, _
        "STATUS=ABERTA; WRITES=" & CStr(Transacao_QtdWrites()), _
        "STATUS=ROLLBACK; SUCESSO=SIM", _
        "Svc_Transacao"
    GoTo finalizar

falha:
    On Error Resume Next
    If abaPreparada Then Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    RegistrarEvento _
        EVT_TRANSACAO, ENT_CRED, gTransacaoId, _
        "STATUS=ABERTA; WRITES=" & CStr(Transacao_QtdWrites()), _
        "STATUS=ROLLBACK; SUCESSO=NAO; MSG=" & Err.Description, _
        "Svc_Transacao"
    On Error GoTo 0
    Transacao_Rollback = False

finalizar:
    gTransacaoAtiva = False
    gTransacaoId = ""
    Erase gTransacaoWrites
    gTransacaoWriteCount = 0
End Function

Private Function Transacao_QtdWrites() As Long
    Transacao_QtdWrites = gTransacaoWriteCount
End Function
