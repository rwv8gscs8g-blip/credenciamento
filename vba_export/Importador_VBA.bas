Attribute VB_Name = "Importador_VBA"
Option Explicit

' Importador_VBA — Importacao automatizada do pacote vba_import/
'
' Objetivo: evitar duplicidade e problemas de ordem ao importar tudo manualmente.
' Funciona lendo o arquivo 000-MANIFESTO-IMPORTACAO.txt e, para cada item:
' - remove o componente existente (se houver) pelo VB_Name do arquivo
' - importa o arquivo do disco
'
' Requisito do Excel: Central de Confianca > "Confiar no acesso ao modelo de objeto do projeto VBA"
'

Public Sub ImportarPacoteCredenciamentoV12()
    On Error GoTo falha

    Dim pastaImport As String
    Dim caminhoManifesto As String
    Dim linhas() As String
    Dim i As Long
    Dim linha As String
    Dim relPath As String
    Dim fullPath As String
    Dim vbName As String

    pastaImport = SelecionarPasta("Selecione a pasta vba_import")
    If pastaImport = "" Then Exit Sub

    If Right$(pastaImport, 1) = "\" Or Right$(pastaImport, 1) = "/" Then
        pastaImport = Left$(pastaImport, Len(pastaImport) - 1)
    End If

    caminhoManifesto = pastaImport & Application.PathSeparator & "000-MANIFESTO-IMPORTACAO.txt"
    If Not ArquivoExiste(caminhoManifesto) Then
        MsgBox "Manifesto não encontrado:" & vbCrLf & caminhoManifesto & vbCrLf & vbCrLf & _
               "Selecione a pasta vba_import correta (a que contém 000-MANIFESTO-IMPORTACAO.txt).", _
               vbCritical, "Importador V12"
        Exit Sub
    End If

    linhas = LerArquivoLinhas(caminhoManifesto)

    ' ─── PURGE DE LEGADOS ─────────────────────────────────────────────────────
    ' Remove módulos legados/fantasmas que causam "Nome repetido: TConfig".
    ' Lista ampliada v2: inclui variantes com sufixo e módulo do .fuse_hidden.
    Dim _legados As Variant
    Dim _k       As Long
    _legados = Array("AAA_Types", "AAA_Types1", "Mod_Types1", "Mod_Types2", _
                     "AppContext1", "Util_CNAE")
    For _k = LBound(_legados) To UBound(_legados)
        RemoverComponenteSeExistir CStr(_legados(_k))
    Next _k
    ' ──────────────────────────────────────────────────────────────────────────

    Application.StatusBar = "Importador V12: iniciando..."

    ' Regra de ouro: Types primeiro. Mesmo com manifesto ordenado, forçamos
    ' a importacao de Mod_Types antes de qualquer outro modulo para evitar
    ' problemas recorrentes de compilacao/ordem no VBE.
    Call ImportarLinhaManifestoSeExistir(pastaImport, linhas, "Mod_Types.bas")

    For i = LBound(linhas) To UBound(linhas)
        linha = Trim$(linhas(i))
        If linha = "" Then GoTo proxima
        If Left$(linha, 1) = "#" Then GoTo proxima
        If InStr(1, linha, "|", vbBinaryCompare) = 0 Then GoTo proxima

        relPath = Mid$(linha, 3)
        If relPath = "" Then GoTo proxima
        If InStr(1, relPath, "Mod_Types.bas", vbTextCompare) > 0 Then GoTo proxima

        fullPath = pastaImport & Application.PathSeparator & AjustarSeparadores(relPath)

        ' Ignora arquivos ocultos do SO (ex: .fuse_hidden, .DS_Store)
        Dim _nomeArqLoop As String
        _nomeArqLoop = Mid$(fullPath, InStrRev(fullPath, Application.PathSeparator) + 1)
        If Left$(_nomeArqLoop, 1) = "." Then GoTo proxima

        If Not ArquivoExiste(fullPath) Then
            Err.Raise 5, "Importador_VBA", "Arquivo do pacote não encontrado: " & fullPath
        End If

        vbName = ExtrairVBName(fullPath)
        If vbName = "" Then
            Err.Raise 5, "Importador_VBA", "Não foi possível extrair Attribute VB_Name de: " & fullPath
        End If

        Application.StatusBar = "Importador V12: " & CStr(i + 1) & "/" & CStr(UBound(linhas) + 1) & _
                                " — " & vbName

        RemoverComponenteSeExistir vbName
        ImportarComponente fullPath

