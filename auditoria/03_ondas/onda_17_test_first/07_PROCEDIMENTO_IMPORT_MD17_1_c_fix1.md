---
titulo: Procedimento de import MD-17.1.c-fix1 — canControles + RepoRoot
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — sessao 2
licenca-target: TPGL-v1.1
---

# 07 — Procedimento de import MD-17.1.c-fix1

## Tema

Fix do Quarteto reprovado em `VR_20260503_141832` apos o import original
MD-17.1.c. Sintaxe reprovada: `V1=171/0+V2_Smoke=19/4+V2_Canonica=23/0+E2E_Strikes=65/0`.
Dois bugs distintos, ambos no MD original, ambos no mesmo arquivo
(`Teste_V2_Roteiros.bas`).

## Causa raiz (2 bugs)

| Bug | Descricao | Impacto observado |
|---|---|---|
| **A** | `canControles` incluiu nomes de variaveis VBA `WithEvents` (`mTxtBusca`, `mTxtBuscaTopo`, `mTxtFiltroCredLista`) — NAO sao controles. Em `Credencia_Empresa` adicionalmente, `TxtFiltro_CredenciamentoServico` era apenas tentativa; controle real eh `CR_TxtFiltroListaDin` (fallback) | 4× `CS_UISMOKE_<FORM>_V1` viraram FALHA |
| **B** | `TV2_UI_RepoRoot` retornava `ThisWorkbook.Path & "\.."`, assumindo workbook em subdir `V12-202-Z003/`. Workbook na raiz do repo (CSV gerado em `\\Mac\Home\Projetos\Credenciamento\TesteV2_*.csv` confirma) | 4× `CS_UISMOKE_<FORM>_V4` viraram MANUAL_ASSISTIDO (skip por arquivo nao encontrado), inflando MANUAL=8 |

Evidencia: `\\Mac\Home\Projetos\Credenciamento\TesteV2_SMOKE_Falhas_TV2_20260503_141832.csv`
(raiz do repo) — 4 linhas FALHA confirmando os controles faltantes.

## Pre-condicoes

| Item | Esperado |
|---|---|
| Workbook ancora | Estado atual (com MICRO19 buggy importado) — Opcao A — OU `V12-202-Z003-onda17-md1b-fix2` restaurado — Opcao B |
| Build atual | `f7aa84f+ONDA17.MD1C-uismoke-readonly` (Opcao A) ou pre-MD-17.1.c (Opcao B) |
| Trust Center | Habilitado (mantido do MD original) |
| `src/vba/` ↔ `local-ai/vba_import/` | shasum batendo (validado pre-edit) |

## Opcoes de rollback (M14)

| Opcao | Acao | Esforco |
|---|---|---|
| **A (recomendada)** | Aplicar fix1 sobre estado atual via `ImportarPacoteV3_Delta "MICRO19-fix1"`. V3 sobrescreve idempotente. | 1 import, ~14m41s Quarteto |
| **B** | Restaurar workbook `V12-202-Z003-onda17-md1b-fix2` + 2 imports (MICRO19 e depois MICRO19-fix1) | 2 imports + restauracao manual; mais demorado |

Pacote MICRO19-fix1 contem **mesmos 2 arquivos** em ambas opcoes (Roteiros
corrigido + App_Release bumped). M14 trivialmente satisfeito — sem
ramificacao para divergir.

## Sequencia canonica respeitada (M11)

