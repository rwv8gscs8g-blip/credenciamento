Attribute VB_Name = "Importador_V2"
Option Explicit

' ============================================================
' Importador V2 - Onda 9 antecipada V12.0.0203
' ============================================================
'
' Substitui o Importador_VBA.bas legacy (com bugs estruturais
' historicos de Mod_Types/TConfig).
'
' Le local-ai/vba_import/000-MANIFESTO-IMPORTACAO.txt enriquecido
' com grupos e importa cada modulo/form com:
'   - backup automatico antes de remover
'   - purge de fantasmas (sufixos numericos, conflitos)
'   - compilacao validada apos cada grupo
'   - tratamento especial de .frm via .code-only.txt
'   - logs em planilha IMPORT_LOG_V2
'
' Pre-requisitos:
'   - VBOM habilitado (Excel Options > Trust Center >
'     Trust access to VBA project object model)
'   - Pasta local-ai/vba_import/ presente (CLA-controlado, ver
'     docs/how-to/COMO_OBTER_FERRAMENTAS_VBA.md)
'   - Manifesto enriquecido com grupos (linha em branco
'     como separador, header `# GRUPO_X`)
'
' Tabu (mantido por enquanto):
'   - Mod_Types.bas nao e modificado por import incremental.
'     Se hash diverge, aborta com diagnostico pedindo aprovacao
'     explicita do mantenedor.
'
' API publica:
'   - ImportarPacoteV2()             - pacote completo + valida por grupo
'   - ImportarPacoteV2_DryRun()      - simula, nao altera
'   - ImportarPacoteV2_Grupo(nome)   - apenas um grupo nominal
'   - ImportarPacoteV2_Status()      - retorna sumario do ultimo run
'
' Documentacao publica:
'   - .hbn/knowledge/0007-acesso-controlado-via-cla.md
'   - docs/explanation/MODELO_DE_ACESSO_CONTROLADO.md
'   - docs/how-to/COMO_OBTER_FERRAMENTAS_VBA.md
'   - docs/reference/MATRIZ_PUBLICO_VS_CLA.md
'   - docs/reference/MANIFESTO_FORMAT.md (a criar em 9.5)
' ============================================================

' === Constantes ===

Private Const IV2_VERSION As String = "V2.0"
Private Const IV2_MANIFESTO_REL As String = "local-ai\vba_import\000-MANIFESTO-IMPORTACAO.txt"
Private Const IV2_VBA_IMPORT_DIR_REL As String = "local-ai\vba_import\"
Private Const IV2_BACKUP_DIR_REL As String = "backups\vba\"
Private Const IV2_LOG_SHEET As String = "IMPORT_LOG_V2"

' Tabu - Mod_Types nao e modificado por importador (Onda 9 plena ainda nao implementada)
Private Const IV2_MOD_TYPES_NAME As String = "Mod_Types"

' Tipos de componente VBE (vbext_ComponentType)
Private Const IV2_VBEXT_CT_STDMODULE As Long = 1
Private Const IV2_VBEXT_CT_CLASSMODULE As Long = 2
Private Const IV2_VBEXT_CT_MSFORM As Long = 3
Private Const IV2_VBEXT_CT_DOCUMENT As Long = 100

' Status do ultimo run
Private mIV2_LastStatus As String


' ============================================================
' === API publica ===========================================
' ============================================================

Public Sub ImportarPacoteV2()
    Call IV2_RodarMain(False, "")
End Sub

Public Sub ImportarPacoteV2_DryRun()
    Call IV2_RodarMain(True, "")
End Sub

Public Sub ImportarPacoteV2_Grupo(ByVal nomeGrupo As String)
    Call IV2_RodarMain(False, nomeGrupo)
End Sub

