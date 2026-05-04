---
titulo: ONDA 10 — Procedimento Microdelta 1.4 (Teste_V2_Engine grava defaults strikes)
natureza-do-documento: procedimento operacional
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-01
autor: Claude Opus 4.7 (sessao Cowork)
---

# 64. Procedimento Microdelta 1.4 — TV2_SetConfigCanonica grava defaults strikes

> **Microdelta 1.4 evolui a infraestrutura de teste oficial.** Adiciona
> 2 linhas em `TV2_SetConfigCanonica` (em `Teste_V2_Engine`) que
> gravam `MAX_STRIKES=1` e `DIAS_SUSPENSAO_STRIKE=0` em CONFIG durante
> o setup canonico. Isso prepara o terreno para o Microdelta 1.3 (bloco
> 7b em Svc_Avaliacao) ler valores conhecidos e preservar equivalencia
> comportamental no `CS_14`. Risco: muito baixo — so adicao em rotina
> de setup de teste.
>
> Este microdelta e **em si** um exemplo do principio "testes via
> interface oficial, evoluindo junto com o codigo de producao".

## 0. Pre-condicoes

| Item | Estado esperado |
|---|---|
| Microdelta 1.2 | APROVADO (TV2_20260501_184237 SMOKE 14/0) |
| Build label atual | `f7aa84f+ONDA10.MICRO02-Svc_Rodizio-incremental` |
| Manifesto delta | `000-MANIFESTO-V3-DELTA-MICRO04.txt` (criado) |
| Espelho `ABF-Teste_V2_Engine.bas` | atualizado (2583 → 2592 linhas, +9) |
| Espelho `AAX-App_Release.bas` | bumpado para MICRO04 |

## 1. Comando único no Imediato

```
ImportarPacoteV3_Delta "MICRO04", "f7aa84f+ONDA10.MICRO04-Teste_V2_Engine-incremental"
```

Esperado em `IMPORT_LOG_V3`:
- BACKUP OK
- BUMP_BUILD_LABEL OK (novo build label)
- GRUPO_INICIO MICRO04 (itens=2)
- MODULO_OK Teste_V2_Engine (~2592 linhas)
- MODULO_OK App_Release (~171 linhas)
- MsgBox: M=2 | F=0 | err=0 | skip=0

## 2. Compile manual (gate sintático)

VBE → `Depurar` → `Compilar VBAProject` — passa limpo.

## 3. Smoke via infraestrutura oficial

Imediato:

```
TV2_RunSmoke
```

Esperado: `OK=14 | FALHA=0 | MANUAL=0` (~30 segundos).

A nova gravacao em CONFIG (MAX_STRIKES=1 e DIAS_SUSPENSAO_STRIKE=0)
ocorre durante o setup canonico do TV2_RunSmoke. Se nenhum cenario
falhar, a gravacao funcionou e nao introduziu regressao.

## 4. Verificacao adicional (opcional, 10s)

Para confirmar visualmente que a gravacao aconteceu, abra a aba
`CONFIG` do workbook e verifique:
- Coluna L (MAX_STRIKES): valor 1
- Coluna M (DIAS_SUSPENSAO_STRIKE): valor 0

Se as colunas L/M nao existirem na CONFIG, e o sintoma esperado de
"baseline tem CONFIG sem essas colunas". Nesse caso, verifique se
o setup TV2_PrepararBaselineCanonica (chamado pelo Smoke) cria as
colunas — pode ser que o teste passe mesmo assim porque grava na
posicao numerica certa.

## 5. Reportar verde

Resposta sugerida no chat:

```
Microdelta 1.4 verde. Build f7aa84f+ONDA10.MICRO04-Teste_V2_Engine-incremental.
Compile limpo. TV2_RunSmoke 14/0. Pode prosseguir para 1.3.
```

## 6. Em caso de falha

| Sintoma | Ação |
|---|---|
| Compile falha em COL_CFG_MAX_STRIKES ou COL_CFG_DIAS_SUSPENSAO_STRIKE | Constantes faltando em Const_Colunas (Phase A confirmou que estao lá; reportar) |
| TV2_RunSmoke falha em algum cenario | Capture o ID do cenario falhado + numero de OK/FALHA, reporte |
| MsgBox V3 reporta `err > 0` | Verificar IMPORT_LOG_V3 |

## 7. Checklist final

- [ ] `ImportarPacoteV3_Delta "MICRO04", "..."` executou sem erro
- [ ] IMPORT_LOG_V3: BACKUP + BUMP + 2x MODULO_OK
- [ ] Compile manual passou limpo
- [ ] TV2_RunSmoke retornou 14/0
- [ ] `?GetBuildImportado` mostra MICRO04
- [ ] Reportei verde no chat
