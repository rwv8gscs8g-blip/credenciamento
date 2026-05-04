---
titulo: 55 — Auditoria Antigravity 2026-05-04
diataxis: status
hbn-track: audit_only
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-04
autor: Antigravity (Gemini Code Assist)
---

# 55. Auditoria Antigravity (Frente 1 / Bloco B Preparatório)

## 1. TL;DR
Auditoria profunda concluída com sucesso em modo READ-ONLY. Identificados gaps marginais de cobertura em Axis 1 (helpers de UI e funções de montagem). Confirmada brecha "espiritual" na Regra 7 (dupla penalização) que será sanada pela Onda 18. Descoberta violação **CRÍTICA** em Axis 3: o form `Reativa_Empresa.frm` está contornando a camada de serviços (`Svc_Rodizio.Reativar`) e realizando cópia direta de ranges (`Range.Copy`) do Excel, ferindo a arquitetura em V203. A Opção B da Onda 18 (Janela de Strikes) proposta pelo operador é técnica e semanticamente irretocável e recebe minha validação para implementação imediata.

---

## 2. Eixo 1 — Cobertura de testes

Foi realizado um mapeamento das `Public Sub/Function` dos módulos `Svc_*.bas` e `Repo_*.bas`. A maioria do "Caminho Feliz" (operações de domínio) é coberta primariamente pelas suítes `Bateria_Oficial` (V1) e `Teste_V2_Roteiros` (V2 E2E e Smoke).

### GAPS de Cobertura (Sem assert direto / Cobertura indireta)
| Módulo / Função | Situação de Cobertura | Risco |
|---|---|---|
| `Svc_Avaliacao.MontarDefaultsAvaliacao` | Indireta (via `AvaliarOS` UI setup) | Baixo |
| `Svc_Avaliacao.DescreverMudancasAvaliacao`| Indireta | Baixo |
| `Svc_Avaliacao.MontarNotasAvaliacao` | Indireta | Baixo |
| `Svc_Avaliacao.MontarPayloadAvaliacao` | Indireta | Baixo |
| `Svc_PreOS.MontarParametrosEmissaoPreOS`| Indireta | Baixo |
| `Svc_Transacao.*` (todas as funções) | **GAP ALTO** (nenhum assert unitário de estado transacional `InTransaction`, `Commit`, `Rollback`) | Alto |
| `Repo_PreOS.AtualizarStatus` | Indireta (via chamadas Svc) | Médio |

### Cobertura Específica (Onda 18)
- `Repo_Avaliacao.ContarStrikesPorEmpresa`: Coberta diretamente por E2E_Strikes e V1 (`BO_330*_NotaMin_*`).
- `Svc_Avaliacao.AvaliarOS` (linhas 380-408, bloco 7b): Coberta diretamente por testes de suspensão com Nota Mínima na V1 (`BO_330c_NotaMin_4_Suspende`).
- `Svc_Rodizio.Reativar`: Coberta por `BO_110_ReativarEmpresa1` e `BO_302_FiltroB_SuspensaExpirada`.

---

## 3. Eixo 2 — Cumprimento das 8 regras V203

| Regra | Módulo / Função Tocado | Estrito ou Brecha? | Detalhamento |
|---|---|---|---|
| **§1. Bastão** | N/A | Estrito | Cumprimento gerencial (docs). |
| **§2. Regra Ouro** | N/A | Estrito | Manifestos e diretórios respeitados rigorosamente até Onda 17. |
| **§3. Heurística 0** | Formulários (`.frm`) | Estrito | Validação estática executada na Onda 8. `Me.Controls.Add` usado para dinâmicos (L23), mas sem `InStr` ou dimensões na lógica de negócio. |
| **§4. Idempotência** | Operações Adm (`LimpaBaseTotalReset`, `Reset_CNAE`) | Estrito | Atestado pelos roteiros `IDM_*`. Cópia `Copia` em `Configuracao_Inicial` mantém consistência. |
| **§5. Audit Log** | `Svc_Rodizio.Reativar`, `Svc_Avaliacao.AvaliarOS`, etc | **Brecha** (UI) | Funções do `Svc_*` disparam `Audit_Log.Registrar` corretamente. Porém, como apontado no Eixo 3, o form `Reativa_Empresa.frm` realiza reativação sem usar o Svc, **pulando o Audit Log**. |
| **§6. Fila Imutável** | `Svc_Rodizio.AvancarFila`, `Suspender` | Estrito | A posição na fila (Timestamp de Última Indicação e Recusas) não é tocada nas funções de Suspensão. Apenas na geração ou recusa da pré-OS. |
| **§7. Dupla Penal.** | `Svc_Avaliacao.AvaliarOS`, `Repo_Avaliacao.ContarStrikes` | **Brecha (DT-17)**| Empresa suspensa por 3 strikes, após 90 dias, reativa. A 1ª nota baixa subsequentemente irá suspender imediatamente porque `ContarStrikesPorEmpresa` lê as 3 falhas do passado. Viola o *espírito* da regra (será corrigido na Onda 18). |
| **§8. Sem novos Mod**| Arquitetura Svc / Repo | Estrito | Restrito à divisão atual e uso estrito de Svc e Repo. |

