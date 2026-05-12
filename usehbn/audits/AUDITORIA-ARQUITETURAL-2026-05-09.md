---
titulo: Auditoria Arquitetural — 3 questões abertas pelo operador 2026-05-09
tipo: auditoria-interna-pre-cross-audit
audiencia: humano + ia
data: 2026-05-09
licenca: AGPLv3
autor: Claude Opus 4.7 (Frente 2 useHBN)
escopo: registrar honestamente o estado atual sobre 3 pontos antes de submeter cross-audit Codex + Antigravity
status: 🔍 HBN CROSS-AUDIT IN PROGRESS
---

# Auditoria Arquitetural — 3 questões abertas

## Contexto

Mauricio levantou 3 questões arquiteturais em 2026-05-09 após a
Esteira 5 do prompt 46 (skeleton `usehbn-phago` como repo separado):

1. **Repo canônico** — usar `usehbn` como github canônico único, com
   braços como subpastas (mono-repo). Justificativa do operador:
   facilita permissão por pastas + evita IAs perderem contexto.
2. **Confusão módulo × aplicação** — onde começa um módulo do useHBN
   e onde ele "usa" o protocolo? O Credenciamento é módulo ou
   aplicação?
3. **Simplificação documental** — eliminar/atualizar documentos
   obsoletos.

Decisão arquitetural foi expressa firmemente; cross-audit Codex +
Antigravity é solicitado para validação técnica e plano de execução,
não para questionar a direção.

## Q1 — Estado atual da decisão de repositórios

### Documento canônico vigente

[`USEHBN-MODULES-ARCHITECTURE.md`](../methodology/USEHBN-MODULES-ARCHITECTURE.md)
linhas 77-83 declara modelo **poly-repo**:

| Repo | Conteúdo (declarado em 2026-05-06) |
|---|---|
| `usehbn` | princípios + protocolo + V2 docs |
| `usehbn-phago` | módulo de fagocitose |
| `usehbn-capsules` | módulo Cápsulas (futuro) |
| `usehbn-otel-rust` | módulo de observabilidade (futuro) |
| `usehbn-coord` | coordenação inter-IA (futuro distante) |

### Realidade no filesystem

- `~/Projetos/usehbn/` — repo HBN original. Contém estrutura própria
  (CHANGELOG, GOVERNANCE, MAINTAINERS, `agents/`, `core/`, `docs/`,
  `local-ai/`, `src/`, `tests/`, etc.). É o repo "mãe" registrado.
- `~/Projetos/usehbn-phago/` — repo skeleton criado 2026-05-09 pela
  Esteira 5. Contém `modules/` com 9 subdirs (6 useHBN modules + 3
  tech) + 45 .gitkeep + README + pyproject + .gitignore.
- `~/Projetos/Credenciamento/usehbn/` — diretório dentro do repo
  Credenciamento que contém `methodology/` (12 docs), `modules/` (8
  arquivos: 6 módulos + RADAR + INDEX), `radar/` (55 fichas + REGISTRY),
  `audits/`, `docs/`, `study-plans/`. Funciona hoje como **fonte
  efetiva** dos documentos canônicos — todos os arquivos mencionados
  até agora moram aqui.

### Tensão

A **decisão poly-repo de 2026-05-06** previa repos separados. A
**realidade operacional** tem todos os documentos canônicos do useHBN
no Credenciamento (`Credenciamento/usehbn/`), com o `~/Projetos/usehbn/`
sendo um repo independente que ainda não recebeu os artefatos
recentes (3 princípios, 6 módulos, 21 markers, etc.).

A decisão de Mauricio em 2026-05-09 (mono-repo) **alinha realidade e
declaração** mas **invalida USEHBN-MODULES-ARCHITECTURE linhas 77-83**
e exige resposta para:

- Como migrar `Credenciamento/usehbn/*` para `~/Projetos/usehbn/*`?
- Como tratar `~/Projetos/usehbn-phago/` recém-criado? Migrar para
  `~/Projetos/usehbn/modules/`?
- Como manter relação Credenciamento ↔ usehbn (Credenciamento usa
  protocolo mas tem documentação dentro)?

## Q2 — Estado atual da confusão módulo × aplicação

### Tipologia atual implícita

Os documentos canônicos hoje misturam pelo menos 4 categorias sem
nomeação formal:

