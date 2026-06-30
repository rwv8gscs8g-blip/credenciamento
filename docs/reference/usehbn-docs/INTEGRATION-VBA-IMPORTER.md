# Integration: VBA Importer pattern (Credenciamento case)

> Caso de uso real: Credenciamento V12.0.0203 (municipality vendor
> accreditation system).
> Padrao replicavel em outros projetos com codigo legacy em ambiente
> embutido (VBA, VBScript, Apps Script, etc).

## Contexto

Sistemas embutidos em planilhas (Excel/Google Sheets) ou aplicacoes
desktop legacy (MS Access, FoxPro, dBase) frequentemente carregam
**toda a logica de negocio** em modulos de codigo dentro do proprio
arquivo binario. Isso cria 3 problemas para qualquer time que queira
trabalhar de forma profissional:

1. **Versionamento.** Codigo dentro de `.xlsm` e `.accdb` nao e
   versionavel diretamente em git (e binario).
2. **Reproducibilidade.** Onboarding novo dev = tentar copiar/colar do
   workbook em producao. Sem manifesto, sem ordem topologica, sem
   normalizacao.
3. **Cybersegurança.** Codigo trafega por email/Drive/Slack como
   arquivo binario, sem assinatura, sem auditoria. Qualquer mudanca
   indireta passa despercebida.

O padrao **VBA Importer** resolve essas 3 dimensoes simultaneamente.

## Os 5 componentes do padrao

### 1. Fonte de verdade textual (`src/vba/` ou equivalente)

Codigo VBA exportado para arquivos `.bas`/`.frm`/`.frx` versionaveis em
git. **Nao** se edita o `.xlsm` diretamente; toda mudanca e:

- editar em `src/vba/<modulo>.bas`,
- rodar publish,
- importar pacote no workbook.

### 2. Pacote de import normalizado (`local-ai/vba_import/` ou equivalente)

Espelho de `src/vba/` apos normalizacao:

- encoding canonico (UTF-8 + CRLF + EOF=3 CRLFs no caso VBA),
- ASCII puro em comentarios (em-dash → hyphen, etc),
- prefixos alfabeticos (`AAA-`, `AAB-`, ...) para ordenacao topologica,
- manifesto declarativo (1 arquivo texto descrevendo grupos e itens).

Esse pacote pode ser **CLA-controlado** se a logica de negocio for
sensivel — ver `INTEGRATION-CLA-CONTROLLED-ACCESS.md`.

### 3. Importador embutido (`Importador_V2.bas` ou equivalente)

Modulo no proprio sistema (VBA neste caso) que:

- le o manifesto,
- valida pre-condicoes (acesso ao modelo de objeto, manifesto presente),
- processa por grupo na ordem topologica,
- valida compilacao apos cada grupo,
- mantem **tabu** em modulos sensiveis (no caso, `Mod_Types`),
- gera log persistente em aba dedicada,
- faz backup automatico antes de import real,
- expoe DryRun (simula sem alterar) + Real (aplica).

### 4. Validacao Glasswing (Cybersegurança Preventiva)

3 vetores especificos para esse padrao:

- **G7** — pacote sincronizado com fonte (md5sum). Detecta drift.
- **G8** — invariantes estruturais (no caso VBA: Public Type apenas em
  `Mod_Types.bas`).
- **G6** — codigo de produto solto na resposta da IA (cultural,
  protege contra IA gerar codigo "no chat" em vez de em arquivo).

Detalhe em `INTEGRATION-GLASSWING.md`.

### 5. git pre-commit hook

Bloqueia commits que violem G7 ou G8. Fast path quando commit nao toca
codigo embutido. Bypass via env var (`GLASSWING_BYPASS=1`) com
auditoria obrigatoria via commit message + nota HBN.

## Como Credenciamento implementou

Stack (resumo):

