# PLANO DE MICRODESENVOLVIMENTO ANTI-REGRESSÃO
Passos Pequenos, Seguros, Auditáveis Baseado em Análise de Risco

## PRINCÍPIOS FUNDAMENTAIS

1. **Atomicidade:** Cada passo altera 1-3 arquivos apenas, com mudança lógica única
2. **Reversibilidade:** Cada passo reversível em < 5 min (backup automático)
3. **Testabilidade:** Cada passo tem teste específico (BO_XXX ou novo) que passa antes e depois
4. **Rastreabilidade:** Git commit antes/depois, changelog automático
5. **Escalabilidade:** Passos podem ser feitos em ordem ou paralelo (exceto dependências)
6. **Risco Mínimo:** Começar com mudanças estruturais baixo-risco, não com lógica crítica

---

## PASSO 1: Análise de Dependências e Mapping de Código

**Objetivo:** Criar dependency graph completo para evitar quebras silenciosas

**Arquivos Afetados:**
- Novo arquivo: `/doc/DEPENDENCY_MAP.md`
- Util_Config.bas (adição de logging)
- Audit_Log.bas (adição de logging)

**Mudanças:**
1. Criar sheet `DEP_MAPPING` (invisible, referência apenas)
   - Col A: Function/Sub name
   - Col B: Arquivo
   - Col C: Funções chamadas (lista)
   - Col D: Funções que chamam esta (lista)
2. Gerar DEPENDENCY_MAP.md via script (lê DEP_MAPPING)
3. Adicionar função LogDependency() em Util_Config que registra cada call em Audit_Log

**Pré-condições:**
- Backup V12-146 existente
- Compilação sem erros

**Critério de Saída:**
- DEP_MAPPING sheet com 80+ funções mapeadas
- DEPENDENCY_MAP.md gerado
- Nenhum conflito de circular dependency detectado

**Testes a Rodar:**
- BO_001 (reset, confirma backup intacto)
- Teste manual: Abrir 3-4 forms, chamar 5 rotinas, confirmar logs em Audit_Log

**Tempo Estimado:** 2-3 horas (investigação + documentação)

**Risco:** Baixo (apenas leitura + documentação, nenhuma mudança lógica)

---

## PASSO 2: Standardizar Leitura de notaMin (MATEMÁTICA - ALTA PRIORIDADE)

**Objetivo:** Fazer notaMin parsing locale-aware, remove divergência de comparação

**Arquivos Afetados:**
- Util_Config.bas (nova função)
- Svc_Avaliacao.bas (mudança de comparação)
- Teste_Bateria_Oficial.bas (novo teste BO_110)

**Mudanças Específicas:**

**2a. Criar função em Util_Config.bas:**
```vba
Public Function NotaMinConfig() As Double
    ' Lê CONFIG![NOTA_MIN] de forma locale-safe
    Dim raw As String, normalized As String
    On Error GoTo ErrorHandler
    
    raw = CStr(Range("CONFIG_NOTA_MIN").Value)
    If IsEmpty(raw) Or raw = "" Then
        NotaMinConfig = 5# ' default
        Exit Function
    End If
    
    ' Normalize: replace vírgula com ponto (brasileira)
    normalized = Replace(raw, ",", ".")
    
    ' Tentar converter
    NotaMinConfig = CDbl(normalized)
    Exit Function
    
ErrorHandler:
    ' Log erro, retorna default
    Audit_Log.Registrar "ERROR", "NotaMinConfig: failed to parse " & raw & ", using default 5.0"
    NotaMinConfig = 5#
End Function
```

**2b. Mudança em Svc_Avaliacao.bas (linha ~145):**
```vba
' ANTES:
If media < notaMin Then Suspender()

' DEPOIS:
Dim mediaRound As Double, notaMinVal As Double
mediaRound = Round(media, 2)
notaMinVal = Util_Config.NotaMinConfig()
If mediaRound < notaMinVal Then
    Audit_Log.Registrar "INFO", "Avaliacao: media " & mediaRound & " < notaMin " & notaMinVal & ", suspendendo"
    Suspender()
End If
```

