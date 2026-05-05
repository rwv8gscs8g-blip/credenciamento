---
titulo: 20 - Tecnico Onda 20 V204 P0 UI
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-05
---

# Onda 20 V204 - P0 UI

## 1. Objetivo

Fechar os P0 apontados nas auditorias cruzadas 64/65 e sintetizados no
doc 66: reativacao de entidade sem servico, mutacao silenciosa de
`COL_CRED_ATIV_ID` na reativacao de empresa e ausencia de guard contra
reentrada em forms mutadores.

## 2. Decisao de negocio aplicada

Foi aplicada a decisao aprovada pelo operador:

1. A reativacao de empresa deve preservar/restaurar o vinculo de
   credenciamento por atividade quando o registro ja existe.
2. A restauracao usa `COL_CRED_COD_ATIV_SERV` para recuperar o
   `COL_CRED_ATIV_ID` quando o form encontra valor vazio ou `X`.
3. Se a atividade nao puder ser derivada, o sistema falha explicitamente.
4. Novo recredenciamento nao e inferido por reativacao; deve ser uma acao
   explicita e auditada no fluxo proprio.

## 3. Implementacao

| Area | Arquivos | Mudanca |
|---|---|---|
| Servico entidade | `src/vba/Svc_Entidade.bas` | Novo `ReativarEntidadePorChave`, com bloqueio de duplicidade ativa e `EVT_REATIVACAO` para `ENT_ENTIDADE`. |
| Servico rodizio | `src/vba/Svc_Rodizio.bas` | Novo `RestaurarCredenciamentosEmpresa`, com restauracao por `COD_ATIV_SERV` e falha explicita quando nao derivavel. |
| Reativacao empresa | `src/vba/Reativa_Empresa.frm` | Remove mutacao silenciosa de `COL_CRED_ATIV_ID`, chama servico de restauracao e adiciona guard de reentrada. |
| Reativacao entidade | `src/vba/Reativa_Entidade.frm` | Deixa de copiar/excluir sozinho e delega ao servico novo. |
| Forms mutadores | `Altera_Empresa`, `Altera_Entidade`, `Limpar_Base`, `Menu_Principal` | Guard simples contra reentrada/double-click nos handlers mutadores. |
| Testes | `Teste_V2_Roteiros`, `Teste_V2_Engine` | CS_23 reforcado, CS_25 novo e smoke `CS_UISMOKE_REENTRADA_GUARDS`. |

## 4. Cobertura adicionada

| Cenario | Suite | Cobertura |
|---|---|---|
| `CS_23` | V2 Canonica | Empresa inativa volta ativa com `DT_ULT_REATIV` e 3 credenciamentos ativos no item. |
| `CS_25` | V2 Canonica | Credenciamento com `ATIV_ID=X` e `COD_ATIV_SERV` vazio falha explicitamente, sem recredenciamento silencioso. |
| `CS_UISMOKE_REENTRADA_GUARDS` | V2 Smoke | Verifica flags de reentrada nos seis forms mutadores tocados. |

Com isso, a expectativa do Quinteto muda para:

```text
V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0
```

## 5. Arquivos importaveis

Manifesto: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO31.txt`.

Comando:

```vb
ImportarPacoteV3_Delta "MICRO31", "f7aa84f+ONDA20.MD20-p0-ui-reativacao"
```

## 6. Gates

1. Importador V3: `M=5 | F=6 | err=0 | skip=0`.
2. VBE: `Depurar > Compilar VBAProject` sem erro.
3. Janela imediata: `?GetBuildImportado` retorna
   `f7aa84f+ONDA20.MD20-p0-ui-reativacao`.
4. `CT_ValidarRelease_QuintetoMinimo` aprovado.

## 7. Proxima onda

Depois do Quinteto verde da Onda 20, avancar para Onda 21:
transacionalidade/rollback nos fluxos OS, Pre-OS, avaliacao e limpeza.
