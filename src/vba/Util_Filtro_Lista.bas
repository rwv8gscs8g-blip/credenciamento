Attribute VB_Name = "Util_Filtro_Lista"
Option Explicit

' ============================================================
' Util_Filtro_Lista
' Helper deterministico para filtros de ListBox/matrizes.
' Nesta etapa o modulo fica isolado: nenhum formulario consome ainda.
' ============================================================

Public Function UtilFiltro_Normalizar(ByVal valor As Variant) As String
    Dim s As String

    s = SafeListText(valor)
    If s = "" Then Exit Function

    On Error Resume Next
    s = Funcoes.NormalizarTextoPTBR(s)
    On Error GoTo 0

    s = UCase$(Trim$(s))
    s = Replace(s, vbCr, " ")
    s = Replace(s, vbLf, " ")
    s = Replace(s, vbTab, " ")
    s = Replace(s, Chr$(160), " ")
    s = UtilFiltro_RemoverAcentos(s)
    UtilFiltro_Normalizar = UtilFiltro_CompactarEspacos(s)
End Function

Public Function UtilFiltro_LinhaAtende(ByVal linhaConcatenada As Variant, ByVal termo As Variant) As Boolean
    Dim termoNorm As String
    Dim linhaNorm As String
    Dim termoDigitos As String
    Dim linhaDigitos As String

    termoNorm = UtilFiltro_Normalizar(termo)
    If termoNorm = "" Then
        UtilFiltro_LinhaAtende = True
        Exit Function
    End If

    linhaNorm = UtilFiltro_Normalizar(linhaConcatenada)
    If InStr(1, linhaNorm, termoNorm, vbBinaryCompare) > 0 Then
        UtilFiltro_LinhaAtende = True
        Exit Function
    End If

    termoDigitos = UtilFiltro_SomenteDigitos(termoNorm)
    If Len(termoDigitos) >= 3 Then
        linhaDigitos = UtilFiltro_SomenteDigitos(linhaNorm)
        UtilFiltro_LinhaAtende = (InStr(1, linhaDigitos, termoDigitos, vbBinaryCompare) > 0)
    End If
End Function

Public Function UtilFiltro_ConcatenarLinha( _
    ByVal matriz As Variant, _
    ByVal linha As Long, _
    ByVal colsBusca As Variant _
) As String
    Dim colMin As Long
    Dim colMax As Long
    Dim col As Long
    Dim texto As String

    On Error GoTo fim
    colMin = LBound(matriz, 2)
    colMax = UBound(matriz, 2)

    For col = colMin To colMax
        If UtilFiltro_UsarColuna(colsBusca, col) Then
            texto = texto & " " & SafeListText(matriz(linha, col))
        End If
    Next col

fim:
    UtilFiltro_ConcatenarLinha = Trim$(texto)
End Function

Public Function UtilFiltro_AplicarSobreMatriz( _
    ByVal matriz As Variant, _
    ByVal colsBusca As Variant, _
    ByVal termo As Variant _
) As Variant
    Dim rowMin As Long
    Dim rowMax As Long
    Dim colMin As Long
    Dim colMax As Long
    Dim rowAtual As Long
    Dim colAtual As Long
    Dim rowDestino As Long
    Dim qtd As Long
    Dim linhaTexto As String
    Dim termoNorm As String
    Dim saida As Variant

    If Not IsArray(matriz) Then Exit Function

    On Error GoTo semDados
    rowMin = LBound(matriz, 1)
    rowMax = UBound(matriz, 1)
    colMin = LBound(matriz, 2)
    colMax = UBound(matriz, 2)
    On Error GoTo 0

    termoNorm = UtilFiltro_Normalizar(termo)

    For rowAtual = rowMin To rowMax
        linhaTexto = UtilFiltro_ConcatenarLinha(matriz, rowAtual, colsBusca)
        If UtilFiltro_LinhaAtende(linhaTexto, termoNorm) Then qtd = qtd + 1
    Next rowAtual

    If qtd = 0 Then Exit Function

    ReDim saida(rowMin To rowMin + qtd - 1, colMin To colMax)
    rowDestino = rowMin

    For rowAtual = rowMin To rowMax
        linhaTexto = UtilFiltro_ConcatenarLinha(matriz, rowAtual, colsBusca)
        If UtilFiltro_LinhaAtende(linhaTexto, termoNorm) Then
            For colAtual = colMin To colMax
                saida(rowDestino, colAtual) = matriz(rowAtual, colAtual)
            Next colAtual
            rowDestino = rowDestino + 1
        End If
    Next rowAtual

    UtilFiltro_AplicarSobreMatriz = saida
    Exit Function

