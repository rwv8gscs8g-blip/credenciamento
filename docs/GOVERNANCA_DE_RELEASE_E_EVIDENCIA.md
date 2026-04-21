# Governança de Release e Evidência

Este documento descreve o contrato público mínimo entre:

- a versão declarada no código
- o status oficial da release
- a nota de release
- a tag git
- o pacote público de evidências

O objetivo é reduzir divergência entre narrativa, código e prova objetiva da linha oficial.

## Fonte primária do código

O arquivo [src/vba/App_Release.bas](../src/vba/App_Release.bas) concentra:

- `APP_RELEASE_ATUAL`
- `APP_RELEASE_STATUS`
- `APP_RELEASE_TAG`
- `APP_RELEASE_EVIDENCE_DIR`
- `APP_RELEASE_TEST_KEY`

Essas chaves formam o contrato mínimo da release publicada.

## Fonte primária do status oficial

O arquivo [obsidian-vault/releases/STATUS-OFICIAL.md](../obsidian-vault/releases/STATUS-OFICIAL.md) é a fonte canônica para classificação pública da versão.

Ele precisa:

- listar a linha oficial vigente
- marcar a versão como `VALIDADA`, `SUPERADA`, `REVERTIDA` ou `HISTORICO_INTERNO`
- manter coerência com a versão exposta no código

## Fonte primária da descrição da release

A nota de release em [obsidian-vault/releases/V12.0.0202.md](../obsidian-vault/releases/V12.0.0202.md) deve:

- existir para a versão declarada em `App_Release`
- repetir a versão no cabeçalho
- declarar o status correspondente
- resumir objetivo, escopo e validação executada

## Fonte primária da trilha de mudanças

O [CHANGELOG.md](../CHANGELOG.md) deve conter uma entrada da versão oficial vigente.

Esse arquivo não substitui a release note detalhada, mas garante leitura rápida da evolução pública da linha oficial.

## Fonte primária da evidência

O diretório público de evidências da release deve existir e ser declarado em `APP_RELEASE_EVIDENCE_DIR`.

Para a linha atual, ele é:

- [auditoria/evidencias/V12.0.0202/](../auditoria/evidencias/V12.0.0202/)

Esse diretório deve conter, no mínimo:

- `MANIFEST.md`
- CSVs recentes da Bateria Oficial
- CSVs recentes de falhas da Bateria Oficial
- validação humana da V2

## Tag pública

A release oficial deve ter uma tag git correspondente.

Exemplo:

- versão no código: `V12.0.0202`
- tag pública: `v12.0.0202`

## Automação de governança

O workflow [verify-docs.yml](../.github/workflows/verify-docs.yml) executa a checagem automática dessa coerência.

Ele valida:

- presença dos arquivos públicos mínimos
- indexação da pasta `auditoria/`
- coerência entre `App_Release`, `STATUS-OFICIAL`, release note e `CHANGELOG`
- existência da tag correspondente
- existência do pacote de evidências declarado

## Critério mínimo de publicação

Uma linha pública só deve ser tratada como release oficial quando os itens abaixo estiverem coerentes:

1. `App_Release` atualizado
2. `STATUS-OFICIAL` atualizado
3. release note presente
4. changelog presente
5. tag git existente
6. evidência pública publicada

## Próximo degrau de maturidade

Os próximos passos desejáveis para esta esteira são:

- checagem automática de hash do pacote de evidências
- verificação automática de links públicos centrais
- ampliação do gate para releases futuras
- associação explícita entre release, suíte e chave pública de teste
