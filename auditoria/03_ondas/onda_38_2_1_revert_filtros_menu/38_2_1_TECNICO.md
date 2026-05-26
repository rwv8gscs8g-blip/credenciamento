# Onda 38.2.1 — Revert filtros Menu_Principal (técnico)

**Versão alvo:** V12.0.0206
**Branch:** `codex/v12-0-0206-planejamento`
**Build label:** `7bca168+ONDA38.2.1-revert-filtros-menu`
**Agente:** Claude Opus 4.7 (bastão transferido Codex → Opus em 2026-05-26)
**Readback:** `.hbn/readbacks/0105-onda38-2-1-revert-filtros-menu.json`
**ERP:** `.hbn/results/0105-exec-onda38-2-1-revert-filtros-menu.json`
**Predecessor:** Onda 38.2 (ERP 0104, reprovada no gate humano)

---

## 1. Motivação

A Onda 38.2 (commit `7bca168`) tentou ligar os 7 filtros do
`Menu_Principal.frm` (TextBox16 a TextBox22 — Entidade, Empresa, Atribuição
Serviço, Rodízio, Cadastro Serviço, Pré-OS, Avaliação) declarando
`Private WithEvents mTxtFiltroXxxxx As MSForms.TextBox` e fazendo bind
dinâmico em `UserForm_Initialize` via `Me.Controls("TextBoxNN")`.

**Resultado funcional (gate humano 2026-05-25):**

| Verificação | Resultado |
|---|---|
| `ImportarPacoteV3_Delta` | ✅ OK |
| Compile VBE | ✅ OK |
| Filtros funcionam | ❌ inconsistentes |
| Erro VBA 424 ao digitar | ❌ presente |
| Cadastro de empresa nova | ❌ retornou ID 001 (suspeita de corrupção) |
| Outras telas | ❌ instabilidade colateral |
| `CT_ValidarRelease_TrioMinimo` | ⏭ não rodado (gate funcional já reprovado) |

**Diagnóstico convergente** (Antigravity/Gemini + Claude Opus anterior +
Codex): a causa raiz é **double-handler**. Os controles
`TextBox16..TextBox22` já têm handlers nativos `TextBoxNN_Change` no
`.frm`. Ao declarar `WithEvents mTxtFiltroXxxxx` e bindar via
`Set mTxtFiltroXxxxx = Me.Controls("TextBoxNN")`, cada digitar disparou
**dois handlers** em ordem indeterminada, ambos mutando variáveis
globais (`cont`, `NItem`, `nLinhas`, `i`). O erro 424 surgiu quando o
segundo handler acessou estado já invalidado pelo primeiro.

**Decisão Mauricio:** reverter via Onda 38.2.1 (forward-only) e refazer
filtros na Onda 38.2.2 com arquitetura segura (handlers nativos +
função pura).

---

## 2. Escopo

### Arquivos tocados

