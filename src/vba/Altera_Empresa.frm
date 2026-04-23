VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Altera_Empresa 
   Caption         =   "Altera / Inativa Empresa"
   ClientHeight    =   4158
   ClientLeft      =   119
   ClientTop       =   462
   ClientWidth     =   14266
   OleObjectBlob   =   "Altera_Empresa.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "Altera_Empresa"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False


' V12.0.0009: ID da empresa armazenado internamente ao abrir o formulario.
' Elimina a dependencia de acessar M_Lista do Menu_Principal (que falha quando
' M_Lista esta dentro de MultiPage e nao e acessivel via Controls("M_Lista")).
Private m_empresaId As String
Private WithEvents mBtnInativarEmpresa As MSForms.CommandButton
Attribute mBtnInativarEmpresa.VB_VarHelpID = -1

Private Sub UserForm_Initialize()
    Call PadronizarRotulosEdicaoEmpresa
    Call InativacaoEmpresa_LigarBotao
End Sub

Private Sub PadronizarRotulosEdicaoEmpresa()
    Call AjustarLabelEdicaoPorCampo(Me, "M_Empresa", "Raz" & ChrW(227) & "o Social:")
    Call AjustarLabelResponsavelEmpresa
End Sub

Private Sub AjustarLabelResponsavelEmpresa()
    If BuscarControleResponsavelNome() Is Nothing Then Exit Sub
    Call AjustarLabelEdicaoPorCampo(Me, BuscarControleResponsavelNome().Name, "Nome Respons" & ChrW(225) & "vel:")
End Sub

Private Sub AjustarLabelEdicaoPorCampo(ByVal container As Object, ByVal nomeCampo As String, ByVal novoCaption As String)
    Dim ctrlCampo As Object
    Dim lblCampo As Object

    Set ctrlCampo = BuscarControleEdicaoRecursivo(container, nomeCampo)
    If ctrlCampo Is Nothing Then Exit Sub

    Set lblCampo = BuscarLabelEdicaoDoCampo(container, ctrlCampo)
    If lblCampo Is Nothing Then Exit Sub

    lblCampo.Caption = novoCaption
End Sub

Private Function BuscarControleEdicaoRecursivo(ByVal container As Object, ByVal nomeControle As String) As Object
    Dim ctl As Object

    For Each ctl In container.Controls
        If StrComp(ctl.Name, nomeControle, vbTextCompare) = 0 Then
            Set BuscarControleEdicaoRecursivo = ctl
            Exit Function
        End If

        If ControleEdicaoTemFilhos(ctl) Then
            Set BuscarControleEdicaoRecursivo = BuscarControleEdicaoRecursivo(ctl, nomeControle)
            If Not BuscarControleEdicaoRecursivo Is Nothing Then Exit Function
        End If
    Next ctl
End Function

Private Function BuscarLabelEdicaoDoCampo(ByVal container As Object, ByVal ctrlCampo As Object) As Object
    Dim melhor As Object
    Dim melhorDist As Double

    melhorDist = 10 ^ 20
    Call LocalizarMelhorLabelEdicao(container, ctrlCampo, melhor, melhorDist)
    Set BuscarLabelEdicaoDoCampo = melhor
End Function

Private Sub LocalizarMelhorLabelEdicao(ByVal container As Object, ByVal ctrlCampo As Object, ByRef melhor As Object, ByRef melhorDist As Double)
    Dim ctl As Object
    Dim topCampo As Double
    Dim leftCampo As Double
    Dim topLabel As Double
    Dim leftLabel As Double
    Dim dist As Double

    topCampo = PosicaoTopoAbsolutaEdicao(ctrlCampo)
    leftCampo = PosicaoEsquerdaAbsolutaEdicao(ctrlCampo)

    For Each ctl In container.Controls
        If TypeName(ctl) = "Label" Then
            topLabel = PosicaoTopoAbsolutaEdicao(ctl)
            leftLabel = PosicaoEsquerdaAbsolutaEdicao(ctl)
            If Abs(topLabel - topCampo) <= 280 And leftLabel < leftCampo Then
                dist = (leftCampo - leftLabel) + Abs(topCampo - topLabel)
                If dist < melhorDist Then
                    melhorDist = dist
                    Set melhor = ctl
                End If
            End If
        End If

        If ControleEdicaoTemFilhos(ctl) Then
            Call LocalizarMelhorLabelEdicao(ctl, ctrlCampo, melhor, melhorDist)
        End If
    Next ctl
