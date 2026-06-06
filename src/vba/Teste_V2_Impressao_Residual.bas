Attribute VB_Name = "Teste_V2_Impressao_Residual"
Option Explicit

Private Const TV2_IR_SUITE As String = "IMPRESSAO_RESIDUAL"
Private Const TV2_IR_DEMANDANTE As String = "Demandante IR 0143"
Private Const TV2_IR_CONTATO As String = "Contato IR"
Private Const TV2_IR_TELEFONE As String = "(11) 99999-0143"
Private Const TV2_IR_TOTAL As Double = 100#

Private Type TTV2IRGlobais
    N_OS As String
    M_NomeEmpresa As String
    Desc_entidade As String
    cont_entidade As String
    telcont_entidade As String
    Empresa_CNPJ As String
    Empresa_endereco As String
    Empresa_email As String
    Empresa_TelCel As String
    Desc_Ativi As String
    Desc_Serv As String
    END_ENTIDADE As String
    QT_ESTIMADA As Double
    Vl_estimado As Double
    NR_Empenho As String
    AvQtH As String
    AvNEmp As String
    AvDtFech As String
    AvVlOs As String
    AvDtPg As String
    AvN01 As String
    Avn02 As String
    AvN03 As String
    AvN04 As String
    AvN05 As String
    AvN06 As String
    AvN07 As String
    AvN08 As String
    AvN09 As String
    AvN10 As String
    AvOb As String
    media As Double
End Type

Public Sub TV2_RunImpressaoResidual(Optional ByVal visual As Boolean = False, Optional ByVal silencioso As Boolean = False)
    Dim inicializado As Boolean
    Dim estadoAntes As TTV2IRGlobais
    Dim okResidual As Boolean
    Dim okTotal As Boolean
    Dim okIdempotente As Boolean
    Dim okDemandante As Boolean
    Dim okPreOSBorda As Boolean
    Dim okAvalBorda As Boolean
    Dim okRanges As Boolean
    Dim detalhesResidual As String
    Dim detalhesTotal As String
    Dim detalhesIdempotente As String
    Dim detalhesDemandante As String
    Dim detalhesPreOSBorda As String
    Dim detalhesAvalBorda As String
    Dim detalhesRanges As String
    Dim erroFatalNumero As Long
    Dim erroFatalDescricao As String

    On Error GoTo falha

    TV2_InitExecucao TV2_IR_SUITE, visual, 6
    inicializado = True

    Call TV2_IR_CapturarGlobais(estadoAntes)
    Call TV2_IR_PrepararGlobais

    okResidual = TV2_IR_SimularTotalOSResidualZero(detalhesResidual)
    PreencherOS
    okTotal = TV2_IR_TotalOSVisualOk(detalhesTotal)
    TV2_LogAssert TV2_IR_SUITE, "IR_01_OS_TOTAL_VISUAL_N63", "AUTO", _
                  "PreencherOS corrige o total visual real da OS", _
                  "EMITE_OS!" & Preencher_RangeTotalOSVisual() & " exibe R$ 100,00 apos residuo zero", _
                  detalhesResidual & "; " & detalhesTotal, _
                  "Fecha o bloqueador da OS 002 pagina 2, onde o total impresso aparecia como traco/zero", _
                  (okResidual And okTotal)

    PreencherOS
    okIdempotente = TV2_IR_TotalOSVisualOk(detalhesIdempotente)
    TV2_LogAssert TV2_IR_SUITE, "IR_02_OS_TOTAL_IDEMPOTENTE", "AUTO", _
                  "Reexecutar PreencherOS preserva total visual", _
                  "EMITE_OS!" & Preencher_RangeTotalOSVisual() & " permanece R$ 100,00", _
                  detalhesIdempotente, _
                  "Garante estabilidade da ponte de impressao em chamadas repetidas da mesma OS", _
                  okIdempotente

    PreencherAvaliacaoOS
    okDemandante = TV2_IR_DemandanteAvaliacaoVisualOk(detalhesDemandante)
    TV2_LogAssert TV2_IR_SUITE, "IR_03_AVALIACAO_DEMANDANTE_L9P15", "AUTO", _
                  "PreencherAvaliacaoOS escreve demandante no range visual real", _
                  "IMP_AVALIA!" & Preencher_RangeDemandanteAvaliacaoVisual() & " contem o demandante esperado", _
                  detalhesDemandante, _
                  "Fecha o bloqueador da AVALIACAO 003, onde L8 era preenchido mas L9:P15 imprimia vazio", _
                  okDemandante

    PreencherPREOS
    okPreOSBorda = TV2_IR_BordasPreOSOk(detalhesPreOSBorda)
    TV2_LogAssert TV2_IR_SUITE, "IR_04_PREOS_BORDA_PRESTADOR", "AUTO", _
                  "PreencherPREOS reaplica bordas pretas continuas no bloco Prestador", _
                  "EMITE_PREOS!" & Preencher_RangeBordaPreOSPrestador() & " tem bordas superiores criticas pretas/continuas", _
                  detalhesPreOSBorda, _
                  "Fecha o marginal visual do PRE-OS 001 em C9/C11", _
                  okPreOSBorda

    okAvalBorda = TV2_IR_BordaAvaliacaoOk(detalhesAvalBorda)
    TV2_LogAssert TV2_IR_SUITE, "IR_05_AVALIACAO_BORDA_VERTICAL", "AUTO", _
                  "PreencherAvaliacaoOS reaplica borda esquerda da faixa vertical", _
                  "IMP_AVALIA!" & Preencher_RangeBordaAvaliacaoVertical() & " tem borda esquerda preta/continua", _
                  detalhesAvalBorda, _
                  "Fecha o marginal visual da faixa AVALIACAO em A25:A45", _
                  okAvalBorda

    okRanges = TV2_IR_RangesContratadosOk(detalhesRanges)
    TV2_LogAssert TV2_IR_SUITE, "IR_06_RANGES_CONTRATADOS", "AUTO", _
                  "Ranges criticos de impressao permanecem explicitamente contratados", _
                  "Demandante=L9:P15; Total=N63:P63; PreOS=C9:C11; Avaliacao=A25:A45", _
                  detalhesRanges, _
                  "Evita regressao silenciosa por troca futura de celula sem atualizar o teste", _
                  okRanges

    Call TV2_IR_LimpezaTemplates
    Call TV2_IR_RestaurarGlobais(estadoAntes)

    TV2_FinalizarExecucao TV2_IR_SUITE, silencioso
    Exit Sub

