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

Public Const TV2_STATUS_OK As String = "OK"
Public Const TV2_STATUS_FAIL As String = "FALHA"
Public Const TV2_STATUS_INFO As String = "INFO"
Public Const TV2_STATUS_MANUAL As String = "MANUAL_ASSISTIDO"

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

    TV2_GerarCatalogoBase
    TV2_LogInfo suite, "BOOT", "Inicializar a suite V2", "Suite pronta para execucao"
End Sub

Public Sub TV2_FinalizarExecucao(ByVal suite As String)
    Dim ws As Worksheet
    Dim nr As Long

    Set ws = TV2_EnsureHistoricoSheet()
    nr = TV2_NextRow(ws, 1, 2)

    ws.Cells(nr, 1).Value = gTV2ExecucaoId
    ws.Cells(nr, 2).Value = suite
    ws.Cells(nr, 3).Value = Now
    ws.Cells(nr, 4).Value = gTV2Ok
    ws.Cells(nr, 5).Value = gTV2Fail
    ws.Cells(nr, 6).Value = gTV2Manual
    ws.Cells(nr, 7).Value = gTV2Ok + gTV2Fail + gTV2Manual

    TV2_FormatarResultadoSheet

    MsgBox "Suite V2 concluida." & vbCrLf & _
           "Execucao: " & gTV2ExecucaoId & vbCrLf & _
           "OK=" & CStr(gTV2Ok) & " | FALHA=" & CStr(gTV2Fail) & " | MANUAL=" & CStr(gTV2Manual), _
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
    Set ws = TV2_EnsureResultadoSheet()
    ws.Activate
    ws.Range("A2").Select
End Sub

Public Sub TV2_AbrirCatalogo()
    Dim ws As Worksheet
    Set ws = TV2_EnsureCatalogoSheet()
    ws.Activate
    ws.Range("A2").Select
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
    TV2_AddCatalogo ws, nr, "SMK_001", "SMOKE", "RAPIDO", "AUTO", "Baseline", "Fila inicial canonica", "Base transacional vazia; 3 empresas credenciadas no item A", "Validar baseline e setup deterministico", "Fila inicial 001,002,003", "Garante ponto de partida repetivel", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "SMK_002", "SMOKE", "RAPIDO", "AUTO", "Rodizio", "Selecionar empresa do topo", "Fila canonica sem bloqueios", "Provar o contrato minimo do rodizio", "Seleciona EMP_ID=001", "Valida o fluxo central de indicacao", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "SMK_003", "SMOKE", "RAPIDO", "AUTO", "Pre-OS", "Emitir Pre-OS basica", "Entidade valida; atividade valida; quantidade positiva", "Validar persistencia minima de PRE_OS", "STATUS=AGUARDANDO_ACEITE e VL_EST coerente", "Confirma emissao basica sem UI", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "SMK_004", "SMOKE", "RAPIDO", "AUTO", "Rodizio", "Pre-OS pendente nao move fila", "Empresa do topo com PRE_OS aguardando aceite", "Validar filtro E e invariantes de nao-movimento", "Proxima indicacao retorna a segunda empresa; fila mantida", "Evita punicao indevida", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "SMK_005", "SMOKE", "RAPIDO", "AUTO", "Pre-OS", "Recusa avanca fila e pune", "PRE_OS aguardando aceite para a empresa do topo", "Validar politica de recusa com punicao", "Fila move para 002,003,001 e QTD_RECUSAS sobe", "Garante giro correto apos recusa", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "SMK_006", "SMOKE", "RAPIDO", "AUTO", "OS", "Emitir OS converte PRE_OS", "PRE_OS valida aguardando aceite", "Validar conversao minima Pre-OS -> OS", "PRE_OS convertida; OS em execucao", "Confirma integracao entre servicos", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "SMK_007", "SMOKE", "RAPIDO", "AUTO", "Avaliacao", "Avaliar OS e concluir", "OS em execucao com notas validas", "Validar fechamento minimo da OS", "OS concluida e fila continua consistente", "Fecha o ciclo core ponta a ponta", "AUTOMATIZADO_ATUAL", "Executado no smoke"
    TV2_AddCatalogo ws, nr, "STR_001", "STRESS", "COMPLETO", "AUTO", "Integridade", "Giros repetidos com recusa e conclusao", "Sequencia deterministica de 12 iteracoes", "Verificar invariantes de fila em repeticao", "IDs unicos; posicoes 1..3 sem buracos", "Captura regressao estrutural em lote", "AUTOMATIZADO_ATUAL", "Executado no stress"
    TV2_AddCatalogo ws, nr, "ASS_001", "ASSISTIDO", "ASSISTIDO", "ASSISTIDO", "UI", "Fluxo visual de menu e feedback", "Humano acompanha selecao de abas e resultados", "Dar leitura operacional dos testes", "Operador entende o que esta sendo testado", "Suporta homologacao observada", "PREVISTO_V2", "Executar smoke assistido"
    TV2_AddCatalogo ws, nr, "MIG_001", "MIGRACAO", "RAPIDO", "BLOQUEADO", "Pre-OS", "Entidade inexistente deve falhar no servico", "Hoje a guarda principal mora na interface", "Migrar validacao de ENT_ID para Svc_PreOS", "Servico retorna erro sem depender de form", "Remove dependencia da interface", "DEPENDENCIA_SERVICO", "Backlog aprovado"
    TV2_AddCatalogo ws, nr, "MIG_002", "MIGRACAO", "RAPIDO", "BLOQUEADO", "OS", "Data prevista invalida deve falhar no servico", "Hoje a guarda principal mora na interface", "Migrar validacao de DT_PREV_TERMINO para Svc_OS", "Servico rejeita data incoerente", "Torna automacao sem UI confiavel", "DEPENDENCIA_SERVICO", "Backlog aprovado"
    TV2_AddCatalogo ws, nr, "MIG_003", "MIGRACAO", "RAPIDO", "BLOQUEADO", "Avaliacao", "Divergencia exige justificativa no servico", "Hoje a guarda principal mora na interface", "Migrar regra de justificativa para Svc_Avaliacao", "Servico rejeita divergencia sem motivo", "Fecha lacuna de regra de negocio", "DEPENDENCIA_SERVICO", "Backlog aprovado"

    TV2_FormatarCatalogoSheet
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
End Sub

