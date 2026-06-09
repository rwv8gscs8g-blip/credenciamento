Attribute VB_Name = "Teste_V2_Punicoes_Dias"
Option Explicit

Private Const TV2_PD_SUITE As String = "PUNICOES_DIAS"

Public Sub TV2_RunPunicoesDias(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Dim inicializado As Boolean
    Dim okMigracao As Boolean
    Dim okValidacao As Boolean
    Dim okUi As Boolean
    Dim okManual As Boolean
    Dim okRecusa As Boolean
    Dim okAntiMeses As Boolean
    Dim okRelatorioCampos As Boolean
    Dim okRelatorioSemApta As Boolean
    Dim detalhesMigracao As String
    Dim detalhesValidacao As String
    Dim detalhesUi As String
    Dim detalhesManual As String
    Dim detalhesRecusa As String
    Dim detalhesAntiMeses As String
    Dim detalhesRelatorioCampos As String
    Dim detalhesRelatorioSemApta As String
    Dim auditMesesAntes As Long
    Dim auditMesesDepois As Long
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao TV2_PD_SUITE, visual, 8
    inicializado = True

    auditMesesAntes = TV2_PD_AuditMesesCount()

    okMigracao = TV2_PD_TestarMigracaoIdempotente(detalhesMigracao)
    TV2_LogAssert TV2_PD_SUITE, "PD_01_MIGRACAO_IDEMPOTENTE", "AUTO", _
                  "Migracao 0153 semeia dias e nao multiplica em execucao dupla", _
                  "Strike e recusa/prazo ficam em 30 dias apos duas execucoes", _
                  detalhesMigracao, _
                  "Fecha risco de converter meses repetidamente ou deixar DIAS_STRIKE=0", _
                  okMigracao

    okValidacao = TV2_PD_TestarValidacaoZero(detalhesValidacao)
    TV2_LogAssert TV2_PD_SUITE, "PD_02_ZERO_REJEITADO", "AUTO", _
                  "Validacao rejeita zero, vazio e decimal em dias de strike", _
                  "Config_ValidarRegraStrikes nao aceita duracao invalida", _
                  detalhesValidacao, _
                  "Remove a polissemia antiga em que 0 significava fallback em meses", _
                  okValidacao

    okUi = TV2_PD_TestarRoundTripUI(detalhesUi)
    TV2_LogAssert TV2_PD_SUITE, "PD_03_UI_RECUSA_DIAS", "AUTO", _
                  "Configuracao_Inicial grava recusa/prazo em dias na coluna nova", _
                  "DIAS_SUSPENSAO_RECUSA_PRAZO recebe 45 e COL_CFG_MESES_SUSPENSAO nao e reinterpretada", _
                  detalhesUi, _
                  "Garante que a interface visual DIAS corresponde a persistencia consumida pelo rodizio", _
                  okUi

    okManual = TV2_PD_TestarSuspensaoManual(detalhesManual)
    TV2_LogAssert TV2_PD_SUITE, "PD_04_MANUAL_EXPLICITA", "AUTO", _
                  "Suspensao manual exige dias e origem explicitos", _
                  "DT_FIM_SUSP = Date + 7 e auditoria registra ORIGEM=MANUAL", _
                  detalhesManual, _
                  "Fecha a terceira origem de suspensao apontada na auditoria adversarial", _
                  okManual

    okRecusa = TV2_PD_TestarRecusaDias(detalhesRecusa)
    TV2_LogAssert TV2_PD_SUITE, "PD_05_RECUSA_DIAS_EXATA", "AUTO", _
                  "Suspensao por recusa/prazo usa dias explicitos", _
                  "Na segunda recusa, DT_FIM_SUSP = Date + 11 e ORIGEM=RECUSA", _
                  detalhesRecusa, _
                  "Prova que o caminho de recusa nao depende mais de BASE=MESES", _
                  okRecusa

    auditMesesDepois = TV2_PD_AuditMesesCount()
    okAntiMeses = (auditMesesDepois = auditMesesAntes)
    detalhesAntiMeses = "ANTES=" & CStr(auditMesesAntes) & "; DEPOIS=" & CStr(auditMesesDepois)
    TV2_LogAssert TV2_PD_SUITE, "PD_06_AUDIT_SEM_MESES", "AUTO", _
                  "Suspensoes da suite nao geram marcadores de meses", _
                  "Nenhum novo BASE=MESES, MESES= ou FALLBACK_MESES em EVT_SUSPENSAO", _
                  detalhesAntiMeses, _
                  "Endurece o canario RVS contra o caminho de recusa que antes nao usava FALLBACK_MESES", _
                  okAntiMeses

    okRelatorioCampos = TV2_PD_TestarRelatorioCampos(detalhesRelatorioCampos)
    TV2_LogAssert TV2_PD_SUITE, "PD_07_RELATORIO_CAMPOS", "AUTO", _
                  "Relatorio de status do rodizio expoe campos de suspensao", _
                  "RPT_RODIZIO_STATUS tem QTD_APTAS, QTD_SUSPENSAS, PROXIMO_RETORNO e ALERTA", _
                  detalhesRelatorioCampos, _
                  "Aprovacao humana precisa enxergar aptas, suspensas e retorno previsto", _
                  okRelatorioCampos

    okRelatorioSemApta = TV2_PD_TestarRelatorioSemApta(detalhesRelatorioSemApta)
    TV2_LogAssert TV2_PD_SUITE, "PD_08_RELATORIO_SEM_APTA", "AUTO", _
                  "Relatorio identifica item sem empresa apta", _
                  "Com todas as empresas suspensas, ALERTA=SEM_EMPRESA_APTA e QTD_APTAS=0", _
                  detalhesRelatorioSemApta, _
                  "Evita aprovar visualmente um item coberto apenas por empresas indisponiveis", _
                  okRelatorioSemApta

    TV2_FinalizarExecucao TV2_PD_SUITE, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    If inicializado Then
        TV2_LogAssert TV2_PD_SUITE, "FATAL", "AUTO", _
                      "Executar suite PunicoesDias sem erro fatal", _
                      "Nenhum erro fatal", _
                      "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                      "Falha fatal precisa ficar rastreavel no historico V2", False
        TV2_FinalizarExecucao TV2_PD_SUITE, silencioso
    ElseIf Not silencioso Then
        MsgBox "Erro fatal antes de iniciar TV2 PunicoesDias: " & erroFatalDescricao, vbCritical, "Testes V2"
    End If
End Sub

Private Function TV2_PD_TestarMigracaoIdempotente(ByRef detalhes As String) As Boolean
    Dim ws As Worksheet
    Dim ok1 As Boolean
    Dim ok2 As Boolean
    Dim det1 As String
    Dim det2 As String
    Dim strike1 As Long
    Dim recusa1 As Long
    Dim strike2 As Long
    Dim recusa2 As Long

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)
    TV2_PD_SetConfigRaw 1, 0, ""
    ok1 = Config_MigrarPunicoesDias0153(det1)
    strike1 = CLng(Val(ws.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_STRIKE).Value))
    recusa1 = CLng(Val(ws.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value))
    ok2 = Config_MigrarPunicoesDias0153(det2)
    strike2 = CLng(Val(ws.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_STRIKE).Value))
    recusa2 = CLng(Val(ws.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value))

    detalhes = "OK1=" & CStr(ok1) & "; DET1=" & det1 & _
               "; OK2=" & CStr(ok2) & "; DET2=" & det2 & _
               "; STRIKE1=" & CStr(strike1) & "; RECUSA1=" & CStr(recusa1) & _
               "; STRIKE2=" & CStr(strike2) & "; RECUSA2=" & CStr(recusa2)
    TV2_PD_TestarMigracaoIdempotente = ok1 And ok2 And strike1 = 30 And recusa1 = 30 And strike2 = 30 And recusa2 = 30
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
End Function

