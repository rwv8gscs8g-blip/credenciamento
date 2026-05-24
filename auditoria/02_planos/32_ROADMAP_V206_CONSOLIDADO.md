---
titulo: Roadmap Consolidado V12.0.0206
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Roadmap Consolidado V12.0.0206

## Objetivo

Executar uma release incremental pós-produção que preserva integralmente a
V12.0.0205 e prepara a V12.0.0207. A V12.0.0206 deve focar em evidências,
mensagens operacionais, PDF automático isolado e jornada humana.

## Contrato de Não Regressão

Assinatura RVS herdada da V12.0.0205:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

O RVS não pode receber contadores novos na V12.0.0206. Testes de PDF devem ser
isolados e complementares.

## Decisão de Consolidação

Codex adota a recomendação mais conservadora:

- higiene documental e evidências antes do PDF;
- PDF isolado, sem contaminar RVS;
- Importador V3 antes do PDF para remover orientação legada;
- débitos técnicos apenas com lista nominal;
- V12.0.0207 preservada para refatoração, performance e componentização.

## Ordem Final de Ondas

| Onda | Tema | Escopo | Gate de saída |
|---|---|---|---|
| 30 | Planejamento V206 | Registrar 88/89, consolidar roadmap 90 e prompt 91 | hearback humano |
| 31 | Higiene documental e evidências | `MANIFEST.md`, `MANIFESTO.csv`, link scan, frontmatter, decisão sobre ondas físicas 26-29 | `verify_release_consistency.sh` + `git diff --check` |
| 32 | Auditoria cruzada PDF/UI | Preparar prompts Opus/Gemini/Codex para PDF automático, relatórios e testes por simulação de cliques | prompts 92/93/94 + hearback |
| 33 | Correção dos relatórios pendentes | Corrigir `Rel_Emp_Serv` e `Rel_OSEmpresa` na interface, sem reabrir lógica de negócio | compile VBE + Smoke + teste específico |
| 34 | Motor PDF central | Implementar pastas, nomeação, fallback, validação de arquivo e log de PDFs | compile VBE + Smoke + teste PDF isolado |
| 35 | Integração PDF operacional | Integrar PDF em Pré-OS, OS, Avaliação e Relatórios, preservando fallback humano | teste específico + RVS completo se tocar fluxo crítico |
| 36 | Bateria UI/PDF isolada | Simular cliques/fluxos de interface e gerar PDFs em `Documentos_Gerados/Testes_UI/<RUN_ID>/` | suíte isolada fora do RVS + evidências |
| 37 | Jornada humana e RC/freeze | Atualizar jornada humana V206, evidências, App_Release, release note e auditoria final | RVS completo + AF1/AF2/AF3 V206 |

## Blindagens Obrigatórias

- Não editar RN-01 a RN-17.
- Não mover `doc/`.
- Não alterar `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas` ou
  `Svc_PreOS.bas` salvo P0 explícito e hearback humano.
- Não renomear símbolos internos de VBA.
- Não incorporar PDF aos contadores RVS.
- Não abrir débitos técnicos nominais sem lista aprovada; após a decisão
  humana de PDF/UI, a Onda 36 passa a ser a bateria isolada UI/PDF.

## Entregáveis Preliminares Para Onda 31

- Decisão sobre papel de `MANIFESTO.csv`.
- Link scan dos documentos canônicos.
- Atualização de frontmatter com datas de última alteração quando relevante.
- Decisão sobre espelho físico de ondas 26-29 em `auditoria/03_ondas/`.

## Decisões Registradas Pela Onda 31

- `MANIFESTO.csv` permanece como espelho tabular do `MANIFEST.md`, voltado a
  automações, planilhas e conferência de hashes.
- Novos artefatos de evidência devem atualizar `MANIFEST.md` e `MANIFESTO.csv`
  no mesmo delta.
- As Ondas 26-29 e a Onda 30 não serão retrocriadas em `auditoria/03_ondas/`;
  a rastreabilidade dessas ondas permanece em ERPs HBN, `auditoria/00_status/`,
  roadmaps e evidências.
- A partir da Onda 31, ondas executivas V206 com entrega técnica própria voltam
  a ter pasta física em `auditoria/03_ondas/`.

## Decisões Registradas Pela Onda 32

- Estrutura de PDFs aprovada: `Documentos_Gerados/Pre-OS/`,
  `Documentos_Gerados/OS/`, `Documentos_Gerados/Avaliacoes/`,
  `Documentos_Gerados/Relatorios/`, `Documentos_Gerados/Validacao/` e
  `Documentos_Gerados/Testes_UI/<RUN_ID>/`.
- Nomeação aprovada: `<TIPO>_<NUMERO_DOCUMENTO>_CNPJ_<CNPJ_LIMPO>_<AAAAMMDD_HHNNSS>.pdf`.
- A auditoria cruzada rápida deve orientar a arquitetura antes da implementação
  para reduzir retrabalho e preparar a bateria futura de simulação de cliques.
- O antigo item de mensagens do Importador V3 fica deferido como débito pequeno
  nominal, a reavaliar após o ciclo PDF/UI ou no RC, sem bloquear a cadência
  principal aprovada.

## Decisões Registradas Pela Consolidação PDF/UI

- A consolidação Codex da auditoria cruzada foi registrada em
  `auditoria/00_status/97_CONSOLIDACAO_PDF_UI_V206_CODEX.md`.
- A Onda 33 começa pela correção de instância fantasma em `Rel_OSEmpresa` e
  `Rel_Emp_Serv`, antes de qualquer motor PDF.
- A raiz operacional `Documentos_Gerados/` deve ser criada ao lado da planilha
  quando o workbook estiver salvo, gravável e fora do repositório git; caso
  contrário, usa fallback canônico em `Documents/Documentos_Gerados/`.
- O motor PDF deve nascer em `Util_PDF.bas`, com log append-only
  `Documentos_Gerados/_LOG/RPT_PDFs_EMITIDOS.csv`, validação de existência,
  tamanho e assinatura `%PDF`.
- Testes UI/PDF permanecem isolados em suites complementares e não alteram a
  assinatura RVS herdada da V12.0.0205.

## Decisões Registradas Pela Onda 33

- A correção de `Rel_OSEmpresa` e `Rel_Emp_Serv` foi limitada ao
  `Menu_Principal.frm`.
- Os handlers dos dois relatórios agora criam a instância exibida antes de
  chamar as rotinas `PreenchimentoRelatorioOSEmpresa` e
  `PreenchimentoRel_EmpXServ`.
- O preaquecimento de `Rel_OSEmpresa` no `UserForm_Initialize` foi removido
  para não criar instância invisível ao abrir o menu.
- A próxima frente continua sendo a Onda 34: motor PDF central, sem tocar os
  serviços blindados.

## Itens Movidos Para V12.0.0207

- Code review profundo.
- Performance estrutural do RVS.
- Componentização.
- Renomeação interna RVS/SRC/BRL.
- Racionalização de `doc/`/CNAE.
- Arquitetura SaaS.
- Migração estratégica do `usehbn/`, se aprovada.
