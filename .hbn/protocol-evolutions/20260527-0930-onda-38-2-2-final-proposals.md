---
titulo: Propostas de evolução do protocolo HBN — Onda 38.2.2 FINAL (pós-corrupção workbook + lições do RVS REPROVADO determinístico)
data: 2026-05-27
autoria: claude-opus-4-7 (sessão 2026-05-27 04:30→09:30)
gatilho: PROMPT_ARQUITETO v1.3 §7.3 (auto-evolução do protocolo a cada handoff)
predecessor: 20260526-1810-onda-38-2-2-proposals.md (L33-L40)
sucessor: a definir (próxima sessão Opus pós-consolidação das auditorias 0009+0010)
contexto-critico: Esta sessão presenciou (a) corrupção do workbook resultante de import V3 da Onda 38.2.2, (b) RVS REPROVADO determinístico em 2 execuções consecutivas, (c) execução paralela de 2 auditorias cruzadas (Codex + Antigravity) por Mauricio enquanto Opus processava feedback operacional. Lições novas L41-L43 + meta-lição sobre orçamento de contexto em sessões com incidentes.
---

# Propostas de evolução do protocolo HBN — Onda 38.2.2 FINAL

> Sessão sucessora do handoff 0430 desta mesma onda. Sucessora também das lições L33-L40 do `20260526-1810-onda-38-2-2-proposals.md`.

## 1. Contexto desta sessão — síntese do incidente

| Evento | Detalhe | Custo |
|---|---|---|
| Workbook 38.2.2 importado corrompeu durante uso | Mauricio reportou ~09:00; Excel travou completo | Re-abertura forçada, rollback obrigatório para cópia anterior (mesma versão) |
| RVS REPROVADO consecutivo | VR_20260527_060519 + VR_20260527_085514 — mesmas 2 falhas (V2_SMOKE drift + V2_E2E_STRIKES) | Confirma determinismo (não intermitente) |
| Mauricio executou 2 auditorias em paralelo | Codex 0009 (24KB) + Antigravity 0010 (16KB) — entregues durante a sessão | Próxima Opus consolida |
| Handoff Opus fechou a ~60% contexto | Excede regra 50% — justificado por incidente + paralelismo | Documentado §8 do handoff |

**Diagnóstico raiz do incidente**: a importação V3 da Onda 38.2.2 (8 módulos, hotfixes consecutivos) produziu um XLSM que aparentava funcional mas era estruturalmente frágil. Durante uso operacional (validação tela-a-tela), o Excel não tolerou alguma combinação interna.

---

## 2. Lições novas observadas

### L41 — Import V3 multi-hotfix produz workbook frágil quando manifesto cresce > 5 módulos

**Rule**: quando uma onda acumula > 5 hotfixes consecutivos com mudanças em `.frm`, **considerar import V3 em 2 fases**: (a) fase só-`.bas` primeiro com RVS Trio; (b) fase `.frm` depois com RVS Trio + sanidade visual.

**Evidência**: Onda 38.2.2 teve 5 hotfixes, manifesto cresceu para 8 módulos (M=3, F=5 originais; depois ajustes). Workbook resultante corrompeu durante uso operacional ~3 horas após import. Hipótese: tamanho do delta + número de forms tocados (Menu_Principal, Credencia_Empresa, Cadastro_Servico) excedeu envelope seguro do V3.

**Proposta de implementação**: adicionar à PHAGOCYTOSIS-VBA-PATTERNS guia "Quando dividir uma onda em 2 imports":

> Se o manifesto V3 tem ≥ 4 entradas tipo F| (forms) OU ≥ 8 entradas totais, considerar dividir a onda em 2 imports separados. Cada import com seu próprio RVS Trio.

**Status**: CANDIDATA — confirmar com Codex/Antigravity nas auditorias 0009/0010.

---

### L42 — RVS determinístico (2 execuções consecutivas mesma falha) = bug; intermitente = teste flaky

**Rule**: ao analisar falha de RVS, distinguir:
- **Determinística** (mesma falha em 2+ execuções consecutivas, mesmo workbook): bug real, investigar.
- **Intermitente** (falha em 1 execução, sucesso em outra): teste flaky, investigar o TESTE primeiro.

**Esta lição não é tão nova mas é importante reforçar** porque a tentação de "rodar de novo para ver se passa" gasta tempo em casos determinísticos. Esta sessão confirmou em 2 RVS consecutivos (`VR_20260527_060519` e `VR_20260527_085514`) que V2_SMOKE drift e V2_E2E_STRIKES `DIAG_PREOS_INTEGRITY` são determinísticos. Bug confirmado.

**Proposta de implementação**: adicionar à `auditoria/03_ondas/onda_<N>/<N>_TECNICO.md` template uma seção §RVS_TRIO_HISTORY que tabula todos os RVS rodados na onda, com link para CSV de evidência, status, primeira falha. Forçar dupla execução antes de declarar onda "RVS APROVADO".

**Custo**: ~2 min de teste extra por onda. **Valor**: previne "passou na sorte" + permite distinguir flaky de determinístico no histórico.

**Status**: CANDIDATA — incorporar via template MD.

---

