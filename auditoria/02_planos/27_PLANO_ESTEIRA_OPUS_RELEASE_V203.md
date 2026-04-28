---
titulo: Plano da Esteira Opus ate o Fechamento Estavel da V12.0.0203
natureza-do-documento: plano de execucao em ondas curtas, conduzidas por Claude Opus, com aprovacao humana entre cada onda
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
branch: codex/v12-0-0203-governanca-testes
data: 2026-04-27
autor: Claude Opus 4.7 (sessao Cowork)
solicitante: Luis Mauricio Junqueira Zanin
documentos-irmaos: auditoria/22..26
escopo: execucao real de codigo em ondas curtas; cada onda entrega arquivos prontos para reimportar e testar
---

# 27. Plano da Esteira Opus ate o Fechamento Estavel da V12.0.0203

## 00. Mudanca de papel

A partir desta sessao, **Claude Opus assume como executor principal** das
microevolucoes ate a publicacao da `V12.0.0203` estavel. Codex continua
disponivel para correcoes pontuais, mas a esteira passa a ser conduzida
por ondas curtas e fechadas do Opus, com aprovacao humana entre ondas.

## 01. Princípio de operacao

Cada **onda** atende a tres regras inviolaveis:

1. **fechada**: a onda inteira e entregue de uma vez, com codigo
   completo, testes automatizados e doc atualizada;
2. **curta**: cabe em uma sessao unica, toca poucos arquivos por
   pacote, nao depende de reexportacao do `.frx` (a menos que esteja
   marcada explicitamente como dependente da UI);
3. **gateavel**: o operador roda compilacao + trio minimo + cenarios
   novos antes da proxima onda.

A regra `nao tocar Mod_Types.bas` permanece em vigor. Todo passo abaixo
respeita essa fronteira.

## 02. Estado atual ancora (2026-04-27)

- Branch ativa: `codex/v12-0-0203-governanca-testes`.
- Ultimo commit: `f7aa84f`.
- 8 arquivos modificados nao commitados (PE-02 ampliado, PE-03, PE-05,
  PE-06, PE-07).
- Drop em `local-ai/incoming/vba-forms/Configuracao_Inicial.frm` (data
  27/04 10:46) com `Label49` novo — sinal de que o operador comecou a
  preparar o designer da Configuracao Inicial.
- Trio minimo: verde no validador `VR_20260426_111549`.

## 03. Decisoes de produto consolidadas

Conforme alinhado com Mauricio:

1. **Nota de corte para strike**: padrao **5.0**, ja existente em
   `GetNotaMinimaAvaliacao()`. **NAO duplicar** — a nota de corte usada
   para strike sera lida do mesmo `COL_CFG_NOTA_MINIMA`. Avaliacao com
   `media < notaCorte` => 1 strike.
2. **Numero de strikes para suspender**: configuravel, padrao **3**.
   Coluna nova `COL_CFG_MAX_STRIKES = 13` (M).
3. **Punicao em dias**: configuravel, padrao **90 dias**. Coluna nova
   `COL_CFG_DIAS_SUSPENSAO_STRIKE = 14` (N). Substitui (nesse caminho
   especifico) o calculo em meses; o legado de meses fica preservado
   para a suspensao por excesso de recusas (`MAX_RECUSAS`).
4. **Retorno automatico**: a empresa volta sozinha quando `DT_FIM_SUSP <=
   hoje` (mecanismo ja existente em `Svc_Rodizio.SelecionarEmpresa`).
   Ao reativar (auto ou manual), o **contador de strikes e zerado
   implicitamente** porque `Reativar` ja zera `QTD_RECUSAS_GLOBAL` e
   limpa `DT_FIM_SUSP`. Strikes sao contados **on-the-fly** a partir do
   historico em `CAD_OS` (coluna `COL_OS_MEDIA`), filtrados pela
   data **maior que** `DT_REATIVA_ULTIMA` quando essa coluna existir,
   ou desde sempre quando nao existir (escolha conservadora — ver onda 2).
