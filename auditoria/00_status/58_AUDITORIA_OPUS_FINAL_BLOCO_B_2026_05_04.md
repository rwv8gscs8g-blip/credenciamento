---
titulo: 58 — Auditoria final Opus 4.7 do Bloco B / Onda 18 (V12.0.0203-rc3)
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203-rc3
data: 2026-05-04
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — modo AUDITORIA FINAL
licenca-target: TPGL-v1.1
---

# 58. Auditoria final Opus 4.7 — Bloco B / Onda 18 (rc3)

## Decisão final

**APROVADO_COM_RESSALVAS** para promover `v12.0.0203-rc3` à condição
de release candidate publicável após auditoria Antigravity (doc 59) e
decisão do operador sobre os débitos formais novos (DT-FRENTE1-*).

Não há P0 nem P1 que bloqueiem a devolução do bastão do Codex CLI ao
Opus 4.7 via doc 60. As ressalvas são P2/P3 deferidos em débito
formal já registrado pelo próprio Codex.

| Eixo | Veredito |
|---|---|
| Escopo crítico Onda 18 (MD-18.1a/1b/2/3 + MD-17.5) | ✅ INTEGRO |
| Fonte de verdade `src/vba/` × espelho `local-ai/vba_import/` (M11) | ✅ shasum bate em 12/12 arquivos canônicos |
| Decisão dupla informação (`ContarStrikesPorEmpresa` + `ContarStrikesParaPunicao`) | ✅ Implementada conforme doc 44 §5 |
| Cobertura E2E nova (6 cenários) | ✅ Asserts factuais verdes |
| Quinteto APROVADO final | ✅ `VR_20260504_075624` sintaxe esperada |
| `RPT_BUGS_RESOLVIDOS` move DT-17 sem esconder INT-CAD-OS-REF-ORFA | ✅ Confirmado |
| Forms `Menu_Principal.frm` ↔ `.code-only.txt` (M9/M15/L22/L24) | ✅ Espelho consistente |
| Bump rc3 conservador antes da release final | ✅ Correto |

## P0 / P1 / P2 encontrados

### P0 — Nenhum

Nenhum problema P0 identificado. Os P0 originais do doc 57 (D3, D4, D5)
foram **resolvidos** dentro do Bloco B:

| Doc 57 | Item | Endereçamento |
|---|---|---|
| D3 | `MLB_CabecalhoEmpresas` precisa de coluna U | ✅ `Mod_Limpeza_Base.bas:213-220` adiciona `"DT_ULT_REATIV"` |
| D4 | Fixtures `TV2_CadastrarEmpresaCanonica` precisam coluna U | ✅ `Teste_V2_Engine.bas:1116` grava `""` em `COL_EMP_DT_ULT_REATIV`; `Repo_Empresa.Inserir:187` idem |
| D5 | Decidir data de corte: `DT_FECHAMENTO` vs `DT_AVALIACAO` | ✅ `Repo_Avaliacao.bas:216` usa `COL_OS_DT_FECHAMENTO` (decisão certa — em insert de avaliação, `DT_FECHAMENTO = DT_AVAL` quando não veio explícita; ver `Repo_Avaliacao.bas:67-69`) |

### P1 — Nenhum bloqueante

Nenhum P1 que bloqueie devolução do bastão. Itens listados como
"deferidos" foram registrados como débitos formais com plano,
respeitando o teto de escopo Bloco B negociado no doc 57.

### P2 — Ressalvas (não bloqueantes, deferidas em débito formal)

