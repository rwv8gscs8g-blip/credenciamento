# PADRONIZAÇÃO DO TREINAMENTO E EXECUÇÃO ASSISTIDA
Diagnóstico do Estado Atual e Proposta de Interface Unificada

## 1. DIAGNÓSTICO: ESTADO ATUAL DE FLUXOS DE TESTE

### 1.1 Inventário de Módulos de Teste

**MÓDULO 1: Teste_Bateria_Oficial.bas (OFICIAL)**
- Propósito: Bateria autom amatizada de ~200 testes
- Organizacao: 6 blocos (Bloco0-Bloco5)
- Execução: RunBateriaOficial() → InputBox menu
- Modo Visual: BA_SetModoExecucaoVisual(True/False) → gDelayVisualMs (0 ou 1800ms)
- Saída: Teste_Bateria_Oficial sheet com BO_001, BO_002, ... resultados
- Característica: Determinístico, repetível, sem intervenção
- Tempo: 20-30 min (visual), 2-3 min (fast)
- Cobertura: Combinatorial, regressão, edge cases

**MÓDULO 2: Central_Testes.bas (LEGADO)**
- Propósito: Menu central interativo (6 opções)
- Execução: CT_AbrirCentral() → InputBox com menu 1-6
- Opções:
  - 1: Teste rápido (16 passos manual)
  - 2: Teste UI guiado (10 passos)
  - 3: Treinamento painel (21 questões)
  - 4: Bateria oficial (delegá a Teste_Bateria_Oficial)
  - 5: Relatório consolidado
  - 6: Sair
- Saída: Múltiplas sheets (RPT_ROTEIRO, TESTE_UI, TREINAMENTO_RESULTADOS, etc.)
- Característica: Menu-driven, mistura automated e manual
- Status: "Central de Testes", ponto de entrada histórico

**MÓDULO 3: Treinamento_Painel.bas (MANUAL)**
- Propósito: Teste de conhecimento com 21 questões (T01-T21)
- Execução: Cria sheet TREINAMENTO_RESULTADOS
- Questões: SIM/NAO/PENDENTE dropdowns
- Cobertura: Cadastro, rotação, Pre-OS, OS, avaliação, impressão, relatórios, compilação
- Saída: Sheet com questões, espaço para respostas, espaço para observações
- Característica: Manual, baseado em checkbox, orientado para treinamento humano
- Interatividade: Nenhuma (sheet estática, usuário preenche)

**MÓDULO 4: Teste_UI_Guiado.bas (ASSISTIDO)**
- Propósito: 10 testes de UI (UI-01 a UI-10)
- Execução: Cria sheet TESTE_UI
- Testes: Clic em botões, preenchimento de forms, navegação
- Saída: Sheet TESTE_UI com steps, checkboxes, coluna de observações
- Característica: Instruções passo-a-passo, manual click-through
- Interatividade: Guiado (roteiro em sheet, usuário executa)
- Cobertura: Forms, lists, buttons, navigation

**MÓDULO 5: Central_Testes_Relatorio.bas (RELATÓRIO)**
- Propósito: Gerar relatórios pós-testes
- Execução: Central_Testes_Relatorio.ExportarRelatorios() ou desde Central_Testes opção 5
- Saída: Múltiplas sheets
  - RPT_ROTEIRO: Relatório do roteiro rápido
  - RPT_BATERIA: Resultado agregado da bateria oficial (by block, por classe)
  - RPT_CK136: Cobertura combinatorial (matriz de combinações testadas)
  - RPT_CONSOLIDADO: Visão geral (total testes, taxa de sucesso)
  - CSV export: Resultado_Testes.csv (formato universal)
- Característica: Pós-processamento, agregação de resultados
- Interatividade: Nenhuma (automático)

### 1.2 Matriz de Características

