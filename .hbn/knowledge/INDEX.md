---
titulo: Knowledge Base do Credenciamento (HBN)
ultima-atualizacao: 2026-04-28
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

## Por decisao (decisoes que afetam comportamento)

| Tema | Arquivo | Impacto |
|---|---|---|
| Bastao de implementacao Onda 6+ | [../relay/0001-onda06-consolidacao-documental.md](../relay/0001-onda06-consolidacao-documental.md) | Claude Opus tem bastao ate V12.0.0203 estavel no GitHub |
| Adopcao Diataxis + llms.txt + AGENTS.md | [0001-regras-v203-inegociaveis.md](0001-regras-v203-inegociaveis.md) | Estrutura `docs/` e mapas para LLMs |

## Arquivamento

Quando uma decisao for explicitamente revogada por release oficial,
mover o arquivo para `.hbn/relay-archive/` com sufixo `_revogado_AAAA-MM-DD`.
