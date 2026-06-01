---
titulo: Análise consolidada — auditoria cruzada Codex + Antigravity (integridade referencial + idempotência V206)
data: 2026-05-27
predecessor: 116_PROMPT_RETOMADA_SESSAO_OPUS.md
input-a: .hbn/proposals/0009-codex-auditoria-integridade-idempotencia-v206.md (24KB)
input-b: .hbn/proposals/0010-antigravity-auditoria-integridade-idempotencia-v206.md (16KB)
sucessor-esperado: hearback Mauricio com decisão A/B/C → readback 0112-rb-onda-38-2-3-<escopo>
hbn-track: fast_track (doc-only análise)
audiencia: ambos
versao-sistema: V12.0.0206
---

# Análise consolidada — auditoria cruzada integridade referencial + idempotência

## 0. Síntese executiva

As duas auditorias **convergem em 80% do diagnóstico** e propõem o mesmo plano em 4 camadas (helpers escrita → leitura → auditoria contínua → migração legado). **Divergem na causa de F-NEW5 (STATUS_CRED vazio)** e na **ordem das ondas** — divergência substantiva, não cosmética.

**F-NEW6 (mismatch Long↔String em IDs) — VALIDADO como causa raiz de V2_E2E_STRIKES `DIAG_PREOS_INTEGRITY`** e como anti-padrão sistêmico real. **NÃO foi provado** como causa de F-NEW5 — Antigravity hipotetiza cascata, Codex pede diagnóstico empírico primeiro. Opus alinha com Codex aqui.

**Recomendação Opus para a decisão A/B/C de Mauricio**: **Hipótese C (híbrida)** — preservar a fonte VBA da Onda 38.2.2 no git, mas refresh do workbook XLSM via re-import em 2 fases (L41), diagnóstico empírico F-NEW5 ANTES de tocar helpers transversais, correção pontual `Svc_PreOS`/`Repo_PreOS` com **exceção mínima ao tabu Svc_*** documentada por hearback.

**Escopo proposto Onda 38.2.3**: AT-1 (re-sync drift) + AT-2 (diagnóstico F-NEW5) + AT-3 (fix pontual V2_E2E_STRIKES com exceção tabu) + AT-4 (re-import 2 fases L41) + AT-5 (GATE-USO-PROLONGADO L43). **Camadas 1-4 (helpers, hidratação, auditoria, migração) ficam para 38.2.4 e 38.2.5** — não comprimir tudo na 38.2.3.

---

## 1. Convergências Codex × Antigravity

10 pontos onde ambas chegam à mesma conclusão por caminhos diferentes:

1. **F-NEW6 procede como hipótese central para `DIAG_PREOS_INTEGRITY`**. Causa direta: `Svc_PreOS.EmitirPreOS:189-205` grava `PRE_OS` sem `NumberFormat = "@"` e `Repo_PreOS.BuscarPorId:78-83` hidrata com `CStr` puro. Mesmo padrão repete-se em `Repo_OS`, `Svc_OS`, `Repo_Avaliacao`.

2. **V2_SMOKE drift `Cadastro_Servico.frm` é trivial**. Fix: rodar `bash local-ai/scripts/publicar_vba_import_v2.sh --apply` ANTES de qualquer outra ação. Causa raiz: hotfixes consecutivos editaram `.frm` sem sincronizar `.code-only.txt`. Quebra de disciplina M9/L22-L24.

3. **Plano em 4 camadas idêntico**:
   - C1 — `Util_Planilha.GravarIdTextual(ws, linha, coluna, idValue)` aplica `NumberFormat="@"` + `Pad3` em ponto único
   - C2 — `Util_Planilha.LerIdTextual(ws, linha, coluna) As String` substitui `CStr(...).Value` nos Repos
   - C3 — Macro `AuditarIntegridadeReferencial` rodada antes de freeze, com CSV; falha = bloqueio
   - C4 — Macro descartável `Util_Migrar_IDS_Workbook` para corrigir células já gravadas como Long no workbook em uso

