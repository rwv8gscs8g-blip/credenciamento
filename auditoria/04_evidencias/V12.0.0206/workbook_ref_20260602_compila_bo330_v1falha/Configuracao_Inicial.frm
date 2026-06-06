VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Configuracao_Inicial 
   Caption         =   "CONFIGURACOES INICIAIS"
   ClientHeight    =   5341
   ClientLeft      =   119
   ClientTop       =   462
   ClientWidth     =   12782
   OleObjectBlob   =   "Configuracao_Inicial.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "Configuracao_Inicial"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Const CI_CTRL_NOTA_CORTE As String = "TxtNotaCorte"
Private Const CI_CTRL_MAX_STRIKES As String = "TxtMaxStrikes"
Private Const CI_CTRL_DIAS_SUSPENSAO As String = "TxtDiasSuspensao"
Private Const CI_CTRL_PRAZO_PREOS As String = "PR_Val_OS"
Private Const CI_CTRL_MAX_RECUSAS As String = "TP_Valor"
Private Const CI_CTRL_MESES_SUSPENSAO As String = "TxtMesesSuspensao"

Private Sub Carrega_CAD_SERV_Click()
On Error GoTo erro_carregamento:
    ' V12: eliminado Sheets.Select + Range.Select (proibidos; formulario modal).
    ' Usa referencia direta ao workbook externo e ao SHEET_CAD_SERV do workbook atual.
    Dim ArqParaAbrir As String
    Dim wbExterno As Workbook
    Dim wsExt As Worksheet
    Dim wsLocal As Worksheet
    Dim ultimaLinhaExt As Long

    Application.ScreenUpdating = False

    ArqParaAbrir = Application.GetOpenFilename("Arquivo do Excel (*.xls*), *.xl*", _
                    Title:="Escolha o arquivo a ser importado", _
                    MultiSelect:=False)

    If ArqParaAbrir = "False" Or ArqParaAbrir = "" Then
        Application.ScreenUpdating = True
        Exit Sub
    End If

    Set wbExterno = Application.Workbooks.Open(ArqParaAbrir)
    Set wsExt = wbExterno.Sheets("CAD_SERV")
    ultimaLinhaExt = wsExt.Range("A65536").End(xlUp).row
    wsExt.Range("A2:I" & ultimaLinhaExt).Copy
    wbExterno.Close False

    Set wsLocal = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    wsLocal.Range("A2").PasteSpecial
    Application.CutCopyMode = False

    MsgBox "Processo conclu" & ChrW(237) & "do. Arquivos copiados.", _
           vbInformation, "Configura" & ChrW(231) & ChrW(245) & "es Iniciais"
    Unload Me
    Application.ScreenUpdating = True
Exit Sub
erro_carregamento:
    Application.ScreenUpdating = True
    Application.CutCopyMode = False
    MsgBox "Erro ao importar CAD_SERV: " & Err.Description, vbCritical, "Configura" & ChrW(231) & ChrW(245) & "es Iniciais"
End Sub

Private Sub B_Parametros_Click()
    Dim detalhes As String
    Call CI_PersistirParametros(True, True, True, detalhes)
End Sub

Public Function CI_TestarPersistenciaPainel( _
    ByVal notaCorteTeste As String, _
    ByVal maxStrikesTeste As String, _
    ByVal diasSuspensaoTeste As String, _
    ByRef detalhes As String, _
    Optional ByVal maxRecusasTeste As String = "", _
    Optional ByVal mesesSuspensaoTeste As String = "", _
    Optional ByVal prazoPreOSTeste As String = "" _
) As Boolean
    On Error GoTo falha

    CI_GarantirControlesRegraNegocio
    Me.Controls(CI_CTRL_NOTA_CORTE).Value = notaCorteTeste
    Me.Controls(CI_CTRL_MAX_STRIKES).Value = maxStrikesTeste
    Me.Controls(CI_CTRL_DIAS_SUSPENSAO).Value = diasSuspensaoTeste
    If maxRecusasTeste <> "" Then Me.Controls(CI_CTRL_MAX_RECUSAS).Value = maxRecusasTeste
    If mesesSuspensaoTeste <> "" Then Me.Controls(CI_CTRL_MESES_SUSPENSAO).Value = mesesSuspensaoTeste
    If prazoPreOSTeste <> "" Then Me.Controls(CI_CTRL_PRAZO_PREOS).Value = prazoPreOSTeste
    CI_TestarPersistenciaPainel = CI_PersistirParametros(False, False, False, detalhes)
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
    CI_TestarPersistenciaPainel = False
