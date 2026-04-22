VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Menu_Principal 
   ClientHeight    =   8911.001
   ClientLeft      =   119
   ClientTop       =   462
   ClientWidth     =   16695
   OleObjectBlob   =   "Menu_Principal.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "Menu_Principal"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
















Option Explicit

' =========================
' Acoes dinamicas na UI
' =========================
' Pre-OS/OS: BT_PREOS_* e BT_OS_CANCELAR sao fisicos no designer (sem Controls.Add).

' Filtros Dinâmicos (MI-09 e MI-10 + busca Empresa/Entidade pós-14h)
Private WithEvents mTxtFiltroRodizio As MSForms.TextBox
Attribute mTxtFiltroRodizio.VB_VarHelpID = -1
Private WithEvents mTxtFiltroServico As MSForms.TextBox
Attribute mTxtFiltroServico.VB_VarHelpID = -1
Private WithEvents mTxtFiltroEmpresa As MSForms.TextBox
Attribute mTxtFiltroEmpresa.VB_VarHelpID = -1
Private WithEvents mTxtFiltroEntidade As MSForms.TextBox
Attribute mTxtFiltroEntidade.VB_VarHelpID = -1
Private WithEvents mTxtFiltroCadServ As MSForms.TextBox
Attribute mTxtFiltroCadServ.VB_VarHelpID = -1
Private mInicializando As Boolean
Private Const SHEET_REL_UI As String = "RELATORIO"
Private Const PRAZO_PADRAO_OS_DIAS As Long = 30

' Chamada pela Central de Testes antes da bateria oficial: foco na planilha.
Public Sub Menu_RecolherParaBateria()
    Dim i As Long

    On Error Resume Next
    Me.Hide
    DoEvents
    For i = VBA.UserForms.Count - 1 To 0 Step -1
        If TypeName(VBA.UserForms(i)) = "Menu_Principal" Then
            VBA.UserForms(i).Hide
            Unload VBA.UserForms(i)
        End If
    Next i
    Application.Visible = True
    ThisWorkbook.Activate
    DoEvents
End Sub

Private Sub AlinharCabecalhosListaEmpresa()
    ' Fonte unica de textos: designer (.frx). Nao sobrescrever captions de labels
    ' (ex.: Razao Social / Nome do Empresario / CNPJ) em runtime.
End Sub

Private Sub Tela_Inicial()
On Error GoTo erro_carregamento:

    'Ativar Botes
        B_Home.BackStyle = fmBackStyleOpaque
        B_Entidade.BackStyle = fmBackStyleTransparent
        B_Empresa_Cadastro.BackStyle = fmBackStyleTransparent
        B_Empresa_Rodizio.BackStyle = fmBackStyleTransparent
        B_Emite_OS.BackStyle = fmBackStyleTransparent
        B_Empresa_Avaliacao.BackStyle = fmBackStyleTransparent
        B_Relatorios.BackStyle = fmBackStyleTransparent
        
        PAGINAS.Value = 0
        
Exit Sub
erro_carregamento:
End Sub
Private Sub AV_Lista_Click()
On Error GoTo erro_carregamento
If AV_Lista.ListIndex < 0 Then Exit Sub

AVCNPJ = AVListaCol(8)
AVEmpresa = AVListaCol(3)
AV_DataFechamento.SetFocus

Exit Sub
erro_carregamento:
End Sub
Private Sub AV_Vl_OS_AfterUpdate()
On Error GoTo erro_carregamento:
AV_Vl_OS = Format(AV_Vl_OS, "currency")
erro_carregamento:
End Sub
Private Sub B_Home_Click()
On Error GoTo erro_carregamento:

    'Ativar Botes
        B_Home.BackStyle = fmBackStyleOpaque
        B_Entidade.BackStyle = fmBackStyleTransparent
        B_Empresa_Cadastro.BackStyle = fmBackStyleTransparent
        B_Empresa_Rodizio.BackStyle = fmBackStyleTransparent
        B_Emite_OS.BackStyle = fmBackStyleTransparent
        B_Empresa_Avaliacao.BackStyle = fmBackStyleTransparent
        B_CAD_SERV.BackStyle = fmBackStyleTransparent
        B_Relatorios.BackStyle = fmBackStyleTransparent

        PAGINAS.Value = 0
        
Exit Sub
erro_carregamento:
End Sub

Private Sub A_Excluir_Click()
On Error GoTo erro_carregamento:
    ' V12: eliminado .Select + Application.GoTo + ActiveCell (proibidos; formulario modal).
    ' Opera diretamente na celula encontrada via .Find.
    Dim wsAtiv As Worksheet
    Dim estavaProtAtiv As Boolean
    Dim senhaAtiv As String

    Set wsAtiv = ThisWorkbook.Sheets("ATIVIDADE ESCOLHIDA")
    With wsAtiv.Range("D:D")
        Set EncontrarID = .Find(What:=A_Lista.Column(3), LookAt:=xlWhole)
        If Not EncontrarID Is Nothing Then
            Call Util_PrepararAbaParaEscrita(wsAtiv, estavaProtAtiv, senhaAtiv)
            EncontrarID.EntireRow.Delete
            Call Util_RestaurarProtecaoAba(wsAtiv, estavaProtAtiv, senhaAtiv)
        End If
    End With

    A_Lista.Clear
    Call PreenchimentoEscolhaAtividade

Exit Sub
erro_carregamento:
End Sub

Private Sub B_Config_Inicial_Click()
On Error GoTo erro_carregamento:
    Dim frmConfiguracao As Object

    Call UI_DescartarFormVisivel("Configuracao_Inicial")
    Set frmConfiguracao = VBA.UserForms.Add("Configuracao_Inicial")
    frmConfiguracao.Show vbModal
    Exit Sub
erro_carregamento:
    MsgBox "Erro ao abrir Configura" & ChrW(231) & ChrW(245) & "es Iniciais: " & Err.Description, _
           vbCritical, "Configura" & ChrW(231) & ChrW(245) & "es Iniciais"
End Sub

Private Sub B_Entidade_Click()
On Error GoTo erro_carregamento:

    'Ativar Botes
        B_Home.BackStyle = fmBackStyleTransparent
        B_Entidade.BackStyle = fmBackStyleOpaque
        B_Empresa_Cadastro.BackStyle = fmBackStyleTransparent
        B_Empresa_Rodizio.BackStyle = fmBackStyleTransparent
        B_Emite_OS.BackStyle = fmBackStyleTransparent
        B_Empresa_Avaliacao.BackStyle = fmBackStyleTransparent
        B_CAD_SERV.BackStyle = fmBackStyleTransparent
        B_Relatorios.BackStyle = fmBackStyleTransparent

        PAGINAS.Value = 1

        ' V12.0.0010: garantir campos de telefone visiveis e sem sobreposicao.
        On Error Resume Next
        If C_Tel_Fixo.Width < 60 Then C_Tel_Fixo.Width = 120
        C_Tel_Fixo.Visible = True
        If C_Tel_Cel.Width < 60 Then C_Tel_Cel.Width = 120
        C_Tel_Cel.Visible = True
        ' Reposicionar Tel_Cel para nao sobrepor Tel_Fixo
        If Abs(C_Tel_Cel.Left - C_Tel_Fixo.Left) < 10 Then
            C_Tel_Cel.Left = C_Tel_Fixo.Left + C_Tel_Fixo.Width + 10
        End If
        On Error GoTo erro_carregamento:

Exit Sub
erro_carregamento:
End Sub

Private Sub B_Empresa_Cadastro_Click()
On Error GoTo erro_carregamento:

    'Ativar Botes
        B_Home.BackStyle = fmBackStyleTransparent
        B_Entidade.BackStyle = fmBackStyleTransparent
        B_Empresa_Cadastro.BackStyle = fmBackStyleOpaque
        B_Empresa_Rodizio.BackStyle = fmBackStyleTransparent
        B_Emite_OS.BackStyle = fmBackStyleTransparent
        B_Empresa_Avaliacao.BackStyle = fmBackStyleTransparent
        B_CAD_SERV.BackStyle = fmBackStyleTransparent
        B_Relatorios.BackStyle = fmBackStyleTransparent

        PAGINAS.Value = 2
        Call AlinharCabecalhosListaEmpresa
        
Exit Sub
erro_carregamento:
End Sub

Private Sub B_Empresa_Rodizio_Click()
On Error GoTo erro_carregamento:

    'Ativar Botes
        B_Home.BackStyle = fmBackStyleTransparent
        B_Entidade.BackStyle = fmBackStyleTransparent
        B_Empresa_Cadastro.BackStyle = fmBackStyleTransparent
        B_Empresa_Rodizio.BackStyle = fmBackStyleOpaque
        B_Emite_OS.BackStyle = fmBackStyleTransparent
        B_Empresa_Avaliacao.BackStyle = fmBackStyleTransparent
        B_Relatorios.BackStyle = fmBackStyleTransparent

        PAGINAS.Value = 3
        Call AplicarFiltrosAtribuicao

Exit Sub
erro_carregamento:
End Sub
Private Sub B_Emite_OS_Click()

'Ativar Botes
        B_Home.BackStyle = fmBackStyleTransparent
        B_Entidade.BackStyle = fmBackStyleTransparent
        B_Empresa_Cadastro.BackStyle = fmBackStyleTransparent
        B_Empresa_Rodizio.BackStyle = fmBackStyleTransparent
        B_Emite_OS.BackStyle = fmBackStyleOpaque
        B_Empresa_Avaliacao.BackStyle = fmBackStyleTransparent
        B_CAD_SERV.BackStyle = fmBackStyleTransparent
        B_Relatorios.BackStyle = fmBackStyleTransparent

        PAGINAS.Value = 4
        Call PreencherPreencheOS

End Sub

Private Sub B_Empresa_Avaliacao_Click()
On Error GoTo erro_carregamento:
   
        B_Home.BackStyle = fmBackStyleTransparent
        B_Entidade.BackStyle = fmBackStyleTransparent
        B_Empresa_Cadastro.BackStyle = fmBackStyleTransparent
        B_Empresa_Rodizio.BackStyle = fmBackStyleTransparent
        B_Emite_OS.BackStyle = fmBackStyleTransparent
        B_Empresa_Avaliacao.BackStyle = fmBackStyleOpaque
        B_CAD_SERV.BackStyle = fmBackStyleTransparent
        B_Relatorios.BackStyle = fmBackStyleTransparent
    
        PAGINAS.Value = 5
        
Exit Sub
erro_carregamento:
End Sub
Private Sub B_CAD_SERV_Click()
On Error GoTo erro_carregamento:
   
        B_Home.BackStyle = fmBackStyleTransparent
        B_Entidade.BackStyle = fmBackStyleTransparent
        B_Empresa_Cadastro.BackStyle = fmBackStyleTransparent
        B_Empresa_Rodizio.BackStyle = fmBackStyleTransparent
        B_Emite_OS.BackStyle = fmBackStyleTransparent
        B_Empresa_Avaliacao.BackStyle = fmBackStyleTransparent
        B_CAD_SERV.BackStyle = fmBackStyleOpaque
        B_Relatorios.BackStyle = fmBackStyleTransparent

        PAGINAS.Value = 6
        If mTxtFiltroCadServ Is Nothing Then
            Call PreencherManutencaoValor
        Else
            Call PreencherManutencaoValor(mTxtFiltroCadServ.Text)
        End If

Exit Sub
erro_carregamento:
End Sub
Private Sub B_Relatorios_Click()
On Error GoTo erro_carregamento:
   
        B_Home.BackStyle = fmBackStyleTransparent
        B_Entidade.BackStyle = fmBackStyleTransparent
        B_Empresa_Cadastro.BackStyle = fmBackStyleTransparent
        B_Empresa_Rodizio.BackStyle = fmBackStyleTransparent
        B_Emite_OS.BackStyle = fmBackStyleTransparent
        B_Empresa_Avaliacao.BackStyle = fmBackStyleTransparent
        B_CAD_SERV.BackStyle = fmBackStyleTransparent
        B_Relatorios.BackStyle = fmBackStyleOpaque
    
        PAGINAS.Value = 7
        
Exit Sub
erro_carregamento:
End Sub

Private Sub UI_DescartarFormVisivel(ByVal nomeFormulario As String)
    Dim frm As Object

    On Error Resume Next
    For Each frm In VBA.UserForms
        If TypeName(frm) = nomeFormulario Then
            If frm.Visible Then Unload frm
        End If
    Next frm
    On Error GoTo 0
End Sub

Private Sub B_ReativaEntidade_Click()
On Error GoTo erro_carregamento:
    Dim frmReativaEntidade As Object

    ' Nao chamar PreenchimentoEntidadeInativa aqui: o UserForm ainda nao existe e
    ' ControleFormulario pode acoplar a uma instancia antiga (nao visivel) do Reativa_Entidade,
    ' gerando lista duplicada/inconsistente com a instancia exibida pelo UserForms.Add.
    If ContarLinhasEntidadeInativasValidas() <= 0 Then
        MsgBox "N" & ChrW(227) & "o h" & ChrW(225) & " entidade inativa para reativar.", _
               vbInformation, "Reativa" & ChrW(231) & ChrW(227) & "o de Entidade"
    Else
        Call UI_DescartarFormVisivel("Reativa_Entidade")
        Set frmReativaEntidade = VBA.UserForms.Add("Reativa_Entidade")
        frmReativaEntidade.Show vbModal
        Call AtualizarListaEntidadeMenuAtual
    End If
    Exit Sub
erro_carregamento:
    MsgBox "Erro ao abrir reativa" & ChrW(231) & ChrW(227) & "o de entidade: " & Err.Description, _
           vbCritical, "Reativa" & ChrW(231) & ChrW(227) & "o"
End Sub

Private Sub B_Reativa_Empresa_Click()
On Error GoTo erro_carregamento:
    Dim frmReativaEmpresa As Object

    If ContarLinhasEmpresaInativasValidas() <= 0 Then
        MsgBox "N" & ChrW(227) & "o h" & ChrW(225) & " empresa inativa para reativar.", _
               vbInformation, "Reativa" & ChrW(231) & ChrW(227) & "o de Empresa"
    Else
        Call UI_DescartarFormVisivel("Reativa_Empresa")
        Set frmReativaEmpresa = VBA.UserForms.Add("Reativa_Empresa")
        frmReativaEmpresa.Show vbModal
        Call AtualizarListaEmpresaMenuAtual
    End If
    Exit Sub
erro_carregamento:
    MsgBox "Erro ao abrir reativa" & ChrW(231) & ChrW(227) & "o de empresa: " & Err.Description, _
           vbCritical, "Reativa" & ChrW(231) & ChrW(227) & "o"
End Sub

Private Sub BE_ImprimeOS_Click()
    On Error GoTo Erro

    If Not ErrorBoundary.BeginWrite("EMISSAO_OS") Then Exit Sub

    ' 1. Validar selecao
    Dim preosId As String
    If OS_Lista.ListIndex < 0 Then
        MsgBox "Selecione uma Pre-OS para emitir a OS.", vbExclamation, "Emitir OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    preosId = OSListaCol(0)
    If Trim(preosId) = "" Then
        MsgBox "Selecione uma Pre-OS para emitir a OS.", vbExclamation, "Emitir OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    ' 2. Preparar parametros  validacao explicita
    Dim dtPrev As Date
    If Trim$(CStr(OS_DT_Fim.Value)) = "" Then
        dtPrev = DateAdd("d", PrazoPadraoOSDias(), Date)
        OS_DT_Fim.Value = Format$(dtPrev, "DD/MM/YYYY")
    ElseIf Not TryParseDataBR(CStr(OS_DT_Fim.Value), dtPrev) Then
        MsgBox "Data prevista de término inválida. Use o formato DD/MM/AAAA.", vbExclamation, "Emitir OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    ElseIf dtPrev < Date Then
        MsgBox "Data prevista de término não pode ser anterior a hoje.", vbExclamation, "Emitir OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    If Trim$(CStr(OS_QT_Estimada.Value)) = "" Or _
       Util_Conversao.ToDouble(CStr(OS_QT_Estimada.Value)) <= 0 Then
        OS_QT_Estimada.Value = "1"
    End If

    Dim numEmp As String
    numEmp = Trim$(CStr(N_Empenho.Value))
    If numEmp = "" Then
        numEmp = GerarEmpenhoPadrao(preosId)
        N_Empenho.Value = numEmp
    End If

    If MsgBox("A ação 'Aceitar e Emitir OS' vai converter a Pre-OS e avançar a fila agora." & vbCrLf & _
              "Esta operação não depende da impressão." & vbCrLf & vbCrLf & _
              "Deseja continuar?", vbQuestion + vbYesNo, "Aceitar e Emitir OS") <> vbYes Then
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    ' 3. Chamar Svc_OS.EmitirOS
    Dim res As TResult
    res = EmitirOS(preosId, dtPrev, numEmp)

    If Not res.Sucesso Then
        MsgBox "Erro ao emitir OS: " & res.mensagem, vbCritical, "Emitir OS"
        ErrorBoundary.RollbackWrite silent:=True
        GoTo LimparFalha
    End If

    ' 4. Sucesso: preparar globais para template de impressao
    N_OS = res.IdGerado
    Empresa_CNPJ = OS_CNPJ
    M_NomeEmpresa = TXT_OS_NomeEmpresa
    Desc_entidade = OS_Demandante
    Desc_Ativi = OS_Atividade
    Desc_Serv = OS_Servico

    QT_ESTIMADA = Util_Conversao.ToDouble(CStr(OS_QT_Estimada.Value))
    If QT_ESTIMADA <= 0 Then QT_ESTIMADA = 1
    Vl_estimado = CDbl(QT_ESTIMADA * VL_Pagto)
    NR_Empenho = N_Empenho

    ' Buscar contato da entidade (mantem logica original sem Sheets.Select)
    Dim wsEnt As Worksheet
    Set wsEnt = ThisWorkbook.Sheets(SHEET_ENTIDADE)
    Dim idxEnt As Long
    For idxEnt = LINHA_DADOS To UltimaLinhaAba(SHEET_ENTIDADE)
        If IdsIguais(SafeListVal(wsEnt.Cells(idxEnt, COL_ENT_ID).Value), OSListaCol(6)) Then
            cont_entidade = SafeListVal(wsEnt.Cells(idxEnt, COL_ENT_CONT1_NOME).Value)
            telcont_entidade = SafeListVal(wsEnt.Cells(idxEnt, COL_ENT_CONT1_FONE).Value)
            Exit For
        End If
    Next idxEnt

    ' Buscar dados da empresa em EMPRESAS (V10: nao mais em Empresa)
    Dim wsEmp As Worksheet
    Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    Dim idxEmp As Long
    For idxEmp = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
        If IdsIguais(SafeListVal(wsEmp.Cells(idxEmp, COL_EMP_ID).Value), OSListaCol(9)) Then
            Empresa_endereco = SafeListVal(wsEmp.Cells(idxEmp, COL_EMP_ENDERECO).Value)
            Empresa_TelCel = SafeListVal(wsEmp.Cells(idxEmp, COL_EMP_TEL_CEL).Value)
            Empresa_email = SafeListVal(wsEmp.Cells(idxEmp, COL_EMP_EMAIL).Value)
            Exit For
        End If
    Next idxEmp

    ' 5. Fluxo de impressao e refresh (sem ambiguidade operacional)
    Call PreencherOS
    If MsgBox("OS emitida com sucesso. Deseja imprimir agora?", vbQuestion + vbYesNo, "Emitir OS") = vbYes Then
        Call ImprimirOS
    End If
    Call LimparOS
    Call PreencherPreencheOS
    Call PreencherAvaliarOS