End Sub

Private Function ControleEdicaoTemFilhos(ByVal ctl As Object) As Boolean
    On Error GoTo fim
    ControleEdicaoTemFilhos = (ctl.Controls.count >= 0)
    Exit Function
fim:
    ControleEdicaoTemFilhos = False
End Function

Private Function PosicaoEsquerdaAbsolutaEdicao(ByVal ctl As Object) As Double
    Dim p As Object
    Dim X As Double

    On Error GoTo fim
    X = ctl.Left
    Set p = ctl.Parent
    Do While Not p Is Nothing
        Select Case TypeName(p)
            Case "Frame", "Page", "MultiPage"
                X = X + p.Left
        End Select
        Set p = p.Parent
    Loop
    PosicaoEsquerdaAbsolutaEdicao = X
    Exit Function
fim:
    PosicaoEsquerdaAbsolutaEdicao = ctl.Left
End Function

Private Function PosicaoTopoAbsolutaEdicao(ByVal ctl As Object) As Double
    Dim p As Object
    Dim Y As Double

    On Error GoTo fim
    Y = ctl.Top
    Set p = ctl.Parent
    Do While Not p Is Nothing
        Select Case TypeName(p)
            Case "Frame", "Page", "MultiPage"
                Y = Y + p.Top
        End Select
        Set p = p.Parent
    Loop
    PosicaoTopoAbsolutaEdicao = Y
    Exit Function
fim:
    PosicaoTopoAbsolutaEdicao = ctl.Top
End Function

Private Function BuscarControleResponsavelNome() As Object
    Set BuscarControleResponsavelNome = BuscarControleEdicaoPorPrefixo(Me, "M_Nome_")
End Function

Private Function BuscarControleCpfResponsavel() As Object
    Set BuscarControleCpfResponsavel = BuscarControleEdicaoPorPrefixo(Me, "M_CPF_")
End Function

Private Function BuscarControleEdicaoPorPrefixo(ByVal container As Object, ByVal prefixo As String) As Object
    Dim ctl As Object

    For Each ctl In container.Controls
        If UCase$(Left$(CStr(ctl.Name), Len(prefixo))) = UCase$(prefixo) Then
            Set BuscarControleEdicaoPorPrefixo = ctl
            Exit Function
        End If

        If ControleEdicaoTemFilhos(ctl) Then
            Set BuscarControleEdicaoPorPrefixo = BuscarControleEdicaoPorPrefixo(ctl, prefixo)
            If Not BuscarControleEdicaoPorPrefixo Is Nothing Then Exit Function
        End If
    Next ctl
End Function

Private Function UI_CaptionContemTodos(ByVal caption As String, ByVal texto1 As String, Optional ByVal texto2 As String = "")
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

Private Function UI_EncontrarBotaoPorTextos(ByVal container As Object, ByVal texto1 As String, Optional ByVal texto2 As String = "") As MSForms.CommandButton
    Dim ctl As Object

    For Each ctl In container.Controls
        If TypeName(ctl) = "CommandButton" Then
            If UI_CaptionContemTodos(CStr(ctl.Caption), texto1, texto2) Then
                Set UI_EncontrarBotaoPorTextos = ctl
                Exit Function
            End If
        End If

        If ControleEdicaoTemFilhos(ctl) Then
            Set UI_EncontrarBotaoPorTextos = UI_EncontrarBotaoPorTextos(ctl, texto1, texto2)
            If Not UI_EncontrarBotaoPorTextos Is Nothing Then Exit Function
        End If
    Next ctl
End Function

