VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Credencia_Empresa 
   ClientHeight    =   6090
   ClientLeft      =   119
   ClientTop       =   462
   ClientWidth     =   14280
   OleObjectBlob   =   "Credencia_Empresa.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "Credencia_Empresa"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False


Option Explicit

Private Const STATUS_CRED_ATIVO As String = "ATIVO"

Private mEmpIdSelecionado As String
Private mCnpjSelecionado As String
Private mRazaoSelecionada As String

Private WithEvents mTxtFiltroCredLista As MSForms.TextBox
Attribute mTxtFiltroCredLista.VB_VarHelpID = -1

Private Sub UserForm_Initialize()
    On Error Resume Next
    Call CR_EnsureFiltroListaDinamico
    Err.Clear
    On Error GoTo 0
End Sub

Private Sub CR_EnsureFiltroListaDinamico()
    Dim lblCr As Object
    On Error GoTo fim
    If Not mTxtFiltroCredLista Is Nothing Then Exit Sub
    On Error Resume Next
    Set mTxtFiltroCredLista = Me.Controls("TxtFiltro_CredenciamentoServico")
    If mTxtFiltroCredLista Is Nothing Then Set mTxtFiltroCredLista = Me.Controls("CR_TxtFiltroListaDin")
    On Error GoTo fim
    If mTxtFiltroCredLista Is Nothing Then
        Set mTxtFiltroCredLista = Me.Controls.Add("Forms.TextBox.1", "TxtFiltro_CredenciamentoServico", True)
        With mTxtFiltroCredLista
            .Top = CR_Lista.Top - 32
            .Left = CR_Lista.Left
            .Width = CR_Lista.Width
            .Height = 18
            .SpecialEffect = fmSpecialEffectSunken
            .Text = ""
            .Font.Size = 9
        End With
        Set lblCr = Me.Controls.Add("Forms.Label.1", "LblFiltro_CredenciamentoServico", True)
        With lblCr
            .Caption = "Buscar atividade / servi" & ChrW(231) & "o:"
            .Top = mTxtFiltroCredLista.Top - 16
            .Left = CR_Lista.Left
            .Width = CR_Lista.Width
            .Height = 12
            .BackStyle = fmBackStyleTransparent
            .Font.Bold = True
            .Font.Size = 8
        End With
    End If
fim:
End Sub

Private Sub mTxtFiltroCredLista_Change()
    If mTxtFiltroCredLista Is Nothing Then Exit Sub
    On Error Resume Next
    Call PreenchimentoCRServico(Me, mTxtFiltroCredLista.Text)
    On Error GoTo 0
End Sub

Private Sub CR_Credenciar_Click()
On Error GoTo erro_carregamento:

Dim wsCred As Worksheet
Dim wsServ As Worksheet
Dim ativId As String
Dim ativDesc As String
Dim empId As String
Dim cnpj As String
Dim razao As String
Dim i As Long
Dim totalServ As Long
Dim adicionados As Long
Dim ignorados As Long
Dim faltantes As String
    Dim codAtivServ As String
    Dim servId As String
    Dim credId As String
    Dim linhaNova As Long
    Dim posNova As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim msgSave As String

Set wsCred = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)

empId = Pad3(mEmpIdSelecionado)
If empId = "" Then empId = Pad3(M_ID_Empresa)

cnpj = Trim$(mCnpjSelecionado)
If cnpj = "" Then cnpj = Trim$(CStr(CR_CNPJ.Value))

razao = Funcoes.NormalizarTextoPTBR(mRazaoSelecionada)
If razao = "" Then razao = Funcoes.NormalizarTextoPTBR(CR_Empresa.Value)

If empId = "" Then
    MsgBox "Selecione uma empresa antes de credenciar.", vbExclamation, "Credenciamento"
    Exit Sub
End If

If Not CarregarDadosEmpresaSelecionada(empId, cnpj, razao) Then
    MsgBox "Empresa selecionada não foi encontrada em EMPRESAS. Selecione novamente na lista principal.", vbCritical, "Credenciamento"
    Exit Sub
