---
titulo: 14 — Procedimento de import Bloco A (Caminho C — Onda 17 fechamento)
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: operador (Mauricio)
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — chat 4 (Bloco A)
licenca-target: TPGL-v1.1
---

# 14. Procedimento de import — Bloco A (MICRO24)

## TL;DR

Pacote MICRO24 entrega Onda 17 fechada em **1 import unificado**: MD-17.2
(TV2_RunIntegridadeBase + RPT_BUGS_CONHECIDOS) + MD-17.3 (Quinteto Mínimo
+ renumeração Central V2 17 opções) + MD-17.4 (validação dupla Quinteto +
Quarteto). MD-18.2 (statusbar hint, toca form) movida para Bloco B.

**Ponto de rollback**: workbook `V12-202-Z010` (build `MD1E`).

**Workbook alvo após Bloco A verde**: `V12-202-Z011-onda17-fechada`.

## 1. Pré-import

### 1.1 Estado canônico vigente

| Campo | Valor |
|---|---|
| Workbook âncora | `V12-202-Z010` |
| Build label | `f7aa84f+ONDA17.MD1E-menu-renumeracao-limpeza-c3` |
| `APP_RELEASE_TEST_KEY` | `quarteto-2026-05-02` |
| Quarteto APROVADO | `VR_20260503_202623` (`V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0`, MANUAL=5) |

### 1.2 Validação shasum M11 (já executada — 2026-05-03 chat 4)

| Arquivo | sha1 | Espelho |
|---|---|---|
| `src/vba/Teste_V2_Roteiros.bas` | `6f88310fbcd1cd0339638e81ec3326deaf15065e` | `ABG` ✓ |
| `src/vba/App_Release.bas` | `6a5d19c50dd729a470911a5dc0cd14f0fcd362dd` | `AAX` ✓ |
| `src/vba/Teste_Validacao_Release.bas` | `c9f2dc7e5496f969751c370a4e670baf95ae89e8` | `ABH` ✓ |
| `src/vba/Central_Testes_V2.bas` | `33baaee06bfe796a6cf49dc9991f3bebf12fc3e5` | `ABE` ✓ |

**CRLF preservado nos 4 arquivos.** Sub/Function balance:
- `Teste_V2_Roteiros.bas` open=37 close=37 ✓
- `Teste_Validacao_Release.bas` open=36 close=36 ✓
- `Central_Testes_V2.bas` open=10 close=10 ✓
- `App_Release.bas` open=30 close=30 ✓

## 2. Sequência de import

### Etapa 1 — VBE Reset

```
Executar > Redefinir   (botão quadrado azul ou Ctrl+Pause/Break)
```

Não pular — sem reset o menu Compilar fica desabilitado (lição L7).

### Etapa 2 — Import V3 Delta MICRO24

Na janela Imediato:

```vba
ImportarPacoteV3_Delta "MICRO24", "f7aa84f+ONDA17.MD2-bloco-a-fechamento-onda17"
```

Esperado: log no Imediato confirmando 4/4 módulos importados:
```
ABG-Teste_V2_Roteiros.bas
AAX-App_Release.bas
ABH-Teste_Validacao_Release.bas
ABE-Central_Testes_V2.bas
```

Se o V3 reclamar "Manifesto vazio ou malformado", inspecionar
`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO24.txt` final — deve
ter bloco `# GRUPO_DELTA_MICRO24_*` + 4 linhas `M|001-modulo/...` separadas
dos comentários por linha em branco (lição M20 candidata).

### Etapa 3 — Compile manual

```
Depurar > Compilar VBAProject   →  deve passar com 0 erros
```

Se falhar: anotar primeira linha destacada e abrir handoff. Suspeitas
prováveis: chamada cross-module qualificada errada (L10) ou nome de campo
UDT (L14).

### Etapa 4 — Sanity smoke (3 comandos no Imediato)

```vba
?GetBuildImportado
'  -> deve retornar "f7aa84f+ONDA17.MD2-bloco-a-fechamento-onda17"

?GetReleaseTestKey
'  -> deve retornar "quinteto-2026-05-04"

TV2_RunIntegridadeBase
'  -> aba RPT_BUGS_CONHECIDOS criada (10 colunas A-J + header azul)
'  -> 1 linha em RPT_BUGS_CONHECIDOS: DT-17-REATIV-STRIKES
'  -> 4 linhas em RESULTADO_QA_V2 (suite=INTEGRIDADE_BASE,
'     cenários CS_INT_01..04 com OK ou MANUAL_ASSISTIDO)
'  -> Suite IntegridadeBase concluida (MsgBox)
```

### Etapa 5 — Idempotência empírica IntegridadeBase

```vba
TV2_RunIntegridadeBase
'  -> RESULTADO_QA_V2 ganha +4 linhas (mesmo número da Etapa 4)
'  -> RPT_BUGS_CONHECIDOS mantém mesma quantidade de bugs (delta=0;
'     UPSERT por BUG_ID atualiza linha existente, não cria nova)
```

Se RPT_BUGS_CONHECIDOS ganhar nova linha de DT-17-REATIV-STRIKES, é bug
de upsert — abrir handoff.

### Etapa 6 — Sanity menu Central V2

