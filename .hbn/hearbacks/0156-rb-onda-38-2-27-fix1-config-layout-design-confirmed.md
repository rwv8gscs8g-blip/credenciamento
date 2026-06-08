---
titulo: Hearback 0156 — correcao de design no formulario Configuracoes Iniciais
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-06
---

# Hearback 0156

Mauricio exportou para `incoming/` o formulario **Configuracoes Iniciais** ja
corrigido no designer. A descoberta operacional foi que o label `suspender por`
estava sobrepondo o campo numerico de dias por recusa/prazo.

Decisao humana: em validacao tela a tela, quando uma correcao puder ser feita
no design de forma simples, clara e de baixo impacto, ela deve prevalecer sobre
ajustes runtime que adicionem complexidade ao codigo.
