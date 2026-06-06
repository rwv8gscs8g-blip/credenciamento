---
titulo: Onda 38.2.17 - formularios avaliacao demandante
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-01
---

# Onda 38.2.17 - formularios avaliacao demandante

## Estado

Readback confirmado por Mauricio:

- `.hbn/readbacks/0134-rb-onda-38-2-17-formularios-avaliacao-demandante.json`
- `.hbn/hearbacks/0134-rb-onda-38-2-17-formularios-avaliacao-demandante-confirmed.json`
- `human_status`: `confirmed`
- comando confirmado:

`confirmo o readback 0134-rb-onda-38-2-17-formularios-avaliacao-demandante`

Codigo liberado somente dentro do escopo autorizado.

## Conferencia do marcador BL-4

A questao do marcador foi fechada como funcional no escopo 0133:

- `Auto_Open.bas` grava nomes ocultos do workbook:
  `_HBN_BL4_AUTOOPEN_TS`, `_HBN_BL4_AUTOOPEN_OK`,
  `_HBN_BL4_AUTOOPEN_DETALHES`;
- as funcoes publicas de leitura fazem fallback do estado em memoria para o
  marcador persistente;
- a primeira suite apos import (`TV2_20260601_115504`) falhou porque o marcador
  ainda nao existia;
- o diagnostico humano mostrou `Application.EnableEvents=True`; apos
  `IniciarSistema`, o marcador passou a retornar timestamp, `OK=True` e
  detalhes `OK`;
- apos `ThisWorkbook.Save`, a suite `TV2_20260601_120900` retornou
  `OK=5 | FALHA=0 | MANUAL=0`.

Conclusao operacional: o mecanismo do marcador funciona quando o ciclo de
inicializacao roda e o workbook e salvo. Nao ha autorizacao nesta onda para
reabrir `Auto_Open.bas`.

## Problema alvo

Mauricio reportou que os formularios ainda precisam de melhoria e que o
formulario de avaliacao nao registra o nome do demandante.

Leitura inicial do codigo:

- `Menu_Principal.EncerraOS_Click` monta o payload usando `AVListaCol(1)` como
  `avaliador` e usa `Desc_entidade` como fallback;
- `PreencherAvaliarOS` tenta popular `AV_Lista` coluna 1 buscando
  `ENTIDADE.NOME` pelo `CAD_OS.ENT_ID`;
- `Svc_Avaliacao.MontarPayloadAvaliacao` rejeita `payloadAvaliador` vazio;
- `Repo_Avaliacao` persiste notas, media, observacoes, status, datas, quantidade
  e valores em `CAD_OS`, mas nao ha coluna dedicada para nome do demandante.

Decisao da fatia: nao criar schema novo. A fonte autoritativa do demandante
permanece `CAD_OS.ENT_ID`; a onda deve resolver, carregar e imprimir o nome por
essa chave.

## Escopo proposto

Arquivos de codigo permitidos:

- `src/vba/Svc_Avaliacao.bas`
- `src/vba/Preencher.bas`
- `src/vba/Menu_Principal.frm`
- `src/vba/Teste_V2_Engine.bas`
- `src/vba/Teste_V2_Roteiros.bas`
- `src/vba/App_Release.bas`
- espelhos correspondentes em `local-ai/vba_import/`

Arquivos proibidos:

- `src/vba/Auto_Open.bas`
- `src/vba/Mod_Types.bas`
- `src/vba/Importador_V3.bas`
- `src/vba/Repo_Avaliacao.bas`
- `src/vba/Const_Colunas.bas`
- `local-ai/vba_import/003-objetos/ThisWorkbook.code.txt`
- qualquer `.frx`

## Plano tecnico

1. Criar helper publico em `Svc_Avaliacao.bas` para resolver demandante por
   `OS_ID`.
2. Trocar a varredura silenciosa de `PreencherAvaliarOS` pelo helper, mantendo
   a coluna visivel da lista preenchida com nome do demandante.
3. Em `EncerraOS_Click`, resolver o demandante pelo `OS_ID` antes de montar o
   payload e antes de preencher variaveis de impressao.
