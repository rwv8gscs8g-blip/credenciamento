Attribute VB_Name = "Preencher"
Option Explicit

Private Const STATUS_PREOS_AGUARDANDO_ACEITE As String = "AGUARDANDO_ACEITE"
Private Const STATUS_OS_EM_EXECUCAO As String = "EM_EXECUCAO"

' IMP_AVALIA: desprotecao unica entre Preencher/Imprimir/Limpar (evita 1004 na avaliacao).
Private mImpAvaliaEstavaProt As Boolean
Private mImpAvaliaSenha As String
Private mImpAvaliaEmUso As Boolean

' Cache Dictionary para evitar loop O(n*m) em BuscarCnaeAtividade.
' Chave: ChaveId(ATIV_ID), Valor: CNAE string.
Private mCacheCnaeAtiv As Object

' Retorna string segura para atribuir � propriedade List de ListBox (evita erro 380).
Public Function SafeListVal(ByVal v As Variant) As String
    If IsError(v) Then SafeListVal = "": Exit Function
    If IsNull(v) Then SafeListVal = "": Exit Function
    If IsEmpty(v) Then SafeListVal = "": Exit Function
    On Error Resume Next
    SafeListVal = CStr(v)
    If Err.Number <> 0 Then SafeListVal = ""
    On Error GoTo 0
End Function

' CNPJ mais largo, nome/razao maior, celular ocupa folga ate a borda (soma = lim).
Private Sub ListaEntEmp_CalcularQuatroLarguras(ByVal lim As Long, ByRef w1 As Long, ByRef w2 As Long, ByRef w3 As Long, ByRef w4 As Long)
    Const R1 As Long = 118
    Const R2 As Long = 338
    Const R3 As Long = 199
    Const R4 As Long = 95
    Dim den As Long

    den = R1 + R2 + R3 + R4
    w1 = CLng(Int((CDbl(lim) * R1) / den))
    w3 = CLng(Int((CDbl(lim) * R3) / den))
    w4 = CLng(Int((CDbl(lim) * R4) / den))
    w2 = lim - w1 - w3 - w4

    Do While (w1 + w2 + w3 + w4) > lim
        If w2 > 130 Then
            w2 = w2 - 1
        ElseIf w3 > 82 Then
            w3 = w3 - 1
        ElseIf w4 > 72 Then
            w4 = w4 - 1
        ElseIf w1 > 90 Then
            w1 = w1 - 1
        Else
            Exit Do
        End If
    Loop

    Do While (w1 + w2 + w3 + w4) < lim
        If w4 < 138 Then
            w4 = w4 + 1
        ElseIf w1 < 132 Then
            w1 = w1 + 1
        Else
            w2 = w2 + 1
        End If
    Loop
End Sub

Private Function ListaEntEmp_LimUtilLista(Optional ByVal largListaPts As Double = 0) As Long
    Const MARGEM As Double = 18#
    Dim lim As Long
    If largListaPts <= 1# Then largListaPts = 620#
    lim = CLng(Fix(largListaPts - MARGEM + 0.5))
    If lim < 380 Then lim = 520
    ListaEntEmp_LimUtilLista = lim
End Function

' C_Lista / C_ListaRodizio / R_Lista: colunas visiveis 1=CNPJ, 2=Nome, 11=Contato, 12=Celular.
Public Function EntidadeLista_MontarColumnWidths(Optional ByVal largListaPts As Double = 0) As String
    Dim lim As Long
    Dim w1 As Long, w2 As Long, w3 As Long, w4 As Long
    lim = ListaEntEmp_LimUtilLista(largListaPts)
    Call ListaEntEmp_CalcularQuatroLarguras(lim, w1, w2, w3, w4)
    EntidadeLista_MontarColumnWidths = "0;" & CStr(w1) & ";" & CStr(w2) & ";0;0;0;0;0;0;0;0;" & CStr(w3) & ";" & CStr(w4) & ";0;0;0;0;0;0;0;0;0;0"
End Function

' EMP_Lista / RM_Lista: 1=CNPJ, 2=Razao, 4=Nome empresario, 12=Tel. celular (mesma proporcao que Entidade).
Public Function EmpresaLista_MontarColumnWidths(Optional ByVal largListaPts As Double = 0) As String
    Dim lim As Long
    Dim w1 As Long, w2 As Long, w3 As Long, w4 As Long
    lim = ListaEntEmp_LimUtilLista(largListaPts)
    Call ListaEntEmp_CalcularQuatroLarguras(lim, w1, w2, w3, w4)
    EmpresaLista_MontarColumnWidths = "0;" & CStr(w1) & ";" & CStr(w2) & ";0;" & CStr(w3) & ";0;0;0;0;0;0;0;" & CStr(w4) & ";0;0;0;0;0;0"
End Function

Private Function TextoEmpresaParaFiltro(ByVal wsEmp As Worksheet, ByVal linha As Long) As String
    TextoEmpresaParaFiltro = UCase$( _
        SafeListVal(wsEmp.Cells(linha, COL_EMP_ID).Value) & " " & _
        SafeListVal(wsEmp.Cells(linha, COL_EMP_CNPJ).Value) & " " & _
        SafeListVal(wsEmp.Cells(linha, COL_EMP_RAZAO).Value) & " " & _
        SafeListVal(wsEmp.Cells(linha, COL_EMP_RESPONSAVEL).Value))
End Function

Private Function EmpresaLinhaPassaFiltro(ByVal wsEmp As Worksheet, ByVal linha As Long, ByVal filtroU As String) As Boolean
    EmpresaLinhaPassaFiltro = UtilFiltro_LinhaAtende(TextoEmpresaParaFiltro(wsEmp, linha), filtroU)
End Function

Private Function TextoEntidadeParaFiltro(ByVal wsEnt As Worksheet, ByVal linha As Long) As String
    TextoEntidadeParaFiltro = UCase$( _
        SafeListVal(wsEnt.Cells(linha, COL_ENT_ID).Value) & " " & _
        SafeListVal(wsEnt.Cells(linha, COL_ENT_CNPJ).Value) & " " & _
        SafeListVal(wsEnt.Cells(linha, COL_ENT_NOME).Value) & " " & _
        SafeListVal(wsEnt.Cells(linha, COL_ENT_TEL_CEL).Value) & " " & _
        SafeListVal(wsEnt.Cells(linha, COL_ENT_CONT1_NOME).Value) & " " & _
        SafeListVal(wsEnt.Cells(linha, COL_ENT_CONT1_FONE).Value))
End Function

Private Function EntidadeLinhaPassaFiltro(ByVal wsEnt As Worksheet, ByVal linha As Long, ByVal filtroU As String) As Boolean
    EntidadeLinhaPassaFiltro = UtilFiltro_LinhaAtende(TextoEntidadeParaFiltro(wsEnt, linha), filtroU)
End Function

Private Function LinhaServicoPassaFiltroCred(ByVal wsServ As Worksheet, ByVal linha As Long, ByVal filtroU As String) As Boolean
    Dim textoBusca As String

    textoBusca = SafeListVal(wsServ.Cells(linha, COL_SERV_ID).Value) & " " & _
                SafeListVal(wsServ.Cells(linha, COL_SERV_ATIV_ID).Value) & " " & _
                SafeListVal(BuscarCnaeAtividade(wsServ.Cells(linha, COL_SERV_ATIV_ID).Value)) & " " & _
                SafeListVal(wsServ.Cells(linha, COL_SERV_ATIV_DESC).Value) & " " & _
                SafeListVal(wsServ.Cells(linha, COL_SERV_DESCRICAO).Value)
    LinhaServicoPassaFiltroCred = UtilFiltro_LinhaAtende(textoBusca, filtroU)
End Function

Private Sub CarregarCacheCnaeAtividade()
    Dim wsAtiv As Worksheet
    Dim ultima As Long
    Dim linha As Long
    Dim chave As String

    Set mCacheCnaeAtiv = CreateObject("Scripting.Dictionary")
    Set wsAtiv = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
    ultima = UltimaLinhaAba(SHEET_ATIVIDADES)
    If ultima < LINHA_DADOS Then Exit Sub

    For linha = LINHA_DADOS To ultima
        chave = ChaveId(wsAtiv.Cells(linha, COL_ATIV_ID).Value)
        If chave <> "" Then
            mCacheCnaeAtiv(chave) = SafeListVal(wsAtiv.Cells(linha, COL_ATIV_CNAE).Value)
        End If
    Next linha
End Sub

' Invalida o cache apos qualquer alteracao em ATIVIDADES.
Public Sub InvalidarCacheCnaeAtividade()
    Set mCacheCnaeAtiv = Nothing
End Sub

Private Function BuscarCnaeAtividade(ByVal ativId As Variant) As String
    Dim chaveBusca As String

    chaveBusca = ChaveId(ativId)
    If chaveBusca = "" Then Exit Function

    If mCacheCnaeAtiv Is Nothing Then CarregarCacheCnaeAtividade
    If mCacheCnaeAtiv.Exists(chaveBusca) Then
        BuscarCnaeAtividade = CStr(mCacheCnaeAtiv(chaveBusca))
    End If
End Function

Private Function FormularioAberto(ByVal nomeFormulario As String, Optional ByVal criarSeAusente As Boolean = False) As Object
    Dim frm As Object
    Dim frmFallback As Object

    For Each frm In VBA.UserForms
        If TypeName(frm) = nomeFormulario Then
            On Error Resume Next
            If frm.Visible Then
                Set FormularioAberto = frm
                On Error GoTo 0
                Exit Function
            End If
            On Error GoTo 0
            If frmFallback Is Nothing Then Set frmFallback = frm
        End If
    Next frm

    If Not frmFallback Is Nothing Then
        Set FormularioAberto = frmFallback
        Exit Function
    End If

    If criarSeAusente Then
        On Error Resume Next
        Set FormularioAberto = VBA.UserForms.Add(nomeFormulario)
        On Error GoTo 0
    End If
End Function

Private Function ControleTemFilhos(ByVal ctl As Object) As Boolean
    On Error GoTo fim
    ControleTemFilhos = (ctl.Controls.Count >= 0)
    Exit Function
fim:
    ControleTemFilhos = False
End Function

Private Function BuscarControleRecursivo(ByVal container As Object, ByVal nomeControle As String) As Object
    Dim ctl As Object

    On Error GoTo fim

    For Each ctl In container.Controls
        If StrComp(ctl.Name, nomeControle, vbTextCompare) = 0 Then
            Set BuscarControleRecursivo = ctl
            Exit Function
        End If

        If ControleTemFilhos(ctl) Then
            Set BuscarControleRecursivo = BuscarControleRecursivo(ctl, nomeControle)
            If Not BuscarControleRecursivo Is Nothing Then Exit Function
        End If
    Next ctl

fim:
End Function

Private Function ControleFormulario(ByVal nomeFormulario As String, ByVal nomeControle As String, Optional ByVal criarFormulario As Boolean = False) As Object
    Dim frm As Object

    Set frm = FormularioAberto(nomeFormulario, criarFormulario)
    If frm Is Nothing Then Exit Function

    Set ControleFormulario = BuscarControleRecursivo(frm, nomeControle)
End Function

Private Function TextoControleFormulario(ByVal nomeFormulario As String, ByVal nomeControle As String) As String
    Dim ctl As Object

    Set ctl = ControleFormulario(nomeFormulario, nomeControle)
    If ctl Is Nothing Then Exit Function

    On Error Resume Next
    TextoControleFormulario = CStr(ctl.Text)
    If Err.Number <> 0 Then
        Err.Clear
        TextoControleFormulario = CStr(ctl.Value)
    End If
    On Error GoTo 0
End Function

Public Sub AtualizarListaEntidadeMenuAtual()
    Dim filtroAtual As String

    filtroAtual = TextoControleFormulario("Menu_Principal", "TxtFiltro_Entidade")
    If Trim$(filtroAtual) = "" Then filtroAtual = TextoControleFormulario("Menu_Principal", "TextBox16")
    Call PreenchimentoEntidade(filtroAtual)
End Sub

Public Sub AtualizarListaEmpresaMenuAtual()
    Dim filtroAtual As String

    filtroAtual = TextoControleFormulario("Menu_Principal", "TextBox17")
    If Trim$(filtroAtual) = "" Then filtroAtual = TextoControleFormulario("Menu_Principal", "TxtFiltroEmpresaDin")
    Call PreenchimentoEmpresa(filtroAtual)
End Sub

Private Function LinhaEntidadeValida(ByVal ws As Worksheet, ByVal linhaAtual As Long) As Boolean
    LinhaEntidadeValida = (Trim$(SafeListVal(ws.Cells(linhaAtual, COL_ENT_ID).Value)) <> "" Or _
                           Trim$(SafeListVal(ws.Cells(linhaAtual, COL_ENT_CNPJ).Value)) <> "" Or _
                           Trim$(SafeListVal(ws.Cells(linhaAtual, COL_ENT_NOME).Value)) <> "")
End Function

' ENTIDADE_INATIVOS: exige ID ou CNPJ documentado (evita linha so com nome / teste sem documento).
Public Function LinhaEntidadeInativosConsideravel(ByVal ws As Worksheet, ByVal linhaAtual As Long) As Boolean
    Dim idS As String
    Dim docN As String

    idS = Trim$(SafeListVal(ws.Cells(linhaAtual, COL_ENT_ID).Value))
    docN = Util_NormalizarDocumentoChave(ws.Cells(linhaAtual, COL_ENT_CNPJ).Value)
    LinhaEntidadeInativosConsideravel = (Len(idS) > 0 Or Len(docN) > 0)
End Function

' Chave estavel para deduplicar linhas na aba ENTIDADE_INATIVOS (evita lista duplicada no Reativa).
Public Function EntidadeInativos_ChaveDedupeLinha(ByVal ws As Worksheet, ByVal linhaAtual As Long) As String
    Dim idS As String
    Dim cnpj As String
    Dim i As Long
    Dim dig As String
    Dim ch As String

    idS = Trim$(Replace$(CStr(ws.Cells(linhaAtual, COL_ENT_ID).Value), " ", ""))
    cnpj = Trim$(CStr(ws.Cells(linhaAtual, COL_ENT_CNPJ).Value))

    If Len(idS) > 0 And IsNumeric(idS) Then
        EntidadeInativos_ChaveDedupeLinha = "I" & CStr(CLng(Val("0" & idS)))
        Exit Function
    End If
    If Len(idS) > 0 Then
        EntidadeInativos_ChaveDedupeLinha = "T" & UCase$(idS)
        Exit Function
    End If
    For i = 1 To Len(cnpj)
        ch = Mid$(cnpj, i, 1)
        If ch >= "0" And ch <= "9" Then dig = dig & ch
    Next i
    If Len(dig) >= 11 Then
        EntidadeInativos_ChaveDedupeLinha = "C" & dig
        Exit Function
    End If
    EntidadeInativos_ChaveDedupeLinha = "U" & CStr(linhaAtual)
End Function

' Conta linhas com dados na aba de inativas (para abrir o form sem depender de NLinhas / form visivel).
Public Function ContarLinhasEntidadeInativasValidas() As Long
    Dim ws As Worksheet
    Dim ult As Long
    Dim r As Long

    Set ws = ThisWorkbook.Sheets(SHEET_ENTIDADE_INATIVOS)
    ult = UltimaLinhaAba(SHEET_ENTIDADE_INATIVOS)
    If ult < LINHA_DADOS Then Exit Function

    For r = LINHA_DADOS To ult
        If LinhaEntidadeInativosConsideravel(ws, r) Then ContarLinhasEntidadeInativasValidas = ContarLinhasEntidadeInativasValidas + 1
    Next r
End Function

Private Function LinhaEmpresaValida(ByVal ws As Worksheet, ByVal linhaAtual As Long) As Boolean
    LinhaEmpresaValida = (Trim$(SafeListVal(ws.Cells(linhaAtual, COL_EMP_ID).Value)) <> "" Or _
                          Trim$(SafeListVal(ws.Cells(linhaAtual, COL_EMP_CNPJ).Value)) <> "" Or _
                          Trim$(SafeListVal(ws.Cells(linhaAtual, COL_EMP_RAZAO).Value)) <> "")
End Function

' EMPRESAS_INATIVAS: exige ID ou CNPJ (evita ruido so com razao social).
Public Function LinhaEmpresaInativosConsideravel(ByVal ws As Worksheet, ByVal linhaAtual As Long) As Boolean
    Dim idS As String
    Dim docN As String

    idS = Trim$(SafeListVal(ws.Cells(linhaAtual, COL_EMP_ID).Value))
    docN = Util_NormalizarDocumentoChave(ws.Cells(linhaAtual, COL_EMP_CNPJ).Value)
    LinhaEmpresaInativosConsideravel = (Len(idS) > 0 Or Len(docN) > 0)
End Function

Public Function EmpresaInativos_ChaveDedupeLinha(ByVal ws As Worksheet, ByVal linhaAtual As Long) As String
    Dim idS As String
    Dim cnpj As String
    Dim i As Long
    Dim dig As String
    Dim ch As String

    idS = Trim$(Replace$(CStr(ws.Cells(linhaAtual, COL_EMP_ID).Value), " ", ""))
    cnpj = Trim$(CStr(ws.Cells(linhaAtual, COL_EMP_CNPJ).Value))

    If Len(idS) > 0 And IsNumeric(idS) Then
        EmpresaInativos_ChaveDedupeLinha = "I" & CStr(CLng(Val("0" & idS)))
        Exit Function
    End If
    If Len(idS) > 0 Then
        EmpresaInativos_ChaveDedupeLinha = "T" & UCase$(idS)
        Exit Function
    End If
    For i = 1 To Len(cnpj)
        ch = Mid$(cnpj, i, 1)
        If ch >= "0" And ch <= "9" Then dig = dig & ch
    Next i
    If Len(dig) >= 11 Then
        EmpresaInativos_ChaveDedupeLinha = "C" & dig
        Exit Function
    End If
    EmpresaInativos_ChaveDedupeLinha = "U" & CStr(linhaAtual)
End Function

Public Function ContarLinhasEmpresaInativasValidas() As Long
    Dim ws As Worksheet
    Dim ult As Long
    Dim r As Long

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS_INATIVAS)
    ult = UltimaLinhaAba(SHEET_EMPRESAS_INATIVAS)
    If ult < LINHA_DADOS Then Exit Function

    For r = LINHA_DADOS To ult
        If LinhaEmpresaInativosConsideravel(ws, r) Then ContarLinhasEmpresaInativasValidas = ContarLinhasEmpresaInativasValidas + 1
    Next r
End Function

Private Function LinhaServicoValida(ByVal ws As Worksheet, ByVal linhaAtual As Long) As Boolean
    LinhaServicoValida = (Trim$(SafeListVal(ws.Cells(linhaAtual, COL_SERV_ID).Value)) <> "" Or _
                          Trim$(SafeListVal(ws.Cells(linhaAtual, COL_SERV_ATIV_ID).Value)) <> "" Or _
                          Trim$(SafeListVal(ws.Cells(linhaAtual, COL_SERV_DESCRICAO).Value)) <> "")
End Function

Private Function BuscarLinhaPorId(ByVal ws As Worksheet, ByVal primeiraLinha As Long, ByVal ultimaLinha As Long, ByVal colId As Long, ByVal idBusca As String) As Long
    Dim i As Long

    If ws Is Nothing Then Exit Function
    If Trim$(idBusca) = "" Then Exit Function

    For i = primeiraLinha To ultimaLinha
        If IdsIguais(SafeListVal(ws.Cells(i, colId).Value), idBusca) Then
            BuscarLinhaPorId = i
            Exit Function
        End If
    Next i
End Function

Sub PreenchimentoEntidadeRodizio(Optional ByVal filtro As String = "")
On Error GoTo erro_carregamento
Dim wsEnt As Worksheet
Dim ultima As Long
Dim linha As Long
Dim col As Long
Dim total As Long
Dim idx As Long
Dim idEnt As String
Dim nomeEnt As String
Dim dados As Variant
Dim lst As Object
Dim filtroU As String

filtroU = UCase$(Trim$(filtro))
Set wsEnt = ThisWorkbook.Sheets(SHEET_ENTIDADE)
ultima = UltimaLinhaAba(SHEET_ENTIDADE)
Set lst = ControleFormulario("Menu_Principal", "C_ListaRodizio")
If lst Is Nothing Then Exit Sub

With lst
    .Clear
    .RowSource = vbNullString
    .ColumnCount = 22
    .ColumnWidths = EntidadeLista_MontarColumnWidths(CDbl(.Width))
End With

If ultima < LINHA_DADOS Then Exit Sub

For linha = LINHA_DADOS To ultima
    idEnt = Trim$(SafeListVal(wsEnt.Cells(linha, COL_ENT_ID).Value))
    nomeEnt = Trim$(SafeListVal(wsEnt.Cells(linha, COL_ENT_NOME).Value))
    If idEnt <> "" Or nomeEnt <> "" Then
        If EntidadeLinhaPassaFiltro(wsEnt, linha, filtroU) Then
            total = total + 1
        End If
    End If
Next linha

If total = 0 Then Exit Sub

ReDim dados(1 To total, 1 To 22)
idx = 1

For linha = LINHA_DADOS To ultima
    idEnt = Trim$(SafeListVal(wsEnt.Cells(linha, COL_ENT_ID).Value))
    nomeEnt = Trim$(SafeListVal(wsEnt.Cells(linha, COL_ENT_NOME).Value))
    If idEnt <> "" Or nomeEnt <> "" Then
        If EntidadeLinhaPassaFiltro(wsEnt, linha, filtroU) Then
            For col = 1 To 22
                dados(idx, col) = SafeListVal(wsEnt.Cells(linha, col).Value)
            Next col
            idx = idx + 1
        End If
    End If
