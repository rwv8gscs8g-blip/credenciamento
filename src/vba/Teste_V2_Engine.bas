Attribute VB_Name = "Teste_V2_Engine"
Option Explicit

' ============================================================
' Teste_V2_Engine
' Infraestrutura da bateria V2:
' - baseline canonica
' - cadastro de fixtures
' - resultado estruturado
' - catalogo semantico
' - invariantes simples de fila
' ============================================================

Public Const TV2_SHEET_RESULTADO As String = "RESULTADO_QA_V2"
Public Const TV2_SHEET_CATALOGO As String = "CATALOGO_CENARIOS_V2"
Public Const TV2_SHEET_HIST As String = "HISTORICO_QA_V2"
Public Const TV2_SHEET_ROTEIRO As String = "ROTEIRO_ASSISTIDO_V2"

Public Const TV2_STATUS_OK As String = "OK"
Public Const TV2_STATUS_FAIL As String = "FALHA"
Public Const TV2_STATUS_INFO As String = "INFO"
Public Const TV2_STATUS_MANUAL As String = "MANUAL_ASSISTIDO"

Private Const TV2_COLUNA_BOTOES_INICIO As Long = 13
Private Const TV2_EMP_STATUS_ATIVA As String = "ATIVA"
Private Const TV2_CRED_STATUS_ATIVO As String = "ATIVO"
Private Const TV2_PREOS_STATUS_AGUARDANDO As String = "AGUARDANDO_ACEITE"
Private Const TV2_PREOS_STATUS_RECUSADA As String = "RECUSADA"
Private Const TV2_PREOS_STATUS_CONVERTIDA As String = "CONVERTIDA_OS"
Private Const TV2_OS_STATUS_EXEC As String = "EM_EXECUCAO"

Private gTV2ExecucaoId As String
Private gTV2Visual As Boolean
Private gTV2Ok As Long
Private gTV2Fail As Long
Private gTV2Manual As Long
Private gTV2SnapshotExecutado As Boolean

Private gTV2AtivCanonA As String
Private gTV2AtivCanonB As String
Private gTV2AtivCanonC As String
Private gTV2AtivDescA As String
Private gTV2AtivDescB As String
Private gTV2AtivDescC As String

Public Sub TV2_InitExecucao(ByVal suite As String, Optional ByVal visual As Boolean = False)
    gTV2ExecucaoId = "TV2_" & Format$(Now, "yyyymmdd_hhnnss")
    gTV2Visual = visual
    gTV2Ok = 0
    gTV2Fail = 0
    gTV2Manual = 0
    gTV2SnapshotExecutado = False

    TV2_PrepararNavegacaoHumana
    Util_LimparFiltrosAba TV2_EnsureResultadoSheet()
    Util_LimparFiltrosAba TV2_EnsureHistoricoSheet()
    TV2_GerarCatalogoBase
    TV2_LogInfo suite, "BOOT", "Inicializar a suite V2", "Suite pronta para execucao"
End Sub

Public Sub TV2_FinalizarExecucao(ByVal suite As String)
    Dim ws As Worksheet
    Dim nr As Long
    Dim pathCsvFalhas As String
    Dim obsExportacao As String

    If gTV2Fail > 0 Then
        pathCsvFalhas = TV2_ExportarFalhasCSV(gTV2ExecucaoId)
        If pathCsvFalhas = "" Then
            obsExportacao = "Falhas encontradas, mas o CSV nao foi gerado."
        Else
            obsExportacao = "CSV de falhas gerado."
        End If
    Else
        obsExportacao = "Sem falhas; nenhum CSV exportado."
    End If

    Set ws = TV2_EnsureHistoricoSheet()
    nr = TV2_NextRow(ws, 1, 2)

    ws.Cells(nr, 1).Value = gTV2ExecucaoId
    ws.Cells(nr, 2).Value = suite
    ws.Cells(nr, 3).Value = Now
    ws.Cells(nr, 4).Value = gTV2Ok
    ws.Cells(nr, 5).Value = gTV2Fail
    ws.Cells(nr, 6).Value = gTV2Manual
    ws.Cells(nr, 7).Value = gTV2Ok + gTV2Fail + gTV2Manual
    ws.Cells(nr, 8).Value = pathCsvFalhas
    ws.Cells(nr, 9).Value = obsExportacao

    TV2_FormatarResultadoSheet
    TV2_FormatarHistoricoSheet
    TV2_AbrirResultadoExecucao gTV2ExecucaoId
    Application.StatusBar = False

    MsgBox "Suite V2 concluida." & vbCrLf & _
           "Execucao: " & gTV2ExecucaoId & vbCrLf & _
           "OK=" & CStr(gTV2Ok) & " | FALHA=" & CStr(gTV2Fail) & " | MANUAL=" & CStr(gTV2Manual) & vbCrLf & vbCrLf & _
           "CSV de falhas:" & vbCrLf & IIf(Len(pathCsvFalhas) > 0, pathCsvFalhas, "Nao exportado") & vbCrLf & vbCrLf & _
           obsExportacao, _
           IIf(gTV2Fail = 0, vbInformation, vbExclamation), "Testes V2"
End Sub

Public Sub TV2_LogAssert( _
    ByVal suite As String, _
    ByVal cenarioId As String, _
    ByVal automacao As String, _
    ByVal objetivo As String, _
    ByVal esperado As String, _
    ByVal obtido As String, _
    ByVal significado As String, _
    ByVal condicao As Boolean, _
    Optional ByVal observacao As String = "" _
)
    If condicao Then
        gTV2Ok = gTV2Ok + 1
        TV2_LogLinha suite, cenarioId, automacao, objetivo, esperado, obtido, TV2_STATUS_OK, significado, observacao
    Else
        gTV2Fail = gTV2Fail + 1
        TV2_LogLinha suite, cenarioId, automacao, objetivo, esperado, obtido, TV2_STATUS_FAIL, significado, observacao
    End If
End Sub

Public Sub TV2_LogInfo( _
    ByVal suite As String, _
    ByVal cenarioId As String, _
    ByVal objetivo As String, _
    ByVal obtido As String _
)
    TV2_LogLinha suite, cenarioId, "AUTO", objetivo, "Marco operacional registrado", obtido, TV2_STATUS_INFO, "Rastreabilidade da execucao", ""
End Sub

Public Sub TV2_LogManual( _
    ByVal suite As String, _
    ByVal cenarioId As String, _
    ByVal objetivo As String, _
    ByVal esperado As String, _
    ByVal significado As String, _
    Optional ByVal observacao As String = "" _
)
    gTV2Manual = gTV2Manual + 1
    TV2_LogLinha suite, cenarioId, "ASSISTIDO", objetivo, esperado, "Pendente de validacao humana", TV2_STATUS_MANUAL, significado, observacao
End Sub

Private Sub TV2_LogLinha( _
    ByVal suite As String, _
    ByVal cenarioId As String, _
    ByVal automacao As String, _
    ByVal objetivo As String, _
    ByVal esperado As String, _
    ByVal obtido As String, _
    ByVal statusTeste As String, _
    ByVal significado As String, _
    ByVal observacao As String _
)
    Dim ws As Worksheet
    Dim nr As Long

    Set ws = TV2_EnsureResultadoSheet()
    nr = TV2_NextRow(ws, 1, 2)

    ws.Cells(nr, 1).Value = gTV2ExecucaoId
    ws.Cells(nr, 2).Value = suite
    ws.Cells(nr, 3).Value = cenarioId
    ws.Cells(nr, 4).Value = automacao
    ws.Cells(nr, 5).Value = objetivo
    ws.Cells(nr, 6).Value = esperado
    ws.Cells(nr, 7).Value = obtido
    ws.Cells(nr, 8).Value = statusTeste
    ws.Cells(nr, 9).Value = significado
    ws.Cells(nr, 10).Value = observacao
    ws.Cells(nr, 11).Value = Now

    TV2_ApplyStatusColor ws.Cells(nr, 8), statusTeste

    If gTV2Visual Then
        ws.Activate
        ws.Cells(nr, 1).Select
        Application.StatusBar = "Testes V2: " & suite & " -> " & cenarioId & " = " & statusTeste
        TV2_PausarVisual 1
    End If
End Sub

Public Sub TV2_AbrirResultado()
    Dim ws As Worksheet
    TV2_PrepararNavegacaoHumana
    Set ws = TV2_EnsureResultadoSheet()
    TV2_FormatarResultadoSheet
    ws.Activate
    ws.Range("A2").Select
End Sub

Public Sub TV2_AbrirCatalogo()
    Dim ws As Worksheet
    TV2_PrepararNavegacaoHumana
    Set ws = TV2_EnsureCatalogoSheet()
    TV2_FormatarCatalogoSheet
    ws.Activate
    ws.Range("A2").Select
End Sub

Public Sub TV2_AbrirRoteiroAssistido()
    Dim ws As Worksheet
    TV2_PrepararNavegacaoHumana
    TV2_GerarCatalogoBase
    Set ws = TV2_EnsureRoteiroSheet()
    TV2_FormatarRoteiroSheet
    ws.Activate
    ws.Range("A2").Select
End Sub

Public Sub TV2_AbrirHistorico()
    Dim ws As Worksheet
    TV2_PrepararNavegacaoHumana
    Set ws = TV2_EnsureHistoricoSheet()
    TV2_FormatarHistoricoSheet
    ws.Activate
    ws.Range("A2").Select
End Sub

Public Sub TV2_PrepararNavegacaoHumana()
    Dim i As Long

    On Error Resume Next
    Menu_Principal.Menu_RecolherParaBateria
    For i = VBA.UserForms.Count - 1 To 0 Step -1
        If TypeName(VBA.UserForms(i)) = "Menu_Principal" Then
            VBA.UserForms(i).Hide
            Unload VBA.UserForms(i)
        End If
    Next i
    On Error GoTo 0
    Application.Visible = True
    ThisWorkbook.Activate
    DoEvents
End Sub

Public Sub TV2_ExportarUltimaExecucaoCSVs()
    Dim execucaoId As String
    Dim pathCsvFalhas As String

    execucaoId = TV2_ExecucaoEmFoco()
    If execucaoId = "" Then
        MsgBox "Nenhuma execucao V2 encontrada para exportacao.", vbInformation, "Testes V2"
        Exit Sub
    End If

    pathCsvFalhas = TV2_ExportarFalhasCSV(execucaoId)

    If pathCsvFalhas = "" Then
        MsgBox "Execucao " & execucaoId & " sem falhas. Nenhum CSV exportado.", vbInformation, "Testes V2"
    Else
        MsgBox "Execucao exportada: " & execucaoId & vbCrLf & vbCrLf & _
               "CSV de falhas:" & vbCrLf & pathCsvFalhas, _
               vbInformation, "Testes V2"
    End If
End Sub

