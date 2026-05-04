---
titulo: 27 — Roadmap reincorporacao incremental V12.0.0203 (handoff para chat novo)
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-01
---

# 27 — Roadmap reincorporacao incremental V12.0.0203

> **Documento canonico de handoff.** Criado em 2026-05-01 apos Phase 1
> V3 APROVADA. Serve de prompt de retomada para chat novo executar
> as Ondas 1-8 incrementalmente sobre o baseline V12-202-S.

---

## 1. Onde estamos agora (snapshot 2026-05-01 12:30)

### 1.1 Baseline funcional

| Campo | Valor |
|---|---|
| Workbook ancora | `V12-202-S/29_04_2026 02_22_53PlanilhaCredenciamento-Homologacao.xlsm` |
| Build label atual | `f7aa84f+ONDA05-em-homologacao` (provisorio — sera atualizado no FECHAMENTO) |
| Compile manual | passa limpo (apos remocao do `Importador_V2` legado) |
| Trio minimo | APROVADO em `VR_20260501_121550` (V1=171/0 + V2 Smoke=14/0 + V2 Canonica=20/0) |
| Importador oficial | V3 (Phase 1 fechada, ver `auditoria/03_ondas/onda_09_importador_v3/`) |
| Pacote isolado em uso | `local-ai/vba_import_v3_phase1/` |

### 1.2 Componentes do workbook (apos V3 Phase 1)

- 35 modulos `.bas` do baseline V12-202-R
- 13 forms
- 2 modulos novos: `Importador_V3` + `Importador_V3_Bootstrap`
- 1 modulo removido: `Importador_V2` (legacy v13 buggy — JAMAIS reimportar)

### 1.3 Debitos tecnicos identificados (auditoria Fase A, 2026-05-01)

| # | Debito | Evidencia |
|---|---|---|
| D1 | 30 dos 35 modulos divergem entre V12-202-S e `src/vba/` | hashes diferentes |
| D2 | Onda 7 (IDM_*/RDZ_*) NAO esta no baseline (0 hits) | grep V12-202-R |
| D3 | Onda 8 (heuristica zero forms) DIVERGE em 3 arquivos | hashes diferentes em Cadastro_Servico, Reativa_Empresa, Reativa_Entidade |
| D4 | App_Release.bas com label provisorio | precisa cravar v12.0.0203 |
| D5 | `Emergencia_CNAE.bas` existe so em src/vba (nao tem destino governado) | listagem inventario |
| D6 | Zero TODO/FIXME/HACK em qualquer codigo | limpo ✓ |

---

## 2. Estrategia: reincorporacao **delta-por-onda**

### 2.1 Principio

> **NAO importar os 30 divergentes em massa.** Aplicar so os deltas
> ESPECIFICOS de cada onda, em sequencia, validando entre cada uma.

Motivos:
1. Ondas 1-5 estao COMPILADAS em V12-202-S (build label "ONDA05" + trio verde com infraestrutura V2 funcional)
2. Os outros 30 divergentes incluem hotfixes V2 do disaster (Util_Filtro_Lista v9, Preencher v8, etc.) que podem ou nao ser melhorias legitimas
3. Aplicar em massa invalida o teorema de "V12-202-S compila e passa trio" — perdemos o ancora se algo quebrar
4. Aplicacao incremental permite isolar regressao por onda

### 2.2 Mapeamento onda → arquivos

| Onda | Tema | Arquivos diretos | Acao |
|---|---|---|---|
| 1 | strikes na avaliacao | Svc_Avaliacao, possivel Const_Colunas | **VERIFICAR** se ja em V12-202-S (build ONDA05 inclui) — diff esperado: minimo |
| 2 | CNAE snapshot + dedup | Cadastro_Servico.frm parcial, Funcoes | **VERIFICAR** ja em baseline |
| 3 | CNAE dedup automatico | refinamento Onda 2 | **VERIFICAR** ja em baseline |
| 4 | wire-up Configuracao_Inicial | Configuracao_Inicial.frm, Util_Config | **VERIFICAR** ja em baseline |
| 5 | form deterministico + Limpa_Base robusta | Limpar_Base.frm, Mod_Limpeza_Base | **VERIFICAR** ja em baseline (build ONDA05 implica) |
| 6 | consolidacao documental | NENHUM .bas — so .md | SKIP — verificar docs em repo |
| 7 | familia IDM_* + RDZ_* (5 cenarios V2 Canonica) | Teste_V2_Engine, Teste_V2_Roteiros, Central_Testes_V2 (+ possivel Svc_Rodizio) | **APLICAR** — manifesto delta-7 |
| 8 | heuristica zero em forms | Cadastro_Servico.frm, Reativa_Empresa.frm, Reativa_Entidade.frm | **APLICAR** — manifesto delta-8 |

### 2.3 Deltas de Ondas 7+8 sao **os arquivos a aplicar**

