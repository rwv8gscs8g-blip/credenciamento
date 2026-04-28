# AGENTS.md — entrada canonica para IAs

> Este arquivo segue o padrao [agents.md](https://agents.md/) e e a
> entrada **obrigatoria** para qualquer IA que va trabalhar neste
> repositorio (Claude Code, Claude Cowork, Claude API, Codex, Cursor,
> Copilot, Gemini, ou qualquer outra). Outros arquivos de instrucao
> historicamente especificos (`CLAUDE.md`, `.codex/`, `.cursorrules`)
> apontam para este como fonte unica.

## Identidade do projeto

| Campo | Valor |
|---|---|
| Nome | Sistema de Credenciamento e Rodizio de Pequenos Reparos |
| Linguagem principal | VBA (Excel `.xlsm`) |
| Versao oficial vigente | V12.0.0202 |
| Linha em estabilizacao | V12.0.0203 |
| Build importado no workbook (homologacao) | `f7aa84f+ONDA05-em-homologacao` |
| Branch ativa | `codex/v12-0-0203-governanca-testes` |
| Licenca | TPGL v1.1 (auto-conversao para Apache 2.0 em 4 anos) |
| Protocolo de governanca | [HBN — Human Brain Net](https://usehbn.org) |

## Antes de tocar qualquer coisa

Leia, em ordem:

1. [`.hbn/relay/INDEX.md`](.hbn/relay/INDEX.md) — quem tem o bastao agora
2. [`.hbn/knowledge/0001-regras-v203-inegociaveis.md`](.hbn/knowledge/0001-regras-v203-inegociaveis.md) — as 10 regras
3. [`.hbn/knowledge/0002-regra-ouro-vba-import.md`](.hbn/knowledge/0002-regra-ouro-vba-import.md) — como espelhar codigo
4. [`.hbn/knowledge/0003-glasswing-style-preventive-security.md`](.hbn/knowledge/0003-glasswing-style-preventive-security.md) — camada de seguranca preventiva
5. [`auditoria/00_status/22_STATUS_MICROEVOLUCOES_V12_0203.md`](auditoria/00_status/22_STATUS_MICROEVOLUCOES_V12_0203.md) — checkpoint atual
6. [`auditoria/40_TRANSICAO_RACIONALIZACAO_E_PROMPT_RETOMADA.md`](auditoria/40_TRANSICAO_RACIONALIZACAO_E_PROMPT_RETOMADA.md) — auditoria honesta

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

Veja `.hbn/relay/INDEX.md`. Em 2026-04-28, o bastao esta com **Claude
Opus 4.7 (Cowork)** ate a release V12.0.0203 estavel ser publicada no
GitHub. IAs sem bastao operam em modo **auditoria** (revisao + proposta
escrita), nao editam codigo.

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
| Validador consolidado | `Teste_Validacao_Release.bas` | `CT_ValidarRelease_TrioMinimo` | ~12 min |

A IA nunca executa esses testes diretamente — ela entrega o pacote
pronto para o operador rodar no workbook.

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
versao-sistema: V12.0.0203
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
  04_evidencias/     <- CSVs e manifestos por release

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