semDados:
    UtilFiltro_AplicarSobreMatriz = Empty
End Function

Private Function UtilFiltro_UsarColuna(ByVal colsBusca As Variant, ByVal colAtual As Long) As Boolean
    Dim i As Long
    Dim colInformada As Long

    On Error GoTo usarTodas

    If IsArray(colsBusca) Then
        For i = LBound(colsBusca) To UBound(colsBusca)
            colInformada = CLng(Val(CStr(colsBusca(i))))
            If colInformada = colAtual Then
                UtilFiltro_UsarColuna = True
                Exit Function
            End If
        Next i
        Exit Function
    End If

    colInformada = CLng(Val(CStr(colsBusca)))
    UtilFiltro_UsarColuna = (colInformada = 0 Or colInformada = colAtual)
    Exit Function

usarTodas:
    UtilFiltro_UsarColuna = True
End Function

Private Function UtilFiltro_RemoverAcentos(ByVal texto As String) As String
    Dim s As String

    s = texto
    s = UtilFiltro_TrocarGrupo(s, ChrW$(193) & ChrW$(192) & ChrW$(194) & ChrW$(195) & ChrW$(196) & ChrW$(197), "A")
    s = UtilFiltro_TrocarGrupo(s, ChrW$(201) & ChrW$(200) & ChrW$(202) & ChrW$(203), "E")
    s = UtilFiltro_TrocarGrupo(s, ChrW$(205) & ChrW$(204) & ChrW$(206) & ChrW$(207), "I")
    s = UtilFiltro_TrocarGrupo(s, ChrW$(211) & ChrW$(210) & ChrW$(212) & ChrW$(213) & ChrW$(214), "O")
    s = UtilFiltro_TrocarGrupo(s, ChrW$(218) & ChrW$(217) & ChrW$(219) & ChrW$(220), "U")
    s = UtilFiltro_TrocarGrupo(s, ChrW$(199), "C")
    s = UtilFiltro_TrocarGrupo(s, ChrW$(209), "N")

    UtilFiltro_RemoverAcentos = s
End Function

Private Function UtilFiltro_TrocarGrupo(ByVal texto As String, ByVal grupo As String, ByVal repl As String) As String
    Dim i As Long
    Dim s As String

    s = texto
    For i = 1 To Len(grupo)
        s = Replace(s, Mid$(grupo, i, 1), repl)
    Next i
    UtilFiltro_TrocarGrupo = s
End Function

Private Function UtilFiltro_CompactarEspacos(ByVal texto As String) As String
    Dim s As String

    s = Trim$(texto)
    Do While InStr(1, s, "  ", vbBinaryCompare) > 0
        s = Replace(s, "  ", " ")
    Loop
    UtilFiltro_CompactarEspacos = s
End Function

Private Function UtilFiltro_SomenteDigitos(ByVal texto As String) As String
    Dim i As Long
    Dim ch As String
    Dim saida As String

    For i = 1 To Len(texto)
        ch = Mid$(texto, i, 1)
        If ch >= "0" And ch <= "9" Then saida = saida & ch
    Next i

    UtilFiltro_SomenteDigitos = saida
End Function


