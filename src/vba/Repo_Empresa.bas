Attribute VB_Name = "Repo_Empresa"
Option Explicit

' Repositorio da aba EMPRESAS - V12-CLEAN
' Extraido de Repo_Credenciamento.bas (SECAO 2: HELPERS DE EMPRESAS).
' Usa Const_Colunas e Util_Planilha. Sem Select/ActiveCell.

' Le dados de uma empresa da aba EMPRESAS.
' linhaOut: retorna o numero da linha (0 = nao encontrado).
Public Function LerEmpresa( _
    ByVal EMP_ID As String, _
    ByRef linhaOut As Long _
) As TEmpresa
    Dim ws As Worksheet
    Dim emp As TEmpresa
    Dim iRow As Long

    linhaOut = 0
    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)

    For iRow = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
        If IdsIguais(ws.Cells(iRow, COL_EMP_ID).Value, EMP_ID) Then
            linhaOut = iRow
            emp.EMP_ID = CStr(ws.Cells(iRow, COL_EMP_ID).Value)
            emp.cnpj = CStr(ws.Cells(iRow, COL_EMP_CNPJ).Value)
            emp.RAZAO_NOME = CStr(ws.Cells(iRow, COL_EMP_RAZAO).Value)
            emp.STATUS_GLOBAL = CStr(ws.Cells(iRow, COL_EMP_STATUS_GLOBAL).Value)
            emp.QTD_RECUSAS = CLng(Val(ws.Cells(iRow, COL_EMP_QTD_RECUSAS).Value))
            emp.CONTATO_TEL = CStr(ws.Cells(iRow, COL_EMP_TEL_CEL).Value)
            emp.CONTATO_EMAIL = CStr(ws.Cells(iRow, COL_EMP_EMAIL).Value)
            emp.endereco = CStr(ws.Cells(iRow, COL_EMP_ENDERECO).Value)
            emp.bairro = CStr(ws.Cells(iRow, COL_EMP_BAIRRO).Value)
            emp.municipio = CStr(ws.Cells(iRow, COL_EMP_MUNICIPIO).Value)
            emp.uf = CStr(ws.Cells(iRow, COL_EMP_UF).Value)
            emp.cep = CStr(ws.Cells(iRow, COL_EMP_CEP).Value)

            Dim rawDtSusp As Variant
            rawDtSusp = ws.Cells(iRow, COL_EMP_DT_FIM_SUSP).Value
            If IsDate(rawDtSusp) Then
                emp.DT_FIM_SUSP = CDate(rawDtSusp)
            Else
                emp.DT_FIM_SUSP = CDate(0)
            End If

            Dim rawDtReativ As Variant
            rawDtReativ = ws.Cells(iRow, COL_EMP_DT_ULT_REATIV).Value
            If IsDate(rawDtReativ) Then
                emp.DT_ULT_REATIV = CDate(rawDtReativ)
            Else
                emp.DT_ULT_REATIV = CDate(0)
            End If

            Exit For
        End If
    Next iRow

fim:
    LerEmpresa = emp
End Function

