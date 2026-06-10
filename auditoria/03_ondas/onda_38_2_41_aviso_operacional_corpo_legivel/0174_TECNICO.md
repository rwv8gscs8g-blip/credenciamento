---
titulo: Onda 0174 — aviso operacional no corpo dos impressos
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-09
---

# Onda 0174 — Aviso Operacional No Corpo Dos Impressos

## Contexto

A 0173 corrigiu o problema de texto artificialmente espacado e fonte espremida
no `C16`, mas a revisao visual dos PDFs 009-021 mostrou que o campo continuava
ruim para leitura humana. O defeito remanescente era de ergonomia: `C16` fica
entre o cabecalho do prestador e a area de servicos, com pouco espaco para uma
frase operacional.

## Decisao

Pre-OS e OS deixam de usar `C16` para o aviso operacional. O aviso passa para
`B24`, dentro do corpo do quadro de servicos. A avaliacao limpa `C16` e mantem
o diagnostico completo em `B40` Observacoes, que ja havia se mostrado legivel
nos PDFs.

A mudanca e apenas informativa. Ela nao expira Pre-OS, nao recusa demanda, nao
avanca fila e nao altera disponibilidade.

## Implementacao

`Preencher.bas`:

- `PreencherOS`, `PreencherAvaliaOS` e `PreencherPREOS` escrevem o aviso em
  `B24` por helper dedicado;
- `PreencherAvaliacaoOS` limpa `C16` e preserva o texto completo em `B40`;
- `LimparOS` e `LimparPREOS` limpam `B24`;
- `C16:N16` continua neutralizado para nao carregar resquicio visual herdado.

`Teste_V2_Roteiros.bas` e `Teste_V2_Engine.bas`:

- `TV2_RunRelatoriosSuspensoesStrikesReset` sobe para 14 cenarios;
- `RELSSR_11_IMPRESSOS_C16_LIMPO` garante que `C16` deixou de ser campo de
  aviso;
- `RELSSR_13_IMPRESSOS_AVISO_CORPO_OBSERVACOES` garante `B24` e `B40`;
- `RELSSR_14_IMPRESSOS_LIMPEZA_AVISO_CORPO` garante limpeza de `B24`.

## Gate Esperado

```text
Importador V3: M=4 | F=0 | err=0 | skip=0
Compile VBE: limpo
TV2_RunRelatoriosSuspensoesStrikesReset
OK=14 | FALHA=0 | MANUAL=0
```

## Validacao Visual Humana

Gerar novos PDFs equivalentes aos cenarios 009-021:

- Pre-OS: `C16` limpo e aviso em `B24`;
- OS: `C16` limpo e aviso em `B24`;
- Avaliacao: `C16` limpo e diagnostico em `B40` Observacoes;
- relatorios seguem sem regressao visual.

## Arquivos

- `src/vba/App_Release.bas`
- `src/vba/Preencher.bas`
- `src/vba/Teste_V2_Engine.bas`
- `src/vba/Teste_V2_Roteiros.bas`
- `local-ai/vba_import/001-modulo/AAX-App_Release.bas`
- `local-ai/vba_import/001-modulo/AAU-Preencher.bas`
- `local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas`
- `local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas`
- `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_41_AVISO_OPERACIONAL_CORPO_LEGIVEL.txt`

## Posicionamento De Contexto

Codex ainda tinha contexto suficiente para implementar e fechar a 0174. Ao
final da onda, deve registrar handoff curto porque a proxima etapa envolve
auditoria cruzada de pendencias, handoffs anteriores e planejamento de freeze
V206/V207.
