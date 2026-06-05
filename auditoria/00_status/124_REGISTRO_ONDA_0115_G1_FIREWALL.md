---
titulo: Registro da Onda 0115 (G1) — firewall formalizado como knowledge 0022
diataxis: explanation
hbn-track: fast_track
data: 2026-06-05
autoria: claude-opus (modo arquiteto, via Cowork) em consulta a Mauricio
onda: 0115 (linha arquiteto; sucede 0114 do doc 123)
readback: .hbn/readbacks/0146-rb-onda-0115-g1-firewall-knowledge-0022.json
hearback: .hbn/hearbacks/0146-g1-firewall-knowledge-0022.json (confirmed 2026-06-05)
erp: .hbn/results/0146-exec-onda-0115-g1-firewall-knowledge-0022.json
---

# Onda 0115 (G1) — firewall → knowledge 0022

Item G1 da Trilha G (backlog §4 do PROMPT_ARQUITETO v1.6). Formaliza como
fonte canônica única (`.hbn/knowledge/0022-firewall-workflow-fast-track.md`)
o princípio decidido por Mauricio no hearback 0145: orquestração
automática/workflows somente `fast_track` (leitura/análise/auditoria);
escrita `safe_track` em VBA permanece humano-aplicada e hearback-gated,
nunca em run autônomo.

Contexto declarado por Mauricio: amadurecer o protocolo antes do
refatoramento da V12.0.0207, contra regressões e processos descontrolados.

Mudanças: knowledge 0022 (novo, canônico), knowledge INDEX (registra 0022),
célula G1 do backlog §4 do prompt mestre → ✅ entregue (sem bump de versão;
refresh do §3 passo 7), contratos 0146.

Invariantes: domínio, guards, schemas e relay/INDEX.md intocados; trabalho
não-commitado da linha Codex preservado (git add seletivo).

Evidência: sha do commit do operador registrado no ERP 0146 após execução.
