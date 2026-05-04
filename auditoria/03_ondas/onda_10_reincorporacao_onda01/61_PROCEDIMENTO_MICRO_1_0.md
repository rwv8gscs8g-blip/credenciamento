---
titulo: ONDA 10 — Procedimento manual seguro do Microdelta 1.0 (extensao V3 + bump auto)
natureza-do-documento: procedimento operacional
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-05-01
autor: Claude Opus 4.7 (sessao Cowork)
---

# 61. Procedimento Microdelta 1.0 — Extensao V3 com capacidade delta + bump auto de build label

> **Este documento e o passo-a-passo que o operador (Mauricio) deve
> seguir para validar o Microdelta 1.0.** Cada passo tem um resultado
> esperado. Se algum passo divergir, parar e reportar antes de
> continuar.

## 0. Pre-condicoes

| Item | Estado esperado |
|---|---|
| Workbook ativo | `V12-202-S/29_04_2026 02_22_53PlanilhaCredenciamento-Homologacao.xlsm` aberto |
| Compile manual atual | passa limpo |
| Trio minimo atual | `VR_20260501_121550` confirma 171/0 + 14/0 + 20/0 |
| Build label atual em workbook | `f7aa84f+ONDA05-em-homologacao` (verificavel via `?GetBuildImportado` na imediata) |
| Espelho `local-ai/vba_import_v3_phase1/001-modulo/ABK-Importador_V3.bas` | atualizado pelo Claude (V3.1-Onda10-Delta, 1379 linhas) |
| Espelho `local-ai/vba_import_v3_phase1/001-modulo/AAX-App_Release.bas` | atualizado pelo Claude (build label novo) |
| VBOM | habilitado (Excel > Preferences > Security > Trust Center > Trust access to VBA project object model) |

Se algum item nao bater, NAO PROSSIGA. Reporte para Claude.

## 1. Reset de estado VBE (defesa contra `[executando]`)

> Por que: L7 do knowledge 0009. Se o VBE esta com qualquer macro
> em estado `[executando]`, todo o menu Depurar fica desabilitado
> (incluindo Compilar). Reset garante limpeza.

1.1. Abra o VBE (`Alt+F11` ou `Option+F11` no Mac).

1.2. Confira se a barra de titulo do VBE diz `[executando]` ou
similar. Se sim, clique no botao quadrado azul (Reset) na barra de
ferramentas. Tambem pode ser `Ctrl+Pause/Break` no Windows.

1.3. Confira que o menu `Depurar` nao tem opcoes greyed out.

## 2. Re-importar manualmente o `Importador_V3` (L2 enforced)

> Por que: V3 nao pode importar a si mesmo (L2 do knowledge 0009).
> A unica forma segura de atualizar o V3 dentro do workbook e Remove
> + Import manual.

2.1. No VBE, no Project Explorer, localize o modulo
`Importador_V3` (em "Modulos").

2.2. Clique direito sobre ele → `Remove Importador_V3...` →
quando perguntar se exporta, escolha **`Nao`** (a versao no disco
e mais nova que a do workbook). O modulo desaparece da lista.

2.3. Clique direito em `VBAProject (PlanilhaCredenciamento-Homologacao.xlsm)`
ou em `Modulos` → `Import File...` → navegue ate
`local-ai/vba_import_v3_phase1/001-modulo/ABK-Importador_V3.bas` →
selecione e clique `Open`. **Importante:** o nome do modulo
importado deve aparecer como `Importador_V3` (nao
`ABK-Importador_V3` — o `Attribute VB_Name` no .bas garante o nome
canonico).

> **ATENCAO — armadilha de path conhecida:** existem DUAS pastas no
> repositorio com um arquivo de mesmo nome `ABK-Importador_V3.bas`:
>
> | Path | Linhas | Conteudo |
> |---|---|---|
> | `local-ai/vba_import/001-modulo/ABK-Importador_V3.bas` | 1096 | V3.0-Phase1 (LEGADO — NAO USAR) |
> | `local-ai/vba_import_v3_phase1/001-modulo/ABK-Importador_V3.bas` | 1379 | V3.1-Onda10-Delta (USAR ESTE) |
>
> O VBE costuma lembrar do ultimo path importado. Se voce importou em
> Phase 1 a partir de `vba_import_v3_phase1/`, o VBE deve abrir
> diretamente na pasta certa. Mas confira sempre o path completo ANTES
> de clicar `Open`. Se o caminho na barra do dialogo NAO termina em
> `vba_import_v3_phase1/001-modulo/`, NAO clique abrir — navegue ate o
> path certo.

2.4. Apos importar, **discriminador de versao**: na janela Imediato
digite:

```
ImportarPacoteV3_Status
```

Resultado esperado:

```
=== ImportarPacoteV3_Status (V3.1-Onda10-Delta) ===
```

Se aparecer `V3.0-Phase1`, voce importou da pasta errada (legada).
Refaca os passos 2.2 e 2.3 com cuidado redobrado no path.

2.5. Confira no Project Explorer que `Importador_V3` voltou a
aparecer.

2.6. Resultado esperado: o modulo `Importador_V3` agora contem 1379
linhas. Verifique selecionando o modulo e olhando a barra de
status (ou abrindo o codigo e indo ao final).

## 3. Compile manual (gate antes de prosseguir)

3.1. No VBE, menu `Depurar` → `Compilar VBAProject`.

3.2. Resultado esperado: compile passa **limpo** (nenhuma janela
de erro).

