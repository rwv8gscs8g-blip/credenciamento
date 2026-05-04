---
titulo: 03 - Superprompt Antigravity v3 (escopo mais maduro pelo operador) — Onda 16
diataxis: how-to
hbn-track: knowledge
hbn-status: active
audiencia: ia
prioridade: alta
versao-sistema: V12.0.0203-rc1 (alvo da onda 16 = rc2 ou V12.0.0204-base)
data: 2026-05-02
autor: Claude Opus 4.7 (Frente 1 Credenciamento) — Cowork
destinatario: Antigravity (revisão final esperada — v3)
implementador-alvo: Claude Opus 4.7 (Frente 1 Credenciamento) em iteração longa única + microdelta colaborativo de filtros
licenca-target: TPGL-v1.1 (Credenciamento)
revisao-anterior-v1: 00_SUPERPROMPT_ANTIGRAVITY.md (cancelada)
revisao-anterior-v2: 02_SUPERPROMPT_ANTIGRAVITY_V2.md (cancelada após decisões mais maduras do operador)
resposta-v1-arquivada: 00b_RESPOSTA_ANTIGRAVITY_V1.md
---

# Superprompt Antigravity v3 — Onda 16 com escopo final

> Olá Antigravity. Maurício amadureceu mais o escopo após revisar a
> v2. Esta v3 é a versão final do prompt — substitui v1 e v2.
> Mantenha o formato canônico (10 seções + 3 apêndices) mas com
> escopo ajustado abaixo. **A v2 fica arquivada — não é base
> incremental.**

## 0. Mudanças desde a v2 (decisões finais do operador)

| Item v2 | Decisão final v3 | Ação |
|---|---|---|
| Heurística zero em 13 forms | **Continua canceladO** | Sem refatoração estrutural de forms |
| Padronização de filtros (sub-tema da heurística) | **NOVO escopo cirúrgico** | Operador colabora com prints; não toca estrutura, apenas garante que filtros são chamados pelo nome canônico do comando, não por dedução |
| Central V12 / Transição (`CT_AbrirCentral`) | **NOVO escopo** | v2 falava só da Central V2; agora inclui também a V12 / Transição (entry point com [1] Bateria V1 + [2] Abrir Central V2) |
| Central V2 — texto reorganizado por categoria | **MANTIDO** | + destacar `[20] Quarteto` como validação oficial de release |
| `Util_PDF.bas` — geração de PDF | **AMPLIADO** | + emissão automática durante testes + **nomeação semântica por entidade** (PRE_OS, OS, Avaliação) |
| Testes UI da Central V2 | **AMPLIADO** | + após padronização de filtros, viabilizar testes via interface clicando nos botões dos forms operacionais (mas sem refatorar a estrutura dos forms) |
| Coluna `DURACAO_MS` | **MANTIDO** | Sem mudanças |
| Aba `EVOLUCAO_TESTES` + sparkline | **MANTIDO** | Sem mudanças |
| Form dedicado `CentralTestes_Painel.frm` | **CONTINUA CANCELADO** | InputBox sempre |
| Q2 fixture PDF | **CONFIRMADO opção (a)** | bytes + metadata hash |

## 1. O que o operador quer com clareza máxima

Frase canônica do operador (2026-05-02 segunda iteração):

> "(1) A parte do formulários não é para mexer, mas eu quero
> revisar todos os filtros, para garantir que os filtros sejam
> chamados diretamente pelo nome do comando na interface, e não
> por dedução, então quero que ele planeje passarmos em todas as
> telas que possuem filtros e façamos essa validação, comigo
> mostrando o print da tela com o nome da interface, padronizamos
> o nome e ajustamos o código para funcionar de maneira
> idempotente. (2) Na central de testes eu quero uma proposta de
> revisão e melhoria das mensagens que aparecem no botão, veja
> imagem e que apareça o item do quarteto como validação. (3) A
> parte da Util_pdf.bas mantido. Um sistema de emissão automática
> para que possamos fazer os testes com o resultado auditável.
> Cada pdf já deve sair com o nome da pre_os, OS, ou da avaliação
> a que ele diga respeito. (4) Uma proposta de efetuarmos os
> testes clicando via interface."

Decomposição em 4 áreas + 1 colaborativa:

### Área F (NOVA, colaborativa) — Padronização de filtros via nome canônico

**Não é refatoração estrutural.** É um trabalho cirúrgico:

