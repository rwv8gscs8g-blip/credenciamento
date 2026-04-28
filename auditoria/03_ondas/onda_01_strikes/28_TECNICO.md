---
titulo: ONDA 1 — Regra de Strikes na Avaliacao
natureza-do-documento: documento tecnico de microevolucao com escopo, codigo, testes e gate
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
branch: codex/v12-0-0203-governanca-testes
data: 2026-04-27
autor: Claude Opus 4.7 (sessao Cowork — executor)
solicitante: Luis Mauricio Junqueira Zanin
plano-mestre: auditoria/27_PLANO_ESTEIRA_OPUS_RELEASE_V203.md
---

# 28. ONDA 1 — Regra de Strikes na Avaliacao

> **AVISO IMPORTANTE (2026-04-27 — pos-revisao com Mauricio):**
> A secao 06 deste documento mencionava `bash local-ai/scripts/publicar_vba_import.sh`
> como passo 1 do gate. **Essa instrucao deve ser ignorada.** O script
> e instavel, ja causou regressao historica e tenta importar
> `Mod_Types.bas`. O procedimento real, manual e seguro, esta em
> [auditoria/29_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_01.md](29_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_01.md).
> Em caso de divergencia entre os dois documentos, **o 29 prevalece**.
>
> **CORRECAO ADICIONAL (2026-04-27 11:00):** a secao 02 do `auditoria/28`
> e a versao inicial do `auditoria/29` listavam apenas 8 arquivos de
> import. Faltava `App_Release.bas`, que e obrigatorio em qualquer
> microevolucao para carimbar o build na tela `Sobre` e nas evidencias
> (regra ja documentada em `local-ai/vba_import/000-BUILD-IMPORTAR-SEMPRE.txt`
> e em `local-ai/vba_import/README.md`). O `auditoria/29` foi
> corrigido: agora a lista tem 9 arquivos, com `App_Release.bas` como
> **arquivo 0**, e ha um passo 04.0.5 dedicado para quem ja completou
> os 8 arquivos antes da correcao.

## 00. Sintese

Substitui a regra "primeira nota baixa suspende" por "N strikes
suspendem por D dias", mantendo retro-compatibilidade com a regra
antiga via `MAX_STRIKES = 1`. Nao mexe em `Mod_Types.bas`. Nao
depende de reexportar `.frx`. Adiciona 7 cenarios automatizados
em uma suite isolada `STRIKES`. Pode entrar antes do fechamento da
`V12.0.0203`.

## 01. Escopo

Entra:

- nova logica de strikes em `Svc_Avaliacao.AvaliarOS`;
- novo parametro `diasSuspensao` em `Svc_Rodizio.Suspender`;
- 3 getters novos em `Util_Config`;
- 2 colunas novas em `CONFIG` via `Const_Colunas`;
- 1 funcao nova em `Repo_Avaliacao`;
- 1 suite nova `TV2_RunStrikes` com 7 cenarios;
- 1 nova opcao na `Central_Testes_V2`.

Nao entra (vai para ondas seguintes):

- janela temporal para o contador (acumulativo permanente nesta onda);
- gravacao das duas colunas novas via `Configuracao_Inicial.frm` (vai
  na ONDA 5, dependente de reexportar o `.frx` com os TextBox novos);
- alteracao de `Svc_Rodizio.AvancarFila` (suspensao por excesso de
  recusas continua usando meses).

## 02. Arquivos modificados

| Arquivo | Mudanca |
|---|---|
| `src/vba/Const_Colunas.bas` | +2 constantes (`COL_CFG_MAX_STRIKES`=12, `COL_CFG_DIAS_SUSPENSAO_STRIKE`=13) |
| `src/vba/Util_Config.bas` | +`GetMaxStrikes()`, +`GetDiasSuspensaoStrike()` |
| `src/vba/Repo_Avaliacao.bas` | +`ContarStrikesPorEmpresa(EMP_ID, notaCorte)` |
| `src/vba/Svc_Rodizio.bas` | `Suspender` agora aceita `diasSuspensao` e `motivo` opcionais; auditoria registra `BASE=DIAS|MESES` |
| `src/vba/Svc_Avaliacao.bas` | bloco "7b" reescrito: conta strikes via `Repo_Avaliacao` e suspende em dias quando atinge `MAX_STRIKES`; registra evento `Avaliacao` com `STRIKES=N/M` |
| `src/vba/Teste_V2_Engine.bas` | `TV2_SetConfigCanonica` agora grava defaults canonicos das duas colunas novas: `MAX_STRIKES=1` e `DIAS_SUSPENSAO_STRIKE=0` (mantem comportamento da suite canonica existente) |
| `src/vba/Teste_V2_Roteiros.bas` | +`TV2_RunStrikes` (suite com `CS_AVAL_001..007`), +helpers `TV2_SetStrikesConfig` e `TV2_ConsumirStrikeEmpresa` |
| `src/vba/Central_Testes_V2.bas` | +opcao `[14] Strikes na avaliacao`, +`CT2_ExecutarStrikes` |
| `auditoria/03_AUDITORIA_REGRAS_DE_NEGOCIO.md` | +R-60..R-62 |
| `CHANGELOG.md` | entrada `[Unreleased]` ampliada |
| `auditoria/27_PLANO_ESTEIRA_OPUS_RELEASE_V203.md` | plano mestre da esteira |
| `auditoria/28_ONDA_01_REGRA_STRIKES_AVALIACAO.md` | este documento |

