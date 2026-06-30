---
adr-id: ADR-005
titulo: Licenciamento — migração AGPLv3 → Apache 2.0 + CLA leve
status: ACCEPTED
data-deposito: 2026-05-09
data-ratificacao: 2026-05-10
autor: Claude Opus 4.7 (chat arquiteto-mestre useHBN)
cross-ia-required: Opus + Antigravity + Codex
hearback-status: ratificado por Mauricio 2026-05-10 (boletim em bloco; direção Apache 2.0 + DCO já decidida 2026-05-09)
prioridade: P1
ordem-cross-ia: após ADRs P0 ratificados
relacionado:
  - 00_BOOTSTRAP_PROTOCOLO_2026_05_09.md §4.5 (proposta inicial Apache 2.0)
  - doc 66 v2.0 (Credenciamento) §11.4
  - LICENSE atual (AGPLv3)
  - docs/LICENSING.md (a atualizar pós-ratificação)
  - usehbn-phago/ repo (atualmente AGPLv3 — também impactado)
---

# ADR-005 — Licenciamento: migração AGPLv3 → Apache 2.0 + CLA leve

## Status

**PROPOSED** — decisão direcional ratificada pelo operador 2026-05-09
("Apache 2.0 + CLA"). Este ADR detalha o caminho de transição, o tipo
de CLA escolhido e os impactos.

## Contexto

`~/Projetos/usehbn/` declara hoje **AGPLv3** (decisão da Frente 2 / E1
em 2026-05-02 quando o protocolo era pensado em integração com
`usehbn-phago/`). Análise comparativa em 2026-05-09 (doc 66 v2.0 §11.4
+ resposta didática Opus em chat) concluiu que Apache 2.0 + CLA serve
melhor à missão "useHBN é protocolo universal de coordenação inter-IA":

- **Adoção corporativa**: Apache 2.0 é padrão de protocolos universais (MCP, LSP, OpenTelemetry, Kubernetes API, Diataxis); AGPLv3 bloqueia.
- **Patent grant**: Apache 2.0 tem cláusula explícita anti-troll, em força equivalente a AGPLv3 nesse eixo.
- **Fagocitose recíproca**: Apache 2.0 absorve e é absorvido por Apache/MIT sem fricção; AGPLv3 só absorve unidirecionalmente.
- **Compatibilidade com Credenciamento (TPGL v1.1, conversão futura para Apache)**: limpa.
- **CLA leve**: preserva opção de re-licenciar futuramente sem rastrear todos os contribuidores; fricção mínima quando há 1 mantenedor + raros contribuidores externos.

A objeção válida pró-AGPL ("e se alguém modifica e nunca devolve?") é
mitigada por governança humana (mantenedor único = Mauricio) +
velocidade de evolução do upstream (apps consumidoras precisam acompanhar
SemVer per ADR-004, então drift fica visível via 🪞 HBN MIRROR DRIFT).

## Decisão

### 1. Licença: Apache License 2.0

- Texto canônico: https://www.apache.org/licenses/LICENSE-2.0.txt
- `LICENSE` raiz atualizado para Apache 2.0 completo (não summary).
- Header recomendado em arquivos de código novo:
  ```
  Copyright 2026 Luis Mauricio Junqueira Zanin
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
      http://www.apache.org/licenses/LICENSE-2.0
  ```

### 1.1 Checklist completo de transição (35 arquivos — ajuste MD-J cross-IA Codex)

Cross-IA Codex contou ~35 referências a `AGPL` no repo (não só `LICENSE`):
`LICENSE:1`, `setup.cfg:8`, `README.md:466`, `CONTRIBUTING.md:60`,
`docs/LICENSING.md`, headers em múltiplos `src/usehbn/*.py`, e outros.

