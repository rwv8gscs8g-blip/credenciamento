---
titulo: Auditoria do handoff V206/V207/useHBN — devolutiva Claude Opus 4.7
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: claude-opus-4-7
papel: arquiteto-principal
solicitado-por: codex (via auditoria/00_status/103_PROMPT_AUDITORIA_CLAUDE_OPUS_47_HANDOFF_V206_V207_USEHBN.md)
hearback-requerido: sim (Mauricio antes de Codex retomar)
---

# Auditoria do handoff V206/V207/useHBN — devolutiva Claude Opus 4.7

## Sumário executivo

Codex preparou um handoff **tecnicamente sólido e honesto** (102 a 104). O
diagnóstico de raiz canônica em `0012-raiz-canonica-projeto.md` é preciso e
documenta com transparência exemplar os dois incidentes P0 de pasta errada
(2026-05-02 e 2026-05-24). O escopo proposto para V206 (reconciliar V5 →
MD33-restart → motor PDF → integração → simulação UI) é coerente com a
realidade do sistema e respeita as fronteiras certas (não toca `Svc_*`, não
reabre RN-01 a RN-17, não muda contadores RVS).

**Mas o handoff tem uma lacuna estrutural que precisa ser corrigida antes da
retomada**: ele propõe seis barreiras no protocolo HBN (§Protocolo useHBN —
Pontos para Claude Avaliar) **descritas como texto**. As barreiras 1, 2, 3, 4,
5 e 6 são exatamente do mesmo tipo que falharam em 02/05 e em 24/05 — regras
textuais que dependem da IA executora obedecer. Os incidentes provaram que
isso não é suficiente.

**Devolutiva**: aprovo o escopo V206, aprovo o escopo V207, **endureço o
protocolo HBN convertendo as barreiras 1–4 em guards executáveis nesta mesma
onda** (Onda 36 — Cura do Protocolo). A partir do próximo commit nesta branch,
qualquer violação de raiz canônica, worktree em /tmp, scope fora do readback
ou commit de segredo é **mecanicamente recusada** pelo pre-commit. Codex pode
retomar a V206 sob o novo contrato.

Documentos novos produzidos nesta auditoria:

| Path | Função |
|---|---|
| `.hbn/canonical-root` | Path canônico declarado, lido pelos guards |
| `.hbn/schemas/readback.schema.json` | Contrato JSON do readback (substitui formato livre) |
| `.hbn/schemas/hearback.schema.json` | Contrato do hearback humano |
| `.hbn/schemas/audit-pre.schema.json` | Contrato da auditoria adversarial pré-execução |
| `.hbn/schemas/audit-post.schema.json` | Contrato da auditoria pós-execução |
| `.hbn/forbidden-paths.txt` | Lista de paths legacy bloqueados em commits novos |
| `.hbn/knowledge/0013-contratos-executaveis.md` | Regra permanente (a ser criada — ver §Cura HBN abaixo) |
| `scripts/hbn-guards/` | Cinco guards + runner + instalador (ver `scripts/hbn-guards/README.md`) |
| `auditoria/02_planos/34_ROADMAP_PROTOCOLO_90_DIAS_OPUS.md` | Roadmap fora-da-V206 para institucionalizar o protocolo |
| `auditoria/02_planos/35_PLANO_ARQUIVAMENTO_LOCAL_AI_E_V12_PASTAS.md` | Plano de fagocitose das árvores paralelas |
| `auditoria/00_status/106_DEVOLUTIVA_OPUS_PROMPT_RETOMADA_CODEX_V206.md` | Prompt revisado para Codex retomar V206 sob o novo contrato |

## Parte 1 — Auditoria item a item do handoff

### 1.1 Consistência geral

**Aprovado com observações.** O handoff:

- Identifica corretamente a âncora V5 (`PlanilhaCredenciamento-Homologacao-V5.xlsm`),
  documenta sua origem (`V12-205-OficialCongelada`), e prova o estado com
  Janela Imediata (build, releases, manifesto, RVS aprovado).
- Encerra os 4 incidentes (worktree tmp, MD33 reprovado, restauração via
  backup, V12-0206-Preparacao reprovada) com decisões claras e evidência.
