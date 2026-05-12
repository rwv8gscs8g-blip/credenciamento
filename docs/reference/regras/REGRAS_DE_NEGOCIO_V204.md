---
titulo: Regras de Negócio V204
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-12
---

# Regras de Negócio V204

Este é o documento público canônico das regras de negócio da V12.0.0204. Ele
separa as regras funcionais do sistema das regras operacionais do HBN e indica
como a bateria de testes garante cada comportamento.

O contrato completo de teste da release está em:

- [Matriz de Cobertura Regras de Negócio V204](../testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md)
- [Matriz de Rastreabilidade de Testes V204](../testes/06_MATRIZ_RASTREABILIDADE_TESTES_V204.md)
- [Roteiro de Teste Manual V204](../testes/07_ROTEIRO_TESTE_MANUAL_V204.md)

## Regra RN-01 — Credenciamento depende de empresa, entidade, atividade e serviço válidos

Uma empresa só pode participar do rodízio quando estiver cadastrada, ativa e
credenciada para uma atividade/serviço existente.

Garantia V204: V1, V2 Canônica, roteiro M-02 a M-06 e IntegridadeBase.

## Regra RN-02 — Rodízio escolhe empresa apta da vez

O sistema deve selecionar a empresa apta da vez dentro da fila do serviço,
sem favorecer manualmente uma empresa específica.

Garantia V204: V2 Canônica, E2E Strikes e roteiro M-07.

## Regra RN-03 — Empresas impedidas são puladas sem quebrar a fila

Empresa inativa, suspensa, com OS aberta ou com Pré-OS pendente não deve ser
selecionada enquanto o impedimento existir.

Garantia V204: V2 Canônica, E2E Strikes, IntegridadeBase e roteiro M-07/M-10.

## Regra RN-04 — Recusa e expiração de Pré-OS têm efeito operacional auditável

Quando uma Pré-OS é recusada ou expira, o avanço da fila deve ser registrado e
o sistema deve continuar apto a selecionar a próxima empresa elegível.

Garantia V204: E2E Strikes e trilha `AUDIT_LOG`.

## Regra RN-05 — Pré-OS aceita gera OS de forma rastreável

Aceitar uma Pré-OS deve produzir uma OS vinculada à mesma demanda e à mesma
empresa, preservando rastreabilidade operacional.

Garantia V204: V2 Canônica, E2E Strikes e roteiro M-08.

## Regra RN-06 — OS aberta bloqueia nova indicação no mesmo contexto

Empresa com OS aberta no contexto operacional testado não deve receber nova
indicação que viole a fila e a pendência existente.

Garantia V204: V2 Canônica, E2E Strikes e IntegridadeBase.

## Regra RN-07 — Avaliação negativa registra justificativa e strike

Avaliação abaixo da nota mínima deve exigir justificativa, registrar strike e
manter evidência auditável.

Garantia V204: E2E Strikes, Smoke `MIG_008` e roteiro M-09.

## Regra RN-08 — Três strikes suspendem conforme configuração vigente

Quando a configuração de strikes é atingida, a empresa deve ser suspensa pelo
prazo configurado.

Garantia V204: E2E Strikes, Smoke `MIG_008` e Boundary Dates.

## Regra RN-09 — Suspensão não deve penalizar duas vezes a empresa

Após cumprir suspensão ou ser reativada conforme regra operacional, a empresa
deve retornar sem perder seu histórico total e sem punição duplicada por perda
artificial de turno.

Garantia V204: E2E Strikes, `CS_REATIV_AUDIT_DUAL_COUNTER`, Boundary Dates e
roteiro M-11.

## Regra RN-10 — Reativação preserva histórico total e janela punitiva correta

A reativação deve diferenciar histórico total de strikes e contador ativo da
janela punitiva.

Garantia V204: MICRO48, E2E Strikes, Boundary Dates e roteiro M-11.

## Regra RN-11 — Auditoria registra ações com efeito de estado

Cadastros, emissão de Pré-OS, aceite, OS, avaliação, suspensão, reativação e
limpeza administrativa devem deixar evidência em trilha auditável.

Garantia V204: V1, V2 Canônica, E2E Strikes, IntegridadeBase e roteiro manual.

