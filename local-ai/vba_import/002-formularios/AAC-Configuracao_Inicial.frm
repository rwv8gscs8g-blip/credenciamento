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
' Nome legado no .frx; a semantica V12.0.0206 e dias de suspensao por recusa/prazo.
Private Const CI_CTRL_DIAS_RECUSA_PRAZO As String = "TxtMesesSuspensao"

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
    Optional ByVal diasRecusaPrazoTeste As String = "", _
    Optional ByVal prazoPreOSTeste As String = "", _
    Optional ByVal gestorTeste As String = "", _
    Optional ByVal municipioTeste As String = "" _
) As Boolean
    On Error GoTo falha

    CI_GarantirControlesRegraNegocio
    If gestorTeste <> "" Then Me.Controls("Gestor_Rodizio").Value = gestorTeste
    If municipioTeste <> "" Then Me.Controls("Municipio_gestao").Value = municipioTeste
    Me.Controls(CI_CTRL_NOTA_CORTE).Value = notaCorteTeste
    Me.Controls(CI_CTRL_MAX_STRIKES).Value = maxStrikesTeste
    Me.Controls(CI_CTRL_DIAS_SUSPENSAO).Value = diasSuspensaoTeste
    If maxRecusasTeste <> "" Then Me.Controls(CI_CTRL_MAX_RECUSAS).Value = maxRecusasTeste
    If diasRecusaPrazoTeste <> "" Then Me.Controls(CI_CTRL_DIAS_RECUSA_PRAZO).Value = diasRecusaPrazoTeste
    If prazoPreOSTeste <> "" Then Me.Controls(CI_CTRL_PRAZO_PREOS).Value = prazoPreOSTeste
    CI_TestarPersistenciaPainel = CI_PersistirParametros(False, False, False, detalhes)
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
    CI_TestarPersistenciaPainel = False
End Function

Public Function CI_TestarNovoPeriodoDeterministico( _
    ByVal nomePasta As String, _
    ByRef pastaSaida As String, _
    ByRef copiaSaida As String, _
    ByRef detalhes As String _
) As Boolean
    On Error GoTo falha

    Dim fso As Object
    Dim basePath As String
    Dim nomeSeguro As String
    Dim preAntes As Long
    Dim cadAntes As Long
    Dim preDepois As Long
    Dim cadDepois As Long

    nomeSeguro = CI_NormalizarNomePastaNovoPeriodo(nomePasta)
    If Len(nomeSeguro) = 0 Then
        detalhes = "Nome de pasta vazio."
        Exit Function
    End If

    basePath = ThisWorkbook.path
    If Len(Trim$(basePath)) = 0 Then
        detalhes = "Workbook ainda nao possui pasta salva."
        Exit Function
    End If

    preAntes = CI_QtdLinhasDados(SHEET_PREOS)
    cadAntes = CI_QtdLinhasDados(SHEET_CAD_OS)

    Set fso = CreateObject("Scripting.FileSystemObject")
    pastaSaida = CI_PathJoin(basePath, nomeSeguro)
    If Not fso.FolderExists(pastaSaida) Then fso.CreateFolder pastaSaida

    copiaSaida = CI_PathJoin(pastaSaida, Format$(Now(), "yyyymmdd_hhnnss_") & ThisWorkbook.Name)
    ThisWorkbook.SaveCopyAs copiaSaida

    If Not CI_LimparPreOSCadOSNovoPeriodo(detalhes) Then Exit Function

    preDepois = CI_QtdLinhasDados(SHEET_PREOS)
    cadDepois = CI_QtdLinhasDados(SHEET_CAD_OS)

    detalhes = "PASTA=" & pastaSaida & _
               "; COPIA=" & copiaSaida & _
               "; PRE_OS_ANTES=" & CStr(preAntes) & _
               "; CAD_OS_ANTES=" & CStr(cadAntes) & _
               "; PRE_OS_DEPOIS=" & CStr(preDepois) & _
               "; CAD_OS_DEPOIS=" & CStr(cadDepois)
    CI_TestarNovoPeriodoDeterministico = True
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
    CI_TestarNovoPeriodoDeterministico = False
End Function

