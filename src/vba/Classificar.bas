Attribute VB_Name = "Classificar"
Sub ClassificaEntidade()
    ' V12: eliminado Sheets.Select + Range.Select + ActiveSheet (proibidos; chamado de formulario modal).
    ' Usa referencia direta via ws.
    Dim ws As Worksheet
    Dim ultimaLinha As Long

    On Error GoTo fim
    Set ws = ThisWorkbook.Worksheets(SHEET_ENTIDADE)
    ultimaLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    If ultimaLinha < LINHA_DADOS Then Exit Sub

    ws.Sort.SortFields.Clear
    ws.Sort.SortFields.Add2 Key:=ws.Range("C2:C" & ultimaLinha), _
         SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortNormal
    With ws.Sort
        .SetRange ws.Range("A2:V" & ultimaLinha)
        .Header = xlGuess
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
Exit Sub
fim:
    Err.Clear
End Sub

Sub ClassificaEmpresa()
    ' V10: classificação da aba de empresas (antes era Empresa).
    ' Usa Range.Sort por compatibilidade entre versões de Excel.
    Dim ws As Worksheet
    Dim ultima As Long
    Dim primeiraLinha As Long

    On Error GoTo fim

    Set ws = ThisWorkbook.Worksheets(SHEET_EMPRESAS)
    ultima = ws.Cells(ws.Rows.count, COL_EMP_ID).End(xlUp).row
    primeiraLinha = PrimeiraLinhaDadosEmpresas()

    ' Com 0/1 registro nao precisa ordenar.
    If ultima <= primeiraLinha Then Exit Sub

    ws.Range("A" & primeiraLinha & ":T" & ultima).Sort _
        Key1:=ws.Range("C" & primeiraLinha), _
        Order1:=xlAscending, _
        Header:=xlNo, _
        Orientation:=xlTopToBottom
    Exit Sub

fim:
    ' Ordenacao nao deve impedir o fluxo de cadastro.
    Err.Clear
End Sub

Sub ClassificaCredenciadoOrdem()
    ' V10: alcance ate coluna O (15 cols). Ordenar por ATIV_ID (J) + POSICAO_FILA (F). Sem Select.
    ' V12.0.0007: adicionado On Error GoTo fim (defensivo). Dados ja escritos nao devem ser
    ' perdidos por falha de ordenacao. O sort deve ser chamado com a aba ja desprotegida.
    On Error GoTo fim
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets(SHEET_CREDENCIADOS)
    ultimaLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    Application.CutCopyMode = False
    If ultimaLinha < LINHA_DADOS Then Exit Sub

    ws.Sort.SortFields.Clear
    ws.Sort.SortFields.Add2 Key:=ws.Range("J" & LINHA_DADOS & ":J" & ultimaLinha), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortTextAsNumbers
    ws.Sort.SortFields.Add2 Key:=ws.Range("F" & LINHA_DADOS & ":F" & ultimaLinha), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortTextAsNumbers
    With ws.Sort
        .SetRange ws.Range("A" & LINHA_DADOS & ":O" & ultimaLinha)
        .Header = xlNo
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
    Exit Sub
fim:
    Err.Clear
End Sub

Sub ClassificaCredenciadoInativo()
    ' V10: alcance ate coluna O. Sem Select.
    ' V12.0.0007: adicionado On Error GoTo fim (defensivo, igual ClassificaEntidade).
    ' O sort deve ser chamado com a aba ja desprotegida pelo chamador (Util_PrepararAbaParaEscrita).
    On Error GoTo fim
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets(SHEET_CREDENCIADOS)
    ultimaLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    Application.CutCopyMode = False
    If ultimaLinha < LINHA_DADOS Then Exit Sub

    ws.Sort.SortFields.Clear
    ws.Sort.SortFields.Add2 Key:=ws.Range("C" & LINHA_DADOS & ":C" & ultimaLinha), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortTextAsNumbers
    With ws.Sort
        .SetRange ws.Range("A" & LINHA_DADOS & ":O" & ultimaLinha)
        .Header = xlNo
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
    Exit Sub
fim:
    Err.Clear
End Sub
Sub ClassificaCredenciadoRel()
    ' V10: alcance ate coluna O. Sem Select.
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets(SHEET_CREDENCIADOS)
    ultimaLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    Application.CutCopyMode = False
    If ultimaLinha < LINHA_DADOS Then Exit Sub

    ws.Sort.SortFields.Clear
    ws.Sort.SortFields.Add2 Key:=ws.Range("B" & LINHA_DADOS & ":B" & ultimaLinha), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortTextAsNumbers
    ws.Sort.SortFields.Add2 Key:=ws.Range("C" & LINHA_DADOS & ":C" & ultimaLinha), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortTextAsNumbers
    With ws.Sort
        .SetRange ws.Range("A" & LINHA_DADOS & ":O" & ultimaLinha)
        .Header = xlNo
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
End Sub

