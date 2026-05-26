Attribute VB_Name = "Util_Excel_Performance"
Option Explicit

' ============================================================
' Util_Excel_Performance
'
' Wrapper de otimizacao Excel para blocos de escrita pesada.
' Util_IniciarBlocoRapido le os 4 flags Application atuais, retorna
' Variant array(0..3) com o estado, e desliga os flags;
' Util_FinalizarBlocoRapido aceita esse Variant e restaura cada
' flag ao valor salvo - NAO forca xlCalculationAutomatic cego
' (preserva configuracao do operador).
'
' Indices do Variant array:
'   (0) ScreenUpdating  As Boolean
'   (1) Calculation     As XlCalculation
'   (2) EnableEvents    As Boolean
'   (3) DisplayAlerts   As Boolean
'
' Usa Variant em vez de Public Type por causa do guard Glasswing G8
' (Public Type apenas em Mod_Types.bas, que e tabu fora da Onda 9).
'
' Uso tipico em rotina de cadastro:
'
'     Public Function Inserir(...) As TResult
'         Dim estadoExcel As Variant
'         estadoExcel = Util_IniciarBlocoRapido()
'         On Error GoTo erro
'         ' ... 15-20 escritas celula-a-celula ...
'         Util_FinalizarBlocoRapido estadoExcel
'         Exit Function
'     erro:
'         Util_FinalizarBlocoRapido estadoExcel
'         ' ... handler de erro ...
'     End Function
'
' Estimativa em PC antigo: 10-30x mais rapido para rotinas com
' 5+ escritas sequenciais (cada Cells(..).Value = ... triggera
' recalc + repaint + eventos sem o wrapper).
'
' Onda 38.2.1-AR1-FIX2-PERF, 2026-05-26
' ============================================================

' ------------------------------------------------------------
' Util_IniciarBlocoRapido
' Le os 4 flags atuais, retorna Variant array(0..3) e desliga os flags.
' ------------------------------------------------------------
Public Function Util_IniciarBlocoRapido() As Variant
    Dim st(0 To 3) As Variant
    st(0) = Application.ScreenUpdating
    st(1) = Application.Calculation
    st(2) = Application.EnableEvents
    st(3) = Application.DisplayAlerts
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    Application.EnableEvents = False
    Application.DisplayAlerts = False
    Util_IniciarBlocoRapido = st
End Function

' ------------------------------------------------------------
' Util_FinalizarBlocoRapido
' Restaura os 4 flags ao estado salvo no Variant array.
' Tolerante a Empty/Null/array invalido (no-op silencioso) para
' permitir chamadas em handler de erro sem checagem extra.
' ------------------------------------------------------------
Public Sub Util_FinalizarBlocoRapido(ByVal st As Variant)
    If IsEmpty(st) Or IsNull(st) Then Exit Sub
    If Not IsArray(st) Then Exit Sub

    On Error Resume Next
    Application.ScreenUpdating = st(0)
    Application.Calculation = st(1)
    Application.EnableEvents = st(2)
    Application.DisplayAlerts = st(3)
    On Error GoTo 0
End Sub