Private Function CI_LimparPreOSCadOSNovoPeriodo(ByRef detalhes As String) As Boolean
    On Error GoTo falha

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

    Set wsPreOS = ThisWorkbook.Sheets(SHEET_PREOS)
    Set wsCADOS = ThisWorkbook.Sheets(SHEET_CAD_OS)

    ultimaLinhaPreOS = CI_UltimaLinhaUsadaAteColuna(wsPreOS, COL_PREOS_OS_ID)
    ultimaLinhaCADOS = CI_UltimaLinhaUsadaAteColuna(wsCADOS, COL_OS_JUSTIF_DIV)

    If Not Util_PrepararAbaParaEscrita(wsPreOS, estProtPreOS, senhaPreOS) Then
        detalhes = "Nao foi possivel iniciar novo periodo: aba PRE_OS protegida para escrita."
        Exit Function
    End If
    preOSPreparada = True

    If Not Util_PrepararAbaParaEscrita(wsCADOS, estProtCADOS, senhaCADOS) Then
        detalhes = "Nao foi possivel iniciar novo periodo: aba CAD_OS protegida para escrita."
        GoTo limpar
    End If
    cadOSPreparada = True

    If ultimaLinhaPreOS >= LINHA_DADOS Then
        wsPreOS.Range(wsPreOS.Cells(LINHA_DADOS, 1), _
                      wsPreOS.Cells(ultimaLinhaPreOS, COL_PREOS_OS_ID)).ClearContents
    End If
    wsPreOS.Cells(1, COL_CONTADOR_AR).Value = 0

    If ultimaLinhaCADOS >= LINHA_DADOS Then
        wsCADOS.Range(wsCADOS.Cells(LINHA_DADOS, 1), _
                      wsCADOS.Cells(ultimaLinhaCADOS, COL_OS_JUSTIF_DIV)).ClearContents
    End If
    wsCADOS.Cells(1, COL_CONTADOR_AR).Value = 0

    CI_LimparPreOSCadOSNovoPeriodo = True

limpar:
    If cadOSPreparada Then Call Util_RestaurarProtecaoAba(wsCADOS, estProtCADOS, senhaCADOS)
    If preOSPreparada Then Call Util_RestaurarProtecaoAba(wsPreOS, estProtPreOS, senhaPreOS)
    If CI_LimparPreOSCadOSNovoPeriodo Then
        Call PreenchimentoServico
        Call AtualizarListaEntidadeMenuAtual
        Call AtualizarListaEmpresaMenuAtual
        Call PreenchimentoEntidadeRodizio
        Call PreencherAvaliarOS
        Call PreencherManutencaoValor
    End If
    Exit Function

falha:
    CI_LimparPreOSCadOSNovoPeriodo = False
    detalhes = "Falha ao iniciar novo periodo: (" & CStr(Err.Number) & ") " & Err.Description
    On Error Resume Next
    If cadOSPreparada Then Call Util_RestaurarProtecaoAba(wsCADOS, estProtCADOS, senhaCADOS)
    If preOSPreparada Then Call Util_RestaurarProtecaoAba(wsPreOS, estProtPreOS, senhaPreOS)
    On Error GoTo 0
End Function

Private Function CI_QtdLinhasDados(ByVal nomeAba As String) As Long
    Dim ws As Worksheet
    Dim colunaChave As Long
    Dim intervalo As Range

    Set ws = ThisWorkbook.Sheets(nomeAba)
    colunaChave = CI_ColunaChaveDados(nomeAba)
    Set intervalo = ws.Range(ws.Cells(LINHA_DADOS, colunaChave), _
                             ws.Cells(ws.Rows.Count, colunaChave))
    CI_QtdLinhasDados = Application.WorksheetFunction.CountA(intervalo)
End Function

Private Function CI_ColunaChaveDados(ByVal nomeAba As String) As Long
    Select Case UCase$(nomeAba)
        Case UCase$(SHEET_PREOS)
            CI_ColunaChaveDados = COL_PREOS_ID
        Case UCase$(SHEET_CAD_OS)
            CI_ColunaChaveDados = COL_OS_ID
        Case Else
            CI_ColunaChaveDados = 1
    End Select
End Function

Private Function CI_UltimaLinhaUsadaAteColuna(ByVal ws As Worksheet, ByVal ultimaColuna As Long) As Long
    Dim col As Long
    Dim ultima As Long
    Dim linhaColuna As Long

    ultima = LINHA_DADOS - 1
    For col = 1 To ultimaColuna
        linhaColuna = ws.Cells(ws.Rows.Count, col).End(xlUp).row
        If linhaColuna > ultima Then ultima = linhaColuna
    Next col
    CI_UltimaLinhaUsadaAteColuna = ultima
End Function

