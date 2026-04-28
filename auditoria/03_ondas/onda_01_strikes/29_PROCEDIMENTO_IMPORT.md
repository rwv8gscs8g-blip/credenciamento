---
titulo: Procedimento de Importacao Manual Segura — ONDA 1 (sem rodar publicar_vba_import.sh)
natureza-do-documento: passo a passo operacional, com plano de rollback, ensaio em copia descartavel e regra de desligamento total do importador automatico
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
branch: codex/v12-0-0203-governanca-testes
data: 2026-04-27
autor: Claude Opus 4.7 (sessao Cowork — executor)
solicitante: Luis Mauricio Junqueira Zanin
documento-irmao: auditoria/28_ONDA_01_REGRA_STRIKES_AVALIACAO.md
escopo: substitui qualquer mencao a `bash local-ai/scripts/publicar_vba_import.sh` na ONDA 1; nao toca em `Mod_Types.bas`; nao usa `Importador_VBA.bas`
---

# 29. Procedimento de Importacao Manual Segura — ONDA 1

## 00. Por que esse documento existe

O documento da ONDA 1 (`auditoria/28`) recomendou, no passo 1 do gate de
teste, rodar `bash local-ai/scripts/publicar_vba_import.sh`. **Essa
recomendacao deve ser ignorada.** Auditoria do script confirma o que o
operador alertou:

- a lista `module_order` do script tem `"000:Mod_Types.bas"` na primeira
  posicao (linha 20 do script);
- o pacote produzido em `local-ai/vba_import/001-modulo/` ja sai com
  `AAA-Mod_Types.bas` carimbado para reimport;
- o documento de ordem (`000-ORDEM-IMPORTACAO.txt`) instrui, em modo
  completo, a "EXCLUIR do VBAProject TODOS os modulos e formularios
  antigos" e re-importar tudo — qualquer mistura desse caminho com a
  ONDA 1 ressuscita o erro `TConfig` historico;
- a frente "reescrita do importador automatico" esta deliberadamente
  adiada para apos a `V12.0.0203` estabilizada (auditoria 22, 23, 24,
  25, 27).

Portanto, este documento substitui o passo 1 e o passo 2 do gate da
ONDA 1 por uma sequencia totalmente manual, sem rodar nenhum script,
sem `Importador_VBA.bas` e sem tocar em `Mod_Types.bas`.

## 01. Regras inviolaveis

1. **NAO rodar** `bash local-ai/scripts/publicar_vba_import.sh`.
2. **NAO importar** `Mod_Types.bas` em hipotese alguma.
3. **NAO importar** `Importador_VBA.bas` nem rodar
   `ImportarPacoteCredenciamentoV12`.
4. **NAO importar** nenhum formulario `.frm` nesta onda — a ONDA 1 nao
   toca em formulario.
5. Backup obrigatorio do `.xlsm` antes do primeiro arquivo importado.
6. Compilar (`Depurar > Compilar VBAProject`) **apos cada arquivo**.
7. Se um arquivo nao compilar, **abortar e voltar ao backup**, nao
   tentar consertar no VBE com a `0203` aberta.

## 02. Lista exata da ONDA 1 (9 arquivos, todos `.bas`)

> **CORRECAO 2026-04-27 11:00:** a versao anterior deste documento
> omitiu `App_Release.bas`. Esse arquivo e **obrigatorio em toda
> microevolucao**, conforme `local-ai/vba_import/README.md` e
> `local-ai/vba_import/000-BUILD-IMPORTAR-SEMPRE.txt`. Sem ele, a tela
> `Sobre` continua mostrando o build anterior e a evidencia (CSV do
> validador) carimba o build errado. A regra esta agora consolidada
> como **arquivo 0** desta lista. Em ondas futuras, **sempre** comecar
> por `App_Release.bas`.

Esta e a unica lista a importar. A ordem e por dependencia semantica
(carimbo do build -> constantes -> config -> repositorios -> servicos
-> motor de teste -> roteiros -> central). Nenhum desses 9 arquivos
toca em `Mod_Types.bas`.

