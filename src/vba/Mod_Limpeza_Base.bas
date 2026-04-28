Attribute VB_Name = "Mod_Limpeza_Base"
Option Explicit

' ============================================================
' V12.0.0203 ONDA 5 — Limpeza TOTAL e idempotente da base
' (versao oficial do projeto, substitui o uso da macro
'  descartavel local-ai/vba_import/Limpa_Base_Total.bas)
' ============================================================
'
' Por que existe:
'   A rotina antiga Preencher.Limpa_Base assumia que a linha 1
'   de cada aba sempre era cabecalho. Em homologacao 28/04/2026
'   detectamos workbooks com cabecalho corrompido (linha 1
'   contendo dados — ex.: "Empresa 1 22.222.222/2222-22"),
'   e a rotina antiga deixava esses zumbis sobreviverem ao
'   reset. Esse modulo:
'
'     - Detecta heuristicamente se a linha 1 e cabecalho real
'       (palavras-chave EMP_ID, CNPJ, ID, RAZAO_SOCIAL etc.) ou
'       se e dado disfarcado.
'     - Quando e dado, apaga linha 1 tambem e reescreve o
'       cabecalho canonico a partir das listas LBT_Cabecalho*().
'     - Usa MAX(End(xlUp)) das colunas A..AT (50 colunas) para
'       evitar UsedRange "vazado" para 1.048.576 linhas.
'     - Trata AUDIT_LOG, RELATORIO e as abas _INATIVAS — nao
'       so as 5 abas operacionais.
'
' Quem chama:
'   - Preencher.Limpa_Base (wrapper, ja existente)
'   - Configuracao_Inicial.frm > Limpar_Base_Click >
'     AbrirLimparBaseSeguro (via Limpar_Base.frm com senha).
'
' O que PRESERVA (nao toca):
'   - ATIVIDADES (CNAE)
'   - CAD_SERV
'   - CONFIG
'
' Idempotencia: pode rodar N vezes seguidas, sempre deixa as
' abas operacionais com cabecalho canonico + linha 2 vazia.
'
' ============================================================
' Cabecalhos canonicos (V12.0.0203). Manter sincronizado com
' os arrays equivalentes em local-ai/vba_import/Limpa_Base_Total.bas
' (ate o dia que a descartavel for removida).
' ============================================================

Public Function LimpaBaseTotalReset(Optional ByRef relatorioOut As String) As Boolean
    Dim relatorio As String

    On Error GoTo falha

    relatorio = "LIMPEZA TOTAL DA BASE - " & Format$(Now, "yyyy-mm-dd hh:nn:ss") & vbCrLf & vbCrLf

    relatorio = relatorio & MLB_LimparAba("EMPRESAS", MLB_CabecalhoEmpresas()) & vbCrLf
    relatorio = relatorio & MLB_LimparAba("EMPRESAS_INATIVAS", MLB_CabecalhoEmpresas()) & vbCrLf
    relatorio = relatorio & MLB_LimparAba("ENTIDADE", MLB_CabecalhoEntidade()) & vbCrLf
    relatorio = relatorio & MLB_LimparAba("ENTIDADE_INATIVOS", MLB_CabecalhoEntidade()) & vbCrLf
    relatorio = relatorio & MLB_LimparAba("CREDENCIADOS", MLB_CabecalhoCredenciados()) & vbCrLf
    relatorio = relatorio & MLB_LimparAba("PRE_OS", MLB_CabecalhoPreOS()) & vbCrLf
    relatorio = relatorio & MLB_LimparAba("CAD_OS", MLB_CabecalhoCadOS()) & vbCrLf
    relatorio = relatorio & MLB_LimparAba("AUDIT_LOG", MLB_CabecalhoAudit()) & vbCrLf
    relatorio = relatorio & MLB_LimparAba("RELATORIO", Empty) & vbCrLf

    relatorio = relatorio & vbCrLf & "PRESERVADO (nao tocado):" & vbCrLf
    relatorio = relatorio & "  - ATIVIDADES (CNAE)" & vbCrLf
    relatorio = relatorio & "  - CAD_SERV" & vbCrLf
    relatorio = relatorio & "  - CONFIG" & vbCrLf

    MLB_GravarRelatorio relatorio
    relatorioOut = relatorio
    LimpaBaseTotalReset = True
    Exit Function

falha:
    relatorioOut = relatorio & vbCrLf & "ERRO FATAL: " & Err.Description & " (cod " & CStr(Err.Number) & ")"
    LimpaBaseTotalReset = False
End Function