```vba
CT2_AbrirCentral
```

Esperado: InputBox com mensagem nova (17 opções contíguas):
- `[1] Quinteto Minimo *** OFICIAL ***`
- `[2] Quarteto Minimo`
- `[3] Trio Minimo`
- `[4] V1 Bateria Oficial`
- `[5..9] V2 suites`
- `[10..15] Visualização`
- `[16..17] Utilitários`

Default = "1". Cancelar a janela (Esc / Cancelar).

### Etapa 7 — Quinteto Mínimo (gate oficial novo)

```
Central V2 → opção [1]
   ou
?CT_ValidarRelease_QuintetoMinimo
```

Tempo esperado: ~12-15 min (Quarteto ~10min + IntegridadeBase ~30s).

Esperado: `RESULTADO=APROVADO` com sintaxe canônica:
```
V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0+IntegridadeBase=N/0
```
Onde `N` depende do estado das abas (4 quando workbook íntegro).

CSV gerado em: `auditoria/evidencias/V12.0.0203/ValidacaoReleaseQuinteto_V12_0_0203_VR_<timestamp>.csv`.

### Etapa 8 — Quarteto Mínimo (regressão zero)

```
Central V2 → opção [2]
   ou
?CT_ValidarRelease_QuartetoMinimo
```

Tempo esperado: ~10 min.

Esperado: `RESULTADO=APROVADO` com sintaxe **IDÊNTICA** ao MD-17.1.e:
```
V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0
```
MANUAL=5.

Idempotência da Onda 17 preservada — IntegridadeBase é PURE READ e não
contamina suites anteriores.

### Etapa 9 — Salvar como ancora

```
File > Save As → V12-202-Z011-onda17-fechada.xlsm
```

## 3. Reportar de volta para o chat

Cole no chat 4:

```
=== Bloco A — Quinteto + Quarteto ===
Build:           <output do ?GetBuildImportado>
Test key:        <output do ?GetReleaseTestKey>
Quinteto VR_id:  VR_<timestamp>
Quinteto sint.:  V1=N/F+V2_Smoke=N/F+V2_Canonica=N/F+E2E_Strikes=N/F+IntegridadeBase=N/F
Quinteto stat.:  APROVADO / REPROVADO
Quarteto VR_id:  VR_<timestamp>
Quarteto sint.:  V1=N/F+V2_Smoke=N/F+V2_Canonica=N/F+E2E_Strikes=N/F
Quarteto stat.:  APROVADO / REPROVADO
Aba RPT_BUGS_CONHECIDOS criada: SIM / NAO
Idempotência IntegridadeBase: SIM / NAO (delta linhas RESULTADO_QA_V2 = 4 em ambas runs?)
Workbook salvo como: V12-202-Z011-onda17-fechada
```

## 4. Em caso de regressão

| Sintoma | Hipótese | Ação |
|---|---|---|
| Compile falha em Roteiros | L10 (qualificação cross-module) ou L14 (campo UDT) | reportar primeira linha destacada |
| TV2_RunIntegridadeBase quebra | helper Private faltando ou campo inexistente | reportar `Err.Number + Err.Description` do MsgBox de erro fatal |
| RPT_BUGS_CONHECIDOS não cria | erro em `TV2_AbaRPTBugsGarantirEstrutura` | inspecionar via Imediato `?TV2_AbaRPTBugsGarantirEstrutura` (helper Private — chamar via wrapper) |
| Quinteto APROVADO mas Quarteto REPROVADO | regressão em alguma das 4 suites originais | inspecionar CSV de falhas + RESULTADO_QA_V2 |
| Menu Central V2 mostra "Opção inválida" para `1`-`17` | Select Case mal mapeado | inspecionar `CT2_AbrirCentral` linhas Case |

**Rollback**: abrir `V12-202-Z010.xlsm` original (mantido). M14 trivialmente
satisfeito (1 única opção de rollback, todos os 4 arquivos no pacote).

## 5. Documentos relacionados

- [Manifesto MICRO24](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO24.txt)
- [Readback MD-17.2](../../.hbn/readbacks/0018-onda17-md17-2.json) (decisões arquiteturais firmes)
- [Transição chat 3 → 4](../../auditoria/00_status/51_TRANSICAO_CHAT_3_PARA_4_2026_05_03.md)
- [Caminho C — memória](../../../.claude/projects/-Users-macbookpro-Projetos-Credenciamento/memory/project_caminho_c_blocos_onda17_18.md)
- [Débito DT-17-REATIV-STRIKES (Onda 18 spec)](../../auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md)
- [PHAGOCYTOSIS L1-L27 + M1-M19](../../usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md)

## 6. Markers HBN V2 ativos

- 🔵 **HBN HANDOFF READY** — pacote MICRO24 pronto para import operador
- 🟢 **HBN CHECKPOINT CLEAN** — espelho M11 com shasum batendo + CRLF + Sub/Function balance
- 🟣 **HBN GAMMA OFFLINE VALIDATED** — manifesto MICRO24 com bloco GRUPO_+M| (lição M20 candidata aplicada)

## Versão

- v1.0 — 2026-05-03 — procedimento inicial Bloco A (MICRO24).
