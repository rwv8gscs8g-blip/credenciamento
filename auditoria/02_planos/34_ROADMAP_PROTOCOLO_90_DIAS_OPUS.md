---
titulo: Roadmap de 90 dias — Institucionalização do protocolo executável
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206+
data: 2026-05-24
autor: claude-opus-4-7
papel: arquiteto-principal
horizonte: 2026-05-24 a 2026-08-22
---

# Roadmap de 90 dias — Institucionalização do protocolo executável

Este roadmap é **paralelo e ortogonal** ao roadmap funcional da V206/V207. O
roadmap funcional entrega features ao usuário; este aqui transforma o
protocolo HBN de "doutrina em markdown" em "código que roda automaticamente
e impede regressão". O sucesso é medido pela métrica `incidentes-de-pasta-errada-por-trimestre = 0` 
e pela frase: ao chamar Codex de uma pasta errada, o terminal responde
`error: not in canonical root, refusing to operate`.

## Princípios diretores

1. **Se uma regra não vira código, ela não existe.** Texto em markdown é
   sugestão, não controle.
2. **Defesa em profundidade.** Cinco camadas (física → git → protocolo → papéis → 
   evidência), não uma só. Um airbag não é uma checklist.
3. **Uma coisa por vez.** Cada fase tem 1 critério de saída testável.
   Sem critério satisfeito, não há próxima fase.
4. **Fagocitar o legado.** Não é suficiente declarar `local-ai/` deprecated —
   precisa ser fisicamente arquivado para que nenhuma IA o leia por engano.
5. **Auditabilidade > velocidade.** Bypass deixa rastro. Bypass sem rastro
   é tratado como achado P0 na revisão semanal.

## Visão geral (3 fases × 30 dias)

| Fase | Datas | Tema | Critério de saída |
|---|---|---|---|
| **F1** | 2026-05-24 → 2026-06-22 | Enforcement mínimo viável + cura do protocolo | Rodar `git commit` numa pasta errada **falha**. Onda 36 fechada com ERP. |
| **F2** | 2026-06-23 → 2026-07-22 | Contratos executáveis Opus/Gemini/Codex + RAG canônico | Pelo menos uma onda V206 fechada com ciclo completo arquiteto→audit-pre→hearback→executor→audit-post→ERP. |
| **F3** | 2026-07-23 → 2026-08-22 | Fagocitose das árvores paralelas + replicação para timelessphoto.art | `local-ai/obsidian-vault/`, vault Obsidian morta e pastas V12-* fora da raiz. Padrão replicado em pelo menos mais 1 projeto. |

## Fase 1 — Enforcement mínimo viável (semanas 1–4)

### Onda 36 (já em execução nesta sessão Opus)

| Entregável | Status | Path |
|---|---|---|
| `.hbn/canonical-root` | ✅ feito | raiz canônica declarada |
| `.hbn/schemas/readback.schema.json` | ✅ feito | contrato JSON do readback |
| `.hbn/schemas/hearback.schema.json` | ✅ feito | contrato JSON do hearback |
| `.hbn/schemas/audit-pre.schema.json` | ✅ feito | contrato JSON da auditoria pré |
| `.hbn/schemas/audit-post.schema.json` | ✅ feito | contrato JSON da auditoria pós |
| `.hbn/forbidden-paths.txt` | ✅ feito | lista de paths legacy bloqueados |
| `scripts/hbn-guards/` (6 scripts + lib + runner + installer + README) | ✅ feito | guards executáveis |
| Hook `.git/hooks/pre-commit` unificado | ⏳ aguardando Mauricio rodar `install.sh` | encadeamento com G7/G8 |
| `auditoria/00_status/105_*` (auditoria do handoff) | ✅ feito | esta devolutiva |
| `auditoria/02_planos/34_*` (este roadmap) | ✅ feito | aqui |
| `auditoria/02_planos/35_*` (plano de arquivamento) | ✅ feito | plano de fagocitose |
| `auditoria/00_status/106_*` (devolutiva ao Codex) | ✅ feito | prompt revisado |
| `.hbn/knowledge/0013-contratos-executaveis.md` | ✅ feito | regra permanente |
| AGENTS.md atualizado | ✅ feito | nova seção §Contratos executáveis |
| `.hbn/relay/INDEX.md` atualizado | ⏳ aguardando confirmação | bastão volta para Codex (Onda 37) após hearback |
| Readback 0089 + ERP 0089 | ✅ readback escrito; ERP escrito | aguarda hearback |

### Critério de saída da F1

Os 3 testes abaixo devem passar:

1. **Teste de raiz**: `cd /private/tmp && git clone <repo> tmp-cred && cd tmp-cred && touch foo.md && git add foo.md && git commit -m test` → **deve falhar** com mensagem clara do `assert-canonical-root.sh` ou `forbid-tmp-worktree.sh`.

2. **Teste de scope**: na raiz correta, criar readback safe_track com `scope.files_allowed = ["docs/X.md"]`, modificar `src/vba/Svc_Rodizio.bas` (proibido), `git add` e `git commit` → **deve falhar** com mensagem do `assert-scope-lock.sh`.

