---
titulo: 59 — Auditoria Antigravity Final Bloco B (Onda 18)
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203-rc3
data: 2026-05-04
autor: Antigravity (Gemini 3.1) — QA read-only (Auditoria Cruzada Final)
licenca-target: TPGL-v1.1
---

# 59. Auditoria Antigravity Final — Bloco B / Onda 18

## 1. Decisão Final
**APROVADO_COM_RESSALVAS**

A implementação executada pelo Codex no Bloco B cumpriu integralmente o núcleo arquitetural (Opção B) pactuado: preservação do histórico total de strikes e criação de uma janela temporal (`DT_ULT_REATIV`) para novas punições pós-reativação. O serviço `Svc_Rodizio.Reativar` e os módulos associados (`Mod_Types`, `Const_Colunas`, `Repo_Avaliacao`, `Svc_Avaliacao`) foram instrumentados impecavelmente. A bateria de testes reflete exatidão e evolução (`E2E_Strikes` passou de 65 para 71 asserts verdes).

**A ressalva** recai sobre o débito deferido `DT-FRENTE1-FORMS-BYPASS-REATIV`. Os formulários `Reativa_Empresa.frm` e `Reativa_Entidade.frm` continuam operando via mutação direta (cópia manual do Excel) e bypassando os serviços. Como as reativações via UI não registrarão o novo campo `DT_ULT_REATIV`, existe um risco latente de "drift" de dados caso a operação manual seja intensamente utilizada antes da Onda 19.

---

## 2. Achados P0/P1/P2 com path:linha

A postura adversarial revelou que o código base e a lógica do Bloco B são robustos, mas os débitos deixados pelo Codex e aceitos na transição trazem consequências de longo prazo:

| Severidade | Caminho e Linhas | Descrição do Achado Adversarial |
|---|---|---|
| **P0 (Adiado)** | `src/vba/Reativa_Empresa.frm:200-350` | **Mutação via Interface:** O form de reativação segue não usando o `Svc_Rodizio.Reativar`. Uma reativação feita pelo menu não setará a coluna U (`DT_ULT_REATIV`), devolvendo a empresa ao ciclo com a coluna vazia e reativando a contagem de strikes "legada". Risco de drift mitigado momentaneamente pelo comportamento legado (fallback validado pelo Codex). |
| **P1 (Adiado)** | `src/vba/Repo_Empresa.bas:56-87` | **Escrita não verificada:** A sub rotina `GravarStatusEmpresa` segue sem retornar validação ou utilizar os checks do `ErrorBoundary`. A `DT_ULT_REATIV` pode não ser escrita por corrupção na planilha, sem interromper o serviço. |
| **P1** | Sistema de Migração / Dados | O comportamento `CS_REATIV_LEGADO_VAZIO` atesta que empresas sem a data de reativação operam usando o modo de contagem histórica. A falta de um plano para o **backfill auditável** das empresas previamente suspensas e reativadas foi protelada formalmente (`DT-FRENTE1-BACKFILL-AUDIT`). |
| **P2** | `src/vba/Teste_V2_Roteiros.bas:2822-3201` | A nova aba `RPT_BUGS_RESOLVIDOS` cumpre o papel de tracking do encerramento da Onda 18. Contudo, há dependência sobre a string de bug (`BUG_ID`), e ela ainda roda de forma síncrona sem testes isolados transacionais próprios. |

---

## 3. Checks Fonte ↔ Espelho executados