| Módulo | Tipo | Automatizado | Interação | Determinístico | Cobertura | Escalabilidade |
|--------|------|--------------|-----------|-----------------|-----------|-----------------|
| Teste_Bateria_Oficial | Core | Sim (100%) | Nenhuma (input menu start) | Sim | ~89% | Excelente |
| Central_Testes | Orquestrador | Parcial (menu) | Menu InputBox | Parcial | Delegada | Boa |
| Treinamento_Painel | Manual | Não | Sheet manual | Não | Educacional | Limitada |
| Teste_UI_Guiado | Assistido | Não | Guia + manual | Não | UI apenas | Limitada |
| Central_Testes_Relatorio | Relatório | Sim (100%) | Nenhuma | Sim | Agregado | Excelente |

## 2. PROBLEMAS IDENTIFICADOS

### 2.1 Falta de Unificação

**Problema U1: Múltiplos Entry Points**
- Usuário não sabe por onde começar: Central_Testes? Teste_Bateria_Oficial direto? Treinamento_Painel?
- Cada módulo tem convenção diferente (InputBox vs Sheet vs Menu)
- Documentação dispersa, sem fluxo claro

**Problema U2: Inconsistência de Nomeclatura**
- Teste_Bateria: BO_001, BO_012, ... (prefixo BO)
- Teste_UI: UI-01, UI-10 (prefixo UI, hífen)
- Treinamento: T01, T21 (prefixo T)
- Sem convenção global, busca dificultada

**Problema U3: Modo Visual Desacoplado**
- gDelayVisualMs é variável global em Teste_Bateria_Oficial
- Usuário deve lembrar de mudar (0 vs 1800) antes de executar
- Sem opção dinâmica dentro da interface

### 2.2 Falta de Forma de Execução Assistida Padrão

**Problema A1: Execução Rápida vs Lenta sem Opção de UI**
- Teste_Bateria roda automaticamente ou com delay visual
- Nenhuma progressão visual em tempo real (sem live progress bar)
- Usuário não sabe qual teste falhou até fim da bateria

**Problema A2: Sem Narrativa Humana**
- Testes não explicam POR QUE falham (só resultado PASS/FAIL)
- Erro 137 em BO_012 não diz "Filter A bloqueou empresa por STATUS_CRED != ATIVO"
- Usuário técnico confuso, não-técnico perdido

**Problema A3: Modo Híbrido Não Existe**
- Não há "execute tests, pausar na falha, explicar, continuar"
- Não há "execute os 5 testes do Bloco1, mostra resultados, aguarda confirmação"
- Nem fast nem slow, nada no meio

### 2.3 Saída Fragmentada

**Problema O1: Múltiplas Sheets sem Conexão**
- Teste_Bateria_Oficial sheet: BO_XXX resultados
- RPT_BATERIA: Agregado por block
- RPT_CK136: Matriz combinatorial
- Sem índice unificado ("clique em BO_012 para ver detalhes em RPT_BATERIA")

**Problema O2: CSV Export Inconsistente**
- Central_Testes_Relatorio exporta CSV sem row headers
- Formato não-standard, difícil de re-importar
- Sem versionamento de resultado (data/hora missing)

**Problema O3: Sem Rastreamento de Mudanças**
- Resultado_Testes.csv não tem timestamp
- Impossível saber se bateria foi executada hoje ou há 2 meses
- Sem comparação entre runs consecutivos

### 2.4 Falta de Escalabilidade em Assistência

**Problema S1: Sem Opção de Seleção de Subset**
- Usuário não pode rodar "apenas Bloco1" sem editar código
- Não há filtro por tipo de teste (rotation, evaluation, etc.)
- Para adicionar 5 testes novos, requer mudança em Teste_Bateria_Oficial.bas

**Problema S2: Sem Histórico de Testes**
- Cada bateria overwrite resultado anterior
- Impossível comparar "14 testes falhavam antes, agora 2"
- Sem rollback ou snapshot

**Problema S3: Documentação de Teste Desacoplada**
- BO_012 não tem explicação em sheet (só código comentado)
- Teste_UI_Guiado sheet tem instruções, mas não linká a código
- Sem "veja Svc_Rodizio.SelecionarEmpresa" para referência

