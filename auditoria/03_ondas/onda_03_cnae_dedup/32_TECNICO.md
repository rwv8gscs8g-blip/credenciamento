---
titulo: ONDA 3 — CNAE: dedup automatico + housekeeping de snapshots + regressao Limpa_Base
natureza-do-documento: documento tecnico de microevolucao com escopo, codigo, testes e gate
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
branch: codex/v12-0-0203-governanca-testes
data: 2026-04-28
autor: Claude Opus 4.7 (sessao Cowork — executor)
solicitante: Luis Mauricio Junqueira Zanin
plano-mestre: auditoria/27_PLANO_ESTEIRA_OPUS_RELEASE_V203.md
documento-irmao-procedimento: auditoria/33_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_03.md
---

# 32. ONDA 3 — CNAE: dedup automatico + housekeeping de snapshots

## 00. Sintese

Fecha o ciclo CNAE iniciado na Onda 2 com tres entregas alinhadas as
decisoes de produto:

1. **dedup automatico**: duplicatas detectadas em `ATIVIDADES` por
   `(CNAE, DESCRICAO)` agora sao **removidas** automaticamente apos
   o reset (decisao Mauricio: "duplicatas foram erro de importacao
   remanescente, devem ser retiradas");
2. **housekeeping de snapshots**: ao iniciar cada reset CNAE, o
   sistema pergunta com confirmacao se quer apagar snapshots antigos,
   mantendo os 5 mais recentes (decisao Mauricio: "limpeza com
   confirmacao");
3. **regressao de `Limpa_Base`**: novo cenario `CNAE_006` trava a
   garantia documentada na MsgBox de `Limpa_Base`: ATIVIDADES e
   CAD_SERV nunca sao tocados pela limpeza operacional.

A onda nao toca em `Mod_Types.bas`, nao toca em `Audit_Log.bas`, nao
toca em `.frm/.frx`, nao usa o script `publicar_vba_import.sh`, nao
usa `Importador_VBA.bas`. Toda integracao na ETAPA 9 do
`ResetarECarregarCNAE_Padrao` e aditiva e nao bloqueante.

## 01. Escopo

Entra:

- 3 helpers publicos em `Preencher.bas`:
  - `CnaeRemoverDuplicatasAtividades()`
  - `CnaePodarSnapshots(manterUltimos)`
  - `CnaeConfirmarPodaSnapshots(manterUltimos)`
- exposicao de `LimparAbaOperacional` como `Public` (sem alterar
  comportamento — apenas escopo);
- integracao no inicio de `ResetarECarregarCNAE_Padrao` (poda
  com confirmacao apos a confirmacao do usuario na ETAPA 4);
- integracao na ETAPA 9 (dedup automatico apos a contagem);
- ampliacao do MsgBox de conclusao com 2 linhas novas
  (`Snapshots antigos podados`, `Duplicatas removidas
  automaticamente`);
- ampliacao do evento `EVT_TRANSACAO`/`RESET_CNAE` com
  `SNAPSHOTS_PODADOS=N` e `DUPLICATAS_REMOVIDAS=N`;
- 3 cenarios novos `CNAE_004..006`.

Nao entra (vai para ondas seguintes ou backlog explicito):

- criacao de evento dedicado `EVT_CNAE_RESET` no enum (decisao
  Mauricio: "em onda futura prefiro manter um reset");
- bloqueio do salvamento quando duplicatas sao detectadas (a
  decisao foi remocao silenciosa, nao bloqueio);
- limpeza automatica sem confirmacao (a decisao foi pergunta
  obrigatoria);
- exportacao de snapshots para arquivo externo;
- funcionalidade de "limpar CNAE" via interface visual (nao e
  prioridade segundo Mauricio).

## 02. Arquivos modificados

| Arquivo | Mudanca |
|---|---|
| `src/vba/App_Release.bas` | carimbo `f7aa84f+ONDA03-em-homologacao`, data `2026-04-28 06:00` |
| `src/vba/Preencher.bas` | 3 funcoes publicas novas (`CnaeRemoverDuplicatas...`, `CnaePodarSnapshots`, `CnaeConfirmarPodaSnapshots`); `LimparAbaOperacional` agora `Public`; integracoes na ETAPA 4 e ETAPA 9 do reset; MsgBox de conclusao ampliado |
| `src/vba/Teste_V2_Roteiros.bas` | suite `TV2_RunCnae` ampliada de 3 para 6 cenarios (`CNAE_004..006` adicionados) |
| `src/vba/Central_Testes_V2.bas` | rotulo da opcao `[15]` atualizado para citar housekeeping |
| `auditoria/32_ONDA_03_CNAE_DEDUP_AUTOMATICO_E_HOUSEKEEPING.md` | este documento |
| `auditoria/33_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_03.md` | procedimento manual de import seguro |
| `CHANGELOG.md` | entrada `[Unreleased]` ampliada |
| `auditoria/INDEX.md` | indexa 32 e 33 |

**Nao tocados**: `Mod_Types.bas`, `Audit_Log.bas`, `Importador_VBA.bas`,
qualquer `.frm/.frx`, `Util_Config.bas`, `Svc_*.bas`, `Repo_*.bas`,
`Const_Colunas.bas`.

## 03. Modelo de dados

### 03.1 Dedup automatico

- chave logica: `UCase(CNAE) + "|" + UCase(DESCRICAO)`;
- algoritmo: Pass 1 identifica linhas duplicadas (preserva a primeira
  ocorrencia); Pass 2 remove em ordem reversa para nao corromper
  indices;
- contador da aba (`Cells(1, COL_CONTADOR_AR)`) atualizado para
  o numero real de linhas remanescentes apos remocao;
- cache invalidado via `InvalidarCacheCnaeAtividade`;
- retorna `-1` em caso de erro irrecuperavel (preserva contrato).

### 03.2 Poda de snapshots

- entrada: nome de cada aba que comeca com `SHEET_PREFIX_CAD_SERV_SNAP`;
- ordenacao por nome (timestamp embutido no proprio nome);
- preserva os N mais recentes (default 5);
- apaga as `qtdAtual - manterUltimos` mais antigas;
- silencia o aviso "deseja excluir aba?" temporariamente
  (`Application.DisplayAlerts = False`) e restaura;
- retorna `-1` em caso de erro irrecuperavel.

### 03.3 Confirmacao da poda

- so exibe MsgBox quando `qtdAtual > manterUltimos`;
- texto da MsgBox cita a quantidade total e a quantidade que sera
  podada, com botao default = `Yes`;
- resposta `No` retorna 0 sem podar nada;
- resposta `Yes` chama `CnaePodarSnapshots(manterUltimos)`.

### 03.4 Auditoria

- evento: `EVT_TRANSACAO` (existente);
- entidade: `ENT_ATIV`;
- IdAfetado: `RESET_CNAE`;
- novos campos no `Depois`: `SNAPSHOTS_PODADOS=N`,
  `DUPLICATAS_REMOVIDAS=N`.

## 04. Algoritmo do reset CNAE (ETAPA 9 reescrita pela Onda 3)

```
ResetarECarregarCNAE_Padrao:
  ETAPA 1..3: localizar CSV, ler, parsear cabecalho (sem mudanca)
  ETAPA 4: confirmar com usuario (sem mudanca)
  >>> NOVO: chamar CnaeConfirmarPodaSnapshots(5) (Onda 3)
  ETAPA 5..8: preparar aba, limpar dados, importar, restaurar (sem mudanca)
  ETAPA 9 (reescrita pela Onda 3):
    1. InvalidarCacheCnaeAtividade
    2. nomeSnapshot = CnaeSnapshotCadServ(qtdLinhasSnapshot)  [Onda 2]
    3. qtdCadServ = LimparCadServParaAssociacaoManual         [existente]
    4. qtdDuplicatas = CnaeContarDuplicatasAtividades()       [Onda 2]
    5. >>> NOVO Onda 3: SE qtdDuplicatas > 0:
            qtdDupRemovidas = CnaeRemoverDuplicatasAtividades()
    6. RegistrarEvento(EVT_TRANSACAO, ..., "RESET_CNAE_CONCLUIDO; ... ;
       SNAPSHOTS_PODADOS=N; ATIVIDADES_DUPLICATAS=N;
       DUPLICATAS_REMOVIDAS=N")
    7. PreenchimentoListaAtividade
    8. PreencherManutencaoValor
    9. Util_SalvarWorkbookSeguro
    10. MsgBox de conclusao com snapshots_podados e duplicatas_removidas
```

Comportamento permanece **aditivo e nao bloqueante**: se algum helper
da Onda 3 falhar internamente (retorna `-1`), o reset continua e a
auditoria registra o estado.

## 05. Cenarios automatizados (suite `CNAE`, agora com 6)

| ID | Origem | Pre-condicao | Acao | Resultado esperado |
|---|---|---|---|---|
| `CNAE_001` | Onda 2 | Triplo canonico | `CnaeSnapshotCadServ()` | aba `CAD_SERV_SNAPSHOT_<ts>` criada |
| `CNAE_002` | Onda 2 | Triplo canonico | injeta duplicata, conta | baseline=0; pos-injecao>=1 |
| `CNAE_003` | Onda 2 | Triplo canonico | dois snapshots em sequencia | nomes distintos, lista ordenada |
| `CNAE_004` | **Onda 3** | Triplo canonico, duplicata injetada | `CnaeRemoverDuplicatasAtividades()` + recontagem | REMOVIDAS>=1, DUP_APOS_REMOCAO=0 |
| `CNAE_005` | **Onda 3** | 4 snapshots criados | `CnaePodarSnapshots(2)` + listagem | restam 2; podadas = qtdInicial-2 |
| `CNAE_006` | **Onda 3** | base com EMPRESAS, ENTIDADE, etc. | `LimparAbaOperacional` em 5 abas operacionais | abas operacionais limpas; ATIVIDADES e CAD_SERV intactas |

## 06. Gate de teste

Detalhes em
[auditoria/33_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_03.md](33_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_03.md).
Resumo: backup, ensaio em copia descartavel com import apenas de
`App_Release.bas`, depois import manual de 4 arquivos `.bas` (App_Release,
Preencher, Teste_V2_Roteiros, Central_Testes_V2), compilacao apos cada
um, trio minimo verde, suite `[14]` com `OK=7` (regressao Onda 1),
suite `[15]` com `OK=6` (Onda 2 + Onda 3).

## 07. Riscos e mitigacoes

| Risco | Mitigacao |
|---|---|
| Dedup remover linhas legitimas | algoritmo preserva a primeira ocorrencia de cada par `(CNAE, DESCRICAO)`; chave inclui descricao integral, nao apenas codigo |
| Poda apagar snapshot ainda necessario | sempre via `CnaeConfirmarPodaSnapshots` com botao default `Yes`; resposta `No` preserva todos |
| MsgBox da poda atrapalhar fluxo automatizado | so aparece quando `qtdSnapshots > 5` (default); operador raramente atinge esse limite no uso cotidiano |
| `LimparAbaOperacional` exposta como Public abrir uso indevido | o nome ja sugere uso restrito; a unica chamada externa em codigo de teste e da suite CNAE_006; nenhum codigo de producao novo a chama |
| Cenario CNAE_006 destruir base e contaminar suites seguintes | a suite CNAE roda isoladamente; cada suite que precisa de base reseta via `TV2_PrepararCenarioTriploCanonico` no inicio; CNAE_006 e o ultimo cenario da CNAE |
| Pass 2 (Rows.Delete) lento em base grande | base CNAE real tem ~600 linhas; duplicatas reais sao raras; performance nao e gargalo |

## 08. Fronteiras nao tocadas

- `Mod_Types.bas`: intocado;
- `Audit_Log.bas`: intocado (continua reuso de `EVT_TRANSACAO`);
- `Importador_VBA.bas`: intocado;
- todos os `.frm/.frx`: intocados;
- `Util_Config.bas`, `Svc_*.bas`, `Repo_*.bas`, `Const_Colunas.bas`:
  intocados;
- regra de strikes da Onda 1: intocada (zero dependencia cruzada);
- snapshots ja criados nas Ondas anteriores: respeitados;
- comportamento da Onda 2 (snapshot + contagem): preservado.

## 09. Decisoes de produto registradas

Conforme alinhamento com Mauricio em 2026-04-28:

1. **duplicatas removidas automaticamente, sem bloqueio**: implementado;
2. **snapshots podados com confirmacao humana, manter 5 mais recentes**:
   implementado (parametrizavel);
3. **`EVT_CNAE_RESET` adiado para onda futura**: mantido `EVT_TRANSACAO`;
4. **funcionalidade de "limpar CNAE" via interface**: nao e prioridade
   nesta release; backlog pos-V12.0.0203;
5. **garantia de "Limpa_Base preserva CNAE"**: confirmada por inspecao
   do codigo existente; trava por cenario `CNAE_006`.

## 10. Proxima onda

Apos OK desta onda, segue a **ONDA 4 — cenario E2E `CS_25_CREDENCIAMENTO_ENDtoEND`
+ suite de filtros completa via `Util_Filtro_Lista`** conforme plano
em `auditoria/27`. Onda igualmente isolada, sem tocar formulario.