4. **Anti-padrão "dispersão de `NumberFormat = "@"`"** identificado por ambas como problema estrutural. Aplicação ad-hoc em handlers de UI + algumas rotinas de repos = vulnerabilidade a esquecimento de desenvolvedor.

5. **Anti-padrão "CStr puro na hidratação"** — confiança cega de que célula manteve tipo textual. Ambas as auditorias indicam todos os pontos: `Repo_Empresa.LerEmpresa:26`, `Repo_Credenciamento.LerCredenciamento:392-395`, `Repo_PreOS.BuscarPorId:78-83`, `RepoOS_BuscarPorId:79-92`, `Svc_OS.LerPreOSCompleto:431-439`.

6. **Anti-padrão "IdsIguais duplicada localmente"** — funções privadas em `Menu_Principal.frm:3035`, `Preencher.bas:1564`, `Credencia_Empresa.frm:388` (`IdsIguaisCred`). Drift risk: mesmo que corretas hoje, podem divergir do contrato central amanhã.

7. **Idempotência crítica nos serviços `Svc_*`**: ambas classificam como NÃO idempotentes (`Svc_PreOS.EmitirPreOS`, `Svc_OS.EmitirOS`, `Svc_Avaliacao.RegistrarAvaliacao`, `Svc_Rodizio.AvancarFila`). Repetição produz duplicação de linhas + avanço incorreto de fila + strikes/contadores cumulativos.

8. **Operações idempotentes confirmadas**: `Util_Sanear_Contadores.SanearContadoresAR1` (guarda monotônica), `IniciarSistema` (inicialização protegida), `Svc_Rodizio.SelecionarEmpresa` (Antigravity classifica Nula; Codex considera "Não" pelo lado de reativação/movimento de fila — vide §2.3).

9. **`Svc_PreOS` e `Svc_OS` precisam tocar pontos de escrita para corrigir a raiz**. Ambas as auditorias destacam que o tabu Svc_* (mantido pela diretiva V206) bloqueia correção limpa — exigirá exceção mínima documentada ou aceite de mitigação parcial.

10. **Fixtures (Teste_V2_Engine, Teste_Bateria_Oficial) gravam IDs sem `NumberFormat="@"` e sem `Pad3`**. Mesma classe de erro do código de produção. Débito V207 mas afeta o workbook de teste — ambas concordam que isso explica por que o dump pós-V1 mostra `ATIV_ID=999/Double` (fixture E2E Strikes) lado a lado com `EMP_ID=001/String` (caminho UI corrigido).

---

## 2. Divergências reais (não cosméticas)

### 2.1 Causa de F-NEW5 (STATUS_CRED vazio para credenciamento manual novo) — DIVERGÊNCIA CENTRAL

**Antigravity (§1.1)**: F-NEW6 explica F-NEW5 via **efeito cascata**. Argumento: se `ATIV_ID` foi gravado como Long `5` em vez de String `"005"`, comparações fora de `IdsIguais` falham silenciosamente; o "status vazio no relatório é sintoma secundário de colunas deslocadas ou erro silencioso de parsing durante o reload da ListBox".

**Codex (§2.3 + §10)**: discorda. Argumento: `STATUS_CRED` é coluna de **estado textual**, não ID; é preenchida explicitamente com literal `STATUS_CRED_ATIVO` em `Credencia_Empresa.frm:178` antes da confirmação de sucesso; nenhuma rotina em `src/vba/` zera essa coluna. F-NEW6 explicaria mismatch `001` vs `1`, **não** célula vazia. Hipóteses alternativas legítimas:
- workbook executou código diferente do `.frm` auditado por drift de importação
- linha observada no relatório não é a mesma linha gravada pelo clique (ordenação/filtro/reload)
- erro/rollback parcial não capturado entre escrita de colunas e exibição
- artefato fora de `src/vba/` ou estado do workbook alterando a coluna

