---
adr-id: ADR-024
titulo: Orquestração-start — rito de elenco, orquestrador reinicializável, Ponteiro HBN, Relato de Estado, numeração paralela e captura de tacit drift
status: ACCEPTED
data-deposito: 2026-06-10
id-global: 20260610-202123-fable-5-adr-orquestracao-start   # regra nova (Decisão 5) — created_at autoritativo no REGISTRY
path: methodology/adr/ADR-024-orquestracao-start.md
temperatura: quente
autor: claude-fable-5 (arquiteto useHBN, janela limpa pós-fechamento E)
cross-ia-required: Codex + Antigravity (consolida brainstorm das 3 famílias; autor Anthropic NÃO audita — ADR-018)
hearback-status: confirmed
prioridade: P1
tier-desta-mudanca: T2 (normativo — ADR + 4 specs core + 4 guard-specs; NENHUM guard ativado no runner)
aplica-a: protocolo usehbn; apps consumidoras recebem proposta via inbox (Q1)
relacionado:
  - .hbn/proposals/0001-fable5-orquestracao-start.md (origem 1/3)
  - .hbn/proposals/0001-codex-orquestracao-start.md (origem 2/3)
  - .hbn/proposals/0042-antigravity-orquestracao-start.md (origem 3/3)
  - methodology/adr/ADR-011-enderecamento-numeracao-temperatura.md (Decisão 5 o estende)
  - methodology/adr/ADR-015-perfis-de-modelo.md
  - methodology/adr/ADR-018-papeis-chapeus-anti-groupthink.md
  - methodology/adr/ADR-020-anti-validacao-de-teatro.md
  - methodology/adr/ADR-021-documentos-auto-localizaveis.md
  - methodology/adr/ADR-022-saida-de-auditoria-legivel.md
  - methodology/adr/ADR-023-integridade-de-hearback.md
  - core/start-rite-spec.md
  - core/orchestrator-profile-spec.md
  - core/pointer-spec.md
  - core/state-report-spec.md
evidencia-motivadora: |
  (1) Colisão REAL de numeração entre escritores paralelos hoje:
  .hbn/proposals/0001-fable5-* × 0001-codex-* — dois "0001" no mesmo dia,
  exatamente a classe de colisão que o ADR-011 mitigou para frentes em dias
  distintos mas não para escrita PARALELA no mesmo dia. (2) O REGISTRY
  chegou a 20260610-99: o NN de 2 dígitos saturou EM UM ÚNICO DIA de
  orquestração multi-IA. (3) A janela do orquestrador conversacional é a
  única sem rito de reinicialização (baseline 0177: 238–393 KB de colagem
  para ~20 linhas de presente). (4) Decisão de Maurício: "ADR sem
  enforcement é só md" — cada regra daqui nasce com guard-spec + teste
  negativo, ou é marcada doutrina-sem-enforcement explicitamente.
---

# ADR-024 — Orquestração-start consolidada

## Status

**ACCEPTED** — adotado pelo readback 0004 confirmado, após cross-IA
(Codex + Antigravity) e hearback humano commitado (ADR-023). Guards
especificados aqui NÃO entram no runner nem na adoção deste ADR: ativação é
onda própria (ADR-020 Decisão 2).

## Contexto

Três brainstorms paralelos (Fable-5, Codex, Antigravity — origens no
front-matter) atacaram a mesma fadiga: o orquestrador conversacional acumula
contexto sem rito de reinicialização, e a passagem entre janelas usa colagem
que trunca. O humano + orquestrador já decidiram o desenho; este ADR
consolida e dá dente. Divergências resolvidas na consolidação:

- `usehbn start` EXECUTOR via CLI com flags (Antigravity §1) foi REJEITADO em
  favor do rito DECLARATIVO (Fable §1, Codex §1): o start imprime, o humano
  comita. Orquestração por CLI permanece FUTURA (roles-assignment-spec §5).