falha:
    erroFatalNumero = Err.Number
    erroFatalDescricao = Err.Description
    On Error Resume Next
    Call TV2_IR_LimpezaTemplates
    Call TV2_IR_RestaurarGlobais(estadoAntes)
    On Error GoTo 0

    If inicializado Then
        TV2_LogAssert TV2_IR_SUITE, "FATAL", "AUTO", _
                      "Executar suite ImpressaoResidual sem erro fatal", _
                      "Nenhum erro fatal", _
                      "Erro " & CStr(erroFatalNumero) & ": " & erroFatalDescricao, _
                      "Falha fatal precisa ficar rastreavel sem tocar UserForms ou templates manuais", False
        TV2_FinalizarExecucao TV2_IR_SUITE, silencioso
    ElseIf Not silencioso Then
        MsgBox "Erro fatal antes de iniciar TV2 ImpressaoResidual: " & erroFatalDescricao, vbCritical, "Testes V2"
    End If
End Sub

Private Sub TV2_IR_PrepararGlobais()
    N_OS = "0143"
    M_NomeEmpresa = "Empresa IR 0143"
    Desc_entidade = TV2_IR_DEMANDANTE
    cont_entidade = TV2_IR_CONTATO
    telcont_entidade = TV2_IR_TELEFONE
    Empresa_CNPJ = "12.345.678/0001-43"
    Empresa_endereco = "Rua IR, 143"
    Empresa_email = "ir0143@example.test"
    Empresa_TelCel = "(11) 98888-0143"
    Desc_Ativi = "Atividade IR"
    Desc_Serv = "Servico IR"
    END_ENTIDADE = "Endereco demandante IR"
    QT_ESTIMADA = 1
    Vl_estimado = TV2_IR_TOTAL
    NR_Empenho = "EMP-IR-0143"
    AvQtH = "1"
    AvNEmp = NR_Empenho
    AvDtFech = Format$(Date, "dd/mm/yyyy")
    AvVlOs = CStr(TV2_IR_TOTAL)
    AvDtPg = Format$(Date + 10, "dd/mm/yyyy")
    AvN01 = "8"
    Avn02 = "8"
    AvN03 = "8"
    AvN04 = "8"
    AvN05 = "8"
    AvN06 = "8"
    AvN07 = "8"
    AvN08 = "8"
    AvN09 = "8"
    AvN10 = "8"
    AvOb = "Observacao IR 0143"
    media = 8
End Sub