Private Function TV2_PD_TestarValidacaoZero(ByRef detalhes As String) As Boolean
    Dim msgZero As String
    Dim msgVazio As String
    Dim msgDecimal As String
    Dim okZero As Boolean
    Dim okVazio As Boolean
    Dim okDecimal As Boolean

    okZero = Not Config_ValidarRegraStrikes("5", "1", "0", msgZero)
    okVazio = Not Config_ValidarRegraStrikes("5", "1", "", msgVazio)
    okDecimal = Not Config_ValidarRegraStrikes("5", "1", "1,5", msgDecimal)

    detalhes = "ZERO=" & CStr(okZero) & ":" & msgZero & _
               "; VAZIO=" & CStr(okVazio) & ":" & msgVazio & _
               "; DECIMAL=" & CStr(okDecimal) & ":" & msgDecimal
    TV2_PD_TestarValidacaoZero = okZero And okVazio And okDecimal
End Function

Private Function TV2_PD_TestarRoundTripUI(ByRef detalhes As String) As Boolean
    Dim frm As Configuracao_Inicial
    Dim ws As Worksheet
    Dim ok As Boolean
    Dim det As String
    Dim diasRecusa As Long

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)
    Set frm = New Configuracao_Inicial
    ok = frm.CI_TestarPersistenciaPainel("5", "1", "30", det, "3", "45", "5")
    diasRecusa = CLng(Val(ws.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value))
    detalhes = "OK=" & CStr(ok) & "; DET=" & det & "; DIAS_RECUSA=" & CStr(diasRecusa)
    TV2_PD_TestarRoundTripUI = ok And diasRecusa = 45
    Unload frm
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
    On Error Resume Next
    If Not frm Is Nothing Then Unload frm
    On Error GoTo 0
