---
titulo: Onda 38.2.12 - Performance UX basica
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-01
---

# Onda 38.2.12 - Performance UX basica

## Escopo confirmado

Readback: `.hbn/readbacks/0128-rb-onda-38-2-12-performance-ux-basica.json`
Hearback: `.hbn/hearbacks/0128-rb-onda-38-2-12-performance-ux-basica-confirmed.json`

Objetivo: aplicar uma micro-onda de UX/performance de baixo risco sobre o
parecer 0024, sem tocar credenciamento em lote nem sequencia de IDs.

## Alteracoes

- `ProgressBar.frm`:
  - remove `Application.ThisWorkbook.Save` dentro da barra;
  - remove o busy-wait `timedelay`;
  - preserva `DoEvents` e mensagens visuais de progresso.
- `Menu_Principal.frm`:
  - extrai limpeza de cadastro de entidade para
    `LimparCamposCadastroEntidade`;
  - `AbrirURLExterna` tenta `Shell "open"` primeiro no Mac, antes de
    `FollowHyperlink`.
- `Teste_V2_Roteiros.bas`:
  - adiciona `TV2_RunPerformanceUXBasica`, com 5 asserts estaticos dirigidos.

## Fora de escopo

FT-4, credenciamento em lote, fica para onda propria. A chamada repetida de
`ProximoId(SHEET_CREDENCIADOS)` dentro do loop tem impacto de performance, mas
tambem controla contador AR1 e sequencia de `CRED_ID`; por isso nao foi
misturada a este pacote de UX basica.

## Importacao

Comando previsto:

```vb
ImportarPacoteV3_Delta "ONDA38_2_12_PERFORMANCE_UX_BASICA", "d2d7ac5+ONDA38.2.12-PERFORMANCE-UX-BASICA"
```

Depois do import:

1. VBE > Depurar > Compilar VBAProject.
2. Janela Imediata: `TV2_RunPerformanceUXBasica`.

Esperado: `OK=5 | FALHA=0 | MANUAL=0`.

## Resultado do gate humano

Mauricio reportou em 2026-06-01 00:42 BRT:

- import V3 concluido;
- `Depurar > Compilar VBAProject` passou limpo;
- `TV2_RunPerformanceUXBasica` concluiu `OK=5 | FALHA=0 | MANUAL=0`;
- execucao registrada: `TV2_20260601_004135`;
- sem CSV de falhas exportado.

Apos o import, `local-ai/vba_import/001-modulo/AAX-App_Release.bas` recebeu o
drift operacional esperado do BUMP do Importador V3. O arquivo foi
ressincronizado pelo publicador oficial com `apply --only App_Release.bas`,
conforme `.hbn/knowledge/0016-bump-build-label-anti-conflito.md`; nao houve
limpeza manual de espacos finais em VBA.

## Limites

Esta onda nao altera `.frx`, `Auto_Open.bas`, `Mod_Types.bas`,
`Importador_V3.bas`, `Credencia_Empresa.frm` nem regras de negocio.