Public Sub TV2_GerarCatalogoBase()
    Dim ws As Worksheet
    Dim nr As Long

    Set ws = TV2_EnsureCatalogoSheet()
    ws.Cells.Clear

    ws.Cells(1, 1).Value = "CENARIO_ID"
    ws.Cells(1, 2).Value = "SUITE"
    ws.Cells(1, 3).Value = "MODO"
    ws.Cells(1, 4).Value = "AUTOMACAO"
    ws.Cells(1, 5).Value = "DOMINIO"
    ws.Cells(1, 6).Value = "CENARIO"
    ws.Cells(1, 7).Value = "CONTEXTO"
    ws.Cells(1, 8).Value = "OBJETIVO"
    ws.Cells(1, 9).Value = "RESULTADO_ESPERADO"
    ws.Cells(1, 10).Value = "SIGNIFICADO"
    ws.Cells(1, 11).Value = "STATUS_ATUAL"
    ws.Cells(1, 12).Value = "OBS_OPERACIONAL"

    nr = 2
    TV2_AddCatalogo ws, nr, "SMK_001", "SMOKE", "RAPIDO", "AUTO", "Baseline", "Fila inicial canonica", "Base operacional limpa; configuracao canonica; servicos padrao garantidos; 3 empresas credenciadas no item A", "Validar baseline e setup deterministico", "Fila inicial 001,002,003", "Garante ponto de partida repetivel", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "SMK_002", "SMOKE", "RAPIDO", "AUTO", "Rodizio", "Selecionar empresa do topo", "Fila canonica sem bloqueios", "Provar o contrato minimo do rodizio", "Seleciona EMP_ID=001", "Valida o fluxo central de indicacao", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "SMK_003", "SMOKE", "RAPIDO", "AUTO", "Pre-OS", "Emitir Pre-OS basica", "Entidade valida; atividade valida; quantidade positiva", "Validar persistencia minima de PRE_OS", "STATUS=AGUARDANDO_ACEITE e VL_EST coerente", "Confirma emissao basica sem UI", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "SMK_004", "SMOKE", "RAPIDO", "AUTO", "Rodizio", "Pre-OS pendente nao move fila", "Empresa do topo com PRE_OS aguardando aceite", "Validar filtro E e invariantes de nao-movimento", "Proxima indicacao retorna a segunda empresa; fila mantida", "Evita punicao indevida", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "SMK_005", "SMOKE", "RAPIDO", "AUTO", "Pre-OS", "Recusa avanca fila e pune", "PRE_OS aguardando aceite para a empresa do topo", "Validar politica de recusa com punicao", "Fila move para 002,003,001 e QTD_RECUSAS sobe", "Garante giro correto apos recusa", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "EXP_001", "SMOKE", "RAPIDO", "AUTO", "Pre-OS", "Expiracao retoma a fila corretamente", "PRE_OS aguardando aceite para a empresa do topo", "Validar expiracao com punicao e retomada correta da fila", "PRE_OS expirada; fila 002,003,001; nova indicacao retorna EMP_ID=002", "Evita bloqueio residual por pendencia vencida", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "SMK_006", "SMOKE", "RAPIDO", "AUTO", "OS", "Emitir OS converte PRE_OS", "PRE_OS valida aguardando aceite", "Validar conversao minima Pre-OS -> OS", "PRE_OS convertida; OS em execucao", "Confirma integracao entre servicos", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "SMK_007", "SMOKE", "RAPIDO", "AUTO", "Avaliacao", "Avaliar OS e concluir", "OS em execucao com notas validas", "Validar fechamento minimo da OS", "OS concluida e fila continua consistente", "Fecha o ciclo core ponta a ponta", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "CS_00", "CANONICO", "COMPLETO", "AUTO", "Setup", "Setup canônico do item triplo", "1 entidade; 1 atividade canônica; 1 serviço; 3 empresas credenciadas no item", "Validar o chão comum da suíte canônica", "Fila 001,002,003; 3 credenciamentos; serviço único", "Abre a família CS_* sobre base determinística", "AUTOMATIZADO_0203", "Executado na suíte canônica"
    TV2_AddCatalogo ws, nr, "CS_01", "CANONICO", "COMPLETO", "AUTO", "Catalogo", "Reaplicar baseline sem duplicar o serviço", "Serviço canônico já existente na atividade canônica", "Validar unicidade estrutural do item canônico", "Permanece 1 serviço 001 vinculado à atividade", "Evita duplicidade silenciosa em CAD_SERV", "AUTOMATIZADO_0203", "Executado na suíte canônica"
    TV2_AddCatalogo ws, nr, "CS_02", "CANONICO", "COMPLETO", "AUTO", "Catalogo", "Rejeitar emissão com vínculo atividade/serviço inexistente", "Entidade válida; atividade canônica; serviço inexistente", "Validar associação correta entre atividade e serviço", "Emissão falha; nenhuma PRE_OS nova", "Protege o item canônico contra associação inválida", "AUTOMATIZADO_0203", "Executado na suíte canônica"
    TV2_AddCatalogo ws, nr, "CS_03", "CANONICO", "COMPLETO", "AUTO", "Fluxo nominal", "Primeira emissão aponta para A", "Fila canônica sem bloqueios", "Validar primeira indicação do cenário canônico", "PRE_OS para EMP_ID=001", "Abre o fluxo nominal A -> B -> C", "AUTOMATIZADO_0203", "Executado na suíte canônica"
    TV2_AddCatalogo ws, nr, "CS_04", "CANONICO", "COMPLETO", "AUTO", "Fluxo nominal", "Converter a PRE_OS de A em OS", "PRE_OS emitida para A", "Validar avanço da fila após OS aberta", "OS para A; fila 002,003,001", "Prova que OS aberta desloca A para o fim", "AUTOMATIZADO_0203", "Executado na suíte canônica"
    TV2_AddCatalogo ws, nr, "CS_05", "CANONICO", "COMPLETO", "AUTO", "Fluxo nominal", "Segunda emissão aponta para B", "A com OS aberta e B/C livres", "Validar pulo técnico de A por OS aberta", "PRE_OS para EMP_ID=002", "Costura o segundo passo do fluxo nominal", "AUTOMATIZADO_0203", "Executado na suíte canônica"
    TV2_AddCatalogo ws, nr, "CS_06", "CANONICO", "COMPLETO", "AUTO", "Fluxo nominal", "Terceira emissão aponta para C", "A com OS aberta; B com PRE_OS pendente", "Validar bloqueios acumulados sem mover indevidamente a fila", "PRE_OS para EMP_ID=003", "Fecha o núcleo A -> B -> C do item canônico", "AUTOMATIZADO_0203", "Executado na suíte canônica"
    TV2_AddCatalogo ws, nr, "CS_07", "CANONICO", "COMPLETO", "AUTO", "Bloqueio", "Rodízio bloqueado por falta de aptos", "A com OS aberta; B e C com PRE_OS pendente", "Validar resposta controlada SEM_CREDENCIADOS_APTOS", "Sem nova PRE_OS; fila preservada", "É o teste crítico de não travamento do item canônico", "AUTOMATIZADO_0203", "Executado na suíte canônica"
    TV2_AddCatalogo ws, nr, "CS_08", "CANONICO", "COMPLETO", "AUTO", "Retomada", "Conclusão de A libera nova emissão", "Estado bloqueado do CS_07 com A em OS aberta", "Validar retomada correta após conclusão da OS", "Nova PRE_OS para EMP_ID=001", "Prova que a fila retoma do ponto certo", "AUTOMATIZADO_0203", "Executado na suíte canônica"
    TV2_AddCatalogo ws, nr, "CS_11", "CANONICO", "COMPLETO", "AUTO", "Suspensão", "Suspensão manual global de A", "Base canônica limpa; sem OS e sem PRE_OS", "Validar pulo de A sem perda de posição", "B escolhida; A segue suspensa em posição 1", "Separa posição de fila de aptidão operacional", "AUTOMATIZADO_0203", "Executado na suíte canônica"
    TV2_AddCatalogo ws, nr, "CS_13", "CANONICO", "COMPLETO", "AUTO", "Suspensão", "Reativação automática por prazo vencido", "A suspensa com DT_FIM_SUSP já vencida", "Validar reativação automática dentro do SelecionarEmpresa", "A reativada e escolhida na próxima emissão", "Prova o retorno automático sem perder turno", "AUTOMATIZADO_0203", "Executado na suíte canônica"
    TV2_AddCatalogo ws, nr, "CS_22", "CANONICO", "COMPLETO", "AUTO", "Integridade", "Associação da atividade preservada em múltiplas emissões", "Item canônico emitido repetidamente", "Validar vínculo estável entre atividade e serviço", "ATIV_ID e SERV_ID corretos em todas as emissões", "Protege contra regressão de CNAE/CAD_SERV", "AUTOMATIZADO_0203", "Executado na suíte canônica"
    TV2_AddCatalogo ws, nr, "STR_001", "STRESS", "COMPLETO", "AUTO", "Integridade", "Giros repetidos com recusa e conclusao", "Sequencia deterministica de 12 iteracoes", "Verificar invariantes de fila em repeticao", "IDs unicos; ordem relativa integra e posicoes estritamente crescentes", "Captura regressao estrutural em lote", "AUTOMATIZADO_ATUAL", "Executado no stress"
    TV2_AddCatalogo ws, nr, "ASS_001", "ASSISTIDO", "ASSISTIDO", "ASSISTIDO", "UI", "Fluxo visual do smoke assistido", "Humano acompanha fechamento do menu, status bar e abertura do resultado", "Dar leitura operacional do smoke", "Operador entende o que esta sendo testado", "Suporta homologacao observada", "PREVISTO_V2", "Executar smoke assistido"
    TV2_AddCatalogo ws, nr, "ASS_002", "ASSISTIDO", "ASSISTIDO", "ASSISTIDO", "UI", "Fluxo visual do stress assistido", "Humano acompanha lote deterministico sem precisar abrir o menu", "Dar leitura operacional do stress", "Operador acompanha o teste de repeticao sem perder contexto", "Suporta homologacao observada", "PREVISTO_V2", "Executar stress assistido"
    TV2_AddCatalogo ws, nr, "ASS_003", "ASSISTIDO", "ASSISTIDO", "ASSISTIDO", "UI", "Botoes de retorno e central", "Humano valida navegacao pelos botoes das abas V2", "Garantir navegacao humana assistida", "Botoes reabrem menu e central corretamente", "Fecha o ciclo operacional da homologacao", "PREVISTO_V2", "Validar apos smoke ou stress"
    TV2_AddCatalogo ws, nr, "MIG_001", "MIGRACAO", "RAPIDO", "AUTO", "Pre-OS", "Entidade inexistente deve falhar no servico", "Guarda de ENT_ID migrada da interface para o servico", "Validar rejeicao de ENT_ID invalida sem gravar PRE_OS", "Servico retorna erro sem depender de form", "Remove dependencia da interface", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "MIG_002", "MIGRACAO", "RAPIDO", "AUTO", "OS", "Data prevista invalida deve falhar no servico", "Guarda de DT_PREV_TERMINO migrada da interface para o servico", "Validar rejeicao de data incoerente sem converter PRE_OS", "Servico rejeita data incoerente", "Torna automacao sem UI confiavel", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "MIG_003", "MIGRACAO", "RAPIDO", "AUTO", "Avaliacao", "Divergencia sem motivo textual deve falhar", "Regra de justificativa/observacao migrada da interface para o servico", "Validar rejeicao de divergencia sem justificativa e sem observacao", "Servico rejeita divergencia sem motivo", "Fecha lacuna de regra de negocio", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "MIG_004", "MIGRACAO", "RAPIDO", "AUTO", "Avaliacao", "Observacao textual pode sustentar a divergencia", "Compatibilidade com a bateria oficial em divergencia com observacao preenchida", "Validar conclusao da OS quando ha observacao mesmo sem campo dedicado", "Servico conclui a OS e registra a divergencia", "Preserva legado sem abrir silencio semantico", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "ATM_001", "ATOMICIDADE", "RAPIDO", "AUTO", "Rodizio", "Falha na segunda escrita reverte a primeira", "EMPRESAS protegida com senha desconhecida durante o fluxo punido de avancar fila", "Validar rollback de fila e recusas quando a atualizacao cruzada falha", "Avanco punido falha, fila volta ao estado anterior e recusas permanecem zeradas", "Evita estado parcial entre CREDENCIADOS e EMPRESAS", "AUTOMATIZADO_ATUAL", "Executado no smoke"

    TV2_FormatarCatalogoSheet
    TV2_GerarRoteiroAssistido
