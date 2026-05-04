---
titulo: ONDA 10 — Procedimento Microdelta 1.2 (Svc_Rodizio.Suspender com params opcionais)
natureza-do-documento: procedimento operacional
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-01
autor: Claude Opus 4.7 (sessao Cowork)
---

# 63. Procedimento Microdelta 1.2 — Svc_Rodizio.Suspender com parametros opcionais

> **Microdelta 1.2 amplia a assinatura de `Svc_Rodizio.Suspender`** com
> dois parametros opcionais (`diasSuspensao` default 0 e `motivo` default
> ""). Quando `diasSuspensao > 0`, a empresa e suspensa por N dias com
> auditoria `BASE=DIAS`. Caso contrario cai no comportamento legado
> (suspensao em meses via `PERIODO_SUSPENSAO_MESES`, auditoria
> `BASE=MESES`). Risco: BAIXO. Retrocompatibilidade preservada por
> design — chamadas antigas `Suspender(EMP_ID)` funcionam identicas.

## 0. Pre-condicoes

| Item | Estado esperado |
|---|---|
| Microdelta 1.1 | APROVADO (`VR_20260501_180949`) |
| Build label atual | `f7aa84f+ONDA10.MICRO01-Repo_Avaliacao-incremental` |
| Manifesto delta | `local-ai/vba_import_v3_phase1/000-MANIFESTO-V3-DELTA-MICRO02.txt` (criado) |
| Espelho `AAP-Svc_Rodizio.bas` | atualizado pelo Claude (446 → 465 linhas — função Suspender substituída in-place) |
| Espelho `AAX-App_Release.bas` | atualizado pelo Claude (build label MICRO02) |

## 1. Reset VBE

1.1. `Alt+F11` → reset (botão azul) se necessário.

## 2. Confirmar V3 ainda V3.1-Onda10-Delta

2.1. Imediato: `ImportarPacoteV3_Status` → cabeçalho mostra `(V3.1-Onda10-Delta)`.

## 3. Executar import delta com bump auto

3.1. Imediato — comando completo (copiar inteiro):

```
ImportarPacoteV3_Delta "MICRO02", "f7aa84f+ONDA10.MICRO02-Svc_Rodizio-incremental"
```

3.2. Logs esperados em `IMPORT_LOG_V3` + Imediato:

- `[V3 OK] BACKUP | * | <path> | Backup completo gerado`
- `[V3 OK] BUMP_BUILD_LABEL | * | <espelho> | delta=MICRO02 | build=...incremental`
- `[V3 OK] GRUPO_INICIO | GRUPO_DELTA_MICRO02_SVC_RODIZIO | itens=2`
- `[V3 OK] MODULO_OK | ... | Svc_Rodizio (465 linhas)`
- `[V3 OK] MODULO_OK | ... | App_Release (171 linhas)`
- MsgBox final: `M=2 | F=0 | err=0 | skip=0`

## 4. Compile manual (gate critico)

4.1. VBE → `Depurar` → `Compilar VBAProject`.

4.2. **Atenção especial:** `Svc_Rodizio.Suspender` foi reescrito.
Outros módulos (`Svc_Avaliacao`, `Teste_V2_Roteiros`, etc.) chamam
`Suspender`. Compile vai validar que todas as chamadas existentes
continuam compatíveis com a nova assinatura (parâmetros opcionais).

4.3. Resultado esperado: compile passa **limpo**. Se aparecer erro
em algum módulo chamando `Suspender`, NÃO PROSSIGA. Restore do
backup automático e reporte.

## 5. Smoke check via infraestrutura existente — TV2_RunSmoke

> **MUDANCA DE ESTRATEGIA (Mauricio 2026-05-01):** smoke ad-hoc no
> Imediato consome tempo, gera iteracoes desnecessarias e nao
> agrega valor permanente. A partir deste microdelta o smoke passa
> a ser **`TV2_RunSmoke`** — suite oficial de smoke que ja existe
> no workbook, roda em ~30 segundos e valida em alto nivel que
> tudo compila e funciona. Trio minimo (~12 min) so no fim de cada
> ONDA completa, nao a cada microdelta.

5.1. Imediato:

```
TV2_RunSmoke
```

5.2. Resultado esperado: ao final aparece linha
`SMOKE V2: 14/0` ou similar (14 cenarios, 0 falhas) na imediata
ou em MsgBox de conclusao.

5.3. Se TV2_RunSmoke retornar 14/0:
- Compile + smoke validados
- Microdelta 1.2 considerado aprovado para passar para 1.4
- Trio mínimo completo sera rodado ao final da Onda 10 (apos 1.5
  fechar verde)

5.4. Se TV2_RunSmoke falhar ou der erro:
- Capture o numero de cenarios falhados + o nome do primeiro a falhar
- NAO salve o workbook
- Reporte para Claude

## 6. Confirmar bump

6.1. Imediato: `?GetBuildImportado`

6.2. Resultado esperado:
`f7aa84f+ONDA10.MICRO02-Svc_Rodizio-incremental`.

## 7. Gate trio mínimo — APENAS NO FIM DA ONDA

> **Politica oficializada 2026-05-01:** Trio minimo (~12 min) so e
> rodado **uma vez ao final de cada Onda completa** (apos Microdelta
> 1.5 fechar). Microdeltas individuais usam Compile + TV2_RunSmoke
> como gates. Isso preserva tempo do operador sem perder
> auditabilidade — TV2_RunSmoke ja exercita as funcoes principais
> e Compile pega regressoes de tipo/sintaxe.

Pular este passo no Microdelta 1.2. Vai ser executado uma unica
vez apos 1.5 verde.

## 8. Reportar verde para Claude

```
Microdelta 1.2 verde. Build f7aa84f+ONDA10.MICRO02-Svc_Rodizio-incremental.
Compile limpo. Smoke ambas chamadas (antiga + nova) OK. Trio 171/0+14/0+20/0.
Pode prosseguir para 1.4.
```

> Lembrete: a próxima é **1.4** (não 1.3) — `Teste_V2_Engine` grava
> defaults de strikes em CONFIG canônica antes do bloco 7b ser
> ativado em `Svc_Avaliacao` (1.3). Ordem deliberada para preservar
> equivalência comportamental no `CS_14`.

## 9. Em caso de problemas

| Sintoma | Acao |
|---|---|
| Compile falha em módulo chamando `Suspender` | Provavelmente chamada com argumentos posicionais errados — capturar erro e linha exata |
| Trio `CS_14` falha | Regressão por mudança de comportamento — restore + reporte (improvável, mas crítico) |
| Suspender com 3 args ainda dá "argumento não opcional" | Re-import não pegou nova versão — verificar IMPORT_LOG_V3 |

## 10. Checklist final

- [ ] `ImportarPacoteV3_Status` retorna V3.1-Onda10-Delta
- [ ] Comando delta MICRO02 executou sem erro
- [ ] IMPORT_LOG_V3: BACKUP OK + BUMP OK + 2x MODULO_OK
- [ ] Compile manual passou limpo
- [ ] TV2_RunSmoke retornou 14/0 (sem falhas)
- [ ] `?GetBuildImportado` mostra MICRO02 (ou MICRO02-fix1 se houve correcao)
- [ ] Reportei verde no chat
- [ ] Trio mínimo NAO rodado neste microdelta (sera rodado apos 1.5 verde)
