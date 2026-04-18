Attribute VB_Name = "Util_Planilha"
Option Explicit

' Remove protecao de uma aba para escrita via VBA.
' Retorna True quando a aba esta pronta para escrita.
Public Function Util_PrepararAbaParaEscrita( _
    ByVal ws As Worksheet, _
    ByRef estavaProtegida As Boolean, _
    ByRef senhaUsada As String _
) As Boolean
    Dim tentativas(1 To 3) As String
    Dim i As Long

    senhaUsada = ""
    estavaProtegida = ws.ProtectContents

    If Not estavaProtegida Then
        Util_PrepararAbaParaEscrita = True
        Exit Function
    End If

    tentativas(1) = ""
    tentativas(2) = "sebrae2024"
    tentativas(3) = "SEBRAE2024"

    On Error Resume Next
    For i = LBound(tentativas) To UBound(tentativas)
        ws.Unprotect Password:=tentativas(i)
        If Not ws.ProtectContents Then
            senhaUsada = tentativas(i)
            Util_PrepararAbaParaEscrita = True
            Exit Function
        End If
    Next i
    On Error GoTo 0

    Util_PrepararAbaParaEscrita = False
End Function

' Restaura a protecao da aba apos escrita via VBA.
Public Sub Util_RestaurarProtecaoAba( _
    ByVal ws As Worksheet, _
    ByVal estavaProtegida As Boolean, _
    ByVal senhaUsada As String _
)
    If Not estavaProtegida Then Exit Sub

    On Error Resume Next
    ws.Protect Password:=senhaUsada, UserInterfaceOnly:=True
    On Error GoTo 0
End Sub

' Exclui uma linha de dados considerando tanto faixas simples quanto ListObjects.
Public Function Util_ExcluirLinhaSegura(ByVal ws As Worksheet, ByVal linha As Long) As Boolean
    Dim lo As ListObject
    Dim idxListRow As Long
    Dim ultimaColuna As Long

    If ws Is Nothing Then Exit Function
    If linha < 1 Then Exit Function

    On Error GoTo tentar_faixa
    For Each lo In ws.ListObjects
        If Not lo.DataBodyRange Is Nothing Then
            If Not Intersect(ws.Rows(linha), lo.DataBodyRange) Is Nothing Then
                idxListRow = linha - lo.DataBodyRange.row + 1
                If idxListRow >= 1 And idxListRow <= lo.ListRows.count Then
                    lo.ListRows(idxListRow).Delete
                    Util_ExcluirLinhaSegura = True
                    Exit Function
                End If
            End If
        End If
    Next lo

    ws.Rows(linha).Delete
    Util_ExcluirLinhaSegura = True
    Exit Function

tentar_faixa:
    Err.Clear
    On Error GoTo fim
    ultimaColuna = ws.Cells(1, ws.Columns.count).End(xlToLeft).Column
    If ultimaColuna < 1 Then ultimaColuna = 1
    ws.Range(ws.Cells(linha, 1), ws.Cells(linha, ultimaColuna)).Delete Shift:=xlUp
    Util_ExcluirLinhaSegura = True
    Exit Function

fim:
    Util_ExcluirLinhaSegura = False
End Function

Public Function Util_NormalizarDocumentoChave(ByVal valor As Variant) As String
    Dim s As String

    s = UCase$(Trim$(CStr(valor)))
    If s = "" Then Exit Function

    s = Replace$(s, ".", "")
    s = Replace$(s, "-", "")
    s = Replace$(s, "/", "")
    s = Replace$(s, "(", "")
    s = Replace$(s, ")", "")
    s = Replace$(s, " ", "")

    Util_NormalizarDocumentoChave = s
End Function

Public Function Util_ArquivoExiste(ByVal caminho As String) As Boolean
    Dim fso As Object

    If Trim$(caminho) = "" Then Exit Function

    On Error GoTo falha
    Set fso = CreateObject("Scripting.FileSystemObject")
    Util_ArquivoExiste = fso.FileExists(caminho)
    Exit Function

falha:
    Util_ArquivoExiste = False
End Function

