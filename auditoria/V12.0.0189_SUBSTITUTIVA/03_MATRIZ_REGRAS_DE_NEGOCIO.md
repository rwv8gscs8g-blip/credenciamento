# 03. Matriz de Regras de Negócio — V12.0.0189

Este documento inventaria as regras de negócio do sistema de credenciamento, marca onde cada uma vive **no código atual** e onde **deveria viver** segundo a arquitetura em camadas (UI → Serviço → Repositório → Dados). Regras em itálico são **inferidas** a partir do comportamento da UI; regras em texto normal foram lidas diretamente do código.

Legenda da coluna "Local atual":
- `SVC` — implementada no `Svc_*` correspondente (correto).
- `UI` — implementada na `Menu_Principal.frm` (lacuna).
- `REPO` — implementada no `Repo_*` correspondente.
- `DATA` — restrição imposta pela planilha (ex: validação de célula).
- `MIX` — partes em locais diferentes.

---

## 1. Empresa (cadastro, alteração, status global)

| # | Regra | Local atual | Local correto | Evidência |
|---|-------|-------------|---------------|-----------|
| E1 | `CNPJ` único na aba `EMPRESAS` | SVC | SVC | `Svc_Empresa.bas` (ou equivalente) + `Repo_Empresa` |
| E2 | `STATUS_GLOBAL` ∈ {ATIVA, SUSPENSA, INATIVA} | SVC | SVC | `Const_Colunas.bas`, `Svc_Rodizio.bas` |
| E3 | Reativação de empresa inativa volta status para ATIVA e limpa data de fim de suspensão | SVC | SVC | `Svc_Empresa.Reativa_Empresa` (e handler UI `B_Reativa_Empresa`) |
| E4 | Não pode haver linhas duplicadas em `ENTIDADE_INATIVOS` quando reativada (removidas todas) | SVC | SVC | `releases/V12.0.0179.md` |
| E5 | `DT_FIM_SUSPENSAO` > hoje → empresa permanece suspensa para rodízio | SVC | SVC | `Svc_Rodizio.bas` filtro B |
| E6 | `QTD_RECUSAS` atinge `COL_CFG_MAX_RECUSAS` → suspende | SVC | SVC | `Svc_Rodizio.IncrementarRecusa` |
| E7 | Duração da suspensão em meses = `COL_CFG_MESES_SUSPENSAO` | SVC | SVC | `Svc_Rodizio.Suspender` |
| E8 | *Filtro de busca inclui CNPJ, razão, contato, telefone fixo e celular* | UI | UI | `Menu_Principal.frm` (`TxtFiltro_Entidade`) — UI-only por ser UX |

**Comentário:** regras de domínio de empresa estão corretamente no serviço. O filtro de busca fica na UI por ser lógica de exibição, não de negócio.

---

## 2. Entidade (cadastro, filtros, reativação)

| # | Regra | Local atual | Local correto | Evidência |
|---|-------|-------------|---------------|-----------|
| N1 | `ID` de entidade único | SVC | SVC | `Repo_Entidade` via `ProximoId` |
| N2 | Entidade inativa vai para `ENTIDADE_INATIVOS` e é removida de `ENTIDADE` | SVC | SVC | `Svc_Entidade` + `releases/V12.0.0179.md` |
| N3 | Reativação exige `ID` ou `CNPJ` | SVC | SVC | `releases/V12.0.0179.md` |
| N4 | *Filtro `TxtFiltro_Entidade` cobre ID, CNPJ, nome, telefones, contato1* | UI | UI | `Menu_Principal.frm` (V178 incluiu `COL_ENT_TEL_CEL`) |

---

## 3. Credenciamento (empresa × atividade)

