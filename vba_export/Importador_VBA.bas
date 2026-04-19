Attribute VB_Name = "Importador_VBA"
Option Explicit

' =============================================================================
' Importador_VBA  (V2 - determinstico, auditvel, com backup)
' =============================================================================
'
' OBJETIVO
'   Importar o pacote vba_import/ de forma reproduzvel, sem provocar o erro
'   cascata "Nome repetido: TConfig" e sem deixar componentes fantasmas no
'   projeto (Mod_Types1, AppContext1, Util_CNAE, etc.).
'
' COMANDOS PUBLICOS
'   - ImportarPacoteCompleto                Importa TODOS os itens do manifesto
'                                           (mantido alias: ImportarPacoteCredenciamentoV12)
'   - ImportarIncremental(lista)            Importa somente os itens informados
'   - ImportarIncremental_Prompt            Abre InputBox para colar a lista
'   - Verificar_ModulosObrigatorios         Checa se os modulos-base do pacote
'                                           existem no projeto antes da compilacao
'   - AAA_Verificar_Estabilizacao_PosImportacao
'                                           Roda verificacao de modulos + duplicidade
'   - BackupVBAProject_Completo             Exporta TODOS os componentes (seguranca)
'   - Verificar_SemDuplicidade              Checa nomes duplicados / Public Types repetidos
'   - Diagnostico_TConfig                   Varre o projeto procurando TConfig
'
' LISTA ACEITA POR ImportarIncremental
'   Separadores validos: virgula, ponto-e-virgula, pipe, tabulacao ou CRLF.
'   Cada item pode ser:
'     (a) VB_Name puro          ex.: "Preencher"
'     (b) Arquivo do pacote     ex.: "001-modulo/AAT-Preencher.bas"
'                                    "002-formularios/AAM-Menu_Principal.frm"
'     (c) Caminho absoluto      ex.: "C:\repo\vba_import\001-modulo\AAT-Preencher.bas"
'
' ORDEM / SEGURANCA
'   - Mod_Types SEMPRE primeiro (mesmo no incremental, se estiver na lista).
'   - Componentes Document (ThisWorkbook, Sheets) NUNCA sao removidos.
'   - Antes de remover qualquer componente, e feito backup em:
'         <workbook>\backups\vba\<YYYYMMDD-HHMM>\
'     (se o workbook ainda nao foi salvo, cai em Environ("TEMP")).
'   - Purge de "fantasmas" (sufixos 1/2, modulos legados conhecidos) no inicio
'     da importacao completa; no incremental so se remove o que colide.
'
' REQUISITO DO EXCEL
'   Arquivo > Opcoes > Centro de Confiabilidade > Configuracoes
'   > Configuracoes de Macro > "Confiar no acesso ao modelo de objeto do
'   projeto VBA" (CHECAR A CAIXA).
'
' =============================================================================

Private Const MANIFESTO_NOME    As String = "000-MANIFESTO-IMPORTACAO.txt"
Private Const MOD_TYPES_VBNAME  As String = "Mod_Types"
Private Const MOD_TYPES_ARQUIVO As String = "Mod_Types.bas"
Private Const PASTA_BACKUP_REL  As String = "backups\vba"
Private Const DIAS_LIMPEZA_BACKUP As Long = 7

' vbext_ct_* (late binding)
Private Const VBEXT_CT_STDMODULE As Long = 1
Private Const VBEXT_CT_CLASSMODULE As Long = 2
Private Const VBEXT_CT_MSFORM As Long = 3
Private Const VBEXT_CT_DOCUMENT As Long = 100

' =============================================================================
' API PUBLICA
' =============================================================================

Public Sub ImportarPacoteCredenciamentoV12()
    ' Retrocompatibilidade: mantem o nome original como alias.
    ImportarPacoteCompleto
End Sub

Public Sub ImportarPacoteCompleto()
    On Error GoTo falha

    Dim pastaImport As String
    pastaImport = SelecionarPastaVBAImport()
    If Len(pastaImport) = 0 Then Exit Sub

    ExecutarImportacaoCompleta pastaImport
    Exit Sub

falha:
    Application.StatusBar = False
    MsgBox "Falha no ImportarPacoteCompleto." & vbCrLf & _
           "Erro " & CStr(Err.Number) & ": " & Err.Description, vbCritical, "Importador V12"
End Sub

Public Sub ImportarIncremental(ByVal listaVBNamesOuArquivos As String)
    On Error GoTo falha

    Dim pastaImport As String
    pastaImport = SelecionarPastaVBAImport()
    If Len(pastaImport) = 0 Then Exit Sub

    If Len(Trim$(listaVBNamesOuArquivos)) = 0 Then
        MsgBox "Lista de itens vazia. Informe VB_Names ou arquivos do pacote.", _
               vbExclamation, "Importador V12 - Incremental"
        Exit Sub
    End If

    ExecutarImportacaoIncremental pastaImport, listaVBNamesOuArquivos
    Exit Sub

falha:
    Application.StatusBar = False
    MsgBox "Falha no ImportarIncremental." & vbCrLf & _
           "Erro " & CStr(Err.Number) & ": " & Err.Description, vbCritical, "Importador V12"
End Sub

Public Sub ImportarIncremental_Prompt()
    Dim lista As String
    lista = InputBox( _
        "Informe os itens a reimportar (VB_Name ou caminho)." & vbCrLf & _
        "Separadores: virgula, ponto-e-virgula, pipe ou nova linha." & vbCrLf & vbCrLf & _
        "Exemplo:" & vbCrLf & _
        "   Preencher, Menu_Principal" & vbCrLf & _
        "   001-modulo/AAT-Preencher.bas", _
        "Importador V12 - Incremental")
    If Len(Trim$(lista)) = 0 Then Exit Sub
    ImportarIncremental lista
End Sub

' =============================================================================
' ATALHOS (AAA_) — para aparecer no topo da lista de macros
' =============================================================================

Public Sub AAA_ImportarIncremental_Entidade()
    ' Entidade: Util_Planilha (helpers ENTIDADE_INATIVOS) + filtro/fluxo + release metadata
    ' Ordem: utilitario antes dos consumidores.
    Call ImportarIncremental("Util_Planilha, Preencher, Reativa_Entidade, Menu_Principal, App_Release")
End Sub

