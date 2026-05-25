---
titulo: Onda 38.1.2 — Botao real Rel_OSEmpresa
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-25
---

# Onda 38.1.2 — Botao real Rel_OSEmpresa

## Contexto

A Onda 38.1.1 importou e compilou. O gate funcional confirmou que
`Rel_Emp_Serv.frm` passou a cancelar corretamente quando o operador escolhe
`Nao`.

O relatorio OS por Empresa continuou sem imprimir pelo botao do form. A
inspecao por `strings src/vba/Rel_OSEmpresa.frx` e o screenshot do VBE
confirmaram que o `CommandButton` real se chama `B_RelMEIOS`, enquanto o
codigo tinha apenas o handler `B_RelEmpresaOS_Click`.

## Causa

O VBA compila porque `B_RelEmpresaOS_Click` e uma Sub privada valida, mas ela
nao e evento de nenhum controle existente no form. Ao clicar no botao visivel
`B_RelMEIOS`, nenhuma rotina era disparada.

## Solucao aplicada

- Adicionado `B_RelMEIOS_Click` em `Rel_OSEmpresa.frm`.
- Mantido `B_RelEmpresaOS_Click` por compatibilidade documental/historica.
- Ambos chamam `AcionarRelatorioOSEmpresa`, que centraliza o tratamento de
  erro e chama `GerarImprimirRelatorioOSEmpresa`.
- `Rel_OSEmpresa.frx` nao foi tocado.

## Arquivos alterados

| Arquivo | Papel |
|---|---|
| `src/vba/Rel_OSEmpresa.frm` | Adiciona handler do botao real `B_RelMEIOS_Click` |
| `src/vba/App_Release.bas` | Carimbo `10ef253+ONDA38.1.2-rel-os-empresa-botao` |
| `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-1-2-REL-OS-EMPRESA-BOTAO.txt` | Manifesto delta importavel |

## Comando de importacao

```vb
ImportarPacoteV3_Delta "ONDA38-1-2-REL-OS-EMPRESA-BOTAO", "10ef253+ONDA38.1.2-rel-os-empresa-botao"
```

Resultado esperado:

```text
M=1 | F=1 | err=0 | skip=0
```

## Gates humanos

1. Importar pelo comando delta acima.
2. Executar `Depurar > Compilar VBAProject`.
3. Executar `CT_ValidarRelease_TrioMinimo`.
4. Confirmar assinatura preservada: `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0`.
5. Abrir OS por Empresa, selecionar empresa, manter data `01/10/2025` ou data
   padrao, clicar `Imprimir Relatorio` e confirmar PDF com titulo
   `Relatorio de Ordens de Servico por Empresa`.

## Observacao

A limpeza de diretorio feita pelo operador em `V12-204-Micro48/` ficou fora do
escopo desta onda e nao deve entrar no commit 38.1.2.
