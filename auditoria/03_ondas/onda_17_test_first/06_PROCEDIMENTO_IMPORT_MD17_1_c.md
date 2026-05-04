---
titulo: Procedimento de import MD-17.1.c real — TV2_RunUiSmokeReadOnly (V1-V5)
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — sessao 2
licenca-target: TPGL-v1.1
---

# 06 — Procedimento de import MD-17.1.c real (Onda 17 Test-First)

## Tema

Smoke read-only de UI sobre 4 forms criticos (`Reativa_Entidade`,
`Reativa_Empresa`, `Cadastro_Servico`, `Credencia_Empresa`) com 5
verificacoes por form (V1-V5) sem instanciar `UserForm`. Cap M11 = 0
imports em forms na Onda 17 preservado.

## Pre-condicoes

| Item | Esperado |
|---|---|
| Workbook ancora | `V12-202-Z003-onda17-md1b-fix2` (apos `VR_20260503_031425`) |
| Build atual | `f7aa84f+ONDA17.MD1B-fix2-cenarios-aplicados` |
| Quarteto pre-import | APROVADO `V1=171/0+V2_Smoke=14/0+V2_Canonica=23/0+E2E_Strikes=65/0` (MANUAL=1) |
| Trust Center | Habilitado: "Confiar no acesso ao modelo de objeto do projeto VBA" |
| `src/vba/` ↔ `local-ai/vba_import/` | shasum batendo (validado pre-edit) |
| MD-17.1.b | concluida com fix2 |

> **Nota Trust Center**: V5_CANARY testa esse acesso. Se desabilitado,
> V5_CANARY=FALHA isolada e Quarteto reprova. Habilitar em
> Excel > Opcoes > Central de Confiabilidade > Configuracoes da Central
> de Confiabilidade > Configuracoes de Macro > "Confiar no acesso ao
> modelo de objeto do projeto VBA".

## Sequencia canonica respeitada (M11)

`src/vba/` e fonte de verdade; `local-ai/vba_import/` e espelho com
prefixos. Hashes confirmados (sha1, src/vba autoritativo):

| Arquivo | sha1 |
|---|---|
| `src/vba/Teste_V2_Roteiros.bas` ↔ `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas` | `97298c1c1b6130e0638a2cec479c6f3048bcdaa3` |
| `src/vba/App_Release.bas` ↔ `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | `79b55c4adcf8f715a7a0130dbb6e9417f2e794fd` |

CRLF preservado em ambos arquivos. **Forms (.frm/.frx/.code-only.txt)
NAO tocados** (cap M11 = 0).

## Mudancas resumo (2 arquivos no pacote VBA)

| Arquivo | Tipo | Linhas |
|---|---|---|
| `Teste_V2_Roteiros.bas` | +Public Sub `TV2_RunUiSmokeReadOnly` + 7 helpers Private `TV2_UI_*` + tabelas canonicas + wire-up dentro de `TV2_RunSmoke` | 2269 → 2694 (+425) |
| `App_Release.bas` | bump APP_BUILD_IMPORTADO + GERADO_EM + comentario MD-17.1.c real | 212 → 221 (+9) |

Detalhe tecnico em
[`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO19.txt`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO19.txt)
e readback formal em
[`.hbn/readbacks/0014-onda17-md17-1-c-real.json`](../../../.hbn/readbacks/0014-onda17-md17-1-c-real.json).

## 5 verificacoes V1-V5 por form

| V | Tema | Mecanismo | Severidade falha |
|---|---|---|---|
| V1 | Existencia controles canonicos hardcoded | `comp.Designer.Controls(nome)` | FALHA hard |
| V2 | Set equality controles (extras + faltantes) | iter `For Each ctl In comp.Designer.Controls` | MANUAL_ASSISTIDO neste MD (STRICT=False ate baseline empirico) |
| V3 | Helpers UI esperados existem no CodeModule | `cm.ProcStartLine(nome, vbext_pk_Proc=0)` | FALHA hard se missing (Q-MD17.1.c.2=A) |
| V4 | `.frm` ↔ `.code-only.txt` sincronizado | gamma tolerante: strip `'` + RTrim + lower-case fora de strings literais | FALHA hard se diverge alem do cosmetico |
| V5_CANARY | VBE.ActiveVBProject acessivel | `Application.VBE.ActiveVBProject.VBComponents.count` | FALHA hard isolada (V1-V3 viram MANUAL para evitar 12 falhas redundantes) |

### Listas canonicas hardcoded (derivadas de grep nos .frm em src/vba/)

| Form | Controles canonicos |
|---|---|
| Reativa_Entidade | `R_Lista, mTxtBusca` |
| Reativa_Empresa | `RM_Lista, mTxtBusca` |
| Cadastro_Servico | `S_Cadastrar_SV, Descricao_SV, SV_Lista, S_Atividade, mTxtBuscaTopo` |
| Credencia_Empresa | `CR_Credenciar, CR_Lista, TxtFiltro_CredenciamentoServico, mTxtFiltroCredLista` |