Public Sub AAA_ImportarIncremental_Prompt()
    ' Mesmo do ImportarIncremental_Prompt, mas com prefixo AAA_ para ficar no topo.
    Call ImportarIncremental_Prompt
End Sub

Public Sub AAA_Verificar_Estabilizacao_PosImportacao()
    Call Verificar_ModulosObrigatorios
    Call Verificar_SemDuplicidade
End Sub

Public Sub BackupVBAProject_Completo()
    ' Exporta todos os VBComponents (exceto Document) em uma pasta timestamped.
    On Error GoTo falha

    Dim pastaBackup As String
    pastaBackup = ResolverPastaBackup("FULL")

    Dim proj As Object
    Set proj = Application.VBE.ActiveVBProject

    Dim comp As Object
    Dim total As Long
    Dim totalDoc As Long
    total = 0
    totalDoc = 0

    For Each comp In proj.VBComponents
        If EhComponenteDocumento(comp) Then
            ExportarDocumentParaTXT comp, pastaBackup
            totalDoc = totalDoc + 1
        Else
            ExportarComponente comp, pastaBackup
            total = total + 1
        End If
    Next comp

    GravarLog pastaBackup, _
              "Backup COMPLETO em " & FormatarAgora() & vbCrLf & _
              "Projeto: " & proj.Name & vbCrLf & _
              "Componentes exportados: " & CStr(total) & vbCrLf & _
              "Documents (snapshot .txt): " & CStr(totalDoc) & vbCrLf

    MsgBox "Backup completo gerado em:" & vbCrLf & pastaBackup, _
           vbInformation, "Importador V12 - Backup"
    Exit Sub

falha:
    MsgBox "Falha no BackupVBAProject_Completo." & vbCrLf & _
           "Erro " & CStr(Err.Number) & ": " & Err.Description, _
           vbCritical, "Importador V12"
End Sub

' =============================================================================
' ENGINES
' =============================================================================

Private Sub ExecutarImportacaoCompleta(ByVal pastaImport As String)
    Dim caminhoManifesto As String
    caminhoManifesto = pastaImport & Application.PathSeparator & MANIFESTO_NOME
    If Not ArquivoExiste(caminhoManifesto) Then
        MsgBox "Manifesto nao encontrado:" & vbCrLf & caminhoManifesto & vbCrLf & vbCrLf & _
               "Selecione a pasta vba_import (a que contem " & MANIFESTO_NOME & ").", _
               vbCritical, "Importador V12"
        Exit Sub
    End If

    Dim linhas() As String
    linhas = LerArquivoLinhas(caminhoManifesto)

    Dim pastaBackup As String
    pastaBackup = ResolverPastaBackup("COMPLETO")

    Dim logTexto As String
    logTexto = "Importacao COMPLETA em " & FormatarAgora() & vbCrLf & _
               "Pacote: " & pastaImport & vbCrLf & _
               "Backup: " & pastaBackup & vbCrLf & vbCrLf

    ' --- Fase 1: Purge de fantasmas (sufixos e legados conhecidos) ----------
    Dim purgeLog As String
    purgeLog = PurgarFantasmasConhecidos(pastaBackup)
    purgeLog = purgeLog & PurgarSufixosNumericos(pastaBackup)
    logTexto = logTexto & "== PURGE ==" & vbCrLf & purgeLog & vbCrLf

    ' --- Fase 2: Mod_Types primeiro ----------------------------------------
    Application.StatusBar = "Importador V12: Mod_Types..."
    logTexto = logTexto & "== IMPORTACAO (Mod_Types primeiro) ==" & vbCrLf
    logTexto = logTexto & ImportarLinhaQueContem(pastaImport, linhas, MOD_TYPES_ARQUIVO, pastaBackup)

    ' --- Fase 3: Demais itens do manifesto (skip Mod_Types) ----------------
    Dim i As Long
    Dim linha As String
    Dim relPath As String
    Dim fullPath As String
    Dim vbName As String
    Dim total As Long
    total = UBound(linhas) - LBound(linhas) + 1

    For i = LBound(linhas) To UBound(linhas)
        linha = Trim$(linhas(i))
        If LinhaIgnoravel(linha) Then GoTo proxima
        relPath = ExtrairRelPathDaLinha(linha)
        If Len(relPath) = 0 Then GoTo proxima
        If InStr(1, relPath, MOD_TYPES_ARQUIVO, vbTextCompare) > 0 Then GoTo proxima

        fullPath = pastaImport & Application.PathSeparator & AjustarSeparadores(relPath)
        If EhArquivoOculto(fullPath) Then GoTo proxima

        If Not ArquivoExiste(fullPath) Then
            Err.Raise 5, "Importador_VBA", "Arquivo do pacote nao encontrado: " & fullPath
        End If

        vbName = ExtrairVBName(fullPath)
        If Len(vbName) = 0 Then
            Err.Raise 5, "Importador_VBA", _
                      "Nao foi possivel extrair Attribute VB_Name de: " & fullPath
        End If

        Application.StatusBar = "Importador V12 [" & CStr(i + 1) & "/" & CStr(total) & _
                                "] " & vbName
        logTexto = logTexto & "  " & vbName & " <- " & relPath & vbCrLf
        logTexto = logTexto & SubstituirComponente(vbName, fullPath, pastaBackup)

proxima:
        DoEvents
    Next i

    Application.StatusBar = False
    GravarLog pastaBackup, logTexto

    MsgBox "Importacao completa concluida." & vbCrLf & vbCrLf & _
           "Backup/log: " & pastaBackup & vbCrLf & vbCrLf & _
           "Proximos passos:" & vbCrLf & _
           "  1. Execute: Verificar_ModulosObrigatorios" & vbCrLf & _
           "  2. Execute: Verificar_SemDuplicidade" & vbCrLf & _
           "  3. Execute: Depurar > Compilar VBAProject", _
           vbInformation, "Importador V12 - Completo"
End Sub

