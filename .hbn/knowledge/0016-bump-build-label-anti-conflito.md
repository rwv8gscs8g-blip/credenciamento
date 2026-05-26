---
titulo: Anti-conflito BUMP_BUILD_LABEL — não pré-setar APP_BUILD_IMPORTADO igual ao target
data: 2026-05-26
autoria: claude-opus-4-7 (Onda 38.2.1-AR1)
aplica-a: Toda IA que prepare uma onda safe_track tocando src/vba/App_Release.bas + local-ai/vba_import/001-modulo/AAX-App_Release.bas
revisar-em: 2026-08-26
---

# Anti-conflito BUMP_BUILD_LABEL

## Regra

Ao preparar `src/vba/App_Release.bas` para uma nova onda **NÃO** pré-setar
`APP_BUILD_IMPORTADO` ao **mesmo valor** que será passado como `buildLabel`
no `ImportarPacoteV3_Delta`. Deixar com o `APP_BUILD_IMPORTADO` da onda
**anterior** (o que o workbook do operador já tem carimbado). O Importador
V3 substitui dinamicamente durante a fase `5b_BUMP_BUILD_LABEL`.

## O que o V3 faz

`src/vba/Importador_V3.bas:1274-1335` (`IV3_AtualizarConstantesAppRelease`):

1. Lê `local-ai/vba_import/001-modulo/AAX-App_Release.bas` do disco.
2. Substitui textualmente:
   ```text
   APP_BUILD_IMPORTADO As String = "..."  →  "...= " & buildLabel
   APP_BUILD_GERADO_EM As String = "..."  →  "...= " & Format(Now, "yyyy-mm-dd hh:mm")
   ```
3. Se `novoConteudo = conteudo` (nenhuma das duas substituições mudou
   nada), reporta `[V3 FALHA] BUMP_NO_CHANGE — Constantes nao encontradas
   ou ja iguais` e **aborta o delta inteiro antes de qualquer import de
   módulo**.

## Quando o conflito acontece

`novoConteudo = conteudo` exige que AMBAS as substituições sejam no-op:

| Linha | No-op se… |
|---|---|
| `APP_BUILD_IMPORTADO` | valor no arquivo == `buildLabel` passado pelo operador |
| `APP_BUILD_GERADO_EM` | valor no arquivo == `Format(Now, "yyyy-mm-dd hh:mm")` no instante do import |

A coincidência do timestamp ao minuto é rara mas aconteceu na primeira
tentativa da Onda 38.2.1-AR1 (timestamp pré-setado `"2026-05-26 03:30"`
+ operador rodou import em `~03:30:15`).

Se o `APP_BUILD_IMPORTADO` já está no target, basta o timestamp
coincidir para o V3 abortar.

## Padrão correto

**Antes do commit da onda nova:**

```bash
# Reverte App_Release ao estado da onda anterior (último commit estável)
git show <onda-anterior-sha>:src/vba/App_Release.bas > src/vba/App_Release.bas

# Re-sync para AAX-App_Release.bas
bash local-ai/scripts/publicar_vba_import_v2.sh --apply
```

Resultado:
- `APP_BUILD_IMPORTADO` no `.bas` = label da onda anterior (≠ target da nova)
- `APP_BUILD_GERADO_EM` no `.bas` = qualquer valor que sobreviva no tempo (provavelmente diferente do `Now` do operador)
- Importador V3 detecta diferença em PELO MENOS `APP_BUILD_IMPORTADO`, substitui, retorna sucesso, prossegue para import dos módulos.

## Anti-padrão

```bash
# RUIM — pré-setar o build label novo no .bas
sed -i 's/APP_BUILD_IMPORTADO As String = ".*"/APP_BUILD_IMPORTADO As String = "<NEW_LABEL>"/' src/vba/App_Release.bas
```

Ou (equivalente) usar `Edit` tool para trocar para o NEW label antes do commit.

Mesmo se funcionar numa onda (porque o timestamp difere), é frágil —
qualquer onda futura em que o operador importar no minuto exato do
timestamp pré-setado vai abortar. A 38.2.1 anterior funcionou só por
sorte: timestamp `"2026-05-26 15:00"` vs import `~02:54`.

## Consequência no git

Após import bem-sucedido, o workbook recebe o NEW label. O Importador V3
**também** edita o `AAX-App_Release.bas` em disco para refletir o NEW
label (parte da fase 5b). Mas `src/vba/App_Release.bas` em git continua
com o OLD label.

Isto é esperado e correto: `src/vba/` é fonte versionada que reflete o
estado "antes da onda atual ser carimbada"; `local-ai/vba_import/` é
área de trabalho do Importador V3.

Na próxima rodada de `publicar_vba_import_v2.sh --apply`, o script
sincroniza `src/vba/` → `vba_import/`, voltando o AAX ao OLD label. Isso
é OK porque a próxima onda começa do estado antes-da-onda-anterior, e
o V3 vai bumpar para o label da onda seguinte.

## Trade-off

A regra cria uma assimetria: o build label no git nunca reflete o
último import bem-sucedido. Para auditar "qual build está no workbook
do operador?", consulta-se o ERP da última onda passada (`build_label`
no `delta_contract`) ou o relay/INDEX.

Alternativa: refatorar `IV3_AtualizarConstantesAppRelease` para tratar
`novoConteudo = conteudo` como **sucesso silencioso** (caso `BUMP_NO_OP`
em vez de `BUMP_NO_CHANGE FALHA`). Decisão fica para V207 — exige
auditoria do Importador V3 (atualmente Mod_Types-like — tabu).

## Documentos relacionados

- `src/vba/Importador_V3.bas:1274-1335` (lógica do BUMP)
- `.hbn/knowledge/0009-licoes-importador-v3-phase1.md`
- `.hbn/knowledge/0015-readback-opening-bootstrap.md`

## Onda de origem

Onda 38.2.1-AR1 (Opus, 2026-05-26). Primeiro import abortado com
`BUMP_NO_CHANGE`; hotfix revertendo `App_Release.bas` ao estado do
commit `e9bcf42` (Onda 38.2.1 encerrada) destravou o V3.
