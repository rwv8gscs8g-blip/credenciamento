---
titulo: Procedimento de import MD-17.1.c-fix2 — TxtFiltro dinamico + VB_Exposed cut
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — sessao 2
licenca-target: TPGL-v1.1
---

# 08 — Procedimento de import MD-17.1.c-fix2

## Tema

Fix do Quarteto reprovado em `VR_20260503_152729` apos fix1
(`V1=171/0+V2_Smoke=23/5+V2_Canonica=23/0+E2E_Strikes=65/0`). 2 bugs nao
isolados em fix1.

## Causa raiz (2 bugs)

| Bug | Descricao | Impacto observado |
|---|---|---|
| **C** | Em `Credencia_Empresa`, `CR_EnsureFiltroListaDinamico` cria textbox via `Me.Controls.Add("Forms.TextBox.1", "TxtFiltro_CredenciamentoServico", True)` em runtime se nem `TxtFiltro_CredenciamentoServico` nem `CR_TxtFiltroListaDin` existem. Smoke read-only (sem instanciar form) **nunca ve** o textbox | `CS_UISMOKE_Credencia_Empresa_V1` FALHA |
| **D** | `TV2_UI_LerSecaoCodigoFrm` cortava em "Attribute VB_Name" — incluindo 5 attributes de form (VB_Name, VB_GlobalNameSpace, VB_Creatable, VB_PredeclaredId, VB_Exposed) que NAO existem no .code-only.txt. Diff sistematico ~170 chars | 4× `CS_UISMOKE_<FORM>_V4` FALHA |

## Validacao pre-import via bash (simulacao do gamma)

| Form | Resultado |
|---|---|
| Reativa_Entidade | **GAMMA MATCH** (11911 chars) |
| Reativa_Empresa | **GAMMA MATCH** (12347 chars) |
| Cadastro_Servico | **GAMMA MATCH** (8540 chars) |
| Credencia_Empresa | **GAMMA MATCH** (12809 chars) |

Alta confianca de que V4 vai passar OK nos 4 forms apos fix2.

## Pre-condicoes

| Item | Esperado |
|---|---|
| Workbook ancora | Estado atual (com MICRO19+fix1 buggy importado) — Opcao A |
| Build atual | `f7aa84f+ONDA17.MD1C-fix1-cancontroles-reporoot` |
| Trust Center | Habilitado |
| `src/vba/` ↔ `local-ai/vba_import/` | shasum batendo (validado pre-edit) |

## Sequencia canonica respeitada (M11)

