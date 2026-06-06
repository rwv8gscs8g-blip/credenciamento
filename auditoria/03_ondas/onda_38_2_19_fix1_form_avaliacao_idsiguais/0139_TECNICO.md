---
titulo: Onda 38.2.19-fix1 - form avaliacao IdsIguais no teste
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-02
---

# Onda 38.2.19-fix1 - form avaliacao IdsIguais no teste

## Contexto

A Onda 38.2.19 importou e compilou, mas `TV2_RunFormAvaliacaoModulos`
executou como `TV2_20260602_125043` e retornou:

`OK=3 | FALHA=2 | MANUAL=0`

O CSV de falhas indicou dois pontos:

- `FAM_03_AV_LISTA_EXIBE_DEMANDANTE`: a lista tinha `LISTCOUNT=1`, mas o
  helper nao encontrou `OS_ID=001`;
- `FAM_05_ENT_ID_INVALIDO_FALHA_AUDITAVEL`: o helper nao encontrou a linha
  para alterar `ENT_ID`, portanto o payload invalido continuou sucesso.

Como `FAM_02_DEMANDANTE_RESOLVIDO_POR_OS` e
`FAM_04_PAYLOAD_FALLBACK_E_PRESERVA_EXPLICITO` passaram, a producao importada
em 0138 resolveu o demandante e montou payload corretamente. A falha ficou no
teste isolado, que comparava `OS_ID` como texto estrito em pontos onde o
sistema usa comparacao canonica por `IdsIguais`.

## Decisao Tecnica

Fix test-only:

- `TV2_FAM_LerDemandanteLista` passa a comparar o `OS_ID` da lista com
  `IdsIguais(osLista, osId)`;
- `TV2_FAM_AlterarEntIdOS` passa a localizar a linha de `CAD_OS` com
  `IdsIguais(SafeListVal(ws.Cells(linha, COL_OS_ID).Value), osId)`;
- `Svc_Avaliacao.bas`, `Preencher.bas`, UserForms e `.frx` permanecem
  intocados.

## Pacote V3

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_19_FIX1_FORM_AVALIACAO_IDSIGUAIS.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_19_FIX1_FORM_AVALIACAO_IDSIGUAIS", "e157221+ONDA38.2.19-FIX1-FORM-IDS"
```

Itens:

- `M|001-modulo/AAX-App_Release.bas`;
- `M|001-modulo/ABQ-Teste_V2_Form_Avaliacao_Modulos.bas`.

Resultado esperado do importador:

`M=2 | F=0 | err=0 | skip=0`

## Gate Humano

Depois do import:

1. VBE > Depurar > Compilar VBAProject.
2. Janela Imediata:

```vb
TV2_RunFormAvaliacaoModulos
```

Resultado esperado:

`OK=5 | FALHA=0 | MANUAL=0`

## Veredito Local

Pacote V3 pronto para gate humano. A onda ainda nao esta validada no workbook:
compile e `TV2_RunFormAvaliacaoModulos` dependem da importacao manual por
Mauricio.

## Resultado Humano

Mauricio reportou em 2026-06-02:

- importacao executada;
- compile limpo no VBE;
- `TV2_RunFormAvaliacaoModulos`: `TV2_20260602_181749` com
  `OK=5 | FALHA=0 | MANUAL=0`;
- CSV de falhas: `NAO_EXPORTADO`.

Veredito: 38.2.19-fix1 validada por V2 dirigido. A falha da 0138 estava no
teste isolado, e a troca para `IdsIguais` corrigiu os dois asserts pendentes
sem tocar producao ou UserForms.

## Gate RVS Completo

Mauricio optou por executar o Gate RVS completo em vez do Trio minimo. O
resultado foi:

- Validacao: `VR_20260602_182253`;
- Build: `e157221+ONDA38.2.19-FIX1-FORM-IDS`;
- Resultado geral: `APROVADO`;
- CSV resumo:
  `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260602_182253.csv`;
- SHA-256:
  `bc5b709ef45e54de085772137bb69456619e21fefb67ad749eb944cf905bb1e1`.

Resumo:

- V1 rapida `BO-20260602-182253`: `OK=171 | FALHA=0 | MANUAL=0`;
- V2 smoke `TV2_20260602_183216`: `OK=34 | FALHA=0 | MANUAL=4`;
- V2 canonico `TV2_20260602_183439`: `OK=24 | FALHA=0 | MANUAL=0`;
- E2E strikes `TV2_20260602_184005`: `OK=76 | FALHA=0 | MANUAL=0`;
- Integridade base `TV2_20260602_184912`: `OK=4 | FALHA=0 | MANUAL=1`;
- Onda23 ADV: `OK=27 | FALHA=0 | MANUAL=0`.

Veredito atualizado: 38.2.19-fix1 validada por V2 dirigido e RVS completo.
Freeze V206 segue nao declarado.
