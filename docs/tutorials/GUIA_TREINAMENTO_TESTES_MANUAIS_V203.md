---
titulo: Guia de Treinamento de Testes Manuais V203
diataxis: tutorial
hbn-track: fast_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-04
---

# Guia de Treinamento de Testes Manuais V203

Este guia treina o operador humano a validar a `V12.0.0203-rc4` em
homologacao. A rc4 esta liberada para testes manuais formais, nao para
producao.

## 1. Objetivo do treinamento

Ao final, o operador deve conseguir:

1. confirmar que esta usando o workbook correto;
2. conferir o build importado;
3. rodar o Quinteto de validacao;
4. interpretar `APROVADO` e `REPROVADO`;
5. coletar evidencia CSV;
6. classificar falhas para a abertura da `V12.0.0204`.

## 2. Contexto da V203 rc4

| Campo | Valor |
|---|---|
| Release em teste | `V12.0.0203-rc4` |
| Build rc4 | `f7aa84f+v12.0.0203-rc4-r1-forms-reativ-fix1-classifica-u` |
| Gate final conhecido | `VR_20260504_171048` |
| Resultado esperado | `APROVADO` |
| Sintaxe esperada | `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0` |
| Uso autorizado | Testes manuais formais |
| Uso nao autorizado | Producao publica |

## 3. Preparacao

1. Abra somente a planilha de homologacao correta.
2. Desative salvamento automatico durante testes destrutivos.
3. Confirme que macros estao habilitadas.
4. Abra o VBA Editor.
5. No menu do VBE, use `Depurar > Compilar VBAProject`.
6. Se a compilacao falhar, nao salve o workbook.

## 4. Confirmar build importado

Na Janela Imediata, execute:

```vb
?GetBuildImportado
```

O retorno deve apontar para a linha `v12.0.0203-rc4` ou para o build
rc4 de correcao final. Divergencia de build deve ser tratada antes de
rodar testes.

## 5. Rodar o Quinteto

Na Janela Imediata, execute:

```vb
CT_ValidarRelease_Quinteto
```

O operador deve aguardar o ciclo inteiro. A validacao pode alternar abas,
limpar dados de teste e preencher relatorios.

## 6. Ler o resultado

O resultado geral aparece na aba `VALIDACAO_RELEASE`.

| Resultado | Acao |
|---|---|
| `APROVADO` | registrar `VALIDACAO_ID`, build, horario e CSV gerado |
| `REPROVADO` | abrir CSV de falhas, copiar primeira falha e nao promover release |
| erro de compilacao | fechar sem salvar e restaurar backup/import correto |
| erro de importacao | coletar log de `IMPORT_LOG_V3` e nao prosseguir para testes |

## 7. Evidencia obrigatoria

Para cada rodada formal, registre:

1. print da aba `VALIDACAO_RELEASE`;
2. `VALIDACAO_ID`;
3. build exibido;
4. sintaxe do resultado;
5. caminho do CSV gerado;
6. decisao humana: aprovado, reprovado ou repetir teste.

## 8. Como classificar falhas

| Tipo | Exemplo | Tratamento |
|---|---|---|
| Falha de teste novo | `CS_23` reprovado apos mudanca de regra | investigar antes de repetir gate |
| Falha de dado orfao | `INT-CAD-OS-REF-ORFA` | mover para debito V204 se nao bloquear rc4 |
| Falha de compilacao | membro nao encontrado | nao salvar workbook e corrigir pacote |
| Falha de importador | erro V3 em modulo/form | restaurar backup e corrigir manifesto |
| Falha manual | operador interrompeu teste | repetir sem promover conclusao |

## 9. Criterio para encerrar a V203

A V203 pode seguir para publicacao de vitrine no GitHub quando:

1. a rc4 compila limpa;
2. o Quinteto retorna `APROVADO`;
3. a evidencia final esta arquivada;
4. as auditorias cruzadas nao apontam P0/P1 bloqueante;
5. os debitos remanescentes estao formalizados para V204.

Mesmo com esses itens verdes, a V203 rc4 continua sendo uma release para
teste manual. A release publica de producao deve ser aberta e estabilizada
na linha V204.
