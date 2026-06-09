---
titulo: Relay HBN — coordenacao inter-IA do Credenciamento
versao-protocolo: HBN 0.3.1 + Cura Onda 36 (contratos executáveis) + PROMPT_ARQUITETO v1.6 (§12 Cadencia D Estendida + §12.B por papel + firewall 0022 + CI ratchet 0116)
proprietario-bastao: Codex (implementador principal V206) consolidou localmente as ondas 38.2.4 a 38.2.10 no commit `882cd2b`, sincronizou HBN em `d2d7ac5`, entregou Performance/UX basica em `e157221`, consolidou a auditoria cruzada documental 38.2.13, entregou a Onda 38.2.14 behavioralizacao C1, validou a Onda 38.2.15 FT-4 em 2026-06-01, validou 38.2.16 BL-4 via fix1 0133, 0137 fix1, 0139 fix1, 0140 e 0141. Antigravity executou a auditoria cruzada de impressao 0142 apontando 2 BLOQUEADORES nos PDFs; Codex implementou 0143, validou 0144 fix1 test-only por import/compile/`TV2_20260606_104057`, validou 0151 GATE 2 Quant./borda por import/compile/`TV2_20260606_111039`, preparou 0152 para incluir impressao residual no RVS oficial e validou 0153 para padronizar punicoes do rodizio em dias com UI, relatorios e RVS; primeiro 0153 importou mas falhou compile, corrigido no fix1 por late-binding auditavel do FT4; fix1 importou mas compile avancou para dependencia direta de `Auto_Open`, corrigida no fix2 via `Application.Run`; fix2 importou mas compile avancou para `Util_VerificarProtecaoPersistenteAposAbertura`, corrigida no fix3 via wrapper; fix3 importou mas compile avancou para membros TV2 de `Menu_Principal`, corrigidos no fix4 via `CallByName`; fix4 importou, compilou e passou `TV2_20260606_193709` + `VR_20260606_193911`; 0154 importou/compilou e passou `TV2_20260606_212617`; 0155 runtime foi suspensa antes de importacao apos diagnostico correto de sobreposicao de label; 0156 substituiu por correcao simples de design `.frm/.frx`, passou import/compile/`TV2_20260606_231033` e teve clique/edicao/salvamento confirmados; 0157 preparou handoff Codex->Codex e proposta USEHBN para tela a tela design-first; 0158 validou botoes/menus por import/compile/`TV2_20260607_005745`; 0159 importou/compilou, mas `TV2_20260607_094429` retornou `OK=12 | FALHA=2 | MANUAL=0` por contrato de teste acoplado a `Auto_Open` fora do delta; Fix1 ajustou a suite para delegar protecao a BL4 e foi validado por import/compile/`TV2_20260607_101426` com `OK=14 | FALHA=0 | MANUAL=0`. Linha arquiteto 0114-0117/0149 consolidou firewall, CI ratchet e handoff do Codex; Codex concluiu GATE 0 pelo readback 0150.
ciclo-ativo: V12.0.0206 EM VALIDACAO ITERATIVA — V12.0.0205 permanece como release oficial. Sequencia recente ENTREGUE/VALIDADA: 38.2.29/0159 Fix1 validada por import/compile/`TV2_20260607_101426` -> 38.2.30/0161 Fix1 validada por import/compile/`TV2_20260608_044610` -> 38.2.31/0162 validada por import/compile/`TV2_20260608_084549` -> 38.2.32/0163 Fix1 validada por import/compile/`TV2_20260608_115730` -> 38.2.33/0164 validada por import/compile/TV2 e `VR_20260608_134548` APROVADO -> 38.2.34/0165 validada por import/compile/`TV2_20260608_161110` -> 38.2.35/0166 limpeza worktree consolidada no commit `945039d` -> 0167 auditoria cruzada concluida -> 0168 higiene HBN pos-auditoria fechada -> 38.2.36/0169 C16 aviso operacional package_ready_gate_pending.
ancora-estavel-atual: V12-202-Z011-onda17-fechada (INTOCAVEL ate aprovacao operador) — build f7aa84f+ONDA17.MD2-bloco-a-fechamento-onda17, Quinteto VR_20260503_234443 APROVADO. CICLO V206 anchor funcional: HEAD ee75b30 (Onda 38.2.1-AR1-FIX2-PERF entregue), build ad5b487+ONDA38.2.1-AR1-FIX2-PERF, RVS Trio APROVADO em VR_20260526_102200. **Anchor de rollback Onda 38.2.2: commit 179bac5**. **Caminho B (rollback) tecnicamente valido se Mauricio escolher**.
proxima-acao: operador deve importar `ONDA38_2_36_C16_AVISO_OPERACIONAL_PDF`, compilar, rodar `TV2_RunRelatoriosSuspensoesStrikesReset` e revisar PDFs de Pre-OS/OS/Avaliacao; depois abrir 0170 disponibilidade composta.
ultima-atualizacao: 2026-06-08T23:31:48-03:00 (0169 pacote pronto para import/compile/TV2/PDF; 0168 doc-only fechada no commit 37486b7)
---

## 🟢 HIGIENE / 0168 — Auditoria cruzada e fechamento HBN pos-0166 (FECHADO)

| Campo | Valor |
|---|---|
| Sinal | ✅ HBN ACTIVE |
| Track | safe_track |
| Readback | [`0168-rb-onda-38-2-35-higiene-hbn-pos-auditoria.json`](../readbacks/0168-rb-onda-38-2-35-higiene-hbn-pos-auditoria.json) — **human_status: confirmed** |
| Hearback | [`0168-rb-onda-38-2-35-higiene-hbn-pos-auditoria-confirmed.json`](../hearbacks/0168-rb-onda-38-2-35-higiene-hbn-pos-auditoria-confirmed.json) |
| ERP | [`0168-exec-onda-38-2-35-higiene-hbn-pos-auditoria.json`](../results/0168-exec-onda-38-2-35-higiene-hbn-pos-auditoria.json) — `completed` |
| Consolidado | [`0167_CONSOLIDADO_AUDITORIA_CRUZADA.md`](../../auditoria/03_ondas/onda_38_2_35_auditoria_cruzada_pos_0165_0166/0167_CONSOLIDADO_AUDITORIA_CRUZADA.md) |
| Decisao aplicada | Fechar a lacuna de governanca antes de nova implementacao VBA |
| Escopo | HBN/relay/auditoria somente; sem VBA, sem pacote importavel, sem VCR |
| Sequencia aprovada | 0168 higiene HBN -> 0169 C16 PDF -> 0170 disponibilidade composta -> 0171 VCR |
| Veredito atual | Fechado no commit `37486b7`; 0169 aberta |

## 🟡 GATE / 0169 — C16 aviso operacional em PDF (PACKAGE READY)

