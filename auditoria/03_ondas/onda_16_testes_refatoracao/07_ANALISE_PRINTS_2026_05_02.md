---
titulo: 07 - Análise dos 11 prints + plano canônico de renomeação (MD-16.6 fix3)
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203 → ONDA16.MD6-fix
data: 2026-05-02
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1 (Credenciamento)
---

# MD-16.6 fix3 — Análise dos 11 prints fornecidos pelo operador

## Contexto

Após regressão MICRO17/18 (rollback aplicado em MICRO19), o operador
disponibilizou 11 prints em
`local-ai/incoming/prints-forms/` cobrindo TODOS os forms/páginas
com TextBox de filtro selecionado + Properties panel do VBE visível.

Objetivo: identificar nome real (auto-gerado, ex.: `TextBox14`,
`TextBox16`) de cada controle de filtro, propor mapeamento canônico
e plano de renomeação manual no designer.

## Inventário dos 11 prints

| # | Timestamp | Form/Página | TextBox selecionado | Função |
|---|---|---|---|---|
| 1 | 21.38.57 | `Cadastro_Servico` | (TextBox de filtro topo direito) | Filtro de serviços |
| 2 | 21.39.11 | `Credencia_Empresa` | (TextBox de filtro topo direito) | Filtro de empresas a credenciar |
| 3 | 21.39.32 | `Menu_Principal` — aba **Entidade** | (TextBox topo direito) | Filtro `Cadastro de Entidades` |
| 4 | 21.39.39 | `Menu_Principal` — aba **Empresa** | (TextBox topo direito) | Filtro `Cadastro de Empresas` |
| 5 | 21.39.44 | `Menu_Principal` — aba **Rodízio** (Atribuição) | TextBox 1 (topo direito) | Filtro Atribuição empresa |
| 6 | 21.39.48 | `Menu_Principal` — aba **Rodízio** | TextBox 2 (Telefone) | Provável outro campo (não filtro) |
| 7 | 21.39.53 | `Menu_Principal` — aba **ImprimeOS** | (TextBox topo direito) | Filtro Emite Solicitação |
| 8 | 21.39.58 | `Menu_Principal` — aba **Avaliações** | (TextBox topo direito) | Filtro Encerramento/Avaliação |
| 9 | 21.40.02 | `Menu_Principal` — aba **Cadfilters** (Altera Cadastro Serviços) | (TextBox topo direito) | Filtro Altera Cadastro |
| 10 | 21.40.16 | `Reativa_Empresa` | (TextBox topo direito, padrão `TextBox16`) | Filtro Reativar Empresa |
| 11 | 21.40.26 | `Reativa_Entidade` | (TextBox topo direito, padrão `TextBox14`) | Filtro Reativar Entidade |

## Observação crítica — escopo Menu_Principal

**6 dos 11 prints (3-9) são páginas do `Menu_Principal.frm`** — não
forms operacionais distintos. O operador disse anteriormente "não
mexer em Menu_Principal" (decisão de Onda 16 v3). Antes de
prosseguir, preciso clarificar:

- **Q1 (NOVO)**: as 6 páginas do Menu_Principal entram no escopo da
  refatoração de filtros desta onda? Ou o foco continua nos 4 forms
  isolados (Reativa_Entidade, Reativa_Empresa, Cadastro_Servico,
  Credencia_Empresa)?

Recomendação: **excluir Menu_Principal desta onda** — é form
complexo (16× `.Top/.Left`, 6× `For Each ctl`, 2× `Controls(var)` —
inventário MD-16.5). Refatorar ele requer onda dedicada.

## Convenção canônica final (extensão Q1 hearback anterior)

Para os 4 forms isolados:

| Form | TextBox atual (auto-gerado) | Nome canônico proposto |
|---|---|---|
| `Reativa_Entidade` | `TextBox14` (provável) | **`mTxtBusca`** |
| `Reativa_Empresa` | `TextBox16` (provável) | **`mTxtBusca`** |
| `Credencia_Empresa` | `TextBox14` (provável) | **`mTxtBusca`** |
| `Cadastro_Servico` | `TextBox14` (provável) | **`mTxtBusca`** |