**Síntese Opus**: **Codex tem razão técnica aqui**. O dump empírico `DUMP_CRED_DIAG` da sessão predecessora mostra `STATUS=ATIVO/String` em todas as linhas existentes — e o relatório que Mauricio viu mostrava vazio para linhas que V1 depois limpou. **Não temos prova empírica direta da gravação stale**. Antigravity hipotetiza cascata sem reproduzi-la; Codex pede diagnóstico empírico primeiro. **A Onda 38.2.3 deve incluir macro DUMP imediatamente pós-`CR_Credenciar_Click`** para capturar tipos+valores+formatos antes de qualquer tela de reload. Sem isso, atribuir F-NEW5 a F-NEW6 é especulação.

### 2.2 Ordem das ondas — DIVERGÊNCIA TÁTICA

**Codex (§8)**:
1. 38.2.3-A — diagnóstico F-NEW5 no workbook real + ressync `Cadastro_Servico.frm` (NÃO refatorar IDs antes de saber a causa do status vazio)
2. 38.2.3-B — corrigir `DIAG_PREOS_INTEGRITY` com menor superfície (somente `PRE_OS`/`CAD_OS` + hidratação)
3. 38.2.4 — sistematizar helpers (C1+C2) nos Repos
4. 38.2.5 — auditoria + migração

**Antigravity (§7)**:
1. 38.2.2-reapply — `--apply` para drift (trivial)
2. 38.2.3 — F-NEW5 + Camada 1 (escrita) + Camada 4 (migração legado) **JUNTOS**
3. 38.2.4 — F-NEW6 + Camada 2 (hidratação)
4. 38.2.5 — Auditoria + Fixtures + RVS Verde

**Síntese Opus**: **Codex tem razão na ordem**. Antigravity comprime correção de F-NEW5 + helpers C1 + migração de dados legados em uma única onda — isso (a) presume F-NEW5 explicada por F-NEW6 (não está), (b) acopla refatoração transversal a um bug ainda não diagnosticado, (c) introduz simultaneamente helper novo + reescrita de dados — duas fontes de risco ao mesmo tempo. **Diagnóstico empírico de F-NEW5 ANTES de tocar helpers transversais.**

### 2.3 Severidade e classificação de idempotência

Calibração diferente, não divergência técnica:
- **Codex** usa escala "Alta/Média/Baixa" com nuance — ex.: `Repo_Empresa.Atualizar` é "Parcial" porque `DT_ULT_ALT = Now` muda em repetição; `Svc_Rodizio.SelecionarEmpresa` é "Alta" porque pode reativar suspensão e mover fila.
- **Antigravity** usa escala "Crítica/Média/Nula" mais grosseira — classifica `Repo_Empresa.Atualizar` como "Nula" (sobrescreve mesma linha) e `Svc_Rodizio.SelecionarEmpresa` também "Nula".

**Síntese Opus**: **Codex é mais rigoroso**. Idempotência estrita exige estado físico idêntico, incluindo timestamps de auditoria e movimentos de fila. Para freeze V206, **adotar classificação Codex** — é a única que detectaria regressões reais em testes de idempotência. Antigravity vê "estado funcional" (qual o resultado de negócio), o que é insuficiente para gates técnicos.

### 2.4 Inclusão de `AVALIACOES` como aba separada

**Antigravity (§5 invariante 6)** trata `AVALIACOES.OS_REF` como invariante separada. **Codex (§3 nota)** corrige: "Não encontrei aba/constantes `AVALIACOES` no mapeamento vigente. Avaliações persistem em `CAD_OS` via `Repo_Avaliacao.Inserir`".

**Síntese Opus**: **Codex está correto factualmente**. `Repo_Avaliacao.bas:31-79` grava em `CAD_OS`, não em aba separada. Antigravity falou em abstração de modelo (faz sentido como invariante lógica), mas no código real essa coluna não existe — a invariante real é "OS avaliada deve existir em CAD_OS e estar em estado avaliável". Manter a invariante de Antigravity como **invariante lógica**, mas implementar via colunas de `CAD_OS`.

---

## 3. F-NEW6 — validado, refutado ou refinado?

**REFINADO**, com 3 escopos distintos:

### 3.1 F-NEW6 como causa raiz de V2_E2E_STRIKES `DIAG_PREOS_INTEGRITY` — **VALIDADO**

