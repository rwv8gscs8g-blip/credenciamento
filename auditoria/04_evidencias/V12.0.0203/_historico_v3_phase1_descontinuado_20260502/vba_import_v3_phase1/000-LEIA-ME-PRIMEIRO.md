# LEIA-ME PRIMEIRO — Importador V3 Phase 1

**Esta pasta contem TUDO que voce precisa para a Phase 1.**
**Voce so importa UM arquivo manualmente. O resto e automatico.**

---

## TLDR — 3 passos

### Passo 1 — abra o workbook baseline em disco LOCAL (nao SMB)

```bash
cp "/Users/macbookpro/Projetos/Credenciamento/V12-202-R/29_04_2026 02_22_53PlanilhaCredenciamento-Homologacao.xlsm" \
   /Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-V3-test.xlsm
```

Abra `/Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-V3-test.xlsm`
no Excel (NAO da pasta SMB `\\Mac\Home\...`).

> Por que essa pasta? Porque o Importador V3 procura `local-ai/vba_import_v3_phase1/`
> ao lado do .xlsm. Se voce salvar o workbook em outro lugar, V3 nao
> encontra a pasta de import.

### Passo 2 — importe UM arquivo no VBE

`Alt+F11` para abrir o VBE. Depois `File > Import File...` e selecione:

```
/Users/macbookpro/Projetos/Credenciamento/local-ai/vba_import_v3_phase1/Importador_V3_Bootstrap.bas
```

Aparece o modulo `Importador_V3_Bootstrap` na arvore.

> **Este e o UNICO arquivo que voce importa manualmente.** Todos os
> outros 48 arquivos (35 modulos + 13 forms) sao importados pelo V3
> de forma automatica.

### Passo 3 — rode duas macros no Imediato

Abra a janela Imediata: `Ctrl+G` (ou `View > Immediate Window`).

```
Bootstrap_V3
```

Aparece MsgBox confirmando que `Importador_V3` foi instalado.

```
ImportarPacoteV3
```

Aguarde ~3-5 minutos. Aparece MsgBox confirmando `M=35 F=13 err=0`.

`Debug > Compile VBAProject` precisa passar limpo. Depois rode:

```
CT_ValidarRelease_TrioMinimo
```

Esperado: V1=171/0, V2 Smoke=14/0, V2 Canonica=20/0, status APROVADO.

**Pronto.** Phase 1 concluida.

---

## Conteudo desta pasta

```
local-ai/vba_import_v3_phase1/
├── 000-LEIA-ME-PRIMEIRO.md          (este arquivo)
├── 000-MANIFESTO-V3-PHASE1.txt      (lista do que sera importado)
├── Importador_V3_Bootstrap.bas      ★ IMPORTAR ESTE PRIMEIRO
├── 001-modulo/                       (36 modulos .bas com prefixos)
│   ├── AAA-Mod_Types.bas
│   ├── AAB-Const_Colunas.bas
│   ├── ... (33 outros)
│   └── ABK-Importador_V3.bas        (engine V3 — Bootstrap importa este)
└── 002-formularios/                  (39 arquivos: 13 forms x 3)
    ├── AAA-Fundo_Branco.frm
    ├── AAA-Fundo_Branco.code-only.txt
    ├── Fundo_Branco.frx
    └── ... (12 outros forms x 3)
```

## Por que esta pasta existe (e nao usa local-ai/vba_import/)

A pasta `local-ai/vba_import/` tem o pacote do **Importador V2**
(descontinuado por bug no Mac SMB). Nao misturar os dois pacotes
evita confusao em qual manifesto o operador esta usando.

Esta pasta `local-ai/vba_import_v3_phase1/` tem **so** os arquivos
necessarios para a Phase 1 do V3, copiados do baseline V12-202-R
(que ja compila e ja passou trio minimo verde).

| Pasta | Para que serve | Status |
|---|---|---|
| `local-ai/vba_import/` | Pacote V2 + base de manifestos historicos | legado, nao mexer |
| `local-ai/vba_import_v3_phase1/` | **Pacote V3 Phase 1 — usar esta** | ativo |

## Em caso de erro durante o import

Nao tente hotfix iterativo. **Pare e reporte ao Claude.**

1. Feche o workbook **sem salvar** (mantem o estado do disco intocado).
2. Re-copie o baseline (passo 1 acima).
3. Reporte:
   - Em qual passo falhou (1, 2, ou 3)
   - Conteudo da MsgBox de erro
   - Conteudo da aba `IMPORT_LOG_V3` (export como CSV se possivel)
   - Conteudo da janela Imediata

## Documentos relacionados

- Procedimento detalhado com gates: [auditoria/03_ondas/onda_09_importador_v3/51_PROCEDIMENTO.md](../../auditoria/03_ondas/onda_09_importador_v3/51_PROCEDIMENTO.md)
- Doc tecnico: [auditoria/03_ondas/onda_09_importador_v3/50_TECNICO.md](../../auditoria/03_ondas/onda_09_importador_v3/50_TECNICO.md)
- Diagnostico do que falhou na V2: [.hbn/relay/IMPORTADOR_V2_DIAGNOSTICO_RETOMADA.md](../../.hbn/relay/IMPORTADOR_V2_DIAGNOSTICO_RETOMADA.md)

## Build de referencia

Phase 1 reproduz o estado do baseline V12-202-R:

| Campo | Valor |
|---|---|
| Build | `f7aa84f+ONDA05-em-homologacao` |
| Validacao ancora | `VR_20260430_225826` |
| Trio minimo | V1=171/0, V2 Smoke=14/0, V2 Canonica=20/0 |
| Status | APROVADO |

Apos Phase 1 verde, a versao apos import sera carimbada com
`...+ONDA09-V3-PHASE1` e proxima Phase abre.