3.3. Se aparecer erro: NAO PROSSIGA. Anote o erro literal e a
linha onde aparece, e reporte para Claude.

## 4. Validacao de capacidade delta — bump standalone

> Por que: o Microdelta 1.0 valida que a nova rotina `IV3_BumpBuildLabel`
> consegue (a) reescrever as constantes no espelho de disco,
> (b) re-importar `App_Release.bas` no workbook, e (c) atualizar o
> resultado de `GetBuildImportado`. **NAO importa nenhum modulo de
> producao** — so testa a tubulacao.

4.1. Na janela Imediato (`Ctrl+G` ou `Cmd+G`), digite e tecle Enter:

```
IV3_BumpBuildLabel "f7aa84f+ONDA10.MICRO00-V3-Delta-Capability-incremental"
```

4.2. Resultado esperado:

- Aparece uma MsgBox dizendo "Build label atualizado com sucesso" e
  citando o novo label.
- A aba `IMPORT_LOG_V3` ganha uma entrada com evento
  `BUMP_BUILD_LABEL` e status `OK`.
- Na imediata aparecem mensagens `[V3 OK] BUMP_BUILD_LABEL ...`
  e `[V3 OK] MODULO_OK ... App_Release ...`.

4.3. Se aparecer falha: clique OK na MsgBox e CONFIRME que a aba
`IMPORT_LOG_V3` mostra detalhes do erro. Reporte para Claude antes
de tentar de novo.

## 5. Confirmar que o bump foi aplicado

5.1. Na janela Imediato:

```
?GetBuildImportado
```

5.2. Resultado esperado: imprime
`f7aa84f+ONDA10.MICRO00-V3-Delta-Capability-incremental`.

5.3. Tambem na imediata:

```
?AppRelease_BuildImportadoRotulo()
```

5.4. Resultado esperado: imprime
`f7aa84f+ONDA10.MICRO00-V3-Delta-Capability (em homologação)`.

5.5. Se algum dos dois nao retornar o esperado, NAO PROSSIGA.
Reporte.

## 6. Gate compile (segundo)

6.1. Menu `Depurar` → `Compilar VBAProject`.

6.2. Resultado esperado: compile passa limpo.

## 7. Gate trio minimo

7.1. Na imediata:

```
CT_ValidarRelease_TrioMinimo
```

7.2. Aguarde a execucao (~12 minutos). Pode ser que o Excel pareca
travado durante este tempo — e normal.

7.3. Resultado esperado: ao final aparece MsgBox com:

- V1 rapida: `171/0`
- V2 Smoke: `14/0`
- V2 Canonica: `20/0`
- Resultado geral: **APROVADO**

7.4. O CSV de validacao e gerado em
`auditoria/04_evidencias/V12.0.0203/ValidacaoRelease_V12_0_0203_VR_<ts>.csv`.

7.5. Se qualquer numero divergir: NAO SALVE o workbook. Reporte
para Claude. Considere restaurar do backup
`backups/vba/20260501_120243-V3-FULL/` (Phase 1) usando re-import
manual do `Importador_V3.bas` original.

## 8. Salvar workbook como ancora intermediaria (opcional)

> Microdelta 1.0 nao gera ancora propria — proxima ancora e apos
> Microdelta 1.5 (`V12-202-T-onda10`). Mas voce pode salvar uma copia
> de seguranca local se quiser.

8.1. Recomendado: deixe o workbook aberto sem salvar. Apos
Microdelta 1.1 verde, salvamos juntos como
`V12-202-T-onda10-micro1` por convencao.

8.2. Se quiser salvar agora: `File` → `Save As` →
`V12-202-S-onda10-micro00.xlsm` ao lado da pasta `V12-202-S/`.

## 9. Reportar verde para Claude

Apos passos 1-7 verdes, responda no chat:

> Microdelta 1.0 verde. Build label atual:
> f7aa84f+ONDA10.MICRO00-V3-Delta-Capability-incremental.
> Compile limpo. Trio 171/0 + 14/0 + 20/0. Pode prosseguir para 1.1.

Claude entao prepara Microdelta 1.1 (Repo_Avaliacao) e aguarda novo
hearback.

## 10. Em caso de problemas

| Sintoma | Acao |
|---|---|
| Erro 438 ao chamar `IV3_BumpBuildLabel` | Compile nao passou. Volta passo 3. |
| MsgBox "AAX-App_Release.bas (espelho) ausente" | Reporte para Claude — espelho nao foi sincronizado |
| MsgBox "Constantes nao encontradas ou ja iguais" | Reporte para Claude — App_Release pode estar com formato divergente |
| `?GetBuildImportado` retorna o label antigo | Re-import do App_Release nao funcionou. Verificar IMPORT_LOG_V3 e reportar |
| Trio falha em algum cenario | Capturar o CSV de evidencia + screenshot da MsgBox de resultado, reportar |
| Compile falha apos bump | Possivel corrupcao em App_Release. Restore manual e reportar |

## 11. Checklist final

- [ ] VBE nao mostra `[executando]`
- [ ] `Importador_V3` re-importado manualmente do espelho atualizado (1379 linhas)
- [ ] Compile manual passou apos re-import
- [ ] `IV3_BumpBuildLabel` executou sem erro e mostrou MsgBox de sucesso
- [ ] `?GetBuildImportado` retorna o label novo
- [ ] Compile manual passou apos bump
- [ ] Trio minimo retornou 171/0 + 14/0 + 20/0
- [ ] Reportei verde para Claude no chat
