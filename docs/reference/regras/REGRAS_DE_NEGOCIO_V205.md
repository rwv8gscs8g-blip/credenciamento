---
titulo: Regras de Negócio V205
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-21
---

# Regras de Negócio — V12.0.0205

A V12.0.0205 não altera regras de negócio. Este documento é uma reedição de
governança da V204, com atualização de nomenclatura de testes e links de
rastreabilidade.

## Regra de Imutabilidade

Os IDs RN-01 a RN-17 permanecem congelados. Nenhuma regra de rodízio,
credenciamento, Pre-OS, OS, avaliação, strike, suspensão, reativação, cálculo
ou integridade de base foi alterada nesta versão.

## Fonte Base e Mudança de Vocabulário

A base semântica permanece em `docs/reference/regras/REGRAS_DE_NEGOCIO_V204.md`.
A V205 consolida as mesmas regras em um documento único e atualiza apenas a
forma de garantia:

- `Sexteto Mínimo` passa a ser apresentado como `Gate de Validação de Release (RVS)`;
- `Quinteto` passa a ser apresentado como `Suíte de Regressão Consolidada (SRC)`;
- `Quarteto Direto` passa a ser apresentado como `Bateria Rápida Legada (BRL)`.

## Guarda Funcional

A aprovação funcional da V205 exige a mesma sintaxe consolidada da V204:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

Qualquer divergência numérica é regressão funcional e bloqueia a release.

## RN-01 — Credenciamento depende de empresa, entidade, atividade e serviço válidos

Uma empresa só pode participar do rodízio quando estiver cadastrada, ativa e
credenciada para uma atividade/serviço existente.

Garantia V205: RVS, SRC, V2 Canônica, roteiro humano e IntegridadeBase.

## RN-02 — Rodízio escolhe empresa apta da vez

O sistema deve selecionar a empresa apta da vez dentro da fila do serviço, sem
favorecimento manual de empresa específica.

Garantia V205: RVS, V2 Canônica, E2E Strikes e jornada humana.

## RN-03 — Empresas impedidas são puladas sem quebrar a fila

Empresa inativa, suspensa, com OS aberta ou com Pré-OS pendente não deve ser
selecionada enquanto o impedimento existir.

Garantia V205: RVS, V2 Canônica, E2E Strikes, IntegridadeBase e jornada humana.

## RN-04 — Recusa e expiração de Pré-OS têm efeito operacional auditável

Quando uma Pré-OS é recusada ou expira, o avanço da fila deve ser registrado e
o sistema deve continuar apto a selecionar a próxima empresa elegível.

Garantia V205: RVS, E2E Strikes e trilha `AUDIT_LOG`.

## RN-05 — Pré-OS aceita gera OS de forma rastreável

Aceitar uma Pré-OS deve produzir uma OS vinculada à mesma demanda e à mesma
empresa, preservando rastreabilidade operacional.

Garantia V205: RVS, V2 Canônica, E2E Strikes e jornada humana.

## RN-06 — OS aberta bloqueia nova indicação no mesmo contexto

Empresa com OS aberta no contexto operacional testado não deve receber nova
indicação que viole a fila e a pendência existente.

Garantia V205: RVS, V2 Canônica, E2E Strikes e IntegridadeBase.

## RN-07 — Avaliação negativa registra justificativa e strike

Avaliação abaixo da nota mínima deve exigir justificativa, registrar strike e
manter evidência auditável.

Garantia V205: RVS, E2E Strikes, Smoke `MIG_008` e jornada humana.

## RN-08 — Três strikes suspendem conforme configuração vigente

Quando a configuração de strikes é atingida, a empresa deve ser suspensa pelo
prazo configurado.

Garantia V205: RVS, E2E Strikes, Smoke `MIG_008` e Boundary Dates.

## RN-09 — Suspensão não deve penalizar duas vezes a empresa

Após cumprir suspensão ou ser reativada conforme regra operacional, a empresa
deve retornar sem perder seu histórico total e sem punição duplicada por perda
artificial de turno.

Garantia V205: RVS, E2E Strikes, `CS_REATIV_AUDIT_DUAL_COUNTER`, Boundary
Dates e jornada humana.

## RN-10 — Reativação preserva histórico total e janela punitiva correta

A reativação deve diferenciar histórico total de strikes e contador ativo da
janela punitiva.

Garantia V205: RVS, MICRO48, E2E Strikes, Boundary Dates e jornada humana.

## RN-11 — Auditoria registra ações com efeito de estado

Cadastros, emissão de Pré-OS, aceite, OS, avaliação, suspensão, reativação e
limpeza administrativa devem deixar evidência em trilha auditável.

Garantia V205: RVS, SRC, V1, V2 Canônica, E2E Strikes, IntegridadeBase e
jornada humana.

## RN-12 — Integridade estrutural deve detectar resíduos relevantes

