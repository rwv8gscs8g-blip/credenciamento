---
titulo: 46 - Prompt unificado Codex - implementacao das 5 decisoes tecnologicas + arquitetura multi-braco
tipo: prompt-de-execucao
audiencia: ia (Codex CLI)
data: 2026-05-09
licenca-target: TPGL v1.1 (este prompt); artefatos finais em AGPLv3
autor: Claude Opus 4.7 (Frente 2) com base em aprovacao Mauricio 2026-05-09
predecessor: 41_DECISOES_5_TECNOLOGIAS_EM_CURSO.md, 42_ROADMAP_CONSENT_CAPSULES_RUST.md, 43_PLANO_DOCUMENTACAO_V2_USEHBN.md, 44_CORRECAO_USEHBN_E_CONSOLIDACAO.md, 45_TRANSCRICAO_SESSAO_2026-05-06.md
status: pronto para submissao a Codex CLI
escopo: consolida 5 decisoes tecnologicas + arquitetura multi-braco em batch executavel pelo Codex
---

# 46 — Prompt Unificado Codex

## Como usar

Mauricio submete o conteudo deste arquivo ao Codex CLI (instrucoes de
acesso na secao "Como acessar o Codex via terminal Antigravity" no
final). Codex consome o prompt e devolve outputs em batch:

- ERPs (Execution Result Packages) em `local-ai/Time_AI/codex-erps/`
  com hashes e gates declarados
- Codigo em `~/Projetos/usehbn-phago/`, `~/Projetos/usehbn-capsules/`,
  ou outros repositorios conforme indicado por modulo
- Capsulas de auditoria em `usehbn/audits/responses/`

Opus consome os ERPs e:
1. Audita aderencia a spec (cross-audit Antigravity opcional para
   pontos criticos)
2. Integra outputs em capitulos da V2 do useHBN
3. Sinaliza handoff de volta a Mauricio para decisao final

---

## TEXTO DO PROMPT (cole no Codex CLI apos abrir sessao)

