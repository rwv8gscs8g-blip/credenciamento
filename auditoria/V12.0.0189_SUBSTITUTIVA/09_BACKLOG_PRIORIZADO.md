# 09. Backlog Priorizado para a Próxima Estabilização — V12.0.0189 → V12.0.019x

Ordenação por **impacto × prerrequisito**. Itens sem prerrequisito e com alto impacto vêm primeiro. Siglas (A, B, C, ...) agrupam por área.

---

## Sprint 1 — Destravar a V2

### A1 — [BLOQ] Corrigir baseline determinística da V2
- **Prioridade:** Máxima
- **Prerrequisito:** nenhum
- **Arquivos:** `vba_export/Teste_V2_Engine.bas`
- **Mudanças:** implementar B1 (doc 07) — substituir `TV2_CountRows` e `TV2_NextDataRow` por contagem via coluna-chave semântica; endurecer `TV2_ClearSheet`.
- **Critério de aceitação:** `CT2_ExecutarSmokeRapido` em planilha com histórico roda sem `Cenario triplo V2 inconsistente`.
- **Esforço:** ~4h
- **Versão esperada:** V12.0.0190

### A2 — [BLOQ] Assert pós-reset
- **Prioridade:** Alta
- **Prerrequisito:** A1
- **Arquivos:** `vba_export/Teste_V2_Engine.bas:381`
- **Mudanças:** adicionar verificação `TV2_CountRows = 0` em todas as 5 abas operacionais após reset.
- **Critério:** reset silencioso em planilha limpa; erro preciso indicando aba com resíduo em planilha poluída.
- **Esforço:** ~30min
- **Versão:** V12.0.0190

### A3 — Executar a bateria V2 no Excel e validar fix
- **Prioridade:** Alta
- **Prerrequisito:** A1, A2
- **Ação:** operador humano (Maurício) roda `CT2_ExecutarSmokeRapido`, `CT2_ExecutarSmokeAssistido`, `CT2_ExecutarStress`, `CT2_ExecutarStressAssistido`.
- **Critério:** todos rodam até o fim, com `PASS` ou `FAIL` semântico (não fatal estrutural).
- **Esforço:** ~1h

---

## Sprint 2 — Migrações UI → Serviço

### B1 — MIG_001 em `Svc_PreOS.EmitirPreOS`
- **Prioridade:** Alta
- **Prerrequisito:** A1-A3
- **Arquivos:** `vba_export/Svc_PreOS.bas`, `vba_export/Menu_Principal.frm`
- **Mudanças:** validar `ENT_ID` existente/ativo e `QT_ESTIMADA > 0`; UI captura e mostra MsgBox.
- **Critério:** `MIG_001` vira `PASS` assertivo na V2.
- **Esforço:** ~2h
- **Versão:** V12.0.0191

### B2 — MIG_002 em `Svc_OS.EmitirOS`
- **Prioridade:** Alta
- **Prerrequisito:** A1-A3
- **Arquivos:** `vba_export/Svc_OS.bas`, `vba_export/Menu_Principal.frm`
- **Mudanças:** validar `DT_PREV_TERMINO >= DT_EMISSAO`.
- **Critério:** `MIG_002` vira assertivo.
- **Esforço:** ~2h
- **Versão:** V12.0.0191

### B3 — MIG_003 em `Svc_Avaliacao.AvaliarOS`
- **Prioridade:** Alta
- **Prerrequisito:** A1-A3
- **Arquivos:** `vba_export/Svc_Avaliacao.bas`, `vba_export/Menu_Principal.frm`
- **Mudanças:** exigir justificativa em divergência de quantidade.
- **Critério:** `MIG_003` vira assertivo.
- **Esforço:** ~2h
- **Versão:** V12.0.0191

### B4 — Converter cenários MIG_* de LogManual para AssertError
- **Prioridade:** Alta
- **Prerrequisito:** B1, B2, B3
- **Arquivos:** `vba_export/Teste_V2_Roteiros.bas`
- **Critério:** os 3 cenários passam como `PASS` assertivos.
- **Esforço:** ~1h
- **Versão:** V12.0.0191

---

## Sprint 3 — Atomicidade e Segurança

### C1 — Atomicidade em `IncrementarRecusa`
- **Prioridade:** Média-Alta
- **Prerrequisito:** A1-A3
- **Arquivos:** `vba_export/Svc_Rodizio.bas`, `vba_export/Repo_Credenciamento.bas`, `vba_export/Repo_Empresa.bas` (novos rollback helpers)
- **Mudanças:** padrão try/rollback entre `CREDENCIADOS.COL_CRED_RECUSAS` e `EMPRESAS.COL_EMP_QTD_RECUSAS`. Log em `SHEET_AUDIT`.
- **Critério:** cenário `ATM_001` (doc 07 B6) passa.
- **Esforço:** ~4h

### C2 — Módulo `Svc_Transacao.bas` (UnitOfWork)
- **Prioridade:** Média
- **Prerrequisito:** C1
- **Arquivos:** novo `vba_export/Svc_Transacao.bas`
- **Mudanças:** implementar `Transacao_Iniciar/RegistrarWrite/Commit/Rollback`.
- **Critério:** cenários `ATM_002..005` passam.
- **Esforço:** ~8h

### C3 — `On Error` explícito em `ProximoId`
- **Prioridade:** Média
- **Arquivos:** `vba_export/Util_Planilha.bas:490-507`
- **Mudanças:** garantir `Util_RestaurarProtecaoAba` em `cleanup`.
- **Esforço:** ~30min

