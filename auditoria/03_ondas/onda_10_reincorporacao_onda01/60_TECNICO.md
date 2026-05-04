---
titulo: ONDA 10 — Reincorporacao Onda 1 (strikes na avaliacao) sobre baseline V12-202-S
natureza-do-documento: documento tecnico de reincorporacao incremental com escopo, microdeltas, gates e rollback
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
linha-alvo: V12.0.0203
branch: codex/v12-0-0203-governanca-testes
data: 2026-05-01
autor: Claude Opus 4.7 (sessao Cowork — executor)
solicitante: Luis Mauricio Junqueira Zanin
plano-mestre: auditoria/00_status/27_ROADMAP_REINCORPORACAO_INCREMENTAL_V203.md
readback: .hbn/readbacks/0010-onda10-reincorporacao-onda01.json
---

# 60. ONDA 10 — Reincorporacao Onda 1 (strikes na avaliacao)

## 00. Sintese

Reintegra a regra de strikes (originalmente Onda 1) ao baseline
`V12-202-S`, que apos a Phase A ficou caracterizado como tendo apenas
a infraestrutura de configuracao (constantes em `Const_Colunas` e
getters em `Util_Config`) sem o nucleo comportamental
(`Repo_Avaliacao.ContarStrikesPorEmpresa`, `Svc_Rodizio.Suspender` com
parametros opcionais, bloco "7b" em `Svc_Avaliacao`,
`TV2_SetConfigCanonica` gravando defaults, suite `TV2_RunStrikes`,
opcao `[14]` na Central V2).

A reincorporacao acontece em **6 microdeltas** (1.0 a 1.5), cada um
seguido de gate manual (compile + trio minimo verde) e bump
automatico de build label via `Importador_V3.ImportarPacoteV3_Delta`.

A ordem dos microdeltas foi **ajustada** para 1.0 → 1.1 → 1.2 → 1.4
→ 1.3 → 1.5: a colocacao de 1.4 antes de 1.3 garante que
`TV2_SetConfigCanonica` esteja gravando `MAX_STRIKES=1` e
`DIAS_SUSPENSAO_STRIKE=0` em `CONFIG` antes do bloco 7b ser ativado em
`Svc_Avaliacao`, preservando equivalencia comportamental com o legado
no `CS_14`.

Onda nao toca `Mod_Types.bas`. Onda nao toca `.frx`. Onda nao usa
`publicar_vba_import.sh` (descontinuado). Onda nao reimporta o
proprio `Importador_V3` via si mesmo (re-import e sempre manual).

## 01. Contexto e diagnostico Phase A

A Phase A (auditoria 2026-05-01) confirmou que `V12-202-S`, embora
carimbado `f7aa84f+ONDA05-em-homologacao` e passando o trio minimo
171/0 + 14/0 + 20/0, possui apenas duas das oito superficies
modificadas pela Onda 1 original:

| Arquivo | Onda 1 esperada | V12-202-S real | Status |
|---|---|---|---|
| `Const_Colunas.bas` | +`COL_CFG_MAX_STRIKES`=12, +`COL_CFG_DIAS_SUSPENSAO_STRIKE`=13 | presentes | OK |
| `Util_Config.bas` | +`GetMaxStrikes`, +`GetDiasSuspensaoStrike` | presentes | OK |
| `Repo_Avaliacao.bas` | +`ContarStrikesPorEmpresa(EMP_ID, notaCorte)` | ausente | FALTA |
| `Svc_Rodizio.bas` | `Suspender` com `diasSuspensao` + `motivo` opcionais; auditoria `BASE=DIAS\|MESES` | assinatura velha `Suspender(EMP_ID)` | FALTA |
| `Svc_Avaliacao.bas` | bloco "7b" reescrito | nenhuma referencia a strike | FALTA |
| `Teste_V2_Engine.bas` | `TV2_SetConfigCanonica` grava defaults canonicos das 2 colunas novas | nao grava | FALTA |
| `Teste_V2_Roteiros.bas` | +`TV2_RunStrikes` (`CS_AVAL_001..007`) + helpers | ausente | FALTA |
| `Central_Testes_V2.bas` | +opcao `[14] Strikes na avaliacao`, +`CT2_ExecutarStrikes` | ausente | FALTA |

A Onda 10 reaplica os 6 itens FALTA via microdeltas verificaveis.

## 02. Pre-requisito tecnico — extensao do Importador V3 (Microdelta 1.0)

