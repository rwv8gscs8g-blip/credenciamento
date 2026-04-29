# CLAUDE.md — instrucoes para Claude neste repositorio

> **Mudanca da Onda 6 (2026-04-28):** este arquivo foi reduzido. A
> entrada canonica agora e [`AGENTS.md`](AGENTS.md), padrao
> [agents.md](https://agents.md/) adotado por todo o ecossistema. Toda
> IA — Claude, Codex, Cursor, Copilot, Gemini — comeca por la.

## Para Claude especificamente

1. Leia [`AGENTS.md`](AGENTS.md) primeiro.
2. Leia [`.hbn/relay/INDEX.md`](.hbn/relay/INDEX.md) — quem tem o bastao.
3. Se for executar onda nova, gere readback explicito em
   `.hbn/readbacks/00NN-ondaNN.json` antes de tocar arquivo.
4. Aguarde hearback `confirmed` do Mauricio antes de execucoes
   `safe_track`.

## Tabus do projeto (referencia rapida)

- **`Mod_Types.bas`** — intervencao planejada apenas na **Onda 9**, com
  plano dedicado e aprovacao previa do Mauricio. Fora disso, nao tocar.
  (Mudou da regra anterior de "proibicao absoluta" — ver auditoria/40
  secao 9.)
- **`local-ai/scripts/publicar_vba_import.sh`** — descontinuado em
  28/04/2026. Manutencao do pacote e MANUAL.
- **"Import File" para `.frm` em workbook estabilizado** — sobrescreve
  `.frx` e perde renomeacoes do designer. Use `.code-only.txt`.
- **Importar a partir de `src/vba/` direto** — proibido. So a partir de
  `local-ai/vba_import/` (Regra de Ouro,
  `.hbn/knowledge/0002-regra-ouro-vba-import.md`).
- **Macro descartavel na raiz de `vba_import/`** — proibido desde Onda 6.
  Macros de diagnostico ficam em
  `Projetos/backups/credenciamento/macros_descartaveis_v0203/`.

## Ondas previstas (resumo)

| Onda | Tema | Status |
|---|---|---|
| 1 | strikes na avaliacao | entregue (em homologacao) |
| 2 | CNAE snapshot + dedup | entregue (em homologacao) |
| 3 | CNAE dedup automatico | entregue (em homologacao) |
| 4 | wire-up Configuracao_Inicial | entregue (em homologacao) |
| 5 | form deterministico + Limpa_Base robusta | entregue (em homologacao) |
| 6 | consolidacao documental + cleanup + HBN/Diataxis/llms.txt/AGENTS.md/Glasswing | entregue |
| 7 | familia IDM_* + RDZ_* (5 cenarios na bateria V2) | entregue |
| 8 | heuristica zero em todos os 13 forms | entregue |
| 9 | Importador V2 + Glasswing G7+G8 + git pre-commit hook (antecipada) | entregue |
| FECH | tag v12.0.0203 + push GitHub | EM EXECUCAO |

## Estrutura do repositorio (pos-Onda 6)

Detalhe completo em [`AGENTS.md`](AGENTS.md). Resumo:

- `.hbn/` — coordenacao inter-IA (HBN-native)
- `auditoria/` — historia + evidencias publicas (reorganizado por tipo)
- `docs/` — Diataxis para humanos (tutorials, how-to, reference, explanation)
- `src/vba/` — fonte de verdade do codigo VBA
- `local-ai/vba_import/` — pacote oficial de import (espelho com prefixos)
- `obsidian-vault/` — vitrine institucional + metodologia

## Quando esta documentacao muda

Esta documentacao so muda por release oficial com migration plan
documentado. Ate la, vale exatamente como esta escrita aqui.
