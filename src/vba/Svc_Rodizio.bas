Attribute VB_Name = "Svc_Rodizio"
Option Explicit

' Serviço de Rodízio Centralizado — V10
' Implementa: SelecionarEmpresa, AvancarFila, Suspender, Reativar.
' Sem Select/ActiveCell/On Error Resume Next silencioso.
' Referência: doc/Time_AI/001-Sprint0-Maquina-de-Estados.md (seção 4 - Algoritmo)

' ============================================================
' CONSTANTES DE STATUS (evitar strings literais espalhadas)
' ============================================================
Private Const STATUS_EMP_ATIVA As String = "ATIVA"
Private Const STATUS_EMP_SUSPENSA As String = "SUSPENSA_GLOBAL"
Private Const STATUS_EMP_INATIVA As String = "INATIVA"
Private Const STATUS_CRED_ATIVO As String = "ATIVO"
Private Const MOTIVO_SEM_CREDENCIADOS As String = "SEM_CREDENCIADOS_APTOS"
Private Const MOTIVO_OS_ABERTA As String = "OS_ABERTA_NA_ATIVIDADE"

' ============================================================
' SEÇÃO 1: SELEÇÃO (Algoritmo Central de Rodízio)
' ============================================================

' SelecionarEmpresa — executa o algoritmo de rodízio para uma atividade.
'
' Algoritmo (conforme Máquina de Estados v1.0):
'   1. Buscar fila da atividade (CREDENCIADOS ordenados por POSICAO_FILA)
'   2. Para cada empresa na fila:
'      a. STATUS_CRED <> ATIVO → pular (sem punição)
'      b. STATUS_GLOBAL = SUSPENSA_GLOBAL → verificar reativação automática
'         - Se DT_FIM_SUSPENSAO <= Hoje → reativar e continuar avaliação
'         - Senão → pular (sem punição)
'      c. TemOSAbertaNaAtividade → mover para fim da fila SEM punição, pular
'      d. Empresa apta → registrar indicação (DT_ULTIMA_IND), retornar
'   3. Nenhuma apta → retornar Encontrou=False
'
' Nota: O avanço de fila definitivo (após aceite/recusa/expiração)
'       é responsabilidade de Svc_PreOS (Sprint 3), via AvancarFila().
'
Public Function SelecionarEmpresa(ByVal ATIV_ID As String) As TRodizioResultado
    Dim resultado As TRodizioResultado
    Dim fila() As TCredenciamento
    Dim cred As TCredenciamento
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim resOp As TResult
    Dim i As Long
    Dim cntFiltroA As Long
    Dim cntFiltroB As Long
    Dim cntFiltroC As Long
    Dim cntFiltroD As Long
    Dim cntFiltroE As Long
    Dim cntSemEmpresa As Long

    On Error GoTo Erro

    resultado.encontrou = False
    resultado.MotivoFalha = MOTIVO_SEM_CREDENCIADOS

    fila = BuscarFila(ATIV_ID)

    ' Verificar se a fila está vazia (sentinela: CRED_ID = "")
    If fila(LBound(fila)).CRED_ID = "" Then
        resultado.MotivoFalha = "SEM_CREDENCIADOS_CADASTRADOS"
        SelecionarEmpresa = resultado
        Exit Function
    End If

    For i = LBound(fila) To UBound(fila)
        cred = fila(i)

        ' FILTRO A: Credenciamento inativo/suspenso localmente → pular
        If cred.STATUS_CRED <> STATUS_CRED_ATIVO Then
            cntFiltroA = cntFiltroA + 1
            GoTo ProximaEmpresa
        End If

        ' Ler dados atuais da empresa na planilha
        emp = LerEmpresa(cred.EMP_ID, linhaEmp)

        If linhaEmp = 0 Then
            cntSemEmpresa = cntSemEmpresa + 1
            GoTo ProximaEmpresa  ' empresa não encontrada
        End If

        ' FILTRO B: Empresa suspensa globalmente
        If emp.STATUS_GLOBAL = STATUS_EMP_SUSPENSA Then
            ' Verificar reativação automática
            If emp.DT_FIM_SUSP > CDate(0) And emp.DT_FIM_SUSP <= Date Then
                ' Reativar automaticamente — empresa volta a participar
                resOp = Reativar(cred.EMP_ID)
                If Not resOp.Sucesso Then
                    cntFiltroB = cntFiltroB + 1
                    GoTo ProximaEmpresa
                End If
                ' Reler dados após reativação
                emp = LerEmpresa(cred.EMP_ID, linhaEmp)
            Else
                ' Ainda suspensa → pular sem punição
                cntFiltroB = cntFiltroB + 1
                GoTo ProximaEmpresa
            End If
        End If

        ' FILTRO C: Empresa inativa → pular
        If emp.STATUS_GLOBAL = STATUS_EMP_INATIVA Then
            cntFiltroC = cntFiltroC + 1
            GoTo ProximaEmpresa
        End If

        ' FILTRO D: Empresa tem OS aberta nesta atividade → pular SEM punição, mover para fim
        If TemOSAbertaNaAtividade(cred.EMP_ID, ATIV_ID) Then
            resOp = MoverFinal(cred.EMP_ID, ATIV_ID)
            ' Sem auditoria aqui — não é punição, é skip técnico
            cntFiltroD = cntFiltroD + 1
            GoTo ProximaEmpresa
        End If

        ' FILTRO E: Empresa tem Pre-OS pendente (AGUARDANDO_ACEITE) nesta atividade → pular SEM punição, SEM mover
        If TemPreOSPendenteNaAtividade(cred.EMP_ID, ATIV_ID) Then
            cntFiltroE = cntFiltroE + 1
            GoTo ProximaEmpresa
        End If

        ' EMPRESA APTA: selecionar
        resultado.encontrou = True
        resultado.MotivoFalha = ""
        resultado.Empresa = emp
        resultado.Credenciamento = cred

        ' Registrar indicação: atualizar DT_ULTIMA_IND sem mover na fila
        ' (a empresa permanece no topo até aceitar/recusar — Svc_PreOS avança depois)
        RegistrarIndicacao cred.EMP_ID, ATIV_ID, Now

        ' Nota: NÃO gravar auditoria aqui. A auditoria de emissão de Pré-OS
        ' é responsabilidade de Svc_PreOS.EmitirPreOS() (Sprint 3).
        ' SelecionarEmpresa é apenas a seleção do candidato.

        SelecionarEmpresa = resultado
        Exit Function

