Attribute VB_Name = "UX_IniciarSistema"
Option Explicit

Private Const UX_IS_SHAPE_NAME As String = "UX_BTN_INICIAR_SISTEMA"
Private Const UX_IS_ONACTION As String = "IniciarSistema"
Private Const UX_IS_ANCHOR As String = "J1"
Private Const UX_IS_WIDTH As Double = 136
Private Const UX_IS_HEIGHT As Double = 26

Public Function UX_IniciarSistema_NomeShape() As String
    UX_IniciarSistema_NomeShape = UX_IS_SHAPE_NAME
End Function

Public Function UX_IniciarSistema_OnActionEsperado() As String
    UX_IniciarSistema_OnActionEsperado = UX_IS_ONACTION
End Function

Public Function UX_IniciarSistema_ResolverAba(Optional ByVal nomeAba As String = "") As Worksheet
    Dim ws As Worksheet
    Dim preferida As Variant

    On Error GoTo falha

    If Trim$(nomeAba) <> "" Then
        Set UX_IniciarSistema_ResolverAba = ThisWorkbook.Worksheets(nomeAba)
        Exit Function
    End If

    If TypeName(ActiveSheet) = "Worksheet" Then
        Set ws = ActiveSheet
        If ws.Parent Is ThisWorkbook Then
            If ws.Visible = xlSheetVisible And Not UX_IS_AbaCritica(ws.Name) Then
                Set UX_IniciarSistema_ResolverAba = ws
                Exit Function
            End If
        End If
    End If

    For Each preferida In Array("RESULTADO_QA_V2", "ROTEIRO_ASSISTIDO_V2", "HISTORICO_QA_V2", "VALIDACAO_RELEASE")
        Set ws = UX_IS_AbaPorNome(CStr(preferida))
        If Not ws Is Nothing Then
            If ws.Visible = xlSheetVisible And Not UX_IS_AbaCritica(ws.Name) Then
                Set UX_IniciarSistema_ResolverAba = ws
                Exit Function
            End If
        End If
    Next preferida

    For Each ws In ThisWorkbook.Worksheets
        If ws.Visible = xlSheetVisible And Not UX_IS_AbaCritica(ws.Name) Then
            Set UX_IniciarSistema_ResolverAba = ws
            Exit Function
        End If
    Next ws

    Exit Function

falha:
    Set UX_IniciarSistema_ResolverAba = Nothing
End Function

Public Function UX_IniciarSistema_Instalar(Optional ByVal nomeAba As String = "") As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim shp As Shape
    Dim estavaProtegida As Boolean
    Dim senhaUsada As String

    On Error GoTo falha

    Set ws = UX_IniciarSistema_ResolverAba(nomeAba)
    If ws Is Nothing Then
        res.sucesso = False
        res.mensagem = "Aba alvo nao encontrada para instalar o atalho."
        UX_IniciarSistema_Instalar = res
        Exit Function
    End If

    If UX_IS_AbaCritica(ws.Name) Then
        res.sucesso = False
        res.mensagem = "Aba critica nao recebe shape UX: " & ws.Name
        UX_IniciarSistema_Instalar = res
        Exit Function
    End If

    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaUsada) Then
        res.sucesso = False
        res.mensagem = "Nao foi possivel preparar a aba para escrita: " & ws.Name
        UX_IniciarSistema_Instalar = res
        Exit Function
    End If

    Set shp = UX_IS_ObterShape(ws)
    If shp Is Nothing Then
        Set shp = ws.Shapes.AddShape(msoShapeRoundedRectangle, _
                                     ws.Range(UX_IS_ANCHOR).Left + 4, _
                                     ws.Range(UX_IS_ANCHOR).Top + 4, _
                                     UX_IS_WIDTH, UX_IS_HEIGHT)
        shp.Name = UX_IS_SHAPE_NAME
    End If

    UX_IS_ConfigurarShape ws, shp
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaUsada

    res.sucesso = True
    res.mensagem = "Atalho IniciarSistema instalado em " & ws.Name
    res.IdGerado = UX_IS_SHAPE_NAME
    UX_IniciarSistema_Instalar = res
    Exit Function

falha:
    On Error Resume Next
    If Not ws Is Nothing Then Util_RestaurarProtecaoAba ws, estavaProtegida, senhaUsada
    On Error GoTo 0
    res.sucesso = False
    res.mensagem = "Erro ao instalar atalho IniciarSistema: " & Err.Description
    res.CodigoErro = Err.Number
    UX_IniciarSistema_Instalar = res
End Function

Public Function UX_IniciarSistema_Remover(Optional ByVal nomeAba As String = "") As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim shp As Shape
    Dim estavaProtegida As Boolean
    Dim senhaUsada As String

    On Error GoTo falha

    Set ws = UX_IniciarSistema_ResolverAba(nomeAba)
    If ws Is Nothing Then
        res.sucesso = True
        res.mensagem = "Aba alvo nao encontrada; nada a remover."
        UX_IniciarSistema_Remover = res
        Exit Function
    End If

    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaUsada) Then
        res.sucesso = False
        res.mensagem = "Nao foi possivel preparar a aba para remover o atalho: " & ws.Name
        UX_IniciarSistema_Remover = res
        Exit Function
    End If

    Set shp = UX_IS_ObterShape(ws)
    If Not shp Is Nothing Then shp.Delete

    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaUsada

    res.sucesso = True
    res.mensagem = "Atalho IniciarSistema removido de " & ws.Name
    UX_IniciarSistema_Remover = res
    Exit Function

