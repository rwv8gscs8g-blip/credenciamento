---
titulo: Registro da Onda 0114 — consolidação de evoluções + backlog §4 + knowledge 0021
diataxis: explanation
hbn-track: fast_track
data: 2026-06-05
autoria: claude-opus (modo arquiteto, via Cowork) em consulta a Mauricio
onda: 0114 (linha arquiteto; sucede 0113 do doc 122)
readback: .hbn/readbacks/0145-rb-onda-0114-consolidacao-evolucoes-backlog.json
hearback: .hbn/hearbacks/0145-consolidacao-evolucoes-backlog.json (confirmed 2026-06-05)
erp: .hbn/results/0145-exec-onda-0114-consolidacao-evolucoes-backlog.json
---

# Onda 0114 — consolidação de evoluções, backlog §4 e knowledge 0021

## Contexto

Validação manual do `PROMPT_ARQUITETO_USEHBN_AUTONOMO.md` v1.5 solicitada por
Mauricio em 2026-06-05 (Cowork). O ciclo executou o pré-flight §2 de ponta a
ponta e produziu a primeira onda formal da linha arquiteto com readback em
`.hbn/readbacks/` (ondas 0111–0113 anteriores não tinham readback nesta pasta).

Pré-flight: guards exit 0 confirmado por **human_report** (screenshot do
Terminal do operador, 2026-06-05 — via Cowork o canonical-root falha por
artefato de sandbox, ver knowledge 0021); zero hearbacks pendentes; último ERP
0144 (linha Codex V206, intocada); 2 protocol-evolutions pendentes no passo F.

## Decisões de Mauricio (hearback 0145, 2026-06-05)

1. **Onda 0114**: escopo confirmado.
2. **Firewall (EW-1)**: princípio permanente — orquestração automática /
   workflows **só** para leitura/análise/auditoria (`fast_track`); escrita
   `safe_track` em VBA permanece humano-aplicada e hearback-gated.
3. **Roadmap EW**: caminho mínimo **EW-1 → EW-3 → EW-4** entra no backlog §4
   (nova Trilha G). EW-2/5/6/7 ficam como sedimentação posterior.
4. **Piloto EW-3**: autorizado — 1 gate real de auditoria cruzada via workflow
   Claude-only (descartável), cruzada multi-modelo em paralelo como controle,
   critério P9 (zero achado BLOQUEADOR/FORTE perdido).

## Mudanças executadas

| Alvo | Mudança |
|---|---|
| `.hbn/protocol-evolutions/20260527-1410-*.md` | status: proposed → **consolidated** (absorvida como sedimentação posterior EW-2/EW-6; revisão após dado do piloto G2) |
| `.hbn/protocol-evolutions/20260601-1048-*.md` | status: proposed → **consolidated** (4 decisões registradas; caminho mínimo no backlog) |
| `.hbn/knowledge/0021-arquiteto-via-cowork-sandbox.md` | **novo** — padrão operacional sandbox vs raiz canônica + fricções colaterais |
| `.hbn/knowledge/INDEX.md` | registra 0021 |
| `PROMPT_ARQUITETO_USEHBN_AUTONOMO.md` (fora do repo) | v1.5 → **v1.6**: A2 ✅ entregue, A3 ⏳ próximo, nova Trilha G (G1=EW-1, G2=EW-3, G3=EW-4), changelog |
| `auditoria/00_status/123_*.md` | este registro |
| `.hbn/readbacks/0145-*.json` + `.hbn/hearbacks/0145-*.json` + `.hbn/results/0145-*.json` | contratos da onda |

**Não tocados (invariantes)**: `src/vba/`, `local-ai/vba_import/`, guards,
schemas, `.hbn/relay/INDEX.md` (carrega 346 inserções não-commitadas da linha
Codex — atualização do relay adiada para após o commit da linha Codex; pendência
registrada no ERP).

## Evidência

- Guards exit 0 pré-onda: screenshot do Terminal (2026-06-05, chat Cowork).
- Commit da onda: **pendente — operador** (git add seletivo conforme
  `scope.files_allowed`; sha registrado no ERP após execução).
- Validação pós-commit: guards-runner no Terminal do operador.

## Fricções → próximas ondas

- Colisão `0014×0014` na knowledge base → onda futura de higiene (Trilha F).
- Enum `agent_id` sem `claude-opus-4-8` → item A5 (bump schema 1.1.0).
- Relay/INDEX.md da linha arquiteto desatualizado → atualizar em micro-onda
  após commit da linha Codex.