| Categoria | Exemplos no projeto | Propósito |
|---|---|---|
| **Protocolo** | princípios, markers, delta card, schemas de cápsula | spec abstrata; sem código |
| **Módulo do protocolo** | Fagocitose, Cápsulas de Consentimento, Coordenação inter-IA, Segurança, Marcadores, Auditoria Cruzada, Radar | implementação ou spec de braço do protocolo |
| **Aplicação que usa o protocolo** | Credenciamento V12.0.0203 | software real que consome markers, delta card, M11, Glasswing, etc. |
| **Tecnologia fagocitada** | Tree-sitter, OpenTelemetry, Rust | tooling externo absorvido pelo protocolo |

### Confusões identificáveis

1. **Credenciamento como "módulo"**: `USEHBN-MODULES-ARCHITECTURE.md`
   linha 130 lista Credenciamento como "caso real" do módulo de
   fagocitose. Mas `usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md`
   linha 50 também o classifica como "Caso de uso (referência
   externa)". Há ambiguidade sobre se é módulo, caso ou aplicação.

2. **`Credenciamento/usehbn/` como source-of-truth**: o diretório dentro
   do Credenciamento contém TODA a documentação canônica do useHBN
   (12 docs methodology, 8 docs modules, 55 fichas radar). Isto sugere
   que o Credenciamento NÃO é mero usuário do protocolo — é o lugar
   onde o protocolo está sendo escrito. Posicionamento de Frente 1 vs
   Frente 2 confunde isso.

3. **Frentes 1 e 2 compartilham `auditoria/00_status/`**: numeração
   33-46 mistura tracking de Credenciamento V12.0.0203 (43_HANDOFF,
   44_DEBITO, 45_ERRO) com tracking do useHBN (43_PLANO, 44_CORRECAO,
   45_TRANSCRICAO). Isso amplia a confusão sobre fronteiras.

4. **`usehbn-phago` como repo do "módulo de fagocitose"**: confunde
   "fagocitose" como módulo do protocolo com "phago" como repo onde
   módulos vivem. O nome do repo (phago) sugere fagocitose-cêntrica,
   mas seu conteúdo (após Esteira 5) tem 9 módulos incluindo os
   outros 5 do useHBN + 3 tech.

### Hipóteses tipológicas a testar no cross-audit

- **Hipótese A — Credenciamento é aplicação**: useHBN é protocolo;
  Credenciamento é aplicação que consome o protocolo. A documentação
  do useHBN moveria para `~/Projetos/usehbn/`; Credenciamento
  manteria apenas links/refs para o protocolo canônico. Análogo:
  HTTP é protocolo; nginx é servidor que implementa; Wikipedia é
  aplicação que usa.
- **Hipótese B — Credenciamento é módulo do useHBN**: Credenciamento
  é UM módulo (de aplicação real do protocolo, fonte de lições) entre
  os 6+. Análogo: VS Code "extension" — protocolo de extensão + cada
  extensão é módulo.
- **Hipótese C — Credenciamento é "caso fundador"**: nem aplicação
  externa, nem módulo formal — é o estudo de caso onde o protocolo
  emergiu. Análogo: WebKit nasceu do KHTML; Tree-sitter nasceu do GitHub.
  Caso fundador permanece referência mas não é parte do protocolo.

Cada hipótese tem implicações distintas para layout de repo,
permissões, governance. Precisa de cross-audit.

## Q3 — Estado atual da documentação (inventário e suspeitas de obsolescência)

### Inventário (apenas escopo useHBN)

**`Credenciamento/usehbn/methodology/`** (12 docs):

| Documento | Suspeita | Decisão potencial |
|---|---|---|
| `MINIMALISM-PRINCIPLE.md` | OK | manter — fonte canônica P11 |
| `SUBSTRATO-SOLIDO-PRINCIPLE.md` | OK | manter — fonte canônica P12 |
| `AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md` | OK | manter — fonte canônica P13 |
| `PRINCIPIOS-CONSTITUCIONAIS.md` | NOVO 2026-05-09 | manter — índice canônico unificado |
| `THREE-TREES-ARCHITECTURE.md` | OK | manter |
| `USEHBN-MODULES-ARCHITECTURE.md` | parcialmente obsoleto (Q1: poly-repo declarado) | atualizar pós cross-audit |
| `LANGUAGE-PLATFORM-COMPARISON.md` | possivelmente obsoleto (Rust já decidido) | revisar — talvez virar apêndice histórico |
| `RADAR-PHAGOCYTOSIS-PIPELINE.md` | duplica conceitualmente FAGOCITOSE.md + RADAR.md | consolidar — este é insumo, módulos são canônicos |
| `INCORPORATION-PROGRESSIVE-PLAN.md` | duplica FAGOCITOSE.md (F0-F5) | consolidar |
| `INTER-CHAT-COORDINATION.md` | duplica COORDENACAO-INTER-IA.md | consolidar |
| `CROSS-IA-AUDIT-PROTOCOL.md` | duplica AUDITORIA-CRUZADA.md | consolidar |
| `RADAR-WEEKLY-REVIEW-PROTOCOL.md` | possivelmente sub-componente do RADAR.md | revisar |

