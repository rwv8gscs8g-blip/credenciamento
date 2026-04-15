Attribute VB_Name = "Funcoes"
Option Explicit

Public Function NormalizarTextoPTBR(ByVal valor As Variant) As String
    Dim s As String

    s = Trim$(CStr(valor))
    If s = "" Then
        NormalizarTextoPTBR = ""
        Exit Function
    End If

    s = CorrigirMojibakeUtf8(s)
    s = CorrigirAcentoTeclado(s)

    Do While InStr(1, s, "  ", vbBinaryCompare) > 0
        s = Replace(s, "  ", " ")
    Loop

    NormalizarTextoPTBR = Trim$(s)
End Function
Public Function cnpj(ByVal KeyAscii As MSForms.ReturnInteger, texto As String) As String
Select Case KeyAscii
Case 8, 48 To 57
If Len(texto) = 18 Then KeyAscii = 0
If Len(texto) = 2 Then texto = texto & "."
If Len(texto) = 6 Then texto = texto & "."
If Len(texto) = 10 Then texto = texto & "/"
If Len(texto) = 15 Then texto = texto & "-"
Case Else
KeyAscii = 0
End Select
cnpj = texto
End Function

Public Function cpf(ByVal KeyAscii As MSForms.ReturnInteger, texto As String) As String
Select Case KeyAscii
Case 8, 48 To 57
If Len(texto) = 14 Then KeyAscii = 0
If Len(texto) = 3 Then texto = texto & "."
If Len(texto) = 7 Then texto = texto & "."
If Len(texto) = 11 Then texto = texto & "-"
Case Else
KeyAscii = 0
End Select
cpf = texto
End Function

Public Function cep(ByVal KeyAscii As MSForms.ReturnInteger, texto As String) As String
Select Case KeyAscii
Case 8, 48 To 57
If Len(texto) = 9 Then KeyAscii = 0
If Len(texto) = 5 Then texto = texto & "-"
Case Else
KeyAscii = 0
End Select
cep = texto
End Function

Public Function telFixo(ByVal KeyAscii As MSForms.ReturnInteger, texto As String) As String
Select Case KeyAscii
Case 8, 48 To 57
If Len(texto) = 13 Then KeyAscii = 0
If Len(texto) = 2 Then texto = "(" & texto & ")"
If Len(texto) = 8 Then texto = texto & "-"
Case Else
KeyAscii = 0
End Select
telFixo = texto
End Function

Public Function telCel(ByVal KeyAscii As MSForms.ReturnInteger, texto As String) As String
Select Case KeyAscii
Case 8, 48 To 57
If Len(texto) = 14 Then KeyAscii = 0
If Len(texto) = 2 Then texto = "(" & texto & ")"
If Len(texto) = 9 Then texto = texto & "-"
Case Else
KeyAscii = 0
End Select
telCel = texto
End Function
Public Function Ent_Data(ByVal KeyAscii As MSForms.ReturnInteger, texto As String) As String
Select Case KeyAscii
Case 8, 48 To 57
If Len(texto) = 10 Then KeyAscii = 0
If Len(texto) = 2 Then texto = texto & "/"
If Len(texto) = 5 Then texto = texto & "/"
Case Else
KeyAscii = 0
End Select
Ent_Data = texto
End Function