Private Function TV2_IR_SimularTotalOSResidualZero(ByRef detalhes As String) As Boolean
    Dim ws As Worksheet
    Dim estavaProtegida As Boolean
    Dim senhaProtecao As String
    Dim destino As Range

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets("EMITE_OS")
    If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then
        detalhes = "Nao foi possivel liberar EMITE_OS para simular residuo."
        Exit Function
    End If

    Set destino = TV2_IR_CelulaMerge(ws.Range("N63"))
    If Not destino.HasFormula Then destino.Value = 0
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao

    detalhes = "RESIDUO_N63=" & CStr(TV2_IR_ValorMerge(ws.Range("N63")))
    TV2_IR_SimularTotalOSResidualZero = True
    Exit Function

falha:
    On Error Resume Next
    Util_RestaurarProtecaoAba ws, estavaProtegida, senhaProtecao
    On Error GoTo 0
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
End Function

Private Function TV2_IR_TotalOSVisualOk(ByRef detalhes As String) As Boolean
    Dim ws As Worksheet
    Dim valorVisual As Double
    Dim valorFormula As String

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets("EMITE_OS")
    valorVisual = Util_Conversao.ToDouble(CStr(TV2_IR_ValorMerge(ws.Range("N63"))))
    valorFormula = SafeListVal(ws.Range("M63").Text)
    detalhes = "N63_VISUAL=" & CStr(valorVisual) & _
               "; M63_TEXT=" & valorFormula & _
               "; MERGE_N63=" & CStr(ws.Range("N63").MergeCells)
    TV2_IR_TotalOSVisualOk = (Abs(valorVisual - TV2_IR_TOTAL) < 0.0001)
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
End Function

Private Function TV2_IR_DemandanteAvaliacaoVisualOk(ByRef detalhes As String) As Boolean
    Dim ws As Worksheet
    Dim valorL8 As String
    Dim valorVisual As String
    Dim esperado As String

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets("IMP_AVALIA")
    esperado = TV2_IR_DemandanteEsperado()
    valorL8 = SafeListVal(ws.Range("L8").Value)
    valorVisual = SafeListVal(TV2_IR_ValorMerge(ws.Range("L9")))
    detalhes = "L8=" & valorL8 & _
               "; L9_VISUAL=" & valorVisual & _
               "; ESPERADO=" & esperado & _
               "; MERGE_L9=" & CStr(ws.Range("L9").MergeCells)
    TV2_IR_DemandanteAvaliacaoVisualOk = (valorVisual = esperado)
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
End Function

Private Function TV2_IR_BordasPreOSOk(ByRef detalhes As String) As Boolean
    Dim ws As Worksheet
    Dim detC9 As String
    Dim detC11 As String
    Dim okC9 As Boolean
    Dim okC11 As Boolean

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets("EMITE_PREOS")
    okC9 = TV2_IR_BordaPretaContinua(ws.Range("C9").Borders(xlEdgeTop), detC9)
    okC11 = TV2_IR_BordaPretaContinua(ws.Range("C11").Borders(xlEdgeTop), detC11)
    detalhes = "C9_TOP={" & detC9 & "}; C11_TOP={" & detC11 & "}"
    TV2_IR_BordasPreOSOk = (okC9 And okC11)
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
End Function

Private Function TV2_IR_BordaAvaliacaoOk(ByRef detalhes As String) As Boolean
    Dim ws As Worksheet

    On Error GoTo falha

    Set ws = ThisWorkbook.Sheets("IMP_AVALIA")
    TV2_IR_BordaAvaliacaoOk = TV2_IR_BordaPretaContinua(ws.Range(Preencher_RangeBordaAvaliacaoVertical()).Borders(xlEdgeLeft), detalhes)
    Exit Function

falha:
    detalhes = "Erro " & CStr(Err.Number) & ": " & Err.Description
End Function

Private Function TV2_IR_RangesContratadosOk(ByRef detalhes As String) As Boolean
    detalhes = "DEMANDANTE=" & Preencher_RangeDemandanteAvaliacaoVisual() & _
               "; TOTAL_OS=" & Preencher_RangeTotalOSVisual() & _
               "; PREOS_PRESTADOR=" & Preencher_RangeBordaPreOSPrestador() & _
               "; AVAL_VERTICAL=" & Preencher_RangeBordaAvaliacaoVertical()
    TV2_IR_RangesContratadosOk = _
        (Preencher_RangeDemandanteAvaliacaoVisual() = "L9:P15" And _
         Preencher_RangeTotalOSVisual() = "N63:P63" And _
         Preencher_RangeBordaPreOSPrestador() = "C9:C11" And _
         Preencher_RangeBordaAvaliacaoVertical() = "A25:A45")