| Arquivo | sha1 |
|---|---|
| `src/vba/Teste_V2_Roteiros.bas` ↔ `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas` | `39ab90ad29446c6b490f496f9de428d31aed8879` |
| `src/vba/App_Release.bas` ↔ `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | `bd71793e92281384e8a6097b46354d9c5edd93ed` |

CRLF preservado. Sub/Function balance 19/19 + 10/10.

## Mudancas resumo

| Arquivo | Tipo | Linhas |
|---|---|---|
| `Teste_V2_Roteiros.bas` | canControles(1..4) corrigidas; TV2_UI_RepoRoot smart probing; comentario-vacina | 2694 → 2713 (+19) |
| `App_Release.bas` | bump APP_BUILD_IMPORTADO + GERADO_EM + comentario fix1 | 221 → 232 (+11) |

### canControles antes/depois

| Form | ANTES (FALHA) | DEPOIS (esperado OK) |
|---|---|---|
| Reativa_Entidade | `R_Lista,mTxtBusca` | `R_Lista` |
| Reativa_Empresa | `RM_Lista,mTxtBusca` | `RM_Lista` |
| Cadastro_Servico | `S_Cadastrar_SV,Descricao_SV,SV_Lista,S_Atividade,mTxtBuscaTopo` | `S_Cadastrar_SV,Descricao_SV,SV_Lista,S_Atividade` |
| Credencia_Empresa | `CR_Credenciar,CR_Lista,TxtFiltro_CredenciamentoServico,mTxtFiltroCredLista` | `CR_Credenciar,CR_Lista,CR_TxtFiltroListaDin` |

## Procedimento operacional (Opcao A recomendada)

### Passo 1 — Resetar VBE

VBE: `Executar > Redefinir`.

### Passo 2 — Rodar import V3 delta

Janela Imediato:

```
ImportarPacoteV3_Delta "MICRO19-fix1", "f7aa84f+ONDA17.MD1C-fix1-cancontroles-reporoot"
```

### Passo 3 — Compile manual

VBE: `Depurar > Compilar VBAProject` (0 erros esperado).

### Passo 4 — Validar build

```
?GetBuildImportado
```

Esperado: `f7aa84f+ONDA17.MD1C-fix1-cancontroles-reporoot`.

### Passo 5 — Quarteto

```
CT_ValidarRelease_QuartetoMinimo
```

Esperado APROVADO com sintaxe:

```
V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0
```

(Smoke 14 baseline + 13 OK novos = 27. MANUAL sobe de 1 para 5: 1 antigo
CS_E2E_REATIV2STRIKES + 4 novos CS_UISMOKE_<FORM>_V2 STRICT=False).

### Passo 6 — Verificar RESULTADO_QA_V2

| Cenario | Status esperado |
|---|---|
| `CS_UISMOKE_VBE_CANARY` | OK |
| 4× `CS_UISMOKE_<FORM>_V1` | **OK** (era FALHA) |
| 4× `CS_UISMOKE_<FORM>_V2` | MANUAL_ASSISTIDO (STRICT=False) |
| 4× `CS_UISMOKE_<FORM>_V3` | OK |
| 4× `CS_UISMOKE_<FORM>_V4` | **OK** (era MANUAL skip) |

### Passo 7 — Salvar workbook

Salvar como `V12-202-Z003-onda17-md1c-fix1`.

### Passo 8 — Reportar VR ao Claude

Cole no chat:
- ID da validacao (`VR_<timestamp>`)
- Sintaxe completa do Quarteto
- Status dos 4× CS_UISMOKE_<FORM>_V1 (esperado: OK)
- Status dos 4× CS_UISMOKE_<FORM>_V4 (esperado: OK; FALHA aqui significa drift estrutural maior que cosmetico — descobrimos em runtime)
- Lista de extras detectados em V2 por form (campo OBS dos 4 cenarios MANUAL)

## Criterios de sucesso MD-17.1.c-fix1

1. Compile manual passa limpo.
2. `GetBuildImportado` = `f7aa84f+ONDA17.MD1C-fix1-cancontroles-reporoot`.
3. Quarteto APROVADO com sintaxe `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0` (ou variante coerente com MANUAL=5).
4. 4× `CS_UISMOKE_<FORM>_V1` STATUS=OK (era FALHA).
5. 4× `CS_UISMOKE_<FORM>_V4` STATUS=OK (era MANUAL skip).
6. shasum batendo M11.

Cumpridos os 6: MD-17.1.c real fechado; proximo eh MD-17.1.d.I (Performance γ).

## Rollback do fix1

Se Quarteto reprovar de novo (FALHA inesperada em V4 por drift estrutural):

```
git restore src/vba/Teste_V2_Roteiros.bas src/vba/App_Release.bas
git restore local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas local-ai/vba_import/001-modulo/AAX-App_Release.bas
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO19-fix1.txt
rm auditoria/03_ondas/onda_17_test_first/07_PROCEDIMENTO_IMPORT_MD17_1_c_fix1.md
```

Reabrir backup `V12-202-Z003-onda17-md1b-fix2`. Reportar evidencia no chat.

## Licao destilada (M16 candidata, oficializar em MD-17.5)

**M16 candidata — `WithEvents <var>` em VBA NAO eh nome de controle**

Quando enumerar controles canonicos de um UserForm via grep no `.frm`, NAO
usar nomes de variaveis declaradas com `Private WithEvents <var> As MSForms.X`.
Essas sao variaveis de modulo que recebem ponteiro para um controle real
em runtime via `Set <var> = Me.Controls("<actual_name>")`. O nome real do
controle vem do .frx (binario) ou eh o argumento de `Me.Controls("...")`.

Anti-padrao: `canControles = "R_Lista,mTxtBusca"` (mTxtBusca eh variavel)
Padrao: `canControles = "R_Lista"` + observar fallbacks via grep
`Set <var> = Me.Controls("...")`.

## Documentos relacionados

- [`.hbn/readbacks/0014-onda17-md17-1-c-real.json`](../../../.hbn/readbacks/0014-onda17-md17-1-c-real.json) (readback original do MD-17.1.c)
- [`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO19-fix1.txt`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO19-fix1.txt)
- [`auditoria/03_ondas/onda_17_test_first/06_PROCEDIMENTO_IMPORT_MD17_1_c.md`](06_PROCEDIMENTO_IMPORT_MD17_1_c.md) (procedimento original; bugs descobertos pos-import)
- `TesteV2_SMOKE_Falhas_TV2_20260503_141832.csv` (raiz do repo) — evidencia das 4 falhas
- [`auditoria/00_status/45_ERRO_E_CORRECAO_FIX1_INCOMPLETO_MD17_1_b.md`](../../00_status/45_ERRO_E_CORRECAO_FIX1_INCOMPLETO_MD17_1_b.md) (M14 — pacote cobre todas opcoes)

## Versao

- v1.0 — 2026-05-03 — fix1 inicial.