O `Importador_V3` original (V3.0-Phase1, 1095 linhas, 7 fixes
acumulados) tem apenas as 4 entry points publicas: `ImportarPacoteV3`,
`ImportarPacoteV3_Fresh`, `ImportarPacoteV3_DryRun` e
`ImportarPacoteV3_Status`. Para suportar reincorporacao incremental
com auditabilidade de build, o Microdelta 1.0 estende o V3 com:

### 02.1 Novas API publicas

- **`ImportarPacoteV3_Delta(nomeDelta, buildLabel)`** — orquestra o
  import de um manifesto delta especifico (caminho montado a partir
  de `nomeDelta`) e dispara o bump automatico de build label antes do
  processamento dos itens.
- **`IV3_BumpBuildLabel(buildLabel)`** — operacao standalone que
  reescreve as constantes `APP_BUILD_IMPORTADO` e
  `APP_BUILD_GERADO_EM` no espelho de disco e re-importa
  `App_Release.bas` para o workbook. Usado em Microdelta 1.0 para
  validar a nova capacidade sem efetuar import de codigo de producao.

### 02.2 Novos helpers privados

- **`IV3_AtualizarConstantesAppRelease(buildLabel)`** — reescreve as
  duas constantes no espelho `AAX-App_Release.bas`. UNC preserve
  aplicado (L4 do knowledge 0009).
- **`IV3_SubstituirConstanteString(conteudo, nomeConstante, novoValor)`**
  — parser linha-a-linha que reescreve `Public Const <nome> As String
  = "<antigo>"` para `Public Const <nome> As String = "<novo>"`. So
  substitui primeira ocorrencia (constantes sao unicas em modulo).
- **`IV3_ReimportarAppRelease()`** — re-importa o espelho atualizado
  para o workbook reusando o pipeline padrao `IV3_ImportarModulo`
  (Remove + Import + validacao por `CountOfLines`).

### 02.3 Modificacao em rotina existente

- **`IV3_RodarMain`** — passa a consultar tres campos modulares novos
  (`mIV3_OverrideManifesto`, `mIV3_OverrideBuildLabel`,
  `mIV3_DeltaName`) que sao setados/limpos por
  `ImportarPacoteV3_Delta`. Quando `mIV3_OverrideManifesto` esta
  setado, usa-o em lugar de `IV3_MANIFESTO_REL`. Quando
  `mIV3_OverrideBuildLabel` esta setado, executa
  `IV3_AtualizarConstantesAppRelease` apos o backup.

### 02.4 Constantes novas no V3

- `IV3_DELTA_MANIFESTO_PREFIX` = `local-ai\vba_import_v3_phase1\000-MANIFESTO-V3-DELTA-`
- `IV3_DELTA_MANIFESTO_SUFFIX` = `.txt`
- `IV3_APP_RELEASE_REL_PATH` = `local-ai\vba_import_v3_phase1\001-modulo\AAX-App_Release.bas`
- `IV3_APP_RELEASE_NOME` = `App_Release`
- `IV3_APP_RELEASE_CONST_BUILD` = `APP_BUILD_IMPORTADO`
- `IV3_APP_RELEASE_CONST_GERADO` = `APP_BUILD_GERADO_EM`
- `IV3_VERSION` atualizada para `V3.1-Onda10-Delta`

### 02.5 Preservacao das licoes do knowledge 0009

- **L1** (Mac SMB DeleteLines+AddFromString): preservada — bump usa
  Remove+Import via pipeline padrao.
- **L2** (auto-import tabu): preservada — `Importador_V3` continua
  proibido de importar a si mesmo. Re-import do V3 atualizado e
  manual em Microdelta 1.0 (clique direito > Remove > Import).
- **L4** (UNC preserve): aplicada — helpers novos detectam prefixo
  `\\` antes do colapso de separadores.
- **L9** (`MkDir` aninhado): preservada — bump nao cria pastas, so
  reescreve arquivo existente.
- **M1** (hotfix sem evidencia): respeitada — todas as linhas novas
  baseadas em diff explicito da Onda 1 original.
- **M2** (strict validation): preservada — sem `On Error Resume Next`
  global, todos erros logados e abortam.

## 03. Microdeltas planejados

### 03.1 Tabela canonica

