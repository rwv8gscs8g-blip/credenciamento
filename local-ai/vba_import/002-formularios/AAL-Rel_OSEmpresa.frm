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
    Me.caption = Rel_TituloExibicao("RELATORIO DE ORDENS DE SERVICO POR EMPRESA")
    Dt_inicial.Value = Format$(Rel_DataInicialPadrao(), "dd/mm/yyyy")
End Sub

Private Sub B_RelEmpresaOS_Click()
    On Error GoTo erro_carregamento
    Call GerarImprimirRelatorioOSEmpresa
    Exit Sub
erro_carregamento:
    MsgBox "Erro ao imprimir relatório: " & Err.Description, vbCritical, "Relatório"
End Sub

Private Sub RO_Lista_Click()
    If RO_Lista.ListIndex < 0 Then Exit Sub
End Sub

Private Sub Dt_inicial_AfterUpdate()
    Dim dataNormalizada As Date

    If Trim$(CStr(Dt_inicial.Value)) = "" Then Exit Sub
    If Rel_ParseDataBR(CStr(Dt_inicial.Value), dataNormalizada) Then
        Dt_inicial.Value = Format$(dataNormalizada, "dd/mm/yyyy")
    End If
End Sub

Private Sub GerarImprimirRelatorioOSEmpresa()
    On Error GoTo erro_carregamento

    Dim wsOS As Worksheet
    Dim wsServ As Worksheet
    Dim wsRel As Worksheet
    Dim EncontrarServ As Range
    Dim empresaId As String
    Dim linhaAtual As Long
    Dim relLinha As Long
    Dim ultimaOS As Long
    Dim Var1 As String, Var2 As String, Var3 As String, Var4 As String
    Dim Var5 As String, Var6 As String, Var7 As String, Var8 As String
    Dim Var9 As String, Var10 As String
    Dim dataTexto As String
    Dim dataInicial As Date
    Dim incluirLinha As Boolean
    Dim totalRegistros As Long
    Dim estRel As Boolean
    Dim senRel As String
    Dim relPreparado As Boolean
    Dim errMsg As String

    Const COL_OS_NUM As Long = 1      ' A: numero OS
    Const COL_OS_DEMANDANTE As Long = 2 ' B: demandante (entidade)
    Const COL_OS_SERV_ID As Long = 3  ' C: servico ID
    Const COL_OS_EMP_ID As Long = 4   ' D: empresa ID (campo de busca)
    Const COL_OS_EMPENHO As Long = 5  ' E: numero empenho
    Const COL_OS_DT_SS As Long = 6    ' F: data S.S.
    Const COL_OS_DT_FECH As Long = 8  ' H: data fechamento
    Const COL_OS_VALOR As Long = 12   ' L: valor S.S.
    Const COL_OS_NOTA As Long = 24    ' X: nota total

    If RO_Lista.ListIndex < 0 Then
        MsgBox "Selecione uma empresa para gerar o relatório.", vbExclamation, "Relatório"
        Exit Sub
    End If

    empresaId = CStr(RO_Lista.Column(0))
    Var10 = ""
    dataTexto = Trim$(CStr(Dt_inicial.Value))

    If dataTexto = "" Then
        dataInicial = Rel_DataInicialPadrao()
        Dt_inicial.Value = Format$(dataInicial, "dd/mm/yyyy")
    ElseIf Not Rel_ParseDataBR(dataTexto, dataInicial) Then
        MsgBox "Data inicial inválida. Informe no formato dd/mm/aaaa, ddmmaaaa ou ddmmaa.", vbExclamation, "Relatório"
        Dt_inicial.SetFocus
        Exit Sub
    End If

    Set wsOS = ThisWorkbook.Sheets(SHEET_CAD_OS)
    Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    Set wsRel = ThisWorkbook.Sheets(SHEET_RELATORIO)
    If Not Util_PrepararAbaParaEscrita(wsRel, estRel, senRel) Then
        MsgBox "Não foi possível preparar a aba RELATORIO para o relatório (proteção).", vbCritical, "Relatório"
        Exit Sub
    End If
    relPreparado = True

    wsRel.Cells.Clear
    wsRel.PageSetup.PrintArea = ""
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

    ultimaOS = UltimaLinhaAba(SHEET_CAD_OS)
    For linhaAtual = LINHA_DADOS To ultimaOS
        If IdsIguais(wsOS.Cells(linhaAtual, COL_OS_EMP_ID).Value, empresaId) Then
            incluirLinha = Rel_DataEmPeriodo(wsOS.Cells(linhaAtual, COL_OS_DT_SS).Value, dataInicial)

            If incluirLinha Then
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
                    Else
                        Var3 = ""
                        Var10 = Var9
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
            End If
        End If
    Next linhaAtual

    totalRegistros = relLinha - 2
    If totalRegistros <= 0 Then
        wsRel.Cells.Clear
        wsRel.PageSetup.PrintArea = ""
        Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
        relPreparado = False
        Call ClassificaOS
        MsgBox "Não há ordens de serviço para a empresa selecionada desde " & _
               Format$(dataInicial, "dd/mm/yyyy") & ".", vbInformation, "Relatório"
        Exit Sub
    End If

    wsRel.Columns("A:H").AutoFit
    Call Rel_FormatarCabecalho(wsRel, 8)
    Call Rel_FormatarDados(wsRel, 2, relLinha - 1, 8)
    Call Rel_ConfigurarPagina(wsRel, "RELATORIO DE ORDENS DE SERVICO POR EMPRESA", "H", False, xlLandscape)
    wsRel.PageSetup.PrintArea = wsRel.Range("A1:H" & CStr(relLinha - 1)).Address

    If Application.Dialogs(xlDialogPrinterSetup).Show Then
        wsRel.PrintOut
        MsgBox "Relatório impresso com sucesso!" & vbCrLf & _
               "Identificação sugerida: " & Rel_NomeArquivoSugerido("RELATORIO DE ORDENS DE SERVICO POR EMPRESA"), _
               vbInformation, "Impressão"
    Else
        MsgBox "Impressão cancelada.", vbInformation, "Relatório"
    End If

    wsRel.Cells.Clear
    wsRel.PageSetup.PrintArea = ""
    Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
    relPreparado = False
    Call ClassificaOS
    Unload Me
    Exit Sub
