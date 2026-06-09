---
titulo: Onda 0172 — Consolidacao gate humano PDFs e VCR
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-09
---

# Onda 0172 — Consolidacao gate humano PDFs e VCR

## Findings

### FORTE — C16 ainda nao atende ao gate visual humano

Arquivos:

- `auditoria/evidencias/V12.0.0205/pdf/079_PRE_OS_PROVISORIA_001_C16_PENDENTE.pdf`
- `auditoria/evidencias/V12.0.0205/pdf/080_PRE_OS_PROVISORIA_002_C16_PENDENTE.pdf`
- `auditoria/evidencias/V12.0.0205/pdf/081_OS_001_C16_OS_EXECUCAO.pdf`
- `auditoria/evidencias/V12.0.0205/pdf/082_AVALIACAO_002_C16_OBS_DISPONIVEL.pdf`

Evidencia:

- `pdftotext -layout` ainda extrai `Status da empres a nes ta data`,
  `s tatus`, `dis ponibilidade`, `s us pens a` e tokens semelhantes nos PDFs
  079-082.
- Renderizacao a 300 dpi dos PDFs 079, 081 e 082 mostra que a linha existe,
  mas ficou pequena demais para leitura humana na faixa C16.
- No PDF 082, o aviso repetido em Observacoes aparece legivel, mas C16 segue
  visualmente fraco.

Veredito: VCR aprovada nao fecha este finding visual. Freeze V12.0.0206 deve
continuar bloqueado ate fix1 ou decisao humana explicita aceitando essa
limitacao.

### MARGINAL — Espelho `AAX-App_Release.bas` ficou fora de sync

Arquivo:

- `local-ai/vba_import/001-modulo/AAX-App_Release.bas`

Evidencia:

- Worktree mostra alteracao nao commitada em `APP_BUILD_GERADO_EM`, de
  `2026-06-08 23:48` para `2026-06-09 08:00`, e duas linhas em branco no EOF.
- `src/vba/App_Release.bas` nao foi alterado nesta onda, portanto o espelho
  importavel ficou diferente da fonte de verdade.

Veredito: nao foi corrigido na 0172 para evitar mudanca VBA sem readback
proprio. Deve ser saneado junto do proximo fix ou em micro-onda documental/
sync separada antes de novo pacote importavel.

## Evidencias positivas consolidadas

### Imports e compile

Mauricio reportou:

- 0169 / Onda 38.2.36 importada com `M=4 | F=0 | err=0 | skip=0`;
- compile VBE limpo para a 0169;
- 0170 / Onda 38.2.37 importada com `M=4 | F=0 | err=0 | skip=0`;
- compile VBE limpo para a 0170.

### Testes dirigidos

- `TV2_RunTelaRelatorios`: `TV2_20260609_080134`, `OK=11 | FALHA=0 | MANUAL=0`.
- `TV2_RunRelatoriosSuspensoesStrikesReset`:
  - `TV2_20260609_080247`, `OK=12 | FALHA=0 | MANUAL=0`;
  - `TV2_20260609_081631`, `OK=12 | FALHA=0 | MANUAL=0`.

### VCR

CSV canonizado:

`auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseVCR_V12_0_0205_VR_20260609_082732.csv`

Hash:

```text
15f4816084636ebf9afd7e000492c9c0680267775c84b79b6c32b6b62f5778b7
```

Resultado:

```text
VR_20260609_082732
APROVADO
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0+ImpressaoResidual=7/0+PunicoesDias=8/0
```

### PDFs 083-088

Os relatórios tabulares 083-088 foram copiados para a pasta canonica de
evidencias. A extracao textual confirma status, disponibilidade, strikes e
resumo operacional onde esperado:

- Empresas cadastradas: suspensoes e disponibilidade aparecem.
- Empresas credenciadas: `SUSPENSA ATE`, `PRE-OS PENDENTE`, `OS EM EXECUCAO`
  e `DISPONIVEL` aparecem nos cenarios impressos.
- OS abertas, empresa por servico e OS por empresa mantem status/resumo
  operacional legiveis.

## Veredito

VCR e testes dirigidos estao aprovados. A linha de relatorios tabulares ficou
boa para seguir a validacao tela a tela.

O gate visual da 0169 nao esta fechado. A proxima onda recomendada e uma
0173-fix1 para tornar o aviso operacional dos impressos realmente legivel, sem
depender de `ShrinkToFit` para uma frase longa em uma unica linha.

## Proxima onda recomendada

Abrir readback 0173 com escopo de fix1:

- decidir se C16 deve receber texto curto e o detalhe fica em Observacoes; ou
- quebrar o aviso em duas linhas/campo mais amplo; ou
- remover `ShrinkToFit` e usar fonte/linha dedicada com texto abreviado.

Antes do fix, sanear tambem a divergencia `AAX-App_Release.bas` vs
`src/vba/App_Release.bas`.