4. Se o demandante nao puder ser resolvido, bloquear a gravacao com mensagem
   clara.
5. Adicionar suite V2 `TV2_RunFormulariosAvaliacaoDemandante`.
6. Publicar pacote V3 delta
   `ONDA38_2_17_FORMULARIOS_AVALIACAO_DEMANDANTE`.

## Implementacao

Entregue em codigo:

1. `Svc_Avaliacao.bas`
   - adiciona `ResolverDemandanteAvaliacaoPorOS`, que busca a OS por `OS_ID`,
     le `CAD_OS.ENT_ID` e resolve o nome em `ENTIDADE.NOME`;
   - retorna `TResult` com mensagem e detalhes auditaveis quando a OS nao
     existe, nao tem `ENT_ID`, aponta para entidade inexistente ou entidade sem
     nome.
2. `Preencher.bas`
   - `PreencherAvaliarOS` passa a usar o helper do servico para preencher a
     coluna visivel do demandante em `AV_Lista`;
   - falha de resolucao deixa a coluna vazia, e a gravacao final e bloqueada no
     formulario.
3. `Menu_Principal.frm`
   - `EncerraOS_Click` resolve o demandante pelo `OS_ID` antes de montar notas,
     payload e impressao;
   - se a resolucao falhar, exibe mensagem e nao grava avaliacao incompleta;
   - o resumo de confirmacao mostra o demandante;
   - `MontarPayloadAvaliacao` recebe o demandante resolvido, nao `Desc_entidade`
     obsoleto;
   - variavel de impressao `Desc_entidade` e preenchida pelo mesmo valor
     resolvido.
4. `Teste_V2_Roteiros.bas` / `Teste_V2_Engine.bas`
   - adiciona `TV2_RunFormulariosAvaliacaoDemandante` com 7 asserts:
     `FD_AV_01` prepara OS em execucao;
     `FD_AV_02` resolve demandante por OS;
     `FD_AV_03` valida `AV_Lista`;
     `FD_AV_04` valida payload vazio vs demandante resolvido;
     `FD_AV_05` valida variavel de impressao;
     `FD_AV_06` conclui a OS via `AvaliarOS` e exige auditoria
     `AVALIADOR=Local 1`;
     `FD_AV_07` valida falha auditavel com `ENT_ID` inexistente.
5. `App_Release.bas`
   - build label: `e157221+ONDA38.2.17-FORM-AVAL-DEMANDANTE`.

## Pacote V3

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_17_FORMULARIOS_AVALIACAO_DEMANDANTE.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_17_FORMULARIOS_AVALIACAO_DEMANDANTE", "e157221+ONDA38.2.17-FORM-AVAL-DEMANDANTE"
```

Resultado esperado do Importador V3:

`M=5 | F=1 | err=0`

Suite esperada:

```vb
TV2_RunFormulariosAvaliacaoDemandante
```

Resultado esperado:

`OK=7 | FALHA=0 | MANUAL=0`

## Validacoes locais

- `scripts/hbn-guards/validate-readback.sh .hbn/readbacks/0134-rb-onda-38-2-17-formularios-avaliacao-demandante.json`: OK.
- `bash local-ai/scripts/publicar_vba_import_v2.sh --check --only ...`: G7/G8 OK, 6 arquivos em sync.
- `git diff --check`: OK.
- `.frx`: sem diff.

## Fora de escopo registrado

Sobre a pergunta operacional de Mauricio: sim, `IniciarSistema` precisa rodar
na abertura normal do workbook para que o sistema inicialize e para que o
marcador BL-4 seja criado. Se eventos/macros nao dispararem, chamada manual
continua possivel. A proposta de criar botao/indicativo visual discreto na
planilha para `IniciarSistema` fica registrada para onda propria posterior,
porque a 38.2.17 nao autoriza tocar `Auto_Open.bas`, `ThisWorkbook` ou desenho
de planilha.

## Gate humano esperado

1. Importar delta V3.
2. Compilar o VBAProject.
3. Executar `TV2_RunFormulariosAvaliacaoDemandante`.
4. Reportar execucao, contagem `OK/FALHA/MANUAL` e CSV de falhas se houver.

Freeze V206 segue bloqueado.