| ID | Tema | Arquivos | Risco | Build label apos verde |
|---|---|---|---|---|
| 1.0 | Extensao V3 + bump auto | `Importador_V3.bas`, `App_Release.bas` | medio | `f7aa84f+ONDA10.MICRO00-V3-Delta-Capability-incremental` |
| 1.1 | `ContarStrikesPorEmpresa` | `Repo_Avaliacao.bas` | muito baixo | `f7aa84f+ONDA10.MICRO01-Repo_Avaliacao-incremental` |
| 1.2 | `Suspender` parametros opcionais | `Svc_Rodizio.bas` | baixo | `f7aa84f+ONDA10.MICRO02-Svc_Rodizio-incremental` |
| 1.4 | `TV2_SetConfigCanonica` grava defaults | `Teste_V2_Engine.bas` | muito baixo | `f7aa84f+ONDA10.MICRO04-Teste_V2_Engine-incremental` |
| 1.3 | bloco "7b" em `AvaliarOS` | `Svc_Avaliacao.bas` | medio | `f7aa84f+ONDA10.MICRO03-Svc_Avaliacao-incremental` |
| 1.5 | suite `TV2_RunStrikes` + opcao `[14]` | `Teste_V2_Roteiros.bas`, `Central_Testes_V2.bas` | baixo | `f7aa84f+ONDA10.MICRO05-Strikes-Suite-incremental` |

### 03.2 Por que 1.4 antes de 1.3

Quando `Svc_Avaliacao` ativa o bloco "7b", ele consulta `GetMaxStrikes`
e `GetDiasSuspensaoStrike`. Se `CONFIG` nao tiver as colunas `L`
(MAX_STRIKES) e `M` (DIAS_SUSPENSAO_STRIKE) preenchidas, os getters
caem nos defaults dos modulos (3 e 90 respectivamente), o que **muda
o comportamento real** comparado ao legado. O legado suspendia ja
no primeiro strike (`MAX_STRIKES = 1` implicito via regra antiga).
Para preservar `CS_14` (que conta com a equivalencia
"primeiro strike suspende"), a Onda 10 grava no canonico
`MAX_STRIKES = 1` antes de ativar o bloco que consulta o valor.

### 03.3 Promocao apos Microdelta 1.5 verde

- Operador salva workbook como `V12-202-T-onda10/PlanilhaCredenciamento-Homologacao.xlsm`
- Bump final: `f7aa84f+ONDA10-aprovada` (data corrente)
- ERP fecha em `.hbn/results/0010-exec-onda10.json`
- Relay atualizado para Onda 11 (suite TV2_RunCnae + menu [15]).

## 04. Estrutura de cada microdelta

Todo microdelta do 1.1 em diante segue o padrao:

1. Atualizar `src/vba/<arquivo>.bas` com o delta.
2. Espelhar em `local-ai/vba_import_v3_phase1/001-modulo/<prefixo>-<arquivo>.bas`.
3. Criar `local-ai/vba_import_v3_phase1/000-MANIFESTO-V3-DELTA-MICRO0X.txt`
   listando o(s) arquivo(s) + sempre `M|001-modulo/AAX-App_Release.bas` no fim.
4. Operador roda `ImportarPacoteV3_Delta "MICRO0X", "<build label esperado>"`.
5. Operador faz compile manual + trio minimo.
6. Se verde: prossegue. Se vermelho: restore do backup automatico.
7. Documenta em `auditoria/03_ondas/onda_10_reincorporacao_onda01/6X_PROCEDIMENTO_MICRO_1_X.md`.

## 05. Gates e rollback

### 05.1 Gates inviolaveis

- **G6**: nenhum codigo VBA solto em chat — toda entrega via arquivo.
- **L2**: V3 nao importa a si mesmo. Re-import do V3 e manual.
- **L9**: helpers de pasta usam `IV3_GarantirPasta`.
- **Backup**: V3 faz backup completo antes de cada microdelta com
  import (1.1 em diante). Em 1.0 o bump standalone nao faz backup
  (operacao isolada de metadados).
- **Compile**: gate manual operador apos cada microdelta.
- **Trio**: gate manual operador apos cada microdelta.

### 05.2 Rollback por microdelta

- O backup pre-microdelta esta em `backups/vba/<ts>-V3-FULL/`.
- Se compile ou trio quebrar, operador restaura via copia do backup.
- `src/vba/` mantem o codigo escrito (rollback so afeta workbook ativo).
- Em caso de regressao detectada apos varios microdeltas, e possivel
  restaurar diretamente para `V12-202-S` original.

### 05.3 Em caso de falha no Microdelta 1.0 (extensao V3)

Como o Microdelta 1.0 nao faz backup (so re-import isolado de
`App_Release.bas`), o rollback e via re-import manual da versao
anterior do `Importador_V3.bas` (presente em
`backups/vba/20260501_120243-V3-FULL/Importador_V3.bas` que foi
gerado pelo backup automatico do run de Phase 1).

## 06. Documentos relacionados

