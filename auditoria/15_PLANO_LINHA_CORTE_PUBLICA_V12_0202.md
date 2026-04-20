# 15. Plano de Linha de Corte Publica — V12.0.0202

Objetivo: preparar a publicacao do `main` oficial a partir da `V12.0.0202`, mantendo no GitHub apenas o que e util para leitura, auditoria, testes e evolucao tecnica do sistema.

## 1. O que deve permanecer no repositório publico

- codigo VBA vivo e funcional
- testes oficiais e V2
- auditorias tecnicas
- notas de release e status oficial das versoes
- dados estruturais de referencia
- documentacao objetiva de arquitetura, regras de negocio, testes e publicacao

## 2. O que deve sair da superficie publica

- materiais operacionais internos
- documentos de transicao de trabalho
- instrucoes privadas de operacao
- instrucoes de upload/importacao pessoais
- artefatos locais de automacao
- backups e espelhos locais
- documentos voltados a workflows internos, e nao ao sistema em si

## 3. Itens candidatos a permanecer apenas localmente

- materiais operacionais internos
- documentos de transicao de trabalho
- espelhos locais de sincronizacao/importacao
- scripts internos de automacao
- material de onboarding interno
- incoming de formularios e pacotes auxiliares
- backups e espelhos locais

## 4. Itens candidatos a permanecer publicos

- `auditoria/`
- `doc/`
- `README.md`
- `obsidian-vault/releases/`
- `obsidian-vault/00-DASHBOARD.md`
- `obsidian-vault/MANIFEST.md`
- documentacao de arquitetura e regras de negocio que nao dependa de workflow privado

## 5. Regra para o novo `main`

O novo `main` deve começar na versao:

- **V12.0.0202**

Condicoes para o corte:

1. compilacao limpa
2. bateria oficial validada
3. senha sem exposicao literal no repositorio
4. status canonico das versoes consolidado
5. leitura publica sem dependencia de workflow privado de sincronizacao como explicacao central

## 6. Passos recomendados da publicacao

1. congelar a `V12.0.0202` como base oficial
2. remover da arvore publicada tudo o que for workflow interno
3. manter historico tecnico apenas onde ele agrega auditoria e rastreabilidade
4. reexecutar V2 (`smoke`, `stress`, `assistido`) na arvore ja limpa
5. pedir nova auditoria externa independente

## 7. Criterio de aceitacao

O repositório publico deve poder ser lido por um programador externo sem precisar entender:

- seu fluxo pessoal de importacao VBA
- sua rotina operacional interna
- seus procedimentos privados de trabalho
- sua estrategia de upload ou compilacao local

Ele deve enxergar apenas:

- codigo
- testes
- auditoria
- releases
- evolucao tecnica
