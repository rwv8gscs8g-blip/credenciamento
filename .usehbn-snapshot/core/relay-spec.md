---
titulo: Relay spec v2 — Bastão 2.0 (STATE × LOG)
diataxis: reference
status: accepted
versao: 2.0.0
data: 2026-06-10
autoria: claude-fable-5 (arquiteto useHBN, ciclo C1)
substitui: prática atual do `.hbn/relay/INDEX.md` monolítico (sem spec formal anterior)
evidencia-motivadora: reports/BASELINE-RETOMADA-2026-06-10.md (retomada 0177 = 238–393 KB)
hearback-status: confirmado 2026-06-10 (readback 0001 / hearback 0001)
---

# Relay spec v2 — separar ESTADO de LOG

## O problema, em linguagem humana

Hoje o relay do Credenciamento é um único arquivo (`.hbn/relay/INDEX.md`,
174 KB, 2.162 linhas) que faz dois trabalhos opostos ao mesmo tempo:

1. **Dizer o que vale AGORA** — quem tem o bastão, qual a onda, qual a
   próxima ação. Isso cabe em ~20 linhas e muda toda onda.
2. **Lembrar tudo o que já aconteceu** — 177 ondas de tabelas, gates,
   manifestos. Isso cresce para sempre e quase nunca precisa ser relido.

Como os dois moram juntos, toda IA que retoma paga o preço do histórico
inteiro para extrair 20 linhas de presente. É como obrigar o plantonista que
chega a reler o prontuário do hospital desde a fundação só para saber qual
paciente está na mesa. A separação STATE × LOG dá ao plantonista uma ficha de
plantão de 1 página; o prontuário continua existindo, mas é consulta sob
demanda, não pedágio de entrada.

Benefício secundário: com um STATE pequeno e schema-validado, um guard pode
RECUSAR mecanicamente um handoff que esqueceu de atualizar a `proxima-acao` —
exatamente o pedido da evolução 0177. Num arquivo de 174 KB isso é inviável.

## Estrutura proposta

```
.hbn/relay/
  STATE.md          ← o vigente. ≤80 linhas. Sobrescrito a cada onda.
  INDEX.md          ← vira ponteiro de 10 linhas: "estado em STATE.md; histórico no archive"
relay-archive/      ← LOG frio, append-only (recebe o conteúdo histórico do INDEX atual)
  2026-Q2.md        ← particionado por trimestre para não recriar o monólito
```

### STATE.md — regras

- **≤80 linhas, um único arquivo, sobrescrito** (nunca append). O git é o
  histórico do STATE; não se acumula nada nele.
- Front-matter YAML é a parte normativa, validada contra
  `schemas/state.schema.json`. Corpo markdown opcional (≤20 linhas) só para
  observações da onda corrente.
- Contém APENAS o vigente: proprietário do bastão, onda atual, papel de cada
  IA agora, próxima ação atômica, sinais HBN abertos, ponteiros para readback
  ativo + handoff mais recente + âncoras de rollback. Nada de histórico.
- Quem fecha onda/handoff **atualiza o STATE no mesmo commit** e move a seção
  da onda encerrada para o `relay-archive/` (uma seção, formato livre atual).
- Sinal que fechou sai do STATE (vive no archive); sinal aberto permanece.

### LOG (relay-archive) — regras

- Append-only, frio, particionado por trimestre. Mesmo formato de seções por
  onda já praticado no INDEX atual — zero migração de conteúdo, só de endereço.
- Nunca está em read-list de retomada. É consultado sob demanda (auditoria,
  arqueologia de decisão), via grep pelo ID da onda.

## STATE-modelo preenchido (onda 0177, estado real de 2026-06-10)