End Sub

Private Sub TV2_AddCatalogo( _
    ByVal ws As Worksheet, _
    ByRef nr As Long, _
    ByVal cenarioId As String, _
    ByVal suite As String, _
    ByVal modo As String, _
    ByVal automacao As String, _
    ByVal dominio As String, _
    ByVal cenario As String, _
    ByVal contexto As String, _
    ByVal objetivo As String, _
    ByVal esperado As String, _
    ByVal significado As String, _
    ByVal statusAtual As String, _
    ByVal obsOperacional As String _
)
    ws.Cells(nr, 1).Value = cenarioId
    ws.Cells(nr, 2).Value = suite
    ws.Cells(nr, 3).Value = modo
    ws.Cells(nr, 4).Value = automacao
    ws.Cells(nr, 5).Value = dominio
    ws.Cells(nr, 6).Value = cenario
    ws.Cells(nr, 7).Value = contexto
    ws.Cells(nr, 8).Value = objetivo
    ws.Cells(nr, 9).Value = esperado
    ws.Cells(nr, 10).Value = significado
    ws.Cells(nr, 11).Value = statusAtual
    ws.Cells(nr, 12).Value = obsOperacional
    nr = nr + 1
End Sub

Public Sub TV2_PrepararBaselineCanonica()
    TV2_ResetBaseOperacional
    TV2_SetConfigCanonica
    CargaInicialCNAE_SeNecessario False
    TV2_MapearAtividadesCanonicas
    TV2_GarantirServicoCanonico gTV2AtivCanonA, gTV2AtivDescA, 100@
    TV2_GarantirServicoCanonico gTV2AtivCanonB, gTV2AtivDescB, 200@
    TV2_GarantirServicoCanonico gTV2AtivCanonC, gTV2AtivDescC, 300@
    SincronizarDescricoesCadServComAtividades True
    AppContext.Invalidate
End Sub

Public Sub TV2_PrepararCenarioTriploCanonico()
    TV2_PrepararBaselineCanonica

    TV2_CadastrarEntidadeCanonica "001", "Local 1"
    TV2_CadastrarEntidadeCanonica "002", "Local 2"
    TV2_CadastrarEntidadeCanonica "003", "Local 3"

    TV2_CadastrarEmpresaCanonica "001", "Empresa 1"
    TV2_CadastrarEmpresaCanonica "002", "Empresa 2"
    TV2_CadastrarEmpresaCanonica "003", "Empresa 3"

    TV2_CredenciarAtividade "001", gTV2AtivCanonA, "001"
    TV2_CredenciarAtividade "002", gTV2AtivCanonA, "001"
    TV2_CredenciarAtividade "003", gTV2AtivCanonA, "001"
    TV2_ValidarCenarioTriploCanonico
End Sub

Private Sub TV2_SetConfigCanonica()
    Dim ws As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        Err.Raise 1004, "TV2_SetConfigCanonica", "Nao foi possivel preparar CONFIG."
    End If

    ws.Cells(LINHA_CFG_VALORES, COL_CFG_GESTOR).Value = "Gestor Testes V2"
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_LOGO).Value = "LOGO_TESTES_V2"
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_MUNICIPIO).Value = "Municipio de Testes V2"
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_PRAZO_PREOS).Value = 5
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value = 3
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_MESES_SUSPENSAO).Value = 1
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_VERSAO).Value = "TESTE_V2_BASELINE"
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_UF).Value = "PE"
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_SECRETARIA).Value = "Secretaria Testes V2"
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_NOTA_MINIMA).Value = 5

    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
End Sub

Private Sub TV2_ResetBaseOperacional()
    Dim nome As Variant
    Dim nomeOperacional As Variant

    If Not gTV2SnapshotExecutado Then
        TV2_GerarSnapshotOperacional
        gTV2SnapshotExecutado = True
    End If

    For Each nome In Array( _
        SHEET_EMPRESAS, _
        SHEET_EMPRESAS_INATIVAS, _
        SHEET_ENTIDADE, _
        SHEET_ENTIDADE_INATIVOS, _
        SHEET_CREDENCIADOS, _
        SHEET_PREOS, _
        SHEET_CAD_OS, _
        SHEET_AUDIT, _
        SHEET_RELATORIO)
        TV2_ClearSheet CStr(nome)
    Next nome

    For Each nomeOperacional In Array( _
        SHEET_EMPRESAS, _
        SHEET_ENTIDADE, _
        SHEET_CREDENCIADOS, _
        SHEET_PREOS, _
        SHEET_CAD_OS)
        If TV2_CountRows(CStr(nomeOperacional)) <> 0 Then
            Err.Raise 1004, "TV2_ResetBaseOperacional", _
                      "Aba " & CStr(nomeOperacional) & " nao zerou apos reset. " & _
                      "Verificar ListObjects, protecao ou residuos fora da area operacional."
        End If
    Next nomeOperacional
End Sub

Private Sub TV2_GerarSnapshotOperacional()
    Dim nome As Variant
    Dim encontrouDados As Boolean
    Dim sufixo As String

    For Each nome In Array( _
        SHEET_EMPRESAS, _
        SHEET_ENTIDADE, _
        SHEET_CREDENCIADOS, _
        SHEET_PREOS, _
        SHEET_CAD_OS)
        If TV2_CountRows(CStr(nome)) > 0 Then
            encontrouDados = True
            Exit For
        End If
    Next nome

    If Not encontrouDados Then
        TV2_LogInfo "CORE", "SNAPSHOT", "Snapshot antes do reset", "Base operacional inicial ja estava vazia"
        Exit Sub
    End If

    sufixo = Format$(Now, "mmdd_hhnnss")

    For Each nome In Array( _
        SHEET_EMPRESAS, _
        SHEET_ENTIDADE, _
        SHEET_CREDENCIADOS, _
        SHEET_PREOS, _
        SHEET_CAD_OS)
        TV2_CopiarSnapshotAba CStr(nome), sufixo
    Next nome

    TV2_LogInfo "CORE", "SNAPSHOT", "Snapshot antes do reset", "Abas operacionais copiadas com sufixo " & sufixo
End Sub

Private Sub TV2_CopiarSnapshotAba(ByVal nomeOrigem As String, ByVal sufixo As String)
    Dim wsOrigem As Worksheet
    Dim wsDestino As Worksheet
    Dim nomeDestino As String

    Set wsOrigem = ThisWorkbook.Sheets(nomeOrigem)
    nomeDestino = TV2_NomeSnapshot(nomeOrigem, sufixo)

    On Error Resume Next
    Application.DisplayAlerts = False
    ThisWorkbook.Sheets(nomeDestino).Delete
    Application.DisplayAlerts = True
    On Error GoTo 0

    Set wsDestino = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
    wsDestino.Name = nomeDestino
    wsOrigem.UsedRange.Copy Destination:=wsDestino.Cells(1, 1)
    wsDestino.Tab.Color = RGB(191, 191, 191)
End Sub

Private Function TV2_NomeSnapshot(ByVal nomeOrigem As String, ByVal sufixo As String) As String
    Dim codigo As String

    Select Case UCase$(Trim$(nomeOrigem))
        Case UCase$(SHEET_EMPRESAS)
            codigo = "EMP"
        Case UCase$(SHEET_ENTIDADE)
            codigo = "ENT"
        Case UCase$(SHEET_CREDENCIADOS)
            codigo = "CRD"
        Case UCase$(SHEET_PREOS)
            codigo = "PRE"
        Case UCase$(SHEET_CAD_OS)
            codigo = "OS"
        Case Else
            codigo = "GEN"
    End Select

    TV2_NomeSnapshot = "SNAPV2_" & codigo & "_" & sufixo
End Function

Private Sub TV2_ClearSheet(ByVal nomeAba As String)
    Dim ws As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim ultimaLinha As Long
    Dim ultimaColuna As Long
    Dim primeiraLinha As Long
    Dim lo As ListObject
    Dim ultimaLinhaColunaA As Long
    Dim ultimaLinhaColunaChave As Long
    Dim ultimaLinhaUsedRange As Long
    Dim ultimaColunaCabecalho As Long
    Dim ultimaColunaUsedRange As Long
    Dim colunaChave As Long

    Set ws = ThisWorkbook.Sheets(nomeAba)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        Err.Raise 1004, "TV2_ClearSheet", "Nao foi possivel preparar a aba " & nomeAba
    End If

    On Error Resume Next
    For Each lo In ws.ListObjects
        Do While lo.ListRows.Count > 0
            lo.ListRows(1).Delete
        Loop
    Next lo
    On Error GoTo 0

    primeiraLinha = TV2_PrimeiraLinhaDados(nomeAba)
    colunaChave = TV2_ColunaChave(nomeAba)

    ultimaLinhaColunaA = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    ultimaLinhaColunaChave = ws.Cells(ws.Rows.Count, colunaChave).End(xlUp).Row
    ultimaLinhaUsedRange = ws.UsedRange.Row + ws.UsedRange.Rows.Count - 1
    ultimaColunaCabecalho = ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column
    ultimaColunaUsedRange = ws.UsedRange.Column + ws.UsedRange.Columns.Count - 1

    ultimaLinha = Application.WorksheetFunction.Max(ultimaLinhaColunaA, ultimaLinhaColunaChave, ultimaLinhaUsedRange)
    ultimaColuna = Application.WorksheetFunction.Max(ultimaColunaCabecalho, ultimaColunaUsedRange)

    If ultimaColuna < 1 Then ultimaColuna = 1
    If ultimaLinha >= primeiraLinha Then
        ws.Range(ws.Cells(primeiraLinha, 1), ws.Cells(ultimaLinha, ultimaColuna)).ClearContents
    End If

    ws.Cells(1, COL_CONTADOR_AR).Value = 0
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
End Sub

Private Function TV2_PrimeiraLinhaDados(ByVal nomeAba As String) As Long
    If StrComp(nomeAba, SHEET_EMPRESAS, vbTextCompare) = 0 Then
        TV2_PrimeiraLinhaDados = PrimeiraLinhaDadosEmpresas()
    Else
        TV2_PrimeiraLinhaDados = LINHA_DADOS
    End If
End Function

Private Function TV2_NextDataRow(ByVal nomeAba As String) As Long
    Dim ws As Worksheet
    Dim colunaChave As Long
    Dim ultima As Long
    Dim primeira As Long

    Set ws = ThisWorkbook.Sheets(nomeAba)
    primeira = TV2_PrimeiraLinhaDados(nomeAba)
    colunaChave = TV2_ColunaChave(nomeAba)
    ultima = ws.Cells(ws.Rows.Count, colunaChave).End(xlUp).Row

    If ultima < primeira Then
        TV2_NextDataRow = primeira
    Else
        TV2_NextDataRow = ultima + 1
    End If
End Function

Private Sub TV2_SetCounter(ByVal nomeAba As String, ByVal valor As Long)
    Dim ws As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    Set ws = ThisWorkbook.Sheets(nomeAba)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then Exit Sub
    ws.Cells(1, COL_CONTADOR_AR).Value = valor
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
End Sub

