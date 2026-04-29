Attribute VB_Name = "Treinamento_Painel"
Option Explicit

' ============================================================
' Treinamento_Painel - Checklist de Testes V12
' Abordagem: aba dedicada TREINAMENTO_RESULTADOS
' SEM controles dinamicos, SEM UserForm auxiliar
' Tudo via planilha nativa (Data Validation + formatacao condicional)
'
' Funcoes publicas:
'   Treinamento_AbrirChecklist  - cria/atualiza aba e a ativa
'   Treinamento_SalvarResultado - grava snapshot dos resultados
'   Treinamento_Resumo          - exibe resumo SIM/NAO/PENDENTE
' ============================================================

Private Const SHEET_CHECKLIST As String = "TREINAMENTO_RESULTADOS"
Private Const TOTAL_TESTES As Long = 21
Private Const LINHA_CABECALHO As Long = 1
Private Const LINHA_PRIMEIRO_TESTE As Long = 3  ' linha 2 = instrucoes

' Colunas da aba
Private Const COL_ITEM As Long = 1       ' A
Private Const COL_SECAO As Long = 2      ' B
Private Const COL_PERGUNTA As Long = 3   ' C
Private Const COL_RESPOSTA As Long = 4   ' D
Private Const COL_COMENTARIO As Long = 5 ' E
Private Const COL_DT_RESP As Long = 6    ' F
Private Const COL_USUARIO As Long = 7    ' G

' ============================================================
' PONTO DE ENTRADA PRINCIPAL
' ============================================================
Public Sub Treinamento_AbrirChecklist()
    On Error GoTo falha

    Dim ws As Worksheet
    Dim jaCriada As Boolean

    Set ws = ObterOuCriarAba(jaCriada)

    If Not jaCriada Then
        ' Aba nova - montar do zero
        Call MontarCabecalho(ws)
        Call MontarInstrucoes(ws)
        Call MontarPerguntas(ws)
        Call AplicarValidacao(ws)
        Call AplicarFormatacaoCondicional(ws)
        Call MontarResumo(ws)
        Call AplicarProtecaoLeve(ws)
    Else
        ' Aba existente - apenas garantir que resumo esta atualizado
        Call AtualizarResumo(ws)
    End If

    ' Ativar a aba (V12: eliminado ws.Range.Select; posicionamento de cursor nao e necessario em contexto modal)
    Application.ScreenUpdating = True
    ws.Activate

    Exit Sub

falha:
    MsgBox "Falha ao abrir checklist de testes: " & Err.Description, vbExclamation, "Checklist V12"
End Sub

' ============================================================
' RESUMO (chamavel externamente)
' ============================================================
Public Sub Treinamento_Resumo()
    On Error GoTo falha

    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(SHEET_CHECKLIST)
    On Error GoTo falha

    If ws Is Nothing Then
        MsgBox "Aba de checklist ainda não foi criada. Clique em 'Treinamento' primeiro.", vbInformation, "Checklist V12"
        Exit Sub
    End If

    Dim cSim As Long, cNao As Long, cPend As Long
    Call ContarRespostas(ws, cSim, cNao, cPend)

    Dim msg As String
    msg = "=== RESUMO DO CHECKLIST V12 ===" & vbCrLf & vbCrLf & _
          "SIM:      " & cSim & " de " & TOTAL_TESTES & vbCrLf & _
          "NAO:      " & cNao & " de " & TOTAL_TESTES & vbCrLf & _
          "PENDENTE: " & cPend & " de " & TOTAL_TESTES & vbCrLf & vbCrLf

    If cPend = 0 And cNao = 0 Then
        msg = msg & "STATUS: TODOS OS TESTES PASSARAM"
    ElseIf cPend = 0 Then
        msg = msg & "STATUS: COMPLETO COM " & cNao & " FALHA(S)"
    Else
        msg = msg & "STATUS: EM ANDAMENTO (" & cPend & " pendente(s))"
    End If

    MsgBox msg, vbInformation, "Resumo Checklist V12"
    Exit Sub

