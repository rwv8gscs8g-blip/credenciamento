---
titulo: Onda 0173 — C16 aviso curto legivel fix1
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-09
---

# Onda 0173 — C16 aviso curto legivel fix1

## Contexto

A consolidacao 0172 registrou VCR aprovada e testes dirigidos verdes, mas
classificou como FORTE a falha visual do C16 nos PDFs 079-082. A onda 0169
corrigiu o alinhamento distribuido, porem manteve o diagnostico completo em uma
linha unica com `ShrinkToFit`. O resultado visual foi uma linha presente, mas
pequena demais para leitura humana confiavel.

## Mudanca aplicada

`Rel_Rodizio_Status.bas` ganhou um helper curto para o aviso operacional. Ele
resume status, disponibilidade e contadores `NB` e `RP`, preservando a leitura
composta introduzida na 0170 para empresa suspensa com OS ou Pre-OS pendente.

`Preencher.bas` passou a escrever esse resumo curto em `C16` e desativou o
`ShrinkToFit`. O diagnostico completo continua sendo produzido pelo helper
anterior e permanece anexado ao campo de observacoes nos documentos que ja usam
`Preencher_ObservacaoComAviso`.

## Teste

A suite `TV2_RunRelatoriosSuspensoesStrikesReset` foi atualizada para 13
cenarios. O novo cenario
`RELSSR_13_IMPRESSOS_C16_AVISO_CURTO_LEGIVEL` valida que:

- C16 usa o helper curto.
- O diagnostico completo continua referenciado para observacoes.
- `ShrinkToFit` permanece desativado.

Resultado esperado apos import/compile:

```text
TV2_RunRelatoriosSuspensoesStrikesReset
OK=13 | FALHA=0 | MANUAL=0
```

## Saneamento AAX

O worktree inicial estava sujo apenas no espelho
`local-ai/vba_import/001-modulo/AAX-App_Release.bas`, com timestamp humano
pos-import e linhas finais. Esta onda nao fez reset/revert. A solucao foi
atualizar `src/vba/App_Release.bas` de forma intencional para o novo build e
republicar os espelhos pelo `publicar_vba_import_v2`, preservando a regra
documentada de normalizacao do pacote.

## Pacote

Manifesto V3:
`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_40_C16_AVISO_CURTO_LEGIVEL_FIX1.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_40_C16_AVISO_CURTO_LEGIVEL_FIX1", "349b2b6+ONDA38.2.40-C16-AVISO-CURTO-FIX1"
```

Import esperado: `M=5 | F=0 | err=0 | skip=0`.

## Arquivos

- `src/vba/App_Release.bas`
- `src/vba/Preencher.bas`
- `src/vba/Rel_Rodizio_Status.bas`
- `src/vba/Teste_V2_Engine.bas`
- `src/vba/Teste_V2_Roteiros.bas`
- espelhos correspondentes em `local-ai/vba_import/001-modulo/`
- manifesto delta, procedimento, changelog, manual, guia de testes e HBN

## Nao feito

- Nao houve mudanca em `.frm` ou `.frx`.
- Nao houve mudanca em `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`
  ou `ThisWorkbook`.
- Nao houve mudanca no motor de rodizio, expiracao, recusa ou fila.
- Nao houve VCR nesta onda; o checkpoint forte fica para depois do gate visual.
- A IA nao executou importacao no workbook, compile VBE ou TV2 dentro do Excel.

## Proxima acao

Depois do gate humano da 0173, seguir a validacao tela a tela. Em seguida,
abrir onda de auditoria/planejamento para revisar pendencias de handoffs
anteriores, definir checklist final de estabilidade V12.0.0206 e separar o que
fica para a V12.0.0207 de refatoramento controlado.
