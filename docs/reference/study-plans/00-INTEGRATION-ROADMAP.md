---
titulo: Roadmap de Incorporação Progressiva das 5 Tecnologias no usehbn-phago
diataxis: how-to
hbn-track: knowledge
hbn-status: active
audiencia: humano + ia
data: 2026-05-02
revisar-em: a cada decisão de promoção
licenca-target: usehbn (AGPLv3)
---

# Roadmap de Incorporação Progressiva

## Princípio condutor

Cada tecnologia entra no `usehbn-phago` como **módulo independente**. Cresce em 3 fases: **embrião** (esqueleto + 1 caso real), **adolescente** (cobre 80% dos casos comuns), **maduro** (extensível por contribuidores externos).

Nenhum módulo precisa estar completo para ser útil. Cada fase termina com cápsula de conhecimento promovida ao repo público.

## Sequência de incorporação recomendada

| Ordem | Tecnologia | Fase pretendida na semana | Razão da ordem |
|---|---|---|---|
| 1 | **uv** | embrião | Pré-requisito de tudo que rodar Python no `usehbn-phago`; instalação trivial |
| 2 | **Typer** | embrião | Pré-requisito da CLI `hbn`; depende de uv para gerenciar |
| 3 | **Tree-sitter** | embrião | Primeiro caso de uso real do hbn-phago: parsear VBA do Credenciamento |
| 4 | **OpenTelemetry** | esqueleto (não embrião — opcional na semana) | Útil mas não bloqueia outras decisões; pode esperar |
| 5 | **Consent capsules** | embrião | Necessário ANTES de qualquer publicação real (mesmo que código não esteja pronto, ter spec) |

### Por que esta ordem

- **uv → Typer**: stack CLI tem dependência clara (uv instala Typer)
- **Typer → Tree-sitter**: CLI é o canal pelo qual Tree-sitter será exposto (`hbn parse <file>`)
- **Tree-sitter antes de OTel**: parsing dá valor imediato; observabilidade é valor de auditoria (importante mas posterior)
- **Consent capsules em paralelo**: pode ser desenhada por mim (Opus) enquanto Codex implementa o resto

## Grafo de dependências

```text
                 ┌──────────────┐
                 │ Consent      │  (paralelo — não bloqueia)
                 │ capsules     │
                 └──────────────┘

┌──────┐         ┌──────┐         ┌──────────────┐
│ uv   │───────▶ │Typer │───────▶ │ Tree-sitter  │
└──────┘         └──────┘         └──────────────┘
                                          │
                                          ▼
                                  ┌──────────────────┐
                                  │ OpenTelemetry    │  (auditoria do parsing)
                                  └──────────────────┘
```

Lock-in entre módulos: **mínimo**. Cada um tem interface própria. Substituição de qualquer um não derruba os outros.

## Estrutura final pretendida do usehbn-phago

```text
usehbn-phago/
├── pyproject.toml              # uv-managed
├── uv.lock                     # determinístico
├── LICENSE                     # AGPLv3
├── README.md
├── PRINCIPLES.md
├── docs/
│   ├── modules/
│   │   ├── parsing.md          # como usar Tree-sitter via hbn-phago
│   │   ├── cli.md              # comandos hbn disponíveis
│   │   ├── telemetry.md        # OTel — opcional
│   │   └── capsules.md         # consent capsules
│   └── tutorials/
│       └── first-fagocitose.md # tutorial: primeira tecnologia fagocitada
└── src/
    └── hbn_phago/
        ├── __init__.py
        ├── cli/                # Typer-based (módulo CLI)
        │   ├── __init__.py
        │   ├── main.py
        │   ├── radar.py
        │   ├── baton.py
        │   └── capsule.py
        ├── parsing/            # Tree-sitter wrapper (módulo parsing)
        │   ├── __init__.py
        │   ├── languages.py    # registro de gramáticas
        │   ├── vba.py          # adapter VBA específico
        │   └── queries/        # queries S-expression versionadas
        │       ├── vba/
        │       │   ├── constants.scm
        │       │   ├── functions.scm
        │       │   └── error-handling.scm
        │       └── cobol/      # futuro
        ├── telemetry/          # OTel SDK wrapper (módulo telemetria)
        │   ├── __init__.py
        │   ├── tracer.py       # decorator @hbn_traced
        │   └── exporters.py    # arquivo JSON local + futuros
        └── capsules/           # cápsulas de consentimento (módulo cápsulas)
            ├── __init__.py
            ├── schema.py       # Pydantic models
            ├── builder.py      # criar cápsula a partir de lição
            ├── validator.py    # validar cápsula
            └── templates/
                ├── lesson.md.template
                └── consent.json.template
```

