---
titulo: 44 — Débito DT-17-REATIV-STRIKES (cobertura amarela em Onda 17, conserto prioritário em Onda 18)
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203 (rc2 com débito declarado; release público condicionado à Onda 18)
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1
---

# 44. Débito DT-17-REATIV-STRIKES

## TL;DR

Durante a MD-17.1.b da Onda 17 (cobertura de strikes), pergunta de
revisão do operador (Luís Maurício, 2026-05-03) expôs que o sistema
atual **não zera o contador de strikes ao reativar uma empresa**. Uma
empresa que cumpre 90 dias de suspensão e volta com `STATUS=ATIVA`
ainda tem todo o histórico antigo de avaliações ruins em `CAD_OS`. Na
primeira nota baixa pós-reativação, `ContarStrikesPorEmpresa` retorna
`strikes_antigos + 1 >= MAX_STRIKES` e a empresa é **re-suspensa
imediatamente**. Empresa não regenera reputação após cumprir suspensão.

Investigação revelou que isso é **decisão de produto V12.0.0203
documentada** (auditoria/00_status/26 §06.3) — não bug. A "janela
temporal pós-reativação" foi explicitamente adiada para evolução
posterior.

Decisão tomada em 2026-05-03: registrar débito formal **DT-17-REATIV-STRIKES**,
documentar o cenário como **AMARELO** (`TV2_LogManual`, não bloqueia
gate) na Onda 17, e **resolver na Onda 18 sem expansão de escopo**
adotando a Opção B do operador (dupla informação: histórico total
preservado + strikes para punição com janela temporal). Release
público de V12.0.0203 fica **condicionado** à conclusão da Onda 18.

## 1. Como o débito surgiu

Durante a MD-17.1.b da Onda 17, ao planejar o cenário
`CS_E2E_REATIV2STRIKES`, o operador perguntou:

> *"Se o contador não é zerado e a empresa é ativada, não pode ocorrer
> o risco dela ser 'desativada novamente' por estar com 3 strikes no
> sistema? Se não zerar como o sistema vai garantir que ele não seja
> punido novamente em uma próxima passada?"*

Investigação (Opus, pre-flight L14 reforçado) confirmou que o risco é
real. O sistema **não tem mecanismo** de janela temporal nem de
"strike consumido" pós-reativação.

## 2. Evidência consolidada (4 fontes do próprio repositório)

| Fonte | Trecho |
|---|---|
| [`auditoria/00_status/26_DIAGNOSTICO_LOOPING_CODEX_E_PROMPT_RETOMADA.md`](26_DIAGNOSTICO_LOOPING_CODEX_E_PROMPT_RETOMADA.md) §06.3 (linha 417) | *"política do contador: **acumulativo** (não zera com avaliação boa), **sem janela temporal na primeira versão** (decisão de produto a ser registrada no CHANGELOG)"* |
| `src/vba/Svc_Avaliacao.bas` §374-379 (comentário no código) | *"Ao reativar... a empresa volta a contar do zero ... **na próxima evolução** (ver auditoria/27 seção 03 e auditoria/28 seção 04 para o roadmap da **janela temporal**)"* — qualificação como pendência futura |
| `src/vba/Teste_V2_Roteiros.bas` §1574-1576 (cabeçalho de TV2_RunRodizioStrikesEndToEnd antes da Onda 17) | *"ContarStrikesPorEmpresa lê **histórico completo (sem janela temporal — decisão de produto V12.0.0203)**. Reativação por timeout usa mecanismo nativo SelecionarEmpresa→Reativar."* |
| `auditoria/04_evidencias/V12.0.0203/TesteV2_STRIKES_E2E_Falhas_TV2_20260502_020217.csv` linha 11 | *"Strike é contado mesmo após reativação da EMP1"* — falha histórica documentada |

`Svc_Rodizio.Reativar()` (linhas 354-394) confirma: zera apenas
`QTD_RECUSAS_GLOBAL` + limpa `DT_FIM_SUSP` + seta `STATUS=ATIVA`. Não
toca `CAD_OS`, não grava timestamp de reativação em EMPRESAS.

## 3. Como a re-suspensão acontece concretamente

