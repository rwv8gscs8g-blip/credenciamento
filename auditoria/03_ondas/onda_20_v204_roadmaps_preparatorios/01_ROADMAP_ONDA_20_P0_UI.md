---
titulo: 01 - Roadmap Onda 20 V204 P0 UI
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-05
---

# Onda 20 V204 - P0 UI, reativacao e reentrada

## 1. Objetivo

Fechar os P0 que bloqueiam producao: reativacao de entidade sem servico,
reentrada por duplo clique e mutacao silenciosa de `COL_CRED_ATIV_ID` na
reativacao de empresa.

## 2. Escopo

| ID | Achado | Severidade | Arquivos provaveis |
|---|---|---|---|
| P0-20.1 | `Reativa_Entidade.frm` copia/exclui sem servico nem `AUDIT_LOG` | P0 | `Reativa_Entidade.frm`, novo servico |
| P0-20.2 | `_DblClick` mutador sem guard | P0 | forms mutadores |
| P0-20.3 | `Reativa_Empresa.frm` zera `COL_CRED_ATIV_ID` silenciosamente | P0 decisao | `Reativa_Empresa.frm`, credenciamento |
| P1-20.4 | comparacao de ID via `CLng(Val(...))` | P1 | `Reativa_Empresa.frm`, `Altera_Entidade.frm` |

## 3. Microdeltas

| MD | Mudanca | Teste novo | Gate |
|---|---|---|---|
| MD-20.1 | Criar contrato de reativacao de entidade com retorno e auditoria | `CS_REATIV_UI_ENTIDADE_AUDIT` | V2 Canonica |
| MD-20.2 | Formalizar decisao `ATIV_ID` e remover mutacao silenciosa | `CS_REATIV_UI_ATIV_ID_DECISAO` | V2 Canonica |
| MD-20.3 | Guard de reentrada em `Reativa_Empresa` e `Reativa_Entidade` | `CS_REATIV_UI_REENTRADA` | Smoke + Canonica |
| MD-20.4 | Expandir guard para `Altera_Empresa`, `Limpar_Base`, `Menu_Principal` | `TV2_RunAdversarial_UI` parcial | Quinteto |
| MD-20.5 | Trocar comparacoes numericas por `IdsIguais` | regressao `BO_320_IntegridadeIdsIguais` | Quinteto |

## 4. Fora de escopo

1. Refatorar todos os forms do sistema.
2. Resolver transacoes de OS/PreOS.
3. Implementar backfill.
4. Alterar `Mod_Types.bas`, salvo se uma decisao C4 for aberta.

## 5. Criterio de aceite

1. Reativar entidade registra evento auditavel.
2. Reativar empresa nao zera credenciamento por atividade sem decisao
   documentada e evento.
3. Duplo clique repetido nao duplica linhas nem apaga origem errada.
4. Quinteto verde.
5. Nenhum P0 remanescente de UI.