falha:
    MsgBox "Erro ao gerar resumo: " & Err.Description, vbExclamation, "Checklist V12"
End Sub

' ============================================================
' SALVAR RESULTADO (grava log com timestamp)
' ============================================================
Public Sub Treinamento_SalvarResultado()
    On Error GoTo falha

    Dim ws As Worksheet
    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(SHEET_CHECKLIST)
    On Error GoTo falha

    If ws Is Nothing Then
        MsgBox "Aba de checklist não encontrada.", vbExclamation, "Checklist V12"
        Exit Sub
    End If

    ' Registrar data/hora em cada linha que tem resposta
    Dim i As Long
    Dim usuario As String
    usuario = ObterUsuario()

    For i = LINHA_PRIMEIRO_TESTE To LINHA_PRIMEIRO_TESTE + TOTAL_TESTES - 1
        Dim resp As String
        resp = Trim$(CStr(ws.Cells(i, COL_RESPOSTA).Value))
        If resp <> "" And UCase$(resp) <> "PENDENTE" Then
            If Trim$(CStr(ws.Cells(i, COL_DT_RESP).Value)) = "" Then
                ws.Cells(i, COL_DT_RESP).Value = Now
                ws.Cells(i, COL_USUARIO).Value = usuario
            End If
        End If
    Next i

    Call AtualizarResumo(ws)

    MsgBox "Resultados salvos com sucesso.", vbInformation, "Checklist V12"
    Exit Sub

falha:
    MsgBox "Erro ao salvar: " & Err.Description, vbExclamation, "Checklist V12"
End Sub

' ============================================================
' OBTER OU CRIAR ABA
' ============================================================
Private Function ObterOuCriarAba(ByRef jaExistia As Boolean) As Worksheet
    Dim ws As Worksheet
    jaExistia = False

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(SHEET_CHECKLIST)
    On Error GoTo 0

    If Not ws Is Nothing Then
        jaExistia = True
        Set ObterOuCriarAba = ws
        Exit Function
    End If

    Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.count))
    ws.Name = SHEET_CHECKLIST
    jaExistia = False
    Set ObterOuCriarAba = ws
End Function

' ============================================================
' MONTAR CABECALHO
' ============================================================
Private Sub MontarCabecalho(ByVal ws As Worksheet)
    Application.ScreenUpdating = False

    On Error Resume Next
    ws.Unprotect
    On Error GoTo 0

    ws.Cells.Clear

    ' Titulo
    ws.Range("A1:G1").Merge
    ws.Range("A1").Value = "CHECKLIST DE TESTES V12 - Rodízio de Empresas"
    With ws.Range("A1")
        .Font.Bold = True
        .Font.Size = 14
        .HorizontalAlignment = xlCenter
        .Interior.Color = RGB(0, 51, 102)
        .Font.Color = RGB(255, 255, 255)
        .RowHeight = 30
    End With
End Sub

' ============================================================
' INSTRUCOES (linha 2)
' ============================================================
Private Sub MontarInstrucoes(ByVal ws As Worksheet)
    ws.Range("A2:G2").Merge
    ws.Range("A2").Value = "Instrucao: na coluna RESPOSTA (D), use o dropdown para escolher SIM, NAO ou PENDENTE. " & _
                           "Use a coluna COMENTARIO (E) para observacoes. Ao terminar, clique Ctrl+Shift+S para salvar resultado."
    With ws.Range("A2")
        .Font.Italic = True
        .Font.Size = 9
        .Font.Color = RGB(80, 80, 80)
        .WrapText = True
        .RowHeight = 32
    End With
End Sub

