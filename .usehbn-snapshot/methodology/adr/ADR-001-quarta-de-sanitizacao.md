---
adr-id: ADR-001
titulo: Quarta de Sanitização — ritual de auto-evolução assistida + janela 12h BRT + gatilho manual
status: ACCEPTED
data-deposito: 2026-05-09
data-ratificacao: 2026-05-10
autor: Claude Opus 4.7 (chat arquiteto-mestre useHBN)
cross-ia-required: Opus + Antigravity + Codex
hearback-status: ratificado por Mauricio 2026-05-10 (boletim em bloco junto com 002/003/005/006/007/009)
prioridade: P0
ordem-cross-ia: 5 de 5 (depende de ADR-002, 003, 004, 009)
relacionado:
  - 00_BOOTSTRAP_PROTOCOLO_2026_05_09.md §4.1
  - 02_ADDENDUM_BOOTSTRAP_2026_05_09.md §B (janela 12h) e §C (manual)
  - doc 66 v2.0 (Credenciamento) §7.4, §11.3
  - methodology/PRINCIPIOS-CONSTITUCIONAIS.md (P6, P10, P11, P12 canônicos)
  - ADR-009 (constituição P1-P13 + Cadência Constitucional como cláusula operacional)
---

# ADR-001 — Quarta de Sanitização: ritual de auto-evolução assistida

## Status

**PROPOSED** — depende de todos os outros ADRs P0 (002, 003, 004, 009)
ratificados primeiro. Único entre os P0 que NÃO bloqueia outros — é o
fechamento.

## Contexto

O protocolo useHBN precisa de mecanismo contínuo de auto-revisão que:

- Detecte hipertrofia documental (Antigravity Q3 detectou 27+ docs).
- Detecte deriva de princípios derivados (ADRs operacionais, marcadores).
- Sincronize cross-IA com cadência previsível.
- Opere dentro da janela de faturamento da plataforma de IA do operador
  (ciclo Anthropic semanal).

Sem ritual contínuo, doutrina cresce e princípios derivados se diluem.
A Quarta inaugural (Quarta 0) só acontece após v204 final do
Credenciamento.

## Decisão

### 1. Anatomia do ritual com janela de 12:00 BRT (corrigida 2026-05-09)

| Estágio | Horário (BRT, -03:00) | Ator | Consome tokens IA? |
|---|---|---|---|
| **AGENT-INTAKE** | terça-feira 21h-23h | IA arquiteto (Opus) varre 4 fontes objetivas: Truth Barrier hits, READ-FIRST misses, Glasswing violations, cross-IA divergências. Gera `auditoria/quartas/NNNN-candidatos.md`. | Sim |
| **AGENT-TRIAGE** | quarta-feira 06h-07h | IA arquiteto classifica candidatos em MERGE / DEFER / DELETE. Escreve readback em `.hbn/relay/NNNN-quarta-NNNN.md`. | Sim |
| **AGENT-DEBATE** | quarta-feira 07h-10h | Cross-IA paralelo (Opus + Antigravity OU Opus + Codex). Cada IA emite parecer independente sobre os MERGE candidatos. | Sim |
| **AGENT-COMMIT-DRAFT** | quarta-feira 10h-11:30 | IA arquiteto consolida pareceres e gera ADR drafts em `methodology/adr/ADR-NNN-*.md`. NÃO comita ainda. | Sim |
| **HARD CUT-OFF de tokens IA** | **quarta-feira 12:00 BRT** | — | linha de corte |
| **HUMAN-RATIFY** | quarta-feira 12h-17h | Mauricio (operador) lê drafts e ratifica em <30 min via boletim. Não revisa linha-a-linha (P5 + P10). | Não |
| **HUMAN-PROPAGATE** | quinta-feira manhã | Operador dispara CI/PR. Apps consumidoras recebem ⛓️ HBN PROTOCOL DEP CHANGE se houver bump MAJOR/MINOR (ADR-004). | Não |

Janela ativa de tokens IA: **terça-noite + quarta 06-12h BRT** (~6h
úteis na quarta).

### 2. Cláusula da Janela de Faturamento (texto canônico)

