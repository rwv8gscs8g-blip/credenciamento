---
titulo: Debito Tecnico CNAE e CAD_SERV
ultima-atualizacao: 2026-04-17
autor-ultima-alteracao: GPT-5 (Codex)
tags: [debito, cnae, cad_serv, backlog]
---

# Debito Tecnico CNAE e CAD_SERV

## Decisao

O redesenho de `CNAE/CAD_SERV` foi retirado do escopo da estabilizacao atual. A `V12.0.0194` reverteu o experimento da `0193` para nao interromper as fases da auditoria do Opus.

## Motivo

- a regressao observada foi operacional, nao de regra de negocio central
- a bateria oficial estava limpa, entao o foco correto continua sendo estabilizacao de servicos, atomicidade e testes
- `CNAE/CAD_SERV` exige decisao funcional explicita antes de novo desenvolvimento

## O que foi revertido na 0194

- deduplicacao estrutural automatica na lista de atividades
- saneamento automatico de `ATIVIDADES`
- reconstrução automatica de `CAD_SERV` dentro de `Limpa_Base`
- fechamento de `ResetarECarregarCNAE_Padrao` com base estrutural simplificada

## O que ficou preservado

- importacao emergencial de CNAE
- reset padrao de CNAE com limpeza de associacoes em `CAD_SERV`
- comportamento legado de cadastro e manutencao operacional

## Perguntas que precisam ser respondidas antes de nova iteracao

1. `ATIVIDADES` deve ser permanente ou suportar reimportacao total por botao dedicado?
2. `CAD_SERV` deve ser preservada, zerada ou reconstruida ao limpar base?
3. existe contrato formal de unicidade por `CNAE`, por descricao ou por ambos?
4. o usuario quer separacao entre importacao de CNAE e associacao manual de servicos?

## Requisitos minimos para uma futura solucao

- decisao funcional aprovada antes de editar o codigo
- testes automatizados cobrindo importacao, listagem, cadastro de servico e limpeza de base
- validacao assistida no Excel com base real
- nenhum impacto nas fases de estabilizacao de regra de negocio e atomicidade

## Regra para a proxima IA

Nao retomar `CNAE/CAD_SERV` por inferencia. Tratar apenas mediante aprovacao explicita do plano funcional pelo revisor humano.