Evidência convergente: `Svc_PreOS.EmitirPreOS:189-205` grava sem `NumberFormat = "@"` + `Repo_PreOS.BuscarPorId:78-83` hidrata com `CStr` puro + `Teste_V2_Roteiros.bas:3714` compara `pre.EMP_ID = empPresel` por igualdade direta. Ambas as auditorias reproduzem o caminho. Excel converte `"001"` em Long `1`, hidratação devolve `"1"`, comparação string falha. **Causa raiz comprovada.**

### 3.2 F-NEW6 como anti-padrão sistêmico (Repos PreOS/OS/Avaliacao + Credenciamento) — **VALIDADO**

Mapa do Codex §3 + Antigravity §1.3 demonstram que o padrão "gravar ID sem `NumberFormat="@"` + ler com `CStr` puro" repete-se transversalmente:
- `Repo_PreOS.Inserir:28-41` — sem format
- `Repo_OS.Inserir:27-42` — sem format
- `Svc_OS.EmitirOS` preenche `COL_PREOS_OS_ID` em `Svc_OS.bas:171-173` — sem format
- `Repo_Credenciamento.LerCredenciamento:392-395` — `CStr` puro para CRED_ID/EMP_ID/ATIV_ID/COD_ATIV_SERV
- `RepoOS_BuscarPorId:79-92` — `CStr` puro

Mesmo que o workbook atual aparente funcionar nessas linhas (porque seeds vieram textuais), qualquer dado novo está sujeito ao mismatch. **Anti-padrão real.**

### 3.3 F-NEW6 como causa de F-NEW5 (STATUS_CRED vazio) — **NÃO PROVADO**

Antigravity hipotetiza cascata (ATIV_ID Long → ListBox parsing → relatório mostra vazio). Codex contesta (STATUS_CRED é estado textual literal, gravação explícita em linha 178). **Sem reprodução com dump pós-clique, atribuir F-NEW5 a F-NEW6 é especulação não-testada.**

Conclusão Opus: **incluir AT-2 de diagnóstico empírico na Onda 38.2.3** (macro `DUMP_POS_CR_CLICK`) para fechar essa lacuna antes de pleitar correção transversal.

---

## 4. Decisão arquitetural Caminho A vs B vs C

### 4.1 Hipóteses recapituladas

- **Hipótese A** — seguir com o workbook atual (38.2.2-V206-FREEZE reaberto após corrupção)
- **Hipótese B** — rollback git para anchor FIX2-PERF (`ee75b30`) + re-aplicar Onda 38.2.2 inteira
- **Hipótese C (Opus)** — preservar git mas refresh do workbook XLSM via re-import L41 (2 fases) + diagnóstico + correção pontual

### 4.2 Análise das auditorias frente à decisão

Nenhuma das duas auditorias recomenda explicitamente rollback. Codex §8 propõe diretamente 38.2.3-A em cima do código atual. Antigravity §7 propõe 38.2.2-reapply (drift) em cima do código atual. **Implicação: a fonte VBA da Onda 38.2.2 está sólida — o problema é (a) drift de espelho, (b) anti-padrão sistêmico F-NEW6 nos Repos não tocados, (c) workbook XLSM instável.**

### 4.3 Argumentos contra Hipótese B (rollback FIX2-PERF)

- Perde 5 hotfixes + AT-1..AT-5 que ambas as auditorias validam como corretos (escrita textual em UI Cadastros)
- Reabre `Repo_Empresa.Inserir` ao mesmo bug que AT-3 corrigiu na 38.2.2 (hotfix 5)
- Não resolve F-NEW6 sistêmico — Repos PreOS/OS/Avaliacao continuam com a mesma classe de bug
- A 38.2.2-reapply seria necessária novamente, refazendo o mesmo trabalho

### 4.4 Argumentos contra Hipótese A pura

- Workbook reaberto continua sendo a mesma cópia (mesma versão `a51b191+ONDA38.2.2-V206-FREEZE`); pode conter bytes residuais da corrupção
- L41 das protocol-evolutions sugere que workbook multi-hotfix > 5 módulos é frágil — atual está nessa zona
- Sem re-import limpo, não temos certeza de que o XLSM que vamos testar é o mesmo XLSM que corrompeu

