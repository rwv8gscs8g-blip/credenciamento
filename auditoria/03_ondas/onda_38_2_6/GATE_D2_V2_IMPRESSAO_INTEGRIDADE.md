---
titulo: Gate D2 - impressao integridade
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-31
---

# Gate D2 - impressao integridade

## TV2 dirigida

Suite: `TV2_RunImpressaoIntegridade`.

| Cenario | Cobertura |
|---|---|
| `CS_IMP_01_NOTAS_CLAMP` | Helper de nota impressa limita 11 para 10, preserva 10/7 e limita negativo/vazio para 0. |
| `CS_IMP_02_PREOS_ID_PREFIXO` | `PROVISORIA - 003` normaliza para `003`; ID cru permanece igual. |
| `CS_IMP_03_OS_GLOBAIS_FORM` | `Menu_Principal` alimenta `NR_Empenho`, `END_ENTIDADE` e chama `PreencherOS`. |
| `CS_IMP_04_OS_TEMPLATE` | `PreencherOS` escreve local e empenho no template. |
| `CS_IMP_05_PREOS_DADOS_TEMPLATE` | `PreencherPREOS` chama o recarregamento de dados com ID normalizado. |
| `CS_IMP_06_AVALIACAO_TEMPLATE` | `PreencherAvaliacaoOS` usa helper seguro para notas `N27:N36`. |

## Saida esperada

```text
OK=6 | FALHA=0 | MANUAL=0
```

## Evidencia

Mauricio executou em 2026-05-31:

```text
Execucao: TV2_20260531_215928
OK=6 | FALHA=0 | MANUAL=0
CSV de falhas: Nao exportado
```

Status: aprovado.