### L43 — Workbook em uso operacional pode corromper mesmo com import V3 bem-sucedido + RVS Trio APROVADO em fases anteriores

**Rule**: NÃO confiar cegamente que workbook pós-import é estável só porque (a) GATE-IMPORT passou e (b) RVS Trio passou em fase anterior (FIX2-PERF). Validação tela-a-tela em uso real pode revelar instabilidade emergente.

**Evidência**: a Onda 38.2.2 passou GATE-IMPORT (`M=8|F=0|err=0`) + GATE-COMPILE limpo + AT-1..AT-5 funcionais via UI. **Mesmo assim, o workbook corrompeu durante uso operacional ~3h depois.**

**Proposta de implementação**: incluir no fluxo de qualquer onda que toca > 3 forms:

> **GATE-USO-PROLONGADO** (novo): após import V3 + GATE-COMPILE + AT-N, operador exercita o workbook em uso normal por ≥ 30 minutos (cadastros, consultas, relatórios, fechamento/reabertura). Só após esse uso prolongado é seguro avançar para GATE-RVS Trio.

**Custo**: 30 min de operação humana por onda multi-form. **Valor**: detecta corrupção emergente antes do freeze.

**Status**: CANDIDATA — aplicar a partir da Onda 38.2.3.

---

### M-L (meta-lição) — Orçamento de contexto Opus em sessões com incidente externo deve ser RECALCULADO, não apenas declarar exceção

**Observação**: sessão fechou a ~60% por 3 motivos válidos (incidente + paralelismo + tarefa substantiva grande). Knowledge 0017 §72-87 prevê "cláusula de exceção". **Mas a exceção isolada não evita o próximo caso.**

**Proposta**: refinar knowledge 0017 com seção "Recálculo de orçamento pós-incidente":

> Se durante a sessão surge incidente externo (corrupção, RVS REPROVADO surpresa, push externo) que demanda > 10% de contexto não planejado, **interromper trabalho substantivo no ponto seguro mais próximo e iniciar handoff antecipado**. Não tentar "absorver o incidente E continuar a onda original" — quase sempre estoura.

**Esta sessão tentou absorver e estourou**. Próxima sessão deve aplicar.

**Status**: META-CANDIDATA — refinar knowledge 0017 numa próxima onda safe_track doc-only.

---

## 3. Lições pré-existentes — status pós-sessão

| Lição | Status | Observação |
|---|---|---|
| L33 (.frm 2-3× contexto) | CONFIRMADA novamente | Esta sessão tocou .frm zero (só doc); não diretamente testada, mas indiretamente reforçada pelos hotfixes anteriores |
| L34 (signature freeze de módulos novos) | CONFIRMADA | Aplicada na auditoria — Opus releu Repo_Empresa/Repo_PreOS antes de propor F-NEW6 |
| L35 (manifestos similares como template) | NÃO TESTADA | Sessão sem manifesto novo |
| L36 (READ-FIRST domínio "chamada nova entre módulos") | NÃO TESTADA | Sessão sem chamada nova |
| L37 (Variant Empty Is Nothing) | NÃO TESTADA | Sessão sem .frm edit |
| L38 (enumerar paths antes de mudança transversal) | CONFIRMADA | F-NEW6 foi descoberto via grep exaustivo de `Cells\(.*, COL_*_ID\)\.Value\s*=` |
| L39 (sem FREEZE no nome até homologação) | EM USO | Onda continua chamada "38.2.2" sem sufixo FREEZE |
| L40 (meta-validação dos testes) | CONFIRMADA EMPIRICAMENTE | RVS Trio APROVADO na FIX2-PERF mascarou que V2_E2E_STRIKES tinha bug latente — só V2 completo (não Trio) revelou |
| HIERARQUIA-LEITURA-CONTEXTUAL | PROPOSTA INALTERADA | Aguarda decisão Mauricio + execução em próxima onda safe_track |

---

## 4. Resumo executivo

3 lições novas confirmadas em 1 sessão de 5h com 1 incidente, 2 RVS REPROVADOS e 2 auditorias paralelas processadas:

- **L41** — Import V3 multi-hotfix produz workbook frágil quando manifesto > 5 módulos
- **L42** — RVS determinístico (mesma falha 2x) = bug, não flaky
- **L43** — GATE-USO-PROLONGADO novo (operação por 30+ min antes do RVS Trio)
- **M-L** — Recálculo de orçamento pós-incidente vs cláusula de exceção solta

---

## 5. Sucessor

Próxima sessão Opus que abrir este arquivo, **após consolidar as 2 auditorias 0009 + 0010**:

1. **Decisão por lição**: para cada L41-L43 + M-L, escolha Promover Tier 1 / Promover Tier 2 / Rejeitar / Adiar
2. **Cross-check com Codex/Antigravity**: se as auditorias 0009/0010 propuseram lições adicionais, incorporar aqui
3. **Atualizar PROMPT_ARQUITETO v1.3 §2 pré-flight** se L41 ou L43 promovidas
4. **Próximo `.hbn/protocol-evolutions/`** consome este arquivo, mantém ATIVOS e adiciona suas lições

---

🔵 HBN PROTOCOL EVOLUTIONS COMPLETO