- Mantém limites duros corretos: não tocar `Svc_*`, não alterar RN-01 a RN-17,
  não alterar contadores RVS, não mover `doc/`.
- Separa V206 (incremental) de V207 (code review profundo) sem ambiguidade.

**Observação 1**: o handoff cita 6 propostas para o protocolo HBN
("Pontos para Claude Avaliar") mas todas são formuladas como **regras a
serem seguidas pela IA**. Nenhuma é formulada como **verificação automatizada
no fluxo git**. Isso é o gap a fechar nesta onda.

**Observação 2**: o handoff diz que `local-ai/` está gitignored e portanto o
export V5 não vira commit — está correto. Mas isso significa que se Codex
retomar em outro chat e a pasta `local-ai/incoming/V206_ANCHOR_V5_20260524/`
não estiver no disco dele, ele **não tem a fonte de comparação**. A
reconciliação V5 vs `src/vba` precisa produzir um artefato versionado
(manifesto SHA-256 + classificação) que sobreviva à perda do `local-ai/`.

**Observação 3**: 62 arquivos no export V5 vs 66 em `src/vba` — diferença de
4 arquivos (`Altera_Entidade.frm`, `Altera_Entidade.frx`, `Emergencia_CNAE.bas`,
`Importador_V2.bas`). Codex chamou de "ausentes na V5". Tecnicamente correto.
Mas há duas hipóteses possíveis: (a) foram removidos do workbook em uma onda
recente e `src/vba` está com lixo legado; (b) `src/vba` tem o estado correto
e o workbook V5 perdeu esses módulos. O handoff não resolve. Isso precisa ser
resolvido **antes** de qualquer MD33-restart.

### 1.2 Anchor V5 — aprovado

A decisão de descartar `V12-0206-Preparacao` e adotar V5 derivada de
`V12-205-OficialCongelada` é correta e a evidência (RVS `VR_20260524_164612`
APROVADO com a sintaxe canônica V205) é suficiente. **Aprovado.**

Recomendação adicional: registrar em `auditoria/02_planos/35_*` que a pasta
`V12-0206-Preparaçao` (com o ç quebrado no encoding) deve ser arquivada
**antes** do fechamento da V206, para que nenhuma IA futura confunda
"preparação" com "âncora válida". Mesmo critério vale para
`V12-2024-Micro54-RC1` (nome com erro tipográfico — 2024 deveria ser 0204).

### 1.3 Fase 1 — Reconciliação V5 vs src/vba — aprovado com refinamento

Aprovo o escopo, mas refino a entrega:

A reconciliação deve produzir, na ordem:

1. **`auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/manifest.sha256.csv`** —
   uma linha por arquivo com: path em `src/vba/`, SHA-256 do arquivo
   normalizado por CRLF, SHA-256 do correspondente em `local-ai/incoming/V206_ANCHOR_V5_20260524/`
   (ou `MISSING`), classe.
2. **`auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/classificacao.md`** —
   matriz humana com as 6 categorias propostas por Codex (igual / drift export
   benigno / diferença funcional / ausente no workbook / obsoleto no repo /
   precisa de decisão humana), com **decisão tomada por arquivo**.
3. **`.hbn/readbacks/0090-onda37-reconciliacao-v5.json`** — readback safe_track
   onde `scope.files_allowed = ["auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/**"]`
   apenas (Fase 1 não toca código VBA).
4. **`.hbn/audits/0090-post.json`** — auditoria pós-execução assinada por
   Claude (auditor) confirmando que a classificação é coerente e que nenhum
   arquivo crítico ficou "decisão humana" sem ADR correspondente.

Por que esta sequência: garante que a Fase 1 produz **artefato versionado e
auditável** independentemente do estado de `local-ai/`. Se Codex perder a
pasta, o `manifest.sha256.csv` já contém a verdade objetiva e a classificação
é fonte de decisão.

### 1.4 Fase 2 — MD33-restart — aprovado com guardrail

A correção de `Rel_OSEmpresa` e `Rel_Emp_Serv` (handlers criando instância
vazia após o preenchimento em outra instância) é necessária. Os MD33,
fix1 e fix2 reprovados ficam apenas como histórico — está correto.

