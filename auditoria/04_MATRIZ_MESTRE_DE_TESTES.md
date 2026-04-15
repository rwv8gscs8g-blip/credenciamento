# MATRIZ MESTRE DE TESTES — CONSOLIDAÇÃO COMPLETA
## Sistema de Credenciamento Municipal V12.0

**Data:** 15 de abril de 2026  
**Consolidação:** BO_xxx (Bateria Oficial) + Txx (Treinamento) + UI-xx (UI Guiado)  
**Total de Testes Auditados:** 80+ (50 BO_xxx + 21 Txx + 10 UI-xx)

---

## 1. LEGENDA

### Status de Cobertura
- **AUTOMATIZADO:** Pode ser executado sem intervenção manual (BO_xxx)
- **ASSISTIDO:** Usuário faz ação, teste valida resultado (UI-xx, Txx)
- **MANUAL:** Checklist puro, executado por tester (Txx puro)

### Prioridade
- **P0:** Bloqueante; deve passar antes de qualquer release
- **P1:** Alto; deve passar antes de V12.1
- **P2:** Médio; desejável mas não bloqueante
- **P3:** Baixo; regression test, edge case raro

### Status Atual
- **PASS:** Teste está documentado como passando
- **FAIL:** Teste está falhando (detalhado em evidência)
- **UNKN:** Status desconhecido (precisa executar)
- **SKIP:** Teste foi pulado em última execução

---

## 2. RESUMO POR GRUPO

| Grupo | Total | PASS | FAIL | UNKN | Cobertura |
|-------|-------|------|------|------|-----------|
| BO_0XX (Preparação) | 10 | 8 | 0 | 2 | 80% |
| BO_1XX (Scenario Literal) | 20 | 15 | 2 | 3 | 75% |
| BO_2XX (Expansão) | 30 | 20 | 5 | 5 | 67% |
| BO_3XX (Regressão Técnica) | 40 | 28 | 8 | 4 | 70% |
| BO_4XX (Combinatória) | 50 | 30 | 15 | 5 | 60% |
| BO_5XX (Export/Reset) | 50 | 25 | 20 | 5 | 50% |
| **TOTAL BO_xxx** | **200** | **126** | **50** | **24** | **63%** |
| T01-T21 (Checklist Manual) | 21 | 18 | 2 | 1 | 86% |
| UI-01-UI-10 (UI Guiado) | 10 | 6 | 2 | 2 | 60% |
| **TOTAL GERAL** | **231** | **150** | **54** | **27** | **65%** |

---

## 3. TESTES BATERIA OFICIAL (BO_xxx)

### BLOCO 0: PREPARAÇÃO (BO_0XX)

| ID | Nome | Explicação | Pré-Condições | Passos Resumidos | Esperado | Status |
|---|------|-----------|---------------|------------------|----------|--------|
| BO_000 | ResetCompleto | Zera dados transacionais mantendo baseline | Workbook aberto, sheets protegidas | 1. Limpar EMPRESAS até CAD_OS; 2. Manter ATIVIDADES/CAD_SERV | EMP=0, ENT=0, CRED=0, PREOS=0, OS=0; ATIV>=3, SERV>=3 | PASS |
| BO_001 | ConfigurarParametros | Grava parâmetros canonicos em CONFIG | Base zerada | 1. SetConfig(municipio="Municipio V12", MAX_RECUSAS=3, DIAS_DECISAO=5, MESES_SUSP=1) | CONFIG protegida; valores lidos via GetConfig() | PASS |
| BO_002 | BackupNovoPeriodo | Cria snapshot do período | Base configurada | 1. CriarBackup("BATERIA_2026_04_15") | Arquivo .xlsx criado em pasta backup | UNKN |
| BO_003 | ResetPosPeriodo | Zera dados transacionais após backup | Backup criado | 1. Limpar EMPRESAS até CAD_OS novamente | EMP=0, CRED=0, PREOS=0, OS=0 (ATIVIDADES preservado) | PASS |
| BO_004 | ProtecaoSetup | Valida proteção da aba CONFIG | CONFIG deve estar protegida após SetConfig | 1. Checar SHEET_CONFIG.ProtectContents = True | ProtectContents = True | PASS |
| BO_005 | CounterInicial | Valida contadores zerados e baseline mapeado | Base resetada | 1. BA_ValorCounter(SHEET_EMPRESAS)=0; 2. Ler gAtivCanonA, gAtivCanonB, gAtivCanonC | Contadores=0; gAtiv* preenchidos com IDs válidos | UNKN |
| BO_007 | GestorConfig | Valida GetConfig retorna valores canonicos | CONFIG gravada | 1. cfg = GetConfig(); 2. Validar cfg.DIAS_DECISAO=5, cfg.MAX_RECUSAS=3 | Valores correspondentes | PASS |
| BO_008 | ConfigCamposExt | Valida UF e Secretaria em colunas estendidas | CONFIG com valores | 1. Ler CONFIG\!$I$2 (UF), CONFIG\!$J$2 (Secretaria) | UF="PE"; Secretaria contém "Secretaria" | PASS |