Limpar:
    OS_QT_Estimada = Empty
    OS_DT_Fim = Empty
    OS_CNPJ = Empty
    TXT_OS_NomeEmpresa = Empty
    OS_Demandante = Empty
    OS_Atividade = Empty
    OS_Servico = Empty
    N_Empenho = Empty
    ErrorBoundary.CommitWrite
    Exit Sub

LimparFalha:
    OS_QT_Estimada = Empty
    OS_DT_Fim = Empty
    OS_CNPJ = Empty
    TXT_OS_NomeEmpresa = Empty
    OS_Demandante = Empty
    OS_Atividade = Empty
    OS_Servico = Empty
    N_Empenho = Empty
    Exit Sub

Erro:
    ErrorBoundary.RollbackWrite silent:=False
    MsgBox "Erro inesperado em BE_ImprimeOS_Click: " & Err.Description, vbCritical, "Erro"
    Resume LimparFalha
End Sub

Private Sub C_Entidade_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub

Private Sub C_ListaRodizio_Click()
On Error GoTo erro_carregamento:
If C_ListaRodizio.ListIndex < 0 Then Exit Sub

Entidade = SafeListVal(C_ListaRodizio.List(C_ListaRodizio.ListIndex, 0))
Desc_entidade = SafeListVal(C_ListaRodizio.List(C_ListaRodizio.ListIndex, 2))
cont_entidade = SafeListVal(C_ListaRodizio.List(C_ListaRodizio.ListIndex, 11))
telcont_entidade = SafeListVal(C_ListaRodizio.List(C_ListaRodizio.ListIndex, 12))
END_ENTIDADE = SafeListVal(C_ListaRodizio.List(C_ListaRodizio.ListIndex, 6))
' A1: fallback por nome quando ID da entidade vier vazio no ListBox
If Trim$(CStr(Entidade)) = "" And Trim$(Desc_entidade) <> "" Then
    Dim wsEnt As Worksheet
    Dim iEnt As Long
    Set wsEnt = ThisWorkbook.Sheets(SHEET_ENTIDADE)
    For iEnt = LINHA_DADOS To UltimaLinhaAba(SHEET_ENTIDADE)
        If StrComp(Trim$(CStr(wsEnt.Cells(iEnt, COL_ENT_NOME).Value)), Trim$(Desc_entidade), vbTextCompare) = 0 Then
            Entidade = SafeListVal(wsEnt.Cells(iEnt, COL_ENT_ID).Value)
            Exit For
        End If
    Next iEnt
End If
Exit Sub
erro_carregamento:
End Sub

Private Sub Cad_Servico_Click()
On Error GoTo erro_carregamento:
    Dim frmServico As Object

    Call UI_DescartarFormVisivel("Altera_Entidade")
    Call UI_DescartarFormVisivel("Cadastro_Servico")

    Set frmServico = VBA.UserForms.Add("Cadastro_Servico")
    frmServico.Show vbModal

    If mTxtFiltroCadServ Is Nothing Then
        Call PreencherManutencaoValor
    Else
        Call PreencherManutencaoValor(mTxtFiltroCadServ.Text)
    End If
    Exit Sub
erro_carregamento:
    MsgBox "Erro ao abrir cadastro de servi" & ChrW(231) & "o: " & Err.Description, _
           vbCritical, "Cadastro de Servi" & ChrW(231) & "o"
End Sub
Private Sub Cad_Valor_HD_Click()
On Error GoTo erro_carregamento:
    ' V12: eliminado .Select + Application.GoTo + ActiveCell (proibidos; formulario modal).
    ' Opera diretamente na celula encontrada via .Find.
    Dim valorHora As Currency
    Dim wsServ As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim servicoTxt As String

    Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    valorHora = Util_Conversao.ToCurrency(H_Vl_Hora.Value)
    If valorHora < 0 Then valorHora = 0
    servicoTxt = Funcoes.NormalizarTextoPTBR(H_Servico.Value)

    With wsServ.Range("A:A")
        Set EncontrarID = .Find(What:=H_Lista.Column(0), LookAt:=xlWhole)
        If Not EncontrarID Is Nothing Then
            If MsgBox("Deseja alterar estes dados?", vbQuestion + vbYesNo, "Alteração") = vbYes Then
                If Not Util_PrepararAbaParaEscrita(wsServ, estavaProtegida, senhaProtecao) Then
                    MsgBox "Não foi possível alterar: aba CAD_SERV protegida.", vbCritical, "Alteração de serviço"
                    Exit Sub
                End If
                EncontrarID.Offset(0, 3).Value = servicoTxt
                EncontrarID.Offset(0, 4).Value = valorHora
                EncontrarID.Offset(0, 4).NumberFormat = "_-R$ * #,##0.00_-;-R$ * #,##0.00_-;_-R$ * ""-""??_-;_-@_-"
'                EncontrarID.Offset(0, 6).Value = Format(H_Vl_Diaria, "currency")
                EncontrarID.Offset(0, 8).Value = Format(CDate(Now), "DD/MM/YYYY")
                Call Util_RestaurarProtecaoAba(wsServ, estavaProtegida, senhaProtecao)

                MsgBox "Valor registrado com sucesso para o serviço '" & servicoTxt & "': R$ " & _
                       Format(valorHora, "#,##0.00"), vbInformation, "Alteração de serviço"
            End If
        End If
    End With
    Call PreencherManutencaoValor
    H_Atividade = Empty
    H_Servico = Empty
    H_Vl_Hora = Empty
    H_DT_Cadastro = Empty

erro_carregamento:
    On Error Resume Next
    If Not wsServ Is Nothing Then Call Util_RestaurarProtecaoAba(wsServ, estavaProtegida, senhaProtecao)
    On Error GoTo 0

End Sub

Private Function Treinamento_ConfirmarUso() As Boolean
    Dim msg As String
    msg = "ATEN" & ChrW(199) & ChrW(195) & "O: o modo de treinamento altera dados reais desta planilha." & vbCrLf & _
          "Use somente em base de testes. Esta planilha n" & ChrW(227) & "o deve ser utilizada em produ" & ChrW(231) & ChrW(227) & "o." & vbCrLf & vbCrLf & _
          "Deseja continuar?"
    Treinamento_ConfirmarUso = (MsgBox(msg, vbExclamation + vbYesNo, "Modo Treinamento") = vbYes)
End Function

Private Sub Credencia_Empresa_Click()
On Error GoTo erro_carregamento:
    ' V12: Bug corrigido — ordem de criacao de instancia do formulario estava invertida.
    ' PreenchimentoCRServico criava Instancia A e populava CR_Lista nela.
    ' UserForms.Add criava Instancia B (CR_Lista vazia) e essa era exibida.
    ' Solucao: criar a instancia ANTES, definir empresa, entao chamar PreenchimentoCRServico
    ' (que encontra a instancia ja existente no VBA.UserForms e popula a lista correta).
    Dim empIdSel As String
    Dim cnpjSel As String
    Dim razaoSel As String
    Dim frmCredenciamento As Object
    Dim frmExistente As Object

    If EMP_Lista.ListCount = 0 Then
        MsgBox "Nenhuma empresa cadastrada. Cadastre uma empresa primeiro.", vbExclamation, "Credenciar Empresa"
        Exit Sub
    End If

    If EMP_Lista.ListIndex >= 0 Then
        empIdSel = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 0))
        cnpjSel = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 1))
        razaoSel = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 2))
    Else
        empIdSel = Trim$(CStr(M_ID_Empresa))
        cnpjSel = Trim$(CStr(Empresa_CNPJ))
        razaoSel = Trim$(CStr(M_NomeEmpresa))
    End If

    ' Fallback robusto: se o ListBox não trouxe o ID (coluna 0 vazia),
    ' tenta localizar a empresa na aba EMPRESAS via CNPJ (ou razão).
    If Trim$(empIdSel) = "" And (Trim$(cnpjSel) <> "" Or Trim$(razaoSel) <> "") Then
        Dim wsEmp As Worksheet
        Dim iEmp As Long
        Dim cnpjBusca As String
        Dim razaoBusca As String
        Dim cnpjPlan As String
        Dim razaoPlan As String

        Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)
        cnpjBusca = Trim$(cnpjSel)
        razaoBusca = Trim$(razaoSel)

        For iEmp = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
            cnpjPlan = Trim$(SafeListVal(wsEmp.Cells(iEmp, COL_EMP_CNPJ).Value))
            razaoPlan = Trim$(SafeListVal(wsEmp.Cells(iEmp, COL_EMP_RAZAO).Value))

            If cnpjBusca <> "" Then
                If StrComp(cnpjPlan, cnpjBusca, vbTextCompare) = 0 Then
                    empIdSel = Trim$(SafeListVal(wsEmp.Cells(iEmp, COL_EMP_ID).Value))
                    Exit For
                End If
            ElseIf razaoBusca <> "" Then
                If StrComp(razaoPlan, razaoBusca, vbTextCompare) = 0 Then
                    empIdSel = Trim$(SafeListVal(wsEmp.Cells(iEmp, COL_EMP_ID).Value))
                    Exit For
                End If
            End If
        Next iEmp
    End If

    If Trim$(empIdSel) = "" Then
        MsgBox "Clique em uma Empresa para Credenciar!" & vbCrLf & _
               "Se a lista estiver carregada mas o ID não for identificado, tente clicar novamente na empresa.", _
               vbExclamation, "Credenciar Empresa"
        Exit Sub
    End If

    ' Fechar instancias fantasma de Credencia_Empresa que possam ter ficado abertas
    On Error Resume Next
    For Each frmExistente In VBA.UserForms
        If TypeName(frmExistente) = "Credencia_Empresa" Then Unload frmExistente
    Next frmExistente
    On Error GoTo erro_carregamento:

    ' Criar instancia, configurar empresa e DEPOIS popular servicos
    ' V12: passa frmCredenciamento diretamente para PreenchimentoCRServico (elimina busca via FormularioAberto)
    ' V12.0.0007: verifica se CR_Lista foi populada antes de exibir o form. Se PreenchimentoCRServico
    ' exibiu MsgBox de "sem servicos" e retornou via Exit Sub, a lista fica vazia; exibir o form
    ' nesse estado confunde o usuario (form aparece mas nao permite acao). Se vazia: descartar form.
    Set frmCredenciamento = VBA.UserForms.Add("Credencia_Empresa")
    CallByName frmCredenciamento, "DefinirEmpresaSelecionada", VbMethod, empIdSel, cnpjSel, razaoSel
    Call PreenchimentoCRServico(frmCredenciamento)
    On Error Resume Next
    Dim nLinhasCredServ As Long
    nLinhasCredServ = frmCredenciamento.Controls("CR_Lista").ListCount
    On Error GoTo erro_carregamento:
    ' V12.0.0009: substituido exit silencioso por MsgBox explicativa.
    If nLinhasCredServ = 0 Then
        Unload frmCredenciamento
        Set frmCredenciamento = Nothing
        MsgBox "N" & ChrW(227) & "o foi poss" & ChrW(237) & "vel abrir o credenciamento." & vbCrLf & _
               "Verifique se h" & ChrW(225) & " atividades e servi" & ChrW(231) & "os cadastrados em CAD_SERV.", _
               vbExclamation, "Credenciar Empresa"
        Exit Sub
    End If
    frmCredenciamento.Show

Exit Sub
erro_carregamento:
    Dim errDescCredencia As String
    errDescCredencia = Err.Description
    On Error Resume Next
    If Not frmCredenciamento Is Nothing Then Unload frmCredenciamento
    On Error GoTo 0
    If errDescCredencia <> "" Then _
        MsgBox "Erro ao abrir credenciamento: " & errDescCredencia, vbCritical, "Credenciar Empresa"
End Sub
Private Sub EncerraOS_Click()
    On Error GoTo erro_carregamento
    Dim osId As String
    Dim notas(1 To 10) As Integer
    Dim payload As TAvaliacaoPayload
    Dim mediaLocal As Double
    Dim qtExec As Double
    Dim vlOS As Double
    Dim qtOrcada As Double
    Dim vlOrcado As Double
    Dim justifDiv As String
    Dim justfInput As String
    Dim avaliador As String
    Dim res As TResult
    Dim resNotas As TResult
    Dim resPayload As TResult

    If AV_Lista.ListIndex < 0 Then
        MsgBox "Selecione uma OS para avaliar!", vbExclamation, "Avaliação"
        GoTo Limpar
    End If

    osId = AVListaCol(0)
    If Trim$(osId) = "" Then
        MsgBox "Selecione uma OS válida para avaliar!", vbExclamation, "Avaliação"
        GoTo Limpar
    End If

    resNotas = MontarNotasAvaliacao( _
        AV_Nota1.Value, AV_Nota2.Value, AV_Nota3.Value, AV_Nota4.Value, AV_Nota5.Value, _
        AV_Nota6.Value, AV_Nota7.Value, AV_Nota8.Value, AV_Nota9.Value, AV_Nota10.Value, _
        notas, mediaLocal)
    If Not resNotas.Sucesso Then
        MsgBox "Erro ao montar notas da avaliação: " & resNotas.Mensagem, vbExclamation, "Avaliação"
        GoTo Limpar
    End If

    media = mediaLocal  ' Atribuir a variavel publica usada por PreencherAvaliacaoOS
    AV_Total.Value = mediaLocal

    ' V12.0.0010: resumo detalhado antes de confirmar
    If MsgBox("Confirma a avaliação?" & vbCrLf & vbCrLf & _
              "OS: " & osId & vbCrLf & _
              "Média das notas: " & CStr(mediaLocal) & vbCrLf & _
              "Notas: " & CStr(notas(1)) & "/" & CStr(notas(2)) & "/" & CStr(notas(3)) & "/" & _
              CStr(notas(4)) & "/" & CStr(notas(5)) & "/" & CStr(notas(6)) & "/" & _
              CStr(notas(7)) & "/" & CStr(notas(8)) & "/" & CStr(notas(9)) & "/" & CStr(notas(10)), _
              vbQuestion + vbYesNo, "Avaliação") <> vbYes Then
        MsgBox "Avaliação cancelada pelo usuário.", _
               vbInformation, "Avaliação"
        GoTo Limpar
    End If

    qtExec = Util_Conversao.ToDouble(SafeListVal(AV_QtHoras.Value))
    vlOS = Util_Conversao.ToDouble(SafeListVal(AV_Vl_OS.Value))
    qtOrcada = Util_Conversao.ToDouble(AVListaCol(5))
    vlOrcado = Util_Conversao.ToDouble(AVListaCol(6))

    justifDiv = Funcoes.NormalizarTextoPTBR(SafeListVal(AV_OBS.Value))
    ' V12.0.0010: validacao reforçada — justificativa obrigatoria quando diverge
    If Abs(vlOS - vlOrcado) > 0.0001 Or Abs(qtExec - qtOrcada) > 0.0001 Then
        justfInput = InputBox( _
            "Os valores realizados divergem dos orçados:" & vbCrLf & _
            "  Qtd orçada: " & CStr(qtOrcada) & " | Qtd executada: " & CStr(qtExec) & vbCrLf & _
            "  Valor orçado: R$ " & Format$(vlOrcado, "#,##0.00") & _
            " | Valor realizado: R$ " & Format$(vlOS, "#,##0.00") & vbCrLf & vbCrLf & _
            "Informe a justificativa (campo obrigat" & ChrW(243) & "rio):", _
            "Justificativa de Diverg" & ChrW(234) & "ncia")
        If Trim$(justfInput) = "" Then
            MsgBox "Justificativa obrigatória quando valores divergem." & vbCrLf & _
                   "Avaliação não registrada.", _
                   vbExclamation, "Avaliação"
            GoTo Limpar
        End If
        justifDiv = Funcoes.NormalizarTextoPTBR(SafeListVal(justfInput))
    End If

    avaliador = Trim$(SafeListVal(AVListaCol(1)))
    If avaliador = "" Then avaliador = Trim$(SafeListVal(Desc_entidade))
    resPayload = MontarPayloadAvaliacao(osId, avaliador, notas, AV_QtHoras.Value, SafeListVal(AV_OBS.Value), justifDiv, payload)
    If Not resPayload.Sucesso Then
        MsgBox "Erro ao montar payload da avaliação: " & resPayload.Mensagem, vbExclamation, "Avaliação"
        GoTo Limpar
    End If

    qtExec = payload.QtExecutada
    res = AvaliarOS(payload.OS_ID, payload.avaliador, payload.notas, payload.QtExecutada, payload.Observacao, payload.JustifDivergencia)
    If Not res.Sucesso Then
        MsgBox "Erro ao avaliar OS: " & res.mensagem, vbCritical, "Avaliação"
        GoTo Limpar
    End If

    MsgBox "Avaliação cadastrada com sucesso!", vbInformation, "Avaliação de serviço"
    If MsgBox("Deseja imprimir a avaliação desta empresa?", vbQuestion + vbYesNo, "Avaliação") = vbYes Then
        N_OS = AVListaCol(0)
        Desc_entidade = AVListaCol(1)
        Desc_Serv = AVListaCol(2)
        Empresa_CNPJ = AVCNPJ
        M_NomeEmpresa = AVEmpresa
        AvNEmp = CStr(AV_N_Empenho.Value)
        AvDtFech = CStr(AV_DataFechamento.Value)
        AvQtH = CStr(AV_QtHoras.Value)
        AvVlOs = CStr(AV_Vl_OS.Value)
        AvDtPg = CStr(AV_Dt_Pagto.Value)
        AvN01 = CStr(AV_Nota1.Value)
        Avn02 = CStr(AV_Nota2.Value)
        AvN03 = CStr(AV_Nota3.Value)
        AvN04 = CStr(AV_Nota4.Value)
        AvN05 = CStr(AV_Nota5.Value)
        AvN06 = CStr(AV_Nota6.Value)
        AvN07 = CStr(AV_Nota7.Value)
        AvN08 = CStr(AV_Nota8.Value)
        AvN09 = CStr(AV_Nota9.Value)
        AvN10 = CStr(AV_Nota10.Value)
        AvOb = CStr(AV_OBS.Value)
        On Error GoTo errPrint
        Call PreencherAvaliacaoOS
        Call Imprimir_AvaliacaoOS
        Call LimparAvaliacaoOS
        On Error GoTo erro_carregamento
    End If
    GoTo Limpar

errPrint:
    MsgBox "Avaliação registrada com sucesso, porém houve erro ao imprimir: " & Err.Description, vbExclamation, "Avaliação"
    On Error Resume Next
    Call LimparAvaliacaoOS
    On Error GoTo erro_carregamento
    GoTo Limpar

