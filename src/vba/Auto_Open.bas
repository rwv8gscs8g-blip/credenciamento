Attribute VB_Name = "Auto_Open"
Option Explicit

' =============================================================================
' Auto_Open.bas - Inicialização do sistema ao abrir o workbook
' Este módulo é chamado automaticamente pelo Excel ao abrir o arquivo.
' =============================================================================

Private mUltimaProtecaoOk As Boolean
Private mUltimaProtecaoDetalhes As String
Private mUltimaProtecaoExecutadaEm As Date
Private Const BL4_MARKER_TS As String = "_HBN_BL4_AUTOOPEN_TS"
Private Const BL4_MARKER_OK As String = "_HBN_BL4_AUTOOPEN_OK"
Private Const BL4_MARKER_DETALHES As String = "_HBN_BL4_AUTOOPEN_DETALHES"

Private Sub InicializarSistema()
    Dim frm As Object
    Dim qtdCnae As Long

    Call AutoOpen_ReaplicarProtecaoCritica

    On Error Resume Next
    qtdCnae = CargaInicialCNAE_SeNecessario(False)
    On Error GoTo 0
    AutoOpen_VerificarBackfillDtUltReativ

    ' Mostrar o menu principal
    For Each frm In VBA.UserForms
        If typeName(frm) = "Menu_Principal" Then
            If Not frm.Visible Then frm.Show
            Exit Sub
        End If
    Next frm

    Set frm = VBA.UserForms.Add("Menu_Principal")
    frm.Show
End Sub

Private Function AutoOpen_ReaplicarProtecaoCritica() As Boolean
    Dim detalhes As String

    On Error GoTo falha

    mUltimaProtecaoExecutadaEm = Now
    mUltimaProtecaoDetalhes = ""
    mUltimaProtecaoOk = Util_ProtegerAbasCriticasVerificado(detalhes)
    If detalhes <> "" Then
        mUltimaProtecaoDetalhes = detalhes
    ElseIf mUltimaProtecaoOk Then
        mUltimaProtecaoDetalhes = "OK"
    Else
        mUltimaProtecaoDetalhes = "PROTECAO_FALSE_SEM_DETALHE"
    End If

    Call AutoOpen_GravarMarcadorProtecao(mUltimaProtecaoOk, mUltimaProtecaoDetalhes, mUltimaProtecaoExecutadaEm)

    AutoOpen_ReaplicarProtecaoCritica = mUltimaProtecaoOk
    Exit Function

falha:
    If mUltimaProtecaoExecutadaEm = 0 Then mUltimaProtecaoExecutadaEm = Now
    mUltimaProtecaoOk = False
    mUltimaProtecaoDetalhes = "ERRO_" & CStr(Err.Number) & ":" & Err.Description
    On Error Resume Next
    Call AutoOpen_GravarMarcadorProtecao(False, mUltimaProtecaoDetalhes, mUltimaProtecaoExecutadaEm)
    On Error GoTo 0
    AutoOpen_ReaplicarProtecaoCritica = False
End Function

Private Sub AutoOpen_VerificarBackfillDtUltReativ()
    Dim res As TResult
    Dim qtdPendentes As Long
    Dim detalhes As String

    On Error GoTo fim
    res = RepoEmpresa_DtUltReativBackfillResumo(qtdPendentes, detalhes)
    If res.sucesso And qtdPendentes > 0 Then
        Application.StatusBar = "Credenciamento: " & CStr(qtdPendentes) & _
            " empresa(s) com DT_ULT_REATIV pendente de backfill assistido."
    End If

fim:
End Sub

Public Sub Auto_Open()
    InicializarSistema
End Sub

Public Sub IniciarSistema()
    InicializarSistema
End Sub

Public Sub AbrirMenu()
    ' Atalho manual para abrir o menu (pode ser atribuído a um botão)
    InicializarSistema
End Sub

Public Function AutoOpen_UltimaProtecaoOk() As Boolean
    If mUltimaProtecaoExecutadaEm > 0 Then
        AutoOpen_UltimaProtecaoOk = mUltimaProtecaoOk
    Else
        AutoOpen_UltimaProtecaoOk = AutoOpen_UltimaProtecaoMarcadorOk()
    End If
End Function

Public Function AutoOpen_UltimaProtecaoDetalhes() As String
    If mUltimaProtecaoDetalhes <> "" Then
        AutoOpen_UltimaProtecaoDetalhes = mUltimaProtecaoDetalhes
    Else
        AutoOpen_UltimaProtecaoDetalhes = AutoOpen_UltimaProtecaoMarcadorDetalhes()
    End If
End Function

Public Function AutoOpen_UltimaProtecaoExecutadaEm() As Date
    If mUltimaProtecaoExecutadaEm > 0 Then
        AutoOpen_UltimaProtecaoExecutadaEm = mUltimaProtecaoExecutadaEm
    Else
        AutoOpen_UltimaProtecaoExecutadaEm = AutoOpen_UltimaProtecaoMarcadorExecutadaEm()
    End If
End Function

Public Function AutoOpen_UltimaProtecaoMarcadorOk() As Boolean
    AutoOpen_UltimaProtecaoMarcadorOk = (UCase$(AutoOpen_LerNomeTexto(BL4_MARKER_OK)) = "TRUE")
End Function

