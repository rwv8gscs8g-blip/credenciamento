Attribute VB_Name = "Rel_Rodizio_Status"
Option Explicit

Private Const RRS_SHEET As String = "RPT_RODIZIO_STATUS"
Private Const STATUS_EMP_ATIVA As String = "ATIVA"
Private Const STATUS_EMP_SUSPENSA As String = "SUSPENSA_GLOBAL"
Private Const STATUS_EMP_INATIVA As String = "INATIVA"
Private Const STATUS_CRED_ATIVO As String = "ATIVO"

Public Function RRS_DiasRestantesSuspensao(ByVal statusGlobal As String, ByVal dtFimSusp As Date) As Long
    Dim dias As Long

    If UCase$(Trim$(statusGlobal)) <> STATUS_EMP_SUSPENSA Then Exit Function
    If dtFimSusp <= CDate(0) Then Exit Function

    dias = DateDiff("d", Date, DateValue(dtFimSusp))
    If dias < 0 Then dias = 0
    RRS_DiasRestantesSuspensao = dias
End Function

Public Function RRS_RetornoPrevistoTexto(ByVal statusGlobal As String, ByVal dtFimSusp As Date) As String
    If UCase$(Trim$(statusGlobal)) <> STATUS_EMP_SUSPENSA Then
        RRS_RetornoPrevistoTexto = ""
    ElseIf dtFimSusp <= CDate(0) Then
        RRS_RetornoPrevistoTexto = "INDEFINIDO"
    Else
        RRS_RetornoPrevistoTexto = Format$(dtFimSusp, "dd/mm/yyyy")
    End If
End Function

Public Function RRS_StatusGlobalHumano(ByVal statusGlobal As String) As String
    Dim stGlobal As String

    stGlobal = UCase$(Trim$(statusGlobal))
    Select Case stGlobal
        Case STATUS_EMP_ATIVA
            RRS_StatusGlobalHumano = "ATIVA"
        Case STATUS_EMP_SUSPENSA
            RRS_StatusGlobalHumano = "SUSPENSA"
        Case STATUS_EMP_INATIVA
            RRS_StatusGlobalHumano = "INATIVA"
        Case ""
            RRS_StatusGlobalHumano = "NAO INFORMADO"
        Case Else
            RRS_StatusGlobalHumano = stGlobal
    End Select
End Function

Public Function RRS_SuspensaDesdeTexto(ByVal empId As String, ByVal statusGlobal As String) As String
    Dim dtSusp As Date

    If UCase$(Trim$(statusGlobal)) <> STATUS_EMP_SUSPENSA Then
        RRS_SuspensaDesdeTexto = "-"
        Exit Function
    End If

    dtSusp = RRS_UltimaDataEventoEmpresa(empId, CLng(EVT_SUSPENSAO))
    If dtSusp > CDate(0) Then
        RRS_SuspensaDesdeTexto = Format$(dtSusp, "dd/mm/yyyy")
    Else
        RRS_SuspensaDesdeTexto = "SEM REGISTRO"
    End If
End Function

Public Function RRS_SuspensaAteTexto(ByVal statusGlobal As String, ByVal dtFimSusp As Date) As String
    If UCase$(Trim$(statusGlobal)) <> STATUS_EMP_SUSPENSA Then
        RRS_SuspensaAteTexto = "-"
    ElseIf dtFimSusp <= CDate(0) Then
        RRS_SuspensaAteTexto = "INDEFINIDA"
    Else
        RRS_SuspensaAteTexto = Format$(dtFimSusp, "dd/mm/yyyy")
    End If
End Function

Public Function RRS_UltimaReativacaoTexto(ByVal dtUltReativ As Date) As String
    If dtUltReativ <= CDate(0) Then
        RRS_UltimaReativacaoTexto = "-"
    Else
        RRS_UltimaReativacaoTexto = Format$(dtUltReativ, "dd/mm/yyyy")
    End If
End Function

Public Function RRS_StrikesNotaBaixa(ByVal empId As String, Optional ByVal statusGlobal As String = "") As Long
    Dim res As TResult
    Dim qtd As Long
    Dim qtdAudit As Long

    On Error GoTo falha

    empId = RRS_Pad3(empId)
    If empId = "" Then Exit Function

    res = ContarStrikesPorEmpresaResultado(empId, GetNotaMinimaAvaliacao(), qtd)
    If res.sucesso Then RRS_StrikesNotaBaixa = qtd

    If RRS_StrikesNotaBaixa = 0 And UCase$(Trim$(statusGlobal)) = STATUS_EMP_SUSPENSA Then
        qtdAudit = RRS_UltimoStrikeSuspensaoAudit(empId)
        If qtdAudit > RRS_StrikesNotaBaixa Then RRS_StrikesNotaBaixa = qtdAudit
    End If
    Exit Function