| # | Ressalva | Arquivo / linha | Severidade | Estado |
|---|---|---|---|---|
| R1 | **Forms Reativa_Empresa.frm e Reativa_Entidade.frm fazem bypass do `Svc_Rodizio.Reativar`** — reativação manual via UI **não grava `DT_ULT_REATIV`**. Empresas reativadas pelo gestor pela UI ficam em modo legado (`usarJanela=False`), invalidando a janela de punição. | `src/vba/Reativa_Empresa.frm:230-348` (Range.Copy direto + linhas excluídas em EMPRESAS_INATIVAS); D1/D2 do doc 57 | 🟠 MÉDIA | DT-FRENTE1-FORMS-BYPASS-REATIV registrado |
| R2 | **`GravarStatusEmpresa` é Public Sub silencioso** — sem retorno de erro. `Svc_Rodizio.Reativar` pode reportar `sucesso=True` sem ter persistido a coluna `U`. | `src/vba/Repo_Empresa.bas:64-100` (D6 do doc 57) | 🟡 BAIXA | DT-FRENTE1-GRAVARSTATUSEMPRESA-SILENT registrado |
| R3 | **Semântica de `Reativar()` em empresa já ATIVA** indefinida — não rejeita, não no-op explícito; renova `DT_ULT_REATIV=Now` zerando janela vigente. | `src/vba/Svc_Rodizio.bas:354-397` (D7 do doc 57) | 🟡 BAIXA | DT-FRENTE1-REATIV-NOOP-ATIVA registrado |
| R4 | **`ContarStrikesParaPunicao` retorna 0 em qualquer erro** — pode mascarar decisão punitiva (empresa parece não ter strikes quando há falha de leitura). | `src/vba/Repo_Avaliacao.bas:236-237` (D9 do doc 57) | 🟠 MÉDIA | DT-FRENTE1-CONTARSTRIKES-ERRO-MUDO registrado |
| R5 | **INT-CAD-OS-REF-ORFA permanece AMARELO** em `RPT_BUGS_CONHECIDOS` — `V2_INTEGRIDADE_BASE` mostra `MANUAL=1` em todas as 5 evidências do Bloco B. Não foi escondido (CS_INT_04 continua detectando), mas é divergência da base que persiste. | `src/vba/Teste_V2_Roteiros.bas:3568` (registra) | 🟡 BAIXA | Aberto em `RPT_BUGS_CONHECIDOS`; pré-existente ao Bloco B |
| R6 | **Log `EVT_AVALIACAO` em `Svc_Avaliacao §386-392` registra apenas `STRIKES` baseado no contador de punição** — doc 56 sugeria que o log mostrasse ambos contadores (histórico total + punição). Auditoria perde visibilidade da divergência entre os dois. | `src/vba/Svc_Avaliacao.bas:386-392` | 🟡 BAIXA | Não-bloqueante; melhoria de auditoria para Onda 19+ |
| R7 | **Backfill de `DT_ULT_REATIV` para empresas legadas via `EVT_REATIVACAO` no AUDIT_LOG não foi implementado** — modo legado fica indefinidamente até primeira reativação real. | (D8 do doc 57) | 🟢 ACEITA | DT-FRENTE1-BACKFILL-AUDIT registrado; comportamento esperado da Opção B |

## Evidências verificadas

### A. Schema EMPRESAS coluna U (MD-18.1a)

| Verificação | Resultado |
|---|---|
| `Const_Colunas.bas:81` declara `Public Const COL_EMP_DT_ULT_REATIV As Long = 21` | ✅ |
| `Mod_Types.bas:53` adiciona `DT_ULT_REATIV As Date` em `TEmpresa` (TABU C4 com plano dedicado) | ✅ |
| `Mod_Limpeza_Base.bas:213-220` cabeçalho EMPRESAS inclui `"DT_ULT_REATIV"` | ✅ |
| `Repo_Empresa.LerEmpresa:47-53` lê coluna U, normaliza vazio para `CDate(0)` | ✅ |
| `Repo_Empresa.Inserir:187` grava `""` (modo legado) em novas empresas | ✅ |
| `Repo_Empresa.GravarStatusEmpresa:92-94` aceita `Optional dtUltReativ As Variant`, grava só se `IsDate` | ✅ |
| `Teste_V2_Engine.TV2_CadastrarEmpresaCanonica:1116` grava `""` em coluna U (legado) | ✅ |
| `Teste_V2_Engine.TV2_CopiarLinhaValores:1680, 1756` copia inativas até a coluna U | ✅ |

### B. Lógica strikes com janela (MD-18.1b)

