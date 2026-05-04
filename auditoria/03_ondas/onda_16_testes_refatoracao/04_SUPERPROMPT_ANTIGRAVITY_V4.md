---
titulo: 04 - Superprompt Antigravity v4 (escopo final consolidado) — Onda 16
diataxis: how-to
hbn-track: knowledge
hbn-status: active
audiencia: ia
prioridade: alta
versao-sistema: V12.0.0203-rc1 (alvo da onda 16 = rc2 ou V12.0.0204-base)
data: 2026-05-02
autor: Claude Opus 4.7 (Frente 1 Credenciamento) — Cowork
destinatario: Antigravity (revisão final esperada — v4)
implementador-alvo: Claude Opus 4.7 (Frente 1 Credenciamento) em iteração longa única + microdelta colaborativo de filtros
licenca-target: TPGL-v1.1 (Credenciamento)
revisao-anterior-v1: 00_SUPERPROMPT_ANTIGRAVITY.md (cancelada)
revisao-anterior-v2: 02_SUPERPROMPT_ANTIGRAVITY_V2.md (cancelada)
revisao-anterior-v3: 03_SUPERPROMPT_ANTIGRAVITY_V3.md (substituída por refinamentos)
resposta-v1-arquivada: 00b_RESPOSTA_ANTIGRAVITY_V1.md
---

# Superprompt Antigravity v4 — Onda 16, escopo consolidado

> Olá Antigravity. Esta é a versão final do prompt da Onda 16.
> Substitui v1, v2, v3. **Não construa em cima delas — leia esta
> v4 como prompt completo.** Mantenha o formato canônico
> (10 seções + 3 apêndices).

## 0. Contexto inicial obrigatório

