Attribute VB_Name = "Teste_Bateria_Oficial"
Option Explicit

Private Const SHEET_TESTE_OFICIAL As String = "RESULTADO_QA"
Private Const TOTAL_TESTES_PREVISTO As Long = 200  ' ajustar conforme contagem real

Private Const STATUS_OK As String = "OK"
Private Const STATUS_FAIL As String = "FALHA"
Private Const STATUS_INFO As String = "INFO"
Private Const STATUS_MANUAL As String = "MANUAL_ASSISTIDO"

Private Const BA_STATUS_EMP_ATIVA As String = "ATIVA"
Private Const BA_STATUS_EMP_INATIVA As String = "INATIVA"
Private Const BA_STATUS_EMP_SUSPENSA As String = "SUSPENSA_GLOBAL"
Private Const BA_STATUS_CRED_ATIVO As String = "ATIVO"
Private Const BA_STATUS_CRED_INATIVO As String = "INATIVO"
Private Const BA_MOTIVO_SEM_APTOS As String = "SEM_CREDENCIADOS_APTOS"
Private Const BA_STATUS_PREOS_AGUARDANDO As String = "AGUARDANDO_ACEITE"
Private Const BA_STATUS_PREOS_RECUSADA As String = "RECUSADA"
Private Const BA_STATUS_PREOS_EXPIRADA As String = "EXPIRADA"
Private Const BA_STATUS_PREOS_CONVERTIDA As String = "CONVERTIDA_OS"
Private Const BA_STATUS_OS_EXEC As String = "EM_EXECUCAO"
Private Const BA_STATUS_OS_CONCLUIDA As String = "CONCLUIDA"
Private Const BA_STATUS_OS_CANCELADA As String = "CANCELADA"

Private gExecucaoId As String
Private gLinhaResultado As Long
Private gOk As Long
Private gFail As Long
Private gManual As Long
Private gDelayVisualMs As Long
Private gUltimaLinhaEmpresaCanonica As Long
Private gTesteOfPreparado As Boolean
Private gTesteOfEstavaProtegida As Boolean
Private gTesteOfSenhaProtecao As String
Private gRegistrarEmPlanilha As Boolean
Private gAtivCanonA As String
Private gAtivCanonB As String
Private gAtivCanonC As String
Private gAtivDescA As String
Private gAtivDescB As String
Private gAtivDescC As String

Public Sub BA_SetModoExecucaoVisual(ByVal execucaoLenta As Boolean)
    If execucaoLenta Then
        gDelayVisualMs = 1800
    Else
        gDelayVisualMs = 0
    End If
End Sub

Public Sub RunBateriaOficial()
    Dim displayAlertsAnterior As Boolean
    Dim fatalNumero As Long
    Dim fatalDescricao As String
    Dim fatalOrigem As String
    Dim csvPath As String
    Dim csvPathFalhas As String
    Dim msgFim As String

    On Error GoTo Erro

    BA_InitExecucao
    displayAlertsAnterior = Application.DisplayAlerts
    Application.DisplayAlerts = False
    ' No modo visual, manter ScreenUpdating ligado para dashboard ao vivo
    If gDelayVisualMs > 0 Then Application.ScreenUpdating = True
    BA_LogInfo "BOOT", "Iniciando bateria oficial", _
        "Executar bateria oficial do baseline compile-clean", _
        "Execução iniciada com planilha compilando limpo"

    BA_Bloco0_Preparacao
    BA_Bloco1_CenarioLiteral
    BA_Bloco2_Expansao
    BA_Bloco3_RegressaoTecnica
    BA_Bloco4_Combinatoria
    BA_Bloco5_ExportacaoEReset

    BA_AtualizarResumo
    BA_FormatacaoFinal
    Application.DisplayAlerts = displayAlertsAnterior
    Application.StatusBar = False

    csvPath = ""
    csvPathFalhas = ""
    If gRegistrarEmPlanilha And gFail > 0 Then
        On Error Resume Next
        csvPathFalhas = CTR_ExportarTesteOficialFalhasCSV()
        On Error GoTo Erro
    End If

    msgFim = "Bateria Oficial concluída. OK=" & gOk & " | FALHA=" & gFail & " | MANUAL=" & gManual
    If gFail = 0 Then
        msgFim = msgFim & vbCrLf & vbCrLf & "Sem falhas; nenhum CSV exportado."
    ElseIf Len(csvPathFalhas) > 0 Then
        msgFim = msgFim & vbCrLf & vbCrLf & "CSV somente falhas:" & vbCrLf & csvPathFalhas
    ElseIf gRegistrarEmPlanilha Then
        msgFim = msgFim & vbCrLf & vbCrLf & "Falhas encontradas, mas o CSV somente falhas não pôde ser gerado."
    ElseIf Not gRegistrarEmPlanilha Then
        msgFim = msgFim & vbCrLf & vbCrLf & "Obs.: não foi possível registrar em RESULTADO_QA (possível proteção)."
    End If
    MsgBox msgFim, vbInformation, "Bateria Oficial"
    BA_FinalizarExecucao
    Exit Sub

Erro:
    fatalNumero = Err.Number
    fatalDescricao = Err.Description
    fatalOrigem = Err.Source
    csvPath = ""
    csvPathFalhas = ""
    If fatalDescricao = "" Then
        fatalDescricao = "Falha não diagnosticada pelo VBA. A execução foi interrompida antes de concluir a bateria."
    End If
    If fatalOrigem = "" Then
        fatalOrigem = "Origem não identificada"
    End If

    On Error Resume Next
    Application.DisplayAlerts = displayAlertsAnterior
    Application.StatusBar = False
    BA_Log STATUS_FAIL, "FATAL", "FATAL_Execucao", _
        "Executar bateria oficial completa", _
        "Execução sem erro fatal", _
        "Erro fatal " & CStr(fatalNumero) & ": " & fatalDescricao & " | ORIGEM=" & fatalOrigem, _
        "A bateria precisa falhar de forma rastreável"
    BA_AtualizarResumo
    If gRegistrarEmPlanilha Then
        csvPathFalhas = CTR_ExportarTesteOficialFalhasCSV()
    End If
    BA_FinalizarExecucao
    MsgBox "Erro fatal na bateria oficial:" & vbCrLf & _
           CStr(fatalNumero) & " - " & fatalDescricao & vbCrLf & _
           "Origem: " & fatalOrigem & _
           IIf(Len(csvPathFalhas) > 0, vbCrLf & vbCrLf & "CSV somente falhas:" & vbCrLf & csvPathFalhas, ""), _
           vbCritical, "Bateria Oficial"
End Sub

Private Sub BA_FinalizarExecucao()
    On Error Resume Next
    If gTesteOfPreparado Then
        Dim ws As Worksheet
        Set ws = ThisWorkbook.Sheets(SHEET_TESTE_OFICIAL)
        Call Util_RestaurarProtecaoAba(ws, gTesteOfEstavaProtegida, gTesteOfSenhaProtecao)
    End If
    gTesteOfPreparado = False
    On Error GoTo 0
End Sub

Public Sub AbrirResultadosBateriaOficial()
    Dim ws As Worksheet
    Set ws = BA_EnsureResultSheet()
    ws.Activate
End Sub

Private Sub BA_Bloco0_Preparacao()
    Dim backupPath As String

    BA_ResetBaseOperacional
    BA_GarantirBaselineEstrutural
    BA_LogAssert "BO_000_ResetCompleto", _
        BA_CountLinhas(SHEET_EMPRESAS) = 0 And BA_CountLinhas(SHEET_ENTIDADE) = 0 And BA_CountLinhas(SHEET_CREDENCIADOS) = 0 And BA_CountLinhas(SHEET_PREOS) = 0 And BA_CountLinhas(SHEET_CAD_OS) = 0 And BA_CountLinhas(SHEET_ATIVIDADES) >= 3 And BA_CountLinhas(SHEET_CAD_SERV) >= 3, _
        "Base transacional vazia com baseline estrutural preservado", _
        "EMP=" & BA_CountLinhas(SHEET_EMPRESAS) & "; ENT=" & BA_CountLinhas(SHEET_ENTIDADE) & "; ATIV=" & BA_CountLinhas(SHEET_ATIVIDADES) & "; SERV=" & BA_CountLinhas(SHEET_CAD_SERV) & "; CRED=" & BA_CountLinhas(SHEET_CREDENCIADOS) & "; PREOS=" & BA_CountLinhas(SHEET_PREOS) & "; OS=" & BA_CountLinhas(SHEET_CAD_OS), _
        "Garantir ambiente deterministico sem apagar CNAEs e servicos estruturais", _
        "Resetar somente dados transacionais"

    BA_SetConfig
    BA_LogAssert "BO_001_ConfigurarParametros", _
        GetConfig().municipio = "Municipio de Auditoria V12" And GetConfig().GESTOR_NOME = "Gestor Auditoria V12" And GetConfig().DIAS_DECISAO = 5 And GetConfig().MAX_RECUSAS = 3 And GetConfig().PERIODO_SUSPENSAO_MESES = 1, _
        "Parametros canonicos gravados em CONFIG", _
        "Municipio=" & GetConfig().municipio & "; Gestor=" & GetConfig().GESTOR_NOME & "; Prazo=" & GetConfig().DIAS_DECISAO & "; MaxRecusas=" & GetConfig().MAX_RECUSAS & "; MesesSusp=" & GetConfig().PERIODO_SUSPENSAO_MESES, _
        "Fixar o contrato de parametros da auditoria", _
        "Salvar parametros canonicamente"
    BA_LogAssert "BO_004_ProtecaoSetup", _
        ThisWorkbook.Sheets(SHEET_CONFIG).ProtectContents, _
        "Aba CONFIG protegida apos setConfig", _
        "ProtectContents=" & CStr(ThisWorkbook.Sheets(SHEET_CONFIG).ProtectContents), _
        "Blindar integridade da CONFIG em execucoes de bateria", _
        "Verificar protecao da aba CONFIG"
    BA_LogAssert "BO_005_CounterInicial", _
        BA_ValorCounter(SHEET_EMPRESAS) = 0 And BA_ValorCounter(SHEET_ENTIDADE) = 0 And BA_ValorCounter(SHEET_CREDENCIADOS) = 0 And BA_ValorCounter(SHEET_PREOS) = 0 And BA_ValorCounter(SHEET_CAD_OS) = 0 And Len(gAtivCanonA) > 0 And Len(gAtivCanonB) > 0 And Len(gAtivCanonC) > 0, _
        "Contadores transacionais zerados e baseline estrutural mapeado", _
        "EMP=" & CStr(BA_ValorCounter(SHEET_EMPRESAS)) & "; ENT=" & CStr(BA_ValorCounter(SHEET_ENTIDADE)) & "; ATIV_A=" & gAtivCanonA & "; ATIV_B=" & gAtivCanonB & "; ATIV_C=" & gAtivCanonC & "; CRED=" & CStr(BA_ValorCounter(SHEET_CREDENCIADOS)) & "; PREOS=" & CStr(BA_ValorCounter(SHEET_PREOS)) & "; OS=" & CStr(BA_ValorCounter(SHEET_CAD_OS)), _
        "Garantir IDs deterministicas antes dos cenarios sem zerar CNAEs", _
        "Verificar contadores operacionais e mapeamento estrutural"
    BA_LogAssert "BO_007_GestorConfig", _
        GetConfig().DIAS_DECISAO = 5 And GetConfig().MAX_RECUSAS = 3, _
        "GetConfig retorna valores canônicos do baseline", _
        "DIAS=" & CStr(GetConfig().DIAS_DECISAO) & "; MAX_RECUSAS=" & CStr(GetConfig().MAX_RECUSAS), _
        "Blindar leitura da CONFIG via GetConfig()", _
        "Revalidar leitura pós-setConfig"
    BA_LogAssert "BO_008_ConfigCamposExt", _
        Trim$(UCase$(CStr(ThisWorkbook.Sheets(SHEET_CONFIG).Cells(LINHA_CFG_VALORES, COL_CFG_UF).Value))) = "PE" And _
        InStr(1, Trim$(CStr(ThisWorkbook.Sheets(SHEET_CONFIG).Cells(LINHA_CFG_VALORES, COL_CFG_SECRETARIA).Value)), "Secretaria", vbTextCompare) > 0, _
        "UF e Secretaria gravadas nas colunas estendidas da CONFIG", _
        "UF=" & Trim$(CStr(ThisWorkbook.Sheets(SHEET_CONFIG).Cells(LINHA_CFG_VALORES, COL_CFG_UF).Value)) & "; SEC=" & Trim$(CStr(ThisWorkbook.Sheets(SHEET_CONFIG).Cells(LINHA_CFG_VALORES, COL_CFG_SECRETARIA).Value)), _
        "Validar COL_CFG_UF e COL_CFG_SECRETARIA após BA_SetConfig", _
        "Ler células da aba CONFIG"

    backupPath = BA_CriarBackup("BATERIA_OFICIAL_2026_03_25")
    BA_LogAssert "BO_002_BackupNovoPeriodo", _
        backupPath <> "", _
        "Backup do periodo criado", _
        backupPath, _
        "Garantir rastreabilidade e rollback da auditoria", _
        "Criar snapshot do periodo"

    BA_ResetBaseOperacional
    BA_GarantirBaselineEstrutural
    BA_LogAssert "BO_003_ResetPosPeriodo", _
        BA_CountLinhas(SHEET_EMPRESAS) = 0 And BA_CountLinhas(SHEET_ENTIDADE) = 0 And BA_CountLinhas(SHEET_CREDENCIADOS) = 0 And BA_CountLinhas(SHEET_ATIVIDADES) >= 3 And BA_CountLinhas(SHEET_CAD_SERV) >= 3, _
        "Base transacional limpa apos geracao do periodo", _
        "EMP=" & BA_CountLinhas(SHEET_EMPRESAS) & "; ENT=" & BA_CountLinhas(SHEET_ENTIDADE) & "; ATIV=" & BA_CountLinhas(SHEET_ATIVIDADES) & "; SERV=" & BA_CountLinhas(SHEET_CAD_SERV) & "; CRED=" & BA_CountLinhas(SHEET_CREDENCIADOS), _
        "Garantir que os testes recomecem sem apagar a baseline estrutural", _
        "Resetar base apos criar periodo"
End Sub

