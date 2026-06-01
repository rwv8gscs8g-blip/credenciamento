---
titulo: Auditoria cruzada curta - Onda 38.2.8 CONFIG baseline V2
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0205
data: 2026-05-31
---

# Auditoria cruzada curta - Onda 38.2.8

## Veredito

Sem bloqueador local identificado para importar o delta
`ONDA38_2_8_CONFIG_BASELINE_V2`, condicionado a compile manual limpo e
`TV2_RunConfigBaselineSeguro` com `OK=3 | FALHA=0 | MANUAL=0`.

## Conferencias

- A causa raiz do reset foi isolada em `TV2_SetConfigCanonica`.
- `COL_CFG_GESTOR` e `COL_CFG_MUNICIPIO` agora passam por helper que preserva
  valor operacional nao vazio.
- Os valores `Gestor Testes V2` e `Municipio de Testes V2` continuam como
  fallback para CONFIG vazia, evitando quebrar fixture inicial.
- A suite dirigida e nao destrutiva valida a presenca do helper e a ausencia
  das atribuicoes diretas antigas.

## Ressalvas

- Esta onda nao corrige CONFIG ja sobrescrita anteriormente; se a aba estiver
  com `Municipio de Testes V2`, o operador deve salvar o municipio real uma vez
  pela UI depois do import.
- Layout/bordas dos PDFs seguem fora do escopo e precisam de readback proprio.
- O worktree contem sujeira historica de ondas anteriores; esta auditoria cobre
  apenas arquivos permitidos pelo readback 0124.
