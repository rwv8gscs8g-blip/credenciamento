---
titulo: Matriz de Cobertura Regras de Negócio V204
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-12
---

# Matriz de Cobertura Regras de Negócio V204

Esta matriz traduz a cobertura final da V12.0.0204 para leitura humana. O
documento canônico das regras fica em
[../regras/REGRAS_DE_NEGOCIO_V204.md](../regras/REGRAS_DE_NEGOCIO_V204.md).
A rastreabilidade técnica detalhada fica em
[06_MATRIZ_RASTREABILIDADE_TESTES_V204.md](06_MATRIZ_RASTREABILIDADE_TESTES_V204.md).

## Gate oficial V204

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

Evidência final de publicação: `VR_20260511_154433`.
Evidência adicional após App_Release final: `VR_20260511_175849`.

## Cobertura por regra

| Regra de negócio | Cobertura V204 | Suíte / roteiro | Evidência |
|---|---|---|---|
| Empresa pode ser cadastrada e listada | Coberta | V1, V2 Canônica, roteiro M-03 | Sexteto V204 |
| Entidade pode ser cadastrada e listada | Coberta | V1, V2 Canônica, roteiro M-02 | Sexteto V204 |
| Serviço/atividade podem compor credenciamento | Coberta | V2 Smoke `MIG_009`, roteiro M-04/M-05/M-06 | MICRO53-fix2 + Sexteto V204 |
| Rodízio seleciona empresa elegível | Coberta | V2 Canônica, E2E Strikes, roteiro M-07 | Sexteto V204 |
| Recusa avança fila de forma auditável | Coberta | E2E Strikes | Sexteto V204 |
| Empresa inativa, suspensa, com OS aberta ou Pré-OS pendente é pulada | Coberta | V2 Canônica, E2E Strikes | Sexteto V204 |
| Avaliação negativa registra strike | Coberta | E2E Strikes, roteiro M-09 | Sexteto V204 |
| Três strikes suspendem empresa conforme configuração | Coberta | E2E Strikes, `MIG_008` | Sexteto V204 |
| Reativação preserva histórico total | Coberta | `CS_REATIV_AUDIT_DUAL_COUNTER`, roteiro M-11 | MICRO48 + Sexteto V204 |
| Reativação reinicia janela punitiva | Coberta | E2E Strikes, Boundary Dates | Onda23Adv |
| Classificação preserva `DT_ULT_REATIV` na linha correta | Coberta por regressão | V2 Canônica | Sexteto V204 |
| Integridade detecta referências órfãs reais | Coberta | IntegridadeBase | Sexteto V204 |
| Resíduos legados sem chave são tratados como limpeza auditável | Coberta | IntegridadeBase / MICRO38 | Sexteto V204 |
| Mensagens de erro explicam origem operacional | Coberta para os fluxos endurecidos | Smoke `MIG_008`, roteiro manual | V204 |
| Reentrada por duplo clique em UI mutadora | Coberta | `ADVERSARIAL_UI` | Onda23Adv |
| Transação aninhada não corrompe estado | Coberta | `TRANSACAO_INTERRUPT` | Onda23Adv |
| Datas de OS/avaliação em bordas temporais | Coberta | `BOUNDARY_DATES` | Onda23Adv |
| Limpar Base preserva CNAE e limpa `CAD_SERV` | Coberta | Smoke `MIG_009`, roteiro M-12/M-13/M-14 | MICRO53-fix2 |
| Vitrine pública aponta para teste humano correto | Coberta documentalmente | MICRO56/MICRO57/MICRO58 | Guias V204 |

## Débitos V203 fechados na V204

| Débito histórico | Status V204 | Evidência |
|---|---|---|
| Mensagens vagas em configuração de strikes | Fechado | MICRO47 / `MIG_008` |
| Reentrada por duplo clique | Fechado para fluxos cobertos | Onda23 `ADVERSARIAL_UI` |
| Backfill e dados legados auditáveis | Fechado nos pontos planejados | MICRO37, MICRO38, MICRO39 |
| Bordas temporais de strikes | Fechado | MICRO40 + Onda23 `BOUNDARY_DATES` |
| Limpeza para reuso municipal | Fechado | MICRO53-fix2 + roteiro manual V204 |

## Débitos aceitos para V205

| Débito | Destino |
|---|---|
| Renomear publicamente a taxonomia "Sexteto" para nomenclatura profissional de testes | V12.0.0205 |
| Reordenar e simplificar a Central de Testes para testador humano | V12.0.0205 |
| Corrigir prefixo histórico `V12_0_0203` no nome do CSV de validação | V12.0.0205 |
| Reavaliar MD-24.4 `SelecionarEmpresa` sem reaproveitar artefatos MICRO49 | V12.0.0205 |
| Lapidar G1/G2/G5 residuais do `glasswing-checks.sh --strict` | V12.0.0205 |