- `--register-model` com uso imediato (Antigravity §1) foi REJEITADO: perfil
  novo é mudança T2 com evidência citável + hearback (ADR-015). O start só
  recusa e imprime o esqueleto.
- "Cápsula colada em chat novo" (Antigravity §2) foi SUBSTITUÍDA por
  contrato em disco + read-list: colagem é o problema, não a solução. A
  cápsula sobrevive como DESTILAÇÃO de decisões informais no handoff
  (Decisão 6), não como veículo de estado.
- Ponteiro de 3 linhas (Fable §3) e de 1 linha (Codex §3) foram fundidos na
  forma de 1 linha com path relativo canônico + href absoluto opcional
  (Decisão 3); `#L<linhas>` (Antigravity §3) entra como opcional do href.

## Decisão 1 — `usehbn start`: rito declarativo de elenco

**`usehbn start` é o NOME de um RITO, não um comando de software.** Não
existe — e esta onda decide que NÃO deve existir — subcomando `start` em
`src/usehbn/cli.py`; afirmar o contrário seria Truth Barrier (cross-audit
0031 F-04). Quem executa o rito é o **orquestrador conversacional** (o
modelo, no chat), lendo o disco e imprimindo texto.

O rito lê os perfis (`.hbn/models/*.json`, ADR-015), valida
aptidão (`papeis_aptos`) e o invariante anti-groupthink — reusando a LÓGICA
do `guards/assert-role-family.sh`, nunca uma reimplementação divergente — e
**IMPRIME** o bloco `atribuicao` (roles-assignment-spec §2) + o elenco.
**Quem comita é o humano**; a atribuição só vige commitada no STATE.
A única face executável do desenho é o guard G-STR, invocado sob demanda
(`bash guards/assert-start-cast.sh <atribuicao.json>`) — e guard não é o
rito: ele confere o que o rito imprimiu.
Bypass de liveness (fornecedor fora do ar) só por `hearback_ref`
dereferenciável (ADR-020). IA nova (ex.: Jules) = novo perfil ADR-015,
mudança T2 com evidência; o start recusa apelido sem perfil e imprime o
esqueleto com `nao_verificado` preenchido. Forma normativa:
`core/start-rite-spec.md`. Enforcement: guard **G-STR** (spec na própria
start-rite-spec §4).

## Decisão 2 — Perfil do orquestrador: contrato curto reinicializável

O papel `conversacional-orquestrador` ganha contrato ≤1 página em
`agents/` — POR REFERÊNCIA à doutrina (ADR-x, knowledge-x), nunca cópia.
Cláusulas: verificar-no-disco, auditoria cruzada (nunca auto-auditoria),
julgamento honesto inclusive contra si, humano no gate, nunca empilhar
proposed, entrega operacional minimalista (knowledge 0002), cláusula de
fadiga no `handoff_threshold` do perfil ativo (ADR-015). Conteúdo normativo:
`core/orchestrator-profile-spec.md`; o arquivo em `agents/` materializado na
adoção é PONTEIRO para a spec (referência, não cópia — mesmo para si mesmo).
Enforcement: **doutrina-sem-enforcement, backlog** (contrato de
comportamento não é checável por guard; o gatilho de fadiga já é
parametrizado pelo perfil ADR-015 e o Relato de Estado da Decisão 4 é a face
checável da saída).

## Decisão 3 — Ponteiro HBN: 1 linha, gerado do disco

Toda passagem de artefato entre janelas usa 1 linha: símbolo HBN + link
clicável (texto = path RELATIVO à raiz, que é a verdade; href `file://`
absoluto + `#L<linhas>` opcionais) + sinal + ação. O path da linha é
IDÊNTICO ao `path:` do front-matter do destino (ADR-021) e o ponteiro é
GERADO lendo o disco depois de escrever — nunca de memória. Forma normativa:
`core/pointer-spec.md`. Enforcement: guard **G-PTR** (spec na pointer-spec).

## Decisão 4 — Relato de Estado: bloco fixo ≤10 linhas antes de todo bastão

