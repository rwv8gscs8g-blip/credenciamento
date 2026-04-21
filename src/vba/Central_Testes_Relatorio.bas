Attribute VB_Name = "Central_Testes_Relatorio"
Option Explicit

' ============================================================
' Central_Testes_Relatorio — Geração de relatórios imprimíveis V12
'
' Propósito: Gerar relatórios formatados A4 Portrait para impressão.
' Dependencias: Central_Testes.bas, Teste_Bateria_Oficial.bas
' Abas que cria: RPT_ROTEIRO, RPT_BATERIA, RPT_CK136, RPT_CONSOLIDADO
' Funcoes publicas:
'   CTR_GerarRelatorioRoteiro      — relatório imprimível do Roteiro Rápido
'   CTR_GerarRelatorioBateria      — relatório imprimível da Bateria Oficial
'   CTR_GerarRelatorioChecklist136 — relatório imprimível da Validação Humana 136
'   CTR_GerarRelatorioConsolidado  — relatório consolidado de todos os testes
'
' Data: 27/03/2026
' ============================================================

Private Const ABA_RPT_ROTEIRO As String = "RPT_ROTEIRO"
Private Const ABA_RPT_BATERIA As String = "RPT_BATERIA"
Private Const ABA_RPT_CK136 As String = "RPT_CK136"
Private Const ABA_RPT_CONSOLIDADO As String = "RPT_CONSOLIDADO"
Private Const ABA_ROTEIRO As String = "ROTEIRO_RAPIDO"
Private Const ABA_TESTE_OFICIAL As String = "RESULTADO_QA"
Private Const ABA_CK136 As String = "CHECKLIST_136"
Private Const ABA_HIST As String = "HISTORICO_TESTES"

' ============================================================
' RELATÓRIO DO ROTEIRO RÁPIDO
' ============================================================
Public Sub CTR_GerarRelatorioRoteiro()
    On Error GoTo falha
    
    Dim wsSrc As Worksheet
    On Error Resume Next
    Set wsSrc = ThisWorkbook.Sheets(ABA_ROTEIRO)
    On Error GoTo falha
    
    If wsSrc Is Nothing Then
        MsgBox "Aba ROTEIRO_RAPIDO não encontrada." & vbCrLf & _
               "Execute primeiro o Roteiro Rápido pela Central de Testes.", vbInformation, "Relatório V12"
        Exit Sub
    End If
    
    Application.ScreenUpdating = False
    
    Dim wsRpt As Worksheet
    Set wsRpt = CTR_CriarAbaRelatorio(ABA_RPT_ROTEIRO)
    
    ' Titulo
    Dim r As Long
    r = 1
    wsRpt.Range("A1:F1").Merge
    wsRpt.Range("A1").Value = "RELATÓRIO DO ROTEIRO RÁPIDO " & ChrW(8212) & " RODÍZIO V12"
    With wsRpt.Range("A1")
        .Font.Bold = True
        .Font.Size = 14
        .HorizontalAlignment = xlCenter
        .Interior.Color = RGB(0, 51, 102)
        .Font.Color = RGB(255, 255, 255)
        .RowHeight = 30
    End With
    
    ' Info do operador
    r = 2
    wsRpt.Range("A2:F2").Merge
    wsRpt.Range("A2").Value = "Operador: " & CTR_ObterUsuario() & "  |  Data: " & Format$(Now, "DD/MM/YYYY HH:MM:SS")
    wsRpt.Range("A2").Font.Size = 10
    wsRpt.Range("A2").HorizontalAlignment = xlCenter
    
    ' Cabecalho
    r = 4
    wsRpt.Cells(r, 1).Value = "PASSO"
    wsRpt.Cells(r, 2).Value = "FASE"
    wsRpt.Cells(r, 3).Value = "AÇÃO"
    wsRpt.Cells(r, 4).Value = "STATUS"
    wsRpt.Cells(r, 5).Value = "OBSERVAÇÃO"
    wsRpt.Cells(r, 6).Value = "EVIDÊNCIA"
    With wsRpt.Range(wsRpt.Cells(r, 1), wsRpt.Cells(r, 6))
        .Font.Bold = True
        .Interior.Color = RGB(217, 225, 242)
        .Borders.LineStyle = xlContinuous
    End With
    
    ' Copiar dados do roteiro
    Dim i As Long
    Dim cOK As Long, cFalha As Long, cPulado As Long, cPend As Long
    cOK = 0: cFalha = 0: cPulado = 0: cPend = 0
    
    For i = 0 To 15
        r = 5 + i
        wsRpt.Cells(r, 1).Value = wsSrc.Cells(4 + i, 1).Value
        wsRpt.Cells(r, 2).Value = wsSrc.Cells(4 + i, 2).Value
        wsRpt.Cells(r, 3).Value = wsSrc.Cells(4 + i, 3).Value
        wsRpt.Cells(r, 4).Value = wsSrc.Cells(4 + i, 5).Value
        wsRpt.Cells(r, 5).Value = wsSrc.Cells(4 + i, 6).Value
        wsRpt.Cells(r, 6).Value = wsSrc.Cells(4 + i, 7).Value
        
        wsRpt.Cells(r, 1).HorizontalAlignment = xlCenter
        wsRpt.Cells(r, 4).HorizontalAlignment = xlCenter
        
        Dim st As String
        st = UCase$(Trim$(CStr(wsRpt.Cells(r, 4).Value)))
        Select Case st
            Case "OK": cOK = cOK + 1
                wsRpt.Cells(r, 4).Interior.Color = RGB(198, 239, 206)
            Case "FALHA": cFalha = cFalha + 1
                wsRpt.Cells(r, 4).Interior.Color = RGB(255, 199, 206)
            Case "PULADO": cPulado = cPulado + 1
            Case Else: cPend = cPend + 1
                wsRpt.Cells(r, 4).Interior.Color = RGB(255, 235, 156)
        End Select
    Next i
    
    wsRpt.Range(wsRpt.Cells(5, 1), wsRpt.Cells(20, 6)).Borders.LineStyle = xlContinuous
    
    ' Resumo
    r = 22
    wsRpt.Range("A" & r & ":F" & r).Merge
    wsRpt.Cells(r, 1).Value = "RESULTADO: " & cOK & "/16 OK  |  " & cFalha & " FALHA  |  " & cPulado & " PULADO  |  " & cPend & " PENDENTE"
    wsRpt.Cells(r, 1).Font.Bold = True
    wsRpt.Cells(r, 1).Font.Size = 12
    wsRpt.Cells(r, 1).HorizontalAlignment = xlCenter
    
    If cFalha = 0 And cPend = 0 Then
        wsRpt.Cells(r, 1).Interior.Color = RGB(198, 239, 206)
    ElseIf cFalha > 0 Then
        wsRpt.Cells(r, 1).Interior.Color = RGB(255, 199, 206)
    End If
    
    ' Assinaturas
    r = 25
    wsRpt.Cells(r, 1).Value = "Assinatura operador: ____________________________"
    wsRpt.Cells(r + 1, 1).Value = "Assinatura supervisor: __________________________"
    
    ' Rodape
    r = 28
    wsRpt.Range("A" & r & ":F" & r).Merge
    wsRpt.Cells(r, 1).Value = "Gerado automaticamente pelo Sistema de Credenciamento V12"
    wsRpt.Cells(r, 1).Font.Size = 8
    wsRpt.Cells(r, 1).Font.Italic = True
    wsRpt.Cells(r, 1).HorizontalAlignment = xlCenter
    
    ' Ajustar larguras
    wsRpt.Columns("A").ColumnWidth = 8
    wsRpt.Columns("B").ColumnWidth = 14
    wsRpt.Columns("C").ColumnWidth = 40
    wsRpt.Columns("D").ColumnWidth = 12
    wsRpt.Columns("E").ColumnWidth = 25
    wsRpt.Columns("F").ColumnWidth = 18
    
    Call CTR_ConfigurarImpressao(wsRpt)
    
    Application.ScreenUpdating = True
    wsRpt.Activate
    
    Dim resp As Long
    resp = MsgBox("Relatório gerado na aba " & ABA_RPT_ROTEIRO & "." & vbCrLf & vbCrLf & _
                  "Deseja imprimir agora?", vbQuestion + vbYesNo, "Relatório Roteiro V12")
    
    If resp = vbYes Then
        On Error Resume Next
        wsRpt.PrintOut
        If Err.Number <> 0 Then
            MsgBox "Não foi possível imprimir. Você pode usar Arquivo > Imprimir manualmente.", vbInformation, "Relatório V12"
        End If
        On Error GoTo falha
    End If
    
    Call CT_GravarHistorico("ROTEIRO_RAPIDO", 16, cOK, cFalha, "Pulado: " & cPulado & " | Pendente: " & cPend)
    
    Exit Sub
