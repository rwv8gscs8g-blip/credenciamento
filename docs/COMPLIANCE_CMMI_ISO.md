# Compliance CMMI / ISO

Este documento descreve a **aproximação** atual do repositório às práticas de
governança, qualidade e rastreabilidade esperadas em trilhas de maturidade
como CMMI nível 3 e controles usuais de ISO 9001 / ISO 27001.

Ele **não** afirma certificação formal.

## Mapa resumido

| Referência | Evidência no repositório | Status |
|---|---|---|
| CMMI CM — baseline/versionamento | [obsidian-vault/releases/STATUS-OFICIAL.md](../obsidian-vault/releases/STATUS-OFICIAL.md) | adotada |
| CMMI VER — verificação técnica | [auditoria/04_MATRIZ_MESTRE_DE_TESTES.md](../auditoria/04_MATRIZ_MESTRE_DE_TESTES.md) | adotada |
| CMMI VAL — validação com operador | [obsidian-vault/releases/V12.0.0202.md](../obsidian-vault/releases/V12.0.0202.md) | adotada |
| CMMI MA — medição e análise | bateria oficial e V2 com evidência pública | parcial |
| CMMI PPQA — garantia de qualidade | auditorias públicas em [auditoria](../auditoria) | parcial |
| CMMI DAR — decisão arquitetural/documental | pareceres e sumários públicos | parcial |
| ISO 9001 8.3 — desenvolvimento controlado | releases, changelog, matriz de testes | adotada |
| ISO 9001 9.1 — avaliação de desempenho | evidências de bateria oficial | parcial |
| ISO 27001 A.5 — políticas | [LICENSE](../LICENSE), [SECURITY.md](../SECURITY.md), [CONTRIBUTING.md](../CONTRIBUTING.md) | adotada |
| ISO 27001 A.8 — gestão de ativos | separação entre superfície pública e material local | parcial |
| ISO 27001 A.12 — integridade operacional | audit log, testes e proteção operacional de abas | parcial |

## Pontos fortes atuais

- versão oficial com status explícito
- release validada por operador humano
- bateria oficial consolidada
- trilha pública de auditoria
- pacote mínimo público de licença, contribuição e segurança

## Pontos ainda abertos

- nova evidência fresca da V2 antes da próxima auditoria externa
- maior rastreabilidade pública de evidências por release
- evolução do hardening de testes e invariantes
- fechamento da estratégia pública de publicação em `main`

## Uso correto deste documento

Este documento deve ser lido como:

- mapa de aderência
- evidência de maturidade incremental
- base para auditorias futuras

Ele não substitui certificação formal emitida por organismo acreditado.
