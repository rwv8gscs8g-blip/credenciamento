---
titulo: 64 - Auditoria Opus V203 rc4 e proposta V204
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203-rc4
data: 2026-05-04
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento — modo AUDITORIA CRUZADA FINAL
licenca-target: TPGL-v1.1
---

# 64. Auditoria Opus 4.7 — V12.0.0203-rc4 e proposta V12.0.0204

## 1. Decisão executiva

**APROVADO_PARA_TESTE_MANUAL.**

A `v12.0.0203-rc4` cumpre o Quinteto Mínimo no gate canônico
`VR_20260504_171048` com sintaxe esperada
`V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0`
([CSV](../evidencias/V12.0.0203/ValidacaoReleaseQuinteto_V12_0_0203_VR_20260504_171048.csv)),
fecha em código a ressalva R1 da auditoria cruzada (forms bypass de
reativação de empresa) via `MICRO30` + `MICRO30-fix1`, preserva o
contrato de dual-counter da Onda 18 (histórico total + janela de
punição via `DT_ULT_REATIV`) e mantém o espelho `src/vba/` ↔
`local-ai/vba_import/` consistente em 12/12 módulos (M11) conforme
auditoria 58.

A liberação é **estritamente para teste manual formal**. **Não é
liberação para produção.** Os fluxos de UI ainda guardam débitos com
impacto operacional (Reativa_Entidade ainda em bypass simétrico ao
estado pré-MICRO30 da empresa, ausência de guard de reentrada nos
`_DblClick` destrutivos, mutação cruzada `COL_CRED_ATIV_ID` na
reativação da empresa, ContarStrikes silenciando erro e
GravarStatusEmpresa sem retorno verificável). Estes débitos são o
miolo do escopo proposto para a V12.0.0204.

| Eixo | Veredito |
|---|---|
| Quinteto Mínimo `VR_20260504_171048` | ✅ APROVADO (171/0 + 27/0 + 23/0 + 71/0 + 3/0) |
| `MICRO30 + MICRO30-fix1` (R1 empresa) | ✅ Form `Reativa_Empresa.frm` agora chama `ReativarLinhaEmpresa` e `ClassificaEmpresa` ordena até a coluna U |
| Dual-counter strikes (Opção B) | ✅ Mantido — `ContarStrikesPorEmpresa` intacto + `ContarStrikesParaPunicao` funcional |
| Espelho src ↔ vba_import (M11) | ✅ Conforme auditoria 58 (12/12) — sem regressão na rc4 |
| `RPT_BUGS_RESOLVIDOS` move DT-17 sem esconder INT-CAD-OS-REF-ORFA | ✅ |
| App_Release coerente com tag/build/test_key | ✅ rc4 |
| Forms restantes em bypass (Reativa_Entidade, mutação ATIV_ID, reentrada) | ❌ aberto — V204 |
| Liberação para produção | ❌ Não autorizada |

## 2. Achados P0 / P1 / P2

> Achados P0 e P1 listados aqui não bloqueiam a liberação para teste
> manual (a rc4 não é produção). Eles **bloqueiam** a promoção a
> `v12.0.0203` final ou a `V12.0.0204` final se não forem resolvidos.

### 2.1 P0 — Bloqueadores para promoção a release final