| Verificação | Resultado |
|---|---|
| `Svc_Rodizio.Reativar:373-376` define `dtReativ = Now` e chama `GravarStatusEmpresa linhaEmp, STATUS_EMP_ATIVA, CDate(0), 0, dtReativ` | ✅ caminho **automático** (acionado por `SelecionarEmpresa` via timeout — linhas 89-90) grava DT_ULT_REATIV |
| `Svc_Rodizio.Reativar:379-384` registra `EVT_REATIVACAO` no AUDIT_LOG com timestamp de `DT_ULT_REATIV` formatado | ✅ |
| `Repo_Avaliacao.ContarStrikesPorEmpresa:119-172` **inalterada** | ✅ histórico total preservado (semântica intacta) |
| `Repo_Avaliacao.ContarStrikesParaPunicao:174-238` **NOVA**, lê `emp.DT_ULT_REATIV` | ✅ |
| Filtro `usarJanela = (dtCorte > CDate(0))` (linha 201) | ✅ modo legado quando vazia |
| Corte `If CDate(dtFech) <= dtCorte Then GoTo proximaLinha` (linha 218) | ✅ exclui OS fechadas em ou antes de DT_ULT_REATIV |
| Coluna do corte: `COL_OS_DT_FECHAMENTO` (X = 8 confirmada em Const_Colunas:164) | ✅ Conforme doc 57 §2.3 (D5) |
| `Svc_Avaliacao §383` substitui chamada para `ContarStrikesParaPunicao(os.EMP_ID, notaMin)` | ✅ |
| `Svc_Avaliacao §374` comentário-vacina explica decisão e cita `DT_ULT_REATIV` | ✅ |

### C. Cobertura E2E nova (6 cenários — MD-18.1b)

| Cenário | Local | Asserts |
|---|---|---|
| `CS_REATIV_DT_ULT_REATIV_GRAVADA` | `Teste_V2_Roteiros.bas:2305-2310` | `empR2S.DT_ULT_REATIV > CDate(0)` |
| `CS_REATIV_HISTORICO_TOTAL_PRESERVADO` | `:2312-2317` | `strikesR2S_total >= 4` (3 antigas + 1 nova) |
| `CS_REATIV_JANELA_EXCLUI_HISTORICO` | `:2319-2324` | `strikesR2S_total >= 4 And strikesR2S_punicao = 1` |
| `CS_E2E_REATIV2STRIKES` (promovido AMARELO→VERDE) | `:2326-2332` | `total>=4 And punicao=1 And STATUS=ATIVA And DT_ULT_REATIV preenchida` |
| `CS_E2E_REATIV3STRIKES` | `:2342-2348` | `punicao>=3 And STATUS=SUSPENSA_GLOBAL` (re-suspende após 3 novas) |
| `CS_REATIV_LEGADO_VAZIO` | `:2371-2377` | `DT_ULT_REATIV = CDate(0) And TOTAL=PUNICAO=1` |

Cobertura responde integralmente às 5 perguntas obrigatórias do prompt
58 sobre testes:

| Pergunta prompt 58 | Cenário cobrindo |
|---|---|
| data gravada | CS_REATIV_DT_ULT_REATIV_GRAVADA |
| histórico preservado | CS_REATIV_HISTORICO_TOTAL_PRESERVADO |
| janela exclui histórico | CS_REATIV_JANELA_EXCLUI_HISTORICO |
| re-suspensão após três novos strikes | CS_E2E_REATIV3STRIKES |
| modo legado com DT_ULT_REATIV vazia | CS_REATIV_LEGADO_VAZIO |

### D. RPT_BUGS_RESOLVIDOS (MD-18.3)

