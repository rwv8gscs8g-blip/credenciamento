---
titulo: Procedimento Import MICRO62 V206 fix1 — Compile Crash
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: operador
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Procedimento Import MICRO62 V206 fix1 — Compile Crash

## Quando usar

Use este procedimento somente depois do incidente reportado em 2026-05-24:

- `ImportarPacoteV3_Delta "MICRO62-V206-MD33-0", "0b7c4e8+ONDA33.MD33.0-fix-relatorios"` importou com sucesso.
- O compile manual no VBE ficou preso em `Compilando...` e fechou o Excel.
- Ao reabrir, nova tentativa de compile repetiu a falha.

O fix1 substitui o delta anterior para a Onda 33. A Onda 34 continua bloqueada
ate este gate passar limpo.

## Pre-condicao de raiz

Na Janela Imediata, confirme:

```vb
?ThisWorkbook.Path
ImportarPacoteV3_Status
```

O caminho esperado e:

```text
\\Mac\Home\Projetos\Credenciamento
```

O manifesto local deve existir em:

```text
\\Mac\Home\Projetos\Credenciamento\local-ai\vba_import\000-MANIFESTO-V3-DELTA-MICRO62-V206-MD33-0-fix1.txt
```

A copia auditavel do manifesto esta em:

```text
auditoria/03_ondas/onda_33_v206_fix_relatorios_pdf_precondicao/04_MANIFESTO_MICRO62_FIX1.txt
```

## Comando

Cole na Janela Imediata:

```vb
ImportarPacoteV3_Delta "MICRO62-V206-MD33-0-fix1", "ONDA33.MD33.0-fix1-compile-crash"
```

## Arquivos importados

```text
M|001-modulo/AAU-Preencher.bas
F|002-formularios/AAM-Menu_Principal.frm
```

Resultado esperado do Importador V3:

```text
M=1 | F=1 | err=0 | skip=0
```

## Gate manual

Depois do import:

1. No VBE, execute `Depurar > Compilar VBAProject`.
2. Se o compile passar, volte ao Excel e rode `TV2_RunSmoke`.
3. Execute os roteiros assistidos `ASS_REL_OS_EMP_LISTA` e
   `ASS_REL_EMP_SERV_LISTA`.

Aceite:

- Compile VBE passa limpo.
- Smoke permanece verde.
- `Rel_OSEmpresa` abre com `RO_Lista` preenchida quando ha empresas.
- `Rel_Emp_Serv` abre com `SV_CR_Lista` preenchida quando ha servicos.
- Nenhuma tela vazia e exibida quando ha dados canonicos.

## Se o Excel fechar de novo

Nao salve o workbook.

Restaure primeiro o backup V3 impresso pelo proprio import fix1. O Importador V3
sempre mostra a linha `dest = ...\backups\vba\<RUN>-V3-FULL` antes do delta.

Se o fix1 nao chegar a criar novo backup, use o backup do import anterior:

```text
\\Mac\Home\Projetos\Credenciamento\backups\vba\20260524_145103-V3-FULL
```

Registre no chat:

- se o import fix1 chegou ao fim;
- a linha final do Importador V3;
- se o fechamento ocorreu durante o compile ou antes dele.

## Limites

Este fix1 nao implementa PDF, nao altera servicos blindados, nao altera RN-01 a
RN-17, nao altera contadores RVS e nao reorganiza `doc/`.
