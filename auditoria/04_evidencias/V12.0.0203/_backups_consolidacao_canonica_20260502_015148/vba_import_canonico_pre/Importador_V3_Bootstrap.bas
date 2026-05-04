Attribute VB_Name = "Importador_V3_Bootstrap"
Option Explicit

' ============================================================
' Importador V3 - Bootstrap (descartavel)
' ============================================================
'
' Este modulo NAO faz parte do build oficial. E uma macro descartavel
' usada UMA VEZ pelo operador para instalar o Importador_V3 real no
' workbook. Apos rodar Bootstrap_V3, este modulo pode ser removido
' (clique direito > Remove sem exportar).
'
' Por que existe:
'   - Importador_V3 nao pode importar a si mesmo (auto-import causou
'     bugs historicos na V2).
'   - O caminho oficial e: operador importa este Bootstrap manualmente
'     via VBE > File > Import File, roda Bootstrap_V3, e depois usa
'     ImportarPacoteV3() do modulo Importador_V3 ja instalado.
'
' Localizacao no disco:
'   local-ai/vba_import/Importador_V3_Bootstrap.bas (raiz, sem prefixo)
'
' Pre-condicao:
'   VBOM habilitado (Trust Center > Trust access to VBA project model).
'
' O Bootstrap_V3:
'   1. Verifica VBOM
'   2. Localiza o arquivo ABK-Importador_V3.bas em vba_import/001-modulo/
'   3. Remove componente Importador_V3 do workbook se ja existir
'   4. Importa o arquivo via VBComponents.Import
'   5. Mostra MsgBox confirmando ou erro
'
' Apos sucesso, operador roda no Imediato:
'   ImportarPacoteV3_Status     ' confirma manifesto presente
'   ImportarPacoteV3_DryRun     ' simula sem tocar
'   ImportarPacoteV3            ' executa real
'
' ============================================================

Private Const BOOT_V3_TARGET_REL As String = _
    "local-ai\vba_import_v3_phase1\001-modulo\ABK-Importador_V3.bas"
Private Const BOOT_V3_COMP_NAME As String = "Importador_V3"

Public Sub Bootstrap_V3()
    Dim p As Object
    On Error Resume Next
    Set p = Application.VBE.ActiveVBProject
    If p Is Nothing Then
        MsgBox "VBOM nao habilitado." & vbCrLf & vbCrLf & _
               "Habilite em: Excel > Preferences > Security > Trust Center > " & _
               "Trust access to VBA project object model." & vbCrLf & vbCrLf & _
               "Depois feche e reabra o workbook e rode Bootstrap_V3 de novo.", _
               vbCritical, "Bootstrap V3"
        Exit Sub
    End If
    On Error GoTo 0

    Dim caminho As String
    caminho = ThisWorkbook.Path & Application.PathSeparator & _
              Replace(BOOT_V3_TARGET_REL, "\", Application.PathSeparator)

    If Dir(caminho) = "" Then
        MsgBox "Arquivo nao encontrado:" & vbCrLf & "  " & caminho & vbCrLf & vbCrLf & _
               "Confira que o pacote local-ai/vba_import/ esta presente ao " & _
               "lado do .xlsm.", vbCritical, "Bootstrap V3"
        Exit Sub
    End If

    ' Remove componente Importador_V3 se ja existir (idempotente)
    On Error Resume Next
    Dim cExist As Object
    Set cExist = p.VBComponents(BOOT_V3_COMP_NAME)
    If Not cExist Is Nothing Then
        p.VBComponents.Remove cExist
    End If
    On Error GoTo 0

    ' Import do arquivo real
    On Error GoTo falha
    p.VBComponents.Import caminho
    On Error GoTo 0

    ' Validacao basica: componente existe e tem >100 linhas
    On Error Resume Next
    Dim cNovo As Object
    Set cNovo = p.VBComponents(BOOT_V3_COMP_NAME)
    If cNovo Is Nothing Then
        MsgBox "Import retornou OK mas componente Importador_V3 nao foi " & _
               "encontrado no projeto. Estado inconsistente.", _
               vbCritical, "Bootstrap V3"
        Exit Sub
    End If
    Dim nLinhas As Long
    nLinhas = cNovo.CodeModule.CountOfLines
    On Error GoTo 0

    If nLinhas < 100 Then
        MsgBox "Importador_V3 importou com apenas " & nLinhas & _
               " linhas (esperado ~500). Possivel corrupcao.", _
               vbCritical, "Bootstrap V3"
        Exit Sub
    End If

    MsgBox "Importador_V3 instalado com sucesso." & vbCrLf & _
           "Linhas: " & nLinhas & vbCrLf & vbCrLf & _
           "Proximos passos no Imediato (Ctrl+G):" & vbCrLf & _
           "  ImportarPacoteV3_Status" & vbCrLf & _
           "  ImportarPacoteV3_DryRun" & vbCrLf & _
           "  ImportarPacoteV3" & vbCrLf & vbCrLf & _
           "Apos validar, voce pode remover este Bootstrap " & _
           "(clique direito no Importador_V3_Bootstrap > Remove sem exportar).", _
           vbInformation, "Bootstrap V3"
    Exit Sub

falha:
    MsgBox "Falha ao importar Importador_V3:" & vbCrLf & _
           "Err " & Err.Number & ": " & Err.Description, _
           vbCritical, "Bootstrap V3"
End Sub