Limpar:
    AVCNPJ = Empty: AVEmpresa = Empty: AV_N_Empenho = Empty
    AV_DataFechamento = Empty: AV_QtHoras = Empty: AV_Vl_OS = Empty
    AV_Dt_Pagto = Empty: AV_Nota1 = Empty: AV_Nota2 = Empty
    AV_Nota3 = Empty: AV_Nota4 = Empty: AV_Nota5 = Empty
    AV_Nota6 = Empty: AV_Nota7 = Empty: AV_Nota8 = Empty
    AV_Nota9 = Empty: AV_Nota10 = Empty: AV_OBS = Empty
    AV_Total = Empty
    Call PreencherAvaliarOS
    Exit Sub
erro_carregamento:
    MsgBox "Erro inesperado em EncerraOS_Click: " & Err.Description, vbCritical, "Erro"
    Resume Limpar
End Sub

Private Sub Entidades_Cadastradas_Click()
Dim wsEnt As Worksheet
Dim wsRel As Worksheet
Dim ultimaEnt As Long
Dim linhaRel As Long
Dim i As Long
Dim estRel As Boolean
Dim senRel As String

Set wsEnt = ThisWorkbook.Sheets(SHEET_ENTIDADE)
Set wsRel = ThisWorkbook.Sheets(SHEET_REL_UI)

ultimaEnt = UltimaLinhaAba(SHEET_ENTIDADE)
If ultimaEnt < LINHA_DADOS Then
    MsgBox "Não há entidades cadastradas para listar.", vbInformation, "Relatório"
    Exit Sub
End If

If Not Util_PrepararAbaParaEscrita(wsRel, estRel, senRel) Then
    MsgBox "Não foi possível preparar a aba RELATORIO para o relatório (proteção).", vbCritical, "Relatório"
    Exit Sub
End If

On Error GoTo falha_rel_entidades

wsRel.Cells.ClearContents
wsRel.Cells(1, 1).Value = "CNPJ"
wsRel.Cells(1, 2).Value = "RAZAO SOCIAL"
wsRel.Cells(1, 3).Value = "TEL.FIXO"
wsRel.Cells(1, 4).Value = "CELULAR"
wsRel.Cells(1, 5).Value = "CONTATO 1"
wsRel.Cells(1, 6).Value = "CEL.CONTATO1"
wsRel.Cells(1, 7).Value = "CONTATO 2"
wsRel.Cells(1, 8).Value = "CEL.CONTATO2"
wsRel.Cells(1, 9).Value = "CONTATO 3"
wsRel.Cells(1, 10).Value = "CEL.CONTATO3"

linhaRel = 2
For i = LINHA_DADOS To ultimaEnt
    wsRel.Cells(linhaRel, 1).Value = SafeListVal(wsEnt.Cells(i, COL_ENT_CNPJ).Value)
    wsRel.Cells(linhaRel, 2).Value = SafeListVal(wsEnt.Cells(i, COL_ENT_NOME).Value)
    wsRel.Cells(linhaRel, 3).Value = SafeListVal(wsEnt.Cells(i, COL_ENT_TEL_FIXO).Value)
    wsRel.Cells(linhaRel, 4).Value = SafeListVal(wsEnt.Cells(i, COL_ENT_TEL_CEL).Value)
    wsRel.Cells(linhaRel, 5).Value = SafeListVal(wsEnt.Cells(i, COL_ENT_CONT1_NOME).Value)
    wsRel.Cells(linhaRel, 6).Value = SafeListVal(wsEnt.Cells(i, COL_ENT_CONT1_FONE).Value)
    wsRel.Cells(linhaRel, 7).Value = SafeListVal(wsEnt.Cells(i, COL_ENT_CONT2_NOME).Value)
    wsRel.Cells(linhaRel, 8).Value = SafeListVal(wsEnt.Cells(i, COL_ENT_CONT2_FONE).Value)
    wsRel.Cells(linhaRel, 9).Value = SafeListVal(wsEnt.Cells(i, COL_ENT_CONT3_NOME).Value)
    wsRel.Cells(linhaRel, 10).Value = SafeListVal(wsEnt.Cells(i, COL_ENT_CONT3_FONE).Value)
    linhaRel = linhaRel + 1
Next i

wsRel.Columns("A:J").AutoFit
With wsRel.PageSetup
        .LeftHeader = ""
        .CenterHeader = "RELATORIO DE ENTIDADES CADASTRADAS NO CREDENCIAMENTO"
        .RightHeader = ""
        .LeftFooter = ""
        .CenterFooter = "Pagina &P"
        .RightFooter = ""
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .Orientation = xlLandscape
        .LeftMargin = Application.CentimetersToPoints(0.5)
        .RightMargin = Application.CentimetersToPoints(0.5)
        .TopMargin = Application.CentimetersToPoints(1.5)
        .BottomMargin = Application.CentimetersToPoints(1)
        .HeaderMargin = Application.CentimetersToPoints(0.5)
        .FooterMargin = Application.CentimetersToPoints(0.5)
        .PrintHeadings = False
        .PrintGridlines = False
        .PrintComments = xlPrintNoComments
        .PrintQuality = 600
        .CenterHorizontally = False
        .CenterVertically = False
        .Orientation = xlLandscape
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
        .EvenPage.LeftHeader.Text = ""
        .EvenPage.CenterHeader.Text = ""
        .EvenPage.RightHeader.Text = ""
        .EvenPage.LeftFooter.Text = ""
        .EvenPage.CenterFooter.Text = ""
        .EvenPage.RightFooter.Text = ""
        .FirstPage.LeftHeader.Text = ""
        .FirstPage.CenterHeader.Text = ""
        .FirstPage.RightHeader.Text = ""
        .FirstPage.LeftFooter.Text = ""
        .FirstPage.CenterFooter.Text = ""
        .FirstPage.RightFooter.Text = ""
End With

wsRel.Range("A1:J" & (linhaRel - 1)).PrintOut

wsRel.Range("A1:J" & (linhaRel - 1)).ClearContents
Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
Exit Sub

falha_rel_entidades:
On Error Resume Next
Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
On Error GoTo 0
erro_carregamento:
MsgBox "Erro ao gerar relatório de entidades cadastradas: " & Err.Description, vbCritical, "Relatório"
End Sub
Private Sub H_Lista_Click()
On Error GoTo erro_carregamento:
    ' V12: eliminado Sheets("CAD_SERV").Select (proibido; formulario modal).
    ' Leitura direta das colunas do ListBox — sem acesso a planilha necessario aqui.
    H_Atividade = H_Lista.Column(3)
    H_Servico = H_Lista.Column(4)
    H_Vl_Hora.SetFocus
    If H_Lista.Column(5) = Empty Then
        H_Vl_Hora = Format(H_Vl_Hora, "currency")
    Else
        H_Vl_Hora = H_Lista.Column(5)
    End If
    H_DT_Cadastro = H_Lista.Column(9)

erro_carregamento:
End Sub
Private Sub H_Vl_Hora_AfterUpdate()
On Error GoTo erro_carregamento:
H_Vl_Hora = Format(Util_Conversao.ToCurrency(H_Vl_Hora.Value), "Currency")
erro_carregamento:
End Sub
Private Sub M_Empresa_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Entidade_AfterUpdate()
On Error GoTo erro_carregamento:
C_Entidade.Value = Funcoes.NormalizarTextoPTBR(C_Entidade.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub M_Empresa_AfterUpdate()
On Error GoTo erro_carregamento:
M_Empresa.Value = Funcoes.NormalizarTextoPTBR(M_Empresa.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub M_Nome_Responsavel_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub M_Nome_Responsavel_AfterUpdate()
On Error GoTo erro_carregamento:
M_Nome_Responsavel.Value = Funcoes.NormalizarTextoPTBR(M_Nome_Responsavel.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub M_Endereco_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub M_Endereco_AfterUpdate()
On Error GoTo erro_carregamento:
M_Endereco.Value = Funcoes.NormalizarTextoPTBR(M_Endereco.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub AV_OBS_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub AV_OBS_AfterUpdate()
On Error GoTo erro_carregamento:
AV_OBS.Value = Funcoes.NormalizarTextoPTBR(AV_OBS.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub M_Bairro_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub M_Bairro_AfterUpdate()
On Error GoTo erro_carregamento:
M_Bairro.Value = Funcoes.NormalizarTextoPTBR(M_Bairro.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub M_Municipio_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub M_Municipio_AfterUpdate()
On Error GoTo erro_carregamento:
M_Municipio.Value = Funcoes.NormalizarTextoPTBR(M_Municipio.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub M_UF_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Contato1_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Contato1_AfterUpdate()
On Error GoTo erro_carregamento:
C_Contato1.Value = Funcoes.NormalizarTextoPTBR(C_Contato1.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Fone_Cont1_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

C_Fone_Cont1.Text = Funcoes.telCel(KeyAscii, C_Fone_Cont1.Text)

erro_carregamento:
End Sub

Private Sub C_Func_Cont1_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Func_Cont1_AfterUpdate()
On Error GoTo erro_carregamento:
C_Func_Cont1.Value = Funcoes.NormalizarTextoPTBR(C_Func_Cont1.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Contato2_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Contato2_AfterUpdate()
On Error GoTo erro_carregamento:
C_Contato2.Value = Funcoes.NormalizarTextoPTBR(C_Contato2.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Fone_Cont2_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

C_Fone_Cont2.Text = Funcoes.telCel(KeyAscii, C_Fone_Cont2.Text)

erro_carregamento:
End Sub

Private Sub C_Func_Cont2_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Func_Cont2_AfterUpdate()
On Error GoTo erro_carregamento:
C_Func_Cont2.Value = Funcoes.NormalizarTextoPTBR(C_Func_Cont2.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Contato3_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Contato3_AfterUpdate()
On Error GoTo erro_carregamento:
C_Contato3.Value = Funcoes.NormalizarTextoPTBR(C_Contato3.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Fone_Cont3_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

C_Fone_Cont3.Text = Funcoes.telCel(KeyAscii, C_Fone_Cont3.Text)

erro_carregamento:
End Sub

Private Sub C_Func_Cont3_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Func_Cont3_AfterUpdate()
On Error GoTo erro_carregamento:
C_Func_Cont3.Value = Funcoes.NormalizarTextoPTBR(C_Func_Cont3.Value)
Exit Sub
erro_carregamento:
End Sub

Private Sub C_Endereco_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Endereco_AfterUpdate()
On Error GoTo erro_carregamento:
C_Endereco.Value = Funcoes.NormalizarTextoPTBR(C_Endereco.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Bairro_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Bairro_AfterUpdate()
On Error GoTo erro_carregamento:
C_Bairro.Value = Funcoes.NormalizarTextoPTBR(C_Bairro.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Municipio_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Municipio_AfterUpdate()
On Error GoTo erro_carregamento:
C_Municipio.Value = Funcoes.NormalizarTextoPTBR(C_Municipio.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_UF_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
    Select Case KeyAscii
        Case 8, 65 To 90, 97 To 122
        Case Else
        KeyAscii = 0
    End Select
   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
End Sub
Private Sub AV_Nota1_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
    Select Case KeyAscii
        Case 48 To 57
        Case Else
        KeyAscii = 0
    End Select
   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
End Sub
Private Sub AV_Nota2_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
    Select Case KeyAscii
        Case 48 To 57
        Case Else
        KeyAscii = 0
    End Select
   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
End Sub
Private Sub AV_Nota3_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
    Select Case KeyAscii
        Case 48 To 57
        Case Else
        KeyAscii = 0
    End Select
   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
End Sub
Private Sub AV_Nota4_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
    Select Case KeyAscii
        Case 48 To 57
        Case Else
        KeyAscii = 0
    End Select
   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
End Sub
Private Sub AV_Nota5_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
    Select Case KeyAscii
        Case 48 To 57
        Case Else
        KeyAscii = 0
    End Select
   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
End Sub
Private Sub AV_Nota6_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
    Select Case KeyAscii
        Case 48 To 57
        Case Else
        KeyAscii = 0
    End Select
   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
End Sub
Private Sub AV_Nota7_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
    Select Case KeyAscii
        Case 48 To 57
        Case Else
        KeyAscii = 0
    End Select
   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
End Sub
Private Sub AV_Nota8_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
    Select Case KeyAscii
        Case 48 To 57
        Case Else
        KeyAscii = 0
    End Select
   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
End Sub
Private Sub AV_Nota9_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
    Select Case KeyAscii
        Case 48 To 57
        Case Else
        KeyAscii = 0
    End Select
   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
End Sub
Private Sub AV_Nota10_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
    Select Case KeyAscii
        Case 48 To 57
        Case Else
        KeyAscii = 0
    End Select
   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
End Sub
Private Sub AV_Total_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
    Select Case KeyAscii
        Case 48 To 57
        Case Else
        KeyAscii = 0
    End Select
   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
End Sub


Private Sub C_InfoAD_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_InfoAD_AfterUpdate()
On Error GoTo erro_carregamento:
C_InfoAD.Value = Funcoes.NormalizarTextoPTBR(C_InfoAD.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub AV_QtHoras_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
    Select Case KeyAscii
        Case 48 To 57
        Case Else
        KeyAscii = 0
    End Select
   ' Permitir acentuacao em PT-BR (V5)
Exit Sub
End Sub

Private Sub A_Lista_Click()
On Error GoTo erro_carregamento:
    ' V12: eliminado .Select + Application.GoTo + ActiveCell (proibidos; formulario modal).
    ' Itera por referencia direta usando numero de linha da celula encontrada.
    Dim wsCadServ As Worksheet
    Dim linhaAtual As Long

    Cd_Ativi = Pad3Id(A_Lista.Column(1))
    Cd_Serv = Pad3Id(A_Lista.Column(0))

    Set wsCadServ = ThisWorkbook.Sheets("CAD_SERV")
    With wsCadServ.Range("B:B")
        Set EncontrarID = .Find(What:=Cd_Ativi, LookAt:=xlWhole)
        If Not EncontrarID Is Nothing Then
            linhaAtual = EncontrarID.row
            Do While Pad3Id(CStr(wsCadServ.Cells(linhaAtual, 2).Value)) = Cd_Ativi
                If Pad3Id(CStr(wsCadServ.Cells(linhaAtual, 1).Value)) = Cd_Serv Then
                    Desc_Ativi = wsCadServ.Cells(linhaAtual, 3).Value
                    Desc_Serv = wsCadServ.Cells(linhaAtual, 4).Value
                    VL_Pagto = Util_Conversao.ToDouble(CStr(wsCadServ.Cells(linhaAtual, 5).Value))
                End If
                linhaAtual = linhaAtual + 1
            Loop
        End If
    End With

erro_carregamento:
End Sub

Private Sub C_Lista_Click()
On Error GoTo erro_carregamento:
    If C_Lista.ListIndex < 0 Then Exit Sub
    C_Cad = CInt(Val(SafeListVal(C_Lista.Column(0))))

    ' V12.0.0009: popular controles visiveis ao selecionar entidade (espelha M_Lista_Click).
    ' Colunas do C_Lista (0-based) = colunas da aba ENTIDADE (1-based) deslocadas em -1.
    C_CNPJ.Value = SafeListVal(C_Lista.List(C_Lista.ListIndex, 1))
    C_Entidade.Value = SafeListVal(C_Lista.List(C_Lista.ListIndex, 2))
    C_Tel_Fixo.Value = SafeListVal(C_Lista.List(C_Lista.ListIndex, 3))
    C_Tel_Cel.Value = SafeListVal(C_Lista.List(C_Lista.ListIndex, 4))
    C_Email.Value = SafeListVal(C_Lista.List(C_Lista.ListIndex, 5))
    C_Endereco.Value = SafeListVal(C_Lista.List(C_Lista.ListIndex, 6))
    C_Municipio.Value = SafeListVal(C_Lista.List(C_Lista.ListIndex, 8))
    C_CEP.Value = SafeListVal(C_Lista.List(C_Lista.ListIndex, 9))
    C_UF.Value = SafeListVal(C_Lista.List(C_Lista.ListIndex, 10))

Exit Sub
erro_carregamento:
End Sub

Private Sub C_Lista_DblClick(ByVal Cancel As MSForms.ReturnBoolean)
On Error GoTo erro_carregamento:

    On Error Resume Next
    
    Dim frmEnt As Object
    Set frmEnt = VBA.UserForms.Add("Altera_Entidade")
    frmEnt.Controls("C_CNPJ").Value = C_Lista.Column(1)
    frmEnt.Controls("C_Entidade").Value = C_Lista.Column(2)
    frmEnt.Controls("C_Tel_Fixo").Value = C_Lista.Column(3)
    frmEnt.Controls("C_Tel_Cel").Value = C_Lista.Column(4)
    frmEnt.Controls("C_Email").Value = C_Lista.Column(5)
    frmEnt.Controls("C_Endereco").Value = C_Lista.Column(6)
    frmEnt.Controls("C_Bairro").Value = C_Lista.Column(7)
    frmEnt.Controls("C_Municipio").Value = C_Lista.Column(8)
    frmEnt.Controls("C_CEP").Value = C_Lista.Column(9)
    frmEnt.Controls("C_UF").Value = C_Lista.Column(10)
    frmEnt.Controls("C_Contato1").Value = C_Lista.Column(11)
    frmEnt.Controls("C_Fone_Cont1").Value = C_Lista.Column(12)
    frmEnt.Controls("C_Func_Cont1").Value = C_Lista.Column(13)
    frmEnt.Controls("C_Contato2").Value = C_Lista.Column(14)
    frmEnt.Controls("C_Fone_Cont2").Value = C_Lista.Column(15)
    frmEnt.Controls("C_Func_Cont2").Value = C_Lista.Column(16)
    frmEnt.Controls("C_Contato3").Value = C_Lista.Column(17)
    frmEnt.Controls("C_Fone_Cont3").Value = C_Lista.Column(18)
    frmEnt.Controls("C_Func_Cont3").Value = C_Lista.Column(19)
    frmEnt.Controls("C_InfoAD").Value = C_Lista.Column(20)
    CallByName frmEnt, "DefinirIdEdicaoEntidade", VbMethod, SafeListVal(C_Lista.List(C_Lista.ListIndex, 0))
    
    Err
    
    frmEnt.Show
Call AtualizarListaEntidadeMenuAtual
Exit Sub
erro_carregamento:
End Sub
Private Sub EMP_Lista_Click()
On Error GoTo erro_carregamento:

    If EMP_Lista.ListIndex < 0 Then Exit Sub
    Dim empIdSel As String
    empIdSel = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 0))
    If empIdSel = "" Then Exit Sub

    ' V12: eliminado .Select + Application.GoTo + ActiveCell (proibidos; causavam saida
    ' prematura via erro_carregamento dentro de formulario modal, zerando as variaveis).
    ' Leitura direta do ListBox — sem efeitos colaterais no workbook.
    A_Cad = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 2))     ' Razao Social (legado)
    C_Cad = CInt(Val(empIdSel))                                  ' ID numerico (legado)
    M_ID_Empresa = empIdSel
    Empresa_CNPJ = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 1))
    M_NomeEmpresa = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 2))
    Empresa_endereco = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 6))
    Empresa_email = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 13))

    ' V12.0.0008: popular controles visiveis ao selecionar empresa.
    ' Antes apenas as variaveis globais eram atualizadas; os TextBox permaneciam vazios.
    ' Colunas do EMP_Lista (0-based) = colunas da aba EMPRESAS (1-based) deslocadas em -1.
    M_CNPJ.Value = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 1))
    M_Empresa.Value = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 2))
    M_Insc_Mun.Value = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 3))
    M_Nome_Responsavel.Value = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 4))
    M_CPF_Responsavel.Value = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 5))
    M_Endereco.Value = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 6))
    M_Bairro.Value = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 7))
    M_Municipio.Value = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 8))
    M_CEP.Value = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 9))
    M_UF.Value = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 10))
    M_Tel_Fixo.Value = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 11))
    M_Tel_Cel.Value = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 12))
    M_Email.Value = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 13))
    M_Temp_Exper.Value = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 14))

