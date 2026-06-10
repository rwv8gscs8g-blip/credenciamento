Attribute VB_Name = "Util_Config"
Option Explicit

' Leitura centralizada de parâmetros da aba CONFIG (V10).
' Referência: Const_Colunas.SHEET_CONFIG
Private Const CFG_DIAS_SUSPENSAO_PADRAO As Long = 30
Private Const CFG_DIAS_SUSPENSAO_MAX As Long = 3650

Public Function GetConfig() As TConfig
    Dim ws As Worksheet
    Dim cfg As TConfig

    On Error GoTo erro
    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)

    cfg.GESTOR_NOME = Trim$(CStr(ws.Cells(LINHA_CFG_VALORES, COL_CFG_GESTOR).Value))
    cfg.CAM_LOGO = Trim$(CStr(ws.Cells(LINHA_CFG_VALORES, COL_CFG_LOGO).Value))
    cfg.municipio = Trim$(CStr(ws.Cells(LINHA_CFG_VALORES, COL_CFG_MUNICIPIO).Value))

    cfg.DIAS_DECISAO = CLng(Val(ws.Cells(LINHA_CFG_VALORES, COL_CFG_PRAZO_PREOS).Value))
    If cfg.DIAS_DECISAO <= 0 Then cfg.DIAS_DECISAO = 5

    cfg.MAX_RECUSAS = CLng(Val(ws.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value))
    If cfg.MAX_RECUSAS <= 0 Then cfg.MAX_RECUSAS = 3

    cfg.PERIODO_SUSPENSAO_MESES = CLng(Val(ws.Cells(LINHA_CFG_VALORES, COL_CFG_MESES_SUSPENSAO).Value))
    If cfg.PERIODO_SUSPENSAO_MESES <= 0 Then cfg.PERIODO_SUSPENSAO_MESES = 6

    GetConfig = cfg
    Exit Function

erro:
    cfg.DIAS_DECISAO = 5
    cfg.MAX_RECUSAS = 3
    cfg.PERIODO_SUSPENSAO_MESES = 6
    GetConfig = cfg
End Function

Public Function GetDiasDecisao() As Long
    GetDiasDecisao = GetConfig().DIAS_DECISAO
End Function

Public Function GetMaxRecusas() As Long
    GetMaxRecusas = GetConfig().MAX_RECUSAS
End Function

Public Function GetMesesSuspensao() As Long
    GetMesesSuspensao = GetConfig().PERIODO_SUSPENSAO_MESES
End Function

Public Function GetDiasSuspensaoRecusaPrazo() As Long
    Dim dias As Long
    Dim mensagem As String

    If Config_TryGetDiasSuspensaoRecusaPrazo(dias, mensagem) Then
        GetDiasSuspensaoRecusaPrazo = dias
    Else
        GetDiasSuspensaoRecusaPrazo = 0
    End If
End Function

Public Function GetNotaMinimaAvaliacao() As Double
    On Error GoTo falha

    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)

    Dim v As Double
    v = CDbl(Val(ws.Cells(LINHA_CFG_VALORES, COL_CFG_NOTA_MINIMA).Value))

    If v <= 0 Then v = 5#
    If v > 10# Then v = 10#

    GetNotaMinimaAvaliacao = v
    Exit Function

falha:
    GetNotaMinimaAvaliacao = 5#
End Function

