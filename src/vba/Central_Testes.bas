Attribute VB_Name = "Central_Testes"
Option Explicit

' ============================================================
' Central_Testes — Orquestrador da Central de Testes e Treinamento V12
' Proposito: Ponto unico de entrada para testes e treinamento.
' Abas que cria: ROTEIRO_RAPIDO, CHECKLIST_136, HISTORICO_TESTES
'
' ATENCAO: A bateria oficial e chamada via
'   Teste_Bateria_Oficial.RunBateriaOficial
' para evitar erro "Nome repetido encontrado".
'
' ============================================================

Private Const ABA_ROTEIRO As String = "ROTEIRO_RAPIDO"
Private Const ABA_CK136 As String = "CHECKLIST_136"
Private Const ABA_HIST As String = "HISTORICO_TESTES"
Private Const ABA_TESTE_OF As String = "RESULTADO_QA"
Private Const ABA_RPT_ROTEIRO As String = "RPT_ROTEIRO"
Private Const ABA_RPT_BATERIA As String = "RPT_BATERIA"
Private Const ABA_RPT_CK136 As String = "RPT_CK136"
Private Const ABA_RPT_CONSOLIDADO As String = "RPT_CONSOLIDADO"
Private Const ABA_V2_RESULTADO As String = "RESULTADO_QA_V2"
Private Const ABA_V2_HIST As String = "HISTORICO_QA_V2"
Private Const ABA_V2_ROTEIRO As String = "ROTEIRO_ASSISTIDO_V2"
Private Const ABA_V2_CATALOGO As String = "CATALOGO_CENARIOS_V2"
Private Const ABA_V2_RELATORIO As String = "RPT_TESTES_V2"
Private Const RR_TOTAL As Long = 16
Private Const RR_L1PASSO As Long = 4
Private Const CT_CK_MAX_LINHAS As Long = 200

Private gBateriaLiveSeq As Long

' ============================================================
' MENU PRINCIPAL DA CENTRAL
' ============================================================
Public Sub CT_AbrirCentral()
    On Error GoTo falha
    Dim op As String
    op = Trim$(InputBox( _
        "=== CENTRAL DE TESTES V12 / TRANSICAO ===" & vbCrLf & vbCrLf & _
        "[1] Executar Bateria Oficial V1 (rapida ~5 min / assistida ~8 min)" & vbCrLf & _
        "[2] Abrir Central de Testes V2" & vbCrLf & vbCrLf & _
        "Digite o numero:", "Central de Testes V12", "1"))
    If op = "" Then Exit Sub
    Select Case op
        Case "1": Call CT_IniciarBateria
        Case "2": Call CT2_AbrirCentral
        Case Else: MsgBox "Opção inválida.", vbInformation, "Central V12"
    End Select
    Exit Sub
falha:
    MsgBox "Erro: " & Err.Description, vbExclamation, "Central V12"
End Sub

' ============================================================
' ROTEIRO RAPIDO — 16 PASSOS
' ============================================================
Public Sub CT_AbrirRoteiroRapido()
    On Error GoTo falha
    Application.ScreenUpdating = False
    Dim ws As Worksheet, nova As Boolean
    Set ws = PegarOuCriarAba(ABA_ROTEIRO, nova)
    If Not nova Then Call MontarRoteiro(ws)
    Application.ScreenUpdating = True
    ws.Activate
    ws.Range("E" & RR_L1PASSO).Select
    Exit Sub
falha:
    Application.ScreenUpdating = True
    MsgBox "Erro: " & Err.Description, vbExclamation, "Roteiro V12"
End Sub

' ============================================================
' RESULTADO_QA — Funil QA Unificado (substitui CHECKLIST_136)
' ============================================================
Public Sub CT_AbrirResultadoQA()
    On Error GoTo falha
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(ABA_TESTE_OF)
    On Error GoTo falha
    If ws Is Nothing Then
        MsgBox "Aba RESULTADO_QA não encontrada." & vbCrLf & _
               "Execute primeiro a bateria automatizada legada.", vbInformation, "Central V12"
        Exit Sub
    End If
    ws.Activate
    ws.Range("A7").Select
    Exit Sub
falha:
    MsgBox "Erro: " & Err.Description, vbExclamation, "Central V12"
End Sub

' ============================================================
' CHECKLIST 136 (legado — mantido para compatibilidade)
' ============================================================
Public Sub CT_AbrirChecklist136()
    On Error GoTo falha
    Application.ScreenUpdating = False
    Dim ws As Worksheet, nova As Boolean
    Set ws = PegarOuCriarAba(ABA_CK136, nova)
    If nova Then Call MontarChecklist136(ws)
    Application.ScreenUpdating = True
    ws.Activate
    ws.Range("H4").Select
    Exit Sub
falha:
    Application.ScreenUpdating = True
    MsgBox "Erro: " & Err.Description, vbExclamation, "Checklist V12"
End Sub

