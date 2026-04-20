Attribute VB_Name = "Repo_Empresa"
Option Explicit

' Repositorio da aba EMPRESAS — V12-CLEAN
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

            Exit For
        End If
    Next iRow

fim:
    LerEmpresa = emp
End Function

' Grava STATUS_GLOBAL e campos relacionados na aba EMPRESAS.
Public Sub GravarStatusEmpresa( _
    ByVal linhaEmp As Long, _
    ByVal NovoStatus As String, _
    ByVal dtFimSusp As Date, _
    ByVal qtdRecusas As Long _
)
    Dim ws As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then GoTo fim

    ws.Cells(linhaEmp, COL_EMP_STATUS_GLOBAL).Value = NovoStatus

    If dtFimSusp > CDate(0) Then
        ws.Cells(linhaEmp, COL_EMP_DT_FIM_SUSP).Value = dtFimSusp
    Else
        ws.Cells(linhaEmp, COL_EMP_DT_FIM_SUSP).Value = ""
    End If

    If qtdRecusas >= 0 Then
        ws.Cells(linhaEmp, COL_EMP_QTD_RECUSAS).Value = qtdRecusas
    End If

    ws.Cells(linhaEmp, COL_EMP_DT_ULT_ALT).Value = Now
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao

fim:
End Sub

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
        res.Sucesso = False
        res.Mensagem = "Nao foi possivel preparar EMPRESAS para escrita."
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

    res.Sucesso = True
    res.Mensagem = "Empresa inserida com sucesso."
    res.IdGerado = novoID
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Inserir = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.Sucesso = False
    res.Mensagem = "Erro ao inserir empresa: " & Err.Description
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
        res.Sucesso = False
        res.Mensagem = "Linha invalida para atualizacao: " & linhaEmp
        Atualizar = res
        Exit Function
    End If

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.Sucesso = False
        res.Mensagem = "Nao foi possivel preparar EMPRESAS para escrita."
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

    res.Sucesso = True
    res.Mensagem = "Empresa atualizada com sucesso."
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Atualizar = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.Sucesso = False
    res.Mensagem = "Erro ao atualizar empresa: " & Err.Description
    res.CodigoErro = Err.Number
    Atualizar = res
End Function