| Form | Helpers UI canonicos (Public/Private Sub|Function) |
|---|---|
| Reativa_Entidade | UI_TextBoxSeExiste, UI_PegarTextBoxBuscaTopoDireita, UI_SafeListVal, UI_LinhaEntidadeValida, UI_TextoEntidadeParaFiltro, UI_LinhaEntidadePassaFiltro, UI_ChaveNormalizadaId, UI_EntidadeInativasTemConflito, UI_AjustarAlturaListaEntInativ, UI_PreencherListaEntidadesInativas, UserForm_Initialize, mTxtBusca_Change, R_Lista_DblClick |
| Reativa_Empresa | UI_TextBoxSeExiste, UI_PegarTextBoxBuscaTopoDireita, UI_SafeListVal, UI_LinhaEmpresaValida, UI_TextoEmpresaParaFiltro, UI_LinhaEmpresaPassaFiltro, UI_ChaveNormalizadaId, UI_EmpresaInativosTemConflito, UI_PreencherListaEmpresasInativas, UserForm_Initialize, mTxtBusca_Change, RM_Lista_DblClick |
| Cadastro_Servico | UI_TextBoxSeExiste, UI_PegarTextBoxBuscaTopoDireita, S_Cadastrar_SV_Click, Descricao_SV_KeyPress, Descricao_SV_AfterUpdate, SV_Lista_Click, S_Atividade_Change, S_Atividade_AfterUpdate, UserForm_Initialize, mTxtBuscaTopo_Change, ServicoJaExiste, Pad3 |
| Credencia_Empresa | UserForm_Initialize, CR_EnsureFiltroListaDinamico, mTxtFiltroCredLista_Change, CR_Credenciar_Click, CR_Lista_Click, DefinirEmpresaSelecionada, PrepararListaCredenciamentoServico, DefinirListaCredenciamentoServico, CredJaExiste, NormalizarCodAtivServ, ProximaPosicaoAtividade, CarregarDadosEmpresaSelecionada, ValidarPersistenciaCredenciamento, IdsIguaisCred, Pad3 |

## Cenarios novos esperados em RESULTADO_QA_V2

| Suite | Cenario | Status esperado |
|---|---|---|
| `SMOKE` | `CS_UISMOKE_VBE_CANARY` | **OK** (FALHA se Trust Center desabilitado) |
| `SMOKE` | `CS_UISMOKE_<FORM>_V1` (4x) | OK |
| `SMOKE` | `CS_UISMOKE_<FORM>_V2` (4x) | **MANUAL_ASSISTIDO** (STRICT=False; diff em obs) |
| `SMOKE` | `CS_UISMOKE_<FORM>_V3` (4x) | OK |
| `SMOKE` | `CS_UISMOKE_<FORM>_V4` (4x) | OK |

Total novo: **17 cenarios** (1 + 4×4). 13 OK + 4 MANUAL.

Sintaxe Quarteto esperada (aproximada):
`V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0`
(Smoke baseline 14 + 13 OK = 27; MANUAL sobe de 1 para 5).

> **Nota sobre V2 STRICT=False**: Os 4 cenarios CS_UISMOKE_<FORM>_V2
> ficam MANUAL_ASSISTIDO neste MD porque a lista canonica de controles
> e derivada de codigo (Me.Controls, WithEvents, event handlers) e pode
> nao incluir labels visuais ou outros controles em .frx nao
> referenciados em codigo. O OBS de cada V2 mostra `extras=[...]
> faltantes=[...]`. **Apos primeiro run, atualizar `canControles(N)`
> em Roteiros para incluir extras legitimos e flipar `STRICT=True`
> em MD futura** quando lista estabilizada empiricamente.

## Procedimento operacional

### Passo 0 — Validar Trust Center

Excel > Opcoes > Central de Confiabilidade > Configuracoes da Central
de Confiabilidade > Configuracoes de Macro > marcar **"Confiar no
acesso ao modelo de objeto do projeto VBA"**. Se desmarcado, V5_CANARY
falha e Quarteto reprova.

### Passo 1 — Resetar VBE (sempre, L7)

VBE: `Executar > Redefinir` (ou Ctrl+Pause/Break). Garante que
`Depurar > Compilar` esta habilitado.

### Passo 2 — Rodar o import V3 delta

Janela Imediato:

```
ImportarPacoteV3_Delta "MICRO19", "f7aa84f+ONDA17.MD1C-uismoke-readonly"
```

Importa 2 arquivos modificados:

- `001-modulo/ABG-Teste_V2_Roteiros.bas` (substitui)
- `001-modulo/AAX-App_Release.bas` (substitui)

### Passo 3 — Compile manual

VBE: `Depurar > Compilar VBAProject`. Esperado: zero erros.

Sintomas de regressao:

| Sintoma | Causa provavel |
|---|---|
| `Sub or Function not defined: TV2_UI_VbeCanary` | Roteiros nao importou; refazer Passo 2 |
| `Compile error: Variable not defined` em `TV2_UI_*` | Mismatch L14 nao detectado — abortar e reportar |
| `Object doesn't support this property or method` em `Application.VBE` | VBE Extensibility nao referenciada em Tools>References — adicionar "Microsoft Visual Basic for Applications Extensibility 5.3" |

### Passo 4 — Validar build importado

```
?GetBuildImportado
```

Esperado: `f7aa84f+ONDA17.MD1C-uismoke-readonly`.

### Passo 5 — Quarteto Minimo (gate principal)

Janela Imediato ou Central V12 [3]:

```
CT_ValidarRelease_QuartetoMinimo
```

Esperado:

- `RESULTADO_GERAL = APROVADO`
- `V1=171/0` (regressao zero V1)
- `V2_Smoke=27/0` ou similar (14 baseline + 13 OK novos; valor exato depende de V2 detectar extras)
- `V2_Canonica=23/0` (regressao zero)
- `E2E_Strikes=65/0` (regressao zero)
- MANUAL pode subir de 1 para 5

### Passo 6 — Verificar cenarios novos em RESULTADO_QA_V2

Filtrar por `CS_UISMOKE_*`. Esperado:

- `CS_UISMOKE_VBE_CANARY` STATUS=OK
- 4× `CS_UISMOKE_<FORM>_V1` STATUS=OK
- 4× `CS_UISMOKE_<FORM>_V2` STATUS=MANUAL_ASSISTIDO (com diff em OBS)
- 4× `CS_UISMOKE_<FORM>_V3` STATUS=OK
- 4× `CS_UISMOKE_<FORM>_V4` STATUS=OK

### Passo 7 — Salvar workbook ancora

Salvar como `V12-202-Z003-onda17-md1c` (apos APROVADO).

### Passo 8 — Reportar VR ao Claude

Cole no chat:

- ID da validacao (`VR_<timestamp>`)
- Sintaxe completa do Quarteto
- Lista de extras detectados em V2 por form (campo OBS dos 4 cenarios MANUAL) — input para atualizar `canControles` em MD futura
- `?GetBuildImportado`

## Criterios de sucesso MD-17.1.c real

1. Compile manual passa limpo.
2. `GetBuildImportado` = `f7aa84f+ONDA17.MD1C-uismoke-readonly`.
3. `CT_ValidarRelease_QuartetoMinimo` APROVADO (regressao zero).
4. CS_UISMOKE_VBE_CANARY com STATUS=OK.
5. 12 cenarios `CS_UISMOKE_<FORM>_V1/V3/V4` com STATUS=OK.
6. 4 cenarios `CS_UISMOKE_<FORM>_V2` com STATUS=MANUAL_ASSISTIDO (com diff em OBS).
7. Sintaxe SMOKE mostra OK + MANUAL coerentes (ex: 27/0 + MANUAL=5).
8. shasum batendo M11 (validado no Passo 0 deste documento).

Cumpridos todos os 8: MD-17.1.c real fechado, proximo e MD-17.1.d.I
(Performance gamma).

## Rollback

Se Quarteto reprovar (FAIL>0 alem do esperado) ou Excel crashar:

```
git restore src/vba/Teste_V2_Roteiros.bas
git restore src/vba/App_Release.bas
git restore local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas
git restore local-ai/vba_import/001-modulo/AAX-App_Release.bas
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO19.txt
rm auditoria/03_ondas/onda_17_test_first/06_PROCEDIMENTO_IMPORT_MD17_1_c.md
# .hbn/readbacks/0014-onda17-md17-1-c-real.json fica preservado para postmortem
```

Reabrir backup `V12-202-Z003-onda17-md1b-fix2`. Reportar evidencia no chat.

## M14 pre-flight (verificacao de coerencia)

Esta MD nao oferece multiplas opcoes de rollback (so uma: voltar para
fix2). Pacote MICRO19 contem exatamente os 2 arquivos modificados desde
checkpoint estavel. M14 trivialmente satisfeito (sem ramificacao para
divergir).

## Documentos relacionados

- [`.hbn/readbacks/0014-onda17-md17-1-c-real.json`](../../../.hbn/readbacks/0014-onda17-md17-1-c-real.json)
- [`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO19.txt`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO19.txt)
- [`auditoria/03_ondas/onda_17_test_first/05_PROCEDIMENTO_IMPORT_MD17_1_c_pre.md`](05_PROCEDIMENTO_IMPORT_MD17_1_c_pre.md) (tentativa anterior revertida; informa tolerancia gamma)
- [`auditoria/00_status/45_ERRO_E_CORRECAO_FIX1_INCOMPLETO_MD17_1_b.md`](../../00_status/45_ERRO_E_CORRECAO_FIX1_INCOMPLETO_MD17_1_b.md) (M14 oficial)
- [`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`](../../../usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md) (L14, L7, M9, M11, M14)

## Versao

- v1.0 — 2026-05-03 — procedimento inicial MD-17.1.c real.