Private Function MLB_LimparAba(ByVal nomeAba As String, ByVal cabecalhoCanonico As Variant) As String
    Dim ws As Worksheet
    Dim qtdLinhas As Long
    Dim ultimaLinha As Long
    Dim linhaInicio As Long
    Dim acao As String
    Dim col As Long
    Dim cabecalhoOk As Boolean
    Dim estavaProtegida As Boolean
    Dim senhaProt As String

    On Error GoTo falhaAba

    Set ws = Nothing
    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets(nomeAba)
    On Error GoTo falhaAba

    If ws Is Nothing Then
        MLB_LimparAba = "  " & nomeAba & ": ABA NAO ENCONTRADA (ignorada)"
        Exit Function
    End If

    ' Desproteger via util oficial do projeto.
    On Error Resume Next
    Call Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProt)
    On Error GoTo falhaAba

    ' Achar a ultima linha real combinando End(xlUp) de varias colunas
    ' (corrige UsedRange "vazado" para 1.048.576 linhas).
    ultimaLinha = 1
    For col = 1 To 50
        Dim ultColLinha As Long
        ultColLinha = 1
        On Error Resume Next
        ultColLinha = ws.Cells(ws.Rows.count, col).End(xlUp).row
        On Error GoTo falhaAba
        If ultColLinha > ultimaLinha Then ultimaLinha = ultColLinha
    Next col

    cabecalhoOk = MLB_LinhaEhCabecalho(ws)

    If cabecalhoOk Then
        linhaInicio = 2
        acao = "cabecalho preservado"
    Else
        linhaInicio = 1
        acao = "cabecalho NAO encontrado — apagado e reescrito"
    End If

    qtdLinhas = 0
    If ultimaLinha >= linhaInicio Then
        ws.Range(ws.Cells(linhaInicio, 1), ws.Cells(ultimaLinha, 50)).ClearContents
        qtdLinhas = ultimaLinha - linhaInicio + 1
    End If

    If Not cabecalhoOk And IsArray(cabecalhoCanonico) Then
        Dim i As Long
        For i = LBound(cabecalhoCanonico) To UBound(cabecalhoCanonico)
            ws.Cells(1, i + 1).Value = cabecalhoCanonico(i)
        Next i
    End If

    ' Resetar contador (Cells(1, 44) — convencao COL_CONTADOR_AR)
    On Error Resume Next
    ws.Cells(1, 44).Value = 0
    On Error GoTo falhaAba

    MLB_LimparAba = "  " & nomeAba & ": apagadas " & CStr(qtdLinhas) & _
                    " linha(s) (" & acao & "), ate linha " & CStr(ultimaLinha)

    Call Util_RestaurarProtecaoAba(ws, estavaProtegida, senhaProt)
    Exit Function

falhaAba:
    On Error Resume Next
    If Not ws Is Nothing Then Call Util_RestaurarProtecaoAba(ws, estavaProtegida, senhaProt)
    On Error GoTo 0
    MLB_LimparAba = "  " & nomeAba & ": ERRO " & CStr(Err.Number) & " - " & Err.Description
End Function

Private Function MLB_LinhaEhCabecalho(ByVal ws As Worksheet) As Boolean
    Dim a1 As String
    Dim b1 As String
    Dim u As String

    On Error GoTo falha

    a1 = Trim$(CStr(ws.Cells(1, 1).Value))
    b1 = Trim$(CStr(ws.Cells(1, 2).Value))

    If a1 = "" Then
        MLB_LinhaEhCabecalho = True
        Exit Function
    End If

    If IsNumeric(a1) Then
        MLB_LinhaEhCabecalho = False
        Exit Function
    End If

    u = UCase$(a1)
    If u = "ID" Or u = "EMP_ID" Or u = "ATIV_ID" Or u = "CRED_ID" Or _
       u = "PREOS_ID" Or u = "OS_ID" Or u = "ENT_ID" Or u = "AUDIT_ID" Or _
       u = "CNPJ" Or u = "RAZAO_SOCIAL" Or u = "NOME" Or u = "CODIGO" Or _
       u = "DT_HORA" Or u = "DATA_HORA" Then
        MLB_LinhaEhCabecalho = True
        Exit Function
    End If

    If b1 <> "" Then
        Dim ub As String
        ub = UCase$(b1)
        If ub = "CNPJ" Or ub = "RAZAO_SOCIAL" Or ub = "NOME" Or ub = "COD_ATIV_SERV" Or _
           ub = "DT_HORA" Or ub = "DATA_HORA" Or ub = "ENT_ID" Or ub = "EMP_ID" Then
            MLB_LinhaEhCabecalho = True
            Exit Function
        End If
    End If

    ' CNPJ formatado em A1 — e dado, nao cabecalho.
    If Len(a1) >= 14 And InStr(a1, ".") > 0 And InStr(a1, "/") > 0 Then
        MLB_LinhaEhCabecalho = False
        Exit Function
    End If

    ' Fallback conservador: preserva linha 1.
    MLB_LinhaEhCabecalho = True
    Exit Function