Referências órfãs, dados legados sem chave e inconsistências estruturais não
devem passar silenciosamente quando forem relevantes para a operação.

Garantia V205: RVS, IntegridadeBase, MICRO37, MICRO38 e MICRO39.

## RN-13 — Interface não deve aceitar reentrada mutadora insegura

Cliques repetidos ou duplo clique em fluxos mutadores não devem corromper
estado nem duplicar efeitos críticos.

Garantia V205: RVS e bloco adversarial `ADVERSARIAL_UI`.

## RN-14 — Transação interrompida não pode deixar estado parcial

Fluxo transacional interrompido deve rejeitar estado parcial e preservar a
consistência da base.

Garantia V205: RVS e bloco adversarial `TRANSACAO_INTERRUPT`.

## RN-15 — Bordas temporais devem preservar coerência de avaliação e suspensão

Datas em bordas operacionais, inclusive virada de período e datas especiais,
não devem quebrar cálculo de suspensão, avaliação ou elegibilidade.

Garantia V205: RVS e bloco adversarial `BOUNDARY_DATES`.

## RN-16 — Limpar Base prepara a planilha para outro município

Limpar Base deve remover dados operacionais, preservar `ATIVIDADES`/CNAE e
`CONFIG`, zerar `CAD_SERV` com cabeçalho preservado e permitir novo cadastro de
serviços após a limpeza.

Garantia V205: RVS, Smoke `MIG_009`, jornada humana e validação manual do
operador em MICRO53-fix2.

## RN-17 — A planilha validada deve ser testável por interface

O testador humano externo deve conseguir validar a release pela tela inicial,
botão **Central de Testes**, botão **Sobre** e formulários da planilha, sem
abrir Editor VBA ou Janela Imediata.

Garantia V205: Jornada de Validação Humana V205, RVS pela interface, guia do
gate e dossiê de release.

## Matriz Resumida de Garantia

| Regra | Automático | Manual | Evidência principal |
|---|---|---|---|
| RN-01 | RVS, SRC, V2 Canônica, IntegridadeBase | Jornada V205 | CSV RVS + manifesto |
| RN-02 | RVS, V2 Canônica, E2E Strikes | Jornada V205 | CSV RVS + manifesto |
| RN-03 | RVS, V2 Canônica, E2E Strikes, IntegridadeBase | Jornada V205 | CSV RVS + manifesto |
| RN-04 | RVS, E2E Strikes | Jornada V205 | CSV RVS + `AUDIT_LOG` |
| RN-05 | RVS, V2 Canônica, E2E Strikes | Jornada V205 | CSV RVS |
| RN-06 | RVS, V2 Canônica, IntegridadeBase | Jornada V205 | CSV RVS |
| RN-07 | RVS, E2E Strikes, Smoke | Jornada V205 | CSV RVS |
| RN-08 | RVS, E2E Strikes, Boundary Dates | Jornada V205 | CSV RVS |
| RN-09 | RVS, E2E Strikes, Dual Counter | Jornada V205 | CSV RVS + MICRO48 |
| RN-10 | RVS, E2E Strikes, Boundary Dates | Jornada V205 | CSV RVS |
| RN-11 | RVS, SRC, V1, V2, E2E | Jornada completa | CSV RVS + manifesto |
| RN-12 | RVS, IntegridadeBase | Revisão de relatório | CSV RVS |
| RN-13 | RVS, Onda23Adv | Observação de UI | CSV RVS |
| RN-14 | RVS, Onda23Adv | Não exigido | CSV RVS |
| RN-15 | RVS, Onda23Adv | Não exigido | CSV RVS |
| RN-16 | RVS, Smoke `MIG_009` | Jornada V205 | CSV RVS + PDF/print manual |
| RN-17 | RVS pela interface | Jornada V205 | Checklist humano + dossiê |

## Débitos Diferidos

V12.0.0206:

1. Automatizar PDF com tratamento robusto de erro.
2. Reavaliar MD-24.4 sem reaproveitar os artefatos MICRO49.
3. Incorporar ajustes incrementais que surgirem nos testes manuais.
4. Lapidar pequenos débitos técnicos sem refatoração profunda.

V12.0.0207 ou roadmap posterior:

1. Refatorar nomes internos de símbolos VBA, se ainda fizer sentido.
2. Migrar a pasta técnica `doc/` para arquitetura de dados mais clara sem
   quebrar caminhos CNAE usados pelo VBA.
3. Iniciar revisão arquitetural para componentização, performance e estratégia
   SaaS.

## Referências

- `docs/reference/testes/NOMENCLATURA_BATERIAS_V205.md`
- `docs/reference/testes/09_MATRIZ_COBERTURA_TESTES_V205.md`
- `docs/tutorials/JORNADA_VALIDACAO_HUMANA_V205.md`