**2c. Novo teste BO_110 em Teste_Bateria_Oficial.bas:**
```vba
Sub BO_110_NotaMinLocaleAware()
    ' Teste: CONFIG![NOTA_MIN] com "5,0" (brasileiro) é lido corretamente
    Dim notaMin As Double
    Range("CONFIG_NOTA_MIN").Value = "5,0" ' Simula entrada brasileira
    notaMin = Util_Config.NotaMinConfig()
    Assert notaMin = 5#, "NotaMinConfig deve retornar 5.0 para entrada '5,0'"
    
    ' Teste 2: Valor não-padrão
    Range("CONFIG_NOTA_MIN").Value = "4,5"
    notaMin = Util_Config.NotaMinConfig()
    Assert notaMin = 4.5, "NotaMinConfig deve retornar 4.5 para entrada '4,5'"
End Sub
```

**Pré-condições:**
- Passo 1 concluído (dependency map)
- Backup V12-146 existente

**Critério de Saída:**
- Função NotaMinConfig() criada e testada
- Svc_Avaliacao.bas modificado, compila sem erros
- BO_110 passa (novo teste)
- Todos testes anteriores ainda passam (regressão zero)

**Testes a Rodar:**
- BO_110 (novo, teste o parsing)
- BO_033 (avaliação falha, valida chamada modificada)
- BO_030, BO_065 (avaliação aprovação, valida comparação roundada)
- Bloco 1 inteiro (30 testes, regressão)

**Tempo Estimado:** 1-2 horas (code, test, validation)

**Risco:** Baixo (isolado em função nova + comparação)

---

## PASSO 3: Unified Media Formatting (MATEMÁTICA - ALTA PRIORIDADE)

**Objetivo:** Usar Round() uniformemente em comparação, exibição, audit, CSV

**Arquivos Afetados:**
- Util_Conversao.bas (nova função)
- Preencher.bas (mudança 1 linha)
- Audit_Log.bas (mudança 1 linha)
- Central_Testes_Relatorio.bas (mudança 1 linha)
- Teste_Bateria_Oficial.bas (novos testes BO_111, BO_112)

**Mudanças Específicas:**

**3a. Criar função em Util_Conversao.bas:**
```vba
Public Function MediaComFormatacao(soma As Integer, divisor As Integer) As Double
    ' Calcula media com rounding uniforme a 2 casas
    Dim media As Double
    media = soma / CDbl(divisor)
    MediaComFormatacao = Round(media, 2)
End Function

Public Function MediaFormatada(media As Double) As String
    ' Retorna string formatada para exibição/audit
    MediaFormatada = Format$(Round(media, 2), "0.00")
End Function
```

**3b. Mudança em Preencher.bas (linha ~N37):**
```vba
' ANTES:
media2 = Fix(media * 100) / 100

' DEPOIS:
media2 = Round(media, 2)
```

**3c. Mudança em Audit_Log.bas (linha ~Registrar media):**
```vba
' ANTES:
strMedia = Format$(media, "0.00")

' DEPOIS:
strMedia = Util_Conversao.MediaFormatada(media)
```

**3d. Mudança em Central_Testes_Relatorio.bas (export media):**
```vba
' ANTES:
csv_line = csv_line & CAD_AVALIACAO![MEDIA_NOTAS] & ","

' DEPOIS:
csv_line = csv_line & Util_Conversao.MediaFormatada(CAD_AVALIACAO![MEDIA_NOTAS]) & ","
```

**3e. Novos testes BO_111, BO_112:**
```vba
Sub BO_111_RoundConsistency()
    ' Teste: Round(4.95, 2) = 4.95 em todos contextos
    ' Teste: Comparação, exibição, audit retornam mesma string
    ' Teste: media=4.995 (improvável, mas simular) → Round = 5.00, comparação vê 5.00
End Sub

Sub BO_112_MediaFormattingUnified()
    ' Teste: Exibição, audit, CSV exportado têm mesma formatação
    ' Valida BO_030 (aprovação), BO_033 (falha), BO_065 (borderline)
End Sub
```