Private Sub BA_Bloco1_CenarioLiteral()
    Dim fila As String
    Dim resRod As TRodizioResultado
    Dim notas(1 To 10) As Integer
    Dim osId As String
    Dim preId As String
    Dim res As TResult
    Dim linhaEmpresa As Long
    Dim empChk As TEmpresa
    Dim linhaChk As Long

    BA_LogAssert "BO_010_CadastrarItemA", _
        BA_ExisteServico("001", "001", 100@), _
        "Item A estrutural disponivel", _
        BA_DescServico("001", "001") & " | R$ " & Format$(BA_ValorServico("001", "001"), "0.00"), _
        "Validar que a baseline estrutural oferece a primeira atividade do roteiro", _
        "Conferir Item A preservado"

    BA_LogAssert "BO_011_CadastrarItemB", _
        BA_ExisteServico("002", "001", 200@), _
        "Item B estrutural disponivel", _
        BA_DescServico("002", "001") & " | R$ " & Format$(BA_ValorServico("002", "001"), "0.00"), _
        "Validar que a baseline estrutural oferece a segunda atividade do roteiro", _
        "Conferir Item B preservado"

    BA_LogAssert "BO_012_CadastrarItemC", _
        BA_ExisteServico("182", "001", 300@), _
        "Item C estrutural disponivel", _
        BA_DescServico("182", "001") & " | R$ " & Format$(BA_ValorServico("182", "001"), "0.00"), _
        "Validar que a baseline estrutural oferece a terceira atividade do roteiro", _
        "Conferir Item C preservado"

    BA_CadastrarEntidadeCanonica "001", "10.000.000/0001-01", "Local 1", "Rua Local 1, 100", "Centro", "Municipio de Auditoria V12", "50000-001", "PE"
    BA_LogAssert "BO_020_CadastrarLocal1", BA_ExisteEntidade("001", "Local 1"), "Local 1 cadastrado com todos os campos", BA_ResumoEntidade("001"), "Validar persistencia completa da entidade 1", "Cadastrar Local 1"

    BA_CadastrarEntidadeCanonica "002", "20.000.000/0001-02", "Local 2", "Rua Local 2, 200", "Bairro 2", "Municipio de Auditoria V12", "50000-002", "PE"
    BA_LogAssert "BO_021_CadastrarLocal2", BA_ExisteEntidade("002", "Local 2"), "Local 2 cadastrado com todos os campos", BA_ResumoEntidade("002"), "Validar persistencia completa da entidade 2", "Cadastrar Local 2"

    BA_CadastrarEntidadeCanonica "003", "30.000.000/0001-03", "Local 3", "Rua Local 3, 300", "Bairro 3", "Municipio de Auditoria V12", "50000-003", "PE"
    BA_LogAssert "BO_022_CadastrarLocal3", BA_ExisteEntidade("003", "Local 3"), "Local 3 cadastrado com todos os campos", BA_ResumoEntidade("003"), "Validar persistencia completa da entidade 3", "Cadastrar Local 3"
    BA_LogAssert "BO_023_IntegridadeEntidades_Base", _
        BA_CountOcorrenciasEntidade("001", "10.000.000/0001-01") = 1 And _
        BA_CountOcorrenciasEntidade("002", "20.000.000/0001-02") = 1 And _
        BA_CountOcorrenciasEntidade("003", "30.000.000/0001-03") = 1, _
        "Entidades sem duplicidade entre abas ativa/inativa na base canonica", _
        "E1=" & CStr(BA_CountOcorrenciasEntidade("001", "10.000.000/0001-01")) & "; E2=" & CStr(BA_CountOcorrenciasEntidade("002", "20.000.000/0001-02")) & "; E3=" & CStr(BA_CountOcorrenciasEntidade("003", "30.000.000/0001-03")), _
        "Cobrir integridade de ID/CNPJ das entidades apos cadastro canonico", _
        "Contar ocorrencias de entidades ativas e inativas"
    BA_LogAssert "BO_024_GuardaReativacaoEntidade", _
        BA_ReativacaoEntidadeDeveBloquearDuplicidade("001", "10.000.000/0001-01"), _
        "Guarda de reativacao da entidade detecta duplicidade existente", _
        "LinhaDetectada=" & CStr(BA_LinhaDuplicadaEntidade("001", "10.000.000/0001-01")), _
        "Blindar reativacao manual contra copia duplicada para a aba ENTIDADE", _
        "Simular checagem de duplicidade de entidade"

    BA_CadastrarEmpresaCanonica "001", "11.111.111/1111-11", "Empresa 1", "Responsavel Empresa 1", "111.111.111-11", "Rua Empresa 1, 10", "Centro", "Municipio de Auditoria V12", "51000-001", "PE", "(81) 3000-0001", "(81) 90000-0001", "empresa1@auditoria.test", "1001", "1 A 2 ANOS"
    linhaEmpresa = gUltimaLinhaEmpresaCanonica
    BA_LogAssert "BO_030_CadastrarEmpresa1", BA_ExisteEmpresaNaLinha(linhaEmpresa, "001", "Empresa 1"), "Empresa 1 cadastrada com todos os campos", BA_ResumoEmpresaNaLinha(linhaEmpresa), "Validar migracao para Empresa e persistencia de campos", "Cadastrar Empresa 1"
    BA_LogAssert "BO_033_IntegridadeEmpresas_Base", _
        BA_CountOcorrenciasEmpresa("001", "11.111.111/1111-11") = 1, _
        "Empresa 1 sem duplicidade entre abas ativa/inativa", _
        "E1=" & CStr(BA_CountOcorrenciasEmpresa("001", "11.111.111/1111-11")), _
        "Cobrir integridade de ID/CNPJ da empresa na base canonica", _
        "Contar ocorrencias da Empresa 1 nas abas ativa e inativa"
    BA_LogAssert "BO_034_GuardaReativacaoEmpresa", _
        BA_ReativacaoEmpresaDeveBloquearDuplicidade("001", "11.111.111/1111-11"), _
        "Guarda de reativacao da empresa detecta duplicidade existente", _
        "LinhaDetectada=" & CStr(BA_LinhaDuplicadaEmpresa("001", "11.111.111/1111-11")), _
        "Blindar reativacao manual contra copia duplicada para a aba EMPRESAS", _
        "Simular checagem de duplicidade de empresa"
    BA_LogAssert "BO_035_EmpStatusInicial", BA_StatusEmpresa("001") = BA_STATUS_EMP_ATIVA, "STATUS_GLOBAL inicial = ATIVA", BA_StatusEmpresa("001"), "Validar estado inicial da empresa no cadastro", "Conferir status apos Empresa 1"
    BA_LogAssert "BO_036_EmpRecusaInicial", BA_QtdRecusasEmpresa("001") = 0, "QTD_RECUSAS inicial = 0", CStr(BA_QtdRecusasEmpresa("001")), "Baseline de recusas antes de fluxos", "Conferir recusas apos Empresa 1"
    empChk = LerEmpresa("001", linhaChk)
    BA_LogAssert "BO_037_EmpSuspInicial", empChk.DT_FIM_SUSP = CDate(0), "Sem suspensao agendada (DT_FIM_SUSP vazio/zero)", Format$(empChk.DT_FIM_SUSP, "yyyy-mm-dd"), "Empresa nova sem data fim suspensao", "Conferir DT_FIM_SUSP apos Empresa 1"

    BA_CadastrarEmpresaCanonica "002", "22.222.222/2222-22", "Empresa 2", "Responsavel Empresa 2", "222.222.222-22", "Rua Empresa 2, 20", "Bairro 2", "Municipio de Auditoria V12", "51000-002", "PE", "(81) 3000-0002", "(81) 90000-0002", "empresa2@auditoria.test", "1002", "2 A 5 ANOS"
    linhaEmpresa = gUltimaLinhaEmpresaCanonica
    BA_LogAssert "BO_031_CadastrarEmpresa2", BA_ExisteEmpresaNaLinha(linhaEmpresa, "002", "Empresa 2"), "Empresa 2 cadastrada com todos os campos", BA_ResumoEmpresaNaLinha(linhaEmpresa), "Validar migracao para Empresa e persistencia de campos", "Cadastrar Empresa 2"

    BA_CadastrarEmpresaCanonica "003", "33.333.333/3333-33", "Empresa 3", "Responsavel Empresa 3", "333.333.333-33", "Rua Empresa 3, 30", "Bairro 3", "Municipio de Auditoria V12", "51000-003", "PE", "(81) 3000-0003", "(81) 90000-0003", "empresa3@auditoria.test", "1003", "+ DE 5 ANOS"
    linhaEmpresa = gUltimaLinhaEmpresaCanonica
    BA_LogAssert "BO_032_CadastrarEmpresa3", BA_ExisteEmpresaNaLinha(linhaEmpresa, "003", "Empresa 3"), "Empresa 3 cadastrada com todos os campos", BA_ResumoEmpresaNaLinha(linhaEmpresa), "Validar migracao para Empresa e persistencia de campos", "Cadastrar Empresa 3"

    BA_LogAssert "BO_040_CredenciarEmpresa1_ItemA", BA_CredenciarAtividade("001", "001", "001") = "INSERIDO", "Empresa 1 credenciada no Item A", BA_FilaCsv("001"), "Montar a fila inicial do Item A", "Credenciar Empresa 1 em 001"
    BA_LogAssert "BO_041_CredenciarEmpresa2_ItemB", BA_CredenciarAtividade("002", "002", "001") = "INSERIDO", "Empresa 2 credenciada no Item B", BA_FilaCsv("002"), "Montar a fila inicial do Item B", "Credenciar Empresa 2 em 002"
    BA_LogAssert "BO_042_CredenciarEmpresa3_ItemC", BA_CredenciarAtividade("003", "182", "001") = "INSERIDO", "Empresa 3 credenciada no Item C", BA_FilaCsv("182"), "Montar a fila inicial do Item C", "Credenciar Empresa 3 em 182"
    BA_LogAssert "BO_043_CredenciarEmpresa1_ItemB", BA_CredenciarAtividade("001", "002", "001") = "INSERIDO", "Empresa 1 tambem credenciada no Item B", BA_FilaCsv("002"), "Ampliar concorrencia no Item B", "Credenciar Empresa 1 em 002"
    BA_LogAssert "BO_044_CredenciarEmpresa1_ItemC", BA_CredenciarAtividade("001", "182", "001") = "INSERIDO", "Empresa 1 tambem credenciada no Item C", BA_FilaCsv("182"), "Ampliar concorrencia no Item C", "Credenciar Empresa 1 em 182"
    BA_LogAssert "BO_045_CredenciarEmpresa2_ItemB_DuplicadoEsperado", BA_CredenciarAtividade("002", "002", "001") = "DUPLICADO", "Mensagem/efeito de duplicidade de credenciamento", BA_FilaCsv("002"), "Validar que o sistema nao duplica credenciamento existente", "Credenciar novamente Empresa 2 em 002"
    BA_LogAssert "BO_046_CredenciarEmpresa2_ItemC", BA_CredenciarAtividade("002", "182", "001") = "INSERIDO", "Empresa 2 credenciada no Item C", BA_FilaCsv("182"), "Fechar a fila tripla do Item C", "Credenciar Empresa 2 em 182"
    BA_LogAssert "BO_047_CredenciarEmpresa3_ItemC_DuplicadoEsperado", BA_CredenciarAtividade("003", "182", "001") = "DUPLICADO", "Mensagem/efeito de duplicidade de credenciamento", BA_FilaCsv("182"), "Validar que o sistema nao duplica credenciamento existente", "Credenciar novamente Empresa 3 em 182"

    fila = BA_FilaCsv("182")
    BA_LogAssert "BO_048_FilaOrdem_ItemC", fila = "003,001,002", "Fila inicial do Item C = 003,001,002", fila, "Plano 146: ordem da fila apos credenciamentos", "Conferir classificacao inicial do Item C"
    BA_LogAssert "BO_049_CredStatusTodosAtivos", _
        BA_StatusCred("001", "001") = BA_STATUS_CRED_ATIVO And BA_StatusCred("002", "002") = BA_STATUS_CRED_ATIVO And BA_StatusCred("003", "182") = BA_STATUS_CRED_ATIVO And BA_StatusCred("001", "002") = BA_STATUS_CRED_ATIVO And BA_StatusCred("001", "182") = BA_STATUS_CRED_ATIVO And BA_StatusCred("002", "182") = BA_STATUS_CRED_ATIVO, _
        "Todos os credenciamentos do cenario com STATUS_CRED = ATIVO", _
        BA_StatusCred("001", "001") & ";" & BA_StatusCred("002", "002") & ";" & BA_StatusCred("003", "182") & ";" & BA_StatusCred("001", "002") & ";" & BA_StatusCred("001", "182") & ";" & BA_StatusCred("002", "182"), _
        "Plano 146: credenciamento ativo apos insercoes", _
        "Conferir STATUS_CRED nas linhas de CREDENCIADOS"

    BA_LogAssert "BO_050_FilaOrdem_ItemA", BA_FilaCsv("001") = "001", "Fila Item A = 001", BA_FilaCsv("001"), "Baseline com um credenciado na atividade", "Conferir fila do Item A apos credenciamentos"
    BA_LogAssert "BO_051_FilaOrdem_ItemB", BA_FilaCsv("002") = "002,001", "Fila Item B = 002,001", BA_FilaCsv("002"), "Baseline com dois credenciados na atividade", "Conferir fila do Item B apos credenciamentos"
    BA_LogAssert "BO_052_CredLinhasAposSetup", BA_CountLinhas(SHEET_CREDENCIADOS) = 6, "Seis registros em CREDENCIADOS apos o setup", CStr(BA_CountLinhas(SHEET_CREDENCIADOS)), "Contagem esperada do cenario literal (seis pares unicos)", "Contar linhas de CREDENCIADOS antes do rodizio"
    BA_LogAssert "BO_053_Emp2Emp3BaselineInicial", BA_StatusEmpresa("002") = BA_STATUS_EMP_ATIVA And BA_StatusEmpresa("003") = BA_STATUS_EMP_ATIVA And BA_QtdRecusasEmpresa("002") = 0 And BA_QtdRecusasEmpresa("003") = 0, "Empresas 2 e 3 ativas com zero recusas", BA_StatusEmpresa("002") & "/" & BA_StatusEmpresa("003") & " | R2=" & CStr(BA_QtdRecusasEmpresa("002")) & " R3=" & CStr(BA_QtdRecusasEmpresa("003")), "Baseline antes de inativacoes e rodizio", "Conferir status e recusas das empresas 2 e 3"

    BA_RodizioPasso "BO_060_RodizioItemC_Local1", "182", "003", True, "Executar o primeiro giro do Item C"
    BA_RodizioPasso "BO_061_RodizioItemC_Local2", "182", "001", True, "Executar o segundo giro do Item C"
    BA_RodizioPasso "BO_062_RodizioItemC_Local3", "182", "002", True, "Executar o terceiro giro do Item C"

    BA_RodizioPasso "BO_070_RodizioItemA_Local1", "001", "001", True, "Executar o primeiro giro do Item A"
    BA_RodizioPasso "BO_071_RodizioItemA_Local2", "001", "001", True, "Executar o segundo giro do Item A"
    BA_RodizioPasso "BO_072_RodizioItemA_Local3", "001", "001", True, "Executar o terceiro giro do Item A"

    BA_RodizioPasso "BO_080_RodizioItemB_Iteracao1", "002", "002", True, "Executar o primeiro giro do Item B"
    BA_RodizioPasso "BO_081_RodizioItemB_Iteracao2", "002", "001", True, "Executar o segundo giro do Item B"
    BA_RodizioPasso "BO_082_RodizioItemB_Iteracao3", "002", "002", True, "Executar o terceiro giro do Item B"

    BA_LogAssert "BO_054_AposRodizioBasico_TodasEmpresasAtivas", BA_StatusEmpresa("001") = BA_STATUS_EMP_ATIVA And BA_StatusEmpresa("002") = BA_STATUS_EMP_ATIVA And BA_StatusEmpresa("003") = BA_STATUS_EMP_ATIVA, "Tres empresas permanecem ATIVA apos giros", BA_StatusEmpresa("001") & ";" & BA_StatusEmpresa("002") & ";" & BA_StatusEmpresa("003"), "Rodizio basico nao deve alterar STATUS_GLOBAL", "Conferir status apos BO_060 a BO_082"
    BA_LogAssert "BO_055_AposRodizioBasico_CredStatusAtivo", _
        BA_StatusCred("001", "001") = BA_STATUS_CRED_ATIVO And BA_StatusCred("002", "002") = BA_STATUS_CRED_ATIVO And BA_StatusCred("003", "182") = BA_STATUS_CRED_ATIVO And BA_StatusCred("001", "002") = BA_STATUS_CRED_ATIVO And BA_StatusCred("001", "182") = BA_STATUS_CRED_ATIVO And BA_StatusCred("002", "182") = BA_STATUS_CRED_ATIVO, _
        "Todos os credenciamentos seguem ATIVO apos giros", _
        BA_StatusCred("001", "001") & ";" & BA_StatusCred("002", "002") & ";" & BA_StatusCred("003", "182"), _
        "Avanco de fila sem punicao nao inativa cred", _
        "Conferir STATUS_CRED apos rodizio basico"
    BA_LogAssert "BO_056_AposRodizioBasico_RecusasZeradas", BA_QtdRecusasEmpresa("001") = 0 And BA_QtdRecusasEmpresa("002") = 0 And BA_QtdRecusasEmpresa("003") = 0, "QTD_RECUSAS = 0 para empresas 1 a 3", "R1=" & CStr(BA_QtdRecusasEmpresa("001")) & " R2=" & CStr(BA_QtdRecusasEmpresa("002")) & " R3=" & CStr(BA_QtdRecusasEmpresa("003")), "Avanco sem punicao nao incrementa recusas globais", "Conferir recusas apos rodizio basico"
    BA_LogAssert "BO_057_AposRodizioBasico_CredLinhas", BA_CountLinhas(SHEET_CREDENCIADOS) = 6, "Ainda seis linhas em CREDENCIADOS", CStr(BA_CountLinhas(SHEET_CREDENCIADOS)), "Nenhuma insercao/remocao de cred no rodizio basico", "Contar CREDENCIADOS apos BO_060 a BO_082"

    BA_SetEmpresaStatus "001", BA_STATUS_EMP_INATIVA, CDate(0), 0
    BA_LogAssert "BO_100_InativarEmpresa1", BA_StatusEmpresa("001") = BA_STATUS_EMP_INATIVA, "Empresa 1 inativada", BA_StatusEmpresa("001"), "Validar filtro de empresa inativa no rodizio", "Inativar Empresa 1"

    resRod = BA_SelecionarEmpresa("001")
    BA_LogAssert "BO_101_ItemA_SemEmpresa", Not resRod.encontrou, "Nenhuma empresa disponivel no Item A com Empresa 1 inativa", BA_ResumoRodizio(resRod), "Item A tem somente Empresa 1; ao inativar, o rodizio deve ficar vazio", "Executar rodizio do Item A com Empresa 1 inativa"

    resRod = BA_SelecionarEmpresa("002")
    BA_LogAssert "BO_102_ItemB_ComEmpresa1Inativa", resRod.encontrou And BA_Pad3(resRod.Empresa.EMP_ID) = "002", "Item B seleciona apenas Empresa 2", BA_ResumoRodizio(resRod), "Validar exclusao da empresa inativa na fila binaria", "Executar rodizio do Item B com Empresa 1 inativa"

    resRod = BA_SelecionarEmpresa("182")
    BA_LogAssert "BO_103_ItemC_ComEmpresa1Inativa", resRod.encontrou And BA_Pad3(resRod.Empresa.EMP_ID) = "003", "Item C exclui Empresa 1 inativa e continua com Empresa 3/Empresa 2", BA_ResumoRodizio(resRod), "Validar exclusao da empresa inativa na fila tripla", "Executar rodizio do Item C com Empresa 1 inativa"

    BA_LogAssert "BO_104_Emp1Inativa_CredLinhas", BA_CountLinhas(SHEET_CREDENCIADOS) = 6, "Seis linhas em CREDENCIADOS com Empresa 1 inativa", CStr(BA_CountLinhas(SHEET_CREDENCIADOS)), "Inativacao global nao remove registros de credenciamento", "Contar CREDENCIADOS com Emp1 inativa"
    BA_LogAssert "BO_105_Emp1Inativa_CredStatusAtivo", _
        BA_StatusCred("001", "001") = BA_STATUS_CRED_ATIVO And BA_StatusCred("002", "002") = BA_STATUS_CRED_ATIVO And BA_StatusCred("003", "182") = BA_STATUS_CRED_ATIVO And BA_StatusCred("001", "002") = BA_STATUS_CRED_ATIVO And BA_StatusCred("001", "182") = BA_STATUS_CRED_ATIVO And BA_StatusCred("002", "182") = BA_STATUS_CRED_ATIVO, _
        "STATUS_CRED permanece ATIVO nas seis linhas", _
        BA_StatusCred("001", "001") & ";" & BA_StatusCred("001", "182"), _
        "Inativar empresa nao deve alterar coluna de status do cred", _
        "Conferir STATUS_CRED com Emp1 inativa"

    BA_SetEmpresaStatus "001", BA_STATUS_EMP_ATIVA, CDate(0), 0
    BA_LogAssert "BO_110_ReativarEmpresa1", BA_StatusEmpresa("001") = BA_STATUS_EMP_ATIVA, "Empresa 1 reativada", BA_StatusEmpresa("001"), "Validar retorno da empresa ao rodizio", "Reativar Empresa 1"

    BA_LogAssert "BO_111_ItemA_AposReativacao", BA_SelecionarEmpresa("001").encontrou And BA_Pad3(BA_SelecionarEmpresa("001").Empresa.EMP_ID) = "001", "Empresa 1 volta a participar do Item A", BA_ResumoRodizio(BA_SelecionarEmpresa("001")), "A empresa reativada deve voltar ao rodizio", "Executar Item A apos reativacao"

    BA_LogAssert "BO_112_AposReativacao_CredLinhas", BA_CountLinhas(SHEET_CREDENCIADOS) = 6, "Seis linhas em CREDENCIADOS apos reativacao", CStr(BA_CountLinhas(SHEET_CREDENCIADOS)), "Ciclo inativar/reativar nao altera quantidade de cred", "Contar CREDENCIADOS apos BO_110-111"
    BA_LogAssert "BO_113_AposReativacao_RecusasZeradas", BA_QtdRecusasEmpresa("001") = 0 And BA_QtdRecusasEmpresa("002") = 0 And BA_QtdRecusasEmpresa("003") = 0, "QTD_RECUSAS = 0 para empresas 1 a 3 apos reativacao", "R1=" & CStr(BA_QtdRecusasEmpresa("001")) & " R2=" & CStr(BA_QtdRecusasEmpresa("002")) & " R3=" & CStr(BA_QtdRecusasEmpresa("003")), "Fluxo de inativacao nao deve punir por recusa", "Conferir recusas apos reativacao"

    preId = BA_EmitirPreOS("001", "182", "001", 2)
    BA_LogAssert "BO_120_FluxoCompleto_PreOS", preId <> "", "Pre-OS emitida no fluxo completo", BA_StatusPreOS(preId) & " | PREOS_ID=" & preId & " | EMP=" & BA_PreOSEmpresa(preId), "Validar emissao da Pre-OS no cenario didatico", "Emitir Pre-OS do fluxo completo"
    BA_LogAssert "BO_114_FluxoCompleto_PreOS_StatusAguardando", BA_StatusPreOS(preId) = BA_STATUS_PREOS_AGUARDANDO, "STATUS da Pre-OS = AGUARDANDO_ACEITE antes do aceite/OS", BA_StatusPreOS(preId) & " | PREOS_ID=" & preId, "Contrato de emissao sem conversao imediata", "Conferir status da Pre-OS apos EmitirPreOS"

    osId = BA_EmitirOS(preId, DateAdd("d", 30, Date), "EMP-BO120")
    BA_LogAssert "BO_120_FluxoCompleto_OS", osId <> "", "OS emitida a partir da Pre-OS", BA_StatusOS(osId) & " | OS_ID=" & osId, "Validar conversao de Pre-OS em OS", "Emitir OS do fluxo completo"
    BA_LogAssert "BO_115_FluxoCompleto_OS_StatusExecucao", BA_StatusOS(osId) = BA_STATUS_OS_EXEC, "STATUS da OS = EM_EXECUCAO apos emissao", BA_StatusOS(osId) & " | OS_ID=" & osId, "Contrato antes da avaliacao e do cancelamento paralelo", "Conferir status da OS apos EmitirOS"

    BA_MontarNotas 8, notas
    res = AvaliarOS(osId, "Gestor Auditoria V12", notas, 2, "Fluxo completo OK", "")
    BA_LogAssert "BO_120_FluxoCompleto_Avaliacao", res.Sucesso And BA_StatusOS(osId) = BA_STATUS_OS_CONCLUIDA, "OS concluida e avaliada", res.Mensagem & " | STATUS=" & BA_StatusOS(osId), "Validar fechamento completo do servico", "Avaliar fornecedor e encerrar fluxo"

    preId = BA_EmitirPreOS("002", "002", "001", 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 15, Date), "EMP-BO121")
    res = CancelarOS(osId, "Teste oficial de cancelamento")
    BA_LogAssert "BO_121_CancelamentoOS", res.Sucesso And BA_StatusOS(osId) = BA_STATUS_OS_CANCELADA, "OS cancelada com sucesso", res.Mensagem & " | STATUS=" & BA_StatusOS(osId), "Validar caminho de cancelamento no fluxo real", "Cancelar OS apos emissao"

    BA_LogAssert "BO_116_AposDoisFluxos_ContagemPreOS", BA_CountLinhas(SHEET_PREOS) = 2, "Duas Pre-OS persistidas no cenario", CStr(BA_CountLinhas(SHEET_PREOS)), "Fluxo completo + fluxo de cancelamento geram duas linhas", "Contar PRE_OS apos BO_120 e BO_121"
    BA_LogAssert "BO_117_AposDoisFluxos_ContagemOS", BA_CountLinhas(SHEET_CAD_OS) = 2, "Duas OS persistidas no cenario", CStr(BA_CountLinhas(SHEET_CAD_OS)), "Uma OS concluida e uma cancelada", "Contar CAD_OS apos BO_120 e BO_121"

    BA_LogManual "BO_130_RelatorioEmpresasPorServico", "Emitir e analisar relatorio de empresas por servico", "Relatorio com dados corretos de cadastro, credenciamento e classificacao", "Validar leitura humana do relatorio de empresas por servico"
    BA_LogManual "BO_131_RelatorioOSPorEmpresa", "Emitir e analisar relatorio de OS por empresa", "Relatorio com dados corretos de execucao e avaliacao", "Validar leitura humana do relatorio de OS por empresa"
    BA_LogManual "BO_140_ImpressaoPreOS", "Imprimir Pre-OS do fluxo completo", "Template preenchido corretamente", "Validar impressao e layout humano da Pre-OS"
    BA_LogManual "BO_150_ImpressaoOS", "Imprimir OS do fluxo completo", "Template preenchido corretamente", "Validar impressao e layout humano da OS"

    BA_ResetBaseOperacional
    BA_GarantirBaselineEstrutural
    BA_LogAssert "BO_160_ResetFinal", _
        BA_CountLinhas(SHEET_EMPRESAS) = 0 And BA_CountLinhas(SHEET_ENTIDADE) = 0 And BA_CountLinhas(SHEET_CREDENCIADOS) = 0 And BA_CountLinhas(SHEET_PREOS) = 0 And BA_CountLinhas(SHEET_CAD_OS) = 0 And BA_CountLinhas(SHEET_ATIVIDADES) >= 3 And BA_CountLinhas(SHEET_CAD_SERV) >= 3, _
        "Planilha transacional limpa e baseline estrutural preservada", _
        "EMP=" & BA_CountLinhas(SHEET_EMPRESAS) & "; ENT=" & BA_CountLinhas(SHEET_ENTIDADE) & "; ATIV=" & BA_CountLinhas(SHEET_ATIVIDADES) & "; SERV=" & BA_CountLinhas(SHEET_CAD_SERV), _
        "Encerrar o cenario didatico sem residuos operacionais", _
        "Reset final do bloco literal"
