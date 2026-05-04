---
titulo: Procedimento de import MD-17.1.c-pre — Sincronia M11 dos 4 .code-only.txt
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1
---

# 05 — Procedimento de import MD-17.1.c-pre

## Tema

Sincronia **M11 enforcement** dos 4 `.code-only.txt` em
`local-ai/vba_import/002-formularios/` com os respectivos `.frm` em
`src/vba/`. Pré-requisito da MD-17.1.c real (TV2_RunUiSmokeReadOnly),
cuja verificação V4 valida essa sincronia como invariante.

## Por que esta MD existe

Pre-flight L14 da MD-17.1.c detectou drift entre `.frm` (autoritativo,
M11) e `.code-only.txt` (espelho) nos 4 forms-alvo. Drift residual da
MD-16.6 cancelada/quarentenada que **não foi limpo** no transplante
43b. M11 exige sincronia → esta MD regenera `.code-only.txt` a partir
do `.frm`.

| Form | Drift detectado |
|---|---|
| Reativa_Entidade | 25 linhas (3 comentários + capitalização Cont/cont) |
| Reativa_Empresa | 27 linhas (mesmo padrão) |
| Cadastro_Servico | 4 linhas (trailing whitespace) |
| Credencia_Empresa | 4 linhas (trailing whitespace) |

## Pré-condições

| Item | Esperado |
|---|---|
| Workbook | `V12-202-Z003-onda17-md1b-fix2` (após `VR_20260503_031425`) |
| Build atual | `f7aa84f+ONDA17.MD1B-fix2-cenarios-aplicados` |
| Quarteto pré-pre | APROVADO |

## Pacote (5 arquivos)

| Arquivo | sha1 |
|---|---|
| `src/vba/App_Release.bas` ↔ `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | `e66add0912e9bd24e07560f327139f4f108cc44a` |
| `local-ai/vba_import/002-formularios/AAF-Reativa_Entidade.code-only.txt` | `d3296c660324ddfb5d5f0ce25a921df277c8a1f9` |
| `local-ai/vba_import/002-formularios/AAH-Reativa_Empresa.code-only.txt` | `96f416b62be94ab93ba2de12f2dd654635ee4138` |
| `local-ai/vba_import/002-formularios/AAD-Cadastro_Servico.code-only.txt` | `602d6633f10f9e08a0e886591fd8af70f737ee0a` |
| `local-ai/vba_import/002-formularios/AAI-Credencia_Empresa.code-only.txt` | `84d1bfe1d5509e3e5c9260bb55053861aad290b3` |

Backups dos `.code-only.txt` anteriores em `*.pre-md17-1-c-pre.bak` no mesmo diretório.

## Sobre cap M10

Cap M10 visa proteger contra iteração rápida em forms causando
inconsistência interna. Aqui **não há edição de forms** — apenas
sincronia textual de espelhos `.code-only.txt` com a fonte `.frm` já
validada em `V12-202-Z003`. V3 em modo Estabilizado importa
`.code-only.txt` substituindo só o código do form (sem tocar `.frx`).
Como o código já estava no workbook (via `.frm`), esta operação **não
introduz código novo** — apenas remove drift residual.

## Procedimento operacional

| # | Comando |
|---|---|
| 1 | VBE: `Executar > Redefinir` |
| 2 | `ImportarPacoteV3_Delta "MICRO18-pre", "f7aa84f+ONDA17.MD1C-pre-codeonly-sync-m11"` |
| 3 | `Depurar > Compilar VBAProject` (zero erros esperado) |
| 4 | `?GetBuildImportado` → `f7aa84f+ONDA17.MD1C-pre-codeonly-sync-m11` |
| 5 | `CT_ValidarRelease_QuartetoMinimo` |
| 6 | Esperado: APROVADO **com sintaxe IDÊNTICA a fix2** — `V1=171/0+V2_Smoke=14/0+V2_Canonica=23/0+E2E_Strikes=65/0` (regressão zero) |
| 7 | Salvar como `V12-202-Z003-onda17-md1c-pre` (apenas após APROVADO) |
| 8 | Reportar VR + sintaxe |

## Critérios de sucesso

1. Compile passa limpo.
2. `GetBuildImportado` = `f7aa84f+ONDA17.MD1C-pre-codeonly-sync-m11`.
3. **Quarteto APROVADO com sintaxe IDÊNTICA** a `VR_20260503_031425` (fix2): `V2_Canonica=23/0`, `E2E_Strikes=65/0` (MANUAL=1).
4. Tempo do Quarteto na faixa de 14-15 minutos (mesmo nível do fix2 — base de comparação para MD-17.1.d.I).

Cumpridos os 4 → MD-17.1.c-pre fechada → MD-17.1.c real (TV2_RunUiSmokeReadOnly) próxima.

## Rollback

Se Quarteto reprovar (não esperado, mas para registro):

```
git restore src/vba/App_Release.bas
git restore local-ai/vba_import/001-modulo/AAX-App_Release.bas
# Restaurar .code-only.txt do backup .bak:
for f in AAF-Reativa_Entidade AAH-Reativa_Empresa AAD-Cadastro_Servico AAI-Credencia_Empresa; do
  cot="local-ai/vba_import/002-formularios/$f.code-only.txt"
  bak="$cot.pre-md17-1-c-pre.bak"
  cp "$bak" "$cot"
done
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO18-pre.txt
```

Reabrir backup `V12-202-Z003-onda17-md1b-fix2`. Reportar evidência.

## Documentos relacionados

- [`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO18-pre.txt`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO18-pre.txt)
- [`auditoria/00_status/45_ERRO_E_CORRECAO_FIX1_INCOMPLETO_MD17_1_b.md`](../../00_status/45_ERRO_E_CORRECAO_FIX1_INCOMPLETO_MD17_1_b.md) (M14)
- [`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`](../../../usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md) (M9 + M11)

## Versão

- v1.0 — 2026-05-03 — pre-sincronia inicial.
