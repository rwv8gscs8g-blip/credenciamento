---
titulo: 42 - Tecnico MICRO35 Fix3 Cumulativo Svc OS
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-05
---

# MICRO35-fix3 - Pacote cumulativo Svc_OS

## 1. Sintoma

Depois de fechar sem salvar e reimportar `MICRO35-fix2`, a compilacao parou
em `Svc_OS.EmitirOS`, na chamada antiga de insercao qualificada.

## 2. Causa

`MICRO35-fix2` era incremental sobre `MICRO35-fix1`. Ele corrigia os pontos
remanescentes de busca de OS, mas nao reimportava `Svc_OS`. Ao reabrir o
workbook sem salvar o `fix1`, o workbook voltou a conter o `Svc_OS` anterior.

## 3. Correcao

`MICRO35-fix3` e cumulativo para esta familia de falhas de compilacao:

| Item | Motivo |
|---|---|
| `Repo_OS.bas` | Entrega os wrappers `RepoOS_Inserir`, `RepoOS_BuscarPorId` e `RepoOS_ExcluirPorId`. |
| `Svc_OS.bas` | Garante que `EmitirOS` use os wrappers ja corrigidos. |
| `Svc_Avaliacao.bas` | Garante que `AvaliarOS` use o buscador wrapper. |
| `Teste_V2_Engine.bas` | Remove dependencia de chamada qualificada em helper V2. |
| `Teste_V2_Roteiros.bas` | Remove dependencia de chamada qualificada no E2E. |
| `Menu_Principal.frm` | Remove dependencia de chamada qualificada na UI de avaliacao. |
| `App_Release.bas` | Bump para `f7aa84f+ONDA21.MD21.5-emitir-os-rollback-fix3`. |

## 4. Gate esperado

`V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`
