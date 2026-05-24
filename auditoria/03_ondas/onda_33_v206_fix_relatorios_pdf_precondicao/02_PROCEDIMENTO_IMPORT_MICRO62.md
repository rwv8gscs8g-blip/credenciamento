---
titulo: Procedimento Import MICRO62 V206 — Fix Relatórios
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: operador
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Procedimento Import MICRO62 V206 — Fix Relatórios

## Pré-condição de raiz

Antes de importar, confirme na Janela Imediata:

```vb
?ThisWorkbook.Path
ImportarPacoteV3_Status
```

O caminho esperado é:

```text
\\Mac\Home\Projetos\Credenciamento
```

O manifesto do delta deve existir em:

```text
\\Mac\Home\Projetos\Credenciamento\local-ai\vba_import\000-MANIFESTO-V3-DELTA-MICRO62-V206-MD33-0.txt
```

## Comando

Cole na Janela Imediata:

```vb
ImportarPacoteV3_Delta "MICRO62-V206-MD33-0", "0b7c4e8+ONDA33.MD33.0-fix-relatorios"
```

## Arquivo importado

```text
F|002-formularios/AAM-Menu_Principal.frm
```

## Resultado esperado

- Importador V3: `M=0 | F=1 | err=0 | skip=0`.
- Compile VBE passa limpo.
- `TV2_RunSmoke` passa sem alterar contadores RVS.
- `ASS_REL_OS_EMP_LISTA` confirma `Rel_OSEmpresa` preenchido ou mensagem clara
  se não houver dados.
- `ASS_REL_EMP_SERV_LISTA` confirma `Rel_Emp_Serv` preenchido ou mensagem clara
  se não houver dados.

## Limites

Este delta não implementa PDF, não altera serviços blindados, não altera RN-01
a RN-17 e não toca nos contadores do RVS.
