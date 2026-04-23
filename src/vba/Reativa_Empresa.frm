VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Reativa_Empresa 
   Caption         =   "REATIVA EMPRESA"
   ClientHeight    =   4907
   ClientLeft      =   119
   ClientTop       =   462
   ClientWidth     =   14539
   OleObjectBlob   =   "Reativa_Empresa.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "Reativa_Empresa"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False



Private WithEvents mTxtBusca As MSForms.TextBox
Attribute mTxtBusca.VB_VarHelpID = -1

Private mListaEmpInativCarregando As Boolean

Private Function UI_TextBoxSeExiste(ByVal nome As String) As MSForms.TextBox
    On Error Resume Next
    Set UI_TextBoxSeExiste = Me.Controls(nome)
    On Error GoTo 0
End Function

Private Function UI_PegarTextBoxBuscaTopoDireita() As MSForms.TextBox
    Dim ctl As Object
    Dim melhor As MSForms.TextBox
    Dim leftMax As Double

    On Error GoTo fim

    leftMax = -1
    For Each ctl In Me.Controls
        If TypeName(ctl) = "TextBox" Then
            If ctl.Top <= 20 And ctl.Height <= 22 Then
                If CDbl(ctl.Left) > leftMax Then
                    leftMax = CDbl(ctl.Left)
                    Set melhor = ctl
                End If
            End If
        End If
    Next ctl

    Set UI_PegarTextBoxBuscaTopoDireita = melhor
    Exit Function
fim:
End Function

Private Function UI_SafeListVal(ByVal valor As Variant) As String
    If IsError(valor) Then Exit Function
    If IsNull(valor) Then Exit Function
    If IsEmpty(valor) Then Exit Function

    On Error Resume Next
    UI_SafeListVal = CStr(valor)
    If Err.Number <> 0 Then UI_SafeListVal = ""
    On Error GoTo 0
End Function

Private Function UI_LinhaEmpresaValida(ByVal wsEmpInativas As Worksheet, ByVal linhaAtual As Long) As Boolean
    UI_LinhaEmpresaValida = LinhaEmpresaInativosConsideravel(wsEmpInativas, linhaAtual)
End Function

Private Function UI_TextoEmpresaParaFiltro(ByVal wsEmpInativas As Worksheet, ByVal linhaAtual As Long) As String
    UI_TextoEmpresaParaFiltro = UCase$( _
        UI_SafeListVal(wsEmpInativas.Cells(linhaAtual, COL_EMP_ID).Value) & " " & _
        UI_SafeListVal(wsEmpInativas.Cells(linhaAtual, COL_EMP_CNPJ).Value) & " " & _
        UI_SafeListVal(wsEmpInativas.Cells(linhaAtual, COL_EMP_RAZAO).Value) & " " & _
        UI_SafeListVal(wsEmpInativas.Cells(linhaAtual, COL_EMP_RESPONSAVEL).Value))
End Function

Private Function UI_LinhaEmpresaPassaFiltro(ByVal wsEmpInativas As Worksheet, ByVal linhaAtual As Long, ByVal filtroU As String) As Boolean
    If filtroU = "" Then
        UI_LinhaEmpresaPassaFiltro = True
    Else
        UI_LinhaEmpresaPassaFiltro = (InStr(1, UI_TextoEmpresaParaFiltro(wsEmpInativas, linhaAtual), filtroU, vbBinaryCompare) > 0)
    End If
End Function

Private Function UI_ChaveNormalizadaId(ByVal valor As Variant) As String
    Dim txt As String

    txt = Trim$(CStr(valor))
    If txt = "" Then Exit Function

    If IsNumeric(txt) Then
        UI_ChaveNormalizadaId = CStr(CLng(Val(txt)))
    Else
        UI_ChaveNormalizadaId = UCase$(txt)
    End If
End Function

