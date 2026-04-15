---
titulo: Governanca IA - Rastreabilidade de Autoria
ultima-atualizacao: 2026-04-15
autor-ultima-alteracao: GPT-5.2 (Cursor)
tags: [vivo, regra]
versao-sistema: V12.0.0166
---

# Governanca IA

## Proposito

Este documento rastreia qual IA fez cada alteracao no projeto. Toda IA com o bastao DEVE atualizar esta tabela ao criar uma release.

## Tabela de Releases

| Versao | Data | IA Autor | Revisor | Status | Compila | Nota |
|--------|------|----------|---------|--------|---------|------|
| V12.0.0166 | 2026-04-15 | GPT-5.2 (Cursor) | Mauricio | EM_VALIDACAO | Sim | Acentos MsgBox bateria + relatório RPT_BATERIA |
| V12.0.0165 | 2026-04-15 | GPT-5.2 (Cursor) | Mauricio | EM_VALIDACAO | Sim | Acentos Roteiro + média impressão sem arredondar |
| V12.0.0163 | 2026-04-14 | GPT-5.2 (Cursor) | Mauricio | EM_VALIDACAO | Sim | Importador VBA (remove+importa pelo manifesto) |
| V12.0.0162 | 2026-04-13 | GPT-5.2 (Cursor) | Mauricio | EM_VALIDACAO | Sim | Acentos MsgBox/relatorios/config/impressao |
| V12.0.0161 | 2026-04-14 | GPT-5.2 (Cursor) | Mauricio | EM_VALIDACAO | Sim | Ingress Menu + acentos MsgBox Menu_Principal |
| V12.0.0160 | 2026-04-14 | GPT-5.2 (Cursor) | Mauricio | EM_VALIDACAO | Sim | Lista folga + botoes Reativa PicturePosition |
| V12.0.0159 | 2026-04-14 | GPT-5.2 (Cursor) | Mauricio | EM_VALIDACAO | Sim | Grid Entidade/Empresa + ingress Menu_Principal |
| V12.0.0158 | 2026-04-14 | GPT-5.2 (Cursor) | Mauricio | EM_VALIDACAO | Sim | Lista empresa: ColumnWidths vs largura ListBox |
| V12.0.0157 | 2026-04-13 | GPT-5.2 (Cursor) | Mauricio | EM_VALIDACAO | Sim | Lista empresa: largura Tel. Celular |
| V12.0.0156 | 2026-04-13 | GPT-5.2 (Cursor) | Mauricio | EM_VALIDACAO | Sim | Labels lista empresa + PreOS |
| V12.0.0155 | 2026-04-13 | GPT-5.2 (Cursor) | Mauricio | EM_VALIDACAO | Sim | Pre-OS/OS botoes fisicos |
| V12.0.0154 | 2026-04-13 | GPT-5.2 (Cursor) | Mauricio | EM_VALIDACAO | Sim | Remove heuristica Tela Inicial |
| V12.0.0153 | 2026-04-13 | GPT-5.2 (Cursor) | Mauricio | EM_VALIDACAO | Sim | Handlers CommandButton13/14/15 |
| V12.0.0152 | 2026-04-13 | GPT-5.2 (Cursor) | Mauricio | EM_VALIDACAO | Sim | Evita duplicar BT_* em runtime |
| V12.0.0151 | 2026-04-13 | GPT-5.2 (Cursor) | Mauricio | EM_VALIDACAO | Sim | Botoes Tela Inicial por Name |
| V12.0.0145 | 2026-04-12 | Claude Opus 4.6 | Mauricio | EM_VALIDACAO | Sim | Reestruturacao documentacao |
| V12.0.0144 | 2026-04-12 | Claude Opus 4.6 | Mauricio | EM_VALIDACAO | Sim | ImportarCNAE_Emergencia V2 + normalize |
| V12.0.0143 | 2026-04-12 | Claude Opus 4.6 | Mauricio | EM_VALIDACAO | Sim | ResetarECarregarCNAE rewrite |
| V12.0.0142 | 2026-04-12 | Claude Opus 4.6 | Mauricio | REVERTIDO | Sim | ResetarECarregarCNAE (ATIVIDADES vazia) |
| V12.0.0141 | 2026-04-12 | Claude Opus 4.6 | Mauricio | EM_VALIDACAO | Sim | Fix SV_Lista, CNAE import, cache |
| V12.0.0140 | 2026-04-11 | Cursor Auto | Mauricio | VALIDADO | Sim | Estabilizacao filtros |
| V12.0.0107-0139 | 2026-04-04 a 04-11 | Cursor/Codex/Sonnet | Mauricio | Varios | Sim | Desenvolvimento incremental |
| V12.0.0062-0106 | Anteriores | Cursor/Codex | Mauricio | Varios | Varios | Fase de construcao |
| V12.0.0010-0061 | Anteriores | Cursor | Mauricio | Historico | Varios | Fase inicial |

## Regra de Preenchimento

Ao criar uma release, adicionar uma linha no TOPO da tabela com:
- Versao exata
- Data no formato YYYY-MM-DD
- Nome completo da IA (incluindo modelo)
- Nome do revisor humano
- Status: RASCUNHO / EM_VALIDACAO / VALIDADO / REVERTIDO
- Se compila ou nao
- Nota breve (max 60 caracteres)

## Certificacao de Integridade

Para gerar hashes de integridade dos arquivos VBA:

```bash
cd vba_export/
sha256sum *.bas *.frm > ../obsidian-vault/ai/HASHES.md
```

Isso permite verificar se algum arquivo foi alterado fora do fluxo oficial.

## Documentos Relacionados

- [[REGRAS]] — Regras inviolaveis
- [[PIPELINE]] — Ciclo de iteracao
- [[ESTADO-ATUAL]] — Versao e status
