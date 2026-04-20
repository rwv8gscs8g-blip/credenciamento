VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Reativa_Entidade 
   Caption         =   "REATIVA ENTIDADE"
   ClientHeight    =   5040
   ClientLeft      =   119
   ClientTop       =   462
   ClientWidth     =   14280
   OleObjectBlob   =   "Reativa_Entidade.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "Reativa_Entidade"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False



Private WithEvents mTxtBusca As MSForms.TextBox
Attribute mTxtBusca.VB_VarHelpID = -1

' Evita reentrancia mTxtBusca_Change durante UI_PreencherListaEntidadesInativas.
Private mListaEntInativCarregando As Boolean

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

Private Function UI_LinhaEntidadeValida(ByVal wsEntInativas As Worksheet, ByVal linhaAtual As Long) As Boolean
    UI_LinhaEntidadeValida = LinhaEntidadeInativosConsideravel(wsEntInativas, linhaAtual)
End Function

Private Function UI_TextoEntidadeParaFiltro(ByVal wsEntInativas As Worksheet, ByVal linhaAtual As Long) As String
    UI_TextoEntidadeParaFiltro = UCase$( _
        UI_SafeListVal(wsEntInativas.Cells(linhaAtual, COL_ENT_ID).Value) & " " & _
        UI_SafeListVal(wsEntInativas.Cells(linhaAtual, COL_ENT_CNPJ).Value) & " " & _
        UI_SafeListVal(wsEntInativas.Cells(linhaAtual, COL_ENT_NOME).Value) & " " & _
        UI_SafeListVal(wsEntInativas.Cells(linhaAtual, COL_ENT_TEL_CEL).Value) & " " & _
        UI_SafeListVal(wsEntInativas.Cells(linhaAtual, COL_ENT_CONT1_NOME).Value) & " " & _
        UI_SafeListVal(wsEntInativas.Cells(linhaAtual, COL_ENT_CONT1_FONE).Value))
End Function

Private Function UI_LinhaEntidadePassaFiltro(ByVal wsEntInativas As Worksheet, ByVal linhaAtual As Long, ByVal filtroU As String) As Boolean
    If filtroU = "" Then
        UI_LinhaEntidadePassaFiltro = True
    Else
        UI_LinhaEntidadePassaFiltro = (InStr(1, UI_TextoEntidadeParaFiltro(wsEntInativas, linhaAtual), filtroU, vbBinaryCompare) > 0)
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

Private Function UI_EntidadeInativasTemConflito(ByVal wsEntInativas As Worksheet, ByVal coll As Collection) As Boolean
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

    For i = 1 To coll.Count
        linhaAtual = CLng(coll(i))

        idAtual = UI_ChaveNormalizadaId(wsEntInativas.Cells(linhaAtual, COL_ENT_ID).Value)
        docAtual = Util_NormalizarDocumentoChave(wsEntInativas.Cells(linhaAtual, COL_ENT_CNPJ).Value)
        nomeAtual = UCase$(Trim$(CStr(wsEntInativas.Cells(linhaAtual, COL_ENT_NOME).Value)))

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

    UI_EntidadeInativasTemConflito = (ids.Count > 1) Or (docs.Count > 1) Or (nomes.Count > 1)
End Function

Private Sub UI_AjustarAlturaListaEntInativ(ByVal lst As Object, ByVal qtdLinhas As Long)
    On Error Resume Next
    Dim hMax As Double
    Dim hCalc As Double

    hMax = Me.InsideHeight - CDbl(lst.Top) - 36
    If hMax < 48 Then hMax = 48
    hCalc = 16# + CDbl(qtdLinhas) * 14#
    If hCalc < 56 Then hCalc = 56
    If hCalc > hMax Then hCalc = hMax
    lst.Height = hCalc
    On Error GoTo 0
End Sub

Private Sub UI_PreencherListaEntidadesInativas(Optional ByVal filtro As String = "")
On Error GoTo erro_carregamento
Dim lst As Object
Dim wsEntInativas As Worksheet
Dim total As Long
Dim linhaAtual As Long
Dim colunaAtual As Long
Dim filtroU As String
Dim arrayitems() As Variant
Dim vistos As Object
Dim chave As String
Dim chaves As Collection
Dim i As Long
Dim linhaUsada As Long

