VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Configuracao_Inicial 
   Caption         =   "CONFIGURACOES INICIAIS"
   ClientHeight    =   5341
   ClientLeft      =   119
   ClientTop       =   462
   ClientWidth     =   12782
   OleObjectBlob   =   "Configuracao_Inicial.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "Configuracao_Inicial"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False





Private Sub Carrega_CAD_SERV_Click()
On Error GoTo erro_carregamento:
    ' V12: eliminado Sheets.Select + Range.Select (proibidos; formulario modal).
    ' Usa referencia direta ao workbook externo e ao SHEET_CAD_SERV do workbook atual.
    Dim ArqParaAbrir As String
    Dim wbExterno As Workbook
    Dim wsExt As Worksheet
    Dim wsLocal As Worksheet
    Dim ultimaLinhaExt As Long

    Application.ScreenUpdating = False

    ArqParaAbrir = Application.GetOpenFilename("Arquivo do Excel (*.xls*), *.xl*", _
                    Title:="Escolha o arquivo a ser importado", _
                    MultiSelect:=False)

    If ArqParaAbrir = "False" Or ArqParaAbrir = "" Then
        Application.ScreenUpdating = True
        Exit Sub
    End If

    Set wbExterno = Application.Workbooks.Open(ArqParaAbrir)
    Set wsExt = wbExterno.Sheets("CAD_SERV")
    ultimaLinhaExt = wsExt.Range("A65536").End(xlUp).row
    wsExt.Range("A2:I" & ultimaLinhaExt).Copy
    wbExterno.Close False

    Set wsLocal = ThisWorkbook.Sheets(SHEET_CAD_SERV)
    wsLocal.Range("A2").PasteSpecial
    Application.CutCopyMode = False

    MsgBox "Processo conclu" & ChrW(237) & "do. Arquivos copiados.", _
           vbInformation, "Configura" & ChrW(231) & ChrW(245) & "es Iniciais"
    Unload Me
    Application.ScreenUpdating = True
Exit Sub
erro_carregamento:
    Application.ScreenUpdating = True
    Application.CutCopyMode = False
    MsgBox "Erro ao importar CAD_SERV: " & Err.Description, vbCritical, "Configura" & ChrW(231) & ChrW(245) & "es Iniciais"
End Sub

Private Sub B_Parametros_Click()
On Error GoTo erro_carregamento:
    Dim wsCfg As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim gestorTxt As String
    Dim municipioTxt As String
    Dim prazoTxt As String
    Dim logoTxt As String
    Dim msgSave As String

    Set wsCfg = ThisWorkbook.Sheets(SHEET_CONFIG)
    If Not Util_PrepararAbaParaEscrita(wsCfg, estavaProtegida, senhaProtecao) Then
        MsgBox "Não foi possível salvar os parâmetros: aba CONFIG protegida.", vbCritical, "Configurações iniciais"
        Exit Sub
    End If

    gestorTxt = Funcoes.NormalizarTextoPTBR(ValorControleTexto(Me, "Gestor_Rodizio", CStr(Gestor_Rodizio)))
    municipioTxt = Funcoes.NormalizarTextoPTBR(ValorControleTexto(Me, "Municipio_gestao", CStr(Municipio_gestao)))
    prazoTxt = Trim$(ValorControleTexto(Me, "PR_Val_OS", CStr(PR_Val_OS)))
    logoTxt = Trim$(ValorControleTexto(Me, "Caminho_Logo", CStr(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_LOGO).Value)))

    If prazoTxt = "" Then prazoTxt = "5"

    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_GESTOR).Value = gestorTxt
    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_LOGO).Value = logoTxt
    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MUNICIPIO).Value = municipioTxt
    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_PRAZO_PREOS).Value = prazoTxt
    wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value = "1"

    Call Util_RestaurarProtecaoAba(wsCfg, estavaProtegida, senhaProtecao)
    If Not Util_SalvarWorkbookSeguro(msgSave) Then
        MsgBox "Parâmetros salvos, mas houve falha ao salvar o arquivo automaticamente." & vbCrLf & _
               "Detalhe: " & msgSave & vbCrLf & _
               "Use Ctrl+S para salvar manualmente antes de continuar.", vbExclamation, "Configurações iniciais"
    End If
    Unload Me
Exit Sub
erro_carregamento:
    On Error Resume Next
    If Not wsCfg Is Nothing Then Call Util_RestaurarProtecaoAba(wsCfg, estavaProtegida, senhaProtecao)
    On Error GoTo 0
    MsgBox "Falha ao salvar parâmetros: (" & CStr(Err.Number) & ") " & Err.Description, vbCritical, "Configurações iniciais"
End Sub

