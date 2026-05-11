---
titulo: Matriz de Cobertura Regras de Negocio V204
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-11
---

# Matriz de Cobertura Regras de Negocio V204

Esta matriz traduz a cobertura final da V12.0.0204 para leitura humana. A
rastreabilidade tecnica detalhada fica em
[06_MATRIZ_RASTREABILIDADE_TESTES_V204.md](06_MATRIZ_RASTREABILIDADE_TESTES_V204.md).

## Gate oficial V204

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

Evidencia final de publicacao: `VR_20260511_154433`.
Evidencia adicional apos App_Release final: `VR_20260511_175849`.

## Cobertura por regra

| Regra de negocio | Cobertura V204 | Suite / roteiro | Evidencia |
|---|---|---|---|
| Empresa pode ser cadastrada e listada | Coberta | V1, V2 Canonica, roteiro M-03 | Sexteto V204 |
| Entidade pode ser cadastrada e listada | Coberta | V1, V2 Canonica, roteiro M-02 | Sexteto V204 |
| Servico/atividade podem compor credenciamento | Coberta | V2 Smoke `MIG_009`, roteiro M-04/M-05/M-06 | MICRO53-fix2 + Sexteto V204 |
| Rodizio seleciona empresa elegivel | Coberta | V2 Canonica, E2E Strikes, roteiro M-07 | Sexteto V204 |
| Recusa avanca fila de forma auditavel | Coberta | E2E Strikes | Sexteto V204 |
| Empresa inativa, suspensa, com OS aberta ou Pre-OS pendente e pulada | Coberta | V2 Canonica, E2E Strikes | Sexteto V204 |
| Avaliacao negativa registra strike | Coberta | E2E Strikes, roteiro M-09 | Sexteto V204 |
| Tres strikes suspendem empresa conforme configuracao | Coberta | E2E Strikes, `MIG_008` | Sexteto V204 |
| Reativacao preserva historico total | Coberta | `CS_REATIV_AUDIT_DUAL_COUNTER`, roteiro M-11 | MICRO48 + Sexteto V204 |
| Reativacao reinicia janela punitiva | Coberta | E2E Strikes, Boundary Dates | Onda23Adv |
| Classificacao preserva `DT_ULT_REATIV` na linha correta | Coberta por regressao | V2 Canonica | Sexteto V204 |
| Integridade detecta referencias orfas reais | Coberta | IntegridadeBase | Sexteto V204 |
| Residuos legados sem chave sao tratados como limpeza auditavel | Coberta | IntegridadeBase / MICRO38 | Sexteto V204 |
| Mensagens de erro explicam origem operacional | Coberta para os fluxos endurecidos | Smoke `MIG_008`, roteiro manual | V204 |
| Reentrada por duplo clique em UI mutadora | Coberta | `ADVERSARIAL_UI` | Onda23Adv |
| Transacao aninhada nao corrompe estado | Coberta | `TRANSACAO_INTERRUPT` | Onda23Adv |
| Datas de OS/avaliacao em bordas temporais | Coberta | `BOUNDARY_DATES` | Onda23Adv |
| Limpar Base preserva CNAE e limpa `CAD_SERV` | Coberta | Smoke `MIG_009`, roteiro M-12/M-13/M-14 | MICRO53-fix2 |
| Vitrine publica aponta para teste humano correto | Coberta documentalmente | MICRO56 | Guias V204 |

## Debitos V203 fechados na V204

| Debito historico | Status V204 | Evidencia |
|---|---|---|
| Mensagens vagas em configuracao de strikes | Fechado | MICRO47 / `MIG_008` |
| Reentrada por duplo clique | Fechado para fluxos cobertos | Onda23 `ADVERSARIAL_UI` |
| Backfill e dados legados auditaveis | Fechado nos pontos planejados | MICRO37, MICRO38, MICRO39 |
| Bordas temporais de strikes | Fechado | MICRO40 + Onda23 `BOUNDARY_DATES` |
| Limpeza para reuso municipal | Fechado | MICRO53-fix2 + roteiro manual V204 |

## Debitos aceitos para V205

| Debito | Destino |
|---|---|
| Renomear publicamente a taxonomia "Sexteto" para nomenclatura profissional de testes | V12.0.0205 |
| Corrigir prefixo historico `V12_0_0203` no nome do CSV de validacao | V12.0.0205 |
| Reavaliar MD-24.4 `SelecionarEmpresa` sem reaproveitar artefatos MICRO49 | V12.0.0205 |
| Lapidar G1/G2/G5 residuais do `glasswing-checks.sh --strict` | V12.0.0205 |
