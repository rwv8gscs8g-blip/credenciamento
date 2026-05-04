Attribute VB_Name = "Importador_V3"
Option Explicit

' ============================================================
' Importador V3 - Onda 9 antecipada V12.0.0203 (entrega 2026-04-30)
' ============================================================
'
' Substitui o Importador_V2 (descontinuado por bug Mac SMB com
' DeleteLines+AddFromString in-place que deixava residuo intermitente
' no CodeModule, gerando codigo duplicado e compile failure).
'
' Diferencas estruturais V2 -> V3:
'   1) Estrategia de import: Remove+Import (deterministico) substitui
'      DeleteLines+AddFromString (erratico no Mac SMB).
'   2) Modos de execucao: Fresh (workbook quase vazio, < limiar) vs
'      Estabilizado (workbook com componentes ja instalados). Cada modo
'      tem caminho proprio para modulos e para forms.
'   3) Validacao: apos cada item importado, comparar CountOfLines real
'      vs esperado (lido do arquivo source). Apos cada grupo, compilar.
'      Falha em qualquer ponto = abort + restore do backup.
'   4) Anti-auto-import: V3 NAO esta no manifesto. Bootstrap externo
'      (Importador_V3_Bootstrap.bas, raiz de vba_import/) carrega V3.
'   5) Manifesto proprio: 000-MANIFESTO-V3-PHASE1.txt (Phase 1) ou
'      000-MANIFESTO-V3-FRESH.txt (Phase 2 futuro).
'
' API publica (4 entry points):
'   - ImportarPacoteV3()              ' detecta modo automaticamente
'   - ImportarPacoteV3_Fresh()        ' forca modo Fresh
'   - ImportarPacoteV3_DryRun()       ' simula, nao toca workbook
'   - ImportarPacoteV3_Status()       ' Sub - imprime estado na imediata
'
' Pre-requisitos:
'   - VBOM habilitado (Excel > Preferences > Security > Trust Center >
'     Trust access to VBA project object model)
'   - Pasta local-ai/vba_import/ presente ao lado do .xlsm
'   - Manifesto valido em local-ai/vba_import/000-MANIFESTO-V3-PHASE1.txt
'
' Mod_Types tabu (contrato 3 do knowledge 0008):
'   - Modo Estabilizado: pula Mod_Types se ja existe e hash bate.
'     Aborta se hash diverge.
'   - Modo Fresh: importa Mod_Types primeiro normalmente (workbook
'     vazio nao tem componente para conflitar).
'
' Persistencia:
'   - Aba IMPORT_LOG_V3 (criada se ausente). Append-only durante o run.
'   - Backup completo em backups\vba\<ts>-V3-FULL\ antes de qualquer
'     Remove em modo real.
'
' Cross-platform (Mac/Win):
'   - Leitura de arquivos via Open ... For Binary Access Read +
'     normalizacao CR/LF/CRLF -> CRLF unificado.
'   - Garantia de ultima linha em branco (bug historico licao a):
'     IV3_LerArquivoBinarioComoTexto adiciona vbCrLf terminal se ausente.
' ============================================================


' === Constantes ===

Private Const IV3_VERSION As String = "V3.3-Onda18-C4"
' V12.0.0203 ONDA 10 fechamento canonico (2026-05-02):
' Restaurada Regra de Ouro 0002 - importacao opera EXCLUSIVAMENTE de
' local-ai/vba_import/. Pasta vba_import_v3_phase1/ era solucao de
' contorno emergencial criada durante estabilizacao da V3 (Onda 9
' Phase 1). Conteudo migrado integralmente para canonica em
' 2026-05-02 com cuidado forense (backup + hash check 9/9). Pasta
' SCEV3 sera arquivada apos validacao. Erro e correcao documentados
' em auditoria/00_status/32_ERRO_E_CORRECAO_PASTA_CANONICA.md e
' usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md (L15 - pasta de import
' deve ser semanticamente homogenea).
Private Const IV3_MANIFESTO_REL As String = "local-ai\vba_import\000-MANIFESTO-V3-PHASE1.txt"
Private Const IV3_VBA_IMPORT_DIR_REL As String = "local-ai\vba_import\"
Private Const IV3_BACKUP_DIR_REL As String = "backups\vba\"
Private Const IV3_LOG_SHEET As String = "IMPORT_LOG_V3"

' V12.0.0203 ONDA 10 - Capacidade delta + bump auto de build label.
' Manifestos delta seguem o padrao 000-MANIFESTO-V3-DELTA-<NOME>.txt
' na pasta IV3_VBA_IMPORT_DIR_REL. Cada delta deve incluir como ultimo
' item o AAX-App_Release.bas, que tera as constantes APP_BUILD_IMPORTADO
' e APP_BUILD_GERADO_EM reescritas no espelho ANTES do import.
Private Const IV3_DELTA_MANIFESTO_PREFIX As String = "local-ai\vba_import\000-MANIFESTO-V3-DELTA-"
Private Const IV3_DELTA_MANIFESTO_SUFFIX As String = ".txt"
Private Const IV3_APP_RELEASE_REL_PATH As String = "local-ai\vba_import\001-modulo\AAX-App_Release.bas"
Private Const IV3_APP_RELEASE_NOME As String = "App_Release"
Private Const IV3_APP_RELEASE_CONST_BUILD As String = "APP_BUILD_IMPORTADO"
Private Const IV3_APP_RELEASE_CONST_GERADO As String = "APP_BUILD_GERADO_EM"

' Limiar para deteccao de modo Fresh: se VBComponents.Count <= este
' numero (excluindo ThisWorkbook + Sheets), modo Fresh; caso contrario
' modo Estabilizado.
Private Const IV3_FRESH_THRESHOLD As Long = 5

' Tabu - Mod_Types nao e modificado em modo Estabilizado
Private Const IV3_MOD_TYPES_NAME As String = "Mod_Types"

' Tipos de componente VBE (vbext_ComponentType)
Private Const IV3_VBEXT_CT_STDMODULE As Long = 1
Private Const IV3_VBEXT_CT_CLASSMODULE As Long = 2
Private Const IV3_VBEXT_CT_MSFORM As Long = 3
Private Const IV3_VBEXT_CT_DOCUMENT As Long = 100

' Tolerancia em linhas para validacao pos-import.
' Cobre: terminal vbCrLf, header Attribute VB_Name, e ate ~3 linhas de
' Attribute extras (VB_Exposed, VB_Customizable, etc.) que o VBE consome
' do arquivo .bas exportado.
Private Const IV3_LINHAS_TOLERANCIA As Long = 5

' Guard de auto-import: nome canonico que NUNCA pode ser importado
' por V3, nem que aparecesse no manifesto por engano.
Private Const IV3_NOME_PROPRIO As String = "Importador_V3"
Private Const IV3_NOME_BOOTSTRAP As String = "Importador_V3_Bootstrap"

' Estado do ultimo run
Private mIV3_LastStatus As String
Private mIV3_BackupDir As String

' V12.0.0203 ONDA 10 - Estado de override para runs delta.
' Quando ImportarPacoteV3_Delta e chamado, estes 3 campos sao setados
' por uma chamada e limpos no fim. IV3_RodarMain consulta esses campos
' para usar manifesto alternativo e disparar o bump de build label.
Private mIV3_OverrideManifesto As String
Private mIV3_OverrideBuildLabel As String
Private mIV3_DeltaName As String
Private mIV3_AllowModTypesC4 As Boolean


' ============================================================
' === API publica ===========================================
' ============================================================

Public Sub ImportarPacoteV3()
    Call IV3_RodarMain(False, "auto", "")
End Sub

Public Sub ImportarPacoteV3_Fresh()
    Call IV3_RodarMain(False, "fresh", "")
End Sub

Public Sub ImportarPacoteV3_DryRun()
    Call IV3_RodarMain(True, "auto", "")
End Sub

