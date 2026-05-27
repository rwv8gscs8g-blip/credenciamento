# AGENTS.md — entrada canônica para IAs

> Este arquivo segue o padrão [agents.md](https://agents.md/) e é a
> entrada **obrigatoria** para qualquer IA que va trabalhar neste
> repositorio (Claude Code, Claude Cowork, Claude API, Codex, Cursor,
> Copilot, Gemini, ou qualquer outra). Outros arquivos de instrucao
> historicamente especificos (`CLAUDE.md`, `.codex/`, `.cursorrules`)
> apontam para este como fonte unica.

## Identidade do projeto

| Campo | Valor |
|---|---|
| Nome | Sistema de Credenciamento e Rodízio de Pequenos Reparos |
| Linguagem principal | VBA (Excel `.xlsm`) |
| Versão oficial vigente | V12.0.0205 |
| Próxima linha planejada | V12.0.0206 |
| Build importado no workbook validado | `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix` |
| Branch V206 ativa | `codex/v12-0-0206-planejamento` |
| Raiz canônica local | `/Users/macbookpro/Projetos/Credenciamento` |
| Licença | TPGL v1.1 (auto-conversão para Apache 2.0 em 4 anos) |
| Protocolo de governança | [HBN — Human Brain Net](https://usehbn.org) |

## Raiz canônica obrigatória

Toda IA deve escrever artefatos do projeto somente em
`/Users/macbookpro/Projetos/Credenciamento`. Isso inclui codigo, auditoria,
HBN, evidencias, pacotes de importacao, backups operacionais e documentos de
handoff. `/private/tmp`, downloads, areas de IDE e outros worktrees podem ser
usados apenas como rascunho descartavel; nenhum entregavel pode permanecer
nesses locais.

> **Onda 36 (2026-05-24) — agora isto é enforçado por código.**
> O pre-commit instalado por `scripts/hbn-guards/install.sh` recusa
> mecanicamente qualquer commit cuja `git rev-parse --show-toplevel` seja
> diferente de `.hbn/canonical-root`, ou que tenha worktree em `/tmp`,
> `/private/tmp`, `Downloads/` ou `.Trash/`. Detalhes em
> [`.hbn/knowledge/0013-contratos-executaveis.md`](.hbn/knowledge/0013-contratos-executaveis.md)
> e em [`auditoria/00_status/105_AUDITORIA_HANDOFF_V206_V207_USEHBN_CLAUDE_OPUS.md`](auditoria/00_status/105_AUDITORIA_HANDOFF_V206_V207_USEHBN_CLAUDE_OPUS.md).

## Contratos executáveis (Onda 36 — 2026-05-24)

A partir do readback `0089-onda36-cura-protocolo-opus`, o protocolo HBN
neste repositório tem **camada executável**. Os readbacks têm schema JSON
formal (`.hbn/schemas/readback.schema.json`) e o pre-commit valida:

| Guard | O que rejeita |
|---|---|
| `scripts/hbn-guards/assert-canonical-root.sh` | git toplevel ≠ raiz canônica |
| `scripts/hbn-guards/forbid-tmp-worktree.sh` | worktree em /tmp, Downloads, .Trash |
| `scripts/hbn-guards/forbid-env-files.sh` | `.env*`, dumps, chaves privadas |
| `scripts/hbn-guards/forbid-legacy-paths.sh` | adicionar conteúdo a `local-ai/obsidian-vault/`, `V12-*/`, etc. (lista em `.hbn/forbidden-paths.txt`) |
| `scripts/hbn-guards/assert-scope-lock.sh` | em safe_track: arquivos staged fora do `scope.files_allowed` do readback ativo OU hearback ainda `pending` |

Toda nova onda safe_track deve:

1. Produzir readback em `.hbn/readbacks/NNNN-*.json` conforme schema.
2. Aguardar hearback humano (`human_status: confirmed` no readback ou
   `.hbn/hearbacks/NNNN.json` com `status: confirmed`).
3. Limitar diff git aos paths declarados em `scope.files_allowed`.
4. Produzir ERP em `.hbn/results/NNNN-exec-*.json` ao fechar.

Detalhes operacionais: [`scripts/hbn-guards/README.md`](scripts/hbn-guards/README.md).
Razão arquitetural: [`.hbn/knowledge/0013-contratos-executaveis.md`](.hbn/knowledge/0013-contratos-executaveis.md).
Roadmap de institucionalização: [`auditoria/02_planos/34_ROADMAP_PROTOCOLO_90_DIAS_OPUS.md`](auditoria/02_planos/34_ROADMAP_PROTOCOLO_90_DIAS_OPUS.md).

Bypass de emergência (deixa rastro):
```bash
HBN_GUARDS_BYPASS=1 git commit -m "[bypass-hbn-guards] motivo: …"
```
+ nota em `.hbn/bypasses/AAAAMMDD-HHmmss-<motivo>.md`.

Antes de ler ou editar arquivos, execute e valide:

```bash
pwd
git rev-parse --show-toplevel
git status --short --branch
git worktree list
```

O valor de `pwd` e de `git rev-parse --show-toplevel` deve ser exatamente
`/Users/macbookpro/Projetos/Credenciamento`. Se qualquer comando apontar para
`/private/tmp` ou outra raiz, a IA deve parar, registrar P0 em HBN e pedir
hearback humano. Readbacks e ERPs devem registrar a raiz canônica; um readback
com `worktree` fora dela e invalido para nova execucao.

Quando a tarefa envolver importacao no workbook, conferir tambem no VBE:

```vb
?ThisWorkbook.Path
ImportarPacoteV3_Status
```

O caminho esperado do workbook e `\\Mac\Home\Projetos\Credenciamento`. O
manifesto importavel deve existir em
`\\Mac\Home\Projetos\Credenciamento\local-ai\vba_import\`.

## Antes de tocar qualquer coisa

Leia, em ordem:

1. [`.hbn/relay/INDEX.md`](.hbn/relay/INDEX.md) — quem tem o bastao agora
2. [`.hbn/knowledge/0001-regras-v203-inegociaveis.md`](.hbn/knowledge/0001-regras-v203-inegociaveis.md) — regras operacionais históricas ainda aplicáveis
3. [`.hbn/knowledge/0002-regra-ouro-vba-import.md`](.hbn/knowledge/0002-regra-ouro-vba-import.md) — como espelhar código
4. [`.hbn/knowledge/0003-glasswing-style-preventive-security.md`](.hbn/knowledge/0003-glasswing-style-preventive-security.md) — camada de segurança preventiva
5. [`.hbn/knowledge/0010-funcionalidade-nova-exige-teste.md`](.hbn/knowledge/0010-funcionalidade-nova-exige-teste.md) — regra permanente: funcionalidade nova exige teste correspondente
6. [`.hbn/knowledge/0011-higiene-documental-recorrente.md`](.hbn/knowledge/0011-higiene-documental-recorrente.md) — regra permanente: higiene documental antes de passar de fase
7. [`.hbn/knowledge/0012-raiz-canonica-projeto.md`](.hbn/knowledge/0012-raiz-canonica-projeto.md) — regra permanente de raiz canônica
8. [`.hbn/knowledge/0013-contratos-executaveis.md`](.hbn/knowledge/0013-contratos-executaveis.md) — **regra permanente de contratos executáveis (Onda 36)**
9. [`.hbn/knowledge/0014-protocolo-fim-de-sessao.md`](.hbn/knowledge/0014-protocolo-fim-de-sessao.md) — **regra permanente de handoff a 50% de contexto ou transferência de bastão (Onda 36.1)**
9b. [`.hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md`](.hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md) — **regra permanente de passagem de bastão entre IAs: papéis, auditoria em chat novo, severidade BLOQUEADOR/FORTE/MARGINAL + veto, checklist anti-viés (§12 do PROMPT_ARQUITETO, onda 0112)**
10. [`auditoria/00_status/105_AUDITORIA_HANDOFF_V206_V207_USEHBN_CLAUDE_OPUS.md`](auditoria/00_status/105_AUDITORIA_HANDOFF_V206_V207_USEHBN_CLAUDE_OPUS.md) — **auditoria-mãe do protocolo curado (Opus 2026-05-24)**
10. [`scripts/hbn-guards/README.md`](scripts/hbn-guards/README.md) — guards executáveis no pre-commit
11. [`.hbn/schemas/README.md`](.hbn/schemas/README.md) — schemas JSON dos artefatos HBN
12. [`obsidian-vault/releases/V12.0.0205.md`](obsidian-vault/releases/V12.0.0205.md) — release oficial vigente
13. [`docs/reference/regras/REGRAS_DE_NEGOCIO_V205.md`](docs/reference/regras/REGRAS_DE_NEGOCIO_V205.md) — regras de negócio públicas V205
14. [`docs/tutorials/JORNADA_VALIDACAO_HUMANA_V205.md`](docs/tutorials/JORNADA_VALIDACAO_HUMANA_V205.md) — guia humano por interface
15. [`auditoria/evidencias/V12.0.0205/INDEX.md`](auditoria/evidencias/V12.0.0205/INDEX.md) — evidências públicas V205
16. [`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`](usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md) — lições históricas sobre VBA

## Working pattern

Toda IA executora trabalha em **ondas curtas** (`onda 1`, `onda 2`, ...).
Cada onda:

1. Comeca com **readback** explicito em `.hbn/readbacks/00NN-ondaNN.json`.
2. So procede com **hearback confirmado** pelo Mauricio (status:
   `confirmed`).
3. Termina com **ERP** em `.hbn/results/00NN-exec-ondaNN.json`.
4. Documenta UM unico documento tecnico em
   `auditoria/03_ondas/onda_NN_<tema>/<numero>_TECNICO.md`.

## Quem tem o bastao agora

Veja `.hbn/relay/INDEX.md`. Em 2026-05-23, a V12.0.0205 está congelada como
linha oficial validada. Novas IAs devem tratar a V12.0.0206 como próxima linha
incremental e operar em modo auditoria/proposta até novo bastão explícito.

## Build steps

Este projeto **nao** tem build automatizado em CI. A "build" e a
importacao manual no Excel VBA Editor (VBE) seguindo
`local-ai/vba_import/000-REGRA-OURO.md`. Cada onda entrega:

1. Codigo em `src/vba/` (fonte de verdade).
2. Espelho em `local-ai/vba_import/` com prefixos.
3. `auditoria/03_ondas/onda_NN_<tema>/<NN+1>_PROCEDIMENTO_IMPORT.md`
   listando ordem exata.
4. Atualizacao de `App_Release.bas` (build novo).
5. Atualizacao de `CHANGELOG.md`.

## Test patterns

| Suite | Local | Comando | Tempo aproximado |
|---|---|---|---|
| V1 rapida | `Teste_Bateria_Oficial.bas` | macro `BO_RodarBateriaOficial` | ~2 min |
| V2 Smoke | `Teste_V2_Engine.bas` | macro `TV2_RunSmoke` | ~30 s |
| V2 Canonica | `Teste_V2_Engine.bas` | macro `TV2_RunCanonica` | ~10 min |
| Gate RVS V205 | `Teste_Validacao_Release.bas` | botão **Central de Testes** > **Gate de Validação de Release (RVS)** | ~12 min |

A IA nunca executa esses testes diretamente — ela entrega o pacote
pronto para o operador rodar no workbook.

Regra permanente: toda funcionalidade nova, regra de negocio nova,
fluxo novo de UI ou comportamento novo de servico deve ser entregue com
teste correspondente no mesmo microdelta. Preferir teste automatizado
em V1/V2; quando nao for tecnicamente automatizavel, registrar teste
assistido/manual auditavel em catalogo, roteiro e procedimento de gate.
Detalhe canonico: [`.hbn/knowledge/0010-funcionalidade-nova-exige-teste.md`](.hbn/knowledge/0010-funcionalidade-nova-exige-teste.md).

Antes de passar de microdelta, onda, release ou bastao, aplicar higiene
documental recorrente: relay, readback/ERP, CHANGELOG, evidencias,
roadmap e proxima acao precisam refletir o estado real. Detalhe
canonico: [`.hbn/knowledge/0011-higiene-documental-recorrente.md`](.hbn/knowledge/0011-higiene-documental-recorrente.md).

## Convencoes de codigo

- VBA `Public Sub`, `Public Function` para superficie estavel.
- `Private` para implementacao.
- `Audit_Log.Registrar` apos qualquer acao com efeito de estado.
- `ErrorBoundary.HandleErr` no topo de qualquer Sub/Function publica.
- `On Error Resume Next` apenas em blocos curtos com justificativa
  comentada.
- Constantes em `Const_Colunas.bas` (colunas de aba) e `Util_Config.bas`
  (configuracao do workbook).

## Frontmatter obrigatorio em docs

Todo `.md` versionado neste repositorio deve abrir com:

```yaml
---
titulo: ...
diataxis: tutorial | how-to | reference | explanation | status | onda
hbn-track: fast_track | safe_track
hbn-status: active | archived | knowledge
audiencia: humano | ia | ambos
versao-sistema: V12.0.0205
data: AAAA-MM-DD
---
```

## Mapas para LLMs (RAG)

- [`llms.txt`](llms.txt) — mapa curado para LLMs (padrao
  [llmstxt.org](https://llmstxt.org/))
- [`llms-full.txt`](llms-full.txt) — indice exaustivo de todos os `.md`
  versionados

## Estrutura de pastas

```
.hbn/                <- coordenacao inter-IA (HBN-native)
  relay/             <- bastao + ciclo ativo
  relay-archive/     <- ondas resolvidas
  knowledge/         <- decisoes reutilizaveis
  reports/           <- saidas humanas concisas
  readbacks/         <- snapshots antes de execucoes safe_track
  results/           <- ERPs vinculados a readbacks

auditoria/           <- historia + evidencias publicas
  00_status/         <- snapshots de estado (22, 24, 26, 40)
  01_regras_e_governanca/  <- regras canonicas
  02_planos/         <- planos (15, 20, 25, 27)
  03_ondas/          <- documentacao tecnica de cada onda
  evidencias/        <- pasta canônica de CSVs e manifestos por release
  04_evidencias/     <- pasta histórica preservada por compatibilidade documental

docs/                <- Diataxis para humanos
  tutorials/         <- aprender (passo-a-passo)
  how-to/            <- problema concreto (cookbook)
  reference/         <- consulta (regras, API VBA, governanca)
  explanation/       <- entender (arquitetura, decisoes, racional)

src/vba/             <- fonte de verdade do codigo VBA
local-ai/vba_import/ <- pacote oficial de import (espelho com prefixos)
obsidian-vault/      <- vitrine institucional (status, dashboards, metodologia)
```

## Linha de comunicacao

Quando travada, a IA deve:

- Marcar a duvida com `🟡 HBN NEEDS HUMAN DECISION`.
- Apontar o arquivo `.hbn/relay/INDEX.md` para contexto.
- Aguardar hearback explicito antes de proceder.

Quando bloqueia algo por seguranca, a IA usa:

- `❌ HBN SECURITY BLOCKED SUGGESTION`.
- Justificativa em uma frase.

Quando esta operacional, a IA usa:

- `✅ HBN ACTIVE` no inicio do ciclo.

## Proibido

- Editar codigo sem ler `.hbn/relay/INDEX.md` antes.
- Reimportar `Mod_Types.bas` fora da Onda 9.
- Subir arquivo importavel fora de `local-ai/vba_import/`.
- Escrever claims sem evidencia ("100%", "zero risco", "totalmente seguro").
- Mandar humano editar codigo manualmente — toda entrega vem em
  `.code-only.txt` ou `.bas` pronto.
- Repetir mesma documentacao em 3 lugares.

## License + ethics

- TPGL v1.1 + CLA obrigatorio para contribuidores externos.
- Nenhuma IA pode introduzir codigo malicioso, exfiltracao de dados, ou
  vetor de ataque conhecido. Camada Glasswing
  (`.hbn/knowledge/0003-...`) lista os 5 vetores cobertos.
