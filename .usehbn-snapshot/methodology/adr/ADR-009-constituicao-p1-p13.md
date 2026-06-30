---
adr-id: ADR-009
titulo: Constituição P1-P13 — migração da fonte canônica e processo de mudança
status: ACCEPTED
data-deposito: 2026-05-09
data-ratificacao: 2026-05-10
autor: Claude Opus 4.7 (chat arquiteto-mestre useHBN)
cross-ia-required: Opus + Antigravity + Codex (3 IAs por exigência constitucional — concluído 2026-05-10)
hearback-status: ratificado por Mauricio 2026-05-10 (boletim em bloco)
prioridade: P0
ordem-cross-ia: 4 de 5 (depende de ADR-002, 003, 004)
relacionado:
  - 00_BOOTSTRAP_PROTOCOLO_2026_05_09.md §4.9 (versão preliminar)
  - 02_ADDENDUM_BOOTSTRAP_2026_05_09.md §A (correção crítica)
  - methodology/PRINCIPIOS-CONSTITUCIONAIS.md (fonte canônica migrada — MD-F)
  - docs/PRINCIPLES.md (legado superseded — MD-F)
  - Credenciamento/usehbn/methodology/PRINCIPIOS-CONSTITUCIONAIS.md (origem)
  - ADR-001 (Quarta — usa cláusula "Cadência Constitucional")
---

# ADR-009 — Constituição P1-P13: migração da fonte canônica e processo de mudança

## Status

**PROPOSED** — exige cross-IA por **3 IAs** (Opus + Antigravity + Codex)
por natureza constitucional. Bloqueia ADR-001 (Quarta usa P6, P10, P11
e P12 nas cláusulas operacionais).

## Contexto

Em 2026-05-09, durante o handoff do chat anterior (`~/Projetos/Credenciamento/`)
para este chat (`~/Projetos/usehbn/`), foi descoberto que existem **duas
listas paralelas de princípios** com peso constitucional aparente:

1. `~/Projetos/usehbn/docs/PRINCIPLES.md` — **8 itens** genéricos
   herdados do v0.2.x (sem ratificação documentada).
2. `~/Projetos/Credenciamento/usehbn/methodology/PRINCIPIOS-CONSTITUCIONAIS.md`
   — **13 princípios** (P1-P10 fundadores + P11-P13 operacionais)
   formalizados por Opus 4.7 Frente 2 em 2026-05-09 com aprovação
   explícita do operador.

Os 13 princípios são canônicos. Os 8 são subset informal. ADR-009 ratifica
a migração da fonte canônica para o repo do protocolo, descontinua
formalmente a lista de 8, e estabelece o processo de mudança constitucional.

Achado adicional: o doc 66 v2.0 do Credenciamento usou "P12 Substrato
Sólido" em dois sentidos diferentes — (a) canônico = "linguagem-base
estável (Rust)"; (b) operacional informal = "regras só mudam após N
ciclos". O sentido (b) é renomeado para **"Cadência Constitucional"**
(cláusula operacional do ADR-001), preservando os 13 intactos.

## Decisão

### 1. Migração da fonte canônica (já executada — MD-F deste bootstrap)

- `methodology/PRINCIPIOS-CONSTITUCIONAIS.md` materializado em
  `~/Projetos/usehbn/` em 2026-05-09 com conteúdo equivalente ao
  original do Credenciamento, paths relativos ajustados para topologia
  do ADR-003.
- `docs/PRINCIPLES.md` recebeu banner SUPERSEDED apontando para a fonte
  canônica.

### 2. Lista canônica P1-P13 (peso constitucional idêntico — ajuste MD-J cross-IA Antigravity)

