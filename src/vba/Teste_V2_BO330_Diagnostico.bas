Attribute VB_Name = "Teste_V2_BO330_Diagnostico"
Option Explicit

Private Const TV2_BO330_SUITE As String = "BO330_DIAGNOSTICO"
Private Const TV2_BO330_EMP_ALVO As String = "003"
Private Const TV2_BO330_STATUS_ATIVA As String = "ATIVA"
Private Const TV2_BO330_STATUS_SUSPENSA As String = "SUSPENSA_GLOBAL"
Private Const TV2_BO330_STATUS_OS_CONCLUIDA As String = "CONCLUIDA"

Public Sub TV2_RunBO330Diagnostico(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Dim inicializado As Boolean
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao TV2_BO330_SUITE, visual, 16
    inicializado = True

    TV2_BO330_RodarCaso "BO330_DIAG_01_MEDIA_5_NAO_SUSPENDE", "5", 5#, False
    TV2_BO330_RodarCaso "BO330_DIAG_02_MEDIA_4_SUSPENDE", "4", 4#, True
    TV2_BO330_RodarCaso "BO330_DIAG_03_MEDIA_0_SUSPENDE", "0", 0#, True
    TV2_BO330_RodarCaso "BO330_DIAG_04_MEDIA_4_9_SUSPENDE", "4_9", 4.9, True

    TV2_FinalizarExecucao TV2_BO330_SUITE, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    If inicializado Then
        TV2_LogAssert TV2_BO330_SUITE, "FATAL", "AUTO", _
                      "Executar diagnostico BO330 sem erro fatal", _
                      "Nenhum erro fatal", _
                      "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                      "Falha fatal precisa ficar rastreavel antes de qualquer correcao de producao", False
        TV2_FinalizarExecucao TV2_BO330_SUITE, silencioso
    ElseIf Not silencioso Then
        MsgBox "Erro fatal antes de iniciar TV2 BO330: " & erroFatalDescricao, vbCritical, "Testes V2"
    End If
End Sub

Private Sub TV2_BO330_RodarCaso( _
    ByVal cenarioId As String, _
    ByVal perfilNotas As String, _
    ByVal mediaEsperada As Double, _
    ByVal deveSuspender As Boolean _
)
    Dim ativA As String
    Dim ativB As String
    Dim ativC As String
    Dim detalhesBase As String
    Dim detalhesComum As String
    Dim detalhesAvaliacao As String
    Dim detalhesStatus As String
    Dim preRes As TResult
    Dim osRes As TResult
    Dim avalRes As TResult
    Dim notas(1 To 10) As Integer
    Dim osId As String
    Dim osEmpId As String
    Dim osStatus As String
    Dim osMedia As Variant
    Dim notaMin As Double
    Dim strikesAntesSelecionada As Long
    Dim strikesDepoisSelecionada As Long
    Dim strikesDepoisEmp03 As Long
    Dim statusSelecionada As String
    Dim statusEmp03 As String
    Dim dtFimSelecionada As Date
    Dim dtFimEmp03 As Date
    Dim statusEsperado As String
    Dim okBase As Boolean
    Dim okPreOS As Boolean
    Dim okOS As Boolean
    Dim okSelecaoEmp03 As Boolean
    Dim okStatusSelecionada As Boolean
    Dim okStatusEmp03 As Boolean
    Dim okDtFimSelecionada As Boolean

    On Error GoTo falha

    okBase = TV2_BO330_PrepararCenarioBase(ativA, ativB, ativC, detalhesBase)
    TV2_LogAssert TV2_BO330_SUITE, cenarioId & "_BASE", "AUTO", _
                  "Preparar cenario BO330 com atividade C e fila esperada", _
                  "Atividade C mapeada; fila C inicia por EMP03", _
                  detalhesBase, _
                  "Isola se a bateria V1 esta esperando EMP03 por um cenario que nao foi montado", _
                  okBase
    If Not okBase Then Exit Sub

    preRes = EmitirPreOS("001", TV2_BO330_CodServico(ativC, "001"), 1)
    okPreOS = preRes.sucesso And Trim$(preRes.IdGerado) <> ""
    If okPreOS Then
        osRes = EmitirOS(preRes.IdGerado, DateAdd("d", 3, Date), "EMP-" & cenarioId)
        okOS = osRes.sucesso And Trim$(osRes.IdGerado) <> ""
        osId = osRes.IdGerado
    End If

    osEmpId = TV2_BO330_OSEmpresa(osId)
    notaMin = GetNotaMinimaAvaliacao()
    If osEmpId <> "" Then
        strikesAntesSelecionada = ContarStrikesParaPunicao(osEmpId, notaMin)
    Else
        strikesAntesSelecionada = -1
    End If

    detalhesComum = "ATIV_A=" & ativA & "; ATIV_B=" & ativB & "; ATIV_C=" & ativC & _
                    "; PREOS_OK=" & CStr(okPreOS) & "; PREOS_ID=" & preRes.IdGerado & _
                    "; OS_OK=" & CStr(okOS) & "; OS_ID=" & osId & _
                    "; OS_EMP_ID=" & osEmpId & "; NOTA_MIN=" & Format$(notaMin, "0.00") & _
                    "; STRIKES_ANTES_SEL=" & CStr(strikesAntesSelecionada)

    okSelecaoEmp03 = (okOS And TV2_BO330_Pad3(osEmpId) = TV2_BO330_EMP_ALVO)
    TV2_LogAssert TV2_BO330_SUITE, cenarioId & "_EMP_SELECIONADA", "AUTO", _
                  "OS do recorte BO330 deve estar vinculada a EMP03", _
                  "OS_EMP_ID=003", _
                  detalhesComum, _
                  "Se falhar, a falha V1 pode estar no cenario/rodizio, nao na suspensao por nota", _
                  okSelecaoEmp03

    TV2_BO330_MontarNotas notas, perfilNotas
    avalRes = AvaliarOS(osId, "Gestor QA", notas, 10, "Diagnostico " & cenarioId, "")

    osStatus = TV2_BO330_StatusOS(osId)
    osMedia = TV2_BO330_MediaOS(osId)
    If osEmpId <> "" Then
        strikesDepoisSelecionada = ContarStrikesParaPunicao(osEmpId, notaMin)
    Else
        strikesDepoisSelecionada = -1
    End If
    strikesDepoisEmp03 = ContarStrikesParaPunicao(TV2_BO330_EMP_ALVO, notaMin)
    statusSelecionada = TV2_BO330_StatusEmpresa(osEmpId)
    statusEmp03 = TV2_BO330_StatusEmpresa(TV2_BO330_EMP_ALVO)
    dtFimSelecionada = TV2_BO330_DtFimEmpresa(osEmpId)
    dtFimEmp03 = TV2_BO330_DtFimEmpresa(TV2_BO330_EMP_ALVO)

    If deveSuspender Then
        statusEsperado = TV2_BO330_STATUS_SUSPENSA
        okDtFimSelecionada = (dtFimSelecionada > Date)
    Else
        statusEsperado = TV2_BO330_STATUS_ATIVA
        okDtFimSelecionada = (dtFimSelecionada = 0)
    End If

    detalhesAvaliacao = "AVAL_OK=" & CStr(avalRes.sucesso) & _
                        "; MSG=" & avalRes.mensagem & _
                        "; OS_STATUS=" & osStatus & _
                        "; OS_MEDIA=" & TV2_BO330_FormatValor(osMedia) & _
                        "; MEDIA_ESPERADA=" & Format$(mediaEsperada, "0.00") & _
                        "; STRIKES_DEPOIS_SEL=" & CStr(strikesDepoisSelecionada) & _
                        "; STRIKES_DEPOIS_EMP03=" & CStr(strikesDepoisEmp03)

    TV2_LogAssert TV2_BO330_SUITE, cenarioId & "_AVALIACAO_CONCLUI", "AUTO", _
                  "Avaliacao do recorte BO330 conclui OS e grava media", _
                  "AvaliarOS sucesso; OS concluida; media esperada gravada", _
                  detalhesAvaliacao, _
                  "Garante que o diagnostico chegou ate a regra de nota minima", _
                  (avalRes.sucesso And osStatus = TV2_BO330_STATUS_OS_CONCLUIDA And _
                   TV2_BO330_MediaIgual(osMedia, mediaEsperada))

    detalhesStatus = "OS_EMP_ID=" & osEmpId & _
                     "; STATUS_SEL=" & statusSelecionada & _
                     "; DT_FIM_SEL=" & TV2_BO330_FormatData(dtFimSelecionada) & _
                     "; STATUS_EMP03=" & statusEmp03 & _
                     "; DT_FIM_EMP03=" & TV2_BO330_FormatData(dtFimEmp03) & _
                     "; ESPERADO=" & statusEsperado & _
                     "; DEVE_SUSPENDER=" & CStr(deveSuspender)

    okStatusSelecionada = (statusSelecionada = statusEsperado)
    TV2_LogAssert TV2_BO330_SUITE, cenarioId & "_STATUS_EMP_SELECIONADA", "AUTO", _
                  "Regra de nota minima atualiza a empresa vinculada a OS", _
                  "Empresa selecionada fica " & statusEsperado, _
                  detalhesStatus, _
                  "Se falhar com OS_EMP_ID=003, a causa provavel esta em AvaliarOS/Suspender", _
                  okStatusSelecionada

    okStatusEmp03 = (statusEmp03 = statusEsperado)
    TV2_LogAssert TV2_BO330_SUITE, cenarioId & "_STATUS_EMP03_LEGADO", "AUTO", _
                  "Contrato legado BO330 observa EMP03", _
                  "EMP03 fica " & statusEsperado, _
                  detalhesStatus, _
                  "Compara a expectativa da bateria V1 contra a empresa real da OS", _
                  okStatusEmp03

    TV2_LogAssert TV2_BO330_SUITE, cenarioId & "_DT_FIM_EMP_SELECIONADA", "AUTO", _
                  "DT_FIM_SUSP da empresa selecionada acompanha a suspensao por nota", _
                  IIf(deveSuspender, "DT_FIM_SUSP > hoje", "DT_FIM_SUSP vazio"), _
                  detalhesStatus, _
                  "Distingue falha de status de falha de prazo de suspensao", _
                  okDtFimSelecionada
    Exit Sub

falha:
    TV2_LogAssert TV2_BO330_SUITE, cenarioId & "_FATAL", "AUTO", _
                  "Executar caso diagnostico sem erro fatal", _
                  "Nenhum erro fatal", _
                  "Erro " & CStr(Err.Number) & ": " & Err.Description, _
                  "Falha fatal do caso precisa ser registrada antes de nova correcao", False
End Sub

Private Function TV2_BO330_PrepararCenarioBase( _
    ByRef ativAOut As String, _
    ByRef ativBOut As String, _
    ByRef ativCOut As String, _
    ByRef detalhes As String _
) As Boolean
    Dim credLog As String
    Dim filaC As String

    On Error GoTo falha

    TV2_PrepararBaselineCanonica
    If Not TV2_BO330_AtividadesCanonicas(ativAOut, ativBOut, ativCOut, detalhes) Then Exit Function

    TV2_CadastrarEntidadeCanonica "001", "Local 1"
    TV2_CadastrarEntidadeCanonica "002", "Local 2"
    TV2_CadastrarEntidadeCanonica "003", "Local 3"

    TV2_CadastrarEmpresaCanonica "001", "Empresa 1"
    TV2_CadastrarEmpresaCanonica "002", "Empresa 2"
    TV2_CadastrarEmpresaCanonica "003", "Empresa 3"

    credLog = credLog & "001/A=" & TV2_CredenciarAtividade("001", ativAOut, "001") & ";"
    credLog = credLog & "002/B=" & TV2_CredenciarAtividade("002", ativBOut, "001") & ";"
    credLog = credLog & "003/C=" & TV2_CredenciarAtividade("003", ativCOut, "001") & ";"
    credLog = credLog & "001/B=" & TV2_CredenciarAtividade("001", ativBOut, "001") & ";"
    credLog = credLog & "001/C=" & TV2_CredenciarAtividade("001", ativCOut, "001") & ";"
    credLog = credLog & "002/C=" & TV2_CredenciarAtividade("002", ativCOut, "001") & ";"

    filaC = TV2_BO330_FilaCsv(ativCOut)
    detalhes = detalhes & "; CRED=" & credLog & "; FILA_C=" & filaC
    TV2_BO330_PrepararCenarioBase = (ativCOut <> "" And filaC <> "")
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
    TV2_BO330_PrepararCenarioBase = False
End Function

Private Function TV2_BO330_AtividadesCanonicas( _
    ByRef ativAOut As String, _
    ByRef ativBOut As String, _
    ByRef ativCOut As String, _
    ByRef detalhes As String _
) As Boolean
    Dim ws As Worksheet
    Dim ultima As Long
    Dim linha As Long
    Dim idx As Long
    Dim idAtual As String
    Dim descAtual As String

    Set ws = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
    ultima = UltimaLinhaAba(SHEET_ATIVIDADES)

    For linha = LINHA_DADOS To ultima
        idAtual = Trim$(CStr(ws.Cells(linha, COL_ATIV_ID).Value))
        descAtual = Trim$(CStr(ws.Cells(linha, COL_ATIV_DESCRICAO).Value))
        If idAtual <> "" And descAtual <> "" And IsNumeric(idAtual) Then
            idx = idx + 1
            Select Case idx
                Case 1
                    ativAOut = TV2_BO330_Pad3(idAtual)
                Case 2
                    ativBOut = TV2_BO330_Pad3(idAtual)
                Case 3
                    ativCOut = TV2_BO330_Pad3(idAtual)
                    Exit For
            End Select
        End If
    Next linha

    detalhes = "ATIV_A=" & ativAOut & "; ATIV_B=" & ativBOut & "; ATIV_C=" & ativCOut
    TV2_BO330_AtividadesCanonicas = (ativAOut <> "" And ativBOut <> "" And ativCOut <> "")
End Function

Private Sub TV2_BO330_MontarNotas(ByRef notas() As Integer, ByVal perfilNotas As String)
    Dim i As Long

    Select Case UCase$(Trim$(perfilNotas))
        Case "4_9"
            For i = LBound(notas) To UBound(notas)
                notas(i) = 5
            Next i
            notas(9) = 4
        Case Else
            For i = LBound(notas) To UBound(notas)
                notas(i) = CInt(Val(perfilNotas))
            Next i
    End Select
End Sub

Private Function TV2_BO330_CodServico(ByVal ativId As String, ByVal servId As String) As String
    TV2_BO330_CodServico = TV2_BO330_Pad3(ativId) & "|" & TV2_BO330_Pad3(servId)
End Function

Private Function TV2_BO330_FilaCsv(ByVal ativId As String) As String
    Dim fila() As TCredenciamento
    Dim i As Long
    Dim txt As String

    On Error GoTo falha

    fila = BuscarFila(ativId)
    If fila(LBound(fila)).CRED_ID = "" Then Exit Function

    For i = LBound(fila) To UBound(fila)
        If txt <> "" Then txt = txt & ","
        txt = txt & TV2_BO330_Pad3(fila(i).EMP_ID) & "#" & CStr(fila(i).POSICAO_FILA)
    Next i

    TV2_BO330_FilaCsv = txt
    Exit Function

falha:
    TV2_BO330_FilaCsv = "ERRO_FILA=" & CStr(Err.Number) & ":" & Err.Description
End Function

Private Function TV2_BO330_LinhaPorId(ByVal nomeAba As String, ByVal colunaId As Long, ByVal idValor As String) As Long
    Dim ws As Worksheet
    Dim linha As Long
    Dim ultima As Long

    If Trim$(idValor) = "" Then Exit Function

    Set ws = ThisWorkbook.Sheets(nomeAba)
    ultima = UltimaLinhaAba(nomeAba)
    For linha = LINHA_DADOS To ultima
        If IdsIguais(ws.Cells(linha, colunaId).Value, idValor) Then
            TV2_BO330_LinhaPorId = linha
            Exit Function
        End If
    Next linha
End Function

Private Function TV2_BO330_OSEmpresa(ByVal osId As String) As String
    Dim linha As Long
    linha = TV2_BO330_LinhaPorId(SHEET_CAD_OS, COL_OS_ID, osId)
    If linha > 0 Then
        TV2_BO330_OSEmpresa = TV2_BO330_Pad3(ThisWorkbook.Sheets(SHEET_CAD_OS).Cells(linha, COL_OS_EMP_ID).Value)
    End If
End Function

Private Function TV2_BO330_StatusOS(ByVal osId As String) As String
    Dim linha As Long
    linha = TV2_BO330_LinhaPorId(SHEET_CAD_OS, COL_OS_ID, osId)
    If linha > 0 Then
        TV2_BO330_StatusOS = Trim$(CStr(ThisWorkbook.Sheets(SHEET_CAD_OS).Cells(linha, COL_OS_STATUS).Value))
    End If
End Function

Private Function TV2_BO330_MediaOS(ByVal osId As String) As Variant
    Dim linha As Long
    linha = TV2_BO330_LinhaPorId(SHEET_CAD_OS, COL_OS_ID, osId)
    If linha > 0 Then
        TV2_BO330_MediaOS = ThisWorkbook.Sheets(SHEET_CAD_OS).Cells(linha, COL_OS_MEDIA).Value
    Else
        TV2_BO330_MediaOS = 0#
    End If
End Function

Private Function TV2_BO330_StatusEmpresa(ByVal empId As String) As String
    Dim linha As Long
    linha = TV2_BO330_LinhaPorId(SHEET_EMPRESAS, COL_EMP_ID, empId)
    If linha > 0 Then
        TV2_BO330_StatusEmpresa = Trim$(CStr(ThisWorkbook.Sheets(SHEET_EMPRESAS).Cells(linha, COL_EMP_STATUS_GLOBAL).Value))
    Else
        TV2_BO330_StatusEmpresa = "NAO_ENCONTRADA"
    End If
End Function

Private Function TV2_BO330_DtFimEmpresa(ByVal empId As String) As Date
    Dim linha As Long
    Dim valor As Variant

    linha = TV2_BO330_LinhaPorId(SHEET_EMPRESAS, COL_EMP_ID, empId)
    If linha = 0 Then Exit Function

    valor = ThisWorkbook.Sheets(SHEET_EMPRESAS).Cells(linha, COL_EMP_DT_FIM_SUSP).Value
    If IsDate(valor) Then TV2_BO330_DtFimEmpresa = CDate(valor)
End Function

Private Function TV2_BO330_FormatData(ByVal valor As Date) As String
    If valor > 0 Then
        TV2_BO330_FormatData = Format$(valor, "yyyy-mm-dd")
    Else
        TV2_BO330_FormatData = "vazio"
    End If
End Function

Private Function TV2_BO330_FormatValor(ByVal valor As Variant) As String
    If IsNumeric(valor) Then
        TV2_BO330_FormatValor = Format$(CDbl(valor), "0.00")
    Else
        TV2_BO330_FormatValor = Trim$(CStr(valor))
    End If
End Function

Private Function TV2_BO330_MediaIgual(ByVal valor As Variant, ByVal esperado As Double) As Boolean
    If IsNumeric(valor) Then
        TV2_BO330_MediaIgual = (Abs(CDbl(valor) - esperado) < 0.001)
    End If
End Function

Private Function TV2_BO330_Pad3(ByVal valor As Variant) As String
    Dim texto As String
    texto = Trim$(CStr(valor))
    If texto = "" Then Exit Function
    If IsNumeric(texto) Then
        TV2_BO330_Pad3 = Format$(CLng(Val(texto)), "000")
    Else
        TV2_BO330_Pad3 = texto
    End If
End Function


