---
titulo: Reestruturacao da Documentacao do Projeto
data: 2026-04-12
autor: Claude Opus 4.6 (Cowork)
versao: V12.0.0145
status: ativo
tags: [bastao, decisao]
---

# 0001 - Reestruturacao da Documentacao

## Contexto

O projeto tinha documentacao espalhada em 6 locais: ai-context/, doc/, obsidian-vault/, release-notes/, raiz (.md), e .cursorrules. Cada IA que entrava no projeto lia um subconjunto diferente e recebia instrucoes potencialmente contraditorias.

## Decisoes Tomadas

1. Consolidar TODA documentacao sob obsidian-vault/
2. Criar pasta ai/ com governanca, regras, pipeline, estado atual
3. Criar sistema de bastao com numeracao sequencial
4. Mover release notes fragmentadas para um unico local
5. Arquivar documentos historicos separados dos vivos
6. Atualizar .cursorrules para apontar para vault

## O que foi feito nesta sessao

- Importacao de 612 CNAEs via ImportarCNAE_Emergencia (apos 6h de tentativas)
- Criacao de ai/REGRAS.md, PIPELINE.md, ESTADO-ATUAL.md, GOVERNANCA.md
- Criacao do sistema de bastao com INDICE.md
- Consolidacao de release notes (78 releases + 53 historico)
- Migracao de handoffs para ai/handoffs/
- Limpeza de raiz e arquivamento de historicos

## Licoes Aprendidas

- Solucoes simples > solucoes complexas (ImportarCNAE_Emergencia vs cadeia complexa)
- VBE nao substitui modulos ao importar — cria duplicatas
- Toda mudanca precisa de version bump + release note (compliance)
- A IA que "descobre os problemas" nem sempre e a que "resolve os problemas"

## Documentos Criados

- obsidian-vault/ai/REGRAS.md
- obsidian-vault/ai/PIPELINE.md
- obsidian-vault/ai/ESTADO-ATUAL.md
- obsidian-vault/ai/GOVERNANCA.md
- obsidian-vault/ai/known-issues.md
- obsidian-vault/ai/bastao/INDICE.md
- obsidian-vault/ai/bastao/0001-2026-04-12-Reestruturacao-Documentacao.md (este)
