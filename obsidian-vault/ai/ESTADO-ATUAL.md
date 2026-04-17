---
titulo: Estado Atual do Sistema
ultima-atualizacao: 2026-04-17
autor-ultima-alteracao: GPT-5 (Codex)
tags: [vivo, regra]
versao-sistema: V12.0.0187
---

# Estado Atual do Sistema

## Versao

- **Versao**: V12.0.0187
- **Data**: 2026-04-17
- **Status**: EM_VALIDACAO
- **Compila**: Sim
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
- Bateria V2 independente (`Central_Testes_V2`, `Teste_V2_Engine`, `Teste_V2_Roteiros`) com `RESULTADO_QA_V2`, `CATALOGO_CENARIOS_V2` e stress deterministico
- `Central_Testes` simplificada para a transicao: apenas bateria legada + entrada da V2
- V2 recolhe o `Menu_Principal` em toda execucao e navegacao da bateria, inclusive na origem da abertura da central de testes, abre a aba detalhada ao fim e exporta apenas CSV de falhas quando existir erro
- Terminologia MEI eliminada no codigo VBA e no `Menu_Principal` (designer); relatorio **Rel_OSEmpresa** abre sem crash
- Exportacao de CSV de resultados de teste
- Release metadata centralizada (App_Release.bas)
- Rollback operacional para a base estavel da V12.0.0180 preservado em `backups/rollback-post-v180-2026-04-17/`

## O que Precisa de Validacao

- Rodizio por atividade (Svc_Rodizio) — depende de CNAEs + servicos corretos
- Ordens de servico (Svc_PreOS, Svc_OS)
- Migracao de guard rails da interface para os servicos (ENT_ID em Pre-OS, data de OS, justificativa de divergencia)
- Importacao no Excel dos modulos V2 e execucao das macros `CT2_*`

## Riscos Conhecidos

- ProximoId faz protect/unprotect por linha (performance em lotes grandes)
- AtividadeJaExiste usa varredura O(n^2)
- Parte das validacoes de negocio ainda mora na interface; os cenarios `MIG_*` da V2 continuam pendentes ate a migracao
- Emergencia_CNAE, Emergencia_CNAE1/2/3 e Importar_Agora sao modulos temporarios — remover apos estabilizacao

## Proximos Passos

1. Importar a V12.0.0187 no Excel e validar `CT_IniciarBateria`, `CT2_ExecutarSmokeRapido` e `CT2_ExecutarStress`.
2. Migrar para servicos as guardas aprovadas no relatorio V2 (`MIG_001`, `MIG_002`, `MIG_003`).
3. Expandir o catalogo semantico e as suites combinatorias em cima da bateria V2.
4. Manter a bateria legada em shadow mode ate a V2 cobrir o pacote minimo de aprovacao.
5. Limpar modulos temporarios de importacao (`Emergencia_CNAE`, etc.) apos CNAE estavel.
6. Migrar para SaaS (Next.js + NeonDB) — fase futura

## Documentos Relacionados

- [[REGRAS]] — Regras inviolaveis
- [[PIPELINE]] — Ciclo de iteracao
- [[GOVERNANCA]] — Rastreabilidade
- Padronizacao UI (repo): `auditoria/PADRONIZACAO_MENU_PRINCIPAL.md` — plano mestre Menu_Principal