falha:
    Application.ScreenUpdating = True
    MsgBox "Erro ao gerar relatório do roteiro: " & Err.Description, vbExclamation, "Relatório V12"
End Sub

' ============================================================
' RELATÓRIO DA BATERIA OFICIAL
' ============================================================
Public Sub CTR_GerarRelatorioBateria()
    Dim errN As Long
    Dim errD As String
    Dim errS As String
    Dim wsSrc As Worksheet
    Dim wsRpt As Worksheet
    Dim ultLinha As Long
    Dim cOK As Long
    Dim cFalha As Long
    Dim cManual As Long
    Dim cTotal As Long
    Dim i As Long
    Dim r As Long
    Dim status As String
    Dim stMan As String
    Dim resp As Long
    Dim estImp As Boolean
    Dim senImp As String

    On Error GoTo falha
    On Error Resume Next
    Set wsSrc = ThisWorkbook.Sheets(ABA_TESTE_OFICIAL)
    On Error GoTo falha
    
    If wsSrc Is Nothing Then
        MsgBox "Aba RESULTADO_QA não encontrada." & vbCrLf & _
               "Execute a Bateria Oficial primeiro.", vbInformation, "Relatório V12"
        Exit Sub
    End If
    
    Application.ScreenUpdating = False

    Set wsRpt = CTR_CriarAbaRelatorio(ABA_RPT_BATERIA)
    
    ' Titulo
    wsRpt.Range("A1:F1").Merge
    wsRpt.Range("A1").Value = "RELATÓRIO DA BATERIA OFICIAL DE TESTES " & ChrW(8212) & " V12"
    With wsRpt.Range("A1")
        .Font.Bold = True
        .Font.Size = 14
        .HorizontalAlignment = xlCenter
        .Interior.Color = RGB(0, 51, 102)
        .Font.Color = RGB(255, 255, 255)
        .RowHeight = 30
    End With
    
    wsRpt.Range("A2:F2").Merge
    wsRpt.Range("A2").Value = "Data: " & Format$(Now, "DD/MM/YYYY HH:MM:SS")
    wsRpt.Range("A2").HorizontalAlignment = xlCenter
    
    ' Contar resultados da aba RESULTADO_QA (dados comecam na row 7, col STATUS=7)
    ultLinha = Application.WorksheetFunction.Max( _
        wsSrc.Cells(wsSrc.Rows.count, 1).End(xlUp).row, _
        wsSrc.Cells(wsSrc.Rows.count, 7).End(xlUp).row)

    cOK = 0: cFalha = 0: cManual = 0

    For i = 7 To ultLinha
        status = UCase$(Trim$(CStr(wsSrc.Cells(i, 7).Value)))
        Select Case status
            Case "OK": cOK = cOK + 1
            Case "FALHA": cFalha = cFalha + 1
            Case "MANUAL_ASSISTIDO", "MANUAL": cManual = cManual + 1
        End Select
    Next i
    cTotal = cOK + cFalha + cManual

    ' Resumo executivo
    r = 4
    wsRpt.Cells(r, 1).Value = "RESULTADO GERAL"
    wsRpt.Cells(r, 1).Font.Bold = True
    wsRpt.Cells(r, 1).Font.Size = 12
    
    r = 5
    wsRpt.Cells(r, 1).Value = "OK:"
    wsRpt.Cells(r, 2).Value = cOK
    wsRpt.Cells(r, 2).Font.Bold = True
    wsRpt.Cells(r, 2).Font.Color = RGB(0, 128, 0)
    
    wsRpt.Cells(r + 1, 1).Value = "FALHA:"
    wsRpt.Cells(r + 1, 2).Value = cFalha
    wsRpt.Cells(r + 1, 2).Font.Bold = True
    wsRpt.Cells(r + 1, 2).Font.Color = RGB(200, 0, 0)
    
    If cManual > 0 Then
        wsRpt.Cells(r + 2, 1).Value = "MANUAL:"
        wsRpt.Cells(r + 2, 2).Value = cManual
        wsRpt.Cells(r + 2, 2).Font.Bold = True
        wsRpt.Cells(r + 2, 2).Font.Color = RGB(128, 128, 0)

        wsRpt.Cells(r + 3, 1).Value = "TOTAL:"
        wsRpt.Cells(r + 3, 2).Value = cTotal
        wsRpt.Cells(r + 3, 2).Font.Bold = True

        wsRpt.Range(wsRpt.Cells(r, 1), wsRpt.Cells(r + 3, 2)).Borders.LineStyle = xlContinuous
    Else
        wsRpt.Cells(r + 2, 1).Value = "TOTAL:"
        wsRpt.Cells(r + 2, 2).Value = cTotal
        wsRpt.Cells(r + 2, 2).Font.Bold = True

        wsRpt.Range(wsRpt.Cells(r, 1), wsRpt.Cells(r + 2, 2)).Borders.LineStyle = xlContinuous
    End If
    
    ' Listar testes com falha
    r = 10
    If cFalha > 0 Then
        wsRpt.Cells(r, 1).Value = "TESTES COM FALHA:"
        wsRpt.Cells(r, 1).Font.Bold = True
        wsRpt.Cells(r, 1).Font.Color = RGB(200, 0, 0)
        r = r + 1
        
        For i = 7 To ultLinha
            If UCase$(Trim$(CStr(wsSrc.Cells(i, 7).Value))) = "FALHA" Then
                wsRpt.Cells(r, 1).Value = wsSrc.Cells(i, 3).Value
                wsRpt.Cells(r, 2).Value = wsSrc.Cells(i, 5).Value
                wsRpt.Cells(r, 3).Value = wsSrc.Cells(i, 6).Value
                wsRpt.Cells(r, 1).Interior.Color = RGB(255, 230, 233)
                r = r + 1
            End If
        Next i
        r = r + 1
    End If
    
    ' Listar testes manuais apenas se existirem
    If cManual > 0 Then
        wsRpt.Cells(r, 1).Value = "TESTES MANUAL_ASSISTIDO (validação humana pendente):"
        wsRpt.Cells(r, 1).Font.Bold = True
        r = r + 1

        For i = 7 To ultLinha
            stMan = UCase$(Trim$(CStr(wsSrc.Cells(i, 7).Value)))
            If stMan = "MANUAL_ASSISTIDO" Or stMan = "MANUAL" Then
                wsRpt.Cells(r, 1).Value = wsSrc.Cells(i, 3).Value
                wsRpt.Cells(r, 2).Value = wsSrc.Cells(i, 5).Value
                wsRpt.Cells(r, 1).Interior.Color = RGB(255, 235, 156)
                r = r + 1
            End If
        Next i
    End If
    
    ' Rodape
    r = r + 2
    wsRpt.Range("A" & r & ":F" & r).Merge
    wsRpt.Cells(r, 1).Value = "Gerado automaticamente pelo Sistema de Credenciamento V12"
    wsRpt.Cells(r, 1).Font.Size = 8
    wsRpt.Cells(r, 1).Font.Italic = True
    wsRpt.Cells(r, 1).HorizontalAlignment = xlCenter
    
    ' Assinaturas
    r = r + 2
    wsRpt.Cells(r, 1).Value = "Assinatura responsavel: ____________________________"
    
    ' Larguras
    wsRpt.Columns("A").ColumnWidth = 40
    wsRpt.Columns("B").ColumnWidth = 35
    wsRpt.Columns("C").ColumnWidth = 35
    wsRpt.Columns("D").ColumnWidth = 12
    wsRpt.Columns("E").ColumnWidth = 12
    wsRpt.Columns("F").ColumnWidth = 12
    
    Call CTR_ConfigurarImpressao(wsRpt)
    
    Application.ScreenUpdating = True
    On Error Resume Next
    wsRpt.Activate
    Err.Clear
    On Error GoTo falha

    resp = MsgBox("Relatório da Bateria gerado na aba " & ABA_RPT_BATERIA & "." & vbCrLf & vbCrLf & _
                  "Deseja imprimir agora?", vbQuestion + vbYesNo, "Relatório Bateria V12")

    If resp = vbYes Then
        estImp = False
        senImp = ""
        If Util_PrepararAbaParaEscrita(wsRpt, estImp, senImp) Then
            On Error Resume Next
            wsRpt.PrintOut
            If Err.Number <> 0 Then
                MsgBox "Impressão indisponível. Use Arquivo > Imprimir manualmente.", vbInformation, "Relatório Bateria V12"
            End If
            On Error GoTo falha
            Call Util_RestaurarProtecaoAba(wsRpt, estImp, senImp)
        Else
            MsgBox "Não foi possível preparar a aba para impressão. Use Arquivo > Imprimir manualmente.", vbInformation, "Relatório Bateria V12"
        End If
    End If

    Call CT_GravarHistorico("BATERIA_OFICIAL", cTotal, cOK, cFalha, "Manual: " & cManual)

    Exit Sub
