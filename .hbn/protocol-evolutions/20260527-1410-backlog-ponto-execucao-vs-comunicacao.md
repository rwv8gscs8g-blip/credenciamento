---
titulo: Backlog — separar "ponto de execução do protocolo" (por projeto) do "ponto de comunicação com a doutrina usehbn"
data: 2026-05-27
autoria: Mauricio (visão) + claude-opus-4-7 (registro, modo arquiteto)
gatilho: observação de Mauricio ao revisar por que o PROMPT_ARQUITETO vive fora do repo
status: proposed
prioridade_sugerida: P2
alvo: arquitetura do meta-protocolo (PROMPT_ARQUITETO §6 cross-projetos + Trilha E do §4)
---

# Backlog — ponto de execução vs ponto de comunicação

## A ideia (Mauricio, 2026-05-27)

O `PROMPT_ARQUITETO_USEHBN_AUTONOMO.md` fica **fora** de qualquer repositório de
projeto porque ele deve atualizar **todos os projetos progressiva e
incrementalmente**. Disso decorre uma separação que hoje é implícita e deveria
ser explícita e fluida:

1. **Ponto de execução (por projeto)**: onde o protocolo é *aplicado* — os
   guards, knowledge, readbacks/ERPs vivos daquele projeto. É o protocolo "em
   uso", específico do projeto.
2. **Ponto de comunicação (com a doutrina usehbn)**: o canal pelo qual um
   projeto *propõe melhorias* ao protocolo (hoje: `.hbn/protocol-evolutions/`)
   e por onde a doutrina canônica (`usehbn/`) *retorna* versões atualizadas.

O risco a evitar: **o projeto se confundir com o protocolo aplicado** — misturar
"o que vale neste projeto agora" com "a doutrina geral que ainda está evoluindo".

## Estado atual (parcial)

Já existe parte do mecanismo: `.hbn/protocol-evolutions/` (subida de propostas),
o PROMPT_ARQUITETO fora do repo (doutrina transversal), e a Trilha E do §4
(promover canônicos para `usehbn/`). Falta a **fluidez bidirecional** e a
fronteira explícita entre "aplicado" e "doutrina".

## Proposta para próximos ciclos (não para agora)

- Definir formalmente, no PROMPT_ARQUITETO, os dois pontos por projeto:
  **execução** (aplicado) e **comunicação** (canal de evolução), com nomes e
  paths canônicos.
- Especificar o fluxo incremental: doutrina (`usehbn/`, versionada por tag) →
  projeto adota via onda própria com hearback → projeto propõe melhoria via
  protocol-evolutions → arquiteto consolida → volta à doutrina (Trilha E).
- Garantir que cada projeto saiba **qual versão da doutrina aplica** sem
  confundir com a doutrina em evolução (ex.: campo `doutrina-aplicada: usehbn vX.Y`
  no relay/INDEX de cada projeto).

## Status

PROPOSTA — registrada na lista de melhorias por decisão de Mauricio
("será melhorado em próximas versões com maior fluidez; pode ficar na lista de
melhorias para os próximos ciclos"). O próximo ciclo do PROMPT_ARQUITETO deve
consumir esta proposta no pré-flight (§2 passo F) e decidir promover/refinar.

🔵 HBN PROPOSTA REGISTRADA — não aplicar nesta sessão.
