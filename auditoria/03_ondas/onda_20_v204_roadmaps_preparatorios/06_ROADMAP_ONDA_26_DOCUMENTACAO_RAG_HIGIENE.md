---
titulo: 06 - Roadmap Onda 26 V204 Documentacao RAG e Higiene
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-06
---

# Onda 26 V204 - Documentacao, RAG e Higiene Recorrente

## 1. Objetivo

Depois da Onda 25 e da promocao da V12.0.0204, criar uma esteira
recorrente de lapidacao documental para reduzir custo de analise humana
e de novas IAs.

## 2. Principio

Toda passagem de fase deve deixar rastro simples:

1. o que mudou;
2. qual build/import foi validado;
3. qual gate passou;
4. quais evidencias sustentam a decisao;
5. qual proxima acao esta liberada;
6. quais pendencias foram abertas, fechadas ou deferidas.

## 3. Higiene documental recorrente

Antes de encerrar microdelta, onda ou release, a IA deve verificar:

| Area | Validacao minima |
|---|---|
| HBN relay | proprietario, ciclo ativo, ultima validacao e proxima acao coerentes |
| Readback/ERP | readback aprovado, ERP criado/atualizado e status condizente com evidencias |
| CHANGELOG | mudanca publica e validacao registradas |
| Evidencias | CSVs, logs e prints citados quando usados para decisao |
| Roadmap | status da onda e bloqueadores atualizados |
| Docs humanas | procedimentos e mapas de teste coerentes com o gate vigente |
| RAG/indices | `llms.txt`, `docs/INDEX.md` e mapas Obsidian apontam para os documentos certos |

## 4. Estrategia Obsidian/RAG

Proposta para a Onda 26:

1. usar `obsidian-vault/` como camada narrativa e operacional para
   humanos;
2. manter `docs/` como documentacao publica Diataxis;
3. manter `.hbn/knowledge/` como memoria operacional curta e normativa
   para IAs;
4. manter `auditoria/` como trilha historica e evidencial;
5. gerar mapas RAG enxutos que respondam: estado atual, como testar,
   como importar, riscos abertos e linhas de decisao.

## 5. Microdeltas

| MD | Entrega | Gate |
|---|---|---|
| MD-26.1 | Checklist canonico de higiene documental por fase | revisao local |
| MD-26.2 | Mapa RAG V204 para humanos e IAs | links sem quebrar |
| MD-26.3 | Obsidian dashboard V204 estavel | navegacao humana validada |
| MD-26.4 | Limpeza de duplicidades e docs obsoletos | diff auditavel |
| MD-26.5 | Auditoria cruzada documental | outra IA sem P0/P1 documental |

## 6. Criterio de aceite

1. Nova IA consegue identificar estado atual em ate 5 minutos.
2. Operador consegue localizar comando de importacao, gate esperado e
   evidencia da ultima validacao sem procurar em historico de chat.
3. Duplicidades documentais possuem regra de fonte de verdade.
4. Cada onda futura herda checklist de higiene documental antes de
   passar de fase.
