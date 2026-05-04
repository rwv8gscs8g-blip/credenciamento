---
titulo: 00 - Superprompt Antigravity — Onda 16 (Refatoração estrutural dos testes + Heurística zero + PDFs determinísticos + UI automatizada)
diataxis: how-to
hbn-track: knowledge
hbn-status: active
audiencia: ia
prioridade: alta
versao-sistema: V12.0.0203-rc1 (publicada em GitHub 2026-05-02)
data: 2026-05-02
autor: Claude Opus 4.7 (Frente 1 Credenciamento) — Cowork
destinatario: Antigravity (IA terceira — auditoria + síntese arquitetural)
implementador-alvo: Claude Opus 4.7 (Frente 1 Credenciamento) em iteração longa única
licenca-target: TPGL-v1.1 (Credenciamento)
---

# Superprompt — Antigravity → Auditoria profunda + plano de refatoração estrutural dos testes (Onda 16)

> Olá, Antigravity. Você é uma IA terceira solicitada por **Luís
> Maurício Junqueira Zanin** (mantenedor do projeto Credenciamento)
> a propor uma refatoração estrutural ampla do subsistema de testes
> do projeto Credenciamento V12.0.0203-rc1 (publicado em
> https://github.com/rwv8gscs8g-blip/credenciamento). Sua resposta
> será implementada pelo Claude Opus 4.7 (Frente 1 Cowork) em
> **uma única iteração longa**. Por isso a resposta precisa ser
> precisa, exaustiva e auto-suficiente.

## 0. Identidade e contexto

| Campo | Valor |
|---|---|
| Projeto | Sistema de Credenciamento e Rodízio de Pequenos Reparos |
| Linguagem | VBA (Excel `.xlsm`) |
| Versão atual | V12.0.0203-rc1 (publicada 2026-05-02) |
| Build label | `f7aa84f+v12.0.0203-rc1` |
| Branch | `codex/v12-0-0203-governanca-testes` |
| Repositório público | https://github.com/rwv8gscs8g-blip/credenciamento |
| Licença | TPGL v1.1 (Credenciamento); usehbn é AGPLv3 |
| Protocolo | HBN — Human Brain Net (https://usehbn.org) |
| Fronteira do bastão | Frente 1 Credenciamento — Claude Opus 4.7 (Cowork) |

## 1. Leituras obrigatórias antes de propor

Antes de gerar a resposta, leia (nesta ordem) e cite no seu output
quais documentos você consultou efetivamente. Se algum estiver
inacessível, registre como `🟠 SOURCE NOT REACHED` no output.

### Tier 1 — fundação canônica

1. `AGENTS.md` — entrada canônica para IAs.
2. `.hbn/knowledge/0001-regras-v203-inegociaveis.md` — 10 regras
   inegociáveis. **Especial atenção à regra #3 (Heurística zero)**:
   - Proibido: `InStr(Caption)`, `ctl.Top`, `ctl.Left`,
     `For Each ctl In Me.Controls` para tomada de decisão.
   - Controles devem ser acessados por nome canônico hardcoded.
   - Cumprimento parcial não conta. A Onda 16 desta proposta deve
     eliminar 100% das heurísticas em todos os 13 forms.
3. `.hbn/knowledge/0002-regra-ouro-vba-import.md` — local-ai/vba_import/
   é a única fonte canônica.
4. `.hbn/knowledge/0003-glasswing-style-preventive-security.md` —
   8 vetores Glasswing (G1-G8).
5. `.hbn/knowledge/0005-protocolo-markers-v2.md` — 10 marcadores
   HBN V2 + delta card de 7 linhas.

### Tier 2 — estado da Onda 11 (closure rc1) e aprendizado

6. `auditoria/03_ondas/onda_11_v203_rc1_closure/70_FECHAMENTO_ONDA_11.md`
7. `auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md`
8. `.hbn/results/0011-exec-onda11.json`
9. `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` — **L1-L18 + M1-M7**
   (em particular L16-L18 + M7 da Onda 11; e L1-L15 da Onda 9).

### Tier 3 — código atual a refatorar

10. `local-ai/vba_import/001-modulo/ABE-Central_Testes_V2.bas` —
    Central V2 atual (versão de produção, opções `[1]-[14]` + `[20]`).
11. `src/vba/Central_Testes_V2.bas` — versão "evoluída" com `[15]-[19]`
    do drift D1.
12. `local-ai/vba_import/001-modulo/AAZ-Central_Testes.bas` — Central
    legada (`CT_*`).
13. `local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas` — engine
    de teste V2.
14. `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas` —
    cenários V2 (Smoke, Canonica, Stress, Strikes, FiltrosDeterministicos,
    `TV2_RunRodizioStrikesEndToEnd`).
15. `local-ai/vba_import/001-modulo/ABA-Teste_Bateria_Oficial.bas` —
    bateria V1.
16. `local-ai/vba_import/001-modulo/ABH-Teste_Validacao_Release.bas` —
    Trio + Quarteto Mínimo (gate oficial; sub
    `CT_ValidarRelease_QuartetoMinimo` é o release gate canônico).
17. `local-ai/vba_import/001-modulo/ABD-Teste_UI_Guiado.bas` — testes
    UI guiados (parcial).
18. `local-ai/vba_import/001-modulo/ABB-Central_Testes_Relatorio.bas`.
19. Os 13 forms em `src/vba/`:
    - `Altera_Empresa.frm`
    - `Altera_Entidade.frm`
    - `Cadastro_Servico.frm`
    - `Configuracao_Inicial.frm`
    - `Credencia_Empresa.frm`
    - `Fundo_Branco.frm`
    - `Limpar_Base.frm`
    - `Menu_Principal.frm`
    - `ProgressBar.frm`
    - `Reativa_Empresa.frm`
    - `Reativa_Entidade.frm`
    - `Rel_Emp_Serv.frm`
    - `Rel_OSEmpresa.frm`

### Tier 4 — specs já parcialmente preparadas (insumo)

20. `auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md` — geração de
    PDFs (DT-5 antecipado para esta onda).
21. `auditoria/00_status/36_SPEC_DT6_Validacao_UI_Configuracao_V12_0204.md`
    — validação UI parametrizada (DT-6 antecipado).
22. `auditoria/00_status/27_ROADMAP_REINCORPORACAO_INCREMENTAL_V203.md`.

## 2. Constraints inegociáveis

A proposta DEVE respeitar todos os seguintes:

| # | Constraint | Origem |
|---|---|---|
| C1 | Regra de Ouro 0002 — todos os artefatos importáveis em `local-ai/vba_import/` (única fonte canônica). | knowledge/0002 |
| C2 | G6 enforced — proibido escrever código VBA inline em chat. Use pseudocódigo, descrição estruturada ou referência a arquivo. | knowledge/0003 G6 |
| C3 | L14 pre-flight — antes de gerar código, listar assinaturas + UDTs + visibilidade. | PHAGOCYTOSIS L14 |
| C4 | `Mod_Types.bas` é TABU fora da Onda 9 plena. Sua proposta NÃO pode tocar em `Mod_Types.bas`. | regras V203 #9 |
| C5 | Drift G7 residual D1 (23 arquivos) preservado intencionalmente. Sua proposta deve operar sobre o canônico OU declarar explicitamente quando precisa sincronizar src/vba ↔ canônico. | DRIFT_G7_RESIDUAL_PRE_ONDA12.md |
| C6 | Heurística zero (regra V203 #3) — 100% dos 13 forms, sem cumprimento parcial. | knowledge/0001 #3 |
| C7 | `CT_ValidarRelease_QuartetoMinimo` (V1+V2_Smoke+V2_Canonica+E2E_Strikes) é o gate de release oficial e PRECISA continuar passando após cada microdelta. | knowledge/0001 + Onda 11 |
| C8 | License split — artefatos do Credenciamento são TPGL v1.1; padrões genéricos a promover para usehbn declaram AGPLv3 com consentimento. | knowledge/0003 |
| C9 | Markers HBN V2 — declarar marcadores aplicáveis (10 disponíveis) em cada microdelta proposto. | knowledge/0005 |
| C10 | Workbook é VBA — operador roda manualmente; IA entrega pacote `.bas` + `.frm` + `.code-only.txt` + manifesto Importador V3. | regras V203 #2 + Importador V3 |

## 3. Cinco pedidos (escopo Onda 16 redefinida)

### Pedido 1 — Auditoria + interface elegante da Central V2

**Análise solicitada.**

1. Listar todas as opções `[1]-[20]` da `Central_Testes_V2.CT2_AbrirCentral`
   (versão canônica + versão src/vba do drift D1) e classificar cada
   opção em uma de:
   - **Teste verdadeiro** — dispara macro de teste com asserts e
     produz OK/FALHA contável.
   - **Abrir aba** — apenas chama `TV2_AbrirX` que faz `Sheets("X").Activate`.
   - **Operação utilitária** — não é teste mas auxilia (ex.: `[16] Diag rodizio`).

2. Identificar redundâncias entre a Central legada (`AAZ-Central_Testes.bas`,
   `CT_*`) e a Central V2 (`ABE-Central_Testes_V2.bas`, `CT2_*`).

3. Identificar ausências:
   - Não existe gate explícito para Trio nem Quarteto na Central V2
     atual (`[12] Trio` foi adicionado apenas na MD-3.1; `[20]
     Quarteto` idem; `[15]-[19]` no src/vba são CNAE/Diag/CFG/IDM/RDZ).
   - Não existe submenu por categoria.
   - Não existe indicador de "última execução" na própria Central.

**Proposta esperada.**

1. **Reorganização do menu** por categoria com hierarquia clara,
   por exemplo:
   - **Smoke** (rápido, ~2 min): TV2_RunSmoke
   - **Filtros determinísticos** (~1 min)
   - **Canônica** (fundação, ~3 min)
   - **Stress** (deterministico/assistido, ~3-5 min)
   - **Strikes E2E** (~2 min)
   - **Releases**: Trio, Quarteto
   - **Auditoria visual**: abrir RESULTADO_QA_V2, CATALOGO,
     HISTORICO, TESTE_TRILHA, AUDIT_TESTES
   - **Utilitários**: Diag rodizio, Configuração, etc.
   Sub-menu por categoria via cascading `InputBox` ou form
   dedicado.

2. **Visualização de testes lentos** — proposta de mecanismo:
   - Coluna `DURACAO_MS` na sheet `RESULTADO_QA_V2` (já existe?
    confirmar empiricamente).
   - Aba `TESTES_LENTOS` ordenada decrescente por duração.
   - Sparkline/condicional na sheet de últimas N execuções.
   - Threshold de "lento" parametrizado em CONFIG (ex.:
     `THRESHOLD_TESTE_LENTO_MS=500`).

3. **Evolução histórica dos testes** na interface:
   - Proposta de aba `EVOLUCAO_TESTES` com gráfico (sparkline
     Excel embutido) por suite por dia.
   - Indicador de regressão: comparar última execução com média
     dos últimos 5.
   - Exposto em uma opção da Central com 1 clique.

4. **Form dedicado** (alternativa ao InputBox em cascata):
   - Form `CentralTestes_Painel.frm` com botões organizados por
     categoria + área de status (último resultado, duração,
     gráfico evolução).
   - Em conformidade com C6 (heurística zero — botões com nomes
     canônicos).

**Entregar para Pedido 1**: tabela de classificação + diagrama
ASCII/markdown da nova hierarquia + nomenclatura canônica de
controles (preparando Pedido 2).

### Pedido 2 — Heurística zero (regra V203 #3) em todos os 13 forms

**Análise solicitada.**

Para cada um dos 13 forms (paths em `Tier 3 #19`), levantar:

1. Inventário de controles (botões, textboxes, labels, listboxes,
   etc.) por nome.
2. Heurísticas detectadas: ocorrências de
   `InStr(*.Caption, ...)`, `ctl.Top`, `ctl.Left`,
   `For Each ctl In Me.Controls`, `Controls("...")` por índice
   variável.
3. Refatoração proposta: cada controle ganha nome canônico
   hardcoded; cada handler `*_Click` aciona helper público
   determinístico em módulo de service.

**Operador vai tirar prints.**

O operador (Luís Maurício) vai colher screenshots dos 13 forms para
referência visual durante a refatoração. Sua proposta deve incluir:

1. **Ordem recomendada** de refatoração — do mais simples ao mais
   complexo. Critério sugerido:
   - Mais simples = poucos controles + sem dependência de dados
     externos (ex.: `Fundo_Branco.frm`, `ProgressBar.frm`).
   - Mais complexo = muitos controles + lógica de negócio
     embutida (ex.: `Cadastro_Servico.frm`, `Configuracao_Inicial.frm`,
     `Menu_Principal.frm`).
2. **Convenção de nomes canônicos** para controles:
   - Botões: `cmd_<acao>_<dominio>` (ex.: `cmd_salvar_empresa`)
   - Textboxes: `txt_<campo>_<dominio>`
   - Labels: `lbl_<campo>_<dominio>` (estáticas) ou
     `lblData_<campo>` (dinâmicas)
   - Listboxes: `lst_<entidade>_<dominio>`
   - ComboBoxes: `cmb_<entidade>_<dominio>`
3. **Bateria de testes por form** após refatoração — cada form
   refatorado tem bateria mínima (ex.: cenários `FRM_<nome>_001..N`
   adicionados a `Teste_V2_Roteiros.bas`).

**Entregar para Pedido 2**: tabela form-a-form com
{controles_atuais, heurísticas_detectadas, ordem_proposta,
testes_propostos}.

### Pedido 3 — Testes UI automatizados (clique simulado)

**Análise solicitada.**

VBA permite acionar handler de form programaticamente via:

1. `Application.Run "FormName.cb_Botao_Click"` ou
2. Carregar form em modo modal/modeless e chamar handler interno
   por nome canônico.

Avaliar trade-offs:

- Modo invisível (form `Show vbModeless` + chamada de handler):
  rápido, mas pode não reproduzir efeitos colaterais de UI
  (validações inline, dependências de `Me`).
- Modo gravação de macro: muito mais lento mas valida UI real.

**Proposta esperada.**

1. **Helper genérico** `TUI_AcionarBotao(formName, botaoName)` que
   abstrai a invocação.
2. **Suite `TV2_RunUiClicks`** com cenários
   `UI_<form>_<botao>_001..N` que cobrem:
   - Cada botão de cada form (após refatoração heurística zero).
   - Validação do efeito esperado (estado da aba mudou? AUDIT_LOG
     registrou? sheet criada?).
3. **Estratégia de mock** para inputs do usuário (textboxes
   preenchidos via helper antes de acionar `*_Click`).
4. **Fixture pattern** — reuso da família L13/M6 (estado limpo +
   determinístico antes de cada UI test).

**Entregar para Pedido 3**: pseudocódigo do helper + matriz form ×
botão × cenário esperado.

### Pedido 4 — PDFs determinísticos como base de teste

**Análise solicitada.**

DT-5 já está specado em
[`auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md`](../../00_status/35_SPEC_DT5_PDFs_V12_0204.md)
e originalmente programado para V12.0.0204. **Antecipar para Onda 16.**

VBA tem `ExportAsFixedFormat Type:=xlTypePDF` nativo. Pré-requisitos:

- Nome único por execução: `<execucaoId>_<timestamp>_<hash8>.pdf`.
- Diretório alvo: `auditoria/04_evidencias/V12.0.0203/pdfs/`.
- Cabeçalho obrigatório: build label, hash SHA-1 do workbook,
  carimbo RFC 3339, identificação do operador.
- Rodapé obrigatório: linha `RESUMO: [N OSes] [M strikes] [K
  suspensoes] [STATUS=...]` + hash SHA-1 do conteúdo do próprio PDF
  (auto-validável).

**Proposta esperada.**

1. **Módulo novo** `Util_PDF.bas` (vai a Onda 16 — não toca
   `Mod_Types`):
   - `Util_PDF_GerarRelatorioCiclo(execucaoId, caminho) As TResult`
   - `Util_PDF_GerarRelatorioRodizio(OS_IDs, caminho) As TResult`
   - `Util_PDF_GerarSummaryFooter(conteudo) As String`
2. **Hooks** opcionais em `Svc_Avaliacao.AvaliarOS`,
   `Svc_Rodizio.SelecionarEmpresa`, `TV2_RunRodizioStrikesEndToEnd`.
3. **PDFs como fixtures de teste**: gerar PDF de baseline conhecido
   no início da onda e comparar PDFs futuros byte-a-byte (se
   determinístico) ou por extração de texto + diff (mais robusto).
4. **Suite `TV2_RunPdfDeterminismo`** que valida geração + leitura
   de PDF de baseline.

**Riscos a endereçar.**

- Performance (`ExportAsFixedFormat` pode levar > 5s por arquivo).
- Determinismo: timestamp no cabeçalho quebra hash byte-a-byte —
  separar campos voláteis de campos de conteúdo.
- Volume: planejar rotação mensal de PDFs em
  `auditoria/04_evidencias/<versao>/pdfs/`.

**Entregar para Pedido 4**: arquitetura `Util_PDF` + matriz de
fixture PDFs + estratégia de comparação (byte-a-byte vs extração de
texto vs OCR + diff).

### Pedido 5 — Plano único de implementação para Claude Opus 4.7

**Síntese solicitada.**

Os Pedidos 1-4 são interdependentes:

- Pedido 2 (heurística zero) cria nomes canônicos que **viabilizam**
  Pedido 3 (testes UI por nome).
- Pedido 1 (interface elegante) **consome** os pedidos 2+3 (forms
  refatorados + testes UI) ao redesenhar o menu.
- Pedido 4 (PDFs) é **fixture** que reforça o gate Quarteto + dá
  evidência forense que pode ser usada nos pedidos 1-3.

Proponha **microdeltas em sequência única** que Claude Opus 4.7
implemente em uma iteração longa. Cada microdelta:

- Tem build label próprio (`f7aa84f+ONDA16.MICRO<NN>-<descricao>-incremental`).
- Bumpa `APP_BUILD_IMPORTADO` em `AAX-App_Release.bas`.
- Tem manifesto `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO<NN>.txt`.
- Tem procedimento `auditoria/03_ondas/onda_16_testes_refatoracao/MD<NN>_PROCEDIMENTO_IMPORT.md`.
- **Mantém Quarteto verde** (V1=171/0+V2_Smoke=14/0+V2_Canonica≥20/0+E2E_Strikes=64/0).
- Espelha src/vba ↔ canônico ou explica drift intencional.

**Entregar para Pedido 5**:

1. **Roteiro de microdeltas numerados** com build label + arquivos
   tocados + gate esperado.
2. **Estimativa de esforço** por microdelta (em horas de operador
   + horas de IA).
3. **Análise de dependência** (DAG) — qual microdelta bloqueia qual.
4. **Plano de regressão** — como garantir Quarteto verde em cada
   passo.
5. **Plano de rollback** — como restaurar V12-202-AB-onda11-rc1 se
   um microdelta falhar.
6. **Critério de "Onda 16 fechada"** — definir gate final
   verificável.
7. **Atualizações esperadas em**:
   - `CHANGELOG.md`
   - `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` (lições novas
     antecipadas, ex.: L19 testes UI determinísticos, L20 PDFs
     como fixture, L21 menu hierárquico, etc.).
   - `auditoria/03_ondas/onda_16_testes_refatoracao/70_FECHAMENTO_ONDA_16.md`
   - `.hbn/results/0012-exec-onda16.json` (próximo NN no padrão
     `NN-exec-onda<NN>`).

## 4. Formato de resposta esperado

Sua resposta deve ser um documento Markdown único com:

```yaml
---
titulo: Onda 16 Credenciamento - Plano de refatoracao estrutural dos testes (resposta Antigravity)
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0203 (alvo da onda 16)
data: AAAA-MM-DD
autor: Antigravity (sintese arquitetural)
implementador: Claude Opus 4.7 (Frente 1 Cowork) - iteracao longa unica
licenca-target: TPGL-v1.1
---

# Onda 16 - Plano completo (resposta Antigravity)

## 0. Resumo executivo (1 paragrafo)
## 1. Documentos consultados (Tier 1-4)
## 2. Constraints validados (C1-C10)
## 3. Pedido 1 - Auditoria + interface elegante
## 4. Pedido 2 - Heuristica zero (13 forms)
## 5. Pedido 3 - Testes UI automatizados
## 6. Pedido 4 - PDFs deterministicos
## 7. Pedido 5 - Plano unico de microdeltas
## 8. Marcadores HBN V2 aplicaveis
## 9. Riscos e mitigacoes
## 10. Criterios de fechamento da Onda 16
## Apendice A - Inventario completo dos 13 forms
## Apendice B - Inventario completo dos testes atuais
## Apendice C - DAG de dependencia entre microdeltas
```

Cada seção numerada deve ter sub-seções específicas conforme
detalhado em §3 deste superprompt.

## 5. Princípios para sua resposta

1. **Precisão > prolixidade** — cada afirmação deve ser sustentada
   por arquivo + linha (formato: `arquivo.bas:NNN`) ou hipótese
   declarada como hipótese.
2. **Determinismo > narrativa** (lição L18) — propor padrões,
   não roteiros pedagógicos.
3. **Pre-flight L14 antes de cada microdelta** — sua proposta
   precisa permitir que o implementador faça pre-flight em < 5min
   por microdelta.
4. **Hashar antes de RCA** (lição M7) — ao propor mudança em
   arquivo divergente entre src/vba e canônico, declarar
   explicitamente sobre qual lado opera.
5. **Anti-vazamento de CONFIG** (lição L16) — qualquer suite nova
   que escreva em CONFIG deve declarar restore baseline em
   try/finally simulado.
6. **Instrumentação cirúrgica** (lição L17) — propor marcadores
   `DIAG_*` para regiões com múltiplas hipóteses.
7. **Heurística zero é binária** (regra V203 #3) — não aceitar
   "cumprimento parcial".
8. **Não duplicar fonte** — Regra de Ouro 0002 vale: tudo
   importável em `local-ai/vba_import/`.
9. **G6 enforced** — pseudocódigo OK; nada de `Sub`/`Function`
   inline no chat.
10. **Marcadores HBN V2** — declare em cada microdelta os
    marcadores aplicáveis (10 disponíveis).

## 6. Marcadores HBN V2 ativos neste superprompt

- 🔵 **HBN HANDOFF READY** — bastão Frente 1 disponibiliza contexto
  completo a Antigravity para síntese.
- 🟣 **HBN PEER REVIEW REQUESTED** — Antigravity é IA terceira
  externa fazendo revisão arquitetural; resposta passa por
  validação Frente 1 antes de virar implementação.
- ⚪ **HBN AUDIT-ONLY** — Antigravity NÃO toca código nesta tarefa;
  apenas propõe.
- 🟤 **HBN LICENSE SPLIT REQUIRED** — proposta para Credenciamento
  TPGL; padrões genéricos a promover usehbn AGPLv3 com
  consentimento.
- 🟡 **HBN NEEDS HUMAN DECISION** — qualquer decisão arquitetural
  ambígua na sua proposta deve ser apontada como Q1, Q2, ... para
  hearback do operador antes da implementação.

## 7. O que NÃO fazer

- ❌ Não toque em `Mod_Types.bas` (TABU C4).
- ❌ Não proponha alteração de `APP_RELEASE_TAG` ou `STATUS` (rc1
  está publicada).
- ❌ Não proponha sincronização forçada de drift D1 dos 23
  arquivos não-relacionados a esta onda.
- ❌ Não escreva código VBA inline (G6 — C2).
- ❌ Não use marker que não exista em
  `.hbn/knowledge/0005-protocolo-markers-v2.md`.
- ❌ Não crie pastas paralelas tipo `local-ai/testes_v2/` (Regra
  de Ouro 0002).
- ❌ Não recomende remover `CT_ValidarRelease_TrioMinimo` (gate
  intermediário continua útil mesmo com Quarteto como release).

## 8. O que SIM fazer

- ✅ Cite arquivos com path absoluto + linha quando possível.
- ✅ Use tabelas Markdown para análise quantitativa.
- ✅ Diagramas ASCII/Mermaid permitidos.
- ✅ Pseudocódigo permitido (e bem-vindo).
- ✅ Listar perguntas em aberto como `Q1`-`QN` para o operador.
- ✅ Propor cenários de teste com nomes canônicos
  (`FRM_<nome>_<NNN>`, `UI_<form>_<botao>_<NNN>`, etc.).
- ✅ Estimar esforço (horas) por microdelta com base em complexidade
  observável.

## 9. Resultado esperado para o operador

Após sua resposta, o fluxo é:

1. Operador (Mauricio) lê + valida a proposta.
2. Operador formula hearback (aprovações + Q1-QN respondidos).
3. Operador entrega resposta + hearback à Frente 1 (Claude Opus 4.7
   Cowork).
4. Frente 1 gera `.hbn/readbacks/0012-onda16-testes-refatoracao.json`
   conforme sua proposta.
5. Frente 1 implementa em iteração longa única, microdelta por
   microdelta, com Quarteto verde a cada gate.
6. Onda 16 fecha com `70_FECHAMENTO_ONDA_16.md` + ERP +
   PHAGOCYTOSIS atualizado + tag git `v12.0.0203-rc2` ou avanço
   para `v12.0.0204-base`.

A qualidade da sua resposta é o que viabiliza ou inviabiliza essa
iteração única. Por isso vale a pena gastar tempo lendo Tier 1-4
inteiramente antes de propor.

## 10. Begin

Não responda com placeholder. Responda com a proposta completa,
seções 0-10 + apêndices A-C, em uma única passada. Se algum
documento Tier 1-4 não for acessível, declare como `🟠 SOURCE NOT
REACHED` no início e ainda assim entregue a melhor proposta
possível com o que estiver disponível.

— Frente 1 Credenciamento, 2026-05-02