Private Sub TV2_MapearAtividadesCanonicas()
    Dim ws As Worksheet
    Dim ultima As Long
    Dim linha As Long
    Dim idAtual As String
    Dim descAtual As String
    Dim idx As Long

    gTV2AtivCanonA = ""
    gTV2AtivCanonB = ""
    gTV2AtivCanonC = ""
    gTV2AtivDescA = ""
    gTV2AtivDescB = ""
    gTV2AtivDescC = ""

    Set ws = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
    ultima = UltimaLinhaAba(SHEET_ATIVIDADES)
    If ultima < LINHA_DADOS Then
        Err.Raise 1004, "TV2_MapearAtividadesCanonicas", "ATIVIDADES sem baseline estrutural."
    End If

    For linha = LINHA_DADOS To ultima
        idAtual = Trim$(CStr(ws.Cells(linha, COL_ATIV_ID).Value))
        descAtual = Trim$(CStr(ws.Cells(linha, COL_ATIV_DESCRICAO).Value))

        If idAtual <> "" And descAtual <> "" Then
            If IsNumeric(idAtual) Then
                idx = idx + 1
                Select Case idx
                    Case 1
                        gTV2AtivCanonA = TV2_Pad3(idAtual)
                        gTV2AtivDescA = descAtual
                    Case 2
                        gTV2AtivCanonB = TV2_Pad3(idAtual)
                        gTV2AtivDescB = descAtual
                    Case 3
                        gTV2AtivCanonC = TV2_Pad3(idAtual)
                        gTV2AtivDescC = descAtual
                        Exit For
                End Select
            End If
        End If
    Next linha

    If gTV2AtivCanonA = "" Or gTV2AtivCanonB = "" Or gTV2AtivCanonC = "" Then
        Err.Raise 1004, "TV2_MapearAtividadesCanonicas", "Nao foi possivel mapear 3 atividades canonicas."
    End If
End Sub

Private Sub TV2_GarantirServicoCanonico(ByVal ativId As String, ByVal descricaoAtiv As String, ByVal valorPadrao As Currency)
    Dim ws As Worksheet
    Dim linha As Long
    Dim ultima As Long
    Dim linhaEncontrada As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    ultima = UltimaLinhaAba(SHEET_CAD_SERV)

    For linha = LINHA_DADOS To ultima
        If IdsIguais(ws.Cells(linha, COL_SERV_ATIV_ID).Value, ativId) And _
           IdsIguais(ws.Cells(linha, COL_SERV_ID).Value, "001") Then
            linhaEncontrada = linha
            Exit For
        End If
    Next linha

    If linhaEncontrada = 0 Then
        If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
            Err.Raise 1004, "TV2_GarantirServicoCanonico", "Nao foi possivel preparar CAD_SERV."
        End If

        linhaEncontrada = TV2_NextDataRow(SHEET_CAD_SERV)
        ws.Cells(linhaEncontrada, COL_SERV_ID).Value = "001"
        ws.Cells(linhaEncontrada, COL_SERV_ATIV_ID).Value = ativId
        ws.Cells(linhaEncontrada, COL_SERV_ATIV_DESC).Value = descricaoAtiv
        ws.Cells(linhaEncontrada, COL_SERV_DESCRICAO).Value = descricaoAtiv
        ws.Cells(linhaEncontrada, COL_SERV_VALOR_UNIT).Value = valorPadrao
        ws.Cells(linhaEncontrada, COL_SERV_DT_CAD).Value = Now

        Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Else
        If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then Exit Sub
        ws.Cells(linhaEncontrada, COL_SERV_ATIV_DESC).Value = descricaoAtiv
        ws.Cells(linhaEncontrada, COL_SERV_DESCRICAO).Value = descricaoAtiv
        ws.Cells(linhaEncontrada, COL_SERV_VALOR_UNIT).Value = valorPadrao
        Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    End If
End Sub

Public Sub TV2_CadastrarEntidadeCanonica(ByVal entId As String, ByVal nome As String)
    Dim ws As Worksheet
    Dim linha As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    Set ws = ThisWorkbook.Sheets(SHEET_ENTIDADE)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        Err.Raise 1004, "TV2_CadastrarEntidadeCanonica", "Nao foi possivel preparar ENTIDADE."
    End If

    linha = TV2_NextDataRow(SHEET_ENTIDADE)
    ws.Cells(linha, COL_ENT_ID).Value = entId
    ws.Cells(linha, COL_ENT_CNPJ).Value = "10.000.000/000" & Right$(entId, 1) & "-0" & Right$(entId, 1)
    ws.Cells(linha, COL_ENT_NOME).Value = nome
    ws.Cells(linha, COL_ENT_TEL_FIXO).Value = "(81) 3100-000" & Right$(entId, 1)
    ws.Cells(linha, COL_ENT_TEL_CEL).Value = "(81) 91000-000" & Right$(entId, 1)
    ws.Cells(linha, COL_ENT_EMAIL).Value = "entidade" & Right$(entId, 1) & "@teste-v2.local"
    ws.Cells(linha, COL_ENT_ENDERECO).Value = "Rua da Entidade " & entId
    ws.Cells(linha, COL_ENT_BAIRRO).Value = "Centro"
    ws.Cells(linha, COL_ENT_MUNICIPIO).Value = "Municipio de Testes V2"
    ws.Cells(linha, COL_ENT_CEP).Value = "50000-00" & Right$(entId, 1)
    ws.Cells(linha, COL_ENT_UF).Value = "PE"
    ws.Cells(linha, COL_ENT_CONT1_NOME).Value = "Contato Principal " & nome
    ws.Cells(linha, COL_ENT_CONT1_FONE).Value = "(81) 92000-000" & Right$(entId, 1)
    ws.Cells(linha, COL_ENT_CONT1_FUNCAO).Value = "Gestor"
    ws.Cells(linha, COL_ENT_CONT2_NOME).Value = "Contato Apoio " & nome
    ws.Cells(linha, COL_ENT_CONT2_FONE).Value = "(81) 93000-000" & Right$(entId, 1)
    ws.Cells(linha, COL_ENT_CONT2_FUNCAO).Value = "Fiscal"
    ws.Cells(linha, COL_ENT_CONT3_NOME).Value = "Contato Reserva " & nome
    ws.Cells(linha, COL_ENT_CONT3_FONE).Value = "(81) 94000-000" & Right$(entId, 1)
    ws.Cells(linha, COL_ENT_CONT3_FUNCAO).Value = "Apoio"
    ws.Cells(linha, COL_ENT_INFO_ADIC).Value = "Fixture automatizada V2"
    ws.Cells(linha, COL_ENT_DT_CAD).Value = Now

    TV2_SetCounter SHEET_ENTIDADE, CLng(Val(entId))
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
End Sub

Public Sub TV2_CadastrarEmpresaCanonica(ByVal empId As String, ByVal razao As String)
    Dim ws As Worksheet
    Dim linha As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        Err.Raise 1004, "TV2_CadastrarEmpresaCanonica", "Nao foi possivel preparar EMPRESAS."
    End If

    linha = TV2_NextDataRow(SHEET_EMPRESAS)
    ws.Cells(linha, COL_EMP_ID).Value = empId
    ws.Cells(linha, COL_EMP_CNPJ).Value = TV2_CNPJEmpresa(empId)
    ws.Cells(linha, COL_EMP_RAZAO).Value = razao
    ws.Cells(linha, COL_EMP_INSCR_MUN).Value = "100" & Right$(empId, 1)
    ws.Cells(linha, COL_EMP_RESPONSAVEL).Value = "Responsavel " & razao
    ws.Cells(linha, COL_EMP_CPF_RESP).Value = "111.111.111-1" & Right$(empId, 1)
    ws.Cells(linha, COL_EMP_ENDERECO).Value = "Rua da Empresa " & empId
    ws.Cells(linha, COL_EMP_BAIRRO).Value = "Centro"
    ws.Cells(linha, COL_EMP_MUNICIPIO).Value = "Municipio de Testes V2"
    ws.Cells(linha, COL_EMP_CEP).Value = "51000-00" & Right$(empId, 1)
    ws.Cells(linha, COL_EMP_UF).Value = "PE"
    ws.Cells(linha, COL_EMP_TEL_FIXO).Value = "(81) 3000-000" & Right$(empId, 1)
    ws.Cells(linha, COL_EMP_TEL_CEL).Value = "(81) 90000-000" & Right$(empId, 1)
    ws.Cells(linha, COL_EMP_EMAIL).Value = "empresa" & Right$(empId, 1) & "@teste-v2.local"
    ws.Cells(linha, COL_EMP_EXPERIENCIA).Value = "1 A 2 ANOS"
    ws.Cells(linha, COL_EMP_STATUS_GLOBAL).Value = TV2_EMP_STATUS_ATIVA
    ws.Cells(linha, COL_EMP_DT_FIM_SUSP).Value = ""
    ws.Cells(linha, COL_EMP_QTD_RECUSAS).Value = 0
    ws.Cells(linha, COL_EMP_DT_CAD).Value = Now
    ws.Cells(linha, COL_EMP_DT_ULT_ALT).Value = Now

    TV2_SetCounter SHEET_EMPRESAS, CLng(Val(empId))
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
End Sub

Public Function TV2_CredenciarAtividade(ByVal empId As String, ByVal ativId As String, Optional ByVal servId As String = "001") As String
    Dim ws As Worksheet
    Dim linha As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim cnpj As String
    Dim razao As String
    Dim linhaExistente As Long
    Dim codAtivServ As String

    linhaExistente = TV2_LinhaCred(empId, ativId)
    If linhaExistente > 0 Then
        TV2_CredenciarAtividade = "DUPLICADO"
        Exit Function
    End If

    TV2_ObterEmpresa empId, cnpj, razao
    codAtivServ = TV2_Pad3(ativId) & TV2_Pad3(servId)

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        Err.Raise 1004, "TV2_CredenciarAtividade", "Nao foi possivel preparar CREDENCIADOS."
    End If

    linha = TV2_NextDataRow(SHEET_CREDENCIADOS)
    ws.Cells(linha, COL_CRED_ID).Value = TV2_Pad3(UltimaLinhaAba(SHEET_CREDENCIADOS))
    ws.Cells(linha, COL_CRED_COD_ATIV_SERV).Value = codAtivServ
    ws.Cells(linha, COL_CRED_EMP_ID).Value = empId
    ws.Cells(linha, COL_CRED_CNPJ).Value = cnpj
    ws.Cells(linha, COL_CRED_RAZAO).Value = razao
    ws.Cells(linha, COL_CRED_POSICAO).Value = TV2_MaxPosicaoFila(ativId) + 1
    ws.Cells(linha, COL_CRED_ULT_OS).Value = ""
    ws.Cells(linha, COL_CRED_DT_ULT_OS).Value = ""
    ws.Cells(linha, COL_CRED_INATIVO_FLAG).Value = ""
    ws.Cells(linha, COL_CRED_ATIV_ID).Value = TV2_Pad3(ativId)
    ws.Cells(linha, COL_CRED_RECUSAS).Value = 0
    ws.Cells(linha, COL_CRED_EXPIRACOES).Value = 0
    ws.Cells(linha, COL_CRED_STATUS).Value = TV2_CRED_STATUS_ATIVO
    ws.Cells(linha, COL_CRED_DT_ULT_IND).Value = ""
    ws.Cells(linha, COL_CRED_DT_CRED).Value = Now

    TV2_SetCounter SHEET_CREDENCIADOS, TV2_CountRows(SHEET_CREDENCIADOS)
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao

    TV2_CredenciarAtividade = "INSERIDO"
End Function

Public Function TV2_FilaCsv(ByVal ativId As String) As String
    Dim fila() As TCredenciamento
    Dim i As Long
    Dim txt As String

    fila = BuscarFila(ativId)
    If fila(LBound(fila)).CRED_ID = "" Then Exit Function

    For i = LBound(fila) To UBound(fila)
        If txt <> "" Then txt = txt & ","
        txt = txt & TV2_Pad3(fila(i).EMP_ID)
    Next i

    TV2_FilaCsv = txt