Private Sub InativacaoEmpresa_LigarBotao()
    On Error Resume Next
    Set mBtnInativarEmpresa = UI_EncontrarBotaoPorTextos(Me, "INATIVA", "EMPRESA")
    On Error GoTo 0
End Sub

Private Sub mBtnInativarEmpresa_Click()
    Call Empresa_InativarSelecionada
End Sub

Public Property Get M_Nome_Empresa() As String
    Dim ctrl As Object
    Set ctrl = BuscarControleResponsavelNome()
    If Not ctrl Is Nothing Then M_Nome_Empresa = CStr(ctrl.Value)
End Property

Public Property Let M_Nome_Empresa(ByVal valor As String)
    Dim ctrl As Object
    Set ctrl = BuscarControleResponsavelNome()
    If Not ctrl Is Nothing Then ctrl.Value = valor
End Property

Public Property Get M_CPF_Empresa() As String
    Dim ctrl As Object
    Set ctrl = BuscarControleCpfResponsavel()
    If Not ctrl Is Nothing Then M_CPF_Empresa = CStr(ctrl.Value)
End Property

Public Property Let M_CPF_Empresa(ByVal valor As String)
    Dim ctrl As Object
    Set ctrl = BuscarControleCpfResponsavel()
    If Not ctrl Is Nothing Then ctrl.Value = valor
End Property

Public Sub DefinirDadosEdicaoEmpresa( _
    ByVal cnpj As String, _
    ByVal razao As String, _
    ByVal inscMun As String, _
    ByVal nomeResponsavel As String, _
    ByVal cpfResponsavel As String, _
    ByVal endereco As String, _
    ByVal bairro As String, _
    ByVal municipio As String, _
    ByVal cep As String, _
    ByVal uf As String, _
    ByVal telFixo As String, _
    ByVal telCel As String, _
    ByVal email As String, _
    ByVal tempExper As String _
)
    ' V12.0.0010: ler ID do global M_ID_Empresa (ja definido por M_Lista_Click antes do DblClick).
    ' Revertida assinatura para 14 params (sem empresaId) para evitar falha silenciosa de
    ' CallByName quando apenas um dos dois modulos era reimportado no Excel.
    m_empresaId = Trim$(CStr(M_ID_Empresa))
    M_CNPJ = cnpj
    M_Empresa = razao
    M_Insc_Mun = inscMun
    M_Nome_Empresa = nomeResponsavel
    M_CPF_Empresa = cpfResponsavel
    M_Endereco = endereco
    M_Bairro = bairro
    M_Municipio = municipio
    M_CEP = cep
    M_UF = uf
    M_Tel_Fixo = telFixo
    M_Tel_Cel = telCel
    M_Email = email
    M_Temp_Exper = tempExper
End Sub

