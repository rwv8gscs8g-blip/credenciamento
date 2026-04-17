# 08. Auditoria Substitutiva da V12.0.0166

> Este documento **substitui** o relatório de auditoria produzido sobre a V12.0.0166, que hoje está defasado em relação ao estado real do código na V12.0.0189. O conteúdo abaixo é a auditoria **em vigor** sobre o sistema de credenciamento.

---

## 1. Por que substituir

A auditoria V12.0.0166 refletia uma fotografia do sistema antes das seguintes mudanças estruturais:

- Centralização de `IdsIguais` em `Util_Planilha.bas` (V12-CLEAN, referenciada em `Util_Planilha.bas:509-514`).
- Eliminação total do termo MEI no `Menu_Principal` (V12.0.0167).
- Importador VBA via manifesto (V12.0.0163).
- Reestabilização de filtros de busca (V12.0.0140).
- Reestruturação documental (V12.0.0145).
- Base estável 0180 e retomada (V12.0.0180).
- Criação da bateria V2 paralela (V12.0.0182).
- Alinhamento do contrato real da fila (V12.0.0189).

Muitos apontamentos do relatório V166 tornaram-se inválidos (já resolvidos) ou mudaram de prioridade. Esta auditoria substitutiva consolida o estado atual.

---

## 2. Status dos apontamentos da V166 (acompanhamento)

Legenda:
- ✅ Resolvido
- ⚠️ Parcial
- ❌ Ainda aberto
- ➖ Já não se aplica

| Apontamento V166 (resumido) | Status em 0189 | Comentário |
|-----------------------------|----------------|------------|
| Duplicação de `IdsIguais` em 8 módulos | ✅ | Centralizada em `Util_Planilha.bas:516` |
| Termo MEI espalhado no `Menu_Principal` | ✅ | Removido em V167 |
| Importação de VBA frágil (cópia manual) | ✅ | Importador via manifesto em V163 |
| Filtros de busca com heurística não determinística | ✅ | Deterministas desde V174/176 |
| Rodízio: contrato da fila ambíguo (1..N) | ✅ | Alinhado em V189 |
| Acentos quebrados em `MsgBox` | ✅ | V165/V166 |
| Rel_OSEmpresa com crash | ✅ | V170 |
| Lacuna `ENT_ID` em Pré-OS | ❌ | **MIG_001** — ainda aberto |
| Lacuna `DT_PREV_TERMINO` em OS | ❌ | **MIG_002** — ainda aberto |
| Lacuna justificativa de divergência | ❌ | **MIG_003** — ainda aberto |
| Risco de performance em `ProximoId` | ⚠️ | Mantido; risco moderado |
| Busca O(n²) em `AtividadeJaExiste` | ⚠️ | Mantido; CNAEs ~612 linhas → tolerável |
| Módulos de emergência persistem | ❌ | `Emergencia_CNAE*`, `Importar_Agora` ainda ativos |
| Atomicidade em `IncrementarRecusa` | ❌ | Não endereçada |
| Bateria única e monolítica | ✅ | V2 introduzida |
| Documentação defasada | ⚠️ | `ESTADO-ATUAL.md` atualizado; `REGRAS.md` e `PIPELINE.md` necessitam revisão |

**Saldo:** 8 apontamentos da V166 resolvidos, 3 persistem (migrações MIG_*), 2 mitigados parcialmente, 1 substituído pelo risco novo da baseline V2.

---

## 3. Estado real do sistema em V12.0.0189

### 3.1 Camadas
- **UI:** `Menu_Principal.frm`, com heurística removida para filtros; handlers determinísticos; acentos corrigidos.
- **Serviço:** `Svc_Rodizio`, `Svc_PreOS`, `Svc_OS`, `Svc_Avaliacao`, `Svc_Empresa`, `Svc_Entidade`. Lógica central contida e rastreável.
- **Repositório:** `Repo_Credenciamento`, `Repo_PreOS`, `Repo_OS`, `Repo_Avaliacao`, `Repo_Empresa`, `Repo_Entidade`. Comparação de IDs via `IdsIguais` centralizada.
- **Dados:** planilha Excel com abas operacionais + auditoria + bateria V1 e V2.

