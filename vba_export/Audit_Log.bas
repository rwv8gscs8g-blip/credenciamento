Attribute VB_Name = "Audit_Log"
Option Explicit

' Auditoria V10 — grava eventos na aba AUDIT_LOG usando Const_Colunas.

Public Enum eTipoEvento
    EVT_CAD_EMP = 1
    EVT_CRED_ATIV = 2
    EVT_PREOS_EMITIDA = 3
    EVT_PREOS_RECUSADA = 4
    EVT_PREOS_EXPIRADA = 5
    EVT_OS_EMITIDA = 6
    EVT_OS_FECHADA = 7
    EVT_OS_CANCELADA = 8
    EVT_AVALIACAO = 9
    EVT_SUSPENSAO = 10
    EVT_REATIVACAO = 11
    EVT_INATIVACAO = 12
    EVT_CAD_ENT = 13
    EVT_CRED_REMOVIDO = 14
End Enum

Public Enum eEntidadeAfetada
    ENT_ATIV = 1
    ENT_SERV = 2
    ENT_EMP = 3
    ENT_PREOS = 4
    ENT_OS = 5
    ENT_ENTIDADE = 6
    ENT_CRED = 7
End Enum

' Retorna descrição legível do tipo de evento
Private Function DescricaoEvento(ByVal tipo As eTipoEvento) As String
    Select Case tipo
        Case EVT_CAD_EMP:        DescricaoEvento = "Cadastro de Empresa"
        Case EVT_CRED_ATIV:      DescricaoEvento = "Credenciamento em Atividade"
        Case EVT_PREOS_EMITIDA:  DescricaoEvento = "Pre-OS Emitida"
        Case EVT_PREOS_RECUSADA: DescricaoEvento = "Pre-OS Recusada"
        Case EVT_PREOS_EXPIRADA: DescricaoEvento = "Pre-OS Expirada"
        Case EVT_OS_EMITIDA:     DescricaoEvento = "OS Emitida"
        Case EVT_OS_FECHADA:     DescricaoEvento = "OS Fechada/Avaliada"
        Case EVT_OS_CANCELADA:   DescricaoEvento = "OS Cancelada"
        Case EVT_AVALIACAO:      DescricaoEvento = "Avaliacao Registrada"
        Case EVT_SUSPENSAO:      DescricaoEvento = "Empresa Suspensa"
        Case EVT_REATIVACAO:     DescricaoEvento = "Empresa Reativada"
        Case EVT_INATIVACAO:     DescricaoEvento = "Empresa Inativada"
        Case EVT_CAD_ENT:        DescricaoEvento = "Cadastro de Entidade"
        Case EVT_CRED_REMOVIDO:  DescricaoEvento = "Credenciamento Removido"
        Case Else:               DescricaoEvento = "Evento Desconhecido"
    End Select
End Function

' Retorna descrição legível da entidade afetada
Private Function DescricaoEntidade(ByVal ent As eEntidadeAfetada) As String
    Select Case ent
        Case ENT_ATIV:     DescricaoEntidade = "ATIVIDADE"
        Case ENT_SERV:     DescricaoEntidade = "SERVICO"
        Case ENT_EMP:      DescricaoEntidade = "EMPRESA"
        Case ENT_PREOS:    DescricaoEntidade = "PRE_OS"
        Case ENT_OS:       DescricaoEntidade = "OS"
        Case ENT_ENTIDADE: DescricaoEntidade = "ENTIDADE"
        Case ENT_CRED:     DescricaoEntidade = "CREDENCIAMENTO"
        Case Else:         DescricaoEntidade = "DESCONHECIDO"
    End Select
End Function

' Registra um evento de auditoria na aba AUDIT_LOG.
Public Sub RegistrarEvento( _
    ByVal tipo As eTipoEvento, _
    ByVal Entidade As eEntidadeAfetada, _
    ByVal IdAfetado As String, _
    ByVal Antes As String, _
    ByVal Depois As String, _
    ByVal usuario As String _
)
    Dim ws As Worksheet
    Dim linha As Long

    On Error GoTo fim

    Set ws = ThisWorkbook.Sheets(SHEET_AUDIT)
    linha = UltimaLinhaAba(SHEET_AUDIT) + 1

    ws.Cells(linha, COL_AUDIT_ID).Value = linha - 1
    ws.Cells(linha, COL_AUDIT_DT).Value = Now
    ws.Cells(linha, COL_AUDIT_USUARIO).Value = usuario
    ws.Cells(linha, COL_AUDIT_TIPO).Value = CLng(tipo)
    ws.Cells(linha, COL_AUDIT_TIPO_DESC).Value = DescricaoEvento(tipo)
    ws.Cells(linha, COL_AUDIT_ENTIDADE).Value = DescricaoEntidade(Entidade)
    ws.Cells(linha, COL_AUDIT_ID_AFETADO).Value = IdAfetado
    ws.Cells(linha, COL_AUDIT_ANTES).Value = Antes
    ws.Cells(linha, COL_AUDIT_DEPOIS).Value = Depois

fim:
End Sub

' --- Helpers para serializar tipos ---

Public Function DescreverEmpresa(ByRef emp As TEmpresa) As String
    DescreverEmpresa = "EMP_ID=" & emp.EMP_ID & "; CNPJ=" & emp.cnpj & "; STATUS=" & emp.STATUS_GLOBAL
End Function

Public Function DescreverPreOS(ByRef p As TPreOS) As String
    DescreverPreOS = "PREOS_ID=" & p.PREOS_ID & "; EMP_ID=" & p.EMP_ID & _
        "; ATIV_ID=" & p.ATIV_ID & "; ENT_ID=" & p.ENT_ID & _
        "; QT=" & CStr(p.QT_ESTIMADA) & "; VL=" & CStr(p.VALOR_ESTIMADO) & _
        "; STATUS=" & p.STATUS_PREOS
End Function

Public Function DescreverOS(ByRef O As TOS) As String
    DescreverOS = "OS_ID=" & O.OS_ID & "; PREOS_ID=" & O.PREOS_ID & _
        "; EMP_ID=" & O.EMP_ID & "; ATIV_ID=" & O.ATIV_ID & _
        "; QT_EST=" & CStr(O.QT_ESTIMADA) & "; QT_CONF=" & CStr(O.QT_CONFIRMADA) & _
        "; VL_TOTAL=" & CStr(O.VALOR_TOTAL_OS) & "; STATUS=" & O.STATUS_OS
End Function


