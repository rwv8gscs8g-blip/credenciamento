---
titulo: Onda 38.2.30 — Configuracoes Iniciais matriz de cenarios e Novo Periodo CSV
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-07
---

# 0160 — Configuracoes Iniciais / Cenarios / Novo Periodo

## Objetivo

Transformar a validacao de Configuracoes Iniciais em um mapa de cenarios
auditavel, cobrindo persistencia de campos, consumo por regra de negocio e
evidencia humana em CSV salva junto da copia da planilha.

## Classificacao HBN

A mudanca e de **regra, persistencia e teste dirigido**, nao de geometria de
UserForm.

- sem alteracao em `Configuracao_Inicial.frx`;
- sem designer/export nesta onda;
- sem tocar `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`,
  `ThisWorkbook` ou `Menu_Principal.frm`;
- sem VCR neste microdelta;
- destrutivo autorizado apenas para `TV2_RunConfigCenariosNovoPeriodo`.

### Fix1 0161

O gate humano da 0160 importou com `M=3 | F=1 | err=0 | skip=0` e compilou,
mas `TV2_20260607_110826` retornou `OK=6 | FALHA=1 | MANUAL=0`. A unica falha
foi `CFGCSV_06_NOVO_PERIODO_COPIA_LIMPEZA`.

O CSV de falhas mostrou que o Novo Periodo executou e a copia existia:

```text
OK_NOVO_PERIODO=Verdadeiro
COPIA_EXISTE=Verdadeiro
PRE_OS_DEPOIS=1
CAD_OS_DEPOIS=1
```

A causa foi limpeza/medicao parcial: a 0160 limpava `PRE_OS` ate `I` e
`CAD_OS` ate `Y`, enquanto os schemas atuais vao ate `N` e `AD`; alem disso, a
contagem pos-limpeza usava ultima linha preenchida, nao registro operacional
por coluna-chave.

O fix1 0161 corrige:

- helper test-only e botao real de Novo Periodo limpam `PRE_OS` ate
  `COL_PREOS_OS_ID`;
- helper test-only e botao real de Novo Periodo limpam `CAD_OS` ate
  `COL_OS_JUSTIF_DIV`;
- contagem pos-limpeza passa a contar registros por coluna-chave;
- build passa para `293e44c+ONDA38.2.30-FIX1-CONFIG-CENARIOS-CSV`.

## Causa

As validacoes anteriores estavam corretas para tela, botoes e fechamento, mas
ainda havia uma lacuna de cobertura: o teste existente provava parte da
persistencia numerica, mas nao demonstrava de forma unificada que todos os
campos da tela eram salvos, consumidos pelos servicos e evidenciados para
leitura humana.

Tambem ainda nao havia evidencia automatica do fluxo de Novo Periodo. Como o
gerador de PDF ainda nao existe, Mauricio autorizou CSV como evidencia
provisoria.

## Acao

Foi criada a suite `TV2_RunConfigCenariosNovoPeriodo` em
`Teste_V2_Roteiros.bas`. Ela registra aviso destrutivo, prepara baseline V2,
executa uma matriz pequena de cenarios e cria uma pasta de Novo Periodo.

Fluxo da suite:

1. Avisar que a suite e destrutiva e deve rodar apenas em homologacao, com
   registro V2/CSV e `MsgBox` quando nao estiver em modo silencioso.
2. Validar existencia dos controles do `Configuracao_Inicial`.
3. Persistir gestor, municipio e todos os numericos com valores `1`.
4. Reabrir/ler a configuracao e validar round-trip por CONFIG e getters.
5. Persistir os mesmos campos com valores `2`.
6. Validar consumo por recusa/prazo com suspensao de 1 dia.
7. Validar consumo por nota/strike com duas notas 1, corte 2 e suspensao de 2
   dias.
8. Criar `V12-0-0206-Onda-38-2-30`.
9. Salvar copia da planilha antes da limpeza.
10. Limpar `PRE_OS` e `CAD_OS` para iniciar Novo Periodo deterministico.
11. Salvar `TesteV2_CONFIG_CENARIOS_<execucao>.csv` na mesma pasta.

## Implementacao

`Configuracao_Inicial.frm` ganhou helper publico test-only:

- `CI_TestarPersistenciaPainel` agora aceita gestor, municipio e prazo
  parametrizados para cenarios;
- `CI_TestarNovoPeriodoDeterministico` cria pasta, salva copia do workbook,
  limpa `PRE_OS`/`CAD_OS` e retorna caminhos/detalhes para o teste;
- helpers privados normalizam nome de pasta, juntam paths e contam linhas de
  dados.

`Teste_V2_Roteiros.bas` ganhou:

- `TV2_RunConfigCenariosNovoPeriodo`;
- cenarios `CFGCSV_01` a `CFGCSV_07`;
- geracao de CSV com ordem, posicao de fila, campos, valores esperados,
  observados, resultado e paths;
- cenarios de consumo por recusa e strike usando fixtures V2 controladas.

`Teste_V2_Engine.bas` ganhou catalogo e roteiro para os 7 asserts
`CFGCSV_*`, marcados como `AUTOMATIZADO_DESTRUTIVO`.

`App_Release.bas` passou a reportar o build:

```text
293e44c+ONDA38.2.30-CONFIG-CENARIOS-CSV
```

## Consequencias Operacionais

A macro nova destroi dados de teste para produzir um estado deterministico. Em
homologacao, isso e desejado: o operador consegue repetir o mesmo fluxo e
comparar o CSV com os resultados esperados. Em producao, a macro nao deve ser
executada.

O Novo Periodo da suite salva a copia da planilha antes da limpeza. Depois
disso, `PRE_OS` e `CAD_OS` ficam vazias para o periodo novo, e o CSV fica
disponivel para leitura humana na mesma pasta.

## Mapa de Cobertura

| Ponto pedido | Cenario | Evidencia |
|---|---|---|
| Municipio com build | `CFGCSV_02`, `CFGCSV_03` | CSV e round-trip |
| Area gestora com build | `CFGCSV_02`, `CFGCSV_03` | CSV e round-trip |
| Prazo de Pre-OS | `CFGCSV_02`, `CFGCSV_03` | CONFIG + getter |
| Numero de recusas/strikes por prazo | `CFGCSV_02`, `CFGCSV_03`, `CFGCSV_04` | CONFIG + regra de recusa |
| Dias de punicao por recusa/prazo | `CFGCSV_02`, `CFGCSV_03`, `CFGCSV_04` | suspensao de 1 dia |
| Nota minima | `CFGCSV_02`, `CFGCSV_03`, `CFGCSV_05` | regra de strike |
| Numero de strikes por nota | `CFGCSV_02`, `CFGCSV_03`, `CFGCSV_05` | duas notas baixas |
| Dias suspenso por strike | `CFGCSV_02`, `CFGCSV_03`, `CFGCSV_05` | suspensao de 2 dias |
| Novo Periodo | `CFGCSV_06` | pasta, copia, `PRE_OS=0`, `CAD_OS=0` |
| Evidencia humana CSV | `CFGCSV_07` | arquivo CSV na pasta |

## Arquivos Alterados

- `src/vba/Configuracao_Inicial.frm`
- `src/vba/Teste_V2_Roteiros.bas`
- `src/vba/Teste_V2_Engine.bas`
- `src/vba/App_Release.bas`
- `docs/tutorials/MANUAL_OPERACIONAL_TELA_A_TELA.md`
- `docs/reference/testes/GUIA_DE_TESTES_E_VALIDACAO.md`
- `CHANGELOG.md`
- `auditoria/INDEX.md`
- artefatos HBN e espelhos em `local-ai/vba_import/`

## Gate Esperado Fix1

1. Importar o delta V3 fix1 da 0161.
2. Compilar o VBAProject no VBE.
3. Rodar `TV2_RunConfigCenariosNovoPeriodo`.
4. Esperado: `OK=7 | FALHA=0 | MANUAL=0`.
5. Conferir a pasta `V12-0-0206-Onda-38-2-30` com copia da planilha e CSV.
6. Nao rodar VCR neste microdelta.

## Gate Observado Fix1

Mauricio reportou que a 0161 importou, compilou e `TV2_20260608_044610`
retornou `OK=7 | FALHA=0 | MANUAL=0`, sem CSV de falhas. Com isso, a
Onda 38.2.30 fica fechada pelo fix1.
