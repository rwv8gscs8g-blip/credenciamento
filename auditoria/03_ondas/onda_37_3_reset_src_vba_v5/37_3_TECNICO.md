---
titulo: Onda 37.3 — Reset src/vba para estado V5 funcional
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: claude-opus-4-7
papel: arquiteto-principal (bastao recebido de codex)
---

# Onda 37.3 — Reset src/vba para V5

## Contexto

Apos a Onda 37.2 reverter 3 arquivos drift_md33_descartar (Importador_V3.bas,
Menu_Principal.frm, Preencher.bas), o ImportarPacoteV3 importou TODOS os 34
modulos + 13 forms do `local-ai/vba_import/` (que espelha `src/vba/`) e o
compile VBE falhou. Diagnostico: os 25 arquivos `drift_legitimo_anterior_v5`
existentes em `src/vba` com commits pos-V5 (Ondas 28-29 nunca importadas no
workbook V5) criaram referencias/dependencias quebradas no compile.

Mauricio passou o bastao para Claude Opus 4.7 (arquiteto principal) executar
o reset completo para estado V5 funcional.

## O que foi feito

1. Backup defensivo de TODO `src/vba` (66 arquivos) em
   `auditoria/03_ondas/onda_37_3_reset_src_vba_v5/backup_pre_reset/`.
2. Manifest SHA-256 do estado pre-reset em
   `manifest_src_vba_pre_reset.sha256.csv`.
3. Manifest SHA-256 do `local-ai/incoming/V206_ANCHOR_V5_20260524/` (gate 1)
   em `manifest_incoming_v5.sha256.csv`. 64 arquivos, todos nao-zero.
4. Reset via `rsync -av --delete` sobrescrevendo `src/vba/` com o conteudo
   exato de `local-ai/incoming/V206_ANCHOR_V5_20260524/`.
5. Remocao fisica de `src/vba/Importador_V2.bas` e
   `src/vba/Emergencia_CNAE.bas` (autorizado pelos ADRs 20260524 da
   Onda 37.1).
6. `diff -rq local-ai/incoming/V206_ANCHOR_V5_20260524/ src/vba/` retornou
   vazio = paridade total confirmada (gate 2).

## Estado pos-reset

| Item | Antes | Depois |
|---|---:|---:|
| Arquivos em src/vba | 66 | 64 |
| Arquivos batendo com export V5 | 8 (igual) + 30 (drift benigno) = 38 | 64 (todos) |
| Drift funcional vs V5 | 28 | 0 |
| Arquivos orfaos | 2 (V2 + Emergencia_CNAE) | 0 |

## Comparacao com export V5

- 38 `.bas` + 13 `.frm` + 13 `.frx` = 64 arquivos, exatos hash do export V5.
- Workbook V5 (.xlsm) NAO foi tocado (operador fechou sem salvar apos
  compile da Onda 37.2 falhar).
- `local-ai/incoming/V206_ANCHOR_V5_20260524/` NAO foi tocado (read-only,
  evidence).

## Perda aceita

Os 25 arquivos que tinham commits pos-V5 das Ondas 28-29 voltaram para o
estado pre-Onda-28. Esses commits estao preservados no historico git e podem
ser reimportados caso a caso em ondas futuras se necessario para
funcionalidades especificas. Para o objetivo imediato da V12.0.0206 (PDFs
automaticos + correcao de formularios), essa perda nao bloqueia nada:
estamos partindo da base que comprovadamente compila.

## Gates restantes para fechar Onda 37.3

| Gate | Status |
|---|---|
| G1: incoming/V5 integridade (64 arquivos, nao-zero, hash legivel) | ✓ |
| G2: diff incoming vs src/vba retorna vazio | ✓ |
| G3: hbn-guards-runner passa 5/5 apos publicar_vba_import_v2 --apply | pendente (operador) |
| G4: Importador_V2.bas e Emergencia_CNAE.bas removidos | ✓ |
| G5: compile humano VBE no workbook V5 apos ImportarPacoteV3 | pendente (operador) |

Onda fica em `delivered_for_human_gate` ate G3 e G5 fecharem.

## Procedimento operacional

Comando 1 — Regenerar espelho local-ai/vba_import:

`bash local-ai/scripts/publicar_vba_import_v2.sh --apply`

Esperado: G7 sync OK, espelho regenerado com os 64 arquivos.

Comando 2 — Validar guards:

`bash scripts/hbn-guards/hbn-guards-runner.sh`

Esperado: 5/5 verde.

Comando 3 — Commit:

`git add src/vba/ local-ai/vba_import/ auditoria/03_ondas/onda_37_3_reset_src_vba_v5/ .hbn/readbacks/0093-onda37-3-reset-src-vba-para-v5.json .hbn/results/0093-exec-onda37-3-reset-src-vba-para-v5.json .hbn/relay/INDEX.md CHANGELOG.md && git commit -m "fix(v206): onda 37.3 reset src/vba para estado V5 funcional"`

Comando 4 — No Excel/VBE (workbook V5):

`ImportarPacoteV3` no painel ou Janela Imediata, depois `Debug > Compile VBAProject`.

Esperado: compile passa limpo (base = V5 que comprovadamente compilava).

## Fallback se compile falhar

1. NAO SALVAR o workbook (preserva V5 intacto no disco).
2. Reportar mensagem exata do compile error (modulo + linha).
3. Significara que o problema NAO esta em src/vba, mas em algo do workbook
   em si (Mod_Types interno, planilha de dados, refs circulares). Abrir
   onda safe_track de investigacao com workbook V5 puro como referencia.

## Bastao apos compile OK

Apos G5 verde, bastao volta para Codex executar Onda 38 (MD33-restart
correto sobre base V5 limpa), Onda 39 (Util_PDF.bas), etc. conforme
auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md e
auditoria/00_status/106_DEVOLUTIVA_OPUS_PROMPT_RETOMADA_CODEX_V206.md.

## Lições destiladas

**L29** — Antes de aprovar qualquer onda safe_track que toque VBA, declarar
no readback o COMPORTAMENTO do importador: ele importa SO os arquivos
declarados no scope ou PACOTE COMPLETO de `local-ai/vba_import/`? Se for
pacote completo (caso atual), qualquer drift previo entre src/vba e
workbook vira fator de risco e exige reset previo.

**L30** — Em crise operacional (codigo nao compila + entrega urgente), o
papel de arquiteto pode receber o bastao do executor explicitamente em
chat, registrado via campo `baton_transfer` no readback. Nao precisa de
onda dedicada para a transferencia; precisa de auditabilidade no readback
da onda em execucao.

**L31** — `local-ai/incoming/` (export bruto do workbook) e a UNICA fonte
confiavel de "estado que compila" quando ha contaminacao em src/vba sem
trilha clara. Vale como ancora de reset, NAO como fonte de import (essa e
sempre `local-ai/vba_import/`).