' V12.0.0203 ONDA 1 - Numero de strikes (avaliacoes com media < nota minima)
' acumulados antes de suspender automaticamente a empresa.
' Coluna COL_CFG_MAX_STRIKES (L) na aba CONFIG.
'
' V12.0.0203 ONDA 10 Microdelta 1.5 fix2 (2026-05-01) - DEFAULT MUDADO
' DE 3 PARA 1. Justificativa: quando CONFIG nao tem valor preenchido
' (workbook em estado natural sem TV2_SetConfigCanonica), o default
' anterior 3 quebrava o comportamento legado (suspende na primeira
' nota baixa) e fazia testes V1 BO_330c/d/f falhar com "nota minima
' nao suspende". MAX_STRIKES=1 reproduz exatamente a regra antiga.
' Operador pode override para 3 (conservador) via Configuracao_Inicial.frm.
Public Function GetMaxStrikes() As Long
    On Error GoTo falha

    Dim ws As Worksheet
    Dim v As Long

    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)
    v = CLng(Val(ws.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_STRIKES).Value))

    If v < 1 Then v = 1
    If v > 50 Then v = 50

    GetMaxStrikes = v
    Exit Function

falha:
    GetMaxStrikes = 1
End Function

' V12.0.0206 ONDA 38.2.26 - Quantidade de dias da suspensao automatica
' disparada pela regra de strikes na avaliacao. Valor valido: 1..3650.
' Valores vazios/0/invalidos sao saneados pela migracao idempotente 0153
' a partir de COL_CFG_MESES_SUSPENSAO (legado) * 30, com minimo 30 dias.
Public Function GetDiasSuspensaoStrike() As Long
    Dim dias As Long
    Dim mensagem As String

    If Config_TryGetDiasSuspensaoStrike(dias, mensagem) Then
        GetDiasSuspensaoStrike = dias
    Else
        GetDiasSuspensaoStrike = 0
    End If
End Function

Public Function Config_TryGetDiasSuspensaoStrike(ByRef dias As Long, ByRef mensagem As String) As Boolean
    mensagem = ""
    If Not Config_MigrarPunicoesDias0153(mensagem) Then Exit Function
    Config_TryGetDiasSuspensaoStrike = Config_LerDiasSuspensao( _
        COL_CFG_DIAS_SUSPENSAO_STRIKE, _
        "DIAS_SUSPENSAO_STRIKE", _
        dias, _
        mensagem)
End Function

Public Function Config_TryGetDiasSuspensaoRecusaPrazo(ByRef dias As Long, ByRef mensagem As String) As Boolean
    mensagem = ""
    If Not Config_MigrarPunicoesDias0153(mensagem) Then Exit Function
    Config_TryGetDiasSuspensaoRecusaPrazo = Config_LerDiasSuspensao( _
        COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO, _
        "DIAS_SUSPENSAO_RECUSA_PRAZO", _
        dias, _
        mensagem)
End Function