' Grava STATUS_GLOBAL e campos relacionados na aba EMPRESAS.
Public Function GravarStatusEmpresa( _
    ByVal linhaEmp As Long, _
    ByVal NovoStatus As String, _
    ByVal dtFimSusp As Date, _
    ByVal qtdRecusas As Long, _
    Optional ByVal dtUltReativ As Variant _
) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim abaPreparada As Boolean
    Dim erroNumero As Long
    Dim erroMensagem As String

    On Error GoTo Erro

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    If linhaEmp < PrimeiraLinhaDadosEmpresas() Or linhaEmp > UltimaLinhaAba(SHEET_EMPRESAS) Then
        res.sucesso = False
        res.mensagem = "Linha invalida para gravar status de empresa: " & CStr(linhaEmp)
        GravarStatusEmpresa = res
        Exit Function
    End If

    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.sucesso = False
        res.mensagem = "Nao foi possivel preparar EMPRESAS para gravar status."
        GravarStatusEmpresa = res
        Exit Function
    End If
    abaPreparada = True

    ws.Cells(linhaEmp, COL_EMP_STATUS_GLOBAL).Value = NovoStatus

    If dtFimSusp > CDate(0) Then
        ws.Cells(linhaEmp, COL_EMP_DT_FIM_SUSP).Value = dtFimSusp
    Else
        ws.Cells(linhaEmp, COL_EMP_DT_FIM_SUSP).Value = ""
    End If

    If qtdRecusas >= 0 Then
        ws.Cells(linhaEmp, COL_EMP_QTD_RECUSAS).Value = qtdRecusas
    End If

    If IsDate(dtUltReativ) Then
        ws.Cells(linhaEmp, COL_EMP_DT_ULT_REATIV).Value = CDate(dtUltReativ)
    End If

    ws.Cells(linhaEmp, COL_EMP_DT_ULT_ALT).Value = Now
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    abaPreparada = False

    If Trim$(CStr(ws.Cells(linhaEmp, COL_EMP_STATUS_GLOBAL).Value)) <> NovoStatus Then
        res.sucesso = False
        res.mensagem = "STATUS_GLOBAL nao confirmou persistencia: esperado=" & NovoStatus & _
                       "; obtido=" & CStr(ws.Cells(linhaEmp, COL_EMP_STATUS_GLOBAL).Value)
        GravarStatusEmpresa = res
        Exit Function
    End If

    If dtFimSusp > CDate(0) Then
        If Not IsDate(ws.Cells(linhaEmp, COL_EMP_DT_FIM_SUSP).Value) Then
            res.sucesso = False
            res.mensagem = "DT_FIM_SUSP nao confirmou persistencia para EMPRESAS linha " & CStr(linhaEmp)
            GravarStatusEmpresa = res
            Exit Function
        End If
    Else
        If Trim$(CStr(ws.Cells(linhaEmp, COL_EMP_DT_FIM_SUSP).Value)) <> "" Then
            res.sucesso = False
            res.mensagem = "DT_FIM_SUSP deveria ficar vazia para EMPRESAS linha " & CStr(linhaEmp)
            GravarStatusEmpresa = res
            Exit Function
        End If
    End If

    If qtdRecusas >= 0 Then
        If CLng(Val("0" & Trim$(CStr(ws.Cells(linhaEmp, COL_EMP_QTD_RECUSAS).Value)))) <> qtdRecusas Then
            res.sucesso = False
            res.mensagem = "QTD_RECUSAS_GLOBAL nao confirmou persistencia para EMPRESAS linha " & CStr(linhaEmp)
            GravarStatusEmpresa = res
            Exit Function
        End If
    End If

    If IsDate(dtUltReativ) Then
        If Not IsDate(ws.Cells(linhaEmp, COL_EMP_DT_ULT_REATIV).Value) Then
            res.sucesso = False
            res.mensagem = "DT_ULT_REATIV nao confirmou persistencia para EMPRESAS linha " & CStr(linhaEmp)
            GravarStatusEmpresa = res
            Exit Function
        End If
    End If

    res.sucesso = True
    res.mensagem = "Status de empresa gravado na linha " & CStr(linhaEmp) & "."
    GravarStatusEmpresa = res
    Exit Function

Erro:
    erroNumero = Err.Number
    erroMensagem = Err.Description
    On Error Resume Next
    If abaPreparada Then Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.sucesso = False
    res.mensagem = "Erro em GravarStatusEmpresa: " & erroMensagem
    res.CodigoErro = erroNumero
    GravarStatusEmpresa = res
End Function

' Busca empresa por CNPJ. Retorna linha (0 = nao encontrada).
Public Function BuscarPorCNPJ( _
    ByVal cnpjBusca As String, _
    ByRef linhaOut As Long _
) As TEmpresa
    Dim ws As Worksheet
    Dim emp As TEmpresa
    Dim iRow As Long
    Dim cnpjLimpo As String

    linhaOut = 0
    On Error GoTo fim

    cnpjLimpo = Trim$(cnpjBusca)
    If cnpjLimpo = "" Then GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)

    For iRow = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
        If Trim$(CStr(ws.Cells(iRow, COL_EMP_CNPJ).Value)) = cnpjLimpo Then
            linhaOut = iRow
            emp = LerEmpresa(CStr(ws.Cells(iRow, COL_EMP_ID).Value), linhaOut)
            Exit For
        End If
    Next iRow

fim:
    BuscarPorCNPJ = emp
End Function

