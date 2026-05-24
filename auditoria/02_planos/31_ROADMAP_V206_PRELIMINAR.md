---
titulo: Roadmap Preliminar V12.0.0206
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Roadmap Preliminar V12.0.0206

## Objetivo

Conduzir uma onda incremental pós-produção para lapidar a V12.0.0205 sem
alterar a semântica de negócio validada. A V12.0.0206 deve preservar a guarda
RVS da V205 e preparar uma base mais limpa para a V12.0.0207.

## Princípios

- Não alterar RN-01 a RN-17 sem decisão humana explícita.
- Não refatorar símbolos VBA internos apenas por estética.
- Toda mudança funcional exige teste correspondente.
- Todo ajuste de documentação deve apontar para caminhos reais.
- Cada microdelta precisa terminar com import, compile VBE e gate adequado.

## Guarda de Não Regressão

Assinatura base herdada da V12.0.0205:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

Qualquer mudança na assinatura precisa ser classificada como P0/P1 e aprovada
antes de seguir.

## Ondas Propostas

| Onda | Tema | Objetivo | Gate mínimo |
|---|---|---|---|
| Onda 30 | Planejamento e auditoria cruzada V206 | Validar escopo com Claude Opus, Gemini/Antigravity e Codex | documentos 83-87 aprovados |
| Onda 31 | PDF automático robusto | Automatizar exportação PDF da aba `VALIDACAO_RELEASE`, com tratamento de erro e fallback manual preservado | compile VBE + Smoke + teste PDF |
| Onda 32 | Jornada humana pós-produção | Incorporar ajustes de testes manuais, prints, checklist e ergonomia da validação por interface | jornada revisada + RVS |
| Onda 33 | Higiene documental e evidências | Organizar `MANIFESTO.csv`, índices, ondas 26-29 físicas se necessário, e paths canônicos | `verify_release_consistency.sh` + link scan |
| Onda 34 | Importador V3 e mensagens operacionais | Atualizar textos legados do Importador V3 que ainda mencionam Trio/Quarteto e reforçar orientação RVS | import dry-run + compile |
| Onda 35 | Pequenos débitos técnicos | Corrigir débitos pequenos surgidos nos testes manuais sem tocar arquitetura profunda | teste específico + RVS parcial |
| Onda 36 | RC e freeze V206 | Consolidar release note, App_Release, evidências e auditoria final | RVS completo + auditoria cruzada final |

## Funcionalidades e Melhorias Candidatas

### Alta Prioridade V206

- PDF automático robusto da validação de release.
- Revisão do fluxo de evidências `INDEX.md`/`MANIFEST.md`/`MANIFESTO.csv`.
- Atualização das mensagens do Importador V3 para Gate RVS.
- Checklist humano pós-produção com campo de evidência manual.
- Registro documental das ondas V205 26-29 em `auditoria/03_ondas/`, se a
  auditoria cruzada confirmar valor.

### Média Prioridade V206

- Melhorar indicação visual do status da release na janela Sobre.
- Adicionar conferência rápida do hash do CSV final na jornada humana.
- Criar roteiro de triagem P0/P1/P2/P3 para testes manuais externos.
- Revisar textos de `docs/how-to/` para reduzir dependência de VBE.
- Criar matriz curta "pendência -> versão alvo -> justificativa".

### Baixa Prioridade V206

- Padronização fina de acentuação e termos históricos.
- Redução de duplicidade entre dashboard, relay e status oficial.
- Pequenas melhorias de nomenclatura nos relatórios sem alterar símbolos VBA.

## Fora de Escopo V206

- Refatoração profunda de serviços/repositórios.
- Performance estrutural do gate completo.
- Componentização do VBA.
- Renomeação interna de `Sexteto` para `RVS`.
- Migração de dados `doc/` ou estratégia SaaS.

Esses itens ficam para V12.0.0207 ou roadmap posterior.

## Saídas Esperadas da Auditoria Cruzada

- Parecer Opus: pontos fortes, riscos e priorização estratégica.
- Parecer Gemini/Antigravity: riscos adversariais, inconsistências e caminhos.
- Consolidação Codex: backlog V206 com ondas, microdeltas, gates e critérios de
  saída.