| Arquivo | sha1 |
|---|---|
| `src/vba/Teste_V2_Roteiros.bas` ↔ `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas` | `34b2a558be680cabef39378343987c2e6b6b2ba4` |
| `src/vba/App_Release.bas` ↔ `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | `35ce032e4398f64c9f34f231cab57f292be9598e` |

CRLF preservado. Sub/Function balance 19/19 + 10/10.

## Mudancas resumo

| Arquivo | Tipo | Linhas |
|---|---|---|
| `Teste_V2_Roteiros.bas` | canControles(4) reduzido + TV2_UI_LerSecaoCodigoFrm refatorado para anchor "Attribute VB_Exposed" | 2713 → 2740 (+27) |
| `App_Release.bas` | bump APP_BUILD_IMPORTADO + GERADO_EM + comentario fix2 | 232 → 245 (+13) |

### canControles antes/depois

| Form | fix1 (FALHA em Credencia) | fix2 (esperado OK) |
|---|---|---|
| Credencia_Empresa | `CR_Credenciar,CR_Lista,CR_TxtFiltroListaDin` | `CR_Credenciar,CR_Lista` |

(Outros 3 forms inalterados.)

### TV2_UI_LerSecaoCodigoFrm antes/depois

| Antes (fix1) | Depois (fix2) |
|---|---|
| Cortava em `Attribute VB_Name` (incluia 5 attrs de form) | Corta APOS `Attribute VB_Exposed` (pula header completo + 5 attrs) |
| Diff residual ~170 chars vs .code-only.txt | Match exato pos-gamma |

## Procedimento operacional (Opcao A recomendada)

### Passo 1 — Resetar VBE

VBE: `Executar > Redefinir`.

### Passo 2 — Rodar import V3 delta

Janela Imediato:

```
ImportarPacoteV3_Delta "MICRO19-fix2", "f7aa84f+ONDA17.MD1C-fix2-textofiltro-dinamico-vbexposed"
```

### Passo 3 — Compile manual

VBE: `Depurar > Compilar VBAProject` (0 erros esperado).

### Passo 4 — Validar build

```
?GetBuildImportado
```

Esperado: `f7aa84f+ONDA17.MD1C-fix2-textofiltro-dinamico-vbexposed`.

### Passo 5 — Quarteto

```
CT_ValidarRelease_QuartetoMinimo
```

Esperado APROVADO com sintaxe:

```
V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0
```

(Smoke 14 baseline + 13 OK novos = 27. MANUAL=5: 1 antigo CS_E2E_REATIV2STRIKES + 4 V2 STRICT=False.)

### Passo 6 — Verificar RESULTADO_QA_V2

| Cenario | Status esperado |
|---|---|
| `CS_UISMOKE_VBE_CANARY` | OK |
| 4× `CS_UISMOKE_<FORM>_V1` | **OK** (Credencia_Empresa era FALHA, agora OK) |
| 4× `CS_UISMOKE_<FORM>_V2` | MANUAL_ASSISTIDO (STRICT=False) |
| 4× `CS_UISMOKE_<FORM>_V3` | OK |
| 4× `CS_UISMOKE_<FORM>_V4` | **OK** (era FALHA, agora OK pos-gamma fix) |

### Passo 7 — Salvar workbook

Salvar como `V12-202-Z003-onda17-md1c-fix2`.

### Passo 8 — Reportar VR ao Claude

Cole no chat:
- ID da validacao (`VR_<timestamp>`)
- Sintaxe completa do Quarteto
- Status dos 4× CS_UISMOKE_<FORM>_V4 (esperado: OK)
- Status do CS_UISMOKE_Credencia_Empresa_V1 (esperado: OK)
- Lista de extras detectados em V2 por form (campo OBS dos 4 cenarios MANUAL)

## Criterios de sucesso MD-17.1.c-fix2

1. Compile manual passa limpo.
2. `GetBuildImportado` = `f7aa84f+ONDA17.MD1C-fix2-textofiltro-dinamico-vbexposed`.
3. Quarteto APROVADO `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0`.
4. 4× `CS_UISMOKE_<FORM>_V4` STATUS=OK (era FALHA).
5. `CS_UISMOKE_Credencia_Empresa_V1` STATUS=OK (era FALHA).
6. shasum batendo M11.

Cumpridos os 6: MD-17.1.c real fechado; proximo eh MD-17.1.d.I (Performance γ).

## Sobre o debito V18 (DT-17-REATIV-STRIKES)

O operador perguntou se o debito de reativacao de empresa (resolucao
prevista para Onda 18) estaria travando o Quarteto. **NAO**:

- DT-17-REATIV-STRIKES afeta APENAS `CS_E2E_REATIV2STRIKES` na suite
  `STRIKES_E2E` (E2E_Strikes=65/0+MANUAL=1 — passou).
- As falhas atuais sao todas em `V2_Smoke` nos cenarios novos
  `CS_UISMOKE_*` introduzidos por esta MD-17.1.c. Sao bugs do codigo
  novo, nao relacionados ao debito.
- Onda 18 resolve DT-17-REATIV-STRIKES de forma definitiva e
  independente — plano completo em
  `auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md`.

## Licao destilada (M16 candidata, oficializar em MD-17.5)

**M16 candidata — Controles dinamicos via `Me.Controls.Add` nao sao
detectaveis por smoke read-only**

Quando `UserForm.Initialize` (ou helper chamado por ele) cria controles
via `Me.Controls.Add(...)`, eles NAO existem no `.frx` estatico. Smoke
read-only (sem instanciar form) NUNCA ve esses controles. Devem ser
EXCLUIDOS de `canControles`. Detectar via grep `Me.Controls.Add` no
`.frm` correspondente.

**M17 candidata — Estrutura .frm vs .code-only.txt difere por 5
attributes de form**

`.frm` tem cabecalho `VERSION + Begin/End + 5× Attribute VB_<formattr>`.
`.code-only.txt` comeca DIRETO no codigo. Para comparacao alinhada,
cortar `.frm` APOS `Attribute VB_Exposed` (anchor da ultima linha do
header bloco).

## Rollback do fix2

Se Quarteto reprovar de novo:

```
git restore src/vba/Teste_V2_Roteiros.bas src/vba/App_Release.bas
git restore local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas local-ai/vba_import/001-modulo/AAX-App_Release.bas
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO19-fix2.txt
rm auditoria/03_ondas/onda_17_test_first/08_PROCEDIMENTO_IMPORT_MD17_1_c_fix2.md
```

Reabrir backup `V12-202-Z003-onda17-md1b-fix2`.

## Documentos relacionados

- [`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO19-fix2.txt`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO19-fix2.txt)
- [`auditoria/03_ondas/onda_17_test_first/06_PROCEDIMENTO_IMPORT_MD17_1_c.md`](06_PROCEDIMENTO_IMPORT_MD17_1_c.md) (original)
- [`auditoria/03_ondas/onda_17_test_first/07_PROCEDIMENTO_IMPORT_MD17_1_c_fix1.md`](07_PROCEDIMENTO_IMPORT_MD17_1_c_fix1.md) (fix1)
- `TesteV2_SMOKE_Falhas_TV2_20260503_152729.csv` (uploads — evidencia das 5 falhas)
- [`auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md`](../../00_status/44_DEBITO_DT_17_REATIV_STRIKES.md) (DT-17 — Onda 18)

## Versao

- v1.0 — 2026-05-03 — fix2 inicial.
