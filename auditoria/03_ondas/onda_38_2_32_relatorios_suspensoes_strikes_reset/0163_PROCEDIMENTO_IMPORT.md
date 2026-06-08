---
titulo: Procedimento de Import — 0163 Relatorios Suspensoes e Strikes
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0205
data: 2026-06-08
---

# Procedimento de Import — 0163

## Escopo

Delta de codigo e teste para relatorios. A mudanca adiciona strikes por nota
baixa, strikes por recusa/prazo e diagnostico operacional aos relatorios com
empresa; inclui aviso operacional em impressos de Pre-OS, OS e avaliacao; e
documenta o contrato de Novo Periodo e Limpar Base.

Este pacote nao executa VCR. A suite dirigida
`TV2_RunRelatoriosSuspensoesStrikesReset` valida a estrutura do pacote por
contratos read-only.

## Comando Fix1

O pacote base `ONDA38_2_32_RELATORIOS_SUSPENSOES_STRIKES_RESET` ja foi
importado e compilou. O teste `TV2_20260608_114127` retornou
`OK=9 | FALHA=1 | MANUAL=0` por falso negativo em `RELSSR_08`: o teste
procurava os literais do aviso em `Preencher.bas`, mas o texto correto esta
centralizado em `Rel_Rodizio_Status.bas`.

Importar agora apenas o fix1:

No VBE, executar:

```vb
ImportarPacoteV3_Delta "ONDA38_2_32_FIX1_RELATORIOS_SUSPENSOES_STRIKES_RESET", "293e44c+ONDA38.2.32-FIX1-REL-SUSP-STRIKES-RESET"
```

## Resultado Esperado do Importador

```text
M=2 | F=0 | err=0 | skip=0
```

Os `M=2` correspondem a:

- `AAX-App_Release.bas`
- `ABG-Teste_V2_Roteiros.bas`

Este manifesto nao importa forms nem `.frx`.

## Pos-Import

1. VBE > Depurar > Compilar VBAProject.
2. Se o compile falhar, nao salvar o workbook e restaurar o backup V3.
3. Se o compile passar, executar na Janela Imediata:

```vb
TV2_RunRelatoriosSuspensoesStrikesReset
```

Resultado esperado:

```text
OK=10 | FALHA=0 | MANUAL=0
```

Regressao opcional curta:

```vb
TV2_RunTelaRelatorios
```

Resultado esperado:

```text
OK=10 | FALHA=0 | MANUAL=0
```

## Arquivos Importados

Ordem do manifesto:

1. `001-modulo/AAX-App_Release.bas`
2. `001-modulo/ABG-Teste_V2_Roteiros.bas`

Manifesto:

```text
local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_32_FIX1_RELATORIOS_SUSPENSOES_STRIKES_RESET.txt
```

## Conferencia Humana Recomendada

Apos o teste dirigido verde, conferir manualmente pelo fluxo real:

- Empresas Cadastradas: status, suspensa desde/ate, ultima reativacao, strikes
  por nota baixa, strikes por recusa/prazo e diagnostico.
- Empresas Credenciadas: status do credenciamento, status da empresa,
  participacao no rodizio, strikes e diagnostico.
- Empresas Credenciadas por Servico: nome do servico no topo, status da empresa
  e strikes nas linhas.
- OS por Empresa: resumo superior com status, retorno, participacao, strikes e
  diagnostico.
- OS Abertas: nao deve aparecer linha `N.O.S. 0` com `EMPRESA NAO ENCONTRADA`.
- Pre-OS Vencidas: status, rodizio, strikes e diagnostico.
- Impressos de Pre-OS, OS e avaliacao: aviso do sistema com strikes por nota
  baixa e por recusa/prazo.

## Contrato de Reset

- Novo Periodo preserva suspensoes porque limpa apenas `PRE_OS` e `CAD_OS`,
  preservando cadastros, configuracao e auditoria.
- Limpar Base remove suspensoes porque apaga empresas, credenciamentos,
  operacao e auditoria, preservando apenas CNAE e CONFIG.

## Nao Executar Neste Microdelta

- VCR.
- Importacao ou restauracao da 0155.
- Edicao manual em `.frx`.
- Alteracao em `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas` ou
  `ThisWorkbook`.

## Se Falhar

- Falha no import: restaurar backup indicado pelo Importador V3.
- Falha no compile: nao salvar o workbook; restaurar backup V3.
- Falha em `TV2_RunRelatoriosSuspensoesStrikesReset`: anexar CSV de falhas e
  nao rodar VCR.
- Falha visual/manual de formatacao: abrir fix novo classificando se e
  geometria/formato de relatorio, regra de negocio ou evento.