End Function

Private Function CI_PersistirParametros( _
    ByVal exibirMensagens As Boolean, _
    ByVal salvarWorkbook As Boolean, _
    ByVal descarregarForm As Boolean, _
    ByRef detalhes As String _
) As Boolean
On Error GoTo erro_carregamento:
    Dim wsCfg As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim gestorTxt As String
    Dim municipioTxt As String
    Dim prazoTxt As String
    Dim logoTxt As String
    Dim msgSave As String
    ' V12.0.0203 ONDA 4 - campos da regra de strikes na avaliacao.
    Dim notaCorteTxt As String
    Dim maxStrikesTxt As String
    Dim diasSuspensaoTxt As String
    Dim maxRecusasTxt As String
    Dim mesesSuspensaoTxt As String
    Dim notaCorteVal As Double
    Dim maxStrikesVal As Long
    Dim diasSuspensaoVal As Long
    Dim prazoVal As Long
    Dim maxRecusasVal As Long
    Dim mesesSuspensaoVal As Long
    Dim msgValidacao As String

    Set wsCfg = ThisWorkbook.Sheets(SHEET_CONFIG)
    CI_GarantirControlesRegraNegocio
    If Not Util_PrepararAbaParaEscrita(wsCfg, estavaProtegida, senhaProtecao) Then
        detalhes = "Nao foi possivel salvar os parametros: aba CONFIG protegida."
        If exibirMensagens Then MsgBox detalhes, vbCritical, "Configurações iniciais"
        Exit Function
    End If

    gestorTxt = Funcoes.NormalizarTextoPTBR(ValorControleTexto(Me, "Gestor_Rodizio", CStr(Gestor_Rodizio)))
    municipioTxt = Funcoes.NormalizarTextoPTBR(ValorControleTexto(Me, "Municipio_gestao", CStr(Municipio_gestao)))
    prazoTxt = CI_ValorControleObrigatorio(CI_CTRL_PRAZO_PREOS)
    logoTxt = Trim$(ValorControleTexto(Me, "Caminho_Logo", CStr(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_LOGO).Value)))

    ' Onda 38.2.5: controles de regra de negocio sao obrigatorios.
    ' A ausencia de qualquer controle canonico bloqueia persistencia.
    notaCorteTxt = CI_ValorControleObrigatorio(CI_CTRL_NOTA_CORTE)
    maxStrikesTxt = CI_ValorControleObrigatorio(CI_CTRL_MAX_STRIKES)
    diasSuspensaoTxt = CI_ValorControleObrigatorio(CI_CTRL_DIAS_SUSPENSAO)
    maxRecusasTxt = CI_ValorControleObrigatorio(CI_CTRL_MAX_RECUSAS)
    mesesSuspensaoTxt = CI_ValorControleObrigatorio(CI_CTRL_MESES_SUSPENSAO)

    If prazoTxt = "" Then prazoTxt = "5"

    If Not CI_ValidarPrazoPreOS(prazoTxt, msgValidacao) Then
        If Not Config_RegistrarFalhaValidacao("Configuracao_Inicial.B_Parametros_Click", msgValidacao) Then
            msgValidacao = msgValidacao & vbCrLf & "Atencao: nao foi possivel registrar a falha no AUDIT_LOG."
        End If
        Call Util_RestaurarProtecaoAba(wsCfg, estavaProtegida, senhaProtecao)
        detalhes = msgValidacao
        If exibirMensagens Then MsgBox msgValidacao, vbExclamation, "Configuracoes iniciais"
        Exit Function
    End If

    ' V12.0.0204 Onda 24 MD-24.2: valor invalido na regra de strikes
    ' bloqueia a gravacao completa e deixa rastro em AUDIT_LOG.
    If Not Config_ValidarRegraStrikes(notaCorteTxt, maxStrikesTxt, diasSuspensaoTxt, msgValidacao) Then
        If Not Config_RegistrarFalhaValidacao("Configuracao_Inicial.B_Parametros_Click", msgValidacao) Then
            msgValidacao = msgValidacao & vbCrLf & "Atencao: nao foi possivel registrar a falha no AUDIT_LOG."
        End If
        Call Util_RestaurarProtecaoAba(wsCfg, estavaProtegida, senhaProtecao)
        detalhes = msgValidacao
        If exibirMensagens Then MsgBox msgValidacao, vbExclamation, "Configuracoes iniciais"
        Exit Function
    End If

    If Not CI_ValidarRegraRecusas(maxRecusasTxt, mesesSuspensaoTxt, msgValidacao) Then
        If Not Config_RegistrarFalhaValidacao("Configuracao_Inicial.B_Parametros_Click", msgValidacao) Then
            msgValidacao = msgValidacao & vbCrLf & "Atencao: nao foi possivel registrar a falha no AUDIT_LOG."
        End If
        Call Util_RestaurarProtecaoAba(wsCfg, estavaProtegida, senhaProtecao)
        detalhes = msgValidacao
        If exibirMensagens Then MsgBox msgValidacao, vbExclamation, "Configuracoes iniciais"
        Exit Function
    End If

    prazoVal = CLng(CDbl(prazoTxt))
    maxRecusasVal = CLng(CDbl(maxRecusasTxt))
    mesesSuspensaoVal = CLng(CDbl(mesesSuspensaoTxt))

    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_GESTOR).Value = gestorTxt
    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_LOGO).Value = logoTxt
    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MUNICIPIO).Value = municipioTxt
    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_PRAZO_PREOS).Value = prazoVal
    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value = maxRecusasVal
    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MESES_SUSPENSAO).Value = mesesSuspensaoVal

    ' V12.0.0203 ONDA 4 - Persistencia da regra de strikes.
    ' Validacao defensiva: se o usuario apagar os campos, mantem o
    ' valor atual em CONFIG (sem zerar nem suspender o sistema).
    If notaCorteTxt <> "" Then
        notaCorteVal = CDbl(notaCorteTxt)
        If notaCorteVal > 0 And notaCorteVal <= 10 Then
            wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_NOTA_MINIMA).Value = notaCorteVal
        End If
    End If
    If maxStrikesTxt <> "" Then
        maxStrikesVal = CLng(CDbl(maxStrikesTxt))
        If maxStrikesVal >= 1 And maxStrikesVal <= 50 Then
            wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_STRIKES).Value = maxStrikesVal
        End If
    End If
    If diasSuspensaoTxt <> "" Then
        diasSuspensaoVal = CLng(CDbl(diasSuspensaoTxt))
        If diasSuspensaoVal >= 0 And diasSuspensaoVal <= 3650 Then
            wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_STRIKE).Value = diasSuspensaoVal
        End If
    End If

    Call Util_RestaurarProtecaoAba(wsCfg, estavaProtegida, senhaProtecao)
    If salvarWorkbook And Not Util_SalvarWorkbookSeguro(msgSave) Then
        MsgBox "Parâmetros salvos, mas houve falha ao salvar o arquivo automaticamente." & vbCrLf & _
               "Detalhe: " & msgSave & vbCrLf & _
               "Use Ctrl+S para salvar manualmente antes de continuar.", vbExclamation, "Configurações iniciais"
    End If
    detalhes = "OK"
    CI_PersistirParametros = True
    If descarregarForm Then Unload Me
