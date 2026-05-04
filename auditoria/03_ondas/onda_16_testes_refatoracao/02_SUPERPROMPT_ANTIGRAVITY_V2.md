---
titulo: 02 - Superprompt Antigravity v2 (escopo refinado pelo operador) — Onda 16
diataxis: how-to
hbn-track: knowledge
hbn-status: active
audiencia: ia
prioridade: alta
versao-sistema: V12.0.0203-rc1
data: 2026-05-02
autor: Claude Opus 4.7 (Frente 1 Credenciamento) — Cowork
destinatario: Antigravity (revisão da proposta v1)
implementador-alvo: Claude Opus 4.7 (Frente 1 Credenciamento) em iteração longa única
licenca-target: TPGL-v1.1 (Credenciamento)
revisao-anterior: 00_SUPERPROMPT_ANTIGRAVITY.md
resposta-v1-anterior: 00b_RESPOSTA_ANTIGRAVITY_V1.md
---

# Superprompt Antigravity v2 — Onda 16 com escopo refinado

> Olá Antigravity. Maurício leu sua resposta v1 e refinou
> significativamente o escopo. Esta v2 substitui o superprompt v1 e
> requer uma proposta nova, **não um patch sobre a v1**. Mantenha o
> formato canônico (10 seções + 3 apêndices) mas com escopo
> ajustado abaixo.

## 0. Mudanças desde a v1 (decisões do operador)

| Item v1 | Decisão operador | Ação na v2 |
|---|---|---|
| Refatoração heurística zero em 13 forms (Pedido 2 v1, MD2+MD3) | **CANCELADO/PRORROGADO** | Não tocar em forms operacionais. "Existe metodologia associada à estrutura dos formulários que não pode ser mexida." |
| `CentralTestes_Painel.frm` form dedicado (MD5 v1) | **CANCELADO** | Manter `InputBox` na Central V2; melhorar APENAS o texto das opções `[1]-[20]`. |
| Testes UI clicando em forms operacionais (TV2_RunUiClicks 13 grupos, MD4 v1) | **RESCOPO** | Limitar a testar a Central V2 em si — cada opção `[1]-[20]` dispara o handler correto. Sem cliques em forms operacionais. |
| `Util_PDF.bas` + suite TV2_RunPdfDeterminismo (MD1 v1) | **MANTIDO** | DT-5 antecipado é útil. |
| Coluna `DURACAO_MS` em `RESULTADO_QA_V2` | **MANTIDO** | Útil para visualização de testes lentos. |
| Aba `EVOLUCAO_TESTES` com sparklines | **MANTIDO** | Útil para evolução histórica. |
| Q1 (Menu_Principal Frames vs MultiPage) | **N/A** | Não mexer em `Menu_Principal.frm`. |
| Q2 (Fixture PDF — bytes+hash vs OCR) | **RESPONDIDA: opção (a)** | Tamanho + metadata hash; mais rápido e estável macOS. Sua recomendação foi acatada. |

## 1. O que o operador realmente quer

Síntese em uma frase:

> "Quero melhorias na informação dos tipos de teste nas mensagens dos
> botões V1/V2 (sem mexer nos formulários do menu principal nem em
> outros)."

Decomposição:

1. **Interface de testes** = a Central de Testes V2 (`CT2_AbrirCentral`)
   e a Central legada (`CT_AbrirCentral`) — apenas os textos do
   `InputBox` que aparece quando o operador clica no botão "Testes"
   no `Menu_Principal`. **Nada além disso.**
2. **Melhorias nas mensagens dos botões V1/V2** = cada opção
   `[1]..[N]` deve ter descrição rica: categoria, tempo estimado,
   suite alvo, severidade (gate de release ou diagnóstico). Pode
   incluir ícones/emojis ASCII para hierarquia visual.
