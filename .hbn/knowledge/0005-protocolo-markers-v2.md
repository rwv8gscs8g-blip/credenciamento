---
titulo: Protocolo HBN — Marcadores e Delta Card V2
data: 2026-05-02
autoria: Claude Opus 4.7 (Cowork) com base em propostas de Antigravity (link 1) e Codex (link 2) na cadeia 2026-05-02 V203 closure
aplica-a: toda IA operando neste repositorio sob protocolo HBN
revisar-em: quarta-feira 2026-05-06 11:45 BRT (primeira automacao semanal apos Onda 11) e a cada quarta subsequente, append-only
status: vigente a partir de 2026-05-02 (Onda 11 V203-rc1 closure)
fonte-primaria: cadeia Antigravity → Codex → Opus, registrada em local-ai/Time_AI/2026-05-02-V203-fechamento/
licenca-target: usehbn-license (AGPLv3) — proposta para promocao ao repositorio publico usehbn
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-protocolo: HBN 0.3.1
---

# Protocolo HBN — Marcadores e Delta Card V2

## Contexto

A cadeia Antigravity → Codex (2026-05-02) que precedeu a Onda 11 do
Credenciamento V12.0.0203 produziu propostas convergentes e
divergentes para evolucao do conjunto de marcadores semanticos do
HBN. Este documento canoniza a versao V2 e fixa o "delta card" de 7
linhas como retorno padrao de IA em modo operacional.

A versao anterior (V1) tinha 3 marcadores: `✅ HBN ACTIVE`,
`🟡 HBN NEEDS HUMAN DECISION`, `❌ HBN SECURITY BLOCKED SUGGESTION`.
Esses 3 permanecem. V2 adiciona 7 marcadores novos, ranqueados por
prioridade de adocao com base no que efetivamente teria evitado o
erro do Antigravity (diagnosticar contra fonte errada por nao
detectar drift G7).

## Tabela canonica V2

| Marker | Origem proposta | Uso | Prioridade |
|---|---|---|---|
| `✅ HBN ACTIVE` | V1 (vigente) | Protocolo engajado; abre cada ciclo. | Cor |
| `🟡 HBN NEEDS HUMAN DECISION` | V1 (vigente) | Aprovacao humana requerida antes de prosseguir. | Cor |
| `❌ HBN SECURITY BLOCKED SUGGESTION` | V1 (vigente) | Gate de seguranca recusou proposta. | Cor |
| `🟠 HBN SOURCE DRIFT DETECTED` | Codex 2026-05-02 | Duas fontes declaradas canonicas divergem. **Bloqueia fechamento ate resolucao humana.** Exemplo: src/vba ≠ local-ai/vba_import. | **CRITICA** |
| `🔴 HBN RELEASE BLOCKER` | Codex 2026-05-02 | Falha impede tag/release, ainda que pesquisa possa continuar. | **CRITICA** |
| `🔵 HBN HANDOFF READY` | Antigravity 2026-05-02 | IA atual fechou seu escopo limpamente; proxima IA pode assumir contexto. Essencial em cadeias multi-IA. | Alta |
| `⚪ HBN AUDIT-ONLY` | Codex 2026-05-02 | IA nao tem bastao executor; so escreve diagnostico/proposta. | Alta |
| `🟢 HBN CHECKPOINT CLEAN` | Codex 2026-05-02 | Onda/microdelta fechou com artefatos, gate e ERP consistentes. | Media |
| `🟤 HBN LICENSE SPLIT REQUIRED` | Codex 2026-05-02 | Ciclo cruza repos/licencas distintas; cada artefato declara alvo. | Media |
| `🟣 HBN PEER REVIEW REQUESTED` | Antigravity 2026-05-02 | Revisao humana de UI ou revisao tecnica IA-IA solicitada. Distinguir explicitamente os dois casos. | Media |

## Delta card (formato canonico de retorno operacional)

Todo retorno operacional de IA em `safe_track` deve abrir com um
delta card de ate 7 linhas. Reduz latencia de leitura para o
operador e facilita colagem em `relay/` e `readbacks/`.

```text
HBN mode: audit-only | executor
Baton: <owner>
Scope: <onda/microdelta>
Touched paths: <paths or none>
Gate run: <none/manual/command>
Evidence: <csv/log/doc>
Decision needed: <yes/no>
```

Cada campo eh obrigatorio. Se nao se aplica, escrever `none` ou
`n/a` literal — nunca omitir linha.

## Formato de retorno em interrupcao incompleta

