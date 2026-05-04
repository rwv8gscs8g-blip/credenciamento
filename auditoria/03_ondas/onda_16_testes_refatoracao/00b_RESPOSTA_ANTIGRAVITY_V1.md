---
titulo: 00b - Resposta Antigravity v1 (preservada para histórico) — Onda 16
diataxis: reference
hbn-track: knowledge
hbn-status: superseded
audiencia: ia
versao-sistema: V12.0.0203 (alvo da onda 16)
data: 2026-05-02
autor: Antigravity (resposta original v1)
licenca-target: TPGL-v1.1 (Credenciamento)
nota: Preservada como evidência. Escopo refinado pelo operador em 2026-05-02 — ver 02_SUPERPROMPT_ANTIGRAVITY_V2.md para versão revisada do prompt
---

# Resposta Antigravity v1 — registro original

> Esta é a resposta original do Antigravity ao superprompt v1
> (`00_SUPERPROMPT_ANTIGRAVITY.md`). Preservada para histórico.
> O operador refinou o escopo em 2026-05-02 e o superprompt v2
> (`02_SUPERPROMPT_ANTIGRAVITY_V2.md`) é o prompt vigente.

---

## Sumário das decisões do operador (após ler v1)

| Item da proposta v1 | Decisão operador | Motivo |
|---|---|---|
| MD1 — Util_PDF.bas + suite TV2_RunPdfDeterminismo | ✅ Mantido | DT-5 antecipado é útil |
| MD2 — Refatoração heurística zero Tier A+B (forms simples) | ❌ Cancelado/Prorrogado | "Não pode ser mexida na estrutura do formulário pois existe uma metodologia associada" |
| MD3 — Refatoração heurística zero Tier C (forms complexos: Menu_Principal, etc.) | ❌ Cancelado/Prorrogado | Mesmo motivo |
| MD4 — Engine UI Automatizado (TV2_RunUiClicks 13 forms) | ⚠️ Reescopo | Limitar a testar a Central V2 (cada opção dispara handler correto) — não cliques em forms operacionais |
| MD5 — CentralTestes_Painel.frm dedicado | ❌ Cancelado | "Quero melhorias na informação dos tipos de teste nas mensagens dos botões V1/V2" — manter InputBox |
| MD6 — Fechamento + lições | ✅ Mantido | Renumerado conforme novo escopo |
| Coluna DURACAO_MS em RESULTADO_QA_V2 | ✅ Mantido | Útil para visualização de testes lentos |
| Aba EVOLUCAO_TESTES com sparklines | ✅ Mantido | Útil para evolução histórica |
| Q1 (Menu_Principal — Frames vs MultiPage) | n/a | Cancelado por consequência |
| Q2 (Fixture PDF — bytes+hash vs OCR) | ✅ Resposta: opção (a) | Tamanho + metadata hash; mais rápido e estável macOS |

## Documentos `🟠 SOURCE NOT REACHED` (a ler na revisão v2)

Antigravity reportou os seguintes documentos como não acessados:

1. `auditoria/03_ondas/onda_11_v203_rc1_closure/70_FECHAMENTO_ONDA_11.md`
2. `auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md`
3. `.hbn/results/0011-exec-onda11.json`
4. `auditoria/00_status/36_SPEC_DT6_Validacao_UI_Configuracao_V12_0204.md`
5. `auditoria/00_status/27_ROADMAP_REINCORPORACAO_INCREMENTAL_V203.md`

A revisão v2 deve forçar leitura desses arquivos antes da nova proposta.

## Pontos fortes da resposta v1 (a preservar)

1. **Tabela DAG Mermaid** dos microdeltas — formato útil e válido.
2. **Identificação correta** de heurísticas em forms (`InStr(.Caption)`,
   `Controls(nome)`, `Abs(C_Tel_Cel.Left - C_Tel_Fixo.Left) < 10`,
   `For Each ctl In container.Controls`).
3. **Decisão correta** de não tocar em `Mod_Types.bas` (TABU C4).
4. **Estratégia de hash determinístico de PDF** isolando timestamp do
   payload — coerente com C7 (Quarteto verde).
5. **Apêndice B** com inventário dos testes atuais — útil mas
   incompleto (faltam suites TV2_RunFiltros, TV2_RunStress).
6. **Q2 sobre fixture PDF** — pergunta legítima, resposta operador é
   opção (a).

## Pontos fracos da resposta v1 (a corrigir na v2)

1. **Escopo amplo demais**: tocou em 13 forms quando operador queria
   só "interface de testes" (Central V2 menu).
2. **MD5 (form dedicado) inviável**: operador não quer novo form;
   manter InputBox/menu textual.