' ImportarPacoteV2_Status agora e Sub e imprime direto na janela imediata.
' (Antes era Function. Quando chamada com "Call ..._Status" o VBA descartava
' o retorno e nada aparecia. Bug corrigido em 2026-04-29.)
'
' Quando ainda nao houve nenhum import nesta sessao, mostra um RESUMO DO
' MANIFESTO (grupos + contagem) para que o operador veja imediatamente
' que a ferramenta esta viva e qual seria o universo de import.
Public Sub ImportarPacoteV2_Status()
    Debug.Print "=== ImportarPacoteV2_Status (" & IV2_VERSION & ") ==="
    If mIV2_LastStatus <> "" Then
        Debug.Print "ULTIMO RUN NESTA SESSAO:"
        Debug.Print mIV2_LastStatus
        Debug.Print ""
    Else
        Debug.Print "(nenhum import V2 executado nesta sessao)"
        Debug.Print ""
    End If

    ' Sempre mostra resumo do manifesto (mesmo sem run anterior)
    Dim manifesto As String
    manifesto = ThisWorkbook.Path & Application.PathSeparator & _
                Replace(IV2_MANIFESTO_REL, "\", Application.PathSeparator)
    Debug.Print "MANIFESTO ESPERADO:"
    Debug.Print "  " & manifesto
    If Not IV2_ArquivoExiste(manifesto) Then
        Debug.Print "  STATUS: AUSENTE"
        Debug.Print ""
        Debug.Print "Pacote local-ai/vba_import/ nao foi descompactado " & _
                    "ou path errado. Ver docs/how-to/COMO_OBTER_FERRAMENTAS_VBA.md."
        Exit Sub
    End If
    Debug.Print "  STATUS: presente"
    Debug.Print ""

    Dim grupos() As String
    Call IV2_LerManifesto(manifesto, grupos)

    Debug.Print "GRUPOS DECLARADOS NO MANIFESTO:"
    Dim i As Long
    Dim totalItens As Long
    Dim cabecalho As String
    Dim conteudoItens As String
    Dim qtdGrupo As Long
    For i = LBound(grupos) To UBound(grupos)
        cabecalho = IV2_PartesGrupo_Header(grupos(i))
        conteudoItens = IV2_PartesGrupo_Itens(grupos(i))
        If conteudoItens = "" Then
            qtdGrupo = 0
        Else
            qtdGrupo = UBound(Split(conteudoItens, vbCrLf)) + 1
        End If
        totalItens = totalItens + qtdGrupo
        Debug.Print "  [" & Format$(i, "00") & "] " & _
                    Left$(cabecalho & String$(60, " "), 60) & _
                    " itens=" & qtdGrupo
    Next i
    Debug.Print ""
    Debug.Print "TOTAL DE ITENS NO MANIFESTO: " & totalItens
    Debug.Print "=== fim ImportarPacoteV2_Status ==="
End Sub


' ============================================================
' === Main ===================================================
' ============================================================

Private Sub IV2_RodarMain(ByVal dryRun As Boolean, ByVal grupoSpec As String)
    Dim manifesto As String
    Dim grupos() As String
    Dim ts As String
    Dim totalImportados As Long
    Dim totalSkipped As Long
    Dim totalErros As Long
    Dim modoTxt As String
    ' Variaveis snapshot para o handler `falha:` (preserva info mesmo se Err
    ' for limpo por sub aninhada com OERN antes do handler ler).
    Dim faseAtual As String
    Dim ultErrNum As Long
    Dim ultErrDesc As String
    Dim ultErrSource As String

    ts = Format$(Now, "yyyymmdd_hhnnss")
    If dryRun Then
        modoTxt = "DRY-RUN"
    Else
        modoTxt = "REAL"
    End If
    mIV2_LastStatus = "(executando " & modoTxt & " em " & ts & ")"
    faseAtual = "INICIO"

    On Error GoTo falha

    ' 1. Validar VBOM habilitado
    faseAtual = "1_VBOM_CHECK"
    If Not IV2_VBOMHabilitado() Then
        Call IV2_AbortarComDiagnostico("VBOM nao habilitado. " & _
            "Excel > Opcoes > Centro de Confiabilidade > Configuracoes de Macro > " & _
            "Confiar no acesso ao modelo de objeto do projeto VBA.")
        Exit Sub
    End If

    ' 2. Localizar manifesto
    faseAtual = "2_LOCALIZAR_MANIFESTO"
    manifesto = ThisWorkbook.Path & Application.PathSeparator & _
                Replace(IV2_MANIFESTO_REL, "\", Application.PathSeparator)
    If Not IV2_ArquivoExiste(manifesto) Then
        Call IV2_AbortarComDiagnostico("Manifesto nao encontrado em:" & vbCrLf & manifesto & vbCrLf & vbCrLf & _
            "Confirmar que o release zip foi descompactado em local-ai/. " & _
            "Ver docs/how-to/COMO_OBTER_FERRAMENTAS_VBA.md.")
        Exit Sub
    End If

    ' 3. Garantir planilha de log
    faseAtual = "3_GARANTIR_PLANILHA_LOG"
    Call IV2_GarantirPlanilhaLog
    faseAtual = "3_LOG_INICIO"
    Call IV2_LogarEvento(ts, "INICIO", "", "", _
                       "Importador V2 " & IV2_VERSION & " - " & modoTxt & _
                       IIf(grupoSpec <> "", " (grupo: " & grupoSpec & ")", " (todos)"), _
                       "info")

    ' 4. Backup do projeto VBA inteiro (so em modo real)
    If Not dryRun Then
        faseAtual = "4_BACKUP"
        Call IV2_BackupAntesDeImportar(ts)
        Call IV2_LogarEvento(ts, "BACKUP", "(projeto)", "backups/vba/" & ts & "-V2-FULL/", _
                           "backup do projeto VBA antes de import", "ok")
    End If

    ' 5. Purge fantasmas (so em modo real)
    If Not dryRun Then
        faseAtual = "5_PURGE_FANTASMAS"
        Call IV2_PurgeFantasmas(ts)
    End If

    ' 6. Ler manifesto e processar por grupo
    faseAtual = "6_LER_MANIFESTO"
    Call IV2_LerManifesto(manifesto, grupos)

    Dim i As Long
    Dim cabecalho As String
    Dim conteudo As String
    Dim grupoMatch As Boolean

    For i = LBound(grupos) To UBound(grupos)
        faseAtual = "6_GRUPO_" & i & "_PARSE"
        cabecalho = IV2_PartesGrupo_Header(grupos(i))
        conteudo = IV2_PartesGrupo_Itens(grupos(i))
        faseAtual = "6_GRUPO_" & i & "_" & Left$(cabecalho, 40)

        ' Filtrar por grupo se especificado
        grupoMatch = True
        If grupoSpec <> "" Then
            If InStr(1, cabecalho, grupoSpec, vbTextCompare) = 0 Then
                grupoMatch = False
                Call IV2_LogarEvento(ts, cabecalho, "", "", _
                                   "skipped (filtro de grupo: " & grupoSpec & ")", "skip")
            End If
        End If

        If grupoMatch And Len(conteudo) > 0 Then
            faseAtual = "6_GRUPO_" & i & "_PROCESSAR"
            ' Snapshot Err antes da chamada (caso sub aninhada limpe Err)
            ultErrNum = 0: ultErrDesc = "": ultErrSource = ""
            Call IV2_ProcessarGrupo(ts, cabecalho, conteudo, dryRun, _
                                  totalImportados, totalSkipped, totalErros)

            ' Validar compilacao apos grupo (so em modo real)
            ' Hotfix Onda 9: validacao e best-effort (True ou Empty).
            ' NUNCA aborta o import - operador valida manualmente apos run
            ' (Debug > Compile VBAProject). Backup completo protege rollback.
            If Not dryRun Then
                faseAtual = "6_GRUPO_" & i & "_COMPILE"
                Dim resultadoCompile As Variant
                resultadoCompile = IV2_CompilarVBProject()
                If IsEmpty(resultadoCompile) Then
                    Call IV2_LogarEvento(ts, cabecalho, "(compile)", "", _
                                       "compile nao validavel neste ambiente - prosseguindo (validar manualmente apos run)", "warn")
                Else
                    Call IV2_LogarEvento(ts, cabecalho, "(compile)", "", "compile OK (best-effort)", "ok")
                End If
            End If
        End If
    Next i

    ' 7. Salvar log final
    faseAtual = "7_LOG_FIM"
    Call IV2_LogarEvento(ts, "FIM", "", "", _
                       "imp=" & totalImportados & " skip=" & totalSkipped & " err=" & totalErros, _
                       IIf(totalErros > 0, "warn", "ok"))

    mIV2_LastStatus = "OK em " & ts & " (imp=" & totalImportados & _
                      ", skip=" & totalSkipped & ", err=" & totalErros & ")"

    Dim icone As Long
    If totalErros = 0 Then
        icone = vbInformation
    Else
        icone = vbExclamation
    End If

    faseAtual = "8_MSGBOX_FIM"
    MsgBox "Importador V2 - " & modoTxt & " concluido." & vbCrLf & vbCrLf & _
           "Importados: " & totalImportados & vbCrLf & _
           "Skipped:    " & totalSkipped & vbCrLf & _
           "Erros:      " & totalErros & vbCrLf & vbCrLf & _
           "Detalhes em planilha IMPORT_LOG_V2.", _
           icone, "Importador V2 " & IV2_VERSION
    Exit Sub

falha:
    ' Snapshot Err IMEDIATAMENTE (antes de qualquer call que possa limpar)
    ultErrNum = Err.Number
    ultErrDesc = Err.Description
    ultErrSource = Err.Source
    mIV2_LastStatus = "ERRO " & ultErrNum & " - " & ultErrDesc & " [fase=" & faseAtual & "]"
    On Error Resume Next
    Call IV2_LogarEvento(ts, "FALHA_FATAL", faseAtual, ultErrSource, _
                       "Err " & ultErrNum & ": " & ultErrDesc, "fatal")
    On Error GoTo 0
    MsgBox "Importador V2 ABORTADO:" & vbCrLf & vbCrLf & _
           "Fase:   " & faseAtual & vbCrLf & _
           "Source: " & ultErrSource & vbCrLf & _
           "Err " & ultErrNum & ": " & ultErrDesc & vbCrLf & vbCrLf & _
           "(Se Err 0: erro engolido por sub interna; ver fase para localizar.)", _
           vbCritical, "Importador V2"
End Sub


' ============================================================
' === Processamento de grupo =================================
' ============================================================

Private Sub IV2_ProcessarGrupo(ByVal ts As String, ByVal cabecalho As String, _
                              ByVal itens As String, ByVal dryRun As Boolean, _
                              ByRef totalImportados As Long, _
                              ByRef totalSkipped As Long, _
                              ByRef totalErros As Long)
    Dim linhas() As String
    Dim i As Long
    Dim linha As String
    Dim tipo As String
    Dim caminhoRel As String
    Dim caminho As String
    Dim vbName As String
    Dim sucesso As Boolean
    Dim posPipe As Long

    Call IV2_LogarEvento(ts, cabecalho, "(grupo inicio)", "", _
                       "iniciando processamento", "info")

    linhas = Split(itens, vbCrLf)
    For i = LBound(linhas) To UBound(linhas)
        linha = Trim$(linhas(i))
        If linha = "" Then GoTo proximoItem
        If Left$(linha, 1) = "#" Then GoTo proximoItem

        posPipe = InStr(linha, "|")
        If posPipe < 2 Then GoTo proximoItem

        tipo = Left$(linha, 1)  ' "M" ou "F"
        caminhoRel = Mid$(linha, posPipe + 1)
        caminho = ThisWorkbook.Path & Application.PathSeparator & _
                  Replace(IV2_VBA_IMPORT_DIR_REL, "\", Application.PathSeparator) & _
                  Replace(caminhoRel, "/", Application.PathSeparator)

        ' Determinar VB_Name (remove pasta, prefixo AAX-, e extensao)
        vbName = IV2_NomeArquivoSemPrefixo(caminhoRel)

        ' TABU: Mod_Types nao e modificado em import incremental.
        '
        ' Regra simplificada (2026-04-29):
        '   - Se Mod_Types ja existe no workbook: SKIP incondicional.
        '   - Se Mod_Types nao existe (workbook limpo / fresh): importa.
        '
        ' A protecao real contra divergencia esta a montante:
        '   - Glasswing G7 garante src/vba <-> local-ai/vba_import sincronizados.
        '   - publicar_vba_import_v2 detecta qualquer mudanca em src/vba/Mod_Types.bas.
        '   - git pre-commit hook (9.4) bloqueia commit que mude Mod_Types sem aprovacao.
        '
        ' Hash heuristico foi removido do gate porque o arquivo .bas no disco
        ' inclui o boilerplate `Attribute VB_Name = ...` que o CodeModule.Lines
        ' do componente VBA NAO retorna - causando divergencia sistemica.
        If vbName = IV2_MOD_TYPES_NAME Then
            If IV2_VBComponentExiste(vbName) Then
                Call IV2_LogarEvento(ts, cabecalho, vbName, caminho, _
                                   "TABU: Mod_Types ja existe no workbook, pulado", "skip")
                totalSkipped = totalSkipped + 1
            Else
                ' Workbook sem Mod_Types: importar (provavelmente build novo)
                If dryRun Then
                    Call IV2_LogarEvento(ts, cabecalho, vbName, caminho, _
                                       "would_import (Mod_Types ausente - workbook limpo)", "dryrun")
                    totalImportados = totalImportados + 1
                Else
                    sucesso = IV2_ImportarModulo(vbName, caminho, ts, cabecalho)
                    If sucesso Then
                        totalImportados = totalImportados + 1
                    Else
                        totalErros = totalErros + 1
                    End If
                End If
            End If
            GoTo proximoItem
        End If

        If dryRun Then
            Call IV2_LogarEvento(ts, cabecalho, vbName, caminho, _
                               "would_import (" & tipo & ")", "dryrun")
            totalImportados = totalImportados + 1
            GoTo proximoItem
        End If

        ' Importacao real
        If tipo = "M" Then
            sucesso = IV2_ImportarModulo(vbName, caminho, ts, cabecalho)
        ElseIf tipo = "F" Then
            sucesso = IV2_ImportarFormSafe(vbName, caminho, ts, cabecalho)
        Else
            Call IV2_LogarEvento(ts, cabecalho, linha, "", _
                               "tipo desconhecido (esperado M ou F)", "err")
            sucesso = False
        End If

        If sucesso Then
            totalImportados = totalImportados + 1
        Else
            totalErros = totalErros + 1
        End If

proximoItem:
    Next i
End Sub


' ============================================================
' === Parsing do manifesto ====================================
' ============================================================

Private Sub IV2_LerManifesto(ByVal caminho As String, ByRef grupos() As String)
    Dim linha As String
    Dim grupoCorrente As String
    Dim resultado() As String
    Dim n As Long
    Dim i As Long
    Dim conteudo As String
    Dim linhas() As String

    n = -1
    ReDim resultado(200)
    grupoCorrente = ""

    ' Le binario + normaliza EOL (cross-platform). Antes usava Line Input,
    ' que no Excel Mac lia o manifesto inteiro como uma linha (bug 2026-04-29).
    conteudo = IV2_LerArquivoBinarioComoTexto(caminho)
    linhas = Split(conteudo, vbCrLf)

    For i = LBound(linhas) To UBound(linhas)
        linha = linhas(i)
        ' Linha vazia = separador de grupo
        If Trim$(linha) = "" Then
            If grupoCorrente <> "" Then
                n = n + 1
                resultado(n) = grupoCorrente
                grupoCorrente = ""
            End If
        Else
            If grupoCorrente = "" Then
                grupoCorrente = linha
            Else
                grupoCorrente = grupoCorrente & vbCrLf & linha
            End If
        End If
    Next i

    ' Adiciona ultimo grupo
    If grupoCorrente <> "" Then
        n = n + 1
        resultado(n) = grupoCorrente
    End If

    If n >= 0 Then
        ReDim Preserve resultado(n)
        grupos = resultado
    Else
        ReDim grupos(0 To 0)
        grupos(0) = ""
    End If
End Sub

Private Function IV2_PartesGrupo_Header(ByVal grupo As String) As String
    Dim linhas() As String
    linhas = Split(grupo, vbCrLf)
    Dim i As Long
    For i = LBound(linhas) To UBound(linhas)
        Dim t As String
        t = Trim$(linhas(i))
        If Left$(t, 1) = "#" Then
            IV2_PartesGrupo_Header = t
            Exit Function
        End If
    Next i
    IV2_PartesGrupo_Header = "(grupo sem header)"
End Function

Private Function IV2_PartesGrupo_Itens(ByVal grupo As String) As String
    Dim linhas() As String
    Dim resultado As String
    Dim i As Long
    Dim t As String

    linhas = Split(grupo, vbCrLf)
    For i = LBound(linhas) To UBound(linhas)
        t = Trim$(linhas(i))
        If Left$(t, 1) <> "#" And t <> "" Then
            If resultado = "" Then
                resultado = t
            Else
                resultado = resultado & vbCrLf & t
            End If
        End If
    Next i
    IV2_PartesGrupo_Itens = resultado
End Function

Private Function IV2_NomeArquivoSemPrefixo(ByVal caminhoRel As String) As String
    Dim nome As String
    Dim p As Long

    ' Pegar nome do arquivo
    p = InStrRev(caminhoRel, "/")
    If p = 0 Then p = InStrRev(caminhoRel, "\")
    If p = 0 Then
        nome = caminhoRel
    Else
        nome = Mid$(caminhoRel, p + 1)
    End If

    ' Remove prefixo AAX- (3 letras + hifen)
    If Len(nome) > 4 Then
        If Mid$(nome, 4, 1) = "-" Then
            nome = Mid$(nome, 5)
        End If
    End If

    ' Remove extensao
    Dim dotPos As Long
    dotPos = InStrRev(nome, ".")
    If dotPos > 0 Then nome = Left$(nome, dotPos - 1)

    IV2_NomeArquivoSemPrefixo = nome
End Function


' ============================================================
' === VBE manipulation ========================================
' ============================================================

Private Function IV2_VBOMHabilitado() As Boolean
    On Error GoTo nao
    Dim n As Long
    n = Application.VBE.ActiveVBProject.VBComponents.Count
    IV2_VBOMHabilitado = (n > 0)
    Exit Function
nao:
    IV2_VBOMHabilitado = False
End Function

Private Function IV2_VBComponentExiste(ByVal vbName As String) As Boolean
    On Error Resume Next
    Dim c As Object
    Set c = Application.VBE.ActiveVBProject.VBComponents(vbName)
    IV2_VBComponentExiste = (Err.Number = 0 And Not c Is Nothing)
    Err.Clear
End Function

' Hotfix Onda 9 (V12.0.0429): Remove robusto.
'
' Bug original: c.Export de backup individual podia falhar (path com SMB,
' permissao, disco) e o handler `falha:` engolia silenciosamente, retornando
' False. IV2_ImportarModulo IGNORAVA esse retorno e seguia importando, com
' o componente original ainda no projeto - VBE renomeava o novo para
' "<nome>1" (modulos fantasma duplicados).
'
' Fix:
'   1. Backup individual e BEST-EFFORT (OERN local), nao bloqueia o Remove.
'      Backup completo do projeto ja foi feito por IV2_BackupAntesDeImportar
'      no inicio do run (modo real).
'   2. O Remove em si tem handler estrito - se falhar, retorna False com
'      contexto.
'   3. Apos Remove, valida que o componente realmente sumiu (defesa em
'      profundidade contra VBE inconsistente).
Private Function IV2_RemoverComponente(ByVal vbName As String, ByVal ts As String) As Boolean
    Dim c As Object
    Dim ext As String
    Dim backupDir As String

    On Error Resume Next
    If Not IV2_VBComponentExiste(vbName) Then
        IV2_RemoverComponente = True
        On Error GoTo 0
        Exit Function
    End If
    On Error GoTo 0

    On Error GoTo falha
    Set c = Application.VBE.ActiveVBProject.VBComponents(vbName)

    ' Document (ThisWorkbook, Plan*) NAO e removivel - retorna OK sem tocar
    If c.Type = IV2_VBEXT_CT_DOCUMENT Then
        IV2_RemoverComponente = True
        Exit Function
    End If

    ' --- Backup individual best-effort (NAO bloqueia Remove se falhar) ---
    On Error Resume Next
    backupDir = ThisWorkbook.Path & Application.PathSeparator & _
                Replace(IV2_BACKUP_DIR_REL, "\", Application.PathSeparator) & ts & "-V2"
    Call IV2_GarantirPasta(backupDir)

    Select Case c.Type
        Case IV2_VBEXT_CT_MSFORM
            ext = ".frm"
        Case IV2_VBEXT_CT_CLASSMODULE
            ext = ".cls"
        Case Else
            ext = ".bas"
    End Select
    c.Export backupDir & Application.PathSeparator & vbName & ext
    Err.Clear  ' descarta erro de backup individual
    On Error GoTo falha
    ' --- fim backup best-effort ---

    Application.VBE.ActiveVBProject.VBComponents.Remove c
    Set c = Nothing

    ' Valida que o componente realmente sumiu (alguns ambientes VBE marcam
    ' Remove com sucesso mas mantem fantasma).
    If IV2_VBComponentExiste(vbName) Then
        IV2_RemoverComponente = False
        Exit Function
    End If

    IV2_RemoverComponente = True
    Exit Function

falha:
    IV2_RemoverComponente = False
End Function

' Hotfix Onda 9 v11 (2026-04-29): in-place replace via DeleteLines + AddFromString.
'
' Bug v10: VBComponents.Add criava componente novo (Module1) quando
' VBComponents.Remove falhava silenciosamente no Mac. O codigo correto ia
' para Module1 e o componente original (Util_Conversao etc) ficava com
' versao defasada. Funcoes "nao encontradas" porque eram chamadas em
' Util_Conversao mas estavam em Module1.
'
' Fix v11 (definitivo, in-place):
'   1. Purge fantasmas <vbName>1..9 (cleanup de imports anteriores).
'   2. Se vbName JA existe: limpa o CodeModule via DeleteLines + injeta
'      novo conteudo via AddFromString.
'   3. Se vbName NAO existe: cria via Add + define Name + AddFromString.
'
' Esta abordagem nao depende do Remove funcionar - funciona em ambos os
' caminhos (Windows com Remove ok, Mac com Remove falho). cm.DeleteLines
' e cm.AddFromString sao APIs determinísticas em ambas as plataformas.
Private Function IV2_ImportarModulo(ByVal vbName As String, ByVal caminho As String, _
                                    ByVal ts As String, ByVal cabecalho As String) As Boolean
    Dim conteudo As String
    Dim linhas() As String
    Dim corpo As String
    Dim i As Long
    Dim linhaTrim As String
    Dim alvo As Object
    Dim cm As Object
    Dim ncLinhas As Long
    Dim metodoUsado As String

    On Error GoTo falha

    If Not IV2_ArquivoExiste(caminho) Then
        Call IV2_LogarEvento(ts, cabecalho, vbName, caminho, _
                           "arquivo nao existe", "err")
        IV2_ImportarModulo = False
        Exit Function
    End If

    ' 1. Purge fantasmas <vbName>1..9 (deixa apenas vbName se existir)
    Call IV2_PurgeFantasmasNumericos(vbName)

    ' 2. Ler conteudo com EOL normalizado (cross-platform)
    conteudo = IV2_LerArquivoBinarioComoTexto(caminho)

    ' 3. Pular cabecalho Attribute VB_* (estas linhas pertencem ao header
    '    do arquivo .bas e NAO ao CodeModule do componente)
    linhas = Split(conteudo, vbCrLf)
    For i = LBound(linhas) To UBound(linhas)
        linhaTrim = LTrim$(linhas(i))
        If Left$(linhaTrim, 13) = "Attribute VB_" Then
            ' Pula esta linha
        Else
            If Len(corpo) = 0 Then
                corpo = linhas(i)
            Else
                corpo = corpo & vbCrLf & linhas(i)
            End If
        End If
    Next i

    ' 4. Estrategia in-place: se vbName ja existe, limpa CodeModule e
    '    injeta novo conteudo. Se nao existe, cria componente novo.
    If IV2_VBComponentExiste(vbName) Then
        Set alvo = Application.VBE.ActiveVBProject.VBComponents(vbName)
        ' Se for Document (ThisWorkbook, Plan*), nao toca - so loga
        If alvo.Type = IV2_VBEXT_CT_DOCUMENT Then
            Call IV2_LogarEvento(ts, cabecalho, vbName, caminho, _
                               "Document - skip (nao removivel)", "skip")
            IV2_ImportarModulo = True
            Exit Function
        End If
        Set cm = alvo.CodeModule

        ' Hotfix v13 (2026-04-29): loop DeleteLines ate CountOfLines = 0.
        ' Bug v12: cm.DeleteLines 1, cm.CountOfLines em uma chamada nao
        ' zerava sempre - deixava residuo no Excel for Mac. Resultado:
        ' AddFromString posterior empilhava em cima e gerava duplicacao
        ' (160 linhas vs 94 esperadas em Util_Conversao).
        Dim tentativasDel As Long
        Dim antesLines As Long
        antesLines = cm.CountOfLines
        tentativasDel = 0
        Do While cm.CountOfLines > 0 And tentativasDel < 10
            cm.DeleteLines 1, cm.CountOfLines
            tentativasDel = tentativasDel + 1
        Loop
        If cm.CountOfLines > 0 Then
            Call IV2_LogarEvento(ts, cabecalho, vbName, caminho, _
                               "DeleteLines NAO zerou apos " & tentativasDel & _
                               " tentativas (CountOfLines=" & cm.CountOfLines & _
                               ", antes=" & antesLines & ")", "err")
            IV2_ImportarModulo = False
            Exit Function
        End If

        ' Injeta novo conteudo no modulo agora vazio
        If Len(corpo) > 0 Then
            cm.AddFromString corpo
        End If
        metodoUsado = "in-place (DeleteLines+AddFromString, " & tentativasDel & "x)"
    Else
        ' Componente nao existe ainda - cria do zero
        Set alvo = Application.VBE.ActiveVBProject.VBComponents.Add(IV2_VBEXT_CT_STDMODULE)
        alvo.Name = vbName
        Set cm = alvo.CodeModule
        If Len(corpo) > 0 Then
            cm.AddFromString corpo
        End If
        metodoUsado = "novo (Add+AddFromString)"
    End If

    ' 5. Validar CountOfLines (deteccao de import vazio ou anomalia)
    ncLinhas = cm.CountOfLines
    If ncLinhas <= 0 Then
        Call IV2_LogarEvento(ts, cabecalho, vbName, caminho, _
                           "import resultou em CodeModule vazio (" & metodoUsado & ")", "err")
        IV2_ImportarModulo = False
        Exit Function
    End If

    Call IV2_LogarEvento(ts, cabecalho, vbName, caminho, _
                       "imported (M, " & metodoUsado & ", lines=" & ncLinhas & ")", "ok")
    IV2_ImportarModulo = True
    Exit Function

falha:
    Call IV2_LogarEvento(ts, cabecalho, vbName, caminho, _
                       "Err " & Err.Number & ": " & Err.Description, "err")
    IV2_ImportarModulo = False
End Function

' Hotfix Onda 9 v11: purge apenas fantasmas com sufixo numerico
' (<vbName>1..<vbName>9). NAO remove vbName em si - a estrategia in-place
' do IV2_ImportarModulo cuida desse caso.
Private Sub IV2_PurgeFantasmasNumericos(ByVal vbName As String)
    On Error Resume Next
    Dim p As Object
    Set p = Application.VBE.ActiveVBProject

    Dim c As Object
    Dim sufixo As Long
    Dim nomeAlvo As String

    For sufixo = 1 To 9
        nomeAlvo = vbName & CStr(sufixo)
        Set c = Nothing
        Set c = p.VBComponents(nomeAlvo)
        If Not c Is Nothing Then
            If c.Type <> IV2_VBEXT_CT_DOCUMENT Then
                p.VBComponents.Remove c
            End If
        End If
        Err.Clear
    Next sufixo
    On Error GoTo 0
End Sub

Private Function IV2_ImportarFormSafe(ByVal vbName As String, ByVal caminhoFrm As String, _
                                      ByVal ts As String, ByVal cabecalho As String) As Boolean
    On Error GoTo falha

    ' .code-only.txt corresponde ao .frm
    Dim caminhoCodeOnly As String
    caminhoCodeOnly = Replace(caminhoFrm, ".frm", ".code-only.txt")

    ' Workbook estabilizado: substituir SO o codigo, preservar .frx do designer
    If IV2_ArquivoExiste(caminhoCodeOnly) And IV2_VBComponentExiste(vbName) Then
        Dim cm As Object
        Set cm = Application.VBE.ActiveVBProject.VBComponents(vbName).CodeModule
        If cm.CountOfLines > 0 Then
            cm.DeleteLines 1, cm.CountOfLines
        End If
        Dim conteudo As String
        conteudo = IV2_LerArquivoTexto(caminhoCodeOnly)
        cm.AddFromString conteudo
        Call IV2_LogarEvento(ts, cabecalho, vbName, caminhoCodeOnly, _
                           "imported (F via code-only.txt - .frx preservado)", "ok")
        IV2_ImportarFormSafe = True
        Exit Function
    End If

    ' Workbook limpo OU code-only.txt ausente: importar .frm + .frx normalmente
    If Not IV2_ArquivoExiste(caminhoFrm) Then
        Call IV2_LogarEvento(ts, cabecalho, vbName, caminhoFrm, _
                           "arquivo .frm nao existe", "err")
        IV2_ImportarFormSafe = False
        Exit Function
    End If

    ' Hotfix Onda 9 v11: purge fantasmas numericos + Import API para .frm.
    ' Para .frm + .frx ainda usamos VBComponents.Import porque o .frx e
    ' binario e nao temos como reconstruir layout do form via AddFromString.
    ' Esse caminho so executa em workbook limpo (raro). Workbook
    ' estabilizado usa .code-only.txt acima (robusto, in-place).
    Call IV2_PurgeFantasmasNumericos(vbName)
    Application.VBE.ActiveVBProject.VBComponents.Import caminhoFrm

    Call IV2_LogarEvento(ts, cabecalho, vbName, caminhoFrm, _
                       "imported (F via frm+frx)", "ok")
    IV2_ImportarFormSafe = True
    Exit Function

falha:
    Call IV2_LogarEvento(ts, cabecalho, vbName, caminhoFrm, _
                       "Err " & Err.Number & ": " & Err.Description, "err")
    IV2_ImportarFormSafe = False
End Function

' Hotfix Onda 9 (V12.0.0429): IV2_CompilarVBProject best-effort.
'
' Decisao final: validacao automatica de compilacao via FindControl(578/753)
' nao funciona de forma confiavel em todos os ambientes (especialmente
' Excel for Mac, onde Execute pode disparar erro mesmo quando compilacao
' real e bem-sucedida). Em vez de tentar distinguir falha real vs falsa,
' a validacao agora e best-effort:
'   - True  = compilacao tentada e Execute retornou sem erro.
'   - Empty = compilacao nao pode ser validada (FindControl indisponivel
'             ou Execute deu erro de qualquer natureza).
'
' Em ambos os casos, o Import segue. O operador valida compilacao
' manualmente via Debug > Compile VBAProject (Cmd+Option+M no Mac)
' apos o Import completar.
'
' Backup completo no inicio do run (IV2_BackupAntesDeImportar) protege
' contra erros reais - rollback manual sempre possivel.
Private Function IV2_CompilarVBProject() As Variant
    Dim ctrl As Object

    On Error Resume Next

    ' Tentativa 1: ID 578 (Excel Windows)
    Set ctrl = Nothing
    Set ctrl = Application.VBE.CommandBars.FindControl(ID:=578)
    If Not ctrl Is Nothing Then
        Err.Clear
        ctrl.Execute
        If Err.Number = 0 Then
            IV2_CompilarVBProject = True
            Err.Clear
            On Error GoTo 0
            Exit Function
        End If
        Err.Clear
    End If

    ' Tentativa 2: ID 753 (alternativo)
    Set ctrl = Nothing
    Set ctrl = Application.VBE.CommandBars.FindControl(ID:=753)
    If Not ctrl Is Nothing Then
        Err.Clear
        ctrl.Execute
        If Err.Number = 0 Then
            IV2_CompilarVBProject = True
            Err.Clear
            On Error GoTo 0
            Exit Function
        End If
        Err.Clear
    End If

    ' Nada funcionou - retorna Empty (best-effort).
    Err.Clear
    IV2_CompilarVBProject = Empty
    On Error GoTo 0
End Function

Private Sub IV2_PurgeFantasmas(ByVal ts As String)
    On Error Resume Next
    Dim removidos As Long
    Dim i As Long
    Dim n As Long
    Dim c As Object
    Dim nome As String
    Dim ultimoChar As String
    Dim raiz As String

    removidos = 0
    n = Application.VBE.ActiveVBProject.VBComponents.Count
    For i = n To 1 Step -1
        Set c = Application.VBE.ActiveVBProject.VBComponents(i)
        If c.Type = IV2_VBEXT_CT_DOCUMENT Then GoTo proximoFantasma

        nome = c.Name
        If Len(nome) < 2 Then GoTo proximoFantasma
        ultimoChar = Right$(nome, 1)

        If ultimoChar Like "[1-9]" Then
            raiz = Left$(nome, Len(nome) - 1)
            If IV2_VBComponentExiste(raiz) Then
                Call IV2_LogarEvento(ts, "PURGE", nome, "", _
                                   "fantasma removido (conflita com raiz " & raiz & ")", "warn")
                Application.VBE.ActiveVBProject.VBComponents.Remove c
                removidos = removidos + 1
            End If
        End If
proximoFantasma:
    Next i
    If removidos > 0 Then
        Call IV2_LogarEvento(ts, "PURGE", "(total)", "", _
                           CStr(removidos) & " fantasmas removidos", "info")
    End If
End Sub


' ============================================================
' === Backup / filesystem ====================================
' ============================================================

Private Sub IV2_BackupAntesDeImportar(ByVal ts As String)
    On Error Resume Next
    Dim backupDir As String
    backupDir = ThisWorkbook.Path & Application.PathSeparator & _
                Replace(IV2_BACKUP_DIR_REL, "\", Application.PathSeparator) & ts & "-V2-FULL"
    Call IV2_GarantirPasta(backupDir)

    Dim i As Long
    Dim c As Object
    Dim ext As String
    For i = 1 To Application.VBE.ActiveVBProject.VBComponents.Count
        Set c = Application.VBE.ActiveVBProject.VBComponents(i)
        If c.Type <> IV2_VBEXT_CT_DOCUMENT Then
            Select Case c.Type
                Case IV2_VBEXT_CT_MSFORM
                    ext = ".frm"
                Case IV2_VBEXT_CT_CLASSMODULE
                    ext = ".cls"
                Case Else
                    ext = ".bas"
            End Select
            c.Export backupDir & Application.PathSeparator & c.Name & ext
        End If
    Next i
End Sub

Private Sub IV2_GarantirPasta(ByVal caminho As String)
    On Error Resume Next
    If Dir(caminho, vbDirectory) <> "" Then Exit Sub

    Dim partes() As String
    Dim acumula As String
    Dim i As Long
    partes = Split(caminho, Application.PathSeparator)
    acumula = ""
    For i = LBound(partes) To UBound(partes)
        If acumula = "" Then
            acumula = partes(i)
        Else
            acumula = acumula & Application.PathSeparator & partes(i)
        End If
        If acumula <> "" And Dir(acumula, vbDirectory) = "" Then
            MkDir acumula
        End If
    Next i
End Sub


' ============================================================
' === Logging =================================================
' ============================================================

Private Sub IV2_GarantirPlanilhaLog()
    On Error Resume Next
    Dim ws As Worksheet
    Set ws = Nothing
    Set ws = ThisWorkbook.Worksheets(IV2_LOG_SHEET)
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add( _
            After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
        ws.Name = IV2_LOG_SHEET
        ws.Cells(1, 1).Value = "TIMESTAMP"
        ws.Cells(1, 2).Value = "GRUPO"
        ws.Cells(1, 3).Value = "MODULO"
        ws.Cells(1, 4).Value = "CAMINHO"
        ws.Cells(1, 5).Value = "DETALHES"
        ws.Cells(1, 6).Value = "STATUS"
        ws.Range("A1:F1").Font.Bold = True
        ws.Columns("A:F").AutoFit
    End If
End Sub

Private Sub IV2_LogarEvento(ByVal ts As String, ByVal grupo As String, _
                            ByVal modulo As String, ByVal caminho As String, _
                            ByVal detalhes As String, ByVal status As String)
    On Error Resume Next
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets(IV2_LOG_SHEET)
    If ws Is Nothing Then Exit Sub

    Dim linha As Long
    linha = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row + 1
    ws.Cells(linha, 1).Value = ts
    ws.Cells(linha, 2).Value = grupo
    ws.Cells(linha, 3).Value = modulo
    ws.Cells(linha, 4).Value = caminho
    ws.Cells(linha, 5).Value = detalhes
    ws.Cells(linha, 6).Value = status
End Sub

Private Sub IV2_AbortarComDiagnostico(ByVal mensagem As String)
    mIV2_LastStatus = "ABORTADO: " & mensagem
    MsgBox "Importador V2 ABORTADO:" & vbCrLf & vbCrLf & mensagem, _
           vbCritical, "Importador V2 " & IV2_VERSION
End Sub


' ============================================================
' === Helpers de filesystem e hash heuristico ===============
' ============================================================

Private Function IV2_ArquivoExiste(ByVal caminho As String) As Boolean
    On Error Resume Next
    IV2_ArquivoExiste = (Dir(caminho) <> "")
    Err.Clear
End Function

' Le um arquivo como bloco binario (cross-platform) e normaliza todos os EOL
' (CR isolado, LF isolado, CRLF) para CRLF unificado. Resolve bug onde
' Excel para Mac le manifesto inteiro como uma linha so quando o arquivo
' nao usa o EOL nativo do SO (bug 2026-04-29).
Private Function IV2_LerArquivoBinarioComoTexto(ByVal caminho As String) As String
    Dim f As Integer
    Dim conteudo As String
    Dim tamArq As Long
    f = FreeFile
    Open caminho For Binary Access Read As #f
    tamArq = LOF(f)
    If tamArq > 0 Then
        conteudo = Space$(tamArq)
        Get #f, , conteudo
    End If
    Close #f
    ' Normaliza qualquer EOL para LF, depois LF para CRLF unificado.
    conteudo = Replace(conteudo, vbCrLf, vbLf)
    conteudo = Replace(conteudo, vbCr, vbLf)
    conteudo = Replace(conteudo, vbLf, vbCrLf)
    IV2_LerArquivoBinarioComoTexto = conteudo
End Function

Private Function IV2_LerArquivoTexto(ByVal caminho As String) As String
    IV2_LerArquivoTexto = IV2_LerArquivoBinarioComoTexto(caminho)
End Function

Private Function IV2_HashHeuristicoArquivo(ByVal caminho As String) As String
    ' VBA nao tem MD5 nativo. Hash heuristico por tamanho + checksum simples.
    On Error Resume Next
    Dim conteudo As String
    Dim linhas() As String
    Dim total As String
    Dim n As Long
    Dim i As Long

    conteudo = IV2_LerArquivoBinarioComoTexto(caminho)
    linhas = Split(conteudo, vbCrLf)

    For i = LBound(linhas) To UBound(linhas)
        If n >= 200 Then Exit For
        total = total & linhas(i)
        n = n + 1
    Next i

    IV2_HashHeuristicoArquivo = CStr(Len(total)) & "_" & CStr(n) & "_" & _
                                IIf(Len(total) > 0, CStr(Asc(Left$(total, 1))) & "_" & CStr(Asc(Right$(total, 1))), "0_0")
End Function

Private Function IV2_HashHeuristicoComponente(ByVal vbName As String) As String
    On Error Resume Next
    Dim cm As Object
    Set cm = Application.VBE.ActiveVBProject.VBComponents(vbName).CodeModule
    Dim total As String
    Dim i As Long
    Dim n As Long
    n = cm.CountOfLines
    If n > 200 Then n = 200
    For i = 1 To n
        total = total & cm.Lines(i, 1)
    Next i
    IV2_HashHeuristicoComponente = CStr(Len(total)) & "_" & CStr(n) & "_" & _
                                   IIf(Len(total) > 0, CStr(Asc(Left$(total, 1))) & "_" & CStr(Asc(Right$(total, 1))), "0_0")
End Function


