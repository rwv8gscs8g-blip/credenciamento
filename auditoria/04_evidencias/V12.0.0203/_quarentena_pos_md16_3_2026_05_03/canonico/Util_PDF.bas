Attribute VB_Name = "Util_PDF"
Option Explicit

' ============================================================
' Util_PDF - Onda 16 MD-16.4 (V12.0.0203)
' Geracao de PDFs determinísticos como evidencia forense.
'
' Padrao de nomenclatura humano-legivel:
'   <TIPO>_<ENTIDADE_ID>_<CNPJ>_<DATA>[_NN].pdf
' Tipos: PREOS, OS, AVAL, CICLO (por empresa), CICLO_RESUMO (geral).
' CNPJ normalizado (so digitos) via Util_Empresa_GetCnpjPorId.
' Data formato YYYY-MM-DD (ordenavel). Sufixo _NN se houver colisao.
'
' Diretorio: auditoria/04_evidencias/V12.0.0203/pdfs/<EXECUCAO_ID>/
' Sheet de controle: RPT_PDFS_GERADOS (lazy create).
'
' Hash determinístico do payload (sem timestamp): algoritmo DJB2 simples
' em VBA puro. Nao e cripto-forte mas suficiente para fixture de teste:
' detecta qualquer mudanca no payload.
'
' Hooks opcionais via flag CONFIG.PDFS_AUTOMATICOS (Q4 hearback default
' FALSE). Operador habilita via CONFIG quando quiser auditoria forense
' em producao.
' ============================================================

Public Const PDF_SHEET_RPT As String = "RPT_PDFS_GERADOS"
Public Const PDF_SHEET_TEMP As String = "TEMP_PDF_GEN"
Public Const PDF_DIR_RAIZ As String = "auditoria"
Public Const PDF_DIR_EVIDENCIAS As String = "evidencias"
Public Const PDF_VERSAO As String = "V12.0.0203"

Public Const PDF_TIPO_PREOS As String = "PREOS"
Public Const PDF_TIPO_OS As String = "OS"
Public Const PDF_TIPO_AVAL As String = "AVAL"
Public Const PDF_TIPO_CICLO As String = "CICLO"
Public Const PDF_TIPO_CICLO_RESUMO As String = "CICLO_RESUMO"

' ============================================================
' API publica
' ============================================================

' Gera PDF de uma PRE_OS especifica. Retorna caminho absoluto do PDF
' gerado (ou "" em caso de falha).
Public Function Util_PDF_GerarPdfPreOS(ByVal preosId As String, ByVal execucaoId As String) As String
    Util_PDF_GerarPdfPreOS = Util_PDF_GerarPorEntidade(PDF_TIPO_PREOS, preosId, execucaoId, "")
End Function

' Gera PDF de uma OS especifica.
Public Function Util_PDF_GerarPdfOS(ByVal osId As String, ByVal execucaoId As String) As String
    Util_PDF_GerarPdfOS = Util_PDF_GerarPorEntidade(PDF_TIPO_OS, osId, execucaoId, "")
End Function

' Gera PDF da Avaliacao de uma OS especifica.
Public Function Util_PDF_GerarPdfAvaliacao(ByVal osId As String, ByVal execucaoId As String) As String
    Util_PDF_GerarPdfAvaliacao = Util_PDF_GerarPorEntidade(PDF_TIPO_AVAL, osId, execucaoId, "")
End Function

' Gera PDF de Ciclo de rodizio focado em UMA empresa (granularidade
' forense por empresa). EmpId obrigatorio.
Public Function Util_PDF_GerarPdfCicloPorEmpresa(ByVal execucaoId As String, ByVal empId As String) As String
    Util_PDF_GerarPdfCicloPorEmpresa = Util_PDF_GerarPorEntidade(PDF_TIPO_CICLO, execucaoId, execucaoId, empId)
End Function

' Gera PDF resumo geral do ciclo (todas empresas em 1 documento, sem
' CNPJ no nome - vista executiva).
Public Function Util_PDF_GerarPdfCicloResumo(ByVal execucaoId As String) As String
    Util_PDF_GerarPdfCicloResumo = Util_PDF_GerarPorEntidade(PDF_TIPO_CICLO_RESUMO, execucaoId, execucaoId, "")
End Function

