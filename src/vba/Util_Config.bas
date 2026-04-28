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

' V12.0.0203 ONDA 1 — Numero de strikes (avaliacoes com media < nota minima)
' acumulados antes de suspender automaticamente a empresa.
' Default conservador 3. Coluna COL_CFG_MAX_STRIKES (L) na aba CONFIG.
' MAX_STRIKES = 1 reproduz a regra antiga (suspende na primeira nota baixa).
Public Function GetMaxStrikes() As Long
    On Error GoTo falha

    Dim ws As Worksheet
    Dim v As Long

    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)
    v = CLng(Val(ws.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_STRIKES).Value))

    If v < 1 Then v = 3
    If v > 50 Then v = 50

    GetMaxStrikes = v
    Exit Function

falha:
    GetMaxStrikes = 3
End Function

' V12.0.0203 ONDA 1 — Quantidade de dias da suspensao automatica
' disparada pela regra de strikes na avaliacao. Default 90 dias.
' Coluna COL_CFG_DIAS_SUSPENSAO_STRIKE (M) na aba CONFIG.
' Quando o valor for <= 0, o helper Svc_Rodizio.Suspender cai no
' fallback historico em meses (PERIODO_SUSPENSAO_MESES) — preserva
' compatibilidade com a regra antiga de suspensao por excesso de recusas.
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
    GetDiasSuspensaoStrike = 90
End Function

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

