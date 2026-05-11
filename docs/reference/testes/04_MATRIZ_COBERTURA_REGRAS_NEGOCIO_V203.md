---
titulo: Matriz de Cobertura Regras de Negocio V203
diataxis: reference
hbn-track: fast_track
hbn-status: archived
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-04
---

# Matriz de Cobertura Regras de Negocio V203

> Documento historico. A matriz vigente da V12.0.0204 e
> [04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md](04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md).

Esta matriz mostra a cobertura funcional consolidada para a `V12.0.0203`.
Ela deve ser expandida na `V12.0.0204` com analise combinatoria formal.

## Matriz resumida

| Regra | Cobertura V203 | Suite | Evidencia |
|---|---|---|---|
| empresa pode ser cadastrada e listada | coberta | V1, V2 Canonica | Quinteto rc4 |
| entidade pode ser cadastrada e listada | coberta | V1, V2 Canonica | Quinteto rc4 |
| servico/atividade podem compor credenciamento | coberta parcial | V2 Canonica | Quinteto rc4 |
| rodizio seleciona empresa elegivel | coberta | V2, E2E Strikes | Quinteto rc4 |
| recusa avanca fila | coberta | E2E Strikes | Quinteto rc4 |
| tres strikes suspendem empresa | coberta | E2E Strikes | Quinteto rc4 |
| reativacao preserva historico total | coberta | E2E Strikes | `CS_E2E_REATIV2STRIKES` |
| reativacao reinicia janela punitiva | coberta | E2E Strikes | `CS_E2E_REATIV2STRIKES` |
| classificacao de empresa preserva `DT_ULT_REATIV` | coberta por regressao | V2 Canonica | `CS_23` |
| integridade detecta referencias orfas | coberta | IntegridadeBase | `CS_INT_04` |
| interface de reativacao evita bypass de regra | coberta parcial | V2 Canonica | MICRO30 R1/fix1 |
| mensagens de erro explicam origem | debito | V204 | plano V204 |
| reentrada por duplo clique | debito | V204 | plano V204 |
| backfill auditavel de dados legados | debito | V204 | plano V204 |

## Cobertura combinatoria atual

| Eixo | Valores exercitados | Lacunas para V204 |
|---|---|---|
| status empresa | ativa, inativa, suspensa | transicoes repetidas e no-op auditado |
| strikes | zero, um, tres, pos-reativacao | datas invalidas e fechamento ausente |
| rodizio | selecao, recusa, suspensao | concorrencia/reentrada por UI |
| dados | canonico limpo, referencia orfa | massa historica migrada |
| importacao | V3 delta e C4 | publicacao limpa sem pacote interno |

## Regra de evolucao

Para a V204, cada nova regra deve entrar com:

1. nome da regra;
2. arquivo de implementacao;
3. cenario automatizado;
4. cenario manual, quando houver UI;
5. evidencia esperada;
6. criterio de bloqueio.