| Verificação | Resultado |
|---|---|
| `TV2_AbaRPTBugsResolvidosGarantirEstrutura` cria aba 13 colunas A-M (`Roteiros.bas:2945-2957`) | ✅ |
| `RegistrarBugResolvido` upsert idempotente (`Roteiros.bas:3065-3094`) | ✅ |
| `TV2_MoverDT17ReativStrikesParaResolvidos` move DT-17 + remove de `RPT_BUGS_CONHECIDOS` (`:3161-3177`) | ✅ |
| `INT-CAD-OS-REF-ORFA` continua sendo registrado em `RPT_BUGS_CONHECIDOS` quando CS_INT_04 detecta órfã (`Roteiros.bas:3568`) | ✅ não escondido |
| Evidência: `V2_INTEGRIDADE_BASE OK=3 / FALHA=0 / MANUAL=1` em todas as 5 VR do Bloco B | ✅ MANUAL=1 = INT-CAD-OS-REF-ORFA exposto |

### E. Statusbar hint Modo Treinamento (MD-18.2)

| Verificação | Resultado |
|---|---|
| `Menu_Principal.frm:628-636` (`Treinamento_ConfirmarUso`) inclui as duas linhas novas | ✅ |
| `local-ai/vba_import/002-formularios/AAM-Menu_Principal.frm` shasum idêntico ao `src/vba/Menu_Principal.frm` (`6376c5bd...`) | ✅ M11 |
| `Menu_Principal.frx` shasum idêntico em src e mirror (`eb4746a2...`) | ✅ designer preservado (M15) |
| `AAM-Menu_Principal.code-only.txt:614-621` espelha mesmo código (offset −14 linhas devido aos `Attribute VB_Name` headers) | ✅ M9/L22 |
| Texto exato conforme doc 50 §2 | ✅ |

### F. Fonte de verdade × espelho (M11)

shasum src/vba ↔ local-ai/vba_import bate em **12/12** arquivos
canônicos auditados:

| Arquivo | shasum match |
|---|---|
| `Mod_Types.bas` ↔ `001-modulo/AAA-Mod_Types.bas` | ✅ |
| `Const_Colunas.bas` ↔ `AAB-Const_Colunas.bas` | ✅ |
| `Mod_Limpeza_Base.bas` ↔ `ABJ-Mod_Limpeza_Base.bas` | ✅ |
| `Repo_Empresa.bas` ↔ `AAO-Repo_Empresa.bas` | ✅ |
| `Svc_Rodizio.bas` ↔ `AAP-Svc_Rodizio.bas` | ✅ |
| `Repo_Avaliacao.bas` ↔ `AAN-Repo_Avaliacao.bas` | ✅ |
| `Svc_Avaliacao.bas` ↔ `AAS-Svc_Avaliacao.bas` | ✅ |
| `Teste_V2_Engine.bas` ↔ `ABF-Teste_V2_Engine.bas` | ✅ |
| `Teste_V2_Roteiros.bas` ↔ `ABG-Teste_V2_Roteiros.bas` | ✅ |
| `Teste_Bateria_Oficial.bas` ↔ `ABA-Teste_Bateria_Oficial.bas` | ✅ |
| `Preencher.bas` ↔ `AAU-Preencher.bas` | ✅ |
| `App_Release.bas` ↔ `AAX-App_Release.bas` | ✅ |
| `Menu_Principal.frm` ↔ `002-formularios/AAM-Menu_Principal.frm` | ✅ |

### G. Manifestos V3 (formato + bloco GRUPO_+M|)

Os 5 manifestos do Bloco B existem e seguem o padrão V3:

| Manifesto | Bloco GRUPO_+M| | Comando documentado |
|---|---|---|
| `MICRO25-fix2` (MD-18.1a schema rollup) | ✅ `# GRUPO_DELTA_MICRO25_FIX2_ONDA18_MD18_1A_SCHEMA_DT_ULT_REATIV` | `ImportarPacoteV3_DeltaC4 "MICRO25-fix2", "..."` (TABU C4) |
| `MICRO26` (MD-18.1b lógica strikes) | ✅ presente | `ImportarPacoteV3_Delta` |
| `MICRO27` (MD-18.3 RPT_BUGS_RESOLVIDOS) | ✅ presente | `ImportarPacoteV3_Delta` |
| `MICRO28` (MD-18.2 statusbar hint) | ✅ presente, F| para AAM-Menu_Principal.frm em modo Estabilizado | `ImportarPacoteV3_Delta` |
| `MICRO29` (MD-17.5 rc3 bump) | ✅ `# GRUPO_DELTA_MICRO29_MD17_5_FECHAMENTO_ONDA17_18_RC3` | `ImportarPacoteV3_Delta` |