```text
Codex, peco execucao em batch das 5 decisoes tecnologicas e da
infraestrutura multi-braco do useHBN consolidadas em 2026-05-06 e
2026-05-09. Voce e o executor canonico de tarefas estruturais. Opus e
arquiteto/validador. Mauricio (operador) decide.

CONTEXTO RAPIDO

useHBN e protocolo aberto multi-braco para coordenacao humano-IA.
Composicao canonica:

- 13 principios (10 constitucionais P1-P10 + 3 operacionais P11-P13)
  formalizados em usehbn/methodology/PRINCIPIOS-CONSTITUCIONAIS.md
- Modelo das 3 Arvores (Estavel/Desenvolvimento/Exploracao) em
  usehbn/methodology/THREE-TREES-ARCHITECTURE.md
- Rust como linguagem-base do substrato
- 6 modulos paralelos + Radar transversal documentados em
  usehbn/modules/{RADAR,FAGOCITOSE,CAPSULAS-DE-CONSENTIMENTO,
  COORDENACAO-INTER-IA,SEGURANCA,MARCADORES,AUDITORIA-CRUZADA}.md
- Arquitetura multi-braco em usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md
- 21 marcadores canonicos em .hbn/knowledge/0005-protocolo-markers-v2.md

DECISOES JA FECHADAS (NAO REVISITAR — IMPLEMENTAR)

| Tecnologia | Decisao | Fonte |
|---|---|---|
| Tree-sitter | APROVADA — fagocitose F1 em curso; POC parsing VBA | 41 + ficha tree-sitter.md |
| Typer | ARQUIVADA — fere P11 Minimalismo de Cadeia; usar Click puro ou argparse se CLI necessaria | 41 + ficha typer.md |
| uv | ARQUIVADA — fere P12 Substrato Solido (decisao Rust direto); usar pip + venv padrao no curto prazo | 41 + ficha uv.md |
| OpenTelemetry | APROVADA — observabilidade do pipeline de fagocitose; roadmap O-A→O-E pendente | 41 + ficha opentelemetry.md |
| Consent Capsules | APROVADA — primeiro projeto demonstrador 3 Arvores; roadmap R-A→R-E completo | 42 |

ESTEIRAS A EXECUTAR (em ordem proposta — Mauricio pode reordenar)

ESTEIRA 1 — Consent Capsules R-A (POC Python)

Objetivo: implementar POC manual em Python que produz uma capsula
real (L18 do Credenciamento) end-to-end.

Spec:
- Diretorio target: ~/Projetos/usehbn-capsules/poc/
- pyproject.toml com deps minimas: pydantic ≥2.0, click (NAO typer),
  cryptography (Ed25519), hashlib (stdlib)
- Schemas Pydantic para os 6 arquivos canonicos da capsula:
  lesson.md (Markdown — apenas validar metadata frontmatter),
  evidence.json, redaction-map.json, consent.json,
  license-target.txt, hashes.json
- Spec dos schemas em 42_ROADMAP_CONSENT_CAPSULES_RUST.md
- POC manual: gerar capsula L18 do Credenciamento
  (auditoria/03_ondas/onda_*/L18_*.md ou equivalente — verificar path
  exato com `find . -iname "*L18*"` antes de comecar)

Gates de fechamento:
- Capsula L18 valida em todos os 6 schemas (validador Python verde)
- consent.json com Mauricio nomeado como autorizador
- license-target.txt = "AGPLv3"
- hashes.json bate (SHA-256 de cada arquivo)
- Suite pytest minima (≥5 testes verdes)
- Um README.md curto explicando como rodar o POC

Output esperado: ERP em local-ai/Time_AI/codex-erps/<data>-consent-capsules-RA.json
+ codigo em ~/Projetos/usehbn-capsules/poc/.

Marker durante execucao: 🌱 HBN EXPLORATION SEED.
Marker apos gates verdes: 🟫 HBN TREE TRANSITION (pronto para R-B).

ESTEIRA 2 — Tree-sitter F1 (estudo profundo + plano de POC)

Objetivo: completar F1 (estudo) preparando POC F2 de parsing de
arquivo VBA real (Const_Colunas.bas).

Spec:
- Diretorio target: ~/Projetos/usehbn-phago/modules/tree-sitter/
- docs/01-fundamentos.md (LR/GLR parsers; gramaticas BNF/EBNF;
  bibliografia ≥5 fontes oficiais)
- docs/02-relacao-principios-hbn.md (analise individual dos 13
  principios — sim/parcial/nao com justificativa)
- docs/03-design-poc.md (plano de POC: extrair regras de negocio de
  Const_Colunas.bas via gramatica eirikpre/tree-sitter-vba)
- ADR-001 documentando decisao de design (gramatica vba escolhida,
  alternativas avaliadas)
- ficha-snapshot.md = copia da ficha do radar
  (usehbn/radar/_per-technology/tree-sitter.md) no momento de F1

Gates de fechamento de F1:
- 5 fontes oficiais documentadas
- Mauricio confirma "estudei o suficiente, ok prosseguir para F2"

Output esperado: ERP + estrutura de pastas pronta para F2.

Marker durante execucao: 🌱 HBN EXPLORATION SEED.

ESTEIRA 3 — OpenTelemetry detalhamento (O-A→O-E)

Objetivo: produzir roadmap em 5 fases analogas ao Consent Capsules
(R-A→R-E), espelhando o padrao.

Spec:
- Diretorio target: pode comecar como documento solo em
  auditoria/00_status/47_ROADMAP_OPENTELEMETRY_RUST.md (numeracao
  pos-46 deste prompt unificado)
- O-A: Spec + POC Python (instrumentar 1 ciclo HBN com OTLP-JSON
  local em local-ai/traces/)
- O-B: Traducao Rust 1:1 (cadeia minima: tracing-rs ou opentelemetry-rust)
- O-C: Refinamentos idiomaticos
- O-D: Promocao a Arvore Estavel
- O-E: Documentacao V2 (capitulos relevantes)
- Cadeia minima de deps Rust documentada (compativel P11 Minimalismo)

Gates de fechamento O-A:
- Trace OTLP-JSON valido gerado por POC
- 1 ciclo HBN completo capturado em span "ciclo:onda-X"
- Backend OTLP local funcional (sem dependencia de servico cloud)
- Documentacao em docs/01-02

Output esperado: documento 47 + ERP.

Marker durante execucao: 🌱 HBN EXPLORATION SEED.

ESTEIRA 4 — Typer/uv arquivamento formal

Objetivo: registrar formalmente o arquivamento das 2 tecnologias com
notas de alternativas.

Spec:
- Atualizar usehbn/radar/_per-technology/typer.md confirmando estado
  `archived` 2026-05-06 (apenas verificar consistencia; ficha ja foi
  atualizada por Opus)
- Atualizar usehbn/radar/_per-technology/uv.md idem
- Adicionar nota em ambas as fichas: "alternativas atuais para esta
  necessidade" (Click puro / argparse para Typer; pip+venv para uv)
- Atualizar usehbn/radar/REGISTRY.md confirmando estado `archived`
- Cross-link com P11 (Minimalismo) e P12 (Substrato Solido)

Gates de fechamento:
- Fichas com estado correto e nota de alternativas
- REGISTRY consistente
- Sem regressao em outras fichas que referenciavam Typer/uv

Output esperado: ERP curto (apenas verificacao de consistencia).

Marker: ⚪ HBN AUDIT-ONLY (Codex sem bastao executor; so registra).

ESTEIRA 5 — Sincronizacao usehbn-phago skeleton

Objetivo: criar/sincronizar a estrutura de modulos no repo
~/Projetos/usehbn-phago/ refletindo a arquitetura multi-braco.

Spec:
- Estrutura: usehbn-phago/modules/{tree-sitter,opentelemetry,
  consent-capsules,...}/{docs,poc,tests,capsules,ADR}
- README.md no root explicando o repo + link para
  https://github.com/<user>/usehbn (repo-mae)
- pyproject.toml minimo (workspace com membros = modulos)
- .gitignore Python padrao + Rust quando aplicavel

Gates:
- Estrutura criada com pastas vazias mas .gitkeep para preservar
- README explicativo no root
- Link bidirecional com usehbn (mae)

Output esperado: ERP + estrutura pronta para receber outputs das
esteiras 1-3.

Marker: 🌳 HBN MODULE BOUNDARY (estreia operacional dos modulos).

HARD CONSTRAINTS (NAO VIOLAR)

1. Regra M11 — fonte de verdade vs espelho: src/vba/ e fonte;
   local-ai/vba_import/ e espelho. NUNCA o inverso.
2. Glasswing G1-G8 — todos os 8 vetores rodam antes de fechamento de
   onda; readback declara estado de cada um.
3. CONSTRAINT 4 — useHBN NAO e fagocitose. Fagocitose e UM modulo
   entre 6. Em qualquer documento que voce escrever, posicione o
   useHBN como protocolo multi-braco.
4. Append-only em compartilhados — .hbn/relay/INDEX.md, marcadores
   canonicos, principios constitucionais sao append-only via
   addendum.
5. Citacoes operacionais de Mauricio em blockquote `>` integral —
   nunca parafrasear.
6. Pull antes de write — antes de qualquer escrita estrutural,
   releitura de .hbn/relay/INDEX.md e mensagens novas em
   .hbn/messages/.
7. Operador e tiebreaker — em qualquer conflito, deposite mensagem
   em .hbn/messages/de-codex_para-frente2_<data>.md e aguarde
   sinalizacao de Mauricio.

CRONOGRAMA SUGERIDO (Mauricio pode reordenar)

| Esteira | Duracao estimada | Pre-req |
|---|---|---|
| 5 (skeleton) | 1 dia | nenhum — pode comecar ja |
| 4 (Typer/uv archive formal) | 1-2 dias | nenhum |
| 1 (Consent Capsules R-A) | 1-2 semanas | esteira 5 (skeleton) |
| 2 (Tree-sitter F1) | 1 semana (estudo) | esteira 5 (skeleton) |
| 3 (OpenTelemetry detalhamento) | 1 semana | nenhum (paralelo) |

PONTOS DE VALIDACAO POR ESTEIRA

Cada esteira fechada gera ERP em **/Users/macbookpro/Projetos/usehbn/local-ai/Time_AI/codex-erps/<data>-<esteira>.json**
(path absoluto canonico — repo mae do useHBN, NAO o Credenciamento que
e Frente 1). Convencao confirmada na auditoria da Esteira 5.

Coordenacao inter-IA do useHBN multi-braco usa **/Users/macbookpro/Projetos/usehbn/.hbn/**
como hub canonico. Se .hbn/messages/ ou outras pastas nao existirem
ainda, criar com .gitkeep ao iniciar a primeira esteira que delas
precisar.

Estrutura completa do ERP:

```json
{
  "esteira": "<id>",
  "status": "ok | parcial | bloqueado",
  "artefatos": [
    {"path": "...", "sha256": "..."}
  ],
  "gates": {
    "<gate_id>": "ok | violado | nao_aplicavel"
  },
  "glasswing_checks": {
    "G1": "ok | violado | nao_aplicavel",
    "...": "..."
  },
  "marker_atual": "🌱 HBN EXPLORATION SEED",
  "marker_proposto_pos_aprovacao": "🟫 HBN TREE TRANSITION",
  "decision_needed": "yes | no",
  "questao_para_mauricio": "..."
}
```

Opus consome o ERP, audita, sinaliza:
- 🤝 HBN CROSS-AUDIT APPROVED se consistente com spec
- ⚖️ HBN CROSS-AUDIT ITERATION se divergencia substantiva
- 🟡 HBN NEEDS HUMAN DECISION se ponto de risco humano detectado

OUTPUT ESPERADO POR ESTEIRA

- Codigo + docs + tests no diretorio target da esteira
- ERP estruturado em local-ai/Time_AI/codex-erps/
- Mensagem em .hbn/messages/ se houve duvida ou conflito
- Marker 🔵 HBN HANDOFF READY no final declarando pronto para Opus
  auditar

TOM REQUERIDO

Direto, operacional, sem narrativa de processo. Tom de spec
executavel, nao de blog post.

Em codigo: comentarios apenas onde o "porque" e nao-obvio. Sem
explicacao de "o que" — nomes ja explicam.

Em README e docs: declarativo. Sem auto-elogio. Sem linguagem de
marketing.

PERGUNTA PARA MAURICIO ANTES DE COMECAR (opcional)

Se voce tem ambiguidade em qualquer ponto deste prompt, deposite
mensagem em .hbn/messages/<data>_<NN>_de-codex_para-frente2.md
ANTES de iniciar a primeira esteira.

REFERENCIAS

- Documentos canonicos:
  - usehbn/methodology/PRINCIPIOS-CONSTITUCIONAIS.md (13 principios)
  - usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md (arquitetura multi-braco)
  - usehbn/methodology/THREE-TREES-ARCHITECTURE.md (3 arvores)
  - usehbn/modules/ (7 fichas: 6 modulos + Radar)
  - .hbn/knowledge/0005-protocolo-markers-v2.md (21 marcadores)
  - .hbn/knowledge/0003-glasswing-style-preventive-security.md (G1-G8)

- Roadmaps detalhados:
  - auditoria/00_status/41_DECISOES_5_TECNOLOGIAS_EM_CURSO.md (decisoes 5 tech)
  - auditoria/00_status/42_ROADMAP_CONSENT_CAPSULES_RUST.md (R-A→R-E detalhado)
  - auditoria/00_status/43_PLANO_DOCUMENTACAO_V2_USEHBN.md (V2 plan refatorado)
  - auditoria/00_status/44_CORRECAO_USEHBN_E_CONSOLIDACAO.md (correcao multi-braco)

- Fichas das 5 tecnologias:
  - usehbn/radar/_per-technology/{tree-sitter,typer,uv,opentelemetry,consent-capsules,rust}.md

Aguardando sua confirmacao de recepcao do prompt e bastao para
iniciar Esteira 5 (skeleton).
```