```markdown
---
state_version: 1
projeto: Credenciamento
protocolo: "HBN 0.3.1 + PROMPT_ARQUITETO v1.6"
onda_atual: "38.2.44 / 0177"
proprietario_bastao: claude-opus-4-8
papel_bastao: auditor-arquiteto
papeis:
  implementador: "codex — EM ESPERA até pareceres + hearback"
  auditor_cruzado_1: "claude-opus-4-8 — ATIVO (proposal 0034)"
  auditor_cruzado_2: "antigravity-gemini35 — PENDENTE (proposal 0035)"
  consolidador: "codex — futuro (proposal 0036)"
proxima_acao: "Opus abre chat novo, lê .hbn/messages/20260610-0110-prompts-auditoria-cruzada-v206-v207.md e produz .hbn/proposals/0034-claude-opus48-auditoria-pendencias-freeze-v206-v207.md"
sinais_abertos:
  - "🔵 0177 HANDOFF READY — bastão formal com Opus"
  - "🟠 0176 gate visual aberto: relatórios 043-048 não usam área branca direita"
  - "🟡 freeze V12.0.0206 bloqueado até validação tela a tela"
  - "🟡 V12.0.0207 apenas planejada"
readback_ativo: ".hbn/readbacks/0177-rb-onda-38-2-44-handoff-opus-pendencias-v206-v207.json"
handoff_mais_recente: ".hbn/messages/20260610-0110-handoff-fim-sessao-codex-bastao-codex-para-opus.md"
ancora_rollback: "0df2241"
ancora_estavel: "V12-202-Z011-onda17-fechada (INTOCÁVEL até aprovação do operador)"
ciclo_ativo: "V12.0.0206 em validação iterativa; V12.0.0205 é a release oficial"
ultima_atualizacao: "2026-06-10T01:10:00-03:00"
atualizado_por: codex
---

Nota da onda: 0176 verde em import/compile/TV2 (TV2_20260610_005405, OK=16);
finding visual remanescente nos relatórios. Não abrir fix VBA antes dos
pareceres Opus/Antigravity + consolidação Codex + hearback Maurício.
```

(38 linhas — metade do teto de 80.)

## Campo `atribuicao` — chapéus checáveis por máquina (ACCEPTED — corrente E 50%, readback 0002, 2026-06-10)

Adição aceita ao front-matter do STATE: bloco `atribuicao` com
`chapeu_atual` (papel da janela dona do
bastão AGORA — inequívoco), `implementador` e `auditores` (apelidos de perfis
ADR-015), `gravada_em` e `hearback_ref`. Forma e regras:
`core/roles-assignment-spec.md` §2; validação: `schemas/state.schema.json`
(propriedade `atribuicao`) + `guards/assert-role-family.sh` (invariante
anti-groupthink: auditor nunca da família do implementador sem hearback). O
campo `papeis` em prosa permanece — humanos leem prosa; guards leem
`atribuicao`.

## Read-list canônica de retomada (substitui os 16+ itens)

Quem retoma lê, nesta ordem, e SÓ isto:

1. `.hbn/relay/STATE.md` — o vigente (≤80 linhas).
2. O handoff apontado por `handoff_mais_recente` — contexto narrativo da
   transferência (16 seções, schema `handoff.schema.json`).
3. O readback apontado por `readback_ativo` — contrato da onda (escopo,
   invariantes, gates).
4. O contrato do papel em `agents/role-templates.md` — o template do SEU
   papel (implementador/auditor/consolidador), que já embute as regras
   permanentes aplicáveis (0017/0019) por referência.
5. `.hbn/knowledge/0022-firewall-workflow-fast-track.md` — o firewall
   (workflows só fast_track; escrita safe_track é humano-aplicada). 3,1 KB.
   Único invariante que permanece sempre-quente (decisão Maurício, C1,
   2026-06-10, hearback conservador).

Total da read-list: 18,5 KB (dry-run do baseline, 4 arquivos) + 3,1 KB
(0022) = **21,6 KB em 5 itens** — contra 238–393 KB da prática atual.