### H. Quinteto APROVADO ao longo do Bloco B

| Microdelta | VR | Sintaxe | Observação |
|---|---|---|---|
| MICRO25-fix2 | `VR_20260504_054106` | `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0+IntegridadeBase=3/0` | E2E ainda 65 (cenários novos não importados) |
| MICRO26 | `VR_20260504_060256` | `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0` | **+6 asserts** (1 promoção AMARELO→VERDE + 5 novos) |
| MICRO27 | `VR_20260504_064117` | mesma 71/0 | mover DT-17 não regrediu |
| MICRO28 | `VR_20260504_070441` | mesma 71/0 | hint não regrediu |
| MICRO29 (rc3) | `VR_20260504_075624` | mesma 71/0 | bump conservador, regressão zero |

**Sintaxe final do Bloco B = sintaxe esperada pelo prompt 58**:
`V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0` ✅

Os 5 CSVs estão presentes em `auditoria/evidencias/V12.0.0203/` com
`STATUS=APROVADO` na linha `GERAL`. `MANUAL=1` em V2_INTEGRIDADE_BASE
expõe `INT-CAD-OS-REF-ORFA` (não bloqueia gate; comportamento
esperado).

### I. App_Release rc3

| Constante | Valor |
|---|---|
| `APP_BUILD_IMPORTADO` | `f7aa84f+v12.0.0203-rc3` ✅ |
| `APP_RELEASE_TAG` | `v12.0.0203-rc3` ✅ |
| `APP_RELEASE_STATUS` | `RELEASE_CANDIDATE` ✅ (mantido) |
| `APP_RELEASE_TEST_KEY` | `quinteto-onda18-2026-05-04` ✅ |
| `APP_RELEASE_ATUAL` | `V12.0.0202` ✅ (mantido até FECH final — política Onda 11) |
| Bump conservador (rc3 vs final) | ✅ Conforme decisão do operador no doc 57 §6 |

## Riscos remanescentes aceitos / deferidos

| Risco | Aceito porque | Onde foi deferido |
|---|---|---|
| **DT-FRENTE1-FORMS-BYPASS-REATIV (R1)** — UI manual de reativação não grava DT_ULT_REATIV. Caminho automático (timeout) cobre o uso operacional principal; reativação manual é raro evento de gestor. | Refatorar UI excede teto Bloco B; risco médio no fluxo principal; coberto por DT formal. | ERP `0021-...md18-1b-reativ-strikes.json` + CHANGELOG `Débitos deferidos` |
| **DT-FRENTE1-GRAVARSTATUSEMPRESA-SILENT (R2)** — Sub Public sem retorno de erro. | Erro cosmético; o handler `Erro:` em `Reativar()` cobre falha catastrófica. | DT formal |
| **DT-FRENTE1-REATIV-NOOP-ATIVA (R3)** — semântica `Reativar()` em empresa já ATIVA. | Caso de borda raro (empresa só vira candidata a Reativar após Suspender). | DT formal |
| **DT-FRENTE1-CONTARSTRIKES-ERRO-MUDO (R4)** — retorno 0 em erro. | Risco baixo: erros de leitura em CAD_OS são raros e o pipeline já tem `On Error GoTo falha` em todas as funções correlatas. | DT formal |
| **DT-FRENTE1-BACKFILL-AUDIT (R7)** — empresas legadas seguem em modo histórico até primeira reativação real. | Comportamento intencional da Opção B (preserva backward compat sem migração de dados). | DT formal |
| **INT-CAD-OS-REF-ORFA (R5)** | Pré-existente ao Bloco B; mostra órfã em `RPT_BUGS_CONHECIDOS` quando base operacional tem dados velhos; não regrediu por causa do Bloco B. | `RPT_BUGS_CONHECIDOS` aberto |
| **EVT_AVALIACAO sem ambos contadores (R6)** | Não-bloqueante; melhoria de auditoria. | Recomendação informal para Onda 19+ |