' ============================================================
' MONTAR PERGUNTAS (T01..T21)
' ============================================================
Private Sub MontarPerguntas(ByVal ws As Worksheet)
    Dim r As Long
    r = LINHA_PRIMEIRO_TESTE

    ' Cabecalho da tabela
    ws.Cells(r - 1, COL_ITEM).Value = ""  ' usado pela instrucao, pular

    ' Cabecalhos reais estao em linha r-1? Nao, instrucao esta em L2. Cabecalhos dos dados:
    ' Inserir cabecalho da tabela na linha PRIMEIRO_TESTE - vou usar a linha r como cabecalho da tabela
    ' Mas nao, vou usar r como primeira pergunta. Preciso de cabecalho em r-1... mas L2 ja e instrucoes.
    ' Solucao: LINHA_PRIMEIRO_TESTE = 4, com cabecalho em L3

    ' Ajustar: usar L3 como cabecalho de colunas
    Dim hdr As Long
    hdr = LINHA_PRIMEIRO_TESTE - 1  ' deveria ser 2, mas L2 e instrucoes
    ' Na verdade LINHA_PRIMEIRO_TESTE = 3, entao hdr = 2. Conflito com instrucoes.
    ' Vou usar LINHA_PRIMEIRO_TESTE como o cabecalho da tabela e dados comecam em +1

    ' Cabecalho da tabela
    ws.Cells(r, COL_ITEM).Value = "ITEM"
    ws.Cells(r, COL_SECAO).Value = "SECAO"
    ws.Cells(r, COL_PERGUNTA).Value = "PERGUNTA"
    ws.Cells(r, COL_RESPOSTA).Value = "RESPOSTA"
    ws.Cells(r, COL_COMENTARIO).Value = "COMENTARIO"
    ws.Cells(r, COL_DT_RESP).Value = "DATA_RESPOSTA"
    ws.Cells(r, COL_USUARIO).Value = "USUARIO"

    With ws.Range(ws.Cells(r, 1), ws.Cells(r, 7))
        .Font.Bold = True
        .Interior.Color = RGB(217, 225, 242)
        .Borders.LineStyle = xlContinuous
        .HorizontalAlignment = xlCenter
    End With

    r = r + 1  ' agora r = LINHA_PRIMEIRO_TESTE + 1 = 4

    ' T01 a T21
    AddTeste ws, r, "T01", "Cadastro", "Cadastrar Entidade: dados persistidos corretamente na aba ENTIDADE?": r = r + 1
    AddTeste ws, r, "T02", "Cadastro", "Cadastrar Empresa Empresa: STATUS_GLOBAL = 'ATIVA' aparece na aba EMPRESAS?": r = r + 1
    AddTeste ws, r, "T03", "Credenciamento", "Credenciar empresa em atividade: linha criada em CREDENCIADOS com POSICAO_FILA?": r = r + 1
    AddTeste ws, r, "T04", "Rodizio", "Verificar fila de rodizio: empresa aparece na ListBox com ID correto?": r = r + 1
    AddTeste ws, r, "T05", "Pre-OS", "Emitir Pre-OS: PDF gerado com dados completos da empresa (endereco, CNPJ)?": r = r + 1
    AddTeste ws, r, "T06", "Rodizio", "Emitir 2a Pre-OS mesma atividade: empresa DIFERENTE foi selecionada?": r = r + 1
    AddTeste ws, r, "T07", "OS", "Aceitar Pre-OS e Emitir OS: OS criada com QT/VL iguais a Pre-OS?": r = r + 1
    AddTeste ws, r, "T08", "Punicao", "Recusar Pre-OS: punicao aplicada (QTD_RECUSAS+1) e fila avancou?": r = r + 1
    AddTeste ws, r, "T09", "UI", "Tela OS: lista pre-OS pendentes sem linha fantasma vazia no topo?": r = r + 1
    AddTeste ws, r, "T10", "Avaliacao", "Avaliar/Encerrar OS: sem erro Null, media calculada, STATUS=CONCLUIDA?": r = r + 1
    AddTeste ws, r, "T11", "Impressão", "Imprimir avaliação: se falha impressora, mensagem clara aparece?": r = r + 1
    AddTeste ws, r, "T12", "Relatorio", "Relatorio empresas por servico: sem erro AutoFit, dados corretos?": r = r + 1
    AddTeste ws, r, "T13", "Relatorio", "Relatorio entidades cadastradas: dados corretos e completos?": r = r + 1
    AddTeste ws, r, "T14", "Mensagem", "Msg 'sem empresas cadastradas': texto amigavel (nao tecnico)?": r = r + 1
    AddTeste ws, r, "T15", "Mensagem", "Msg 'sem empresas aptas': texto amigavel (nao tecnico)?": r = r + 1
    AddTeste ws, r, "T16", "Relatorio", "Relatorio OS Empresa: sem linha fantasma vazia no topo da lista?": r = r + 1
    AddTeste ws, r, "T17", "Compilacao", "Debug > Compile VBAProject: zero erros de compilacao?": r = r + 1
    AddTeste ws, r, "T18", "Anti-Dup", "Emitir Pre-OS + clique rapido 2x: NAO emite Pre-OS duplicada?": r = r + 1
    AddTeste ws, r, "T19", "Integridade", "OS emitida: QT_ESTIMADA, VL_UNIT, VL_TOTAL identicos entre Pre-OS e OS?": r = r + 1
    AddTeste ws, r, "T20", "Filtro D", "Empresa com OS aberta e pulada no rodizio (sem erro, conforme regra)?": r = r + 1
    AddTeste ws, r, "T21", "Cancelar OS", "CancelarOS (se aplicavel): STATUS_OS=CANCELADA, sem punicao?": r = r + 1

    ' Bordas na area de dados
    Dim ultLinha As Long
    ultLinha = r - 1
    ws.Range(ws.Cells(LINHA_PRIMEIRO_TESTE, 1), ws.Cells(ultLinha, 7)).Borders.LineStyle = xlContinuous

    ' Ajustar larguras
    ws.Columns("A").ColumnWidth = 7
    ws.Columns("B").ColumnWidth = 16
    ws.Columns("C").ColumnWidth = 72
    ws.Columns("D").ColumnWidth = 14
    ws.Columns("E").ColumnWidth = 40
    ws.Columns("F").ColumnWidth = 20
    ws.Columns("G").ColumnWidth = 16

    ' Altura de linhas de dados
    Dim iRow As Long
    For iRow = LINHA_PRIMEIRO_TESTE + 1 To ultLinha
        ws.Rows(iRow).RowHeight = 22
    Next iRow

    ' Wrap text para pergunta e comentario
    ws.Range(ws.Cells(LINHA_PRIMEIRO_TESTE + 1, COL_PERGUNTA), ws.Cells(ultLinha, COL_PERGUNTA)).WrapText = True
    ws.Range(ws.Cells(LINHA_PRIMEIRO_TESTE + 1, COL_COMENTARIO), ws.Cells(ultLinha, COL_COMENTARIO)).WrapText = True
