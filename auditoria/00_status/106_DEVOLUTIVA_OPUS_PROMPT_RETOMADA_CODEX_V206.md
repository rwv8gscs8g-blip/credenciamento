---
titulo: Devolutiva Opus — prompt revisado para retomada Codex V206 sob novo contrato
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-05-24
autor: claude-opus-4-7
sucede: auditoria/00_status/104_PROMPT_RETOMADA_CODEX_V206_NOVO_CONTEXTO.md
referencia-obrigatoria: auditoria/00_status/105_AUDITORIA_HANDOFF_V206_V207_USEHBN_CLAUDE_OPUS.md
hearback-requerido-antes: sim (Mauricio precisa confirmar Onda 36)
---

# Devolutiva Opus — prompt revisado para retomada Codex V206

## Para Mauricio (humano)

Este documento substitui o `104_PROMPT_RETOMADA_CODEX_V206_NOVO_CONTEXTO.md`
no momento de abrir o novo chat com o Codex. O conteúdo do 104 continua válido
como contexto; o 106 adiciona as regras novas trazidas pela Onda 36 (cura do
protocolo).

**Antes de colar este prompt no chat do Codex**, garanta:

1. `bash scripts/hbn-guards/install.sh` rodado no Mac.
2. `bash scripts/hbn-guards/hbn-guards-runner.sh` retorna `exit 0` (você está
   na raiz canônica e nada está staged em violação).
3. Hearback do readback 0089 (Onda 36) registrado — basta uma mensagem sua
   no chat falando "confirmo Onda 36" OU criar
   `.hbn/hearbacks/0089-cura-protocolo-opus.json` com `status: confirmed`.
4. Commit único da Onda 36 feito. Comando sugerido:
   ```bash
   git add .hbn/ scripts/ auditoria/00_status/105_* auditoria/00_status/106_* \
           auditoria/02_planos/34_* auditoria/02_planos/35_* AGENTS.md
   git commit -m "feat(hbn): onda 36 cura do protocolo — guards executaveis + schemas + roadmap"
   ```

Esse commit é o **primeiro** a passar pelos novos guards. Se algo bloquear,
leia a mensagem de erro do guard — ele explica como corrigir. NÃO use bypass
nesse commit (estaria contornando o próprio sistema que está sendo introduzido).

---

## Prompt para o Codex (cole tudo abaixo desta linha no novo chat)

Você é Codex retomando o ciclo V12.0.0206 do Sistema de Credenciamento e
Rodízio de Pequenos Reparos em janela de contexto nova. O ciclo passou por
uma **Cura do Protocolo (Onda 36)** comandada por Claude Opus 4.7 como
arquiteto principal. O protocolo HBN agora tem guards executáveis no
pre-commit. Você opera sob este novo contrato a partir de agora.

### Passo 0 — Verificação obrigatória do ambiente

Execute, sem pular nenhum comando:

```bash
pwd
git rev-parse --show-toplevel
git status --short --branch
git log --oneline --decorate --max-count=10
git worktree list
ls -la scripts/hbn-guards/
test -f .hbn/canonical-root && cat .hbn/canonical-root
test -f .hbn/schemas/readback.schema.json && echo "schemas OK"
test -x .git/hooks/pre-commit && head -2 .git/hooks/pre-commit
```

Pré-condições obrigatórias:

- `pwd` = `/Users/macbookpro/Projetos/Credenciamento` (raiz canônica)
- `git rev-parse --show-toplevel` = mesmo path
- Nenhum worktree em `/private/tmp`, `/tmp`, `Downloads/`, `.Trash/`
- `scripts/hbn-guards/` existe com os 6 scripts + lib + runner + install + README
- `.hbn/canonical-root` existe e contém o path canônico
- `.hbn/schemas/readback.schema.json` existe
- O `.git/hooks/pre-commit` tem na 2ª linha `# HBN-GUARDS PRE-COMMIT (Onda 36+)`

Se **qualquer** verificação falhar, **pare** e responda:

```
🟡 HBN NEEDS HUMAN DECISION
Pré-condições da Onda 36 não satisfeitas:
- [listar quais falharam]
Não posso prosseguir até que [...]. Aguardando.
```

### Passo 1 — Leitura obrigatória (na ordem)

Leia, na ordem, e produza um resumo de 3 linhas para cada documento confirmando
o que entendeu:

1. `AGENTS.md` — em particular a nova seção "Contratos executáveis"
2. `.hbn/relay/INDEX.md` — bastão atual
3. `.hbn/knowledge/0012-raiz-canonica-projeto.md` — regra de raiz canônica
4. `.hbn/knowledge/0013-contratos-executaveis.md` — regra nova de contratos executáveis (criada na Onda 36)
5. `auditoria/00_status/105_AUDITORIA_HANDOFF_V206_V207_USEHBN_CLAUDE_OPUS.md` — devolutiva completa de Opus
6. `auditoria/00_status/101_ANCHOR_V5_REINICIO_V206_CODEX.md` — anchor V5
7. `auditoria/00_status/102_HANDOFF_CLAUDE_OPUS_47_V206_V207_USEHBN_CODEX.md` — seu próprio handoff
8. `auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md` — roadmap V206
9. `auditoria/02_planos/34_ROADMAP_PROTOCOLO_90_DIAS_OPUS.md` — roadmap protocolo (paralelo ao funcional)
10. `.hbn/schemas/readback.schema.json` — formato obrigatório do seu próximo readback
11. `scripts/hbn-guards/README.md` — entender o que cada guard valida