Sub ClassificaOSEmpresa()
    ' V10: alcance ate coluna AD (30 cols). Sem Select.
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets(SHEET_CAD_OS)
    ultimaLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    Application.CutCopyMode = False
    If ultimaLinha < LINHA_DADOS Then Exit Sub

    ws.Sort.SortFields.Clear
    ws.Sort.SortFields.Add2 Key:=ws.Range("D" & LINHA_DADOS & ":D" & ultimaLinha), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortTextAsNumbers
    ws.Sort.SortFields.Add2 Key:=ws.Range("F" & LINHA_DADOS & ":F" & ultimaLinha), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortTextAsNumbers
    With ws.Sort
        .SetRange ws.Range("A" & LINHA_DADOS & ":AD" & ultimaLinha)
        .Header = xlNo
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
End Sub
Sub ClassificaOS()
    ' V10: alcance ate coluna AD. Sem Select.
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets(SHEET_CAD_OS)
    ultimaLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    Application.CutCopyMode = False
    If ultimaLinha < LINHA_DADOS Then Exit Sub

    ws.Sort.SortFields.Clear
    ws.Sort.SortFields.Add2 Key:=ws.Range("A" & LINHA_DADOS & ":A" & ultimaLinha), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortTextAsNumbers
    With ws.Sort
        .SetRange ws.Range("A" & LINHA_DADOS & ":AD" & ultimaLinha)
        .Header = xlNo
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
End Sub

Sub ClassificaDataOS()
    ' V10: alcance ate coluna AD. Sem Select.
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets(SHEET_CAD_OS)
    ultimaLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    Application.CutCopyMode = False
    If ultimaLinha < LINHA_DADOS Then Exit Sub

    ws.Sort.SortFields.Clear
    ws.Sort.SortFields.Add2 Key:=ws.Range("H" & LINHA_DADOS & ":H" & ultimaLinha), SortOn:=xlSortOnValues, Order:=xlDescending, DataOption:=xlSortTextAsNumbers
    With ws.Sort
        .SetRange ws.Range("A" & LINHA_DADOS & ":AD" & ultimaLinha)
        .Header = xlNo
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
End Sub

Sub ClassificaDataPreOS()
    ' V10: alcance ate coluna N (14 cols). Sem Select.
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets(SHEET_PREOS)
    ultimaLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    Application.CutCopyMode = False
    If ultimaLinha < LINHA_DADOS Then Exit Sub

    ws.Sort.SortFields.Clear
    ws.Sort.SortFields.Add2 Key:=ws.Range("E" & LINHA_DADOS & ":E" & ultimaLinha), SortOn:=xlSortOnValues, Order:=xlDescending, DataOption:=xlSortTextAsNumbers
    With ws.Sort
        .SetRange ws.Range("A" & LINHA_DADOS & ":N" & ultimaLinha)
        .Header = xlNo
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
End Sub
Sub ClassificaPreOS()
    ' V10: alcance ate coluna N. Sem Select.
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Worksheets(SHEET_PREOS)
    ultimaLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    Application.CutCopyMode = False
    If ultimaLinha < LINHA_DADOS Then Exit Sub

    ws.Sort.SortFields.Clear
    ws.Sort.SortFields.Add2 Key:=ws.Range("A" & LINHA_DADOS & ":A" & ultimaLinha), SortOn:=xlSortOnValues, Order:=xlDescending, DataOption:=xlSortTextAsNumbers
    With ws.Sort
        .SetRange ws.Range("A" & LINHA_DADOS & ":N" & ultimaLinha)
        .Header = xlNo
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
End Sub

Sub ClassificaServico()
    ' V12: eliminado Sheets.Select + Range.Select + ActiveSheet (proibidos; chamado de formulario modal).
    ' Usa referencia direta via ws.
    Dim ws As Worksheet
    Dim ultimaLinha As Long

    On Error GoTo fim
    Set ws = ThisWorkbook.Worksheets(SHEET_CAD_SERV)
    ultimaLinha = ws.Cells(ws.Rows.count, 1).End(xlUp).row
    If ultimaLinha < LINHA_DADOS Then Exit Sub

    ws.Sort.SortFields.Clear
    ws.Sort.SortFields.Add Key:=ws.Range("C2:C" & ultimaLinha), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortNormal
    ws.Sort.SortFields.Add Key:=ws.Range("D2:D" & ultimaLinha), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortNormal

    With ws.Sort
        .SetRange ws.Range("A2:I" & ultimaLinha)
        .Header = xlGuess
        .MatchCase = False
        .Orientation = xlTopToBottom
        .SortMethod = xlPinYin
        .Apply
    End With
Exit Sub
fim:
    Err.Clear
End Sub


