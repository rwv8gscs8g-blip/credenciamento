---
titulo: Estado Atual do Sistema
ultima-atualizacao: 2026-04-19
autor-ultima-alteracao: GPT-5 (Codex)
tags: [vivo, regra]
versao-sistema: V12.0.0201
---

# Estado Atual do Sistema

## Versao

- **Versao**: V12.0.0201
- **Data**: 2026-04-19
- **Status**: EM_VALIDACAO
- **Compila**: Pendente de validacao no Excel
- **Arquivo**: PlanilhaCredenciamento-Homologacao.xlsm

## O que Funciona

- Abertura do sistema (Auto_Open > Menu_Principal)
- Importacao de CNAEs via ImportarCNAE_Emergencia (612 atividades)
- Cadastro de empresas (Credencia_Empresa)
- Alteracao de empresas (Altera_Empresa)
- Reativacao de empresas (Reativa_Empresa)
- Gestao de entidades (Altera_Entidade, Reativa_Entidade)
- Filtros de busca (empresas, entidades)
- Cadastro de servicos (CAD_SERV) com edicao (Alterar Dados)
- Bateria oficial de testes (resultados em `RESULTADO_QA`; a regressao de divergencia na avaliacao foi enderecada na `0193`, pendente revalidacao no Excel)
- Bateria V2 independente (`Central_Testes_V2`, `Teste_V2_Engine`, `Teste_V2_Roteiros`) com `RESULTADO_QA_V2`, `CATALOGO_CENARIOS_V2`, `ROTEIRO_ASSISTIDO_V2` e stress deterministico
- `Central_Testes` simplificada para a transicao: apenas bateria legada + entrada da V2
- V2 descarrega a instancia real do `Menu_Principal` em toda execucao e navegacao da bateria, inclusive antes de abrir a central V2, e exporta apenas CSV de falhas quando existir erro
- V2 passou a validar cenario deterministico completo sobre reset operacional, configuracao canonica, servicos canonicos e contrato real da fila (ordem integra, nao renumeracao forcada)
- V2 passou a medir registros por coluna-chave semantica e a validar imediatamente o reset das abas operacionais
- Central V2 reorganizada em automatico + assistido: smoke rapido, smoke assistido, stress deterministico, stress assistido e roteiro humano dedicado
- `Svc_PreOS` passou a validar `ENT_ID` ativo e `QT_ESTIMADA > 0` sem depender do formulario
- `Svc_OS` passou a validar `DT_PREV_TERMINO >= hoje` no proprio servico
- `Svc_Avaliacao` passou a validar `QtExecutada > 0` e agora aceita `Observacao` como motivo efetivo de divergencia quando o campo dedicado vier vazio
- Os cenarios `MIG_001`, `MIG_002`, `MIG_003` e `MIG_004` ficaram assertivos no smoke da V2
- Fluxos de inativacao/reativacao passaram a higienizar duplicidades nas abas `*_INATIVOS`, preferir a linha mais recente e bloquear reativacao quando houver conflito semantico na mesma chave
- A bateria oficial veio limpa nos CSVs enviados pelo revisor humano durante a estabilizacao da `0193`
- A `0194` reverteu apenas o recorte `CNAE/CAD_SERV` da `0193` para o comportamento anterior, preservando as correcoes de avaliacao e da bateria V2
- `Svc_Transacao` passou a registrar writes e permitir rollback minimo entre abas
- `Repo_Credenciamento.IncrementarRecusa` passou a reverter `CREDENCIADOS` se a escrita em `EMPRESAS` falhar no meio do fluxo
- `Svc_Rodizio.AvancarFila` passou a restaurar a fila quando a etapa de punicao falha apos o movimento
- `Audit_Log.RegistrarEvento` passou a preparar/restaurar a aba de auditoria antes de gravar
- `Svc_Transacao` passou a registrar abertura, commit e rollback em `AUDIT_LOG`
- `Util_Planilha.ProximoId` agora restaura protecao mesmo quando ocorre erro
- A V2 ganhou o cenario `ATM_001`, que simula falha controlada na segunda escrita e valida rollback com rastro de auditoria
- A V2 passou a gerar um snapshot unico das 5 abas operacionais antes do primeiro reset da execucao
- A `0196` corrigiu a compatibilidade de compilacao VBA removendo a qualificacao `Audit_Log.` das chamadas `RegistrarEvento`
- A `0197` removeu a tipagem local `eTipoEvento` em `Svc_Rodizio`, mantendo os membros `EVT_*` como constantes
- A `0198` qualificou as chamadas de avaliacao como `Svc_Avaliacao.AvaliarOS` para evitar ambiguidade de nome em projetos reimportados
- A `0199` endureceu o `Importador_VBA` com verificacao de modulos obrigatorios antes da compilacao
- A `0200` corrigiu o excesso de continuacoes de linha no `Importador_VBA` e preservou a checagem estrutural do pacote
- A `0201` removeu a dependencia do tipo nativo `Collection` dentro do `Importador_VBA`, tornando o importador mais tolerante a projetos contaminados
- Terminologia MEI eliminada no codigo VBA e no `Menu_Principal` (designer); relatorio **Rel_OSEmpresa** abre sem crash
- Exportacao de CSV de resultados de teste
- Release metadata centralizada (App_Release.bas)
- Rollback operacional para a base estavel da V12.0.0180 preservado em `backups/rollback-post-v180-2026-04-17/`