1. Inventariar todas as telas que possuem filtros (combobox de
   filtro, textbox de busca, listbox filtrável).
2. Para cada filtro: garantir que é acessado pelo **nome do
   comando** na interface (canônico), não por dedução heurística
   (`InStr(.Caption)`, `Controls(nome variável)`,
   posicionamento `.Top`/`.Left`).
3. Plano de execução **colaborativo**:
   - Para cada tela: operador tira print (mostra nome dos
     controles na UI real)
   - Antigravity propõe nome canônico padronizado
     (ex.: `cmb_filtro_<entidade>`, `txt_busca_<entidade>`,
     `lst_resultados_<entidade>`)
   - Frente 1 ajusta apenas o nome no código (sem mexer no
     designer do form se possível) **OU** instrui operador a
     renomear no designer manualmente, conforme o caso
   - Idempotência: rodar 1x ou Nx produz mesmo estado
4. **Forms operacionais NÃO sofrem refatoração de estrutura.**
   Apenas o ponto 2 acima — garantir filtro chamado pelo nome.

**Análise solicitada:**

1. Identificar quais dos 13 forms têm filtros (textbox/combobox/
   listbox).
2. Detectar uso atual: filtro chamado por nome canônico ou por
   dedução heurística?
3. Propor convenção de nomes:
   - `cmb_filtro_<entidade>` — combobox de filtro
   - `txt_busca_<entidade>` — textbox de busca livre
   - `lst_resultados_<entidade>` — listbox de resultados
   - `cmd_aplicar_filtro_<entidade>` — botão aplicar
   - `cmd_limpar_filtro_<entidade>` — botão limpar
4. Ordem proposta de revisão (do mais simples ao mais complexo).
5. Para cada filtro: bateria mínima de teste idempotente
   (rodar filtro com critério X 1x, depois Nx; resultado deve
   ser idêntico).

**Entregar:**

- Tabela form-a-form: {tem_filtros?, filtros_atuais, heurística_detectada,
  nome_canônico_proposto}.
- Plano colaborativo em N rodadas (1 print por tela).
- Esforço estimado por tela.

### Área A — Texto da Central V12 (Transição) + Central V2

**Sem novo form. InputBox apenas.** Texto refinado.

#### A.1 — Central V12 / Transição (`CT_AbrirCentral` em `AAZ-Central_Testes.bas`)

Atualmente:

```
=== CENTRAL DE TESTES V12 / TRANSICAO ===

[1] Executar Bateria Oficial V1 (rapida ~5 min / assistida ~8 min)
[2] Abrir Central de Testes V2
```

**Análise solicitada:**

1. Esse menu é o entry point — o que o operador clica primeiro
   para chegar nas suites.
2. Ausências: não menciona Quarteto como gate oficial de release.
3. Proposta: enriquecer descrição de cada opção com categoria
   (Legado V1 vs Centralizado V2), dar destaque para o Quarteto
   como gate canônico de release rc1.

**Proposta esperada:**

Texto refinado em InputBox que inclua:
- Cabeçalho V12 / Transição mais claro (origem dos testes V1
  legados em transição para V2)
- Indicador de qual é o gate oficial (Quarteto via Central V2 →
  opção [20])
- Tempo estimado por opção
- Possivelmente um atalho `[3] Quarteto Direto` que vai direto
  para `CT_ValidarRelease_QuartetoMinimo` sem passar por Central V2

#### A.2 — Central V2 (`CT2_AbrirCentral` em `ABE-Central_Testes_V2.bas`)

Atualmente (canônico, V12.0.0203-rc1 importado):

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

(Notar que a imagem capturada pelo operador para esta v3 é da
versão SEM `[20]` ainda visível — pode ser print pré-import ou da
src/vba. O canônico V12.0.0203-rc1 publicado tem `[20]`.)

**Análise solicitada:**

1. Confirmar que `[20]` está visível no canônico após import
   MICRO11+MICRO12.
2. Reorganizar hierarquicamente em categorias dentro do mesmo
   InputBox.
3. Destacar `[20] Quarteto` como **gate oficial de release**
   (ex.: marcar com `***` ou `>>> OFICIAL <<<`).
4. Diferenciar "executar teste" de "abrir aba".

**Proposta esperada:**

Layout textual hierárquico no InputBox da Central V2 com:
- Cabeçalho com referência à versão (`V12.0.0203-rc1` ou
  `quarteto-2026-05-02`)
- Seção "GATES DE RELEASE" no topo, com `[12] Trio` e `[20]
  Quarteto` em destaque