falha:
    errN = Err.Number
    errD = Err.Description
    errS = Err.Source

    Application.ScreenUpdating = True

    MsgBox "Erro ao gerar relatório da bateria:" & vbCrLf & vbCrLf & _
           CStr(errN) & " - " & errD & vbCrLf & _
           "Origem: " & errS, _
           vbExclamation, "Relatório Bateria V12"
End Sub

' ============================================================
' RELATÓRIO DO CHECKLIST 136 (VALIDAÇÃO HUMANA)
' ============================================================
Public Sub CTR_GerarRelatorioChecklist136()
    On Error GoTo falha
    
    Dim wsSrc As Worksheet
    On Error Resume Next
    Set wsSrc = ThisWorkbook.Sheets(ABA_CK136)
    On Error GoTo falha
    
    If wsSrc Is Nothing Then
        MsgBox "Aba CHECKLIST_136 não encontrada." & vbCrLf & _
               "Abra a Validação Humana (opção 3) pela Central de Testes.", vbInformation, "Relatório V12"
        Exit Sub
    End If
    
    Application.ScreenUpdating = False
    
    Dim wsRpt As Worksheet
    Set wsRpt = CTR_CriarAbaRelatorio(ABA_RPT_CK136)
    
    ' Titulo
    wsRpt.Range("A1:H1").Merge
    wsRpt.Range("A1").Value = "RELATÓRIO DE VALIDAÇÃO HUMANA " & ChrW(8212) & " CHECKLIST_136 " & ChrW(8212) & " V12"
    With wsRpt.Range("A1")
        .Font.Bold = True
        .Font.Size = 13
        .HorizontalAlignment = xlCenter
        .Interior.Color = RGB(0, 51, 102)
        .Font.Color = RGB(255, 255, 255)
        .RowHeight = 30
    End With
    
    wsRpt.Range("A2:H2").Merge
    wsRpt.Range("A2").Value = "Operador: " & CTR_ObterUsuario() & "  |  Data: " & Format$(Now, "DD/MM/YYYY HH:MM:SS")
    wsRpt.Range("A2").Font.Size = 10
    wsRpt.Range("A2").HorizontalAlignment = xlCenter
    
    ' Cabecalho
    Dim r As Long
    r = 4
    Dim hds As Variant
    hds = Array("ID", "TIPO", "BLOCO", "NOME_TESTE", "STATUS_AUTO", "STATUS_HUMANO", "OBS", "EVIDENCIA")
    Dim c As Long
    For c = 0 To 7
        wsRpt.Cells(r, c + 1).Value = hds(c)
    Next c
    With wsRpt.Range(wsRpt.Cells(r, 1), wsRpt.Cells(r, 8))
        .Font.Bold = True
        .Interior.Color = RGB(217, 225, 242)
        .Borders.LineStyle = xlContinuous
        .HorizontalAlignment = xlCenter
    End With
    
    ' Copiar dados — header do CHECKLIST_136 esta na row 3, dados a partir de row 4
    Dim cConfirmado As Long, cDivergente As Long, cPendente As Long, cNA As Long
    Dim cAutoOK As Long, cAutoFalha As Long, cAutoManual As Long
    cConfirmado = 0: cDivergente = 0: cPendente = 0: cNA = 0
    cAutoOK = 0: cAutoFalha = 0: cAutoManual = 0
    
    Dim totalLinhas As Long
    totalLinhas = 0
    Dim srcRow As Long
    For srcRow = 4 To 139
        Dim idVal As Variant
        idVal = wsSrc.Cells(srcRow, 1).Value
        If IsEmpty(idVal) Or Trim$(CStr(idVal)) = "" Then Exit For
        totalLinhas = totalLinhas + 1
        r = 4 + totalLinhas
        
        wsRpt.Cells(r, 1).Value = wsSrc.Cells(srcRow, 1).Value   ' ID
        wsRpt.Cells(r, 2).Value = wsSrc.Cells(srcRow, 2).Value   ' TIPO
        wsRpt.Cells(r, 3).Value = wsSrc.Cells(srcRow, 3).Value   ' BLOCO
        wsRpt.Cells(r, 4).Value = wsSrc.Cells(srcRow, 4).Value   ' NOME_TESTE
        wsRpt.Cells(r, 5).Value = wsSrc.Cells(srcRow, 7).Value   ' STATUS_AUTO
        wsRpt.Cells(r, 6).Value = wsSrc.Cells(srcRow, 8).Value   ' STATUS_HUMANO
        wsRpt.Cells(r, 7).Value = wsSrc.Cells(srcRow, 9).Value   ' OBS
        wsRpt.Cells(r, 8).Value = wsSrc.Cells(srcRow, 10).Value  ' EVIDENCIA
        
        wsRpt.Cells(r, 1).HorizontalAlignment = xlCenter
        wsRpt.Cells(r, 2).HorizontalAlignment = xlCenter
        wsRpt.Cells(r, 3).HorizontalAlignment = xlCenter
        wsRpt.Cells(r, 5).HorizontalAlignment = xlCenter
        wsRpt.Cells(r, 6).HorizontalAlignment = xlCenter
        
        ' Contagem STATUS_AUTO
        Dim sAuto As String
        sAuto = UCase$(Trim$(CStr(wsRpt.Cells(r, 5).Value)))
        Select Case sAuto
            Case "OK": cAutoOK = cAutoOK + 1
                wsRpt.Cells(r, 5).Interior.Color = RGB(198, 239, 206)
            Case "FALHA": cAutoFalha = cAutoFalha + 1
                wsRpt.Cells(r, 5).Interior.Color = RGB(255, 199, 206)
            Case "MANUAL_ASSISTIDO": cAutoManual = cAutoManual + 1
                wsRpt.Cells(r, 5).Interior.Color = RGB(255, 235, 156)
        End Select
        
        ' Contagem STATUS_HUMANO
        Dim sHum As String
        sHum = UCase$(Trim$(CStr(wsRpt.Cells(r, 6).Value)))
        Select Case sHum
            Case "CONFIRMADO": cConfirmado = cConfirmado + 1
                wsRpt.Cells(r, 6).Interior.Color = RGB(198, 239, 206)
            Case "DIVERGENTE": cDivergente = cDivergente + 1
                wsRpt.Cells(r, 6).Interior.Color = RGB(255, 199, 206)
            Case "N/A": cNA = cNA + 1
            Case Else: cPendente = cPendente + 1
                wsRpt.Cells(r, 6).Interior.Color = RGB(255, 235, 156)
        End Select
        
        ' Destacar linhas MANUAL
        If UCase$(Trim$(CStr(wsRpt.Cells(r, 2).Value))) = "MANUAL" Then
            wsRpt.Range(wsRpt.Cells(r, 1), wsRpt.Cells(r, 8)).Interior.Color = RGB(255, 235, 156)
        End If
    Next srcRow
    
    Dim ultDados As Long
    ultDados = 4 + totalLinhas
    wsRpt.Range(wsRpt.Cells(5, 1), wsRpt.Cells(ultDados, 8)).Borders.LineStyle = xlContinuous
    
    ' Resumo — AUTOMATIZADO
    r = ultDados + 2
    wsRpt.Range("A" & r & ":H" & r).Merge
    wsRpt.Cells(r, 1).Value = "RESULTADO AUTOMATIZADO: " & cAutoOK & " OK  |  " & cAutoFalha & " FALHA  |  " & cAutoManual & " MANUAL"
    wsRpt.Cells(r, 1).Font.Bold = True
    wsRpt.Cells(r, 1).Font.Size = 11
    wsRpt.Cells(r, 1).HorizontalAlignment = xlCenter
    If cAutoFalha > 0 Then
        wsRpt.Cells(r, 1).Interior.Color = RGB(255, 199, 206)
    Else
        wsRpt.Cells(r, 1).Interior.Color = RGB(198, 239, 206)
    End If
    
    ' Resumo — VALIDACAO HUMANA
    r = r + 1
    wsRpt.Range("A" & r & ":H" & r).Merge
    wsRpt.Cells(r, 1).Value = "VALIDAÇÃO HUMANA: " & cConfirmado & " CONFIRMADO  |  " & cDivergente & " DIVERGENTE  |  " & cPendente & " PENDENTE  |  " & cNA & " N/A"
    wsRpt.Cells(r, 1).Font.Bold = True
    wsRpt.Cells(r, 1).Font.Size = 11
    wsRpt.Cells(r, 1).HorizontalAlignment = xlCenter
    If cDivergente > 0 Then
        wsRpt.Cells(r, 1).Interior.Color = RGB(255, 199, 206)
    ElseIf cPendente > 0 Then
        wsRpt.Cells(r, 1).Interior.Color = RGB(255, 235, 156)
    Else
        wsRpt.Cells(r, 1).Interior.Color = RGB(198, 239, 206)
    End If
    
    ' Divergencias detalhadas
    If cDivergente > 0 Then
        r = r + 2
        wsRpt.Cells(r, 1).Value = "DIVERGÊNCIAS ENCONTRADAS:"
        wsRpt.Cells(r, 1).Font.Bold = True
        wsRpt.Cells(r, 1).Font.Color = RGB(200, 0, 0)
        r = r + 1
        Dim dr As Long
        For dr = 5 To ultDados
            If UCase$(Trim$(CStr(wsRpt.Cells(dr, 6).Value))) = "DIVERGENTE" Then
                wsRpt.Cells(r, 1).Value = wsRpt.Cells(dr, 1).Value
                wsRpt.Cells(r, 2).Value = wsRpt.Cells(dr, 4).Value
                wsRpt.Cells(r, 3).Value = wsRpt.Cells(dr, 5).Value
                wsRpt.Cells(r, 4).Value = wsRpt.Cells(dr, 7).Value
                wsRpt.Cells(r, 1).Interior.Color = RGB(255, 230, 233)
                r = r + 1
            End If
        Next dr
    End If
    
    ' Assinaturas
    r = r + 2
    wsRpt.Cells(r, 1).Value = "Assinatura operador: ____________________________"
    wsRpt.Cells(r + 1, 1).Value = "Assinatura supervisor: __________________________"
    
    ' Rodape
    r = r + 3
    wsRpt.Range("A" & r & ":H" & r).Merge
    wsRpt.Cells(r, 1).Value = "Gerado automaticamente pelo Sistema de Credenciamento V12"
    wsRpt.Cells(r, 1).Font.Size = 8
    wsRpt.Cells(r, 1).Font.Italic = True
    wsRpt.Cells(r, 1).HorizontalAlignment = xlCenter
    
    ' Larguras
    wsRpt.Columns("A").ColumnWidth = 6
    wsRpt.Columns("B").ColumnWidth = 9
    wsRpt.Columns("C").ColumnWidth = 9
    wsRpt.Columns("D").ColumnWidth = 36
    wsRpt.Columns("E").ColumnWidth = 16
    wsRpt.Columns("F").ColumnWidth = 16
    wsRpt.Columns("G").ColumnWidth = 22
    wsRpt.Columns("H").ColumnWidth = 14
    
    Call CTR_ConfigurarImpressao(wsRpt)
    
    Application.ScreenUpdating = True
    wsRpt.Activate
    
    Dim resp As Long
    resp = MsgBox("Relatório de validação humana (136) gerado." & vbCrLf & vbCrLf & _
                  "Deseja imprimir agora?", vbQuestion + vbYesNo, "Relatório CK136 V12")
    
    If resp = vbYes Then
        On Error Resume Next
        wsRpt.PrintOut
        If Err.Number <> 0 Then
            MsgBox "Não foi possível imprimir. Use Arquivo > Imprimir.", vbInformation, "Relatório V12"
        End If
        On Error GoTo falha
    End If
    
    Call CT_GravarHistorico("CHECKLIST_136", totalLinhas, cConfirmado, cDivergente, _
        "Pendente: " & cPendente & " | N/A: " & cNA & " | AutoOK: " & cAutoOK & " | AutoFalha: " & cAutoFalha)
    
    Exit Sub