## Resposta às perguntas obrigatórias do prompt 58

| # | Pergunta | Resposta |
|---|---|---|
| 1 | DT_ULT_REATIV respeita fonte de verdade `src/vba/` e espelho `local-ai/vba_import/`? | ✅ shasum bate em 12/12 arquivos auditados (M11 satisfeita) |
| 2 | Decisão dupla informação correta? | ✅ `ContarStrikesPorEmpresa` preserva histórico total (intacta), `ContarStrikesParaPunicao` aplica janela. Cobertura factual em CS_REATIV_HISTORICO_TOTAL_PRESERVADO + CS_REATIV_JANELA_EXCLUI_HISTORICO |
| 3 | `Svc_Rodizio.Reativar` grava DT_ULT_REATIV em todos os caminhos relevantes? | ⚠️ ✅ no caminho **automático** (acionado pelo sistema via `SelecionarEmpresa` → linhas 89-90 do Svc_Rodizio); ❌ no caminho **manual UI** via `Reativa_Empresa.frm` (R1 — DT formal aberto) |
| 4 | `Svc_Avaliacao` usa o contador punitivo correto? | ✅ linha 383 chama `ContarStrikesParaPunicao(os.EMP_ID, notaMin)` |
| 5 | Os 5 testes obrigatórios (data, histórico, janela, re-suspensão, legado) estão cobertos? | ✅ Os 5 cobertos por 6 cenários assertivos verdes (ver §C) |
| 6 | RPT_BUGS_RESOLVIDOS move DT-17 sem esconder INT-CAD-OS-REF-ORFA? | ✅ DT-17 movido via `RegistrarBugResolvido` + `TV2_RemoverBugConhecido`; INT-CAD-OS-REF-ORFA continua exposto em `RPT_BUGS_CONHECIDOS` (MANUAL=1 em V2_INTEGRIDADE_BASE em todas as 5 VR) |
| 7 | `Menu_Principal.frm` e `AAM-Menu_Principal.code-only.txt` coerentes com M9/M15/L22/L24? | ✅ shasum frm e frx batem entre src e mirror; texto da dica idêntico nas duas representações; designer .frx preservado |
| 8 | Bump rc3 conservador o bastante antes do final? | ✅ rc3 mantém `RELEASE_CANDIDATE` e `APP_RELEASE_ATUAL=V12.0.0202`; promoção a final fica condicionada à auditoria cruzada (correto) |
| 9 | Há P0/P1 que bloqueie a devolução do bastão? | ❌ Nenhum |

## Recomendação

### 9.1 Recomendo prosseguir para auditoria Antigravity (doc 59)

Bloco B está integralmente entregue, validado por Quinteto verde
estável em 5 microdeltas consecutivos com sintaxe IDÊNTICA, espelho
shasum-consistente em 12/12 módulos, e cobertura factual completa
das 5 perguntas obrigatórias sobre testes.

### 9.2 Pré-condições para devolução formal do bastão (doc 60)

Antes de o Codex CLI publicar `60_DEVOLUCAO_BASTAO_CODEX_PARA_OPUS_*`,
recomendo confirmar:

1. ✅ Doc 59 (Antigravity) APROVADO ou APROVADO_COM_RESSALVAS sem
   sobreposição com débitos não-listados aqui.
2. 🟡 Operador valida explicitamente os 5 DT-FRENTE1-* novos e
   decide cadência de tratamento (Onda 19? V12.0.0204?).
3. 🟡 Operador decide se rc3 deve ser tagueada em git agora ou se
   espera resolução de R1 (DT-FRENTE1-FORMS-BYPASS-REATIV) antes da
   release final.

### 9.3 Pré-condições para promover rc3 → v12.0.0203 final

Promoção a release final NÃO é recomendada nesta auditoria porque:

- R1 (forms bypass) tem impacto operacional concreto: gestor que usa
  UI manual de reativação não materializa a invariante DT_ULT_REATIV.
  A promoção sem isso resolvido cria divergência silenciosa entre
  caminho automático (correto) e manual (legado eterno).