Public Function Config_MigrarPunicoesDias0153(Optional ByRef detalhes As String) As Boolean
    Dim ws As Worksheet
    Dim rawMeses As String
    Dim rawStrike As String
    Dim rawRecusa As String
    Dim meses As Long
    Dim diasBase As Long
    Dim diasStrike As Long
    Dim diasRecusa As Long
    Dim precisaStrike As Boolean
    Dim precisaRecusa As Boolean
    Dim precisaHeader As Boolean
    Dim estCfg As Boolean
    Dim senCfg As String
    Dim errD As String

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)
    rawMeses = Trim$(CStr(ws.Cells(LINHA_CFG_VALORES, COL_CFG_MESES_SUSPENSAO).Value))
    rawStrike = Trim$(CStr(ws.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_STRIKE).Value))
    rawRecusa = Trim$(CStr(ws.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value))

    If Not Config_TentarInteiro(rawMeses, meses) Or meses < 1 Then meses = 1
    If meses > 121 Then
        diasBase = CFG_DIAS_SUSPENSAO_MAX
    Else
        diasBase = meses * 30
    End If
    If diasBase < CFG_DIAS_SUSPENSAO_PADRAO Then diasBase = CFG_DIAS_SUSPENSAO_PADRAO

    precisaStrike = Not Config_ValorDiasValido(rawStrike, diasStrike)
    precisaRecusa = Not Config_ValorDiasValido(rawRecusa, diasRecusa)
    precisaHeader = Trim$(CStr(ws.Cells(1, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value)) = ""

    If Not precisaStrike And Not precisaRecusa And Not precisaHeader Then
        detalhes = "MIGRACAO_0153=NOOP; STRIKE_DIAS=" & CStr(diasStrike) & "; RECUSA_PRAZO_DIAS=" & CStr(diasRecusa)
        Config_MigrarPunicoesDias0153 = True
        Exit Function
    End If

    If Not Util_PrepararAbaParaEscrita(ws, estCfg, senCfg) Then
        detalhes = "Nao foi possivel preparar CONFIG para migracao de punicoes em dias."
        Exit Function
    End If

    If precisaHeader Then ws.Cells(1, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value = "DIAS_SUSPENSAO_RECUSA_PRAZO"
    If precisaStrike Then
        ws.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_STRIKE).Value = diasBase
        diasStrike = diasBase
    End If
    If precisaRecusa Then
        ws.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value = diasBase
        diasRecusa = diasBase
    End If

    Call Util_RestaurarProtecaoAba(ws, estCfg, senCfg)

    detalhes = "MIGRACAO_0153=APLICADA; LEGADO_MESES_ANTES=" & rawMeses & _
               "; ANTES_STRIKE_DIAS=" & rawStrike & _
               "; ANTES_RECUSA_PRAZO_DIAS=" & rawRecusa & _
               "; DEPOIS_STRIKE_DIAS=" & CStr(diasStrike) & _
               "; DEPOIS_RECUSA_PRAZO_DIAS=" & CStr(diasRecusa) & _
               "; FATOR_DIAS_MES=30"

    RegistrarEvento EVT_TRANSACAO, ENT_ATIV, "CONFIG", _
        "MIGRACAO_PUNICOES_DIAS_0153; LEGADO_MESES_ANTES=" & rawMeses & _
        "; ANTES_STRIKE_DIAS=" & rawStrike & _
        "; ANTES_RECUSA_PRAZO_DIAS=" & rawRecusa, _
        "DEPOIS_STRIKE_DIAS=" & CStr(diasStrike) & _
        "; DEPOIS_RECUSA_PRAZO_DIAS=" & CStr(diasRecusa) & _
        "; FATOR_DIAS_MES=30", _
        "Util_Config"

    Config_MigrarPunicoesDias0153 = True
    Exit Function

falha:
    errD = Err.Description
    On Error Resume Next
    If Not ws Is Nothing Then Call Util_RestaurarProtecaoAba(ws, estCfg, senCfg)
    On Error GoTo 0
    detalhes = "Erro na migracao 0153 de punicoes em dias: " & errD
    Config_MigrarPunicoesDias0153 = False
End Function

Public Function Config_SnapshotPunicoesDias() As String
    Dim diasStrike As Long
    Dim diasRecusa As Long
    Dim msgStrike As String
    Dim msgRecusa As String

    If Config_TryGetDiasSuspensaoStrike(diasStrike, msgStrike) And _
       Config_TryGetDiasSuspensaoRecusaPrazo(diasRecusa, msgRecusa) Then
        Config_SnapshotPunicoesDias = "MAX_RECUSAS=" & CStr(GetMaxRecusas()) & _
            "; DIAS_RECUSA_PRAZO=" & CStr(diasRecusa) & _
            "; NOTA_MIN=" & Format$(GetNotaMinimaAvaliacao(), "0.00") & _
            "; MAX_STRIKES=" & CStr(GetMaxStrikes()) & _
            "; DIAS_STRIKE=" & CStr(diasStrike)
    Else
        Config_SnapshotPunicoesDias = "CONFIG_INVALIDA; STRIKE=" & msgStrike & "; RECUSA_PRAZO=" & msgRecusa
    End If
End Function

' V12.0.0203 ONDA 16 MD-16.2 (2026-05-02) - threshold de teste lento.
' Suites V2 com duracao acima desse valor (em ms) sao marcadas como
' "lento" no historico (cor condicional vermelha). Coluna COL_CFG_
' THRESHOLD_TESTE_LENTO_MS (N) na aba CONFIG.
' Default 500 ms. Faixa valida 1..600000 (10 min).
Public Function GetThresholdTesteLentoMS() As Long
    On Error GoTo falha

    Dim ws As Worksheet
    Dim v As Long

    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)
    v = CLng(Val(ws.Cells(LINHA_CFG_VALORES, COL_CFG_THRESHOLD_TESTE_LENTO_MS).Value))

    If v < 1 Then v = 500
    If v > 600000 Then v = 600000

    GetThresholdTesteLentoMS = v
    Exit Function