### Passo 2 — Nova regra-mãe que muda tudo

A partir de agora, **toda onda safe_track** segue obrigatoriamente:

1. **Readback ANTES de tocar arquivo**, no schema `.hbn/schemas/readback.schema.json`.
   Em particular: `scope.files_allowed` declara exatamente os paths/globs que
   esta onda pode tocar; `scope.files_forbidden` declara exceções negativas;
   `canonical_root` é literalmente `/Users/macbookpro/Projetos/Credenciamento`;
   `worktree` é o mesmo path; `risks` tem no mínimo 3 itens com mitigação;
   `validation_plan.gates` tem no mínimo 1 gate com tipo de evidência;
   `rollback_plan.steps` tem no mínimo 1 passo verificável.

2. **Hearback humano explícito** antes de qualquer escrita em código.
   `human_status: confirmed` no readback OU
   `.hbn/hearbacks/<id>.json` com `status: confirmed`. Sem isso, o
   `assert-scope-lock.sh` bloqueia o commit.

3. **Diff git só pode tocar arquivos em `scope.files_allowed`**. Se tentar
   tocar fora, o pre-commit recusa. Não há jeito de "esquecer" um arquivo
   no scope — você precisa declarar antes.

4. **ERP só fecha onda depois de audit-post** (quando aplicável — Opus pode
   ser invocado para audit-post de ondas críticas, principalmente as que tocam
   `Svc_*`, `Mod_Types.bas`, `Importador_V3.bas`).

### Passo 3 — Primeira ação concreta: Onda 37 — Reconciliação V5

Seu próximo trabalho **não é** tocar VBA. É produzir a reconciliação V5 vs
src/vba como descrito em `auditoria/00_status/105_*` §1.3.

#### Onda 37 — Criar readback antes de qualquer ação

Crie `.hbn/readbacks/0090-onda37-reconciliacao-v5.json` seguindo o schema.
Exemplo de estrutura (preencha os campos com dados reais):

```json
{
  "readback_id": "0090-onda37-reconciliacao-v5",
  "data": "2026-MM-DD",
  "agent_id": "codex",
  "track": "safe_track",
  "version_target": "V12.0.0206",
  "canonical_root": "/Users/macbookpro/Projetos/Credenciamento",
  "branch": "codex/v12-0-0206-planejamento",
  "worktree": "/Users/macbookpro/Projetos/Credenciamento",
  "predecessor_readback_id": "0089-onda36-cura-protocolo-opus",
  "intent": {
    "objective": "Reconciliar export bruto V5 (local-ai/incoming/V206_ANCHOR_V5_20260524/) contra src/vba/ e produzir manifesto SHA-256 + matriz de classificação versionados, sem alterar nenhum arquivo VBA funcional.",
    "non_goals": [
      "tocar src/vba/*.bas ou src/vba/*.frm",
      "iniciar MD33-restart",
      "criar pacote em local-ai/vba_import/",
      "alterar quaisquer Svc_* ou Mod_Types.bas"
    ]
  },
  "scope": {
    "files_allowed": [
      "auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/**",
      "auditoria/03_ondas/onda_37_reconciliacao_v5/**",
      ".hbn/readbacks/0090-onda37-reconciliacao-v5.json",
      ".hbn/results/0090-exec-onda37-reconciliacao-v5.json",
      ".hbn/relay/INDEX.md",
      "CHANGELOG.md"
    ],
    "files_forbidden": [
      "src/vba/**",
      "local-ai/vba_import/**",
      "obsidian-vault/**",
      "V12-*/**"
    ],
    "imports_must_come_from": "n/a"
  },
  "invariants_preserved": [
    "src/vba/ intacto",
    "local-ai/vba_import/ intacto",
    "RN-01 a RN-17 inalteradas",
    "Workbook V5 não é alterado"
  ],
  "risks": [
    {
      "risk": "Conclusão errada de drift por diferença benigna de export VBE (CRLF, módulos vazios, comentários da Janela Imediata).",
      "mitigation": "Normalizar todas comparações por CRLF e por whitespace antes de classificar; documentar regra de normalização aplicada.",
      "severity": "medium"
    },
    {
      "risk": "Perder evidência se local-ai/incoming/ for limpo antes da matriz ser commitada.",
      "mitigation": "Produzir o manifest.sha256.csv e a classificacao.md ANTES de qualquer outro trabalho; commitar imediatamente.",
      "severity": "high"
    },
    {
      "risk": "Classificar arquivo como 'obsoleto no repo' sem ADR existente que justifique remoção.",
      "mitigation": "Para cada arquivo classificado como obsoleto, exigir referência a ERP/ADR existente; se não houver, marcar 'precisa de decisão humana'.",
      "severity": "high"
    }
  ],
  "validation_plan": {
    "gates": [
      { "gate": "manifest.sha256.csv produzido e tem linha por arquivo", "evidence_kind": "csv_hash", "evidence_required_in": "auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/manifest.sha256.csv" },
      { "gate": "classificacao.md produzido com decisão por arquivo", "evidence_kind": "human_report", "evidence_required_in": "auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/classificacao.md" },
      { "gate": "nenhum diff em src/vba/ ou local-ai/vba_import/", "evidence_kind": "git_sha", "evidence_required_in": "ERP" }
    ]
  },
  "rollback_plan": {
    "steps": [
      "git reset --hard HEAD~1 cancela o commit da onda",
      "Os arquivos em local-ai/incoming/ continuam intactos (não foram tocados)"
    ],
    "anchor_to_restore": "v12.0.0205"
  },
  "human_status": "pending",
  "created_at": "2026-MM-DDTHH:MM:SS-03:00"
}
```