Public Sub Util_LimparFiltrosAba(ByVal ws As Worksheet)
    Dim lo As ListObject

    If ws Is Nothing Then Exit Sub

    On Error Resume Next
    If ws.FilterMode Then ws.ShowAllData
    On Error GoTo 0

    On Error Resume Next
    For Each lo In ws.ListObjects
        If Not lo.AutoFilter Is Nothing Then
            If lo.AutoFilter.FilterMode Then lo.AutoFilter.ShowAllData
        End If
    Next lo
    On Error GoTo 0
End Sub

Public Function Util_LinhaDuplicadaIdOuDocumento( _
    ByVal ws As Worksheet, _
    ByVal primeiraLinha As Long, _
    ByVal colId As Long, _
    ByVal idBusca As Variant, _
    ByVal colDocumento As Long, _
    ByVal documentoBusca As Variant, _
    Optional ByVal ignorarLinha As Long = 0 _
) As Long
    Dim linhaAtual As Long
    Dim ultimaLinha As Long
    Dim docBuscaNorm As String
    Dim docAtualNorm As String

    If ws Is Nothing Then Exit Function

    ultimaLinha = UltimaLinhaAba(ws.Name)
    If ultimaLinha < primeiraLinha Then Exit Function

    docBuscaNorm = Util_NormalizarDocumentoChave(documentoBusca)

    For linhaAtual = primeiraLinha To ultimaLinha
        If linhaAtual <> ignorarLinha Then
            If IdsIguais(ws.Cells(linhaAtual, colId).Value, idBusca) Then
                Util_LinhaDuplicadaIdOuDocumento = linhaAtual
                Exit Function
            End If

            docAtualNorm = Util_NormalizarDocumentoChave(ws.Cells(linhaAtual, colDocumento).Value)
            If docBuscaNorm <> "" And docAtualNorm <> "" Then
                If StrComp(docAtualNorm, docBuscaNorm, vbTextCompare) = 0 Then
                    Util_LinhaDuplicadaIdOuDocumento = linhaAtual
                    Exit Function
                End If
            End If
        End If
    Next linhaAtual
End Function

' Todas as linhas em ENTIDADE_INATIVOS que representam a mesma entidade selecionada na lista.
' Cobre: varias linhas com o mesmo ID; linha "fantasma" com ID vazio mas mesmo CNPJ; duplicidade de inativacao.
' Requer pelo menos ID ou CNPJ na linha (ignora nome solto).
Public Function Util_EntidadeInativos_ColetarLinhasMesmaChave( _
    ByVal wsInativas As Worksheet, _
    ByVal primeiraLinha As Long, _
    ByVal idLista As String, _
    ByVal cnpjLista As String _
) As Collection
    Dim ult As Long
    Dim r As Long
    Dim cnpjNormLista As String
    Dim coll As New Collection

    If wsInativas Is Nothing Then GoTo fim

    cnpjNormLista = Util_NormalizarDocumentoChave(cnpjLista)
    ult = UltimaLinhaAba(wsInativas.Name)
    If ult < primeiraLinha Then GoTo fim

    For r = primeiraLinha To ult
        If Util_EntidadeInativos_LinhaConsideravel(wsInativas, r) Then
            If Util_EntidadeInativos_LinhaCombinaChave(wsInativas, r, idLista, cnpjNormLista) Then
                coll.Add r
            End If
        End If
    Next r

fim:
    Set Util_EntidadeInativos_ColetarLinhasMesmaChave = coll
End Function

Private Function Util_EntidadeInativos_LinhaConsideravel(ByVal ws As Worksheet, ByVal linha As Long) As Boolean
    Dim idS As String
    Dim docN As String

    idS = Trim$(CStr(ws.Cells(linha, COL_ENT_ID).Value))
    docN = Util_NormalizarDocumentoChave(ws.Cells(linha, COL_ENT_CNPJ).Value)
    Util_EntidadeInativos_LinhaConsideravel = (Len(idS) > 0 Or Len(docN) > 0)
End Function