5. **Retorno imediato com correcao**: para a primeira versao,
   "correcao" e definida como "termino do prazo". Reativacao manual
   pelo gestor continua disponivel via `Svc_Rodizio.Reativar`.
6. **Configuracao na interface**: o `Configuracao_Inicial.frm` ja teve
   `Label49` adicionado pelo operador. A onda que toca o `.frm` precisa
   de reexportacao do `.frx` (marcada como dependente da UI).

## 04. Ondas previstas

A esteira completa cabe em **6 ondas** ate o fechamento da `V12.0.0203`.

### ONDA 1 — Regra de strikes na avaliacao (entregue agora)

- Suspensao por contagem configuravel de notas baixas com punicao em
  dias. Nao depende de reexportar `.frx` (interface fica para a Onda 5).
- Documento tecnico: `auditoria/28_ONDA_01_REGRA_STRIKES_AVALIACAO.md`.

### ONDA 2 — CNAE: snapshot, dedup e teste

- Implementar PE-08 + PE-09 do parecer 25:
  - snapshot automatico de `CAD_SERV` antes do reset;
  - validacao de duplicidade pos-import (zero `CNAE+DESCRICAO` repetidos);
  - cenarios `CNAE_001` (snapshot) e `CNAE_002` (dedup);
  - eventos novos `CNAE_RESET_INICIADO` e `CNAE_RESET_CONCLUIDO`.
- Arquivos provaveis: `Preencher.bas`, `Audit_Log.bas` (apenas
  constante), `Teste_V2_Roteiros.bas`, `Const_Colunas.bas` (constante de
  prefixo de aba snapshot).

### ONDA 3 — Cenario E2E de credenciamento + suite de filtros completa

- PE-10 do parecer 25: novo `CS_25_CREDENCIAMENTO_ENDtoEND`.
- Adicionar cenarios `FLT_*` que exercitem o `Util_Filtro_Lista` com
  matrizes derivadas das listas reais (Empresas, Entidades, Atividades,
  Servicos, Manutencao de valor).
- Arquivos: `Teste_V2_Roteiros.bas`, `Teste_V2_Engine.bas` (helpers).

### ONDA 4 — Padronizacao de relatorios + exportacao PDF + log

- PE-11, PE-12, PE-13.
- `Util_Config.Rel_ConfigurarPagina` (rodape uniforme com hash curto do
  build), `Util_Config.Rel_ExportarPDF`, aba `RPT_PDFs_EMITIDOS`.
- Arquivos: `Util_Config.bas`, `Rel_OSEmpresa.frm`, `Rel_Emp_Serv.frm`,
  `Const_Colunas.bas` (nova aba), `Teste_V2_Roteiros.bas` (cenarios
  `RPT_*`).

### ONDA 5 — Interface da Configuracao Inicial (depende do operador)

- Sincronizar `Configuracao_Inicial.frm` com o `.frx` reexportado pelo
  operador (TextBox novos para `MAX_STRIKES` e `DIAS_SUSPENSAO_STRIKE`).
- Acrescentar logica em `B_Parametros_Click` para gravar nas colunas L
  e M de CONFIG.
- PE-04 (Reativa_Entidade.frm) entra junto, plug do helper.
- Arquivos: `Configuracao_Inicial.frm`, `Reativa_Entidade.frm`.
- **Esta e a unica onda que depende de reexportacao no Excel.**

### ONDA 6 — Fechamento da release V12.0.0203

- PE-01 do parecer 25:
  - rodar trio minimo + validador consolidado no build limpo;
  - atualizar `App_Release.bas` para `V12.0.0203 / VALIDADO / OFICIAL`;
  - mover `[Unreleased]` do `CHANGELOG.md` para `[V12.0.0203]`;
  - `STATUS-OFICIAL.md`, release note, dashboard;
  - tag `v12.0.0203` apos confirmacao humana;
  - documentacao narrada inicial: `docs/testes/02..06.md` (catalogo
    minimo, sem detalhamento exaustivo).

