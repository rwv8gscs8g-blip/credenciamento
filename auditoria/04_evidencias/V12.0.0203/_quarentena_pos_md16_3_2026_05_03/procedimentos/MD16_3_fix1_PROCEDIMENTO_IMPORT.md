---
titulo: Procedimento MD-16.3 fix1 — refatoração InputBox CT2_AbrirCentral (limite line continuation)
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203 → ONDA16.MD3-fix1
data: 2026-05-02
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1 (Credenciamento)
---

# MD-16.3 fix1 — Procedimento de import (correção erro 40192)

## Diagnóstico

Tentativa de import do `MICRO15` falhou com `Err=40192` em
`ABE-Central_Testes_V2.bas`. Causa raiz: o `InputBox` em
`CT2_AbrirCentral` cresceu durante as ondas (MD-3.1 + MD-16.1 +
MD-16.3) e atingiu **25+ line continuations (`_`) consecutivas**, o
que quebra o VBE na importação programática (limite tipicamente
não documentado mas empiricamente ~25).

Estado atual do workbook após falha parcial:

| Módulo | Status no workbook |
|---|---|
| `ABL-Util_Evolucao.bas` | ✅ Importado (módulo novo presente) |
| `ABF-Teste_V2_Engine.bas` | ✅ Importado (com hook + DURACAO_MS) |
| `ABE-Central_Testes_V2.bas` | ❌ Versão antiga (MD-16.1, sem `[21]`) |
| `AAX-App_Release.bas` | ❌ Build label antigo (MD-16.2) |

## Solução

Refatorar `CT2_AbrirCentral` para acumular o prompt em variável
local `prompt` via concatenação linha-a-linha, eliminando line
continuations consecutivas. Comportamento funcional preservado.

| Campo | Valor |
|---|---|
| Microdelta | MD-16.3 fix1 |
| Build label | `f7aa84f+ONDA16.MD3-fix1-evolucao-testes-incremental` |
| Manifesto | `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO15-fix1.txt` |
| Arquivos modificados | `ABE-Central_Testes_V2.bas`, `AAX-App_Release.bas` |
| Espelho src/vba | sincronizado |
| Risco | Baixo — refatoração de string sem mudança funcional |

## Pre-flight L14 cumprido

- Zero line continuations consecutivas no novo `CT2_AbrirCentral`
- `Util_Evolucao_AbrirEMostrar` (handler `[21]`) já em ABL importado
- `CT_ValidarRelease_QuartetoMinimo` em ABH (Onda 11 MD-3)
- Sub/End Sub balanceados em ABE: 8/8
- Hashes batendo (canônico ↔ src/vba)

## Passos no Excel

1. Abrir workbook **atual** (estado pós-falha do MICRO15 — `V12-202-AC-onda16-md2`
   com 2 módulos do MD-16.3 já importados).
2. `?GetBuildImportado` (provavelmente: `…MD2-duracao-ms-incremental`
   — porque AAX não foi importado no MICRO15).
3. `ImportarPacoteV3_Delta "MICRO15-fix1", "f7aa84f+ONDA16.MD3-fix1-evolucao-testes-incremental"`.
4. Compile manual: `Debug → Compile VBAProject` (esperado: limpo).
5. `?GetBuildImportado` (esperado: `f7aa84f+ONDA16.MD3-fix1-evolucao-testes-incremental`).
6. **Validação visual da Central V2:**
   - `CT2_AbrirCentral`.
   - Confirmar menu hierárquico completo com `[21] EVOLUCAO_TESTES (regressao + media movel)` na seção `>> VISUALIZACAO`.
7. **Validação da opção `[21]`:**
   - Selecionar `[21]` no menu.
   - Confirmar abertura da sheet `EVOLUCAO_TESTES` (criada lazy se ainda não existe).
8. **Teste do hook automático:**
   - `TV2_RunSmoke` (~2 min).
   - Abrir `EVOLUCAO_TESTES` — deve haver 1 linha nova com EXECUCAO_ID + SUITE + DURACAO_MS.
9. **Repetir Smoke 2 vezes** para popular MEDIA_5_MS na 2ª/3ª linha.
10. **Gate de regressão zero:**
    - `CT_ValidarRelease_QuartetoMinimo`.
    - Esperado: APROVADO `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0`.
    - 3 linhas novas em `EVOLUCAO_TESTES` (V2_Smoke + V2_Canonica + E2E_Strikes; V1 não passa pela engine V2).
11. Salvar como `V12-202-AC-onda16-md3` (ou convenção local).

## Gate

MD-16.3 fix1 fica **APROVADO** quando:

- [ ] Import passa limpo (sem Err=40192)
- [ ] Compile manual limpo
- [ ] Build label `…MD3-fix1-evolucao-testes-incremental`
- [ ] `CT2_AbrirCentral` exibe menu com `[21]` na seção VISUALIZACAO
- [ ] Opção `[21]` abre sheet EVOLUCAO_TESTES
- [ ] Hook em TV2_RunSmoke grava linha em EVOLUCAO_TESTES
- [ ] MEDIA_5_MS calcula a partir da 2ª execução
- [ ] Quarteto retorna 171/0+14/0+20/0+64/0 (regressão zero)

## Lição L19 candidata (registrar em PHAGOCYTOSIS no MD-16.9)

**InputBox/MsgBox com mais de ~15 linhas de texto deve usar
variável local `prompt` acumulada via `&=` em vez de line
continuations consecutivas.** Limite empírico: ~25 `_` consecutivos
quebram VBE no import (Err=40192 = "Erro de definição de aplicativo
ou de objeto"). Padrão correto:

```text
Dim prompt As String
prompt = "linha 1" & vbCrLf
prompt = prompt & "linha 2" & vbCrLf
... (cresce livremente)
op = InputBox(prompt, "Titulo", "default")
```

Marker visual durante diagnóstico de erro 40192 em sub com InputBox
extenso: contar line continuations consecutivas. Se >20, refatorar
preventivamente.

## Rollback

```bash
git checkout src/vba/Central_Testes_V2.bas src/vba/App_Release.bas
git checkout local-ai/vba_import/001-modulo/ABE-Central_Testes_V2.bas
git checkout local-ai/vba_import/001-modulo/AAX-App_Release.bas
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO15-fix1.txt
```

Workbook ancora estável para retorno: `V12-202-AC-onda16-md2` (estado antes do MICRO15).

## Após APROVADO

Prosseguir para MD-16.4 (`Util_PDF.bas` com nomeação humano-legível
incluindo CNPJ + emissão automática + `TV2_RunPdfDeterminismo` +
`[22]` + `RPT_PDFS_GERADOS`).

## Versão

- v1.0 — 2026-05-02 — fix inicial; refatoração da concatenação no `CT2_AbrirCentral`.