Private Sub M_Alterar_Click()
On Error GoTo erro_carregamento:
    ' V12.0.0009: usa m_empresaId (armazenado em DefinirDadosEdicaoEmpresa) em vez de
    ' acessar M_Lista do Menu_Principal (que falha dentro de MultiPage).
    ' Substituido Range.Find por loop normalizado CLng(Val(...)) para robustecer
    ' comparacao de IDs numericos vs texto.
    Dim wsEmpAlt As Worksheet
    Dim linhaAlt As Long
    Dim linhaFinalAlt As Long
    Dim estProtAlt As Boolean
    Dim senhaAlt As String

    If M_Empresa = Empty Then
        MsgBox "Informe a razão social da empresa!", vbExclamation, "Alteração"
        M_Empresa.BackColor = &HFFFF&
        M_Empresa.SetFocus
        Exit Sub
    End If

    If m_empresaId = "" Then
        MsgBox "ID da empresa n" & ChrW(227) & "o identificado. Feche e reabra o formul" & ChrW(225) & "rio.", _
               vbExclamation, "Alteração"
        Exit Sub
    End If

    If MsgBox("Deseja realmente continuar?", vbQuestion + vbYesNo, "Alteração") <> vbYes Then Exit Sub

    Set wsEmpAlt = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    linhaFinalAlt = UltimaLinhaAba(SHEET_EMPRESAS)
    Set EncontrarID = Nothing

    For linhaAlt = LINHA_DADOS To linhaFinalAlt
        If Trim$(CStr(wsEmpAlt.Cells(linhaAlt, COL_EMP_ID).Value)) <> "" Then
            If CLng(Val("0" & Trim$(CStr(wsEmpAlt.Cells(linhaAlt, COL_EMP_ID).Value)))) = _
               CLng(Val("0" & m_empresaId)) Then
                Set EncontrarID = wsEmpAlt.Cells(linhaAlt, COL_EMP_ID)
                Exit For
            End If
        End If
    Next linhaAlt

    If EncontrarID Is Nothing Then
        MsgBox "Empresa n" & ChrW(227) & "o encontrada na aba EMPRESAS.", vbExclamation, "Alteração"
        Exit Sub
    End If

    Call Util_PrepararAbaParaEscrita(wsEmpAlt, estProtAlt, senhaAlt)
    EncontrarID.Offset(0, 1).Value = M_CNPJ
    EncontrarID.Offset(0, 2).Value = Funcoes.NormalizarTextoPTBR(M_Empresa.Value)
    EncontrarID.Offset(0, 3).Value = Format(M_Insc_Mun)
    EncontrarID.Offset(0, 4).Value = Funcoes.NormalizarTextoPTBR(M_Nome_Empresa)
    EncontrarID.Offset(0, 5).Value = M_CPF_Empresa
    EncontrarID.Offset(0, 6).Value = Funcoes.NormalizarTextoPTBR(M_Endereco.Value)
    EncontrarID.Offset(0, 7).Value = Funcoes.NormalizarTextoPTBR(M_Bairro.Value)
    EncontrarID.Offset(0, 8).Value = Funcoes.NormalizarTextoPTBR(M_Municipio.Value)
    EncontrarID.Offset(0, 9).Value = Format(M_CEP)
    EncontrarID.Offset(0, 10).Value = Format(M_UF)
    EncontrarID.Offset(0, 11).Value = Format(M_Tel_Fixo)
    EncontrarID.Offset(0, 12).Value = Format(M_Tel_Cel)
    EncontrarID.Offset(0, 13).Value = Format(M_Email)
    EncontrarID.Offset(0, 14).Value = Funcoes.NormalizarTextoPTBR(M_Temp_Exper.Value)
    EncontrarID.Offset(0, 18).Value = CDate(Now)
    Call Util_RestaurarProtecaoAba(wsEmpAlt, estProtAlt, senhaAlt)

    M_CNPJ = Empty
    M_Empresa = Empty
    M_Insc_Mun = Empty
    M_Nome_Empresa = vbNullString
    M_CPF_Empresa = vbNullString
    M_Endereco = Empty
    M_Bairro = Empty
    M_Municipio = Empty
    M_CEP = Empty
    M_UF = Empty
    M_Temp_Exper = Empty
    M_Tel_Fixo = Empty
    M_Tel_Cel = Empty
    M_Email = Empty
    M_Cert_RFB = False
    M_Cert_FGTS = False
    M_Cert_Mun = False

    Call AtualizarListaEmpresaMenuAtual
    MsgBox "Empresa alterada com sucesso!", vbInformation, "Alterar Empresa"
    Unload Me
Exit Sub
erro_carregamento:
    MsgBox "Erro ao alterar empresa: " & Err.Description, vbCritical, "Erro"
End Sub

