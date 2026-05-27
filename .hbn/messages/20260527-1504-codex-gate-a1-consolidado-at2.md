---
titulo: Codex consolidou GATE-A1 e abriu AT-2
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Codex consolidou GATE-A1 e abriu AT-2

Estado:

- Commit GATE-A1/AT-1: `ad14aa3`.
- Opus aprovou AT-1 e apontou BLOQ-1 diferido: `AAI-Credencia_Empresa.code-only.txt` stale pelo bug do gerador.
- Antigravity aprovou AT-1 sem bloqueadores.
- Mauricio confirmou a recomendacao Codex para seguir AT-2 incorporando BLOQ-1 no escopo.

Decisao aplicada:

- AT-2 tera `Credencia_Empresa` como alvo.
- O code-only de `Credencia_Empresa` sera ressincronizado dentro do mesmo readback.
- `ProgressBar` nao sera tocado nesta fase por ser form blindado.
- O import operacional do AT-2 usara manifesto delta V3 proprio, porque colagem manual do `.code-only.txt` nao deve ser usada com `Attribute` per-symbol preservado.

Proxima acao Codex:

Implementar diagnostico temporario F-NEW5 com gate `ATIVAR_DIAG_FNEW5`, publicar pacote alvo com manifesto delta V3 e parar para Mauricio importar/reproduzir o fluxo e gerar CSV.