Private Function CI_NormalizarNomePastaNovoPeriodo(ByVal nomePasta As String) As String
    Dim nome As String

    nome = Trim$(nomePasta)
    nome = Replace(nome, "/", "-")
    nome = Replace(nome, "\", "-")
    nome = Replace(nome, ":", "-")
    nome = Replace(nome, "*", "-")
    nome = Replace(nome, "?", "-")
    nome = Replace(nome, """", "'")
    nome = Replace(nome, "<", "-")
    nome = Replace(nome, ">", "-")
    nome = Replace(nome, "|", "-")
    CI_NormalizarNomePastaNovoPeriodo = nome
End Function

Private Function CI_PathJoin(ByVal pasta As String, ByVal nome As String) As String
    If Right$(pasta, 1) = "\" Or Right$(pasta, 1) = "/" Then
        CI_PathJoin = pasta & nome
    Else
        CI_PathJoin = pasta & Application.PathSeparator & nome
    End If
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
    Dim diasRecusaPrazoTxt As String
    Dim notaCorteVal As Double
    Dim maxStrikesVal As Long
    Dim diasSuspensaoVal As Long
    Dim prazoVal As Long
    Dim maxRecusasVal As Long
    Dim diasRecusaPrazoVal As Long
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
    diasRecusaPrazoTxt = CI_ValorControleObrigatorio(CI_CTRL_DIAS_RECUSA_PRAZO)

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

    If Not CI_ValidarRegraRecusas(maxRecusasTxt, diasRecusaPrazoTxt, msgValidacao) Then
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
    diasRecusaPrazoVal = CLng(CDbl(diasRecusaPrazoTxt))

    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_GESTOR).Value = gestorTxt
    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_LOGO).Value = logoTxt
    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MUNICIPIO).Value = municipioTxt
    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_PRAZO_PREOS).Value = prazoVal
    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value = maxRecusasVal
    wsCfg.Cells(1, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value = "DIAS_SUSPENSAO_RECUSA_PRAZO"
    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value = diasRecusaPrazoVal

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
        If diasSuspensaoVal >= 1 And diasSuspensaoVal <= 3650 Then
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
    CI_ExigirControle CI_CTRL_DIAS_RECUSA_PRAZO
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
    ByVal diasRecusaPrazoTxt As String, _
    ByRef mensagem As String _
) As Boolean
    Dim erros As String
    Dim valorInteiro As Long

    mensagem = ""
    maxRecusasTxt = Trim$(maxRecusasTxt)
    diasRecusaPrazoTxt = Trim$(diasRecusaPrazoTxt)

    If maxRecusasTxt = "" Then
        CI_AddErro erros, "TP_Valor deve ser informado."
    ElseIf Not CI_TentarInteiro(maxRecusasTxt, valorInteiro) Then
        CI_AddErro erros, "TP_Valor deve ser numero inteiro entre 1 e 50."
    ElseIf valorInteiro < 1 Or valorInteiro > 50 Then
        CI_AddErro erros, "TP_Valor deve ficar entre 1 e 50."
    End If

    If diasRecusaPrazoTxt = "" Then
        CI_AddErro erros, "Dias de suspensao por recusa/prazo deve ser informado."
    ElseIf Not CI_TentarInteiro(diasRecusaPrazoTxt, valorInteiro) Then
        CI_AddErro erros, "Dias de suspensao por recusa/prazo deve ser numero inteiro entre 1 e 3650."
    ElseIf valorInteiro < 1 Or valorInteiro > 3650 Then
        CI_AddErro erros, "Dias de suspensao por recusa/prazo deve ficar entre 1 e 3650."
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

        ultimaLinhaPreOS = CI_UltimaLinhaUsadaAteColuna(wsPreOS, COL_PREOS_OS_ID)
        ultimaLinhaCADOS = CI_UltimaLinhaUsadaAteColuna(wsCADOS, COL_OS_JUSTIF_DIV)

        If Not Util_PrepararAbaParaEscrita(wsPreOS, estProtPreOS, senhaPreOS) Then
            MsgBox "Não foi possível iniciar o novo período: aba PRE_OS protegida para escrita.", _
                   vbCritical, "Configurações iniciais"
            Exit Sub
        End If
        preOSPreparada = True

        If Not Util_PrepararAbaParaEscrita(wsCADOS, estProtCADOS, senhaCADOS) Then
            If preOSPreparada Then Call Util_RestaurarProtecaoAba(wsPreOS, estProtPreOS, senhaPreOS)
            MsgBox "Não foi possível iniciar o novo período: aba CAD_OS protegida para escrita.", _
                   vbCritical, "Configurações iniciais"
            Exit Sub
        End If
        cadOSPreparada = True

        If ultimaLinhaPreOS >= LINHA_DADOS Then
            wsPreOS.Range(wsPreOS.Cells(LINHA_DADOS, 1), _
                          wsPreOS.Cells(ultimaLinhaPreOS, COL_PREOS_OS_ID)).ClearContents
        End If
        wsPreOS.Cells(1, COL_CONTADOR_AR).Value = 0

        If ultimaLinhaCADOS >= LINHA_DADOS Then
            wsCADOS.Range(wsCADOS.Cells(LINHA_DADOS, 1), _
                          wsCADOS.Cells(ultimaLinhaCADOS, COL_OS_JUSTIF_DIV)).ClearContents
        End If
        wsCADOS.Cells(1, COL_CONTADOR_AR).Value = 0

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

Private Sub Label56_Click()
End Sub

Private Sub CommandButton1_Click()
    CI_AbrirAjudaHBN
End Sub

Private Sub UserForm_Initialize()
On Error GoTo erro_carregamento:
    ' V12: eliminado Sheets.Select + .Select + ActiveCell (proibidos; formulario modal).
    ' Usa referencia direta via ThisWorkbook.Sheets().Cells().Value.
    Dim wsCfg As Worksheet
    Dim ctl As Object
    Dim txt As String
    Dim diasStrikeCfg As Long
    Dim diasRecusaPrazoCfg As Long
    Dim msgCfg As String

    Set wsCfg = ThisWorkbook.Sheets(SHEET_CONFIG)

    Gestor_Rodizio = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_GESTOR).Value
    Caminho_Logo = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_LOGO).Value
    Municipio_gestao = Funcoes.NormalizarTextoPTBR(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MUNICIPIO).Value)
    CI_GarantirControlesRegraNegocio
    CI_PrepararCampoTextoEditavel CI_CTRL_DIAS_RECUSA_PRAZO
    Me.Controls(CI_CTRL_PRAZO_PREOS).Value = CStr(GetDiasDecisao())
    Me.Controls(CI_CTRL_NOTA_CORTE).Value = Format$(GetNotaMinimaAvaliacao(), "0.0")
    Me.Controls(CI_CTRL_MAX_STRIKES).Value = CStr(GetMaxStrikes())
    Me.Controls(CI_CTRL_MAX_RECUSAS).Value = CStr(GetMaxRecusas())
    If Config_TryGetDiasSuspensaoStrike(diasStrikeCfg, msgCfg) Then
        Me.Controls(CI_CTRL_DIAS_SUSPENSAO).Value = CStr(diasStrikeCfg)
    Else
        Me.Controls(CI_CTRL_DIAS_SUSPENSAO).Value = ""
    End If
    msgCfg = ""
    If Config_TryGetDiasSuspensaoRecusaPrazo(diasRecusaPrazoCfg, msgCfg) Then
        Me.Controls(CI_CTRL_DIAS_RECUSA_PRAZO).Value = CStr(diasRecusaPrazoCfg)
    Else
        Me.Controls(CI_CTRL_DIAS_RECUSA_PRAZO).Value = ""
    End If

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

                If InStr(txt, "recusa") > 0 And InStr(txt, "puni") > 0 Then
                    ctl.caption = "recusa(s) ou expiracao de prazo, suspender por"
                    ctl.WordWrap = True
                End If

                If InStr(txt, "strike") > 0 And InStr(txt, "puni") > 0 Then
                    ctl.caption = "strike(s), suspender por"
                    ctl.WordWrap = True
                End If

                If InStr(txt, "mes") > 0 And Len(txt) <= 12 Then
                    ctl.caption = "dia(s)."
                End If
            End If
        Next ctl
    On Error GoTo 0
Exit Sub
erro_carregamento:
End Sub

Private Sub CI_PrepararCampoTextoEditavel(ByVal nomeControle As String)
    On Error Resume Next
    With Me.Controls(nomeControle)
        .Enabled = True
        .Locked = False
        .TabStop = True
        .BackColor = &HFFFFFF
    End With
    On Error GoTo 0
End Sub

Private Sub CI_AbrirAjudaHBN()
    Dim caminho As String

    On Error GoTo falha

    caminho = ThisWorkbook.Path & Application.PathSeparator & "docs" & _
              Application.PathSeparator & "help" & _
              Application.PathSeparator & "hbn" & _
              Application.PathSeparator & "configuracoes-iniciais.html"

    If Dir(caminho) = "" Then
        MsgBox "Ajuda HBN nao encontrada:" & vbCrLf & caminho, _
               vbExclamation, "Configurações iniciais"
        Exit Sub
    End If

    Application.FollowHyperlink Address:=caminho
    Exit Sub

falha:
    MsgBox "Nao foi possivel abrir a ajuda HBN." & vbCrLf & _
           "Detalhe: " & Err.Description, vbExclamation, "Configurações iniciais"
End Sub

Private Function ValorControleTexto(ByVal frm As Object, ByVal nomeControle As String, Optional ByVal valorPadrao As String = "") As String
    On Error GoTo usar_padrao
    ValorControleTexto = Trim$(CStr(frm.Controls(nomeControle).Value))
    Exit Function
usar_padrao:
    ValorControleTexto = Trim$(valorPadrao)
End Function


