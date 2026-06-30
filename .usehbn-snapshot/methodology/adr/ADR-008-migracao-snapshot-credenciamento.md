---
adr-id: ADR-008
titulo: Migração Credenciamento/usehbn/ → ~/Projetos/usehbn/ + .usehbn-snapshot/ no consumidor
status: PROPOSED (BLOQUEADO até v204 final do Credenciamento)
data-deposito: 2026-05-09
autor: Claude Opus 4.7 (chat arquiteto-mestre useHBN)
cross-ia-required: Opus + Codex (Codex é dono operacional do Credenciamento)
hearback-status: aguardando humano + v204 final
prioridade: P0 (bloqueada por evento externo — v204 final)
ordem-cross-ia: depende de ADRs 002, 003, 004
relacionado:
  - 00_BOOTSTRAP_PROTOCOLO_2026_05_09.md §4.8
  - doc 66 v2.0 (Credenciamento) §11.5
  - ADR-002 (tipologia — Credenciamento é app consumidora, NÃO módulo)
  - ADR-003 (topologia)
  - ADR-004 (SemVer — declarado em AGENTS.md da app)
  - ADR-006 (sinais — 🪞 HBN MIRROR DRIFT)
  - prompt-retomada Codex 01_PROMPT_RETOMADA_CODEX_V204.md
---

# ADR-008 — Migração `Credenciamento/usehbn/` → snapshot read-only

## Status

**PROPOSED — BLOQUEADO até v204 final** do Credenciamento. ADR só
executa depois que rollback MICRO49→MICRO48 + ondas restantes da V204
fecharem com release final publicada.

## Contexto

`~/Projetos/Credenciamento/usehbn/` hoje contém fonte de verdade
**legada** do protocolo misturada com aplicação consumidora. Topologia
alvo (ADR-003) exige que essa pasta deixe de existir em duas etapas:

(a) **Extração**: conteúdo canônico migra para `~/Projetos/usehbn/`.
    Já iniciado em 2026-05-09 (criação do repo standalone).

(b) **Substituição**: pasta legada vira README depreciado de uma linha
    + `.usehbn-snapshot/` read-only mirror que o Credenciamento consome.

Risco se não fizer: drift permanente entre `Credenciamento/usehbn/`
(congelado em v204) e `~/Projetos/usehbn/` (vivo). IA operando em CWD
do Credenciamento volta a editar protocolo.

Bloqueio operacional: durante a janela v204 (até release final), Codex
CLI detém bastão F1 do Credenciamento. Qualquer escrita em
`Credenciamento/usehbn/` fora do Codex viola o congelamento.

## Decisão

Após v204 final do Credenciamento publicada (com rollback MICRO49→MICRO48
ratificado per `01_PROMPT_RETOMADA_CODEX_V204.md`):

### 1. Auditoria pré-migração (Opus + Codex)

Confirmar que tudo de `Credenciamento/usehbn/` foi migrado para
`~/Projetos/usehbn/`:

- `methodology/PRINCIPIOS-CONSTITUCIONAIS.md` — ✅ migrado (MD-F deste bootstrap)
- Outros docs em `Credenciamento/usehbn/methodology/` — pendente (Onda Documental Sanitization)
- `Credenciamento/usehbn/audits/` — pendente
- `Credenciamento/usehbn/radar/` — pendente
- `Credenciamento/usehbn/site/` — pendente

Cross-IA confirma diff = 0 entre origem e destino canônico.

### 2. Substituição da pasta legada

`Credenciamento/usehbn/` recebe README de uma linha:

```markdown
# DEPRECATED — useHBN movido para repo standalone

A fonte de verdade do protocolo useHBN foi extraída deste
repositório em 2026-XX-XX (data v204 final + ADR-008).

- Repo canônico: ~/Projetos/usehbn/ (ou URL pública quando publicado)
- Versão consumida por este projeto: ver `.usehbn-snapshot/VERSION`
- Política: este projeto é APLICAÇÃO CONSUMIDORA do protocolo,
  não hospeda mais doc canônica.

Histórico desta pasta preservado no commit <sha-da-migração> e em
~/Projetos/usehbn/auditoria/.
```

Demais conteúdo da pasta legada removido pelo Codex (commit dedicado).

### 3. `.usehbn-snapshot/` no Credenciamento

Estrutura:

```
~/Projetos/Credenciamento/.usehbn-snapshot/
├── VERSION                      versão consumida (ex.: "1.0.0")
├── PROTOCOL_SHA256.txt          checksum do snapshot inteiro
├── modules/...                  cópia read-only
├── methodology/                 cópia read-only (P1-P13 + ADRs)
└── README.md                    "este diretório é gerado por bin/usehbn-fetch.sh; não editar"
```

