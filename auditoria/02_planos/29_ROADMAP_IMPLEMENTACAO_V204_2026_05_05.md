---
titulo: 29 - Roadmap de Implementacao V204
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-05
---

# 29. Roadmap de Implementacao V12.0.0204

## 1. Objetivo

Transformar a `V12.0.0203-rc4` em uma linha `V12.0.0204` apta a
producao, fechando os P0/P1 das auditorias 64/65 e ampliando a suite
para cobrir UI adversarial, transacoes, datas e dados legados.

## 2. Estado de entrada

| Campo | Valor |
|---|---|
| Base | `V12.0.0203-rc4` |
| Gate | `VR_20260504_171048` |
| Status | aprovado para teste manual |
| Producao | nao autorizada |
| Auditorias base | 64 Opus + 65 Antigravity |
| Sintese | `auditoria/00_status/66_SINTESE_AUDITORIA_CRUZADA_V203_RC4_E_ABERTURA_V204_2026_05_05.md` |

## 3. Ordem de ondas

| Onda | Tema | Tipo | Bloqueia V204 final |
|---|---|---|---|
| 20 | P0 UI: reativacao, reentrada e decisao `ATIV_ID` | codigo + testes | sim |
| 21 | P1 transacional: status, avaliacao, OS e strikes | codigo + testes | sim |
| 22 | Dados legados: backfill, orfaos e datas | codigo + migracao assistida | sim |
| 23 | Baterias adversariais e matriz combinatoria | testes + docs | sim |
| 24 | Seguranca preventiva e usabilidade operacional | codigo + docs | sim |
| 25 | Fechamento V204 e auditoria cruzada final | release | sim |
| 26 | Lapidacao documental, RAG/Obsidian e faxina recorrente | docs + metodologia | pos-release |

## 4. Roadmap detalhado

### Onda 20 - P0 UI e regras de reativacao

| MD | Entrega | Arquivos provaveis | Gate |
|---|---|---|---|
| MD-20.1 | Servico de reativacao de entidade com `AUDIT_LOG` | novo `Svc_Entidade.bas`, `Reativa_Entidade.frm`, testes | V2 Canonica + cenario entidade |
| MD-20.2 | Decisao `ATIV_ID`: preservar ou zerar com servico/auditoria | `Reativa_Empresa.frm`, possivel `Svc_Credenciamento` | cenario `CS_REATIV_UI_ATIV_ID_DECISAO` |
| MD-20.3 | Guard de reentrada em forms mutadores | `Reativa_Empresa.frm`, `Reativa_Entidade.frm`, `Altera_Empresa.frm`, `Limpar_Base.frm`, `Menu_Principal.frm` | `TV2_RunAdversarial_UI` parcial |
| MD-20.4 | Substituir comparacao numerica de IDs por `IdsIguais` | `Reativa_Empresa.frm`, `Altera_Entidade.frm`, possiveis forms correlatos | V1 + V2 Smoke |
| MD-20.5 | Cenarios de regressao UI reativacao | `Teste_V2_Roteiros.bas`, `Teste_V2_Engine.bas` | Quinteto verde |

### Onda 21 - Integridade transacional e erro explicito

| MD | Entrega | Arquivos provaveis | Gate |
|---|---|---|---|
| MD-21.1 | `GravarStatusEmpresa` retorna resultado estruturado | `Repo_Empresa.bas`, `Svc_Rodizio.bas`, testes | V1 + V2 Canonica |
| MD-21.2 | `AvaliarOS` propaga falha de `Suspender`/`AvancarFila` | `Svc_Avaliacao.bas`, testes | E2E Strikes |
| MD-21.3 | `ContarStrikes*` deixa de retornar zero em erro | `Repo_Avaliacao.bas`, `Svc_Avaliacao.bas`, possivel novo tipo | E2E Strikes + boundary |
| MD-21.4 | `EmitirOS` com rollback/ordem segura | `Svc_OS.bas`, `Repo_OS.bas`, testes | transacao interrupt |
| MD-21.5 | `Svc_Transacao` impede aninhamento silencioso | `Svc_Transacao.bas`, suites transacionais | V2 Canonica |