```
CLÁUSULA DA JANELA DE FATURAMENTO — useHBN ADR-001 §2

A Quarta de Sanitização opera dentro de uma "janela de faturamento"
explícita, derivada do ciclo de créditos da plataforma de IA usada
pelo operador. A janela tem quatro parâmetros canônicos:

  - dia da semana: quarta-feira
  - hora-limite de tokens IA: 12:00
  - fuso: BRT (-03:00)
  - origem: ciclo de créditos Anthropic (semanal, vence ao fim
            do período)

Os 4 estágios IA (INTAKE, TRIAGE, DEBATE, COMMIT-DRAFT) DEVEM completar
antes da hora-limite. Estágio que não couber vira automaticamente
DEFER para a Quarta seguinte (apoia P11 — Minimalismo: dúvida = adiar).

Os 2 estágios humanos (RATIFY, PROPAGATE) ocorrem após o cut-off SEM
consumo de tokens IA.

Se a plataforma de IA, o operador, ou o ciclo de faturamento mudar
de forma a invalidar qualquer dos parâmetros, a primeira IA a
detectar emite o sinal:

  ⏳ HBN BILLING WINDOW DRIFT — janela atual <X> conflita com novo
     parâmetro <Y>; proposta de ajuste em ADR-001-revisao-NN.

A revisão da janela é exceção à Cadência Constitucional (cláusula §3
abaixo) — tem natureza operacional, não constitucional. Operador
ratifica o ajuste no próprio ciclo seguinte.

Múltiplas plataformas: se o operador adotar mais de um provedor de
IA simultaneamente, cada provedor declara sua janela própria; a
janela canônica da Quarta é a INTERSEÇÃO das janelas (a primeira
a fechar).
```

### 3. Cláusula "Cadência Constitucional" (operacional, não princípio numerado)

> **Cadência Constitucional**: a Quarta de Sanitização **NÃO revisa**
> os princípios constitucionais P1-P13. Mudanças em P1-P13 seguem
> processo separado (ADR-009 §4): cross-audit com ≥2 IAs auxiliares,
> decisão humana, cápsula de auditoria, append-only, bump MAJOR. A
> Quarta opera apenas sobre doutrina derivada (ADRs operacionais,
> marcadores, métricas, ondas de execução).

Esta cláusula resolve a sobrecarga semântica de "P12 Substrato Sólido"
detectada no doc 66 v2.0 (ver ADR-009 §3).

### 4. Cinco cláusulas operacionais da Quarta

1. **Reversibilidade** (apoiada em P6): todo MERGE traz seção `rollback` no MD ou ADR sucessor declarando o caminho de reversão. Rollback é **obrigatório**; criação de ADR novo dedicado **não é obrigatória** quando o rollback cabe no próprio MD da mudança.
2. **Cadência Constitucional** (acima): princípios P1-P13 seguem processo separado.
3. **Minimalismo** (apoiado em P11): dúvida = DELETE/DEFER curto, nunca DEFER indefinido.
4. **Cross-IA obrigatório**: single-IA = DEFER automático.
5. **Métrica viva**: cada MERGE da Quarta N vira input mensurável da Quarta N+4.

### 5. Quarta Manual (gatilho on-demand)

Dois mecanismos de invocação fora do ciclo recorrente:

**(a) Comando CLI** — `hbn quarta --manual [--scope=<tema>] [--dry-run]`

- **Status atual: contrato futuro pós-v0.3.0** (subcomando NÃO existe em `src/usehbn/cli.py` na data deste ADR — confirmado via cross-IA Codex). Documentado aqui para preservar contrato; implementação fica para roadmap pós-v0.3.0 (Onda 7+ ou v0.4.0).
- Comportamento:
  - Pré-12h BRT: executa pipeline completo INTAKE → COMMIT-DRAFT na sessão.
  - Pós-12h BRT: executa apenas INTAKE+TRIAGE; DEFER do DEBATE para 06h BRT do dia útil seguinte.
- Argumentos:
  - `--scope <tema>`: limita varredura (ex.: "licença", "topologia", "schemas").
  - `--dry-run`: gera relatório sem produzir ADR drafts.

**(b) Convocação por sinal HBN multi-repo (ADR-006)**

Qualquer IA emite um destes sinais → operador decide se invoca Quarta manual:

- 🌐 HBN CROSS-REPO LOCK
- ⏳ HBN BILLING WINDOW DRIFT
- 🪞 HBN MIRROR DRIFT

### 5.1 Cláusula anti-abuso da Quarta Manual

