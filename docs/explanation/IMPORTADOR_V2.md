# Importador V2 - Visao conceitual

> Diataxis: Explanation. Para passo a passo, ver
> [`docs/how-to/COMO_IMPORTAR_PACOTE_VBA.md`](../how-to/COMO_IMPORTAR_PACOTE_VBA.md).
> Para especificacao do contrato, ver
> [`docs/reference/MANIFESTO_FORMAT.md`](../reference/MANIFESTO_FORMAT.md).

## O que e

O Importador V2 (`Importador_V2.bas`) e um modulo VBA do produto
Credenciamento responsavel por trazer codigo do pacote oficial
(`local-ai/vba_import/`) para dentro de um workbook `.xlsm`. Substitui o
Importador_VBA legacy.

E **publico** (vai pro repositorio `src/vba/`). Mas o pacote que ele
consome (`local-ai/vba_import/`) e CLA-controlado e distribuido
separadamente — ver
[`MODELO_DE_ACESSO_CONTROLADO.md`](MODELO_DE_ACESSO_CONTROLADO.md).

## Por que existe (lado historico)

Durante as Ondas 1-5 do projeto Credenciamento, em uma janela de
homologacao, ocorreu uma regressao significativa: 30+ arquivos VBA
ficaram desincronizados entre `src/vba/` (fonte de verdade) e o pacote
de import. Sintomas variados:

- Formularios viraram modulos no VBE.
- `Util_Config` defasada quebrou Onda 1.
- `Mod_Limpeza_Base` cacheado quebrou `Preencher`.
- `Configuracao_Inicial` foi importado como modulo por bug de encoding.

A causa raiz nao foi acidental — foi uma **regressao explicita** causada
pela ausencia de mecanismos de protecao na ferramenta de import. O
Importador V1 lia direto de `src/vba/`, sem normalizacao, sem checagem
de hash, sem ordenacao topologica, sem persistencia, sem tabu.

A Onda 9 antecipou a reescrita para tratar a causa raiz, e o Importador
V2 e o resultado.

## Como pensa

O Importador V2 trata import como uma **transacao auditavel**, nao como
uma colecao de comandos isolados. Quatro principios estruturam o design:

### 1. Manifesto e a unica fonte de verdade

A ferramenta nao decide o que importar — ela **executa** o que o
manifesto declara. O manifesto vive em
`local-ai/vba_import/000-MANIFESTO-IMPORTACAO.txt` e e regenerado
automaticamente pelo `publicar_vba_import_v2.sh --apply`. Nao se edita
manualmente.

Especificacao formal em
[`MANIFESTO_FORMAT.md`](../reference/MANIFESTO_FORMAT.md).

### 2. Ordenacao topologica em 9 grupos

Modulos VBA tem dependencias de compilacao implicitas. Importar fora de
ordem causa erros que mascaram a causa real. O manifesto declara grupos
nesta ordem fixa:

1. **TYPES** — `Mod_Types` (tabu, ver abaixo)
2. **BASE** — constantes, identidade, utils basicos
3. **INFRA** — logging, contexto, error boundary, transacao
4. **REPOS** — repositorios CRUD que tocam abas
5. **SERVICES** — logica de negocio
6. **DOMAIN** — operacoes que tocam varias abas
7. **RELEASE** — `App_Release` (identidade do build)
8. **STARTUP** — `Auto_Open` (entry point)
9. **TESTS** — cenarios automatizados
10. **FORMS** — apos todos os modulos

Em modo real, **compilacao e validada apos cada grupo**. Se um grupo
quebra, os anteriores ja foram aplicados (ficam no workbook), mas os
posteriores nao sao tocados. Backup completo do projeto VBA fica em
`backups/vba/<ts>-V2-FULL/`.

### 3. Tabu Mod_Types

`Mod_Types` contem todos os `Public Type` do projeto. Mover Types entre
modulos causa erros sutis (tipo `TConfig duplicado`) que sao dificeis de
diagnosticar. Decisao arquitetural: **`Mod_Types` so e modificado em
intervencao explicita aprovada pelo mantenedor (Onda 9 plena)**.

Em import incremental (caso 99% das vezes), o Importador V2 aplica a
regra:

- Se `Mod_Types` ja existe no workbook → SKIP incondicional.
- Se `Mod_Types` ausente (workbook fresh) → importa.

A protecao contra divergencia real fica nas camadas a montante:
**Glasswing G7** (sincronizacao `src/vba` ↔ `vba_import`),
**publicar_vba_import_v2** (detecta mudanca em `src/vba/Mod_Types.bas`),
e **git pre-commit hook** (bloqueia commit que viole G7+G8).

### 4. Backup automatico antes de import real

Toda chamada a `ImportarPacoteV2()` (modo real) faz export completo do
projeto VBA atual para `backups/vba/<ts>-V2-FULL/` antes de tocar
qualquer coisa. Rollback manual sempre possivel — basta importar de
volta cada `.bas`/`.frm` da pasta de backup.

