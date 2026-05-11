---
titulo: Onda 24 MICRO49 - SelecionarEmpresa Com Efeitos
diataxis: onda
hbn-track: safe_track
hbn-status: archived
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-09
---

# Onda 24 MICRO49 - SelecionarEmpresa Com Efeitos

> Status: substituido por MICRO49-fix1. O operador reportou fechamento do
> Excel no gate manual de compilacao da MICRO49 original; ver
> `09_TECNICO_MICRO49_FIX1_SELECIONAR_COM_EFEITOS.md`.

## Objetivo

Remover ambiguidade operacional de `SelecionarEmpresa`: a rotina parecia uma
leitura neutra, mas pode produzir efeitos controlados no rodizio. O MICRO49
mantem a API antiga como alias e introduz `SelecionarEmpresaComEfeitos` como
nome explicito.

## Estado de Entrada

| Gate | Evidencia | Resultado |
|---|---|---:|
| `TV2_RunRodizioStrikesEndToEnd False` | `TV2_20260509_172616` | `76/0/0` |
| Sexteto | `VR_20260509_173629` | `V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` |
| Build de entrada | `f7aa84f+ONDA24.MD24.3-avaliacao-dual-counter` | aprovado pelo operador |

## Entregas

| Arquivo | Papel |
|---|---|
| `src/vba/Svc_Rodizio.bas` | adiciona `SelecionarEmpresaComEfeitos` e preserva `SelecionarEmpresa` como alias |
| `src/vba/Teste_V2_Roteiros.bas` | adiciona `SMK_008` no Smoke |
| `src/vba/Teste_V2_Engine.bas` | adiciona helper de leitura de `DT_ULTIMA_IND`, catalogo e roteiro |
| `src/vba/App_Release.bas` | bump para `f7aa84f+ONDA24.MD24.4-selecionar-com-efeitos` |
| `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO49.txt` | manifesto importavel do microdelta |

## Efeitos Explicitados

| Efeito | Origem | Contrato |
|---|---|---|
| Atualizar `DT_ULTIMA_IND` | empresa apta selecionada | marca a indicacao sem mover a fila |
| Reativar empresa | empresa suspensa com `DT_FIM_SUSP <= Date` | chama `Reativar` e relê empresa |
| Mover empresa ao fim | empresa com OS aberta na atividade | skip tecnico sem punicao |

## Contrato de Teste

`TV2_RunSmoke False` sobe de 33 para 34 asserts:

| Cenario | Objetivo |
|---|---|
| `SMK_008` | validar que `SelecionarEmpresaComEfeitos` seleciona `EMP_ID=001`, atualiza `DT_ULTIMA_IND`, preserva fila `001,002,003` e que o alias legado `SelecionarEmpresa` continua funcional |

O Sexteto passa a esperar:

`V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`

## Riscos Residuais

| Risco | Mitigacao |
|---|---|
| Quebra de chamadas existentes | `SelecionarEmpresa` segue publico e delega para o novo nome |
| Novo nome virar API paralela sem cobertura | `SMK_008` chama explicitamente o wrapper novo e o alias legado |
| Confusao sobre avanço definitivo da fila | Comentario reforca que aceite/recusa/expiracao continuam em `Svc_PreOS` via `AvancarFila` |

## Validacao Local

1. `src/vba` sincronizado para `local-ai/vba_import` via `publicar_vba_import_v2.py apply`.
2. `publicar_vba_import_v2.py check` verde para todos os arquivos importaveis.
3. `shasum` pareado validado para os 4 arquivos importaveis.
4. Manifesto MICRO49 criado com `M=4 | F=0`.

## Validacao Esperada no Workbook

1. Importador V3: `M=4 | F=0 | err=0 | skip=0`.
2. Compilacao manual limpa no VBE.
3. `TV2_RunSmoke False` retorna `OK=34 | FALHA=0 | MANUAL=4`.
4. `CT_ValidarRelease_SextetoMinimo` retorna `APROVADO`.