falha:
    GetThresholdTesteLentoMS = 500
End Function

' V12.0.0203 ONDA 17 MD-17.1.d.II (2026-05-03) - verbosity da StatusBar
' durante execucao de suites V2.
'   0 = silent (no-op; Application.StatusBar nao atualiza)
'   1 = minimum (so transicao de suite: 'V2 [SMOKE] iniciando' / 'concluido')
'   2 = default ('V2 [SMOKE] X/N: CS_xxx = OK')
'   3 = verbose ('V2 [SMOKE] X/N: CS_xxx = OK [etapa]')
' Coluna formal em CONFIG sera adicionada em Const_Colunas em MD futura.
' Por enquanto le coluna 99 (high enough para nao colidir). Default 2
' quando coluna ausente/vazia/invalida (compatibilidade backward total).
Public Function GetStatusBarVerbosity() As Long
    Const COL_VERBOSITY As Long = 99

    On Error GoTo falha

    Dim ws As Worksheet
    Dim valor As Variant
    Dim v As Long

    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)
    On Error Resume Next
    valor = ws.Cells(LINHA_CFG_VALORES, COL_VERBOSITY).Value
    On Error GoTo falha
    If IsEmpty(valor) Or CStr(valor) = "" Then
        GetStatusBarVerbosity = 2
        Exit Function
    End If
    v = CLng(Val(CStr(valor)))
    If v < 0 Then v = 0
    If v > 3 Then v = 3
    GetStatusBarVerbosity = v
    Exit Function

falha:
    GetStatusBarVerbosity = 2
End Function

Public Function Config_ValidarRegraStrikes( _
    ByVal notaCorteTxt As String, _
    ByVal maxStrikesTxt As String, _
    ByVal diasSuspensaoTxt As String, _
    ByRef mensagem As String _
) As Boolean
    Dim erros As String
    Dim valorNota As Double
    Dim valorInteiro As Long

    mensagem = ""
    notaCorteTxt = Trim$(notaCorteTxt)
    maxStrikesTxt = Trim$(maxStrikesTxt)
    diasSuspensaoTxt = Trim$(diasSuspensaoTxt)

    If notaCorteTxt <> "" Then
        If Not Config_TentarNumero(notaCorteTxt, valorNota) Then
            Config_AddErro erros, "TxtNotaCorte deve ser numero maior que 0 e ate 10."
        ElseIf valorNota <= 0# Or valorNota > 10# Then
            Config_AddErro erros, "TxtNotaCorte deve ficar maior que 0 e ate 10."
        End If
    End If

    If maxStrikesTxt <> "" Then
        If Not Config_TentarInteiro(maxStrikesTxt, valorInteiro) Then
            Config_AddErro erros, "TxtMaxStrikes deve ser numero inteiro entre 1 e 50."
        ElseIf valorInteiro < 1 Or valorInteiro > 50 Then
            Config_AddErro erros, "TxtMaxStrikes deve ficar entre 1 e 50."
        End If
    End If

    If diasSuspensaoTxt = "" Then
        Config_AddErro erros, "TxtDiasSuspensao deve ser informado."
    ElseIf Not Config_TentarInteiro(diasSuspensaoTxt, valorInteiro) Then
        Config_AddErro erros, "TxtDiasSuspensao deve ser numero inteiro entre 1 e 3650."
    ElseIf valorInteiro < 1 Or valorInteiro > CFG_DIAS_SUSPENSAO_MAX Then
        Config_AddErro erros, "TxtDiasSuspensao deve ficar entre 1 e 3650."
    End If

    If erros = "" Then
        Config_ValidarRegraStrikes = True
    Else
        mensagem = "Configuracao invalida: " & erros
        Config_ValidarRegraStrikes = False
    End If