falha:
    If UCase$(Trim$(statusGlobal)) = STATUS_EMP_SUSPENSA Then
        RRS_StrikesNotaBaixa = RRS_UltimoStrikeSuspensaoAudit(empId)
    End If
End Function

Public Function RRS_StrikesRecusaPrazo(ByVal empId As String) As Long
    Dim emp As TEmpresa
    Dim linhaEmp As Long

    On Error GoTo fim
    emp = LerEmpresa(RRS_Pad3(empId), linhaEmp)
    If linhaEmp > 0 Then RRS_StrikesRecusaPrazo = emp.QTD_RECUSAS
fim:
End Function

Public Function RRS_StrikesNotaBaixaTexto(ByVal empId As String, Optional ByVal statusGlobal As String = "") As String
    RRS_StrikesNotaBaixaTexto = CStr(RRS_StrikesNotaBaixa(empId, statusGlobal))
End Function

Public Function RRS_StrikesRecusaPrazoTexto(ByVal empId As String) As String
    RRS_StrikesRecusaPrazoTexto = CStr(RRS_StrikesRecusaPrazo(empId))
End Function

Private Function RRS_OcupacaoAtividadeTexto(ByVal empId As String, ByVal idAtividade As String) As String
    If Trim$(idAtividade) = "" Then Exit Function

    If TemOSAbertaNaAtividade(empId, idAtividade) Then
        RRS_OcupacaoAtividadeTexto = "OS EM EXECUCAO"
    ElseIf TemPreOSPendenteNaAtividade(empId, idAtividade) Then
        RRS_OcupacaoAtividadeTexto = "PRE-OS PENDENTE"
    End If
End Function

Private Function RRS_ComporDisponibilidadeSuspensa(ByVal dispBase As String, ByVal ocupacaoAtividade As String) As String
    If Trim$(ocupacaoAtividade) = "" Then
        RRS_ComporDisponibilidadeSuspensa = dispBase
    Else
        RRS_ComporDisponibilidadeSuspensa = dispBase & "; " & ocupacaoAtividade
    End If
End Function

Public Function RRS_DisponibilidadeOperacionalEmpresa( _
    ByVal empId As String, _
    Optional ByVal statusCred As String = "ATIVO", _
    Optional ByVal ativId As String = "" _
) As String
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim stCred As String
    Dim stGlobal As String
    Dim idAtividade As String
    Dim ocupacaoAtividade As String
    Dim dispBase As String

    On Error GoTo falha

    emp = LerEmpresa(RRS_Pad3(empId), linhaEmp)
    If linhaEmp = 0 Then
        RRS_DisponibilidadeOperacionalEmpresa = "EMPRESA NAO ENCONTRADA"
        Exit Function
    End If

    stCred = UCase$(Trim$(statusCred))
    stGlobal = UCase$(Trim$(emp.STATUS_GLOBAL))
    idAtividade = RRS_Pad3(ativId)

    If stCred <> STATUS_CRED_ATIVO Then
        RRS_DisponibilidadeOperacionalEmpresa = "CREDENCIAMENTO INATIVO"
    ElseIf stGlobal = STATUS_EMP_SUSPENSA Then
        ocupacaoAtividade = RRS_OcupacaoAtividadeTexto(emp.EMP_ID, idAtividade)
        If emp.DT_FIM_SUSP > CDate(0) And emp.DT_FIM_SUSP <= Date Then
            dispBase = "REATIVAVEL - PRAZO VENCIDO"
        ElseIf emp.DT_FIM_SUSP > CDate(0) Then
            dispBase = "SUSPENSA ATE " & Format$(emp.DT_FIM_SUSP, "dd/mm/yyyy")
        Else
            dispBase = "SUSPENSA SEM DATA DE RETORNO"
        End If
        RRS_DisponibilidadeOperacionalEmpresa = RRS_ComporDisponibilidadeSuspensa(dispBase, ocupacaoAtividade)
    ElseIf stGlobal = STATUS_EMP_INATIVA Then
        RRS_DisponibilidadeOperacionalEmpresa = "EMPRESA INATIVA"
    ElseIf stGlobal <> STATUS_EMP_ATIVA Then
        RRS_DisponibilidadeOperacionalEmpresa = "STATUS GLOBAL " & stGlobal
    Else
        ocupacaoAtividade = RRS_OcupacaoAtividadeTexto(emp.EMP_ID, idAtividade)
        If ocupacaoAtividade <> "" Then
            RRS_DisponibilidadeOperacionalEmpresa = ocupacaoAtividade
        Else
            RRS_DisponibilidadeOperacionalEmpresa = "DISPONIVEL"
        End If
    End If
    Exit Function