| Campo | Valor |
|---|---|
| Sinal | ✅ HBN ACTIVE |
| Track | safe_track |
| Readback | [`0169-rb-onda-38-2-36-c16-aviso-operacional-pdf.json`](../readbacks/0169-rb-onda-38-2-36-c16-aviso-operacional-pdf.json) — **human_status: confirmed** |
| Hearback | [`0169-rb-onda-38-2-36-c16-aviso-operacional-pdf-confirmed.json`](../hearbacks/0169-rb-onda-38-2-36-c16-aviso-operacional-pdf-confirmed.json) |
| ERP | [`0169-exec-onda-38-2-36-c16-aviso-operacional-pdf.json`](../results/0169-exec-onda-38-2-36-c16-aviso-operacional-pdf.json) — `package_ready_gate_pending` |
| Tecnico | [`0169_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_36_c16_aviso_operacional_pdf/0169_TECNICO.md) |
| Procedimento | [`0169_PROCEDIMENTO_IMPORT.md`](../../auditoria/03_ondas/onda_38_2_36_c16_aviso_operacional_pdf/0169_PROCEDIMENTO_IMPORT.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_36_C16_AVISO_OPERACIONAL_PDF.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_36_C16_AVISO_OPERACIONAL_PDF.txt) |
| Decisao aplicada | C16:N16 dos impressos recebe alinhamento legivel em runtime para neutralizar alinhamento distribuido do template |
| Build | `37486b7+ONDA38.2.36-C16-AVISO-OPERACIONAL` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_36_C16_AVISO_OPERACIONAL_PDF", "37486b7+ONDA38.2.36-C16-AVISO-OPERACIONAL"` |
| Pos-import esperado | `M=4 | F=0 | err=0 | skip=0`; compile limpo; `TV2_RunRelatoriosSuspensoesStrikesReset` com `OK=11 | FALHA=0 | MANUAL=0` |
| Validacao visual | Gerar PDFs de Pre-OS, OS e Avaliacao; aviso `Status da empresa nesta data` em C16 deve sair sem letras artificialmente espacadas |
| Nao tocar | `.frm`, `.frx`, `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`, `ThisWorkbook`; nao rodar VCR neste microdelta |
| Veredito atual | Pacote pronto; aguardando gate humano |

## 🟢 HIGIENE / 0166 — Limpeza worktree pos-0165 (FECHADO POR FOLLOW-UP 0168)

| Campo | Valor |
|---|---|
| Sinal | 🟢 FECHADO |
| Track | safe_track |
| Readback | [`0166-rb-onda-38-2-35-limpeza-worktree-pos-0165.json`](../readbacks/0166-rb-onda-38-2-35-limpeza-worktree-pos-0165.json) — **human_status: confirmed** |
| Hearback | [`0166-rb-onda-38-2-35-limpeza-worktree-pos-0165-confirmed.json`](../hearbacks/0166-rb-onda-38-2-35-limpeza-worktree-pos-0165-confirmed.json) |
| ERP | [`0166-exec-onda-38-2-35-limpeza-worktree-pos-0165.json`](../results/0166-exec-onda-38-2-35-limpeza-worktree-pos-0165.json) — `completed` |
| Commit | `945039d` (`945039da0560e30e09888310ee806fbe61e6f832`) |
| Decisao aplicada | Consolidar localmente a 0165 validada e limpar o worktree sem reset/revert/stash |
| Observacao | ERP criado em follow-up 0168 porque precisava registrar o hash do commit de limpeza |
| Veredito atual | Fechado; branch segue ahead 2 ate decisao humana de push |

## 🟢 GATE / 0165 — Pre-OS vencidas relatorio/impressao (FECHADO)

| Campo | Valor |
|---|---|
| Sinal | ✅ HBN ACTIVE |
| Track | safe_track |
| Readback | [`0165-rb-onda-38-2-34-preos-vencidas-relatorio-impressao.json`](../readbacks/0165-rb-onda-38-2-34-preos-vencidas-relatorio-impressao.json) — **human_status: confirmed** |
| Hearback | [`0165-rb-onda-38-2-34-preos-vencidas-relatorio-impressao-confirmed.json`](../hearbacks/0165-rb-onda-38-2-34-preos-vencidas-relatorio-impressao-confirmed.json) |
| ERP | [`0165-exec-onda-38-2-34-preos-vencidas-relatorio-impressao.json`](../results/0165-exec-onda-38-2-34-preos-vencidas-relatorio-impressao.json) — `completed` |
| Tecnico | [`0165_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_34_preos_vencidas_relatorio_impressao/0165_TECNICO.md) |
| Procedimento | [`0165_PROCEDIMENTO_IMPORT.md`](../../auditoria/03_ondas/onda_38_2_34_preos_vencidas_relatorio_impressao/0165_PROCEDIMENTO_IMPORT.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_34_PREOS_VENCIDAS_RELATORIO_IMPRESSAO.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_34_PREOS_VENCIDAS_RELATORIO_IMPRESSAO.txt) |
| Decisao aplicada | O relatorio de Pre-OS vencidas fica documentado e testado como consulta/impressao, sem expiracao automatica |
| Build | `b33ec4e+ONDA38.2.34-PREOS-VENCIDAS-RELATORIO` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_34_PREOS_VENCIDAS_RELATORIO_IMPRESSAO", "b33ec4e+ONDA38.2.34-PREOS-VENCIDAS-RELATORIO"` |
| Pos-import esperado | `M=3 | F=0 | err=0 | skip=0`; compile limpo; `TV2_RunTelaRelatorios` com `OK=11 | FALHA=0 | MANUAL=0` |
| Gate observado | Import `M=3 | F=0 | err=0 | skip=0`; compile limpo; `TV2_20260608_161110` com `OK=11 | FALHA=0 | MANUAL=0`; mensagem de indisponibilidade aplicada corretamente |
| PDFs revisados | 072-078: entidades, empresas, credenciadas, Pre-OS, OS e avaliacao com status/disponibilidade nos pontos relevantes |
| Suite | `TV2_RunTelaRelatorios`, read-only por tokens, sem acionar impressao real ou expiracao |
| Nao tocar | `.frx`, `Menu_Principal.frm`, `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`, `ThisWorkbook`; nao rodar VCR neste microdelta |
| Veredito atual | Fechado; proxima onda deve abrir novo readback antes de implementacao |

## 🟢 GATE / 0164 — Disponibilidade operacional em relatorios (FECHADO)

| Campo | Valor |
|---|---|
| Sinal | ✅ HBN ACTIVE |
| Track | safe_track |
| Readback | [`0164-rb-onda-38-2-33-disponibilidade-operacional-relatorios.json`](../readbacks/0164-rb-onda-38-2-33-disponibilidade-operacional-relatorios.json) — **human_status: confirmed** |
| Hearback | [`0164-rb-onda-38-2-33-disponibilidade-operacional-relatorios-confirmed.json`](../hearbacks/0164-rb-onda-38-2-33-disponibilidade-operacional-relatorios-confirmed.json) |
| ERP | [`0164-exec-onda-38-2-33-disponibilidade-operacional-relatorios.json`](../results/0164-exec-onda-38-2-33-disponibilidade-operacional-relatorios.json) — `package_ready_gate_pending` |
| Tecnico | [`0164_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_33_disponibilidade_operacional_relatorios/0164_TECNICO.md) |
| Procedimento | [`0164_PROCEDIMENTO_IMPORT.md`](../../auditoria/03_ondas/onda_38_2_33_disponibilidade_operacional_relatorios/0164_PROCEDIMENTO_IMPORT.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_33_DISPONIBILIDADE_OPERACIONAL_RELATORIOS.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_33_DISPONIBILIDADE_OPERACIONAL_RELATORIOS.txt) |
| Decisao aplicada | Relatorios e mensagem de Pre-OS passam a mostrar disponibilidade operacional real: suspensa, OS em execucao, Pre-OS pendente ou disponivel |
| Build | `293e44c+ONDA38.2.33-DISPONIBILIDADE-RELATORIOS` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_33_DISPONIBILIDADE_OPERACIONAL_RELATORIOS", "293e44c+ONDA38.2.33-DISPONIBILIDADE-RELATORIOS"` |
| Pos-import esperado | `M=5 | F=3 | err=0 | skip=0`; compile limpo; `TV2_RunRelatoriosSuspensoesStrikesReset` com `OK=10 | FALHA=0 | MANUAL=0` |
| Regressao recomendada | `TV2_RunTelaRelatorios` com `OK=10 | FALHA=0 | MANUAL=0` |
| Gate observado | Import `M=5 | F=3 | err=0 | skip=0`; compile limpo; `TV2_RunRelatoriosSuspensoesStrikesReset` com `OK=10 | FALHA=0 | MANUAL=0`; `VR_20260608_134548` APROVADO |
| Nao tocar | `.frx`, `Configuracao_Inicial.frm`, `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`, `ThisWorkbook`; nao implementar checkboxes de reset anual nesta onda |
| Veredito atual | Fechado; checkpoint 0153-0164 consolidado no commit `b33ec4e`; 0165 aberta para documentar Pre-OS vencidas |

## 🟢 FIX1 / 0163 — Relatorios suspensoes, strikes e reset (FECHADO)

| Campo | Valor |
|---|---|
| Sinal | ✅ HBN ACTIVE |
| Track | safe_track |
| Readback | [`0163-rb-onda-38-2-32-relatorios-suspensoes-strikes-reset.json`](../readbacks/0163-rb-onda-38-2-32-relatorios-suspensoes-strikes-reset.json) — **human_status: confirmed** |
| Hearback | [`0163-rb-onda-38-2-32-relatorios-suspensoes-strikes-reset-confirmed.json`](../hearbacks/0163-rb-onda-38-2-32-relatorios-suspensoes-strikes-reset-confirmed.json) |
| ERP | [`0163-exec-onda-38-2-32-fix1-relatorios-suspensoes-strikes-reset.json`](../results/0163-exec-onda-38-2-32-fix1-relatorios-suspensoes-strikes-reset.json) — `completed` |
| Tecnico | [`0163_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_32_relatorios_suspensoes_strikes_reset/0163_TECNICO.md) |
| Procedimento | [`0163_PROCEDIMENTO_IMPORT.md`](../../auditoria/03_ondas/onda_38_2_32_relatorios_suspensoes_strikes_reset/0163_PROCEDIMENTO_IMPORT.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_32_FIX1_RELATORIOS_SUSPENSOES_STRIKES_RESET.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_32_FIX1_RELATORIOS_SUSPENSOES_STRIKES_RESET.txt) |
| Decisao aplicada | Corrige falso negativo test-only: RELSSR_01 valida os literais do aviso em `Rel_Rodizio_Status`; RELSSR_08 valida apenas a fiacao de `Preencher` para o impresso |
| Build | `293e44c+ONDA38.2.32-FIX1-REL-SUSP-STRIKES-RESET` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_32_FIX1_RELATORIOS_SUSPENSOES_STRIKES_RESET", "293e44c+ONDA38.2.32-FIX1-REL-SUSP-STRIKES-RESET"` |
| Pos-import esperado | `M=2 | F=0 | err=0 | skip=0`; compile limpo; `TV2_RunRelatoriosSuspensoesStrikesReset` com `OK=10 | FALHA=0 | MANUAL=0` |
| Gate base observado | Pacote base importou e compilou; `TV2_20260608_114127` retornou `OK=9 | FALHA=1 | MANUAL=0` em `RELSSR_08_IMPRESSOS_AVISO_OPERACIONAL` |
| Suite | `TV2_RunRelatoriosSuspensoesStrikesReset`, read-only por tokens, sem acionar impressao real ou fluxo destrutivo |
| Nao tocar | `.frx`, `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`, `ThisWorkbook`; nao rodar VCR neste microdelta |
| Gate observado | Importou, compilou e `TV2_20260608_115730` retornou `OK=10 | FALHA=0 | MANUAL=0`; VCR posterior falhou apenas por falso negativo adversarial fora da regra RELSSR |
| Veredito atual | Fechado; 0164 aberta para disponibilidade operacional e correcao do falso negativo VCR |

## 🟢 GATE TELA A TELA / 0162 — Relatorios status e formatacao (FECHADO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 FECHADO |
| Track | safe_track |
| Readback | [`0162-rb-onda-38-2-31-relatorios-tela-a-tela-status-formatacao.json`](../readbacks/0162-rb-onda-38-2-31-relatorios-tela-a-tela-status-formatacao.json) — **human_status: confirmed** |
| Hearback | [`0162-rb-onda-38-2-31-relatorios-tela-a-tela-status-formatacao-confirmed.json`](../hearbacks/0162-rb-onda-38-2-31-relatorios-tela-a-tela-status-formatacao-confirmed.json) |
| ERP | [`0162-exec-onda-38-2-31-relatorios-tela-a-tela-status-formatacao.json`](../results/0162-exec-onda-38-2-31-relatorios-tela-a-tela-status-formatacao.json) — `package_ready_gate_pending` |
| Tecnico | [`0162_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_31_relatorios_tela_a_tela/0162_TECNICO.md) |
| Procedimento | [`0162_PROCEDIMENTO_IMPORT.md`](../../auditoria/03_ondas/onda_38_2_31_relatorios_tela_a_tela/0162_PROCEDIMENTO_IMPORT.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_31_RELATORIOS_TELA_A_TELA.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_31_RELATORIOS_TELA_A_TELA.txt) |
| Decisao aplicada | Relatorios com empresa passam a mostrar status operacional, datas de suspensao, ultima reativacao/retorno e participacao no rodizio; relatorios principais usam formatacao tabular comum |
| Build | `293e44c+ONDA38.2.31-RELATORIOS-TELA-A-TELA` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_31_RELATORIOS_TELA_A_TELA", "293e44c+ONDA38.2.31-RELATORIOS-TELA-A-TELA"` |
| Pos-import esperado | `M=4 | F=3 | err=0 | skip=0`; compile limpo; `TV2_RunTelaRelatorios` com `OK=10 | FALHA=0 | MANUAL=0` |
| Gate observado | Importou e compilou, reportado pelo operador; `TV2_20260608_084549` com `OK=10 | FALHA=0 | MANUAL=0`; PDFs 054-061 analisados para abrir 0163 |
| Suite | `TV2_RunTelaRelatorios`, read-only por tokens, sem acionar impressao real |
| Nao tocar | `.frx`, `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`, `ThisWorkbook`; nao rodar VCR neste microdelta |
| Veredito atual | Fechado; proxima onda 0163 aberta para normalizar strikes/reset |

## 🟢 FIX1 / 0161 — Novo Periodo limpeza e contagem (FECHADO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 FECHADO |
| Track | safe_track |
| Readback | [`0161-rb-onda-38-2-30-fix1-novo-periodo-contagem-limpeza.json`](../readbacks/0161-rb-onda-38-2-30-fix1-novo-periodo-contagem-limpeza.json) — **human_status: confirmed** |
| Hearback | [`0161-rb-onda-38-2-30-fix1-novo-periodo-contagem-limpeza-confirmed.json`](../hearbacks/0161-rb-onda-38-2-30-fix1-novo-periodo-contagem-limpeza-confirmed.json) |
| ERP | [`0161-exec-onda-38-2-30-fix1-novo-periodo-contagem-limpeza.json`](../results/0161-exec-onda-38-2-30-fix1-novo-periodo-contagem-limpeza.json) — `completed` |
| Tecnico | [`0160_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_30_config_cenarios_persistencia_csv/0160_TECNICO.md) |
| Procedimento | [`0160_PROCEDIMENTO_IMPORT.md`](../../auditoria/03_ondas/onda_38_2_30_config_cenarios_persistencia_csv/0160_PROCEDIMENTO_IMPORT.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_30_CONFIG_CENARIOS_CSV_FIX1.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_30_CONFIG_CENARIOS_CSV_FIX1.txt) |
| Causa | Gate 0160 passou import/compile e falhou apenas `CFGCSV_06`; limpeza parcial + contagem por ultima linha viraram falso negativo `PRE_OS_DEPOIS=1` e `CAD_OS_DEPOIS=1` |
| Decisao aplicada | Limpar `PRE_OS` ate `COL_PREOS_OS_ID`, limpar `CAD_OS` ate `COL_OS_JUSTIF_DIV`, contar registros por coluna-chave e aplicar a mesma limpeza no botao real de Novo Periodo |
| Build | `293e44c+ONDA38.2.30-FIX1-CONFIG-CENARIOS-CSV` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_30_CONFIG_CENARIOS_CSV_FIX1", "293e44c+ONDA38.2.30-FIX1-CONFIG-CENARIOS-CSV"` |
| Pos-import esperado | `M=2 | F=1 | err=0 | skip=0`; compile limpo; `TV2_RunConfigCenariosNovoPeriodo` com `OK=7 | FALHA=0 | MANUAL=0` |
| Gate observado | Importou e compilou, reportado pelo operador; `TV2_20260608_044610` com `OK=7 | FALHA=0 | MANUAL=0`; CSV de falhas nao exportado |
| Nao tocar | `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`, `ThisWorkbook`, `Menu_Principal.frm/.frx`, `Configuracao_Inicial.frx`; nao rodar VCR |
| Veredito atual | Fechado; proxima onda deve abrir novo readback |

## 🟡 GATE TELA A TELA / 0160 — Configuracoes Iniciais matriz de cenarios + CSV (ABRIU FIX1)

| Campo | Valor |
|---|---|
| Sinal | ✅ HBN ACTIVE |
| Track | safe_track |
| Readback | [`0160-rb-onda-38-2-30-config-cenarios-persistencia-csv.json`](../readbacks/0160-rb-onda-38-2-30-config-cenarios-persistencia-csv.json) — **human_status: confirmed** |
| Hearback | [`0160-rb-onda-38-2-30-config-cenarios-persistencia-csv-confirmed.json`](../hearbacks/0160-rb-onda-38-2-30-config-cenarios-persistencia-csv-confirmed.json) |
| ERP | [`0160-exec-onda-38-2-30-config-cenarios-persistencia-csv.json`](../results/0160-exec-onda-38-2-30-config-cenarios-persistencia-csv.json) — `package_ready_gate_pending` |
| Tecnico | [`0160_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_30_config_cenarios_persistencia_csv/0160_TECNICO.md) |
| Procedimento | [`0160_PROCEDIMENTO_IMPORT.md`](../../auditoria/03_ondas/onda_38_2_30_config_cenarios_persistencia_csv/0160_PROCEDIMENTO_IMPORT.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_30_CONFIG_CENARIOS_CSV.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_30_CONFIG_CENARIOS_CSV.txt) |
| Decisao aplicada | Ampliar a persistencia do painel para matriz 1/2, gestor/municipio com build, consumo por getters/regras, Novo Periodo deterministico e CSV salvo junto da copia da planilha |
| Build | `293e44c+ONDA38.2.30-CONFIG-CENARIOS-CSV` |
| Base encontrada | `TV2_RunPersistenciaPainel` ja cobre round-trip parcial; `TV2_RunTelaConfiguracoesIniciais` cobre tela/botoes; `CONFIG_SNAPSHOT_V2` cobre restauracao tecnica da CONFIG |
| Lacuna coberta | Gestor/municipio, matriz 1/2, consumo por servicos, copia da planilha e CSV de evidencias de Novo Periodo |
| Destrutivo autorizado | Sim, apenas para o mapa de testes: avisar, criar cenario deterministico/idempotente, salvar copia da planilha antes da limpeza e registrar CSV na pasta `V12-0-0206-Onda-38-2-30` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_30_CONFIG_CENARIOS_CSV", "293e44c+ONDA38.2.30-CONFIG-CENARIOS-CSV"` |
| Pos-import esperado | `M=3 | F=1 | err=0 | skip=0`; compile limpo; `TV2_RunConfigCenariosNovoPeriodo` com `OK=7 | FALHA=0 | MANUAL=0` |
| Gate observado | Import `M=3 | F=1 | err=0 | skip=0`; compile limpo; `TV2_20260607_110826` com `OK=6 | FALHA=1 | MANUAL=0`, falha isolada em `CFGCSV_06` |
| Evidencia esperada | Pasta `V12-0-0206-Onda-38-2-30` contendo copia da planilha e `TesteV2_CONFIG_CENARIOS_<execucao>.csv` |
| Nao tocar | `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`, `ThisWorkbook`, `Menu_Principal.frm/.frx`, `Configuracao_Inicial.frx`, Util_PDF quarentenado; nao rodar VCR neste microdelta |
| Veredito atual | Supersedido pelo fix1 0161 para corrigir falso negativo de limpeza/contagem |

## 🟢 GATE TELA A TELA / 0159 — Tela Inicial Menu Principal (FECHADO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 FECHADO |
| Track | safe_track |
| Readback | [`0159-rb-onda-38-2-29-tela-inicial-menu-principal.json`](../readbacks/0159-rb-onda-38-2-29-tela-inicial-menu-principal.json) — **human_status: confirmed** |
| Hearback | [`0159-rb-onda-38-2-29-tela-inicial-menu-principal-confirmed.json`](../hearbacks/0159-rb-onda-38-2-29-tela-inicial-menu-principal-confirmed.json) |
| ERP | [`0159-exec-onda-38-2-29-tela-inicial-menu-principal.json`](../results/0159-exec-onda-38-2-29-tela-inicial-menu-principal.json) — `completed` |
| Tecnico | [`0159_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_29_tela_inicial_menu_principal/0159_TECNICO.md) |
| Procedimento | [`0159_PROCEDIMENTO_IMPORT.md`](../../auditoria/03_ondas/onda_38_2_29_tela_inicial_menu_principal/0159_PROCEDIMENTO_IMPORT.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_29_TELA_INICIAL.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_29_TELA_INICIAL.txt) |
| Decisao aplicada | Test-only + build label; sem alterar `Menu_Principal.frm`, `.frx`, `Auto_Open.bas` ou fluxos destrutivos |
| Build | `293e44c+ONDA38.2.29-FIX1-TELA-INICIAL` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_29_TELA_INICIAL", "293e44c+ONDA38.2.29-FIX1-TELA-INICIAL"` |
| Gate inicial observado | Import `M=3 | F=0 | err=0 | skip=0`; compile limpo; `TV2_20260607_094429` com `OK=12 | FALHA=2 | MANUAL=0` por tokens de `Auto_Open` fora do delta |
| Gate Fix1 observado | Import `M=3 | F=0 | err=0 | skip=0`; compile limpo; `TV2_20260607_101426` com `OK=14 | FALHA=0 | MANUAL=0`; sem CSV de falhas |
| Pos-import esperado | `M=3 | F=0 | err=0 | skip=0`; compile limpo; `TV2_RunTelaInicial` com `OK=14 | FALHA=0 | MANUAL=0` |
| Nao tocar | `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`, `ThisWorkbook`, `Menu_Principal.frm/.frx`, freeze V206; nao rodar VCR neste microdelta |
| Veredito atual | Fechado; proxima onda deve ter novo readback |

## 🟢 GATE TELA A TELA / 0158 — Configuracoes Iniciais botoes e menus (FECHADO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 FECHADO |
| Track | safe_track |
| Readback | [`0158-rb-onda-38-2-28-configuracoes-iniciais-botoes-menus.json`](../readbacks/0158-rb-onda-38-2-28-configuracoes-iniciais-botoes-menus.json) — **human_status: confirmed** |
| Hearback | [`0158-rb-onda-38-2-28-configuracoes-iniciais-botoes-menus-confirmed.json`](../hearbacks/0158-rb-onda-38-2-28-configuracoes-iniciais-botoes-menus-confirmed.json) |
| ERP | [`0158-exec-onda-38-2-28-configuracoes-iniciais-botoes-menus.json`](../results/0158-exec-onda-38-2-28-configuracoes-iniciais-botoes-menus.json) — `completed` |
| Tecnico | [`0158_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_28_configuracoes_iniciais_botoes_menus/0158_TECNICO.md) |
| Procedimento | [`0158_PROCEDIMENTO_IMPORT.md`](../../auditoria/03_ondas/onda_38_2_28_configuracoes_iniciais_botoes_menus/0158_PROCEDIMENTO_IMPORT.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_28_CONFIG_BOTOES_MENUS.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_28_CONFIG_BOTOES_MENUS.txt) |
| Decisao aplicada | Test-only + build label; sem alterar `.frm/.frx`; fluxos destrutivos validados por contrato estatico/confirmacao, nao por execucao automatica |
| Build | `293e44c+ONDA38.2.28-CONFIG-BOTOES-MENUS` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_28_CONFIG_BOTOES_MENUS", "293e44c+ONDA38.2.28-CONFIG-BOTOES-MENUS"` |
| Pos-import esperado | `M=2 | F=0 | err=0 | skip=0`; compile limpo; `TV2_RunTelaConfiguracoesIniciais` com `OK=9 | FALHA=0 | MANUAL=0` |
| Import V3 observado | `M=2 | F=0 | err=0 | skip=0`; backup `20260607_005702-V3-FULL` |
| Compile observado | Limpo, reportado pelo operador |
| Teste dirigido | `TV2_20260607_005745` — `OK=9 | FALHA=0 | MANUAL=0`; sem CSV de falhas |
| Nao tocar | `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`, `ThisWorkbook`, freeze V206; nao rodar VCR neste microdelta |
| Veredito atual | Etapa fechada; proximo delta exige novo readback |

## 🔵 HANDOFF / 0157 — Codex para Codex: Configuracoes Iniciais tela a tela (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🔵 HBN HANDOFF READY |
| Track | fast_track |
| Readback | [`0157-rb-handoff-codex-configuracoes-iniciais-tela-a-tela.json`](../readbacks/0157-rb-handoff-codex-configuracoes-iniciais-tela-a-tela.json) — **human_status: confirmed** |
| Hearback | [`0157-rb-handoff-codex-configuracoes-iniciais-tela-a-tela-confirmed.json`](../hearbacks/0157-rb-handoff-codex-configuracoes-iniciais-tela-a-tela-confirmed.json) |
| ERP | [`0157-exec-handoff-codex-configuracoes-iniciais-tela-a-tela.json`](../results/0157-exec-handoff-codex-configuracoes-iniciais-tela-a-tela.json) |
| Handoff | [`20260606-2325-handoff-fim-sessao-codex-bastao-codex-para-codex.md`](../messages/20260606-2325-handoff-fim-sessao-codex-bastao-codex-para-codex.md) |
| Prompt de retomada | [`128_PROMPT_RETOMADA_CODEX_CONFIG_INICIAL_TELA_A_TELA.md`](../../auditoria/00_status/128_PROMPT_RETOMADA_CODEX_CONFIG_INICIAL_TELA_A_TELA.md) |
| Proposta USEHBN | [`20260606-2325-configuracoes-iniciais-design-first-handoff.md`](../protocol-evolutions/20260606-2325-configuracoes-iniciais-design-first-handoff.md) |
| Proxima acao | Cumprida pela 0158; qualquer novo delta exige novo readback |
| Diretriz-chave | Defeito geometrico de UserForm deve preferir designer/export; regra/evento deve ter codigo + teste V2 |

## 🟢 GATE TELA A TELA / 0156 — Configuracoes Iniciais layout design fix1 (FECHADO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 FECHADO |
| Track | safe_track |
| Readback | [`0156-rb-onda-38-2-27-fix1-config-layout-design.json`](../readbacks/0156-rb-onda-38-2-27-fix1-config-layout-design.json) — **human_status: confirmed** |
| Hearback | [`0156-rb-onda-38-2-27-fix1-config-layout-design-confirmed.json`](../hearbacks/0156-rb-onda-38-2-27-fix1-config-layout-design-confirmed.json) |
| Tecnico | [`0156_FIX1_DESIGN_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_27_config_help_vcr/0156_FIX1_DESIGN_TECNICO.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_27_CONFIG_LAYOUT_FIX1.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_27_CONFIG_LAYOUT_FIX1.txt) |
| Motivo | Diagnostico humano isolou causa raiz: label `suspender por` sobrepunha o campo numerico, logo a correcao correta e de design |
| Decisao aplicada | Incorporado `.frm/.frx` exportado de `incoming`; teste dirigido agora reprova label sobreposto ao campo |
| Build | `293e44c+ONDA38.2.27-CONFIG-LAYOUT-fix1` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_27_CONFIG_LAYOUT_FIX1", "293e44c+ONDA38.2.27-CONFIG-LAYOUT-fix1"` |
| Pos-import esperado | `M=2 | F=1 | err=0 | skip=0`; compile limpo; `TV2_RunTelaConfiguracoesIniciais` com `OK=3 | FALHA=0 | MANUAL=0` |
| Import V3 observado | `M=2 | F=1 | err=0 | skip=0`; backup `20260606_230924-V3-FULL` |
| Compile observado | Limpo, reportado pelo operador |
| Teste dirigido | `TV2_20260606_231033` — `OK=3 | FALHA=0 | MANUAL=0`; sem CSV de falhas |
| Validacao manual | Mauricio confirmou: campo aceita clique, edicao e salvamento |
| Nao tocar | `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`, `ThisWorkbook`, freeze V206 |
| Veredito atual | Etapa fechada; seguir em novo chat para botoes, menus e submenus |

## 🟡 GATE TELA A TELA / 0155 — Configuracoes Iniciais campo dias/Tab fix1 (SUPERSEDIDA)

| Campo | Valor |
|---|---|
| Sinal | 🔴 SUSPENSA ANTES DE IMPORTACAO |
| Track | safe_track |
| Readback | [`0155-rb-onda-38-2-27-fix1-config-campo-tab.json`](../readbacks/0155-rb-onda-38-2-27-fix1-config-campo-tab.json) — **human_status: confirmed** |
| Hearback | [`0155-rb-onda-38-2-27-fix1-config-campo-tab-confirmed.json`](../hearbacks/0155-rb-onda-38-2-27-fix1-config-campo-tab-confirmed.json) |
| Tecnico | [`0155_FIX1_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_27_config_help_vcr/0155_FIX1_TECNICO.md) |
| Manifesto | Removido para evitar import acidental |
| Motivo | A 0154 passou no teste dirigido, mas o gate humano mostrou que o campo `suspender por 30 dia(s)` ainda estava dificil de editar e fora da navegacao Tab esperada |
| Decisao aplicada | Supersedida pela 0156; runtime magic removido |
| Build | `293e44c+ONDA38.2.27-CONFIG-HELP-VCR-fix1` |
| Import V3 | NAO IMPORTAR |
| Pos-import esperado | NAO APLICAVEL |
| Validacao manual | Clicar, editar e navegar por Tab no campo `suspender por 30 dia(s)` |
| Nao tocar | `.frx`, `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`, `ThisWorkbook`, freeze V206 |
| Veredito atual | Nao usar; substituida por 0156 |

## 🟡 GATE TELA A TELA / 0154 — Configuracoes Iniciais, Ajuda HBN e VCR

| Campo | Valor |
|---|---|
| Sinal | 🟡 IMPORT/COMPILE/TV2 VERDE; GATE VISUAL ABRIU FIX1 0155 |
| Track | safe_track |
| Readback | [`0154-rb-onda-38-2-27-config-help-vcr.json`](../readbacks/0154-rb-onda-38-2-27-config-help-vcr.json) — **human_status: confirmed** |
| Hearback | [`0154-rb-onda-38-2-27-config-help-vcr-confirmed.json`](../hearbacks/0154-rb-onda-38-2-27-config-help-vcr-confirmed.json) |
| Tecnico | [`0154_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_27_config_help_vcr/0154_TECNICO.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_27_CONFIG_HELP_VCR.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_27_CONFIG_HELP_VCR.txt) |
| Motivo | Mauricio aprovou a atuacao tela a tela e corrigiu a nomenclatura: Validacao Completa da Release deve ser VCR; `.csv` e apenas formato de evidencia |
| Decisao aplicada | Central de Testes mostra VCR; alias `CT_ValidarRelease_Completa`; `TxtMesesSuspensao` fica editavel em runtime e semanticamente representa dias por recusa/prazo |
| Build | `293e44c+ONDA38.2.27-CONFIG-HELP-VCR` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_27_CONFIG_HELP_VCR", "293e44c+ONDA38.2.27-CONFIG-HELP-VCR"` |
| Pos-import esperado | `M=4 | F=1 | err=0 | skip=0`; compile limpo; `TV2_RunTelaConfiguracoesIniciais` com `OK=3 | FALHA=0 | MANUAL=0` |
| Help | `docs/help/hbn/configuracoes-iniciais.html` abre pelo botao Ajuda da tela |
| Cadencia | VCR demora mais de 1h no fluxo atual; usar teste dirigido por tela e reservar VCR para checkpoint forte |
| Nao tocar | `.frx`, `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`, `ThisWorkbook`, freeze V206 |
| Gate humano | Importou, compilou e `TV2_20260606_212617` retornou `OK=3 | FALHA=0 | MANUAL=0`; porem campo `suspender por 30 dia(s)` continuou ruim para clique/edicao/Tab |
| Veredito atual | 0154 parcialmente validada; 0155 corrige a acessibilidade real do campo antes de seguir tela a tela |

## 🟡 GATE PRE-TELA / 0153 — punicoes do rodizio em dias (NOVO)

| Campo | Valor |
|---|---|
| Sinal | ✅ VALIDADO POR IMPORT/COMPILE/TV2/RVS |
| Track | safe_track |
| Readback | [`0153-rb-onda-38-2-26-punicoes-em-dias.json`](../readbacks/0153-rb-onda-38-2-26-punicoes-em-dias.json) — **human_status: confirmed** |
| Hearback | [`0153-rb-onda-38-2-26-punicoes-em-dias-confirmed.json`](../hearbacks/0153-rb-onda-38-2-26-punicoes-em-dias-confirmed.json) |
| Tecnico | [`0153_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_26_punicoes_em_dias/0153_TECNICO.md) |
| ERP | [`0153-exec-onda-38-2-26-punicoes-em-dias.json`](../results/0153-exec-onda-38-2-26-punicoes-em-dias.json) — `validated_human_gate_passed` |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_26_PUNICOES_EM_DIAS.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_26_PUNICOES_EM_DIAS.txt) |
| Motivo | Mauricio pediu rigor maximo na regra de strikes/punicoes e apontou que a interface podia dizer zero dias enquanto o codigo usava fallback inadequado |
| Decisao aplicada | Todas as suspensoes usam dias: strike, recusa, expiracao e manual; meses ficam apenas como legado de migracao idempotente |
| Build | `293e44c+ONDA38.2.26-PUNICOES-DIAS-fix4` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_26_PUNICOES_EM_DIAS_FIX4", "293e44c+ONDA38.2.26-PUNICOES-DIAS-fix4"` |
| Primeiro import | `M=14 | F=3 | err=0 | skip=0`; compile falhou por chamada fortemente tipada a membro ausente em `Credencia_Empresa` |
| Fix1 aplicado | `Teste_V2_Roteiros` chama o helper FT4 por `CallByName` em `Object`, eliminando dependencia em tempo de compilacao |
| Fix1 import | `M=14 | F=3 | err=0 | skip=0`; compile falhou em chamada direta a `AutoOpen_UltimaProtecaoMarcadorExecutadaEm` |
| Fix2 aplicado | `Teste_V2_Roteiros` chama funcoes `AutoOpen_*` por `Application.Run`; se ausentes, teste BL4 registra falha em runtime sem quebrar compile |
| Fix2 import | `M=14 | F=3 | err=0 | skip=0`; compile falhou em chamada direta a `Util_VerificarProtecaoPersistenteAposAbertura` |
| Fix3 aplicado | `Teste_V2_Roteiros` chama `Util_VerificarProtecaoPersistenteAposAbertura` por wrapper `Application.Run` em todos os pontos BL4 |
| Fix3 import | `M=14 | F=3 | err=0 | skip=0`; compile falhou em chamada direta a `frm.TV2_AvaliacaoDemandanteNaLista` |
| Fix4 aplicado | `Teste_V2_Roteiros` chama membros TV2 de `Menu_Principal` por wrappers `CallByName`, sem importar `Menu_Principal.frm` |
| Fix4 import | `M=14 | F=3 | err=0 | skip=0`; backup `20260606_193609-V3-FULL` |
| Compile fix4 | Limpo, reportado pelo operador |
| Relatorios | Novo `RPT_RODIZIO_STATUS`; relatorios de empresa/servico e OS/empresa mostram STATUS_GLOBAL, DIAS_RESTANTES, RETORNO_PREVISTO e PARTICIPA_RODIZIO |
| Teste dirigido | `TV2_20260606_193709` — `OK=8 | FALHA=0 | MANUAL=0` |
| RVS | `VR_20260606_193911` — APROVADO com `PunicoesDias=8/0` |
| CSV RVS | `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260606_193911.csv` |
| Nao tocar | `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`, `ThisWorkbook`, freeze V206 |
| Veredito atual | 0153 validada; liberar proximo readback curto antes do GATE 3 tela a tela |

## 🟡 GATE PRE-TELA / 0152 — RVS inclui impressao residual (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟡 PACOTE PRONTO / GATE HUMANO PENDENTE |
| Track | safe_track |
| Readback | [`0152-rb-onda-38-2-25-rvs-inclui-impressao-residual.json`](../readbacks/0152-rb-onda-38-2-25-rvs-inclui-impressao-residual.json) — **human_status: confirmed** |
| Hearback | [`0152-rb-onda-38-2-25-rvs-inclui-impressao-residual-confirmed.json`](../hearbacks/0152-rb-onda-38-2-25-rvs-inclui-impressao-residual-confirmed.json) |
| Tecnico | [`0152_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_25_rvs_inclui_impressao_residual/0152_TECNICO.md) |
| ERP | [`0152-exec-onda-38-2-25-rvs-inclui-impressao-residual.json`](../results/0152-exec-onda-38-2-25-rvs-inclui-impressao-residual.json) — `package_ready_gate_pending` |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_25_RVS_IMPRESSAO_RESIDUAL.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_25_RVS_IMPRESSAO_RESIDUAL.txt) |
| Motivo | Mauricio pediu um teste completo antes da atuacao tela a tela e perguntou se os novos testes deveriam entrar no RVS geral |
| Decisao aplicada | Sim: `CT_ValidarRelease_SextetoMinimo` passa a executar `TV2_RunImpressaoResidual False, True` como etapa `V2_IMPRESSAO_RESIDUAL` |
| Build | `e157221+ONDA38.2.25-RVS-IMP-RES` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_25_RVS_IMPRESSAO_RESIDUAL", "e157221+ONDA38.2.25-RVS-IMP-RES"` |
| Nao tocar | UserForms, `.frx`, `Auto_Open.bas`, `ThisWorkbook`, `Mod_Types.bas`, `Importador_V3.bas`, `Teste_V2_Engine.bas`, `Teste_V2_Roteiros.bas`, `Teste_V2_Impressao_Residual.bas`, template workbook manual |
| Gate humano esperado | Importador V3 `M=2 | F=0 | err=0`; compile limpo; `CT_ValidarRelease_SextetoMinimo` APROVADO com `ImpressaoResidual=7/0` |
| Veredito atual | Pacote pronto; nao iniciar GATE 3 tela a tela ate o RVS ampliado passar |

## 🟢 GATE 2 / 0151 VALIDADO — impressao residual Quant./borda code-only (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 GATE HUMANO VERDE |
| Track | safe_track |
| Readback | [`0151-rb-onda-38-2-24-impressao-residual-quant-borda-codeonly.json`](../readbacks/0151-rb-onda-38-2-24-impressao-residual-quant-borda-codeonly.json) — **human_status: confirmed** |
| Hearback | [`0151-rb-onda-38-2-24-impressao-residual-quant-borda-codeonly-confirmed.json`](../hearbacks/0151-rb-onda-38-2-24-impressao-residual-quant-borda-codeonly-confirmed.json) |
| Tecnico | [`0151_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_24_impressao_residual_quant_borda_codeonly/0151_TECNICO.md) |
| ERP | [`0151-exec-onda-38-2-24-impressao-residual-quant-borda-codeonly.json`](../results/0151-exec-onda-38-2-24-impressao-residual-quant-borda-codeonly.json) — `completed` |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_24_IMPRESSAO_RESIDUAL_QUANT_BORDA_CODEONLY.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_24_IMPRESSAO_RESIDUAL_QUANT_BORDA_CODEONLY.txt) |
| Origem | Handoff 127 / GATE 2: `Quant.` imprimia `1,` por `NumberFormatLocal "0,##"`; `IMP_AVALIA!A25:A45` precisava borda externa esquerda media se regra visual final exigir |
| Decisao aplicada | `AplicarFormatoQuantidade` usa formato inteiro `"0"`; helper de borda aceita peso; `A25:A45` recebe `xlMedium` na borda esquerda; teste V2 sobe para 7 asserts |
| Build | `e157221+ONDA38.2.24-IMP-RES-QTD-BORDA` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_24_IMPRESSAO_RESIDUAL_QUANT_BORDA_CODEONLY", "e157221+ONDA38.2.24-IMP-RES-QTD-BORDA"` |
| Nao tocar | UserForms, `.frx`, `Auto_Open.bas`, `ThisWorkbook`, `Mod_Types.bas`, `Importador_V3.bas`, `Teste_V2_Engine.bas`, `Teste_V2_Roteiros.bas`, template workbook manual |
| Teste dirigido | `TV2_RunImpressaoResidual` esperado `OK=7 | FALHA=0 | MANUAL=0` |
| Gate humano | Importador V3 OK: `modo=Estabilizado`, `dryRun=Falso`, `M=3`, `F=0`, `err=0`, `skip=0`; backup `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260606_110957-V3-FULL`; compile limpo; `TV2_20260606_111039` retornou `OK=7 | FALHA=0 | MANUAL=0`; sem CSV de falhas |
| Veredito atual | 38.2.24 validada por import, compile e V2 dirigido; proximo passo e GATE 3 tela a tela |

## 🟢 GATE 0 / 0150 — consolidacao do working tree V206 e ponte arquiteto 0114-0117 (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 GATE 0 CONSOLIDADO |
| Track | fast_track historica com codigo ja validado por gates humanos anteriores |
| Readback | [`0150-rb-onda-gate0-consolidacao-working-tree-v206.json`](../readbacks/0150-rb-onda-gate0-consolidacao-working-tree-v206.json) — **human_status: confirmed** |
| Hearback | [`0150-gate0-consolidacao-working-tree-v206.json`](../hearbacks/0150-gate0-consolidacao-working-tree-v206.json) |
| Origem | Prompt canônico do doc 127 + ponte `.hbn/messages/20260605-1950-ponte-estado-protocolo-para-codex.md` |
| Commits criados | `d0fccbe` contratos HBN 38.2/0150; `a27492b` codigo+espelho VBA; `b2c18ef` docs/evidencias; `98308e8` relay/ERPs |
| Onda arquiteto 0114 | `5ad07fe` — knowledge 0021: guards em sandbox informativos; commit no Terminal do operador |
| Onda arquiteto 0115 | `8204fe9` — knowledge 0022 FIREWALL: workflows automaticos so fast_track; escrita safe_track humano-aplicada |
| Onda arquiteto 0116 | `5b5b9a7` — CI hbn-guards: contratos ratchet + scope-lock por commit |
| Onda arquiteto 0117 | `7cff187` — organizacao, doc 126 V207, doc 127 handoff Codex |
| Micro-onda 0149 | `e2b8700` — epoca do ratchet; contratos 0149+ estritos no CI |
| Incoming | `incoming/workbook_ref_20260602_compila_bo330_v1falha/` movido para `auditoria/04_evidencias/V12.0.0206/workbook_ref_20260602_compila_bo330_v1falha/` como evidencia; nao e origem de importacao |
| Checagem G7/G8 | `python3 local-ai/scripts/publicar_vba_import_v2.py check --verbose` retornou `OK — vba_import 100% sincronizado com src/vba` apos entrada explicita de `UX_IniciarSistema` no mapa |
| CI | Primeiro `hbn-guards-ci` do GATE 0 verde: run `27063539868`, SHA `98308e8d4dfb2ed92c87ded2a38f4a432b91b409` |
| Proxima acao apos GATE 0 | GATE 1 executado e verde em 2026-06-06; seguir para GATE 2/0151 somente com novo readback e hearback |

## ✅ HBN ACTIVE — CODEX ASSUMIU BASTÃO V206 / ONDA 38.2.3 (NOVO)

| Campo | Valor |
|---|---|
| Sinal | ✅ HBN ACTIVE |
| Papel | Codex implementador principal |
| Onda | 38.2.3 — AT-3 Svc_PreOS / Repo_PreOS |
| Readback | [`0114-rb-onda-38-2-3-at1-gerador-codeonly.json`](../readbacks/0114-rb-onda-38-2-3-at1-gerador-codeonly.json) — **human_status: confirmed** |
| Readback AT-2 | [`0114-rb-onda-38-2-3-at2-diagnostico-fnew5.json`](../readbacks/0114-rb-onda-38-2-3-at2-diagnostico-fnew5.json) — **human_status: confirmed** |
| Readback AT-3 | [`0114-rb-onda-38-2-3-at3-svc-preos.json`](../readbacks/0114-rb-onda-38-2-3-at3-svc-preos.json) — **human_status: confirmed** |
| Readback AT-3 Fix1 | [`0115-rb-onda-38-2-3-at3-fix1-compile-preos-wrapper.json`](../readbacks/0115-rb-onda-38-2-3-at3-fix1-compile-preos-wrapper.json) — **human_status: confirmed** |
| Readback AT-3 Fix2 | [`0116-rb-onda-38-2-3-at3-fix2-preos-integrity-assert.json`](../readbacks/0116-rb-onda-38-2-3-at3-fix2-preos-integrity-assert.json) — **human_status: confirmed** |
| Readback AT-3 Fix3 | [`0117-rb-onda-38-2-3-at3-fix3-preos-write-normalizacao.json`](../readbacks/0117-rb-onda-38-2-3-at3-fix3-preos-write-normalizacao.json) — **human_status: confirmed** |
| Readback GATE-A4 | [`0118-rb-onda-38-2-3-gate-a4-import-uso-prolongado.json`](../readbacks/0118-rb-onda-38-2-3-gate-a4-import-uso-prolongado.json) — **human_status: confirmed** |
| Readback evidencias A4 | [`0119-rb-onda-38-2-3-gate-a4-rvs-evidencias.json`](../readbacks/0119-rb-onda-38-2-3-gate-a4-rvs-evidencias.json) — **human_status: confirmed** |
| Readback 38.2.4 | [`0120-rb-onda-38-2-4-integridade-estado.json`](../readbacks/0120-rb-onda-38-2-4-integridade-estado.json) — **human_status: confirmed** |
| Readback 38.2.5 | [`0121-rb-onda-38-2-5-ui-regras-negocio.json`](../readbacks/0121-rb-onda-38-2-5-ui-regras-negocio.json) — **human_status: confirmed** |
| Readback 38.2.6 | [`0122-rb-onda-38-2-6-integridade-impressao.json`](../readbacks/0122-rb-onda-38-2-6-integridade-impressao.json) — **human_status: confirmed** |
| Readback 38.2.7 | [`0123-rb-onda-38-2-7-leitura-exibicao.json`](../readbacks/0123-rb-onda-38-2-7-leitura-exibicao.json) — **human_status: confirmed** |
| Readback 38.2.8 | [`0124-rb-onda-38-2-8-config-baseline-v2.json`](../readbacks/0124-rb-onda-38-2-8-config-baseline-v2.json) — **human_status: confirmed** |
| Readback 38.2.9 | [`0125-rb-onda-38-2-9-config-snapshot-v2.json`](../readbacks/0125-rb-onda-38-2-9-config-snapshot-v2.json) — **human_status: confirmed** |
| Readback 38.2.10 | [`0126-rb-onda-38-2-10-higiene-repositorio.json`](../readbacks/0126-rb-onda-38-2-10-higiene-repositorio.json) — **human_status: confirmed** |
| Readback 38.2.11 | [`0127-rb-onda-38-2-11-sync-hbn-pos-commit.json`](../readbacks/0127-rb-onda-38-2-11-sync-hbn-pos-commit.json) — **human_status: confirmed** |
| Readback 38.2.12 | [`0128-rb-onda-38-2-12-performance-ux-basica.json`](../readbacks/0128-rb-onda-38-2-12-performance-ux-basica.json) — **human_status: confirmed** |
| Readback 38.2.13 | [`0129-rb-onda-38-2-13-auditoria-cruzada-consolidada.json`](../readbacks/0129-rb-onda-38-2-13-auditoria-cruzada-consolidada.json) — **human_status: confirmed** |
| Readback 38.2.14 | [`0130-rb-onda-38-2-14-behavioralizacao-c1.json`](../readbacks/0130-rb-onda-38-2-14-behavioralizacao-c1.json) — **human_status: confirmed** |
| Readback 38.2.15 | [`0131-rb-onda-38-2-15-ft4-credenciamento-lote.json`](../readbacks/0131-rb-onda-38-2-15-ft4-credenciamento-lote.json) — **human_status: confirmed** |
| Readback 38.2.16 | [`0132-rb-onda-38-2-16-bl4-protecao-persistente.json`](../readbacks/0132-rb-onda-38-2-16-bl4-protecao-persistente.json) — **human_status: confirmed** |
| Readback 38.2.16-fix1 | [`0133-rb-onda-38-2-16-fix1-bl4-autoopen-marker.json`](../readbacks/0133-rb-onda-38-2-16-fix1-bl4-autoopen-marker.json) — **human_status: confirmed** |
| Readback 38.2.17 | [`0134-rb-onda-38-2-17-formularios-avaliacao-demandante.json`](../readbacks/0134-rb-onda-38-2-17-formularios-avaliacao-demandante.json) — **human_status: confirmed** |
| Readback 38.2.17-fix1 | [`0135-rb-onda-38-2-17-fix1-form-avaliacao-compile-crash.json`](../readbacks/0135-rb-onda-38-2-17-fix1-form-avaliacao-compile-crash.json) — **human_status: pending / supersedido operacionalmente** |
| Readback 38.2.18 | [`0136-rb-onda-38-2-18-recuperacao-bo330-diagnostico.json`](../readbacks/0136-rb-onda-38-2-18-recuperacao-bo330-diagnostico.json) — **human_status: confirmed** |
| Readback 38.2.18-fix1 | [`0137-rb-onda-38-2-18-fix1-bo330-status-canonico.json`](../readbacks/0137-rb-onda-38-2-18-fix1-bo330-status-canonico.json) — **human_status: confirmed** |
| Readback 38.2.19 | [`0138-rb-onda-38-2-19-form-avaliacao-modulos-primeiro.json`](../readbacks/0138-rb-onda-38-2-19-form-avaliacao-modulos-primeiro.json) — **human_status: confirmed** |
| Readback 38.2.19-fix1 | [`0139-rb-onda-38-2-19-fix1-form-avaliacao-idsiguais.json`](../readbacks/0139-rb-onda-38-2-19-fix1-form-avaliacao-idsiguais.json) — **human_status: confirmed** |
| Readback 38.2.20 | [`0140-rb-onda-38-2-20-ux-iniciar-sistema-codeonly.json`](../readbacks/0140-rb-onda-38-2-20-ux-iniciar-sistema-codeonly.json) — **human_status: confirmed / validada** |
| Readback 38.2.21 | [`0141-rb-onda-38-2-21-formularios-residuais-codeonly.json`](../readbacks/0141-rb-onda-38-2-21-formularios-residuais-codeonly.json) — **human_status: confirmed / validada** |
| Readback 38.2.22 | [`0142-rb-onda-38-2-22-auditoria-cruzada-0136-0141-impressao.json`](../readbacks/0142-rb-onda-38-2-22-auditoria-cruzada-0136-0141-impressao.json) — **human_status: confirmed** |
| Readback 38.2.23 | [`0143-rb-onda-38-2-23-impressao-residual-codeonly-template.json`](../readbacks/0143-rb-onda-38-2-23-impressao-residual-codeonly-template.json) — **human_status: confirmed / import+compile ok, TV2 falhou por falso negativo** |
| Readback 38.2.23-fix1 | [`0144-rb-onda-38-2-23-fix1-impressao-residual-testeonly.json`](../readbacks/0144-rb-onda-38-2-23-fix1-impressao-residual-testeonly.json) — **human_status: confirmed / validada** |
| Mensagem | [`.hbn/messages/20260527-1408-codex-assumiu-bastao-v206.md`](../messages/20260527-1408-codex-assumiu-bastao-v206.md) |
| Entrega GATE-A1 | [`.hbn/proposals/0013-codex-at1-gerador-codeonly.md`](../proposals/0013-codex-at1-gerador-codeonly.md) |
| Auditorias GATE-A1 | [Opus 0014](../proposals/0014-opus-auditoria-gate-a1-onda-38-2-3.md) + [Antigravity 0015](../proposals/0015-antigravity-auditoria-gate-a1-onda-38-2-3.md) — aprovadas |
| Entrega GATE-A2 | [Codex 0016](../proposals/0016-codex-at2-diagnostico-fnew5.md) + [Opus 0017](../proposals/0017-opus-auditoria-gate-a2-onda-38-2-3.md) + [Antigravity 0018](../proposals/0018-antigravity-auditoria-gate-a2-onda-38-2-3.md) + [Opus reauditoria 0019](../proposals/0019-opus-reauditoria-gate-a2-onda-38-2-3.md) — aprovadas |
| Entrega GATE-A3 | [Opus 0020](../proposals/0020-opus-auditoria-gate-a3-onda-38-2-3.md) + [Antigravity 0021](../proposals/0021-antigravity-auditoria-gate-a3-onda-38-2-3.md) — aprovadas sem BLOQUEADORES |
| Head observado | `27237e4` — doc-only posterior a `ce5879e`; predecessor de codigo V206 preservado |
| Head observado atual | `e157221` — Performance/UX basica 38.2.12; 38.2.13 e doc-only posterior |
| Proxima acao | GATE 2/0151 para residual final de impressao code-only, com novo readback e hearback. |

## 🟢 ONDA 38.2.23-FIX1 VALIDADA — impressao residual teste-only (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 GATE HUMANO VERDE |
| Track | safe_track |
| Readback | [`0144-rb-onda-38-2-23-fix1-impressao-residual-testeonly.json`](../readbacks/0144-rb-onda-38-2-23-fix1-impressao-residual-testeonly.json) — **human_status: confirmed** |
| Hearback | [`0144-rb-onda-38-2-23-fix1-impressao-residual-testeonly-confirmed.json`](../hearbacks/0144-rb-onda-38-2-23-fix1-impressao-residual-testeonly-confirmed.json) |
| Tecnico | [`0144_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_23_fix1_impressao_residual_testeonly/0144_TECNICO.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_23_FIX1_IMPRESSAO_RESIDUAL_TESTEONLY.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_23_FIX1_IMPRESSAO_RESIDUAL_TESTEONLY.txt) |
| ERP | [`0144-exec-onda-38-2-23-fix1-impressao-residual-testeonly.json`](../results/0144-exec-onda-38-2-23-fix1-impressao-residual-testeonly.json) — `completed` |
| Origem | 0143 importou e compilou; `TV2_RunImpressaoResidual` retornou `OK=5 | FALHA=1` em `IR_03` |
| Diagnostico | CSV `TesteV2_IMPRESSAO_RESIDUAL_Falhas_TV2_20260603_121844.csv`: `L9_VISUAL=esperado`, `MERGE_L9=Verdadeiro`, `L8=` vazio |
| Decisao aplicada | Fix test-only: `IR_03` valida `L9:P15` visual; `L8` permanece apenas em detalhes diagnosticos |
| Build | `e157221+ONDA38.2.23-FIX1-IMP-RES-TEST` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_23_FIX1_IMPRESSAO_RESIDUAL_TESTEONLY", "e157221+ONDA38.2.23-FIX1-IMP-RES-TEST"` |
| Nao tocar | `Preencher.bas`, `Auto_Open.bas`, `ThisWorkbook`, `Mod_Types.bas`, `Importador_V3.bas`, UserForms, `.frx`, `Teste_V2_Engine`, `Teste_V2_Roteiros` |
| Teste dirigido | `TV2_RunImpressaoResidual` esperado `OK=6 | FALHA=0 | MANUAL=0` |
| Gate humano | Importador V3 OK: `modo=Estabilizado`, `dryRun=Falso`, `M=2`, `F=0`, `err=0`, `skip=0`; backup `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260606_104016-V3-FULL`; compile limpo; `TV2_20260606_104057` retornou `OK=6 | FALHA=0 | MANUAL=0`; sem CSV de falhas |
| Veredito atual | 38.2.23-fix1 validada por import, compile e V2 dirigido; proximo passo e abrir GATE 2/0151 se houver residual final de impressao a corrigir |

## 🟡 ONDA 38.2.23 IMPLEMENTADA — impressao residual code-only/template (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🔴 GATE HUMANO FALHOU NO V2 DIRIGIDO |
| Track | safe_track |
| Readback | [`0143-rb-onda-38-2-23-impressao-residual-codeonly-template.json`](../readbacks/0143-rb-onda-38-2-23-impressao-residual-codeonly-template.json) — **human_status: confirmed** |
| Hearback | [`0143-rb-onda-38-2-23-impressao-residual-codeonly-template-confirmed.json`](../hearbacks/0143-rb-onda-38-2-23-impressao-residual-codeonly-template-confirmed.json) |
| Tecnico | [`0143_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_23_impressao_residual_codeonly_template/0143_TECNICO.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_23_IMPRESSAO_RESIDUAL_CODEONLY_TEMPLATE.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_23_IMPRESSAO_RESIDUAL_CODEONLY_TEMPLATE.txt) |
| Origem | Auditoria 0142 fechou dois bloqueadores de impressao e dois residuos visuais nos PDFs 001/002/003 |
| Bloqueadores | `IMP_AVALIA` demandante vazio por escrita em `L8` enquanto o template visual usa `L9:P15`; `EMITE_OS` total final visual em `N63:P63` imprime `-` apesar de item com R$ 100,00 |
| Marginais | Bordas cinza/descontinuas em `EMITE_PREOS!C9/C11`; borda esquerda ausente em `IMP_AVALIA!A25:A45` |
| Diretriz | Code-only primeiro: `Preencher.bas`, `App_Release`, modulo V2 isolado e manifesto V3; parar se exigir edicao direta de workbook/template |
| Nao tocar | `Auto_Open.bas`, `ThisWorkbook`, `Mod_Types.bas`, `Importador_V3.bas`, `Menu_Principal.frm`, `Credencia_Empresa.frm`, qualquer UserForm, `.frx`, `Teste_V2_Engine`, `Teste_V2_Roteiros` |
| Build | `e157221+ONDA38.2.23-IMP-RES-CODE` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_23_IMPRESSAO_RESIDUAL_CODEONLY_TEMPLATE", "e157221+ONDA38.2.23-IMP-RES-CODE"` |
| Teste dirigido | `TV2_RunImpressaoResidual` retornou `OK=5 | FALHA=1 | MANUAL=0` em `TV2_20260603_121844` |
| Falha | `IR_03_AVALIACAO_DEMANDANTE_L9P15`: falso negativo test-only; `L9_VISUAL=esperado`, `MERGE_L9=Verdadeiro`, `L8=` vazio |
| Veredito atual | Correcao funcional importou/compilou; gate V2 dirigido sera reexecutado via 0144 fix1 |

## 🟡 ONDA 38.2.22 CONSOLIDADA — auditoria cruzada 0136-0141 e impressao (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟡 FREEZE BLOQUEADO |
| Track | fast_track doc-only |
| Readback | [`0142-rb-onda-38-2-22-auditoria-cruzada-0136-0141-impressao.json`](../readbacks/0142-rb-onda-38-2-22-auditoria-cruzada-0136-0141-impressao.json) — **human_status: confirmed** |
| Hearback | [`0142-rb-onda-38-2-22-auditoria-cruzada-0136-0141-impressao-confirmed.json`](../hearbacks/0142-rb-onda-38-2-22-auditoria-cruzada-0136-0141-impressao-confirmed.json) |
| Tecnico | [`0142_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_22_auditoria_cruzada_0136_0141_impressao/0142_TECNICO.md) |
| ERP | [`0142-exec-onda-38-2-22-auditoria-cruzada-0136-0141-impressao.json`](../results/0142-exec-onda-38-2-22-auditoria-cruzada-0136-0141-impressao.json) — `completed` |
| Motivo | Avaliar qualidade das ondas 136-141 e investigar as causas-raiz de falhas documentais nos PDFs de OS/impressao e a cegueira dos testes dirigidos. |
| Decisao aplicada | Auditoria aponta 2 BLOQUEADORES (Demandante vazio na Avaliacao, OS com total zerado) e 2 MARGINAIS. Identificado que os testes de impressao validam apenas funcoes em memoria e tokens de codigo, e nao celulas reais. A correcao foi aberta e implementada na 38.2.23, ainda pendente de gate humano. |
| Veredito atual | 38.2.22 consolidada; freeze V206 segue bloqueado. |

## 🟢 ONDA 38.2.21 VALIDADA — formularios residuais code-only (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 GATE HUMANO VERDE |
| Track | safe_track |
| Readback | [`0141-rb-onda-38-2-21-formularios-residuais-codeonly.json`](../readbacks/0141-rb-onda-38-2-21-formularios-residuais-codeonly.json) — **human_status: confirmed** |
| Hearback | [`0141-rb-onda-38-2-21-formularios-residuais-codeonly-confirmed.json`](../hearbacks/0141-rb-onda-38-2-21-formularios-residuais-codeonly-confirmed.json) |
| Tecnico | [`0141_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_21_formularios_residuais_codeonly/0141_TECNICO.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_21_FORMULARIOS_RESIDUAIS_CODEONLY.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_21_FORMULARIOS_RESIDUAIS_CODEONLY.txt) |
| ERP | [`0141-exec-onda-38-2-21-formularios-residuais-codeonly.json`](../results/0141-exec-onda-38-2-21-formularios-residuais-codeonly.json) — `completed` |
| Motivo | Retomar estabilizacao dos formularios V206 depois de 0140 verde, sem repetir importacao de UserForm completo que causou crash em 0134/38.2.17 |
| Decisao aplicada | `Svc_Avaliacao.AvaliarOS` resolve demandante por `OS_ID` quando avaliador vier vazio; novo modulo isolado `Teste_V2_Formularios_Residuais` cobre duas OS/demandantes, estado global obsoleto e negativo de ENT_ID inexistente |
| Build | `e157221+ONDA38.2.21-FORM-RES-CODE` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_21_FORMULARIOS_RESIDUAIS_CODEONLY", "e157221+ONDA38.2.21-FORM-RES-CODE"` |
| Nao importar | `Auto_Open.bas`, `ThisWorkbook`, `Menu_Principal.frm`, `Credencia_Empresa.frm`, qualquer UserForm, `.frx`, `Mod_Types`, `Importador_V3`, `Teste_V2_Engine`, `Teste_V2_Roteiros` |
| Gate humano | Importacao executada; compile limpo; `TV2_20260602_234618` retornou `OK=6 | FALHA=0 | MANUAL=0`; sem CSV de falhas |
| Veredito atual | 38.2.21 validada por V2 dirigido; freeze V206 segue bloqueado |

## 🟢 ONDA 38.2.20 VALIDADA — UX IniciarSistema code-only (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 GATE HUMANO VERDE |
| Track | safe_track |
| Readback | [`0140-rb-onda-38-2-20-ux-iniciar-sistema-codeonly.json`](../readbacks/0140-rb-onda-38-2-20-ux-iniciar-sistema-codeonly.json) — **human_status: confirmed** |
| Hearback | [`0140-rb-onda-38-2-20-ux-iniciar-sistema-codeonly-confirmed.json`](../hearbacks/0140-rb-onda-38-2-20-ux-iniciar-sistema-codeonly-confirmed.json) |
| Tecnico | [`0140_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_20_ux_iniciar_sistema_codeonly/0140_TECNICO.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_20_UX_INICIAR_SISTEMA_CODEONLY.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_20_UX_INICIAR_SISTEMA_CODEONLY.txt) |
| ERP | [`0140-exec-onda-38-2-20-ux-iniciar-sistema-codeonly.json`](../results/0140-exec-onda-38-2-20-ux-iniciar-sistema-codeonly.json) — `completed` |
| Motivo | Pedido humano pendente: forma visual na planilha para acionar `IniciarSistema` quando o usuario esta apenas olhando dados |
| Decisao aplicada | Modulo padrao novo `UX_IniciarSistema` para instalar/atualizar atalho visual de planilha via `Shape.OnAction`, mais modulo V2 isolado `Teste_V2_UX_IniciarSistema` |
| Build | `e157221+ONDA38.2.20-UX-INICIAR-CODE` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_20_UX_INICIAR_SISTEMA_CODEONLY", "e157221+ONDA38.2.20-UX-INICIAR-CODE"` |
| Nao importar | `Auto_Open.bas`, `ThisWorkbook`, `Menu_Principal.frm`, qualquer UserForm, `.frx`, `Svc_Avaliacao`, `Preencher`, `Mod_Types`, `Importador_V3`, `Teste_V2_Engine`, `Teste_V2_Roteiros` |
| Gate humano | Importacao executada; compile limpo; `TV2_20260602_205320` retornou `OK=5 | FALHA=0 | MANUAL=0`; sem CSV de falhas |
| Proxima acao operacional | Se a UX for retomada, ajustar instalador para ativar/selecionar o shape; por ora seguir para formularios conforme pedido humano |
| Observacao pos-instalacao | Janela Imediata confirmou `RESULTADO_QA_V2`, `ContarAtalhos=1` e `OnAction=IniciarSistema`; Mauricio localizou o botao em `J1` e confirmou funcionamento |
| Veredito atual | 38.2.20 validada por V2 dirigido; freeze V206 segue bloqueado |

## 🟢 ONDA 38.2.19-FIX1 VALIDADA — form avaliacao IdsIguais no teste (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 GATE HUMANO VERDE |
| Track | safe_track |
| Readback | [`0139-rb-onda-38-2-19-fix1-form-avaliacao-idsiguais.json`](../readbacks/0139-rb-onda-38-2-19-fix1-form-avaliacao-idsiguais.json) — **human_status: confirmed** |
| Hearback | [`0139-rb-onda-38-2-19-fix1-form-avaliacao-idsiguais-confirmed.json`](../hearbacks/0139-rb-onda-38-2-19-fix1-form-avaliacao-idsiguais-confirmed.json) |
| Tecnico | [`0139_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_19_fix1_form_avaliacao_idsiguais/0139_TECNICO.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_19_FIX1_FORM_AVALIACAO_IDSIGUAIS.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_19_FIX1_FORM_AVALIACAO_IDSIGUAIS.txt) |
| ERP | [`0139-exec-onda-38-2-19-fix1-form-avaliacao-idsiguais.json`](../results/0139-exec-onda-38-2-19-fix1-form-avaliacao-idsiguais.json) — `completed` |
| Motivo | 0138 importou e compilou, mas `TV2_20260602_125043` retornou `OK=3 | FALHA=2 | MANUAL=0`; CSV mostra comparacao textual estrita de `OS_ID=001` no teste isolado |
| Diagnostico | `FAM_02` e `FAM_04` passaram; resolver de demandante e fallback de payload funcionaram. Falharam `FAM_03` e `FAM_05` porque helpers do teste buscaram `OS_ID` com comparacao textual em vez de `IdsIguais` |
| Decisao aplicada | Fix test-only em `Teste_V2_Form_Avaliacao_Modulos`: usar `IdsIguais` em `TV2_FAM_LerDemandanteLista` e `TV2_FAM_AlterarEntIdOS`; importar apenas `App_Release` + modulo V2 isolado |
| Build | `e157221+ONDA38.2.19-FIX1-FORM-IDS` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_19_FIX1_FORM_AVALIACAO_IDSIGUAIS", "e157221+ONDA38.2.19-FIX1-FORM-IDS"` |
| Nao importar | `Svc_Avaliacao`, `Preencher`, `Menu_Principal.frm`, qualquer UserForm, `.frx`, `ThisWorkbook`, `Auto_Open.bas`, `Mod_Types.bas`, `Importador_V3.bas`, `Teste_V2_Engine.bas`, `Teste_V2_Roteiros.bas` |
| Gate humano | Importacao e compile reportados por Mauricio; `TV2_20260602_181749` retornou `OK=5 | FALHA=0 | MANUAL=0`; sem CSV de falhas |
| RVS completo | `VR_20260602_182253` APROVADO; CSV [`ValidacaoReleaseRVS_V12_0_0205_VR_20260602_182253.csv`](../../auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260602_182253.csv); SHA-256 `bc5b709ef45e54de085772137bb69456619e21fefb67ad749eb944cf905bb1e1` |
| Veredito atual | 38.2.19-fix1 validada por V2 dirigido e RVS completo; freeze V206 segue bloqueado |

## 🔴 ONDA 38.2.19 GATE V2 FALHOU — formulario avaliacao modulos primeiro (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🔴 GATE HUMANO FALHOU NO V2 DIRIGIDO |
| Track | safe_track |
| Readback | [`0138-rb-onda-38-2-19-form-avaliacao-modulos-primeiro.json`](../readbacks/0138-rb-onda-38-2-19-form-avaliacao-modulos-primeiro.json) — **human_status: confirmed** |
| Hearback | [`0138-rb-onda-38-2-19-form-avaliacao-modulos-primeiro-confirmed.json`](../hearbacks/0138-rb-onda-38-2-19-form-avaliacao-modulos-primeiro-confirmed.json) |
| Tecnico | [`0138_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_19_form_avaliacao_modulos_primeiro/0138_TECNICO.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_19_FORM_AVALIACAO_MODULOS_PRIMEIRO.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_19_FORM_AVALIACAO_MODULOS_PRIMEIRO.txt) |
| ERP | [`0138-exec-onda-38-2-19-form-avaliacao-modulos-primeiro.json`](../results/0138-exec-onda-38-2-19-form-avaliacao-modulos-primeiro.json) — `human_gate_failed` |
| Motivo | Retomar formularios apos 0137 verde, mas evitando repetir o crash de 0134 causado pelo pacote com UserForm grande |
| Decisao aplicada | Pacote V3 sem item F: importar apenas `Svc_Avaliacao`, `Preencher`, `App_Release` e novo modulo isolado `Teste_V2_Form_Avaliacao_Modulos` |
| Build | `e157221+ONDA38.2.19-FORM-AVAL-MODULOS` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_19_FORM_AVALIACAO_MODULOS_PRIMEIRO", "e157221+ONDA38.2.19-FORM-AVAL-MODULOS"` |
| Nao importar | `Menu_Principal.frm`, qualquer UserForm, `.frx`, `ThisWorkbook`, `Teste_V2_Engine.bas`, `Teste_V2_Roteiros.bas` |
| Hipotese funcional | O form existente ja usa `AVListaCol(1)` em `EncerraOS_Click`; se `PreencherAvaliarOS` preencher essa coluna por `OS_ID -> ENT_ID -> ENTIDADE.NOME`, o demandante passa a chegar no registro/impressao sem reimportar o form |
| Gate humano | Importador V3 `M=4 | F=0 | err=0 | skip=0`; compile limpo; `TV2_20260602_125043` retornou `OK=3 | FALHA=2 | MANUAL=0` |
| CSV | `TesteV2_FORM_AVALIACAO_MODULOS_Falhas_TV2_20260602_125043.csv` |
| Diagnostico | Falha no teste isolado por comparacao textual de `OS_ID`; abrir fix1 0139 test-only |
| Veredito atual | 0138 nao validada; freeze V206 segue bloqueado |

## 🟢 ONDA 38.2.18-FIX1 VALIDADA — BO330 status canonico (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 GATE HUMANO VERDE |
| Track | safe_track |
| Readback | [`0137-rb-onda-38-2-18-fix1-bo330-status-canonico.json`](../readbacks/0137-rb-onda-38-2-18-fix1-bo330-status-canonico.json) — **human_status: confirmed** |
| Hearback | [`0137-rb-onda-38-2-18-fix1-bo330-status-canonico-confirmed.json`](../hearbacks/0137-rb-onda-38-2-18-fix1-bo330-status-canonico-confirmed.json) |
| Tecnico | [`0137_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_18_fix1_bo330_status_canonico/0137_TECNICO.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_18_FIX1_BO330_STATUS_CANONICO.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_18_FIX1_BO330_STATUS_CANONICO.txt) |
| ERP | [`0137-exec-onda-38-2-18-fix1-bo330-status-canonico.json`](../results/0137-exec-onda-38-2-18-fix1-bo330-status-canonico.json) — `completed` |
| Build | `e157221+ONDA38.2.18-FIX1-BO330-STATUS` |
| Origem | `TV2_20260602_105519` retornou `OK=18 | FALHA=6 | MANUAL=0`, mas o CSV mostrou `STATUS_EMP03=SUSPENSA_GLOBAL` e `DT_FIM_SUSP=2026-07-02`; falha era expectativa do diagnostico |
| Mudanca | `TV2_BO330_STATUS_SUSPENSA` passa de `SUSPENSA` para `SUSPENSA_GLOBAL` no modulo diagnostico isolado |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_18_FIX1_BO330_STATUS_CANONICO", "e157221+ONDA38.2.18-FIX1-BO330-STATUS"` |
| Gate humano | Import V3 `M=2 | F=0 | err=0`; compile limpo; `TV2_20260602_111854` retornou `OK=24 | FALHA=0 | MANUAL=0`; `CT_ValidarRelease_TrioMinimo` gerou `VR_20260602_112011` APROVADO |
| Proibidos | Producao, UserForms, `.frx`, `Auto_Open.bas`, `Mod_Types.bas`, `Importador_V3.bas`, `ThisWorkbook.code.txt`, `Teste_V2_Engine.bas`, `Teste_V2_Roteiros.bas` |
| Veredito atual | 38.2.18-fix1 validada; BO_330 voltou a passar no Trio minimo; freeze V206 segue bloqueado por demais pendencias |

## 🟡 ONDA 38.2.18 GATE INTERPRETADO — recuperação BO330 diagnóstico (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟡 GATE HUMANO GEROU EVIDENCIA |
| Track | safe_track |
| Readback | [`0136-rb-onda-38-2-18-recuperacao-bo330-diagnostico.json`](../readbacks/0136-rb-onda-38-2-18-recuperacao-bo330-diagnostico.json) — **human_status: confirmed** |
| Hearback | [`0136-rb-onda-38-2-18-recuperacao-bo330-diagnostico-confirmed.json`](../hearbacks/0136-rb-onda-38-2-18-recuperacao-bo330-diagnostico-confirmed.json) |
| Tecnico | [`0136_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_18_recuperacao_bo330_diagnostico/0136_TECNICO.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_18_RECUPERACAO_BO330_DIAGNOSTICO.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_18_RECUPERACAO_BO330_DIAGNOSTICO.txt) |
| ERP | [`0136-exec-onda-38-2-18-recuperacao-bo330-diagnostico.json`](../results/0136-exec-onda-38-2-18-recuperacao-bo330-diagnostico.json) — `human_gate_failed_diagnostic_expectation` |
| Build | `e157221+ONDA38.2.18-RECUP-BO330-DIAG` |
| Origem | Workbook de referencia compila em `fd45a5d+ONDA38.2.6-IMPRESSAO-INTEGRIDADE`, mas Trio minimo reprovou V1 por BO_330 (`OK=167 | FALHA=4`) |
| Decisao tecnica | Nao importar `Teste_V2_Engine.bas`/`Teste_V2_Roteiros.bas` completos no workbook 38.2.6; usar modulo isolado `Teste_V2_BO330_Diagnostico` |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_18_RECUPERACAO_BO330_DIAGNOSTICO", "e157221+ONDA38.2.18-RECUP-BO330-DIAG"` |
| Gate humano | Import V3 `M=2 | F=0 | err=0`; compile limpo; `TV2_20260602_105519` retornou `OK=18 | FALHA=6 | MANUAL=0` |
| Proibidos | Producao, UserForms, `.frx`, `Auto_Open.bas`, `Mod_Types.bas`, `Importador_V3.bas`, `ThisWorkbook.code.txt`, `Teste_V2_Engine.bas`, `Teste_V2_Roteiros.bas` |
| Veredito atual | CSV mostrou `OS_EMP_ID=003`, `STATUS_EMP03=SUSPENSA_GLOBAL` e `DT_FIM_SUSP=2026-07-02`; falha era expectativa `SUSPENSA` no diagnostico. Fix1 0137 aberto; freeze V206 segue bloqueado |

## 🟠 ONDA 38.2.17-FIX1 PROPOSTA — formulario avaliacao compile crash (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟠 READBACK PENDENTE DE HEARBACK |
| Track | safe_track |
| Readback | [`0135-rb-onda-38-2-17-fix1-form-avaliacao-compile-crash.json`](../readbacks/0135-rb-onda-38-2-17-fix1-form-avaliacao-compile-crash.json) — **human_status: pending** |
| Motivo | 0134 importou, mas o compile travou e fechou o Excel antes de TV2 |
| Hipotese principal | Reimportar `Menu_Principal.frm` em delta pequeno elevou risco de instabilidade do VBE/Excel |
| Diretriz do fix1 | Pacote V3 menor, sem item `F` e sem importar `Menu_Principal.frm`; corrigir por modulos e teste dirigido |
| Recuperacao operacional | Nao salvar workbook recuperado apos crash; partir do ultimo salvo limpo ou backup V3 anterior ao import 0134 |
| Teste V1 com 4 erros | Registrado como alerta; diagnosticar depois de compile limpo e TV2 dirigido verde |
| Veredito atual | Aguardando Mauricio confirmar readback 0135 |

## 🔴 ONDA 38.2.17 FALHOU NO GATE HUMANO — formularios avaliacao demandante (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🔴 GATE HUMANO FALHOU |
| Track | safe_track |
| Readback | [`0134-rb-onda-38-2-17-formularios-avaliacao-demandante.json`](../readbacks/0134-rb-onda-38-2-17-formularios-avaliacao-demandante.json) — **human_status: confirmed** |
| Hearback | [`0134-rb-onda-38-2-17-formularios-avaliacao-demandante-confirmed.json`](../hearbacks/0134-rb-onda-38-2-17-formularios-avaliacao-demandante-confirmed.json) |
| Tecnico | [`0134_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_17_formularios_avaliacao_demandante/0134_TECNICO.md) |
| ERP | [`0134-exec-onda-38-2-17-formularios-avaliacao-demandante.json`](../results/0134-exec-onda-38-2-17-formularios-avaliacao-demandante.json) — **failed_human_gate** |
| Origem | Mauricio reportou erros residuais em formularios e caso concreto em que a avaliacao ainda nao registra/exibe o nome do demandante |
| Conferencia previa | Marcador BL-4 0133 funciona apos `IniciarSistema` e save; TV2_20260601_120900 retornou `OK=5 | FALHA=0 | MANUAL=0` |
| Escopo entregue | `Svc_Avaliacao.bas`, `Preencher.bas`, `Menu_Principal.frm`, testes V2, `App_Release.bas`, espelhos importaveis e manifesto V3 |
| Objetivo | Resolver demandante da avaliacao por `OS_ID -> CAD_OS.ENT_ID -> ENTIDADE.NOME`, preencher lista/formulario, payload e variaveis de impressao, com V2 dirigido |
| Import V3 | `ImportarPacoteV3_Delta "ONDA38_2_17_FORMULARIOS_AVALIACAO_DEMANDANTE", "e157221+ONDA38.2.17-FORM-AVAL-DEMANDANTE"` |
| Gate V2 | Executar `TV2_RunFormulariosAvaliacaoDemandante`; esperado `OK=7 | FALHA=0 | MANUAL=0` |
| Resultado humano | Importou; compile travou e fechou Excel; TV2 nao executado |
| Proibidos | `Auto_Open.bas`, `Mod_Types.bas`, `Importador_V3.bas`, `Repo_Avaliacao.bas`, `Const_Colunas.bas`, `ThisWorkbook.code.txt`, `Credencia_Empresa.frm`, `.frx` |
| Nota fora de escopo | Botao/indicativo visual para `IniciarSistema` sera onda propria posterior; nao entra na 38.2.17 |
| Veredito atual | Abrir fix1 0135; freeze V206 segue bloqueado |

## 🟢 ONDA 38.2.16-FIX1 VALIDADA — BL-4 Auto_Open marker (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 GATE HUMANO VERDE |
| Track | safe_track |
| Readback | [`0133-rb-onda-38-2-16-fix1-bl4-autoopen-marker.json`](../readbacks/0133-rb-onda-38-2-16-fix1-bl4-autoopen-marker.json) — **human_status: confirmed** |
| Hearback | [`0133-rb-onda-38-2-16-fix1-bl4-autoopen-marker-confirmed.json`](../hearbacks/0133-rb-onda-38-2-16-fix1-bl4-autoopen-marker-confirmed.json) |
| Tecnico | [`0133_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_16_fix1_bl4_autoopen_marker/0133_TECNICO.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_16_FIX1_BL4_AUTOOPEN_MARKER.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_16_FIX1_BL4_AUTOOPEN_MARKER.txt) |
| ERP | [`0133-exec-onda-38-2-16-fix1-bl4-autoopen-marker.json`](../results/0133-exec-onda-38-2-16-fix1-bl4-autoopen-marker.json) — `completed` |
| Build | `e157221+ONDA38.2.16-FIX1-BL4-MARKER` |
| Origem | 38.2.16 importou e compilou, mas `BL4_01_AUTO_OPEN_REAPLICOU_PROTECAO` falhou em `TV2_20260601_105519` e `TV2_20260601_110148` |
| Diagnostico | Os asserts concretos de protecao passaram; o sinal de abertura nao deve depender apenas de variavel VBA em memoria |
| Escopo entregue | `Auto_Open.bas`, `Teste_V2_Engine.bas`, `Teste_V2_Roteiros.bas`, `App_Release.bas`, espelhos importaveis e manifesto V3 fix1 |
| Mudanca | `Auto_Open` grava nomes ocultos do workbook com timestamp/status/detalhes; `BL4_01` le o marcador persistente |
| Proibidos | `ThisWorkbook.code.txt`, `Util_Planilha.bas`, `Mod_Types.bas`, `Importador_V3.bas`, formularios, `Preencher.bas`, `Svc_*`, `Repo_*`, `.frx` |
| Comando | `ImportarPacoteV3_Delta "ONDA38_2_16_FIX1_BL4_AUTOOPEN_MARKER", "e157221+ONDA38.2.16-FIX1-BL4-MARKER"` |
| Gate humano | Import V3 `M=4 | F=0 | err=0`; compile limpo; diagnostico `Application.EnableEvents=True`; `IniciarSistema` criou marcador `OK`; `TV2_20260601_120900` retornou `OK=5 | FALHA=0 | MANUAL=0` |
| Falha intermediaria | `TV2_20260601_115504` falhou por `MARCADOR_TS=nao registrado`; resolvida no diagnostico com marcador persistente criado por `IniciarSistema` |
| Veredito atual | BL-4 validado por suite V2 apos fix1; freeze V206 segue bloqueado por demais pendencias |

## 🔴 ONDA 38.2.16 GATE FALHOU — BL-4 protecao persistente (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🔴 GATE HUMANO FALHOU |
| Track | safe_track |
| Readback | [`0132-rb-onda-38-2-16-bl4-protecao-persistente.json`](../readbacks/0132-rb-onda-38-2-16-bl4-protecao-persistente.json) — **human_status: confirmed** |
| Hearback | [`0132-rb-onda-38-2-16-bl4-protecao-persistente-confirmed.json`](../hearbacks/0132-rb-onda-38-2-16-bl4-protecao-persistente-confirmed.json) |
| Tecnico | [`0132_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_16_bl4_protecao_persistente/0132_TECNICO.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_16_BL4_PROTECAO_PERSISTENTE.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_16_BL4_PROTECAO_PERSISTENTE.txt) |
| ERP | [`0132-exec-onda-38-2-16-bl4-protecao-persistente.json`](../results/0132-exec-onda-38-2-16-bl4-protecao-persistente.json) — `human_gate_failed` |
| Build | `e157221+ONDA38.2.16-BL4-PROT-PERSIST` |
| Decisao explicita | Mauricio confirmou excecao estreita para tocar `Auto_Open.bas` apenas para reaplicar/instrumentar protecao critica na abertura |
| Escopo entregue | `Auto_Open.bas`, `Util_Planilha.bas`, testes V2, `App_Release.bas`, espelhos importaveis e manifesto V3 |
| Gate humano | Import V3 `M=5 | F=0 | err=0`; compile limpo; `TV2_20260601_105519` e `TV2_20260601_110148` retornaram `OK=4 | FALHA=1 | MANUAL=0` |
| Falha | `BL4_01_AUTO_OPEN_REAPLICOU_PROTECAO`: `EXECUTADA_EM=nao registrada; OK=Falso; DETALHES=` |
| Fora do escopo | Formularios, demandante, impressao, `Preencher.bas`, `Menu_Principal.frm`, `ThisWorkbook.code.txt`, `Mod_Types.bas`, `Importador_V3.bas`, `.frx` |
| Veredito atual | BL-4 nao fechado; micro-fix 0133 aberta/pending para marcador persistente de Auto_Open; freeze V206 segue bloqueado |

### Fila registrada apos 38.2.16

- Onda propria para melhoria de formularios, com prioridade para
  avaliacao/encerramento de OS e caso em que o formulario de avaliacao nao
  registra/exibe o nome do demandante.
- Em handoff ou auditoria cruzada, rodar nova evolucao do protocolo useHBN com
  `/Users/macbookpro/Projetos/PROMPT_ARQUITETO_USEHBN_AUTONOMO.md`.

## 🟢 ONDA 38.2.15 VALIDADA — FT-4 credenciamento em lote (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 GATE HUMANO VERDE |
| Track | safe_track |
| Readback | [`0131-rb-onda-38-2-15-ft4-credenciamento-lote.json`](../readbacks/0131-rb-onda-38-2-15-ft4-credenciamento-lote.json) — **human_status: confirmed** |
| Hearback | [`0131-rb-onda-38-2-15-ft4-credenciamento-lote-confirmed.json`](../hearbacks/0131-rb-onda-38-2-15-ft4-credenciamento-lote-confirmed.json) |
| Tecnico | [`0131_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_15_ft4_credenciamento_lote/0131_TECNICO.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_15_FT4_CREDENCIAMENTO_LOTE.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_15_FT4_CREDENCIAMENTO_LOTE.txt) |
| ERP | [`0131-exec-onda-38-2-15-ft4-credenciamento-lote.json`](../results/0131-exec-onda-38-2-15-ft4-credenciamento-lote.json) — `completed` |
| Build | `e157221+ONDA38.2.15-FT4-CRED-LOTE` |
| Escopo | `Credencia_Empresa.frm` + testes V2 + pacote V3, sem `.frx`, sem Auto_Open/Mod_Types/Importador_V3 |
| Objetivo | FT-4: remover alocacao O(n^2) de `CRED_ID`/AR1 dentro do loop de credenciamento e provar sequencia/tempo por TV2 |
| Gate humano | Importador V3 `M=3 | F=1 | err=0 | skip=0`; compile limpo; `TV2_20260601_102735` com `OK=6 | FALHA=0 | MANUAL=0` |
| Veredito atual | FT-4 validada; freeze V206 segue bloqueado |

### Desvio controlado da sequencia 0033

A 0033 listava BL-4 e impressao fase 2 antes de FT-4, mas o relay pos-38.2.14
registrou FT-4 como proxima acao porque a rede C1 inicial ficou verde no
workbook. Esse desvio nao libera freeze: BL-4, impressao fase 2, FT-9, FT-10,
FT-11 real, RVS sexteto e L44 continuam pendentes.

## 🟢 ONDA 38.2.14 VALIDADA — behavioralizacao C1 (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 GATE HUMANO VERDE |
| Track | safe_track |
| Readback | [`0130-rb-onda-38-2-14-behavioralizacao-c1.json`](../readbacks/0130-rb-onda-38-2-14-behavioralizacao-c1.json) — **human_status: confirmed** |
| Hearback | [`0130-rb-onda-38-2-14-behavioralizacao-c1-confirmed.json`](../hearbacks/0130-rb-onda-38-2-14-behavioralizacao-c1-confirmed.json) |
| Tecnico | [`0130_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_14_behavioralizacao_c1/0130_TECNICO.md) |
| Manifesto | [`000-MANIFESTO-V3-DELTA-ONDA38_2_14_BEHAVIORALIZACAO_C1.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_14_BEHAVIORALIZACAO_C1.txt) |
| ERP | [`0130-exec-onda-38-2-14-behavioralizacao-c1.json`](../results/0130-exec-onda-38-2-14-behavioralizacao-c1.json) — `completed` |
| Build | `e157221+ONDA38.2.14-BEHAVIORALIZACAO-C1` |
| Gate humano | Importador V3 `M=3 | F=0 | err=0 | skip=0`; compile limpo; `TV2_20260601_093826` com `OK=5 | FALHA=0 | MANUAL=0` |
| Veredito | Primeira fatia C1 validada; nenhum codigo de producao alterado; freeze V206 segue bloqueado |

### Gate 38.2.14

Mauricio importou o delta 38.2.14 pelo manifesto V3, compilou o VBAProject e
executou `TV2_RunBehavioralizacaoC1`. Resultado: `TV2_20260601_093826` com
`OK=5 | FALHA=0 | MANUAL=0`. A proxima onda recomendada passa a ser FT-4
credenciamento em lote, ainda mediante novo readback safe_track proprio.

## 🟡 ONDA 38.2.13 CONSOLIDADA — auditoria cruzada pos-38.2.12 (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟡 FREEZE BLOQUEADO |
| Track | fast_track doc-only |
| Readback | [`0129-rb-onda-38-2-13-auditoria-cruzada-consolidada.json`](../readbacks/0129-rb-onda-38-2-13-auditoria-cruzada-consolidada.json) — **human_status: confirmed** |
| Consolidacao | [`0033-consolidacao-auditoria-cruzada-38-2-4-a-38-2-12.md`](../proposals/0033-consolidacao-auditoria-cruzada-38-2-4-a-38-2-12.md) |
| Tecnico | [`0129_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_13_auditoria_cruzada/0129_TECNICO.md) |
| Veredito | Deltas 38.2.4 a 38.2.12 aproveitaveis com ressalvas; freeze V206 bloqueado por C1/C4/C5; FT-4 nao deve abrir antes de behavioralizacao |

### Decisao 38.2.13

A proxima onda recomendada e **38.2.14 - behavioralizacao da bateria/C1**:
converter asserts estaticos `TV2_EST_*` em fluxos executados onde o risco e
comportamental, especialmente base populada, impressao, protecao save/reopen e
sequencia `CRED_ID`/AR1. FT-4 credenciamento em lote continua pendente ate essa
rede de seguranca existir.

### Escopo AT-3 ativo

GATE-A2 concluiu que F-NEW5 nao reproduziu e que a falha restante e F-NEW6 (`EMP_PRESEL=001` vs `EMP_PREOS=1`). AT-3 incorpora os FORTES do 0019: write-side primario em `Svc_PreOS.EmitirPreOS`, blindagem de `Repo_PreOS.Inserir`, sem backfill legado porque a base atual e descartavel. Decisao de IDs >999: manter 3 digitos como largura minima, nao maxima; normalizador nao pode truncar `1000` para `000`.

### Compile blocker AT-3 Fix1

Import AT-3 retornou `M=2 | F=0 | err=0 | skip=0`, mas `Debug > Compile VBAProject` falhou em `Teste_V2_Roteiros` na chamada qualificada `Repo_PreOS.BuscarPorId`. Fix1 aplica o mesmo padrao de `Repo_OS`: wrapper publico `RepoPreOS_BuscarPorId` e troca mecanica das 4 chamadas no roteiro.

### STRIKES_E2E AT-3 Fix2

Fix1 importou e compilou. O CSV `TesteV2_STRIKES_E2E_Falhas_TV2_20260527_213936.csv` trouxe 37 falhas, todas `DIAG_PREOS_INTEGRITY`, com `EMP_PRESEL=2/3` e `EMP_PREOS=002/003`. Isso mostra que a gravacao textual passou; a assercao ficou comparando observador cru contra ID canonico. Fix2 mantem a sentinela forte lendo a celula bruta de `PRE_OS.COL_PREOS_EMP_ID`: `002/003` passam, mas `2/3` bruto continua falhando.

### STRIKES_E2E AT-3 Fix3

Fix2 importou e compilou. O CSV `TesteV2_STRIKES_E2E_Falhas_TV2_20260527_220557.csv` confirmou `NF=@`, `EMP_PREOS_BRUTO=2/3` e `EMP_PREOS_REPO=002/003`. Logo a falha residual esta na escrita: `Svc_PreOS.EmitirPreOS` aplicava formato texto, mas ainda gravava `rodizio.Empresa.EMP_ID` cru. Fix3 normaliza `ENT_ID`, `ATIV_ID`, `SERV_ID` e `EMP_ID` antes da gravacao.

### GATE-A4 aberto

Mauricio importou o Fix3, compilou e executou `TV2_RunRodizioStrikesEndToEnd` com `OK=76 | FALHA=0 | MANUAL=0`. Opus 0020 e Antigravity 0021 aprovaram GATE-A3 sem BLOQUEADORES. GATE-A4 abriu com micro-higiene obrigatoria: `ATIVAR_DIAG_FNEW5=False` em `Credencia_Empresa`, manifestos reais `ONDA38_2_3_A4_F1_MODULOS` e `ONDA38_2_3_A4_F2_FORMS`, procedimento `IMPORT_PROCEDURE_2_FASES.md` e template `GATE_USO_PROLONGADO_REPORT.md`.

### GATE-A4 F1/F2 verdes

Mauricio executou Fase 1: import `M=4 | F=0 | err=0 | skip=0`, compile limpo e RVS `VR_20260528_063131` APROVADO. Executou Fase 2: import `M=1 | F=2 | err=0 | skip=0`, compile limpo e RVS `VR_20260528_090314` APROVADO. Evidencias registradas em `GATE_A4_FASES12_RESULTADO.md`; falta L43 uso prolongado + RVS final pos-uso antes de auditoria cruzada A4.

## 🟣 ONDA 0113 META APLICADA (fast_track doc-only) — Operacionalizar a passagem de bastão (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟣 META APLICADA (pendente commit no Mac) |
| Track | fast_track (doc-only — meta-protocolo) |
| Origem | Claude Opus 4.7 (modo ARQUITETO, sessão Cowork 2026-05-27 ~13:55), sucessora da 0112 |
| Readback | [`0113-operacionalizar-passagem-bastao.json`](../readbacks/0113-operacionalizar-passagem-bastao.json) — **human_status: confirmed** |
| Spec | [`.hbn/protocol-evolutions/20260527-1340-onda-0113-operacionalizar-bastao-spec.md`](../protocol-evolutions/20260527-1340-onda-0113-operacionalizar-bastao-spec.md) |
| Registro §11 | [`auditoria/00_status/122_OPERACIONALIZAR_PASSAGEM_BASTAO.md`](../../auditoria/00_status/122_OPERACIONALIZAR_PASSAGEM_BASTAO.md) |
| ERP | [`0113-exec-operacionalizar-passagem-bastao.json`](../results/0113-exec-operacionalizar-passagem-bastao.json) — executed_local_pending_human_commit |

### Mudanças

PROMPT_ARQUITETO v1.4 → **v1.5**: §12.B expandido por papel (B1 implementador / B2 auditor / B3 consolidador). Registro de transferência de bastão **fundido** no handoff de fim-de-sessão (knowledge 0014, itens 13-16) por decisão de Mauricio. Critério objetivo de promoção da P9 aprovado (registrado no 122). **Protocolo de passagem de bastão pronto para devolver às IAs.**

---

## 🟣 ONDA 0112 META APLICADA (fast_track doc-only) — Cadência D Estendida / passagem de bastão (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟣 META APLICADA (pendente commit no Mac) |
| Track | fast_track (doc-only — meta-protocolo) |
| Origem | Claude Opus 4.7 (modo ARQUITETO, sessão Cowork 2026-05-27 ~13:00) consumindo doc 120 (10 propostas) |
| Readback | [`0112-evolucao-protocolo-onda38-passagem-bastao.json`](../readbacks/0112-evolucao-protocolo-onda38-passagem-bastao.json) — **human_status: confirmed** |
| Decisão por proposta | [`.hbn/protocol-evolutions/20260527-1300-decisao-evolucoes-onda-38-passagem-bastao.md`](../protocol-evolutions/20260527-1300-decisao-evolucoes-onda-38-passagem-bastao.md) |
| Registro §11 | [`auditoria/00_status/121_EVOLUCAO_PROTOCOLO_ONDA38_PASSAGEM_BASTAO.md`](../../auditoria/00_status/121_EVOLUCAO_PROTOCOLO_ONDA38_PASSAGEM_BASTAO.md) |
| ERP | [`0112-exec-evolucao-protocolo-onda38-passagem-bastao.json`](../results/0112-exec-evolucao-protocolo-onda38-passagem-bastao.json) — executed_local_pending_human_commit |

### Mudanças (Tier 1 = PROMPT_ARQUITETO §12 + knowledge 0019; Tier 2 recomendado; L44 = knowledge 0020)

PROMPT_ARQUITETO v1.3 → **v1.4** (§12 Cadência D Estendida + §12.A template auditoria + §12.B prompt de entrada chat novo). 3 modificações do arquiteto sobre o doc 120, confirmadas por Mauricio: P1 sem implementador único por ciclo; P7 renomeada **BLOQUEADOR/FORTE/MARGINAL**; meta-protocolo no PROMPT_ARQUITETO + knowledge 0019 (AGENTS.md só aponta). P9 fica EM TESTE (38.2.3); P10 adiada pós-freeze.

### Próxima ação

Mauricio commita do Mac (comando sugerido no ERP 0112). Onda **0113** (META, pending hearback) operacionaliza a passagem de bastão antes de devolvê-lo às IAs.

---

## 🟢 ONDA 38.2.2 V206 PURO ENTREGUE — última onda antes do freeze (NOVO)

| Campo | Valor |
|---|---|
| Sinal | 🟢 HBN ENTREGUE |
| Onda | ONDA38.2.2 — V206 puro freeze |
| Agente | Claude Opus 4.7 (sessão 2026-05-26 ~17:30 BRT, sucessora pós-handoff 1730) |
| Readback | [`0111-onda-38-2-2-v206-puro-filtros-envelopamento-quickwins-freeze.json`](../readbacks/0111-onda-38-2-2-v206-puro-filtros-envelopamento-quickwins-freeze.json) — confirmed (chat 2026-05-26 ~16:45 BRT) |
| Técnico | [`auditoria/03_ondas/onda_38_2_2_v206_freeze/38_2_2_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_2_v206_freeze/38_2_2_TECNICO.md) |
| Manifesto | [`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-2-2-V206-FREEZE.txt`](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-2-2-V206-FREEZE.txt) — 8 módulos M |
| Anchor de rollback | commit `179bac5` (HEAD pós-consolidação 2ª rodada V207) |
| Anchor V206 funcional | `ee75b30` (FIX2-PERF + RVS Trio APROVADO `VR_20260526_102200`) |

### 5 alvos atômicos entregues

- **AT-1** (item 68 Codex, sev. ALTO) — `Util_Planilha.Util_MaxIdOperacional(nomeAba)` pair-aware EMPRESAS+INATIVAS / ENTIDADE+INATIVOS; `ProximoId` redirecionado.
- **AT-2** (item 69 Codex, sev. MÉDIO) — handler-before-flag em `Util_Sanear_Contadores.SanearContadoresAR1` + 4 funções `Repo_Empresa` (Inserir, Atualizar, GravarStatusEmpresa, RepoEmpresa_BackfillDtUltReativPorAuditLog).
- **AT-3** (F-NEW3 sistemático) — `NumberFormat = "@"` em coluna A antes de gravar ID em 5 pontos: Menu_Principal entidade + empresa-alt, Credencia_Empresa (dentro do loop), Cadastro_Servico (atividade + serviço).
- **AT-4** (filtros nativos) — 7 handlers estáticos `TextBox16..22_Change` no `Menu_Principal.frm` despachando para `Preencher.Preencher_FiltrarPorBoxEstatico(nomeContexto, termo)`. Reverte definitivamente a regressão da Onda 38.2.1 (`e9bcf42`). Handlers dinâmicos `mTxtFiltro*_Change` mantidos como fallback. Débito V207: rename canônico de TextBox16..22 no designer + `Optional filtro` em `PreencherPreencheOS`/`PreencherAvaliarOS`.
- **AT-5** (envelopamento) — `Util_Excel_Performance` aplicado em 4 subs `.frm`: Menu_Principal (entidade + empresa-alt), Credencia_Empresa (loop credenciamento), Cadastro_Servico (atividade + serviço). Padrão emergente: `blocoRapidoIniciado As Boolean` defensiva no handler de erro (candidato a knowledge 002X).

### Próxima ação

Apresentar a Mauricio para os **10 gates humanos pós-commit**:
GATE-IMPORT → GATE-COMPILE → GATE-AT-1..AT-5 → GATE-RVS → GATE-VAL-TELA-A-TELA (cronograma [`38_2_TECNICO.md:79`](../../auditoria/03_ondas/onda_38_2_filtros_menu_principal/38_2_TECNICO.md#L79)) → GATE-FREEZE (tag `v12.0.0206` anotada + push origin sob aprovação).

---

## 🟢 HBN HANDOFF READY FECHADO — sessão Opus 2026-05-26 ~12:30 → 15:26 (resolvido)

| Campo | Valor |
|---|---|
| Sinal | 🔵 HBN HANDOFF READY |
| Origem | Claude Opus 4.7 (sessão 2026-05-26 ~12:30 → 15:26, ~3h, ~70% contexto fadigado) |
| Destino | Claude Opus 4.7 (próxima sessão) |
| Gatilho | regra_50pct_contexto (com exceção documentada — input externo grande pós-50%) + §7 Passo 5 + §7.3 v1.3 |
| Handoff | [`.hbn/messages/20260526-1526-handoff-fim-sessao-opus.md`](../messages/20260526-1526-handoff-fim-sessao-opus.md) — 12 itens + 13 (cláusula exceção 50%) + 14 (memory updates) + 15 (encerramento) |
| Prompt de retomada | [`auditoria/00_status/110_PROMPT_RETOMADA_SESSAO_OPUS.md`](../../auditoria/00_status/110_PROMPT_RETOMADA_SESSAO_OPUS.md) — inclui prompts 2ª rodada para Codex+Antigravity |
| Análise auditoria cruzada 1ª rodada | [`auditoria/00_status/111_ANALISE_AUDITORIA_CRUZADA_V207.md`](../../auditoria/00_status/111_ANALISE_AUDITORIA_CRUZADA_V207.md) |
| Protocol evolutions (1ª aplicação §7.3) | [`.hbn/protocol-evolutions/20260526-1526-onda0111-proposals.md`](../protocol-evolutions/20260526-1526-onda0111-proposals.md) — L29 (confirmada), L30 (confirmada), L31 (NOVA), L32 (NOVA) |
| Anchor funcional V206 | commit `ee75b30` + build `ad5b487+ONDA38.2.1-AR1-FIX2-PERF` + RVS Trio `VR_20260526_102200` |

### Primeira ação da próxima sessão

**Entregar os 2 prompts da 2ª rodada de auditoria cruzada** (textos prontos no 110 §"Prompts 2ª rodada"). Mauricio abre 2 sessões paralelas Codex + Antigravity refinando 2 alternativas:

- **Alternativa I**: Caminho 1 → Caminho 2 puro (V207 + V208 sequencial, 12-17 ondas)
- **Alternativa II**: Opção 4 híbrida (Caminho 1 + in-memory parcial nas listas, 7-9 ondas em 1 release)

Output esperado: 4 arquivos `.md` em `.hbn/proposals/0005-0008-*`. Opus consolida em sucessor do 111; Mauricio decide com hearback explícito.

### Em paralelo (opcional, não bloqueia 2ª rodada)

**Onda 38.2.2 (V206 puro)** — pré-trabalho PHAGOCYTOSIS já consolidado (M9, L22-L24, M15-M17) + 2 quick wins identificados na 1ª rodada Codex:
- Item 68 (severidade alto): `Util_MaxIdOperacional(nomeAba)` pair-aware EMPRESAS+EMPRESAS_INATIVAS / ENTIDADE+ENTIDADE_INATIVOS
- Item 69 (severidade médio): instalar `On Error GoTo` ANTES de chamar `Util_IniciarBlocoRapido` em 5 callers

Pode abrir readback 0111 se Mauricio aprovar — escopo independente da decisão V207.

---

## 🟢 HBN PENDING HEARBACK V207 FECHADO — Alternativa II-bis confirmada por Mauricio (2026-05-26 ~16:30 BRT)

> Mauricio confirmou em chat **Alternativa II-bis (commitment full V207.0-V207.8 sem cláusula de escape)**. Decisão documentada em `decisions_preconfirmed[0]` do readback 0111 + executada nesta onda 38.2.2. Bloco abaixo preservado como histórico do consenso 2ª rodada.

## 🔵 HBN PENDING HEARBACK — 2ª rodada auditoria cruzada V207 CONSOLIDADA (HISTÓRICO)

| Campo | Valor |
|---|---|
| Sinal | 🔵 PENDING HEARBACK MAURICIO |
| Track | meta (ato cognitivo sem readback safe_track) |
| Inputs | [`0005-codex-refinamento-arquitetural-v207.md`](../proposals/0005-codex-refinamento-arquitetural-v207.md) (~35KB) + [`0006-codex-recomendacao-alternativa-i-ou-ii.md`](../proposals/0006-codex-recomendacao-alternativa-i-ou-ii.md) (~7.5KB) + [`0007-antigravity-refinamento-arquitetural-v207.md`](../proposals/0007-antigravity-refinamento-arquitetural-v207.md) (~16KB) + [`0008-antigravity-recomendacao-alternativa-i-ou-ii.md`](../proposals/0008-antigravity-recomendacao-alternativa-i-ou-ii.md) (~6KB) |
| Commits originais | Codex `039b2ec` + Antigravity `32e1bad` |
| Output consolidado | [`auditoria/00_status/112_ANALISE_AUDITORIA_CRUZADA_V207_2A_RODADA.md`](../../auditoria/00_status/112_ANALISE_AUDITORIA_CRUZADA_V207_2A_RODADA.md) |
| Veredito | **Convergência unânime Codex+Antigravity: Alternativa II com 3 guard-rails sistêmicos invioláveis** |
| Recomendação Opus 4.7 | Alternativa II com cláusula de escape V207.4 (sub-versão da III-G Codex) |

### Os 3 Guard-rails Sistêmicos (contratos invioláveis Alternativa II)

1. **Fase-Lock**: V207.5+ só após RVS+E2E_CADASTROS verdes e tag `v12.0.0207-base-monolito` cravada. Proibido branches/commits cache em paralelo.
2. **Invalidação Stateless**: cache reconstrói coleção inteira ao invalidar; nunca atualiza item isolado.
3. **Callback Explícito**: toda gravação `Repo_*.bas` invoca `Menu_Principal.InvalidarCache(tipoAba)` sob pena de gate mecânico.

### Decisão pendente Mauricio (3 hipóteses)

- ✅ **(II) Alternativa II com cláusula de escape V207.4 — RECOMENDADA Opus**
- ⚠ (II-bis) Alternativa II sem escape (commitment full V207.0-V207.8)
- ❌ (I) Alternativa I — rejeitada por ambas IAs auxiliares
- ❌ (III) EDRA — rejeitada

### Próximos passos pós-hearback

1. **Onda 38.2.2 V206 puro EM PARALELO** (independente da decisão V207): readback `0111-rb-onda-38-2-2-v206-puro-quick-wins-filtros-envelopamento-fnew3` aproveita contexto Opus limpo
2. **Onda safe_track doc-only** consolidando knowledges 0018 (Doc-Delta) + 0019 (Limites Hibridismo) + 0020 (Invalidação Stateless) ANTES de V207.0
3. **Readback `0120-rb-v207-0-foundation-idperf`** abre primeira onda V207 substantiva (quick wins + base defensiva)
4. Sequência V207 prosseguindo pelos IDs `0121-0129` (9 ondas em release única)

---

## 🟢 Auditoria cruzada V207 1ª rodada — CONSOLIDADA

| Campo | Valor |
|---|---|
| Sinal | 🟢 CONSOLIDADA |
| Track | meta (ato cognitivo sem readback safe_track) |
| Inputs | [`0001-codex-auditoria-v206-codigo.md`](../proposals/0001-codex-auditoria-v206-codigo.md) (~23KB), [`0002-codex-tres-propostas-v207-codigo.md`](../proposals/0002-codex-tres-propostas-v207-codigo.md) (~17KB), [`0003-antigravity-auditoria-v206-sistemica.md`](../proposals/0003-antigravity-auditoria-v206-sistemica.md) (~18KB), [`0004-antigravity-tres-propostas-v207-sistemica.md`](../proposals/0004-antigravity-tres-propostas-v207-sistemica.md) (~16KB) |
| Commits originais | Codex `b33d904` + Antigravity `2d49259` (ambos commits locais sem push pelas IAs auxiliares; pushados nesta sessão Opus junto com artefatos handoff) |
| Output | [`auditoria/00_status/111_ANALISE_AUDITORIA_CRUZADA_V207.md`](../../auditoria/00_status/111_ANALISE_AUDITORIA_CRUZADA_V207.md) |
| Estrutura da análise | 8 convergências base sólida + 3 divergências reais + tabela 6→3 caminhos consolidados + recomendação Opus + decisão preliminar Mauricio |
| Decisão preliminar Mauricio | Alternativa I (Caminho 1→2 puro) OU Alternativa II (Opção 4 híbrida) — só decide após 2ª rodada |

### Quick wins não-implementação aprovados (sem precisar de decisão arquitetural)

1. **Knowledge 0018 — Doc-Delta Pattern** (proposto por Antigravity §3.3): a criar em onda safe_track doc-only futura, idealmente antes de V207.0.
2. **Util_MaxIdOperacional pair-aware** + **handler-before-flag** — compatíveis com escopo Onda 38.2.2 (V206 puro).

---

## 🟢 Onda 0110 ENTREGUE (fast_track doc-only) — Evolução manual do protocolo v1.2 → v1.3

| Campo | Valor |
|---|---|
| Sinal | 🟢 ENTREGUE |
| Track | fast_track (doc-only) |
| Origem | Claude Opus (sessão Cowork de evolução manual, 2026-05-26 ~12:00 → 12:30) + sessão sucessora (commit+push 12:50+) |
| Readback | [`readbacks/0110-evolucao-protocolo-v13-knowledge-0017.json`](../readbacks/0110-evolucao-protocolo-v13-knowledge-0017.json) — **human_status: confirmed** |
| Doc de auditoria (par.11 PROMPT_ARQUITETO) | [`109_EVOLUCAO_MANUAL_PROTOCOLO_OPUS_V13.md`](../../auditoria/00_status/109_EVOLUCAO_MANUAL_PROTOCOLO_OPUS_V13.md) |
| ERP | [`results/0110-exec-evolucao-protocolo-v13.json`](../results/0110-exec-evolucao-protocolo-v13.json) — **outcome: executed** |
| Commits | `91037f1` (primário, 6 arquivos +498/-24) + `f4d1884` (adjacente CSV V206 evidência aprovada) + `8c03e34` (fechamento ERP+relay) |
| Push | ✅ origin atualizado |

### Mudanças entregues (4 alvos atômicos)

1. **`/Users/macbookpro/Projetos/PROMPT_ARQUITETO_USEHBN_AUTONOMO.md`** (fora do repo) — v1.2 → **v1.3**: §7.3 novo (auto-evolução do protocolo a cada handoff) + Passo 5 do §7 + passo F do §2 pré-flight + changelog.
2. **`.hbn/knowledge/0017-handoff-aos-50-pct-contexto.md`** (NOVO) — formaliza a regra dos 50% com orçamento 50/30/20 e cláusula de exceção.
3. **`auditoria/00_status/108_PROMPT_RETOMADA_SESSAO_OPUS.md`** — Atenção e Quando-50% atualizadas para v1.3; exige 3 artefatos no próximo handoff.
4. **`.hbn/knowledge/INDEX.md`** — linha 0017 + bump de data.

---

## 🟢 Onda 38.2.1-AR1-FIX2-PERF ENTREGUE (Opus) — human_gate_passed_with_findings

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [`readbacks/0108-onda38-2-1-ar1-fix2-perf.json`](../readbacks/0108-onda38-2-1-ar1-fix2-perf.json) — **human_status: confirmed** |
| ERP | [`results/0108-exec-onda38-2-1-ar1-fix2-perf.json`](../results/0108-exec-onda38-2-1-ar1-fix2-perf.json) — **human_gate_passed_with_findings** |
| Doc tecnico | [`38_2_1_AR1_FIX2_PERF_TECNICO.md`](../../auditoria/03_ondas/onda_38_2_1_ar1_fix2_perf/38_2_1_AR1_FIX2_PERF_TECNICO.md) |
| Manifesto | `ONDA38-2-1-AR1-FIX2-PERF` (M=5 importados pelo V3) |
| Build label | `ad5b487+ONDA38.2.1-AR1-FIX2-PERF` |
| Commit primario | `ee75b30` |
| RVS Trio | **APROVADO** `VR_20260526_102200` `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0` |
| Anchor de rollback | commit `ad5b487` (handoff Opus + Sexteto VR_20260526_035523) |

### Resultado

**Entregue**: Parte A (microdelta ID monotonico) + Parte B.lite (wrapper Excel performance em Repo_Empresa).

- **Guarda monotonica validada na real**: `CREDENCIADOS!AR1 8 -> 8 (sources: CREDENCIADOS=4)`. AR1 estava em 8, coluna A so tinha 4 IDs (CRED_IDs 005-008 deletados historicamente). Sem a guarda, AR1 cairia para 4 e reusaria IDs. **F5 do ERP 0106 RESOLVIDO definitivamente.**
- Import V3: `M=5 | F=0 | err=0 | skip=0`. Compile limpo.
- Cadastros sequenciais: empresa 6 → ID 004, empresa 7 → ID 005. Local 4 → ID 004, Local 5 → ID 5 (ver F-NEW3).
- Performance: ~2x mais rapida (esperado 10-30x; ver F-NEW4).

### Findings pos-gate

- **F-NEW3** (cosmetico): ID `5` em ENTIDADE em vez de `005`. Causa: ListObject sem `.NumberFormat="@"` em `Menu_Principal.frm:1622`. Funcionalmente OK (`IdsIguais` trata). Fix em Onda 38.2.2.
- **F-NEW4** (medium - continuacao F4): performance parcial. Gargalo residual: reload de ListBox + cadastros em `.frm`. Resto na Onda 38.2.2 + refatoracao V207.
- **F-NEW4-DT** (medium): testes E2E de cadastros nao existem; debito tecnico V207.

### Proxima onda

**38.2.2 — filtros nativos + envelopamento .frm + fix F-NEW3**:
- Handlers `TextBox16..22_Change` estaticos + funcao filtro pura.
- Envelopa `Util_Excel_Performance` em cadastros .frm (Menu_Principal entidade/empresa-alt + Credencia_Empresa + Cadastro_Servico).
- `Range.NumberFormat = "@"` para a coluna A da nova linha em cadastros.
- **PRE-TRABALHO OBRIGATORIO Opus**: deep-dive PHAGOCYTOSIS-VBA-PATTERNS leitura completa de **M9, L22, L23, L24, M15, M16, M17** antes do readback 0109.

---

## 🔵 HBN HANDOFF READY — sessão Opus 2026-05-26 encerrada (CONSUMIDO pelo readback 0108)

| Campo | Valor |
|---|---|
| Sinal | 🔵 HBN HANDOFF READY |
| Origem | Claude Opus 4.7 (sessão 2026-05-26 14:30 → 04:25) |
| Destino | Claude Opus 4.7 (próxima sessão) |
| Gatilho | explicit_request_mauricio (Opção B de pausa) |
| Handoff completo | [`.hbn/messages/20260526-0425-handoff-fim-sessao-opus.md`](../messages/20260526-0425-handoff-fim-sessao-opus.md) (12 itens + análise técnica F4 e F5) |
| Prompt de retomada | [`auditoria/00_status/106_PROMPT_RETOMADA_SESSAO_OPUS.md`](../../auditoria/00_status/106_PROMPT_RETOMADA_SESSAO_OPUS.md) |
| Readback de handoff | [`readbacks/0107-handoff-fim-sessao-opus.json`](../readbacks/0107-handoff-fim-sessao-opus.json) (fast_track, confirmed) |
| Anchor funcional V206 | commit `433f25c` (Sexteto APROVADO `VR_20260526_035523`) |

### Decisão pendente Mauricio na próxima sessão

Escolher entre 3 caminhos (recomendação Opus = A → B → C):

| Onda | Tema | Escopo | Custo |
|---|---|---|---|
| **(A) 38.2.1-AR1-FIX2** | algoritmo monotônico (`max(max_existente, AR1_atual)`) | `Util_Planilha.ProximoId` + `Util_Sanear_Contadores` | ~5 linhas, microdelta urgente |
| **(B) 38.2.x-perf** | wrapper Excel performance (ScreenUpdating/Calculation off) | `Util_Excel_Performance.bas` novo + aplicar em `Repo_Empresa.*`, `Repo_Credenciamento.*`, etc. | médio, 10-30x mais rápido em PCs antigos |
| **(C) 38.2.2** | filtros nativos Menu_Principal | handlers `TextBoxNN_Change` estáticos + função filtro pura | médio, com pré-trabalho deep-dive PHAGOCYTOSIS |

(A) e (B) podem ser combinadas em microdelta único se Mauricio preferir.

## Onda 38.2.1-AR1 ENTREGUE — Saneamento contadores AR1 (Opus) — human_gate_passed_with_minor_finding

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0106-onda38-2-1-ar1-sanear-contadores.json](../readbacks/0106-onda38-2-1-ar1-sanear-contadores.json) — **human_status: confirmed** |
| Hearback | confirmed — Mauricio aprovou Caminho A em chat 2026-05-26 |
| ERP | [results/0106-exec-onda38-2-1-ar1-sanear-contadores.json](../results/0106-exec-onda38-2-1-ar1-sanear-contadores.json) — **human_gate_passed_with_minor_finding** |
| Doc tecnico | [38_2_1_AR1_TECNICO.md](../../auditoria/03_ondas/onda_38_2_1_ar1_sanear_contadores/38_2_1_AR1_TECNICO.md) |
| Manifesto delta | [000-MANIFESTO-V3-DELTA-ONDA38-2-1-AR1-SANEAR-CONTADORES.txt](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-2-1-AR1-SANEAR-CONTADORES.txt) |
| Build label (target) | `e9bcf42+ONDA38.2.1-AR1-sanear-contadores` |
| Predecessor | [0105-onda38-2-1-revert-filtros-menu.json](../readbacks/0105-onda38-2-1-revert-filtros-menu.json) |
| Origem | F1 + F2 do ERP 0105 (cadastro empresa ID 001 + cadastro entidade no topo) |
| Commit primario | `ffc8e8a` (modulo + readback + ERP + doc + manifesto + 7 abas alvo, EMPRESAS_INATIVAS/ENTIDADE_INATIVOS como sources) |
| Commit hotfix BUMP | `9592e0f` (revert App_Release ao estado e9bcf42 + knowledge 0016) |
| RVS Sexteto | **APROVADO** `VR_20260526_035523` `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` |

### Resultado Onda 38.2.1-AR1

**Entregue**: Util_Sanear_Contadores criado, importado, compilado, executado;
log do Imediato `[SanearContadoresAR1] FIM ok=7 falhas=0`; AR1 corrigidos
em todas as 7 abas; cadastro de empresa nova com ID 004 (era 001); cadastro
de entidade no FIM da lista (era no topo). Sexteto completo APROVADO.

**F1 e F2 do ERP 0105 RESOLVIDOS.**

**F5 (minor, pos-gate)**: `CREDENCIADOS!AR1` decresceu de 6 para 4 - existiram
CRED_IDs 005 e 006 que foram deletados historicamente; algoritmo max(ID)
ressincronizou para 4. Proximo cadastro de credenciamento vai reusar ID 005.
Trade-off documentado no ERP 0106. Aguarda decisao Mauricio: tratar agora,
deferir V207 ou descartar.

**F-NEW1/F-NEW2 (cobertura inativas)**: nao testados por ausencia de dados
(EMPRESAS_INATIVAS=0, ENTIDADE_INATIVOS=0). Logica do codigo esta pronta
para o caso quando houver inabilitacao.

### Resumo da onda 38.2.1-AR1

**Causa**: `Util_Planilha.ProximoId(nomeAba)` le `<aba>!AR1` (coluna
`COL_CONTADOR_AR=44`), incrementa e grava. Quando o workbook foi
restaurado de backup pre-38.2 para aplicar a Onda 38.2.1, os
contadores `EMPRESAS!AR1` e (provavel) `ENTIDADES!AR1` ficaram
dessincronizados do max(ID) real das empresas/entidades ja existentes.
Resultado: cadastro novo pega ID 001 ou similar e duplica IDs, o que
e CRITICO para `Svc_Rodizio.SelecionarEmpresa` (`LerEmpresa` retorna
o primeiro encontrado e empresa nova fica invisivel ao rodizio).

**Acao**: criar `src/vba/Util_Sanear_Contadores.bas` com funcao
`SanearContadoresAR1()` que percorre as abas que usam `ProximoId`
(EMPRESAS, ENTIDADES, CAD_OS, PRE_OS, AVALIACOES, CREDENCIAMENTO,
SERVICOS), calcula `max(coluna_ID)` e grava em `<aba>!AR1`.
Funcao idempotente, pode rodar quantas vezes for preciso. Mauricio
roda 1x apos import via macro no Imediato. NAO toca .frm/.frx, NAO
toca servicos blindados, NAO toca dados de empresa/entidade.

**Fora de escopo** (deferido): filtros novos (38.2.2), PDF (39+),
lentidao cadastros (V207), refatoracao de ProximoId (V207).

## Onda 38.2.1 ENTREGUE — Revert filtros Menu Principal (Opus) — human_gate_passed_with_findings

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0105-onda38-2-1-revert-filtros-menu.json](../readbacks/0105-onda38-2-1-revert-filtros-menu.json) — **human_status: confirmed** |
| Hearback | confirmed — Mauricio aprovou plano de revert + arquitetura 38.2.2 em chat 2026-05-26 |
| ERP | [results/0105-exec-onda38-2-1-revert-filtros-menu.json](../results/0105-exec-onda38-2-1-revert-filtros-menu.json) — **human_gate_passed_with_findings** |
| Doc tecnico | [38_2_1_TECNICO.md](../../auditoria/03_ondas/onda_38_2_1_revert_filtros_menu/38_2_1_TECNICO.md) |
| Manifesto delta | [000-MANIFESTO-V3-DELTA-ONDA38-2-1-REVERT-FILTROS-MENU.txt](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-2-1-REVERT-FILTROS-MENU.txt) |
| Build label | `7bca168+ONDA38.2.1-revert-filtros-menu` |
| Predecessor | [0104-onda38-2-filtros-menu-principal.json](../readbacks/0104-onda38-2-filtros-menu-principal.json) (human_gate_failed) |
| Commit | `e9bcf42` (15 arquivos, 5/5 guards verdes) |
| Housekeeping pre-onda | commit `7e98926` - V12-204-Micro48 removida, AAX dirty descartada, CSVs/0103/AUDITORIA_ESCOPO untracked apagados |

### Resultado Onda 38.2.1

**Entregue**: import OK (`M=2|F=1|err=0|skip=0`); compile VBE limpo;
**erro 424 eliminado**; build label propagado; RVS Trio APROVADO
em `VR_20260526_024718` com `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0`.
Filtro de Empresa (TextBox17) funciona — handler nativo
`TextBox17_Change` pre-existente desde 38.1.5 confirma a hipotese
arquitetural da 38.2.2.

**Findings** (debitos abertos para ondas futuras, NAO regressao do 38.2):
- **F1** ID 001 cadastro empresa - causa em `Util_Planilha.ProximoId`
  + `EMPRESAS!AR1` dessincronizado - **Onda 38.2.1-AR1 (ativa)**.
- **F2** Cadastro entidade nova no topo - provavel mesmo bug AR1 em
  ENTIDADES - **Onda 38.2.1-AR1 (provavel cobre)**.
- **F3** Filtros faltantes (Entidade, Atribuicao Servico, etc.) -
  **Onda 38.2.2** (handlers nativos + funcao pura).
- **F4** Lentidao cadastros - **DEFERIDO V207**.

**Knowledge HBN nova**: `.hbn/knowledge/0015-readback-opening-bootstrap.md`
documenta licao sobre commit de abertura de onda safe_track e propoe
melhoria no `assert-scope-lock.sh`.

**Bastao**: continua com Claude Opus 4.7.

### Resumo da onda 38.2.1

**Causa**: a Onda 38.2 (commit 7bca168) introduziu WithEvents dinamico
para os filtros TextBox16..22 do Menu_Principal competindo com handlers
nativos `TextBoxNN_Change`. Resultado: erro 424 ao digitar, filtros
inconsistentes, suspeita de corrupcao de estado global (cadastro de
empresa retornando ID 001). Gate funcional reprovado por Mauricio; RVS
nao rodou por falha funcional anterior. Diagnostico Antigravity/Gemini
+ Opus anterior + Codex convergiram para REVERTER IMEDIATAMENTE.

**Acao**: revert forward-only (sem `git revert`). Restaurar
`src/vba/Menu_Principal.frm` e `src/vba/Preencher.bas` byte-a-byte do
anchor git `a6ad842` (Onda 38.1.5 estavel). Atualizar `App_Release.bas`
trocando apenas as strings `APP_BUILD_IMPORTADO` e `APP_BUILD_GERADO_EM`.
Sincronizar `local-ai/vba_import/` via `publicar_vba_import_v2.sh`.

**Fora de escopo** (deferido): implementar filtros novos (38.2.2),
investigar ID 001 (condicional ao gate humano da 38.2.1), Onda 39+ PDF.

**Arquitetura aprovada para 38.2.2** (apos 38.2.1 passar gate):
handlers nativos `TextBoxNN_Change` estaticos + funcao filtro PURA
stateless; ZERO WithEvents dinamico; ZERO Controls.Add; ZERO heuristica;
Clear+AddItem construtivo (nunca RemoveItem); variaveis locais; possivel
reuso de `Util_Filtro_Lista.bas`.

**Bastao**: Codex -> Claude Opus 4.7 (provisorio ate freeze V12.0.0206).
Codex volta como auditor adversarial pos-implementacao.

---

## Onda 38.2 REPROVADA NO GATE HUMANO — Filtros Menu Principal (Codex)

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0104-onda38-2-filtros-menu-principal.json](../readbacks/0104-onda38-2-filtros-menu-principal.json) |
| Hearback | confirmed — Mauricio aprovou recomendações e avanço em microdeltas pequenos antes da V207 |
| ERP | [results/0104-exec-onda38-2-filtros-menu-principal.json](../results/0104-exec-onda38-2-filtros-menu-principal.json) — delivered_for_human_gate |
| Doc tecnico | [38_2_TECNICO.md](../../auditoria/03_ondas/onda_38_2_filtros_menu_principal/38_2_TECNICO.md) |
| Manifesto delta | [000-MANIFESTO-V3-DELTA-ONDA38-2-FILTROS-MENU.txt](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-2-FILTROS-MENU.txt) |
| Build label | `a6ad842+ONDA38.2-filtros-menu` |

### Resultado Onda 38.2

- Prints em `local-ai/incoming/filtros/` confirmaram os filtros `TextBox16` a
  `TextBox22` no Menu Principal.
- `Menu_Principal.frm` declara ponteiros `Private WithEvents` para Entidade,
  Empresa, Atribuicao Servico, Pre-OS, Avaliacao, Cadastro de Servico e
  Atribuicao Empresa.
- `PreencherPreencheOS` e `PreencherAvaliarOS` recebem filtro opcional,
  preservando chamadas sem argumento.
- Nenhum `.frx`, controle de designer, regra de negocio, servico blindado ou
  contador RVS foi alterado.
- Antes do freeze V206, fica planejada passagem assistida tela a tela e botao a
  botao para fechar a interface e registrar melhorias V207.

## Onda 38.1.5 ENTREGUE PARA GATE HUMANO — Replay Rel_Emp_Serv protecao (Codex)

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0102-onda38-1-5-rel-emp-serv-protecao.json](../readbacks/0102-onda38-1-5-rel-emp-serv-protecao.json) |
| Hearback | confirmed — Mauricio aprovou microdelta minimo apos diagnostico de replay incompleto em workbook pre-38.1 |
| ERP | [results/0102-exec-onda38-1-5-rel-emp-serv-protecao.json](../results/0102-exec-onda38-1-5-rel-emp-serv-protecao.json) — human_gate_passed |
| Doc tecnico | [38_1_5_TECNICO.md](../../auditoria/03_ondas/onda_38_1_5_rel_emp_serv_protecao/38_1_5_TECNICO.md) |
| Manifesto delta | [000-MANIFESTO-V3-DELTA-ONDA38-1-5-REL-EMP-SERV-PROTECAO.txt](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-5-REL-EMP-SERV-PROTECAO.txt) |
| Build label | `696a8c2+ONDA38.1.5-rel-emp-serv-protecao` |

### Resultado Onda 38.1.5

- Reaplica `Rel_Emp_Serv.frm` corrigido no workbook restaurado de base anterior
  a 38.1.
- O delta 38.1.4 compilou, mas nao importava `Rel_Emp_Serv.frm`; por isso o
  erro de planilha protegida voltou no relatório Empresas por Serviço.
- Esta onda importa somente `AAK-Rel_Emp_Serv.frm` e `AAX-App_Release.bas`.
- `Rel_OSEmpresa.frm`, `.frx`, `Menu_Principal.frm`, `Preencher.bas` e serviços
  blindados permanecem intocados.
- Gate humano fechado por Mauricio: import `M=1 | F=1 | err=0 | skip=0`,
  compile VBE limpo, relatorios impressos corretamente e RVS
  `VR_20260525_204559` APROVADO com contadores preservados.

## Onda 38.1.4 ENTREGUE PARA GATE HUMANO — Restauracao Rel_OSEmpresa (Codex)

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0101-onda38-1-4-restaura-rel-os-empresa.json](../readbacks/0101-onda38-1-4-restaura-rel-os-empresa.json) |
| Hearback | confirmed — Mauricio aprovou restauracao real e documentacao da licao aprendida |
| ERP | [results/0101-exec-onda38-1-4-restaura-rel-os-empresa.json](../results/0101-exec-onda38-1-4-restaura-rel-os-empresa.json) — delivered_for_human_gate |
| Doc tecnico | [38_1_4_TECNICO.md](../../auditoria/03_ondas/onda_38_1_4_restaura_rel_os_empresa/38_1_4_TECNICO.md) |
| Manifesto delta | [000-MANIFESTO-V3-DELTA-ONDA38-1-4-RESTAURA-REL-OS-EMPRESA.txt](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-4-RESTAURA-REL-OS-EMPRESA.txt) |
| Build label | `8d5e2e6+ONDA38.1.4-restaura-rel-os-empresa` |

### Resultado Onda 38.1.4

- `Rel_OSEmpresa.frm` foi restaurado ao conteudo compilavel da Onda 38.1.2
  (`35775b3`), preservando `B_RelMEIOS_Click`.
- Mudancas da 38.1.3 foram removidas: `Var8 As Variant`,
  `Util_Conversao.ToDouble` e `NumberFormat = "0.00"` na coluna H.
- Knowledge L11 adicionada em
  `.hbn/knowledge/0009-licoes-importador-v3-phase1.md`: manifesto delta antigo
  aponta para arquivo vivo, nao para snapshot historico.
- Proximo gate: reabrir workbook limpo, importar delta 38.1.4, compile VBE,
  `CT_ValidarRelease_TrioMinimo`.

## Onda 38.1.3 ENTREGUE PARA GATE HUMANO — Nota Total decimal (Codex)

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0100-onda38-1-3-nota-total-decimal.json](../readbacks/0100-onda38-1-3-nota-total-decimal.json) |
| Hearback | confirmed — Mauricio aprovou escopo minimo: duas casas decimais na Nota Total, sem alterar calculos nem cabecalho |
| ERP | [results/0100-exec-onda38-1-3-nota-total-decimal.json](../results/0100-exec-onda38-1-3-nota-total-decimal.json) — human_gate_failed |
| Doc tecnico | [38_1_3_TECNICO.md](../../auditoria/03_ondas/onda_38_1_3_nota_total_decimal/38_1_3_TECNICO.md) |
| Manifesto delta | [000-MANIFESTO-V3-DELTA-ONDA38-1-3-NOTA-TOTAL-DECIMAL.txt](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-3-NOTA-TOTAL-DECIMAL.txt) |
| Build label | `35775b3+ONDA38.1.3-nota-total-decimal` |

### Resultado Onda 38.1.3

- `Rel_OSEmpresa.frm` preserva o cabecalho `NOTA TOTAL`.
- A coluna H do relatorio passa a receber valor numerico quando preenchida.
- A coluna H recebe `NumberFormat = "0.00"` e alinhamento a direita, mantendo
  duas casas decimais no PDF.
- Nenhum calculo, servico, `.frx`, `Menu_Principal.frm`, `Preencher.bas` ou
  `Rel_Emp_Serv.frm` foi tocado.
- Gate humano: import delta passou, mas o Excel fechou durante compile VBE.
  Tentativa de reimportar manifesto antigo 38.1.2 tambem nao restaurou, pois o
  manifesto apontava para arquivo vivo ja alterado pela 38.1.3.
- Substituida pela Onda 38.1.4 de restauracao real.

## Onda 38.1.2 ENTREGUE PARA GATE HUMANO — Botao real Rel_OSEmpresa (Codex)

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0099-onda38-1-2-rel-os-empresa-botao-real.json](../readbacks/0099-onda38-1-2-rel-os-empresa-botao-real.json) |
| Hearback | confirmed — Mauricio confirmou screenshot do VBE com CommandButton `B_RelMEIOS` e aprovou correcao |
| ERP | [results/0099-exec-onda38-1-2-rel-os-empresa-botao-real.json](../results/0099-exec-onda38-1-2-rel-os-empresa-botao-real.json) — human_gate_passed |
| Doc tecnico | [38_1_2_TECNICO.md](../../auditoria/03_ondas/onda_38_1_2_rel_os_empresa_botao_real/38_1_2_TECNICO.md) |
| Manifesto delta | [000-MANIFESTO-V3-DELTA-ONDA38-1-2-REL-OS-EMPRESA-BOTAO.txt](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-2-REL-OS-EMPRESA-BOTAO.txt) |
| Build label | `10ef253+ONDA38.1.2-rel-os-empresa-botao` |

### Resultado Onda 38.1.2

- `Rel_OSEmpresa.frm` agora tem `B_RelMEIOS_Click`, handler do botao real
  confirmado no VBE.
- `B_RelEmpresaOS_Click` permanece como compatibilidade e ambos chamam
  `AcionarRelatorioOSEmpresa`.
- `Rel_OSEmpresa.frx` nao foi tocado.
- `Rel_Emp_Serv.frm` permanece congelado; Mauricio confirmou que `Nao =
  cancelar` funcionou corretamente na Onda 38.1.1.
- Proximo gate: import delta, compile VBE, `CT_ValidarRelease_TrioMinimo` e
  PDF de OS por Empresa pelo botao `Imprimir Relatorio`.

## Onda 38.1.1 ENTREGUE PARA GATE HUMANO — Hotfix relatorios (Codex)

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0098-onda38-1-1-relatorios-hotfix.json](../readbacks/0098-onda38-1-1-relatorios-hotfix.json) |
| Hearback | confirmed — Mauricio confirmou escopo e aprovou as mudanças |
| ERP | [results/0098-exec-onda38-1-1-relatorios-hotfix.json](../results/0098-exec-onda38-1-1-relatorios-hotfix.json) — delivered_for_human_gate |
| Doc tecnico | [38_1_1_TECNICO.md](../../auditoria/03_ondas/onda_38_1_1_relatorios_hotfix/38_1_1_TECNICO.md) |
| Manifesto delta | [000-MANIFESTO-V3-DELTA-ONDA38-1-1-RELATORIOS-HOTFIX.txt](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-1-RELATORIOS-HOTFIX.txt) |
| Build label | `6103cab+ONDA38.1.1-relatorios-hotfix` |

### Resultado Onda 38.1.1

- `Rel_Emp_Serv.frm` remove `PrintPreview`; `Sim` imprime e `Nao` cancela
  limpo sem travar a interface.
- `Rel_OSEmpresa.frm` preenche `Dt_inicial` automaticamente com o primeiro dia
  do mes de sete meses atras, normaliza `dd/mm/aaaa`, `ddmmaaaa` e `ddmmaa`, e
  filtra por periodo desde a data inicial.
- `Rel_OSEmpresa.frm` troca a busca `Find` + bloco contiguo por varredura
  completa de `CAD_OS`, comparando empresa com `IdsIguais`.
- `App_Release.bas` carimbado com
  `6103cab+ONDA38.1.1-relatorios-hotfix`.
- Proximo gate: import delta, compile VBE, `CT_ValidarRelease_TrioMinimo`,
  Empresas por Servico (`Sim` imprime, `Nao` cancela) e OS por Empresa (data
  padrao + impressao do periodo).

## Onda 38.1 IMPLEMENTADA LOCALMENTE — Relatorios protecao e impressao (Codex)

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0097-onda38-1-relatorios-protecao-impressao.json](../readbacks/0097-onda38-1-relatorios-protecao-impressao.json) |
| Hearback | confirmed — Mauricio aprovou executar Onda 38.1 e 38.2; 38.1 separa correcao funcional urgente |
| ERP | [results/0097-exec-onda38-1-relatorios-protecao-impressao.json](../results/0097-exec-onda38-1-relatorios-protecao-impressao.json) — human_gate_rvs_pass_functional_pending |
| Doc tecnico | [38_1_TECNICO.md](../../auditoria/03_ondas/onda_38_1_relatorios_protecao_impressao/38_1_TECNICO.md) |
| Manifesto delta | [000-MANIFESTO-V3-DELTA-ONDA38-1-RELATORIOS-PROTECAO.txt](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-RELATORIOS-PROTECAO.txt) |
| Build label | `cf778b2+ONDA38.1-relatorios-protecao` |

### Resultado Onda 38.1

- `Rel_OSEmpresa.frm` agora gera o relatorio no botao `Imprimir Relatorio`,
  usando a empresa selecionada e a data atual digitada em `Dt_inicial`.
- `RO_Lista_Click` passa a ser selecao simples, sem gerar relatorio pesado.
- `Rel_Emp_Serv.frm` prepara/restaura protecao da aba `RELATORIO`, limpa
  residuos e define `PrintArea` para evitar colunas de relatorio anterior.
- Os dois forms aplicam formatacao minima com `Rel_FormatarCabecalho` e
  `Rel_FormatarDados`.
- Importacao `ONDA38-1-RELATORIOS-PROTECAO` passou com `M=1 | F=2 | err=0 | skip=0`.
- Compile VBE passou limpo.
- RVS `VR_20260525_124700` APROVADO com contadores preservados.
- Onda 38.2 fica deferida ate Mauricio confirmar os dois gates funcionais dos
  relatorios.

## Onda 38 IMPLEMENTADA LOCALMENTE — MD33 restart Relatorios (Codex)

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0094-onda38-md33-restart-rel-os-rel-emp-serv.json](../readbacks/0094-onda38-md33-restart-rel-os-rel-emp-serv.json) |
| Hearback | confirmed — Mauricio aprovou escopo expandido em 2026-05-25 |
| ERP | [results/0094-exec-onda38-md33-restart-rel-os-rel-emp-serv.json](../results/0094-exec-onda38-md33-restart-rel-os-rel-emp-serv.json) — implemented_awaiting_commit_and_human_gate |
| Doc tecnico | [38_TECNICO.md](../../auditoria/03_ondas/onda_38_md33_restart_rel_os_rel_emp_serv/38_TECNICO.md) |
| Prompt auditoria | [38_PROMPT_AUDITORIA_CRUZADA_OPUS_GEMINI.md](../../auditoria/03_ondas/onda_38_md33_restart_rel_os_rel_emp_serv/38_PROMPT_AUDITORIA_CRUZADA_OPUS_GEMINI.md) |
| Consolidado auditoria | [39_CONSOLIDADO_AUDITORIA_CRUZADA.md](../../auditoria/03_ondas/onda_38_md33_restart_rel_os_rel_emp_serv/39_CONSOLIDADO_AUDITORIA_CRUZADA.md) |
| Manifesto delta | [000-MANIFESTO-V3-DELTA-ONDA38-MD33-RESTART.txt](../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-MD33-RESTART.txt) |
| Build label | `e43352f+ONDA38.MD33-restart-relatorios` |

### Resultado Onda 38

- `Menu_Principal.frm` agora cria `Rel_OSEmpresa` e `Rel_Emp_Serv` via
  `VBA.UserForms.Add` antes de chamar as rotinas de preenchimento.
- `Preencher.bas` nao cria instancia fallback invisivel para
  `Rel_OSEmpresa`; ambos os preenchimentos dependem da instancia exibida ja
  registrada em `VBA.UserForms`.
- `Rel_OSEmpresa.frm`, `Rel_Emp_Serv.frm` e arquivos `.frx` permaneceram
  intocados.
- Auditorias Opus e Gemini/Antigravity aprovadas com ressalvas resolvidas:
  `Rel_EmpXServ_Click` nao faz unload imediato apos `.Show`, vazamento 37.2
  revertido, locks Git limpos e readback sucessor 0096 criado.
- Proximo gate: guards finais, commit/import delta, compile VBE e
  `CT_ValidarRelease_TrioMinimo`.

## Onda 37.3 EM EXECUCAO — Reset src/vba para V5 (Opus, bastao recebido de Codex)

| Campo | Valor |
|---|---|
| Track | safe_track (reset estrutural de src/vba e local-ai/vba_import) |
| Readback | [readbacks/0093-onda37-3-reset-src-vba-para-v5.json](../readbacks/0093-onda37-3-reset-src-vba-para-v5.json) |
| Hearback | confirmed (Mauricio em chat 2026-05-24 apos falha de compile pos-37.2) |
| ERP | [results/0093-exec-onda37-3-reset-src-vba-para-v5.json](../results/0093-exec-onda37-3-reset-src-vba-para-v5.json) — delivered_for_human_gate |
| Doc tecnico | [auditoria/03_ondas/onda_37_3_reset_src_vba_v5/37_3_TECNICO.md](../../auditoria/03_ondas/onda_37_3_reset_src_vba_v5/37_3_TECNICO.md) |
| Backup pre-reset | [backup_pre_reset/](../../auditoria/03_ondas/onda_37_3_reset_src_vba_v5/backup_pre_reset/) (66 arquivos + manifest SHA-256) |
| Manifest incoming V5 | [manifest_incoming_v5.sha256.csv](../../auditoria/03_ondas/onda_37_3_reset_src_vba_v5/manifest_incoming_v5.sha256.csv) (64 arquivos validados) |
| Estado src/vba apos reset | 64 arquivos = paridade exata com export V5 (verificado via diff -rq vazio) |
| Workbook V5 .xlsm | INTACTO no disco (operador fechou sem salvar) |
| local-ai/incoming/ | INTACTO (read-only) |
| Bastao apos compile OK | volta para Codex (Onda 38 = MD33-restart correto sobre base V5 limpa) |



## Onda 37.2 ENTREGUE PARA GATE HUMANO — Reversao drift MD33 (Codex)

| Campo | Valor |
|---|---|
| Track | safe_track (toca VBA e pacote importavel declarado) |
| Readback | [readbacks/0092-onda37-2-reversao-md33.json](../readbacks/0092-onda37-2-reversao-md33.json) |
| Hearback | confirmed — Mauricio informou aprovacao do readback 0092 no chat |
| ERP | [results/0092-exec-onda37-2-reversao-md33.json](../results/0092-exec-onda37-2-reversao-md33.json) |
| Doc tecnico | [37_2_TECNICO.md](../../auditoria/03_ondas/onda_37_2_reversao_md33/37_2_TECNICO.md) |
| Procedimento | [37_2_PROCEDIMENTO_IMPORT.md](../../auditoria/03_ondas/onda_37_2_reversao_md33/37_2_PROCEDIMENTO_IMPORT.md) |

### Resultado Onda 37.2

- `src/vba/Importador_V3.bas`, `src/vba/Menu_Principal.frm` e
  `src/vba/Preencher.bas` foram restaurados ao estado equivalente ao export
  V5.
- Espelhos declarados em `local-ai/vba_import/` foram atualizados para o gate
  humano; a importacao operacional deve vir somente dessa pasta.
- `local-ai/incoming/`, `backups/vba/`, workbook V5 e `Menu_Principal.frx`
  permaneceram intactos.
- ERP esta em `delivered_for_human_gate`, com compile VBE pendente de
  confirmacao humana.

🟠 SOURCE DRIFT DETECTED: a reversao corrige o drift MD33 descartavel em
`src/vba/`, mas a confirmacao final depende do VBE detectar se ha qualquer
dessincronizacao residual entre `.frm` e `.frx`.

## Onda 37.1 EXECUTADA — Decisoes de drift e licoes MD33 (Codex)

| Campo | Valor |
|---|---|
| Track | fast_track (documental, sem tocar VBA) |
| Readback | [readbacks/0091-onda37-1-decisoes-drift.json](../readbacks/0091-onda37-1-decisoes-drift.json) |
| Hearback | confirmed — Mauricio informou aprovacao e criacao do readback com auditoria Opus |
| ERP | [results/0091-exec-onda37-1-decisoes-drift.json](../results/0091-exec-onda37-1-decisoes-drift.json) |
| Matriz | [classificacao_drift_funcional.md](../../auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/classificacao_drift_funcional.md) |
| Doc tecnico | [37_1_TECNICO.md](../../auditoria/03_ondas/onda_37_1_decisoes_drift/37_1_TECNICO.md) |
| Proposta | [PROPOSTA_ONDA_37_2_SAFE_TRACK.md](../../auditoria/03_ondas/onda_37_1_decisoes_drift/PROPOSTA_ONDA_37_2_SAFE_TRACK.md) |

### Resultado Onda 37.1

- `drift_md33_descartar=3`: `Importador_V3.bas`, `Menu_Principal.frm`, `Preencher.bas`.
- `drift_legitimo_anterior_v5=25`: sem commits pos-V205; cruzados contra linhas/ondas fechadas.
- `drift_misto=0`.
- `drift_inesperado_investigar=0`; nenhum arquivo exigiu decisao humana individual nessa classe.
- ADRs produzidos: remocao futura de `Importador_V2.bas` e pendencia documentada de `Emergencia_CNAE.bas` fora da V206.

🟠 SOURCE DRIFT DETECTED: a cadeia MD33 deixou `src/vba/` com drift que nao representa a unica ancora compilavel conhecida (V5). A correcao deve ser uma nova onda safe_track, nao import direto.


## Onda 37 EXECUTADA — Reconciliacao V5 vs src/vba (Codex)

| Campo | Valor |
|---|---|
| Track | safe_track (evidencia/auditoria, sem tocar VBA) |
| Readback | [readbacks/0090-onda37-reconciliacao-v5.json](../readbacks/0090-onda37-reconciliacao-v5.json) |
| Hearback | confirmed — Mauricio informou aprovacao de Opus (audit) e Mauricio (hearback) no chat de 2026-05-24 |
| ERP | [results/0090-exec-onda37-reconciliacao-v5.json](../results/0090-exec-onda37-reconciliacao-v5.json) |
| Evidencia | [manifest.sha256.csv](../../auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/manifest.sha256.csv) |
| Classificacao | [classificacao.md](../../auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/classificacao.md) |
| Doc tecnico | [37_TECNICO.md](../../auditoria/03_ondas/onda_37_reconciliacao_v5/37_TECNICO.md) |

### Resultado Onda 37

- `src/vba/`: 66 arquivos analisados.
- Export V5: 64 arquivos analisados.
- Classes: `igual=8`, `drift_export_benigno=28`, `diferenca_funcional=28`, `ausente_no_workbook=0`, `obsoleto_no_repo=1`, `precisa_decisao_humana=1`.
- `Altera_Entidade.frm/.frx` estao presentes no export atual da V5; isso corrige o metadata drift do handoff anterior.
- `Importador_V2.bas` classificado como `obsoleto_no_repo` com referencia documental de nao reintegracao.
- `Emergencia_CNAE.bas` classificado como `precisa_decisao_humana`.

🟡 HBN NEEDS HUMAN DECISION: decidir o destino de `Emergencia_CNAE.bas` antes de qualquer onda que mexa em pacote importavel ou remocao de arquivo.


## Onda 36 FECHADA — Cura do Protocolo (Claude Opus 4.7)

| Campo | Valor |
|---|---|
| Track | safe_track (governança, sem tocar VBA) |
| Readback | [readbacks/0089-onda36-cura-protocolo-opus.json](../readbacks/0089-onda36-cura-protocolo-opus.json) |
| Hearback | confirmed — confirmado antes da retomada da Onda 37 |
| ERP | [results/0089-exec-onda36-cura-protocolo-opus.json](../results/0089-exec-onda36-cura-protocolo-opus.json) |
| Auditoria-mãe | [auditoria/00_status/105_AUDITORIA_HANDOFF_V206_V207_USEHBN_CLAUDE_OPUS.md](../../auditoria/00_status/105_AUDITORIA_HANDOFF_V206_V207_USEHBN_CLAUDE_OPUS.md) |
| Devolutiva ao Codex | [auditoria/00_status/106_DEVOLUTIVA_OPUS_PROMPT_RETOMADA_CODEX_V206.md](../../auditoria/00_status/106_DEVOLUTIVA_OPUS_PROMPT_RETOMADA_CODEX_V206.md) |
| Roadmap protocolo | [auditoria/02_planos/34_ROADMAP_PROTOCOLO_90_DIAS_OPUS.md](../../auditoria/02_planos/34_ROADMAP_PROTOCOLO_90_DIAS_OPUS.md) |
| Plano arquivamento | [auditoria/02_planos/35_PLANO_ARQUIVAMENTO_LOCAL_AI_E_V12_PASTAS.md](../../auditoria/02_planos/35_PLANO_ARQUIVAMENTO_LOCAL_AI_E_V12_PASTAS.md) |
| Knowledge nova | [knowledge/0013-contratos-executaveis.md](../knowledge/0013-contratos-executaveis.md) |

### Entregáveis Onda 36 (todos prontos)

- `.hbn/canonical-root` — path canônico declarativo
- `.hbn/forbidden-paths.txt` — paths legacy bloqueados em commits novos
- `.hbn/schemas/` — readback + hearback + audit-pre + audit-post + README
- `scripts/hbn-guards/` — 5 guards + lib + runner + install + README
- `AGENTS.md` — seção "Contratos executáveis" + lista de leitura atualizada
- `.hbn/knowledge/0013-contratos-executaveis.md` — regra permanente
- 4 documentos canônicos (105, 106, 34, 35)

### Próxima ação após hearback Onda 36

Bastão passa para **Codex**, em sessão nova, para executar **Onda 37 — Reconciliação V5 vs src/vba** sob o novo contrato. Prompt em [auditoria/00_status/106_DEVOLUTIVA_OPUS_PROMPT_RETOMADA_CODEX_V206.md](../../auditoria/00_status/106_DEVOLUTIVA_OPUS_PROMPT_RETOMADA_CODEX_V206.md). Codex precisa produzir `.hbn/readbacks/0090-onda37-reconciliacao-v5.json` e aguardar hearback antes de qualquer execução.



## P0 corrigido — raiz canonica do projeto

Em 2026-05-24 foi identificado que a branch
`codex/v12-0-0206-planejamento` estava sendo executada no worktree
`/private/tmp/cred-v205`, enquanto o workbook e o Importador V3 apontavam para
`\\Mac\Home\Projetos\Credenciamento`. Isso quebrava a fonte unica de verdade:
os deltas V206 existiam no tmp, mas o operador e o backup obrigatorio do
workbook liam a pasta do projeto.

Correcao aplicada:

- `/private/tmp/cred-v205` foi removido como worktree ativo.
- A branch `codex/v12-0-0206-planejamento` agora esta em
  `/Users/macbookpro/Projetos/Credenciamento`.
- Os deltas V206 feitos no tmp foram resgatados e reaplicados na pasta
  canonica.
- Evidencias de resgate e colisao ficaram em
  `backups/raiz_canonica/20260524_134722/`.
- A regra permanente foi registrada em
  [`.hbn/knowledge/0012-raiz-canonica-projeto.md`](../knowledge/0012-raiz-canonica-projeto.md)
  e em [`AGENTS.md`](../../AGENTS.md).

Preflight obrigatorio para qualquer IA:

```bash
pwd
git rev-parse --show-toplevel
git status --short --branch
git worktree list
```

Se `pwd` ou `git rev-parse --show-toplevel` forem diferentes de
`/Users/macbookpro/Projetos/Credenciamento`, a IA deve parar e registrar P0.

## Anchor V5 — reinicio operacional V206

Em 2026-05-24, o operador descartou a rota de `V12-0206-Preparacao` porque a
planilha tambem nao compilava. A nova ancora operacional local e:

```text
/Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-Homologacao-V5.xlsm
```

Origem declarada:

```text
/Users/macbookpro/Projetos/Credenciamento/V12-205-OficialCongelada
```

Confirmacoes humanas:

- `?ThisWorkbook.Path` retornou `\\Mac\Home\Projetos\Credenciamento`;
- `ImportarPacoteV3_Status` encontrou o manifesto em `local-ai\vba_import`;
- `GetReleaseTag` retornou `v12.0.0205`;
- `GetReleaseAtual` retornou `V12.0.0205`;
- `GetReleaseAlvo` retornou `V12.0.0206`;
- `GetBuildImportado` retornou
  `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix`;
- Gate RVS `VR_20260524_164612` APROVADO com assinatura
  `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.

Status canonico:

- a V5 e workbook local ignorado pelo Git;
- `src/vba/` segue como fonte versionada da verdade;
- `local-ai/vba_import/` segue como unica fonte operacional de import;
- antes de qualquer novo microdelta, exportar V5 para
  `local-ai/incoming/V206_ANCHOR_V5_20260524/` e comparar contra `src/vba/`;
- nao usar os manifestos MD33/fix1/fix2 reprovados na V5.

Referencia: [`../../auditoria/00_status/101_ANCHOR_V5_REINICIO_V206_CODEX.md`](../../auditoria/00_status/101_ANCHOR_V5_REINICIO_V206_CODEX.md).

## Bastao Claude Opus 4.7 — auditoria antes de executar

Em 2026-05-24, apos o export bruto da V5, o operador solicitou passagem de
bastao para Claude Opus 4.7 revisar o handoff, ajustar o protocolo de entrada
useHBN e propor barreiras reais entre IAs antes de qualquer nova implementacao.

Documentos de entrada:

- [`../../auditoria/00_status/102_HANDOFF_CLAUDE_OPUS_47_V206_V207_USEHBN_CODEX.md`](../../auditoria/00_status/102_HANDOFF_CLAUDE_OPUS_47_V206_V207_USEHBN_CODEX.md)
- [`../../auditoria/00_status/103_PROMPT_AUDITORIA_CLAUDE_OPUS_47_HANDOFF_V206_V207_USEHBN.md`](../../auditoria/00_status/103_PROMPT_AUDITORIA_CLAUDE_OPUS_47_HANDOFF_V206_V207_USEHBN.md)
- [`../../auditoria/00_status/104_PROMPT_RETOMADA_CODEX_V206_NOVO_CONTEXTO.md`](../../auditoria/00_status/104_PROMPT_RETOMADA_CODEX_V206_NOVO_CONTEXTO.md)
- [`../../auditoria/02_planos/33_ROADMAP_V207_CODE_REVIEW_REFORMULACAO.md`](../../auditoria/02_planos/33_ROADMAP_V207_CODE_REVIEW_REFORMULACAO.md)

Codex nao deve retomar implementacao funcional ate que exista:

```text
auditoria/00_status/105_AUDITORIA_HANDOFF_V206_V207_USEHBN_CLAUDE_OPUS.md
```

e o operador aprove a devolutiva.

## V12.0.0205 — ciclo ativo de estabilização

| Campo | Valor |
|---|---|
| Branch | `main` após tag `v12.0.0205` |
| Base canônica | `e43352f` |
| Versão oficial anterior | `V12.0.0204` |
| Status V205 | VALIDADO/OFICIAL congelada para produção; compile VBE pós-MICRO61 e Gate RVS final aprovados |
| Guard funcional | `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` |
| Evidência final | `VR_20260523_215637` |
| Readback | [`../../auditoria/00_status/76_READBACK_ABERTURA_V205_CODEX.md`](../../auditoria/00_status/76_READBACK_ABERTURA_V205_CODEX.md) |
| Roadmap | [`../../auditoria/02_planos/30_ROADMAP_V205_PRODUCAO.md`](../../auditoria/02_planos/30_ROADMAP_V205_PRODUCAO.md) |
| ERPs | [`../results/0069-exec-onda26-v205-md26-1-governanca-tooling-abertura.json`](../results/0069-exec-onda26-v205-md26-1-governanca-tooling-abertura.json), [`../results/0070-exec-onda27-v205-md27-1-rvs-labels-csv-prefix.json`](../results/0070-exec-onda27-v205-md27-1-rvs-labels-csv-prefix.json), [`../results/0073-exec-onda28-v205-md28-2-rvs-aprovado.json`](../results/0073-exec-onda28-v205-md28-2-rvs-aprovado.json), [`../results/0075-exec-onda29-v205-md29-2-af3-freeze.json`](../results/0075-exec-onda29-v205-md29-2-af3-freeze.json), [`../results/0076-exec-onda29-v205-md29-3-freeze-publicacao.json`](../results/0076-exec-onda29-v205-md29-3-freeze-publicacao.json) |

### Limites do bastão V205

- Permitido: documentação, índices, CI/CD de consistência, labels de UI,
  prefixos/pastas de evidência e metadados de fechamento.
- Bloqueado: lógica de rodízio, persistência, cálculo, avaliação, OS,
  renomeação de símbolos VBA, PDF automático via VBA e refatoração estrutural.
- Fechamento oficial: Gate RVS final e compile VBE pós-MICRO61 aprovados. A
  V12.0.0205 está pronta para tag/publicação e a próxima linha é V12.0.0206.

## V12.0.0206 — ciclo de planejamento

| Campo | Valor |
|---|---|
| Branch | `codex/v12-0-0206-planejamento` |
| Base | `v12.0.0205` / commit `f24e535` |
| Status | Roadmap aprovado; Onda 31 documental executada; Onda 32 consolidou auditoria cruzada PDF/UI; Onda 33 pausada apos tres imports OK e compile crash; retomada reancorada na V5 derivada de V12-205-OficialCongelada com RVS aprovado |
| Roadmap preliminar | [`../../auditoria/02_planos/31_ROADMAP_V206_PRELIMINAR.md`](../../auditoria/02_planos/31_ROADMAP_V206_PRELIMINAR.md) |
| Roadmap consolidado | [`../../auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md`](../../auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md) |
| Readback | [`../../auditoria/00_status/83_READBACK_ABERTURA_V206_CODEX.md`](../../auditoria/00_status/83_READBACK_ABERTURA_V206_CODEX.md) |
| Prompts planejamento | [`../../auditoria/00_status/84_PROMPT_PLANEJAMENTO_V206_CLAUDE_OPUS.md`](../../auditoria/00_status/84_PROMPT_PLANEJAMENTO_V206_CLAUDE_OPUS.md), [`../../auditoria/00_status/85_PROMPT_PLANEJAMENTO_V206_GEMINI_ANTIGRAVITY.md`](../../auditoria/00_status/85_PROMPT_PLANEJAMENTO_V206_GEMINI_ANTIGRAVITY.md), [`../../auditoria/00_status/91_PROMPT_RETOMADA_CODEX_V206_NOVO_CHAT.md`](../../auditoria/00_status/91_PROMPT_RETOMADA_CODEX_V206_NOVO_CHAT.md) |
| PDF/UI | [`../../auditoria/00_status/92_PROMPT_AUDITORIA_PDF_UI_V206_CLAUDE_OPUS.md`](../../auditoria/00_status/92_PROMPT_AUDITORIA_PDF_UI_V206_CLAUDE_OPUS.md), [`../../auditoria/00_status/93_PROMPT_AUDITORIA_ADVERSARIAL_PDF_UI_V206_GEMINI.md`](../../auditoria/00_status/93_PROMPT_AUDITORIA_ADVERSARIAL_PDF_UI_V206_GEMINI.md), [`../../auditoria/00_status/94_PROMPT_CONSOLIDACAO_PDF_UI_V206_CODEX.md`](../../auditoria/00_status/94_PROMPT_CONSOLIDACAO_PDF_UI_V206_CODEX.md), [`../../auditoria/00_status/97_CONSOLIDACAO_PDF_UI_V206_CODEX.md`](../../auditoria/00_status/97_CONSOLIDACAO_PDF_UI_V206_CODEX.md) |
| Anchor V5 | [`../../auditoria/00_status/101_ANCHOR_V5_REINICIO_V206_CODEX.md`](../../auditoria/00_status/101_ANCHOR_V5_REINICIO_V206_CODEX.md) |

### Limites preliminares V206

- Permitido: PDF automático robusto, ajustes manuais, evidências, Importador V3,
  documentação e pequenos débitos técnicos.
- Bloqueado: code review profundo, performance estrutural, componentização,
  preparação SaaS e renomeações internas amplas; esses itens ficam para
  V12.0.0207 salvo nova decisão humana.

> ⚠️ **REGRA INVIOLAVEL (M11 destilada 2026-05-03)**: A IA le `src/vba/`
> (fonte de verdade — AGENTS.md §62-63) e transporta para
> `local-ai/vba_import/` (espelho com prefixos). NUNCA o inverso.
> Cada microdelta valida `shasum src/vba/X == shasum local-ai/vba_import/<prefixo>-X`
> antes de declarar gate. Esta regra ja causou regressao em
> 2026-05-02 (lição M11) e em 2026-05-02 ondas anteriores
> (auditoria 32). Ver `auditoria/00_status/43c_LICAO_FONTE_DE_VERDADE_VS_ESPELHO.md`.

## Onda 11 FECHADA — V12.0.0203-rc1 (2026-05-02 06:50 BRT)

> ✅ **PUBLICADA NO GITHUB** — tag `v12.0.0203-rc1` em
> `https://github.com/rwv8gscs8g-blip/credenciamento`. Validacao
> Quarteto pos-import: `VR_20260502_063028 = APROVADO`
> com sintaxe `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0`.

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0011-onda11-v203-rc1-closure.json](../readbacks/0011-onda11-v203-rc1-closure.json) |
| Hearback | confirmed (Q1-Q7' aprovados em chat 2026-05-02; "Pode comecar a implementacao" + "Confirmo e aprovo de Q5 a Q7. Pode implementar") |
| ERP | [results/0011-exec-onda11.json](../results/0011-exec-onda11.json) |
| Fechamento | [auditoria/03_ondas/onda_11_v203_rc1_closure/70_FECHAMENTO_ONDA_11.md](../../auditoria/03_ondas/onda_11_v203_rc1_closure/70_FECHAMENTO_ONDA_11.md) |
| Drift G7 residual (D1) | [auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md](../../auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md) — 23 arquivos divergentes para Ondas 12-16 caso-a-caso |
| Origem | Cadeia Antigravity → Codex (2026-05-02) revelou drift G7 entre src/vba e local-ai/vba_import nos 6 modulos do dominio strikes |
| Renumeracao | Onda 11 corretiva (esta) substitui Onda 11 original (CNAE), que vira Onda 12+ |
| Deadline hard | Domingo 2026-05-03 23:59 BRT |
| **Deadline atendido** | **sim — fechada em 2026-05-02** |
| **Status microdeltas** | **8/8 ENTREGUES** — ver tabela abaixo |
| **Build label final** | `f7aa84f+v12.0.0203-rc1` |
| **APP_RELEASE_TAG** | `v12.0.0203-rc1` |
| **APP_RELEASE_STATUS** | `RELEASE_CANDIDATE` |
| **APP_RELEASE_TEST_KEY** | `quarteto-2026-05-02` (Quarteto = gate oficial conforme Q7 operador) |
| **Gate oficial** | `CT_ValidarRelease_QuartetoMinimo` (V1+V2_Smoke+V2_Canonica+E2E_Strikes) |
| **Validacao final** | `VR_20260502_054314` = APROVADO; sintaxe `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0` |
| Ancora estavel atual | **V12-202-Z** (backup operador apos MD-2.3 verde) — build `f7aa84f+ONDA11.MD2-3-DT3-cleanup-config-incremental` |
| Validacao intermediaria | VR_20260502_034422 = APROVADO (V1=171/0 + V2 Smoke=14/0 + V2 Canonica=20/0); TV2_20260502_040156 = E2E STRIKES 64/0 |
| **Pendente operador** | ✅ CONCLUÍDO 2026-05-02 06:50 — Quarteto APROVADO `VR_20260502_063028`, tag `v12.0.0203-rc1` publicada em `https://github.com/rwv8gscs8g-blip/credenciamento` |
| **Onda 11 fisicamente fechada** | 2026-05-02 06:50 BRT |
| Protocolo HBN | V2 vigente — ver [knowledge/0005-protocolo-markers-v2.md](../knowledge/0005-protocolo-markers-v2.md) |
| Cadeia Antigravity → Codex (esta sessao) | local-ai/Time_AI/2026-05-02-V203-fechamento/ (gitignored) |
| Phagocytosis decisao | Proposta A + campos de capsule da D — chat-novo-usehbn implementa em paralelo a partir de 2026-05-02 |
| DT-6 NOVO | Validacao UI Configuracao_Inicial parametrizada — V12.0.0204; spec em auditoria/00_status/36_SPEC_DT6_Validacao_UI_Configuracao_V12_0204.md |
| Automacao semanal | Wave 11+ (segunda 2026-05-04): Typer + uv + GitHub Actions + signed commits PR-only |
| Fora de escopo | DT-2, DT-4 (Ondas 13+); DT-5 PDFs (V12.0.0204); DT-6 (V12.0.0204); reincorporacao Ondas 2-8 originais (Ondas 12+) |

### Microdeltas Onda 11 — entregues (8/8 + tag pendente)

| ID | Tema | Build label | Validacao | Status |
|---|---|---|---|---|
| **MD-0** | Drift G7 sync — 6 arquivos canonicos copiados de volta para src/vba | (sem bump — sincronizacao) | shasum 6/6 match | ✅ APROVADO |
| **MD-1** | Instrumentacao E2E DT-3 — 5 markers DIAG_* por rodada em TV2_E2E_AtenderProximaEmpresa | `ONDA11.MD1-DT3-diagnostic-incremental` | TV2_RunSmoke 14/0 + E2E rodou capturando evidencia | ✅ APROVADO |
| **MD-2** | Fix A (Select Case tolerante a padding "1"↔"001") + Fix B (CONFIG MAX_STRIKES=3, DIAS=90 no contexto E2E) | `ONDA11.MD2-DT3-fix-test-helper-incremental` | E2E 12 falhas → 1 falha (regressao reduzida) | ✅ APROVADO |
| **MD-2.2** | Asserts da verdade matematica — Etapa E sem loop, valores reais (1, 3, 3) com comentario-vacina | `ONDA11.MD2-2-DT3-asserts-fatos-incremental` | E2E 64/0 (primeira vez); trio falhou por vazamento CONFIG → MD-2.3 | ✅ APROVADO |
| **MD-2.3** | Anti-vazamento de CONFIG — helper TV2_E2E_RestaurarConfigBaseline em sucesso + falha | `ONDA11.MD2-3-DT3-cleanup-config-incremental` | VR_20260502_034422 trio APROVADO (171/0+14/0+20/0) + E2E 64/0 | ✅ APROVADO |
| **MD-3** | DT-1 release gate honesty — `CT_ValidarRelease_QuartetoMinimo` (V1+V2_Smoke+V2_Canonica+E2E_Strikes) | `ONDA11.MD3-DT1-quarteto-release-gate-incremental` | **VR_20260502_054314 = APROVADO; sintaxe `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0`** | ✅ APROVADO |
| **MD-3.1** | Visibilidade Quarteto no menu Central V2 (opcao [20]) | `ONDA11.MD3-1-DT1-quarteto-menu-incremental` | manifesto MICRO11 entregue; pendente import operador | ✅ ENTREGUE |
| **MD-4** | CSVs antigos da raiz movidos para `auditoria/04_evidencias/V12.0.0203/` | (sem bump — file-only) | 3 CSVs movidos | ✅ APROVADO |
| **MD-5** | rc1 bump (TAG/STATUS/EVIDENCE_DIR/TEST_KEY) + CHANGELOG + L16-L18+M7 em PHAGOCYTOSIS + ERP + 70_FECHAMENTO + DRIFT_G7_RESIDUAL | `f7aa84f+v12.0.0203-rc1` | manifesto MICRO12 entregue; pendente import operador | ✅ ENTREGUE |

### Pendente operador para fechamento físico

| Acao | Esforço | Files |
|---|---|---|
| Importar MICRO11 (MD-3.1 menu) + MICRO12 (rc1 bump) no workbook | ~5min | manifestos `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO{11,12}.txt` |
| Compile manual + Quarteto verde | ~12min | `CT_ValidarRelease_QuartetoMinimo` |
| Salvar como `V12-202-AB-onda11-rc1` | ~1min | workbook ancora rc1 |
| `git tag v12.0.0203-rc1` + `git push origin v12.0.0203-rc1` | ~1min | git |
| **MD-5** | V12.0.0203-rc1: bump APP_RELEASE_TAG/STATUS/EVIDENCE_DIR + CHANGELOG + L16-L18+M7 em PHAGOCYTOSIS + ERP `0011-exec-onda11.json` + `auditoria/03_ondas/onda_11_v203_rc1_closure/70_FECHAMENTO_ONDA_11.md` | ~60min | AAX-App_Release.bas + 5+ docs |
| Tag git | `git tag v12.0.0203-rc1` + push (operador) | ~5min | git |

### Licoes destiladas nesta sessao (a registrar em PHAGOCYTOSIS no MD-5)

- **L16** — Anti-vazamento de CONFIG entre suites (toda mudanca de estado em CONFIG por suite deve ser revertida em try/finally simulado)
- **L17** — Instrumentacao cirurgica antes de fixar (DIAG_* logs por etapa revelam causa raiz sem ciclos de hotfix encadeados)
- **L18** — Determinismo > narrativa pedagogica (testes devem refletir fatos do sistema, nao premissas idealizadas)
- **M7** — Auditor de espelho deve hashar src vs canonical antes de RCA (erro do Antigravity virou marker `🟠 SOURCE DRIFT DETECTED`)

## Transicao 2026-05-02 — Sessao original encerra; 2 chats paralelos abrem

| Frente | Bastao | Foco | Prompt de abertura |
|---|---|---|---|
| **1 — Credenciamento** | Claude Opus 4.7 (continuacao) | Fechar V12.0.0203-rc1 (MD-3+MD-4+MD-5+tag) + Ondas 12-19 + FECH conforme roadmap original | `local-ai/Time_AI/2026-05-02-V203-fechamento/200-PROMPT-CHAT-NOVO-CREDENCIAMENTO.md` |
| **2 — usehbn / Fagocitose** | Claude Opus 4.7 = arquiteto senior + validador; Codex = executor em esteiras incrementais; Mauricio = palavra final em decisoes complexas | Bootstrap HBN Phagocytosis Protocol v0.1 (modulo VBA primeiro alvo) + protocolo vivo | `local-ai/Time_AI/2026-05-02-V203-fechamento/201-PROMPT-CHAT-NOVO-USEHBN.md` |

Sincronizacao entre frentes: via arquivos no repo (`.hbn/`, `auditoria/`, `usehbn/`). Sem bloqueio mutuo.

# Relay HBN — Credenciamento

## Bastao atual

| Campo | Valor |
|---|---|
| Proprietario | Claude Opus 4.7 (Cowork) |
| Concedido por | Luis Mauricio Junqueira Zanin |
| Data de concessao | 2026-04-28 |
| Validade | ate fechamento estavel da V12.0.0203 no GitHub |
| Reverte para | Codex (apoio) + Claude Opus em modo auditoria |
| Modo de operacao atual | **CONSULTIVO CONTROLADO** (alterado 2026-04-28 apos violacao G6 — saiu do modo "execucao maxima") |
| Justificativa | retrabalho da Onda 5 nao estabilizada; concentracao em uma IA reduz risco de perda de contexto durante a estabilizacao |

## Onda 10 EM EXECUCAO — Reincorporacao Onda 1 (strikes)

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0010-onda10-reincorporacao-onda01.json](../readbacks/0010-onda10-reincorporacao-onda01.json) |
| Hearback | confirmed (5 pontos aprovados em chat 2026-05-01) |
| Microdelta atual | **N/A — Onda 10 FECHADA na canonica em 2026-05-02 com debito DT-3 documentado** |
| ERP | [results/0010-exec-onda10.json](../results/0010-exec-onda10.json) |
| Validacao final | `VR_20260501_233424` (V1=171/0, V2 Smoke=14/0, V2 Canonica=20/0) APROVADO |
| Build label final | `f7aa84f+ONDA10-canonica-fechada-com-debito-strikes` |
| Pasta canonica | `local-ai/vba_import/` (RESTAURADA — Regra de Ouro 0002 reafirmada) |
| Solucao de contorno | `local-ai/vba_import_v3_phase1/` arquivada em `auditoria/04_evidencias/V12.0.0203/_historico_v3_phase1_descontinuado_20260502/` |
| Politica de teste | **TV2_RunSmoke por microdelta + trio mínimo 1x ao final da onda** (oficializado 2026-05-01 18:44) |
| Princípio arquitetural | Testes via interface oficial (TV2_Run*), idempotentes, evoluindo junto com codigo de producao. **Sem smoke ad-hoc no Imediato.** |
| Estrategia de espelho | **A — minimalista** (espelho = baseline + delta da onda; src/vba intocado em Phase A.5; hotfixes residuais para Phase A.6) |
| Microdeltas planejados | 1.0 → 1.1 → 1.2 → 1.4 → 1.3 → 1.5 (ordem com 1.4 antes de 1.3 para preservar config canonica) |
| Build label apos 1.0 | `f7aa84f+ONDA10.MICRO00-V3-Delta-Capability-incremental` |
| Build label final apos 1.5 | `f7aa84f+ONDA10-aprovada` |
| Ancora pos-onda10 | V12-202-T-onda10 |
| Doc tecnico | [auditoria/03_ondas/onda_10_reincorporacao_onda01/](../../auditoria/03_ondas/onda_10_reincorporacao_onda01/) |
| Achado Phase A | Ondas 1-4 estao **PARCIALMENTE** no baseline (so infra/producao parcial; suites/diag/menus ausentes). Onda 5 CONFIRMADA. |
| Estrategia | Reincorporacao progressiva via microdeltas, cada um com gate compile + trio + bump build incremental. |

### Microdeltas concluidos da Onda 10

| ID | Tema | Validacao | Build label | Status |
|---|---|---|---|---|
| 1.0 | Extensao V3 capacidade delta + bump auto | VR_20260501_173310 (171/0+14/0+20/0) | `f7aa84f+ONDA10.MICRO00-V3-Delta-Capability-incremental` | ✅ APROVADO 2026-05-01 17:44 |
| 1.1 | Repo_Avaliacao.ContarStrikesPorEmpresa | VR_20260501_180949 (171/0+14/0+20/0) | `f7aa84f+ONDA10.MICRO01-Repo_Avaliacao-incremental` | ✅ APROVADO 2026-05-01 18:19 |
| 1.2 | Svc_Rodizio.Suspender params opcionais | TV2_20260501_184237 SMOKE 14/0 | `f7aa84f+ONDA10.MICRO02-Svc_Rodizio-incremental` | ✅ APROVADO 2026-05-01 18:44 |
| 1.4 | TV2_SetConfigCanonica grava MAX_STRIKES e DIAS_SUSPENSAO_STRIKE | TV2_20260501_185512 SMOKE 14/0 | `f7aa84f+ONDA10.MICRO04-Teste_V2_Engine-incremental` | ✅ APROVADO 2026-05-01 18:55 |
| 1.3 | Svc_Avaliacao bloco 7b strikes ATIVO em producao (regra integrada) | TV2_20260501_194706 SMOKE 14/0 | `f7aa84f+ONDA10.MICRO03-Svc_Avaliacao-fix1-incremental` | ✅ APROVADO 2026-05-01 19:47 |


## Modo de operacao

**Consultivo controlado** (vigente desde hotfix v2 da Onda 6):

- Leitura ampla permitida (Read, Glob, Grep em todo o repo).
- Escrita pequena: cada arquivo modificado e escrita atomica, com
  hearback explicito para mudancas em arquivos canonicos
  (`.hbn/knowledge/`, `auditoria/01_regras_e_governanca/`,
  `usehbn/agents/`, `CLAUDE.md`).
- **Verificacao G6 obrigatoria** antes de enviar resposta ao Mauricio:
  scan da resposta por padroes VBA (`Private Sub`, `Public Sub`,
  `Public Function`, `Dim ... As`, `Range(...)`, `Sheets(...)`,
  `Cells(...)`, `Application.X`). Se houver match, pausar, mover para
  arquivo, atualizar procedimento, reenviar.
- Comandos shell para o operador continuam permitidos (sao operacionais,
  nao deliverable).
- Modo "execucao maxima" anterior (Onda 6 fase 1-2) provou produzir
  violacao — descontinuado.

## Ciclo encerrado mais recente

**ONDA 9 V3 — Phase 1 APROVADA** (2026-05-01 12:25)

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0009-onda09-v3-phase1.json](../readbacks/0009-onda09-v3-phase1.json) |
| Hearback | confirmed (3 OKs explicitos + 7 ciclos iterativos validados) |
| ERP | [results/0009-exec-onda09-v3-phase1.json](../results/0009-exec-onda09-v3-phase1.json) |
| Trio minimo | VR_20260501_121550 — V1=171/0 + V2 Smoke=14/0 + V2 Canonica=20/0 — APROVADO |
| Compile manual | passou limpo apos remocao do Importador_V2 legado |
| Engine | `src/vba/Importador_V3.bas` (1095 linhas) |
| Pacote isolado | `local-ai/vba_import_v3_phase1/` (LEIA-ME + manifesto + 35M + 13F) |
| Bootstrap | `local-ai/vba_import_v3_phase1/Importador_V3_Bootstrap.bas` |
| Doc tecnico | [auditoria/03_ondas/onda_09_importador_v3/50_TECNICO.md](../../auditoria/03_ondas/onda_09_importador_v3/50_TECNICO.md) |
| Procedimento | [auditoria/03_ondas/onda_09_importador_v3/51_PROCEDIMENTO.md](../../auditoria/03_ondas/onda_09_importador_v3/51_PROCEDIMENTO.md) |
| Licoes aprendidas | [knowledge/0009-licoes-importador-v3-phase1.md](../knowledge/0009-licoes-importador-v3-phase1.md) (L1-L9 + M1-M5) |
| Ancora | `V12-202-S/` — primeira versao com V3 como importador oficial + compile limpo + trio verde |
| Fixes acumulados | 7 (todos baseados em evidencia empirica do log, nenhum chute) |

## Proximas fases

| Fase | Tema | Status |
|---|---|---|
| 1 | V3 alpha — importar baseline | ✅ APROVADA (2026-05-01) |
| 2 | V3 beta — modo Fresh em .xlsx em branco | OPCIONAL — robustece V3 mas nao bloqueia V203 |
| 3 | V3 gamma — renomeacao L2 | DESCARTADA por decisao operador (L1 escolhido) |
| 4 | Auditoria de debitos tecnicos + re-aplicar Ondas 7/8 se delta | EM PLANEJAMENTO |
| F | FECHAMENTO — atualizar build label + tag v12.0.0203 + push GitHub | DEPOIS DE 4 |

## Onda 5 — HOMOLOGADA

| Campo | Valor |
|---|---|
| Status | HOMOLOGADA em 2026-04-28 |
| Validacao | `VR_20260428_231958` em `auditoria/04_evidencias/V12.0.0203/` |
| Build | `f7aa84f+ONDA05-em-homologacao` |
| Trio minimo | V1=171/0, V2 Smoke=14/0, V2 Canonica=20/0 — **APROVADO** |
| Backup ancora | `V12-202-Q/` no diretorio raiz do projeto |

## Ciclo encerrado mais recente

| Campo | Valor |
|---|---|
| Ciclo | ONDA 6 — consolidacao documental + cleanup |
| Track HBN | safe_track |
| Status | ENCERRADO em 2026-04-28 |
| Readback | [readbacks/0001-onda06.json](../readbacks/0001-onda06.json) |
| Hearback | confirmed |
| ERP | [results/0001-exec-onda06.json](../results/0001-exec-onda06.json) |
| Resumo humano | [reports/0001-onda06-summary.md](../reports/0001-onda06-summary.md) |
| Doc tecnico | [auditoria/03_ondas/onda_06_consolidacao_documental/41_TECNICO.md](../../auditoria/03_ondas/onda_06_consolidacao_documental/41_TECNICO.md) |
| Commits | `85d7459` (conteudo) + `7e64622` (estrutural) |
| Ciclo origem | [relay/0001-onda06-consolidacao-documental.md](0001-onda06-consolidacao-documental.md) (sera arquivado em proxima abertura de ciclo) |

## Ondas previstas (a partir desta)

| Onda | Tema | Status |
|---|---|---|
| 6 | consolidacao documental + cleanup + integracao Diataxis/llms.txt/AGENTS.md/HBN | EM EXECUCAO |
| 5 (resgate) | homologacao final do form deterministico + Limpa_Base robusta (ja entregue, em homologacao manual) | EM HOMOLOGACAO |
| 7 | familia IDM_* + RDZ_* (idempotencia + rodizio em loop) | PROXIMA APOS ONDA 6 |
| 8 | heuristica zero em todos os 13 forms | DEPOIS DA 7 |
| 9 | reescrita do Importador_VBA + auditoria de Mod_Types (com aprovacao explicita) | DEPOIS DA 8 |
| FECHAMENTO | tag v12.0.0203, push GitHub, release publica | DEPOIS DA 9 |

## Proxima acao explicita

**Aprovacao do roadmap V203 final** (ver tabela "Proximas fases" acima).

Recomendacao Claude:
1. **Auditoria de debitos tecnicos** (~30 min Claude) — diff src/vba vs V12-202-S, lista de divergencias se houver
2. **Atualizar carimbo de build** em `App_Release.bas` para `f7aa84f+ONDA09-V3-PHASE1-aprovada` (1 commit)
3. **Phase 2 (opcional)** — robustecer V3 com run em `.xlsx` Fresh
4. **Phase 4 sequencial** — re-rodar trio + V2 Canonica completo + auditar Ondas 7/8 se delta
5. **FECHAMENTO** — tag v12.0.0203 + push GitHub

Aguardando hearback do Mauricio sobre ordem.

## Standard HBN markers

Esta sessao usa os marcadores visiveis do adapter HBN:

- `✅ HBN ACTIVE` — protocolo engajado
- `❌ HBN SECURITY BLOCKED SUGGESTION` — gate de seguranca
- `🟡 HBN NEEDS HUMAN DECISION` — aprovacao requerida

---

# Frente 2 — usehbn / Sprint 0 (aberta 2026-05-02)

> Seção append-only adicionada pela Frente 2 conforme protocolo
> `usehbn/methodology/INTER-CHAT-COORDINATION.md`. Não substitui nem
> edita conteúdo da Frente 1 acima.

## Bastão Frente 2

| Campo | Valor |
|---|---|
| Proprietário arquiteto | Claude Opus 4.7 (Cowork — sessão Frente 2 aberta 2026-05-02) |
| Proprietário executor | Codex CLI (delegação por esteiras) |
| Autoridade final | Luís Maurício Junqueira Zanin |
| Modo de operação | ⚪ HBN AUDIT-ONLY para Opus (orquestra, valida; não codifica). Codex em modo executor para esteiras aprovadas. |
| Foco | Bootstrap `hbn-phago` (HBN Phagocytosis Protocol v0.1) — esteira E1 = Radar Bootstrap |
| Repo destino | `~/Projetos/usehbn-phago/` (alternativa b — local separado, AGPLv3 limpo, futura promoção a repo público) |

## Histórico de esteiras Frente 2

### Esteira E1 — Radar Bootstrap (FECHADA — aprovada com débito)

| Campo | Valor |
|---|---|
| ID | E1 — Radar Bootstrap |
| Status | ✅ APROVADA com débito DT-FRENTE2-01 (templates genéricos nas 53 fichas — endereçado em E1.1) |
| Spec | `local-ai/Time_AI/2026-05-02-V203-fechamento/300-SPRINT-0-HBN-PHAGO-CODEX.md` |
| ERP | [`local-ai/Time_AI/codex-erps/2026-05-02_E1-radar-bootstrap.json`](../../local-ai/Time_AI/codex-erps/2026-05-02_E1-radar-bootstrap.json) |
| Resultado | 55 fichas + REGISTRY + MATRIX + repo `~/Projetos/usehbn-phago/` (LICENSE AGPLv3) |
| Validação Opus | V1-V12 verdes (estrutura); A1 amarelo (justificativas template — endereçado em E1.1) |
| Hearback Maurício | "sim para todas as quatro" — 2026-05-02 |

### Esteira E1.1 — Radar Content Deepening (FECHADA — aprovada com débito DT-FRENTE2-02)

| Campo | Valor |
|---|---|
| ID | E1.1 — Radar Content Deepening |
| Status | ✅ APROVADA com débito DT-FRENTE2-02 (justificativas template por categoria — não-bloqueante) |
| Spec | `local-ai/Time_AI/2026-05-02-V203-fechamento/302-ESTEIRA-E1-1-RADAR-CONTENT-DEEPENING.md` |
| ERP | [`2026-05-02_E1-1-radar-deepening.json`](../../local-ai/Time_AI/codex-erps/2026-05-02_E1-1-radar-deepening.json) |
| Resultado | 43 fichas reescritas (templates por categoria) + 10 arquivadas + REGISTRY/MATRIX regenerados + relatório `auditoria/00_status/40` |
| Validação Opus | V1-V3, V7-V15 verdes; V4/V5/V6 amarelos (templates persistentes — não-bloqueante) |
| Hearback Maurício | aprovado 2026-05-02 + decisão estratégica: análise profunda migra para Opus sob demanda |
| Mensagem fechamento | [`.hbn/messages/2026-05-02_06_de-opus_para-codex.md`](../messages/2026-05-02_06_de-opus_para-codex.md) |

### Análise profunda Opus (5 fichas — sob demanda, FECHADA)

| Campo | Valor |
|---|---|
| ID | A5 — Análise Profunda 5 Fichas (Opus) |
| Status | ✅ ENTREGUE |
| Fichas | tree-sitter, typer, uv, opentelemetry, consent-capsules |
| Resultado | 5 reescritas in-place com análise individual real, referências reais, recomendações de promoção |
| Recomendações | tree-sitter → `convergence-mapped` (9/10); opentelemetry → `convergence-mapped` (8/10); consent-capsules → `candidate` (10/10) |
| Confirmações | typer + uv → `candidate` em 2026-05-04 conforme programado (10/10 e 8/10 respectivamente) |

### Permeabilidade do radar formalizada (FECHADA)

| Campo | Valor |
|---|---|
| Doc | [`usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`](../../usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md) — seção "Permeabilidade" |
| Cobertura | 5 vias de entrada, regras de baixo atrito, anti-ruído, reentrada de archived, filtro de impacto |
| Origem | pedido Maurício 2026-05-02 (lógica de permeabilidade para novas tecnologias) |

### Sessão 2026-05-06 — análise das 5 tecnologias + reorientação arquitetural radical

| Campo | Valor |
|---|---|
| ID | A5-EVOLUÇÃO — análise das 5 tecnologias do radar (4 de 5 concluídas) |
| Decisões fechadas | **TODAS AS 5**: Tree-sitter APROVADA; Typer ARQUIVADA; uv ARQUIVADA; Consent Capsules APROVADA (migração imediata); **OpenTelemetry APROVADA (fagocitose progressiva)** |
| **Correção fundamental** | **useHBN é MULTI-BRAÇO; fagocitose é apenas UM dos 6 módulos. Doc canônico: `USEHBN-MODULES-ARCHITECTURE.md`** |
| **Documento de aprovação consolidado** | **`auditoria/00_status/44_CORRECAO_USEHBN_E_CONSOLIDACAO.md` — 7 blocos de decisão pendentes para Maurício** |
| **Auditoria Cruzada IAs (Módulo 6)** | **declarada em `CROSS-IA-AUDIT-PROTOCOL.md`** |
| **Proposta site** | **`usehbn/site/PROPOSTA-MELHORIA-USEHBN-ORG.md`** |
| Decisão arquitetural maior | **Rust como linguagem-base do useHBN** (Árvore Estável); **Consent Capsules como primeira migração estruturada Python → Rust** |
| Princípios operacionais formalizados | Minimalismo de Cadeia (P11 candidato); Substrato Sólido (P12 candidato); AI-Language-Abstraction (P13 candidato) |
| Modelo arquitetural novo | **3 Árvores — Estável (Rust), Desenvolvimento (transição), Exploração (qualquer linguagem)** |
| Markers V2 novos propostos (7) | 🟦 MINIMALIST, 🟪 SUBSTRATO, 🟧 AI-ABSTRACTION, 🌱 EXPLORATION SEED, 🔧 DEV BRANCH, 🪨 STABLE TRUNK, 🟫 TREE TRANSITION |
| Documentos canônicos novos (8) | `MINIMALISM-PRINCIPLE.md`, `SUBSTRATO-SOLIDO-PRINCIPLE.md`, `AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md`, `THREE-TREES-ARCHITECTURE.md`, `LANGUAGE-PLATFORM-COMPARISON.md`, `42_ROADMAP_CONSENT_CAPSULES_RUST.md`, `43_PLANO_DOCUMENTACAO_V2_USEHBN.md` + ficha `rust.md` |
| Status | ⏳ apenas análise OpenTelemetry pendente antes do prompt unificado ao Codex e início efetivo R-A |
| Sucessor | `auditoria/00_status/42_PROMPT_UNIFICADO_CODEX.md` (renomear para evitar conflito com 42 atual) ou novo número — a ser criado após decisão #5 |
| V2 useHBN | em planejamento; F1 esboço pronto em `43_PLANO_DOCUMENTACAO_V2_USEHBN.md`; F2 inicia após análise OTel |

## Sistema de revisão semanal (ativado nesta sessão)

| Componente | Path |
|---|---|
| Log append-only | [`usehbn/radar/WEEKLY-UPDATES.md`](../../usehbn/radar/WEEKLY-UPDATES.md) |
| Protocolo | [`usehbn/methodology/RADAR-WEEKLY-REVIEW-PROTOCOL.md`](../../usehbn/methodology/RADAR-WEEKLY-REVIEW-PROTOCOL.md) |
| Frequência | Toda quarta-feira 11:45 BRT |
| Próxima revisão | 2026-05-06 (quarta) |
| Modo | Manual (Opus + Maurício) até Wave 11+; depois `hbn weekly-review` automatizado |

## Decisões registradas no hearback 2026-05-02

| # | Decisão | Status |
|---|---|---|
| 1 | Arquivar 10 tecnologias | Codex executa em E1.1 |
| 2 | Promover MCP → `convergence-mapped` | ✅ Opus executou (ficha atualizada) |
| 3 | Acionar Codex para E1.1 | ✅ Mensagem 04 depositada |
| 4 | Stack CLI (Typer, uv, GH Actions, Signed commits) → `candidate` em 2026-05-04 | Agendado |

## Documentos canônicos da Frente 2 (criados nesta sessão)

| Path | Função |
|---|---|
| [`usehbn/methodology/INTER-CHAT-COORDINATION.md`](../../usehbn/methodology/INTER-CHAT-COORDINATION.md) | Protocolo de coexistência F1 ↔ F2 (particionamento de paths, mensageria, soft-locks) |
| [`usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`](../../usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md) | Camada 0 — Radar formalizada (estados, transições, schema de ficha) |
| `local-ai/Time_AI/2026-05-02-V203-fechamento/300-SPRINT-0-HBN-PHAGO-CODEX.md` | Spec executável da esteira E1 (Codex) |
| `local-ai/Time_AI/2026-05-02-V203-fechamento/301-PROTOCOLO-PINGPONG-OPUS-CODEX.md` | Protocolo Opus ↔ Codex (handoff, ERP, validação, iteração) |
| [`.hbn/messages/2026-05-02_01_de-frente2_para-frente1.md`](../messages/2026-05-02_01_de-frente2_para-frente1.md) | Mensagem informativa de abertura para a Frente 1 |

## Particionamento de paths vigente

Detalhes em `usehbn/methodology/INTER-CHAT-COORDINATION.md`. Resumo:

- **Frente 2 escreve em**: `usehbn/methodology/`, `usehbn/radar/`, `usehbn/constitution/` (Sprint 1+), `local-ai/Time_AI/2026-05-02-V203-fechamento/3*.md`, `auditoria/00_status/` (numeração 38-42), `.hbn/messages/`, `.hbn/locks/`, `.hbn/knowledge/0010+.md`, repo externo `~/Projetos/usehbn-phago/`
- **Frente 2 NÃO toca**: tudo o que pertence à Frente 1 (`src/vba/`, `local-ai/vba_import/`, `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`, `auditoria/03_ondas/`, `App_Release.bas`, `CHANGELOG.md`, `.hbn/readbacks/0011-*`, `.hbn/results/0011-*`, `auditoria/00_status/` numeração 33-37)
- **Append-only compartilhado**: este `.hbn/relay/INDEX.md` (Frente 2 só adiciona seção própria no fim)

## Markers V2 ativos no abrir da Frente 2

- `✅ HBN ACTIVE` — Frente 2 engajada
- `⚪ HBN AUDIT-ONLY` — Opus orquestra; Codex tem bastão executor
- `🔵 HBN HANDOFF READY` — pacote pronto para release ao Codex (aguardando hearback final)
- `🟤 HBN LICENSE SPLIT REQUIRED` — artefatos cruzam TPGL (Credenciamento) e AGPLv3 (usehbn-phago)
