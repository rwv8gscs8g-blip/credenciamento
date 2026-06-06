---
titulo: Onda 38.2.13 - Auditoria cruzada consolidada
diataxis: onda
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-01
---

# Onda 38.2.13 - Auditoria cruzada consolidada

## Escopo confirmado

Readback: `.hbn/readbacks/0129-rb-onda-38-2-13-auditoria-cruzada-consolidada.json`
Hearback: `.hbn/hearbacks/0129-rb-onda-38-2-13-auditoria-cruzada-consolidada-confirmed.json`

Objetivo: consolidar o estado das ondas 38.2.4 a 38.2.12 contra o parecer
0024 e contra a auditoria externa colada por Mauricio, sem implementar codigo.

## Resultado

Artefato principal:

- `.hbn/proposals/0033-consolidacao-auditoria-cruzada-38-2-4-a-38-2-12.md`

Veredito operacional:

- deltas 38.2.4 a 38.2.12 seguem aproveitaveis, sem recomendacao de rollback;
- freeze V12.0.0206 segue bloqueado;
- FT-4 credenciamento em lote nao deve ser a proxima onda;
- proxima onda recomendada: 38.2.14, behavioralizacao da bateria/C1.

## Decisao tecnica

A fragilidade dominante nao e mais ausencia de codigo para varios itens do
0024. O problema atual e a forca da prova: muitos testes novos validam tokens
de codigo-fonte via `TV2_EST_*`, enquanto o L43 revelou defeitos dependentes de
base real, caminho de UI, documento impresso e estado salvo/reaberto.

Por isso, a ordem recomendada muda:

1. fortalecer a rede de testes comportamentais;
2. fechar BL-4 e impressao fase 2;
3. so entao abrir FT-4, com teste de sequencia `CRED_ID`/AR1 e tempo.

## Limites preservados

Esta onda nao altera:

- `src/vba/`;
- `local-ai/vba_import/`;
- `.frx`;
- `Auto_Open.bas`;
- `Mod_Types.bas`;
- `Importador_V3.bas`;
- `Credencia_Empresa.frm`.

Tambem nao declara freeze V206.

## Proxima acao proposta

Abrir readback safe_track 0130 para **Onda 38.2.14 - Behavioralizacao da
bateria/C1**, com escopo inicial em testes V2 e fixtures controladas. A onda
deve substituir ou complementar asserts estaticos por verificacoes executadas
antes de qualquer otimizacao de credenciamento em lote.
