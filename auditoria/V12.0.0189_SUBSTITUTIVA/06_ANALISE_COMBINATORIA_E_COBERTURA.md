# 06. Análise Combinatória e Cobertura — V12.0.0189

## 1. Objetivo

Inventariar as dimensões do sistema que podem ser combinadas em casos de teste, identificar quais combinações estão cobertas (V1, V2 ou ambas), e marcar lacunas. Serve de insumo para o documento 07 (plano de baterias complementares).

---

## 2. Dimensões relevantes

| Dimensão | Valores possíveis | Fonte |
|----------|-------------------|-------|
| **D1. Status global da empresa** | ATIVA, SUSPENSA, INATIVA | `COL_EMP_STATUS_GLOBAL` |
| **D2. Status do credenciamento** | ATIVO, SUSPENSO, INATIVO | `COL_CRED_STATUS` |
| **D3. OS aberta na atividade** | sim, não | `Repo_OS` |
| **D4. Pré-OS pendente na atividade** | sim, não | `Repo_PreOS` |
| **D5. Nº recusas empresa** | 0..MAX, MAX | `COL_EMP_QTD_RECUSAS` |
| **D6. Nº recusas credenciamento** | 0..MAX, MAX | `COL_CRED_RECUSAS` |
| **D7. `DT_FIM_SUSPENSAO`** | nula, passada, futura | `COL_EMP_DT_FIM_SUSP` |
| **D8. Posição na fila** | 1, meio, última | `COL_CRED_POSICAO` |
| **D9. Entidade solicitante** | ativa, inativa, inexistente | `SHEET_ENTIDADE` |
| **D10. Quantidade estimada (Pré-OS)** | 0, negativa, positiva | `COL_PREOS_QTD_ESTIMADA` |
| **D11. `DT_PREV_TERMINO` (OS)** | passada, igual emissão, futura | `COL_OS_DT_PREV_TERMINO` |
| **D12. Divergência em avaliação** | `QT_EXEC = QT_EST`, `QT_EXEC ≠ QT_EST` | `Svc_Avaliacao` |
| **D13. Justificativa de divergência** | vazia, preenchida | idem |
| **D14. Nota da avaliação** | 0, limiar, >= mínima | `COL_CFG_NOTA_MINIMA` |

Total bruto: 3 × 3 × 2 × 2 × 3 × 3 × 3 × 3 × 3 × 3 × 3 × 2 × 2 × 3 = **314.928 combinações**. Não é tratável exaustivamente.

---

## 3. Estratégia de cobertura: pairwise + casos semânticos

A estratégia recomendada é **pairwise** (cada par de dimensões visto em pelo menos uma combinação) mais um conjunto dedicado de **casos semânticos de borda**.

- **Pairwise teórico para 14 dimensões com cardinalidade média 2.5:** tipicamente 30 a 50 casos.
- **Casos semânticos de borda:** 12 a 18 casos.
- **Total alvo:** ~60 casos em uma bateria completa.

Ferramenta sugerida: gerador pairwise externo (ex.: `allpairs.py`) alimentado por um CSV com as 14 dimensões e seus valores. Executar offline e gravar os casos resultantes em `CATALOGO_CENARIOS_V2`.

---

## 4. Cobertura atual (V1 + V2)

### 4.1 Cenários V2 explícitos

Rastreados em `Teste_V2_Roteiros.bas`:

| Cenário | Cobre dimensões | Dimensões não endereçadas |
|---------|------------------|---------------------------|
| `SMK_001` — fila básica | D1(ATIVA) × D8 | D5..D14 |
| `SMK_002` — seleção por menor posição | D8 | D1..D7, D9..D14 |
| `SMK_003` — avanço de fila | D8 | idem |
| `SMK_004` — recusa simples | D5, D6, D8 | idem |
| `SMK_005` — suspensão por recusa máxima | D1, D5, D7 | idem |
| `SMK_006` — fila com entidade diferente | D9 | idem |
| `SMK_007` — Pré-OS aberta bloqueia nova | D4, D8 | idem |
| `STR_001` — N ciclos determinísticos | D1, D5, D8 | idem |
| `MIG_001` — ENT_ID inválido em Pré-OS | D9 | — (marcado LogManual) |
| `MIG_002` — DT_PREV_TERMINO inválida | D11 | — (LogManual) |
| `MIG_003` — divergência sem justificativa | D12, D13 | — (LogManual) |

### 4.2 Cenários V1 (Teste_Bateria_Oficial)

Cobertura semelhante em D1, D4, D5, D8. Pouca cobertura em D10, D11, D12, D13, D14.

### 4.3 Lacunas críticas