### 4.5 Recomendação Opus: Hipótese C

**Híbrida**:
1. **Git preservado** em HEAD `8fbdf26` (não rollback). Branch `codex/v12-0-0206-planejamento` permanece.
2. **Workbook XLSM refreshed**: Mauricio executa o procedimento abaixo no início da 38.2.3:
   - (a) abrir cópia pré-Onda 38.2.2 (anchor FIX2-PERF `ee75b30`, que tinha RVS Trio APROVADO)
   - (b) executar `bash local-ai/scripts/publicar_vba_import_v2.sh --apply` para resolver drift V2_SMOKE
   - (c) **re-import da Onda 38.2.2 em 2 fases (L41)**: primeiro só os 3 `.bas` (Repo_Empresa, Audit_Log, módulos auxiliares), RVS Trio; depois os 5 `.frm` (forms), RVS Trio novamente
   - (d) **GATE-USO-PROLONGADO (L43)**: 30 min de uso operacional pré-RVS Trio final
3. **Apenas se (3.c+3.d) verde**, prosseguir com AT-2..AT-5 da 38.2.3.
4. **Aceitar a oferta de Mauricio** de exportar forms+módulos do workbook ATUAL para `local-ai/incoming/` ANTES de descartá-lo → `diff` byte-a-byte vs `src/vba/` para confirmar/refutar drift suspeito e validar que não há código órfão no workbook em uso.

**Por que C é superior a A**: aplica diretamente L41 (workbook multi-hotfix frágil) e L43 (GATE-USO-PROLONGADO) das protocol-evolutions desta mesma onda — usar essas lições é o sentido delas existirem.

**Por que C é superior a B**: preserva o trabalho 38.2.2 validado pelas duas auditorias; evita re-trabalho desnecessário; o "reset" acontece no workbook (artefato), não no git (verdade).

---

## 5. Escopo proposto Onda 38.2.3 — pré-confirmação Mauricio

Pressuposto: Hipótese C aprovada por hearback.

### AT-1 — re-sync drift `Cadastro_Servico.frm` ↔ `.code-only.txt` [trivial, low-risk]

- Rodar `bash local-ai/scripts/publicar_vba_import_v2.sh --apply` localmente
- Validar que `len_frm == len_co` no próximo RVS V2_SMOKE
- Commitar o delta de `.code-only.txt` resultante
- Fix correspondente: V2_SMOKE drift `Cadastro_Servico` (RVS REPROVADO determinístico 2x)

### AT-2 — diagnóstico empírico F-NEW5 [pré-condição para AT-3+ se F-NEW5 for incluída]

- Macro temporária `DUMP_POS_CR_CLICK` injetada em `Credencia_Empresa.frm` (envelopada por `Const ATIVAR_DIAG_FNEW5 = True` para fácil remoção)
- Dispara imediatamente após `CR_Credenciar_Click` final, captura: linha gravada, valor + `VarType` + `NumberFormat` de cada coluna (CRED_ID, EMP_ID, ATIV_ID, COD_ATIV_SERV, STATUS_CRED) → CSV em `auditoria/evidencias/V12.0.0206/csv/`
- Mauricio reproduz o cenário F-NEW5: cadastra atividade nova, serviço novo, credencia empresa nova
- Validação: o CSV mostra STATUS=ATIVO ou STATUS=vazio? Se vazio, qual a coluna na verdade gravada? Se ATIVO, então o problema é na exibição (ListBox/relatório), não na gravação
- **Decisão depende do resultado**: se confirmar que gravação está OK, F-NEW5 é problema de exibição (escopo separado, possivelmente 38.2.4); se confirmar gravação stale, F-NEW5 entra como fix prioritário

### AT-3 — fix pontual `Svc_PreOS` + `Repo_PreOS` para V2_E2E_STRIKES [médio, **requer exceção tabu**]