**Pré-condições:**
- Passo 2 concluído (NotaMinConfig)
- Passo 1 concluído (dependency map)

**Critério de Saída:**
- Funções MediaComFormatacao() e MediaFormatada() criadas e testadas
- Preencher.bas, Audit_Log.bas, Central_Testes_Relatorio.bas modificados
- BO_111, BO_112 passam
- Regressão: BO_030, BO_033, BO_065 passam

**Testes a Rodar:**
- BO_111, BO_112 (novos)
- Bloco 1 (30 testes)
- BO_130 (CSV export, se existir)

**Tempo Estimado:** 2-3 horas

**Risco:** Baixo-Médio (múltiplos arquivos, mas mudanças isoladas e testadas)

---

## PASSO 4: Criar Testes para Classe D (COBERTURA - ALTA PRIORIDADE)

**Objetivo:** Adicionar teste dedicado para Filter E (Pre-OS pendente, skip sem punição)

**Arquivos Afetados:**
- Teste_Bateria_Oficial.bas (novo teste BO_D01)

**Mudanças Específicas:**

**4a. Novo teste BO_D01 em Teste_Bateria_Oficial.bas:**
```vba
Sub BO_D01_FilterESkipSemPunicao()
    ' Cenário: Empresa com Pre-OS pendente, sem OS aberta
    ' Esperado: Skip sem incrementar QTD_RECUSAS (Filter E ativo)
    
    ' Setup
    Dim empresa As TestEmpresa
    Set empresa = CreateEmpresa("E001", "ATIVA")
    empresa.QTD_RECUSAS = 1 ' Começa com 1
    
    Dim preos As TestPreOS
    Set preos = CreatePreOS(empresa, "AGUARDANDO_ACEITE") ' Pre-OS pendente
    
    ' Execução
    Svc_Rodizio.SelecionarEmpresa(atividadeID)
    
    ' Validação
    Assert empresa.QTD_RECUSAS = 1, "Filter E: QTD_RECUSAS não deve incrementar"
    Assert empresa.POSICAO_FILA = posicaoOriginal, "Filter E: POSICAO_FILA não deve mudar (skip sem mover)"
    
    ' Log
    BA_LogAssert "BO_D01", "Filter E", "PASS"
End Sub
```

**Pré-condições:**
- Passo 1-3 concluídos
- Teste_Bateria_Oficial estrutura funcional

**Critério de Saída:**
- BO_D01 criado, compila
- BO_D01 passa (confirma comportamento esperado)
- Nenhuma regressão em BO_012-BO_020

**Testes a Rodar:**
- BO_D01 (novo)
- Bloco 1 (regressão)

**Tempo Estimado:** 1-2 horas

**Risco:** Baixo (novo teste, não modifica código existente)

---

## PASSO 5: Criar Testes para Cross-Atividade (COBERTURA - ALTA PRIORIDADE)

**Objetivo:** Adicionar testes para interação de Filter D + Filter E entre atividades diferentes

**Arquivos Afetados:**
- Teste_Bateria_Oficial.bas (novos testes BO_XA01, BO_XA02)

**Mudanças Específicas:**

**5a. Novo teste BO_XA01:**
```vba
Sub BO_XA01_CrossAtividadeMoverFinal()
    ' Cenário: Empresa com OS aberta em Atividade A, Pre-OS em Atividade B
    ' Esperado: Filter D (MoverFinal) apenas aplica na mesma atividade
    '          Em Atividade B, não há OS, então eleição procede normal
    
    ' Setup
    Dim empresa As TestEmpresa
    Set empresa = CreateEmpresa("E001", "ATIVA")
    
    Dim osA As TestOS
    Set osA = CreateOS(empresa, "ATIVIDADE_A", "EM_EXECUCAO") ' OS aberta em A
    
    ' Execução: Seleção em Atividade B (diferente de A)
    Svc_Rodizio.SelecionarEmpresa("ATIVIDADE_B")
    
    ' Validação
    Assert empresa.POSICAO_FILA = 2, "Cross-atividade: empresa deveria estar em posição 2 (eleita em B)"
    Assert osA.STATUS = "EM_EXECUCAO", "OS em A permanece intacta"
End Sub
```

