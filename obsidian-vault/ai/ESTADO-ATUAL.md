---
titulo: Estado Atual do Sistema
ultima-atualizacao: 2026-04-15
autor-ultima-alteracao: GPT-5.2 (Cursor)
tags: [vivo, regra]
versao-sistema: V12.0.0166
---

# Estado Atual do Sistema

## Versao

- **Versao**: V12.0.0166
- **Data**: 2026-04-15
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
- Bateria oficial de testes (0 falhas na ultima execucao estavel)
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

1. Validar servicos e rodizio com dados reais
2. Limpar modulos temporarios de importacao
3. Estabilizar fluxo completo: Empresa > Atividade > Servico > Rodizio > OS
4. Migrar para SaaS (Next.js + NeonDB) — fase futura

## Documentos Relacionados

- [[REGRAS]] — Regras inviolaveis
- [[PIPELINE]] — Ciclo de iteracao
- [[GOVERNANCA]] — Rastreabilidade
