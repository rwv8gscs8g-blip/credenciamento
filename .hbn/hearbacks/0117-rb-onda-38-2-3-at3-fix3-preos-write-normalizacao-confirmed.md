---
titulo: Hearback 0117 — AT-3 Fix3 PreOS Write Normalizacao
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Hearback 0117 — AT-3 Fix3 PreOS Write Normalizacao

Mauricio reportou que o import do fix2 compilou limpo e que `TV2_RunRodizioStrikesEndToEnd` gerou 37 falhas no CSV `TesteV2_STRIKES_E2E_Falhas_TV2_20260527_220557.csv`.

O CSV mostra `NF=@`, `EMP_PREOS_BRUTO=2/3` e `EMP_PREOS_REPO=002/003`. O Codex fica autorizado a executar micro-fix de escopo restrito em `Svc_PreOS.EmitirPreOS`: gravar IDs ja normalizados depois de aplicar `NumberFormat="@"`, sem alterar rodizio, repo ou testes.
