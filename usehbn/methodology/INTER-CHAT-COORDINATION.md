---
titulo: Protocolo de Coordenação Inter-Chat — múltiplas IAs Opus em paralelo
diataxis: reference
hbn-track: knowledge
hbn-status: active
audiencia: ia
versao-protocolo: usehbn 0.4.0 (proposta)
data: 2026-05-02
autor: Claude Opus 4.7 (Frente 2 — usehbn)
licenca-target: usehbn (AGPLv3)
revisar-em: a cada nova frente paralela aberta
---

# Protocolo de Coordenação Inter-Chat

## Problema

O ecossistema useHBN/Credenciamento opera em 2026-05-02 com **duas
sessões Cowork (Claude Opus 4.7) abertas em paralelo**:

- **Frente 1 — Credenciamento**: foco em fechar V12.0.0203-rc1 (Onda 11
  microdeltas MD-3/MD-4/MD-5 + tag git).
- **Frente 2 — usehbn**: foco em bootstrap do `hbn-phago` (esta frente
  é arquiteto + validador; Codex é executor de código).

Ambas leem e escrevem o mesmo repositório (`/Users/macbookpro/Projetos/Credenciamento/`).
Sem protocolo, há risco de:

- Edição concorrente do mesmo arquivo → conflito git
- Duplicação de informação em paths distintos
- Perda de contexto sobre quem fez o quê
- Drift documental (G7 conceitual)

Este documento é o protocolo minimal viable para coexistência segura.
Sem infraestrutura nova: usa apenas convenção de paths + mensagens
em arquivos.

## Princípios

1. **Particionamento por path** — cada frente é dona de um conjunto disjunto de paths.
2. **Append-only em compartilhados** — arquivos compartilhados só recebem adendos no fim, nunca edição de seções existentes.
3. **Mensageria assíncrona** — comunicação entre chats vive em `.hbn/messages/`, sem reply síncrono obrigatório.
4. **Soft-lock pré-escrita** — ao tocar arquivo crítico compartilhado, criar arquivo de lock declarando intenção e ETA.
5. **Pull antes de write** — antes de qualquer escrita estrutural, releitura obrigatória de `.hbn/relay/INDEX.md`.
6. **Operador é tiebreaker** — em qualquer conflito, Maurício decide. As frentes não tentam resolver entre si.

## Particionamento canônico de paths (vigente 2026-05-02)

| Path | Frente proprietária | Modo |
|---|---|---|
| `src/vba/` | F1 | exclusivo |
| `local-ai/vba_import/` | F1 | exclusivo |
| `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` | F1 | exclusivo (até MD-5 fechar) |
| `usehbn/docs/INTEGRATION-VBA-IMPORTER.md` | F1 | exclusivo |
| `auditoria/03_ondas/onda_11_*/` | F1 | exclusivo |
| `auditoria/04_evidencias/V12.0.0203/` | F1 | exclusivo |
| `.hbn/readbacks/0011-*.json` | F1 | exclusivo |
| `.hbn/results/0011-*.json` | F1 | exclusivo |
| `auditoria/00_status/` (numeração 33-37) | F1 | exclusivo |
| `App_Release.bas`, `CHANGELOG.md` | F1 | exclusivo |
| `usehbn/methodology/` | F2 | exclusivo |
| `usehbn/radar/` | F2 (Codex escreve sob orquestração F2) | exclusivo |
| `usehbn/constitution/` | F2 (Sprint 1+) | exclusivo |
| `local-ai/Time_AI/2026-05-02-V203-fechamento/3*.md` | F2 | exclusivo |
| `local-ai/Time_AI/codex-erps/` | F2 (Codex escreve, F2 valida) | exclusivo |
| `.hbn/messages/` | ambas (cada uma escreve seus arquivos) | particionado por nome de arquivo |
| `.hbn/locks/` | ambas | particionado por nome de arquivo |
| `auditoria/00_status/` (numeração 38-42) | F2 | exclusivo |
| Repo externo `~/Projetos/usehbn-phago/` | F2 + Codex | exclusivo do ecossistema F2 |
| `.hbn/relay/INDEX.md` | compartilhado | append-only por seção |
| `.hbn/knowledge/0010+.md` | F2 | exclusivo |
| `.hbn/knowledge/0001-0009.md` | F1 (já existentes) | apenas leitura para F2 |

## Mensageria assíncrona

### Localização