Exit Function
erro_carregamento:
    detalhes = "Falha ao salvar parametros: (" & CStr(Err.Number) & ") " & Err.Description
    On Error Resume Next
    If Not wsCfg Is Nothing Then Call Util_RestaurarProtecaoAba(wsCfg, estavaProtegida, senhaProtecao)
    On Error GoTo 0
    If exibirMensagens Then MsgBox detalhes, vbCritical, "Configurações iniciais"
End Function

' Onda 38.2.5: garantia por validacao. Estes controles devem existir
' no designer/.frx; nao sao criados em runtime, para o teste V2 falhar se o
' layout regredir.
Private Sub CI_GarantirControlesRegraNegocio()
    CI_ExigirControle CI_CTRL_NOTA_CORTE
    CI_ExigirControle CI_CTRL_MAX_STRIKES
    CI_ExigirControle CI_CTRL_DIAS_SUSPENSAO
    CI_ExigirControle CI_CTRL_PRAZO_PREOS
    CI_ExigirControle CI_CTRL_MAX_RECUSAS
    CI_ExigirControle CI_CTRL_MESES_SUSPENSAO
End Sub

Private Sub CI_ExigirControle(ByVal nomeControle As String)
    Dim ctl As Object

    On Error GoTo ausente
    Set ctl = Me.Controls(nomeControle)
    If ctl Is Nothing Then GoTo ausente
    Exit Sub