' ============================================================
' BATERIA AUTOMATIZADA (chamada EXPLICITA ao modulo)
' ============================================================
Private Sub CT_IniciarBateria()
    On Error GoTo falha
    Dim opModo As Long
    Dim execucaoLenta As Boolean

    If MsgBox("Executar a BATERIA OFICIAL completa?" & vbCrLf & vbCrLf & _
              "Durante a execução, o Menu Principal será recolhido." & vbCrLf & _
              "Acompanhe pela barra inferior do Excel (macroprocesso em execução) e pela planilha RESULTADO_QA.", _
              vbQuestion + vbYesNo, "Bateria Oficial V12") = vbNo Then Exit Sub

    If MsgBox("Deseja limpar os testes anteriores?" & vbCrLf & vbCrLf & _
              "Isso limpa os artefatos de teste da V1 e V2:" & vbCrLf & _
              "- RESULTADO_QA / RESULTADO_QA_V2" & vbCrLf & _
              "- CHECKLIST_136 / ROTEIRO_RAPIDO / HISTORICO_*" & vbCrLf & _
              "- relatórios RPT_*" & vbCrLf & _
              "- snapshots SNAPV2_*", _
              vbQuestion + vbYesNo, "Limpeza Pré-Teste V12") = vbYes Then
        CT_LimparArtefatosTesteV1
    End If

    opModo = MsgBox("Escolha o modo de execução:" & vbCrLf & vbCrLf & _
                    "SIM  = ASSISTIDA (~8 min; mesma bateria, mais lenta e mostrando a evolução na tela)" & vbCrLf & _
                    "NÃO  = RÁPIDA (~5 min; mesma bateria, sem pausas visuais)" & vbCrLf & _
                    "CANCELAR = não executar agora", _
                    vbQuestion + vbYesNoCancel, "Modo de Execução")
    If opModo = vbCancel Then Exit Sub
    execucaoLenta = (opModo = vbYes)

    ' Define o modo diretamente no modulo de bateria (sem Names.Add/Delete).
    Call BA_SetModoExecucaoVisual(execucaoLenta)

    On Error Resume Next
    Dim frmMP As Object
    For Each frmMP In VBA.UserForms
        If TypeName(frmMP) = "Menu_Principal" Then
            frmMP.Hide
            Exit For
        End If
    Next frmMP
    Application.Visible = True
    ThisWorkbook.Activate
    Err.Clear
    On Error GoTo falha

    ' Chamada direta para evitar "Metodo ou membro de dados nao encontrado"
    Call RunBateriaOficial

    Call CTR_GerarRelatorioBateria
    If MsgBox("Abrir o RESULTADO_QA (funil unificado)?", vbQuestion + vbYesNo, "Central V12") = vbYes Then
        Call CT_AbrirResultadoQA
    End If
    If MsgBox("Reabrir o Menu Principal?", vbQuestion + vbYesNo, "Central V12") = vbYes Then
        On Error Resume Next
        Dim frmMenuPrincipal As Object
        Set frmMenuPrincipal = VBA.UserForms.Add("Menu_Principal")
        frmMenuPrincipal.Show vbModal
        On Error GoTo falha
    End If
    Exit Sub
falha:
    MsgBox "Erro: " & Err.Description & vbCrLf & _
           "Codigo: " & CStr(Err.Number) & vbCrLf & _
           "Origem: " & Err.Source, _
           vbExclamation, "Bateria V12"
End Sub

Private Sub CT_LimparArtefatosTesteV1()
    Dim idx As Long
    Dim nome As Variant
    Dim ws As Worksheet
    Dim nomeAba As String

    On Error Resume Next
    Application.DisplayAlerts = False

    For idx = ThisWorkbook.Worksheets.Count To 1 Step -1
        Set ws = ThisWorkbook.Worksheets(idx)
        nomeAba = ws.Name
        If CT_EhArtefatoTeste(nomeAba) Then
            ws.Delete
        End If
    Next idx

    For Each nome In Array(ABA_TESTE_OF, ABA_CK136, ABA_HIST, ABA_ROTEIRO, ABA_V2_RESULTADO, ABA_V2_HIST, ABA_V2_ROTEIRO, ABA_V2_CATALOGO, ABA_V2_RELATORIO)
        Set ws = Nothing
        Set ws = ThisWorkbook.Sheets(nome)
        If Not ws Is Nothing Then
            ws.Cells.Clear
            ws.Cells.ClearFormats
        End If
    Next nome

    Application.DisplayAlerts = True
    On Error GoTo 0
End Sub

Private Function CT_EhArtefatoTeste(ByVal nomeAba As String) As Boolean
    Select Case UCase$(Trim$(nomeAba))
        Case UCase$(ABA_ROTEIRO), UCase$(ABA_CK136), UCase$(ABA_HIST), UCase$(ABA_TESTE_OF), _
             UCase$(ABA_RPT_ROTEIRO), UCase$(ABA_RPT_BATERIA), UCase$(ABA_RPT_CK136), UCase$(ABA_RPT_CONSOLIDADO), _
             UCase$(ABA_V2_RESULTADO), UCase$(ABA_V2_HIST), UCase$(ABA_V2_ROTEIRO), UCase$(ABA_V2_CATALOGO), UCase$(ABA_V2_RELATORIO)
            CT_EhArtefatoTeste = True
            Exit Function
    End Select

    If Left$(UCase$(nomeAba), 7) = "SNAPV2_" Then
        CT_EhArtefatoTeste = True
        Exit Function
    End If

    CT_EhArtefatoTeste = False
