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

Public Sub Rel_ConfigurarPagina(ByVal ws As Worksheet, ByVal titulo As String, _
                                 Optional ByVal ultimaColLetra As String = "J")
    ' Configura PageSetup padrao para relatorios de negocio:
    '   - Titulo com acentos no cabecalho central
    '   - Municipio na esquerda
    '   - Data/hora na direita
    '   - Rodape com "Pagina X" acentuado
    '   - Paisagem, A4, margens estreitas, FitToPage
    Dim mun As String
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
        .CenterHeader = "&""Calibri,Bold""&12" & titulo
        .RightHeader = "&""Calibri,Regular""&08Impresso em &D " & ChrW(224) & "s &T"
        .LeftFooter = ""
        .CenterFooter = "&""Calibri,Regular""&08P" & ChrW(225) & "gina &P de &N"
        .RightFooter = "&""Calibri,Regular""&07" & APP_RELEASE_ATUAL
        .Orientation = xlLandscape
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
        .CenterHorizontally = True
        .Draft = False
        .Order = xlDownThenOver
        .BlackAndWhite = False
        .PrintErrors = xlPrintErrorsDisplayed
        .OddAndEvenPagesHeaderFooter = False
        .DifferentFirstPageHeaderFooter = False
        .ScaleWithDocHeaderFooter = True
        .AlignMarginsHeaderFooter = True
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

