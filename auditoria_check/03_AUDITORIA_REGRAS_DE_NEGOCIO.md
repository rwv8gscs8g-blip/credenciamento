# AUDITORIA DE REGRAS DE NEGÓCIO
## Reverse Engineering Completo do Algoritmo de Rodízio e Fluxo de OS

**Data:** 15 de abril de 2026  
**Fonte:** Engenharia reversa de Svc_Rodizio.bas, Svc_PreOS.bas, Svc_OS.bas, Svc_Avaliacao.bas

---

## 1. VISÃO GERAL DO FLUXO

```
SOLICITA SERVIÇO
    ↓
SELECIONA EMPRESA (Rodízio com 5 filtros A-E)
    ↓
EMITE PRÉ-OS (AGUARDANDO_ACEITE)
    ↓
[ESCOLHA DO USUÁRIO]
    ├─ ACEITA → EMITE OS (EM_EXECUCAO) → EXECUTA → AVALIA (10 notas)
    ├─ REJEITA → PRÉ-OS status = RECUSADA → VOLTA AO RODÍZIO (próxima empresa)
    └─ PRAZO EXPIRA → PRÉ-OS status = EXPIRADA → VOLTA AO RODÍZIO (próxima empresa)

[AVALIAÇÃO]
    ├─ Média >= notaMin → OS status = CONCLUIDA (OK)
    └─ Média < notaMin → Suspender empresa (SUSPENSA_GLOBAL)
```

---

## 2. ALGORITMO DE SELEÇÃO (Svc_Rodizio.SelecionarEmpresa)

### 2.1 Estrutura Geral

**Input:** ATIV_ID (atividade/CNAE)  
**Output:** TRodizioResultado (encontrou=True|False, Empresa, Credenciamento, MotivoFalha)

**Processo:**

```vba
1. BuscarFila(ATIV_ID) → array TCredenciamento[] ordenado por POSICAO_FILA
2. Para i = LBound até UBound
   a. FILTRO A: Se STATUS_CRED ≠ ATIVO → pular (sem punição)
   b. FILTRO B: Se STATUS_GLOBAL = SUSPENSA_GLOBAL
      - Se DT_FIM_SUSP <= Today → Reativar automaticamente e continuar
      - Senão → pular (sem punição)
   c. FILTRO C: Se STATUS_GLOBAL = INATIVA → pular (sem punição)
   d. FILTRO D: Se TemOSAbertaNaAtividade(EMP_ID, ATIV_ID) = True
      - MoverFinal(EMP_ID, ATIV_ID) sem punição
      - pular (sem registro de auditoria)
   e. FILTRO E: Se TemPreOSPendenteNaAtividade(EMP_ID, ATIV_ID) = True
      - pular SEM mover (sem punição, sem auditoria)
   f. APTO: 
      - RegistrarIndicacao(EMP_ID, ATIV_ID, DT_ULTIMA_IND=Now)
      - Retornar (encontrou=True, empresa, credenciamento)
3. Se nenhuma apta → Retornar (encontrou=False, MotivoFalha=concatenado)
```

### 2.2 Filtros Detalhados

#### FILTRO A: Status do Credenciamento Local
```
Condição: cred.STATUS_CRED ≠ "ATIVO"
Valores Possíveis: "ATIVO" | "INATIVO" | "SUSPENSO_LOCAL"
Ação: Pular (skip)
Punição: NÃO
Auditoria: NÃO
Motivo: Empresa não está credenciada ativa nesta atividade
```

**Evidência:**
```vba
If cred.STATUS_CRED <> STATUS_CRED_ATIVO Then
    cntFiltroA = cntFiltroA + 1
    GoTo ProximaEmpresa
End If
```

#### FILTRO B: Suspensão Global com Auto-Reativação
```
Condição: emp.STATUS_GLOBAL = "SUSPENSA_GLOBAL"
Sub-Lógica:
  - Se DT_FIM_SUSP > CDate(0) E DT_FIM_SUSP <= Date ENTÃO
      Reativar(EMP_ID)
      Reler dados da empresa
      Continuar avaliação
  - Senão
      Pular (skip)
Punição: NÃO (reativação é automática, sem penalidade)
Auditoria: SIM (evento EVT_REATIVACAO_AUTOMATICA)
Motivo: Prazo de suspensão venceu
```

