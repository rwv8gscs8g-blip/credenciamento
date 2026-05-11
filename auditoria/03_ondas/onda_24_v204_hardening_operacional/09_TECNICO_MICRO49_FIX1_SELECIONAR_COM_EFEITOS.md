---
titulo: MICRO49-fix1 — SelecionarEmpresa Com Efeitos Sem Wrapper Publico
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-09
---

# MICRO49-fix1 — SelecionarEmpresa com efeitos sem wrapper publico

> Status: substituido por MICRO49-fix2. O operador confirmou que o build
> fix1 entrou, mas o gate manual de compilacao continuou fechando o Excel e
> o Smoke ficou em `33/0/4`, portanto `SMK_008` nao foi mantido.

## Contexto

A MICRO49 original importou, mas o gate manual `VBE > Depurar > Compilar
VBAProject` fechou o Excel. Ao reabrir, o workbook voltou ao build anterior
`f7aa84f+ONDA24.MD24.3-avaliacao-dual-counter`; o Smoke `33/0/4` e o Sexteto
verde desse ciclo nao validam a MICRO49.

## Decisao

O fix remove o novo wrapper publico `SelecionarEmpresaComEfeitos` e preserva
somente o contrato publico legado `SelecionarEmpresa`.

O objetivo tecnico continua atendido de modo mais conservador:

1. `SelecionarEmpresa` declara no proprio cabecalho que nao e leitura pura.
2. Os efeitos documentados sao `DT_ULTIMA_IND`, reativacao automatica por prazo
   vencido e skip tecnico por OS aberta.
3. O Smoke ganha `SMK_008` para validar `DT_ULTIMA_IND` e preservacao da fila.
4. Nenhum novo membro publico retornando UDT e introduzido.

## Arquivos

| Arquivo | Alteracao |
|---|---|
| `src/vba/Svc_Rodizio.bas` | Remove wrapper novo e documenta efeitos em `SelecionarEmpresa`. |
| `src/vba/Teste_V2_Roteiros.bas` | `SMK_008` usa apenas `SelecionarEmpresa`. |
| `src/vba/Teste_V2_Engine.bas` | Catalogo/roteiro passam a descrever contrato legado explicito. |
| `src/vba/App_Release.bas` | Build `f7aa84f+ONDA24.MD24.4-selecionar-com-efeitos-fix1`. |

## Gate esperado

| Gate | Esperado |
|---|---|
| Importador V3 | `M=4 | F=0 | err=0 | skip=0` |
| Compilacao | limpa, sem fechamento do Excel |
| `TV2_RunSmoke False` | `OK=34 | FALHA=0 | MANUAL=4` |
| Sexteto | `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` |
