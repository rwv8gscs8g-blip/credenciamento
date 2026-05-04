---
titulo: Onda 9 antecipada — Importador V3 — Tecnico (Phase 1)
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-04-30
---

# Onda 9 antecipada — Importador V3 — documento tecnico (Phase 1)

## Por que existe

A V2 sofreu 13 hotfixes iterativos sem convergencia. A causa raiz foi
identificada em diagnostico de retomada: **`cm.DeleteLines` +
`cm.AddFromString` no Excel for Mac via SMB nao e deterministico**.
Multiplos modulos terminaram com codigo duplicado (160 linhas onde
esperava-se 94), o `Compile manual` falhou, e o trio minimo nao mais
podia ser executado.

V3 nasce do zero, sem heranca de hotfix. Mantem 4 dos 5 contratos da
V2 (manifesto unico, ordem topologica, tabu Mod_Types, backup
automatico) e reescreve um (estrategia de import).

## Cinco contratos V3

| # | Contrato | V3 |
|---|---|---|
| 1 | Manifesto e fonte unica | mantido (formato compativel V2) |
| 2 | **Estrategia de import** | **Remove + Import** sempre, com pos-validacao por `CountOfLines`. Nunca `DeleteLines+AddFromString` em modulos `.bas`. |
| 3 | Tabu Mod_Types | modo-dependente: Estabilizado pula se ja existe; Fresh importa primeiro |
| 4 | Forms via `.code-only.txt` em estabilizado, `.frm+.frx` em fresh | mantido com deteccao automatica de modo |
| 5 | Backup automatico antes de real | antes de qualquer Remove |

## Dois modos de execucao

| Modo | Trigger automatico | Estrategia por modulo | Estrategia por form |
|---|---|---|---|
| Fresh | `VBComponents.Count <= 5` (excluindo Documents) | `VBComponents.Import(arquivo)` direto | `Import(arquivo.frm)` (carrega `.frx` automaticamente) |
| Estabilizado | `Count > 5` | `Remove` -> `Import` -> validar `CountOfLines` | `.code-only.txt`: `cm.DeleteLines + cm.AddFromString` (preserva `.frx`) |

Em ambos os modos, **NUNCA** `DeleteLines+AddFromString` para modulos `.bas`.
So aceitavel para forms (sem substituir `.frx`).

## Anti-auto-import

V3 nao faz parte do manifesto. Bootstrap externo
(`local-ai/vba_import/Importador_V3_Bootstrap.bas`, raiz, sem prefixo)
carrega V3 no workbook. V3 nunca importa a si mesmo. Bug historico
da V2 (auto-referencia corrompendo codigo em execucao) eliminado por
design.

## Validacao apos cada modulo

Para cada item importado, V3 executa em sequencia:

1. **Contagem de linhas esperada** (lida do source antes de qualquer mudanca)
2. **Remove + Import**
3. **`CountOfLines` real** apos import -> comparar com esperado (tolerancia 2 linhas para diferencas EOL terminal)
4. Se divergir -> abort (proximos modulos nao sao tocados); operador roda restore manual a partir do backup
5. Apos cada grupo -> `VBProject.Compile`. Se falhar -> abort

A falta dessa cadeia foi o que escondeu o bug da v12 da V2.

## Universo Phase 1

Phase 1 reproduz **fielmente** o conjunto que ja compila no baseline
V12-202-R (build `f7aa84f+ONDA05-em-homologacao`, trio minimo
VR_20260430_225826 = 171/0 + 14/0 + 20/0 APROVADO).

| Categoria | Qtd | Detalhe |
|---|---|---|
| Modulos `.bas` | 35 | mesmo conjunto do V12-202-R (sem `Emergencia_CNAE`, sem `Importador_V2`, sem `Importador_V3`) |
| Forms `.frm` | 13 | mesmo conjunto do V12-202-R |
| **Total** | **48 itens** | |

## Lessons learned absorvidas

