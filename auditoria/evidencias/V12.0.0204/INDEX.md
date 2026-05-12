---
titulo: Índice de Evidências V12.0.0204
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-12
---

# Índice de Evidências V12.0.0204

Esta pasta contém as evidências públicas da release V12.0.0204. A pasta
canônica para evidências atuais é:

```text
auditoria/evidencias/V12.0.0204/
```

A pasta histórica `auditoria/04_evidencias/` permanece no repositório apenas
por compatibilidade documental de versões anteriores.

## Evidência canônica final

| Evidência | Papel | Resultado |
|---|---|---|
| `ValidacaoReleaseSexteto_V12_0_0204_VR_20260511_175849.csv` | Cópia canônica V204 do gate adicional após MICRO55 App_Release final | APROVADO |
| `ValidacaoReleaseSexteto_V12_0_0203_VR_20260511_175849.csv` | Nome histórico original preservado | APROVADO |

Essa é a evidência preferencial para confirmar a V12.0.0204 após o ajuste final
da janela **Sobre**.

## Evidência de publicação

| Evidência | Papel | Resultado |
|---|---|---|
| `ValidacaoReleaseSexteto_V12_0_0204_VR_20260511_154433.csv` | Cópia canônica V204 do gate usado na publicação V12.0.0204 | APROVADO |
| `ValidacaoReleaseSexteto_V12_0_0203_VR_20260511_154433.csv` | Nome histórico original preservado | APROVADO |

## Evidências intermediárias

| Evidência | Contexto |
|---|---|
| `ValidacaoReleaseSexteto_V12_0_0203_VR_20260510_000428.csv` | Gate rc1 anterior ao fechamento final |
| `ValidacaoReleaseSexteto_V12_0_0203_VR_20260511_132806.csv` | Gate intermediário após correção de Limpar Base |
| `intermediarios/TesteV2_SMOKE_Falhas_TV2_20260511_125944.csv` | Falha intermediária resolvida antes do gate final |

## Observação sobre o prefixo `V12_0_0203`

Os CSVs originais da V12.0.0204 mantiveram no nome o prefixo histórico
`ValidacaoReleaseSexteto_V12_0_0203_`. O conteúdo interno, a pasta de destino e
os gates documentados correspondem à V12.0.0204.

Para reduzir ruído na vitrine pública, a MICRO58 adicionou cópias com prefixo
`V12_0_0204` para as duas evidências oficiais. Os nomes históricos permanecem
preservados para rastreabilidade.

## Sintaxe esperada da V12.0.0204

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

## Como usar este índice

1. Para validar a release publicada, consulte `VR_20260511_154433`.
2. Para validar o estado final após App_Release MICRO55, consulte
   `VR_20260511_175849`.
3. Para auditoria de incidentes, consulte a pasta `intermediarios/`.
4. Para histórico V202/V203, consulte `auditoria/evidencias/` e
   `auditoria/04_evidencias/` com atenção ao período da release.