End Sub

Private Sub BA_Bloco2_Expansao()
    BA_PrepararCenarioBase

    BA_RodizioPasso "BO_200_Rodizio5Ciclos_Ativ182_1", "182", "003", True, "Ciclo 1 do Item C"
    BA_RodizioPasso "BO_200_Rodizio5Ciclos_Ativ182_2", "182", "001", True, "Ciclo 2 do Item C"
    BA_RodizioPasso "BO_200_Rodizio5Ciclos_Ativ182_3", "182", "002", True, "Ciclo 3 do Item C"
    BA_RodizioPasso "BO_200_Rodizio5Ciclos_Ativ182_4", "182", "003", True, "Ciclo 4 do Item C"
    BA_RodizioPasso "BO_200_Rodizio5Ciclos_Ativ182_5", "182", "001", True, "Ciclo 5 do Item C"

    BA_PrepararCenarioBase
    BA_RodizioPasso "BO_201_Rodizio5Ciclos_Ativ002_1", "002", "002", True, "Ciclo 1 do Item B"
    BA_RodizioPasso "BO_201_Rodizio5Ciclos_Ativ002_2", "002", "001", True, "Ciclo 2 do Item B"
    BA_RodizioPasso "BO_201_Rodizio5Ciclos_Ativ002_3", "002", "002", True, "Ciclo 3 do Item B"
    BA_RodizioPasso "BO_201_Rodizio5Ciclos_Ativ002_4", "002", "001", True, "Ciclo 4 do Item B"
    BA_RodizioPasso "BO_201_Rodizio5Ciclos_Ativ002_5", "002", "002", True, "Ciclo 5 do Item B"

    BA_PrepararCenarioBase
    BA_RodizioPasso "BO_202_Rodizio5Ciclos_Ativ001_1", "001", "001", True, "Ciclo 1 do Item A"
    BA_RodizioPasso "BO_202_Rodizio5Ciclos_Ativ001_2", "001", "001", True, "Ciclo 2 do Item A"
    BA_RodizioPasso "BO_202_Rodizio5Ciclos_Ativ001_3", "001", "001", True, "Ciclo 3 do Item A"
    BA_RodizioPasso "BO_202_Rodizio5Ciclos_Ativ001_4", "001", "001", True, "Ciclo 4 do Item A"
    BA_RodizioPasso "BO_202_Rodizio5Ciclos_Ativ001_5", "001", "001", True, "Ciclo 5 do Item A"

    BA_PrepararCenarioBase
    BA_SetEmpresaStatus "001", BA_STATUS_EMP_INATIVA, CDate(0), 0
    BA_RodizioPasso "BO_203_ItemB_AposInativacao_1", "002", "002", True, "Item B com Empresa 1 inativa"
    BA_RodizioPasso "BO_204_ItemC_AposInativacao_1", "182", "003", True, "Item C com Empresa 1 inativa"
    BA_RodizioPasso "BO_204_ItemC_AposInativacao_2", "182", "002", True, "Item C com Empresa 1 inativa ciclo 2"

    BA_PrepararCenarioBase
    BA_RecusarEmissao "BO_205_RecusaPreOS", "001", "182", "001", "Recusa de auditoria", "001"

    BA_PrepararCenarioBase
    BA_ExpirarEmissao "BO_206_ExpiracaoPreOS", "001", "182", "001", "001"

    BA_PrepararCenarioBase
    BA_SetEmpresaStatus "001", BA_STATUS_EMP_SUSPENSA, DateAdd("d", -1, Date), 3
    BA_RodizioPasso "BO_207_ReativacaoAutomatica", "001", "001", True, "Empresa 1 suspensa com prazo vencido"

    BA_PrepararCenarioBase
    BA_ValidarCancelamentoSemAvanco "BO_208_CancelamentoSemAvanco", "001", "182", "001"

    BA_PrepararCenarioBase
    BA_ValidarFiltroD_OSAberta "BO_210_FiltroD_OSAberta", "182"

    BA_PrepararCenarioBase
    BA_ValidarFiltroE_PreOSPendente "BO_211_FiltroE_PreOSPendente", "182"

    BA_PrepararCenarioBase
    BA_ValidarAvaliacaoInvalida "BO_240_AvaliacaoInvalidaMaior10", 11

    BA_PrepararCenarioBase
    BA_ValidarAvaliacaoInvalida "BO_241_AvaliacaoInvalidaMenor0", -1

    BA_PrepararCenarioBase
    BA_ValidarAvaliacaoArrayInvalido "BO_242_AvaliacaoArrayInvalido"

    BA_PrepararCenarioBase
    BA_ValidarFiltroDExaustivo "BO_250_FiltroD_Exaustivo", "182"

    BA_PrepararCenarioBase
    BA_ValidarFiltroEExaustivo "BO_251_FiltroE_Exaustivo", "182"

    BA_PrepararCenarioBase
    BA_ValidarCombinacaoDE "BO_252_CombinacaoDE", "182"
End Sub

Private Sub BA_Bloco3_RegressaoTecnica()
    Dim resRod As TRodizioResultado
    Dim resOp As TResult
    Dim preId As String
    Dim osId As String
    Dim notas(1 To 10) As Integer
    Dim r As TResult

    BA_PrepararCenarioBase
    BA_SetCredStatus "001", "001", BA_STATUS_CRED_INATIVO
    resRod = BA_SelecionarEmpresa("001")
    BA_LogAssert "BO_300_FiltroA_StatusCredInativo", Not resRod.encontrou, "Sem empresa apta quando credenciamento esta inativo", BA_ResumoRodizio(resRod), "Validar filtro A do rodizio", "Inativar credenciamento de Empresa 1 no Item A"

    BA_PrepararCenarioBase
    BA_SetEmpresaStatus "001", BA_STATUS_EMP_SUSPENSA, DateAdd("m", 1, Date), 2
    resRod = BA_SelecionarEmpresa("001")
    BA_LogAssert "BO_301_FiltroB_SuspensaFutura", Not resRod.encontrou, "Empresa suspensa com prazo futuro nao participa", BA_ResumoRodizio(resRod), "Validar filtro B com suspensao ativa", "Suspender Empresa 1 com prazo futuro"

    BA_PrepararCenarioBase
    BA_SetEmpresaStatus "001", BA_STATUS_EMP_SUSPENSA, DateAdd("d", -1, Date), 2
    resRod = BA_SelecionarEmpresa("001")
    BA_LogAssert "BO_302_FiltroB_SuspensaExpirada", resRod.encontrou And BA_Pad3(resRod.Empresa.EMP_ID) = "001" And BA_StatusEmpresa("001") = BA_STATUS_EMP_ATIVA, "Empresa suspensa expirada volta automaticamente", BA_ResumoRodizio(resRod) & " | STATUS=" & BA_StatusEmpresa("001"), "Validar reativacao automatica do rodizio", "Suspender Empresa 1 com prazo vencido"

    BA_PrepararCenarioBase
    BA_SetEmpresaStatus "001", BA_STATUS_EMP_INATIVA, CDate(0), 0
    resRod = BA_SelecionarEmpresa("001")
    BA_LogAssert "BO_303_FiltroC_EmpresaInativa", Not resRod.encontrou, "Empresa inativa nao participa do rodizio", BA_ResumoRodizio(resRod), "Validar filtro C do rodizio", "Inativar Empresa 1 no Item A"

    BA_PrepararCenarioBase
    resOp = EmitirPreOS("001", BA_CodServicoLegado("001", "001"), 5)
    BA_LogAssert "BO_304_EmissaoCurta_ServicoValido", resOp.Sucesso, "Emissao curta com COD_ATIV_SERV legado continua funcionando", resOp.Mensagem & " | PREOS=" & resOp.IdGerado, "Garantir compatibilidade com servico concatenado usando a atividade canonica mapeada", "Emitir Pre-OS usando codigo legado dinamico"

    BA_PrepararCenarioBase
    BA_SetEmpresaStatus "001", BA_STATUS_EMP_ATIVA, CDate(0), 3
    resRod = BA_SelecionarEmpresa("001")
    BA_LogAssert "BO_305_FronteiraRecusas", resRod.encontrou And BA_Pad3(resRod.Empresa.EMP_ID) = "001" And BA_StatusEmpresa("001") = BA_STATUS_EMP_ATIVA, "Empresa ativa com QTD_RECUSAS no limite continua participando ate ser suspensa por transicao valida", BA_ResumoRodizio(resRod) & " | STATUS=" & BA_StatusEmpresa("001") & " | QTD=" & CStr(BA_QtdRecusasEmpresa("001")), "Validar que o contador isolado de recusas nao bloqueia o rodizio sem suspensao", "Ajustar QTD_RECUSAS para limite maximo"

    BA_PrepararCenarioBase
    BA_ValidarProtecaoAbas "BO_310_ProtecaoAbas"

    BA_PrepararCenarioBase
    BA_ValidarPersistenciaWorkbook "BO_311_PersistenciaWorkbook"

    BA_PrepararCenarioBase
    BA_LogAssert "BO_320_IntegridadeIdsIguais", BA_IdsIguaisCanonico("1", "001") And BA_IdsIguaisCanonico("001", "001") And Not BA_IdsIguaisCanonico("001", "002"), "Comparacao canonica de IDs preserva equivalencia esperada", "1~001 | 001~001 | 001!=002", "Blindar o contrato de IDs usados em filtros e buscas", "Executar helper canonico de equivalencia"

    BA_PrepararCenarioBase
    BA_LogAssert "BO_321_IntegridadeExtrairServId", BA_ExtrairServIdCanonico("001001") = "001" And BA_ExtrairServIdCanonico("001|001") = "001" And BA_ExtrairServIdCanonico("182|003") = "003", "Extracao canonica do SERV_ID funciona em chaves legadas e novas", BA_ExtrairServIdCanonico("001001") & "|" & BA_ExtrairServIdCanonico("001|001") & "|" & BA_ExtrairServIdCanonico("182|003"), "Blindar a traducao entre formatos de servico usados no sistema", "Executar helper canonico de extracao"

    BA_PrepararCenarioBase
    preId = BA_EmitirPreOS("001", "182", "001", 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 3, Date), "EMP-BO330")
    notas(1) = 8: notas(2) = 8: notas(3) = 8: notas(4) = 8: notas(5) = 8
    notas(6) = 8: notas(7) = 8: notas(8) = 8: notas(9) = 8: notas(10) = 8
    r = AvaliarOS(osId, "Gestor QA", notas, 10, "Media oito", "")
    BA_LogAssert "BO_330_AvaliacaoValida", r.Sucesso And BA_StatusOS(osId) = BA_STATUS_OS_CONCLUIDA, "Avaliacao valida conclui OS", BA_StatusOS(osId) & " | MSG=" & r.Mensagem, "Validar servico de avaliacao com media calculada", "Avaliar OS com notas 8"

    BA_PrepararCenarioBase
    BA_LogInfo "BO_330b_NotaMin_Limite", "Nota minima: media=5 nao suspende", _
        "MEDIA=5 deve manter empresa ATIVA (5 >= 5)", _
        "NOTA_MIN=" & Format$(GetNotaMinimaAvaliacao(), "0.0")
    preId = BA_EmitirPreOS("001", "182", "001", 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 3, Date), "EMP-BO330b")
    notas(1) = 5: notas(2) = 5: notas(3) = 5: notas(4) = 5: notas(5) = 5
    notas(6) = 5: notas(7) = 5: notas(8) = 5: notas(9) = 5: notas(10) = 5
    r = AvaliarOS(osId, "Gestor QA", notas, 10, "Media cinco", "")
    BA_LogAssert "BO_330b_NotaMin_5_NaoSuspende", r.Sucesso And BA_StatusOS(osId) = BA_STATUS_OS_CONCLUIDA And BA_StatusEmpresa("003") = BA_STATUS_EMP_ATIVA, _
        "Media 5 conclui OS e NAO suspende (limite inclusivo)", _
        BA_StatusOS(osId) & " | EMP03=" & BA_StatusEmpresa("003") & " | MSG=" & r.Mensagem, _
        "Validar fronteira: media igual a nota minima nao suspende", _
        "Avaliar com notas 5"

    BA_PrepararCenarioBase
    preId = BA_EmitirPreOS("001", "182", "001", 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 3, Date), "EMP-BO330c")
    notas(1) = 4: notas(2) = 4: notas(3) = 4: notas(4) = 4: notas(5) = 4
    notas(6) = 4: notas(7) = 4: notas(8) = 4: notas(9) = 4: notas(10) = 4
    r = AvaliarOS(osId, "Gestor QA", notas, 10, "Media quatro", "")
    BA_LogAssert "BO_330c_NotaMin_4_Suspende", r.Sucesso And BA_StatusOS(osId) = BA_STATUS_OS_CONCLUIDA And BA_StatusEmpresa("003") = BA_STATUS_EMP_SUSPENSA, _
        "Media 4 conclui OS e SUSPENDE (4 < 5)", _
        BA_StatusOS(osId) & " | EMP03=" & BA_StatusEmpresa("003") & " | MSG=" & r.Mensagem, _
        "Validar regra: media abaixo da nota minima suspende empresa", _
        "Avaliar com notas 4"

    BA_PrepararCenarioBase
    preId = BA_EmitirPreOS("001", "182", "001", 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 3, Date), "EMP-BO330d")
    notas(1) = 0: notas(2) = 0: notas(3) = 0: notas(4) = 0: notas(5) = 0
    notas(6) = 0: notas(7) = 0: notas(8) = 0: notas(9) = 0: notas(10) = 0
    r = AvaliarOS(osId, "Gestor QA", notas, 10, "Media zero", "")
    BA_LogAssert "BO_330d_NotaMin_0_Suspende", r.Sucesso And BA_StatusOS(osId) = BA_STATUS_OS_CONCLUIDA And BA_StatusEmpresa("003") = BA_STATUS_EMP_SUSPENSA, _
        "Media 0 conclui OS e SUSPENDE (0 < 5)", _
        BA_StatusOS(osId) & " | EMP03=" & BA_StatusEmpresa("003") & " | MSG=" & r.Mensagem, _
        "Cobrir fronteira inferior (nota zero)", _
        "Avaliar com notas 0"

    BA_PrepararCenarioBase
    preId = BA_EmitirPreOS("001", "182", "001", 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 3, Date), "EMP-BO330e")
    notas(1) = 10: notas(2) = 10: notas(3) = 10: notas(4) = 10: notas(5) = 10
    notas(6) = 10: notas(7) = 10: notas(8) = 10: notas(9) = 10: notas(10) = 10
    r = AvaliarOS(osId, "Gestor QA", notas, 10, "Media dez", "")
    BA_LogAssert "BO_330e_NotaMin_10_NaoSuspende", r.Sucesso And BA_StatusOS(osId) = BA_STATUS_OS_CONCLUIDA And BA_StatusEmpresa("003") = BA_STATUS_EMP_ATIVA, _
        "Media 10 conclui OS e NAO suspende", _
        BA_StatusOS(osId) & " | EMP03=" & BA_StatusEmpresa("003") & " | MSG=" & r.Mensagem, _
        "Cobrir fronteira superior (nota 10)", _
        "Avaliar com notas 10"

    BA_PrepararCenarioBase
    preId = BA_EmitirPreOS("001", "182", "001", 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 3, Date), "EMP-BO330f")
    notas(1) = 5: notas(2) = 5: notas(3) = 5: notas(4) = 5: notas(5) = 5
    notas(6) = 5: notas(7) = 5: notas(8) = 5: notas(9) = 4: notas(10) = 5
    r = AvaliarOS(osId, "Gestor QA", notas, 10, "Media quatro ponto nove", "")
    BA_LogAssert "BO_330f_NotaMin_4_9_Suspende", r.Sucesso And BA_StatusOS(osId) = BA_STATUS_OS_CONCLUIDA And BA_StatusEmpresa("003") = BA_STATUS_EMP_SUSPENSA, _
        "Media 4,9 conclui OS e SUSPENDE (4,9 < 5)", _
        BA_StatusOS(osId) & " | EMP03=" & BA_StatusEmpresa("003") & " | MSG=" & r.Mensagem, _
        "Cobrir fronteira decimal (4,9)", _
        "Avaliar com 9 notas 5 e uma nota 4"

    BA_PrepararCenarioBase
    preId = BA_EmitirPreOS("001", "182", "001", 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 3, Date), "EMP-BO330g")
    notas(1) = 4: notas(2) = 4: notas(3) = 4: notas(4) = 4: notas(5) = 4
    notas(6) = 4: notas(7) = 4: notas(8) = 4: notas(9) = 4: notas(10) = 4
    Dim empAfter As TEmpresa
    Dim linhaEmpAfter As Long
    r = AvaliarOS(osId, "Gestor QA", notas, 10, "DT_FIM_SUSP esperado", "")
    empAfter = LerEmpresa("003", linhaEmpAfter)
    BA_LogAssert "BO_330g_DtFimSusp", r.Sucesso And BA_StatusEmpresa("003") = BA_STATUS_EMP_SUSPENSA And linhaEmpAfter > 0 And empAfter.DT_FIM_SUSP > Date, _
        "Ao suspender por nota, DT_FIM_SUSP deve ser hoje + meses de suspensao", _
        "STATUS=" & BA_StatusEmpresa("003") & " | DT_FIM_SUSP=" & Format$(empAfter.DT_FIM_SUSP, "yyyy-mm-dd"), _
        "Validar que a suspensao por nota grava DT_FIM_SUSP", _
        "Avaliar com notas 4 e conferir DT_FIM_SUSP"
