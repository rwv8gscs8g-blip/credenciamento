---
titulo: ONDA 2 — CNAE: snapshot, dedup e teste
natureza-do-documento: documento tecnico de microevolucao com escopo, codigo, testes e gate
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
branch: codex/v12-0-0203-governanca-testes
data: 2026-04-27
autor: Claude Opus 4.7 (sessao Cowork — executor)
solicitante: Luis Mauricio Junqueira Zanin
plano-mestre: auditoria/27_PLANO_ESTEIRA_OPUS_RELEASE_V203.md
documento-irmao-procedimento: auditoria/31_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_02.md
---

# 30. ONDA 2 — CNAE: snapshot, dedup e teste

## 00. Sintese

Adiciona trilha auditavel ao reset CNAE: antes de chamar
`LimparCadServParaAssociacaoManual`, o sistema agora copia
`CAD_SERV` para uma aba snapshot `CAD_SERV_SNAPSHOT_<timestamp>`
protegida; depois do import, conta duplicatas
`(CNAE, DESCRICAO)` em `ATIVIDADES`; o resumo do reset (incluindo
nome do snapshot e contagem de duplicatas) entra em `AUDIT_LOG` como
`EVT_TRANSACAO`. Suite nova `CNAE_001..003` exercita os helpers sem
rodar o reset real (que tem `MsgBox` e depende de CSV externo).

## 01. Escopo

Entra:

- 3 helpers publicos em `Preencher.bas`
  (`CnaeSnapshotCadServ`, `CnaeContarDuplicatasAtividades`,
  `CnaeListarSnapshots`);
- 1 helper privado em `Preencher.bas` (`CnaeAbaExiste`);
- integracao desses helpers na ETAPA 9 do `ResetarECarregarCNAE_Padrao`;
- 1 constante de prefixo em `Const_Colunas.bas`
  (`SHEET_PREFIX_CAD_SERV_SNAP`);
- 1 suite `TV2_RunCnae` com 3 cenarios em `Teste_V2_Roteiros.bas`,
  mais helpers privados de teste
  (`TV2_RemoverSnapshotsCnaeAnteriores`, `CnaeAbaExisteTeste`);
- 1 nova opcao na `Central_Testes_V2` (`[15] CNAE: snapshot e dedup`).

Nao entra (vai para ondas seguintes):

- alteracao do enum `eTipoEvento` em `Audit_Log.bas` (decisao
  deliberada — reuso de `EVT_TRANSACAO` evita risco de regressao
  em qualquer codigo que use o enum por indice numerico);
- bloqueio de salvamento quando duplicatas detectadas (a regra atual
  apenas reporta — bloquear sera decisao futura);
- exportacao automatica do snapshot para arquivo externo;
- limpeza automatica de snapshots antigos (continua manual).

## 02. Arquivos modificados

| Arquivo | Mudanca |
|---|---|
| `src/vba/App_Release.bas` | carimbo `f7aa84f+ONDA02-em-homologacao`, data `2026-04-27 10:30` |
| `src/vba/Const_Colunas.bas` | nova constante `SHEET_PREFIX_CAD_SERV_SNAP = "CAD_SERV_SNAPSHOT_"` |
| `src/vba/Preencher.bas` | ETAPA 9 do `ResetarECarregarCNAE_Padrao` ampliada (snapshot + dedup + auditoria); 3 funcoes publicas novas e 1 helper privado novo no final do arquivo |
| `src/vba/Teste_V2_Roteiros.bas` | suite nova `TV2_RunCnae` (`CNAE_001..003`) e 2 helpers privados |
| `src/vba/Central_Testes_V2.bas` | opcao `[15]` no menu, sub `CT2_ExecutarCnae` |
| `auditoria/30_ONDA_02_CNAE_SNAPSHOT_DEDUP.md` | este documento |
| `auditoria/31_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_02.md` | procedimento manual de import seguro |
| `CHANGELOG.md` | entrada `[Unreleased]` ampliada |
| `auditoria/INDEX.md` | indexa 30 e 31 |