End Function

' ============================================================
' MENU DE RELATORIOS
' ============================================================
Private Sub CT_MenuRelatorios()
    On Error GoTo falha
    Dim op As String
    op = Trim$(InputBox( _
        "=== RELATÓRIOS V12 ===" & vbCrLf & vbCrLf & _
        "[1] Roteiro Rápido" & vbCrLf & _
        "[2] Bateria Oficial" & vbCrLf & _
        "[3] Validacao Humana (planilha de apoio)" & vbCrLf & _
        "[4] Consolidado" & vbCrLf & _
        "[5] Histórico", "Relatórios V12", "1"))
    If op = "" Then Exit Sub
    Select Case op
        Case "1": Call CTR_GerarRelatorioRoteiro
        Case "2": Call CTR_GerarRelatorioBateria
        Case "3": Call CTR_GerarRelatorioChecklist136
        Case "4": Call CTR_GerarRelatorioConsolidado
        Case "5": Call CT_AbrirHistorico
        Case Else: MsgBox "Opção inválida.", vbInformation, "Relatórios V12"
    End Select
    Exit Sub
falha:
    MsgBox "Erro: " & Err.Description, vbExclamation, "Relatórios V12"
End Sub

' ============================================================
' NAVEGACAO
' ============================================================
Public Sub CT_AbrirMenuPrincipal()
    On Error Resume Next
    Dim frmMenuPrincipal As Object
    Set frmMenuPrincipal = VBA.UserForms.Add("Menu_Principal")
    frmMenuPrincipal.Show
End Sub

' ============================================================
' HISTORICO
' ============================================================
Public Sub CT_GravarHistorico(ByVal tipo As String, ByVal total As Long, ByVal nOk As Long, ByVal nFail As Long, Optional ByVal obs As String = "")
    On Error GoTo sair
    Dim ws As Worksheet, nova As Boolean
    Set ws = PegarOuCriarAba(ABA_HIST, nova)
    If Not nova Then
        Dim h As Long
        For h = 1 To 7
            ws.Cells(1, h).Font.Bold = True
            ws.Cells(1, h).Interior.Color = RGB(0, 51, 102)
            ws.Cells(1, h).Font.Color = RGB(255, 255, 255)
        Next h
        ws.Cells(1, 1).Value = "EXECUCAO_ID"
        ws.Cells(1, 2).Value = "TIPO"
        ws.Cells(1, 3).Value = "DATA_HORA"
        ws.Cells(1, 4).Value = "TOTAL"
        ws.Cells(1, 5).Value = "OK"
        ws.Cells(1, 6).Value = "FALHA"
        ws.Cells(1, 7).Value = "OBS"
    End If
    Dim nr As Long
    nr = ws.Cells(ws.Rows.count, 1).End(xlUp).row + 1
    If nr < 2 Then nr = 2
    ws.Cells(nr, 1).Value = Format$(Now, "YYYY-MM-DD") & "_" & Format$(nr - 1, "000")
    ws.Cells(nr, 2).Value = tipo
    ws.Cells(nr, 3).Value = Now
    ws.Cells(nr, 4).Value = total
    ws.Cells(nr, 5).Value = nOk
    ws.Cells(nr, 6).Value = nFail
    ws.Cells(nr, 7).Value = obs
sair:
End Sub

Private Sub CT_AbrirHistorico()
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(ABA_HIST)
    On Error GoTo 0
    If ws Is Nothing Then
        MsgBox "Nenhum histórico. Execute um teste primeiro.", vbInformation, "Histórico V12"
    Else
        ws.Activate: ws.Range("A1").Select
    End If
End Sub

