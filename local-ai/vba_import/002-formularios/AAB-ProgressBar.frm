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
    Application.CutCopyMode = False 'Limpa a �rea de transfer�ncia
    
    Call CalculateData
    Application.Cursor = xlDefault
    
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

Dim TotaL1, Total2, y, x    As Integer
Dim cont, i, a, b           As Long

    TotaL1 = 1
    Total2 = 10
    a = 0.1
        
    On Error Resume Next
    For y = 1 To Total2
        Barra_Carrega.Width = (y / Total2) * 248
        DoEvents
        
        Percent_Label.caption = "Processando: " & Format(y / a, "00") & "%"
        If (y / a) >= 85 Then
            Percent_Label.caption = "Finalizando: " & Format(y / a, "00") & "%"
        End If
    Next y

    Total2 = Empty
    x = Empty
    y = Empty

Exit Sub
erro_carregamento:
End Sub