ProximaEmpresa:
    Next i

    ' Nenhuma empresa apta encontrada
    resultado.encontrou = False
    resultado.MotivoFalha = MontarMotivoSemAptos(cntFiltroA, cntFiltroB, cntFiltroC, cntFiltroD, cntFiltroE, cntSemEmpresa)
    SelecionarEmpresa = resultado
    Exit Function

Erro:
    resultado.encontrou = False
    resultado.MotivoFalha = "ERRO_INTERNO: " & Err.Description
    SelecionarEmpresa = resultado
End Function

' ============================================================
' SEÇÃO 2: AVANÇO DE FILA (chamado por Svc_PreOS no Sprint 3)
' ============================================================

' AvancarFila — move empresa para o fim da fila após aceite, recusa ou expiração.
'
' Parâmetros:
'   EMP_ID   : empresa a mover
'   ATIV_ID  : atividade (fila específica)
'   IsPunido : True  = recusa ou expiração → incrementar QTD_RECUSAS e verificar suspensão
'              False = aceite ou OS aberta → apenas mover, sem punição
'   Motivo   : string descritiva para auditoria (ex.: "RECUSA_EXPLICITA", "PRAZO_EXPIRADO",
'              "ACEITE_OS_EMITIDA", "OS_ABERTA_NA_ATIVIDADE")
'
Public Function AvancarFila( _
    ByVal EMP_ID As String, _
    ByVal ATIV_ID As String, _
    ByVal IsPunido As Boolean, _
    ByVal motivo As String _
) As TResult
    Dim res As TResult
    Dim resMove As TResult
    Dim resRec As TResult
    Dim resRollbackFila As TResult
    Dim cfg As TConfig
    Dim resSusp As TResult
    Dim novaRecusaGlobal As Long
    Dim tipoEvento As Long
    Dim linhaCredOriginal As Long
    Dim credOriginal As TCredenciamento
    Dim posicaoOriginal As Long

    On Error GoTo Erro

    credOriginal = BuscarPorEmpresaAtividade(EMP_ID, ATIV_ID, linhaCredOriginal)
    If linhaCredOriginal > 0 Then posicaoOriginal = credOriginal.POSICAO_FILA

    ' 1. Mover para o fim da fila
    resMove = MoverFinal(EMP_ID, ATIV_ID, Now)

    If Not resMove.Sucesso Then
        res.Sucesso = False
        res.Mensagem = "Falha ao mover fila: " & resMove.Mensagem
        AvancarFila = res
        Exit Function
    End If

    ' 2. Se punido: incrementar contadores e verificar suspensão
    If IsPunido Then
        resRec = IncrementarRecusa(EMP_ID, ATIV_ID)

        If Not resRec.Sucesso Then
            If linhaCredOriginal > 0 Then
                resRollbackFila = RestaurarPosicaoFila(EMP_ID, ATIV_ID, posicaoOriginal, credOriginal.DT_ULTIMA_IND)
                RegistrarEvento _
                    EVT_TRANSACAO, ENT_CRED, EMP_ID, _
                    "EMP=" & EMP_ID & "; ATIV=" & ATIV_ID & "; POS_ANTES=" & CStr(posicaoOriginal), _
                    "ROLLBACK_FILA=" & IIf(resRollbackFila.Sucesso, "OK", "FALHOU") & _
                    "; MOTIVO=INCREMENTAR_RECUSA_FALHOU; MSG=" & resRec.Mensagem, _
                    "Svc_Rodizio"
            End If
            res.Sucesso = False
            res.Mensagem = "Falha ao incrementar recusa: " & resRec.Mensagem
            AvancarFila = res
            Exit Function
        End If

        If resRec.Sucesso Then
            ' Evita depender de campos de TResult em projetos antigos; lê o valor persistido.
            Dim empTmp As TEmpresa
            Dim linhaEmpTmp As Long
            empTmp = LerEmpresa(EMP_ID, linhaEmpTmp)
            If linhaEmpTmp > 0 Then
                novaRecusaGlobal = empTmp.QTD_RECUSAS
            Else
                novaRecusaGlobal = 0
            End If

            cfg = GetConfig()

            If novaRecusaGlobal >= cfg.MAX_RECUSAS Then
                resSusp = Suspender(EMP_ID)
                ' Suspensão registra sua própria auditoria
            End If

            ' Auditoria do avanço com punição (dentro do If Sucesso)
            ' Selecionar evento correto: RECUSADA vs EXPIRADA
            If InStr(1, motivo, "EXPIRAD", vbTextCompare) > 0 Then
                tipoEvento = EVT_PREOS_EXPIRADA
            Else
                tipoEvento = EVT_PREOS_RECUSADA
            End If

            RegistrarEvento _
                tipoEvento, ENT_CRED, EMP_ID, _
                "QTD_RECUSAS_ANTERIOR=" & CStr(novaRecusaGlobal - 1), _
                "MOTIVO=" & motivo & "; QTD_RECUSAS_GLOBAL=" & novaRecusaGlobal & "; ATIV=" & ATIV_ID, _
                "Svc_Rodizio"
        End If
    End If

    res.Sucesso = True
    res.Mensagem = "Fila avancada. EMP=" & EMP_ID & " ATIV=" & ATIV_ID & " PUNIDO=" & CStr(IsPunido)
    res.IdGerado = EMP_ID
    AvancarFila = res
    Exit Function

