---
titulo: Hearback 0164 — disponibilidade operacional em relatorios
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0205
data: 2026-06-08
---

# Hearback 0164

Mauricio aprovou a implementacao das correcoes de diagnostico operacional em
mensagens, relatorios e impressos.

Escopo confirmado:

- melhorar a mensagem quando o rodizio nao encontra empresa disponivel;
- mostrar disponibilidade operacional nos relatorios;
- reduzir duplicidade e melhorar uso da area impressa;
- incluir no campo observacao de Pre-OS, OS e Avaliacao o texto "Status da
  empresa nesta data" com suspensao, strikes e disponibilidade;
- corrigir o falso negativo de `UI_ADV_011`.

Fora deste microdelta:

- checkboxes de zeragem anual em Configuracoes Iniciais. Essa mudanca exige
  designer, persistencia, auditoria e teste proprio.
