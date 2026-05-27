---
titulo: Codex AT-2 Diagnostico F-NEW5
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Codex AT-2 Diagnostico F-NEW5

## 1. Veredito

**GATE-A2 tecnicamente aprovado por evidencia empirica.**

O F-NEW5 operacional reportado como "rodizio sem empresas disponiveis" **nao reproduziu** no fluxo manual novo executado por Mauricio em 2026-05-27 20:05-20:10.

O diagnostico mostra que a gravacao do credenciamento novo nao ficou stale:

- `STATUS_CRED_VAL=ATIVO`
- `STATUS_CRED_VARTYPE=String`
- relatorio de empresas credenciadas por servico exibiu `ATIVO`
- emissao de Pre-OS para o servico novo foi bem-sucedida
- segunda tentativa de Pre-OS foi bloqueada corretamente por regra de negocio: empresa apta ja tinha Pre-OS pendente de aceite

Portanto, a hipotese "F-NEW5 = STATUS_CRED vazio por gravacao stale em Credencia_Empresa" fica **refutada neste cenario real**.

## 2. Evidencias usadas

### CSV DIAG_FNEW5

Arquivo:

`auditoria/evidencias/V12.0.0206/csv/DIAG_FNEW5_20260527_200546.csv`

Linha capturada:

```text
CRED_ID=009; EMP_ID=004; ATIV_ID=1331; SERV_ID=002; COD_ATIV_SERV=1331002; STATUS_CRED=ATIVO
```

Campos diagnosticos relevantes:

| Campo | Valor | VarType | NumberFormat | Interpretacao |
|---|---:|---|---|---|
| `CRED_ID` | `009` | String | `@` | correto |
| `EMP_ID` | `004` | String | `@` | correto |
| `ATIV_ID` | `1331` | Double | General | confirma coerção numerica F-NEW6 em CREDENCIADOS, mas nao quebrou este fluxo |
| `COD_ATIV_SERV` | `1331002` | String | `@` | correto |
| `STATUS_CRED` | `ATIVO` | String | General | correto; nao ha status vazio |
| `ULT_OS` | vazio | String | `@` | esperado para credenciamento novo |

### Evidencia de interface reportada por Mauricio

Fluxo manual descrito:

1. Criou atividade `SERVICOS DOMESTICOS` e servico `TESTE_DIAG_FNEW5_1525`.
2. Cadastrou `empresa 4`.
3. Credenciou `empresa 4` no servico novo.
4. Interface confirmou credenciamento.
5. Emissao de Pre-OS foi bem-sucedida.
6. Relatorio "Empresas Credenciadas por Servico" exibiu `STATUS CRED=ATIVO`.
7. Nova emissao de Pre-OS foi bloqueada corretamente porque havia Pre-OS pendente.

Observacao marginal: durante a criacao da atividade, a lista branca do form `Cadastro_Servico` ficou momentaneamente vazia. Como o servico foi cadastrado, o valor foi registrado e o fluxo subsequente funcionou, isso nao bloqueia GATE-A2; registrar como observacao de UI se reaparecer em uso prolongado.

### CSV RVS Strikes

Arquivo recebido:

`TesteV2_STRIKES_E2E_Falhas_TV2_20260527_202518.csv`

Copia canonica preservada para auditoria:

`auditoria/evidencias/V12.0.0206/csv/TesteV2_STRIKES_E2E_Falhas_TV2_20260527_202518.csv`

Todas as 11 falhas sao o mesmo cenario:

```text
DIAG_PREOS_INTEGRITY
esperado: EMP=001
obtido: EMP_PRESEL=001 EMP_PREOS=1
```

Isso nao e F-NEW5 operacional. E a falha F-NEW6 ja consolidada: `PRE_OS.COL_PREOS_EMP_ID` esta sendo gravado ou lido sem preservacao textual, entao `001` vira `1`.

## 3. Interpretacao tecnica

### 3.1 F-NEW5 nao e gravacao stale do status

O CSV captura o estado da linha em `CREDENCIADOS` depois de `ClassificaCredenciadoOrdem` e `AtualizarListaEmpresaMenuAtual`, antes da validacao final. Mesmo apos sort/reload, a linha atual foi localizada e o status permaneceu `ATIVO`.

Logo:

- `Credencia_Empresa.CR_Credenciar_Click` gravou `COL_CRED_STATUS` corretamente.
- O relatorio leu e exibiu o status corretamente.
- O rodizio encontrou a empresa e emitiu a Pre-OS.

### 3.2 F-NEW6 foi confirmado em duas frentes

O diagnostico manual confirmou que `CREDENCIADOS.COL_CRED_ATIV_ID` foi persistido como `Double/General`.

O RVS confirmou que `PRE_OS.COL_PREOS_EMP_ID` retorna `1` quando a pre-selecao esperava `001`.

Essas evidencias confirmam a classe sistemica F-NEW6, mas nao provam que ela causou o F-NEW5 manual original. A correcao pontual AT-3 continua necessaria porque o gate automatizado `TV2_RunRodizioStrikesEndToEnd` segue reprovando.

## 4. Recomendacao

Prosseguir para auditoria cruzada do GATE-A2 com o seguinte veredito:

- **Aprovar AT-2**: diagnostico gerou evidencia suficiente e o F-NEW5 operacional nao reproduziu.
- **Nao implementar fix de F-NEW5 em `Credencia_Empresa` agora**: nao ha evidencia de gravacao stale do status.
- **Prosseguir para AT-3 apos auditoria**: aplicar a excecao alfa aprovada em `Svc_PreOS.EmitirPreOS` para `NumberFormat="@"` antes das gravacoes e normalizador type-aware em `Repo_PreOS.BuscarPorId`, cobrindo `X`, `Null`, `Error` e `>=1000` sem `Pad3` direto sobre `Variant`.
- **Manter observacao de UI** sobre lista branca em `Cadastro_Servico` como marginal para GATE-USO-PROLONGADO, sem bloquear AT-3.

## 5. Proxima decisao esperada

Mauricio deve levar esta proposta para Opus + Antigravity em chats novos.

Saidas esperadas:

- Opus: `.hbn/proposals/0017-opus-auditoria-gate-a2-onda-38-2-3.md`
- Antigravity: `.hbn/proposals/0018-antigravity-auditoria-gate-a2-onda-38-2-3.md`

Pergunta objetiva aos auditores:

> Com base no CSV DIAG_FNEW5 e no CSV RVS Strikes, voces aprovam o GATE-A2 como diagnostico suficiente para encerrar F-NEW5 como nao reproduzido neste fluxo e seguir para AT-3, tratando a falha restante como F-NEW6 em PRE_OS/Repo_PreOS?

Codex nao deve iniciar AT-3 antes do retorno consolidado das duas auditorias e hearback Mauricio.