Erro:
    res.Sucesso = False
    res.Mensagem = "Erro em AvancarFila: " & Err.Description
    res.CodigoErro = Err.Number
    AvancarFila = res
End Function

' ============================================================
' SEÇÃO 3: SUSPENSÃO E REATIVAÇÃO
' ============================================================

' Suspender — coloca empresa em SUSPENSA_GLOBAL.
' Chamada automaticamente por AvancarFila quando MAX_RECUSAS é atingido.
' Pode também ser chamada manualmente pelo gestor (futuro Sprint 4).
'
Public Function Suspender( _
    ByVal EMP_ID As String, _
    Optional ByVal diasSuspensao As Long = 0, _
    Optional ByVal motivo As String = "" _
) As TResult
    Dim res As TResult
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim cfg As TConfig
    Dim dtFimSusp As Date
    Dim base As String
    Dim baseTexto As String

    On Error GoTo Erro

    emp = LerEmpresa(EMP_ID, linhaEmp)

    If linhaEmp = 0 Then
        res.Sucesso = False
        res.Mensagem = "Empresa nao encontrada: EMP_ID=" & EMP_ID
        Suspender = res
        Exit Function
    End If

    If emp.STATUS_GLOBAL = STATUS_EMP_SUSPENSA Then
        ' Já suspensa: não fazer nada (idempotente)
        res.Sucesso = True
        res.Mensagem = "Empresa ja estava suspensa."
        Suspender = res
        Exit Function
    End If

    ' V12.0.0203 ONDA 1 — Suspensao em dias quando informado;
    ' fallback historico em meses (PERIODO_SUSPENSAO_MESES) quando nao.
    ' Compatibilidade: chamadores antigos sem parametros continuam usando meses.
    If diasSuspensao > 0 Then
        dtFimSusp = DateAdd("d", diasSuspensao, Date)
        base = "DIAS"
        baseTexto = "DIAS=" & CStr(diasSuspensao)
    Else
        cfg = GetConfig()
        dtFimSusp = DateAdd("m", cfg.PERIODO_SUSPENSAO_MESES, Date)
        base = "MESES"
        baseTexto = "MESES=" & cfg.PERIODO_SUSPENSAO_MESES
    End If

    ' Gravar status de suspensão
    GravarStatusEmpresa linhaEmp, STATUS_EMP_SUSPENSA, dtFimSusp, -1

    ' Auditoria
    RegistrarEvento _
        EVT_SUSPENSAO, ENT_EMP, EMP_ID, _
        "STATUS=" & emp.STATUS_GLOBAL, _
        "STATUS=SUSPENSA_GLOBAL; DT_FIM_SUSP=" & Format$(dtFimSusp, "DD/MM/YYYY") & _
        "; BASE=" & base & "; " & baseTexto & _
        IIf(Trim$(motivo) = "", "", "; MOTIVO=" & motivo), _
        "Svc_Rodizio"

    res.Sucesso = True
    res.Mensagem = "Empresa EMP_ID=" & EMP_ID & " suspensa ate " & Format$(dtFimSusp, "DD/MM/YYYY") & _
                   " (BASE=" & base & ")"
    res.IdGerado = EMP_ID
    Suspender = res
    Exit Function