Exit Sub
erro_carregamento:
End Sub

Private Sub EMP_Lista_DblClick(ByVal Cancel As MSForms.ReturnBoolean)
On Error GoTo erro_carregamento:

    If EMP_Lista.ListIndex < 0 Then
        MsgBox "Selecione uma empresa para alterar.", vbExclamation, "Cadastro de Empresa"
        Exit Sub
    End If

    Dim frmAltera As Object

    Set frmAltera = VBA.UserForms.Add("Altera_Empresa")
    ' V12.0.0010: corrigido — col 0 (ID) removido da CallByName.
    ' O ID e lido da global M_ID_Empresa.
    ' Garantia explicitamente definida aqui antes de chamar:
    M_ID_Empresa = SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 0))
    CallByName frmAltera, "DefinirDadosEdicaoEmpresa", VbMethod, _
        SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 1)), _
        SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 2)), _
        SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 3)), _
        SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 4)), _
        SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 5)), _
        SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 6)), _
        SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 7)), _
        SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 8)), _
        SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 9)), _
        SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 10)), _
        SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 11)), _
        SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 12)), _
        SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 13)), _
        SafeListVal(EMP_Lista.List(EMP_Lista.ListIndex, 14))

    frmAltera.Show
    Call AtualizarListaEmpresaMenuAtual
    Exit Sub
erro_carregamento:
End Sub
Private Sub C_Cadastrar_Click()
On Error GoTo erro_carregamento:
    ' V12: eliminado .Select + Application.GoTo + Selection + ActiveCell (proibidos; formulario modal).
    ' Usa ProximoId(SHEET_ENTIDADE) para gerar ID e escreve direto na ultima linha + 1.
    Dim msgSave As String
    Dim wsEnt As Worksheet
    Dim ultimaLinhaEnt As Long
    Dim estEntProt As Boolean
    Dim senhaEntProt As String

    If C_Entidade = Empty Then
        MsgBox "Informe o nome da Entidade!", vbExclamation, "Cadastro"
        C_Entidade.BackColor = &HFFFF&
        C_Entidade.SetFocus
        Exit Sub
    End If

    If MsgBox("Deseja realmente continuar?", vbQuestion + vbYesNo, "Cadastro") <> vbYes Then Exit Sub

    Set wsEnt = ThisWorkbook.Sheets(SHEET_ENTIDADE)
    ultimaLinhaEnt = wsEnt.Cells(wsEnt.Rows.count, 1).End(xlUp).row + 1

    ' ProximoId le e incrementa o contador em AR1 da aba ENTIDADE
    ContCodigo = CLng(Val(ProximoId(SHEET_ENTIDADE)))

    ' Lancar dados diretamente por referencia de celula
    If Not Util_PrepararAbaParaEscrita(wsEnt, estEntProt, senhaEntProt) Then
        MsgBox "N" & ChrW(227) & "o foi poss" & ChrW(237) & "vel acessar a aba ENTIDADE para escrita.", vbCritical, "Cadastro"
        Exit Sub
    End If
    wsEnt.Cells(ultimaLinhaEnt, 1).Value = Format(ContCodigo, "000")
    wsEnt.Cells(ultimaLinhaEnt, 2).Value = C_CNPJ
    wsEnt.Cells(ultimaLinhaEnt, 3).Value = Funcoes.NormalizarTextoPTBR(C_Entidade.Value)
    wsEnt.Cells(ultimaLinhaEnt, 4).Value = Format(C_Tel_Fixo)
    wsEnt.Cells(ultimaLinhaEnt, 5).Value = Format(C_Tel_Cel)
    wsEnt.Cells(ultimaLinhaEnt, 6).Value = Format(C_Email)
    wsEnt.Cells(ultimaLinhaEnt, 7).Value = Funcoes.NormalizarTextoPTBR(C_Endereco.Value)
    wsEnt.Cells(ultimaLinhaEnt, 8).Value = Funcoes.NormalizarTextoPTBR(C_Bairro.Value)
    wsEnt.Cells(ultimaLinhaEnt, 9).Value = Funcoes.NormalizarTextoPTBR(C_Municipio.Value)
    wsEnt.Cells(ultimaLinhaEnt, 10).Value = Format(C_CEP)
    wsEnt.Cells(ultimaLinhaEnt, 11).Value = Format(C_UF)
    wsEnt.Cells(ultimaLinhaEnt, 12).Value = Funcoes.NormalizarTextoPTBR(C_Contato1.Value)
    wsEnt.Cells(ultimaLinhaEnt, 13).Value = Format(C_Fone_Cont1)
    wsEnt.Cells(ultimaLinhaEnt, 14).Value = Funcoes.NormalizarTextoPTBR(C_Func_Cont1.Value)
    wsEnt.Cells(ultimaLinhaEnt, 15).Value = Funcoes.NormalizarTextoPTBR(C_Contato2.Value)
    wsEnt.Cells(ultimaLinhaEnt, 16).Value = Format(C_Fone_Cont2)
    wsEnt.Cells(ultimaLinhaEnt, 17).Value = Funcoes.NormalizarTextoPTBR(C_Func_Cont2.Value)
    wsEnt.Cells(ultimaLinhaEnt, 18).Value = Funcoes.NormalizarTextoPTBR(C_Contato3.Value)
    wsEnt.Cells(ultimaLinhaEnt, 19).Value = Format(C_Fone_Cont3)
    wsEnt.Cells(ultimaLinhaEnt, 20).Value = Funcoes.NormalizarTextoPTBR(C_Func_Cont3.Value)
    wsEnt.Cells(ultimaLinhaEnt, 21).Value = Funcoes.NormalizarTextoPTBR(C_InfoAD.Value)
    wsEnt.Cells(ultimaLinhaEnt, 22).Value = CDate(Now)
    Call Util_RestaurarProtecaoAba(wsEnt, estEntProt, senhaEntProt)

    C_CNPJ = Empty
    C_Entidade = Empty
    C_Tel_Fixo = Empty
    C_Tel_Cel = Empty
    C_Email = Empty
    C_Endereco = Empty
    C_Bairro = Empty
    C_Municipio = Empty
    C_CEP = Empty
    C_UF = Empty
    C_Contato1 = Empty
    C_Fone_Cont1 = Empty
    C_Func_Cont1 = Empty
    C_Contato2 = Empty
    C_Fone_Cont2 = Empty
    C_Func_Cont2 = Empty
    C_Contato3 = Empty
    C_Fone_Cont3 = Empty
    C_Func_Cont3 = Empty
    C_InfoAD = Empty

    Call ClassificaEntidade
    Call AtualizarListaEntidadeMenuAtual
    Call PreenchimentoEntidadeRodizio
    If Not Util_SalvarWorkbookSeguro(msgSave) Then
        MsgBox "Cadastro de entidade concluído, mas houve falha ao salvar automaticamente." & vbCrLf & _
               "Detalhe: " & msgSave & vbCrLf & _
               "Use Ctrl+S para salvar manualmente antes de continuar.", vbExclamation, "Cadastro"
    End If
    ProgressBar.Show
    MsgBox "Cadastro realizado com sucesso!", vbInformation, "Cadastro"

Exit Sub
erro_carregamento:
    On Error Resume Next
    Call Util_RestaurarProtecaoAba(wsEnt, estEntProt, senhaEntProt)
    On Error GoTo 0
End Sub

Private Sub C_CNPJ_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:
C_CNPJ.Text = Funcoes.cnpj(KeyAscii, C_CNPJ.Text)
erro_carregamento:
End Sub
Private Sub C_Tel_Fixo_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

C_Tel_Fixo.Text = Funcoes.telFixo(KeyAscii, C_Tel_Fixo.Text)

erro_carregamento:
End Sub
Private Sub OS_DT_Fim_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

OS_DT_Fim.Text = Funcoes.Ent_Data(KeyAscii, OS_DT_Fim.Text)

erro_carregamento:
End Sub
Private Sub H_DT_CADASTRO_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

H_DT_Cadastro.Text = Funcoes.Ent_Data(KeyAscii, H_DT_Cadastro.Text)

erro_carregamento:
End Sub

Private Sub AV_DataFechamento_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

AV_DataFechamento.Text = Funcoes.Ent_Data(KeyAscii, AV_DataFechamento.Text)

erro_carregamento:
End Sub
Private Sub AV_Dt_Pagto_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

AV_Dt_Pagto.Text = Funcoes.Ent_Data(KeyAscii, AV_Dt_Pagto.Text)

erro_carregamento:
End Sub
Private Sub C_Tel_Cel_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

C_Tel_Cel.Text = Funcoes.telCel(KeyAscii, C_Tel_Cel.Text)

erro_carregamento:
End Sub
Private Sub M_Tel_Fixo_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

M_Tel_Fixo.Text = Funcoes.telFixo(KeyAscii, M_Tel_Fixo.Text)

erro_carregamento:
End Sub
Private Sub M_Tel_Cel_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

M_Tel_Cel.Text = Funcoes.telCel(KeyAscii, M_Tel_Cel.Text)

erro_carregamento:
End Sub
Private Sub C_CEP_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:
C_CEP.Text = Funcoes.cep(KeyAscii, C_CEP.Text)
erro_carregamento:
End Sub
Private Sub M_CEP_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:
M_CEP.Text = Funcoes.cep(KeyAscii, M_CEP.Text)
erro_carregamento:
End Sub
Private Sub B_PreOS_Click()
    On Error GoTo Erro

    If Not ErrorBoundary.BeginWrite("EMISSAO_PREOS") Then Exit Sub

    ' 1. Validacao basica de UI
    Dim codServico As String
    Dim ativIDSel As String
    Dim servIDSel As String
    Dim idxSel As Long
    Dim iSel As Long
    Dim descAtivSel As String
    Dim descServSel As String
    Dim totalServicosNaLista As Long

    totalServicosNaLista = 0
    On Error Resume Next
    totalServicosNaLista = A_Lista.ListCount
    On Error GoTo Erro
    If totalServicosNaLista <= 0 Then
        MsgBox "Nenhum serviço carregado para seleção." & vbCrLf & _
               "Verifique o cadastro em CAD_SERV e tente novamente.", _
               vbExclamation, "Pre-OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    idxSel = A_Lista.ListIndex
    If idxSel < 0 Then
        For iSel = 0 To A_Lista.ListCount - 1
            If A_Lista.Selected(iSel) Then
                idxSel = iSel
                Exit For
            End If
        Next iSel
    End If

    If idxSel >= 0 Then
        On Error Resume Next
        ativIDSel = Pad3Id(A_Lista.List(idxSel, 1))
        servIDSel = Pad3Id(A_Lista.List(idxSel, 0))
        descAtivSel = Trim$(CStr(A_Lista.List(idxSel, 2)))
        descServSel = Trim$(CStr(A_Lista.List(idxSel, 3)))
        On Error GoTo Erro
    Else
        ' Fallback: usa ultimo item clicado (variaveis globais)
        ativIDSel = Pad3Id(Cd_Ativi)
        servIDSel = Pad3Id(Cd_Serv)
        descAtivSel = Trim$(CStr(Desc_Ativi))
        descServSel = Trim$(CStr(Desc_Serv))
    End If

    If Len(Trim$(ativIDSel)) = 0 Or Len(Trim$(servIDSel)) = 0 Then
        MsgBox "Selecione um serviço na lista superior antes de emitir a Pre-OS.", vbExclamation, "Pre-OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    codServico = ativIDSel & "|" & servIDSel

    ' A1: fallback de Entidade pela selecao atual da C_ListaRodizio
    If Trim$(CStr(Entidade)) = "" Then
        If C_ListaRodizio.ListIndex >= 0 Then
            Entidade = SafeListVal(C_ListaRodizio.List(C_ListaRodizio.ListIndex, 0))
            If Trim$(CStr(Entidade)) = "" Then
                Dim nomeEntFallback As String
                nomeEntFallback = SafeListVal(C_ListaRodizio.List(C_ListaRodizio.ListIndex, 2))
                If Trim$(nomeEntFallback) <> "" Then
                    Dim wsEntFB As Worksheet
                    Dim iFB As Long
                    Set wsEntFB = ThisWorkbook.Sheets(SHEET_ENTIDADE)
                    For iFB = LINHA_DADOS To UltimaLinhaAba(SHEET_ENTIDADE)
                        If StrComp(Trim$(CStr(wsEntFB.Cells(iFB, COL_ENT_NOME).Value)), Trim$(nomeEntFallback), vbTextCompare) = 0 Then
                            Entidade = SafeListVal(wsEntFB.Cells(iFB, COL_ENT_ID).Value)
                            Exit For
                        End If
                    Next iFB
                End If
            End If
        End If
    End If

    If Trim$(CStr(Entidade)) = "" Then
        MsgBox "Selecione um serviço e uma entidade para emissão da Pre-OS.", vbExclamation, "Pre-OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    ' 2. Solicitar quantidade (mantem InputBox como V9)  validacao explicita, sem On Error Resume Next
    Dim strQtd As String
    Dim valorUnit As Double
    valorUnit = 0
    Dim wsServ As Worksheet
    Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    Dim servId As String
    servId = servIDSel
    Dim ativIDServ As String
    ativIDServ = ativIDSel
    Dim jj As Long
    For jj = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_SERV)
        If Pad3Id(wsServ.Cells(jj, COL_SERV_ID).Value) = servId And _
           Pad3Id(wsServ.Cells(jj, COL_SERV_ATIV_ID).Value) = ativIDServ Then
            valorUnit = Util_Conversao.ToDouble(CStr(wsServ.Cells(jj, COL_SERV_VALOR_UNIT).Value))
            Exit For
        End If
    Next jj

    If valorUnit <= 0 Then
        MsgBox "Valor do serviço não encontrado no cadastro de serviços.", vbExclamation, "Pre-OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    If descAtivSel = "" Then descAtivSel = "ID " & ativIDSel
    If descServSel = "" Then descServSel = "ID " & servIDSel

    strQtd = InputBox("Quantidade:" & vbCrLf & _
                      "Atividade: " & descAtivSel & vbCrLf & _
                      "Serviço: " & descServSel & vbCrLf & _
                      "Valor unitário: R$ " & Format(valorUnit, "#,##0.00"), "Pre-OS", "1")
    If strQtd = "" Then
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If
    QT_ESTIMADA = Util_Conversao.ToDouble(strQtd)
    If QT_ESTIMADA <= 0 Then QT_ESTIMADA = 1
    VL_Pagto = valorUnit
    Vl_estimado = QT_ESTIMADA * VL_Pagto

    ' 3. Chamar EmitirPreOS (logica de rodizio encapsulada em modulo de servico)
    Dim res As TResult
    res = EmitirPreOS(CStr(Entidade), codServico, QT_ESTIMADA)

    If Not res.Sucesso Then
        MsgBox MensagemAmigavelPreOS(res.mensagem), vbCritical, "Pre-OS"
        ErrorBoundary.RollbackWrite silent:=True
        GoTo LimparFalha
    End If

    ' 4. Sucesso: ler dados da empresa de EMPRESAS (para template de impressao)
    N_OS = "PROVIS" & ChrW(211) & "RIA - " & res.IdGerado
    Dim wsPreOS As Worksheet
    Set wsPreOS = ThisWorkbook.Sheets(SHEET_PREOS)
    Dim empIDPreOS As String
    Dim kk As Long
    For kk = LINHA_DADOS To UltimaLinhaAba(SHEET_PREOS)
        If IdsIguais(SafeListVal(wsPreOS.Cells(kk, COL_PREOS_ID).Value), res.IdGerado) Then
            empIDPreOS = SafeListVal(wsPreOS.Cells(kk, COL_PREOS_EMP_ID).Value)
            Exit For
        End If
    Next kk

    Dim wsEmp As Worksheet
    Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    For kk = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
        If IdsIguais(SafeListVal(wsEmp.Cells(kk, COL_EMP_ID).Value), empIDPreOS) Then
            M_NomeEmpresa = SafeListVal(wsEmp.Cells(kk, COL_EMP_RAZAO).Value)
            Empresa_CNPJ = SafeListVal(wsEmp.Cells(kk, COL_EMP_CNPJ).Value)
            Empresa_endereco = SafeListVal(wsEmp.Cells(kk, COL_EMP_ENDERECO).Value)
            Empresa_TelCel = SafeListVal(wsEmp.Cells(kk, COL_EMP_TEL_CEL).Value)
            Empresa_email = SafeListVal(wsEmp.Cells(kk, COL_EMP_EMAIL).Value)
            'AM_NomeEmpresa = M_NomeEmpresa
            'R_TelEmpresa = Empresa_TelCel
            Exit For
        End If
    Next kk

    ' Desc_Ativi e Desc_Serv para o template
    Desc_Ativi = descAtivSel
    Desc_Serv = descServSel

    ' 5. Fluxo de impressao (emissao da Pre-OS independe da impressao)
    If Trim$(empIDPreOS) = "" Or Trim$(CStr(M_NomeEmpresa)) = "" Then
        MsgBox "Pre-OS emitida com sucesso (ID " & res.IdGerado & ")." & vbCrLf & _
               "Não foi possível preparar os dados para impressão automaticamente." & vbCrLf & _
               "Verifique a aba PRE_OS e tente imprimir novamente pelo relatório, se necessário.", _
               vbInformation, "Pre-OS"
    Else
        Call PreencherPREOS
        If MsgBox("Pre-OS emitida com sucesso. Deseja imprimir agora?", vbQuestion + vbYesNo, "Pre-OS") = vbYes Then
            Call Imprimir_PREOS
        End If
        Call LimparPREOS
    End If

Limpar:
    'AM_NomeEmpresa = Empty
    'R_TelEmpresa = Empty
    Entidade = ""
    Call RefreshPosPreOS
    ErrorBoundary.CommitWrite
    Exit Sub

LimparFalha:
    'AM_NomeEmpresa = Empty
    'R_TelEmpresa = Empty
    Entidade = ""
    Call RefreshPosPreOS
    Exit Sub

Erro:
    ErrorBoundary.RollbackWrite silent:=False
    MsgBox "Erro inesperado em B_PreOS_Click." & vbCrLf & _
           "Erro: " & CStr(Err.Number) & " - " & Err.Description & vbCrLf & _
           "Origem: " & Err.Source, _
           vbCritical, "Erro"
    On Error Resume Next
    'AM_NomeEmpresa = Empty
    'R_TelEmpresa = Empty
    Entidade = ""
    Call RefreshPosPreOS
    On Error GoTo 0
    Exit Sub
End Sub

Private Sub RefreshPosPreOS()
    On Error Resume Next
    Call PreenchimentoEscolhaAtividade
    If Err.Number <> 0 Then Err.Clear
    Call PreenchimentoEntidadeRodizio
    If Err.Number <> 0 Then Err.Clear
    Call PreencherPreencheOS
    If Err.Number <> 0 Then Err.Clear
    On Error GoTo 0
