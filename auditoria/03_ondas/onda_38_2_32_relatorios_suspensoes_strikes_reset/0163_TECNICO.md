---
titulo: Onda 38.2.32 — Relatorios com suspensoes, strikes e reset documentado
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-08
---

# 0163 — Relatorios, Suspensoes, Strikes e Reset

## Objetivo

Normalizar a leitura de suspensao em todos os relatorios que exibem empresas,
mostrar strikes por nota baixa e por recusa/prazo, remover linha fantasma de OS
abertas e documentar o comportamento confirmado de `Iniciar Novo Periodo` e
`Limpar Base`.

## Classificacao HBN

A mudanca e de **relatorio, leitura de regra de negocio, aviso em impressao e
teste dirigido**. Nao e defeito de geometria de UserForm.

- sem `.frx` no manifesto V3;
- sem tocar `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas` ou
  `ThisWorkbook`;
- sem VCR neste microdelta;
- fluxos destrutivos continuam documentados, mas a suite nova e estrutural por
  tokens.

## Causa

Depois da validacao manual, o comportamento de negocio ficou correto:

- `Iniciar Novo Periodo` preserva suspensoes, porque e passagem de ano;
- `Limpar Base` remove suspensoes, porque e reset total para outro municipio.

Os PDFs 054-061 mostraram duas lacunas de apresentacao:

- uma empresa podia aparecer como suspensa em um relatorio e sem a mesma leitura
  em outro;
- o relatorio de OS abertas podia imprimir uma linha `N.O.S. 0` com `EMPRESA
  NAO ENCONTRADA`.

Tambem faltava expor, nos relatorios e documentos impressos, quantos strikes a
empresa acumulou por nota baixa e por recusa/prazo.

## Acao

`Rel_Rodizio_Status.bas` ganhou helpers publicos para leitura operacional:

- `RRS_StrikesNotaBaixa`;
- `RRS_StrikesRecusaPrazo`;
- `RRS_StrikesNotaBaixaTexto`;
- `RRS_StrikesRecusaPrazoTexto`;
- `RRS_DiagnosticoOperacionalEmpresa`;
- `RRS_AvisoOperacionalEmpresa`.

Quando a empresa esta suspensa e o novo periodo ja limpou `CAD_OS`, o helper de
strikes por nota baixa usa o ultimo evento de suspensao por strike no
`AUDIT_LOG` como fallback. Isso preserva a explicacao da suspensao que continua
vigente entre exercicios.

`Menu_Principal.frm` passou a mostrar, nas tabelas geradas em `RELATORIO`:

- `STRIKES NOTA BAIXA`;
- `STRIKES RECUSA/PRAZO`;
- `DIAGNOSTICO SISTEMA`.

Isso foi aplicado a Empresas Cadastradas, Empresas Credenciadas, OS Abertas e
Pre-OS Vencidas. O relatorio de OS abertas agora ignora linhas sem numero real
de OS ou com `N.O.S. 0`.

`Rel_Emp_Serv.frm` e `Rel_OSEmpresa.frm` tambem receberam status, strikes e
diagnostico. `Preencher.bas` passou a escrever aviso operacional em impressos
de Pre-OS, OS e avaliacao.

## Contrato de Reset

`Iniciar Novo Periodo`:

- cria pasta e copia da planilha;
- limpa `PRE_OS` e `CAD_OS`;
- zera os contadores AR dessas abas;
- preserva `EMPRESAS`, `CREDENCIADOS`, `CONFIG` e `AUDIT_LOG`;
- portanto, preserva suspensoes vigentes.

`Limpar Base`:

- apaga `EMPRESAS`, `EMPRESAS_INATIVAS`, `ENTIDADE`,
  `ENTIDADE_INATIVOS`, `CREDENCIADOS`, `CAD_SERV`, `PRE_OS`, `CAD_OS`,
  `AUDIT_LOG` e `RELATORIO`;
- preserva `ATIVIDADES` e `CONFIG`;
- portanto, remove suspensoes anteriores e deixa a base pronta para outro
  municipio.

## Teste Dirigido

Foi criada a suite `TV2_RunRelatoriosSuspensoesStrikesReset`, com 10 cenarios
estruturais:

| Cenario | Cobertura |
|---|---|
| `RELSSR_01` | helpers de strikes e fallback por auditoria |
| `RELSSR_02` | Empresas Cadastradas com strikes e diagnostico |
| `RELSSR_03` | Empresas Credenciadas com status global, rodizio e strikes |
| `RELSSR_04` | OS Abertas sem linha fantasma de N.O.S. zero |
| `RELSSR_05` | Pre-OS Vencidas com diagnostico |
| `RELSSR_06` | Empresa por Servico com nome do servico, status e strikes |
| `RELSSR_07` | OS por Empresa com resumo superior de strikes |
| `RELSSR_08` | Pre-OS, OS e avaliacao impressas com aviso operacional |
| `RELSSR_09` | contrato de Novo Periodo preservando suspensoes |
| `RELSSR_10` | contrato de Limpar Base removendo suspensoes |

`TV2_RunTelaRelatorios` foi mantida e atualizada para a nova largura das
tabelas.

## Consequencias Operacionais

O operador passa a ler a mesma situacao da empresa nos relatorios principais:
status global, suspensao, rodizio, strikes e diagnostico. A empresa sabe se tem
strikes por nota baixa e/ou por recusa/prazo, e a area gestora consegue auditar
a causa operacional sem abrir as abas de dados.

Novo Periodo deixa de parecer anistia: ele preserva suspensoes. Limpar Base fica
documentado como reset total para outro municipio.

## Arquivos Alterados

- `src/vba/App_Release.bas`
- `src/vba/Menu_Principal.frm`
- `src/vba/Preencher.bas`
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

1. Importar o fix1 test-only:

```vb
ImportarPacoteV3_Delta "ONDA38_2_32_FIX1_RELATORIOS_SUSPENSOES_STRIKES_RESET", "293e44c+ONDA38.2.32-FIX1-REL-SUSP-STRIKES-RESET"
```

2. Esperado no Importador V3:

```text
M=2 | F=0 | err=0 | skip=0
```

3. Compilar no VBE.
4. Rodar na Janela Imediata:

```vb
TV2_RunRelatoriosSuspensoesStrikesReset
```

5. Esperado:

```text
OK=10 | FALHA=0 | MANUAL=0
```

6. Como regressao opcional curta, rodar `TV2_RunTelaRelatorios`. Nao rodar VCR
   neste microdelta.