Quarta manual NÃO pode ser invocada mais que **2 vezes/mês** sem revisão
expressa do operador + parecer cross-IA. Limite anti-abuso vigia o
risco antropológico (Antigravity §C.2: "operador ansioso pode invocar
toda sexta e segunda, diluindo o peso do ritual principal").
Métrica `quartas_manuais_por_mes` entra em ADR-007 §1 quando esta
cláusula for ratificada.

### 6. Diferença entre Quarta automática e manual

| Atributo | Automática | Manual |
|---|---|---|
| Frequência | Semanal (toda quarta) | On-demand |
| Quorum cross-IA | Obrigatório antes do COMMIT-DRAFT | Obrigatório antes do COMMIT-DRAFT |
| HUMAN-RATIFY | Quarta 12-17h BRT | Imediato pós-COMMIT-DRAFT (mesmo dia) |
| Constraint janela 12h | Sim | Sim (com fallback DEFER) |
| Output | ADR drafts em `methodology/adr/` | Idem |
| Append em métricas | Conta como Quarta N | Conta como Quarta N.k (sub-índice) |

### 7. Quarta 0 inaugural

Acontece **apenas após v204 final** do Credenciamento (ADR-008
ratificado). Pre-condição: **ADRs 002, 003, 004, 005, 006, 008, 009 todos
ACCEPTED** (lista completa pós cross-IA 2026-05-10; inclui 005 licença
+ 006 sinais que faltavam no depósito original v1.0). Pauta da Quarta 0:

1. Ratificar este próprio ADR-001.
2. Decidir 2ª aplicação consumidora candidata (decisão O4 do doc 66 v2.0).
3. Bump SemVer para v1.0.0 se `protocol_version` virar required (decisão Q4 do plano v0.3.0).

## Consequências

**Positivas:**
- Protocolo auto-corretivo, anti-hipertrofia.
- Janela 12h BRT alinha custo computacional ao ciclo de faturamento.
- Quarta manual permite resposta rápida a sinais cruzados (ex.: hoje
  2026-05-09 — auditorias convergiram fora de quarta).

**Negativas:**
- Operador precisa estar disponível quarta 12-17h BRT para HUMAN-RATIFY (~30min).
- Custo de coordenação adicional ~3-4h/semana (parte humano, parte IA).

## Riscos e mitigação

| # | Risco | Mitigação |
|---|---|---|
| R1 | Estágios IA estourarem 12:00 BRT regularmente | DEFER automático preserva integridade; métrica em ADR-007 monitora frequência. >2 estouros consecutivos → ajustar janela ou reduzir escopo |
| R2 | Operador faltar HUMAN-RATIFY por viagem/feriado | Quarta vira "Quarta DEFER" — nada commita; próxima Quarta absorve. Sem perda de trabalho IA (drafts persistem) |
| R3 | Cross-IA não disponível (Antigravity offline, Codex em janela de release de app) | Single-IA = DEFER automático. Não tenta merge com 1 IA |
| R4 | Quarta manual virar abuso (operador chama todo dia) | Métrica `quartas_sem_merge_consecutivas` em ADR-007 detecta |
| R5 | Quarta 0 sendo bloqueada por v204 estendendo demais | Pré-Quartas (sem ratificação) podem ocorrer durante a janela; servem de warm-up |

## Próximo passo

1. Todos os ADRs P0 anteriores ratificados (002, 003, 004, 009).
2. Cross-IA review por Antigravity OU Codex.
3. Hearback humano.
4. Status PROPOSED → ACCEPTED.
5. Aguardar v204 final do Credenciamento.
6. Quarta 0 inaugural ratifica este ADR (cerimonialmente — já está ACCEPTED neste passo).

## Versão

- v1.0 — 2026-05-09 — Opus 4.7 chat arquiteto-mestre — depósito inicial. Janela reorganizada para 06-12h BRT (correção do addendum 02 §B). Cláusula "Cadência Constitucional" introduzida para resolver sobrecarga de P12 (ADR-009). Quarta manual formalizada (addendum 02 §C).
- v1.1 — 2026-05-10 — Opus 4.7 chat arquiteto-mestre — MD-J cross-IA. Ajustes: (a) 🟠 BILLING WINDOW DRIFT → ⏳ (resolução de colisão); (b) `hbn quarta --manual` marcado explicitamente como contrato futuro pós-v0.3.0; (c) cláusula §4.1 reversibilidade — rollback obrigatório mas não exige ADR novo dedicado; (d) §5.1 cláusula anti-abuso da Quarta manual (≤2/mês sem revisão); (e) §7 lista completa de pré-requisitos do Quarta 0 (inclui 005 e 006).
