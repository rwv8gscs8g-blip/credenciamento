---
titulo: Procedimento de import MD-17.1.a — Engine FixtureFactory + namespacing
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1
---

# 01 — Procedimento de import MD-17.1.a (Onda 17 Test-First)

## Tema

Mecânica de fixture isolada por namespace + helper `TV2_RestaurarConfigBaseline`
generalizado + promoção de `TV2_NextDataRow` para Public, conforme readback
[`.hbn/readbacks/0013-onda17-test-first.json`](../../../.hbn/readbacks/0013-onda17-test-first.json).

## Pré-condições

| Item | Esperado |
|---|---|
| Workbook ancora | `V12-202-Z003/02_05_2026 20_43_09PlanilhaCredenciamento-Homologacao-V3.xlsm` |
| Build atual | `f7aa84f+ONDA16.MD3-fix1-evolucao-testes-incremental` |
| Quarteto pré-import | APROVADO (`VR_20260502_222849`) |
| `src/vba/` ↔ `local-ai/vba_import/` | shasum batendo (3 arquivos do MICRO16) |
| Hearback Q-MD17.1.a.1 a Q-MD17.1.a.3 | `confirmed` (alternativa a em todos) |

## Sequência canônica respeitada (M11)

```
src/vba/<arquivo>.bas    (fonte de verdade — AGENTS.md §62-63)
        ↓ cp + shasum batendo
local-ai/vba_import/001-modulo/<prefixo>-<arquivo>.bas    (espelho)
        ↓ ImportarPacoteV3_Delta
workbook .xlsm    (consumidor final)
```

**Hashes confirmados** (sha1, src/vba autoritativo):