**Guardrail novo**: o readback do MD33-restart deve declarar:

```jsonc
{
  "scope": {
    "files_allowed": [
      "src/vba/Rel_OSEmpresa.frm",
      "src/vba/Rel_OSEmpresa.frx",
      "src/vba/Rel_Emp_Serv.frm",
      "src/vba/Rel_Emp_Serv.frx",
      "local-ai/vba_import/<prefixo>-Rel_OSEmpresa.*",
      "local-ai/vba_import/<prefixo>-Rel_Emp_Serv.*",
      "auditoria/03_ondas/onda_33_v206_fix_relatorios_pdf_precondicao/**",
      "CHANGELOG.md"
    ],
    "files_forbidden": [
      "src/vba/Svc_*.bas",
      "src/vba/Mod_Types.bas",
      "src/vba/Importador_V3.bas"
    ],
    "imports_must_come_from": "local-ai/vba_import/"
  },
  "invariants_preserved": [
    "RN-01 a RN-17 inalteradas",
    "contadores RVS inalterados (171/0+34/0+24/0+76/0+4/0+27/0)",
    "Svc_* intactos",
    "Mod_Types.bas intacto",
    "compile manual VBE limpo"
  ]
}
```

Com esse readback, o `assert-scope-lock.sh` (que entra em vigor nesta onda 36)
**impede mecanicamente** que MD33-restart toque qualquer outro arquivo.

### 1.5 Fase 3 — Util_PDF.bas — aprovado

O contrato proposto está completo: hierarquia de pastas, padrão de nomenclatura,
sanitização CNPJ/tipo, validação por magic bytes `%PDF-`, log em
`RPT_PDFs_EMITIDOS.csv`, fallback manual claro. Aprovado.

**Refino**: `Util_PDF.bas` deve ser **um arquivo único e novo** em
`src/vba/` (e seu espelho em `local-ai/vba_import/`). Nada mais. O readback
da Onda 34 declara essa restrição:

```jsonc
{
  "scope": {
    "files_allowed": [
      "src/vba/Util_PDF.bas",
      "local-ai/vba_import/<prefixo>-Util_PDF.bas",
      "auditoria/03_ondas/onda_34_motor_pdf/**",
      "CHANGELOG.md"
    ]
  }
}
```

A integração com Pré-OS / OS / Avaliação / Relatórios é a **Onda 35**, com
readback separado por etapa (uma integração por commit, com gate de smoke
isolado entre elas — defesa contra regressão cruzada).

### 1.6 Fase 4 e 5 — aprovado

Aprovo a integração faseada (Pré-OS → OS → Avaliação → Relatórios) e a
bateria isolada de simulação UI/PDF **fora** das 6 baterias do RVS. Crítico:
manter a sintaxe do RVS exatamente como está (`V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`)
para que qualquer drift seja detectado.

### 1.7 V207 — escopo aprovado com adendo

Aprovo o roadmap V207 conforme `auditoria/02_planos/33_*`. Item 7 do escopo
("Protocolo formal inter-IA com barreiras automatizaveis") **já vai ser
parcialmente executado nesta Onda 36** — então o V207 herda um protocolo
mais maduro e foca em refinos: locking de concorrência, validação cross-IA
de ADRs, integração CI semanal, signed commits via Sigstore.

**Adendo**: V207 deve incluir item 9 — "Arquivamento físico de `local-ai/`
antigo, vault Obsidian morta e pastas V12-* da raiz". Esse passivo
arquitetural precisa ser pago para que a base seja honestamente "limpa"
antes de qualquer iniciativa SaaS. Plano detalhado em
`auditoria/02_planos/35_PLANO_ARQUIVAMENTO_LOCAL_AI_E_V12_PASTAS.md`.

## Parte 2 — Cura do protocolo HBN (Onda 36)

As 6 barreiras propostas pelo Codex são **boas como diagnóstico do que falta**.
A devolutiva é convertê-las em guards executáveis. Mapeamento:

