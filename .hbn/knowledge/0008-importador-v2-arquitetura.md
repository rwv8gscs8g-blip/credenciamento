# 0008 — Importador V2: arquitetura e contratos

> Status: canonico. Vigente apos Onda 9 (2026-04-29).
> Substitui o Importador_VBA legacy (descontinuado).

## Por que existe

O Importador V2 nasceu como resposta tecnica e cultural a uma regressao
real ocorrida durante as Ondas 1-5 do projeto Credenciamento, em que a
desincronizacao entre `src/vba/` e o pacote de import (`local-ai/vba_import/`)
causou problemas em massa:

- formularios viraram modulos no VBE por bug de encoding/EOF/em-dash;
- `Util_Config` defasada gerou erros `GetMaxStrikes não definido`;
- `Mod_Limpeza_Base` cacheado quebrou `Preencher`;
- 30+ arquivos divergiram em um unico ciclo de homologacao.

A causa raiz: o Importador V1 (`Importador_VBA.bas`) lia direto de `src/vba/`,
sem normalizacao, sem checagem de hash, sem ordenacao topologica, sem tabu,
e sem log persistente.

V2 fecha essas lacunas com 5 contratos firmes (abaixo).

## Os 5 contratos do Importador V2

1. **Manifesto V2 e a unica fonte de verdade.** O Importador le e processa
   exatamente o que esta em `local-ai/vba_import/000-MANIFESTO-IMPORTACAO.txt`.
   Nao acessa `src/vba/` em nenhum momento. (Regra de Ouro,
   `0002-regra-ouro-vba-import.md`.)

2. **Ordenacao topologica em 9 grupos.** TYPES → BASE → INFRA → REPOS →
   SERVICES → DOMAIN → RELEASE → STARTUP → TESTS → FORMS. Compilacao
   validada apos cada grupo (em modo real). Falha aborta sem tocar
   restante. Detalhe formal em `MANIFESTO_FORMAT.md`.

3. **Tabu Mod_Types.** Mod_Types nao e modificado em import incremental
   fora da Onda 9 plena. Heuristica: se Mod_Types existe no workbook,
   pula; se ausente (build fresh), importa. Protecao real esta a montante
   (G7 + publish + git pre-commit hook).

4. **`.frm` via `.code-only.txt` em workbook estabilizado.** Nunca
   substitui `.frx` do designer (preserva renomeacoes e binarios). Em
   workbook limpo, importa `.frm + .frx` normalmente.

5. **Backup automatico antes de import real.** Cada execucao gera
   `backups/vba/<ts>-V2-FULL/` com export completo do projeto VBA. Rollback
   manual e sempre possivel.

## API publica (4 entry points)

```
ImportarPacoteV2()              ' apply real, todos grupos
ImportarPacoteV2_DryRun()       ' simula, nao toca workbook
ImportarPacoteV2_Grupo(nome)    ' apply real de 1 grupo so
ImportarPacoteV2_Status()       ' Sub - Debug.Print do estado + manifesto
```

Apenas `ImportarPacoteV2()` modifica o workbook. Os demais sao
read-only/diagnostico.

## Persistencia

Aba `IMPORT_LOG_V2` (criada se ausente) registra cada evento:
`TIMESTAMP | GRUPO | MODULO | CAMINHO | DETALHES | STATUS`. Append-only
durante o run. Glasswing G4 (AUDIT_LOG append-only) aplicavel.

## Cross-platform (Excel Mac vs Windows)

Leitura de arquivos faz `Open caminho For Binary Access Read` + normalizacao
de EOL (CR/LF/CRLF para CRLF unificado). Resolve bug onde `Line Input` no
Excel Mac le manifesto inteiro como uma linha unica quando o EOL do arquivo
nao e nativo do SO. Helper canonico: `IV2_LerArquivoBinarioComoTexto`.

## Diagnostico de falha

Handler `falha:` em `IV2_RodarMain` registra:
- `faseAtual` (1_VBOM_CHECK, 2_LOCALIZAR_MANIFESTO, ..., 6_GRUPO_N_PROCESSAR, 7_LOG_FIM)
- `Err.Number / Description / Source` (snapshot imediato, antes de qualquer
  call que possa limpar Err em sub aninhada com OERN)

Mensagem de erro inclui **fase** mesmo se Err for engolido. Padrao para
debug em ambientes onde sub aninhada com OERN limpa Err do escopo
chamador (Mac VBA).

## Onde se conecta

- **Glasswing G7+G8** (`0003-glasswing-style-preventive-security.md`):
  publish script + pre-commit hook + check periodico via `glasswing-checks.sh`.
- **Modelo CLA-controlado** (`0007-acesso-controlado-via-cla.md`): o
  Importador V2 (`Importador_V2.bas`) e publico; mas o pacote
  `local-ai/vba_import/` que ele consome e CLA-controlado (release zip).
- **Tabela canonica de entrega** (`0006-tabela-canonica-entrega.md`):
  toda mudanca em `src/vba/Importador_V2.bas` segue o padrao de tabela
  com 4 colunas.

## Documentos relacionados (Diataxis)

- `docs/explanation/IMPORTADOR_V2.md` — visao conceitual
- `docs/how-to/COMO_IMPORTAR_PACOTE_VBA.md` — fluxo passo a passo
- `docs/reference/MANIFESTO_FORMAT.md` — especificacao do contrato

## Vitrine usehbn

`usehbn/docs/INTEGRATION-VBA-IMPORTER.md` mostra o padrao para outros
projetos que precisem importar codigo legacy em ambiente confidencial.