Private Sub ExecutarImportacaoIncremental(ByVal pastaImport As String, ByVal lista As String)
    Dim caminhoManifesto As String
    caminhoManifesto = pastaImport & Application.PathSeparator & MANIFESTO_NOME
    Dim manifestoLinhas() As String
    If ArquivoExiste(caminhoManifesto) Then
        manifestoLinhas = LerArquivoLinhas(caminhoManifesto)
    Else
        ' Sem manifesto ainda conseguimos resolver caminhos absolutos/relativos.
        ReDim manifestoLinhas(0 To 0)
        manifestoLinhas(0) = ""
    End If

    Dim itens() As String
    itens = TokenizarLista(lista)
    If (Not AlocadoArray(itens)) Or (UBound(itens) < LBound(itens)) Then
        MsgBox "Nenhum item valido na lista.", vbExclamation, "Importador V12 - Incremental"
        Exit Sub
    End If

    Dim pastaBackup As String
    pastaBackup = ResolverPastaBackup("INCREMENTAL")

    Dim logTexto As String
    logTexto = "Importacao INCREMENTAL em " & FormatarAgora() & vbCrLf & _
               "Pacote: " & pastaImport & vbCrLf & _
               "Backup: " & pastaBackup & vbCrLf & _
               "Itens solicitados: " & CStr(UBound(itens) - LBound(itens) + 1) & vbCrLf & vbCrLf

    ' --- Resolver cada item em fullPath + vbName ---------------------------
    Dim resolvidos As Collection
    Set resolvidos = New Collection

    Dim i As Long
    Dim item As String
    Dim fullPath As String
    Dim vbName As String

    For i = LBound(itens) To UBound(itens)
        item = Trim$(itens(i))
        If Len(item) = 0 Then GoTo proxItem

        fullPath = ResolverItemParaArquivo(pastaImport, manifestoLinhas, item)
        If Len(fullPath) = 0 Then
            logTexto = logTexto & "  [IGNORADO] " & item & " - arquivo nao localizado no pacote" & vbCrLf
            GoTo proxItem
        End If
        If EhArquivoOculto(fullPath) Then GoTo proxItem

        vbName = ExtrairVBName(fullPath)
        If Len(vbName) = 0 Then
            logTexto = logTexto & "  [IGNORADO] " & item & " - sem Attribute VB_Name" & vbCrLf
            GoTo proxItem
        End If

        resolvidos.Add Array(vbName, fullPath)
proxItem:
    Next i

    If resolvidos.Count = 0 Then
        GravarLog pastaBackup, logTexto & vbCrLf & "Nada a importar."
        MsgBox "Nenhum item resolvido a partir da lista." & vbCrLf & _
               "Verifique os nomes/caminhos.", vbExclamation, "Importador V12 - Incremental"
        Exit Sub
    End If

    ' --- Se Mod_Types estiver na lista, importar primeiro ------------------
    Dim indiceModTypes As Long
    indiceModTypes = IndiceModTypesNaColecao(resolvidos)

    Application.StatusBar = "Importador V12 [Incremental]..."
    logTexto = logTexto & "== IMPORTACAO ==" & vbCrLf

    If indiceModTypes > 0 Then
        Dim parTypes As Variant
        parTypes = resolvidos.Item(indiceModTypes)
        logTexto = logTexto & "  " & CStr(parTypes(0)) & " (Mod_Types primeiro)" & vbCrLf
        logTexto = logTexto & SubstituirComponente(CStr(parTypes(0)), CStr(parTypes(1)), pastaBackup)
    End If

    For i = 1 To resolvidos.Count
        If i <> indiceModTypes Then
            Dim par As Variant
            par = resolvidos.Item(i)
            logTexto = logTexto & "  " & CStr(par(0)) & vbCrLf
            logTexto = logTexto & SubstituirComponente(CStr(par(0)), CStr(par(1)), pastaBackup)
        End If
        DoEvents
    Next i

    Application.StatusBar = False
    GravarLog pastaBackup, logTexto

    MsgBox "Importacao incremental concluida (" & CStr(resolvidos.Count) & " item(ns))." & vbCrLf & vbCrLf & _
           "Backup/log: " & pastaBackup & vbCrLf & vbCrLf & _
           "Proximos passos:" & vbCrLf & _
           "  1. Execute: Verificar_ModulosObrigatorios" & vbCrLf & _
           "  2. Execute: Verificar_SemDuplicidade" & vbCrLf & _
           "  3. Execute: Depurar > Compilar VBAProject", _
           vbInformation, "Importador V12 - Incremental"
End Sub

' =============================================================================
' SUBSTITUICAO ATOMICA (backup -> remover -> importar)
' =============================================================================

Private Function SubstituirComponente(ByVal vbName As String, ByVal fullPath As String, _
                                       ByVal pastaBackup As String) As String
    Dim log As String
    log = ""

    ' Purge de sufixos relacionados a ESTE vbName (ex.: Preencher1, Preencher2).
    log = log & PurgarSufixosDeUmNome(vbName, pastaBackup)

    ' Backup + remocao do componente com o mesmo nome, se existir.
    log = log & BackupAntesDeRemover(vbName, pastaBackup)

    ' Import.
    ImportarComponente fullPath
    log = log & "    [OK] importado: " & vbName & vbCrLf

    SubstituirComponente = log
End Function

Private Function BackupAntesDeRemover(ByVal vbName As String, ByVal pastaBackup As String) As String
    Dim proj As Object
    Set proj = Application.VBE.ActiveVBProject

    Dim comp As Object
    Set comp = EncontrarComponentePorNome(proj, vbName)
    If comp Is Nothing Then
        BackupAntesDeRemover = ""
        Exit Function
    End If

    If EhComponenteDocumento(comp) Then
        BackupAntesDeRemover = "    [SKIP] Document nao removido: " & vbName & vbCrLf
        Exit Function
    End If

    ExportarComponente comp, pastaBackup
    proj.VBComponents.Remove comp
    BackupAntesDeRemover = "    [BAK] exportado+removido: " & vbName & vbCrLf
End Function

Private Function PurgarSufixosDeUmNome(ByVal vbName As String, ByVal pastaBackup As String) As String
    ' Remove componentes cujo nome eh "<vbName>1", "<vbName>2", ..., "<vbName>_BKP", etc.
    Dim proj As Object
    Set proj = Application.VBE.ActiveVBProject

    Dim log As String
    Dim comp As Object
    Dim alvo As String
    Dim acharVariantes As Collection
    Set acharVariantes = New Collection

    Dim n As Long
    For n = 1 To 9
        acharVariantes.Add vbName & CStr(n)
    Next n
    acharVariantes.Add vbName & "_BKP"
    acharVariantes.Add vbName & "_OLD"
    acharVariantes.Add vbName & "_old"

    Dim v As Variant
    For Each v In acharVariantes
        alvo = CStr(v)
        Set comp = EncontrarComponentePorNome(proj, alvo)
        If Not comp Is Nothing Then
            If Not EhComponenteDocumento(comp) Then
                ExportarComponente comp, pastaBackup
                proj.VBComponents.Remove comp
                log = log & "    [PURGE] " & alvo & " (sufixo de " & vbName & ")" & vbCrLf
            End If
        End If
    Next v

    PurgarSufixosDeUmNome = log