End Function

Public Function TV2_PosicaoFila(ByVal empId As String, ByVal ativId As String) As Long
    Dim ws As Worksheet
    Dim linha As Long

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If IdsIguais(ws.Cells(linha, COL_CRED_EMP_ID).Value, empId) And _
           IdsIguais(ws.Cells(linha, COL_CRED_ATIV_ID).Value, ativId) Then
            TV2_PosicaoFila = CLng(Val(ws.Cells(linha, COL_CRED_POSICAO).Value))
            Exit Function
        End If
    Next linha
End Function

Public Function TV2_QtdRecusasEmpresa(ByVal empId As String) As Long
    Dim linhaEmp As Long
    Dim emp As TEmpresa

    emp = LerEmpresa(empId, linhaEmp)
    If linhaEmp > 0 Then
        TV2_QtdRecusasEmpresa = emp.QTD_RECUSAS
    End If
End Function

Public Function TV2_QtdRecusasCredenciamento(ByVal empId As String, ByVal ativId As String) As Long
    Dim ws As Worksheet
    Dim linha As Long

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If IdsIguais(ws.Cells(linha, COL_CRED_EMP_ID).Value, empId) And _
           IdsIguais(ws.Cells(linha, COL_CRED_ATIV_ID).Value, ativId) Then
            TV2_QtdRecusasCredenciamento = CLng(Val(ws.Cells(linha, COL_CRED_RECUSAS).Value))
            Exit Function
        End If
    Next linha
End Function

Public Function TV2_StatusEmpresa(ByVal empId As String) As String
    Dim linhaEmp As Long
    Dim emp As TEmpresa

    emp = LerEmpresa(empId, linhaEmp)
    If linhaEmp > 0 Then
        TV2_StatusEmpresa = Trim$(emp.STATUS_GLOBAL)
    End If
End Function

Public Function TV2_DtFimSuspEmpresa(ByVal empId As String) As Date
    Dim linhaEmp As Long
    Dim emp As TEmpresa

    emp = LerEmpresa(empId, linhaEmp)
    If linhaEmp > 0 Then
        TV2_DtFimSuspEmpresa = emp.DT_FIM_SUSP
    End If
End Function

Public Function TV2_StatusPreOS(ByVal preosId As String) As String
    Dim ws As Worksheet
    Dim linha As Long

    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_PREOS)
        If IdsIguais(ws.Cells(linha, COL_PREOS_ID).Value, preosId) Then
            TV2_StatusPreOS = Trim$(CStr(ws.Cells(linha, COL_PREOS_STATUS).Value))
            Exit Function
        End If
    Next linha
End Function

Public Function TV2_EmpIdPreOS(ByVal preosId As String) As String
    Dim ws As Worksheet
    Dim linha As Long

    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_PREOS)
        If IdsIguais(ws.Cells(linha, COL_PREOS_ID).Value, preosId) Then
            TV2_EmpIdPreOS = TV2_Pad3(ws.Cells(linha, COL_PREOS_EMP_ID).Value)
            Exit Function
        End If
    Next linha
End Function

Public Function TV2_ValorEstPreOS(ByVal preosId As String) As Currency
    Dim ws As Worksheet
    Dim linha As Long

    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_PREOS)
        If IdsIguais(ws.Cells(linha, COL_PREOS_ID).Value, preosId) Then
            TV2_ValorEstPreOS = CCur(Val(ws.Cells(linha, COL_PREOS_VL_EST).Value))
            Exit Function
        End If
    Next linha
End Function

Public Function TV2_StatusOS(ByVal osId As String) As String
    Dim os As TOS
    os = Repo_OS.BuscarPorId(osId)
    TV2_StatusOS = Trim$(os.STATUS_OS)
End Function

Public Function TV2_FilaTemOrdemIntegra(ByVal ativId As String, ByVal qtdEsperada As Long) As Boolean
    Dim fila() As TCredenciamento
    Dim dictEmp As Object
    Dim i As Long
    Dim ultimaPosicao As Long
    Dim empId As String

    ' O contrato real do repositorio preserva ordem relativa e posicoes crescentes,
    ' mas nao renumera necessariamente a fila para 1..N apos cada movimento.
    fila = BuscarFila(ativId)
    If fila(LBound(fila)).CRED_ID = "" Then Exit Function
    If (UBound(fila) - LBound(fila) + 1) <> qtdEsperada Then Exit Function

    Set dictEmp = CreateObject("Scripting.Dictionary")
    ultimaPosicao = 0

    For i = LBound(fila) To UBound(fila)
        empId = TV2_Pad3(fila(i).EMP_ID)
        If dictEmp.Exists(empId) Then Exit Function
        dictEmp.Add empId, True

        If fila(i).POSICAO_FILA <= 0 Then Exit Function
        If fila(i).POSICAO_FILA <= ultimaPosicao Then Exit Function
        ultimaPosicao = fila(i).POSICAO_FILA
    Next i

    TV2_FilaTemOrdemIntegra = True
End Function

Public Function TV2_FilaComPosicoesCsv(ByVal ativId As String) As String
    Dim fila() As TCredenciamento
    Dim i As Long
    Dim txt As String

    fila = BuscarFila(ativId)
    If fila(LBound(fila)).CRED_ID = "" Then Exit Function

    For i = LBound(fila) To UBound(fila)
        If txt <> "" Then txt = txt & ","
        txt = txt & TV2_Pad3(fila(i).EMP_ID) & "#" & CStr(fila(i).POSICAO_FILA)
    Next i

    TV2_FilaComPosicoesCsv = txt
End Function

Public Function TV2_AtivCanonA() As String
    TV2_AtivCanonA = gTV2AtivCanonA
End Function

Public Function TV2_CodServicoA() As String
    TV2_CodServicoA = gTV2AtivCanonA & "|001"
End Function

Public Function TV2_CodServico(ByVal ativId As String, Optional ByVal servId As String = "001") As String
    TV2_CodServico = TV2_Pad3(ativId) & "|" & TV2_Pad3(servId)
End Function

Public Function TV2_QtdServicosAtivServ(ByVal ativId As String, Optional ByVal servId As String = "") As Long
    Dim ws As Worksheet
    Dim linha As Long

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_SERV)
        If IdsIguais(ws.Cells(linha, COL_SERV_ATIV_ID).Value, ativId) Then
            If servId = "" Or IdsIguais(ws.Cells(linha, COL_SERV_ID).Value, servId) Then
                TV2_QtdServicosAtivServ = TV2_QtdServicosAtivServ + 1
            End If
        End If
    Next linha
End Function

Public Function TV2_DescricaoServico(ByVal ativId As String, ByVal servId As String) As String
    Dim ws As Worksheet
    Dim linha As Long

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_SERV)
        If IdsIguais(ws.Cells(linha, COL_SERV_ATIV_ID).Value, ativId) And _
           IdsIguais(ws.Cells(linha, COL_SERV_ID).Value, servId) Then
            TV2_DescricaoServico = Trim$(CStr(ws.Cells(linha, COL_SERV_DESCRICAO).Value))
            Exit Function
        End If
    Next linha
End Function

Public Function TV2_QtdCredenciadosNoItem(ByVal ativId As String, Optional ByVal servId As String = "001") As Long
    Dim ws As Worksheet
    Dim linha As Long
    Dim codItem As String

    codItem = TV2_Pad3(ativId) & TV2_Pad3(servId)
    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)

    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If IdsIguais(ws.Cells(linha, COL_CRED_ATIV_ID).Value, ativId) And _
           Trim$(CStr(ws.Cells(linha, COL_CRED_COD_ATIV_SERV).Value)) = codItem Then
            TV2_QtdCredenciadosNoItem = TV2_QtdCredenciadosNoItem + 1
        End If
    Next linha
End Function

Public Function TV2_CountRows(ByVal nomeAba As String) As Long
    Dim ws As Worksheet
    Dim colunaChave As Long
    Dim primeira As Long
    Dim intervalo As Range

    Set ws = ThisWorkbook.Sheets(nomeAba)
    colunaChave = TV2_ColunaChave(nomeAba)
    primeira = TV2_PrimeiraLinhaDados(nomeAba)
    Set intervalo = ws.Range(ws.Cells(primeira, colunaChave), ws.Cells(ws.Rows.Count, colunaChave))

    TV2_CountRows = Application.WorksheetFunction.CountA(intervalo)
End Function

Public Function TV2_AuditContemTrecho(ByVal trecho As String) As Boolean
    Dim ws As Worksheet
    Dim linha As Long
    Dim textoBusca As String

    Set ws = ThisWorkbook.Sheets(SHEET_AUDIT)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_AUDIT)
        textoBusca = CStr(ws.Cells(linha, COL_AUDIT_TIPO_DESC).Value) & " " & _
                     CStr(ws.Cells(linha, COL_AUDIT_ANTES).Value) & " " & _
                     CStr(ws.Cells(linha, COL_AUDIT_DEPOIS).Value)
        If InStr(1, textoBusca, trecho, vbTextCompare) > 0 Then
            TV2_AuditContemTrecho = True
            Exit Function
        End If
    Next linha
End Function

Public Function TV2_AuditCount(Optional ByVal tipoDesc As String = "", Optional ByVal trecho As String = "") As Long
    Dim ws As Worksheet
    Dim linha As Long
    Dim tipoAtual As String
    Dim textoBusca As String

    Set ws = ThisWorkbook.Sheets(SHEET_AUDIT)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_AUDIT)
        tipoAtual = Trim$(CStr(ws.Cells(linha, COL_AUDIT_TIPO_DESC).Value))
        textoBusca = CStr(ws.Cells(linha, COL_AUDIT_ANTES).Value) & " " & _
                     CStr(ws.Cells(linha, COL_AUDIT_DEPOIS).Value)

        If (tipoDesc = "" Or StrComp(tipoAtual, tipoDesc, vbTextCompare) = 0) Then
            If trecho = "" Or InStr(1, textoBusca, trecho, vbTextCompare) > 0 Then
                TV2_AuditCount = TV2_AuditCount + 1
            End If
        End If
    Next linha
End Function

Public Sub TV2_ProtegerAbaTeste(ByVal nomeAba As String, ByVal senha As String)
    Dim ws As Worksheet

    Set ws = ThisWorkbook.Sheets(nomeAba)
    Util_DesprotegerAbaComTentativas ws
    ws.Protect Password:=senha, UserInterfaceOnly:=False
End Sub

Public Sub TV2_DesprotegerAbaTeste(ByVal nomeAba As String, ByVal senha As String)
    Dim ws As Worksheet

    Set ws = ThisWorkbook.Sheets(nomeAba)
    On Error Resume Next
    ws.Unprotect Password:=senha
    On Error GoTo 0
End Sub

Private Function TV2_ColunaChave(ByVal nomeAba As String) As Long
    Select Case UCase$(Trim$(nomeAba))
        Case UCase$(SHEET_EMPRESAS), UCase$(SHEET_EMPRESAS_INATIVAS)
            TV2_ColunaChave = COL_EMP_ID
        Case UCase$(SHEET_ENTIDADE), UCase$(SHEET_ENTIDADE_INATIVOS)
            TV2_ColunaChave = COL_ENT_ID
        Case UCase$(SHEET_CREDENCIADOS)
            TV2_ColunaChave = COL_CRED_ID
        Case UCase$(SHEET_PREOS)
            TV2_ColunaChave = COL_PREOS_ID
        Case UCase$(SHEET_CAD_OS)
            TV2_ColunaChave = COL_OS_ID
        Case UCase$(SHEET_AUDIT)
            TV2_ColunaChave = COL_AUDIT_ID
        Case Else
            TV2_ColunaChave = 1
    End Select
