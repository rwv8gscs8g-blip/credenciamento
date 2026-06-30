---
adr-id: ADR-019
titulo: Diagnóstico de segurança defensivo obrigatório antes de qualquer projeto avançar
status: PROPOSED
data-deposito: 2026-06-10
autor: claude-fable-5 (arquiteto useHBN, corrente segurança+onboarding)
temperatura: quente
cross-ia-required: Antigravity-Gemini + Codex (prompts 20260610-61/62)
hearback-status: pendente
aplica-a: TODOS os projetos sob o protocolo
relacionado: [ADR-014 (cerimônia proporcional), ADR-017 (freeze-gate), inbox 20260610-53..59]
evidencia-motivadora: |
  Corrente de 2026-06-10 achou, em 7 projetos: credencial real de banco
  versionada e servida estaticamente (timelessphoto.art
  public/timeless-site/suporte/wp-config.php:23-29,51, EM PRODUÇÃO);
  credenciais órfãs ativas em pasta sem código (govflow-saas-core);
  e-CPF .pfx real na árvore de trabalho (MAURICIOZANIN-HUB/.certs/).
  Nenhum desses projetos tinha passado por diagnóstico antes de ir ao ar.
---

# ADR-019 — Sem diagnóstico defensivo, projeto não avança

## Decisão

Todo projeto sob o protocolo passa por **diagnóstico de segurança
defensivo** (find-and-fix, nunca ofensivo) em dois gatilhos:

1. **No onboarding** — antes da primeira onda sob useHBN.
2. **Antes de avanço de estágio** — MVP→beta, beta→produção, ou qualquer
   deploy público novo (acopla ao freeze-gate do ADR-017).

## Escopo mínimo do diagnóstico (checklist OWASP-orientado)

a. Segredos: no repo (tracked), no HISTÓRICO git, e na árvore de trabalho
   (.env*, *.pfx, dumps). As três camadas — a corrente de hoje provou que
   cada uma falha de um jeito diferente.
b. Auth/authz: rotas sem checagem, fallbacks de secret, usuários mágicos.
c. Validação de entrada/injeção: raw SQL, dangerouslySetInnerHTML, uploads.
d. Exposição de dados: PII em planilha/seed/dump, diretórios public/.
e. Dependências: versões + advisories.
f. Config de deploy: headers, CSP, endpoints de debug/teste em produção.

## Regras de execução

- Achado cita `arquivo:linha + severidade + correção`; valor de segredo
  NUNCA é transcrito (só natureza).
- Profundidade proporcional (ADR-014): top-risco = profundo; resto =
  inicial COM declaração explícita do que não foi verificado. Inflar
  cobertura é violação do protocolo (Truth Barrier).
- Resultado vai para `.hbn/results/` do projeto (frio ao nascer) e a
  decisão para o REGISTRY.
- Alegação de agente/IA auxiliar só entra em relatório APÓS verificação por
  evidência direta (a corrente de hoje desmentiu 3 achados "críticos" de
  agentes que leram errado).

## Consequências

Custo: ~horas por projeto, na cadência dos gatilhos. Benefício: a classe
de incidente "credencial versionada descoberta depois do deploy" passa a
ser estruturalmente improvável. Sem hearback de Maurício este ADR não
governa nada.
