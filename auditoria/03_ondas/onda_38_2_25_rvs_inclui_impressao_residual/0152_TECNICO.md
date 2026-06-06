---
titulo: Onda 38.2.25 - RVS inclui impressao residual
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-06
---

# Onda 38.2.25 - RVS inclui impressao residual

## Escopo

Antes de iniciar a atuacao tela a tela, esta onda incorpora a suite dirigida
`TV2_RunImpressaoResidual` ao gate oficial de Validacao de Release (RVS).

A superficie publica permanece `CT_ValidarRelease_SextetoMinimo`, que e a
macro chamada pela Central de Testes para o RVS. A mudanca evita criar um
teste avulso esquecido fora do gate geral.

Nao foram alterados UserForms, `.frx`, `Auto_Open.bas`, `ThisWorkbook`,
`Mod_Types.bas`, `Importador_V3.bas`, `Teste_V2_Engine.bas`,
`Teste_V2_Roteiros.bas` nem `Teste_V2_Impressao_Residual.bas`.

## Mudancas tecnicas

- `Teste_Validacao_Release.bas` passa a executar
  `TV2_RunImpressaoResidual False, True` apos o bloco `V2_ONDA23_ADV`.
- A nova etapa e registrada como `V2_IMPRESSAO_RESIDUAL` na aba
  `VALIDACAO_RELEASE`.
- `VR_StatusGeralSexteto` passa a avaliar as linhas 7 a 13.
- `VR_SintaxeSexteto` passa a incluir
  `+ImpressaoResidual=<OK>/<FALHA>`.
- O bloco copiavel para IA e o CSV `ValidacaoReleaseRVS_V12_0_0205_*`
  passam a conter a linha de impressao residual.
- `App_Release.bas` carimba o build importavel como
  `e157221+ONDA38.2.25-RVS-IMP-RES`.

## Manifesto V3

Arquivo:
`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_25_RVS_IMPRESSAO_RESIDUAL.txt`.

Comando operacional:

```vb
ImportarPacoteV3_Delta "ONDA38_2_25_RVS_IMPRESSAO_RESIDUAL", "e157221+ONDA38.2.25-RVS-IMP-RES"
```

Itens:

- `M|001-modulo/ABH-Teste_Validacao_Release.bas`
- `M|001-modulo/AAX-App_Release.bas`

Prerequisito operacional: GATE 2/0151 ja importado e validado no workbook alvo,
pois o RVS ampliado chama `TV2_RunImpressaoResidual`.

## Gate humano pendente

Apos import e compile limpo, executar na Janela Imediata:

```vb
CT_ValidarRelease_SextetoMinimo
```

Resultado esperado: `Gate RVS` aprovado com sintaxe contendo:

```text
ImpressaoResidual=7/0
```

Referencia de contadores esperada, com base no ultimo RVS completo verde e na
suite validada no GATE 2:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0+ImpressaoResidual=7/0
```

Se o RVS falhar, nao iniciar a atuacao tela a tela. Anexar o CSV gerado pelo
RVS e abrir novo readback corretivo para a primeira falha.

## Validacoes locais

- Readback 0152 validado contra schema por
  `bash scripts/hbn-guards/validate-readback.sh`.
- `python3 local-ai/scripts/publicar_vba_import_v2.py check --verbose`
  retornou `OK — vba_import 100% sincronizado com src/vba`.
- `git diff --check` retornou limpo.

Veredito local: pacote pronto para importacao humana. Validacao final depende
do import, compile e RVS completo no Excel.