Erro:
    res.Sucesso = False
    res.Mensagem = "Erro em Suspender: " & Err.Description
    res.CodigoErro = Err.Number
    Suspender = res
End Function

' Reativar — reverte suspensão global de uma empresa.
' Chamada automaticamente por SelecionarEmpresa quando DT_FIM_SUSPENSAO <= Hoje.
' Pode também ser chamada pelo gestor antes do prazo (futuro Sprint 4).
'
Public Function Reativar(ByVal EMP_ID As String) As TResult
    Dim res As TResult
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim statusAnterior As String

    On Error GoTo Erro

    emp = LerEmpresa(EMP_ID, linhaEmp)

    If linhaEmp = 0 Then
        res.Sucesso = False
        res.Mensagem = "Empresa nao encontrada: EMP_ID=" & EMP_ID
        Reativar = res
        Exit Function
    End If

    statusAnterior = emp.STATUS_GLOBAL

    ' Zerar QTD_RECUSAS_GLOBAL e remover DT_FIM_SUSPENSAO; STATUS → ATIVA
    GravarStatusEmpresa linhaEmp, STATUS_EMP_ATIVA, CDate(0), 0

    ' Auditoria
    RegistrarEvento _
        EVT_REATIVACAO, ENT_EMP, EMP_ID, _
        "STATUS=" & statusAnterior & "; QTD_RECUSAS=" & emp.QTD_RECUSAS, _
        "STATUS=ATIVA; QTD_RECUSAS_GLOBAL=0; DT_FIM_SUSP=(limpa)", _
        "Svc_Rodizio"

    res.Sucesso = True
    res.Mensagem = "Empresa EMP_ID=" & EMP_ID & " reativada."
    res.IdGerado = EMP_ID
    Reativar = res
    Exit Function

