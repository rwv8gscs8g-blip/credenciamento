---
titulo: Propostas USEHBN — tela a tela design-first e handoff operacional
diataxis: explanation
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-06
gatilho: Handoff 0157 apos fechamento da 0156 em Configuracoes Iniciais
status: proposta_para_evolucao_manual
---

# Propostas USEHBN — tela a tela design-first e handoff operacional

Este documento nao aplica mudancas no protocolo. Ele registra pontos objetivos
para uma evolucao manual do `PROMPT_ARQUITETO_USEHBN_AUTONOMO` antes da proxima
janela Codex.

## P1 — Classificacao obrigatoria de defeito em UserForm

Antes de qualquer delta que toque UserForm, a IA deve classificar o problema:

| Classe | Exemplo | Solucao preferencial |
|---|---|---|
| Design | sobreposicao, alinhamento, tamanho, tab order | corrigir no designer e reexportar `.frm/.frx` |
| Codigo | validacao, persistencia, evento de botao, regra de negocio | corrigir VBA com teste V2 |
| Hibrido | evento depende de layout ou controle renomeado | dividir em microdeltas ou pedir hearback |

Motivo: a 0155 propunha ajuste runtime para um problema geometrico; a causa real
era label sobreposto. A 0156 resolveu melhor com designer/export.

## P2 — Inventario de tela antes de corrigir botoes

Toda validacao tela a tela deve abrir com uma tabela de cobertura:

| Controle | Tipo | Acao esperada | Persistencia/efeito | Teste V2 | Evidencia manual | Status |
|---|---|---|---|---|---|---|

Motivo: evita validar apenas campos centrais e esquecer botoes, menus,
submenus, fechamento e navegacao.

## P3 — Gate manual UI estruturado no ERP

Adicionar ao ERP um bloco padrao `manual_ui_gate`:

```json
{
  "screen": "Configuracoes Iniciais",
  "control": "TxtMesesSuspensao",
  "actions": ["click", "edit", "save"],
  "observed": "pass",
  "reported_by": "Mauricio",
  "reported_at": "AAAA-MM-DDTHH:MM:SS-03:00",
  "screenshot": "opcional"
}
```

Motivo: hoje usamos `human_report`, mas UI manual precisa ficar mais
consultavel para auditoria futura.

## P4 — Cadencia de teste por custo

Formalizar tres niveis de teste por onda:

| Nivel | Uso | Exemplo |
|---|---|---|
| Dirigido | todo microdelta | `TV2_RunTelaConfiguracoesIniciais` |
| Canonico parcial | checkpoint de grupo | `TV2_RunCanonica` quando aplicavel |
| VCR | checkpoint forte, nao iteracao diaria | Validação Completa da Release |

Motivo: VCR observada com mais de 1 hora; usar em todo microdelta prejudica o
fluxo sem aumentar proporcionalmente a seguranca.

## P5 — Handoff antecipado para UserForms

Promover regra operacional: se uma onda tocar `.frm/.frx` e ja houver duas
rodadas de import/compile/fix ou contexto alto, handoff antes da proxima tela.

Motivo: UserForms combinam design, FRX, codigo e validacao manual; o custo de
contexto cresce rapido.

## P6 — Prompt de retomada separado do handoff

Manter o handoff completo em `.hbn/messages/` e criar um prompt copiavel em
`auditoria/00_status/NNN_PROMPT_RETOMADA_*.md`.

Motivo: o handoff e auditoria; o prompt e operacao. Separar reduz leitura
humana sem perder rastreabilidade.

## Recomendacao de ordem para evolucao manual

1. Aplicar P1 e P2 no `PROMPT_ARQUITETO` como regra de pre-flight para UserForm.
2. Aplicar P3 como bloco recomendado de ERP, sem alterar schema ainda.
3. Aplicar P4 como politica de gate de teste.
4. Deixar P5 e P6 como recomendacoes operacionais, pois ja sao compatíveis com
   knowledge 0014/0019.
