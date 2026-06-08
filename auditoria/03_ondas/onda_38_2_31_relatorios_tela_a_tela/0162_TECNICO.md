---
titulo: Onda 38.2.31 — Relatorios tela a tela com status e formatacao
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-08
---

# 0162 — Relatorios Tela a Tela

## Objetivo

Fechar a revisao tela a tela dos relatorios que exibem empresas, garantindo que
o operador veja status operacional, datas de suspensao, retorno/reativacao e
participacao no rodizio sem precisar abrir a base.

## Classificacao HBN

A mudanca e de **relatorio, leitura de regra de negocio e teste dirigido**.
Nao e defeito de geometria de UserForm.

- sem alteracao em `.frx`;
- sem tocar `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas` ou
  `ThisWorkbook`;
- sem VCR neste microdelta;
- impressao real permanece fluxo humano; o teste V2 e read-only por tokens.

## Causa

Os bloqueios por strikes e notas foram validados manualmente, mas os relatorios
ainda nao davam ao operador a mesma leitura operacional. Em especial:

- "Empresas Credenciadas" nao mostrava se a empresa estava suspensa;
- "Empresas Credenciadas por Servico" nao identificava o servico no topo;
- relatorios com empresa nao exibiam datas de suspensao e retorno;
- alguns relatorios ainda nao usavam o padrao visual aprovado de cabecalho,
  linhas alternadas e bordas.

## Acao

Foram adicionados helpers publicos em `Rel_Rodizio_Status.bas` para converter
o status tecnico em texto humano:

- `RRS_StatusGlobalHumano`;
- `RRS_SuspensaDesdeTexto`;
- `RRS_SuspensaAteTexto`;
- `RRS_UltimaReativacaoTexto`;
- `RRS_ParticipaRodizioHumanoPorEmpresa`.

O `Menu_Principal.frm` passou a gerar as listagens principais na aba temporaria
`RELATORIO`, com limpeza da area de impressao e formatacao comum:

- Entidades Cadastradas: formatacao padrao.
- Empresas Cadastradas: status, suspensa desde, suspensa ate e ultima
  reativacao.
- Empresas Credenciadas: atividade, servico, status do credenciamento, status
  da empresa, suspensao e participacao no rodizio.
- OS Abertas: status da empresa, suspensa desde, suspensa ate e participacao.
- Pre-OS Vencidas: status da empresa, suspensa desde, suspensa ate e
  participacao.

Os forms especificos tambem foram ajustados:

- `Rel_Emp_Serv.frm` mostra atividade, servico e codigo atividade/servico no
  topo do relatorio, alem de status da empresa e rodizio na tabela.
- `Rel_OSEmpresa.frm` mostra resumo superior com status, suspensa desde,
  suspensa ate, dias restantes, retorno previsto, ultima reativacao e
  participacao no rodizio.

## Teste Dirigido

Foi criada a suite `TV2_RunTelaRelatorios`, com 10 cenarios read-only:

| Cenario | Cobertura |
|---|---|
| `REL_TELA_01` | helpers de status humano |
| `REL_TELA_02` | Empresa por Servico mostra nome do servico e status |
| `REL_TELA_03` | OS por Empresa mostra datas e status |
| `REL_TELA_04` | Entidades usa formatacao padrao |
| `REL_TELA_05` | Empresas Cadastradas mostra status e datas |
| `REL_TELA_06` | Empresas Credenciadas mostra status e participacao |
| `REL_TELA_07` | OS Abertas mostra status e datas |
| `REL_TELA_08` | Pre-OS Vencidas mostra status e datas |
| `REL_TELA_09` | aba temporaria e area de impressao sao limpas |
| `REL_TELA_10` | Status do Rodizio por Servico preserva diagnostico formatado |

## Consequencias Operacionais

O operador passa a enxergar, nos relatorios, se a empresa esta ativa, suspensa
ou inativa. Quando houver suspensao, os relatorios exibem desde quando ela esta
suspensa, ate quando permanece bloqueada e se ja existe ultima reativacao
registrada.

Isso reduz a chance de decisao manual baseada apenas em credenciamento ativo.
Credenciamento ativo nao significa empresa apta: a coluna de participacao no
rodizio deixa essa diferenca explicita.

## Arquivos Alterados

- `src/vba/App_Release.bas`
- `src/vba/Menu_Principal.frm`
- `src/vba/Rel_Emp_Serv.frm`
- `src/vba/Rel_OSEmpresa.frm`
- `src/vba/Rel_Rodizio_Status.bas`
- `src/vba/Teste_V2_Engine.bas`
- `src/vba/Teste_V2_Roteiros.bas`
- espelhos correspondentes em `local-ai/vba_import/`
- `docs/tutorials/MANUAL_OPERACIONAL_TELA_A_TELA.md`
- `docs/reference/testes/GUIA_DE_TESTES_E_VALIDACAO.md`
- `CHANGELOG.md`
- `auditoria/INDEX.md`
- `.hbn/relay/INDEX.md`

## Gate Esperado

1. Importar o delta V3:

```vb
ImportarPacoteV3_Delta "ONDA38_2_31_RELATORIOS_TELA_A_TELA", "293e44c+ONDA38.2.31-RELATORIOS-TELA-A-TELA"
```

2. Esperado no Importador V3:

```text
M=4 | F=3 | err=0 | skip=0
```

3. Compilar no VBE.
4. Rodar na Janela Imediata:

```vb
TV2_RunTelaRelatorios
```

5. Esperado:

```text
OK=10 | FALHA=0 | MANUAL=0
```

6. Validar manualmente, se desejado, a aparencia dos relatorios impressos por
   fluxo humano real. Nao rodar VCR neste microdelta.