End Sub

Private Sub InicializarAcoesPreOS()
    On Error Resume Next
    BE_ImprimeOS.caption = "Aceitar e Emitir OS"
    On Error GoTo 0
End Sub

Private Sub InicializarAcoesOS()
    On Error Resume Next
    EncerraOS.caption = "Encerrar S.S"
    On Error GoTo 0
End Sub

Private Function ObterPreOSSelecionada(ByRef preosId As String) As Boolean
    preosId = ""
    If OS_Lista.ListIndex < 0 Then Exit Function

    preosId = Trim$(CStr(OSListaCol(0)))
    If preosId = "" Then Exit Function

    ObterPreOSSelecionada = True
End Function

Private Function BuscarLinhaPreOS(ByVal preosId As String, ByRef linhaOut As Long) As Boolean
    Dim ws As Worksheet
    Dim i As Long

    linhaOut = 0
    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)
    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_PREOS)
        If IdsIguais(SafeListVal(ws.Cells(i, COL_PREOS_ID).Value), preosId) Then
            linhaOut = i
            BuscarLinhaPreOS = True
            Exit Function
        End If
    Next i
End Function

Private Sub RejeitarPreOSSelecionada()
    On Error GoTo Erro_Rejeitar
    Dim preosId As String
    Dim motivo As String
    Dim res As TResult

    If Not ErrorBoundary.BeginWrite("REJEITAR_PREOS") Then Exit Sub

    If Not ObterPreOSSelecionada(preosId) Then
        MsgBox "Selecione uma Pre-OS para rejeitar.", vbExclamation, "Rejeitar Pre-OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    motivo = Trim$(InputBox("Informe o motivo da rejeição da Pre-OS:", "Rejeitar Pre-OS", "RECUSA_GESTOR"))
    If motivo = "" Then
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    If MsgBox("Confirmar rejeição da Pre-OS " & preosId & "?", vbQuestion + vbYesNo, "Rejeitar Pre-OS") <> vbYes Then
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    res = RecusarPreOS(preosId, motivo)
    If Not res.Sucesso Then
        MsgBox "Falha ao rejeitar Pre-OS: " & res.mensagem, vbCritical, "Rejeitar Pre-OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    MsgBox "Pre-OS " & preosId & " rejeitada e fila avançada com punição.", vbInformation, "Rejeitar Pre-OS"
    Call PreencherPreencheOS
    Call RefreshPosPreOS
    ErrorBoundary.CommitWrite
    Exit Sub

Erro_Rejeitar:
    ErrorBoundary.RollbackWrite silent:=False
    MsgBox "Falha sistêmica ao rejeitar: " & Err.Description, vbCritical
End Sub

Private Sub ExpirarPreOSSelecionada()
    On Error GoTo Erro_Expirar
    Dim preosId As String
    Dim linhaPre As Long
    Dim ws As Worksheet
    Dim statusAtual As String
    Dim dtLimite As Variant
    Dim res As TResult

    If Not ErrorBoundary.BeginWrite("EXPIRAR_PREOS") Then Exit Sub

    If Not ObterPreOSSelecionada(preosId) Then
        MsgBox "Selecione uma Pre-OS para expirar.", vbExclamation, "Expirar Pre-OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    If Not BuscarLinhaPreOS(preosId, linhaPre) Then
        MsgBox "Pre-OS não encontrada na base.", vbExclamation, "Expirar Pre-OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)
    statusAtual = UCase$(Trim$(SafeListVal(ws.Cells(linhaPre, COL_PREOS_STATUS).Value)))
    If statusAtual <> "AGUARDANDO_ACEITE" Then
        MsgBox "A Pre-OS selecionada não está aguardando aceite (status atual: " & statusAtual & ").", vbExclamation, "Expirar Pre-OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    dtLimite = ws.Cells(linhaPre, COL_PREOS_DT_LIMITE).Value
    If IsDate(dtLimite) Then
        If CDate(dtLimite) >= Date Then
            MsgBox "A Pre-OS ainda está no prazo. Expiração manual só é permitida após o vencimento.", vbExclamation, "Expirar Pre-OS"
            ErrorBoundary.RollbackWrite silent:=True
            Exit Sub
        End If
    End If

    If MsgBox("Confirmar expiração da Pre-OS " & preosId & "?" & vbCrLf & _
              "A fila avançará com punição.", vbQuestion + vbYesNo, "Expirar Pre-OS") <> vbYes Then
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    res = ExpirarPreOS(preosId)
    If Not res.Sucesso Then
        MsgBox "Falha ao expirar Pre-OS: " & res.mensagem, vbCritical, "Expirar Pre-OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    MsgBox "Pre-OS " & preosId & " expirada e fila avançada com punição.", vbInformation, "Expirar Pre-OS"
    Call PreencherPreencheOS
    Call RefreshPosPreOS
    ErrorBoundary.CommitWrite
    Exit Sub

Erro_Expirar:
    ErrorBoundary.RollbackWrite silent:=False
    MsgBox "Falha sistêmica ao expirar: " & Err.Description, vbCritical
End Sub

Private Sub CancelarOSSelecionada()
    On Error GoTo Erro_Cancelar
    Dim osId As String
    Dim motivo As String
    Dim res As TResult

    If Not ErrorBoundary.BeginWrite("CANCELAR_OS") Then Exit Sub

    If AV_Lista.ListIndex < 0 Then
        MsgBox "Selecione uma OS para cancelar.", vbExclamation, "Cancelar OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    osId = Trim$(CStr(AVListaCol(0)))
    If osId = "" Then
        MsgBox "OS selecionada inválida.", vbExclamation, "Cancelar OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    motivo = Trim$(InputBox("Informe o motivo do cancelamento da OS:", "Cancelar OS", "CANCELAMENTO_GESTOR"))
    If motivo = "" Then
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    If MsgBox("Confirmar cancelamento da OS " & osId & "?", vbQuestion + vbYesNo, "Cancelar OS") <> vbYes Then
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    res = CancelarOS(osId, motivo)
    If Not res.Sucesso Then
        MsgBox "Falha ao cancelar OS: " & res.mensagem, vbCritical, "Cancelar OS"
        ErrorBoundary.RollbackWrite silent:=True
        Exit Sub
    End If

    MsgBox "OS " & osId & " cancelada com sucesso.", vbInformation, "Cancelar OS"
    Call PreencherAvaliarOS
    Call RefreshPosPreOS
    ErrorBoundary.CommitWrite
    Exit Sub

Erro_Cancelar:
    ErrorBoundary.RollbackWrite silent:=False
    MsgBox "Falha sistêmica ao cancelar: " & Err.Description, vbCritical
End Sub

Private Sub M_Cadastrar_Empresa_Click()
On Error GoTo erro_carregamento:
Dim wsEmpCad As Worksheet
Dim linhaNovaEmp As Long
Dim ultimo As Long
Dim i As Long
Dim novoID As String
Dim cnpjDigitado As String
Dim estavaProtegida As Boolean
Dim senhaProtecao As String
Dim avisoPosCadastro As String
Dim errNum As Long
Dim errDesc As String
Dim msgSave As String
Dim primeiraLinhaEmp As Long

cnpjDigitado = Trim$(CStr(M_CNPJ.Value))

If cnpjDigitado = "" Then
    MsgBox "Informe o CNPJ da Empresa.", vbExclamation, "Cadastro de Empresa"
    M_CNPJ.BackColor = &HFFFF&
    M_CNPJ.SetFocus
    Exit Sub
End If

If Trim$(CStr(M_Empresa.Value)) = "" Then
    MsgBox "Informe a razão social da empresa.", vbExclamation, "Cadastro de Empresa"
    M_Empresa.SetFocus
    Exit Sub
End If

Set wsEmpCad = ThisWorkbook.Sheets(SHEET_EMPRESAS)
ultimo = UltimaLinhaAba(SHEET_EMPRESAS)
primeiraLinhaEmp = PrimeiraLinhaDadosEmpresas()

' Validacao de duplicidade por CNPJ (normalizado).
If ultimo >= primeiraLinhaEmp Then
    For i = primeiraLinhaEmp To ultimo
        If NormalizarCNPJ(wsEmpCad.Cells(i, COL_EMP_CNPJ).Value) = NormalizarCNPJ(cnpjDigitado) Then
            MsgBox "Empresa já cadastrada para este CNPJ.", vbExclamation, "Cadastro de Empresa"
            M_CNPJ.BackColor = &HFFFF&
            M_CNPJ.SetFocus
            Exit Sub
        End If
    Next i
End If

If MsgBox("Deseja realmente continuar o cadastramento?", vbQuestion + vbYesNo, "Cadastro de Empresa") <> vbYes Then
    Exit Sub
End If

If Not PrepararAbaParaEscrita(wsEmpCad, estavaProtegida, senhaProtecao) Then
    MsgBox "A aba EMPRESAS está protegida e não foi possível liberar escrita pelo VBA." & vbCrLf & _
           "Verifique a senha de proteção da planilha.", vbCritical, "Cadastro de Empresa"
    Exit Sub
End If

M_CNPJ.BackColor = &H8000000F
linhaNovaEmp = UltimaLinhaAba(SHEET_EMPRESAS) + 1
If linhaNovaEmp < primeiraLinhaEmp Then linhaNovaEmp = primeiraLinhaEmp

novoID = ProximoId(SHEET_EMPRESAS)

' Gravacao robusta de cadastro na aba EMPRESAS.
With wsEmpCad
    .Cells(linhaNovaEmp, COL_EMP_ID).Value = novoID
    .Cells(linhaNovaEmp, COL_EMP_CNPJ).Value = Trim$(CStr(M_CNPJ.Value))
    .Cells(linhaNovaEmp, COL_EMP_RAZAO).Value = Funcoes.NormalizarTextoPTBR(M_Empresa.Value)
    .Cells(linhaNovaEmp, COL_EMP_INSCR_MUN).Value = Trim$(CStr(M_Insc_Mun.Value))
    .Cells(linhaNovaEmp, COL_EMP_RESPONSAVEL).Value = Funcoes.NormalizarTextoPTBR(M_Nome_Responsavel.Value)
    .Cells(linhaNovaEmp, COL_EMP_CPF_RESP).Value = Trim$(CStr(M_CPF_Responsavel.Value))
    .Cells(linhaNovaEmp, COL_EMP_ENDERECO).Value = Funcoes.NormalizarTextoPTBR(M_Endereco.Value)
    .Cells(linhaNovaEmp, COL_EMP_BAIRRO).Value = Funcoes.NormalizarTextoPTBR(M_Bairro.Value)
    .Cells(linhaNovaEmp, COL_EMP_MUNICIPIO).Value = Funcoes.NormalizarTextoPTBR(M_Municipio.Value)
    .Cells(linhaNovaEmp, COL_EMP_CEP).Value = Trim$(CStr(M_CEP.Value))
    .Cells(linhaNovaEmp, COL_EMP_UF).Value = Trim$(CStr(M_UF.Value))
    .Cells(linhaNovaEmp, COL_EMP_TEL_FIXO).Value = Trim$(CStr(M_Tel_Fixo.Value))
    .Cells(linhaNovaEmp, COL_EMP_TEL_CEL).Value = Trim$(CStr(M_Tel_Cel.Value))
    .Cells(linhaNovaEmp, COL_EMP_EMAIL).Value = Trim$(CStr(M_Email.Value))
    .Cells(linhaNovaEmp, COL_EMP_EXPERIENCIA).Value = Funcoes.NormalizarTextoPTBR(M_Temp_Exper.Value)
    .Cells(linhaNovaEmp, COL_EMP_STATUS_GLOBAL).Value = "ATIVA"
    .Cells(linhaNovaEmp, COL_EMP_DT_FIM_SUSP).Value = ""
    .Cells(linhaNovaEmp, COL_EMP_QTD_RECUSAS).Value = 0
    .Cells(linhaNovaEmp, COL_EMP_DT_CAD).Value = CDate(Now)
    .Cells(linhaNovaEmp, COL_EMP_DT_ULT_ALT).Value = CDate(Now)
End With

Call LimparCamposCadastroEmpresa
Call AtualizarPosCadastroEmpresa(avisoPosCadastro)
Call RestaurarProtecaoAba(wsEmpCad, estavaProtegida, senhaProtecao)

If Not Util_SalvarWorkbookSeguro(msgSave) Then
    If avisoPosCadastro <> "" Then avisoPosCadastro = avisoPosCadastro & " "
    avisoPosCadastro = avisoPosCadastro & "Falha ao salvar automaticamente (" & msgSave & ")."
End If

If avisoPosCadastro = "" Then
    MsgBox "Cadastro realizado com sucesso! ID: " & novoID, vbInformation, "Cadastro de Empresa"
Else
    MsgBox "Cadastro realizado com sucesso! ID: " & novoID & vbCrLf & _
           "Aviso: " & avisoPosCadastro, vbExclamation, "Cadastro de Empresa"
End If
Exit Sub

erro_carregamento:
errNum = Err.Number
errDesc = Err.Description

On Error Resume Next
If Not wsEmpCad Is Nothing Then Call RestaurarProtecaoAba(wsEmpCad, estavaProtegida, senhaProtecao)
On Error GoTo 0

If Trim$(errDesc) = "" Then
    errDesc = "Erro sem descrição (código " & CStr(errNum) & ")."
End If

MsgBox "Erro ao cadastrar empresa: " & errDesc, vbCritical, "Cadastro de Empresa"
End Sub

Private Sub LimparCamposCadastroEmpresa()
    M_CNPJ.Value = Empty
    M_Empresa.Value = Empty
    M_Insc_Mun.Value = Empty
    M_Nome_Responsavel.Value = Empty
    M_CPF_Responsavel.Value = Empty
    M_Endereco.Value = Empty
    M_Bairro.Value = Empty
    M_Municipio.Value = Empty
    M_CEP.Value = Empty
    M_UF.Value = Empty
    M_Temp_Exper.Value = Empty
    M_Tel_Fixo.Value = Empty
    M_Tel_Cel.Value = Empty
    M_Email.Value = Empty
End Sub

Private Function NormalizarCNPJ(ByVal valor As Variant) As String
    Dim s As String
    s = Trim$(CStr(valor))
    s = Replace(s, ".", "")
    s = Replace(s, "/", "")
    s = Replace(s, "-", "")
    s = Replace(s, " ", "")
    NormalizarCNPJ = s
End Function

Private Function Pad3Id(ByVal v As Variant) As String
    Dim s As String
    s = Trim$(CStr(v))
    If s = "" Then
        Pad3Id = ""
    ElseIf IsNumeric(s) Then
        Pad3Id = Format$(CLng(Val(s)), "000")
    Else
        Pad3Id = s
    End If
End Function

Private Function MensagemAmigavelPreOS(ByVal msgOriginal As String) As String
    Dim m As String
    Dim u As String
    Dim cA As Long
    Dim cB As Long
    Dim cC As Long
    Dim cD As Long
    Dim cE As Long
    Dim cSemEmp As Long

    m = Trim$(CStr(msgOriginal))
    If m = "" Then
        MensagemAmigavelPreOS = "Erro ao emitir Pre-OS."
        Exit Function
    End If

    u = UCase$(m)
    cA = ExtrairContadorMotivo(u, "A")
    cB = ExtrairContadorMotivo(u, "B")
    cC = ExtrairContadorMotivo(u, "C")
    cD = ExtrairContadorMotivo(u, "D")
    cE = ExtrairContadorMotivo(u, "E")
    cSemEmp = ExtrairContadorMotivo(u, "SEM_EMP")

    If InStr(1, u, "SEM_CREDENCIADOS_CADASTRADOS", vbTextCompare) > 0 Then
        MensagemAmigavelPreOS = "Não foi possível emitir a Pre-OS: não há empresas credenciadas para esta atividade."
        Exit Function
    End If

    If (cD > 0) And (cE = 0) And (cA + cB + cC + cSemEmp = 0) Then
        MensagemAmigavelPreOS = "Não foi possível emitir a Pre-OS: todas as empresas desta atividade estão com OS em execução."
        Exit Function
    End If

    If InStr(1, u, "BLOQUEIO=PREOS_PENDENTE", vbTextCompare) > 0 Then
        MensagemAmigavelPreOS = "Não foi possível emitir a Pre-OS: todas as empresas aptas desta atividade estão com Pre-OS pendente de aceite."
        Exit Function
    End If

    If (cD > 0) And (cE > 0) And (cA + cB + cC + cSemEmp = 0) Then
        MensagemAmigavelPreOS = "Não foi possível emitir a Pre-OS: no momento, todas as empresas estão ocupadas (OS em execução ou Pre-OS pendente)."
        Exit Function
    End If

    If (cSemEmp > 0) Or ((cA + cB + cC + cD + cE + cSemEmp) = 0 And InStr(1, u, "SEM_CREDENCIADOS", vbTextCompare) > 0) Then
        MensagemAmigavelPreOS = "Não foi possível emitir a Pre-OS: não há empresas disponíveis para esta atividade."
        Exit Function
    End If

    If InStr(1, u, "SEM_CREDENCIADOS", vbTextCompare) > 0 _
       Or InStr(1, u, "NAO HA EMPRESAS CREDENCIADAS", vbTextCompare) > 0 _
       Or InStr(1, u, "NAO HA EMPRESAS CREDENCIADAS APTAS", vbTextCompare) > 0 Then
        MensagemAmigavelPreOS = "Não foi possível emitir a Pre-OS: não há empresas disponíveis para esta atividade."
        Exit Function
    End If

    If InStr(1, u, "EMPRESA_SUSPENSA", vbTextCompare) > 0 _
       Or InStr(1, u, "SUSPENSA_GLOBAL", vbTextCompare) > 0 Then
        MensagemAmigavelPreOS = "A empresa selecionada está temporariamente suspensa. Aguarde o término do período de suspensão."
        Exit Function
    End If

    If InStr(1, u, "EMPRESA_INATIVA", vbTextCompare) > 0 _
       Or InStr(1, u, "INATIVA", vbTextCompare) > 0 Then
        MensagemAmigavelPreOS = "A empresa selecionada está inativa no credenciamento."
        Exit Function
    End If

    MensagemAmigavelPreOS = "Ocorreu um problema ao emitir a Pre-OS. Detalhes técnicos: " & m
End Function

Private Function ExtrairContadorMotivo(ByVal texto As String, ByVal chave As String) As Long
    Dim padrao As String
    Dim p As Long
    Dim i As Long
    Dim trecho As String
    Dim ch As String

    padrao = UCase$(chave) & "="
    p = InStr(1, texto, padrao, vbTextCompare)
    If p = 0 Then Exit Function

    trecho = Mid$(texto, p + Len(padrao))
    For i = 1 To Len(trecho)
        ch = Mid$(trecho, i, 1)
        If ch Like "[0-9]" Then
            ExtrairContadorMotivo = CLng(Val(Left$(trecho, i)))
        Else
            Exit For
        End If
    Next i
End Function

