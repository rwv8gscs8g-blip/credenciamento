---
titulo: Onda 37 — Classificacao da reconciliacao V5 vs src/vba
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
---

# Classificacao da reconciliacao V5 vs src/vba

## Escopo

Esta matriz compara a fonte versionada `src/vba/` com o export bruto da V5 em `local-ai/incoming/V206_ANCHOR_V5_20260524/`.
O export bruto e evidencia de comparacao, nao fonte de importacao. Nenhum arquivo de `src/vba/`, `local-ai/vba_import/` ou `local-ai/incoming/` foi alterado por esta reconciliacao.

## Politica de normalizacao

- `.bas` e `.frm`: hash comparativo com CRLF/LF normalizado, trailing whitespace removido e linhas vazias ignoradas.
- `.frx`: hash bruto binario, sem normalizacao textual.
- Drift binario em `.frx` foi classificado como benigno somente quando o `.frm` pareado ficou igual por normalizacao gamma. Quando o `.frm` pareado tambem divergiu textualmente, o `.frx` ficou como diferenca funcional.

## Resumo

| Classe | Qtde | Criterio |
|---|---:|---|
| igual | 8 | Arquivos com hash comparativo identico entre src/vba e export V5. |
| drift_export_benigno | 28 | Diferencas absorvidas por normalizacao textual ou drift binario .frx com codigo .frm equivalente. |
| diferenca_funcional | 28 | Diferenca textual/binaria relevante entre src/vba e V5; nao autoriza overwrite, apenas registra drift funcional. |
| ausente_no_workbook | 0 | Arquivo esperado no workbook mas ausente no export V5, com decisao ja documentada para reincorporacao. |
| obsoleto_no_repo | 1 | Arquivo presente no repo e ausente no workbook com referencia documental de legado/nao reintegracao. |
| precisa_decisao_humana | 1 | Divergencia sem decisao documental suficiente; exige hearback antes de qualquer acao futura. |

Total analisado: 66 arquivos na uniao de `src/vba/` e export V5. Export-only: 0. Missing no export V5 a partir de `src/vba/`: 2.

## Igual

- `Auto_Open.bas` - src/vba/Auto_Open.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Auto_Open.bas; status bruto: raw_equal
- `Central_Testes_V2.bas` - src/vba/Central_Testes_V2.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Central_Testes_V2.bas; status bruto: raw_equal
- `Central_Testes.bas` - src/vba/Central_Testes.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Central_Testes.bas; status bruto: raw_equal
- `Classificar.bas` - src/vba/Classificar.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Classificar.bas; status bruto: raw_equal
- `Const_Colunas.bas` - src/vba/Const_Colunas.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Const_Colunas.bas; status bruto: raw_equal
- `ErrorBoundary.bas` - src/vba/ErrorBoundary.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/ErrorBoundary.bas; status bruto: raw_equal
- `Mod_Limpeza_Base.bas` - src/vba/Mod_Limpeza_Base.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Mod_Limpeza_Base.bas; status bruto: raw_equal
- `Mod_Types.bas` - src/vba/Mod_Types.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Mod_Types.bas; status bruto: raw_equal

## Drift export benigno