**5b. Novo teste BO_XA02:**
```vba
Sub BO_XA02_CrossAtividadeMultipla()
    ' Cenário: 3 empresas, múltiplas combinações de OS/Pre-OS em diferentes atividades
    ' Esperado: Filtros aplicados corretamente por contexto de atividade
    
    ' Setup: 3 empresas, 2 atividades
    Dim e1 As TestEmpresa, e2 As TestEmpresa, e3 As TestEmpresa
    Set e1 = CreateEmpresa("E001", "ATIVA")
    Set e2 = CreateEmpresa("E002", "ATIVA")
    Set e3 = CreateEmpresa("E003", "ATIVA")
    
    ' E1 tem OS em A, nada em B → em B, deve ser eleita
    ' E2 tem Pre-OS em B, nada em A → em A, deve ser eleita
    ' E3 tem nada em ambas → segunda opção em ambas
    
    ' Execução
    Svc_Rodizio.SelecionarEmpresa("ATIVIDADE_A") ' Deve eleger E2
    Svc_Rodizio.SelecionarEmpresa("ATIVIDADE_B") ' Deve eleger E1
    
    ' Validação (conforme lógica de ordem)
    Assert (empresa_eleita_A.id = "E002" Or empresa_eleita_A.id = "E003"), "Atividade A: E1 skipped por OS em A"
    Assert (empresa_eleita_B.id = "E001" Or empresa_eleita_B.id = "E003"), "Atividade B: E2 skipped por Pre-OS em B"
End Sub
```

**Pré-condições:**
- Passo 1-4 concluídos
- Teste_Bateria_Oficial estrutura funcional

**Critério de Saída:**
- BO_XA01, BO_XA02 criados, compilam
- Ambos testes passam
- Nenhuma regressão em Bloco 1-2

**Testes a Rodar:**
- BO_XA01, BO_XA02 (novos)
- Bloco 1 (regressão)

**Tempo Estimado:** 2-3 horas

**Risco:** Médio (testes complexos, múltiplas atividades, lógica de contexto)

---

## PASSO 6: Implementar CONFIG_TESTES Sheet (STANDARDIZAÇÃO - MÉDIA PRIORIDADE)

**Objetivo:** Criar sheet de configuração global para modo de execução, verbosidade, etc.

**Arquivos Afetados:**
- Novo sheet: CONFIG_TESTES
- Central_Testes.bas (lê CONFIG_TESTES)
- Util_Config.bas (nova função)

**Mudanças Específicas:**

**6a. Criar sheet CONFIG_TESTES:**
```
SETTING                        │ VALOR_ATUAL │ TIPO     │ VALORES_VALIDOS
───────────────────────────────┼─────────────┼──────────┼────────────────────────
MODO_EXECUCAO_TESTES           │ Normal      │ String   │ Fast, Normal, Slow
VERBOSIDADE_LOG                │ Normal      │ String   │ Silent, Normal, Verbose
AUTO_RESET_DATABASE_ANTES      │ Sim         │ Boolean  │ Sim, Não
TAMANHO_GRUPO_ASSISTIDO        │ 5           │ Integer  │ 1-20
BLOCO_PADRAO                   │ 1-5         │ String   │ 0-5, ranges, all
INCLUDE_HISTORICO_RELATORIO    │ Sim         │ Boolean  │ Sim, Não
TIMESTAMP_OUTPUT_CSV           │ Sim         │ Boolean  │ Sim, Não
PASTA_EXPORT_CSV               │ ./output    │ String   │ caminho válido
```