ausente:
    Err.Raise 1004, "Configuracao_Inicial", "Controle obrigatorio ausente: " & nomeControle
End Sub

Private Function CI_ValorControleObrigatorio(ByVal nomeControle As String) As String
    On Error GoTo ausente
    CI_ValorControleObrigatorio = Trim$(CStr(Me.Controls(nomeControle).Value))
    Exit Function
ausente:
    Err.Raise 1004, "Configuracao_Inicial", "Controle obrigatorio ausente: " & nomeControle
End Function

Private Function CI_ValidarRegraRecusas( _
    ByVal maxRecusasTxt As String, _
    ByVal mesesSuspensaoTxt As String, _
    ByRef mensagem As String _
) As Boolean
    Dim erros As String
    Dim valorInteiro As Long

    mensagem = ""
    maxRecusasTxt = Trim$(maxRecusasTxt)
    mesesSuspensaoTxt = Trim$(mesesSuspensaoTxt)

    If maxRecusasTxt = "" Then
        CI_AddErro erros, "TP_Valor deve ser informado."
    ElseIf Not CI_TentarInteiro(maxRecusasTxt, valorInteiro) Then
        CI_AddErro erros, "TP_Valor deve ser numero inteiro entre 1 e 50."
    ElseIf valorInteiro < 1 Or valorInteiro > 50 Then
        CI_AddErro erros, "TP_Valor deve ficar entre 1 e 50."
    End If

    If mesesSuspensaoTxt = "" Then
        CI_AddErro erros, "TxtMesesSuspensao deve ser informado."
    ElseIf Not CI_TentarInteiro(mesesSuspensaoTxt, valorInteiro) Then
        CI_AddErro erros, "TxtMesesSuspensao deve ser numero inteiro entre 1 e 120."
    ElseIf valorInteiro < 1 Or valorInteiro > 120 Then
        CI_AddErro erros, "TxtMesesSuspensao deve ficar entre 1 e 120."
    End If

    If erros = "" Then
        CI_ValidarRegraRecusas = True
    Else
        mensagem = "Configuracao invalida: " & erros
        CI_ValidarRegraRecusas = False
    End If
End Function