- `Altera_Empresa.frm` - src/vba/Altera_Empresa.frm -> local-ai/incoming/V206_ANCHOR_V5_20260524/Altera_Empresa.frm; status bruto: gamma_equal
- `Altera_Empresa.frx` - src/vba/Altera_Empresa.frx -> local-ai/incoming/V206_ANCHOR_V5_20260524/Altera_Empresa.frx; status bruto: binary_diff
- `Altera_Entidade.frm` - src/vba/Altera_Entidade.frm -> local-ai/incoming/V206_ANCHOR_V5_20260524/Altera_Entidade.frm; status bruto: gamma_equal
- `Altera_Entidade.frx` - src/vba/Altera_Entidade.frx -> local-ai/incoming/V206_ANCHOR_V5_20260524/Altera_Entidade.frx; status bruto: binary_diff
- `App_Release.bas` - src/vba/App_Release.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/App_Release.bas; status bruto: gamma_equal
- `AppContext.bas` - src/vba/AppContext.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/AppContext.bas; status bruto: gamma_equal
- `Cadastro_Servico.frm` - src/vba/Cadastro_Servico.frm -> local-ai/incoming/V206_ANCHOR_V5_20260524/Cadastro_Servico.frm; status bruto: gamma_equal
- `Cadastro_Servico.frx` - src/vba/Cadastro_Servico.frx -> local-ai/incoming/V206_ANCHOR_V5_20260524/Cadastro_Servico.frx; status bruto: binary_diff
- `Credencia_Empresa.frm` - src/vba/Credencia_Empresa.frm -> local-ai/incoming/V206_ANCHOR_V5_20260524/Credencia_Empresa.frm; status bruto: gamma_equal
- `Credencia_Empresa.frx` - src/vba/Credencia_Empresa.frx -> local-ai/incoming/V206_ANCHOR_V5_20260524/Credencia_Empresa.frx; status bruto: binary_diff
- `Funcoes.bas` - src/vba/Funcoes.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Funcoes.bas; status bruto: gamma_equal
- `Fundo_Branco.frm` - src/vba/Fundo_Branco.frm -> local-ai/incoming/V206_ANCHOR_V5_20260524/Fundo_Branco.frm; status bruto: gamma_equal
- `Fundo_Branco.frx` - src/vba/Fundo_Branco.frx -> local-ai/incoming/V206_ANCHOR_V5_20260524/Fundo_Branco.frx; status bruto: binary_diff
- `Limpar_Base.frm` - src/vba/Limpar_Base.frm -> local-ai/incoming/V206_ANCHOR_V5_20260524/Limpar_Base.frm; status bruto: gamma_equal
- `Limpar_Base.frx` - src/vba/Limpar_Base.frx -> local-ai/incoming/V206_ANCHOR_V5_20260524/Limpar_Base.frx; status bruto: binary_diff
- `ProgressBar.frm` - src/vba/ProgressBar.frm -> local-ai/incoming/V206_ANCHOR_V5_20260524/ProgressBar.frm; status bruto: gamma_equal
- `ProgressBar.frx` - src/vba/ProgressBar.frx -> local-ai/incoming/V206_ANCHOR_V5_20260524/ProgressBar.frx; status bruto: binary_diff
- `Reativa_Empresa.frm` - src/vba/Reativa_Empresa.frm -> local-ai/incoming/V206_ANCHOR_V5_20260524/Reativa_Empresa.frm; status bruto: gamma_equal
- `Reativa_Empresa.frx` - src/vba/Reativa_Empresa.frx -> local-ai/incoming/V206_ANCHOR_V5_20260524/Reativa_Empresa.frx; status bruto: binary_diff
- `Reativa_Entidade.frm` - src/vba/Reativa_Entidade.frm -> local-ai/incoming/V206_ANCHOR_V5_20260524/Reativa_Entidade.frm; status bruto: gamma_equal
- `Reativa_Entidade.frx` - src/vba/Reativa_Entidade.frx -> local-ai/incoming/V206_ANCHOR_V5_20260524/Reativa_Entidade.frx; status bruto: binary_diff
- `Rel_Emp_Serv.frm` - src/vba/Rel_Emp_Serv.frm -> local-ai/incoming/V206_ANCHOR_V5_20260524/Rel_Emp_Serv.frm; status bruto: gamma_equal
- `Rel_Emp_Serv.frx` - src/vba/Rel_Emp_Serv.frx -> local-ai/incoming/V206_ANCHOR_V5_20260524/Rel_Emp_Serv.frx; status bruto: binary_diff
- `Rel_OSEmpresa.frm` - src/vba/Rel_OSEmpresa.frm -> local-ai/incoming/V206_ANCHOR_V5_20260524/Rel_OSEmpresa.frm; status bruto: gamma_equal
- `Rel_OSEmpresa.frx` - src/vba/Rel_OSEmpresa.frx -> local-ai/incoming/V206_ANCHOR_V5_20260524/Rel_OSEmpresa.frx; status bruto: binary_diff
- `Util_Evolucao.bas` - src/vba/Util_Evolucao.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Util_Evolucao.bas; status bruto: gamma_equal
- `Util_Filtro_Lista.bas` - src/vba/Util_Filtro_Lista.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Util_Filtro_Lista.bas; status bruto: gamma_equal
- `Util_Planilha.bas` - src/vba/Util_Planilha.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Util_Planilha.bas; status bruto: gamma_equal

