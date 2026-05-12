---
titulo: Coordenacao inter-IA
tipo: modulo-do-usehbn
papel: coexistencia segura de multiplas IAs operando o mesmo repositorio
audiencia: humano + ia
licenca: AGPLv3
---

# Coordenacao inter-IA

## O que e

Coordenacao inter-IA e o modulo do useHBN que permite **multiplas IAs
trabalharem sobre o mesmo repositorio sem colidir, perder contexto ou
gerar drift documental**. Define convencoes textuais (paths,
mensageria, locks, marcadores) que dispensam infraestrutura nova e
funcionam em qualquer projeto com filesystem versionado.

O modulo regula multiplas frentes concorrentes (sessoes Opus, Codex,
Antigravity, Gemini, Notebook LM) que operam sobre o mesmo
repositorio. A premissa central: **o operador (humano) e o tiebreaker
em qualquer conflito; as IAs nao tentam resolver entre si**.

## Os seis principios

| # | Principio | O que significa |
|---|---|---|
| 1 | **Particionamento por path** | Cada IA/frente e dona de um conjunto disjunto de paths; ninguem escreve fora do seu particionamento sem mensagem explicita |
| 2 | **Append-only em compartilhados** | Arquivos compartilhados so recebem adendos no fim, nunca edicao de secoes existentes |
| 3 | **Mensageria assincrona** | Comunicacao entre IAs vive em arquivos no repositorio (`.hbn/messages/`); sem reply sincrono obrigatorio |
| 4 | **Soft-lock pre-escrita** | Ao tocar arquivo critico compartilhado, criar arquivo de lock declarando intencao e ETA |
| 5 | **Pull antes de write** | Antes de qualquer escrita estrutural, releitura obrigatoria do INDEX do relay e das mensagens novas |
| 6 | **Operador e tiebreaker** | Em qualquer conflito, o operador decide; as frentes nao tentam resolver entre si |

## As quatro esteiras

| Esteira | Localizacao | Funcao | Append-only? |
|---|---|---|---|
| **Mensageria** | `.hbn/messages/` | comunicacao IA→IA | sim (cria arquivo, nunca edita) |
| **Locks** | `.hbn/locks/` | declaracao de intencao de escrita | nao (criado e removido pela mesma IA) |
| **Readbacks** | `.hbn/readbacks/` | output JSON de cada onda/microdelta com hashes de integridade | sim |
| **Results** | `.hbn/results/` | ERP (Execution Result Package) com decisoes, gates, microdeltas entregues | sim |

E um quinto, transversal: `.hbn/relay/INDEX.md` — hub de coordenacao
operacional, append-only por secao, com estado do bastao por frente.

## Particionamento canonico (exemplo vigente)

| Path | Frente proprietaria | Modo |
|---|---|---|
| `src/vba/` | Frente 1 (Credenciamento) | exclusivo |
| `local-ai/vba_import/` | Frente 1 | exclusivo |
| `auditoria/03_ondas/` | Frente 1 (ondas operacionais) | exclusivo |
| `usehbn/methodology/` | Frente 2 (useHBN) | exclusivo |
| `usehbn/radar/` | Frente 2 (Codex executa sob orquestracao) | exclusivo |
| `usehbn/modules/` | Frente 2 | exclusivo |
| `.hbn/messages/` | ambas | particionado por nome de arquivo |
| `.hbn/locks/` | ambas | particionado por nome de arquivo |
| `.hbn/relay/INDEX.md` | compartilhado | append-only por secao |

Particionamento e ajustado por consenso operador quando uma onda muda
de fase ou nova frente abre. Nunca decidido entre IAs sozinhas.

## Movimento — fluxo do bastao

```text
Frente N detem o bastao
   │
   ▼
produz readback (.hbn/readbacks/<id>.json)
   │
   ▼
emite ERP (.hbn/results/<id>.json) com hashes
   │
   ▼
atualiza relay/INDEX.md (secao append-only)
   │
   ▼
declara handoff (🔵 HBN HANDOFF READY)
   │
   ▼
Frente N+1 le INDEX + ultimas mensagens
   │
   ▼
confirma recepcao (mensagem em .hbn/messages/)
   │
   ▼
assume bastao
```

A simetria do handoff e protocolo: **declaracao do que esta pronto +
declaracao do que ainda precisa acontecer**. Sem simetria, fica
ambiguo se o sucessor pode prosseguir.

## Regra M11 — fonte de verdade vs espelho

M11 e o caso especifico do principio 1 com nome proprio. **Em VBA,
`src/vba/` e a fonte de verdade publica e `local-ai/vba_import/` e
o pacote-espelho com prefixos consumido pelo Importador V3. Nunca o
inverso.** Editar o espelho e propagar para a fonte fere a regra e
introduz drift G7.

M11 e materializada por:

- Gate G7 (Glasswing-style) que detecta drift via md5sum
- Pre-commit hook que bloqueia commit em VBA se G7 violado
- Cadeia de revisao: publish → checksum → gate → commit

Coordenacao inter-IA opera sob o principio de que regras com nome
proprio (M11, G7, G8) sao spec normativa, nao narrativa de incidente.
O texto da regra define o contrato; o historico fica em readbacks
quando pertinente.

## Filtros / Gates