End Function

Private Function TV2_IR_BordaPretaContinua(ByVal borda As Border, ByRef detalhes As String) As Boolean
    detalhes = "LineStyle=" & CStr(borda.LineStyle) & _
               "; Weight=" & CStr(borda.Weight) & _
               "; Color=" & CStr(borda.Color)
    TV2_IR_BordaPretaContinua = (borda.LineStyle = xlContinuous And borda.Color = vbBlack)
End Function

Private Function TV2_IR_CelulaMerge(ByVal alvo As Range) As Range
    If alvo.MergeCells Then
        Set TV2_IR_CelulaMerge = alvo.MergeArea.Cells(1, 1)
    Else
        Set TV2_IR_CelulaMerge = alvo.Cells(1, 1)
    End If
End Function

Private Function TV2_IR_ValorMerge(ByVal alvo As Range) As Variant
    TV2_IR_ValorMerge = TV2_IR_CelulaMerge(alvo).Value
End Function

Private Function TV2_IR_DemandanteEsperado() As String
    TV2_IR_DemandanteEsperado = TV2_IR_DEMANDANTE & " - " & TV2_IR_CONTATO & " - " & TV2_IR_TELEFONE
End Function

Private Sub TV2_IR_LimpezaTemplates()
    On Error Resume Next
    LimparOS
    LimparPREOS
    LimparAvaliacaoOS
    On Error GoTo 0
End Sub

Private Sub TV2_IR_CapturarGlobais(ByRef st As TTV2IRGlobais)
    st.N_OS = N_OS
    st.M_NomeEmpresa = M_NomeEmpresa
    st.Desc_entidade = Desc_entidade
    st.cont_entidade = cont_entidade
    st.telcont_entidade = telcont_entidade
    st.Empresa_CNPJ = Empresa_CNPJ
    st.Empresa_endereco = Empresa_endereco
    st.Empresa_email = Empresa_email
    st.Empresa_TelCel = Empresa_TelCel
    st.Desc_Ativi = Desc_Ativi
    st.Desc_Serv = Desc_Serv
    st.END_ENTIDADE = END_ENTIDADE
    st.QT_ESTIMADA = QT_ESTIMADA
    st.Vl_estimado = Vl_estimado
    st.NR_Empenho = NR_Empenho
    st.AvQtH = AvQtH
    st.AvNEmp = AvNEmp
    st.AvDtFech = AvDtFech
    st.AvVlOs = AvVlOs
    st.AvDtPg = AvDtPg
    st.AvN01 = AvN01
    st.Avn02 = Avn02
    st.AvN03 = AvN03
    st.AvN04 = AvN04
    st.AvN05 = AvN05
    st.AvN06 = AvN06
    st.AvN07 = AvN07
    st.AvN08 = AvN08
    st.AvN09 = AvN09
    st.AvN10 = AvN10
    st.AvOb = AvOb
    st.media = media
End Sub

Private Sub TV2_IR_RestaurarGlobais(ByRef st As TTV2IRGlobais)
    N_OS = st.N_OS
    M_NomeEmpresa = st.M_NomeEmpresa
    Desc_entidade = st.Desc_entidade
    cont_entidade = st.cont_entidade
    telcont_entidade = st.telcont_entidade
    Empresa_CNPJ = st.Empresa_CNPJ
    Empresa_endereco = st.Empresa_endereco
    Empresa_email = st.Empresa_email
    Empresa_TelCel = st.Empresa_TelCel
    Desc_Ativi = st.Desc_Ativi
    Desc_Serv = st.Desc_Serv
    END_ENTIDADE = st.END_ENTIDADE
    QT_ESTIMADA = st.QT_ESTIMADA
    Vl_estimado = st.Vl_estimado
    NR_Empenho = st.NR_Empenho
    AvQtH = st.AvQtH
    AvNEmp = st.AvNEmp
    AvDtFech = st.AvDtFech
    AvVlOs = st.AvVlOs
    AvDtPg = st.AvDtPg
    AvN01 = st.AvN01
    Avn02 = st.Avn02
    AvN03 = st.AvN03
    AvN04 = st.AvN04
    AvN05 = st.AvN05
    AvN06 = st.AvN06
    AvN07 = st.AvN07
    AvN08 = st.AvN08
    AvN09 = st.AvN09
    AvN10 = st.AvN10
    AvOb = st.AvOb
    media = st.media
End Sub


