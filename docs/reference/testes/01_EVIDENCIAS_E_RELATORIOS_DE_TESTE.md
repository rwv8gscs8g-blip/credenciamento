# Evidências e Relatórios de Teste

## Princípio

Os testes do projeto precisam entregar duas coisas diferentes:

1. **determinismo técnico**
2. **legibilidade humana**

Esses objetivos são complementares, mas não são a mesma coisa.

## O que a suíte V2 faz hoje

A suíte V2 reconstrói a base operacional a cada cenário para garantir repetibilidade. Isso significa que, por desenho:

- `EMPRESAS`, `ENTIDADE`, `CREDENCIADOS`, `PRE_OS` e `CAD_OS` são zeradas a cada cenário
- a aba `AUDIT_LOG` operacional também é reiniciada a cada novo reset determinístico

Consequência:

- a `AUDIT_LOG` ao final da execução mostra apenas o rastro residual do último cenário executado
- a trilha cumulativa da execução humana precisa ser lida em `RESULTADO_QA_V2`, `HISTORICO_QA_V2` e no relatório da execução

## O que isso significa na prática

A ausência de um histórico completo na `AUDIT_LOG` final **não é bug do sistema de negócio**. É efeito colateral do modelo de teste determinístico.

Em outras palavras:

- a suíte preserva a prova do resultado da execução
- mas não preserva, por padrão, o “filme completo” na aba operacional de auditoria

## Padrão de exportação

### V1 — Bateria Oficial

- CSV automático deve existir apenas quando houver falhas
- sem falha, o padrão é: nenhuma exportação automática
- o relatório humano continua opcional e pode ser impresso manualmente

### V2

- CSV automático segue restrito a falhas
- o relatório da última execução deve ser legível, revisável e opcionalmente imprimível

## Relatório humano

O relatório humano da V2 deve servir para:

- provar qual execução foi rodada
- mostrar `OK`, `FALHA` e `MANUAL`
- listar cenários, expectativas e resultados obtidos
- explicar que a `AUDIT_LOG` final reflete apenas o último cenário por causa do reset determinístico

## Próximo passo evolutivo

A melhoria estrutural desejável para a V2 é adicionar uma trilha cumulativa própria da execução de testes, separada da `AUDIT_LOG` operacional. Isso evita misturar:

- auditoria do negócio em execução
- evidência de auditoria da suíte de testes
