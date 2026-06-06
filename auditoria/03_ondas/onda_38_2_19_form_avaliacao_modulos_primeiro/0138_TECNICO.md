---
titulo: Onda 38.2.19 - formulario avaliacao modulos primeiro
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-02
---

# Onda 38.2.19 - formulario avaliacao modulos primeiro

## Contexto

A Onda 38.2.17 tentou corrigir o formulario de avaliacao importando tambem
`Menu_Principal.frm`, mas o gate humano travou/fechou o Excel durante o compile.
Depois disso, a Onda 38.2.18-fix1 recuperou a confianca do workbook: Mauricio
validou `TV2_RunBO330Diagnostico` e o Trio minimo `VR_20260602_112011`
APROVADO.

A decisao desta onda e retomar formularios por uma fatia conservadora:
importar somente modulos. O `Menu_Principal.frm` existente no workbook ja usa
`AVListaCol(1)` em `EncerraOS_Click`; portanto, se `PreencherAvaliarOS`
popular `AV_Lista` coluna 1 a partir de `OS_ID -> CAD_OS.ENT_ID ->
ENTIDADE.NOME`, o demandante passa a chegar ao fluxo existente sem reimportar
UserForm grande.

## Decisao Tecnica

O pacote resolve a base funcional sem tocar no designer:

- `Svc_Avaliacao.ResolverDemandanteAvaliacaoPorOS` resolve o demandante por
  `OS_ID`, `CAD_OS.ENT_ID` e `ENTIDADE.NOME`.
- `PreencherAvaliarOS` usa esse resolver para preencher `AV_Lista` coluna 1.
- `MontarPayloadAvaliacao` tenta o mesmo resolver quando o avaliador recebido
  esta vazio, mas preserva o avaliador explicito quando ele ja vem preenchido.
- `Teste_V2_Form_Avaliacao_Modulos.bas` cria uma suite isolada, sem alterar
  `Teste_V2_Engine.bas` nem `Teste_V2_Roteiros.bas`.

Nao foram importados `Menu_Principal.frm`, `.frx`, `ThisWorkbook`,
`Auto_Open.bas`, `Mod_Types.bas`, `Importador_V3.bas` ou formularios.

## Pacote V3

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_19_FORM_AVALIACAO_MODULOS_PRIMEIRO.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_19_FORM_AVALIACAO_MODULOS_PRIMEIRO", "e157221+ONDA38.2.19-FORM-AVAL-MODULOS"
```

Itens:

- `M|001-modulo/AAX-App_Release.bas`;
- `M|001-modulo/AAS-Svc_Avaliacao.bas`;
- `M|001-modulo/AAU-Preencher.bas`;
- `M|001-modulo/ABQ-Teste_V2_Form_Avaliacao_Modulos.bas`.

Resultado esperado do importador:

`M=4 | F=0 | err=0 | skip=0`

## Gate Humano

Depois do import:

1. VBE > Depurar > Compilar VBAProject.
2. Janela Imediata:

```vb
TV2_RunFormAvaliacaoModulos
```

Resultado esperado:

`OK=5 | FALHA=0 | MANUAL=0`

## Cobertura V2

A suite dirigida cobre:

- preparo de OS em `EM_EXECUCAO` com `ENT_ID=001` e demandante `Local 1`;
- resolucao direta do demandante por `ResolverDemandanteAvaliacaoPorOS`;
- inspecao da `AV_Lista` do `Menu_Principal` existente, sem metodo novo no
  UserForm;
- fallback do payload quando o avaliador esta vazio e preservacao de avaliador
  explicito;
- falha auditavel quando a OS aponta para `ENT_ID` inexistente, com restauracao
  da base ao final.

## Veredito Local

Pacote V3 pronto para gate humano. A onda ainda nao esta validada no workbook:
compile e `TV2_RunFormAvaliacaoModulos` dependem da importacao manual por
Mauricio.

## Resultado Humano

Mauricio reportou em 2026-06-02:

- Importador V3 OK: `M=4 | F=0 | err=0 | skip=0`;
- compile limpo no VBE;
- `TV2_RunFormAvaliacaoModulos`: `TV2_20260602_125043` com
  `OK=3 | FALHA=2 | MANUAL=0`;
- CSV de falhas:
  `TesteV2_FORM_AVALIACAO_MODULOS_Falhas_TV2_20260602_125043.csv`.

Falhas observadas:

- `FAM_03_AV_LISTA_EXIBE_DEMANDANTE`: `OS_ID nao encontrada na AV_Lista;
  LISTCOUNT=1; OS_ID=001`;
- `FAM_05_ENT_ID_INVALIDO_FALHA_AUDITAVEL`: `OS_ID nao encontrada para alterar
  ENT_ID: 001`; por isso o payload invalido continuou sucesso.

Diagnostico: `FAM_02_DEMANDANTE_RESOLVIDO_POR_OS` e
`FAM_04_PAYLOAD_FALLBACK_E_PRESERVA_EXPLICITO` passaram. A producao importada
resolve o demandante e monta o payload. As duas falhas restantes ficam no
modulo de teste isolado, que comparou `OS_ID` como texto estrito em pontos em
que o sistema normalmente usa `IdsIguais`.

Veredito: 0138 importou e compilou, mas falhou no gate V2 dirigido. Abrir
fix1 0139 test-only para trocar as comparacoes auxiliares por `IdsIguais`, sem
tocar producao nem UserForms.