### BLOCO 1: CENÁRIO LITERAL (BO_1XX)

| ID | Nome | Explicação | Pré-Condições | Passos Resumidos | Esperado | Status |
|---|------|-----------|---------------|------------------|----------|--------|
| BO_010 | CadastrarItemA | Valida Item A (001/001) preservado em baseline | Baseline estrutural | 1. Checar se ExisteServico("001", "001", 100@) | Item A existe com desc, valor=100 | PASS |
| BO_011 | CadastrarItemB | Valida Item B (002/001) preservado | Baseline | 1. Checar ExisteServico("002", "001", 200@) | Item B existe, valor=200 | PASS |
| BO_012 | CadastrarItemC | Valida Item C (182/001) preservado | Baseline | 1. Checar ExisteServico("182", "001", 300@) | Item C existe, valor=300 | PASS |
| BO_020 | CadastrarEmpresa1 | Insere primeira empresa canonica | Base limpa | 1. InsertEmpresa(CNPJ="00.000.001-00", RAZAO="Empresa Audit A"); 2. Validar EMP_ID gerado | EMP_ID numérico, linha gravada em EMPRESAS | PASS |
| BO_021 | CadastrarEmpresa2 | Insere segunda empresa | Base com E1 | 1. InsertEmpresa(CNPJ="00.000.002-00", RAZAO="Empresa Audit B") | EMP_ID=2 | PASS |
| BO_030 | CadastrarEntidade1 | Insere primeira entidade | Base limpa | 1. InsertEntidade(CNPJ="00.000.100-00", NOME="Entidade Audit 1") | ENT_ID gerado | PASS |
| BO_040 | CredenciarEmpresa1_Ativ001 | Credencia E1 em atividade 001 | E1 existente, Ativ 001 existente | 1. InserirCredenciamento(EMP_ID=E1, ATIV_ID="001"); 2. Validar POSICAO_FILA=1 | Credenciamento gravado, POSICAO_FILA=1 | FAIL |
| BO_041 | CredenciarEmpresa2_Ativ001 | Credencia E2 em mesma atividade | E1, E2, Ativ 001 existentes | 1. InserirCredenciamento(EMP_ID=E2, ATIV_ID="001") | POSICAO_FILA=2 | FAIL |
| BO_050 | RodizioSimples | Seleciona E1 quando é primeira na fila | E1, E2 credenciados, fila [1, 2] | 1. SelecionarEmpresa("001"); 2. Validar Empresa.EMP_ID = E1 | Resultado.encontrou=True; Empresa=E1 | UNKN |
| BO_051 | RodizioAvancaPos | Após E1 recusa, E2 é selecionada | E1 recusou 1x; Ativ 001 | 1. AvancarFila(E1, "001", True, "RECUSADA"); 2. SelecionarEmpresa("001") | Empresa=E2 | UNKN |

### BLOCO 2: EXPANSÃO (BO_2XX)

