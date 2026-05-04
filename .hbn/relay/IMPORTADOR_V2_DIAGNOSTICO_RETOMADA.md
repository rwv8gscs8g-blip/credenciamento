# Importador V2 — Diagnostico de Retomada (29/04/2026 ~05:00)

> Documento autocontido para retomada em novo chat sem perder contexto.
> Escrito apos 4h de hotfixes iterativos sem convergencia, com pedido
> explicito do operador (Mauricio) para parar o loop e fazer analise robusta.

## Resumo brutal: o que aconteceu

O **Importador V2** (`src/vba/Importador_V2.bas`) le um manifesto em
`local-ai/vba_import/000-MANIFESTO-IMPORTACAO.txt` e importa 48 modulos
(.bas) + 1 tabu (Mod_Types) + 13 forms (.frm) no workbook
`PlanilhaCredenciamento-Homologacao.xlsm` aberto em **Excel for Mac**
via **SMB share** (`\\Mac\Home\Projetos\Credenciamento\...`).

Apos 13 hotfixes (v1 a v13) iterativos, o sintoma recorrente:

- DryRun reporta `48 / 1 / 0` consistentemente.
- Real reporta `48 / 1 / 0` (mas as vezes com errs intermediarios).
- **MsgBox final diz que terminou OK.**
- **Compile manual subsequente falha** com `Metodo ou membro de dados
  nao encontrado` em chamadas como `Util_Conversao.ToDouble`,
  `Util_Conversao.ToLong`, `Funcoes.NormalizarTextoPTBR`, etc.
- `?ThisWorkbook.VBProject.VBComponents("Util_Conversao").CodeModule.CountOfLines`
  retorna **160** (esperado **94**) — codigo duplicado dentro do modulo.

## Hotfixes iterativos aplicados (que NAO resolveram)

| v | Mudanca | Resultado |
|---|---|---|
| v5 | `IV2_RemoverComponente` robusto (backup best-effort) | parcial |
| v6 | `IV2_ImportarModulo` aborta se Remove falhou | parcial |
| v7 | `IV2_CompilarVBProject` best-effort (nao aborta no Mac) | OK (esse fix permanece valido) |
| v8 | `Preencher.bas` linha 2622-2623 corrigido (smart quotes via ChrW) | OK (esse fix permanece valido) |
| v9 | `Util_Filtro_Lista.UtilFiltro_LocalizarTextBoxFiltro` retorna `MSForms.TextBox` (compativel WithEvents) | OK (esse fix permanece valido) |
| v10 | Substituiu `VBComponents.Import` por `Add + AddFromString` | falhou: criava modulo paralelo (Module1) quando Remove silencioso |
| v11 | Estrategia in-place: se vbName existe, `cm.DeleteLines + cm.AddFromString` | parcialmente OK (4 forms com .code-only.txt funcionam) |
| v12 | Publish gera `.code-only.txt` para 13 forms | OK (corrigiu 9 errs em forms) |
| v13 | Loop `cm.DeleteLines` ate `CountOfLines = 0` | NAO TESTADO ainda; ultima tentativa antes de parar |

## Bug residual nao resolvido (estado atual)

Apos run REAL com hotfix v12 (e v13 publicado mas nao testado):

```
?GetBuildImportado                                       → b2e7bd3+ONDA09-hotfix-v12-em-homologacao
?...VBComponents("Util_Conversao").CodeModule.CountOfLines → 160 (esperado ~94)
Compile manual                                            → "Metodo ou membro de dados nao encontrado"
```

Diagnostico provavel: o `cm.DeleteLines 1, cm.CountOfLines` em **uma
unica chamada** no Excel for Mac NAO zera o CodeModule completamente.
Deixa residuo (~66 linhas). Apos `cm.AddFromString corpo` (~94 linhas),
total fica ~160 com codigo duplicado interno. Parser VBA detecta
declaracoes ambiguas e rejeita.

