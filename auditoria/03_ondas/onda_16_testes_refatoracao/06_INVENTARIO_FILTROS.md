---
titulo: 06 - Inventário de filtros nos 13 forms (MD-16.5 Fase 1)
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203 → ONDA16.MD5
data: 2026-05-02
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1 (Credenciamento)
---

# MD-16.5 — Inventário de filtros + padrão consolidado

## TL;DR

Dos 13 forms operacionais, **4 têm filtro real** (TextBox de busca
com `WithEvents` + handler `_Change()` para refiltrar listbox/sheet):

1. `Cadastro_Servico.frm` — `mTxtBuscaTopo`
2. `Credencia_Empresa.frm` — `mTxtFiltroCredLista`
3. `Reativa_Empresa.frm` — `mTxtBusca` ✓ (template emergente)
4. `Reativa_Entidade.frm` — `mTxtBusca` ✓ (template emergente)

**Padrão consolidado proposto**: adotar `mTxtBusca` em todos (já é o
nome em 2/4) e remover o helper heurístico
`UI_PegarTextBoxBuscaTopoDireita` que chama
`UtilFiltro_LocalizarTextBoxFiltro(Me)` — substituir pelo TextBox
declarado `WithEvents` direto.

Os outros 9 forms ou (a) não têm filtro, ou (b) têm dívida heurística
**não relacionada a filtro** (Altera_Empresa, Configuracao_Inicial,
Menu_Principal) que fica para futura onda de heurística zero ampla.

## 1. Inspeção empírica (todos os 13 forms)

| Form | TextBox | ListBox | ComboBox | CommandButton | For Each ctl | Controls(var) | .Top/.Left | Tem filtro? | Categoria |
|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| Altera_Empresa | 0 | 0 | 0 | 2 | 4 | 0 | 6 | ❌ | dívida não-filtro |
| **Altera_Entidade** | 0 | 0 | 0 | 0 | 0 | 0 | 0 | ❌ | **TEMPLATE LIMPO** |
| **Cadastro_Servico** | 3 | 0 | 0 | 0 | 0 | 1 | 0 | ✅ filtro | **MD-16.6** |
| Configuracao_Inicial | 0 | 0 | 0 | 0 | 1 | 1 | 0 | ❌ | dívida não-filtro |
| **Credencia_Empresa** | 1 | 0 | 0 | 0 | 0 | 0 | 4 | ✅ filtro | **MD-16.6** |
| Fundo_Branco | 0 | 0 | 0 | 0 | 0 | 0 | 2 | ❌ | trivial (visual) |
| Limpar_Base | 0 | 0 | 0 | 0 | 0 | 0 | 0 | ❌ | trivial |
| Menu_Principal | 12 | 0 | 0 | 2 | 6 | 2 | 16 | ❌ | dívida não-filtro pesada |
| ProgressBar | 0 | 0 | 0 | 0 | 0 | 0 | 0 | ❌ | trivial |
| **Reativa_Empresa** | 3 | 0 | 0 | 0 | 0 | 1 | 0 | ✅ filtro | **MD-16.6** |
| **Reativa_Entidade** | 3 | 0 | 0 | 0 | 0 | 1 | 1 | ✅ filtro | **MD-16.6** |
| Rel_Emp_Serv | (designer-only) | (designer-only) | (designer-only) | 0 | 0 | 0 | 0 | ❌ | sem filtro (handler `SV_CR_Lista_Click`) |
| Rel_OSEmpresa | (designer-only) | (designer-only) | (designer-only) | 0 | 0 | 0 | 0 | ❌ | sem filtro (handler `B_RelEmpresaOS_Click`) |

> "designer-only" = controles existem no `.frx` mas o code-behind não
> declara `Private WithEvents` para eles (acessados só via Me.X).

## 2. Convenção atual observada nos 4 forms com filtro

### 2.1 `Reativa_Empresa.frm` (CANDIDATO A TEMPLATE)