| Gate | Pergunta-chave | Acao se violado |
|---|---|---|
| Pull antes de write | Li o INDEX e as mensagens novas desde meu ultimo ciclo? | nao escrever; ler primeiro |
| Particionamento | Este path e meu? | depositar mensagem; aguardar autorizacao |
| Soft-lock | Existe lock ativo neste arquivo? | aguardar ETA + 50% de margem; depois mensagem |
| Append-only | Estou alterando secao existente em arquivo compartilhado? | adicionar adendum no fim; nao reescrever |
| Regra dos 50% contexto | Estou acima de 40-45% de uso de contexto? | sinalizar 🟡 HBN CONTEXT FATIGUE INCOMING e preparar handoff |
| Simetria de handoff | Declarei o que esta pronto E o que ainda falta? | repor declaracao simetrica antes de liberar bastao |

## Cadencias operacionais

| Cadencia | Quando aplicar | Quem participa |
|---|---|---|
| **A — Opus solo** | tarefa pequena, contexto baixo, decisao tecnica direta | Opus |
| **C — scoping em chat N + implementacao em chat N+1** | MD grande, contexto incerto | Opus chat 1 (scope) → Opus chat 2 (impl) |
| **D — Codex implementador, Opus auditor** | MD critico com contexto Opus baixo | Codex (implementa) + Opus (audita) |
| **Cross-IA** | decisao arquitetural ou validacao de tom | Opus + Codex + Antigravity + Gemini (subset conforme caso) |

A escolha de cadencia e do operador. As IAs sugerem; ele decide.

## Marcadores

| Marcador | Quando aplica |
|---|---|
| 🔵 HBN HANDOFF READY | IA atual fechou seu escopo limpamente; sucessor pode assumir |
| 🟢 HBN CHECKPOINT CLEAN | onda/microdelta fechou com artefatos, gate e ERP consistentes |
| 🟠 HBN SOURCE DRIFT DETECTED | duas fontes declaradas canonicas divergem; bloqueia fechamento |
| ⚪ HBN AUDIT-ONLY | IA nao tem bastao executor; so escreve diagnostico/proposta |
| 🟡 HBN CONTEXT FATIGUE INCOMING | IA esta acima de 40-45% de uso de contexto; handoff iminente |
| 🌳 HBN MODULE BOUNDARY | decisao toca multiplos modulos do useHBN |

## Conexao com outros modulos

| Modulo | Relacao |
|---|---|
| Auditoria Cruzada | Roda sobre handoffs registrados; mensageria e canal de pedidos cruzados |
| Capsulas de Consentimento | Cada handoff significativo pode ser registrado como mini-capsula (lesson + evidence + consent) |
| Seguranca | Regra M11 e da mesma familia que G7+G8 (anti-drift); gates Glasswing rodam antes de fechamento |
| Marcadores | Estados do bastao tem markers especificos; cadencias usam markers de fadiga e checkpoint |
| Fagocitose | Cada fase F1-F5 pode ser executada por IAs diferentes; coordenacao mantem rastreabilidade |
| Radar | Mudancas de estado em fichas geram entrada no relay; e propostas atravessam mensageria |

## Como adotar Coordenacao inter-IA em outro projeto

Para replicar este modulo em projeto externo com 2+ IAs ativas:

1. Criar pasta `.hbn/` (ou equivalente) com subpastas: `messages/`,
   `locks/`, `readbacks/`, `results/`, `relay/`
2. Criar `relay/INDEX.md` com estado por frente; manter append-only
   por secao
3. Definir tabela de particionamento canonico — cada path tem dona
   declarada (frente, IA, modulo)
4. Adotar convencao de naming para mensagens (`AAAA-MM-DD_NN_de-X_para-Y.md`)
5. Adotar frontmatter minimo para mensagens (titulo, de, para, data,
   prioridade, resposta-em)
6. Definir politica de soft-lock (quando criar, quanto durar, como
   limpar orfaos)
7. Treinar IAs participantes para o protocolo "pull antes de write"
8. Estabelecer operador humano como tiebreaker explicito — sem isso,
   as IAs eventualmente vao tentar negociar entre si e o protocolo
   degrada
9. Cross-link com modulo `MARCADORES` para usar markers de bastao
   (🔵 🟢 🟠 ⚪ 🟡)
10. Considerar regra dos 50% contexto: nenhuma IA opera acima desse
    limite sem sinalizacao explicita de fadiga

A coordenacao e leve em infraestrutura mas exige disciplina cultural.
A maior parte das regressoes vem de IA "esquecendo" de fazer pull
antes de write, ou tentando resolver conflito sozinha sem escalar
para o operador.

## Ferramental futuro (CLI hbn)

Comandos planejados para Wave 11+ que materializarao convencoes:

| Comando | Funcao |
|---|---|
| `hbn baton status` | dono do bastao, modo, proxima acao, bloqueios |
| `hbn frente status` | frentes ativas, particionamento vigente, locks |
| `hbn message send --to <frente> --priority <nivel>` | cria mensagem com nome correto |
| `hbn lock acquire --file <path> --eta <minutos>` | cria soft-lock |
| `hbn lock release --file <path>` | remove lock |
| `hbn coexist check --before-write <path>` | pre-check de conflito |

Ate la, tudo manual — mas com convencao forte, overhead baixo.

## Estado vivo

Mantido em [.hbn/relay/INDEX.md](../../.hbn/relay/INDEX.md).
Atualizado a cada handoff.