**Regra**: nome do TextBox no designer = `mTxtBusca` (idêntico ao
`Private WithEvents mTxtBusca As MSForms.TextBox` declarado em
code-behind). Quando os nomes batem, **VBE faz bind automático
sem necessidade de `Set` explícito** — o code-behind fica
extremamente limpo.

## Plano de ataque revisado (3 etapas)

### Etapa 1 — **Construir cobertura ANTES de mexer** (Quinteto)

Sem suite UI, qualquer renomeação pode regredir e o gate atual
(Quarteto) não detecta. Ordem:

1. **MD-16.6 fix2** (próximo MICRO20): criar suite `TV2_RunUiFiltros`
   com cenários por form (lista popula + filtro funciona +
   idempotência).
2. Estender `CT_ValidarRelease_QuartetoMinimo` →
   `CT_ValidarRelease_QuintetoMinimo` (adiciona `TV2_RunUiFiltros`
   como 5ª etapa).
3. Atualizar `APP_RELEASE_TEST_KEY = "quinteto-2026-05-XX"`.

### Etapa 2 — Renomear designer + ajustar code-behind (com cobertura)

Para cada um dos 4 forms isolados:

1. **Operador no VBE**:
   - Abrir form no designer
   - Selecionar TextBox de filtro
   - Properties panel → mudar `(Name)` para `mTxtBusca`
   - Salvar workbook
   - Exportar `.frm + .frx + .code-only.txt` para
     `local-ai/vba_import/002-formularios/<prefixo>-<Form>.*`
2. **IA**:
   - Atualizar code-behind no canônico:
     - Remover `Set mTxtBusca = UI_TextBoxSeExiste(...)` (bind
       automático agora)
     - Remover `UI_PegarTextBoxBuscaTopoDireita`
     - Manter apenas `Private WithEvents mTxtBusca As MSForms.TextBox`
       + handler `Private Sub mTxtBusca_Change()`
     - `UserForm_Initialize` reduzido a `Call UI_PreencherLista...`
3. **Gate**: Quinteto verde (regressão UI detectada se houver).
4. Próximo form.

### Etapa 3 — Cleanup final (MD-16.6.5)

Após os 4 forms migrados:

- Remover `UtilFiltro_LocalizarTextBoxFiltro` de `Util_Filtro_Lista.bas`
  (sem consumidores).
- Remover `UI_PegarTextBoxBuscaTopoDireita` que sobrou em forms.

## Sobre Reativa_Empresa lista vazia (suspeita)

No print de validação MICRO19, Reativa_Empresa apareceu vazia. Duas
hipóteses:

1. **Operador inativou só entidades, não empresas** — lista vazia é
   correta.
2. **Regressão persistente apesar do rollback** — improvável (rollback
   é byte-a-byte do estado pré-MICRO17).

**Q2 (NOVO)**: você inativou empresas no fluxo normal antes de abrir
Reativa_Empresa? Se sim e mesmo assim a lista veio vazia, é
regressão real e investigamos. Se não, é estado correto.

## 🟡 HBN NEEDS HUMAN DECISION — Q1 + Q2 + Q3

| # | Pergunta | Default proposto |
|---|---|---|
| **Q1** | Menu_Principal entra no escopo MD-16.6 (renomear filtros das 6 páginas)? | **NÃO** — Menu_Principal tem dívida heurística pesada não-filtro; refatoração ampla fica para Onda 17. Foco MD-16.6: 4 forms isolados (Reativa_Entidade, Reativa_Empresa, Credencia_Empresa, Cadastro_Servico). |
| **Q2** | Você inativou empresas antes do print que mostrou Reativa_Empresa vazia? | Aguardo resposta. |
| **Q3** | Aprova plano em 3 etapas (Quinteto primeiro → renomear form-a-form → cleanup)? | **Sim** — Quinteto verde antes de qualquer renomeação garante zero regressão silenciosa. |

## 10. Marcadores HBN V2 ativos

- 🟠 HBN SOURCE DRIFT DETECTED (resolvido por rollback MICRO19)
- 🔵 HBN HANDOFF READY (próximo passo: construir Quinteto)
- 🟡 HBN NEEDS HUMAN DECISION (Q1-Q3 acima)
- 🟣 HBN PEER REVIEW REQUESTED (operador validou prints + renomeará designer)

## Versão

- v1.0 — 2026-05-02 — análise inicial dos 11 prints + plano canônico.