End Function

Public Function Config_RegistrarFalhaValidacao(ByVal origem As String, ByVal mensagem As String) As Boolean
    On Error GoTo falha

    RegistrarEvento EVT_VALIDACAO_REJEITADA, ENT_ATIV, "CONFIG", _
        origem, _
        "CONFIG_INVALIDA | " & mensagem, _
        Application.UserName

    Config_RegistrarFalhaValidacao = True
    Exit Function

falha:
    Config_RegistrarFalhaValidacao = False
End Function

Private Function Config_TentarNumero(ByVal texto As String, ByRef valor As Double) As Boolean
    On Error GoTo falha

    texto = Trim$(texto)
    If texto = "" Then Exit Function
    If Not IsNumeric(texto) Then Exit Function

    valor = CDbl(texto)
    Config_TentarNumero = True
    Exit Function

falha:
    Config_TentarNumero = False
End Function

Private Function Config_TentarInteiro(ByVal texto As String, ByRef valor As Long) As Boolean
    Dim valorDouble As Double

    If Not Config_TentarNumero(texto, valorDouble) Then Exit Function
    If valorDouble <> Fix(valorDouble) Then Exit Function
    If valorDouble < -2147483648# Or valorDouble > 2147483647# Then Exit Function

    valor = CLng(valorDouble)
    Config_TentarInteiro = True
End Function

Private Function Config_ValorDiasValido(ByVal texto As String, ByRef dias As Long) As Boolean
    texto = Trim$(texto)
    If texto = "" Then Exit Function
    If Not Config_TentarInteiro(texto, dias) Then Exit Function
    If dias < 1 Or dias > CFG_DIAS_SUSPENSAO_MAX Then Exit Function
    Config_ValorDiasValido = True
End Function

Private Function Config_LerDiasSuspensao( _
    ByVal coluna As Long, _
    ByVal nomeCampo As String, _
    ByRef dias As Long, _
    ByRef mensagem As String _
) As Boolean
    Dim ws As Worksheet
    Dim raw As String

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)
    raw = Trim$(CStr(ws.Cells(LINHA_CFG_VALORES, coluna).Value))
    If Not Config_ValorDiasValido(raw, dias) Then
        mensagem = nomeCampo & " invalido: informe inteiro entre 1 e " & CStr(CFG_DIAS_SUSPENSAO_MAX) & " dias."
        Exit Function
    End If

    Config_LerDiasSuspensao = True
    Exit Function

falha:
    mensagem = "Erro ao ler " & nomeCampo & ": " & Err.Description
    Config_LerDiasSuspensao = False
End Function

Private Sub Config_AddErro(ByRef erros As String, ByVal detalhe As String)
    If erros = "" Then
        erros = detalhe
    Else
        erros = erros & " " & detalhe
    End If
End Sub

Public Function GetGestorNome() As String
    Dim cfg As TConfig
    cfg = GetConfig()
    GetGestorNome = cfg.GESTOR_NOME
End Function

Public Function GetMunicipio() As String
    Dim cfg As TConfig
    cfg = GetConfig()
    GetMunicipio = cfg.municipio
End Function

Public Function GetCamLogo() As String
    Dim cfg As TConfig
    cfg = GetConfig()
    GetCamLogo = cfg.CAM_LOGO
End Function

' ============================================================
' HELPERS PARA RELATORIOS DE NEGOCIO (V12.0.0149)
' ============================================================