Private Function CI_ValidarPrazoPreOS( _
    ByVal prazoTxt As String, _
    ByRef mensagem As String _
) As Boolean
    Dim valorInteiro As Long

    mensagem = ""
    prazoTxt = Trim$(prazoTxt)

    If prazoTxt = "" Then
        mensagem = "Configuracao invalida: PR_Val_OS deve ser informado."
    ElseIf Not CI_TentarInteiro(prazoTxt, valorInteiro) Then
        mensagem = "Configuracao invalida: PR_Val_OS deve ser numero inteiro entre 1 e 3650."
    ElseIf valorInteiro < 1 Or valorInteiro > 3650 Then
        mensagem = "Configuracao invalida: PR_Val_OS deve ficar entre 1 e 3650."
    Else
        CI_ValidarPrazoPreOS = True
    End If
End Function

Private Function CI_TentarInteiro(ByVal texto As String, ByRef valor As Long) As Boolean
    Dim valorDouble As Double

    On Error GoTo falha
    texto = Trim$(texto)
    If texto = "" Then Exit Function
    If Not IsNumeric(texto) Then Exit Function

    valorDouble = CDbl(texto)
    If valorDouble <> Fix(valorDouble) Then Exit Function
    If valorDouble < -2147483648# Or valorDouble > 2147483647# Then Exit Function

    valor = CLng(valorDouble)
    CI_TentarInteiro = True
    Exit Function

falha:
    CI_TentarInteiro = False
End Function

Private Sub CI_AddErro(ByRef erros As String, ByVal detalhe As String)
    If erros = "" Then
        erros = detalhe
    Else
        erros = erros & " " & detalhe
    End If
End Sub

