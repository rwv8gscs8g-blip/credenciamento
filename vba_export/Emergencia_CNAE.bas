Attribute VB_Name = "Emergencia_CNAE"
Option Explicit

' =====================================================================
' MACRO EMERGENCIAL V2 — Importa CNAE do CSV para ATIVIDADES.
' Zero dependencias do sistema. Normaliza formato CNAE.
' =====================================================================

Public Sub ImportarCNAE_Emergencia()
    Dim ws As Worksheet
    Dim caminhoCsv As String
    Dim f As Integer
    Dim linha As String
    Dim partes() As String
    Dim r As Long
    Dim desc As String
    Dim k As Long
    Dim primeiraLinha As Boolean
    Dim cnaeVal As String
    Dim sep As String
    Dim ultimaReal As Long

    sep = Application.PathSeparator

    ' 1) Achar o CSV.
    caminhoCsv = ThisWorkbook.Path & sep & "cnae_servicos_normalizado.csv"
    If Dir(caminhoCsv) = "" Then
        caminhoCsv = ThisWorkbook.Path & sep & "doc" & sep & "cnae-normalizado" & sep & "cnae_servicos_normalizado.csv"
    End If
    If Dir(caminhoCsv) = "" Then
        caminhoCsv = Application.GetOpenFilename("CSV (*.csv), *.csv", , "Selecione cnae_servicos_normalizado.csv")
        If caminhoCsv = "False" Or caminhoCsv = "Falso" Then Exit Sub
    End If

    MsgBox "CSV: " & caminhoCsv & vbCrLf & "Clique OK para importar.", vbInformation, "CNAE emergência V2"

    ' 2) Obter aba.
    Set ws = ThisWorkbook.Sheets("ATIVIDADES")

    ' 3) Desproteger.
    On Error Resume Next
    ws.Unprotect Password:=""
    ws.Unprotect Password:="sebrae2024"
    ws.Unprotect Password:="SEBRAE2024"
    On Error GoTo 0

    ' 4) Limpar filtros.
    On Error Resume Next
    If ws.AutoFilterMode Then ws.AutoFilter.ShowAllData
    On Error GoTo 0

    ' 5) Limpar TODA a area de dados (ate ultima linha real, nao so 1500).
    ultimaReal = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    If ultimaReal < 1500 Then ultimaReal = 1500
    ws.Range("A2:C" & ultimaReal).ClearContents

    ' 6) Ler CSV e escrever.
    f = FreeFile
    Open caminhoCsv For Input As #f

    r = 2
    primeiraLinha = True

    Do While Not EOF(f)
        Line Input #f, linha

        If primeiraLinha Then
            primeiraLinha = False
            GoTo proxLinha
        End If

        If Trim$(linha) = "" Then GoTo proxLinha

        partes = Split(linha, ",")
        If UBound(partes) < 2 Then GoTo proxLinha

        ' CNAE (coluna 1 do CSV).
        cnaeVal = Trim$(Replace(partes(1), """", ""))
        ' Normalizar formato: extrair so digitos e reformatar como DDDD-D/DD.
        cnaeVal = NormalizarCNAE(cnaeVal)

        ' Descricao (coluna 2+ do CSV, pode conter virgulas).
        desc = ""
        For k = 2 To UBound(partes)
            If desc <> "" Then desc = desc & ","
            desc = desc & Trim$(Replace(partes(k), """", ""))
        Next k

        If cnaeVal = "" Or desc = "" Then GoTo proxLinha

        ' Escrever.
        ws.Cells(r, 1).NumberFormat = "@"
        ws.Cells(r, 1).Value = Format$(r - 1, "000")
        ws.Cells(r, 2).NumberFormat = "@"
        ws.Cells(r, 2).Value = cnaeVal
        ws.Cells(r, 3).Value = desc
        r = r + 1

        If (r - 2) Mod 100 = 0 Then
            Application.StatusBar = "Importando CNAE... " & (r - 2)
            DoEvents
        End If

proxLinha:
    Loop

    Close #f

    ' 7) Atualizar contador (coluna AR = 44).
    ws.Cells(1, 44).Value = r - 2

    ' 8) Reproteger.
    On Error Resume Next
    ws.Protect Password:="sebrae2024", UserInterfaceOnly:=True
    On Error GoTo 0

    Application.StatusBar = False
    MsgBox "IMPORTAÇÃO CONCLUÍDA: " & (r - 2) & " registros." & vbCrLf & _
           "Fonte: " & caminhoCsv, vbInformation, "CNAE emergência V2"
End Sub

' Extrai somente digitos e reformata como DDDD-D/DD (formato padrao do sistema).
Private Function NormalizarCNAE(ByVal codigo As String) As String
    Dim d As String
    Dim i As Long
    Dim ch As String

    d = ""
    For i = 1 To Len(codigo)
        ch = Mid$(codigo, i, 1)
        If ch >= "0" And ch <= "9" Then d = d & ch
    Next i

    If Len(d) = 7 Then
        NormalizarCNAE = Left$(d, 4) & "-" & Mid$(d, 5, 1) & "/" & Right$(d, 2)
    ElseIf Len(d) = 5 Then
        NormalizarCNAE = Left$(d, 4) & "-" & Right$(d, 1)
    Else
        NormalizarCNAE = Trim$(codigo)
    End If
End Function