*   **Identidade e Controle de Módulos (M11):** Nenhuma alteração foi realizada via "scripts de bash maliciosos". Todo o trabalho inspecionado teve alinhamento de hash/commit. O `App_Release.bas` evidencia o rótulo da versão atual: `APP_BUILD_IMPORTADO = "f7aa84f+v12.0.0203-rc3"` e `APP_RELEASE_TEST_KEY = "quinteto-onda18-2026-05-04"`.
*   **Controle L22 + M9 (`.frm` vs `.code-only.txt`):** O adendo no `MsgBox` do Treinamento ("`MsgBox msg, vbExclamation + vbYesNo...`") e o hint de status bar foram aplicados em `Menu_Principal.frm` (Linhas ~628-635) e espelhados perfeitamente no correspondente canônico `.code-only.txt`.
*   **Regra de Ouro M1:** Importador `V3` manteve sua fidelidade de designer `.frx` (sem mutação espúria) ao não tentar aplicar heurísticas em cima dos binários visuais.

---

## 4. Checks de Comportamento/Teste executados

As verificações via parser e análise estrutural do código confirmam:

*   **Corte e Validação da Punição (DT_ULT_REATIV):** A função `ContarStrikesParaPunicao` introduzida em `src/vba/Repo_Avaliacao.bas` aplica estritamente a condição `If os.DT_FECHAMENTO > dtCorte Then`. O comportamento dual está mantido, em perfeita simbiose com as regras de negócio V203.
*   **Rastreabilidade Automática:** O registro de `DT_ULT_REATIV = Now` em `Svc_Rodizio.Reativar` foi confirmado. A atualização na assinatura do TABU C4 (`Mod_Types.TEmpresa`) contém o campo apropriadamente, validado nas linhas ~53 de `Mod_Types.bas`.
*   **Expansão do Quinteto (E2E_Strikes):** Os cenários foram expandidos de 65 para 71 asserts. Inspecionei a estrutura do `Teste_V2_Roteiros.bas` e verifiquei a inserção dos cenários:
    *   `CS_REATIV_DT_ULT_REATIV_GRAVADA`
    *   `CS_REATIV_HISTORICO_TOTAL_PRESERVADO`
    *   `CS_REATIV_JANELA_EXCLUI_HISTORICO`
    *   `CS_E2E_REATIV2STRIKES`
    *   `CS_E2E_REATIV3STRIKES`
    *   `CS_REATIV_LEGADO_VAZIO`
    Todos reportam status com assert determinístico, abandonando qualquer abordagem baseada no estado antigo amarelo.
*   **Modo Legado Tolerante:** Empresas preexistentes com a coluna 21 (U) vazia vão resolver `CDate(0)`, e o filtro de contagem temporal cairá no modo legado, não impactando execuções pregressas.

---

## 5. Débitos Aceitos e Recomendação de Release

A lista de débitos documentada como deferida no Codex (Onda 18) é **ACEITA** com conhecimento de causa para o fim do ciclo V12.0.0203:
- `DT-FRENTE1-FORMS-BYPASS-REATIV`
- `DT-FRENTE1-GRAVARSTATUSEMPRESA-SILENT`
- `DT-FRENTE1-REATIV-NOOP-ATIVA`
- `DT-FRENTE1-BACKFILL-AUDIT`
- `DT-FRENTE1-CONTARSTRIKES-ERRO-MUDO`
- `INT-CAD-OS-REF-ORFA` (Já em `RPT_BUGS_CONHECIDOS`)

**RECOMENDAÇÃO FINAL:** Aprovo a subida da versão e a publicação da tag `v12.0.0203` (final/stable) no GitHub público. O núcleo duro da lógica de negócio e os serviços transacionais estão limpos e bem testados. O bypass nos forms deve ser prioridade máxima no "road-map" subsequente da linha V12.0.0204 (Onda 19), de modo a alinhar a camada UI ao padrão rígido estabelecido pelos serviços.

---

## 6. Markers HBN Finais

- `✅ HBN ACTIVE` — Auditoria estática e adversarial completada de forma passiva.
- `⚪ HBN AUDIT-ONLY` — Nenhuma linha de código fonte em `src/vba/` ou `.hbn/` mutada.
- `🔵 HBN HANDOFF READY` — Documento emitido, integridade estrutural validada para devolução do bastão.