Next linha

lst.List = dados
Exit Sub
erro_carregamento:
MsgBox "Falha ao carregar entidades para o rodízio: " & Err.Description, vbExclamation, "Rodízio"
End Sub

Sub PreenchimentoEntidade(Optional ByVal filtro As String = "")
On Error GoTo erro_carregamento
Dim lst As Object
Dim wsEnt As Worksheet
Dim total As Long
Dim idx As Long
Dim filtroU As String

filtroU = UCase$(Trim$(filtro))
Cont = 1
NItem = 0
Set lst = ControleFormulario("Menu_Principal", "C_Lista")
If lst Is Nothing Then Exit Sub
lst.Clear
Set wsEnt = ThisWorkbook.Sheets(SHEET_ENTIDADE)
NLinhas = UltimaLinhaAba(SHEET_ENTIDADE)

With lst
    .ColumnCount = 22
    .ColumnWidths = EntidadeLista_MontarColumnWidths(CDbl(.Width))
End With

If NLinhas < LINHA_DADOS Then Exit Sub

For linha = LINHA_DADOS To NLinhas
    If LinhaEntidadeValida(wsEnt, linha) Then
        If EntidadeLinhaPassaFiltro(wsEnt, linha, filtroU) Then total = total + 1
    End If
Next linha

If total = 0 Then Exit Sub

ReDim arrayitems(1 To total, 1 To 22)
idx = 1
For linha = LINHA_DADOS To NLinhas
    If LinhaEntidadeValida(wsEnt, linha) Then
        If EntidadeLinhaPassaFiltro(wsEnt, linha, filtroU) Then
            For Coluna = 1 To 22
                arrayitems(idx, Coluna) = SafeListVal(wsEnt.Cells(linha, Coluna).Value)
            Next Coluna
            idx = idx + 1
        End If
    End If
Next linha

lst.List = arrayitems()
arrayitems = Empty

Exit Sub
erro_carregamento:
End Sub
Sub PreenchimentoEntidadeInativa()
On Error GoTo erro_carregamento
Dim lst As Object
Dim wsEntInativas As Worksheet
Dim total As Long
Dim vistos As Object
Dim chave As String
Dim chaves() As String
Dim totalChaves As Long
Dim i As Long
Dim linhaUsada As Long

Cont = 1
NItem = 0
Set wsEntInativas = ThisWorkbook.Sheets(SHEET_ENTIDADE_INATIVOS)
NLinhas = UltimaLinhaAba(SHEET_ENTIDADE_INATIVOS)
Set lst = ControleFormulario("Reativa_Entidade", "R_Lista")
If lst Is Nothing Then Exit Sub

With lst
    .Clear
    .ColumnCount = 22
    .ColumnWidths = EntidadeLista_MontarColumnWidths(CDbl(.Width))
End With

If NLinhas < LINHA_DADOS Then Exit Sub

Set vistos = CreateObject("Scripting.Dictionary")
totalChaves = 0
ReDim chaves(1 To NLinhas - LINHA_DADOS + 1)
For linha = LINHA_DADOS To NLinhas
    If LinhaEntidadeInativosConsideravel(wsEntInativas, linha) Then
        chave = EntidadeInativos_ChaveDedupeLinha(wsEntInativas, linha)
        If Not vistos.Exists(chave) Then
            totalChaves = totalChaves + 1
            chaves(totalChaves) = chave
        End If
        vistos(chave) = linha
    End If
Next linha

total = totalChaves
If total = 0 Then Exit Sub

ReDim arrayitems(1 To total, 1 To 22)
For i = 1 To totalChaves
    linhaUsada = CLng(vistos(CStr(chaves(i))))
    For Coluna = 1 To 22
        arrayitems(i, Coluna) = SafeListVal(wsEntInativas.Cells(linhaUsada, Coluna).Value)
    Next Coluna
Next i

lst.List = arrayitems()
arrayitems = Empty

Exit Sub
erro_carregamento:
End Sub
' Alias para compatibilidade: formul?rio e vers?es antigas chamam PreenchimentoEscolhaAtividade (V5)
Public Sub PreenchimentoEscolhaAtividade()
    Call PreenchimentoServico
End Sub
Sub PreenchimentoServico(Optional ByVal filtro As String = "")
On Error GoTo erro_carregamento
Dim wsServ As Worksheet
Dim cnaeAtual As String
Dim textoBusca As String
Dim idx As Long
Dim col As Long
Dim total As Long
Dim itens() As Variant
Dim lst As Object
Dim filtroU As String

filtroU = UCase$(Trim$(filtro))
Cont = 1
NItem = 0
Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
Set lst = ControleFormulario("Menu_Principal", "A_Lista")
If lst Is Nothing Then Exit Sub

With lst
    .Clear
    .RowSource = vbNullString
    .ColumnCount = 9
    .ColumnWidths = "0; 0; 380; 250; 0; 0; 0; 0; 0"
End With

NLinhas = UltimaLinhaAba(SHEET_CAD_SERV)
If NLinhas < LINHA_DADOS Then Exit Sub

For linha = LINHA_DADOS To NLinhas
    If LinhaServicoValida(wsServ, linha) Then
        cnaeAtual = SafeListVal(BuscarCnaeAtividade(wsServ.Cells(linha, COL_SERV_ATIV_ID).Value))
        textoBusca = SafeListVal(wsServ.Cells(linha, COL_SERV_ID).Value) & " " & _
                    SafeListVal(wsServ.Cells(linha, COL_SERV_ATIV_ID).Value) & " " & _
                    cnaeAtual & " " & _
                    SafeListVal(wsServ.Cells(linha, COL_SERV_ATIV_DESC).Value) & " " & _
                    SafeListVal(wsServ.Cells(linha, COL_SERV_DESCRICAO).Value)
        If UtilFiltro_LinhaAtende(textoBusca, filtroU) Then
            total = total + 1
        End If
    End If
Next linha

If total = 0 Then Exit Sub

ReDim itens(1 To total, 1 To 9)
idx = 1
For linha = LINHA_DADOS To NLinhas
    If LinhaServicoValida(wsServ, linha) Then
        cnaeAtual = SafeListVal(BuscarCnaeAtividade(wsServ.Cells(linha, COL_SERV_ATIV_ID).Value))
        textoBusca = SafeListVal(wsServ.Cells(linha, COL_SERV_ID).Value) & " " & _
                    SafeListVal(wsServ.Cells(linha, COL_SERV_ATIV_ID).Value) & " " & _
                    cnaeAtual & " " & _
                    SafeListVal(wsServ.Cells(linha, COL_SERV_ATIV_DESC).Value) & " " & _
                    SafeListVal(wsServ.Cells(linha, COL_SERV_DESCRICAO).Value)
        If UtilFiltro_LinhaAtende(textoBusca, filtroU) Then
            For col = 1 To 9
                itens(idx, col) = SafeListVal(wsServ.Cells(linha, col).Value)
            Next col
            idx = idx + 1
        End If
    End If
Next linha

lst.List = itens

Exit Sub
erro_carregamento:
End Sub
Sub PreenchimentoCRServico(Optional ByVal frmJaAberto As Object = Nothing, Optional ByVal filtro As String = "")
On Error GoTo erro_carregamento
' V12: aceita referencia direta ao formulario (evita busca dupla via FormularioAberto).
' Chamadores que ja criaram o formulario devem passar frmJaAberto.
' filtro: texto livre sobre atividade e descricao do servico (mesma logica de PreenchimentoServico).
Dim wsServ As Worksheet
Dim frmCred As Object
Dim total As Long
Dim totalValidos As Long
Dim filtroU As String

filtroU = UCase$(Trim$(filtro))
Cont = 1
NItem = 0
Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)

If frmJaAberto Is Nothing Then
    Set frmCred = FormularioAberto("Credencia_Empresa", False)
Else
    Set frmCred = frmJaAberto
End If
If frmCred Is Nothing Then Exit Sub

CallByName frmCred, "PrepararListaCredenciamentoServico", VbMethod

NLinhas = UltimaLinhaAba(SHEET_CAD_SERV)
If NLinhas < LINHA_DADOS Then
    MsgBox "Nenhum servi" & ChrW(231) & "o cadastrado em CAD_SERV." & vbCrLf & _
           "Cadastre servi" & ChrW(231) & "os antes de credenciar.", _
           vbExclamation, "Credenciamento"
    Exit Sub
End If

For linha = LINHA_DADOS To NLinhas
    If LinhaServicoValida(wsServ, linha) Then totalValidos = totalValidos + 1
Next linha

If totalValidos = 0 Then
    MsgBox "Nenhum servi" & ChrW(231) & "o cadastrado em CAD_SERV." & vbCrLf & _
           "Cadastre servi" & ChrW(231) & "os antes de credenciar.", _
           vbExclamation, "Credenciamento"
    Exit Sub
End If

For linha = LINHA_DADOS To NLinhas
    If LinhaServicoValida(wsServ, linha) Then
        If LinhaServicoPassaFiltroCred(wsServ, linha, filtroU) Then total = total + 1
    End If
Next linha

If total = 0 Then
    If filtroU <> "" Then
        CallByName frmCred, "PrepararListaCredenciamentoServico", VbMethod
        Exit Sub
    End If
    MsgBox "Nenhum servi" & ChrW(231) & "o cadastrado em CAD_SERV." & vbCrLf & _
           "Cadastre servi" & ChrW(231) & "os antes de credenciar.", _
           vbExclamation, "Credenciamento"
    Exit Sub
End If

' ListBox.List espera array 2D 0-based (evita "Tipos incompatíveis").
Dim arrayitems As Variant
Dim idx0 As Long
ReDim arrayitems(0 To total - 1, 0 To 8)
idx0 = 0
For linha = LINHA_DADOS To NLinhas
    If LinhaServicoValida(wsServ, linha) Then
        If LinhaServicoPassaFiltroCred(wsServ, linha, filtroU) Then
            For Coluna = 1 To 9
                arrayitems(idx0, Coluna - 1) = SafeListVal(wsServ.Cells(linha, Coluna).Value)
            Next Coluna
            idx0 = idx0 + 1
        End If
    End If
Next linha

CallByName frmCred, "DefinirListaCredenciamentoServico", VbMethod, arrayitems
arrayitems = Empty

Exit Sub
erro_carregamento:
    MsgBox "Erro ao carregar servi" & ChrW(231) & "os: " & Err.Description, vbCritical, "Credenciamento"
End Sub

Sub PreenchimentoEmpresa(Optional ByVal filtro As String = "")
On Error GoTo erro_carregamento
Dim wsEmp As Worksheet
Dim idx As Long
Dim total As Long
Dim primeiraLinhaEmp As Long
Dim lst As Object
Dim filtroU As String

filtroU = UCase$(Trim$(filtro))
Cont = 1
NItem = 0
Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)
Set lst = ControleFormulario("Menu_Principal", "EMP_Lista")
If lst Is Nothing Then Exit Sub

With lst
    .Clear
    .RowSource = vbNullString
    .ColumnCount = 19
    .ColumnWidths = EmpresaLista_MontarColumnWidths(CDbl(.Width))
End With

primeiraLinhaEmp = PrimeiraLinhaDadosEmpresas()
NLinhas = UltimaLinhaAba(SHEET_EMPRESAS)
If NLinhas < primeiraLinhaEmp Then Exit Sub

For linha = primeiraLinhaEmp To NLinhas
    If LinhaEmpresaValida(wsEmp, linha) Then
        If EmpresaLinhaPassaFiltro(wsEmp, linha, filtroU) Then total = total + 1
    End If
Next linha

If total = 0 Then Exit Sub

ReDim arrayitems(1 To total, 1 To 19)
idx = 1
For linha = primeiraLinhaEmp To NLinhas
    If LinhaEmpresaValida(wsEmp, linha) Then
        If EmpresaLinhaPassaFiltro(wsEmp, linha, filtroU) Then
            For Coluna = 1 To 19
                arrayitems(idx, Coluna) = SafeListVal(wsEmp.Cells(linha, Coluna).Value)
            Next Coluna
            idx = idx + 1
        End If
    End If
Next linha

lst.List = arrayitems()
arrayitems = Empty

Exit Sub
erro_carregamento:
End Sub
Sub PreenchimentoEmpresa_Inativo()
On Error GoTo erro_carregamento
Dim lst As Object
Dim wsEmpInativas As Worksheet
Dim total As Long
Dim vistos As Object
Dim chave As String
Dim chaves() As String
Dim totalChaves As Long
Dim i As Long
Dim linhaUsada As Long
Dim linha As Long

Cont = 1
NItem = 0
Set wsEmpInativas = ThisWorkbook.Sheets(SHEET_EMPRESAS_INATIVAS)
NLinhas = UltimaLinhaAba(SHEET_EMPRESAS_INATIVAS)
Set lst = ControleFormulario("Reativa_Empresa", "RM_Lista")
If lst Is Nothing Then Exit Sub

With lst
    .Clear
    .ColumnCount = 19
    .ColumnWidths = EmpresaLista_MontarColumnWidths(CDbl(.Width))
End With

If NLinhas < LINHA_DADOS Then Exit Sub

Set vistos = CreateObject("Scripting.Dictionary")
totalChaves = 0
ReDim chaves(1 To NLinhas - LINHA_DADOS + 1)
For linha = LINHA_DADOS To NLinhas
    If LinhaEmpresaInativosConsideravel(wsEmpInativas, linha) Then
        chave = EmpresaInativos_ChaveDedupeLinha(wsEmpInativas, linha)
        If Not vistos.Exists(chave) Then
            totalChaves = totalChaves + 1
            chaves(totalChaves) = chave
        End If
        vistos(chave) = linha
    End If
Next linha

total = totalChaves
If total = 0 Then Exit Sub

ReDim arrayitems(1 To total, 1 To 19)
For i = 1 To totalChaves
    linhaUsada = CLng(vistos(CStr(chaves(i))))
    For Coluna = 1 To 19
        arrayitems(i, Coluna) = SafeListVal(wsEmpInativas.Cells(linhaUsada, Coluna).Value)
    Next Coluna
Next i

lst.List = arrayitems()
arrayitems = Empty

Exit Sub
erro_carregamento:
End Sub

Sub LogoPrefeitura()
    Dim frmCfg As Object
    Dim picLogo As StdPicture

On Error GoTo carregamento:
    Set frmCfg = FormularioAberto("Configuracao_Inicial", False)
    If frmCfg Is Nothing Then Exit Sub
    Set picLogo = LoadPicture(CAM_LOGO)
    CallByName frmCfg, "Picture", VbLet, picLogo
    CallByName frmCfg, "PictureSizeMode", VbLet, fmPictureSizeModeZoom
Exit Sub
carregamento:
End Sub

Sub PreencherPreencheOS()
    ' Refatorado: sem Select/ActiveCell, uso de Range.Find seguro e filtro claro de Pré-OS pendentes.
    Dim Linhalistbox As Integer
    Dim linha As Long
    Dim NLinhas As Long
    Dim wsPreOS As Worksheet
    Dim wsEntidade As Worksheet
    Dim wsCadServ As Worksheet
    Dim wsEmp As Worksheet
    Dim rngResult As Range
    Dim lst As Object

    Set wsPreOS = ThisWorkbook.Sheets(SHEET_PREOS)
    Set wsEntidade = ThisWorkbook.Sheets(SHEET_ENTIDADE)
    Set wsCadServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    Set lst = ControleFormulario("Menu_Principal", "OS_Lista")
    If lst Is Nothing Then Exit Sub

    Linhalistbox = 0
    NLinhas = wsPreOS.Range("A1048576").End(xlUp).row

    lst.Clear
    With lst
        .RowSource = vbNullString
        .ColumnCount = 13
        .ColumnWidths = "25; 200; 200; 200; 100; 0; 0; 0; 0; 0; 0; 0; 0"
    End With

    With wsPreOS
        For linha = LINHA_DADOS To NLinhas
            If Trim(CStr(.Cells(linha, COL_PREOS_ID).Value)) <> "" And _
               Trim$(UCase$(CStr(.Cells(linha, COL_PREOS_STATUS).Value))) = STATUS_PREOS_AGUARDANDO_ACEITE Then

                lst.AddItem

                SafeSetList lst, Linhalistbox, 0, .Cells(linha, 1).Value
                SafeSetList lst, Linhalistbox, 10, .Cells(linha, 3).Value
                SafeSetList lst, Linhalistbox, 11, .Cells(linha, 9).Value
                SafeSetList lst, Linhalistbox, 12, .Cells(linha, 10).Value

                Dim linhaEnt As Long
                linhaEnt = BuscarLinhaPorId(wsEntidade, LINHA_DADOS, UltimaLinhaAba(SHEET_ENTIDADE), COL_ENT_ID, SafeListVal(.Cells(linha, COL_PREOS_ENT_ID).Value))
                If linhaEnt > 0 Then
                    SafeSetList lst, Linhalistbox, 1, wsEntidade.Cells(linhaEnt, COL_ENT_NOME).Value
                    SafeSetList lst, Linhalistbox, 6, wsEntidade.Cells(linhaEnt, COL_ENT_ID).Value
                End If

                Dim codServ As String
                Dim ativIDBusca As String
                Dim servIDBusca As String
                Dim jServ As Long

                codServ = SafeListVal(.Cells(linha, COL_PREOS_COD_SERV).Value)
                ativIDBusca = SafeListVal(.Cells(linha, COL_PREOS_ATIV_ID).Value)
                servIDBusca = ExtrairServId(codServ, ativIDBusca)
                Set rngResult = Nothing

                If servIDBusca <> "" Then
                    For jServ = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_SERV)
                        If IdsIguais(SafeListVal(wsCadServ.Cells(jServ, COL_SERV_ID).Value), servIDBusca) And _
                           IdsIguais(SafeListVal(wsCadServ.Cells(jServ, COL_SERV_ATIV_ID).Value), ativIDBusca) Then
                            Set rngResult = wsCadServ.Cells(jServ, COL_SERV_ID)
                            Exit For
                        End If
                    Next jServ
                End If
                If Not rngResult Is Nothing Then
                    SafeSetList lst, Linhalistbox, 5, rngResult.Offset(0, 2).Value
                    SafeSetList lst, Linhalistbox, 2, rngResult.Offset(0, 3).Value
                    SafeSetList lst, Linhalistbox, 8, rngResult.Value
                End If

                Dim linhaEmp As Long
                linhaEmp = BuscarLinhaPorId(wsEmp, PrimeiraLinhaDadosEmpresas(), UltimaLinhaAba(SHEET_EMPRESAS), COL_EMP_ID, SafeListVal(.Cells(linha, COL_PREOS_EMP_ID).Value))
                If linhaEmp > 0 Then
                    SafeSetList lst, Linhalistbox, 3, wsEmp.Cells(linhaEmp, COL_EMP_RAZAO).Value
                    SafeSetList lst, Linhalistbox, 4, wsEmp.Cells(linhaEmp, COL_EMP_TEL_CEL).Value
                    SafeSetList lst, Linhalistbox, 7, wsEmp.Cells(linhaEmp, COL_EMP_CNPJ).Value
                    SafeSetList lst, Linhalistbox, 9, wsEmp.Cells(linhaEmp, COL_EMP_ID).Value
                End If

                Linhalistbox = Linhalistbox + 1
            End If
        Next linha
    End With
End Sub
Sub PreencherOS()
' V12: eliminado Sheets.Select + Range.Select + ActiveCell (proibidos; chamado de formulario modal).
' Usa referencia direta via ws.Range("X").Value.
On Error GoTo falha
Dim ws As Worksheet
Dim estavaProtegida As Boolean
Dim senhaProtecao As String
Set ws = ThisWorkbook.Sheets("EMITE_OS")

' Escrita no template pode falhar se a aba estiver protegida.
If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
    Err.Raise 1004, "PreencherOS", "A aba EMITE_OS esta protegida e nao foi possivel liberar para preenchimento."
End If
' Municipio e gestor sempre lidos da CONFIG para evitar dado defasado em memoria
Call CarregarCabecalhoConfig
ws.Range("D2").Value = MontarCabecalhoMunicipio(municipio)
ws.Range("D3").Value = Gestor_Empresa
ws.Range("L3").Value = N_OS
ws.Range("L9").Value = Desc_entidade & " - " & cont_entidade & " - " & telcont_entidade
ws.Range("N5").Value = Format(CDate(Now), "DD/MM/YYYY")
ws.Range("C9").Value = M_NomeEmpresa
ws.Range("C11").Value = Empresa_endereco
ws.Range("C13").Value = Empresa_TelCel
ws.Range("C15").Value = Empresa_email
ws.Range("G13").Value = Empresa_CNPJ
ws.Range("B18").Value = Desc_Ativi
ws.Range("F18").Value = END_ENTIDADE
ws.Range("L18").Value = Desc_Serv
ws.Range("B23").Value = Desc_Serv
ws.Range("L23").Value = Util_Conversao.ToDouble(QT_ESTIMADA)
Call AplicarFormatoQuantidade(ws.Range("L23"))
ws.Range("M23").Value = Util_Conversao.ToDouble(CStr(Vl_estimado))
Call AplicarFormatoMoedaBR(ws.Range("M23"))
ws.Range("M31").Value = Util_Conversao.ToDouble(CStr(Vl_estimado))
Call AplicarFormatoMoedaBR(ws.Range("M31"))
ws.Range("B55").Value = Desc_Serv
ws.Range("L55").Value = Util_Conversao.ToDouble(QT_ESTIMADA)
Call AplicarFormatoQuantidade(ws.Range("L55"))
ws.Range("M55").Value = Util_Conversao.ToDouble(CStr(Vl_estimado))
Call AplicarFormatoMoedaBR(ws.Range("M55"))
ws.Range("D84").Value = NR_Empenho
Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
Err.Clear
Exit Sub
falha:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    Err.Raise Err.Number, "PreencherOS", Err.Description
End Sub
Sub PreencherAvaliaOS()
' V12: eliminado Sheets.Select + Range.Select + ActiveCell (proibidos; chamado de formulario modal).
' Usa referencia direta via ws.Range("X").Value. Identico ao PreencherOS (avaliacao usa mesmo template).
On Error GoTo falha
Dim ws As Worksheet
Dim estavaProtegida As Boolean
Dim senhaProtecao As String
Set ws = ThisWorkbook.Sheets("EMITE_OS")

