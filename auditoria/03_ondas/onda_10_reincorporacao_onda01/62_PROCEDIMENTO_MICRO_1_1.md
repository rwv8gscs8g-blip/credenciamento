---
titulo: ONDA 10 — Procedimento Microdelta 1.1 (Repo_Avaliacao + ContarStrikesPorEmpresa)
natureza-do-documento: procedimento operacional
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-01
autor: Claude Opus 4.7 (sessao Cowork)
---

# 62. Procedimento Microdelta 1.1 — Repo_Avaliacao.ContarStrikesPorEmpresa

> **Microdelta 1.1 e a primeira reincorporacao de codigo de producao
> da Onda 1.** Adiciona a funcao publica `ContarStrikesPorEmpresa` ao
> modulo `Repo_Avaliacao` no workbook. Funcao pura (so leitura),
> sem efeito colateral. Risco operacional muito baixo.

## 0. Pre-condicoes

| Item | Estado esperado |
|---|---|
| Workbook ativo | `V12-202-S/...PlanilhaCredenciamento-Homologacao.xlsm` aberto |
| Microdelta 1.0 | APROVADO (`VR_20260501_173310`) |
| Importador V3 no workbook | `V3.1-Onda10-Delta` (confirmar via `ImportarPacoteV3_Status`) |
| Build label atual no workbook | `f7aa84f+ONDA10.MICRO00-V3-Delta-Capability-incremental` (confirmar via `?GetBuildImportado`) |
| Manifesto delta | `local-ai/vba_import_v3_phase1/000-MANIFESTO-V3-DELTA-MICRO01.txt` (criado pelo Claude) |
| Espelho `AAN-Repo_Avaliacao.bas` | atualizado pelo Claude (167 linhas — baseline 112 + funcao 55) |
| Espelho `AAX-App_Release.bas` | atualizado pelo Claude (build label MICRO01) |

## 1. Reset VBE (defesa contra `[executando]`)

1.1. Abra o VBE (`Alt+F11` ou `Option+F11` no Mac).

1.2. Se a barra de titulo do VBE mostrar `[executando]`, clique no
botao quadrado azul (Reset) na barra de ferramentas.

1.3. Confira que o menu `Depurar` nao tem opcoes greyed out.

## 2. Confirmar versao V3 no workbook

2.1. Janela Imediata (`Ctrl+G` ou `Cmd+G`):

```
ImportarPacoteV3_Status
```

2.2. Resultado esperado: cabecalho mostra `(V3.1-Onda10-Delta)`. Se
nao mostrar, refazer Microdelta 1.0 (re-import manual da V3).

## 3. Executar o import delta com bump auto

3.1. Janela Imediata:

```
ImportarPacoteV3_Delta "MICRO01", "f7aa84f+ONDA10.MICRO01-Repo_Avaliacao-incremental"
```

3.2. **O que vai acontecer (logs esperados em `IMPORT_LOG_V3` + Imediato):**

- `[V3 OK] BACKUP | * | <path> | Backup completo gerado`
- `[V3 OK] BUMP_BUILD_LABEL | * | <espelho> | delta=MICRO01 | build=f7aa84f+ONDA10.MICRO01-Repo_Avaliacao-incremental`
- `[V3 OK] GRUPO_INICIO | GRUPO_DELTA_MICRO01_REPO_AVALIACAO | itens=2`
- `[V3 OK] MODULO_OK | ... | Repo_Avaliacao (167 linhas)`
- `[V3 OK] MODULO_OK | ... | App_Release (171 linhas)`
- MsgBox final: `Importador V3 concluiu o import OK. modo=Estabilizado | dryRun=False | M=2 | F=0 | err=0 | skip=0`

3.3. Se aparecer `FALHA` em qualquer linha, NAO PROSSIGA. Anote
o evento e codigo de erro do `IMPORT_LOG_V3` e reporte.

## 4. Compile manual (gate antes do trio)