falha:
    Application.ScreenUpdating = True
    MsgBox "Erro ao gerar relatório do checklist 136: " & Err.Description, vbExclamation, "Relatório V12"
End Sub

' ============================================================
' RELATÓRIO CONSOLIDADO
' ============================================================
Public Sub CTR_GerarRelatorioConsolidado()
    On Error GoTo falha
    
    Application.ScreenUpdating = False
    
    Dim wsRpt As Worksheet
    Set wsRpt = CTR_CriarAbaRelatorio(ABA_RPT_CONSOLIDADO)
    
    ' Titulo
    wsRpt.Range("A1:F1").Merge
    wsRpt.Range("A1").Value = "RELATÓRIO CONSOLIDADO DE TESTES " & ChrW(8212) & " V12"
    With wsRpt.Range("A1")
        .Font.Bold = True
        .Font.Size = 14
        .HorizontalAlignment = xlCenter
        .Interior.Color = RGB(0, 51, 102)
        .Font.Color = RGB(255, 255, 255)
        .RowHeight = 30
    End With
    
    wsRpt.Range("A2:F2").Merge
    wsRpt.Range("A2").Value = "Operador: " & CTR_ObterUsuario() & "  |  Data: " & Format$(Now, "DD/MM/YYYY HH:MM:SS")
    wsRpt.Range("A2").Font.Size = 10
    wsRpt.Range("A2").HorizontalAlignment = xlCenter
    
    ' === Seção 1: Roteiro Rápido ===
    Dim r As Long
    r = 4
    wsRpt.Range("A" & r & ":F" & r).Merge
    wsRpt.Cells(r, 1).Value = "1. ROTEIRO RÁPIDO (16 passos)"
    wsRpt.Cells(r, 1).Font.Bold = True
    wsRpt.Cells(r, 1).Font.Size = 12
    wsRpt.Cells(r, 1).Interior.Color = RGB(217, 225, 242)
    r = r + 1
    
    Dim wsRot As Worksheet
    On Error Resume Next
    Set wsRot = ThisWorkbook.Sheets(ABA_ROTEIRO)
    On Error GoTo falha
    
    If wsRot Is Nothing Then
        wsRpt.Cells(r, 1).Value = "Roteiro não executado."
        wsRpt.Cells(r, 1).Font.Italic = True
        r = r + 2
    Else
        Dim rOK As Long, rFail As Long, rPend As Long
        rOK = 0: rFail = 0: rPend = 0
        Dim ri As Long
        For ri = 4 To 19
            Dim rSt As String
            rSt = UCase$(Trim$(CStr(wsRot.Cells(ri, 5).Value)))
            Select Case rSt
                Case "OK": rOK = rOK + 1
                Case "FALHA": rFail = rFail + 1
                Case Else: rPend = rPend + 1
            End Select
        Next ri
        wsRpt.Cells(r, 1).Value = "OK:"
        wsRpt.Cells(r, 2).Value = rOK
        wsRpt.Cells(r + 1, 1).Value = "FALHA:"
        wsRpt.Cells(r + 1, 2).Value = rFail
        wsRpt.Cells(r + 2, 1).Value = "PENDENTE:"
        wsRpt.Cells(r + 2, 2).Value = rPend
        CTR_ColorirResumo wsRpt, r, rFail, rPend
        r = r + 4
    End If
    
    ' === Secao 2: Bateria Oficial ===
    wsRpt.Range("A" & r & ":F" & r).Merge
    wsRpt.Cells(r, 1).Value = "2. BATERIA OFICIAL AUTOMATIZADA"
    wsRpt.Cells(r, 1).Font.Bold = True
    wsRpt.Cells(r, 1).Font.Size = 12
    wsRpt.Cells(r, 1).Interior.Color = RGB(217, 225, 242)
    r = r + 1
    
    Dim wsBO As Worksheet
    On Error Resume Next
    Set wsBO = ThisWorkbook.Sheets(ABA_TESTE_OFICIAL)
    On Error GoTo falha
    
    If wsBO Is Nothing Then
        wsRpt.Cells(r, 1).Value = "Bateria não executada."
        wsRpt.Cells(r, 1).Font.Italic = True
        r = r + 2
    Else
        Dim bOK As Long, bFail As Long, bMan As Long
        bOK = 0: bFail = 0: bMan = 0
        Dim ultBO As Long
        ultBO = wsBO.Cells(wsBO.Rows.count, 1).End(xlUp).row
        Dim bi As Long
        For bi = 7 To ultBO
            Dim bSt As String
            bSt = UCase$(Trim$(CStr(wsBO.Cells(bi, 7).Value)))
            Select Case bSt
                Case "OK": bOK = bOK + 1
                Case "FALHA": bFail = bFail + 1
                Case "MANUAL_ASSISTIDO", "MANUAL": bMan = bMan + 1
            End Select
        Next bi
        wsRpt.Cells(r, 1).Value = "OK:"
        wsRpt.Cells(r, 2).Value = bOK
        wsRpt.Cells(r + 1, 1).Value = "FALHA:"
        wsRpt.Cells(r + 1, 2).Value = bFail
        wsRpt.Cells(r + 2, 1).Value = "MANUAL:"
        wsRpt.Cells(r + 2, 2).Value = bMan
        CTR_ColorirResumo wsRpt, r, bFail, 0
        r = r + 4
    End If
    
    ' === Secao 3: Checklist 136 ===
    wsRpt.Range("A" & r & ":F" & r).Merge
    wsRpt.Cells(r, 1).Value = "3. VALIDAÇÃO HUMANA (136 itens)"
    wsRpt.Cells(r, 1).Font.Bold = True
    wsRpt.Cells(r, 1).Font.Size = 12
    wsRpt.Cells(r, 1).Interior.Color = RGB(217, 225, 242)
    r = r + 1
    
    Dim wsCK As Worksheet
    On Error Resume Next
    Set wsCK = ThisWorkbook.Sheets(ABA_CK136)
    On Error GoTo falha
    
    If wsCK Is Nothing Then
        wsRpt.Cells(r, 1).Value = "Checklist não preenchido."
        wsRpt.Cells(r, 1).Font.Italic = True
        r = r + 2
    Else
        Dim cConf As Long, cDiv As Long, cPnd As Long
        cConf = 0: cDiv = 0: cPnd = 0
        Dim ci As Long
        For ci = 4 To 139
            If IsEmpty(wsCK.Cells(ci, 1).Value) Then Exit For
            Dim cSt As String
            cSt = UCase$(Trim$(CStr(wsCK.Cells(ci, 8).Value)))
            Select Case cSt
                Case "CONFIRMADO": cConf = cConf + 1
                Case "DIVERGENTE": cDiv = cDiv + 1
                Case Else: cPnd = cPnd + 1
            End Select
        Next ci
        wsRpt.Cells(r, 1).Value = "CONFIRMADO:"
        wsRpt.Cells(r, 2).Value = cConf
        wsRpt.Cells(r + 1, 1).Value = "DIVERGENTE:"
        wsRpt.Cells(r + 1, 2).Value = cDiv
        wsRpt.Cells(r + 2, 1).Value = "PENDENTE:"
        wsRpt.Cells(r + 2, 2).Value = cPnd
        CTR_ColorirResumo wsRpt, r, cDiv, cPnd
        r = r + 4
    End If
    
    ' === Secao 4: Historico ===
    wsRpt.Range("A" & r & ":F" & r).Merge
    wsRpt.Cells(r, 1).Value = "4. HISTORICO DE EXECUCOES"
    wsRpt.Cells(r, 1).Font.Bold = True
    wsRpt.Cells(r, 1).Font.Size = 12
    wsRpt.Cells(r, 1).Interior.Color = RGB(217, 225, 242)
    r = r + 1
    
    Dim wsHist As Worksheet
    On Error Resume Next
    Set wsHist = ThisWorkbook.Sheets(ABA_HIST)
    On Error GoTo falha
    
    If wsHist Is Nothing Then
        wsRpt.Cells(r, 1).Value = "Nenhum historico registrado."
        wsRpt.Cells(r, 1).Font.Italic = True
        r = r + 2
    Else
        Dim ultH As Long
        ultH = wsHist.Cells(wsHist.Rows.count, 1).End(xlUp).row
        If ultH < 2 Then
            wsRpt.Cells(r, 1).Value = "Nenhum historico registrado."
            wsRpt.Cells(r, 1).Font.Italic = True
            r = r + 2
        Else
            ' Cabecalho
            wsRpt.Cells(r, 1).Value = "EXECUCAO_ID"
            wsRpt.Cells(r, 2).Value = "TIPO"
            wsRpt.Cells(r, 3).Value = "DATA"
            wsRpt.Cells(r, 4).Value = "TOTAL"
            wsRpt.Cells(r, 5).Value = "OK"
            wsRpt.Cells(r, 6).Value = "FALHA"
            With wsRpt.Range(wsRpt.Cells(r, 1), wsRpt.Cells(r, 6))
                .Font.Bold = True
                .Interior.Color = RGB(200, 210, 230)
                .Borders.LineStyle = xlContinuous
            End With
            r = r + 1
            Dim hi As Long
            For hi = 2 To ultH
                wsRpt.Cells(r, 1).Value = wsHist.Cells(hi, 1).Value
                wsRpt.Cells(r, 2).Value = wsHist.Cells(hi, 2).Value
                wsRpt.Cells(r, 3).Value = wsHist.Cells(hi, 3).Value
                wsRpt.Cells(r, 4).Value = wsHist.Cells(hi, 4).Value
                wsRpt.Cells(r, 5).Value = wsHist.Cells(hi, 5).Value
                wsRpt.Cells(r, 6).Value = wsHist.Cells(hi, 6).Value
                wsRpt.Range(wsRpt.Cells(r, 1), wsRpt.Cells(r, 6)).Borders.LineStyle = xlContinuous
                r = r + 1
            Next hi
            r = r + 1
        End If
    End If
    
    ' Veredicto final
    wsRpt.Range("A" & r & ":F" & r).Merge
    Dim veredicto As String
    Dim corVeredicto As Long
    
    Dim temFalha As Boolean
    temFalha = False
    Dim temPendente As Boolean
    temPendente = False
    
    If Not wsBO Is Nothing Then
        If bFail > 0 Then temFalha = True
    End If
    If Not wsCK Is Nothing Then
        If cDiv > 0 Then temFalha = True
        If cPnd > 0 Then temPendente = True
    End If
    If Not wsRot Is Nothing Then
        If rFail > 0 Then temFalha = True
        If rPend > 0 Then temPendente = True
    End If
    
    If temFalha Then
        veredicto = "REPROVADO — Existem falhas ou divergências que precisam ser corrigidas."
        corVeredicto = RGB(255, 199, 206)
    ElseIf temPendente Then
        veredicto = "PENDENTE — Existem itens ainda não validados."
        corVeredicto = RGB(255, 235, 156)
    Else
        veredicto = "APROVADO — Todos os testes e validações foram concluídos com sucesso."
        corVeredicto = RGB(198, 239, 206)
    End If
    
    wsRpt.Cells(r, 1).Value = "VEREDICTO: " & veredicto
    wsRpt.Cells(r, 1).Font.Bold = True
    wsRpt.Cells(r, 1).Font.Size = 12
    wsRpt.Cells(r, 1).HorizontalAlignment = xlCenter
    wsRpt.Cells(r, 1).Interior.Color = corVeredicto
    
    ' Assinaturas
    r = r + 3
    wsRpt.Cells(r, 1).Value = "Assinatura operador: ____________________________"
    wsRpt.Cells(r + 1, 1).Value = "Assinatura supervisor: __________________________"
    wsRpt.Cells(r + 2, 1).Value = "Assinatura gerente: _____________________________"
    
    ' Rodape
    r = r + 4
    wsRpt.Range("A" & r & ":F" & r).Merge
    wsRpt.Cells(r, 1).Value = "Gerado automaticamente pelo Sistema de Credenciamento V12"
    wsRpt.Cells(r, 1).Font.Size = 8
    wsRpt.Cells(r, 1).Font.Italic = True
    wsRpt.Cells(r, 1).HorizontalAlignment = xlCenter
    
    ' Larguras
    wsRpt.Columns("A").ColumnWidth = 20
    wsRpt.Columns("B").ColumnWidth = 20
    wsRpt.Columns("C").ColumnWidth = 20
    wsRpt.Columns("D").ColumnWidth = 12
    wsRpt.Columns("E").ColumnWidth = 12
    wsRpt.Columns("F").ColumnWidth = 12
    
    Call CTR_ConfigurarImpressao(wsRpt)
    
    Application.ScreenUpdating = True
    wsRpt.Activate
    
    Dim resp As Long
    resp = MsgBox("Relatório consolidado gerado." & vbCrLf & vbCrLf & _
                  "Deseja imprimir agora?", vbQuestion + vbYesNo, "Relatório Consolidado V12")
    
    If resp = vbYes Then
        On Error Resume Next
        wsRpt.PrintOut
        If Err.Number <> 0 Then
            MsgBox "Não foi possível imprimir. Use Arquivo > Imprimir.", vbInformation, "Relatório V12"
        End If
        On Error GoTo falha
    End If
    
    Call CT_GravarHistorico("CONSOLIDADO", 0, 0, 0, "Veredicto: " & veredicto)
    
    Exit Sub