## O que Precisa de Validacao

- Rodizio por atividade (Svc_Rodizio) — depende de CNAEs + servicos corretos
- Ordens de servico (Svc_PreOS, Svc_OS, Svc_Avaliacao) apos a migracao das guardas para servico
- Execucao no Excel dos cenarios `MIG_001`, `MIG_002`, `MIG_003` e `MIG_004` dentro do smoke V2
- Execucao no Excel do cenario `ATM_001` dentro do smoke V2
- Validacao da criacao dos snapshots `SNAPV2_*` na primeira execucao da suite V2
- Revalidacao da compilacao da `V12.0.0196` no Excel
- Revalidacao da compilacao da `V12.0.0197` no Excel
- Revalidacao da compilacao da `V12.0.0198` no Excel
- Revalidacao da compilacao da `V12.0.0199` no Excel
- Revalidacao da compilacao da `V12.0.0200` no Excel
- Revalidacao da compilacao da `V12.0.0201` no Excel
- Revalidacao da bateria oficial nos casos `BO_330*`
- Validacao no Excel da `V12.0.0194` apos o rollback cirurgico de `CNAE/CAD_SERV`
- Importacao no Excel dos modulos V2 e execucao das macros `CT2_*`

## Riscos Conhecidos

- ProximoId faz protect/unprotect por linha (performance em lotes grandes)
- AtividadeJaExiste usa varredura O(n^2)
- Ainda existem validacoes operacionais e defaults na interface; a `0191` migra apenas as tres guardas criticas aprovadas para o servico
- Bases historicas com conflito real em `ENTIDADE_INATIVOS` ou `EMPRESAS_INATIVAS` podem agora ser bloqueadas na reativacao ate saneamento manual
- A bateria V2 ainda nao substitui totalmente a legada: a base automatica ficou mais forte, mas ainda faltam atomicidade, edge cases e shadow mode
- O desenho definitivo de `CNAE/CAD_SERV` foi explicitamente adiado como debito tecnico para nao interromper a estabilizacao das fases do Opus
- A atomicidade desta iteracao cobre o fluxo minimo de recusa/avanco; `PreOS`, `OS` e `Avaliacao` ainda nao migraram para transacao ampla
- Emergencia_CNAE, Emergencia_CNAE1/2/3 e Importar_Agora sao modulos temporarios — remover apos estabilizacao

## Proximos Passos

1. Importar `Repo_Avaliacao.bas` no workbook atual e validar a compilacao.
2. Atualizar o importador para a `V12.0.0201`.
2. Reexecutar a bateria oficial.
3. Rodar `CT2_ExecutarSmokeRapido`, `CT2_ExecutarSmokeAssistido`, `CT2_ExecutarStress` e `CT2_ExecutarStressAssistido`, com foco em `ATM_001`.
4. Verificar a criacao dos snapshots `SNAPV2_*` durante a primeira execucao da V2.
5. Seguir para a proxima fatia da fase 3: ampliar atomicidade para `PreOS/OS/Avaliacao`, edge cases e shadow mode.
6. Tratar `CNAE/CAD_SERV` apenas no backlog dedicado documentado em `DEBITO-TECNICO-CNAE-CADSERV.md`.

## Documentos Relacionados

- [[REGRAS]] — Regras inviolaveis
- [[PIPELINE]] — Ciclo de iteracao
- [[GOVERNANCA]] — Rastreabilidade
- Padronizacao UI (repo): `auditoria/PADRONIZACAO_MENU_PRINCIPAL.md` — plano mestre Menu_Principal