proxima:
        DoEvents
    Next i

    Application.StatusBar = False
    MsgBox "Importação concluída com sucesso." & vbCrLf & _
           "Agora execute: Depurar > Compilar VBAProject.", vbInformation, "Importador V12"
    Exit Sub

falha:
    Application.StatusBar = False
    MsgBox "Falha ao importar pacote." & vbCrLf & _
           "Erro: " & CStr(Err.Number) & " - " & Err.Description, vbCritical, "Importador V12"
End Sub

Private Sub ImportarLinhaManifestoSeExistir(ByVal pastaImport As String, ByRef linhas() As String, ByVal containsPath As String)
    Dim i As Long
    Dim linha As String
    Dim relPath As String
    Dim fullPath As String
    Dim vbName As String

    For i = LBound(linhas) To UBound(linhas)
        linha = Trim$(linhas(i))
        If linha = "" Then GoTo proxima
        If Left$(linha, 1) = "#" Then GoTo proxima
        If InStr(1, linha, "|", vbBinaryCompare) = 0 Then GoTo proxima

        relPath = Mid$(linha, 3)
        If relPath = "" Then GoTo proxima
        If InStr(1, relPath, containsPath, vbTextCompare) = 0 Then GoTo proxima

        fullPath = pastaImport & Application.PathSeparator & AjustarSeparadores(relPath)

        ' Ignora arquivos ocultos do SO
        Dim _nomeArqSub As String
        _nomeArqSub = Mid$(fullPath, InStrRev(fullPath, Application.PathSeparator) + 1)
        If Left$(_nomeArqSub, 1) = "." Then GoTo proxima

        If Not ArquivoExiste(fullPath) Then
            Err.Raise 5, "Importador_VBA", "Arquivo do pacote não encontrado: " & fullPath
        End If

        vbName = ExtrairVBName(fullPath)
        If vbName = "" Then
            Err.Raise 5, "Importador_VBA", "Não foi possível extrair Attribute VB_Name de: " & fullPath
        End If

        Application.StatusBar = "Importador V12: types primeiro — " & vbName
        RemoverComponenteSeExistir vbName
        ImportarComponente fullPath
        Exit Sub

proxima:
        DoEvents
    Next i
End Sub

Private Function SelecionarPasta(ByVal titulo As String) As String
    On Error GoTo falha

    Dim fd As Object
    Set fd = Application.FileDialog(4) ' msoFileDialogFolderPicker

    fd.Title = titulo
    fd.AllowMultiSelect = False

    If fd.Show <> -1 Then
        SelecionarPasta = ""
        Exit Function
    End If

    SelecionarPasta = CStr(fd.SelectedItems(1))
    Exit Function

falha:
    SelecionarPasta = ""
End Function

Private Sub ImportarComponente(ByVal fullPath As String)
    Dim vbeObj As Object
    Dim proj As Object
    Dim comps As Object

    Set vbeObj = Application.VBE
    Set proj = vbeObj.ActiveVBProject
    Set comps = proj.VBComponents

    comps.Import fullPath
End Sub

Private Sub RemoverComponenteSeExistir(ByVal vbName As String)
    Dim vbeObj As Object
    Dim proj As Object
    Dim comp As Object

    Set vbeObj = Application.VBE
    Set proj = vbeObj.ActiveVBProject

    Set comp = EncontrarComponentePorNome(proj, vbName)
    If comp Is Nothing Then Exit Sub

    If EhComponenteDocumento(comp) Then Exit Sub

    proj.VBComponents.Remove comp
End Sub

