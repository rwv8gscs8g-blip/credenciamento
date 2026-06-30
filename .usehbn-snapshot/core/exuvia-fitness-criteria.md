---
titulo: "Critérios objetivos de exúvia — o que sobrevive ao molt"
tipo: spec-core
status: accepted
temperatura: quente
path: core/exuvia-fitness-criteria.md
id-global: 20260616-011004-codex-exuvia-fitness-criteria
autor: claude-opus-4-8 (orquestrador)
promovido_de: .hbn/messages/20260616-011004-opus-4-8-criterios-exuvia.md
promovido_por: codex
readback: 0027-faxina-pendencias
created_at: "2026-06-16T01:10:04-03:00"
---

# Critérios objetivos de exúvia

## Para humanos — a ideia em linguagem simples

**A analogia certa é a dos artrópodes e das lagostas.** Esses animais têm um
**exoesqueleto**: uma carapaça rígida por fora que ao mesmo tempo os **sustenta e
protege**. O problema é que a mesma carapaça que protege também **aprisiona** — ela
não cresce junto com o animal. Para crescer, o bicho precisa passar pela **exúvia**
(em inglês, *molt*, a muda): abandonar o exoesqueleto que o limita, atravessar uma
janela de vulnerabilidade, crescer, e então **construir uma carapaça nova**, maior,
que volta a protegê-lo.

A **exúvia do software** é esse mesmo momento: parar, repensar e **abandonar aquilo
que nos limita** para construir algo que permita **crescer** e que ao mesmo tempo
**proteja**. No caso do usehbn isso é central, porque o usehbn é um protocolo de
**proteção e defesa** de todos os sistemas desenvolvidos com ele — a premissa é
proteger, mas também **evoluir e melhorar continuamente**. A exúvia é como o próprio
protocolo cresce sem perder a função protetora: troca a casca velha que trava por
uma nova que sustenta mais. (Este conceito será aprofundado adiante para entrar na
lógica de planejamento.)

O problema que estes critérios resolvem: quando chega a hora da muda, **o que da
carapaça velha merece virar carapaça nova, e o que deve ficar para trás?** Sem
regra, isso vira discussão de opinião ("acho que esse mecanismo é bom"). A proposta
aqui é trocar opinião por **placar**: oito perguntas de SIM ou NÃO que qualquer
pessoa pode conferir olhando o repositório. Se um mecanismo (um guard, uma regra,
um schema) responde SIM às perguntas certas, ele **sobrevive** à muda e entra na
carapaça nova. Se não, ele é **refeito** ou **descartado** antes de enrijecer numa
casca que limita em vez de proteger.

Glossário dos termos que aparecem adiante:

- **Mecanismo**: uma peça de governança que construímos numa onda — por exemplo um guard (`assert-dispatch-integrity`), uma regra (não auto-emendar escopo), um schema.
- **Guard**: um script que **bloqueia** um commit quando alguma regra é violada. É o "fiscal" automático.
- **Onda**: um ciclo de trabalho fechado (implementar → auditar → selar). S1, S2, B17… são ondas.
- **Cross-audit**: auditoria por **duas IAs de famílias diferentes** da que implementou, cada uma conferindo no disco de forma independente. Evita que o autor valide o próprio trabalho.
- **Dogfood** ("comer a própria comida de cachorro"): o mecanismo é testado **em si mesmo**. Ex.: o despacho que criou a regra de despacho foi o primeiro a passar pela regra. Se passa no próprio teste, é real, não teoria.
- **Fail-closed** (falhar fechado): quando falta um insumo (ex.: o schema sumiu), o guard **bloqueia por segurança** em vez de deixar passar. O oposto, "falhar aberto", seria liberar no escuro.
- **Regressão**: quebrar algo que já funcionava. "Sem regressão" = as proteções antigas continuam de pé.
- **Dívida (técnica)**: um problema conhecido que ainda não foi corrigido. Não é proibido ter — é proibido **esconder**. Dívida tem que estar escrita e classificada (foi o caso do marginal H em S2).
- **Truth Barrier**: a regra de que toda afirmação cita arquivo:linha ou comando+saída — nada de "confie em mim".

O objetivo final: que cada onda termine com esse placar de oito colunas
preenchido. Assim, quando a exúvia chegar, a decisão do que sobrevive é
**mecânica e auditável**, e a aprendizagem entre ciclos de IAs fica registrada em
evidência, não em memória.

## Versão normativa

Proposta de spec. Define, de forma **mensurável**, o que um mecanismo precisa
provar para **sobreviver** ao molt (entrar na pasta da próxima versão) em vez de
ser **descartado** como exoesqueleto velho. Serve ao dogfooding e à aprendizagem
contínua entre ciclos de IAs: cada onda gera evidência objetiva, e a decisão de
exúvia deixa de ser opinião e passa a ser um placar verificável no disco.