## Regra RN-12 — Integridade estrutural deve detectar resíduos relevantes

Referências órfãs, dados legados sem chave e inconsistências estruturais não
devem passar silenciosamente quando forem relevantes para a operação.

Garantia V204: IntegridadeBase, MICRO37, MICRO38 e MICRO39.

## Regra RN-13 — Interface não deve aceitar reentrada mutadora insegura

Cliques repetidos ou duplo clique em fluxos mutadores não devem corromper
estado nem duplicar efeitos críticos.

Garantia V204: Onda23Adv `ADVERSARIAL_UI`.

## Regra RN-14 — Transação interrompida não pode deixar estado parcial

Fluxo transacional interrompido deve rejeitar estado parcial e preservar a
consistência da base.

Garantia V204: Onda23Adv `TRANSACAO_INTERRUPT`.

## Regra RN-15 — Bordas temporais devem preservar coerência de avaliação e suspensão

Datas em bordas operacionais, inclusive virada de período e datas especiais,
não devem quebrar cálculo de suspensão, avaliação ou elegibilidade.

Garantia V204: Onda23Adv `BOUNDARY_DATES`.

## Regra RN-16 — Limpar Base prepara a planilha para outro município

Limpar Base deve remover dados operacionais, preservar `ATIVIDADES`/CNAE e
`CONFIG`, zerar `CAD_SERV` com cabeçalho preservado e permitir novo cadastro de
serviços após a limpeza.

Garantia V204: Smoke `MIG_009`, roteiro M-12/M-13/M-14 e validação manual do
operador em MICRO53-fix2.

## Regra RN-17 — A planilha validada deve ser testável por interface

O testador humano externo deve conseguir validar a release pela tela inicial,
botão **Central de Testes**, botão **Sobre** e formulários da planilha, sem
abrir Editor VBA ou Janela Imediata.

Garantia V204: MICRO56, MICRO57, guia humano V204 e roteiro manual V204.

## Matriz resumida de garantia

| Regra | Automático | Manual | Evidência principal |
|---|---|---|---|
| RN-01 | V1, V2 Canônica, IntegridadeBase | M-02 a M-06 | Sexteto V204 |
| RN-02 | V2 Canônica, E2E Strikes | M-07 | Sexteto V204 |
| RN-03 | V2 Canônica, E2E Strikes | M-07/M-10 | Sexteto V204 |
| RN-04 | E2E Strikes | M-08 | Sexteto V204 |
| RN-05 | V2 Canônica, E2E Strikes | M-08 | Sexteto V204 |
| RN-06 | V2 Canônica, IntegridadeBase | M-07/M-08 | Sexteto V204 |
| RN-07 | E2E Strikes, Smoke | M-09 | Sexteto V204 |
| RN-08 | E2E Strikes, Boundary Dates | M-10 | Sexteto V204 |
| RN-09 | E2E Strikes, Dual Counter | M-11 | MICRO48 + Sexteto |
| RN-10 | E2E Strikes, Boundary Dates | M-11 | Sexteto V204 |
| RN-11 | V1, V2, E2E | Roteiro completo | Sexteto V204 |
| RN-12 | IntegridadeBase | Revisão de relatório | Sexteto V204 |
| RN-13 | Onda23Adv | Observação de UI | Sexteto V204 |
| RN-14 | Onda23Adv | Não exigido | Sexteto V204 |
| RN-15 | Onda23Adv | Não exigido | Sexteto V204 |
| RN-16 | Smoke `MIG_009` | M-12 a M-14 | MICRO53-fix2 |
| RN-17 | Documental | Guia humano | MICRO56/MICRO57 |

## Débitos explícitos para V12.0.0205

1. Renomear a taxonomia pública "Sexteto", "Quinteto" e "Quarteto" para nomes
   profissionais de engenharia de software.
2. Reordenar a Central de Testes para que a validação completa de release seja
   a primeira opção clara para humanos.
3. Migrar a pasta técnica `doc/` para uma arquitetura de dados mais clara, sem
   quebrar os caminhos CNAE usados pelo VBA.
4. Reavaliar MD-24.4 sem reaproveitar os artefatos MICRO49.