falha:
    Application.ScreenUpdating = True
    MsgBox "Erro ao gerar relatório consolidado: " & Err.Description, vbExclamation, "Relatório V12"
End Sub

' ============================================================
' EXPORTAR CSV — RESULTADO_QA (nome com data/hora da execucao)
' ============================================================
Public Function CTR_ExportarTesteOficialCSV() As String
    CTR_ExportarTesteOficialCSV = CTR_ExportarTesteOficialCSVInterno(False)
End Function

Public Function CTR_ExportarTesteOficialFalhasCSV() As String
    CTR_ExportarTesteOficialFalhasCSV = CTR_ExportarTesteOficialCSVInterno(True)
End Function

Private Function CTR_ExportarTesteOficialCSVInterno(ByVal somenteFalhas As Boolean) As String
    On Error GoTo falha
    CTR_ExportarTesteOficialCSVInterno = ""

    Dim fNum As Integer
    fNum = 0

    Dim wsSrc As Worksheet
    On Error Resume Next
    Set wsSrc = ThisWorkbook.Sheets(ABA_TESTE_OFICIAL)
    On Error GoTo falha
    If wsSrc Is Nothing Then Exit Function

    Dim pastaBase As String
    pastaBase = Trim$(ThisWorkbook.Path)
    If Len(pastaBase) = 0 Then
        pastaBase = Environ$("TEMP")
    End If

    Dim stamp As String
    stamp = Format$(Now, "yyyymmdd_hhnnss")
    Dim execId As String
    execId = Trim$(CStr(wsSrc.Cells(1, 2).Value))
    If Len(execId) > 0 Then
        stamp = Replace$(Replace$(Replace$(execId, ":", ""), "-", ""), " ", "_")
    End If

    Dim caminho As String
    If somenteFalhas Then
        caminho = pastaBase & Application.PathSeparator & "BateriaOficial_Falhas_" & stamp & ".csv"
    Else
        caminho = pastaBase & Application.PathSeparator & "BateriaOficial_" & stamp & ".csv"
    End If

    Dim ultLinha As Long
    ultLinha = wsSrc.Cells(wsSrc.Rows.count, 1).End(xlUp).row
    If ultLinha < 6 Then GoTo falha

    fNum = FreeFile
    Open caminho For Output As #fNum

    ' Header row
    Print #fNum, "EXECUCAO_ID;BLOCO;NOME_TESTE;APLICACAO;RESULTADO_ESPERADO;RESULTADO_OBTIDO;STATUS;IMPORTANCIA;EVIDENCIA;DATA_HORA"

    Dim r As Long
    For r = 7 To ultLinha
        If (Not somenteFalhas) Or UCase$(Trim$(CStr(wsSrc.Cells(r, 7).Value))) = "FALHA" Then
            Print #fNum, CTR_CsvLinhaPlanilha(wsSrc, r)
        End If
    Next r

    Close #fNum
    fNum = 0
    CTR_ExportarTesteOficialCSVInterno = caminho
    Exit Function
