---
adr-id: ADR-008
versao-adr: v2
titulo: Migração Credenciamento/usehbn/ → .usehbn-snapshot/ — gatilho por DATA+DONO (supersede v1)
status: ACCEPTED
data-deposito: 2026-06-10
autor: claude-fable-5 (arquiteto useHBN, corrente C2), sobre decisão Q4 de Maurício
supersede: ADR-008-migracao-snapshot-credenciamento.md (v1, 2026-05-09 — fica ULTRAPASSADO quando este for aceito; arquivo v1 intocado, per ADR-011)
temperatura: quente
cross-ia-required: Opus + Codex (Codex é dono operacional do Credenciamento)
hearback-status: confirmado 2026-06-10 (readback 0001 / hearback 0001)
prioridade: P0
gatilho: 2026-06-30 (data fixa)
dono: Maurício
dependencias: ciclos C2 (fronteira) e C3 concluídos; MD-I (tooling fetch/verify); matriz MD-K (já entregue)
relacionado: [ADR-002, ADR-003, ADR-011 (id do inbox), ADR-012, auditoria/00_status/08_MD_K (matriz origem→destino)]
---

# ADR-008 v2 — gatilho com data e dono; inbox por projeto

## Por que uma v2

A v1 (2026-05-09) condicionava a migração a "v204 final do Credenciamento" —
um **evento externo sem dono**. Resultado comprovado: um mês depois, o
Credenciamento já vai em V12.0.0206 e o ADR continua bloqueado, porque
"esperar a release final" é um alvo que anda. A v2 troca evento por DATA e
nomeia um DONO. O conteúdo técnico da v1 (snapshot read-only + checksum, não
submodule, README depreciado) permanece válido e é incorporado por referência
— o que muda é o gatilho e a adição do inbox.

## Decisão 1 — Gatilho: data fixa + dono

- **Data**: **2026-06-30**. Não é "quando a release sair"; é uma data de
  calendário.
- **Dono**: **Maurício**. Na data, o dono decide: EXECUTAR a migração,
  REAGENDAR (nova data explícita, registrada aqui) ou CANCELAR (status
  REJECTED). Silêncio não é opção válida.
- **Dependências**: ciclos C2 (fronteira) e C3 do plano do protocolo
  concluídos antes da execução. Se na data não estiverem, o dono reagenda —
  a decisão volta para a mesa de qualquer forma.
- **DESACOPLADO do freeze da V206**: o estado da release do Credenciamento
  (freeze, validação tela a tela, V207) não bloqueia nem dispara este ADR.
  São trilhos independentes por decisão explícita (Q4, 2026-06-10).
- **Reabertura obrigatória**: se 2026-06-30 passar sem ação do dono, qualquer
  IA com bastão no usehbn DEVE reabrir o tópico no próximo handoff/STATE
  (sinal aberto: "🟠 ADR-008 venceu sem decisão do dono").

**Meta-regra (vale para todo ADR daqui em diante): nenhuma decisão pode
ficar bloqueada por evento sem dono.** Todo bloqueio declara `gatilho:`
(data) e `dono:` (pessoa). Evento externo pode ser citado como contexto,
nunca como condição de desbloqueio por si só. Esta meta-regra corrige a
falha de desenho que manteve a v1 parada.

## Decisão 2 — Inbox por projeto (fronteira de escrita)

Estrutura nova no repo canônico:

```
usehbn/inbox/
  README.md                      ← contrato (depositado junto com este ADR)
  credenciamento/
    <AAAAMMDD-NN>-<slug>.md      ← id per ADR-011, namespaced pela pasta
  timelessphoto/
  <novo-projeto>/
```

- Projetos NUNCA editam o canônico diretamente: depositam PROPOSTAS no seu
  subdiretório do inbox. O namespace por pasta + id `AAAAMMDD-NN` (ADR-011)
  elimina por construção colisões tipo 0014×0014 — N projetos alimentam o
  protocolo sem disputar contador.
- **Consolidação (papel do arquiteto)**: o arquiteto useHBN lê o inbox a cada
  ciclo, e para cada item decide: (a) vira ADR/knowledge/core-spec proposto
  no canônico (com `origem:` apontando o item do inbox), (b) é recusado com
  justificativa de 1 parágrafo appendada ao próprio item, ou (c) é adiado com
  `gatilho:`+`dono:` (meta-regra acima). Em todos os casos o item vira
  `temperatura: frio` com link para o destino — nunca deletado.
- Itens do inbox nascem `temperatura: quente` e `status: proposed`; nada
  no inbox governa o protocolo por si — só o que o arquiteto consolidar e
  Maurício aprovar por hearback.

## Decisão 3 — Plano de migração (executa no gatilho)

Reusa a matriz MD-K (`auditoria/00_status/08_MD_K_*.md` — origem→destino já
mapeada) e o desenho técnico da v1:

1. **Auditoria diff**: cross-IA confirma diff = 0 entre
   `Credenciamento/usehbn/` e os destinos canônicos da matriz MD-K.
   Pendências de migração viram itens de inbox, não bloqueio.
2. **`radar/` migra como está** — fagocitose parada, sem redesenho nesta
   rodada (decisão Q4). Vira `frio` no destino; redesenho é ciclo futuro.
3. **Substituição**: `Credenciamento/usehbn/` → README depreciado de 1 linha
   (texto da v1 §2) + `.usehbn-snapshot/` read-only com `VERSION` +
   `PROTOCOL_SHA256.txt` (desenho da v1 §3, validação por
   `bin/usehbn-verify.sh` / sinal 🪞 HBN MIRROR DRIFT).
4. **AGENTS.md do Credenciamento**: seção de dependência (v1 §4) + read-list
   de retomada apontando para o snapshot, e feedback de protocolo passa a
   fluir SÓ via `usehbn/inbox/credenciamento/`.
5. Commit dedicado por etapa; rollback = `git revert` (nada destruído).

## Consequências

Positivas: decisão deixa de envelhecer sem dono; fronteira
protocolo×projetos ganha endereço único e sem colisão; firewall 0022 e o
modo "projetos só propõem" ficam materializados em estrutura de pastas.
Negativas: mais uma data na agenda do dono (mitigada: reabertura é obrigação
de quem tiver o bastão); inbox exige disciplina de consolidação por ciclo.

## DONE-check

Existe endereço único para feedback de cada projeto
(`inbox/<projeto>/<AAAAMMDD-NN>-<slug>.md`), sem colisão por construção, e o
gatilho da migração tem data (2026-06-30) + dono (Maurício) + regra de
reabertura.

## Versão

- v2.0 — 2026-06-10 — claude-fable-5, corrente C2 — re-deposit por decisão Q4
  de Maurício (data+dono; inbox; radar como está). Supersede v1 quando aceito.