End Sub

Private Sub BA_Bloco4_Combinatoria()
    Dim preId As String
    Dim osId As String
    Dim res As TResult
    Dim notas(1 To 10) As Integer
    Dim resRod As TRodizioResultado

    BA_PrepararCenarioBase
    BA_SetEmpresaStatus "001", BA_STATUS_EMP_ATIVA, CDate(0), 0
    resRod = BA_SelecionarEmpresa("001")
    BA_LogAssert "BO_400_MatrizStatusGlobal_Ativa", resRod.encontrou And BA_Pad3(resRod.Empresa.EMP_ID) = "001", "Empresa ativa participa do rodizio", BA_ResumoRodizio(resRod), "Cobrir status global ATIVA", "Selecionar Item A com Empresa 1 ativa"

    BA_PrepararCenarioBase
    BA_SetEmpresaStatus "001", BA_STATUS_EMP_INATIVA, CDate(0), 0
    resRod = BA_SelecionarEmpresa("001")
    BA_LogAssert "BO_400_MatrizStatusGlobal_Inativa", Not resRod.encontrou, "Empresa inativa fica fora do rodizio", BA_ResumoRodizio(resRod), "Cobrir status global INATIVA", "Selecionar Item A com Empresa 1 inativa"

    BA_PrepararCenarioBase
    BA_SetEmpresaStatus "001", BA_STATUS_EMP_SUSPENSA, DateAdd("d", 2, Date), 1
    resRod = BA_SelecionarEmpresa("001")
    BA_LogAssert "BO_400_MatrizStatusGlobal_Suspensa", Not resRod.encontrou, "Empresa suspensa com prazo futuro nao participa", BA_ResumoRodizio(resRod), "Cobrir status global SUSPENSA_GLOBAL", "Selecionar Item A com Empresa 1 suspensa"

    BA_PrepararCenarioBase
    BA_SetEmpresaStatus "001", BA_STATUS_EMP_SUSPENSA, DateAdd("d", -1, Date), 1
    resRod = BA_SelecionarEmpresa("001")
    BA_LogAssert "BO_400_MatrizStatusGlobal_Reativada", resRod.encontrou And BA_Pad3(resRod.Empresa.EMP_ID) = "001" And BA_StatusEmpresa("001") = BA_STATUS_EMP_ATIVA, "Empresa suspensa vencida volta a ATIVA", BA_ResumoRodizio(resRod) & " | STATUS=" & BA_StatusEmpresa("001"), "Cobrir transicao automatica SUSPENSA -> ATIVA", "Selecionar Item A com suspensao vencida"

    BA_PrepararCenarioBase
    BA_SetEmpresaStatus "001", BA_STATUS_EMP_ATIVA, CDate(0), 0
    BA_LogAssert "BO_410_MatrizFronteiraRecusas_0", BA_QtdRecusasEmpresa("001") = 0, "Baseline de recusas inicia em zero", CStr(BA_QtdRecusasEmpresa("001")), "Validar fronteira inferior antes das recusas", "Preparar cenario base"
    BA_RecusarEmissao "BO_410_MatrizFronteiraRecusas_Recusa1", "001", "001", "001", "Recusa fronteira 1"
    BA_RecusarEmissao "BO_410_MatrizFronteiraRecusas_Recusa2", "001", "001", "001", "Recusa fronteira 2"
    BA_LogAssert "BO_410_MatrizFronteiraRecusas_Apos2", BA_QtdRecusasEmpresa("001") = 2 And BA_StatusEmpresa("001") = BA_STATUS_EMP_ATIVA, "Duas recusas mantem empresa ativa", CStr(BA_QtdRecusasEmpresa("001")) & " | STATUS=" & BA_StatusEmpresa("001"), "Cobrir fronteira abaixo do limite de suspensao", "Executar duas recusas consecutivas"
    BA_RecusarEmissao "BO_410_MatrizFronteiraRecusas_Recusa3", "001", "001", "001", "Recusa fronteira 3"
    BA_LogAssert "BO_410_MatrizFronteiraRecusas_Apos3", BA_QtdRecusasEmpresa("001") >= GetConfig().MAX_RECUSAS And BA_StatusEmpresa("001") = BA_STATUS_EMP_SUSPENSA, "Terceira recusa suspende empresa conforme limite", CStr(BA_QtdRecusasEmpresa("001")) & " | STATUS=" & BA_StatusEmpresa("001"), "Cobrir fronteira superior de recusas", "Executar terceira recusa"

    BA_PrepararCenarioBase
    preId = BA_EmitirPreOS("001", "182", "001", 1)
    BA_LogAssert "BO_420_MatrizTransicaoPreOS_Recusa", preId <> "", "Pre-OS emitida para transicao de recusa", BA_StatusPreOS(preId), "Cobrir transicao AGUARDANDO_ACEITE -> RECUSADA", "Emitir Pre-OS para recusa"
    res = RecusarPreOS(preId, "Recusa de matriz")
    BA_LogAssert "BO_420_MatrizTransicaoPreOS_Recusada", res.Sucesso And BA_StatusPreOS(preId) = BA_STATUS_PREOS_RECUSADA, "Transicao AGUARDANDO_ACEITE -> RECUSADA", BA_StatusPreOS(preId), "Validar transicao de estado da Pre-OS", "Recusar Pre-OS"
    res = RecusarPreOS(preId, "Recusa novamente (invalida)")
    BA_LogAssert "BO_420_RecusaJaRecusada", Not res.Sucesso And BA_StatusPreOS(preId) = BA_STATUS_PREOS_RECUSADA, "Recusar PreOS ja recusada deve falhar", res.Mensagem & " | STATUS=" & BA_StatusPreOS(preId), "Validar transicao invalida (RECUSADA -> RECUSADA)", "Recusar a mesma Pre-OS novamente"

    BA_PrepararCenarioBase
    preId = BA_EmitirPreOS("001", "182", "001", 1)
    res = ExpirarPreOS(preId)
    BA_LogAssert "BO_420_MatrizTransicaoPreOS_Expirada", res.Sucesso And BA_StatusPreOS(preId) = BA_STATUS_PREOS_EXPIRADA, "Transicao AGUARDANDO_ACEITE -> EXPIRADA", BA_StatusPreOS(preId), "Validar transicao por prazo expirado", "Expirar Pre-OS"
    res = ExpirarPreOS(preId)
    BA_LogAssert "BO_420_ExpirarJaExpirada", Not res.Sucesso And BA_StatusPreOS(preId) = BA_STATUS_PREOS_EXPIRADA, "Expirar PreOS ja expirada deve falhar", res.Mensagem & " | STATUS=" & BA_StatusPreOS(preId), "Validar transicao invalida (EXPIRADA -> EXPIRADA)", "Expirar a mesma Pre-OS novamente"

    BA_PrepararCenarioBase
    preId = BA_EmitirPreOS("001", "182", "001", 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 5, Date), "EMP-BO420")
    BA_LogAssert "BO_420_MatrizTransicaoPreOS_Convertida", osId <> "" And BA_StatusPreOS(preId) = BA_STATUS_PREOS_CONVERTIDA, "Transicao AGUARDANDO_ACEITE -> CONVERTIDA_OS", BA_StatusPreOS(preId) & " | OS_ID=" & osId, "Validar transicao de Pre-OS para OS", "Converter Pre-OS em OS"
    res = RecusarPreOS(preId, "Recusar convertida (invalida)")
    BA_LogAssert "BO_420_RecusarConvertida", Not res.Sucesso And BA_StatusPreOS(preId) = BA_STATUS_PREOS_CONVERTIDA, "Recusar PreOS CONVERTIDA_OS deve falhar", res.Mensagem & " | STATUS=" & BA_StatusPreOS(preId), "Validar transicao invalida (CONVERTIDA_OS -> RECUSADA)", "Tentar recusar Pre-OS ja convertida"
    res = EmitirOS(preId, DateAdd("d", 5, Date), "EMP-BO420-INV")
    BA_LogAssert "BO_420_EmitirOSJaConvertida", Not res.Sucesso And BA_StatusPreOS(preId) = BA_STATUS_PREOS_CONVERTIDA, "Emitir OS a partir de PreOS ja convertida deve falhar", res.Mensagem & " | STATUS=" & BA_StatusPreOS(preId), "Validar emissao invalida (PreOS CONVERTIDA_OS)", "Tentar emitir OS novamente para a mesma Pre-OS"

    BA_PrepararCenarioBase
    preId = BA_EmitirPreOS("001", "182", "001", 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 5, Date), "EMP-BO430A")
    BA_MontarNotas 10, notas
    res = AvaliarOS(osId, "Gestor Auditoria V12", notas, 1, "Matriz concluida", "")
    BA_LogAssert "BO_430_MatrizTransicaoOS_Concluida", res.Sucesso And BA_StatusOS(osId) = BA_STATUS_OS_CONCLUIDA, "Transicao EM_EXECUCAO -> CONCLUIDA", BA_StatusOS(osId), "Validar transicao final da OS por avaliacao", "Concluir OS"
    res = CancelarOS(osId, "Cancelar OS concluida (invalida)")
    BA_LogAssert "BO_430_CancelConcluida", Not res.Sucesso And BA_StatusOS(osId) = BA_STATUS_OS_CONCLUIDA, "Cancelar OS CONCLUIDA deve falhar", res.Mensagem & " | STATUS=" & BA_StatusOS(osId), "Validar transicao invalida (CONCLUIDA -> CANCELADA)", "Tentar cancelar OS ja concluida"

    BA_PrepararCenarioBase
    preId = BA_EmitirPreOS("001", "002", "001", 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 5, Date), "EMP-BO430B")
    res = CancelarOS(osId, "Matriz cancelada")
    BA_LogAssert "BO_430_MatrizTransicaoOS_Cancelada", res.Sucesso And BA_StatusOS(osId) = BA_STATUS_OS_CANCELADA, "Transicao EM_EXECUCAO -> CANCELADA", BA_StatusOS(osId), "Validar transicao de cancelamento da OS", "Cancelar OS em execucao"
    BA_MontarNotas 10, notas
    res = AvaliarOS(osId, "Gestor QA", notas, 1, "Avaliar OS cancelada (invalida)", "")
    BA_LogAssert "BO_430_ConcluirCancelada", Not res.Sucesso And BA_StatusOS(osId) = BA_STATUS_OS_CANCELADA, "Avaliar OS CANCELADA deve falhar", res.Mensagem & " | STATUS=" & BA_StatusOS(osId), "Validar transicao invalida (CANCELADA -> CONCLUIDA)", "Tentar avaliar OS cancelada"

    BA_PrepararCenarioBase
    BA_LogAssert "BO_440_MatrizCapacidade_0Empresas", Not BA_SelecionarEmpresa("999").encontrou, "Atividade sem empresas retorna vazio", BA_ResumoRodizio(BA_SelecionarEmpresa("999")), "Cobrir fronteira de atividade sem elegiveis", "Selecionar atividade inexistente"

    BA_PrepararCenarioBase
    BA_SetCredStatus "001", "002", BA_STATUS_CRED_INATIVO
    resRod = BA_SelecionarEmpresa("002")
    BA_LogAssert "BO_440_MatrizCapacidade_1Empresa", resRod.encontrou And BA_Pad3(resRod.Empresa.EMP_ID) = "002", "Atividade com 1 empresa apta seleciona unico candidato", BA_ResumoRodizio(resRod), "Cobrir fronteira de uma empresa apta", "Inativar credencial de Empresa 1 no Item B"

    BA_PrepararCenarioBase
    resRod = BA_SelecionarEmpresa("182")
    BA_LogAssert "BO_440_MatrizCapacidade_3Empresas", resRod.encontrou And BA_Pad3(resRod.Empresa.EMP_ID) = "003", "Atividade com 3 empresas respeita primeira da fila", BA_ResumoRodizio(resRod), "Cobrir fronteira de tres empresas aptas", "Selecionar Item C com tres empresas aptas"
End Sub

Private Sub BA_Bloco5_ExportacaoEReset()
    BA_LogInfo "BO_500_ExportarResumoTecnico", "Resumo tecnico consolidado na aba TESTE_OFICIAL", _
        "Aba TESTE_OFICIAL preenchida com resultado detalhado e resumo executivo", _
        "Execução=" & gExecucaoId
    BA_LogInfo "BO_501_ExportarResumoHumano", "Resumo humano consolidado na aba TESTE_OFICIAL", _
        "Aba TESTE_OFICIAL pode ser usada como trilha de auditoria e checklist humano", _
        "OK=" & gOk & " | FALHA=" & gFail & " | MANUAL=" & gManual

    BA_LogInfo "BO_505_PreRelatorio", "Checkpoint antes do relatorio impresso/CSV", _
        "Todos os logs da bateria ja estao em TESTE_OFICIAL; relatorio e opcional na Central", _
        "OK=" & gOk & " | FALHA=" & gFail & " | MANUAL=" & gManual

    BA_LogInfo "BO_506_PosRelatorio", "Relatório humano disponível sob demanda na Central", _
        "A bateria não força impressão nem exportação adicional durante a execução", _
        "OK=" & gOk & " | FALHA=" & gFail & " | MANUAL=" & gManual

    ' --- RESET CONDICIONAL: só executa com confirmação do operador ---
    Dim respReset As Long
    respReset = MsgBox("Bateria concluída. OK=" & gOk & " | FALHA=" & gFail & " | MANUAL=" & gManual & vbCrLf & vbCrLf & _
        "Deseja LIMPAR a base operacional agora?" & vbCrLf & _
        "(Dados de teste serão removidos. A aba RESULTADO_QA será preservada.)", _
        vbQuestion + vbYesNo, "Reset Pós-Bateria V12")

    If respReset = vbYes Then
        BA_ResetBaseOperacional
        BA_GarantirBaselineEstrutural
        BA_LogAssert "BO_510_ResetFinalPosAuditoria", _
            BA_CountLinhas(SHEET_EMPRESAS) = 0 And BA_CountLinhas(SHEET_ENTIDADE) = 0 And BA_CountLinhas(SHEET_CREDENCIADOS) = 0 And BA_CountLinhas(SHEET_PREOS) = 0 And BA_CountLinhas(SHEET_CAD_OS) = 0 And BA_CountLinhas(SHEET_ATIVIDADES) >= 3 And BA_CountLinhas(SHEET_CAD_SERV) >= 3, _
            "Planilha transacional limpa após auditoria", _
            "EMP=" & BA_CountLinhas(SHEET_EMPRESAS) & "; ENT=" & BA_CountLinhas(SHEET_ENTIDADE) & "; ATIV=" & BA_CountLinhas(SHEET_ATIVIDADES) & "; SERV=" & BA_CountLinhas(SHEET_CAD_SERV) & "; CRED=" & BA_CountLinhas(SHEET_CREDENCIADOS), _
            "Entregar a planilha pronta para nova execução sem perder a baseline estrutural", _
            "Executar reset final pós auditoria"
    Else
        BA_LogInfo "BO_510_ResetPulado", "Reset não executado por decisão do operador", _
            "Base operacional mantida com dados de teste para inspeção", _
            "Operador optou por manter dados"
    End If
End Sub

Private Sub BA_PrepararCenarioBase()
    BA_ResetBaseOperacional
    BA_GarantirBaselineEstrutural
    BA_SetConfig

    BA_CadastrarEntidadeCanonica "001", "10.000.000/0001-01", "Local 1", "Rua Local 1, 100", "Centro", "Municipio de Auditoria V12", "50000-001", "PE"
    BA_CadastrarEntidadeCanonica "002", "20.000.000/0001-02", "Local 2", "Rua Local 2, 200", "Bairro 2", "Municipio de Auditoria V12", "50000-002", "PE"
    BA_CadastrarEntidadeCanonica "003", "30.000.000/0001-03", "Local 3", "Rua Local 3, 300", "Bairro 3", "Municipio de Auditoria V12", "50000-003", "PE"

    BA_CadastrarEmpresaCanonica "001", "11.111.111/1111-11", "Empresa 1", "Responsavel Empresa 1", "111.111.111-11", "Rua Empresa 1, 10", "Centro", "Municipio de Auditoria V12", "51000-001", "PE", "(81) 3000-0001", "(81) 90000-0001", "empresa1@auditoria.test", "1001", "1 A 2 ANOS"
    BA_CadastrarEmpresaCanonica "002", "22.222.222/2222-22", "Empresa 2", "Responsavel Empresa 2", "222.222.222-22", "Rua Empresa 2, 20", "Bairro 2", "Municipio de Auditoria V12", "51000-002", "PE", "(81) 3000-0002", "(81) 90000-0002", "empresa2@auditoria.test", "1002", "2 A 5 ANOS"
    BA_CadastrarEmpresaCanonica "003", "33.333.333/3333-33", "Empresa 3", "Responsavel Empresa 3", "333.333.333-33", "Rua Empresa 3, 30", "Bairro 3", "Municipio de Auditoria V12", "51000-003", "PE", "(81) 3000-0003", "(81) 90000-0003", "empresa3@auditoria.test", "1003", "+ DE 5 ANOS"

    BA_CredenciarAtividade "001", "001", "001"
    BA_CredenciarAtividade "002", "002", "001"
    BA_CredenciarAtividade "003", "182", "001"
    BA_CredenciarAtividade "001", "002", "001"
    BA_CredenciarAtividade "001", "182", "001"
    BA_CredenciarAtividade "002", "182", "001"

    BA_ValidarCenarioBaseEstrutural
End Sub