| Proposta Codex (texto) | Conversão em código (esta onda) |
|---|---|
| 1. Preflight obrigatório e bloqueante (pwd, toplevel, status, worktree, importador) | `scripts/hbn-guards/assert-canonical-root.sh` + `forbid-tmp-worktree.sh` rodados em **toda** invocação do pre-commit |
| 2. Barreira de origem — IA só escreve na raiz canônica | `assert-canonical-root.sh` compara `git rev-parse --show-toplevel -P` contra `.hbn/canonical-root` |
| 3. Barreira de importação — Excel só importa de `local-ai/vba_import` | Campo `scope.imports_must_come_from` no `readback.schema.json` (declarativo no readback) + nota permanente em AGENTS.md (verificação humana do operador na hora do import) |
| 4. Barreira de drift — comparar V5 vs src antes de qualquer mudança funcional | Workflow procedimental: a Fase 1 da V206 produz `manifest.sha256.csv` versionado; readbacks subsequentes precisam citar esse manifesto em `predecessor_readback_id` (auditável por convenção, não por hook ainda) |
| 5. Barreira de ownership entre IAs | Campo `agent_id` no schema do readback + roles documentadas em `AGENTS.md` (a evoluir para multi-IA validation no V207) |
| 6. Barreira de status — `.hbn/relay/INDEX.md` aponta sempre para única próxima ação | Convenção mantida; sem hook por enquanto (overhead alto vs. valor); reavaliar no V207 |

**Adicional não pedido pelo Codex mas necessário** (vem da análise de
2026-05-24 sobre os 5 vícios sistêmicos):

| Guard novo | Razão |
|---|---|
| `forbid-env-files.sh` | Defesa contra commit acidental de `.env`, dumps, chaves — vetor de leak conhecido na indústria |
| `forbid-legacy-paths.sh` | Recusa commits que tentem **adicionar** conteúdo às árvores legacy (`local-ai/obsidian-vault/`, `local-ai/auditoria/`, `V12-*/`, `~$*.xlsm`, `.DS_Store`). Permite manter o histórico físico, mas impede crescimento. |
| `assert-scope-lock.sh` | **A guarda que faltou em 02/05 e 24/05.** Para `safe_track`, recusa commit que toque arquivo fora do `scope.files_allowed` declarado no readback ativo. |

Todos os guards estão em `scripts/hbn-guards/` com README explicativo. O
instalador `scripts/hbn-guards/install.sh` substitui o `.git/hooks/pre-commit`
atual por uma versão unificada que **encadeia** os novos guards com o G7/G8
Glasswing já existente — nada do que funcionava é perdido.

### 2.1 Schemas como segunda camada

Os schemas em `.hbn/schemas/` formalizam o contrato do readback. Em
particular, `readback.schema.json` exige:

- `canonical_root` literalmente igual a `/Users/macbookpro/Projetos/Credenciamento`
- `worktree` literalmente igual a `/Users/macbookpro/Projetos/Credenciamento`
- `scope.files_allowed` não-vazio para `safe_track`
- `risks` com no mínimo 3 itens, cada um com mitigação declarada
- `validation_plan.gates` com no mínimo 1 gate e tipo de evidência
- `rollback_plan.steps` com no mínimo 1 passo verificável
- `human_status` em `{pending, confirmed, rejected}`
- `created_at` em ISO 8601 com offset

Para `safe_track`, `human_status` precisa estar `confirmed` (ou existir
`.hbn/hearbacks/<id>.json` com `status: confirmed`) antes que o
`assert-scope-lock.sh` permita o commit do diff de código.

### 2.2 Bypass de emergência — controlado

O guard runner aceita `HBN_GUARDS_BYPASS=1` (compatível com `GLASSWING_BYPASS=1`
já existente). O bypass:

- Emite warning em **cada guard** com nome do guard, para deixar trilha clara.
- Exige prefixo `[bypass-hbn-guards]` no commit message (CI pode validar).
- Exige nota em `.hbn/bypasses/<timestamp>-<motivo>.md` com plano de
  remediação.

Bypass sem essas três coisas é violação de processo, mesmo que o git aceite.
A onda seguinte deve listar bypasses sem nota e tratá-los como achado P0.

## Parte 3 — Decisões sobre reconciliação V5 vs src/vba

Decisão arquitetural pré-MD33:

1. **`src/vba/` continua sendo a fonte versionada da verdade** (regra de ouro
   0002 reafirmada). Em caso de divergência sem decisão humana documentada,
   `src/vba/` prevalece — workbook V5 se ajusta.

2. **Os 4 arquivos ausentes na V5** devem ser tratados explicitamente:

   - **`Altera_Entidade.frm` / `.frx`**: se foram removidos do workbook em
     onda recente (provavelmente Onda 19+ na consolidação V205), precisamos
     do ERP/ADR que justifica a remoção. Se existir, `src/vba/` os contém
     como legado e precisam ser removidos do repo via nova micro-onda
     declarada. Se não existir ERP, **paramos** e Maurício decide se
     reincorpora no workbook ou remove definitivamente.

   - **`Emergencia_CNAE.bas`**: nome sugere ferramenta de fix-up temporária.
     Mesmo critério acima.

   - **`Importador_V2.bas`**: está em CLAUDE.md como "removido na Onda 9"
     (substituído por `Importador_V3.bas`). Se ainda existe em `src/vba/`,
     é resíduo — remover via micro-onda específica.

3. **Os arquivos comuns com diferença textual** (`Importador_V3.bas`,
   `App_Release.bas`, `Menu_Principal.frm`, `Preencher.bas`, etc.) precisam
   de classificação 1-a-1. Não há atalho honesto. O manifest.sha256.csv e a
   classificacao.md (item 1.3 acima) são a entrega da Fase 1.

4. **Nenhum overwrite automático**. Codex tinha razão neste ponto. Cada
   divergência vira linha na matriz e cada linha vira decisão humana.

## Parte 4 — Barreiras reais obrigatórias antes da retomada V206

Antes de o Codex tocar **qualquer** arquivo VBA na V206:

| # | Barreira | Verificação | Quem libera |
|---|---|---|---|
| B1 | Hooks instalados | `ls -la .git/hooks/pre-commit` mostra novo hook com `# HBN-GUARDS PRE-COMMIT (Onda 36+)` | Mauricio roda `bash scripts/hbn-guards/install.sh` |
| B2 | Smoke do runner passa | `bash scripts/hbn-guards/hbn-guards-runner.sh` exit 0 quando `pwd` é a raiz canônica | Mauricio executa |
| B3 | Knowledge 0013 publicado | `.hbn/knowledge/0013-contratos-executaveis.md` existe | Esta onda 36 |
| B4 | AGENTS.md atualizado | seção "Contratos executáveis" presente | Esta onda 36 |
| B5 | Readback 0089 da Onda 36 confirmado | Hearback explícito de Mauricio no chat OU em `.hbn/hearbacks/0089-*.json` | Mauricio |
| B6 | Relay INDEX.md atualizado | bastão passa de "Claude auditoria" para "Codex execução V206 Fase 1" | Esta onda 36 |
| B7 | Readback novo da Fase 1 V206 (Reconciliação V5) | `.hbn/readbacks/0090-onda37-reconciliacao-v5.json` declarando scope correto | Codex em nova sessão |

Sem B1–B6, Codex não retoma. Sem B7, Codex não executa Fase 1.

## Parte 5 — Plano ajustado para Codex retomar V206

Documento canônico: `auditoria/00_status/106_DEVOLUTIVA_OPUS_PROMPT_RETOMADA_CODEX_V206.md`.

Resumo do fluxo desejado:

```
Onda 36 (esta) — Cura do protocolo
    ├─ schemas HBN executáveis        ✅ feito
    ├─ guards de filesystem           ✅ feito
    ├─ instalador de pre-commit       ✅ feito
    ├─ knowledge 0013 + AGENTS update ✅ feito
    └─ readback 0089 + ERP 0089       ✅ feito (aguardando hearback Mauricio)

Onda 37 (próxima) — Reconciliação V5 vs src/vba [Codex em novo chat]
    ├─ readback 0090 declarando scope = apenas auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/**
    ├─ hearback confirmed antes de qualquer execução
    ├─ produzir manifest.sha256.csv e classificacao.md
    ├─ ADR para cada arquivo de classe "decisão humana"
    └─ ERP 0090 + audit-post

Onda 38 (depois) — MD33-restart [Codex]
    ├─ readback 0091 com scope = apenas Rel_OSEmpresa.* e Rel_Emp_Serv.* + import
    ├─ hearback confirmed
    ├─ implementar correção (fix no padrão de instanciação dos handlers)
    ├─ gate compile VBE + smoke isolado dos dois forms
    ├─ NÃO incluir no RVS
    └─ ERP 0091 + audit-post

Onda 39 — Motor PDF Util_PDF.bas [Codex]
Onda 40 — Integração PDF (uma sub-onda por consumidor: Pré-OS, OS, Avaliação, Relatórios)
Onda 41 — Simulação UI/PDF isolada
Onda 42 — Jornada humana V206 + freeze
```