**Evidência:**
```vba
If emp.STATUS_GLOBAL = STATUS_EMP_SUSPENSA Then
    If emp.DT_FIM_SUSP > CDate(0) And emp.DT_FIM_SUSP <= Date Then
        resOp = Reativar(cred.EMP_ID)
        emp = LerEmpresa(cred.EMP_ID, linhaEmp)
        ' Continua normalmente
    Else
        GoTo ProximaEmpresa
    End If
End If
```

#### FILTRO C: Inatividade Global
```
Condição: emp.STATUS_GLOBAL = "INATIVA"
Ação: Pular (skip)
Punição: NÃO
Auditoria: NÃO
Motivo: Empresa desligou do sistema
```

#### FILTRO D: OS Aberta na Atividade
```
Condição: TemOSAbertaNaAtividade(EMP_ID, ATIV_ID) = True
Ação:
  - MoverFinal(EMP_ID, ATIV_ID) → move para fim de fila
  - Pular (skip)
Punição: NÃO
Auditoria: NÃO
Motivo: Empresa já está executando serviço nesta atividade
Nota: MoverFinal sem increment de QTD_RECUSAS
```

**Lógica:**
```
SELECT * FROM CAD_OS 
WHERE EMP_ID = ? 
  AND ATIV_ID = ? 
  AND STATUS_OS IN ("EM_EXECUCAO")
```

#### FILTRO E: Pré-OS Pendente na Atividade
```
Condição: TemPreOSPendenteNaAtividade(EMP_ID, ATIV_ID) = True
Ação: Pular (skip) SEM MOVER
Punição: NÃO
Auditoria: NÃO
Motivo: Empresa já tem proposta aguardando resposta
Nota: DIFERENÇA CRÍTICA de D — não move na fila
```

**Lógica:**
```
SELECT * FROM PRE_OS
WHERE EMP_ID = ?
  AND ATIV_ID = ?
  AND STATUS_PREOS = "AGUARDANDO_ACEITE"
```

---

## 3. AVANÇO DE FILA (Svc_Rodizio.AvancarFila)

### 3.1 Assinatura

```vba
Function AvancarFila(
    EMP_ID As String,
    ATIV_ID As String,
    IsPunido As Boolean,       ' True=recusa/expiração, False=aceite/conclusão
    motivo As String           ' ex: "RECUSADA", "EXPIRADA", "ACEITE_OS_EMITIDA"
) As TResult
```

### 3.2 Fluxo

```
1. MoverFinal(EMP_ID, ATIV_ID) → reordena POSICAO_FILA
   - Decrementa POSICAO_FILA de todas à frente
   - Incrementa POSICAO_FILA desta para fim
   
2. Se IsPunido = True ENTÃO
   a. IncrementarRecusa(EMP_ID, ATIV_ID)
      - QTD_RECUSAS (local, nesta atividade)++
      - QTD_RECUSAS_GLOBAL (na empresa)++
   b. Busca cfg = GetConfig()
   c. Se QTD_RECUSAS_GLOBAL >= cfg.MAX_RECUSAS (default=3) ENTÃO
      Suspender(EMP_ID)
      - STATUS_GLOBAL = "SUSPENSA_GLOBAL"
      - DT_FIM_SUSP = Today + PERIODO_SUSPENSAO_MESES (default=1)
      - Audit_Log.RegistrarEvento(EVT_SUSPENSAO, ...)
   d. Audit_Log.RegistrarEvento(EVT_PREOS_RECUSADA ou EVT_PREOS_EXPIRADA, ...)

3. Se IsPunido = False ENTÃO
   - Apenas mover, sem incrementar QTD_RECUSAS
   - Sem auditoria especial (evento de aceite já registrado em Svc_PreOS)
```

### 3.3 Casos de Uso