Private Sub BA_ValidarCenarioBaseEstrutural()
    Dim mensagem As String

    mensagem = ""

    If BA_CountLinhas(SHEET_EMPRESAS) <> 3 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "EMPRESAS=" & CStr(BA_CountLinhas(SHEET_EMPRESAS)))
    End If
    If BA_CountLinhas(SHEET_EMPRESAS_INATIVAS) <> 0 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "EMPRESAS_INATIVAS=" & CStr(BA_CountLinhas(SHEET_EMPRESAS_INATIVAS)))
    End If
    If BA_CountLinhas(SHEET_ENTIDADE) <> 3 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "ENTIDADE=" & CStr(BA_CountLinhas(SHEET_ENTIDADE)))
    End If
    If BA_CountLinhas(SHEET_ENTIDADE_INATIVOS) <> 0 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "ENTIDADE_INATIVOS=" & CStr(BA_CountLinhas(SHEET_ENTIDADE_INATIVOS)))
    End If
    If BA_CountLinhas(SHEET_CREDENCIADOS) <> 6 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "CREDENCIADOS=" & CStr(BA_CountLinhas(SHEET_CREDENCIADOS)))
    End If
    If BA_CountLinhas(SHEET_ATIVIDADES) < 3 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "ATIVIDADES=" & CStr(BA_CountLinhas(SHEET_ATIVIDADES)))
    End If
    If BA_CountLinhas(SHEET_CAD_SERV) < 3 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "CAD_SERV=" & CStr(BA_CountLinhas(SHEET_CAD_SERV)))
    End If
    If Not BA_TemServico("001", "001") Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "SERVICO_ITEM_A_AUSENTE")
    End If
    If Not BA_TemServico("002", "001") Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "SERVICO_ITEM_B_AUSENTE")
    End If
    If Not BA_TemServico("182", "001") Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "SERVICO_ITEM_C_AUSENTE")
    End If

    If BA_CountOcorrenciasEmpresa("001", "11.111.111/1111-11") <> 1 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "EMP001_OCORRENCIAS=" & CStr(BA_CountOcorrenciasEmpresa("001", "11.111.111/1111-11")))
    End If
    If BA_CountOcorrenciasEmpresa("002", "22.222.222/2222-22") <> 1 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "EMP002_OCORRENCIAS=" & CStr(BA_CountOcorrenciasEmpresa("002", "22.222.222/2222-22")))
    End If
    If BA_CountOcorrenciasEmpresa("003", "33.333.333/3333-33") <> 1 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "EMP003_OCORRENCIAS=" & CStr(BA_CountOcorrenciasEmpresa("003", "33.333.333/3333-33")))
    End If

    If BA_CountOcorrenciasEntidade("001", "10.000.000/0001-01") <> 1 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "ENT001_OCORRENCIAS=" & CStr(BA_CountOcorrenciasEntidade("001", "10.000.000/0001-01")))
    End If
    If BA_CountOcorrenciasEntidade("002", "20.000.000/0001-02") <> 1 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "ENT002_OCORRENCIAS=" & CStr(BA_CountOcorrenciasEntidade("002", "20.000.000/0001-02")))
    End If
    If BA_CountOcorrenciasEntidade("003", "30.000.000/0001-03") <> 1 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "ENT003_OCORRENCIAS=" & CStr(BA_CountOcorrenciasEntidade("003", "30.000.000/0001-03")))
    End If

    If BA_StatusEmpresa("001") <> BA_STATUS_EMP_ATIVA Or BA_QtdRecusasEmpresa("001") <> 0 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "EMP001_STATUS=" & BA_StatusEmpresa("001") & ";QTD=" & CStr(BA_QtdRecusasEmpresa("001")))
    End If
    If BA_StatusEmpresa("002") <> BA_STATUS_EMP_ATIVA Or BA_QtdRecusasEmpresa("002") <> 0 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "EMP002_STATUS=" & BA_StatusEmpresa("002") & ";QTD=" & CStr(BA_QtdRecusasEmpresa("002")))
    End If
    If BA_StatusEmpresa("003") <> BA_STATUS_EMP_ATIVA Or BA_QtdRecusasEmpresa("003") <> 0 Then
        mensagem = BA_AcumularFalhaEstrutural(mensagem, "EMP003_STATUS=" & BA_StatusEmpresa("003") & ";QTD=" & CStr(BA_QtdRecusasEmpresa("003")))
    End If

    If mensagem <> "" Then
        Err.Raise 1004, "BA_PrepararCenarioBase", _
                  "Para garantir resultado deterministico, a bateria foi interrompida porque o cenario-base nao esta integro. " & _
                  "Corrija a inconsistencia identificada e reinicie a validacao com seguranca. Detalhes: " & mensagem
    End If
End Sub

Private Function BA_AcumularFalhaEstrutural(ByVal atual As String, ByVal trecho As String) As String
    If atual <> "" Then
        BA_AcumularFalhaEstrutural = atual & " | " & trecho
    Else
        BA_AcumularFalhaEstrutural = trecho
    End If
End Function

Private Sub BA_GarantirBaselineEstrutural()
    Call CargaInicialCNAE_SeNecessario(False)
    BA_MapearAtividadesCanonicas
    BA_GarantirServicoCanonico gAtivCanonA, gAtivDescA, 100@
    BA_GarantirServicoCanonico gAtivCanonB, gAtivDescB, 200@
    BA_GarantirServicoCanonico gAtivCanonC, gAtivDescC, 300@
    Call SincronizarDescricoesCadServComAtividades(True)
End Sub

Private Sub BA_MapearAtividadesCanonicas()
    Dim ws As Worksheet
    Dim ultima As Long
    Dim linha As Long
    Dim idAtual As String
    Dim descAtual As String
    Dim idx As Long

    gAtivCanonA = ""
    gAtivCanonB = ""
    gAtivCanonC = ""
    gAtivDescA = ""
    gAtivDescB = ""
    gAtivDescC = ""

    Set ws = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
    ultima = UltimaLinhaAba(SHEET_ATIVIDADES)
    If ultima < LINHA_DADOS Then
        Err.Raise 1004, "BA_MapearAtividadesCanonicas", "ATIVIDADES sem linhas estruturais suficientes."
    End If

    For linha = LINHA_DADOS To ultima
        idAtual = Trim$(CStr(ws.Cells(linha, COL_ATIV_ID).Value))
        descAtual = Trim$(CStr(ws.Cells(linha, COL_ATIV_DESCRICAO).Value))
        If idAtual <> "" And descAtual <> "" Then
            If IsNumeric(idAtual) Then
                If CLng(Val(idAtual)) >= 1 And CLng(Val(idAtual)) <= 999 Then
                    idx = idx + 1
                    Select Case idx
                        Case 1
                            gAtivCanonA = BA_Pad3(idAtual)
                            gAtivDescA = descAtual
                        Case 2
                            gAtivCanonB = BA_Pad3(idAtual)
                            gAtivDescB = descAtual
                        Case 3
                            gAtivCanonC = BA_Pad3(idAtual)
                            gAtivDescC = descAtual
                            Exit For
                    End Select
                End If
            End If
        End If
    Next linha

    If Len(gAtivCanonA) = 0 Or Len(gAtivCanonB) = 0 Or Len(gAtivCanonC) = 0 Then
        Err.Raise 1004, "BA_MapearAtividadesCanonicas", _
                  "Nao foi possivel mapear 3 atividades canonicas no range 001-999 a partir da baseline estrutural."
    End If
End Sub

Private Sub BA_GarantirServicoCanonico(ByVal ativIdReal As String, ByVal descricaoAtiv As String, ByVal valorPadrao As Currency)
    Dim ws As Worksheet
    Dim ultima As Long
    Dim linha As Long
    Dim linhaEncontrada As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    If Trim$(ativIdReal) = "" Then Exit Sub

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    ultima = UltimaLinhaAba(SHEET_CAD_SERV)

    For linha = LINHA_DADOS To ultima
        If IdsIguais(ws.Cells(linha, COL_SERV_ATIV_ID).Value, ativIdReal) And IdsIguais(ws.Cells(linha, COL_SERV_ID).Value, "001") Then
            linhaEncontrada = linha
            Exit For
        End If
    Next linha

    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        Err.Raise 1004, "BA_GarantirServicoCanonico", "Nao foi possivel preparar CAD_SERV."
    End If

    If linhaEncontrada = 0 Then
        linhaEncontrada = BA_NextDataRow(SHEET_CAD_SERV)
        ws.Cells(linhaEncontrada, COL_SERV_ID).Value = "001"
        ws.Cells(linhaEncontrada, COL_SERV_ATIV_ID).Value = ativIdReal
        ws.Cells(linhaEncontrada, COL_SERV_DT_CAD).Value = Now
        BA_SetCounter SHEET_CAD_SERV, 1
    End If

    If Trim$(CStr(ws.Cells(linhaEncontrada, COL_SERV_ATIV_DESC).Value)) = "" Then
        ws.Cells(linhaEncontrada, COL_SERV_ATIV_DESC).Value = descricaoAtiv
    End If
    If Trim$(CStr(ws.Cells(linhaEncontrada, COL_SERV_DESCRICAO).Value)) = "" Then
        ws.Cells(linhaEncontrada, COL_SERV_DESCRICAO).Value = descricaoAtiv
    End If
    If Val(ws.Cells(linhaEncontrada, COL_SERV_VALOR_UNIT).Value) <= 0 Then
        ws.Cells(linhaEncontrada, COL_SERV_VALOR_UNIT).Value = valorPadrao
    End If
    If Trim$(CStr(ws.Cells(linhaEncontrada, COL_SERV_DT_CAD).Value)) = "" Then
        ws.Cells(linhaEncontrada, COL_SERV_DT_CAD).Value = Now
    End If

    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
End Sub

Private Function BA_MapearAtivIdTeste(ByVal ativId As String) As String
    Select Case BA_Pad3(ativId)
        Case "001"
            BA_MapearAtivIdTeste = gAtivCanonA
        Case "002"
            BA_MapearAtivIdTeste = gAtivCanonB
        Case "182"
            BA_MapearAtivIdTeste = gAtivCanonC
        Case Else
            BA_MapearAtivIdTeste = BA_Pad3(ativId)
    End Select
End Function

Private Function BA_CodServicoLegado(ByVal ativId As String, ByVal servId As String) As String
    BA_CodServicoLegado = BA_MapearAtivIdTeste(ativId) & BA_Pad3(servId)
End Function

Private Function BA_SelecionarEmpresa(ByVal ativId As String) As TRodizioResultado
    BA_SelecionarEmpresa = SelecionarEmpresa(BA_MapearAtivIdTeste(ativId))
End Function

Private Function BA_AvancarFila(ByVal empId As String, ByVal ativId As String, ByVal punir As Boolean, ByVal motivo As String) As TResult
    BA_AvancarFila = AvancarFila(empId, BA_MapearAtivIdTeste(ativId), punir, motivo)
End Function

Private Sub BA_TesteRecusaOuExpiracao( _
    ByVal caso As String, _
    ByVal entId As String, _
    ByVal ativId As String, _
    ByVal servId As String, _
    ByVal expira As Boolean, _
    Optional ByVal motivo As String = "", _
    Optional ByVal empIdEsperadoSeguinte As String = "")
    Dim preId As String
    Dim r As TResult
    Dim resSel As TRodizioResultado

    preId = BA_EmitirPreOS(entId, ativId, servId, 1)
    If expira Then
        r = ExpirarPreOS(preId)
        BA_LogAssert caso, r.Sucesso And BA_StatusPreOS(preId) = BA_STATUS_PREOS_EXPIRADA, "Pre-OS expirada e fila punida", r.Mensagem & " | STATUS=" & BA_StatusPreOS(preId), "Validar expiracao com punicao no rodizio", "Expirar Pre-OS e observar proxima selecao"
    Else
        If Len(Trim$(motivo)) = 0 Then motivo = "Recusa do caso " & caso
        r = RecusarPreOS(preId, motivo)
        BA_LogAssert caso, r.Sucesso And BA_StatusPreOS(preId) = BA_STATUS_PREOS_RECUSADA, "Pre-OS recusada e fila punida", r.Mensagem & " | STATUS=" & BA_StatusPreOS(preId), "Validar recusa com punicao no rodizio", "Recusar Pre-OS e observar proxima selecao"
    End If

    If Len(Trim$(empIdEsperadoSeguinte)) > 0 Then
        resSel = BA_SelecionarEmpresa(ativId)
        BA_LogAssert caso & "_RodizioSeguinte", resSel.encontrou And BA_Pad3(resSel.Empresa.EMP_ID) = BA_Pad3(empIdEsperadoSeguinte), "Depois da punicao o rodizio segue para a proxima empresa", BA_ResumoRodizio(resSel), "Garantir continuidade do rodizio apos punicao", "Selecionar proxima empresa na atividade " & BA_Pad3(ativId)
    End If
End Sub

Private Sub BA_RecusarEmissao( _
    ByVal caso As String, _
    ByVal entId As String, _
    ByVal ativId As String, _
    ByVal servId As String, _
    ByVal motivo As String, _
    Optional ByVal empIdEsperadoSeguinte As String = "")
    BA_TesteRecusaOuExpiracao caso, entId, ativId, servId, False, motivo, empIdEsperadoSeguinte
End Sub

Private Sub BA_ExpirarEmissao( _
    ByVal caso As String, _
    ByVal entId As String, _
    ByVal ativId As String, _
    ByVal servId As String, _
    Optional ByVal empIdEsperadoSeguinte As String = "")
    BA_TesteRecusaOuExpiracao caso, entId, ativId, servId, True, empIdEsperadoSeguinte
End Sub

Private Sub BA_TesteSuspensaoPorRecusa()
    Dim i As Long
    Dim preId As String
    Dim r As TResult

    For i = 1 To 2
        preId = BA_EmitirPreOS("001", "001", "001", 1)
        r = RecusarPreOS(preId, "Borda recusas " & CStr(i))
    Next i
    BA_LogAssert "BO_230_SuspensaoAutomatica_PreBorda", BA_StatusEmpresa("001") = BA_STATUS_EMP_ATIVA, "Empresa ainda ativa antes de atingir o limite", BA_StatusEmpresa("001"), "Validar fronteira inferior de recusas", "Executar 2 recusas com limite 3"

    preId = BA_EmitirPreOS("001", "001", "001", 1)
    r = RecusarPreOS(preId, "Borda recusas 3")
    BA_LogAssert "BO_230_SuspensaoAutomatica", BA_StatusEmpresa("001") = BA_STATUS_EMP_SUSPENSA, "Empresa suspensa ao atingir o limite de recusas", BA_StatusEmpresa("001") & " | QTD_RECUSAS=" & BA_QtdRecusasEmpresa("001"), "Validar suspensao automatica por recusas", "Executar a terceira recusa"
End Sub

Private Sub BA_TesteReativacaoAutomatica()
    Dim resSel As TRodizioResultado

    BA_SetEmpresaStatus "001", BA_STATUS_EMP_SUSPENSA, DateAdd("d", -1, Date), 3
    resSel = BA_SelecionarEmpresa("001")
    BA_LogAssert "BO_231_ReativacaoAutomatica", resSel.encontrou And BA_StatusEmpresa("001") = BA_STATUS_EMP_ATIVA, "Empresa suspensa com prazo vencido volta automaticamente", BA_ResumoRodizio(resSel) & " | STATUS=" & BA_StatusEmpresa("001"), "Validar reativacao automatica prevista no edital", "Selecionar atividade com suspensao expirada"
End Sub

Private Sub BA_TesteCancelamentoNaoAvancaFila()
    Dim filaAntes As String
    Dim preId As String
    Dim osId As String
    Dim r As TResult
    Dim filaDepois As String

    filaAntes = BA_FilaCsv("002")
    preId = BA_EmitirPreOS("001", "002", "001", 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 7, Date), "EMP-BO260")
    filaDepois = BA_FilaCsv("002")
    r = CancelarOS(osId, "Cancelar sem avancar novamente")

    BA_LogAssert "BO_260_CancelamentoNaoAvancaFila", r.Sucesso And BA_FilaCsv("002") = filaDepois And filaDepois <> filaAntes, "Cancelamento nao gera novo avancar de fila", "ANTES=" & filaAntes & " | DEPOIS_EMITIR=" & filaDepois & " | DEPOIS_CANCELAR=" & BA_FilaCsv("002"), "Validar que o cancelamento nao avancou a fila duas vezes", "Emitir OS e depois cancelar"
End Sub

Private Sub BA_ValidarCancelamentoSemAvanco( _
    ByVal caso As String, _
    ByVal entId As String, _
    ByVal ativId As String, _
    ByVal servId As String)
    BA_TesteCancelamentoNaoAvancaFila
End Sub

Private Sub BA_InitExecucao()
    Dim ws As Worksheet
    Dim lastRow As Long

    Set ws = BA_EnsureResultSheet()
    gExecucaoId = "BO-" & Format$(Now, "yyyymmdd-hhnnss")
    gOk = 0
    gFail = 0
    gManual = 0
    gRegistrarEmPlanilha = True

    ' Modo de execucao ja foi definido via BA_DefinirModoExecucaoVisual
    ' chamado por CT_IniciarBateria antes desta sub.
    ' Se a bateria for chamada diretamente, o padrao e RAPIDO (gDelayVisualMs=0).

    On Error Resume Next
    If ws.ProtectContents Then
        gTesteOfPreparado = Util_PrepararAbaParaEscrita(ws, gTesteOfEstavaProtegida, gTesteOfSenhaProtecao)
    Else
        gTesteOfPreparado = True
        gTesteOfEstavaProtegida = False
        gTesteOfSenhaProtecao = ""
    End If
    On Error GoTo 0

    If Not gTesteOfPreparado Or ws.ProtectContents Then
        ' Fallback para demonstracao: quando a aba estiver bloqueada e nao der para destravar,
        ' renomeia a aba antiga e recria uma TESTE_OFICIAL limpa para gravacao.
        Call BA_RecriarTesteOficialSeBloqueado(ws)
        Set ws = BA_EnsureResultSheet()
        gTesteOfPreparado = True
        gTesteOfEstavaProtegida = False
        gTesteOfSenhaProtecao = ""
    End If

    On Error Resume Next
    ws.Cells(1, 1).Value = "EXECUCAO_ATUAL"
    ws.Cells(1, 2).Value = gExecucaoId
    ws.Cells(1, 4).Value = "INICIO_EM"
    ws.Cells(1, 5).Value = Format$(Now, "dd/mm/yyyy hh:nn:ss")
    If Err.Number <> 0 Then
        gRegistrarEmPlanilha = False
        Err.Clear
    End If
    On Error GoTo 0

    ' Evita CSV "velho": sempre inicia a execucao limpa no TESTE_OFICIAL.
    If gRegistrarEmPlanilha Then
        On Error Resume Next
        lastRow = ws.Cells(ws.Rows.count, 1).End(xlUp).row
        If lastRow >= 7 Then
            ws.Range(ws.Cells(7, 1), ws.Cells(lastRow, 10)).ClearContents
        End If
        If Err.Number <> 0 Then
            gRegistrarEmPlanilha = False
            Err.Clear
        End If
        On Error GoTo 0
    End If

    gLinhaResultado = 7
    BA_AtualizarResumo

    ' Formatar cabecalho da aba como dashboard
    If gRegistrarEmPlanilha Then
        On Error Resume Next

        ' --- Linha 1: Titulo (merge A1:J1, laranja) ---
        With ws.Range(ws.Cells(1, 1), ws.Cells(1, 10))
            .UnMerge
            .Merge
        End With
        With ws.Cells(1, 1)
            .Value = "BATERIA OFICIAL DE TESTES " & ChrW(8212) & " RODIZIO V12"
            .Font.Bold = True
            .Font.Size = 14
            .HorizontalAlignment = xlCenter
            .Interior.Color = RGB(255, 192, 0)
        End With
        ws.Rows(1).RowHeight = 30

        ' --- Linha 2: Botoes de navegacao ---
        ws.Rows(2).RowHeight = 30
        Dim shp As Shape
        For Each shp In ws.Shapes
            If Left$(shp.Name, 7) = "QA_BTN_" Then shp.Delete
        Next shp

        Dim b As Shape
        Set b = ws.Shapes.AddShape(msoShapeRoundedRectangle, 10, 34, 180, 26)
        With b
            .Name = "QA_BTN_MENU"
            .TextFrame2.TextRange.Text = "Voltar ao Menu Principal"
            .TextFrame2.TextRange.Font.Size = 9: .TextFrame2.TextRange.Font.Bold = msoTrue
            .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter
            .Fill.ForeColor.RGB = RGB(0, 51, 102)
            .TextFrame2.TextRange.Font.Fill.ForeColor.RGB = RGB(255, 255, 255)
            .OnAction = "CT_AbrirMenuPrincipal"
        End With
        Set b = ws.Shapes.AddShape(msoShapeRoundedRectangle, 200, 34, 150, 26)
        With b
            .Name = "QA_BTN_REL"
            .TextFrame2.TextRange.Text = "Gerar Relatorio"
            .TextFrame2.TextRange.Font.Size = 9: .TextFrame2.TextRange.Font.Bold = msoTrue
            .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter
            .Fill.ForeColor.RGB = RGB(0, 128, 0)
            .TextFrame2.TextRange.Font.Fill.ForeColor.RGB = RGB(255, 255, 255)
            .OnAction = "CTR_GerarRelatorioBateria"
        End With
        Set b = ws.Shapes.AddShape(msoShapeRoundedRectangle, 360, 34, 150, 26)
        With b
            .Name = "QA_BTN_CENTRAL"
            .TextFrame2.TextRange.Text = "Central de Testes"
            .TextFrame2.TextRange.Font.Size = 9: .TextFrame2.TextRange.Font.Bold = msoTrue
            .TextFrame2.TextRange.ParagraphFormat.Alignment = msoAlignCenter
            .Fill.ForeColor.RGB = RGB(255, 192, 0)
            .TextFrame2.TextRange.Font.Fill.ForeColor.RGB = RGB(0, 0, 0)
            .OnAction = "CT_AbrirCentral"
        End With

        ' --- Linha 3: Contadores horizontais ---
        ws.Cells(3, 1).Value = "OK:"
        ws.Cells(3, 1).Font.Bold = True
        ws.Cells(3, 1).Interior.Color = RGB(198, 239, 206)
        ws.Cells(3, 2).Value = 0
        ws.Cells(3, 2).Font.Size = 16: ws.Cells(3, 2).Font.Bold = True

        ws.Cells(3, 3).Value = "FALHA:"
        ws.Cells(3, 3).Font.Bold = True
        ws.Cells(3, 3).Interior.Color = RGB(255, 199, 206)
        ws.Cells(3, 4).Value = 0
        ws.Cells(3, 4).Font.Size = 16: ws.Cells(3, 4).Font.Bold = True

        ws.Cells(3, 5).Value = "MANUAL:"
        ws.Cells(3, 5).Font.Bold = True
        ws.Cells(3, 5).Interior.Color = RGB(255, 235, 156)
        ws.Cells(3, 6).Value = 0
        ws.Cells(3, 6).Font.Size = 16: ws.Cells(3, 6).Font.Bold = True

        ws.Cells(3, 7).Value = "TOTAL:"
        ws.Cells(3, 7).Font.Bold = True
        ws.Cells(3, 8).Value = 0
        ws.Cells(3, 8).Font.Size = 16: ws.Cells(3, 8).Font.Bold = True

        ws.Cells(3, 9).Value = "de"
        ws.Cells(3, 10).Value = TOTAL_TESTES_PREVISTO
        ws.Cells(3, 10).Font.Size = 16: ws.Cells(3, 10).Font.Bold = True

        ' --- Linha 4: Execucao e inicio ---
        ws.Cells(4, 1).Value = "EXECUCAO:"
        ws.Cells(4, 1).Font.Bold = True
        ws.Cells(4, 2).Value = gExecucaoId
        ws.Cells(4, 7).Value = "INICIO:"
        ws.Cells(4, 7).Font.Bold = True
        ws.Cells(4, 8).Value = Format$(Now, "dd/mm/yyyy hh:nn:ss")

        ' --- Linha 5: separador vazio ---
        ' (nada)

        ' --- Linha 6: Cabecalho de colunas ---
        ws.Cells(6, 1).Value = "EXECUCAO"
        ws.Cells(6, 2).Value = "BLOCO"
        ws.Cells(6, 3).Value = "TESTE"
        ws.Cells(6, 4).Value = "APLICACAO"
        ws.Cells(6, 5).Value = "ESPERADO"
        ws.Cells(6, 6).Value = "OBTIDO"
        ws.Cells(6, 7).Value = "STATUS"
        ws.Cells(6, 8).Value = "IMPORTANCIA"
        ws.Cells(6, 9).Value = "NOME"
        ws.Cells(6, 10).Value = "DATA/HORA"
        With ws.Range(ws.Cells(6, 1), ws.Cells(6, 10))
            .Font.Bold = True
            .Interior.Color = RGB(0, 51, 102)
            .Font.Color = RGB(255, 255, 255)
            .HorizontalAlignment = xlCenter
            .Borders.LineStyle = xlContinuous
        End With

        ' --- Larguras de coluna ---
        ws.Columns(1).ColumnWidth = 22
        ws.Columns(2).ColumnWidth = 12
        ws.Columns(3).ColumnWidth = 42
        ws.Columns(4).ColumnWidth = 35
        ws.Columns(5).ColumnWidth = 30
        ws.Columns(6).ColumnWidth = 30
        ws.Columns(7).ColumnWidth = 10
        ws.Columns(8).ColumnWidth = 25
        ws.Columns(9).ColumnWidth = 25
        ws.Columns(10).ColumnWidth = 18

        ' --- Congelar paineis na linha 7 (linhas 1-6 sempre visiveis) ---
        ws.Activate
        ActiveWindow.FreezePanes = False
        ws.Cells(7, 1).Select
        ActiveWindow.FreezePanes = True

        If gDelayVisualMs > 0 Then Application.ScreenUpdating = True
        Application.Goto ws.Cells(1, 1), True
        DoEvents
        On Error GoTo 0
    End If

    On Error Resume Next
    Call CT_PrepararChecklistParaBateriaAoVivo
    On Error GoTo 0