falha:
    RRS_DisponibilidadeOperacionalEmpresa = "DISPONIBILIDADE INDISPONIVEL"
End Function

Public Function RRS_StatusEmpresaNaData( _
    ByVal empId As String, _
    Optional ByVal statusCred As String = "ATIVO", _
    Optional ByVal ativId As String = "" _
) As String
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim strikesNota As Long
    Dim strikesRecusa As Long

    On Error GoTo falha

    emp = LerEmpresa(RRS_Pad3(empId), linhaEmp)
    If linhaEmp = 0 Then
        RRS_StatusEmpresaNaData = "Status da empresa nesta data: empresa nao encontrada no cadastro."
        Exit Function
    End If

    strikesNota = RRS_StrikesNotaBaixa(emp.EMP_ID, emp.STATUS_GLOBAL)
    strikesRecusa = RRS_StrikesRecusaPrazo(emp.EMP_ID)

    RRS_StatusEmpresaNaData = "Status da empresa nesta data: status=" & RRS_StatusGlobalHumano(emp.STATUS_GLOBAL) & _
        "; disponibilidade=" & RRS_DisponibilidadeOperacionalEmpresa(emp.EMP_ID, statusCred, ativId) & _
        "; suspensa ate=" & RRS_SuspensaAteTexto(emp.STATUS_GLOBAL, emp.DT_FIM_SUSP) & _
        "; strikes nota baixa=" & CStr(strikesNota) & _
        "; strikes recusa/prazo=" & CStr(strikesRecusa) & "."
    Exit Function

falha:
    RRS_StatusEmpresaNaData = "Status da empresa nesta data: diagnostico indisponivel."
End Function

Public Function RRS_DiagnosticoOperacionalEmpresa( _
    ByVal empId As String, _
    Optional ByVal statusCred As String = "ATIVO", _
    Optional ByVal ativId As String = "" _
) As String
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim statusHumano As String
    Dim suspAte As String
    Dim disponibilidade As String
    Dim strikesNota As Long
    Dim strikesRecusa As Long

    On Error GoTo falha

    emp = LerEmpresa(RRS_Pad3(empId), linhaEmp)
    If linhaEmp = 0 Then
        RRS_DiagnosticoOperacionalEmpresa = "Empresa nao encontrada no cadastro."
        Exit Function
    End If

    statusHumano = RRS_StatusGlobalHumano(emp.STATUS_GLOBAL)
    suspAte = RRS_SuspensaAteTexto(emp.STATUS_GLOBAL, emp.DT_FIM_SUSP)
    disponibilidade = RRS_DisponibilidadeOperacionalEmpresa(emp.EMP_ID, statusCred, ativId)
    strikesNota = RRS_StrikesNotaBaixa(emp.EMP_ID, emp.STATUS_GLOBAL)
    strikesRecusa = RRS_StrikesRecusaPrazo(emp.EMP_ID)

    RRS_DiagnosticoOperacionalEmpresa = "Status: " & statusHumano & _
        "; disponibilidade: " & disponibilidade & _
        "; suspensa ate: " & suspAte & _
        "; strikes nota baixa: " & CStr(strikesNota) & _
        "; strikes recusa/prazo: " & CStr(strikesRecusa)
    Exit Function

falha:
    RRS_DiagnosticoOperacionalEmpresa = "Diagnostico indisponivel."
End Function

Public Function RRS_AvisoOperacionalEmpresa( _
    ByVal empId As String, _
    Optional ByVal statusCred As String = "ATIVO", _
    Optional ByVal ativId As String = "" _
) As String
    RRS_AvisoOperacionalEmpresa = RRS_StatusEmpresaNaData(empId, statusCred, ativId)