| # | Caminho | Modulo VBA (`Attribute VB_Name`) | Funcao na onda |
|---|---|---|---|
| 0 | `src/vba/App_Release.bas` | `App_Release` | **carimba o build** que vai aparecer na tela `Sobre` e nas evidencias |
| 1 | `src/vba/Const_Colunas.bas` | `Const_Colunas` | constantes novas `COL_CFG_MAX_STRIKES` (L) e `COL_CFG_DIAS_SUSPENSAO_STRIKE` (M) |
| 2 | `src/vba/Util_Config.bas` | `Util_Config` | getters `GetMaxStrikes`, `GetDiasSuspensaoStrike` |
| 3 | `src/vba/Repo_Avaliacao.bas` | `Repo_Avaliacao` | `ContarStrikesPorEmpresa` |
| 4 | `src/vba/Svc_Rodizio.bas` | `Svc_Rodizio` | `Suspender` aceita `diasSuspensao` |
| 5 | `src/vba/Svc_Avaliacao.bas` | `Svc_Avaliacao` | bloco "7b" reescrito: contagem de strikes |
| 6 | `src/vba/Teste_V2_Engine.bas` | `Teste_V2_Engine` | defaults canonicos `MAX=1`, `DIAS=0` |
| 7 | `src/vba/Teste_V2_Roteiros.bas` | `Teste_V2_Roteiros` | suite `STRIKES` com `CS_AVAL_001..007` |
| 8 | `src/vba/Central_Testes_V2.bas` | `Central_Testes_V2` | opcao `[14] Strikes na avaliacao` |

Quem **NAO** entra nesta lista (mesmo que tenha mudado em algum momento
da branch): `Mod_Types.bas`, formularios `.frm/.frx`,
`Importador_VBA.bas`.

### 02.1 Identificador do build manual (regra de carimbo sem script)

Como nao rodamos o script, `APP_BUILD_IMPORTADO` precisa ser editado a
mao. O formato esperado pela funcao `AppRelease_BuildImportadoRotulo`
(ja existente em `App_Release.bas`) e `<base>-em-homologacao` ou
`<base>-homologado`. Convencao adotada para esta onda:

- enquanto a Onda 1 nao for commitada:
  `f7aa84f+ONDA01-em-homologacao`
- apos commitar a Onda 1:
  `<novo-commit-curto>-homologado`

A tela `Sobre` exibira automaticamente:
- antes do commit: `f7aa84f+ONDA01 (em homologação)`
- depois do commit: `<novo-commit-curto> (homologado)`

`APP_BUILD_BRANCH` e `APP_BUILD_GERADO_EM` ja foram preenchidos no
`src/vba/App_Release.bas` desta sessao com:

- `APP_BUILD_BRANCH = "codex/v12-0-0203-governanca-testes"`
- `APP_BUILD_GERADO_EM = "2026-04-27 09:45"`

## 03. Ensaio em copia descartavel (obrigatorio antes do real)

Antes de tocar em `PlanilhaCredenciamento-Homologacao.xlsm`, faca o
ensaio:

1. Fechar o Excel.
2. Copiar `PlanilhaCredenciamento-Homologacao.xlsm` para uma pasta
   temporaria com nome novo, ex.:
   `~/Downloads/Onda01_Ensaio_PlanilhaCredenciamento-Homologacao.xlsm`.
3. Abrir essa copia descartavel.
4. Aplicar **somente o passo 04.1** (importar `Const_Colunas.bas`)
   e o **passo 04.2** (compilar).
5. Se compilar limpo, fechar a copia, descartar.
6. Se nao compilar, **parar tudo aqui mesmo**, registrar a mensagem
   exata do erro, fechar a copia sem salvar e me avisar. Sem ensaio
   verde, a ONDA 1 nao entra no workbook real.

Esse ensaio prova que a constante nova (`COL_CFG_MAX_STRIKES`,
`COL_CFG_DIAS_SUSPENSAO_STRIKE`) nao colide com nada existente.

## 04. Procedimento real (no workbook de homologacao)

### 04.0 Backup obrigatorio

1. Fechar o Excel.
2. Copiar `PlanilhaCredenciamento-Homologacao.xlsm` para
   `V12-202-K/PlanilhaCredenciamento-Homologacao_PRE_ONDA_01_<DATA>.xlsm`
   (uma das pastas `V12-202-*` ja existentes na raiz serve).
3. Confirmar que o backup abre normalmente em uma janela separada.
4. Fechar o backup.

### 04.0.5 Importar arquivo 0 — `App_Release.bas` (carimbo do build)

> **Para quem ja completou os 8 arquivos da onda em uma sessao
> anterior:** rode apenas este passo agora. Ele atualiza o build
> exibido na tela `Sobre` e nas evidencias futuras. Nao e necessario
> rerodar a importacao dos outros 8 arquivos. Apos importar o
> `App_Release.bas`, abra a tela `Sobre`: tem que aparecer
> `f7aa84f+ONDA01 (em homologação)`. Apos isso, opcionalmente
> reexecute o validador consolidado para arquivar uma evidencia com
> o build correto.