## 3. PROPOSTA DE PADRONIZAÇÃO: CENTRAL DE TESTES UNIFICADA (V2)

### 3.1 Modelo Arquitetural

```
┌─────────────────────────────────────────────────────────────────┐
│                    CENTRAL_TESTES_V2 (NOVO)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [ENTRADA UNIFICADA]                                            │
│    MenuPrincipal() → InputBox com opções padronizadas           │
│                                                                  │
│    Opção 1: Executar Bateria Oficial                           │
│       ├─ Todas as opções abaixo                                │
│       └─ Retorna resumo                                        │
│                                                                  │
│    Opção 2: Executar Subset (por Bloco, Tipo, Palavra-chave)   │
│       ├─ Seleciona Bloco 0-5 ou ranges BO_012:BO_020           │
│       └─ Executa subset, retorna resumo                        │
│                                                                  │
│    Opção 3: Modo Assistido (Passo-a-Passo com Pausa)           │
│       ├─ Executa 5 testes de cada vez                          │
│       ├─ Mostra resultado (PASS/FAIL/SKIP com explicação)      │
│       ├─ Pausa, aguarda Enter                                  │
│       └─ Continua próximos 5                                   │
│                                                                  │
│    Opção 4: Treinamento Interativo                             │
│       ├─ Abre sheet TREINAMENTO_V2 com instruções              │
│       └─ Guia passo-a-passo (T01-T21)                          │
│                                                                  │
│    Opção 5: Teste UI Guiado (Sheet + Instruções)               │
│       ├─ Abre sheet UI_GUIDE_V2                               │
│       └─ Passo-a-passo clicável (UI-01 a UI-10)               │
│                                                                  │
│    Opção 6: Ver Histórico de Resultados                        │
│       ├─ Lista runs anteriores (data, # testes, taxa sucesso)  │
│       └─ Seleciona um para ver detalhes                        │
│                                                                  │
│    Opção 7: Exportar Relatório                                 │
│       ├─ Formato: Sheets ou CSV ou PDF                         │
│       └─ Inclui timestamp, metadata                            │
│                                                                  │
│    Opção 8: Sair                                               │
│                                                                  │
│  [CONFIGURAÇÃO GLOBAL]                                         │
│    Modo de Execução: Fast (0ms), Normal (500ms), Slow (1800ms) │
│    Verbosidade: Silent, Normal, Verbose                        │
│    Auto-Reset: Sim/Não (reset database antes de rodar)         │
│                                                                  │
│  [OUTPUT UNIFICADO]                                            │
│    Sheet: BATERIA_RESULTADO_V2 (resultado estruturado)         │
│    Sheet: HISTORICO_BATERIA (log de todos os runs)            │
│    CSV: Resultado_Testes_YYYYMMDD_HHMMSS.csv (com timestamp)  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Estrutura de Output: BATERIA_RESULTADO_V2 Sheet

```
┌──────────────────────────────────────────────────────────────────────────────────────┐
│ CENTRAL DE TESTES - RESULTADO EXECUTADO EM 15-04-2026 14:30:00                      │
├──────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│ RESUMO EXECUTIVO                                                                    │
│ ═════════════════                                                                   │
│ Modo Execução: Assistido (5 testes por grupo)                    │ 7/7             │
│ Total de Testes: 45 de 200 (Bloco 1-2)                          │ Taxa Sucesso    │
│ Testes Passando: 42                                              │ 93.3%           │
│ Testes Falhando: 3                                               │ Falhas          │
│ Tempo Total: 12:35 (mm:ss)                                      │ 3               │
│                                                                  │                 │
│ RESULTADOS DETALHADOS                                                              │
│ ════════════════════                                                                │
│                                                                  │                 │
│ ID_TESTE │ BLOCO │ CLASSE           │ RESULTADO │ TEMPO  │ OBSERVAÇÃO             │
│──────────┼───────┼──────────────────┼───────────┼────────┼───────────────────────  │
│ BO_010   │ 1     │ Setup            │ PASS      │ 0.5s   │ Database reset OK       │
│ BO_011   │ 1     │ Setup            │ PASS      │ 0.2s   │ Master data loaded      │
│ BO_012   │ 1     │ Rodicio - Filter A│ PASS      │ 1.2s   │ Bloqueio STATUS inativo │
│ BO_013   │ 1     │ Rodicio - Filter B│ PASS      │ 0.9s   │ Reativação automática   │
│ BO_014   │ 1     │ Rodicio - Filter C│ PASS      │ 0.7s   │ Skip suspensão ativa    │
│ BO_015   │ 1     │ Rodicio - Filter D│ PASS      │ 1.1s   │ MoverFinal sem punição  │
│ BO_016   │ 1     │ Rodicio - Filter E│ FAIL      │ 1.5s   │ *** VER DETALHES ABAIXO │
│ BO_017   │ 1     │ Eleição          │ PASS      │ 0.8s   │ Pre-OS criada OK        │
│ BO_018   │ 1     │ Pre-OS           │ PASS      │ 1.3s   │ Status AGUARDANDO_ACEITE│
│ BO_019   │ 1     │ Pre-OS-Aceite    │ PASS      │ 0.9s   │ Pre-OS aceita OK        │
│ BO_020   │ 1     │ Pre-OS-Recusa    │ FAIL      │ 1.2s   │ *** VER DETALHES ABAIXO │
│                   ... (mais 35 testes)                                              │
│                                                                  │                 │
│ FALHAS DETECTADAS                                                                   │
│ ═══════════════════                                                                 │
│                                                                  │                 │
│ FALHA 1: BO_016 (Rodicio - Filter E)                                               │
│   Erro: "AssertionError: Expected QTD_RECUSAS=0 but got 1"                        │
│   Contexto: Empresa com Pre-OS pendente, Filter E deveria skipar sem incrementar    │
│   Linha de Código: Svc_Rodizio.bas linha 145                                       │
│   Raiz Provável: IncrementarRecusa() chamado quando não deveria                   │
│   Ação Recomendada: Revisar lógica Filter E em SelecionarEmpresa()                │
│   Teste Relacionado: BO_032 (cross-validação)                                     │
│                                                                  │                 │
│ FALHA 2: BO_020 (Pre-OS-Recusa)                                                     │
│   Erro: "AssertionError: DT_VALIDADE não encontrada em PREOS"                      │
│   Contexto: Criação de Pre-OS, data de validade não persistida                     │
│   Linha de Código: Repo_PreOS.bas linha 78                                         │
│   Raiz Provável: Coluna CAD_PREOS![DT_VALIDADE] não preenchida                    │
│   Ação Recomendada: Adicionar assignment em Svc_PreOS.CriarPreOS()                │
│   Teste Relacionado: BO_025, BO_030                                               │
│                                                                  │                 │
│ FALHA 3: BO_055 (Bloqueio Múltiplo)                                                 │
│   Erro: "AssertionError: Rotacao não pulou empresa conforme esperado"              │
│   Contexto: 2 empresas com STATUS_GLOBAL=INATIVA, ambas deveriam ser skipped       │
│   Linha de Código: Svc_Rodizio.bas linha 89                                        │
│   Raiz Provável: Loop não continua corretamente após skip                          │
│   Ação Recomendada: Revisar lógica de continuação em SelecionarEmpresa()          │
│   Teste Relacionado: BO_010, BO_012                                               │
│                                                                  │                 │
│ PRÓXIMOS PASSOS                                                                    │
│ ════════════════                                                                   │
│ 1. Corrigir BO_016: Revisar lógica Filter E, adicionar condição de proteção      │
│ 2. Corrigir BO_020: Adicionar DT_VALIDADE em CriarPreOS                          │
│ 3. Corrigir BO_055: Debug SelecionarEmpresa loop                                  │
│ 4. Re-executar Bloco 1 (10 testes)                                                │
│ 5. Se tudo PASS, executar Bloco 2 (50 testes)                                     │
│                                                                  │                 │
│ VERSÃO DO SISTEMA                                                                  │
│ ═════════════════                                                                 │
│ Excel: 16.88.1 (Microsoft 365)                                  │                 │
│ VBA: Version 7.1                                                │                 │
│ Build: PlanilhaCredenciamento-Homologacao v12.146              │                 │
│ Data de Execução: 15-04-2026 14:30:00.123                       │                 │
│ Duração: 12:35 mm:ss                                           │                 │
│ Usuário: AutoTest                                              │                 │
│                                                                  │                 │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