Private Sub AtualizarPosCadastroEmpresa(ByRef aviso As String)
    Dim msg As String

    aviso = ""
    On Error Resume Next

    Call ClassificaEmpresa
    If Err.Number <> 0 Then
        msg = "Classificacao da lista de empresas falhou (" & Err.Number & ")."
        Err.Clear
    End If

    Call AtualizarListaEmpresaMenuAtual
    If Err.Number <> 0 Then
        If msg <> "" Then msg = msg & " "
        msg = msg & "Atualizacao da lista de empresas falhou (" & Err.Number & ")."
        Err.Clear
    End If

    Call PreenchimentoCRServico
    If Err.Number <> 0 Then
        If msg <> "" Then msg = msg & " "
        msg = msg & "Atualizacao da lista de credenciamento falhou (" & Err.Number & ")."
        Err.Clear
    End If

    On Error GoTo 0
    aviso = msg
End Sub

Private Function PrepararAbaParaEscrita(ByVal ws As Worksheet, ByRef estavaProtegida As Boolean, ByRef senhaUsada As String) As Boolean
    Dim tentativas As Variant
    Dim i As Long

    senhaUsada = ""
    estavaProtegida = ws.ProtectContents

    If Not estavaProtegida Then
        PrepararAbaParaEscrita = True
        Exit Function
    End If

    tentativas = Util_SenhasTentativaProtecao()

    On Error Resume Next
    For i = LBound(tentativas) To UBound(tentativas)
        ws.Unprotect Password:=CStr(tentativas(i))
        If Not ws.ProtectContents Then
            senhaUsada = CStr(tentativas(i))
            PrepararAbaParaEscrita = True
            Exit Function
        End If
    Next i
    On Error GoTo 0

    PrepararAbaParaEscrita = False
End Function

Private Sub RestaurarProtecaoAba(ByVal ws As Worksheet, ByVal estavaProtegida As Boolean, ByVal senhaUsada As String)
    If Not estavaProtegida Then Exit Sub

    On Error Resume Next
    ws.Protect Password:=senhaUsada, UserInterfaceOnly:=True
    On Error GoTo 0
End Sub
Private Sub L_Sair_Click()
On Error GoTo erro_carregamento:

    If MsgBox("Deseja realmente continuar com o fechamento do sistema?", vbQuestion + vbYesNo, "Fechar") = vbYes Then
        
        ProgressBar.Show
        Application.Quit
        ActiveWorkbook.Close savechanges:=False
        Application.DisplayAlerts = False
        
    End If
    
Exit Sub
erro_carregamento:
End Sub

Private Sub M_CNPJ_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
M_CNPJ.Text = Funcoes.cnpj(KeyAscii, M_CNPJ.Text)
End Sub
Private Sub M_CPF_Responsavel_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
M_CPF_Responsavel.Text = Funcoes.cpf(KeyAscii, M_CPF_Responsavel.Text)
End Sub

Private Sub Btn_Empresas_Cadastradas_Click()
Dim wsEmp As Worksheet
Dim ultima As Long
Dim primeiraLinhaEmp As Long
Dim estEmp As Boolean
Dim senEmp As String

Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)
ultima = UltimaLinhaAba(SHEET_EMPRESAS)
primeiraLinhaEmp = PrimeiraLinhaDadosEmpresas()
If ultima < primeiraLinhaEmp Then
    MsgBox "Não há empresas cadastradas para listar.", vbInformation, "Relatório"
    Exit Sub
End If

If Not Util_PrepararAbaParaEscrita(wsEmp, estEmp, senEmp) Then
    MsgBox "Não foi possível preparar a aba EMPRESAS para impressão (proteção).", vbCritical, "Relatório"
    Exit Sub
End If

On Error GoTo falha_rel_emp_cad

wsEmp.Columns("A:O").AutoFit
With wsEmp.PageSetup
        .LeftHeader = ""
        .CenterHeader = "RELATORIO DE EMPRESAS CADASTRADAS NO CREDENCIAMENTO"
        .RightHeader = ""
        .LeftFooter = ""
        .CenterFooter = "Pagina &P"
        .RightFooter = ""
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .Orientation = xlLandscape
        .LeftMargin = Application.CentimetersToPoints(0.5)
        .RightMargin = Application.CentimetersToPoints(0.5)
        .TopMargin = Application.CentimetersToPoints(1.5)
        .BottomMargin = Application.CentimetersToPoints(1)
        .HeaderMargin = Application.CentimetersToPoints(0.5)
        .FooterMargin = Application.CentimetersToPoints(0.5)
        .PrintHeadings = False
        .PrintGridlines = False
        .PrintComments = xlPrintNoComments
        .PrintQuality = 600
        .CenterHorizontally = False
        .CenterVertically = False
        .Orientation = xlLandscape
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
        .EvenPage.LeftHeader.Text = ""
        .EvenPage.CenterHeader.Text = ""
        .EvenPage.RightHeader.Text = ""
        .EvenPage.LeftFooter.Text = ""
        .EvenPage.CenterFooter.Text = ""
        .EvenPage.RightFooter.Text = ""
        .FirstPage.LeftHeader.Text = ""
        .FirstPage.CenterHeader.Text = ""
        .FirstPage.RightHeader.Text = ""
        .FirstPage.LeftFooter.Text = ""
        .FirstPage.CenterFooter.Text = ""
        .FirstPage.RightFooter.Text = ""
 
'        copias = InputBox("Quantas cpias?", "Copias a serem Impressas")
        wsEmp.Range("A1:O" & ultima).PrintOut
End With
Call Util_RestaurarProtecaoAba(wsEmp, estEmp, senEmp)
Exit Sub

falha_rel_emp_cad:
On Error Resume Next
Call Util_RestaurarProtecaoAba(wsEmp, estEmp, senEmp)
On Error GoTo 0
MsgBox "Erro ao gerar relatório de empresas cadastradas: " & Err.Description, vbCritical, "Relatório"
End Sub

Private Sub Btn_Empresas_Credenciados_Click()
Dim wsCred As Worksheet
Dim wsServ As Worksheet
Dim wsRel As Worksheet
Dim i As Long
Dim j As Long
Dim ultimaCred As Long
Dim ultimaServ As Long
Dim linhaRel As Long
Dim chaveAtual As String
Dim chave As String
Dim codAtivServ As String
Dim ativId As String
Dim servId As String
Dim descAtiv As String
Dim descServ As String
Dim estRel As Boolean
Dim senRel As String

Set wsCred = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
Set wsRel = ThisWorkbook.Sheets(SHEET_REL_UI)

Call ClassificaCredenciadoRel

ultimaCred = UltimaLinhaAba(SHEET_CREDENCIADOS)
ultimaServ = UltimaLinhaAba(SHEET_CAD_SERV)

If ultimaCred < LINHA_DADOS Then
    MsgBox "Não há empresas credenciadas para listar.", vbInformation, "Relatório"
    Exit Sub
End If

If Not Util_PrepararAbaParaEscrita(wsRel, estRel, senRel) Then
    MsgBox "Não foi possível preparar a aba RELATORIO para o relatório (proteção).", vbCritical, "Relatório"
    Exit Sub
End If

On Error GoTo falha_rel_emp_cred

wsRel.Cells.ClearContents
linhaRel = 1

For i = LINHA_DADOS To ultimaCred
    codAtivServ = SafeListVal(wsCred.Cells(i, COL_CRED_COD_ATIV_SERV).Value)
    ativId = Pad3Id(wsCred.Cells(i, COL_CRED_ATIV_ID).Value)
    servId = ExtrairServIdFromCod(codAtivServ, ativId)
    If servId = "" And Len(codAtivServ) >= 6 Then servId = Right$(codAtivServ, 3)

    chave = ativId & "|" & servId
    If chave <> chaveAtual Then
        If linhaRel > 1 Then linhaRel = linhaRel + 1
        descAtiv = ""
        descServ = ""
        For j = LINHA_DADOS To ultimaServ
            If IdsIguais(SafeListVal(wsServ.Cells(j, COL_SERV_ATIV_ID).Value), ativId) And _
               IdsIguais(SafeListVal(wsServ.Cells(j, COL_SERV_ID).Value), servId) Then
                descAtiv = SafeListVal(wsServ.Cells(j, COL_SERV_ATIV_DESC).Value)
                descServ = SafeListVal(wsServ.Cells(j, COL_SERV_DESCRICAO).Value)
                Exit For
            End If
        Next j
        If descAtiv = "" Then descAtiv = "ATIVIDADE " & ativId
        If descServ = "" Then descServ = "SERVICO " & servId

        wsRel.Cells(linhaRel, 1).Value = descAtiv & " / " & descServ
        linhaRel = linhaRel + 1
        wsRel.Cells(linhaRel, 1).Value = "CNPJ EMPRESA"
        wsRel.Cells(linhaRel, 2).Value = "NOME EMPRESA"
        wsRel.Cells(linhaRel, 3).Value = "POSICAO FILA"
        wsRel.Cells(linhaRel, 4).Value = "ULTIMA OS"
        wsRel.Cells(linhaRel, 5).Value = "DATA ULT. OS"
        wsRel.Cells(linhaRel, 6).Value = "STATUS CRED."
        linhaRel = linhaRel + 1
        chaveAtual = chave
    End If

    wsRel.Cells(linhaRel, 1).Value = SafeListVal(wsCred.Cells(i, COL_CRED_CNPJ).Value)
    wsRel.Cells(linhaRel, 2).Value = SafeListVal(wsCred.Cells(i, COL_CRED_RAZAO).Value)
    wsRel.Cells(linhaRel, 3).Value = SafeListVal(wsCred.Cells(i, COL_CRED_POSICAO).Value)
    wsRel.Cells(linhaRel, 4).Value = SafeListVal(wsCred.Cells(i, COL_CRED_ULT_OS).Value)
    wsRel.Cells(linhaRel, 5).Value = SafeListVal(wsCred.Cells(i, COL_CRED_DT_ULT_OS).Value)
    wsRel.Cells(linhaRel, 6).Value = SafeListVal(wsCred.Cells(i, COL_CRED_STATUS).Value)
    linhaRel = linhaRel + 1
Next i

If linhaRel <= 1 Then
    MsgBox "Não há empresas credenciadas para listar.", vbInformation, "Relatório"
    Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
    Exit Sub
End If

wsRel.Columns("A:F").AutoFit
With wsRel.PageSetup
        .LeftHeader = ""
        .CenterHeader = "RELATORIO DE EMPRESAS CREDENCIADAS"
        .RightHeader = ""
        .LeftFooter = ""
        .CenterFooter = "Pagina &P"
        .RightFooter = ""
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .Orientation = xlLandscape
        .LeftMargin = Application.CentimetersToPoints(0.5)
        .RightMargin = Application.CentimetersToPoints(0.5)
        .TopMargin = Application.CentimetersToPoints(1.5)
        .BottomMargin = Application.CentimetersToPoints(1)
        .HeaderMargin = Application.CentimetersToPoints(0.5)
        .FooterMargin = Application.CentimetersToPoints(0.5)
End With

wsRel.Range("A1:F" & (linhaRel - 1)).PrintOut
wsRel.Range("A1:F" & (linhaRel - 1)).ClearContents
Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
Exit Sub

falha_rel_emp_cred:
On Error Resume Next
Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
On Error GoTo 0
MsgBox "Erro ao gerar relatório de empresas credenciadas: " & Err.Description, vbCritical, "Relatório"
End Sub

Private Sub OS_Emitidas_Click()
Dim wsOS As Worksheet
Dim wsRel As Worksheet
Dim ultimaOS As Long
Dim i As Long
Dim linhaRel As Long
Dim statusOS As String
Dim dtFechamento As String
Dim osId As String
Dim entId As String
Dim codServ As String
Dim empId As String
Dim estRel As Boolean
Dim senRel As String

Set wsOS = ThisWorkbook.Sheets(SHEET_CAD_OS)
Set wsRel = ThisWorkbook.Sheets(SHEET_REL_UI)

Call ClassificaDataOS

If Not Util_PrepararAbaParaEscrita(wsRel, estRel, senRel) Then
    MsgBox "Não foi possível preparar a aba RELATORIO para o relatório (proteção).", vbCritical, "Relatório"
    Exit Sub
End If

On Error GoTo falha_rel_os_emit

wsRel.Cells.ClearContents
wsRel.Cells(1, 1).Value = "N.O.S."
wsRel.Cells(1, 2).Value = "DEMANDANTE"
wsRel.Cells(1, 3).Value = "SERVICO"
wsRel.Cells(1, 4).Value = "CREDENCIADO"
wsRel.Cells(1, 5).Value = "N. EMPENHO"
wsRel.Cells(1, 6).Value = "DATA O.S."
wsRel.Cells(1, 7).Value = "DT PREV. FIM"
wsRel.Cells(1, 8).Value = "QTDE H/D"
wsRel.Cells(1, 9).Value = "VALOR TOTAL"

ultimaOS = UltimaLinhaAba(SHEET_CAD_OS)
linhaRel = 2

For i = LINHA_DADOS To ultimaOS
    statusOS = UCase$(Trim$(SafeListVal(wsOS.Cells(i, COL_OS_STATUS).Value)))
    dtFechamento = Trim$(SafeListVal(wsOS.Cells(i, COL_OS_DT_FECHAMENTO).Value))

    If statusOS = "EM_EXECUCAO" Or dtFechamento = "" Then
        osId = SafeListVal(wsOS.Cells(i, COL_OS_ID).Value)
        entId = SafeListVal(wsOS.Cells(i, COL_OS_ENT_ID).Value)
        codServ = SafeListVal(wsOS.Cells(i, COL_OS_COD_SERV).Value)
        empId = SafeListVal(wsOS.Cells(i, COL_OS_EMP_ID).Value)

        wsRel.Cells(linhaRel, 1).Value = Format$(Val(osId), "000")
        wsRel.Cells(linhaRel, 2).Value = BuscarNomeEntidadePorId(entId)
        wsRel.Cells(linhaRel, 3).Value = BuscarDescricaoServicoPorCod(codServ, wsOS.Cells(i, COL_OS_ATIV_ID).Value)
        wsRel.Cells(linhaRel, 4).Value = BuscarNomeEmpresaPorId(empId)
        wsRel.Cells(linhaRel, 5).Value = SafeListVal(wsOS.Cells(i, COL_OS_EMPENHO).Value)
        wsRel.Cells(linhaRel, 6).Value = SafeListVal(wsOS.Cells(i, COL_OS_DT_EMISSAO).Value)
        wsRel.Cells(linhaRel, 7).Value = SafeListVal(wsOS.Cells(i, COL_OS_DT_PREV_FIM).Value)
        wsRel.Cells(linhaRel, 8).Value = SafeListVal(wsOS.Cells(i, COL_OS_QT_EST).Value)
        wsRel.Cells(linhaRel, 9).Value = Format(Util_Conversao.ToCurrency(wsOS.Cells(i, COL_OS_VL_TOTAL).Value), "Currency")
        linhaRel = linhaRel + 1
    End If
Next i

If linhaRel = 2 Then
    MsgBox "Não há ordens de serviço abertas para listar.", vbInformation, "Relatório"
    Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
    Exit Sub
End If

wsRel.Columns("A:I").AutoFit
With wsRel.PageSetup
        .LeftHeader = ""
        .CenterHeader = "RELATORIO DE ORDENS DE SERVICO ABERTAS"
        .RightHeader = ""
        .LeftFooter = ""
        .CenterFooter = "Pagina &P"
        .RightFooter = ""
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .Orientation = xlLandscape
        .LeftMargin = Application.CentimetersToPoints(0.5)
        .RightMargin = Application.CentimetersToPoints(0.5)
        .TopMargin = Application.CentimetersToPoints(1.5)
        .BottomMargin = Application.CentimetersToPoints(1)
        .HeaderMargin = Application.CentimetersToPoints(0.5)
        .FooterMargin = Application.CentimetersToPoints(0.5)
        .PrintHeadings = False
        .PrintGridlines = False
        .PrintComments = xlPrintNoComments
        .PrintQuality = 600
        .CenterHorizontally = False
        .CenterVertically = False
        .Orientation = xlLandscape
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
        .EvenPage.LeftHeader.Text = ""
        .EvenPage.CenterHeader.Text = ""
        .EvenPage.RightHeader.Text = ""
        .EvenPage.LeftFooter.Text = ""
        .EvenPage.CenterFooter.Text = ""
        .EvenPage.RightFooter.Text = ""
        .FirstPage.LeftHeader.Text = ""
        .FirstPage.CenterHeader.Text = ""
        .FirstPage.RightHeader.Text = ""
        .FirstPage.LeftFooter.Text = ""
        .FirstPage.CenterFooter.Text = ""
        .FirstPage.RightFooter.Text = ""
End With

wsRel.Range("A1:I" & (linhaRel - 1)).PrintOut

wsRel.Range("A1:I" & (linhaRel - 1)).ClearContents
Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
Call ClassificaOS
Exit Sub

falha_rel_os_emit:
On Error Resume Next
Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
On Error GoTo 0
MsgBox "Erro ao gerar relatório de ordens de serviço abertas: " & Err.Description, vbCritical, "Relatório"
End Sub