3. **Teste de env**: na raiz correta, criar `.env.local` com qualquer conteúdo, `git add -f .env.local && git commit` → **deve falhar** com mensagem do `forbid-env-files.sh`.

Se os 3 passam: F1 fechada. Onda 36 ganha ERP definitivo e o bastão volta para Codex (Onda 37 — Reconciliação V5).

### Riscos de F1 e mitigações

| Risco | Severidade | Mitigação |
|---|---|---|
| pre-commit instalado mas não roda em pull request via GitHub Actions | medium | Adicionar workflow `.github/workflows/hbn-guards-ci.yml` na F2 que roda o runner em PRs |
| Bypass virar hábito | high | Revisão semanal (cron de domingo) lista bypasses sem nota → vira P0 automático |
| Schema rejeitar readback antigo válido | low | Onda 36 não migra readbacks 0001–0088; eles continuam válidos sob "v0 sem schema". A partir do 0089 é obrigatório. |
| Codex em novo chat não ler 105/106 | medium | O prompt 106 começa com "Verifique que estes arquivos existem; se não existirem, pare imediatamente" |

## Fase 2 — Contratos executáveis Opus/Gemini/Codex + RAG (semanas 5–8)

Objetivo: o que hoje são prompts colados manualmente vira **wrappers
executáveis** que enforçam pré-condições antes de invocar a IA e
pós-condições antes de aceitar o output.

### Entregáveis F2

#### Camada A — Wrappers de IA

`scripts/with-opus.sh <task>` que:

1. Valida `pwd` = raiz canônica.
2. Garante que há intent registrado em `.hbn/intents/`.
3. Constrói o prompt do Opus injetando: AGENTS.md, ADRs vigentes, princípios
   P1–P13, último readback da branch, knowledge relevante.
4. Invoca a IA (Cowork / Claude API).
5. Recebe o readback proposto e valida contra schema antes de aceitar.

Análogos: `scripts/with-gemini.sh`, `scripts/with-codex.sh`.

#### Camada B — Fluxo padrão de onda completa

Script `scripts/hbn-wave.sh` que orquestra:

```
hbn-wave new <tema>
  → cria intent em .hbn/intents/NNNN-tema.yaml

hbn-wave architect
  → invoca Opus com intent + contexto → produz readback + ADR (se necessário)

hbn-wave audit-pre
  → invoca Gemini contra o readback → produz .hbn/audits/NNNN-pre.json
  → exit 0 se verdict=pass; exit 1 se fail
  
hbn-wave hearback
  → aguarda assinatura humana de .hbn/hearbacks/NNNN.json
  → bloqueia até status=confirmed

hbn-wave execute
  → invoca Codex em sandbox restrito (sem acesso fora do scope.files_allowed)
  → produz diff git + saída de testes
  → roda gates declarados em validation_plan

hbn-wave audit-post
  → invoca Gemini sobre diff + saída de testes → .hbn/audits/NNNN-post.json
  → recommendation: aceitar | aceitar_com_debito | revisar | reverter

hbn-wave erp
  → cria .hbn/results/NNNN-exec-*.json
  → commita tudo (readback, hearback, audits, erp, código)
  → atualiza .hbn/relay/INDEX.md
```

#### Camada C — RAG canônico local

- Indexar `docs/`, `auditoria/00_status/`, `auditoria/01_regras_e_governanca/`,
  `auditoria/02_planos/`, `.hbn/knowledge/`, `.hbn/readbacks/` (últimos 90 dias),
  `usehbn/methodology/`.
- Não indexar `obsidian-vault/`, `local-ai/`, `V12-*/`, `backups/`,
  `auditoria/03_ondas/` antigas (>180 dias).
- Servir via MCP local que cada wrapper consulta antes de invocar a IA
  (resposta vira parte do prompt).
- Refresh diário via cron / launchd.

#### Camada D — CI semanal

`.github/workflows/hbn-weekly-review.yml`:

- Roda toda segunda 09:00 BRT.
- Lista bypasses sem nota correspondente em `.hbn/bypasses/`.
- Lista readbacks que ficaram >7 dias com `human_status: pending`.
- Lista ondas sem audit-post.
- Abre issue automática com label `hbn/weekly`.

### Critério de saída da F2

Pelo menos **uma** onda V206 (provavelmente a Onda 38 — MD33-restart) deve
ser executada do começo ao fim usando `hbn-wave`, com todos os 6 artefatos
gerados (intent, readback, audit-pre, hearback, audit-post, ERP) e o commit
final passando por todos os guards sem bypass.

## Fase 3 — Fagocitose e replicação (semanas 9–12)

### Bloco 1 — Fagocitose das árvores paralelas no Credenciamento

Plano detalhado em `auditoria/02_planos/35_PLANO_ARQUIVAMENTO_LOCAL_AI_E_V12_PASTAS.md`.

Resumo:

