Attribute VB_Name = "Svc_Avaliacao"
Option Explicit

' Serviço de Avaliação de OS - V10
' Implementa: AvaliarOS.
' Registra 10 notas (0-10), calcula média e fecha OS como CONCLUIDA.
' Sem Select/ActiveCell/On Error Resume Next silencioso.

Private Const STATUS_OS_EXEC      As String = "EM_EXECUCAO"
Private Const STATUS_OS_CONCLUIDA As String = "CONCLUIDA"

Public Function MediaAvaliacaoDeterministica(ByVal somaNotas As Long) As Double
    Dim mediaExata As Currency

    mediaExata = CCur(CLng(somaNotas) * 10) / CCur(100)
    MediaAvaliacaoDeterministica = CDbl(mediaExata)
End Function

Public Function FormatarMediaAvaliacao(ByVal mediaNotas As Variant) As String
    FormatarMediaAvaliacao = Format$(Util_Conversao.ToCurrency(mediaNotas), "0.00")
End Function

Public Function MontarDefaultsAvaliacao( _
    ByRef os As TOS, _
    ByRef osId As String, _
    ByRef numEmpenho As String, _
    ByRef dtFechamento As String, _
    ByRef dtPagamento As String, _
    ByRef qtExecutada As Double, _
    ByRef valorExecutado As Currency _
) As TResult
    Dim res As TResult

    If Trim$(os.OS_ID) = "" Then
        res.Sucesso = False
        res.Mensagem = "OS obrigatoria para montar defaults da avaliacao."
        MontarDefaultsAvaliacao = res
        Exit Function
    End If

    osId = Trim$(os.OS_ID)
    numEmpenho = Trim$(os.NUM_EMPENHO)
    If os.DT_PREV_TERMINO > 0 Then
        dtFechamento = Format$(os.DT_PREV_TERMINO, "DD/MM/YYYY")
    Else
        dtFechamento = Format$(Date, "DD/MM/YYYY")
    End If
    dtPagamento = ""
    If os.QT_CONFIRMADA > 0 Then
        qtExecutada = os.QT_CONFIRMADA
    Else
        qtExecutada = os.QT_ESTIMADA
    End If
    valorExecutado = os.VALOR_TOTAL_OS

    res.Sucesso = True
    res.Mensagem = "Defaults da avaliacao montados."
    MontarDefaultsAvaliacao = res
End Function

Public Function DescreverMudancasAvaliacao( _
    ByVal defaultNumEmpenho As String, _
    ByVal defaultDtFechamento As String, _
    ByVal defaultQtExecutada As Double, _
    ByVal defaultValorExecutado As Currency, _
    ByVal numEmpenhoAtual As Variant, _
    ByVal dtFechamentoAtual As Variant, _
    ByVal qtExecutadaAtual As Variant, _
    ByVal valorAtual As Variant, _
    ByRef houveMudanca As Boolean, _
    ByRef resumoMudancas As String _
) As TResult
    Dim res As TResult
    Dim empAtual As String
    Dim dtAtual As String
    Dim qtAtual As Double
    Dim vlAtual As Currency

    empAtual = Trim$(SafeListVal(numEmpenhoAtual))
    dtAtual = SvcAvaliacao_NormalizarDataTexto(dtFechamentoAtual)
    qtAtual = Util_Conversao.ToDouble(qtExecutadaAtual)
    vlAtual = Util_Conversao.ToCurrency(valorAtual)

    If StrComp(defaultNumEmpenho, empAtual, vbTextCompare) <> 0 Then
        houveMudanca = True
        resumoMudancas = resumoMudancas & "- Empenho: '" & defaultNumEmpenho & "' -> '" & empAtual & "'" & vbCrLf
    End If

    If StrComp(defaultDtFechamento, dtAtual, vbTextCompare) <> 0 Then
        houveMudanca = True
        resumoMudancas = resumoMudancas & "- Data de fechamento: '" & defaultDtFechamento & "' -> '" & dtAtual & "'" & vbCrLf
    End If

    If Abs(qtAtual - defaultQtExecutada) > 0.0001 Then
        houveMudanca = True
        resumoMudancas = resumoMudancas & "- Quantidade executada: " & _
                         Format$(defaultQtExecutada, "0.00") & " -> " & Format$(qtAtual, "0.00") & vbCrLf
    End If

    If Abs(CDbl(vlAtual) - CDbl(defaultValorExecutado)) > 0.0001 Then
        houveMudanca = True
        resumoMudancas = resumoMudancas & "- Valor executado: R$ " & _
                         Format$(defaultValorExecutado, "#,##0.00") & " -> R$ " & Format$(vlAtual, "#,##0.00") & vbCrLf
    End If

    If Right$(resumoMudancas, 2) = vbCrLf Then
        resumoMudancas = Left$(resumoMudancas, Len(resumoMudancas) - 2)
    End If

    res.Sucesso = True
    res.Mensagem = "Mudancas da avaliacao comparadas."
    DescreverMudancasAvaliacao = res