End If

CR_CNPJ.Value = cnpj
CR_Empresa.Value = razao

If CR_Lista.ListIndex < 0 Then
    MsgBox "Selecione uma atividade para credenciamento.", vbExclamation, "Credenciamento"
    Exit Sub
End If

ativId = Pad3(CR_Lista.Column(1))
ativDesc = Trim$(CStr(CR_Lista.Column(2)))
If ativId = "" Then
    MsgBox "Atividade inválida para credenciamento.", vbExclamation, "Credenciamento"
    Exit Sub
End If
If ativDesc = "" Then ativDesc = "(Sem descrição)"

If Not Util_PrepararAbaParaEscrita(wsCred, estavaProtegida, senhaProtecao) Then
    MsgBox "Não foi possível credenciar: aba CREDENCIADOS protegida.", vbCritical, "Credenciamento"
    Exit Sub
End If

' Credencia a empresa em TODOS os servicos da atividade (regra de negocio).
For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_SERV)
    If IdsIguaisCred(wsServ.Cells(i, COL_SERV_ATIV_ID).Value, ativId) Then
        totalServ = totalServ + 1
        servId = Pad3(wsServ.Cells(i, COL_SERV_ID).Value)
        codAtivServ = ativId & servId

        If Not CredJaExiste(wsCred, codAtivServ, empId) Then
            linhaNova = UltimaLinhaAba(SHEET_CREDENCIADOS) + 1
            If linhaNova < LINHA_DADOS Then linhaNova = LINHA_DADOS

            posNova = ProximaPosicaoAtividade(wsCred, ativId)
            credId = ProximoId(SHEET_CREDENCIADOS)

            wsCred.Cells(linhaNova, COL_CRED_ID).Value = credId
            wsCred.Cells(linhaNova, COL_CRED_COD_ATIV_SERV).Value = codAtivServ
            wsCred.Cells(linhaNova, COL_CRED_EMP_ID).Value = empId
            wsCred.Cells(linhaNova, COL_CRED_CNPJ).Value = cnpj
            wsCred.Cells(linhaNova, COL_CRED_RAZAO).Value = razao
            wsCred.Cells(linhaNova, COL_CRED_POSICAO).Value = posNova
            wsCred.Cells(linhaNova, COL_CRED_ULT_OS).Value = ""
            wsCred.Cells(linhaNova, COL_CRED_DT_ULT_OS).Value = ""
            wsCred.Cells(linhaNova, COL_CRED_INATIVO_FLAG).Value = ""
            wsCred.Cells(linhaNova, COL_CRED_ATIV_ID).Value = ativId
            wsCred.Cells(linhaNova, COL_CRED_RECUSAS).Value = 0
            wsCred.Cells(linhaNova, COL_CRED_EXPIRACOES).Value = 0
            wsCred.Cells(linhaNova, COL_CRED_STATUS).Value = STATUS_CRED_ATIVO
            wsCred.Cells(linhaNova, COL_CRED_DT_ULT_IND).Value = ""
            wsCred.Cells(linhaNova, COL_CRED_DT_CRED).Value = CDate(Now)

            RegistrarEvento _
                EVT_CRED_ATIV, ENT_CRED, credId, _
                "", _
                "EMP_ID=" & empId & "; ATIV_ID=" & ativId & "; SERV_ID=" & servId & "; POS=" & CStr(posNova), _
                "Credencia_Empresa"
            adicionados = adicionados + 1
        Else
            ignorados = ignorados + 1
        End If
    End If
Next i

If totalServ = 0 Then
    Call Util_RestaurarProtecaoAba(wsCred, estavaProtegida, senhaProtecao)
    MsgBox "Não há serviços cadastrados para esta atividade. Cadastre serviços primeiro.", vbExclamation, "Credenciamento"
    Exit Sub
End If

Call ClassificaCredenciadoOrdem
Call AtualizarListaEmpresaMenuAtual