| O que | Para onde | Como |
|---|---|---|
| `local-ai/obsidian-vault/` (214 .md) | branch `archive/local-ai-pre-canonical-2026-05` e depois removido da `main` | Script de migração com manifest SHA-256 + commit em branch dedicada |
| `local-ai/auditoria/` | mesma branch arquivo | conteúdo perene migrado para `auditoria/` real ou descartado |
| `local-ai/root/.cursorrules` (V12.0.0180) | mesma branch arquivo | substituído por `.cursorrules` novo no root apontando para AGENTS.md |
| Pastas `V12-*/` (5 pastas-snapshot) | repo separado `credenciamento-snapshots` ou git-lfs | tags `snapshot/v12.0.0204-micro48`, etc. |
| `obsidian-vault/` na raiz | conteúdo perene (metodologia, releases canônicos) migra para `docs/`; daily notes/log vão para vault Obsidian PESSOAL do Mauricio fora do repo | script Python + revisão Mauricio |
| Arquivos `~$*.xlsm`, `.DS_Store` | deletados | `git clean` + `.gitignore` reforçado |
| `Credenciamento/usehbn/` | submódulo apontando para tag específica do usehbn canônico em `/Projetos/usehbn/` | substitui cópia divergente |

### Bloco 2 — Replicação para timelessphoto.art

Aplicar o mesmo padrão (guards + schemas + roadmap) no `timelessphoto.art`:

- `.hbn/canonical-root` com `/Users/macbookpro/Projetos/timelessphoto.art`
- Mesmo `scripts/hbn-guards/` (copiado).
- Adaptar lista `.hbn/forbidden-paths.txt` para os scripts legados específicos
  daquele projeto (`scripts/cleanup-and-version.sh`, `scripts/release-v5.10.1.sh`,
  `scripts/organize-docs.sh`).
- Eliminar URLs antigas (`tna-studio-v5.vercel.app`) dos targets de teste no
  `package.json`.
- Adicionar `.github/workflows/` que substitua a parte do Shield Protocol
  hoje rodada por shell scripts manuais.

### Bloco 3 — Aposentar `usehbn-phago` como skeleton

Decisão: ou ele vira aplicação real do protocolo (com `.hbn/`, schemas, guards,
ondas executadas), ou é arquivado em `usehbn-phago.archived`. Skeletons
documentais drenam credibilidade da doutrina (citado na análise inicial).

### Critério de saída da F3

- `local-ai/obsidian-vault/` e `local-ai/auditoria/` não existem mais na
  branch `main`.
- `V12-*/` removidas da raiz; conteúdo preservado em repo de snapshots ou LFS.
- `timelessphoto.art` tem o mesmo pre-commit unificado e passa nos 3 testes
  de smoke.
- `CHANGELOG.md` do Credenciamento tem entrada `### Lição` para os incidentes
  de 02/05 e 24/05.
- Vault Obsidian pessoal de Mauricio existe fora dos repositórios e contém
  o conhecimento que estava misturado nas vaults dos projetos.

## KPIs (medir a cada 30 dias)

| KPI | Baseline 2026-05-24 | Meta F1 | Meta F2 | Meta F3 |
|---|---|---|---|---|
| Mean Time to Detect Drift (pasta errada) | dias (descoberto por humano) | minutos (rejeitado no pre-commit) | 0 (não chega ao commit) | 0 |
| Incidentes P0 de pasta errada por trimestre | 2 (02/05 e 24/05) | 0 | 0 | 0 |
| Bypasses do pre-commit por mês | n/a (sem hook) | ≤2 com nota | ≤1 com nota | 0 |
| Tempo médio de uma onda (intent → ERP) | indef | medir | medir | reduzir 20% vs F2 |
| Readbacks com schema válido | 0% | 100% (a partir de 0089) | 100% | 100% |
| Ondas com audit-pre + audit-post | 0 | n/a | ≥1 | ≥3 |
| Cobertura de testes adversariais no usehbn | 0 | 0 | n/a | ≥1 (race em handoff) |
| Arquivos .md na vault "viva" (obsidian-vault/) | ~270 (com legacy) | 5 | 5 | 0 (deletada) |

## Riscos macro

| Risco | Mitigação |
|---|---|
| Mauricio cansar do overhead | Wrappers da F2 reduzem o overhead manual; medir tempo médio de onda explicitamente |
| Codex/Gemini ignorarem o readback declarado | scope-lock no pre-commit faz o git ignorar a IA, não o operador |
| Adoção parcial deixar 2 sistemas convivendo | Cada projeto migra como um todo; sem meia-implementação |
| Drift entre `usehbn/` canônico e cópia em projetos | Onda da F3 transforma cópias em submódulos com pin de tag |

## Compromissos do Opus como arquiteto

1. Manter este roadmap atualizado a cada virada de fase (commit em onda
   safe_track própria).
2. Não introduzir novo princípio P14+ sem ADR aprovado por humano.
3. Reportar quinzenalmente em `.hbn/reports/quinzenal-AAAAMMDD.md` o estado
   dos KPIs.
4. Cancelar uma fase se KPI da fase anterior não foi atingido — não acumular
   dívida.

— Claude Opus 4.7, 2026-05-24