Quando uma IA nao puder concluir, deve emitir antes de encerrar:

```text
Last clean checkpoint:
Files written:
Files intentionally not touched:
Evidence collected:
Open blockers:
Recommended next action:
```

Isso evita finais narrativos sem continuidade operacional.

## Comandos `hbn` derivados (especificacao para Wave 11+ de implementacao)

Os marcadores e delta card seriam reforcados por uma CLI
`hbn` que materializa o protocolo em codigo. Implementacao Python
prevista para segunda-feira 2026-05-04 (apos fechamento V12.0.0203-rc1).

| Comando | Funcao | Marcador associado |
|---|---|---|
| `hbn baton status` | Mostra dono do bastao, modo, proxima acao, bloqueios. | ✅ ⚪ |
| `hbn drift check --source src/vba --package local-ai/vba_import` | Detecta drift G7 antes de fechamento. | 🟠 |
| `hbn preflight symbols --domain vba --paths ...` | Lista assinaturas, UDTs, visibilidade, chamadas qualificadas suspeitas (L14). | — |
| `hbn answer scan --policy g6` | Escaneia resposta/artefato antes de enviar ao operador (G6 enforced). | — |
| `hbn license split --artifacts ...` | Exige `licenca-target` por arquivo quando ha mais de uma licenca. | 🟤 |
| `hbn phago candidate` | Gera candidato de licao com evidencia e redacao. | — |
| `hbn weekly-review` | Automacao quarta-feira 11:45 BRT (15 min antes da renovacao do pacote Claude Opus). | 🔵 |

## Convergencias e divergencias documentadas

### Convergencia plena entre Antigravity e Codex

- Marker de handoff (`🔵 HBN HANDOFF READY`) — essencial em cadeias multi-IA
- Marker de peer review (`🟣 HBN PEER REVIEW REQUESTED`) — com distincao UI humana vs revisao tecnica IA
- Readback deve carregar hashes (assinatura de estado), nao apenas narrativa
- Signed commits para qualquer automacao de IA
- Network effect via repositorio publico (`usehbn-rfc` ou `usehbn-rfcs`)

### Divergencias resolvidas pela canonizacao V2

| Tema | Antigravity | Codex | Decisao Opus |
|---|---|---|---|
| Marcadores prioritarios | Sociais (handoff, peer review) | Integridade (drift, blocker, license split) | **Codex tem razao** — integridade vem antes do social. Adotar todos, mas drift/blocker/audit-only sao CRITICOS. |
| JSON-LD em readbacks | Adotar agora | Para futuro; JSON simples + schema basta para V203 | **Codex** — JSON simples + frontmatter; JSON-LD revisita pos-Wave 12. |
| MCP para regras ativas | Read+enforcement | Read-only primeiro; enforcement em CLI local | **Codex** — MCP read-only inicialmente; enforcement vive em `hbn` CLI. |
| Hard constraints no superprompt | Sugestao geral | Ordem formal: 1.constraints 2.bastao 3.paths 4.artefatos 5.missao 6.fontes 7.estilo | **Codex** — adotar ordem formal. |

## Hook de revisao semanal (mecanismo append-only)

Este documento e mutado nao destrutivamente pela automacao de
quarta-feira 11:45 BRT. Regras:

1. **Nunca** reescrever secoes 0-N existentes deste documento.
2. **Acrescentar** bloco no fim com titulo `## YYYY-MM-DD weekly addendum`.
3. Cada addendum contem: novos candidatos a marker, decisoes
   promovidas, itens rejeitados, links de PR/issue.
4. Se uma recomendacao antiga for superada, adicionar
   `supersedes: <secao>` no addendum; **nao editar** a secao
   antiga.
5. PR semanal e draft ate aprovacao do mantenedor (Luís Maurício
   Junqueira Zanin).
6. Promocao para o repositorio publico `usehbn` exige consentimento
   explicito por capsula (proposta D Codex § 2026-05-02).

## Efeito de rede (mecanismo `usehbn-rfcs`)

Fluxo em 4 niveis para que projetos diferentes contribuam para o
protocolo sem ruido:

1. **`local candidate`**: licao fica no projeto local com evidencia
   e consentimento pendente.
2. **`public issue`**: usuario autoriza issue estruturada sem
   payload sensivel.
3. **`rfc draft`**: mantenedores consolidam 3+ candidatos
   semelhantes em RFC.
4. **`protocol PR`**: RFC aceita vira PR para `usehbn` com
   schema/test/docs.

