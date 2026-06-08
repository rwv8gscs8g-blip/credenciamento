---
titulo: Procedimento de Import — 0162 Relatorios Tela a Tela
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0205
data: 2026-06-08
---

# Procedimento de Import — 0162

## Escopo

Delta de codigo e teste para relatorios tela a tela. A mudanca adiciona status
da empresa, datas de suspensao, ultima reativacao, participacao no rodizio e
formatacao padrao nos relatorios relevantes.

Este pacote nao executa VCR e nao aciona impressao automaticamente pelo teste.
A suite dirigida `TV2_RunTelaRelatorios` valida a estrutura do pacote por
contratos read-only.

## Comando

No VBE, executar:

```vb
ImportarPacoteV3_Delta "ONDA38_2_31_RELATORIOS_TELA_A_TELA", "293e44c+ONDA38.2.31-RELATORIOS-TELA-A-TELA"
```

## Resultado Esperado do Importador

```text
M=4 | F=3 | err=0 | skip=0
```

Os `F=3` correspondem a:

- `AAM-Menu_Principal.frm`
- `AAK-Rel_Emp_Serv.frm`
- `AAL-Rel_OSEmpresa.frm`

Este manifesto nao importa `.frx`.

## Pos-Import

1. VBE > Depurar > Compilar VBAProject.
2. Se o compile falhar, nao salvar o workbook e restaurar o backup V3.
3. Se o compile passar, executar na Janela Imediata:

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
2. `001-modulo/ABF-Teste_V2_Engine.bas`
3. `001-modulo/ABG-Teste_V2_Roteiros.bas`
4. `001-modulo/ABV-Rel_Rodizio_Status.bas`
5. `002-formularios/AAM-Menu_Principal.frm`
6. `002-formularios/AAK-Rel_Emp_Serv.frm`
7. `002-formularios/AAL-Rel_OSEmpresa.frm`

Manifesto:

```text
local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_31_RELATORIOS_TELA_A_TELA.txt
```

## Conferencia Humana Recomendada

Apos o teste dirigido verde, conferir manualmente pelo fluxo real, quando
necessario:

- Empresas Cadastradas: status, suspensa desde, suspensa ate e ultima
  reativacao.
- Empresas Credenciadas: status do credenciamento, status da empresa e
  participacao no rodizio.
- Empresas Credenciadas por Servico: nome da atividade/servico no topo e
  status da empresa nas linhas.
- OS por Empresa: resumo superior com status, suspensao e retorno.
- OS Abertas e Pre-OS Vencidas: status e datas junto da empresa listada.

## Nao Executar Neste Microdelta

- VCR.
- Importacao ou restauracao da 0155.
- Edicao manual em `.frx`.
- Alteracao em `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas` ou
  `ThisWorkbook`.

## Se Falhar

- Falha no import: restaurar backup indicado pelo Importador V3.
- Falha no compile: nao salvar o workbook; restaurar backup V3.
- Falha em `TV2_RunTelaRelatorios`: anexar CSV de falhas e nao rodar VCR.
- Falha visual/manual de formatacao: abrir fix novo classificando se e
  geometria/formato de relatorio, regra de negocio ou evento.