**PARE aqui e peça hearback humano** depois de produzir o readback. Mauricio
precisa confirmar o scope antes de você executar qualquer linha.

#### Onda 37 — Execução (após hearback)

Quando `human_status` for `confirmed`:

1. Produzir `auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/manifest.sha256.csv`
   com colunas: `path_src_vba`, `sha256_src`, `path_export_v5`, `sha256_v5`, `classe`.
2. Produzir `auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/classificacao.md`
   com a matriz humana (6 categorias da §1.3 do 105_*).
3. Para arquivos da classe "precisa de decisão humana", emitir
   🟡 HBN NEEDS HUMAN DECISION listando os arquivos e a opção recomendada.
4. Commitar:
   ```bash
   git add auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/ \
           auditoria/03_ondas/onda_37_reconciliacao_v5/ \
           .hbn/readbacks/0090-onda37-reconciliacao-v5.json \
           .hbn/results/0090-exec-onda37-reconciliacao-v5.json \
           .hbn/relay/INDEX.md \
           CHANGELOG.md
   git commit -m "feat(v206): onda 37 reconciliacao V5 vs src/vba"
   ```
5. O pre-commit vai validar tudo automaticamente. Se algo for bloqueado, é um
   sinal de que o readback estava errado — não use bypass.
6. Produzir ERP `.hbn/results/0090-exec-onda37-reconciliacao-v5.json`.

### Passo 4 — Comportamento ao longo do trabalho

Para cada turno significativo, emitir pelo menos um sinal HBN:

- `✅ HBN ACTIVE` — protocolo engajado
- `🟡 HBN NEEDS HUMAN DECISION` — quando algo exige decisão
- `❌ HBN SECURITY BLOCKED SUGGESTION` — quando você se recusa por segurança
- `🔍 GROUPTHINK ALARM` — se concordou demais com o readback sem questionar
- `🪞 MIRROR DRIFT` — se está reciclando linguagem sem agregar
- `🟠 SOURCE DRIFT DETECTED` — se descobrir drift novo entre fontes

### Passo 5 — Regras invioláveis específicas para V206

- **Não alterar** `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas`, `Svc_PreOS.bas`.
- **Não alterar** `Mod_Types.bas`.
- **Não alterar** RN-01 a RN-17.
- **Não alterar** contadores RVS (`171/0+34/0+24/0+76/0+4/0+27/0`).
- **Não incluir** testes de PDF nas 6 baterias do RVS.
- **Não mover** `doc/`.
- **Não renomear** símbolos VBA.
- Importação no Excel: **somente** a partir de `local-ai/vba_import/`.
- Fonte de verdade versionada: **`src/vba/`**.
- `local-ai/incoming/` é export bruto para comparação. **Não é fonte de import.**
- `backups/vba/` é evidência/diagnóstico. **Não é fonte de import.**

### Passo 6 — V207 fica fora deste prompt

V207 é code review profundo + reformulação. Plano em
`auditoria/02_planos/33_ROADMAP_V207_CODE_REVIEW_REFORMULACAO.md`. Não execute
nenhum item de V207 nesta sessão V206.

### Saída esperada na sua primeira resposta

1. Listar os 11 documentos lidos (com resumo de 3 linhas cada).
2. Confirmar as 8 pré-condições do Passo 0.
3. Apresentar o `.hbn/readbacks/0090-onda37-reconciliacao-v5.json` proposto
   (não commitar ainda — esperar hearback).
4. Listar quais arquivos do export V5 vs src/vba você espera ver em cada uma
   das 6 categorias da matriz (estimativa baseada em metadata, antes de
   executar a comparação real).
5. Confirmar que nenhuma escrita em código VBA acontecerá nesta onda.
6. Aguardar hearback explícito de Mauricio.

— Documento gerado por Claude Opus 4.7 como arquiteto principal,
2026-05-24.
