---
titulo: Onda 38.2.16 Fix1 - marcador persistente Auto_Open BL-4
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-01
---

# Onda 38.2.16 Fix1 - marcador persistente Auto_Open BL-4

## Estado

Micro-fix implementado e pronto para gate humano:

- `.hbn/readbacks/0133-rb-onda-38-2-16-fix1-bl4-autoopen-marker.json`
- `.hbn/hearbacks/0133-rb-onda-38-2-16-fix1-bl4-autoopen-marker-confirmed.json`
- `.hbn/results/0133-exec-onda-38-2-16-fix1-bl4-autoopen-marker.json`
- `human_status`: `confirmed`
- `status`: `ready_for_human_gate`

Mauricio confirmou o readback em chat. O codigo foi alterado somente dentro do
escopo autorizado.

## Origem

A Onda 38.2.16 importou e compilou, mas falhou duas vezes no mesmo assert:

- `TV2_20260601_105519`: `OK=4 | FALHA=1 | MANUAL=0`;
- `TV2_20260601_110148`: `OK=4 | FALHA=1 | MANUAL=0`.

Falha unica repetida:

`BL4_01_AUTO_OPEN_REAPLICOU_PROTECAO`

Resultado obtido:

`EXECUTADA_EM=nao registrada; OK=Falso; DETALHES=`

Os demais asserts de protecao passaram. A leitura atual e que a protecao
concreta esta sendo verificada, mas o sinal de execucao de `Auto_Open` nao deve
depender exclusivamente de variavel VBA em memoria.

## Decisao explicita confirmada

Hearback confirmado:

`confirmo o readback 0133-rb-onda-38-2-16-fix1-bl4-autoopen-marker`

Escopo da autorizacao:

- tocar `src/vba/Auto_Open.bas` e
  `local-ai/vba_import/001-modulo/AAY-Auto_Open.bas` somente para persistir e
  ler marcador auditavel de execucao de `Auto_Open`;
- tocar `Teste_V2_Engine.bas`, `Teste_V2_Roteiros.bas` e seus espelhos apenas
  para ajustar `BL4_01` e catalogo/roteiro;
- tocar `App_Release.bas` e espelho para build label;
- gerar manifesto V3 fix1.

Limites:

- nao alterar `ThisWorkbook.code.txt`;
- nao alterar `Util_Planilha.bas`, `Mod_Types.bas` ou `Importador_V3.bas`;
- nao alterar formularios, `Preencher.bas`, `Svc_*` ou `Repo_*`;
- nao tocar `.frx`;
- nao declarar freeze V206.

## Implementacao

1. `Auto_Open.bas`
   - grava nomes ocultos do workbook com timestamp, OK e detalhes da ultima
     reaplicacao de protecao executada na abertura;
   - torna a gravacao idempotente;
   - expoe funcoes publicas minimas para a suite V2 ler o marcador persistente:
     `AutoOpen_UltimaProtecaoMarcadorOk`,
     `AutoOpen_UltimaProtecaoMarcadorDetalhes`,
     `AutoOpen_UltimaProtecaoMarcadorExecutadaEm` e
     `AutoOpen_UltimaProtecaoMarcadorAposUltimoSave`;
   - preserva as assinaturas publicas e o fluxo atual de abertura.

2. `Teste_V2_Roteiros.bas`
   - ajusta `BL4_01_AUTO_OPEN_REAPLICOU_PROTECAO` para validar o marcador
     persistente;
   - mantem `BL4_02` a `BL4_05` sem relaxar os asserts que ja passaram.

3. Pacote V3
   - publicou quatro modulos permitidos;
   - gerou manifesto
     `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_16_FIX1_BL4_AUTOOPEN_MARKER.txt`.

## Pacote V3

Comando operacional:

```vb
ImportarPacoteV3_Delta "ONDA38_2_16_FIX1_BL4_AUTOOPEN_MARKER", "e157221+ONDA38.2.16-FIX1-BL4-MARKER"
```