Private Sub Empresa_InativarSelecionada()
On Error GoTo erro_carregamento:
    ' V12.0.0009: usa m_empresaId (armazenado em DefinirDadosEdicaoEmpresa) em vez de
    ' acessar M_Lista do Menu_Principal (que falha dentro de MultiPage).
    ' Range.Find substituido por loop normalizado CLng(Val(...)) (mesmo padrao de Reativa_Empresa).
    Dim wsEmp As Worksheet
    Dim wsInativas As Worksheet
    Dim wsCred As Worksheet
    Dim linhaInativa As Long
    Dim linhaCredAtual As Long
    Dim ultimaLinhaCred As Long
    Dim linhaInativAtual As Long
    Dim linhaFinalEmp As Long
    Dim primeiraLinhaEmp As Long
    Dim estProtEmp As Boolean
    Dim senhaEmp As String
    Dim estProtInativas As Boolean
    Dim senhaInativas As String
    Dim estProtCred As Boolean
    Dim senhaCred As String
    Dim linhasMesmaChave As Variant
    Dim qtdLinhasMesmaChave As Long
    Dim baseLinhas As Long
    Dim cnpjEmpresa As String
    Dim linhasDel() As Long
    Dim nDelDup As Long
    Dim kDup As Long
    Dim jDup As Long
    Dim tmpDup As Long

    If m_empresaId = "" Then
        MsgBox "ID da empresa n" & ChrW(227) & "o identificado. Feche e reabra o formul" & ChrW(225) & "rio.", _
               vbExclamation, "Inativar Empresa"
        Exit Sub
    End If

    If MsgBox("Tem certeza que deseja Inativar esta Empresa?", vbQuestion + vbYesNo, "Inativar Empresa") <> vbYes Then Exit Sub

    Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    Set wsInativas = ThisWorkbook.Sheets(SHEET_EMPRESAS_INATIVAS)
    Set wsCred = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)

    ' V12.0.0009: loop normalizado — elimina Range.Find fragil (ID string vs numerico)
    primeiraLinhaEmp = PrimeiraLinhaDadosEmpresas()
    linhaFinalEmp = UltimaLinhaAba(SHEET_EMPRESAS)
    Set EncontrarID = Nothing
    For linhaInativAtual = primeiraLinhaEmp To linhaFinalEmp
        If Trim$(CStr(wsEmp.Cells(linhaInativAtual, COL_EMP_ID).Value)) <> "" Then
            If CLng(Val("0" & Trim$(CStr(wsEmp.Cells(linhaInativAtual, COL_EMP_ID).Value)))) = _
               CLng(Val("0" & m_empresaId)) Then
                Set EncontrarID = wsEmp.Cells(linhaInativAtual, COL_EMP_ID)
                Exit For
            End If
        End If
    Next linhaInativAtual

    If EncontrarID Is Nothing Then
        MsgBox "Empresa n" & ChrW(227) & "o encontrada na aba EMPRESAS.", vbExclamation, "Inativação"
        Exit Sub
    End If

    cnpjEmpresa = Trim$(CStr(EncontrarID.Offset(0, 1).Value))
    linhasMesmaChave = Util_EmpresaInativos_ColetarLinhasMesmaChave(wsInativas, LINHA_DADOS, CStr(EncontrarID.Value), cnpjEmpresa)
    If IsArray(linhasMesmaChave) Then
        baseLinhas = LBound(linhasMesmaChave)
        qtdLinhasMesmaChave = UBound(linhasMesmaChave) - baseLinhas + 1
        nDelDup = qtdLinhasMesmaChave
        If nDelDup > 0 Then
            ReDim linhasDel(1 To nDelDup)
            For kDup = 1 To nDelDup
                linhasDel(kDup) = CLng(linhasMesmaChave(baseLinhas + kDup - 1))
            Next kDup
            For kDup = 1 To nDelDup - 1
                For jDup = kDup + 1 To nDelDup
                    If linhasDel(kDup) < linhasDel(jDup) Then
                        tmpDup = linhasDel(kDup)
                        linhasDel(kDup) = linhasDel(jDup)
                        linhasDel(jDup) = tmpDup
                    End If
                Next jDup
            Next kDup

            If Not Util_PrepararAbaParaEscrita(wsInativas, estProtInativas, senhaInativas) Then
                MsgBox "Não foi possível preparar EMPRESAS_INATIVAS para escrita.", vbCritical, "Inativação"
                Exit Sub
            End If
            For kDup = 1 To nDelDup
                If Not Util_ExcluirLinhaSegura(wsInativas, linhasDel(kDup)) Then
                    Err.Raise 1004, "Empresa_InativarSelecionada", "Nao foi possivel excluir linha " & CStr(linhasDel(kDup)) & " em EMPRESAS_INATIVAS."
                End If
            Next kDup
            Call Util_RestaurarProtecaoAba(wsInativas, estProtInativas, senhaInativas)
        End If
    End If

    ' Copiar linha inteira para aba de inativas (sem .Select)
    linhaInativa = wsInativas.Cells(wsInativas.Rows.count, 1).End(xlUp).row + 1
    If Not Util_PrepararAbaParaEscrita(wsInativas, estProtInativas, senhaInativas) Then
        MsgBox "Não foi possível preparar EMPRESAS_INATIVAS para escrita.", vbCritical, "Inativação"
        Exit Sub
    End If
    EncontrarID.EntireRow.Copy Destination:=wsInativas.Cells(linhaInativa, 1)
    Call Util_RestaurarProtecaoAba(wsInativas, estProtInativas, senhaInativas)
    Application.CutCopyMode = False

    ' V12.0.0009: m_empresaId ja esta armazenado; sincronizar global legado ID_Empresa
    ID_Empresa = m_empresaId

    ' Remover linha da aba ativa
    If Not Util_PrepararAbaParaEscrita(wsEmp, estProtEmp, senhaEmp) Then
        MsgBox "Não foi possível preparar EMPRESAS para escrita.", vbCritical, "Inativação"
        Exit Sub
    End If
    If Not Util_ExcluirLinhaSegura(wsEmp, EncontrarID.row) Then
        Err.Raise 1004, "Empresa_InativarSelecionada", "Não foi possível excluir a linha da empresa na aba EMPRESAS."
    End If
    Call Util_RestaurarProtecaoAba(wsEmp, estProtEmp, senhaEmp)

    ' V12.0.0007: desproteger CREDENCIADOS antes do sort + escrita de inativacao.
    ' ClassificaCredenciadoInativo usa Sort.SortFields.Add2; aba protegida pode rejeitar Sort
    ' mesmo com UserInterfaceOnly:=True em certas versoes do Excel.
    ' Comparacao de ID usa CLng(Val(...)) (normalizada) em vez de CStr direto (fragil
    ' quando o ID e "001" texto vs 1 numerico).
    If Not Util_PrepararAbaParaEscrita(wsCred, estProtCred, senhaCred) Then
        MsgBox "Não foi possível preparar CREDENCIADOS para escrita.", vbCritical, "Inativação"
        Exit Sub
    End If
    Call ClassificaCredenciadoInativo
    ultimaLinhaCred = UltimaLinhaAba(SHEET_CREDENCIADOS)
    If ultimaLinhaCred >= LINHA_DADOS Then
        For linhaCredAtual = LINHA_DADOS To ultimaLinhaCred
            If Trim$(CStr(wsCred.Cells(linhaCredAtual, COL_CRED_EMP_ID).Value)) <> "" Then
                If CLng(Val("0" & Trim$(CStr(wsCred.Cells(linhaCredAtual, COL_CRED_EMP_ID).Value)))) = CLng(Val("0" & Trim$(ID_Empresa))) Then
                    wsCred.Cells(linhaCredAtual, COL_CRED_ATIV_ID).Value = "X"
                End If
            End If
        Next linhaCredAtual
    End If
    Call Util_RestaurarProtecaoAba(wsCred, estProtCred, senhaCred)

    Call ClassificaEmpresa
    MsgBox "Empresa inativada com sucesso!", vbExclamation, "Inativação"
    Unload Me
Exit Sub
erro_carregamento:
    MsgBox "Erro ao inativar empresa: " & Err.Description, vbCritical, "Erro"
End Sub
Private Sub M_Empresa_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
        
Exit Sub
erro_carregamento:
End Sub
Private Sub M_Nome_Empresa_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
        
Exit Sub
erro_carregamento:
End Sub
Private Sub M_Endereco_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
        
Exit Sub
erro_carregamento:
End Sub
Private Sub M_Bairro_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
        
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
Private Sub M_CEP_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:
M_CEP.Text = Funcoes.cep(KeyAscii, M_CEP.Text)
erro_carregamento:
End Sub