' Insere nova empresa na aba EMPRESAS. Retorna TResult com ID gerado.
Public Function Inserir( _
    ByVal cnpjVal As String, _
    ByVal razaoVal As String, _
    ByVal inscrMunVal As String, _
    ByVal responsavelVal As String, _
    ByVal cpfRespVal As String, _
    ByVal enderecoVal As String, _
    ByVal bairroVal As String, _
    ByVal municipioVal As String, _
    ByVal cepVal As String, _
    ByVal ufVal As String, _
    ByVal telFixoVal As String, _
    ByVal telCelVal As String, _
    ByVal emailVal As String, _
    ByVal experienciaVal As String _
) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim novaLinha As Long
    Dim novoID As String
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo Erro

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.sucesso = False
        res.mensagem = "Nao foi possivel preparar EMPRESAS para escrita."
        Inserir = res
        Exit Function
    End If

    novoID = ProximoId(SHEET_EMPRESAS)
    novaLinha = UltimaLinhaAba(SHEET_EMPRESAS) + 1

    ws.Cells(novaLinha, COL_EMP_ID).Value = novoID
    ws.Cells(novaLinha, COL_EMP_CNPJ).Value = cnpjVal
    ws.Cells(novaLinha, COL_EMP_RAZAO).Value = Funcoes.NormalizarTextoPTBR(razaoVal)
    ws.Cells(novaLinha, COL_EMP_INSCR_MUN).Value = inscrMunVal
    ws.Cells(novaLinha, COL_EMP_RESPONSAVEL).Value = Funcoes.NormalizarTextoPTBR(responsavelVal)
    ws.Cells(novaLinha, COL_EMP_CPF_RESP).Value = cpfRespVal
    ws.Cells(novaLinha, COL_EMP_ENDERECO).Value = Funcoes.NormalizarTextoPTBR(enderecoVal)
    ws.Cells(novaLinha, COL_EMP_BAIRRO).Value = Funcoes.NormalizarTextoPTBR(bairroVal)
    ws.Cells(novaLinha, COL_EMP_MUNICIPIO).Value = Funcoes.NormalizarTextoPTBR(municipioVal)
    ws.Cells(novaLinha, COL_EMP_CEP).Value = cepVal
    ws.Cells(novaLinha, COL_EMP_UF).Value = ufVal
    ws.Cells(novaLinha, COL_EMP_TEL_FIXO).Value = telFixoVal
    ws.Cells(novaLinha, COL_EMP_TEL_CEL).Value = telCelVal
    ws.Cells(novaLinha, COL_EMP_EMAIL).Value = emailVal
    ws.Cells(novaLinha, COL_EMP_EXPERIENCIA).Value = Funcoes.NormalizarTextoPTBR(experienciaVal)
    ws.Cells(novaLinha, COL_EMP_STATUS_GLOBAL).Value = "ATIVA"
    ws.Cells(novaLinha, COL_EMP_DT_CAD).Value = Now
    ws.Cells(novaLinha, COL_EMP_DT_ULT_ALT).Value = Now
    ws.Cells(novaLinha, COL_EMP_DT_ULT_REATIV).Value = ""

    res.sucesso = True
    res.mensagem = "Empresa inserida com sucesso."
    res.IdGerado = novoID
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Inserir = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.sucesso = False
    res.mensagem = "Erro ao inserir empresa: " & Err.Description
    res.CodigoErro = Err.Number
    Inserir = res
End Function