Private Function Util_EntidadeInativos_LinhaCombinaChave( _
    ByVal ws As Worksheet, _
    ByVal linha As Long, _
    ByVal idLista As String, _
    ByVal cnpjNormLista As String _
) As Boolean
    Dim idCell As String
    Dim docLinha As String

    idCell = Trim$(CStr(ws.Cells(linha, COL_ENT_ID).Value))
    docLinha = Util_NormalizarDocumentoChave(ws.Cells(linha, COL_ENT_CNPJ).Value)

    If Len(Trim$(idLista)) > 0 And Len(idCell) > 0 Then
        If IdsIguais(idCell, idLista) Then
            Util_EntidadeInativos_LinhaCombinaChave = True
            Exit Function
        End If
    End If

    If Len(cnpjNormLista) > 0 And Len(docLinha) > 0 Then
        If StrComp(docLinha, cnpjNormLista, vbTextCompare) = 0 Then
            Util_EntidadeInativos_LinhaCombinaChave = True
            Exit Function
        End If
    End If

    Util_EntidadeInativos_LinhaCombinaChave = False
End Function

' Mesmo padrao de Util_EntidadeInativos_* para EMPRESAS_INATIVAS (Reativa_Empresa).
Public Function Util_EmpresaInativos_ColetarLinhasMesmaChave( _
    ByVal wsInativas As Worksheet, _
    ByVal primeiraLinha As Long, _
    ByVal idLista As String, _
    ByVal cnpjLista As String _
) As Collection
    Dim ult As Long
    Dim r As Long
    Dim cnpjNormLista As String
    Dim coll As New Collection

    If wsInativas Is Nothing Then GoTo fimEmp

    cnpjNormLista = Util_NormalizarDocumentoChave(cnpjLista)
    ult = UltimaLinhaAba(wsInativas.Name)
    If ult < primeiraLinha Then GoTo fimEmp

    For r = primeiraLinha To ult
        If Util_EmpresaInativos_LinhaConsideravel(wsInativas, r) Then
            If Util_EmpresaInativos_LinhaCombinaChave(wsInativas, r, idLista, cnpjNormLista) Then
                coll.Add r
            End If
        End If
    Next r

fimEmp:
    Set Util_EmpresaInativos_ColetarLinhasMesmaChave = coll
End Function

Private Function Util_EmpresaInativos_LinhaConsideravel(ByVal ws As Worksheet, ByVal linha As Long) As Boolean
    Dim idS As String
    Dim docN As String

    idS = Trim$(CStr(ws.Cells(linha, COL_EMP_ID).Value))
    docN = Util_NormalizarDocumentoChave(ws.Cells(linha, COL_EMP_CNPJ).Value)
    Util_EmpresaInativos_LinhaConsideravel = (Len(idS) > 0 Or Len(docN) > 0)
End Function

Private Function Util_EmpresaInativos_LinhaCombinaChave( _
    ByVal ws As Worksheet, _
    ByVal linha As Long, _
    ByVal idLista As String, _
    ByVal cnpjNormLista As String _
) As Boolean
    Dim idCell As String
    Dim docLinha As String

    idCell = Trim$(CStr(ws.Cells(linha, COL_EMP_ID).Value))
    docLinha = Util_NormalizarDocumentoChave(ws.Cells(linha, COL_EMP_CNPJ).Value)

    If Len(Trim$(idLista)) > 0 And Len(idCell) > 0 Then
        If IdsIguais(idCell, idLista) Then
            Util_EmpresaInativos_LinhaCombinaChave = True
            Exit Function
        End If
    End If

    If Len(cnpjNormLista) > 0 And Len(docLinha) > 0 Then
        If StrComp(docLinha, cnpjNormLista, vbTextCompare) = 0 Then
            Util_EmpresaInativos_LinhaCombinaChave = True
            Exit Function
        End If
    End If

    Util_EmpresaInativos_LinhaCombinaChave = False
End Function

' Salva o workbook com tratamento seguro de erro.
' Retorna False quando o save falhar, preenchendo mensagemErro.
Public Function Util_SalvarWorkbookSeguro(Optional ByRef mensagemErro As String = "") As Boolean
    On Error GoTo falha
    ThisWorkbook.Save
    Util_SalvarWorkbookSeguro = True
    mensagemErro = ""
    Exit Function
falha:
    Util_SalvarWorkbookSeguro = False
    mensagemErro = Err.Description
End Function