## 05. Onda 7+ (apos a release)

Tudo isso fica para a fase pos-publicacao da `V12.0.0203`:

- **Onda 7**: simulador UI camada A (`Teste_UI_Simulador.bas`,
  cenarios `UISIM_001..003`, secao 5 do parecer 25).
- **Onda 8**: redesign do painel assistido
  (`Painel_Testes_Assistido.frm`).
- **Onda 9**: documentacao narrada completa de todos os testes
  (`docs/testes/02..09.md`).
- **Onda 10**: revisao do importador automatico (frente isolada com
  plano dedicado em `auditoria/29_*.md`).
- **Onda 11**: revisao de `Mod_Types.bas` (apenas se houver bug
  funcional confirmado, com plano dedicado em `auditoria/30_*.md`).
- **Onda 12**: simulador UI camada B (automacao externa Windows).

## 06. Como Mauricio aprova cada onda

> **Regra global:** **nenhuma onda usa o script
> `local-ai/scripts/publicar_vba_import.sh`** nem o
> `Importador_VBA.bas`. Toda importacao e manual, modulo por modulo,
> via VBE, com remocao previa do modulo de mesmo nome, backup do
> `.xlsm` antes e compilacao apos cada arquivo. Para a ONDA 1 esse
> procedimento esta detalhado em
> `auditoria/29_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_01.md`. Cada
> onda seguinte ganha um documento de procedimento equivalente.
>
> **Regra global complementar (2026-04-27):** **toda onda comeca por
> editar e importar `src/vba/App_Release.bas`**. Sem isso, a tela
> `Sobre` continua mostrando o build da onda anterior e a evidencia
> (CSV do validador consolidado) carimba o build errado. O passo de
> editar `APP_BUILD_IMPORTADO`, `APP_BUILD_BRANCH` e
> `APP_BUILD_GERADO_EM` e responsabilidade do Opus dentro da sessao
> da onda. O operador apenas faz Remove + Import + Compilar do
> `App_Release.bas` no VBE como **arquivo 0** de cada lista.
> Convencao do identificador: `<commit-base>+ONDA<NN>-em-homologacao`
> antes do commit; `<novo-commit-curto>-homologado` apos commitar a
> onda. A funcao `AppRelease_BuildImportadoRotulo` (ja existente)
> traduz o sufixo para o rotulo amigavel da tela `Sobre`.

1. Opus entrega o pacote completo (codigo + testes + doc) em uma
   sessao, mais um documento de procedimento manual de import seguro
   (`auditoria/2X_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_NN.md`);
2. operador faz backup do `.xlsm` e segue o procedimento manual;
3. operador roda trio minimo
   (`Teste_Validacao_Release.CT_ValidarRelease_TrioMinimo` ou as 3
   chamadas individuais) + os cenarios novos especificos da onda;
4. arquivar CSV de evidencia em
   `auditoria/evidencias/V12.0.0203/`;
5. responder no chat com OK ou com falha + log;
6. so apos OK, Opus inicia a proxima onda.

## 07. Riscos da esteira em modo Opus

| Risco | Mitigacao |
|---|---|
| Opus tocar arquivo sem necessidade | cada onda ja vem com lista exata de arquivos; arquivos fora da lista nao sao tocados |
| Quebra silenciosa por cenario nao previsto | toda onda inclui cenario de regressao para o comportamento anterior |
| Onda 5 ficar travada por reexportacao | onda 5 vem ultima antes do fechamento; ate la o operador tem todo o ciclo aberto para preparar o designer |
| Acumular tres ondas sem aprovacao | regra estrita: nao iniciar onda N+1 sem confirmacao da onda N |

## 08. Conclusao

Este e o plano mestre da esteira. A primeira entrega (Onda 1) ja vem
junto desta sessao em arquivos novos e modificados, documentada em
`auditoria/28_ONDA_01_REGRA_STRIKES_AVALIACAO.md`.
