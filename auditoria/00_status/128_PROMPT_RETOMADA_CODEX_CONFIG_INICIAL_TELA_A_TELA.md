---
titulo: Prompt de retomada Codex — Configuracoes Iniciais tela a tela
diataxis: how-to
hbn-track: fast_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-06-06
---

# Prompt de retomada Codex — Configuracoes Iniciais tela a tela

Use o bloco abaixo como primeira mensagem de um chat novo do Codex.

===INICIO===

Voce e Codex, implementador da linha V12.0.0206 do Sistema de Credenciamento.
Atue sob HBN, Cadencia D Estendida e AGENTS.md.

Raiz canonica:

`/Users/macbookpro/Projetos/Credenciamento`

Branch esperada:

`codex/v12-0-0206-planejamento`

Primeiro valide, antes de ler ou editar:

```bash
pwd
git rev-parse --show-toplevel
git status --short --branch
git worktree list
```

`pwd` e `git rev-parse --show-toplevel` devem retornar exatamente:

```text
/Users/macbookpro/Projetos/Credenciamento
```

Leia, nesta ordem:

1. `AGENTS.md`
2. `.hbn/relay/INDEX.md`
3. `.hbn/messages/20260606-2325-handoff-fim-sessao-codex-bastao-codex-para-codex.md`
4. `.hbn/results/0156-exec-onda-38-2-27-fix1-config-layout-design.json`
5. `auditoria/03_ondas/onda_38_2_27_config_help_vcr/0156_FIX1_DESIGN_TECNICO.md`
6. `.hbn/protocol-evolutions/20260606-2325-configuracoes-iniciais-design-first-handoff.md`
7. `docs/tutorials/MANUAL_OPERACIONAL_TELA_A_TELA.md`
8. `docs/reference/testes/GUIA_DE_TESTES_E_VALIDACAO.md`
9. `.hbn/knowledge/0014-protocolo-fim-de-sessao.md`
10. `.hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md`
11. `.hbn/knowledge/0022-firewall-workflow-fast-track.md`

Estado fechado:

- 0153 padronizou punicoes do rodizio em dias e passou TV2 + VCR.
- 0154 iniciou Configuracoes Iniciais, Ajuda HBN e nomenclatura VCR.
- 0155 runtime foi suspensa antes de importacao.
- 0156 substituiu a 0155 por correcao simples no designer/export do UserForm.
- 0156 importou com `M=2 | F=1 | err=0 | skip=0`, compilou, passou
  `TV2_20260606_231033` com `OK=3 | FALHA=0 | MANUAL=0`.
- Mauricio confirmou que o campo `suspender por 30 dia(s)` aceita clique,
  edicao e salvamento. A etapa esta fechada.

Objetivo imediato:

Abrir readback 0158 para continuar a validacao tela a tela em
**Configuracoes Iniciais**, agora cobrindo botoes, menus e submenus ligados a
essa tela, sem implementar antes do hearback.

Escopo de analise sugerido para 0158:

- Formulario `Configuracao_Inicial`;
- botoes da tela: `Ajuda`, `Iniciar Novo Periodo`, `Limpar Base`,
  `Salvar Parametros`;
- botoes/atalhos do menu inicial que interagem com a tela: `Sobre`, `GitHub`,
  `Central de Testes`, `Configuracoes Iniciais`;
- menu lateral do sistema, quando relevante para entrada/saida da tela:
  `Inicio`, `Cadastra Entidade`, `Cadastra Empresa`,
  `Indica Empresa P/ Servico`, `Imprime Solicitacao de Servico`,
  `Avalia Prestador de Servico`, `Cadastra e Altera Servico`, `Relatorios`,
  `Sair`;
- comportamento do X/fechamento se fizer parte do fluxo real do operador.

Regra de engenharia para UserForms:

Antes de propor codigo, classifique o defeito:

- geometria, sobreposicao, alinhamento, tab order, tamanho de campo ou texto:
  preferir correcao no designer e reexportar `.frm/.frx` para `incoming/`;
- regra de negocio, persistencia, validacao, evento de botao ou relatorio:
  corrigir no codigo com teste V2 dirigido;
- se houver duvida, documentar a classificacao no readback e pedir hearback.

Nao fazer:

- nao importar ou restaurar a 0155;
- nao rodar VCR a cada microdelta;
- nao mexer em `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas` ou
  `ThisWorkbook` sem readback proprio;
- nao iniciar V207;
- nao declarar freeze;
- nao reverter alteracoes do worktree.

Teste esperado na proxima onda:

Criar ou ampliar teste V2 dirigido apenas para o comportamento coberto pela
0158. A VCR fica reservada para checkpoint forte.

Comece agora validando a raiz, lendo os documentos na ordem e propondo o
readback 0158. Nao altere arquivos antes do hearback.

===FIM===