- Aplicar `NumberFormat = "@"` antes da gravação em `Svc_PreOS.EmitirPreOS:189-205` (linhas que escrevem COL_PREOS_ID/ENT_ID/COD_SERV/EMP_ID/ATIV_ID)
- Aplicar `Pad3()` na hidratação em `Repo_PreOS.BuscarPorId:78-83` para EMP_ID, ATIV_ID, ENT_ID, SERV_ID
- **NÃO** introduzir helper centralizado nesta onda (isso é Camada 1 da Onda 38.2.4) — fix direto, escopo mínimo
- **Bloqueio**: tabu Svc_* (V206) impede tocar `Svc_PreOS` sem aprovação. **Pedir exceção mínima a Mauricio em hearback** (vide §8 hipótese H-C-i abaixo)

### AT-4 — re-import L41 (2 fases) [operacional, novo procedimento]

- Manifesto Onda 38.2.3 dividido em dois pacotes:
  - **Fase 1**: só `.bas` (Repo_PreOS modificado + qualquer outro `.bas` da onda)
  - **Fase 2**: só `.frm` (Cadastro_Servico ressincronizado em AT-1)
- RVS Trio entre as duas fases + RVS Trio final
- Documentar passo-a-passo em `auditoria/03_ondas/onda_38_2_3/` para reuso futuro (L41 vira procedimento standard)

### AT-5 — GATE-USO-PROLONGADO L43 [operacional, 30 min Mauricio]

- Após import Fase 2 (AT-4), Mauricio exercita o workbook por ≥ 30 min em uso normal: cadastros, consultas, relatórios, fechar/reabrir workbook, emissão de Pre-OS e OS de teste
- Critério de saída: ZERO erros, ZERO travamentos, abertura/fechamento limpos
- Só após esse uso prolongado: GATE-RVS Trio final + sinalização ONDA38.2.3 ENTREGUE

**Ordem de execução**:
- AT-1 + AT-2 em paralelo na microonda 38.2.3-A (workbook pré-import, fast_track)
- AT-3 microonda 38.2.3-B (precisa hearback de exceção tabu)
- AT-4 + AT-5 fechamento (sequencial, operacional)

**NÃO incluído nesta onda** (e por quê):
- Camada 1 (`GravarIdTextual` centralizado) → 38.2.4 (helper transversal exige onda dedicada com signature freeze L34)
- Camada 2 (`LerIdTextual` substituindo `CStr` nos Repos) → 38.2.4
- Camada 3 (`AuditarIntegridadeReferencial`) → 38.2.5
- Camada 4 (migração legado workbook) → 38.2.5 (só após helpers estabilizados)
- Correção F-NEW6 em `Repo_OS`, `Svc_OS`, `Repo_Avaliacao`, `Repo_Credenciamento` → 38.2.4 com helper
- Fixtures `Teste_V2_Engine.bas` e `Teste_Bateria_Oficial.bas` → débito V207 (mantido)
- L40 meta-validação (teste E2E não-fixture) → 38.2.5

---

## 6. Roadmap atualizado até GATE-FREEZE V206

| Onda | Escopo | Riscos | Status |
|---|---|---|---|
| **38.2.3** | AT-1..AT-5 acima — drift + diagnóstico + fix pontual + L41 + L43 | Exceção tabu Svc_PreOS; resultado AT-2 pode redirecionar | A iniciar pós-hearback |
| **38.2.4** | Camada 1 (`Util_Planilha.GravarIdTextual`) + Camada 2 (`Util_Planilha.LerIdTextual`); substituição nos Repos não-blindados (Repo_OS, Repo_Avaliacao, Repo_Credenciamento) + nos cadastros UI já corrigidos (reescrever via helper, sem mudança comportamental); RVS Trio + meta-validação L40 (teste E2E novo, não-fixture) | Refatoração transversal = signature freeze L34 obrigatório; comparações duplicadas de IdsIguais a unificar | A planejar |
| **38.2.5** | Camada 3 (`AuditarIntegridadeReferencial`) + Camada 4 (`Util_Migrar_IDS_Workbook`); migração 1× no workbook ativo (backup obrigatório); RVS Trio final | Migração descartável é classe nova de macro; reversibilidade exige snapshot | A planejar |
| **GATE-FREEZE V206** | RVS Trio APROVADO + integridade referencial verde + 1 semana de uso operacional sem incidente + L40 verde | Operacional; depende de Mauricio em uso real | A planejar |

