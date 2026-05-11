---
titulo: Onda 24 MICRO47 - Configuracao Invalida Auditavel
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-09
---

# Onda 24 MICRO47 - Configuracao Invalida Auditavel

## Objetivo

Fechar a lacuna de configuracao invalida silenciosa: valores fora da faixa
na regra de strikes nao podem ser ignorados, parcialmente gravados ou ficar
sem trilha no `AUDIT_LOG`.

## Estado de Entrada

| Gate | Evidencia | Resultado |
|---|---|---:|
| `ADVERSARIAL_UI` | `TV2_20260509_141117` | `12/0/0` |
| Sexteto | `VR_20260509_141235` | `V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0+Onda23Adv=27/0` |
| Build de entrada | `f7aa84f+ONDA24.MD24.1-limpar-base-seguro` | aprovado pelo operador |

## Entregas

| Arquivo | Papel |
|---|---|
| `src/vba/Configuracao_Inicial.frm` | bloqueia gravacao quando a regra de strikes e invalida |
| `src/vba/Util_Config.bas` | centraliza validacao e auditoria `CONFIG_INVALIDA` |
| `src/vba/Teste_V2_Roteiros.bas` | adiciona `MIG_008` ao Smoke |
| `src/vba/Teste_V2_Engine.bas` | registra catalogo e roteiro V2 do novo assert |
| `src/vba/App_Release.bas` | bump para `f7aa84f+ONDA24.MD24.2-config-invalida-audit` |
| `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO47.txt` | manifesto importavel do microdelta |

## Decisoes

1. Campo vazio continua preservando o valor atual, como no legado.
2. Valor preenchido e invalido bloqueia toda a gravacao do form.
3. A mensagem cita os campos invalidos: `TxtNotaCorte`, `TxtMaxStrikes`,
   `TxtDiasSuspensao`.
4. A rejeicao tenta registrar `EVT_VALIDACAO_REJEITADA` com marcador
   `CONFIG_INVALIDA`.
5. A funcionalidade nova tem teste no mesmo microdelta: `MIG_008`.

## Contrato de Teste

`TV2_RunSmoke False` sobe de 32 para 33 asserts:

| Cenario | Objetivo |
|---|---|
| `MIG_008` | validar rejeicao de configuracao invalida, mensagem clara e auditoria `CONFIG_INVALIDA` |

O Sexteto passa a esperar:

`V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0+Onda23Adv=27/0`

## Riscos Residuais

| Risco | Mitigacao |
|---|---|
| O teste valida o helper e a auditoria, nao clica o form | O form usa diretamente o helper testado antes de qualquer write |
| Falha de auditoria no caminho humano | Mensagem informa que a falha de auditoria ocorreu e bloqueia a gravacao |
| Locale numerico Windows/Excel | Usa conversao VBA nativa (`CDbl`) apos `IsNumeric`, coerente com o ambiente do workbook |

## Validacao Local

1. `src/vba` sincronizado para `local-ai/vba_import` via `publicar_vba_import_v2.py apply`.
2. `publicar_vba_import_v2.py check` verde para 53 arquivos.
3. `shasum` pareado validado para os 5 arquivos importaveis.
4. Manifesto MICRO47 criado com `M=4 | F=1`.

## Validacao Esperada no Workbook

1. Importador V3: `M=4 | F=1 | err=0 | skip=0`.
2. Compilacao manual limpa no VBE.
3. `TV2_RunSmoke False` retorna `OK=33 | FALHA=0 | MANUAL=4`.
4. `CT_ValidarRelease_SextetoMinimo` retorna `APROVADO`.
