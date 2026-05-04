Attribute VB_Name = "ErrorBoundary"
Option Explicit

Private g_emOperacao As Boolean
Private calcState As Long
Private eventsState As Boolean
Private screenState As Boolean

' Inicia uma transacao segura no Excel, travando repintura visual e calculos.
Public Function BeginWrite(ByVal operacao As String) As Boolean
    On Error Resume Next

    If g_emOperacao Then
        BeginWrite = False
        Exit Function
    End If

    calcState = Application.Calculation
    eventsState = Application.EnableEvents
    screenState = Application.ScreenUpdating

    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False
    Application.ScreenUpdating = False

    g_emOperacao = True
    BeginWrite = True
    On Error GoTo 0
End Function

' Finaliza com sucesso a transacao, devolvendo o controle da interface.
Public Sub CommitWrite()
    If Not g_emOperacao Then Exit Sub

    On Error Resume Next
    Application.Calculation = calcState
    Application.EnableEvents = eventsState
    Application.ScreenUpdating = screenState
    Application.Calculate

    g_emOperacao = False
    On Error GoTo 0
End Sub

' Em caso de falha critica, reverte o estado visual e registra erro.
Public Sub RollbackWrite(Optional ByVal silent As Boolean = False)
    If Not g_emOperacao Then Exit Sub

    Dim errNum As Long
    Dim errDesc As String

    errNum = Err.Number
    errDesc = Err.Description

    On Error Resume Next
    Application.Calculation = calcState
    Application.EnableEvents = eventsState
    Application.ScreenUpdating = screenState

    g_emOperacao = False

    If Not silent And errNum <> 0 Then
        MsgBox "Ocorreu uma falha crítica durante a operação." & vbCrLf & _
               "Erro: " & errNum & " - " & errDesc, vbCritical, "Erro de execução"
    End If
    On Error GoTo 0
End Sub


