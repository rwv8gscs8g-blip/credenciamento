---
titulo: Onda 24 MICRO46 - Limpar Base Seguro
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-09
---

# Onda 24 MICRO46 - Limpar Base Seguro

## Objetivo

Reduzir risco operacional no fluxo mais destrutivo do workbook (`Limpar_Base`)
sem alterar o contrato humano da limpeza: a acao continua exigindo senha,
confirmacao e delegacao para o reset centralizado.

## Estado de Entrada

| Gate | Evidencia | Resultado |
|---|---|---:|
| Sexteto | `VR_20260509_025323` | `V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0+Onda23Adv=26/0` |
| `ADVERSARIAL_UI` | `TV2_20260509_025210` | `11/0/0` antes do MICRO46 |

## Entregas

| Arquivo | Papel |
|---|---|
| `src/vba/Limpar_Base.frm` | mascara campo de senha, delega validacao e audita tentativa |
| `src/vba/Mod_Limpeza_Base.bas` | centraliza validacao sem token sensivel literal e registra tentativa |
| `src/vba/Teste_V2_Roteiros.bas` | adiciona `UI_ADV_012_LIMPAR_BASE_SEM_SENHA_CLARA` |
| `src/vba/Teste_V2_Engine.bas` | registra catalogo e roteiro V2 do novo assert |
| `src/vba/Teste_Validacao_Release.bas` | remove literal sensivel remanescente do preparo da planilha de validacao |
| `src/vba/App_Release.bas` | bump para `f7aa84f+ONDA24.MD24.1-limpar-base-seguro` |
| `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO46.txt` | manifesto importavel do microdelta |

## Decisoes

1. A senha deixa de aparecer como literal em claro no form.
2. A validacao fica em helper centralizado, preservando a semantica atual.
3. O campo visual de senha passa a usar mascara no `UserForm_Initialize`.
4. Tentativas negadas e autorizadas geram trilha auditavel via `AUDIT_LOG`.
5. A funcionalidade nova tem teste no mesmo microdelta, conforme regra HBN
   0010: `UI_ADV_012`.

## Contrato de Teste

`TV2_RunAdversarial_UI False` sobe de 11 para 12 asserts:

| Cenario | Objetivo |
|---|---|
| `UI_ADV_012_LIMPAR_BASE_SEM_SENHA_CLARA` | validar ausencia de token sensivel literal em `Limpar_Base.frm` |

O Sexteto passa a esperar:

`V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0+Onda23Adv=27/0`

## Riscos Residuais

| Risco | Mitigacao |
|---|---|
| A senha ainda existe no codigo, embora nao literal | Tratada como debito residual para politica externa de segredo/config em V204 final |
| Auditoria usa evento generico de transacao | Detalhe inclui `LIMPAR_BASE`, resultado e origem suficiente para rastrear tentativa |
| Mudanca em form pode falhar no importador V3 | Manifesto usa item `F|` para importar form completo; rollback e fechar sem salvar se compile falhar |

## Validacao Local

1. `src/vba` sincronizado para `local-ai/vba_import` via `publicar_vba_import_v2.py apply`.
2. `publicar_vba_import_v2.py check` esperado verde.
3. `shasum` pareado validado para os 6 arquivos importaveis.
4. Busca por token sensivel literal em `src/vba` e espelho esperada sem resultado.

## Validacao Esperada no Workbook

1. Importador V3: `M=5 | F=1 | err=0 | skip=0`.
2. Compilacao manual limpa no VBE.
3. `TV2_RunAdversarial_UI False` retorna `OK=12 | FALHA=0 | MANUAL=0`.
4. `CT_ValidarRelease_SextetoMinimo` retorna `APROVADO`.

## Validacao Operador

| Gate | Evidencia | Resultado |
|---|---|---:|
| `TV2_RunAdversarial_UI False` | `TV2_20260509_141117` | `12/0/0` |
| Sexteto | `VR_20260509_141235` | `V1=171/0+V2_Smoke=32/0+V2_Canonica=24/0+E2E_Strikes=75/0+IntegridadeBase=4/0+Onda23Adv=27/0` |
