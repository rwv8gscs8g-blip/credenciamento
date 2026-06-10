---
titulo: Onda 38.2.43 - aviso em duas linhas e zoom dos relatorios
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-10
---

# 0176 - Tecnico

## Contexto

A 38.2.42 foi importada, compilada e validada por TV2 dirigido
`TV2_20260610_002102` com `OK=16 | FALHA=0 | MANUAL=0`. A revisao visual dos
PDFs 031-038 mostrou duas pendencias de legibilidade:

- Pre-OS/OS ainda concentravam todo o aviso operacional em `B30`, apertando a
  leitura quando disponibilidade, suspensao e strikes apareciam juntos.
- Relatorios impressos continuavam com sobra horizontal visivel porque o Excel
  reduzia areas largas com `FitToPagesWide`, mas nao ampliava areas estreitas.

## Implementacao

`Preencher.bas` agora divide o aviso operacional por `Preencher_DividirAvisoOperacional`.
A linha `B29` recebe status e disponibilidade; `B30` recebe suspensao e strikes.
`LimparOS` e `LimparPREOS` limpam `B24`, `B29` e `B30`.

`Util_Config.bas` recebeu `Rel_DefinirAreaImpressao`. O helper define
`PrintArea` e chama `Rel_AjustarZoomLarguraUtil`, que calcula a largura util A4
conforme orientacao e margens. Quando a area impressa e menor que a largura util,
aplica zoom numerico limitado; quando precisa reduzir, preserva `FitToPagesWide=1`.

Os relatorios de `Menu_Principal.frm`, `Rel_Emp_Serv.frm`,
`Rel_OSEmpresa.frm` e `Rel_Rodizio_Status.bas` deixam de definir `PrintArea`
diretamente e passam pelo helper comum.

## Testes Atualizados

`TV2_RunRelatoriosSuspensoesStrikesReset` permanece com 16 cenarios, mas os
contratos 13-16 foram endurecidos para validar `B29/B30`, limpeza dos dois
campos ativos e zoom dinamico. `REL_TELA_11_PREOS_VENCIDAS_IMPRESSAO_SEM_EXPIRAR`
tambem foi ajustado para exigir `Rel_DefinirAreaImpressao` no relatorio de
Pre-OS vencidas.

## Gate Esperado

- `ImportarPacoteV3_Delta "ONDA38_2_43_AVISO_DUAS_LINHAS_RELATORIOS_ZOOM", "8078e73+ONDA38.2.43-AVISO-2LINHAS-REL-ZOOM"`
- Importador V3: `M=6 | F=3 | err=0 | skip=0`
- Compile manual limpo no VBE
- `TV2_RunRelatoriosSuspensoesStrikesReset`: `OK=16 | FALHA=0 | MANUAL=0`
- Revisao visual de novos PDFs:
  - Pre-OS/OS com aviso legivel em duas linhas `B29:K30`
  - Relatorios usando melhor a largura horizontal visivel

## Fora de Escopo

Nao houve alteracao em `.frx`, `Mod_Types.bas`, `Importador_V3.bas`,
`Auto_Open.bas`, `ThisWorkbook`, motor de rodizio, expiracao, recusa ou avanco
de fila.
