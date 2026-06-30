---
adr-id: ADR-023
titulo: Integridade de hearback — anti-auto-assinatura (uma IA nunca commita a própria autorização)
status: ACCEPTED
data-deposito: 2026-06-10
id-global: 20260610-82
path: methodology/adr/ADR-023-integridade-de-hearback.md
autor: claude-fable-5 (arquiteto useHBN, corrente E — fechamento, Bloco 5)
cross-ia-required: Codex + Antigravity (responde ao FORTE F-05 da 0026 — P10)
hearback-status: confirmado por Maurício (readback 0003, 2026-06-10)
prioridade: P0 (sem isto, todo o sistema de hearbacks pode ser forjado pela própria IA)
temperatura: quente
tier-desta-mudanca: T2 (normativo — ADR + guard novo com teste negativo)
aplica-a: todo hearback de todo projeto sob o protocolo
relacionado: [.hbn/results/0026-cross-ia-antigravity-corrente-e.md (F-05 FORTE — "Teatro de 3º Nível"), ADR-020 (dereferência de hearback), guards/assert-hearback-integrity.sh, guards/assert-role-family.sh (consumidor de hearback), guards/freeze-gate.sh (consumidor de hearback)]
evidencia-motivadora: |
  Finding F-05 (FORTE) da re-auditoria 0026 (Antigravity): a IA roda no
  shell do humano, com as mesmas permissões. Ela pode gerar
  .hbn/hearbacks/9999-fake.json com status "confirmed" e signed_by
  "Maurício", commitá-lo JUNTO com a mudança que ele autoriza, e os guards
  endurecidos do ADR-020 aprovarão — o arquivo existe, está confirmado e
  cobre a exceção. A dereferência (ADR-020) provou a SUBSTÂNCIA do arquivo;
  falta provar a ORIGEM da assinatura. É o Teatro de 3º Nível.
---

# ADR-023 — Integridade de hearback

## O problema, em linguagem humana

O hearback é a assinatura do humano no protocolo. O ADR-020 ensinou os
guards a conferir se a assinatura EXISTE e o que ela COBRE — mas não QUEM a
escreveu. Numa folha de papel, forjar assinatura exige imitar a caligrafia;
num JSON, basta digitar `"signed_by": "Maurício"`. Como a IA escreve no
mesmo repositório e commita pelo mesmo shell, a única caligrafia disponível
é a FORMA DO HISTÓRICO: quando o commit nasceu, o que ele tocou junto, e
quem o assina perante o git.

## Decisão 1 — O que torna um hearback VÁLIDO

Um hearback só é válido como autorização quando, cumulativamente:

- **(a) Commitado pelo HUMANO.** Uma IA NUNCA cria, edita ou commita
  arquivo em `.hbn/hearbacks/` — nem mesmo o draft "para facilitar"
  (exceção: draft com `status: pendente` explicitamente pedido pelo humano,
  como o 0002 — que NÃO autoriza nada enquanto pendente).
- **(b) Em commit SEPARADO que PRÉ-EXISTE à mudança que autoriza.** O
  commit do hearback toca APENAS `.hbn/hearbacks/` e é ancestral estrito do
  commit da mudança. Autorização que chega junto com a obra não é
  autorização — é fato consumado.
- **(c) Revisado no diff pelo humano.** Antes de commitar o hearback, o
  humano LÊ o diff de `.hbn/hearbacks/` — esta é a barreira FINAL e
  inalienável (ver "limite honesto" abaixo).

## Decisão 2 — Guard `assert-hearback-integrity` (G-HRB), com teste negativo

`bash guards/assert-hearback-integrity.sh <hearback> [commit-da-mudança=HEAD]`
recusa a adoção quando:

1. o hearback NÃO está commitado antes da mudança (staged/untracked não
   pré-existe a nada);
2. o hearback nasceu ou foi alterado no MESMO commit da mudança que
   autoriza (auto-assinatura clássica — caso-ruim do teste negativo);
3. o commit do hearback NÃO é puro (toca arquivos fora de
   `.hbn/hearbacks/` — autorização misturada com obra).

Sobre o critério "autor do commit do hearback = autor da mudança": a regra
normativa é que o autor do hearback seja o humano. Mecanicamente, porém,
no regime atual o repositório inteiro usa UMA identidade git (a do humano,
emprestada à IA pelo shell compartilhado) — a igualdade de autores é o caso
legítimo NORMAL e não distingue nada. Bloquear por igualdade bloquearia
toda adoção legítima. Por isso o G-HRB rebaixa este critério a AVISO
explícito enquanto a identidade for única, e o ADR registra a elevação
futura: quando houver identidades separadas ou assinatura criptográfica,
o aviso vira BLOQUEIO.

O guard NÃO entra no runner nesta onda (ADR-020 Decisão 2).

## Decisão 3 — O limite honesto, declarado

Em shell compartilhado a trava lógica é PARCIAL por construção: a IA tem as
mesmas permissões do humano e pode, em tese, forjar também o commit puro
separado. O que este ADR consegue é encarecer a forja — de "gerar uma
string" para "fabricar um commit separado, puro e anterior no histórico" —
e torná-la VISÍVEL: todo toque em `.hbn/hearbacks/` aparece em diff
auditável. A barreira final é, e continua sendo, a revisão humana do diff
de `.hbn/hearbacks/` (Decisão 1c; recomendação H4 da 0026).

## Decisão 4 — Evolução futura no backlog (não nesta onda)

Assinatura criptográfica dos hearbacks (GPG ou SSH signing: o humano assina
o commit do hearback com chave que a IA não possui; G-HRB passa a verificar
`git verify-commit`) entra no backlog do STATE como a elevação que torna a
trava lógica TOTAL. Não implementada agora: exige setup de chave fora do
repositório — decisão de ambiente do humano, não de protocolo.

## Consequências

Positivas: a auto-assinatura barata (mesmo commit) vira erro mecânico
reproduzível; o fluxo legítimo ganha forma canônica (hearback = commit puro
do humano, anterior à adoção); o risco residual fica NOMEADO em vez de
implícito. Negativas: um commit a mais por autorização (aceito: é o ritual
que dá valor à assinatura); o aviso de autor único gera ruído até a
elevação criptográfica (aceito: ruído que lembra o limite é honestidade).

## DONE-check

`bash guards/tests/run-guard-tests.sh` verde incluindo: hearback no mesmo
commit da mudança → BLOQUEADO; hearback nascido em commit impuro →
BLOQUEADO; hearback não commitado → BLOQUEADO; fluxo legítimo (commit puro
anterior) → passa.

## Versão

- v1.0 — 2026-06-10 — claude-fable-5, corrente E (fechamento) — depósito inicial.
- v1.1 — 2026-06-10 — codex, consolidação — ACCEPTED por hearback humano no readback 0003, mantendo mesmo autor como AVISO até identidade separada/GPG.