1. Project Explorer (`Ctrl+R`): localizar o modulo `App_Release`
   (clicar com o direito > **Remove App_Release** > **No** ao
   "exportar?").
2. `File > Import File...` -> selecionar `src/vba/App_Release.bas`
   (ja foi atualizado nesta sessao com o carimbo da Onda 1).
3. Compilar (`Depurar > Compilar VBAProject`). Tem que terminar sem
   mensagem.
4. Validar visualmente: abrir a tela `Sobre` no Menu Principal. Tem
   que aparecer:
   - **Build importado:** `f7aa84f+ONDA01 (em homologação)`
   - **Branch:** `codex/v12-0-0203-governanca-testes`
   - **Pacote gerado em:** `2026-04-27 09:45`
5. Salvar `Ctrl+S`.

### 04.1 Importar arquivo 1 — `Const_Colunas.bas`

1. Abrir `PlanilhaCredenciamento-Homologacao.xlsm`.
2. `Alt+F11` para abrir o VBE.
3. Painel **Project Explorer** (`Ctrl+R`): localizar o modulo
   `Const_Colunas` (clicar com o direito > **Remove Const_Colunas** >
   responder **No** quando perguntar se quer exportar).
4. `File > Import File...` -> selecionar
   `src/vba/Const_Colunas.bas`.
5. Confirmar no Project Explorer que o modulo voltou com o mesmo nome
   `Const_Colunas`.

### 04.2 Compilar

`Depurar > Compilar VBAProject`. Tem que terminar **sem mensagem**.

Se aparecer qualquer erro:

- abortar (Ctrl+Z nao desfaz import; precisa fechar sem salvar);
- restaurar do backup criado em 04.0;
- registrar a mensagem exata e me avisar.

### 04.3 Importar arquivo 2 — `Util_Config.bas`

1. Project Explorer: `Util_Config` (clique direito > Remove > No).
2. `File > Import File...` -> `src/vba/Util_Config.bas`.
3. Compilar (passo 04.2). Tem que ficar limpo.

### 04.4 Importar arquivo 3 — `Repo_Avaliacao.bas`

1. Remover `Repo_Avaliacao`.
2. Importar `src/vba/Repo_Avaliacao.bas`.
3. Compilar.

### 04.5 Importar arquivo 4 — `Svc_Rodizio.bas`

1. Remover `Svc_Rodizio`.
2. Importar `src/vba/Svc_Rodizio.bas`.
3. Compilar.

### 04.6 Importar arquivo 5 — `Svc_Avaliacao.bas`

1. Remover `Svc_Avaliacao`.
2. Importar `src/vba/Svc_Avaliacao.bas`.
3. Compilar.

### 04.7 Importar arquivo 6 — `Teste_V2_Engine.bas`

1. Remover `Teste_V2_Engine`.
2. Importar `src/vba/Teste_V2_Engine.bas`.
3. Compilar.

### 04.8 Importar arquivo 7 — `Teste_V2_Roteiros.bas`

1. Remover `Teste_V2_Roteiros`.
2. Importar `src/vba/Teste_V2_Roteiros.bas`.
3. Compilar.

### 04.9 Importar arquivo 8 — `Central_Testes_V2.bas`

1. Remover `Central_Testes_V2`.
2. Importar `src/vba/Central_Testes_V2.bas`.
3. Compilar.

### 04.10 Salvar

`Ctrl+S` no Excel. Confirmar manter `.xlsm`.

## 05. Caminho alternativo ainda mais conservador (sem `File > Import`)

Se voce preferir evitar ate `File > Import` (porque ja teve problemas
historicos com encoding/CRLF nesse caminho), use a alternativa abaixo,
arquivo por arquivo, na mesma ordem:

1. No Project Explorer, **dar duplo clique** no modulo a substituir
   (ex.: `Util_Config`).
2. No painel central, `Ctrl+A` para selecionar tudo, `Delete`.
3. No editor de texto do sistema (TextEdit em modo plain text, ou
   VS Code), abrir `src/vba/Util_Config.bas`.
4. **Apagar a primeira linha** `Attribute VB_Name = "Util_Config"`
   (ela ja existe no modulo do projeto, e duplica-la causa erro).
5. `Ctrl+A`, `Ctrl+C` no texto restante.
6. Voltar ao VBE, colar `Ctrl+V` no painel central.
7. Compilar (`Depurar > Compilar VBAProject`).

Essa alternativa preserva a identidade do modulo (`VB_Name`,
`Attribute`s implícitos) e elimina qualquer chance de conflito por
encoding.

