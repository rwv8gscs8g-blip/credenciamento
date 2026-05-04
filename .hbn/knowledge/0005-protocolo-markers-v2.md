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