---

## 4. Eixo 3 — UI ↔ Regras

Foi realizada varredura cruzando `Eventos` em `*.frm` vs chamadas da API `Svc_*` / `Repo_*`.

| Formulário | Evento de Ação | Sub / Regra de Negócio Chamada | Status |
|---|---|---|---|
| `Menu_Principal.frm` | `BE_ImprimeOS_Click` | `Svc_PreOS.EmitirPreOS`, `Svc_OS.EmitirOS` | ✅ Protegido e roteado pelos serviços |
| `Menu_Principal.frm` | `Botao Avaliar` | `Svc_Avaliacao.AvaliarOS` | ✅ Protegido (via `PreencherAvaliarOS`) |
| `Menu_Principal.frm` | `CancelarOSSelecionada` | `Svc_OS.CancelarOS` | ✅ Protegido |
| `Reativa_Empresa.frm`| `RM_Lista_DblClick` | **NENHUMA (Mutação Direta)** | ❌ **CRÍTICO**. O UI está fazendo `wsInativas.Rows(linhaCopia).Copy Destination:=wsEmpresas.Cells(...)`! |

**Achado Crítico:** `Reativa_Empresa.frm` e `Reativa_Entidade.frm` bypassam `Svc_Rodizio.Reativar` e o framework de `Audit_Log` inteiramente. Elas manipulam as planilhas lendo de `EMPRESAS_INATIVAS` e copiando o range (`Range.Copy`) direto para a última linha de `EMPRESAS`. Esse bypass invalida a governança, foge do log, e causará corrupção de dados ao incluir novas colunas como `DT_ULT_REATIV`.

---

## 5. Eixo 4 — Onda 18 critica

### 5.1 Validação Opção B do operador
A "Opção B" (manter o `ContarStrikesPorEmpresa` histórico, e criar `ContarStrikesParaPunicao` com janela de reativação) é **validada e altamente recomendada**.
- **Concordância:** Mantém a rastreabilidade integral para auditorias governamentais (sem exclusão de strikes "perdoados"). Preserva os testes e lógicas existentes na suíte que testavam histórico bruto.
- **Trade-offs:** Adiciona uma coluna ao banco (EMP_DT_ULT_REATIV), elevando o tempo de processamento fracional da montagem e parsing, e exigirá intervenção pontual no Tabu de Mod_Types. Custo ínfimo vs. Valor Semântico de auditoria.

### 5.2 Proposta técnica detalhada (MD-18.1)
Estou em pleno acordo com a sua especificação no doc 44 §6. Os passos são exatamente estes:
*   **a)** `Schema EMPRESAS`: Usar a coluna U/21 como `COL_EMP_DT_ULT_REATIV` (`Date`). Atualizar `Const_Colunas.bas`.
*   **b)** `Mod_Types.TEmpresa`: Inserir `DT_ULT_REATIV As Date`.
*   **c)** `Repo_Empresa.LerEmpresa`: Ler campo `emp.DT_ULT_REATIV = CDate(Cells(..., COL_EMP_DT_ULT_REATIV))`.
*   **d)** `Svc_Rodizio.Reativar`: No bloco que seta Status=Ativa, adicionar `emp.DT_ULT_REATIV = Now()`.
*   **e)** `Repo_Avaliacao.ContarStrikesParaPunicao`: Nova function, clona a lógica atual iterando `CAD_OS`, porém checando `If OS.DT_FECHAMENTO > emp.DT_ULT_REATIV Then`.
*   **f)** `Svc_Avaliacao §387`: Substituir chamada antiga pela nova função.
*   **g)** Atualizar assertions no `CS_E2E_REATIV2STRIKES` para verde.

