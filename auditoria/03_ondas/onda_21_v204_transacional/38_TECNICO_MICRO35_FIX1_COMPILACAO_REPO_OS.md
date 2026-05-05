---
titulo: 38 - Tecnico MICRO35 Fix1 Compilacao Repo OS
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-05
---

# MICRO35-fix1 - Compilacao Repo_OS

## 1. Sintoma

Durante o Quinteto do MICRO35, o VBE interrompeu em `Svc_OS.EmitirOS` com:

`Metodo ou membro de dados nao encontrado`

O ponto destacado foi a chamada qualificada `Repo_OS.Inserir(os)`.

## 2. Causa operacional

O projeto ja possui varios `Inserir` publicos em repositorios diferentes. Para
evitar que o VBE resolva a chamada qualificada `Repo_OS.*` como membro
inexistente em algum contexto, o fix cria wrappers com nomes unicos.

## 3. Correcao

| Arquivo | Mudanca |
|---|---|
| `src/vba/Repo_OS.bas` | Adiciona `RepoOS_Inserir(ByRef O As TOS)`. |
| `src/vba/Repo_OS.bas` | Adiciona `RepoOS_ExcluirPorId(OS_ID)`. |
| `src/vba/Svc_OS.bas` | Troca `Repo_OS.Inserir` por `RepoOS_Inserir`. |
| `src/vba/Svc_OS.bas` | Troca `Repo_OS.ExcluirPorId` por `RepoOS_ExcluirPorId`. |
| `src/vba/App_Release.bas` | Build atualizado para `f7aa84f+ONDA21.MD21.5-emitir-os-rollback-fix1`. |

## 4. Gate esperado

`V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`