## Critérios de incorporação por tecnologia

### uv (incorporação embrião)

**Sinais de "incorporada":**
- `pyproject.toml` válido no `usehbn-phago/`
- `uv.lock` versionado e reprodutível
- README documenta `uv sync` como instalação padrão
- 1 contribuidor externo (Maurício) consegue instalar em < 30s

**Testes de incorporação:**
- `uv sync --frozen` em CI passa
- `uv sync` em macOS Sequoia (Maurício) e Linux (Codex CLI) reproduz mesmo ambiente
- `uv export --format requirements-txt` produz arquivo pip-compatível (fallback)

**Cápsula de conhecimento gerada:**
- `capsule-001-uv-bootstrap.md` — lições do bootstrap (gotchas, comparativo com pip, padrões adotados)

### Typer (incorporação embrião)

**Sinais de "incorporada":**
- `src/hbn_phago/cli/main.py` define `app = typer.Typer()`
- 3 comandos funcionais: `hbn baton status`, `hbn radar list`, `hbn capsule validate`
- Autocompletion instalado (`hbn --install-completion`)
- Test runner (`pytest tests/cli/`) com `CliRunner`

**Testes de incorporação:**
- Comandos respondem em < 200ms (cold start aceitável para uso CLI)
- `hbn --help` lista subcommands; cada subcommand tem `--help` próprio
- Autocompletion funciona em zsh do Maurício

**Cápsula de conhecimento gerada:**
- `capsule-002-typer-cli-patterns.md` — patterns de design de CLIs com Typer aprendidos no uso real

### Tree-sitter (incorporação embrião)

**Sinais de "incorporada":**
- `src/hbn_phago/parsing/vba.py` parseia `.bas` files via `tree-sitter-vba`
- 3 queries S-expression versionadas: `constants.scm`, `functions.scm`, `error-handling.scm`
- Comando `hbn parse <file>` mostra árvore + extrai constantes/funções

**Testes de incorporação:**
- Parsea 100% dos `.bas` do Credenciamento sem `ERROR` nodes não-esperados
- Extrai mesmo conjunto de constantes que o regex do Importador V3 (validação cruzada)
- Documenta gramáticas de outras linguagens-alvo (COBOL, Pascal) com status de maturidade

**Cápsula de conhecimento gerada:**
- `capsule-003-tree-sitter-vba.md` — lições sobre parsing VBA com Tree-sitter (gotchas, queries úteis)

### OpenTelemetry (incorporação esqueleto — opcional na semana)

**Sinais de "esqueleto":**
- `src/hbn_phago/telemetry/tracer.py` define decorator `@hbn_traced`
- 1 comando da CLI emite spans (escolha: `hbn parse <file>`)
- Exportador para arquivo OTLP-JSON local funciona
- Documentação de semantic conventions específicas: `hbn.esteira.id`, `hbn.marker`, `hbn.frente`

**Testes de incorporação:**
- Trace de `hbn parse Const_Colunas.bas` mostra spans com timing (< 100ms total esperado)
- Arquivo `.otlp-json` gerado é parseável e legível
- Desativar telemetria via env var (`HBN_TELEMETRY=off`) funciona

**Cápsula de conhecimento gerada (futura, não obrigatória esta semana):**
- `capsule-004-otel-hbn-instrumentation.md`

### Consent capsules (incorporação embrião — paralelo)

