# MAPA DE TESTES V2 EXECUTAVEL

## Objetivo

Materializar a estrategia aprovada em uma bateria nova, isolada do legado, com:

- baseline deterministica
- resultado semantico legivel por humano
- smoke rapido
- smoke assistido
- stress deterministico
- backlog explicito das guardas ainda presas na interface

## Modulos implementados

- `vba_export/Central_Testes_V2.bas`
- `vba_export/Teste_V2_Engine.bas`
- `vba_export/Teste_V2_Roteiros.bas`

## Macros de entrada

- `CT2_AbrirCentral`
- `CT2_ExecutarSmokeRapido`
- `CT2_ExecutarSmokeAssistido`
- `CT2_ExecutarStress`
- `CT2_ExecutarStressAssistido`

## Planilhas geradas pela V2

- `RESULTADO_QA_V2`
- `CATALOGO_CENARIOS_V2`
- `HISTORICO_QA_V2`

## Suites entregues agora

### Smoke

- `SMK_001` baseline e fila inicial canonica
- `SMK_002` selecao da empresa do topo
- `SMK_003` emissao basica de PRE_OS
- `SMK_004` filtro E sem mover fila
- `SMK_005` recusa com avanco e punicao
- `SMK_006` conversao PRE_OS -> OS
- `SMK_007` avaliacao e conclusao de OS

### Stress

- `STR_001` repeticao controlada com alternancia entre recusa e fechamento de OS

### Backlog explicito de migracao UI -> servico

- `MIG_001` entidade inexistente em `Svc_PreOS`
- `MIG_002` data prevista invalida em `Svc_OS`
- `MIG_003` divergencia sem justificativa em `Svc_Avaliacao`

## Resultado esperado desta fase

- operar a V2 em paralelo ao legado
- validar a importacao no Excel
- usar `CATALOGO_CENARIOS_V2` como artefato semantico para homologacao humana
- expandir a V2 antes de substituir a bateria atual

## Regra de adocao

Nao aposentar `Central_Testes.bas` e `Teste_Bateria_Oficial.bas` nesta etapa.

A bateria V2 entra primeiro em `shadow mode`, e so vira padrao depois de:

1. validacao manual no Excel
2. confirmacao das suites smoke
3. ampliacao da cobertura combinatoria
4. migracao das guardas de UI prioritarias