If Not ValidarPersistenciaCredenciamento(wsCred, wsServ, empId, ativId, faltantes) Then
    Call Util_RestaurarProtecaoAba(wsCred, estavaProtegida, senhaProtecao)
    MsgBox "Falha de persistência no credenciamento da atividade " & ativId & "." & vbCrLf & _
           "Serviços sem registro para a empresa: " & faltantes, vbCritical, "Credenciamento"
    Exit Sub
End If

Call Util_RestaurarProtecaoAba(wsCred, estavaProtegida, senhaProtecao)

If Not Util_SalvarWorkbookSeguro(msgSave) Then
    MsgBox "Credenciamento concluído, mas houve falha ao salvar o arquivo automaticamente." & vbCrLf & _
           "Detalhe: " & msgSave & vbCrLf & _
           "Use Ctrl+S para salvar manualmente antes de continuar.", _
           vbExclamation, "Credenciamento"
End If

If adicionados > 0 Then
    MsgBox "Credenciamento realizado por atividade." & vbCrLf & _
           "Atividade: " & ativDesc & "." & vbCrLf & _
           "A empresa foi credenciada em todos os serviços desta atividade." & vbCrLf & _
           "Novos credenciamentos: " & adicionados & _
           IIf(ignorados > 0, vbCrLf & "Já existentes (ignorados): " & ignorados, ""), _
           vbInformation, "Credenciamento"
Else
    MsgBox "A empresa já estava credenciada em todos os serviços da atividade " & ativDesc & ".", _
           vbInformation, "Credenciamento"
End If

Empresa_CNPJ = Empty
M_NomeEmpresa = Empty
M_ID_Empresa = Empty
mEmpIdSelecionado = ""
mCnpjSelecionado = ""
mRazaoSelecionada = ""
Unload Me
Exit Sub

erro_carregamento:
On Error Resume Next
If Not wsCred Is Nothing Then Call Util_RestaurarProtecaoAba(wsCred, estavaProtegida, senhaProtecao)
On Error GoTo 0
MsgBox "Erro ao credenciar empresa: " & Err.Description, vbCritical, "Credenciamento"
End Sub

Private Sub CR_Lista_Click()
On Error GoTo erro_carregamento:
If Trim$(mCnpjSelecionado) <> "" Then
    CR_CNPJ = mCnpjSelecionado
Else
    CR_CNPJ = Empresa_CNPJ
End If

If Trim$(mRazaoSelecionada) <> "" Then
    CR_Empresa = mRazaoSelecionada
Else
    CR_Empresa = M_NomeEmpresa
End If

CR_Atividade = CR_Lista.Column(2)
CR_Servico = CR_Lista.Column(3)

Exit Sub
erro_carregamento:
End Sub

Public Sub DefinirEmpresaSelecionada(ByVal empId As String, ByVal cnpj As String, ByVal razao As String)
    mEmpIdSelecionado = Pad3(empId)
    mCnpjSelecionado = Trim$(CStr(cnpj))
    mRazaoSelecionada = Funcoes.NormalizarTextoPTBR(razao)

    If mCnpjSelecionado <> "" Then CR_CNPJ.Value = mCnpjSelecionado
    If mRazaoSelecionada <> "" Then CR_Empresa.Value = mRazaoSelecionada
End Sub

Public Sub PrepararListaCredenciamentoServico()
    With CR_Lista
        .Clear
        .RowSource = vbNullString
        .ColumnCount = 9
        ' V12.0.0010: col0=ID(30) visivel, col1=AtivID(0), col2=Atividade(300), col3=Servico(200), col4=Valor(70)
        .ColumnWidths = "30; 0; 300; 200; 70; 0; 0; 0; 0"
    End With
End Sub

Public Sub DefinirListaCredenciamentoServico(ByRef valores As Variant)
    CR_Lista.List = valores
End Sub

Private Function CredJaExiste(ByVal wsCred As Worksheet, ByVal codAtivServ As String, ByVal empId As String) As Boolean
    Dim i As Long
    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If NormalizarCodAtivServ(wsCred.Cells(i, COL_CRED_COD_ATIV_SERV).Value) = NormalizarCodAtivServ(codAtivServ) And _
           IdsIguaisCred(wsCred.Cells(i, COL_CRED_EMP_ID).Value, empId) Then
            CredJaExiste = True
            Exit Function
        End If
    Next i
    CredJaExiste = False