' Retorna a última linha com dados em uma coluna.
' Nome da função com sufixo \"Sheet\" para evitar conflito com
' eventuais funções locais em módulos de planilha.
Public Function UltimaLinhaSheet(ByVal nomeAba As String, Optional ByVal Coluna As Long = 1) As Long
    Dim ws As Worksheet
    
    On Error GoTo fim
    Set ws = ThisWorkbook.Sheets(nomeAba)
    UltimaLinhaSheet = ws.Cells(ws.Rows.count, Coluna).End(xlUp).row
    If UltimaLinhaSheet < 1 Then UltimaLinhaSheet = 1
    Exit Function
fim:
    UltimaLinhaSheet = 1
End Function

' Busca um valor em uma coluna e retorna o número da linha (0 se não encontrar).
Public Function BuscarLinha( _
    ByVal nomeAba As String, _
    ByVal Coluna As Long, _
    ByVal valor As Variant _
) As Long
    Dim ws As Worksheet
    Dim rng As Range
    
    On Error GoTo fim
    Set ws = ThisWorkbook.Sheets(nomeAba)
    Set rng = ws.Columns(Coluna).Find(What:=valor, LookAt:=xlWhole, LookIn:=xlValues)
    If rng Is Nothing Then
        BuscarLinha = 0
    Else
        BuscarLinha = rng.row
    End If
    Exit Function
fim:
    BuscarLinha = 0
End Function

' Lê e incrementa um contador sequencial em uma célula (ex.: AR1).
Public Function ProximoContador( _
    ByVal nomeAba As String, _
    ByVal CelulaContador As String _
) As Long
    Dim ws As Worksheet
    Dim atual As Long
    
    On Error GoTo fim
    Set ws = ThisWorkbook.Sheets(nomeAba)
    atual = Util_Conversao.ToLong(ws.Range(CelulaContador).Value)
    atual = atual + 1
    ws.Range(CelulaContador).Value = atual
    ProximoContador = atual
    Exit Function
fim:
    ProximoContador = 1
End Function

' Formata uma célula como data (sem Select/ActiveCell).
Public Sub FormatarComoData( _
    ByVal ws As Worksheet, _
    ByVal linha As Long, _
    ByVal Coluna As Long, _
    ByVal valor As Date _
)
    On Error Resume Next
    If valor > 0 Then
        ws.Cells(linha, Coluna).Value = CDbl(valor)
        ws.Cells(linha, Coluna).NumberFormat = "dd/mm/yyyy"
    Else
        ws.Cells(linha, Coluna).ClearContents
    End If
    On Error GoTo 0
End Sub

' Formata uma célula como moeda (sem Select/ActiveCell).
Public Sub FormatarComoMoeda( _
    ByVal ws As Worksheet, _
    ByVal linha As Long, _
    ByVal Coluna As Long, _
    ByVal valor As Currency _
)
    On Error Resume Next
    ws.Cells(linha, Coluna).Value = valor
    ws.Cells(linha, Coluna).NumberFormat = "_-R$ * #,##0.00_-;-R$ * #,##0.00_-;_-R$ * ""-""??_-;_-@_-"
    On Error GoTo 0
End Sub

' Protege abas críticas no Workbook_Open sem depender de módulos extras removidos.
Public Sub ProtegerAbasCriticas()
    Dim nomes As Variant
    Dim nomeAba As Variant
    Dim ws As Worksheet

    nomes = Array(SHEET_EMPRESAS, SHEET_EMPRESAS_INATIVAS, SHEET_ENTIDADE, _
                  SHEET_ENTIDADE_INATIVOS, SHEET_ATIVIDADES, SHEET_CAD_SERV, _
                  SHEET_CREDENCIADOS, SHEET_PREOS, SHEET_CAD_OS, SHEET_AUDIT)

    For Each nomeAba In nomes
        Set ws = Nothing
        If Util_TentarObterWorksheet(CStr(nomeAba), ws) Then
            On Error Resume Next
            If ws.ProtectContents Then ws.Unprotect Password:="sebrae2024"
            If ws.ProtectContents Then ws.Unprotect Password:=""
            ws.Protect Password:="sebrae2024", DrawingObjects:=True, Contents:=True, _
                       Scenarios:=True, UserInterfaceOnly:=True
            On Error GoTo 0
        End If
    Next nomeAba
