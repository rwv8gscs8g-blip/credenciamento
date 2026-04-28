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
- `APP_RELEASE_CANAL`
- `APP_RELEASE_ALVO`
- `APP_RELEASE_BUILD_KEY`
- `APP_BUILD_IMPORTADO`
- `APP_BUILD_BRANCH`
- `APP_BUILD_GERADO_EM`
- `APP_RELEASE_TAG`
- `APP_RELEASE_EVIDENCE_DIR`
- `APP_RELEASE_TEST_KEY`

Essas chaves formam o contrato mínimo da release publicada.

## Regra de versionamento seguro

O projeto distingue explicitamente:

- **release oficial**: última linha pública validada e publicada
- **canal ativo**: estágio operacional da cópia em uso (`DESENVOLVIMENTO`, `CANDIDATA`, `OFICIAL`)
- **próxima release alvo**: versão em preparação
- **build importado**: commit exato do pacote levado ao Excel
- **origem do build**: branch de onde o pacote foi gerado
- **pacote gerado em**: data e hora do carimbo operacional do pacote
- **estado do build**: `homologado` quando gerado a partir de árvore rastreada limpa; `em homologação` quando gerado com alterações rastreadas ainda não commitadas
- **assinatura do build**: combinação curta que mantém legibilidade da linha em evolução

Exemplo de microevolução segura:

- `APP_RELEASE_ATUAL = V12.0.0202`
- `APP_RELEASE_STATUS = VALIDADO`
- `APP_RELEASE_CANAL = DESENVOLVIMENTO`
- `APP_RELEASE_ALVO = V12.0.0203`
- `APP_BUILD_IMPORTADO = 733782c-homologado`
- `APP_BUILD_BRANCH = codex/v12-0-0203-governanca-testes`
- `APP_BUILD_GERADO_EM = 2026-04-21 06:03`

Nesse modelo, a cópia em uso continua ancorada na release pública oficial, mas a interface já informa claramente qual é a próxima versão em trabalho e qual commit exato foi importado no Excel.

## Regra do pacote local

O pacote operacional em `local-ai/vba_import/` deve ser gerado a partir de `src/vba/` e carimbar automaticamente:

- commit curto atual
- branch atual
- data e hora da geração do pacote

O operador deve sempre reimportar `App_Release.bas` junto com qualquer microevolução importável.
Na pasta publicada, o arquivo obrigatório é `local-ai/vba_import/001-modulo/AAX-App_Release.bas`.
Sem essa importação, o código pode estar atualizado, mas o Excel continuará exibindo o build anterior no Sobre, na validação consolidada e nas evidências.

Regra para IAs: toda orientação de importação deve listar `AAX-App_Release.bas` antes dos módulos funcionais alterados. Uma proposta de importação sem `AAX-App_Release.bas` é incompleta, mesmo quando a alteração é pequena.

Regra pública de nomenclatura: documentação, tela `Sobre`, evidências e mensagens para operador devem usar os rótulos **em homologação** e **homologado**. Termos técnicos de controle interno do Git não devem aparecer na comunicação pública do projeto.

## Regra de acompanhamento por build

Durante uma linha de desenvolvimento ainda não promovida, o projeto deve
registrar duas informações diferentes:

- **versão oficial**: permanece estável até a publicação formal;
- **build importado**: commit curto exato do pacote em execução no workbook.

Na linha `V12.0.0203`, o build importado passou a ser o indicador
operacional mais preciso para responder "qual código está no ar". O
histórico de microevoluções deve ser acompanhado por esse commit, não
por uma promoção prematura da versão oficial.

O checkpoint público de cada sequência relevante deve registrar:

1. build importado;
2. branch;
3. data de geração do pacote;
4. testes humanos executados;
5. resultado objetivo de cada suíte;
6. classificação do que ficou feito, pendente e adiado.

O documento vigente dessa linha é
[auditoria/22_STATUS_MICROEVOLUCOES_V12_0203.md](../auditoria/22_STATUS_MICROEVOLUCOES_V12_0203.md).

O bump da versão oficial só deve acontecer no fechamento do ciclo, quando:

1. a evolução compilar
2. smoke passar
3. stress passar
4. assistido passar
5. evidências forem publicadas
6. changelog, release note, status oficial e tag forem atualizados

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