Os outros divergentes (Svc_PreOS, Repo_Avaliacao, Util_Filtro_Lista, Preencher, etc.) provavelmente sao residuo de hotfixes V2 — **deixar como estao** em V12-202-S a menos que algum teste futuro acuse regressao especifica.

---

## 3. Roteiro operacional (chat novo)

### 3.1 Fase A — Verificacao Ondas 1-5 (1h)

Para cada onda 1..5, ler doc tecnico (`auditoria/03_ondas/onda_NN_*/NN_TECNICO.md`) e verificar:

1. **Identificar arquivos modificados** pelo doc tecnico
2. **shasum** dos arquivos em V12-202-R (= V12-202-S source) vs `src/vba` versao mais antiga conhecida da onda (git log)
3. Se hash bate → onda CONFIRMADA em baseline
4. Se diverge → marcar para investigar

Saida: tabela com onda × status (CONFIRMADA / DIVERGE / DESCONHECIDO).

### 3.2 Fase B — Onda 6 docs (15 min)

Onda 6 nao tem .bas changes. Verificar que:
- `AGENTS.md`, `llms.txt`, `llms-full.txt` existem
- `docs/` tem estrutura Diataxis (tutorials, how-to, reference, explanation)
- `.hbn/` esta com a estrutura (relay, knowledge, readbacks, results)

Se OK → marcar Onda 6 como CONFIRMADA documental.

### 3.3 Fase C — Aplicar Onda 7 (1 sessao)

#### C.1 Preparar manifesto delta-7

Criar `local-ai/vba_import_v3_phase1/000-MANIFESTO-V3-DELTA7.txt`:

```
# Manifesto delta Onda 7 — IDM_*/RDZ_* (5 cenarios V2 Canonica)

# GRUPO_DELTA7_TESTS
M|001-modulo/ABE-Central_Testes_V2.bas
M|001-modulo/ABF-Teste_V2_Engine.bas
M|001-modulo/ABG-Teste_V2_Roteiros.bas

# Possivelmente tambem:
# M|001-modulo/AAP-Svc_Rodizio.bas  (se a auditoria mostrar que Onda 7 mexeu nele)
```

#### C.2 Atualizar arquivos no pacote

Substituir os 3 (ou 4) `.bas` em `vba_import_v3_phase1/001-modulo/` pelas versoes ATUAIS de `src/vba/`.

#### C.3 Atualizar Importador_V3 para aceitar manifesto alternativo

Pequena alteracao em `IV3_MANIFESTO_REL` ou nova API `ImportarPacoteV3_Delta(manifesto)`.

#### C.4 Operador roda

```
Bootstrap_V3
ImportarPacoteV3_Delta "DELTA7"
```

Backup automatico antes. Apos:
- Compile manual
- Trio minimo (deve continuar 171/0+14/0+20/0)
- **V2 Canonica completa** — esperado: 25 tests (20 originais + 5 IDM_/RDZ_)

#### C.5 Gates Onda 7

- ✅ Compile limpo
- ✅ Trio verde
- ✅ V2 Canonica = 25/0 (ou X/0 com X > 20 — quantidade nova)
- ✅ Operador salva como `V12-202-T-onda7`

Se algum gate falhar → restaurar do backup V3, investigar arquivo especifico.

### 3.4 Fase D — Aplicar Onda 8 (1 sessao)

#### D.1 Preparar manifesto delta-8

```
# Manifesto delta Onda 8 — heuristica zero forms

# GRUPO_DELTA8_FORMS
F|002-formularios/AAD-Cadastro_Servico.frm
F|002-formularios/AAF-Reativa_Entidade.frm
F|002-formularios/AAH-Reativa_Empresa.frm
```

#### D.2 Atualizar 3 forms no pacote

Substituir `.frm` + `.frx` + regerar `.code-only.txt` para os 3 forms a partir de `src/vba/`.

#### D.3 Operador roda

```
Bootstrap_V3
ImportarPacoteV3_Delta "DELTA8"
```

Apos:
- Compile manual
- Trio minimo (continua verde)
- **Teste UI guiado** dos 3 forms (heuristica zero implica que abrir form e fazer cadastro nao causa erro)

#### D.4 Gates Onda 8

- ✅ Compile limpo
- ✅ Trio verde
- ✅ UI dos 3 forms funcional
- ✅ Operador salva como `V12-202-U-onda8`

### 3.5 Fase E — FECHAMENTO V12.0.0203

#### E.1 Atualizar build label

Editar `src/vba/App_Release.bas`:
```
Public Const APP_BUILD_IMPORTADO As String = "v12.0.0203"
Public Const APP_GERADO_EM As String = "2026-05-XX HH:MM"
```

Espelhar em `vba_import_v3_phase1/001-modulo/AAX-App_Release.bas`.

Re-importar via V3 (so esse modulo, ou rodar manifesto completo).

#### E.2 Validacao final

- Compile manual
- Trio minimo
- V2 Canonica completa
- `?GetBuildImportado` → "v12.0.0203"
- Salvar como `PlanilhaCredenciamento-Homologacao-v12.0.0203.xlsm`