## 03. Modelo de dados

### 03.1 Novas colunas em `CONFIG`

| Col | Const | Default | Faixa permitida | Funcao |
|---|---|---|---|---|
| L | `COL_CFG_MAX_STRIKES` | 3 | 1..50 | numero de strikes que disparam suspensao |
| M | `COL_CFG_DIAS_SUSPENSAO_STRIKE` | 90 | 0..3650 | dias de suspensao (0 = fallback em meses) |

### 03.2 Coluna existente reaproveitada

| Col | Const | Default | Funcao |
|---|---|---|---|
| K | `COL_CFG_NOTA_MINIMA` | 5.0 | nota de corte: avaliacao com `MEDIA < NOTA_MINIMA` conta strike |

### 03.3 Estrutura de leitura (sem alterar TConfig)

`GetConfig()` continua devolvendo apenas `DIAS_DECISAO`, `MAX_RECUSAS`,
`PERIODO_SUSPENSAO_MESES`, `GESTOR_NOME`, `municipio`, `CAM_LOGO`. Os 3
getters novos (`GetNotaMinimaAvaliacao`, `GetMaxStrikes`,
`GetDiasSuspensaoStrike`) leem `CONFIG` diretamente quando chamados.
**Decisao deliberada: nao tocar `Mod_Types.bas`.**

## 04. Algoritmo do strike

```
1. avaliacao registrada via AvaliarOS calcula media.
2. se media >= NOTA_MINIMA -> nada acontece (caminho feliz).
3. se media < NOTA_MINIMA:
   a) chama Repo_Avaliacao.ContarStrikesPorEmpresa(EMP_ID, NOTA_MINIMA)
      que varre SHEET_CAD_OS filtrando STATUS=CONCLUIDA e MEDIA<corte;
      o valor retornado JA inclui a avaliacao recem-inserida porque
      RepoAvaliacaoInserir grava antes do bloco de strikes.
   b) registra evento `Avaliacao` em ENT_EMP com:
        antes:  STRIKES=N-1/MAX
        depois: STRIKES=N/MAX, NOTA_MIN, MEDIA
   c) se strikes >= MAX_STRIKES:
        - le DIAS_SUSPENSAO_STRIKE
        - se > 0: chama Suspender(EMP_ID, DIAS, "STRIKES=N")
        - se = 0: chama Suspender(EMP_ID, 0, "STRIKES=N; FALLBACK_MESES")
        - Suspender registra sua propria auditoria com BASE=DIAS|MESES
4. continua com AvancarFila (sem alteracao).
```

### 04.1 Janela temporal e zerar contador

Nesta onda, **nao ha janela temporal**. O contador e a contagem total de
OS concluidas com media baixa. A "zeragem" funcional acontece de duas
formas:

- via reativacao: ao reativar (auto por `DT_FIM_SUSP <= hoje` ou manual
  por `Reativar`), o status volta a `ATIVA` e o contador efetivo retoma
  do zero **na pratica** porque novas avaliacoes sao avaliadas contra a
  contagem total — mas a contagem total **continua subindo** se houver
  novas notas baixas. Em outras palavras: empresa que ja levou 3
  strikes, ao receber 1 nova nota baixa apos reativar, continuara
  ativando 4 strikes na contagem on-the-fly e sera suspensa de novo.
- via reset operacional manual: gestor pode limpar avaliacoes antigas
  em `CAD_OS` (procedimento administrativo).

A introducao de janela temporal (ex: contar so strikes dos ultimos N
meses) fica para uma onda posterior, com decisao de produto explicita,
porque exige criterio para "quando o relogio comeca a contar":
data da avaliacao, data da reativacao, data fixa da release, etc.

### 04.2 Compatibilidade com a regra antiga

`MAX_STRIKES = 1` faz a regra nova reproduzir a regra antiga: na
primeira avaliacao com `MEDIA < NOTA_MINIMA`, suspende. O cenario
`CS_AVAL_005` prova isso. A suite canonica V2 ja existente
(`TV2_RunCanonicoFundacao`) continua usando `MAX_STRIKES = 1` por
default em `TV2_SetConfigCanonica`, garantindo zero regressao em
`CS_14`, `CS_15`, `CS_16`.

## 05. Cenarios automatizados (suite `STRIKES`)