' V12.0.0203 ONDA 10 - Capacidade delta + bump auto de build label.
'
' Importa apenas os arquivos listados no manifesto delta correspondente
' a nomeDelta (ex.: nomeDelta="MICRO01" -> le manifesto
' local-ai\vba_import_v3_phase1\000-MANIFESTO-V3-DELTA-MICRO01.txt).
'
' Antes de processar os itens do manifesto, reescreve no espelho de
' disco as constantes APP_BUILD_IMPORTADO (= buildLabel) e
' APP_BUILD_GERADO_EM (= timestamp atual) em AAX-App_Release.bas.
' O proprio manifesto delta deve incluir AAX-App_Release.bas como
' ultimo item para garantir que o workbook receba o novo label.
'
' Backup automatico via fluxo padrao IV3_FazerBackupCompleto.
' Compile + trio continuam sendo gate manual do operador.
Public Sub ImportarPacoteV3_Delta(ByVal nomeDelta As String, _
                                   ByVal buildLabel As String)
    If Trim(nomeDelta) = "" Then
        MsgBox "ImportarPacoteV3_Delta: nomeDelta obrigatorio.", _
               vbCritical, "Importador V3"
        Exit Sub
    End If
    If Trim(buildLabel) = "" Then
        MsgBox "ImportarPacoteV3_Delta: buildLabel obrigatorio " & _
               "(auditoria por iteracao).", vbCritical, "Importador V3"
        Exit Sub
    End If

    ' Defensiva: limpa estado de qualquer override leftover
    mIV3_OverrideManifesto = ""
    mIV3_OverrideBuildLabel = ""
    mIV3_DeltaName = ""
    mIV3_AllowModTypesC4 = False

    mIV3_OverrideManifesto = IV3_DELTA_MANIFESTO_PREFIX & nomeDelta & IV3_DELTA_MANIFESTO_SUFFIX
    mIV3_OverrideBuildLabel = buildLabel
    mIV3_DeltaName = nomeDelta

    On Error GoTo limpar
    Call IV3_RodarMain(False, "auto", "")
limpar:
    mIV3_OverrideManifesto = ""
    mIV3_OverrideBuildLabel = ""
    mIV3_DeltaName = ""
    mIV3_AllowModTypesC4 = False
End Sub

' V12.0.0203 ONDA 18 - entrada C4 pre-aprovada.
'
' Igual a ImportarPacoteV3_Delta, mas permite reimportar Mod_Types em
' modo Estabilizado quando o delta foi explicitamente isolado e aprovado.
Public Sub ImportarPacoteV3_DeltaC4(ByVal nomeDelta As String, _
                                    ByVal buildLabel As String)
    If Trim(nomeDelta) = "" Then
        MsgBox "ImportarPacoteV3_DeltaC4: nomeDelta obrigatorio.", _
               vbCritical, "Importador V3"
        Exit Sub
    End If
    If Trim(buildLabel) = "" Then
        MsgBox "ImportarPacoteV3_DeltaC4: buildLabel obrigatorio.", _
               vbCritical, "Importador V3"
        Exit Sub
    End If
    If InStr(1, UCase$(nomeDelta), "MICRO25", vbTextCompare) = 0 Then
        MsgBox "ImportarPacoteV3_DeltaC4 bloqueado: use apenas para " & _
               "delta C4 pre-aprovado da Onda 18.", _
               vbCritical, "Importador V3"
        Exit Sub
    End If

    mIV3_OverrideManifesto = ""
    mIV3_OverrideBuildLabel = ""
    mIV3_DeltaName = ""
    mIV3_AllowModTypesC4 = False

    mIV3_OverrideManifesto = IV3_DELTA_MANIFESTO_PREFIX & nomeDelta & IV3_DELTA_MANIFESTO_SUFFIX
    mIV3_OverrideBuildLabel = buildLabel
    mIV3_DeltaName = nomeDelta
    mIV3_AllowModTypesC4 = True

    On Error GoTo limpar
    Call IV3_RodarMain(False, "auto", "")
limpar:
    mIV3_OverrideManifesto = ""
    mIV3_OverrideBuildLabel = ""
    mIV3_DeltaName = ""
    mIV3_AllowModTypesC4 = False
End Sub

' V12.0.0203 ONDA 10 - Bump standalone de build label.
'
' Atualiza apenas as constantes APP_BUILD_IMPORTADO e APP_BUILD_GERADO_EM
' em AAX-App_Release.bas (espelho de disco) e re-importa esse modulo
' para o workbook. Usado em Microdelta 1.0 para validar a capacidade
' delta sem efetuar import de codigo de producao.
'
' Reusa pipeline padrao IV3_ImportarModulo (Remove+Import com validacao
' por CountOfLines). Backup nao e disparado aqui - bump sozinho e
' considerado operacao de baixa criticidade (afeta so um modulo
' isolado de metadados). Para auditoria com backup, use
' ImportarPacoteV3_Delta apontando para um manifesto delta dedicado.
Public Sub IV3_BumpBuildLabel(ByVal buildLabel As String)
    Dim ok As Boolean

    If Trim(buildLabel) = "" Then
        MsgBox "IV3_BumpBuildLabel: buildLabel obrigatorio.", _
               vbCritical, "Importador V3"
        Exit Sub
    End If
    If Not IV3_ChecarVBOM() Then
        MsgBox "VBOM desabilitado. Habilite em: Excel > Preferences > " & _
               "Security > Trust Center > Trust access to VBA project " & _
               "object model.", vbCritical, "Importador V3"
        Exit Sub
    End If

    ok = IV3_AtualizarConstantesAppRelease(buildLabel)
    If Not ok Then
        MsgBox "Falha ao atualizar constantes em App_Release.bas " & _
               "(espelho). Veja IMPORT_LOG_V3.", _
               vbCritical, "Importador V3"
        Exit Sub
    End If

    ok = IV3_ReimportarAppRelease()
    If Not ok Then
        MsgBox "Falha ao re-importar App_Release.bas no workbook. " & _
               "Veja IMPORT_LOG_V3.", _
               vbCritical, "Importador V3"
        Exit Sub
    End If

    Call IV3_LogEvento("BUMP_BUILD_LABEL", "*", _
                        IV3_APP_RELEASE_REL_PATH, _
                        "novo build=" & buildLabel, "OK")

    MsgBox "Build label atualizado com sucesso." & vbCrLf & vbCrLf & _
           "Novo APP_BUILD_IMPORTADO = " & buildLabel & vbCrLf & vbCrLf & _
           "GATE MANUAL:" & vbCrLf & _
           "  1. VBE > Depurar > Compilar VBAProject (precisa passar limpo)" & vbCrLf & _
           "  2. Imediato: ?GetBuildImportado (deve retornar o novo label)" & vbCrLf & _
           "  3. CT_ValidarRelease_TrioMinimo (171/0+14/0+20/0)", _
           vbInformation, "Importador V3"
End Sub