- Seção "SUITES DE TESTE" com [1]-[5], [13], [14]
- Seção "VISUALIZAÇÃO" com [7]-[11]
- Seção "UTILITÁRIOS" com [6] e (no src/vba) [15]-[19]
- Indicador opcional de "última execução" por opção
  (ex.: `[20] Quarteto (✓ 6:30) ***`)

### Área B — Coluna `DURACAO_MS` em `RESULTADO_QA_V2`

(Sem mudanças vs v2 — repetir conforme v2 § 2.B)

### Área C — Aba `EVOLUCAO_TESTES` (sparklines + indicador de regressão)

(Sem mudanças vs v2 — repetir conforme v2 § 2.C)

### Área D — `Util_PDF.bas` AMPLIADO (emissão automática + nomeação semântica)

**Mudança chave vs v2**: PDFs emitidos automaticamente durante
testes E2E, **com nome semântico baseado na entidade
(PRE_OS / OS / Avaliação) que o PDF reporta**.

**Análise solicitada:**

1. Confirmar via doc DT-5 (`auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md`)
   o formato canônico de cabeçalho/rodapé.
2. Estratégia de nomeação semântica:
   - PDF de uma PRE_OS: `<EXECUCAO_ID>_PREOS_<PREOS_ID>_<TIMESTAMP>_<HASH8>.pdf`
   - PDF de uma OS:    `<EXECUCAO_ID>_OS_<OS_ID>_<TIMESTAMP>_<HASH8>.pdf`
   - PDF de uma Avaliação: `<EXECUCAO_ID>_AVAL_<OS_ID>_<TIMESTAMP>_<HASH8>.pdf`
   - PDF de ciclo completo: `<EXECUCAO_ID>_CICLO_<TIMESTAMP>_<HASH8>.pdf`
3. Hash determinístico do payload (sem timestamp) para fixture.
4. Diretório alvo: `auditoria/04_evidencias/V12.0.0203/pdfs/<EXECUCAO_ID>/`
   (subpasta por execução).

**Proposta esperada:**

1. API mínima do `Util_PDF.bas`:
   - `Util_PDF_GerarPdfPreOS(preosId, execucaoId) As String` (retorna caminho)
   - `Util_PDF_GerarPdfOS(osId, execucaoId) As String`
   - `Util_PDF_GerarPdfAvaliacao(osId, execucaoId) As String`
   - `Util_PDF_GerarPdfCiclo(execucaoId) As String`
   - `Util_PDF_HashPayloadDeterministico(caminho) As String`
2. Hook automático em testes E2E — ex.: ao final de
   `TV2_RunRodizioStrikesEndToEnd`, gerar 3 PDFs (1 por OS criada
   no ciclo) automaticamente.
3. Suite `TV2_RunPdfDeterminismo`:
   - Gerar PDF de baseline conhecido, hash = X.
   - Gerar PDF de novo cenário idêntico, hash deve = X.
   - Mudar 1 strike, hash deve diferir.
4. Resultado auditável: cada PDF tem nome falando QUAL entidade
   reporta + hash auto-validável + ligação com `EXECUCAO_ID` da
   suite que o gerou.

### Área E — Testes via interface (clicando)

**Mudança chave vs v2**: agora viabilizado por Área F (filtros
padronizados por nome canônico).

**Análise solicitada:**

1. Após Área F garantir nomes canônicos de filtros, testes UI
   podem chamar `Application.Run "FormName.cmd_aplicar_filtro_empresa_Click"`
   determinísticamente.
2. Não toca estrutura dos forms; apenas usa nomes canônicos para
   acionar handlers.
3. Não testa todos os botões dos forms (não é heurística zero
   completa) — testa apenas os fluxos onde Área F padronizou.

**Proposta esperada:**

1. Helper `Teste_UI_Engine.bas`:
   - `TUI_AcionarBotao(formName, btnName)` — abre form modeless,
     dispara handler, valida estado pós-chamada.
   - `TUI_PreencherCampo(formName, ctrlName, valor)` — define
     valor de textbox/combobox antes do clique.
2. Suite `TV2_RunUiInterface`:
   - 1 cenário por filtro padronizado em Área F.
   - Cobertura mínima: aplica filtro X, verifica que `lst_resultados_*`
     filtra; clica `cmd_limpar_filtro_*`, verifica que volta ao
     estado inicial; idempotência.