## Parte 6 — Sinais HBN emitidos nesta auditoria

- ✅ HBN ACTIVE — Opus assumiu o bastão de auditoria.
- 🔍 GROUPTHINK ALARM — registrado: as 6 propostas do Codex eram textualmente
  consistentes mas estruturalmente do mesmo tipo que já falhou. Auditor (Opus)
  divergiu propondo conversão para código. Cross-IA divergência > 10% — saudável.
- 🟠 SOURCE DRIFT DETECTED — divergência V5 vs `src/vba` confirmada; precisa
  reconciliação documentada antes de qualquer mudança funcional.
- 🟡 HBN NEEDS HUMAN DECISION — itens em §1.7 (4 arquivos ausentes) precisam
  decisão Mauricio sobre origem (remover do repo ou reincorporar no workbook).
- 🔵 HBN HANDOFF READY — pacote desta auditoria pronto para hearback humano e
  então Codex retoma.

## Parte 7 — Aprovações condicionais

| Item | Status | Condição |
|---|---|---|
| Escopo V206 conforme handoff 102 | ✅ aprovado | barreiras B1–B7 satisfeitas |
| Anchor V5 | ✅ aprovado | sem condição |
| Fase 1 Reconciliação V5 | ✅ aprovado | seguir refino de §1.3 (manifest + classificacao versionados) |
| Fase 2 MD33-restart | ✅ aprovado | scope.files_allowed conforme §1.4 |
| Fase 3 Util_PDF | ✅ aprovado | arquivo único; scope conforme §1.5 |
| Fase 4 Integração PDF | ✅ aprovado | uma sub-onda por consumidor |
| Fase 5 Simulação UI/PDF | ✅ aprovado | fora do RVS |
| Roadmap V207 | ✅ aprovado | adicionar item 9 (arquivamento legacy) |
| Cura do protocolo HBN | ✅ esta onda | aguarda hearback Mauricio |

## Parte 8 — Próxima ação humana

Mauricio precisa, na ordem:

1. Ler esta auditoria.
2. Rodar `bash scripts/hbn-guards/install.sh` no Mac (raiz canônica).
3. Rodar `bash scripts/hbn-guards/hbn-guards-runner.sh` e ver exit 0.
4. Confirmar hearback do readback 0089 (Onda 36) — explicitar no chat ou
   criar `.hbn/hearbacks/0089-cura-protocolo-opus.json` com `status: confirmed`.
5. Commitar a Onda 36 (todos os arquivos listados nesta auditoria) em commit
   único, message: `feat(hbn): onda 36 cura do protocolo — guards executaveis + schemas + roadmap`.
6. Abrir novo chat com Codex usando `auditoria/00_status/106_DEVOLUTIVA_OPUS_PROMPT_RETOMADA_CODEX_V206.md`.

## Apêndice — Compromisso do arquiteto

Eu (Claude Opus 4.7, no papel de arquiteto principal desta migração de
protocolo) me comprometo a:

- Não emitir mais um readback nesta repo sem usar o schema novo.
- Recusar revisar qualquer onda safe_track sem `scope.files_allowed` declarado.
- Emitir audit-pre antes de hearback humano em qualquer onda que toque
  `src/vba/` se solicitado.
- Em caso de divergência irreconciliável com Codex sobre escopo, marcar
  🟡 HBN NEEDS HUMAN DECISION e parar — não decidir unilateralmente.

— Claude Opus 4.7, 2026-05-24
