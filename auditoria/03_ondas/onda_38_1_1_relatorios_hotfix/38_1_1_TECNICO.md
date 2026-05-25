---
titulo: Onda 38.1.1 — Hotfix relatorios
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-25
---

# Onda 38.1.1 — Hotfix relatorios

## Contexto

A Onda 38.1 foi importada, compilou limpo e passou RVS completo. O gate
funcional humano mostrou dois residuos:

- `Rel_Emp_Serv.frm` imprime corretamente quando o operador escolhe `Sim`,
  mas a opcao `Nao` acionava `PrintPreview` e travava a interface.
- `Rel_OSEmpresa.frm` nao imprimia de forma confiavel pela interface, com ou
  sem data digitada.

## Decisoes

- `Nao` deixa de significar visualizar na tela e passa a significar cancelar.
  A visualizacao por `PrintPreview` fica removida destes dois forms nesta onda.
- A data inicial de OS por Empresa e preenchida automaticamente como o primeiro
  dia do mes de sete meses atras:
  `DateSerial(Year(Date), Month(Date) - 7, 1)`.
- Essa escolha evita `DateAdd` e evita preservar um dia inexistente em meses
  menores. A exibicao continua em `dd/mm/yyyy`.
- A padronizacao visual ampla continua fora desta onda e deve ser executada
  depois dos gates funcionais.

## Solucao aplicada

- `Rel_Emp_Serv.frm` remove `PrintPreview` do caminho `Nao` e do cancelamento
  do dialogo de impressora. O form limpa `RELATORIO`, restaura protecao e fecha
  sem travar a interface.
- `Rel_OSEmpresa.frm` preenche `Dt_inicial` no `Initialize`, normaliza entradas
  `dd/mm/aaaa`, `ddmmaaaa` e `ddmmaa`, e filtra por periodo desde a data
  inicial.
- `Rel_OSEmpresa.frm` troca a combinacao `Find` + `Do While` contiguo por
  varredura completa de `CAD_OS` ate `UltimaLinhaAba(SHEET_CAD_OS)`, comparando
  empresa com `IdsIguais`.
- `Rel_OSEmpresa.frm` restaura a ordenacao normal com `ClassificaOS` nos
  caminhos de sucesso, sem registros e erro.

## Arquivos alterados

| Arquivo | Papel |
|---|---|
| `src/vba/Rel_OSEmpresa.frm` | Hotfix de data, filtro por periodo, varredura completa e cancelamento limpo |
| `src/vba/Rel_Emp_Serv.frm` | Remove preview e transforma `Nao` em cancelamento limpo |
| `src/vba/App_Release.bas` | Carimbo `6103cab+ONDA38.1.1-relatorios-hotfix` |
| `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-1-RELATORIOS-HOTFIX.txt` | Manifesto delta importavel |

## Comando de importacao

```vb
ImportarPacoteV3_Delta "ONDA38-1-1-RELATORIOS-HOTFIX", "6103cab+ONDA38.1.1-relatorios-hotfix"
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
5. Em Empresas por Servico, selecionar servico, escolher `Sim` e confirmar
   impressao; repetir escolhendo `Nao` e confirmar cancelamento sem travar.
6. Em OS por Empresa, abrir o form, confirmar data padrao, selecionar empresa e
   imprimir; repetir apagando a data para confirmar que ela volta ao padrao.

## Proxima onda

A Onda 38.2 de padronizacao visual ampla permanece deferida ate este hotfix
passar em importacao, compile, RVS e gates funcionais.
