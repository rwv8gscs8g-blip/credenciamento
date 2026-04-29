VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} ProgressBar 
   Caption         =   "Processamento"
   ClientHeight    =   987
   ClientLeft      =   63
   ClientTop       =   434
   ClientWidth     =   5565
   OleObjectBlob   =   "ProgressBar.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "ProgressBar"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False





Option Explicit

Private Sub UserForm_QueryClose(Cancel As Integer, CloseMode As Integer)
    If CloseMode = vbFormControlMenu Then
        Cancel = True
    End If
End Sub

Private Sub UserForm_Activate()
On Error GoTo erro_carregamento

    Application.Cursor = xlWait
    ProgressBar.MousePointer = fmMousePointerHourGlass
    Application.CutCopyMode = False 'Limpa a área de transferência
    
    Call CalculateData
    Application.Cursor = xlDefault
    
    'Application.ThisWorkbook.Save

    Unload Me
    
Exit Sub
erro_carregamento:
End Sub

Private Sub UserForm_Initialize()
On Error GoTo erro_carregamento
    
    Barra_Carrega.Width = 0
        
Exit Sub
erro_carregamento:
End Sub

Sub CalculateData()
On Error GoTo erro_carregamento

Dim TotaL1, Total2, Y, X    As Integer
Dim Cont, i, a, b           As Long

    TotaL1 = 1
    Total2 = 10
    a = 0.1
        
    On Error Resume Next
    For Y = 1 To Total2
        Barra_Carrega.Width = (Y / Total2) * 248
        DoEvents
        
        Percent_Label.Caption = "Calculando: " & Format(Y / a, "00") & "%"
        If (Y / a) >= 85 Then
            Percent_Label.Caption = "Salvando dados..." & Format(Y / a, "00") & "%"
            If (Y / a) = 90 Then
                Application.ThisWorkbook.Save
            End If
        End If
        'Fração de Segundo
        For Cont = 1 To 1
            timedelay (0.01)
        Next Cont
    Next Y

    Total2 = Empty
    X = Empty
    Y = Empty

Exit Sub
erro_carregamento:
End Sub

Sub timedelay(segundos As Double)
On Error GoTo erro_carregamento

Dim X As Single
Dim i As Long
    
    X = DateTime.Timer
    
    While DateTime.Timer - X < segundos
        
    Wend

Exit Sub
erro_carregamento:
End Sub


