# Como Contribuir

Obrigado por considerar contribuições para este repositório.

## Natureza do projeto

Este repositório é público, auditável e **source-available** sob
[TPGL v1.1](LICENSE). Ele não é
publicado como software livre/open source sob a definição da OSI.

## Regra obrigatória de contribuição

Toda contribuição pública exige aceite do
[CLA.md](CLA.md).

Sem CLA rastreável, a contribuição pode ser recusada.

Materiais operacionais complementares, incluindo guia detalhado de importação
do código-fonte e vídeo tutorial de incorporação ao workbook, são fornecidos
em canal controlado somente após aceite rastreável do CLA.

## Fluxo recomendado

1. abra uma issue, se a mudança alterar comportamento, documentação estrutural
   ou política pública
2. crie uma branch curta e objetiva
3. faça mudanças pequenas, coerentes e auditáveis
4. atualize documentação e evidências quando necessário
5. abra um pull request com checklist completo

## Convenções de branch

- `feat/`
- `fix/`
- `docs/`
- `test/`
- `refactor/`
- `chore/`

## Convenções de commit

Preferência por Conventional Commits:

- `feat:`
- `fix:`
- `docs:`
- `test:`
- `refactor:`
- `chore:`

## Expectativa de qualidade

Mudanças que alterem regra de negócio, testes ou governança devem preservar:

- compilação limpa do projeto VBA
- bateria oficial sem falhas bloqueantes
- coerência com a matriz de testes pública
- atualização do `CHANGELOG.md` quando houver mudança relevante

## Pull requests

Inclua no PR, quando aplicável:

- objetivo da mudança
- escopo
- evidência de compilação
- evidência da bateria oficial
- impactos em documentação/auditoria
- indicação de breaking change, se houver

## O que não publicar

Não envie:

- dados reais de municípios ou usuários
- segredos, senhas, chaves ou artefatos locais
- fluxos operacionais locais ou automações não publicadas
- arquivos temporários de Excel, backup local ou lixo de sistema