End Sub

Private Function Util_TentarObterWorksheet(ByVal nomeAba As String, ByRef wsOut As Worksheet) As Boolean
    Dim ws As Worksheet

    Util_TentarObterWorksheet = False
    For Each ws In ThisWorkbook.Worksheets
        If StrComp(ws.Name, nomeAba, vbTextCompare) = 0 Then
            Set wsOut = ws
            Util_TentarObterWorksheet = True
            Exit Function
        End If
    Next ws
End Function

' ============================================================
' FUNCOES MOVIDAS DE Const_Colunas.bas (V12-CLEAN)
' ============================================================

' Detecta se aba EMPRESAS tem cabecalho na linha 1.
Public Function PrimeiraLinhaDadosEmpresas() As Long
    Dim ws As Worksheet
    Dim cabA As String
    Dim cabB As String
    Dim cabC As String

    Set ws = ThisWorkbook.Sheets(SHEET_EMPRESAS)

    cabA = UCase$(Trim$(CStr(ws.Cells(1, COL_EMP_ID).Value)))
    cabB = UCase$(Trim$(CStr(ws.Cells(1, COL_EMP_CNPJ).Value)))
    cabC = UCase$(Trim$(CStr(ws.Cells(1, COL_EMP_RAZAO).Value)))

    If cabA = "ID" Or cabA = "EMP_ID" Or cabB = "CNPJ" Or cabC = "RAZAO SOCIAL" Or cabC = "RAZAO_SOCIAL" Then
        PrimeiraLinhaDadosEmpresas = LINHA_DADOS
    Else
        PrimeiraLinhaDadosEmpresas = 1
    End If
End Function

' Retorna a ultima linha com dados em uma aba (coluna A).
Public Function UltimaLinhaAba(ByVal nomeAba As String) As Long
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets(nomeAba)
    If ws.Cells(ws.Rows.count, 1).End(xlUp).row < LINHA_DADOS Then
        UltimaLinhaAba = LINHA_DADOS - 1
    Else
        UltimaLinhaAba = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    End If
End Function

' Gera proximo ID sequencial (formato "001", "002", ...).
' Le e incrementa o contador em AR1 da aba.
Public Function ProximoId(ByVal nomeAba As String) As String
    Dim ws As Worksheet
    Dim atual As Long
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim abaPreparada As Boolean
    Dim numeroErro As Long
    Dim mensagemErro As String

    On Error GoTo falha
    Set ws = ThisWorkbook.Sheets(nomeAba)

    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        Err.Raise 1004, "ProximoId", "Nao foi possivel preparar a aba '" & nomeAba & "' para escrita."
    End If
    abaPreparada = True

    atual = CLng(Val(ws.Cells(1, COL_CONTADOR_AR).Value))
    atual = atual + 1
    ws.Cells(1, COL_CONTADOR_AR).Value = atual
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    abaPreparada = False
    ProximoId = Format$(atual, "000")
    Exit Function

falha:
    numeroErro = Err.Number
    mensagemErro = Err.Description
    On Error Resume Next
    If abaPreparada Then Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    Err.Raise numeroErro, "Util_Planilha.ProximoId", mensagemErro
End Function

' ============================================================
' FUNCAO CENTRALIZADA IdsIguais (V12-CLEAN)
' Antes duplicada em Repo_Credenciamento, Repo_PreOS, Repo_OS,
' Repo_Avaliacao, Svc_Rodizio, Svc_PreOS, Svc_OS, Preencher.
' ============================================================

' Compara dois IDs tratando numerico vs texto (ex: "001" = 1 = "1").
Public Function IdsIguais(ByVal a As Variant, ByVal b As Variant) As Boolean
    Dim sA As String
    Dim sB As String

    sA = Trim$(CStr(a))
    sB = Trim$(CStr(b))
    If sA = "" Or sB = "" Then
        IdsIguais = False
        Exit Function
    End If

    If IsNumeric(sA) And IsNumeric(sB) Then
        IdsIguais = (CLng(Val(sA)) = CLng(Val(sB)))
    Else
        IdsIguais = (StrComp(sA, sB, vbTextCompare) = 0)
    End If
End Function



