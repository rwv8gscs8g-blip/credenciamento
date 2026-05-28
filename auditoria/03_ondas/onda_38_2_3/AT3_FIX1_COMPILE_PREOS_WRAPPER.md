---
titulo: AT-3 Fix1 Compile PreOS Wrapper
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# AT-3 Fix1 Compile PreOS Wrapper

## Bloqueador

Após o import AT-3, o VBE compilou com erro:

`Método ou membro de dados não encontrado`

O destaque ocorreu em `Teste_V2_Roteiros`, na chamada:

```vb
Repo_PreOS.BuscarPorId(...)
```

## Correção

Aplicado padrão já existente em `Repo_OS`:

- `Repo_PreOS.bas`: criado wrapper público `RepoPreOS_BuscarPorId`, que delega diretamente para `BuscarPorId`.
- `Teste_V2_Roteiros.bas`: substituídas as 4 chamadas `Repo_PreOS.BuscarPorId(...)` por `RepoPreOS_BuscarPorId(...)`.

Não houve mudança em cenário, assert, contador ou regra de negócio.

## Import

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_3_AT3_FIX1_COMPILE_PREOS_WRAPPER.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_3_AT3_FIX1_COMPILE_PREOS_WRAPPER", "<sha>+ONDA38.2.3-AT3.fix1-COMPILE"
```

## Próximo gate

1. Importar fix1.
2. Rodar `Debug > Compile VBAProject`.
3. Se compile verde, rodar `TV2_RunRodizioStrikesEndToEnd`.
