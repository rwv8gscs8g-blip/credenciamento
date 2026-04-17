---
titulo: Estado Atual do Sistema
ultima-atualizacao: 2026-04-17
autor-ultima-alteracao: GPT-5 (Codex)
tags: [vivo, regra]
versao-sistema: V12.0.0190
---

# Estado Atual do Sistema

## Versao

- **Versao**: V12.0.0190
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
- A bateria V2 ainda nao substitui totalmente a legada: ela agora tem semantica mais clara e diagnostico melhor, mas a migracao UI -> servico segue como dependencia para fechamento completo
- A `V12.0.0190` ainda precisa de homologacao no Excel para confirmar que o fatal estrutural de baseline foi eliminado
- Emergencia_CNAE, Emergencia_CNAE1/2/3 e Importar_Agora sao modulos temporarios — remover apos estabilizacao

## Proximos Passos

1. Importar a V12.0.0190 no Excel e validar `CT_IniciarBateria`, `CT2_AbrirCentral`, `CT2_ExecutarSmokeRapido`, `CT2_ExecutarSmokeAssistido`, `CT2_ExecutarStress` e `CT2_ExecutarStressAssistido`.
2. Se o fatal estrutural da baseline desaparecer, iniciar a fase de migracao `UI -> servico` para `MIG_001`, `MIG_002` e `MIG_003`.
3. Expandir o catalogo semantico e as suites combinatorias em cima da bateria V2.
4. Manter a bateria legada em shadow mode ate a V2 cobrir o pacote minimo de aprovacao.
5. Limpar modulos temporarios de importacao (`Emergencia_CNAE`, etc.) apos CNAE estavel.
6. Migrar para SaaS (Next.js + NeonDB) — fase futura

## Documentos Relacionados

- [[REGRAS]] — Regras inviolaveis
- [[PIPELINE]] — Ciclo de iteracao
- [[GOVERNANCA]] — Rastreabilidade
- Padronizacao UI (repo): `auditoria/PADRONIZACAO_MENU_PRINCIPAL.md` — plano mestre Menu_Principal
