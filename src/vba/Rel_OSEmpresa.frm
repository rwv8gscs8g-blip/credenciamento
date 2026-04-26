VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Rel_OSEmpresa 
   Caption         =   "Relatorio por Empresa"
   ClientHeight    =   5397
   ClientLeft      =   119
   ClientTop       =   462
   ClientWidth     =   9793.001
   OleObjectBlob   =   "Rel_OSEmpresa.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "Rel_OSEmpresa"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub UserForm_Initialize()
    Me.Caption = Rel_TituloExibicao("RELATORIO DE ORDENS DE SERVICO POR EMPRESA")
End Sub

Private Sub B_RelEmpresaOS_Click()
On Error GoTo erro_carregamento:
    ' V12: eliminado Sheets.Select + Range.Select + ActiveWindow.SelectedSheets.PrintOut
    ' Usa ws.PageSetup e ws.PrintOut diretamente.
    Dim wsRel As Worksheet
    Dim ultimaLinhaRel As Long

    Set wsRel = ThisWorkbook.Sheets(SHEET_RELATORIO)
    ultimaLinhaRel = wsRel.Range("A65536").End(xlUp).row
    wsRel.Columns("A:H").AutoFit

    Call Rel_ConfigurarPagina(wsRel, "RELATORIO DE ORDENS DE SERVICO POR EMPRESA", "H", False, xlLandscape)

    Application.Dialogs(xlDialogPrinterSetup).Show
    wsRel.PrintOut

    MsgBox "Relat" & ChrW(243) & "rio impresso com sucesso!" & vbCrLf & _
           "Identifica" & ChrW(231) & "ão sugerida: " & Rel_NomeArquivoSugerido("RELATORIO DE ORDENS DE SERVICO POR EMPRESA"), _
           vbInformation, "Impress" & ChrW(227) & "o"
    wsRel.Range("A1:H" & ultimaLinhaRel).ClearContents
    wsRel.Range("A1:H" & ultimaLinhaRel).ClearFormats
    Unload Me
Exit Sub
erro_carregamento:
    MsgBox "Erro ao imprimir relatório: " & Err.Description, vbCritical, "Relatório"
End Sub