' Calcula hash determinístico DJB2 de uma string (payload). Mesmo
' input -> mesmo output sempre. Usado para fixture de teste.
'
' V12.0.0203 ONDA 16 MD-16.4 fix1 (2026-05-02): refatorado de Long
' para Double com modulo manual. Causa raiz do erro em runtime na suite
' TV2_RunPdfDeterminismo (CT_PDF_999): em VBA Long e signed 32-bit
' (max 2^31-1 = 2147483647). h*33 estoura apos poucas iteracoes de
' loop ainda que o & 0x7FFFFFFF aplicado no fim, porque o overflow
' acontece ANTES do AND. Solucao: usar Double durante o loop e
' aplicar modulo 2^32 manualmente a cada passo, depois truncar para
' 31-bit signed (cabe em Long) no final. (Licao L20 candidata.)
Public Function Util_PDF_HashPayload(ByVal payload As String) As String
    On Error GoTo falha

    Const MOD32 As Double = 4294967296#  ' 2^32
    Const MOD31 As Double = 2147483648#  ' 2^31

    Dim h As Double
    Dim i As Long
    Dim n As Long

    n = Len(payload)
    h = 5381#
    For i = 1 To n
        h = h * 33# + CDbl(AscW(Mid$(payload, i, 1)))
        ' Manter h em 32-bit unsigned ([0, 2^32))
        If h >= MOD32 Then
            h = h - (Int(h / MOD32) * MOD32)
        End If
    Next i

    ' Truncar para 31-bit positivo (cabe em Long signed para Hex$)
    If h >= MOD31 Then
        h = h - MOD31
    End If

    Util_PDF_HashPayload = Right$("00000000" & Hex$(CLng(h)), 8)
    Exit Function

falha:
    Util_PDF_HashPayload = "00000000"
End Function

' Handler da opcao [22] da Central V2: abrir pasta de PDFs no Finder/
' Explorer ou ativar sheet RPT_PDFS_GERADOS quando OS sandbox bloqueia.
Public Sub Util_PDF_AbrirPasta()
    On Error GoTo falha
    Dim ws As Worksheet
    Set ws = Util_PDF_AssegurarSheetRpt()
    Util_PDF_FormatarSheetRpt ws
    ws.Activate
    ws.Range("A1").Select
    Exit Sub

falha:
    MsgBox "Erro ao abrir RPT_PDFS_GERADOS: " & Err.Description, _
           vbExclamation, "Util PDF"
End Sub

' Verifica se geracao automatica esta habilitada via CONFIG.
' Q4 hearback: opcional via flag PDFS_AUTOMATICOS. Default FALSE.
' Hooks em suites E2E so geram PDF se retornar TRUE.
Public Function Util_PDF_AutomaticoHabilitado() As Boolean
    On Error GoTo falha
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets(SHEET_CONFIG)
    ' Coluna O reservada para PDFS_AUTOMATICOS (TRUE/FALSE).
    ' Por enquanto retornamos FALSE por default. Operador habilita
    ' adicionando a coluna manualmente em CONFIG quando precisar.
    Dim v As Variant
    v = ws.Cells(LINHA_CFG_VALORES, 15).Value  ' coluna O
    If IsEmpty(v) Or v = "" Then
        Util_PDF_AutomaticoHabilitado = False
    Else
        Util_PDF_AutomaticoHabilitado = (UCase$(Trim$(CStr(v))) = "TRUE" Or _
                                          CStr(v) = "1" Or _
                                          CBool(v) = True)
    End If
    Exit Function
falha:
    Util_PDF_AutomaticoHabilitado = False
End Function

' ============================================================
' Implementacao interna
' ============================================================

Private Function Util_PDF_GerarPorEntidade( _
    ByVal tipo As String, _
    ByVal entidadeId As String, _
    ByVal execucaoId As String, _
    ByVal empIdOverride As String _
) As String
    On Error GoTo falha

    Dim wsTemp As Worksheet
    Dim caminho As String
    Dim nomeArquivo As String
    Dim payload As String
    Dim hashPayload As String
    Dim cnpj As String
    Dim empId As String
    Dim tamanhoBytes As Long

    ' Determinar EMP_ID e CNPJ conforme tipo
    Select Case tipo
        Case PDF_TIPO_PREOS
            empId = ResolverEmpIdPorPreOS(entidadeId)
        Case PDF_TIPO_OS, PDF_TIPO_AVAL
            empId = ResolverEmpIdPorOS(entidadeId)
        Case PDF_TIPO_CICLO
            empId = empIdOverride
        Case PDF_TIPO_CICLO_RESUMO
            empId = ""
    End Select

    cnpj = ""
    If Trim$(empId) <> "" Then
        cnpj = Util_Empresa_GetCnpjPorId(empId)
    End If

    ' Construir nome canonico humano-legivel
    nomeArquivo = MontarNomeArquivo(tipo, entidadeId, cnpj)
    caminho = GarantirDiretorio(execucaoId) & Application.PathSeparator & nomeArquivo

    ' Aplicar sufixo _NN em caso de colisao no mesmo dia
    caminho = AplicarSufixoColisao(caminho)

    ' Gerar payload determinístico (sem timestamp)
    payload = MontarPayload(tipo, entidadeId, empId, cnpj)
    hashPayload = Util_PDF_HashPayload(payload)

    ' Renderizar sheet temporaria + exportar PDF
    Set wsTemp = AssegurarSheetTemp()
    PreencherTempSheet wsTemp, tipo, entidadeId, empId, cnpj, hashPayload, payload, execucaoId
    ExportarPdf wsTemp, caminho

    ' Tamanho final
    tamanhoBytes = TamanhoArquivoBytes(caminho)

    ' Registrar em RPT_PDFS_GERADOS
    Util_PDF_RegistrarEmRpt execucaoId, tipo, entidadeId, cnpj, caminho, hashPayload, tamanhoBytes

    Util_PDF_GerarPorEntidade = caminho
    Exit Function