' Escrita no template pode falhar se a aba estiver protegida.
If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
    Err.Raise 1004, "PreencherAvaliaOS", "A aba EMITE_OS esta protegida e nao foi possivel liberar para preenchimento."
End If
Call CarregarCabecalhoConfig
ws.Range("D2").Value = MontarCabecalhoMunicipio(municipio)
ws.Range("D3").Value = Gestor_Empresa
ws.Range("L3").Value = N_OS
ws.Range("L9").Value = Desc_entidade & " - " & cont_entidade & " - " & telcont_entidade
ws.Range("N5").Value = Format(CDate(Now), "DD/MM/YYYY")
ws.Range("C9").Value = M_NomeEmpresa
ws.Range("C11").Value = Empresa_endereco
ws.Range("C13").Value = Empresa_TelCel
ws.Range("C15").Value = Empresa_email
ws.Range("G13").Value = Empresa_CNPJ
ws.Range("B18").Value = Desc_Ativi
ws.Range("F18").Value = END_ENTIDADE
ws.Range("L18").Value = Desc_Serv
ws.Range("B23").Value = Desc_Serv
ws.Range("L23").Value = Util_Conversao.ToDouble(QT_ESTIMADA)
Call AplicarFormatoQuantidade(ws.Range("L23"))
ws.Range("M23").Value = Util_Conversao.ToDouble(CStr(Vl_estimado))
Call AplicarFormatoMoedaBR(ws.Range("M23"))
ws.Range("M31").Value = Util_Conversao.ToDouble(CStr(Vl_estimado))
Call AplicarFormatoMoedaBR(ws.Range("M31"))
ws.Range("B55").Value = Desc_Serv
ws.Range("L55").Value = Util_Conversao.ToDouble(QT_ESTIMADA)
Call AplicarFormatoQuantidade(ws.Range("L55"))
ws.Range("M55").Value = Util_Conversao.ToDouble(CStr(Vl_estimado))
Call AplicarFormatoMoedaBR(ws.Range("M55"))
ws.Range("D84").Value = NR_Empenho
Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
Err.Clear
Exit Sub
falha:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    Err.Raise Err.Number, "PreencherAvaliaOS", Err.Description
End Sub
Sub PreencherPREOS()
' V12: eliminado Sheets.Select + Range.Select + ActiveCell (proibidos; chamado de formulario modal).
' Usa referencia direta via ws.Range("X").Value.
On Error GoTo falha
Dim ws As Worksheet
Dim estavaProtegida As Boolean
Dim senhaProtecao As String
Set ws = ThisWorkbook.Sheets("EMITE_PREOS")

' Escrita no template pode falhar se a aba estiver protegida.
If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
    Err.Raise 1004, "PreencherPREOS", "A aba EMITE_PREOS esta protegida e nao foi possivel liberar para preenchimento."
End If
Call CarregarCabecalhoConfig
Call GarantirDadosPreOSParaImpressao(N_OS)
ws.Range("D2").Value = MontarCabecalhoMunicipio(municipio)
ws.Range("D3").Value = Gestor_Empresa
ws.Range("L3").Value = N_OS
ws.Range("L9").Value = Desc_entidade & " - " & cont_entidade & " - " & telcont_entidade
ws.Range("N5").Value = Format(CDate(Now), "DD/MM/YYYY")
ws.Range("C9").Value = M_NomeEmpresa
ws.Range("C11").Value = Empresa_endereco
ws.Range("C13").Value = Empresa_TelCel
ws.Range("C15").Value = Empresa_email
ws.Range("G13").Value = Empresa_CNPJ
ws.Range("B18").Value = Desc_Ativi
ws.Range("F18").Value = END_ENTIDADE
ws.Range("L18").Value = Desc_Serv
ws.Range("B23").Value = Desc_Serv
ws.Range("L23").Value = Util_Conversao.ToDouble(QT_ESTIMADA)
Call AplicarFormatoQuantidade(ws.Range("L23"))
ws.Range("M23").Value = Util_Conversao.ToDouble(CStr(Vl_estimado))
Call AplicarFormatoMoedaBR(ws.Range("M23"))
ws.Range("M31").Value = Util_Conversao.ToDouble(CStr(Vl_estimado))
Call AplicarFormatoMoedaBR(ws.Range("M31"))

Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
Err.Clear
Exit Sub
falha:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    Err.Raise Err.Number, "PreencherPREOS", Err.Description
End Sub
Sub Imprimir_PREOS()
' V12: eliminado Sheets.Select + Range.Select + ActiveWindow.SelectedSheets.PrintOut
' Usa ws.PageSetup e ws.PrintOut diretamente (sem necessidade de ativar/selecionar).
On Error GoTo ErroPrint
Dim ws As Worksheet
Dim estavaProtegida As Boolean
Dim senhaProtecao As String
Set ws = ThisWorkbook.Sheets("EMITE_PREOS")

' PageSetup/PrintOut podem falhar se a aba estiver protegida.
If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
    Err.Raise 1004, "Imprimir_PREOS", "A aba EMITE_PREOS está protegida e não foi possível liberar para impressão."
End If
With ws.PageSetup
'        .LeftHeader = ""
'        .CenterHeader = ""
'        .RightHeader = ""
'        .LeftFooter = ""
'        .CenterFooter = ""
'        .RightFooter = ""
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .Orientation = xlPortrait
        .LeftMargin = Application.CentimetersToPoints(0.5)
        .RightMargin = Application.CentimetersToPoints(0.5)
        .TopMargin = Application.CentimetersToPoints(0.5)
        .BottomMargin = Application.CentimetersToPoints(1)
        .HeaderMargin = Application.CentimetersToPoints(0.5)
        .FooterMargin = Application.CentimetersToPoints(0.5)
        .PrintHeadings = False
        .PrintGridlines = False
        .PrintComments = xlPrintNoComments
        .PrintQuality = 600
        .CenterHorizontally = False
        .CenterVertically = False
        .Orientation = xlPortrait
        .Draft = False
        .PaperSize = xlPaperA4
        .FirstPageNumber = xlAutomatic
        .Order = xlDownThenOver
        .BlackAndWhite = False
        .Zoom = False
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .PrintErrors = xlPrintErrorsDisplayed
        .OddAndEvenPagesHeaderFooter = False
        .DifferentFirstPageHeaderFooter = False
        .ScaleWithDocHeaderFooter = True
        .AlignMarginsHeaderFooter = True
'        .EvenPage.LeftHeader.Text = ""
'        .EvenPage.CenterHeader.Text = ""
'        .EvenPage.RightHeader.Text = ""
'        .EvenPage.LeftFooter.Text = ""
'        .EvenPage.CenterFooter.Text = ""
'        .EvenPage.RightFooter.Text = ""
'        .FirstPage.LeftHeader.Text = ""
'        .FirstPage.CenterHeader.Text = ""
'        .FirstPage.RightHeader.Text = ""
'        .FirstPage.LeftFooter.Text = ""
'        .FirstPage.CenterFooter.Text = ""
'        .FirstPage.RightFooter.Text = ""
'
'        copias = InputBox("Quantas c?pias?", "C?pias a serem Impressas")
        ws.PrintOut
End With

Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
Err.Clear
Exit Sub
ErroPrint:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    MsgBox "Não foi possível imprimir a Pre-OS." & vbCrLf & _
           "Verifique se há uma impressora configurada como padrão no Windows." & vbCrLf & _
           "Erro: " & CStr(Err.Number) & " - " & Err.Description, _
           vbExclamation, "Impressão"
    Err.Clear

End Sub
Sub ImprimirOS()
' V12: eliminado Sheets.Select + Range.Select + ActiveWindow.SelectedSheets.PrintOut
' Usa ws.PageSetup e ws.PrintOut diretamente.
On Error GoTo ErroPrint
Dim ws As Worksheet
Dim estavaProtegida As Boolean
Dim senhaProtecao As String
Set ws = ThisWorkbook.Sheets("EMITE_OS")

' PageSetup/PrintOut podem falhar se a aba estiver protegida.
If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
    Err.Raise 1004, "ImprimirOS", "A aba EMITE_OS está protegida e não foi possível liberar para impressão."
End If
With ws.PageSetup
'        .LeftHeader = ""
'        .CenterHeader = ""
'        .RightHeader = ""
'        .LeftFooter = ""
'        .CenterFooter = ""
'        .RightFooter = ""
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .Orientation = xlPortrait
        .LeftMargin = Application.CentimetersToPoints(0.5)
        .RightMargin = Application.CentimetersToPoints(0.5)
        .TopMargin = Application.CentimetersToPoints(0.5)
        .BottomMargin = Application.CentimetersToPoints(1)
        .HeaderMargin = Application.CentimetersToPoints(0.5)
        .FooterMargin = Application.CentimetersToPoints(0.5)
        .PrintHeadings = False
        .PrintGridlines = False
        .PrintComments = xlPrintNoComments
        .PrintQuality = 600
        .CenterHorizontally = False
        .CenterVertically = False
        .Orientation = xlPortrait
        .Draft = False
        .PaperSize = xlPaperA4
        .FirstPageNumber = xlAutomatic
        .Order = xlDownThenOver
        .BlackAndWhite = False
        .Zoom = False
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .PrintErrors = xlPrintErrorsDisplayed
        .OddAndEvenPagesHeaderFooter = False
        .DifferentFirstPageHeaderFooter = False
        .ScaleWithDocHeaderFooter = True
        .AlignMarginsHeaderFooter = True
'        .EvenPage.LeftHeader.Text = ""
'        .EvenPage.CenterHeader.Text = ""
'        .EvenPage.RightHeader.Text = ""
'        .EvenPage.LeftFooter.Text = ""
'        .EvenPage.CenterFooter.Text = ""
'        .EvenPage.RightFooter.Text = ""
'        .FirstPage.LeftHeader.Text = ""
'        .FirstPage.CenterHeader.Text = ""
'        .FirstPage.RightHeader.Text = ""
'        .FirstPage.LeftFooter.Text = ""
'        .FirstPage.CenterFooter.Text = ""
'        .FirstPage.RightFooter.Text = ""
'
'        copias = InputBox("Quantas c?pias?", "C?pias a serem Impressas")
        ws.PrintOut
End With

Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
Err.Clear
Exit Sub
ErroPrint:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    MsgBox "Não foi possível imprimir a OS." & vbCrLf & _
           "Verifique se há uma impressora configurada como padrão no Windows." & vbCrLf & _
           "Erro: " & CStr(Err.Number) & " - " & Err.Description, _
           vbExclamation, "Impressão"
    Err.Clear
End Sub
Sub LimparOS()
' V12: eliminado Sheets.Select + Range.Select + ActiveCell (proibidos; chamado de formulario modal).
' Usa referencia direta via ws.Range("X").Value.
Dim ws As Worksheet
Set ws = ThisWorkbook.Sheets("EMITE_OS")

ws.Range("D2").Value = ""
ws.Range("D3").Value = ""
ws.Range("L3").Value = ""
ws.Range("L9").Value = ""
ws.Range("N5").Value = ""
ws.Range("C9").Value = ""
ws.Range("C11").Value = ""
ws.Range("C13").Value = ""
ws.Range("C15").Value = ""
ws.Range("G13").Value = ""
ws.Range("B18").Value = ""
ws.Range("F18").Value = ""
ws.Range("L18").Value = ""
ws.Range("B23").Value = ""
If Not ws.Range("L23").HasFormula Then ws.Range("L23").Value = 0
If Not ws.Range("M23").HasFormula Then ws.Range("M23").Value = 0
If Not ws.Range("M31").HasFormula Then ws.Range("M31").Value = 0
ws.Range("B55").Value = ""
If Not ws.Range("L55").HasFormula Then ws.Range("L55").Value = 0
If Not ws.Range("M55").HasFormula Then ws.Range("M55").Value = 0
If Not ws.Range("N63").HasFormula Then ws.Range("N63").Value = 0
If Not ws.Range("D84").HasFormula Then ws.Range("D84").Value = 0

End Sub
Sub LimparPREOS()
' V12: eliminado Sheets.Select + Range.Select + ActiveCell (proibidos; chamado de formulario modal).
' Usa referencia direta via ws.Range("X").Value.
Dim ws As Worksheet
Set ws = ThisWorkbook.Sheets("EMITE_PREOS")

ws.Range("D2").Value = ""
ws.Range("D3").Value = ""
ws.Range("L3").Value = ""
ws.Range("L9").Value = ""
ws.Range("N5").Value = ""
ws.Range("C9").Value = ""
ws.Range("C11").Value = ""
ws.Range("C13").Value = ""
ws.Range("C15").Value = ""
ws.Range("G13").Value = ""
ws.Range("B18").Value = ""
ws.Range("F18").Value = ""
ws.Range("L18").Value = ""
ws.Range("B23").Value = ""
If Not ws.Range("L23").HasFormula Then ws.Range("L23").Value = 0
If Not ws.Range("M23").HasFormula Then ws.Range("M23").Value = 0
If Not ws.Range("M31").HasFormula Then ws.Range("M31").Value = 0

End Sub
Sub PreencherAvaliarOS()
    On Error GoTo erro_carregamento

    Dim wsOS     As Worksheet
    Dim wsEmp    As Worksheet
    Dim wsServ   As Worksheet
    Dim i        As Long
    Dim lb       As Long
    Dim lst      As Object

    Set wsOS = ThisWorkbook.Sheets(SHEET_CAD_OS)
    Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    Set lst = ControleFormulario("Menu_Principal", "AV_Lista")
    If lst Is Nothing Then Exit Sub

    lb = 0
    lst.Clear
    With lst
        .ColumnCount = 10
        .ColumnWidths = "25; 180; 180; 180; 60; 50; 60; 0; 0; 0"
    End With

    Dim nOS As Long
    nOS = UltimaLinhaAba(SHEET_CAD_OS)

    For i = LINHA_DADOS To nOS
        If Trim$(UCase$(SafeListVal(wsOS.Cells(i, COL_OS_STATUS).Value))) = STATUS_OS_EM_EXECUCAO Then
            lst.AddItem
            lst.List(lb, 0) = SafeListVal(wsOS.Cells(i, COL_OS_ID).Value)

            Dim entId As String
            entId = SafeListVal(wsOS.Cells(i, COL_OS_ENT_ID).Value)
            Dim j As Long
            For j = LINHA_DADOS To UltimaLinhaAba(SHEET_ENTIDADE)
                If IdsIguais(SafeListVal(ThisWorkbook.Sheets(SHEET_ENTIDADE).Cells(j, COL_ENT_ID).Value), entId) Then
                    lst.List(lb, 1) = SafeListVal(ThisWorkbook.Sheets(SHEET_ENTIDADE).Cells(j, COL_ENT_NOME).Value)
                    Exit For
                End If
            Next j

            Dim codServ As String
            codServ = CStr(wsOS.Cells(i, COL_OS_COD_SERV).Value)
            Dim ativId As String
            ativId = SafeListVal(wsOS.Cells(i, COL_OS_ATIV_ID).Value)
            Dim servId As String
            servId = ExtrairServId(codServ, ativId)
            For j = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_SERV)
                If IdsIguais(SafeListVal(wsServ.Cells(j, COL_SERV_ID).Value), servId) And _
                   IdsIguais(SafeListVal(wsServ.Cells(j, COL_SERV_ATIV_ID).Value), ativId) Then
                    lst.List(lb, 2) = SafeListVal(wsServ.Cells(j, COL_SERV_DESCRICAO).Value)
                    lst.List(lb, 7) = SafeListVal(wsServ.Cells(j, COL_SERV_ID).Value)
                    Exit For
                End If
            Next j

            Dim empId As String
            empId = SafeListVal(wsOS.Cells(i, COL_OS_EMP_ID).Value)
            For j = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
                If IdsIguais(SafeListVal(wsEmp.Cells(j, COL_EMP_ID).Value), empId) Then
                    lst.List(lb, 3) = SafeListVal(wsEmp.Cells(j, COL_EMP_RAZAO).Value)
                    lst.List(lb, 8) = SafeListVal(wsEmp.Cells(j, COL_EMP_CNPJ).Value)
                    Exit For
                End If
            Next j

            lst.List(lb, 4) = SafeListVal(wsOS.Cells(i, COL_OS_DT_EMISSAO).Value)
            lst.List(lb, 5) = SafeListVal(wsOS.Cells(i, COL_OS_QT_EST).Value)
            lst.List(lb, 6) = SafeListVal(wsOS.Cells(i, COL_OS_VL_TOTAL).Value)
            lst.List(lb, 9) = SafeListVal(wsOS.Cells(i, COL_OS_EMP_ID).Value)

            lb = lb + 1
        End If
    Next i

    Exit Sub
erro_carregamento:
End Sub

Sub PreenchimentoRelatorioOSEmpresa()
On Error GoTo erro_carregamento
Dim primeiraLinhaEmp As Long
Dim lst As Object
Dim wsEmp As Worksheet
Dim total As Long
Dim idx As Long

Cont = 1
NItem = 0
Set lst = ControleFormulario("Rel_OSEmpresa", "RO_Lista", True)
If lst Is Nothing Then Exit Sub
Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)
primeiraLinhaEmp = PrimeiraLinhaDadosEmpresas()
NLinhas = UltimaLinhaAba(SHEET_EMPRESAS)

With lst
    .Clear
    .ColumnCount = 19
    .ColumnWidths = "0; 0; 210; 0; 200; 0; 0; 0; 0; 0; 0; 0; 70; 0; 0; 0; 0; 0; 0"
End With

If NLinhas < primeiraLinhaEmp Then Exit Sub

For linha = primeiraLinhaEmp To NLinhas
    If LinhaEmpresaValida(wsEmp, linha) Then total = total + 1
Next linha

If total = 0 Then Exit Sub

ReDim arrayitems(1 To total, 1 To 19)
idx = 1
For linha = primeiraLinhaEmp To NLinhas
    If LinhaEmpresaValida(wsEmp, linha) Then
        For Coluna = 1 To 19
            arrayitems(idx, Coluna) = SafeListVal(wsEmp.Cells(linha, Coluna).Value)
        Next Coluna
        idx = idx + 1
    End If
Next linha

lst.List = arrayitems()
arrayitems = Empty

Exit Sub
erro_carregamento:
End Sub

Sub PreenchimentoRel_EmpXServ()

On Error GoTo erro_carregamento
Dim lst As Object
Dim wsServ As Worksheet
Dim total As Long
Dim idx As Long

Cont = 1
NItem = 0
Set lst = ControleFormulario("Rel_Emp_Serv", "SV_CR_Lista")
If lst Is Nothing Then Exit Sub
Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
NLinhas = UltimaLinhaAba(SHEET_CAD_SERV)

With lst
    .Clear
    .ColumnCount = 9
    .ColumnWidths = "0; 0; 350; 350; 0; 0; 0; 0; 0"
End With

If NLinhas < LINHA_DADOS Then Exit Sub

For linha = LINHA_DADOS To NLinhas
    If LinhaServicoValida(wsServ, linha) Then total = total + 1
Next linha

If total = 0 Then Exit Sub

ReDim arrayitems(1 To total, 1 To 9)
idx = 1
For linha = LINHA_DADOS To NLinhas
    If LinhaServicoValida(wsServ, linha) Then
        For Coluna = 1 To 9
            arrayitems(idx, Coluna) = SafeListVal(wsServ.Cells(linha, Coluna).Value)
        Next Coluna
        idx = idx + 1
    End If
Next linha

lst.List = arrayitems()
arrayitems = Empty

Exit Sub
erro_carregamento:
End Sub

Public Sub GarantirAtividadesBase()
On Error GoTo erro_carregamento
Dim qtd As Long

qtd = CargaInicialCNAE_SeNecessario(False)
If UltimaLinhaAba(SHEET_ATIVIDADES) >= LINHA_DADOS Then Exit Sub

MsgBox "A aba ATIVIDADES está vazia e a base can" & ChrW(244) & "nica de CNAE n" & ChrW(227) & "o foi localizada." & vbCrLf & _
       "Para estabilizar o sistema e a bateria oficial, carregue a base estrutural can" & ChrW(244) & "nica antes de continuar.", _
       vbExclamation, "Base CNAE obrigatória"

Exit Sub
erro_carregamento:
End Sub