End Sub

Private Sub BA_FormatacaoFinal()
    ' Formatacao pos-execucao: AutoFilter, coloracao condicional e resumo no rodape
    If Not gRegistrarEmPlanilha Then Exit Sub

    Dim ws As Worksheet
    On Error Resume Next
    Set ws = BA_EnsureResultSheet()
    If ws Is Nothing Then Exit Sub

    Dim ultimaLinha As Long
    ultimaLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    If ultimaLinha < 7 Then GoTo FimFormatacao

    ' --- AutoFilter na linha 6 ---
    If Not ws.AutoFilterMode Then
        ws.Range(ws.Cells(6, 1), ws.Cells(6, 10)).AutoFilter
    End If

    ' --- Coloracao condicional nas linhas de dados ---
    Dim r As Long
    For r = 7 To ultimaLinha
        Dim statusVal As String
        statusVal = Trim$(CStr(ws.Cells(r, 7).Value))
        Select Case statusVal
            Case STATUS_OK
                ' Apenas celula STATUS (col G) verde
                ws.Cells(r, 7).Interior.Color = RGB(198, 239, 206)
            Case STATUS_FAIL
                ' Linha inteira vermelha
                ws.Range(ws.Cells(r, 1), ws.Cells(r, 10)).Interior.Color = RGB(255, 199, 206)
            Case STATUS_MANUAL
                ' Linha inteira amarela
                ws.Range(ws.Cells(r, 1), ws.Cells(r, 10)).Interior.Color = RGB(255, 235, 156)
            Case Else
                ' INFO ou vazio: sem cor
        End Select
    Next r

    ' --- Resumo no rodape ---
    Dim linhaResumo As Long
    linhaResumo = ultimaLinha + 2
    ws.Cells(linhaResumo, 1).Value = "RESUMO: " & gOk & " OK | " & gFail & " FALHA | " & _
        gManual & " MANUAL | TOTAL " & (gOk + gFail + gManual)
    ws.Cells(linhaResumo, 1).Font.Bold = True
    ws.Cells(linhaResumo, 1).Font.Size = 12
    If gFail > 0 Then
        ws.Range(ws.Cells(linhaResumo, 1), ws.Cells(linhaResumo, 10)).Interior.Color = RGB(255, 199, 206)
    Else
        ws.Range(ws.Cells(linhaResumo, 1), ws.Cells(linhaResumo, 10)).Interior.Color = RGB(198, 239, 206)
    End If

FimFormatacao:
    On Error GoTo 0
End Sub

Private Sub BA_RecriarTesteOficialSeBloqueado(ByVal ws As Worksheet)
    On Error Resume Next
    If ws Is Nothing Then Exit Sub
    If Not ws.ProtectContents Then Exit Sub

    Dim nomeAntigo As String
    nomeAntigo = "TESTE_OFICIAL_BLOQ_" & Format$(Now, "hhnnss")

    ws.Name = nomeAntigo
    If Err.Number <> 0 Then
        Err.Clear
        Exit Sub
    End If

    Dim wsNovo As Worksheet
    Set wsNovo = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.count))
    wsNovo.Name = SHEET_TESTE_OFICIAL
    On Error GoTo 0
End Sub

Private Function BA_EnsureResultSheet() As Worksheet
    Dim ws As Worksheet

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(SHEET_TESTE_OFICIAL)
    On Error GoTo 0

    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.count))
        ws.Name = SHEET_TESTE_OFICIAL
    End If

    If Trim$(CStr(ws.Cells(6, 1).Value)) = "" Then
        ws.Cells(6, 1).Value = "EXECUCAO_ID"
        ws.Cells(6, 2).Value = "BLOCO"
        ws.Cells(6, 3).Value = "NOME_TESTE"
        ws.Cells(6, 4).Value = "APLICACAO"
        ws.Cells(6, 5).Value = "RESULTADO_ESPERADO"
        ws.Cells(6, 6).Value = "RESULTADO_OBTIDO"
        ws.Cells(6, 7).Value = "STATUS"
        ws.Cells(6, 8).Value = "IMPORTANCIA"
        ws.Cells(6, 9).Value = "EVIDENCIA"
        ws.Cells(6, 10).Value = "DATA_HORA"
        ws.Cells(6, 11).Value = "EXPLICACAO"
    End If

    Set BA_EnsureResultSheet = ws
End Function

Private Function BA_NextResultRow(ByVal ws As Worksheet) As Long
    Dim lastRow As Long
    lastRow = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    If lastRow < 7 Then
        BA_NextResultRow = 7
    Else
        BA_NextResultRow = lastRow + 1
    End If
End Function

Private Sub BA_AtualizarResumo()
    If Not gRegistrarEmPlanilha Then Exit Sub

    Dim ws As Worksheet
    On Error Resume Next
    Set ws = BA_EnsureResultSheet()
    If ws Is Nothing Then Exit Sub

    ' Contadores horizontais na linha 3 (layout dashboard)
    ws.Cells(3, 2).Value = gOk
    ws.Cells(3, 4).Value = gFail
    ws.Cells(3, 6).Value = gManual
    ws.Cells(3, 8).Value = gOk + gFail + gManual

    If Err.Number <> 0 Then
        gRegistrarEmPlanilha = False
        Err.Clear
    End If
    On Error GoTo 0
End Sub

Private Sub BA_LogAssert(ByVal nomeTeste As String, ByVal condicao As Boolean, ByVal esperado As String, ByVal obtido As String, ByVal importancia As String, ByVal aplicacao As String)
    If condicao Then
        BA_Log STATUS_OK, BA_BlocoDe(nomeTeste), nomeTeste, aplicacao, esperado, obtido, importancia
    Else
        BA_Log STATUS_FAIL, BA_BlocoDe(nomeTeste), nomeTeste, aplicacao, esperado, obtido, importancia
    End If
End Sub

Private Sub BA_LogInfo(ByVal nomeTeste As String, ByVal aplicacao As String, ByVal esperado As String, ByVal obtido As String)
    BA_Log STATUS_INFO, BA_BlocoDe(nomeTeste), nomeTeste, aplicacao, esperado, obtido, "Registrar marco operacional da auditoria"
End Sub

Private Sub BA_LogManual(ByVal nomeTeste As String, ByVal aplicacao As String, ByVal esperado As String, ByVal importancia As String)
    BA_Log STATUS_MANUAL, BA_BlocoDe(nomeTeste), nomeTeste, aplicacao, esperado, "Pendente de validacao humana", importancia
End Sub

Private Sub BA_Log(ByVal statusTeste As String, ByVal bloco As String, ByVal nomeTeste As String, ByVal aplicacao As String, ByVal esperado As String, ByVal obtido As String, ByVal importancia As String)
    Dim ws As Worksheet
    Dim dh As Date
    Dim t0 As Single

    dh = Now

    If gRegistrarEmPlanilha Then
        On Error Resume Next
        Set ws = BA_EnsureResultSheet()

        ws.Cells(gLinhaResultado, 1).Value = gExecucaoId
        ws.Cells(gLinhaResultado, 2).Value = bloco
        ws.Cells(gLinhaResultado, 3).Value = nomeTeste
        ws.Cells(gLinhaResultado, 4).Value = aplicacao
        ws.Cells(gLinhaResultado, 5).Value = esperado
        ws.Cells(gLinhaResultado, 6).Value = obtido
        ws.Cells(gLinhaResultado, 7).Value = statusTeste
        ws.Cells(gLinhaResultado, 8).Value = importancia
        ws.Cells(gLinhaResultado, 9).Value = nomeTeste
        ws.Cells(gLinhaResultado, 10).Value = Format$(dh, "dd/mm/yyyy hh:nn:ss")

        If Err.Number <> 0 Then
            gRegistrarEmPlanilha = False
            Err.Clear
        End If
        On Error GoTo 0
    End If

    Select Case statusTeste
        Case STATUS_OK
            gOk = gOk + 1
        Case STATUS_FAIL
            gFail = gFail + 1
        Case STATUS_MANUAL
            gManual = gManual + 1
    End Select

    ' CHECKLIST_136 desacoplada de TESTE_OFICIAL: sempre registra ao vivo.
    On Error Resume Next
    Call CT_BateriaLive_Registrar(nomeTeste, bloco, aplicacao, esperado, obtido, statusTeste, dh)
    On Error GoTo 0

    Debug.Print statusTeste & " | " & nomeTeste & " | " & obtido

    ' Atualizar contadores no topo da aba (modo visual ou nao)
    If gRegistrarEmPlanilha Then
        On Error Resume Next
        ws.Cells(2, 2).Value = gOk
        ws.Cells(3, 2).Value = gFail
        ws.Cells(4, 2).Value = gManual
        ws.Cells(1, 5).Value = Format$(Now, "dd/mm/yyyy hh:nn:ss")
        On Error GoTo 0
    End If

    ' Modo visual: colorir linha, atualizar StatusBar e scroll
    If gDelayVisualMs > 0 Then
        On Error Resume Next
        Application.StatusBar = "Bateria [" & CStr(gOk + gFail + gManual) & "] " & _
            nomeTeste & " " & ChrW(8212) & " " & statusTeste

        ' Colorir linha conforme resultado
        ' OK: apenas celula STATUS (col G) fica verde; FALHA/MANUAL: linha inteira colorida
        If gRegistrarEmPlanilha And Not ws Is Nothing Then
            Dim corFundo As Long
            Select Case statusTeste
                Case STATUS_OK
                    ' Apenas a celula de STATUS (coluna G = 7) fica verde
                    ws.Cells(gLinhaResultado, 7).Interior.Color = RGB(198, 239, 206)
                Case STATUS_FAIL
                    corFundo = RGB(255, 199, 206)    ' vermelho claro — linha inteira
                    ws.Range(ws.Cells(gLinhaResultado, 1), ws.Cells(gLinhaResultado, 10)).Interior.Color = corFundo
                Case STATUS_MANUAL
                    corFundo = RGB(255, 235, 156)    ' amarelo claro — linha inteira
                    ws.Range(ws.Cells(gLinhaResultado, 1), ws.Cells(gLinhaResultado, 10)).Interior.Color = corFundo
                Case Else
                    ' INFO: sem cor (fundo branco padrao)
            End Select

            ' Scroll para linha atual
            Application.Goto ws.Cells(gLinhaResultado, 1), True
        End If
        On Error GoTo 0

        DoEvents
        t0 = Timer
        Do While (Timer - t0) < (CSng(gDelayVisualMs) / 1000!)
            DoEvents
        Loop
    End If

    gLinhaResultado = gLinhaResultado + 1
End Sub

Private Function BA_BlocoDe(ByVal nomeTeste As String) As String
    BA_BlocoDe = Left$(nomeTeste, 6)
End Function

Private Sub BA_ResetBaseOperacional()
    Dim nome As Variant
    For Each nome In Array(SHEET_EMPRESAS, SHEET_EMPRESAS_INATIVAS, SHEET_ENTIDADE, SHEET_ENTIDADE_INATIVOS, SHEET_CREDENCIADOS, SHEET_PREOS, SHEET_CAD_OS, SHEET_AUDIT, SHEET_RELATORIO)
        BA_ClearSheet CStr(nome)
    Next nome
End Sub

Private Sub BA_LimparAtividadesDeTeste()
    Dim nome As Variant
    For Each nome In Array(SHEET_CREDENCIADOS)
        BA_ClearSheet CStr(nome)
    Next nome
End Sub

Private Sub BA_ClearSheet(ByVal nomeAba As String)
    Dim ws As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim ultimaLinha As Long
    Dim ultimaColuna As Long
    Dim primeiraLinha As Long
    Dim lo As ListObject

    Set ws = ThisWorkbook.Sheets(nomeAba)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        Err.Raise 1004, "BA_ClearSheet", "Nao foi possivel preparar a aba " & nomeAba
    End If

    On Error Resume Next
    For Each lo In ws.ListObjects
        Do While lo.ListRows.count > 0
            lo.ListRows(1).Delete
        Loop
    Next lo
    On Error GoTo 0

    ultimaLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    ultimaColuna = ws.Cells(1, ws.Columns.count).End(xlToLeft).Column
    primeiraLinha = BA_PrimeiraLinhaDados(nomeAba)
    If ultimaColuna < 1 Then ultimaColuna = 1

    If ultimaLinha >= primeiraLinha Then
        ws.Range(ws.Cells(primeiraLinha, 1), ws.Cells(ultimaLinha, ultimaColuna)).ClearContents
    End If
    ws.Cells(1, COL_CONTADOR_AR).Value = 0

    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
End Sub

Private Sub BA_SetConfig()
    Dim ws As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        Err.Raise 1004, "BA_SetConfig", "Nao foi possivel preparar CONFIG para escrita."
    End If

    ws.Cells(LINHA_CFG_VALORES, COL_CFG_GESTOR).Value = "Gestor Auditoria V12"
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_LOGO).Value = "LOGO_AUDITORIA_V12"
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_MUNICIPIO).Value = "Municipio de Auditoria V12"
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_PRAZO_PREOS).Value = 5
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value = 3
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_MESES_SUSPENSAO).Value = 1
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_VERSAO).Value = "BATERIA_OFICIAL_2026_03_25"
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_UF).Value = "PE"
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_SECRETARIA).Value = "Secretaria Auditoria V12"
    ws.Cells(LINHA_CFG_VALORES, COL_CFG_NOTA_MINIMA).Value = 5

    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
End Sub

Private Function BA_CriarBackup(ByVal identificador As String) As String
    Dim pasta As String
    Dim arquivo As String
    Dim nomeBase As String
    Dim fso As Object

    On Error GoTo falha

    If ThisWorkbook.Path = "" Then Exit Function

    pasta = ThisWorkbook.Path & Application.PathSeparator & "backup_bateria_oficial"
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FolderExists(pasta) Then
        fso.CreateFolder pasta
    End If

    nomeBase = ThisWorkbook.Name
    If LCase$(Right$(nomeBase, 5)) = ".xlsm" Then
        nomeBase = Left$(nomeBase, Len(nomeBase) - 5)
    End If

    arquivo = pasta & Application.PathSeparator & nomeBase & "_" & identificador & "_" & Format$(Now, "yyyymmdd_hhnnss") & ".xlsm"
    ThisWorkbook.SaveCopyAs arquivo
    BA_CriarBackup = arquivo
    Exit Function

falha:
    BA_CriarBackup = ""
End Function

