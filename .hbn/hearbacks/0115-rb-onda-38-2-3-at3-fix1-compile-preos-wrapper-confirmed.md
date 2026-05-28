---
titulo: Hearback 0114 AT-3 Fix1 Compile PreOS Wrapper
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Hearback confirmado — AT-3 Fix1 Compile PreOS Wrapper

Mauricio reportou erro de compilação bloqueante após importar AT-3:

> Método ou membro de dados não encontrado

O VBE destacou `Repo_PreOS.BuscarPorId` dentro de `Teste_V2_Roteiros`.

Interpretação operacional:

- Compile gate P1 bloqueia RVS.
- Codex pode abrir micro-fix dentro do GATE-A3 para substituir a chamada qualificada frágil por wrapper público estável.
- Escopo mínimo: `Repo_PreOS.bas` + `Teste_V2_Roteiros.bas` e seus espelhos importáveis.