Private Function EncontrarComponentePorNome(ByVal proj As Object, ByVal vbName As String) As Object
    Dim comp As Object

    For Each comp In proj.VBComponents
        If StrComp(CStr(comp.Name), vbName, vbTextCompare) = 0 Then
            Set EncontrarComponentePorNome = comp
            Exit Function
        End If
    Next comp

    Set EncontrarComponentePorNome = Nothing
End Function

Private Function EhComponenteDocumento(ByVal comp As Object) As Boolean
    On Error Resume Next
    ' vbext_ct_Document = 100
    EhComponenteDocumento = (CLng(comp.Type) = 100)
    On Error GoTo 0
End Function

Private Function ExtrairVBName(ByVal fullPath As String) As String
    Dim linhas() As String
    Dim i As Long
    Dim s As String
    Dim p As Long

    linhas = LerArquivoLinhas(fullPath)
    For i = LBound(linhas) To UBound(linhas)
        s = Trim$(linhas(i))
        If Left$(s, 17) = "Attribute VB_Name" Then
            p = InStr(1, s, """", vbBinaryCompare)
            If p > 0 Then
                ExtrairVBName = ExtrairEntreAspas(s)
                Exit Function
            End If
        End If
    Next i

    ExtrairVBName = ""
End Function

Private Function ExtrairEntreAspas(ByVal s As String) As String
    Dim p1 As Long
    Dim p2 As Long

    p1 = InStr(1, s, """", vbBinaryCompare)
    If p1 = 0 Then
        ExtrairEntreAspas = ""
        Exit Function
    End If

    p2 = InStr(p1 + 1, s, """", vbBinaryCompare)
    If p2 = 0 Then
        ExtrairEntreAspas = ""
        Exit Function
    End If

    ExtrairEntreAspas = Mid$(s, p1 + 1, p2 - p1 - 1)
End Function

Private Function ArquivoExiste(ByVal fullPath As String) As Boolean
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    ArquivoExiste = fso.FileExists(fullPath)
End Function

Private Function LerArquivoLinhas(ByVal fullPath As String) As String()
    Dim fso As Object
    Dim ts As Object
    Dim conteudo As String

    Set fso = CreateObject("Scripting.FileSystemObject")
    Set ts = fso.OpenTextFile(fullPath, 1, False) ' ForReading
    conteudo = ts.ReadAll
    ts.Close

    LerArquivoLinhas = Split(conteudo, vbCrLf)
End Function

Private Function AjustarSeparadores(ByVal relPath As String) As String
    Dim s As String
    s = relPath
    s = Replace$(s, "/", Application.PathSeparator)
    s = Replace$(s, "\", Application.PathSeparator)
    AjustarSeparadores = s
End Function

' ─────────────────────────────────────────────────────────────────────────────
' Verificar_SemDuplicidade — execute APÓS ImportarPacoteCredenciamentoV12
' e ANTES de Depurar > Compilar VBAProject.
' Detecta: módulos com nome duplicado (sufixo 1/2) e Public Type em dois módulos.
' ─────────────────────────────────────────────────────────────────────────────
Public Sub Verificar_SemDuplicidade()
    Dim proj      As Object
    Dim comp      As Object
    Dim dictNomes As Object
    Dim dictTypes As Object
    Dim erros     As String
    Dim nomeComp  As String
    Dim cm        As Object
    Dim i         As Long
    Dim codeLine  As String
    Dim typeName  As String

    Set proj      = Application.VBE.ActiveVBProject
    Set dictNomes = CreateObject("Scripting.Dictionary")
    Set dictTypes = CreateObject("Scripting.Dictionary")
    erros = ""

    For Each comp In proj.VBComponents
        nomeComp = comp.Name

        ' 1) Verifica nomes duplicados (sufixo 1, 2...)
        If dictNomes.Exists(nomeComp) Then
            erros = erros & "[ERRO] Modulo duplicado: " & nomeComp & vbCrLf
        Else
            dictNomes.Add nomeComp, 1
        End If

        ' 2) Varre Public Type para detectar duplicidade de definicao
        If comp.Type <> 100 Then
            Set cm = comp.CodeModule
            For i = 1 To cm.CountOfLines
                codeLine = Trim$(UCase$(cm.Lines(i, 1)))
                If Left$(codeLine, 11) = "PUBLIC TYPE" Then
                    typeName = Trim$(Mid$(codeLine, 12))
                    If dictTypes.Exists(typeName) Then
                        erros = erros & "[ERRO] Public Type '" & typeName & _
                                "' em dois modulos: " & dictTypes(typeName) & _
                                " e " & nomeComp & vbCrLf
                    Else
                        dictTypes.Add typeName, nomeComp
                    End If
                End If
            Next i
        End If
    Next comp

    If Len(erros) = 0 Then
        MsgBox "OK - Nenhuma duplicidade encontrada." & vbCrLf & _
               "Componentes: " & CStr(proj.VBComponents.Count) & vbCrLf & _
               "Public Types: " & CStr(dictTypes.Count) & vbCrLf & vbCrLf & _
               "Execute: Depurar > Compilar VBAProject", _
               vbInformation, "Verificacao OK"
    Else
        MsgBox "PROBLEMAS ENCONTRADOS:" & vbCrLf & vbCrLf & erros, _
               vbCritical, "Verificacao FALHOU"
    End If
 End Sub

' ─────────────────────────────────────────────────────────────────────────────
' Diagnostico_TConfig — varredura completa do projeto
' Lista todos os componentes e localiza TODAS as definicoes de Public Type TConfig.
' ─────────────────────────────────────────────────────────────────────────────
Public Sub Diagnostico_TConfig()
    Dim proj      As Object
    Dim comp      As Object
    Dim relat     As String
    Dim achados   As String
    Dim totalMods As Long
    Dim cm        As Object
    Dim nLinhas   As Long
    Dim j         As Long
    Dim codeLinha As String
    Dim fso       As Object
    Dim ts        As Object
    Dim logPath   As String

    Set proj = Application.VBE.ActiveVBProject
    relat = "=== DIAGNOSTICO TConfig - " & Now() & " ===" & vbCrLf & vbCrLf
    relat = relat & "Projeto: " & proj.Name & vbCrLf
    relat = relat & "Componentes:" & vbCrLf
    achados = ""

    For Each comp In proj.VBComponents
        totalMods = totalMods + 1
        relat = relat & "  [" & DiagTipoComp(comp.Type) & "] " & comp.Name & vbCrLf

        If comp.Type <> 100 Then
            Set cm = comp.CodeModule
            nLinhas = cm.CountOfLines
            For j = 1 To nLinhas
                codeLinha = Trim$(cm.Lines(j, 1))
                If InStr(1, UCase$(codeLinha), "PUBLIC TYPE TCONFIG") > 0 Then
                    achados = achados & "  *** Public Type TConfig em: " & _
                              comp.Name & " (linha " & j & ")" & vbCrLf
                End If
            Next j
        End If
    Next comp

    relat = relat & vbCrLf & "Total componentes: " & CStr(totalMods) & vbCrLf

    If Len(achados) = 0 Then
        relat = relat & vbCrLf & "[OK] Nenhuma definicao duplicada de TConfig." & vbCrLf
        relat = relat & "     Se erro persiste -> p-code corrompido -> usar planilha limpa." & vbCrLf
    Else
        relat = relat & vbCrLf & "[ERRO] Definicoes encontradas:" & vbCrLf & achados
        relat = relat & vbCrLf & "Acao: remova os modulos duplicados acima." & vbCrLf
    End If

    Set fso = CreateObject("Scripting.FileSystemObject")
    logPath = Environ("HOME") & "/Desktop/Diagnostico_TConfig.txt"
    Set ts = fso.CreateTextFile(logPath, True)
    ts.Write relat
    ts.Close

    MsgBox relat, vbInformation, "Diagnostico TConfig"
End Sub

Private Function DiagTipoComp(ByVal t As Long) As String
    Select Case t
        Case 1:   DiagTipoComp = "BAS"
        Case 2:   DiagTipoComp = "CLS"
        Case 3:   DiagTipoComp = "FRM"
        Case 100: DiagTipoComp = "DOC"
        Case Else: DiagTipoComp = "???" & t
    End Select
End Function

