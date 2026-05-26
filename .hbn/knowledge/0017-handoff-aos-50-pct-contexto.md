---
titulo: Handoff aos 50% de contexto — orçamento obrigatório de qualidade
data: 2026-05-26
autoria: claude-opus-4-7 (sessão de evolução manual pós-Onda 38.2.1-AR1-FIX2-PERF)
aplica-a: Toda IA que opere em sessão longa sujeita a limite de contexto (Opus, Codex, Gemini, Cursor, qualquer)
revisar-em: 2026-08-26
---

# Handoff aos 50% de contexto

## Regra

A IA **inicia o protocolo de fim-de-sessão** (knowledge 0014 + §7 do
`PROMPT_ARQUITETO_USEHBN_AUTONOMO.md`) quando o contexto consumido cruza
**~50%**. Não esperar fadiga, não esperar 70%, não esperar 90%. **50% é
o gatilho duro.**

A motivação: a qualidade de análise, escrita e decisão da IA degrada
de forma não-linear na segunda metade do contexto. Decisões tomadas com
70%+ de contexto consumido têm taxa observada de retrabalho mais alta
que decisões tomadas com folga, e o **próprio handoff sofre** quando é
escrito sob pressão de fim de janela.

## Orçamento sugerido de uma sessão (50/30/20)

Após o handoff iniciado aos 50%, a sessão se distribui assim:

| Fatia | Uso | Por quê |
|---|---|---|
| **~50% inicial** | Trabalho substantivo da onda (análise, escrita de código no scope, deep-dive, entrega de prompts a Mauricio, consolidação de propostas externas) | Janela de máxima clareza |
| **~30% subsequente** | Redação dos 3 artefatos de handoff: (1) `.hbn/messages/AAAAMMDD-HHmm-handoff-fim-sessao-<agente>.md` (12 itens, knowledge 0014), (2) `auditoria/00_status/NNN_PROMPT_RETOMADA_SESSAO_<AGENTE>.md`, (3) `.hbn/protocol-evolutions/AAAAMMDD-HHmm-onda<N>-proposals.md` (§7.3 do PROMPT_ARQUITETO v1.3+) | Handoff precisa de contexto disponível para qualidade |
| **~20% buffer** | Ajuste último-minuto pedido por Mauricio em chat, correção de inconsistência detectada no auto-review final | Sempre sobra demanda imprevista; reservar margem |

Quem termina a sessão com 90%+ de contexto consumido **não cumpriu o
protocolo** — produziu trabalho substantivo a mais do que cabia naquela
janela, e o handoff resultante é, em algum grau, comprometido.

## Gatilhos secundários (qualquer um adianta o handoff)

Além do 50% nominal, o handoff pode ser disparado antes por:

1. Operador pede explicitamente: "stop", "fim de sessão", "save state",
   "vamos pausar", "vamos retomar amanhã".
2. Contagem de turnos > 30 (heurística simples — knowledge 0014).
3. Transferência de bastão entre agentes (Codex → Opus, Opus → Codex).
4. Final natural de onda safe_track após ERP fechado (mesmo com contexto
   sobrando — knowledge 0014).
5. Bloqueio externo prolongado (ex.: aguardando hearback que não chega
   em janela útil) — fechar a sessão é mais barato que mantê-la viva
   consumindo memória sem progresso.

## Auto-medição honesta do contexto

Limitações: nem toda IA tem leitura precisa do próprio consumo de
contexto. Heurísticas operacionais aceitas como proxy:

- **Token usage estimado > 50% do contexto da IA** (knowledge 0014,
  gatilho 3) — calibrado a partir do limite da modelagem da IA em uso.
- **Contagem de turnos > 30** (knowledge 0014, gatilho 2) — heurística
  simples, conservadora.
- **Sensação de "começar a esquecer coisas" ou ter que re-ler o que
  acabou de escrever** — sinal subjetivo mas confiável; quando aparece,
  já passou de 50%, dispare o handoff.
- **Re-perguntar ao operador algo que está no início do chat** — sinal
  duro de saturação; handoff imediato.

Na dúvida entre "ainda dá tempo" e "agora", escolher **agora**. Custo
de handoff antecipado é baixo (sucessor herda contexto rico); custo de
handoff atrasado é alto (sucessor herda contexto pobre e fricção
operacional).

## Cláusula de exceção (não inverter a regra)

Há cenários onde 50% é cedo demais para handoff e o trabalho substantivo
ainda não chegou a ponto de fechamento mínimo. Nesse caso:

1. **Documentar a exceção** no próprio handoff (campo "## 1. Onda em
   curso" do schema knowledge 0014) com 1 linha explicando por que o
   handoff foi adiado para X% > 50%.
2. **Aceitar a degradação** como custo conhecido — não justificar como
   "estava tudo sob controle".
3. **Capturar a lição** em `.hbn/protocol-evolutions/` (§7.3) com
   proposta concreta para evitar o mesmo dilema na próxima sessão
   (geralmente: melhor escopo de onda, melhor pré-flight, melhor
   delegação a sessões paralelas).

Exceções repetidas indicam que o protocolo precisa evoluir, não que a
regra precisa ser frouxa.

## Como o sucessor consome esta knowledge

O sucessor, ao abrir sessão nova com base no prompt de retomada
(`auditoria/00_status/NNN_PROMPT_RETOMADA_SESSAO_<AGENTE>.md`), lê esta
knowledge **junto com 0014 e 0015** e:

1. Internaliza o gatilho dos 50% antes de começar o trabalho.
2. Reserva o orçamento 50/30/20 mentalmente.
3. Cria checkpoints próprios: a cada turno significativo, perguntar-se
   "estou na primeira metade do contexto?" — se não, fim-de-sessão imediato.
4. Aceita que terminar uma onda em sessão fresca de 60% disponível é
   melhor do que esticar a sessão atual.

## Origem desta regra

- Lição registrada por Mauricio em chat 2026-05-26 pós-handoff
  `20260526-1118-handoff-fim-sessao-opus.md` (Onda 38.2.1-AR1-FIX2-PERF):
  *"deveríamos ter feito o handoff com 50% do contexto para não sobrecarregar
  e prejudicar sua capacidade de análise e entrega"*.
- A sessão fechou a ~90% de contexto, produziu o handoff sob pressão,
  e o handoff resultante teve inconsistências detectadas posteriormente
  (ex.: referência a `107_PROMPT_RETOMADA_SESSAO_OPUS.md` enquanto o
  arquivo real é `108_*` — o `107_` já estava tomado por
  `107_SUPERPROMPT_CODEX_RETOMADA_ONDA_38_PDF.md`). Exemplo concreto do
  custo de handoff tardio.
- Sessão de evolução manual 2026-05-26 (pós-handoff) formalizou:
  - PROMPT_ARQUITETO_USEHBN_AUTONOMO v1.3 §7.3 (auto-evolução por handoff)
  - Knowledge 0017 (esta — handoff aos 50%)

## Como verificar

Antes de uma sessão nova começar trabalho substantivo:

```
grep -E "50%|0017" auditoria/00_status/*_PROMPT_RETOMADA_*.md | head -5
```

Esperado: pelo menos uma menção explícita ao gatilho dos 50% e/ou a
esta knowledge no prompt de retomada vigente. Se ausente, atualizar
o prompt de retomada na próxima onda safe_track de protocolo.

Durante uma sessão em andamento, ao perceber qualquer dos sinais
subjetivos de saturação (esquecimento, re-leitura, re-pergunta),
interromper o trabalho substantivo no próximo ponto seguro e iniciar
o §7 do PROMPT_ARQUITETO.

## Lições paralelas relevantes

- [`0014-protocolo-fim-de-sessao.md`](0014-protocolo-fim-de-sessao.md) — schema dos 12 itens do handoff
- [`0015-readback-opening-bootstrap.md`](0015-readback-opening-bootstrap.md) — bootstrap de readback sem burlar guard
- [`0016-bump-build-label-anti-conflito.md`](0016-bump-build-label-anti-conflito.md) — anti-padrão de pré-set
- `/Users/macbookpro/Projetos/PROMPT_ARQUITETO_USEHBN_AUTONOMO.md` §7 + §7.3 (v1.3+) — protocolo completo + auto-evolução

## Onda de origem

Sessão de evolução manual 2026-05-26 pós-handoff 0108 da Onda
38.2.1-AR1-FIX2-PERF. Mauricio autorizou explicitamente a evolução
manual do PROMPT_ARQUITETO + criação desta knowledge porque "todas as
IAs estão paradas aguardando" e o momento era adequado para um ciclo
de manutenção do protocolo. Próxima onda safe_track no Credenciamento
deve consolidar esta knowledge no INDEX.md e referenciá-la nos demais
prompts de retomada futuros.
