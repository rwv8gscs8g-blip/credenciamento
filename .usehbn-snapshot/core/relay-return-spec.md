---
titulo: Relay return spec — recibo efemero de execucao
diataxis: reference
status: proposed
temperatura: frio
created_at: "2026-06-20T10:00:00-03:00"
autoria: "claude-opus-4-8 (orquestrador) + codex (implementador)"
---

# Relay return spec

Esta especificacao define o canal de retorno A+C para que silencio em disco
nao seja confundido com espera legitima. Todo implementador escreve um recibo
legivel por maquina ao final de qualquer execucao, incluindo sucesso, bloqueio
por guard ou erro operacional.

## Recibo

O recibo vive em `.hbn/relay/RETURN.json`.

Esse arquivo e efemero e nao deve ser versionado. Ele existe para comunicar o
resultado da execucao corrente ao orquestrador ou harness consumidor.

## Schema

```json
{
  "de": "<apelido>",
  "para": "orquestrador",
  "ts": "<ISO-8601>",
  "ref_despacho": "<path do bloco/despacho>",
  "status": "ok|blocked|error",
  "sha": "<commit ou null>",
  "files": ["..."],
  "blockers": [
    {
      "guard": "...",
      "arquivo": "...",
      "linha": 0,
      "motivo": "..."
    }
  ],
  "resumo": "<1-3 linhas>"
}
```

Regras dos campos:

- `de`: apelido canonico do implementador que executou a entrega.
- `para`: sempre `orquestrador`.
- `ts`: instante de escrita do recibo em ISO-8601.
- `ref_despacho`: arquivo do despacho, mensagem ou bloco que originou a
  execucao.
- `status`: `ok` quando a entrega terminou e o commit existe; `blocked`
  quando um guard, regra ou pre-condicao bloqueou; `error` quando a execucao
  falhou antes de chegar a um bloqueio governado.
- `sha`: SHA do commit entregue quando `status=ok`; `null` nos demais casos.
- `files`: caminhos tocados, incluindo arquivos versionados e recibos
  efemeros relevantes.
- `blockers`: lista estruturada de bloqueios. Use lista vazia quando nao houver
  bloqueador.
- `resumo`: uma a tres linhas com o resultado humano da execucao.

## Ciclo de Vida

O implementador sempre escreve `.hbn/relay/RETURN.json` como ultima acao antes
de encerrar a execucao.

O consumidor le o recibo, age sobre o resultado e descarta o arquivo. O descarte
pode mover `.hbn/relay/RETURN.json` para
`.hbn/relay/inbox/.consumed/<ts>-RETURN.json`, mantendo trilha, ou apagar o
arquivo quando a trilha externa ja for suficiente.

## Contrato de Timeout

O harness deve tratar a ausencia de recibo novo apos o tempo `T` como estado de
erro. Ausencia apos timeout nao representa espera, silencio aceitavel nem
execucao ainda saudavel.