DryRun (`ImportarPacoteV2_DryRun()`) **nao** faz backup nem altera nada;
apenas registra na aba `IMPORT_LOG_V2` o que faria em modo real.

## Quatro APIs publicas

| Sub | Modifica workbook? | Quando usar |
|---|---|---|
| `ImportarPacoteV2()` | sim | aplicar pacote completo (release) |
| `ImportarPacoteV2_DryRun()` | nao | simular antes de aplicar real |
| `ImportarPacoteV2_Grupo("BASE")` | sim | aplicar 1 grupo so (debug) |
| `ImportarPacoteV2_Status()` | nao | dump do estado + manifesto |

Apenas `ImportarPacoteV2()` modifica workbook. Padrao recomendado:
**sempre rodar DryRun primeiro**.

## Auditabilidade

Aba `IMPORT_LOG_V2` e a fonte de verdade auditavel. Cada evento
(INICIO, BACKUP, grupo_inicio, item, compile, FIM, FALHA_FATAL) gera
uma linha com timestamp, modulo, caminho, detalhes, status. Append-only
durante o run (Glasswing G4).

Para auditor externo, isso significa: **todo import deixa rastro**, e o
rastro fica no proprio workbook (nao em log volatil de console).

## Cross-platform (Mac vs Windows)

Excel para Mac e Excel Windows divergem no tratamento de EOL ao usar
`Line Input`. Em alguns cenarios no Mac, o manifesto inteiro era lido
como uma unica linha gigante.

Solucao: leitura de arquivos sempre via `Open caminho For Binary Access
Read` + normalizacao de EOL. O helper `IV2_LerArquivoBinarioComoTexto`
abstrai isso. Funciona igual em Mac e Windows.

## Diagnostico de falha (instrumentacao)

O handler `falha:` em `IV2_RodarMain` registra:

- **`faseAtual`** — em qual etapa do fluxo o erro ocorreu
  (`1_VBOM_CHECK`, `2_LOCALIZAR_MANIFESTO`, ..., `6_GRUPO_N_PROCESSAR`,
  `7_LOG_FIM`).
- **Snapshot de Err** — captura `Err.Number/Description/Source`
  imediatamente, antes de qualquer call que possa limpar Err em sub
  aninhada com `On Error Resume Next`.

Em VBA, e comum que sub aninhada com OERN limpe Err do escopo
chamador, levando a mensagens "Err 0:" sem informacao util. A fase
permanece valida mesmo nesse cenario, e o operador (ou agente IA) pode
localizar o problema sem ter que rodar tracing manual.

## Limitacoes conhecidas

1. **Hash heuristico** (tamanho + n linhas + first/last byte) e fragil.
   Suficiente para detectar mudancas grosseiras, nao substitui MD5. Por
   isso o tabu Mod_Types nao depende mais dele — e Glasswing G7 usa
   md5sum a montante.
2. **`.frm` em workbook estabilizado** depende de `.code-only.txt`
   correspondente. Se o pacote nao tiver `.code-only.txt`, o Importador
   cai no fallback de importar `.frm + .frx` normalmente — o que pode
   sobrescrever renomeacoes do designer. Workbook fresh nao tem esse
   problema.
3. **VBOM (acesso ao modelo VBA)** precisa estar habilitado. Em Excel
   bloqueado, o Importador aborta com mensagem clara apontando o
   caminho de configuracao.

## Onde se conecta no resto da arquitetura

```
                       ┌─────────────────────────┐
                       │  src/vba/ (fonte verdade)│
                       └────────────┬────────────┘
                                    │
                       publicar_vba_import_v2.sh
                       (normaliza, valida G7+G8,
                        gera manifesto)
                                    │
                                    ▼
                  ┌─────────────────────────────────┐
                  │  local-ai/vba_import/           │
                  │  (CLA-controlado, gitignored)    │
                  │  - 000-MANIFESTO-IMPORTACAO.txt │
                  │  - 000-MAPA-PREFIXOS.txt        │
                  │  - 001-modulo/*.bas             │
                  │  - 002-formularios/*.frm/.frx   │
                  │  - 002-formularios/*.code-only.txt
                  └────────────┬────────────────────┘
                               │
                  ImportarPacoteV2_DryRun() / V2()
                               │
                               ▼
              ┌────────────────────────────────────┐
              │  PlanilhaCredenciamento-*.xlsm     │
              │  + IMPORT_LOG_V2 (auditavel)       │
              │  + backups/vba/<ts>-V2-FULL/       │
              └────────────────────────────────────┘
```

A montante de tudo isso, **git pre-commit hook** valida G7+G8 a cada
commit que toque VBA, garantindo que o pacote nunca diverge do `src/vba`
no historico.