Princípios operacionais:

1. **Nunca editada manualmente.** Populada por `bin/usehbn-fetch.sh
   <versão>` (script novo no useHBN).
2. **Imutável dentro do release da app consumidora.** V12.0.0204 do
   Credenciamento consome useHBN 1.0.0 (ou versão escolhida na
   ratificação); congelada até próximo release decidir bumpar.
3. **Validável por checksum.** Antes de qualquer ação, IA roda
   `bin/usehbn-verify.sh` que (a) lê `VERSION`, (b) calcula sha256 da
   pasta, (c) compara com `PROTOCOL_SHA256.txt`, (d) bloqueia se
   divergente (emite 🪞 HBN MIRROR DRIFT — ADR-006).
4. **Auditável.** CHANGELOG.md do Credenciamento declara qual versão
   do useHBN consume e a data do fetch.

### 4. AGENTS.md do Credenciamento — seção nova

```markdown
## Dependência de protocolo: useHBN

Este projeto consome o protocolo useHBN como dependência externa.

| Campo | Valor |
|---|---|
| Versão consumida | `1.0.0` |
| Operador SemVer | `^1.0.0` |
| Repo canônico | `https://github.com/<org>/usehbn` |
| Snapshot local | `.usehbn-snapshot/` (read-only) |
| Última atualização | 2026-XX-XX |
| Próxima revisão | quando `1.1.0` ou `2.0.0` for lançado |

Sinais a observar:
- ⛓️ HBN PROTOCOL DEP CHANGE — protocolo lançou nova MAJOR/MINOR
  e este projeto precisa decidir consumo.
- 🪞 HBN MIRROR DRIFT — `.usehbn-snapshot/` divergiu do checksum
  esperado.

NUNCA edite `.usehbn-snapshot/` diretamente. Para upgrade, rode
`bin/usehbn-fetch.sh <nova-versão>` e cite o ADR correspondente do
useHBN no commit.

Para os princípios completos, leia `.usehbn-snapshot/methodology/PRINCIPIOS-CONSTITUCIONAIS.md` (read-only).
```

### 5. NÃO submodule git

Decisão explícita pela simplicidade (doc 66 v2.0 §11.5.6):

- Submodule funciona, mas tem fricção alta para o operador (`git
  submodule update --init` esquecido = falha silenciosa) e para IAs
  (sandbox CWD ≠ submodule é confuso).
- Snapshot read-only + checksum é mais simples, mais auditável e não
  depende de operação git extra.

Se em algum momento o ecossistema crescer (3+ apps consumidoras),
revisitar submodule ou subtree split em sub-ADR.

## Consequências

**Positivas:**
- Topologia ADR-003 materializada na prática.
- Risco de IA tocar protocolo enquanto opera no Credenciamento eliminado.
- Promoção pública de `~/Projetos/usehbn/` (Onda 6 do plano v0.3.0)
  destrava — não compete mais com `Credenciamento/usehbn/`.

**Negativas:**
- Dependência de scripts (`bin/usehbn-fetch.sh`, `bin/usehbn-verify.sh`).
  Precisam existir antes da execução.
- Histórico do `Credenciamento/usehbn/` preservado apenas em commit;
  navegação no working tree perde rastreabilidade direta.

## Riscos e mitigação

| # | Risco | Mitigação |
|---|---|---|
| R1 | `bin/usehbn-fetch.sh` falhar silenciosamente | `hbn doctor --target <app>` checa checksum em cada execução |
| R2 | Codex CLI tocar `Credenciamento/usehbn/` antes de ADR-008 executar | Pasta congelada per doc 66 v2.0 §3.3; deny rules no Credenciamento. Risco residual mitigado por monitoramento humano |
| R3 | Ratificação de versão consumida (1.0.0?) ser feita prematuramente | ADR-008 só executa pós-v204 final, quando ADR-005 (Apache) e bump SemVer já decididos |
| R4 | App consumidora tentar editar `.usehbn-snapshot/` por engano | README do diretório + checksum verify bloqueiam operacionalmente |

## Próximo passo

1. Aguardar v204 final do Credenciamento.
2. Ratificar ADRs 002, 003, 004, 005, 009.
3. Cross-IA review (Opus + Codex) deste ADR.
4. Hearback humano.
5. Status PROPOSED → ACCEPTED.
6. Opus + Codex executam migração em MD coordenado pós-v204.

## Versão

- v1.0 — 2026-05-09 — Opus 4.7 chat arquiteto-mestre — depósito inicial.
