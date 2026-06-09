---
titulo: Onda 38.2.34 — Pre-OS vencidas: relatorio e impressao
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-08
---

# 0165 — Pre-OS vencidas: relatorio e impressao

## Contexto

A revisao tela a tela dos relatorios levantou uma duvida operacional: ao
imprimir o relatorio de Pre-OS vencidas, a Pre-OS deveria expirar
automaticamente ou apenas aparecer para decisao humana?

A leitura do codigo confirmou o comportamento correto atual. O botao
`PRE_OS_Vencidas_Click` e um relatorio: ele lista Pre-OS vencidas em
`AGUARDANDO_ACEITE`, monta a aba temporaria `RELATORIO`, imprime e limpa a
area de impressao. Ele nao chama `ExpirarPreOS`, `RecusarPreOS` ou
`AvancarFila`.

## Classificacao HBN

| Item | Classificacao |
|---|---|
| Tipo | teste/documentacao de comportamento operacional |
| Designer | nao alterado |
| `.frx` | nao requerido |
| Regra de negocio | preservada |
| Persistencia | nao alterada |
| Teste | V2 dirigido por contrato de trecho |

## Acoes implementadas

- `TV2_RunTelaRelatorios` passou de 10 para 11 cenarios.
- Foi adicionado o cenario
  `REL_TELA_11_PREOS_VENCIDAS_IMPRESSAO_SEM_EXPIRAR`.
- O novo cenario valida o trecho de `Menu_Principal.PRE_OS_Vencidas_Click`.
- O teste exige tokens de filtro e impressao do relatorio.
- O teste reprova se o trecho contiver chamada a `ExpirarPreOS`, `RecusarPreOS`
  ou `AvancarFila`.
- Catalogo e roteiro assistido V2 receberam o novo cenario.
- Manual tela a tela e guia de testes documentam o fluxo humano correto.

## Comportamento operacional

O relatorio de Pre-OS vencidas e informativo. O operador deve usa-lo para
identificar pendencias vencidas. Se a decisao for expirar uma Pre-OS, a acao
deve ser tomada na tela operacional apropriada, por comando explicito de
expiracao. Depois disso, se a demanda ainda precisar de atendimento, o operador
emite nova Pre-OS para acionar novo rodizio.

Essa separacao evita que uma impressao administrativa altere a fila do rodizio
sem confirmacao humana.

## Teste esperado

```vb
TV2_RunTelaRelatorios
```

Esperado: `OK=11 | FALHA=0 | MANUAL=0`.

## Fora do escopo

- Nao foi alterada a rotina de expiracao.
- Nao foi alterado o motor do rodizio.
- Nao foi alterado o layout dos UserForms.
- Nao foi adicionada automacao de impressao real.
- VCR fica reservado para checkpoint forte posterior.
