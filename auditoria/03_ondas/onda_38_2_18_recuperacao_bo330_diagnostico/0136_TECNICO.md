---
titulo: Onda 38.2.18 - recuperacao BO330 diagnostico
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-02
---

# Onda 38.2.18 - recuperacao BO330 diagnostico

## Contexto

O workbook de referencia voltou a compilar no build
`fd45a5d+ONDA38.2.6-IMPRESSAO-INTEGRIDADE`, mas
`CT_ValidarRelease_TrioMinimo` reprovou a etapa V1 rapida por quatro falhas
no bloco BO_330. As verificacoes manuais confirmaram:

- `ThisWorkbook.Path = \\Mac\Home\Projetos\Credenciamento`;
- `Application.EnableEvents = True`;
- `Application.Calculation = -4135`;
- `VBComponents.Count = 211`;
- `GetNotaMinimaAvaliacao() = 5`;
- `GetMaxStrikes() = 1`;
- `GetDiasSuspensaoStrike() = 0`;
- `CONFIG!L2 = 1`;
- `CONFIG!M2 = 0`.

As comparacoes contra a exportacao de referencia nao apontaram drift
comportamental direto em `Repo_Avaliacao.bas`, `Svc_Rodizio.bas`,
`Svc_OS.bas` ou `Const_Colunas.bas`.

## Decisao Tecnica

Nao importar `Teste_V2_Engine.bas` nem `Teste_V2_Roteiros.bas` completos
neste workbook de referencia. Esses arquivos no repositorio ja contêm ondas
posteriores e podem referenciar funcoes/forms que o workbook 38.2.6 ainda
nao tem.

Foi criado um modulo isolado:

`Teste_V2_BO330_Diagnostico`

Ele replica apenas o recorte BO_330 necessario para observar:

- atividade C mapeada;
- fila da atividade C;
- `OS_EMP_ID` gravado na OS;
- media gravada;
- strikes antes/depois;
- status e `DT_FIM_SUSP` da empresa selecionada;
- status e `DT_FIM_SUSP` de `EMP03`, que e a expectativa legado da V1.

## Pacote V3

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_18_RECUPERACAO_BO330_DIAGNOSTICO.txt`

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_18_RECUPERACAO_BO330_DIAGNOSTICO", "e157221+ONDA38.2.18-RECUP-BO330-DIAG"
```

Itens:

- `M|001-modulo/AAX-App_Release.bas`;
- `M|001-modulo/ABP-Teste_V2_BO330_Diagnostico.bas`.

Sem forms, sem `.frx`, sem `Auto_Open`, sem producao.

## Gate Humano

Depois do import:

1. VBE > Depurar > Compilar VBAProject.
2. Janela Imediata:

```vb
TV2_RunBO330Diagnostico
```

O resultado pode ter falhas. Nesta onda, falhas do diagnostico sao evidencia
para decidir a proxima correcao, nao regressao do pacote em si.

## Interpretacao

Se `_EMP_SELECIONADA` falhar e mostrar `OS_EMP_ID` diferente de `003`, a
causa provavel esta na expectativa/cenario da bateria V1 ou na ordenacao do
rodizio do cenario.

Se `_EMP_SELECIONADA` passar com `OS_EMP_ID=003`, mas
`_STATUS_EMP_SELECIONADA` ou `_DT_FIM_EMP_SELECIONADA` falhar, a causa
provavel esta no caminho `AvaliarOS -> ContarStrikesParaPunicao -> Suspender`.

Se a empresa selecionada suspender corretamente, mas `_STATUS_EMP03_LEGADO`
falhar, o diagnostico confirma divergencia entre empresa real da OS e a
empresa observada pelo contrato legado BO_330.
