---
titulo: 34 - Tecnico MICRO34 Onda 21 V204 ContarStrikes Resultado
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-05
---

# MICRO34 - ContarStrikes Com Resultado Explicito

## 1. Objetivo

Fechar o debito MD-21.4: os contadores de strikes nao podem transformar erro
interno em `0` quando o valor sera usado para decisao punitiva.

## 2. Mudancas

| Arquivo | Mudanca |
|---|---|
| `src/vba/Repo_Avaliacao.bas` | Adiciona `ContarStrikesPorEmpresaResultado(EMP_ID, notaCorte, qtdOut)` com `TResult`. |
| `src/vba/Repo_Avaliacao.bas` | Adiciona `ContarStrikesParaPunicaoResultado(EMP_ID, notaCorte, qtdOut)` com `TResult`. |
| `src/vba/Repo_Avaliacao.bas` | Wrappers historicos deixam de retornar `0` em erro e passam a levantar erro. |
| `src/vba/Svc_Avaliacao.bas` | `AvaliarOS` usa o contador de punicao com `TResult`; se falhar, registra `AUDIT_LOG` e retorna falha explicita. |
| `src/vba/App_Release.bas` | Build atualizado para `f7aa84f+ONDA21.MD21.4-contar-strikes-result`. |

## 3. Politica adotada

As funcoes historicas `ContarStrikesPorEmpresa` e `ContarStrikesParaPunicao`
continuam existindo para compatibilidade com testes e chamadas antigas, mas nao
silenciam mais falhas. O caminho transacional novo deve usar as funcoes
`...Resultado` com `qtdOut` por referencia.

## 4. Risco fechado

| Debito | Estado apos MICRO34 |
|---|---|
| `DT-V204-CONTARSTRIKES-RESULT` | Fechado para API nova + uso punitivo em `AvaliarOS`. |
| Erro de aba/coluna contado como zero strikes | Mitigado: `AvaliarOS` retorna falha parcial. |
| Empresa inexistente em contador de punicao | Mitigado: contador retorna falha explicita. |

## 5. Escopo adiado

1. Rollback/ordem segura de `EmitirOS` fica para MD-21.5.
2. Guard de aninhamento de `Svc_Transacao` fica para MD-21.6.
3. Fault injection automatizado fica para Onda 23.

## 6. Validacao esperada

Gate esperado:

`V1=171/0+V2_Smoke=28/0+V2_Canonica=24/0+E2E_Strikes=71/0+IntegridadeBase=3/0`

## 7. Evidencias de entrada

1. MICRO32 verde: `VR_20260505_174431`.
2. MICRO33 verde: `VR_20260505_180817`.
