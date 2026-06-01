---
titulo: Observacoes Manuais de Entidades — Onda 38.2.4
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-30
---

# Observacoes Manuais de Entidades — Onda 38.2.4

## Escopo

Este documento registra achados da validacao manual de Entidades. Itens fora do readback `0120` ficam documentados para onda futura e nao devem ser corrigidos nesta micro-onda sem novo hearback.

## Achados

### ENT-UI-01 — Detalhes incompletos na tela principal

Ao selecionar entidades cadastradas, os dados completos aparecem no modal de edicao, mas nem todos sao reproduzidos nos campos de detalhe da tela principal.

Classificacao atual: FORTE para onda futura de leitura/exibicao.

Escopo provavel: `Menu_Principal.frm` ou mapeamento de campos da tela principal. Esse arquivo esta fora do readback `0120`.

Evidencia pos-Fix3: entidade `Entidade 7 - Fix 3 Last Row` exibiu todos os campos no modal de edicao, mas a tela principal continuou omitindo parte dos campos de detalhe.

### ENT-UI-02 — Limpeza dos campos apos cadastro novo

A criacao de uma nova entidade limpa os campos do formulario. Pode ser comportamento intencional de "pronto para novo cadastro", mas precisa decisao de UX porque tambem dificulta a verificacao imediata dos dados recem-gravados.

Classificacao atual: MARGINAL/FORTE, pendente de decisao operacional.

Escopo provavel: fluxo de cadastro em `Menu_Principal.frm` ou rotina de limpeza do formulario. Fora do readback `0120`.

### ENT-ORDER-01 — Ordenacao das inativas

A lista de entidades inativas apareceu na ordem esperada nas imagens reportadas por Mauricio. Sem acao de codigo neste momento.

### ENT-TABLE-01 — Erro ao inativar ultima entidade ativa

Erro observado:

> As linhas de Cabecalho e de Insercao de uma tabela que nao contenha dados nao podem ser excluidas.

Diagnostico: tentativa de deletar a unica linha de dados de uma tabela Excel (`ListObject`). Corrigido no Fix3 por `Util_ExcluirLinhaSegura`: quando resta uma unica `ListRow`, o helper limpa o conteudo da linha e preserva a estrutura da tabela.

Status: corrigido em codigo; pendente de import, compile, `TV2_RunIntegridadeEstado` e reteste manual.

Evidencia pos-Fix3: import `ONDA38_2_4_ESTADO_FIX3_LAST_ROW_TABLE`, compile, `TV2_RunIntegridadeEstado OK=5` e reteste manual de inativacao da ultima entidade ativa foram reportados como aprovados.

### ENT-UI-03 — Item ativo fora da area visivel apos reativacao

Depois de reativar todas as entidades, a `Local 3 E2E`/entidade 3 nao ficou imediatamente visivel na lista principal. Pelas imagens ha barra de rolagem na lista, entao o achado e tratado como problema de visualizacao/scroll ou foco, nao como falha de persistencia.

Classificacao atual: FORTE para onda futura de leitura/exibicao se o item existir na planilha mas nao ficar acessivel/selecionavel de forma clara.

Escopo provavel: `Menu_Principal.frm` ou configuracao visual da lista. Fora do readback `0120`.

### ENT-SEC-01 — Abas criticas editaveis diretamente

Apos RVS completo aprovado no Fix3, foi possivel editar diretamente celulas nas abas `ENTIDADE`, `ENTIDADE_INATIVOS` e `PRE_OS`, sem desbloqueio intencional.

Classificacao atual: BLOQUEADOR da Onda 38.2.4.

Status: Fix4 preparado em `Util_Planilha.bas` para bloquear todas as celulas das abas criticas, proteger objetos e validar `ProtectContents + Locked`.

Evidencia pos-Fix4: Mauricio confirmou bloqueio de escrita direta em `ENTIDADE`, `ENTIDADE_INATIVOS`, `PRE_OS`, `CAD_OS` e `EMPRESAS`.

Status: corrigido para escrita direta; pendente reteste/registro de tentativa de colar, mover ou excluir objeto em aba protegida.

### ENT-SEC-02 — Objeto/imagem em aba critica

Foi observada imagem/objeto colado em `ENTIDADE_INATIVOS`, evidenciando que a protecao de objetos tambem nao estava ativa.

Classificacao atual: FORTE/BLOQUEADOR associado a `ENT-SEC-01`, porque o mesmo mecanismo de protecao precisa impedir edicao de objetos em abas criticas.

Status: Fix4 usa `DrawingObjects:=True` na protecao. A imagem existente permaneceu como residuo historico da fase desprotegida; o Fix5 foi autorizado para limpeza supervisionada e teste estrutural de objetos em abas criticas.

Evidencia pos-Fix4: objeto/imagem residual ainda existe em `ENTIDADE_INATIVOS`.

Interpretacao: se novas alteracoes de celulas e objetos estiverem bloqueadas, o achado passa de falha de protecao para higiene do workbook. Ainda assim, deve ser removido por microdelta auditavel antes de liberar a Onda 38.2.4 para auditoria final.

Fix5 preparado: `Util_LimparObjetosAbasCriticas` remove `Shapes` existentes; `Util_VerificarObjetosAbasCriticas` valida `Shapes.Count = 0` e `ProtectDrawingObjects=True`; `TV2_RunIntegridadeEstado` passa a exigir `OK=8 | FALHA=0 | MANUAL=0`. O reteste manual deve confirmar que nao e possivel colar, mover, redimensionar ou excluir objetos em abas criticas sem desbloqueio.
