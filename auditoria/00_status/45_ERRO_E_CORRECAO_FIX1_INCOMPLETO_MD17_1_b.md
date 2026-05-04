---
titulo: 45 — Erro fix1 incompleto MD-17.1.b (vitrine de transparência 2026-05-03)
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1
---

# 45. Erro fix1 incompleto MD-17.1.b — vitrine de transparência

> Este documento existe pelos mesmos motivos de
> [`32_ERRO_E_CORRECAO_PASTA_CANONICA.md`](32_ERRO_E_CORRECAO_PASTA_CANONICA.md)
> e [`43c_LICAO_FONTE_DE_VERDADE_VS_ESPELHO.md`](43c_LICAO_FONTE_DE_VERDADE_VS_ESPELHO.md):
> registrar honestamente erros operacionais da IA executora para que
> outras IAs não repitam, a comunidade compreenda o raciocínio e o
> protocolo HBN evolua a partir de evidência empírica. **Operador
> exigiu este registro explicitamente em 2026-05-03 03:30 BRT.**

## TL;DR

Durante o fix do Quarteto reprovado em VR_20260503_020405 (MD-17.1.b),
a IA executora (Claude Opus 4.7 Cowork) ofereceu duas opções de
rollback ao operador:

- **Opção A** (mais limpa, recomendada): restaurar workbook salvo após MD-17.1.a
- **Opção B** (rápida): sobrescrever sobre o estado MD-17.1.b importado

O **manifesto fix1** que a IA preparou continha apenas **Engine + App_Release**,
porque foi planejado assumindo Opção B (Roteiros já estaria importado).
**Operador escolheu Opção A** (a recomendação explícita da IA). Resultado:
o workbook restaurado para MD-17.1.a tinha Roteiros antigo (sem cenários
novos) + fix1 só importou Engine. **Quarteto verde mas incompleto** — os
5 cenários novos da MD-17.1.b não foram executados.

Foi necessário um segundo round (fix2) que re-importou o Roteiros com
os cenários. O Quarteto correto (`V1=171/0+V2_Smoke=14/0+V2_Canonica=23/0+E2E_Strikes=65/0`)
só passou em VR_20260503_031425.

**Custo real para o operador**:

- ~30 minutos de trabalho na madrugada (2:50 — 3:30 BRT)
- 2 sequências completas de import + Quarteto (2× ~14m41s + análise)
- Tokens desperdiçados nos rounds extra
- Distração do escopo principal da Onda 17

## Cronologia detalhada

### Etapa 1 — Quarteto MD-17.1.b reprovado (2026-05-03 02:04)

VR_20260503_020405: `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/3+E2E_Strikes=64/1`.
4 cenários falharam por causa de bug no Engine fix1 (ATIV_ID alfanumérico
incompatível com `TV2_Pad3` interno do `TV2_CredenciarAtividade`). Diagnóstico
correto: Quarteto reprovado pela falha do helper `TV2_FixtureFactory`,
não pelo Roteiros. Plano de fix1 correto: corrigir Engine.

### Etapa 2 — IA propõe duas opções de rollback

A IA propôs:

> **Opção A (mais limpa, recomendada)**: fechar Excel sem salvar, reabrir
> o workbook salvo após MD-17.1.a, importar fix1.
>
> **Opção B (rápida)**: rodar `ImportarPacoteV3_Delta` direto sobre o
> estado atual (com Roteiros MD-17.1.b já importado), aceitar lixo
> residual em ATIVIDADES.

A recomendação explícita foi A. Justificativa: "garante validação 100%
limpa; em B fica difícil distinguir 'bug de fix1' de 'interferência do
lixo residual' caso o Quarteto reprove novamente".

### Etapa 3 — Manifesto fix1 incompleto (erro raiz)

A IA preparou o `MICRO17-fix1` com apenas 2 arquivos:
`ABF-Teste_V2_Engine.bas` (correção do bug) + `AAX-App_Release.bas` (bump label).
**Não incluiu** `ABG-Teste_V2_Roteiros.bas` (que tinha os 5 cenários novos
da MD-17.1.b) porque assumiu — mentalmente, sem validar — que o operador
escolheria Opção B (com Roteiros já importado no workbook).

Esse pressuposto foi feito **depois** de a IA ter recomendado Opção A.
A IA não fez a verificação obrigatória: "Se operador seguir minha recomendação
(Opção A), o pacote fix1 cobre tudo o que ele precisa? Não. Falta o Roteiros."

### Etapa 4 — Operador segue a recomendação da IA (Opção A)