```text
Private WithEvents mTxtBusca As MSForms.TextBox

Private Function UI_PegarTextBoxBuscaTopoDireita() As MSForms.TextBox
    Set UI_PegarTextBoxBuscaTopoDireita = UtilFiltro_LocalizarTextBoxFiltro(Me)
End Function

' ... handler refiltra listbox a cada keystroke
Private Sub mTxtBusca_Change()
    ...
End Sub
```

### 2.2 `Reativa_Entidade.frm` (idêntico ao acima)

Mesma estrutura: `mTxtBusca` + `UI_PegarTextBoxBuscaTopoDireita` + `mTxtBusca_Change`.

### 2.3 `Credencia_Empresa.frm`

```text
Private WithEvents mTxtFiltroCredLista As MSForms.TextBox

Private Sub mTxtFiltroCredLista_Change()
    ...
End Sub

Private Sub CR_EnsureFiltroListaDinamico()
    ' lógica de wiring inicial via designer
End Sub
```

Nome divergente: `mTxtFiltroCredLista` em vez de `mTxtBusca`.

### 2.4 `Cadastro_Servico.frm`

```text
Private WithEvents mTxtBuscaTopo As MSForms.TextBox

Private Function UI_PegarTextBoxBuscaTopoDireita() As MSForms.TextBox
    Set UI_PegarTextBoxBuscaTopoDireita = UtilFiltro_LocalizarTextBoxFiltro(Me)
End Function

Private Sub mTxtBuscaTopo_Change()
    ...
End Sub
```

Nome divergente: `mTxtBuscaTopo`.

## 3. Heurística residual (regra V203 #3)

Os 4 forms com filtro usam helper externo:

```text
UtilFiltro_LocalizarTextBoxFiltro(Me)  ' em Util_Filtro_Lista.bas
```

Esse helper **busca o TextBox por dedução** (provavelmente
posicionamento ou padrão de Caption). Viola regra #3 ("controles
acessados por nome canônico hardcoded; proibido `For Each ctl In
Me.Controls` para tomada de decisão"). É a dívida específica de
filtro que MD-16.6 vai limpar.

## 4. Convenção consolidada proposta (extensão do padrão emergente)

### 4.1 Nome canônico do TextBox de busca

**`mTxtBusca`** para todos os 4 forms (já em uso em
`Reativa_Empresa` e `Reativa_Entidade`).

Renomeações necessárias:
- `Credencia_Empresa.mTxtFiltroCredLista` → `mTxtBusca`
- `Cadastro_Servico.mTxtBuscaTopo` → `mTxtBusca`

### 4.2 Eliminação de heurística

Remover de todos os 4 forms:
- `UI_PegarTextBoxBuscaTopoDireita()` (private function)
- Wiring via `If mTxtBusca Is Nothing Then Set mTxtBusca = UI_Pegar...`

Substituir por declaração direta no `.frm`:
- O TextBox no designer fica com nome `mTxtBusca` (nome canônico)
- `Private WithEvents mTxtBusca As MSForms.TextBox` se vincula
  automaticamente quando designer e code usam o mesmo nome
- Handler `Private Sub mTxtBusca_Change()` permanece direto

### 4.3 Idempotência

Cada filtro deve ser idempotente: digitar `XYZ`, apagar, digitar
`XYZ` novamente produz o mesmo recordset. Validação via bateria
nova (FRM_<form>_Filtro_001).

## 5. Plano colaborativo MD-16.6 (tela-a-tela)

Para cada form, o ciclo é:

```text
1. Operador tira print do form aberto no Excel
2. Operador me envia o nome real do TextBox de busca no designer
   (ou eu infiro pelo print + leitura do .frx)
3. Eu proponho ajustes: renomear TextBox no designer (operador faz)
   + ajustar code-behind (eu faço)
4. Operador importa microdelta + roda Quarteto
5. Operador valida visualmente: filtro funciona, idempotente, sem
   regressão
6. Próxima tela
```