---

## Como acessar o Codex via terminal Antigravity

### Pre-requisitos

1. **Antigravity esta aberto** com o repositorio do Credenciamento
   (`/Users/macbookpro/Projetos/Credenciamento`) como workspace.
2. **Terminal integrado do Antigravity esta disponivel** —
   geralmente acessivel via:
   - Atalho `Ctrl+`` (backtick) no Mac/Linux equivalente
   - Menu "Terminal" → "New Terminal"
   - Painel inferior do IDE
3. **Codex CLI esta instalado localmente**. Se nao estiver:
   ```bash
   # via npm (recomendado pelo OpenAI)
   npm install -g @openai/codex

   # alternativa via brew
   brew install openai-codex
   ```
4. **Variavel de ambiente OPENAI_API_KEY** esta exportada no shell
   (zsh, conforme o sistema atual):
   ```bash
   echo $OPENAI_API_KEY  # deve retornar a chave (nao copie em chat)
   ```
   Se vazio, configurar em `~/.zshrc`:
   ```bash
   export OPENAI_API_KEY="sk-..."
   ```
   ou autenticar interativamente:
   ```bash
   codex auth login
   ```

### Passo a passo

**Passo 1 — Abrir terminal no Antigravity**

No Antigravity (Google AI dev environment), abrir o painel de
terminal integrado. O terminal abre na raiz do workspace
(`/Users/macbookpro/Projetos/Credenciamento`).

**Passo 2 — Verificar Codex disponivel**

```bash
codex --version
```

Esperado: numero de versao. Se erro `command not found`, retornar
ao item 3 dos pre-requisitos.

**Passo 3 — Submeter o prompt unificado**

Tres formas, em ordem de robustez:

**(a) Sessao interativa com prompt como input** (recomendado para
prompts longos como este):
```bash
codex
```
Codex abre prompt interativo. Cole o conteudo do bloco `text` deste
documento (linhas 28-202 acima — desde "Codex, peco execucao..." ate
"Aguardando sua confirmacao..."). Pressione Enter duplo para
submeter.

**(b) Pipe via stdin** (util para automacao):
```bash
sed -n '/```text$/,/^```$/p' auditoria/00_status/46_PROMPT_UNIFICADO_CODEX.md \
  | sed '1d;$d' | codex