Public Function Rel_TituloExibicao(ByVal titulo As String) As String
    Dim chave As String

    chave = UCase$(Trim$(titulo))

    Select Case chave
        Case "RELATORIO DE ENTIDADES CADASTRADAS NO CREDENCIAMENTO"
            Rel_TituloExibicao = "Relat" & ChrW(243) & "rio de Entidades Cadastradas no Credenciamento"
        Case "RELATORIO DE EMPRESAS CADASTRADAS NO CREDENCIAMENTO"
            Rel_TituloExibicao = "Relat" & ChrW(243) & "rio de Empresas Cadastradas no Credenciamento"
        Case "RELATORIO DE EMPRESAS CREDENCIADAS"
            Rel_TituloExibicao = "Relat" & ChrW(243) & "rio de Empresas Credenciadas"
        Case "RELATORIO DE EMPRESAS CREDENCIADAS POR SERVICO"
            Rel_TituloExibicao = "Relat" & ChrW(243) & "rio de Empresas Credenciadas por Servi" & ChrW(231) & "o"
        Case "RELATORIO DE ORDENS DE SERVICO ABERTAS"
            Rel_TituloExibicao = "Relat" & ChrW(243) & "rio de Ordens de Servi" & ChrW(231) & "o Abertas"
        Case "RELATORIO DE ORDENS DE SERVICO POR EMPRESA"
            Rel_TituloExibicao = "Relat" & ChrW(243) & "rio de Ordens de Servi" & ChrW(231) & "o por Empresa"
        Case "RELATORIO DE PRE-OS VENCIDAS"
            Rel_TituloExibicao = "Relat" & ChrW(243) & "rio de Pr" & ChrW(233) & "-OS Vencidas"
        Case "RELATORIO DE STATUS DO RODIZIO POR SERVICO"
            Rel_TituloExibicao = "Relat" & ChrW(243) & "rio de Status do Rod" & ChrW(237) & "zio por Servi" & ChrW(231) & "o"
        Case Else
            Rel_TituloExibicao = titulo
            Rel_TituloExibicao = Replace(Rel_TituloExibicao, "RELATORIO", "Relat" & ChrW(243) & "rio")
            Rel_TituloExibicao = Replace(Rel_TituloExibicao, "SERVICOS", "Servi" & ChrW(231) & "os")
            Rel_TituloExibicao = Replace(Rel_TituloExibicao, "SERVICO", "Servi" & ChrW(231) & "o")
            Rel_TituloExibicao = Replace(Rel_TituloExibicao, "PRE-OS", "Pr" & ChrW(233) & "-OS")
    End Select
End Function

Private Function Rel_CodigoCurto(ByVal titulo As String) As String
    Dim chave As String

    chave = UCase$(Trim$(titulo))

    Select Case chave
        Case "RELATORIO DE ENTIDADES CADASTRADAS NO CREDENCIAMENTO"
            Rel_CodigoCurto = "ENTIDADES_CADASTRADAS"
        Case "RELATORIO DE EMPRESAS CADASTRADAS NO CREDENCIAMENTO"
            Rel_CodigoCurto = "EMPRESAS_CADASTRADAS"
        Case "RELATORIO DE EMPRESAS CREDENCIADAS"
            Rel_CodigoCurto = "EMPRESAS_CREDENCIADAS"
        Case "RELATORIO DE EMPRESAS CREDENCIADAS POR SERVICO"
            Rel_CodigoCurto = "EMPRESAS_CREDENCIADAS_SERVICO"
        Case "RELATORIO DE ORDENS DE SERVICO ABERTAS"
            Rel_CodigoCurto = "OS_ABERTAS"
        Case "RELATORIO DE ORDENS DE SERVICO POR EMPRESA"
            Rel_CodigoCurto = "OS_POR_EMPRESA"
        Case "RELATORIO DE PRE-OS VENCIDAS"
            Rel_CodigoCurto = "PREOS_VENCIDAS"
        Case "RELATORIO DE STATUS DO RODIZIO POR SERVICO"
            Rel_CodigoCurto = "RODIZIO_STATUS_SERVICO"
        Case Else
            Rel_CodigoCurto = "RELATORIO"
    End Select