falha:
    MLB_LinhaEhCabecalho = True
End Function

Private Function MLB_CabecalhoEmpresas() As Variant
    MLB_CabecalhoEmpresas = Array( _
        "EMP_ID", "CNPJ", "RAZAO_SOCIAL", "INSCR_MUN", "RESPONSAVEL", _
        "CPF_RESP", "ENDERECO", "BAIRRO", "MUNICIPIO", "CEP", _
        "UF", "TEL_FIXO", "TEL_CEL", "EMAIL", "EXPERIENCIA", _
        "STATUS_GLOBAL", "DT_FIM_SUSP", "QTD_RECUSAS", "DT_CAD", "DT_ULT_ALT")
End Function

Private Function MLB_CabecalhoEntidade() As Variant
    MLB_CabecalhoEntidade = Array( _
        "ENT_ID", "CNPJ", "NOME", "INSCR_MUN", "ENDERECO", _
        "BAIRRO", "MUNICIPIO", "CEP", "UF", "TEL_FIXO", _
        "TEL_CEL", "EMAIL", "RESPONSAVEL", "INFO_AD", "STATUS", _
        "DT_CAD", "DT_ULT_ALT")
End Function

Private Function MLB_CabecalhoCredenciados() As Variant
    MLB_CabecalhoCredenciados = Array( _
        "CRED_ID", "COD_ATIV_SERV", "EMP_ID", "CNPJ", "RAZAO_SOCIAL", _
        "POSICAO", "ULT_OS", "DT_ULT_OS", "INATIVO_FLAG", "ATIV_ID", _
        "RECUSAS", "EXPIRACOES", "STATUS", "DT_ULT_INDICACAO", "DT_CREDENCIAMENTO")
End Function

Private Function MLB_CabecalhoPreOS() As Variant
    MLB_CabecalhoPreOS = Array( _
        "PREOS_ID", "ENT_ID", "COD_SERV", "EMP_ID", "DT_EMISSAO", _
        "DT_LIMITE", "ATIV_ID", "DT_EM_OS", "QT_EST", "VL_EST", _
        "VL_UNIT", "STATUS", "MOTIVO", "OS_ID")
End Function

Private Function MLB_CabecalhoCadOS() As Variant
    MLB_CabecalhoCadOS = Array( _
        "OS_ID", "DEMANDANTE", "COD_SERV", "EMP_ID", "EMPENHO", _
        "DT_SS", "ATIV_ID", "DT_FECHAMENTO", "DT_PREV_TERMINO", "QT_ESTIMADA", _
        "VL_UNIT", "VALOR_TOTAL", "DT_PAGTO", "QT_EXEC", "VL_EXEC", _
        "JUSTIF_DIV", "OBSERVACOES", "PRE_OS_ID", _
        "NOTA_01", "NOTA_02", "NOTA_03", "NOTA_04", "NOTA_05", _
        "NOTA_06", "NOTA_07", "NOTA_08", "NOTA_09", "NOTA_10", "MEDIA", _
        "STATUS_OS")
End Function

Private Function MLB_CabecalhoAudit() As Variant
    MLB_CabecalhoAudit = Array( _
        "AUDIT_ID", "DT_HORA", "TIPO_EVENTO", "ENTIDADE", "ID_AFETADO", _
        "ANTES", "DEPOIS", "USUARIO")
End Function

Private Sub MLB_GravarRelatorio(ByVal texto As String)
    Const SHEET_RPT As String = "RPT_LIMPEZA_TOTAL"
    Dim ws As Worksheet
    Dim linhas() As String
    Dim i As Long
    Dim estavaProtegida As Boolean
    Dim senhaProt As String

    On Error GoTo falha

    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets(SHEET_RPT)
    On Error GoTo falha
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add( _
            After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.count))
        ws.Name = SHEET_RPT
    End If

    On Error Resume Next
    Call Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProt)
    On Error GoTo falha

    ws.Cells.Clear
    linhas = Split(texto, vbCrLf)
    For i = LBound(linhas) To UBound(linhas)
        ws.Cells(i + 1, 1).Value = linhas(i)
    Next i

    On Error Resume Next
    ws.Columns("A").AutoFit
    Call Util_RestaurarProtecaoAba(ws, estavaProtegida, senhaProt)
    On Error GoTo falha
    Exit Sub

falha:
End Sub