End Function

Private Function TV2_PD_TestarSuspensaoManual(ByRef detalhes As String) As Boolean
    Dim res As TResult
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim auditAntes As Long
    Dim auditDepois As Long

    On Error GoTo falha

    TV2_PrepararCenarioTriploCanonico
    TV2_PD_SetConfigPunicoes 3, 30, 1, 30
    auditAntes = TV2_AuditCount("Empresa Suspensa", "ORIGEM=MANUAL")
    res = Suspender("001", 7, "MANUAL", "PD_04_MANUAL", Config_SnapshotPunicoesDias())
    emp = LerEmpresa("001", linhaEmp)
    auditDepois = TV2_AuditCount("Empresa Suspensa", "ORIGEM=MANUAL")

    detalhes = "SUCESSO=" & CStr(res.sucesso) & "; MSG=" & res.mensagem & _
               "; STATUS=" & emp.STATUS_GLOBAL & "; DT_FIM=" & Format$(emp.DT_FIM_SUSP, "yyyy-mm-dd") & _
               "; AUDIT_DELTA=" & CStr(auditDepois - auditAntes)
    TV2_PD_TestarSuspensaoManual = res.sucesso And linhaEmp > 0 And emp.STATUS_GLOBAL = "SUSPENSA_GLOBAL" And _
        emp.DT_FIM_SUSP = DateAdd("d", 7, Date) And (auditDepois - auditAntes) = 1
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
End Function