' Atualiza dados de empresa existente na aba EMPRESAS.
Public Function Atualizar( _
    ByVal linhaEmp As Long, _
    ByVal razaoVal As String, _
    ByVal inscrMunVal As String, _
    ByVal responsavelVal As String, _
    ByVal cpfRespVal As String, _
    ByVal enderecoVal As String, _
    ByVal bairroVal As String, _
    ByVal municipioVal As String, _
    ByVal cepVal As String, _
    ByVal ufVal As String, _
    ByVal telFixoVal As String, _
    ByVal telCelVal As String, _
    ByVal emailVal As String, _
    ByVal experienciaVal As String _
) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo Erro

    If linhaEmp < LINHA_DADOS Then
        res.sucesso = False
        res.mensagem = "Linha invalida para atualizacao: " & linhaEmp
        Atualizar = res
        Exit Function
    End If

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.sucesso = False
        res.mensagem = "Nao foi possivel preparar EMPRESAS para escrita."
        Atualizar = res
        Exit Function
    End If

    ws.Cells(linhaEmp, COL_EMP_RAZAO).Value = Funcoes.NormalizarTextoPTBR(razaoVal)
    ws.Cells(linhaEmp, COL_EMP_INSCR_MUN).Value = inscrMunVal
    ws.Cells(linhaEmp, COL_EMP_RESPONSAVEL).Value = Funcoes.NormalizarTextoPTBR(responsavelVal)
    ws.Cells(linhaEmp, COL_EMP_CPF_RESP).Value = cpfRespVal
    ws.Cells(linhaEmp, COL_EMP_ENDERECO).Value = Funcoes.NormalizarTextoPTBR(enderecoVal)
    ws.Cells(linhaEmp, COL_EMP_BAIRRO).Value = Funcoes.NormalizarTextoPTBR(bairroVal)
    ws.Cells(linhaEmp, COL_EMP_MUNICIPIO).Value = Funcoes.NormalizarTextoPTBR(municipioVal)
    ws.Cells(linhaEmp, COL_EMP_CEP).Value = cepVal
    ws.Cells(linhaEmp, COL_EMP_UF).Value = ufVal
    ws.Cells(linhaEmp, COL_EMP_TEL_FIXO).Value = telFixoVal
    ws.Cells(linhaEmp, COL_EMP_TEL_CEL).Value = telCelVal
    ws.Cells(linhaEmp, COL_EMP_EMAIL).Value = emailVal
    ws.Cells(linhaEmp, COL_EMP_EXPERIENCIA).Value = Funcoes.NormalizarTextoPTBR(experienciaVal)
    ws.Cells(linhaEmp, COL_EMP_DT_ULT_ALT).Value = Now

    res.sucesso = True
    res.mensagem = "Empresa atualizada com sucesso."
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Atualizar = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.sucesso = False
    res.mensagem = "Erro ao atualizar empresa: " & Err.Description
    res.CodigoErro = Err.Number
    Atualizar = res
End Function

' Detecta apenas valores nao vazios e invalidos em DT_ULT_REATIV.
' Campo vazio continua sendo modo legado/backfill, nao erro estrutural.
Public Function RepoEmpresa_DtUltReativInvalidasResumo( _
    ByRef qtdInvalidas As Long, _
    ByRef detalhes As String _
) As TResult
    Dim res As TResult
    Dim wsEmp As Worksheet
    Dim iRow As Long
    Dim empId As String
    Dim valor As Variant

    On Error GoTo Erro

    qtdInvalidas = 0
    detalhes = ""
    Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)

    For iRow = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
        empId = Trim$(CStr(wsEmp.Cells(iRow, COL_EMP_ID).Value))
        If empId <> "" Then
            valor = wsEmp.Cells(iRow, COL_EMP_DT_ULT_REATIV).Value
            If RepoEmpresa_DtUltReativValorInvalido(valor) Then
                qtdInvalidas = qtdInvalidas + 1
                RepoEmpresa_AppendRelatorio detalhes, _
                    "EMP_ID=" & empId & "; VALOR=" & RepoEmpresa_DtUltReativValorParaRelatorio(valor)
            End If
        End If
    Next iRow

    res.sucesso = True
    res.mensagem = "DT_ULT_REATIV invalidas: " & CStr(qtdInvalidas)
    RepoEmpresa_DtUltReativInvalidasResumo = res
    Exit Function

Erro:
    res.sucesso = False
    res.mensagem = "Erro ao detectar DT_ULT_REATIV invalidas: " & Err.Description
    res.CodigoErro = Err.Number
    RepoEmpresa_DtUltReativInvalidasResumo = res
End Function