Resultado esperado do Importador V3:

`M=4 | F=0 | err=0`

## Gate humano esperado

Depois da implementacao e importacao:

1. Importar pelo comando V3 acima.
2. VBE > Depurar > Compilar VBAProject.
3. Salvar o workbook.
4. Fechar e reabrir o workbook.
5. Executar na Janela Imediata:

```vb
TV2_RunBL4ProtecaoPersistente
```

Resultado esperado:

`OK=5 | FALHA=0 | MANUAL=0`

## Resultado do gate humano

Mauricio reportou em 2026-06-01:

- Importador V3: `modo=Estabilizado | dryRun=False | M=4 | F=0 | err=0 | skip=0`;
- Compile VBAProject: passou;
- Suite: `TV2_RunBL4ProtecaoPersistente`;
- Execucao: `TV2_20260601_115504`;
- Resultado: `OK=4 | FALHA=1 | MANUAL=0`.

CSV de falha:

`TesteV2_BL4_PROTECAO_PERSISTENTE_Falhas_TV2_20260601_115504.csv`

Falha unica:

`BL4_01_AUTO_OPEN_REAPLICOU_PROTECAO`

Resultado obtido:

`EXECUTADA_EM=nao registrada; MARCADOR_TS=nao registrado; MARCADOR_OK=Falso; MARCADOR_DETALHES=`

Interpretacao: o marcador persistente nao existia no workbook no momento do
teste. Como `ThisWorkbook.Workbook_Open` chama `IniciarSistema`, a proxima etapa
nao deve ser nova implementacao ainda; primeiro e preciso diagnosticar se o
evento de abertura disparou e se `Application.EnableEvents` estava ativo no
reopen.

## Proxima acao diagnostica

Na Janela Imediata, antes de novo codigo:

```vb
?Application.EnableEvents
?AutoOpen_UltimaProtecaoMarcadorExecutadaEm
?AutoOpen_UltimaProtecaoMarcadorOk
?AutoOpen_UltimaProtecaoMarcadorDetalhes
IniciarSistema
?AutoOpen_UltimaProtecaoMarcadorExecutadaEm
?AutoOpen_UltimaProtecaoMarcadorOk
?AutoOpen_UltimaProtecaoMarcadorDetalhes
```

Mauricio executou o diagnostico:

- `Application.EnableEvents`: `Verdadeiro`;
- antes de `IniciarSistema`: marcador vazio, `OK=Falso`;
- depois de `IniciarSistema`: `01/06/2026 12:04:42`, `OK=Verdadeiro`,
  detalhes `OK`;
- depois: `Application.EnableEvents = True` e `ThisWorkbook.Save`.

Isso confirmou que a correcao de marcador funciona quando `IniciarSistema`
executa. A falha intermediaria `TV2_20260601_115504` decorreu da ausencia de
marcador antes da chamada de inicializacao, nao de erro na gravacao persistente.

## Re-teste verde

Mauricio executou novamente `TV2_RunBL4ProtecaoPersistente`:

- Execucao: `TV2_20260601_120900`;
- Resultado: `OK=5 | FALHA=0 | MANUAL=0`;
- CSV de falhas: nao exportado.

Veredito: BL-4 validado por suite V2 apos fix1 e diagnostico operacional.

## Validacoes locais

- Readback 0133 confirmado por hearback humano.
- Publicador V2 `apply/check` em quatro modulos, com G7/G8 OK.
- Manifesto V3 fix1 gerado com hash dos quatro artefatos.
- `git diff --check` limpo.
- `scripts/hbn-guards/hbn-guards-runner.sh` limpo.
- `ThisWorkbook.code.txt`, `Util_Planilha.bas`, `Mod_Types.bas`,
  `Importador_V3.bas`, formularios, `Preencher.bas`, `Svc_*`, `Repo_*` e
  `.frx` permaneceram fora da edicao 0133.
