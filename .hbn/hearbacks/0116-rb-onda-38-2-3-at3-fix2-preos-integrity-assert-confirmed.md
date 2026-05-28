---
titulo: Hearback 0116 — AT-3 Fix2 PreOS Integrity Assert
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Hearback 0116 — AT-3 Fix2 PreOS Integrity Assert

Mauricio reportou que o import do fix1 compilou limpo e que `TV2_RunRodizioStrikesEndToEnd` gerou 37 falhas no CSV `TesteV2_STRIKES_E2E_Falhas_TV2_20260527_213936.csv`.

O Codex fica autorizado a executar micro-fix de escopo restrito em `Teste_V2_Roteiros`: ajustar `DIAG_PREOS_INTEGRITY` para comparar a expectativa canonica (`002`/`003`) contra a celula bruta persistida em `PRE_OS`, sem alterar dominio e sem tocar `Teste_V2_Engine`.