Operador fez exatamente o que a IA recomendou: restaurou workbook MD-17.1.a,
importou MICRO17-fix1, compilou, rodou Quarteto. VR_20260503_025114 verde
**mas com sintaxe `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0`**
— os números pré-MD-17.1.b. Os 5 cenários novos não rodaram.

### Etapa 5 — IA reconhece o erro

Operador colou print do Quarteto APROVADO mas pediu validação. IA percebeu
o gap: V2_Canonica deveria ser 23/0, E2E_Strikes deveria ser 66/0. Causa
raiz isolada: manifesto fix1 não incluía Roteiros.

IA gerou MICRO17-fix2 contendo `ABG-Teste_V2_Roteiros.bas` + bump de label.
Operador importou, recompilou, rodou Quarteto novamente. VR_20260503_031425
APROVADO com `V1=171/0+V2_Smoke=14/0+V2_Canonica=23/0+E2E_Strikes=65/0`
e MANUAL=1 em E2E_Strikes (CS_E2E_REATIV2STRIKES AMARELO funcionando).

### Etapa 6 — Operador exige registro do erro

Operador (citação literal):

> *"documente o erro porque você me recomendou a opção A para fazer uma
> passagem limpa e eu segui a recomendação. e vc não colocou o código da
> sua recomendaçao. Isso tem de ser documentado como um erro para
> corrigirmos no protocolo de gestao das ias."*

Este documento atende essa exigência.

## Causa raiz — análise honesta

A IA cometeu **duas falhas distintas em sequência** no mesmo plano:

| # | Falha | Onde aconteceu |
|---|---|---|
| **F1** | **Falha de revisão de coerência interna do plano**: o pacote fix1 foi montado mentalmente assumindo um caminho de execução (Opção B), mas a recomendação textual da IA foi pelo outro caminho (Opção A). A IA não fez sweep "se operador seguir minha recomendação, o pacote ainda cobre tudo?" | Geração do manifesto fix1 |
| **F2** | **Falha de cobertura de variantes operacionais**: ao oferecer "duas opções de rollback", o pacote do fix deveria ser **válido para ambas as opções**, não para uma. V3 sobrescreve módulos idempotentemente; incluir Roteiros no fix1 não teria custo na Opção B (V3 só substitui o que mudou) e teria evitado completamente o problema na Opção A | Estrutura do plano (não código) |

A combinação de F1 + F2 produziu o resultado pior possível: operador
seguiu a recomendação, mas o pacote da própria IA não estava preparado
para a recomendação dela mesma.

## Custo do erro

| Item | Custo |
|---|---|
| Tempo extra do operador na madrugada | ~30 min (2:50 — 3:30 BRT) |
| Rounds extras de import + compile + Quarteto | 2 sequências completas (~14m41s cada apenas para o Quarteto) |
| Análise de diagnóstico extra (operador colando prints, IA respondendo) | 3-4 ciclos de hearback |
| Tokens consumidos | (não medido pela IA, mas o operador notou explicitamente que houve desperdício) |
| Distração do escopo principal | Pause na execução de MD-17.1.c+ |

**Custo único e absoluto, registrado, não diluído.**

## Mitigação obrigatória para sprints futuras (M14 oficial)

A meta-lição derivada deste erro é registrada como **M14** em
[`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`](../../usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md):

### M14 — Plano de fix em onda multi-microdelta deve cobrir todas as opções de rollback