**Sinais de "incorporada":**
- `src/hbn_phago/capsules/schema.py` define Pydantic models (Lesson, Evidence, RedactionMap, Consent, LicenseTarget, Hashes)
- 1 cápsula real montada manualmente: `capsule-001-L18-determinismo.md` (lição L18 do Credenciamento)
- `hbn capsule validate <path>` confirma cápsula bem-formada
- `hbn capsule create --from-lesson <id>` esqueleto inicial (não precisa estar perfeito)

**Testes de incorporação:**
- Cápsula valida schema
- Hashes batem com conteúdo dos arquivos
- redaction-map cobre todas as menções identificadas

**Cápsula de conhecimento gerada (meta — cápsula sobre cápsulas):**
- `capsule-000-capsules-bootstrap.md` — schema + processo de criação + decisões iniciais

## Estratégia de testes em cada incorporação

Cada módulo segue o mesmo padrão de teste:

| Camada | Tecnologia útil | Quando |
|---|---|---|
| **Unit** | pytest | sempre |
| **Integration** | pytest + fixtures reais (arquivos VBA pequenos) | após embrião |
| **Smoke** | scripts em `scripts/smoke_*.sh` | manual antes de cápsula |
| **Characterization** | golden tests (saída salva em arquivo de referência) | quando comportamento estabilizar |
| **Property-based** | hypothesis (futuro) | quando módulo for "maduro" |

Cada cápsula promovida tem **suíte de testes correspondente** documentada.

## Cronograma sugerido (2 semanas — semana de estudo + semana de implementação)

### Semana 1 (2026-W18): estudo (esta semana)
- Sáb-Dom-Seg-Ter: imersão nos study plans + Notebook LM
- Quarta 2026-05-06 (revisão semanal): decisões de promoção

### Semana 2 (2026-W19): incorporação embrião
- Quinta 2026-05-07: spec E2 + bootstrap uv no `usehbn-phago`
- Sex-Sáb 2026-05-08-09: Typer CLI esqueleto + Tree-sitter VBA POC
- Dom 2026-05-10: Consent capsules schema
- Quarta 2026-05-13 (próxima revisão): primeiro relatório de incorporação

## Pontos de decisão (gates de Maurício)

| Gate | Quando | O que decidir |
|---|---|---|
| **G1 — fim da semana de estudo** | quarta 2026-05-06 | Quais 5 viram `convergence-mapped` ou `candidate`? |
| **G2 — pós-bootstrap uv+Typer** | sexta 2026-05-08 | Stack CLI funciona? Avança para módulo parsing? |
| **G3 — pós-POC Tree-sitter VBA** | terça 2026-05-12 | Parsing supera regex? Vale fagocitar (`phagocytosed`)? |
| **G4 — pós-cápsula L18** | terça 2026-05-12 | Schema Consent capsules está bom? Pronto para promover lições reais? |
| **G5 — fim semana 2** | quarta 2026-05-13 | Quais módulos viram `phagocytosed`? Próximas 5 do radar para imersão? |

## Critérios para fagocitose final (`phagocytosed`)

Para um módulo virar `phagocytosed` no useHBN:

1. **Caso de uso real funcionando** (não apenas POC)
2. **Documentação completa em `docs/modules/<nome>.md`**
3. **Testes unit + integration verdes**
4. **Cápsula de conhecimento promovida** (com hashes + consent)
5. **Decisão explícita do Maurício** (palavra final)

## Permeabilidade a novas tecnologias durante a semana

Nada impede que durante o estudo você (Maurício) ou eu (Opus) topemos com tecnologia adicional relevante. Procedimento:

1. Adicionar ficha rápida em `usehbn/radar/_per-technology/<slug>.md` (frontmatter mínimo + 1-3 linhas)
2. Notar no `WEEKLY-UPDATES.md` na próxima revisão
3. Avaliar se merece imersão na próxima semana

A regra é simples: **permeabilidade alta na entrada; filtro de impacto na saída** (vide `RADAR-PHAGOCYTOSIS-PIPELINE.md` § Permeabilidade).

## Versão

- v1.0 — 2026-05-02 — roadmap inicial após hearback "monte plano de incorporação progressiva".