Private Function UI_EmpresaInativosTemConflito(ByVal wsEmpInativas As Worksheet, ByRef linhas As Variant) As Boolean
    Dim ids As Object
    Dim docs As Object
    Dim nomes As Object
    Dim i As Long
    Dim linhaAtual As Long
    Dim idAtual As String
    Dim docAtual As String
    Dim nomeAtual As String

    Set ids = CreateObject("Scripting.Dictionary")
    Set docs = CreateObject("Scripting.Dictionary")
    Set nomes = CreateObject("Scripting.Dictionary")

    If Not IsArray(linhas) Then Exit Function

    For i = LBound(linhas) To UBound(linhas)
        linhaAtual = CLng(linhas(i))

        idAtual = UI_ChaveNormalizadaId(wsEmpInativas.Cells(linhaAtual, COL_EMP_ID).Value)
        docAtual = Util_NormalizarDocumentoChave(wsEmpInativas.Cells(linhaAtual, COL_EMP_CNPJ).Value)
        nomeAtual = UCase$(Trim$(CStr(wsEmpInativas.Cells(linhaAtual, COL_EMP_RAZAO).Value)))

        If idAtual <> "" Then
            If Not ids.Exists(idAtual) Then ids.Add idAtual, True
        End If
        If docAtual <> "" Then
            If Not docs.Exists(docAtual) Then docs.Add docAtual, True
        End If
        If nomeAtual <> "" Then
            If Not nomes.Exists(nomeAtual) Then nomes.Add nomeAtual, True
        End If
    Next i

    UI_EmpresaInativosTemConflito = (ids.Count > 1) Or (docs.Count > 1) Or (nomes.Count > 1)
End Function

Private Sub UI_PreencherListaEmpresasInativas(Optional ByVal filtro As String = "")
On Error GoTo erro_carregamento
Dim lst As Object
Dim wsEmpInativas As Worksheet
Dim total As Long
Dim linhaAtual As Long
Dim colunaAtual As Long
Dim filtroU As String
Dim arrayitems() As Variant
Dim vistos As Object
Dim chave As String
Dim chaves() As String
Dim qtdChaves As Long
Dim i As Long
Dim linhaUsada As Long

mListaEmpInativCarregando = True
filtroU = UCase$(Trim$(filtro))
Cont = 1
NItem = 0
Set wsEmpInativas = ThisWorkbook.Sheets(SHEET_EMPRESAS_INATIVAS)
NLinhas = UltimaLinhaAba(SHEET_EMPRESAS_INATIVAS)
Set lst = Me.Controls("RM_Lista")
If lst Is Nothing Then GoTo fimEmp

With lst
    .Clear
    .ColumnCount = 19
    .ColumnWidths = EmpresaLista_MontarColumnWidths(CDbl(.Width))
End With

If NLinhas < LINHA_DADOS Then GoTo fimEmp

Set vistos = CreateObject("Scripting.Dictionary")
For linhaAtual = LINHA_DADOS To NLinhas
    If UI_LinhaEmpresaValida(wsEmpInativas, linhaAtual) Then
        If UI_LinhaEmpresaPassaFiltro(wsEmpInativas, linhaAtual, filtroU) Then
            chave = EmpresaInativos_ChaveDedupeLinha(wsEmpInativas, linhaAtual)
            If Not vistos.Exists(chave) Then
                qtdChaves = qtdChaves + 1
                ReDim Preserve chaves(1 To qtdChaves)
                chaves(qtdChaves) = chave
            End If
            vistos(chave) = linhaAtual
        End If
    End If
Next linhaAtual

total = qtdChaves
If total = 0 Then GoTo fimEmp

ReDim arrayitems(1 To total, 1 To 19)
For i = 1 To qtdChaves
    linhaUsada = CLng(vistos(CStr(chaves(i))))
    For colunaAtual = 1 To 19
        arrayitems(i, colunaAtual) = UI_SafeListVal(wsEmpInativas.Cells(linhaUsada, colunaAtual).Value)
    Next colunaAtual
Next i

lst.List = arrayitems()
arrayitems = Empty

fimEmp:
mListaEmpInativCarregando = False
Exit Sub
erro_carregamento:
mListaEmpInativCarregando = False
End Sub

