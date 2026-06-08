---
titulo: Hearback 0155 — campo dias por recusa/prazo acessivel
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-06
---

# Hearback 0155

Mauricio reportou que a 0154 importou, compilou e `TV2_RunTelaConfiguracoesIniciais` passou, mas o campo visual `suspender por 30 dia(s)` na tela **Configuracoes Iniciais** ainda nao esta editavel/acessivel e a navegacao por Tab esta irregular.

Autorizacao operacional: corrigir o campo e o teste dirigido em microdelta estreito, sem editar `.frx`, sem alterar a regra de negocio de punicoes em dias e sem exigir VCR completa nesta iteracao.
