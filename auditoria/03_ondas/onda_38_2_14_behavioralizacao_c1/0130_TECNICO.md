---
titulo: Onda 38.2.14 - behavioralizacao C1
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-01
---

# Onda 38.2.14 - Behavioralizacao C1

## Contexto

A auditoria cruzada 38.2.13 consolidou que as ondas 38.2.4 a 38.2.12 sao
aproveitaveis com ressalvas, mas o freeze V206 continua bloqueado por C1, C4
e C5. O proximo passo recomendado foi criar uma rede de testes
comportamentais antes de abrir FT-4 credenciamento em lote.

Esta onda implementa a primeira fatia de C1 somente em testes V2. Nao ha
alteracao em codigo de producao, formularios, `.frx`, `Auto_Open.bas`,
`Mod_Types.bas` ou `Importador_V3.bas`.

## Readback e hearback

- Readback: `.hbn/readbacks/0130-rb-onda-38-2-14-behavioralizacao-c1.json`
- Hearback: `.hbn/hearbacks/0130-rb-onda-38-2-14-behavioralizacao-c1-confirmed.json`
- Confirmacao humana: Mauricio confirmou em chat o readback 0130.
- Track: `safe_track`

## Mudancas entregues

- `src/vba/Teste_V2_Engine.bas`
  - helper de round-trip real do snapshot CONFIG A:N.
  - helper de sequencia `ProximoId(CREDENCIADOS)` com AR1 atrasado em base populada.
  - helper de varredura de `CRED_ID` canonico, numerico e unico por atividade.
- `src/vba/Teste_V2_Roteiros.bas`
  - nova suite dirigida `TV2_RunBehavioralizacaoC1`.
  - cinco asserts automaticos C1:
    - `CS_C1_01_CONFIG_SNAPSHOT_ROUNDTRIP`
    - `CS_C1_02_ORDENACAO_ENTIDADE_BASE_POPULADA`
    - `CS_C1_03_CRED_ID_AR1_SEQUENCIAL`
    - `CS_C1_04_CRED_ID_CANONICO_UNICO`
    - `CS_C1_05_FILA_ORDEM_INTEGRA`
- `src/vba/App_Release.bas`
  - build importado marcado como `e157221+ONDA38.2.14-BEHAVIORALIZACAO-C1`.
- `CHANGELOG.md`
  - registro da onda e do nao-freeze.
- `local-ai/vba_import/`
  - espelho V3 sincronizado para os tres modulos importaveis.
  - manifesto delta criado em `000-MANIFESTO-V3-DELTA-ONDA38_2_14_BEHAVIORALIZACAO_C1.txt`.

## Pacote V3

Manifesto operacional:

- `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_14_BEHAVIORALIZACAO_C1.txt`

Arquivos hash-pinados no manifesto:

| Tipo | Arquivo | SHA-256 |
|---|---|---|
| M | `001-modulo/ABF-Teste_V2_Engine.bas` | `c8ff3e74c7c652d79120ab7df8e8b17f2f4f469adb7a7794524cd504d996723d` |
| M | `001-modulo/ABG-Teste_V2_Roteiros.bas` | `ca7ea98967094e24693528f7c7dd3962520cd16c8c42d4838dbcb77f1d2931eb` |
| M | `001-modulo/AAX-App_Release.bas` | `7122716494a97d827cfe7a3fa0529e34584ad48fcefdbcde3e90678b8f40e115` |

## Gate humano

Gate solicitado:

1. Importador V3 do delta 38.2.14.
2. `Debug > Compile VBAProject`.
3. Suite `TV2_RunBehavioralizacaoC1`.

Resultado reportado por Mauricio em 2026-06-01:

- Importador V3: `modo=Estabilizado | dryRun=False | M=3 | F=0 | err=0 | skip=0`
- Compile: passou limpo.
- Suite: `TV2_20260601_093826`
- Resultado: `OK=5 | FALHA=0 | MANUAL=0`
- CSV de falhas: nao exportado, sem falhas.

Com isso, a primeira fatia C1 desta onda fica validada no workbook.

## Validacoes locais

- `publicar_vba_import_v2.py check` passou para `Teste_V2_Engine.bas`,
  `Teste_V2_Roteiros.bas` e `App_Release.bas`.
- Glasswing G7/G8 passou no publicador.
- `validate-readback.sh` passou para o readback 0130.
- `jsonschema` validou o hearback 0130 contra o schema local.
- `git diff --check` passou limpo antes do ERP.
- `scripts/hbn-guards/hbn-guards-runner.sh` passou com readback ativo 0130
  confirmado e sem arquivos staged fora de escopo.

## Pendencias preservadas

- FT-4 credenciamento em lote nao foi aberto nesta onda.
- C1 ainda nao deve ser declarado totalmente fechado: esta e a primeira fatia
  comportamental focada nos riscos que antecedem FT-4.
- Proxima onda recomendada: abrir readback safe_track de FT-4 credenciamento
  em lote, com teste V2 de sequencia `CRED_ID`/AR1 e tempo de execucao.
- Freeze V206 segue bloqueado ate nova auditoria e gates posteriores.