| Caso | Quem Chama | IsPunido | Motivo | Auditoria |
|------|-----------|----------|--------|-----------|
| Rejeição explícita | Svc_PreOS.ReusarParaRecusa | True | "RECUSADA" | EVT_PREOS_RECUSADA |
| Prazo expirado | Svc_PreOS.Expirar | True | "EXPIRADA" | EVT_PREOS_EXPIRADA |
| Aceite e OS emitida | Svc_OS.EmitirOS | False | "ACEITE_OS_EMITIDA" | (já em Svc_OS) |
| Avaliação concluída | Svc_Avaliacao.AvaliarOS | False | "AVALIACAO_CONCLUIDA" | (já em Svc_Avaliacao) |

---

## 4. SUSPENSÃO E REATIVAÇÃO

### 4.1 Suspensão Automática

**Disparador:** AvancarFila quando QTD_RECUSAS_GLOBAL >= MAX_RECUSAS

```vba
Function Suspender(EMP_ID As String) As TResult
    emp = LerEmpresa(EMP_ID, linhaEmp)
    cfg = GetConfig()
    dtFimSusp = DateAdd("m", cfg.PERIODO_SUSPENSAO_MESES, Date)
    
    GravarStatusEmpresa(linhaEmp, "SUSPENSA_GLOBAL", dtFimSusp, -1)
    
    Audit_Log.RegistrarEvento _
        EVT_SUSPENSAO, ENT_EMP, EMP_ID, _
        "STATUS=" & emp.STATUS_GLOBAL, _
        "STATUS=SUSPENSA_GLOBAL; DT_FIM_SUSP=" & Format$(dtFimSusp, "DD/MM/YYYY"), _
        "Svc_Rodizio"
End Function
```

**Parâmetros:**
- DT_FIM_SUSP = Today + PERIODO_SUSPENSAO_MESES (via CONFIG)
- QTD_RECUSAS = reset a 0 (opcional — documentar)
- STATUS_GLOBAL = "SUSPENSA_GLOBAL"

### 4.2 Reativação Automática

**Disparador:** SelecionarEmpresa deteta empresa suspensa com DT_FIM_SUSP <= Today

```vba
If emp.STATUS_GLOBAL = STATUS_EMP_SUSPENSA Then
    If emp.DT_FIM_SUSP > CDate(0) And emp.DT_FIM_SUSP <= Date Then
        resOp = Reativar(cred.EMP_ID)
        emp = LerEmpresa(cred.EMP_ID, linhaEmp)
    Else
        GoTo ProximaEmpresa
    End If
End If
```

### 4.3 Reativação Manual (Futuro)

**Comentário:** "Pode também ser chamada manualmente pelo gestor (futuro Sprint 4)"  
**Status:** Não implementada em V12

---

## 5. AVALIAÇÃO E SUSPENSÃO POR NOTA

### 5.1 Cálculo da Média

```vba
soma = 0
For i = 1 To 10
    soma = soma + notas(i)  ' Integer 0-10
Next i
media = soma / 10#  ' Double exato
```

**Resultado:** media é Double com até 1 casa decimal (ex: 5.0, 5.2, 5.199999...)

### 5.2 Comparação com Nota Mínima

```vba
notaMin = GetNotaMinimaAvaliacao()  ' Default CONFIG: 5.0 (Double)
If media < notaMin Then
    resSusp = Suspender(os.EMP_ID)
End If
```

**Risco de Anomalia:**
- Cálculo usa `media = soma / 10#` (Double exato: 5.202)
- Impressão usa `Fix(media * 100) / 100` (truncado: 5.20)
- Armazenamento em DB: Double exato (5.202)
- Se notaMin = 5.20, empresa com MEDIA=5.199 não suspende mas imprime como 5.19

**Recomendação:** Documentar estratégia de comparação de Doubles (usar epsilon ou arredondamento explícito)

### 5.3 Avanço Automático de Fila Pós-Avaliação

```vba
Dim resAvancar As TResult
resAvancar = AvancarFila(os.EMP_ID, os.ATIV_ID, False, "AVALIACAO_CONCLUIDA")
' Sem punição — empresa sai de topo da fila após conclusão
```