' Detecta empresas com DT_ULT_REATIV vazia/invalida que podem ser
' reconstruidas a partir do ultimo EVT_REATIVACAO no AUDIT_LOG.
Public Function RepoEmpresa_DtUltReativBackfillResumo( _
    ByRef qtdPendentes As Long, _
    ByRef detalhes As String _
) As TResult
    Dim res As TResult
    Dim wsEmp As Worksheet
    Dim iRow As Long
    Dim empId As String
    Dim dtAudit As Date

    On Error GoTo Erro

    qtdPendentes = 0
    detalhes = ""
    Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)

    For iRow = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
        empId = Trim$(CStr(wsEmp.Cells(iRow, COL_EMP_ID).Value))
        If empId <> "" Then
            If RepoEmpresa_DtUltReativPrecisaBackfill(wsEmp.Cells(iRow, COL_EMP_DT_ULT_REATIV).Value) Then
                dtAudit = RepoEmpresa_UltimaReativacaoAudit(empId)
                If dtAudit > CDate(0) Then
                    qtdPendentes = qtdPendentes + 1
                    RepoEmpresa_AppendRelatorio detalhes, _
                        "EMP_ID=" & empId & "; DT_AUDIT=" & Format$(dtAudit, "yyyy-mm-dd hh:nn:ss")
                End If
            End If
        End If
    Next iRow

    res.sucesso = True
    res.mensagem = "Backfill DT_ULT_REATIV pendente: " & CStr(qtdPendentes)
    RepoEmpresa_DtUltReativBackfillResumo = res
    Exit Function

Erro:
    res.sucesso = False
    res.mensagem = "Erro ao detectar backfill DT_ULT_REATIV: " & Err.Description
    res.CodigoErro = Err.Number
    RepoEmpresa_DtUltReativBackfillResumo = res
End Function

' Aplica backfill explicito de DT_ULT_REATIV a partir do AUDIT_LOG.
' Nao e chamado automaticamente na abertura do workbook.
Public Function RepoEmpresa_BackfillDtUltReativPorAuditLog( _
    ByRef qtdAtualizadas As Long, _
    ByRef relatorio As String _
) As TResult
    Dim res As TResult
    Dim wsEmp As Worksheet
    Dim iRow As Long
    Dim empId As String
    Dim dtAudit As Date
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim abaPreparada As Boolean
    Dim erroNumero As Long
    Dim erroMensagem As String

    On Error GoTo Erro

    qtdAtualizadas = 0
    relatorio = ""
    Set wsEmp = ThisWorkbook.Sheets(SHEET_EMPRESAS)

    If Not Util_PrepararAbaParaEscrita(wsEmp, estavaProtegida, senhaProtecao) Then
        res.sucesso = False
        res.mensagem = "Nao foi possivel preparar EMPRESAS para backfill DT_ULT_REATIV."
        RepoEmpresa_BackfillDtUltReativPorAuditLog = res
        Exit Function
    End If
    abaPreparada = True

    For iRow = PrimeiraLinhaDadosEmpresas() To UltimaLinhaAba(SHEET_EMPRESAS)
        empId = Trim$(CStr(wsEmp.Cells(iRow, COL_EMP_ID).Value))
        If empId <> "" Then
            If RepoEmpresa_DtUltReativPrecisaBackfill(wsEmp.Cells(iRow, COL_EMP_DT_ULT_REATIV).Value) Then
                dtAudit = RepoEmpresa_UltimaReativacaoAudit(empId)
                If dtAudit > CDate(0) Then
                    wsEmp.Cells(iRow, COL_EMP_DT_ULT_REATIV).Value = dtAudit
                    wsEmp.Cells(iRow, COL_EMP_DT_ULT_ALT).Value = Now
                    If Not IsDate(wsEmp.Cells(iRow, COL_EMP_DT_ULT_REATIV).Value) Then
                        Err.Raise 1004, "RepoEmpresa_BackfillDtUltReativPorAuditLog", _
                                  "DT_ULT_REATIV nao confirmou persistencia para EMP_ID=" & empId
                    End If

                    qtdAtualizadas = qtdAtualizadas + 1
                    RepoEmpresa_AppendRelatorio relatorio, _
                        "EMP_ID=" & empId & "; DT_ULT_REATIV=" & Format$(dtAudit, "yyyy-mm-dd hh:nn:ss")
                    RegistrarEvento EVT_TRANSACAO, ENT_EMP, empId, _
                        "DT_ULT_REATIV=(vazia/invalida)", _
                        "BACKFILL_DT_ULT_REATIV=" & Format$(dtAudit, "yyyy-mm-dd hh:nn:ss"), _
                        "Repo_Empresa.BackfillDtUltReativ"
                End If
            End If
        End If
    Next iRow

    Util_RestaurarProtecaoAba wsEmp, estavaProtegida, senhaProtecao
    abaPreparada = False

    res.sucesso = True
    res.mensagem = "Backfill DT_ULT_REATIV aplicado: " & CStr(qtdAtualizadas)
    RepoEmpresa_BackfillDtUltReativPorAuditLog = res
    Exit Function

