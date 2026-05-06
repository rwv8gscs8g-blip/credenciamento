Attribute VB_Name = "Repo_OS"
Option Explicit

' Repositório da aba CAD_OS - V10
' Usa Const_Colunas para mapeamento. Sem Select/ActiveCell.

Private Const STATUS_OS_EM_EXECUCAO As String = "EM_EXECUCAO"

' Insere nova OS. Gera OS_ID automaticamente.
Public Function Inserir(ByRef O As TOS) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim linha As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo Erro

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.sucesso = False
        res.mensagem = "Nao foi possivel preparar CAD_OS para escrita."
        Inserir = res
        Exit Function
    End If

    O.OS_ID = ProximoId(SHEET_CAD_OS)
    linha = UltimaLinhaAba(SHEET_CAD_OS) + 1

    ws.Cells(linha, COL_OS_ID).Value = O.OS_ID
    ws.Cells(linha, COL_OS_ENT_ID).Value = O.ENT_ID
    ws.Cells(linha, COL_OS_COD_SERV).Value = O.ATIV_ID & "|" & O.SERV_ID
    ws.Cells(linha, COL_OS_EMP_ID).Value = O.EMP_ID
    ws.Cells(linha, COL_OS_EMPENHO).Value = O.NUM_EMPENHO
    ws.Cells(linha, COL_OS_DT_EMISSAO).Value = O.DT_EMISSAO
    ws.Cells(linha, COL_OS_DT_PREV_FIM).Value = O.DT_PREV_TERMINO
    ' DT_FECHAMENTO vazio
    ws.Cells(linha, COL_OS_QT_EST).Value = O.QT_ESTIMADA
    ws.Cells(linha, COL_OS_VL_TOTAL).Value = O.VALOR_TOTAL_OS
    ' QT_EXEC, VL_EXEC, DT_PAGTO, NOTAS vazias
    ws.Cells(linha, COL_OS_ATIV_ID).Value = O.ATIV_ID
    ws.Cells(linha, COL_OS_PREOS_ID).Value = O.PREOS_ID
    ws.Cells(linha, COL_OS_STATUS).Value = O.STATUS_OS
    ws.Cells(linha, COL_OS_VL_UNIT).Value = O.VALOR_UNIT
    ' JUSTIF_DIVERGENCIA vazio

    res.sucesso = True
    res.mensagem = "OS inserida com sucesso."
    res.IdGerado = O.OS_ID
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Inserir = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.sucesso = False
    res.mensagem = "Erro ao inserir OS: " & Err.Description
    res.CodigoErro = Err.Number
    Inserir = res
End Function

Public Function RepoOS_Inserir(ByRef O As TOS) As TResult
    RepoOS_Inserir = Inserir(O)
End Function

' Busca OS por ID.
Public Function BuscarPorId(ByVal OS_ID As String) As TOS
    Dim O As TOS
    Dim ws As Worksheet
    Dim i As Long

    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_OS)
        If IdsIguais(ws.Cells(i, COL_OS_ID).Value, OS_ID) Then
            O.OS_ID = CStr(ws.Cells(i, COL_OS_ID).Value)
            O.ENT_ID = CStr(ws.Cells(i, COL_OS_ENT_ID).Value)
            O.ATIV_ID = CStr(ws.Cells(i, COL_OS_ATIV_ID).Value)
            O.SERV_ID = ExtrairServId(CStr(ws.Cells(i, COL_OS_COD_SERV).Value), O.ATIV_ID)
            O.EMP_ID = CStr(ws.Cells(i, COL_OS_EMP_ID).Value)
            O.NUM_EMPENHO = CStr(ws.Cells(i, COL_OS_EMPENHO).Value)
            O.DT_EMISSAO = ws.Cells(i, COL_OS_DT_EMISSAO).Value
            O.DT_PREV_TERMINO = ws.Cells(i, COL_OS_DT_PREV_FIM).Value
            O.QT_ESTIMADA = CDbl(Val(ws.Cells(i, COL_OS_QT_EST).Value))
            O.QT_CONFIRMADA = CDbl(Val(ws.Cells(i, COL_OS_QT_EXEC).Value))
            O.VALOR_UNIT = CCur(Val(ws.Cells(i, COL_OS_VL_UNIT).Value))
            O.VALOR_TOTAL_OS = CCur(Val(ws.Cells(i, COL_OS_VL_TOTAL).Value))
            O.PREOS_ID = CStr(ws.Cells(i, COL_OS_PREOS_ID).Value)
            O.STATUS_OS = CStr(ws.Cells(i, COL_OS_STATUS).Value)
            O.JUSTIF_DIVERGENCIA = CStr(ws.Cells(i, COL_OS_JUSTIF_DIV).Value)
            O.DT_FECHAMENTO = ws.Cells(i, COL_OS_DT_FECHAMENTO).Value
            Exit For
        End If
    Next i

