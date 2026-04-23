VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} Altera_Entidade 
   Caption         =   "Altera / Inativa Entidade"
   ClientHeight    =   4977
   ClientLeft      =   119
   ClientTop       =   462
   ClientWidth     =   14357
   OleObjectBlob   =   "Altera_Entidade.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "Altera_Entidade"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False




Private m_entidadeId As String

Public Sub DefinirIdEdicaoEntidade(ByVal entidadeId As String)
    m_entidadeId = Trim$(entidadeId)
End Sub

Private Sub B_Altera_Entidade_Click()
On Error GoTo erro_carregamento:
    ' V12: eliminado .Select + Application.GoTo + ActiveCell (proibidos; formulario modal).
    ' Usa busca direta por ID persistido no proprio formulario.
    Dim wsEnt As Worksheet
    Dim linhaAtual As Long
    Dim linhaFinal As Long
    Dim estProt As Boolean
    Dim senhaProt As String

    If C_Entidade = Empty Then
        MsgBox "Informe o nome da Entidade!", vbExclamation, "Altera" & ChrW(231) & ChrW(227) & "o"
        C_Entidade.BackColor = &HFFFF&
        C_Entidade.SetFocus
        Exit Sub
    End If

    If m_entidadeId = "" Then
        MsgBox "ID da entidade n" & ChrW(227) & "o identificado. Feche e reabra o formul" & ChrW(225) & "rio.", _
               vbExclamation, "Altera" & ChrW(231) & ChrW(227) & "o"
        Exit Sub
    End If

    If MsgBox("Deseja realmente continuar?", vbQuestion + vbYesNo, "Altera" & ChrW(231) & ChrW(227) & "o") <> vbYes Then Exit Sub

    Set wsEnt = ThisWorkbook.Sheets(SHEET_ENTIDADE)
    linhaFinal = UltimaLinhaAba(SHEET_ENTIDADE)
    Set EncontrarID = Nothing

    For linhaAtual = LINHA_DADOS To linhaFinal
        If Trim$(CStr(wsEnt.Cells(linhaAtual, COL_ENT_ID).Value)) <> "" Then
            If CLng(Val("0" & Trim$(CStr(wsEnt.Cells(linhaAtual, COL_ENT_ID).Value)))) = _
               CLng(Val("0" & m_entidadeId)) Then
                Set EncontrarID = wsEnt.Cells(linhaAtual, COL_ENT_ID)
                Exit For
            End If
        End If
    Next linhaAtual

    If EncontrarID Is Nothing Then
        MsgBox "Entidade n" & ChrW(227) & "o encontrada na aba ENTIDADE.", vbExclamation, "Altera" & ChrW(231) & ChrW(227) & "o"
        Exit Sub
    End If

    Call Util_PrepararAbaParaEscrita(wsEnt, estProt, senhaProt)
    EncontrarID.Offset(0, 1).Value = C_CNPJ
    EncontrarID.Offset(0, 2).Value = Funcoes.NormalizarTextoPTBR(C_Entidade.Value)
    EncontrarID.Offset(0, 3).Value = C_Tel_Fixo
    EncontrarID.Offset(0, 4).Value = C_Tel_Cel
    EncontrarID.Offset(0, 5).Value = Format(C_Email)
    EncontrarID.Offset(0, 6).Value = Funcoes.NormalizarTextoPTBR(C_Endereco.Value)
    EncontrarID.Offset(0, 7).Value = Funcoes.NormalizarTextoPTBR(C_Bairro.Value)
    EncontrarID.Offset(0, 8).Value = Funcoes.NormalizarTextoPTBR(C_Municipio.Value)
    EncontrarID.Offset(0, 9).Value = C_CEP
    EncontrarID.Offset(0, 10).Value = Format(C_UF)
    EncontrarID.Offset(0, 11).Value = Funcoes.NormalizarTextoPTBR(C_Contato1.Value)
    EncontrarID.Offset(0, 12).Value = C_Fone_Cont1
    EncontrarID.Offset(0, 13).Value = Funcoes.NormalizarTextoPTBR(C_Func_Cont1.Value)
    EncontrarID.Offset(0, 14).Value = Funcoes.NormalizarTextoPTBR(C_Contato2.Value)
    EncontrarID.Offset(0, 15).Value = C_Fone_Cont2
    EncontrarID.Offset(0, 16).Value = Funcoes.NormalizarTextoPTBR(C_Func_Cont2.Value)
    EncontrarID.Offset(0, 17).Value = Funcoes.NormalizarTextoPTBR(C_Contato3.Value)
    EncontrarID.Offset(0, 18).Value = C_Fone_Cont3
    EncontrarID.Offset(0, 19).Value = Funcoes.NormalizarTextoPTBR(C_Func_Cont3.Value)
    EncontrarID.Offset(0, 20).Value = Funcoes.NormalizarTextoPTBR(C_InfoAD.Value)
    EncontrarID.Offset(0, 21).Value = CDate(Now)
    Call Util_RestaurarProtecaoAba(wsEnt, estProt, senhaProt)

    Call AtualizarListaEntidadeMenuAtual
    Unload Me