Toda sessão termina com bloco fixo ≤10 linhas (ADR-022): linha STATE com o
`ultima_atualizacao` EXATO do arquivo pós-atualização (denuncia relato de
memória), sinais, feito/pendente, próxima ação, Ponteiro(s) HBN,
linha-humano (knowledge 0002). O guard confere
`relato.proxima_acao == STATE.proxima_acao` (igualdade exata). Forma
normativa: `core/state-report-spec.md`. Enforcement: guard **G-RLT** (spec
na state-report-spec).

## Decisão 5 — Numeração de escrita paralela: `AAAAMMDD-HHMMSS-<agente>-<slug>` (REGRA NOVA — estende ADR-011)

Evidência: colisão 0001-fable5 × 0001-codex (mesmo dia, escritores
paralelos) e saturação do NN (REGISTRY em 20260610-99 num único dia).

1. Artefato nascido em **escrita paralela** (≥2 escritores no mesmo ciclo
   sem ponto de serialização — ex.: brainstorms, pareceres simultâneos)
   nasce `AAAAMMDD-HHMMSS-<agente>-<slug>.<ext>`. O `<agente>` é o apelido
   de perfil ADR-015. Colisão exigiria mesmo segundo + mesmo agente —
   impossível por construção para um agente serial consigo mesmo.
2. **Escrita serial mantém `AAAAMMDD-NN`** (ADR-011 Decisão 1 intacta);
   séries locais (ADR-NNN, knowledge NNNN…) continuam — este arquivo é
   ADR-024 NA SÉRIE, com `id-global` no formato novo (dogfood).
3. O **REGISTRY grava `created_at` ISO8601** em coluna própria; essa coluna
   é a linha do tempo autoritativa entre ids de formatos mistos. Linhas
   novas usam a tabela de 6 colunas
   `| id | artefato (path) | tipo | temperatura | superseded_by | created_at |`
   em bloco novo append-only — as 5 primeiras colunas preservam a forma que
   o G-REG grepa (compatibilidade verificada na onda de implementação).
4. Relógio: hora LOCAL do operador com offset explícito no `created_at`
   (ex.: `-03:00`); o HHMMSS do id deriva desse mesmo carimbo.

Enforcement: guard **G-NUM** — spec e casos de teste em
`core/start-rite-spec.md` §5 (mora junto do rito porque é o rito que abre
ciclo paralelo e declara quem são os escritores paralelos).

## Decisão 6 — Tacit drift: log frio + cápsula destilada

Instruções informais do humano em chat ("ignora o lint por enquanto")
morrem na troca de janela. Dupla captura:

- **(2a) Log frio**: o log de chat do orquestrador vai para `logs/`
  (protocolo) como artefato FRIO — consulta sob demanda, ARQUIVA não
  deleta, NUNCA em read-list (mesma regra do relay-archive).
- **(cápsula)**: o orquestrador DESTILA as decisões informais da sessão em
  seção própria do handoff (a cápsula é destilação para o disco, não
  colagem para o chat).

Enforcement: a existência da seção de cápsula no handoff é checável e entra
no escopo do G-RLT (state-report-spec §3); o CONTEÚDO da destilação é
**doutrina-sem-enforcement, backlog** (fidelidade de resumo não é guard).

## Mapa de enforcement (a regra de Maurício: "ADR sem enforcement é só md")

