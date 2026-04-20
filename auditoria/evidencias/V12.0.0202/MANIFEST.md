# Evidências Públicas — V12.0.0202

## Escopo

Este diretório publica a evidência objetiva atualmente disponível da linha
`V12.0.0202` no repositório público.

## Evidência publicada

### Bateria Oficial

- `BateriaOficial_20260420_014908.csv`
  - SHA-256: `5d8d2c3ecf4f17d1c89906585f0250718726878dc9d970ffedffcad7b217662c`
- `BateriaOficial_20260420_015310.csv`
  - SHA-256: `990cb513dd738a1f73f88cf5c9f45434eccbd996fc9b6c49aed800001cf14613`
- `BateriaOficial_20260420_015317.csv`
  - SHA-256: `990cb513dd738a1f73f88cf5c9f45434eccbd996fc9b6c49aed800001cf14613`
- `BateriaOficial_Falhas_20260420_014908.csv`
  - SHA-256: `8a120b687d090c90d4ee09634361531071bffd3bc0b1d4f266e03a75a5826c94`
- `BateriaOficial_Falhas_20260420_015310.csv`
  - SHA-256: `8a120b687d090c90d4ee09634361531071bffd3bc0b1d4f266e03a75a5826c94`
- `BateriaOficial_Falhas_20260420_015317.csv`
  - SHA-256: `8a120b687d090c90d4ee09634361531071bffd3bc0b1d4f266e03a75a5826c94`
- `BateriaOficial_20260420_025421.csv`
  - SHA-256: `24624f4633589ffca5072fd6dcb2ec38a1d549de5a37858c01eb052b0da6aedf`
- `BateriaOficial_20260420_025517.csv`
  - SHA-256: `ee2091f72e9467fa8bd99558597764bf4645b480cb2f52347bb3498b14fb82d7`
- `BateriaOficial_20260420_025521.csv`
  - SHA-256: `ee2091f72e9467fa8bd99558597764bf4645b480cb2f52347bb3498b14fb82d7`
- `BateriaOficial_Falhas_20260420_025421.csv`
  - SHA-256: `8a120b687d090c90d4ee09634361531071bffd3bc0b1d4f266e03a75a5826c94`
- `BateriaOficial_Falhas_20260420_025517.csv`
  - SHA-256: `8a120b687d090c90d4ee09634361531071bffd3bc0b1d4f266e03a75a5826c94`
- `BateriaOficial_Falhas_20260420_025522.csv`
  - SHA-256: `8a120b687d090c90d4ee09634361531071bffd3bc0b1d4f266e03a75a5826c94`

### Validação Humana da V2

- [V2_VALIDACAO_HUMANA_2026-04-20.md](V2_VALIDACAO_HUMANA_2026-04-20.md)
  - validação operacional de `smoke`, `stress` e testes assistidos
  - critério da suíte: em execução íntegra, nenhum CSV de falhas é exportado

## Leitura resumida

- a bateria oficial recente da `V12.0.0202` não registrou falhas exportadas
- as rodadas públicas recentes da bateria oficial mantiveram saída sem falhas
- a V2 foi revalidada por operador humano em 2026-04-20:
  - `smoke`: `OK=12`, `FALHA=0`, `MANUAL=0`
  - `stress`: `OK=12`, `FALHA=0`, `MANUAL=0`
  - `assistido`: validado sem exportação de CSV de falhas

## Situação atual

Não há pendência técnica aberta de evidência de testes para a linha
`V12.0.0202`. O próximo passo é a consolidação final da linha pública, a
homologação jurídica humana da TPGL v1.1 e a promoção da árvore limpa para
`main`.