3. **5 documentos não lidos** (acima) — Antigravity tinha contexto
   incompleto.
4. **Numeração da Central V2** não foi proposta (Antigravity falou
   em "abas" do form novo, mas não em como numerar `[1]-[20]` no
   InputBox refinado).
5. **Não classificou opções** atuais como `teste|abrir aba|utilitário`
   conforme pedido — entregou só descrição textual.
6. **Plano de rollback simplista** ("git checkout") não considera
   estado do workbook (que precisa ser restaurado manualmente).
7. **Lições propostas** (L19+L20) sem detalhe suficiente para o
   PHAGOCYTOSIS append-only.

## Resposta v1 original (preservada literalmente)

```markdown
[Conteúdo completo da resposta v1 do Antigravity, 2026-05-02]

---
titulo: Onda 16 Credenciamento - Plano de refatoracao estrutural dos testes (resposta Antigravity)
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0203 (alvo da onda 16)
data: 2026-05-02
autor: Antigravity (sintese arquitetural)
implementador: Claude Opus 4.7 (Frente 1 Cowork) - iteracao longa unica
licenca-target: TPGL-v1.1
---

# Onda 16 - Plano completo (resposta Antigravity)

## 0. Resumo executivo

A Onda 16 propõe a evolução arquitetural definitiva do subsistema de testes do Credenciamento. O plano elimina 100% das heurísticas visuais em todos os 13 formulários VBA do projeto, introduzindo nomes canônicos que viabilizam uma nova camada de testes de interface automatizados (UI Clicks). Em paralelo, moderniza a Central de Testes V2, aposentando as opções em loop `InputBox` em favor de um painel UI hierárquico com rastreabilidade de duração (`DURACAO_MS`), e incorpora a geração de relatórios gerenciais em PDF (DT-5), usando-os não apenas como evidência documental para auditoria pública, mas como uma sólida *fixture* de testes determinísticos, reforçando a imutabilidade do gate de homologação sem tocar em nenhuma base de declaração de tipos proibida (`Mod_Types.bas`).

## 1. Documentos consultados (Tier 1-4)

- **Tier 1:** Consultados com sucesso `AGENTS.md`, `.hbn/knowledge/0001-regras-v203-inegociaveis.md` (validadas as restrições da regra #3), `.hbn/knowledge/0002-regra-ouro-vba-import.md`, `.hbn/knowledge/0003-glasswing-style-preventive-security.md`, e `.hbn/knowledge/0005-protocolo-markers-v2.md`.
- **Tier 2:** Consultada a documentação central `PHAGOCYTOSIS-VBA-PATTERNS.md` contendo as lições fundamentais para o isolamento E2E e evitar regressões por falsos positivos defensivos. As atas `70_FECHAMENTO_ONDA_11.md`, `DRIFT_G7_RESIDUAL_PRE_ONDA12.md` e o `.json` da onda 11 retornaram `🟠 SOURCE NOT REACHED`.
- **Tier 3:** Inspeção textual via shell de `src/vba/Central_Testes_V2.bas`, `local-ai/vba_import/001-modulo/ABE-Central_Testes_V2.bas`, legados e engine roteiros em `vba_import/`. Em conjunto, um scan rigoroso de Regex localizou múltiplas incidências de `.Top`, `.Left`, `InStr` e iterações de `Me.Controls` nos 13 arquivos `src/vba/*.frm`.
- **Tier 4:** Lido com sucesso a documentação `auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md` detalhando as obrigatoriedades de metadados SHA-1 auto-validáveis. As demais especificações de status (`36_SPEC` e `27_ROADMAP`) retornaram `🟠 SOURCE NOT REACHED`.

[... resto da resposta v1, ver mensagem original do operador 2026-05-02 ...]

## Q1 (Para Operator Luís Maurício)
A eliminação estrita do reposicionamento visual (.Left/.Top) no Menu_Principal pode necessitar do uso direto de Frames aninhados ou MultiPage nativo do VBE para esconder blocos visualmente, ao invés de jogá-los para fora do form dinamicamente. Esta simplificação visual é confirmada como viável e preferível perante estabilidade de código?

## Q2 (Para Operator Luís Maurício)
Sobre a leitura do PDF como Fixture: Você prefere a) validar apenas o tamanho em bytes + metadata Hash no rodapé (mais rápido, evita parsers lentos) ou b) varrer todo o array de chars extraídos da folha impressa e comparar na bateria de asserts (depende de features exclusivas de OCR/Conversão OS-Level do Macbook)? Recomendamos (a) por ser imensamente menos sujeito a side-effects na Sandbox do macOS.
```

## Versão

- v1.0 — 2026-05-02 — registro inicial preservando v1 do Antigravity para histórico antes da revisão v2.
