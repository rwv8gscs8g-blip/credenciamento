---
titulo: Anchor V5 de Reinicio V206 — Codex
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Anchor V5 de Reinicio V206

## Veredito

A nova ancora operacional para reinicio da V12.0.0206 e:

```text
/Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-Homologacao-V5.xlsm
```

Origem humana declarada:

```text
/Users/macbookpro/Projetos/Credenciamento/V12-205-OficialCongelada
```

A planilha V5 substitui a tentativa anterior baseada em
`V12-0206-Preparacao`. A V4 de preparacao e as tentativas
`MICRO62-V206-MD33-0`, `MICRO62-V206-MD33-0-fix1` e
`MICRO62-V206-MD33-0-fix2` permanecem apenas como historico reprovado.

## Evidencia Humana

Janela Imediata na V5:

```text
?ThisWorkbook.Path
\\Mac\Home\Projetos\Credenciamento

ImportarPacoteV3_Status
=== ImportarPacoteV3_Status (V3.3-Onda18-C4) ===
(nenhum import V3 executado nesta sessao)

MANIFESTO ESPERADO:
  \\Mac\Home\Projetos\Credenciamento\local-ai\vba_import\000-MANIFESTO-V3-PHASE1.txt
  STATUS: presente

MODO DETECTADO: Estabilizado
```

Metadados de release confirmados:

```text
?GetReleaseTag
v12.0.0205

?GetReleaseAtual
V12.0.0205

?GetReleaseAlvo
V12.0.0206

?GetBuildImportado
e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix
```

Gate RVS executado na V5 antes de qualquer novo import V206:

```text
ID: VR_20260524_164612
Resultado: APROVADO
Sintaxe: V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
CSV: auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260524_164612.csv
```

## Estado Canonico

- A V5 e workbook operacional local, ignorado pelo Git por regra de
  `.gitignore` para `*.xlsm`.
- A fonte versionada da verdade continua sendo `src/vba/`.
- O pacote importavel para Excel continua sendo `local-ai/vba_import/`.
- `local-ai/incoming/` pode receber export bruto para comparacao, mas nunca e
  fonte direta de importacao.
- `backups/vba/` e apenas evidencia/diagnostico, nao fonte operacional.

## Documentacao Ativa

Documentos ativos apos este reinicio:

| Documento | Papel |
|---|---|
| `AGENTS.md` | Entrada obrigatoria de IAs e regra de raiz canonica |
| `.hbn/relay/INDEX.md` | Bastao atual e proxima acao |
| `.hbn/knowledge/0012-raiz-canonica-projeto.md` | Regra permanente de raiz canonica |
| `auditoria/00_status/101_ANCHOR_V5_REINICIO_V206_CODEX.md` | Este status, ancora V5 |
| `auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md` | Roadmap V206 ainda valido |
| `auditoria/00_status/97_CONSOLIDACAO_PDF_UI_V206_CODEX.md` | Especificacao PDF/UI ainda valida, bloqueada ate reancoragem |

Documentos superados para acao operacional:

| Documento | Status |
|---|---|
| `auditoria/00_status/100_PAUSA_REBASE_PLANILHA_LIMPA_V206_CODEX.md` | Superado por este status quanto a ancora; mantido como historico do incidente |
| `auditoria/03_ondas/onda_33_v206_fix_relatorios_pdf_precondicao/02_PROCEDIMENTO_IMPORT_MICRO62.md` | Nao usar na V5 |
| `auditoria/03_ondas/onda_33_v206_fix_relatorios_pdf_precondicao/03_PROCEDIMENTO_IMPORT_MICRO62_FIX1.md` | Reprovado; nao usar |
| `auditoria/03_ondas/onda_33_v206_fix_relatorios_pdf_precondicao/05_PROCEDIMENTO_IMPORT_MICRO62_FIX2.md` | Reprovado; nao usar |

## Proxima Acao Tecnica

Antes de retomar Onda 33 ou iniciar Onda 34:

1. Exportar todos os componentes da V5 para:

   ```text
   /Users/macbookpro/Projetos/Credenciamento/local-ai/incoming/V206_ANCHOR_V5_20260524/
   ```

2. Comparar o export bruto da V5 contra `src/vba/`.
3. Classificar divergencias como:
   - esperado de workbook congelado V205;
   - drift de designer/formulario;
   - diferenca real que precisa de decisao humana.
4. Somente depois disso preparar novo microdelta.

## Ordem Recomendada V206 Apos V5

1. MD33-restart: corrigir os dois relatorios em pacote novo, pequeno e
   rebaseado na V5.
2. Gate humano: compile disponivel ou RVS/smoke equivalente sem fechamento do
   Excel.
3. Onda 34: criar `Util_PDF.bas`, sem tocar `Svc_*`.
4. Onda 35: integrar PDF em Pre-OS, OS, Avaliacao e Relatorios.
5. Onda 36: bateria isolada UI/PDF por simulacao, fora do RVS.
6. Onda 37: jornada humana, RC e freeze.

## Fora de Escopo Nesta Micro-Onda

- Nao alterar VBA funcional.
- Nao criar motor PDF.
- Nao reabrir RN-01 a RN-17.
- Nao alterar contadores RVS.
- Nao mover `doc/`.
- Nao tocar `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas` ou
  `Svc_PreOS.bas`.
