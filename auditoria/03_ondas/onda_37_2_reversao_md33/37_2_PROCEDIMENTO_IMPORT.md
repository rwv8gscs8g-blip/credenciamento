---
titulo: Procedimento Onda 37.2 — Importacao humana controlada
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-05-24
---

# Procedimento Onda 37.2 — Importacao humana controlada

## Pre-condicoes

- Usar o workbook V5 local validado.
- Confirmar no VBE que `ThisWorkbook.Path` aponta para
  `\\Mac\Home\Projetos\Credenciamento`.
- Confirmar que o pacote importavel esta em
  `\\Mac\Home\Projetos\Credenciamento\local-ai\vba_import\`.
- Nao importar arquivos de `local-ai/incoming/`, `backups/vba/` ou qualquer
  pasta `V12-*`.

## Arquivos autorizados para importacao

Importar somente estes arquivos do pacote oficial `local-ai/vba_import/`:

| Tipo | Arquivo |
|---|---|
| Modulo | `local-ai/vba_import/001-modulo/ABK-Importador_V3.bas` |
| Modulo | `local-ai/vba_import/001-modulo/AAU-Preencher.bas` |
| Formulario | `local-ai/vba_import/002-formularios/AAM-Menu_Principal.frm` |

O arquivo `local-ai/vba_import/002-formularios/AAM-Menu_Principal.code-only.txt`
e evidencia auxiliar do corpo importavel do formulario; nao substitui a
importacao do `.frm` pelo VBE/Importador.

## Passos humanos

1. Abrir o workbook V5 validado.
2. Rodar `ImportarPacoteV3_Status` e confirmar que a pasta detectada e
   `local-ai\vba_import\`.
3. Importar somente os tres arquivos listados acima.
4. No VBE, executar `Debug > Compile VBAProject`.
5. Se o compile passar, registrar a confirmacao humana no proximo hearback.
6. Se o compile falhar, nao salvar nova versao como valida; registrar o erro
   observado para uma onda de rollback ou correcao com readback proprio.

## Gate pendente

O ERP `0092-exec-onda37-2-reversao-md33.json` permanece em estado
`delivered_for_human_gate` ate Mauricio confirmar a importacao controlada e o
compile VBE. Este procedimento nao autoriza importacao a partir de
`local-ai/incoming/`.