**Motivo:** Sem isto, empresa fica travada na posição 1 e não permite próximas solicitações.

---

## 6. TABELA DE TRANSIÇÕES DE ESTADO

### 6.1 Empresa (STATUS_GLOBAL)

| Estado | Pode Transicionar Para | Via | Condição |
|--------|----------------------|-----|-----------|
| ATIVA | SUSPENSA_GLOBAL | Suspender | QTD_RECUSAS >= MAX_RECUSAS OU media < notaMin |
| ATIVA | INATIVA | (manual em UI) | Admin marca como inativa |
| SUSPENSA_GLOBAL | ATIVA | Reativar automática | DT_FIM_SUSP <= Today (no rodízio) |
| SUSPENSA_GLOBAL | ATIVA | Reativar manual | (futuro Sprint 4) |
| INATIVA | ATIVA | (manual em UI) | Admin reativa |

### 6.2 Credenciamento (STATUS_CRED)

| Estado | Pode Transicionar Para | Via | Condição |
|--------|----------------------|-----|-----------|
| ATIVO | INATIVO | (manual em UI) | Admin marca como inativo |
| ATIVO | SUSPENSO_LOCAL | (reservado, não implementado) | Futuro |
| INATIVO | ATIVO | (manual em UI) | Admin reativa |

### 6.3 Pré-OS (STATUS_PREOS)

| Estado | Pode Transicionar Para | Via | Condição |
|--------|----------------------|-----|-----------|
| AGUARDANDO_ACEITE | RECUSADA | Svc_PreOS.ReusarParaRecusa | Usuário clica "Rejeitar" |
| AGUARDANDO_ACEITE | EXPIRADA | Svc_PreOS.Expirar | DIAS_DECISAO vencido |
| AGUARDANDO_ACEITE | CONVERTIDA_OS | Svc_OS.EmitirOS | Usuário clica "Aceitar" |

### 6.4 OS (STATUS_OS)

| Estado | Pode Transicionar Para | Via | Condição |
|--------|----------------------|-----|-----------|
| EM_EXECUCAO | CONCLUIDA | Svc_Avaliacao.AvaliarOS | 10 notas preenchidas |
| EM_EXECUCAO | CANCELADA | Svc_OS.CancelarOS | Admin cancela |

---

## 7. INVARIANTES DE NEGÓCIO

### Invariantes Críticas (Deve Ser Sempre Verdadeiro)

| Invariante | Definição | Verificação |
|-----------|-----------|-------------|
| Fila Consistente | Cada credenciamento em CREDENCIADOS tem EMP_ID válido em EMPRESAS | SELECT CRED.EMP_ID FROM CREDENCIADOS LEFT JOIN EMPRESAS ... IS NULL |
| POSICAO_FILA Única | Não há duplicatas de POSICAO_FILA para (ATIV_ID, EMP_ID) | SELECT ATIV_ID, POSICAO_FILA, COUNT(*) GROUP BY 1,2 HAVING COUNT > 1 |
| QTD_RECUSAS Limitado | QTD_RECUSAS <= MAX_RECUSAS + 10 (buffer para debugging) | SELECT * FROM EMPRESAS WHERE QTD_RECUSAS > (MAX_RECUSAS + 10) |
| DT_FIM_SUSP Futuro | Se STATUS_GLOBAL=SUSPENSA_GLOBAL, então DT_FIM_SUSP > Today | SELECT * FROM EMPRESAS WHERE STATUS_GLOBAL='SUSPENSA_GLOBAL' AND DT_FIM_SUSP <= Today |
| Pre-OS Monotônico | Se PRE-OS i está CONVERTIDA_OS, existe OS com PREOS_ID=i | SELECT PREOS_ID FROM PRE_OS WHERE STATUS='CONVERTIDA_OS' AND PREOS_ID NOT IN (SELECT PREOS_ID FROM CAD_OS) |
| Nota no Intervalo | NOTA_01...NOTA_10 ∈ [0,10] | SELECT * FROM CAD_OS WHERE NOTA_XX < 0 OR NOTA_XX > 10 |