**Nao tocados** (regra inviolavel): `Mod_Types.bas`, `Audit_Log.bas`,
`Importador_VBA.bas`, qualquer `.frm/.frx`, `Svc_Rodizio.bas`,
`Svc_PreOS.bas`, `Svc_OS.bas`, `Svc_Avaliacao.bas`, `Util_Config.bas`.

## 03. Modelo de dados

### 03.1 Aba snapshot

- nome: `CAD_SERV_SNAPSHOT_yyyymmdd_hhnnss` (com sufixo `_NN` se
  duas execucoes acontecerem no mesmo segundo);
- conteudo: copia integral de `CAD_SERV` (cabecalho + dados +
  formatos), preservando linha 1 do contador `COL_CONTADOR_AR`;
- protecao: aba sai protegida com a senha padrao
  (`Util_SenhaProtecaoPadrao`) e `UserInterfaceOnly:=True`;
- ciclo de vida: nao e apagada automaticamente; o operador remove
  manualmente quando nao precisar mais da referencia.

### 03.2 Auditoria do reset

- evento: `EVT_TRANSACAO` (existente — sem mexer no enum);
- entidade: `ENT_ATIV`;
- IdAfetado: `"RESET_CNAE"` (string fixa para facilitar filtro);
- `Antes`: `ATIVIDADES_ANTES=<n>; CADSERV_ANTES=<n>`;
- `Depois`: `RESET_CNAE_CONCLUIDO; ATIVIDADES_IMPORTADAS=<n>;
  CADSERV_LIMPADO=<n>; SNAPSHOT=<nome>; SNAPSHOT_LINHAS=<n>;
  ATIVIDADES_DUPLICATAS=<n>`.

### 03.3 Detecao de duplicata

- chave logica: `UCase(CNAE) + "|" + UCase(DESCRICAO)`;
- linhas vazias (CNAE e DESCRICAO ambos em branco) sao ignoradas;
- `CnaeContarDuplicatasAtividades()` retorna a contagem; `-1` quando
  ocorre erro irrecuperavel na varredura (proteção defensiva).

## 04. Algoritmo

```
ResetarECarregarCNAE_Padrao (ETAPA 9 reescrita):
  1. InvalidarCacheCnaeAtividade (existente)
  2. nomeSnapshot = CnaeSnapshotCadServ(qtdLinhasSnapshot)
  3. qtdCadServ = LimparCadServParaAssociacaoManual (existente)
  4. qtdDuplicatas = CnaeContarDuplicatasAtividades()
  5. RegistrarEvento(EVT_TRANSACAO, ENT_ATIV, "RESET_CNAE", ...)
  6. PreenchimentoListaAtividade (existente)
  7. PreencherManutencaoValor (existente)
  8. Util_SalvarWorkbookSeguro (existente)
  9. MsgBox de conclusao agora informa snapshot + duplicatas
```

A nova logica e **aditiva**: se `CnaeSnapshotCadServ` falhar
internamente (retorna `""`), o reset continua e a auditoria registra
`SNAPSHOT=`. Se `CnaeContarDuplicatasAtividades` falhar, registra
`ATIVIDADES_DUPLICATAS=-1`. Em nenhum caso o reset e abortado pela
nova logica — preserva o comportamento historico sob a regra "nao
introduzir bloqueio sem aprovacao explicita".

## 05. Cenarios automatizados (suite `CNAE`)

| ID | Pre-condicao | Acao | Resultado esperado | Razao |
|---|---|---|---|---|
| `CNAE_001` | Triplo canonico (3 entidades, 3 empresas, 3 servicos canonicos), sem snapshots anteriores | `CnaeSnapshotCadServ()` | aba `CAD_SERV_SNAPSHOT_<ts>` criada; nome comeca com `SHEET_PREFIX_CAD_SERV_SNAP`; aba existe; contagem informada bate com a real | prova a trilha auditavel basica do estado anterior |
| `CNAE_002` | Triplo canonico em `ATIVIDADES`, sem duplicatas iniciais | contar duplicatas, injetar uma copia da primeira linha, recontar, restaurar | baseline=0; pos-injecao>=1 | prova que a deteccao funciona e nao mascara duplicata |
| `CNAE_003` | Triplo canonico, primeiro snapshot ja criado | criar segundo snapshot; chamar `CnaeListarSnapshots()` | dois nomes distintos; ambas as abas existem; lista ordenada por timestamp | prova que historico nao e sobrescrito |