Erro:
    erroNumero = Err.Number
    erroMensagem = Err.Description
    On Error Resume Next
    If abaPreparada Then Util_RestaurarProtecaoAba wsEmp, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.sucesso = False
    res.mensagem = "Erro ao aplicar backfill DT_ULT_REATIV: " & erroMensagem
    res.CodigoErro = erroNumero
    RepoEmpresa_BackfillDtUltReativPorAuditLog = res
End Function

Private Function RepoEmpresa_DtUltReativPrecisaBackfill(ByVal valor As Variant) As Boolean
    If IsError(valor) Then
        RepoEmpresa_DtUltReativPrecisaBackfill = True
    ElseIf Trim$(CStr(valor)) = "" Then
        RepoEmpresa_DtUltReativPrecisaBackfill = True
    ElseIf Not IsDate(valor) Then
        RepoEmpresa_DtUltReativPrecisaBackfill = True
    ElseIf CDate(valor) <= CDate(0) Then
        RepoEmpresa_DtUltReativPrecisaBackfill = True
    End If
End Function

Private Function RepoEmpresa_DtUltReativValorInvalido(ByVal valor As Variant) As Boolean
    If IsError(valor) Then
        RepoEmpresa_DtUltReativValorInvalido = True
    ElseIf IsNull(valor) Then
        RepoEmpresa_DtUltReativValorInvalido = False
    ElseIf Trim$(CStr(valor)) = "" Then
        RepoEmpresa_DtUltReativValorInvalido = False
    ElseIf Not IsDate(valor) Then
        RepoEmpresa_DtUltReativValorInvalido = True
    ElseIf CDate(valor) <= CDate(0) Then
        RepoEmpresa_DtUltReativValorInvalido = True
    End If
End Function

Private Function RepoEmpresa_DtUltReativValorParaRelatorio(ByVal valor As Variant) As String
    If IsError(valor) Then
        RepoEmpresa_DtUltReativValorParaRelatorio = "#ERRO"
    ElseIf IsNull(valor) Then
        RepoEmpresa_DtUltReativValorParaRelatorio = "(null)"
    ElseIf Trim$(CStr(valor)) = "" Then
        RepoEmpresa_DtUltReativValorParaRelatorio = "(vazia)"
    ElseIf IsDate(valor) Then
        RepoEmpresa_DtUltReativValorParaRelatorio = Format$(CDate(valor), "yyyy-mm-dd hh:nn:ss")
    Else
        RepoEmpresa_DtUltReativValorParaRelatorio = Left$(Trim$(CStr(valor)), 80)
    End If
End Function

Private Function RepoEmpresa_UltimaReativacaoAudit(ByVal empId As String) As Date
    Dim wsAudit As Worksheet
    Dim linha As Long
    Dim dtEvento As Date
    Dim entidade As String

    Set wsAudit = ThisWorkbook.Sheets(SHEET_AUDIT)
    For linha = LINHA_DADOS To UltimaLinhaAba(SHEET_AUDIT)
        If CLng(Val(wsAudit.Cells(linha, COL_AUDIT_TIPO).Value)) = CLng(EVT_REATIVACAO) Then
            entidade = UCase$(Trim$(CStr(wsAudit.Cells(linha, COL_AUDIT_ENTIDADE).Value)))
            If entidade = "EMPRESA" Then
                If IdsIguais(wsAudit.Cells(linha, COL_AUDIT_ID_AFETADO).Value, empId) Then
                    If IsDate(wsAudit.Cells(linha, COL_AUDIT_DT).Value) Then
                        dtEvento = CDate(wsAudit.Cells(linha, COL_AUDIT_DT).Value)
                        If dtEvento > RepoEmpresa_UltimaReativacaoAudit Then
                            RepoEmpresa_UltimaReativacaoAudit = dtEvento
                        End If
                    End If
                End If
            End If
        End If
    Next linha
End Function

Private Sub RepoEmpresa_AppendRelatorio(ByRef relatorio As String, ByVal item As String)
    If Len(relatorio) > 0 Then relatorio = relatorio & " | "
    relatorio = relatorio & item
End Sub