Private Sub BR_Backup_Click()
On Error GoTo erro_carregamento:
    ' V12: eliminado Sheets.Select + Range.Select + ActiveCell (proibidos; formulario modal).
    ' Usa referencia direta via ws.Range e ws.Cells.
    Dim Copia As String, NomeArquivo As String, Resposta As String, NomePasta As String, pasta As String
    Dim wsPreOS As Worksheet
    Dim wsCADOS As Worksheet
    Dim estProtPreOS As Boolean
    Dim senhaPreOS As String
    Dim estProtCADOS As Boolean
    Dim senhaCADOS As String
    Dim ultimaLinhaPreOS As Long
    Dim ultimaLinhaCADOS As Long
    Dim preOSPreparada As Boolean
    Dim cadOSPreparada As Boolean

    NomeArquivo = ThisWorkbook.Name
    MsgBox "Efetuando c" & ChrW(243) & "pia de seguran" & ChrW(231) & "a, limpando a base de Pr" & ChrW(233) & "-SS e SS e mantendo os demais cadastros.", _
           vbInformation, "In" & ChrW(237) & "cio de Novo Per" & ChrW(237) & "odo"

    Resposta = MsgBox("Confirme o Backup " & NomeArquivo & "?", vbYesNo + vbQuestion, _
                      "Iniciando um Novo Per" & ChrW(237) & "odo")

    If Resposta = vbNo Then
        MsgBox "Backup cancelado pelo usu" & ChrW(225) & "rio!", vbExclamation, "Iniciando um Novo Per" & ChrW(237) & "odo"
        Exit Sub
    End If

    NomePasta = InputBox("Informe o Nome para a Pasta", "Iniciando um Novo Per" & ChrW(237) & "odo")
    pasta = ThisWorkbook.path & "\" & NomePasta & "\"
    Copia = pasta & Format(Now(), "dd_mm_yyyy hh_mm_ss") & NomeArquivo
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FolderExists(pasta) Then
        Call fso.CreateFolder(pasta)
        MsgBox "Pasta criada com sucesso!", vbInformation, "Iniciando um Novo Per" & ChrW(237) & "odo"
    Else
        MsgBox "A pasta n" & ChrW(227) & "o foi criada por j" & ChrW(225) & " existir.", _
               vbInformation, "Iniciando um Novo Per" & ChrW(237) & "odo"
    End If

    If ThisWorkbook.ReadOnly = True Then
        ThisWorkbook.Saved = True
    Else
        ThisWorkbook.Save
    End If

    ThisWorkbook.SaveCopyAs Copia

    MsgBox "Backup efetuado com sucesso!", vbInformation, "Iniciando um Novo Per" & ChrW(237) & "odo"

    If MsgBox("Tem certeza que deseja iniciar um NOVO PER" & ChrW(237) & "ODO?", _
              vbQuestion + vbYesNo, "Iniciando um Novo Per" & ChrW(237) & "odo") = vbYes Then

        Set wsPreOS = ThisWorkbook.Sheets("PRE_OS")
        Set wsCADOS = ThisWorkbook.Sheets("CAD_OS")

        ultimaLinhaPreOS = wsPreOS.Range("A65536").End(xlUp).row
        ultimaLinhaCADOS = wsCADOS.Range("A65536").End(xlUp).row

        If ultimaLinhaPreOS > 1 Then
            If Not Util_PrepararAbaParaEscrita(wsPreOS, estProtPreOS, senhaPreOS) Then
                MsgBox "Não foi possível iniciar o novo período: aba PRE_OS protegida para escrita.", _
                       vbCritical, "Configurações iniciais"
                Exit Sub
            End If
            preOSPreparada = True
        End If

        If ultimaLinhaCADOS > 1 Then
            If Not Util_PrepararAbaParaEscrita(wsCADOS, estProtCADOS, senhaCADOS) Then
                If preOSPreparada Then Call Util_RestaurarProtecaoAba(wsPreOS, estProtPreOS, senhaPreOS)
                MsgBox "Não foi possível iniciar o novo período: aba CAD_OS protegida para escrita.", _
                       vbCritical, "Configurações iniciais"
                Exit Sub
            End If
            cadOSPreparada = True
        End If

        If ultimaLinhaPreOS > 1 Then
            wsPreOS.Range("A2:I" & ultimaLinhaPreOS).ClearContents
            wsPreOS.Cells(1, 44).Value = 0  ' coluna AR = contador de IDs
        End If

        If ultimaLinhaCADOS > 1 Then
            wsCADOS.Range("A2:Y" & ultimaLinhaCADOS).ClearContents
            wsCADOS.Cells(1, 44).Value = 0  ' coluna AR = contador de IDs
        End If

        If cadOSPreparada Then Call Util_RestaurarProtecaoAba(wsCADOS, estProtCADOS, senhaCADOS)
        If preOSPreparada Then Call Util_RestaurarProtecaoAba(wsPreOS, estProtPreOS, senhaPreOS)

        Call PreenchimentoServico
        Call AtualizarListaEntidadeMenuAtual
        Call AtualizarListaEmpresaMenuAtual
        Call PreenchimentoEntidadeRodizio
        Call PreencherAvaliarOS
        Call PreencherManutencaoValor
        MsgBox "Novo per" & ChrW(237) & "odo iniciado com sucesso!", _
               vbInformation, "Iniciando um Novo Per" & ChrW(237) & "odo"
    Else
        MsgBox "Novo per" & ChrW(237) & "odo n" & ChrW(227) & "o iniciado, base de dados n" & ChrW(227) & "o foi alterada.", _
               vbInformation, "Iniciando um Novo Per" & ChrW(237) & "odo"
    End If

Exit Sub
erro_carregamento:
    On Error Resume Next
    If cadOSPreparada Then Call Util_RestaurarProtecaoAba(wsCADOS, estProtCADOS, senhaCADOS)
    If preOSPreparada Then Call Util_RestaurarProtecaoAba(wsPreOS, estProtPreOS, senhaPreOS)
    On Error GoTo 0
    MsgBox "Erro no processo de backup: " & Err.Description, vbCritical, "Configurações iniciais"
End Sub

Private Sub Limpar_Base_Click()
    Call AbrirLimparBaseSeguro
End Sub

