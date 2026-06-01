---
titulo: Prompt de auditoria cruzada — integridade referencial + idempotência em ciclo de estabilização V206
data: 2026-05-27
autoria: claude-opus-4-7 (sessão Onda 38.2.2 ENTREGUE PARCIAL → preparação 38.2.3)
destinatarios: Codex (sessão paralela) + Antigravity (sessão paralela)
contexto: V12.0.0206 em validação iterativa; RVS REPROVADO `VR_20260527_060519`; 3 vetores convergentes apontando para problema sistêmico de tipo numérico vs textual em IDs
formato: 2 prompts independentes (Codex + Antigravity) com mesma carga útil, redação adaptada ao perfil de cada IA
---

# Prompt de auditoria cruzada — integridade referencial + idempotência (Onda 38.2.3 pre-flight)

## Contexto compartilhado

**Sistema**: Credenciamento V12.0.0206 (Excel/VBA, Sistema de Gestão de Pequenos Reparos).
**Branch**: `codex/v12-0-0206-planejamento` (HEAD `731bc9e`).
**Anchor V206 funcional**: commit `ee75b30` + RVS Trio APROVADO `VR_20260526_102200`.
**Estado**: Onda 38.2.2 ENTREGUE PARCIAL com 5 hotfixes consecutivos (`c9bcd41` → `f855d0b` → `88b347b` → `854c392` → `255d3bc` → `a51b191`); RVS atual REPROVADO `VR_20260527_060519`.
**Diretiva Mauricio (2026-05-27)**: garantir **integridade referencial** + **idempotência** em todo o sistema antes do freeze V206. Hipótese central: a sequência de correções (38.2.1 → 38.2.1-AR1 → FIX2-PERF → 38.2.2) introduziu desestabilização que precisa ser revisada e corrigida sistematicamente, não em microdeltas isolados.

## 3 vetores observados convergentes

### Vetor 1 — F-NEW5: rodízio "sem empresas disponíveis" para credenciamento novo

**Observado por operador** durante validação tela-a-tela pós-import 38.2.2:

1. Cadastrou atividade nova "CULTIVO DE ALGODÃO HERBÁCEO" (CNAE 0112-1/01).
2. Cadastrou serviço "teste de algodao" (R$1000) sob essa atividade.
3. Credenciou Empresa 5 na atividade — UI confirmou "Novos credenciamentos: 1".
4. Tentou emitir Pre-OS para a atividade → erro: **"Não foi possível emitir a Pre-OS: não há empresas disponíveis para esta atividade."**

Relatório de credenciamentos mostrou `STATUS_CRED` **vazio** para credenciamentos novos (`CULTIVO DE TRIGO` + `CULTIVO DE ALGODÃO HERBÁCEO`) mas mostra `"ATIVO"` para credenciamentos da fixture (`Atividade E2E Strikes`).

