---
titulo: Matriz de Rastreabilidade dos Testes V204
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-11
---

# Matriz de Rastreabilidade dos Testes V204

Esta matriz liga regra de negocio, cenario, assert e evidencia. Ela existe
para reduzir ambiguidade antes de criar ou alterar testes e para sustentar o
gate consolidado V204 fechado em `VR_20260511_154433`.

## Contrato de Uso

1. Toda funcionalidade nova deve nascer com pelo menos um teste que valide o
   comportamento novo no mesmo microdelta.
2. Toda mudanca em regra de negocio deve apontar aqui qual cenario cobre a
   regra e qual evidencia comprova a execucao.
3. Toda passagem de microdelta, onda, release ou bastao deve executar higiene
   documental: indice atualizado, evidencias citadas, status HBN coerente e
   ausencia de duplicacao narrativa.
4. Quando uma IA alterar teste, ela deve preservar a ligacao
   `regra -> cenario -> assert -> evidencia`; se a ligacao quebrar, o teste
   perde valor de auditoria.

## Gates Vigentes

| Gate | Comando VBA | Contrato atual | Ultima evidencia |
|---|---|---:|---|
| V1 rapida | `BO_RodarBateriaOficial` | 171/0 | `VR_20260511_154433` |
| V2 Smoke | `TV2_RunSmoke` | 34/0 | `VR_20260511_154433` |
| V2 Canonica | `TV2_RunCanonica` | 24/0 | `VR_20260511_154433` |
| E2E Strikes | `TV2_RunRodizioStrikesEndToEnd` | 76/0 | `VR_20260511_154433` |
| IntegridadeBase | `TV2_RunIntegridadeBase` | 4/0 | `VR_20260511_154433` |
| UI adversarial | `TV2_RunAdversarial_UI False` | 12/0/0 | `VR_20260511_154433` |
| Transacao interrupt | `TV2_RunTransaction_Interrupt False` | 6/0/0 | `TV2_20260507_042944` |
| Boundary dates | `TV2_RunBoundary_Dates False` | 9/0/0 | `TV2_20260509_020108` |

## Matriz Regra -> Cenario -> Assert -> Evidencia

| Regra / risco | Cenario ou assert | Suite | Evidencia | Status |
|---|---|---|---|---|
| Regressao funcional geral nao pode quebrar durante microdeltas | 171 asserts da bateria oficial | V1 rapida | `VR_20260511_154433` | Coberto |
| Smoke deve detectar falha curta e fatal rastreavel | `MIG_*`, `ATM_002`, smoke operacional | V2 Smoke | `VR_20260511_154433` | Coberto |
| Caminho canonico deve preservar fluxo real de negocio | 24 cenarios canonicos V2 | V2 Canonica | `VR_20260511_154433` | Coberto |
| Reativacao nao pode manter strikes punitivos anteriores a `DT_ULT_REATIV` | `CS_E2E_REATIV2STRIKES` e correlatos | E2E Strikes | `VR_20260511_154433` | Coberto |
| Bordas temporais da janela de strikes devem ser explicitas | corte anterior, igual, posterior e futuro | E2E Strikes | `VR_20260507_010423` | Coberto |
| Integridade passiva nao pode aceitar orfas reais ou datas invalidas | `CS_INT_01..05` | IntegridadeBase | `VR_20260511_154433` | Coberto |
| Forms mutadores nao podem permitir reentrada ou bypass de servico | `UI_ADV_001..010` | Adversarial UI | `VR_20260511_154433` | Coberto |
| Acoes destrutivas exigem confirmacao, guarda e limpeza de estado | `UI_ADV_002`, `UI_ADV_003`, `UI_ADV_007`, `UI_ADV_008`, `UI_ADV_009` | Adversarial UI | `TV2_20260507_022218` | Coberto |
| Gate novo precisa nascer testado no mesmo microdelta | `UI_ADV_011_SEXTETO_GATE_EXPOSTO` | Adversarial UI | `VR_20260511_154433` | Coberto |
| Limpar Base deve preservar CNAE e zerar Cadastro de Servico para novo municipio | `MIG_009` | V2 Smoke | `TV2_20260511_131824` e `VR_20260511_154433` | Coberto |
| Transacao deve limpar estado apos commit e rollback | `TX_INT_001`, `TX_INT_002`, `TX_INT_006` | Transacao Interrupt | `TV2_20260507_042944` | Coberto |
| Transacao aninhada nao pode sobrescrever transacao externa | `TX_INT_004`, `TX_INT_005` | Transacao Interrupt | `TV2_20260507_042944` | Coberto |
| Datas de OS vazias usam default controlado, sem erro fatal | `DATE_BND_001_OS_DATA_VAZIA_DEFAULT` | Boundary Dates | `TV2_20260509_020108` | Coberto |
| Data prevista hoje e permitida; ontem e rejeitada | `DATE_BND_002`, `DATE_BND_003` | Boundary Dates | `TV2_20260509_020108` | Coberto |
| Datas impossiveis ou fora de faixa devem ser normalizadas/rejeitadas | `DATE_BND_004`, `DATE_BND_006`, `DATE_BND_007` | Boundary Dates | `TV2_20260509_020108` | Coberto |
| Ano bissexto deve ser tratado explicitamente | `DATE_BND_005`, `DATE_BND_006` | Boundary Dates | `TV2_20260509_020108` | Coberto |
| Data de avaliacao so deve gerar mudanca quando for diferente | `DATE_BND_008`, `DATE_BND_009` | Boundary Dates | `TV2_20260509_020108` | Coberto |