Private Sub BA_CadastrarItemCanonico(ByVal ativId As String, ByVal descricao As String, ByVal valorUnit As Currency)
    Dim wsAtiv As Worksheet
    Dim wsServ As Worksheet
    Dim linhaAtiv As Long
    Dim linhaServ As Long
    Dim estavaProtegidaAtiv As Boolean
    Dim estavaProtegidaServ As Boolean
    Dim senhaAtiv As String
    Dim senhaServ As String

    Set wsAtiv = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
    Set wsServ = ThisWorkbook.Sheets(SHEET_CAD_SERV)

    If Not Util_PrepararAbaParaEscrita(wsAtiv, estavaProtegidaAtiv, senhaAtiv) Then Err.Raise 1004, "BA_CadastrarItemCanonico", "Nao foi possivel preparar ATIVIDADES."
    If Not Util_PrepararAbaParaEscrita(wsServ, estavaProtegidaServ, senhaServ) Then Err.Raise 1004, "BA_CadastrarItemCanonico", "Nao foi possivel preparar CAD_SERV."

    linhaAtiv = BA_NextDataRow(SHEET_ATIVIDADES)
    wsAtiv.Cells(linhaAtiv, COL_ATIV_ID).Value = ativId
    wsAtiv.Cells(linhaAtiv, COL_ATIV_CNAE).Value = "CNAE-" & ativId
    wsAtiv.Cells(linhaAtiv, COL_ATIV_DESCRICAO).Value = descricao

    linhaServ = BA_NextDataRow(SHEET_CAD_SERV)
    wsServ.Cells(linhaServ, COL_SERV_ID).Value = "001"
    wsServ.Cells(linhaServ, COL_SERV_ATIV_ID).Value = ativId
    wsServ.Cells(linhaServ, COL_SERV_ATIV_DESC).Value = descricao
    wsServ.Cells(linhaServ, COL_SERV_DESCRICAO).Value = descricao
    wsServ.Cells(linhaServ, COL_SERV_VALOR_UNIT).Value = valorUnit
    wsServ.Cells(linhaServ, COL_SERV_DT_CAD).Value = Now

    BA_SetCounter SHEET_ATIVIDADES, CLng(Val(ativId))
    BA_SetCounter SHEET_CAD_SERV, 1

    Util_RestaurarProtecaoAba wsAtiv, estavaProtegidaAtiv, senhaAtiv
    Util_RestaurarProtecaoAba wsServ, estavaProtegidaServ, senhaServ
End Sub

Private Sub BA_CadastrarEntidadeCanonica(ByVal entId As String, ByVal cnpj As String, ByVal nome As String, ByVal endereco As String, ByVal bairro As String, ByVal municipio As String, ByVal cep As String, ByVal uf As String)
    Dim ws As Worksheet
    Dim linha As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    Set ws = ThisWorkbook.Sheets(SHEET_ENTIDADE)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then Err.Raise 1004, "BA_CadastrarEntidadeCanonica", "Nao foi possivel preparar ENTIDADE."

    linha = BA_NextDataRow(SHEET_ENTIDADE)
    ws.Cells(linha, COL_ENT_ID).Value = entId
    ws.Cells(linha, COL_ENT_CNPJ).Value = cnpj
    ws.Cells(linha, COL_ENT_NOME).Value = nome
    ws.Cells(linha, COL_ENT_TEL_FIXO).Value = "(81) 3100-" & Right$(entId, 1) & Right$(entId, 1) & Right$(entId, 1) & Right$(entId, 1)
    ws.Cells(linha, COL_ENT_TEL_CEL).Value = "(81) 91000-00" & Right$(entId, 1)
    ws.Cells(linha, COL_ENT_EMAIL).Value = "local" & Right$(entId, 1) & "@auditoria.test"
    ws.Cells(linha, COL_ENT_ENDERECO).Value = endereco
    ws.Cells(linha, COL_ENT_BAIRRO).Value = bairro
    ws.Cells(linha, COL_ENT_MUNICIPIO).Value = municipio
    ws.Cells(linha, COL_ENT_CEP).Value = cep
    ws.Cells(linha, COL_ENT_UF).Value = uf
    ws.Cells(linha, COL_ENT_CONT1_NOME).Value = "Contato 1 " & nome
    ws.Cells(linha, COL_ENT_CONT1_FONE).Value = "(81) 92000-00" & Right$(entId, 1)
    ws.Cells(linha, COL_ENT_CONT1_FUNCAO).Value = "Gestor"
    ws.Cells(linha, COL_ENT_CONT2_NOME).Value = "Contato 2 " & nome
    ws.Cells(linha, COL_ENT_CONT2_FONE).Value = "(81) 93000-00" & Right$(entId, 1)
    ws.Cells(linha, COL_ENT_CONT2_FUNCAO).Value = "Fiscal"
    ws.Cells(linha, COL_ENT_CONT3_NOME).Value = "Contato 3 " & nome
    ws.Cells(linha, COL_ENT_CONT3_FONE).Value = "(81) 94000-00" & Right$(entId, 1)
    ws.Cells(linha, COL_ENT_CONT3_FUNCAO).Value = "Apoio"
    ws.Cells(linha, COL_ENT_INFO_ADIC).Value = "Entidade cadastrada pela bateria oficial"
    ws.Cells(linha, COL_ENT_DT_CAD).Value = Now

    BA_SetCounter SHEET_ENTIDADE, CLng(Val(entId))
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
End Sub

Private Sub BA_CadastrarEmpresaCanonica(ByVal empId As String, ByVal cnpj As String, ByVal razao As String, ByVal responsavel As String, ByVal cpf As String, ByVal endereco As String, ByVal bairro As String, ByVal municipio As String, ByVal cep As String, ByVal uf As String, ByVal telFixo As String, ByVal telCel As String, ByVal email As String, ByVal inscrMun As String, ByVal experiencia As String)
    Dim ws As Worksheet
    Dim linha As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then Err.Raise 1004, "BA_CadastrarEmpresaCanonica", "Nao foi possivel preparar EMPRESAS."

    linha = BA_NextDataRow(SHEET_EMPRESAS)

    ws.Cells(linha, COL_EMP_ID).Value = empId
    ws.Cells(linha, COL_EMP_CNPJ).Value = cnpj
    ws.Cells(linha, COL_EMP_RAZAO).Value = razao
    ws.Cells(linha, COL_EMP_INSCR_MUN).Value = inscrMun
    ws.Cells(linha, COL_EMP_RESPONSAVEL).Value = responsavel
    ws.Cells(linha, COL_EMP_CPF_RESP).Value = cpf
    ws.Cells(linha, COL_EMP_ENDERECO).Value = endereco
    ws.Cells(linha, COL_EMP_BAIRRO).Value = bairro
    ws.Cells(linha, COL_EMP_MUNICIPIO).Value = municipio
    ws.Cells(linha, COL_EMP_CEP).Value = cep
    ws.Cells(linha, COL_EMP_UF).Value = uf
    ws.Cells(linha, COL_EMP_TEL_FIXO).Value = telFixo
    ws.Cells(linha, COL_EMP_TEL_CEL).Value = telCel
    ws.Cells(linha, COL_EMP_EMAIL).Value = email
    ws.Cells(linha, COL_EMP_EXPERIENCIA).Value = experiencia
    ws.Cells(linha, COL_EMP_STATUS_GLOBAL).Value = BA_STATUS_EMP_ATIVA
    ws.Cells(linha, COL_EMP_DT_FIM_SUSP).Value = ""
    ws.Cells(linha, COL_EMP_QTD_RECUSAS).Value = 0
    ws.Cells(linha, COL_EMP_DT_CAD).Value = Now
    ws.Cells(linha, COL_EMP_DT_ULT_ALT).Value = Now

    gUltimaLinhaEmpresaCanonica = linha
    BA_SetCounter SHEET_EMPRESAS, CLng(Val(empId))
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Exit Sub

falha:
    Dim numeroErro As Long
    Dim descricaoErro As String

    numeroErro = Err.Number
    descricaoErro = Err.Description
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    If numeroErro = 0 Then numeroErro = 1004
    Err.Raise numeroErro, _
              "BA_CadastrarEmpresaCanonica", _
              "Falha ao cadastrar empresa canonica EMP_ID=" & empId & "; CNPJ=" & cnpj & "; LINHA=" & CStr(linha) & ". " & descricaoErro
End Sub

Private Function BA_CredenciarAtividade(ByVal empId As String, ByVal ativId As String, ByVal servId As String) As String
    Dim ws As Worksheet
    Dim linha As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim cnpj As String
    Dim razao As String
    Dim linhaExistente As Long
    Dim codAtivServ As String
    Dim ativIdReal As String

    ativIdReal = BA_MapearAtivIdTeste(ativId)
    BA_ObterEmpresa empId, cnpj, razao
    codAtivServ = BA_Pad3(ativIdReal) & BA_Pad3(servId)
    linhaExistente = BA_LinhaCred(empId, ativId)
    If linhaExistente > 0 Then
        BA_CredenciarAtividade = "DUPLICADO"
        Exit Function
    End If

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then Err.Raise 1004, "BA_CredenciarAtividade", "Nao foi possivel preparar CREDENCIADOS."

    linha = BA_NextDataRow(SHEET_CREDENCIADOS)
    ws.Cells(linha, COL_CRED_ID).Value = BA_Pad3(BA_CountLinhas(SHEET_CREDENCIADOS) + 1)
    ws.Cells(linha, COL_CRED_COD_ATIV_SERV).Value = codAtivServ
    ws.Cells(linha, COL_CRED_EMP_ID).Value = empId
    ws.Cells(linha, COL_CRED_CNPJ).Value = cnpj
    ws.Cells(linha, COL_CRED_RAZAO).Value = razao
    ws.Cells(linha, COL_CRED_POSICAO).Value = BA_MaxPosicaoFila(ativId) + 1
    ws.Cells(linha, COL_CRED_ULT_OS).Value = ""
    ws.Cells(linha, COL_CRED_DT_ULT_OS).Value = ""
    ws.Cells(linha, COL_CRED_INATIVO_FLAG).Value = ""
    ws.Cells(linha, COL_CRED_ATIV_ID).Value = ativIdReal
    ws.Cells(linha, COL_CRED_RECUSAS).Value = 0
    ws.Cells(linha, COL_CRED_EXPIRACOES).Value = 0
    ws.Cells(linha, COL_CRED_STATUS).Value = BA_STATUS_CRED_ATIVO
    ws.Cells(linha, COL_CRED_DT_ULT_IND).Value = ""
    ws.Cells(linha, COL_CRED_DT_CRED).Value = Now

    BA_SetCounter SHEET_CREDENCIADOS, BA_CountLinhas(SHEET_CREDENCIADOS)
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    BA_CredenciarAtividade = "INSERIDO"
End Function

Private Sub BA_ObterEmpresa(ByVal empId As String, ByRef cnpjOut As String, ByRef razaoOut As String)
    Dim ws As Worksheet
    Dim i As Long

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    For i = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
        If BA_IdsIguaisCanonico(CStr(ws.Cells(i, COL_EMP_ID).Value), empId) Then
            cnpjOut = Trim$(CStr(ws.Cells(i, COL_EMP_CNPJ).Value))
            razaoOut = Trim$(CStr(ws.Cells(i, COL_EMP_RAZAO).Value))
            Exit Sub
        End If
    Next i
End Sub

Private Function BA_ExisteServico(ByVal ativId As String, ByVal servId As String, ByVal valorUnit As Currency) As Boolean
    BA_ExisteServico = BA_TemServico(ativId, servId)
End Function

Private Function BA_TemServico(ByVal ativId As String, ByVal servId As String) As Boolean
    BA_TemServico = (BA_DescServico(ativId, servId) <> "")
End Function

Private Function BA_DescServico(ByVal ativId As String, ByVal servId As String) As String
    Dim ws As Worksheet
    Dim i As Long
    Dim ativIdReal As String
    Set ws = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    ativIdReal = BA_MapearAtivIdTeste(ativId)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_SERV)
        If BA_Pad3(ws.Cells(i, COL_SERV_ATIV_ID).Value) = BA_Pad3(ativIdReal) And BA_Pad3(ws.Cells(i, COL_SERV_ID).Value) = BA_Pad3(servId) Then
            BA_DescServico = Trim$(CStr(ws.Cells(i, COL_SERV_DESCRICAO).Value))
            Exit Function
        End If
    Next i
End Function

Private Function BA_ValorServico(ByVal ativId As String, ByVal servId As String) As Currency
    Dim ws As Worksheet
    Dim i As Long
    Dim ativIdReal As String
    Set ws = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    ativIdReal = BA_MapearAtivIdTeste(ativId)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_SERV)
        If BA_Pad3(ws.Cells(i, COL_SERV_ATIV_ID).Value) = BA_Pad3(ativIdReal) And BA_Pad3(ws.Cells(i, COL_SERV_ID).Value) = BA_Pad3(servId) Then
            BA_ValorServico = CCur(Val(ws.Cells(i, COL_SERV_VALOR_UNIT).Value))
            Exit Function
        End If
    Next i
End Function

Private Function BA_ExisteEntidade(ByVal entId As String, ByVal nome As String) As Boolean
    BA_ExisteEntidade = (InStr(1, BA_ResumoEntidade(entId), nome, vbTextCompare) > 0)
End Function

Private Function BA_ResumoEntidade(ByVal entId As String) As String
    Dim ws As Worksheet
    Dim i As Long
    Set ws = ThisWorkbook.Sheets(SHEET_ENTIDADE)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_ENTIDADE)
        If BA_Pad3(ws.Cells(i, COL_ENT_ID).Value) = BA_Pad3(entId) Then
            BA_ResumoEntidade = Trim$(CStr(ws.Cells(i, COL_ENT_NOME).Value)) & " | " & Trim$(CStr(ws.Cells(i, COL_ENT_ENDERECO).Value)) & " | " & Trim$(CStr(ws.Cells(i, COL_ENT_EMAIL).Value))
            Exit Function
        End If
    Next i
End Function

Private Function BA_ExisteEmpresa(ByVal empId As String, ByVal razao As String) As Boolean
    Dim ws As Worksheet
    Dim i As Long

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    For i = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
        If BA_IdsIguaisCanonico(CStr(ws.Cells(i, COL_EMP_ID).Value), empId) Then
            BA_ExisteEmpresa = (InStr(1, Trim$(CStr(ws.Cells(i, COL_EMP_RAZAO).Value)), razao, vbTextCompare) > 0)
            Exit Function
        End If
    Next i
End Function

Private Function BA_CountOcorrenciasEmpresa(ByVal empId As String, ByVal cnpj As String) As Long
    BA_CountOcorrenciasEmpresa = BA_CountOcorrenciasRegistro(SHEET_EMPRESAS, PrimeiraLinhaDadosEmpresas(), COL_EMP_ID, empId, COL_EMP_CNPJ, cnpj) + _
                                 BA_CountOcorrenciasRegistro(SHEET_EMPRESAS_INATIVAS, LINHA_DADOS, COL_EMP_ID, empId, COL_EMP_CNPJ, cnpj)
End Function

Private Function BA_CountOcorrenciasEntidade(ByVal entId As String, ByVal cnpj As String) As Long
    BA_CountOcorrenciasEntidade = BA_CountOcorrenciasRegistro(SHEET_ENTIDADE, LINHA_DADOS, COL_ENT_ID, entId, COL_ENT_CNPJ, cnpj) + _
                                  BA_CountOcorrenciasRegistro(SHEET_ENTIDADE_INATIVOS, LINHA_DADOS, COL_ENT_ID, entId, COL_ENT_CNPJ, cnpj)
End Function

Private Function BA_CountOcorrenciasRegistro( _
    ByVal nomeAba As String, _
    ByVal primeiraLinha As Long, _
    ByVal colId As Long, _
    ByVal idBusca As String, _
    ByVal colDocumento As Long, _
    ByVal documentoBusca As String _
) As Long
    Dim ws As Worksheet
    Dim linha As Long
    Dim ultima As Long
    Dim docBuscaNorm As String
    Dim docAtualNorm As String

    Set ws = ThisWorkbook.Sheets(nomeAba)
    ultima = UltimaLinhaAba(nomeAba)
    If ultima < primeiraLinha Then Exit Function

    docBuscaNorm = Util_NormalizarDocumentoChave(documentoBusca)
    For linha = primeiraLinha To ultima
        If IdsIguais(ws.Cells(linha, colId).Value, idBusca) Then
            BA_CountOcorrenciasRegistro = BA_CountOcorrenciasRegistro + 1
        Else
            docAtualNorm = Util_NormalizarDocumentoChave(ws.Cells(linha, colDocumento).Value)
            If docBuscaNorm <> "" And docAtualNorm <> "" Then
                If StrComp(docAtualNorm, docBuscaNorm, vbTextCompare) = 0 Then
                    BA_CountOcorrenciasRegistro = BA_CountOcorrenciasRegistro + 1
                End If
            End If
        End If
    Next linha
End Function

Private Function BA_LinhaDuplicadaEmpresa(ByVal empId As String, ByVal cnpj As String) As Long
    BA_LinhaDuplicadaEmpresa = Util_LinhaDuplicadaIdOuDocumento( _
                                    ThisWorkbook.Sheets(SHEET_EMPRESAS), _
                                    PrimeiraLinhaDadosEmpresas(), _
                                    COL_EMP_ID, _
                                    empId, _
                                    COL_EMP_CNPJ, _
                                    cnpj)
End Function

Private Function BA_LinhaDuplicadaEntidade(ByVal entId As String, ByVal cnpj As String) As Long
    BA_LinhaDuplicadaEntidade = Util_LinhaDuplicadaIdOuDocumento( _
                                     ThisWorkbook.Sheets(SHEET_ENTIDADE), _
                                     LINHA_DADOS, _
                                     COL_ENT_ID, _
                                     entId, _
                                     COL_ENT_CNPJ, _
                                     cnpj)
End Function

Private Function BA_ReativacaoEmpresaDeveBloquearDuplicidade(ByVal empId As String, ByVal cnpj As String) As Boolean
    BA_ReativacaoEmpresaDeveBloquearDuplicidade = (BA_LinhaDuplicadaEmpresa(empId, cnpj) > 0)
End Function

Private Function BA_ReativacaoEntidadeDeveBloquearDuplicidade(ByVal entId As String, ByVal cnpj As String) As Boolean
    BA_ReativacaoEntidadeDeveBloquearDuplicidade = (BA_LinhaDuplicadaEntidade(entId, cnpj) > 0)
End Function

Private Function BA_ExisteEmpresaNaLinha(ByVal linha As Long, ByVal empId As String, ByVal razao As String) As Boolean
    Dim ws As Worksheet

    If linha <= 0 Then Exit Function

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    BA_ExisteEmpresaNaLinha = _
        BA_IdsIguaisCanonico(CStr(ws.Cells(linha, COL_EMP_ID).Value), empId) And _
        (InStr(1, Trim$(CStr(ws.Cells(linha, COL_EMP_RAZAO).Value)), razao, vbTextCompare) > 0)
End Function

Private Function BA_ResumoEmpresa(ByVal empId As String) As String
    Dim ws As Worksheet
    Dim i As Long
    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)

    For i = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
        If BA_IdsIguaisCanonico(CStr(ws.Cells(i, COL_EMP_ID).Value), empId) Then
            BA_ResumoEmpresa = Trim$(CStr(ws.Cells(i, COL_EMP_RAZAO).Value)) & " | " & Trim$(CStr(ws.Cells(i, COL_EMP_RESPONSAVEL).Value)) & " | " & Trim$(CStr(ws.Cells(i, COL_EMP_EMAIL).Value))
            Exit Function
        End If
    Next i
End Function

Private Function BA_ResumoEmpresaNaLinha(ByVal linha As Long) As String
    Dim ws As Worksheet

    If linha <= 0 Then Exit Function

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    BA_ResumoEmpresaNaLinha = _
        Trim$(CStr(ws.Cells(linha, COL_EMP_RAZAO).Value)) & " | " & _
        Trim$(CStr(ws.Cells(linha, COL_EMP_RESPONSAVEL).Value)) & " | " & _
        Trim$(CStr(ws.Cells(linha, COL_EMP_EMAIL).Value))
End Function

Private Function BA_FilaCsv(ByVal ativId As String) As String
    Dim ws As Worksheet
    Dim i As Long
    Dim maxPos As Long
    Dim pos As Long
    Dim arr() As String
    Dim out As String
    Dim ativIdReal As String

    ativIdReal = BA_MapearAtivIdTeste(ativId)
    maxPos = BA_MaxPosicaoFila(ativId)
    If maxPos <= 0 Then Exit Function
    ReDim arr(1 To maxPos)

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If BA_Pad3(ws.Cells(i, COL_CRED_ATIV_ID).Value) = BA_Pad3(ativIdReal) Then
            pos = CLng(Val(ws.Cells(i, COL_CRED_POSICAO).Value))
            If pos >= 1 And pos <= maxPos Then
                arr(pos) = BA_Pad3(ws.Cells(i, COL_CRED_EMP_ID).Value)
            End If
        End If
    Next i

    For i = 1 To maxPos
        If arr(i) <> "" Then
            If out <> "" Then out = out & ","
            out = out & arr(i)
        End If
    Next i
    BA_FilaCsv = out