Erro:
    res.Sucesso = False
    res.Mensagem = "Erro em Reativar: " & Err.Description
    res.CodigoErro = Err.Number
    Reativar = res
End Function

' ============================================================
' SEÇÃO 4: HELPERS PRIVADOS
' ============================================================

' Registra a data de indicação na linha do credenciamento sem mover a posição.
' Chamado quando uma empresa é selecionada pelo rodízio.
Private Sub RegistrarIndicacao( _
    ByVal EMP_ID As String, _
    ByVal ATIV_ID As String, _
    ByVal dtIndicacao As Date _
)
    Dim ws As Worksheet
    Dim i As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim abaPreparada As Boolean

    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then GoTo fim
    abaPreparada = True

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If IdsIguais(ws.Cells(i, COL_CRED_EMP_ID).Value, EMP_ID) And _
           IdsIguais(ws.Cells(i, COL_CRED_ATIV_ID).Value, ATIV_ID) Then
            ws.Cells(i, COL_CRED_DT_ULT_IND).Value = dtIndicacao
            Exit For
        End If
    Next i

    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    abaPreparada = False

fim:
    On Error Resume Next
    If abaPreparada Then Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
End Sub

' IdsIguais removida — usar Util_Planilha.IdsIguais (V12-CLEAN).

Private Function MontarMotivoSemAptos( _
    ByVal cntA As Long, _
    ByVal cntB As Long, _
    ByVal cntC As Long, _
    ByVal cntD As Long, _
    ByVal cntE As Long, _
    ByVal cntSemEmp As Long _
) As String
    Dim motivo As String

    motivo = MOTIVO_SEM_CREDENCIADOS & _
             ";A=" & CStr(cntA) & _
             ";B=" & CStr(cntB) & _
             ";C=" & CStr(cntC) & _
             ";D=" & CStr(cntD) & _
             ";E=" & CStr(cntE) & _
             ";SEM_EMP=" & CStr(cntSemEmp)

    If cntE > 0 Then
        If (cntA + cntB + cntC + cntD + cntSemEmp) = 0 Then
            motivo = motivo & ";BLOQUEIO=PREOS_PENDENTE"
        Else
            motivo = motivo & ";BLOQUEIO=MISTO;DETALHE=PREOS_PENDENTE_PRESENTE"
        End If
    End If
    MontarMotivoSemAptos = motivo
End Function

' ============================================================
' V12.0.0203 ONDA 4 — Diagnostico de rodizio
' ============================================================
'
' Diag_RodizioStatus(ATIV_ID) percorre BuscarFila(ATIV_ID) e produz,
' linha por linha, uma fotografia auditavel da fila atual:
'   - posicao na fila;
'   - EMP_ID, nome da empresa (quando legivel);
'   - STATUS_CRED em CREDENCIADOS;
'   - STATUS_GLOBAL em EMPRESAS;
'   - DT_FIM_SUSP da empresa;
'   - tem OS aberta na atividade?
'   - tem Pre-OS pendente na atividade?
'   - decisao prevista do SelecionarEmpresa: APTA / FILTRO_A / FILTRO_B /
'     FILTRO_C / FILTRO_D / FILTRO_E / SEM_EMPRESA.
'
' Saida: aba RPT_DIAG_RODIZIO. Substitui o conteudo a cada chamada.
' Nao altera nenhum dado operacional. Pode ser rodada a qualquer
' momento para entender por que uma empresa esta sendo pulada.