Exit Sub
erro_carregamento:
    On Error Resume Next
    Call Util_RestaurarProtecaoAba(wsEnt, estProt, senhaProt)
    On Error GoTo 0
End Sub

Private Sub C_Inativa_Entidade_Click()
On Error GoTo erro_carregamento:
    ' V12: eliminado .Select + ActiveCell + Selection (proibidos; formulario modal).
    ' Opera por ID persistido no proprio formulario para evitar instancias erradas do menu.
    Dim wsEnt As Worksheet
    Dim wsEntInativas As Worksheet
    Dim linhaEntInativa As Long
    Dim linhaAtual As Long
    Dim linhaFinal As Long
    Dim estEntInativProt As Boolean
    Dim senhaEntInativ As String
    Dim linhasMesmaChave As Variant
    Dim qtdLinhasMesmaChave As Long
    Dim baseLinhas As Long
    Dim cnpjEntidade As String
    Dim linhasDel() As Long
    Dim nDel As Long
    Dim k As Long
    Dim j As Long
    Dim tmp As Long

    If m_entidadeId = "" Then
        MsgBox "ID da entidade n" & ChrW(227) & "o identificado. Feche e reabra o formul" & ChrW(225) & "rio.", _
               vbExclamation, "Inativar Entidade"
        Exit Sub
    End If

    If MsgBox("Tem certeza que deseja Inativar esta Entidade?", vbQuestion + vbYesNo, "Inativar Entidade") <> vbYes Then Exit Sub

    Set wsEnt = ThisWorkbook.Sheets(SHEET_ENTIDADE)
    Set wsEntInativas = ThisWorkbook.Sheets(SHEET_ENTIDADE_INATIVOS)

    linhaFinal = UltimaLinhaAba(SHEET_ENTIDADE)
    Set EncontrarID = Nothing
    For linhaAtual = LINHA_DADOS To linhaFinal
        If Trim$(CStr(wsEnt.Cells(linhaAtual, COL_ENT_ID).Value)) <> "" Then
            If CLng(Val("0" & Trim$(CStr(wsEnt.Cells(linhaAtual, COL_ENT_ID).Value)))) = _
               CLng(Val("0" & m_entidadeId)) Then
                Set EncontrarID = wsEnt.Cells(linhaAtual, COL_ENT_ID)
                Exit For
            End If
        End If
    Next linhaAtual

    If EncontrarID Is Nothing Then
        MsgBox "Entidade n" & ChrW(227) & "o encontrada.", vbExclamation, "Inativação"
        Exit Sub
    End If

    cnpjEntidade = Trim$(CStr(EncontrarID.Offset(0, 1).Value))
    linhasMesmaChave = Util_EntidadeInativos_ColetarLinhasMesmaChave(wsEntInativas, LINHA_DADOS, CStr(EncontrarID.Value), cnpjEntidade)
    If IsArray(linhasMesmaChave) Then
        baseLinhas = LBound(linhasMesmaChave)
        qtdLinhasMesmaChave = UBound(linhasMesmaChave) - baseLinhas + 1
        nDel = qtdLinhasMesmaChave
        If nDel > 0 Then
            ReDim linhasDel(1 To nDel)
            For k = 1 To nDel
                linhasDel(k) = CLng(linhasMesmaChave(baseLinhas + k - 1))
            Next k
            For k = 1 To nDel - 1
                For j = k + 1 To nDel
                    If linhasDel(k) < linhasDel(j) Then
                        tmp = linhasDel(k)
                        linhasDel(k) = linhasDel(j)
                        linhasDel(j) = tmp
                    End If
                Next j
            Next k

            Call Util_PrepararAbaParaEscrita(wsEntInativas, estEntInativProt, senhaEntInativ)
            For k = 1 To nDel
                If Not Util_ExcluirLinhaSegura(wsEntInativas, linhasDel(k)) Then
                    Err.Raise 1004, "Entidade_InativarSelecionada", "Nao foi possivel excluir linha " & CStr(linhasDel(k)) & " em ENTIDADE_INATIVOS."
                End If
            Next k
            Call Util_RestaurarProtecaoAba(wsEntInativas, estEntInativProt, senhaEntInativ)
        End If
    End If

    ' Copiar linha para aba de inativas (sem .Select)
    linhaEntInativa = wsEntInativas.Cells(wsEntInativas.Rows.count, 1).End(xlUp).row + 1
    Call Util_PrepararAbaParaEscrita(wsEntInativas, estEntInativProt, senhaEntInativ)
    EncontrarID.EntireRow.Copy Destination:=wsEntInativas.Cells(linhaEntInativa, 1)
    Call Util_RestaurarProtecaoAba(wsEntInativas, estEntInativProt, senhaEntInativ)
    Application.CutCopyMode = False

    ' Remover linha da aba ativa
    Call Util_PrepararAbaParaEscrita(wsEnt, estEntInativProt, senhaEntInativ)
    If Not Util_ExcluirLinhaSegura(wsEnt, EncontrarID.row) Then
        Err.Raise 1004, "Entidade_InativarSelecionada", "Nao foi possivel excluir a linha da entidade na aba ENTIDADE."
    End If
    Call Util_RestaurarProtecaoAba(wsEnt, estEntInativProt, senhaEntInativ)

    Call ClassificaEntidade
    MsgBox "Entidade Inativada com sucesso!", vbExclamation, "Inativa" & ChrW(231) & ChrW(227) & "o"
    Unload Me