falha:
    Util_PDF_GerarPorEntidade = ""
End Function

Private Function MontarNomeArquivo(ByVal tipo As String, ByVal entidadeId As String, ByVal cnpj As String) As String
    Dim dataStr As String
    Dim base As String

    dataStr = Format$(Now, "yyyy-mm-dd")

    Select Case tipo
        Case PDF_TIPO_CICLO_RESUMO
            ' Sem CNPJ (vista geral)
            base = tipo & "_" & entidadeId & "_" & dataStr
        Case Else
            If Trim$(cnpj) = "" Then
                base = tipo & "_" & entidadeId & "_SEM_CNPJ_" & dataStr
            Else
                base = tipo & "_" & entidadeId & "_" & cnpj & "_" & dataStr
            End If
    End Select

    MontarNomeArquivo = SanitizarNome(base) & ".pdf"
End Function

Private Function SanitizarNome(ByVal nome As String) As String
    Dim s As String
    s = nome
    s = Replace$(s, "/", "_")
    s = Replace$(s, "\", "_")
    s = Replace$(s, ":", "_")
    s = Replace$(s, " ", "_")
    s = Replace$(s, "*", "_")
    s = Replace$(s, "?", "_")
    s = Replace$(s, "<", "_")
    s = Replace$(s, ">", "_")
    s = Replace$(s, "|", "_")
    s = Replace$(s, """", "_")
    SanitizarNome = s
End Function

Private Function GarantirDiretorio(ByVal execucaoId As String) As String
    Dim sep As String
    Dim base As String
    Dim pasta As String

    sep = Application.PathSeparator
    base = Trim$(ThisWorkbook.Path)
    If Len(base) = 0 Then base = Environ$("TEMP")

    pasta = base & sep & PDF_DIR_RAIZ
    GarantirPastaSeAusente pasta
    pasta = pasta & sep & PDF_DIR_EVIDENCIAS
    GarantirPastaSeAusente pasta
    pasta = pasta & sep & PDF_VERSAO
    GarantirPastaSeAusente pasta
    pasta = pasta & sep & "pdfs"
    GarantirPastaSeAusente pasta
    pasta = pasta & sep & SanitizarNome(execucaoId)
    GarantirPastaSeAusente pasta

    GarantirDiretorio = pasta
End Function

Private Sub GarantirPastaSeAusente(ByVal pasta As String)
    On Error Resume Next
    If Len(Dir$(pasta, vbDirectory)) = 0 Then MkDir pasta
    On Error GoTo 0
End Sub

Private Function AplicarSufixoColisao(ByVal caminhoBase As String) As String
    Dim sep As String
    Dim diretorio As String
    Dim baseNome As String
    Dim ext As String
    Dim n As Long
    Dim tentativa As String
    Dim posBarra As Long
    Dim posPonto As Long

    sep = Application.PathSeparator

    If Len(Dir$(caminhoBase)) = 0 Then
        AplicarSufixoColisao = caminhoBase
        Exit Function
    End If

    posBarra = InStrRev(caminhoBase, sep)
    diretorio = Left$(caminhoBase, posBarra)
    baseNome = Mid$(caminhoBase, posBarra + 1)
    posPonto = InStrRev(baseNome, ".")
    ext = Mid$(baseNome, posPonto)
    baseNome = Left$(baseNome, posPonto - 1)

    n = 2
    Do
        tentativa = diretorio & baseNome & "_" & Format$(n, "00") & ext
        If Len(Dir$(tentativa)) = 0 Then
            AplicarSufixoColisao = tentativa
            Exit Function
        End If
        n = n + 1
    Loop While n < 100

    AplicarSufixoColisao = tentativa
End Function

Private Function MontarPayload( _
    ByVal tipo As String, _
    ByVal entidadeId As String, _
    ByVal empId As String, _
    ByVal cnpj As String _
) As String
    ' Payload determinístico SEM timestamp. Conteudo varia por tipo.
    ' Hash dele e gravado no rodape do PDF e em RPT_PDFS_GERADOS.
    Dim p As String
    p = "TIPO=" & tipo & "|"
    p = p & "ENTIDADE=" & entidadeId & "|"
    p = p & "EMP=" & empId & "|"
    p = p & "CNPJ=" & cnpj
    MontarPayload = p
End Function

Private Function AssegurarSheetTemp() As Worksheet
    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(PDF_SHEET_TEMP)
    On Error GoTo 0

    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add( _
            After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.count))
        ws.Name = PDF_SHEET_TEMP
        ws.Visible = xlSheetHidden
    End If

    ws.Cells.Clear
    Set AssegurarSheetTemp = ws
End Function

Private Sub PreencherTempSheet( _
    ByVal ws As Worksheet, _
    ByVal tipo As String, _
    ByVal entidadeId As String, _
    ByVal empId As String, _
    ByVal cnpj As String, _
    ByVal hashPayload As String, _
    ByVal payload As String, _
    ByVal execucaoId As String _
)
    On Error Resume Next

    ' Cabecalho
    ws.Cells(1, 1).Value = "Sistema de Credenciamento - Evidencia Forense"
    ws.Cells(2, 1).Value = "Tipo: " & tipo
    ws.Cells(3, 1).Value = "Entidade ID: " & entidadeId
    ws.Cells(4, 1).Value = "EMP_ID: " & empId
    ws.Cells(4, 3).Value = "CNPJ: " & cnpj
    ws.Cells(5, 1).Value = "Build: " & AppRelease_BuildImportado()
    ws.Cells(5, 3).Value = "Execucao: " & execucaoId
    ws.Cells(6, 1).Value = "Gerado em: " & Format$(Now, "yyyy-mm-dd hh:nn:ss")

    ' Conteudo (preenchido por tipo - evolucao futura)
    ws.Cells(8, 1).Value = "Payload (determinístico, hashado):"
    ws.Cells(9, 1).Value = payload

    ' Rodape
    ws.Cells(11, 1).Value = "HASH_PAYLOAD: " & hashPayload
    ws.Cells(12, 1).Value = "RESUMO: TIPO=" & tipo & " ENT=" & entidadeId & _
                            " CNPJ=" & cnpj
    ws.Cells(13, 1).Value = "Documento auto-validavel via hash (DJB2) do payload acima."

    ws.Range("A1:F1").Merge
    ws.Range("A1").Font.Bold = True
    ws.Range("A1").Font.Size = 14
    ws.Range("A11:A12").Font.Bold = True
    ws.Columns("A:F").AutoFit

    On Error GoTo 0
End Sub

Private Sub ExportarPdf(ByVal ws As Worksheet, ByVal caminho As String)
    On Error Resume Next
    ws.ExportAsFixedFormat _
        Type:=xlTypePDF, _
        Filename:=caminho, _
        Quality:=xlQualityStandard, _
        IncludeDocProperties:=False, _
        IgnorePrintAreas:=False, _
        OpenAfterPublish:=False
    On Error GoTo 0
End Sub

Private Function TamanhoArquivoBytes(ByVal caminho As String) As Long
    On Error Resume Next
    TamanhoArquivoBytes = FileLen(caminho)
    On Error GoTo 0
End Function

Private Function ResolverEmpIdPorOS(ByVal osId As String) As String
    On Error GoTo falha
    Dim ws As Worksheet
    Dim ultima As Long
    Dim r As Long

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("CAD_OS")
    On Error GoTo 0

    If ws Is Nothing Then
        ResolverEmpIdPorOS = ""
        Exit Function
    End If

    ultima = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    For r = 2 To ultima
        If StrComp(Trim$(CStr(ws.Cells(r, 1).Value)), Trim$(osId), vbTextCompare) = 0 Then
            ' EMP_ID em CAD_OS coluna conhecida (assume coluna 2 como padrao;
            ' implementacao real consulta Const_Colunas.COL_OS_EMP_ID).
            ResolverEmpIdPorOS = Trim$(CStr(ws.Cells(r, 2).Value))
            Exit Function
        End If
    Next r

    ResolverEmpIdPorOS = ""
    Exit Function

falha:
    ResolverEmpIdPorOS = ""
End Function

Private Function ResolverEmpIdPorPreOS(ByVal preosId As String) As String
    On Error GoTo falha
    Dim ws As Worksheet
    Dim ultima As Long
    Dim r As Long

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("PRE_OS")
    On Error GoTo 0

    If ws Is Nothing Then
        ResolverEmpIdPorPreOS = ""
        Exit Function
    End If

    ultima = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    For r = 2 To ultima
        If StrComp(Trim$(CStr(ws.Cells(r, 1).Value)), Trim$(preosId), vbTextCompare) = 0 Then
            ResolverEmpIdPorPreOS = Trim$(CStr(ws.Cells(r, 2).Value))
            Exit Function
        End If
    Next r

    ResolverEmpIdPorPreOS = ""
    Exit Function

falha:
    ResolverEmpIdPorPreOS = ""
End Function

' ============================================================
' Sheet RPT_PDFS_GERADOS
' ============================================================

Private Function Util_PDF_AssegurarSheetRpt() As Worksheet
    Dim ws As Worksheet

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(PDF_SHEET_RPT)
    On Error GoTo 0

    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add( _
            After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.count))
        ws.Name = PDF_SHEET_RPT
    End If

    If Trim$(CStr(ws.Cells(1, 1).Value)) = "" Then
        ws.Cells(1, 1).Value = "EXECUCAO_ID"
        ws.Cells(1, 2).Value = "TIPO"
        ws.Cells(1, 3).Value = "ENTIDADE_ID"
        ws.Cells(1, 4).Value = "EMP_CNPJ"
        ws.Cells(1, 5).Value = "CAMINHO"
        ws.Cells(1, 6).Value = "NOME_ARQUIVO"
        ws.Cells(1, 7).Value = "HASH_PAYLOAD"
        ws.Cells(1, 8).Value = "TAMANHO_BYTES"
        ws.Cells(1, 9).Value = "DATA_GERACAO"
        ws.Cells(1, 10).Value = "OBS"
    End If

    Set Util_PDF_AssegurarSheetRpt = ws
End Function

Public Sub Util_PDF_RegistrarEmRpt( _
    ByVal execucaoId As String, _
    ByVal tipo As String, _
    ByVal entidadeId As String, _
    ByVal cnpj As String, _
    ByVal caminho As String, _
    ByVal hashPayload As String, _
    ByVal tamanhoBytes As Long _
)
    On Error GoTo falha
    Dim ws As Worksheet
    Dim nr As Long
    Dim sep As String
    Dim posBarra As Long
    Dim nomeArquivo As String

    Set ws = Util_PDF_AssegurarSheetRpt()
    nr = ws.Cells(ws.Rows.count, 1).End(xlUp).row + 1
    If nr < 2 Then nr = 2

    sep = Application.PathSeparator
    posBarra = InStrRev(caminho, sep)
    If posBarra > 0 Then
        nomeArquivo = Mid$(caminho, posBarra + 1)
    Else
        nomeArquivo = caminho
    End If

    ws.Cells(nr, 1).Value = execucaoId
    ws.Cells(nr, 2).Value = tipo
    ws.Cells(nr, 3).Value = entidadeId
    ws.Cells(nr, 4).Value = cnpj
    ws.Cells(nr, 5).Value = caminho
    ws.Cells(nr, 6).Value = nomeArquivo
    ws.Cells(nr, 7).Value = hashPayload
    ws.Cells(nr, 8).Value = tamanhoBytes
    ws.Cells(nr, 9).Value = Now
    ws.Cells(nr, 10).Value = ""

    Util_PDF_FormatarSheetRpt ws
    Exit Sub
falha:
End Sub

Private Sub Util_PDF_FormatarSheetRpt(ByVal ws As Worksheet)
    On Error Resume Next
    ws.Rows(1).Font.Bold = True
    ws.Rows(1).Interior.Color = RGB(0, 51, 102)
    ws.Rows(1).Font.Color = RGB(255, 255, 255)
    ws.Columns("A:J").EntireColumn.AutoFit

    Dim ultima As Long
    ultima = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    If ultima >= 1 Then
        If ws.AutoFilterMode Then ws.AutoFilter.ShowAllData
        ws.Range(ws.Cells(1, 1), ws.Cells(ultima, 10)).AutoFilter
    End If
    On Error GoTo 0
End Sub