End Function

Public Function Rel_NomeArquivoSugerido(ByVal titulo As String, Optional ByVal extensao As String = "pdf") As String
    Dim baseNome As String

    baseNome = Rel_CodigoCurto(titulo) & "_" & Format$(Now, "yyyymmdd_hhnnss")
    If Trim$(extensao) <> "" Then
        Rel_NomeArquivoSugerido = baseNome & "." & LCase$(Trim$(extensao))
    Else
        Rel_NomeArquivoSugerido = baseNome
    End If
End Function

Public Sub Rel_ConfigurarPagina(ByVal ws As Worksheet, ByVal titulo As String, _
                                 Optional ByVal ultimaColLetra As String = "J", _
                                 Optional ByVal centralizarHorizontalmente As Boolean = False, _
                                 Optional ByVal orientacaoPagina As XlPageOrientation = xlLandscape)
    ' Configura PageSetup padrao para relatorios de negocio:
    '   - Titulo com acentos no cabecalho central
    '   - Municipio na esquerda
    '   - Data/hora na direita
    '   - Rodape com "Pagina X" acentuado
    '   - Paisagem, A4, margens laterais minimas, FitToPage
    Dim mun As String
    Dim tituloExibicao As String
    Dim referenciaRel As String

    tituloExibicao = Rel_TituloExibicao(titulo)
    referenciaRel = Rel_NomeArquivoSugerido(titulo, "")
    mun = GetMunicipio()
    If mun = "" Then
        mun = "Munic" & ChrW(237) & "pio n" & ChrW(227) & "o informado"
    Else
        If UCase$(Left$(mun, 9)) <> "MUNICIPIO" And UCase$(Left$(mun, 10)) <> "MUNIC" & ChrW(205) & "PIO" Then
            mun = "Munic" & ChrW(237) & "pio de " & mun
        End If
    End If

    With ws.PageSetup
        .LeftHeader = "&""Calibri,Regular""&08" & mun
        .CenterHeader = "&""Calibri,Bold""&12" & tituloExibicao
        .RightHeader = "&""Calibri,Regular""&08Impresso em &D " & ChrW(224) & "s &T"
        .LeftFooter = "&""Calibri,Regular""&07" & tituloExibicao
        .CenterFooter = "&""Calibri,Regular""&08P" & ChrW(225) & "gina &P de &N"
        .RightFooter = "&""Calibri,Regular""&07Ref " & referenciaRel & " | " & APP_RELEASE_ATUAL
        .Orientation = orientacaoPagina
        .PaperSize = xlPaperA4
        .LeftMargin = Application.CentimetersToPoints(0.2)
        .RightMargin = Application.CentimetersToPoints(0.2)
        .TopMargin = Application.CentimetersToPoints(2)
        .BottomMargin = Application.CentimetersToPoints(1)
        .HeaderMargin = Application.CentimetersToPoints(0.5)
        .FooterMargin = Application.CentimetersToPoints(0.5)
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .Zoom = False
        .PrintHeadings = False
        .PrintGridlines = False
        .PrintComments = xlPrintNoComments
        .PrintQuality = 600
        .CenterHorizontally = centralizarHorizontalmente
        .CenterVertically = False
        .Draft = False
        .Order = xlDownThenOver
        .BlackAndWhite = False
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
End Sub

Public Sub Rel_DefinirAreaImpressao(ByVal ws As Worksheet, ByVal areaImpressao As Range)
    If ws Is Nothing Then Exit Sub
    If areaImpressao Is Nothing Then Exit Sub

    ws.PageSetup.PrintArea = areaImpressao.Address
    Call Rel_AjustarZoomLarguraUtil(ws, areaImpressao)
End Sub