v13 tenta loop ate zerar — mas **nao testado**. Pode nao ser suficiente
se o problema for mais profundo (e.g., `cm.DeleteLines` no Mac com
arquivo SMB tem limite de linhas por chamada, ou `cm.AddFromString`
mantem cache do conteudo anterior).

## Hipoteses NAO TESTADAS (caminhos a investigar)

### H1 — VBE Mac via SMB tem comportamento erratico

Workbook esta em `\\Mac\Home\Projetos\Credenciamento\` (SMB share). VBE
pode ter limitacoes especificas de I/O assincrono ou cache que nao
manifestam em local disk. **Teste**: copiar workbook para disco local
do Mac (ex.: `~/Desktop/`) e rodar Importador V2 dali.

### H2 — `cm.AddFromString` faz append, nao replace

Hipotese: a API VBE faz `AddFromString` adicionando ao final do
CodeModule existente, mesmo apos DeleteLines aparentemente zerar. O
DeleteLines pode estar marcando linhas como "deleted" mas elas voltam
quando AddFromString e chamado.

**Teste**: apos DeleteLines, fazer `Set cm = alvo.CodeModule` (re-bind)
e `Application.VBE.MainWindow.Visible = False : True` (forcar refresh)
antes de AddFromString.

### H3 — Workbook em estado corrompido binario

Mauricio fechou e reabriu o workbook varias vezes, salvou em estados
intermediarios diferentes. O `.xlsm` no disco pode ter cache binario
do VBE que mantem componentes "fantasmas" entre re-aberturas.

**Teste**: Reset radical — usar `PlanilhaCredenciamento-Modelo.xlsx`
(template sem VBA) e importar tudo do zero. Workbook fresh nao tem
nenhum componente para conflitar.

### H4 — `corpo` extraido tem problema sutil

Talvez o `Split(conteudo, vbCrLf)` deixa caracteres invisiveis ou BOM
no inicio que confundem `AddFromString`.

**Teste**: dump do `corpo` para arquivo `.txt` antes de chamar
AddFromString, comparar bytewise com src/vba/Util_Conversao.bas.

### H5 — Modulos com `Public Sub` ou `Public Function` que conflitam globalmente

Se o codigo fonte tem `Public Sub` com nome que ja existe em outro
modulo, o segundo import gera "Ambiguous name" mas pode ser silenciado.

**Teste**: rodar grep por funcoes Public duplicadas em src/vba/.

### H6 — Bug no proprio Importador V2 importado

O Importador V2 e autoreferencial (ele mesmo e um modulo). Se a copia
no workbook esta corrompida (e.g., 2x duplicado), o codigo que roda
durante o import esta defasado.

**Teste**: validar `?ThisWorkbook.VBProject.VBComponents("Importador_V2").CodeModule.CountOfLines`
antes de rodar. Esperado ~860.

## O que tentamos e nao funcionou

1. **Reimport manual de 5 modulos** → outros modulos quebrados
2. **Reimport manual de 11 modulos** → ainda outros quebrados
3. **Reimport manual de 9 modulos** (Util_*, Funcoes, Repos) → ainda quebrado
4. **Reset (close sem salvar) + reimport** → estado do disco ja estava ruim
5. **Hotfix v10 (Add+AddFromString)** → criou modulos paralelos (Module1)
6. **Hotfix v11 (in-place DeleteLines+AddFromString)** → 9 forms quebrados
7. **Hotfix v12 (.code-only.txt para todos os forms)** → 0 errs reportados, mas codigo duplicado interno
8. **Hotfix v13 (loop DeleteLines)** → publicado, NAO testado

## Onde a IA (Claude) errou

1. **Iteracoes pequenas demais**: cada hotfix corrigia um sintoma sem
   atacar a causa raiz. Devia ter parado e feito analise robusta apos
   v8.

2. **Confiou no log do Importador V2**: o log dizia `imported ok` mas o
   estado real do projeto VBA era diferente. Devia ter SEMPRE validado
   pos-import via `CountOfLines`.

3. **Nao testou os hotfixes antes de pedir Mauricio rodar**: cada hotfix
   ia direto para o operador. Teria valido criar um workbook de teste
   no proprio sandbox.

4. **Subestimou complexidade do ambiente**: SMB + Excel Mac + workbook
   em estado misto + APIs VBE legadas = territorio minado. Devia ter
   recomendado **reset radical (workbook fresh)** desde o inicio.

5. **Foco em fixes em vez de diagnostico**: deveria ter pedido para
   Mauricio rodar inventario completo (todos componentes + tamanhos +
   duplicatas) antes de propor mudancas no codigo.

## Estado atual dos arquivos (para retomada)

### Publico (commitavel):
- `src/vba/Importador_V2.bas` — v13 com loop DeleteLines (NAO testado)
- `src/vba/App_Release.bas` — APP_BUILD_IMPORTADO = `b2e7bd3+ONDA09-hotfix-v13-em-homologacao`
- `src/vba/Preencher.bas` — fix smart quotes via ChrW (v8) — VALIDO
- `src/vba/Util_Filtro_Lista.bas` — early-binding MSForms.TextBox (v9) — VALIDO
- `src/vba/Cadastro_Servico.frm`, `Reativa_Empresa.frm`, `Reativa_Entidade.frm` — refator Onda 8 — VALIDO
- `src/vba/Teste_V2_Engine.bas`, `Teste_V2_Roteiros.bas`, `Central_Testes_V2.bas` — Onda 7 IDM_*+RDZ_* — VALIDO
- `src/vba/AppContext.bas` — comentario corrigido (Mod_Types) — VALIDO
- `src/vba/AAA_Types.bas` — DELETADO — VALIDO
- `.hbn/knowledge/0008-importador-v2-arquitetura.md` — knowledge — VALIDO
- `docs/explanation/IMPORTADOR_V2.md`, `docs/how-to/COMO_IMPORTAR_PACOTE_VBA.md`, `docs/reference/MANIFESTO_FORMAT.md` — Diataxis — VALIDO
- `usehbn/docs/INTEGRATION-VBA-IMPORTER.md` — vitrine — VALIDO
- `docs/explanation/HEURISTICA_ZERO_NOS_FORMS.md` — Onda 8 — VALIDO
- `.hbn/knowledge/0003-glasswing-style-preventive-security.md` — G7+G8 documentados — VALIDO

### CLA-controlado (gitignored, atualizado):
- `local-ai/vba_import/001-modulo/*.bas` — 33 modulos espelhados
- `local-ai/vba_import/002-formularios/*.frm/.frx/.code-only.txt` — 13 forms + 13 code-only.txt (todos)
- `local-ai/scripts/publicar_vba_import_v2.py` — gera code-only.txt sempre
- `local-ai/scripts/git-hooks/pre-commit` — Glasswing G7+G8 (Onda 9.4)
- `local-ai/scripts/install-git-hooks.sh` — instalador (Onda 9.4)

## Workbook de homologacao

- Caminho: `/Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-Homologacao.xlsm`
- Abre via: SMB share `\\Mac\Home\Projetos\Credenciamento\...` (do ponto de vista do Excel para Mac)
- Trio minimo APROVADO antes da serie de hotfixes (timestamp `VR_20260429_014916`)
- Apos hotfixes: estado **misto/corrompido**. Modulos com codigo duplicado.

## Que dados o proximo chat precisa coletar antes de propor mudancas

1. **Inventario completo de componentes do workbook**:
   ```
   Sub Inv: Dim c As Object: For Each c In ThisWorkbook.VBProject.VBComponents: Debug.Print c.Name & " | type=" & c.Type & " | lines=" & c.CodeModule.CountOfLines: Next: End Sub
   ```
   Cole na imediata, executa. Reporta TODOS os componentes + tamanhos.

2. **Lista de funcoes Public duplicadas**:
   ```bash
   grep -hE "^Public Function|^Public Sub" src/vba/*.bas | sort | uniq -d
   ```

3. **Hash do `.xlsm` atual no disco**:
   ```bash
   shasum -a 256 PlanilhaCredenciamento-Homologacao.xlsm
   ```

4. **Existe `PlanilhaCredenciamento-Modelo.xlsx` (sem VBA) para reset radical?**
   ```bash
   ls -la PlanilhaCredenciamento-Modelo*
   ```

## Recomendacao para retomada

**Ordem proposta**:

1. **Coletar dados** (3 itens acima) antes de qualquer hotfix.
2. **Validar hipoteses H1-H6** uma a uma com testes especificos.
3. **Decidir entre 2 caminhos**:
   - A) Continuar fix do Importador V2 v14 baseado em diagnostico real.
   - B) **Reset radical**: usar workbook Modelo (sem VBA), Importador V2 cai no caminho `Add+AddFromString` que e determinístico para workbook limpo.
4. **NAO mais hotfix incremental sem evidencia**.

## Para o novo chat — prompt de retomada (copiar e colar)

```
Estamos retomando estabilizacao do projeto Credenciamento V12.0.0203
apos 4h de hotfixes iterativos no Importador V2 sem convergencia.

Leia primeiro estes 2 arquivos canonicos para contexto completo:

1. .hbn/relay/IMPORTADOR_V2_DIAGNOSTICO_RETOMADA.md
   (resumo brutal do que aconteceu, hotfixes aplicados, hipoteses
   nao testadas, e onde a IA anterior errou)

2. .hbn/knowledge/0008-importador-v2-arquitetura.md
   (arquitetura do Importador V2 + 5 contratos)

Apos ler, NAO faca hotfix imediato. Em vez disso:

PASSO 1 — Pedir ao Mauricio rodar inventario completo do workbook:
  Sub Inv: Dim c As Object: For Each c In ThisWorkbook.VBProject.VBComponents: Debug.Print c.Name & " | type=" & c.Type & " | lines=" & c.CodeModule.CountOfLines: Next: End Sub

PASSO 2 — Validar hipoteses H1-H6 do diagnostico (ver doc) com testes
especificos antes de propor qualquer alteracao em codigo.

PASSO 3 — Decidir entre 2 caminhos (A=fix iterativo / B=reset radical)
com base em evidencias coletadas.

PASSO 4 — Se opcao B: usar PlanilhaCredenciamento-Modelo.xlsx (workbook
sem VBA) e importar tudo via Importador V2 (caminho Add+AddFromString
deterministico para workbook fresh).

Estado atual:
- src/vba/Importador_V2.bas esta na versao v13 (loop DeleteLines, NAO
  testado).
- Build atual: b2e7bd3+ONDA09-hotfix-v13-em-homologacao
- Workbook PlanilhaCredenciamento-Homologacao.xlsm esta com codigo
  duplicado em multiplos modulos. Compile manual falha.
- Trio minimo aprovado pela ultima vez em VR_20260429_014916 (antes
  da serie de hotfixes).

NAO REPETIR padrao do chat anterior:
- Nao fazer hotfix sem evidencia
- Nao confiar no log do Importador V2 isoladamente
- SEMPRE validar pos-import via CodeModule.CountOfLines
- Considerar reset radical (workbook fresh) como caminho mais simples

Modo: consultivo + tabela canonica + sem codigo VBA solto no chat (G6).
```

## Conclusao honesta

A culpa do loop e da IA (Claude). Mauricio confiou em cada hotfix e
cada um trazia um sintoma novo. O caminho correto desde v8/v9 teria
sido: **parar, coletar inventario, considerar reset radical**.

Em vez disso, fui adicionando hotfixes baseados em hipoteses que nao
testei. Resultado: 4h perdidas, workbook em estado pior, e operador
exausto.

Pedido: comecar novo chat com este documento como ponto de partida.
Coletar dados antes de qualquer mudanca. Considerar abandonar o
caminho atual e fazer reset radical (workbook fresh + import via
caminho `Add+AddFromString` determinístico).

— Claude Opus 4.7 (Cowork), 2026-04-29 ~05:00
