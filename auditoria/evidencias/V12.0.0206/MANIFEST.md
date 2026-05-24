---
titulo: Manifesto de Evidências V12.0.0206
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-05-24
---

# Manifesto de Evidências V12.0.0206

Este manifesto será preenchido conforme a V12.0.0206 produzir evidências
próprias. No início da Onda 31, a release ainda herda a evidência final V205:

```text
auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260523_215637.csv
```

## Papel do `MANIFESTO.csv`

`MANIFESTO.csv` é o espelho tabular deste manifesto. Ele existe para scripts,
planilhas e validações automáticas. O `MANIFEST.md` continua sendo a leitura
humana canônica.

Quando um artefato V206 for anexado, registrar no mesmo delta:

1. linha humana em `MANIFEST.md`;
2. linha tabular em `MANIFESTO.csv`;
3. `sha256` calculado sobre o arquivo real;
4. caminho relativo dentro de `auditoria/evidencias/V12.0.0206/`.

| arquivo | tipo | papel | build | validation_id | timestamp | aba_origem | status | sha256 | caminho |
|---|---|---|---|---|---|---|---|---|---|
