---
titulo: Procedimento de Importacao Manual Segura — ONDA 2 (CNAE snapshot + dedup)
natureza-do-documento: passo a passo operacional, sem rodar publicar_vba_import.sh, sem tocar Mod_Types
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
branch: codex/v12-0-0203-governanca-testes
data: 2026-04-27
autor: Claude Opus 4.7 (sessao Cowork — executor)
solicitante: Luis Mauricio Junqueira Zanin
documento-irmao: auditoria/30_ONDA_02_CNAE_SNAPSHOT_DEDUP.md
---

# 31. Procedimento de Importacao Manual Segura — ONDA 2

## 00. Regras inviolaveis (igual a Onda 1)

1. **NAO rodar** `bash local-ai/scripts/publicar_vba_import.sh`.
2. **NAO importar** `Mod_Types.bas`.
3. **NAO importar** `Importador_VBA.bas`.
4. **NAO importar** nenhum `.frm/.frx` nesta onda.
5. Backup obrigatorio do `.xlsm` antes do primeiro arquivo importado.
6. Compilar (`Depurar > Compilar VBAProject`) **apos cada arquivo**.
7. Em caso de erro, abortar e voltar ao backup; nao consertar no VBE.

## 01. Lista exata da ONDA 2 (5 arquivos, todos `.bas`)

| # | Caminho | Modulo VBA (`Attribute VB_Name`) | Funcao na onda |
|---|---|---|---|
| 0 | `src/vba/App_Release.bas` | `App_Release` | **carimbo** `f7aa84f+ONDA02-em-homologacao` |
| 1 | `src/vba/Const_Colunas.bas` | `Const_Colunas` | nova constante `SHEET_PREFIX_CAD_SERV_SNAP` |
| 2 | `src/vba/Preencher.bas` | `Preencher` | snapshot, dedup, listagem, integracao com reset |
| 3 | `src/vba/Teste_V2_Roteiros.bas` | `Teste_V2_Roteiros` | suite `TV2_RunCnae` (`CNAE_001..003`) |
| 4 | `src/vba/Central_Testes_V2.bas` | `Central_Testes_V2` | opcao `[15] CNAE: snapshot e dedup` |

Nao entram nesta lista: `Mod_Types.bas`, `Audit_Log.bas` (intocado),
`Util_Config.bas` (intocado nesta onda), nenhum `Svc_*.bas` (intocado),
nenhum `Repo_*.bas` (intocado), nenhum `.frm/.frx`, `Importador_VBA.bas`.

## 02. Identificador do build manual

Ja gravado em `src/vba/App_Release.bas`:

- `APP_BUILD_IMPORTADO = "f7aa84f+ONDA02-em-homologacao"`
- `APP_BUILD_BRANCH = "codex/v12-0-0203-governanca-testes"`
- `APP_BUILD_GERADO_EM = "2026-04-27 10:30"`

A tela `Sobre` deve passar a exibir:
`Build importado: f7aa84f+ONDA02 (em homologação)`.

## 03. Ensaio em copia descartavel (obrigatorio)

1. Fechar o Excel.
2. Copiar `PlanilhaCredenciamento-Homologacao.xlsm` para
   `~/Downloads/Onda02_Ensaio_PlanilhaCredenciamento-Homologacao.xlsm`.
3. Abrir a copia.
4. Importar **somente** `Const_Colunas.bas` (passo 04.2).
5. Compilar.
6. Se compilar limpo, fechar a copia, descartar.
7. Se nao compilar, parar e me avisar com a mensagem exata.

## 04. Procedimento real

### 04.0 Backup obrigatorio

Copiar `PlanilhaCredenciamento-Homologacao.xlsm` para
`V12-202-K/PlanilhaCredenciamento-Homologacao_PRE_ONDA_02_<DATA>.xlsm`.

### 04.1 Importar arquivo 0 — `App_Release.bas`

1. Project Explorer (`Ctrl+R`): clique direito em `App_Release` >
   **Remove App_Release** > **No** ao "exportar?".