| Passo | Estado |
|---|---|
| 1. EMP1 com MAX_STRIKES=3 acumula 3 strikes | `STATUS_GLOBAL=SUSPENSA_GLOBAL`, `DT_FIM_SUSP=hoje+90` |
| 2. 90 dias passam | `DT_FIM_SUSP <= hoje` |
| 3. SelecionarEmpresa próxima vez encontra EMP1 com prazo vencido | Chama `Reativar(EMP1)` automaticamente |
| 4. Reativar zera QTD_RECUSAS, seta STATUS=ATIVA | EMP1 volta à fila — **mas CAD_OS ainda tem 3 OS com média baixa** |
| 5. EMP1 recebe próxima indicação, leva nota baixa (4ª avaliação ruim na história dela) | `Svc_Avaliacao` consulta `ContarStrikesPorEmpresa(EMP1, 5.0)` |
| 6. ContarStrikes itera CAD_OS, conta **TODAS** OS_CONCLUIDA com `MEDIA<5.0` | Retorna **4** (3 antigas + 1 nova) |
| 7. `4 >= 3 (MAX_STRIKES)` → suspende novamente por 90 dias | EMP1 re-suspensa **com 1 única nota baixa pós-reativação** |

## 4. Tensão com a Regra V203 §7

[`.hbn/knowledge/0001-regras-v203-inegociaveis.md`](../../.hbn/knowledge/0001-regras-v203-inegociaveis.md) §7:

> *"Empresa não é penalizada duas vezes. Após cumprir suspensão... a
> empresa volta à posição original na fila. **A nota baixa já pune por
> N dias — perder turno seria dupla penalização.**"*

Essa regra fala formalmente sobre **posição na fila**, mas o espírito
é "uma punição por uma falha". O comportamento atual de strikes não
viola **a letra** da regra (a punição na re-suspensão é por NOVA nota
baixa, não pela antiga), mas **viola o espírito** — empresa não
regenera reputação após cumprir 90 dias de suspensão. Qualquer deslize
na primeira indicação re-suspende com base em histórico já punido.

Isso é **dupla penalização efetiva**, mesmo que tecnicamente
defensável.

## 5. Decisão de produto adotada (Opção B do operador, 2026-05-03)

A escolha técnica feita pelo operador é **dupla informação**:

| Conceito | Mecanismo |
|---|---|
| **Strikes total histórico** | `ContarStrikesPorEmpresa(empId, notaMin)` — comportamento atual preservado: lê todas as OS_CONCLUIDA da empresa com `MEDIA<notaMin`. Função inalterada. Auditoria/transparência regulatória continua plena. |
| **Strikes para punição** | `ContarStrikesParaPunicao(empId, notaMin)` — função NOVA. Lê `EMPRESAS.DT_ULT_REATIV` da empresa; itera CAD_OS contando apenas OS com `DT_AVALIACAO > DT_ULT_REATIV` (ou todas se nunca reativada). É essa função que `Svc_Avaliacao` consulta para decidir suspensão. |

A decisão preserva 4 propriedades:

1. **Auditoria intacta** — histórico real da empresa nunca é apagado
2. **Lógica de produto cristalina** — separação clara entre "memória" e "punição vigente"
3. **Backward compatibility** — `ContarStrikesPorEmpresa` mantém semântica
4. **Implementação cirúrgica** — 1 coluna nova + 1 função nova + 1 troca de chamada em Svc_Avaliacao

## 6. Especificação técnica para Onda 18

