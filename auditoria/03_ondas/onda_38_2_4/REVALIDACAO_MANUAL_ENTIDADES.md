---
titulo: Revalidacao Manual de Entidades — Onda 38.2.4
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-05-30
---

# Revalidacao Manual de Entidades — Onda 38.2.4

## Objetivo

Validar somente o escopo da Onda 38.2.4 na area de Entidades: listagem, ordenacao, alteracao, inativacao, reativacao e protecao de abas.

Este roteiro nao substitui o teste completo tela-a-tela do sistema. O teste completo fica para gate posterior, depois que as ondas de bloqueadores L43 estiverem resolvidas.

## Pre-condicoes

- Workbook importado no build `fd45a5d+ONDA38.2.4-ESTADO-FIX5-OBJETOS-ABAS`.
- VBE > Depurar > Compilar VBAProject aprovado.
- `TV2_RunIntegridadeEstado` aprovado com `OK=8 | FALHA=0 | MANUAL=0`.
- Base de teste pode ser descartada; criar entidades temporarias e permitido.

## Criterio de Parada

Pare o roteiro e traga evidencia para Codex se ocorrer qualquer um destes pontos:

- mensagem de erro ao cadastrar, alterar, inativar ou reativar;
- entidade aparece simultaneamente em ativa e inativa;
- lista principal colapsa ou perde linhas apos cadastro/inativacao/reativacao;
- campos completos aparecem no modal de edicao, mas ficam incoerentes na tela principal;
- aba critica aceita edicao manual direta sem desbloqueio intencional.
- aba critica aceita colagem, movimentacao, redimensionamento ou exclusao de objeto sem desbloqueio intencional.

## Roteiro

### 1. Abertura e Lista Inicial

1. Abrir o menu `CADASTRA ENTIDADE`.
2. Conferir se a lista inicial carrega sem ficar em branco.
3. Conferir se ao menos estas colunas aparecem coerentes na lista: CNPJ, Nome da Entidade, Contato, Celular.
4. Selecionar uma entidade existente.
5. Confirmar que os campos detalhados abaixo da lista correspondem a entidade selecionada.

Resultado esperado: lista visivel, sem colapso, e detalhes coerentes com a linha selecionada.

### 2. Cadastro Novo

1. Cadastrar uma entidade temporaria com nome rastreavel, por exemplo `TESTE ENTIDADE 38 2 4 A`.
2. Usar CNPJ unico de teste.
3. Preencher telefone, celular, e-mail, endereco, municipio, UF, contato principal e informacoes adicionais.
4. Confirmar o cadastro.
5. Verificar se a entidade aparece na lista principal.
6. Fechar e reabrir a area `CADASTRA ENTIDADE`.
7. Confirmar que a entidade continua aparecendo.

Resultado esperado: cadastro persiste, lista continua estavel e ordenada.

### 3. Ordenacao em Base Populada

1. Cadastrar mais duas entidades temporarias com nomes que forcem ordenacao, por exemplo:
   - `AAA TESTE ENTIDADE 38 2 4`
   - `ZZZ TESTE ENTIDADE 38 2 4`
2. Fechar e reabrir `CADASTRA ENTIDADE`.
3. Verificar se a lista permanece visivel e se os nomes aparecem em ordem coerente.
4. Selecionar cada uma das entidades temporarias.
5. Conferir se os detalhes exibidos pertencem a linha selecionada.

Resultado esperado: ordenacao nao embaralha dados da linha e nao esconde linhas.

### 4. Alteracao de Entidade

1. Abrir uma entidade temporaria pelo fluxo de alteracao.
2. Alterar ao menos:
   - Nome da Entidade;
   - Telefone/Celular;
   - E-mail;
   - Informacoes adicionais.
3. Confirmar a alteracao.
4. Reabrir a entidade.
5. Conferir se os valores alterados persistiram.

Resultado esperado: alteracao persiste e a lista principal reflete os campos principais esperados.

### 5. Inativacao do Primeiro Item Ativo