2. `File > Import File...` -> `src/vba/App_Release.bas`.
3. `Depurar > Compilar VBAProject`. Tem que ficar limpo.
4. Conferir tela `Sobre`:
   - **Build importado:** `f7aa84f+ONDA02 (em homologação)`
   - **Branch:** `codex/v12-0-0203-governanca-testes`
   - **Pacote gerado em:** `2026-04-27 10:30`

### 04.2 Importar arquivo 1 — `Const_Colunas.bas`

1. Remover `Const_Colunas`.
2. Importar `src/vba/Const_Colunas.bas`.
3. Compilar.

### 04.3 Importar arquivo 2 — `Preencher.bas`

1. Remover `Preencher`.
2. Importar `src/vba/Preencher.bas`.
3. Compilar.

> **Observacao:** este e o arquivo mais pesado da onda (~3835 linhas).
> Inclui as 3 funcoes novas no final (`CnaeSnapshotCadServ`,
> `CnaeContarDuplicatasAtividades`, `CnaeListarSnapshots`) e a
> integracao na ETAPA 9 do reset. Caso a compilacao acuse simbolo nao
> reconhecido, e provavel que `Const_Colunas.bas` (passo 04.2) nao
> tenha sido importado ainda — voltar e refazer 04.2.

### 04.4 Importar arquivo 3 — `Teste_V2_Roteiros.bas`

1. Remover `Teste_V2_Roteiros`.
2. Importar `src/vba/Teste_V2_Roteiros.bas`.
3. Compilar.

### 04.5 Importar arquivo 4 — `Central_Testes_V2.bas`

1. Remover `Central_Testes_V2`.
2. Importar `src/vba/Central_Testes_V2.bas`.
3. Compilar.

### 04.6 Salvar

`Ctrl+S`. Confirmar manter `.xlsm`.

## 05. Verificacao final

1. Compilar uma ultima vez. Tem que ficar limpo.
2. Conferir tela `Sobre`: build deve mostrar `f7aa84f+ONDA02 (em homologação)`.
3. Trio minimo:
   - V1 rapida (Bateria Oficial)
   - V2 Smoke (Central V2 opcao `[1]`)
   - V2 Canonica (Central V2 opcao `[5]`)
   - Esperado: todos verdes.
4. Suite Onda 1 (regressao): Central V2 opcao `[14]` (Strikes na avaliacao).
   - Esperado: `OK=7`, `FALHA=0`.
5. Suite Onda 2 (nova): Central V2 opcao `[15]` (CNAE: snapshot e dedup).
   - Esperado: `OK=3`, `FALHA=0`.
6. Conferir resultado em `RESULTADO_QA_V2`, filtro `suite = CNAE`.
7. Salvar `Ctrl+S`.

## 06. Plano de rollback

Em caso de qualquer falha:

1. Fechar Excel sem salvar.
2. Restaurar do backup criado em 04.0.
3. Abrir backup, rodar trio minimo para confirmar volta ao verde.
4. Me devolver a mensagem exata do erro.

## 07. Por que nao gera regressao

- nenhum `.frx` tocado;
- `Mod_Types.bas` intocado;
- `Audit_Log.bas` intocado (reuso de `EVT_TRANSACAO`);
- `Util_Config.bas` intocado (regra de strikes da Onda 1 preservada);
- `Svc_*` intocados;
- todas as funcoes novas em `Preencher.bas` sao **aditivas** — nada
  removido, nenhuma assinatura existente alterada;
- a integracao na ETAPA 9 e nao bloqueante: se snapshot ou dedup
  falharem internamente, o reset original continua e a auditoria
  registra o estado;
- a suite nova nao chama o reset real — exercita helpers em isolamento.

## 08. Politica para a proxima onda

Apos OK desta onda, sigo para a **ONDA 3**: cenario E2E
`CS_25_CREDENCIAMENTO_ENDtoEND` + suite de filtros completa via
`Util_Filtro_Lista`. Mesmo padrao: arquivo 0 = `App_Release.bas` com
identificador `f7aa84f+ONDA03-em-homologacao`.