**6b. Função em Util_Config.bas:**
```vba
Public Function GetConfigTeste(chave As String, padrao As Variant) As Variant
    ' Lê CONFIG_TESTES[chave], retorna padrao se não encontrado
    On Error GoTo ErrorHandler
    Dim valor As Variant
    valor = Range("CONFIG_TESTES_" & chave).Value
    If IsEmpty(valor) Or valor = "" Then
        GetConfigTeste = padrao
    Else
        GetConfigTeste = valor
    End If
    Exit Function
ErrorHandler:
    GetConfigTeste = padrao
End Function

Public Sub SetConfigTeste(chave As String, valor As Variant)
    ' Escreve em CONFIG_TESTES[chave]
    Range("CONFIG_TESTES_" & chave).Value = valor
End Sub
```

**6c. Mudança em Central_Testes.bas:**
```vba
Sub CT_AbrirCentral()
    Dim modoExec As String
    modoExec = Util_Config.GetConfigTeste("MODO_EXECUCAO_TESTES", "Normal")
    
    ' ... rest of menu logic
    
    Select Case opcao
        Case "1":
            BA_SetModoExecucaoVisual (modoExec = "Slow")
            Teste_Bateria_Oficial.RunBateriaOficial()
        ' ... etc
    End Select
End Sub
```

**Pré-condições:**
- Passo 1-5 concluídos
- Excel file com estrutura estável

**Critério de Saída:**
- Sheet CONFIG_TESTES criado com dados iniciais
- Função GetConfigTeste(), SetConfigTeste() criadas
- Central_Testes.bas modificado para usar CONFIG_TESTES
- Nenhuma regressão

**Testes a Rodar:**
- BO_001 (confirma CONFIG_TESTES carregado)
- Bloco 1 (regressão)

**Tempo Estimado:** 1-2 horas

**Risco:** Baixo (novo sheet, funções isoladas)

---

## PASSO 7: Implementar Central_Testes_V2 Base (INTERFACE - MÉDIA PRIORIDADE)

**Objetivo:** Criar novo módulo Central_Testes_V2.bas com MenuPrincipal() unificado

**Arquivos Afetados:**
- Novo arquivo: Central_Testes_V2.bas
- Novo sheet: BATERIA_RESULTADO_V2
- Novo sheet: HISTORICO_BATERIA

**Mudanças Específicas:**

**7a. Novo módulo Central_Testes_V2.bas:**
```vba
Sub MenuPrincipal()
    Dim opcao As String
    Do
        opcao = InputBox("CENTRAL DE TESTES - SISTEMA DE CREDENCIAMENTO" & vbCrLf & vbCrLf & _
                        "1 - Executar Bateria Oficial Completa" & vbCrLf & _
                        "2 - Executar Subset de Testes" & vbCrLf & _
                        "3 - Modo Assistido (Passo-a-Passo)" & vbCrLf & _
                        "4 - Treinamento Interativo" & vbCrLf & _
                        "5 - Teste UI Guiado" & vbCrLf & _
                        "6 - Ver Histórico de Resultados" & vbCrLf & _
                        "7 - Exportar Relatório" & vbCrLf & _
                        "8 - Configurações" & vbCrLf & _
                        "9 - Sair", "Sua escolha:")
        Select Case opcao
            Case "1": ExecutarBateriaCompleta()
            Case "2": ExecutarSubset()
            Case "3": ModoAssistido()
            Case "4": TreinamentoInterativo()
            Case "5": TesteUIGuiado()
            Case "6": VerHistorico()
            Case "7": ExportarRelatorio()
            Case "8": ConfigurarOpcoes()
            Case "9": Exit Do
        End Select
    Loop
End Sub

Sub ExecutarBateriaCompleta()
    ' Delegá para Teste_Bateria_Oficial com modo global
    Teste_Bateria_Oficial.RunBateriaOficial()
    ' Após execução, popular BATERIA_RESULTADO_V2
    PopularResultadoV2()
    MsgBox "Bateria concluída. Resultado em sheet BATERIA_RESULTADO_V2"
End Sub

' ... outras subs
```