End Function

Public Function RRS_AvisoOperacionalEmpresaCurto( _
    ByVal empId As String, _
    Optional ByVal statusCred As String = "ATIVO", _
    Optional ByVal ativId As String = "" _
) As String
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim disponibilidade As String
    Dim strikesNota As Long
    Dim strikesRecusa As Long

    On Error GoTo falha

    emp = LerEmpresa(RRS_Pad3(empId), linhaEmp)
    If linhaEmp = 0 Then
        RRS_AvisoOperacionalEmpresaCurto = "Aviso operacional: EMPRESA NAO ENCONTRADA"
        Exit Function
    End If

    disponibilidade = RRS_DisponibilidadeOperacionalEmpresa(emp.EMP_ID, statusCred, ativId)
    strikesNota = RRS_StrikesNotaBaixa(emp.EMP_ID, emp.STATUS_GLOBAL)
    strikesRecusa = RRS_StrikesRecusaPrazo(emp.EMP_ID)

    RRS_AvisoOperacionalEmpresaCurto = "Aviso operacional: " & RRS_StatusGlobalHumano(emp.STATUS_GLOBAL) & _
        "; " & disponibilidade & _
        "; NB=" & CStr(strikesNota) & _
        "; RP=" & CStr(strikesRecusa)
    Exit Function

falha:
    RRS_AvisoOperacionalEmpresaCurto = "Aviso operacional: DIAGNOSTICO INDISPONIVEL"
End Function

Public Function RRS_ParticipaRodizioHumano(ByVal participaCodigo As String) As String
    Dim cod As String

    cod = UCase$(Trim$(participaCodigo))
    Select Case cod
        Case "SIM"
            RRS_ParticipaRodizioHumano = "SIM - APTA"
        Case "REATIVAVEL"
            RRS_ParticipaRodizioHumano = "REATIVAVEL - PRAZO VENCIDO"
        Case "NAO_SUSPENSA"
            RRS_ParticipaRodizioHumano = "NAO - SUSPENSA"
        Case "NAO_CRED_INATIVO"
            RRS_ParticipaRodizioHumano = "NAO - CREDENCIAMENTO INATIVO"
        Case "NAO_INATIVA"
            RRS_ParticipaRodizioHumano = "NAO - EMPRESA INATIVA"
        Case "NAO_EMPRESA_NAO_ENCONTRADA"
            RRS_ParticipaRodizioHumano = "NAO - EMPRESA NAO ENCONTRADA"
        Case ""
            RRS_ParticipaRodizioHumano = "NAO INFORMADO"
        Case Else
            If Left$(cod, 18) = "NAO_STATUS_GLOBAL=" Then
                RRS_ParticipaRodizioHumano = "NAO - " & Mid$(cod, 19)
            Else
                RRS_ParticipaRodizioHumano = cod
            End If
    End Select
End Function

Public Function RRS_ParticipaRodizioHumanoPorEmpresa( _
    ByVal statusCred As String, _
    ByVal statusGlobal As String, _
    ByVal dtFimSusp As Date _
) As String
    RRS_ParticipaRodizioHumanoPorEmpresa = RRS_ParticipaRodizioHumano( _
        RRS_ParticipaRodizioTexto(statusCred, statusGlobal, dtFimSusp))
End Function

Public Function RRS_ParticipaRodizioTexto( _
    ByVal statusCred As String, _
    ByVal statusGlobal As String, _
    ByVal dtFimSusp As Date _
) As String
    Dim stCred As String
    Dim stGlobal As String

    stCred = UCase$(Trim$(statusCred))
    stGlobal = UCase$(Trim$(statusGlobal))

    If stCred <> STATUS_CRED_ATIVO Then
        RRS_ParticipaRodizioTexto = "NAO_CRED_INATIVO"
    ElseIf stGlobal = STATUS_EMP_ATIVA Then
        RRS_ParticipaRodizioTexto = "SIM"
    ElseIf stGlobal = STATUS_EMP_SUSPENSA Then
        If dtFimSusp > CDate(0) And dtFimSusp <= Date Then
            RRS_ParticipaRodizioTexto = "REATIVAVEL"
        Else
            RRS_ParticipaRodizioTexto = "NAO_SUSPENSA"
        End If
    ElseIf stGlobal = STATUS_EMP_INATIVA Then
        RRS_ParticipaRodizioTexto = "NAO_INATIVA"
    Else
        RRS_ParticipaRodizioTexto = "NAO_STATUS_GLOBAL=" & stGlobal
    End If