| ID | Local | Descrição |
|---|---|---|
| **P0-A** | [src/vba/Reativa_Entidade.frm:316-318](../../src/vba/Reativa_Entidade.frm#L316-L318) e [240-355](../../src/vba/Reativa_Entidade.frm#L240-L355) | **Bypass simétrico ao R1 da empresa, ainda aberto na rc4.** O handler `R_Lista_DblClick` faz `wsInativas.Rows(linhaCopia).Copy Destination:=wsEntidade.Cells(linhaDestino, 1)` e exclui linhas em `ENTIDADE_INATIVOS` sem chamar nenhum serviço (`Svc_Rodizio.Reativar` é só de empresa) e **sem registrar `EVT_REATIVACAO` em `AUDIT_LOG`**. Onde o caminho de empresa hoje materializa `STATUS=ATIVA`, `QTD_RECUSAS=0`, `DT_FIM_SUSP=(limpa)`, `DT_ULT_REATIV=Now` e auditoria via `ReativarLinhaEmpresa`, o caminho de entidade ainda materializa apenas a cópia de linha. **Regra V203 #5 (AUDIT_LOG cobre toda ação com efeito de estado) é violada.** |
| **P0-B** | [src/vba/Reativa_Empresa.frm:339-352](../../src/vba/Reativa_Empresa.frm#L339-L352) | **Mutação cruzada não documentada após reativação.** Após chamar `ReativarLinhaEmpresa` com sucesso, o handler entra em `wsCred` e zera `COL_CRED_ATIV_ID` de **todas** as linhas cujo `COL_CRED_EMP_ID` bate (comparação `CLng(Val("0" & ...))`). Isto efetivamente "desativa" o vínculo da empresa reativada com cada atividade que ela já estava credenciada — a empresa volta ao mundo ativa sem mais aparecer em nenhuma fila de rodízio até ser recredenciada. Pode ser **intencional** (premissa: reativação após inativação administrativa exige re-credenciamento por atividade) ou **bug crítico** (perda silenciosa de vínculos). Não há cenário de teste que assira este efeito, não há `EVT_TRANSACAO` no `AUDIT_LOG` e não há decisão de produto documentada em `auditoria/01_regras_e_governanca/`. **Decisão de produto necessária antes de release final.** |

### 2.2 P1 — Bloqueadores para V12.0.0204 final

| ID | Local | Descrição |
|---|---|---|
| **P1-A** | [src/vba/Reativa_Empresa.frm:222](../../src/vba/Reativa_Empresa.frm#L222), [Reativa_Entidade.frm:240](../../src/vba/Reativa_Entidade.frm#L240), [Limpar_Base.frm](../../src/vba/Limpar_Base.frm), [Menu_Principal.frm:743](../../src/vba/Menu_Principal.frm#L743) (EncerraOS) | **Reentrada por duplo clique sem guard.** Handlers `_DblClick` destrutivos/mutadores não setam flag local "em processamento". Apesar do Excel ser serial, há janelas onde o segundo clique pode disparar lógica sobre estado já alterado (linha de origem já apagada, EMPRESA já reativada). Eco direto do achado P1 em [56_QA_CODEX](56_QA_CODEX_2026_05_04.md) §4 e P0 do doc 65 (Antigravity). **Sem cenário automatizado.** |
| **P1-B** | [src/vba/Repo_Empresa.bas:64-100](../../src/vba/Repo_Empresa.bas#L64-L100) | **`GravarStatusEmpresa` é Public Sub silencioso.** Nenhum retorno de erro. `Svc_Rodizio.Reativar` (caminho automático) e `ReativarLinhaEmpresa` (UI corrigida) podem reportar `sucesso=True` sem persistência efetiva. `ReativarLinhaEmpresa` mitiga em parte com pós-leituras `Err.Raise` em STATUS_GLOBAL/QTD_RECUSAS/DT_ULT_REATIV ([linhas 423-437](../../src/vba/Svc_Rodizio.bas#L423-L437)), **mas o caminho `Suspender` em `Svc_Rodizio.bas:325` não confere a gravação** de `STATUS_EMP_SUSPENSA` e `DT_FIM_SUSP`. DT formal `DT-FRENTE1-GRAVARSTATUSEMPRESA-SILENT` aberto. |
| **P1-C** | [src/vba/Svc_Avaliacao.bas:394-403](../../src/vba/Svc_Avaliacao.bas#L394-L403) e [410-418](../../src/vba/Svc_Avaliacao.bas#L410-L418) | **Falha de `Suspender` e `AvancarFila` ignorada.** `AvaliarOS` chama `Suspender` e descarta `resSusp.sucesso`; chama `AvancarFila` e em falha apenas faz `RegistrarEvento ... AVISO`. Nota baixa pode produzir avaliação com `res.sucesso=True` sem que a empresa tenha sido suspensa (apesar de `strikesAtuais >= maxStrikes`) e sem que a fila tenha avançado. Operador vê "OS avaliada" e segue. |
| **P1-D** | [src/vba/Repo_Avaliacao.bas:170-172](../../src/vba/Repo_Avaliacao.bas#L170-L172) e [236-237](../../src/vba/Repo_Avaliacao.bas#L236-L237) | **Erro silencioso vira "sem strikes".** Tanto `ContarStrikesPorEmpresa` quanto `ContarStrikesParaPunicao` retornam `0` em qualquer falha. `ContarStrikesParaPunicao` alimenta diretamente a decisão de suspender em `Svc_Avaliacao.bas:383`. Erro de leitura em `CAD_OS` produz a falsa proposição "esta empresa não tem strikes" e empresa segue ativa. DT formal `DT-FRENTE1-CONTARSTRIKES-ERRO-MUDO` aberto. |
| **P1-E** | [src/vba/Reativa_Empresa.frm:343-348](../../src/vba/Reativa_Empresa.frm#L343-L348) | **Comparação de EMP_ID via `CLng(Val("0" & ...))`.** Esta normalização colapsa IDs alfanuméricos para 0 e iguala todos os credenciamentos com EMP_ID não numérico em uma única classe — a mutação descrita em P0-B se propaga em massa para qualquer cred com EMP_ID alfanumérico. Hoje o projeto usa IDs numéricos com padding (`"001"`); o risco é latente e ativa com qualquer drift futuro de domínio. |
| **P1-F** | [src/vba/Repo_Empresa.bas:39-53](../../src/vba/Repo_Empresa.bas#L39-L53) | **`LerEmpresa` normaliza data inválida silenciosamente.** Quando `COL_EMP_DT_ULT_REATIV` contém string ou erro, `LerEmpresa` retorna `CDate(0)` sem evento. Isto é interpretado por `ContarStrikesParaPunicao:201` como "modo legado" — empresa reativada com a coluna corrompida volta a contar histórico total. Eco do risco "Inválida (String)" da matriz combinatória do doc 65 §3. |

### 2.3 P2 — Recomendações não bloqueantes

| ID | Local | Descrição |
|---|---|---|
| **P2-A** | [src/vba/Svc_Rodizio.bas:39-154](../../src/vba/Svc_Rodizio.bas#L39-L154) | `SelecionarEmpresa` muta estado em nome aparentemente neutro (reativa em [85-97](../../src/vba/Svc_Rodizio.bas#L85-L97), move para fim em [110-115](../../src/vba/Svc_Rodizio.bas#L110-L115), grava `DT_ULTIMA_IND` em [132](../../src/vba/Svc_Rodizio.bas#L132)). Eco do P2 do doc 56 §3. Documentar o contrato no comentário do header do módulo, ou renomear (custo alto de refactor). |
| **P2-B** | [src/vba/Svc_Avaliacao.bas:386-392](../../src/vba/Svc_Avaliacao.bas#L386-L392) | `EVT_AVALIACAO` registra apenas o contador de punição. Em pós-reativação, operador inspecionando o log não vê o histórico total. Doc 56 propôs registrar os dois números; doc 58 marcou como melhoria informacional para Onda 19+. |
| **P2-C** | [src/vba/Classificar.bas:29-52](../../src/vba/Classificar.bas#L29-L52) | Range hardcoded até `COL_EMP_DT_ULT_REATIV` (corrigido em `MICRO30-fix1`). Próxima coluna acrescentada à aba EMPRESAS exige nova revisão manual. Considerar derivar o range a partir do "última coluna canônica conhecida" (constante em `Const_Colunas`). |
| **P2-D** | [src/vba/Limpar_Base.frm:16-29](../../src/vba/Limpar_Base.frm#L16-L29) e [Mod_Limpeza_Base.bas:54-62](../../src/vba/Mod_Limpeza_Base.bas#L54-L62) | Senha hardcoded para operação destrutiva. Eco do achado de segurança preventiva no doc 65 §6. Aceitável em produção privada, indesejável em repositório público. |

## 3. Validação das regras de negócio

### 3.1 Rodízio, avaliação, suspensão e reativação — coerentes?

**Sim, no caminho automático e no caminho UI de empresa pós-MICRO30; parcial no caminho UI de entidade.**

| Regra V203 | Implementação atual | Coerência |
|---|---|---|
| Rodízio — `SelecionarEmpresa` percorre fila e aplica filtros A-E ([Svc_Rodizio.bas:68-122](../../src/vba/Svc_Rodizio.bas#L68-L122)) | ✅ STATUS_CRED, suspensão (com reativação automática), inativa, OS aberta na atividade, Pre-OS pendente | OK |
| Rodízio — Empresa apta registra indicação sem mover ([Svc_Rodizio.bas:124-138](../../src/vba/Svc_Rodizio.bas#L124-L138)) | ✅ Não move até aceitar/recusar/expirar | OK (Regra V203 #6) |
| Avaliação — Strike registrado quando média < notaCorte ([Svc_Avaliacao.bas:376-403](../../src/vba/Svc_Avaliacao.bas#L376-L403)) | ✅ Usa `ContarStrikesParaPunicao` (Opção B) | OK |
| Avaliação — Suspensão por strikes em dias ([Svc_Avaliacao.bas:394-401](../../src/vba/Svc_Avaliacao.bas#L394-L401) + [Svc_Rodizio.bas:313-322](../../src/vba/Svc_Rodizio.bas#L313-L322)) | ✅ `MAX_STRIKES`, `DIAS_SUSPENSAO_STRIKE` configuráveis | OK, com débito P1-C (falha de Suspender mascarada) |
| Avaliação — Suspensão idempotente ([Svc_Rodizio.bas:302-308](../../src/vba/Svc_Rodizio.bas#L302-L308)) | ✅ Já SUSPENSA → no-op | OK (Regra V203 #4) |
| Reativação automática por timeout ([Svc_Rodizio.bas:85-97](../../src/vba/Svc_Rodizio.bas#L85-L97) → `Reativar` → `ReativarLinhaEmpresa`) | ✅ Grava `DT_ULT_REATIV=Now`, zera recusas, limpa `DT_FIM_SUSP`, registra `EVT_REATIVACAO` | OK |
| Reativação manual UI empresa via `Reativa_Empresa.frm` ([:303-313](../../src/vba/Reativa_Empresa.frm#L303-L313)) | ✅ Move linha + chama `ReativarLinhaEmpresa` (MICRO30) | OK no fluxo de reativação, **mas** P0-B persiste (zera ATIV_ID) |
| Reativação manual UI entidade via `Reativa_Entidade.frm` ([:316-318](../../src/vba/Reativa_Entidade.frm#L316-L318)) | ❌ Cópia direta sem serviço, sem `AUDIT_LOG` | **VIOLAÇÃO** Regra V203 #5 |
| Empresa reativada volta à posição original (Regra V203 #7) | ⚠️ Não há cenário automatizado afirmando que `POSICAO_FILA` é preservada após reativação. `ReativarLinhaEmpresa` toca apenas `EMPRESAS`; `CREDENCIADOS.POSICAO_FILA` permanece. **Coerência implícita por omissão**, não por teste. |
| Posição imutável sem motivo declarado (Regra V203 #6) | ✅ Apenas recusa/conclusão/admin movem fila ([Svc_Rodizio.bas:160-268](../../src/vba/Svc_Rodizio.bas#L160-L268)) | OK |

### 3.2 Cobertura da correção `DT_ULT_REATIV`

| Caminho | Cadastro | Leitura | Reativação | Classificação | Regressão |
|---|---|---|---|---|---|
| Cadastro novo de empresa | ✅ [Repo_Empresa.bas:187](../../src/vba/Repo_Empresa.bas#L187) grava `""` (legado) | ✅ [Repo_Empresa.bas:47-53](../../src/vba/Repo_Empresa.bas#L47-L53) lê e normaliza | n/a | ✅ Classificar até U | ✅ V2 Canônica |
| Reativação automática | n/a | ✅ | ✅ Grava `Now` | ✅ Classificar até U | ✅ E2E Strikes (`CS_REATIV_DT_ULT_REATIV_GRAVADA`) |
| Reativação manual empresa | ✅ | ✅ | ✅ Pós-MICRO30 | ✅ MICRO30-fix1 | ✅ `CS_23` (regressão de classificação) |
| Reativação manual entidade | n/a (entidade não tem coluna) | n/a | n/a | n/a | n/a |
| Empresa legado (sem reativação) | ✅ Coluna vazia | ✅ → `CDate(0)` | n/a | ✅ | ✅ `CS_REATIV_LEGADO_VAZIO` |
| Backfill de empresas com `EVT_REATIVACAO` antigo | ❌ | ❌ | ❌ | ❌ | ❌ Débito formal |
| Empresa com `DT_ULT_REATIV` corrompida (string, erro) | ❌ → silencioso para CDate(0) | ⚠️ | n/a | n/a | ❌ Sem cenário |

**Veredito:** correção da coluna `DT_ULT_REATIV` cobre cadastro,
leitura, reativação automática, reativação manual e classificação
de forma consistente para o domínio empresa. Falta cobertura para
backfill (DT-FRENTE1-BACKFILL-AUDIT) e para dado corrompido (P1-F).

### 3.3 Caminhos de UI que ainda burlam a regra de serviço

| Caminho | Burla? | Detalhe |
|---|---|---|
| `Reativa_Empresa.frm` | ❌ Não burla mais (MICRO30) | Move linha mas chama `ReativarLinhaEmpresa` em seguida |
| `Reativa_Entidade.frm` | ✅ Sim — **P0-A** | Cópia direta + delete sem `AUDIT_LOG` |
| `Configuracao_Inicial.frm` (limpeza, novo período, strikes) | ⚠️ Parcial | Limpeza de PRE_OS/CAD_OS via ranges fixos (doc 56 §5); validação de strikes silenciosa quando inválido |
| `Limpar_Base.frm` | ⚠️ Senha hardcoded; opera via serviço (`Mod_Limpeza_Base.LimpaBaseTotalReset`) | OK arquitetural, débito de segurança |
| `Altera_Empresa.frm` | ⚠️ Inativa diretamente em `EMPRESAS` + `CREDENCIADOS` (doc 56 §5 P2) | Eco do bypass do antigo R1 |
| `Cadastro_Servico.frm` (criar atividade via InputBox) | ⚠️ Validação mínima (CNAE não vazio) | Doc 56 §5 P2 |

### 3.4 Bateria Quinteto suficiente para liberar teste manual?

**Sim para teste manual; insuficiente para produção.** O Quinteto
APROVADO em `VR_20260504_171048` cobre:

- **V1 rápida** (171/0): regressão histórica funcional, incluindo
  `BO_330d_NotaMin_0_Suspende` (regressão L12).
- **V2 Smoke** (27/0): sanity rápido + TV2_RunUiSmokeReadOnly nos
  forms canônicos (Reativa_Empresa, Reativa_Entidade, Cadastro_Servico,
  Credencia_Empresa). MANUAL=4 indica os 4 V5_CANARY (VBE acessível).
- **V2 Canônica** (23/0): inclui `CS_23` (ida/volta empresa
  ativa↔inativa preservando `DT_ULT_REATIV` após classificação),
  bordas (`CS_BORDA_MAX2`, `CS_BORDA_MAX5`, `CS_NOTA_ZERO`).
- **E2E Strikes** (71/0): inclui os 6 cenários novos da Onda 18
  (`CS_REATIV_DT_ULT_REATIV_GRAVADA`,
  `CS_REATIV_HISTORICO_TOTAL_PRESERVADO`,
  `CS_REATIV_JANELA_EXCLUI_HISTORICO`, `CS_E2E_REATIV2STRIKES`,
  `CS_E2E_REATIV3STRIKES`, `CS_REATIV_LEGADO_VAZIO`).
- **IntegridadeBase** (3/0): `CS_INT_01..04` com `MANUAL=1`
  (`INT-CAD-OS-REF-ORFA` exposto, não escondido).

**Lacunas materiais para produção** (ver §6 análise combinatória):
reentrada UI, UI bypass de entidade, mutação ATIV_ID na reativação,
backfill, datas inválidas, comparação numérica de IDs.

### 3.5 Mapas de teste explicam o que é coberto e o que não é?

| Documento | Avaliação |
|---|---|
| [02_MAPA_TESTES_V203_QUINTETO](../../docs/reference/testes/02_MAPA_TESTES_V203_QUINTETO.md) | ✅ Composição + papéis + leitura operacional. ⚠️ Tabela "O que não prova sozinha" é genérica; falta amarrar aos débitos abertos (não cita reentrada, ATIV_ID, backfill). |
| [03_CATALOGO_CENARIOS_V2_V203](../../docs/reference/testes/03_CATALOGO_CENARIOS_V2_V203.md) | ⚠️ Lista famílias e 3 cenários nominais, mas o E2E_Strikes hoje tem 71 asserts em ~12 cenários (`CS_E2E_C/D/E/H2`, `CS_E2E_5EMPS`, `CS_E2E_REATIV2STRIKES`, `CS_E2E_REATIV3STRIKES`, `CS_REATIV_LEGADO_VAZIO`, `CS_REATIV_DT_ULT_REATIV_GRAVADA`, `CS_REATIV_HISTORICO_TOTAL_PRESERVADO`, `CS_REATIV_JANELA_EXCLUI_HISTORICO`, `CS_BORDA_MAX2/MAX5`, `CS_NOTA_ZERO`). O catálogo **não** lista os 23 canônicos nem os 71 asserts. Para V204 deve virar matriz `regra → cenário → asserts → evidência`. |
| [04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V203](../../docs/reference/testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V203.md) | ✅ Identifica cobertura e lacunas (mensagens, reentrada, backfill como débitos V204). ⚠️ Não cita UI bypass entidade, ATIV_ID zerado, datas inválidas — eixos críticos faltantes. |
| [05_ROTEIRO_TESTE_MANUAL_V203_RC4](../../docs/reference/testes/05_ROTEIRO_TESTE_MANUAL_V203_RC4.md) | ✅ Estrutura útil para humano. ⚠️ Lista fluxos genéricos; falta cenário explícito "abrir Reativa_Entidade > duplo clique > confirmar AUDIT_LOG não tem `EVT_REATIVACAO`" e "reativar empresa > olhar credenciamentos > confirmar/contestar zeramento de ATIV_ID". |

## 4. Validação de segurança e Glasswing

| Vetor | Estado |
|---|---|
| **G1** macro descartável | ✅ `local-ai/vba_import/` sem macros descartáveis na raiz |
| **G2** config validada | ⚠️ `Util_Config.GetMaxStrikes`/`GetDiasSuspensaoStrike`/`GetNotaMinimaAvaliacao` validam faixa, mas `Configuracao_Inicial.frm:111-127` ignora silenciosamente entrada inválida sem `EVT_CONFIG_REJEITADA` (P2 do doc 56). Não regressão na rc4 |
| **G3** fórmulas privilegiadas | ✅ Sem introdução nesta rc4 |
| **G4** AUDIT_LOG append-only | ⚠️ Cumprido pelo serviço; **violado pelo `Reativa_Entidade.frm`** (P0-A — não escreve, mas tampouco deveria mudar estado sem registro). `Limpa_Base` continua sendo o único caminho autenticado para limpar |
| **G5** claims sem evidência | ✅ Documentação rc4 (CHANGELOG, fechamento Onda 18) cita `VR_*` como evidência; sem "100% testado" / "zero risco" |
| **G6** código no chat | ✅ Esta auditoria não emite código VBA — apenas referências `path:linha` e tabelas |
| **G7** src ↔ vba_import | ✅ Conforme auditoria 58 (12/12 shasum). Bump `MICRO30 + MICRO30-fix1` espelhado (App_Release coerente) |
| **G8** Public Type isolado | ✅ `TEmpresa.DT_ULT_REATIV` em `Mod_Types.bas` (TABU C4 com plano dedicado da Onda 9 — aprovado em Onda 18 pelo operador) |

**Risco residual de segurança preventiva** (eco do doc 65 §6):

- Senha hardcoded em `Limpar_Base.frm` — combinatória trivial em
  repositório público.
- `_DblClick` sem semáforo — vetor de duplicação massiva por evento
  enfileirado se o handler ficar lento (ex.: planilha grande).
- Transação emulada (`Svc_Transacao` com estado global único, doc 56
  §4) — crash do Excel pode deixar bases em estado parcial.

## 5. Avaliação dos mapas de teste

Detalhamento em §3.5. Resumo:

| Tema | Mapa atual | Lacuna |
|---|---|---|
| O que cobre | OK macro | OK micro insuficiente (não lista todos os 23 + 71 + 27 asserts) |
| O que não cobre | Genérico | Não cita explicitamente: UI bypass entidade, mutação ATIV_ID, reentrada, backfill, dado corrompido, comparação numérica de IDs |
| Como falha | Bem definido (P0-P3) | Falta separar falha de sistema vs falha de dado vs falha de teste (parcialmente apontado no catálogo §"Como evoluir") |
| Como evolui na V204 | Roteiro listado em cada mapa | OK direcional, falta plano executável |

## 6. Análise combinatória de cobertura

Eixos solicitados pelo prompt e estado de cobertura na rc4:

### 6.1 Status × DT_ULT_REATIV × Strikes × Origem × Base × Operador

| Eixo | Valores | Cobertos pelos 71 asserts E2E + 23 canônicos | Lacuna |
|---|---|---|---|
| **Status empresa** | ATIVA | ✅ massivo | — |
| | INATIVA | ✅ `CS_23`, V2 Canônica | — |
| | SUSPENSA | ✅ `CS_E2E_C/D/E_FINAL_SUSP`, `CS_E2E_REATIV3STRIKES` | Transição direta SUSPENSA → INATIVA via UI não testada |
| **DT_ULT_REATIV** | vazia (legado) | ✅ `CS_REATIV_LEGADO_VAZIO` | — |
| | posterior à OS antiga | ✅ `CS_REATIV_JANELA_EXCLUI_HISTORICO`, `CS_E2E_REATIV2STRIKES` | — |
| | igual à OS (mesmo timestamp) | ❌ | **Ambiguidade**: `dtFech > dtCorte` exclui igualdade. OS fechada no instante exato da reativação fica fora da janela |
| | anterior à OS (data backdated) | ❌ | OS pós-reativação com `DT_FECHAMENTO` informada manualmente para data anterior à reativação **não conta** para punição. Doc 56 §6.3 propôs `CS_REATIV_DATA_BACKDATED`; **não implementado** |
| | inválida (string, #ERRO!) | ❌ P1-F | — |
| **Strikes** | 0 | ✅ implícito em V2 Canônica | — |
| | 1 | ✅ `CS_E2E_REATIV2STRIKES` (1 nova pós-reativação) | — |
| | 2 | ⚠️ Implicado em sequência E2E | Sem assert explícito de "2 strikes não suspende" |
| | 3 | ✅ `CS_E2E_C/D/E_FINAL_SUSP`, `CS_E2E_REATIV3STRIKES` | — |
| | 4 (histórico total) | ✅ `CS_REATIV_HISTORICO_TOTAL_PRESERVADO` (>=4) | — |
| **Origem** | Service direto | ✅ V2 Canônica | — |
| | Form (UI) | ⚠️ `CS_23` cobre regressão de classificação após UI | Sem assert direto sobre `Reativa_Empresa.frm` (`MICRO30` validou em compile + Quinteto, mas sem `CS_REATIV_UI_EMPRESA_*` formal). Sem assert para `Reativa_Entidade.frm` |
| | Teste canônico (fixture) | ✅ massivo | — |
| **Base** | Limpa | ✅ massivo (testes V2 montam baseline) | — |
| | Migrada (sem coluna U pré-existente) | ❌ | Schema novo só vê base limpa |
| | Com referência órfã | ✅ `CS_INT_04` (`MANUAL=1`) | OK exposto |
| **Operador** | Clique único | ✅ implícito | — |
| | Duplo clique (reentrada) | ❌ P1-A | Doc 65 §7 propôs `TV2_RunAdversarial_UI`; não implementado |
| | Cancelamento mid-fluxo | ⚠️ | `Svc_Transacao` aninhada quebra (doc 56 §4); sem cenário de crash simulado |

### 6.2 Combinações que faltam para afirmar robustez de produção

1. **UI Reativa_Entidade × AUDIT_LOG** — assert `EVT_REATIVACAO` para
   entidade após duplo clique.
2. **UI Reativa_Empresa × ATIV_ID em CREDENCIADOS** — assert que
   define o contrato de produto (zerar é intencional ou bug).
3. **UI × Reentrada** — assert que segundo `_DblClick` em janela
   <500ms é ignorado ou retorna erro estruturado.
4. **DT_ULT_REATIV inválida** — Type Mismatch handling (P1-F).
5. **OS backdated pós-reativação** — `CS_REATIV_DATA_BACKDATED` da
   spec do doc 56 §6.3.
6. **OS mesmo timestamp da reativação** — borda `dtFech == dtCorte`.
7. **Empresa SUSPENSA + nova nota baixa** — não tenta suspender de
   novo nem quebra `Svc_Transacao` (lacuna do doc 65 §5).
8. **Suspender falha durante AvaliarOS** — propagação do erro como
   falha bloqueante (P1-C).
9. **GravarStatusEmpresa falha durante Suspender** — confirmação
   pós-gravação (P1-B aplicado a Suspender).
10. **Backfill DT_ULT_REATIV via AUDIT_LOG** — empresas previamente
    reativadas via `EVT_REATIVACAO` ganham coluna U preenchida.
11. **Concorrência simulada de duas seleções para a mesma fila** —
    `RegistrarIndicacao` sem AUDIT_LOG (P2 do doc 56 §3).
12. **Comparação de EMP_ID alfanumérico** — P1-E.

## 7. Comparativo V12.0.0202 → V12.0.0203 rc4

| Dimensão | V12.0.0202 | V12.0.0203 rc4 | Delta |
|---|---|---|---|
| Heurística em forms | Presente (`InStr(Caption)`, `ctl.Top/Left` em `Configuracao_Inicial`) | Removida (Onda 5 + 8) | ✅ Regra V203 #3 cumprida |
| Suspensão por strikes | Regra única (1 strike → suspende) | `MAX_STRIKES` configurável (default 3), `DIAS_SUSPENSAO_STRIKE` (default 90 dias) | ✅ Onda 1 reincorporada |
| `DT_ULT_REATIV` | Não existe | Coluna U + `TEmpresa.DT_ULT_REATIV` + dual-counter | ✅ Onda 18 |
| Forms reativação | `Reativa_Empresa` cópia direta (bypass) | `Reativa_Empresa` chama `ReativarLinhaEmpresa` (MICRO30) | ✅ R1 fechado para empresa |
| Forms reativação entidade | `Reativa_Entidade` cópia direta | Mesmo (sem fix simétrico) | ❌ Bypass residual |
| Gate de release | Trio Mínimo (V1+V2_Smoke+V2_Canonica) | Quinteto Mínimo (+E2E_Strikes +IntegridadeBase) | ✅ Onda 17 |
| Cobertura E2E_Strikes | Inexistente como gate | 71 asserts | ✅ |
| Cobertura V2_Smoke | 14/0 | 27/0 (+UI smoke read-only) | ✅ |
| `RPT_BUGS_CONHECIDOS` | Inexistente | 4 cenários CS_INT_01..04 + upsert por BUG_ID | ✅ |
| `RPT_BUGS_RESOLVIDOS` | Inexistente | DT-17 movido formalmente | ✅ |
| `AUDIT_LOG` cobre toda ação | Parcial (forms bypass) | Quase total — entidade ainda fora | ⚠️ |
| Espelho src ↔ vba_import (M11) | Variável (drift residual D1) | 12/12 nos módulos auditados | ✅ |
| Senha hardcoded em Limpar_Base | Presente | Presente | — Débito V204 |
| `GravarStatusEmpresa` retornável | Sub silenciosa | Sub silenciosa | — Débito V204 |
| Documentação Diataxis + AGENTS.md + HBN + Glasswing | Parcial | Consolidada (Onda 6) | ✅ |

**Síntese:** rc4 corrige todos os P0 originais do doc 57 (D3-D5),
fecha o R1 da auditoria cruzada para o domínio empresa, materializa
o gate Quinteto e mantém o espelho M11 íntegro. Os débitos
remanescentes são ortogonais ao núcleo do contrato de strikes/
reativação — vivem na camada UI e na qualidade de propagação de
erro.

## 8. Débitos que devem entrar na V12.0.0204

| ID | Origem | Severidade | Local | Bloqueia V204 final? |
|---|---|---|---|---|
| `DT-FRENTE1-FORMS-BYPASS-REATIV-ENTIDADE` (novo) | P0-A | P0 | `Reativa_Entidade.frm:240-355` | ✅ Sim |
| `DT-FRENTE1-REATIVA-EMPRESA-MUTA-ATIV-ID` (novo) | P0-B | P0 (decisão de produto) | `Reativa_Empresa.frm:339-352` | ✅ Sim — exige decisão |
| `DT-FRENTE1-FORMS-REENTRANCIA` (novo) | P1-A | P1 | `Reativa_*.frm`, `Limpar_Base.frm`, `Menu_Principal.frm` | ✅ Sim |
| `DT-FRENTE1-GRAVARSTATUSEMPRESA-SILENT` (já aberto) | P1-B | P1 | `Repo_Empresa.bas:64-100` | ✅ Sim |
| `DT-FRENTE1-AVALIAR-OS-FALHA-NAO-PROPAGADA` (novo) | P1-C | P1 | `Svc_Avaliacao.bas:394-418` | ✅ Sim |
| `DT-FRENTE1-CONTARSTRIKES-ERRO-MUDO` (já aberto) | P1-D | P1 | `Repo_Avaliacao.bas:170-172, 236-237` | ✅ Sim |
| `DT-FRENTE1-LEREMP-DT-INVALIDA-SILENT` (novo) | P1-F | P1 | `Repo_Empresa.bas:39-53` | ✅ Sim |
| `DT-FRENTE1-REATIVA-EMP-ID-COMPARACAO-NUM` (novo) | P1-E | P1 | `Reativa_Empresa.frm:343-348` | ⚠️ Bloqueia se houver IDs alfanuméricos |
| `DT-FRENTE1-REATIV-NOOP-ATIVA` (já aberto) | doc 58 R3 | P2 | `Svc_Rodizio.bas:354-378` | ❌ Não |
| `DT-FRENTE1-BACKFILL-AUDIT` (já aberto) | doc 58 R7 | P2 | `Auto_Open.bas` (proposta V204) | ❌ Não — comportamento esperado da Opção B |
| `DT-FRENTE1-EVT-AVALIACAO-DUAL-COUNTER` (novo) | P2-B | P2 | `Svc_Avaliacao.bas:386-392` | ❌ Não |
| `DT-FRENTE1-LIMPAR-BASE-SENHA-HARDCODED` (novo) | P2-D + doc 65 §6 | P2 (segurança) | `Limpar_Base.frm`, `Mod_Limpeza_Base.bas` | ✅ Bloqueia se rc4 → push GitHub público |
| `DT-FRENTE1-CONFIG-INICIAL-VALIDACAO-SILENT` (novo) | doc 56 §5 P1 | P2 | `Configuracao_Inicial.frm:111-127` | ❌ Não |
| `DT-FRENTE1-CLASSIFICAR-RANGE-HARDCODED` (novo) | P2-C | P2 | `Classificar.bas:29-52` | ❌ Não |
| `INT-CAD-OS-REF-ORFA` (já aberto, pré-rc3) | `RPT_BUGS_CONHECIDOS` | P2 | dado, não código | ⚠️ Bloqueia se for fechar a release com base operacional real |

## 9. Proposta detalhada de ondas V12.0.0204

> Sequência otimizada para reduzir blast radius: forms primeiro
> (debits tactical), depois transactional integrity (debits
> structural), depois dados/cobertura, depois segurança/Mod_Types,
> depois fechamento. Cada onda fecha com Quinteto verde + bump rc.

### Onda 19 — Camada UI sem heurística e sem bypass

**Tema:** Refactor cirúrgico de forms destrutivos/mutadores para
remover bypasses, reentrada e mutação cruzada.

| MD | Entrega |
|---|---|
| MD-19.1 | `Reativa_Entidade.frm` chama serviço novo `Svc_Entidade.Reativar` (criar) com `EVT_REATIVACAO` em `AUDIT_LOG`. Espelhar contrato de `ReativarLinhaEmpresa`: pré-condições, gravação, asserts pós-gravação |
| MD-19.2 | Decisão de produto formalizada para `Reativa_Empresa.frm:341-352` (zerar ATIV_ID): se intencional, mover lógica para serviço com `EVT_TRANSACAO`; se bug, remover. Documentar em `auditoria/01_regras_e_governanca/` |
| MD-19.3 | Guard de reentrada (`bIsProcessing As Boolean` + `Application.Cursor=xlWait`) em `Reativa_Empresa.frm`, `Reativa_Entidade.frm`, `Altera_Empresa.frm`, `Limpar_Base.frm`, `Menu_Principal.EncerraOS_Click`, `Menu_Principal.B_*_Click` destrutivos. Pattern centralizado em helper `Util_UI_BeginAction/EndAction` |
| MD-19.4 | Comparação de EMP_ID em `Reativa_Empresa.frm:343-348` migrada para `IdsIguais` (via `Util_Planilha`) — substituir `CLng(Val("0" & ...))` |
| MD-19.5 | Cenários novos em `Teste_V2_Roteiros.bas`: `CS_REATIV_UI_EMPRESA_AUDIT`, `CS_REATIV_UI_ENTIDADE_AUDIT`, `CS_REATIV_UI_REENTRADA`, `CS_REATIV_UI_ATIV_ID_DECISAO`. E2E sobe de 71 para ~80 asserts |

**Gate Onda 19:** Quinteto Mínimo verde + 4 cenários novos verdes
+ `MANUAL=0` em V2 Smoke UI sobre os 4 forms.

### Onda 20 — Integridade transacional e propagação de erro

**Tema:** Eliminar `sucesso=True` mascarado e fluxos parciais.

| MD | Entrega |
|---|---|
| MD-20.1 | `Repo_Empresa.GravarStatusEmpresa` vira `Public Function` com `TResult` — chamadores propagam e auditam falha |
| MD-20.2 | `Svc_Avaliacao.AvaliarOS` propaga falha de `Suspender` e `AvancarFila` como falha bloqueante (não AVISO) ou trata como aviso explicitamente flagged em `TResult.observacoes` |
| MD-20.3 | `Svc_PreOS.RecusarPreOS`/`ExpirarPreOS` envolvem avanço + status em transação compensável (`Svc_Transacao`) |
| MD-20.4 | `Svc_OS.EmitirOS` valida escrita de `PRE_OS` antes de inserir OS; rollback OS em falha de avanço |
| MD-20.5 | `Svc_Transacao` impede aninhamento — falha explícita ao iniciar transação dentro de outra |
| MD-20.6 | `Repo_Avaliacao.ContarStrikesPorEmpresa` e `ContarStrikesParaPunicao` substituem retorno-0-em-erro por `TStrikesResult` (qtd + sucesso). Em erro, `Svc_Avaliacao` registra `EVT_AVALIACAO_FALHA_CONTAGEM` e bloqueia decisão punitiva |
| MD-20.7 | `Repo_Empresa.LerEmpresa` registra `EVT_DADO_INVALIDO` quando `DT_ULT_REATIV` é não-data não-vazia |

**Gate Onda 20:** Quinteto verde + 6 cenários transacionais novos
(incluindo `CS_REATIV_DATA_INVALIDA`, `CS_AVALIAR_SUSPENDER_FALHA`,
`CS_PREOS_RECUSA_TRANS`, `CS_OS_EMITIR_ROLLBACK`).

### Onda 21 — Dados legados e backfill

**Tema:** Resolver `DT-FRENTE1-BACKFILL-AUDIT` e `INT-CAD-OS-REF-ORFA`.

| MD | Entrega |
|---|---|
| MD-21.1 | Helper `Backfill_DT_ULT_REATIV_From_AUDIT_LOG` em `Mod_Limpeza_Base` (varre `AUDIT_LOG` por `EVT_REATIVACAO`, preenche coluna U onde vazia, registra `EVT_BACKFILL`) |
| MD-21.2 | `Auto_Open.bas` instrumentado: detecta empresas em modo legado com `EVT_REATIVACAO` antigo e propõe backfill ao operador (não automático) |
| MD-21.3 | Cenário `CS_BACKFILL_REATIV_FROM_AUDIT` em E2E_Strikes |
| MD-21.4 | Resolução de `INT-CAD-OS-REF-ORFA`: cenário de migração que ofereça relatório de divergências + remoção controlada via `Limpa_Base` extendida |
| MD-21.5 | Cenários de borda de data: `CS_REATIV_DATA_BACKDATED`, `CS_REATIV_DT_IGUAL`, `CS_REATIV_DT_FUTURA_INVALIDA` |

**Gate Onda 21:** Quinteto verde + IntegridadeBase = `OK=4 / FALHA=0
/ MANUAL=0` (INT-CAD-OS-REF-ORFA fechado).

### Onda 22 — Cobertura combinatória adversarial

**Tema:** Implementar suítes adversariais propostas no doc 65 §7.

| MD | Entrega |
|---|---|
| MD-22.1 | `TV2_RunAdversarial_UI` — disparo programático de `_Click`/`_DblClick` repetidos validando guard MD-19.3 |
| MD-22.2 | `TV2_RunBoundary_Dates` — bordas de `DT_ULT_REATIV` (vazia, igual, anterior, posterior, ano bissexto, futura corrompida, string) |
| MD-22.3 | `TV2_RunTransaction_Interrupt` — força falha mid-transação em `Svc_PreOS`/`Svc_OS`/`Svc_Avaliacao`, valida rollback |
| MD-22.4 | Matriz combinatória explícita de 6 eixos do prompt 64 — pelo menos 1 cenário por célula relevante |
| MD-22.5 | Catálogo de cenários (doc 03) reescrito com matriz `regra → cenário → asserts → evidência` |

**Gate Onda 22:** Sexteto Mínimo (Quinteto + Adversarial), com bump
de teste-key.

### Onda 23 — Segurança preventiva e Mod_Types Onda 9 finalizada

**Tema:** Endurecer Glasswing G2/G4 e fechar tabu C4.

| MD | Entrega |
|---|---|
| MD-23.1 | Senha de `Limpar_Base.frm` derivada de hash dinâmico ou removida do source (env var / arquivo fora do git) |
| MD-23.2 | `Configuracao_Inicial.frm` valida campos com mensagem por campo + registra `EVT_CONFIG_REJEITADA` |
| MD-23.3 | `RegistrarIndicacao` em `Svc_Rodizio` registra `EVT_TRANSACAO` (`SelecionarEmpresa` deixa de ser nome neutro com side-effect oculto) |
| MD-23.4 | `Svc_Rodizio.Reativar` em empresa já ATIVA — política explícita (rejeitar com `EVT_VALIDACAO_REJEITADA` ou no-op auditado) |
| MD-23.5 | Auditoria final de `Mod_Types.bas` — fechar Onda 9 plena com plano dedicado, alinhado com a alteração da Onda 18 (DT_ULT_REATIV em TEmpresa) |

**Gate Onda 23:** Sexteto verde + `bash local-ai/scripts/glasswing-checks.sh
--strict` retorna OK em todos os 8 vetores.

### Onda 24 — Fechamento V12.0.0204 + push GitHub

**Tema:** Promoção formal e tag pública.

| MD | Entrega |
|---|---|
| MD-24.1 | Documentação atualizada (CHANGELOG, AGENTS.md, llms.txt, obsidian-vault) refletindo V12.0.0204 estável |
| MD-24.2 | `App_Release.APP_RELEASE_ATUAL` promove de `V12.0.0202` para `V12.0.0204` (skip `V12.0.0203` por nunca ter saído do RELEASE_CANDIDATE) |
| MD-24.3 | Tag git `v12.0.0204` + push para `main` + release notes em `obsidian-vault/releases/` |
| MD-24.4 | Atualização de `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` com lições destiladas das Ondas 19-23 (candidatas: L28-L35, M18-M22) |

**Gate Onda 24:** Sexteto verde + Glasswing-strict OK + auditoria
cruzada Opus + Antigravity sem P0 nem P1 + decisão explícita do
operador para promover `V12.0.0202` → `V12.0.0204`.

### Sumário das ondas

| Onda | Tema | Bloqueia V204 final? |
|---|---|---|
| 19 | UI sem bypass + reentrada | ✅ |
| 20 | Integridade transacional | ✅ |
| 21 | Dados legados (backfill) | ✅ |
| 22 | Cobertura adversarial | ✅ |
| 23 | Segurança preventiva + Mod_Types Onda 9 plena | ✅ |
| 24 | Fechamento + push GitHub | ✅ (release final) |

## 10. Markers HBN finais

- ✅ **HBN ACTIVE** — auditoria executada em modo read-only; nenhum
  arquivo em `src/vba/` ou `local-ai/vba_import/` tocado.
- 🟢 **HBN CHECKPOINT CLEAN** — Quinteto `VR_20260504_171048` APROVADO,
  espelho M11 íntegro, R1 da auditoria 58 fechado em código, dual-counter
  consistente.
- 🟣 **HBN PEER REVIEW** — auditoria Opus 4.7 entregue como contraparte
  da auditoria Antigravity 65; convergência forte em P0-A (forms bypass),
  P0-B (decisão de produto), P1 (reentrada, GravarStatusEmpresa,
  ContarStrikes silente).
- ⚪ **HBN AUDIT-ONLY** — Opus 4.7 manteve modo auditor; sem edits em
  código de produção; somente este documento e leituras.
- 🟡 **HBN NEEDS HUMAN DECISION** — duas decisões críticas pendentes:
  (a) zerar `COL_CRED_ATIV_ID` na reativação de empresa é
  comportamento de produto ou bug? (P0-B); (b) tagueamento formal de
  `v12.0.0203-rc4` no GitHub privado/público antes de Onda 19, e
  nomeação da próxima release (`V12.0.0204` skipping `V12.0.0203`
  estável, ou promoção tardia da V203 após Onda 19-23).
- 🔵 **HBN HANDOFF READY** — pacote rc4 pronto para teste manual
  formal humano segundo
  [05_ROTEIRO_TESTE_MANUAL_V203_RC4](../../docs/reference/testes/05_ROTEIRO_TESTE_MANUAL_V203_RC4.md);
  registro deste documento devolve insumo para o operador decidir
  abertura formal da V12.0.0204.
- 🟤 **HBN LICENSE SPLIT REQUIRED** — TPGL Credenciamento; lições
  candidatas L28-L35 + M18-M22 das Ondas 19-23 deverão ser revisadas
  para promoção AGPLv3 antes do push GitHub público (Onda 24).
- 🟠 **HBN SOURCE DRIFT** — Nenhum drift novo detectado entre `src/vba/`
  e `local-ai/vba_import/` na rc4; herdado o resíduo D1 documentado em
  `auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md`
  (não regrediu).
- 🔴 **HBN RELEASE BLOCKER** — promoção a `v12.0.0203` final ou
  `V12.0.0204` final exige fechamento dos 7 P0/P1 listados em §8.

## 11. Documentos relacionados

- [56 — QA Codex](56_QA_CODEX_2026_05_04.md)
- [58 — Auditoria final Opus Bloco B](58_AUDITORIA_OPUS_FINAL_BLOCO_B_2026_05_04.md)
- [59 — Auditoria final Antigravity Bloco B](59_AUDITORIA_ANTIGRAVITY_FINAL_BLOCO_B_2026_05_04.md)
- [65 — Auditoria Antigravity V203 rc4 e V204](65_AUDITORIA_ANTIGRAVITY_V203_RC4_E_V204_2026_05_04.md)
- [Fechamento Onda 17](../03_ondas/onda_17_test_first/70_FECHAMENTO_ONDA_17.md)
- [Fechamento Onda 18](../03_ondas/onda_18_reativ_strikes/70_FECHAMENTO_ONDA_18.md)
- [Mapa de Testes V203 Quinteto](../../docs/reference/testes/02_MAPA_TESTES_V203_QUINTETO.md)
- [Catalogo de Cenarios V2 V203](../../docs/reference/testes/03_CATALOGO_CENARIOS_V2_V203.md)
- [Matriz de Cobertura V203](../../docs/reference/testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V203.md)
- [Roteiro de Teste Manual V203 rc4](../../docs/reference/testes/05_ROTEIRO_TESTE_MANUAL_V203_RC4.md)
- [CSV Quinteto VR_20260504_171048](../evidencias/V12.0.0203/ValidacaoReleaseQuinteto_V12_0_0203_VR_20260504_171048.csv)
- [Regras V203 Inegociaveis](../../.hbn/knowledge/0001-regras-v203-inegociaveis.md)
- [Regra de Ouro VBA Import](../../.hbn/knowledge/0002-regra-ouro-vba-import.md)
- [Glasswing Preventive Security](../../.hbn/knowledge/0003-glasswing-style-preventive-security.md)

## 12. Versão

- v1.0 — 2026-05-04 — Opus 4.7 (Cowork) entrega auditoria cruzada
  final da `v12.0.0203-rc4` e proposta detalhada da V12.0.0204
  (Ondas 19-24). Veredito **APROVADO_PARA_TESTE_MANUAL**, com 2 P0
  e 6 P1 a resolver antes de promoção a release final pública.