mListaEntInativCarregando = True
filtroU = UCase$(Trim$(filtro))
Cont = 1
NItem = 0
Set wsEntInativas = ThisWorkbook.Sheets(SHEET_ENTIDADE_INATIVOS)
NLinhas = UltimaLinhaAba(SHEET_ENTIDADE_INATIVOS)
Set lst = Me.Controls("R_Lista")
If lst Is Nothing Then GoTo fim_silencioso

With lst
    .Clear
    .ColumnCount = 22
    .ColumnWidths = EntidadeLista_MontarColumnWidths(CDbl(.Width))
End With

If NLinhas < LINHA_DADOS Then GoTo fim_silencioso

Set vistos = CreateObject("Scripting.Dictionary")
Set chaves = New Collection
For linhaAtual = LINHA_DADOS To NLinhas
    If UI_LinhaEntidadeValida(wsEntInativas, linhaAtual) Then
        If UI_LinhaEntidadePassaFiltro(wsEntInativas, linhaAtual, filtroU) Then
            chave = EntidadeInativos_ChaveDedupeLinha(wsEntInativas, linhaAtual)
            If Not vistos.Exists(chave) Then
                chaves.Add chave
            End If
            vistos(chave) = linhaAtual
        End If
    End If
Next linhaAtual

total = chaves.Count
If total = 0 Then GoTo fim_silencioso

ReDim arrayitems(1 To total, 1 To 22)
For i = 1 To chaves.Count
    linhaUsada = CLng(vistos(CStr(chaves(i))))
    For colunaAtual = 1 To 22
        arrayitems(i, colunaAtual) = UI_SafeListVal(wsEntInativas.Cells(linhaUsada, colunaAtual).Value)
    Next colunaAtual
Next i

lst.List = arrayitems()
Call UI_AjustarAlturaListaEntInativ(lst, total)
arrayitems = Empty

fim_silencioso:
mListaEntInativCarregando = False
Exit Sub
erro_carregamento:
mListaEntInativCarregando = False
End Sub

Private Sub UserForm_Initialize()
On Error GoTo fim
    ' V12.0.0006: formulario popula a propria lista ao inicializar.
    ' PreenchimentoEntidadeInativa usa ControleFormulario("Reativa_Entidade", "R_Lista");
    ' o form ja esta em VBA.UserForms neste ponto, entao a busca encontra R_Lista corretamente.
    ' V12.0.0110: TextBox de busca precisa existir no designer; o codigo apenas conecta ao controle.
    Set mTxtBusca = UI_TextBoxSeExiste("TxtFiltro_ReativaEntidade")
    If mTxtBusca Is Nothing Then Set mTxtBusca = UI_PegarTextBoxBuscaTopoDireita()
    If mTxtBusca Is Nothing Then Set mTxtBusca = UI_TextBoxSeExiste("TextBox16")
    Call UI_PreencherListaEntidadesInativas(IIf(mTxtBusca Is Nothing, "", CStr(mTxtBusca.Text)))
fim:
End Sub

Private Sub mTxtBusca_Change()
On Error GoTo fim
    If mListaEntInativCarregando Then Exit Sub
    If mTxtBusca Is Nothing Then Exit Sub
    Call UI_PreencherListaEntidadesInativas(CStr(mTxtBusca.Text))
fim:
End Sub