### Regras de Validação Pré-Operação

| Operação | Pré-Condição | Pós-Condição |
|----------|-------------|--------------|
| SelecionarEmpresa | ATIV_ID existe em ATIVIDADES | Retorna empresa apta OU MotivoFalha |
| EmitirPreOS | Empresa, atividade, entidade válidos | PRE_OS.STATUS = AGUARDANDO_ACEITE, DT_LIMITE = Today + DIAS_DECISAO |
| EmitirOS | Pre-OS.STATUS = AGUARDANDO_ACEITE | OS.STATUS = EM_EXECUCAO, PRE_OS.STATUS = CONVERTIDA_OS |
| AvaliarOS | OS.STATUS = EM_EXECUCAO | OS.STATUS = CONCLUIDA, MEDIA calculada e persistida |

---

## 8. MATRIZ DE EVENTOS AUDITADOS

| Tipo Evento | Código | Entidade | Descrição | Dados Capturados |
|-------------|--------|----------|-----------|-----------------|
| Rodízio | EVT_SELECAO_EMPRESA | ENT_CRED | Empresa selecionada | EMP_ID, ATIV_ID, motivo |
| Pré-OS | EVT_PREOS_EMITIDA | ENT_PREOS | Pré-OS criada | PREOS_ID, DT_LIMITE |
| Pré-OS | EVT_PREOS_RECUSADA | ENT_PREOS | Pré-OS recusada | PREOS_ID, MOTIVO, QTD_RECUSAS_NOVO |
| Pré-OS | EVT_PREOS_EXPIRADA | ENT_PREOS | Prazo expirou | PREOS_ID, DIAS_PASSADOS |
| OS | EVT_OS_EMITIDA | ENT_OS | OS criada | OS_ID, PREOS_ID |
| OS | EVT_OS_FECHADA | ENT_OS | OS concluída com avaliação | OS_ID, MEDIA |
| OS | EVT_OS_CANCELADA | ENT_OS | OS cancelada | OS_ID, JUSTIFICATIVA |
| Suspensão | EVT_SUSPENSAO | ENT_EMP | Empresa suspensa | EMP_ID, MOTIVO (MAX_RECUSAS ou NOTA_BAIXA) |
| Reativação | EVT_REATIVACAO_AUTOMATICA | ENT_EMP | Empresa reativada automaticamente | EMP_ID, DT_FIM_SUSP |
| Reativação | EVT_REATIVACAO_MANUAL | ENT_EMP | Admin reativou manualmente | EMP_ID, USER |

---

## 9. CASOS DE TESTE DERIVADOS

### 9.1 Rodízio Normal (Happy Path)

**Cenário:** Atividade A tem 3 empresas credenciadas (E1, E2, E3)
1. SelecionarEmpresa(A) → E1 (primeira na fila)
2. RegistrarIndicacao(E1, A)
3. EmitirPreOS para E1
4. [Usuário aceita]
5. EmitirOS
6. [Executa serviço]
7. AvaliarOS (media >= notaMin)
8. AvancarFila(E1, A, False) → E1 vai para fim
9. Próxima SelecionarEmpresa(A) → E2
10. [Repetir...]

**Verificação:** POSICAO_FILA de E1 muda de 1 para 3

### 9.2 Recusa com Suspensão

**Cenário:** E1 já recusou 2 vezes (MAX_RECUSAS=3)
1. SelecionarEmpresa(A) → E1
2. EmitirPreOS para E1
3. [Usuário rejeita]
4. ReusarParaRecusa → AvancarFila(E1, A, IsPunido=True)
5. QTD_RECUSAS_GLOBAL(E1) = 3
6. Automático: Suspender(E1)
7. E1.STATUS_GLOBAL = SUSPENSA_GLOBAL
8. E1.DT_FIM_SUSP = Today + 1 mês

**Próxima SelecionarEmpresa(A):**
- E1 é detectada como suspensa (FILTRO B)
- Pulada automaticamente
- E2 selecionada