falha:
    On Error Resume Next
    If Not ws Is Nothing Then Util_RestaurarProtecaoAba ws, estavaProtegida, senhaUsada
    On Error GoTo 0
    res.sucesso = False
    res.mensagem = "Erro ao remover atalho IniciarSistema: " & Err.Description
    res.CodigoErro = Err.Number
    UX_IniciarSistema_Remover = res
End Function

Public Function UX_IniciarSistema_ContarAtalhos(Optional ByVal nomeAba As String = "") As Long
    Dim ws As Worksheet
    Dim shp As Shape
    Dim qtd As Long

    On Error GoTo falha

    Set ws = UX_IniciarSistema_ResolverAba(nomeAba)
    If ws Is Nothing Then Exit Function

    For Each shp In ws.Shapes
        If StrComp(shp.Name, UX_IS_SHAPE_NAME, vbTextCompare) = 0 Then qtd = qtd + 1
    Next shp

    UX_IniciarSistema_ContarAtalhos = qtd
    Exit Function

falha:
    UX_IniciarSistema_ContarAtalhos = 0
End Function

Public Function UX_IniciarSistema_OnActionAtual(Optional ByVal nomeAba As String = "") As String
    Dim ws As Worksheet
    Dim shp As Shape

    On Error GoTo falha

    Set ws = UX_IniciarSistema_ResolverAba(nomeAba)
    If ws Is Nothing Then Exit Function

    Set shp = UX_IS_ObterShape(ws)
    If shp Is Nothing Then Exit Function

    UX_IniciarSistema_OnActionAtual = shp.OnAction
    Exit Function

falha:
    UX_IniciarSistema_OnActionAtual = ""
End Function

Public Sub UX_InstalarAtalhoIniciarSistema()
    Dim res As TResult

    res = UX_IniciarSistema_Instalar()
    If res.sucesso Then
        MsgBox res.mensagem & vbCrLf & vbCrLf & _
               "Clique no botao visual para executar IniciarSistema.", _
               vbInformation, "Iniciar Sistema"
    Else
        MsgBox res.mensagem, vbExclamation, "Iniciar Sistema"
    End If
End Sub

Public Sub UX_RemoverAtalhoIniciarSistema()
    Dim res As TResult

    res = UX_IniciarSistema_Remover()
    If res.sucesso Then
        MsgBox res.mensagem, vbInformation, "Iniciar Sistema"
    Else
        MsgBox res.mensagem, vbExclamation, "Iniciar Sistema"
    End If
End Sub

Private Function UX_IS_AbaPorNome(ByVal nomeAba As String) As Worksheet
    On Error Resume Next
    Set UX_IS_AbaPorNome = ThisWorkbook.Worksheets(nomeAba)
    On Error GoTo 0
End Function

Private Function UX_IS_ObterShape(ByVal ws As Worksheet) As Shape
    On Error Resume Next
    Set UX_IS_ObterShape = ws.Shapes(UX_IS_SHAPE_NAME)
    On Error GoTo 0
End Function

Private Sub UX_IS_ConfigurarShape(ByVal ws As Worksheet, ByVal shp As Shape)
    If shp.Name <> UX_IS_SHAPE_NAME Then shp.Name = UX_IS_SHAPE_NAME

    shp.OnAction = UX_IS_ONACTION
    shp.Locked = False
    shp.Placement = xlFreeFloating
    shp.Left = ws.Range(UX_IS_ANCHOR).Left + 4
    shp.Top = ws.Range(UX_IS_ANCHOR).Top + 4
    shp.Width = UX_IS_WIDTH
    shp.Height = UX_IS_HEIGHT
    shp.AlternativeText = "Atalho visual para executar IniciarSistema"

    With shp.Fill
        .Visible = msoTrue
        .ForeColor.RGB = RGB(0, 112, 74)
        .Transparency = 0
    End With

    With shp.Line
        .Visible = msoTrue
        .ForeColor.RGB = RGB(0, 82, 54)
        .Weight = 1
    End With

    With shp.TextFrame2
        .VerticalAnchor = msoAnchorMiddle
        .MarginLeft = 8
        .MarginRight = 8
        .MarginTop = 2
        .MarginBottom = 2
        .TextRange.Text = "Iniciar Sistema"
        .TextRange.ParagraphFormat.Alignment = msoAlignCenter
        .TextRange.Font.Size = 10
        .TextRange.Font.Bold = msoTrue
        .TextRange.Font.Fill.ForeColor.RGB = RGB(255, 255, 255)
    End With
End Sub

Private Function UX_IS_AbaCritica(ByVal nomeAba As String) As Boolean
    Dim nomeNormalizado As String

    nomeNormalizado = UCase$(Trim$(nomeAba))
    Select Case nomeNormalizado
        Case "EMPRESAS", "EMPRESAS_INATIVAS", "ENTIDADE", "ENTIDADE_INATIVOS", _
             "ATIVIDADES", "CAD_SERV", "CREDENCIADOS", "PRE_OS", "CAD_OS", _
             "AUDIT_LOG"
            UX_IS_AbaCritica = True
    End Select
End Function


