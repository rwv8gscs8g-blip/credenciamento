---
titulo: 65 - Auditoria Antigravity V203 rc4 e V204
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0203-rc4
data: 2026-05-04
---

# 65. Auditoria Antigravity V203 rc4 e V204

## 1. Decisão Executiva

**APROVADO_PARA_TESTE_MANUAL**

A versão V12.0.0203-rc4 cumpriu os requisitos do Quinteto de Validação (171/0, 27/0, 23/0, 71/0, 3/0). A resolução da coluna `DT_ULT_REATIV` e a estabilização da contagem de strikes foram integradas satisfatoriamente no modelo "Opção B" (janela pós-reativação), fechando o débito crítico `DT-17-REATIV-STRIKES`.

No entanto, **não aprovo para produção**. Foram identificadas lacunas na arquitetura transacional e mutações assíncronas entre UI e API, além de silenciosos `On Error Resume Next`. A rc4 é liberada puramente como teste manual formal, devendo os achados orientar a priorização da V12.0.0204.

## 2. Achados Adversariais (P0/P1/P2)

| Sev | Tipo | Caminho:Linha | Descrição e Impacto |
|---|---|---|---|
| **P0** | UI Reentrada | `src/vba/Reativa_Empresa.frm:222`<br>`src/vba/Reativa_Entidade.frm:240` | **Reentrada por Duplo Clique:** Formulários destrutivos/mutadores (`_DblClick`) não possuem *guard clauses* (flag de processamento em andamento). O usuário do Excel pode disparar a mesma ação múltipla vezes com *double-clicks* frenéticos, causando cópias repetidas da mesma linha. |
| **P0** | Bypass de Regra | `src/vba/Reativa_Empresa.frm:301-349` | **Mutação Direta (UI Bypass):** A operação não utiliza `Svc_Rodizio.Reativar` nem o `AUDIT_LOG`. Ela faz `Range.Copy` cru das inativas para as ativas, mascarando as ações do gestor e bypassando `DT_ULT_REATIV`. |
| **P1** | Mascaramento | `src/vba/Reativa_Empresa.frm:22,56`<br>`src/vba/Reativa_Entidade.frm:23,57,136` | **On Error Resume Next:** Uso de supressão silenciosa em eventos críticos de inicialização de formulário ou UI de transição, que pode esconder carregamentos degradados e causar perda silenciosa de dados. |
| **P1** | Falso Sucesso | `src/vba/Repo_Empresa.bas:64-100`<br>`src/vba/Svc_Rodizio.bas` | **`sucesso = True` após Falha Silenciosa:** `GravarStatusEmpresa` é um `Public Sub` que não sinaliza erro. Quando `Svc_Rodizio.Reativar` ou `Suspender` a invoca, marca `sucesso = True` independentemente do sucesso efetivo no filesystem, permitindo drift entre `CAD_OS` e `EMPRESAS`. |
| **P1** | Call Order | `src/vba/Svc_OS.bas:130-172` | **Ordem de Dependência Não Documentada:** `EmitirOS` insere a nova OS antes de preparar e converter a `PRE_OS`. Se a conversão da pré-OS falhar no processo, teremos uma OS criada e órfã do lado de cá, com a fila lógica possivelmente já avançada. |
| **P2** | Mutação de Estado | `src/vba/Svc_Rodizio.bas:85-97` | **Side-effect Global em Nome Neutro:** A função `SelecionarEmpresa` realiza reativação automática de empresa e move empresas ocupadas para o fim da fila de forma assíncrona. Funções de seleção ("read-like") não devem mutar estado operacional base. |
| **P2** | Falha de Ordenação | `src/vba/Classificar.bas:29` | **Esquecimento da Coluna U:** Recentemente corrigida (MICRO30-fix1), a falha onde `ClassificaEmpresa` parava na coluna `T` mostra o risco residual de `Hardcoded Ranges` ignorando `DT_ULT_REATIV`. Exige monitoramento ativo. |

## 3. Matriz Combinatória Requerida

Foram cruzados os seguintes estados fundamentais para entender o limite sistêmico.

| Entidade | Empresa | DT_ULT_REATIV | OS | Avaliação (em rel. à Reativ.) | Operador | Base | Cobertura / Risco |
|---|---|---|---|---|---|---|---|
| Existe | Ativa | Preenchida | Fechada | Depois da Reativação | Service | Limpa | ✅ OK (CS_E2E_REATIV2STRIKES) |
| Existe | Ativa | Preenchida | Cancelada | Igual (mesmo timestamp) | Service | Migrada | 🟡 Ambiguidade na contagem temporal em avaliações *backdated*. |
| Não Existe | Inativa | Vazia (Legado) | Aberta | Antes da Reativação | Form | Migrada | ❌ Erro não tratado. `BuscarPorEmpresa` com vazias gera falha silenciosa de strikes. |
| Existe | Suspensa | Inválida (String) | Fechada | Antes da Reativação | Menu | Com Órfãos | ❌ Conversão de string (ex: "") ou lixo de memória pode causar Type Mismatch não capturado. |
| Existe | Suspensa | Vazia | Fechada | Depois | Form (UI Bypass) | Migrada | ❌ **Risco Crítico:** UI de Reativação manual bypassa serviço; `DT_ULT_REATIV` não é salva, logo ela reativa e sofre suspensão na 1ª avaliação. |

## 4. Comparativo V202 -> V203 rc4

A versão **V12.0.0202** operava sob forte heurística e falta de isolamento arquitetural, com forms lendo dimensões `Top/Left` de labels para decisões lógicas e duplicação da variável de contagem de punição sem persistência.

