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

## Como obter ferramentas avançadas (CLA-controlado)

O projeto adota o modelo **público-auditável + ferramentas
CLA-controladas** (decidido na Onda 9 antecipada da V12.0.0203).

**Tudo que é público** (auditoria, documentação, código VBA do produto,
governança, evidências de teste, vitrine) está disponível neste
repositório sem necessidade de CLA. Você pode auditar, ler, e propor
PRs documentais sem nenhum acesso adicional.

**Ferramentas avançadas** — incluindo o pacote de import oficial
(`local-ai/vba_import/`), scripts Bash/Python de sincronização e
auditoria, Importador V2 (módulo VBA) e instalador do git pre-commit
hook — são distribuídas via **release zip cifrado** após aceite
rastreável do CLA e validação do enquadramento do solicitante.

Procedimento detalhado em
[`docs/how-to/COMO_OBTER_FERRAMENTAS_VBA.md`](docs/how-to/COMO_OBTER_FERRAMENTAS_VBA.md).

Por que esse modelo existe e como ele convive com a TPGL v1.1:
[`docs/explanation/MODELO_DE_ACESSO_CONTROLADO.md`](docs/explanation/MODELO_DE_ACESSO_CONTROLADO.md).

Matriz definitiva do que é público vs CLA-controlado:
[`docs/reference/MATRIZ_PUBLICO_VS_CLA.md`](docs/reference/MATRIZ_PUBLICO_VS_CLA.md).

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
