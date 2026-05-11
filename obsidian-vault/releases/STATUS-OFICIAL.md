---
titulo: Status Oficial das Versoes
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-11
---

# Status Oficial das Versoes

Este arquivo e a fonte canonica para o status de publicacao das versoes. As release notes individuais continuam existindo como historico tecnico, mas a classificacao oficial passa a ser feita aqui.

## Linha oficial atual

| Versao | Status | Compila | Testes | Observacao |
|--------|--------|---------|--------|------------|
| V12.0.0204 | VALIDADA | Sim | `VR_20260511_154433` e `VR_20260511_175849` aprovados | Linha oficial vigente; build final validado `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`; Smoke `34/0/4`; validacao manual final aprovada pelo operador; vitrine humana V204 atualizada |

## Linha em estabilizacao, ainda nao oficial

| Versao alvo | Status | Build ancora | Compila | Testes | Observacao |
|-------------|--------|--------------|---------|--------|------------|
| V12.0.0205 | PLANEJAMENTO | pendente | pendente | pendente | Proxima linha: auditoria cruzada Opus/Antigravity, lista mestra de evolucoes e renomeacao profissional da taxonomia de testes |

## Marcos validados

| Versao | Status | Observacao |
|--------|--------|------------|
| V12.0.0202 | SUPERADA | Substituida pela V12.0.0204, mantendo valor historico como primeira linha publica validada da fase HBN |
| V12.0.0203 | SUPERADA | Release candidate e trilha de estabilizacao absorvidas pela V12.0.0204; nao foi promovida como release oficial isolada |
| V12.0.0190 | VALIDADA | Marco de estabilizacao da baseline deterministica da V2 |
| V12.0.0191 | VALIDADA | Marco da migracao das guardas criticas UI -> servico |
| V12.0.0180 | VALIDADA | Base estavel aprovada para a retomada da linha V12 |

## Superadas por consolidacao

| Versoes | Status | Observacao |
|---------|--------|------------|
| V12.0.0182 a V12.0.0189 | SUPERADAS | Iteracoes preparatorias da V2; valor historico preservado |
| V12.0.0192 | SUPERADA | Higiene de inativos incorporada na linha estabilizada posterior |
| V12.0.0194 a V12.0.0201 | SUPERADAS | Hotfixes intermediarios absorvidos pela V12.0.0202 |

## Revertidas ou rejeitadas

| Versao | Status | Observacao |
|--------|--------|------------|
| V12.0.0193 | REVERTIDA | Recorte CNAE/CAD_SERV revertido por regressao operacional |
| V12.0.0142 | REVERTIDA | Estrategia de reset CNAE descartada no historico |

## Historico interno nao candidato a publicacao direta

| Faixa | Status | Observacao |
|-------|--------|------------|
| V12.0.0062 a V12.0.0179 | HISTORICO_INTERNO | Material util para rastreabilidade, mas fora da linha oficial que sera publicada |

## Regra de uso

- Nenhuma release deve permanecer sem status oficial.
- Se a versao deixou de ser candidata a auditoria isolada, ela deve ser marcada como `SUPERADA`.
- Se a versao regrediu ou foi abandonada, ela deve ser marcada como `REVERTIDA`.
- A linha publica do projeto deve sempre apontar para a versao mais nova `VALIDADA`.
