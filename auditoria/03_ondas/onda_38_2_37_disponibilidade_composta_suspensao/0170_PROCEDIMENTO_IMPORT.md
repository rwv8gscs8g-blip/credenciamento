---
titulo: Procedimento de importacao — Onda 0170
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-06-08
---

# Procedimento de importacao — Onda 0170

## Pre-condicoes

- Workbook aberto no VBE em `\\Mac\Home\Projetos\Credenciamento`.
- Worktree local em `/Users/macbookpro/Projetos/Credenciamento`.
- Se a 0169 ainda nao foi importada no workbook, importar primeiro
  `ONDA38_2_36_C16_AVISO_OPERACIONAL_PDF`.
- Nao rodar VCR neste microdelta; reservar para a 0171.

## Importar pacote

Na Janela Imediata do VBE:

```vb
ImportarPacoteV3_Delta "ONDA38_2_37_DISPONIBILIDADE_COMPOSTA_SUSPENSAO", "10c1750+ONDA38.2.37-DISPONIBILIDADE-COMPOSTA"
```

Resultado esperado:

```text
M=4 | F=0 | err=0 | skip=0
```

## Compilar

Executar `Depurar > Compilar VBAProject`.

Resultado esperado: compile limpo.

## Teste dirigido

Na Janela Imediata:

```vb
TV2_RunRelatoriosSuspensoesStrikesReset
```

Resultado esperado:

```text
OK=12 | FALHA=0 | MANUAL=0
```

## Conferencia humana

Ao revisar relatorios ou avisos com empresa suspensa e ocupada na mesma
atividade, a disponibilidade deve mostrar a suspensao e a ocupacao adicional,
por exemplo:

```text
SUSPENSA ATE dd/mm/aaaa; OS EM EXECUCAO
SUSPENSA ATE dd/mm/aaaa; PRE-OS PENDENTE
```

A suspensao continua sendo o bloqueio principal. O complemento nao libera a
empresa para rodizio.

## Falha

- Se o import falhar, restaurar o backup indicado pelo Importador V3.
- Se o compile falhar, nao salvar o workbook e restaurar o backup.
- Se o TV2 falhar, anexar CSV/log da falha e nao rodar VCR.