End Sub

Private Sub AddTeste(ByVal ws As Worksheet, ByVal rowNum As Long, ByVal codigo As String, ByVal secao As String, ByVal pergunta As String)
    ws.Cells(rowNum, COL_ITEM).Value = codigo
    ws.Cells(rowNum, COL_SECAO).Value = secao
    ws.Cells(rowNum, COL_PERGUNTA).Value = pergunta
    ws.Cells(rowNum, COL_RESPOSTA).Value = "PENDENTE"
    ws.Cells(rowNum, COL_COMENTARIO).Value = ""
    ws.Cells(rowNum, COL_DT_RESP).Value = ""
    ws.Cells(rowNum, COL_USUARIO).Value = ""

    ' Centralizar item e secao
    ws.Cells(rowNum, COL_ITEM).HorizontalAlignment = xlCenter
    ws.Cells(rowNum, COL_SECAO).HorizontalAlignment = xlCenter
    ws.Cells(rowNum, COL_RESPOSTA).HorizontalAlignment = xlCenter
End Sub

' ============================================================
' DATA VALIDATION (dropdown SIM/NAO/PENDENTE)
' ============================================================
Private Sub AplicarValidacao(ByVal ws As Worksheet)
    Dim rng As Range
    Dim primeiraLinhaDados As Long
    Dim ultimaLinhaDados As Long

    primeiraLinhaDados = LINHA_PRIMEIRO_TESTE + 1  ' L4
    ultimaLinhaDados = primeiraLinhaDados + TOTAL_TESTES - 1  ' L24

    Set rng = ws.Range(ws.Cells(primeiraLinhaDados, COL_RESPOSTA), ws.Cells(ultimaLinhaDados, COL_RESPOSTA))

    With rng.Validation
        .Delete
        .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Operator:=xlBetween, Formula1:="SIM,NAO,PENDENTE"
        .IgnoreBlank = True
        .InCellDropdown = True
        .InputTitle = "Resposta"
        .InputMessage = "Escolha SIM, NAO ou PENDENTE"
        .ErrorTitle = "Valor invalido"
        .ErrorMessage = "Use apenas SIM, NAO ou PENDENTE."
    End With