Os cenarios **nao chamam** `ResetarECarregarCNAE_Padrao` (para evitar
`MsgBox` e dependencia de CSV externo). Em vez disso, exercitam os
helpers diretamente, simulando o ciclo do reset por composicao.

## 06. Gate de teste

Detalhes em
[auditoria/31_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_02.md](31_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_02.md).
Resumo: backup, ensaio em copia descartavel com import apenas de
`Const_Colunas.bas`, depois import manual de 5 arquivos `.bas` na ordem
canonica (App_Release, Const_Colunas, Preencher, Teste_V2_Roteiros,
Central_Testes_V2), compilacao apos cada um, trio minimo verde, suite
nova `[15]` verde com `OK=3`, `FALHA=0`.

## 07. Riscos e mitigacoes

| Risco | Mitigacao |
|---|---|
| Snapshot poluir o workbook com muitas abas | snapshot so e criado quando o reset CNAE executa (acao manual rara); operador remove abas antigas via clique-direito quando quiser; suite de teste limpa proprios snapshots ao final |
| `ResetarECarregarCNAE_Padrao_DryRun` (do Codex em working tree) entrar em conflito | os helpers da Onda 2 usam nomes distintos (`CnaeSnapshot...`, `CnaeContarDuplicatas...`) que nao colidem com `CnaeDryRun_*`; ambas as familias coexistem |
| Auditoria via `EVT_TRANSACAO` ser confundida com rollback | o IdAfetado fixo `"RESET_CNAE"` no campo `IdAfetado` permite filtrar facilmente; o texto `RESET_CNAE_CONCLUIDO` no campo `Depois` deixa explicito |
| `CnaeContarDuplicatasAtividades` ser lenta em base grande | usa `Scripting.Dictionary`; varredura linear O(n); aceitavel para `ATIVIDADES` ate ~10000 linhas (dimensao real e ~600) |
| Snapshot protegido bloquear reaproveitamento | a senha padrao `Util_SenhaProtecaoPadrao` e a mesma do projeto; operador pode desproteger via `Revisao > Desproteger Planilha` quando precisar copiar dados |

## 08. Fronteiras nao tocadas

- `src/vba/Mod_Types.bas`: intocado;
- `src/vba/Audit_Log.bas`: intocado (reuso de `EVT_TRANSACAO`);
- `src/vba/Importador_VBA.bas`: intocado;
- `src/vba/Menu_Principal.frm` e demais formularios: intocados;
- nucleo do rodizio (`Svc_Rodizio`, `Svc_PreOS`, `Svc_OS`,
  `Svc_Avaliacao`): intocado;
- regra de strikes da Onda 1: intocada (sem dependencia cruzada).

## 09. Decisoes pendentes para Mauricio

1. confirmar que duplicatas detectadas devem **apenas reportar**
   (regra atual) e nao bloquear o salvamento? Se quiser bloquear, abro
   onda separada com flag `CONFIG.BLOQUEAR_DUP_CNAE` e cenarios
   adicionais.
2. confirmar que snapshots nao precisam de limpeza automatica? Se
   quiser limpeza apos N dias ou apos N snapshots, abro onda separada
   com helper `CnaePodarSnapshots(antesDe)`.
3. confirmar que o evento de auditoria como `EVT_TRANSACAO` e suficiente
   ou prefere uma onda futura criando `EVT_CNAE_RESET` no enum (toca
   `Audit_Log.bas` em escopo controlado)?

## 10. Proxima onda

Apos OK desta onda (e do carimbo `App_Release.bas` aplicado), segue a
**ONDA 3 — cenario E2E `CS_25_CREDENCIAMENTO_ENDtoEND` + suite de
filtros completa** conforme plano `auditoria/27`.
