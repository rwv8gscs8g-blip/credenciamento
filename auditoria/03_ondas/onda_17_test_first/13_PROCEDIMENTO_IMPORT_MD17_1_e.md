---
titulo: Procedimento de import MD-17.1.e — Limpeza C3 + renumeracao menu Central V2
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — sessao 3 (chat 3 / VS Code)
licenca-target: TPGL-v1.1
---

# 13 — Procedimento de import MD-17.1.e

## Tema

**Limpeza C3 do menu Central V2 + renumeracao semantica + porta unica V1 dentro V2 + atalho "Limpar testes antigos".**

Decisoes operador 2026-05-03 (hearback Q-MD17.1.e):

| # | Decisao |
|---|---|
| 2 | Saem da MENSAGEM `[2] Smoke assistido`, `[4] Stress assistido`, `[6] Roteiro assistido V2`. Subs ficam Public callable VBE. |
| 3a | Estrutura semantica: GATES → V1 → V2 → VISUALIZACAO → UTILITARIOS (16 opcoes contiguas). |
| 3b (opc. 2) | Quinteto Minimo `[1]` reservado para MD-17.3. Hoje `[1]` = Quarteto Minimo (gate oficial). |
| 3c | V1 dentro V2 (porta unica). Nova `[3]` V1 Bateria Oficial + nova `[16]` Limpar testes antigos. Central V1 (`CT_AbrirCentral`) intacto nesta MD. |

## Pre-condicoes

| Item | Esperado |
|---|---|
| Workbook ancora | `V12-202-Z008` (mais recente; herda md1d3) |
| Build atual no workbook | `f7aa84f+ONDA17.MD1D3-hotfix-v1visibility-csvmsg` |
| Quarteto pre-import | `VR_20260503_181718` APROVADO (V1=171/0 + V2_Smoke=27/0 + V2_Canonica=23/0 + E2E_Strikes=65/0; MANUAL=5) |
| `src/vba/` ↔ `local-ai/vba_import/` | shasum batendo (validado pre-edit) |
| Idempotencia empirica | confirmada Run 1 + Run 2 no chat 2 |

## Sequencia M11 (shasum src ↔ pacote)

| Arquivo | sha1 (pos-MD-17.1.e) |
|---|---|
| `src/vba/Central_Testes_V2.bas` ↔ `ABE-Central_Testes_V2.bas` | `0f50dfcb4762aee36066bb6e746015e2d24daa3e` |
| `src/vba/Central_Testes.bas` ↔ `AAZ-Central_Testes.bas` | `f9221a2c4ae142ca85791f0d6b39e4ed1617c1c1` |
| `src/vba/App_Release.bas` ↔ `AAX-App_Release.bas` | `4e7b3d6c5fe6caec56449a22e99b6c4f6e4fc3b5` |

CRLF preservado. Sub/Function balance: Central V2 = 10/10 + 0/0; Central V1 = 19/19 + 3/3; App_Release = 0/0 + 30/30.

## Mudancas resumo

| Arquivo | Tipo de mudanca |
|---|---|
| `Central_Testes_V2.bas` | (1) string `prompt` substituida (3 assistidos saem da mensagem); (2) `Select Case op` novo mapeamento 1-16; (3) default InputBox `"20"` → `"1"`; (4) 2 Subs Public novas (`CT2_ExecutarBateriaV1`, `CT2_ExecutarLimparTestes`); (5) Subs assistidos antigos PRESERVADOS Public callable VBE |
| `Central_Testes.bas` | adiciona Sub Public `CT_LimparTestesAntigos` no fim do modulo (delega para `CT_LimparArtefatosTesteV1` Private ja existente) |
| `App_Release.bas` | bump label + timestamp + comentario MD-17.1.e (16 linhas) |

## Procedimento operacional

### Passo 0 — Backup de seguranca antes de importar

```
0a. Salvar workbook atual como copia trabalho (Arquivo > Salvar Como)
    nome sugerido: V12-202-Z008-pre-md1e.xlsm
0b. Mantenha aberto o V12-202-Z008 atual (que sera modificado).
```

> Rollback se algo der errado: fechar sem salvar e reabrir o backup
> `V12-202-Z008/03_05_2026 18_43_01PlanilhaCredenciamento-Homologacao-V3.xlsm`.

### Passo 1-4 — Reset, Import, Compile, Build check

```
1. VBE > Executar > Redefinir
2. ImportarPacoteV3_Delta "MICRO23", "f7aa84f+ONDA17.MD1E-menu-renumeracao-limpeza-c3"
3. VBE > Depurar > Compilar VBAProject  (esperado: 0 erros)
4. Janela Imediato: ?GetBuildImportado
   esperado: "f7aa84f+ONDA17.MD1E-menu-renumeracao-limpeza-c3"
```

### Passo 5 — Verificacao visual da mensagem nova

```
5. CT2_AbrirCentral
```

Esperado na tela:

```
=== CENTRAL DE TESTES V2 ===
Build: f7aa84f+ONDA17.MD1E-menu-renumeracao-limpeza-c3
Gate oficial vigente: [1] Quarteto Minimo

>> GATES DE RELEASE (rodar antes de homologar)
[1] Quarteto Minimo  (V1 + V2 Smoke + V2 Canonica + V2 E2E Strikes)  *** OFICIAL ***
[2] Trio Minimo      (V1 + V2 Smoke + V2 Canonica)  -- legado

>> BATERIA V1 (executavel direto)
[3] V1 - Bateria Oficial completa (~5 min)

>> BATERIA V2 (suites parciais)
[4] V2 Smoke rapido            (~30 s)
[5] V2 Suite Canonica           (~3 min)
[6] V2 Stress deterministico    (~3 min)
[7] V2 Filtros deterministicos  (~1 min)
[8] V2 E2E Strikes              (~2 min)

>> VISUALIZACAO (abrir aba)
[9]  RESULTADO_QA_V2
[10] CATALOGO_CENARIOS_V2
[11] HISTORICO_QA_V2
[12] TESTE_TRILHA
[13] AUDIT_TESTES
[14] EVOLUCAO_TESTES (regressao + media movel)

>> UTILITARIOS
[15] Roteiro Assistido V2 (navegacao guiada)
[16] Limpar testes antigos

Digite o numero:  [1]
```

Confirme: 16 opcoes contiguas, sem `[2] Smoke assistido` / `[4] Stress assistido` / `[6] Roteiro assistido V2` antigos. Default = `1`.

### Passo 6 — Smoke do roteamento (opcional mas recomendado)

Teste rapido cada opcao chamando `CT2_AbrirCentral` e digitando o numero. Suficiente verificar:

| Opcao | Acao esperada |
|---|---|
| `1` | abre confirmacao + roda Quarteto |
| `3` | abre `RunBateriaOficial` (V1 com prompt seu de "limpar testes anteriores?") |
| `15` | abre Roteiro Assistido V2 (aba ROTEIRO_ASSISTIDO_V2) |
| `16` | abre MsgBox de confirmacao com lista de abas + default NAO |

Cancele `Bateria Oficial` no Passo 6 (prompt "Cancela com Não") para nao gastar tempo. Em `[16]` clique **NÃO** na confirmacao para nao apagar artefatos antes do Quarteto final.

### Passo 7 — Quarteto APROVADO sintaxe IDENTICA

```
7. CT_ValidarRelease_QuartetoMinimo
```

Esperado:
- Tempo: similar a md1d3 (~13min — sem regressao perf)
- Sintaxe: `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0` (MANUAL=5)
- RESULTADO_GERAL: `APROVADO`
- VR id: `VR_<timestamp>`
- CSV resumo gerado em `auditoria/evidencias/V12.0.0203/`

### Passo 8 — Smoke das Subs assistidas preservadas

Janela Imediato:

```
?CT2_ExecutarSmokeAssistido
?CT2_ExecutarStressAssistido
```

Cancele os prompts de cada execucao com Esc/Cancelar. Esperado: as Subs disparam (sao Public, callable). Se janela Imediato retornar "Sub or Function not defined" eh regressao — abrir.

### Passo 9 — Backup ancora pos-MD-17.1.e

```
9. Salvar workbook como V12-202-Z009-onda17-md1e.xlsm na raiz do projeto.
```

### Passo 10 — Hearback de escrita-em-codigo

Reportar ao Claude:

```
MD-17.1.e — APROVADO
Build: f7aa84f+ONDA17.MD1E-menu-renumeracao-limpeza-c3
VR: VR_<timestamp>
Sintaxe: <colar string>
Tempo: <colar>
Mensagem nova OK / Smoke assistido callable: sim/nao
Backup: V12-202-Z009-onda17-md1e
```

## Rollback (se necessario)

| Falha | Acao |
|---|---|
| Compile manual com erro | Verificar erro especifico — provavelmente assinatura quebrada. Reportar ao Claude antes de mexer. |
| `Sub or Function not defined: CT_LimparTestesAntigos` em `[16]` | Conferir que `Central_Testes.bas` (AAZ) foi importado. Re-rodar `ImportarPacoteV3_Delta "MICRO23"`. |
| Quarteto reprova com sintaxe diferente do md1d3 | Bug de roteamento. Fechar Excel sem salvar; reabrir backup `V12-202-Z008/03_05_2026 18_43_01PlanilhaCredenciamento-Homologacao-V3.xlsm`. Reportar ao Claude. |
| Quarteto trava ou demora muito | Cancelar (Esc), rollback completo via Z008. |

## Pos-aprovacao

- Atualizar `.hbn/relay/INDEX.md` (proprietario-bastao + ancora-estavel-atual + proxima-acao)
- Gerar `.hbn/results/0017-exec-onda17-md17-1-e.json` (ERP)
- Atualizar `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` se houver licao destilada
- Continuar com **MD-17.2** (`TV2_RunIntegridadeBase` + `RPT_BUGS_CONHECIDOS`)

## Documentos relacionados

- [Readback `0017-onda17-md17-1-e.json`](../../../.hbn/readbacks/0017-onda17-md17-1-e.json)
- [Manifesto `MICRO23`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO23.txt)
- [49 — Transicao chat 2 → 3](../../00_status/49_TRANSICAO_CHAT_NOVO_OPUS_47_2026_05_03_pt2.md)
- [PHAGOCYTOSIS L1-L27 + M1-M19](../../../usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md)

## Versao

- v1.0 — 2026-05-03 — registro inicial.