Private Sub SafeSetList(ByRef lb As Object, ByVal row As Long, ByVal col As Long, ByVal valor As Variant)
    On Error Resume Next
    If row >= 0 And col >= 0 Then
        If row < lb.ListCount And col < lb.ColumnCount Then
            lb.List(row, col) = SafeListVal(valor)
        End If
    End If
    On Error GoTo 0
End Sub

Private Function MontarCabecalhoMunicipio(ByVal municipio As String) As String
    Dim m As String
    m = Trim$(CStr(municipio))
    If m = "" Then
        MontarCabecalhoMunicipio = "Município não informado"
        Exit Function
    End If

    If UCase$(Left$(m, 9)) = "MUNICIPIO" Then
        MontarCabecalhoMunicipio = m
    Else
        MontarCabecalhoMunicipio = "Município de " & m
    End If
End Function

Private Sub CarregarCabecalhoConfig()
    Dim wsCfg As Worksheet

    On Error Resume Next
    Set wsCfg = ThisWorkbook.Sheets(SHEET_CONFIG)
    On Error GoTo 0

    If wsCfg Is Nothing Then Exit Sub

    Gestor_Empresa = Trim$(CStr(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_GESTOR).Value))
    municipio = Trim$(CStr(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MUNICIPIO).Value))
End Sub

Private Sub AplicarFormatoQuantidade(ByVal alvo As Range)
    On Error Resume Next
    If Application.International(xlDecimalSeparator) = "," Then
        alvo.NumberFormatLocal = "0,##"
    Else
        alvo.NumberFormat = "0.##"
    End If
    alvo.ShrinkToFit = True
    On Error GoTo 0
End Sub

Private Sub AplicarFormatoMoedaBR(ByVal alvo As Range)
    Dim fmtLocal As String

    On Error Resume Next
    If Application.International(xlDecimalSeparator) = "," Then
        fmtLocal = "R$ #.##0,00"
        alvo.NumberFormatLocal = fmtLocal
    Else
        fmtLocal = "R$ #,##0.00"
        alvo.NumberFormat = fmtLocal
    End If

    If Err.Number <> 0 Then
        Err.Clear
        alvo.NumberFormat = "[$R$-pt-BR] #,##0.00"
    End If
    alvo.ShrinkToFit = True
    On Error GoTo 0
End Sub

Private Function IdsIguais(ByVal a As String, ByVal b As String) As Boolean
    Dim sA As String
    Dim sB As String

    sA = Trim$(CStr(a))
    sB = Trim$(CStr(b))
    If sA = "" Or sB = "" Then Exit Function

    If IsNumeric(sA) And IsNumeric(sB) Then
        IdsIguais = (CLng(Val(sA)) = CLng(Val(sB)))
    Else
        IdsIguais = (StrComp(sA, sB, vbTextCompare) = 0)
    End If
End Function

Private Sub GarantirDadosPreOSParaImpressao(ByVal preosId As Variant)
    Dim wsPre As Worksheet
    Dim wsEmp As Worksheet
    Dim wsEnt As Worksheet
    Dim wsServ As Worksheet
    Dim i As Long
    Dim linhaPre As Long
    Dim linhaEmp As Long
    Dim linhaEnt As Long
    Dim linhaServ As Long
    Dim empId As String
    Dim entId As String
    Dim ativId As String
    Dim codServ As String
    Dim servId As String
    Dim preId As String

    On Error GoTo erro_carregamento

    preId = Trim$(CStr(preosId))
    If preId = "" Then Exit Sub

    Set wsPre = ThisWorkbook.Sheets(SHEET_PREOS)
    Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    Set wsEnt = ThisWorkbook.Sheets(SHEET_ENTIDADE)
    Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_PREOS)
        If IdsIguais(SafeListVal(wsPre.Cells(i, COL_PREOS_ID).Value), preId) Then
            linhaPre = i
            Exit For
        End If
    Next i
    If linhaPre = 0 Then Exit Sub

    empId = SafeListVal(wsPre.Cells(linhaPre, COL_PREOS_EMP_ID).Value)
    entId = SafeListVal(wsPre.Cells(linhaPre, COL_PREOS_ENT_ID).Value)
    ativId = SafeListVal(wsPre.Cells(linhaPre, COL_PREOS_ATIV_ID).Value)
    codServ = SafeListVal(wsPre.Cells(linhaPre, COL_PREOS_COD_SERV).Value)
    servId = ExtrairServId(codServ, ativId)

    If Util_Conversao.ToDouble(QT_ESTIMADA) <= 0 Then QT_ESTIMADA = Util_Conversao.ToDouble(wsPre.Cells(linhaPre, COL_PREOS_QT_EST).Value)
    If Util_Conversao.ToDouble(Vl_estimado) <= 0 Then Vl_estimado = Util_Conversao.ToDouble(wsPre.Cells(linhaPre, COL_PREOS_VL_EST).Value)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_SERV)
        If IdsIguais(SafeListVal(wsServ.Cells(i, COL_SERV_ID).Value), servId) Then
            If ativId = "" Or IdsIguais(SafeListVal(wsServ.Cells(i, COL_SERV_ATIV_ID).Value), ativId) Then
                linhaServ = i
                Exit For
            End If
        End If
    Next i
    If linhaServ > 0 Then
        If Trim$(Desc_Ativi) = "" Then Desc_Ativi = SafeListVal(wsServ.Cells(linhaServ, COL_SERV_ATIV_DESC).Value)
        If Trim$(Desc_Serv) = "" Then Desc_Serv = SafeListVal(wsServ.Cells(linhaServ, COL_SERV_DESCRICAO).Value)
        If Util_Conversao.ToDouble(Vl_estimado) <= 0 Then Vl_estimado = Util_Conversao.ToDouble(wsServ.Cells(linhaServ, COL_SERV_VALOR_UNIT).Value) * Util_Conversao.ToDouble(QT_ESTIMADA)
    End If

    For i = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
        If IdsIguais(SafeListVal(wsEmp.Cells(i, COL_EMP_ID).Value), empId) Then
            linhaEmp = i
            Exit For
        End If
    Next i
    If linhaEmp > 0 Then
        M_NomeEmpresa = SafeListVal(wsEmp.Cells(linhaEmp, COL_EMP_RAZAO).Value)
        Empresa_CNPJ = SafeListVal(wsEmp.Cells(linhaEmp, COL_EMP_CNPJ).Value)
        Empresa_endereco = SafeListVal(wsEmp.Cells(linhaEmp, COL_EMP_ENDERECO).Value)
        Empresa_TelCel = SafeListVal(wsEmp.Cells(linhaEmp, COL_EMP_TEL_CEL).Value)
        Empresa_email = SafeListVal(wsEmp.Cells(linhaEmp, COL_EMP_EMAIL).Value)
    End If

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_ENTIDADE)
        If IdsIguais(SafeListVal(wsEnt.Cells(i, COL_ENT_ID).Value), entId) Then
            linhaEnt = i
            Exit For
        End If
    Next i
    If linhaEnt > 0 Then
        Desc_entidade = SafeListVal(wsEnt.Cells(linhaEnt, COL_ENT_NOME).Value)
        cont_entidade = SafeListVal(wsEnt.Cells(linhaEnt, COL_ENT_CONT1_NOME).Value)
        telcont_entidade = SafeListVal(wsEnt.Cells(linhaEnt, COL_ENT_CONT1_FONE).Value)
        END_ENTIDADE = SafeListVal(wsEnt.Cells(linhaEnt, COL_ENT_ENDERECO).Value)
    End If

    Exit Sub
erro_carregamento:
End Sub

Private Sub InserirAtividadePadrao(ByVal wsAtiv As Worksheet, ByVal CNAE As String, ByVal descricao As String)
    Dim linhaNova As Long

    If AtividadeJaExiste(wsAtiv, CNAE, descricao) Then Exit Sub

    linhaNova = UltimaLinhaAba(SHEET_ATIVIDADES) + 1
    If linhaNova < LINHA_DADOS Then linhaNova = LINHA_DADOS

    wsAtiv.Cells(linhaNova, COL_ATIV_ID).Value = ProximoId(SHEET_ATIVIDADES)
    wsAtiv.Cells(linhaNova, COL_ATIV_CNAE).NumberFormat = "@"
    wsAtiv.Cells(linhaNova, COL_ATIV_CNAE).Value = FormatarCodigoCNAE(CNAE)
    wsAtiv.Cells(linhaNova, COL_ATIV_DESCRICAO).Value = LimparTextoImportado(descricao)
End Sub

Private Function AtividadeJaExiste(ByVal wsAtiv As Worksheet, ByVal CNAE As String, ByVal descricao As String) As Boolean
    Dim i As Long
    Dim ultima As Long
    Dim cnaeAtual As String
    Dim descAtual As String
    Dim cnaeNovo As String
    Dim descNovo As String

    ultima = UltimaLinhaAba(SHEET_ATIVIDADES)
    If ultima < LINHA_DADOS Then
        AtividadeJaExiste = False
        Exit Function
    End If

    cnaeNovo = SomenteDigitos(CNAE)
    descNovo = NormalizarTextoBusca(descricao)

    For i = LINHA_DADOS To ultima
        cnaeAtual = SomenteDigitos(wsAtiv.Cells(i, COL_ATIV_CNAE).Value)
        descAtual = NormalizarTextoBusca(wsAtiv.Cells(i, COL_ATIV_DESCRICAO).Value)
        If (cnaeNovo <> "" And cnaeAtual = cnaeNovo) Or (descNovo <> "" And descAtual = descNovo) Then
            AtividadeJaExiste = True
            Exit Function
        End If
    Next i

    AtividadeJaExiste = False
End Function

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

    If Len(s) >= 4 Then ExtrairServId = Mid$(s, 4)
End Function

Public Sub PreenchimentoListaAtividade(Optional ByVal termoFiltro As String = "", Optional ByVal lstDireto As Object = Nothing)
On Error GoTo erro_carregamento
Dim wsAtiv As Worksheet
Dim filtro As String
Dim ultima As Long
Dim i As Long
Dim qtd As Long
Dim idx As Long
Dim itens() As Variant
Dim lst As Object

Call CargaInicialCNAE_SeNecessario

Set wsAtiv = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
Call Util_LimparFiltrosAba(wsAtiv)

If Not lstDireto Is Nothing Then
    Set lst = lstDireto
Else
    Set lst = ControleFormulario("Cadastro_Servico", "SV_Lista")
End If
If lst Is Nothing Then Exit Sub
filtro = UCase$(Trim$(termoFiltro))

With lst
    .Clear
    .RowSource = vbNullString
    .ColumnCount = 3
    ' V12.0.0010: col0=ID(30), col1=CNAE(90), col2=Descricao(320)
    .ColumnWidths = "30; 90; 320"
End With

ultima = UltimaLinhaAba(SHEET_ATIVIDADES)
If ultima < LINHA_DADOS Then Exit Sub

For i = LINHA_DADOS To ultima
    If LinhaAtividadeCombina(wsAtiv, i, filtro) Then qtd = qtd + 1
Next i

If qtd = 0 Then Exit Sub

ReDim itens(1 To qtd, 1 To 3)
idx = 1
For i = LINHA_DADOS To ultima
    If LinhaAtividadeCombina(wsAtiv, i, filtro) Then
        itens(idx, 1) = wsAtiv.Cells(i, COL_ATIV_ID).Value
        itens(idx, 2) = wsAtiv.Cells(i, COL_ATIV_CNAE).Value
        itens(idx, 3) = wsAtiv.Cells(i, COL_ATIV_DESCRICAO).Value
        idx = idx + 1
    End If
Next i

lst.List = itens
Exit Sub

erro_carregamento:
End Sub

Private Function LinhaAtividadeCombina(ByVal wsAtiv As Worksheet, ByVal linhaAtual As Long, ByVal filtro As String) As Boolean
    Dim textoBusca As String

    If filtro = "" Then
        LinhaAtividadeCombina = True
        Exit Function
    End If

    textoBusca = SafeListVal(wsAtiv.Cells(linhaAtual, COL_ATIV_ID).Value) & " " & _
                 SafeListVal(wsAtiv.Cells(linhaAtual, COL_ATIV_CNAE).Value) & " " & _
                 SafeListVal(wsAtiv.Cells(linhaAtual, COL_ATIV_DESCRICAO).Value)

    LinhaAtividadeCombina = UtilFiltro_LinhaAtende(textoBusca, filtro)
End Function

Public Sub ImportarCNAE_Arquivo()
On Error GoTo erro_carregamento
Dim arq As Variant
Dim ext As String
Dim importados As Long

arq = Application.GetOpenFilename("Arquivos CNAE (*.csv;*.xls;*.xlsx),*.csv;*.xls;*.xlsx", , _
                                  "Selecione o arquivo de CNAE")
If arq = False Then Exit Sub

ext = LCase$(Mid$(CStr(arq), InStrRev(CStr(arq), ".") + 1))
If ext = "csv" Then
    importados = ImportarCNAE_CSV(CStr(arq), True)
Else
    importados = ImportarCNAE_Excel(CStr(arq), True)
End If

Call InvalidarCacheCnaeAtividade
Call PreenchimentoListaAtividade
MsgBox "Importação de CNAE concluída. Registros novos: " & importados, vbInformation, "CNAE"
Exit Sub

erro_carregamento:
MsgBox "Falha ao importar CNAE: " & Err.Description, vbCritical, "CNAE"
End Sub

Public Sub ImportarCNAE_Padrao_TimeAI()
On Error GoTo erro_carregamento
Dim caminho As String
Dim importados As Long
Dim msgSave As String

caminho = LocalizarArquivoCnaePadrao()

If caminho = "" Then
    MsgBox "Arquivo CNAE padrão não encontrado." & vbCrLf & _
           "Esperado na raiz do projeto ou nos caminhos legados versionados.", vbExclamation, "CNAE"
    Exit Sub
End If

importados = ImportarCNAE_CSV(caminho, True)
Call InvalidarCacheCnaeAtividade
Call SincronizarDescricoesCadServComAtividades(True)
Call Util_SalvarWorkbookSeguro(msgSave)
Call PreenchimentoListaAtividade
MsgBox "Importação CNAE padrão concluída. Registros novos: " & importados & vbCrLf & _
       "Fonte: " & caminho, vbInformation, "CNAE"
Exit Sub

erro_carregamento:
MsgBox "Falha na importação CNAE padrão: " & Err.Description, vbCritical, "CNAE"
End Sub

Public Sub CargaCNAE_Permanente()
On Error GoTo erro_carregamento
Dim qtd As Long
Dim msgSave As String

qtd = CargaInicialCNAE_SeNecessario(True)
If Not Util_SalvarWorkbookSeguro(msgSave) Then
    MsgBox "Carga CNAE executada, mas houve falha ao salvar automaticamente." & vbCrLf & _
           "Detalhe: " & msgSave, vbExclamation, "CNAE"
    Exit Sub
End If
MsgBox "Carga CNAE concluída e salva na planilha." & vbCrLf & _
       "Registros novos: " & qtd, vbInformation, "CNAE"
Exit Sub

erro_carregamento:
MsgBox "Falha ao carregar/salvar CNAE: " & Err.Description, vbCritical, "CNAE"
End Sub

Public Sub ResetarECarregarCNAE_Padrao_DryRun()
' ---------------------------------------------------------------
' V12.0.0203 - Dry-run do reset CNAE.
' Gera RPT_CNAE_DIFF e nao altera ATIVIDADES nem CAD_SERV.
' ---------------------------------------------------------------
Dim wsAtiv As Worksheet
Dim wsServ As Worksheet
Dim wsRpt As Worksheet
Dim caminho As String
Dim textoCsv As String
Dim linhas() As String
Dim linhaTxt As String
Dim partesCabec() As String
Dim partes() As String
Dim delim As String
Dim colCnae As Long
Dim colDesc As Long
Dim temCabecalho As Boolean
Dim idxLinha As Long
Dim inicioLoop As Long
Dim totalLinhas As Long
Dim i As Long
Dim j As Long
Dim cnaeVal As String
Dim descVal As String
Dim chave As String
Dim qtdImportaveis As Long
Dim qtdDuplicadasCsv As Long
Dim qtdAtividadesAtuais As Long
Dim qtdCadServ As Long
Dim qtdCadServVinculado As Long
Dim ultimaAtiv As Long
Dim ultimaServ As Long
Dim mapaCsv As Object
Dim mapaAtual As Object
Dim linhaRpt As Long
Dim estavaProtegidaRpt As Boolean
Dim senhaProtecaoRpt As String
Dim erroNumero As Long
Dim erroMensagem As String

On Error GoTo erro_carregamento

Application.StatusBar = "Dry-run CNAE: localizando CSV..."
caminho = LocalizarArquivoCnaePadrao()
If caminho = "" Then
    MsgBox "Arquivo CNAE padrao nao encontrado. Nenhuma alteracao foi feita.", _
           vbExclamation, "Dry-run CNAE"
    Application.StatusBar = False
    Exit Sub
End If

Application.StatusBar = "Dry-run CNAE: lendo CSV..."
textoCsv = LerTextoArquivo(caminho)
If textoCsv = "" Then
    MsgBox "CSV encontrado, mas vazio ou ilegivel:" & vbCrLf & caminho, _
           vbCritical, "Dry-run CNAE"
    Application.StatusBar = False
    Exit Sub
End If

textoCsv = Replace(textoCsv, vbCrLf, vbLf)
textoCsv = Replace(textoCsv, vbCr, vbLf)
linhas = Split(textoCsv, vbLf)
If UBound(linhas) < 1 Then
    MsgBox "CSV tem menos de 2 linhas. Nenhuma alteracao foi feita." & vbCrLf & caminho, _
           vbCritical, "Dry-run CNAE"
    Application.StatusBar = False
    Exit Sub
End If

linhaTxt = linhas(0)
If InStr(1, linhaTxt, ";") > 0 Then
    delim = ";"
Else
    delim = ","
End If

partesCabec = Split(linhaTxt, delim)
colCnae = IdentificarColunaCabecalho(partesCabec, "CNAE", "SUBCLASSE", "SUBCLASSE_ID", "CODIGO")
colDesc = IdentificarColunaCabecalho(partesCabec, "DESCRICAO", "DENOMINACAO", "DENOMINACAO_SUBCLASSE")
temCabecalho = (colCnae >= 0 And colDesc >= 0)

If Not temCabecalho Then
    If UBound(partesCabec) >= 2 Then
        colCnae = 1
        colDesc = 2
    Else
        MsgBox "Cabecalho do CSV nao reconhecido e formato posicional invalido." & vbCrLf & _
               "Primeira linha: " & Left$(linhaTxt, 200), vbCritical, "Dry-run CNAE"
        Application.StatusBar = False
        Exit Sub
    End If
End If

Set mapaCsv = CreateObject("Scripting.Dictionary")
Set mapaAtual = CreateObject("Scripting.Dictionary")
mapaCsv.CompareMode = vbTextCompare
mapaAtual.CompareMode = vbTextCompare

If temCabecalho Then
    inicioLoop = 1
Else
    inicioLoop = 0
End If
totalLinhas = UBound(linhas)

