---
titulo: ADR e MD — primer didático
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ambos (humano + IA)
versao-protocolo: useHBN pre-v1
data: 2026-05-10
autor: Claude Opus 4.7 (chat arquiteto-mestre useHBN)
escopo: definir e diferenciar `ADR` e `MD` como unidades canônicas de evolução do protocolo
---

# ADR e MD — primer didático

> Documento de explicação (Diataxis: explanation). Reflete o uso canônico
> dessas duas unidades no useHBN. Toda IA ou humano novo no projeto deve
> ler este primer antes de propor mudança estrutural.

## Resumo de uma frase

| Sigla | Pergunta que responde | Para quê serve |
|---|---|---|
| **ADR** *(Architecture Decision Record)* | **POR QUE** decidimos isso | Capturar o **raciocínio** atrás de uma decisão arquitetural, no momento em que é tomada |
| **MD** *(Microdelta)* | **COMO** vamos executar | Coordenar uma **mudança operacional atômica** com escopo, gates e rollback explícitos |

ADR é estratégico. MD é operacional. Eles são ortogonais e complementares.

## ADR — Architecture Decision Record

### Origem

Termo cunhado por **Michael Nygard em 2011** ("Documenting Architecture
Decisions"). Adotado depois por ThoughtWorks Tech Radar, Apache Software
Foundation, AWS Well-Architected, Spotify, GitHub. É padrão de fato da
indústria para decisões arquiteturais sérias.

### Por que existe

Decisões arquiteturais geralmente "evaporam": fica o código resultante,
mas ninguém depois sabe **por que** foi feito assim. Quando alguém
propõe mudar 6 meses depois, o time perde tempo redescobrindo a razão
original — ou, pior, muda algo crítico sem saber que era crítico.

ADR captura o **porquê** no momento da decisão, em formato persistente,
auditável e versionado.

### Estrutura clássica (Nygard)

1. **Title** — nome curto e único.
2. **Status** — `Proposed → Accepted → Deprecated → Superseded`.
3. **Context** — quais forças estão em jogo? Qual é o problema?
4. **Decision** — o que foi decidido. Texto curto, direto.
5. **Consequences** — o que melhora, o que piora, o que vira trade-off.

### Estrutura no useHBN (extensões)

Além dos campos de Nygard:

- **`adr-id`** — `ADR-NNN` (NNN ≥ 001, append-only).
- **`prioridade`** — `P0` (bloqueia release), `P1` (importante mas não bloqueia), `P2` (melhoria).
- **`cross-ia-required`** — quais IAs precisam revisar antes de `ACCEPTED`. Mínimo 2 IAs distintas (P10 — Cross-IA obrigatório). ADR constitucional (mudança em P1-P13) exige 3 IAs.
- **`hearback-status`** — registro do Hearback humano (P5 — Humano é raiz da confiança).
- **`riscos e mitigação`** — R1, R2, R3 ... cada risco com mitigação proposta.
- **`próximo passo`** — o que destrava após `ACCEPTED`.
- **`versão`** — histórico de revisões (v1.0, v1.1, ...). Mudanças cosméticas/clarificações não viram ADR novo; mudanças de decisão sim (com `SUPERSEDED-BY: ADR-MMM`).

### Estados estendidos (useHBN)

| Estado | Significado |
|---|---|
| `PROPOSED` | Depositado por arquiteto; aguardando cross-IA |
| `PROPOSED v1.X` | Cross-IA concluído + ajustes aplicados; aguardando Hearback humano |
| `ACCEPTED` | Hearback ratificou; ADR é vinculante |
| `NÃO_RATIFICAR` | Cross-IA detectou bloqueador objetivo; volta à mesa após pré-requisito (geralmente um MD) |
| `SUPERSEDED` | Substituído por novo ADR; histórico preservado, decisão atual é a do sucessor |
| `DEPRECATED` | Decisão não vale mais e não tem sucessor (raro) |

### Append-only

ADR antigo **nunca é deletado**. Quando substituído, ganha
`SUPERSEDED-BY: ADR-MMM` apontando para o sucessor. Isso preserva o
**histórico de raciocínio** do projeto (P7 — Nenhuma tecnologia
fagocitada perde sua identidade).

### O que vira ADR no useHBN

Decisões que afetam **contrato público**: schemas, princípios
constitucionais (P1-P13), licença, topologia de repositórios, sinais
HBN, ritual de sanitização, processo de cross-IA.

### O que NÃO vira ADR

- Bug fix.
- Refactoring interno sem mudança de contrato externo.
- Adição de teste.
- Mudança de redação cosmética (vira PATCH no SemVer, não ADR).

### Onde vivem

`methodology/adr/ADR-NNN-<kebab-slug>.md`. Índice em
`methodology/adr/INDEX.md`.

### Template

`methodology/templates/ADR-TEMPLATE.md`.

---

## MD — Microdelta

### Origem

**Convenção interna do projeto** — não é termo padrão da indústria.
Nasceu no Credenciamento (a Founding Application) como granularidade
ideal para coordenar Codex CLI (cirurgião) e Opus (arquiteto) operando
sobre o mesmo código.

No Credenciamento aparece como `MD-19.1`, `MD-19.2`, `MD-24.3` (MD-X.Y
onde X é a Onda e Y o microdelta dentro da Onda). No useHBN, antes
de termos Ondas numeradas formais, aparece como `MD-A`, `MD-B`...
`MD-K`.

### Por que existe

É a **unidade de execução atômica e auditável**. Resolve um problema
clássico de granularidade:

| Unidade | Problema |
|---|---|
| **Commit** | Granular demais — frequentemente sem contexto, sem teste, sem rollback documentado |
| **Pull Request** | Pode ser grande demais — muitas mudanças misturadas, difícil de reverter cirurgicamente |
| **Issue/Ticket** | Descreve problema, não solução com plano e rollback |

MD é o ponto certo no meio: grande o suficiente para ter contexto +
plano + rollback documentados; pequeno o suficiente para reverter via
`git revert` sem dor.

### Estrutura típica de um MD

1. **Tema** — o que muda em uma frase.
2. **Pré-requisito** — o que precisa estar pronto antes (Hearback de outro MD, ADR ACCEPTED, etc.).
3. **Arquivos permitidos** — escopo explícito de **o que pode** ser tocado.
4. **Arquivos proibidos** — escopo explícito de **o que NÃO pode** ser tocado (gate operacional).
5. **Gates** — testes que precisam passar antes/depois (ex.: G7 Glasswing, pytest verde, `hbn doctor` OK).
6. **Riscos + mitigação** — R1, R2, R3 com mitigação por risco.
7. **Rollback** — caminho exato de reversão (`git revert`, `git checkout`, etc.).
8. **Output esperado** — o que fica no repo após o MD fechar.

### Onde vivem

No useHBN: `auditoria/00_status/NN_MD_<letra>_<slug>.md` (numerado por
ordem de chegada). Histórico preservado para auditoria.

No Credenciamento: inline em `auditoria/03_ondas/onda_NN_<tema>/` ou
descritos em manifestos no relay.

### Template

`methodology/templates/MD-TEMPLATE.md`.

---

## Como ADR e MD se relacionam

São **ortogonais e complementares**:

| Eixo | ADR | MD |
|---|---|---|
| Pergunta que responde | **POR QUE** | **COMO** |
| Granularidade | Decisão estratégica/arquitetural | Mudança operacional atômica |
| Frequência | Raro (uma decisão pesa muito) | Frequente (várias por semana) |
| Append-only | Sim — nunca deleta | Não — pode ser arquivado quando concluído |
| Cross-IA | Obrigatório antes de ACCEPTED | Opcional (depende do escopo) |
| Hearback humano | Obrigatório | Para escopo amplo; opcional para MD trivial |
| Reversibilidade | Via novo ADR `SUPERSEDED` | Via `git revert` direto |
| Onde vive | `methodology/adr/` | `auditoria/00_status/` |

### Padrão de dependência típico

- Um **ADR** geralmente gera **N MDs** que o executam.
  *Exemplo*: ADR-005 (Apache 2.0 + DCO) → MD-G aplica em ~35 arquivos.
- Um **MD** pode aplicar **N ADRs** simultaneamente.
  *Exemplo*: MD-J aplicou ajustes derivados dos ADRs 001/002/003/005/006/007/009.
- ADR ratificado **destrava** os MDs que dependem dele.
  *Exemplo*: ADR-002 ACCEPTED → MD-C (criar AGENTS.md raiz) destrava.
- MD pode **bloquear** ADR quando o cross-IA descobre pré-requisito técnico.
  *Exemplo*: ADR-004 bloqueado por MD-H (resolução de versão).

### Hierarquia para visualizar

```
Onda (epoch de mudança ampla, ex.: Onda 6 v0.3.0 release)
  │
  ├── ADR (decisões que sustentam a Onda)
  │     │
  │     └── MD (execuções operacionais que materializam o ADR)
  │           │
  │           └── Commit (passos atômicos de git dentro do MD)
  │
  └── (várias Ondas + ADRs + MDs ao longo do tempo)
```

## Fluxo canônico de uma decisão arquitetural

```
1. Detecção de necessidade
   ├── Auditoria cruzada
   ├── Quarta de Sanitização (ADR-001)
   └── Sinal HBN multi-repo (ADR-006)

2. Depósito de ADR (status PROPOSED) por arquiteto
   └── methodology/adr/ADR-NNN-<slug>.md

3. Cross-IA review (≥2 IAs distintas, 3 se constitucional)
   ├── Codex CLI: técnico-cirúrgico
   └── Antigravity: conceitual-estratégico

4. Consolidação (Opus arquiteto-mestre)
   └── auditoria/00_status/NN_CONSOLIDACAO_*.md

5. Ajustes aplicados (status PROPOSED v1.X)
   └── via MD-J (ou similar)

6. Hearback humano (boletim em bloco ou item-a-item)
   └── status → ACCEPTED

7. Execução em MDs subsequentes
   ├── MD-G, MD-H, MD-I, ...
   └── cada MD com escopo + rollback + gates

8. Métrica de saúde (ADR-007)
   └── alarmes em hbn doctor --health

9. Eventual SUPERSEDED por ADR sucessor
   └── histórico preservado (P7)
```

## Exemplo concreto da janela atual (2026-05-10)

| ADR ACCEPTED | MD que executa | Status do MD |
|---|---|---|
| ADR-001 (Quarta) | MD-E (pré-Quarta), futuro `hbn quarta --manual` | pendente |
| ADR-002 (Tipologia) | MD-C (criar `AGENTS.md` raiz) | destravado |
| ADR-003 v1.2 (Topologia) | Onda Documental Sanitization (futura) | bloqueado por v204 |
| ADR-005 (Apache 2.0 + DCO) | MD-G (re-licenciar 35 arquivos) | destravado |
| ADR-006 (Sinais multi-repo) | MD que estende `runtime.py` para 16 marcadores | pendente |
| ADR-007 (Métricas) | MD que implementa `hbn doctor --health` | pendente, pós-v0.3.0 |
| ADR-009 (Constituição P1-P13) | MD que atualiza README.md:13 | pendente |

ADRs em `NÃO_RATIFICAR`:
- ADR-004 (SemVer): bloqueado por MD-H aplicar patch.
- ADR-008 (Migração snapshot): bloqueado por MD-I implementar tooling + Onda Documental.

## Versão

- v1.0 — 2026-05-10 — Opus 4.7 chat arquiteto-mestre — primer inicial. Formaliza no sistema (em `methodology/`, partição arquitetural permanente — não em `docs/` legado) o vocabulário operacional ADR/MD usado desde 2026-05-09.
