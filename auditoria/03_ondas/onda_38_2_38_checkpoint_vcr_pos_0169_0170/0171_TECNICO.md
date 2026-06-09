---
titulo: Onda 0171 — Checkpoint VCR pos-0169/0170
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-08
---

# Onda 0171 — Checkpoint VCR pos-0169/0170

## Objetivo

Preparar um checkpoint forte de Validacao Completa da Release depois dos
pacotes 0169 e 0170.

Esta onda e documental. Ela nao altera codigo, nao altera pacote importavel e
nao executa VCR. A execucao continua sendo humana, no workbook.

## Por que agora

As ondas recentes tocaram pontos visiveis e compartilhados dos relatorios:

- 0169 corrigiu a legibilidade do aviso operacional em `C16:N16` nos impressos.
- 0170 tornou a disponibilidade mais informativa quando ha suspensao e ocupacao
  simultaneas na mesma atividade.

Antes de continuar microcorrecoes tela a tela rumo ao congelamento da
V12.0.0206, o operador precisa de uma ordem unica para validar que os deltas
foram importados em sequencia e que os testes dirigidos estao verdes antes da
VCR.

## Contrato do checkpoint

1. Importar 0169 se ela ainda nao estiver aplicada no workbook.
2. Importar 0170.
3. Compilar no VBE.
4. Rodar `TV2_RunTelaRelatorios`.
5. Rodar `TV2_RunRelatoriosSuspensoesStrikesReset`.
6. Conferir visualmente os pontos afetados quando houver evidencias/PDFs.
7. Rodar `CT_ValidarRelease_Completa` somente se os passos anteriores estiverem
   verdes.

## Evidencia esperada do operador

Colar no proximo hearback:

- resultado de import da 0169, se executada;
- resultado de import da 0170;
- compile limpo ou primeira falha;
- ID/resultado do `TV2_RunTelaRelatorios`;
- ID/resultado do `TV2_RunRelatoriosSuspensoesStrikesReset`;
- ID/resultado da VCR;
- caminho do CSV de evidencia quando houver;
- primeira falha, se a VCR reprovar.

## Decisao apos VCR

- Se a VCR reprovar: nao congelar; abrir nova onda com a primeira falha
  concreta.
- Se a VCR aprovar: consolidar evidencia e continuar a validacao tela a tela
  antes de declarar freeze.

## Nao feito

- Nenhuma alteracao em `src/vba/`.
- Nenhuma alteracao em `local-ai/vba_import/`.
- Nenhum teste Excel/VBE executado pela IA.