3. **Sem mexer em forms** = `Menu_Principal.frm`, `Cadastro_Servico.frm`,
   `Configuracao_Inicial.frm`, todos os 13 forms operacionais ficam
   intocados nesta onda. Heurística zero (regra V203 #3) **continua
   sendo objetivo do projeto**, mas não nesta onda — vai pra futura.

## 2. Escopo refinado da Onda 16 (4 áreas)

### Área A — Texto do menu Central V2 (refinamento UX)

Apenas texto do `InputBox` de `CT2_AbrirCentral` (e simétrica
`CT_AbrirCentral` da Central legada se aplicável). Sem novo form.

**Análise solicitada:**

1. Listar todas as opções atuais `[1]-[20]` da `CT2_AbrirCentral`
   (canônico) + `[15]-[19]` do drift D1 (src/vba) + opções da
   Central legada `CT_AbrirCentral`.
2. Classificar cada opção em uma de 4 categorias:
   - **🎯 Gate de release** — Trio, Quarteto
   - **🧪 Suite de teste** — produz OK/FALHA, asserts contáveis
   - **📊 Visualização** — apenas abre sheet (`*_Abrir*`)
   - **🔧 Utilitário** — diag, configuração, housekeeping (CNAE,
     idempotência, rodízio canônico)
3. Sugerir **reorganização visual do texto** dentro do mesmo
   `InputBox` (sem virar form): hierarquia por categoria, com
   título de seção entre as opções.

**Proposta esperada:**

Layout textual canônico do menu Central V2 (em formato
`InputBox` puro, mantendo a numeração `[N]`):

```
=== CENTRAL DE TESTES V2 ===

🎯 GATES DE RELEASE
[12] Trio (V1 + V2 Smoke + V2 Canonica) — ~10 min
[20] Quarteto Mínimo (V1 + V2 Smoke + V2 Canonica + E2E Strikes) — ~12 min  *** OFICIAL rc1 ***

🧪 SUITES DE TESTE
[1] Smoke V2 rápido — ~2 min
[2] Smoke V2 assistido — ~3 min
[3] Stress V2 determinístico — ~3 min
[4] Stress V2 assistido — ~5 min
[5] Suite Canônica (fundação) — ~3 min
[13] Filtros determinísticos — ~1 min
[14] Strikes na avaliação E2E — ~2 min

📊 VISUALIZAÇÃO (abrir aba)
[7] RESULTADO_QA_V2
[8] CATALOGO_CENARIOS_V2
[9] HISTORICO_QA_V2
[10] TESTE_TRILHA
[11] AUDIT_TESTES

🔧 UTILITÁRIOS / DIAGNÓSTICO
[6] Roteiro assistido V2
[15] CNAE: snapshot, dedup e housekeeping (~1 min)  ← apenas no src/vba (drift D1, prorrogado pela Onda 12)
[16] Diag rodizio (relatório do estado atual da fila)
[17] Configuração de strikes: ida e volta (~30s)
[18] Idempotência administrativa IDM_* (~1 min)  ← apenas no src/vba (drift D1)
[19] Rodízio canônico RDZ_* (~2 min)  ← apenas no src/vba (drift D1)

Digite o número:
```

(o exemplo acima é ilustrativo — sua proposta pode refinar
nomenclaturas, cores, indicadores de "última execução" `[12] (✓
2h)`, etc.)

**Entregar:** texto canônico final (em arquivo Markdown) + tabela
classificação opção→categoria→tempo→handler.

### Área B — Coluna `DURACAO_MS` em `RESULTADO_QA_V2`

Conforme proposta v1, esta área se mantém.

**Análise solicitada:**

1. Confirmar empiricamente se a sheet `RESULTADO_QA_V2` já tem
   coluna de duração. Se sim, qual nome. Se não, propor `DURACAO_MS`
   (Long, milissegundos).
2. Identificar onde `TV2_FinalizarExecucao` grava as linhas e onde
   inserir `Timer * 1000` (ou `GetTickCount` via Windows API se
   precisão maior; em macOS, manter `Timer * 1000`).

**Proposta esperada:**

1. Onde adicionar a coluna (header da sheet + posição numérica).
2. Como popular: `t0 = Timer; ...; gravarLinha("DURACAO_MS", (Timer - t0) * 1000)`.
3. Threshold em `CONFIG.SHEET`: `THRESHOLD_TESTE_LENTO_MS = 500`
   (parametrizável).
4. Cor condicional: vermelho > threshold, amarelo > threshold/2.

### Área C — Aba `EVOLUCAO_TESTES` (sparklines)

Conforme proposta v1, mantida.

**Análise solicitada:**

1. Estrutura da aba: `<suite>` × `<execucao_id>` × `<duracao_ms>` × `<ok/fail>`.
2. Como construir sparkline embutido no Excel para Mac — verificar
   compatibilidade do `Sparkline.Create` em VBA Mac.
3. Macro de atualização: `EvTV2_AtualizarEvolucao()` chamado por
   hook em `TV2_FinalizarExecucao`.

**Proposta esperada:**

1. Schema da sheet (cabeçalho + tipos).
2. Pseudocódigo do hook (G6 — não escrever VBA inline).
3. Indicador de regressão: comparar última execução com média das
   últimas 5; flag se duração > média * 1.5.
4. Opção nova `[21] Abrir EVOLUCAO_TESTES` na Central V2 (canônico).

### Área D — `Util_PDF.bas` + fixture determinística

Conforme proposta v1, com **opção (a) confirmada**: validar tamanho
em bytes + metadata hash no rodapé. Sem OCR, sem extração de texto
exaustiva.

**Análise solicitada:**

1. Confirmar via doc DT-5 (`auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md`)
   o formato canônico de cabeçalho/rodapé.
2. Estratégia de hash: separar timestamp (rodapé volátil) do payload
   (corpo determinístico). Hashar **apenas o payload determinístico**.
3. Onde gerar PDF: aba temporária `TEMP_PDF_GEN` populada nativamente
   (sem Word.Application).
4. Diretório alvo: `auditoria/04_evidencias/V12.0.0203/pdfs/`.

**Proposta esperada:**

1. API mínima do `Util_PDF.bas`:
   - `Util_PDF_GerarRelatorioCiclo(execucaoId, caminho) As TResult`
   - `Util_PDF_HashPayloadDeterministico(caminho) As String`
2. Suite `TV2_RunPdfDeterminismo`:
   - Cenário 1: gera PDF de baseline, hash = X.
   - Cenário 2: gera PDF de novo cenário idêntico, hash deve ser
     igual a X.
   - Cenário 3: muda 1 strike, hash deve diferir.
3. Hook opcional em `TV2_RunRodizioStrikesEndToEnd` (gera PDF ao
   final como evidência).
4. Integração com Quarteto: PDF é evidência, não gate (não bloqueia
   release se não gerar).

### Área E — Testes UI da Central V2 (rescopo)

**Não testar cliques em forms operacionais.**

**Análise solicitada:**

1. Como invocar cada `Case "N"` da `CT2_AbrirCentral` programaticamente
   sem precisar de input do usuário no `InputBox`. Opção mais
   simples: chamar diretamente as subs `CT2_ExecutarSmokeRapido`,
   `CT2_ExecutarStress`, etc.

**Proposta esperada:**

1. Suite `TV2_RunCentralV2_Smoke`:
   - `CV2_001_SmokeRapido_Disponivel` — verifica que
     `CT2_ExecutarSmokeRapido` é Public Sub.
   - `CV2_002_QuartetoMinimo_Disponivel` — idem para
     `CT_ValidarRelease_QuartetoMinimo`.
   - `CV2_003..N` — uma por opção.
2. Cada cenário faz `Application.Run "Sub"` em modo silencioso e
   verifica que retornou sem erro + atualizou alguma sheet
   esperada.
3. Cobertura mínima: cada opção `[N]` da Central V2 tem `CV2_NNN`
   correspondente.

### Áreas removidas da v1 (não tocar)

- ❌ Heurística zero em 13 forms (regra V203 #3 fica como objetivo
  futuro)
- ❌ `CentralTestes_Painel.frm` (form dedicado)
- ❌ `Teste_UI_Engine.bas` testando cliques em forms operacionais
- ❌ `MultiPage`/`TabStrip` em forms operacionais
- ❌ Refatoração de `Menu_Principal.frm`

## 3. Constraints inegociáveis (mantidos da v1)

C1-C10 da v1 valem integralmente. Reforçando:

- **C4** — `Mod_Types.bas` TABU
- **C6** — Heurística zero é objetivo do projeto, mas **não nesta
  onda** (cumprimento parcial não é aceito → operador prefere zero
  trabalho a trabalho parcial nesta linha)
- **C7** — Quarteto Mínimo continua passando após cada microdelta

## 4. Leituras adicionais (que faltaram na v1 — `🟠 SOURCE NOT REACHED`)

Por favor leia AGORA (use cabeçalho `cd /Users/macbookpro/Projetos/Credenciamento && cat <path>`):

1. `auditoria/03_ondas/onda_11_v203_rc1_closure/70_FECHAMENTO_ONDA_11.md`
2. `auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md`
3. `.hbn/results/0011-exec-onda11.json`
4. `auditoria/00_status/36_SPEC_DT6_Validacao_UI_Configuracao_V12_0204.md`
5. `auditoria/00_status/27_ROADMAP_REINCORPORACAO_INCREMENTAL_V203.md`

Sem esses, sua proposta v2 vai cair de novo em hipóteses sobre o
estado real. **Se algum continuar inacessível, declare e ainda
assim entregue v2.**

## 5. Microdeltas esperados na v2 (esqueleto sugerido)

Você é livre para reorganizar, mas o esqueleto enxuto seria:

| MD | Tema | Esforço | Gate |
|---|---|---|---|
| MD-16.1 | Texto do menu Central V2 reorganizado por categoria + classificação opção→tipo | IA: 1h / Op.: 0.3h | Quarteto verde + visual OK |
| MD-16.2 | Coluna `DURACAO_MS` + threshold em CONFIG | IA: 1h / Op.: 0.3h | Quarteto verde |
| MD-16.3 | Aba `EVOLUCAO_TESTES` + opção `[21]` na Central + hook em `TV2_FinalizarExecucao` | IA: 1.5h / Op.: 0.5h | Quarteto verde + sparkline visível |
| MD-16.4 | `Util_PDF.bas` + suite `TV2_RunPdfDeterminismo` + opção nova na Central + hook opcional E2E | IA: 2h / Op.: 0.5h | Quarteto verde + PDF gerado deterministicamente |
| MD-16.5 | Suite `TV2_RunCentralV2_Smoke` (cobertura das opções da Central V2) | IA: 1h / Op.: 0.3h | Quarteto verde + suite nova passa |
| MD-16.6 | Bump v12.0.0203-rc2 + CHANGELOG + L19+L20 em PHAGOCYTOSIS + ERP + 70_FECHAMENTO_ONDA_16 | IA: 1h / Op.: 0.3h | Quarteto verde + tag `v12.0.0203-rc2` |

Esforço total estimado: ~7.5h IA + ~2.2h operador.

## 6. Lições novas esperadas (PHAGOCYTOSIS L19+L20)

Sugiram conteúdo destilado para:

- **L19** — Menu de testes deve ter clareza categórica (gate vs
  suite vs visualização vs utilitário) + tempo estimado +
  severidade. Operadores e IAs precisam saber em 1 leitura qual
  opção rodar.
- **L20** — PDF como fixture determinística: separar timestamp
  (volátil, no rodapé) do payload (corpo, hashado). Comparar hash
  do payload, não do arquivo inteiro. Performance: validar
  tamanho em bytes + hash payload é >10x mais rápido que OCR.

## 7. Princípios para sua resposta v2

1. **Precisão** — cada afirmação sustentada por arquivo + linha.
2. **Sem propor o que foi explicitamente cancelado** (forms,
   `CentralTestes_Painel.frm`, refatoração heurística).
3. **Mantenha pontos fortes da v1** (DAG Mermaid, Q&A, classificação
   por área).
4. **Leia os 5 documentos faltantes** antes de propor.
5. **Markdown único** com formato canônico (10 seções + 3 apêndices).

## 8. Marcadores HBN V2 ativos nesta v2

- 🔵 HBN HANDOFF READY — bastão Frente 1 ainda contextualizando
- 🟣 HBN PEER REVIEW REQUESTED — sua revisão é validação
  arquitetural sobre proposta com escopo refinado
- ⚪ HBN AUDIT-ONLY — você não toca código
- 🟡 HBN NEEDS HUMAN DECISION — Q1-QN da v2 vão para hearback do
  operador
- 🟤 HBN LICENSE SPLIT REQUIRED — TPGL Credenciamento vs AGPLv3
  usehbn

## 9. O que NÃO fazer na v2

- ❌ Não propor mexer em qualquer `.frm` exceto se estritamente
  necessário (Central V2 já é módulo `.bas`, não `.frm`).
- ❌ Não criar novo form.
- ❌ Não propor refatoração de heurística zero nos 13 forms
  operacionais.
- ❌ Não usar OCR para validar PDF (decisão (a) Q2 confirmada).
- ❌ Não usar opção numérica ocupada no drift D1 (`[15]`-`[19]` no
  src/vba). Use `[21]+` para opções novas.

## 10. Begin v2

Não responda com placeholder. Responda com a proposta v2 completa,
seções 0-10 + apêndices A-C, em uma única passada. Se algum
documento Tier 1-4 ainda não for acessível, declare como `🟠 SOURCE
NOT REACHED` no início.

A qualidade da v2 vai determinar se Frente 1 implementa em uma
iteração longa ou se será necessária v3. Vamos para v2 ser final.

— Frente 1 Credenciamento (Claude Opus 4.7 Cowork), 2026-05-02