- `.hbn/readbacks/0010-onda10-reincorporacao-onda01.json` — readback formal
- `.hbn/knowledge/0009-licoes-importador-v3-phase1.md` — L1-L9 + M1-M5
- `auditoria/00_status/27_ROADMAP_REINCORPORACAO_INCREMENTAL_V203.md` — roadmap
- `auditoria/03_ondas/onda_01_strikes/28_TECNICO.md` — Onda 1 original
- `auditoria/03_ondas/onda_09_importador_v3/50_TECNICO.md` — V3 design

## 06.1 Princípio arquitetural de validação (oficializado 2026-05-01 18:44)

**Testes via interface oficial, evoluindo junto com o código.** A V12.0.0203
adota como princípio que toda validação de microdelta passa pela
infraestrutura de teste própria do projeto (`TV2_RunSmoke`,
`TV2_RunCanonicoFundacao`, `TV2_RunStrikes`, etc.), nunca por smoke
ad-hoc inventado no Imediato. Isso porque:

1. **Idempotência**: rotinas TV2_* são reproduzíveis, podem rodar 100
   vezes sem efeito colateral residual graças aos snapshots/reset.
2. **Auditabilidade**: cada execução fica registrada em
   `RESULTADO_QA_V2` e `HISTORICO_QA_V2` com timestamp + ID único.
3. **Evolução progressiva**: cada onda acrescenta cenários novos à
   suite (Onda 1 = TV2_RunStrikes; Onda 2 = TV2_RunCnae; Onda 3 =
   estende TV2_RunCnae; Onda 4 = TV2_RunCfg; Onda 7 = TV2_RunIdempotencia
   + TV2_RunRodizio). Cada onda **fortalece a infraestrutura de teste**.
4. **Economia de tempo do operador**: TV2_RunSmoke ~30s vs trio
   mínimo ~12min. Trio mínimo só ao final de cada onda completa.

Política operacional resultante:
- **Por microdelta**: compile manual (gate sintático) + `TV2_RunSmoke`
  (gate funcional, ~30s).
- **Por onda completa**: trio mínimo `CT_ValidarRelease_TrioMinimo`
  + suíte recém-adicionada (ex.: TV2_RunStrikes ao final da Onda 10).
- **Smoke ad-hoc no Imediato**: antipadrão. Substituído por evolução
  da suíte oficial.

Esse princípio é **condição de aceitação** de qualquer microdelta da
Onda 10 para frente. Próximas Ondas (11, 12, 13, 14, 15) seguem a mesma
política.

## 07. Estrategia de espelhamento aprovada (2026-05-01)

**Estrategia A — espelho minimalista** confirmada apos Microdelta 1.0
verde:

- Para cada microdelta de reincorporacao, o espelho
  `local-ai/vba_import_v3_phase1/001-modulo/<prefixo>-<arquivo>.bas`
  e **construido manualmente** como `baseline V12-202-S + apenas o
  delta da onda em questao`.
- `src/vba/<arquivo>.bas` **NAO e tocado** durante toda a Phase A.5
  (excecao: `App_Release.bas` que recebe o bump de build label e
  `Importador_V3.bas` que recebeu a capacidade delta). Permanece como
  estado-final-desejado.
- Ao final da Phase A.5: `vba_import_v3_phase1/` reflete `baseline +
  Onda 1+2+3+4 isoladas`. `src/vba/` reflete `baseline + Onda 1+2+3+4
  + 26 hotfixes residuais`. Diferenca auditavel.
- Phase A.6 analisa os 26 hotfixes residuais caso-a-caso e os
  reincorpora via microdeltas adicionais.
- Cada microdelta da Phase A.5 e tematicamente puro (so o delta da
  onda original, sem caronas).

## 08. Historico de execucao

### Microdelta 1.0 — APROVADO 2026-05-01 17:44

- Validacao: `VR_20260501_173310`
- Trio: 171/0 + 14/0 + 20/0
- Build label aplicado: `f7aa84f+ONDA10.MICRO00-V3-Delta-Capability-incremental`
- Capacidade delta + bump auto provados em producao real
- Armadilha de path identificada: `local-ai/vba_import/001-modulo/`
  ainda contem versao V3.0-Phase1 legada — sera sincronizada em fase
  posterior

### Microdelta 1.1 — APROVADO 2026-05-01 18:19

- Validacao: `VR_20260501_180949`
- Trio: 171/0 + 14/0 + 20/0
- Build label aplicado: `f7aa84f+ONDA10.MICRO01-Repo_Avaliacao-incremental`
- Backup: `\\Mac\Home\...\backups\vba\20260501_180746-V3-FULL`
- Espelho final: `AAN-Repo_Avaliacao.bas` 167 linhas
- ContarStrikesPorEmpresa agora vive no workbook V12-202-S
- Estrategia A validada na pratica (baseline + delta isolado, sem hotfixes residuais)

