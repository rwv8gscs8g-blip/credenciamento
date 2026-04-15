Attribute VB_Name = "Teste_UI_Guiado"
Option Explicit

' ============================================================
' MODULO DE TESTE DA SPRINT 4 (MI-04)
' ============================================================
' Contem testes interativos guiados para V12.

Public Sub RunTesteUI()
    On Error GoTo falha
    Application.ScreenUpdating = False
    
    Dim ws As Worksheet
    Dim nova As Boolean
    
    ' Procurar a aba ou criar
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets("TESTE_UI")
    On Error GoTo falha
    
    If ws Is Nothing Then
        Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.count))
        ws.Name = "TESTE_UI"
        ws.Tab.Color = RGB(0, 153, 204)
    End If
    
    ws.Cells.Clear
    
    ' Titulo
    ws.Range("A1:G1").Merge
    With ws.Range("A1")
        .Value = "ROTEIRO DE TESTES VISO-MANUAIS DE UI — V12"
        .Font.Bold = True
        .Font.Size = 14
        .HorizontalAlignment = xlCenter
        .Interior.Color = RGB(0, 153, 204)
        .Font.Color = RGB(255, 255, 255)
        .RowHeight = 30
    End With
    
    Dim cols As Variant
    cols = Array("ID", "TELA", "COMPONENTE", "ACAO ESPERADA", "RESULTADO ESPERADO", "STATUS", "OBS")
    Dim c As Long
    For c = 0 To 6
        ws.Cells(3, c + 1).Value = cols(c)
    Next c
    
    With ws.Range("A3:G3")
        .Font.Bold = True
        .Interior.Color = RGB(0, 51, 102)
        .Font.Color = RGB(255, 255, 255)
        .Borders.LineStyle = xlContinuous
        .HorizontalAlignment = xlCenter
    End With
    
    Dim r As Long
    r = 4
    
    Call InserirPasso(ws, r, "UI-01", "Cadastro>Empresa", "Botão Credencia Empresa", "Selecionar empresa na lista e clicar Credenciar", "Abre Form de credenciamento sem erros")
    Call InserirPasso(ws, r, "UI-02", "Cadastro>Empresa", "Lista de Empresas", "Observar os 6 cabeçalhos da lista", "Labels correspondem aos dados das colunas (CNPJ, Razão, etc)")
    Call InserirPasso(ws, r, "UI-03", "Lista>Empresas", "Inativar Empresa", "Duplo clique na lista e Clicar Inativar", "Inativa sem erro de M_ID nulo")
    Call InserirPasso(ws, r, "UI-04", "Cadastro>Entidade", "Caixas de Telefone", "Visualizar formulário de entidade", "Telefone Fixo não deve estar oculto ou sobreposto")
    Call InserirPasso(ws, r, "UI-05", "DASHBOARD", "Botões de Impressão", "Exibir impressões cruas", "Os 4 botões de relatórios crus imprimem ou exibem sem macro error")
    Call InserirPasso(ws, r, "UI-06", "Cadastro>Serviço", "Lista de Serviço/CNAE", "Verificar largura da coluna e pesquisa", "Textos CNAE não se sobrepõem")
    Call InserirPasso(ws, r, "UI-07", "Painel OS", "Avaliação de OS Divergente", "Divergir valor orçado vs executado e tentar concluir sem texto", "Exige campo de Justificativa")
    Call InserirPasso(ws, r, "UI-08", "Várias Telas", "List/ComboBoxes", "Tentar rolar grandes listas", "O scroll roda solto e mostra todos os itens")
    Call InserirPasso(ws, r, "UI-09", "Reativar", "Aba Reativação", "Verificar lista de empresas/entidades inativas", "Mostra a Razão Social corretamente e não apenas ID vago")
    Call InserirPasso(ws, r, "UI-10", "DASHBOARD", "Menu Esquerdo", "Navegar pelos sub-menus dinâmicos", "Nenhum botão de ação deve se amontoar sobre outro em telas menores")
    
    Dim ul As Long
    ul = r - 1
    ws.Range("A3:A" & ul).HorizontalAlignment = xlCenter
    ws.Range(ws.Cells(4, 1), ws.Cells(ul, 7)).Borders.LineStyle = xlContinuous
    
    ' Criar validação
    Dim rv As Range
    Set rv = ws.Range(ws.Cells(4, 6), ws.Cells(ul, 6))
    With rv.Validation
        .Delete
        .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Formula1:="OK,FALHA,PENDENTE"
        .InCellDropdown = True
    End With
    
    rv.FormatConditions.Delete
    With rv.FormatConditions.Add(Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""OK""")
        .Interior.Color = RGB(198, 239, 206): .Font.Bold = True
    End With
    With rv.FormatConditions.Add(Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""FALHA""")
        .Interior.Color = RGB(255, 199, 206): .Font.Bold = True
    End With
    
    ws.Columns("A").ColumnWidth = 8
    ws.Columns("B").ColumnWidth = 16
    ws.Columns("C").ColumnWidth = 24
    ws.Columns("D").ColumnWidth = 38
    ws.Columns("E").ColumnWidth = 38
    ws.Columns("F").ColumnWidth = 14
    ws.Columns("G").ColumnWidth = 24
    
    Application.ScreenUpdating = True
    ws.Activate
    MsgBox "Roteiro de Validação de UI gerado na aba TESTE_UI." & vbCrLf & "Use a coluna 'STATUS' para checar suas validações.", vbInformation, "Testes Guiados"
    Exit Sub
falha:
    Application.ScreenUpdating = True
    MsgBox "Erro ao gerar aba: " & Err.Description, vbExclamation, "Teste UI Guiado"
End Sub

Private Sub InserirPasso(ByVal ws As Worksheet, ByRef rw As Long, ByVal id As String, ByVal t As String, ByVal com As String, ByVal ac As String, ByVal re As String)
    ws.Cells(rw, 1).Value = id
    ws.Cells(rw, 2).Value = t
    ws.Cells(rw, 3).Value = com
    ws.Cells(rw, 4).Value = ac
    ws.Cells(rw, 5).Value = re
    ws.Cells(rw, 6).Value = "PENDENTE"
    rw = rw + 1
End Sub