4.1. VBE → menu `Depurar` → `Compilar VBAProject`.

4.2. Resultado esperado: compile passa **limpo**.

4.3. Se aparecer erro: capture o erro literal + nome do modulo +
linha. Restaure do backup gerado em
`backups/vba/<ts>-V3-FULL/` e reporte.

## 5. Validar a nova funcao standalone (smoke check rapido)

5.1. Janela Imediata:

```
?Repo_Avaliacao.ContarStrikesPorEmpresa("EMP_001", 5)
```

5.2. Resultado esperado: imprime um numero (provavelmente `0` se a
base de testes esta limpa). NAO deve dar erro de "Sub or Function
not defined" nem 1004.

5.3. Tambem na imediata:

```
?Repo_Avaliacao.ContarStrikesPorEmpresa("", 5)
```

5.4. Resultado esperado: imprime `0` (defesa contra EMP_ID vazio).

5.5. Se algum dos dois falhar, capture mensagem e reporte.

## 6. Confirmar bump de build label

6.1. Janela Imediata:

```
?GetBuildImportado
```

6.2. Resultado esperado:
`f7aa84f+ONDA10.MICRO01-Repo_Avaliacao-incremental`.

## 7. Gate trio minimo

7.1. Janela Imediata:

```
CT_ValidarRelease_TrioMinimo
```

7.2. Aguarde a execucao (~12 minutos).

7.3. Resultado esperado:

- V1 rapida: `171/0`
- V2 Smoke: `14/0`
- V2 Canonica: `20/0`
- Resultado geral: **APROVADO**

7.4. Build no CSV de evidencia deve mostrar
`f7aa84f+ONDA10.MICRO01-Repo_Avaliacao-incremental`.

7.5. Se algum numero divergir, NAO SALVE. Restaure do backup e
reporte.

## 8. Reportar verde para Claude

Ao final, responda no chat:

> Microdelta 1.1 verde. Build label:
> f7aa84f+ONDA10.MICRO01-Repo_Avaliacao-incremental.
> Compile limpo. Trio 171/0+14/0+20/0. Smoke da nova funcao OK.
> Pode prosseguir para 1.2.

Claude entao prepara Microdelta 1.2 (Svc_Rodizio com Suspender
parametros opcionais) e aguarda novo hearback.

## 9. Em caso de problemas

| Sintoma | Acao |
|---|---|
| Erro 458 / "Sub or Function not defined" em ContarStrikesPorEmpresa apos import | Verificar IMPORT_LOG_V3 — provavelmente Repo_Avaliacao nao foi re-importado |
| Erro de compile em SHEET_CAD_OS / COL_OS_EMP_ID etc | Dependencia faltante no baseline — reportar imediatamente |
| Trio falha em qualquer cenario | Capture CSV evidencia + screenshot, restore backup, reporte |
| Smoke check `?Repo_Avaliacao.ContarStrikesPorEmpresa("EMP_001", 5)` retorna erro 1004 | Possivel problema com SHEET_CAD_OS — verificar que aba existe |
| Build label nao mudou em `?GetBuildImportado` | Re-import de App_Release falhou — IMPORT_LOG_V3 deve ter detalhes |

## 10. Checklist final

- [ ] VBE nao mostra `[executando]`
- [ ] `ImportarPacoteV3_Status` confirma V3.1-Onda10-Delta
- [ ] `ImportarPacoteV3_Delta "MICRO01", "..."` executou sem erro
- [ ] IMPORT_LOG_V3 mostra: BACKUP OK + BUMP_BUILD_LABEL OK + 2x MODULO_OK
- [ ] Compile manual passou
- [ ] Smoke `?Repo_Avaliacao.ContarStrikesPorEmpresa("EMP_001", 5)` retorna numero
- [ ] `?GetBuildImportado` retorna `...MICRO01-Repo_Avaliacao-incremental`
- [ ] Trio minimo 171/0 + 14/0 + 20/0 APROVADO
- [ ] Reportei verde no chat