**7b. Criar sheets:**
- BATERIA_RESULTADO_V2 (layout conforme Doc 07, seção 3.2)
- HISTORICO_BATERIA (layout conforme Doc 07, seção 3.3)

**Pré-condições:**
- Passo 1-6 concluídos
- Teste_Bateria_Oficial funcional

**Critério de Saída:**
- Central_Testes_V2.bas criado com MenuPrincipal() funcional
- Sheets BATERIA_RESULTADO_V2, HISTORICO_BATERIA criados
- Opção 1 (ExecutarBateriaCompleta) testada e funcional
- Nenhuma regressão

**Testes a Rodar:**
- BO_001 (confirma sheets criados)
- Bloco 1 (regressão)
- Teste manual: Chamar Central_Testes_V2.MenuPrincipal(), escolher opção 1, confirmar resultado em sheet

**Tempo Estimado:** 2-3 horas

**Risco:** Baixo (novo módulo, não modifica existente, nova interface)

---

## PASSO 8: Implementar ModoAssistido() (INTERFACE - MÉDIA PRIORIDADE)

**Objetivo:** Modo assistido com pausas e feedback por grupo de testes

**Arquivos Afetados:**
- Central_Testes_V2.bas (novo sub ModoAssistido)
- Teste_Bateria_Oficial.bas (novo sub ExecutarTesteUnico)

**Mudanças Específicas:**

**8a. Novo sub em Central_Testes_V2.bas:**
```vba
Sub ModoAssistido()
    Dim bloco As String, tamanhoGrupo As Integer, modoExec As String
    Dim testes As Collection, i As Integer
    Dim resultados As Collection
    
    bloco = InputBox("Qual bloco? (0-5 ou range como '1-3' ou 'all')", , "1-5")
    tamanhoGrupo = Util_Config.GetConfigTeste("TAMANHO_GRUPO_ASSISTIDO", 5)
    modoExec = Util_Config.GetConfigTeste("MODO_EXECUCAO_TESTES", "Normal")
    
    Set testes = ObterTestesParaBloco(bloco)
    Set resultados = New Collection
    
    For i = 1 To testes.Count Step tamanhoGrupo
        Dim j As Integer, grupoRespostass As Collection
        Set grupoRespostas = New Collection
        
        For j = i To Application.Min(i + tamanhoGrupo - 1, testes.Count)
            Dim idTeste As String
            idTeste = testes(j)
            
            ' Executar teste único
            Dim res As TestResult
            Set res = Teste_Bateria_Oficial.ExecutarTesteUnico(idTeste)
            grupoRespostas.Add res
            
            ' Mostrar resultado em tempo real
            ShowResultadoTeste res
        Next j
        
        ' Pausa entre grupos
        Dim continuar As VbMsgBoxResult
        continuar = MsgBox("Grupo " & (i / tamanhoGrupo + 1) & " concluído. Continuar?", vbYesNo)
        If continuar = vbNo Then Exit For
    Next i
    
    ' Gerar resumo
    PopularResultadoV2()
    MsgBox "Modo assistido concluído. Total: " & resultados.Count & " testes"
End Sub

Sub ShowResultadoTeste(res As TestResult)
    ' Mostra resultado de 1 teste em dialog/sheet
    Dim msg As String
    msg = res.id & " (" & res.classe & "): " & res.status & vbCrLf
    If res.status <> "PASS" Then
        msg = msg & "Erro: " & res.erro & vbCrLf & _
              "Ação: " & res.acaoRecomendada
    End If
    Debug.Print msg
End Sub
```