### 9.3 Auto-Reativação no Rodízio

**Cenário:** E1 suspensa desde 2026-04-01, reativação periódica 1 mês, hoje é 2026-05-02
1. SelecionarEmpresa(A)
2. [Loop na fila] encontra E1
3. FILTRO B: E1.STATUS_GLOBAL = SUSPENSA_GLOBAL
4. DT_FIM_SUSP (2026-05-01) <= Today (2026-05-02) → True
5. Reativar(E1) → STATUS_GLOBAL = ATIVA, QTD_RECUSAS = 0, DT_FIM_SUSP = null
6. E1 continua na avaliação (pode ser selecionada)

### 9.4 OS Aberta Bloqueia Seleção

**Cenário:** E1 tem OS aberta em A, chega nova solicitação em A
1. SelecionarEmpresa(A)
2. [Loop na fila] encontra E1 (topo)
3. FILTRO D: TemOSAbertaNaAtividade(E1, A) = True
4. MoverFinal(E1, A) → POSICAO_FILA(E1) = 3
5. [Continua loop] E2 selecionada

**Próxima SelecionarEmpresa(A):**
- E1 está no fim, E2 é topo
- E2 selecionada (se apto)

### 9.5 Pré-OS Pendente Bloqueia Seleção

**Cenário:** E1 tem Pré-OS aguardando, chega nova solicitação em A
1. SelecionarEmpresa(A)
2. [Loop na fila] encontra E1 (topo)
3. FILTRO E: TemPreOSPendenteNaAtividade(E1, A) = True
4. **NÃO move na fila** (diferença de FILTRO D)
5. [Continua loop] E2 selecionada

**Observação:** E1 continua na posição 1; próxima solicitação encontrará novamente E1 (se Pré-OS não for resolvida)

### 9.6 Avaliação com Nota Baixa Suspende

**Cenário:** OS concluída, notas = [3, 4, 5, 4, 3, 5, 4, 3, 5, 4], média = 4.0, notaMin = 5.0
1. AvaliarOS(OS_ID, notas, ...)
2. media = 40 / 10# = 4.0
3. 4.0 < 5.0 → True
4. Automático: Suspender(EMP_ID)
5. EMP.STATUS_GLOBAL = SUSPENSA_GLOBAL

**Auditoria:** EVT_OS_FECHADA com MEDIA=4.00, EVT_SUSPENSAO automático

---

## 10. INVARIANTES DESCOBERTOS NÃO DOCUMENTADOS

1. **Reativação automática é idempotente:** Se empresa já está ATIVA, Reativar retorna sucesso sem mudanças
2. **MoverFinal não se aplica a empresas inativas:** Se STATUS_GLOBAL ≠ ATIVA durante MoverFinal, operação falha
3. **DT_ULTIMA_IND é atualizado a cada SelecionarEmpresa:** Mesmo se empresa não for usada (apenas passada por filtro A)
4. **Audit_Log é imutável:** Nenhum delete ou update permitido (append-only)
5. **Suspensão pode ocorrer sem auditoria se GetConfig() falhar:** (bug potencial)

---

## CONCLUSÃO E RECOMENDAÇÕES

**Achados:**

1. **Algoritmo de rodízio é determinístico e bem-definido** (Filtros A-E claros)
2. **Transições de estado são bem mapeadas** (5 entidades principais)
3. **Anomalia de avaliação: Double precision não sincronizada** com impressão (5.20 vs 5.199)
4. **Suspensão automática não distingue causa** (MAX_RECUSAS vs NOTA_BAIXA) — falta flag TIPO_SUSPENSAO
5. **Reativação manual documentada mas não implementada** (comentário "futuro Sprint 4")

**Recomendações:**

- P0: Documentar anomalia de avaliação em SLA
- P1: Adicionar TIPO_SUSPENSAO (AUTO_RECUSAS | AUTO_AVALIACAO | MANUAL) para compliance
- P1: Implementar reativação manual (Sprint 4)
- P2: Refatorar comparação de notas com epsilon ou rounding explícito
- P2: Adicionar invariante checker em diagnostic module

