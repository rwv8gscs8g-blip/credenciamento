---
titulo: AT-3 Validacao Estatica Pre-OS IDs
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-05-27
---

# AT-3 Validacao Estatica Pre-OS IDs

## Normalizador local em Repo_PreOS

Contrato aplicado por `NormalizarIdTextual`:

| Entrada | Saida esperada | Observacao |
|---|---|---|
| `Error` | vazio | defensivo; nao propaga erro |
| `Null` | vazio | defensivo |
| `Empty` | vazio | defensivo |
| `X` | `X` | nao numerico preservado |
| `0` | `000` | largura minima 3 |
| `001` | `001` | preservado |
| `1000` | `1000` | nao trunca acima de 999 |
| `005001` | `005001` | nao remove zeros significativos em IDs longos |
| ` 1 ` | `001` | trim + largura minima |
| `1.5e2` | `1.5e2` | string nao e aceita como numerica; sem `IsNumeric` |

## Checagens

- `Repo_PreOS.bas` nao chama `Pad3`.
- `Repo_PreOS.bas` nao chama `IsNumeric`.
- Comparacao de `BuscarPorId` usa `IdTextualIgual`, que compara os dois lados depois de normalizacao local.
- `Svc_PreOS.EmitirPreOS` aplica `NumberFormat="@"` antes de gravar IDs textuais em `PRE_OS`.
- `Repo_PreOS.Inserir` aplica `NumberFormat="@"` antes de gravar IDs textuais no caminho dormente.

## Decisao sobre >999

Nao foi feita ampliacao global de largura para quatro ou mais digitos. O contrato V206 neste AT-3 e: 3 digitos sao a largura minima de IDs curtos; IDs com quatro ou mais digitos permanecem completos.