**8b. Novo sub em Teste_Bateria_Oficial.bas:**
```vba
Function ExecutarTesteUnico(idTeste As String) As TestResult
    ' Executa um teste individual, retorna TestResult
    Dim res As TestResult
    Set res = New TestResult
    res.id = idTeste
    res.tempoInicio = Now()
    
    On Error GoTo ErrorHandler
    
    ' Chamar função correspondente
    Select Case idTeste
        Case "BO_010": BO_010_ResetDatabase()
        Case "BO_011": BO_011_ConfigureMinimalSystem()
        ' ... todos os testes BO_XXX
        Case Else: Err.Raise 9999, , "Teste não encontrado: " & idTeste
    End Select
    
    res.status = "PASS"
    res.tempoFinal = Now()
    ExecutarTesteUnico = res
    Exit Function
    
ErrorHandler:
    res.status = "FAIL"
    res.erro = Err.Description
    res.tempoFinal = Now()
    ExecutarTesteUnico = res
End Function
```

**Pré-condições:**
- Passo 1-7 concluídos
- Teste_Bateria_Oficial estrutura funcional

**Critério de Saída:**
- ModoAssistido() implementado e testado
- ExecutarTesteUnico() implementado
- Modo assistido com pausa entre grupos funcional
- Nenhuma regressão

**Testes a Rodar:**
- Teste manual: Central_Testes_V2.MenuPrincipal() → opção 3 → bloco 1 → confirma pause após 5 testes

**Tempo Estimado:** 3-4 horas

**Risco:** Médio (novo fluxo, múltiplas pauses, pode ter bugs em interação usuário-código)

---

## PASSO 9: Adicionar Testes de Arredondamento Cumulativo (MATEMÁTICA - BAIXA PRIORIDADE)

**Objetivo:** Validar arredondamento cumulativo de VL_EXEC não causa erro > 0.01

**Arquivos Afetados:**
- Teste_Bateria_Oficial.bas (novo teste BO_AC01, BO_AC02)

**Mudanças Específicas:**

**9a. Novo teste BO_AC01:**
```vba
Sub BO_AC01_VL_EXECArredondamentoCumulativo()
    ' Teste: 100 × VL_EXEC com VALOR_UNIT pequeno
    ' Esperado: Erro acumulado < 0.01
    
    Dim empresa As TestEmpresa, atividade As TestAtividade
    Set empresa = CreateEmpresa("E001", "ATIVA")
    Set atividade = GetAtividade("SERVICO_X")
    
    ' Simular 100 execuções de 1.25 × 20.9999
    Dim i As Integer, totalExato As Double, totalExecutado As Double
    totalExato = 100 * 1.25 * 20.9999 ' 2624.9875
    
    For i = 1 To 100
        Repo_Avaliacao.Inserir empresa, atividade, 1.25, 20.9999, "EXECUCAO_" & i
    Next i
    
    totalExecutado = SUM(CAD_AVALIACAO![VALOR_EXECUCAO])
    
    Dim erro As Double
    erro = Abs(totalExato - totalExecutado)
    
    Assert erro < 0.01, "Erro cumulativo deve ser < 0.01, mas foi " & erro
End Sub
```

**Pré-condições:**
- Passo 1-8 concluídos
- Repo_Avaliacao funcional

**Critério de Saída:**
- BO_AC01 criado, compila
- BO_AC01 passa (confirma erro cumulativo < 0.01)
- Se teste falhar, documenta em lacunas (COR006 futuro)

**Testes a Rodar:**
- BO_AC01 (novo)

**Tempo Estimado:** 1-2 horas

**Risco:** Baixo (apenas teste, nenhuma mudança em código)

---

## PASSO 10: Documentar Precision de Currency (DOCUMENTAÇÃO - BAIXA PRIORIDADE)

**Objetivo:** Adicionar seção em Contrato_de_Dados.md sobre Currency 4-decimal precision

**Arquivos Afetados:**
- /doc/Contrato_de_Dados.md (nova seção)

**Mudanças Específicas:**