End Function

Private Function TV2_MaxPosicaoFila(ByVal ativId As String) As Long
    Dim ws As Worksheet
    Dim linha As Long
    Dim atual As Long

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If IdsIguais(ws.Cells(linha, COL_CRED_ATIV_ID).Value, ativId) Then
            atual = CLng(Val(ws.Cells(linha, COL_CRED_POSICAO).Value))
            If atual > TV2_MaxPosicaoFila Then TV2_MaxPosicaoFila = atual
        End If
    Next linha
End Function

Private Function TV2_LinhaCred(ByVal empId As String, ByVal ativId As String) As Long
    Dim ws As Worksheet
    Dim linha As Long

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If IdsIguais(ws.Cells(linha, COL_CRED_EMP_ID).Value, empId) And _
           IdsIguais(ws.Cells(linha, COL_CRED_ATIV_ID).Value, ativId) Then
            TV2_LinhaCred = linha
            Exit Function
        End If
    Next linha
End Function

Private Sub TV2_ObterEmpresa(ByVal empId As String, ByRef cnpjOut As String, ByRef razaoOut As String)
    Dim ws As Worksheet
    Dim linha As Long

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    For linha = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
        If IdsIguais(ws.Cells(linha, COL_EMP_ID).Value, empId) Then
            cnpjOut = CStr(ws.Cells(linha, COL_EMP_CNPJ).Value)
            razaoOut = CStr(ws.Cells(linha, COL_EMP_RAZAO).Value)
            Exit Sub
        End If
    Next linha
End Sub

Private Function TV2_CNPJEmpresa(ByVal empId As String) As String
    TV2_CNPJEmpresa = Right$("00" & empId, 3) & "." & Right$("00" & empId, 3) & "." & Right$("00" & empId, 3) & "/0001-" & Right$("0" & empId, 2)
End Function

Private Function TV2_Pad3(ByVal valor As Variant) As String
    TV2_Pad3 = Format$(CLng(Val(valor)), "000")
End Function

Private Function TV2_EnsureResultadoSheet() As Worksheet
    Dim ws As Worksheet

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(TV2_SHEET_RESULTADO)
    On Error GoTo 0

    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
        ws.Name = TV2_SHEET_RESULTADO
    End If

    If Trim$(CStr(ws.Cells(1, 1).Value)) = "" Then
        ws.Cells(1, 1).Value = "EXECUCAO_ID"
        ws.Cells(1, 2).Value = "SUITE"
        ws.Cells(1, 3).Value = "CENARIO_ID"
        ws.Cells(1, 4).Value = "AUTOMACAO"
        ws.Cells(1, 5).Value = "OBJETIVO"
        ws.Cells(1, 6).Value = "RESULTADO_ESPERADO"
        ws.Cells(1, 7).Value = "RESULTADO_OBTIDO"
        ws.Cells(1, 8).Value = "STATUS"
        ws.Cells(1, 9).Value = "SIGNIFICADO"
        ws.Cells(1, 10).Value = "OBSERVACAO"
        ws.Cells(1, 11).Value = "DATA_HORA"
    End If

    Set TV2_EnsureResultadoSheet = ws
End Function

Private Function TV2_EnsureCatalogoSheet() As Worksheet
    Dim ws As Worksheet

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(TV2_SHEET_CATALOGO)
    On Error GoTo 0

    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
        ws.Name = TV2_SHEET_CATALOGO
    End If

    Set TV2_EnsureCatalogoSheet = ws
End Function

Private Function TV2_EnsureRoteiroSheet() As Worksheet
    Dim ws As Worksheet

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(TV2_SHEET_ROTEIRO)
    On Error GoTo 0

    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
        ws.Name = TV2_SHEET_ROTEIRO
    End If

    Set TV2_EnsureRoteiroSheet = ws
End Function

Private Function TV2_EnsureHistoricoSheet() As Worksheet
    Dim ws As Worksheet

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(TV2_SHEET_HIST)
    On Error GoTo 0

    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
        ws.Name = TV2_SHEET_HIST
    End If

    If Trim$(CStr(ws.Cells(1, 1).Value)) = "" Then
        ws.Cells(1, 1).Value = "EXECUCAO_ID"
        ws.Cells(1, 2).Value = "SUITE"
        ws.Cells(1, 3).Value = "DATA_HORA"
        ws.Cells(1, 4).Value = "OK"
        ws.Cells(1, 5).Value = "FALHA"
        ws.Cells(1, 6).Value = "MANUAL"
        ws.Cells(1, 7).Value = "TOTAL"
        ws.Cells(1, 8).Value = "CSV_FALHAS"
        ws.Cells(1, 9).Value = "OBS_EXPORTACAO"
    Else
        ws.Cells(1, 8).Value = "CSV_FALHAS"
        ws.Cells(1, 9).Value = "OBS_EXPORTACAO"
    End If

    Set TV2_EnsureHistoricoSheet = ws
End Function

Private Function TV2_NextRow(ByVal ws As Worksheet, ByVal colBase As Long, ByVal minRow As Long) As Long
    Dim ultima As Long

    ultima = ws.Cells(ws.Rows.Count, colBase).End(xlUp).Row
    If ultima < minRow Then
        TV2_NextRow = minRow
    Else
        TV2_NextRow = ultima + 1
    End If
End Function

Private Sub TV2_FormatarResultadoSheet()
    Dim ws As Worksheet
    Dim ultima As Long

    Set ws = TV2_EnsureResultadoSheet()
    ws.Rows(1).Font.Bold = True
    ws.Rows(1).Interior.Color = RGB(0, 51, 102)
    ws.Rows(1).Font.Color = RGB(255, 255, 255)
    ws.Columns("A:K").EntireColumn.AutoFit
    ultima = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    If ultima >= 1 Then
        On Error Resume Next
        If ws.AutoFilterMode Then ws.AutoFilter.ShowAllData
        On Error GoTo 0
        ws.Range(ws.Cells(1, 1), ws.Cells(ultima, 11)).AutoFilter
    End If
    TV2_AdicionarBotoes ws
End Sub

Private Sub TV2_FormatarCatalogoSheet()
    Dim ws As Worksheet

    Set ws = TV2_EnsureCatalogoSheet()
    ws.Rows(1).Font.Bold = True
    ws.Rows(1).Interior.Color = RGB(0, 51, 102)
    ws.Rows(1).Font.Color = RGB(255, 255, 255)
    ws.Columns("A:L").EntireColumn.AutoFit
    TV2_AdicionarBotoes ws
End Sub

Private Sub TV2_FormatarRoteiroSheet()
    Dim ws As Worksheet
    Dim ultima As Long

    Set ws = TV2_EnsureRoteiroSheet()
    ws.Rows(1).Font.Bold = True
    ws.Rows(1).Interior.Color = RGB(0, 51, 102)
    ws.Rows(1).Font.Color = RGB(255, 255, 255)
    ws.Columns("A:H").EntireColumn.AutoFit
    ultima = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    If ultima >= 1 Then
        On Error Resume Next
        If ws.AutoFilterMode Then ws.AutoFilter.ShowAllData
        On Error GoTo 0
        ws.Range(ws.Cells(1, 1), ws.Cells(ultima, 8)).AutoFilter
    End If
    TV2_AdicionarBotoes ws
End Sub

Private Sub TV2_FormatarHistoricoSheet()
    Dim ws As Worksheet
    Dim ultima As Long

    Set ws = TV2_EnsureHistoricoSheet()
    ws.Rows(1).Font.Bold = True
    ws.Rows(1).Interior.Color = RGB(0, 51, 102)
    ws.Rows(1).Font.Color = RGB(255, 255, 255)
    ws.Columns("A:I").EntireColumn.AutoFit
    ultima = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    If ultima >= 1 Then
        On Error Resume Next
        If ws.AutoFilterMode Then ws.AutoFilter.ShowAllData
        On Error GoTo 0
        ws.Range(ws.Cells(1, 1), ws.Cells(ultima, 9)).AutoFilter
    End If
    TV2_AdicionarBotoes ws
End Sub

