---
titulo: Estado Atual do Sistema
ultima-atualizacao: 2026-04-17
autor-ultima-alteracao: GPT-5 (Codex)
tags: [vivo, regra]
versao-sistema: V12.0.0192
---

# Estado Atual do Sistema

## Versao

- **Versao**: V12.0.0192
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
- Bateria oficial de testes (resultados em `RESULTADO_QA`; ultima execucao pode ter falhas pontuais — investigar antes de promover)
- Bateria V2 independente (`Central_Testes_V2`, `Teste_V2_Engine`, `Teste_V2_Roteiros`) com `RESULTADO_QA_V2`, `CATALOGO_CENARIOS_V2`, `ROTEIRO_ASSISTIDO_V2` e stress deterministico
- `Central_Testes` simplificada para a transicao: apenas bateria legada + entrada da V2
- V2 descarrega a instancia real do `Menu_Principal` em toda execucao e navegacao da bateria, inclusive antes de abrir a central V2, e exporta apenas CSV de falhas quando existir erro
- V2 passou a validar cenario deterministico completo sobre reset operacional, configuracao canonica, servicos canonicos e contrato real da fila (ordem integra, nao renumeracao forcada)
- V2 passou a medir registros por coluna-chave semantica e a validar imediatamente o reset das abas operacionais
- Central V2 reorganizada em automatico + assistido: smoke rapido, smoke assistido, stress deterministico, stress assistido e roteiro humano dedicado
- `Svc_PreOS` passou a validar `ENT_ID` ativo e `QT_ESTIMADA > 0` sem depender do formulario
- `Svc_OS` passou a validar `DT_PREV_TERMINO >= hoje` no proprio servico
- `Svc_Avaliacao` passou a validar `QtExecutada > 0` e justificativa obrigatoria quando ha divergencia entre executado e orcado
- Os cenarios `MIG_001`, `MIG_002` e `MIG_003` deixaram de ser manuais e passaram a ser assertivos no smoke da V2
- Fluxos de inativacao/reativacao passaram a higienizar duplicidades nas abas `*_INATIVOS`, preferir a linha mais recente e bloquear reativacao quando houver conflito semantico na mesma chave
- Terminologia MEI eliminada no codigo VBA e no `Menu_Principal` (designer); relatorio **Rel_OSEmpresa** abre sem crash
- Exportacao de CSV de resultados de teste
- Release metadata centralizada (App_Release.bas)
- Rollback operacional para a base estavel da V12.0.0180 preservado em `backups/rollback-post-v180-2026-04-17/`

## O que Precisa de Validacao

- Rodizio por atividade (Svc_Rodizio) — depende de CNAEs + servicos corretos
- Ordens de servico (Svc_PreOS, Svc_OS, Svc_Avaliacao) apos a migracao das guardas para servico
- Execucao no Excel dos cenarios `MIG_001`, `MIG_002` e `MIG_003` dentro do smoke V2
- Importacao no Excel dos modulos V2 e execucao das macros `CT2_*`

## Riscos Conhecidos

- ProximoId faz protect/unprotect por linha (performance em lotes grandes)
- AtividadeJaExiste usa varredura O(n^2)
- Ainda existem validacoes operacionais e defaults na interface; a `0191` migra apenas as tres guardas criticas aprovadas para o servico
- Bases historicas com conflito real em `ENTIDADE_INATIVOS` ou `EMPRESAS_INATIVAS` podem agora ser bloqueadas na reativacao ate saneamento manual
- A bateria V2 ainda nao substitui totalmente a legada: a base automatica ficou mais forte, mas ainda faltam atomicidade, edge cases e shadow mode
- A `V12.0.0192` ainda precisa de homologacao no Excel para confirmar o endurecimento de inativacao/reativacao
- Emergencia_CNAE, Emergencia_CNAE1/2/3 e Importar_Agora sao modulos temporarios — remover apos estabilizacao

## Proximos Passos

1. Importar a V12.0.0192 no Excel e validar `CT2_ExecutarSmokeRapido`, `CT2_ExecutarSmokeAssistido`, `CT2_ExecutarStress` e `CT2_ExecutarStressAssistido`.
2. Validar manualmente inativacao e reativacao de entidade e empresa sobre base limpa e sobre base com duplicidade historica.
3. Iniciar a fase seguinte de atomicidade, edge cases e testes complementares sobre a V2.
4. Manter a bateria legada em shadow mode ate a V2 cobrir o pacote minimo de aprovacao.
5. Limpar modulos temporarios de importacao (`Emergencia_CNAE`, etc.) apos CNAE estavel.
6. Migrar para SaaS (Next.js + NeonDB) — fase futura

## Documentos Relacionados

- [[REGRAS]] — Regras inviolaveis
- [[PIPELINE]] — Ciclo de iteracao
- [[GOVERNANCA]] — Rastreabilidade
- Padronizacao UI (repo): `auditoria/PADRONIZACAO_MENU_PRINCIPAL.md` — plano mestre Menu_Principal