End Function

Public Function MontarNotasAvaliacao( _
    ByVal nota1 As Variant, _
    ByVal nota2 As Variant, _
    ByVal nota3 As Variant, _
    ByVal nota4 As Variant, _
    ByVal nota5 As Variant, _
    ByVal nota6 As Variant, _
    ByVal nota7 As Variant, _
    ByVal nota8 As Variant, _
    ByVal nota9 As Variant, _
    ByVal nota10 As Variant, _
    ByRef notas() As Integer, _
    ByRef mediaNotas As Double _
) As TResult
    Dim res As TResult
    Dim valores(1 To 10) As Variant
    Dim i As Long
    Dim soma As Long

    If LBound(notas) <> 1 Or UBound(notas) <> 10 Then
        res.Sucesso = False
        res.Mensagem = "Array Notas deve ter indices 1 a 10."
        MontarNotasAvaliacao = res
        Exit Function
    End If

    valores(1) = nota1
    valores(2) = nota2
    valores(3) = nota3
    valores(4) = nota4
    valores(5) = nota5
    valores(6) = nota6
    valores(7) = nota7
    valores(8) = nota8
    valores(9) = nota9
    valores(10) = nota10

    For i = 1 To 10
        notas(i) = SvcAvaliacao_NotaSegura(valores(i))
        soma = soma + notas(i)
    Next i

    mediaNotas = MediaAvaliacaoDeterministica(soma)
    res.Sucesso = True
    res.Mensagem = "Notas normalizadas com sucesso."
    MontarNotasAvaliacao = res
End Function

Public Function MontarPayloadAvaliacao( _
    ByVal OS_ID As String, _
    ByVal avaliador As String, _
    ByRef notas() As Integer, _
    ByVal QtExecutadaTexto As Variant, _
    ByVal ObservacaoTexto As Variant, _
    ByVal JustifTexto As Variant, _
    ByRef payloadOSID As String, _
    ByRef payloadAvaliador As String, _
    ByRef payloadQtExecutada As Double, _
    ByRef payloadObservacao As String, _
    ByRef payloadJustifDivergencia As String, _
    ByRef payloadMediaNotas As Double _
) As TResult
    Dim res As TResult
    Dim i As Long
    Dim soma As Long

    If LBound(notas) <> 1 Or UBound(notas) <> 10 Then
        res.Sucesso = False
        res.Mensagem = "Array Notas deve ter indices 1 a 10."
        MontarPayloadAvaliacao = res
        Exit Function
    End If

    payloadOSID = Trim$(OS_ID)
    payloadAvaliador = Trim$(avaliador)
    payloadQtExecutada = Util_Conversao.ToDouble(SafeListVal(QtExecutadaTexto))
    payloadObservacao = SafeListVal(ObservacaoTexto)
    payloadJustifDivergencia = Funcoes.NormalizarTextoPTBR(SafeListVal(JustifTexto))

    For i = 1 To 10
        soma = soma + notas(i)
    Next i

    payloadMediaNotas = MediaAvaliacaoDeterministica(soma)

    If payloadOSID = "" Then
        res.Sucesso = False
        res.Mensagem = "OS_ID obrigatorio para montar payload de avaliacao."
        MontarPayloadAvaliacao = res
        Exit Function
    End If

    If payloadAvaliador = "" Then
        res.Sucesso = False
        res.Mensagem = "Avaliador obrigatorio para montar payload de avaliacao."
        MontarPayloadAvaliacao = res
        Exit Function
    End If

    If payloadQtExecutada <= 0 Then
        res.Sucesso = False
        res.Mensagem = "QtExecutada deve ser maior que zero."
        MontarPayloadAvaliacao = res
        Exit Function
    End If

    res.Sucesso = True
    res.Mensagem = "Payload de avaliacao montado com sucesso."
    MontarPayloadAvaliacao = res
End Function

Private Function SvcAvaliacao_NotaSegura(ByVal valor As Variant) As Integer
    Dim texto As String
    Dim numero As Long

    texto = Trim$(CStr(valor))
    If texto = "" Then
        SvcAvaliacao_NotaSegura = 0
        Exit Function
    End If

    numero = CLng(Val(texto))
    If numero < 0 Then numero = 0
    If numero > 10 Then numero = 10
    SvcAvaliacao_NotaSegura = CInt(numero)
End Function

Private Function SvcAvaliacao_NormalizarDataTexto(ByVal valor As Variant) As String
    If IsDate(valor) Then
        SvcAvaliacao_NormalizarDataTexto = Format$(CDate(valor), "DD/MM/YYYY")
    Else
        SvcAvaliacao_NormalizarDataTexto = Trim$(CStr(valor))
    End If
