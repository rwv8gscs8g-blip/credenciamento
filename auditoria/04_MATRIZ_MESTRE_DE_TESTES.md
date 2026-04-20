# MATRIZ MESTRE DE TESTES — LINHA OFICIAL

Objetivo: definir a estrutura publica e vigente de testes da versao `V12.0.0202`.

## 1. Camadas de teste

### Bateria Oficial

Uso:
- prova de regressao principal
- validacao de regras de negocio centrais
- criterio minimo de liberacao de release

Estado atual:
- compilou
- rodada recente validada sem falhas

### Testes V2

Uso:
- baseline deterministica
- smoke rapido
- smoke assistido
- stress deterministico
- verificacao de guardas migradas para servico

Estado atual:
- baseline estabilizada
- precisa de rodada fresca antes da nova auditoria externa

### Testes assistidos

Uso:
- verificacao humana de fluxo visual e operacao guiada
- apoio de homologacao funcional

Estado atual:
- mantidos como camada complementar, nao como prova unica de regra

## 2. Politica de liberacao

Uma release candidata a status oficial deve atender:

1. compilacao limpa
2. bateria oficial sem falhas bloqueantes
3. evidencias recentes da V2
4. documentacao de release com status explicito
5. riscos remanescentes descritos

## 3. Objetivo de evolucao

O repositório publico deve caminhar para uma esteira em camadas:

1. contratos e invariantes
2. cenarios de negocio automatizados
3. comparacao entre suites
4. stress deterministico
5. smoke assistido para homologacao

## 4. Pendencias abertas para proxima auditoria

- rodada fresca de `smoke`, `stress` e `assistido`
- aumento da evidenciacao publica da V2
- comparador automatizado entre suites
- chaves de evolucao e rastreabilidade mais fortes por release

## 5. Conclusao

A estrategia de testes ja e suficiente para sustentar a linha oficial estabilizada, mas ainda nao representa o teto de maturidade desejado. A proxima auditoria deve olhar principalmente para:

- cobertura incremental
- confiabilidade da V2
- mecanismos de gate antes de release
- rastreabilidade de evolucao do sistema de testes