**Regra "tudo ou nada"**: a transição AGPLv3 → Apache 2.0 NÃO pode ser
parcial. Deixar `LICENSE` Apache + headers AGPL = ambiguidade legal.
O MD-G de execução produz a lista completa via
`rg -l 'AGPL|Affero' .` e atualiza **todos** os arquivos no mesmo
commit (ou série de commits atômica revertível em bloco). `hbn doctor`
ganha check `license_consistency` que falha se encontrar mistura.

### 2. CLA: variante leve (DCO-style, não ICLA tradicional)

Duas opções avaliadas:

| Opção | Descrição | Custo de adoção | Recomendação |
|---|---|---|---|
| **DCO (Developer Certificate of Origin)** | Contributor adiciona `Signed-off-by: Nome <email>` no commit message. Sem assinatura digital, sem formulário externo. Modelo do Linux kernel + CNCF projects. | Baixíssimo. Configurar GitHub Action `DCO check` em PRs. | ✅ **Recomendada** — alinha com "CLA leve" |
| **ICLA tradicional** | Contributor assina formulário PDF/DocuSign uma vez. Modelo Apache Software Foundation. | Médio. Friccional para contribuidor casual. | Reservar para quando projeto crescer |

**Decisão**: adotar **DCO** como mecanismo de "CLA leve" deste ADR.

**Faseamento do enforcement (ajuste MD-J cross-IA Codex):**
- **Fase 1** (junto com a troca de licença): apenas texto em
  `CONTRIBUTING.md` explicando o DCO + exemplos de `git commit -s`.
  Sem enforcement automático. Razão: não bloquear contribuidores antes
  de eles saberem da mudança.
- **Fase 2** (release seguinte): GitHub Action `DCO check` em PRs
  passa a ser obrigatório. Documentado em `.github/workflows/dco.yml`.

(Verificação cross-IA Codex: `git log --format='%an'` retornou apenas
"Luís Maurício Junqueira Zanin" — autor único confirmado, re-licenciamento
não exige autorização de terceiros.)

Cláusula explícita no `CONTRIBUTING.md`:

> Toda contribuição via PR deve incluir `Signed-off-by: Nome <email>` no commit
> (use `git commit -s`). Esta assinatura é o seu "Developer Certificate of
> Origin" — você atesta que (a) o código contribuído é seu ou você tem direito
> de licenciar, (b) você concede ao projeto useHBN licença Apache 2.0 sobre
> ele. Texto completo do DCO: https://developercertificate.org

Se no futuro o projeto exigir CCLA corporativo (Corporate Contributor License
Agreement) para contribuidores empregados de empresas, ADR sub-005-A formaliza.

### 3. Caminho de transição

| Passo | Quando | Quem | Risco |
|---|---|---|---|
| 1. ADR-005 cross-IA review por Antigravity | Pós-ratificação ADRs P0 | Opus + Antigravity | Baixo |
| 2. Hearback humano (Mauricio) | Logo após cross-IA | Mauricio | Baixo |
| 3. Re-licenciamento de contribuições AGPLv3 prévias | Mauricio é autor único confirmado em `~/Projetos/usehbn/` (verificar via `git log --format='%an'` antes) | Mauricio | Médio se houver outros autores; nulo se autor único |
| 4. Re-licenciamento de `~/Projetos/usehbn-phago/` | Idem (autor único) | Mauricio | Médio |
| 5. Atualizar `LICENSE` para Apache 2.0 completo | Após passo 3-4 | Opus arquiteto entrega draft; Mauricio comita | Baixo |
| 6. Atualizar `pyproject.toml` campo `license` | Junto com passo 5 | Idem | Baixo |
| 7. Atualizar README "License" + `docs/LICENSING.md` | Junto com passo 5 | Idem | Baixo |
| 8. Adicionar `DCO check` GitHub Action | Após passo 5 | Opus arquiteto entrega plano; Mauricio aplica | Baixo |
| 9. Atualizar `CONTRIBUTING.md` com cláusula DCO | Junto com passo 8 | Idem | Baixo |
| 10. Arquivar ou banner-superseded `~/Projetos/usehbn-phago/` | Após passo 5 | Mauricio | Baixo |
| 11. Bump SemVer MAJOR (mudança de licença = breaking) | Junto com passo 5 | Mauricio + ADR-004 | Baixo (alinhamento com Onda 6 do plano v0.3.0 / release v0.3.0 ou v0.4.0 dependendo do timing) |
| 12. CHANGELOG.md anota a transição | Junto com passo 11 | Idem | Baixo |