**Regra geral do invariante sempre-quente**: um invariante só entra na
read-list de retomada (leitura sempre-quente) se for crítico de
segurança/negócio **E** ainda não for garantido por guard executável. O 0022
qualifica hoje nos dois critérios (firewall de escrita; nenhum guard cobre
orquestração automática). Quando um guard executável passar a cobri-lo, ele
sai da read-list e vira consulta sob demanda — a regra fica, o item roda.

Demais regras permanentes (knowledge 00xx, regras de negócio, PHAGO etc.)
saem da read-list de retomada: são consulta sob demanda quando o escopo da
onda tocar o tema — o readback já aponta quais valem para a onda via
`files_allowed` / `invariants_preserved`.

## Guard conceitual — recusa handoff sem STATE atualizado

Pedido literal da evolução 0177 ("guard que recuse relay sem proxima-acao
atualizada quando houver handoff novo"). Especificação para futuro
`scripts/hbn-guards/guard-state-fresh.sh` (a implantação no Credenciamento é
de outra rodada; aqui é só a especificação):

```bash
#!/usr/bin/env bash
# guard-state-fresh.sh — BLOQUEIA commit que cria/altera handoff sem STATE coerente
set -euo pipefail
STATE=".hbn/relay/STATE.md"
fail() { echo "GUARD-STATE-FRESH: $1" >&2; exit 1; }

# Gatilho: o commit em curso toca algum handoff?
HANDOFFS=$(git diff --cached --name-only | grep -E '^\.hbn/messages/.*handoff.*\.md$' || true)
[ -z "$HANDOFFS" ] && exit 0   # sem handoff novo, guard não opina

# 1. STATE precisa existir e estar staged no MESMO commit
[ -f "$STATE" ] || fail "handoff staged mas $STATE não existe"
git diff --cached --name-only | grep -qx "$STATE" \
  || fail "handoff staged sem atualização do STATE no mesmo commit"

# 2. STATE precisa apontar para o handoff que está entrando
H=$(echo "$HANDOFFS" | head -1)
grep -q "$(basename "$H")" "$STATE" \
  || fail "campo handoff_mais_recente não aponta para $H"

# 3. proxima_acao não pode estar vazia nem igual à versão anterior do STATE
NOVA=$(awk -F': ' '/^proxima_acao:/{print substr($0,index($0,": ")+2)}' "$STATE")
[ -n "$NOVA" ] || fail "proxima_acao vazia"
VELHA=$(git show HEAD:"$STATE" 2>/dev/null | awk -F': ' '/^proxima_acao:/{print substr($0,index($0,": ")+2)}' || true)
[ "$NOVA" != "$VELHA" ] || fail "proxima_acao não mudou — handoff sem próxima ação nova"

# 4. STATE ≤80 linhas e front-matter válido contra schemas/state.schema.json
[ "$(wc -l < "$STATE")" -le 80 ] || fail "STATE excede 80 linhas — estado vazando para log"
# validação de schema: extrair front-matter (yq/python) e validar; falha => exit 1
exit 0
```

Checagens 1–3 são puro bash/git (zero dependências); a 4 reaproveita o padrão
dos guards existentes (`scripts/hbn-guards/`). Conforme knowledge 0021, em
sandbox o guard é informativo; conclusivo no Terminal do operador.

## Migração (quando e se Maurício confirmar)

1. Criar `STATE.md` a partir do front-matter atual do INDEX (o modelo acima).
2. Mover corpo do INDEX para `relay-archive/2026-Q2.md` (mv + 1 commit).
3. Reduzir INDEX.md a ponteiro de 10 linhas (compatibilidade com links).
4. Atualizar AGENTS.md do projeto: read-list de retomada → 5 itens (incl. 0022).
5. Ativar guard-state-fresh no pre-commit.

Custo estimado: 1 onda safe_track documental. Rollback: `git revert` (o
conteúdo nunca é destruído, só muda de endereço).
