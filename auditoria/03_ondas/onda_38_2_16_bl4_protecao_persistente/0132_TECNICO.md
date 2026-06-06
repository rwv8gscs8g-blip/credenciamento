---
titulo: Onda 38.2.16 - BL-4 protecao persistente
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-01
---

# Onda 38.2.16 - BL-4 protecao persistente

## Estado

Pacote implementado, importado e compilado, mas o gate humano falhou:

- `.hbn/readbacks/0132-rb-onda-38-2-16-bl4-protecao-persistente.json`
- `.hbn/hearbacks/0132-rb-onda-38-2-16-bl4-protecao-persistente-confirmed.json`
- `.hbn/results/0132-exec-onda-38-2-16-bl4-protecao-persistente.json`
- `human_status`: `confirmed`
- `status`: `human_gate_failed`

Mauricio confirmou o readback em chat. A excecao para `Auto_Open.bas` foi usada
somente dentro do limite aprovado.

## Resultado do gate humano

Mauricio reportou em 2026-06-01 a primeira execucao:

- Importador V3: `modo=Estabilizado | dryRun=False | M=5 | F=0 | err=0 | skip=0`;
- Compile VBAProject: passou;
- Suite: `TV2_RunBL4ProtecaoPersistente`;
- Execucao: `TV2_20260601_105519`;
- Resultado: `OK=4 | FALHA=1 | MANUAL=0`.

CSV de falha:

`TesteV2_BL4_PROTECAO_PERSISTENTE_Falhas_TV2_20260601_105519.csv`

Falha unica:

`BL4_01_AUTO_OPEN_REAPLICOU_PROTECAO`

Resultado obtido:

`EXECUTADA_EM=nao registrada; OK=Falso; DETALHES=`

Interpretacao: os demais asserts de protecao passaram, mas o status guardado
por `Auto_Open` nao estava presente no momento da suite. Isso e compativel com
execucao sem o ciclo save/close/reopen correto, ou com algum reset do estado VBA
entre a abertura e o teste.

Mauricio repetiu o gate e reportou nova falha em:

- Execucao: `TV2_20260601_110148`;
- Resultado: `OK=4 | FALHA=1 | MANUAL=0`;
- CSV:
  `TesteV2_BL4_PROTECAO_PERSISTENTE_Falhas_TV2_20260601_110148.csv`;
- Falha unica:
  `BL4_01_AUTO_OPEN_REAPLICOU_PROTECAO`;
- Resultado obtido:
  `EXECUTADA_EM=nao registrada; OK=Falso; DETALHES=`.

Com a segunda falha igual, a proxima acao deixa de ser rerun e passa a ser
micro-fix 0133: persistir/instrumentar um marcador auditavel de execucao de
`Auto_Open`, em vez de depender apenas de variavel em memoria.

## Decisao explicita requerida

Esta onda pede uma excecao estreita para tocar `Auto_Open.bas`.

Texto da decisao: Mauricio autoriza, para a Onda 38.2.16, tocar
`src/vba/Auto_Open.bas` e
`local-ai/vba_import/001-modulo/AAY-Auto_Open.bas` somente para
reaplicacao/instrumentacao verificavel da protecao critica na abertura do
workbook.

Limites:

- nao alterar `ThisWorkbook.code.txt`;
- nao alterar `Mod_Types.bas` ou `Importador_V3.bas`;
- nao alterar formularios, `Preencher.bas`, `Svc_*` ou `Repo_*`;
- nao tocar `.frx`;
- nao declarar freeze V206.

## Plano tecnico

1. `Auto_Open.bas`
   - Removeu o silencio da protecao critica dentro de `InicializarSistema`.
   - Isolou a reaplicacao em helper interno que chama
     `Util_ProtegerAbasCriticasVerificado`.
   - Guarda ultimo status/detalhes da protecao da abertura para leitura da
     suite V2.
   - Preserva `Auto_Open`, `IniciarSistema`, `AbrirMenu` e o fluxo de abertura
     do `Menu_Principal`.

2. `Util_Planilha.bas`
   - Adicionou verificador pos-abertura para confirmar:
     `ProtectContents=True`, `ProtectDrawingObjects=True`, celulas bloqueadas e
     escrita VBA em celula bloqueada com mesmo valor.
   - Esse ultimo ponto evidencia que `UserInterfaceOnly` foi reaplicado apos
     reopen.

3. `Teste_V2_Roteiros.bas` e `Teste_V2_Engine.bas`
   - Adicionou `TV2_RunBL4ProtecaoPersistente`.
   - A suite deve ser rodada apos importar, compilar, salvar, fechar e reabrir o
     workbook.
   - Resultado esperado: `OK=5 | FALHA=0 | MANUAL=0`.
   - Catalogo e roteiro V2 foram atualizados com os cenarios `BL4_01` a
     `BL4_05`.

4. Pacote V3
   - Manifesto gerado:
     `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_16_BL4_PROTECAO_PERSISTENTE.txt`.
   - Import esperado: `M=5 | F=0 | err=0`.

## Procedimento de gate humano

Na Janela Imediata:

```vb
ImportarPacoteV3_Delta "ONDA38_2_16_BL4_PROTECAO_PERSISTENTE", "e157221+ONDA38.2.16-BL4-PROT-PERSIST"
```

Depois:

1. VBE > Depurar > Compilar VBAProject.
2. Salvar o workbook.
3. Fechar e reabrir o workbook para disparar `Workbook_Open`/`Auto_Open`.
4. Na Janela Imediata:

```vb
TV2_RunBL4ProtecaoPersistente
```

Resultado esperado:

`OK=5 | FALHA=0 | MANUAL=0`

## Proxima acao

Abrir micro-fix 0133 para tornar o sinal de abertura persistente/auditavel sem
depender de variavel em memoria:

`0133-rb-onda-38-2-16-fix1-bl4-autoopen-marker`

## Validacoes locais

- Readback 0132 valido contra schema HBN.
- Hearback 0132 valido contra schema HBN.
- `publicar_vba_import_v2.py apply/check` em 5 modulos, com G7/G8 OK.
- `git diff --check` limpo.
- `scripts/hbn-guards/hbn-guards-runner.sh` limpo.
- Nenhum `.frx`, `ThisWorkbook.code.txt`, `Mod_Types.bas`,
  `Importador_V3.bas`, `Preencher.bas`, `Menu_Principal.frm`, `Svc_*` ou
  `Repo_*` foi alterado por esta onda.

## Fila apos BL-4

O feedback humano sobre formularios fica registrado para a proxima onda de
produto. Candidato recomendado: avaliacao/encerramento de OS, incluindo o caso
em que o formulario de avaliacao nao registra ou nao exibe o nome do demandante.

Em handoff ou auditoria cruzada, fica tambem registrada a melhoria de protocolo
useHBN com o arquivo externo:

`/Users/macbookpro/Projetos/PROMPT_ARQUITETO_USEHBN_AUTONOMO.md`