| Arquivo | sha1 |
|---|---|
| `src/vba/Teste_V2_Engine.bas` ↔ `local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas` | `c44d5cbc5c0a9752681fd742b4f0553a7a1ba193` |
| `src/vba/Teste_V2_Roteiros.bas` ↔ `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas` | `eb7801aba24a76644e3c0847b0e6a883f0c05f61` |
| `src/vba/App_Release.bas` ↔ `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | `8baa22279722d32179f8a53e9a53a70b8f5e7302` |

CRLF preservado em todos os 6 arquivos (validado via `file`).

## Mudanças resumo (3 arquivos)

| Arquivo | Tipo | Linhas |
|---|---|---|
| `Teste_V2_Engine.bas` | +TV2_NextDataRow Public; +TV2_RestaurarConfigBaseline; +TV2_LimparNamespace + helper privado; +TV2_FixtureFactory + 5 helpers privados | 2647 → 2956 (+309) |
| `Teste_V2_Roteiros.bas` | -TV2_E2E_NextDataRow (Private); -TV2_E2E_RestaurarConfigBaseline (Private); 4 substituições de chamadas pelos helpers Public do Engine; bloco de comentário-histórico | 1909 → 1882 (-27) |
| `App_Release.bas` | bump APP_BUILD_IMPORTADO + APP_BUILD_GERADO_EM | 187 → 190 (+3) |

Detalhe técnico completo no manifesto
[`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO16.txt`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO16.txt).

## Procedimento operacional

### Passo 1 — Resetar VBE (sempre, L7)

No VBE: `Executar > Redefinir` (ou Ctrl+Pause/Break). Garante que `Depurar > Compilar`
está habilitado depois.

### Passo 2 — Rodar o import V3 delta

Janela Imediato do VBE:

```
ImportarPacoteV3_Delta "MICRO16", "f7aa84f+ONDA17.MD1A-fixture-factory-namespacing"
```

Isso processa o manifesto `000-MANIFESTO-V3-DELTA-MICRO16.txt` e importa os
3 arquivos modificados em modo Estabilizado:

- `001-modulo/ABF-Teste_V2_Engine.bas` (substitui o módulo existente)
- `001-modulo/ABG-Teste_V2_Roteiros.bas` (substitui)
- `001-modulo/AAX-App_Release.bas` (substitui)

### Passo 3 — Compile manual

VBE: `Depurar > Compilar VBAProject`. Esperado: zero erros.

Sintomas que indicariam regressão:

| Sintoma | Causa provável |
|---|---|
| `Sub or Function not defined: TV2_RestaurarConfigBaseline` | Engine não importou; refazer Passo 2 |
| `Sub or Function not defined: TV2_NextDataRow` em Roteiros | Engine importou versão antiga (Private mantido); refazer |
| `Compile error: Variable not defined` em qualquer ponto | Mismatch L14 não detectado — abortar e reportar com print |

### Passo 4 — Validar build importado

Janela Imediato:

```
?GetBuildImportado
```

Esperado: `f7aa84f+ONDA17.MD1A-fixture-factory-namespacing`.

### Passo 5 — Smoke teste do TV2_NextDataRow Public (sanity check da promoção)

Janela Imediato:

```
?TV2_NextDataRow("EMPRESAS")
```

Esperado: número inteiro positivo (próxima linha de dados da aba EMPRESAS).
Se acusar `Method or data member not found`, a promoção Private→Public falhou.

### Passo 6 — Smoke teste do FixtureFactory (opcional, mas recomendado)

Janela Imediato:

```
TV2_LimparNamespace "TFF"
Dim eo() As String, mo() As String, ao() As String
TV2_FixtureFactory "TFF", 0, 2, 1, eo, mo, ao
?mo(1)
?mo(2)
?ao(1)
TV2_LimparNamespace "TFF"
```

Esperado:

- `mo(1)` retorna `TFF_001`
- `mo(2)` retorna `TFF_002`
- `ao(1)` retorna `F_TFF_01`
- Após `TV2_LimparNamespace "TFF"` final, `EMPRESAS` não contém linhas com
  `EMP_ID` começando por `TFF_`, e `ATIVIDADES` não contém `F_TFF_01`.

### Passo 7 — Quarteto Mínimo (gate intermediário)

Janela Imediato ou Central V12 [3]:

```
CT_ValidarRelease_QuartetoMinimo
```

Esperado: APROVADO com sintaxe `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0`.

**Se o Quarteto reprovar**: rollback obrigatório (M10 cap iterações). Ver §Rollback.

### Passo 8 — Salvar workbook ancora

Salvar como `V12-202-Z003-onda17-md1a` (ou convenção local) **somente após
Quarteto APROVADO**.

### Passo 9 — Reportar VR (validação) ao Claude

Operador cola no chat:

- ID da validação (`VR_<timestamp>`)
- Sintaxe completa do Quarteto
- Confirmação de smoke testes 5+6 (se executados)
- Build importado conferido (`?GetBuildImportado`)

## Critérios de sucesso MD-17.1.a

1. Compile manual passa limpo.
2. `GetBuildImportado` = `f7aa84f+ONDA17.MD1A-fixture-factory-namespacing`.
3. `TV2_NextDataRow("EMPRESAS")` retorna número (Public OK).
4. `TV2_FixtureFactory "TFF", 0, 2, 1, eo, mo, ao` cria 2 empresas + 1 atividade
   com IDs prefixados, `TV2_LimparNamespace "TFF"` limpa.
5. `CT_ValidarRelease_QuartetoMinimo` APROVADO (regressão zero).

Cumpridos todos os 5: MD-17.1.a fechado, próximo é MD-17.1.b (5 cenários novos).

## Rollback

Se Quarteto reprovar ou Excel crashar:

```
git restore src/vba/Teste_V2_Engine.bas
git restore src/vba/Teste_V2_Roteiros.bas
git restore src/vba/App_Release.bas
git restore local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas
git restore local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas
git restore local-ai/vba_import/001-modulo/AAX-App_Release.bas
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO16.txt
```

Reabrir backup `V12-202-Z003` original (operador). Reportar evidência no chat
para Opus replanejar MD-17.1.a com hearback.

## Documentos relacionados

- [`.hbn/readbacks/0013-onda17-test-first.json`](../../../.hbn/readbacks/0013-onda17-test-first.json)
- [`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO16.txt`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO16.txt)
- [`auditoria/00_status/43_HANDOFF_NOVA_SESSAO_2026_05_03_TEST_FIRST.md`](../../00_status/43_HANDOFF_NOVA_SESSAO_2026_05_03_TEST_FIRST.md)
- [`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`](../../../usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md) (L16, M11)

## Versão

- v1.0 — 2026-05-03 — procedimento inicial MD-17.1.a.