`.hbn/messages/`

### Convenção de nome

`AAAA-MM-DD_NN_de-frenteN_para-frenteN.md`

- `AAAA-MM-DD` = data ISO
- `NN` = sequência no dia (01, 02, 03...)
- `de-frenteN` = origem
- `para-frenteN` = destino (use `para-todos` para broadcast; use `para-codex` ou `para-opus` para mensagens dentro do ping-pong)

Exemplos:
- `2026-05-02_01_de-frente2_para-frente1.md`
- `2026-05-02_02_de-frente1_para-frente2.md`
- `2026-05-03_01_de-codex_para-opus.md`

### Frontmatter mínimo

```yaml
---
titulo: <descrição curta>
de: <chat/IA emissor>
para: <chat/IA destinatário>
data: AAAA-MM-DD
hbn-track: knowledge | safe_track | fast_track
audiencia: ia
prioridade: informativa | bloqueante | urgente
resposta-em: <path da resposta esperada, se aplicável>
---
```

### Regras

- Mensagem é **append-only**: criada uma vez, nunca editada.
- Resposta é **outra mensagem**, com link para a original.
- Sem garantia de leitura imediata — frente lê quando puder.
- Operador pode ler todas as mensagens e copiar conteúdo entre chats
  se quiser acelerar comunicação.
- Mensagens **bloqueantes** devem ser claramente marcadas com
  `prioridade: bloqueante` no frontmatter — frente destinatária
  deve ler antes de prosseguir com escritas estruturais.

## Soft-locks

### Quando usar

Antes de tocar arquivo crítico compartilhado (raríssimo no protocolo
atual, pois particionamento é forte). Exemplo: edição estrutural em
`.hbn/relay/INDEX.md` que vá além de append.

### Como criar

Arquivo em `.hbn/locks/<path-sanitizado>.lock` com:

```yaml
---
arquivo-alvo: <path completo>
frente: F1 | F2 | codex
adquirido-em: AAAA-MM-DD HH:MM:SS BRT
eta-minutos: <número>
operacao: <descrição curta>
release-criterio: <quando o lock será removido>
---
```

### Como respeitar

- Frente que vê lock existente:
  1. Aguarda até ETA + 50% margem
  2. Se ETA expirou, deposita mensagem perguntando se ainda está em uso
  3. Se sem resposta após 30min, escala para o operador

### Limpeza

Lock é removido pela frente que o criou ao concluir. Locks órfãos com
mais de 24h são removidos pela próxima frente que os encontrar
(com nota em `.hbn/messages/`).

## Append-only em compartilhados — regras práticas

### `.hbn/relay/INDEX.md`

- F1 mantém topo + seções existentes.
- F2 adiciona seção `## Frente 2 — usehbn / Sprint <N>` no final do arquivo.
- Renomeação de seções existentes só por consenso operador.

### `.hbn/knowledge/`

- Cada frente cria arquivos novos com numeração próxima ao seu range.
- F1: 0001-0009 (já existentes).
- F2: 0010+ (novos).
- Edição de arquivo existente sempre via append no fim, com cabeçalho `## YYYY-MM-DD addendum (Frente N)`.

## Pull antes de write

Antes de qualquer escrita estrutural, releitura obrigatória de:

1. `.hbn/relay/INDEX.md` (estado do bastão por frente)
2. Mensagens novas em `.hbn/messages/` desde último ciclo
3. Locks ativos em `.hbn/locks/`

Se algum item indicar atividade conflitante, **não escreve**: deposita
mensagem perguntando ou aguarda lock liberar.

## Hooks para o futuro

Quando a CLI `hbn` for implementada (Wave 11+), os comandos abaixo
materializarão este protocolo:

| Comando | Função |
|---|---|
| `hbn frente status` | Mostra todas as frentes ativas, dono de cada path, locks vigentes |
| `hbn message send --to F1 --priority informativa` | Cria mensagem com nome correto |
| `hbn lock acquire --file <path> --eta 30` | Cria soft-lock |
| `hbn lock release --file <path>` | Remove lock |
| `hbn coexist check --before-write <path>` | Pré-check de conflito (G6 estendido) |

Até lá, tudo é manual — mas com convenção forte, baixo overhead.

## Versão

- v1.0 — 2026-05-02 — protocolo inicial para coexistência F1↔F2 a partir
  da abertura simultânea de duas sessões Cowork sobre o mesmo repo.
