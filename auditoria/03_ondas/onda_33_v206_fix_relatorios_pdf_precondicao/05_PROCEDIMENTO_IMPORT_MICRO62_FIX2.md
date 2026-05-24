---
titulo: Procedimento Import MICRO62 V206 fix2 - Sem Menu Principal
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: operador
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Procedimento Import MICRO62 V206 fix2 - Sem Menu Principal

> **REPROVADO — não usar.** Este procedimento fica apenas como registro
> histórico. O import passou, mas o compile VBE fechou o Excel.

## Quando usar

Use este procedimento depois do segundo incidente:

- `MICRO62-V206-MD33-0-fix1` importou com sucesso.
- O resultado foi `M=1 | F=1 | err=0 | skip=0`.
- O compile manual no VBE fechou o Excel novamente.

O fix2 evita novo import de `Menu_Principal.frm`. A correcao passa a acontecer
nos dois formularios pequenos de relatorio, que se preenchem ao abrir.

Se o Excel oferecer recuperacao automatica apos o fechamento, nao use a versao
recuperada para homologar o fix2. A retomada aprovada passa a ser planilha limpa
copiada para a raiz canonica.

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
\\Mac\Home\Projetos\Credenciamento\local-ai\vba_import\000-MANIFESTO-V3-DELTA-MICRO62-V206-MD33-0-fix2.txt
```

## Comando

Cole na Janela Imediata:

```vb
ImportarPacoteV3_Delta "MICRO62-V206-MD33-0-fix2", "ONDA33.MD33.0-fix2-no-menu-import"
```

## Arquivos importados

```text
M|001-modulo/AAU-Preencher.bas
F|002-formularios/AAK-Rel_Emp_Serv.frm
F|002-formularios/AAL-Rel_OSEmpresa.frm
```

Resultado esperado do Importador V3:

```text
M=1 | F=2 | err=0 | skip=0
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
- O relatorio `Rel_OSEmpresa` abre com `RO_Lista` preenchida quando ha empresas.
- O relatorio `Rel_Emp_Serv` abre com `SV_CR_Lista` preenchida quando ha
  servicos.

## Se o Excel fechar

Registre no chat:

- se o import fix2 chegou ao fim;
- a linha final do Importador V3;
- se o fechamento ocorreu durante o compile ou antes dele.

Nao importar codigo a partir de `backups/vba`. Backups do V3 sao evidencia e
material de diagnostico; fonte operacional para o Excel e apenas
`local-ai/vba_import/`.

## Limites

Este fix2 nao implementa PDF, nao altera servicos blindados, nao altera RN-01 a
RN-17, nao altera contadores RVS e nao reorganiza `doc/`.
