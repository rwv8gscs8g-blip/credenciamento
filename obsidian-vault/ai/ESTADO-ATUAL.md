---
titulo: Estado Atual do Sistema
ultima-atualizacao: 2026-04-17
autor-ultima-alteracao: GPT-5.2 (Cursor)
tags: [vivo, regra]
versao-sistema: V12.0.0180
---

# Estado Atual do Sistema

## Versao

- **Versao**: V12.0.0180
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
- Terminologia MEI eliminada no codigo VBA e no `Menu_Principal` (designer); relatorio **Rel_OSEmpresa** abre sem crash
- Exportacao de CSV de resultados de teste
- Release metadata centralizada (App_Release.bas)

## O que Precisa de Validacao

- Lista de servicos na SV_Lista (verificar se carrega sem duplicatas)
- Rodizio por atividade (Svc_Rodizio) — depende de CNAEs + servicos corretos
- Ordens de servico (Svc_PreOS, Svc_OS)
- Relatorios (Rel_Emp_Serv, Rel_OSEmpresa)
- CargaInicialCNAE_SeNecessario — comportamento apos importacao emergencial

## Riscos Conhecidos

- ProximoId faz protect/unprotect por linha (performance em lotes grandes)
- AtividadeJaExiste usa varredura O(n^2)
- CargaInicialCNAE_SeNecessario roda em todo PreenchimentoListaAtividade (linha 1555)
- Emergencia_CNAE, Emergencia_CNAE1/2/3 e Importar_Agora sao modulos temporarios — remover apos estabilizacao

## Proximos Passos

1. **Homologacao**: na planilha `RESULTADO_QA`, tratar cada linha **FALHA** (ex.: filtro por status), reexecutar caso ou ajustar codigo/dados de teste; registrar versao no relatorio da Central.
2. **MEI remanescente (opcional)**: no designer, renomear controles ainda legados em `Altera_Empresa` e labels em `Menu_Principal` conforme `auditoria/INSTRUCOES_RENOMEAR_DESIGNER.md` (secao Altera_Empresa + `R_TelMEI` / `AM_Empresamei`).
3. Validar servicos e rodizio com dados reais (Svc_Rodizio, SV_Lista sem duplicatas).
4. Limpar modulos temporarios de importacao (`Emergencia_CNAE`, etc.) apos CNAE estavel.
5. Estabilizar fluxo completo: Empresa > Atividade > Servico > Rodizio > OS
6. Migrar para SaaS (Next.js + NeonDB) — fase futura

## Documentos Relacionados

- [[REGRAS]] — Regras inviolaveis
- [[PIPELINE]] — Ciclo de iteracao
- [[GOVERNANCA]] — Rastreabilidade
- Padronizacao UI (repo): `auditoria/PADRONIZACAO_MENU_PRINCIPAL.md` — plano mestre Menu_Principal