' ============================================================
' MONTAR ROTEIRO RAPIDO
' ============================================================
Private Sub MontarRoteiro(ByVal ws As Worksheet)
    On Error Resume Next: ws.Unprotect: On Error GoTo 0
    ws.Cells.Clear

    ' Titulo + instrucao
    ws.Range("A1:H1").Merge
    With ws.Range("A1")
        .Value = "ROTEIRO RÁPIDO DE VALIDAÇÃO — RODÍZIO V12"
        .Font.Bold = True: .Font.Size = 14: .HorizontalAlignment = xlCenter
        .Interior.Color = RGB(255, 192, 0): .RowHeight = 30
    End With
    ws.Range("A2:H2").Merge
    With ws.Range("A2")
        .Value = "Execute cada passo no sistema, volte aqui e marque STATUS (E). Use OBS (F) e EVIDÊNCIA (G)."
        .Font.Italic = True: .Font.Size = 9: .WrapText = True: .RowHeight = 28
    End With

    ' Cabecalho
    Dim cols As Variant
    cols = Array("PASSO", "FASE", "AÇÃO ESPERADA", "RESULTADO ESPERADO", "STATUS", "OBSERVAÇÃO", "EVIDÊNCIA", "DATA_HORA")
    Dim c As Long
    For c = 0 To 7
        ws.Cells(3, c + 1).Value = cols(c)
    Next c
    With ws.Range("A3:H3")
        .Font.Bold = True: .Interior.Color = RGB(0, 51, 102): .Font.Color = RGB(255, 255, 255)
        .Borders.LineStyle = xlContinuous: .HorizontalAlignment = xlCenter
    End With

    ' 16 passos
    Dim r As Long
    r = 4
    AP ws, r, "P01", "Cadastro", "Cadastrar Entidade ENT-TESTE-001", "Aparece em ENTIDADE com CNPJ": r = r + 1
    AP ws, r, "P02", "Cadastro", "Cadastrar Empresa EMP-TESTE-001", "STATUS_GLOBAL = ATIVA": r = r + 1
    AP ws, r, "P03", "Cadastro", "Cadastrar Empresa EMP-TESTE-002", "Linha separada, sem conflito": r = r + 1
    AP ws, r, "P04", "Cadastro", "Cadastrar Empresa EMP-TESTE-003", "Terceira empresa OK": r = r + 1
    AP ws, r, "P05", "Credenciamento", "Credenciar EMP-001 em TESTE-ATIV", "POSICAO_FILA + STATUS_CRED = ATIVO": r = r + 1
    AP ws, r, "P06", "Credenciamento", "Credenciar EMP-002 mesma atividade", "POSICAO_FILA diferente": r = r + 1
    AP ws, r, "P07", "Credenciamento", "Credenciar EMP-003 mesma atividade", "Fila com 3 empresas": r = r + 1
    AP ws, r, "P08", "Rodizio", "Verificar fila na ListBox", "3 empresas na ordem correta": r = r + 1
    AP ws, r, "P09", "Pre-OS", "Emitir Pre-OS ENT-001 + TESTE-ATIV", "Empresa posicao 1 selecionada": r = r + 1
    AP ws, r, "P10", "Pre-OS", "Emitir 2a Pre-OS mesma atividade", "Empresa DIFERENTE (posicao 2)": r = r + 1
    AP ws, r, "P11", "OS", "Aceitar e Emitir OS (1a Pre-OS)", "STATUS_OS = EM_EXECUCAO": r = r + 1
    AP ws, r, "P12", "Punicao", "Recusar 2a Pre-OS", "QTD_RECUSAS incrementou": r = r + 1
    AP ws, r, "P13", "Filtro D", "Emitir 3a Pre-OS", "Empresa com OS aberta pulada": r = r + 1
    AP ws, r, "P14", "Avaliacao", "Avaliar/Encerrar OS passo 11", "STATUS_OS = CONCLUIDA": r = r + 1
    AP ws, r, "P15", "Relatório", "Gerar Empresas por Serviço", "Sem erro, 3 empresas": r = r + 1
    AP ws, r, "P16", "Compilacao", "Debug > Compile VBAProject", "Zero erros": r = r + 1

    Dim ul As Long
    ul = r - 1
    ws.Range(ws.Cells(4, 1), ws.Cells(ul, 8)).Borders.LineStyle = xlContinuous

    ' Resumo
    Dim lr As Long
    lr = ul + 2
    Dim sr As String
    sr = "E4:E" & ul
    ws.Cells(lr, 1).Value = "RESUMO": ws.Cells(lr, 1).Font.Bold = True
    ws.Cells(lr + 1, 1).Value = "OK:": ws.Cells(lr + 1, 2).Formula = "=COUNTIF(" & sr & ",""OK"")"
    ws.Cells(lr + 2, 1).Value = "FALHA:": ws.Cells(lr + 2, 2).Formula = "=COUNTIF(" & sr & ",""FALHA"")"
    ws.Cells(lr + 3, 1).Value = "PENDENTE:": ws.Cells(lr + 3, 2).Formula = "=COUNTIF(" & sr & ",""PENDENTE"")"
    ws.Cells(lr + 4, 1).Value = "TOTAL:": ws.Cells(lr + 4, 2).Value = 16
    ws.Range(ws.Cells(lr, 1), ws.Cells(lr + 4, 2)).Font.Bold = True
    ws.Range(ws.Cells(lr, 1), ws.Cells(lr + 4, 2)).Borders.LineStyle = xlContinuous

    ' Metadados
    ws.Cells(lr + 6, 1).Value = "OPERADOR:": ws.Cells(lr + 6, 2).Value = ObterUsr()
    ws.Cells(lr + 7, 1).Value = "DATA:": ws.Cells(lr + 7, 2).Value = Now

    ' Validacao
    Dim rv As Range
    Set rv = ws.Range(ws.Cells(4, 5), ws.Cells(ul, 5))
    With rv.Validation
        .Delete
        .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Formula1:="OK,FALHA,PULADO,PENDENTE"
        .InCellDropdown = True
    End With

    ' Formatacao condicional
    rv.FormatConditions.Delete
    With rv.FormatConditions.Add(Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""OK""")
        .Interior.Color = RGB(198, 239, 206): .Font.Bold = True
    End With
    With rv.FormatConditions.Add(Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""FALHA""")
        .Interior.Color = RGB(255, 199, 206): .Font.Bold = True
    End With
    With rv.FormatConditions.Add(Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""PENDENTE""")
        .Interior.Color = RGB(255, 235, 156)
    End With

    ' Protecao
    ws.Cells.Locked = True
    ws.Range(ws.Cells(4, 5), ws.Cells(ul, 5)).Locked = False
    ws.Range(ws.Cells(4, 6), ws.Cells(ul, 6)).Locked = False
    ws.Range(ws.Cells(4, 7), ws.Cells(ul, 7)).Locked = False
    ws.Protect UserInterfaceOnly:=True, AllowFormattingCells:=True

    Call InserirBotoes(ws)

    ' Freeze + larguras
    ws.Activate: ActiveWindow.FreezePanes = False
    ws.Range("A4").Select: ActiveWindow.FreezePanes = True
    ws.Columns("A").ColumnWidth = 8: ws.Columns("B").ColumnWidth = 14
    ws.Columns("C").ColumnWidth = 44: ws.Columns("D").ColumnWidth = 44
    ws.Columns("E").ColumnWidth = 14: ws.Columns("F").ColumnWidth = 28
    ws.Columns("G").ColumnWidth = 18: ws.Columns("H").ColumnWidth = 18
    Dim iR As Long
    For iR = 4 To ul: ws.Rows(iR).RowHeight = 28: Next iR
    ws.Range(ws.Cells(4, 3), ws.Cells(ul, 4)).WrapText = True
End Sub

Private Sub AP(ByVal ws As Worksheet, ByVal rw As Long, ByVal p As String, ByVal f As String, ByVal a As String, ByVal re As String)
    ws.Cells(rw, 1).Value = p: ws.Cells(rw, 2).Value = f
    ws.Cells(rw, 3).Value = a: ws.Cells(rw, 4).Value = re
    ws.Cells(rw, 5).Value = "PENDENTE"
    ws.Cells(rw, 1).HorizontalAlignment = xlCenter
    ws.Cells(rw, 2).HorizontalAlignment = xlCenter
    ws.Cells(rw, 5).HorizontalAlignment = xlCenter
End Sub

' ============================================================
' MONTAR CHECKLIST 136
' ============================================================
Private Sub MontarChecklist136(ByVal ws As Worksheet)
    On Error Resume Next: ws.Unprotect: On Error GoTo 0
    ws.Cells.Clear

    ws.Range("A1:K1").Merge
    With ws.Range("A1")
        .Value = "BATERIA MANUAL DE APOIO — " & CStr(CT_CK_MAX_LINHAS) & " linhas (uso opcional) — V12"
        .Font.Bold = True: .Font.Size = 13: .HorizontalAlignment = xlCenter
        .Interior.Color = RGB(255, 192, 0): .RowHeight = 30
    End With
    ws.Range("A2:K2").Merge
    With ws.Range("A2")
        .Value = "Planilha manual opcional. A bateria automatizada V1 usa RESULTADO_QA; esta aba deve ser preenchida apenas em homologação humana dedicada."
        .Font.Italic = True: .Font.Size = 9: .WrapText = True: .RowHeight = 28
    End With

    Dim hds As Variant
    hds = Array("ID", "TIPO", "BLOCO", "NOME_TESTE", "ESPERADO", "OBTIDO", "STATUS_AUTO", "STATUS_HUMANO", "OBS", "EVIDENCIA", "DATA_HORA")
    Dim c As Long
    For c = 0 To 10: ws.Cells(3, c + 1).Value = hds(c): Next c
    With ws.Range("A3:K3")
        .Font.Bold = True: .Interior.Color = RGB(0, 51, 102): .Font.Color = RGB(255, 255, 255)
        .Borders.LineStyle = xlContinuous: .HorizontalAlignment = xlCenter
    End With

    Dim i As Long
    For i = 1 To CT_CK_MAX_LINHAS
        Dim rw As Long
        rw = 3 + i
        ws.Cells(rw, 1).Value = i: ws.Cells(rw, 1).HorizontalAlignment = xlCenter
        ws.Cells(rw, 2).Value = "MANUAL": ws.Cells(rw, 2).HorizontalAlignment = xlCenter
        ws.Cells(rw, 4).Value = "(aguardando bateria)"
        ws.Cells(rw, 7).Value = "PENDENTE": ws.Cells(rw, 7).HorizontalAlignment = xlCenter
        ws.Cells(rw, 8).Value = "PENDENTE": ws.Cells(rw, 8).HorizontalAlignment = xlCenter
        If i > CT_CK_MAX_LINHAS - 4 Then ws.Range(ws.Cells(rw, 1), ws.Cells(rw, 11)).Interior.Color = RGB(255, 235, 156)
    Next i

    Dim ul As Long
    ul = 3 + CT_CK_MAX_LINHAS
    ws.Range(ws.Cells(4, 1), ws.Cells(ul, 11)).Borders.LineStyle = xlContinuous

    ' Resumo
    Dim lr As Long
    lr = ul + 2
    Dim rh As String
    rh = "H4:H" & ul
    ws.Cells(lr, 1).Value = "RESUMO": ws.Cells(lr, 1).Font.Bold = True
    ws.Cells(lr + 1, 1).Value = "CONFIRMADO:": ws.Cells(lr + 1, 2).Formula = "=COUNTIF(" & rh & ",""CONFIRMADO"")"
    ws.Cells(lr + 2, 1).Value = "DIVERGENTE:": ws.Cells(lr + 2, 2).Formula = "=COUNTIF(" & rh & ",""DIVERGENTE"")"
    ws.Cells(lr + 3, 1).Value = "PENDENTE:": ws.Cells(lr + 3, 2).Formula = "=COUNTIF(" & rh & ",""PENDENTE"")"
    ws.Cells(lr + 4, 1).Value = "TOTAL:": ws.Cells(lr + 4, 2).Formula = "=COUNTA(A4:A" & ul & ")"
    ws.Range(ws.Cells(lr, 1), ws.Cells(lr + 4, 2)).Font.Bold = True

    ws.Cells(lr + 6, 1).Value = "OPERADOR:": ws.Cells(lr + 6, 2).Value = ObterUsr()
    ws.Cells(lr + 7, 1).Value = "DATA:": ws.Cells(lr + 7, 2).Value = Now

    ' Validacao STATUS_HUMANO
    Dim rv As Range
    Set rv = ws.Range(ws.Cells(4, 8), ws.Cells(ul, 8))
    With rv.Validation
        .Delete
        .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Formula1:="CONFIRMADO,DIVERGENTE,PENDENTE,N/A"
        .InCellDropdown = True
    End With
    rv.FormatConditions.Delete
    With rv.FormatConditions.Add(Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""CONFIRMADO""")
        .Interior.Color = RGB(198, 239, 206): .Font.Bold = True
    End With
    With rv.FormatConditions.Add(Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""DIVERGENTE""")
        .Interior.Color = RGB(255, 199, 206): .Font.Bold = True
    End With

    ' Formatacao STATUS_AUTO
    Dim ra As Range
    Set ra = ws.Range(ws.Cells(4, 7), ws.Cells(ul, 7))
    ra.FormatConditions.Delete
    With ra.FormatConditions.Add(Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""OK""")
        .Interior.Color = RGB(198, 239, 206): .Font.Bold = True
    End With
    With ra.FormatConditions.Add(Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""FALHA""")
        .Interior.Color = RGB(255, 199, 206): .Font.Bold = True
    End With
    With ra.FormatConditions.Add(Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""EXECUTANDO""")
        .Interior.Color = RGB(173, 216, 230): .Font.Bold = True
    End With
    With ra.FormatConditions.Add(Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""INFO""")
        .Interior.Color = RGB(221, 235, 247): .Font.Bold = False
    End With

    ' Protecao
    ws.Cells.Locked = True
    ws.Range(ws.Cells(4, 8), ws.Cells(ul, 8)).Locked = False
    ws.Range(ws.Cells(4, 9), ws.Cells(ul, 9)).Locked = False
    ws.Range(ws.Cells(4, 10), ws.Cells(ul, 10)).Locked = False
    ws.Protect UserInterfaceOnly:=True, AllowFormattingCells:=True

    Call InserirBotoes(ws)

    ws.Activate: ActiveWindow.FreezePanes = False
    ws.Range("A4").Select: ActiveWindow.FreezePanes = True
    ws.Columns("A").ColumnWidth = 6: ws.Columns("B").ColumnWidth = 9
    ws.Columns("C").ColumnWidth = 9: ws.Columns("D").ColumnWidth = 38
    ws.Columns("E").ColumnWidth = 32: ws.Columns("F").ColumnWidth = 32
    ws.Columns("G").ColumnWidth = 16: ws.Columns("H").ColumnWidth = 16
    ws.Columns("I").ColumnWidth = 22: ws.Columns("J").ColumnWidth = 14
    ws.Columns("K").ColumnWidth = 22
End Sub

Private Sub CT_AtualizarTituloChecklist136(ByVal ws As Worksheet)
    On Error GoTo sair

    Dim ul As Long
    ul = 3 + CT_CK_MAX_LINHAS

    Dim total As Long
    Dim nAuto As Long
    Dim nManual As Long
    Dim r As Long
    Dim nm As String
    Dim tp As String
    Dim st As String

    total = 0: nAuto = 0: nManual = 0
    For r = 4 To ul
        nm = CStr(ws.Cells(r, 4).Value)
        st = UCase$(Trim$(CStr(ws.Cells(r, 7).Value)))
        If nm <> "" And nm <> "(aguardando bateria)" And st <> "" And st <> "PENDENTE" Then
            total = total + 1
            tp = UCase$(Trim$(CStr(ws.Cells(r, 2).Value)))
            If tp = "MANUAL" Then
                nManual = nManual + 1
            Else
                nAuto = nAuto + 1
            End If
        End If
    Next r

    ws.Range("A1").Value = "BATERIA MANUAL DE APOIO — " & CStr(total) & " linhas preenchidas — V12"

sair:
End Sub

' ============================================================
' IMPORTAR RESULTADOS DA BATERIA -> CHECKLIST_136
' ============================================================
Private Sub ImportarResultadosBateria(ByVal wd As Worksheet)
    On Error GoTo sair
    Dim wsBO As Worksheet
    On Error Resume Next
    Set wsBO = ThisWorkbook.Sheets(ABA_TESTE_OF)
    On Error GoTo sair
    If wsBO Is Nothing Then Exit Sub
    Dim lastBO As Long
    lastBO = wsBO.Cells(wsBO.Rows.count, 1).End(xlUp).row
    If lastBO < 7 Then Exit Sub

    On Error Resume Next: wd.Unprotect: On Error GoTo sair

    Dim sr As Long, dr As Long, seq As Long
    dr = 4: seq = 0
    For sr = 7 To lastBO
        Dim st As String
        st = UCase$(Trim$(CStr(wsBO.Cells(sr, 7).Value)))
        If st = "OK" Or st = "FALHA" Or st = "MANUAL_ASSISTIDO" Or st = "INFO" Or st = "MANUAL" Then
            seq = seq + 1
            If dr <= 3 + CT_CK_MAX_LINHAS Then
                wd.Cells(dr, 1).Value = seq
                If st = "MANUAL_ASSISTIDO" Or st = "MANUAL" Then
                    wd.Cells(dr, 2).Value = "MANUAL"
                ElseIf st = "INFO" Then
                    wd.Cells(dr, 2).Value = "INFO"
                Else
                    wd.Cells(dr, 2).Value = "AUTO"
                End If
                wd.Cells(dr, 3).Value = Trim$(CStr(wsBO.Cells(sr, 2).Value))
                wd.Cells(dr, 4).Value = Trim$(CStr(wsBO.Cells(sr, 3).Value))
                wd.Cells(dr, 5).Value = Trim$(CStr(wsBO.Cells(sr, 5).Value))
                wd.Cells(dr, 6).Value = Trim$(CStr(wsBO.Cells(sr, 6).Value))
                wd.Cells(dr, 7).Value = st
                wd.Cells(dr, 11).Value = wsBO.Cells(sr, 10).Value
                If Trim$(CStr(wd.Cells(dr, 8).Value)) = "" Or wd.Cells(dr, 8).Value = "PENDENTE" Then
                    wd.Cells(dr, 8).Value = "PENDENTE"
                End If
                If st = "MANUAL_ASSISTIDO" Then
                    wd.Range(wd.Cells(dr, 1), wd.Cells(dr, 11)).Interior.Color = RGB(255, 235, 156)
                End If
                dr = dr + 1
            End If
        End If
    Next sr

    wd.Protect UserInterfaceOnly:=True, AllowFormattingCells:=True
sair:
    On Error Resume Next
    Call CT_AtualizarTituloChecklist136(wd)
End Sub

' ============================================================
' BATERIA AO VIVO — atualiza CHECKLIST_136 a cada log
' ============================================================
Public Sub CT_PrepararChecklistParaBateriaAoVivo()
    On Error Resume Next
    gBateriaLiveSeq = 0
    Dim ws As Worksheet
    Dim nova As Boolean
    Set ws = PegarOuCriarAba(ABA_CK136, nova)
    If ws Is Nothing Then Exit Sub
    MontarChecklist136 ws
End Sub

Public Sub CT_BateriaLive_Registrar( _
    ByVal nomeTeste As String, _
    ByVal bloco As String, _
    ByVal aplicacao As String, _
    ByVal esperado As String, _
    ByVal obtido As String, _
    ByVal statusFinal As String, _
    ByVal dataHora As Date)

    ' Escrita atomica na linha (evita ficar preso em EXECUTANDO apos DoEvents/modais).
    Dim wd As Worksheet
    Dim dr As Long
    Dim tipoLinha As String

    On Error GoTo erroChk

    Set wd = ThisWorkbook.Sheets(ABA_CK136)
    If wd Is Nothing Then GoTo fimChk

    gBateriaLiveSeq = gBateriaLiveSeq + 1
    If gBateriaLiveSeq > CT_CK_MAX_LINHAS Then GoTo fimChk

    dr = 3 + gBateriaLiveSeq

    wd.Unprotect

    tipoLinha = "AUTO"
    If UCase$(Trim$(statusFinal)) = "MANUAL_ASSISTIDO" Or UCase$(Trim$(statusFinal)) = "MANUAL" Then
        tipoLinha = "MANUAL"
    ElseIf UCase$(Trim$(statusFinal)) = "INFO" Then
        tipoLinha = "INFO"
    End If

    wd.Cells(dr, 1).Value = gBateriaLiveSeq
    wd.Cells(dr, 1).HorizontalAlignment = xlCenter
    wd.Cells(dr, 2).Value = tipoLinha
    wd.Cells(dr, 2).HorizontalAlignment = xlCenter
    wd.Cells(dr, 3).Value = bloco
    wd.Cells(dr, 4).Value = nomeTeste
    wd.Cells(dr, 5).Value = esperado
    wd.Cells(dr, 6).Value = obtido
    wd.Cells(dr, 7).Value = statusFinal
    wd.Cells(dr, 7).HorizontalAlignment = xlCenter
    wd.Cells(dr, 8).Value = "PENDENTE"
    wd.Cells(dr, 8).HorizontalAlignment = xlCenter
    wd.Cells(dr, 11).Value = dataHora

    wd.Range(wd.Cells(dr, 1), wd.Cells(dr, 11)).Interior.ColorIndex = xlNone
    If UCase$(Trim$(statusFinal)) = "MANUAL_ASSISTIDO" Or UCase$(Trim$(statusFinal)) = "MANUAL" Then
        wd.Range(wd.Cells(dr, 1), wd.Cells(dr, 11)).Interior.Color = RGB(255, 235, 156)
    End If

    Call CT_AtualizarTituloChecklist136(wd)

    Application.StatusBar = "Bateria [" & CStr(gBateriaLiveSeq) & "/" & CStr(CT_CK_MAX_LINHAS) & "] " & nomeTeste & " — " & statusFinal

    Application.ScreenUpdating = True
    DoEvents
    Application.ScreenUpdating = False

    wd.Protect UserInterfaceOnly:=True, AllowFormattingCells:=True
    GoTo fimChk

erroChk:
    On Error Resume Next
    If Not wd Is Nothing And dr >= 4 Then
        wd.Unprotect
        wd.Cells(dr, 7).Value = statusFinal
        wd.Cells(dr, 5).Value = esperado
        wd.Cells(dr, 6).Value = obtido
        wd.Protect UserInterfaceOnly:=True, AllowFormattingCells:=True
    End If

fimChk:
End Sub

' ============================================================
' BOTOES DE NAVEGACAO (Shapes — Mac compativel)
' ============================================================
Private Sub InserirBotoes(ByVal ws As Worksheet)
    On Error Resume Next
    Dim shp As Object
    For Each shp In ws.Shapes
        If Left$(shp.Name, 6) = "CT_BTN" Then shp.Delete
    Next shp
    On Error GoTo 0

    Dim b As Object
    Set b = ws.Shapes.AddShape(msoShapeRoundedRectangle, 10, 34, 180, 26)
    With b
        .Name = "CT_BTN_MENU"
        .TextFrame2.TextRange.Text = "Voltar ao Menu Principal"
        .TextFrame2.TextRange.Font.Size = 9: .TextFrame2.TextRange.Font.Bold = msoTrue
        .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter
        .Fill.ForeColor.RGB = RGB(0, 51, 102)
        .TextFrame2.TextRange.Font.Fill.ForeColor.RGB = RGB(255, 255, 255)
        .OnAction = "CT_AbrirMenuPrincipal"
    End With

    Set b = ws.Shapes.AddShape(msoShapeRoundedRectangle, 200, 34, 150, 26)
    With b
        .Name = "CT_BTN_REL"
        .TextFrame2.TextRange.Text = "Gerar Relatório"
        .TextFrame2.TextRange.Font.Size = 9: .TextFrame2.TextRange.Font.Bold = msoTrue
        .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter
        .Fill.ForeColor.RGB = RGB(0, 128, 0)
        .TextFrame2.TextRange.Font.Fill.ForeColor.RGB = RGB(255, 255, 255)
        .OnAction = "CTR_GerarRelatorioChecklist136"
    End With

    Set b = ws.Shapes.AddShape(msoShapeRoundedRectangle, 360, 34, 150, 26)
    With b
        .Name = "CT_BTN_CENTRAL"
        .TextFrame2.TextRange.Text = "Central de Testes"
        .TextFrame2.TextRange.Font.Size = 9: .TextFrame2.TextRange.Font.Bold = msoTrue
        .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter
        .Fill.ForeColor.RGB = RGB(255, 192, 0)
        .TextFrame2.TextRange.Font.Fill.ForeColor.RGB = RGB(0, 0, 0)
        .OnAction = "CT_AbrirCentral"
    End With
End Sub

' ============================================================
' HELPERS
' ============================================================
Private Function PegarOuCriarAba(ByVal nm As String, ByRef existia As Boolean) As Worksheet
    Dim ws As Worksheet
    existia = False
    On Error Resume Next: Set ws = ThisWorkbook.Sheets(nm): On Error GoTo 0
    If Not ws Is Nothing Then
        existia = True
        Set PegarOuCriarAba = ws
        Exit Function
    End If
    Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.count))
    ws.Name = nm: ws.Tab.Color = RGB(255, 192, 0)
    Set PegarOuCriarAba = ws
End Function

Private Function ObterUsr() As String
    On Error Resume Next
    ObterUsr = Environ$("USERNAME")
    If ObterUsr = "" Then ObterUsr = Application.UserName
    On Error GoTo 0
    If ObterUsr = "" Then ObterUsr = "OPERADOR"
End Function
