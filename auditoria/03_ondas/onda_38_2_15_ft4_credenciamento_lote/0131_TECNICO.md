---
titulo: Onda 38.2.15 - FT-4 credenciamento em lote
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-01
---

# Onda 38.2.15 - FT-4 credenciamento em lote

## Contexto

A Onda 38.2.14 validou a primeira fatia C1 no workbook
(`TV2_20260601_093826`, `OK=5 | FALHA=0 | MANUAL=0`). Com essa rede inicial
verde, Mauricio confirmou o readback 0131 para abrir FT-4.

O alvo do parecer 0024 era o custo O(n^2) em `CR_Credenciar_Click`: o fluxo
chamava `ProximoId(SHEET_CREDENCIADOS)` dentro do loop de servicos, e cada
chamada podia desproteger/reproteger e varrer a aba para reconciliar AR1 com o
maior `CRED_ID` real.

## Readback e hearback

- Readback: `.hbn/readbacks/0131-rb-onda-38-2-15-ft4-credenciamento-lote.json`
- Hearback: `.hbn/hearbacks/0131-rb-onda-38-2-15-ft4-credenciamento-lote-confirmed.json`
- Confirmacao humana: Mauricio confirmou em chat o readback 0131.
- Track: `safe_track`

## Mudancas em codigo

### `Credencia_Empresa.frm`

O handler de UI continua validando empresa, atividade, mensagens, salvamento e
limpeza de estado do formulario. O miolo de escrita foi extraido para um
executor de lote privado, reaproveitado por uma superficie publica minima de
teste.

Mudancas funcionais:

- calcula uma base unica para `CRED_ID` por lote:
  `max(AR1, Util_MaxIdOperacional(CREDENCIADOS))`;
- incrementa `CRED_ID` em memoria a cada novo credenciamento;
- escreve AR1 uma unica vez ao final quando ha novos credenciamentos;
- calcula proxima linha e proxima posicao de fila uma vez e incrementa
  localmente;
- cria indice local dos credenciamentos existentes da empresa para evitar
  varredura repetida no caminho comum;
- preserva `RegistrarEvento` por credenciamento novo, validacao de
  persistencia, classificacao, atualizacao do menu e salvamento automatico no
  fluxo de UI.

Inalterado:

- a regra segue credenciando a empresa em todos os servicos da atividade
  selecionada;
- duplicidades seguem ignoradas;
- nenhum `.frx` ou layout foi alterado.

### Testes V2

Nova suite dirigida:

- `TV2_RunFT4CredenciamentoLote`

Cenarios/asserts:

1. `FT4_01_PREPARA_BASE_POPULADA`
2. `FT4_02_LOTE_ADICIONA_TODOS_SERVICOS`
3. `FT4_03_CRED_ID_SEQUENCIAL_CONTINUO`
4. `FT4_04_AR1_ATUALIZADO_UMA_VEZ`
5. `FT4_05_TEMPO_EXECUCAO_LOTE`
6. `FT4_06_REEXECUCAO_IDEMPOTENTE`

Resultado esperado no workbook:

- `OK=6 | FALHA=0 | MANUAL=0`
- `FT4_05_TEMPO_EXECUCAO_LOTE` com tempo <= 10 segundos.

## Pacote V3

Manifesto:

- `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_15_FT4_CREDENCIAMENTO_LOTE.txt`

Arquivos hash-pinados:

| Tipo | Arquivo | SHA-256 |
|---|---|---|
| F | `002-formularios/AAI-Credencia_Empresa.frm` | `6fcb247ef9d983070dbf8be1dd0fc800b108a14eb49ef9121c82384f4e4028ef` |
| code-only | `002-formularios/AAI-Credencia_Empresa.code-only.txt` | `99cb5d3397dacd9b04b142d500421fbcca82c445cb047cad1a48f0a6f2fc975a` |
| M | `001-modulo/ABF-Teste_V2_Engine.bas` | `a1589b6b7ed5b3ebdb92f5ee94672ec50953f174125f2f045b24eae940e5051b` |
| M | `001-modulo/ABG-Teste_V2_Roteiros.bas` | `f465a4e8a60da769c9f1afc0b93f1d1ec5fa830e4a9a93615a55d5816c6daf8f` |
| M | `001-modulo/AAX-App_Release.bas` | `40185fb66f476acf967e2eb4d523b966bfb8a2ab9638da562a230a25d878f61a` |

## Gate humano

Gate solicitado:

1. Importador V3 do delta 38.2.15.
2. `Debug > Compile VBAProject`.
3. Suite `TV2_RunFT4CredenciamentoLote`.

Resultado reportado por Mauricio em 2026-06-01:

- Importador V3: `modo=Estabilizado | dryRun=False | M=3 | F=1 | err=0 | skip=0`
- Compile: passou limpo.
- Suite: `TV2_20260601_102735`
- Resultado: `OK=6 | FALHA=0 | MANUAL=0`
- CSV de falhas: nao exportado, sem falhas.

Com isso, FT-4 fica validado no workbook nesta onda.

## Validacoes locais

- Readback 0131 validado contra schema.
- Hearback 0131 validado contra schema.
- Publicador V2 `check` passou para `Credencia_Empresa.frm`,
  `Teste_V2_Engine.bas`, `Teste_V2_Roteiros.bas` e `App_Release.bas`.
- Glasswing G7/G8 passou no publicador.
- `git diff --check` passou limpo.
- `scripts/hbn-guards/hbn-guards-runner.sh` passou com readback 0131
  confirmado.
- Diff rastreado nao contem `.frx`.

## Pendencias preservadas

- Freeze V206 segue bloqueado.
- BL-4 save/reopen, impressao fase 2, FT-9, FT-10, FT-11 real, RVS sexteto e
  L44 continuam pendentes para ondas posteriores.
- Proxima decisao recomendada: BL-4 save/reopen se Mauricio aceitar tratar
  protecao persistente; alternativa pragmatica: impressao fase 2.