| # | Regra | Local atual | Local correto | Evidência |
|---|-------|-------------|---------------|-----------|
| C1 | Chave composta `(EMP_ID, ATIV_ID)` única | SVC | SVC | `Repo_Credenciamento` |
| C2 | `STATUS` ∈ {ATIVO, SUSPENSO, INATIVO} | SVC | SVC | `Const_Colunas.bas` |
| C3 | `POSICAO_FILA` = `Max(POSICAO_FILA in ATIV) + 1` ao credenciar | SVC | SVC | `Svc_Rodizio.AvancarFila` / `TV2_CredenciarAtividade` |
| C4 | Ordem relativa da fila é preservada; `POSICAO_FILA` **cresce**, não renumera | SVC | SVC | `releases/V12.0.0189.md`, `Svc_Rodizio.bas` |
| C5 | `RECUSAS` ≥ `MAX_RECUSAS` → status passa para SUSPENSO | SVC | SVC | `Svc_Rodizio.IncrementarRecusa` |
| C6 | Inativação manual marca `INATIVO_FLAG` e move fila | SVC | SVC | `Svc_Rodizio` |

---

## 4. Pré-OS

| # | Regra | Local atual | Local correto | Evidência |
|---|-------|-------------|---------------|-----------|
| P1 | `PREOS_ID` único | SVC | SVC | `Repo_PreOS` + `ProximoId` |
| P2 | Avança fila **antes** de gravar Pré-OS | SVC | SVC | `Svc_PreOS.EmitirPreOS` |
| P3 | Seleção de empresa usa os 5 filtros A–E | SVC | SVC | `Svc_Rodizio.SelecionarEmpresa` |
| P4 | Expiração: prazo em dias = `COL_CFG_PRAZO_PREOS` | SVC | SVC | `Svc_PreOS.ExpirarPreOS` |
| P5 | Recusa: incrementa contador e suspende se atingir máximo | SVC | SVC | `Svc_PreOS.RecusarPreOS` + `Svc_Rodizio.IncrementarRecusa` |
| **P6** | **`ENT_ID` existe e está ativo** | **UI** | **SVC** | `Menu_Principal.frm` valida; `Svc_PreOS.bas` aceita sem checar. **MIG_001** |
| **P7** | **`QT_ESTIMADA > 0`** | **UI** | **SVC** | `Menu_Principal.frm` valida; `Svc_PreOS.bas` aceita 0/negativo. **MIG_001 (extensão)** |

---

## 5. OS

| # | Regra | Local atual | Local correto | Evidência |
|---|-------|-------------|---------------|-----------|
| O1 | `OS_ID` único | SVC | SVC | `Repo_OS` + `ProximoId` |
| O2 | `PREOS_ID` referenciado deve existir e estar em estado compatível | SVC | SVC | `Svc_OS.EmitirOS` |
| O3 | Cancelamento libera a empresa da OS | SVC | SVC | `Svc_OS.CancelarOS` |
| **O4** | **`DT_PREV_TERMINO >= DT_EMISSAO`** | **UI** | **SVC** | `Menu_Principal.frm` valida; `Svc_OS.bas` aceita data anterior. **MIG_002** |
| O5 | *`DT_EMISSAO` = hoje (não pode ser futura)* | UI | SVC | inferido pela UX |

---

## 6. Avaliação

| # | Regra | Local atual | Local correto | Evidência |
|---|-------|-------------|---------------|-----------|
| A1 | `NOTA` ∈ [0, 10] com casas decimais | SVC | SVC | `Svc_Avaliacao.bas` |
| A2 | `NOTA < COL_CFG_NOTA_MINIMA` incrementa contador de recusas da empresa | SVC | SVC | `Svc_Avaliacao.bas` |
| A3 | Média impressa sem arredondamento (mantém 2 casas) | SVC | SVC | `releases/V12.0.0165.md` |
| **A4** | **Se `QT_EXECUTADA <> QT_ESTIMADA`, exige texto em `JUSTIFICATIVA`** | **UI** | **SVC** | `Menu_Principal.frm` valida; `Svc_Avaliacao.bas` aceita vazio. **MIG_003** |
| A5 | Avaliação fecha a OS, atualizando `STATUS_OS` = FECHADA | SVC | SVC | `Svc_Avaliacao.bas` |

---

## 7. CNAE / Atividades / Serviços