## Diferenca funcional

- `Audit_Log.bas` - src/vba/Audit_Log.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Audit_Log.bas; status bruto: text_diff
- `Central_Testes_Relatorio.bas` - src/vba/Central_Testes_Relatorio.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Central_Testes_Relatorio.bas; status bruto: text_diff
- `Configuracao_Inicial.frm` - src/vba/Configuracao_Inicial.frm -> local-ai/incoming/V206_ANCHOR_V5_20260524/Configuracao_Inicial.frm; status bruto: text_diff
- `Configuracao_Inicial.frx` - src/vba/Configuracao_Inicial.frx -> local-ai/incoming/V206_ANCHOR_V5_20260524/Configuracao_Inicial.frx; status bruto: binary_diff
- `Importador_V3.bas` - src/vba/Importador_V3.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Importador_V3.bas; status bruto: text_diff
- `Menu_Principal.frm` - src/vba/Menu_Principal.frm -> local-ai/incoming/V206_ANCHOR_V5_20260524/Menu_Principal.frm; status bruto: text_diff
- `Menu_Principal.frx` - src/vba/Menu_Principal.frx -> local-ai/incoming/V206_ANCHOR_V5_20260524/Menu_Principal.frx; status bruto: binary_diff
- `Preencher.bas` - src/vba/Preencher.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Preencher.bas; status bruto: text_diff
- `Repo_Avaliacao.bas` - src/vba/Repo_Avaliacao.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Repo_Avaliacao.bas; status bruto: text_diff
- `Repo_Credenciamento.bas` - src/vba/Repo_Credenciamento.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Repo_Credenciamento.bas; status bruto: text_diff
- `Repo_Empresa.bas` - src/vba/Repo_Empresa.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Repo_Empresa.bas; status bruto: text_diff
- `Repo_OS.bas` - src/vba/Repo_OS.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Repo_OS.bas; status bruto: text_diff
- `Repo_PreOS.bas` - src/vba/Repo_PreOS.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Repo_PreOS.bas; status bruto: text_diff
- `Svc_Avaliacao.bas` - src/vba/Svc_Avaliacao.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Svc_Avaliacao.bas; status bruto: text_diff
- `Svc_Entidade.bas` - src/vba/Svc_Entidade.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Svc_Entidade.bas; status bruto: text_diff
- `Svc_OS.bas` - src/vba/Svc_OS.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Svc_OS.bas; status bruto: text_diff
- `Svc_PreOS.bas` - src/vba/Svc_PreOS.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Svc_PreOS.bas; status bruto: text_diff
- `Svc_Rodizio.bas` - src/vba/Svc_Rodizio.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Svc_Rodizio.bas; status bruto: text_diff
- `Svc_Transacao.bas` - src/vba/Svc_Transacao.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Svc_Transacao.bas; status bruto: text_diff
- `Teste_Bateria_Oficial.bas` - src/vba/Teste_Bateria_Oficial.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Teste_Bateria_Oficial.bas; status bruto: text_diff
- `Teste_UI_Guiado.bas` - src/vba/Teste_UI_Guiado.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Teste_UI_Guiado.bas; status bruto: text_diff
- `Teste_V2_Engine.bas` - src/vba/Teste_V2_Engine.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Teste_V2_Engine.bas; status bruto: text_diff
- `Teste_V2_Roteiros.bas` - src/vba/Teste_V2_Roteiros.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Teste_V2_Roteiros.bas; status bruto: text_diff
- `Teste_Validacao_Release.bas` - src/vba/Teste_Validacao_Release.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Teste_Validacao_Release.bas; status bruto: text_diff
- `Treinamento_Painel.bas` - src/vba/Treinamento_Painel.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Treinamento_Painel.bas; status bruto: text_diff
- `Util_Config.bas` - src/vba/Util_Config.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Util_Config.bas; status bruto: text_diff
- `Util_Conversao.bas` - src/vba/Util_Conversao.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Util_Conversao.bas; status bruto: text_diff
- `Variaveis.bas` - src/vba/Variaveis.bas -> local-ai/incoming/V206_ANCHOR_V5_20260524/Variaveis.bas; status bruto: text_diff