Private Function CorrigirAcentoTeclado(ByVal s As String) As String
    s = Replace(s, ChrW$(&H2019), "'")
    s = Replace(s, ChrW$(&H2018), "'")
    s = Replace(s, ChrW$(&HB4), "'")
    s = Replace(s, ChrW$(&H60), "`")

    s = Replace(s, "'a", ChrW$(&HE1))
    s = Replace(s, "'e", ChrW$(&HE9))
    s = Replace(s, "'i", ChrW$(&HED))
    s = Replace(s, "'o", ChrW$(&HF3))
    s = Replace(s, "'u", ChrW$(&HFA))
    s = Replace(s, "'A", ChrW$(&HC1))
    s = Replace(s, "'E", ChrW$(&HC9))
    s = Replace(s, "'I", ChrW$(&HCD))
    s = Replace(s, "'O", ChrW$(&HD3))
    s = Replace(s, "'U", ChrW$(&HDA))

    s = Replace(s, "`a", ChrW$(&HE0))
    s = Replace(s, "`e", ChrW$(&HE8))
    s = Replace(s, "`i", ChrW$(&HEC))
    s = Replace(s, "`o", ChrW$(&HF2))
    s = Replace(s, "`u", ChrW$(&HF9))
    s = Replace(s, "`A", ChrW$(&HC0))
    s = Replace(s, "`E", ChrW$(&HC8))
    s = Replace(s, "`I", ChrW$(&HCC))
    s = Replace(s, "`O", ChrW$(&HD2))
    s = Replace(s, "`U", ChrW$(&HD9))

    s = Replace(s, "^a", ChrW$(&HE2))
    s = Replace(s, "^e", ChrW$(&HEA))
    s = Replace(s, "^i", ChrW$(&HEE))
    s = Replace(s, "^o", ChrW$(&HF4))
    s = Replace(s, "^u", ChrW$(&HFB))
    s = Replace(s, "^A", ChrW$(&HC2))
    s = Replace(s, "^E", ChrW$(&HCA))
    s = Replace(s, "^I", ChrW$(&HCE))
    s = Replace(s, "^O", ChrW$(&HD4))
    s = Replace(s, "^U", ChrW$(&HDB))

    s = Replace(s, "~a", ChrW$(&HE3))
    s = Replace(s, "~o", ChrW$(&HF5))
    s = Replace(s, "~n", ChrW$(&HF1))
    s = Replace(s, "~A", ChrW$(&HC3))
    s = Replace(s, "~O", ChrW$(&HD5))
    s = Replace(s, "~N", ChrW$(&HD1))

    s = Replace(s, ",c", ChrW$(&HE7))
    s = Replace(s, ",C", ChrW$(&HC7))
    s = Replace(s, "'c", ChrW$(&HE7))
    s = Replace(s, "'C", ChrW$(&HC7))

    ' Heuristica comum no teclado com dead-key via VM: "Munic'pio" -> "Municipio" com acento.
    s = Replace(s, "c'pi", ChrW$(&HED) & "pi")
    s = Replace(s, "C'PI", ChrW$(&HCD) & "PI")

    CorrigirAcentoTeclado = s
End Function

Private Function CorrigirMojibakeUtf8(ByVal s As String) As String
    s = Replace(s, ChrW$(&HC3) & ChrW$(&HA1), ChrW$(&HE1))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&HA9), ChrW$(&HE9))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&HAD), ChrW$(&HED))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&HB3), ChrW$(&HF3))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&HBA), ChrW$(&HFA))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&HA2), ChrW$(&HE2))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&HAA), ChrW$(&HEA))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&HB4), ChrW$(&HF4))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&HA0), ChrW$(&HE0))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&HA3), ChrW$(&HE3))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&HB5), ChrW$(&HF5))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&HA7), ChrW$(&HE7))

    s = Replace(s, ChrW$(&HC3) & ChrW$(&H81), ChrW$(&HC1))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&H89), ChrW$(&HC9))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&H8D), ChrW$(&HCD))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&H93), ChrW$(&HD3))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&H9A), ChrW$(&HDA))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&H82), ChrW$(&HC2))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&H8A), ChrW$(&HCA))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&H94), ChrW$(&HD4))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&H80), ChrW$(&HC0))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&H83), ChrW$(&HC3))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&H95), ChrW$(&HD5))
    s = Replace(s, ChrW$(&HC3) & ChrW$(&H87), ChrW$(&HC7))

    s = Replace(s, ChrW$(&HC2), "")
    s = Replace(s, ChrW$(&HFFFD), "")

    CorrigirMojibakeUtf8 = s
End Function

Public Function Pad3(ByVal numero As Long) As String
    Pad3 = Right$("000" & CStr(numero), 3)
End Function