Public Sub Diag_RodizioStatus(ByVal ATIV_ID As String)
    Const SHEET_DIAG As String = "RPT_DIAG_RODIZIO"

    Dim ws As Worksheet
    Dim wsEmp As Worksheet
    Dim fila() As TCredenciamento
    Dim cred As TCredenciamento
    Dim emp As TEmpresa
    Dim linhaEmp As Long
    Dim i As Long
    Dim linha As Long
    Dim decisao As String
    Dim qtdSelecionavel As Long

    On Error GoTo falha

    ' Garantir aba.
    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets(SHEET_DIAG)
    On Error GoTo falha
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add( _
            After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
        ws.Name = SHEET_DIAG
    End If

    On Error Resume Next
    If ws.ProtectContents Then ws.Unprotect Password:=Util_SenhaProtecaoPadrao()
    ws.Cells.Clear
    On Error GoTo falha

    ws.Cells(1, 1).Value = "DIAGNOSTICO RODIZIO"
    ws.Cells(2, 1).Value = "ATIV_ID"
    ws.Cells(2, 2).Value = ATIV_ID
    ws.Cells(3, 1).Value = "GERADO_EM"
    ws.Cells(3, 2).Value = Format$(Now, "yyyy-mm-dd hh:nn:ss")
    ws.Cells(4, 1).Value = "BUILD"
    ws.Cells(4, 2).Value = APP_BUILD_IMPORTADO

    ' Cabecalho da tabela.
    ws.Cells(6, 1).Value = "POSICAO"
    ws.Cells(6, 2).Value = "EMP_ID"
    ws.Cells(6, 3).Value = "STATUS_CRED"
    ws.Cells(6, 4).Value = "STATUS_GLOBAL"
    ws.Cells(6, 5).Value = "DT_FIM_SUSP"
    ws.Cells(6, 6).Value = "OS_ABERTA?"
    ws.Cells(6, 7).Value = "PREOS_PEND?"
    ws.Cells(6, 8).Value = "DECISAO"
    ws.Cells(6, 9).Value = "EXPLICACAO"

    fila = BuscarFila(ATIV_ID)
    linha = 7
    qtdSelecionavel = 0

    If fila(LBound(fila)).CRED_ID = "" Then
        ws.Cells(linha, 1).Value = "(vazia)"
        ws.Cells(linha, 9).Value = "Nenhum credenciamento encontrado para a atividade."
    Else
        For i = LBound(fila) To UBound(fila)
            cred = fila(i)
            ws.Cells(linha, 1).Value = cred.POSICAO_FILA
            ws.Cells(linha, 2).Value = cred.EMP_ID
            ws.Cells(linha, 3).Value = cred.STATUS_CRED

            decisao = ""
            If cred.STATUS_CRED <> STATUS_CRED_ATIVO Then
                ws.Cells(linha, 4).Value = "(empresa nao consultada)"
                ws.Cells(linha, 5).Value = ""
                ws.Cells(linha, 6).Value = ""
                ws.Cells(linha, 7).Value = ""
                decisao = "FILTRO_A"
                ws.Cells(linha, 9).Value = "STATUS_CRED=" & cred.STATUS_CRED & " (esperado=" & STATUS_CRED_ATIVO & ")"
                GoTo proxLinha
            End If

            emp = LerEmpresa(cred.EMP_ID, linhaEmp)
            If linhaEmp = 0 Then
                ws.Cells(linha, 4).Value = "(empresa nao encontrada)"
                ws.Cells(linha, 5).Value = ""
                ws.Cells(linha, 6).Value = ""
                ws.Cells(linha, 7).Value = ""
                decisao = "SEM_EMPRESA"
                ws.Cells(linha, 9).Value = "EMP_ID=" & cred.EMP_ID & " nao consta em EMPRESAS"
                GoTo proxLinha
            End If

            ws.Cells(linha, 4).Value = emp.STATUS_GLOBAL
            If emp.DT_FIM_SUSP > CDate(0) Then
                ws.Cells(linha, 5).Value = Format$(emp.DT_FIM_SUSP, "dd/mm/yyyy")
            Else
                ws.Cells(linha, 5).Value = "(limpa)"
            End If

            Dim temOs As Boolean
            Dim temPre As Boolean
            temOs = TemOSAbertaNaAtividade(cred.EMP_ID, ATIV_ID)
            temPre = TemPreOSPendenteNaAtividade(cred.EMP_ID, ATIV_ID)
            ws.Cells(linha, 6).Value = IIf(temOs, "SIM", "nao")
            ws.Cells(linha, 7).Value = IIf(temPre, "SIM", "nao")

            If emp.STATUS_GLOBAL = STATUS_EMP_SUSPENSA Then
                If emp.DT_FIM_SUSP > CDate(0) And emp.DT_FIM_SUSP <= Date Then
                    decisao = "APTA_REATIVAVEL"
                    ws.Cells(linha, 9).Value = "Suspensa mas DT_FIM_SUSP <= hoje; sera reativada automaticamente"
                    qtdSelecionavel = qtdSelecionavel + 1
                Else
                    decisao = "FILTRO_B"
                    ws.Cells(linha, 9).Value = "STATUS_GLOBAL=SUSPENSA_GLOBAL ate " & Format$(emp.DT_FIM_SUSP, "dd/mm/yyyy")
                End If
            ElseIf emp.STATUS_GLOBAL = STATUS_EMP_INATIVA Then
                decisao = "FILTRO_C"
                ws.Cells(linha, 9).Value = "STATUS_GLOBAL=INATIVA"
            ElseIf temOs Then
                decisao = "FILTRO_D"
                ws.Cells(linha, 9).Value = "OS aberta nesta atividade; sera movida para fim sem punicao"
            ElseIf temPre Then
                decisao = "FILTRO_E"
                ws.Cells(linha, 9).Value = "Pre-OS AGUARDANDO_ACEITE nesta atividade"
            Else
                decisao = "APTA"
                ws.Cells(linha, 9).Value = "Empresa pode ser selecionada agora"
                qtdSelecionavel = qtdSelecionavel + 1
            End If

proxLinha:
            ws.Cells(linha, 8).Value = decisao
            linha = linha + 1
        Next i
    End If

    ws.Cells(linha + 1, 1).Value = "RESUMO"
    ws.Cells(linha + 1, 2).Value = "Aptas/Reativaveis: " & qtdSelecionavel

    ws.Columns("A:I").AutoFit
    On Error Resume Next
    ws.Protect Password:=Util_SenhaProtecaoPadrao(), UserInterfaceOnly:=True
    On Error GoTo falha

    ws.Activate
    ws.Cells(1, 1).Select

    Exit Sub

falha:
    On Error Resume Next
    MsgBox "Erro em Diag_RodizioStatus: " & Err.Description, vbExclamation, "Diagnostico Rodizio"
End Sub

Public Sub Diag_RodizioStatusInteractive()
    Dim ATIV_ID As String
    ATIV_ID = Trim$(InputBox( _
        "Informe o ATIV_ID a diagnosticar (ex.: 001):" & vbCrLf & vbCrLf & _
        "O relatorio sera gravado em RPT_DIAG_RODIZIO mostrando" & vbCrLf & _
        "qual filtro barra cada empresa credenciada.", _
        "Diagnostico de Rodizio", "001"))
    If ATIV_ID = "" Then Exit Sub
    Diag_RodizioStatus ATIV_ID
End Sub



