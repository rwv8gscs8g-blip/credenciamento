---
titulo: Mapa de Testes de Entidades V206
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-30
---

# Mapa de Testes de Entidades V206

## Objetivo

Converter a validacao manual feita por Mauricio em uma matriz auditavel para a area de Entidades. Este mapa orienta os testes manuais da Onda 38.2.4 e serve como base para automatizacao futura por modulo.

## Escopo V206

Obrigatorio para fechar a Onda 38.2.4:

- ciclo cadastrar, alterar, inativar e reativar entidades;
- exclusividade entre `ENTIDADE` e `ENTIDADE_INATIVOS`;
- comportamento da primeira, intermediaria e ultima linha;
- protecao contra edicao direta em abas criticas;
- reteste da protecao apos RVS.

Fora deste readback, mas documentado para onda futura:

- completar campos exibidos na tela principal;
- melhorar scroll/foco da lista;
- redesenhar arquitetura para cadastro canonico com status em V207.

## Matriz

| ID | Cenario | Tipo | Resultado Esperado | Status |
|---|---|---|---|---|
| ENT_MAN_01 | Abrir `CADASTRA ENTIDADE` com base populada | Manual | Lista carrega sem colapso visual | Obrigatorio |
| ENT_MAN_02 | Selecionar entidade existente | Manual | Campos principais correspondem a linha selecionada | Obrigatorio |
| ENT_MAN_03 | Cadastrar entidade com todos os campos preenchidos | Manual | Registro aparece na lista ativa e persiste | Obrigatorio |
| ENT_MAN_04 | Fechar e reabrir a tela apos cadastro | Manual | Entidade permanece listada | Obrigatorio |
| ENT_MAN_05 | Abrir modal de edicao da nova entidade | Manual | Modal exibe todos os campos gravados | Obrigatorio |
| ENT_MAN_06 | Comparar modal de edicao com tela principal | Manual | Divergencias ficam documentadas; nao bloquear D3/D4 se persistencia estiver correta | Forte futuro |
| ENT_MAN_07 | Alterar nome, telefone, e-mail e informacoes adicionais | Manual | Alteracoes persistem no modal e na planilha | Obrigatorio |
| ENT_MAN_08 | Inativar entidade intermediaria | Manual | Sai de `ENTIDADE` e aparece uma vez em `ENTIDADE_INATIVOS` | Obrigatorio |
| ENT_MAN_09 | Reativar entidade intermediaria | Manual | Sai das inativas e volta ativa sem duplicidade | Obrigatorio |
| ENT_MAN_10 | Inativar primeira entidade ativa visivel | Manual | Operacao conclui sem erro de cabecalho/tabela | Obrigatorio |
| ENT_MAN_11 | Reativar primeira entidade | Manual | Entidade volta ativa com dados preservados | Obrigatorio |
| ENT_MAN_12 | Inativar ultima entidade ativa | Manual | Operacao conclui sem erro de linha unica de tabela | Obrigatorio |
| ENT_MAN_13 | Reativar ultima entidade ativa/inativa | Manual | Entidade volta sem duplicidade | Obrigatorio |
| ENT_MAN_14 | Inativar todas as entidades em base descartavel | Manual | Lista ativa pode ficar vazia sem corromper tabela | Obrigatorio |
| ENT_MAN_15 | Reativar todas as entidades | Manual | Nenhuma entidade fica ativa e inativa simultaneamente | Obrigatorio |
| ENT_MAN_16 | Verificar ordenacao da lista ativa | Manual | Lista permanece navegavel e sem perda de linhas | Obrigatorio |
| ENT_MAN_17 | Verificar ordenacao da lista inativa | Manual | Lista de reativacao aparece coerente | Obrigatorio |
| ENT_MAN_18 | Verificar scroll/foco com mais itens que a area visivel | Manual | Todos os itens continuam acessiveis | Forte futuro |
| ENT_MAN_19 | Tentar editar diretamente `ENTIDADE` | Manual | Excel bloqueia edicao sem desbloqueio | Bloqueador |
| ENT_MAN_20 | Tentar editar diretamente `ENTIDADE_INATIVOS` | Manual | Excel bloqueia edicao sem desbloqueio | Bloqueador |
| ENT_MAN_21 | Tentar editar diretamente `PRE_OS` ou `CAD_OS` | Manual | Excel bloqueia edicao sem desbloqueio | Bloqueador |
| ENT_MAN_22 | Tentar colar imagem/objeto em aba critica | Manual | Excel bloqueia colagem/edicao de objeto | Bloqueador |
| ENT_MAN_23 | Rodar RVS e repetir ENT_MAN_19..22 | Manual + RVS | RVS nao deixa abas criticas editaveis | Bloqueador |
| ENT_MAN_24 | Confirmar que a base de teste pode ser descartada | Operacional | Sem decisao de migracao legada nesta onda | Informativo |
| ENT_MAN_25 | Verificar objetos residuais e bloqueio de objetos em abas criticas | Manual + estrutural Fix5 | Nenhum objeto/imagem nao autorizado permanece em aba critica; colar/mover/excluir objeto e bloqueado | Bloqueador |

## Conversao Para Automatizacao

Prioridade para V206:

- `ENT_MAN_19` a `ENT_MAN_23`: automatizar como assert estrutural e, quando possivel, teste assistido com evidencia manual.
- `ENT_MAN_25`: Fix5 automatiza limpeza/verificacao de `Shapes` e `ProtectDrawingObjects`; a tentativa manual de colar, mover ou excluir objeto continua obrigatoria no gate.
- `ENT_MAN_08` a `ENT_MAN_15`: ampliar `TV2_RunIntegridadeEstado` para cobrir ciclo completo com primeira/intermediaria/ultima linha.
- `ENT_MAN_03` a `ENT_MAN_07`: criar suite de CRUD de Entidades quando houver harness seguro de UI ou camada de servico isolavel.

Prioridade para V207:

- trocar movimentacao fisica entre abas por cadastro canonico com status;
- manter a interface Excel como fachada operacional;
- transformar este mapa em bateria por modulo com fixture isolada, snapshots pre/pos e validacao de invariantes.