3. Cenários `UI_<form>_<filtro>_<NNN>`.
4. NÃO criar Suite `TV2_RunUiClicks` exaustiva (era v1, cancelada).
   Apenas `TV2_RunUiInterface` focada em filtros padronizados.

## 2. Constraints inegociáveis (mantidos)

C1-C10 da v1 valem integralmente.

Especialmente:

- **C4** — `Mod_Types.bas` TABU
- **C6** — Heurística zero (regra V203 #3) é objetivo do projeto
  futuro; **nesta onda só padronizamos filtros, não os 13 forms**
- **C7** — Quarteto Mínimo continua passando após cada microdelta
- **C10** — Importador V3 + manifesto MICRO

## 3. Leituras adicionais (que faltaram na v1)

Por favor leia AGORA (não pulado:

1. `auditoria/03_ondas/onda_11_v203_rc1_closure/70_FECHAMENTO_ONDA_11.md`
2. `auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md`
3. `.hbn/results/0011-exec-onda11.json`
4. `auditoria/00_status/36_SPEC_DT6_Validacao_UI_Configuracao_V12_0204.md`
5. `auditoria/00_status/27_ROADMAP_REINCORPORACAO_INCREMENTAL_V203.md`

Adicionalmente para v3:

6. `local-ai/vba_import/001-modulo/AAZ-Central_Testes.bas` — Central V12
   / Transição completa (texto + handlers).
7. `auditoria/03_ondas/onda_12_cnae_prorrogada/00_PRORROGACAO.md` —
   contexto sobre opções `[15]` CNAE no src/vba.

## 4. Microdeltas esperados na v3 (esqueleto sugerido)

Você é livre para reorganizar, mas o esqueleto enxuto seria:

| MD | Tema | Esforço | Gate | Colaborativo? |
|---|---|---|---|---|
| MD-16.1 | Texto da Central V12 (Transição) + Central V2 (`[20]` destacado, hierárquica por categoria) | IA: 1h / Op.: 0.3h | Quarteto verde + visual OK | Não |
| MD-16.2 | Coluna `DURACAO_MS` + threshold em CONFIG | IA: 1h / Op.: 0.3h | Quarteto verde | Não |
| MD-16.3 | Aba `EVOLUCAO_TESTES` + opção `[21]` na Central + hook em `TV2_FinalizarExecucao` | IA: 1.5h / Op.: 0.5h | Quarteto verde + sparkline visível | Não |
| MD-16.4 | `Util_PDF.bas` + nomeação semântica + emissão automática + suite `TV2_RunPdfDeterminismo` + opção `[22]` na Central | IA: 2.5h / Op.: 0.5h | Quarteto verde + PDF gerado deterministicamente + nomes semânticos | Não |
| MD-16.5 | Padronização de filtros — fase 1: inventário + nomenclatura canônica + ordem de revisão | IA: 1h / Op.: 0.3h | Tabela canônica entregue | Sim (operador valida tabela) |
| MD-16.6 | Padronização de filtros — fase 2: revisão tela-a-tela com prints do operador (1 print = 1 tela = 1 microdelta interno) | IA: 0.5h × N telas / Op.: 0.5h × N telas | Quarteto verde + filtro idempotente após cada tela | **Sim** — interativo |
| MD-16.7 | Suite `TV2_RunUiInterface` (testes via interface após filtros padronizados) | IA: 1.5h / Op.: 0.5h | Quarteto verde + suite nova passa | Não |
| MD-16.8 | Bump v12.0.0203-rc2 + CHANGELOG + L19+L20+L21 em PHAGOCYTOSIS + ERP `0012-exec-onda16.json` + `70_FECHAMENTO_ONDA_16.md` | IA: 1h / Op.: 0.3h | Quarteto verde + tag git `v12.0.0203-rc2` | Não |

Esforço total estimado: ~10h IA + ~3h operador, mais MD-16.6
proporcional ao número de telas com filtros (estimativa ~5 telas
× 1h = 5h adicionais).

## 5. Lições novas esperadas (PHAGOCYTOSIS L19+L20+L21)

- **L19** — Menu de testes deve ter clareza categórica (gate vs
  suite vs visualização vs utilitário) + tempo estimado +
  severidade. Operadores e IAs precisam saber em 1 leitura qual
  opção rodar.
- **L20** — PDF como fixture determinística com nomeação
  semântica: separar timestamp (volátil, no rodapé) do payload
  (corpo, hashado). Nome do arquivo carrega entidade reportada
  (PREOS_<id>, OS_<id>, AVAL_<id>) — IA + humano podem identificar
  o PDF sem abrir.
- **L21** — Padronização cirúrgica de filtros antes de testes UI.
  Filtros chamados por nome canônico + idempotência são
  pré-requisito para `TV2_RunUiInterface`. Refatorar **só os
  filtros**, não a estrutura completa dos forms — é trabalho
  pequeno de alto impacto que viabiliza camada de teste sem
  invadir metodologia preservada do designer.

## 6. Princípios para sua resposta v3

1. **Precisão > prolixidade** — cada afirmação sustentada por
   arquivo + linha.
2. **Sem propor o que foi explicitamente cancelado** (refatoração
   de 13 forms, form dedicado).
3. **Mantenha pontos fortes da v1** (DAG Mermaid, classificação
   por área).
4. **Leia os 7 documentos** (5 da v1 que faltaram + 2 novos da v3).
5. **Markdown único** com formato canônico (10 seções + 3 apêndices).
6. **Plano colaborativo** explicitamente desenhado para MD-16.6
   (trabalho tela-a-tela com prints).

## 7. Marcadores HBN V2 ativos nesta v3

- 🔵 HBN HANDOFF READY — bastão Frente 1 disponibiliza contexto
  completo
- 🟣 HBN PEER REVIEW REQUESTED — sua revisão é validação
  arquitetural sobre proposta com escopo refinado
- ⚪ HBN AUDIT-ONLY — você não toca código
- 🟡 HBN NEEDS HUMAN DECISION — Q1-QN da v3 vão para hearback do
  operador
- 🟤 HBN LICENSE SPLIT REQUIRED — TPGL Credenciamento vs AGPLv3
  usehbn

## 8. O que NÃO fazer na v3

- ❌ Não propor refatoração estrutural de 13 forms
- ❌ Não propor `CentralTestes_Painel.frm` ou form dedicado
- ❌ Não usar OCR para validar PDF (decisão (a) Q2 confirmada)
- ❌ Não propor refatoração heurística zero ampla (apenas filtros)
- ❌ Não usar opção numérica ocupada no drift D1 (`[15]`-`[19]` no
  src/vba). Use `[21]+` para opções novas
- ❌ Não tocar em `Mod_Types.bas`
- ❌ Não propor mudança de `APP_RELEASE_TAG`/`STATUS` que invalide
  rc1 publicada (rc1 fica; rc2 é avanço)

## 9. O que SIM fazer na v3

- ✅ Cite arquivos com path absoluto + linha quando possível
- ✅ Use tabelas Markdown para análise quantitativa
- ✅ Diagramas ASCII/Mermaid permitidos
- ✅ Pseudocódigo permitido
- ✅ Listar perguntas em aberto como `Q1`-`QN` para o operador
- ✅ Propor cenários de teste com nomes canônicos
- ✅ Estimar esforço por microdelta
- ✅ **Plano colaborativo de MD-16.6** com formato:
  "1 print do operador → análise + proposta IA → ajuste IA →
  Quarteto verde → próxima tela"
- ✅ Diferenciar Central V12 / Transição da Central V2
- ✅ Destacar Quarteto como gate oficial em ambas centrais

## 10. Resultado esperado

Documento Markdown único, 10 seções + 3 apêndices, formato
canônico. Após a v3:

1. Operador valida + responde Q1-QN.
2. Operador entrega resposta + hearback à Frente 1.
3. Frente 1 gera readback `0012-onda16-testes-refatoracao.json`.
4. Frente 1 implementa MDs 16.1-16.5 + 16.7 + 16.8 em iteração
   longa (~10h IA).
5. MD-16.6 (filtros tela-a-tela) é colaborativo e pode tomar
   várias sessões — operador entrega prints e Frente 1 valida 1 a 1.
6. Onda 16 fecha com tag git `v12.0.0203-rc2` ou `v12.0.0204-base`,
   conforme decisão final do operador no fechamento.

## 11. Begin v3

Não responda com placeholder. Responda com a proposta v3 completa,
seções 0-10 + apêndices A-C, em uma única passada. Se algum
documento tier 1-4 ainda não for acessível, declare como `🟠 SOURCE
NOT REACHED` no início.

A qualidade da v3 vai determinar se Frente 1 implementa em
iteração longa imediata ou se será necessária v4. Vamos para v3
ser final.

— Frente 1 Credenciamento (Claude Opus 4.7 Cowork), 2026-05-02