Private Function TV2_PD_TestarRecusaDias(ByRef detalhes As String) As Boolean
    Dim res1 As TResult
    Dim res2 As TResult
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim auditAntes As Long
    Dim auditDepois As Long

    On Error GoTo falha

    TV2_PrepararCenarioTriploCanonico
    TV2_PD_SetConfigPunicoes 2, 11, 1, 30
    auditAntes = TV2_AuditCount("Empresa Suspensa", "ORIGEM=RECUSA")
    res1 = AvancarFila("001", TV2_AtivCanonA(), True, "PD_05_RECUSA_1")
    res2 = AvancarFila("001", TV2_AtivCanonA(), True, "PD_05_RECUSA_2")
    emp = LerEmpresa("001", linhaEmp)
    auditDepois = TV2_AuditCount("Empresa Suspensa", "ORIGEM=RECUSA")

    detalhes = "R1=" & CStr(res1.sucesso) & ":" & res1.mensagem & _
               "; R2=" & CStr(res2.sucesso) & ":" & res2.mensagem & _
               "; STATUS=" & emp.STATUS_GLOBAL & "; RECUSAS=" & CStr(emp.QTD_RECUSAS) & _
               "; DT_FIM=" & Format$(emp.DT_FIM_SUSP, "yyyy-mm-dd") & _
               "; AUDIT_DELTA=" & CStr(auditDepois - auditAntes)
    TV2_PD_TestarRecusaDias = res1.sucesso And res2.sucesso And linhaEmp > 0 And _
        emp.STATUS_GLOBAL = "SUSPENSA_GLOBAL" And emp.DT_FIM_SUSP = DateAdd("d", 11, Date) And _
        (auditDepois - auditAntes) = 1
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
End Function

Private Function TV2_PD_TestarRelatorioCampos(ByRef detalhes As String) As Boolean
    Dim res As TResult
    Dim ws As Worksheet
    Dim okHeaders As Boolean

    On Error GoTo falha

    TV2_PrepararCenarioTriploCanonico
    TV2_PD_SetConfigPunicoes 3, 30, 1, 30
    res = Suspender("001", 9, "MANUAL", "PD_07_RELATORIO", Config_SnapshotPunicoesDias())
    res = RRS_GerarRelatorioStatusPorServico(False)
    Set ws = ThisWorkbook.Sheets("RPT_RODIZIO_STATUS")

    okHeaders = (TV2_PD_HeaderCol(ws, "QTD_APTAS") > 0) And _
                (TV2_PD_HeaderCol(ws, "QTD_SUSPENSAS") > 0) And _
                (TV2_PD_HeaderCol(ws, "PROXIMO_RETORNO") > 0) And _
                (TV2_PD_HeaderCol(ws, "ALERTA") > 0)
    detalhes = "REL_SUCESSO=" & CStr(res.sucesso) & "; MSG=" & res.mensagem & _
               "; HEADERS_OK=" & CStr(okHeaders)
    TV2_PD_TestarRelatorioCampos = res.sucesso And okHeaders
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
End Function

Private Function TV2_PD_TestarRelatorioSemApta(ByRef detalhes As String) As Boolean
    Dim res As TResult
    Dim ws As Worksheet
    Dim rowItem As Long
    Dim colAptas As Long
    Dim colSusp As Long
    Dim colAlerta As Long

    On Error GoTo falha

    TV2_PrepararCenarioTriploCanonico
    TV2_PD_SuspenderTodasEmpresas DateAdd("d", 5, Date)
    res = RRS_GerarRelatorioStatusPorServico(False)
    Set ws = ThisWorkbook.Sheets("RPT_RODIZIO_STATUS")
    rowItem = TV2_PD_RowServico(ws, TV2_AtivCanonA(), "001")
    colAptas = TV2_PD_HeaderCol(ws, "QTD_APTAS")
    colSusp = TV2_PD_HeaderCol(ws, "QTD_SUSPENSAS")
    colAlerta = TV2_PD_HeaderCol(ws, "ALERTA")

    detalhes = "REL_SUCESSO=" & CStr(res.sucesso) & "; ROW=" & CStr(rowItem) & _
               "; APTAS=" & TV2_PD_CellText(ws, rowItem, colAptas) & _
               "; SUSP=" & TV2_PD_CellText(ws, rowItem, colSusp) & _
               "; ALERTA=" & TV2_PD_CellText(ws, rowItem, colAlerta)
    TV2_PD_TestarRelatorioSemApta = res.sucesso And rowItem > 0 And _
        CLng(Val(ws.Cells(rowItem, colAptas).Value)) = 0 And _
        CLng(Val(ws.Cells(rowItem, colSusp).Value)) >= 3 And _
        UCase$(Trim$(CStr(ws.Cells(rowItem, colAlerta).Value))) = "SEM_EMPRESA_APTA"
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
End Function

