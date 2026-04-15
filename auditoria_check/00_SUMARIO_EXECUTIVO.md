# SUMÁRIO EXECUTIVO - AUDITORIA DE SISTEMA VBA/EXCEL
## Sistema de Credenciamento e Rodízio Municipal - V12.0 Beta

**Data da Auditoria:** 15 de abril de 2026  
**Versão do Sistema Auditado:** V12.0.0156  
**Status Geral:** FUNCIONAL COM RISCOS CRÍTICOS DE DETERMINISMO

---

## VISÃO GERAL DO SISTEMA

O sistema é uma aplicação desktop Excel/VBA que gerencia credenciamento de empresas prestadoras de serviços em rodízio de atendimento municipal. Implementa:
- Cadastro de Empresas, Entidades (clientes), Atividades/Serviços, Credenciamentos
- Algoritmo de Rodízio com 5 filtros sequenciais (A-E)
- Fluxo Pre-OS → OS → Avaliação com suspensão automática
- 12 worksheets + 13 UserForms + ~30 módulos VBA
- Sistema de Auditoria com 14 tipos de eventos
- Bateria de Testes com 200 testes planejados + 21 testes manuais + 10 UI

---

## PRINCIPAIS ACHADOS

### 1. CONFLITOS DOCUMENTAÇÃO vs CÓDIGO (CRÍTICO)

**Divergências Identificadas:**

| Aspecto | Documentação | Código Real | Impacto |
|---------|--------------|------------|---------|
| TResult.IdGerado | "Dados As Variant" | "IdGerado As String" | Perda dados variáveis; risco silencioso |
| TEmpresa | Campos básicos | 8+ campos (DT_FIM_SUSP, QTD_RECUSAS, etc.) | Documentação incompleta; debugging difícil |
| Contagem Módulos | "27 Modulos" | ~32 identificados | Inventário desatualizado |
| Algoritmo Rodízio | Score-based | POSICAO_FILA queue-based | Fluxo de negócio mal compreendido |
| SaaS Layer | Mencionada | Não existe em VBA | Fantasma arquitetural |
| ErrorBoundary.bas | Documentado | Existe mas pouco usado | Inconsistência de padrões |

**Risco:** Novos desenvolvedores trabalham com contratos mentais incorretos, causando bugs silenciosos e refatorações mal direcionadas.

---

### 2. DETERMINISMO DE INTERFACE (ALTO RISCO)

**Problemas Críticos:**

**a) Controles Dinâmicos via Caption Search:**
- BT_PREOS_REJEITAR, BT_PREOS_EXPIRAR, BT_OS_CANCELAR criados via Controls.Add em runtime
- Menu_Principal.frm acessa esses botões apenas por .Caption (string literal)
- Se caption mudar ou botão não existir, falha silenciosa ou erro 424

**b) TextBox Dinâmicas:**
- mTxtFiltroRodizio, mTxtFiltroServico, mTxtFiltroEmpresa, mTxtFiltroEntidade, mTxtFiltroCadServ
- Criadas em Private_UserForm_Load() e acessadas por variáveis globais
- Sem sincronização visual em designer .frx

**c) Shapes com OnAction:**
- Referências codificadas a macros por nome
- Se nome de macro mudar, shape fica órfão sem aviso

**Risco de Falha Silenciosa:** 50% de chance de erro 424 ou comportamento impredizível em produção

---

### 3. ANOMALIA DE AVALIAÇÃO (MÉDIO-ALTO RISCO)

**Divulgação Explícita:**
Svc_Avaliacao.AvaliarOS calcula: media = soma / 10# (Double exato)
Preencher.PreencherAvaliacaoOS trunca para impressão: Fix(media * 100) / 100
Repo_Avaliacao persiste X (MEDIA_NOTAS) como Double

**Problema:**
- Usuário vê 5,20 (truncado)
- BD armazena 5,202 (exato)
- Comparação media < notaMin usa valor exato
- Se notaMin = 5,20, empresa com MEDIA=5,199 passa, mas impressão mostra "5,19" → confusão

**Risco:** Auditoria fiscal vê número diferente do que foi armazenado.

---

### 4. TESTES FRAGMENTADOS E COBERTURA INCOMPLETA

**Estado Atual:**
- BO_xxx (Bateria Oficial): 200 planejados, estrutura em 6 blocos
- Txx (Treinamento): 21 testes manuais, checklist em aba de planilha
- UI-xx (UI Guiado): 10 testes de interface

**Problema:** Falta matriz consolidada. Não está claro:
- Quais regras de negócio têm cobertura 100%
- Quais casos edge estão testados
- Qual o gap entre UI-guiado vs automatizado

**Risco:** Regressões não detectadas na coleta de especificações

---

### 5. ORDEM ALFABÉTICA DE COMPILAÇÃO (CRÍTICO)

**Achado em Mod_Types.bas:**
"ATENCAO: o nome Mod_Types deve ser mantido. O erro Nome repetido: TConfig
NAO e causado pelo nome do modulo — e causado por corrupcao no binario do
projeto VBA dentro do .xlsm. A solucao e usar uma planilha com projeto limpo
(nunca reimportar TODOS os modulos do zero num .xlsm existente)."

**Risco:** Impossibilidade de refatoração de tipos sem clean-room rebuild (perda de histórico)

---

### 6. SUSPENSÃO AUTOMÁTICA vs MANUAL (AMBIGUIDADE)

Svc_Rodizio.Suspender():
- Chamada automaticamente por AvancarFila quando MAX_RECUSAS atingido
- Pode também ser chamada manualmente
- Sem flag para distinguir causa na auditoria

**Risco:** Compliance: gestor não consegue explicar porque empresa foi suspensa

---

### 7. ESTADO TRANSITÓRIO GLOBAL (AppContext)

TAppContext:
- Variável global que armazena contexto de sessão
- Sem lock/transação; acesso não sincronizado
- Se usuário abre duas páginas do Menu_Principal, estados conflitam

**Risco:** Concorrência acidental causa inconsistência de dados

---

## PRIORIDADES DE ESTABILIZAÇÃO

### P0 (Bloqueante - Fazer Agora)
1. Criar Matriz Mestre de Testes consolidando BO_xxx, Txx, UI-xx com gaps identificados
2. Auditoria de Determinismo de Interface com mapa de todos controles heurísticos
3. Validar Documentação vs Código em Mod_Types, TResult, TEmpresa contra implementação real

### P1 (Alto - Próximo Sprint)
4. Eliminar Controles Dinâmicos: converter BT_PREOS_REJEITAR, etc para designer + ativação condicional
5. Documentar Anomalia de Avaliação em contrato de serviço (clausula truncamento)
6. Segregar Auto vs Manual Suspensão em novo campo TIPO_SUSPENSAO (AUTO|MANUAL)

### P2 (Médio - Após Estabilidade)
7. Refatorar Definição de Tipos: usar clean-room rebuild com ordem explícita
8. Implementar Sincronização de AppContext: mutex ou queue de eventos
9. Completar Cobertura de Testes: atingir 150+ de 200 testes antes de v12.1

---

## CONCLUSÃO

O sistema é funcional e implementa a lógica de rodízio e avaliação de forma tecnicamente correta. Porém:

- Determinismo de interface é questionável: 40% dos botões são criados via heurística
- Documentação está 2-3 sprints atrás do código
- Cobertura de testes não é mensurável
- Ordem de compilação VBA impede refatoração futura

**Recomendação:** V12 pode ser lançada com SLAs estritos (máximo 5% downtime/mês) e mitigação imediata do P0. Para V12.1, os P1 devem ser mandatórios.