fim:
    BuscarPorId = O
End Function

Public Function RepoOS_BuscarPorId(ByVal OS_ID As String) As TOS
    RepoOS_BuscarPorId = BuscarPorId(OS_ID)
End Function

Private Function ExtrairServId(ByVal codServ As String, ByVal ativId As String) As String
    Dim p As Long
    Dim s As String
    Dim a As String

    s = Trim$(CStr(codServ))
    a = Trim$(CStr(ativId))
    If s = "" Then Exit Function

    p = InStr(1, s, "|", vbBinaryCompare)
    If p > 1 Then
        ExtrairServId = Trim$(Mid$(s, p + 1))
        Exit Function
    End If

    If a <> "" Then
        If Left$(s, Len(a)) = a Then
            ExtrairServId = Mid$(s, Len(a) + 1)
            Exit Function
        End If
    End If

    If Len(s) >= 4 Then ExtrairServId = Mid$(s, 4)
End Function

' Remove OS por ID. Uso principal: rollback de emissao quando etapa posterior
' falha antes da conclusao transacional.
Public Function ExcluirPorId(ByVal OS_ID As String) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim i As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo Erro

    If Trim$(OS_ID) = "" Then
        res.sucesso = False
        res.mensagem = "OS_ID obrigatorio para exclusao."
        ExcluirPorId = res
        Exit Function
    End If

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)
    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_OS)
        If IdsIguais(ws.Cells(i, COL_OS_ID).Value, OS_ID) Then
            If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
                res.sucesso = False
                res.mensagem = "Nao foi possivel preparar CAD_OS para exclusao."
                ExcluirPorId = res
                Exit Function
            End If

            If Not Util_ExcluirLinhaSegura(ws, i) Then
                res.sucesso = False
                res.mensagem = "Nao foi possivel excluir OS_ID=" & OS_ID
                Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
                ExcluirPorId = res
                Exit Function
            End If

            res.sucesso = True
            res.mensagem = "OS excluida com sucesso."
            res.IdGerado = OS_ID
            Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
            ExcluirPorId = res
            Exit Function
        End If
    Next i

    res.sucesso = False
    res.mensagem = "OS_ID " & OS_ID & " nao encontrada para exclusao."
    ExcluirPorId = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.sucesso = False
    res.mensagem = "Erro ao excluir OS: " & Err.Description
    res.CodigoErro = Err.Number
    ExcluirPorId = res
End Function

Public Function RepoOS_ExcluirPorId(ByVal OS_ID As String) As TResult
    RepoOS_ExcluirPorId = ExcluirPorId(OS_ID)
End Function

' Atualiza registro de OS existente.
Public Function Atualizar(ByRef O As TOS) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim i As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String

    On Error GoTo Erro

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.sucesso = False
        res.mensagem = "Nao foi possivel preparar CAD_OS para escrita."
        Atualizar = res
        Exit Function
    End If

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_OS)
        If IdsIguais(ws.Cells(i, COL_OS_ID).Value, O.OS_ID) Then
            ws.Cells(i, COL_OS_DT_FECHAMENTO).Value = O.DT_FECHAMENTO
            ws.Cells(i, COL_OS_QT_EXEC).Value = O.QT_CONFIRMADA
            ws.Cells(i, COL_OS_VL_EXEC).Value = O.QT_CONFIRMADA * O.VALOR_UNIT
            ws.Cells(i, COL_OS_STATUS).Value = O.STATUS_OS
            ws.Cells(i, COL_OS_JUSTIF_DIV).Value = O.JUSTIF_DIVERGENCIA
            ws.Cells(i, COL_OS_OBSERVACOES).Value = ""

            res.sucesso = True
            res.mensagem = "OS atualizada com sucesso."
            res.IdGerado = O.OS_ID
            Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
            Atualizar = res
            Exit Function
        End If
    Next i

    res.sucesso = False
    res.mensagem = "OS ID " & O.OS_ID & " nao encontrada."
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    Atualizar = res
    Exit Function

