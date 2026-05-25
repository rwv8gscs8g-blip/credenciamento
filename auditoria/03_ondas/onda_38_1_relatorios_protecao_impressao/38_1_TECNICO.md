---
titulo: Onda 38.1 — Relatorios protecao e impressao
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-25
---

# Onda 38.1 — Relatorios protecao e impressao

## Contexto

A Onda 38 foi importada com sucesso no workbook V5, compilou limpo e passou
o RVS completo. O gate humano funcional encontrou novo problema fora do
escopo original: os forms de relatorio conseguiam preencher listas, mas ao
gerar/imprimir usavam a aba `RELATORIO` sem preparar protecao, mantinham
residuos de area impressa e o botao `Imprimir Relatorio` de OS por Empresa
imprimia conteudo gerado antes da data atual digitada.

## Causa

- `Rel_Emp_Serv.frm` limpava apenas `A:D`, deixando colunas e `PrintArea`
  residuais de relatorio anterior.
- `Rel_OSEmpresa.frm` gerava o relatorio no clique da lista e o botao apenas
  imprimia o que ja estava montado.
- Os dois forms escreviam e configuravam pagina em `RELATORIO` sem
  `Util_PrepararAbaParaEscrita`.

## Solucao aplicada

- `Rel_Emp_Serv.frm` agora prepara/restaura protecao, limpa a aba inteira
  antes e depois, define `PrintArea` para `A:D` e aplica
  `Rel_FormatarCabecalho`/`Rel_FormatarDados`.
- `Rel_OSEmpresa.frm` deixa `RO_Lista_Click` como selecao simples.
- `B_RelEmpresaOS_Click` agora gera o relatorio no momento do clique, usando
  a empresa selecionada e a data atual de `Dt_inicial`.
- O parser de data aceita `dd/mm/aaaa`, `dd-mm-aaaa` e `ddmmaaaa`.
- O relatorio OS por Empresa define `PrintArea` para `A:H`, aplica formatacao
  minima padrao e limpa residuos ao terminar.

## Arquivos alterados

| Arquivo | Papel |
|---|---|
| `src/vba/Rel_OSEmpresa.frm` | Corrige fluxo do botao, protecao, data e area impressa |
| `src/vba/Rel_Emp_Serv.frm` | Corrige protecao, limpeza, area impressa e residuos |
| `src/vba/App_Release.bas` | Carimbo `cf778b2+ONDA38.1-relatorios-protecao` |
| `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-RELATORIOS-PROTECAO.txt` | Manifesto delta importavel |

## Comando de importacao

```vb
ImportarPacoteV3_Delta "ONDA38-1-RELATORIOS-PROTECAO", "cf778b2+ONDA38.1-relatorios-protecao"
```

Resultado esperado:

```text
M=1 | F=2 | err=0 | skip=0
```

## Gates humanos

1. Importar pelo comando delta acima.
2. Executar `Depurar > Compilar VBAProject`.
3. Executar `CT_ValidarRelease_TrioMinimo`.
4. Confirmar assinatura preservada: `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0`.
5. Em OS por Empresa, selecionar uma empresa, preencher data opcional e clicar
   `Imprimir Relatorio`; confirmar ausencia de erro de protecao e respeito a
   data digitada.
6. Em Empresas por Servico, selecionar um servico; confirmar ausencia de erro
   de protecao e ausencia de colunas residuais de outro relatorio.

## Proxima onda

A Onda 38.2 fica reservada para padronizacao visual ampla dos relatorios,
incluindo avaliacao de todos os geradores e possivel consolidacao de helper
central de layout. Ela deve iniciar apenas apos os gates humanos da Onda 38.1.