### C4 — Snapshot pré-reset na V2
- **Prioridade:** Média
- **Arquivos:** `vba_export/Teste_V2_Engine.bas`
- **Mudanças:** copiar as 5 abas operacionais para `SNAPSHOT_V2_ANTES_<timestamp>` antes de `TV2_ResetBaseOperacional`.
- **Critério:** operador consegue recuperar dados perdidos acidentalmente.
- **Esforço:** ~2h

---

## Sprint 4 — Cobertura e Shadow Mode

### D1 — Script `compara_baterias.py`
- **Prioridade:** Alta
- **Prerrequisito:** A1-A3
- **Arquivos:** novo `ferramentas/compara_baterias.py`
- **Mudanças:** lê `RPT_BATERIA` e `RESULTADO_QA_V2` e emite diff semântico.
- **Critério:** roda no CLI, gera markdown em `obsidian-vault/shadow/`.
- **Esforço:** ~4h

### D2 — Shadow mode contínuo
- **Prioridade:** Alta
- **Prerrequisito:** D1
- **Ação:** a cada release em `EM_VALIDACAO`, rodar V1 e V2 e gravar diff.
- **Critério de saída:** 5 releases consecutivas com divergência = 0.
- **Esforço:** contínuo ao longo de 3-5 sprints.

### E1 — Cenários `EDG_001..007` + `STR_002` + `STR_003`
- **Prioridade:** Média
- **Prerrequisito:** A1-A3
- **Arquivos:** `vba_export/Teste_V2_Roteiros.bas`
- **Esforço:** ~10h
- **Cobre:** L4, L5, L6, L7, L8, L10, L11 (doc 06)

---

## Sprint 5 — Higiene e Produção

### H1 — Isolar módulos de emergência
- **Prioridade:** Média
- **Arquivos:** `Emergencia_CNAE*`, `Importar_Agora`
- **Mudanças:** renomear para prefixo `_ADMIN_`, marcar `Private` onde possível, adicionar confirmação dupla.
- **Critério:** não aparecem (ou aparecem claramente) em Alt+F8.
- **Esforço:** ~1h

### H2 — Centralizar caminhos hardcoded
- **Prioridade:** Baixa
- **Arquivos:** `Const_Colunas.bas` ou novo `Const_Caminhos.bas`
- **Esforço:** ~1h

### H3 — Senha `sebrae2024` em constante
- **Prioridade:** Baixa
- **Arquivos:** `Const_Colunas.bas` ou novo `Const_Seguranca.bas`
- **Mudanças:** `Public Const SENHA_PLANILHA As String = "sebrae2024"`. Substituir todas as ocorrências.
- **Esforço:** ~30min

### H4 — Hash + versão no cabeçalho dos CSVs de teste
- **Prioridade:** Baixa
- **Arquivos:** `Teste_V2_Engine.bas` (função que exporta CSV)
- **Esforço:** ~1h

### H5 — Atualizar `REGRAS.md` e `PIPELINE.md`
- **Prioridade:** Baixa-Média
- **Arquivos:** `obsidian-vault/ai/REGRAS.md`, `obsidian-vault/ai/PIPELINE.md`
- **Esforço:** ~2h

---

## Investigações (tarefas de descobrir, não de implementar)

### I1 — Confirmar comportamento pós-cancelamento de OS
- Empresa volta à fila (mesmo posição) ou ao fim? Ler `Svc_OS.CancelarOS` até o fim.
- **Esforço:** ~30min

### I2 — Confirmar semântica de `ResetarECarregarCNAE` vs `ImportarCNAE_Emergencia V2`
- Upsert ou reset total?
- **Esforço:** ~30min

### I3 — Confirmar papel de `AppContext.Invalidate`
- Ler `AppContext.bas`.
- **Esforço:** ~30min

### I4 — Auditar `On Error Resume Next` em todos os `Repo_*`
- Mapear, decidir política para cada bloco.
- **Esforço:** ~2h

### I5 — Confirmar se `Suspender(empId)` afeta `COL_CRED_STATUS` em todas as atividades
- Relação entre `COL_EMP_STATUS_GLOBAL` e `COL_CRED_STATUS`.
- **Esforço:** ~1h

---

## Resumo quantitativo

| Sprint | Item | Esforço | Versão alvo |
|--------|------|---------|-------------|
| 1 | A1, A2, A3 | ~5.5h | V12.0.0190 |
| 2 | B1, B2, B3, B4 | ~7h | V12.0.0191 |
| 3 | C1, C2, C3, C4 | ~14.5h | V12.0.0192-3 |
| 4 | D1, D2, E1 | ~14h + contínuo | V12.0.0193+ |
| 5 | H1..H5 | ~5.5h | V12.0.0194 |
| - | Investigações I1..I5 | ~4.5h | em paralelo |

**Total de engenharia concentrada:** ~51 horas ao longo de ~5 sprints.

---

## Critério de saída do backlog

A V12.0.019x é considerada **estabilizada** quando:

- [ ] A1..A3 completos (V2 roda).
- [ ] B1..B4 completos (MIG_* assertivos).
- [ ] C1 completo (atomicidade em `IncrementarRecusa`).
- [ ] D2 com 5 releases consecutivas sem divergência.
- [ ] E1 com todos os `EDG_*` em `PASS`.
- [ ] H1 aplicado (módulos de emergência isolados).
- [ ] `GOVERNANCA.md` atualizada.
- [ ] `HASHES.md` regenerado.

Na hora em que todos os itens acima estejam ✅, a próxima versão se torna candidata a ser promovida como **V13.0.0000** (novo major, refletindo migração V1→V2 concluída).
