---
titulo: Indice do Bastao IA
ultima-atualizacao: 2026-04-12
autor-ultima-alteracao: Claude Opus 4.6
tags: [vivo, regra]
versao-sistema: V12.0.0145
---

# Indice do Bastao IA

## Regras do Bastao

1. A IA com o bastao escreve documentos de trabalho AQUI (diagnosticos, planos, decisoes)
2. Formato do nome: `NNNN-YYYY-MM-DD-NomeAssunto.md` (NNNN = sequencial de 4 digitos)
3. Cada documento tem frontmatter YAML com: titulo, data, autor (IA), versao, status
4. Quando a pasta tiver mais de 20 documentos, ou quando for necessario reorganizar, a IA move os documentos superados para `historico/`
5. Documentos vencidos (bugs finalizados, planos concluidos) sao movidos para `historico/` e um novo documento resume o estado atual
6. A IA com o bastao pode (e deve) atualizar documentos vivos em outros locais do vault (REGRAS.md, ESTADO-ATUAL.md, DASHBOARD, etc.)
7. Para saber o proximo numero sequencial: verificar o maior NNNN existente e somar 1

## IA Atual com o Bastao

- **IA**: Claude Opus 4.6 (Cowork)
- **Desde**: 2026-04-12
- **Sessao**: Reestruturacao documentacao + importacao CNAE

## Documentos Ativos

| # | Data | Assunto | Status |
|---|------|---------|--------|
| 0001 | 2026-04-12 | Reestruturacao-Documentacao | Ativo |

## Documentos no Historico

Nenhum ainda.

## Como Passar o Bastao

Ao encerrar a sessao, a IA deve:
1. Atualizar este INDICE.md com status final dos documentos
2. Atualizar ai/ESTADO-ATUAL.md com versao e status
3. Atualizar ai/GOVERNANCA.md com releases feitas
4. Deixar claro no handoff o que ficou pendente
