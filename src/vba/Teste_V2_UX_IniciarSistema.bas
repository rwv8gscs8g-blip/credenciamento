Attribute VB_Name = "Teste_V2_UX_IniciarSistema"
Option Explicit

Private Const TV2_UXIS_SUITE As String = "UX_INICIAR_SISTEMA"
Private Const TV2_UXIS_ABA As String = "RESULTADO_QA_V2"
Private Const TV2_UXIS_SENTINELA_1 As String = "Z1"
Private Const TV2_UXIS_SENTINELA_2 As String = "Z2"

Public Sub TV2_RunUXIniciarSistemaCodeOnly(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Dim inicializado As Boolean
    Dim ws As Worksheet
    Dim nomeAba As String
    Dim haviaAntes As Boolean
    Dim countAntes As Long
    Dim countInstalado As Long
    Dim countReinstalado As Long
    Dim countFinal As Long
    Dim sent1Antes As String
    Dim sent2Antes As String
    Dim sent1Depois As String
    Dim sent2Depois As String
    Dim acaoAtual As String
    Dim resInstalar As TResult
    Dim resReinstalar As TResult
    Dim resFinal As TResult
    Dim resIgnorado As TResult
    Dim detalheInstalar As String
    Dim detalheOnAction As String
    Dim detalheIdempotencia As String
    Dim detalheSentinelas As String
    Dim detalheCleanup As String
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao TV2_UXIS_SUITE, visual, 5
    inicializado = True

    Set ws = UX_IniciarSistema_ResolverAba(TV2_UXIS_ABA)
    If ws Is Nothing Then Set ws = UX_IniciarSistema_ResolverAba()

    If Not ws Is Nothing Then
        nomeAba = ws.Name
        countAntes = UX_IniciarSistema_ContarAtalhos(nomeAba)
        haviaAntes = (countAntes > 0)
        sent1Antes = TV2_UXIS_FormulaSegura(ws, TV2_UXIS_SENTINELA_1)
        sent2Antes = TV2_UXIS_FormulaSegura(ws, TV2_UXIS_SENTINELA_2)

        resInstalar = UX_IniciarSistema_Instalar(nomeAba)
        countInstalado = UX_IniciarSistema_ContarAtalhos(nomeAba)
        acaoAtual = UX_IniciarSistema_OnActionAtual(nomeAba)

        resReinstalar = UX_IniciarSistema_Instalar(nomeAba)
        countReinstalado = UX_IniciarSistema_ContarAtalhos(nomeAba)

        sent1Depois = TV2_UXIS_FormulaSegura(ws, TV2_UXIS_SENTINELA_1)
        sent2Depois = TV2_UXIS_FormulaSegura(ws, TV2_UXIS_SENTINELA_2)
    End If

    detalheInstalar = "ABA=" & nomeAba & _
                      "; SUCESSO=" & CStr(resInstalar.sucesso) & _
                      "; MSG=" & resInstalar.mensagem & _
                      "; QTD_ANTES=" & CStr(countAntes) & _
                      "; QTD_DEPOIS=" & CStr(countInstalado)
    TV2_LogAssert TV2_UXIS_SUITE, "UXIS_01_INSTALA_ATALHO_VISUAL", "AUTO", _
                  "Instalar atalho visual IniciarSistema em aba operacional", _
                  "Shape unico " & UX_IniciarSistema_NomeShape() & " criado/atualizado", _
                  detalheInstalar, _
                  "Garante acesso visual sem Auto_Open, ThisWorkbook ou UserForm", _
                  (Not ws Is Nothing And resInstalar.sucesso And countInstalado = 1)

    detalheOnAction = "ABA=" & nomeAba & _
                      "; ONACTION=" & acaoAtual & _
                      "; ESPERADO=" & UX_IniciarSistema_OnActionEsperado()
    TV2_LogAssert TV2_UXIS_SUITE, "UXIS_02_ONACTION_INICIARSISTEMA", "AUTO", _
                  "Validar macro acionada pelo shape", _
                  "OnAction aponta para IniciarSistema", _
                  detalheOnAction, _
                  "O clique visual executa o mesmo ponto de entrada operacional ja existente", _
                  (acaoAtual = UX_IniciarSistema_OnActionEsperado())

    detalheIdempotencia = "ABA=" & nomeAba & _
                          "; SUCESSO_REEXEC=" & CStr(resReinstalar.sucesso) & _
                          "; MSG_REEXEC=" & resReinstalar.mensagem & _
                          "; QTD_APOS_REEXEC=" & CStr(countReinstalado)
    TV2_LogAssert TV2_UXIS_SUITE, "UXIS_03_IDEMPOTENTE_SEM_DUPLICAR", "AUTO", _
                  "Reexecutar instalador do atalho visual", _
                  "Aba permanece com apenas um shape UX_BTN_INICIAR_SISTEMA", _
                  detalheIdempotencia, _
                  "Permite atualizar o atalho em novas importacoes sem acumular botoes", _
                  (resReinstalar.sucesso And countReinstalado = 1)

    detalheSentinelas = TV2_UXIS_SENTINELA_1 & "_ANTES=" & sent1Antes & _
                        "; " & TV2_UXIS_SENTINELA_1 & "_DEPOIS=" & sent1Depois & _
                        "; " & TV2_UXIS_SENTINELA_2 & "_ANTES=" & sent2Antes & _
                        "; " & TV2_UXIS_SENTINELA_2 & "_DEPOIS=" & sent2Depois
    TV2_LogAssert TV2_UXIS_SUITE, "UXIS_04_NAO_ALTERA_CELULAS_SENTINELA", "AUTO", _
                  "Instalacao do atalho nao altera celulas de dados", _
                  "Sentinelas Z1/Z2 preservadas", _
                  detalheSentinelas, _
                  "O delta atua como shape flutuante e nao como schema ou dado de negocio", _
                  (sent1Antes = sent1Depois And sent2Antes = sent2Depois)

    If nomeAba <> "" Then
        If haviaAntes Then
            resFinal = UX_IniciarSistema_Instalar(nomeAba)
        Else
            resFinal = UX_IniciarSistema_Remover(nomeAba)
        End If
        countFinal = UX_IniciarSistema_ContarAtalhos(nomeAba)
    End If

    detalheCleanup = "ABA=" & nomeAba & _
                     "; HAVIA_ANTES=" & CStr(haviaAntes) & _
                     "; SUCESSO_FINAL=" & CStr(resFinal.sucesso) & _
                     "; MSG_FINAL=" & resFinal.mensagem & _
                     "; QTD_FINAL=" & CStr(countFinal)
    TV2_LogAssert TV2_UXIS_SUITE, "UXIS_05_LIMPEZA_RESTAURA_ESTADO", "AUTO", _
                  "Remover ou restaurar o atalho apos teste dirigido", _
                  "Estado final preserva existencia anterior do atalho", _
                  detalheCleanup, _
                  "Evita deixar artefato visual de teste quando o usuario ainda nao instalou o botao", _
                  (resFinal.sucesso And countFinal = IIf(haviaAntes, 1, 0))

    TV2_FinalizarExecucao TV2_UXIS_SUITE, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    On Error Resume Next
    If nomeAba <> "" Then
        If haviaAntes Then
            resIgnorado = UX_IniciarSistema_Instalar(nomeAba)
        Else
            resIgnorado = UX_IniciarSistema_Remover(nomeAba)
        End If
    End If
    On Error GoTo 0

    If inicializado Then
        TV2_LogAssert TV2_UXIS_SUITE, "FATAL", "AUTO", _
                      "Executar suite UX IniciarSistema sem erro fatal", _
                      "Nenhum erro fatal", _
                      "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                      "Falha fatal precisa ficar rastreavel sem tocar Auto_Open/UserForms", False
        TV2_FinalizarExecucao TV2_UXIS_SUITE, silencioso
    ElseIf Not silencioso Then
        MsgBox "Erro fatal antes de iniciar TV2 UX IniciarSistema: " & erroFatalDescricao, vbCritical, "Testes V2"
    End If
End Sub

Private Function TV2_UXIS_FormulaSegura(ByVal ws As Worksheet, ByVal endereco As String) As String
    On Error GoTo falha
    TV2_UXIS_FormulaSegura = CStr(ws.Range(endereco).Formula)
    Exit Function

falha:
    TV2_UXIS_FormulaSegura = "ERRO_" & CStr(Err.Number) & ":" & Err.Description
End Function