### Onda 22 - Dados legados, backfill e integridade

| MD | Entrega | Arquivos provaveis | Gate |
|---|---|---|---|
| MD-22.1 | Backfill auditavel de `DT_ULT_REATIV` por `AUDIT_LOG` — MICRO37 entregue para importacao | `Repo_Empresa.bas`, `Auto_Open.bas`, testes | `MIG_005`; Quinteto esperado com `V2_Smoke=30/0` |
| MD-22.2 | Fechar `INT-CAD-OS-REF-ORFA` com relatorio/migracao — MICRO38 aprovado | `Repo_OS.bas`, `Teste_V2_Roteiros.bas`, `Teste_V2_Engine.bas` | `MIG_006`; `VR_20260506_163217`; limpeza controlada 82 residuos; Quinteto verde |
| MD-22.3 | Tratamento de `DT_ULT_REATIV` invalida — MICRO39-fix1 aprovado | `Repo_Empresa.bas`, `Repo_Avaliacao.bas`, testes | `MIG_007`; `CS_INT_05`; `VR_20260506_232006`; Quinteto `V2_Smoke=32/0` e `IntegridadeBase=4/0` |
| MD-22.4 | Bordas temporais: igual, anterior, posterior, futura — MICRO40 aprovado | `Teste_V2_Roteiros.bas`, `Teste_V2_Engine.bas` | `CS_REATIV_BORDA_*`; `VR_20260507_010423`; Quinteto `E2E_Strikes=75/0` |

### Onda 23 - Baterias adversariais e cobertura combinatoria

| MD | Entrega | Arquivos provaveis | Gate |
|---|---|---|---|
| MD-23.1 | `TV2_RunAdversarial_UI` — MICRO41 aprovado | `Teste_V2_Engine.bas`, `Teste_V2_Roteiros.bas`, `Central_Testes_V2.bas` | `TV2_20260507_022218`: `ADVERSARIAL_UI=10/0/0`; `VR_20260507_022355`: Quinteto verde |
| MD-23.2 | `TV2_RunTransaction_Interrupt` — MICRO42 aprovado | `Teste_V2_Engine.bas`, `Teste_V2_Roteiros.bas`, `Central_Testes_V2.bas` | `TV2_20260507_042944`: `TRANSACAO_INTERRUPT=6/0/0`; `VR_20260507_043052`: Quinteto verde |
| MD-23.3 | `TV2_RunBoundary_Dates` — MICRO43 aprovado | `Teste_V2_Engine.bas`, `Teste_V2_Roteiros.bas`, `Central_Testes_V2.bas` | `BOUNDARY_DATES=9/0/0` em `TV2_20260509_020108`; Quinteto `VR_20260507_083959` |
| MD-23.4 | Matriz `regra -> cenario -> assert -> evidencia` — MICRO44 entregue | `docs/reference/testes/06_MATRIZ_RASTREABILIDADE_TESTES_V204.md` | doc review |
| MD-23.5 | Novo gate `Sexteto` — MICRO45 aprovado | `Teste_Validacao_Release.bas`, `Central_Testes_V2.bas`, testes V2 | `TV2_20260509_025210`: `ADVERSARIAL_UI=11/0/0`; `VR_20260509_025323`: Sexteto `Onda23Adv=26/0` |

### Onda 24 - Seguranca preventiva e usabilidade

