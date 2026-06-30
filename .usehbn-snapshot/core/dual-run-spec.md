---
titulo: Dual-run spec — caracterização de legado e gate de substituição
diataxis: reference
status: proposed
temperatura: quente
id-global: 20260610-38
versao: 0.1.0
data: 2026-06-10
autoria: claude-fable-5 (arquiteto useHBN, corrente D)
hearback-status: pendente (lote corrente D)
relacionado: [ADR-016, schemas/dual-run-result.schema.json]
---

# Dual-run spec — o comportamento atual vira gabarito

## §1 Vocabulário

- **golden**: saída do motor ATUAL para um caso, congelada com hash. Inclui
  comportamento não documentado — caracterização, não especificação.
- **caso**: entrada nomeada e reprodutível (id estável + inputs versionados).
- **corpus**: conjunto de casos. Vive no projeto (`.hbn/dual-run/corpus/`).
- **normalização**: transformação DECLARADA aplicada às duas saídas antes do
  diff (ex.: zerar timestamps, ordenar chaves). Sem declaração = byte a byte.

## §2 Fase 1 — caracterizar o velho

1. Eleger corpus: caminho feliz + bordas de produção + TODA regra não
   documentada conhecida (cada uma vira caso nomeado com comentário).
2. Rodar o motor ATUAL (humano roda — T3) e gravar, por caso:
   `inputs_hash`, `hash_velho` (sha256 da saída normalizada), e a saída bruta
   em `.hbn/dual-run/golden/<caso>/`.
3. Golden é append-only; mudar um golden = novo caso ou diff justificado.

## §3 Fase 2 — dual-run do novo

Para cada caso: rodar o motor NOVO sobre os MESMOS inputs, normalizar igual,
calcular `hash_novo`, emitir um registro `dual-run-result` (schema
`schemas/dual-run-result.schema.json`):

- `diff_status: identico` quando `hash_novo == hash_velho`.
- `diff_status: diferente` exige `diff_resumo` (o que mudou, em linguagem
  humana), `justificativa` (por que a diferença é desejada) e, para o gate
  passar, `hearback_ref` apontando hearback confirmado.

## §4 O gate (função, executável por script ou à mão)

```
para cada registro r do corpus:
  r.diff_status == identico                      → passa
  r.diff_status == diferente
      e r.justificativa presente
      e r.hearback_ref presente (confirmado)     → passa-com-justificativa
  caso contrário                                 → FALHA (lista o caso)
gate = PASSA sse nenhum caso FALHA e todo caso do corpus tem registro
```

Caso sem registro conta como FALHA (corpus é contrato, não amostra).
Veredicto final + lista de falhas = saída obrigatória de qualquer
implementação do gate.

**Nota (auditoria 0021/F-06, corrente E): schema-válido ≠ gate-aprovado.**
O schema (`schemas/dual-run-result.schema.json`) valida a FORMA do registro;
o veredicto do gate é a função acima — em particular, `diferente` passa no
schema sem `hearback_ref`, mas FALHA no gate. Antes do primeiro uso
operacional de substituição, deve existir script/fixture versionado do gate
(backlog corrente E); até lá, nenhum "validou no schema" conta como
aprovação (ADR-020, anti-teatro).

## §5 Cobertura mínima e regra de produção

Corpus mínimo: 1 caso por relatório/tela/fluxo de saída do motor + 1 caso por
regra não documentada conhecida. Regra permanente: produção revela
comportamento novo → o caso entra no corpus (caracterizado contra o motor
vigente) ANTES de qualquer fix — senão o fix destrói a evidência.

## §6 Papéis (T3 — ADR-014)

IA: desenha corpus, normalizações, script de comparação, registros. Humano:
executa os dois motores, commita golden e resultados, assina hearbacks de
diffs justificados. IA nunca roda motor de produção nem commita no projeto.