### 3.2 Novidades relevantes desde V166
1. Bateria V2 com engine, roteiros e central dedicada.
2. Rollback operacional preservado em `backups/rollback-post-v180-2026-04-17/`.
3. Contrato real da fila formalmente alinhado (V189).
4. Central V1 simplificada e V2 em transição.
5. Exportação condicional de CSV na V2 (apenas quando há falhas).

### 3.3 Dívidas técnicas herdadas
- MIG_001, MIG_002, MIG_003.
- Atomicidade multi-aba.
- `ProximoId` com protect/unprotect por chamada.
- Módulos de emergência ainda presentes.
- Senha `sebrae2024` hardcoded.

### 3.4 Dívida nova (específica da V2)
- Fragilidade da baseline determinística (doc 02 e 07).
- Ausência de snapshot pré-reset.
- `MIG_*` como `LogManual` até migração ocorrer.

---

## 4. Apontamentos novos (não presentes na V166)

1. **N1 — Baseline V2 inconsistente.** Prioridade máxima. Corrigir via B1+B2 (doc 07).
2. **N2 — V2 sem snapshot pré-reset.** Perda silenciosa de dados operacionais se executada sobre sessão ativa. Mitigação: aba `SNAPSHOT_V2_ANTES_*` ou confirmação humana explícita.
3. **N3 — `TV2_ClearSheet` com `On Error Resume Next` global no trecho de ListObjects.** Doc 02 §2.3.
4. **N4 — CSVs de teste sem versão/hash no cabeçalho.** Doc 04 §4.
5. **N5 — Cenários MIG_* permanecem LogManual até migração.** Falsa sensação de cobertura se não houver acompanhamento.
6. **N6 — Shadow mode V1×V2 sem automação.** Hoje diff é manual. Doc 05 §4.
7. **N7 — Bateria de atomicidade inexistente.** Doc 07 §B6.
8. **N8 — Edge cases combinatórios L1..L14 parcialmente cobertos.** Doc 06.

---

## 5. Recomendação geral substituta

A recomendação que fecha esta auditoria é **não promover a V12.0.0189 a `VALIDADO` sem cumprir, nesta ordem:**

1. B1 — fixar `TV2_CountRows` e `TV2_NextDataRow` para usar coluna-chave semântica via `CountA`.
2. B2 — assert pós-reset em `TV2_ResetBaseOperacional`.
3. Rodar `CT2_ExecutarSmokeRapido` no workbook real e confirmar que `EMPRESAS=3, ENTIDADE=3, CREDENCIADOS=3, PRE_OS=0, CAD_OS=0`.
4. Rodar bateria V1 em paralelo e gerar primeiro diff (shadow mode manual).
5. Atualizar `GOVERNANCA.md` marcando como `VALIDADO` apenas se as etapas anteriores passarem.

Após V12.0.0189 promovida, a V12.0.0190 deve absorver B3 (migrações MIG_*).

---

## 6. Invalidação de recomendações antigas

Estas recomendações da V166 **não devem mais ser seguidas** sem revisão à luz do estado atual:

- "Reescrever `IdsIguais` em cada módulo" → obsoleto; foi centralizado.
- "Manter bateria única como fonte única de verdade" → V2 entrou como paralelo intencional.
- "Heurística no `Menu_Principal` deve ser melhorada" → heurísticas foram removidas.
- "Preservar termo MEI para compatibilidade" → não se aplica; termo foi eliminado em V167.

Qualquer agente que encontre a auditoria V166 em algum branch ou backup deve **descartar** as recomendações acima e se ater a esta substitutiva.
