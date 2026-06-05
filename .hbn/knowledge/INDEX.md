---
titulo: Knowledge Base do Credenciamento (HBN)
ultima-atualizacao: 2026-06-05
---

# Knowledge Base do Credenciamento (HBN)

> Descobertas reutilizaveis entre IAs. **Nao** e historia operacional de
> curto prazo. Para isso, ver `.hbn/relay-archive/`.

## Convencao

- Nomeacao: `0001-Assunto.md`, `0002-Assunto.md`, ...
- Toda entrada tem frontmatter YAML com `titulo`, `data`, `autoria`,
  `aplica-a` e `revisar-em`.
- Toda entrada termina com a secao "Como verificar" — comandos ou
  procedimentos para a proxima IA validar que o conhecimento ainda e
  valido.

## Por padrao (operacional permanente)

| Tema | Arquivo | Uso |
|---|---|---|
| Regras V203 inegociaveis | [0001-regras-v203-inegociaveis.md](0001-regras-v203-inegociaveis.md) | Toda IA que entrar no projeto le primeiro |
| Regra de Ouro do `vba_import/` | [0002-regra-ouro-vba-import.md](0002-regra-ouro-vba-import.md) | Antes de modificar `.bas` ou `.frm` |
| Camada Glasswing de seguranca preventiva | [0003-glasswing-style-preventive-security.md](0003-glasswing-style-preventive-security.md) | Antes de declarar onda fechada |
| Padrao resposta: tabela de entrega de arquivos | [0004-padrao-resposta-tabela-de-entrega.md](0004-padrao-resposta-tabela-de-entrega.md) | Toda entrega operacional para o operador |
| Bug conhecido: formulario importado como modulo no VBE | [0005-bug-form-importado-como-modulo.md](0005-bug-form-importado-como-modulo.md) | Antes de qualquer `File > Import` de `.frm`, e como diagnosticar/recuperar quando o bug se manifesta |
| Padronizacao obrigatoria de encoding, line endings e EOF | [0006-padronizacao-encoding-line-endings-frm.md](0006-padronizacao-encoding-line-endings-frm.md) | Antes de salvar/comitar qualquer `.frm` ou `.bas`. Root cause comprovada do bug 0005. |
| Funcionalidade nova exige teste correspondente | [0010-funcionalidade-nova-exige-teste.md](0010-funcionalidade-nova-exige-teste.md) | Antes de propor ou implementar qualquer nova funcionalidade, regra de negocio, fluxo de UI ou comportamento de servico |
| Higiene documental recorrente | [0011-higiene-documental-recorrente.md](0011-higiene-documental-recorrente.md) | Antes de passar de microdelta, onda, release ou bastao |
| Raiz canonica obrigatoria do projeto | [0012-raiz-canonica-projeto.md](0012-raiz-canonica-projeto.md) | Antes de qualquer leitura, escrita, importacao, handoff ou uso de worktree |
| Handoff aos 50% de contexto — orçamento obrigatório de qualidade | [0017-handoff-aos-50-pct-contexto.md](0017-handoff-aos-50-pct-contexto.md) | Toda IA em sessão longa: gatilho duro aos 50% + orçamento 50/30/20; reforça §7.3 do PROMPT_ARQUITETO v1.3+ |
| Protocolo de fim-de-sessão + registro de transferência de bastão | [0014-protocolo-fim-de-sessao.md](0014-protocolo-fim-de-sessao.md) | Handoff obrigatório a 50% / fim de onda / **transferência de bastão** (itens 13-16 + checklist anti-viés §12.4, fundidos na onda 0113) |
| Cadência D Estendida — passagem de bastão entre IAs | [0019-cadencia-d-estendida-passagem-bastao.md](0019-cadencia-d-estendida-passagem-bastao.md) | Toda IA que implementa, audita ou recomenda bastão: papéis, auditoria em chat novo, severidade BLOQUEADOR/FORTE/MARGINAL + veto, checklist anti-viés. Materializa §12 do PROMPT_ARQUITETO v1.4+ |
| L44 — diff "cosmético" de sub-agente é suspeito | [0020-explore-diff-cosmetico-suspeito.md](0020-explore-diff-cosmetico-suspeito.md) | Antes de aceitar diff "cosmético" de Explore/Task em .frm/.code-only.txt: inspecionar o pipeline gerador |
| Arquiteto via Cowork — sandbox vs raiz canônica | [0021-arquiteto-via-cowork-sandbox.md](0021-arquiteto-via-cowork-sandbox.md) | Toda execução do PROMPT_ARQUITETO via Cowork: guards no sandbox são informativos; validação conclusiva + commit no Terminal do operador (L27/L28). Nunca bypass |
| Firewall — workflows só `fast_track`; escrita `safe_track` é humano-aplicada | [0022-firewall-workflow-fast-track.md](0022-firewall-workflow-fast-track.md) | Antes de propor/aceitar qualquer orquestração automática, scheduled task ou fan-out: leitura/análise/auditoria OK; escrita de domínio ou aplicação no Excel em run autônomo = ❌ SECURITY BLOCKED. Fonte canônica única (decisão Mauricio, hearback 0145) |

## Por decisao (decisoes que afetam comportamento)

| Tema | Arquivo | Impacto |
|---|---|---|
| Bastao de implementacao Onda 6+ | [../relay/0001-onda06-consolidacao-documental.md](../relay/0001-onda06-consolidacao-documental.md) | Claude Opus tem bastao ate V12.0.0203 estavel no GitHub |
| Adopcao Diataxis + llms.txt + AGENTS.md | [0001-regras-v203-inegociaveis.md](0001-regras-v203-inegociaveis.md) | Estrutura `docs/` e mapas para LLMs |

## Arquivamento

Quando uma decisao for explicitamente revogada por release oficial,
mover o arquivo para `.hbn/relay-archive/` com sufixo `_revogado_AAAA-MM-DD`.