### 5.3 Cenários de teste novos (Onda 18)
Novos testes que devem ser incluídos/validados via `E2E_Strikes` ou Roteiros `TV2`:
1.  **Reativação Sem Histórico de Reativação:** Validar empresa com `DT_ULT_REATIV` vazia, toma 3 notas baixas, deve suspender imediatamente.
2.  **Reativação Multi-Ciclo:** Empresa reativada 1 vez, toma 1 nota baixa, nada. Toma 2, nada. Toma 3, suspende novamente. É reativada pela 2ª vez, o contador reinicia a 0.
3.  **Reativação Automática (Time-driven):** Seleção pelo Rodízio de uma empresa que venceu suspensão ontem. O Selecionar a reativa, garantindo o disparo e atualização do timestamp, seguido por sua 1ª nota baixa que **NÃO** pode suspendê-la (strike count 1).
4.  **Reativação Manual (UI-driven):** Reativação precoce antes do prazo (como revogação de punição), valida a correta limpeza da janela. (Nota: Exige que a UI Chame o Serviço!).
5.  **Backward Compatibility:** Teste de regressão para as empresas antigas. Garantir validação `IsEmpty()` ou `= "00:00:00"` no tipo Data VBA em `ContarStrikesParaPunicao` para contar todo o histórico.

### 5.4 Impactos em forms (pre-flight L14)
**Alerta L14:** O esquema de Cópia Direta de ranges detectado no Eixo 3 é fatal aqui. Formulários que fazem cópia lateral cega de Range (como `Reativa_Empresa.frm` e `Reativa_Entidade.frm`) e formulários de exportação de relatórios, se amarrados de `A` até `T`, perderão os dados da coluna `U` (`DT_ULT_REATIV`) no translado. Da mesma forma, `Configuracao_Inicial` lida com "ClearContents" nas planilhas, certificar-se que limpa até as novas dimensões de coluna se fizer hardcode (no momento faz clear até `I` e `Y`, então não deve sobrepor `U`).

---

## 6. Propostas de melhoria detalhadas
1.  **P0 (Crítico para Integridade) — Refatoração de `Reativa_Empresa.frm` e `Reativa_Entidade.frm`**: Alterar o evento de Double Click e botão "Reativar" para **chamar as funções API** (`Svc_Rodizio.Reativar`) ao invés de copiar Range das inativas.
2.  **P1 (Segurança / L16) — Transaction Context Check**: Os serviços `Transacao_*` não estão sendo unitariamente testados. Sugiro adicionar uma bateria `TV2_RunTransacoes()` validando isolamento de commits e fallbacks de error-handling.
3.  **P2 — Constantes Hardcoded Ranges**: Mapear `Range("A2:Y")` espalhados pelo código UI (ex: `Configuracao_Inicial`) e mover as extremidades (`Y`) para funções de auxílio calcadas no `Mod_Types`.

---

## 7. Markers HBN V2 finais
- `⚪ HBN AUDIT-ONLY` — Auditoria estática realizada, sem mutações.
- `🔵 HBN HANDOFF READY` — Conclusões entregues, pronto para input no Chat 5.

---

### Trilha de Leitura (Auditabilidade)
- `AGENTS.md`
- `.hbn/knowledge/0001-regras-v203-inegociaveis.md`
- `auditoria/00_status/54_TRANSICAO_CHAT_4_PARA_5_2026_05_04.md`
- `auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md`
- `auditoria/00_status/50_DEBITO_DT_MD17_1E_STATUSBAR_HINT.md`
- `.hbn/knowledge/0002-regra-ouro-vba-import.md`
- `.hbn/knowledge/0003-glasswing-style-preventive-security.md`
- `.hbn/knowledge/0005-protocolo-markers-v2.md`
- `.hbn/relay/INDEX.md`
- `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`
- `CLAUDE.md`
- `grep` searches em todo repositório (diretório src/vba): `*.bas` e `*.frm` para coverage e UI linkage.
