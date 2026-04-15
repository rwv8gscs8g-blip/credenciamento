VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Cadastro_Servico 
   Caption         =   "Cadastrar Servicos"
   ClientHeight    =   5341
   ClientLeft      =   119
   ClientTop       =   462
   ClientWidth     =   11550
   OleObjectBlob   =   "Cadastro_Servico.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "Cadastro_Servico"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False




Private mIgnorarFiltro As Boolean
Private WithEvents mTxtBuscaTopo As MSForms.TextBox
Attribute mTxtBuscaTopo.VB_VarHelpID = -1

Private Function UI_PegarTextBoxBuscaTopoDireita() As MSForms.TextBox
    Dim ctl As Object
    Dim melhor As MSForms.TextBox
    Dim leftMax As Double

    On Error GoTo fim

    leftMax = -1
    For Each ctl In Me.Controls
        If TypeName(ctl) = "TextBox" Then
            ' Campo pequeno no topo (busca incremental da lista).
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

Private Sub S_Cadastrar_SV_Click()
On Error GoTo erro_carregamento:

Dim wsServ As Worksheet
Dim wsAtiv As Worksheet
Dim descServ As String
Dim ativDesc As String
Dim ativId As String
Dim CNAE As String
Dim linhaNova As Long
Dim msgCriacaoAtiv As String
Dim estavaProtServ As Boolean
Dim senhaProtServ As String
Dim estavaProtAtiv As Boolean
Dim senhaProtAtiv As String
Dim msgSave As String

Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
Set wsAtiv = ThisWorkbook.Sheets(SHEET_ATIVIDADES)

descServ = Funcoes.NormalizarTextoPTBR(Descricao_SV.Value)
ativDesc = Funcoes.NormalizarTextoPTBR(S_Atividade.Value)

If descServ = "" Then
    MsgBox "Informe a descri" & ChrW(231) & ChrW(227) & "o do servi" & ChrW(231) & "o.", _
           vbExclamation, "Cadastro de serviço"
    Exit Sub
End If

' 1) Atividade selecionada na lista (fluxo normal)
If SV_Lista.ListIndex >= 0 Then
    ativId = Pad3(SV_Lista.Column(0))
    If ativDesc = "" Then ativDesc = Trim(CStr(SV_Lista.Column(2)))
End If

' 2) Base vazia/sem selecao: permite cadastro assistido de atividade + CNAE
If ativId = "" Then
    If ativDesc = "" Then
        MsgBox "Selecione uma atividade na lista ou preencha 'Descri" & ChrW(231) & ChrW(227) & "o Atividade'.", _
               vbExclamation, "Cadastro de serviço"
        Exit Sub
    End If

    Dim rngAtiv As Range
    Set rngAtiv = wsAtiv.Columns(3).Find(What:=ativDesc, LookAt:=xlWhole)
    If Not rngAtiv Is Nothing Then
        ativId = Pad3(rngAtiv.Offset(0, -2).Value)
    Else
        CNAE = Trim(InputBox("Atividade ainda não cadastrada." & vbCrLf & _
                             "Informe o CNAE para criar a atividade '" & ativDesc & "':", _
                             "Novo CNAE / Atividade"))
        If CNAE = "" Then
            MsgBox "Cadastro cancelado: CNAE é obrigatório para nova atividade.", vbExclamation, "Cadastro de serviço"
            Exit Sub
        End If

        If Not Util_PrepararAbaParaEscrita(wsAtiv, estavaProtAtiv, senhaProtAtiv) Then
            MsgBox "Não foi possível cadastrar nova atividade: aba ATIVIDADES protegida.", vbCritical, "Cadastro de serviço"
            Exit Sub
        End If

        ativId = ProximoId(SHEET_ATIVIDADES)
        linhaNova = UltimaLinhaAba(SHEET_ATIVIDADES) + 1
        If linhaNova < LINHA_DADOS Then linhaNova = LINHA_DADOS
        wsAtiv.Cells(linhaNova, 1).Value = ativId
        wsAtiv.Cells(linhaNova, 2).Value = Funcoes.NormalizarTextoPTBR(CNAE)
        wsAtiv.Cells(linhaNova, 3).Value = Funcoes.NormalizarTextoPTBR(ativDesc)
        Call Util_RestaurarProtecaoAba(wsAtiv, estavaProtAtiv, senhaProtAtiv)
        msgCriacaoAtiv = "Atividade/CNAE criada: " & ativId & " - " & CNAE & "." & vbCrLf
    End If
End If

' Evita duplicidade do mesmo servico na mesma atividade
If ServicoJaExiste(wsServ, ativId, descServ) Then
    If ativDesc = "" Then ativDesc = "(descrição da atividade não informada)"
    MsgBox "Não foi possível cadastrar: este serviço já existe para a atividade selecionada." & vbCrLf & _
           "Atividade: " & ativId & " - " & ativDesc & vbCrLf & _
           "Serviço: " & descServ & vbCrLf & _
           "Se necessário, atualize apenas o valor na tela principal.", _
           vbExclamation, "Cadastro de serviço"
    Exit Sub
End If

' Grava novo servico
If Not Util_PrepararAbaParaEscrita(wsServ, estavaProtServ, senhaProtServ) Then
    MsgBox "Não foi possível cadastrar serviço: aba CAD_SERV protegida.", vbCritical, "Cadastro de serviço"
    Exit Sub
End If