Mantida intacta conforme `methodology/PRINCIPIOS-CONSTITUCIONAIS.md`.
**Os 13 têm peso normativo igual** — sem hierarquia "fundadores" vs
"operacionais" (insight Antigravity: "uma constituição não pode ter
castas"). A informação histórica sobre formalização vai em rodapé/
metadado de cada princípio, não em cabeçalho.

1. P1 — Preservar antes de transformar
2. P2 — Documentar antes de executar
3. P3 — Testar antes de refatorar
4. P4 — Explicar antes de automatizar
5. P5 — Humano no controle por padrão
6. P6 — Toda evolução deve ser reversível
7. P7 — Nenhuma tecnologia fagocitada perde sua identidade
8. P8 — O protocolo importa mais que a ferramenta
9. P9 — Frameworks são descartáveis; princípios são permanentes
10. P10 — Segurança e não-regressão > velocidade
11. P11 — Minimalismo de Cadeia (🟦 HBN MINIMALIST GATE)
12. P12 — Substrato Sólido (🟪 HBN SUBSTRATO GATE) — sentido canônico exclusivo: linguagem-base estável (Rust). **NÃO invalida o runtime Python v0.3.0** — coexistem; transição é plurianual via Phagocytosis (ajuste cross-IA Codex)
13. P13 — AI-Language-Abstraction (🟧 HBN AI-ABSTRACTION GATE)

> Histórico (rodapé): P1-P10 declarados na V1 da tese (2026-05-02);
> P11-P13 articulados na janela 2026-05-02 → 2026-05-06 e promovidos a
> status constitucional equivalente em 2026-05-09 (decisão Maurício).

### 3. Sobrecarga semântica resolvida

| Sentido | Onde | Como passa a ser nomeado |
|---|---|---|
| "Linguagem-base estável (Rust)" | P12 canônico | **P12 Substrato Sólido** (preservado) |
| "Regras só mudam após N ciclos" | doc 66 v2.0 §3.4, §7.4 (uso informal) | **Cadência Constitucional** (cláusula operacional do ADR-001 — ver §B do addendum 02) |

### 4. Processo de mudança constitucional

Mudança em redação de qualquer P1-P13 OU adição de P14+ exige:

1. **Cross-audit com pelo menos 2 IAs auxiliares** (Opus + Antigravity, ou Opus + Codex, ou Antigravity + Codex). Single-IA = rejeição automática.
2. **Decisão Maurício** após síntese das auditorias (P5 — humano é raiz da confiança).
3. **Cápsula de auditoria** registrando o porquê em `auditoria/capsulas/<slug>.md` (ascii — ver §7).
4. **Append-only**: princípio antigo permanece com nota `superseded-by`.
5. **Adição de P14+**: requisito adicional de **≥2 incidências reais** documentadas que motivaram a formulação.
6. **Bump SemVer MAJOR** (ADR-004): mudança em princípio constitucional é breaking change para apps consumidoras.

### 5. Cadência

- **Anual** (mais conservadora que tecnologias).
- A Quarta de Sanitização (ADR-001) **NÃO** revisa P1-P13. Quartas
  operam sobre doutrina derivada, ADRs operacionais e métricas — nunca
  sobre constituição diretamente.

### 6. Descontinuação formal de docs/PRINCIPLES.md

- Banner SUPERSEDED já aplicado (MD-F).
- Próximo MD: remover dependência de docs/PRINCIPLES.md em README.md.
  - `README.md:13` atualizar para apontar **tanto** `methodology/MATURITY-MATRIX.md` (estado por componente) **quanto** `methodology/PRINCIPIOS-CONSTITUCIONAIS.md` (axiomas P1-P13) — ajuste cross-IA Codex (`README.md:13` hoje só aponta MATURITY-MATRIX).
- Manter o arquivo legado `docs/PRINCIPLES.md` (não deletar) — preserva histórico (P7).

### 7. Padronização de paths sem acento (ajuste cross-IA Codex)

Diretórios e arquivos novos do ecossistema usam **ascii puro** em path
(sem acento, sem espaço). Aplicar especificamente: usar
`auditoria/capsulas/` (não `auditoria/cápsulas/`) em todas as
referências futuras. Se algum path com acento já tiver sido criado,
renomear no próximo MD. Razão: robustez cross-platform de tooling.

## Consequências

**Positivas:**
- Eliminação da ambiguidade entre 8 e 13 princípios.
- ADR-001 (Quarta) tem termos canônicos — "Cadência Constitucional" é
  cláusula operacional, não princípio numerado novo.
- Comunicação pública passa a citar 13 princípios uniformemente.

**Negativas:**
- README, MATURITY-MATRIX, AGENTS-MD precisam atualização para citar 13
  no lugar de 8 — trabalho mecânico, baixo risco. MD subsequente.

## Riscos e mitigação

| # | Risco | Mitigação |
|---|---|---|
| R1 | Operador concluir que precisa adicionar P14 antes do useHBN amadurecer | Critério "≥2 incidências reais" no §4.5 desencoraja adições prematuras |
| R2 | Auditoria externa achar que 13 é muito (vs 5-7 de protocolos comparáveis como MCP) | Justificar em comunicação pública: P1-P10 são axiomas; P11-P13 são extensões pragmáticas registradas |
| R3 | Mudança simultânea de múltiplos P (ex.: revisão grande) gerar caos | Regra: 1 ADR por P alterado; cross-IA por ADR; sequencial |

## Próximo passo

1. ADR-002, ADR-003, ADR-004 ratificados.
2. Cross-IA review por **Antigravity + Codex** (3 IAs por natureza
   constitucional — único ADR que exige).
3. Hearback humano.
4. Status PROPOSED → ACCEPTED.
5. MD subsequente: atualizar README e MATURITY-MATRIX para citar 13
   princípios.
6. ADR-001 (Quarta) destrava após este ratificado (P12 canônico vs
   "Cadência Constitucional" claros).

## Versão

- v1.0 — 2026-05-09 — Opus 4.7 chat arquiteto-mestre — depósito inicial. Substitui §4.9 do bootstrap (que propunha "criar P1-P12 do zero" — incorreto, fonte canônica já existia).
- v1.1 — 2026-05-10 — Opus 4.7 chat arquiteto-mestre — MD-J cross-IA. Ajustes: (a) eliminada hierarquia "fundadores" vs "operacionais" — P1-P13 com peso constitucional idêntico, histórico em rodapé (insight Antigravity); (b) P12 declarado como farol de longo prazo que não invalida runtime Python v0.3.0 (insight Codex); (c) `README.md:13` deve apontar MATURITY-MATRIX + PRINCIPIOS-CONSTITUCIONAIS (insight Codex); (d) §7 padronização de paths ascii (`capsulas/` não `cápsulas/`) (insight Codex). PRINCIPIOS-CONSTITUCIONAIS.md já reescrito (v1.1) refletindo (a) e (b).
