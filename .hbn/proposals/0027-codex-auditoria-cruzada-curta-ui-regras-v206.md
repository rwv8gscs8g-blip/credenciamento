---
titulo: Auditoria cruzada curta — Onda 38.2.5 UI de regras de negocio
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-31
---

# 0027 — Auditoria cruzada curta UI de regras de negocio

## Escopo Auditado

- Readback: `.hbn/readbacks/0121-rb-onda-38-2-5-ui-regras-negocio.json`
- Parecer arbitro: `.hbn/proposals/0024-Opus3-4-MAX-auditoria-gate-a4-l43-v206.md`
- Form: `src/vba/Configuracao_Inicial.frm` + `.frx`
- Teste dirigido: `src/vba/Teste_V2_Roteiros.bas`
- Manifesto: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_5_UI_REGRAS_NEGOCIO.txt`

## Findings

1. `Configuracao_Inicial.frx` promovido contem `TxtNotaCorte`, `TxtMaxStrikes`, `TxtDiasSuspensao`, `PR_Val_OS`, `TP_Valor` e `TxtMesesSuspensao`.
2. O code-behind nao cria controles em runtime; se qualquer controle sumir do designer, `CI_GarantirControlesRegraNegocio` levanta erro e `TV2_RunPersistenciaPainel` deve reprovar.
3. A semantica dos campos permanece: nota abaixo do corte conta strike; max strikes dispara suspensao; dias de suspensao define a duracao. `PR_Val_OS` define o prazo da Pre-OS em dias. Recusas seguem a regra existente: `TP_Valor` define o limite e `TxtMesesSuspensao` grava o periodo em meses consumido por `Svc_Rodizio.Suspender`.
4. O pacote nao toca `Auto_Open.bas`, `Svc_*`, `Repo_*`, `Classificar.bas`, `Altera_Entidade.frm`, `Util_Planilha.bas`, `Preencher.bas` ou `Menu_Principal.frm`.
5. A importacao precisa ser `F|` para `Configuracao_Inicial` porque o delta altera `.frx`; code-only isolado nao fecharia BL-1.

## Veredito

Sem bloqueador local para enviar ao operador para import, compile e `TV2_RunPersistenciaPainel`.

Nao declara freeze V206. BL-1 so pode ser declarado resolvido apos import/compile/teste no workbook.