| ID | Pre-condicao | Acao | Resultado esperado | Razao |
|---|---|---|---|---|
| `CS_AVAL_001` | Triplo canonico, MAX=3, DIAS=90 | 1 strike na empresa "001" | STATUS=ATIVA, STRIKES=1 | 1 nota baixa nao suspende mais |
| `CS_AVAL_002` | Triplo canonico, MAX=3, DIAS=90 | 2 strikes na empresa "001" | STATUS=ATIVA, STRIKES=2 | contador acumula |
| `CS_AVAL_003` | Triplo canonico, MAX=3, DIAS=90 | 3 strikes na empresa "001" | STATUS=SUSPENSA_GLOBAL, STRIKES=3, DT_FIM=hoje+90, AUDIT BASE=DIAS=1 | regra principal |
| `CS_AVAL_004` | Triplo canonico, MAX=3, DIAS=90 | strike, avaliacao boa, strike | STATUS=ATIVA, STRIKES=2 | avaliacao boa nao zera contador |
| `CS_AVAL_005` | Triplo canonico, MAX=1, DIAS=90 | 1 strike na empresa "001" | STATUS=SUSPENSA_GLOBAL, AUDIT BASE=DIAS=1 | retro-compatibilidade |
| `CS_AVAL_006` | Triplo canonico, MAX=1, DIAS=30 | 1 strike na empresa "001" | STATUS=SUSPENSA_GLOBAL, DT_FIM=hoje+30 | calendario respeita DIAS configurado |
| `CS_AVAL_007` | Triplo canonico, MAX=1, DIAS=30, depois forca DT_FIM=hoje-1 e roda SelecionarEmpresa | reativacao automatica | STATUS=ATIVA pos-rodizio | ciclo de retorno preservado |

## 06. Gate de teste

> Substituido pelo procedimento manual seguro em
> [auditoria/29_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_01.md](29_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_01.md).
> **Nao rodar o script.** **Nao importar `Mod_Types.bas`.** **Nao usar
> `Importador_VBA.bas`.**

Resumo do gate (detalhes no `auditoria/29`):

1. backup obrigatorio do `.xlsm`;
2. ensaio em copia descartavel com importacao apenas de `Const_Colunas.bas`;
3. importacao manual via VBE de 8 modulos `.bas`, **um por vez**, com
   remocao previa do modulo de mesmo nome e compilacao apos cada um;
4. nenhum formulario `.frm/.frx` tocado;
5. trio minimo verde (V1 rapida + V2 Smoke + V2 Canonica);
6. nova suite `[14] Strikes na avaliacao` verde (`OK=7`, `FALHA=0`);
7. responder no chat OK ou falha + log;
8. em caso de falha, restaurar do backup e me avisar — sem tentar
   consertar no VBE com a `0203` aberta.

## 07. Riscos e mitigacoes

| Risco | Mitigacao |
|---|---|
| Suite canonica existente quebrar por mudanca de regra | `TV2_SetConfigCanonica` grava defaults `MAX=1` e `DIAS=0` — comportamento identico ao anterior; CS_14/15/16 nao mudam |
| Compilacao quebrar por uso de `IIf` com strings | testado em revisao; padrao ja usado em outros pontos do codigo |
| `ContarStrikesPorEmpresa` retornar 0 quando `STATUS_OS_CONCLUIDA` for diferente | constante explicita `Private Const STATUS_OS_CONCLUIDA = "CONCLUIDA"` no proprio modulo, casa com a usada em `Repo_Avaliacao.Inserir` |
| Operador esquecer de reimportar `App_Release.bas` carimbado | regra existente do `local-ai/vba_import/README.md` — sempre importar |

## 08. Fronteiras nao tocadas (preserva diretrizes vigentes)

- `src/vba/Mod_Types.bas`: intocado;
- `src/vba/Importador_VBA.bas`: intocado;
- `src/vba/Menu_Principal.frm`: intocado;
- `src/vba/Configuracao_Inicial.frm`: intocado nesta onda (vai na
  ONDA 5, depois de o operador reexportar o `.frx`);
- nucleo do rodizio (`SelecionarEmpresa`, `AvancarFila`): intocado;
- regra de suspensao por excesso de recusas (`MAX_RECUSAS`):
  intocada — continua usando meses pelo fallback do `Suspender`.

## 09. Decisoes pendentes para Mauricio (registrar antes da ONDA 5)

1. confirmar defaults para entregar na interface da Configuracao
   Inicial: `MAX_STRIKES = 3`, `DIAS_SUSPENSAO_STRIKE = 90`?
2. confirmar que a ONDA 5 deve gravar essas duas colunas no
   `B_Parametros_Click` (espelho do que ja faz para `MAX_RECUSAS`)?
3. confirmar que a janela temporal NAO entra na V12.0.0203 (fica para
   pos-release)?

## 10. Proxima onda

Apos OK desta onda, segue automaticamente a **ONDA 2 — CNAE: snapshot,
dedup e teste** conforme plano em `auditoria/27`.