Complementa o **Fitness Gate** já citado no STATE (baseline funcional + Ponte
verde + confronto incumbente×desafiante): o Fitness Gate decide se a versão
inteira muda; estes critérios decidem, mecanismo a mecanismo, o que entra na
carapaça nova.

## Os oito critérios (cada um é SIM/NÃO verificável)

| Código | Critério | Como medir (comando/arquivo) |
|---|---|---|
| C-TEST | Tem caso **positivo E negativo** na suíte | grep do caso em guards/tests/run-guard-tests.sh; suíte verde |
| C-ADV | Tem **burla adversarial** documentada e bloqueada | linha Bxx em guards/tests/adversarial-battery.sh → BLOQUEADA |
| C-XAUDIT | **Aprovado por ≥2 famílias** distintas do implementador | dois `.hbn/results/*` com APROVA_*: SIM, famílias ≠ |
| C-DOG | **Dogfood**: o mecanismo se aplica a si mesmo, sem grandfathering | artefato do próprio mecanismo passa o próprio guard ao re-stagear |
| C-FCLOSE | **Fail-closed**: falta de insumo BLOQUEIA, não passa | teste com schema/insumo ausente → exit ≠ 0 |
| C-NOREG | **Sem regressão**: invariantes/guards anteriores intactos | suíte + adversarial completas verdes; main intocada |
| C-TRACE | **Rastreável**: readback + autorização humana + token FP + REGISTRY | trailers nos commits; linha no REGISTRY; readback no disco |
| C-DEBT | **Dívida conhecida registrada e aceita** (não-bloqueadora) | marginal anotada em STATE/parecer com classificação |

## Regra de sobrevivência

Um mecanismo **SOBREVIVE ao molt** se e somente se **C-TEST a C-TRACE = SIM**
(os sete são obrigatórios) **e** C-DEBT está registrada (dívida conhecida e
aceita, ou inexistente). Caso contrário:

- Falha C-TEST/C-ADV/C-FCLOSE/C-NOREG → **REFATORAR antes do molt** (o mecanismo é frágil).
- Falha C-XAUDIT/C-TRACE → **não-ratificado**: não entra até auditar/rastrear.
- Dívida em C-DEBT não-registrada → **registrar e endereçar** antes do molt (foi exatamente o caso do marginal H de S2).

## Placar retroativo (evidência no disco, 2026-06-16)

| Mecanismo | C-TEST | C-ADV | C-XAUDIT | C-DOG | C-FCLOSE | C-NOREG | C-TRACE | C-DEBT | Veredito |
|---|---|---|---|---|---|---|---|---|---|
| S1 anti-auto-emenda scope-lock | SIM | B16 | SIM (Gem+Cur) | SIM | SIM | SIM | rb0017 | — | SOBREVIVE |
| B17 meta-path tipo+nome | SIM | B17 | SIM | SIM | SIM | SIM | rb0019 | — | SOBREVIVE |
| B18 symlink em meta-path | SIM | B18 | SIM | SIM | SIM | SIM | rb0021 | — | SOBREVIVE |
| B19 symlink em path governado | SIM | B19 | SIM (classe FECHADA) | SIM | SIM | SIM | rb0023 | hardlink=non-issue (aceito) | SOBREVIVE |
| S2 dispatch auto-declarante | SIM | B20-B22 | SIM (Gem100/Cur90) | SIM | SIM | SIM | rb0025 | H trailers (a corrigir em 0027) | SOBREVIVE c/ dívida endereçada |

Leitura: os cinco mecanismos das últimas ondas **sobrevivem**. O único com
dívida ativa é S2 (marginal H), e ela está **endereçada** pela faxina 0027 — por
isso S2 entra na carapaça nova, mas a dívida não. Hardlink em B19 é dívida *aceita*
(won't-fix justificado: git materializa como 100644).

## O que isto muda na prática

1. Toda onda nova passa a fechar com este placar de oito colunas no handoff — informação clara e precisa, não narrativa.
2. A decisão de exúvia (molt) vira um filtro objetivo: roda-se o placar sobre cada mecanismo; o que não fecha sete-de-sete é refatorado ou descartado antes de virar carapaça nova.
3. Dívida deixa de virar lixo silencioso: C-DEBT obriga registro; faxina periódica (como a 0027) zera as dívidas endereçáveis.

## Sequência de adoção

- Selar esta spec como `core/exuvia-fitness-criteria.md` na faxina 0027.
- Acrescentar ao state-report-spec a exigência do placar de 8 colunas no handoff de fim de onda (candidato a S3).
- Rodar o placar como pré-condição do Fitness Gate quando a exúvia for ativada (M-C).