**Verificação posterior (sessão Opus)**:
- Único ponto de gravação de `COL_CRED_STATUS` em runtime real: [`Credencia_Empresa.frm:178`](src/vba/Credencia_Empresa.frm#L178) — grava `STATUS_CRED_ATIVO` literal.
- Versão pré-onda 38.2.2 (`ee75b30`) também grava na mesma linha.
- Nenhum sub em `src/vba/` zera coluna 13 de CREDENCIADOS.
- Sheet `CREDENCIADOS` no workbook **não tem código** (sem `Worksheet_Change`/`Worksheet_BeforeSave`).
- `ThisWorkbook` só chama `IniciarSistema` em `Workbook_Open`.

### Vetor 2 — V2_SMOKE drift estrutural: `Cadastro_Servico.frm`

**Falha do RVS `VR_20260527_060519`**:

```
CENARIO=CS_UISMOKE_Cadastro_Servico_V4
OBJETIVO=Comparacao .frm <-> .code-only.txt (gamma) Cadastro_Servico
ESPERADO=Normalizacao gamma identica
OBTIDO=DIVERGE: len_frm=9307 len_co=9179
SIGNIFICADO=Drift estrutural alem do cosmetico - investigar manualmente
```

Diferença de 128 caracteres normalizados (após `TV2_UI_NormalizarGammaTexto`). Suspeita inicial: hotfixes sequenciais editaram `.frm` sem sincronizar `.code-only.txt` (publicar_vba_import_v2.sh --apply não rodado entre hotfixes).

### Vetor 3 — V2_E2E_STRIKES `DIAG_PREOS_INTEGRITY`: tipo numérico vs textual

**Falha do RVS `VR_20260527_060519`**:

```
CENARIO=DIAG_PREOS_INTEGRITY
OBJETIVO=EMP preselecionada deve coincidir com EMP gravada em PRE_OS
ESPERADO=EMP=001
OBTIDO=EMP_PRESEL=001 EMP_PREOS=1
SIGNIFICADO=Detecta dupla selecao divergente entre observador e EmitirPreOS interno
```

**Hipótese F-NEW6 (sistêmica) levantada por Opus 4.7**:

- [`Repo_Empresa.LerEmpresa:26`](src/vba/Repo_Empresa.bas#L26) → `emp.EMP_ID = CStr(ws.Cells(iRow, COL_EMP_ID).Value)` — `CStr` direto. Se `EMPRESAS!EMP_ID` armazena `"001"` textual → retorna `"001"`. Se armazena `1` numérico → retorna `"1"`. Sem normalização `Pad3`.
- [`Repo_PreOS.BuscarPorId:83`](src/vba/Repo_PreOS.bas#L83) → mesma implementação. Se PRE_OS grava EMP_ID sem `NumberFormat="@"`, Excel converte para Long, e o `CStr` recupera como `"1"` (não `"001"`).

A Onda 38.2.2 (AT-3 sistemático) aplicou `NumberFormat = "@"` em **5 caminhos UI de cadastros** (Menu_Principal entidade/empresa-alt + Credencia_Empresa + Cadastro_Servico atividade/serviço) + Service path `Repo_Empresa.Inserir` (hotfix 5). **Não tocou em**:
- `Repo_PreOS.bas` (gravações em PRE_OS)
- `Repo_OS.bas` (gravações em CAD_OS)
- `Repo_Avaliacao.bas` (gravações em AVALIACOES)
- `Repo_Credenciamento.bas` (não tem `.Inserir`, mas hidratação `LerCredenciamento` força `CStr` sem `Pad3`)
- Fixtures de teste (`Teste_V2_Engine.bas`, `Teste_Bateria_Oficial.bas` — débito V207 conhecido)

**Evidência empírica recente (dump CREDENCIADOS pós-V1)**:

```
L3 | CRED=002 | EMP=001/String | ATIV=999/Double | STATUS=ATIVO/String
L4 | CRED=003 | EMP=002/String | ATIV=999/Double | STATUS=ATIVO/String
L5 | CRED=004 | EMP=003/String | ATIV=999/Double | STATUS=ATIVO/String
```

`ATIV_ID` armazenado como `Double` valor `999` em **todas as linhas** (fixture E2E Strikes). EMP_ID armazenado como `String "001/002/003"`. **Mistura de tipos persistida no mesmo workbook**, sinalizando que a normalização de IDs não é consistente entre Repos.

## Pedido específico de auditoria

### 1. Validar/refutar a hipótese F-NEW6

- A hipótese de que **inconsistência de NumberFormat + ausência de `Pad3` em hidratação de Repos** é a causa raiz de F-NEW5 + V2_E2E_STRIKES procede?
- Há outras manifestações possíveis (PRE_OS, OS, AVALIACOES, AUDIT_LOG) onde o mismatch de tipo pode estar causando bugs silenciosos?
- Existe ângulo cego além dos Repos enumerados acima?

### 2. Mapa de gravação de IDs por aba

Enumerar (com `file:line`) **TODOS** os pontos de gravação de IDs operacionais nas abas:
- `EMPRESAS!COL_EMP_ID` (1)
- `ENTIDADE!COL_ENT_ID` (1)
- `CREDENCIADOS!COL_CRED_ID` (1), `COL_CRED_EMP_ID` (3), `COL_CRED_ATIV_ID` (10), `COL_CRED_COD_ATIV_SERV` (2)
- `CAD_SERV!COL_SERV_ID` (1), `COL_SERV_ATIV_ID` (2)
- `ATIVIDADES!COL_ATIV_ID` (1)
- `PRE_OS!COL_PREOS_ID` (1), `COL_PREOS_EMP_ID` (?), `COL_PREOS_ATIV_ID` (?), `COL_PREOS_SERV_ID` (?)
- `CAD_OS!COL_OS_ID` (1), `COL_OS_EMP_ID` (?), `COL_OS_ATIV_ID` (?)
- `AVALIACOES!COL_AVAL_ID` (1), `COL_AVAL_EMP_ID` (?), `COL_AVAL_OS_ID` (?)
- `AUDIT_LOG` (todos os ID_AFETADO, etc.)

Para cada ponto:
- (a) está aplicando `NumberFormat = "@"` ANTES da gravação?
- (b) está normalizando o valor via `Pad3` (ou equivalente) na gravação?
- (c) está sendo lido via `CStr` direto na hidratação (suscetível a `"1"` vs `"001"`)?
- (d) é caminho de produção (UI ou Service) ou fixture de teste?

### 3. Mapa de leitura/comparação de IDs

Enumerar pontos de comparação direta `String = String` (com `=` ou `StrComp`) entre IDs lidos de células e IDs literais/calculados, **fora** de `Util_Planilha.IdsIguais`. Toda comparação fora de `IdsIguais` é candidata a falha silenciosa por mismatch de tipo.

### 4. Idempotência

Mapear as principais operações safe_track e classificar:

| Operação | É idempotente hoje? | Onde quebra? | Severidade |
|---|---|---|---|
| `Repo_Empresa.Inserir` | | | |
| `Repo_Empresa.Atualizar` | | | |
| `Repo_Empresa.GravarStatusEmpresa` | | | |
| `Credencia_Empresa.CR_Credenciar_Click` | | | |
| `Cadastro_Servico.S_Cadastrar_SV_Click` | | | |
| `Svc_PreOS.EmitirPreOS` | | | |
| `Svc_OS.EmitirOS` | | | |
| `Svc_Avaliacao.RegistrarAvaliacao` | | | |
| `Svc_Rodizio.AvancarFila` | | | |
| `Svc_Rodizio.SelecionarEmpresa` | | | |
| `Util_Sanear_Contadores.SanearContadoresAR1` | | | |
| `IniciarSistema` (chamado em `Workbook_Open`) | | | |

**Definição operacional de idempotência aqui**: rodar a mesma operação 2× consecutivas (sem mudança de input) produz o mesmo estado final, sem efeitos colaterais cumulativos (duplicação de linha, incremento extra de contador, AUDIT_LOG duplicado, etc.).

### 5. Integridade referencial

Enumerar invariantes de integridade que **deveriam** valer sempre:
- `CREDENCIADOS.EMP_ID` existe em `EMPRESAS.EMP_ID` ou `EMPRESAS_INATIVAS.EMP_ID`?
- `CREDENCIADOS.ATIV_ID` existe em `ATIVIDADES.ATIV_ID`?
- `CREDENCIADOS.COD_ATIV_SERV` = `ATIV_ID & SERV_ID` (ambos Pad3) e existe em `CAD_SERV`?
- `PRE_OS.EMP_ID` existe em EMPRESAS + `PRE_OS.ATIV_ID` em ATIVIDADES + a combinação `(EMP_ID, ATIV_ID)` existe em CREDENCIADOS com `STATUS_CRED = "ATIVO"`?
- `CAD_OS.PREOS_REF` existe em PRE_OS?
- `AVALIACOES.OS_REF` existe em CAD_OS?
- Para cada invariante: existe **macro de verificação** (auditoria)? Se sim, ela cobre tipo numérico vs textual?

Recomendar um conjunto mínimo de **macros de auditoria de integridade referencial** que possam ser rodadas pelo operador antes de qualquer freeze.

### 6. Recomendação de correção sistêmica

Não pedimos implementação. Pedimos plano em camadas:

- **Camada 1 — Helpers compartilhados** (centralização): introduzir `Util_Planilha.GravarIdTextual(ws, linha, coluna, idValue)` que faz `NumberFormat="@"` + grava `Pad3(idValue)` em um único ponto. Substituir TODAS as gravações dispersas por essa função em uma onda dedicada.
- **Camada 2 — Hidratação consistente**: substituir `CStr(ws.Cells(..., COL_*_ID).Value)` por `Util_Planilha.LerIdTextual(ws, linha, coluna)` que retorna `Pad3` quando possível.
- **Camada 3 — Auditoria contínua**: macro `AuditarIntegridadeReferencial` rodada antes de cada freeze, com saída CSV; falha = bloqueio do freeze.
- **Camada 4 — Migração de dados legados**: como tratar células já gravadas como Long no workbook do operador (não pode quebrar dados existentes).

Para cada camada: estimar onda(s) e dependências.

### 7. Ordem de execução proposta

Dado que o sistema está EM USO (Mauricio testando dia-a-dia), propor sequência de ondas que:
- Minimize risco de regressão em fluxos já validados (E2E Strikes)
- Resolva o bug F-NEW5 primeiro (alta prioridade — bloqueia rodízio)
- Resolva V2_SMOKE drift (trivial — só re-sync `--apply`)
- Resolva V2_E2E_STRIKES + F-NEW6 sistêmico (médio-grande, multi-onda)
- Não antecipe decisões V207 (cache in-memory, ORM, Svc_Cadastro*)

## Restrições

- **Sem implementação**. Pedimos plano, não diff.
- **Sem decisões V207**. Foco em estabilização V206 puro.
- **Sem tocar tabus**: `Mod_Types.bas`, `Importador_V3.bas`, `Svc_*` blindados (Rodizio, Avaliacao, OS, PreOS, Entidade, Transacao), `Auto_Open.bas`, 10 forms blindados.
- **Knowledge 0016 vigente**: `App_Release.bas` ficou no estado atual; V3 fará BUMP no próximo import.
- **PHAGOCYTOSIS-VBA-PATTERNS**: L10 (não qualificar standard module), L14 (pre-flight signatures), L22-L24 (sempre que toca .frm), M9 (PHAGOCYTOSIS UI).

## Output esperado

Arquivo `.md` salvo em `.hbn/proposals/`:
- **Codex**: `0009-codex-auditoria-integridade-idempotencia-v206.md`
- **Antigravity**: `0010-antigravity-auditoria-integridade-idempotencia-v206.md`

Estrutura sugerida:
1. Análise dos 3 vetores (concordância/discordância com hipótese F-NEW6)
2. Mapa completo (pedidos 2 + 3) — tabela ou listagem
3. Avaliação de idempotência (pedido 4) — tabela preenchida
4. Mapa de integridade referencial + macros de auditoria (pedido 5)
5. Plano de correção em camadas (pedido 6)
6. Sequência de ondas proposta (pedido 7)
7. Riscos identificados + mitigações
8. Comentário sobre divergências entre vocês (se relevante)

Após ambos os outputs, Opus 4.7 consolida em `auditoria/00_status/116_ANALISE_AUDITORIA_INTEGRIDADE_IDEMPOTENCIA.md` e propõe escopo da Onda 38.2.3 com hearback explícito.

---

## VERSÃO CODEX (copiar/colar em sessão paralela)

```
Você é o Codex (auditor técnico paralelo) no Sistema de Credenciamento V12.0.0206 (Excel/VBA), branch codex/v12-0-0206-planejamento, HEAD 731bc9e.

Contexto: A Onda 38.2.2 foi entregue parcial com 5 hotfixes consecutivos. O RVS VR_20260527_060519 REPROVOU com 2 falhas que, combinadas com um bug operacional reportado (F-NEW5 — rodízio "sem empresas" para credenciamento manual novo), sugerem problema sistêmico de integridade referencial e idempotência. Mauricio (operador/arquiteto) pediu auditoria cruzada antes de propor onda 38.2.3.

Documento completo do prompt: auditoria/00_status/115_PROMPT_AUDITORIA_CRUZADA_INTEGRIDADE_IDEMPOTENCIA.md

Tarefa: produza um relatório em .hbn/proposals/0009-codex-auditoria-integridade-idempotencia-v206.md cobrindo:

1. ANÁLISE DOS 3 VETORES (V2_SMOKE drift; V2_E2E_STRIKES DIAG_PREOS_INTEGRITY; F-NEW5 STATUS_CRED vazio em credenciamento novo).
   - Concorda/discorda com a hipótese F-NEW6 sistêmica (mismatch de tipo Long vs String em IDs por ausência de NumberFormat="@" + Pad3 nos Repos PreOS/OS/Avaliacao)?
   - Quais outros vetores podem estar envolvidos?

2. MAPA EXAUSTIVO de gravação de IDs operacionais em todas as abas: EMPRESAS, ENTIDADE, CREDENCIADOS, CAD_SERV, ATIVIDADES, PRE_OS, CAD_OS, AVALIACOES, AUDIT_LOG. Para cada ponto file:line: usa NumberFormat="@"? Usa Pad3? Hidratação via CStr puro?

3. MAPA de comparação de IDs FORA de Util_Planilha.IdsIguais. Cada hit é candidato a bug silencioso.

4. TABELA de idempotência das operações safe_track principais (Repo_Empresa.Inserir/Atualizar/GravarStatusEmpresa, Credencia_Empresa.CR_Credenciar_Click, Cadastro_Servico.S_Cadastrar_SV_Click, Svc_PreOS.EmitirPreOS, Svc_OS.EmitirOS, Svc_Avaliacao.RegistrarAvaliacao, Svc_Rodizio.AvancarFila/SelecionarEmpresa, Util_Sanear_Contadores.SanearContadoresAR1, IniciarSistema). Cada uma: é idempotente? Onde quebra? Severidade?

5. INVARIANTES de integridade referencial entre abas (CREDENCIADOS↔EMPRESAS/EMPRESAS_INATIVAS, CREDENCIADOS↔ATIVIDADES, CREDENCIADOS↔CAD_SERV, PRE_OS↔CREDENCIADOS, CAD_OS↔PRE_OS, AVALIACOES↔CAD_OS). Macros de auditoria mínimas para validar.

6. PLANO de correção em 4 camadas (helpers compartilhados → hidratação consistente → auditoria contínua → migração legado). Estimar ondas.

7. SEQUÊNCIA de ondas proposta para Onda 38.2.3 + 38.2.4 + 38.2.5 até freeze V206.

8. RISCOS + mitigações.

RESTRIÇÕES INVIOLÁVEIS:
- Sem implementação (sem diff). Plano em texto + tabelas + file:line.
- Sem decisões V207 (cache in-memory, ORM, Svc_Cadastro*).
- Sem tocar tabus: Mod_Types.bas, Importador_V3.bas, Svc_* blindados, Auto_Open.bas, 10 forms blindados (Altera_*, Reativa_*, Configuracao_Inicial, Limpar_Base, Fundo_Branco, ProgressBar, Rel_Emp_Serv, Rel_OSEmpresa).
- Knowledge 0016: App_Release.bas no estado atual.
- PHAGOCYTOSIS-VBA-PATTERNS L10, L14, L22-L24, M9 obrigatórias.

Aprofunde no que vê com seu próprio olhar (não copie minhas hipóteses sem validar). Se discordar de algo no prompt, explicite. Output em português técnico, .md, ≤ 35KB.

Commit no final: `git add .hbn/proposals/0009-codex-*.md && git commit -m "audit(v206): codex - integridade referencial + idempotencia"` — NÃO PUSH.
```

---

## VERSÃO ANTIGRAVITY (copiar/colar em sessão paralela)

```
Você é o Antigravity (auditor sistêmico paralelo) no Sistema de Credenciamento V12.0.0206 (Excel/VBA), branch codex/v12-0-0206-planejamento, HEAD 731bc9e.

Contexto: A Onda 38.2.2 foi entregue parcial com 5 hotfixes consecutivos. O RVS VR_20260527_060519 REPROVOU com 2 falhas que, combinadas com um bug operacional reportado (F-NEW5 — rodízio "sem empresas" para credenciamento manual novo), sugerem problema sistêmico de integridade referencial e idempotência. Mauricio pediu auditoria cruzada antes de propor onda 38.2.3.

Documento completo do prompt: auditoria/00_status/115_PROMPT_AUDITORIA_CRUZADA_INTEGRIDADE_IDEMPOTENCIA.md

Diferentemente do Codex (foco técnico file:line), seu olhar deve ser SISTÊMICO:
- Onde a arquitetura tolera/não-tolera essa classe de erro?
- Que invariantes a Máquina de Estados (doc/Time_AI/001-Sprint0-Maquina-de-Estados.md) assume que estão violadas hoje?
- Que padrões cross-cutting (NumberFormat textual, hidratação consistente, idempotência, auditoria referencial) deveriam estar centralizados e hoje estão dispersos?
- Como medir continuamente — não só em RVS — que essas invariantes seguem valendo?

Tarefa: produza um relatório em .hbn/proposals/0010-antigravity-auditoria-integridade-idempotencia-v206.md cobrindo:

1. LEITURA SISTÊMICA dos 3 vetores (V2_SMOKE drift; V2_E2E_STRIKES; F-NEW5). O que cada um diz sobre saúde arquitetural?

2. ANTI-PADRÕES identificados além de F-NEW6:
   - Dispersão de NumberFormat="@" (vs centralização em helper)
   - CStr puro em hidratação (vs Pad3 na leitura)
   - Comparações de String fora de IdsIguais (vs IdsIguais único)
   - Gravação em múltiplos paths sem helper unificado (Repo + UI + Fixture independentes)
   - Outros?

3. INVARIANTES da Máquina de Estados que dependem desses padrões. Quais hoje estão violáveis silenciosamente?

4. MAPA de idempotência das operações principais (mesma tabela do pedido Codex). Foco em RACE CONDITIONS, EFEITOS COLATERAIS CUMULATIVOS, AUDIT_LOG duplicação.

5. INTEGRIDADE REFERENCIAL: invariantes desejadas + como instrumentar verificação contínua (não só em RVS de freeze).

6. PLANO de correção em camadas, com ênfase em:
   - Reuso de helpers (centralizar)
   - Migração de dados legados (workbook em uso)
   - Testes que cubram fluxos NOVOS, não apenas fixtures (L40 — meta-validação dos testes)

7. SEQUÊNCIA de ondas até freeze V206. Recomendar pausas para validação tela-a-tela após cada onda.

8. RISCOS sistêmicos + mitigações.

9. COMENTÁRIO sobre L40 (meta-validação) — como garantir que a suite de testes cobre fluxos não-fixture antes do freeze?

RESTRIÇÕES INVIOLÁVEIS:
- Sem implementação.
- Sem decisões V207 (cache in-memory, ORM, Svc_Cadastro*).
- Sem tocar tabus: Mod_Types.bas, Importador_V3.bas, Svc_* blindados, Auto_Open.bas, 10 forms blindados (Altera_*, Reativa_*, Configuracao_Inicial, Limpar_Base, Fundo_Branco, ProgressBar, Rel_Emp_Serv, Rel_OSEmpresa).
- Knowledge 0016: App_Release.bas no estado atual.
- PHAGOCYTOSIS-VBA-PATTERNS L10, L14, L22-L24, M9 obrigatórias.

Aplique seu olhar sistêmico ao máximo — esse é o seu diferencial vs Codex. Output em português técnico, .md, ≤ 25KB.

Commit no final: `git add .hbn/proposals/0010-antigravity-*.md && git commit -m "audit(v206): antigravity - integridade referencial + idempotencia sistemica"` — NÃO PUSH.
```

---

## Pós-auditoria — consolidação Opus

Quando ambos `0009-*` e `0010-*` estiverem commitados (sem push), Opus 4.7 (próxima sessão ou continuação) consolida em:

`auditoria/00_status/116_ANALISE_AUDITORIA_INTEGRIDADE_IDEMPOTENCIA.md`

Com estrutura:
1. Convergências entre Codex + Antigravity
2. Divergências reais (não cosméticas)
3. Hipótese F-NEW6 — validada, refutada, ou refinada?
4. Recomendação Opus para escopo da Onda 38.2.3 (AT-1, AT-2, AT-3...)
5. Roadmap atualizado até freeze V206
6. Decisão preliminar Mauricio com 3 hipóteses (se aplicável)

Hearback Mauricio decide. Onda 38.2.3 abre readback 0112 com o escopo aprovado.