Private Sub TV2_GerarRoteiroAssistido()
    Dim ws As Worksheet
    Dim nr As Long

    Set ws = TV2_EnsureRoteiroSheet()
    ws.Cells.Clear

    ws.Cells(1, 1).Value = "CENARIO_ID"
    ws.Cells(1, 2).Value = "TIPO"
    ws.Cells(1, 3).Value = "OBJETIVO"
    ws.Cells(1, 4).Value = "ACAO_HUMANA"
    ws.Cells(1, 5).Value = "RESULTADO_ESPERADO"
    ws.Cells(1, 6).Value = "O_QUE_OBSERVAR"
    ws.Cells(1, 7).Value = "SIGNIFICADO"
    ws.Cells(1, 8).Value = "STATUS_ATUAL"

    nr = 2
    TV2_AddRoteiro ws, nr, "SMK_001", "AUTO", "Validar setup deterministico", "Apenas executar o smoke e conferir a primeira linha automatica", "Fila inicial 001,002,003", "Resultado automatizado na aba RESULTADO_QA_V2", "Confirma que o cenario foi reconstruido do zero", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "SMK_002", "AUTO", "Validar selecao do topo da fila", "Apenas conferir o resultado automatizado do cenario", "EMP_ID=001", "Linha do cenario SMK_002", "Garante contrato minimo do rodizio", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "SMK_003", "AUTO", "Validar emissao de Pre-OS", "Apenas conferir o resultado automatizado do cenario", "PRE_OS aguardando aceite com valor estimado coerente", "Linha do cenario SMK_003", "Garante emissao minima sem interface", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "SMK_004", "AUTO", "Validar filtro E sem punicao", "Apenas conferir o resultado automatizado do cenario", "Rodizio pula a empresa com PRE_OS pendente sem mover a fila", "Linha do cenario SMK_004", "Evita giro indevido", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "SMK_005", "AUTO", "Validar recusa com punicao", "Apenas conferir o resultado automatizado do cenario", "Fila gira e QTD_RECUSAS sobe", "Linha do cenario SMK_005", "Confirma punicao por recusa", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "EXP_001", "AUTO", "Validar expiracao com retomada correta da fila", "Apenas conferir o resultado automatizado do cenario", "PRE_OS expirada; fila 002,003,001; nova indicacao retorna EMP_ID=002", "Linha do cenario EXP_001", "Confirma que a expiracao remove o bloqueio residual e preserva a fila", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "SMK_006", "AUTO", "Validar conversao de Pre-OS em OS", "Apenas conferir o resultado automatizado do cenario", "PRE_OS convertida; OS em execucao; fila gira", "Linha do cenario SMK_006", "Confirma integracao entre servicos", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "SMK_007", "AUTO", "Validar conclusao de OS", "Apenas conferir o resultado automatizado do cenario", "Avaliacao bem-sucedida; STATUS_OS=CONCLUIDA; fila continua integra", "Linha do cenario SMK_007", "Fecha o ciclo ponta a ponta", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "CS_00", "AUTO", "Validar setup canônico do item triplo", "Executar a suíte canônica e conferir a primeira linha automatizada", "3 empresas, serviço único e fila 001,002,003", "Linhas CS_00 no resultado", "Abre a família canônica sobre base determinística", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "CS_01", "AUTO", "Validar unicidade estrutural do serviço canônico", "Executar a suíte canônica e conferir a linha CS_01", "Permanece apenas 1 serviço 001 vinculado à atividade canônica", "Linhas CS_01 no resultado", "Evita duplicidade silenciosa em CAD_SERV", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "CS_02", "AUTO", "Validar rejeição de associação inválida atividade/serviço", "Executar a suíte canônica e conferir a linha CS_02", "Emissão falha e não grava PRE_OS", "Linhas CS_02 no resultado", "Protege o item canônico contra vínculo inválido", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "CS_03", "AUTO", "Validar primeira emissão do fluxo nominal", "Executar a suíte canônica e conferir a linha CS_03", "PRE_OS para EMP_ID=001", "Linhas CS_03 no resultado", "Abre o fluxo A -> B -> C", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "CS_04", "AUTO", "Validar OS aberta deslocando A para o fim", "Executar a suíte canônica e conferir a linha CS_04", "Fila 002,003,001 após emissão da OS", "Linhas CS_04 no resultado", "Confirma o primeiro giro da fila", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "CS_05", "AUTO", "Validar segunda emissão apontando para B", "Executar a suíte canônica e conferir a linha CS_05", "PRE_OS para EMP_ID=002", "Linhas CS_05 no resultado", "Costura o segundo passo do fluxo nominal", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "CS_06", "AUTO", "Validar terceira emissão apontando para C", "Executar a suíte canônica e conferir a linha CS_06", "PRE_OS para EMP_ID=003", "Linhas CS_06 no resultado", "Fecha o núcleo nominal do item canônico", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "CS_07", "AUTO", "Validar bloqueio total sem travamento", "Executar a suíte canônica e conferir a linha CS_07", "SEM_CREDENCIADOS_APTOS sem nova PRE_OS", "Linhas CS_07 no resultado", "É o teste mais crítico de aptidão do item canônico", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "CS_08", "AUTO", "Validar retomada correta após conclusão da OS", "Executar a suíte canônica e conferir a linha CS_08", "Nova PRE_OS para EMP_ID=001", "Linhas CS_08 no resultado", "Prova que a fila retoma do ponto certo", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "CS_11", "AUTO", "Validar suspensão manual sem perda de posição", "Executar a suíte canônica e conferir a linha CS_11", "A suspensa; B escolhida; posição de A preservada", "Linhas CS_11 no resultado", "Abre o bloco de suspensões da família canônica", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "CS_13", "AUTO", "Validar reativação automática por prazo vencido", "Executar a suíte canônica e conferir a linha CS_13", "A reativada e escolhida automaticamente", "Linhas CS_13 no resultado", "Fecha o primeiro ciclo de suspensão e retorno", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "CS_22", "AUTO", "Validar associação preservada em emissões múltiplas", "Executar a suíte canônica e conferir a linha CS_22", "ATIV_ID e SERV_ID corretos em todas as emissões", "Linhas CS_22 no resultado", "Fecha a proteção contra regressão de associação atividade/serviço", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "STR_001", "AUTO", "Validar repeticao deterministica do rodizio", "Executar Stress deterministico e acompanhar somente se houver falha", "Fila sem duplicidade e em ordem integra apos cada iteracao", "Linhas STR_001 no resultado", "Captura degradacao estrutural em lote", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "ASS_001", "ASSISTIDO", "Acompanhar visualmente o smoke assistido", "Executar a opcao 2 da central V2 e observar a tela durante toda a execucao", "Menu principal fechado; status bar evoluindo; aba de resultado assumindo o foco ao final", "Fechamento do menu, transicao para planilha e feedback visual", "Prova que o operador consegue assistir ao smoke sem interferencia do formulario", "ASSISTIDO"
    TV2_AddRoteiro ws, nr, "ASS_002", "ASSISTIDO", "Acompanhar visualmente o stress assistido", "Executar a opcao 4 da central V2 e acompanhar apenas o giro da fila e a abertura do resultado ao final", "Sem erro fatal; resultados STR_001 visiveis; menu principal fechado durante toda a bateria", "Status bar, aba RESULTADO_QA_V2 e ausencia do formulario do menu", "Permite homologacao assistida do lote deterministico", "ASSISTIDO"
    TV2_AddRoteiro ws, nr, "ASS_003", "ASSISTIDO", "Confirmar retorno ao menu e botoes da V2", "Ao fim do smoke ou stress, clicar nos botoes de retorno e central de testes", "Botoes funcionam e reabrem o fluxo correto", "Topo das abas V2", "Confirma operacao humana sem perder contexto", "ASSISTIDO"
    TV2_AddRoteiro ws, nr, "MIG_001", "AUTO", "Validar rejeicao de ENT_ID invalida no servico", "Apenas conferir o resultado automatizado do cenario", "Servico falha e nao grava PRE_OS", "Linha do cenario MIG_001", "Confirma a migracao da guarda de entidade para o servico", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "MIG_002", "AUTO", "Validar rejeicao de data invalida de OS", "Apenas conferir o resultado automatizado do cenario", "Servico falha e mantem a PRE_OS aguardando aceite", "Linha do cenario MIG_002", "Confirma a migracao da guarda de data para o servico", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "MIG_003", "AUTO", "Validar que divergencia sem motivo falha", "Apenas conferir o resultado automatizado do cenario", "Servico falha e mantem a OS em execucao", "Linha do cenario MIG_003", "Fecha a lacuna de regra de negocio na avaliacao", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "MIG_004", "AUTO", "Validar compatibilidade da observacao como motivo", "Apenas conferir o resultado automatizado do cenario", "Servico conclui a OS mesmo sem campo dedicado quando ha observacao textual", "Linha do cenario MIG_004", "Evita regressao na bateria oficial e mantem rastreabilidade", "AUTOMATIZADO"
    TV2_AddRoteiro ws, nr, "ATM_001", "AUTO", "Validar rollback do avancar punido", "Apenas conferir o resultado automatizado do cenario", "Falha controlada sem alterar fila nem recusas, com rastro de auditoria", "Linha do cenario ATM_001", "Prova atomicidade minima no fluxo de recusa", "AUTOMATIZADO"

    TV2_FormatarRoteiroSheet
End Sub

Private Sub TV2_AddRoteiro( _
    ByVal ws As Worksheet, _
    ByRef nr As Long, _
    ByVal cenarioId As String, _
    ByVal tipo As String, _
    ByVal objetivo As String, _
    ByVal acaoHumana As String, _
    ByVal esperado As String, _
    ByVal observar As String, _
    ByVal significado As String, _
    ByVal statusAtual As String _
)
    ws.Cells(nr, 1).Value = cenarioId
    ws.Cells(nr, 2).Value = tipo
    ws.Cells(nr, 3).Value = objetivo
    ws.Cells(nr, 4).Value = acaoHumana
    ws.Cells(nr, 5).Value = esperado
    ws.Cells(nr, 6).Value = observar
    ws.Cells(nr, 7).Value = significado
    ws.Cells(nr, 8).Value = statusAtual
    nr = nr + 1
End Sub

Private Sub TV2_ValidarCenarioTriploCanonico()
    Dim mensagem As String

    If TV2_CountRows(SHEET_EMPRESAS) <> 3 Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "EMPRESAS=" & CStr(TV2_CountRows(SHEET_EMPRESAS)))
    If TV2_CountRows(SHEET_ENTIDADE) <> 3 Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "ENTIDADE=" & CStr(TV2_CountRows(SHEET_ENTIDADE)))
    If TV2_CountRows(SHEET_CREDENCIADOS) <> 3 Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "CREDENCIADOS=" & CStr(TV2_CountRows(SHEET_CREDENCIADOS)))
    If TV2_CountRows(SHEET_PREOS) <> 0 Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "PRE_OS=" & CStr(TV2_CountRows(SHEET_PREOS)))
    If TV2_CountRows(SHEET_CAD_OS) <> 0 Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "CAD_OS=" & CStr(TV2_CountRows(SHEET_CAD_OS)))
    If gTV2AtivCanonA = "" Or gTV2AtivCanonB = "" Or gTV2AtivCanonC = "" Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "ATIVIDADES_CANONICAS_NAO_MAPEADAS")
    If Abs(CDbl(TV2_ValorUnitServico(gTV2AtivCanonA, "001")) - 100#) > 0.001 Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "SERV_A=" & Format$(TV2_ValorUnitServico(gTV2AtivCanonA, "001"), "0.00"))
    If Abs(CDbl(TV2_ValorUnitServico(gTV2AtivCanonB, "001")) - 200#) > 0.001 Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "SERV_B=" & Format$(TV2_ValorUnitServico(gTV2AtivCanonB, "001"), "0.00"))
    If Abs(CDbl(TV2_ValorUnitServico(gTV2AtivCanonC, "001")) - 300#) > 0.001 Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "SERV_C=" & Format$(TV2_ValorUnitServico(gTV2AtivCanonC, "001"), "0.00"))
    If CLng(Val(ThisWorkbook.Sheets(SHEET_CONFIG).Cells(LINHA_CFG_VALORES, COL_CFG_PRAZO_PREOS).Value)) <> 5 Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "CFG_PRAZO_PREOS")
    If CLng(Val(ThisWorkbook.Sheets(SHEET_CONFIG).Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value)) <> 3 Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "CFG_MAX_RECUSAS")
    If CDbl(Val(ThisWorkbook.Sheets(SHEET_CONFIG).Cells(LINHA_CFG_VALORES, COL_CFG_NOTA_MINIMA).Value)) <> 5# Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "CFG_NOTA_MINIMA")
    If TV2_FilaCsv(gTV2AtivCanonA) <> "001,002,003" Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "FILA_A=" & TV2_FilaCsv(gTV2AtivCanonA))
    If TV2_StatusEmpresa("001") <> TV2_EMP_STATUS_ATIVA Or TV2_QtdRecusasEmpresa("001") <> 0 Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "EMP001=" & TV2_StatusEmpresa("001") & ";QTD=" & CStr(TV2_QtdRecusasEmpresa("001")))
    If TV2_StatusEmpresa("002") <> TV2_EMP_STATUS_ATIVA Or TV2_QtdRecusasEmpresa("002") <> 0 Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "EMP002=" & TV2_StatusEmpresa("002") & ";QTD=" & CStr(TV2_QtdRecusasEmpresa("002")))
    If TV2_StatusEmpresa("003") <> TV2_EMP_STATUS_ATIVA Or TV2_QtdRecusasEmpresa("003") <> 0 Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "EMP003=" & TV2_StatusEmpresa("003") & ";QTD=" & CStr(TV2_QtdRecusasEmpresa("003")))
    If Not TV2_FilaTemOrdemIntegra(gTV2AtivCanonA, 3) Then mensagem = TV2_AcumularFalhaEstrutural(mensagem, "ORDEM_FILA=" & TV2_FilaComPosicoesCsv(gTV2AtivCanonA))

    If mensagem <> "" Then
        Err.Raise 1004, "TV2_ValidarCenarioTriploCanonico", "Cenario triplo V2 inconsistente: " & mensagem
    End If
End Sub

Private Function TV2_AcumularFalhaEstrutural(ByVal atual As String, ByVal trecho As String) As String
    If atual <> "" Then
        TV2_AcumularFalhaEstrutural = atual & " | " & trecho
    Else
        TV2_AcumularFalhaEstrutural = trecho
    End If
End Function

Public Function TV2_ValorUnitServico(ByVal ativId As String, ByVal servId As String) As Currency
    Dim ws As Worksheet
    Dim linha As Long

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_SERV)
        If IdsIguais(ws.Cells(linha, COL_SERV_ATIV_ID).Value, ativId) And _
           IdsIguais(ws.Cells(linha, COL_SERV_ID).Value, servId) Then
            TV2_ValorUnitServico = CCur(Val(ws.Cells(linha, COL_SERV_VALOR_UNIT).Value))
            Exit Function
        End If
    Next linha
End Function