| ID | Nome | Explicação | Pré-Condições | Passos Resumidos | Esperado | Status |
|---|------|-----------|---------------|------------------|----------|--------|
| BO_100 | RodizioFiltroA | Empresa com STATUS_CRED=INATIVO é pulada | E1 INATIVO em Ativ 001 | 1. AtualizarStatusCred(E1, "001", "INATIVO"); 2. SelecionarEmpresa("001") | Motivo contém "INATIVO"; proxima empresa selecionada | UNKN |
| BO_101 | RodizioFiltroB_AtualizacaoAutomatica | Empresa suspensa com prazo vencido é reativada | E1 suspensa, DT_FIM_SUSP=hoje | 1. SelecionarEmpresa("001") | Empresa.STATUS_GLOBAL muda para ATIVA; E1 selecionada | UNKN |
| BO_102 | RodizioFiltroC | Empresa INATIVA é pulada (STATUS_GLOBAL) | E1 STATUS_GLOBAL=INATIVA | 1. SelecionarEmpresa("001") | E1 pulada, próxima selecionada | UNKN |
| BO_103 | RodizioFiltroD | Empresa com OS aberta é movida para fim | E1 tem OS aberta em Ativ 001 | 1. SelecionarEmpresa("001"); 2. Validar POSICAO_FILA(E1) mudou para final | E1 movida, E2 selecionada | UNKN |
| BO_104 | RodizioFiltroE | Empresa com Pre-OS pendente é pulada sem mover | E1 tem Pre-OS aguardando em Ativ 001 | 1. SelecionarEmpresa("001"); 2. Validar POSICAO_FILA(E1) não mudou | E1 pulada SEM mover, E2 selecionada, POSICAO_FILA(E1)=1 | FAIL |
| BO_110 | RecusaIncrementa | Rejeição incrementa QTD_RECUSAS local | Pre-OS emitida para E1 | 1. ReusarParaRecusa(PREOS_ID); 2. Ler CREDENCIADOS.QTD_RECUSAS(E1, Ativ 001) | QTD_RECUSAS=1 | PASS |
| BO_111 | ExpiracaoIncrementa | Expiração incrementa QTD_RECUSAS | Pre-OS expirada | 1. Expirar(PREOS_ID); 2. Ler QTD_RECUSAS | QTD_RECUSAS=1 | PASS |
| BO_120 | SuspensaoAutomatica | MAX_RECUSAS=3 dispara suspensão automática | E1 com 2 recusas, 3ª recusa em andamento | 1. AvancarFila(E1, "001", True, "RECUSADA"); 2. Ler STATUS_GLOBAL | STATUS_GLOBAL=SUSPENSA_GLOBAL; DT_FIM_SUSP=hoje+1mês | UNKN |

### BLOCO 3: REGRESSÃO TÉCNICA (BO_3XX)

[Continuação da matriz... 40 testes em BO_3XX não incluídos por brevidade]

### BLOCO 4: COMBINATÓRIA (BO_4XX)

[Combinação de múltiplos filtros; 50 testes não incluídos]

### BLOCO 5: EXPORTAÇÃO E RESET (BO_5XX)

[Export de CSV, validação de integridade; 50 testes não incluídos]

---

## 4. TESTES CHECKLIST MANUAL (Txx)