Private Sub UserForm_Initialize()
On Error GoTo fim
    ' V12.0.0006: formulario popula a propria lista ao inicializar.
    ' PreenchimentoEmpresa_Inativo usa ControleFormulario("Reativa_Empresa", "RM_Lista");
    ' o form ja esta em VBA.UserForms neste ponto, entao a busca encontra RM_Lista corretamente.
    ' V12.0.0108: TextBox de busca precisa existir no designer; o codigo apenas conecta ao controle.
    Set mTxtBusca = UI_PegarTextBoxBuscaTopoDireita()
    If mTxtBusca Is Nothing Then Set mTxtBusca = UI_TextBoxSeExiste("TextBox16")
    Call UI_PreencherListaEmpresasInativas(IIf(mTxtBusca Is Nothing, "", CStr(mTxtBusca.Text)))
fim:
End Sub

Private Sub mTxtBusca_Change()
On Error GoTo fim
    If mListaEmpInativCarregando Then Exit Sub
    If mTxtBusca Is Nothing Then Exit Sub
    Call UI_PreencherListaEmpresasInativas(CStr(mTxtBusca.Text))
fim:
End Sub

Private Sub RM_Lista_DblClick(ByVal Cancel As MSForms.ReturnBoolean)
On Error GoTo erro_carregamento:
    Dim wsInativas As Worksheet
    Dim wsEmpresas As Worksheet
    Dim wsCred As Worksheet
    Dim linhaDestino As Long
    Dim linhaCredAtual As Long
    Dim ultimaLinhaCred As Long
    Dim estProt As Boolean
    Dim Senha As String
    Dim empresaIdReativ As String
    Dim cnpjLista As String
    Dim cnpjReativ As String
    Dim linhaDuplicada As Long
    Dim linhasMesmaChave As Variant
    Dim qtdLinhasMesmaChave As Long
    Dim baseLinhas As Long
    Dim linhaCopia As Long
    Dim k As Long
    Dim j As Long
    Dim nDel As Long
    Dim linhasDel() As Long
    Dim tmp As Long
    Dim idParaDup As String
    Dim idParaCred As String

    If RM_Lista.ListIndex < 0 Then Exit Sub

    empresaIdReativ = Trim$(CStr(RM_Lista.List(RM_Lista.ListIndex, 0)))
    cnpjLista = Trim$(CStr(RM_Lista.List(RM_Lista.ListIndex, 1)))

    If Len(empresaIdReativ) = 0 And Len(Util_NormalizarDocumentoChave(cnpjLista)) = 0 Then
        MsgBox "Selecione uma linha com ID ou CNPJ para reativar.", vbExclamation, "Reativa" & ChrW(231) & ChrW(227) & "o"
        Exit Sub
    End If

    Set wsInativas = ThisWorkbook.Sheets(SHEET_EMPRESAS_INATIVAS)
    Set wsEmpresas = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    Set wsCred = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)

    linhasMesmaChave = Util_EmpresaInativos_ColetarLinhasMesmaChave(wsInativas, LINHA_DADOS, empresaIdReativ, cnpjLista)
    If Not IsArray(linhasMesmaChave) Then GoTo nao_achou_emp
    baseLinhas = LBound(linhasMesmaChave)
    qtdLinhasMesmaChave = UBound(linhasMesmaChave) - baseLinhas + 1
    If qtdLinhasMesmaChave <= 0 Then GoTo nao_achou_emp

    If UI_EmpresaInativosTemConflito(wsInativas, linhasMesmaChave) Then
        MsgBox "Reativacao bloqueada: existem linhas conflitantes para a mesma empresa em EMPRESAS_INATIVAS." & vbCrLf & _
               "Faca o saneamento da base antes de reativar.", _
               vbExclamation, "Integridade de Dados"
        Exit Sub
    End If

    linhaCopia = CLng(linhasMesmaChave(baseLinhas))
    For k = baseLinhas + 1 To UBound(linhasMesmaChave)
        If CLng(linhasMesmaChave(k)) > linhaCopia Then linhaCopia = CLng(linhasMesmaChave(k))
    Next k

    cnpjReativ = Trim$(CStr(wsInativas.Cells(linhaCopia, COL_EMP_CNPJ).Value))
    idParaDup = Trim$(CStr(wsInativas.Cells(linhaCopia, COL_EMP_ID).Value))
    If Len(idParaDup) = 0 Then idParaDup = empresaIdReativ
    idParaCred = Trim$(CStr(wsInativas.Cells(linhaCopia, COL_EMP_ID).Value))
    If Len(idParaCred) = 0 Then idParaCred = empresaIdReativ

    linhaDuplicada = Util_LinhaDuplicadaIdOuDocumento( _
                        wsEmpresas, _
                        PrimeiraLinhaDadosEmpresas(), _
                        COL_EMP_ID, _
                        idParaDup, _
                        COL_EMP_CNPJ, _
                        cnpjReativ)
    If linhaDuplicada > 0 Then
        MsgBox "Reativa" & ChrW(231) & ChrW(227) & "o bloqueada: j" & ChrW(225) & " existe empresa ativa com o mesmo ID ou CNPJ na aba EMPRESAS." & vbCrLf & _
               "Linha ativa: " & CStr(linhaDuplicada) & vbCrLf & _
               "Fa" & ChrW(231) & "a o saneamento da base antes de reativar.", _
               vbExclamation, "Integridade de Dados"
        Exit Sub
    End If

    If MsgBox("Tem certeza que deseja REATIVAR esta Empresa?", vbQuestion + vbYesNo, "Reativa" & ChrW(231) & ChrW(227) & "o") <> vbYes Then Exit Sub

    linhaDestino = wsEmpresas.Cells(wsEmpresas.Rows.count, 1).End(xlUp).row + 1
    Call Util_PrepararAbaParaEscrita(wsEmpresas, estProt, Senha)
    wsInativas.Rows(linhaCopia).Copy Destination:=wsEmpresas.Cells(linhaDestino, 1)
    Call Util_RestaurarProtecaoAba(wsEmpresas, estProt, Senha)
    Application.CutCopyMode = False

    nDel = qtdLinhasMesmaChave
    ReDim linhasDel(1 To nDel)
    For k = 1 To nDel
        linhasDel(k) = CLng(linhasMesmaChave(baseLinhas + k - 1))
    Next k
    For k = 1 To nDel - 1
        For j = k + 1 To nDel
            If linhasDel(k) < linhasDel(j) Then
                tmp = linhasDel(k)
                linhasDel(k) = linhasDel(j)
                linhasDel(j) = tmp
            End If
        Next j
    Next k

    Call Util_PrepararAbaParaEscrita(wsInativas, estProt, Senha)
    For k = 1 To nDel
        If Not Util_ExcluirLinhaSegura(wsInativas, linhasDel(k)) Then
            Err.Raise 1004, "Reativar_Empresa", "Nao foi possivel excluir linha " & CStr(linhasDel(k)) & " em EMPRESAS_INATIVAS."
        End If
    Next k
    Call Util_RestaurarProtecaoAba(wsInativas, estProt, Senha)

    ultimaLinhaCred = UltimaLinhaAba(SHEET_CREDENCIADOS)
    If ultimaLinhaCred >= LINHA_DADOS Then
        Call Util_PrepararAbaParaEscrita(wsCred, estProt, Senha)
        Call ClassificaCredenciadoInativo
        For linhaCredAtual = LINHA_DADOS To ultimaLinhaCred
            If Trim$(CStr(wsCred.Cells(linhaCredAtual, COL_CRED_EMP_ID).Value)) <> "" Then
                If Len(Trim$(idParaCred)) > 0 Then
                    If CLng(Val("0" & Trim$(CStr(wsCred.Cells(linhaCredAtual, COL_CRED_EMP_ID).Value)))) = CLng(Val("0" & Trim$(idParaCred))) Then
                        wsCred.Cells(linhaCredAtual, COL_CRED_ATIV_ID).Value = ""
                    End If
                End If
            End If
        Next linhaCredAtual
        Call Util_RestaurarProtecaoAba(wsCred, estProt, Senha)
    End If

    MsgBox "Empresa Reativada com sucesso!", vbExclamation, "Reativa" & ChrW(231) & ChrW(227) & "o"
    Unload Me
    Exit Sub

nao_achou_emp:
    MsgBox "Empresa n" & ChrW(227) & "o encontrada nas inativas.", vbExclamation, "Reativa" & ChrW(231) & ChrW(227) & "o"
    Exit Sub
erro_carregamento:
    MsgBox "Erro ao reativar empresa: " & Err.Description, vbCritical, "Erro"
End Sub