| Licao | Mecanismo na V3 |
|---|---|
| (a) ultima linha em branco ausente | `IV3_LerArquivoBinarioComoTexto` adiciona terminal `vbCrLf` se ausente |
| (b) formatacao incorreta (BOM/EOL) | mesmo helper normaliza CR/LF/CRLF -> CRLF e remove BOM UTF-8 |
| (c) ordem errada -> erro Tconfig | manifesto agrupado + `compile-after-each-group` aborta antes do proximo grupo |
| (d) Mod_Types/AAA_Types | modo Fresh trata Mod_Types como AAA na ordem; modo Estabilizado pula |

## Arquivos entregues nesta Onda

| Arquivo | Tamanho | Funcao |
|---|---|---|
| `src/vba/Importador_V3.bas` | 849 linhas | Engine V3 (fonte de verdade) |
| `local-ai/vba_import/001-modulo/ABK-Importador_V3.bas` | 849 linhas | Espelho com prefixo (Regra de Ouro) |
| `local-ai/vba_import/Importador_V3_Bootstrap.bas` | ~95 linhas | Bootstrap descartavel (raiz) |
| `local-ai/vba_import/000-MANIFESTO-V3-PHASE1.txt` | ~70 linhas | Manifesto Phase 1 (35M+13F) |
| `auditoria/03_ondas/onda_09_importador_v3/50_TECNICO.md` | este arquivo | doc tecnico |
| `auditoria/03_ondas/onda_09_importador_v3/51_PROCEDIMENTO.md` | proximo arquivo | passo-a-passo operador |
| `.hbn/readbacks/0009-onda09-v3-phase1.json` | ~100 linhas | readback HBN |

## Gates de aceitacao Phase 1

Phase 1 e considerada APROVADA quando:

1. Operador executa procedimento `51_PROCEDIMENTO.md` Phase 0+1 sem erro
2. `IMPORT_LOG_V3` mostra **35 OK_M** + **13 OK_F** (ou **34 OK_M + 1 SKIP** se Mod_Types pulado em Estabilizado) + **0 FALHA**
3. `VBE > Debug > Compile VBAProject` passa limpo
4. `CT_ValidarRelease_TrioMinimo` retorna 171/0 + 14/0 + 20/0
5. CSV de validacao salvo em `auditoria/04_evidencias/V12.0.0203/ValidacaoRelease_V12_0_0203_VR_<ts>.csv`

Sem os 5 gates, Phase 1 NAO esta aprovada e Phase 2 nao abre.

## Limites desta entrega

V3 ainda NAO e prova empirica de que `Remove + Import` e deterministico
em Mac SMB — a confianca vem de **eliminar** o caminho comprovadamente
ruim (DeleteLines+AddFromString in-place) e da semantica documentada
da API VBE para `Import`. A primeira execucao Phase 1 e que ratifica
empiricamente.

## Proximas fases (apos Phase 1 verde)

| Phase | Tema | Pre-requisito |
|---|---|---|
| 2 | Modo Fresh em workbook `.xlsx` em branco -> 35M+13F do zero | Phase 1 verde |
| 3 | Renomeacao L2 (se decidida no futuro) | Phase 2 verde + decisao operador |
| 4 | Re-aplicar Ondas 6 + 7 + 8 sobre baseline V3 (uma a uma com trio entre) | Phase 2 verde |
| F | tag `v12.0.0203` + push GitHub | Phase 4 verde |

## Referencias

- `.hbn/relay/IMPORTADOR_V2_DIAGNOSTICO_RETOMADA.md` (diagnostico raiz)
- `.hbn/knowledge/0008-importador-v2-arquitetura.md` (5 contratos V2)
- `.hbn/readbacks/0009-onda09-v3-phase1.json` (readback HBN)
- `local-ai/vba_import/000-REGRA-OURO.md` (regra de ouro)
- `V12-202-R/auditoria/evidencias/V12.0.0203/ValidacaoRelease_V12_0_0203_VR_20260430_225826.csv` (baseline)