Erro:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.sucesso = False
    res.mensagem = "Erro ao atualizar OS: " & Err.Description
    res.CodigoErro = Err.Number
    Atualizar = res
End Function

' Verifica se empresa tem OS aberta (EM_EXECUCAO) em uma atividade.
Public Function TemOSAbertaNaAtividade( _
    ByVal EMP_ID As String, _
    ByVal ATIV_ID As String _
) As Boolean
    Dim ws As Worksheet
    Dim i As Long

    On Error GoTo fim

    TemOSAbertaNaAtividade = False
    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)

    For i = LINHA_DADOS To UltimaLinhaAba(SHEET_CAD_OS)
        If IdsIguais(ws.Cells(i, COL_OS_EMP_ID).Value, EMP_ID) And _
           IdsIguais(ws.Cells(i, COL_OS_ATIV_ID).Value, ATIV_ID) And _
           Trim$(UCase$(CStr(ws.Cells(i, COL_OS_STATUS).Value))) = STATUS_OS_EM_EXECUCAO Then
            TemOSAbertaNaAtividade = True
            Exit Function
        End If
    Next i

fim:
End Function

Public Function RepoOS_DiagnosticarReferenciasCADOS( _
    ByRef qtdOrfaEmp As Long, _
    ByRef qtdOrfaAtiv As Long, _
    ByRef qtdResiduosSemChave As Long, _
    ByRef detalhes As String _
) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim setEmp As Object
    Dim setAtiv As Object
    Dim ultima As Long
    Dim linha As Long
    Dim osId As String
    Dim empKey As String
    Dim ativKey As String

    On Error GoTo Erro

    qtdOrfaEmp = 0
    qtdOrfaAtiv = 0
    qtdResiduosSemChave = 0
    detalhes = ""

    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)
    Set setEmp = CreateObject("Scripting.Dictionary")
    Set setAtiv = CreateObject("Scripting.Dictionary")

    RepoOS_CarregarIdsValidos setEmp, SHEET_EMPRESAS, COL_EMP_ID, PrimeiraLinhaDadosEmpresas()
    RepoOS_CarregarIdsValidos setEmp, SHEET_EMPRESAS_INATIVAS, COL_EMP_ID, LINHA_DADOS
    RepoOS_CarregarIdsValidos setAtiv, SHEET_ATIVIDADES, COL_ATIV_ID, LINHA_DADOS

    ultima = RepoOS_UltimaLinhaVarredura(ws, COL_OS_JUSTIF_DIV)
    For linha = LINHA_DADOS To ultima
        If RepoOS_LinhaSemChaveComDados(ws, linha, COL_OS_JUSTIF_DIV) Then
            qtdResiduosSemChave = qtdResiduosSemChave + 1
            RepoOS_AnexarDetalhe detalhes, "RESIDUO linha=" & CStr(linha)
        Else
            osId = Trim$(CStr(ws.Cells(linha, COL_OS_ID).Value))
            If osId <> "" Then
                empKey = RepoOS_NormalizarChave(ws.Cells(linha, COL_OS_EMP_ID).Value)
                If empKey = "" Or Not setEmp.Exists(empKey) Then
                    qtdOrfaEmp = qtdOrfaEmp + 1
                    RepoOS_AnexarDetalhe detalhes, "ORFA_EMP linha=" & CStr(linha) & ";EMP_ID=" & CStr(ws.Cells(linha, COL_OS_EMP_ID).Value)
                End If

                ativKey = RepoOS_NormalizarChave(ws.Cells(linha, COL_OS_ATIV_ID).Value)
                If ativKey = "" Or Not setAtiv.Exists(ativKey) Then
                    qtdOrfaAtiv = qtdOrfaAtiv + 1
                    RepoOS_AnexarDetalhe detalhes, "ORFA_ATIV linha=" & CStr(linha) & ";ATIV_ID=" & CStr(ws.Cells(linha, COL_OS_ATIV_ID).Value)
                End If
            End If
        End If
    Next linha

    res.sucesso = True
    res.mensagem = "Diagnostico CAD_OS concluido: ORFA_EMP=" & CStr(qtdOrfaEmp) & _
                   "; ORFA_ATIV=" & CStr(qtdOrfaAtiv) & _
                   "; RESIDUOS_SEM_CHAVE=" & CStr(qtdResiduosSemChave)
    RepoOS_DiagnosticarReferenciasCADOS = res
    Exit Function

