---
titulo: "Arvores registry-centric"
tipo: spec-core
status: accepted
temperatura: quente
path: core/arvores-spec.md
id-global: 20260617-184100-codex-arvores-spec-core
autor: claude-opus-4-8 (orquestrador)
implementado_por: codex
readback: 0049-arvores-registry-centric
created_at: "2026-06-17T18:41:00-03:00"
---

# Arvores registry-centric

Esta spec define o rotulo de arvore dos artefatos do protocolo. O rotulo mede
o grau de prova acumulada de um artefato; ele e ortogonal a temperatura,
track, papel do agente e local fisico do arquivo.

## As tres arvores

- `fronteira`: ideias, propostas, pareceres e mecanismos ainda em descoberta
  ou antes de ratificacao suficiente. E o default honesto para artefato novo.
- `intermediaria`: artefato com evidencia operacional e cross-audit suficiente
  para orientar trabalho, mas ainda nao promovido ao nucleo estavel.
- `estavel`: artefato selado como regra ou referencia de base. Todo artefato
  `estavel` deve ter `temperatura=quente`.

## Fonte unica

O REGISTRY e a fonte unica da arvore. A coluna going-forward e:

`| id | artefato (path) | tipo | temperatura | arvore | superseded_by | created_at |`

Valores validos para `arvore`: `fronteira`, `intermediaria`, `estavel`.
Linhas legadas sem a coluna continuam legiveis, mas novas linhas devem declarar
a arvore explicitamente.

Nao existe front-matter `arvore:` em artefatos. Tambem nao existe parser YAML,
compilador de Markdown para runtime, nem particao fisica por arvore nesta spec.

## Promocao

Promocao de arvore e sempre evento append-only no REGISTRY, com
`tipo=arvore-promocao`. A linha original de nascimento nunca e editada em
lugar para trocar a arvore.

Uma promocao deve referenciar o readback que autorizou a mudanca e deve ser
rastreavel por onda. O gate de promocao reutiliza os oito criterios objetivos
de `core/exuvia-fitness-criteria.md`:

- C-TEST
- C-ADV
- C-XAUDIT
- C-DOG
- C-FCLOSE
- C-NOREG
- C-TRACE
- C-DEBT

Promover para `intermediaria` ou `estavel` exige aprovacao humana e cross-audit
por familia diferente da implementadora. A promocao para `estavel` exige ainda
`temperatura=quente`.

## Guardas

G-REG valida que artefato novo nasce com arvore valida no REGISTRY e que o path
e casado por coluna, nao por substring.

G-ARVORE-LABEL bloqueia mislabel: `intermediaria` ou `estavel` sem evento
`arvore-promocao` rastreavel nao entra; `estavel` sem `temperatura=quente`
tambem nao entra.

O rotulo de arvore nao muda runtime, nao muda API e nao substitui selagem. Ele
apenas torna explicito o grau de prova do artefato e da linha de ledger que o
governa.
