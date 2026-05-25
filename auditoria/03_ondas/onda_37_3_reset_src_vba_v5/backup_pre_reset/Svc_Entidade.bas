Attribute VB_Name = "Svc_Entidade"
Option Explicit

' Servicos de entidade que removem bypass direto dos forms.

Public Function ReativarEntidadePorChave( _
    ByVal ENT_ID As String, _
    ByVal cnpjLista As String, _
    Optional ByVal origem As String = "Svc_Entidade" _
) As TResult
    Dim res As TResult
    Dim wsInativas As Worksheet
    Dim wsEntidade As Worksheet
    Dim linhaDestino As Long
    Dim linhaDuplicada As Long
    Dim linhasMesmaChave As Variant
    Dim qtdLinhasMesmaChave As Long
    Dim baseLinhas As Long
    Dim linhaCopia As Long
    Dim cnpjReativ As String
    Dim idParaDup As String
    Dim idAuditoria As String
    Dim k As Long
    Dim j As Long
    Dim nDel As Long
    Dim linhasDel() As Long
    Dim tmp As Long
    Dim estProtInativas As Boolean
    Dim estProtEntidade As Boolean
    Dim senhaInativas As String
    Dim senhaEntidade As String
    Dim abaInativasPreparada As Boolean
    Dim abaEntidadePreparada As Boolean
    Dim copiou As Boolean
    Dim erroNumero As Long
    Dim erroMensagem As String

    On Error GoTo Erro

    ENT_ID = Trim$(CStr(ENT_ID))
    cnpjLista = Trim$(CStr(cnpjLista))

    If Len(ENT_ID) = 0 And Len(Util_NormalizarDocumentoChave(cnpjLista)) = 0 Then
        res.sucesso = False
        res.mensagem = "Informe ID ou CNPJ da entidade para reativar."
        ReativarEntidadePorChave = res
        Exit Function
    End If

    Set wsInativas = ThisWorkbook.Sheets(SHEET_ENTIDADE_INATIVOS)
    Set wsEntidade = ThisWorkbook.Sheets(SHEET_ENTIDADE)

    linhasMesmaChave = Util_EntidadeInativos_ColetarLinhasMesmaChave(wsInativas, LINHA_DADOS, ENT_ID, cnpjLista)
    If Not IsArray(linhasMesmaChave) Then
        res.sucesso = False
        res.mensagem = "Entidade nao encontrada em ENTIDADE_INATIVOS."
        ReativarEntidadePorChave = res
        Exit Function
    End If

    baseLinhas = LBound(linhasMesmaChave)
    qtdLinhasMesmaChave = UBound(linhasMesmaChave) - baseLinhas + 1
    If qtdLinhasMesmaChave <= 0 Then
        res.sucesso = False
        res.mensagem = "Entidade nao encontrada em ENTIDADE_INATIVOS."
        ReativarEntidadePorChave = res
        Exit Function
    End If

    If Svc_EntidadeInativasTemConflito(wsInativas, linhasMesmaChave) Then
        res.sucesso = False
        res.mensagem = "Reativacao bloqueada: existem linhas conflitantes para a mesma entidade em ENTIDADE_INATIVOS."
        ReativarEntidadePorChave = res
        Exit Function
    End If

    linhaCopia = CLng(linhasMesmaChave(baseLinhas))
    For k = baseLinhas + 1 To UBound(linhasMesmaChave)
        If CLng(linhasMesmaChave(k)) > linhaCopia Then linhaCopia = CLng(linhasMesmaChave(k))
    Next k

    cnpjReativ = Trim$(CStr(wsInativas.Cells(linhaCopia, COL_ENT_CNPJ).Value))
    idParaDup = Trim$(CStr(wsInativas.Cells(linhaCopia, COL_ENT_ID).Value))
    If Len(idParaDup) = 0 Then idParaDup = ENT_ID

    linhaDuplicada = Util_LinhaDuplicadaIdOuDocumento( _
                        wsEntidade, _
                        LINHA_DADOS, _
                        COL_ENT_ID, _
                        idParaDup, _
                        COL_ENT_CNPJ, _
                        cnpjReativ)
    If linhaDuplicada > 0 Then
        res.sucesso = False
        res.mensagem = "Reativacao bloqueada: ja existe entidade ativa com o mesmo ID ou CNPJ na linha " & CStr(linhaDuplicada) & "."
        ReativarEntidadePorChave = res
        Exit Function
    End If

    If Not Util_PrepararAbaParaEscrita(wsEntidade, estProtEntidade, senhaEntidade) Then
        res.sucesso = False
        res.mensagem = "Nao foi possivel preparar ENTIDADE para escrita."
        ReativarEntidadePorChave = res
        Exit Function
    End If
    abaEntidadePreparada = True

    linhaDestino = wsEntidade.Cells(wsEntidade.Rows.count, 1).End(xlUp).row + 1
    wsInativas.Rows(linhaCopia).Copy Destination:=wsEntidade.Cells(linhaDestino, 1)
    Application.CutCopyMode = False
    copiou = True

    Util_RestaurarProtecaoAba wsEntidade, estProtEntidade, senhaEntidade
    abaEntidadePreparada = False

    nDel = qtdLinhasMesmaChave
    ReDim linhasDel(1 To nDel)
    For k = 1 To nDel
        linhasDel(k) = CLng(linhasMesmaChave(baseLinhas + k - 1))
    Next k
    For k = 1 To nDel - 1
        For j = k + 1 To nDel
            If linhasDel(k) < linhasDel(j) Then
                tmp = linhasDel(k)
                linhasDel(k) = linhasDel(j)
                linhasDel(j) = tmp
            End If
        Next j
    Next k

    If Not Util_PrepararAbaParaEscrita(wsInativas, estProtInativas, senhaInativas) Then
        Err.Raise 1004, "ReativarEntidadePorChave", "Nao foi possivel preparar ENTIDADE_INATIVOS para escrita."
    End If
    abaInativasPreparada = True

    For k = 1 To nDel
        If Not Util_ExcluirLinhaSegura(wsInativas, linhasDel(k)) Then
            Err.Raise 1004, "ReativarEntidadePorChave", "Nao foi possivel excluir linha " & CStr(linhasDel(k)) & " em ENTIDADE_INATIVOS."
        End If
    Next k

    Util_RestaurarProtecaoAba wsInativas, estProtInativas, senhaInativas
    abaInativasPreparada = False
    copiou = False

    ClassificaEntidade

    idAuditoria = idParaDup
    If Len(idAuditoria) = 0 Then idAuditoria = cnpjReativ
    If Len(idAuditoria) = 0 Then idAuditoria = "LINHA=" & CStr(linhaDestino)

    RegistrarEvento EVT_REATIVACAO, ENT_ENTIDADE, idAuditoria, _
                    "ABA=ENTIDADE_INATIVOS; LINHAS=" & CStr(qtdLinhasMesmaChave), _
                    "ABA=ENTIDADE; LINHA=" & CStr(linhaDestino) & "; CNPJ=" & cnpjReativ, _
                    origem

    res.sucesso = True
    res.mensagem = "Entidade " & idAuditoria & " reativada."
    res.IdGerado = idAuditoria
    ReativarEntidadePorChave = res
    Exit Function