Public Sub ImportarPacoteV3_Status()
    Debug.Print "=== ImportarPacoteV3_Status (" & IV3_VERSION & ") ==="
    If mIV3_LastStatus <> "" Then
        Debug.Print "ULTIMO RUN NESTA SESSAO:"
        Debug.Print mIV3_LastStatus
        Debug.Print ""
    Else
        Debug.Print "(nenhum import V3 executado nesta sessao)"
        Debug.Print ""
    End If

    Dim manifesto As String
    manifesto = ThisWorkbook.Path & Application.PathSeparator & _
                Replace(IV3_MANIFESTO_REL, "\", Application.PathSeparator)
    Debug.Print "MANIFESTO ESPERADO:"
    Debug.Print "  " & manifesto
    If Not IV3_ArquivoExiste(manifesto) Then
        Debug.Print "  STATUS: AUSENTE"
        Exit Sub
    End If
    Debug.Print "  STATUS: presente"
    Debug.Print ""

    Dim modoDetectado As String
    modoDetectado = IV3_DetectarModo()
    Debug.Print "MODO DETECTADO: " & modoDetectado
    Debug.Print "  (Estabilizado se VBComponents.Count > " & IV3_FRESH_THRESHOLD & "; Fresh caso contrario)"
End Sub


' ============================================================
' === Engine principal ======================================
' ============================================================

Private Sub IV3_RodarMain(ByVal dryRun As Boolean, _
                          ByVal modoForcado As String, _
                          ByVal grupoAlvo As String)
    Dim faseAtual As String
    Dim errNum As Long, errDesc As String, errSrc As String

    On Error GoTo falha

    faseAtual = "1_VBOM_CHECK"
    If Not IV3_ChecarVBOM() Then
        MsgBox "VBOM desabilitado. Habilite em: Excel > Preferences > Security > " & _
               "Trust Center > Trust access to VBA project object model.", _
               vbCritical, "Importador V3"
        Exit Sub
    End If

    faseAtual = "2_LOCALIZAR_MANIFESTO"
    Dim manifesto As String
    Dim manifestoRel As String
    ' V12.0.0203 ONDA 10 - se delta override esta setado, usa manifesto delta
    If mIV3_OverrideManifesto <> "" Then
        manifestoRel = mIV3_OverrideManifesto
    Else
        manifestoRel = IV3_MANIFESTO_REL
    End If
    manifesto = ThisWorkbook.Path & Application.PathSeparator & _
                Replace(manifestoRel, "\", Application.PathSeparator)
    If Not IV3_ArquivoExiste(manifesto) Then
        MsgBox "Manifesto V3 ausente: " & manifesto, vbCritical, "Importador V3"
        Exit Sub
    End If

    faseAtual = "3_DETECTAR_MODO"
    Dim modo As String
    If modoForcado = "fresh" Then
        modo = "Fresh"
    ElseIf modoForcado = "estabilizado" Then
        modo = "Estabilizado"
    Else
        modo = IV3_DetectarModo()
    End If

    faseAtual = "4_LER_MANIFESTO"
    Dim grupos() As String
    Dim totalGrupos As Long
    totalGrupos = IV3_LerManifesto(manifesto, grupos)
    If totalGrupos = 0 Then
        MsgBox "Manifesto vazio ou malformado.", vbCritical, "Importador V3"
        Exit Sub
    End If

    faseAtual = "5_BACKUP"
    If Not dryRun Then
        mIV3_BackupDir = IV3_FazerBackupCompleto()
        If mIV3_BackupDir = "" Then
            MsgBox "Backup pre-import falhou. Abortando.", vbCritical, "Importador V3"
            Exit Sub
        End If
        Call IV3_LogEvento("BACKUP", "*", mIV3_BackupDir, "Backup completo gerado", "OK")
    End If

    ' V12.0.0203 ONDA 10 - Bump auto de build label antes do processamento.
    ' Reescreve as constantes em AAX-App_Release.bas (espelho) ANTES dos
    ' itens do manifesto serem processados. O proprio manifesto delta deve
    ' incluir AAX-App_Release.bas como ultimo item para que o workbook
    ' receba o novo label durante o run.
    faseAtual = "5b_BUMP_BUILD_LABEL"
    If mIV3_OverrideBuildLabel <> "" And Not dryRun Then
        If Not IV3_AtualizarConstantesAppRelease(mIV3_OverrideBuildLabel) Then
            MsgBox "Falha ao atualizar build label em App_Release.bas. " & _
                   "Abortando delta. Veja IMPORT_LOG_V3.", _
                   vbCritical, "Importador V3"
            Exit Sub
        End If
        Call IV3_LogEvento("BUMP_BUILD_LABEL", "*", _
                            IV3_APP_RELEASE_REL_PATH, _
                            "delta=" & mIV3_DeltaName & _
                            " | build=" & mIV3_OverrideBuildLabel, "OK")
    End If

    ' Nota: V3 NAO chama mais Application.VBE.ActiveVBProject.Compile
    ' programaticamente. A API retorna erro 438 no Excel Windows em certas
    ' versoes, mesmo quando o workbook compila normalmente via menu manual.
    ' A protecao da V3 e por validacao de CountOfLines apos cada Import.
    ' O gate final fica com o operador: Debug > Compile + trio minimo.

    faseAtual = "6_PROCESSAR_GRUPOS"
    Dim totalImportadosM As Long, totalImportadosF As Long
    Dim totalErros As Long, totalSkips As Long
    Dim resultado As Boolean
    resultado = IV3_ProcessarGrupos(grupos, modo, dryRun, grupoAlvo, _
                                     totalImportadosM, totalImportadosF, _
                                     totalErros, totalSkips)

    faseAtual = "7_LOG_FIM"
    Dim resumo As String
    resumo = "modo=" & modo & " | dryRun=" & dryRun & " | M=" & totalImportadosM & _
             " | F=" & totalImportadosF & " | err=" & totalErros & " | skip=" & totalSkips
    mIV3_LastStatus = resumo
    Call IV3_LogEvento("FIM", "*", manifesto, resumo, IIf(resultado, "OK", "FALHA"))

    If resultado Then
        MsgBox "Importador V3 concluiu o import OK." & vbCrLf & resumo & vbCrLf & vbCrLf & _
               "GATE FINAL (manual - V3 NAO faz compile programatico):" & vbCrLf & _
               "  1. VBE > Depurar > Compilar VBAProject (precisa passar limpo)" & vbCrLf & _
               "  2. Imediato: CT_ValidarRelease_TrioMinimo (precisa retornar 171/0+14/0+20/0)" & vbCrLf & vbCrLf & _
               "Se o passo 1 falhar, NAO salve o workbook. Restaure do backup em:" & vbCrLf & _
               "  " & mIV3_BackupDir, _
               vbInformation, "Importador V3"
    Else
        MsgBox "Importador V3 falhou na fase: " & faseAtual & vbCrLf & resumo & vbCrLf & vbCrLf & _
               "Backup disponivel em:" & vbCrLf & "  " & mIV3_BackupDir, _
               vbCritical, "Importador V3"
    End If
    Exit Sub

falha:
    errNum = Err.Number
    errDesc = Err.Description
    errSrc = Err.Source
    Call IV3_LogEvento("ERRO_FATAL", faseAtual, "", _
                        "Err=" & errNum & " | " & errDesc & " | src=" & errSrc, "FALHA")
    MsgBox "Importador V3 erro fatal." & vbCrLf & _
           "Fase: " & faseAtual & vbCrLf & _
           "Err: " & errNum & " - " & errDesc & vbCrLf & _
           "Src: " & errSrc & vbCrLf & vbCrLf & _
           "Backup em: " & mIV3_BackupDir, _
           vbCritical, "Importador V3"
End Sub


' ============================================================
' === Deteccao de modo ======================================
' ============================================================

Private Function IV3_DetectarModo() As String
    Dim p As Object
    Set p = Application.VBE.ActiveVBProject
    Dim contagemSignif As Long
    Dim c As Object
    For Each c In p.VBComponents
        ' Conta apenas StdModule, ClassModule, MSForm
        ' (ignora Documents - ThisWorkbook, Sheet1, etc.)
        If c.Type <> IV3_VBEXT_CT_DOCUMENT Then
            contagemSignif = contagemSignif + 1
        End If
    Next c
    If contagemSignif <= IV3_FRESH_THRESHOLD Then
        IV3_DetectarModo = "Fresh"
    Else
        IV3_DetectarModo = "Estabilizado"
    End If
End Function


' ============================================================
' === Leitura do manifesto ==================================
' ============================================================
'
' Manifesto V3 segue o formato V2:
'   - Linha em branco separa GRUPOS
'   - # comeca comentario
'   - M|caminho-relativo .bas  ou  F|caminho-relativo .frm
'   - Header sugerido: # GRUPO_NOME ...
'
' Retorna array de strings serializadas no formato:
'   "GRUPO_NOME~ITEM1|ITEM2|...|ITEMn"
' onde cada ITEM e da forma "M|001-modulo/AAA-Mod_Types.bas".

Private Function IV3_LerManifesto(ByVal caminho As String, _
                                   ByRef grupos() As String) As Long
    Dim conteudo As String
    conteudo = IV3_LerArquivoBinarioComoTexto(caminho)

    Dim linhas() As String
    linhas = Split(conteudo, vbCrLf)

    Dim grupoNome As String
    Dim grupoItens As String
    Dim listaGrupos() As String
    ReDim listaGrupos(0 To 100)
    Dim qtdGrupos As Long
    qtdGrupos = 0
    grupoNome = ""
    grupoItens = ""

    Dim i As Long
    For i = LBound(linhas) To UBound(linhas)
        Dim linha As String
        linha = Trim(linhas(i))
        If Len(linha) = 0 Then
            ' Linha em branco = fim de grupo
            If Len(grupoItens) > 0 Then
                listaGrupos(qtdGrupos) = grupoNome & "~" & grupoItens
                qtdGrupos = qtdGrupos + 1
                grupoNome = ""
                grupoItens = ""
            End If
        ElseIf Left(linha, 1) = "#" Then
            ' Comentario / header de grupo
            Dim comentario As String
            comentario = Trim(Mid(linha, 2))
            If InStr(1, UCase(comentario), "GRUPO_") = 1 Then
                grupoNome = Split(comentario, " ")(0)
            End If
        ElseIf Left(linha, 2) = "M|" Or Left(linha, 2) = "F|" Then
            If Len(grupoItens) > 0 Then
                grupoItens = grupoItens & "##"
            End If
            grupoItens = grupoItens & linha
        End If
    Next i

    ' Flush grupo final
    If Len(grupoItens) > 0 Then
        listaGrupos(qtdGrupos) = grupoNome & "~" & grupoItens
        qtdGrupos = qtdGrupos + 1
    End If

    If qtdGrupos = 0 Then
        IV3_LerManifesto = 0
        Exit Function
    End If

    ReDim grupos(0 To qtdGrupos - 1)
    For i = 0 To qtdGrupos - 1
        grupos(i) = listaGrupos(i)
    Next i
    IV3_LerManifesto = qtdGrupos
End Function


' ============================================================
' === Processamento de grupos ===============================
' ============================================================

Private Function IV3_ProcessarGrupos(ByRef grupos() As String, _
                                      ByVal modo As String, _
                                      ByVal dryRun As Boolean, _
                                      ByVal grupoAlvo As String, _
                                      ByRef totalM As Long, _
                                      ByRef totalF As Long, _
                                      ByRef totalErros As Long, _
                                      ByRef totalSkips As Long) As Boolean
    Dim g As Long
    For g = LBound(grupos) To UBound(grupos)
        Dim partes() As String
        partes = Split(grupos(g), "~")
        Dim nomeGrupo As String
        nomeGrupo = partes(0)
        Dim itensSerial As String
        itensSerial = partes(1)
        Dim itens() As String
        itens = Split(itensSerial, "##")

        If grupoAlvo <> "" And UCase(grupoAlvo) <> UCase(nomeGrupo) Then
            ' Pular grupos nao alvo
            GoTo proxGrupo
        End If

        Call IV3_LogEvento("GRUPO_INICIO", nomeGrupo, "", _
                            "itens=" & (UBound(itens) - LBound(itens) + 1), "OK")

        Dim i As Long
        Dim importadosNoGrupo As Long
        importadosNoGrupo = 0
        For i = LBound(itens) To UBound(itens)
            Dim resultadoItem As String
            resultadoItem = IV3_ProcessarItem(itens(i), modo, dryRun, nomeGrupo)
            Select Case resultadoItem
                Case "OK_M"
                    totalM = totalM + 1
                    importadosNoGrupo = importadosNoGrupo + 1
                Case "OK_F"
                    totalF = totalF + 1
                    importadosNoGrupo = importadosNoGrupo + 1
                Case "SKIP"
                    totalSkips = totalSkips + 1
                Case "FALHA"
                    totalErros = totalErros + 1
                    IV3_ProcessarGrupos = False
                    Call IV3_LogEvento("GRUPO_FIM", nomeGrupo, "", _
                                        "abort em item " & itens(i), "FALHA")
                    Exit Function
            End Select
        Next i

        ' Compile-after-each-group REMOVIDO em Fix #6: API VBProject.Compile
        ' nao e estavel no Excel Windows (erro 438). V3 confia na validacao
        ' por CountOfLines apos cada Import (ja feita em IV3_ImportarModulo).
        ' Gate final fica manual: operador roda Debug > Compile + trio minimo.
        Call IV3_LogEvento("GRUPO_FIM", nomeGrupo, "", _
                            "importados=" & importadosNoGrupo & " (compile-check manual no fim)", "OK")
proxGrupo:
    Next g
    IV3_ProcessarGrupos = True
End Function


' ============================================================
' === Processamento de UM item ==============================
' ============================================================
'
' itemSerial: "M|001-modulo/AAA-Mod_Types.bas" ou "F|002-formularios/AAA-Fundo_Branco.frm"
' Retorna: "OK_M", "OK_F", "SKIP", "FALHA"

Private Function IV3_ProcessarItem(ByVal itemSerial As String, _
                                    ByVal modo As String, _
                                    ByVal dryRun As Boolean, _
                                    ByVal nomeGrupo As String) As String
    Dim tipo As String, caminhoRel As String
    tipo = Left(itemSerial, 1)
    caminhoRel = Mid(itemSerial, 3)

    ' Monta caminho absoluto: ThisWorkbook.Path + IV3_VBA_IMPORT_DIR_REL + caminhoRel
    ' Manifesto tem paths como "001-modulo/AAA-Mod_Types.bas" relativos a pasta
    ' de import (vba_import_v3_phase1/). Workbook fica em uma pasta acima.
    '
    ' Preserva prefixo UNC (\\) do Windows: se ThisWorkbook.Path comeca com
    ' "\\" (UNC), o normalizador de separadores duplicados deve preservar os
    ' dois primeiros caracteres.
    Dim caminhoAbs As String
    Dim sep As String
    sep = Application.PathSeparator
    caminhoAbs = ThisWorkbook.Path & sep & _
                 Replace(IV3_VBA_IMPORT_DIR_REL, "\", sep) & _
                 Replace(caminhoRel, "/", sep)
    caminhoAbs = Replace(caminhoAbs, "\", sep)

    ' Detecta e protege prefixo UNC antes do colapso de duplicatas
    Dim prefixoUNC As String
    prefixoUNC = ""
    If sep = "\" And Len(caminhoAbs) >= 2 Then
        If Left(caminhoAbs, 2) = "\\" Then
            prefixoUNC = "\\"
            caminhoAbs = Mid(caminhoAbs, 3)
        End If
    End If

    ' Colapsa separadores duplicados internos (ex.: trailing sep do IV3_VBA_IMPORT_DIR_REL)
    Do While InStr(caminhoAbs, sep & sep) > 0
        caminhoAbs = Replace(caminhoAbs, sep & sep, sep)
    Loop

    ' Restaura prefixo UNC
    caminhoAbs = prefixoUNC & caminhoAbs

    If Not IV3_ArquivoExiste(caminhoAbs) Then
        Call IV3_LogEvento("MISSING_FILE", nomeGrupo, caminhoAbs, _
                            "Arquivo do manifesto nao existe", "FALHA")
        IV3_ProcessarItem = "FALHA"
        Exit Function
    End If

    ' Deduzir nome canonico do componente (sem prefixo AAA-)
    Dim nomeComponente As String
    nomeComponente = IV3_NomeCanonico(caminhoAbs)

    ' Guard anti-auto-import (defesa contra manifesto malformado).
    ' V3 NUNCA pode importar a si mesmo nem o Bootstrap descartavel.
    If StrComp(nomeComponente, IV3_NOME_PROPRIO, vbTextCompare) = 0 Or _
       StrComp(nomeComponente, IV3_NOME_BOOTSTRAP, vbTextCompare) = 0 Then
        Call IV3_LogEvento("AUTO_IMPORT_BLOQUEADO", nomeGrupo, caminhoAbs, _
                            "Tentativa de auto-import bloqueada por guard: " & _
                            nomeComponente & " nunca deve estar no manifesto V3", "SKIP")
        IV3_ProcessarItem = "SKIP"
        Exit Function
    End If

    ' Tabu Mod_Types
    If StrComp(nomeComponente, IV3_MOD_TYPES_NAME, vbTextCompare) = 0 Then
        If modo = "Estabilizado" Then
            If IV3_ComponenteExiste(nomeComponente) Then
                If Not mIV3_AllowModTypesC4 Then
                    ' Skip se ja existe (independente de hash por agora; v3.1 podera comparar hash)
                    Call IV3_LogEvento("MOD_TYPES_SKIP", nomeGrupo, caminhoAbs, _
                                        "Mod_Types ja presente em modo Estabilizado", "SKIP")
                    IV3_ProcessarItem = "SKIP"
                    Exit Function
                End If
                Call IV3_LogEvento("MOD_TYPES_C4_ALLOW", nomeGrupo, caminhoAbs, _
                                    "Delta C4 pre-aprovado: " & mIV3_DeltaName, "OK")
            End If
            ' Caso raro: estabilizado mas sem Mod_Types -> importa
        End If
        ' Modo Fresh: importa normalmente
    End If

    If dryRun Then
        Call IV3_LogEvento("DRYRUN_ITEM", nomeGrupo, caminhoAbs, _
                            "Simularia import de " & nomeComponente, "OK")
        IV3_ProcessarItem = IIf(tipo = "M", "OK_M", "OK_F")
        Exit Function
    End If

    Dim sucesso As Boolean
    If tipo = "M" Then
        sucesso = IV3_ImportarModulo(caminhoAbs, nomeComponente, modo, nomeGrupo)
        IV3_ProcessarItem = IIf(sucesso, "OK_M", "FALHA")
    ElseIf tipo = "F" Then
        sucesso = IV3_ImportarForm(caminhoAbs, nomeComponente, modo, nomeGrupo)
        IV3_ProcessarItem = IIf(sucesso, "OK_F", "FALHA")
    Else
        Call IV3_LogEvento("TIPO_INVALIDO", nomeGrupo, caminhoAbs, _
                            "Tipo desconhecido: " & tipo, "FALHA")
        IV3_ProcessarItem = "FALHA"
    End If
End Function


' ============================================================
' === Import de MODULO (.bas) ===============================
' ============================================================
'
' Estrategia unica em V3: Remove (se existe) + Import. Sempre.
' NAO usa DeleteLines+AddFromString in-place (bug Mac SMB historico).
' NAO usa Add+AddFromString (cria modulo paralelo se Remove falhar).

Private Function IV3_ImportarModulo(ByVal caminho As String, _
                                     ByVal nomeComp As String, _
                                     ByVal modo As String, _
                                     ByVal nomeGrupo As String) As Boolean
    On Error GoTo falhaModulo

    Dim p As Object
    Set p = Application.VBE.ActiveVBProject

    ' 1. Linhas esperadas (lidas do source antes de qualquer modificacao)
    Dim linhasEsperadas As Long
    linhasEsperadas = IV3_ContarLinhasArquivo(caminho)
    If linhasEsperadas <= 0 Then
        Call IV3_LogEvento("CONTAR_LINHAS", nomeGrupo, caminho, _
                            "Falha ao contar linhas do arquivo source", "FALHA")
        IV3_ImportarModulo = False
        Exit Function
    End If

    ' 2. Remover componente existente
    If IV3_ComponenteExiste(nomeComp) Then
        Dim cExistente As Object
        Set cExistente = p.VBComponents(nomeComp)
        p.VBComponents.Remove cExistente

        ' Validar Remove (defesa contra Mac SMB silencioso)
        If IV3_ComponenteExiste(nomeComp) Then
            Call IV3_LogEvento("REMOVE_FALHOU", nomeGrupo, caminho, _
                                "Remove de " & nomeComp & " nao surtiu efeito", "FALHA")
            IV3_ImportarModulo = False
            Exit Function
        End If
    End If

    ' 3. Import do arquivo
    Dim cNovo As Object
    Set cNovo = p.VBComponents.Import(caminho)

    ' 4. Validar nome do componente importado
    If StrComp(cNovo.Name, nomeComp, vbTextCompare) <> 0 Then
        ' Renomear (.bas com Attribute VB_Name correto deveria preservar; defesa)
        cNovo.Name = nomeComp
    End If

    ' 5. Validar CountOfLines vs esperado
    Dim linhasReais As Long
    linhasReais = cNovo.CodeModule.CountOfLines
    Dim diff As Long
    diff = Abs(linhasReais - linhasEsperadas)
    If diff > IV3_LINHAS_TOLERANCIA Then
        Call IV3_LogEvento("VALIDACAO_LINHAS", nomeGrupo, caminho, _
                            "esperado=" & linhasEsperadas & _
                            " real=" & linhasReais & _
                            " diff=" & diff & " (tolerancia=" & _
                            IV3_LINHAS_TOLERANCIA & ")", "FALHA")
        IV3_ImportarModulo = False
        Exit Function
    End If

    Call IV3_LogEvento("MODULO_OK", nomeGrupo, caminho, _
                        nomeComp & " (" & linhasReais & " linhas)", "OK")
    IV3_ImportarModulo = True
    Exit Function

falhaModulo:
    Call IV3_LogEvento("MODULO_ERRO", nomeGrupo, caminho, _
                        "Err=" & Err.Number & " | " & Err.Description, "FALHA")
    IV3_ImportarModulo = False
End Function


' ============================================================
' === Import de FORM (.frm + .frx ou .code-only.txt) ========
' ============================================================
'
' Modo Fresh: Import .frm (carrega .frx automaticamente).
' Modo Estabilizado: substituir codigo via .code-only.txt preserva
'   .frx do designer (renomeacoes, controles, layout).

Private Function IV3_ImportarForm(ByVal caminhoFrm As String, _
                                   ByVal nomeComp As String, _
                                   ByVal modo As String, _
                                   ByVal nomeGrupo As String) As Boolean
    On Error GoTo falhaForm

    Dim p As Object
    Set p = Application.VBE.ActiveVBProject

    If modo = "Fresh" Then
        ' Modo Fresh: import .frm + .frx via API VBE
        ' Pre-condicao: componente NAO existe (workbook fresh)
        If IV3_ComponenteExiste(nomeComp) Then
            ' Inesperado em Fresh - remove e segue
            Dim cExist As Object
            Set cExist = p.VBComponents(nomeComp)
            p.VBComponents.Remove cExist
        End If
        p.VBComponents.Import caminhoFrm
        Call IV3_LogEvento("FORM_FRESH_OK", nomeGrupo, caminhoFrm, nomeComp, "OK")
        IV3_ImportarForm = True
        Exit Function
    End If

    ' Modo Estabilizado: substitui codigo via .code-only.txt preservando .frx.
    ' Bug historico V2 com Mac SMB: cm.DeleteLines + cm.AddFromString em uma
    ' unica chamada NAO zera o CodeModule completamente, deixando residuo
    ' que se duplica com o AddFromString seguinte. Mitigacao em V3:
    '   - loop DeleteLines ate CountOfLines == 0 (com limite de tentativas)
    '   - validacao agressiva pos-AddFromString (tolerancia 0)
    '   - falha em qualquer ponto = abort sem fallback silencioso
    Dim codeOnly As String
    codeOnly = IV3_DerivarCodeOnlyPath(caminhoFrm)
    If Not IV3_ArquivoExiste(codeOnly) Then
        Call IV3_LogEvento("CODE_ONLY_AUSENTE", nomeGrupo, codeOnly, _
                            "Form em modo Estabilizado exige .code-only.txt", "FALHA")
        IV3_ImportarForm = False
        Exit Function
    End If

    If Not IV3_ComponenteExiste(nomeComp) Then
        ' Form nao existe no workbook estabilizado - inesperado
        ' Fallback: importa .frm + .frx (carrega designer do disco)
        Call IV3_LogEvento("FORM_AUSENTE_FALLBACK", nomeGrupo, caminhoFrm, _
                            "Form " & nomeComp & " nao existia em Estabilizado, fallback Fresh", "WARN")
        p.VBComponents.Import caminhoFrm
        Call IV3_LogEvento("FORM_OK", nomeGrupo, caminhoFrm, nomeComp, "OK")
        IV3_ImportarForm = True
        Exit Function
    End If

    ' Substituir codigo do form preservando .frx
    Dim cForm As Object
    Set cForm = p.VBComponents(nomeComp)
    Dim cm As Object
    Set cm = cForm.CodeModule
    Dim conteudo As String
    conteudo = IV3_LerArquivoBinarioComoTexto(codeOnly)

    ' Strip per-symbol Attribute lines (Fix #7).
    ' Linhas como "Attribute X.VB_VarHelpID = -1" sao validas em .frm
    ' (processadas por VBComponents.Import) mas geram "Erro de sintaxe"
    ' quando passadas a cm.AddFromString. VBE regenera os defaults
    ' automaticamente quando precisar.
    conteudo = IV3_LimparAtributosCodeOnly(conteudo)

    ' 1. Loop DeleteLines ate CountOfLines == 0 (defesa Mac SMB).
    Dim antesLines As Long
    antesLines = cm.CountOfLines
    Dim tentDel As Long
    tentDel = 0
    Do While cm.CountOfLines > 0 And tentDel < 10
        cm.DeleteLines 1, cm.CountOfLines
        tentDel = tentDel + 1
    Loop
    If cm.CountOfLines > 0 Then
        Call IV3_LogEvento("FORM_DELETE_FALHOU", nomeGrupo, codeOnly, _
                            "DeleteLines nao zerou apos " & tentDel & _
                            " tentativas (CountOfLines=" & cm.CountOfLines & ")", "FALHA")
        IV3_ImportarForm = False
        Exit Function
    End If

    ' 2. AddFromString com o novo conteudo (ja limpo de Attribute lines)
    cm.AddFromString conteudo

    ' 3. Validacao AGRESSIVA pos-AddFromString.
    ' linhasEsperadas e contado a partir do CONTEUDO LIMPO (apos strip de
    ' Attribute), nao do arquivo bruto, para nao gerar false-failure quando
    ' o .code-only.txt tem muitas Attribute lines per-symbol.
    Dim linhasEsperadas As Long
    Dim arrLinhas() As String
    arrLinhas = Split(conteudo, vbCrLf)
    linhasEsperadas = UBound(arrLinhas) - LBound(arrLinhas) + 1
    If linhasEsperadas > 0 Then
        If arrLinhas(UBound(arrLinhas)) = "" Then linhasEsperadas = linhasEsperadas - 1
    End If

    Dim linhasReais As Long
    linhasReais = cm.CountOfLines
    Dim diff As Long
    diff = Abs(linhasReais - linhasEsperadas)
    If diff > IV3_LINHAS_TOLERANCIA Then
        Call IV3_LogEvento("FORM_VALIDACAO", nomeGrupo, codeOnly, _
                            "esperado=" & linhasEsperadas & _
                            " real=" & linhasReais & _
                            " diff=" & diff & " antesDelete=" & antesLines & _
                            " tentDel=" & tentDel, "FALHA")
        IV3_ImportarForm = False
        Exit Function
    End If

    Call IV3_LogEvento("FORM_ESTAB_OK", nomeGrupo, codeOnly, _
                        nomeComp & " (" & linhasReais & " linhas, " & _
                        tentDel & "x DeleteLines)", "OK")
    IV3_ImportarForm = True
    Exit Function

falhaForm:
    Call IV3_LogEvento("FORM_ERRO", nomeGrupo, caminhoFrm, _
                        "Err=" & Err.Number & " | " & Err.Description, "FALHA")
    IV3_ImportarForm = False
End Function


' ============================================================
' === Helpers ===============================================
' ============================================================

Private Function IV3_ChecarVBOM() As Boolean
    On Error Resume Next
    Dim p As Object
    Set p = Application.VBE.ActiveVBProject
    IV3_ChecarVBOM = (Not p Is Nothing)
    On Error GoTo 0
End Function

Private Function IV3_ArquivoExiste(ByVal caminho As String) As Boolean
    Dim resultado As String
    On Error Resume Next
    resultado = Dir(caminho)
    IV3_ArquivoExiste = (Len(resultado) > 0 And Err.Number = 0)
    On Error GoTo 0
End Function

Private Function IV3_ComponenteExiste(ByVal nome As String) As Boolean
    On Error Resume Next
    Dim p As Object
    Set p = Application.VBE.ActiveVBProject
    Dim c As Object
    Set c = p.VBComponents(nome)
    IV3_ComponenteExiste = (Not c Is Nothing And Err.Number = 0)
    On Error GoTo 0
End Function

' Deriva nome canonico do componente a partir do caminho.
' Ex.: ".../AAA-Mod_Types.bas" -> "Mod_Types"
'      ".../AAJ-Limpar_Base.frm" -> "Limpar_Base"
'      ".../Util_Conversao.bas"  -> "Util_Conversao" (sem prefixo)
Private Function IV3_NomeCanonico(ByVal caminho As String) As String
    Dim nome As String
    nome = Dir(caminho)
    ' Remove extensao
    Dim p As Long
    p = InStrRev(nome, ".")
    If p > 0 Then nome = Left(nome, p - 1)
    ' Remove prefixo AAA-, AAB-, ..., ABZ-, etc. (3 letras + hifen)
    If Len(nome) >= 4 Then
        If Mid(nome, 4, 1) = "-" And IsLetter(Mid(nome, 1, 1)) And _
           IsLetter(Mid(nome, 2, 1)) And IsLetter(Mid(nome, 3, 1)) Then
            nome = Mid(nome, 5)
        End If
    End If
    IV3_NomeCanonico = nome
End Function

Private Function IsLetter(ByVal s As String) As Boolean
    If Len(s) <> 1 Then
        IsLetter = False
        Exit Function
    End If
    Dim a As Integer
    a = Asc(UCase(s))
    IsLetter = (a >= 65 And a <= 90)
End Function

' Deriva caminho do .code-only.txt a partir do .frm
' Ex.: ".../AAJ-Limpar_Base.frm" -> ".../AAJ-Limpar_Base.code-only.txt"
Private Function IV3_DerivarCodeOnlyPath(ByVal caminhoFrm As String) As String
    Dim p As Long
    p = InStrRev(caminhoFrm, ".")
    If p > 0 Then
        IV3_DerivarCodeOnlyPath = Left(caminhoFrm, p - 1) & ".code-only.txt"
    Else
        IV3_DerivarCodeOnlyPath = caminhoFrm & ".code-only.txt"
    End If
End Function

' Le arquivo binario, normaliza EOL para CRLF, garante terminal vbCrLf.
' Resolve bug historico: Line Input no Mac le manifesto inteiro como
' uma linha quando EOL nao e nativo. Tambem remove BOM UTF-8 se presente.
Private Function IV3_LerArquivoBinarioComoTexto(ByVal caminho As String) As String
    Dim fNum As Integer
    Dim raw As String
    fNum = FreeFile
    Open caminho For Binary Access Read As #fNum
    raw = Space(LOF(fNum))
    If LOF(fNum) > 0 Then Get #fNum, , raw
    Close #fNum

    ' Remove BOM UTF-8 se presente (3 bytes: EF BB BF)
    If Len(raw) >= 3 Then
        If Asc(Mid(raw, 1, 1)) = 239 And Asc(Mid(raw, 2, 1)) = 187 And _
           Asc(Mid(raw, 3, 1)) = 191 Then
            raw = Mid(raw, 4)
        End If
    End If

    ' Normaliza CRLF/CR/LF -> CRLF
    raw = Replace(raw, vbCrLf, vbLf)
    raw = Replace(raw, vbCr, vbLf)
    raw = Replace(raw, vbLf, vbCrLf)

    ' Garante terminal CRLF (licao a: ultima linha em branco)
    If Len(raw) >= 2 Then
        If Right(raw, 2) <> vbCrLf Then raw = raw & vbCrLf
    Else
        raw = raw & vbCrLf
    End If

    IV3_LerArquivoBinarioComoTexto = raw
End Function

' Remove linhas que comecam com "Attribute " do conteudo de um form code-only.txt.
' Per-symbol Attribute (ex.: "Attribute X.VB_VarHelpID = -1") aparece em arquivos
' .frm exportados mas nao e aceito por cm.AddFromString - gera "Erro de sintaxe".
' VBE regenera defaults automaticamente quando o form e usado em runtime.
' Form-level Attribute (VB_Name, VB_GlobalNameSpace, etc.) nao deveria aparecer
' aqui pois o extrator de .code-only.txt ja descarta o cabecalho do .frm; mesmo
' assim, este helper protege contra qualquer Attribute residual.
Private Function IV3_LimparAtributosCodeOnly(ByVal conteudo As String) As String
    Dim linhas() As String
    linhas = Split(conteudo, vbCrLf)
    Dim resultado As String
    Dim i As Long
    Dim removidas As Long
    removidas = 0
    For i = LBound(linhas) To UBound(linhas)
        Dim trimmed As String
        trimmed = LTrim(linhas(i))
        If Len(trimmed) >= 10 Then
            If LCase(Left(trimmed, 10)) = "attribute " Then
                removidas = removidas + 1
                GoTo proxima
            End If
        End If
        If Len(resultado) > 0 Then
            resultado = resultado & vbCrLf
        End If
        resultado = resultado & linhas(i)
proxima:
    Next i
    If Len(resultado) > 0 Then
        If Right(resultado, 2) <> vbCrLf Then resultado = resultado & vbCrLf
    End If
    If removidas > 0 Then
        Debug.Print "[V3 FORM] Removidas " & removidas & " linha(s) Attribute do conteudo"
    End If
    IV3_LimparAtributosCodeOnly = resultado
End Function

Private Function IV3_ContarLinhasArquivo(ByVal caminho As String) As Long
    Dim conteudo As String
    conteudo = IV3_LerArquivoBinarioComoTexto(caminho)
    Dim linhas() As String
    linhas = Split(conteudo, vbCrLf)
    ' Remove a ultima entrada vazia (vem do terminal vbCrLf garantido)
    Dim n As Long
    n = UBound(linhas) - LBound(linhas) + 1
    If n > 0 Then
        If linhas(UBound(linhas)) = "" Then n = n - 1
    End If
    IV3_ContarLinhasArquivo = n
End Function

Private Function IV3_CompilarVBProject() As Boolean
    Dim e As Long, eDesc As String, eSrc As String
    On Error Resume Next
    Err.Clear
    Application.VBE.ActiveVBProject.Compile
    e = Err.Number
    eDesc = Err.Description
    eSrc = Err.Source
    On Error GoTo 0

    If e <> 0 Then
        Debug.Print "[V3 COMPILE FAIL] err=" & e & " | desc='" & eDesc & _
                    "' | src='" & eSrc & "'"
        Debug.Print "  Para investigar manualmente: VBE > Depurar > Compilar VBAProject"
        IV3_CompilarVBProject = False
    Else
        IV3_CompilarVBProject = True
    End If
End Function

' Backup completo do projeto VBA antes de qualquer Remove em modo real.
' Cria pastas recursivamente (backups/, backups/vba/, backups/vba/<ts>-V3-FULL/)
' usando helper IV3_GarantirPasta que tolera "ja existe" (Err 75) mas falha
' real em qualquer outro erro. Cada passo e logado via Debug.Print para que
' o operador possa colar a janela Imediata em caso de falha.
'
' Mudanca apos diagnostico de Phase 1 run #1 em workbook fresh (2026-05-01):
'   - cria parent dirs recursivamente (problema do bug: MkDir aninhado em
'     backups\vba\ falhava se backups\ nao existir)
'   - log verboso de cada passo
'   - tratamento explicito de Err 75 (ja existe) e 76 (path nao encontrado)
Private Function IV3_FazerBackupCompleto() As String
    Dim ts As String
    ts = Format(Now, "yyyymmdd_hhmmss")
    Dim sep As String
    sep = Application.PathSeparator

    Dim wbPath As String
    wbPath = ThisWorkbook.Path
    If Len(wbPath) > 0 Then
        If Right(wbPath, 1) = sep Then wbPath = Left(wbPath, Len(wbPath) - 1)
    End If

    ' Constroi os 3 niveis de pasta sem trailing separator
    Dim dirBackups As String, dirVba As String, dirDest As String
    dirBackups = wbPath & sep & "backups"
    dirVba = dirBackups & sep & "vba"
    dirDest = dirVba & sep & ts & "-V3-FULL"

    Debug.Print "[V3 BACKUP] paths:"
    Debug.Print "  workbook = " & wbPath
    Debug.Print "  backups  = " & dirBackups
    Debug.Print "  vba      = " & dirVba
    Debug.Print "  dest     = " & dirDest

    ' Cria cada nivel recursivamente. Aborta na primeira falha real.
    If Not IV3_GarantirPasta(dirBackups) Then
        Debug.Print "[V3 BACKUP FAIL] Nao consegui criar/encontrar pasta backups: " & dirBackups
        IV3_FazerBackupCompleto = ""
        Exit Function
    End If
    If Not IV3_GarantirPasta(dirVba) Then
        Debug.Print "[V3 BACKUP FAIL] Nao consegui criar/encontrar pasta vba: " & dirVba
        IV3_FazerBackupCompleto = ""
        Exit Function
    End If
    If Not IV3_GarantirPasta(dirDest) Then
        Debug.Print "[V3 BACKUP FAIL] Nao consegui criar/encontrar pasta dest: " & dirDest
        IV3_FazerBackupCompleto = ""
        Exit Function
    End If

    Debug.Print "[V3 BACKUP] Pastas OK. Iniciando export dos componentes..."

    ' Exporta cada componente significativo, contando sucessos e falhas
    Dim p As Object
    Set p = Application.VBE.ActiveVBProject
    Dim c As Object
    Dim exportadosOk As Long, exportadosFail As Long
    exportadosOk = 0
    exportadosFail = 0

    For Each c In p.VBComponents
        If c.Type <> IV3_VBEXT_CT_DOCUMENT Then
            Dim ext As String
            Select Case c.Type
                Case IV3_VBEXT_CT_STDMODULE: ext = ".bas"
                Case IV3_VBEXT_CT_CLASSMODULE: ext = ".cls"
                Case IV3_VBEXT_CT_MSFORM: ext = ".frm"
                Case Else: ext = ".bas"
            End Select
            On Error Resume Next
            Err.Clear
            c.Export dirDest & sep & c.Name & ext
            If Err.Number <> 0 Then
                exportadosFail = exportadosFail + 1
                Debug.Print "[V3 BACKUP] EXPORT FAIL: " & c.Name & _
                            " err=" & Err.Number & " " & Err.Description
                Err.Clear
            Else
                exportadosOk = exportadosOk + 1
            End If
            On Error GoTo 0
        End If
    Next c

    Debug.Print "[V3 BACKUP] Exports: ok=" & exportadosOk & " fail=" & exportadosFail

    If exportadosOk = 0 Then
        Debug.Print "[V3 BACKUP FAIL] Zero exports OK em " & dirDest
        IV3_FazerBackupCompleto = ""
        Exit Function
    End If

    Debug.Print "[V3 BACKUP OK] dest = " & dirDest
    IV3_FazerBackupCompleto = dirDest
End Function

' Garante que uma pasta exista. Cria se ausente; aceita Err 75 (ja existe)
' como sucesso. Verifica via Dir apos MkDir para detectar criacao silenciosa
' bem-sucedida em SMB/UNC. Loga falhas reais para debug.
Private Function IV3_GarantirPasta(ByVal caminho As String) As Boolean
    Dim existe As Boolean
    On Error Resume Next
    Err.Clear
    existe = (Dir(caminho, vbDirectory) <> "")
    Err.Clear
    On Error GoTo 0

    If existe Then
        IV3_GarantirPasta = True
        Exit Function
    End If

    ' Tenta criar
    Dim e As Long, eDesc As String
    On Error Resume Next
    Err.Clear
    MkDir caminho
    e = Err.Number
    eDesc = Err.Description
    Err.Clear
    On Error GoTo 0

    If e = 0 Then
        ' Confirma criacao via Dir (UNC pode mentir)
        On Error Resume Next
        existe = (Dir(caminho, vbDirectory) <> "")
        On Error GoTo 0
        IV3_GarantirPasta = existe
        Exit Function
    End If

    If e = 75 Or e = 58 Then
        ' "Path/File access error" ou "File already exists" - re-checa
        On Error Resume Next
        existe = (Dir(caminho, vbDirectory) <> "")
        On Error GoTo 0
        IV3_GarantirPasta = existe
        Exit Function
    End If

    Debug.Print "[V3 GarantirPasta] MkDir falhou: '" & caminho & _
                "' err=" & e & " " & eDesc
    IV3_GarantirPasta = False
End Function


' ============================================================
' === V12.0.0203 ONDA 10 - Helpers de bump auto build label =
' ============================================================
'
' Atualiza as constantes APP_BUILD_IMPORTADO e APP_BUILD_GERADO_EM
' no espelho de disco (AAX-App_Release.bas). Nao toca workbook.
' Retorna True em sucesso. Loga em IMPORT_LOG_V3 em falha.
'
' UNC preserve aplicado (L4) - prefixo \\Mac\Home\... preservado
' antes do colapso de separadores duplicados internos.
Private Function IV3_AtualizarConstantesAppRelease(ByVal buildLabel As String) As Boolean
    Dim sep As String
    sep = Application.PathSeparator

    Dim caminhoAbs As String
    caminhoAbs = ThisWorkbook.Path & sep & _
                 Replace(IV3_APP_RELEASE_REL_PATH, "\", sep)

    ' Preserva prefixo UNC antes do colapso (L4 do knowledge 0009)
    Dim prefixoUNC As String
    prefixoUNC = ""
    If sep = "\" And Len(caminhoAbs) >= 2 Then
        If Left(caminhoAbs, 2) = "\\" Then
            prefixoUNC = "\\"
            caminhoAbs = Mid(caminhoAbs, 3)
        End If
    End If
    Do While InStr(caminhoAbs, sep & sep) > 0
        caminhoAbs = Replace(caminhoAbs, sep & sep, sep)
    Loop
    caminhoAbs = prefixoUNC & caminhoAbs

    If Not IV3_ArquivoExiste(caminhoAbs) Then
        Call IV3_LogEvento("BUMP_FILE_MISSING", "*", caminhoAbs, _
                            "AAX-App_Release.bas (espelho) ausente", "FALHA")
        IV3_AtualizarConstantesAppRelease = False
        Exit Function
    End If

    Dim conteudo As String
    conteudo = IV3_LerArquivoBinarioComoTexto(caminhoAbs)

    Dim novoConteudo As String
    novoConteudo = IV3_SubstituirConstanteString(conteudo, _
                                                  IV3_APP_RELEASE_CONST_BUILD, _
                                                  buildLabel)
    novoConteudo = IV3_SubstituirConstanteString(novoConteudo, _
                                                  IV3_APP_RELEASE_CONST_GERADO, _
                                                  Format(Now, "yyyy-mm-dd hh:mm"))

    If novoConteudo = conteudo Then
        Call IV3_LogEvento("BUMP_NO_CHANGE", "*", caminhoAbs, _
                            "Constantes nao encontradas ou ja iguais", "FALHA")
        IV3_AtualizarConstantesAppRelease = False
        Exit Function
    End If

    On Error GoTo erroEscrita
    Dim h As Integer
    h = FreeFile
    Open caminhoAbs For Output As #h
    Print #h, novoConteudo;
    Close #h
    On Error GoTo 0

    IV3_AtualizarConstantesAppRelease = True
    Exit Function

erroEscrita:
    Call IV3_LogEvento("BUMP_ESCRITA_FALHA", "*", caminhoAbs, _
                        "Err=" & Err.Number & " | " & Err.Description, "FALHA")
    IV3_AtualizarConstantesAppRelease = False
End Function

' Substitui o valor de uma constante string em conteudo de .bas.
' Procura linha que comece (apos LTrim) com:
'   Public Const <nomeConstante> As String
' Reescreve a linha mantendo o padrao Public Const <nome> As String = "<novo>".
' Retorna conteudo inalterado se a constante nao for encontrada.
' So substitui a primeira ocorrencia (constantes sao unicas em um modulo).
Private Function IV3_SubstituirConstanteString(ByVal conteudo As String, _
                                                ByVal nomeConstante As String, _
                                                ByVal novoValor As String) As String
    Dim linhas() As String
    Dim i As Long
    Dim linha As String
    Dim linhaTrim As String
    Dim alvo As String
    alvo = "Public Const " & nomeConstante & " As String"

    linhas = Split(conteudo, vbCrLf)
    For i = LBound(linhas) To UBound(linhas)
        linha = linhas(i)
        linhaTrim = LTrim(linha)
        If Left(linhaTrim, Len(alvo)) = alvo Then
            linhas(i) = "Public Const " & nomeConstante & _
                        " As String = """ & novoValor & """"
            Exit For
        End If
    Next i

    IV3_SubstituirConstanteString = Join(linhas, vbCrLf)
End Function

' Re-importa AAX-App_Release.bas do espelho atualizado para o workbook.
' Reusa pipeline padrao IV3_ImportarModulo (Remove+Import com validacao
' por CountOfLines). Modo "Estabilizado" (workbook ja tem App_Release).
' UNC preserve aplicado.
Private Function IV3_ReimportarAppRelease() As Boolean
    Dim sep As String
    sep = Application.PathSeparator

    Dim caminhoAbs As String
    caminhoAbs = ThisWorkbook.Path & sep & _
                 Replace(IV3_APP_RELEASE_REL_PATH, "\", sep)

    Dim prefixoUNC As String
    prefixoUNC = ""
    If sep = "\" And Len(caminhoAbs) >= 2 Then
        If Left(caminhoAbs, 2) = "\\" Then
            prefixoUNC = "\\"
            caminhoAbs = Mid(caminhoAbs, 3)
        End If
    End If
    Do While InStr(caminhoAbs, sep & sep) > 0
        caminhoAbs = Replace(caminhoAbs, sep & sep, sep)
    Loop
    caminhoAbs = prefixoUNC & caminhoAbs

    IV3_ReimportarAppRelease = IV3_ImportarModulo(caminhoAbs, _
                                                   IV3_APP_RELEASE_NOME, _
                                                   "Estabilizado", _
                                                   "BUMP_STANDALONE")
End Function


Private Sub IV3_LogEvento(ByVal evento As String, _
                          ByVal grupo As String, _
                          ByVal caminho As String, _
                          ByVal detalhes As String, _
                          ByVal status As String)
    On Error Resume Next
    Dim ws As Object
    Set ws = ThisWorkbook.Sheets(IV3_LOG_SHEET)
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Sheets.Add
        ws.Name = IV3_LOG_SHEET
        ws.Cells(1, 1).Value = "TIMESTAMP"
        ws.Cells(1, 2).Value = "EVENTO"
        ws.Cells(1, 3).Value = "GRUPO"
        ws.Cells(1, 4).Value = "CAMINHO"
        ws.Cells(1, 5).Value = "DETALHES"
        ws.Cells(1, 6).Value = "STATUS"
    End If
    Dim ult As Long
    ult = ws.Cells(ws.Rows.count, 1).End(-4162).row + 1   ' xlUp = -4162
    ws.Cells(ult, 1).Value = Format(Now, "yyyy-mm-dd hh:mm:ss")
    ws.Cells(ult, 2).Value = evento
    ws.Cells(ult, 3).Value = grupo
    ws.Cells(ult, 4).Value = caminho
    ws.Cells(ult, 5).Value = detalhes
    ws.Cells(ult, 6).Value = status

    ' Tambem imprime na imediata para visibilidade durante o run
    Debug.Print "[V3 " & status & "] " & evento & " | " & grupo & " | " & _
                caminho & " | " & detalhes
    On Error GoTo 0
End Sub