## Cobertura Combinatoria

| Dimensao | Valores cobertos | Lacuna conhecida |
|---|---|---|
| Estado da empresa | ativa, inativa, reativada, suspensa por strikes | UI manual completa ainda fica para Onda 24/25 |
| Tempo | ontem, hoje, futuro, 31/02, bissexto valido/invalido, corte futuro | timezone/locale do Windows ainda e teste manual assistido |
| Transacao | commit, rollback sem write, rollback com write, rollback duplo, aninhamento | interrupcao fisica do Excel ainda nao e automatizada |
| UI destrutiva | confirmacao, guarda de reentrada, exposicao em menu, saneamento | automacao visual externa fica para proposta Onda 26 |
| Integridade | orfas reais, residuos legados, data invalida, status de base | auditoria historica antes da migracao segue como DT controlado |

## Uso no Sexteto

A V204 fecha com o `Sexteto` como nome historico do gate de release. A sexta
dimensao e um bloco adversarial Onda 23 que agrega:

| Bloco | Suites candidatas | Total atual |
|---|---|---:|
| Adversarial Onda 23 | `ADVERSARIAL_UI` + `TRANSACAO_INTERRUPT` + `BOUNDARY_DATES` | 27/0/0 |

Esse bloco nao substitui o Quinteto. Ele adiciona cobertura sobre as tres
familias que nasceram para testar falhas ocultas, reentrada, rollback e
bordas de data.

Sintaxe final aprovada da V204:

`V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`

Debito aceito para V12.0.0205: renomear a taxonomia publica de "Sexteto" para
nomes mais profissionais de engenharia de software, preservando rastreabilidade
historica das evidencias V204.

## Higiene Antes de Nova Onda

Antes de abrir a V12.0.0205, verificar:

1. `CHANGELOG.md` cita todos os microdeltas aprovados.
2. `.hbn/relay/INDEX.md` aponta o proximo passo real, nao um passo ja
   executado.
3. `.hbn/results/INDEX.md` inclui o ERP mais recente.
4. Toda suite nova aparece neste documento e no indice de testes.
5. Evidencias CSV citadas existem ou foram explicitamente marcadas como
   "nao exportadas" pela propria suite.