## Ausente no workbook

- Nenhum arquivo nesta categoria.

## Obsoleto no repo

- `Importador_V2.bas` - src/vba/Importador_V2.bas -> MISSING; status bruto: missing

Referencia documental: `Importador_V2.bas` aparece como legado V13 removido do workbook na Onda 9 e com orientacao "NAO REINTEGRAR" em `auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md`. Esta onda nao remove o arquivo; apenas registra a classificacao para uma micro-onda futura, se Mauricio aprovar.

## Precisa decisao humana

- `Emergencia_CNAE.bas` - src/vba/Emergencia_CNAE.bas -> MISSING; status bruto: missing

Opcao recomendada para hearback humano: manter `Emergencia_CNAE.bas` fora do workbook V5 e fora de `local-ai/vba_import/` nesta V206, sem apagar do repo agora; abrir decisao especifica para arquivar/remover ou reincorporar apenas se houver ADR/ERP que justifique. Motivo: ha historico de que ficou fora do Phase 1 e da Onda 12, mas nao ha decisao final desta Onda 37 para remover ou reimportar.

## Matriz por arquivo

| Arquivo | Classe | Status bruto |
|---|---|---|
| `Altera_Empresa.frm` | `drift_export_benigno` | gamma_equal |
| `Altera_Empresa.frx` | `drift_export_benigno` | binary_diff |
| `Altera_Entidade.frm` | `drift_export_benigno` | gamma_equal |
| `Altera_Entidade.frx` | `drift_export_benigno` | binary_diff |
| `App_Release.bas` | `drift_export_benigno` | gamma_equal |
| `AppContext.bas` | `drift_export_benigno` | gamma_equal |
| `Audit_Log.bas` | `diferenca_funcional` | text_diff |
| `Auto_Open.bas` | `igual` | raw_equal |
| `Cadastro_Servico.frm` | `drift_export_benigno` | gamma_equal |
| `Cadastro_Servico.frx` | `drift_export_benigno` | binary_diff |
| `Central_Testes_Relatorio.bas` | `diferenca_funcional` | text_diff |
| `Central_Testes_V2.bas` | `igual` | raw_equal |
| `Central_Testes.bas` | `igual` | raw_equal |
| `Classificar.bas` | `igual` | raw_equal |
| `Configuracao_Inicial.frm` | `diferenca_funcional` | text_diff |
| `Configuracao_Inicial.frx` | `diferenca_funcional` | binary_diff |
| `Const_Colunas.bas` | `igual` | raw_equal |
| `Credencia_Empresa.frm` | `drift_export_benigno` | gamma_equal |
| `Credencia_Empresa.frx` | `drift_export_benigno` | binary_diff |
| `Emergencia_CNAE.bas` | `precisa_decisao_humana` | missing |
| `ErrorBoundary.bas` | `igual` | raw_equal |
| `Funcoes.bas` | `drift_export_benigno` | gamma_equal |
| `Fundo_Branco.frm` | `drift_export_benigno` | gamma_equal |
| `Fundo_Branco.frx` | `drift_export_benigno` | binary_diff |
| `Importador_V2.bas` | `obsoleto_no_repo` | missing |
| `Importador_V3.bas` | `diferenca_funcional` | text_diff |
| `Limpar_Base.frm` | `drift_export_benigno` | gamma_equal |
| `Limpar_Base.frx` | `drift_export_benigno` | binary_diff |
| `Menu_Principal.frm` | `diferenca_funcional` | text_diff |
| `Menu_Principal.frx` | `diferenca_funcional` | binary_diff |
| `Mod_Limpeza_Base.bas` | `igual` | raw_equal |
| `Mod_Types.bas` | `igual` | raw_equal |
| `Preencher.bas` | `diferenca_funcional` | text_diff |
| `ProgressBar.frm` | `drift_export_benigno` | gamma_equal |
| `ProgressBar.frx` | `drift_export_benigno` | binary_diff |
| `Reativa_Empresa.frm` | `drift_export_benigno` | gamma_equal |
| `Reativa_Empresa.frx` | `drift_export_benigno` | binary_diff |
| `Reativa_Entidade.frm` | `drift_export_benigno` | gamma_equal |
| `Reativa_Entidade.frx` | `drift_export_benigno` | binary_diff |
| `Rel_Emp_Serv.frm` | `drift_export_benigno` | gamma_equal |
| `Rel_Emp_Serv.frx` | `drift_export_benigno` | binary_diff |
| `Rel_OSEmpresa.frm` | `drift_export_benigno` | gamma_equal |
| `Rel_OSEmpresa.frx` | `drift_export_benigno` | binary_diff |
| `Repo_Avaliacao.bas` | `diferenca_funcional` | text_diff |
| `Repo_Credenciamento.bas` | `diferenca_funcional` | text_diff |
| `Repo_Empresa.bas` | `diferenca_funcional` | text_diff |
| `Repo_OS.bas` | `diferenca_funcional` | text_diff |
| `Repo_PreOS.bas` | `diferenca_funcional` | text_diff |
| `Svc_Avaliacao.bas` | `diferenca_funcional` | text_diff |
| `Svc_Entidade.bas` | `diferenca_funcional` | text_diff |
| `Svc_OS.bas` | `diferenca_funcional` | text_diff |
| `Svc_PreOS.bas` | `diferenca_funcional` | text_diff |
| `Svc_Rodizio.bas` | `diferenca_funcional` | text_diff |
| `Svc_Transacao.bas` | `diferenca_funcional` | text_diff |
| `Teste_Bateria_Oficial.bas` | `diferenca_funcional` | text_diff |
| `Teste_UI_Guiado.bas` | `diferenca_funcional` | text_diff |
| `Teste_V2_Engine.bas` | `diferenca_funcional` | text_diff |
| `Teste_V2_Roteiros.bas` | `diferenca_funcional` | text_diff |
| `Teste_Validacao_Release.bas` | `diferenca_funcional` | text_diff |
| `Treinamento_Painel.bas` | `diferenca_funcional` | text_diff |
| `Util_Config.bas` | `diferenca_funcional` | text_diff |
| `Util_Conversao.bas` | `diferenca_funcional` | text_diff |
| `Util_Evolucao.bas` | `drift_export_benigno` | gamma_equal |
| `Util_Filtro_Lista.bas` | `drift_export_benigno` | gamma_equal |
| `Util_Planilha.bas` | `drift_export_benigno` | gamma_equal |
| `Variaveis.bas` | `diferenca_funcional` | text_diff |

## Observacao de drift de metadata

`Altera_Entidade.frm` e `Altera_Entidade.frx` aparecem presentes no export atual da V5. Isso diverge do handoff anterior que listava esses dois arquivos como ausentes. A reconciliacao atual usa o estado real do filesystem em 2026-05-24 e registra o achado como drift de metadata do handoff, nao como decisao funcional.