| Componente | Mudança |
|---|---|
| `EMPRESAS` (schema) | Adicionar coluna `COL_EMP_DT_ULT_REATIV` (tipo `Date`; vazio quando nunca foi reativada) — última posição da tabela |
| `Const_Colunas.bas` | Adicionar `Public Const COL_EMP_DT_ULT_REATIV As Long = <N>` (próxima livre) |
| `Mod_Types.bas` | Adicionar campo `DT_ULT_REATIV As Date` em `TEmpresa` (TABU C4 — apenas Onda 9 originalmente, mas Onda 18 abre exceção via plano dedicado pré-aprovado pelo operador conforme CLAUDE.md tabu C4 "intervenção planejada apenas na Onda 9, fora disso, não tocar" — Onda 18 vira plano dedicado pré-aprovado) |
| `Svc_Rodizio.Reativar()` (linhas 354-394) | Antes do `GravarStatusEmpresa`, gravar `DT_ULT_REATIV = Now` (e `RegistrarEvento` registra esse timestamp na auditoria) |
| `Repo_Avaliacao.ContarStrikesPorEmpresa` (existente, §119) | **Inalterada** — vira função "histórico total" oficial |
| `Repo_Avaliacao.ContarStrikesParaPunicao` (NOVA) | Lê `DT_ULT_REATIV` via `LerEmpresa(empId)`; itera CAD_OS contando apenas OS com `DT_AVALIACAO > DT_ULT_REATIV` (ou todas se `DT_ULT_REATIV` vazia ou ano-1900). Mesma assinatura: `(empId As String, notaMin As Double) As Long` |
| `Svc_Avaliacao` §387 | Trocar `ContarStrikesPorEmpresa` por `ContarStrikesParaPunicao` no bloco de decisão de suspensão |
| Cenário `CS_E2E_REATIV2STRIKES` | Atualizado de `TV2_LogManual` (Onda 17 AMARELO) para `TV2_LogAssert` verde com asserts: `ContarStrikesParaPunicao(EMP1) = 1` E `ContarStrikesPorEmpresa(EMP1) = 4` (histórico preservado) E `STATUS=ATIVA` pós 1 nota baixa pós-reativação |
| `RPT_BUGS_CONHECIDOS` | Mover entrada DT-17-REATIV-STRIKES para `RPT_BUGS_RESOLVIDOS` (nova aba a criar na Onda 18) |
| `auditoria/00_status/27_ROADMAP_REINCORPORACAO_INCREMENTAL_V203.md` | Atualizar §03 (roadmap janela temporal) marcando como entregue |
| `CHANGELOG.md` | Entrada Onda 18: "feature: janela temporal de strikes (DT-17-REATIV-STRIKES resolvido); release público desbloqueado" |
| `App_Release.bas` | Bump `APP_RELEASE_TAG` para `v12.0.0203-rc3` (ou `v12.0.0203` final dependendo da decisão de release) |

### Migração de dados

Empresas existentes ao importar a Onda 18 não têm `DT_ULT_REATIV`
preenchido. Tratamento:

- `DT_ULT_REATIV` vazia ou anterior a `2000-01-01` → comportar como
  "nunca reativada" → `ContarStrikesParaPunicao` lê histórico completo
  (igual a `ContarStrikesPorEmpresa`). Backward compatible.
- Empresas que já estavam ativas no momento da migração mantêm
  comportamento equivalente ao de hoje até a próxima reativação real.

### Impacto em testes

Suítes que assertam comportamento atual de re-suspensão (a maioria
dos `CS_E2E_*`) **continuam verdes** porque elas testam EMPs que nunca
foram reativadas explicitamente — `DT_ULT_REATIV` vazia, comportamento
de janela = histórico completo. **Apenas CS_E2E_REATIV2STRIKES muda**
de TV2_LogManual amarelo para TV2_LogAssert verde (asserts factuais
com janela temporal vigente).

## 7. Plano de teste

### 7.1 Onda 17 (AMARELO — atual)

| Item | Mecanismo |
|---|---|
| Cenário `CS_E2E_REATIV2STRIKES` | `TV2_LogManual` em `TV2_RunRodizioStrikesEndToEnd` (Roteiros) |
| Status no Quarteto | `MANUAL_ASSISTIDO` (gTV2Manual+=1; gTV2Fail inalterado) |
| Sintaxe Quarteto | `V1=171/0+V2_Smoke=14/0+V2_Canonica=23/0+E2E_Strikes=66/0` (ou similar; valor manual exposto separadamente em CSV) |
| Bloqueio de gate | **Não** — Quarteto continua APROVADO |
| Visibilidade do débito | RESULTADO_QA_V2 mostra linha amarela com obs detalhada apontando este documento |

### 7.2 Onda 18 (VERDE — alvo)

| Item | Mecanismo |
|---|---|
| Cenário `CS_E2E_REATIV2STRIKES` | `TV2_LogAssert` em `TV2_RunRodizioStrikesEndToEnd` |
| Status | `OK` |
| Asserts factuais | `ContarStrikesParaPunicao(EMP1) = 1` E `ContarStrikesPorEmpresa(EMP1) = 4` E `STATUS=ATIVA` |
| Bloqueio de gate | Não regrede — gate continua APROVADO |

## 8. Critério de release

