---
titulo: Camada Glasswing-style de seguranca preventiva
data: 2026-04-28
autoria: derivado de Project Glasswing (Anthropic, abril 2026), Claude Mythos Preview e principios HBN existentes
aplica-a: toda IA que edita codigo VBA, formulas Excel, queries SQL ou qualquer artefato executavel deste repositorio
revisar-em: a cada nova capacidade significativa do Claude (proxima major release)
status: vigente como pratica obrigatoria
referencias:
  - https://www.anthropic.com/glasswing
  - https://red.anthropic.com/2026/mythos-preview/
---

# Camada Glasswing-style de seguranca preventiva

## Por que existe

Em abril de 2026, a Anthropic publicou o Project Glasswing e revelou que
o modelo Claude Mythos Preview encontrou **milhares de zero-days em todos
os principais sistemas operacionais e navegadores**. A leitura simples:
**modelos atuais ja sao capazes de descobrir e explorar vulnerabilidades
mais rapido do que humanos sao capazes de remediar**.

Para um repositorio publico de software municipal — com macros VBA que
manipulam dados pessoais e operacao real — isso muda o calculo de risco.
Nao e mais "uma IA bem intencionada nao vai introduzir vulnerabilidade".
E "se uma IA hostil clonar o repo, com qual rapidez ela acha falha?"

## Os 8 vetores que esta camada cobre

A camada Glasswing-style do Credenciamento adiciona 8 verificacoes
preventivas em cima do HBN existente:

- **G1-G5** introduzidos na Onda 6.
- **G6** adicionado no hotfix v2 da Onda 6 (2026-04-28) apos violacao real.
- **G7+G8** adicionados na Onda 9 (2026-04-29) como resposta a regressao
  estrutural causada por desincronizacao `src/vba/` ↔ `local-ai/vba_import/`
  durante Ondas 1-5. Sao a familia anti-IA explicita: protegem contra
  agentes (humanos ou IA) que pulem o publish ou movam Public Type entre
  modulos sem aprovacao.

Toda IA executora deve responder "sim" a todas as 8 antes de declarar
onda fechada **e antes de enviar resposta ao operador**.

### G1 — Macro nao confiavel

Nenhuma macro descartavel fica disponivel para auto-execucao. Macros de
diagnostico (Diag_*, Limpa_*, Reset_*) sao removidas do pacote
`vba_import/` e ficam apenas em backup externo, requerendo importacao
manual deliberada com hearback explicito do operador.

**Verificar:**

```bash
ls local-ai/vba_import/*.bas | grep -v -E "(Importador_VBA|Importar_Agora)\.bas$"
# Deve retornar vazio (regra Onda 6 em diante).
```

### G2 — Dados de configuracao validados antes de virar privilegio

Toda leitura de `CONFIG` (nota minima, max strikes, dias suspensao,
parametros de rodizio) passa por validacao de tipo + faixa **antes** de
produzir efeito comportamental. Valores invalidos nao zeram a config em
vigor (regra defensiva da Onda 4) e nao sao silenciosamente substituidos
por padroes — geram evento `CONFIG_REJEITADA` em `AUDIT_LOG`.

**Verificar:** revisar `Util_Config.GetX()` para confirmar que toda
leitura tem clausula `If valor < min Or valor > max Then Exit Function`
ou equivalente.

### G3 — Formulas privilegiadas isoladas

Formulas de planilha que executam acoes (`HYPERLINK("=macro()...")`,
`WEBSERVICE`, ranges com `SUBSTITUTE` que reescrevem comportamento) nao
podem aparecer em abas operacionais (`EMPRESAS`, `ATIVIDADES`, `CAD_OS`,
`CONFIG`). Se aparecerem em abas de teste/diagnostico, ficam em aba
prefixada `RPT_` ou `DIAG_` e o conteudo expira em 30 dias (campo de
data registrado no cabecalho).

**Verificar:** rodar diagnostico que lista todas as formulas em abas
operacionais e flag qualquer `=HYPERLINK`, `=WEBSERVICE` ou
`=INDIRECT` com argumento dinamico.

### G4 — Trilha de auditoria nao pode ser editada por IA

`AUDIT_LOG` e `AUDIT_TESTES` sao append-only no contrato operacional.
Nenhuma IA pode emitir codigo que faca `Range.Delete` ou `Range.Clear`
nesses ranges fora do caminho `Limpa_Base` autenticado pelo gestor.

**Verificar:**

```bash
grep -nE "(AUDIT_LOG|AUDIT_TESTES)\b" src/vba/*.bas | grep -E "(Delete|Clear|EntireRow)"
# Deve retornar apenas referencias dentro de Limpa_Base/LimpaBaseTotalReset.
```

### G6 — Codigo de produto na resposta da IA bloqueia entrega

**Adicionado em V12.0.0203 ONDA 6 hotfix v2 (2026-04-28).**

