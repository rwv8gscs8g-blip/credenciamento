Attribute VB_Name = "Teste_V2_Formularios_Residuais"
Option Explicit

Private Const TV2_FR_SUITE As String = "FORMULARIOS_RESIDUAIS"
Private Const TV2_FR_ENT_1 As String = "001"
Private Const TV2_FR_ENT_2 As String = "002"
Private Const TV2_FR_NOME_1 As String = "Local 1"
Private Const TV2_FR_NOME_2 As String = "Local 2"

Public Sub TV2_RunFormulariosResiduaisCodeOnly(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Dim inicializado As Boolean
    Dim osId1 As String
    Dim osId2 As String
    Dim detalhesBase As String
    Dim detalhesLista As String
    Dim detalhesPayload As String
    Dim detalhesAvalDireta As String
    Dim detalhesInvalido As String
    Dim detalhesRestore As String
    Dim nomeLista1 As String
    Dim nomeLista2 As String
    Dim entId As String
    Dim nomeResolver As String
    Dim detalhesResolver As String
    Dim payloadOSID As String
    Dim payloadAvaliador As String
    Dim payloadQtExecutada As Double
    Dim payloadObservacao As String
    Dim payloadJustif As String
    Dim payloadMedia As Double
    Dim notas(1 To 10) As Integer
    Dim i As Long
    Dim auditAntes As Long
    Dim auditDepois As Long
    Dim okBase As Boolean
    Dim okLista As Boolean
    Dim okPayload As Boolean
    Dim okAvalDireta As Boolean
    Dim okInvalido As Boolean
    Dim okRestore As Boolean
    Dim resPayload As TResult
    Dim resAvalDireta As TResult
    Dim resInvalido As TResult
    Dim resResolver As TResult
    Dim frm As Menu_Principal
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao TV2_FR_SUITE, visual, 6
    inicializado = True

    okBase = TV2_FR_PrepararBaseDuasOS(osId1, osId2, detalhesBase)
    TV2_LogAssert TV2_FR_SUITE, "FR_01_PREPARA_DUAS_OS_DEMANDANTES", "AUTO", _
                  "Preparar duas OS em execucao com demandantes distintos", _
                  "OS1 usa Local 1 e OS2 usa Local 2", _
                  detalhesBase, _
                  "Cria base minima para pegar troca de demandante entre linhas do formulario", _
                  okBase

    If okBase Then
        Set frm = New Menu_Principal
        PreencherAvaliarOS
        okLista = TV2_FR_LerDemandanteLista(frm, osId1, nomeLista1, detalhesLista)
        okLista = okLista And TV2_FR_LerDemandanteLista(frm, osId2, nomeLista2, detalhesResolver)
        detalhesLista = detalhesLista & "; " & detalhesResolver
        okLista = (okLista And nomeLista1 = TV2_FR_NOME_1 And nomeLista2 = TV2_FR_NOME_2)
    Else
        detalhesLista = "Base nao preparada; lista nao verificada."
    End If
    TV2_LogAssert TV2_FR_SUITE, "FR_02_LISTA_PRESERVA_DEMANDANTE_POR_OS", "AUTO", _
                  "AV_Lista preserva demandante por OS_ID em mais de uma linha", _
                  "OS1=Local 1 e OS2=Local 2 depois do refresh", _
                  detalhesLista, _
                  "Evita usar Desc_entidade ou indice obsoleto quando ha varias OS em avaliacao", _
                  okLista

    If okBase Then
        For i = 1 To 10
            notas(i) = 8
        Next i

        Desc_entidade = "__TV2_OBSOLETO__"
        resPayload = MontarPayloadAvaliacao(osId2, "", notas, 2, "OBS FR", "", _
                                            payloadOSID, payloadAvaliador, payloadQtExecutada, _
                                            payloadObservacao, payloadJustif, payloadMedia)
        okPayload = (resPayload.sucesso And payloadAvaliador = TV2_FR_NOME_2 And payloadQtExecutada = 2)
        detalhesPayload = "SUCESSO=" & CStr(resPayload.sucesso) & _
                          "; AVALIADOR=" & payloadAvaliador & _
                          "; DESC_ENTIDADE_OBSOLETO=" & SafeListVal(Desc_entidade) & _
                          "; MSG=" & resPayload.mensagem
    Else
        detalhesPayload = "Base nao preparada; payload nao verificado."
    End If
    TV2_LogAssert TV2_FR_SUITE, "FR_03_PAYLOAD_VAZIO_RESOLVE_OS_CORRETA", "AUTO", _
                  "Payload sem avaliador resolve demandante pela OS correta", _
                  "OS2 resolve Local 2 mesmo com Desc_entidade obsoleto", _
                  detalhesPayload, _
                  "Fecha residual de formulario que deixa estado global antigo no workbook", _
                  okPayload

    If okBase Then
        auditAntes = TV2_AuditCount("OS Fechada/Avaliada", "AVALIADOR=" & TV2_FR_NOME_2)
        resAvalDireta = AvaliarOS(osId2, "", notas, 2, "OBS FR direta", "", Date + 6, Date + 15)
        auditDepois = TV2_AuditCount("OS Fechada/Avaliada", "AVALIADOR=" & TV2_FR_NOME_2)
        okAvalDireta = (resAvalDireta.sucesso And TV2_StatusOS(osId2) = "CONCLUIDA" And auditDepois > auditAntes)
        detalhesAvalDireta = "SUCESSO=" & CStr(resAvalDireta.sucesso) & _
                              "; STATUS_OS=" & TV2_StatusOS(osId2) & _
                              "; AUDIT_ANTES=" & CStr(auditAntes) & _
                              "; AUDIT_DEPOIS=" & CStr(auditDepois) & _
                              "; MSG=" & resAvalDireta.mensagem
    Else
        detalhesAvalDireta = "Base nao preparada; avaliacao direta nao verificada."
    End If
    TV2_LogAssert TV2_FR_SUITE, "FR_04_AVALIAROS_DIRETO_REGISTRA_DEMANDANTE", "AUTO", _
                  "AvaliarOS direto resolve avaliador vazio por OS_ID", _
                  "OS2 conclui e AUDIT_LOG contem AVALIADOR=Local 2", _
                  detalhesAvalDireta, _
                  "Garante defesa no servico mesmo se o formulario chamar AvaliarOS sem payload previo", _
                  okAvalDireta

    If okBase Then
        okInvalido = TV2_FR_AlterarEntIdOS(osId1, "999", detalhesInvalido)
        resInvalido = AvaliarOS(osId1, "", notas, 2, "OBS FR invalido", "", Date + 7, Date + 16)
        okRestore = TV2_FR_AlterarEntIdOS(osId1, TV2_FR_ENT_1, detalhesRestore)
        resResolver = ResolverDemandanteAvaliacaoPorOS(osId1, entId, nomeResolver, detalhesResolver)
        okInvalido = (okInvalido And Not resInvalido.sucesso And TV2_StatusOS(osId1) = "EM_EXECUCAO")
        detalhesInvalido = detalhesInvalido & _
                            "; SUCESSO_INVALIDO=" & CStr(resInvalido.sucesso) & _
                            "; STATUS_OS=" & TV2_StatusOS(osId1) & _
                            "; MSG=" & resInvalido.mensagem
        okRestore = (okRestore And resResolver.sucesso And IdsIguais(entId, TV2_FR_ENT_1) And nomeResolver = TV2_FR_NOME_1)
    Else
        detalhesInvalido = "Base nao preparada; negativo nao executado."
        detalhesRestore = "Base nao preparada; restore nao executado."
    End If
    TV2_LogAssert TV2_FR_SUITE, "FR_05_ENT_ID_INVALIDO_REJEITA_DIRETO", "AUTO", _
                  "AvaliarOS direto rejeita demandante inexistente", _
                  "ENT_ID inexistente nao conclui a OS nem grava avaliacao incompleta", _
                  detalhesInvalido, _
                  "Evita mascarar inconsistencia de base quando o formulario envia avaliador vazio", _
                  okInvalido

    TV2_LogAssert TV2_FR_SUITE, "FR_06_RESTAURA_ENT_ID_VALIDO", "AUTO", _
                  "Restaurar ENT_ID valido apos negativo", _
                  "ResolverDemandanteAvaliacaoPorOS volta a Local 1", _
                  detalhesRestore & "; " & detalhesResolver, _
                  "Mantem a base do workbook consistente depois do teste dirigido", _
                  okRestore

    On Error Resume Next
    If Not frm Is Nothing Then Unload frm
    On Error GoTo 0
    Set frm = Nothing

    TV2_FinalizarExecucao TV2_FR_SUITE, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    On Error Resume Next
    If Not frm Is Nothing Then Unload frm
    On Error GoTo 0
    If inicializado Then
        TV2_LogAssert TV2_FR_SUITE, "FATAL", "AUTO", _
                      "Executar suite FormulariosResiduaisCodeOnly sem erro fatal", _
                      "Nenhum erro fatal", _
                      "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                      "Falha fatal precisa ficar rastreavel sem importar UserForm", False
        TV2_FinalizarExecucao TV2_FR_SUITE, silencioso
    ElseIf Not silencioso Then
        MsgBox "Erro fatal antes de iniciar TV2 FormulariosResiduais: " & erroFatalDescricao, vbCritical, "Testes V2"
    End If
End Sub

Private Function TV2_FR_PrepararBaseDuasOS( _
    ByRef osId1Out As String, _
    ByRef osId2Out As String, _
    ByRef detalhes As String _
) As Boolean
    Dim resPre1 As TResult
    Dim resPre2 As TResult
    Dim resOs1 As TResult
    Dim resOs2 As TResult
    Dim ativId As String
    Dim codServico As String
    Dim cred1 As String
    Dim cred2 As String
    Dim entId1 As String
    Dim entId2 As String
    Dim nome1 As String
    Dim nome2 As String
    Dim det1 As String
    Dim det2 As String
    Dim resDem1 As TResult
    Dim resDem2 As TResult

    On Error GoTo falha

    TV2_PrepararBaselineCanonica
    TV2_CadastrarEntidadeCanonica TV2_FR_ENT_1, TV2_FR_NOME_1
    TV2_CadastrarEntidadeCanonica TV2_FR_ENT_2, TV2_FR_NOME_2
    TV2_CadastrarEmpresaCanonica "001", "Empresa FR 1"
    TV2_CadastrarEmpresaCanonica "002", "Empresa FR 2"

    ativId = TV2_AtivCanonA()
    codServico = TV2_CodServico(ativId, "001")
    cred1 = TV2_CredenciarAtividade("001", ativId, "001")
    cred2 = TV2_CredenciarAtividade("002", ativId, "001")

    resPre1 = EmitirPreOS(TV2_FR_ENT_1, codServico, 2)
    If resPre1.sucesso Then resOs1 = EmitirOS(resPre1.IdGerado, Date + 5, "EMP-FR-0141-A")
    osId1Out = resOs1.IdGerado

    resPre2 = EmitirPreOS(TV2_FR_ENT_2, codServico, 2)
    If resPre2.sucesso Then resOs2 = EmitirOS(resPre2.IdGerado, Date + 6, "EMP-FR-0141-B")
    osId2Out = resOs2.IdGerado

    If osId1Out <> "" Then
        resDem1 = ResolverDemandanteAvaliacaoPorOS(osId1Out, entId1, nome1, det1)
    End If
    If osId2Out <> "" Then
        resDem2 = ResolverDemandanteAvaliacaoPorOS(osId2Out, entId2, nome2, det2)
    End If

    detalhes = "ATIV_ID=" & ativId & _
               "; CRED1=" & cred1 & _
               "; CRED2=" & cred2 & _
               "; PRE1=" & resPre1.IdGerado & "/" & CStr(resPre1.sucesso) & _
               "; OS1=" & osId1Out & "/" & TV2_StatusOS(osId1Out) & _
               "; DEM1=" & nome1 & _
               "; PRE2=" & resPre2.IdGerado & "/" & CStr(resPre2.sucesso) & _
               "; OS2=" & osId2Out & "/" & TV2_StatusOS(osId2Out) & _
               "; DEM2=" & nome2

    TV2_FR_PrepararBaseDuasOS = _
        (resPre1.sucesso And resOs1.sucesso And resDem1.sucesso And _
         resPre2.sucesso And resOs2.sucesso And resDem2.sucesso And _
         TV2_StatusOS(osId1Out) = "EM_EXECUCAO" And _
         TV2_StatusOS(osId2Out) = "EM_EXECUCAO" And _
         nome1 = TV2_FR_NOME_1 And nome2 = TV2_FR_NOME_2)
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
    TV2_FR_PrepararBaseDuasOS = False
End Function

Private Function TV2_FR_LerDemandanteLista( _
    ByVal frm As Menu_Principal, _
    ByVal osId As String, _
    ByRef demandanteOut As String, _
    ByRef detalhes As String _
) As Boolean
    Dim i As Long
    Dim osLista As String

    On Error GoTo falha

    demandanteOut = ""
    If frm Is Nothing Then
        detalhes = "Formulario nao instanciado."
        Exit Function
    End If

    For i = 0 To frm.AV_Lista.ListCount - 1
        osLista = Trim$(SafeListVal(frm.AV_Lista.List(i, 0)))
        If IdsIguais(osLista, osId) Then
            demandanteOut = Trim$(SafeListVal(frm.AV_Lista.List(i, 1)))
            detalhes = "OS_ID=" & osLista & _
                       "; LINHA=" & CStr(i) & _
                       "; DEMANDANTE=" & demandanteOut & _
                       "; LISTCOUNT=" & CStr(frm.AV_Lista.ListCount)
            TV2_FR_LerDemandanteLista = True
            Exit Function
        End If
    Next i

    detalhes = "OS_ID nao encontrada na AV_Lista: " & osId & _
               "; LISTCOUNT=" & CStr(frm.AV_Lista.ListCount)
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
    TV2_FR_LerDemandanteLista = False
End Function

Private Function TV2_FR_AlterarEntIdOS( _
    ByVal osId As String, _
    ByVal entIdNovo As String, _
    ByRef detalhes As String _
) As Boolean
    Dim ws As Worksheet
    Dim linha As Long
    Dim ultima As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        detalhes = "Nao foi possivel preparar CAD_OS para escrita."
        Exit Function
    End If

    ultima = UltimaLinhaAba(SHEET_CAD_OS)
    For linha = LINHA_DADOS To ultima
        If IdsIguais(SafeListVal(ws.Cells(linha, COL_OS_ID).Value), osId) Then
            ws.Cells(linha, COL_OS_ENT_ID).Value = entIdNovo
            detalhes = "OS_ID=" & osId & "; LINHA=" & CStr(linha) & "; ENT_ID=" & entIdNovo
            TV2_FR_AlterarEntIdOS = True
            Exit For
        End If
    Next linha

    If Not TV2_FR_AlterarEntIdOS Then
        detalhes = "OS_ID nao encontrada para alterar ENT_ID: " & osId
    End If

fim:
    If Not ws Is Nothing Then Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
    Resume fim
End Function


