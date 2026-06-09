---
titulo: Onda 0170 — Disponibilidade composta sob suspensao
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-08
---

# Onda 0170 — Disponibilidade composta sob suspensao

## Contexto

A auditoria cruzada pos-0165/0166 apontou um risco de legibilidade operacional:
quando uma empresa esta suspensa, `RRS_DisponibilidadeOperacionalEmpresa`
retornava apenas a suspensao e nao mostrava se havia OS aberta ou Pre-OS
pendente na mesma atividade.

Isso nao era erro de regra de rodizio, mas podia confundir o operador ao ler
relatorios e avisos impressos.

## Mudanca aplicada

`Rel_Rodizio_Status.bas` passou a separar a ocupacao por atividade em
`RRS_OcupacaoAtividadeTexto`:

- OS aberta continua tendo prioridade sobre Pre-OS pendente.
- Empresa ativa preserva a leitura anterior: `OS EM EXECUCAO`,
  `PRE-OS PENDENTE` ou `DISPONIVEL`.
- Empresa suspensa continua bloqueada pela suspensao, mas a disponibilidade
  passa a compor o texto com ocupacao, por exemplo:
  `SUSPENSA ATE dd/mm/aaaa; OS EM EXECUCAO`.

`RRS_ComporDisponibilidadeSuspensa` centraliza a composicao para evitar alterar
o motor de rodizio, expiracao, recusa ou fila.

## Teste

A suite `TV2_RunRelatoriosSuspensoesStrikesReset` recebeu o cenario
`RELSSR_12_DISPONIBILIDADE_COMPOSTA_SUSPENSAO`, que valida os tokens
estruturais do helper de ocupacao e da composicao de disponibilidade suspensa.

Resultado esperado apos import/compile:

```text
TV2_RunRelatoriosSuspensoesStrikesReset
OK=12 | FALHA=0 | MANUAL=0
```

## Pacote

Manifesto V3:
`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_37_DISPONIBILIDADE_COMPOSTA_SUSPENSAO.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_37_DISPONIBILIDADE_COMPOSTA_SUSPENSAO", "10c1750+ONDA38.2.37-DISPONIBILIDADE-COMPOSTA"
```

Import esperado: `M=4 | F=0 | err=0 | skip=0`.

## Arquivos

- `src/vba/Rel_Rodizio_Status.bas`
- `src/vba/Teste_V2_Roteiros.bas`
- `src/vba/Teste_V2_Engine.bas`
- `src/vba/App_Release.bas`
- espelhos correspondentes em `local-ai/vba_import/001-modulo/`
- documentos HBN, changelog, manual e guia de testes

## Nao feito

- Nao houve mudanca em `.frm` ou `.frx`.
- Nao houve mudanca em `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`
  ou `ThisWorkbook`.
- Nao houve VCR nesta onda; o checkpoint forte fica para 0171.
- A IA nao executou importacao no workbook, compile VBE ou TV2 dentro do Excel.
