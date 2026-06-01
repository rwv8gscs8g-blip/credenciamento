---
titulo: Onda 38.2.4 — Integridade de Estado
diataxis: onda
hbn-track: safe_track
hbn-status: archived
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-31
---

# Onda 38.2.4 — Integridade de Estado

## Objetivo

Resolver o primeiro bloco de BLOQUEADORES do L43/GATE-A4, adotando o parecer `0024` como arbitro principal:

- ordenacao deterministica em `Classificar.bas` (`xlGuess` removido);
- inativacao de entidade com rollback defensivo em `Altera_Entidade.frm`;
- protecao verificavel das abas criticas em `Util_Planilha.bas`;
- suite dirigida `TV2_RunIntegridadeEstado` em `Teste_V2_Roteiros.bas`.

## Fora de Escopo

- `Auto_Open.bas` permanece fora do escopo inicial;
- Configuracao Inicial / strikes UI;
- impressao Pre-OS, OS e avaliacao;
- designer visual, filtros e performance;
- qualquer decisao V207.

## Artefatos

- Readback: `.hbn/readbacks/0120-rb-onda-38-2-4-integridade-estado.json`
- Hearback: `.hbn/hearbacks/0120-rb-onda-38-2-4-integridade-estado-confirmed.json`
- Manifesto Fase 1: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_4_INTEGRIDADE_ESTADO_F1_MODULOS.txt`
- Manifesto Fase 2: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_4_INTEGRIDADE_ESTADO_F2_FORMS.txt`
- Manifesto Fix1: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_4_ESTADO_FIX1_ENTIDADE.txt`
- Manifesto Fix2: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_4_ESTADO_FIX2_TV2_TOKEN.txt`
- Manifesto Fix3: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_4_ESTADO_FIX3_LAST_ROW_TABLE.txt`
- Manifesto Fix4: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_4_ESTADO_FIX4_PROTECAO_ABAS.txt`
- Manifesto Fix5: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_4_ESTADO_FIX5_OBJETOS_ABAS.txt`
- Procedimento: `auditoria/03_ondas/onda_38_2_4/IMPORT_PROCEDURE_2_FASES.md`
- Import/TV2: `auditoria/03_ondas/onda_38_2_4/GATE_IMPORT_TV2_RESULTADO.md`
- Gate D2: `auditoria/03_ondas/onda_38_2_4/GATE_D2_ORDENACAO.md`
- Gate D3: `auditoria/03_ondas/onda_38_2_4/GATE_D3_ENTIDADE_ATOMICA.md`
- Gate D4: `auditoria/03_ondas/onda_38_2_4/GATE_D4_PROTECAO_ABAS.md`
- Gate D5: `auditoria/03_ondas/onda_38_2_4/GATE_D5_OBJETOS_ABAS_CRITICAS.md`
- RVS final: `auditoria/03_ondas/onda_38_2_4/RVS_FINAL.md`
- Revalidacao manual: `auditoria/03_ondas/onda_38_2_4/REVALIDACAO_MANUAL_ENTIDADES.md`
- Mapa de testes de Entidades: `auditoria/03_ondas/onda_38_2_4/MAPA_TESTES_ENTIDADES_V206.md`
- Observacoes manuais: `auditoria/03_ondas/onda_38_2_4/OBSERVACOES_MANUAIS_ENTIDADES.md`
- Nota V207: `auditoria/03_ondas/onda_38_2_4/V207_NOTA_ARQUITETURA_STATUS_CANONICO.md`

## Gates

1. Import Fase 1 e compile manual limpo.
2. Import Fase 2, compile manual limpo e `TV2_RunIntegridadeEstado` verde.
3. RVS completo aprovado apos Fase 2.
4. Revalidacao manual L43 dos itens de ordenacao, entidade ativa/inativa e protecao de abas.
5. Auditoria cruzada pos-onda antes de avancar para Config UI/impressao.
6. Reteste manual `ENT_MAN_23` pos-RVS no build salvo.

## Status

Import Fase 1, compile Fase 1, import Fase 2, compile Fase 2, `TV2_RunIntegridadeEstado` e RVS completo foram reportados como aprovados por Mauricio em 2026-05-30.

Evidencias:

- `GATE_IMPORT_TV2_RESULTADO.md`
- `RVS_FINAL.md`

Revalidacao manual detectou erro ao inativar o primeiro item ativo de entidade. Foi aberto Fix1 no mesmo escopo da onda.

Fix1 importou e compilou, e o RVS completo `VR_20260530_145839` passou no build `fd45a5d+ONDA38.2.4-ESTADO-FIX1-ENTIDADE`. A suite dirigida falhou por token textual `ActiveCell` em comentario historico do form; foi aberto Fix2 para remover esse falso positivo.

Fix2 importou e compilou. `TV2_RunIntegridadeEstado` passou com `OK=4 | FALHA=0 | MANUAL=0` na execucao `TV2_20260530_153820`.

Nova revalidacao manual detectou erro ao inativar a ultima entidade ativa de uma tabela Excel: o `ListObject` recusa excluir a unica linha de dados porque ela passa a funcionar como linha de insercao/cabecalho. Foi aberto Fix3 para preservar a tabela e limpar o conteudo da unica linha em vez de excluir a linha fisica.

Fix3 importou e compilou. `TV2_RunIntegridadeEstado` passou com `OK=5 | FALHA=0 | MANUAL=0` na execucao `TV2_20260530_162347`. A revalidacao manual dirigida confirmou inativacao/reativacao de item intermediario, primeiro item, ultima entidade ativa e exclusividade ativa/inativa sem duplicidade.

RVS completo pos-Fix3 passou com `VR_20260530_164422`, mas a revalidacao manual D4 bloqueou a onda: `ENTIDADE`, `ENTIDADE_INATIVOS` e `PRE_OS` aceitavam escrita direta sem desbloqueio. Foi aberto Fix4 para aplicar protecao efetiva com celulas bloqueadas e reteste manual antes e depois do RVS.

Fix4 importou e compilou em 2026-05-30. Mauricio confirmou bloqueio de escrita direta em `ENTIDADE`, `ENTIDADE_INATIVOS`, `PRE_OS`, `CAD_OS` e `EMPRESAS`. RVS completo pos-Fix4 passou com `VR_20260530_210350`, build `fd45a5d+ONDA38.2.4-ESTADO-FIX4-PROTECAO-ABAS`.

Fix5 importou e compilou em 2026-05-31. Mauricio reportou import V3 `M=3 | F=0 | err=0 | skip=0`, backup `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260531_013500-V3-FULL`, compile manual VBE aprovado e `TV2_RunIntegridadeEstado` verde na execucao `TV2_20260531_013557` com `OK=8 | FALHA=0 | MANUAL=0`, sem CSV de falhas.

Mauricio reportou D5 manual aprovado em 2026-05-31: `ENTIDADE_INATIVOS` limpa, edicao direta bloqueada em planilhas criticas e tentativa de colar imagem bloqueada corretamente. RVS completo pos-Fix5 aprovado em `VR_20260531_092609`, build `fd45a5d+ONDA38.2.4-ESTADO-FIX5-OBJETOS-ABAS`, CSV `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260531_092609.csv`, SHA-256 `ee0bbd9840cce362592aa856ee9224b921ff8467fdc8aea8dc1e5ee240c48056`.

Auditoria cruzada curta concluida: Antigravity/Gemini 3.5 recomendou aprovar a onda e fechar ERP 0120; Opus 4.8 recomendou fechar apos confirmar o `ENT_MAN_23` pos-RVS, sem liberar propagacao/freeze. Mauricio confirmou o `ENT_MAN_23` em 2026-05-31 12:22: `ThisWorkbook.Path = \\Mac\Home\Projetos\Credenciamento`, `GetBuildImportado() = fd45a5d+ONDA38.2.4-ESTADO-FIX5-OBJETOS-ABAS`, bloqueio habilitado em `ENTIDADE`, `ENTIDADE_INATIVOS`, `PRE_OS`, `CAD_OS`, `EMPRESAS` e aba de empresas inativas.

Status final: Onda 38.2.4 aprovada e fechada pelo ERP 0120. Este fechamento nao declara freeze V206 nem libera propagacao automatica do padrao para outros campos.

Residuos visuais continuam documentados em `OBSERVACOES_MANUAIS_ENTIDADES.md`: campos completos aparecem no modal de edicao mas nao na tela principal, e ha possivel problema de visibilidade/scroll de item ativo apos reativacao. Esses residuos estao fora do readback `0120`.

Freeze V206 permanece bloqueado ate todos os BLOQUEADORES L43 serem resolvidos e auditados. Proximos passos ficam fora da Onda 38.2.4: resolver os bloqueadores remanescentes do parecer `0024`, evoluir FAQ HBN como protocolo futuro e transformar os testes de Entidades em cobertura comportamental antes de propagar o padrao.
