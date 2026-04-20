# Pendência de Evidência V2 — V12.0.0202

## Situação

A rodada fresca da V2 (`smoke`, `stress`, `assistido`) ainda não foi anexada a
este pacote público de evidências.

## Motivo

A linha `V12.0.0202` já conta com:

- compilação limpa validada por operador humano
- bateria oficial recente sem falhas bloqueantes
- evidência pública da bateria oficial publicada neste diretório

Entretanto, a auditoria pública final recomendou anexar também a exportação
mais recente da V2 antes da promoção definitiva da linha pública para `main`.

## Próximo passo

Executar no workbook validado:

1. `smoke`
2. `stress`
3. `assistido`
4. exportação da última execução V2

Depois disso, anexar os arquivos gerados neste mesmo diretório e atualizar o
`MANIFEST.md`.