End Function

Public Function RRS_GerarRelatorioStatusPorServico(Optional ByVal mostrarMensagem As Boolean = True) As TResult
    Dim res As TResult
    Dim wsServ As Worksheet
    Dim wsCred As Worksheet
    Dim wsRpt As Worksheet
    Dim ultServ As Long
    Dim ultCred As Long
    Dim linhaServ As Long
    Dim linhaCred As Long
    Dim linhaOut As Long
    Dim ativId As String
    Dim servId As String
    Dim codAtivServ As String
    Dim empId As String
    Dim statusCred As String
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim participa As String
    Dim qtdCred As Long
    Dim qtdAptas As Long
    Dim qtdSuspensas As Long
    Dim qtdInativas As Long
    Dim qtdCredInativo As Long
    Dim listaAptas As String
    Dim listaSuspensas As String
    Dim proximoRetorno As Date
    Dim retornoTexto As String
    Dim alerta As String
    Dim totalServicos As Long
    Dim totalSemApta As Long

    On Error GoTo falha

    Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    Set wsCred = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    Set wsRpt = RRS_PegarOuCriarAba(RRS_SHEET)

    wsRpt.Cells.Clear
    wsRpt.PageSetup.PrintArea = ""

    wsRpt.Cells(1, 1).Value = "ATIV_ID"
    wsRpt.Cells(1, 2).Value = "SERV_ID"
    wsRpt.Cells(1, 3).Value = "SERVICO"
    wsRpt.Cells(1, 4).Value = "QTD_CRED"
    wsRpt.Cells(1, 5).Value = "QTD_APTAS"
    wsRpt.Cells(1, 6).Value = "QTD_SUSPENSAS"
    wsRpt.Cells(1, 7).Value = "QTD_INATIVAS"
    wsRpt.Cells(1, 8).Value = "QTD_CRED_INATIVO"
    wsRpt.Cells(1, 9).Value = "EMPRESAS_APTAS"
    wsRpt.Cells(1, 10).Value = "EMPRESAS_SUSPENSAS"
    wsRpt.Cells(1, 11).Value = "PROXIMO_RETORNO"
    wsRpt.Cells(1, 12).Value = "ALERTA"

    linhaOut = 2
    ultServ = UltimaLinhaAba(SHEET_CAD_SERV)
    ultCred = UltimaLinhaAba(SHEET_CREDENCIADOS)

    For linhaServ = LINHA_DADOS To ultServ
        ativId = RRS_Pad3(wsServ.Cells(linhaServ, COL_SERV_ATIV_ID).Value)
        servId = RRS_Pad3(wsServ.Cells(linhaServ, COL_SERV_ID).Value)
        If ativId = "" Or servId = "" Then GoTo ProximoServico

        codAtivServ = ativId & servId
        qtdCred = 0
        qtdAptas = 0
        qtdSuspensas = 0
        qtdInativas = 0
        qtdCredInativo = 0
        listaAptas = ""
        listaSuspensas = ""
        proximoRetorno = CDate(0)

        For linhaCred = LINHA_DADOS To ultCred
            If RRS_CodAtivServIgual(wsCred.Cells(linhaCred, COL_CRED_COD_ATIV_SERV).Value, codAtivServ) Then
                qtdCred = qtdCred + 1
                empId = RRS_Pad3(wsCred.Cells(linhaCred, COL_CRED_EMP_ID).Value)
                statusCred = Trim$(CStr(wsCred.Cells(linhaCred, COL_CRED_STATUS).Value))
                emp = LerEmpresa(empId, linhaEmp)

                If linhaEmp = 0 Then
                    qtdInativas = qtdInativas + 1
                Else
                    participa = RRS_ParticipaRodizioTexto(statusCred, emp.STATUS_GLOBAL, emp.DT_FIM_SUSP)
                    Select Case participa
                        Case "SIM", "REATIVAVEL"
                            qtdAptas = qtdAptas + 1
                            RRS_AddLista listaAptas, emp.EMP_ID & ":" & emp.RAZAO_NOME
                        Case "NAO_SUSPENSA"
                            qtdSuspensas = qtdSuspensas + 1
                            retornoTexto = RRS_RetornoPrevistoTexto(emp.STATUS_GLOBAL, emp.DT_FIM_SUSP)
                            RRS_AddLista listaSuspensas, emp.EMP_ID & ":" & emp.RAZAO_NOME & _
                                "(DIAS=" & CStr(RRS_DiasRestantesSuspensao(emp.STATUS_GLOBAL, emp.DT_FIM_SUSP)) & _
                                "; RETORNO=" & retornoTexto & ")"
                            If emp.DT_FIM_SUSP > CDate(0) Then
                                If proximoRetorno = CDate(0) Or emp.DT_FIM_SUSP < proximoRetorno Then proximoRetorno = emp.DT_FIM_SUSP
                            End If
                        Case "NAO_INATIVA"
                            qtdInativas = qtdInativas + 1
                        Case Else
                            qtdCredInativo = qtdCredInativo + 1
                    End Select
                End If
            End If
        Next linhaCred

        If qtdCred = 0 Then
            alerta = "SEM_CREDENCIADOS"
        ElseIf qtdAptas = 0 Then
            alerta = "SEM_EMPRESA_APTA"
            totalSemApta = totalSemApta + 1
        Else
            alerta = "OK"
        End If

        wsRpt.Cells(linhaOut, 1).Value = ativId
        wsRpt.Cells(linhaOut, 2).Value = servId
        wsRpt.Cells(linhaOut, 3).Value = Trim$(CStr(wsServ.Cells(linhaServ, COL_SERV_DESCRICAO).Value))
        wsRpt.Cells(linhaOut, 4).Value = qtdCred
        wsRpt.Cells(linhaOut, 5).Value = qtdAptas
        wsRpt.Cells(linhaOut, 6).Value = qtdSuspensas
        wsRpt.Cells(linhaOut, 7).Value = qtdInativas
        wsRpt.Cells(linhaOut, 8).Value = qtdCredInativo
        wsRpt.Cells(linhaOut, 9).Value = listaAptas
        wsRpt.Cells(linhaOut, 10).Value = listaSuspensas
        If proximoRetorno > CDate(0) Then wsRpt.Cells(linhaOut, 11).Value = proximoRetorno
        wsRpt.Cells(linhaOut, 12).Value = alerta

        totalServicos = totalServicos + 1
        linhaOut = linhaOut + 1

