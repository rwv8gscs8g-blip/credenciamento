---
titulo: Hearback 0152 — RVS inclui impressao residual
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-06
---

# Hearback 0152 — confirmado

Mauricio confirmou em chat: "Aprovado, pode avancar" e perguntou se seria
adequado rodar teste completo antes da atuacao tela a tela e incluir os novos
testes no RVS geral.

Decisao operacional: sim. O microdelta 0152 incorpora
`TV2_RunImpressaoResidual` ao gate oficial `CT_ValidarRelease_SextetoMinimo`,
mantendo a superficie publica do RVS e registrando a nova etapa no CSV e na
sintaxe final.

Escopo proibido: UserForms, `.frx`, workbook/template manual, `Auto_Open`,
`Mod_Types`, `Importador_V3`, `Teste_V2_Engine`, `Teste_V2_Roteiros` e a suite
`Teste_V2_Impressao_Residual` ja validada no GATE 2/0151.