Para a ONDA 1, recomendo o procedimento da secao 04 (`File > Import`)
em modulo a modulo, com remocao previa. Esse caminho e o mais limpo e
nao exige editar o `.bas` antes.

## 06. Verificacao final apos os 8 arquivos

1. Compilar uma ultima vez.
2. Conferir na tela `Sobre` que o build exibido continua coerente — o
   `App_Release.bas` **nao foi tocado** nesta onda, entao a tela
   `Sobre` continua mostrando o build anterior. Isso e proposital: a
   ONDA 1 nao promove release.
3. Rodar **trio minimo** pelo menu existente:
   - V1 rapida (Bateria Oficial)
   - V2 Smoke (Central V2 opcao 1)
   - V2 Canonica (Central V2 opcao 5)
   Esperado: todos verdes, sem novo CSV de falhas.
4. Rodar a **suite nova de strikes**:
   - Central V2 opcao **[14] Strikes na avaliacao**
   Esperado: `OK=7`, `FALHA=0`.
5. Salvar `Ctrl+S`.

## 07. Plano de rollback

Se em qualquer ponto a compilacao quebrar, ou se o trio minimo passar
de verde para vermelho, ou se a suite nova ficar com `FALHA > 0`:

1. **Nao tente consertar no VBE.**
2. Fechar o Excel sem salvar.
3. Restaurar `PlanilhaCredenciamento-Homologacao.xlsm` a partir de
   `V12-202-K/PlanilhaCredenciamento-Homologacao_PRE_ONDA_01_<DATA>.xlsm`.
4. Abrir o backup restaurado, rodar trio minimo para confirmar que
   voltou ao verde anterior.
5. Registrar a mensagem exata do erro (print ou texto) e me devolver.
6. Eu reviso a fonte em `src/vba/` e devolvo um patch corretivo. A
   regra continua: nada de `Mod_Types.bas`, nada de
   `Importador_VBA.bas`, nada de script.

## 08. Por que esse caminho nao gera regressao

- nenhum `.frx` e tocado: o designer dos formularios continua
  identico ao antes da ONDA 1;
- `Mod_Types.bas` continua identico: zero risco de erro `TConfig`;
- `Importador_VBA.bas` continua identico: zero risco do importador
  reescrever modulos sensiveis;
- `App_Release.bas` continua identico: tela `Sobre` continua exibindo
  o build anterior (essa atualizacao acontece somente na ONDA 6 do
  fechamento da `V12.0.0203`);
- cada modulo importado substitui um modulo de mesmo nome com a mesma
  assinatura publica (todas as APIs antigas permanecem; as novas sao
  aditivas);
- `TV2_SetConfigCanonica` ja foi atualizado para gravar defaults
  canonicos (`MAX_STRIKES=1`, `DIAS_SUSPENSAO_STRIKE=0`) que mantem o
  comportamento legado da suite canonica existente — `CS_14`/`CS_16`
  continuam suspendendo na primeira nota baixa;
- a suite nova `STRIKES` e isolada: nao roda automaticamente no trio
  minimo; o operador escolhe quando rodar (opcao `[14]`).

## 09. Atualizacao do documento da ONDA 1

A secao 06 do documento `auditoria/28_ONDA_01_REGRA_STRIKES_AVALIACAO.md`
deve ser lida em conjunto com este `auditoria/29`. Em caso de
divergencia, **este documento prevalece**: nada de `publicar_vba_import.sh`
na ONDA 1, nada de `Importador_VBA.bas`, nada de `Mod_Types.bas`.

## 10. Politica para as proximas ondas

- ONDAS 2, 3 e 4 seguem a mesma regra: lista exata de arquivos,
  remocao previa, importacao manual, compilacao apos cada arquivo,
  backup obrigatorio antes;
- ONDA 5 (interface): vai exigir importacao de `.frm/.frx` — nesse
  momento eu publico um documento `auditoria/3X` com procedimento
  manual proprio para formulario, com remocao previa do form e import
  do par `.frm + .frx` na mesma operacao;
- ONDA 6 (fechamento): toca em `App_Release.bas` para promover a
  release; mesmo padrao manual aqui.
- A frente "reescrita do importador automatico" continua adiada para
  pos-`V12.0.0203` estabilizada, com plano dedicado em
  `auditoria/30_*.md` quando autorizado.

## 11. Conclusao operacional

A ONDA 1 esta segura **se e somente se** voce seguir este documento e
ignorar qualquer mencao ao script ou ao importador no `auditoria/28`.
Quando voce confirmar OK, eu sigo para a ONDA 2.