Erro:
    erroNumero = Err.Number
    erroMensagem = Err.Description
    On Error Resume Next
    If copiou Then Util_ExcluirLinhaSegura wsEntidade, linhaDestino
    If abaInativasPreparada Then Util_RestaurarProtecaoAba wsInativas, estProtInativas, senhaInativas
    If abaEntidadePreparada Then Util_RestaurarProtecaoAba wsEntidade, estProtEntidade, senhaEntidade
    Application.CutCopyMode = False
    On Error GoTo 0

    res.sucesso = False
    res.mensagem = "Erro em ReativarEntidadePorChave: " & erroMensagem
    res.CodigoErro = erroNumero
    ReativarEntidadePorChave = res
End Function

Private Function Svc_EntidadeInativasTemConflito(ByVal wsInativas As Worksheet, ByRef linhas As Variant) As Boolean
    Dim idS As Object
    Dim docs As Object
    Dim nomes As Object
    Dim i As Long
    Dim linhaAtual As Long
    Dim idAtual As String
    Dim docAtual As String
    Dim nomeAtual As String

    Set idS = CreateObject("Scripting.Dictionary")
    Set docs = CreateObject("Scripting.Dictionary")
    Set nomes = CreateObject("Scripting.Dictionary")

    If Not IsArray(linhas) Then Exit Function

    For i = LBound(linhas) To UBound(linhas)
        linhaAtual = CLng(linhas(i))
        idAtual = Svc_ChaveNormalizadaId(wsInativas.Cells(linhaAtual, COL_ENT_ID).Value)
        docAtual = Util_NormalizarDocumentoChave(wsInativas.Cells(linhaAtual, COL_ENT_CNPJ).Value)
        nomeAtual = UCase$(Trim$(CStr(wsInativas.Cells(linhaAtual, COL_ENT_NOME).Value)))

        If idAtual <> "" Then
            If Not idS.Exists(idAtual) Then idS.Add idAtual, True
        End If
        If docAtual <> "" Then
            If Not docs.Exists(docAtual) Then docs.Add docAtual, True
        End If
        If nomeAtual <> "" Then
            If Not nomes.Exists(nomeAtual) Then nomes.Add nomeAtual, True
        End If
    Next i

    Svc_EntidadeInativasTemConflito = (idS.count > 1 Or docs.count > 1 Or nomes.count > 1)
End Function

Private Function Svc_ChaveNormalizadaId(ByVal valor As Variant) As String
    Dim txt As String

    txt = Trim$(CStr(valor))
    If txt = "" Then Exit Function

    If IsNumeric(txt) Then
        Svc_ChaveNormalizadaId = CStr(CLng(Val(txt)))
    Else
        Svc_ChaveNormalizadaId = UCase$(txt)
    End If
End Function