1. Identificar o primeiro item ativo visivel na lista de entidades.
2. Abrir o modal de alteracao desse primeiro item.
3. Acionar `Inativa Entidade`.
4. Confirmar a operacao.
5. Verificar que nao aparece mensagem de erro.
6. Verificar que o item saiu da lista ativa.
7. Abrir `Reativa Entidade`.
8. Verificar que o mesmo item aparece na lista de inativas.

Resultado esperado: o primeiro item ativo inativa sem erro e passa para a lista de inativas.

### 6. Reativacao do Mesmo Item

1. Na lista de `Reativa Entidade`, selecionar o item inativado no passo anterior.
2. Reativar.
3. Confirmar que ele some da lista de inativas.
4. Voltar para `CADASTRA ENTIDADE`.
5. Confirmar que ele voltou para a lista ativa.
6. Abrir o item reativado e conferir campos principais.

Resultado esperado: a reativacao nao duplica a entidade e preserva os dados.

### 7. Inativacao de Item Intermediario ou Final

1. Escolher um item que nao seja o primeiro da lista ativa.
2. Repetir o fluxo de inativacao.
3. Confirmar que nao ha erro.
4. Confirmar que ele aparece em `Reativa Entidade`.
5. Reativar o item.
6. Confirmar que ele volta para a lista ativa.

Resultado esperado: fluxo rapido e estavel tambem para itens intermediarios/finais.

### 8. Exclusividade Ativa/Inativa

1. Escolher uma entidade usada no teste.
2. Conferir visualmente em `CADASTRA ENTIDADE` se ela esta ativa.
3. Abrir `Reativa Entidade` e confirmar que ela nao aparece como inativa.
4. Inativar essa entidade.
5. Confirmar que ela sai da lista ativa.
6. Abrir `Reativa Entidade` e confirmar que aparece uma unica vez.
7. Reativar e confirmar o inverso.

Resultado esperado: a mesma entidade nunca fica simultaneamente ativa e inativa.

### 9. Inativacao da Ultima Entidade Ativa

1. Use somente base de teste descartavel.
2. Inative entidades ate restar uma unica entidade ativa na lista principal.
3. Abra essa ultima entidade ativa pelo modal de alteracao.
4. Acione `Inativa Entidade`.
5. Confirmar que nao aparece erro de cabecalho/insercao de tabela.
6. Confirmar que a lista ativa fica vazia ou sem entidade selecionavel remanescente.
7. Abrir `Reativa Entidade`.
8. Confirmar que a entidade inativada aparece uma unica vez.
9. Reativar a entidade.
10. Confirmar que ela volta para a lista ativa.

Resultado esperado: a ultima linha de dados de `ENTIDADE` pode ser inativada sem erro estrutural da tabela Excel.

### 10. Persistencia Apos Fechar/Reabrir Telas

1. Fechar o menu principal.
2. Abrir novamente `CADASTRA ENTIDADE`.
3. Conferir se a lista e os detalhes continuam coerentes.
4. Abrir `Reativa Entidade`.
5. Conferir se a lista de inativas permanece coerente.

Resultado esperado: estado visual permanece coerente apos reabertura.

### 11. Protecao de Abas Criticas

1. Confirmar visualmente que nao existe imagem/objeto residual em `ENTIDADE_INATIVOS`.
2. Sem usar desbloqueio manual, tentar editar uma celula de dados em `ENTIDADE`.
3. Tentar editar uma celula de dados em `ENTIDADE_INATIVOS`.
4. Repetir em uma aba critica adicional, por exemplo `PRE_OS` ou `CAD_OS`.
5. Tentar colar ou inserir uma imagem/objeto em `ENTIDADE_INATIVOS`.
6. Tentar mover, redimensionar ou excluir objeto em uma aba critica, se houver objeto disponivel no momento do teste.
7. Nao forcar desbloqueio.

Resultado esperado: Excel bloqueia edicao direta e colagem/edicao de objetos pelo operador.

### 12. Protecao Apos RVS

1. Rodar o RVS completo.
2. Repetir imediatamente o passo 11.

Resultado esperado: o RVS nao deixa o workbook editavel diretamente.

## Resultado a Reportar

Ao final, reportar:

- passou ou falhou;
- se falhou, em qual passo;
- print da mensagem ou tela incoerente;
- entidade usada no teste;
- se a falha deixou duplicidade ativa/inativa.