Erro:
    res.sucesso = False
    res.mensagem = "Erro ao diagnosticar referencias CAD_OS: " & Err.Description
    res.CodigoErro = Err.Number
    RepoOS_DiagnosticarReferenciasCADOS = res
End Function

Public Function RepoOS_LimparResiduosCADOSSemChave( _
    ByRef qtdLimpas As Long, _
    ByRef relatorio As String _
) As TResult
    Dim res As TResult
    Dim ws As Worksheet
    Dim ultima As Long
    Dim linha As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim abaPreparada As Boolean

    On Error GoTo Erro

    qtdLimpas = 0
    relatorio = ""
    Set ws = ThisWorkbook.Sheets(SHEET_CAD_OS)

    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        res.sucesso = False
        res.mensagem = "Nao foi possivel preparar CAD_OS para limpeza controlada."
        RepoOS_LimparResiduosCADOSSemChave = res
        Exit Function
    End If
    abaPreparada = True

    ultima = RepoOS_UltimaLinhaVarredura(ws, COL_OS_JUSTIF_DIV)
    For linha = ultima To LINHA_DADOS Step -1
        If RepoOS_LinhaSemChaveComDados(ws, linha, COL_OS_JUSTIF_DIV) Then
            ws.Range(ws.Cells(linha, 1), ws.Cells(linha, COL_OS_JUSTIF_DIV)).ClearContents
            qtdLimpas = qtdLimpas + 1
            RepoOS_AnexarDetalhe relatorio, "LIMPA linha=" & CStr(linha)
        End If
    Next linha

    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    abaPreparada = False

    If qtdLimpas > 0 Then
        RegistrarEvento EVT_TRANSACAO, ENT_OS, "CAD_OS", _
            "RESIDUOS_SEM_CHAVE=" & CStr(qtdLimpas), _
            "LIMPEZA_REF_ORFA_CONTROLADA=OK", _
            "Repo_OS.LimparResiduosCADOSSemChave"
    End If

    res.sucesso = True
    res.mensagem = "Limpeza controlada CAD_OS concluida: RESIDUOS_LIMPOS=" & CStr(qtdLimpas)
    RepoOS_LimparResiduosCADOSSemChave = res
    Exit Function

Erro:
    On Error Resume Next
    If abaPreparada Then Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    res.sucesso = False
    res.mensagem = "Erro ao limpar residuos CAD_OS: " & Err.Description
    res.CodigoErro = Err.Number
    RepoOS_LimparResiduosCADOSSemChave = res
End Function

