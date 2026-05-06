---
titulo: Onda 22 MICRO38 — Fechamento INT-CAD-OS-REF-ORFA
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-06
---

# Onda 22 MICRO38 — Fechamento INT-CAD-OS-REF-ORFA

## Objetivo

Fechar o bug `INT-CAD-OS-REF-ORFA` sem apagar dados reais: separar residuos legados sem `OS_ID` de orfas reais em `CAD_OS`, oferecer migracao explicita e manter teste automatizado no mesmo microdelta.

## Diagnostico

A base de homologacao apresentava residuos em `CAD_OS` com `OS_ID` vazio e sobras em colunas finais (`ATIV_ID`, `PREOS_ID`, `STATUS`, `JUSTIF`). Isso podia manter `CS_INT_04` como manual mesmo quando nao havia OS real com chave referencial quebrada.

## Mudanca tecnica

| Arquivo | Mudanca |
|---|---|
| `src/vba/Repo_OS.bas` | adiciona diagnostico `RepoOS_DiagnosticarReferenciasCADOS`, limpeza controlada `RepoOS_LimparResiduosCADOSSemChave` e comando operacional `RepoOS_MigrarRefOrfaLegado` |
| `src/vba/Teste_V2_Roteiros.bas` | adiciona `MIG_006` ao Smoke e altera `CS_INT_04` para usar o diagnostico do repositorio |
| `src/vba/Teste_V2_Engine.bas` | adiciona `MIG_006` ao catalogo/roteiro e reforca `TV2_ClearSheet` para limpar sobras nas primeiras 50 colunas |
| `src/vba/App_Release.bas` | bump para `f7aa84f+ONDA22.MD22.2-ref-orfa-cad-os` |

## Contrato de comportamento

1. Linhas sem `OS_ID` e com sobras em `CAD_OS` sao classificadas como residuos sem chave.
2. Linhas com `OS_ID` preenchido continuam sendo tratadas como OS real; se `EMP_ID` ou `ATIV_ID` nao bater, ficam reportadas como orfas reais.
3. A migracao limpa apenas residuos sem chave; nao exclui OS real.
4. A limpeza registra `EVT_TRANSACAO` com `LIMPEZA_REF_ORFA_CONTROLADA=OK` quando altera a base.
5. `CS_INT_04` move `INT-CAD-OS-REF-ORFA` para `RPT_BUGS_RESOLVIDOS` somente quando orfas reais e residuos chegam a zero.

## Cobertura de teste

`TV2_RunSmoke` passa a incluir `MIG_006`:

| Cenario | Validacao |
|---|---|
| `MIG_006` | cria uma linha residual sem `OS_ID` em `CAD_OS`, confirma que o diagnostico conta residuo e nao orfa real, executa a limpeza controlada e confirma diagnostico zerado |

Sintaxe esperada do Quinteto apos importacao e migracao:

`V1=171/0+V2_Smoke=31/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`

## Limites conscientes

- Se `RepoOS_MigrarRefOrfaLegado` apontar `ORFA_EMP` ou `ORFA_ATIV` maior que zero depois da limpeza, o caso nao deve ser considerado fechado: existe OS real com referencia invalida e precisa triagem humana.
- MICRO38 nao altera regras de emissao/avaliacao de OS; limita-se a diagnostico, migracao controlada e integridade.
- A migracao nao roda automaticamente no `Auto_Open`.

## Higiene documental

Gate aplicado conforme `.hbn/knowledge/0011-higiene-documental-recorrente.md`:

- readback/ERP criados;
- manifesto V3 criado;
- `src/vba` e `local-ai/vba_import` com `shasum` pareado;
- procedimento de importacao com comandos copiaveis;
- CHANGELOG/relay/roadmap atualizados.
