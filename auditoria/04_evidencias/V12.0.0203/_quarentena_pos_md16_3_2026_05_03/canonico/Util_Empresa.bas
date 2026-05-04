Attribute VB_Name = "Util_Empresa"
Option Explicit

' ============================================================
' Util_Empresa - Onda 16 MD-16.4 (V12.0.0203)
' Helpers de leitura de dados de EMPRESA pelo EMP_ID.
' Reaproveita SHEET_EMPRESAS, COL_EMP_ID, COL_EMP_CNPJ de Const_Colunas.
' Nao toca em Mod_Types.bas (TABU C4).
' ============================================================

' Retorna o CNPJ normalizado (so digitos) da empresa identificada por
' empId. Procura primeiro em SHEET_EMPRESAS, depois em
' SHEET_EMPRESAS_INATIVAS (auditoria forense pode precisar reportar
' PDFs de empresas que ja foram inativadas).
'
' Retorna "" quando empId vazio, sheet ausente, ou nenhum match.
' Tolera padding alfanumerico ("1" vs "001") via comparacao
' case-insensitive em StrComp.
Public Function Util_Empresa_GetCnpjPorId(ByVal empId As String) As String
    On Error GoTo falha

    Dim cnpjBruto As String

    If Trim$(empId) = "" Then
        Util_Empresa_GetCnpjPorId = ""
        Exit Function
    End If

    cnpjBruto = LookupCnpjEmSheet(SHEET_EMPRESAS, empId)
    If Trim$(cnpjBruto) = "" Then
        cnpjBruto = LookupCnpjEmSheet(SHEET_EMPRESAS_INATIVAS, empId)
    End If

    Util_Empresa_GetCnpjPorId = Util_NormalizarDocumentoChave(cnpjBruto)
    Exit Function

falha:
    Util_Empresa_GetCnpjPorId = ""
End Function

Private Function LookupCnpjEmSheet(ByVal nomeSheet As String, ByVal empId As String) As String
    On Error GoTo falha

    Dim ws As Worksheet
    Dim ultima As Long
    Dim r As Long
    Dim idLinha As String
    Dim alvo As String

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(nomeSheet)
    On Error GoTo 0

    If ws Is Nothing Then
        LookupCnpjEmSheet = ""
        Exit Function
    End If

    ultima = ws.Cells(ws.Rows.count, COL_EMP_ID).End(xlUp).row
    If ultima < 2 Then
        LookupCnpjEmSheet = ""
        Exit Function
    End If

    alvo = Trim$(CStr(empId))

    For r = 2 To ultima
        idLinha = Trim$(CStr(ws.Cells(r, COL_EMP_ID).Value))
        If StrComp(idLinha, alvo, vbTextCompare) = 0 Then
            LookupCnpjEmSheet = CStr(ws.Cells(r, COL_EMP_CNPJ).Value)
            Exit Function
        End If
    Next r

    LookupCnpjEmSheet = ""
    Exit Function

falha:
    LookupCnpjEmSheet = ""
End Function