#### E.3 Atualizar CHANGELOG.md

Adicionar entrada V12.0.0203 com resumo: 9 ondas concluidas + V3 importador estabilizado.

#### E.4 Snapshot final

Criar `auditoria/00_status/28_RELEASE_V12_0203.md` com:
- Build label final
- Lista das 9 ondas com status
- Hash do workbook
- Trio + V2 Canonica resultado

#### E.5 Tag + push

```bash
git add .
git commit -m "release: v12.0.0203 final - 9 ondas + V3 importador"
git tag v12.0.0203
git push origin v12.0.0203
git push origin codex/v12-0-0203-governanca-testes
```

---

## 4. Risco e mitigacao

| Risco | Mitigacao |
|---|---|
| Onda 7 traz dependencia que nao existe em V12-202-S | V3 backup automatico antes de cada delta. Se compile falhar, restore + identificar dependencia faltante |
| Onda 8 form quebra .frx do designer | Usar `.code-only.txt` (preserva binario do designer) |
| App_Release atualizado quebra alguma referencia | Modulo App_Release e isolado, so define constantes |
| Hotfixes V2 latentes em outros modulos causam regressao | Nao mexer neles; se trio passa, nao tocar |
| Operador esquece de fazer backup antes de salvar | V3 ja faz backup automatico em `backups/vba/<ts>-V3-FULL/` |

---

## 5. Pre-requisitos para chat novo

Ao abrir chat novo, ele precisa LER (nessa ordem):

1. `AGENTS.md` — entrada canonica IA
2. `.hbn/relay/INDEX.md` — bastao atual
3. `.hbn/knowledge/0009-licoes-importador-v3-phase1.md` — 14 licoes anti-regressao
4. `.hbn/results/0009-exec-onda09-v3-phase1.json` — ERP Phase 1
5. **Este documento** (`27_ROADMAP_REINCORPORACAO_INCREMENTAL_V203.md`)
6. `auditoria/03_ondas/onda_09_importador_v3/50_TECNICO.md` — V3 design
7. `auditoria/03_ondas/onda_09_importador_v3/51_PROCEDIMENTO.md` — V3 procedimento

---

## 6. Prompt de retomada (copiar pra chat novo)

```
Estamos retomando o projeto Credenciamento V12.0.0203 apos Phase 1
do Importador V3 ter sido APROVADA em 2026-05-01.

LEIA NESTA ORDEM:
1. AGENTS.md
2. .hbn/relay/INDEX.md
3. auditoria/00_status/27_ROADMAP_REINCORPORACAO_INCREMENTAL_V203.md
4. .hbn/knowledge/0009-licoes-importador-v3-phase1.md
5. .hbn/results/0009-exec-onda09-v3-phase1.json

Estado:
- Workbook V12-202-S compila e passa trio minimo verde
- Importador V3 funciona (1095 linhas, 7 fixes acumulados)
- Falta reincorporar incrementalmente Ondas 7 e 8 sobre o baseline
- Ondas 1-5 ja em V12-202-S (build ONDA05)
- Onda 6 e documental (verificar docs)
- Apos isso: FECHAMENTO V12.0.0203 (build label + tag + push)

Modo: consultivo controlado. G6 enforced (sem codigo VBA solto no chat).
Cada onda = 1 readback + 1 ERP. Hearback obrigatorio antes de
escrever qualquer arquivo.

Mauricio aprovou ordem A→D→B→E→F (auditoria → reincorporacao
incremental → build label → changelog → tag/push).

Comece pela Fase A (verificacao Ondas 1-5 conforme secao 3.1 do
roadmap). Reporta tabela canonica com status de cada onda antes
de avancar para Fase C/D/E.
```

---

## 7. Decisoes pendentes

| Q | Tema | Default proposto |
|---|---|---|
| Q1 | Emergencia_CNAE entra no release ou fica fora? | Decisao do operador no chat novo (default: entrar) |
| Q2 | Aplicar tambem os outros divergentes (Util_Filtro_Lista v9, Preencher v8, etc)? | Default NAO — sao hotfixes V2 sem evidencia de melhoria |
| Q3 | Build label final exato? | `v12.0.0203` (sem sufixo). Se quiser RC, pode ser `v12.0.0203-rc1` |
| Q4 | Atualizar Importador V3 para aceitar manifesto delta? | Sim (~30 linhas adicionais em V3, baixo risco) |

---

## 8. Resumo em 5 linhas

1. V12-202-S e o baseline. Compila + passa trio. Nao mexer no que esta.
2. Aplicar **so Onda 7 e Onda 8** via V3 com manifestos delta separados.
3. Validar com trio minimo + V2 Canonica completa apos cada onda.
4. Atualizar build label `App_Release.bas` para `v12.0.0203` apos as duas ondas verde.
5. Tag + push fecha V12.0.0203.

**Esforco estimado: 4 sessoes curtas (~1h cada) ate FECHAMENTO.**