### 3.3 Estrutura de Output: HISTORICO_BATERIA Sheet

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ HISTÓRICO DE EXECUÇÕES DE TESTES                                               │
├─────────────────────────────────────────────────────────────────────────────────┤
│ Data/Hora              │ Bloco │ # Testes │ # Pass │ # Fail │ Taxa   │ Arquivo │
│────────────────────────┼───────┼──────────┼────────┼────────┼────────┼─────────│
│ 15-04-2026 14:30:00    │ 1-2   │ 45       │ 42     │ 3      │ 93.3%  │ RES_... │
│ 15-04-2026 10:15:00    │ 0-5   │ 200      │ 197    │ 3      │ 98.5%  │ RES_... │
│ 14-04-2026 23:45:00    │ 1     │ 30       │ 30     │ 0      │ 100%   │ RES_... │
│ 14-04-2026 20:20:00    │ 3-4   │ 100      │ 98     │ 2      │ 98.0%  │ RES_... │
│ 13-04-2026 15:30:00    │ 0-5   │ 200      │ 195    │ 5      │ 97.5%  │ RES_... │
│                        │       │          │        │        │        │         │
│ (clique em row para ver detalhes completos)                                    │
│                                                                                │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 3.4 Interface InputBox Unificada

```
┌─────────────────────────────────────────────────────────────┐
│     CENTRAL DE TESTES - SISTEMA DE CREDENCIAMENTO          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Escolha uma opção:                                          │
│                                                             │
│ 1 - Executar Bateria Oficial Completa (Bloco 0-5, 200 t.)  │
│ 2 - Executar Subset de Testes (selecione bloco/range)      │
│ 3 - Modo Assistido (Passo-a-Passo, 5 testes/pausa)         │
│ 4 - Treinamento Interativo (T01-T21)                       │
│ 5 - Teste UI Guiado (UI-01-UI-10)                          │
│ 6 - Ver Histórico de Resultados                            │
│ 7 - Exportar Relatório (Sheets/CSV/PDF)                    │
│ 8 - Configurações (Modo, Verbosidade, Reset)               │
│ 9 - Sair                                                   │
│                                                             │
│ Sua escolha: [_]                                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3.5 Interface Modo Assistido (Em Tempo Real)

```
┌──────────────────────────────────────────────────────────────────┐
│  MODO ASSISTIDO - GRUPO 1 DE 9 (Bloco 1, testes 1-5)             │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│ Executando: BO_010 (Setup - Database Reset)                     │
│   Status: [████████████████████░░░░░░░░░░░░░] 50% completo      │
│   Tempo Decorrido: 5.2s / Estimado Total: 12:35                │
│                                                                  │
│ RESULTADO: BO_010 = PASS                                         │
│   Descrição: Database reset realizado com sucesso               │
│   Detalhes: 0 erros, 25 registros limpsos                       │
│                                                                  │
│ ─────────────────────────────────────────────────────────────   │
│ Próximo teste: BO_011 (Setup - Master Data)                     │
│                                                                  │
│ Deseja continuar? [SIM] [NÃO] [PRÓXIMO GRUPO]                   │
│                                                                  │
│ (Se NÃO: pode parar aqui, retorna resumo)                       │
│ (Se PRÓXIMO GRUPO: pula para próximos 5 testes)                │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## 4. ESPECIFICAÇÕES FUNCIONAIS DETALHADAS