Private Sub TV2_ClearSheet(ByVal nomeAba As String)
    Dim ws As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim ultimaLinha As Long
    Dim ultimaColuna As Long
    Dim primeiraLinha As Long
    Dim lo As ListObject

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

    ultimaLinha = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    ultimaColuna = ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column
    primeiraLinha = TV2_PrimeiraLinhaDados(nomeAba)

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
    Dim ultima As Long
    Dim primeira As Long

    primeira = TV2_PrimeiraLinhaDados(nomeAba)
    ultima = UltimaLinhaAba(nomeAba)

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

Public Function TV2_FilaTemPosicoesCanonicas(ByVal ativId As String, ByVal qtdEsperada As Long) As Boolean
    Dim ws As Worksheet
    Dim linha As Long
    Dim dictPos As Object
    Dim dictEmp As Object
    Dim posicao As Long

    Set dictPos = CreateObject("Scripting.Dictionary")
    Set dictEmp = CreateObject("Scripting.Dictionary")
    Set ws = ThisWorkbook.Sheets(SHEET_CREDENCIADOS)

    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_CREDENCIADOS)
        If IdsIguais(ws.Cells(linha, COL_CRED_ATIV_ID).Value, ativId) Then
            posicao = CLng(Val(ws.Cells(linha, COL_CRED_POSICAO).Value))
            If posicao <= 0 Then Exit Function
            If dictPos.Exists(CStr(posicao)) Then Exit Function
            dictPos.Add CStr(posicao), True

            If dictEmp.Exists(TV2_Pad3(ws.Cells(linha, COL_CRED_EMP_ID).Value)) Then Exit Function
            dictEmp.Add TV2_Pad3(ws.Cells(linha, COL_CRED_EMP_ID).Value), True
        End If
    Next linha

    If dictPos.Count <> qtdEsperada Then Exit Function
    If dictEmp.Count <> qtdEsperada Then Exit Function

    For posicao = 1 To qtdEsperada
        If Not dictPos.Exists(CStr(posicao)) Then Exit Function
    Next posicao

    TV2_FilaTemPosicoesCanonicas = True
End Function

Public Function TV2_AtivCanonA() As String
    TV2_AtivCanonA = gTV2AtivCanonA
End Function

Public Function TV2_CodServicoA() As String
    TV2_CodServicoA = gTV2AtivCanonA & "|001"
End Function

Public Function TV2_CountRows(ByVal nomeAba As String) As Long
    Dim primeira As Long
    Dim ultima As Long

    primeira = TV2_PrimeiraLinhaDados(nomeAba)
    ultima = UltimaLinhaAba(nomeAba)
    If ultima < primeira Then Exit Function

    TV2_CountRows = ultima - primeira + 1
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

    Set ws = TV2_EnsureResultadoSheet()
    ws.Rows(1).Font.Bold = True
    ws.Rows(1).Interior.Color = RGB(0, 51, 102)
    ws.Rows(1).Font.Color = RGB(255, 255, 255)
    ws.Columns("A:K").EntireColumn.AutoFit
End Sub

Private Sub TV2_FormatarCatalogoSheet()
    Dim ws As Worksheet

    Set ws = TV2_EnsureCatalogoSheet()
    ws.Rows(1).Font.Bold = True
    ws.Rows(1).Interior.Color = RGB(0, 51, 102)
    ws.Rows(1).Font.Color = RGB(255, 255, 255)
    ws.Columns("A:L").EntireColumn.AutoFit
End Sub

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