erro_carregamento:
    errMsg = Err.Description
    On Error Resume Next
    If Not wsRel Is Nothing Then
        wsRel.PageSetup.PrintArea = ""
        wsRel.Cells.Clear
        If relPreparado Then Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
    End If
    Call ClassificaOS
    On Error GoTo 0
    If errMsg = "" Then errMsg = "Erro não identificado."
    MsgBox "Erro ao gerar relatório: " & errMsg, vbCritical, "Relatório"
End Sub

Private Function Rel_DataInicialPadrao() As Date
    Rel_DataInicialPadrao = DateSerial(Year(Date), Month(Date) - 7, 1)
End Function

Private Function Rel_ParseDataBR(ByVal texto As String, ByRef dtOut As Date) As Boolean
    Dim partes() As String
    Dim digitos As String
    Dim d As Long
    Dim m As Long
    Dim y As Long

    texto = Trim$(texto)
    If texto = "" Then Exit Function
    texto = Replace(texto, "-", "/")

    If InStr(1, texto, "/", vbBinaryCompare) > 0 Then
        partes = Split(texto, "/")
        If UBound(partes) <> 2 Then Exit Function
        If Not IsNumeric(partes(0)) Or Not IsNumeric(partes(1)) Or Not IsNumeric(partes(2)) Then Exit Function
        d = CLng(Val(partes(0)))
        m = CLng(Val(partes(1)))
        y = CLng(Val(partes(2)))
    Else
        digitos = Rel_ApenasDigitos(texto)
        If Len(digitos) = 8 Then
            d = CLng(Val(Left$(digitos, 2)))
            m = CLng(Val(Mid$(digitos, 3, 2)))
            y = CLng(Val(Right$(digitos, 4)))
        ElseIf Len(digitos) = 6 Then
            d = CLng(Val(Left$(digitos, 2)))
            m = CLng(Val(Mid$(digitos, 3, 2)))
            y = CLng(Val(Right$(digitos, 2)))
        Else
            Exit Function
        End If
    End If

    If y < 100 Then y = 2000 + y
    If d < 1 Or d > 31 Then Exit Function
    If m < 1 Or m > 12 Then Exit Function
    If y < 1900 Then Exit Function

    On Error GoTo falha
    dtOut = DateSerial(y, m, d)
    If Day(dtOut) <> d Or Month(dtOut) <> m Or Year(dtOut) <> y Then Exit Function
    Rel_ParseDataBR = True
    Exit Function
falha:
    Rel_ParseDataBR = False
End Function

Private Function Rel_ApenasDigitos(ByVal texto As String) As String
    Dim i As Long
    Dim c As String
    Dim saida As String

    For i = 1 To Len(texto)
        c = Mid$(texto, i, 1)
        If c >= "0" And c <= "9" Then saida = saida & c
    Next i

    Rel_ApenasDigitos = saida
End Function

Private Function Rel_DataEmPeriodo(ByVal valor As Variant, ByVal dataInicial As Date) As Boolean
    Dim dtValor As Date

    On Error GoTo tentar_texto
    If IsDate(valor) Then
        Rel_DataEmPeriodo = (DateValue(CDate(valor)) >= DateValue(dataInicial))
        Exit Function
    End If

tentar_texto:
    If Rel_ParseDataBR(CStr(valor), dtValor) Then
        Rel_DataEmPeriodo = (DateValue(dtValor) >= DateValue(dataInicial))
    End If
End Function


