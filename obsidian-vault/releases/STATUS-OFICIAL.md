---
titulo: Status Oficial das Versoes
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-21
---

# Status Oficial das Versões

Este arquivo é a fonte canônica para o status de publicação das versões. As release notes individuais continuam existindo como histórico técnico, mas a classificação oficial passa a ser feita aqui.

## Linha oficial atual

| Versão | Status | Compila | Testes | Observação |
|--------|--------|---------|--------|------------|
| V12.0.0205 | VALIDADO | Sim | `VR_20260521_182816` aprovado | Linha oficial vigente; build validado `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix`; Gate RVS preserva a guarda funcional da V204; documentação pública V205 consolidada para produção |

## Próximas linhas planejadas

| Versão alvo | Status | Build âncora | Compila | Testes | Observação |
|-------------|--------|--------------|---------|--------|------------|
| V12.0.0206 | PLANEJAMENTO | `V12.0.0205` | pendente | pendente | Estabilização incremental pós-produção: ajustes manuais residuais, PDF automático especificado, débitos técnicos pequenos e melhorias prorrogadas sem refatoração profunda |
| V12.0.0207 | PLANEJAMENTO | `V12.0.0206` | pendente | pendente | Code review profundo, performance, componentização e preparação arquitetural para evolução SaaS |

## Marcos validados

| Versão | Status | Observação |
|--------|--------|------------|
| V12.0.0204 | SUPERADA | Substituída pela V12.0.0205 em 2026-05-21; preservada como baseline funcional estável que originou a guarda RVS |
| V12.0.0202 | SUPERADA | Substituída pela V12.0.0204, mantendo valor histórico como primeira linha pública validada da fase HBN |
| V12.0.0203 | SUPERADA | Release candidate e trilha de estabilização absorvidas pela V12.0.0204; não foi promovida como release oficial isolada |
| V12.0.0190 | VALIDADA | Marco de estabilização da baseline determinística da V2 |
| V12.0.0191 | VALIDADA | Marco da migração das guardas críticas UI -> serviço |
| V12.0.0180 | VALIDADA | Base estável aprovada para a retomada da linha V12 |

## Superadas por consolidacao

| Versões | Status | Observação |
|---------|--------|------------|
| V12.0.0182 a V12.0.0189 | SUPERADAS | Iterações preparatórias da V2; valor histórico preservado |
| V12.0.0192 | SUPERADA | Higiene de inativos incorporada na linha estabilizada posterior |
| V12.0.0194 a V12.0.0201 | SUPERADAS | Hotfixes intermediários absorvidos pela V12.0.0202 |

## Revertidas ou rejeitadas

| Versão | Status | Observação |
|--------|--------|------------|
| V12.0.0193 | REVERTIDA | Recorte CNAE/CAD_SERV revertido por regressão operacional |
| V12.0.0142 | REVERTIDA | Estratégia de reset CNAE descartada no histórico |

## Historico interno nao candidato a publicacao direta

| Faixa | Status | Observacao |
|-------|--------|------------|
| V12.0.0062 a V12.0.0179 | HISTORICO_INTERNO | Material útil para rastreabilidade, mas fora da linha oficial que será publicada |

## Regra de uso

- Nenhuma release deve permanecer sem status oficial.
- Se a versão deixou de ser candidata a auditoria isolada, ela deve ser marcada como `SUPERADA`.
- Se a versão regrediu ou foi abandonada, ela deve ser marcada como `REVERTIDA`.
- A linha pública do projeto deve sempre apontar para a versão mais nova `VALIDADO`.