### 4. Impactos em apps consumidoras

- **Credenciamento (TPGL v1.1)**: nenhum ajuste imediato. Quando
  `.usehbn-snapshot/` for populado (ADR-008), o snapshot é Apache 2.0 e
  conversa limpo com TPGL. Auto-conversão futura do Credenciamento para
  Apache 2.0 (4 anos no TPGL) dará compatibilidade plena.
- **`usehbn-phago/`**: arquivado ou re-licenciado para Apache 2.0
  (decisão Mauricio). Banner "superseded by usehbn (Apache 2.0)" no
  README sugere o caminho.

### 5. Sinal `🟤 HBN LICENSE SPLIT REQUIRED` resolvido

Após ADR-005 ratificado e LICENSE atualizado, este sinal sai do estado
ativo. Permanece apenas como rastro histórico em commits anteriores.

## Consequências

**Positivas:**
- Adoção corporativa de useHBN como dependência fica viável.
- Fagocitose recíproca com Diataxis/llms.txt/MCP/LSP fica limpa.
- Patent grant explícito (Apache 2.0 §3) protege contra trolling.
- DCO como CLA leve preserva opção de re-licenciar futuramente sem custo de rastrear contribuidores.

**Negativas (assumíveis):**
- Empresa pode usar useHBN em SaaS proprietário sem devolver. Mitigação: governança humana + velocidade de evolução upstream.
- Sinal cultural "permissivo" pode afastar contribuidor ideológico pró-AGPL. Mitigação: GOVERNANCE.md explicita governança forte mesmo sob licença permissiva.

## Riscos e mitigação

| # | Risco | Mitigação |
|---|---|---|
| R1 | `~/Projetos/usehbn/` ter contribuidor além de Mauricio (re-licenciamento exige autorização de cada um) | Verificar `git log --format='%an %ae' | sort -u` antes do passo 3. Se autor único, prosseguir; senão, sub-ADR de autorização individual |
| R2 | DCO ser interpretado como menos sério que ICLA tradicional | Documentação explícita em CONTRIBUTING.md cita CNCF/Linux como precedentes |
| R3 | Empresa fork no `usehbn` virar concorrente fechado | Aceitar — protocolo aberto não impede fork; identidade do upstream + cadência de evolução são a defesa |
| R4 | AGPLv3 dependência transitiva via `usehbn-phago/` ainda contaminar | Re-licenciamento de `usehbn-phago/` é parte do plano (passo 4) |

## Próximo passo

1. ADRs P0 (002, 003, 004, 009, 001) ratificados.
2. Cross-IA review por Antigravity.
3. Hearback humano.
4. Status PROPOSED → ACCEPTED.
5. Executar passos 3-12 da §3 acima como MD subsequente
   (`MD-G: Re-licenciamento + DCO`).

## Versão

- v1.0 — 2026-05-09 — Opus 4.7 chat arquiteto-mestre — depósito inicial. Decisão direcional Apache 2.0 + CLA leve ratificada pelo operador 2026-05-09 antes do depósito; CLA leve detalhado como DCO style após análise de fricção.
- v1.1 — 2026-05-10 — Opus 4.7 chat arquiteto-mestre — MD-J cross-IA. Ajustes: (a) §1.1 checklist "tudo ou nada" dos ~35 arquivos com refs AGPL + check `license_consistency` em `hbn doctor` (insight Codex); (b) faseamento DCO — fase 1 só texto em CONTRIBUTING, fase 2 enforcement no CI; (c) registrada confirmação de autor único via `git log`.