### Microdelta 1.2 — APROVADO 2026-05-01 18:44

- Validacao: `TV2_20260501_184237` SMOKE 14/0
- Build label aplicado: `f7aa84f+ONDA10.MICRO02-Svc_Rodizio-incremental`
- Espelho final: `AAP-Svc_Rodizio.bas` 465 linhas
- Suspender com 3 parametros (1 obrigatorio + 2 opcionais) ativo no workbook V12-202-S
- Retrocompatibilidade preservada (V2 Canonica sem regressao)
- Politica de teste oficializada: TV2_RunSmoke por microdelta + trio so no fim da onda
- Lecao registrada (M6): smoke ad-hoc no Imediato com retorno UDT (`?func().Field`) e antipadrao — usar suite oficial sempre

### Microdelta 1.4 — APROVADO 2026-05-01 18:55

- Validacao: `TV2_20260501_185512` SMOKE 14/0
- Build label aplicado: `f7aa84f+ONDA10.MICRO04-Teste_V2_Engine-incremental`
- Backup: `\\Mac\Home\...\backups\vba\20260501_185328-V3-FULL`
- Espelho final: `ABF-Teste_V2_Engine.bas` 2592 linhas
- CONFIG canonica agora grava MAX_STRIKES=1 + DIAS_SUSPENSAO_STRIKE=0 durante TV2_PrepararBaselineCanonica
- Pre-condicao para 1.3 garantida

### Microdelta 1.3 — APROVADO 2026-05-01 19:47 (apos fix1)

- Validacao: `TV2_20260501_194706` SMOKE 14/0
- Build label aplicado: `f7aa84f+ONDA10.MICRO03-Svc_Avaliacao-fix1-incremental`
- Iteracao fix1: removida qualificacao `Repo_Avaliacao.` antes de `ContarStrikesPorEmpresa` (Licao L10 documentada)
- Espelho final: `AAS-Svc_Avaliacao.bas` 453 linhas
- **Regra de strikes ATIVA EM PRODUCAO** no V12-202-S: AvaliarOS consulta strikes, audita STRIKES=N/MAX, suspende quando atinge MAX_STRIKES
- Comportamento observavel preservado (CS_14 verde) gracas a config canonica 1.4

### Microdelta 1.5 — IMPLEMENTADO (aguardando execucao operador) — ULTIMO da Onda 10

- Tema: suite TV2_RunStrikes (7 cenarios CS_AVAL_001..007 + 2 helpers privados) + opcao [14] na Central V2
- Espelhos:
  - `ABG-Teste_V2_Roteiros.bas` 1378 → 1631 linhas (apenddos TV2_RunStrikes + TV2_SetStrikesConfig + TV2_ConsumirStrikeEmpresa)
  - `ABE-Central_Testes_V2.bas` 102 → ~110 linhas (opcao [14] + Case 14 + CT2_ExecutarStrikes)
- Manifesto: `000-MANIFESTO-V3-DELTA-MICRO05.txt` (3 itens: Roteiros + Central V2 + App_Release)
- Build label esperado: `f7aa84f+ONDA10.MICRO05-Strikes-Suite-incremental`
- Procedimento operador: `66_PROCEDIMENTO_MICRO_1_5.md`
- Gates: compile + TV2_RunSmoke 14/0 + **TV2_RunStrikes 7/0 (NOVO!)** + **Trio mínimo completo 171/0+14/0+20/0 (FECHAMENTO da Onda 10)**
- Promocao apos verde: workbook salvo como `V12-202-T-onda10/`, build label final `f7aa84f+ONDA10-aprovada` (em outro microdelta), ERP `0010-exec-onda10.json`

## 09. Versao

- v1.0 — 2026-05-01 — criacao apos hearback dos 5 pontos. Microdelta 1.0
  implementado (V3 estendido + App_Release bumpado), espelhos
  atualizados.
- v1.1 — 2026-05-01 17:50 — Microdelta 1.0 APROVADO em
  `VR_20260501_173310`. Estrategia A oficializada. Microdelta 1.1
  implementado (espelho minimalista de Repo_Avaliacao + manifesto
  delta MICRO01).
- v1.2 — 2026-05-01 18:25 — Microdelta 1.1 APROVADO em
  `VR_20260501_180949`. Microdelta 1.2 implementado (Suspender com
  parametros opcionais + bump build label MICRO02).
