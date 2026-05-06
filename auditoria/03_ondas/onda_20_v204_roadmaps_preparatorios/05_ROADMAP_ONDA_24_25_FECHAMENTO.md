---
titulo: 05 - Roadmap Ondas 24 e 25 V204 Seguranca e Fechamento
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-05
---

# Ondas 24, 25 e 26 V204 - Seguranca, Fechamento e Documentacao

## 1. Onda 24 - Seguranca e usabilidade

| MD | Mudanca | Gate |
|---|---|---|
| MD-24.1 | Remover ou isolar senha hardcoded de `Limpar_Base` | teste assistido |
| MD-24.2 | Configuracao invalida gera mensagem clara e `AUDIT_LOG` | V2 Smoke |
| MD-24.3 | `EVT_AVALIACAO` registra contador historico e punitivo | E2E Strikes |
| MD-24.4 | Documentar/renomear side-effects de `SelecionarEmpresa` | regressao |

## 2. Onda 25 - Release final

| MD | Mudanca | Gate |
|---|---|---|
| MD-25.1 | Bump `V12.0.0204-rc1` | Sexteto verde |
| MD-25.2 | Auditoria cruzada final | Opus + Antigravity sem P0/P1 |
| MD-25.3 | Release notes + CHANGELOG + docs | review humano |
| MD-25.4 | Tag/push GitHub | aprovacao operador |
| MD-25.5 | HBN devolucao de bastao | doc formal |

## 3. Criterio de aceite final

1. Zero P0.
2. Zero P1 sem decisao formal.
3. Sexteto verde.
4. Auditoria cruzada final aprovada.
5. Operador autoriza producao.

## 4. Onda 26 - Pos-release documental

Depois da Onda 25, parar a esteira de codigo e planejar a Onda 26 para:

1. lapidar documentacao publica e interna;
2. criar estrategia recorrente de higiene documental para IAs;
3. revisar Obsidian/RAG, `llms.txt`, indices e mapas de testes;
4. remover duplicidades documentais ou declarar fonte de verdade;
5. preparar auditoria documental cruzada.