### 4.1 Função Principal: MenuPrincipal()

**Entrada:** Nenhuma (usuário escolhe via InputBox)
**Saída:** Executa subrotina correspondente

```
Pseudo-Código:
Function MenuPrincipal()
  Do
    opcao = InputBox("Escolha opção (1-9):")
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
End Function
```

### 4.2 Função: ExecutarBateriaCompleta()

**Entrada:** Modo global (Fast/Normal/Slow), Auto-Reset (Sim/Não)
**Saída:**
- Sheet BATERIA_RESULTADO_V2 preenchida
- Sheet HISTORICO_BATERIA atualizado
- CSV exportado automaticamente

**Fluxo:**
1. Perguntar: "Auto-reset database antes de rodar?" (padrão Sim)
2. Se Sim: ResetDatabase()
3. Chamar Teste_Bateria_Oficial.RunBateriaOficial() com modo atual
4. Coletar resultados de Teste_Bateria_Oficial sheet
5. Preencher BATERIA_RESULTADO_V2 com formatação padrão
6. Adicionar linha em HISTORICO_BATERIA
7. Exportar CSV com timestamp
8. Mostrar resumo (# pass, # fail, taxa sucesso, tempo total)

### 4.3 Função: ModoAssistido()

**Entrada:** Modo global, Tamanho de grupo (padrão 5 testes), Bloco (padrão 1-5)
**Saída:** BATERIA_RESULTADO_V2 sheet preenchida incrementalmente

**Fluxo:**
1. Determinar testes a executar (padrão: BO_010 até BO_199)
2. Particionar em grupos de 5
3. Para cada grupo:
   a. Mostrar "Próximo grupo: BO_X até BO_Y" com progresso visual
   b. Executar 5 testes (chamando Teste_Bateria_Oficial.ExecutarTesteUnico(ID) para cada)
   c. Mostrar resultado: PASS/FAIL com explicação de 1 linha
   d. Pausa: "Pressione Enter para continuar ou X para parar"
   e. Se usuário pede parada, quebra loop e retorna resumo parcial
4. Após todo grupo completar, mostrar opção: "Próximo grupo?" ou "Gerar relatório?"

**Behavior Esperado:**
- Vivacidade: Usuário vê progresso em tempo real, não aguarda fim de 200 testes
- Interrupção: Pode parar no meio sem perder resultado parcial
- Explicação: Cada falha mostrada com "Linha de código", "Raiz provável", "Ação recomendada"

### 4.4 Função: TreinamentoInterativo()

**Entrada:** Nenhuma
**Saída:** Sheet TREINAMENTO_V2 com questões (T01-T21) e instruções

**Layout TREINAMENTO_V2:**
```
Coluna A: ID_QUESTAO (T01, T02, ..., T21)
Coluna B: ENUNCIADO (descrição da questão)
Coluna C: RESPOSTA (dropdown: SIM / NÃO / PENDENTE / ?)
Coluna D: OBSERVAÇÃO (espaço para notas)
Coluna E: LINK_CÓDIGO (referência: "Ver Svc_Rodizio.bas:145")
Coluna F: STATUS_VALIDACAO (automático: CORRETO / INCORRETO / PENDENTE)
```

**Fluxo:**
1. Criar sheet TREINAMENTO_V2 se não existir
2. Preencher questões (T01-T21) com enunciados em português
3. Abrir sheet
4. Usuário preenche RESPOSTA + OBSERVAÇÃO
5. Função ValidarTreinamento() lê respostas e marca STATUS_VALIDACAO
6. Gerar resumo: "X corretas de 21, Y incorretas, Z pendentes"

### 4.5 Função: TesteUIGuiado()

**Entrada:** Nenhuma
**Saída:** Sheet UI_GUIDE_V2 com steps e instruções

**Layout UI_GUIDE_V2:**
```
Coluna A: ID_TESTE (UI-01, ..., UI-10)
Coluna B: INSTRUÇÃO (passo a passo em português)
Coluna C: ELEMENTO (referência visual: "Clique no botão 'Rodicio'" ou "Preencha campo A5")
Coluna D: EXPECTED_RESULT (resultado esperado após click: "Sheet 'Rodicio' aberta" ou "Pre-OS criada")
Coluna E: RESULTADO_REAL (preenchido manualmente pelo usuário: OK / ERRO / N/A)
Coluna F: OBSERVAÇÃO (espaço para notas se erro)
```

**Fluxo:**
1. Criar sheet UI_GUIDE_V2 se não existir
2. Preencher steps UI-01-UI-10
3. Abrir sheet e posicionar em linha 1
4. Usuário segue instruções
5. Após cada passo, marca RESULTADO_REAL
6. Ao final, função ValidarTesteUI() lê coluna E e conta OKs
7. Gerar resumo: "X steps OK de 10, Y erros"

## 5. CONFIGURAÇÃO GLOBAL E PERSISTÊNCIA

### 5.1 Sheet CONFIG_TESTES (novo)

```
SETTING                          │ VALOR_ATUAL │ VALORES_PERMITIDOS       │
─────────────────────────────────┼─────────────┼──────────────────────────│
MODO_EXECUCAO                    │ Normal      │ Fast (0), Normal (500), Slow (1800) │
VERBOSIDADE                      │ Normal      │ Silent, Normal, Verbose  │
AUTO_RESET_DATABASE              │ Sim         │ Sim, Não                 │
TAMANHO_GRUPO_ASSISTIDO          │ 5           │ 1-20                     │
BLOCO_PADRAO                     │ 1-5         │ 0-5, ranges, all         │
EXPORT_FORMATO                   │ Sheets      │ Sheets, CSV, PDF, All    │
INCLUDE_HISTORICO                │ Sim         │ Sim, Não                 │
TIMESTAMPOUTPUT                  │ Sim         │ Sim, Não                 │
PASTA_EXPORT_CSV                 │ .            │ /output/, ./results/, ... │
IDIOMA                           │ PT-BR       │ PT-BR, EN, ES            │
```

## 6. CRONOGRAMA DE IMPLEMENTAÇÃO

### Fase 1 (Semana 1): Estrutura Base
- Criar Central_Testes_V2.bas com MenuPrincipal()
- Criar sheet BATERIA_RESULTADO_V2 e HISTORICO_BATERIA
- Implementar ExecutarBateriaCompleta()

### Fase 2 (Semana 2): Modo Assistido
- Implementar ModoAssistido() com lógica de grupo
- Adicionar pausas e input de usuário
- Testar com Bloco 1 (30 testes)

### Fase 3 (Semana 3): Treinamento + UI
- Implementar TreinamentoInterativo() e TesteUIGuiado()
- Adicionar sheets TREINAMENTO_V2 e UI_GUIDE_V2
- Adicionar validação automática

### Fase 4 (Semana 4): Polimento e Histórico
- Implementar VerHistorico() com busca de runs anteriores
- Adicionar funcionalidade de comparação entre runs
- Implementar ExportarRelatorio() multi-formato
- Testes de integração e usabilidade

**Esforço Total:** ~60 horas (2 devs, 2 semanas, ou 1 dev, 4 semanas)

## 7. CONCLUSÃO E RECOMENDAÇÃO

**Estado Atual:** Fragmentado, múltiplos entry points, sem narrativa unificada
**Proposta:** Central_Testes_V2 como orquestrador único, com suporte a:
- Execução automatizada completa
- Modo assistido passo-a-passo
- Treinamento interativo
- UI guiado com instruções
- Histórico e comparação de runs
- Exportação multi-formato

**Benefício:** Usuários (técnicos e não-técnicos) têm fluxo claro, documentado, reproduzível.

**Risco:** Implementação requer ~60 horas. Recomendação: Fazer ao longo de 1 mês, não bloqueia uso atual.

**Prioridade:** Alta (melhora significativamente experiência de testes e treinamento)
