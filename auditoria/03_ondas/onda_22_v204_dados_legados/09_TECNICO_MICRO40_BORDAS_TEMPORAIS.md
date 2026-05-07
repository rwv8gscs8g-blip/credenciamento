---
titulo: Tecnico MICRO40 — Bordas temporais de strikes
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-07
---

# MICRO40 — Bordas temporais de strikes

## 1. Objetivo

Fechar o MD-22.4 validando a janela punitiva de strikes apos reativacao.
A regra vigente e intencionalmente estrita:

```text
CAD_OS.DT_FECHAMENTO > EMPRESAS.DT_ULT_REATIV
```

OS fechada antes ou exatamente no corte nao conta para punicao. OS
fechada depois do corte conta. Um corte futuro tambem nao deve voltar ao
historico antigo.

## 2. Entrega

O `TV2_RunRodizioStrikesEndToEnd` ganhou quatro asserts:

| Cenario | Cobre | Esperado |
|---|---|---|
| `CS_REATIV_BORDA_ANTERIOR` | fechamento anterior ao corte | `STRIKES_PUNICAO=0` |
| `CS_REATIV_BORDA_IGUAL` | fechamento exatamente igual ao corte | `STRIKES_PUNICAO=0` |
| `CS_REATIV_BORDA_POSTERIOR` | fechamento posterior ao corte | `STRIKES_PUNICAO=1` |
| `CS_REATIV_BORDA_FUTURA` | `DT_ULT_REATIV` futura | `STRIKES_PUNICAO=0` |

Os cenarios usam fixture isolada `SBTM` e OS sinteticas fechadas em
`CAD_OS`. A limpeza local remove somente OS com prefixo `SBTM_`.

## 3. Impacto no gate

Como os quatro asserts entram em `E2E_Strikes`, o contador esperado do
Quinteto sobe:

```text
E2E_Strikes=71/0 -> E2E_Strikes=75/0
```

Demais suites permanecem com a contagem atual.