ProximoServico:
    Next linhaServ

    If totalServicos > 0 Then
        Call Rel_FormatarCabecalho(wsRpt, 12, 1)
        Call Rel_FormatarDados(wsRpt, 2, linhaOut - 1, 12)
        wsRpt.Columns("A:L").AutoFit
    End If
    Call Rel_ConfigurarPagina(wsRpt, "RELATORIO DE STATUS DO RODIZIO POR SERVICO", "L", False, xlLandscape)
    If totalServicos > 0 Then
        Call Rel_DefinirAreaImpressao(wsRpt, wsRpt.Range("A1:L" & CStr(linhaOut - 1)))
    End If

    res.sucesso = True
    res.mensagem = "Relatorio " & RRS_SHEET & " gerado. SERVICOS=" & CStr(totalServicos) & "; SEM_EMPRESA_APTA=" & CStr(totalSemApta)
    res.IdGerado = RRS_SHEET
    If mostrarMensagem Then MsgBox res.mensagem, vbInformation, "Relatorio"
    RRS_GerarRelatorioStatusPorServico = res
    Exit Function

falha:
    res.sucesso = False
    res.mensagem = "Erro ao gerar relatorio de status do rodizio: " & Err.Description
    res.CodigoErro = Err.Number
    If mostrarMensagem Then MsgBox res.mensagem, vbCritical, "Relatorio"
    RRS_GerarRelatorioStatusPorServico = res
End Function

Private Function RRS_UltimaDataEventoEmpresa(ByVal empId As String, ByVal tipoEvento As Long) As Date
    Dim wsAudit As Worksheet
    Dim linha As Long
    Dim alvo As String
    Dim idAudit As String
    Dim dtEvento As Variant

    On Error GoTo fim

    alvo = RRS_Pad3(empId)
    If alvo = "" Then GoTo fim

    Set wsAudit = ThisWorkbook.Sheets(SHEET_AUDIT)
    For linha = UltimaLinhaAba(SHEET_AUDIT) To LINHA_DADOS Step -1
        If CLng(Val(wsAudit.Cells(linha, COL_AUDIT_TIPO).Value)) = tipoEvento Then
            idAudit = RRS_Pad3(wsAudit.Cells(linha, COL_AUDIT_ID_AFETADO).Value)
            If idAudit = alvo Then
                dtEvento = wsAudit.Cells(linha, COL_AUDIT_DT).Value
                If IsDate(dtEvento) Then
                    RRS_UltimaDataEventoEmpresa = CDate(dtEvento)
                    Exit Function
                End If
            End If
        End If
    Next linha