Application.StatusBar = "Dry-run CNAE: analisando CSV..."
For idxLinha = inicioLoop To totalLinhas
    linhaTxt = linhas(idxLinha)
    If Trim$(linhaTxt) <> "" Then
        partes = Split(linhaTxt, delim)
        If colCnae <= UBound(partes) And colDesc <= UBound(partes) Then
            cnaeVal = Trim$(Replace(partes(colCnae), """", ""))
            descVal = Trim$(Replace(partes(colDesc), """", ""))

            If UBound(partes) > colDesc Then
                For j = colDesc + 1 To UBound(partes)
                    descVal = descVal & "," & Trim$(Replace(partes(j), """", ""))
                Next j
            End If

            cnaeVal = FormatarCodigoCNAE(cnaeVal)
            descVal = LimparTextoImportado(descVal)
            chave = CnaeDryRun_Chave(cnaeVal, descVal)

            If chave <> "" Then
                qtdImportaveis = qtdImportaveis + 1
                If mapaCsv.Exists(chave) Then
                    qtdDuplicadasCsv = qtdDuplicadasCsv + 1
                Else
                    mapaCsv.Add chave, cnaeVal & "||" & descVal
                End If
            End If
        End If
    End If
Next idxLinha

Application.StatusBar = "Dry-run CNAE: analisando abas atuais..."
Set wsAtiv = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
ultimaAtiv = UltimaLinhaAba(SHEET_ATIVIDADES)
If ultimaAtiv >= LINHA_DADOS Then
    For i = LINHA_DADOS To ultimaAtiv
        cnaeVal = FormatarCodigoCNAE(SafeListVal(wsAtiv.Cells(i, COL_ATIV_CNAE).Value))
        descVal = LimparTextoImportado(SafeListVal(wsAtiv.Cells(i, COL_ATIV_DESCRICAO).Value))
        chave = CnaeDryRun_Chave(cnaeVal, descVal)
        If chave <> "" Then
            qtdAtividadesAtuais = qtdAtividadesAtuais + 1
            If Not mapaAtual.Exists(chave) Then mapaAtual.Add chave, cnaeVal & "||" & descVal
        End If
    Next i
End If

Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
ultimaServ = UltimaLinhaAba(SHEET_CAD_SERV)
If ultimaServ >= LINHA_DADOS Then
    For i = LINHA_DADOS To ultimaServ
        If LinhaServicoValida(wsServ, i) Then
            qtdCadServ = qtdCadServ + 1
            If Trim$(SafeListVal(wsServ.Cells(i, COL_SERV_ATIV_ID).Value)) <> "" Or _
               Trim$(SafeListVal(wsServ.Cells(i, COL_SERV_ATIV_DESC).Value)) <> "" Then
                qtdCadServVinculado = qtdCadServVinculado + 1
            End If
        End If
    Next i
End If

Set wsRpt = CnaeDryRun_EnsureSheet()
If Not Util_PrepararAbaParaEscrita(wsRpt, estavaProtegidaRpt, senhaProtecaoRpt) Then
    MsgBox "Nao foi possivel preparar RPT_CNAE_DIFF para escrita." & vbCrLf & _
           "Nenhuma aba operacional foi alterada.", vbCritical, "Dry-run CNAE"
    Application.StatusBar = False
    Exit Sub
End If

Application.StatusBar = "Dry-run CNAE: gerando RPT_CNAE_DIFF..."
wsRpt.Cells.Clear
linhaRpt = 1
wsRpt.Cells(linhaRpt, 1).Value = "RPT_CNAE_DIFF - DRY-RUN"
wsRpt.Cells(linhaRpt, 2).Value = Format$(Now, "dd/mm/yyyy hh:nn:ss")
linhaRpt = linhaRpt + 2

wsRpt.Cells(linhaRpt, 1).Value = "FONTE_CSV"
wsRpt.Cells(linhaRpt, 2).Value = caminho
linhaRpt = linhaRpt + 1
wsRpt.Cells(linhaRpt, 1).Value = "LINHAS_CSV"
wsRpt.Cells(linhaRpt, 2).Value = UBound(linhas) + 1
linhaRpt = linhaRpt + 1
wsRpt.Cells(linhaRpt, 1).Value = "REGISTROS_IMPORTAVEIS"
wsRpt.Cells(linhaRpt, 2).Value = qtdImportaveis
linhaRpt = linhaRpt + 1
wsRpt.Cells(linhaRpt, 1).Value = "REGISTROS_DISTINTOS_CSV"
wsRpt.Cells(linhaRpt, 2).Value = mapaCsv.count
linhaRpt = linhaRpt + 1
wsRpt.Cells(linhaRpt, 1).Value = "DUPLICIDADES_CSV_IGNORADAS"
wsRpt.Cells(linhaRpt, 2).Value = qtdDuplicadasCsv
linhaRpt = linhaRpt + 1
wsRpt.Cells(linhaRpt, 1).Value = "ATIVIDADES_ATUAIS"
wsRpt.Cells(linhaRpt, 2).Value = qtdAtividadesAtuais
linhaRpt = linhaRpt + 1
wsRpt.Cells(linhaRpt, 1).Value = "CAD_SERV_LINHAS_VALIDAS"
wsRpt.Cells(linhaRpt, 2).Value = qtdCadServ
linhaRpt = linhaRpt + 1
wsRpt.Cells(linhaRpt, 1).Value = "CAD_SERV_VINCULOS_QUE_SERIAM_LIMPOS"
wsRpt.Cells(linhaRpt, 2).Value = qtdCadServVinculado
linhaRpt = linhaRpt + 1
wsRpt.Cells(linhaRpt, 1).Value = "STATUS"
wsRpt.Cells(linhaRpt, 2).Value = "DRY-RUN: nenhuma escrita operacional realizada"
linhaRpt = linhaRpt + 2

Call CnaeDryRun_EscreverSecao(wsRpt, linhaRpt, "AMOSTRA_ADICIONADAS_CSV_NAO_ATUAL", mapaCsv, mapaAtual, 25)
linhaRpt = linhaRpt + 1
Call CnaeDryRun_EscreverSecao(wsRpt, linhaRpt, "AMOSTRA_REMOVIDAS_ATUAL_NAO_CSV", mapaAtual, mapaCsv, 25)

Call CnaeDryRun_FormatarRelatorio(wsRpt, linhaRpt)
Call Util_RestaurarProtecaoAba(wsRpt, estavaProtegidaRpt, senhaProtecaoRpt)

Application.StatusBar = False
wsRpt.Activate
MsgBox "Dry-run CNAE concluido sem alterar dados operacionais." & vbCrLf & vbCrLf & _
       "CSV importavel: " & qtdImportaveis & vbCrLf & _
       "Atividades atuais: " & qtdAtividadesAtuais & vbCrLf & _
       "Vinculos em CAD_SERV que seriam limpos: " & qtdCadServVinculado & vbCrLf & _
       "Relatorio: RPT_CNAE_DIFF", vbInformation, "Dry-run CNAE"
Exit Sub

erro_carregamento:
erroNumero = Err.Number
erroMensagem = Err.Description
On Error Resume Next
Application.StatusBar = False
If Not wsRpt Is Nothing Then Call Util_RestaurarProtecaoAba(wsRpt, estavaProtegidaRpt, senhaProtecaoRpt)
On Error GoTo 0
If erroMensagem = "" Then erroMensagem = "Erro " & CStr(erroNumero)
MsgBox "Falha no dry-run CNAE: " & erroMensagem & vbCrLf & _
       "Nenhuma aba operacional foi alterada.", vbCritical, "Dry-run CNAE"
End Sub

Private Function CnaeDryRun_Chave(ByVal cnaeVal As String, ByVal descVal As String) As String
    cnaeVal = Trim$(cnaeVal)
    descVal = Trim$(descVal)
    If cnaeVal = "" Or descVal = "" Then Exit Function
    CnaeDryRun_Chave = UCase$(cnaeVal & "|" & descVal)
End Function

Private Function CnaeDryRun_EnsureSheet() As Worksheet
    Dim ws As Worksheet

    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets("RPT_CNAE_DIFF")
    On Error GoTo 0

    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.count))
        ws.Name = "RPT_CNAE_DIFF"
    End If

    Set CnaeDryRun_EnsureSheet = ws
End Function

Private Sub CnaeDryRun_SepararValor(ByVal valor As String, ByRef cnaeVal As String, ByRef descVal As String)
    Dim pos As Long

    cnaeVal = ""
    descVal = ""
    pos = InStr(1, valor, "||", vbBinaryCompare)
    If pos > 0 Then
        cnaeVal = Left$(valor, pos - 1)
        descVal = Mid$(valor, pos + 2)
    Else
        descVal = valor
    End If
End Sub

Private Sub CnaeDryRun_EscreverSecao( _
    ByVal wsRpt As Worksheet, _
    ByRef linhaRpt As Long, _
    ByVal titulo As String, _
    ByVal mapaOrigem As Object, _
    ByVal mapaComparacao As Object, _
    ByVal limite As Long _
)
    Dim chaves As Variant
    Dim i As Long
    Dim qtd As Long
    Dim chave As String
    Dim cnaeVal As String
    Dim descVal As String
    Dim exibir As Boolean

    wsRpt.Cells(linhaRpt, 1).Value = titulo
    wsRpt.Cells(linhaRpt, 1).Font.Bold = True
    linhaRpt = linhaRpt + 1
    wsRpt.Cells(linhaRpt, 1).Value = "SEQ"
    wsRpt.Cells(linhaRpt, 2).Value = "CNAE"
    wsRpt.Cells(linhaRpt, 3).Value = "DESCRICAO"
    wsRpt.Cells(linhaRpt, 4).Value = "CHAVE"
    linhaRpt = linhaRpt + 1

    If Not mapaOrigem Is Nothing Then
        If mapaOrigem.count > 0 Then
            chaves = mapaOrigem.Keys
            For i = LBound(chaves) To UBound(chaves)
                chave = CStr(chaves(i))
                exibir = True
                If Not mapaComparacao Is Nothing Then
                    If mapaComparacao.Exists(chave) Then exibir = False
                End If

                If exibir Then
                    qtd = qtd + 1
                    Call CnaeDryRun_SepararValor(CStr(mapaOrigem(chave)), cnaeVal, descVal)
                    wsRpt.Cells(linhaRpt, 1).Value = qtd
                    wsRpt.Cells(linhaRpt, 2).Value = cnaeVal
                    wsRpt.Cells(linhaRpt, 3).Value = descVal
                    wsRpt.Cells(linhaRpt, 4).Value = chave
                    linhaRpt = linhaRpt + 1
                    If qtd >= limite Then Exit For
                End If
            Next i
        End If
    End If

    If qtd = 0 Then
        wsRpt.Cells(linhaRpt, 1).Value = "SEM_DIFERENCA_NA_AMOSTRA"
        linhaRpt = linhaRpt + 1
    End If
End Sub

Private Sub CnaeDryRun_FormatarRelatorio(ByVal wsRpt As Worksheet, ByVal ultimaLinha As Long)
    If ultimaLinha < 1 Then Exit Sub

    With wsRpt
        .Columns("A:D").EntireColumn.AutoFit
        .Rows(1).Font.Bold = True
        .Rows(1).Font.Color = RGB(255, 255, 255)
        .Rows(1).Interior.Color = RGB(0, 51, 102)
        .Range(.Cells(1, 1), .Cells(ultimaLinha, 4)).Borders.LineStyle = xlContinuous
        .Range(.Cells(1, 1), .Cells(ultimaLinha, 4)).Borders.Weight = xlThin
        .Columns("A:A").ColumnWidth = 18
        .Columns("B:B").ColumnWidth = 18
        .Columns("C:C").ColumnWidth = 70
        .Columns("D:D").ColumnWidth = 85
        .Rows("1:" & ultimaLinha).VerticalAlignment = xlTop
    End With
End Sub

Public Sub ResetarECarregarCNAE_Padrao()
' ---------------------------------------------------------------
' V12.0.0143 - Reescrita completa com import direto inline.
' Elimina dependencias de ProximoId por-linha e AtividadeJaExiste.
' Valida CSV ANTES de apagar dados. Diagnostico em cada passo.
' ---------------------------------------------------------------
Dim wsAtiv As Worksheet
Dim ultima As Long
Dim caminho As String
Dim textoCsv As String
Dim qtd As Long
Dim qtdCadServ As Long
Dim estavaProtegida As Boolean
Dim senhaProtecao As String
Dim msgSave As String
Dim pastaBase As String
Dim linhas() As String
Dim linhaTxt As String
Dim partesCabec() As String
Dim delim As String
Dim colCnae As Long
Dim colDesc As Long
Dim temCabecalho As Boolean
Dim idxLinha As Long
Dim partes() As String
Dim cnaeVal As String
Dim descVal As String
Dim linhaEscrita As Long
Dim contadorId As Long
Dim etapa As String
Dim inicioLoop As Long
Dim totalLinhas As Long
Dim j As Long

On Error GoTo erro_carregamento

' --- ETAPA 1: Localizar CSV ---
etapa = "Localizando arquivo CSV"
Application.StatusBar = "Reset CNAE: " & etapa & "..."
caminho = LocalizarArquivoCnaePadrao()

If caminho = "" Then
    pastaBase = Trim$(ThisWorkbook.Path)
    MsgBox "Arquivo CNAE padrão não encontrado." & vbCrLf & vbCrLf & _
           "ThisWorkbook.Path = " & pastaBase & vbCrLf & vbCrLf & _
           "Caminhos verificados:" & vbCrLf & _
           "  1) " & pastaBase & "\cnae_servicos_normalizado.csv" & vbCrLf & _
           "  2) " & pastaBase & "\doc\cnae-normalizado\cnae_completo_normalizado.csv" & vbCrLf & _
           "  3) " & pastaBase & "\doc\Time_AI\bases_auxiliares\cnaes_ibge.csv" & vbCrLf & _
           "  (+ 3 caminhos no diretorio-pai)" & vbCrLf & vbCrLf & _
           "Copie o CSV para um desses caminhos e tente novamente.", _
           vbExclamation, "Reset CNAE"
    Application.StatusBar = False
    Exit Sub
End If

' --- ETAPA 2: Ler e validar conteudo do CSV ---
etapa = "Lendo arquivo CSV"
Application.StatusBar = "Reset CNAE: " & etapa & "..."
textoCsv = LerTextoArquivo(caminho)
If textoCsv = "" Then
    MsgBox "CSV encontrado mas vazio ou ilegível:" & vbCrLf & caminho & vbCrLf & vbCrLf & _
           "Verifique encoding (UTF-8 ou ANSI esperado).", _
           vbCritical, "Reset CNAE"
    Application.StatusBar = False
    Exit Sub
End If

' --- ETAPA 3: Parsear cabecalho e validar estrutura ---
etapa = "Parseando cabecalho"
Application.StatusBar = "Reset CNAE: " & etapa & "..."
textoCsv = Replace(textoCsv, vbCrLf, vbLf)
textoCsv = Replace(textoCsv, vbCr, vbLf)
linhas = Split(textoCsv, vbLf)

If UBound(linhas) < 1 Then
    MsgBox "CSV tem menos de 2 linhas - sem dados para importar." & vbCrLf & _
           "Arquivo: " & caminho, vbCritical, "Reset CNAE"
    Application.StatusBar = False
    Exit Sub
End If

linhaTxt = linhas(0)
If InStr(1, linhaTxt, ";") > 0 Then
    delim = ";"
Else
    delim = ","
End If

partesCabec = Split(linhaTxt, delim)
colCnae = IdentificarColunaCabecalho(partesCabec, "CNAE", "SUBCLASSE", "SUBCLASSE_ID", "CODIGO")
colDesc = IdentificarColunaCabecalho(partesCabec, "DESCRICAO", "DENOMINACAO", "DENOMINACAO_SUBCLASSE")
temCabecalho = (colCnae >= 0 And colDesc >= 0)

If Not temCabecalho Then
    ' Fallback: CSV sem cabecalho reconhecido - tentar colunas posicionais.
    ' Formato esperado: ID, CNAE, DESCRICAO (3 colunas).
    If UBound(partesCabec) >= 2 Then
        colCnae = 1
        colDesc = 2
        temCabecalho = False ' processar todas as linhas inclusive a primeira
    Else
        MsgBox "Cabeçalho do CSV não reconhecido:" & vbCrLf & _
               "Primeira linha: " & Left$(linhaTxt, 200) & vbCrLf & vbCrLf & _
               "Esperado: colunas CNAE e DESCRICAO (ou pelo menos 3 colunas).", _
               vbCritical, "Reset CNAE"
        Application.StatusBar = False
        Exit Sub
    End If
End If

' --- ETAPA 4: Confirmar com usuario (CSV ja validado) ---
If MsgBox("Reset vai APAGAR dados atuais da aba ATIVIDADES e reimportar do CSV." & vbCrLf & vbCrLf & _
          "Fonte: " & caminho & vbCrLf & _
          "Linhas no CSV: " & (UBound(linhas) + 1) & vbCrLf & _
          "Delimitador: """ & delim & """" & vbCrLf & _
          "Cabeçalho detectado: " & IIf(temCabecalho, "Sim (CNAE col " & colCnae & ", DESC col " & colDesc & ")", "Não (posicional)") & vbCrLf & vbCrLf & _
          "Deseja continuar?", vbQuestion + vbYesNo, "Reset CNAE V12.0.0143") <> vbYes Then
    Application.StatusBar = False
    Exit Sub
End If

' V12.0.0203 ONDA 3 - pergunta se quer podar snapshots antigos antes
' de criar mais um. Mantem os 5 mais recentes por default.
Dim qtdPodadas As Long
qtdPodadas = CnaeConfirmarPodaSnapshots(5)

' --- ETAPA 5: Preparar aba - desproteger UMA VEZ para todo o ciclo ---
etapa = "Preparando aba ATIVIDADES"
Application.StatusBar = "Reset CNAE: " & etapa & "..."
Set wsAtiv = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
Call Util_LimparFiltrosAba(wsAtiv)

If Not Util_PrepararAbaParaEscrita(wsAtiv, estavaProtegida, senhaProtecao) Then
    MsgBox "Não foi possível desproteger a aba ATIVIDADES." & vbCrLf & _
           "ProtectContents = " & wsAtiv.ProtectContents, vbCritical, "Reset CNAE"
    Application.StatusBar = False
    Exit Sub
End If

' --- ETAPA 6: Limpar dados existentes ---
etapa = "Limpando dados existentes"
Application.StatusBar = "Reset CNAE: " & etapa & "..."
ultima = UltimaLinhaAba(SHEET_ATIVIDADES)
If ultima >= LINHA_DADOS Then
    wsAtiv.Range(wsAtiv.Cells(LINHA_DADOS, COL_ATIV_ID), wsAtiv.Cells(ultima, COL_ATIV_DESCRICAO)).ClearContents
End If
wsAtiv.Cells(1, COL_CONTADOR_AR).Value = 0

' --- ETAPA 7: Import DIRETO - escrita inline sem ProximoId/AtividadeJaExiste ---
etapa = "Importando registros"
contadorId = 0
linhaEscrita = LINHA_DADOS
qtd = 0

If temCabecalho Then
    inicioLoop = 1 ' pular cabecalho
Else
    inicioLoop = 0 ' processar desde a primeira linha
End If

totalLinhas = UBound(linhas)

For idxLinha = inicioLoop To totalLinhas
    linhaTxt = linhas(idxLinha)
    If Trim$(linhaTxt) = "" Then GoTo proxima_linha

    partes = Split(linhaTxt, delim)

    ' Extrair CNAE e descricao pela posicao detectada.
    If colCnae > UBound(partes) Or colDesc > UBound(partes) Then GoTo proxima_linha

    cnaeVal = Trim$(Replace(partes(colCnae), """", ""))
    descVal = Trim$(Replace(partes(colDesc), """", ""))

    ' Para descricoes com virgula dentro de aspas: se ha mais partes alem do
    ' esperado, a descricao (ultima coluna logica) foi quebrada pelo Split.
    ' Reunificar todas as partes excedentes.
    If UBound(partes) > colDesc Then
        For j = colDesc + 1 To UBound(partes)
            descVal = descVal & "," & Trim$(Replace(partes(j), """", ""))
        Next j
    End If

    If cnaeVal = "" Or descVal = "" Then GoTo proxima_linha

    ' Formatar CNAE.
    cnaeVal = FormatarCodigoCNAE(cnaeVal)
    descVal = LimparTextoImportado(descVal)

    ' Escrever diretamente - sem ProximoId (contador inline), sem AtividadeJaExiste (aba limpa).
    contadorId = contadorId + 1
    wsAtiv.Cells(linhaEscrita, COL_ATIV_ID).Value = Format$(contadorId, "000")
    wsAtiv.Cells(linhaEscrita, COL_ATIV_CNAE).NumberFormat = "@"
    wsAtiv.Cells(linhaEscrita, COL_ATIV_CNAE).Value = cnaeVal
    wsAtiv.Cells(linhaEscrita, COL_ATIV_DESCRICAO).Value = descVal
    linhaEscrita = linhaEscrita + 1
    qtd = qtd + 1

    ' Feedback visual a cada 50 registros.
    If qtd Mod 50 = 0 Then
        Application.StatusBar = "Reset CNAE: importando... " & qtd & " de ~" & totalLinhas & " registros"
        DoEvents
    End If

proxima_linha:
Next idxLinha

' Atualizar contador oficial da aba.
wsAtiv.Cells(1, COL_CONTADOR_AR).Value = contadorId

' --- ETAPA 8: Restaurar protecao ---
etapa = "Restaurando protecao"
Application.StatusBar = "Reset CNAE: " & etapa & "..."
Call Util_RestaurarProtecaoAba(wsAtiv, estavaProtegida, senhaProtecao)

If qtd = 0 Then
    MsgBox "ATENÇÃO: nenhum registro foi importado." & vbCrLf & _
           "Linhas no CSV: " & (totalLinhas + 1) & vbCrLf & _
           "Cabeçalho: " & temCabecalho & " (CNAE col=" & colCnae & ", DESC col=" & colDesc & ")" & vbCrLf & _
           "Delimitador: """ & delim & """" & vbCrLf & _
           "Primeira linha de dados: " & Left$(linhas(inicioLoop), 200) & vbCrLf & vbCrLf & _
           "Arquivo: " & caminho, _
           vbCritical, "Reset CNAE"
    Application.StatusBar = False
    Exit Sub
End If

' --- ETAPA 9: Pos-processamento ---
etapa = "Pos-processamento"
Application.StatusBar = "Reset CNAE: " & etapa & "..."
Call InvalidarCacheCnaeAtividade

' V12.0.0203 ONDA 2 - snapshot de CAD_SERV antes da limpeza,
' validacao de duplicidade e auditoria via EVT_TRANSACAO.
' V12.0.0203 ONDA 3 - dedup AUTOMATICO de duplicatas remanescentes
' em ATIVIDADES (decisao do operador: import remanescente nao deve
' persistir no estado final).
Dim nomeSnapshot As String
Dim qtdLinhasSnapshot As Long
Dim qtdDuplicatas As Long
Dim qtdDupRemovidas As Long

nomeSnapshot = CnaeSnapshotCadServ(qtdLinhasSnapshot)
qtdCadServ = LimparCadServParaAssociacaoManual()
qtdDuplicatas = CnaeContarDuplicatasAtividades()
qtdDupRemovidas = 0
If qtdDuplicatas > 0 Then
    qtdDupRemovidas = CnaeRemoverDuplicatasAtividades()
End If

' Auditoria do reset (evento existente EVT_TRANSACAO, sem mexer em
' Audit_Log.bas nem criar novo enum). Antes/Depois carregam o
' contexto operacional do que aconteceu.
On Error Resume Next
RegistrarEvento _
    EVT_TRANSACAO, ENT_ATIV, "RESET_CNAE", _
    "ATIVIDADES_ANTES=" & CStr(ultima) & _
    "; CADSERV_ANTES=" & CStr(qtdCadServ), _
    "RESET_CNAE_CONCLUIDO" & _
    "; ATIVIDADES_IMPORTADAS=" & CStr(qtd) & _
    "; CADSERV_LIMPADO=" & CStr(qtdCadServ) & _
    "; SNAPSHOT=" & nomeSnapshot & _
    "; SNAPSHOT_LINHAS=" & CStr(qtdLinhasSnapshot) & _
    "; SNAPSHOTS_PODADOS=" & CStr(qtdPodadas) & _
    "; ATIVIDADES_DUPLICATAS=" & CStr(qtdDuplicatas) & _
    "; DUPLICATAS_REMOVIDAS=" & CStr(qtdDupRemovidas), _
    "Preencher"
On Error GoTo erro_carregamento

Call PreenchimentoListaAtividade
Call PreencherManutencaoValor

If Not Util_SalvarWorkbookSeguro(msgSave) Then
    MsgBox "Reset executado com " & qtd & " registros, mas falha ao salvar:" & vbCrLf & _
           msgSave & vbCrLf & "Use Ctrl+S.", vbExclamation, "Reset CNAE"
    Application.StatusBar = False
    Exit Sub
End If

Application.StatusBar = False
MsgBox "Reset e carga concluída com sucesso!" & vbCrLf & vbCrLf & _
       "Registros CNAE carregados: " & qtd & vbCrLf & _
       "Associações removidas em CAD_SERV: " & qtdCadServ & vbCrLf & _
       "Snapshot preservado: " & nomeSnapshot & " (" & qtdLinhasSnapshot & " linhas)" & vbCrLf & _
       "Snapshots antigos podados: " & qtdPodadas & vbCrLf & _
       "Duplicatas detectadas em ATIVIDADES: " & qtdDuplicatas & vbCrLf & _
       "Duplicatas removidas automaticamente: " & qtdDupRemovidas & vbCrLf & _
       "Vinculação de serviços permanece manual." & vbCrLf & _
       "Fonte: " & caminho, vbInformation, "Reset CNAE"
Exit Sub

erro_carregamento:
On Error Resume Next
Application.StatusBar = False
If Not wsAtiv Is Nothing Then Call Util_RestaurarProtecaoAba(wsAtiv, estavaProtegida, senhaProtecao)
On Error GoTo 0
MsgBox "ERRO no reset CNAE!" & vbCrLf & vbCrLf & _
       "Etapa: " & etapa & vbCrLf & _
       "Erro: " & Err.Description & vbCrLf & _
       "Número: " & Err.Number & vbCrLf & _
       "Registros importados até o erro: " & qtd & vbCrLf & _
       "Fonte CSV: " & caminho, vbCritical, "Reset CNAE"
End Sub

Public Function SincronizarDescricoesCadServComAtividades(Optional ByVal corrigirLegado As Boolean = True) As Long
On Error GoTo erro_carregamento
Dim wsAtiv As Worksheet
Dim wsServ As Worksheet
Dim ultimaAtiv As Long
Dim ultimaServ As Long
Dim i As Long
Dim chave As String
Dim descAtiv As String
Dim descAtual As String
Dim descFinal As String
Dim mapa As Object

Set wsAtiv = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
ultimaAtiv = UltimaLinhaAba(SHEET_ATIVIDADES)
ultimaServ = UltimaLinhaAba(SHEET_CAD_SERV)

If ultimaAtiv < LINHA_DADOS Or ultimaServ < LINHA_DADOS Then
    SincronizarDescricoesCadServComAtividades = 0
    Exit Function
End If

Set mapa = CreateObject("Scripting.Dictionary")

For i = LINHA_DADOS To ultimaAtiv
    chave = ChaveId(wsAtiv.Cells(i, COL_ATIV_ID).Value)
    If chave <> "" Then
        mapa(chave) = Trim$(CStr(wsAtiv.Cells(i, COL_ATIV_DESCRICAO).Value))
    End If
Next i

For i = LINHA_DADOS To ultimaServ
    chave = ChaveId(wsServ.Cells(i, COL_SERV_ATIV_ID).Value)
    descAtual = Trim$(CStr(wsServ.Cells(i, COL_SERV_ATIV_DESC).Value))

    If mapa.Exists(chave) Then
        descFinal = CStr(mapa(chave))
    ElseIf corrigirLegado Then
        descFinal = CorrigirMojibakeBasico(descAtual)
    Else
        descFinal = descAtual
    End If

    If descFinal <> "" And descFinal <> descAtual Then
        wsServ.Cells(i, COL_SERV_ATIV_DESC).Value = descFinal
        SincronizarDescricoesCadServComAtividades = SincronizarDescricoesCadServComAtividades + 1
    End If
Next i

Exit Function

erro_carregamento:
SincronizarDescricoesCadServComAtividades = 0
End Function

Private Function ChaveId(ByVal v As Variant) As String
    Dim s As String
    s = Trim$(CStr(v))
    If s = "" Then Exit Function
    If IsNumeric(s) Then
        ChaveId = CStr(CLng(Val(s)))
    Else
        ChaveId = s
    End If
End Function

Private Function CorrigirMojibakeBasico(ByVal s As String) As String
    Dim t As String
    t = s
    t = Replace(t, "Ã¡", "á")
    t = Replace(t, "Ã¢", "â")
    t = Replace(t, "Ã£", "ã")
    t = Replace(t, "Ã€", "À")
    t = Replace(t, "Ã", "Á")
    t = Replace(t, "Ã‚", "Â")
    t = Replace(t, "Ãƒ", "Ã")
    t = Replace(t, "Ã§", "ç")
    t = Replace(t, "Ã‡", "Ç")
    t = Replace(t, "Ã©", "é")
    t = Replace(t, "Ã¨", "è")
    t = Replace(t, "Ãª", "ê")
    t = Replace(t, "Ã‰", "É")
    t = Replace(t, "ÃŠ", "Ê")
    t = Replace(t, "Ã­", "í")
    t = Replace(t, "Ã", "Í")
    t = Replace(t, "Ã³", "ó")
    t = Replace(t, "Ã´", "ô")
    t = Replace(t, "Ãµ", "õ")
    t = Replace(t, "Ã“", "Ó")
    t = Replace(t, "Ã”", "Ô")
    t = Replace(t, "Ã•", "Õ")
    t = Replace(t, "Ãº", "ú")
    t = Replace(t, "Ãš", "Ú")
    CorrigirMojibakeBasico = t
End Function

Public Function CargaInicialCNAE_SeNecessario(Optional ByVal exibirMensagem As Boolean = False) As Long
On Error GoTo erro_carregamento
Dim caminho As String
Dim qtd As Long
Dim totalAtividades As Long
Dim msgSave As String

qtd = 0
If UltimaLinhaAba(SHEET_ATIVIDADES) >= LINHA_DADOS Then
    CargaInicialCNAE_SeNecessario = 0
    Exit Function
End If

' V12: prioriza a base CNAE canônica da raiz do projeto/workbook.
caminho = LocalizarArquivoCnaePadrao()

If caminho <> "" Then
    qtd = ImportarCNAE_CSV(caminho, True)
    If qtd > 0 Then
        Call InvalidarCacheCnaeAtividade
        Call SincronizarDescricoesCadServComAtividades(True)
        Call Util_SalvarWorkbookSeguro(msgSave)
    End If
End If

totalAtividades = UltimaLinhaAba(SHEET_ATIVIDADES) - (LINHA_DADOS - 1)
If totalAtividades < 0 Then totalAtividades = 0

If exibirMensagem Then
    MsgBox "Carga inicial de CNAE concluída. Registros na ATIVIDADES: " & _
           totalAtividades & vbCrLf & _
           "Fonte: " & IIf(caminho <> "", caminho, "Workbook já persistido"), vbInformation, "CNAE"
    If caminho = "" And totalAtividades = 0 Then
        MsgBox "Nenhum arquivo can" & ChrW(244) & "nico de CNAE foi encontrado e a aba ATIVIDADES continua vazia." & vbCrLf & _
               "O administrador deve carregar a base estrutural antes de distribuir esta planilha.", _
               vbExclamation, "Base CNAE obrigatória"
    End If
End If

CargaInicialCNAE_SeNecessario = qtd
Exit Function

erro_carregamento:
CargaInicialCNAE_SeNecessario = 0
End Function

Private Function LocalizarArquivoCnaePadrao() As String
    Dim pastaBase As String
    Dim pastaPai As String
    Dim caminho As String
    Dim sep As String

    pastaBase = Trim$(ThisWorkbook.Path)
    If pastaBase = "" Then Exit Function

    sep = Application.PathSeparator

    ' --- Busca relativa a ThisWorkbook.Path ---
    caminho = pastaBase & sep & "cnae_servicos_normalizado.csv"
    If Util_ArquivoExiste(caminho) Then
        LocalizarArquivoCnaePadrao = caminho
        Exit Function
    End If

    caminho = pastaBase & sep & "doc" & sep & "cnae-normalizado" & sep & "cnae_completo_normalizado.csv"
    If Util_ArquivoExiste(caminho) Then
        LocalizarArquivoCnaePadrao = caminho
        Exit Function
    End If

    caminho = pastaBase & sep & "doc" & sep & "Time_AI" & sep & "bases_auxiliares" & sep & "cnaes_ibge.csv"
    If Util_ArquivoExiste(caminho) Then
        LocalizarArquivoCnaePadrao = caminho
        Exit Function
    End If

    ' --- V12.0.0143: Busca tambem no diretorio-pai (caso workbook esteja em subpasta) ---
    pastaPai = Left$(pastaBase, InStrRev(pastaBase, sep) - 1)
    If pastaPai = "" Then Exit Function

    caminho = pastaPai & sep & "cnae_servicos_normalizado.csv"
    If Util_ArquivoExiste(caminho) Then
        LocalizarArquivoCnaePadrao = caminho
        Exit Function
    End If

    caminho = pastaPai & sep & "doc" & sep & "cnae-normalizado" & sep & "cnae_completo_normalizado.csv"
    If Util_ArquivoExiste(caminho) Then
        LocalizarArquivoCnaePadrao = caminho
        Exit Function
    End If

    caminho = pastaPai & sep & "doc" & sep & "Time_AI" & sep & "bases_auxiliares" & sep & "cnaes_ibge.csv"
    If Util_ArquivoExiste(caminho) Then
        LocalizarArquivoCnaePadrao = caminho
    End If
End Function

Private Function ImportarCNAE_CSV(ByVal caminhoCsv As String, Optional ByVal silencioso As Boolean = False) As Long
    Dim wsAtiv As Worksheet
    Dim texto As String
    Dim linhas() As String
    Dim linhaTxt As String
    Dim idxLinha As Long
    Dim delim As String
    Dim CNAE As String
    Dim descricao As String
    Dim importados As Long
    Dim colCnae As Long
    Dim colDesc As Long
    Dim temCabecalho As Boolean
    Dim partesCabec() As String
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    Set wsAtiv = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
    Call Util_LimparFiltrosAba(wsAtiv)

    If Not Util_PrepararAbaParaEscrita(wsAtiv, estavaProtegida, senhaProtecao) Then
        ImportarCNAE_CSV = 0
        Exit Function
    End If

    texto = LerTextoArquivo(caminhoCsv)
    If texto = "" Then
        Call Util_RestaurarProtecaoAba(wsAtiv, estavaProtegida, senhaProtecao)
        ImportarCNAE_CSV = 0
        Exit Function
    End If

    texto = Replace(texto, vbCrLf, vbLf)
    texto = Replace(texto, vbCr, vbLf)
    linhas = Split(texto, vbLf)
    If UBound(linhas) < 0 Then
        Call Util_RestaurarProtecaoAba(wsAtiv, estavaProtegida, senhaProtecao)
        ImportarCNAE_CSV = 0
        Exit Function
    End If

    linhaTxt = linhas(0)
    If InStr(1, linhaTxt, ";") > 0 Then
        delim = ";"
    Else
        delim = ","
    End If

    partesCabec = Split(linhaTxt, delim)
    colCnae = IdentificarColunaCabecalho(partesCabec, "CNAE", "SUBCLASSE", "SUBCLASSE_ID", "CODIGO")
    colDesc = IdentificarColunaCabecalho(partesCabec, "DESCRICAO", "DENOMINACAO", "DENOMINACAO_SUBCLASSE")
    temCabecalho = (colCnae >= 0 And colDesc >= 0)

    ' Se a primeira linha nao for cabecalho reconhecido, processa como dado.
    If Not temCabecalho Then
        Call ExtrairCnaeDescricao(linhaTxt, delim, CNAE, descricao)
        If CNAE <> "" And descricao <> "" And Not AtividadeJaExiste(wsAtiv, CNAE, descricao) Then
            Call InserirAtividadeImportada(wsAtiv, CNAE, descricao)
            importados = importados + 1
        End If
    End If

    For idxLinha = 1 To UBound(linhas)
        linhaTxt = linhas(idxLinha)
        If Trim$(linhaTxt) <> "" Then
            If temCabecalho Then
                Call ExtrairCnaeDescricaoComCabecalho(linhaTxt, delim, colCnae, colDesc, CNAE, descricao)
            Else
                Call ExtrairCnaeDescricao(linhaTxt, delim, CNAE, descricao)
            End If
            If CNAE <> "" And descricao <> "" And Not AtividadeJaExiste(wsAtiv, CNAE, descricao) Then
                Call InserirAtividadeImportada(wsAtiv, CNAE, descricao)
                importados = importados + 1
            End If
        End If
    Next idxLinha

    Call Util_RestaurarProtecaoAba(wsAtiv, estavaProtegida, senhaProtecao)

    ImportarCNAE_CSV = importados
    If Not silencioso Then
        MsgBox "CNAEs importados do CSV: " & importados, vbInformation, "CNAE"
    End If
End Function

Private Function ImportarCNAE_Excel(ByVal caminhoExcel As String, Optional ByVal silencioso As Boolean = False) As Long
    Dim wbSrc As Workbook
    Dim wsSrc As Worksheet
    Dim wsAtiv As Worksheet
    Dim linhaCab As Long
    Dim colCnae As Long
    Dim colDesc As Long
    Dim c As Long
    Dim cab As String
    Dim ultima As Long
    Dim i As Long
    Dim CNAE As String
    Dim descricao As String
    Dim linhaNova As Long
    Dim importados As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    Set wsAtiv = ThisWorkbook.Sheets(SHEET_ATIVIDADES)

    If Not Util_PrepararAbaParaEscrita(wsAtiv, estavaProtegida, senhaProtecao) Then
        ImportarCNAE_Excel = 0
        Exit Function
    End If

    Set wbSrc = Workbooks.Open(Filename:=caminhoExcel, ReadOnly:=True)
    Set wsSrc = wbSrc.Worksheets(1)
    ultima = wsSrc.Cells(wsSrc.Rows.count, 1).End(xlUp).row

    linhaCab = 1
    colCnae = 1
    colDesc = 2

    For i = 1 To 10
        For c = 1 To 30
            cab = UCase$(Trim$(CStr(wsSrc.Cells(i, c).Value)))
            If cab <> "" Then
                If InStr(1, cab, "SUBCLASSE", vbTextCompare) > 0 Or InStr(1, cab, "CNAE", vbTextCompare) > 0 Then
                    colCnae = c
                    linhaCab = i
                End If
                If InStr(1, cab, "DENOMIN", vbTextCompare) > 0 Or InStr(1, cab, "DESCR", vbTextCompare) > 0 Then
                    colDesc = c
                    linhaCab = i
                End If
            End If
        Next c
    Next i

    For i = linhaCab + 1 To ultima
        CNAE = Trim$(CStr(wsSrc.Cells(i, colCnae).Value))
        descricao = Trim$(CStr(wsSrc.Cells(i, colDesc).Value))

        If CNAE <> "" And descricao <> "" Then
            If Not AtividadeJaExiste(wsAtiv, CNAE, descricao) Then
                linhaNova = UltimaLinhaAba(SHEET_ATIVIDADES) + 1
                If linhaNova < LINHA_DADOS Then linhaNova = LINHA_DADOS
                wsAtiv.Cells(linhaNova, COL_ATIV_ID).Value = ProximoId(SHEET_ATIVIDADES)
                wsAtiv.Cells(linhaNova, COL_ATIV_CNAE).NumberFormat = "@"
                wsAtiv.Cells(linhaNova, COL_ATIV_CNAE).Value = FormatarCodigoCNAE(CNAE)
                wsAtiv.Cells(linhaNova, COL_ATIV_DESCRICAO).Value = LimparTextoImportado(descricao)
                importados = importados + 1
            End If
        End If
    Next i

    wbSrc.Close savechanges:=False
    Call Util_RestaurarProtecaoAba(wsAtiv, estavaProtegida, senhaProtecao)

    ImportarCNAE_Excel = importados
    If Not silencioso Then
        MsgBox "CNAEs importados do Excel: " & importados, vbInformation, "CNAE"
    End If
End Function

Private Function ReinstalarCadServEstruturalPorAtividades() As Long
    Dim wsAtiv As Worksheet
    Dim wsServ As Worksheet
    Dim ultimaAtiv As Long
    Dim ultimaServ As Long
    Dim linhaAtiv As Long
    Dim linhaServ As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo erro_carregamento

    Set wsAtiv = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
    Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    ultimaAtiv = UltimaLinhaAba(SHEET_ATIVIDADES)

    If ultimaAtiv < LINHA_DADOS Then Exit Function
    If Not Util_PrepararAbaParaEscrita(wsServ, estavaProtegida, senhaProtecao) Then Exit Function

    ultimaServ = UltimaLinhaAba(SHEET_CAD_SERV)
    If ultimaServ >= LINHA_DADOS Then
        wsServ.Range(wsServ.Cells(LINHA_DADOS, COL_SERV_ID), wsServ.Cells(ultimaServ, COL_SERV_DT_CAD)).ClearContents
    End If

    wsServ.Cells(1, COL_CONTADOR_AR).Value = 1
    linhaServ = LINHA_DADOS

    For linhaAtiv = LINHA_DADOS To ultimaAtiv
        If Trim$(SafeListVal(wsAtiv.Cells(linhaAtiv, COL_ATIV_ID).Value)) <> "" And _
           Trim$(SafeListVal(wsAtiv.Cells(linhaAtiv, COL_ATIV_DESCRICAO).Value)) <> "" Then
            wsServ.Cells(linhaServ, COL_SERV_ID).Value = "001"
            wsServ.Cells(linhaServ, COL_SERV_ATIV_ID).Value = SafeListVal(wsAtiv.Cells(linhaAtiv, COL_ATIV_ID).Value)
            wsServ.Cells(linhaServ, COL_SERV_ATIV_DESC).Value = SafeListVal(wsAtiv.Cells(linhaAtiv, COL_ATIV_DESCRICAO).Value)
            wsServ.Cells(linhaServ, COL_SERV_DESCRICAO).Value = SafeListVal(wsAtiv.Cells(linhaAtiv, COL_ATIV_DESCRICAO).Value)
            wsServ.Cells(linhaServ, COL_SERV_VALOR_UNIT).Value = 0#
            wsServ.Cells(linhaServ, COL_SERV_VALOR_UNIT).NumberFormat = "_-R$ * #,##0.00_-;-R$ * #,##0.00_-;_-R$ * ""-""??_-;_-@_-"
            wsServ.Cells(linhaServ, COL_SERV_DT_CAD).Value = Now
            ReinstalarCadServEstruturalPorAtividades = ReinstalarCadServEstruturalPorAtividades + 1
            linhaServ = linhaServ + 1
        End If
    Next linhaAtiv

    Call Util_RestaurarProtecaoAba(wsServ, estavaProtegida, senhaProtecao)
    Exit Function

erro_carregamento:
    On Error Resume Next
    Call Util_RestaurarProtecaoAba(wsServ, estavaProtegida, senhaProtecao)
    On Error GoTo 0
    ReinstalarCadServEstruturalPorAtividades = 0
End Function

Private Function LimparCadServParaAssociacaoManual() As Long
    Dim wsServ As Worksheet
    Dim ultimaServ As Long
    Dim linha As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo erro_carregamento

    Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    Call Util_LimparFiltrosAba(wsServ)
    ultimaServ = UltimaLinhaAba(SHEET_CAD_SERV)
    If ultimaServ < LINHA_DADOS Then Exit Function

    For linha = LINHA_DADOS To ultimaServ
        If LinhaServicoValida(wsServ, linha) Then
            LimparCadServParaAssociacaoManual = LimparCadServParaAssociacaoManual + 1
        End If
    Next linha

    If Not Util_PrepararAbaParaEscrita(wsServ, estavaProtegida, senhaProtecao) Then
        LimparCadServParaAssociacaoManual = 0
        Exit Function
    End If

    wsServ.Range(wsServ.Cells(LINHA_DADOS, COL_SERV_ID), wsServ.Cells(ultimaServ, COL_SERV_DT_CAD)).ClearContents
    wsServ.Cells(1, COL_CONTADOR_AR).Value = 0

    Call Util_RestaurarProtecaoAba(wsServ, estavaProtegida, senhaProtecao)
    Exit Function

erro_carregamento:
    On Error Resume Next
    Call Util_RestaurarProtecaoAba(wsServ, estavaProtegida, senhaProtecao)
    On Error GoTo 0
    LimparCadServParaAssociacaoManual = 0
End Function

Private Sub ExtrairCnaeDescricao(ByVal linhaTxt As String, ByVal delim As String, ByRef CNAE As String, ByRef descricao As String)
    Dim partes() As String
    Dim i As Long
    Dim token As String
    Dim ultimoTexto As String

    partes = Split(linhaTxt, delim)
    CNAE = ""
    descricao = ""

    ' Formatos comuns:
    ' 1) id;descricao;...
    ' 2) ...;cnae;descricao;...
    If UBound(partes) >= 1 Then
        If EhTokenCNAE(LimparCampoCsv(partes(0))) Then
            CNAE = LimparCampoCsv(partes(0))
            descricao = LimparCampoCsv(partes(1))
            Exit Sub
        End If
    End If
    If UBound(partes) >= 2 Then
        If EhTokenCNAE(LimparCampoCsv(partes(1))) Then
            CNAE = LimparCampoCsv(partes(1))
            descricao = LimparCampoCsv(partes(2))
            Exit Sub
        End If
    End If

    For i = LBound(partes) To UBound(partes)
        token = LimparCampoCsv(partes(i))
        If token <> "" Then
            ultimoTexto = token
            If CNAE = "" And EhTokenCNAE(token) Then
                CNAE = token
            End If
        End If
    Next i

    If CNAE = "" Then
        If UBound(partes) >= 0 Then CNAE = LimparCampoCsv(partes(0))
    End If

    If ultimoTexto <> "" Then descricao = ultimoTexto
End Sub

Private Function LimparCampoCsv(ByVal v As String) As String
    LimparCampoCsv = Trim$(Replace(v, """", ""))
End Function

Private Function LerTextoArquivo(ByVal caminho As String) As String
    ' Tenta UTF-8 primeiro para preservar acentuacao do CONCLA.
    Dim stm As Object
    Dim f As Integer
    Dim linha As String
    Dim txt As String

    On Error GoTo fallback_ansi

    Set stm = CreateObject("ADODB.Stream")
    stm.Type = 2
    stm.Mode = 3
    stm.Charset = "utf-8"
    stm.Open
    stm.LoadFromFile caminho
    LerTextoArquivo = stm.ReadText(-1)
    stm.Close
    Set stm = Nothing
    Exit Function

fallback_ansi:
    On Error GoTo fim

    f = FreeFile
    Open caminho For Input As #f
    Do While Not EOF(f)
        Line Input #f, linha
        txt = txt & linha & vbCrLf
    Loop
    Close #f
    LerTextoArquivo = txt
    Exit Function

fim:
    LerTextoArquivo = ""
End Function

Private Sub InserirAtividadeImportada(ByVal wsAtiv As Worksheet, ByVal CNAE As String, ByVal descricao As String)
    Dim linhaNova As Long

    linhaNova = UltimaLinhaAba(SHEET_ATIVIDADES) + 1
    If linhaNova < LINHA_DADOS Then linhaNova = LINHA_DADOS

    wsAtiv.Cells(linhaNova, COL_ATIV_ID).Value = ProximoId(SHEET_ATIVIDADES)
    wsAtiv.Cells(linhaNova, COL_ATIV_CNAE).NumberFormat = "@"
    wsAtiv.Cells(linhaNova, COL_ATIV_CNAE).Value = FormatarCodigoCNAE(CNAE)
    wsAtiv.Cells(linhaNova, COL_ATIV_DESCRICAO).Value = LimparTextoImportado(descricao)
End Sub

Private Function FormatarCodigoCNAE(ByVal codigo As String) As String
    Dim d As String
    d = SomenteDigitos(codigo)

    If Len(d) = 7 Then
        FormatarCodigoCNAE = Left$(d, 4) & "-" & Mid$(d, 5, 1) & "/" & Right$(d, 2)
    ElseIf Len(d) = 5 Then
        FormatarCodigoCNAE = Left$(d, 4) & "-" & Right$(d, 1)
    Else
        FormatarCodigoCNAE = Trim$(codigo)
    End If
End Function

Private Function SomenteDigitos(ByVal txt As Variant) As String
    Dim s As String
    Dim i As Long
    Dim ch As String
    s = CStr(txt)
    For i = 1 To Len(s)
        ch = Mid$(s, i, 1)
        If ch Like "[0-9]" Then SomenteDigitos = SomenteDigitos & ch
    Next i
End Function

Private Function LimparTextoImportado(ByVal txt As String) As String
    Dim s As String
    s = Trim$(txt)
    s = Replace(s, ChrW$(&HFEFF), "")
    LimparTextoImportado = s
End Function

Private Function NormalizarTextoBusca(ByVal txt As Variant) As String
    NormalizarTextoBusca = UCase$(Trim$(CStr(txt)))
End Function

Private Sub ExtrairCnaeDescricaoComCabecalho(ByVal linhaTxt As String, ByVal delim As String, _
                                             ByVal colCnae As Long, ByVal colDesc As Long, _
                                             ByRef CNAE As String, ByRef descricao As String)
    Dim partes() As String
    partes = Split(linhaTxt, delim)

    CNAE = LimparCampoPorIndice(partes, colCnae)
    descricao = LimparCampoPorIndice(partes, colDesc)
End Sub

Private Function LimparCampoPorIndice(ByRef partes() As String, ByVal idx As Long) As String
    If idx < LBound(partes) Or idx > UBound(partes) Then
        LimparCampoPorIndice = ""
    Else
        LimparCampoPorIndice = LimparCampoCsv(partes(idx))
    End If
End Function

Private Function IdentificarColunaCabecalho(ByRef partes() As String, _
                                            ByVal alvo1 As String, _
                                            ByVal alvo2 As String, _
                                            Optional ByVal alvo3 As String = "", _
                                            Optional ByVal alvo4 As String = "") As Long
    Dim i As Long
    Dim h As String

    IdentificarColunaCabecalho = -1

    ' Passo 1: match exato.
    For i = LBound(partes) To UBound(partes)
        h = NormalizarCabecalho(LimparCampoCsv(partes(i)))
        If h = NormalizarCabecalho(alvo1) Or h = NormalizarCabecalho(alvo2) Or _
           (alvo3 <> "" And h = NormalizarCabecalho(alvo3)) Or _
           (alvo4 <> "" And h = NormalizarCabecalho(alvo4)) Then
            IdentificarColunaCabecalho = i
            Exit Function
        End If
    Next i

    ' Passo 2: contains.
    For i = LBound(partes) To UBound(partes)
        h = NormalizarCabecalho(LimparCampoCsv(partes(i)))
        If InStr(1, h, NormalizarCabecalho(alvo1), vbTextCompare) > 0 Or _
           InStr(1, h, NormalizarCabecalho(alvo2), vbTextCompare) > 0 Or _
           (alvo3 <> "" And InStr(1, h, NormalizarCabecalho(alvo3), vbTextCompare) > 0) Or _
           (alvo4 <> "" And InStr(1, h, NormalizarCabecalho(alvo4), vbTextCompare) > 0) Then
            IdentificarColunaCabecalho = i
            Exit Function
        End If
    Next i
End Function

Private Function NormalizarCabecalho(ByVal txt As String) As String
    Dim s As String
    s = UCase$(Trim$(txt))
    s = Replace(s, ChrW$(&HFEFF), "") ' remove BOM quando presente
    s = Replace(s, " ", "_")
    NormalizarCabecalho = s
End Function

Private Function EhTokenCNAE(ByVal token As String) As Boolean
    Dim s As String
    Dim i As Long
    Dim temDigito As Boolean
    Dim digitos As Long
    Dim ch As String

    s = Trim$(token)
    If s = "" Then Exit Function

    For i = 1 To Len(s)
        ch = Mid$(s, i, 1)
        If ch Like "[0-9]" Then
            temDigito = True
            digitos = digitos + 1
        End If
    Next i

    ' Evita capturar codigos muito curtos (divisao/grupo) como CNAE principal.
    EhTokenCNAE = temDigito And digitos >= 5
End Function

Sub PreencherServicoFormatado()
' V12: eliminado Sheets.Select + Range.Activate (proibidos; chamado de formulario modal).
' Usa referencia direta via ws.Cells.
On Error GoTo erro_carregamento
Dim wsServ As Worksheet
Dim Linhalistbox As Integer
Dim lst As Object

Linhalistbox = 0
linha = 2
Set lst = ControleFormulario("Menu_Principal", "A_Lista")
If lst Is Nothing Then Exit Sub

Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
NLinhas = wsServ.Range("A1048576").End(xlUp).row

With wsServ
    While linha <= NLinhas
        With lst
            .AddItem
            .List(Linhalistbox, 0) = wsServ.Cells(linha, 1)
            .List(Linhalistbox, 1) = wsServ.Cells(linha, 2)
            .List(Linhalistbox, 2) = wsServ.Cells(linha, 3)
            .List(Linhalistbox, 3) = wsServ.Cells(linha, 4)
            .List(Linhalistbox, 4) = Format(wsServ.Cells(linha, 5), "currency")
            .List(Linhalistbox, 5) = Format(wsServ.Cells(linha, 6), "currency")
            .List(Linhalistbox, 6) = Format(wsServ.Cells(linha, 7), "currency")
            .List(Linhalistbox, 7) = Format(wsServ.Cells(linha, 8), "currency")
            .List(Linhalistbox, 8) = wsServ.Cells(linha, 9)
            Linhalistbox = Linhalistbox + 1
            linha = linha + 1
        End With
    Wend
End With

erro_carregamento:
End Sub
Sub PreencherAvaliacaoOS()
' V12: eliminado Sheets.Select + Range.Select + ActiveCell (proibidos; chamado de formulario modal).
' Usa referencia direta via ws.Range("X").Value.
' V12.0.0093: IMP_AVALIA costuma estar protegida - desproteger antes de gravar.
Dim ws As Worksheet
Set ws = ThisWorkbook.Sheets("IMP_AVALIA")
If Not mImpAvaliaEmUso Then
    If Not Util_PrepararAbaParaEscrita(ws, mImpAvaliaEstavaProt, mImpAvaliaSenha) Then Exit Sub
    mImpAvaliaEmUso = True
End If
Call CarregarCabecalhoConfig
ws.Range("D2").Value = MontarCabecalhoMunicipio(municipio)
ws.Range("D3").Value = Gestor_Empresa
ws.Range("L3").Value = N_OS
ws.Range("L8").Value = Desc_entidade & " - " & cont_entidade & " - " & telcont_entidade
ws.Range("N5").Value = AvDtFech
ws.Range("C9").Value = M_NomeEmpresa
ws.Range("C11").Value = Empresa_endereco
ws.Range("C13").Value = Empresa_TelCel
ws.Range("C15").Value = Empresa_email
ws.Range("G13").Value = Empresa_CNPJ
ws.Range("B18").Value = Desc_Ativi
ws.Range("F18").Value = END_ENTIDADE
ws.Range("L18").Value = Desc_Serv
ws.Range("B23").Value = Desc_Serv
ws.Range("L23").Value = Util_Conversao.ToDouble(AvQtH)
Call AplicarFormatoQuantidade(ws.Range("L23"))
ws.Range("M23").Value = Util_Conversao.ToDouble(CStr(AvVlOs))
Call AplicarFormatoMoedaBR(ws.Range("M23"))
ws.Range("N27").Value = Format(AvN01, "##,#")
ws.Range("N28").Value = Format(Avn02, "##,#")
ws.Range("N29").Value = Format(AvN03, "##,#")
ws.Range("N30").Value = Format(AvN04, "##,#")
ws.Range("N31").Value = Format(AvN05, "##,#")
ws.Range("N32").Value = Format(AvN06, "##,#")
ws.Range("N33").Value = Format(AvN07, "##,#")
ws.Range("N34").Value = Format(AvN08, "##,#")
ws.Range("N35").Value = Format(AvN09, "##,#")
ws.Range("N36").Value = Format(AvN10, "##,#")
ws.Range("D37").Value = AvNEmp
ws.Range("N37").Value = Util_Conversao.ToCurrency(FormatarMediaAvaliacao(media))
ws.Range("N37").NumberFormat = "0.00"
ws.Range("B40").Value = AvOb
End Sub

Sub Imprimir_AvaliacaoOS()
' V12: eliminado Sheets.Select + Range.Select + ActiveWindow.SelectedSheets.PrintOut
' Usa ws.PageSetup e ws.PrintOut diretamente.
' V12.0.0093: se PreencherAvaliacaoOS nao rodou (falha de preparacao), garantir desprotecao aqui.
Dim ws As Worksheet
Set ws = ThisWorkbook.Sheets("IMP_AVALIA")
If Not mImpAvaliaEmUso Then
    If Not Util_PrepararAbaParaEscrita(ws, mImpAvaliaEstavaProt, mImpAvaliaSenha) Then Exit Sub
    mImpAvaliaEmUso = True
End If
With ws.PageSetup
'        .LeftHeader = ""
'        .CenterHeader = ""
'        .RightHeader = ""
'        .LeftFooter = ""
'        .CenterFooter = ""
'        .RightFooter = ""
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .Orientation = xlPortrait
        .LeftMargin = Application.CentimetersToPoints(0.5)
        .RightMargin = Application.CentimetersToPoints(0.5)
        .TopMargin = Application.CentimetersToPoints(0.5)
        .BottomMargin = Application.CentimetersToPoints(1)
        .HeaderMargin = Application.CentimetersToPoints(0.5)
        .FooterMargin = Application.CentimetersToPoints(0.5)
        .PrintHeadings = False
        .PrintGridlines = False
        .PrintComments = xlPrintNoComments
        .PrintQuality = 600
        .CenterHorizontally = False
        .CenterVertically = False
        .Orientation = xlPortrait
        .Draft = False
        .PaperSize = xlPaperA4
        .FirstPageNumber = xlAutomatic
        .Order = xlDownThenOver
        .BlackAndWhite = False
        .Zoom = False
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .PrintErrors = xlPrintErrorsDisplayed
        .OddAndEvenPagesHeaderFooter = False
        .DifferentFirstPageHeaderFooter = False
        .ScaleWithDocHeaderFooter = True
        .AlignMarginsHeaderFooter = True
'        .EvenPage.LeftHeader.Text = ""
'        .EvenPage.CenterHeader.Text = ""
'        .EvenPage.RightHeader.Text = ""
'        .EvenPage.LeftFooter.Text = ""
'        .EvenPage.CenterFooter.Text = ""
'        .EvenPage.RightFooter.Text = ""
'        .FirstPage.LeftHeader.Text = ""
'        .FirstPage.CenterHeader.Text = ""
'        .FirstPage.RightHeader.Text = ""
'        .FirstPage.LeftFooter.Text = ""
'        .FirstPage.CenterFooter.Text = ""
'        .FirstPage.RightFooter.Text = ""
'
'        copias = InputBox("Quantas c?pias?", "C?pias a serem Impressas")
        Application.Dialogs(xlDialogPrinterSetup).Show
        ws.PrintOut
End With

End Sub

Sub LimparAvaliacaoOS()
' V12: eliminado Sheets.Select + Range.Select + ActiveCell (proibidos; chamado de formulario modal).
' Usa referencia direta via ws.Range("X").Value.
Dim ws As Worksheet
Set ws = ThisWorkbook.Sheets("IMP_AVALIA")

ws.Range("D2").Value = ""
ws.Range("D3").Value = ""
ws.Range("L3").Value = ""
ws.Range("L8").Value = ""
ws.Range("N5").Value = ""
ws.Range("C9").Value = ""
ws.Range("C11").Value = ""
ws.Range("C13").Value = ""
ws.Range("C15").Value = ""
ws.Range("G13").Value = ""
ws.Range("B18").Value = ""
ws.Range("F18").Value = ""
ws.Range("L18").Value = ""
ws.Range("B23").Value = ""
ws.Range("L23").Value = ""
ws.Range("M23").Value = ""
ws.Range("N27").Value = ""
ws.Range("N28").Value = ""
ws.Range("N29").Value = ""
ws.Range("N30").Value = ""
ws.Range("N31").Value = ""
ws.Range("N32").Value = ""
ws.Range("N33").Value = ""
ws.Range("N34").Value = ""
ws.Range("N35").Value = ""
ws.Range("N36").Value = ""
ws.Range("D37").Value = ""
ws.Range("N37").Value = ""
ws.Range("B40").Value = ""

If mImpAvaliaEmUso Then
    Call Util_RestaurarProtecaoAba(ws, mImpAvaliaEstavaProt, mImpAvaliaSenha)
    mImpAvaliaEmUso = False
End If
End Sub


Sub PreencherManutencaoValor(Optional ByVal filtro As String = "")
On Error GoTo erro_carregamento
Dim lst As Object
Dim wsServ As Worksheet
Dim filtroU As String
Dim cnaeAtual As String
Dim textoBusca As String
Dim total As Long
Dim idx As Long

Cont = 1
Set lst = ControleFormulario("Menu_Principal", "H_Lista")
If lst Is Nothing Then Exit Sub
Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
filtroU = UCase$(Trim$(filtro))
lst.Clear
NLinhas = UltimaLinhaAba(SHEET_CAD_SERV)

With lst
    .ColumnCount = 10
    .ColumnWidths = "30; 0; 85; 180; 330; 65; 0; 0; 0; 70"
End With

If NLinhas < LINHA_DADOS Then Exit Sub

For linha = LINHA_DADOS To NLinhas
    If LinhaServicoValida(wsServ, linha) Then
        cnaeAtual = SafeListVal(BuscarCnaeAtividade(wsServ.Cells(linha, COL_SERV_ATIV_ID).Value))
        textoBusca = SafeListVal(wsServ.Cells(linha, COL_SERV_ID).Value) & " " & _
                    SafeListVal(wsServ.Cells(linha, COL_SERV_ATIV_ID).Value) & " " & _
                    cnaeAtual & " " & _
                    SafeListVal(wsServ.Cells(linha, COL_SERV_ATIV_DESC).Value) & " " & _
                    SafeListVal(wsServ.Cells(linha, COL_SERV_DESCRICAO).Value)
        If UtilFiltro_LinhaAtende(textoBusca, filtroU) Then
            total = total + 1
        End If
    End If
Next linha

If total = 0 Then Exit Sub

ReDim arrayitems(1 To total, 1 To 10)
idx = 1
For linha = LINHA_DADOS To NLinhas
    If LinhaServicoValida(wsServ, linha) Then
        cnaeAtual = SafeListVal(BuscarCnaeAtividade(wsServ.Cells(linha, COL_SERV_ATIV_ID).Value))
        textoBusca = SafeListVal(wsServ.Cells(linha, COL_SERV_ID).Value) & " " & _
                    SafeListVal(wsServ.Cells(linha, COL_SERV_ATIV_ID).Value) & " " & _
                    cnaeAtual & " " & _
                    SafeListVal(wsServ.Cells(linha, COL_SERV_ATIV_DESC).Value) & " " & _
                    SafeListVal(wsServ.Cells(linha, COL_SERV_DESCRICAO).Value)
        If UtilFiltro_LinhaAtende(textoBusca, filtroU) Then
            arrayitems(idx, 1) = SafeListVal(wsServ.Cells(linha, COL_SERV_ID).Value)
            arrayitems(idx, 2) = SafeListVal(wsServ.Cells(linha, COL_SERV_ATIV_ID).Value)
            arrayitems(idx, 3) = cnaeAtual
            arrayitems(idx, 4) = SafeListVal(wsServ.Cells(linha, COL_SERV_ATIV_DESC).Value)
            arrayitems(idx, 5) = SafeListVal(wsServ.Cells(linha, COL_SERV_DESCRICAO).Value)
            arrayitems(idx, 6) = SafeListVal(wsServ.Cells(linha, COL_SERV_VALOR_UNIT).Value)
            arrayitems(idx, 7) = SafeListVal(wsServ.Cells(linha, COL_SERV_RESERVA1).Value)
            arrayitems(idx, 8) = SafeListVal(wsServ.Cells(linha, COL_SERV_RESERVA2).Value)
            arrayitems(idx, 9) = SafeListVal(wsServ.Cells(linha, COL_SERV_RESERVA3).Value)
            arrayitems(idx, 10) = SafeListVal(wsServ.Cells(linha, COL_SERV_DT_CAD).Value)
            idx = idx + 1
        End If
    End If
Next linha

lst.List = arrayitems()
arrayitems = Empty

Exit Sub
erro_carregamento:
End Sub


' V12.0.0203 ONDA 5 - agora delega para Mod_Limpeza_Base.LimpaBaseTotalReset,
' que detecta cabecalho corrompido, usa MAX(End(xlUp)) em 50 colunas e
' tambem zera AUDIT_LOG / RELATORIO. Mantem a mesma assinatura para nao
' quebrar quem chama (Limpar_Base.frm > CommandButton1_Click; tambem o
' fallback Configuracao_Inicial.AbrirLimparBaseSeguro). PRESERVA: ATIVIDADES,
' CAD_SERV, CONFIG.
Sub Limpa_Base()
    Dim relatorio As String
    Dim msgSave As String

    If MsgBox("Tem certeza que deseja ZERAR a Base Operacional?" & vbCrLf & _
              "(EMPRESAS, EMPRESAS_INATIVAS, ENTIDADE, ENTIDADE_INATIVOS," & vbCrLf & _
              " CREDENCIADOS, PRE_OS, CAD_OS, AUDIT_LOG, RELATORIO)" & vbCrLf & _
              "As abas ATIVIDADES (CNAE), CAD_SERV e CONFIG serao PRESERVADAS." & vbCrLf & vbCrLf & _
              "Quando o cabecalho de uma aba estiver corrompido," & vbCrLf & _
              "a rotina detecta e reescreve o cabecalho canonico.", _
              vbQuestion + vbYesNo, "Limpar a Base de Dados") <> vbYes Then
        MsgBox "Base de dados não foi alterada.", vbInformation, "Base preservada"
        Exit Sub
    End If

    If Not Mod_Limpeza_Base.LimpaBaseTotalReset(relatorio) Then
        MsgBox "Falha durante a limpeza:" & vbCrLf & vbCrLf & relatorio, _
               vbCritical, "Limpar Base"
        Exit Sub
    End If

    Call PreenchimentoServico
    Call AtualizarListaEntidadeMenuAtual
    Call AtualizarListaEmpresaMenuAtual
    Call PreenchimentoEntidadeRodizio
    Call PreencherAvaliarOS
    Call PreencherManutencaoValor
    If Not Util_SalvarWorkbookSeguro(msgSave) Then
        MsgBox "Base limpa, mas não foi possível salvar automaticamente." & vbCrLf & _
               "Detalhe: " & msgSave & vbCrLf & _
               "Use Ctrl+S para salvar manualmente antes de continuar.", vbExclamation, "Limpar Base"
    End If
    MsgBox "Base de Dados Limpa com Sucesso!" & vbCrLf & vbCrLf & _
           "Relatorio detalhado tambem foi gravado em RPT_LIMPEZA_TOTAL." & vbCrLf & vbCrLf & _
           relatorio, vbInformation, "Limpar Base"
End Sub

' V12.0.0203 ONDA 3 - exposta como Public para permitir cobertura de
' regressao (CS CNAE_006) provando que ATIVIDADES e CAD_SERV nunca sao
' tocados por essa rotina. Nao altera comportamento; apenas escopo.
Public Function LimparAbaOperacional(ByVal ws As Worksheet, ByVal ultimaColuna As String, ByRef msgErro As String) As Boolean
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim ultimaLinha As Long
    Dim intervalo As String

    msgErro = ""
    If ws Is Nothing Then
        msgErro = "Aba invalida para limpeza."
        Exit Function
    End If

    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        msgErro = "Nao foi possivel liberar escrita na aba '" & ws.Name & "'." & vbCrLf & _
                  "Verifique a senha de protecao da planilha."
        Exit Function
    End If

    On Error GoTo falha

    ultimaLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    If ultimaLinha >= LINHA_DADOS Then
        intervalo = "A" & LINHA_DADOS & ":" & ultimaColuna & CStr(ultimaLinha)
        ws.Range(intervalo).ClearContents
    End If
    ws.Cells(1, COL_CONTADOR_AR).Value = 0

    LimparAbaOperacional = True
    GoTo finalizar

falha:
    msgErro = "Falha ao limpar a aba '" & ws.Name & "': " & Err.Description
    LimparAbaOperacional = False

finalizar:
    Call Util_RestaurarProtecaoAba(ws, estavaProtegida, senhaProtecao)
End Function

' =====================================================================
' V12.0.0143 - IMPORTACAO EMERGENCIAL CNAE
' Zero dependencias internas. Aparece no Alt+F8.
' Le CSV, normaliza formato CNAE, escreve diretamente nas celulas.
' =====================================================================

Public Sub ImportarCNAE_Emergencia()
    Dim ws As Worksheet
    Dim caminhoCsv As String
    Dim f As Integer
    Dim linha As String
    Dim partes() As String
    Dim r As Long
    Dim desc As String
    Dim k As Long
    Dim primeiraLinha As Boolean
    Dim cnaeVal As String
    Dim sep As String
    Dim ultimaReal As Long
    Dim d As String
    Dim i As Long
    Dim ch As String

    sep = Application.PathSeparator

    ' 1) Achar o CSV.
    caminhoCsv = ThisWorkbook.Path & sep & "cnae_servicos_normalizado.csv"
    If Dir(caminhoCsv) = "" Then
        caminhoCsv = ThisWorkbook.Path & sep & "doc" & sep & "cnae-normalizado" & sep & "cnae_servicos_normalizado.csv"
    End If
    If Dir(caminhoCsv) = "" Then
        caminhoCsv = Application.GetOpenFilename("CSV (*.csv), *.csv", , "Selecione cnae_servicos_normalizado.csv")
        If caminhoCsv = "False" Or caminhoCsv = "Falso" Then Exit Sub
    End If

    MsgBox "CSV: " & caminhoCsv & vbCrLf & "Clique OK para importar.", vbInformation, "CNAE emergência"

    ' 2) Obter aba.
    Set ws = ThisWorkbook.Sheets(SHEET_ATIVIDADES)

    ' 3) Desproteger.
    Util_DesprotegerAbaComTentativas ws

    ' 4) Limpar filtros.
    On Error Resume Next
    If ws.AutoFilterMode Then ws.AutoFilter.ShowAllData
    On Error GoTo 0

    ' 5) Limpar TODA a area de dados.
    ultimaReal = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    If ultimaReal < 2000 Then ultimaReal = 2000
    ws.Range(ws.Cells(LINHA_DADOS, COL_ATIV_ID), ws.Cells(ultimaReal, COL_ATIV_DESCRICAO)).ClearContents
    ws.Cells(1, COL_CONTADOR_AR).Value = 0

    ' 6) Ler CSV e escrever.
    f = FreeFile
    Open caminhoCsv For Input As #f

    r = LINHA_DADOS
    primeiraLinha = True

    Do While Not EOF(f)
        Line Input #f, linha

        If primeiraLinha Then
            primeiraLinha = False
            GoTo proxLinha
        End If

        If Trim$(linha) = "" Then GoTo proxLinha

        partes = Split(linha, ",")
        If UBound(partes) < 2 Then GoTo proxLinha

        ' CNAE (coluna 1 do CSV) - normalizar para formato DDDD-D/DD.
        cnaeVal = Trim$(Replace(partes(1), """", ""))
        d = ""
        For i = 1 To Len(cnaeVal)
            ch = Mid$(cnaeVal, i, 1)
            If ch >= "0" And ch <= "9" Then d = d & ch
        Next i
        If Len(d) = 7 Then
            cnaeVal = Left$(d, 4) & "-" & Mid$(d, 5, 1) & "/" & Right$(d, 2)
        ElseIf Len(d) = 5 Then
            cnaeVal = Left$(d, 4) & "-" & Right$(d, 1)
        End If

        ' Descricao (coluna 2+ do CSV, pode conter virgulas).
        desc = ""
        For k = 2 To UBound(partes)
            If desc <> "" Then desc = desc & ","
            desc = desc & Trim$(Replace(partes(k), """", ""))
        Next k

        If cnaeVal = "" Or desc = "" Then GoTo proxLinha

        ' Escrever.
        ws.Cells(r, COL_ATIV_ID).NumberFormat = "@"
        ws.Cells(r, COL_ATIV_ID).Value = Format$(r - LINHA_DADOS + 1, "000")
        ws.Cells(r, COL_ATIV_CNAE).NumberFormat = "@"
        ws.Cells(r, COL_ATIV_CNAE).Value = cnaeVal
        ws.Cells(r, COL_ATIV_DESCRICAO).Value = desc
        r = r + 1

        If (r - LINHA_DADOS) Mod 100 = 0 Then
            Application.StatusBar = "Importando CNAE... " & (r - LINHA_DADOS)
            DoEvents
        End If

proxLinha:
    Loop

    Close #f

    ' 7) Atualizar contador.
    ws.Cells(1, COL_CONTADOR_AR).Value = r - LINHA_DADOS

    ' 8) Reproteger.
    On Error Resume Next
    ws.Protect Password:=Util_SenhaProtecaoPadrao(), UserInterfaceOnly:=True
    On Error GoTo 0

    ' 9) Invalidar cache e atualizar listas.
    Call InvalidarCacheCnaeAtividade

    Application.StatusBar = False
    MsgBox "IMPORTAÇÃO CONCLUÍDA: " & (r - LINHA_DADOS) & " registros." & vbCrLf & _
           "Formato CNAE: DDDD-D/DD (normalizado)" & vbCrLf & _
           "Fonte: " & caminhoCsv, vbInformation, "CNAE emergência"
End Sub

' ============================================================
' V12.0.0203 ONDA 2 - Snapshot + dedup do reset CNAE
' ============================================================
'
' Propósito: dar trilha auditavel ao reset CNAE sem mexer no nucleo
' do importador nem em Mod_Types.bas. Tres helpers publicos:
'
'   - CnaeSnapshotCadServ()       : copia CAD_SERV para uma aba
'                                   nova "CAD_SERV_SNAPSHOT_<ts>"
'                                   antes de qualquer limpeza.
'   - CnaeContarDuplicatasAtividades() : conta duplicatas exatas em
'                                   ATIVIDADES no par (CNAE, DESCRICAO).
'   - CnaeListarSnapshots()       : devolve as abas snapshot existentes
'                                   ordenadas por nome (timestamp).
'
' Sao chamados pelo ResetarECarregarCNAE_Padrao na ETAPA 9 e tambem
' pelos cenarios CNAE_001..003 da suite TV2_RunCnae.

Public Function CnaeSnapshotCadServ(Optional ByRef qtdLinhasOut As Long) As String
    Dim wsServ As Worksheet
    Dim wsSnap As Worksheet
    Dim ultima As Long
    Dim nomeSnap As String
    Dim sufixo As Long

    On Error GoTo falha
    qtdLinhasOut = 0

    Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    ultima = UltimaLinhaAba(SHEET_CAD_SERV)

    nomeSnap = SHEET_PREFIX_CAD_SERV_SNAP & Format$(Now, "yyyymmdd_hhnnss")
    ' Garante unicidade caso o reset rode duas vezes no mesmo segundo.
    sufixo = 0
    Do While CnaeAbaExiste(nomeSnap)
        sufixo = sufixo + 1
        nomeSnap = SHEET_PREFIX_CAD_SERV_SNAP & Format$(Now, "yyyymmdd_hhnnss") & "_" & Format$(sufixo, "00")
    Loop

    Set wsSnap = ThisWorkbook.Worksheets.Add( _
        After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
    wsSnap.Name = nomeSnap

    ' Copia integral (cabecalho + dados, com formatos), preservando
    ' a aba original. CopyDestination usa o range completo da fonte.
    If ultima >= 1 Then
        wsServ.Range(wsServ.Cells(1, COL_SERV_ID), _
                     wsServ.Cells(ultima, COL_SERV_DT_CAD)) _
              .Copy Destination:=wsSnap.Cells(1, COL_SERV_ID)
        Application.CutCopyMode = False
    End If

    If ultima >= LINHA_DADOS Then
        qtdLinhasOut = ultima - LINHA_DADOS + 1
    Else
        qtdLinhasOut = 0
    End If

    ' Snapshot sai protegido com a senha padrao para nao virar fonte
    ' de edicao acidental. Operador pode desproteger manualmente se
    ' precisar reaproveitar dados.
    On Error Resume Next
    wsSnap.Protect Password:=Util_SenhaProtecaoPadrao(), UserInterfaceOnly:=True
    On Error GoTo falha

    CnaeSnapshotCadServ = nomeSnap
    Exit Function

falha:
    On Error Resume Next
    Application.CutCopyMode = False
    On Error GoTo 0
    CnaeSnapshotCadServ = ""
    qtdLinhasOut = 0
End Function

Public Function CnaeContarDuplicatasAtividades() As Long
    Dim wsAtiv As Worksheet
    Dim ultima As Long
    Dim i As Long
    Dim cnaeVal As String
    Dim descVal As String
    Dim chave As String
    Dim mapa As Object
    Dim duplicatas As Long

    On Error GoTo falha

    Set wsAtiv = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
    ultima = UltimaLinhaAba(SHEET_ATIVIDADES)
    If ultima < LINHA_DADOS Then
        CnaeContarDuplicatasAtividades = 0
        Exit Function
    End If

    Set mapa = CreateObject("Scripting.Dictionary")
    duplicatas = 0

    For i = LINHA_DADOS To ultima
        cnaeVal = Trim$(CStr(wsAtiv.Cells(i, COL_ATIV_CNAE).Value))
        descVal = Trim$(CStr(wsAtiv.Cells(i, COL_ATIV_DESCRICAO).Value))
        If cnaeVal = "" And descVal = "" Then GoTo proximaLinha

        chave = UCase$(cnaeVal) & "|" & UCase$(descVal)
        If mapa.Exists(chave) Then
            duplicatas = duplicatas + 1
        Else
            mapa.Add chave, True
        End If

proximaLinha:
    Next i

    CnaeContarDuplicatasAtividades = duplicatas
    Exit Function

falha:
    CnaeContarDuplicatasAtividades = -1
End Function

Public Function CnaeListarSnapshots() As Variant
    Dim ws As Worksheet
    Dim nomes() As String
    Dim qtd As Long
    Dim i As Long
    Dim j As Long
    Dim tmp As String

    On Error GoTo falha

    qtd = 0
    ReDim nomes(0 To 0)
    For Each ws In ThisWorkbook.Worksheets
        If Left$(ws.Name, Len(SHEET_PREFIX_CAD_SERV_SNAP)) = SHEET_PREFIX_CAD_SERV_SNAP Then
            If qtd > 0 Then ReDim Preserve nomes(0 To qtd)
            nomes(qtd) = ws.Name
            qtd = qtd + 1
        End If
    Next ws

    If qtd = 0 Then
        CnaeListarSnapshots = Empty
        Exit Function
    End If

    ' Ordena por nome (timestamp) - bubble simples; n geralmente pequeno.
    For i = 0 To qtd - 2
        For j = i + 1 To qtd - 1
            If nomes(i) > nomes(j) Then
                tmp = nomes(i)
                nomes(i) = nomes(j)
                nomes(j) = tmp
            End If
        Next j
    Next i

    CnaeListarSnapshots = nomes
    Exit Function

falha:
    CnaeListarSnapshots = Empty
End Function

Private Function CnaeAbaExiste(ByVal nome As String) As Boolean
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets(nome)
    On Error GoTo 0
    CnaeAbaExiste = Not ws Is Nothing
End Function

' ============================================================
' V12.0.0203 ONDA 3 - Dedup automatico + housekeeping de snapshots
' ============================================================
'
' Decisoes de produto (registradas em CHANGELOG e auditoria/32):
'  - duplicatas detectadas em ATIVIDADES por (CNAE,DESCRICAO) sao
'    REMOVIDAS automaticamente (decisao do operador: foi um erro de
'    importacao remanescente, nao deve persistir);
'  - snapshots antigos sao podados quando o reset CNAE roda, com
'    confirmacao humana e mantendo os N mais recentes (default 5).
'
' Tres helpers publicos novos:
'  - CnaeRemoverDuplicatasAtividades() : remove fisicamente as
'    linhas duplicadas em ATIVIDADES por (CNAE, DESCRICAO),
'    preservando a primeira ocorrencia. Retorna quantidade removida.
'  - CnaePodarSnapshots(manterUltimos)  : apaga abas-snapshot mais
'    antigas, preservando as N mais recentes. Retorna quantidade
'    apagada.
'  - CnaeConfirmarPodaSnapshots(manterUltimos): wrapper interativo
'    com MsgBox; pergunta ao operador antes de podar. Usado pelo
'    reset CNAE no inicio da ETAPA 1.

Public Function CnaeRemoverDuplicatasAtividades() As Long
    Dim wsAtiv As Worksheet
    Dim ultima As Long
    Dim i As Long
    Dim cnaeVal As String
    Dim descVal As String
    Dim chave As String
    Dim mapa As Object
    Dim removidas As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim linhasParaRemover() As Long
    Dim qtdAlvo As Long

    On Error GoTo falha

    Set wsAtiv = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
    ultima = UltimaLinhaAba(SHEET_ATIVIDADES)
    If ultima < LINHA_DADOS Then
        CnaeRemoverDuplicatasAtividades = 0
        Exit Function
    End If

    Set mapa = CreateObject("Scripting.Dictionary")
    qtdAlvo = 0
    ReDim linhasParaRemover(0 To 0)

    ' Pass 1: identificar linhas duplicadas (preservando a primeira ocorrencia).
    For i = LINHA_DADOS To ultima
        cnaeVal = Trim$(CStr(wsAtiv.Cells(i, COL_ATIV_CNAE).Value))
        descVal = Trim$(CStr(wsAtiv.Cells(i, COL_ATIV_DESCRICAO).Value))
        If cnaeVal = "" And descVal = "" Then GoTo proxLinhaPass1

        chave = UCase$(cnaeVal) & "|" & UCase$(descVal)
        If mapa.Exists(chave) Then
            If qtdAlvo > 0 Then ReDim Preserve linhasParaRemover(0 To qtdAlvo)
            linhasParaRemover(qtdAlvo) = i
            qtdAlvo = qtdAlvo + 1
        Else
            mapa.Add chave, True
        End If
proxLinhaPass1:
    Next i

    If qtdAlvo = 0 Then
        CnaeRemoverDuplicatasAtividades = 0
        Exit Function
    End If

    ' Pass 2: remover linhas em ordem reversa para nao corromper indices.
    If Not Util_PrepararAbaParaEscrita(wsAtiv, estavaProtegida, senhaProtecao) Then
        CnaeRemoverDuplicatasAtividades = -1
        Exit Function
    End If

    removidas = 0
    For i = qtdAlvo - 1 To 0 Step -1
        wsAtiv.Rows(linhasParaRemover(i)).Delete
        removidas = removidas + 1
    Next i

    ' Atualiza contador da aba (linha 1, COL_CONTADOR_AR) considerando
    ' as linhas remanescentes apos a remocao. Se o contador anterior
    ' nao bater com o numero real, ajusta para o real.
    Dim ultimaPos As Long
    ultimaPos = UltimaLinhaAba(SHEET_ATIVIDADES)
    If ultimaPos >= LINHA_DADOS Then
        wsAtiv.Cells(1, COL_CONTADOR_AR).Value = ultimaPos - LINHA_DADOS + 1
    Else
        wsAtiv.Cells(1, COL_CONTADOR_AR).Value = 0
    End If

    Util_RestaurarProtecaoAba wsAtiv, estavaProtegida, senhaProtecao
    Call InvalidarCacheCnaeAtividade

    CnaeRemoverDuplicatasAtividades = removidas
    Exit Function

falha:
    On Error Resume Next
    If Not wsAtiv Is Nothing Then Util_RestaurarProtecaoAba wsAtiv, estavaProtegida, senhaProtecao
    On Error GoTo 0
    CnaeRemoverDuplicatasAtividades = -1
End Function

Public Function CnaePodarSnapshots(Optional ByVal manterUltimos As Long = 5) As Long
    Dim listSnaps As Variant
    Dim qtdSnaps As Long
    Dim qtdPodar As Long
    Dim i As Long
    Dim podadas As Long
    Dim nomeAlvo As String

    On Error GoTo falha

    If manterUltimos < 0 Then manterUltimos = 0

    listSnaps = CnaeListarSnapshots()
    If Not IsArray(listSnaps) Then
        CnaePodarSnapshots = 0
        Exit Function
    End If

    qtdSnaps = UBound(listSnaps) - LBound(listSnaps) + 1
    If qtdSnaps <= manterUltimos Then
        CnaePodarSnapshots = 0
        Exit Function
    End If

    qtdPodar = qtdSnaps - manterUltimos
    podadas = 0

    Application.DisplayAlerts = False
    For i = LBound(listSnaps) To LBound(listSnaps) + qtdPodar - 1
        nomeAlvo = CStr(listSnaps(i))
        On Error Resume Next
        ThisWorkbook.Worksheets(nomeAlvo).Delete
        If Err.Number = 0 Then podadas = podadas + 1
        Err.Clear
        On Error GoTo falha
    Next i
    Application.DisplayAlerts = True

    CnaePodarSnapshots = podadas
    Exit Function

falha:
    On Error Resume Next
    Application.DisplayAlerts = True
    On Error GoTo 0
    CnaePodarSnapshots = -1
End Function

Public Function CnaeConfirmarPodaSnapshots(Optional ByVal manterUltimos As Long = 5) As Long
    Dim listSnaps As Variant
    Dim qtdSnaps As Long
    Dim qtdExcedente As Long
    Dim resposta As VbMsgBoxResult

    On Error GoTo falha

    listSnaps = CnaeListarSnapshots()
    If Not IsArray(listSnaps) Then
        CnaeConfirmarPodaSnapshots = 0
        Exit Function
    End If

    qtdSnaps = UBound(listSnaps) - LBound(listSnaps) + 1
    If qtdSnaps <= manterUltimos Then
        CnaeConfirmarPodaSnapshots = 0
        Exit Function
    End If

    qtdExcedente = qtdSnaps - manterUltimos
    resposta = MsgBox( _
        "Existem " & qtdSnaps & " snapshots de CAD_SERV salvos no workbook." & vbCrLf & _
        "Deseja apagar os " & qtdExcedente & " mais antigos, mantendo apenas os " & _
        manterUltimos & " mais recentes?" & vbCrLf & vbCrLf & _
        "Resposta Nao preserva todos os snapshots existentes.", _
        vbQuestion + vbYesNo + vbDefaultButton1, _
        "Reset CNAE: limpeza de snapshots")

    If resposta = vbYes Then
        CnaeConfirmarPodaSnapshots = CnaePodarSnapshots(manterUltimos)
    Else
        CnaeConfirmarPodaSnapshots = 0
    End If
    Exit Function

falha:
    CnaeConfirmarPodaSnapshots = -1
End Function


