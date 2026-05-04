---
titulo: Procedimento de import MD-17.1.c-fix3 — gamma skip linhas vazias
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — sessao 2
licenca-target: TPGL-v1.1
---

# 09 — Procedimento de import MD-17.1.c-fix3

## Tema

Fix do Quarteto reprovado em `VR_20260503_155854` apos fix2
(`V1=171/0+V2_Smoke=23/4+V2_Canonica=23/0+E2E_Strikes=65/0`). Diff
residual de 2-3 chars nos 4 V4 gamma — causa raiz isolada via reproducao
bash do algoritmo VBA exato.

## Causa raiz (1 bug residual)

**BUG-E:** `.frm` tem 2-3 trailing newlines a mais que `.code-only.txt`.
Verificado via TAIL_HEX:

| Form | FRM tail (hex) | CO tail (hex) | Diff |
|---|---|---|---|
| Reativa_Entidade | `...end sub\n\n\n\n\n` | `...end sub\n\n\n` | 2 chars |
| Reativa_Empresa | `...end sub\n\n\n\n\n` | `...end sub\n\n\n` | 2 chars |
| Cadastro_Servico | `...end function\n\n\n\n\n\n` | `...end function\n\n\n` | 3 chars |
| Credencia_Empresa | `...end function\n\n\n\n\n\n` | `...end function\n\n\n` | 3 chars |

`NormalizarGammaTexto` preservava linhas em branco (strippava apenas
comentario inteira-linha). Os trailing `\n` viravam empty lines
preservadas no acc, causando diff sistematico.

**Fix**: regra (d) do gamma — apos RTrim, se linha == "", skip. Linhas
em branco nao mudam significado de codigo VBA.

## Validacao bash pre-import (reproducao do algoritmo VBA exato com fix3)

| Form | Resultado |
|---|---|
| Reativa_Entidade | **GAMMA MATCH** (11862 chars) |
| Reativa_Empresa | **GAMMA MATCH** (12299 chars) |
| Cadastro_Servico | **GAMMA MATCH** (8525 chars) |
| Credencia_Empresa | **GAMMA MATCH** (12774 chars) |

ALTISSIMA confianca de que V4 vai passar OK nos 4 forms.

## Pre-condicoes

| Item | Esperado |
|---|---|
| Workbook ancora | Estado atual (com MICRO19+fix1+fix2 importado) |
| Build atual | `f7aa84f+ONDA17.MD1C-fix2-textofiltro-dinamico-vbexposed` |
| `src/vba/` ↔ `local-ai/vba_import/` | shasum batendo |

## Sequencia M11

| Arquivo | sha1 |
|---|---|
| `src/vba/Teste_V2_Roteiros.bas` ↔ ABG | `51dfc67ccd059d9ebef3874ff969f1a63e15b571` |
| `src/vba/App_Release.bas` ↔ AAX | `ede3203cbf1d674c4bc7436abdf0317a9694a257` |

CRLF preservado. Sub/Function balance 19/19 + 10/10.

## Mudancas resumo

| Arquivo | Tipo | Linhas |
|---|---|---|
| `Teste_V2_Roteiros.bas` | TV2_UI_NormalizarGammaTexto + regra (d) skip linhas vazias | 2740 → 2746 (+6) |
| `App_Release.bas` | bump label fix3 + comentario | 245 → 255 (+10) |

## Procedimento operacional (Opcao A recomendada)

### Passo 1 — Resetar VBE

VBE: `Executar > Redefinir`.

### Passo 2 — Import V3 delta

```
ImportarPacoteV3_Delta "MICRO19-fix3", "f7aa84f+ONDA17.MD1C-fix3-gamma-skip-empty-lines"
```

### Passo 3 — Compile manual

VBE: `Depurar > Compilar VBAProject` (0 erros).

### Passo 4 — Validar build

```
?GetBuildImportado
```

Esperado: `f7aa84f+ONDA17.MD1C-fix3-gamma-skip-empty-lines`.

### Passo 5 — Quarteto

```
CT_ValidarRelease_QuartetoMinimo
```

Esperado APROVADO com sintaxe:

```
V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0
```

(Smoke 14 baseline + 13 OK novos = 27. MANUAL=5: 1 antigo CS_E2E_REATIV2STRIKES
+ 4 novos V2 STRICT=False.)

### Passo 6 — Verificar RESULTADO_QA_V2

| Cenario | Status esperado |
|---|---|
| `CS_UISMOKE_VBE_CANARY` | OK |
| 4× `CS_UISMOKE_<FORM>_V1` | OK |
| 4× `CS_UISMOKE_<FORM>_V2` | MANUAL_ASSISTIDO |
| 4× `CS_UISMOKE_<FORM>_V3` | OK |
| 4× `CS_UISMOKE_<FORM>_V4` | **OK** (era FALHA — fix3 absorve trailing whitespace) |

### Passo 7 — Salvar

`V12-202-Z003-onda17-md1c-fix3`.

### Passo 8 — Reportar

VR + sintaxe + status dos 4× V4 + extras V2.

## Criterios de sucesso MD-17.1.c-fix3

1. Compile manual passa limpo.
2. `GetBuildImportado` = `f7aa84f+ONDA17.MD1C-fix3-gamma-skip-empty-lines`.
3. Quarteto APROVADO `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0`.
4. 4× `CS_UISMOKE_<FORM>_V4` STATUS=OK.
5. shasum batendo M11.

Cumpridos os 5: MD-17.1.c real fechado; proximo eh MD-17.1.d.I.

## Licao M17 candidata (oficializar em MD-17.5)

**Gamma de comparacao textual entre arquivos VBA deve incluir skip de
linhas vazias para absorver trailing whitespace differences.**

`.frm` exportado pelo VBE pode ter trailing newlines diferentes do
`.code-only.txt` salvo. Diff de 2-3 trailing `\n` foi causa raiz de
falha sistematica em V4 (MD-17.1.c-fix2 → fix3). Linhas em branco no
meio do codigo tambem nao mudam significado — skip eh seguro.

## Rollback

```
git restore src/vba/Teste_V2_Roteiros.bas src/vba/App_Release.bas
git restore local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas local-ai/vba_import/001-modulo/AAX-App_Release.bas
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO19-fix3.txt
rm auditoria/03_ondas/onda_17_test_first/09_PROCEDIMENTO_IMPORT_MD17_1_c_fix3.md
```

## Documentos relacionados

- [`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO19-fix3.txt`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO19-fix3.txt)
- [`08_PROCEDIMENTO_IMPORT_MD17_1_c_fix2.md`](08_PROCEDIMENTO_IMPORT_MD17_1_c_fix2.md)
- `TesteV2_SMOKE_Falhas_TV2_20260503_155854.csv` (uploads — evidencia 4 V4)

## Versao

- v1.0 — 2026-05-03 — fix3 inicial.