| # | Regra | Local atual | Local correto | Evidência |
|---|-------|-------------|---------------|-----------|
| T1 | `ATIV_ID` numérico único | SVC | SVC | `Repo_Atividade` |
| T2 | Descrição da atividade sincroniza com `CAD_SERV` quando alterada | SVC | SVC | `SincronizarDescricoesCadServComAtividades` |
| T3 | Import inicial carrega 612 atividades | SVC | SVC | `ImportarCNAE_Emergencia` |
| T4 | `AtividadeJaExiste` usa busca linear (O(n)) | SVC | SVC | código + `ESTADO-ATUAL.md` seção Riscos |
| T5 | `CAD_SERV` suporta edição/alteração de dados | SVC | SVC | `releases/V12.0.0141.md` |

---

## 8. Rodízio (seleção da empresa)

| # | Regra | Local atual | Local correto | Evidência |
|---|-------|-------------|---------------|-----------|
| R1 | Filtro A: empresa `STATUS_CRED = ATIVO` | SVC | SVC | `Svc_Rodizio.SelecionarEmpresa` |
| R2 | Filtro B: empresa não está suspensa globalmente | SVC | SVC | idem |
| R3 | Filtro C: empresa não está inativa | SVC | SVC | idem |
| R4 | Filtro D: empresa sem OS aberta nessa atividade | SVC | SVC | idem |
| R5 | Filtro E: empresa sem Pré-OS pendente nessa atividade | SVC | SVC | idem |
| R6 | Ordem de filtros: A → B → C → D → E | SVC | SVC | idem |
| R7 | Empresa selecionada é a de menor `POSICAO_FILA` entre as elegíveis | SVC | SVC | idem |

---

## 9. Configuração

| # | Regra | Local atual | Local correto | Evidência |
|---|-------|-------------|---------------|-----------|
| G1 | `CONFIG` mantém valores na linha `LINHA_CFG_VALORES` | DATA+SVC | DATA+SVC | `Const_Colunas.bas` |
| G2 | `COL_CFG_MAX_RECUSAS`, `COL_CFG_MESES_SUSPENSAO`, `COL_CFG_PRAZO_PREOS`, `COL_CFG_NOTA_MINIMA` regem comportamento operacional | SVC | SVC | `TV2_SetConfigCanonica` em `Teste_V2_Engine.bas:357` |
| G3 | `COL_CFG_VERSAO` marca baseline de testes (V2 grava "TESTE_V2_BASELINE") | SVC | SVC | idem |

---

## 10. Lacunas consolidadas (MIG_*)

| ID | Regra | Arquivo origem | Arquivo destino | Prioridade |
|----|-------|----------------|-----------------|------------|
| MIG_001 | P6, P7 — `ENT_ID` válido e `QT_ESTIMADA > 0` em Pré-OS | `Menu_Principal.frm` | `Svc_PreOS.EmitirPreOS` | **Alta** |
| MIG_002 | O4 — `DT_PREV_TERMINO >= DT_EMISSAO` em OS | `Menu_Principal.frm` | `Svc_OS.EmitirOS` | **Alta** |
| MIG_003 | A4 — Justificativa obrigatória em divergência de quantidade | `Menu_Principal.frm` | `Svc_Avaliacao.AvaliarOS` | **Alta** |

A V2 já tem cenários com essas siglas marcados como `LogManual` — eles passam a ser assertivos assim que a regra for migrada, fechando o loop sem intervenção adicional na bateria.

---

## 11. Regras inferidas (não lidas diretamente no código)

Marcadas como **incerteza** para auditor externo confirmar:

- *I1*: após OS cancelada, a empresa volta ao final da fila ou mantém posição? O código sugere **manter posição** (não há chamada a `AvancarFila` em `CancelarOS`), mas não foi rastreado completamente.
- *I2*: importação de CNAE limpa `ATIVIDADES` ou apenas faz upsert? `ResetarECarregarCNAE` rewrite (`V12.0.0143`) sugere reset completo; `ImportarCNAE_Emergencia V2` (`V12.0.0144`) sugere upsert.
- *I3*: `AppContext.Invalidate` é chamado após mudanças estruturais — **inferência**: mantém cache consistente; confirmação requer inspeção de `AppContext.bas`.
- *I4*: quando `Suspender(empId)` roda, os credenciamentos daquela empresa em múltiplas atividades são todos afetados? Código sugere **sim** (status global domina), mas há leitura separada por `STATUS_CRED` (filtro A) que pode divergir.

Esses itens entram no backlog de validação (documento 09, seção I).
