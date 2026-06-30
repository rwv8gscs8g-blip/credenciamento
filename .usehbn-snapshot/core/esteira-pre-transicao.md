---
titulo: "Esteira de Pre-Transicao — gate de subagentes tematicos antes do freeze e da exuvia"
tipo: spec-core
status: accepted
temperatura: quente
created_at: "2026-06-17T10:30:00-03:00"
origem: docs/brainstorm/rodada-2026-06-17/analise-pre-transicao/06-esteira-pre-transicao-proposta.md
---

# Esteira de Pre-Transicao

## 1. Definicao
Antes de dois marcos criticos — o FREEZE (tag de versao estavel) e a EXUVIA (muda para
novo exoesqueleto) — o orquestrador dispara ondas de grupos de subagentes TEMATICOS,
cada uma com tema especifico, todas READ-ONLY e sob Truth Barrier, que documentam seus
achados NO PROPRIO SISTEMA (pasta datada e legivel) para outros agentes lerem. Complementa
o cross-audit de familia distinta (que valida uma onda): o cross-audit pergunta "esta
mudanca esta correta?"; a esteira pergunta "o sistema inteiro esta pronto para congelar /
mudar de casca?".

## 2. Regras invioláveis da esteira
- Read-only: subagentes so LEEM o existente e ESCREVEM apenas seu proprio relatorio novo.
  Sem commit, sem tocar main, sem --no-verify/git add, sem modificar arquivo rastreado.
- Truth Barrier: todo achado cita arquivo:linha OU comando+saida.
- Documentacao no sistema: pasta docs/brainstorm/rodada-AAAA-MM-DD/analise-pre-transicao/
  com NN-tema.md (cabecalho padrao) + 00-INDICE.md. Zona livre/untracked ate curadoria
  humana (knowledge 0024) — nao entra em commit sem aprovacao por arquivo.
- Saida acionavel: cada relatorio classifica recomendacoes em LEVE (antes do freeze) vs
  EXUVIA (para a muda), sempre sob o principio de leveza (P11).

## 3. Temas minimos (piso, aberto a evolucao)
a) Auditoria profunda (runtime, guards+adversarial, meta-validacao do fluxo).
b) Estrutura de pastas + documentacao (livro-razao central, nada solto na raiz).
c) Mapa de migracao / genoma auto-contido (novo sistema nasce sem apontar para os antigos;
   antigos ficam na pasta original para auditoria).
d) Qualidade da descricao e documentacao do software (README, AGENTS, docstrings, CLI, glossario).
e) Padronizacao geral (nomenclatura, ids, datas, formato do REGISTRY).
f) Prontidao GitHub para transicao segura (clone limpo, CI, branch protection, segredos, paths).
g) Protocolos de teste + novos testes mais simples e efetivos (fixtures engine-reais,
   property-based, gate de honestidade de contagem).
A lista e um MINIMO, nao um teto. Inclusao/fusao/remocao de tema passa pelo gate normal
(aprovacao humana -> cross-audit -> decisao).

## 4. Forca de regra (vinculante)
- R-PT1. Sem dossie, sem freeze: o freeze-gate nao roda para tag estavel sem dossie
  completo (um relatorio por tema minimo a-g + 00-INDICE.md). [implementacao no freeze-gate: onda futura]
- R-PT2. Sem dossie de exuvia, sem muda: o Fitness Gate exige dossie focado em genoma
  auto-contido (tema c) antes do corte.
- R-PT3. Curadoria humana explicita: cada recomendacao LEVE so vira onda apos aceno humano
  por item (knowledge 0024); nada e auto-implementado.
- R-PT4. Rastreabilidade: a conclusao de cada esteira gera linha no REGISTRY (evento
  'esteira-pre-transicao concluida', com path do dossie e o marco — freeze ou exuvia).
- R-PT5. Cobertura minima auditavel: ausencia de qualquer tema a-g e bloqueio.

## 5. Posicao no ciclo de vida
A esteira roda DUAS vezes com focos distintos: antes do FREEZE (estabilizar o incumbente)
e antes da EXUVIA (preparar genoma limpo). Os relatorios alimentam (i) o checklist de
freeze e (ii) o mapa de migracao da exuvia. A lista de temas e viva; a obrigatoriedade do
gate e fixa: nenhum freeze e nenhuma exuvia sem a esteira cumprida e curada.
