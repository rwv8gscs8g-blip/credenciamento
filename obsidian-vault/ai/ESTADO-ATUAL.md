---
titulo: Estado Atual do Sistema
ultima-atualizacao: 2026-04-17
autor-ultima-alteracao: GPT-5 (Codex)
tags: [vivo, regra]
versao-sistema: V12.0.0193
---

# Estado Atual do Sistema

## Versao

- **Versao**: V12.0.0193
- **Data**: 2026-04-17
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
- `Cadastro_Servico` passou a reutilizar atividade existente por CNAE normalizado ou descricao, evitando criar CNAEs duplicados na aba `ATIVIDADES`
- `PreenchimentoListaAtividade` passou a esconder duplicidades legadas da lista visual e priorizar a primeira ocorrencia canonica
- `Limpa_Base` passou a chamar `LIMPAR_CADSERV_AGORA`, saneando `ATIVIDADES` e reconstruindo `CAD_SERV` em modo estrutural simples sem duplicidade
- `ResetarECarregarCNAE_Padrao` passou a terminar com `CAD_SERV` simplificada e pronta para uma base apenas com CNAEs
- Terminologia MEI eliminada no codigo VBA e no `Menu_Principal` (designer); relatorio **Rel_OSEmpresa** abre sem crash
- Exportacao de CSV de resultados de teste
- Release metadata centralizada (App_Release.bas)
- Rollback operacional para a base estavel da V12.0.0180 preservado em `backups/rollback-post-v180-2026-04-17/`

## O que Precisa de Validacao

- Rodizio por atividade (Svc_Rodizio) — depende de CNAEs + servicos corretos
- Ordens de servico (Svc_PreOS, Svc_OS, Svc_Avaliacao) apos a migracao das guardas para servico
- Execucao no Excel dos cenarios `MIG_001`, `MIG_002`, `MIG_003` e `MIG_004` dentro do smoke V2
- Revalidacao da bateria oficial nos casos `BO_330*`
- Importacao no Excel dos modulos V2 e execucao das macros `CT2_*`

## Riscos Conhecidos

- ProximoId faz protect/unprotect por linha (performance em lotes grandes)
- AtividadeJaExiste usa varredura O(n^2)
- Ainda existem validacoes operacionais e defaults na interface; a `0191` migra apenas as tres guardas criticas aprovadas para o servico
- Bases historicas com conflito real em `ENTIDADE_INATIVOS` ou `EMPRESAS_INATIVAS` podem agora ser bloqueadas na reativacao ate saneamento manual
- A bateria V2 ainda nao substitui totalmente a legada: a base automatica ficou mais forte, mas ainda faltam atomicidade, edge cases e shadow mode
- A `V12.0.0193` ainda precisa de homologacao no Excel para confirmar compatibilidade da avaliacao, deduplicacao de CNAE e a nova simplificacao da limpeza de base
- Emergencia_CNAE, Emergencia_CNAE1/2/3 e Importar_Agora sao modulos temporarios — remover apos estabilizacao

## Proximos Passos

1. Importar a V12.0.0193 no Excel e reexecutar a bateria oficial focando `BO_330*`.
2. Validar `CT2_ExecutarSmokeRapido`, `CT2_ExecutarSmokeAssistido`, `CT2_ExecutarStress` e `CT2_ExecutarStressAssistido`, agora com `MIG_004`.
3. Validar manualmente que `Cadastro_Servico` nao duplica CNAE ao criar atividade nova ou reaproveitar atividade existente.
4. Rodar `Limpa_Base` e conferir que `ATIVIDADES` fica saneada e `CAD_SERV` termina reconstruida sem duplicidade.
5. Seguir para atomicidade, edge cases e shadow mode da V2.
6. Limpar modulos temporarios de importacao (`Emergencia_CNAE`, etc.) apos CNAE estavel.

## Documentos Relacionados

- [[REGRAS]] — Regras inviolaveis
- [[PIPELINE]] — Ciclo de iteracao
- [[GOVERNANCA]] — Rastreabilidade
- Padronizacao UI (repo): `auditoria/PADRONIZACAO_MENU_PRINCIPAL.md` — plano mestre Menu_Principal
