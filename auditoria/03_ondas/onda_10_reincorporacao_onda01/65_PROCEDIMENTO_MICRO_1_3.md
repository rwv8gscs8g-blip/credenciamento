---
titulo: ONDA 10 — Procedimento Microdelta 1.3 (Svc_Avaliacao bloco 7b strikes ATIVO em producao)
natureza-do-documento: procedimento operacional
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-01
autor: Claude Opus 4.7 (sessao Cowork)
---

# 65. Procedimento Microdelta 1.3 — Svc_Avaliacao bloco 7b ATIVO

> **Microdelta 1.3 e o ponto de virada da Onda 10.** A regra de
> strikes finalmente passa a ser EXECUTADA em producao quando uma
> avaliacao com media abaixo do corte e registrada. Tudo que veio
> antes (1.1 ContarStrikes, 1.2 Suspender params, 1.4 CONFIG canonica)
> existia mas nao era acionado. Agora aciona.
>
> Risco: medio. Toca caminho critico de producao. Defesa: como CONFIG
> canonica tem MAX_STRIKES=1 + DIAS_SUSPENSAO_STRIKE=0, o
> comportamento OBSERVAVEL (CS_14 do TV2_RunCanonicoFundacao) e
> identico ao baseline — primeiro strike suspende, fallback meses.
> O ganho real fica na **auditoria detalhada** (STRIKES=N/MAX gravados
> no audit_log).

## 0. Pre-condicoes

| Item | Estado esperado |
|---|---|
| Microdelta 1.4 | APROVADO (TV2_20260501_185512 SMOKE 14/0) |
| Build label atual | `f7aa84f+ONDA10.MICRO04-Teste_V2_Engine-incremental` |
| Manifesto delta | `000-MANIFESTO-V3-DELTA-MICRO03.txt` (criado) |
| Espelho `AAS-Svc_Avaliacao.bas` | atualizado (414 → 453 linhas, +39) |
| Dependencias garantidas | `ContarStrikesPorEmpresa` (1.1), `Suspender(EMP, dias, motivo)` (1.2), `MAX_STRIKES`/`DIAS_SUSPENSAO_STRIKE` em CONFIG canonica (1.4) — todos no workbook |

## 1. Comando único no Imediato (fix1 — qualificacao Repo_Avaliacao removida)

> **HISTÓRICO:** primeira tentativa MICRO03 foi importada mas falhou
> em Compile manual com "Método ou membro de dados não encontrado"
> destacando `.ContarStrikesPorEmpresa`. Causa: VBA standard module
> nao aceita qualificacao `Modulo.Funcao(...)` em todas as versoes.
> Padrao do projeto e chamada DIRETA (`Funcao(...)`). Espelho
> corrigido — re-import com label fix1.

```
ImportarPacoteV3_Delta "MICRO03", "f7aa84f+ONDA10.MICRO03-Svc_Avaliacao-fix1-incremental"
```

Esperado em `IMPORT_LOG_V3`:
- BACKUP OK
- BUMP_BUILD_LABEL OK (delta=MICRO03, build=...incremental)
- GRUPO_INICIO MICRO03 (itens=2)
- MODULO_OK Svc_Avaliacao (~453 linhas)
- MODULO_OK App_Release (~171 linhas)
- MsgBox: M=2 | F=0 | err=0 | skip=0

## 2. Compile manual (gate sintatico)

VBE → `Depurar` → `Compilar VBAProject` — passa limpo.

> Atencao: Svc_Avaliacao agora consulta `Repo_Avaliacao.ContarStrikesPorEmpresa`
> (1.1) e chama `Suspender(EMP_ID, dias, motivo)` (1.2). Se compile
> falhar, indica que algum dos microdeltas anteriores nao esta
> efetivado — restore + reportar.

## 3. Smoke via infraestrutura oficial

Imediato:

```
TV2_RunSmoke
```

Esperado: `OK=14 | FALHA=0 | MANUAL=0` (~30s).

> CS_14 e o cenario sensivel — testa suspensao por nota baixa. Como
> CONFIG canonica grava MAX_STRIKES=1, o comportamento e identico ao
> baseline. Se CS_14 falhar, restore e reportar imediatamente.

## 4. Reportar verde

```
Microdelta 1.3 verde. Build f7aa84f+ONDA10.MICRO03-Svc_Avaliacao-incremental.
Compile limpo. TV2_RunSmoke 14/0. Pode prosseguir para 1.5 (Strikes Suite).
```

## 5. Em caso de falha

| Sintoma | Ação |
|---|---|
| Compile falha em `Repo_Avaliacao.ContarStrikesPorEmpresa` | Microdelta 1.1 nao foi efetivado — verificar via `?Repo_Avaliacao.ContarStrikesPorEmpresa` |
| Compile falha em `Suspender(...)` com 3 args | Microdelta 1.2 nao foi efetivado — restore para baseline antes de 1.3 |
| TV2_RunSmoke falha em CS_14 | Regressao critica em suspensao por nota baixa — capturar evidencia, restore |
| TV2_RunSmoke falha em outros cenarios | Regressao indireta — capturar ID + numero falhas, reporte |

## 6. Checklist final

- [ ] `ImportarPacoteV3_Delta "MICRO03", "...fix1-incremental"` executou sem erro
- [ ] IMPORT_LOG_V3: BACKUP + BUMP + 2x MODULO_OK
- [ ] Compile manual passou limpo (sem destacar `.ContarStrikesPorEmpresa`)
- [ ] TV2_RunSmoke retornou 14/0 (CS_14 incluso, verde)
- [ ] `?GetBuildImportado` mostra MICRO03-fix1
- [ ] Reportei verde no chat