| Tag | Estado |
|---|---|
| `v12.0.0203-rc1` | publicada 2026-05-02 (sem CS_E2E_REATIV2STRIKES — débito pré-existente não detectado formalmente) |
| `v12.0.0203-rc2` | a publicar ao fim da Onda 17 — **inclui DT-17-REATIV-STRIKES como débito amarelo declarado** |
| `v12.0.0203-rc3` ou `v12.0.0203` final | só pode sair **após Onda 18** com DT-17-REATIV-STRIKES resolvido (CS_E2E_REATIV2STRIKES verde) |

## 9. Por que isso não trava a Onda 17

1. `TV2_LogManual` registra cenário em `RESULTADO_QA_V2` com status
   `MANUAL_ASSISTIDO` (amarelo).
2. Engine V2 contabiliza isso em `gTV2Manual`, **não em `gTV2Fail`**.
3. Quarteto Mínimo soma `OK` e `FALHA` por suite na sintaxe canônica;
   `MANUAL` aparece à parte sem afetar APROVADO/REPROVADO.
4. `RESULTADO_GERAL` é `APROVADO` se todas as suites tiverem `FALHA=0`
   (ver `VR_StatusGeral` em `Teste_Validacao_Release.bas` §289-297).

Ou seja: o cenário aparece como amarelo legível pelo operador, com
texto explicativo apontando para este documento, sem bloquear gate
operacional.

## 10. Ações imediatas (Onda 17)

1. ✅ Inserir `CS_E2E_REATIV2STRIKES` em `TV2_RunRodizioStrikesEndToEnd`
   via `TV2_LogManual` (feito MD-17.1.b)
2. ✅ Inserir comentário-vacina inline citando este documento (feito
   MD-17.1.b)
3. ⏳ Registrar entrada formal em `RPT_BUGS_CONHECIDOS` (a executar em
   MD-17.2)
4. ✅ Documentar plano de Onda 18 neste arquivo (feito agora)
5. ⏳ Atualizar readback formal `0013` com seção `debitos_declarados`
   (a executar em MD-17.5)
6. ⏳ ERP final da Onda 17 (`.hbn/results/0013-exec-onda17.json`)
   referencia este débito (a executar em MD-17.5)

## 11. Ações Onda 18 (escopo dedicado)

| # | Item | Esforço estimado |
|---|---|---|
| 1 | Plano de mudança em `Mod_Types.bas` (TABU C4 → exceção via plano dedicado pré-aprovado) | 30 min |
| 2 | Adicionar `COL_EMP_DT_ULT_REATIV` em EMPRESAS (schema + constante + migração) | 1h |
| 3 | Modificar `Svc_Rodizio.Reativar()` para gravar `DT_ULT_REATIV` | 30 min |
| 4 | Implementar `Repo_Avaliacao.ContarStrikesParaPunicao` | 1h |
| 5 | Trocar chamada em `Svc_Avaliacao` §387 | 15 min |
| 6 | Atualizar `CS_E2E_REATIV2STRIKES` para `TV2_LogAssert` verde | 30 min |
| 7 | Validação Quarteto/Quinteto verde + cenário virou OK | n/a |
| 8 | Bump rc3 + CHANGELOG + L22 em PHAGOCYTOSIS + ERP + fechamento Onda 18 | 1.5h |
| **Total** | | **~5h IA + ~1.5h Op** |

## 12. Documentos relacionados

- [`auditoria/00_status/26_DIAGNOSTICO_LOOPING_CODEX_E_PROMPT_RETOMADA.md`](26_DIAGNOSTICO_LOOPING_CODEX_E_PROMPT_RETOMADA.md) §06.3 — decisão de produto original
- [`.hbn/knowledge/0001-regras-v203-inegociaveis.md`](../../.hbn/knowledge/0001-regras-v203-inegociaveis.md) §7 — regra V203 sobre não dupla penalização
- [`.hbn/readbacks/0013-onda17-test-first.json`](../../.hbn/readbacks/0013-onda17-test-first.json) — readback Onda 17
- `src/vba/Svc_Avaliacao.bas` §374-379, 380-407 — fluxo atual de strikes
- `src/vba/Svc_Rodizio.bas` §354-394 — Reativar() atual
- `src/vba/Repo_Avaliacao.bas` §119-172 — ContarStrikesPorEmpresa atual
- `src/vba/Teste_V2_Roteiros.bas` (após MD-17.1.b) — CS_E2E_REATIV2STRIKES com TV2_LogManual

## Versão

- v1.0 — 2026-05-03 — registro inicial do débito DT-17-REATIV-STRIKES,
  decisão de produto Opção B, plano de execução para Onda 18.
