Attribute VB_Name = "Util_Conversao"
Option Explicit

' Converte qualquer Variant em String segura para uso em ListBox / UI.
' Não gera erro 380: erros, Null e Empty viram string vazia.
Public Function SafeListText(ByVal v As Variant) As String
    If IsError(v) Or IsNull(v) Or IsEmpty(v) Then
        SafeListText = ""
        Exit Function
    End If
    On Error Resume Next
    SafeListText = CStr(v)
    If Err.Number <> 0 Then SafeListText = ""
    On Error GoTo 0
End Function

' Converte texto monetário ("R$ 1.234,56", "1234.56") em Currency.
' Nunca retorna erro — retorna 0 se inválido.
Public Function ToCurrency(ByVal v As Variant) As Currency
    Dim n As Double
    
    If IsEmpty(v) Or IsNull(v) Then
        ToCurrency = 0
        Exit Function
    End If

    n = ParseNumeroFlex(CStr(v))
    On Error Resume Next
    ToCurrency = CCur(n)
    If Err.Number <> 0 Then ToCurrency = 0
    On Error GoTo 0
End Function

' Converte texto de data em Date.
' Retorna 0 se inválido.
Public Function ToDate(ByVal v As Variant) As Date
    If IsEmpty(v) Or IsNull(v) Then
        ToDate = 0
        Exit Function
    End If
    
    If IsDate(v) Then
        ToDate = CDate(v)
        Exit Function
    End If
    
    On Error Resume Next
    ToDate = CDate(CStr(v))
    If Err.Number <> 0 Then ToDate = 0
    On Error GoTo 0
End Function

' Converte Variant em Double seguro.
Public Function ToDouble(ByVal v As Variant) As Double
    If IsEmpty(v) Or IsNull(v) Then
        ToDouble = 0
        Exit Function
    End If

    If IsNumeric(v) Then
        ToDouble = CDbl(v)
    Else
        ToDouble = ParseNumeroFlex(CStr(v))
    End If
End Function

' Converte Variant em Long seguro.
Public Function ToLong(ByVal v As Variant) As Long
    On Error Resume Next
    ToLong = CLng(v)
    If Err.Number <> 0 Then ToLong = 0
    On Error GoTo 0
End Function

Private Function ParseNumeroFlex(ByVal bruto As String) As Double
    Dim s As String
    Dim limpo As String
    Dim i As Long
    Dim ch As String
    Dim posVirg As Long
    Dim posPonto As Long
    Dim sepDec As String
    Dim sepMil As String
    Dim p As Long
    Dim neg As Boolean

    s = Trim$(bruto)
    If s = "" Then Exit Function

    s = Replace(s, "R$", "", , , vbTextCompare)
    s = Replace(s, "US$", "", , , vbTextCompare)
    s = Replace(s, "$", "")
    s = Replace(s, Chr$(160), "")
    s = Replace(s, " ", "")

    If Left$(s, 1) = "(" And Right$(s, 1) = ")" Then
        neg = True
        s = Mid$(s, 2, Len(s) - 2)
    End If

    For i = 1 To Len(s)
        ch = Mid$(s, i, 1)
        If (ch >= "0" And ch <= "9") Or ch = "," Or ch = "." Or ch = "-" Then
            limpo = limpo & ch
        End If
    Next i

    If limpo = "" Or limpo = "-" Then Exit Function

    If Left$(limpo, 1) = "-" Then
        neg = True
        limpo = Mid$(limpo, 2)
    End If

    posVirg = InStrRev(limpo, ",")
    posPonto = InStrRev(limpo, ".")

    If posVirg > 0 And posPonto > 0 Then
        If posVirg > posPonto Then
            sepDec = ","
            sepMil = "."
        Else
            sepDec = "."
            sepMil = ","
        End If
    ElseIf posVirg > 0 Then
        If Len(limpo) - posVirg <= 2 Then
            sepDec = ","
        Else
            sepMil = ","
        End If
    ElseIf posPonto > 0 Then
        If Len(limpo) - posPonto <= 2 Then
            sepDec = "."
        Else
            sepMil = "."
        End If
    End If

    If sepMil <> "" Then limpo = Replace(limpo, sepMil, "")

    If sepDec <> "" Then
        p = InStrRev(limpo, sepDec)
        If p > 0 Then
            limpo = Replace(limpo, sepDec, "")
            If Len(limpo) >= p Then
                limpo = Left$(limpo, p - 1) & "." & Mid$(limpo, p)
            End If
        End If
    End If

    On Error Resume Next
    ParseNumeroFlex = CDbl(Val(limpo))
    If Err.Number <> 0 Then ParseNumeroFlex = 0
    On Error GoTo 0

    If neg Then ParseNumeroFlex = ParseNumeroFlex * -1
End Function


