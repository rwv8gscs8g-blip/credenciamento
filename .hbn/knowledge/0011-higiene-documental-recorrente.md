---
titulo: Higiene documental recorrente antes de passar de fase
diataxis: reference
hbn-track: safe_track
hbn-status: knowledge
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-06
autoria: decisao operacional de Luis Mauricio Junqueira Zanin, registrada por Codex CLI
aplica-a: toda IA e todo contribuidor humano antes de encerrar microdelta, onda, release ou bastao
revisar-em: Onda 26 V12.0.0204
status: vigente
---

# Higiene Documental Recorrente Antes de Passar de Fase

## Regra

Antes de passar de microdelta, onda, release ou bastao, a IA deve fazer
uma validacao curta de higiene documental. O objetivo e reduzir ambiguidade
para humanos e para a proxima IA.

## Checklist minimo

1. `.hbn/relay/INDEX.md` informa ciclo ativo, ultima validacao e proxima
   acao.
2. Readback e ERP existem ou o motivo da ausencia esta documentado.
3. ERP reflete o status real: entregue, aprovado pelo operador,
   superseded, reprovado ou bloqueado.
4. `CHANGELOG.md` registra mudanca publica e gate quando aplicavel.
5. Evidencias usadas na decisao estao citadas por id, caminho ou nome.
6. Roadmap da onda nao contradiz o estado real.
7. Pendencias abertas, fechadas ou deferidas estao explicitas.
8. Se houve funcionalidade nova, existe teste correspondente conforme
   regra `0010`.

## Uso com Obsidian/RAG

A Onda 26 deve formalizar a camada de consulta recorrente:

1. `obsidian-vault/` para navegacao humana;
2. `docs/` para documentacao publica;
3. `.hbn/knowledge/` para regras curtas de IA;
4. `auditoria/` para trilha historica e evidencial;
5. `llms.txt` e `llms-full.txt` para mapas RAG.

## Como verificar

Antes de declarar fase encerrada, responder:

1. Onde esta o estado atual?
2. Onde esta o gate validado?
3. Onde esta a evidencia?
4. Qual e a proxima acao?
5. Qual documento uma nova IA deve ler primeiro?

Se qualquer resposta depender apenas do chat, a fase ainda nao esta
documentalmente pronta para passagem.