A **V12.0.0203 rc4** entrega:
- **Heurística Zero:** Validação formal removendo dependências baseadas em UI layout e `InStr(Caption)`.
- **Arquitetura Service-Repo:** Camada isolada entre `Svc_*` e `Repo_*`.
- **Resolução DT-17-REATIV-STRIKES:** Coluna explícita `DT_ULT_REATIV` garantindo que strikes antes da suspensão são preservados em histórico mas isolados para efeitos de novas punições (Opção B).
- **Drift Mínimo V2:** Suíte V2 com +100 asserts novos cobrindo integrações (de 65 para 71 asserts E2E na rc4).

**Déficit de V203 rc4:** A separação "UI vs API" revelou o quão defasados estão os Forms. Vários `Reativa_*.frm` continuam fazendo *copia e cola* de planilhas (`Range.Copy`) e bypassando as APIs recém-construídas.

## 5. Lacunas de Teste por Regra de Negócio

| Regra de Negócio | Lacuna no Teste Atual |
|---|---|
| *Empresa suspensa acumula strikes mas não avança punição* | Falta cenário comprovando que se a empresa já está suspensa, uma nova Avaliação Baixa não tenta suspender de novo ou quebrar o `Svc_Transacao`. |
| *Reativação zera strikes operacionais* | O teste abrange o **Serviço** automático, mas inexiste *assert* garantindo o que ocorre se o Gestor usar o **Formulário de Reativação** manual pelo Menu Principal. |
| *Avaliação de OS sem DT_FECHAMENTO preenchida* | `Repo_Avaliacao.ContarStrikesParaPunicao` compara `DT_FECHAMENTO > DT_ULT_REATIV`. Há lacuna em que OS sem data não computa punição ou gera Type Mismatch. |

## 6. Riscos de Segurança Preventiva

- **Criptografia Simétrica ou Senhas Hardcoded:** A operação `Limpar_Base.frm` lida com destrutibilidade alta usando senha fixada no código fonte. Um ataque combinatório interno é trivial.
- **Race Condition em VBA:** A falta de semáforos globais e o processamento síncrono frágil perante cliques repetidos (`DblClick` nos Forms) abrem um *Exploit* de duplicação massiva da base `EMPRESAS`.
- **Transação Assíncrona Parcial:** Transações emuladas (ex: `Svc_OS.EmitirOS`) não têm *Atomicidade*. Ocorrendo um Crash do Excel, bases podem ficar pela metade (`PRE_OS` convertida, mas `CAD_OS` vazia).

## 7. Proposta Detalhada de Baterias V204

Na v204 a suíte E2E deve focar agressivamente na simulação humana errática:

1. **`TV2_RunAdversarial_UI`:** Rotina que força a injeção simulada (bypass do mouse) disparando eventos VBA `_Click` e `_DblClick` duplicados em frações de segundo para comprovar que o sistema ignora o 2º clique ou emite erro estruturado de Transação-Em-Andamento.
2. **`TV2_RunTransaction_Interrupt`:** Uma interrupção manual da thread VBA (Emulação via trigger on-error interno) no meio de `Svc_PreOS.EmitirPreOS` garantindo que o `Rollback` reverte tanto a `EMPRESA` quanto `CREDENCIADOS`.
3. **`TV2_RunBoundary_Dates`:** Conjunto de testes de borda para `DT_ULT_REATIV` simulando anos bissextos, campos vazios e datas futuras corrompidas, garantindo sanitização ou fallback defensivo (ex: fallback para modo legado sem travar a thread).

## 8. Proposta Detalhada de Evoluções V204

1. **Refatoração Drástica dos Formulários (Feature Parity API):** `Reativa_Empresa.frm`, `Reativa_Entidade.frm`, `Altera_Empresa.frm` perdem o acesso ao `Range` da planilha. Devem obrigatoriamente popular instâncias UDT, enviar ao serviço `Svc_*.Reativar()` ou `Svc_*.Atualizar()` e apenas repintar o *ListObject*. Esta é a tarefa nº 1.
2. **Strict Mode de Erros:** O banimento do `On Error Resume Next` de escopos globais. Ele só deve existir no Handler de fechamento (ex: reset do `EnableEvents`), em linhas isoladas para operações *try-read* muito específicas e documentadas, falhando com `Result=False` na API original.
3. **Conversão de `Public Sub` em Functions Transacionais:** Padronizar `Repo_Empresa.GravarStatusEmpresa` para retornar um `TResult` transacional autêntico informando se a operação no disco local realmente foi processada.
4. **Semáforo Global de Interface:** Inclusão do flag `Application.Cursor = xlWait` junto com um lock local por formulário `bIsProcessing As Boolean` validado no topo de todo evento que chama a camada de Serviços.
5. **Automação Completa de Backfill:** O módulo de `Auto_Open.bas` na V204 deve vasculhar `AUDIT_LOG` no Load 1 para empresas em modo legado (Coluna U vazia) que possuam evento formal "REATIVADA", inserindo a data oficial automaticamente na base (Backfill transparente e auditável).

## 9. Markers HBN Finais

- `✅ HBN ACTIVE`
- `⚪ HBN AUDIT-ONLY`
- `🔵 HBN HANDOFF READY`
- `🟡 HBN NEEDS HUMAN DECISION` — Decidir tagueamento formal do GitHub release v12.0.0203 rc4, aprovar V204 e aceitar a estratégia de mitigação de forms para o backlog de tarefas.