Private Sub TV2_PD_SetConfigRaw(ByVal mesesLegado As Long, ByVal diasStrike As Variant, ByVal diasRecusa As Variant)
    Dim ws As Worksheet
    Dim est As Boolean
    Dim sen As String

    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)
    If Util_PrepararAbaParaEscrita(ws, est, sen) Then
        ws.Cells(LINHA_CFG_VALORES, COL_CFG_MESES_SUSPENSAO).Value = mesesLegado
        ws.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_STRIKE).Value = diasStrike
        ws.Cells(1, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value = "DIAS_SUSPENSAO_RECUSA_PRAZO"
        ws.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value = diasRecusa
        Util_RestaurarProtecaoAba ws, est, sen
    End If
End Sub

Private Sub TV2_PD_SetConfigPunicoes(ByVal maxRecusas As Long, ByVal diasRecusa As Long, ByVal maxStrikes As Long, ByVal diasStrike As Long)
    Dim ws As Worksheet
    Dim est As Boolean
    Dim sen As String

    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)
    If Util_PrepararAbaParaEscrita(ws, est, sen) Then
        ws.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value = maxRecusas
        ws.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_STRIKES).Value = maxStrikes
        ws.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_STRIKE).Value = diasStrike
        ws.Cells(1, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value = "DIAS_SUSPENSAO_RECUSA_PRAZO"
        ws.Cells(LINHA_CFG_VALORES, COL_CFG_DIAS_SUSPENSAO_RECUSA_PRAZO).Value = diasRecusa
        Util_RestaurarProtecaoAba ws, est, sen
    End If
End Sub

Private Function TV2_PD_AuditMesesCount() As Long
    TV2_PD_AuditMesesCount = TV2_AuditCount("Empresa Suspensa", "BASE=MESES") + _
                             TV2_AuditCount("Empresa Suspensa", "MESES=") + _
                             TV2_AuditCount("Empresa Suspensa", "FALLBACK_MESES")
End Function

Private Function TV2_PD_HeaderCol(ByVal ws As Worksheet, ByVal header As String) As Long
    Dim c As Long
    For c = 1 To ws.Cells(1, ws.Columns.count).End(xlToLeft).Column
        If UCase$(Trim$(CStr(ws.Cells(1, c).Value))) = UCase$(Trim$(header)) Then
            TV2_PD_HeaderCol = c
            Exit Function
        End If
    Next c
End Function

Private Function TV2_PD_RowServico(ByVal ws As Worksheet, ByVal ativId As String, ByVal servId As String) As Long
    Dim r As Long
    For r = 2 To ws.Cells(ws.Rows.count, 1).End(xlUp).row
        If Format$(CLng(Val(ws.Cells(r, 1).Value)), "000") = Format$(CLng(Val(ativId)), "000") And _
           Format$(CLng(Val(ws.Cells(r, 2).Value)), "000") = Format$(CLng(Val(servId)), "000") Then
            TV2_PD_RowServico = r
            Exit Function
        End If
    Next r
End Function

Private Function TV2_PD_CellText(ByVal ws As Worksheet, ByVal rowNum As Long, ByVal colNum As Long) As String
    If rowNum <= 0 Or colNum <= 0 Then
        TV2_PD_CellText = ""
    Else
        TV2_PD_CellText = Trim$(CStr(ws.Cells(rowNum, colNum).Value))
    End If
End Function

Private Sub TV2_PD_SuspenderTodasEmpresas(ByVal dtFim As Date)
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim ids As Variant
    Dim i As Long
    Dim ignorado As TResult

    ids = Array("001", "002", "003")
    For i = LBound(ids) To UBound(ids)
        emp = LerEmpresa(CStr(ids(i)), linhaEmp)
        If linhaEmp > 0 Then
            ignorado = GravarStatusEmpresa(linhaEmp, "SUSPENSA_GLOBAL", dtFim, emp.QTD_RECUSAS)
        End If
    Next i
End Sub


