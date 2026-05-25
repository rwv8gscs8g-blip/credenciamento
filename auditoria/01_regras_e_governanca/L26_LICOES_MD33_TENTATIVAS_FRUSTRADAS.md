---
titulo: L26 — Licoes MD33 tentativas frustradas
diataxis: explanation
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
---

# L26 — Licoes MD33 tentativas frustradas

## Contexto

A Onda 33 tentou corrigir os relatorios `Rel_OSEmpresa` e `Rel_Emp_Serv`
antes do motor PDF. As tres tentativas importaram pelo Importador V3, mas o
compile manual no VBE fechou o Excel. A V5, derivada da V12.0.0205 oficial,
passou a ser a unica ancora operacional conhecida que compila.

## Tentativas

| Tentativa | O que tentou | Sintoma observado | Hipotese descartada | Licao |
|---|---|---|---|---|
| MD33-0 / `MICRO62-V206-MD33-0` | Corrigir relatorios a partir do menu e do preenchimento existente. | Import passou, mas o compile VBE ficou preso e fechou o Excel. | "Import OK implica delta seguro para compile." | Importador V3 verde nao substitui compile humano; delta de form/menu pode quebrar em etapa posterior. |
| fix1 / `MICRO62-V206-MD33-0-fix1` | Reduzir risco de crash importando `Preencher.bas` junto com form, mantendo assinatura coerente. | Import passou (`M=1/F=1`), mas o compile fechou o Excel novamente. | "Assinatura coerente entre chamador e preenchimento basta." | Quando compile fecha o Excel, a hipotese local nao esta confirmada; nao insistir com variacoes pequenas sem reancoragem limpa. |
| fix2 / `MICRO62-V206-MD33-0-fix2` | Evitar novo import de `Menu_Principal.frm` e importar apenas Preencher + dois relatorios. | Documentado como historico reprovado; V5 substituiu a rota operacional. | "Remover o menu do delta resolve a contaminacao." | Se a base de workbook esta contaminada ou nao compila, fixes incrementais sobre ela deixam de ser fonte confiavel. |

## Regras derivadas

1. Toda tentativa safe_track reprovada precisa produzir knowledge de
   reprovacao antes do proximo readback funcional.
2. Quando o workbook fecha no compile, nao usar o estado importado como base
   para novo microdelta.
3. O proximo readback deve declarar explicitamente quais arquivos do delta
   reprovado serao revertidos, preservados ou tratados como pendencia.
4. Backups em `backups/vba/` sao evidencia e diagnostico; nunca fonte
   operacional de importacao.
5. A frase "src/vba e fonte de verdade" nao autoriza importar drift que veio
   de tentativa reprovada. Fonte de verdade tambem precisa representar um
   estado importavel que compila.

## Referencias

- `auditoria/00_status/100_PAUSA_REBASE_PLANILHA_LIMPA_V206_CODEX.md`
- `auditoria/00_status/101_ANCHOR_V5_REINICIO_V206_CODEX.md`
- `auditoria/03_ondas/onda_33_v206_fix_relatorios_pdf_precondicao/01_TECNICO_ONDA33_FIX_RELATORIOS.md`
- `auditoria/03_ondas/onda_33_v206_fix_relatorios_pdf_precondicao/02_PROCEDIMENTO_IMPORT_MICRO62.md`
- `auditoria/03_ondas/onda_33_v206_fix_relatorios_pdf_precondicao/03_PROCEDIMENTO_IMPORT_MICRO62_FIX1.md`
- `auditoria/03_ondas/onda_33_v206_fix_relatorios_pdf_precondicao/05_PROCEDIMENTO_IMPORT_MICRO62_FIX2.md`