End Sub

' ============================================================
' FORMATACAO CONDICIONAL (cores por resposta)
' ============================================================
Private Sub AplicarFormatacaoCondicional(ByVal ws As Worksheet)
    Dim rng As Range
    Dim primeiraLinhaDados As Long
    Dim ultimaLinhaDados As Long

    primeiraLinhaDados = LINHA_PRIMEIRO_TESTE + 1
    ultimaLinhaDados = primeiraLinhaDados + TOTAL_TESTES - 1

    Set rng = ws.Range(ws.Cells(primeiraLinhaDados, COL_RESPOSTA), ws.Cells(ultimaLinhaDados, COL_RESPOSTA))
    rng.FormatConditions.Delete

    ' SIM = verde claro
    With rng.FormatConditions.Add(Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""SIM""")
        .Interior.Color = RGB(198, 239, 206)
        .Font.Color = RGB(0, 97, 0)
        .Font.Bold = True
        .StopIfTrue = True
    End With

    ' NAO = vermelho claro
    With rng.FormatConditions.Add(Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""NAO""")
        .Interior.Color = RGB(255, 199, 206)
        .Font.Color = RGB(156, 0, 6)
        .Font.Bold = True
        .StopIfTrue = True
    End With

    ' PENDENTE = amarelo claro
    With rng.FormatConditions.Add(Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""PENDENTE""")
        .Interior.Color = RGB(255, 235, 156)
        .Font.Color = RGB(156, 101, 0)
        .StopIfTrue = True
    End With

    ' Aplicar mesma formatacao na linha inteira para cada resposta
    Set rng = ws.Range(ws.Cells(primeiraLinhaDados, 1), ws.Cells(ultimaLinhaDados, 7))
    rng.FormatConditions.Delete

    ' Linhas inteiras com cor de fundo sutil
    With rng.FormatConditions.Add(Type:=xlExpression, Formula1:="=$D" & primeiraLinhaDados & "=""SIM""")
        .Interior.Color = RGB(234, 249, 237)
        .StopIfTrue = False
    End With

    With rng.FormatConditions.Add(Type:=xlExpression, Formula1:="=$D" & primeiraLinhaDados & "=""NAO""")
        .Interior.Color = RGB(255, 230, 233)
        .StopIfTrue = False
    End With
End Sub