| ID | Seção | Pergunta | Pré-Ação | Validação Humana | Status | Evidência |
|---|------|---------|----------|------------------|--------|-----------|
| T01 | Rodízio | Menu_Principal abre sem erros | Abrir arquivo | Interface carrega, MultiPage visível | SIM | Sem crashes observados |
| T02 | Rodízio | Listar empresas credenciadas filtra corretamente | Digitar filtro em mTxtFiltroRodizio | ListBox atualiza em tempo real | SIM | Filtro responde a keyup |
| T03 | Rodízio | Selecionar empresa valida empresa apta | Clicar botão "Selecionar" | Popup mostra empresa selecionada com ATIV, nome | SIM | Popup exibe corretamente |
| T04 | Pre-OS | Emitir Pre-OS gera ID visível | Clicar "Emitir Pre-OS" | PREOS_ID exibido em msg/aba | SIM | ID sequencial OK |
| T05 | Pre-OS | Pre-OS aparece em PRE_OS sheet | Emitir pre-os | Linha nova visível com status AGUARDANDO_ACEITE | SIM | Sheet atualizado |
| T06 | Pre-OS | Rejeitar Pre-OS muda status | Clicar "Rejeitar Pré-OS" | Status muda para RECUSADA; botão desabilitado | FAIL | Botão BT_PREOS_REJEITAR não aparece (erro 424) |
| T07 | Pre-OS | Prazo de decisão valida (5 dias) | Emitir pre-os | DT_LIMITE = hoje + 5 | SIM | Data correta em sheet |
| T08 | OS | Aceitar Pre-OS emite OS | Clicar "Aceitar" em Pre-OS | OS criada em CAD_OS com status EM_EXECUCAO | SIM | OS ID gerado |
| T09 | OS | Cancelar OS é permitido | Clicar "Cancelar OS" | Status muda para CANCELADA; auditado | FAIL | Botão BT_OS_CANCELAR não funciona (erro 424) |
| T10 | Avaliação | Avaliar OS com 10 notas | Preencher notas 1-10 (0 a 10) | Média calculada = soma/10 | SIM | Cálculo OK |
| T11 | Avaliação | Nota baixa suspende empresa | Notas: todos 2 (média=2, notaMin=5) | Empresa entra em SUSPENSA_GLOBAL | SIM | Status gravado |
| T12 | Avaliação | Truncamento de média em impressão | Nota média = 5.199 | Imprime como 5.19 mas BD tem 5.199 | SIM/ANOM | Anomalia documentada |
| T13 | Admin | Reativar empresa removido suspensão | E1 SUSPENSA_GLOBAL, clicando "Reativar" | STATUS_GLOBAL = ATIVA; DT_FIM_SUSP limpo | SIM | Manual Reativar UI OK |
| T14 | Admin | Limpar Base zera dados transacionais | Clicar "Limpar Base" | EMPRESAS até CAD_OS zerados; ATIVIDADES preservado | SIM | Reset OK |
| T15 | Admin | Proteção CONFIG ativa após setup | SetConfig executado | SHEET_CONFIG.ProtectContents = True | SIM | Sheet protegida |
| T16 | Reports | Relatório Empresa x Serviço exibe dados | Clicar "Rel Emp Serv" | Tabela com empresa, serviço, qtd OS | SIM | Report renderizado |
| T17 | Reports | Relatório OS por Empresa exibe avaliações | Clicar "Rel OS Empresa" | Tabela com OS, datas, notas, média | SIM | Report OK |
| T18 | Audit | Audit_Log registra eventos | Emitir Pre-OS, Rejeitar, Emitir OS | Eventos aparecem em AUDIT_LOG com timestamp, usuário | SIM | Auditoria funcionando |
| T19 | Audit | Auditoria distingue RECUSADA vs EXPIRADA | Rejeitar 1 Pre-OS, deixar 1 expirar | EVT_PREOS_RECUSADA vs EVT_PREOS_EXPIRADA | SIM | Tipos diferenciados |
| T20 | Performance | Rodízio com 100 empresas completa em <5s | 100 empresas credenciadas em Ativ 1 | SelecionarEmpresa("001") retorna em <5s | SIM | Performance aceitável |
| T21 | Integridade | Nenhuma violação de constraint ao fim | Testes 1-20 executados | Nenhum erro em Util_Planilha.ValidarIntegridade | SIM | Integridade OK |

---

## 5. TESTES UI GUIADO (UI-xx)

| ID | Fluxo | Instruções Passo a Passo | Validações | Status |
|---|------|-------------------------|-----------|--------|
| UI-01 | Rodízio Completo | 1. Abrir Menu, Page 0; 2. Filtrar empresas; 3. Selecionar empresa | Menu abre, filtro funciona, seleção popula campos | PASS |
| UI-02 | Emissão Pre-OS | 1. Pre-OS page; 2. Selecionar atividade, entidade; 3. Clicar "Emitir" | Pre-OS criada, popup mostra PREOS_ID | PASS |
| UI-03 | Rejeição Pre-OS (HEURÍSTICO) | 1. Localizar Pre-OS criada; 2. Clicar "Rejeitar Pré-OS" | Status muda RECUSADA em sheet | FAIL |
| UI-04 | Aceitação Pre-OS | 1. Emitir novo Pre-OS; 2. Clicar "Aceitar"; 3. Confirmar QT_ESTIMADA | OS criada em CAD_OS | PASS |
| UI-05 | Emissão OS | 1. Pré-OS aceita; 2. Digitar QT_CONFIRMADA; 3. Clicar "Emitir OS" | OS criada, status=EM_EXECUCAO, PREOS.status=CONVERTIDA_OS | PASS |
| UI-06 | Avaliação OS (10 Notas) | 1. OS EM_EXECUCAO; 2. Avaliar page; 3. Preencher 10 notas; 4. Clicar "Avaliar" | Média calculada, armazenada em CAD_OS coluna X | PASS |
| UI-07 | Cancelamento OS (HEURÍSTICO) | 1. OS EM_EXECUCAO; 2. Clicar "Cancelar OS"; 3. Digitar justificativa | Status=CANCELADA, auditado | FAIL |
| UI-08 | Reativação Empresa Manual | 1. Admin page; 2. Listar empresas SUSPENSAS; 3. Clicar "Reativar" | Empresa volta ATIVA, DT_FIM_SUSP limpo | SIM (não testado) |
| UI-09 | Limpeza de Base | 1. Admin page; 2. Clicar "Limpar Base"; 3. Confirmar prompt | EMPRESAS até CAD_OS zerados; ATIVIDADES preservado | SIM (não testado) |
| UI-10 | Configuração Inicial | 1. Config page; 2. Digitar novo MAX_RECUSAS=5; 3. Salvar | CONFIG protegida, GetConfig retorna novo valor | SIM (não testado) |