| MD | Entrega | Arquivos provaveis | Gate |
|---|---|---|---|
| MD-24.1 | Remover/mitigar senha hardcoded de `Limpar_Base` — MICRO46 aprovado | `Limpar_Base.frm`, `Mod_Limpeza_Base.bas`, docs | `ADVERSARIAL_UI=12/0/0`; Sexteto `VR_20260509_141235` |
| MD-24.2 | Config invalidada gera mensagem e evento — MICRO47 aprovado | `Configuracao_Inicial.frm`, `Audit_Log.bas` | Smoke `TV2_20260509_150814`; Sexteto `VR_20260509_163840` |
| MD-24.3 | Evento dual-counter em avaliacao — MICRO48 aprovado | `Svc_Avaliacao.bas` | E2E `TV2_20260509_172616`; Sexteto `VR_20260509_173629`; `E2E_Strikes=76/0` |
| MD-24.4 | `SelecionarEmpresa` documenta side-effects — MICRO49/fix1/fix2 reprovados e rollback ratificado | `Svc_Rodizio.bas`, docs | deferido para V205; nao bloqueia V204 rc1 |

### Onda 25 - Fechamento V204

| MD | Entrega | Arquivos provaveis | Gate |
|---|---|---|---|
| MD-25.1 | Bump V204 release candidate — MICRO50 aprovado | `App_Release.bas`, `CHANGELOG.md`, docs | Sexteto `VR_20260510_000428` |
| MD-25.2 | Higiene documental final — MICRO51 | relay/results/roadmap/status/changelog | documental; sem novo gate Excel |
| MD-25.3 | Auditoria cruzada final Opus + Antigravity — MICRO52 aprovado | prompts + docs | sem P0/P1; P2 documentais para MICRO54 |
| MD-25.4 | Correcoes finais, se houver — MICRO53 | conforme achados | nao aberto: nenhum P0/P1 |
| MD-25.5 | Tag/push GitHub, release notes e devolucao de bastao — MICRO54 ampliado | docs + git | resolver P2 pre-tag e pedir aprovacao operador |

## 5. Gates obrigatorios por onda

1. `src/vba` continua fonte de verdade.
2. `local-ai/vba_import` sincronizado por M11.
3. CRLF preservado.
4. Compile manual limpo pelo operador.
5. Quinteto verde ate a Onda 22.
6. Sexteto verde a partir da Onda 23.
7. Auditoria cruzada sem P0/P1 antes da Onda 25 final.
8. Higiene documental recorrente antes de passar de fase:
   relay atualizado, ERP/readback coerentes, CHANGELOG com validacao,
   evidencias referenciadas, roadmap sem status defasado e proxima acao
   clara para humano e IA.

## 6. Onda 26 - lapidacao documental e estrategia RAG

A Onda 26 nao bloqueia a promocao tecnica da V204 quando a Onda 25 for
aprovada, mas deve iniciar logo depois da release para transformar a
documentacao em vitrine recorrente de auditabilidade.

| MD | Entrega | Criterio |
|---|---|---|
| MD-26.1 | Checklist canonico de higiene documental por fase | Toda IA sabe o que validar antes de passar bastao ou onda |
| MD-26.2 | Estrategia Obsidian/RAG para mapas, evidencias e status | Pontos de entrada claros para humanos e IAs |
| MD-26.3 | Faxina de duplicidades, docs obsoletos e indices | `llms.txt`, `docs/INDEX.md`, `.hbn/knowledge` e `obsidian-vault` coerentes |
| MD-26.4 | Protocolo recorrente de revisao documental por IA | Checklist reutilizavel a cada microdelta/onda/release |
| MD-26.5 | Auditoria documental cruzada | Outra IA valida navegabilidade, clareza e rastreabilidade |

## 7. Aprovacao solicitada

Para iniciar desenvolvimento, aprovar:

1. Onda 20 como primeira onda V204.
2. Decisao recomendada: reativacao de empresa **preserva**
   `COL_CRED_ATIV_ID`; qualquer recredenciamento deve ser acao explicita.
3. Guard de UI com helper central + flag local por form.
4. `V12.0.0204` como primeira linha candidata a producao.
