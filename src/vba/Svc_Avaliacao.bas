Attribute VB_Name = "Svc_Avaliacao"
Option Explicit

' Serviço de Avaliação de OS — V10
' Implementa: AvaliarOS.
' Registra 10 notas (0-10), calcula média e fecha OS como CONCLUIDA.
' Sem Select/ActiveCell/On Error Resume Next silencioso.

Private Const STATUS_OS_EXEC      As String = "EM_EXECUCAO"
Private Const STATUS_OS_CONCLUIDA As String = "CONCLUIDA"

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

    mediaNotas = Round(soma / 10#, 2)
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
    ByRef payload As TAvaliacaoPayload _
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

    payload.OS_ID = Trim$(OS_ID)
    payload.avaliador = Trim$(avaliador)
    payload.QtExecutada = Util_Conversao.ToDouble(SafeListVal(QtExecutadaTexto))
    payload.Observacao = SafeListVal(ObservacaoTexto)
    payload.JustifDivergencia = Funcoes.NormalizarTextoPTBR(SafeListVal(JustifTexto))

    For i = 1 To 10
        payload.notas(i) = notas(i)
        soma = soma + notas(i)
    Next i

    payload.MediaNotas = Round(soma / 10#, 2)

    If payload.OS_ID = "" Then
        res.Sucesso = False
        res.Mensagem = "OS_ID obrigatorio para montar payload de avaliacao."
        MontarPayloadAvaliacao = res
        Exit Function
    End If

    If payload.avaliador = "" Then
        res.Sucesso = False
        res.Mensagem = "Avaliador obrigatorio para montar payload de avaliacao."
        MontarPayloadAvaliacao = res
        Exit Function
    End If

    If payload.QtExecutada <= 0 Then
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

Public Function AvaliarOS( _
    ByVal OS_ID As String, _
    ByVal avaliador As String, _
    ByRef notas() As Integer, _
    ByVal QtExecutada As Double, _
    ByVal Observacao As String, _
    ByVal justifDiv As String, _
    Optional ByVal dtFechamento As Variant, _
    Optional ByVal DtPagto As Variant _
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

    valorExecutado = CCur(QtExecutada * os.VALOR_UNIT)
    haDivergencia = (Abs(QtExecutada - os.QT_ESTIMADA) > 0.0001) Or _
                    (Abs(CDbl(valorExecutado) - CDbl(os.VALOR_TOTAL_OS)) > 0.0001)

    If haDivergencia And justifEfetiva = "" Then
        res.Sucesso = False
        res.Mensagem = "Justificativa obrigatoria quando ha divergencia entre o executado e o orcado."
        AvaliarOS = res
        Exit Function
    End If

    ' 5. Calcular média (critério 36)
    media = soma / 10#

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
    resInsert = RepoAvaliacaoInserir(aval, QtExecutada, os.VALOR_UNIT, justifEfetiva, dtFechamento, DtPagto)
    If Not resInsert.Sucesso Then
        res.Sucesso = False
        res.Mensagem = "Falha ao salvar avaliacao: " & resInsert.Mensagem
        AvaliarOS = res
        Exit Function
    End If

    ' 7b. Regra: media abaixo da nota minima => suspende empresa (Iteracao 2)
    notaMin = GetNotaMinimaAvaliacao()
    If media < notaMin Then
        resSusp = Suspender(os.EMP_ID)
        ' Suspensão registra sua própria auditoria; aqui só garantimos a regra de negócio.
    End If

    ' 8. Avancar fila do rodizio: mover empresa para fim da fila SEM punicao.
    '    Sem isso, a empresa fica "travada" na posicao 1 e o rodizio nao avanca
    '    para a proxima empresa nas solicitacoes seguintes.
    Dim resAvancar As TResult
    resAvancar = AvancarFila(os.EMP_ID, os.ATIV_ID, False, "AVALIACAO_CONCLUIDA")
    ' Se falhar, nao bloqueia a avaliacao — apenas loga.
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
        "MEDIA=" & Format$(media, "0.00") & _
        "; AVALIADOR=" & avaliador & _
        "; QT_EXEC=" & CStr(QtExecutada) & _
        "; NOTA_MIN=" & Format$(notaMin, "0.00"), _
        "Svc_Avaliacao"

    RegistrarEvento _
        EVT_OS_FECHADA, ENT_OS, OS_ID, _
        "STATUS=EM_EXECUCAO", _
        "STATUS=CONCLUIDA; MEDIA=" & Format$(media, "0.00") & _
        "; AVALIADOR=" & avaliador & "; QT_EXEC=" & CStr(QtExecutada), _
        "Svc_Avaliacao"

    res.Sucesso = True
    res.Mensagem = "OS " & OS_ID & " avaliada. MEDIA=" & Format$(media, "0.00")
    res.IdGerado = OS_ID
    AvaliarOS = res
    Exit Function

Erro:
    res.Sucesso = False
    res.Mensagem = "Erro em AvaliarOS: " & Err.Description
    res.CodigoErro = Err.Number
    AvaliarOS = res
End Function