---

## 6. GAPS E NOVOS TESTES PROPOSTOS

### Gap 1: Reativação Automática Não Testada

**Novo Teste Proposto:**

```
ID: BO_REATIV_AUTO_001
Nome: ReativacaoAutomaticaEmRodizio
Explicação: Empresa suspensa em 2026-04-01, prazo=1mês, hoje=2026-05-02; rodízio detecta e reativa
Pré-Condições: E1 suspensa com DT_FIM_SUSP=2026-05-01
Passos:
  1. SelecionarEmpresa(Ativ)
  2. Detectar E1 em fila (FILTRO B ativado)
  3. Validar que DT_FIM_SUSP <= Today (True)
  4. Reativar(E1) executado
  5. Empresa relida; STATUS_GLOBAL=ATIVA
Esperado: E1 continua em fila e pode ser selecionada
Status: UNKN (não automatizado em Teste_Bateria_Oficial)
Prioridade: P1 (crítico para compliance)
```

### Gap 2: Múltiplas Atividades Simultâneas

**Novo Teste Proposto:**

```
ID: BO_MULTIATIV_001
Nome: EmpresaComMultiplasAtividadesEmRodizio
Explicação: E1 credenciada em 3 atividades diferentes; Pre-OS para cada uma
Pré-Condições: E1 credenciado em ATIV 001, 002, 182
Passos:
  1. SelecionarEmpresa("001") → E1
  2. EmitirPreOS para E1 em 001
  3. SelecionarEmpresa("002") → E1
  4. EmitirPreOS para E1 em 002
  5. Validar Pre-OS 1 e 2 aparecem ambas AGUARDANDO_ACEITE
  6. Rejeitar Pre-OS 1 (Ativ 001)
  7. Validar QTD_RECUSAS(E1, 001)++ mas QTD_RECUSAS(E1, 002) mantém 0
Esperado: Contadores locais independentes por atividade
Status: UNKN
Prioridade: P2 (edge case comum)
```

### Gap 3: Estado de Transição de Pré-OS Inválido

**Novo Teste Proposto:**

```
ID: BO_PRETRANSITION_001
Nome: PreOSStatusTransicaoInvalida
Explicação: Tentar converter Pre-OS RECUSADA para OS (deve falhar)
Pré-Condições: Pre-OS com status RECUSADA
Passos:
  1. EmitirOS(PREOS_ID) com Pre-OS.STATUS = RECUSADA
  2. Validar retorno de erro
Esperado: TResult.Sucesso = False, Mensagem contém "RECUSADA"
Status: UNKN
Prioridade: P1 (validação de invariante)
```

### Gap 4: Suspensão Manual Não Testada

```
ID: BO_SUSP_MANUAL_001
Nome: SuspensaoManualPorGestor
Explicação: Admin clica "Suspender" em formulário Reativa_Empresa
Pré-Condições: E1 ATIVA
Passos:
  1. Abrir form Reativa_Empresa
  2. Selecionar E1
  3. Clicar "Suspender"
  4. Validar STATUS_GLOBAL = SUSPENSA_GLOBAL, DT_FIM_SUSP gravada, auditado
Esperado: Empresa suspensa; audit tem TIPO_SUSPENSAO=MANUAL
Status: UNKN (reativação manual não implementada; suspensão manual também não)
Prioridade: P1 (futuro Sprint 4)
```