Public Function AutoOpen_UltimaProtecaoMarcadorDetalhes() As String
    AutoOpen_UltimaProtecaoMarcadorDetalhes = AutoOpen_LerNomeTexto(BL4_MARKER_DETALHES)
End Function

Public Function AutoOpen_UltimaProtecaoMarcadorExecutadaEm() As Date
    AutoOpen_UltimaProtecaoMarcadorExecutadaEm = AutoOpen_ParseDataMarcador(AutoOpen_LerNomeTexto(BL4_MARKER_TS))
End Function

Public Function AutoOpen_UltimaProtecaoMarcadorAposUltimoSave(ByRef detalhes As String) As Boolean
    Dim dtMarcador As Date
    Dim dtUltimoSave As Date
    Dim okMarcador As Boolean
    Dim detalhesMarcador As String

    dtMarcador = AutoOpen_UltimaProtecaoMarcadorExecutadaEm()
    okMarcador = AutoOpen_UltimaProtecaoMarcadorOk()
    detalhesMarcador = AutoOpen_UltimaProtecaoMarcadorDetalhes()

    detalhes = "MARCADOR_TS=" & IIf(dtMarcador > 0, Format$(dtMarcador, "yyyy-mm-dd hh:nn:ss"), "nao registrado") & _
               "; MARCADOR_OK=" & CStr(okMarcador) & _
               "; MARCADOR_DETALHES=" & detalhesMarcador

    If dtMarcador <= 0 Or Not okMarcador Then
        AutoOpen_UltimaProtecaoMarcadorAposUltimoSave = False
        Exit Function
    End If

    dtUltimoSave = AutoOpen_UltimoSaveTime()
    If dtUltimoSave > 0 Then
        detalhes = detalhes & "; LAST_SAVE=" & Format$(dtUltimoSave, "yyyy-mm-dd hh:nn:ss")
        If DateDiff("s", dtMarcador, dtUltimoSave) > 2 Then
            detalhes = detalhes & "; MARCADOR_ANTERIOR_AO_LAST_SAVE"
            AutoOpen_UltimaProtecaoMarcadorAposUltimoSave = False
            Exit Function
        End If
    Else
        detalhes = detalhes & "; LAST_SAVE=indisponivel"
    End If

    AutoOpen_UltimaProtecaoMarcadorAposUltimoSave = True
End Function

Private Sub AutoOpen_GravarMarcadorProtecao(ByVal ok As Boolean, ByVal detalhes As String, ByVal executadaEm As Date)
    Call AutoOpen_SetNomeTexto(BL4_MARKER_TS, Format$(executadaEm, "yyyy-mm-dd hh:nn:ss"))
    Call AutoOpen_SetNomeTexto(BL4_MARKER_OK, IIf(ok, "TRUE", "FALSE"))
    Call AutoOpen_SetNomeTexto(BL4_MARKER_DETALHES, AutoOpen_NormalizarMarcadorTexto(detalhes))
End Sub

Private Sub AutoOpen_SetNomeTexto(ByVal nome As String, ByVal valor As String)
    Dim formula As String

    formula = "=""" & Replace$(AutoOpen_NormalizarMarcadorTexto(valor), """", """""") & """"

    On Error Resume Next
    Err.Clear
    ThisWorkbook.Names(nome).RefersTo = formula
    If Err.Number <> 0 Then
        Err.Clear
        ThisWorkbook.Names.Add Name:=nome, RefersTo:=formula
    End If
    ThisWorkbook.Names(nome).Visible = False
    Err.Clear
    On Error GoTo 0
End Sub

Private Function AutoOpen_LerNomeTexto(ByVal nome As String) As String
    Dim valor As Variant

    On Error GoTo falha
    valor = Application.Evaluate(ThisWorkbook.Names(nome).RefersTo)
    If IsError(valor) Then
        AutoOpen_LerNomeTexto = ""
    Else
        AutoOpen_LerNomeTexto = CStr(valor)
    End If
    Exit Function

falha:
    AutoOpen_LerNomeTexto = ""
End Function

Private Function AutoOpen_ParseDataMarcador(ByVal valor As String) As Date
    On Error GoTo falha
    If Len(valor) < 19 Then Exit Function
    AutoOpen_ParseDataMarcador = DateSerial(CInt(Left$(valor, 4)), CInt(Mid$(valor, 6, 2)), CInt(Mid$(valor, 9, 2))) + _
                                  TimeSerial(CInt(Mid$(valor, 12, 2)), CInt(Mid$(valor, 15, 2)), CInt(Mid$(valor, 18, 2)))
    Exit Function

falha:
    AutoOpen_ParseDataMarcador = 0
End Function

Private Function AutoOpen_UltimoSaveTime() As Date
    Dim valor As Variant

    On Error GoTo falha
    valor = ThisWorkbook.BuiltinDocumentProperties("Last Save Time").Value
    If IsDate(valor) Then AutoOpen_UltimoSaveTime = CDate(valor)
    Exit Function

falha:
    AutoOpen_UltimoSaveTime = 0
End Function

Private Function AutoOpen_NormalizarMarcadorTexto(ByVal valor As String) As String
    Dim texto As String

    texto = Replace$(Replace$(CStr(valor), vbCr, " "), vbLf, " ")
    If Len(texto) > 900 Then texto = Left$(texto, 900) & "...(truncado)"
    AutoOpen_NormalizarMarcadorTexto = texto
End Function


