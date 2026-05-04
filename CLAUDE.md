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
5. **READ-FIRST por dominio**: antes de qualquer microdelta, leia o
   capitulo correspondente em
   [`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`](usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md)
   (ver tabela abaixo).

## READ-FIRST por dominio (PHAGOCYTOSIS-VBA-PATTERNS)

| Domínio do MD | Lições obrigatórias |
|---|---|
| Suite de testes nova (Public/Private) | M12, M13, L14 |
| Plano de fix em MD multi-microdelta | M14 |
| Mexida em src/vba/ ou local-ai/vba_import/ | M11, M9 |
| Forms/UI (smoke read-only, helpers UI) | **M9, L22, L23, L24, M15, M16, M17** |
| Validação textual nova (.frm/.code-only/diff) | **L22, L24, M16** |
| Hash/randomização determinística | L20, L21 |
| Status bar / progress | L17 (instrumentação) |
| Refatoração γ de performance | (a destilar — Onda 17 MD-17.1.d.I) |

Esta tabela cresce a cada onda. Atualizar quando lições novas forem
oficializadas (geralmente na MD final da onda).

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
| 1 | strikes na avaliacao | entregue + reincorporada na Onda 10 |
| 2 | CNAE snapshot + dedup | entregue (a reincorporar na Onda 11) |
| 3 | CNAE dedup automatico | entregue (a reincorporar na Onda 12) |
| 4 | wire-up Configuracao_Inicial | entregue (a reincorporar na Onda 13) |
| 5 | form deterministico + Limpa_Base robusta | entregue (em V12-202-S baseline) |
| 6 | consolidacao documental + cleanup + HBN/Diataxis/llms.txt/AGENTS.md/Glasswing | entregue |
| 7 | familia IDM_* + RDZ_* (5 cenarios na bateria V2) | entregue (a reincorporar na Onda 15) |
| 8 | heuristica zero em todos os 13 forms | entregue (a reincorporar na Onda 16) |
| 9 | Importador V3 (substituiu V2) + Phase 1 | entregue (V3.2-Canonica-Onda10-Fechada) |
| **10** | **Reincorporacao Onda 1 (strikes) + restauracao Regra de Ouro 0002** | **FECHADA NA CANONICA 2026-05-02 com debito DT-3** |
| 11+ | proximas ondas - ver `auditoria/00_status/33_HANDOFF_NOVA_SESSAO_OPUS.md` | A INICIAR |
| FECH | tag v12.0.0203-rc1 + push GitHub | depois de Ondas 11-19 |

## ATENCAO ESPECIAL para IAs assumindo o bastao em 2026-05-02 ou depois

1. **A pasta canonica de import e UNICA**: `local-ai/vba_import/`. Ver
   `auditoria/00_status/32_ERRO_E_CORRECAO_PASTA_CANONICA.md` —
   documento de transparencia sobre erro recente de operar fora dela.
2. **NUNCA crie pastas paralelas** "para isolar experimentos". Use git
   branches ou backups em `auditoria/04_evidencias/<versao>/_backups/`.
3. **Releia a Regra de Ouro 0002** antes de qualquer proposta que
   envolva paths de import.
4. Se voce ler este arquivo apos 2026-05-02, comece pelo handoff em
   `auditoria/00_status/33_HANDOFF_NOVA_SESSAO_OPUS.md`.

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
