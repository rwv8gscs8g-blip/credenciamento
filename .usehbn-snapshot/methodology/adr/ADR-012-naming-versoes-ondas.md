---
adr-id: ADR-012
titulo: Naming canônico de versões, ondas e artefatos de onda — um nome por coisa
status: ACCEPTED
data-deposito: 2026-06-10
autor: claude-fable-5 (arquiteto useHBN, corrente C2)
cross-ia-required: Opus + Codex (Codex é dono operacional do Credenciamento, maior afetado)
hearback-status: confirmado 2026-06-10 (readback 0001 / hearback 0001)
prioridade: P0
aplica-a: TODOS os projetos sob o protocolo
relacionado: [ADR-011 (id global e temperatura), ADR-004 (SemVer do protocolo)]
temperatura: quente
evidencia-motivadora: |
  Nomes coexistentes para a MESMA linha de release no relay do Credenciamento
  (grep em .hbn/relay/INDEX.md, 2026-06-10): V12.0.0206, V12-0-0206-Onda-38-2-30,
  V12-205-OficialCongelada, V12-204-Micro48, V12-202-Z011-onda17-fechada,
  V12-202-S/T/Q, V12.0.0203-rc1. Onda com chave dupla: "38.2.44 / 0177".
  Build labels: +ONDA01-em-homologacao … +ONDA04. Custo: toda IA que retoma
  precisa decifrar se V12-202-Z011 = V12.0.0202 (sim) e se 38.2.44 = 0177 (sim).
---

# ADR-012 — Um nome canônico por versão, um por onda

## O problema, em linguagem humana

A mesma release tem hoje meia dúzia de apelidos (`V12.0.0206`,
`V12-0-0206-Onda-38-2-30`…) e a mesma onda tem duas chaves (`38.2.44` e
`0177`). Cada apelido novo é uma tradução que toda IA futura paga para fazer.
Nome é endereço: endereço com seis grafias não entrega carta.

## Decisão 1 — UM formato de versão: `V<MAJOR>.<MINOR>.<PATCH>`

Canônico: `V12.0.0206` (PATCH mantém os 4 dígitos já praticados — zero
migração nas releases existentes). É o ÚNICO nome de versão válido em STATE,
readbacks, handoffs, CHANGELOGs e commits going-forward.

Aposentados como CHAVE (viram, no máximo, descrição humana entre parênteses):
`V12-0-0206-Onda-*`, `V12-NNN-<letra><seq>` (`V12-202-Z011`),
`V12-NNN-<apelido>` (`V12-205-OficialCongelada`, `V12-204-Micro48`).
Pré-release segue SemVer: `V12.0.0203-rc1` permanece válido (`-rc<N>`).
Estado de congelamento NÃO entra no nome — congelamento é fato do
STATE/REGISTRY (`ancora_estavel`), não do identificador.

## Decisão 2 — UMA chave de onda: `NNNN` monotônico

Chave canônica: `onda-0177` (o NNNN já praticado nos readbacks/results).
A árvore decimal `38.2.x` é **rebaixada a descrição humana opcional** — pode
aparecer em prosa ("onda-0177, a 44ª da família 38.2"), NUNCA como chave em
nome de arquivo, campo de STATE, readback ou commit. Campo `onda_atual` do
STATE passa a conter só `0177`.

Razão: o NNNN já é a chave real dos artefatos (`0177-rb-*.json`,
`0177-exec-*.json`); a árvore decimal exige conhecer a história da família
para ordenar (38.2.9 < 38.2.10 quebra ordenação lexicográfica) e duplica o
que o NNNN já responde melhor.

## Decisão 3 — Artefato dentro da onda: `NNNN-<tipo>-<slug>`

Padrão único (já majoritário na prática): `0177-rb-onda-handoff-opus.json`.
Vocabulário FIXO de `<tipo>` (compartilhado com ADR-011):

`rb` (readback) · `hb` (hearback) · `exec` (resultado de execução) ·
`tecnico` (nota técnica) · `handoff` · `proposal` (auditoria/parecer) ·
`adr` · `audit` · `analise` · `report` · `prompt` · `knowledge` · `baseline` ·
`schema` · `guard` · `ci` · `queue` · `spec-core`
(últimos 5 adicionados pela C3/C4 em 2026-06-10, pré-ratificação, mesmo lote —
necessários para o REGISTRY classificar schemas, guards, workflows e fila)

Tipo fora do vocabulário = artefato inválido (guard futuro pode recusar).
Acréscimo de tipo novo: 1 linha neste ADR via protocol-evolution, não apelido
ad hoc.

## Decisão 4 — Build label: `<versão>+<commit>` apenas

Canônico: `V12.0.0206+0df2241`. Aposentado: `+ONDA01-em-homologacao`,
`+ONDA...-ARx-FIXy` e qualquer metadado narrativo no label. A onda, o AR e o
FIX são rastreáveis pelo REGISTRY/REGISTRY da onda (ADR-011) e pelo commit —
o label só precisa responder "que código é este": versão + sha.

## Decisão 5 — Migração: going-forward, com tabela de mapeamento

- **Nunca reescrever história fechada**: tags, arquivos e commits existentes
  ficam como estão. Releases congeladas mantêm os nomes com que foram
  congeladas.
- Todo nome NOVO (a partir da aceitação) usa exclusivamente as formas
  canônicas acima.
- Cada projeto deposita `docs/NAMING-LEGADO.md` (ou seção no REGISTRY) com a
  tabela legado→canônico, preenchida UMA vez e congelada (frio). Exemplo
  mínimo do Credenciamento:

| Legado | Canônico | Nota |
|---|---|---|
| V12-202-Z011-onda17-fechada | V12.0.0202 | apelido de fase Z, onda 17 |
| V12-204-Micro48 | V12.0.0204 | micro-release 48 |
| V12-205-OficialCongelada | V12.0.0205 | release oficial vigente |
| V12-0-0206-Onda-38-2-30 | V12.0.0206 | em validação |
| 38.2.44 | onda-0177 | última equivalência decimal↔NNNN |

- IA que encontrar nome legado em doc vivo: traduz pela tabela, não propaga.

## Consequências

Positivas: tradução mental eliminada na retomada; ordenação de ondas vira
comparação de inteiros; guards podem validar nomes mecanicamente (regex
única); STATE fica menor e não-ambíguo. Negativas: a tabela de mapeamento é
um artefato a mais por projeto (frio, escrito uma vez); perde-se a "genealogia
visual" da árvore decimal — aceita, pois o REGISTRY e a prosa cobrem isso.

## DONE-check

Qualquer onda ou versão tem exatamente UM nome canônico
(`onda-NNNN` / `V<MAJOR>.<MINOR>.<PATCH>`); subnomes legados resolvem por
tabela e novos subnomes são inválidos por construção.

## Versão

- v1.0 — 2026-06-10 — claude-fable-5, corrente C2 — depósito inicial (PROPOSED).
