---
titulo: Onda 38.2.36 — C16 aviso operacional em PDF
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-08
---

# 0169 — C16 aviso operacional em PDF

## Contexto

A auditoria cruzada 0167 apontou que o aviso operacional inserido em `C16` nos
impressos de Pre-OS, OS e Avaliacao ficava com caracteres artificialmente
espacado em PDFs. O texto estava correto, mas a renderizacao indicava
alinhamento distribuido/justificado herdado do template.

## Decisao tecnica

A correcao foi feita em runtime, no ponto unico que escreve o aviso:
`Preencher_EscreverAvisoOperacional`.

O range `C16:N16` agora recebe:

- `HorizontalAlignment = xlLeft`;
- `VerticalAlignment = xlCenter`;
- `WrapText = False`;
- `ShrinkToFit = True`.

Isso neutraliza a formatacao distribuida do template sem editar `.frm`, `.frx`
ou o workbook manualmente.

## Cobertura V2

`TV2_RunRelatoriosSuspensoesStrikesReset` passou de 10 para 11 cenarios.

Novo cenario:

- `RELSSR_11_IMPRESSOS_C16_ALINHAMENTO_LEGIVEL`

O teste valida por contrato estatico que `Preencher.bas` reaplica o alinhamento
legivel antes do `ShrinkToFit`.

## Gate esperado

```vb
TV2_RunRelatoriosSuspensoesStrikesReset
```

Esperado: `OK=11 | FALHA=0 | MANUAL=0`.

Tambem e obrigatoria revisao visual humana de PDFs novos de Pre-OS, OS e
Avaliacao para confirmar que o aviso em `C16` nao aparece com letras
artificialmente espacadas.

## Fora do escopo

- Nao foi alterada a regra de disponibilidade.
- Nao foi alterado o texto do aviso operacional.
- Nao foi alterado o motor de rodizio.
- Nao foi editado `.frm`, `.frx` ou template manualmente.
- VCR fica reservado para a Onda 0171.