**`Credenciamento/usehbn/modules/`** (8 docs — todos novos 2026-05-09):

| Documento | Status |
|---|---|
| `INDEX.md` | OK — índice |
| `RADAR.md` | OK — template canônico |
| `FAGOCITOSE.md` | OK — pós cross-audit Antigravity |
| `CAPSULAS-DE-CONSENTIMENTO.md` | OK |
| `COORDENACAO-INTER-IA.md` | OK |
| `SEGURANCA.md` | OK |
| `MARCADORES.md` | OK |
| `AUDITORIA-CRUZADA.md` | OK |

**`auditoria/00_status/` (Frente 2 useHBN apenas):**

| Documento | Suspeita |
|---|---|
| `38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md` | obsoleto pós multi-braço (V1 cêntrica em fagocitose) — preservar como histórico |
| `41_DECISOES_5_TECNOLOGIAS_EM_CURSO.md` | OK |
| `42_ROADMAP_CONSENT_CAPSULES_RUST.md` | OK |
| `43_PLANO_DOCUMENTACAO_V2_USEHBN.md` (v1.1) | OK |
| `44_CORRECAO_USEHBN_E_CONSOLIDACAO.md` | OK — registra correção multi-braço |
| `45_TRANSCRICAO_SESSAO_2026-05-06.md` | OK — referência histórica |
| `46_PROMPT_UNIFICADO_CODEX.md` | OK — em uso (status: Esteiras 1-4 em hold) |

**Conflitos de numeração entre Frentes** em `auditoria/00_status/`:
- `43_HANDOFF` (Frente 1) vs `43_PLANO` (Frente 2)
- `44_CORRECAO` (Frente 2) vs `44_DEBITO` (Frente 1)
- `45_ERRO` (Frente 1) vs `45_TRANSCRICAO` (Frente 2)

Falta partição clara F1/F2 dentro de `auditoria/00_status/`.

### Critérios de simplificação (a serem validados no cross-audit)

1. **Source-of-truth única por conceito**: cada conceito tem 1
   documento canônico; outros são insumos ou referências.
2. **Insumo vs declaração**: `methodology/` documents que serviram
   de insumo para `modules/` declarações ficam como insumo (não como
   spec canônica).
3. **Tracking interno vs declaração pública**: `auditoria/00_status/`
   é Frente 1; documentos de Frente 2 podem migrar para `usehbn/`
   canônico se mono-repo for adotado.
4. **Append-only para o que já foi publicado externamente**: V1 da
   tese 38 fica preservada; revisões viram addendums.

### Estimativa preliminar de redução

- 12 docs em `usehbn/methodology/` → ~7 docs (consolidar 5 que duplicam
  módulos)
- 7 docs em `auditoria/00_status/` (Frente 2) → ~5 docs (38 vira
  histórico; 44 absorvido em USEHBN-MODULES-ARCHITECTURE)

## Próximo passo

Submeter cross-audit Codex + Antigravity. Cada um foca em ângulo
distinto:

- **Codex** — viabilidade técnica, mecânica de tooling, padrões
  open-source
- **Antigravity** — design conceitual, robustez de longo prazo,
  tipologia formal

Após receber as 2 respostas, Opus sintetiza e apresenta:
1. Proposta de solução para cada questão (Q1, Q2, Q3)
2. Roadmap de execução (ordem, dependências, esteiras)
3. Decisões necessárias do operador

Marker desta esteira: 🔍 HBN CROSS-AUDIT IN PROGRESS.

## Restrições durante o cross-audit

- Esteiras 1-4 do prompt 46 (Consent Capsules R-A, Tree-sitter F1,
  OpenTelemetry detalhamento, Typer/uv arquivamento formal) **em
  HOLD** até cross-audit fechar
- Esteira 5 (skeleton em `~/Projetos/usehbn-phago/`) já entregue
  permanece intacta — pode ser migrada se mono-repo for confirmado
- Documentos canônicos do useHBN **não modificados** durante
  cross-audit (preservar estado para análise honesta)
