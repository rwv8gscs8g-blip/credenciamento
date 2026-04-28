---
titulo: Procedimento de Importacao Manual Segura — ONDA 3 (CNAE dedup auto + housekeeping)
natureza-do-documento: passo a passo operacional, sem rodar publicar_vba_import.sh, sem tocar Mod_Types
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
branch: codex/v12-0-0203-governanca-testes
data: 2026-04-28
autor: Claude Opus 4.7 (sessao Cowork — executor)
solicitante: Luis Mauricio Junqueira Zanin
documento-irmao: auditoria/32_ONDA_03_CNAE_DEDUP_AUTOMATICO_E_HOUSEKEEPING.md
---

# 33. Procedimento de Importacao Manual Segura — ONDA 3

## 00. Regras inviolaveis

1. **NAO rodar** `bash local-ai/scripts/publicar_vba_import.sh`.
2. **NAO importar** `Mod_Types.bas`.
3. **NAO importar** `Importador_VBA.bas`.
4. **NAO importar** nenhum `.frm/.frx` nesta onda.
5. Backup obrigatorio antes do primeiro arquivo importado.
6. Compilar (`Depurar > Compilar VBAProject`) apos cada arquivo.
7. Em caso de erro, abortar e voltar ao backup; nao consertar no VBE.

## 01. Lista exata da ONDA 3 (4 arquivos, todos `.bas`)

| # | Caminho | Modulo VBA | Funcao na onda |
|---|---|---|---|
| 0 | `src/vba/App_Release.bas` | `App_Release` | carimbo `f7aa84f+ONDA03-em-homologacao` |
| 1 | `src/vba/Preencher.bas` | `Preencher` | dedup automatico, poda, confirmacao, LimparAbaOperacional Public |
| 2 | `src/vba/Teste_V2_Roteiros.bas` | `Teste_V2_Roteiros` | cenarios `CNAE_004..006` adicionados a suite |
| 3 | `src/vba/Central_Testes_V2.bas` | `Central_Testes_V2` | rotulo `[15]` atualizado |

Nao entram: `Mod_Types.bas`, `Const_Colunas.bas` (intocado nesta onda),
`Audit_Log.bas`, qualquer `.frm/.frx`, `Util_Config.bas`, `Svc_*.bas`,
`Repo_*.bas`.

## 02. Identificador do build

Ja gravado em `src/vba/App_Release.bas`:
- `APP_BUILD_IMPORTADO = "f7aa84f+ONDA03-em-homologacao"`
- `APP_BUILD_BRANCH = "codex/v12-0-0203-governanca-testes"`
- `APP_BUILD_GERADO_EM = "2026-04-28 06:00"`

## 03. Ensaio em copia descartavel

1. Fechar Excel, copiar `PlanilhaCredenciamento-Homologacao.xlsm`
   para `~/Downloads/Onda03_Ensaio_*.xlsm`.
2. Abrir a copia.
3. Importar **somente** `App_Release.bas` e compilar.
4. Conferir tela `Sobre`: build deve mostrar `f7aa84f+ONDA03 (em homologação)`.
5. Se ok, fechar, descartar.

## 04. Procedimento real

### 04.0 Backup

Copiar para `V12-202-K/PlanilhaCredenciamento-Homologacao_PRE_ONDA_03_<DATA>.xlsm`.

### 04.1 Arquivo 0 — `App_Release.bas`

1. Project Explorer: clique direito `App_Release` > **Remove** > **No**.
2. `File > Import File...` -> `src/vba/App_Release.bas`.
3. Compilar.
4. Tela `Sobre` deve mostrar:
   - **Build:** `f7aa84f+ONDA03 (em homologação)`
   - **Pacote gerado em:** `2026-04-28 06:00`

### 04.2 Arquivo 1 — `Preencher.bas`

1. Remover `Preencher`.
2. Importar `src/vba/Preencher.bas`.
3. Compilar.

> Este e o arquivo mais pesado (~4040 linhas com as adicoes da Onda 3).

### 04.3 Arquivo 2 — `Teste_V2_Roteiros.bas`

1. Remover `Teste_V2_Roteiros`.
2. Importar `src/vba/Teste_V2_Roteiros.bas`.
3. Compilar.

### 04.4 Arquivo 3 — `Central_Testes_V2.bas`

1. Remover `Central_Testes_V2`.
2. Importar `src/vba/Central_Testes_V2.bas`.
3. Compilar.

### 04.5 Salvar

`Ctrl+S` no Excel.

## 05. Verificacao final

1. Compilar uma ultima vez.
2. Conferir tela `Sobre`: `f7aa84f+ONDA03 (em homologação)`.
3. Trio minimo verde:
   - V1 rapida (Bateria Oficial)
   - V2 Smoke (Central V2 `[1]`)
   - V2 Canonica (Central V2 `[5]`)
4. Suite Onda 1 (regressao): `[14]` Strikes — esperado `OK=7`, `FALHA=0`.
5. Suite Onda 2 + Onda 3: `[15]` CNAE — esperado `OK=6`, `FALHA=0`.
6. Conferir em `RESULTADO_QA_V2`, filtro `suite = CNAE`, que existem
   linhas para `CNAE_001` ate `CNAE_006`.
7. `Ctrl+S`.

## 06. Plano de rollback

1. Fechar sem salvar.
2. Restaurar do backup.
3. Abrir backup, rodar trio minimo + `[14]` + `[15]` para confirmar
   estado anterior (a Onda 2 deve voltar com `OK=3` na CNAE).
4. Reportar mensagem exata do erro.

## 07. Por que nao gera regressao

- nenhum `.frx` tocado;
- `Mod_Types`, `Audit_Log`, `Const_Colunas` intocados;
- todos os helpers da Onda 3 sao **aditivos**;
- `LimparAbaOperacional` muda apenas de Private para Public, sem
  alterar comportamento ou assinatura;
- a poda de snapshots so executa apos confirmacao humana
  (`Yes`/`No` no MsgBox);
- o dedup automatico so dispara quando `qtdDuplicatas > 0`; em
  base limpa nao age;
- o cenario `CNAE_006` destrói a base operacional do workbook de
  homologacao durante sua execucao — apos rodar `[15]` voce precisa
  recompor a base se quiser reusar empresas/entidades de teste,
  ou simplesmente seguir com o reset de cenario que cada suite faz
  no inicio.

> **Importante sobre o cenario CNAE_006**: ele exercita
> `LimparAbaOperacional` nas 5 abas operacionais (EMPRESAS, ENTIDADE,
> CREDENCIADOS, PRE_OS, CAD_OS) para provar que ATIVIDADES e CAD_SERV
> nao sao tocados. Se voce estava com dados operacionais reais nessas
> abas para fins de homologacao manual antes da execucao da `[15]`,
> esses dados serao apagados pelo cenario. Recomendo rodar a `[15]` em
> momentos onde a base operacional ja vai ser regenerada de qualquer
> forma — por exemplo, antes de rodar a V2 Canonica que sempre repovoa
> a base via `TV2_PrepararCenarioTriploCanonico`.

## 08. Politica para a proxima onda

Apos OK desta onda, sigo para a **ONDA 4**: cenario E2E
`CS_25_CREDENCIAMENTO_ENDtoEND` + suite de filtros completa via
`Util_Filtro_Lista`. Mesmo padrao: arquivo 0 = `App_Release.bas` com
`f7aa84f+ONDA04-em-homologacao`.