A IA executora **nao** envia ao operador, dentro do chat, qualquer
artefato que va eventualmente parar dentro do workbook `.xlsm`. Em
particular: nenhum bloco de codigo VBA (`Private Sub`, `Public Sub`,
`Public Function`, `Dim ... As`, `Range(...)`, `Sheets(...)`, `Cells(...)`,
`Application.X`), nenhuma formula Excel privilegiada, nenhuma macro
descartavel direto na resposta.

**Por que existe:** durante a Onda 6, identifiquei (Claude Opus 4.7
Cowork) que o Truth Barrier do HBN cobre claims de texto em documentos
do projeto, mas **nao cobre codigo solto na resposta da IA ao operador**.
O resultado pratico foi: respondi um diagnostico de erro de compilacao
colando codigo no chat com instrucoes Ctrl+A/C/V, em vez de atualizar o
procedimento canonico em `auditoria/03_ondas/onda_NN_*/<NN+1>_PROCEDIMENTO_IMPORT.md`
e o arquivo em `local-ai/vba_import/`. Mauricio pegou a violacao e
exigiu correcao explicita.

**O que e permitido na resposta:**

- Comandos shell que o operador roda no terminal local (git, bash, ls,
  cd, mv, mkdir, etc.) — esses sao **operacionais**, nao deliverables.
- Caminhos de arquivo no repositorio (`local-ai/vba_import/...`,
  `auditoria/03_ondas/...`).
- Tabelas operacionais que mapeiam [arquivo no repo | acao no Excel].
- Saida de diagnostico (output esperado, erros conhecidos, hashes).

**O que e proibido na resposta:**

- Trecho de Sub/Function VBA, mesmo em bloco markdown.
- Conteudo do `.code-only.txt`, `.bas`, ou `.frm` reproduzido na resposta.
- Formulas Excel com argumento dinamico (`HYPERLINK`, `WEBSERVICE`,
  `INDIRECT`).