## 6. Ordem de revisão proposta (do mais simples ao mais complexo)

| # | Form | Esforço | Por que essa ordem |
|---|---|---|---|
| 1 | `Reativa_Entidade` | Baixo | Já usa `mTxtBusca`; só remover `UI_PegarTextBoxBuscaTopoDireita` + wiring heurístico |
| 2 | `Reativa_Empresa` | Baixo | Idêntico ao Reativa_Entidade — replicar mesma mudança |
| 3 | `Credencia_Empresa` | Médio | Renomear `mTxtFiltroCredLista` → `mTxtBusca` no designer + ajustar code |
| 4 | `Cadastro_Servico` | Médio | Renomear `mTxtBuscaTopo` → `mTxtBusca` + ajustar code; tem mais handlers acoplados |

## 7. Forms com dívida heurística NÃO-filtro (fora do escopo MD-16.6)

| Form | Heurística | Recomendação |
|---|---|---|
| Altera_Empresa | 4 `For Each ctl` + 6 `.Top/.Left` (funções `BuscarControleEdicaoRecursivo`, `PosicaoEsquerdaAbsolutaEdicao`) | Onda futura de heurística zero ampla — não é filtro |
| Configuracao_Inicial | 1 `For Each ctl` + 1 `Controls(var)` | Onda futura |
| Menu_Principal | 6 `For Each ctl` + 16 `.Top/.Left` + 2 `Controls(var)` | Onda futura — dívida pesada, requer planejamento dedicado |
| Fundo_Branco | 2 `.Top/.Left` (puro visual, talvez justificado) | Aceitável; revisar em onda futura |

`Altera_Entidade` permanece como template canônico (zero
heurística observada em qualquer dimensão).

## 8. 🟡 HBN NEEDS HUMAN DECISION — Q1-Q3 antes de iniciar MD-16.6

| # | Pergunta | Default proposto |
|---|---|---|
| **Q1** | Convenção definitiva do nome do TextBox: **`mTxtBusca`** (segue Reativa_*) ou outro nome (ex.: `txt_busca`)? | **`mTxtBusca`** — já em uso em 2 forms; preserva prefixo `m` (módulo) + Hungarian leve `Txt`. Zero churn em Reativa_Empresa/Entidade. |
| **Q2** | Remover `UI_PegarTextBoxBuscaTopoDireita()` + `UtilFiltro_LocalizarTextBoxFiltro` quando ninguém mais consumir? | **Sim** — após MD-16.6.4 (último form), helper fica órfão. Remover em MD-16.6.5 (cleanup) ou deixar para Onda 17. |
| **Q3** | Iniciar **MD-16.6.1 (Reativa_Entidade)** agora ou aguardar você tirar todos os 4 prints primeiro? | **Iniciar pela Reativa_Entidade** — já posso propor mudança baseada no código atual + leitura do `.frx` (operador valida visualmente). 4 prints em série fica longo; melhor entregar 1, validar, depois próxima. |

## 9. Marcadores HBN V2 ativos neste documento

- 🔵 HBN HANDOFF READY — inventário completo entregue para validação
- 🟡 HBN NEEDS HUMAN DECISION — Q1-Q3 acima
- 🟣 HBN PEER REVIEW REQUESTED — validação do operador via prints (MD-16.6)
- 🟢 HBN CHECKPOINT CLEAN — Fase 1 (inventário) sem efeito colateral

## 10. Próximos passos

Após hearback Q1-Q3, MD-16.6 inicia com **Reativa_Entidade**
(microdelta interno MD-16.6.1, manifesto MICRO17). Ciclo de prints
+ ajustes tela-a-tela até cobrir os 4 forms (MICRO17, MICRO18,
MICRO19, MICRO20). Cleanup do helper órfão em MICRO21 (se Q2=sim).

## Versão

- v1.0 — 2026-05-02 — inventário inicial + padrão consolidado.