**Tempo estimado**: 38.2.3 ≈ 1 sessão Opus + operação Mauricio; 38.2.4 ≈ 2 sessões Opus; 38.2.5 ≈ 2 sessões Opus + 1 semana uso operacional.

---

## 7. Riscos identificados + mitigações

| Risco | Severidade | Mitigação |
|---|---|---|
| Exceção tabu Svc_PreOS (AT-3) negada por Mauricio | Alta | Plano B: corrigir só `Repo_PreOS.BuscarPorId` (hidratação `Pad3`), aceitar gravação numérica em PRE_OS, documentar mitigação parcial. Codex §9 prevê esse cenário explicitamente |
| AT-2 mostra que F-NEW5 não é F-NEW6 nem ListBox parsing — causa real desconhecida | Média | Triage: se diagnóstico inconclusivo, escalar para análise tela-a-tela com gravação Spy++ ou similar; F-NEW5 fica reaberto sem bloquear 38.2.3 |
| Re-import 2 fases (L41) introduz erro humano (manifesto mal montado) | Média | Documentação passo-a-passo em `onda_38_2_3/IMPORT_PROCEDURE.md`; checklist antes da Fase 2 |
| GATE-USO-PROLONGADO 30 min é insuficiente | Baixa | Se workbook corromper em uso de 1+ hora, voltar ao plano de uso operacional 1 semana (movido de 38.2.5 para 38.2.3) |
| Workbook reaberto pós-corrupção tem código órfão não-versionado | Alta | Aceitar oferta de Mauricio: exportar forms+módulos do workbook ATUAL para `local-ai/incoming/`, fazer `diff` vs `src/vba/` ANTES de descartar; documentar achados |
| AT-3 corrige `DIAG_PREOS_INTEGRITY` mas introduz regressão em RVS V2_E2E_STRIKES casos correlatos | Média | Pré-flight signature freeze (L34); rodar V2 completo (não Trio) antes de declarar entrega; meta-validação L40 |
| Camada 1+2 da Onda 38.2.4 toca tantos Repos que workbook fica frágil de novo (L41 recursivo) | Alta | Aplicar L41 também na 38.2.4: import em 2 fases por categoria de módulo |
| Migração legado (38.2.5) reescreve tokens que não são IDs (`AUDIT_LOG.ID_AFETADO` com valores `"CAD_OS"`, `"CONFIG"`) | Alta | Codex §7 Camada 4: helper de migração type-aware com lista explícita de colunas/sentinelas permitidas; CSV pré + pós para validação |

---

## 8. Pedido de hearback Mauricio — 3 hipóteses

🟡 **HBN HEARBACK REQUEST — decisão arquitetural pré-Onda 38.2.3**

### Hipótese H-A — seguir Codex puro (workbook atual, sem refresh)

- Pró: zero esforço operacional pré-onda; trabalho começa imediato
- Contra: ignora L41/L43 das protocol-evolutions desta mesma onda; mantém workbook que corrompeu
- Quando faz sentido: se Mauricio avaliou que o workbook reaberto está estável e prefere economizar 30 min de re-import

### Hipótese H-B — rollback git FIX2-PERF + re-aplicar 38.2.2

- Pró: estado git conhecido limpo (RVS Trio APROVADO `VR_20260526_102200`)
- Contra: descarta 5 hotfixes validados pelas auditorias; trabalho de re-aplicação; mesmas correções voltam a ser necessárias
- Quando faz sentido: se Mauricio quer "começar do zero" e considera o trabalho de re-aplicação custo aceitável

### Hipótese H-C (recomendação Opus) — git preservado + workbook refresh L41 + diagnóstico F-NEW5 + fix pontual

