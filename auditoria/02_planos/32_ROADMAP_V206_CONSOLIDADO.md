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
| 32 | Importador V3 e mensagens | Remover orientação ativa a Trio/Quarteto/Sexteto legado e orientar Gate RVS | compile VBE + Smoke |
| 33 | Especificação e teste PDF isolado | Criar especificação final do teste PDF fora do RVS | documento aprovado + hearback |
| 34 | PDF automático robusto | Exportar `VALIDACAO_RELEASE` para PDF com handler, pasta, fallback e teste isolado | compile VBE + Smoke + teste PDF + RVS completo |
| 35 | Jornada humana V206 | Atualizar checklist humano, hash, triagem P0/P1/P2/P3 e fluxo PDF | dry-run humano |
| 36 | Débitos pequenos nominais | Apenas itens listados e aprovados; sem lógica de negócio | teste específico + RVS completo se tocar código |
| 37 | RC e freeze V206 | App_Release, release note, evidências V206, auditoria cruzada final e tag | RVS completo + AF1/AF2/AF3 V206 |

## Blindagens Obrigatórias

- Não editar RN-01 a RN-17.
- Não mover `doc/`.
- Não alterar `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas` ou
  `Svc_PreOS.bas` salvo P0 explícito e hearback humano.
- Não renomear símbolos internos de VBA.
- Não incorporar PDF aos contadores RVS.
- Não abrir Onda 36 sem lista nominal de débitos.

## Entregáveis Preliminares Para Onda 31

- Decisão sobre papel de `MANIFESTO.csv`.
- Link scan dos documentos canônicos.
- Atualização de frontmatter com datas de última alteração quando relevante.
- Decisão sobre espelho físico de ondas 26-29 em `auditoria/03_ondas/`.

## Itens Movidos Para V12.0.0207

- Code review profundo.
- Performance estrutural do RVS.
- Componentização.
- Renomeação interna RVS/SRC/BRL.
- Racionalização de `doc/`/CNAE.
- Arquitetura SaaS.
- Migração estratégica do `usehbn/`, se aprovada.

