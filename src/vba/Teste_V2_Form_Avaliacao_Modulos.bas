Attribute VB_Name = "Teste_V2_Form_Avaliacao_Modulos"
Option Explicit

Private Const TV2_FAM_SUITE As String = "FORM_AVALIACAO_MODULOS"
Private Const TV2_FAM_ENT_ID As String = "001"
Private Const TV2_FAM_ENT_NOME As String = "Local 1"
Private Const TV2_FAM_EMP_ID As String = "001"

Public Sub TV2_RunFormAvaliacaoModulos(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Dim inicializado As Boolean
    Dim osId As String
    Dim detalhesBase As String
    Dim detalhesResolver As String
    Dim detalhesLista As String
    Dim detalhesPayload As String
    Dim detalhesInvalido As String
    Dim detalhesRestore As String
    Dim entId As String
    Dim demandanteNome As String
    Dim demandanteLista As String
    Dim payloadOSID As String
    Dim payloadAvaliador As String
    Dim payloadQtExecutada As Double
    Dim payloadObservacao As String
    Dim payloadJustif As String
    Dim payloadMedia As Double
    Dim payloadAvaliadorFallback As String
    Dim payloadAvaliadorExplicito As String
    Dim notas(1 To 10) As Integer
    Dim i As Long
    Dim okBase As Boolean
    Dim okResolver As Boolean
    Dim okLista As Boolean
    Dim okPayloadFallback As Boolean
    Dim okPayloadExplicito As Boolean
    Dim okInvalido As Boolean
    Dim okRestore As Boolean
    Dim resResolver As TResult
    Dim resPayloadVazio As TResult
    Dim resPayloadExplicito As TResult
    Dim resPayloadInvalido As TResult
    Dim frm As Menu_Principal
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao TV2_FAM_SUITE, visual, 5
    inicializado = True

    okBase = TV2_FAM_PrepararBase(osId, detalhesBase)
    TV2_LogAssert TV2_FAM_SUITE, "FAM_01_PREPARA_OS_EM_EXECUCAO", "AUTO", _
                  "Preparar OS em execucao com demandante canonico", _
                  "OS em EM_EXECUCAO com ENT_ID=001 e demandante Local 1", _
                  detalhesBase, _
                  "Base controlada para testar avaliacao/demandante sem importar UserForm", _
                  okBase

    If okBase Then
        resResolver = ResolverDemandanteAvaliacaoPorOS(osId, entId, demandanteNome, detalhesResolver)
        okResolver = (resResolver.sucesso And IdsIguais(entId, TV2_FAM_ENT_ID) And demandanteNome = TV2_FAM_ENT_NOME)
    Else
        detalhesResolver = "Base nao preparada; resolver nao executado."
    End If
    TV2_LogAssert TV2_FAM_SUITE, "FAM_02_DEMANDANTE_RESOLVIDO_POR_OS", "AUTO", _
                  "Resolver demandante por OS_ID", _
                  "ResolverDemandanteAvaliacaoPorOS retorna ENT_ID=001 e NOME=Local 1", _
                  detalhesResolver, _
                  "Remove dependencia de Desc_entidade ou estado obsoleto do formulario", _
                  okResolver

    If okBase Then
        Set frm = New Menu_Principal
        PreencherAvaliarOS
        okLista = TV2_FAM_LerDemandanteLista(frm, osId, demandanteLista, detalhesLista)
    Else
        detalhesLista = "Base nao preparada; lista nao verificada."
    End If
    TV2_LogAssert TV2_FAM_SUITE, "FAM_03_AV_LISTA_EXIBE_DEMANDANTE", "AUTO", _
                  "AV_Lista do formulario existente recebe demandante", _
                  "Linha da OS traz Local 1 na coluna 1", _
                  detalhesLista, _
                  "Prova a fatia de modulos sem importar Menu_Principal.frm", _
                  (okLista And demandanteLista = TV2_FAM_ENT_NOME)

    If okBase Then
        For i = 1 To 10
            notas(i) = 8
        Next i

        resPayloadVazio = MontarPayloadAvaliacao(osId, "", notas, 2, "OBS FAM", "", _
                                                 payloadOSID, payloadAvaliador, payloadQtExecutada, _
                                                 payloadObservacao, payloadJustif, payloadMedia)
        okPayloadFallback = (resPayloadVazio.sucesso And payloadAvaliador = TV2_FAM_ENT_NOME And payloadQtExecutada = 2)
        payloadAvaliadorFallback = payloadAvaliador

        resPayloadExplicito = MontarPayloadAvaliacao(osId, "Avaliador Manual", notas, 2, "OBS FAM", "", _
                                                     payloadOSID, payloadAvaliador, payloadQtExecutada, _
                                                     payloadObservacao, payloadJustif, payloadMedia)
        okPayloadExplicito = (resPayloadExplicito.sucesso And payloadAvaliador = "Avaliador Manual")
        payloadAvaliadorExplicito = payloadAvaliador
        detalhesPayload = "VAZIO_SUCESSO=" & CStr(resPayloadVazio.sucesso) & _
                          "; VAZIO_AVALIADOR=" & payloadAvaliadorFallback & _
                          "; MSG_VAZIO=" & resPayloadVazio.mensagem & _
                          "; EXPLICITO_SUCESSO=" & CStr(resPayloadExplicito.sucesso) & _
                          "; EXPLICITO_AVALIADOR=" & payloadAvaliadorExplicito & _
                          "; MSG_EXPLICITO=" & resPayloadExplicito.mensagem
    Else
        detalhesPayload = "Base nao preparada; payload nao verificado."
    End If
    TV2_LogAssert TV2_FAM_SUITE, "FAM_04_PAYLOAD_FALLBACK_E_PRESERVA_EXPLICITO", "AUTO", _
                  "Payload resolve demandante vazio por OS_ID e preserva avaliador explicito", _
                  "Vazio vira Local 1; Avaliador Manual permanece Avaliador Manual", _
                  detalhesPayload, _
                  "Permite o formulario existente continuar chamando MontarPayloadAvaliacao com AVListaCol(1)", _
                  (okPayloadFallback And okPayloadExplicito)

    If okBase Then
        okInvalido = TV2_FAM_AlterarEntIdOS(osId, "999", detalhesInvalido)
        resPayloadInvalido = MontarPayloadAvaliacao(osId, "", notas, 2, "OBS FAM", "", _
                                                    payloadOSID, payloadAvaliador, payloadQtExecutada, _
                                                    payloadObservacao, payloadJustif, payloadMedia)
        okRestore = TV2_FAM_AlterarEntIdOS(osId, TV2_FAM_ENT_ID, detalhesRestore)
        okInvalido = (okInvalido And Not resPayloadInvalido.sucesso And okRestore)
        detalhesInvalido = detalhesInvalido & _
                           "; PAYLOAD_INVALIDO_SUCESSO=" & CStr(resPayloadInvalido.sucesso) & _
                           "; MSG=" & resPayloadInvalido.mensagem & _
                           "; RESTORE=" & CStr(okRestore) & "; " & detalhesRestore
    Else
        detalhesInvalido = "Base nao preparada; cenario invalido nao executado."
    End If
    TV2_LogAssert TV2_FAM_SUITE, "FAM_05_ENT_ID_INVALIDO_FALHA_AUDITAVEL", "AUTO", _
                  "Demandante invalido falha sem gravar payload incompleto", _
                  "ENT_ID inexistente reprova e base e restaurada", _
                  detalhesInvalido, _
                  "Evita mascarar base inconsistente quando OS_ID nao resolve demandante", _
                  okInvalido

    On Error Resume Next
    If Not frm Is Nothing Then Unload frm
    On Error GoTo 0
    Set frm = Nothing

    TV2_FinalizarExecucao TV2_FAM_SUITE, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    On Error Resume Next
    If Not frm Is Nothing Then Unload frm
    On Error GoTo 0
    If inicializado Then
        TV2_LogAssert TV2_FAM_SUITE, "FATAL", "AUTO", _
                      "Executar suite FormAvaliacaoModulos sem erro fatal", _
                      "Nenhum erro fatal", _
                      "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                      "Falha fatal precisa ficar rastreavel sem importar UserForm", False
        TV2_FinalizarExecucao TV2_FAM_SUITE, silencioso
    ElseIf Not silencioso Then
        MsgBox "Erro fatal antes de iniciar TV2 FormAvaliacaoModulos: " & erroFatalDescricao, vbCritical, "Testes V2"
    End If
End Sub

Private Function TV2_FAM_PrepararBase(ByRef osIdOut As String, ByRef detalhes As String) As Boolean
    Dim resPre As TResult
    Dim resOs As TResult
    Dim ativId As String
    Dim cred As String

    On Error GoTo falha

    TV2_PrepararBaselineCanonica
    TV2_CadastrarEntidadeCanonica TV2_FAM_ENT_ID, TV2_FAM_ENT_NOME
    TV2_CadastrarEmpresaCanonica TV2_FAM_EMP_ID, "Empresa FAM 1"

    ativId = TV2_AtivCanonA()
    cred = TV2_CredenciarAtividade(TV2_FAM_EMP_ID, ativId, "001")
    resPre = EmitirPreOS(TV2_FAM_ENT_ID, TV2_CodServico(ativId, "001"), 2)
    If resPre.sucesso Then
        resOs = EmitirOS(resPre.IdGerado, Date + 5, "EMP-FAM-0138")
        If resOs.sucesso Then osIdOut = resOs.IdGerado
    End If

    detalhes = "ATIV_ID=" & ativId & _
               "; CRED=" & cred & _
               "; PRE_OK=" & CStr(resPre.sucesso) & _
               "; PRE_ID=" & resPre.IdGerado & _
               "; OS_OK=" & CStr(resOs.sucesso) & _
               "; OS_ID=" & osIdOut & _
               "; STATUS_OS=" & TV2_StatusOS(osIdOut)

    TV2_FAM_PrepararBase = (resPre.sucesso And resOs.sucesso And TV2_StatusOS(osIdOut) = "EM_EXECUCAO")
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
    TV2_FAM_PrepararBase = False
End Function

Private Function TV2_FAM_LerDemandanteLista( _
    ByVal frm As Menu_Principal, _
    ByVal osId As String, _
    ByRef demandanteOut As String, _
    ByRef detalhes As String _
) As Boolean
    Dim i As Long
    Dim osLista As String

    On Error GoTo falha

    If frm Is Nothing Then
        detalhes = "Formulario nao instanciado."
        Exit Function
    End If

    For i = 0 To frm.AV_Lista.ListCount - 1
        osLista = Trim$(CStr(frm.AV_Lista.List(i, 0)))
        If IdsIguais(osLista, osId) Then
            demandanteOut = Trim$(CStr(frm.AV_Lista.List(i, 1)))
            detalhes = "LISTCOUNT=" & CStr(frm.AV_Lista.ListCount) & _
                       "; LINHA=" & CStr(i) & _
                       "; OS_ID=" & osLista & _
                       "; DEMANDANTE=" & demandanteOut
            TV2_FAM_LerDemandanteLista = True
            Exit Function
        End If
    Next i

    detalhes = "OS_ID nao encontrada na AV_Lista; LISTCOUNT=" & CStr(frm.AV_Lista.ListCount) & _
               "; OS_ID=" & osId
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
    TV2_FAM_LerDemandanteLista = False
End Function

Private Function TV2_FAM_AlterarEntIdOS( _
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
            TV2_FAM_AlterarEntIdOS = True
            Exit For
        End If
    Next linha

    If Not TV2_FAM_AlterarEntIdOS Then
        detalhes = "OS_ID nao encontrada para alterar ENT_ID: " & osId
    End If

fim:
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
    Resume fim
End Function