Exit Sub
erro_carregamento:
    On Error Resume Next
    Call Util_RestaurarProtecaoAba(wsEntInativas, estEntInativProt, senhaEntInativ)
    Call Util_RestaurarProtecaoAba(wsEnt, estEntInativProt, senhaEntInativ)
    On Error GoTo 0
    MsgBox "Erro ao inativar entidade: " & Err.Description, vbCritical, "Erro"
End Sub

Private Sub C_Contato1_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
        
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Fone_Cont1_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

C_Fone_Cont1.Text = Funcoes.telCel(KeyAscii, C_Fone_Cont1.Text)

erro_carregamento:
End Sub

Private Sub C_Func_Cont1_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
        
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Contato2_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
        
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Fone_Cont2_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

C_Fone_Cont2.Text = Funcoes.telCel(KeyAscii, C_Fone_Cont2.Text)

erro_carregamento:
End Sub

Private Sub C_Func_Cont2_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
        
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Contato3_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
        
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Fone_Cont3_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

C_Fone_Cont3.Text = Funcoes.telCel(KeyAscii, C_Fone_Cont3.Text)

erro_carregamento:
End Sub

Private Sub C_Func_Cont3_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
        
Exit Sub
erro_carregamento:
End Sub

Private Sub C_Endereco_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
        
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Bairro_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
        
Exit Sub
erro_carregamento:
End Sub

Private Sub C_Municipio_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
        
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Municipio_AfterUpdate()
On Error GoTo erro_carregamento:
C_Municipio.Value = Funcoes.NormalizarTextoPTBR(C_Municipio.Value)
Exit Sub
erro_carregamento:
End Sub
Private Sub C_UF_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
    Select Case KeyAscii
        Case 8, 65 To 90, 97 To 122
        Case Else
        KeyAscii = 0
    End Select
   ' Permitir acentuacao em PT-BR (V5)
        
Exit Sub
End Sub

Private Sub C_InfoAD_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
        
Exit Sub
erro_carregamento:
End Sub
Private Sub C_Entidade_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

   ' Permitir acentuacao em PT-BR (V5)
        
Exit Sub
erro_carregamento:
End Sub
Private Sub C_CNPJ_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:
C_CNPJ.Text = Funcoes.cnpj(KeyAscii, C_CNPJ.Text)
erro_carregamento:
End Sub
Private Sub C_Tel_Fixo_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

C_Tel_Fixo.Text = Funcoes.telFixo(KeyAscii, C_Tel_Fixo.Text)

erro_carregamento:
End Sub
Private Sub C_Tel_Cel_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:

C_Tel_Cel.Text = Funcoes.telCel(KeyAscii, C_Tel_Cel.Text)

erro_carregamento:
End Sub
Private Sub C_CEP_KeyPress(ByVal KeyAscii As MSForms.ReturnInteger)
On Error GoTo erro_carregamento:
C_CEP.Text = Funcoes.cep(KeyAscii, C_CEP.Text)
erro_carregamento:
End Sub