End Function

Private Function PurgarFantasmasConhecidos(ByVal pastaBackup As String) As String
    ' Lista curada de legados que podem sobreviver entre versoes do projeto.
    Dim proj As Object
    Set proj = Application.VBE.ActiveVBProject

    Dim legados As Variant
    legados = Array( _
        "AAA_Types", "AAA_Types1", _
        "Mod_Types1", "Mod_Types2", _
        "AppContext1", "AppContext2", _
        "Mod_AppContext", _
        "Util_CNAE", "Util_CNAE1", _
        "Importador_VBA1" _
    )

    Dim log As String
    Dim i As Long
    Dim alvo As String
    Dim comp As Object

    For i = LBound(legados) To UBound(legados)
        alvo = CStr(legados(i))
        Set comp = EncontrarComponentePorNome(proj, alvo)
        If Not comp Is Nothing Then
            If Not EhComponenteDocumento(comp) Then
                ExportarComponente comp, pastaBackup
                proj.VBComponents.Remove comp
                log = log & "    [PURGE-legado] " & alvo & vbCrLf
            End If
        End If
    Next i

    PurgarFantasmasConhecidos = log
End Function

Private Function PurgarSufixosNumericos(ByVal pastaBackup As String) As String
    ' Varre o projeto procurando nomes terminados em 1..9 cuja "raiz" (nome
    ' sem o digito final) tambem existe. Esses sao fantasmas criados pelo VBE
    ' em re-imports com nome colidindo.
    Dim proj As Object
    Set proj = Application.VBE.ActiveVBProject

    Dim nomes As Object
    Set nomes = CreateObject("Scripting.Dictionary")

    Dim comp As Object
    For Each comp In proj.VBComponents
        nomes(comp.Name) = True
    Next comp

    Dim log As String
    Dim nome As String
    Dim ultimo As String
    Dim raiz As String

    ' Precisa copiar a lista porque vamos mexer na colecao.
    Dim listaNomes As Variant
    listaNomes = nomes.Keys

    Dim i As Long
    For i = LBound(listaNomes) To UBound(listaNomes)
        nome = CStr(listaNomes(i))
        If Len(nome) < 2 Then GoTo prox
        ultimo = Right$(nome, 1)
        If ultimo < "1" Or ultimo > "9" Then GoTo prox
        raiz = Left$(nome, Len(nome) - 1)
        If Len(raiz) = 0 Then GoTo prox
        If Not nomes.Exists(raiz) Then GoTo prox

        Set comp = EncontrarComponentePorNome(proj, nome)
        If comp Is Nothing Then GoTo prox
        If EhComponenteDocumento(comp) Then GoTo prox

        ExportarComponente comp, pastaBackup
        proj.VBComponents.Remove comp
        log = log & "    [PURGE-sufixo] " & nome & " (raiz=" & raiz & ")" & vbCrLf
prox:
    Next i

    PurgarSufixosNumericos = log
End Function

' =============================================================================
' RESOLUCAO DE ITENS (VB_Name, caminho relativo, caminho absoluto)
' =============================================================================

Private Function ResolverItemParaArquivo(ByVal pastaImport As String, _
                                          ByRef manifesto() As String, _
                                          ByVal item As String) As String
    Dim s As String
    s = Trim$(item)

    If Len(s) = 0 Then
        ResolverItemParaArquivo = ""
        Exit Function
    End If

    ' Caminho absoluto (tem ":" no windows ou comeca com "/").
    If CaminhoEhAbsoluto(s) Then
        If ArquivoExiste(s) Then ResolverItemParaArquivo = s Else ResolverItemParaArquivo = ""
        Exit Function
    End If

    ' Caminho relativo (contem separador OU termina em extensao conhecida).
    If ContemSeparador(s) Or TerminaExtensaoComponente(s) Then
        Dim p As String
        p = pastaImport & Application.PathSeparator & AjustarSeparadores(s)
        If ArquivoExiste(p) Then
            ResolverItemParaArquivo = p
            Exit Function
        End If
        ' Tenta casar pelo final do caminho relativo contra o manifesto.
        ResolverItemParaArquivo = ResolverPeloManifesto(pastaImport, manifesto, s)
        Exit Function
    End If

    ' VB_Name puro: procura no manifesto linha cujo arquivo seja "*-<nome>.bas"
    ' ou "*-<nome>.frm" (ou <nome>.bas/<nome>.frm para pacotes sem prefixo).
    ResolverItemParaArquivo = ResolverVBNameNoManifesto(pastaImport, manifesto, s)
End Function

Private Function ResolverVBNameNoManifesto(ByVal pastaImport As String, _
                                            ByRef manifesto() As String, _
                                            ByVal vbName As String) As String
    Dim i As Long
    Dim linha As String
    Dim relPath As String
    Dim nomeArq As String
    Dim semExt As String

    For i = LBound(manifesto) To UBound(manifesto)
        linha = Trim$(manifesto(i))
        If LinhaIgnoravel(linha) Then GoTo prox
        relPath = ExtrairRelPathDaLinha(linha)
        If Len(relPath) = 0 Then GoTo prox

        nomeArq = UltimoSegmento(relPath)                 ' ex.: AAT-Preencher.bas
        semExt = RemoverExtensao(nomeArq)                  ' ex.: AAT-Preencher
        Dim radical As String
        radical = RadicalAposPrefixo(semExt)               ' ex.: Preencher

        If StrComp(radical, vbName, vbTextCompare) = 0 Or _
           StrComp(semExt, vbName, vbTextCompare) = 0 Then
            ResolverVBNameNoManifesto = pastaImport & Application.PathSeparator & _
                                         AjustarSeparadores(relPath)
            Exit Function
        End If
prox:
    Next i

    ResolverVBNameNoManifesto = ""
End Function