Private Sub R_Lista_DblClick(ByVal Cancel As MSForms.ReturnBoolean)
On Error GoTo erro_carregamento:
    ' Copia uma linha canonica para ENTIDADE e remove TODAS as linhas correspondentes em ENTIDADE_INATIVOS
    ' (duplicatas com mesmo ID; fantasma com ID vazio e mesmo CNPJ).
    Dim wsInativas As Worksheet
    Dim wsEntidade As Worksheet
    Dim linhaDestino As Long
    Dim estProt As Boolean
    Dim Senha As String
    Dim entidadeIdReativ As String
    Dim cnpjLista As String
    Dim cnpjReativ As String
    Dim linhaDuplicada As Long
    Dim coll As Collection
    Dim linhaCopia As Long
    Dim k As Long
    Dim j As Long
    Dim nDel As Long
    Dim linhasDel() As Long
    Dim tmp As Long
    Dim idParaDup As String

    If R_Lista.ListIndex < 0 Then Exit Sub

    entidadeIdReativ = Trim$(CStr(R_Lista.List(R_Lista.ListIndex, 0)))
    cnpjLista = Trim$(CStr(R_Lista.List(R_Lista.ListIndex, 1)))

    If Len(entidadeIdReativ) = 0 And Len(Util_NormalizarDocumentoChave(cnpjLista)) = 0 Then
        MsgBox "Selecione uma linha com ID ou CNPJ para reativar.", vbExclamation, "Reativa" & ChrW(231) & ChrW(227) & "o"
        Exit Sub
    End If

    Set wsInativas = ThisWorkbook.Sheets(SHEET_ENTIDADE_INATIVOS)
    Set wsEntidade = ThisWorkbook.Sheets(SHEET_ENTIDADE)

    Set coll = Util_EntidadeInativos_ColetarLinhasMesmaChave(wsInativas, LINHA_DADOS, entidadeIdReativ, cnpjLista)
    If coll Is Nothing Then GoTo nao_achou
    If coll.Count = 0 Then GoTo nao_achou

    If UI_EntidadeInativasTemConflito(wsInativas, coll) Then
        MsgBox "Reativacao bloqueada: existem linhas conflitantes para a mesma entidade em ENTIDADE_INATIVOS." & vbCrLf & _
               "Faca o saneamento da base antes de reativar.", _
               vbExclamation, "Integridade de Dados"
        Exit Sub
    End If

    linhaCopia = CLng(coll(1))
    For k = 2 To coll.Count
        If CLng(coll(k)) > linhaCopia Then linhaCopia = CLng(coll(k))
    Next k

    cnpjReativ = Trim$(CStr(wsInativas.Cells(linhaCopia, COL_ENT_CNPJ).Value))
    idParaDup = Trim$(CStr(wsInativas.Cells(linhaCopia, COL_ENT_ID).Value))
    If Len(idParaDup) = 0 Then idParaDup = entidadeIdReativ

    linhaDuplicada = Util_LinhaDuplicadaIdOuDocumento( _
                        wsEntidade, _
                        LINHA_DADOS, _
                        COL_ENT_ID, _
                        idParaDup, _
                        COL_ENT_CNPJ, _
                        cnpjReativ)
    If linhaDuplicada > 0 Then
        MsgBox "Reativa" & ChrW(231) & ChrW(227) & "o bloqueada: j" & ChrW(225) & " existe entidade ativa com o mesmo ID ou CNPJ na aba ENTIDADE." & vbCrLf & _
               "Linha ativa: " & CStr(linhaDuplicada) & vbCrLf & _
               "Fa" & ChrW(231) & "a o saneamento da base antes de reativar.", _
               vbExclamation, "Integridade de Dados"
        Exit Sub
    End If

    If MsgBox("Tem certeza que deseja REATIVAR esta Entidade?", vbQuestion + vbYesNo, "Reativa" & ChrW(231) & ChrW(227) & "o") <> vbYes Then Exit Sub

    linhaDestino = wsEntidade.Cells(wsEntidade.Rows.count, 1).End(xlUp).row + 1
    Call Util_PrepararAbaParaEscrita(wsEntidade, estProt, Senha)
    wsInativas.Rows(linhaCopia).Copy Destination:=wsEntidade.Cells(linhaDestino, 1)
    Call Util_RestaurarProtecaoAba(wsEntidade, estProt, Senha)
    Application.CutCopyMode = False

    nDel = coll.Count
    ReDim linhasDel(1 To nDel)
    For k = 1 To nDel
        linhasDel(k) = CLng(coll(k))
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
            Err.Raise 1004, "Reativar_Entidade", "Nao foi possivel excluir linha " & CStr(linhasDel(k)) & " em ENTIDADE_INATIVOS."
        End If
    Next k
    Call Util_RestaurarProtecaoAba(wsInativas, estProt, Senha)

    Call ClassificaEntidade
    MsgBox "Entidade Reativada com sucesso!", vbExclamation, "Reativa" & ChrW(231) & ChrW(227) & "o"
    Unload Me
    Exit Sub

nao_achou:
    MsgBox "Entidade n" & ChrW(227) & "o encontrada nas inativas.", vbExclamation, "Reativa" & ChrW(231) & ChrW(227) & "o"
    Exit Sub
erro_carregamento:
    MsgBox "Erro ao reativar entidade: " & Err.Description, vbCritical, "Erro"
End Sub