```

**(c) Argumento direto** (so funciona para prompts curtos; este
provavelmente excede limite de argumentos):
```bash
codex "$(cat <<'EOF'
... cole conteudo aqui ...
EOF
)"
```

**Passo 4 — Acompanhar execucao**

Codex executa em modo agentic — ele le arquivos do repo, escreve
artefatos, roda comandos, e devolve ERP estruturado. Output aparece
no terminal em tempo real. Esperado:

- Confirmacao de recepcao do prompt
- Pergunta de bastao (Codex pode confirmar antes de comecar)
- Inicio da Esteira 5 (skeleton) com escrita de pastas e arquivos
- ERP final em `local-ai/Time_AI/codex-erps/<data>-esteira-5.json`

**Passo 5 — Validar ERP**

Apos Codex sinalizar `🔵 HBN HANDOFF READY`, voltar para a sessao
Opus (Claude/Antigravity) e pedir auditoria do ERP:

```text
Opus, audite o ERP <path do arquivo> da Esteira 5.
```

Opus le o ERP, verifica gates e marcadores, e devolve veredito
🤝/⚖️/🟡 conforme protocolo.

### Modo alternativo — sem Codex CLI local

Se o Codex CLI nao estiver instalado nem for instalavel, alternativas:

1. **Web Codex** (ChatGPT Plus/Pro) — copiar o bloco `text` do
   prompt unificado para a interface web do Codex. Output volta no
   chat; Mauricio copia ERP para `local-ai/Time_AI/codex-erps/`
   manualmente.

2. **API direta** — via `curl` ao endpoint OpenAI:
   ```bash
   curl https://api.openai.com/v1/responses \
     -H "Authorization: Bearer $OPENAI_API_KEY" \
     -H "Content-Type: application/json" \
     -d @prompt-payload.json
   ```
   (gerar `prompt-payload.json` a partir do bloco `text`)

3. **Outra IA executora** (Antigravity Claude Code, etc.) — qualquer
   IA com acesso ao filesystem do repositorio pode receber este
   mesmo prompt. O texto do prompt e ferramenta-agnostico (P8 — o
   protocolo importa mais que a ferramenta).

### Marcadores durante a execucao

| Estado | Marker | Significado |
|---|---|---|
| Codex recebeu prompt mas ainda nao confirmou | ⚪ HBN AUDIT-ONLY | aguardando confirmacao |
| Codex aceita bastao e inicia primeira esteira | ✅ HBN ACTIVE + 🌱 HBN EXPLORATION SEED | esteira em curso |
| Codex completa esteira com gates verdes | 🟢 HBN CHECKPOINT CLEAN + 🔵 HBN HANDOFF READY | pronto para audit Opus |
| Opus audita e aprova | 🤝 HBN CROSS-AUDIT APPROVED | esteira fechada |
| Divergencia detectada na auditoria | ⚖️ HBN CROSS-AUDIT ITERATION | nova rodada |
| Decisao humana necessaria | 🟡 HBN NEEDS HUMAN DECISION | aguardando Mauricio |

### Em caso de bloqueio

Se Codex ficar travado (sem output por > 5 minutos sem indicacao de
processamento), abortar com `Ctrl+C` e investigar:

1. Verificar `OPENAI_API_KEY` valida e com creditos
2. Verificar conexao internet
3. Verificar se o repo tem `.gitignore` ou permissions impedindo
   leitura de arquivos canonicos
4. Reduzir prompt para uma esteira por vez (esteira 5 isolada
   primeiro)

## Versao

- v1.0 — 2026-05-09 — primeira versao do prompt unificado, escrita
  apos aprovacao Mauricio das decisoes pendentes do plano V2 e
  refator multi-braco da Tarefa 5. Pre-requisitos satisfeitos:
  PRINCIPIOS-CONSTITUCIONAIS.md criado nesta mesma sessao.

## Status (2026-05-09 pos-Esteira 5)

🔍 **HBN CROSS-AUDIT IN PROGRESS** sobre 3 questoes arquiteturais
levantadas por Mauricio apos auditoria da Esteira 5:

1. **Mono-repo vs poly-repo** — Mauricio sinalizou preferencia por
   `usehbn` como github canonico unico, com bracos como subpastas. A
   arquitetura declarada em `USEHBN-MODULES-ARCHITECTURE.md` previa
   repos separados (`usehbn-phago`, `usehbn-capsules`, etc.). A
   Esteira 5 ja criou `~/Projetos/usehbn-phago/` como repo separado.
2. **Modulo vs aplicacao** — Credenciamento e modulo do useHBN ou
   aplicacao que usa o protocolo? Confusao identificada por Mauricio.
3. **Simplificacao da documentacao** — eliminar/atualizar documentos
   obsoletos.

**Esteiras 1-4 deste prompt em HOLD** ate cross-audit Codex +
Antigravity fechar e sintese Opus apresentar proposta+roadmap. Esteira
5 ja entregue permanece valida como base — pode ser migrada de
`~/Projetos/usehbn-phago/` para `~/Projetos/usehbn/modules/` se
arquitetura mono-repo for confirmada.

Artefatos da auditoria arquitetural:

- `usehbn/audits/AUDITORIA-ARQUITETURAL-2026-05-09.md` (estado atual)
- `usehbn/audits/PROMPT-CROSS-AUDIT-CODEX-ARQ-2026-05-09.md`
- `usehbn/audits/PROMPT-CROSS-AUDIT-ANTIGRAVITY-ARQ-2026-05-09.md`