**10a. Nova seção em Contrato_de_Dados.md:**
```markdown
## Precisão Numérica e Arredondamento

### Currency: 4 Decimais de Precisão

Campos VALOR_* (VALOR_ESTIMADO, VALOR_TOTAL_OS, VALOR_EXECUCAO) são armazenados como Currency.
- **Precisão:** 4 casas decimais (0.0001)
- **Exibição padrão:** 2 casas decimais (0.00) em currency format
- **Arredondamento:** Implícito ao atribuir a Currency
- **Exemplo:** 35.00035 → 35.0004 (arredonda para 4 decimais)

**Implicação:** Discrepância invisível entre célula exibida (0.00) e armazenado (0.0001).
Para auditoria precisa, exportar com Util_Conversao.FormatarCurrency(valor).

### Double: 15 Dígitos Significativos

Campos MEDIA_NOTAS, QT_ESTIMADA, QT_CONFIRMADA são Double.
- **Precisão:** ~15 dígitos significativos (IEEE 754)
- **Arredondamento:** Usar Round(media, 2) para exibição/comparação
- **Comparação:** Sempre usar <= / >= com Double (nunca == exato)

### Integer: Exato

Campos SOMA_NOTAS, QTD_RECUSAS, POSICAO_FILA são Integer.
- **Precisão:** Exata (2^31 - 1)
- **Sem arredondamento:** Nenhum
```

**Pré-condições:**
- Passo 1-9 concluídos
- Arquivo /doc/Contrato_de_Dados.md existente

**Critério de Saída:**
- Seção adicionada a Contrato_de_Dados.md
- Exemplos e implicações documentadas

**Testes a Rodar:**
- Nenhum (apenas documentação)

**Tempo Estimado:** 0.5-1 hora

**Risco:** Nenhum (apenas documentação)

---

## SUMÁRIO E ORDEM DE EXECUÇÃO

### Ordem Recomendada (Crítica → Suporte)

| Passo | Nome | Prioridade | Risco | Tempo | Dependências | Status |
|-------|------|-----------|-------|-------|--------------|--------|
| 1 | Dependency Mapping | Alta | Baixo | 2-3h | Nenhuma | Pronto |
| 2 | NotaMin Locale-Safe | Alta | Baixo | 1-2h | 1 | Pronto |
| 3 | Media Formatting Unificada | Alta | Baixo-Médio | 2-3h | 1-2 | Pronto |
| 4 | Testes Classe D | Alta | Baixo | 1-2h | 1-3 | Pronto |
| 5 | Testes Cross-Atividade | Alta | Médio | 2-3h | 1-4 | Pronto |
| 6 | CONFIG_TESTES Sheet | Média | Baixo | 1-2h | 1-3 | Pronto |
| 7 | Central_Testes_V2 Base | Média | Baixo | 2-3h | 1-6 | Pronto |
| 8 | ModoAssistido | Média | Médio | 3-4h | 1-7 | Pronto |
| 9 | Testes Arredondamento Cumulativo | Baixa | Baixo | 1-2h | 1-8 | Pronto |
| 10 | Documentação Currency Precision | Baixa | Nenhum | 0.5-1h | 1-9 | Pronto |

**Tempo Total:** 15-27 horas (1 dev, ~2-3 semanas)

### Parallelização Possível

- Passos 1-4 podem rodar em paralelo (diferentes arquivos)
- Passo 5 requer testes em 1-4
- Passos 6-9 podem rodar em paralelo (diferentes funções)
- Passo 10 pode rodar em paralelo (documentação)

**Arranjo Paralelo (2 devs):**
- Dev A: Passos 1-3 (Math), 7-8 (Interface) = 9-12h
- Dev B: Passos 4-6 (Testes/Config), 9-10 (Final) = 6-9h
- **Tempo Total Paralelo:** ~12-15h (1 semana com 2 devs)

---

## CRITÉRIO DE SUCESSO GLOBAL

Após todos 10 passos:
1. **Cobertura:** 95% (era 89%, +6%)
2. **Matemática:** Consistente (Round uniforme)
3. **Interface:** Unificada (Central_Testes_V2)
4. **Regressão:** Zero (todos testes anteriores passam)
5. **Documentação:** Completa (precision, dependency, policy)

**Nível de Confiança:** 90% → 95%