Você é Antigravity. Vai propor refatoração estrutural do
subsistema de testes do projeto Credenciamento V12.0.0203-rc1
(publicado em https://github.com/rwv8gscs8g-blip/credenciamento).
Sua resposta será implementada pelo Claude Opus 4.7
(Frente 1 Cowork) em **iteração longa única + microdelta
colaborativo (filtros tela-a-tela com prints)**.

| Campo | Valor |
|---|---|
| Projeto | Sistema de Credenciamento e Rodízio de Pequenos Reparos |
| Linguagem | VBA (Excel `.xlsm`) |
| Versão atual | V12.0.0203-rc1 (publicada 2026-05-02) |
| Build label | `f7aa84f+v12.0.0203-rc1` |
| Workbook ancora | `V12-202-AB-onda11-rc1` |
| Branch | `codex/v12-0-0203-governanca-testes` |
| Repo público | https://github.com/rwv8gscs8g-blip/credenciamento |
| Licença | TPGL v1.1 (Credenciamento); usehbn é AGPLv3 |
| Protocolo | HBN — Human Brain Net |
| Bastão | Frente 1 Credenciamento — Claude Opus 4.7 (Cowork) |

## 1. Decisões finais do operador (frase canônica)

> "(1) Já existe um padrão que está sendo tomado no Entidade e
> Empresa — quero simplesmente validar na mesma forma para os
> demais Filtros, confira e corrija para termos tudo padronizado.
> (2) Central de testes — OK, revisão das mensagens dos botões.
> (3) Util_PDF: o próprio nome do arquivo já deve ser explicativo
> do que ele é, tipo nome da OS + data no nome do arquivo. (4)
> Testes UI: quero que TODOS os testes da V1 e da V2 possam ser
> feitos clicando diretamente na interface de forma automatizada
> para garantirmos que a interface está aderente com a regra de
> negócio."

## 2. Pre-flight feito pela Frente 1 (insumo para você)

A Frente 1 inspecionou os 2 forms-referência citados pelo operador
e detectou:

### Altera_Empresa.frm (estado atual)

- ✅ Já usa **handlers nomeados diretamente**:
  - `Private Sub mBtnInativarEmpresa_Click()`
  - `Private Sub M_Alterar_Click()`
  - `Private WithEvents mBtnInativarEmpresa As MSForms.CommandButton`
- ✅ Convenção observada: `M_<Funcionalidade>` (textbox/control
  edição), `mBtn<Funcionalidade>` (botão modernizado WithEvents)
- ⚠️ **Heurística residual** (regra V203 #3 violada parcialmente):
  - `BuscarControleEdicaoRecursivo` faz `For Each ctl In container.Controls`
  - `BuscarLabelEdicaoDoCampo` busca por dedução
  - `PosicaoEsquerdaAbsolutaEdicao`, `PosicaoTopoAbsolutaEdicao`
    usam `.Top`/`.Left`
  - `UI_CaptionContemTodos` faz `InStr(.Caption)`
  - `UI_EncontrarBotaoPorTextos` busca botão por texto

### Altera_Entidade.frm (estado atual)

- ✅ Handlers nomeados diretamente, **sem heurística**:
  - `Private Sub B_Altera_Entidade_Click()`
  - `Private Sub C_Inativa_Entidade_Click()`
- ✅ Convenção observada: `B_<Funcionalidade>` (botão alterar),
  `C_<Funcionalidade>` (botão cancelar/inativar)
- ✅ Sem `For Each ctl`, sem `InStr(.Caption)`, sem `Controls(varname)`
- ✅ **Estado canônico desejado** — modelo a estender aos demais

### Conclusão pre-flight

O "padrão sendo tomado" pelo operador é:

1. **Handlers nomeados diretamente** — `<NomeControle>_Click()`,
   sem busca por dedução.
2. **Convenção de nomes existente em uso**:
   - `M_<Campo>` para textbox/edição (Empresa)
   - `B_<Acao>` para botão alterar (Entidade)
   - `C_<Acao>` para botão cancelar/inativar (Entidade)
   - `mBtn<Funcionalidade>` para botões modernizados WithEvents
     (Empresa)
3. **`Altera_Entidade.frm` é o exemplo limpo**; `Altera_Empresa.frm`
   tem dívida heurística residual a ser limpa nesta onda
   (cirurgicamente — apenas remover funções de busca/posicionamento
   heurístico, sem mexer no layout/estrutura do form).

## 3. Cinco áreas de refatoração (escopo Onda 16 final)

### Área F — Padronização cirúrgica de filtros (estender padrão Empresa↔Entidade)

**Não é refatoração ampla.** É trabalho cirúrgico:

1. **Confirmar/refinar a convenção** observada em `Altera_Empresa.frm`
   e `Altera_Entidade.frm`. Decidir se há divergência entre os dois
   (`B_/C_` em Entidade vs `mBtn/M_` em Empresa) e propor padrão
   consolidado a estender.
2. **Estender a todos os forms com filtros** que ainda não seguem
   o padrão.
3. **Limpar heurística residual** em `Altera_Empresa.frm` (remover
   `BuscarControleEdicaoRecursivo`, `BuscarLabelEdicaoDoCampo`,
   `PosicaoEsquerdaAbsolutaEdicao`, `PosicaoTopoAbsolutaEdicao`,
   `UI_CaptionContemTodos`, `UI_EncontrarBotaoPorTextos`) sem
   mexer no layout/estrutura do form.

**Plano colaborativo (operador tira print):**

Para cada tela com filtro:

1. Operador tira print mostrando os controles na UI real.
2. Antigravity infere nomes atuais e propõe ajuste para padrão
   consolidado.
3. Frente 1 ajusta apenas o código (nomes em handlers + chamadas),
   **sem mexer no `.frx`** (preserva designer).
4. Quarteto verde após cada ajuste.
5. Idempotência: rodar filtro 1x ou Nx produz mesmo estado.

**Forms operacionais NÃO sofrem refatoração estrutural.** Apenas:
- nomes de controles ajustados (se preciso, mas preservando layout)
- handlers `<Nome>_Click()` mantidos diretos
- heurística residual removida em Empresa

**Análise solicitada:**

1. Inventário de forms com filtros (combobox/textbox/listbox).
2. Detectar uso atual: filtros já usam padrão Empresa↔Entidade ou
   ainda usam dedução?
3. Propor padrão consolidado (Antigravity decide se Empresa ou
   Entidade é o template canônico, ou se devem convergir para um
   terceiro).
4. Ordem de revisão (do mais simples ao mais complexo).
5. Para cada filtro: bateria mínima de teste idempotente.

**Entregar:**

- Tabela form-a-form: {tem_filtros?, controles_atuais,
  padrão_atual_observado, padrão_consolidado_proposto,
  ajustes_necessários}.
- Plano colaborativo em N rodadas (1 print por tela).
- Esforço estimado por tela.

### Área A — Texto do menu (Central V12 + Central V2)

**Sem novo form. InputBox apenas.** Texto refinado.

#### A.1 — Central V12 / Transição

Atualmente em `local-ai/vba_import/001-modulo/AAZ-Central_Testes.bas`:

```
=== CENTRAL DE TESTES V12 / TRANSICAO ===

[1] Executar Bateria Oficial V1 (rapida ~5 min / assistida ~8 min)
[2] Abrir Central de Testes V2
```

**Análise + proposta esperada:**

Enriquecer texto e oferecer atalho direto para Quarteto (gate
oficial) sem precisar passar pela Central V2:

```
=== CENTRAL DE TESTES V12 / TRANSICAO ===
Build atual: f7aa84f+v12.0.0203-rc1 (rc1 publicada)
Gate oficial: [3] Quarteto Minimo

🎯 GATES DE RELEASE
[3] Quarteto Direto: V1 + V2 Smoke + V2 Canonica + E2E Strikes (~12 min)  ★★★ OFICIAL rc1

🧪 ENTRY POINTS
[1] Bateria Oficial V1 (legado, rapida ~5 min / assistida ~8 min)
[2] Central de Testes V2 (suites detalhadas + utilitarios)
```

(Sua proposta pode refinar o texto. O ponto é: incluir Quarteto
como atalho top-level + cabeçalho com build atual.)

#### A.2 — Central V2

Atualmente em `local-ai/vba_import/001-modulo/ABE-Central_Testes_V2.bas`
(canônico, V12.0.0203-rc1):

```
=== CENTRAL DE TESTES V2 ===

[1] Smoke rapido (~2 min)
[2] Smoke assistido (~3 min)
[3] Stress deterministico (~3 min)
[4] Stress assistido (~5 min)
[5] Suite canonica (fundacao, ~3 min)
[6] Abrir roteiro assistido V2
[7] Abrir RESULTADO_QA_V2
[8] Abrir CATALOGO_CENARIOS_V2
[9] Abrir HISTORICO_QA_V2
[10] Abrir TESTE_TRILHA
[11] Abrir AUDIT_TESTES
[12] Validacao release Trio: V1 + Smoke + Canonico (~10 min)
[13] Filtros deterministicos (~1 min)
[14] Strikes na avaliacao (~2 min)
[20] Validacao release Quarteto: V1 + Smoke + Canonico + E2E Strikes (~12 min)

Digite o numero:
```

**Análise + proposta esperada:**

Reorganização hierárquica por categoria, com Quarteto destacado:

```
=== CENTRAL DE TESTES V2 — V12.0.0203-rc1 ===
Gate oficial: [20] Quarteto Minimo

🎯 GATES DE RELEASE
[12] Trio (V1 + V2_Smoke + V2_Canonica) — ~10 min
[20] Quarteto Minimo (V1 + V2_Smoke + V2_Canonica + E2E_Strikes) — ~12 min  ★★★ OFICIAL

🧪 SUITES DE TESTE
[1] Smoke rapido — ~2 min
[2] Smoke assistido — ~3 min
[5] Suite canonica (fundacao) — ~3 min
[3] Stress deterministico — ~3 min
[4] Stress assistido — ~5 min
[13] Filtros deterministicos — ~1 min
[14] Strikes na avaliacao (E2E) — ~2 min

📊 VISUALIZACAO (abrir aba)
[7] RESULTADO_QA_V2
[8] CATALOGO_CENARIOS_V2
[9] HISTORICO_QA_V2
[10] TESTE_TRILHA
[11] AUDIT_TESTES
[21] EVOLUCAO_TESTES (sparklines + regressoes)  ← novo na Onda 16

🔧 UTILITARIOS / DIAGNOSTICO
[6] Roteiro assistido V2
[22] PDFs gerados (auditoria/04_evidencias/V12.0.0203/pdfs/)  ← novo na Onda 16
```

(Itens `[15]-[19]` do drift D1 ficam preservados no src/vba — não
aparecem no canônico V12.0.0203-rc1.)

### Área B — Coluna `DURACAO_MS` em `RESULTADO_QA_V2`

(Mantido conforme v3.)

**Análise:** confirmar se já existe coluna; senão propor `DURACAO_MS`
(Long, ms) populada em `TV2_FinalizarExecucao` via `Timer * 1000`.
Threshold em CONFIG: `THRESHOLD_TESTE_LENTO_MS = 500`.

### Área C — Aba `EVOLUCAO_TESTES` (sparklines + indicador de regressão)

(Mantido conforme v3.)

**Análise:** schema da sheet, hook em `TV2_FinalizarExecucao`,
sparkline VBA Mac, indicador de regressão (duração > média*1.5),
opção `[21]` na Central V2 com handler dedicado.

### Área D — `Util_PDF.bas` com nome humano-legível por entidade

**Mudança chave vs v3**: nome do arquivo deve ser **explicativo
para humanos**, não encoding técnico. Padrão: `<TIPO>_<ENTIDADE_ID>_<DATA>.pdf`.

**Análise + proposta esperada:**

1. **Nomeação canônica do arquivo PDF:**

| Tipo de entidade | Nome do arquivo | Exemplo |
|---|---|---|
| PRE_OS | `PREOS_<PREOS_ID>_<DATA>.pdf` | `PREOS_PRE-2025-001_2026-05-02.pdf` |
| OS | `OS_<OS_ID>_<DATA>.pdf` | `OS_2025-001_2026-05-02.pdf` |
| Avaliação de OS | `AVAL_<OS_ID>_<DATA>.pdf` | `AVAL_2025-001_2026-05-02.pdf` |
| Ciclo de rodízio completo | `CICLO_<EXECUCAO_ID>_<DATA>.pdf` | `CICLO_TV2_20260502_063028_2026-05-02.pdf` |

   - Sem hash no nome — hash vai em **metadata interno do PDF**
     (cabeçalho/rodapé) e em coluna `HASH_PAYLOAD` na sheet
     `RPT_PDFS_GERADOS`.
   - Data no formato `YYYY-MM-DD` (ordenável).
   - Se já existe arquivo com mesmo nome no mesmo dia, sufixar com
     `_NN` (ex.: `OS_2025-001_2026-05-02_02.pdf`).

2. **Diretório alvo:** `auditoria/04_evidencias/V12.0.0203/pdfs/<EXECUCAO_ID>/`

3. **Emissão automática durante testes:**
   - Hook em `TV2_RunRodizioStrikesEndToEnd` ao final → gera 1 PDF
     por OS criada no ciclo (3 PDFs típicos).
   - Hook em `Svc_Avaliacao.AvaliarOS` (opcional) → gera PDF da
     avaliação após cada nota lançada em ambiente de teste.

4. **API mínima do `Util_PDF.bas`:**
   - `Util_PDF_GerarPdfPreOS(preosId, execucaoId) As String` (retorna caminho do PDF gerado)
   - `Util_PDF_GerarPdfOS(osId, execucaoId) As String`
   - `Util_PDF_GerarPdfAvaliacao(osId, execucaoId) As String`
   - `Util_PDF_GerarPdfCiclo(execucaoId) As String`
   - `Util_PDF_HashPayloadDeterministico(caminho) As String`
   - `Util_PDF_RegistrarEmRpt(caminho, tipo, entidadeId, hashPayload) As Long` (linha
     adicionada em `RPT_PDFS_GERADOS`)

5. **Suite `TV2_RunPdfDeterminismo`:**
   - CT_PDF_001: gera baseline conhecido, hash payload = X
   - CT_PDF_002: gera novo cenário idêntico, hash deve = X
   - CT_PDF_003: muda 1 strike, hash deve diferir
   - CT_PDF_004: nome do arquivo segue padrão canônico
     (regex match)
   - CT_PDF_005: idempotência — gerar 2 vezes a mesma OS no mesmo
     dia → arquivos com sufixo `_01`, `_02`

6. **Hash determinístico do payload:**
   - Hashar **apenas o conteúdo de dados** (OS_ID, EMP_ID, MEDIA,
     STATUS, lista de eventos AUDIT_LOG do ciclo) — **nunca**
     timestamp ou caminhos.
   - Hash em metadata interno do PDF (footer "HASH_PAYLOAD: <sha1>").

### Área E — Testes UI: TODOS os testes V1+V2 acionados via interface

**Mudança chave vs v3**: cobertura completa V1+V2 via interface
clicando, não apenas filtros padronizados.

**Análise + proposta esperada:**

1. **Interpretação do "via interface" para a Central** (que é
   InputBox, não form):
   - Solução: cada teste V1+V2 tem opção numerada na Central V2
     (já tem). O teste UI da Central = chamar via
     `Application.Run "CT2_ExecutarSmokeRapido"` etc. e validar
     estado pós (sheet atualizada, AUDIT_LOG, etc.).
   - **Não é exatamente "clicar OK no InputBox"** — é exercitar o
     handler que o InputBox dispara, num modo automatizado.
   - **Justificativa**: a Central V2 é só um dispatcher de
     opção→handler; testar o dispatcher manualmente (operador
     clicar 14 vezes) seria absurdo. A Frente 1 implementa a
     suíte que valida que cada opção do dispatcher chama o
     handler correto.

2. **Forms operacionais (não Central) — testes UI verdadeiros:**
   - Helper `TUI_AcionarBotao(formName, btnName)` abre form
     `frm.Show vbModeless` + chama
     `Application.Run "<FormName>.<btn>_Click"`.
   - Helper `TUI_PreencherCampo(formName, ctrlName, valor)` define
     valor de textbox/combobox antes do clique.
   - Cobertura: cada handler `*_Click()` de cada form
     operacional tem cenário UI mínimo verificando que o efeito
     esperado aconteceu (sheet atualizada, AUDIT_LOG registrou,
     mensagem retornada).
   - **Aderência à regra de negócio:** se a regra diz "ao
     inativar empresa, status muda para INATIVA + AUDIT_LOG
     registra evento DESATIVACAO", o teste UI clica `B_Inativar`
     e valida AUDIT_LOG.

3. **Suite `TV2_RunUiCobertura`:**
   - Cobertura mínima: 1 cenário UI por handler `*_Click()` de
     cada form operacional.
   - Cenários `UI_<form>_<handler>_<NNN>`.
   - Reusa fixtures dos cenários V1/V2 existentes (mesmo cenário,
     mas exercitado via UI em vez de chamada direta de Sub).

4. **Suite `TV2_RunUiCentralV2`:**
   - 1 cenário por opção da Central V2.
   - Verifica que `Application.Run "CT2_ExecutarX"` retorna sem
     erro + atualizou alguma sheet/log esperado.

5. **Aderência V1↔UI e V2↔UI:**
   - Para cada teste V1 (Bateria Oficial): existe versão UI que
     dispara via interface (clicando opção `[1]` da Central V12
     e validando que `BO_RodarBateriaOficial` rodou OK).
   - Para cada teste V2 (Smoke, Canonica, Strikes, etc.): idem.
   - Resultado: dupla validação — código + interface — todas
     passam, prova que UI está aderente à regra de negócio.

## 4. Constraints inegociáveis (mantidos)

C1-C10 da v1 valem integralmente:

- **C1** — Regra de Ouro 0002 (vba_import canônico)
- **C2** — G6 enforced (sem código VBA inline em chat)
- **C3** — L14 pre-flight
- **C4** — `Mod_Types.bas` TABU
- **C5** — Drift G7 D1 preservado
- **C6** — Heurística zero é objetivo do projeto; **nesta onda
  apenas eliminamos heurística residual em `Altera_Empresa.frm`
  + estendemos padrão Empresa↔Entidade aos filtros**; outros forms
  ficam intocados estruturalmente
- **C7** — Quarteto Mínimo continua passando após cada microdelta
- **C8** — License split TPGL (Credenciamento) vs AGPLv3 (usehbn)
- **C9** — Markers HBN V2 declarados por microdelta
- **C10** — Importador V3 + manifesto MICRO

## 5. Leituras obrigatórias (com paths absolutos)

### Tier 1 — fundação canônica

1. `AGENTS.md`
2. `.hbn/knowledge/0001-regras-v203-inegociaveis.md` (regra #3)
3. `.hbn/knowledge/0002-regra-ouro-vba-import.md`
4. `.hbn/knowledge/0003-glasswing-style-preventive-security.md`
5. `.hbn/knowledge/0005-protocolo-markers-v2.md`

### Tier 2 — estado da Onda 11 (closure rc1)

6. `auditoria/03_ondas/onda_11_v203_rc1_closure/70_FECHAMENTO_ONDA_11.md`
7. `auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md`
8. `.hbn/results/0011-exec-onda11.json`
9. `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` (L1-L18 + M1-M7)

### Tier 3 — código atual a refatorar

10. `local-ai/vba_import/001-modulo/AAZ-Central_Testes.bas` (Central V12)
11. `local-ai/vba_import/001-modulo/ABE-Central_Testes_V2.bas` (Central V2 canônica)
12. `src/vba/Central_Testes_V2.bas` (drift D1)
13. `local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas`
14. `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas`
15. `local-ai/vba_import/001-modulo/ABA-Teste_Bateria_Oficial.bas`
16. `local-ai/vba_import/001-modulo/ABH-Teste_Validacao_Release.bas`
17. `local-ai/vba_import/001-modulo/ABD-Teste_UI_Guiado.bas`
18. **`src/vba/Altera_Empresa.frm`** (modelo com heurística residual a limpar)
19. **`src/vba/Altera_Entidade.frm`** (modelo limpo a estender)
20. Os outros 11 forms em `src/vba/*.frm` (escaneados para inventário
    de filtros; sem refatoração estrutural)

### Tier 4 — specs e roadmap

21. `auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md`
22. `auditoria/00_status/36_SPEC_DT6_Validacao_UI_Configuracao_V12_0204.md`
23. `auditoria/00_status/27_ROADMAP_REINCORPORACAO_INCREMENTAL_V203.md`
24. `auditoria/03_ondas/onda_12_cnae_prorrogada/00_PRORROGACAO.md`

## 6. Microdeltas esperados na v4 (esqueleto sugerido)

| MD | Tema | Esforço | Gate | Colaborativo? |
|---|---|---|---|---|
| MD-16.1 | Texto Central V12 (atalho `[3]` Quarteto) + Central V2 reorganizada | 1h IA + 0.3h Op | Quarteto verde + visual OK | Não |
| MD-16.2 | Coluna `DURACAO_MS` + threshold em CONFIG | 1h IA + 0.3h Op | Quarteto verde | Não |
| MD-16.3 | Aba `EVOLUCAO_TESTES` + sparkline + opção `[21]` | 1.5h IA + 0.5h Op | Quarteto verde + sparkline visível | Não |
| MD-16.4 | `Util_PDF.bas` com nome humano-legível + emissão automática + suite `TV2_RunPdfDeterminismo` + opção `[22]` + sheet `RPT_PDFS_GERADOS` | 2.5h IA + 0.5h Op | Quarteto verde + PDF gerado deterministicamente | Não |
| MD-16.5 | Filtros Fase 1 — confirmar/refinar padrão Empresa↔Entidade + inventário forms com filtros + ordem de revisão | 1h IA + 0.3h Op | Tabela canônica entregue | Sim (operador valida) |
| **MD-16.6** | **Filtros Fase 2 — limpar heurística residual em `Altera_Empresa.frm` (sem mexer layout) + estender padrão tela-a-tela com prints** | 1h IA × N telas / 0.5h Op × N | Quarteto verde + filtro idempotente após cada tela | **Sim — interativo** |
| MD-16.7 | Suite `TV2_RunUiCentralV2` (todas as opções da Central V2 acionadas via `Application.Run`) | 1.5h IA + 0.5h Op | Quarteto verde + suite passa 100% | Não |
| MD-16.8 | Suite `TV2_RunUiCobertura` (1 cenário UI por handler `*_Click()` em forms operacionais) | 3h IA + 1h Op | Quarteto verde + suite passa cobertura mínima | Parcial |
| MD-16.9 | Bump v12.0.0203-rc2 + CHANGELOG + L19+L20+L21 em PHAGOCYTOSIS + ERP `0012-exec-onda16.json` + `70_FECHAMENTO_ONDA_16.md` | 1h IA + 0.3h Op | Quarteto verde + tag `v12.0.0203-rc2` | Não |

Esforço total estimado: **~12.5h IA + ~3.7h operador (não
colaborativo)** + **MD-16.6 colaborativo proporcional ao número de
telas com filtros** (~5 telas × 1h IA + 0.5h Op = 5h IA + 2.5h Op
adicionais) + **MD-16.8 cobertura forms** (~3h IA + 1h Op).

**Total geral:** ~20.5h IA + ~7h operador (com colaborativos).

## 7. Lições novas esperadas (PHAGOCYTOSIS L19+L20+L21)

- **L19** — Menu de testes deve ter clareza categórica: gates de
  release destacados, suites, visualização, utilitários, com
  tempo estimado por opção.
- **L20** — PDF como fixture determinística com nome humano-legível
  (TIPO_ENTIDADE_DATA), hash de payload no metadata interno
  (rodapé) — não no nome do arquivo. Permite operador localizar
  PDF visualmente sem abrir.
- **L21** — Estender padrão existente vs criar nova convenção. Quando
  operador já tem padrão emergente (`Altera_Entidade.frm` como
  modelo limpo, `Altera_Empresa.frm` com dívida residual), a IA
  deve **detectar o padrão**, **propor consolidação**, e **estender
  cirurgicamente** — não reinventar. Custo de adoção é menor; a
  IA respeita decisões de design já tomadas.

## 8. Marcadores HBN V2 ativos nesta v4

- 🔵 HBN HANDOFF READY
- 🟣 HBN PEER REVIEW REQUESTED
- ⚪ HBN AUDIT-ONLY (Antigravity em modo audit-only)
- 🟡 HBN NEEDS HUMAN DECISION (Q1-QN ao operador)
- 🟤 HBN LICENSE SPLIT REQUIRED

## 9. O que NÃO fazer na v4

- ❌ Não criar novo form (`CentralTestes_Painel.frm` continua
  cancelado)
- ❌ Não propor refatoração estrutural completa de 13 forms
  (heurística zero ampla fica para futura onda)
- ❌ Não usar OCR para validar PDF (decisão (a) da v1: bytes +
  metadata hash)
- ❌ Não usar opção numérica ocupada no drift D1 (`[15]-[19]` no
  src/vba). Use `[21]+`
- ❌ Não tocar em `Mod_Types.bas`
- ❌ Não invalidar rc1 publicada (rc1 fica; rc2 é avanço)
- ❌ Não inventar nova convenção de nomes para filtros — **estender
  o padrão Empresa↔Entidade que já está em uso**
- ❌ Não incluir hash no nome do arquivo PDF — hash vai em metadata
  interno

## 10. O que SIM fazer na v4

- ✅ Cite arquivos com path absoluto + linha
- ✅ Use tabelas Markdown
- ✅ Diagramas Mermaid permitidos
- ✅ Pseudocódigo permitido (G6 enforced)
- ✅ Liste perguntas em aberto como Q1-QN
- ✅ Estime esforço por microdelta
- ✅ **Plano colaborativo de MD-16.6** com formato:
  "1 print do operador → análise + proposta IA → ajuste IA →
  Quarteto verde → próxima tela"
- ✅ **Detectar e estender padrão existente** (não inventar)
- ✅ Diferenciar Central V12 / Transição da Central V2
- ✅ Destacar Quarteto como gate oficial em ambas
- ✅ Cobertura UI: 1 cenário por handler `*_Click()` de cada form
- ✅ Reusar fixtures V1/V2 existentes para suites UI

## 11. Resultado esperado

Documento Markdown único (10 seções + 3 apêndices). Após v4:

1. Operador valida + responde Q1-QN.
2. Operador entrega proposta + hearback à Frente 1.
3. Frente 1 gera readback `0012-onda16-testes-refatoracao.json`.
4. Frente 1 implementa MDs 16.1-16.4 + 16.7 + 16.8 + 16.9 em
   iteração longa (~12h IA).
5. MD-16.5 + MD-16.6 (filtros tela-a-tela) é colaborativo —
   operador entrega prints e Frente 1 valida 1 a 1.
6. MD-16.8 (cobertura UI forms) tem componente colaborativo
   parcial.
7. Onda 16 fecha com tag git `v12.0.0203-rc2` ou `v12.0.0204-base`,
   conforme decisão final do operador no fechamento.

## 12. Begin v4

Não responda com placeholder. Responda com a proposta v4 completa,
seções 0-10 + apêndices A-C, em uma única passada. Se algum
documento Tier 1-4 ainda não for acessível, declare como `🟠 SOURCE
NOT REACHED` no início.

A qualidade da v4 vai determinar se Frente 1 implementa em
iteração longa imediata. Vamos para v4 ser final.

— Frente 1 Credenciamento (Claude Opus 4.7 Cowork), 2026-05-02