Private Sub OS_Lista_Click()
    ' Refatorado: sem Select/ActiveCell; preenchimento resiliente da tela a partir da lista e da PRE_OS.
    Dim nPre As String
    Dim linPre As Long
    Dim wsPreOS As Worksheet
    Dim wsEntidade As Worksheet
    Dim wsCadServ As Worksheet
    Dim wsEmp As Worksheet
    Dim rngResult As Range
    Dim rPre As Range
    
    Set wsPreOS = ThisWorkbook.Sheets(SHEET_PREOS)
    Set wsEntidade = ThisWorkbook.Sheets(SHEET_ENTIDADE)
    Set wsCadServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)

    If OS_Lista.ListIndex < 0 Then Exit Sub
    
    ' Preencher campos do formulrio a partir da linha selecionada na lista (SafeListVal evita erro 380)
    OS_CNPJ.Value = OSListaCol(7)        ' col 7 = CNPJ Empresa
    TXT_OS_NomeEmpresa.Value = OSListaCol(3)     ' col 3 = Nome Empresa
    OS_Demandante.Value = OSListaCol(1)  ' col 1 = Nome Entidade
    OS_Atividade.Value = OSListaCol(5)   ' col 5 = Descricao Atividade
    OS_Servico.Value = OSListaCol(2)     ' col 2 = Descricao Servico
    
    ' Coluna 11 e 12 podem ter QT e Valor se foram gravados na PRE_OS
    If OSListaCol(11) <> "" Then OS_QT_Estimada.Value = OSListaCol(11)
    
    ' Se a lista veio com campos vazios, refazer preenchimento usando a origem (PRE_OS + ENTIDADE/CAD_SERV/Empresa)
    If Trim(OS_Demandante.Value) = "" Or Trim(OS_CNPJ.Value) = "" Then
        nPre = OSListaCol(0) ' col 0 = No Pre-OS
        Set rPre = Nothing
        For linPre = LINHA_DADOS To UltimaLinhaAba(SHEET_PREOS)
            If IdsIguais(SafeListVal(wsPreOS.Cells(linPre, COL_PREOS_ID).Value), nPre) Then
                Set rPre = wsPreOS.Cells(linPre, COL_PREOS_ID)
                Exit For
            End If
        Next linPre
        
        If Not rPre Is Nothing Then
            linPre = rPre.row
            
            ' ENTIDADE a partir da col 2 da PRE_OS
            Set rngResult = Nothing
            Dim jEnt As Long
            For jEnt = LINHA_DADOS To UltimaLinhaAba(SHEET_ENTIDADE)
                If IdsIguais(SafeListVal(ThisWorkbook.Sheets(SHEET_ENTIDADE).Cells(jEnt, COL_ENT_ID).Value), _
                             SafeListVal(wsPreOS.Cells(linPre, COL_PREOS_ENT_ID).Value)) Then
                    OS_Demandante.Value = SafeListVal(ThisWorkbook.Sheets(SHEET_ENTIDADE).Cells(jEnt, COL_ENT_NOME).Value)
                    Exit For
                End If
            Next jEnt
            
            ' Servico/atividade a partir da PRE_OS (suporta formato novo e legado)
            Dim codPre As String
            Dim ativPre As String
            Dim servPre As String
            Dim j As Long

            codPre = SafeListVal(wsPreOS.Cells(linPre, COL_PREOS_COD_SERV).Value)
            ativPre = SafeListVal(wsPreOS.Cells(linPre, COL_PREOS_ATIV_ID).Value)
            servPre = ExtrairServIdFromCod(codPre, ativPre)
            For j = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_SERV)
                If IdsIguais(SafeListVal(wsCadServ.Cells(j, COL_SERV_ID).Value), servPre) And _
                   IdsIguais(SafeListVal(wsCadServ.Cells(j, COL_SERV_ATIV_ID).Value), ativPre) Then
                    OS_Atividade.Value = SafeListVal(wsCadServ.Cells(j, COL_SERV_ATIV_DESC).Value)
                    OS_Servico.Value = SafeListVal(wsCadServ.Cells(j, COL_SERV_DESCRICAO).Value)
                    VL_Pagto = Util_Conversao.ToDouble(CStr(wsCadServ.Cells(j, COL_SERV_VALOR_UNIT).Value))
                    Exit For
                End If
            Next j
            
            ' Empresa a partir da col 4 da PRE_OS
            Set rngResult = Nothing
            Dim jEmp As Long
            For jEmp = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
                If IdsIguais(SafeListVal(wsEmp.Cells(jEmp, COL_EMP_ID).Value), _
                             SafeListVal(wsPreOS.Cells(linPre, COL_PREOS_EMP_ID).Value)) Then
                    OS_CNPJ.Value = SafeListVal(wsEmp.Cells(jEmp, COL_EMP_CNPJ).Value)
                    TXT_OS_NomeEmpresa.Value = SafeListVal(wsEmp.Cells(jEmp, COL_EMP_RAZAO).Value)
                    Exit For
                End If
            Next jEmp
            
            ' Quantidade estimada armazenada na PRE_OS (col 9)
            If OS_QT_Estimada.Value = "" And wsPreOS.Cells(linPre, 9).Value <> "" Then
                OS_QT_Estimada.Value = SafeListVal(wsPreOS.Cells(linPre, 9).Value)
            End If
        End If
    End If

    If Trim$(CStr(OS_QT_Estimada.Value)) = "" Or _
       Util_Conversao.ToDouble(CStr(OS_QT_Estimada.Value)) <= 0 Then
        OS_QT_Estimada.Value = "1"
    End If

    If Trim$(CStr(OS_DT_Fim.Value)) = "" Then
        OS_DT_Fim.Value = Format$(DateAdd("d", PrazoPadraoOSDias(), Date), "DD/MM/YYYY")
    End If

    If Trim$(CStr(N_Empenho.Value)) = "" Then
        N_Empenho.Value = GerarEmpenhoPadrao(OSListaCol(0))
    End If
    
    ' Buscar valor unitario do servico a partir do ID da coluna 8 da lista
    Dim idServ As String
    idServ = OSListaCol(8)
    If idServ <> "" Then
        Set rngResult = wsCadServ.Range("A:A").Find(What:=idServ, LookAt:=xlWhole) ' col 8 = ID Servio
        If Not rngResult Is Nothing Then
            VL_Pagto = Util_Conversao.ToDouble(CStr(rngResult.Offset(0, 4).Value)) ' col 5 = valor unitario
        End If
    End If
    
    ' Calcular valor estimado somente quando quantidade estiver preenchida.
    If Trim(CStr(OS_QT_Estimada.Value)) <> "" Then
        QT_ESTIMADA = Util_Conversao.ToDouble(CStr(OS_QT_Estimada.Value))
        If QT_ESTIMADA <= 0 Then QT_ESTIMADA = 1
        Vl_estimado = QT_ESTIMADA * VL_Pagto
    End If
End Sub

Private Function OSListaCol(ByVal idx As Long) As String
    On Error GoTo fim
    If OS_Lista.ListIndex < 0 Then Exit Function
    If idx < 0 Or idx >= OS_Lista.ColumnCount Then Exit Function
    OSListaCol = SafeListVal(OS_Lista.List(OS_Lista.ListIndex, idx))
    Exit Function
fim:
    OSListaCol = ""
End Function

Private Function AVListaCol(ByVal idx As Long) As String
    On Error GoTo fim
    If AV_Lista.ListIndex < 0 Then Exit Function
    If idx < 0 Or idx >= AV_Lista.ColumnCount Then Exit Function
    AVListaCol = SafeListVal(AV_Lista.List(AV_Lista.ListIndex, idx))
    Exit Function
fim:
    AVListaCol = ""
End Function

Private Function PrazoPadraoOSDias() As Long
    Dim wsCfg As Worksheet
    Dim valorCfg As Variant
    Dim dias As Long

    dias = PRAZO_PADRAO_OS_DIAS
    On Error GoTo fim
    Set wsCfg = ThisWorkbook.Sheets(SHEET_CONFIG)
    valorCfg = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_PRAZO_PREOS).Value
    If IsNumeric(valorCfg) Then
        If CLng(Val(valorCfg)) > 0 Then dias = CLng(Val(valorCfg))
    End If
fim:
    PrazoPadraoOSDias = dias
End Function

Private Function TryParseDataBR(ByVal texto As String, ByRef dtOut As Date) As Boolean
    Dim partes() As String
    Dim d As Long
    Dim m As Long
    Dim y As Long

    texto = Trim$(texto)
    If texto = "" Then Exit Function

    partes = Split(texto, "/")
    If UBound(partes) <> 2 Then Exit Function
    If Not IsNumeric(partes(0)) Or Not IsNumeric(partes(1)) Or Not IsNumeric(partes(2)) Then Exit Function

    d = CLng(Val(partes(0)))
    m = CLng(Val(partes(1)))
    y = CLng(Val(partes(2)))

    If y < 100 Then y = 2000 + y
    If d < 1 Or d > 31 Then Exit Function
    If m < 1 Or m > 12 Then Exit Function
    If y < 1900 Then Exit Function

    On Error GoTo falha
    dtOut = DateSerial(y, m, d)
    If Day(dtOut) <> d Or Month(dtOut) <> m Or Year(dtOut) <> y Then Exit Function
    TryParseDataBR = True
    Exit Function
falha:
    TryParseDataBR = False
End Function

Private Function GerarEmpenhoPadrao(ByVal preosId As String) As String
    Dim sufixo As String

    sufixo = ApenasDigitos(preosId)
    If sufixo = "" Then
        sufixo = Format$(Now, "HHMMSS")
    Else
        sufixo = Right$("000000" & sufixo, 6)
    End If

    GerarEmpenhoPadrao = "EMP-" & Format$(Date, "YYYYMMDD") & "-" & sufixo
End Function

Private Function ApenasDigitos(ByVal texto As String) As String
    Dim i As Long
    Dim c As String
    Dim saida As String

    texto = CStr(texto)
    For i = 1 To Len(texto)
        c = Mid$(texto, i, 1)
        If c >= "0" And c <= "9" Then saida = saida & c
    Next i

    ApenasDigitos = saida
End Function

Private Function NotaSegura(ByVal valor As Variant) As Integer
    Dim n As Long
    n = CLng(Val("" & valor))
    If n < 0 Then n = 0
    If n > 10 Then n = 10
    NotaSegura = CInt(n)
End Function

Private Function ExtrairServIdFromCod(ByVal codServ As String, ByVal ativId As String) As String
    Dim s As String
    Dim a As String
    Dim p As Long

    s = Trim$(CStr(codServ))
    a = Trim$(CStr(ativId))
    If s = "" Then Exit Function

    p = InStr(1, s, "|", vbBinaryCompare)
    If p > 1 Then
        ExtrairServIdFromCod = Trim$(Mid$(s, p + 1))
        Exit Function
    End If

    If a <> "" And Left$(s, Len(a)) = a Then
        ExtrairServIdFromCod = Mid$(s, Len(a) + 1)
        Exit Function
    End If

    If Len(s) >= 4 Then ExtrairServIdFromCod = Mid$(s, 4)
End Function

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

Private Function BuscarNomeEntidadePorId(ByVal entId As Variant) As String
    Dim wsEnt As Worksheet
    Dim ultima As Long
    Dim i As Long
    Dim alvo As String

    alvo = Trim$(SafeListVal(entId))
    If alvo = "" Then Exit Function

    Set wsEnt = ThisWorkbook.Sheets(SHEET_ENTIDADE)
    ultima = UltimaLinhaAba(SHEET_ENTIDADE)

    For i = LINHA_DADOS To ultima
        If IdsIguais(SafeListVal(wsEnt.Cells(i, COL_ENT_ID).Value), alvo) Then
            BuscarNomeEntidadePorId = SafeListVal(wsEnt.Cells(i, COL_ENT_NOME).Value)
            Exit Function
        End If
    Next i

    BuscarNomeEntidadePorId = alvo
End Function

Private Function BuscarNomeEmpresaPorId(ByVal empId As Variant) As String
    Dim wsEmp As Worksheet
    Dim ultima As Long
    Dim i As Long
    Dim alvo As String

    alvo = Trim$(SafeListVal(empId))
    If alvo = "" Then Exit Function

    Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    ultima = UltimaLinhaAba(SHEET_EMPRESAS)

    For i = PrimeiraLinhaDadosEmpresas() To ultima
        If IdsIguais(SafeListVal(wsEmp.Cells(i, COL_EMP_ID).Value), alvo) Then
            BuscarNomeEmpresaPorId = SafeListVal(wsEmp.Cells(i, COL_EMP_RAZAO).Value)
            Exit Function
        End If
    Next i

    BuscarNomeEmpresaPorId = alvo
End Function

Private Function BuscarDescricaoServicoPorCod(ByVal codServRaw As Variant, ByVal ativIdRaw As Variant) As String
    Dim wsServ As Worksheet
    Dim ultima As Long
    Dim i As Long
    Dim codServ As String
    Dim ativId As String
    Dim servId As String

    codServ = Trim$(SafeListVal(codServRaw))
    ativId = Pad3Id(ativIdRaw)
    servId = ExtrairServIdFromCod(codServ, ativId)

    If servId = "" And Len(codServ) >= 3 Then servId = Right$(codServ, 3)

    Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    ultima = UltimaLinhaAba(SHEET_CAD_SERV)

    For i = LINHA_DADOS To ultima
        If IdsIguais(SafeListVal(wsServ.Cells(i, COL_SERV_ATIV_ID).Value), ativId) And _
           (IdsIguais(SafeListVal(wsServ.Cells(i, COL_SERV_ID).Value), servId) Or _
            IdsIguais(SafeListVal(wsServ.Cells(i, COL_SERV_ID).Value), codServ)) Then
            BuscarDescricaoServicoPorCod = SafeListVal(wsServ.Cells(i, COL_SERV_DESCRICAO).Value)
            Exit Function
        End If
    Next i

    If codServ <> "" Then
        BuscarDescricaoServicoPorCod = codServ
    Else
        BuscarDescricaoServicoPorCod = "SERVICO"
    End If
End Function

Private Sub Btn_Rel_OS_Empresa_Click()
    ' Relatorio "Ordens de Servico por Empresa" — nome separado do TextBox TXT_OS_NomeEmpresa (evita colisao OS_Empresa).
    On Error GoTo falha
    Call PreenchimentoRelatorioOSEmpresa
    Rel_OSEmpresa.Show vbModal
    Exit Sub
falha:
    MsgBox "Erro ao abrir relatorio OS por Empresa: " & Err.Description, vbCritical, "Relatorio"
End Sub

Private Sub PRE_OS_Vencidas_Click()
Dim wsPre As Worksheet
Dim wsRel As Worksheet
Dim ultimaPre As Long
Dim i As Long
Dim linhaRel As Long
Dim prazoDias As Long
Dim dtLimite As Variant
Dim dtEmissao As Variant
Dim cutoff As Date
Dim statusPre As String
Dim preosId As String
Dim entId As String
Dim empId As String
Dim codServ As String
Dim estRel As Boolean
Dim senRel As String

Set wsPre = ThisWorkbook.Sheets(SHEET_PREOS)
Set wsRel = ThisWorkbook.Sheets(SHEET_REL_UI)

Call ClassificaDataPreOS

prazoDias = CLng(Val(PR_Val_OS))
If prazoDias <= 0 Then prazoDias = 30
cutoff = DateAdd("d", -prazoDias, Date)

If Not Util_PrepararAbaParaEscrita(wsRel, estRel, senRel) Then
    MsgBox "Não foi possível preparar a aba RELATORIO para o relatório (proteção).", vbCritical, "Relatório"
    Exit Sub
End If

On Error GoTo falha_rel_pre_venc

wsRel.Cells.ClearContents
wsRel.Cells(1, 1).Value = "N. PRE O.S."
wsRel.Cells(1, 2).Value = "DEMANDANTE"
wsRel.Cells(1, 3).Value = "SERVICO"
wsRel.Cells(1, 4).Value = "CREDENCIADO"
wsRel.Cells(1, 5).Value = "DATA PRE O.S."
wsRel.Cells(1, 6).Value = "DATA LIMITE"

ultimaPre = UltimaLinhaAba(SHEET_PREOS)
linhaRel = 2

For i = LINHA_DADOS To ultimaPre
    statusPre = UCase$(Trim$(SafeListVal(wsPre.Cells(i, COL_PREOS_STATUS).Value)))
    If statusPre <> "AGUARDANDO_ACEITE" Then GoTo ProximoPre

    dtLimite = wsPre.Cells(i, COL_PREOS_DT_LIMITE).Value
    dtEmissao = wsPre.Cells(i, COL_PREOS_DT_EMISSAO).Value

    If IsDate(dtLimite) Then
        If CDate(dtLimite) >= Date Then GoTo ProximoPre
    ElseIf IsDate(dtEmissao) Then
        If CDate(dtEmissao) >= cutoff Then GoTo ProximoPre
    Else
        GoTo ProximoPre
    End If

    preosId = SafeListVal(wsPre.Cells(i, COL_PREOS_ID).Value)
    entId = SafeListVal(wsPre.Cells(i, COL_PREOS_ENT_ID).Value)
    codServ = SafeListVal(wsPre.Cells(i, COL_PREOS_COD_SERV).Value)
    empId = SafeListVal(wsPre.Cells(i, COL_PREOS_EMP_ID).Value)

    wsRel.Cells(linhaRel, 1).Value = Format$(Val(preosId), "000")
    wsRel.Cells(linhaRel, 2).Value = BuscarNomeEntidadePorId(entId)
    wsRel.Cells(linhaRel, 3).Value = BuscarDescricaoServicoPorCod(codServ, wsPre.Cells(i, COL_PREOS_ATIV_ID).Value)
    wsRel.Cells(linhaRel, 4).Value = BuscarNomeEmpresaPorId(empId)
    wsRel.Cells(linhaRel, 5).Value = SafeListVal(wsPre.Cells(i, COL_PREOS_DT_EMISSAO).Value)
    wsRel.Cells(linhaRel, 6).Value = SafeListVal(wsPre.Cells(i, COL_PREOS_DT_LIMITE).Value)
    linhaRel = linhaRel + 1

ProximoPre:
Next i

If linhaRel = 2 Then
    MsgBox "Não há pré-OS vencidas para listar.", vbInformation, "Relatório"
    Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
    Exit Sub
End If

wsRel.Columns("A:F").AutoFit
With wsRel.PageSetup
        .LeftHeader = ""
        .CenterHeader = "RELATORIO DE ORDENS DE SERVICO ABERTAS"
        .RightHeader = ""
        .LeftFooter = ""
        .CenterFooter = "Pagina &P"
        .RightFooter = ""
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .Orientation = xlLandscape
        .LeftMargin = Application.CentimetersToPoints(0.5)
        .RightMargin = Application.CentimetersToPoints(0.5)
        .TopMargin = Application.CentimetersToPoints(1.5)
        .BottomMargin = Application.CentimetersToPoints(1)
        .HeaderMargin = Application.CentimetersToPoints(0.5)
        .FooterMargin = Application.CentimetersToPoints(0.5)
        .PrintHeadings = False
        .PrintGridlines = False
        .PrintComments = xlPrintNoComments
        .PrintQuality = 600
        .CenterHorizontally = False
        .CenterVertically = False
        .Orientation = xlLandscape
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
        .EvenPage.LeftHeader.Text = ""
        .EvenPage.CenterHeader.Text = ""
        .EvenPage.RightHeader.Text = ""
        .EvenPage.LeftFooter.Text = ""
        .EvenPage.CenterFooter.Text = ""
        .EvenPage.RightFooter.Text = ""
        .FirstPage.LeftHeader.Text = ""
        .FirstPage.CenterHeader.Text = ""
        .FirstPage.RightHeader.Text = ""
        .FirstPage.LeftFooter.Text = ""
        .FirstPage.CenterFooter.Text = ""
        .FirstPage.RightFooter.Text = ""
End With

wsRel.Range("A1:F" & (linhaRel - 1)).PrintOut

wsRel.Range("A1:F" & (linhaRel - 1)).ClearContents
Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
Call ClassificaPreOS
Exit Sub

falha_rel_pre_venc:
On Error Resume Next
Call Util_RestaurarProtecaoAba(wsRel, estRel, senRel)
On Error GoTo 0
MsgBox "Erro ao gerar relatório de pré-OS vencidas: " & Err.Description, vbCritical, "Relatório"
End Sub

Private Sub Rel_EmpXServ_Click()

Call PreenchimentoRel_EmpXServ

Rel_Emp_Serv.Show

End Sub








































Private Sub BT_PREOS_REJEITAR_Click()
    On Error GoTo falha
    Call RejeitarPreOSSelecionada
    Exit Sub
falha:
    MsgBox "Falha ao rejeitar Pre-OS: " & Err.Description, vbCritical, "Rejeitar Pre-OS"
End Sub

Private Sub BT_PREOS_EXPIRAR_Click()
    On Error GoTo falha
    Call ExpirarPreOSSelecionada
    Exit Sub
falha:
    MsgBox "Falha ao expirar Pre-OS: " & Err.Description, vbCritical, "Expirar Pre-OS"
End Sub

Private Sub BT_OS_CANCELAR_Click()
    On Error GoTo falha
    Call CancelarOSSelecionada
    Exit Sub
falha:
    MsgBox "Falha ao cancelar OS: " & Err.Description, vbCritical, "Cancelar OS"
End Sub

' Alias opcional (designer): botao "Cancelar SS" com Name alternativo.
Private Sub BT_CANCELAR_SS_Click()
    On Error GoTo falha
    Call CancelarOSSelecionada
    Exit Sub