' Compatibilidade: em algumas exportacoes/importacoes o controle ficou nomeado "Limpar_Basee".
Private Sub Limpar_Basee_Click()
    Call AbrirLimparBaseSeguro
End Sub

Private Sub Municipio_gestao_AfterUpdate()
On Error GoTo fim
    Municipio_gestao.Value = Funcoes.NormalizarTextoPTBR(Municipio_gestao.Value)
fim:
End Sub

Private Sub Gestor_Rodizio_AfterUpdate()
On Error GoTo fim
    Gestor_Rodizio.Value = Funcoes.NormalizarTextoPTBR(Gestor_Rodizio.Value)
fim:
End Sub

Private Sub AbrirLimparBaseSeguro()
On Error GoTo fallback
    VBA.UserForms.Add("Limpar_Base").Show
Exit Sub
fallback:
    ' Fallback operacional para nao travar o fluxo de testes.
    Call Limpa_Base
End Sub

Private Sub UserForm_Initialize()
On Error GoTo erro_carregamento:
    ' V12: eliminado Sheets.Select + .Select + ActiveCell (proibidos; formulario modal).
    ' Usa referencia direta via ThisWorkbook.Sheets().Cells().Value.
    Dim wsCfg As Worksheet
    Dim ctl As Object
    Dim txt As String

    Set wsCfg = ThisWorkbook.Sheets(SHEET_CONFIG)

    Gestor_Rodizio = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_GESTOR).Value
    Caminho_Logo = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_LOGO).Value
    Municipio_gestao = Funcoes.NormalizarTextoPTBR(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MUNICIPIO).Value)
    CI_GarantirControlesRegraNegocio
    Me.Controls(CI_CTRL_PRAZO_PREOS).Value = CStr(GetDiasDecisao())
    Me.Controls(CI_CTRL_NOTA_CORTE).Value = Format$(GetNotaMinimaAvaliacao(), "0.0")
    Me.Controls(CI_CTRL_MAX_STRIKES).Value = CStr(GetMaxStrikes())
    Me.Controls(CI_CTRL_DIAS_SUSPENSAO).Value = CStr(GetDiasSuspensaoStrike())
    Me.Controls(CI_CTRL_MAX_RECUSAS).Value = CStr(GetMaxRecusas())
    Me.Controls(CI_CTRL_MESES_SUSPENSAO).Value = CStr(GetMesesSuspensao())

    ' Ajustes de interface: acentuacao e rotulos
    On Error Resume Next
        ' Titulo da janela (corrige acentuacao)
        Me.caption = "Configura" & ChrW(231) & ChrW(245) & "es Iniciais"

        ' Manter a barra azul (Label42) apenas limpando o texto
        With Me.Controls("Label42")
            .caption = ""
            .Visible = True
        End With

        ' Corrigir textos de rotulos principais pela legenda atual (sem depender do nome do controle)
        For Each ctl In Me.Controls
            If typeName(ctl) = "Label" Then
                txt = LCase$(ctl.caption)

                ' Area Gestora do Municipio
                If InStr(txt, "area gestora") > 0 Then
                    ctl.caption = ChrW(193) & "rea Gestora do Munic" & ChrW(237) & "pio"
                    ctl.WordWrap = True
                End If

                ' Municipio (sem o "de")
                If InStr(txt, "municipio de") > 0 Or InStr(txt, "munic") > 0 Then
                    ctl.caption = "Munic" & ChrW(237) & "pio"
                End If
            End If
        Next ctl
    On Error GoTo 0
Exit Sub
erro_carregamento:
End Sub

Private Function ValorControleTexto(ByVal frm As Object, ByVal nomeControle As String, Optional ByVal valorPadrao As String = "") As String
    On Error GoTo usar_padrao
    ValorControleTexto = Trim$(CStr(frm.Controls(nomeControle).Value))
    Exit Function
usar_padrao:
    ValorControleTexto = Trim$(valorPadrao)
End Function


                   


