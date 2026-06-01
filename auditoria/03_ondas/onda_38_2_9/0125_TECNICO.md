---
titulo: Onda 38.2.9 - snapshot CONFIG em suites V2
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-31
---

# Onda 38.2.9 - snapshot CONFIG em suites V2

## Escopo confirmado

Readback: `.hbn/readbacks/0125-rb-onda-38-2-9-config-snapshot-v2.json`
Hearback: `.hbn/hearbacks/0125-rb-onda-38-2-9-config-snapshot-v2-confirmed.json`

Objetivo: impedir que execucoes V2 deixem valores canonicos de teste na aba
`CONFIG` depois da suite.

## Alteracoes entregues

- `TV2_InitExecucao` captura `CONFIG!A:N` antes de preparar a suite.
- `TV2_FinalizarExecucao` restaura `CONFIG!A:N` no encerramento normal.
- O handler fatal de `TV2_FinalizarExecucao` tambem chama a restauracao antes
  de devolver o Excel ao operador.
- A nova suite `TV2_RunConfigSnapshotV2` valida de forma nao destrutiva que o
  motor declara, captura e restaura o snapshot nos pontos esperados.

## Pacote V3

Manifesto:
`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_9_CONFIG_SNAPSHOT_V2.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_9_CONFIG_SNAPSHOT_V2", "fd45a5d+ONDA38.2.9-CONFIG-SNAPSHOT-V2"
```

Pos-import esperado:

1. Importador V3: `M=3 | F=0 | err=0`.
2. VBE > Depurar > Compilar VBAProject: limpo.
3. Janela Imediata: `TV2_RunConfigSnapshotV2`.
4. Resultado esperado: `OK=4 | FALHA=0 | MANUAL=0`.

## Racional

A Onda 38.2.8 corrigiu o caso mais visivel, municipio e gestor. A auditoria
posterior mostrou que a CONFIG tem outros campos operacionais usados pela UI e
pelas regras: logo, prazo de Pre-OS, recusas, meses de suspensao, nota minima,
strikes, dias de suspensao e threshold de teste lento.

Em vez de propagar excecoes campo a campo, esta onda trata a fronteira correta:
toda suite V2 pode usar baseline canonica durante o teste, mas deve devolver a
linha operacional da CONFIG ao estado em que estava no inicio da execucao.

## Fora do escopo preservado

- `Auto_Open.bas` nao foi tocado.
- `Mod_Types.bas` nao foi tocado.
- `Importador_V3.bas` nao foi tocado.
- `Configuracao_Inicial.frm` e `.frx` nao foram tocados.
- `Menu_Principal`, `Preencher`, `Svc_*` e `Repo_*` nao foram alterados.
- Layout/bordas dos PDFs continuam para onda propria.
- Nao foi declarado freeze V206.
