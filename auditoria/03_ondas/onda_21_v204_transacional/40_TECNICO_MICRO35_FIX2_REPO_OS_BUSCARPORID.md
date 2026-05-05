---
titulo: 40 - Tecnico MICRO35 Fix2 Repo OS BuscarPorId
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-05
---

# MICRO35-fix2 - RepoOS_BuscarPorId

## 1. Sintoma

Apos `MICRO35-fix1`, a compilacao avancou e parou em
`Svc_Avaliacao.AvaliarOS`, na chamada `Repo_OS.BuscarPorId(OS_ID)`.

## 2. Correcao

| Arquivo | Mudanca |
|---|---|
| `src/vba/Repo_OS.bas` | Adiciona `RepoOS_BuscarPorId(OS_ID)`. |
| `src/vba/Svc_Avaliacao.bas` | Usa `RepoOS_BuscarPorId`. |
| `src/vba/Menu_Principal.frm` | Usa `RepoOS_BuscarPorId`. |
| `src/vba/Teste_V2_Engine.bas` | Usa `RepoOS_BuscarPorId`. |
| `src/vba/Teste_V2_Roteiros.bas` | Usa `RepoOS_BuscarPorId`. |
| `src/vba/App_Release.bas` | Build atualizado para `f7aa84f+ONDA21.MD21.5-emitir-os-rollback-fix2`. |

## 3. Verificacao local

Busca em `src/vba` deve retornar zero ocorrencias ativas de `Repo_OS.`.

## 4. Gate esperado

`V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`