Private Sub RO_Lista_Click()
On Error GoTo erro_carregamento:
    ' V12: eliminado Sheets.Select + Range.Select + Application.GoTo + ActiveCell + Selection.
    ' Usa referencia direta via ws.Cells(linhaAtual, col) para iterar, e wsRel.Cells(relLinha, col) para escrever.
    Dim wsOS As Worksheet
    Dim wsServ As Worksheet
    Dim wsRel As Worksheet
    Dim EncontrarServ As Range
    Dim empresaId As String
    Dim linhaAtual As Long
    Dim relLinha As Long
    Dim Var1 As String, Var2 As String, Var3 As String, Var4 As String
    Dim Var5 As String, Var6 As String, Var7 As String, Var8 As String
    Dim Var9 As String, Var10 As String

    Const COL_OS_NUM As Long = 1      ' A: numero OS
    Const COL_OS_DEMANDANTE As Long = 2 ' B: demandante (entidade)
    Const COL_OS_SERV_ID As Long = 3  ' C: servico ID
    Const COL_OS_EMP_ID As Long = 4   ' D: empresa ID (campo de busca)
    Const COL_OS_EMPENHO As Long = 5  ' E: numero empenho
    Const COL_OS_DT_SS As Long = 6    ' F: data S.S.
    Const COL_OS_DT_FECH As Long = 8  ' H: data fechamento
    Const COL_OS_VALOR As Long = 12   ' L: valor S.S.
    Const COL_OS_NOTA As Long = 24    ' X: nota total

    empresaId = CStr(RO_Lista.Column(0))
    Var10 = ""

    Set wsOS = ThisWorkbook.Sheets(SHEET_CAD_OS)
    Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    Set wsRel = ThisWorkbook.Sheets(SHEET_RELATORIO)

    ' Escrever cabecalho do relatorio
    wsRel.Cells(1, 1).Value = "N" & ChrW(186) & " O.S."
    wsRel.Cells(1, 2).Value = "DEMANDANTE"
    wsRel.Cells(1, 3).Value = "SERVI" & ChrW(199) & "O"
    wsRel.Cells(1, 4).Value = "N" & ChrW(186) & " EMPENHO"
    wsRel.Cells(1, 5).Value = "DATA S.S."
    wsRel.Cells(1, 6).Value = "DT FECHAMENTO"
    wsRel.Cells(1, 7).Value = "VALOR S.S."
    wsRel.Cells(1, 8).Value = "NOTA TOTAL"
    relLinha = 2

    Call ClassificaOSEmpresa

    If Dt_inicial = Empty Then
        If MsgBox("Deseja emitir relat" & ChrW(243) & "rio com todas as Solicita" & ChrW(231) & ChrW(245) & "es dessa Empresa?", _
                  vbQuestion + vbYesNo, "Ordens de Servi" & ChrW(231) & "o") = vbNo Then
            Dt_inicial.SetFocus
            Exit Sub
        End If
    End If

    With wsOS.Range("D:D")
        Set EncontrarID = .Find(What:=empresaId, LookAt:=xlWhole)
        If Not EncontrarID Is Nothing Then
            linhaAtual = EncontrarID.row

            Do While wsOS.Cells(linhaAtual, COL_OS_EMP_ID).Value = empresaId
                If Dt_inicial = Empty Then
                    ' Sem filtro de data: incluir todos os registros
                    Var1 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_NUM).Value)
                    Var2 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_DEMANDANTE).Value)
                    Var4 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_EMPENHO).Value)
                    Var5 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_DT_SS).Value)
                    Var6 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_DT_FECH).Value)
                    Var7 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_VALOR).Value)
                    Var8 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_NOTA).Value)
                    Var9 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_SERV_ID).Value)

                    If Var10 <> Var9 Then
                        Set EncontrarServ = wsServ.Range("A:A").Find(What:=Var9, LookAt:=xlWhole)
                        If Not EncontrarServ Is Nothing Then
                            Var3 = SafeListVal(EncontrarServ.Offset(0, 3).Value)
                            Var10 = SafeListVal(EncontrarServ.Value)
                        End If
                    End If

                    wsRel.Cells(relLinha, 1).Value = Format(Var1, "000")
                    wsRel.Cells(relLinha, 2).Value = Var2
                    wsRel.Cells(relLinha, 3).Value = Var3
                    wsRel.Cells(relLinha, 4).Value = Var4
                    wsRel.Cells(relLinha, 5).Value = Var5
                    wsRel.Cells(relLinha, 6).Value = Var6
                    wsRel.Cells(relLinha, 7).Value = Format(Var7, "CURRENCY")
                    wsRel.Cells(relLinha, 8).Value = Var8
                    relLinha = relLinha + 1
                Else
                    ' Com filtro de data: incluir somente o periodo indicado
                    If wsOS.Cells(linhaAtual, COL_OS_DT_SS).Value = Dt_inicial Then
                        Var1 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_NUM).Value)
                        Var2 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_DEMANDANTE).Value)
                        Var4 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_EMPENHO).Value)
                        Var5 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_DT_SS).Value)
                        Var6 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_DT_FECH).Value)
                        Var7 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_VALOR).Value)
                        Var8 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_NOTA).Value)
                        Var9 = SafeListVal(wsOS.Cells(linhaAtual, COL_OS_SERV_ID).Value)

                        ' V12.0.0010: corrigido Var3 -> Var10 (Var10 armazena o ultimo servico buscado)
                        If Var10 <> Var9 Then
                            Set EncontrarServ = wsServ.Range("A:A").Find(What:=Var9, LookAt:=xlWhole)
                            If Not EncontrarServ Is Nothing Then
                                Var3 = SafeListVal(EncontrarServ.Offset(0, 3).Value)
                                Var10 = SafeListVal(EncontrarServ.Value)
                            End If
                        End If

                        wsRel.Cells(relLinha, 1).Value = Var1
                        wsRel.Cells(relLinha, 2).Value = Var2
                        wsRel.Cells(relLinha, 3).Value = Var3
                        wsRel.Cells(relLinha, 4).Value = Var4
                        wsRel.Cells(relLinha, 5).Value = Var5
                        wsRel.Cells(relLinha, 6).Value = Var6
                        wsRel.Cells(relLinha, 7).Value = Var7
                        wsRel.Cells(relLinha, 8).Value = Var8
                        relLinha = relLinha + 1
                    End If
                End If

                linhaAtual = linhaAtual + 1
                If linhaAtual > wsOS.Rows.count Then Exit Do
            Loop
        End If
    End With

    MsgBox "Clique no Bot" & ChrW(227) & "o Imprimir Relat" & ChrW(243) & "rio para impress" & ChrW(227) & "o", _
           vbExclamation, "Relat" & ChrW(243) & "rio Pronto"
    Call ClassificaOS
Exit Sub
erro_carregamento:
    MsgBox "Erro ao gerar relatório: " & Err.Description, vbCritical, "Relatório"
End Sub


