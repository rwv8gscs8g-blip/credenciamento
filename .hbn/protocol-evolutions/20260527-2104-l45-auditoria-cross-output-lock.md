---
titulo: L45 — Output lock para auditoria cruzada
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-05-27
---

# L45 — Output lock para auditoria cruzada

## Rule

Prompts de auditoria cruzada devem reservar explicitamente um único caminho de saída por auditor, com política de colisão obrigatória:

- se o caminho existir, não sobrescrever;
- responder `COLLISION` e listar o arquivo existente;
- aguardar novo caminho humano ou usar um fallback previamente declarado.

## Evidência

No GATE-A2 da Onda 38.2.3, o prompt do Codex indicou os caminhos `0017` e `0018`. Em execução posterior, o Opus encontrou ambos já preenchidos e corretamente recusou sobrescrever, produzindo uma reauditoria em `0019` após decisão humana. A auditoria foi útil, mas a colisão consumiu coordenação e gerou ambiguidade documental.

## Proposta

Antes de disparar auditoria cruzada, o implementador deve preparar um bloco de roteamento com:

- `gate_id`;
- `auditor_role`;
- `output_path`;
- `collision_policy`;
- `fallback_path` opcional;
- lista de arquivos de entrada;
- perguntas de auditoria;
- severidade esperada: `BLOQUEADOR`, `FORTE`, `MARGINAL`.

Cada auditor recebe um prompt separado contendo apenas o seu `output_path`. O prompt deve proibir que um auditor escreva no arquivo do outro.

## Status

Proposta para o próximo ciclo de melhoria do protocolo UseHBN. Não altera o GATE-A3, mas deve ser considerada antes da próxima rodada de prompts de auditoria cruzada.