End Function

Public Function AvaliarOS( _
    ByVal OS_ID As String, _
    ByVal avaliador As String, _
    ByRef notas() As Integer, _
    ByVal QtExecutada As Double, _
    ByVal Observacao As String, _
    ByVal justifDiv As String, _
    Optional ByVal dtFechamento As Variant, _
    Optional ByVal DtPagto As Variant, _
    Optional ByVal valorExecutadoInformado As Variant, _
    Optional ByVal numEmpenho As String = "" _
) As TResult
    Dim res As TResult
    Dim os As TOS
    Dim aval As TAvaliacao
    Dim soma As Long
    Dim media As Double
    Dim notaMin As Double
    Dim i As Long
    Dim resInsert As TResult
    Dim resSusp As TResult
    Dim valorExecutado As Currency
    Dim haDivergencia As Boolean
    Dim justifEfetiva As String

    On Error GoTo Erro

    ' 1. Buscar OS (critério 32)
    os = Repo_OS.BuscarPorId(OS_ID)
    If os.OS_ID = "" Then
        res.Sucesso = False
        res.Mensagem = "OS nao encontrada: OS_ID=" & OS_ID
        AvaliarOS = res
        Exit Function
    End If

    ' 2. Validar STATUS (critério 33)
    If os.STATUS_OS <> STATUS_OS_EXEC Then
        RegistrarEvento _
            EVT_VALIDACAO_REJEITADA, ENT_OS, OS_ID, _
            "OPERACAO=AVALIAR; STATUS=" & os.STATUS_OS, _
            "REJEITADA; MOTIVO=STATUS_INVALIDO", _
            "Svc_Avaliacao"
        res.Sucesso = False
        res.Mensagem = "OS nao pode ser avaliada. STATUS=" & os.STATUS_OS
        AvaliarOS = res
        Exit Function
    End If

    ' 3. Validar índices do array (critério 34)
    If LBound(notas) <> 1 Or UBound(notas) <> 10 Then
        res.Sucesso = False
        res.Mensagem = "Array Notas deve ter indices 1 a 10."
        AvaliarOS = res
        Exit Function
    End If

    ' 4. Validar valores das notas (critério 35)
    soma = 0
    For i = 1 To 10
        If notas(i) < 0 Or notas(i) > 10 Then
            res.Sucesso = False
            res.Mensagem = "Nota " & i & " invalida: " & CStr(notas(i)) & ". Deve ser 0-10."
            AvaliarOS = res
            Exit Function
        End If
        soma = soma + notas(i)
    Next i

    If QtExecutada <= 0 Then
        res.Sucesso = False
        res.Mensagem = "QtExecutada deve ser maior que zero."
        AvaliarOS = res
        Exit Function
    End If

    justifEfetiva = Trim$(justifDiv)
    If justifEfetiva = "" Then justifEfetiva = Trim$(Observacao)

    valorExecutado = Util_Conversao.ToCurrency(valorExecutadoInformado)
    If valorExecutado <= 0 Then valorExecutado = CCur(QtExecutada * os.VALOR_UNIT)
    haDivergencia = (Abs(QtExecutada - os.QT_ESTIMADA) > 0.0001) Or _
                    (Abs(CDbl(valorExecutado) - CDbl(os.VALOR_TOTAL_OS)) > 0.0001)

    If haDivergencia And justifEfetiva = "" Then
        res.Sucesso = False
        res.Mensagem = "Justificativa obrigatoria quando ha divergencia entre o executado e o orcado."
        AvaliarOS = res
        Exit Function
    End If

    ' 5. Calcular média (critério 36)
    media = MediaAvaliacaoDeterministica(soma)

    ' 6. Montar TAvaliacao
    aval.OS_ID = OS_ID
    aval.avaliador = avaliador
    For i = 1 To 10
        aval.notas(i) = notas(i)
    Next i
    aval.SOMA_NOTAS = soma
    aval.MEDIA_NOTAS = media
    aval.Observacao = Observacao
    aval.DT_AVAL = Now

    ' 7. Persistir via Repo_Avaliacao
    resInsert = RepoAvaliacaoInserir(aval, QtExecutada, valorExecutado, justifEfetiva, dtFechamento, DtPagto, numEmpenho)
    If Not resInsert.Sucesso Then
        res.Sucesso = False
        res.Mensagem = "Falha ao salvar avaliacao: " & resInsert.Mensagem
        AvaliarOS = res
        Exit Function
    End If

    ' 7b. V12.0.0203 ONDA 1 - Regra de strikes na avaliacao.
    '
    ' Cada avaliacao com media estritamente menor que a nota de corte
    ' (GetNotaMinimaAvaliacao, default 5.0) conta 1 strike para a empresa.
    ' Quando os strikes acumulados (incluindo a avaliacao recem-inserida)
    ' atingem MAX_STRIKES (GetMaxStrikes, default 3), a empresa e
    ' suspensa por DIAS_SUSPENSAO_STRIKE dias (GetDiasSuspensaoStrike,
    ' default 90). MAX_STRIKES = 1 reproduz a regra antiga (suspende na
    ' primeira nota baixa). Strikes sao recontados on-the-fly em
    ' Repo_Avaliacao.ContarStrikesPorEmpresa, que varre SHEET_CAD_OS
    ' filtrando OS CONCLUIDA com COL_OS_MEDIA < notaCorte. Ao reativar
    ' (auto por DT_FIM_SUSP <= hoje, ou manual via Reativar()), a
    ' empresa volta a contar do zero porque GravarStatusEmpresa zera
    ' QTD_RECUSAS e o filtro de strikes nao olha para o passado anterior
    ' a esse ponto na proxima evolucao (ver auditoria/27 secao 03 e
    ' auditoria/28 secao 04 para o roadmap da janela temporal).
    notaMin = GetNotaMinimaAvaliacao()
    If media < notaMin Then
        Dim maxStrikes As Long
        Dim strikesAtuais As Long
        Dim diasSusp As Long

        maxStrikes = GetMaxStrikes()
        strikesAtuais = Repo_Avaliacao.ContarStrikesPorEmpresa(os.EMP_ID, notaMin)

        ' Auditoria do strike (mesmo quando ainda nao suspende).
        RegistrarEvento _
            EVT_AVALIACAO, ENT_EMP, os.EMP_ID, _
            "STRIKES=" & CStr(strikesAtuais - 1) & "/" & CStr(maxStrikes), _
            "STRIKES=" & CStr(strikesAtuais) & "/" & CStr(maxStrikes) & _
            "; NOTA_MIN=" & Format$(notaMin, "0.00") & _
            "; MEDIA=" & FormatarMediaAvaliacao(media), _
            "Svc_Avaliacao"

        If strikesAtuais >= maxStrikes Then
            diasSusp = GetDiasSuspensaoStrike()
            If diasSusp > 0 Then
                resSusp = Suspender(os.EMP_ID, diasSusp, "STRIKES=" & CStr(strikesAtuais))
            Else
                ' Fallback: usa a regra antiga em meses.
                resSusp = Suspender(os.EMP_ID, 0, "STRIKES=" & CStr(strikesAtuais) & "; FALLBACK_MESES")
            End If
            ' Suspender registra sua propria auditoria.
        End If
    End If

    ' 8. Avancar fila do rodizio: mover empresa para fim da fila SEM punicao.
    '    Sem isso, a empresa fica "travada" na posicao 1 e o rodizio nao avanca
    '    para a proxima empresa nas solicitacoes seguintes.
    Dim resAvancar As TResult
    resAvancar = AvancarFila(os.EMP_ID, os.ATIV_ID, False, "AVALIACAO_CONCLUIDA")
    ' Se falhar, nao bloqueia a avaliacao - apenas loga.
    If Not resAvancar.Sucesso Then
        RegistrarEvento _
            EVT_AVALIACAO, ENT_OS, OS_ID, _
            "", _
            "AVISO: Falha ao avancar fila apos avaliacao: " & resAvancar.Mensagem, _
            "Svc_Avaliacao"
    End If

    ' 9. Auditoria (critério 37)
    RegistrarEvento _
        EVT_AVALIACAO, ENT_OS, OS_ID, _
        "STATUS=EM_EXECUCAO", _
        "MEDIA=" & FormatarMediaAvaliacao(media) & _
        "; AVALIADOR=" & avaliador & _
        "; QT_EXEC=" & CStr(QtExecutada) & _
        "; NOTA_MIN=" & Format$(notaMin, "0.00"), _
        "Svc_Avaliacao"

    RegistrarEvento _
        EVT_OS_FECHADA, ENT_OS, OS_ID, _
        "STATUS=EM_EXECUCAO", _
        "STATUS=CONCLUIDA; MEDIA=" & FormatarMediaAvaliacao(media) & _
        "; AVALIADOR=" & avaliador & "; QT_EXEC=" & CStr(QtExecutada), _
        "Svc_Avaliacao"

    res.Sucesso = True
    res.Mensagem = "OS " & OS_ID & " avaliada. MEDIA=" & FormatarMediaAvaliacao(media)
    res.IdGerado = OS_ID
    AvaliarOS = res
    Exit Function

Erro:
    res.Sucesso = False
    res.Mensagem = "Erro em AvaliarOS: " & Err.Description
    res.CodigoErro = Err.Number
    AvaliarOS = res
End Function