| ID | Lacuna | Dimensões | Prioridade |
|----|--------|-----------|------------|
| L1 | Avaliação com divergência justificada e não-justificada | D12, D13 | **Alta** (depende MIG_003) |
| L2 | OS com `DT_PREV_TERMINO` inválida | D11 | **Alta** (depende MIG_002) |
| L3 | Pré-OS com `QT_ESTIMADA = 0` ou negativa | D10 | **Alta** (depende MIG_001) |
| L4 | Empresa reativada após suspensão com `DT_FIM_SUSPENSAO` passada | D1, D7 | Média |
| L5 | Credenciamento SUSPENSO (distinto de empresa SUSPENSA) | D2 | Média |
| L6 | Nota exatamente no limiar mínimo | D14 | Baixa |
| L7 | Fila com empresa em última posição recusando | D5, D6, D8 | Média |
| L8 | Múltiplas empresas empatadas em `POSICAO_FILA` | D8 | **Alta** (edge case real) |
| L9 | Importação de CNAE com duplicatas | — | Baixa |
| L10 | Avaliação de OS cancelada | — | Média |
| L11 | Cancelamento de OS de empresa já suspensa | D1 | Média |
| L12 | `CONFIG` alterada em runtime (ex: MAX_RECUSAS diminuído) | G2 | Baixa |
| L13 | Entidade inativa sendo reativada após duplicação em `ENTIDADE_INATIVOS` | D9 | Média |
| L14 | Operação concorrente (dois operadores no mesmo workbook) | — | Fora de escopo |

---

## 5. Matriz cruzada: dimensão × status de cobertura

| Dim | Valor | Coberto V1 | Coberto V2 | Lacuna |
|-----|-------|------------|------------|--------|
| D1 | ATIVA | Sim | Sim | — |
| D1 | SUSPENSA | Sim | Sim | — |
| D1 | INATIVA | Parcial | Sim | — |
| D2 | ATIVO | Sim | Sim | — |
| D2 | SUSPENSO | Não | Não | L5 |
| D2 | INATIVO | Parcial | Parcial | L5 |
| D3 | sim | Sim | Sim | — |
| D3 | não | Sim | Sim | — |
| D4 | sim | Sim | Sim | — |
| D4 | não | Sim | Sim | — |
| D5 | 0..MAX-1 | Sim | Sim | — |
| D5 | MAX | Sim | Sim | — |
| D6 | 0..MAX-1 | Sim | Sim | — |
| D6 | MAX | Parcial | Parcial | L7 |
| D7 | nula | Sim | Sim | — |
| D7 | passada | Parcial | Parcial | L4 |
| D7 | futura | Sim | Sim | — |
| D8 | 1 | Sim | Sim | — |
| D8 | meio | Sim | Sim | — |
| D8 | última | Sim | Sim | — |
| D8 | empatada | Não | Não | L8 |
| D9 | ativa | Sim | Sim | — |
| D9 | inativa | Não | LogManual | L13 |
| D9 | inexistente | Não | LogManual (MIG_001) | L3 |
| D10 | 0 | Não | LogManual | L3 |
| D10 | negativa | Não | LogManual | L3 |
| D10 | positiva | Sim | Sim | — |
| D11 | passada | Não | LogManual (MIG_002) | L2 |
| D11 | igual | Não | LogManual | L2 |
| D11 | futura | Sim | Sim | — |
| D12 | sem divergência | Sim | Sim | — |
| D12 | com divergência | Não | LogManual (MIG_003) | L1 |
| D13 | vazia | Não | LogManual | L1 |
| D13 | preenchida | Sim | Sim | — |
| D14 | 0 | Parcial | Parcial | L6 |
| D14 | limiar | Não | Não | L6 |
| D14 | >= mínima | Sim | Sim | — |

---

## 6. Conclusões combinatórias

1. **Três pacotes MIG_* cobrem boa parte das lacunas prioritárias.** L1, L2, L3 se fecham assim que MIG_001, MIG_002, MIG_003 virarem testes assertivos (não mais `LogManual`). Confirma a priorização do documento 09.

2. **L5, L7 e L8 são lacunas estruturais que nenhuma das baterias cobre hoje.** Entram na bateria B5 (stress + edge cases) proposta em 07.

3. **L6 (nota no limiar) é cheap win.** Um caso por cenário e fecha. Entra em B4.

4. **L14 (concorrência) é fora de escopo enquanto o sistema for desktop single-user.** Fica anotado para quando a migração SaaS começar.

5. **Cobertura das operações multi-aba críticas (seção 2 do doc 04) é frágil em ambas as baterias.** Recomenda-se criar uma bateria específica `B6 — atomicidade`, que induza falha artificial em um `Repo_*` e verifique se a outra aba é revertida. Hoje essa bateria não existe.
