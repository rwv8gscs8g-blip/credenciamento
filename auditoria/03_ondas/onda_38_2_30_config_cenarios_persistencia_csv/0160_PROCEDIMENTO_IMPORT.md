---
titulo: Procedimento de Import — 0160 Configuracoes Iniciais Cenarios CSV
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0205
data: 2026-06-07
---

# Procedimento de Import — 0160

## Escopo

Delta de codigo e teste para validar Configuracoes Iniciais com matriz de
cenarios, consumo por regras e Novo Periodo com copia da planilha e CSV de
evidencia.

Este procedimento ja incorpora o Fix1 0161. O primeiro pacote 0160 importou e
compilou, mas `TV2_RunConfigCenariosNovoPeriodo` retornou `OK=6 | FALHA=1 |
MANUAL=0` porque `CFGCSV_06` contou uma linha remanescente apos a limpeza.
O fix1 limpa `PRE_OS`/`CAD_OS` ate as colunas finais atuais e conta registros
reais pela coluna-chave.

Esta suite e destrutiva por autorizacao expressa do hearback 0160. Execute
apenas no workbook de homologacao.

## Comando

No VBE, executar:

```vb
ImportarPacoteV3_Delta "ONDA38_2_30_CONFIG_CENARIOS_CSV_FIX1", "293e44c+ONDA38.2.30-FIX1-CONFIG-CENARIOS-CSV"
```

## Resultado Esperado do Importador

```text
M=2 | F=1 | err=0 | skip=0
```

O `F=1` corresponde ao `Configuracao_Inicial.frm`. Este pacote nao importa
`.frx`.

## Pos-Import

1. VBE > Depurar > Compilar VBAProject.
2. Se o compile falhar, nao salvar o workbook e restaurar o backup V3.
3. Se o compile passar, executar na Janela Imediata:

```vb
TV2_RunConfigCenariosNovoPeriodo
```

Resultado esperado:

```text
OK=7 | FALHA=0 | MANUAL=0
```

## Evidencia Esperada

A suite deve criar ou reutilizar esta pasta no caminho do workbook:

```text
\\Mac\Home\Projetos\Credenciamento\V12-0-0206-Onda-38-2-30
```

Dentro dela devem existir:

1. uma copia da planilha salva antes da limpeza;
2. `TesteV2_CONFIG_CENARIOS_<execucao>.csv`.

O CSV deve permitir conferir:

- numero e ordem dos cenarios;
- posicao/resumo da fila quando aplicavel;
- gestor e municipio contendo o build da onda;
- valores esperados e observados para prazo, recusas, dias, nota e strikes;
- resultado do consumo por recusa e por strike;
- confirmacao de `PRE_OS=0` e `CAD_OS=0` depois do Novo Periodo;
- caminhos da pasta, copia da planilha e CSV.

## Nao Executar Neste Microdelta

- VCR.
- `Limpar Base` manual.
- `Sair`/fechamento do workbook como parte do teste.
- Central de Testes como fluxo real.
- importacao ou restauracao da 0155.

## Arquivos Importados

- `001-modulo/AAX-App_Release.bas`
- `001-modulo/ABG-Teste_V2_Roteiros.bas`
- `002-formularios/AAC-Configuracao_Inicial.frm`

## Se Falhar

- Falha no import: restaurar backup indicado pelo Importador V3.
- Falha no compile: nao salvar o workbook; restaurar backup V3.
- Falha em `TV2_RunConfigCenariosNovoPeriodo`: anexar CSV de falhas, anexar o
  CSV gerado se existir e nao rodar VCR.
- Pasta/copia/CSV ausente: abrir fix novo; nao repetir em producao.
