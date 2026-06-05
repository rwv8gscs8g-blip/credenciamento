---
titulo: PONTE — estado do protocolo após as ondas arquiteto 0114-0117 (para a IA que retomar a V206)
data: 2026-06-05
autoria: claude-opus-4.8 (modo arquiteto, onda 0117)
motivo: .hbn/relay/INDEX.md não pôde ser atualizado (carrega 346 inserções não-commitadas da linha Codex); esta ponte cobre a lacuna até o GATE 0 consolidar
expira: quando o relay/INDEX.md ganhar a seção das ondas 0114-0117 (GATE 0 do doc 127)
---

# Ponte de estado — o que mudou no protocolo (2026-06-05)

Quatro ondas da linha ARQUITETO rodaram fora do relay (registros completos em
auditoria/00_status/123-127):

| Onda | Entrega | Efeito prático para você |
|---|---|---|
| 0114 | Consolidação de evoluções + knowledge 0021 | Guards rodados em sandbox (Cowork) são informativos; validação conclusiva e commits SEMPRE no Terminal do operador; git de escrita proibido em sandbox |
| 0115 | knowledge 0022 — FIREWALL | Orquestração automática/workflow só para leitura/análise/auditoria (fast_track); escrita safe_track VBA é humano-aplicada e hearback-gated, nunca em run autônomo |
| 0116 | CI hbn-guards (`.github/workflows/hbn-guards-ci.yml`) | Todo push/PR valida: contratos novos/modificados × schemas 1.0.0 (RATCHET — use evidence_kind só do enum; agent_id do enum) + scope-lock POR COMMIT com resolução histórica; bypass exige nota em .hbn/bypasses/ no range |
| 0117 | Organização + handoff | AGENTS.md atualizado (CI + 0021/0022 + versões), auditoria/INDEX.md cobre docs 100-127, colisões 0005×0005 / 0014×0014 / 106×106 sinalizadas (NÃO renumerar), doc 126 = condições V207, doc 127 = seu prompt de entrada |

Numeração em uso: readbacks 0145-0148 são da linha arquiteto. **Próximo livre: 0149.**
PROMPT_ARQUITETO_USEHBN_AUTONOMO.md está em v1.6 (fora do repo, em ~/Projetos).

Pendências que o GATE 0 (doc 127) resolve: consolidar o working tree da linha
Codex (95 untracked + 21 modified), atualizar relay/INDEX.md com esta tabela,
fechar ERPs 0147/0148 com os shas dos commits do operador, triagem de incoming/.

Passivo conhecido que NÃO bloqueia: 80 readbacks + 11 hearbacks legados fora
do schema (CI reporta sem falhar; bump 1.1.0 = item A5, insumo no doc 125).
