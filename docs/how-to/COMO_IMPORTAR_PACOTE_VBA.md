# Como importar pacote VBA - Importador V2

> Diataxis: How-to (passo a passo orientado a tarefa).
> Para visao conceitual, ver [`docs/explanation/IMPORTADOR_V2.md`](../explanation/IMPORTADOR_V2.md).
> Para especificacao, ver [`docs/reference/MANIFESTO_FORMAT.md`](../reference/MANIFESTO_FORMAT.md).

## Pre-requisitos

1. Voce e contribuidor com **CLA assinado** (ou mantenedor).
2. Voce **recebeu o pacote `local-ai/`** descompactado em
   `Projetos/Credenciamento/local-ai/`. Ver
   [`COMO_OBTER_FERRAMENTAS_VBA.md`](COMO_OBTER_FERRAMENTAS_VBA.md).
3. Workbook `PlanilhaCredenciamento-*.xlsm` aberto.
4. **VBOM habilitado** em
   `Excel > Opcoes > Centro de Confiabilidade > Configuracoes de Macro >
   Confiar no acesso ao modelo de objeto do projeto VBA`.

## Cenario A — Workbook estabilizado (caso comum)

Voce tem um workbook que ja passa no trio minimo (V1 + V2 Smoke + V2
Canonica) e quer aplicar um pacote V2 atualizado.

### Passo 1 - Importar o `Importador_V2.bas` no workbook

So precisa fazer 1 vez por workbook (ou quando Importador V2 mudar):

1. Abrir VBE (`Alt+F11` no Windows, `Option+Cmd+F11` no Mac).
2. Se `Importador_V2` ja estiver listado em Modulos: clique direito >
   Remover Importador_V2 > **Nao** salvar export.
3. Arquivo > Importar Arquivo > selecionar
   `local-ai/vba_import/001-modulo/ABK-Importador_V2.bas`.

### Passo 2 - Status

Na janela imediata (`Ctrl+G`), digite:

```
ImportarPacoteV2_Status
```

Esperado: dump do manifesto com 11 grupos e ~49 itens (depende de
release). Se aparecer `STATUS: AUSENTE`, o pacote `local-ai/` nao foi
descompactado.

### Passo 3 - DryRun (sempre antes do real)

```
ImportarPacoteV2_DryRun
```

Esperado: MsgBox `Importados: N, Skipped: 1, Erros: 0`. O `Skipped: 1`
e o tabu `Mod_Types`. Aba `IMPORT_LOG_V2` populada com ~50 linhas
mostrando o que o import faria.

Se houver `Erros > 0`: investigar a aba `IMPORT_LOG_V2`, coluna
`STATUS = err`. Nao prosseguir para o passo 4 ate `Erros = 0`.

### Passo 4 - Import real

```
ImportarPacoteV2
```

O Importador:

1. Faz backup do projeto VBA inteiro em `backups/vba/<ts>-V2-FULL/`.
2. Purge fantasmas (modulos com sufixo numerico).
3. Importa por grupo, validando compilacao apos cada grupo.
4. Mod_Types e pulado (tabu, hash bate ou e `would_skip`).
5. `.frm` em workbook estabilizado importa via `.code-only.txt`
   (preserva `.frx`).

Esperado: MsgBox final com `Importados: ~48, Skipped: 1, Erros: 0`.

### Passo 5 - Validar trio minimo

No Excel, abra a aba `VALIDACAO_RELEASE` e execute o trio minimo
(V1 Rapida + V2 Smoke + V2 Canonica). Esperado: `RESULTADO_GERAL =
APROVADO`.

Se algum teste falhar: rollback manual a partir de
`backups/vba/<ts>-V2-FULL/` (importar cada `.bas`/`.frm` manualmente).

## Cenario B — Workbook limpo / fresh

Voce esta criando um workbook do zero a partir de
`PlanilhaCredenciamento-Modelo.xlsx`.

Diferencas vs. cenario A:

- **Mod_Types e importado** (workbook nao tem ainda).
- **`.frm` importa como `.frm + .frx`** (nao via `.code-only.txt`).

Demais passos identicos.

## Cenario C — Aplicar 1 grupo so (debug)

Util quando voce quer iterar em um grupo especifico sem mexer no resto:

```
ImportarPacoteV2_Grupo "BASE"
```

O argumento e a substring do header do grupo. Aceita `BASE`, `INFRA`,
`REPOS`, `SERVICES`, `DOMAIN`, `RELEASE`, `STARTUP`, `TESTS`, `FORMS`.

Compilacao e validada apos o grupo. Outros grupos sao logados como
`skipped (filtro de grupo: ...)`.

## Cenario D — Algo deu errado

### Mensagem `Importador V2 ABORTADO: Fase: X_..., Err N: ...`

A fase indica em qual etapa o erro ocorreu:

- `1_VBOM_CHECK` — VBOM nao habilitado (ver pre-requisitos).
- `2_LOCALIZAR_MANIFESTO` — pacote `local-ai/` ausente ou path errado.
- `3_GARANTIR_PLANILHA_LOG` — falha ao criar aba `IMPORT_LOG_V2`
  (raro — workbook protegido?).
- `4_BACKUP` — falha ao escrever em `backups/vba/...`. Permissao de
  pasta? Disco cheio?
- `5_PURGE_FANTASMAS` — falha ao remover modulo fantasma. Workbook
  protegido?
- `6_LER_MANIFESTO` — manifesto corrompido (raro).
- `6_GRUPO_N_PROCESSAR` — falha em algum item do grupo N. Olhar
  `IMPORT_LOG_V2` linhas com `STATUS = err`.
- `6_GRUPO_N_COMPILE` — modulos importados nao compilam juntos. Causa
  comum: dependencia faltando (e.g., um modulo de BASE foi pulado).
  Restaurar do backup e investigar.
- `7_LOG_FIM` — falha cosmetica (log final). Import ja completou.

### Mensagem `Err 0:` (engolido)

Significa que erro foi engolido por sub interna com `On Error Resume
Next`. Use a fase para localizar — ela permanece valida.

### Workbook ficou inconsistente apos crash

Rollback manual:

1. Fechar o workbook **sem salvar**.
2. Abrir backup mais recente em `backups/vba/<ts>-V2-FULL/`.
3. Importar cada `.bas`/`.frm` manualmente.

Em ultimo caso, voltar ao snapshot anterior do workbook em
`backups/credenciamento/` (fora do repo, em `~/Projetos/backups/`).

## Pos-import: validacao Glasswing

Apos qualquer import bem-sucedido, e bom rodar:

```
bash local-ai/scripts/glasswing-checks.sh
```

Esperado: 5 OK + 2 WARN + 1 MANUAL. `VIOLATED` em qualquer vetor pede
investigacao.

## Apoio cruzado

- [`docs/explanation/IMPORTADOR_V2.md`](../explanation/IMPORTADOR_V2.md)
  — visao conceitual.
- [`docs/reference/MANIFESTO_FORMAT.md`](../reference/MANIFESTO_FORMAT.md)
  — especificacao do contrato.
- [`docs/explanation/MODELO_DE_ACESSO_CONTROLADO.md`](../explanation/MODELO_DE_ACESSO_CONTROLADO.md)
  — por que o pacote e CLA-controlado.
- [`.hbn/knowledge/0008-importador-v2-arquitetura.md`](../../.hbn/knowledge/0008-importador-v2-arquitetura.md)
  — knowledge HBN-native.