**Anti-padrão.** Quando uma IA executora oferece N opções de rollback ao
operador (ex: "Opção A: voltar ao microdelta N-2; Opção B: manter no
microdelta N-1"), montar o pacote do fix considerando apenas UMA das
opções gera incompletude operacional. Operador segue a recomendação,
pacote não cobre o caminho recomendado, fix falha silenciosamente
(Quarteto verde mas incompleto).

**Padrão.** Pacote do fix em onda multi-microdelta DEVE incluir todos
os arquivos modificados desde o último checkpoint estável anterior ao
microdelta com falha — mesmo que algumas dessas modificações já estejam
no estado atual em algumas opções de rollback. V3 sobrescreve idempotente
(F=0, err=0); o custo de incluir um arquivo que já está importado é
zero, mas o custo de NÃO incluir um arquivo que precisava ser importado
é um round inteiro extra de validação.

**Verificação obrigatória antes de propor opções de rollback ao operador.**

```
PRE-FLIGHT M14 (checklist mental antes de gerar manifesto de fix):

1. Liste todos os arquivos modificados desde o último checkpoint estável
   anterior ao microdelta com falha:
   git diff <checkpoint>..HEAD -- src/vba/ local-ai/vba_import/
   
2. Para cada opção de rollback que voce vai oferecer:
   - Em qual estado o workbook ficará após o rollback?
   - Quais dos arquivos da lista NÃO estão refletidos nesse estado?
   - Esses arquivos PRECISAM estar no manifesto do fix.

3. União dos arquivos a importar = união entre todas as opções de rollback.
   Manifesto do fix DEVE conter essa união.

4. Se a opção recomendada gera lista mais ampla de imports do que a
   alternativa, OK — V3 idempotente sobrescreve; o custo é zero, o
   beneficio é cobertura.
```

**Validação que prova M14 aplicada.** No final da execução do fix:

- Sintaxe do Quarteto bate com a esperada **exata** (não apenas
  RESULTADO_GERAL=APROVADO)
- Cada cenário novo introduzido nas microdeltas anteriores aparece
  com o status esperado em RESULTADO_QA_V2

## Atualização do protocolo de gestão de IAs

Como consequência deste erro, o protocolo HBN é **atualizado**:

### Adição em `.hbn/knowledge/0001-regras-v203-inegociaveis.md`

Será proposta a regra **G6 (estendido)** ou nova **G11**: "Pacote de fix
em onda multi-microdelta cobre todos os arquivos modificados desde o
último checkpoint estável." Esta proposição segue o protocolo de
mudança de regras V203 (release oficial com migration plan documentado).

### Marker HBN V2 adicional

Candidato a marker novo: `🟠 HBN ROLLBACK PLAN INCOMPLETE` — IA detecta
durante geração de plano de rollback que o pacote do fix não cobre
todas as opções oferecidas. Análogo a `🟠 HBN SOURCE DRIFT DETECTED`
mas para inconsistência interna do plano. A ser proposto formalmente
no addendum semanal de `0005-protocolo-markers-v2.md`.

### Lição operacional para próximas Ondas

Antes de fechar qualquer microdelta de fix em onda multi-microdelta:

1. Verificar M14 (checklist acima)
2. Verificar coerência texto da recomendação ↔ conteúdo do pacote
3. Se houver dúvida, pedir hearback do operador antes de gerar manifesto

## Para IAs futuras lendo este documento

Se você está lendo este documento porque assumiu o bastão da Onda 17 ou
posterior, ou está montando um plano de fix em qualquer onda multi-microdelta:

1. **A recomendação textual e o pacote técnico devem ser COERENTES**.
   Se você recomenda Opção A textualmente, o pacote técnico deve estar
   pronto para Opção A.

2. **Em onda multi-microdelta, o pacote de fix sempre cobre o conjunto
   maior de arquivos modificados** desde o último checkpoint estável.
   Não otimize para "uma das opções". Cubra todas.

3. **Operador na madrugada, seguindo recomendação da IA, depende da IA
   ter feito o trabalho corretamente**. Cada round extra é tempo de
   sono perdido + frustração + tokens desperdiçados. O custo é
   absoluto.

4. **Antes de propor opções, faça o pre-flight M14**.

5. **Documentar erros honestamente é obrigação, não cortesia**. O HBN
   se constrói sobre transparência radical de cada falha.

## Documentos relacionados

- [`auditoria/00_status/32_ERRO_E_CORRECAO_PASTA_CANONICA.md`](32_ERRO_E_CORRECAO_PASTA_CANONICA.md) — primeiro erro arquitetural documentado
- [`auditoria/00_status/43c_LICAO_FONTE_DE_VERDADE_VS_ESPELHO.md`](43c_LICAO_FONTE_DE_VERDADE_VS_ESPELHO.md) — segundo erro (M11)
- [`auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md`](44_DEBITO_DT_17_REATIV_STRIKES.md) — débito declarado (não erro de IA, decisão de produto consciente)
- [`auditoria/03_ondas/onda_17_test_first/03_PROCEDIMENTO_IMPORT_MD17_1_b_fix1.md`](../03_ondas/onda_17_test_first/03_PROCEDIMENTO_IMPORT_MD17_1_b_fix1.md) — procedimento fix1 (incompleto)
- [`auditoria/03_ondas/onda_17_test_first/04_PROCEDIMENTO_IMPORT_MD17_1_b_fix2.md`](../03_ondas/onda_17_test_first/04_PROCEDIMENTO_IMPORT_MD17_1_b_fix2.md) — procedimento fix2 (correção do erro)

## Versão

- v1.0 — 2026-05-03 — registro inicial.