Private Sub TV2_ApplyStatusColor(ByVal alvo As Range, ByVal statusTeste As String)
    Select Case UCase$(Trim$(statusTeste))
        Case TV2_STATUS_OK
            alvo.Interior.Color = RGB(198, 239, 206)
        Case TV2_STATUS_FAIL
            alvo.Interior.Color = RGB(255, 199, 206)
        Case TV2_STATUS_MANUAL
            alvo.Interior.Color = RGB(255, 235, 156)
        Case Else
            alvo.Interior.Color = RGB(221, 235, 247)
    End Select
End Sub

Private Sub TV2_PausarVisual(ByVal segundos As Long)
    If segundos <= 0 Then Exit Sub
    Application.Wait Now + TimeSerial(0, 0, segundos)
End Sub

Private Sub TV2_AdicionarBotoes(ByVal ws As Worksheet)
    Dim shp As Shape
    Dim b As Shape
    Dim topPos As Double
    Dim leftMenu As Double
    Dim leftCentral As Double
    Dim leftCsv As Double

    On Error Resume Next
    For Each shp In ws.Shapes
        If Left$(shp.Name, 8) = "TV2_BTN_" Then shp.Delete
    Next shp
    On Error GoTo 0

    topPos = ws.Cells(1, TV2_COLUNA_BOTOES_INICIO).Top + 2
    leftMenu = ws.Cells(1, TV2_COLUNA_BOTOES_INICIO).Left
    leftCentral = ws.Cells(1, TV2_COLUNA_BOTOES_INICIO + 3).Left
    leftCsv = ws.Cells(1, TV2_COLUNA_BOTOES_INICIO + 6).Left

    Set b = ws.Shapes.AddShape(msoShapeRoundedRectangle, leftMenu, topPos, 180, 22)
    With b
        .Name = "TV2_BTN_MENU_" & ws.Name
        .TextFrame2.TextRange.Text = "Voltar ao Menu Principal"
        .TextFrame2.TextRange.Font.Size = 9
        .TextFrame2.TextRange.Font.Bold = msoTrue
        .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter
        .Fill.ForeColor.RGB = RGB(0, 51, 102)
        .TextFrame2.TextRange.Font.Fill.ForeColor.RGB = RGB(255, 255, 255)
        .OnAction = "CT_AbrirMenuPrincipal"
    End With

    Set b = ws.Shapes.AddShape(msoShapeRoundedRectangle, leftCentral, topPos, 140, 22)
    With b
        .Name = "TV2_BTN_CENTRAL_" & ws.Name
        .TextFrame2.TextRange.Text = "Central de Testes"
        .TextFrame2.TextRange.Font.Size = 9
        .TextFrame2.TextRange.Font.Bold = msoTrue
        .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter
        .Fill.ForeColor.RGB = RGB(255, 192, 0)
        .TextFrame2.TextRange.Font.Fill.ForeColor.RGB = RGB(0, 0, 0)
        .OnAction = "CT2_AbrirCentral"
    End With

    Set b = ws.Shapes.AddShape(msoShapeRoundedRectangle, leftCsv, topPos, 160, 22)
    With b
        .Name = "TV2_BTN_CSV_" & ws.Name
        .TextFrame2.TextRange.Text = "Exportar CSV de Falhas"
        .TextFrame2.TextRange.Font.Size = 9
        .TextFrame2.TextRange.Font.Bold = msoTrue
        .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter
        .Fill.ForeColor.RGB = RGB(0, 128, 0)
        .TextFrame2.TextRange.Font.Fill.ForeColor.RGB = RGB(255, 255, 255)
        .OnAction = "TV2_ExportarUltimaExecucaoCSVs"
    End With
End Sub

Private Sub TV2_AbrirResultadoExecucao(ByVal execucaoId As String)
    Dim ws As Worksheet
    Dim ultima As Long

    Set ws = TV2_EnsureResultadoSheet()
    ultima = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    On Error Resume Next
    If ws.AutoFilterMode Then ws.AutoFilter.ShowAllData
    On Error GoTo 0
    If ultima >= 1 Then
        ws.Range(ws.Cells(1, 1), ws.Cells(ultima, 11)).AutoFilter Field:=1, Criteria1:=execucaoId
    End If
    ws.Activate
    ws.Range("A1").Select
End Sub

Private Function TV2_UltimaExecucaoId() As String
    Dim ws As Worksheet
    Dim ultima As Long

    Set ws = TV2_EnsureHistoricoSheet()
    ultima = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    If ultima >= 2 Then
        TV2_UltimaExecucaoId = Trim$(CStr(ws.Cells(ultima, 1).Value))
    End If
End Function

Private Function TV2_ExecucaoEmFoco() As String
    Dim ws As Worksheet
    Dim linhaAtual As Long
    Dim ultima As Long
    Dim r As Long

    On Error Resume Next
    Set ws = ActiveSheet
    On Error GoTo 0

    If ws Is Nothing Then
        TV2_ExecucaoEmFoco = TV2_UltimaExecucaoId()
        Exit Function
    End If

    Select Case UCase$(ws.Name)
        Case UCase$(TV2_SHEET_RESULTADO), UCase$(TV2_SHEET_HIST)
            linhaAtual = ActiveCell.Row
            If linhaAtual >= 2 Then
                TV2_ExecucaoEmFoco = Trim$(CStr(ws.Cells(linhaAtual, 1).Value))
                If TV2_ExecucaoEmFoco <> "" Then Exit Function
            End If

            ultima = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
            For r = 2 To ultima
                If Not ws.Rows(r).Hidden Then
                    TV2_ExecucaoEmFoco = Trim$(CStr(ws.Cells(r, 1).Value))
                    If TV2_ExecucaoEmFoco <> "" Then Exit Function
                End If
            Next r
    End Select

    TV2_ExecucaoEmFoco = TV2_UltimaExecucaoId()
End Function

Public Function TV2_ExportarFalhasCSV(ByVal execucaoId As String) As String
    Dim wsSrc As Worksheet
    Dim pastaBase As String
    Dim caminho As String
    Dim fNum As Integer
    Dim ultLinha As Long
    Dim r As Long
    Dim suite As String
    Dim stamp As String
    Dim statusAtual As String
    Dim temFalha As Boolean

    On Error GoTo falha

    If Trim$(execucaoId) = "" Then Exit Function
    Set wsSrc = TV2_EnsureResultadoSheet()

    pastaBase = Trim$(ThisWorkbook.Path)
    If Len(pastaBase) = 0 Then pastaBase = Environ$("TEMP")

    suite = TV2_SuiteDaExecucao(execucaoId)
    If suite = "" Then suite = "V2"

    stamp = Replace$(Replace$(Replace$(execucaoId, ":", ""), "-", ""), " ", "_")
    caminho = pastaBase & Application.PathSeparator & "TesteV2_" & suite & "_Falhas_" & stamp & ".csv"

    ultLinha = wsSrc.Cells(wsSrc.Rows.Count, 1).End(xlUp).Row
    If ultLinha < 2 Then Exit Function

    For r = 2 To ultLinha
        If Trim$(CStr(wsSrc.Cells(r, 1).Value)) = execucaoId Then
            statusAtual = UCase$(Trim$(CStr(wsSrc.Cells(r, 8).Value)))
            If statusAtual = TV2_STATUS_FAIL Then
                temFalha = True
                Exit For
            End If
        End If
    Next r

    If Not temFalha Then Exit Function

    fNum = FreeFile
    Open caminho For Output As #fNum
    Print #fNum, "EXECUCAO_ID;SUITE;CENARIO_ID;AUTOMACAO;DOMINIO;CENARIO;CONTEXTO;OBJETIVO;RESULTADO_ESPERADO;RESULTADO_OBTIDO;STATUS;SIGNIFICADO;OBSERVACAO;DATA_HORA"

    For r = 2 To ultLinha
        If Trim$(CStr(wsSrc.Cells(r, 1).Value)) = execucaoId Then
            statusAtual = UCase$(Trim$(CStr(wsSrc.Cells(r, 8).Value)))
            If statusAtual = TV2_STATUS_FAIL Then
                Print #fNum, TV2_CsvLinha(wsSrc, r)
            End If
        End If
    Next r

    Close #fNum
    TV2_ExportarFalhasCSV = caminho
    Exit Function

falha:
    On Error Resume Next
    If fNum <> 0 Then Close #fNum
    TV2_ExportarFalhasCSV = ""
End Function

Private Function TV2_SuiteDaExecucao(ByVal execucaoId As String) As String
    Dim ws As Worksheet
    Dim ultLinha As Long
    Dim r As Long

    Set ws = TV2_EnsureResultadoSheet()
    ultLinha = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    For r = 2 To ultLinha
        If Trim$(CStr(ws.Cells(r, 1).Value)) = execucaoId Then
            TV2_SuiteDaExecucao = Trim$(CStr(ws.Cells(r, 2).Value))
            Exit Function
        End If
    Next r
End Function

Private Function TV2_CsvLinha(ByVal ws As Worksheet, ByVal r As Long) As String
    Dim dominio As String
    Dim cenario As String
    Dim contexto As String

    TV2_LerCatalogoCenario Trim$(CStr(ws.Cells(r, 3).Value)), dominio, cenario, contexto

    TV2_CsvLinha = _
        TV2_CsvCel(ws.Cells(r, 1).Value) & ";" & _
        TV2_CsvCel(ws.Cells(r, 2).Value) & ";" & _
        TV2_CsvCel(ws.Cells(r, 3).Value) & ";" & _
        TV2_CsvCel(ws.Cells(r, 4).Value) & ";" & _
        TV2_CsvCel(dominio) & ";" & _
        TV2_CsvCel(cenario) & ";" & _
        TV2_CsvCel(contexto) & ";" & _
        TV2_CsvCel(ws.Cells(r, 5).Value) & ";" & _
        TV2_CsvCel(ws.Cells(r, 6).Value) & ";" & _
        TV2_CsvCel(ws.Cells(r, 7).Value) & ";" & _
        TV2_CsvCel(ws.Cells(r, 8).Value) & ";" & _
        TV2_CsvCel(ws.Cells(r, 9).Value) & ";" & _
        TV2_CsvCel(ws.Cells(r, 10).Value) & ";" & _
        TV2_CsvCel(ws.Cells(r, 11).Value)
End Function

Private Function TV2_CsvCel(ByVal v As Variant) As String
    Dim s As String

    If IsDate(v) Then
        s = Format$(CDate(v), "dd/mm/yyyy hh:nn:ss")
    Else
        s = CStr(v)
    End If

    s = Trim$(Replace$(Replace$(s, vbCr, " "), vbLf, " "))
    s = Replace$(s, """", """""")
    If InStr(1, s, ";", vbBinaryCompare) > 0 Or InStr(1, s, """", vbBinaryCompare) > 0 Then
        TV2_CsvCel = """" & s & """"
    Else
        TV2_CsvCel = s
    End If
End Function

Private Sub TV2_LerCatalogoCenario(ByVal cenarioId As String, ByRef dominioOut As String, ByRef cenarioOut As String, ByRef contextoOut As String)
    Dim ws As Worksheet
    Dim ultLinha As Long
    Dim r As Long

    If Trim$(cenarioId) = "" Then Exit Sub

    Set ws = TV2_EnsureCatalogoSheet()
    ultLinha = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row

    For r = 2 To ultLinha
        If Trim$(CStr(ws.Cells(r, 1).Value)) = cenarioId Then
            dominioOut = Trim$(CStr(ws.Cells(r, 5).Value))
            cenarioOut = Trim$(CStr(ws.Cells(r, 6).Value))
            contextoOut = Trim$(CStr(ws.Cells(r, 7).Value))
            Exit Sub
        End If
    Next r
End Sub
