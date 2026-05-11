Attribute VB_Name = "Util_Config"
Option Explicit

' Leitura centralizada de parâmetros da aba CONFIG (V10).
' Referência: Const_Colunas.SHEET_CONFIG

Public Function GetConfig() As TConfig
    Dim ws As Worksheet
    Dim cfg As TConfig

    On Error GoTo Erro
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

Erro:
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

' V12.0.0203 ONDA 1 - Quantidade de dias da suspensao automatica
' disparada pela regra de strikes na avaliacao.
' Coluna COL_CFG_DIAS_SUSPENSAO_STRIKE (M) na aba CONFIG.
' Quando o valor for <= 0, o helper Svc_Rodizio.Suspender cai no
' fallback historico em meses (PERIODO_SUSPENSAO_MESES).
'
' V12.0.0203 ONDA 10 Microdelta 1.5 fix2 (2026-05-01) - DEFAULT MUDADO
' DE 90 PARA 0. Justificativa: quando CONFIG nao tem valor (workbook
' natural), default 0 forca fallback meses, alinhando com regra antiga.
' Operador pode override para 90 (ou outro valor) via Configuracao_Inicial.frm.
Public Function GetDiasSuspensaoStrike() As Long
    On Error GoTo falha

    Dim ws As Worksheet
    Dim v As Long

    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)
    v = CLng(Val(ws.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_STRIKE).Value))

    If v < 0 Then v = 0
    If v > 3650 Then v = 3650

    GetDiasSuspensaoStrike = v
    Exit Function

falha:
    GetDiasSuspensaoStrike = 0
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

    If diasSuspensaoTxt <> "" Then
        If Not Config_TentarInteiro(diasSuspensaoTxt, valorInteiro) Then
            Config_AddErro erros, "TxtDiasSuspensao deve ser numero inteiro entre 0 e 3650."
        ElseIf valorInteiro < 0 Or valorInteiro > 3650 Then
            Config_AddErro erros, "TxtDiasSuspensao deve ficar entre 0 e 3650."
        End If
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
    '   - Paisagem, A4, margens estreitas, FitToPage
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
        .LeftMargin = Application.CentimetersToPoints(0.5)
        .RightMargin = Application.CentimetersToPoints(0.5)
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