- Decisão de release final é prerrogativa do operador, mas Opus
  recomenda **resolver R1 em microdelta isolado pré-final** (substituir
  Range.Copy direto por chamada a `Svc_Rodizio.Reativar`).

Se operador decidir promover sem isso, registrar como decisão
explícita no doc 60 com justificativa.

### 9.4 Recomendações para Onda 19 (informacionais)

| # | Recomendação | Justificativa |
|---|---|---|
| 1 | Resolver DT-FRENTE1-FORMS-BYPASS-REATIV (R1) | Maior risco real entre os 5 deferidos |
| 2 | Resolver DT-FRENTE1-CONTARSTRIKES-ERRO-MUDO (R4) | Decisão punitiva mascarada é falha de transparência |
| 3 | Melhorar log EVT_AVALIACAO para mostrar ambos contadores (R6) | Aumenta transparência de auditoria sem refatorar lógica |
| 4 | Backfill EVT_REATIVACAO no AUDIT_LOG (R7/D8) | Permite reconstrução histórica sem mexer na coluna U |

## Markers HBN finais

- 🟢 **HBN CHECKPOINT CLEAN** — Bloco B aprovado em todos os eixos críticos; Quinteto estável em 5 VR consecutivas
- 🟣 **HBN PEER REVIEW** — auditoria Opus 4.7 entregue; aguardando contrapeso Antigravity (Gemini 3.1) no doc 59
- ⚪ **HBN AUDIT-ONLY** — Opus 4.7 manteve modo auditor (sem edits em código de produção; só este doc + memória/README de retomada se aplicável)
- 🔵 **HBN HANDOFF READY** (condicional) — bastão F1 pronto para retornar Codex CLI → Opus 4.7 via doc 60 **após** doc 59 + decisão operador sobre os DT-FRENTE1-*
- 🟤 **HBN LICENSE SPLIT REQUIRED** — TPGL Credenciamento; lições candidatas L28/L29/M24 para promoção AGPLv3 quando MD-17.5 oficializar PHAGOCYTOSIS

## Documentos relacionados

- [44 — Débito DT-17-REATIV-STRIKES (spec)](44_DEBITO_DT_17_REATIV_STRIKES.md)
- [50 — Débito DT-MD17.1.e-STATUSBAR-HINT](50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md)
- [55 — Auditoria Antigravity 2026-05-04](55_AUDITORIA_ANTIGRAVITY_2026_05_04.md)
- [56 — QA Codex 2026-05-04](56_QA_CODEX_2026_05_04.md)
- [57 — Passagem do bastão F1 Opus → Codex (Bloco B)](57_PASSAGEM_BASTAO_F1_OPUS_PARA_CODEX_BLOCO_B_2026_05_04.md)
- [Fechamento Onda 17](../03_ondas/onda_17_test_first/70_FECHAMENTO_ONDA_17.md)
- [Fechamento Onda 18](../03_ondas/onda_18_reativ_strikes/70_FECHAMENTO_ONDA_18.md)
- [ERP 0020 — schema](../../.hbn/results/0020-exec-onda18-md18-1a-schema.json)
- [ERP 0021 — strikes window](../../.hbn/results/0021-exec-onda18-md18-1b-reativ-strikes.json)
- [ERP 0022 — RPT_BUGS_RESOLVIDOS](../../.hbn/results/0022-exec-onda18-md18-3-rpt-bugs-resolvidos.json)
- [ERP 0023 — statusbar hint](../../.hbn/results/0023-exec-onda18-md18-2-statusbar-hint.json)
- [ERP 0024 — fechamento rc3](../../.hbn/results/0024-exec-onda17-18-fechamento-rc3.json)

## Versão

- v1.0 — 2026-05-04 — Opus 4.7 (Cowork) entrega auditoria final do
  Bloco B / Onda 18; veredito APROVADO_COM_RESSALVAS para devolução do
  bastão; recomendação de não promover rc3 a release final sem
  resolver DT-FRENTE1-FORMS-BYPASS-REATIV (R1).