fim:
End Function

Private Function RRS_UltimoStrikeSuspensaoAudit(ByVal empId As String) As Long
    Dim wsAudit As Worksheet
    Dim linha As Long
    Dim alvo As String
    Dim idAudit As String
    Dim depois As String
    Dim qtd As Long

    On Error GoTo fim

    alvo = RRS_Pad3(empId)
    If alvo = "" Then GoTo fim

    Set wsAudit = ThisWorkbook.Sheets(SHEET_AUDIT)
    For linha = UltimaLinhaAba(SHEET_AUDIT) To LINHA_DADOS Step -1
        If CLng(Val(wsAudit.Cells(linha, COL_AUDIT_TIPO).Value)) = CLng(EVT_SUSPENSAO) Then
            idAudit = RRS_Pad3(wsAudit.Cells(linha, COL_AUDIT_ID_AFETADO).Value)
            If idAudit = alvo Then
                depois = CStr(wsAudit.Cells(linha, COL_AUDIT_DEPOIS).Value)
                If InStr(1, depois, "ORIGEM=STRIKE", vbTextCompare) > 0 Then
                    qtd = RRS_ExtrairLongAposChave(depois, "STRIKES=")
                    If qtd > 0 Then
                        RRS_UltimoStrikeSuspensaoAudit = qtd
                        Exit Function
                    End If
                End If
            End If
        End If
    Next linha

fim:
End Function

Private Function RRS_ExtrairLongAposChave(ByVal texto As String, ByVal chave As String) As Long
    Dim pos As Long
    Dim i As Long
    Dim c As String
    Dim digitos As String

    pos = InStr(1, texto, chave, vbTextCompare)
    If pos <= 0 Then Exit Function

    i = pos + Len(chave)
    Do While i <= Len(texto)
        c = Mid$(texto, i, 1)
        If c < "0" Or c > "9" Then Exit Do
        digitos = digitos & c
        i = i + 1
    Loop

    If Len(digitos) > 0 Then RRS_ExtrairLongAposChave = CLng(Val(digitos))
End Function

Private Function RRS_PegarOuCriarAba(ByVal nomeAba As String) As Worksheet
    On Error Resume Next
    Set RRS_PegarOuCriarAba = ThisWorkbook.Sheets(nomeAba)
    On Error GoTo 0

    If RRS_PegarOuCriarAba Is Nothing Then
        Set RRS_PegarOuCriarAba = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Sheets(ThisWorkbook.Sheets.count))
        RRS_PegarOuCriarAba.Name = nomeAba
    End If
End Function

Private Function RRS_Pad3(ByVal v As Variant) As String
    Dim s As String

    s = Trim$(CStr(v))
    If s = "" Then
        RRS_Pad3 = ""
    ElseIf IsNumeric(s) Then
        RRS_Pad3 = Format$(CLng(Val(s)), "000")
    Else
        RRS_Pad3 = s
    End If
End Function

Private Function RRS_NormalizarCodAtivServ(ByVal v As Variant) As String
    Dim s As String

    s = UCase$(Trim$(CStr(v)))
    s = Replace$(s, " ", "")
    s = Replace$(s, "|", "")
    If s = "" Then
        RRS_NormalizarCodAtivServ = ""
    ElseIf IsNumeric(s) Then
        RRS_NormalizarCodAtivServ = Format$(CLng(Val(s)), "000000")
    Else
        RRS_NormalizarCodAtivServ = s
    End If
End Function

Private Function RRS_CodAtivServIgual(ByVal origem As Variant, ByVal alvo As String) As Boolean
    RRS_CodAtivServIgual = (RRS_NormalizarCodAtivServ(origem) = RRS_NormalizarCodAtivServ(alvo))
End Function

Private Sub RRS_AddLista(ByRef lista As String, ByVal item As String)
    item = Trim$(item)
    If item = "" Then Exit Sub

    If lista = "" Then
        lista = item
    Else
        lista = lista & " | " & item
    End If
End Sub


