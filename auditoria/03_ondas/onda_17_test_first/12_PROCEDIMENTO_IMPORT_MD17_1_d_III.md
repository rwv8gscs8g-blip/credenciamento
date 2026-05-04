---
titulo: Procedimento de import MD-17.1.d.III — Hotfix V1 visibility + msg CSV
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — sessao 2
licenca-target: TPGL-v1.1
---

# 12 — Procedimento de import MD-17.1.d.III

## Tema

2 hotfixes do feedback do operador pos-MD-17.1.d.II:
- **(a) V1_RAPIDA visibility**: estática durante CT_ValidarRelease_* (StatusBar
  só atualizava em modo visual; CT seta `BA_SetModoExecucaoVisual False`).
- **(b) Msg CSV resumo ambígua**: mostrava path mesmo sem confirmar geração;
  operador teve sensação de "passa imagem errada".

## Causa raiz isolada

| Bug | Local | Causa |
|---|---|---|
| **a** | `Teste_Bateria_Oficial.bas` linha 1502 | `If gDelayVisualMs > 0 Then` envolvia o StatusBar update; CT zera gDelayVisualMs via BA_SetModoExecucaoVisual False |
| **b** | `Teste_Validacao_Release.bas` linhas 49 + 147 | msg final concatenava `csvResumo` sem checar se `Dir(csvResumo) <> ""` |

CSV de resumo **DE FATO É GERADO** (verificado: 949 bytes em `auditoria/evidencias/V12.0.0203/ValidacaoReleaseQuarteto_V12_0_0203_VR_20260503_175218.csv`). Fix é UX (confirmação explícita), não funcional.

## Pre-condicoes

| Item | Esperado |
|---|---|
| Workbook ancora | `V12-202-Z003-onda17-md1d2` |
| Build atual | `f7aa84f+ONDA17.MD1D2-visibility-status-bar-rica` |
| Quarteto pre-import | APROVADO |
| `src/vba/` ↔ `local-ai/vba_import/` | shasum batendo |

## Sequencia M11

| Arquivo | sha1 |
|---|---|
| `src/vba/Teste_Bateria_Oficial.bas` ↔ ABA | `c2fdba864d713842edf520cafc57c230366ded35` |
| `src/vba/Teste_Validacao_Release.bas` ↔ ABH | `4e07143047a018853dd9f7c0f5da183b1ca2026f` |
| `src/vba/App_Release.bas` ↔ AAX | `b29efe329434f5165d1c3f4a301803d670b234e9` |

CRLF preservado. Sub/Function balance Bateria 52/52 + 56/56; Validacao 13/13 + 16/16.

## Mudancas resumo

| Arquivo | Tipo |
|---|---|
| `Teste_Bateria_Oficial.bas` | StatusBar update SEMPRE (movido para fora do If gDelayVisualMs > 0) |
| `Teste_Validacao_Release.bas` | 2 blocos csvStatusMsg/csvStatusMsgQ com Dir() check antes da msgFinal (Trio + Quarteto) |
| `App_Release.bas` | bump label + comentario MD-17.1.d.III |

## Procedimento operacional

### Passo 1-4 — Reset, Import, Compile, Build check

```
0. VBE > Executar > Redefinir
1. ImportarPacoteV3_Delta "MICRO22", "f7aa84f+ONDA17.MD1D3-hotfix-v1visibility-csvmsg"
2. VBE > Depurar > Compilar VBAProject  (0 erros)
3. ?GetBuildImportado  → "f7aa84f+ONDA17.MD1D3-hotfix-v1visibility-csvmsg"
```

### Passo 5 — Quarteto + observar 2 fixes

```
CT_ValidarRelease_QuartetoMinimo
```

DURANTE V1_RAPIDA, observe StatusBar atualizando:
```
Bateria [1] BO_xxx — OK
Bateria [2] BO_yyy — OK
...
Bateria [171] BO_zzz — OK
```

(ANTES do fix: ficava estático em "Validacao Quarteto: V1 rapida")

NA MENSAGEM FINAL, observe:
```
CSV resumo (gerado):
\\Mac\Home\Projetos\Credenciamento\auditoria\evidencias\V12.0.0203\ValidacaoReleaseQuarteto_V12_0_0203_VR_<id>.csv
```

(ANTES do fix: mostrava só "CSV resumo: <path>" sem confirmar geração)

### Passo 6 — Salvar + Reportar

`V12-202-Z003-onda17-md1d3`. Reportar VR + confirmação visual dos 2 fixes.

## Criterios de sucesso

1. Compile manual passa limpo.
2. `GetBuildImportado` = `f7aa84f+ONDA17.MD1D3-hotfix-v1visibility-csvmsg`.
3. Quarteto APROVADO sintaxe IDENTICA.
4. **V1_RAPIDA visibility**: StatusBar atualiza durante execução (era estática).
5. **Msg final**: mostra "(gerado)" explicitamente antes do path.
6. shasum batendo M11 (3 arquivos).

## Documentos relacionados

- [`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO22.txt`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO22.txt)
- [`11_PROCEDIMENTO_IMPORT_MD17_1_d_II.md`](11_PROCEDIMENTO_IMPORT_MD17_1_d_II.md) (anterior)

## Versao

- v1.0 — 2026-05-03 — hotfix inicial.
