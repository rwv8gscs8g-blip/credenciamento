---
titulo: Onda 23 MICRO45 - Gate Sexteto Minimo
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-09
---

# Onda 23 MICRO45 - Gate Sexteto Minimo

## Objetivo

Transformar o bloco adversarial da Onda 23 em sexta dimensao formal do gate
de release V204-dev, sem remover o Quinteto de compatibilidade.

## Estado de Entrada

| Suite | Evidencia | Resultado |
|---|---|---:|
| Quinteto | `VR_20260507_083959` | `V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0` |
| `ADVERSARIAL_UI` | `TV2_20260507_022218` | `10/0/0` antes do MICRO45 |
| `TRANSACAO_INTERRUPT` | `TV2_20260507_042944` | `6/0/0` |
| `BOUNDARY_DATES` | `TV2_20260509_020108` | `9/0/0` |

## Entregas

| Arquivo | Papel |
|---|---|
| `src/vba/Teste_Validacao_Release.bas` | adiciona `CT_ValidarRelease_SextetoMinimo` e wrapper `VR_ValidarReleaseSextetoMinimo` |
| `src/vba/Teste_V2_Roteiros.bas` | adiciona `UI_ADV_011_SEXTETO_GATE_EXPOSTO` e eleva `ADVERSARIAL_UI` para 11 asserts |
| `src/vba/Teste_V2_Engine.bas` | registra o novo cenario no catalogo/roteiro V2 |
| `src/vba/Central_Testes_V2.bas` | torna o Sexteto a opcao [1] oficial e preserva Quinteto/Quarteto/Trio |
| `src/vba/App_Release.bas` | bump para `f7aa84f+ONDA23.MD23.5-sexteto-gate` |
| `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO45.txt` | manifesto importavel do microdelta |

## Contrato do Sexteto

O Sexteto executa, nesta ordem:

1. `RunBateriaOficial True`
2. `TV2_RunSmoke False, True`
3. `TV2_RunCanonicoFundacao False, True`
4. `TV2_RunRodizioStrikesEndToEnd False, True`
5. `TV2_RunIntegridadeBase False, True`
6. Bloco `V2_ONDA23_ADV`, composto por:
   `TV2_RunAdversarial_UI False, True`,
   `TV2_RunTransaction_Interrupt False, True` e
   `TV2_RunBoundary_Dates False, True`.

Sintaxe esperada:

`V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0+Onda23Adv=26/0`

## Decisoes

1. O Quinteto permanece publico e executavel para comparabilidade historica.
2. O Sexteto passa a ser a primeira opcao da Central V2 e o gate oficial
   V204-dev.
3. A propria funcionalidade nova tem teste dedicado: `UI_ADV_011`.
4. O bloco adversarial e agregado em uma linha unica `V2_ONDA23_ADV` no
   relatorio de release para manter leitura operacional simples.

## Riscos Residuais

| Risco | Mitigacao |
|---|---|
| Tempo maior de gate | Sexteto roda somente como gate formal; suites parciais seguem disponiveis |
| Falha em qualquer suite adversarial esconder origem | `execIds` concatena `SUITE:EXECUCAO_ID` e primeira falha preserva a suite de origem |
| Drift documental de contagem | Matriz V204 e indice foram atualizados para `ADVERSARIAL_UI=11/0/0` e `Onda23Adv=26/0` |

## Validacao Esperada

1. Importador V3: `M=5 | F=0 | err=0 | skip=0`.
2. Compilacao manual limpa no VBE.
3. `TV2_RunAdversarial_UI False` retorna `OK=11 | FALHA=0 | MANUAL=0`.
4. `CT_ValidarRelease_SextetoMinimo` retorna `APROVADO`.