- Pró: aplica L41+L43 imediatamente; preserva trabalho 38.2.2 validado; resolve V2_SMOKE drift + V2_E2E_STRIKES sem comprimir 4 camadas em 1 onda; respeita ordem Codex (diagnóstico antes de refatoração transversal)
- Contra: 30 min operacionais pré-onda + 30 min GATE-USO; pede exceção tabu Svc_PreOS (sub-decisão H-C-i)
- **Sub-decisão H-C-i — exceção mínima ao tabu Svc_PreOS para AT-3**:
  - **(α) aprovada**: AT-3 toca `Svc_PreOS.EmitirPreOS:189-205` aplicando só `NumberFormat="@"` antes das gravações de IDs; demais pontos do módulo intocados; signature freeze documentado
  - **(β) negada**: AT-3 reduzido a só `Repo_PreOS.BuscarPorId:78-83` com `Pad3`; aceita-se que PRE_OS continua gravando IDs como Long mas leitura corrige; mitigação parcial documentada

### Pedido específico

Mauricio responde via hearback explícito em `.hbn/hearbacks/0112-rb-onda-38-2-3-<escopo>.md`:

1. **Decisão A/B/C**: qual hipótese de partida?
2. **Se C: decisão H-C-i**: α (exceção aprovada) ou β (mitigação parcial)?
3. **Sobre oferta de export workbook ATUAL** para `local-ai/incoming/`: aceitar e fazer `diff` pré-onda? sim/não
4. **Sobre AT-2 (diagnóstico F-NEW5)**: incluir agora ou mover para depois? Recomendação Opus: incluir agora, evita falsa atribuição
5. **Confirmar L41 e L43** como vinculantes para Onda 38.2.3 (e Camadas 1-2 da 38.2.4)?

Após hearback `confirmed`, Opus abre readback `0112-rb-onda-38-2-3-<escopo>` com `decisions_preconfirmed` e proposta de paths/módulos exatos para AT-1..AT-5.

---

## 9. Notas operacionais para próxima Opus

- **Estado git esperado pós-117**: commit `docs(hbn): analise consolidada auditorias 0009+0010 (Opus → Onda 38.2.3 escopo)` em fast_track, com bypass-hbn-guards (paths fora dos readbacks ativos 0111-* — mesmo padrão de Antigravity 0010)
- **Memória a atualizar** após hearback:
  - `project_corrupcao_workbook_v206_onda_38_2_2.md` → adicionar decisão A/B/C tomada
  - Nova memória se H-C-i aprovada: `project_excecao_tabu_svc_preos_at3.md` (exceção mínima, escopo restrito)
- **Bastão**: continua Opus 4.7. Próxima sessão abrirá `0112-rb-onda-38-2-3-<escopo>` após hearback
- **Orçamento de contexto**: esta sessão está em ~15% após reads completos + redação; tem espaço confortável para commit + atualização relay/INDEX.md

---

## 10. Referências

- Auditoria Codex: [`.hbn/proposals/0009-codex-auditoria-integridade-idempotencia-v206.md`](../../.hbn/proposals/0009-codex-auditoria-integridade-idempotencia-v206.md)
- Auditoria Antigravity: [`.hbn/proposals/0010-antigravity-auditoria-integridade-idempotencia-v206.md`](../../.hbn/proposals/0010-antigravity-auditoria-integridade-idempotencia-v206.md)
- Prompt origem auditoria: [`auditoria/00_status/115_PROMPT_AUDITORIA_CRUZADA_INTEGRIDADE_IDEMPOTENCIA.md`](115_PROMPT_AUDITORIA_CRUZADA_INTEGRIDADE_IDEMPOTENCIA.md)
- Handoff predecessor: [`.hbn/messages/20260527-0930-handoff-fim-sessao-opus.md`](../../.hbn/messages/20260527-0930-handoff-fim-sessao-opus.md)
- Protocol-evolutions L41-L43 + M-L: [`.hbn/protocol-evolutions/20260527-0930-onda-38-2-2-final-proposals.md`](../../.hbn/protocol-evolutions/20260527-0930-onda-38-2-2-final-proposals.md)
- Relay vivo: [`.hbn/relay/INDEX.md`](../../.hbn/relay/INDEX.md)
- Anchor V206 funcional: `ee75b30` + RVS Trio APROVADO `VR_20260526_102200`
- HEAD atual: `8fbdf26`

---FIM ANÁLISE 117---