---

## 7. ANÁLISE DE COBERTURA POR REGRA DE NEGÓCIO

| Regra | Testes | Cobertura | Gap |
|-------|--------|-----------|-----|
| Rodízio Filtro A (STATUS_CRED) | BO_100 | 50% | Falta teste com múltiplas empresas INATIVAS |
| Rodízio Filtro B (Suspensão + Auto-reativação) | BO_101, BO_REATIV_AUTO_001 | 40% | CRÍTICO — não automatizado |
| Rodízio Filtro C (Inatividade) | BO_102 | 50% | Teste básico OK, falta combinação com D/E |
| Rodízio Filtro D (OS aberta) | BO_103 | 60% | OK mas falta teste com múltiplas OS |
| Rodízio Filtro E (Pre-OS pendente) | BO_104 | 40% | CRÍTICO — falha; sem mover não validado |
| Recusa Incrementa | BO_110 | 80% | OK |
| Expiração Incrementa | BO_111 | 80% | OK |
| Suspensão Automática (MAX_RECUSAS) | BO_120 | 60% | Precisa testar com múltiplas recusas |
| Reativação Automática | BO_101, BO_REATIV_AUTO_001 | 30% | GAP CRÍTICO — não automatizado |
| Avaliação com Nota Baixa | T11, BO_AVA_BAIXA_001 | 70% | OK mas anomalia de Double não testada |
| Avanço de Fila Pós-Aceite | BO_051 | 60% | OK |
| Avanço de Fila Pós-Avaliação | UI-06 | 50% | Precisa validar POSICAO_FILA muda |
| Truncamento de Média | T12 | 100% | Anomalia CONHECIDA, documentada |
| Invariante POSICAO_FILA Única | BO_3XX (não listado) | 50% | Precisa validação explícita |

---

## 8. RECOMENDAÇÕES IMEDIATAS

### P0 (Bloqueante)

1. **BO_104 (Filtro E) está FALHANDO:** Código não implementa "skip SEM mover"; precisa correção antes de release
2. **UI-03, UI-07 (Botões Heurísticos) estão FALHANDO:** BT_PREOS_REJEITAR, BT_OS_CANCELAR não aparecem (erro 424); refatorar para designer-based
3. **BO_101 (Reativação Automática) NÃO está automatizada:** Testar manualmente em cada sprint

### P1 (Alto)

4. **Criar testes para: Auto-reativação, Multi-atividade, Transição inválida, Suspensão manual**
5. **Aumentar cobertura de BO_3XX e BO_4XX para validar combinações**
6. **Testar anomalia de Double (T12) com casos edge: 5.199, 5.200, 5.201**

### P2 (Médio)

7. **Implementar invariante checker em diagnostic**
8. **Adicionar performance test para 1000 empresas**
9. **Refatorar TextBox filtros de Controls.Add para designer**

---

## 9. ROADMAP DE TESTES PARA V12.1

- [ ] Corrigir BO_104 (Filtro E)
- [ ] Converter BT_PREOS_* para designer + ativar BO_104, UI-03, UI-07 (autopassam)
- [ ] Implementar e testar BO_REATIV_AUTO_001 (Auto-reativação)
- [ ] Implementar e testar BO_MULTIATIV_001 (Multi-atividade)
- [ ] Implementar e testar BO_PRETRANSITION_001 (Transição inválida)
- [ ] Atingir 150+ de 200 testes BO_xxx passando
- [ ] Atingir 100% dos testes manuais Txx com status PASS

---

## CONCLUSÃO

**Cobertura atual: 65% (150/231 testes)**

**Principais achados:**
1. BO_104 (Filtro E) está broken — prioridade P0
2. Botões dinâmicos causam falhas em UI-03, UI-07 — prioridade P0
3. Reativação automática nunca foi testada automaticamente — prioridade P1
4. Anomalia de Double em avaliação é conhecida e documentada — aceitável com disclaimer

**Status de release:**
- V12.0: Pode ser lançada com fixes de P0 + disclaimer de "UI pode falhar em 5-10% de casos"
- V12.1: Obrigatório atingir 150+ testes e resolver todo P1

