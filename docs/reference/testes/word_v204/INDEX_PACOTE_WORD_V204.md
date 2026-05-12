---
titulo: Pacote Word V12.0.0204 — Homologação Humana
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-12
---

# Pacote Word V12.0.0204 — Homologação Humana

Este diretório agrupa, em formato `.docx` pronto para envio a testador externo,
o conjunto de documentos da homologação humana da V12.0.0204. A fonte
canônica continua sendo o Markdown em `docs/`; os `.docx` são reproduções
fiéis com sumário e formatação tipográfica para leitura impressa.

## Ordem sugerida de leitura

| Ordem | Arquivo | Papel |
|---|---|---|
| 1 | `01_GUIA_TESTES_HUMANOS_V204.docx` | Visão geral curta para o testador externo abrir o arquivo, liberar macros, rodar Sexteto e seguir o roteiro manual |
| 2 | `06_COMO_LIBERAR_MACROS_NO_WINDOWS.docx` | Passo a passo para destravar `.xlsm` no Windows 10/11 |
| 3 | `07_COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.docx` | Caminho exato pela interface para executar o gate automatizado |
| 4 | `03_REGRAS_DE_NEGOCIO_V204.docx` | Regras canônicas que a release não pode violar |
| 5 | `04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.docx` | Cobertura de cada regra por suíte e roteiro |
| 6 | `05_MATRIZ_RASTREABILIDADE_TESTES_V204.docx` | Ligação técnica regra → cenário → assert → evidência |
| 7 | `02_ROTEIRO_TESTE_MANUAL_V204.docx` | Roteiro técnico oficial de 14 fluxos M-01 a M-14 |
| 8 | `08_PROTOCOLO_HOMOLOGACAO_HUMANA_V204.docx` | **Documento principal** — protocolo completo, exaustivo, preenchível e auditável (47 regras, 50 cenários, checklist de liberação, relatório final, bug reports) |

## Como usar este pacote

1. Entregar todos os 8 documentos `.docx` ao testador externo, junto com o
   arquivo `.xlsm` final validado (build
   `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`).
2. O testador lê em ordem (1 → 8). Os documentos 1–7 sustentam a
   contextualização e a execução. O documento 8 é o **protocolo
   preenchível** — cada cenário tem tabela própria para registrar resultado,
   data, hora, evidência e responsável.
3. Ao final, o testador devolve o documento 8 preenchido, junto com os
   CSVs de Sexteto, prints e bug reports.

## Identidade da release

| Campo | Valor |
|---|---|
| Versão | V12.0.0204 |
| Status | VALIDADO |
| Build importado | `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |
| Gate final | `VR_20260511_175849` (com gate paralelo `VR_20260511_154433`) |
| Sintaxe canônica | `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` |
| Pasta de evidências | `auditoria/evidencias/V12.0.0204/` |

## Sobre a formatação

Os `.docx` foram gerados com `pandoc 3.9` usando o template de referência
padrão, que aplica:

- fonte do tema **Aptos/Calibri** (corpo) com cabeçalhos em azul corporativo `#0F4761`;
- sumário automático com profundidade 2;
- tabelas com banded rows e bordas leves;
- blocos de código em fonte monospace;
- margens padrão A4.

Para reformatar com identidade visual específica do município ou da
organização contratante, abrir cada `.docx` no Word, aplicar o tema desejado
em **Design > Temas** e salvar como cópia.

## Fonte canônica

Os Markdowns continuam em:

- [Protocolo de Homologação V204](../08_PROTOCOLO_HOMOLOGACAO_HUMANA_V204.md)
- [Guia Testes Humanos V204](../../../tutorials/GUIA_TESTES_HUMANOS_V204.md)
- [Roteiro Manual V204](../07_ROTEIRO_TESTE_MANUAL_V204.md)
- [Regras de Negócio V204](../../regras/REGRAS_DE_NEGOCIO_V204.md)
- [Matriz de Cobertura V204](../04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md)
- [Matriz de Rastreabilidade V204](../06_MATRIZ_RASTREABILIDADE_TESTES_V204.md)
- [Como Liberar Macros](../../../how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md)
- [Como Rodar Sexteto](../../../how-to/COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.md)

Qualquer atualização deve ser feita primeiro no Markdown e depois
re-exportada para `.docx` com o comando `pandoc` registrado em
`docs/reference/testes/word_v204/GENERATE.md`.