Private Sub BR_Backup_Click()
On Error GoTo erro_carregamento:
    ' V12: eliminado Sheets.Select + Range.Select + ActiveCell (proibidos; formulario modal).
    ' Usa referencia direta via ws.Range e ws.Cells.
    Dim Copia As String, NomeArquivo As String, Resposta As String, NomePasta As String, pasta As String
    Dim wsPreOS As Worksheet
    Dim wsCADOS As Worksheet
    Dim estProtPreOS As Boolean
    Dim senhaPreOS As String
    Dim estProtCADOS As Boolean
    Dim senhaCADOS As String
    Dim ultimaLinhaPreOS As Long
    Dim ultimaLinhaCADOS As Long
    Dim preOSPreparada As Boolean
    Dim cadOSPreparada As Boolean

    NomeArquivo = ThisWorkbook.Name
    MsgBox "Efetuando c" & ChrW(243) & "pia de seguran" & ChrW(231) & "a, limpando a base de Pr" & ChrW(233) & "-SS e SS e mantendo os demais cadastros.", _
           vbInformation, "In" & ChrW(237) & "cio de Novo Per" & ChrW(237) & "odo"

    Resposta = MsgBox("Confirme o Backup " & NomeArquivo & "?", vbYesNo + vbQuestion, _
                      "Iniciando um Novo Per" & ChrW(237) & "odo")

    If Resposta = vbNo Then
        MsgBox "Backup cancelado pelo usu" & ChrW(225) & "rio!", vbExclamation, "Iniciando um Novo Per" & ChrW(237) & "odo"
        Exit Sub
    End If

    NomePasta = InputBox("Informe o Nome para a Pasta", "Iniciando um Novo Per" & ChrW(237) & "odo")
    pasta = ThisWorkbook.Path & "\" & NomePasta & "\"
    Copia = pasta & Format(Now(), "dd_mm_yyyy hh_mm_ss") & NomeArquivo
    Dim fso As Object
    Set fso = CreateObject("Scripting.FileSystemObject")
    If Not fso.FolderExists(pasta) Then
        Call fso.CreateFolder(pasta)
        MsgBox "Pasta criada com sucesso!", vbInformation, "Iniciando um Novo Per" & ChrW(237) & "odo"
    Else
        MsgBox "A pasta n" & ChrW(227) & "o foi criada por j" & ChrW(225) & " existir.", _
               vbInformation, "Iniciando um Novo Per" & ChrW(237) & "odo"
    End If

    If ThisWorkbook.ReadOnly = True Then
        ThisWorkbook.Saved = True
    Else
        ThisWorkbook.Save
    End If

    ThisWorkbook.SaveCopyAs Copia

    MsgBox "Backup efetuado com sucesso!", vbInformation, "Iniciando um Novo Per" & ChrW(237) & "odo"

    If MsgBox("Tem certeza que deseja iniciar um NOVO PER" & ChrW(237) & "ODO?", _
              vbQuestion + vbYesNo, "Iniciando um Novo Per" & ChrW(237) & "odo") = vbYes Then

        Set wsPreOS = ThisWorkbook.Sheets("PRE_OS")
        Set wsCADOS = ThisWorkbook.Sheets("CAD_OS")

        ultimaLinhaPreOS = wsPreOS.Range("A65536").End(xlUp).row
        ultimaLinhaCADOS = wsCADOS.Range("A65536").End(xlUp).row

        If ultimaLinhaPreOS > 1 Then
            If Not Util_PrepararAbaParaEscrita(wsPreOS, estProtPreOS, senhaPreOS) Then
                MsgBox "Não foi possível iniciar o novo período: aba PRE_OS protegida para escrita.", _
                       vbCritical, "Configurações iniciais"
                Exit Sub
            End If
            preOSPreparada = True
        End If

        If ultimaLinhaCADOS > 1 Then
            If Not Util_PrepararAbaParaEscrita(wsCADOS, estProtCADOS, senhaCADOS) Then
                If preOSPreparada Then Call Util_RestaurarProtecaoAba(wsPreOS, estProtPreOS, senhaPreOS)
                MsgBox "Não foi possível iniciar o novo período: aba CAD_OS protegida para escrita.", _
                       vbCritical, "Configurações iniciais"
                Exit Sub
            End If
            cadOSPreparada = True
        End If

        If ultimaLinhaPreOS > 1 Then
            wsPreOS.Range("A2:I" & ultimaLinhaPreOS).ClearContents
            wsPreOS.Cells(1, 44).Value = 0  ' coluna AR = contador de IDs
        End If

        If ultimaLinhaCADOS > 1 Then
            wsCADOS.Range("A2:Y" & ultimaLinhaCADOS).ClearContents
            wsCADOS.Cells(1, 44).Value = 0  ' coluna AR = contador de IDs
        End If

        If cadOSPreparada Then Call Util_RestaurarProtecaoAba(wsCADOS, estProtCADOS, senhaCADOS)
        If preOSPreparada Then Call Util_RestaurarProtecaoAba(wsPreOS, estProtPreOS, senhaPreOS)

        Call PreenchimentoServico
        Call AtualizarListaEntidadeMenuAtual
        Call AtualizarListaEmpresaMenuAtual
        Call PreenchimentoEntidadeRodizio
        Call PreencherAvaliarOS
        Call PreencherManutencaoValor
        MsgBox "Novo per" & ChrW(237) & "odo iniciado com sucesso!", _
               vbInformation, "Iniciando um Novo Per" & ChrW(237) & "odo"
    Else
        MsgBox "Novo per" & ChrW(237) & "odo n" & ChrW(227) & "o iniciado, base de dados n" & ChrW(227) & "o foi alterada.", _
               vbInformation, "Iniciando um Novo Per" & ChrW(237) & "odo"
    End If