Private Sub Rel_AjustarZoomLarguraUtil(ByVal ws As Worksheet, ByVal areaImpressao As Range)
    Const REL_ZOOM_MIN_EXPAND As Long = 105
    Const REL_ZOOM_MAX_EXPAND As Long = 175
    Dim larguraDisponivel As Double
    Dim larguraArea As Double
    Dim zoomAlvo As Long

    If ws Is Nothing Then Exit Sub
    If areaImpressao Is Nothing Then Exit Sub

    larguraArea = areaImpressao.Width
    larguraDisponivel = Rel_LarguraPaginaUtil(ws)
    If larguraArea <= 0 Or larguraDisponivel <= 0 Then Exit Sub

    zoomAlvo = CLng(Fix((larguraDisponivel / larguraArea) * 100))
    With ws.PageSetup
        If zoomAlvo >= REL_ZOOM_MIN_EXPAND Then
            If zoomAlvo > REL_ZOOM_MAX_EXPAND Then zoomAlvo = REL_ZOOM_MAX_EXPAND
            .FitToPagesWide = False
            .FitToPagesTall = False
            .Zoom = zoomAlvo
        Else
            .Zoom = False
            .FitToPagesWide = 1
            .FitToPagesTall = False
        End If
    End With
End Sub

Private Function Rel_LarguraPaginaUtil(ByVal ws As Worksheet) As Double
    Dim larguraPapel As Double

    If ws Is Nothing Then Exit Function

    If ws.PageSetup.Orientation = xlLandscape Then
        larguraPapel = Application.CentimetersToPoints(29.7)
    Else
        larguraPapel = Application.CentimetersToPoints(21)
    End If

    Rel_LarguraPaginaUtil = larguraPapel - ws.PageSetup.LeftMargin - ws.PageSetup.RightMargin
End Function

Public Sub Rel_FormatarCabecalho(ByVal ws As Worksheet, ByVal ultimaCol As Long, _
                                  Optional ByVal linhaHeader As Long = 1)
    ' Formata a linha de cabecalho de dados com estilo profissional:
    '   - Fundo azul escuro, texto branco, negrito, bordas
    With ws.Range(ws.Cells(linhaHeader, 1), ws.Cells(linhaHeader, ultimaCol))
        .Font.Bold = True
        .Font.Color = RGB(255, 255, 255)
        .Font.Size = 9
        .Interior.Color = RGB(0, 51, 102)
        .HorizontalAlignment = xlCenter
        .Borders(xlEdgeBottom).LineStyle = xlContinuous
        .Borders(xlEdgeBottom).Weight = xlThin
        .Borders(xlInsideVertical).LineStyle = xlContinuous
        .Borders(xlInsideVertical).Weight = xlHairline
        .Borders(xlInsideVertical).Color = RGB(150, 180, 210)
    End With
End Sub

Public Sub Rel_FormatarDados(ByVal ws As Worksheet, ByVal linhaInicio As Long, _
                              ByVal linhaFim As Long, ByVal ultimaCol As Long)
    ' Aplica bordas finas e zebrado sutil nas linhas de dados
    Dim rng As Range
    Set rng = ws.Range(ws.Cells(linhaInicio, 1), ws.Cells(linhaFim, ultimaCol))

    With rng.Borders(xlEdgeBottom)
        .LineStyle = xlContinuous: .Weight = xlThin
    End With
    With rng.Borders(xlEdgeTop)
        .LineStyle = xlContinuous: .Weight = xlThin
    End With
    With rng.Borders(xlInsideHorizontal)
        .LineStyle = xlContinuous: .Weight = xlHairline: .Color = RGB(200, 200, 200)
    End With

    ' Zebrado sutil
    Dim r As Long
    For r = linhaInicio To linhaFim
        If (r - linhaInicio) Mod 2 = 1 Then
            ws.Range(ws.Cells(r, 1), ws.Cells(r, ultimaCol)).Interior.Color = RGB(240, 245, 250)
        End If
    Next r
End Sub