End Function

Private Function BA_MaxPosicaoFila(ByVal ativId As String) As Long
    Dim ws As Worksheet
    Dim i As Long
    Dim pos As Long
    Dim ativIdReal As String
    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    ativIdReal = BA_MapearAtivIdTeste(ativId)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If BA_Pad3(ws.Cells(i, COL_CRED_ATIV_ID).Value) = BA_Pad3(ativIdReal) Then
            pos = CLng(Val(ws.Cells(i, COL_CRED_POSICAO).Value))
            If pos > BA_MaxPosicaoFila Then BA_MaxPosicaoFila = pos
        End If
    Next i
End Function

Private Sub BA_RodizioPasso(ByVal nomeTeste As String, ByVal ativId As String, ByVal empEsperada As String, ByVal avancaFila As Boolean, ByVal aplicacao As String)
    Dim res As TRodizioResultado
    Dim resAv As TResult
    res = BA_SelecionarEmpresa(ativId)

    BA_LogAssert nomeTeste, res.encontrou And BA_Pad3(res.Empresa.EMP_ID) = BA_Pad3(empEsperada), "Empresa " & BA_Pad3(empEsperada) & " selecionada para a atividade " & BA_Pad3(ativId), BA_ResumoRodizio(res) & " | FILA=" & BA_FilaCsv(ativId), "Validar a ordem de classificacao do rodizio", aplicacao

    If avancaFila And res.encontrou Then
        resAv = BA_AvancarFila(res.Empresa.EMP_ID, ativId, False, "ACEITE_OS_EMITIDA")
        BA_LogAssert nomeTeste & "_Avanco", resAv.Sucesso, "Fila avancada apos o atendimento da empresa selecionada", resAv.Mensagem & " | FILA=" & BA_FilaCsv(ativId), "Confirmar o giro ciclico da fila", "Avancar fila apos selecao bem-sucedida"
    End If
End Sub

Private Function BA_EmitirPreOS(ByVal entId As String, ByVal ativId As String, ByVal servId As String, ByVal qt As Double) As String
    Dim r As TResult
    r = EmitirPreOS(entId, BA_CodServicoLegado(ativId, servId), qt)
    If r.Sucesso Then BA_EmitirPreOS = r.IdGerado
End Function

Private Function BA_EmitirOS(ByVal preosId As String, ByVal dtPrev As Date, ByVal empenho As String) As String
    Dim r As TResult
    r = EmitirOS(preosId, dtPrev, empenho)
    If r.Sucesso Then BA_EmitirOS = r.IdGerado
End Function

Private Sub BA_MontarNotas(ByVal valor As Integer, ByRef notas() As Integer)
    Dim i As Long
    For i = 1 To 10
        notas(i) = valor
    Next i
End Sub

Private Function BA_ServicoPrincipal(ByVal ativId As String) As String
    Select Case BA_Pad3(ativId)
        Case "001": BA_ServicoPrincipal = "001"
        Case "002": BA_ServicoPrincipal = "001"
        Case "182": BA_ServicoPrincipal = "001"
        Case Else: BA_ServicoPrincipal = "001"
    End Select
End Function

Private Sub BA_ValidarFiltroD_OSAberta(ByVal casoId As String, ByVal ativId As String)
    Dim preId As String
    Dim osId As String
    Dim res As TRodizioResultado

    preId = BA_EmitirPreOS("001", ativId, BA_ServicoPrincipal(ativId), 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 5, Date), "EMP-" & casoId)
    res = BA_SelecionarEmpresa(ativId)
    BA_LogAssert casoId, res.encontrou And BA_Pad3(res.Empresa.EMP_ID) <> "003", "Empresa com OS aberta na atividade e ignorada pelo rodizio", "OS=" & osId & " | " & BA_ResumoRodizio(res), "Validar filtro D do rodizio", "Emitir OS para primeira empresa da fila"
End Sub

Private Sub BA_ValidarFiltroE_PreOSPendente(ByVal casoId As String, ByVal ativId As String)
    Dim preId As String
    Dim res As TRodizioResultado

    preId = BA_EmitirPreOS("001", ativId, BA_ServicoPrincipal(ativId), 1)
    res = BA_SelecionarEmpresa(ativId)
    BA_LogAssert casoId, res.encontrou And BA_Pad3(res.Empresa.EMP_ID) = "001", "Pre-OS pendente faz o rodizio pular sem mover a fila", "PREOS=" & preId & " | " & BA_ResumoRodizio(res), "Validar filtro E do rodizio", "Manter primeira empresa com Pre-OS aguardando aceite"
End Sub

Private Sub BA_ValidarAvaliacaoInvalida(ByVal casoId As String, ByVal notaInvalida As Integer)
    Dim preId As String
    Dim osId As String
    Dim notas(1 To 10) As Integer
    Dim i As Long
    Dim res As TResult

    preId = BA_EmitirPreOS("001", "182", "001", 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 4, Date), "EMP-" & casoId)
    For i = 1 To 10
        notas(i) = 8
    Next i
    notas(3) = notaInvalida
    res = AvaliarOS(osId, "Gestor QA", notas, 10, "Teste invalido", "")
    BA_LogAssert casoId, Not res.Sucesso And BA_StatusOS(osId) = BA_STATUS_OS_EXEC, "Avaliacao invalida nao conclui OS", BA_StatusOS(osId) & " | MSG=" & res.Mensagem, "Blindar validacao de notas fora do intervalo", "Aplicar nota invalida=" & CStr(notaInvalida)
End Sub

Private Sub BA_ValidarAvaliacaoArrayInvalido(ByVal casoId As String)
    Dim preId As String
    Dim osId As String
    Dim notas(1 To 9) As Integer
    Dim i As Long
    Dim res As TResult

    preId = BA_EmitirPreOS("001", "182", "001", 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 4, Date), "EMP-" & casoId)
    For i = 1 To 9
        notas(i) = 8
    Next i
    res = AvaliarOS(osId, "Gestor QA", notas, 10, "Array curto", "")
    BA_LogAssert casoId, Not res.Sucesso And BA_StatusOS(osId) = BA_STATUS_OS_EXEC, "Array de notas invalido nao conclui OS", BA_StatusOS(osId) & " | MSG=" & res.Mensagem, "Blindar contrato do vetor de notas", "Executar AvaliarOS com vetor 1..9"
End Sub

Private Sub BA_ValidarFiltroDExaustivo(ByVal casoId As String, ByVal ativId As String)
    Dim preId As String
    Dim osId As String
    Dim res1 As TRodizioResultado
    Dim res2 As TRodizioResultado

    preId = BA_EmitirPreOS("001", ativId, BA_ServicoPrincipal(ativId), 1)
    osId = BA_EmitirOS(preId, DateAdd("d", 5, Date), "EMP-" & casoId)
    res1 = BA_SelecionarEmpresa(ativId)
    res2 = BA_SelecionarEmpresa(ativId)
    BA_LogAssert casoId, res1.encontrou And res2.encontrou And BA_Pad3(res1.Empresa.EMP_ID) <> "003" And BA_Pad3(res2.Empresa.EMP_ID) <> "003", "Filtro D continua evitando empresa com OS aberta em selecoes sucessivas", "OS=" & osId & " | 1=" & BA_ResumoRodizio(res1) & " | 2=" & BA_ResumoRodizio(res2), "Cobrir persistencia do filtro D", "Executar duas selecoes sucessivas com OS aberta"
End Sub

Private Sub BA_ValidarFiltroEExaustivo(ByVal casoId As String, ByVal ativId As String)
    Dim preId As String
    Dim res1 As TRodizioResultado
    Dim res2 As TRodizioResultado

    preId = BA_EmitirPreOS("001", ativId, BA_ServicoPrincipal(ativId), 1)
    res1 = BA_SelecionarEmpresa(ativId)
    Call BA_AvancarFila("001", ativId, False, "TESTE_FILTRO_E_EXAUSTIVO")
    res2 = BA_SelecionarEmpresa(ativId)
    BA_LogAssert casoId, res1.encontrou And BA_Pad3(res1.Empresa.EMP_ID) = "001" And res2.encontrou And BA_Pad3(res2.Empresa.EMP_ID) = "002", "Filtro E preserva fila do pendente e proxima empresa entra apos avancar", "PREOS=" & preId & " | 1=" & BA_ResumoRodizio(res1) & " | 2=" & BA_ResumoRodizio(res2), "Cobrir persistencia do filtro E", "Executar selecao, avancar fila e selecionar novamente"
End Sub

Private Sub BA_ValidarCombinacaoDE(ByVal casoId As String, ByVal ativId As String)
    Dim preId As String
    Dim osId As String
    Dim res As TRodizioResultado

    preId = BA_EmitirPreOS("001", ativId, BA_ServicoPrincipal(ativId), 1)
    osId = BA_EmitirOS(BA_EmitirPreOS("002", ativId, BA_ServicoPrincipal(ativId), 1), DateAdd("d", 5, Date), "EMP-" & casoId)
    res = BA_SelecionarEmpresa(ativId)
    BA_LogAssert casoId, res.encontrou And BA_Pad3(res.Empresa.EMP_ID) = "002", "Combinacao D+E preserva comportamento combinado sem quebrar o rodizio", "PREOS=" & preId & " | OS=" & osId & " | " & BA_ResumoRodizio(res), "Cobrir interacao entre filtros D e E", "Criar Pre-OS pendente e OS aberta em empresas diferentes"
End Sub

Private Sub BA_ValidarProtecaoAbas(ByVal casoId As String)
    Dim ws As Worksheet
    Dim estavaProtegida As Boolean
    Dim Senha As String
    Set ws = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    ProtegerAbasCriticas
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, Senha) Then
        BA_LogAssert casoId, False, "Aba critica permite escrita controlada", "Nao foi possivel preparar aba para escrita", "Blindar a bateria contra planilhas protegidas", "Executar Util_PrepararAbaParaEscrita em CAD_SERV"
        Exit Sub
    End If
    ws.Cells(LINHA_DADOS, COL_SERV_DESCRICAO).Value = ws.Cells(LINHA_DADOS, COL_SERV_DESCRICAO).Value
    Util_RestaurarProtecaoAba ws, estavaProtegida, Senha
    BA_LogAssert casoId, True, "Aba critica aceita escrita controlada e restaura protecao", "CAD_SERV preparada e restaurada", "Blindar operacoes em abas protegidas", "Executar preparo/restauro de protecao"
End Sub

Private Sub BA_ValidarPersistenciaWorkbook(ByVal casoId As String)
    Dim ok As Boolean
    Dim msgErro As String

    ok = Util_SalvarWorkbookSeguro(msgErro)
    BA_LogAssert casoId, ok, "Workbook salva com a infraestrutura atual", IIf(ok, "SALVO", "FALHOU: " & msgErro), "Validar persistencia apos a bateria", "Executar Util_SalvarWorkbookSeguro"
End Sub

Private Function BA_IdsIguaisCanonico(ByVal valorA As String, ByVal valorB As String) As Boolean
    BA_IdsIguaisCanonico = (BA_Pad3(valorA) = BA_Pad3(valorB))
End Function

Private Function BA_ExtrairServIdCanonico(ByVal codAtivServ As String) As String
    Dim partes() As String
    If InStr(1, codAtivServ, "|", vbTextCompare) > 0 Then
        partes = Split(codAtivServ, "|")
        BA_ExtrairServIdCanonico = BA_Pad3(partes(1))
    ElseIf Len(Trim$(codAtivServ)) >= 6 Then
        BA_ExtrairServIdCanonico = BA_Pad3(Right$(Trim$(codAtivServ), 3))
    Else
        BA_ExtrairServIdCanonico = BA_Pad3(codAtivServ)
    End If
End Function

Private Function BA_PreOSEmpresa(ByVal preosId As String) As String
    Dim linha As Long
    linha = BA_LinhaPreOS(preosId)
    If linha = 0 Then Exit Function
    BA_PreOSEmpresa = BA_Pad3(ThisWorkbook.Sheets(SHEET_PREOS).Cells(linha, COL_PREOS_EMP_ID).Value)
End Function

Private Function BA_StatusPreOS(ByVal preosId As String) As String
    Dim linha As Long
    linha = BA_LinhaPreOS(preosId)
    If linha = 0 Then Exit Function
    BA_StatusPreOS = Trim$(CStr(ThisWorkbook.Sheets(SHEET_PREOS).Cells(linha, COL_PREOS_STATUS).Value))
End Function

Private Function BA_StatusOS(ByVal osId As String) As String
    Dim linha As Long
    linha = BA_LinhaOS(osId)
    If linha = 0 Then Exit Function
    BA_StatusOS = Trim$(CStr(ThisWorkbook.Sheets(SHEET_CAD_OS).Cells(linha, COL_OS_STATUS).Value))
End Function

Private Function BA_LinhaPreOS(ByVal preosId As String) As Long
    Dim ws As Worksheet
    Dim linha As Long
    Set ws = ThisWorkbook.Sheets(SHEET_PREOS)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_PREOS)
        If BA_Pad3(ws.Cells(linha, COL_PREOS_ID).Value) = BA_Pad3(preosId) Then
            BA_LinhaPreOS = linha
            Exit Function
        End If
    Next linha
End Function

Private Function BA_LinhaOS(ByVal osId As String) As Long
    Dim ws As Worksheet
    Dim linha As Long
    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_OS)
        If BA_Pad3(ws.Cells(linha, COL_OS_ID).Value) = BA_Pad3(osId) Then
            BA_LinhaOS = linha
            Exit Function
        End If
    Next linha
End Function

Private Function BA_StatusEmpresa(ByVal empId As String) As String
    Dim linha As Long
    BA_StatusEmpresa = Trim$(CStr(LerEmpresa(empId, linha).STATUS_GLOBAL))
End Function

Private Function BA_QtdRecusasEmpresa(ByVal empId As String) As Long
    Dim linha As Long
    BA_QtdRecusasEmpresa = LerEmpresa(empId, linha).QTD_RECUSAS
End Function

Private Sub BA_SetEmpresaStatus(ByVal empId As String, ByVal statusNovo As String, ByVal dtFim As Date, ByVal qtdRecusas As Long)
    Dim linha As Long
    Dim emp As TEmpresa
    emp = LerEmpresa(empId, linha)
    If linha > 0 Then
        GravarStatusEmpresa linha, statusNovo, dtFim, qtdRecusas
    End If
End Sub

Private Sub BA_SetCredStatus(ByVal empId As String, ByVal ativId As String, ByVal statusNovo As String)
    Dim ws As Worksheet
    Dim linha As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    linha = BA_LinhaCred(empId, ativId)
    If linha = 0 Then Exit Sub

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then Exit Sub
    ws.Cells(linha, COL_CRED_STATUS).Value = statusNovo
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
End Sub

Private Function BA_LinhaCred(ByVal empId As String, ByVal ativId As String) As Long
    Dim ws As Worksheet
    Dim i As Long
    Dim ativIdReal As String
    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    ativIdReal = BA_MapearAtivIdTeste(ativId)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If BA_Pad3(ws.Cells(i, COL_CRED_EMP_ID).Value) = BA_Pad3(empId) And BA_Pad3(ws.Cells(i, COL_CRED_ATIV_ID).Value) = BA_Pad3(ativIdReal) Then
            BA_LinhaCred = i
            Exit Function
        End If
    Next i
End Function

Private Function BA_StatusCred(ByVal empId As String, ByVal ativId As String) As String
    Dim ws As Worksheet
    Dim linha As Long

    linha = BA_LinhaCred(empId, ativId)
    If linha = 0 Then
        BA_StatusCred = ""
        Exit Function
    End If

    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)
    BA_StatusCred = Trim$(CStr(ws.Cells(linha, COL_CRED_STATUS).Value))
End Function

Private Function BA_ResumoRodizio(ByRef res As TRodizioResultado) As String
    If res.encontrou Then
        BA_ResumoRodizio = "EMP_ID=" & BA_Pad3(res.Empresa.EMP_ID) & "; MOTIVO=" & res.MotivoFalha
    Else
        BA_ResumoRodizio = "SEM_EMPRESA; MOTIVO=" & res.MotivoFalha
    End If
End Function

Private Function BA_ColunaChave(ByVal nomeAba As String) As Long
    Select Case UCase$(Trim$(nomeAba))
        Case UCase$(SHEET_ATIVIDADES)
            BA_ColunaChave = COL_ATIV_ID
        Case UCase$(SHEET_CAD_SERV)
            BA_ColunaChave = COL_SERV_ID
        Case UCase$(SHEET_CREDENCIADOS)
            BA_ColunaChave = COL_CRED_ID
        Case UCase$(SHEET_PREOS)
            BA_ColunaChave = COL_PREOS_ID
        Case UCase$(SHEET_CAD_OS)
            BA_ColunaChave = COL_OS_ID
        Case UCase$(SHEET_AUDIT)
            BA_ColunaChave = COL_AUDIT_ID
        Case Else
            BA_ColunaChave = 1
    End Select
End Function

Private Function BA_PrimeiraLinhaDados(ByVal nomeAba As String) As Long
    Select Case UCase$(Trim$(nomeAba))
        Case UCase$(SHEET_EMPRESAS)
            BA_PrimeiraLinhaDados = PrimeiraLinhaDadosEmpresas()
        Case Else
            BA_PrimeiraLinhaDados = LINHA_DADOS
    End Select
End Function

Private Function BA_CountLinhas(ByVal nomeAba As String) As Long
    Dim ws As Worksheet
    Dim colunaChave As Long
    Dim primeiraLinha As Long

    Set ws = ThisWorkbook.Sheets(nomeAba)
    colunaChave = BA_ColunaChave(nomeAba)
    primeiraLinha = BA_PrimeiraLinhaDados(nomeAba)
    BA_CountLinhas = Application.WorksheetFunction.CountA(ws.Range(ws.Cells(primeiraLinha, colunaChave), ws.Cells(ws.Rows.count, colunaChave)))
End Function

Private Function BA_NextDataRow(ByVal nomeAba As String) As Long
    Dim ws As Worksheet
    Dim colunaChave As Long
    Dim primeiraLinha As Long
    Dim ultimaCelula As Range

    Set ws = ThisWorkbook.Sheets(nomeAba)

    colunaChave = BA_ColunaChave(nomeAba)
    primeiraLinha = BA_PrimeiraLinhaDados(nomeAba)
    Set ultimaCelula = ws.Columns(colunaChave).Find(What:="*", After:=ws.Cells(1, colunaChave), LookIn:=xlValues, LookAt:=xlPart, SearchOrder:=xlByRows, SearchDirection:=xlPrevious, MatchCase:=False)

    If ultimaCelula Is Nothing Then
        BA_NextDataRow = primeiraLinha
    ElseIf ultimaCelula.row < primeiraLinha Then
        BA_NextDataRow = primeiraLinha
    Else
        BA_NextDataRow = ultimaCelula.row + 1
    End If
End Function

Private Sub BA_SetCounter(ByVal nomeAba As String, ByVal valor As Long)
    Dim ws As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Set ws = ThisWorkbook.Sheets(nomeAba)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then Exit Sub
    If CLng(Val(ws.Cells(1, COL_CONTADOR_AR).Value)) < valor Then
        ws.Cells(1, COL_CONTADOR_AR).Value = valor
    End If
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
End Sub

Private Function BA_ValorCounter(ByVal nomeAba As String) As Long
    BA_ValorCounter = CLng(Val(ThisWorkbook.Sheets(nomeAba).Cells(1, COL_CONTADOR_AR).Value))
End Function

Private Function BA_Pad3(ByVal valor As Variant) As String
    BA_Pad3 = Format$(CLng(Val(valor)), "000")
End Function