falha:
    MsgBox "Falha ao cancelar OS: " & Err.Description, vbCritical, "Cancelar OS"
End Sub












Private Sub UI_AjustarUmBotaoReativaSeAplicavel(ByVal ctl As Object)
    On Error Resume Next
    Dim btn As MSForms.CommandButton
    Dim cap As String
    If TypeName(ctl) <> "CommandButton" Then Exit Sub
    cap = UCase$(Trim$(CStr(ctl.caption)))
    If InStr(1, cap, "REATIVA", vbTextCompare) = 0 Then Exit Sub
    Set btn = ctl
    btn.PicturePosition = fmPicturePositionLeftCenter
    If btn.Width > 0# And btn.Width < 150# Then btn.Width = btn.Width + 16#
    On Error GoTo 0
End Sub

Private Sub UI_AjustarBotoesReativaComImagem()
    Dim ctl As Object
    Dim pg As Object
    Dim mp As Object
    On Error Resume Next
    For Each ctl In Me.Controls
        Call UI_AjustarUmBotaoReativaSeAplicavel(ctl)
    Next ctl
    Set mp = Me.Controls("PAGINAS")
    If Not mp Is Nothing Then
        For Each pg In mp.Pages
            For Each ctl In pg.Controls
                Call UI_AjustarUmBotaoReativaSeAplicavel(ctl)
            Next ctl
        Next pg
    End If
    On Error GoTo 0
End Sub

Private Sub UserForm_Initialize()
    Dim wsCfg As Worksheet

    ' Inicializacao resiliente: falhas pontuais nao podem "matar" o menu principal.
    On Error Resume Next
    mInicializando = True
    Me.caption = "SISTEMA DE CREDENCIAMENTO"
    Call PreenchimentoEscolhaAtividade
    Call PreenchimentoEntidade
    Call PreenchimentoEmpresa
    Call PreenchimentoEntidadeRodizio
    Call PreencherPreencheOS
    Call PreencherAvaliarOS
    Call PreenchimentoRelatorioOSEmpresa
    Call PreencherManutencaoValor
    Call PreenchimentoListaAtividade
    Call Tela_Inicial
    Call AlinharCabecalhosListaEmpresa
    PAGINAS.Style = fmTabStyleNone

    Set wsCfg = ThisWorkbook.Sheets(SHEET_CONFIG)
    If Not wsCfg Is Nothing Then
        Gestor_Empresa = CStr(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_GESTOR).Value)
        municipio = CStr(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MUNICIPIO).Value)
        PR_Val_OS = CStr(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_PRAZO_PREOS).Value)
    End If
    If Trim$(PR_Val_OS) = "" Or PR_Val_OS = "0" Then PR_Val_OS = "30"
    TP_Valor = ""

    Call InicializarAcoesPreOS
    Call InicializarAcoesOS
    Call Filtros_CriarDinamico
    Call AplicarFiltrosAtribuicao
    Call UI_AjustarBotoesReativaComImagem

    mInicializando = False
    Err.Clear
    On Error GoTo 0
End Sub

Private Sub AplicarFiltrosAtribuicao()
    On Error Resume Next
    If Not mTxtFiltroServico Is Nothing Then Call PreenchimentoServico(mTxtFiltroServico.Text)
    If Not mTxtFiltroRodizio Is Nothing Then Call PreenchimentoEntidadeRodizio(mTxtFiltroRodizio.Text)
    On Error GoTo 0
End Sub

Private Function UI_CaptionContemTodos(ByVal caption As String, ByVal texto1 As String, Optional ByVal texto2 As String = "") As Boolean
    Dim alvo As String

    alvo = UCase$(Trim$(caption))
    If alvo = "" Then Exit Function

    UI_CaptionContemTodos = True
    If InStr(1, alvo, UCase$(Trim$(texto1)), vbTextCompare) = 0 Then
        UI_CaptionContemTodos = False
        Exit Function
    End If
    If Trim$(texto2) <> "" Then
        If InStr(1, alvo, UCase$(Trim$(texto2)), vbTextCompare) = 0 Then
            UI_CaptionContemTodos = False
            Exit Function
        End If
    End If
End Function

Private Function UI_EncontrarBotaoPorTextos(ByVal texto1 As String, Optional ByVal texto2 As String = "") As MSForms.CommandButton
    Dim ctl As Object
    Dim mp As Object
    Dim pg As Object

    On Error GoTo fim

    For Each ctl In Me.Controls
        If TypeName(ctl) = "CommandButton" Then
            If UI_CaptionContemTodos(CStr(ctl.caption), texto1, texto2) Then
                Set UI_EncontrarBotaoPorTextos = ctl
                Exit Function
            End If
        End If
    Next ctl

    Set mp = Nothing
    Set mp = Me.Controls("PAGINAS")
    If Not mp Is Nothing Then
        For Each pg In mp.Pages
            For Each ctl In pg.Controls
                If TypeName(ctl) = "CommandButton" Then
                    If UI_CaptionContemTodos(CStr(ctl.caption), texto1, texto2) Then
                        Set UI_EncontrarBotaoPorTextos = ctl
                        Exit Function
                    End If
                End If
            Next ctl
        Next pg
    End If

fim:
End Function

Private Function AbrirURLExterna(ByVal url As String) As Boolean
    On Error Resume Next

    Application.FollowHyperlink url
    If Err.Number = 0 Then
        AbrirURLExterna = True
        Exit Function
    End If

    Err.Clear
    ThisWorkbook.FollowHyperlink url
    If Err.Number = 0 Then
        AbrirURLExterna = True
        Exit Function
    End If

    Err.Clear
    If InStr(1, Application.OperatingSystem, "Windows", vbTextCompare) > 0 Then
        Shell "cmd.exe /c start """" """ & url & """", vbNormalFocus
    ElseIf InStr(1, Application.OperatingSystem, "Mac", vbTextCompare) > 0 Then
        Shell "open """ & url & """", vbNormalFocus
    End If

    AbrirURLExterna = (Err.Number = 0)
    Err.Clear
    On Error GoTo 0
End Function

Private Sub Menu_TelaInicial_AbrirCentralTestes()
    On Error GoTo falha
    If Not Treinamento_ConfirmarUso() Then Exit Sub
    Call Menu_RecolherParaBateria
    Call CT_AbrirCentral
    Exit Sub
falha:
    MsgBox "Erro ao abrir Central de Testes: " & Err.Description, vbExclamation, "Central de Testes"
End Sub

Private Sub Menu_TelaInicial_MostrarSobre()
    Dim msg As String
    msg = "Sistema de Credenciamento e Rodízio de Pequenos Reparos"
    msg = msg & vbCrLf & vbCrLf & "Linha pública source-available e auditável para gestão municipal"
    msg = msg & vbCrLf & "de credenciamento, rodízio, Pre-OS, OS e avaliação de prestadores."
    msg = msg & vbCrLf & vbCrLf & "Release oficial: " & AppRelease_Atual()
    msg = msg & vbCrLf & "Status oficial: " & AppRelease_Status()
    msg = msg & vbCrLf & "Canal ativo: " & AppRelease_Canal()
    msg = msg & vbCrLf & "Próxima release alvo: " & AppRelease_Alvo()
    msg = msg & vbCrLf & "Build importado: " & AppRelease_BuildImportado()
    msg = msg & vbCrLf & "Origem do build: " & AppRelease_BuildBranch()
    msg = msg & vbCrLf & "Pacote gerado em: " & AppRelease_BuildGeradoEm()
    msg = msg & vbCrLf & vbCrLf & "Objetivo:"
    msg = msg & vbCrLf & "Promover o rodízio de forma auditável e segura. O sistema escolhe"
    msg = msg & vbCrLf & "a empresa apta da vez e pula quem está inativo, suspenso, com OS"
    msg = msg & vbCrLf & "aberta ou com Pré-OS pendente."
    msg = msg & vbCrLf & vbCrLf & "Licença pública: TPGL v1.1 (veja LICENSE no GitHub oficial)"
    msg = msg & vbCrLf & vbCrLf & "Autor: Sérgio Cintra"
    msg = msg & vbCrLf & "Co-autoria, Desenvolvimento e Evolução: Luís Maurício Junqueira Zanin"
    msg = msg & vbCrLf & vbCrLf & "Use o botão 'GitHub' para abrir o repositório oficial."
    msg = msg & vbCrLf & "Clique em OK para voltar ao sistema."

    MsgBox msg, vbInformation + vbOKOnly, "Sobre"
End Sub

Private Sub Menu_TelaInicial_AbrirGitHub()
    If Not AbrirURLExterna(AppRelease_GitHubRepoUrl()) Then
        MsgBox "Não foi possível abrir o navegador automaticamente." & vbCrLf & _
               "Acesse manualmente:" & vbCrLf & AppRelease_GitHubRepoUrl(), _
               vbExclamation, "GitHub"
    End If
End Sub

Private Sub BT_CENTRAL_TESTES_Click()
    Call Menu_TelaInicial_AbrirCentralTestes
End Sub

Private Sub BT_SOBRE_Click()
    Call Menu_TelaInicial_MostrarSobre
End Sub

Private Sub BT_GITHUB_Click()
    Call Menu_TelaInicial_AbrirGitHub
End Sub

' ============================================================
' HANDLERS LEGADOS (designer) — manter enquanto existirem CommandButton13/14/15
' ============================================================
Private Sub CommandButton15_Click()
    Call Menu_TelaInicial_AbrirCentralTestes
End Sub

Private Sub CommandButton13_Click()
    Call Menu_TelaInicial_MostrarSobre
End Sub

Private Sub CommandButton14_Click()
    Call Menu_TelaInicial_AbrirGitHub
End Sub

Private Function UI_TextBoxSeExistePagina(ByVal container As Object, ByVal nome As String) As MSForms.TextBox
    On Error Resume Next
    Set UI_TextBoxSeExistePagina = container.Controls(nome)
    On Error GoTo 0
End Function

Private Function UI_ControleTemFilhos(ByVal ctl As Object) As Boolean
    On Error GoTo fim
    UI_ControleTemFilhos = (ctl.Controls.count >= 0)
    Exit Function
fim:
    UI_ControleTemFilhos = False
End Function

Private Function UI_TextBoxSeExisteRecursivo(ByVal container As Object, ByVal nome As String) As MSForms.TextBox
    Dim ctl As Object

    On Error Resume Next
    Set UI_TextBoxSeExisteRecursivo = container.Controls(nome)
    On Error GoTo 0
    If Not UI_TextBoxSeExisteRecursivo Is Nothing Then Exit Function

    For Each ctl In container.Controls
        If UI_ControleTemFilhos(ctl) Then
            Set UI_TextBoxSeExisteRecursivo = UI_TextBoxSeExisteRecursivo(ctl, nome)
            If Not UI_TextBoxSeExisteRecursivo Is Nothing Then Exit Function
        End If
    Next ctl
End Function

Private Sub UI_PegarMelhorTextBoxBuscaRecursivo(ByVal container As Object, ByVal topoMin As Double, ByVal topoMax As Double, ByRef melhor As MSForms.TextBox, ByRef leftMax As Double)
    Dim ctl As Object
    Dim topAbs As Double
    Dim leftAbs As Double

    For Each ctl In container.Controls
        If TypeName(ctl) = "TextBox" Then
            topAbs = UI_PosicaoTopoAbsoluta(ctl)
            leftAbs = UI_PosicaoEsquerdaAbsoluta(ctl)
            If topAbs <= topoMax And topAbs >= topoMin Then
                If ctl.Height <= 22 And ctl.Width >= 80 Then
                    If leftAbs > leftMax Then
                        leftMax = leftAbs
                        Set melhor = ctl
                    End If
                End If
            End If
        End If

        If UI_ControleTemFilhos(ctl) Then
            Call UI_PegarMelhorTextBoxBuscaRecursivo(ctl, topoMin, topoMax, melhor, leftMax)
        End If
    Next ctl
End Sub

Private Function UI_PosicaoTopoAbsoluta(ByVal ctl As Object) As Double
    Dim p As Object
    Dim y As Double

    On Error GoTo fim
    y = ctl.Top
    Set p = ctl.Parent
    Do While Not p Is Nothing
        Select Case TypeName(p)
            Case "Frame", "Page", "MultiPage"
                y = y + p.Top
        End Select
        Set p = p.Parent
    Loop
    UI_PosicaoTopoAbsoluta = y
    Exit Function
fim:
    UI_PosicaoTopoAbsoluta = ctl.Top
End Function

Private Function UI_PosicaoEsquerdaAbsoluta(ByVal ctl As Object) As Double
    Dim p As Object
    Dim x As Double

    On Error GoTo fim
    x = ctl.Left
    Set p = ctl.Parent
    Do While Not p Is Nothing
        Select Case TypeName(p)
            Case "Frame", "Page", "MultiPage"
                x = x + p.Left
        End Select
        Set p = p.Parent
    Loop
    UI_PosicaoEsquerdaAbsoluta = x
    Exit Function
fim:
    UI_PosicaoEsquerdaAbsoluta = ctl.Left
End Function

Private Function UI_PegarTextBoxBuscaDaLista(ByVal lst As Object) As MSForms.TextBox
    Dim melhor As MSForms.TextBox
    Dim leftMax As Double

    On Error GoTo fim

    leftMax = -1
    Call UI_PegarMelhorTextBoxBuscaRecursivo(lst.Parent, UI_PosicaoTopoAbsoluta(lst) - 60, UI_PosicaoTopoAbsoluta(lst), melhor, leftMax)

    Set UI_PegarTextBoxBuscaDaLista = melhor
    Exit Function
fim:
End Function

' =========================================================
' Filtros Dinâmicos (MI-09 e MI-10)
' =========================================================
Private Sub Filtros_CriarDinamico()
    On Error GoTo falha
    Dim lblEmp As Object
    Dim lblServ As Object
    Dim tbFiltroEnt As MSForms.TextBox

    ' Busca na lista de Empresas (EMP_Lista)
    Set mTxtFiltroEmpresa = UI_TextBoxSeExisteRecursivo(EMP_Lista.Parent, "TextBox17")
    If mTxtFiltroEmpresa Is Nothing Then Set mTxtFiltroEmpresa = UI_PegarTextBoxBuscaDaLista(EMP_Lista)
    If mTxtFiltroEmpresa Is Nothing Then Set mTxtFiltroEmpresa = UI_TextBoxSeExistePagina(EMP_Lista.Parent, "TxtFiltroEmpresaDin")
    If mTxtFiltroEmpresa Is Nothing Then
        Set mTxtFiltroEmpresa = EMP_Lista.Parent.Controls.Add("Forms.TextBox.1", "TxtFiltroEmpresaDin", True)
        With mTxtFiltroEmpresa
            .Top = EMP_Lista.Top - 35
            .Left = EMP_Lista.Left + 45
            .Width = 220
            .Height = 15
            .SpecialEffect = fmSpecialEffectSunken
            .Text = ""
            .Font.Size = 9
        End With
        Set lblEmp = EMP_Lista.Parent.Controls.Add("Forms.Label.1", "LblFiltroEmpDin", True)
        With lblEmp
            .Top = mTxtFiltroEmpresa.Top + 2
            .Left = mTxtFiltroEmpresa.Left - 92
            .Width = 88
            .Height = 15
            .caption = "Buscar empresa:"
            .BackStyle = fmBackStyleTransparent
            .Font.Bold = True
        End With
    End If

    ' Busca Entidade (sem heuristica): preferir nome canonico, aceitar legado enquanto o .frx nao for reexportado.
    ' Canonico: TxtFiltro_Entidade | Legado: TextBox16
    Set tbFiltroEnt = UI_TextBoxSeExisteRecursivo(Me, "TxtFiltro_Entidade")
    If tbFiltroEnt Is Nothing Then Set tbFiltroEnt = UI_TextBoxSeExisteRecursivo(Me, "TextBox16")
    If tbFiltroEnt Is Nothing Then
        MsgBox "Filtro de Entidade ausente no designer." & vbCrLf & _
               "Renomeie o TextBox para (Name)=TxtFiltro_Entidade (ou mantenha como TextBox16).", _
               vbCritical, "Padronizacao UI"
        GoTo falha
    End If
    Set mTxtFiltroEntidade = tbFiltroEnt

    ' Filtros do Rodizio/Atribuicao (pagina PAGINAS=3): deterministico, sem TextBox18/TextBox22.
    Set mTxtFiltroServico = UI_TextBoxSeExisteRecursivo(Me, "TxtFiltro_Servico")
    Set mTxtFiltroRodizio = UI_TextBoxSeExisteRecursivo(Me, "TxtFiltro_EntidadeRodizio")

    ' Busca na lista de manutencao de servicos (H_Lista)
    Set mTxtFiltroCadServ = UI_PegarTextBoxBuscaDaLista(H_Lista)
    If mTxtFiltroCadServ Is Nothing Then Set mTxtFiltroCadServ = UI_TextBoxSeExisteRecursivo(H_Lista.Parent, "TxtFiltroCadServDin")
    If mTxtFiltroCadServ Is Nothing Then
        Set mTxtFiltroCadServ = H_Lista.Parent.Controls.Add("Forms.TextBox.1", "TxtFiltroCadServDin", True)
        With mTxtFiltroCadServ
            .Top = H_Lista.Top - 35
            .Left = H_Lista.Left + H_Lista.Width - 220
            .Width = 220
            .Height = 15
            .SpecialEffect = fmSpecialEffectSunken
            .Text = ""
            .Font.Size = 9
        End With
        Set lblServ = H_Lista.Parent.Controls.Add("Forms.Label.1", "LblFiltroCadServDin", True)
        With lblServ
            .Top = mTxtFiltroCadServ.Top + 2
            .Left = mTxtFiltroCadServ.Left - 116
            .Width = 112
            .Height = 15
            .caption = "Buscar CNAE/servico:"
            .BackStyle = fmBackStyleTransparent
            .Font.Bold = True
        End With
    End If

    Exit Sub
falha:
    Err.Clear
End Sub

Private Sub mTxtFiltroEmpresa_Change()
    If mInicializando Then Exit Sub
    Call PreenchimentoEmpresa(mTxtFiltroEmpresa.Text)
End Sub

Private Sub mTxtFiltroEntidade_Change()
    If mInicializando Then Exit Sub
    If mTxtFiltroEntidade Is Nothing Then Exit Sub
    Call PreenchimentoEntidade(mTxtFiltroEntidade.Text)
End Sub


Private Sub mTxtFiltroServico_Change()
    If mInicializando Then Exit Sub
    If mTxtFiltroServico Is Nothing Then Exit Sub
    Call PreenchimentoServico(mTxtFiltroServico.Text)
End Sub

Private Sub mTxtFiltroRodizio_Change()
    If mInicializando Then Exit Sub
    If mTxtFiltroRodizio Is Nothing Then Exit Sub
    Call PreenchimentoEntidadeRodizio(mTxtFiltroRodizio.Text)
End Sub
Private Sub mTxtFiltroCadServ_Change()
    If mInicializando Then Exit Sub
    Call PreencherManutencaoValor(mTxtFiltroCadServ.Text)
End Sub

Private Sub TextBox17_Change()
    On Error Resume Next
    Call PreenchimentoEmpresa(TextBox17.Text)
    On Error GoTo 0
End Sub