' ============================================================
' RESUMO (linha apos os testes)
' ============================================================
Private Sub MontarResumo(ByVal ws As Worksheet)
    Dim linhaResumo As Long
    linhaResumo = LINHA_PRIMEIRO_TESTE + 1 + TOTAL_TESTES + 1  ' L26

    ws.Cells(linhaResumo, 1).Value = "RESUMO"
    ws.Cells(linhaResumo, 1).Font.Bold = True
    ws.Cells(linhaResumo, 1).Font.Size = 12

    ws.Cells(linhaResumo + 1, 1).Value = "SIM:"
    ws.Cells(linhaResumo + 1, 2).Formula = "=COUNTIF(D4:D24,""SIM"")"
    ws.Cells(linhaResumo + 1, 2).Font.Bold = True
    ws.Cells(linhaResumo + 1, 2).Font.Color = RGB(0, 128, 0)

    ws.Cells(linhaResumo + 2, 1).Value = "NAO:"
    ws.Cells(linhaResumo + 2, 2).Formula = "=COUNTIF(D4:D24,""NAO"")"
    ws.Cells(linhaResumo + 2, 2).Font.Bold = True
    ws.Cells(linhaResumo + 2, 2).Font.Color = RGB(200, 0, 0)

    ws.Cells(linhaResumo + 3, 1).Value = "PENDENTE:"
    ws.Cells(linhaResumo + 3, 2).Formula = "=COUNTIF(D4:D24,""PENDENTE"")"
    ws.Cells(linhaResumo + 3, 2).Font.Bold = True
    ws.Cells(linhaResumo + 3, 2).Font.Color = RGB(180, 120, 0)

    ws.Cells(linhaResumo + 4, 1).Value = "TOTAL:"
    ws.Cells(linhaResumo + 4, 2).Value = TOTAL_TESTES
    ws.Cells(linhaResumo + 4, 2).Font.Bold = True

    ' Borda no resumo
    ws.Range(ws.Cells(linhaResumo, 1), ws.Cells(linhaResumo + 4, 2)).Borders.LineStyle = xlContinuous
End Sub

Private Sub AtualizarResumo(ByVal ws As Worksheet)
    ' Resumo usa formulas COUNTIF - atualiza automaticamente
    ' Nada a fazer aqui
End Sub

' ============================================================
' PROTECAO LEVE (travar colunas A-C, liberar D-E)
' ============================================================
Private Sub AplicarProtecaoLeve(ByVal ws As Worksheet)
    On Error Resume Next
    ws.Unprotect
    On Error GoTo 0

    ' Primeiro: travar tudo
    ws.Cells.Locked = True

    ' Liberar coluna D (RESPOSTA) e E (COMENTARIO) nas linhas de dados
    Dim primeiraLinhaDados As Long
    Dim ultimaLinhaDados As Long
    primeiraLinhaDados = LINHA_PRIMEIRO_TESTE + 1
    ultimaLinhaDados = primeiraLinhaDados + TOTAL_TESTES - 1

    ws.Range(ws.Cells(primeiraLinhaDados, COL_RESPOSTA), ws.Cells(ultimaLinhaDados, COL_RESPOSTA)).Locked = False
    ws.Range(ws.Cells(primeiraLinhaDados, COL_COMENTARIO), ws.Cells(ultimaLinhaDados, COL_COMENTARIO)).Locked = False

    ' Proteger sem senha (usuario pode desproteger se precisar)
    ws.Protect UserInterfaceOnly:=True, AllowFormattingCells:=True
End Sub

' ============================================================
' HELPERS
' ============================================================
Private Sub ContarRespostas(ByVal ws As Worksheet, ByRef cSim As Long, ByRef cNao As Long, ByRef cPend As Long)
    Dim i As Long
    Dim resp As String
    Dim primeiraLinhaDados As Long
    primeiraLinhaDados = LINHA_PRIMEIRO_TESTE + 1

    cSim = 0: cNao = 0: cPend = 0

    For i = primeiraLinhaDados To primeiraLinhaDados + TOTAL_TESTES - 1
        resp = UCase$(Trim$(CStr(ws.Cells(i, COL_RESPOSTA).Value)))
        Select Case resp
            Case "SIM": cSim = cSim + 1
            Case "NAO": cNao = cNao + 1
            Case Else: cPend = cPend + 1
        End Select
    Next i
End Sub

Private Function ObterUsuario() As String
    On Error Resume Next
    ObterUsuario = Environ$("USERNAME")
    If ObterUsuario = "" Then ObterUsuario = Application.UserName
    On Error GoTo 0
    If ObterUsuario = "" Then ObterUsuario = "OPERADOR"
End Function


