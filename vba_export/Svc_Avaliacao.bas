Attribute VB_Name = "Svc_Avaliacao"
Option Explicit

' Serviço de Avaliação de OS — V10
' Implementa: AvaliarOS.
' Registra 10 notas (0-10), calcula média e fecha OS como CONCLUIDA.
' Sem Select/ActiveCell/On Error Resume Next silencioso.

Private Const STATUS_OS_EXEC      As String = "EM_EXECUCAO"
Private Const STATUS_OS_CONCLUIDA As String = "CONCLUIDA"

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
    resInsert = RepoAvaliacaoInserir(aval, QtExecutada, os.VALOR_UNIT, justifDiv, dtFechamento, DtPagto)
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
        Audit_Log.RegistrarEvento _
            EVT_AVALIACAO, ENT_OS, OS_ID, _
            "", _
            "AVISO: Falha ao avancar fila apos avaliacao: " & resAvancar.Mensagem, _
            "Svc_Avaliacao"
    End If

    ' 9. Auditoria (critério 37)
    Audit_Log.RegistrarEvento _
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