Templates de issue e labels detalhados em
`103b-Codex-Protocolo-usehbn-Propostas.md` § 3.

Anti-ruido: nenhum candidato vira RFC sem gate objetivo ou pelo
menos duas reproducoes independentes em projetos distintos.

## Aplicacao imediata na Onda 11

Esta Onda 11 (V12.0.0203-rc1 closure, em execucao a partir de
2026-05-02) usa V2 desde o readback `0011-onda11-v203-rc1-closure.json`.
Marcadores aplicaveis listados naquele readback.

## Versao

- v1.0 — 2026-05-02 — primeira canonizacao V2 a partir da cadeia
  Antigravity → Codex → Opus 4.7. Registro inicial.

## 2026-05-09 weekly addendum

Origem: sessao Cowork Opus 4.7 entre 2026-05-02 e 2026-05-06 produziu
3 principios operacionais (Minimalismo, Substrato Solido,
AI-Language-Abstraction), modelo das 3 Arvores (Estavel /
Desenvolvimento / Exploracao) e protocolo de Auditoria Cruzada entre
IAs. Cada um desses pede vocabulario semantico proprio. Este addendum
canoniza 11 marcadores adicionais distribuidos em 3 grupos.

Nenhuma secao anterior deste protocolo e modificada. V2 base (10
marcadores ✅ 🟡 ❌ 🟠 🔴 🔵 ⚪ 🟢 🟤 🟣) permanece valida e em uso. O
delta card de 7 linhas continua canonico. O hook de revisao semanal
continua valendo.

### Grupo A — Principios operacionais (3 marcadores)

| Marker | Uso | Prioridade |
|---|---|---|
| `🟦 HBN MINIMALIST GATE` | Decisao de adicao de dependencia/ferramenta passou pelo filtro do Principio Minimalismo de Cadeia. Aplicar em fichas de tecnologia em transicao para `candidate` e em commits que adicionam crate/lib. | Alta |
| `🟪 HBN SUBSTRATO GATE` | Artefato pertence a Arvore Estavel (Rust no substrato comum) ou cumpre criterios de promocao para ela. Aplicar em release notes da Arvore Estavel e em capsulas que migram entre arvores. | Alta |
| `🟧 HBN AI-ABSTRACTION GATE` | Decisao de linguagem/ferramenta foi tomada considerando IA como cliente prioritario, nao apenas humano. Aplicar em escolhas que arquivam tecnologias historicamente "ergonomicas" (Typer, uv) por nao serem mais necessarias na nova ordem. | Media |

Origem: principios formalizados em `usehbn/methodology/MINIMALISM-PRINCIPLE.md`,
`SUBSTRATO-SOLIDO-PRINCIPLE.md`, `AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md`.

### Grupo B — Modelo das 3 Arvores (5 marcadores)

| Marker | Uso | Prioridade |
|---|---|---|
| `🌱 HBN EXPLORATION SEED` | Tecnologia/ideia em Arvore de Exploracao. POC isolado, sem promessa de incorporacao. | Alta |
| `🔧 HBN DEV BRANCH` | Artefato em Arvore de Desenvolvimento. Em transicao de linguagem ou refatoracao ativa. | Alta |
| `🪨 HBN STABLE TRUNK` | Artefato em Arvore Estavel. Compilado, assinado, em uso real. Mudanca exige capsula de consentimento. | **CRITICA** |
| `🟫 HBN TREE TRANSITION` | Artefato cruzando fronteira entre arvores (Exploracao → Desenvolvimento ou Desenvolvimento → Estavel). Evento auditavel. | Alta |
| `🌳 HBN MODULE BOUNDARY` | Indica fronteira entre modulos do useHBN (Fagocitose, Capsulas, Coordenacao inter-IA, Seguranca, Markers, Auditoria Cruzada, Radar). Aplicar em cross-links e em decisoes que tocam mais de um modulo. | Media |

Origem: modelo formalizado em `usehbn/methodology/THREE-TREES-ARCHITECTURE.md`
e `usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md`.

### Grupo C — Auditoria Cruzada entre IAs (3 marcadores)