```
- src/vba/                           (fonte de verdade publica)
- local-ai/                          (CLA-controlado, gitignored)
  - scripts/
    - publicar_vba_import_v2.sh+.py  (publish + normalizacao)
    - glasswing-checks.sh            (G1-G8 standalone)
    - install-git-hooks.sh           (instala pre-commit)
    - git-hooks/pre-commit           (template do hook)
  - vba_import/                      (pacote)
    - 000-MANIFESTO-IMPORTACAO.txt
    - 000-MAPA-PREFIXOS.txt
    - 001-modulo/<prefixo>-<nome>.bas
    - 002-formularios/<prefixo>-<nome>.frm/.frx/.code-only.txt
- src/vba/Importador_V2.bas          (modulo do produto, publico)
```

Operacao tipica do contribuidor (com CLA assinado):

```bash
# Editar
vim src/vba/Svc_Avaliacao.bas

# Sincronizar
bash local-ai/scripts/publicar_vba_import_v2.sh --apply

# Validar
bash local-ai/scripts/glasswing-checks.sh

# Importar no workbook (no Excel VBE)
ImportarPacoteV2_DryRun
ImportarPacoteV2

# Commit (hook valida G7+G8)
git add src/vba/Svc_Avaliacao.bas
git commit -m "fix(svc): corrigir bug X em Svc_Avaliacao"
```

## Por que isso ajuda outros projetos

### Time pequeno + IA-augmented

A ordenacao topologica + tabu permite que IA atue **com seguranca**:
ela so pode mexer em arquivos do `src/vba/`, e qualquer mudanca passa
por 3 camadas de validacao (publish, glasswing, hook) antes de chegar
no commit. Custom GPTs / Claude / Codex podem operar como contribuidor
com CLA, mas nao podem escapar dos invariantes.

### Codigo legacy + modernizacao gradual

Voce nao precisa reescrever o sistema em uma stack moderna para ter
versionamento, reprodutibilidade e auditoria. O padrao envelopa o
codigo legacy num fluxo profissional sem mexer na linguagem alvo.

### Auditoria CMMI / ISO

Cada import deixa rastro em `IMPORT_LOG_V2` (append-only). Cada
publish deixa rastro em `BUILD_INFO`. Cada commit passa por validacao
automatizada. Auditor externo consegue reconstruir 100% do historico
sem precisar acesso ao codigo CLA-controlado.

## Adaptacao para Apps Script / Office Scripts / Macros

O padrao funciona com qualquer linguagem embutida em arquivo binario
ou ambiente proprietario. Substitua:

| VBA | Apps Script | Office Scripts | dBase/FoxPro |
|---|---|---|---|
| `.bas` | `.gs` | `.ts` | `.prg` |
| `.frm/.frx` | (sem equivalente) | (sem equivalente) | `.fxp` |
| `Application.VBE.ActiveVBProject` | `ScriptApp` | `ExcelScript` | (CLI proprietario) |
| `Mod_Types` | namespace de tipos | interface centralizada | (header file) |
| Aba `IMPORT_LOG_V2` | folha de log | folha de log | tabela de log |

A logica do publish + glasswing + hook permanece identica. Apenas o
modulo de import precisa ser reescrito na linguagem alvo.

## Onde aprender mais

- `usehbn/docs/INTEGRATION-GLASSWING.md` — vetores G1-G8 detalhados.
- `usehbn/docs/INTEGRATION-CLA-CONTROLLED-ACCESS.md` — quando manter
  parte do tooling CLA-controlado.
- `usehbn/docs/INTEGRATION-DIATAXIS.md` — como organizar a documentacao
  (publica + restrita).
- `usehbn/docs/CASE-STUDY-CREDENCIAMENTO.md` — caso completo.

## Quem inventou

Este padrao foi destilado durante as Ondas 6-9 do projeto
Credenciamento V12.0.0203 (2026-04 a 2026-04, projeto municipal de
credenciamento de prestadores). Maintainers: Mauricio Junqueira Zanin
+ Claude Opus 4.7 (Cowork). Bug que motivou a reescrita: regressao em
massa Onda 1-5 com 30+ arquivos divergentes.