Public Function RepoOS_MigrarRefOrfaLegado() As String
    Dim resAntes As TResult
    Dim resLimpar As TResult
    Dim resDepois As TResult
    Dim qtdOrfaEmpAntes As Long
    Dim qtdOrfaAtivAntes As Long
    Dim qtdResidAntes As Long
    Dim qtdOrfaEmpDepois As Long
    Dim qtdOrfaAtivDepois As Long
    Dim qtdResidDepois As Long
    Dim qtdLimpas As Long
    Dim detalhesAntes As String
    Dim detalhesDepois As String
    Dim relatorio As String

    On Error GoTo Erro

    resAntes = RepoOS_DiagnosticarReferenciasCADOS(qtdOrfaEmpAntes, qtdOrfaAtivAntes, qtdResidAntes, detalhesAntes)
    If Not resAntes.sucesso Then
        RepoOS_MigrarRefOrfaLegado = "ERRO_DIAG_ANTES: " & resAntes.mensagem
        Exit Function
    End If

    resLimpar = RepoOS_LimparResiduosCADOSSemChave(qtdLimpas, relatorio)
    If Not resLimpar.sucesso Then
        RepoOS_MigrarRefOrfaLegado = "ERRO_LIMPEZA: " & resLimpar.mensagem
        Exit Function
    End If

    resDepois = RepoOS_DiagnosticarReferenciasCADOS(qtdOrfaEmpDepois, qtdOrfaAtivDepois, qtdResidDepois, detalhesDepois)
    If Not resDepois.sucesso Then
        RepoOS_MigrarRefOrfaLegado = "ERRO_DIAG_DEPOIS: " & resDepois.mensagem
        Exit Function
    End If

    RepoOS_MigrarRefOrfaLegado = _
        "ANTES: ORFA_EMP=" & CStr(qtdOrfaEmpAntes) & _
        "; ORFA_ATIV=" & CStr(qtdOrfaAtivAntes) & _
        "; RESIDUOS=" & CStr(qtdResidAntes) & _
        " | LIMPOS=" & CStr(qtdLimpas) & _
        " | DEPOIS: ORFA_EMP=" & CStr(qtdOrfaEmpDepois) & _
        "; ORFA_ATIV=" & CStr(qtdOrfaAtivDepois) & _
        "; RESIDUOS=" & CStr(qtdResidDepois) & _
        " | DETALHES=" & detalhesDepois
    Exit Function

Erro:
    RepoOS_MigrarRefOrfaLegado = "ERRO_FATAL: " & Err.Description
End Function

Private Sub RepoOS_CarregarIdsValidos( _
    ByVal dict As Object, _
    ByVal nomeAba As String, _
    ByVal colunaId As Long, _
    ByVal primeiraLinha As Long _
)
    Dim ws As Worksheet
    Dim ultima As Long
    Dim linha As Long
    Dim chave As String

    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(nomeAba)
    ultima = UltimaLinhaAba(nomeAba)
    For linha = primeiraLinha To ultima
        chave = RepoOS_NormalizarChave(ws.Cells(linha, colunaId).Value)
        If chave <> "" Then
            If Not dict.Exists(chave) Then dict.Add chave, True
        End If
    Next linha

fim:
End Sub

Private Function RepoOS_NormalizarChave(ByVal valor As Variant) As String
    Dim s As String

    On Error GoTo fim

    If IsError(valor) Then GoTo fim
    s = Trim$(CStr(valor))
    If s = "" Then GoTo fim

    If Not (s Like "*[!0-9]*") Then
        RepoOS_NormalizarChave = Format$(CLng(Val(s)), "000")
    Else
        RepoOS_NormalizarChave = UCase$(s)
    End If
    Exit Function

fim:
    RepoOS_NormalizarChave = ""
End Function

Private Function RepoOS_UltimaLinhaVarredura(ByVal ws As Worksheet, ByVal colunaMax As Long) As Long
    Dim col As Long
    Dim ultima As Long
    Dim maior As Long

    maior = LINHA_DADOS - 1
    For col = 1 To colunaMax
        ultima = ws.Cells(ws.Rows.count, col).End(xlUp).row
        If ultima > maior Then maior = ultima
    Next col

    If maior < LINHA_DADOS Then
        RepoOS_UltimaLinhaVarredura = LINHA_DADOS - 1
    Else
        RepoOS_UltimaLinhaVarredura = maior
    End If
End Function

Private Function RepoOS_LinhaSemChaveComDados( _
    ByVal ws As Worksheet, _
    ByVal linha As Long, _
    ByVal colunaMax As Long _
) As Boolean
    Dim col As Long

    If Trim$(CStr(ws.Cells(linha, COL_OS_ID).Value)) <> "" Then Exit Function

    For col = 1 To colunaMax
        If Trim$(CStr(ws.Cells(linha, col).Value)) <> "" Then
            RepoOS_LinhaSemChaveComDados = True
            Exit Function
        End If
    Next col
End Function

Private Sub RepoOS_AnexarDetalhe(ByRef detalhes As String, ByVal novoDetalhe As String)
    If Len(detalhes) > 360 Then Exit Sub

    If detalhes = "" Then
        detalhes = novoDetalhe
    Else
        detalhes = detalhes & "; " & novoDetalhe
    End If
End Sub

' IdsIguais removida - usar Util_Planilha.IdsIguais (V12-CLEAN).