| Regra normativa | Guard (spec) | Teste negativo | Estado nesta onda |
|---|---|---|---|
| D1 start: anti-groupthink/aptidão na atribuição impressa | G-STR — start-rite-spec §4 | atribuição groupthink sem hearback → BLOCK | spec + casos especificados; implementação .sh + suíte verde = metade 2 |
| D3 ponteiro honesto (path = front-matter, existe no disco) | G-PTR — pointer-spec §3 | ponteiro p/ path inexistente ou ≠ `path:` → BLOCK | idem |
| D4 relato fresh (proxima_acao == STATE; ultima_atualizacao exato) | G-RLT — state-report-spec §4 | relato divergente do STATE → BLOCK | idem |
| D5 numeração paralela + created_at no REGISTRY | G-NUM — start-rite-spec §5 | artefato paralelo sem HHMMSS-agente; linha sem created_at → BLOCK | idem |
| D2 contrato do orquestrador | — | — | doutrina-sem-enforcement, backlog (declarado) |
| D6 conteúdo da cápsula | — (presença da seção: G-RLT, heading exato) | seção ausente → BLOCK (presença) | conteúdo: doutrina-sem-enforcement, backlog (declarado) |
| D6 log frio (`logs/`: naming, consulta sob demanda, NUNCA em read-list) | — | — | doutrina-sem-enforcement, backlog (declarado — cross-audit 0030 F-04 / 0031 F-06) |

Nenhuma regra nasce sem linha nesta tabela. NENHUM guard entra no runner
nesta onda; "metade 2" = onda de implementação (.sh + casos na suíte
`guards/tests/run-guard-tests.sh`) ANTES de qualquer ativação, que por sua
vez segue exigindo os testes negativos dos 5 guards legados (STATE).

## Consequências

**Positivas:** orquestrador vira papel reinicializável (janela deixa de ser
o ativo; disco é o ativo); colisão de escritores paralelos impossível por
construção; handoff cai de KBs colados para 1 linha de ponteiro + 10 de
relato; toda regra nova já nasce com seu dente especificado ou com a
ausência dele declarada. **Negativas (assumíveis):** dois formatos de id
convivem (mitigado: `created_at` no REGISTRY é o eixo único); 4 specs novas
para manter; disciplina de relato a cada bastão (~10 linhas — barato).

## Riscos e mitigação

| # | Risco | Mitigação |
|---|---|---|
| R1 | start virar orquestrador CLI (scope creep) | termina IMPRIMINDO; nunca executa nem comita; §5 da roles-assignment-spec segue FUTURO |
| R2 | ponteiro errado pior que colagem | gerado-do-disco obrigatório + G-PTR compara com `path:` do destino |
| R3 | relato virar teatro (template sem ler disco) | linha STATE exige `ultima_atualizacao` exato do arquivo; G-RLT compara |
| R4 | perfil do orquestrador inchar (novo monólito) | ≤1 página, só referência; estado no STATE, história no archive |
| R5 | coluna created_at quebrar o G-REG | bloco novo de tabela preserva as 5 colunas grepadas; caso de teste dedicado na metade 2 |

## Próximo passo

1. Cross-IA: Codex + Antigravity (autor é Anthropic; ADR-018).
2. Hearback humano commitado (ADR-023) → ACCEPTED.
3. Metade 2 (onda própria): implementar G-STR/G-PTR/G-RLT/G-NUM em
   `guards/` + casos na suíte; só então discutir ativação (que ainda
   depende dos testes dos 5 guards legados).
4. Na adoção: materializar `agents/` ponteiro do perfil do orquestrador;
   criar `logs/` com README de 3 linhas (frio, sob demanda, nunca read-list).

## DONE-check

As 6 decisões têm linha no mapa de enforcement; cada uma ou aponta
guard-spec com caso negativo especificado, ou declara
"doutrina-sem-enforcement, backlog". As 4 specs core existem com `path:`;
REGISTRY tem as linhas com `created_at`. Nada no runner; nada commitado
por IA.

## Versão

- v1.0 — 2026-06-10 — claude-fable-5 — consolidação dos 3 brainstorms (PROPOSED).
- v1.1 — 2026-06-10 — claude-fable-5 — FIX cross-audits 0030/0031: D1 explicitado como RITO (não comando de cli.py — 0031 F-04); linha D6 log frio no mapa (0030 F-04 / 0031 F-06); cápsula com heading exato (0030 F-02).
- v1.2 — 2026-06-10 — codex — ACCEPTED por readback 0004 confirmado; suíte 63 verde; guards seguem FORA do runner.
