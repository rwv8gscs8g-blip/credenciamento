---
titulo: Tecnico MICRO39 — DT_ULT_REATIV Invalida
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-06
---

# MICRO39 — DT_ULT_REATIV Invalida

## 1. Objetivo

Fechar a lacuna de dados legados em que `DT_ULT_REATIV` nao vazia, mas
invalida, podia ser lida como `CDate(0)` e fazer a contagem punitiva de
strikes cair em modo legado silencioso.

## 2. Regra de negocio

| Caso | Comportamento |
|---|---|
| `DT_ULT_REATIV` vazia | Modo legado/backfill permitido. Nao falha por si so. |
| `DT_ULT_REATIV` valida e maior que `CDate(0)` | Janela de strikes usa `COL_OS_DT_FECHAMENTO > DT_ULT_REATIV`. |
| `DT_ULT_REATIV` nao vazia e invalida | Punicao por strikes bloqueada com `TResult.sucesso=False`. |

## 3. Implementacao

| Arquivo | Alteracao |
|---|---|
| `Repo_Avaliacao.bas` | `ContarStrikesParaPunicaoResultado` passa a validar o valor bruto da coluna antes de decidir a janela. |
| `Repo_Empresa.bas` | Novo diagnostico read-only `RepoEmpresa_DtUltReativInvalidasResumo`. |
| `Teste_V2_Roteiros.bas` | `MIG_007` injeta data invalida controlada, valida falha explicita e restaura a celula; `CS_INT_05` varre a base. |
| `Teste_V2_Engine.bas` | Catalogo e roteiro V2 incluem `MIG_007`. |
| `App_Release.bas` | Build bump para `f7aa84f+ONDA22.MD22.3-dt-ult-reativ-invalida`. |

## 4. Testes

| Cenario | Suite | Esperado |
|---|---|---|
| `MIG_007` | `TV2_RunSmoke` | Contador de strikes retorna falha explicita, `qtd=0`, mensagem cita `DT_ULT_REATIV invalida`. |
| `CS_INT_05` | `TV2_RunIntegridadeBase` | Base sem valores invalidos fica verde; base com valor invalido registra `INT-DT-ULT-REATIV-INVALIDA`. |

## 5. Risco residual

`DT_ULT_REATIV` vazia ainda e aceita como legado para compatibilidade com
bases antigas. Bases com evento `EVT_REATIVACAO` e campo vazio devem usar
o backfill explicito entregue no MICRO37.