falha:
    On Error Resume Next
    If fNum <> 0 Then Close #fNum
    CTR_ExportarTesteOficialCSVInterno = ""
End Function

Private Function CTR_CsvCel(ByVal v As Variant) As String
    Dim s As String
    If IsDate(v) Then
        ' Padroniza data/hora no CSV para evitar formato "estatico" ou truncado.
        s = Format$(CDate(v), "dd/mm/yyyy hh:nn:ss")
    Else
        s = CStr(v)
    End If
    s = Trim$(Replace$(Replace$(s, vbCr, " "), vbLf, " "))
    s = Replace$(s, """", """""")
    If InStr(1, s, ";", vbBinaryCompare) > 0 Or InStr(1, s, """", vbBinaryCompare) > 0 Then
        CTR_CsvCel = """" & s & """"
    Else
        CTR_CsvCel = s
    End If
End Function

Private Function CTR_CsvLinhaPlanilha(ByVal ws As Worksheet, ByVal r As Long) As String
    Dim c As Long
    Dim partes(1 To 10) As String
    For c = 1 To 10
        partes(c) = CTR_CsvCel(ws.Cells(r, c).Value)
    Next c
    CTR_CsvLinhaPlanilha = partes(1) & ";" & partes(2) & ";" & partes(3) & ";" & partes(4) & ";" & partes(5) & ";" & partes(6) & ";" & partes(7) & ";" & partes(8) & ";" & partes(9) & ";" & partes(10)
End Function

' ============================================================
' HELPERS
' ============================================================
Private Function CTR_CriarAbaRelatorio(ByVal nomeAba As String) As Worksheet
    Dim ws As Worksheet
    Dim wsAnchor As Worksheet
    Dim delOk As Boolean

    On Error Resume Next
    Set wsAnchor = ThisWorkbook.Sheets(ABA_TESTE_OFICIAL)
    If wsAnchor Is Nothing Then Set wsAnchor = ThisWorkbook.Sheets(1)
    wsAnchor.Activate
    Err.Clear
    On Error GoTo 0

    Set ws = Nothing
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(nomeAba)

    If Not ws Is Nothing Then
        Application.DisplayAlerts = False
        delOk = False
        ws.Delete
        If Err.Number = 0 Then delOk = True
        Application.DisplayAlerts = True
        Err.Clear

        If Not delOk Then
            Set ws = ThisWorkbook.Sheets(nomeAba)
            If Not ws Is Nothing Then
                ws.Cells.Clear
                ws.Cells.ClearFormats
                ws.Tab.Color = RGB(0, 51, 102)
                Set CTR_CriarAbaRelatorio = ws
                On Error GoTo 0
                Exit Function
            End If
        End If
    End If
    Err.Clear
    On Error GoTo 0

    On Error Resume Next
    wsAnchor.Activate
    On Error GoTo 0
    Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.count))
    ws.Name = nomeAba
    ws.Tab.Color = RGB(0, 51, 102)
    Set CTR_CriarAbaRelatorio = ws
