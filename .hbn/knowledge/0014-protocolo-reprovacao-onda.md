---
titulo: Protocolo de reprovacao de onda safe_track
data: 2026-05-24
autoria: Codex + auditoria Claude Opus 4.7
aplica-a: Todas as ondas safe_track V12.0.0206+
revisar-em: 2026-06-24
---

# Protocolo de reprovacao de onda

## Regra

Toda onda `safe_track` reprovada deve produzir knowledge de reprovacao antes do
proximo readback funcional.

## Por que existe

A cadeia MD33 mostrou que uma tentativa pode importar corretamente, falhar no
compile humano e ainda assim deixar `src/vba/` com drift que parece
autoritativo para a proxima IA. Isso quebra o invariante operacional:
`src/vba/` deve representar estado versionado importavel que compila, nao
apenas a ultima tentativa escrita.

## Conteudo minimo do knowledge de reprovacao

1. O que a onda tentou fazer.
2. Quais microdeltas/imports foram executados.
3. Qual sintoma reprovou a onda.
4. Qual hipotese foi descartada.
5. Quais arquivos ficaram contaminados ou suspeitos.
6. Qual ancora volta a ser fonte operacional.
7. O que a proxima onda nao pode assumir.

## Efeito no proximo readback

O readback seguinte deve declarar:

- predecessor da onda reprovada;
- arquivos que precisam reversao, congelamento ou decisao humana;
- `scope.files_forbidden` protegendo areas contaminadas que nao serao tocadas;
- gates que provam que o estado voltou a compilar.

## Aplicacao inicial

Esta regra nasce da Onda 37.1, que destilou a L26 sobre as tentativas
frustradas MD33.