| Marker | Uso | Prioridade |
|---|---|---|
| `🔄 HBN CROSS-AUDIT IN PROGRESS` | Decisao arquitetural foi submetida a auditoria cruzada entre IAs (Opus + Codex + Antigravity + Gemini ou subset). Resultado pendente. | Alta |
| `✅ HBN CROSS-AUDIT APPROVED` | Auditoria cruzada chegou a consenso. Decisao pode prosseguir. **Disambiguacao:** o emoji `✅` ja e usado para `HBN ACTIVE` (V1). Diferenciar pelo label completo. | Alta |
| `🟡 HBN CROSS-AUDIT ITERATION` | Auditoria cruzada detectou divergencia que pede mais uma rodada. **Disambiguacao:** o emoji `🟡` ja e usado para `HBN NEEDS HUMAN DECISION` (V1). Diferenciar pelo label completo. | Alta |

Origem: protocolo formalizado em
`usehbn/methodology/CROSS-IA-AUDIT-PROTOCOL.md`.

### Reuso de emoji (✅ e 🟡)

V1 ja usa `✅` para `HBN ACTIVE` e `🟡` para `HBN NEEDS HUMAN DECISION`.
Os marcadores Grupo C reusam esses emojis com labels distintos
(`CROSS-AUDIT APPROVED`, `CROSS-AUDIT ITERATION`). A regra de
desambiguacao e: **sempre escrever o label completo**. Em delta cards
e readbacks, o campo de marcador carrega o label canonico, nao o
emoji solto.

Alternativa rejeitada: introduzir emojis novos para Grupo C. Foi
descartada porque (a) a familia ✅/🟡 ja carrega a semantica certa de
"aprovado" e "precisa atencao" e (b) o protocolo prefere reuso
contextual a explosao de simbolos.

### Aplicacao retroativa

A sessao Cowork 2026-05-06 ja usou alguns destes marcadores
informalmente (notavel: 🌱 🪨 🟫 em RADAR.md). Esta canonizacao
formaliza o uso. Documentos publicos do useHBN em
`usehbn/methodology/` e `usehbn/modules/` referenciam esta tabela
como fonte canonica.

### Total apos addendum

10 (V2 base) + 11 (Grupos A+B+C) = **21 marcadores HBN canonicos**.
Modulo MARCADORES (`usehbn/modules/MARCADORES.md`) consolida
mapeamento marcador → modulo de origem em tabela unica.

## 2026-05-09 weekly addendum (correcao Grupo C)

supersedes: linhas 207-209 do addendum anterior (Grupo C — Auditoria
Cruzada) e a secao "Reuso de emoji (✅ e 🟡)" subsequente.

Origem: auditoria cruzada Antigravity sobre os 6 modulos publicos
recem-formalizados (relatorio em
`usehbn/audits/RELATORIO-ANTIGRAVITY-MODULOS-2026-05-09.md`) sinalizou
risco de confusao cognitiva pelo reuso dos emojis `✅` e `🟡` nos
marcadores Grupo C. Argumento aceito: leitura rapida decodifica icone
antes do label, e o ganho de minimalismo simbolico do reuso e
desproporcional ao risco operacional.

A correcao e aplicada antes que os tres marcadores entrem em uso
operacional efetivo (ainda na mesma sessao em que foram propostos).

### Tabela revisada — Grupo C — Auditoria Cruzada

| Marker (canonico) | Marker (anterior, descontinuado) | Uso | Prioridade |
|---|---|---|---|
| `🔍 HBN CROSS-AUDIT IN PROGRESS` | `🔄 HBN CROSS-AUDIT IN PROGRESS` | Decisao arquitetural foi submetida a auditoria cruzada entre IAs. Resultado pendente. | Alta |
| `🤝 HBN CROSS-AUDIT APPROVED` | `✅ HBN CROSS-AUDIT APPROVED` | Auditoria cruzada chegou a consenso. Decisao pode prosseguir. | Alta |
| `⚖️ HBN CROSS-AUDIT ITERATION` | `🟡 HBN CROSS-AUDIT ITERATION` | Auditoria cruzada detectou divergencia que pede mais uma rodada. | Alta |

A familia inteira foi unificada (3 emojis univocamente relacionados a
auditoria) em vez de manter `🔄` apenas na entrada do fluxo, para
coerencia visual: lupa investiga, aperto de mao consente, balanca pesa
divergencia.

### Secao "Reuso de emoji (✅ e 🟡)" descontinuada

A secao "Reuso de emoji (✅ e 🟡)" do addendum anterior nao se aplica
mais — a familia de auditoria cruzada agora usa simbolos univocos. A
desambiguacao por label completo continua valendo como regra geral
para outros possiveis casos futuros, mas nao ha mais reuso ativo entre
V1/V2 base e Grupo C.

### Total apos correcao

Permanece **21 marcadores HBN canonicos** (a contagem nao muda; apenas
3 deles trocaram de simbolo).
