---
titulo: 66 - Sintese auditoria cruzada V203 rc4 e abertura V204
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-05
---

# 66. Sintese - Auditorias 64/65 e abertura da V12.0.0204

## 1. Decisao consolidada

As auditorias 64 (Opus 4.7) e 65 (Antigravity) convergem em um ponto:

**V12.0.0203-rc4 esta APROVADA_PARA_TESTE_MANUAL e NAO esta aprovada
para producao.**

O gate `VR_20260504_171048` permanece valido:

`V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0`

A linha de producao deve ser a `V12.0.0204`, depois de fechar os
P0/P1 abaixo e ampliar as baterias de teste.

## 2. Ajuste interpretativo das auditorias

| Tema | Auditoria 64 | Auditoria 65 | Sintese Codex |
|---|---|---|---|
| `Reativa_Empresa.frm` bypass total | considera R1 empresa corrigido por MICRO30, mas aponta mutacao `ATIV_ID` | aponta bypass total em `301-349` | **Parcialmente falso positivo em 65**: o form chama `ReativarLinhaEmpresa` em `310`, entao `DT_ULT_REATIV` e auditoria de empresa foram corrigidas. O debito real remanescente e a copia/delete no form e a mutacao silenciosa de `COL_CRED_ATIV_ID`. |
| `Reativa_Entidade.frm` | P0 bypass simetrico ainda aberto | risco de UI bypass | **P0 confirmado**: copia direta para `ENTIDADE`, exclui de `ENTIDADE_INATIVOS` e nao registra `AUDIT_LOG`. |
| Reentrada UI | P1 | P0 | **P0 para producao**: todo `_DblClick` mutador deve ter guard. |
| `GravarStatusEmpresa` | P1 | P1 | **P1 confirmado**: `Public Sub` silencioso deve virar contrato retornavel. |
| `ContarStrikes*` | P1 | P1 | **P1 confirmado**: erro nao pode virar zero strikes. |
| `EmitirOS` transacional | P1 complementar | P1 | **P1 confirmado**: OS pode nascer antes de PRE_OS/rollback estar garantido. |
| Datas invalidas/backdated | P1/P2 | P1/P2 | **P1 confirmado**: `DT_ULT_REATIV` invalida e bordas temporais precisam teste + tratamento. |
| Senha hardcoded | P2/P1-publicacao | P2 | **P2 seguranca**: nao bloqueia teste manual, deve fechar antes de producao publica. |

## 3. Bloqueadores V204 final

| ID | Severidade V204 | Origem | Acao requerida |
|---|---|---|---|
| `DT-V204-UI-REATIVA-ENTIDADE-SERVICE` | P0 | 64 P0-A / 65 bypass | Criar caminho de servico/auditoria para reativar entidade. |
| `DT-V204-UI-REENTRADA-GUARD` | P0 | 64 P1-A / 65 P0 | Semaforo em forms mutadores e cenarios adversariais. |
| `DT-V204-REATIVA-EMPRESA-ATIV-ID` | P0 decisao | 64 P0-B | Decidir se reativar preserva ou zera credenciamentos por atividade. Implementar sem mutacao silenciosa. |
| `DT-V204-GRAVARSTATUS-RESULT` | P1 | 64 P1-B / 65 P1 | `GravarStatusEmpresa` deve retornar sucesso/falha e todos chamadores devem checar. |
| `DT-V204-AVALIAROS-PROPAGA-FALHAS` | P1 | 64 P1-C | `AvaliarOS` deve tratar falha de suspensao/fila como contrato explicito. |
| `DT-V204-CONTARSTRIKES-RESULT` | P1 | 64 P1-D / 65 P1 | Contadores de strikes devem devolver resultado estruturado, nao zero em erro. |
| `DT-V204-LEREMPRESA-DATA-INVALIDA` | P1 | 64 P1-F / 65 datas | Data invalida em `DT_ULT_REATIV` deve gerar diagnostico e teste. |
| `DT-V204-EMITIR-OS-ROLLBACK` | P1 | 65 P1 | `EmitirOS` precisa rollback/ordem transacional segura. |
| `DT-V204-BACKFILL-AUDIT` | P1 | 64/65 | Empresas legadas precisam backfill auditavel quando houver evidencia em `AUDIT_LOG`. |
| `DT-V204-INT-CAD-OS-REF-ORFA` | P1 dado | bug conhecido | Resolver ou migrar referencias orfas antes de producao. |

## 4. Decisoes humanas antes do primeiro microdelta

| Decisao | Recomendacao Codex | Impacto |
|---|---|---|
| `COL_CRED_ATIV_ID` deve ser zerado na reativacao de empresa? | **Nao, por padrao preservar.** Se o negocio exigir recredenciamento, mover para servico explicito com confirmacao e evento. | Define Onda 20 MD-20.2. |
| V203 rc4 deve receber tag GitHub formal? | Manter como PR/rc de teste manual; producao fica V204. | Evita publicar candidato como estavel. |
| V204 pula V203 estavel? | Sim: V203 foi candidata/teste; V204 deve ser a primeira candidata a producao pos-debitos. | Simplifica comunicacao publica. |
| Guard de UI sera local por form ou helper central? | Helper central + flag local por form. | Reduz duplicacao e padroniza testes. |

## 5. Estrategia V204

1. Corrigir P0 de UI primeiro, porque eles podem corromper dados por
   acao humana normal.
2. Depois corrigir P1 transacional, porque esses erros podem produzir
   sucesso falso.
3. Depois fechar migracao/backfill e integridade de dados.
4. Em seguida criar baterias adversariais e combinatorias.
5. Por fim endurecer seguranca preventiva e fechar release.

## 6. Markers HBN

- ✅ HBN ACTIVE
- 🟡 HBN NEEDS HUMAN DECISION: decisao sobre `COL_CRED_ATIV_ID`
- 🔴 HBN RELEASE BLOCKER: V204 final bloqueada ate P0/P1 fechados
- 🔵 HBN ROADMAP READY: ver plano 29 e roadmap da Onda 20