| Path | Operação |
|---|---|
| `src/vba/Menu_Principal.frm` | restore byte-a-byte do anchor `a6ad842` |
| `src/vba/Preencher.bas` | restore byte-a-byte do anchor `a6ad842` |
| `src/vba/App_Release.bas` | restore do anchor + 2 strings atualizadas |
| `local-ai/vba_import/002-formularios/AAM-Menu_Principal.frm` | sync via `publicar_vba_import_v2.sh --apply` |
| `local-ai/vba_import/002-formularios/AAM-Menu_Principal.code-only.txt` | sync via `publicar_vba_import_v2.sh --apply` |
| `local-ai/vba_import/001-modulo/AAU-Preencher.bas` | sync |
| `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | sync |
| `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-2-1-REVERT-FILTROS-MENU.txt` | criado |
| `.hbn/results/0104-exec-onda38-2-filtros-menu-principal.json` | fechado como `human_gate_failed` |
| `.hbn/readbacks/0105-onda38-2-1-revert-filtros-menu.json` | criado (confirmed) |
| `.hbn/results/0105-exec-onda38-2-1-revert-filtros-menu.json` | criado |
| `.hbn/relay/INDEX.md` | flip bastão Codex → Opus + bloco Onda 38.2.1 |
| `.hbn/knowledge/0015-readback-opening-bootstrap.md` | lição aprendida criada |
| `CHANGELOG.md` | entradas Onda 38.2 (reprovada) e 38.2.1 (revert) |

### Não tocados (invariantes)

- Nenhum `.frx`
- Nenhum serviço blindado (`Svc_Rodizio`, `Svc_Avaliacao`, `Svc_OS`, `Svc_PreOS`)
- `Mod_Types.bas`, `Importador_V3.bas`
- RN-01 a RN-17
- Contadores RVS
- `local-ai/incoming/**` (read-only)

---

## 3. Decisão arquitetural: fonte = git anchor, não export

O export estável em
`local-ai/incoming/export_workbook_38_1_5_estavel_20260525/` foi
**evidência comparativa apenas**, não fonte de verdade. Motivo (auditado
em chat 2026-05-26): export tem ruído de trailing whitespace em
`Menu_Principal.frm` (sequência extra `\r\n\r\n\r\n           \r\n\r\n\r\n`)
e em `App_Release.bas` (5 espaços órfãos + CRLF). O anchor git `a6ad842`
é limpo e — verificado byte-a-byte — idêntico ao trailer atualmente em
`HEAD`/`7bca168` (a Onda 38.2 ruim não modificou trailers). Restaurar
do git garante zero divergência de whitespace que poderia regredir o
compile VBA.

---

## 4. Validações locais

| Gate | Status | Evidência |
|---|---|---|
| shasum `src/vba/Menu_Principal.frm` vs `git a6ad842` | ✅ | `818bdbdde17ccfd8de7144d714953bfdfa4e2855` byte-idêntico |
| shasum `src/vba/Preencher.bas` vs `git a6ad842` | ✅ | `1073edb02d4982f295a3b848adc51de98f77f636` byte-idêntico |
| diff `src/vba/App_Release.bas` vs `git a6ad842` | ✅ | 2 linhas: `APP_BUILD_IMPORTADO` e `APP_BUILD_GERADO_EM` |
| `publicar_vba_import_v2.sh --apply` | ✅ | espelho regenerado; G7 OK; G8 OK |
| `publicar_vba_import_v2.sh --check` | ✅ | vba_import 100% sincronizado |
| Manifest delta criado (3 arquivos) | ✅ | `F\|AAM-Menu_Principal.frm`, `M\|AAU-Preencher.bas`, `M\|AAX-App_Release.bas` |

---

## 5. Gates humanos pendentes

1. `ImportarPacoteV3_Delta "ONDA38-2-1-REVERT-FILTROS-MENU", "7bca168+ONDA38.2.1-revert-filtros-menu"` deve retornar `M=2 | F=1 | err=0 | skip=0`.
2. `Depurar > Compilar VBAProject` deve passar limpo no VBE.
3. Abrir Menu Principal + telas-filhas; digitar em TextBox16..22 → **sem** erro 424. Filtros inativos (como na 38.1.5).
4. **Gate explícito** — cadastrar uma empresa nova; ID deve ser sequencial correto. Se ID 001 voltar, **parar** e abrir Onda 38.2.1-AR1 para investigar `Repo_Empresa.ProximoId`/AR1.
5. `CT_ValidarRelease_TrioMinimo` retorna APROVADO `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0`.

---

## 6. Plano de rollback

| Cenário | Ação |
|---|---|
| `shasum` divergir antes do commit | refazer `git show a6ad842:<path> > <path>` |
| `publicar_vba_import_v2.sh --check` falhar | `--apply` até sync 100%; só commitar com `--check` OK |
| `ImportarPacoteV3_Delta` falhar | Mauricio **não salva** o workbook; cola mensagem do Importador V3 |
| Compile VBE falhar | restaurar do backup indicado pelo Importador V3 |
| Cadastro empresa retornar ID 001 | **parar imediatamente**; abrir Onda 38.2.1-AR1 |
| RVS falhar ou alterar contadores | abrir investigação separada antes da 38.2.2 |

Âncora absoluta de restauração: anchor git `a6ad842`, workbook validado
pós-Onda 38.1.5 com build `696a8c2+ONDA38.1.5-rel-emp-serv-protecao`.

---

## 7. Próxima onda

**38.2.2 — filtros do Menu Principal pela forma correta.** Pré-condição:
gate humano da 38.2.1 passar completo, inclusive teste explícito de
cadastro de empresa.

Arquitetura aprovada por Mauricio em chat 2026-05-26:

- Handlers nativos `TextBox16..TextBox22_Change` estáticos no `.frm`.
- Cada handler chama uma função filtro PURA stateless:
  ```vba
  Private Sub TextBox17_Change()
      FiltrarLista_Empresas Me.TextBox17.Text
  End Sub

  Private Sub FiltrarLista_Empresas(ByVal padrao As String)
      Dim arr() As String       ' LOCAL
      Dim i As Long              ' LOCAL — nunca global
      arr = Repo_Empresa.LerTodasEmpresasComoArray()
      Me.ListBox_Empresas.Clear
      For i = LBound(arr) To UBound(arr)
          If padrao = "" Or InStr(1, arr(i), padrao, vbTextCompare) > 0 Then
              Me.ListBox_Empresas.AddItem arr(i)
          End If
      Next i
  End Sub
  ```
- **Proibido:** `WithEvents` dinâmico para controles já existentes no
  designer; `Me.Controls.Add` para filtros; heurística por
  posição/coordenadas; `RemoveItem` destrutivo; uso de `cont`, `NItem`,
  `nLinhas`, `i` como globais em rotina de filtro; `On Error Resume Next`
  amplo.
- **Reuso:** verificar se `Util_Filtro_Lista.bas` já tem
  `FiltrarArrayPorTexto(arr, padrao)` reaproveitável.

Pré-trabalho da 38.2.2: deep-dive completo das lições UI/Forms
(M9, L22, L23, L24, M15, M16, M17) em
`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`.