- Macro descartavel "rapida" direto no chat ("rode esta macro de
  diagnostico").

**Verificacao manual:**

```bash
# Pre-flight check antes de mandar resposta — se algum match, parar e
# mover o conteudo para arquivo no repo:
grep -E "^(Private |Public |Sub |Function |Dim .* As |Sheets\(|Range\(|Cells\(|Application\.)" <(echo "$RESPOSTA")
```

**Verificacao automatica (a implementar na Onda 7 junto com glasswing-checks.sh):**

`local-ai/scripts/glasswing-checks.sh` recebe extensao para validar a
ultima resposta da IA salva (se aplicavel) e flag tokens VBA. Por
enquanto, a verificacao e manual e responsabilidade da propria IA antes
de enviar.

**Recuperacao se G6 violado:**

1. Reconhecer a violacao explicitamente para o operador.
2. Mover o codigo da resposta para o arquivo correto em
   `local-ai/vba_import/`.
3. Atualizar (ou criar) o procedimento em
   `auditoria/03_ondas/onda_NN_*/`.
4. Reenviar a resposta apenas com tabela de paths + acao.

### G7 — Pacote vba_import sincronizado com src/vba (anti-regressao IA)

**Adicionado em V12.0.0203 ONDA 9 (2026-04-29).**

Detecta drift entre `src/vba/` (fonte de verdade publica) e
`local-ai/vba_import/` (pacote CLA-controlado consumido pelo Importador
V2). Drift = qualquer diferenca de md5sum no conteudo normalizado entre
os dois lados.

**Por que existe:** durante as Ondas 1-5, IA executora editou
`src/vba/Util_Config.bas` (Onda 1, strikes), `src/vba/Mod_Limpeza_Base.bas`
(Onda 4, limpa base), `src/vba/Preencher.bas` (Onda 5) **sem rodar o
publish**. Resultado: `src/vba/` avancou, mas `local-ai/vba_import/`
ficou na versao antiga. O Importador V1 lia direto de
`local-ai/vba_import/` e propagou versao defasada para o workbook,
causando erros tipo `GetMaxStrikes nao definido`,
`Mod_Limpeza_Base.LimpaBaseTotalReset nao encontrado`,
`SHEET_PREFIX_CAD_SERV_SNAP nao definida`. Cada onda "fechada com
trio minimo verde" estava na verdade usando codigo defasado.

A correcao da causa raiz exige **gate automatico** que detecte drift
**antes** do commit ser feito. G7 e esse gate.

**Verificar:**

```bash
bash local-ai/scripts/glasswing-checks.sh G7
# OK = vba_import 100% sincronizado com src/vba (md5sum).
# VIOLATED = lista divergencias (arquivo X em src/vba diverge ou ausente
#            em vba_import) e bloqueia onda.
```

**Como corrigir uma violacao G7:**

```bash
bash local-ai/scripts/publicar_vba_import_v2.sh --apply
git add -A local-ai/vba_import/
git commit -m "fix(vba): ressincronizar vba_import com src/vba (G7)"
```

**Camadas de protecao automatizadas:**

1. `publicar_vba_import_v2.sh --check` (rapido, antes de commit)
2. `glasswing-checks.sh G7` (auditoria periodica)
3. **git pre-commit hook** (`local-ai/scripts/git-hooks/pre-commit`)
   bloqueia o proprio commit se G7 violado e o commit toca arquivo VBA

Detalhe arquitetural em `0008-importador-v2-arquitetura.md`.

### G8 — Public Type isolado em Mod_Types.bas (anti-IA-bagunca)

**Adicionado em V12.0.0429 ONDA 9 (2026-04-29).**

Detecta `Public Type` declarado fora de `src/vba/Mod_Types.bas`. Em
VBA, mover Public Types entre modulos causa erros sutis (`TConfig
duplicado`, `nao foi possivel encontrar nome`, `tipo nao definido em
contexto`) que sao dificeis de diagnosticar e bloqueiam compilacao.

**Por que existe:** durante a Onda 4, IA executora gerou um modulo
`AAA_Types.bas` paralelo com Public Type, criando conflito com
`Mod_Types.bas`. O sintoma demorou para aparecer porque so manifestava
em compilacoes completas, nao em re-imports parciais. G8 detecta isso
imediatamente, sem esperar o sintoma.

**Regra:** **todo `Public Type` do projeto vive em
`src/vba/Mod_Types.bas`. Sem excecao.** Mod_Types e tabu fora da Onda
9 plena (so muda com aprovacao explicita do mantenedor).

**Verificar:**

```bash
bash local-ai/scripts/glasswing-checks.sh G8
# OK = nenhuma violacao.
# VIOLATED = lista <arquivo>:<linha> com Public Type fora de Mod_Types.
```

**Como corrigir uma violacao G8:**

1. Identificar o arquivo violador na saida de `glasswing-checks.sh G8`.
2. Mover a declaracao `Public Type` para `src/vba/Mod_Types.bas`
   (verificar se ja existe la — se sim, deletar a duplicacao no
   violador).
3. Pedir aprovacao explicita do mantenedor antes de tocar Mod_Types
   (regra do tabu).
4. Rodar `bash local-ai/scripts/publicar_vba_import_v2.sh --apply`.
5. Rodar trio minimo no workbook para confirmar nao regressao.

**Camadas de protecao automatizadas:** identicas a G7
(publish --check, glasswing-checks, git pre-commit hook).

### G5 — Claim sem evidencia bloqueia entrega

A IA nao pode escrever em onda fechada frases como:

- "100% testado"
- "sem risco"
- "totalmente seguro"
- "garantido funcionar em todos os Excel"
- "nao introduz regressao"

Truth Barrier do HBN flag esses claims. Substitua por:

- "trio minimo verde no checkpoint <CSV>"
- "risco residual: <especificar>"
- "validado em Excel 2019/2021/365 conforme `obsidian-vault/00-DASHBOARD.md`"
- "regressao nao detectada na bateria oficial; cobertura ainda parcial em forms"

**Verificar:**

```bash
grep -rE "(100%|zero risco|sem risco|totalmente seguro|garantido)" \
  auditoria/03_ondas/ docs/ README.md CHANGELOG.md
# Deve retornar zero ocorrencias.
```

## Integracao com HBN

A camada Glasswing-style **nao substitui** o HBN — ela e uma extensao do
Truth Barrier (regra G5) e do Guardian (regras G1-G4). Toda violacao
gera entrada em `.hbn/results/` com `outcome: rejected`.

Em readbacks, a IA executora declara explicitamente:

```json
{
  "glasswing_checks": {
    "G1_macro_nao_confiavel": "ok | violado | nao_aplicavel",
    "G2_config_validada": "ok | violado | nao_aplicavel",
    "G3_formulas_privilegiadas": "ok | violado | nao_aplicavel",
    "G4_audit_log_append_only": "ok | violado | nao_aplicavel",
    "G5_claims_proporcionais": "ok | violado | nao_aplicavel",
    "G6_codigo_no_chat": "ok | violado | nao_aplicavel",
    "G7_vba_import_sincronizado": "ok | violado | nao_aplicavel",
    "G8_public_type_isolado": "ok | violado | nao_aplicavel"
  }
}
```

## Como verificar (resumo)

Antes de fechar onda, rodar:

```bash
bash local-ai/scripts/glasswing-checks.sh
```

Saida esperada: tabela com 5 OK + 2 WARN (falsos positivos historicos)
+ 1 MANUAL (G6 cultural). Qualquer `VIOLATED` bloqueia o fechamento da
onda.

Modos:

```bash
# auditoria completa
bash local-ai/scripts/glasswing-checks.sh

# strict (WARN tambem bloqueia, util em CI)
bash local-ai/scripts/glasswing-checks.sh --strict

# vetores especificos
bash local-ai/scripts/glasswing-checks.sh G7 G8

# silenciar output (util em pre-commit hook)
bash local-ai/scripts/glasswing-checks.sh --quiet
```

A protecao a montante e o **git pre-commit hook**
(`local-ai/scripts/git-hooks/pre-commit`), que invoca
`publicar_vba_import_v2.sh --check` (G7+G8) automaticamente em todo
commit que toque arquivos VBA. Bypass de emergencia via
`GLASSWING_BYPASS=1 git commit ...` exige justificativa formal em
`.hbn/`.