linhaNova = UltimaLinhaAba(SHEET_CAD_SERV) + 1
If linhaNova < LINHA_DADOS Then linhaNova = LINHA_DADOS

wsServ.Cells(linhaNova, COL_SERV_ID).Value = ProximoId(SHEET_CAD_SERV)
wsServ.Cells(linhaNova, COL_SERV_ATIV_ID).Value = ativId
wsServ.Cells(linhaNova, COL_SERV_ATIV_DESC).Value = Funcoes.NormalizarTextoPTBR(ativDesc)
wsServ.Cells(linhaNova, COL_SERV_DESCRICAO).Value = Funcoes.NormalizarTextoPTBR(descServ)
wsServ.Cells(linhaNova, COL_SERV_VALOR_UNIT).Value = 0#
wsServ.Cells(linhaNova, COL_SERV_VALOR_UNIT).NumberFormat = "_-R$ * #,##0.00_-;-R$ * #,##0.00_-;_-R$ * ""-""??_-;_-@_-"
wsServ.Cells(linhaNova, COL_SERV_DT_CAD).Value = CDate(Now)
Call Util_RestaurarProtecaoAba(wsServ, estavaProtServ, senhaProtServ)

Call ClassificaServico
Call PreenchimentoListaAtividade("", SV_Lista)
Call PreencherServicoFormatado
Call PreenchimentoServico
Call PreenchimentoCRServico

If Not Util_SalvarWorkbookSeguro(msgSave) Then
    MsgBox "Serviço cadastrado, mas houve falha ao salvar o arquivo automaticamente." & vbCrLf & _
           "Detalhe: " & msgSave & vbCrLf & _
           "Use Ctrl+S para salvar manualmente antes de continuar.", _
           vbExclamation, "Cadastro de serviço"
End If

    MsgBox msgCriacaoAtiv & "Servi" & ChrW(231) & "o cadastrado com sucesso." & vbCrLf & _
       "Defina o valor do servi" & ChrW(231) & "o na tela de manuten" & ChrW(231) & ChrW(227) & "o de valores.", _
       vbInformation, "Cadastro de serviço"
Unload Me
Exit Sub

erro_carregamento:
On Error Resume Next
If Not wsServ Is Nothing Then Call Util_RestaurarProtecaoAba(wsServ, estavaProtServ, senhaProtServ)
If Not wsAtiv Is Nothing Then Call Util_RestaurarProtecaoAba(wsAtiv, estavaProtAtiv, senhaProtAtiv)
On Error GoTo 0
MsgBox "Erro ao cadastrar servi" & ChrW(231) & "o: " & Err.Description, vbCritical, "Cadastro de serviço"
End Sub

Private Sub Descricao_SV_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir digitacao livre (compatibilidade)

Exit Sub
erro_carregamento:
End Sub

Private Sub Descricao_SV_AfterUpdate()
On Error GoTo erro_carregamento:
Descricao_SV.Value = Funcoes.NormalizarTextoPTBR(Descricao_SV.Value)
Exit Sub
erro_carregamento:
End Sub

Private Sub SV_Lista_Click()

Dim C_Atividade As String

On Error GoTo erro_carregamento:

  mIgnorarFiltro = True
  C_Atividade = SV_Lista.Column(0)
  S_Atividade = SV_Lista.Column(2)
  mIgnorarFiltro = False

Exit Sub
erro_carregamento:
  mIgnorarFiltro = False
End Sub

Private Sub S_Atividade_Change()
On Error GoTo erro_carregamento:

If mIgnorarFiltro Then Exit Sub
Call PreenchimentoListaAtividade(Trim$(CStr(S_Atividade.Value)), SV_Lista)

Exit Sub
erro_carregamento:
End Sub

Private Sub S_Atividade_AfterUpdate()
On Error GoTo erro_carregamento:
S_Atividade.Value = Funcoes.NormalizarTextoPTBR(S_Atividade.Value)
Exit Sub
erro_carregamento:
End Sub

Private Sub UserForm_Initialize()
On Error GoTo erro_carregamento:

mIgnorarFiltro = True
Me.Caption = "Cadastrar Servi" & ChrW(231) & "os"
Call GarantirAtividadesBase
Call PreenchimentoListaAtividade("", SV_Lista)
mIgnorarFiltro = False

' Busca incremental da lista (TextBox topo-direita).
Set mTxtBuscaTopo = UI_PegarTextBoxBuscaTopoDireita()
mIgnorarFiltro = True
If Not mTxtBuscaTopo Is Nothing Then mTxtBuscaTopo.Text = ""
mIgnorarFiltro = False

Exit Sub
erro_carregamento:
mIgnorarFiltro = False
End Sub

Private Sub mTxtBuscaTopo_Change()
On Error GoTo fim
If mIgnorarFiltro Then Exit Sub
Call PreenchimentoListaAtividade(Trim$(CStr(mTxtBuscaTopo.Text)), SV_Lista)
fim:
End Sub

Private Function ServicoJaExiste(ByVal wsServ As Worksheet, ByVal ativId As String, ByVal descServ As String) As Boolean
    Dim i As Long
    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_SERV)
        If Pad3(wsServ.Cells(i, COL_SERV_ATIV_ID).Value) = Pad3(ativId) And _
           UCase$(Trim$(CStr(wsServ.Cells(i, COL_SERV_DESCRICAO).Value))) = UCase$(Trim$(descServ)) Then
            ServicoJaExiste = True
            Exit Function
        End If
    Next i
    ServicoJaExiste = False
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