Exit Sub
erro_carregamento:
    On Error Resume Next
    If cadOSPreparada Then Call Util_RestaurarProtecaoAba(wsCADOS, estProtCADOS, senhaCADOS)
    If preOSPreparada Then Call Util_RestaurarProtecaoAba(wsPreOS, estProtPreOS, senhaPreOS)
    On Error GoTo 0
    MsgBox "Erro no processo de backup: " & Err.Description, vbCritical, "Configurações iniciais"
End Sub

Private Sub Limpar_Base_Click()
    Call AbrirLimparBaseSeguro
End Sub

' Compatibilidade: em algumas exportacoes/importacoes o controle ficou nomeado "Limpar_Basee".
Private Sub Limpar_Basee_Click()
    Call AbrirLimparBaseSeguro
End Sub

Private Sub Municipio_gestao_AfterUpdate()
On Error GoTo fim
    Municipio_gestao.Value = Funcoes.NormalizarTextoPTBR(Municipio_gestao.Value)
fim:
End Sub

Private Sub Gestor_Rodizio_AfterUpdate()
On Error GoTo fim
    Gestor_Rodizio.Value = Funcoes.NormalizarTextoPTBR(Gestor_Rodizio.Value)
fim:
End Sub

Private Sub AbrirLimparBaseSeguro()
On Error GoTo fallback
    VBA.UserForms.Add("Limpar_Base").Show
Exit Sub
fallback:
    ' Fallback operacional para nao travar o fluxo de testes.
    Call Limpa_Base
End Sub

Private Sub UserForm_Initialize()
On Error GoTo erro_carregamento:
    ' V12: eliminado Sheets.Select + .Select + ActiveCell (proibidos; formulario modal).
    ' Usa referencia direta via ThisWorkbook.Sheets().Cells().Value.
    Dim wsCfg As Worksheet
    Dim ctl As Object
    Dim txt As String

    Set wsCfg = ThisWorkbook.Sheets(SHEET_CONFIG)

    Gestor_Rodizio = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_GESTOR).Value
    Caminho_Logo = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_LOGO).Value
    Municipio_gestao = Funcoes.NormalizarTextoPTBR(wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MUNICIPIO).Value)
    PR_Val_OS = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_PRAZO_PREOS).Value
    ' Garantir que o prazo da Pre-OS esteja sempre preenchido (valor padrao 5 se nunca configurado)
    If PR_Val_OS = "" Or PR_Val_OS = "0" Or IsEmpty(PR_Val_OS) Then PR_Val_OS = "5"
    TP_Valor = wsCfg.Cells(LINHA_CFG_VALORES, COL_CFG_MAX_RECUSAS).Value

    ' Ajustes de interface: acentuacao e rotulos
    On Error Resume Next
        ' Titulo da janela (corrige acentuacao)
        Me.Caption = "Configura" & ChrW(231) & ChrW(245) & "es Iniciais"

        ' Manter a barra azul (Label42) apenas limpando o texto
        With Me.Controls("Label42")
            .Caption = ""
            .Visible = True
        End With

        ' Corrigir textos de rotulos principais pela legenda atual (sem depender do nome do controle)
        For Each ctl In Me.Controls
            If TypeName(ctl) = "Label" Then
                txt = LCase$(ctl.Caption)

                ' Area Gestora do Municipio
                If InStr(txt, "area gestora") > 0 Then
                    ctl.Caption = ChrW(193) & "rea Gestora do Munic" & ChrW(237) & "pio"
                    ctl.WordWrap = True
                End If

                ' Municipio (sem o "de")
                If InStr(txt, "municipio de") > 0 Or InStr(txt, "munic") > 0 Then
                    ctl.Caption = "Munic" & ChrW(237) & "pio"
                End If
            End If
        Next ctl
    On Error GoTo 0
Exit Sub
erro_carregamento:
End Sub

Private Function ValorControleTexto(ByVal frm As Object, ByVal nomeControle As String, Optional ByVal valorPadrao As String = "") As String
    On Error GoTo usar_padrao
    ValorControleTexto = Trim$(CStr(frm.Controls(nomeControle).Value))
    Exit Function
usar_padrao:
    ValorControleTexto = Trim$(valorPadrao)
End Function