Private Function ResolverPeloManifesto(ByVal pastaImport As String, _
                                        ByRef manifesto() As String, _
                                        ByVal relativoParcial As String) As String
    Dim alvo As String
    alvo = Replace$(Replace$(relativoParcial, "\", "/"), "//", "/")

    Dim i As Long
    Dim linha As String
    Dim relPath As String
    Dim rel As String

    For i = LBound(manifesto) To UBound(manifesto)
        linha = Trim$(manifesto(i))
        If LinhaIgnoravel(linha) Then GoTo prox
        relPath = ExtrairRelPathDaLinha(linha)
        If Len(relPath) = 0 Then GoTo prox
        rel = Replace$(relPath, "\", "/")
        If StrComp(Right$(rel, Len(alvo)), alvo, vbTextCompare) = 0 Then
            ResolverPeloManifesto = pastaImport & Application.PathSeparator & _
                                    AjustarSeparadores(relPath)
            Exit Function
        End If
prox:
    Next i

    ResolverPeloManifesto = ""
End Function

Private Function ImportarLinhaQueContem(ByVal pastaImport As String, _
                                         ByRef linhas() As String, _
                                         ByVal contains As String, _
                                         ByVal pastaBackup As String) As String
    Dim i As Long
    Dim linha As String
    Dim relPath As String
    Dim fullPath As String
    Dim vbName As String

    For i = LBound(linhas) To UBound(linhas)
        linha = Trim$(linhas(i))
        If LinhaIgnoravel(linha) Then GoTo prox
        relPath = ExtrairRelPathDaLinha(linha)
        If Len(relPath) = 0 Then GoTo prox
        If InStr(1, relPath, contains, vbTextCompare) = 0 Then GoTo prox

        fullPath = pastaImport & Application.PathSeparator & AjustarSeparadores(relPath)
        If EhArquivoOculto(fullPath) Then GoTo prox
        If Not ArquivoExiste(fullPath) Then
            Err.Raise 5, "Importador_VBA", "Arquivo esperado ausente: " & fullPath
        End If

        vbName = ExtrairVBName(fullPath)
        If Len(vbName) = 0 Then
            Err.Raise 5, "Importador_VBA", "Sem Attribute VB_Name: " & fullPath
        End If

        ImportarLinhaQueContem = "  " & vbName & " <- " & relPath & vbCrLf & _
                                  SubstituirComponente(vbName, fullPath, pastaBackup)
        Exit Function
prox:
    Next i

    ImportarLinhaQueContem = "  [WARN] Nao achei linha contendo '" & contains & "'" & vbCrLf
End Function

' =============================================================================
' Verificar_SemDuplicidade e Diagnostico_TConfig
' =============================================================================

Public Sub Verificar_ModulosObrigatorios()
    Dim proj As Object
    Dim presentes As Object
    Dim esperados As Variant
    Dim i As Long
    Dim faltando As String
    Dim nome As String

    Set proj = Application.VBE.ActiveVBProject
    Set presentes = CreateObject("Scripting.Dictionary")
    esperados = ListaVBNamesObrigatorios()

    Dim comp As Object
    For Each comp In proj.VBComponents
        presentes(comp.Name) = True
    Next comp

    For i = LBound(esperados) To UBound(esperados)
        nome = CStr(esperados(i))
        If Not presentes.Exists(nome) Then
            faltando = faltando & " - " & nome & vbCrLf
        End If
    Next i

    If Len(faltando) = 0 Then
        MsgBox "OK: todos os modulos obrigatorios do pacote estao presentes." & vbCrLf & _
               "Agora execute Verificar_SemDuplicidade e depois compile.", _
               vbInformation, "Importador V12 - Estrutura OK"
    Else
        MsgBox "MODULOS OBRIGATORIOS AUSENTES:" & vbCrLf & vbCrLf & _
               faltando & vbCrLf & _
               "Importe os modulos faltantes antes de compilar." & vbCrLf & _
               "Exemplo: Repo_Avaliacao ausente causa erro em Svc_Avaliacao.", _
               vbCritical, "Importador V12 - Estrutura incompleta"
    End If
End Sub

Public Sub Verificar_SemDuplicidade()
    Dim proj As Object
    Set proj = Application.VBE.ActiveVBProject

    Dim dictNomes As Object
    Set dictNomes = CreateObject("Scripting.Dictionary")
    Dim dictTypes As Object
    Set dictTypes = CreateObject("Scripting.Dictionary")
    Dim dictSufixos As Object
    Set dictSufixos = CreateObject("Scripting.Dictionary")

    Dim erros As String
    erros = ""

    Dim comp As Object
    Dim nomeComp As String
    Dim ultimo As String
    Dim raiz As String

    For Each comp In proj.VBComponents
        nomeComp = comp.Name

        ' 1) Nomes duplicados (o VBE nunca permite 2 nomes iguais, mas
        '    permite "X" + "X1" + "X2" como diferentes componentes).
        If dictNomes.Exists(nomeComp) Then
            erros = erros & "[ERRO] Nome duplicado: " & nomeComp & vbCrLf
        Else
            dictNomes.Add nomeComp, 1
        End If

        ' 2) Fantasmas com sufixo numerico cuja raiz tambem existe.
        '    IMPORTANTE: ignorar VBEXT_CT_DOCUMENT (Planilhas/ThisWorkbook),
        '    pois codenames como Planilha2 vs Planilha20 sao normais e NAO sao fantasmas.
        If comp.Type <> VBEXT_CT_DOCUMENT Then
            If Len(nomeComp) >= 2 Then
                ultimo = Right$(nomeComp, 1)
                If ultimo >= "1" And ultimo <= "9" Then
                    raiz = Left$(nomeComp, Len(nomeComp) - 1)
                    dictSufixos(nomeComp) = raiz
                End If
            End If
        End If

        ' 3) Public Type definidos em mais de um modulo.
        If comp.Type <> VBEXT_CT_DOCUMENT Then
            Dim cm As Object
            Set cm = comp.CodeModule
            Dim i As Long
            Dim codeLine As String
            Dim typeName As String
            For i = 1 To cm.CountOfLines
                codeLine = Trim$(UCase$(cm.Lines(i, 1)))
                If Left$(codeLine, 11) = "PUBLIC TYPE" Then
                    typeName = Trim$(Mid$(codeLine, 12))
                    If dictTypes.Exists(typeName) Then
                        erros = erros & "[ERRO] Public Type '" & typeName & _
                                "' em 2 modulos: " & dictTypes(typeName) & _
                                " e " & nomeComp & vbCrLf
                    Else
                        dictTypes.Add typeName, nomeComp
                    End If
                End If
            Next i
        End If
    Next comp

    ' Cross-check de sufixos vs raizes.
    Dim chave As Variant
    For Each chave In dictSufixos.Keys
        Dim raizDetectada As String
        raizDetectada = CStr(dictSufixos(chave))
        If dictNomes.Exists(raizDetectada) Then
            erros = erros & "[ERRO] Fantasma: " & chave & _
                    " (convive com raiz " & raizDetectada & ")" & vbCrLf
        End If
    Next chave

    If Len(erros) = 0 Then
        MsgBox "OK: Nenhuma duplicidade encontrada." & vbCrLf & _
               "Componentes: " & CStr(proj.VBComponents.Count) & vbCrLf & _
               "Public Types: " & CStr(dictTypes.Count) & vbCrLf & vbCrLf & _
               "Execute: Depurar > Compilar VBAProject", _
               vbInformation, "Verificacao OK"
    Else
        MsgBox "PROBLEMAS ENCONTRADOS:" & vbCrLf & vbCrLf & erros & vbCrLf & _
               "Use ImportarIncremental(<nome-afetado>) ou BackupVBAProject_Completo" & _
               " para resolver.", vbCritical, "Verificacao FALHOU"
    End If
End Sub

Private Function ListaVBNamesObrigatorios() As Variant
    Dim itens(0 To 32) As String

    itens(0) = "Mod_Types"
    itens(1) = "Const_Colunas"
    itens(2) = "Util_Conversao"
    itens(3) = "Util_Config"
    itens(4) = "Util_Planilha"
    itens(5) = "Funcoes"
    itens(6) = "Audit_Log"
    itens(7) = "AppContext"
    itens(8) = "ErrorBoundary"
    itens(9) = "Svc_Transacao"
    itens(10) = "Repo_Credenciamento"
    itens(11) = "Repo_PreOS"
    itens(12) = "Repo_OS"
    itens(13) = "Repo_Avaliacao"
    itens(14) = "Repo_Empresa"
    itens(15) = "Svc_Rodizio"
    itens(16) = "Svc_PreOS"
    itens(17) = "Svc_OS"
    itens(18) = "Svc_Avaliacao"
    itens(19) = "Classificar"
    itens(20) = "Preencher"
    itens(21) = "Variaveis"
    itens(22) = "Emergencia_CNAE"
    itens(23) = "App_Release"
    itens(24) = "Auto_Open"
    itens(25) = "Central_Testes"
    itens(26) = "Teste_Bateria_Oficial"
    itens(27) = "Central_Testes_Relatorio"
    itens(28) = "Treinamento_Painel"
    itens(29) = "Teste_UI_Guiado"
    itens(30) = "Central_Testes_V2"
    itens(31) = "Teste_V2_Engine"
    itens(32) = "Teste_V2_Roteiros"

    ListaVBNamesObrigatorios = itens
End Function

Public Sub Diagnostico_TConfig()
    Dim proj As Object
    Set proj = Application.VBE.ActiveVBProject

    Dim relat As String
    Dim achados As String
    Dim totalMods As Long
    relat = "=== DIAGNOSTICO TConfig - " & FormatarAgora() & " ===" & vbCrLf & _
            "Projeto: " & proj.Name & vbCrLf & vbCrLf & _
            "Componentes:" & vbCrLf

    Dim comp As Object
    Dim cm As Object
    Dim nLinhas As Long
    Dim j As Long
    Dim codeLinha As String

    For Each comp In proj.VBComponents
        totalMods = totalMods + 1
        relat = relat & "  [" & DiagTipoComp(comp.Type) & "] " & comp.Name & vbCrLf
        If comp.Type <> VBEXT_CT_DOCUMENT Then
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
        relat = relat & vbCrLf & "[OK] Nenhuma definicao duplicada de TConfig." & vbCrLf & _
                "     Se o erro persiste, e cascata (p-code corrompido)." & vbCrLf & _
                "     Acao sugerida: use planilha limpa + ImportarPacoteCompleto." & vbCrLf
    Else
        relat = relat & vbCrLf & "[ERRO] Definicoes encontradas:" & vbCrLf & achados & vbCrLf & _
                "Acao: ImportarIncremental(""Mod_Types"") + remover os duplicados acima." & vbCrLf
    End If

    ' Salva relatorio em <backups>/vba/diag-YYYYMMDD-HHMM.txt
    Dim pasta As String
    pasta = ResolverPastaBackup("DIAG")
    GravarTextoParaArquivo pasta & Application.PathSeparator & "diagnostico_tconfig.txt", relat

    MsgBox relat & vbCrLf & "Relatorio salvo em: " & pasta, vbInformation, "Diagnostico TConfig"
End Sub

' =============================================================================
' HELPERS: VBE / Componentes
' =============================================================================

Private Sub ImportarComponente(ByVal fullPath As String)
    Dim proj As Object
    Set proj = Application.VBE.ActiveVBProject
    proj.VBComponents.Import fullPath
End Sub

Private Sub ExportarComponente(ByVal comp As Object, ByVal pastaBackup As String)
    GarantirPasta pastaBackup
    Dim ext As String
    Select Case comp.Type
        Case VBEXT_CT_STDMODULE:   ext = ".bas"
        Case VBEXT_CT_CLASSMODULE: ext = ".cls"
        Case VBEXT_CT_MSFORM:      ext = ".frm"
        Case Else:                 ext = ".txt"
    End Select
    Dim destino As String
    destino = pastaBackup & Application.PathSeparator & comp.Name & ext
    On Error Resume Next
    comp.Export destino
    On Error GoTo 0
End Sub

Private Sub ExportarDocumentParaTXT(ByVal comp As Object, ByVal pastaBackup As String)
    ' Document components nao podem ser removidos, mas podem ter codigo.
    ' Gravamos o CodeModule como .txt para auditoria.
    On Error Resume Next
    GarantirPasta pastaBackup
    Dim cm As Object
    Set cm = comp.CodeModule
    Dim total As Long
    total = cm.CountOfLines
    If total = 0 Then Exit Sub
    Dim conteudo As String
    conteudo = cm.Lines(1, total)
    GravarTextoParaArquivo pastaBackup & Application.PathSeparator & _
                           "_DOC_" & comp.Name & ".code.txt", conteudo
    On Error GoTo 0
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
    EhComponenteDocumento = (CLng(comp.Type) = VBEXT_CT_DOCUMENT)
    On Error GoTo 0
End Function

Private Function DiagTipoComp(ByVal t As Long) As String
    Select Case t
        Case VBEXT_CT_STDMODULE:   DiagTipoComp = "BAS"
        Case VBEXT_CT_CLASSMODULE: DiagTipoComp = "CLS"
        Case VBEXT_CT_MSFORM:      DiagTipoComp = "FRM"
        Case VBEXT_CT_DOCUMENT:    DiagTipoComp = "DOC"
        Case Else:                 DiagTipoComp = "??" & CStr(t)
    End Select
End Function

Private Function IndiceModTypesNaColecao(ByVal col As Collection) As Long
    Dim i As Long
    For i = 1 To col.Count
        Dim par As Variant
        par = col.Item(i)
        If StrComp(CStr(par(0)), MOD_TYPES_VBNAME, vbTextCompare) = 0 Then
            IndiceModTypesNaColecao = i
            Exit Function
        End If
    Next i
    IndiceModTypesNaColecao = 0
End Function

' =============================================================================
' HELPERS: Manifesto / Lista
' =============================================================================

Private Function LinhaIgnoravel(ByVal linha As String) As Boolean
    If Len(linha) = 0 Then
        LinhaIgnoravel = True
        Exit Function
    End If
    If Left$(linha, 1) = "#" Then
        LinhaIgnoravel = True
        Exit Function
    End If
    If InStr(1, linha, "|", vbBinaryCompare) = 0 Then
        LinhaIgnoravel = True
        Exit Function
    End If
    LinhaIgnoravel = False
End Function

Private Function ExtrairRelPathDaLinha(ByVal linha As String) As String
    ' Formato esperado: "M|001-modulo/xxx.bas" ou "F|002-formularios/xxx.frm"
    Dim p As Long
    p = InStr(1, linha, "|", vbBinaryCompare)
    If p = 0 Then
        ExtrairRelPathDaLinha = ""
        Exit Function
    End If
    ExtrairRelPathDaLinha = Trim$(Mid$(linha, p + 1))
End Function

Private Function TokenizarLista(ByVal s As String) As String()
    ' Aceita virgula, ponto-e-virgula, pipe, tab, LF e CRLF.
    Dim tmp As String
    tmp = s
    tmp = Replace$(tmp, vbCrLf, vbLf)
    tmp = Replace$(tmp, vbCr, vbLf)
    tmp = Replace$(tmp, vbTab, vbLf)
    tmp = Replace$(tmp, ",", vbLf)
    tmp = Replace$(tmp, ";", vbLf)
    tmp = Replace$(tmp, "|", vbLf)

    Dim partes() As String
    partes = Split(tmp, vbLf)

    ' Remove vazios.
    Dim out() As String
    ReDim out(0 To UBound(partes))
    Dim i As Long
    Dim n As Long
    n = 0
    For i = LBound(partes) To UBound(partes)
        If Len(Trim$(partes(i))) > 0 Then
            out(n) = Trim$(partes(i))
            n = n + 1
        End If
    Next i

    If n = 0 Then
        ReDim out(0 To -1)
    Else
        ReDim Preserve out(0 To n - 1)
    End If
    TokenizarLista = out
End Function

Private Function CaminhoEhAbsoluto(ByVal s As String) As Boolean
    If Len(s) = 0 Then Exit Function
    If Left$(s, 1) = "/" Or Left$(s, 1) = "\" Then
        CaminhoEhAbsoluto = True
        Exit Function
    End If
    ' Windows drive letter
    If Len(s) >= 3 Then
        If Mid$(s, 2, 1) = ":" And (Mid$(s, 3, 1) = "\" Or Mid$(s, 3, 1) = "/") Then
            CaminhoEhAbsoluto = True
        End If
    End If
End Function

Private Function ContemSeparador(ByVal s As String) As Boolean
    ContemSeparador = (InStr(1, s, "/", vbBinaryCompare) > 0) Or _
                      (InStr(1, s, "\", vbBinaryCompare) > 0)
End Function

Private Function TerminaExtensaoComponente(ByVal s As String) As Boolean
    Dim up As String
    up = UCase$(s)
    TerminaExtensaoComponente = (Right$(up, 4) = ".BAS") Or _
                                (Right$(up, 4) = ".FRM") Or _
                                (Right$(up, 4) = ".CLS")
End Function

Private Function UltimoSegmento(ByVal relPath As String) As String
    Dim s As String
    s = Replace$(relPath, "\", "/")
    Dim p As Long
    p = InStrRev(s, "/")
    If p = 0 Then
        UltimoSegmento = s
    Else
        UltimoSegmento = Mid$(s, p + 1)
    End If
End Function

Private Function RemoverExtensao(ByVal nome As String) As String
    Dim p As Long
    p = InStrRev(nome, ".")
    If p = 0 Then
        RemoverExtensao = nome
    Else
        RemoverExtensao = Left$(nome, p - 1)
    End If
End Function

Private Function RadicalAposPrefixo(ByVal semExt As String) As String
    ' Ex.: "AAT-Preencher" -> "Preencher"; "Preencher" -> "Preencher".
    Dim p As Long
    p = InStr(1, semExt, "-", vbBinaryCompare)
    If p = 0 Then
        RadicalAposPrefixo = semExt
    Else
        RadicalAposPrefixo = Mid$(semExt, p + 1)
    End If
End Function

Private Function AlocadoArray(ByRef arr() As String) As Boolean
    On Error Resume Next
    Dim dummy As Long
    dummy = UBound(arr)
    AlocadoArray = (Err.Number = 0)
    Err.Clear
    On Error GoTo 0
End Function

' =============================================================================
' HELPERS: FSO / Arquivos / Log
' =============================================================================

Private Function ResolverPastaBackup(ByVal tag As String) As String
    Dim baseRaiz As String
    If Len(ThisWorkbook.Path) > 0 Then
        baseRaiz = ThisWorkbook.Path
    Else
        baseRaiz = Environ$("TEMP")
    End If

    ' Em caminhos de rede (UNC), criar pasta pode falhar com Erro 76.
    ' Para manter o importador utilizavel, usa TEMP como fallback deterministico.
    If Left$(baseRaiz, 2) = "\\" Then baseRaiz = Environ$("TEMP")

    ' Limpeza automatica: remove backups antigos (evita acumulo indefinido).
    LimparBackupsAntigos baseRaiz, DIAS_LIMPEZA_BACKUP

    Dim pasta As String
    pasta = baseRaiz & Application.PathSeparator & PASTA_BACKUP_REL & _
            Application.PathSeparator & Format$(Now(), "yyyymmdd-hhnn") & _
            "-" & tag
    GarantirPasta pasta
    ResolverPastaBackup = pasta
End Function

Private Sub LimparBackupsAntigos(ByVal baseRaiz As String, ByVal dias As Long)
    On Error GoTo sair

    If dias <= 0 Then GoTo sair
    If Len(Trim$(baseRaiz)) = 0 Then GoTo sair

    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")

    Dim raizBackups As String
    raizBackups = Replace$(baseRaiz, "/", Application.PathSeparator)
    raizBackups = raizBackups & Application.PathSeparator & PASTA_BACKUP_REL
    raizBackups = Replace$(raizBackups, "/", Application.PathSeparator)

    If Not fso.FolderExists(raizBackups) Then GoTo sair

    Dim limite As Date
    limite = DateAdd("d", -dias, Now())

    Dim folderRaiz As Object
    Set folderRaiz = fso.GetFolder(raizBackups)

    Dim subPasta As Object
    For Each subPasta In folderRaiz.SubFolders
        If subPasta.DateLastModified < limite Then
            On Error Resume Next
            fso.DeleteFolder subPasta.Path, True
            On Error GoTo sair
        End If
    Next subPasta

sair:
End Sub

Private Sub GarantirPasta(ByVal pasta As String)
    ' Cria a arvore de pastas com FSO (nao usar MkDir nativo).
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    If fso.FolderExists(pasta) Then Exit Sub

    ' Implementacao robusta: cria o pai recursivamente e depois cria a pasta.
    ' Evita bugs com drive root (C:\) e caminhos UNC (\\server\share\...).
    Dim alvo As String
    Dim pai As String
    alvo = Replace$(pasta, "/", Application.PathSeparator)

    pai = fso.GetParentFolderName(alvo)
    If Len(pai) > 0 Then
        If Not fso.FolderExists(pai) Then
            ' GetParentFolderName pode devolver "C:" (sem barra). Normaliza para "C:\".
            If Right$(pai, 1) = ":" Then pai = pai & Application.PathSeparator
            If Not fso.FolderExists(pai) Then GarantirPasta pai
        End If
    End If

    If Not fso.FolderExists(alvo) Then fso.CreateFolder alvo
End Sub

Private Sub GravarLog(ByVal pastaBackup As String, ByVal texto As String)
    GarantirPasta pastaBackup
    GravarTextoParaArquivo pastaBackup & Application.PathSeparator & "importador.log", texto
End Sub

Private Sub GravarTextoParaArquivo(ByVal caminho As String, ByVal texto As String)
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    Dim ts As Object
    Set ts = fso.CreateTextFile(caminho, True, False) ' ASCII, overwrite
    ts.Write texto
    ts.Close
End Sub

Private Function ArquivoExiste(ByVal fullPath As String) As Boolean
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    ArquivoExiste = fso.FileExists(fullPath)
End Function

Private Function LerArquivoLinhas(ByVal fullPath As String) As String()
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    Dim ts As Object
    Set ts = fso.OpenTextFile(fullPath, 1, False) ' ForReading
    Dim conteudo As String
    conteudo = ts.ReadAll
    ts.Close
    ' Normaliza para CRLF interno antes do Split (tolerante a LF).
    conteudo = Replace$(conteudo, vbCrLf, vbLf)
    conteudo = Replace$(conteudo, vbCr, vbLf)
    LerArquivoLinhas = Split(conteudo, vbLf)
End Function

Private Function AjustarSeparadores(ByVal relPath As String) As String
    Dim s As String
    s = relPath
    s = Replace$(s, "/", Application.PathSeparator)
    s = Replace$(s, "\", Application.PathSeparator)
    AjustarSeparadores = s
End Function

Private Function EhArquivoOculto(ByVal fullPath As String) As Boolean
    Dim nomeArq As String
    nomeArq = UltimoSegmento(Replace$(fullPath, "\", "/"))
    If Len(nomeArq) = 0 Then Exit Function
    EhArquivoOculto = (Left$(nomeArq, 1) = ".")
End Function

Private Function ExtrairVBName(ByVal fullPath As String) As String
    Dim linhas() As String
    linhas = LerArquivoLinhas(fullPath)
    Dim i As Long
    Dim s As String
    For i = LBound(linhas) To UBound(linhas)
        s = Trim$(linhas(i))
        If Left$(s, 17) = "Attribute VB_Name" Then
            ExtrairVBName = ExtrairEntreAspas(s)
            Exit Function
        End If
    Next i
    ExtrairVBName = ""
End Function

Private Function ExtrairEntreAspas(ByVal s As String) As String
    Dim p1 As Long
    Dim p2 As Long
    p1 = InStr(1, s, """", vbBinaryCompare)
    If p1 = 0 Then Exit Function
    p2 = InStr(p1 + 1, s, """", vbBinaryCompare)
    If p2 = 0 Then Exit Function
    ExtrairEntreAspas = Mid$(s, p1 + 1, p2 - p1 - 1)
End Function

Private Function SelecionarPastaVBAImport() As String
    On Error GoTo falha

    Dim fd As Object
    Set fd = Application.FileDialog(4) ' msoFileDialogFolderPicker
    fd.Title = "Selecione a pasta vba_import"
    fd.AllowMultiSelect = False
    If fd.Show <> -1 Then
        SelecionarPastaVBAImport = ""
        Exit Function
    End If

    Dim p As String
    p = CStr(fd.SelectedItems(1))
    If Right$(p, 1) = "\" Or Right$(p, 1) = "/" Then
        p = Left$(p, Len(p) - 1)
    End If
    SelecionarPastaVBAImport = p
    Exit Function

falha:
    SelecionarPastaVBAImport = ""
End Function

Private Function FormatarAgora() As String
    FormatarAgora = Format$(Now(), "yyyy-mm-dd hh:nn:ss")
End Function