End Function

Private Sub CTR_ConfigurarImpressao(ByVal ws As Worksheet)
    On Error Resume Next
    With ws.PageSetup
        .Orientation = xlPortrait
        .PaperSize = xlPaperA4
        .LeftMargin = Application.CentimetersToPoints(1.5)
        .RightMargin = Application.CentimetersToPoints(1.5)
        .TopMargin = Application.CentimetersToPoints(2)
        .BottomMargin = Application.CentimetersToPoints(1.5)
        .CenterHorizontally = True
    End With
    On Error GoTo 0
End Sub

Private Function CTR_ObterUsuario() As String
    On Error Resume Next
    CTR_ObterUsuario = Environ$("USERNAME")
    If CTR_ObterUsuario = "" Then CTR_ObterUsuario = Application.UserName
    On Error GoTo 0
    If CTR_ObterUsuario = "" Then CTR_ObterUsuario = "OPERADOR"
End Function

Private Sub CTR_ColorirResumo(ByVal ws As Worksheet, ByVal startRow As Long, ByVal falhas As Long, ByVal pendentes As Long)
    If falhas > 0 Then
        ws.Cells(startRow + 1, 2).Font.Color = RGB(200, 0, 0)
    End If
    ws.Cells(startRow, 2).Font.Bold = True
    ws.Cells(startRow + 1, 2).Font.Bold = True
    ws.Cells(startRow + 2, 2).Font.Bold = True
    ws.Range(ws.Cells(startRow, 1), ws.Cells(startRow + 2, 2)).Borders.LineStyle = xlContinuous
End Sub