End Function

Private Function NormalizarCodAtivServ(ByVal v As Variant) As String
    Dim s As String
    s = Trim$(CStr(v))
    s = Replace(s, " ", "")
    If s = "" Then
        NormalizarCodAtivServ = ""
    ElseIf IsNumeric(s) Then
        NormalizarCodAtivServ = Format$(CLng(Val(s)), "000000")
    Else
        NormalizarCodAtivServ = UCase$(s)
    End If
End Function

Private Function ProximaPosicaoAtividade(ByVal wsCred As Worksheet, ByVal ativId As String) As Long
    Dim i As Long
    Dim maxPos As Long
    Dim pos As Long

    maxPos = 0
    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If IdsIguaisCred(wsCred.Cells(i, COL_CRED_ATIV_ID).Value, ativId) Then
            pos = CLng(Val(wsCred.Cells(i, COL_CRED_POSICAO).Value))
            If pos > maxPos Then maxPos = pos
        End If
    Next i
    ProximaPosicaoAtividade = maxPos + 1
End Function

Private Function CarregarDadosEmpresaSelecionada(ByVal empId As String, ByRef cnpj As String, ByRef razao As String) As Boolean
    Dim wsEmp As Worksheet
    Dim i As Long

    Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    For i = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
        If IdsIguaisCred(wsEmp.Cells(i, COL_EMP_ID).Value, empId) Then
            cnpj = Trim$(SafeListVal(wsEmp.Cells(i, COL_EMP_CNPJ).Value))
            razao = Funcoes.NormalizarTextoPTBR(SafeListVal(wsEmp.Cells(i, COL_EMP_RAZAO).Value))
            CarregarDadosEmpresaSelecionada = True
            Exit Function
        End If
    Next i
End Function

Private Function ValidarPersistenciaCredenciamento( _
    ByVal wsCred As Worksheet, _
    ByVal wsServ As Worksheet, _
    ByVal empId As String, _
    ByVal ativId As String, _
    ByRef faltantes As String _
) As Boolean
    Dim i As Long
    Dim codAtivServ As String
    Dim servId As String
    Dim totalEsperado As Long
    Dim totalEncontrado As Long

    faltantes = ""

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_SERV)
        If IdsIguaisCred(wsServ.Cells(i, COL_SERV_ATIV_ID).Value, ativId) Then
            totalEsperado = totalEsperado + 1
            servId = Pad3(wsServ.Cells(i, COL_SERV_ID).Value)
            codAtivServ = Pad3(ativId) & servId
            If CredJaExiste(wsCred, codAtivServ, empId) Then
                totalEncontrado = totalEncontrado + 1
            Else
                If faltantes <> "" Then faltantes = faltantes & ", "
                faltantes = faltantes & servId
            End If
        End If
    Next i

    ValidarPersistenciaCredenciamento = (totalEsperado > 0 And totalEsperado = totalEncontrado)
End Function

Private Function IdsIguaisCred(ByVal a As Variant, ByVal b As Variant) As Boolean
    Dim sA As String
    Dim sB As String

    sA = Trim$(CStr(a))
    sB = Trim$(CStr(b))
    If sA = "" Or sB = "" Then Exit Function

    If IsNumeric(sA) And IsNumeric(sB) Then
        IdsIguaisCred = (CLng(Val(sA)) = CLng(Val(sB)))
    Else
        IdsIguaisCred = (StrComp(sA, sB, vbTextCompare) = 0)
    End If
End Function

Private Function Pad3(ByVal v As Variant) As String
    Dim s As String
    s = Trim$(CStr(v))
    If s = "" Then
        Pad3 = ""
    ElseIf IsNumeric(s) Then
        Pad3 = Format$(CLng(Val(s)), "000")
    Else
        Pad3 = s
    End If
End Function

