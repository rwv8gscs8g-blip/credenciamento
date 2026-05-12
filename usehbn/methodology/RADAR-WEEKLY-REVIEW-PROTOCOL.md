---
titulo: Protocolo de Revisão Semanal do Radar useHBN
diataxis: how-to
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-02
autor: Claude Opus 4.7 (Frente 2 — usehbn)
licenca-target: usehbn (AGPLv3)
revisar-em: após primeira revisão semanal real (2026-05-06)
---

# Protocolo de Revisão Semanal do Radar useHBN

## Princípio

Tecnologias no radar precisam de **acompanhamento ativo** ou viram zumbi documental — fichas que ninguém lê, com info desatualizada, sem decisão.

Revisão semanal **leve mas regular** mantém o radar vivo. Frequência baixa demais (mensal) deixa coisa apodrecer; alta demais (diária) gera ruído e fadiga.

## Frequência

**Toda quarta-feira às 11:45 BRT**, 15 minutos antes da renovação do pacote Claude Opus de Maurício. Janela curta intencional — força síntese, evita análise infinita.

## Quem executa

| Período | Executor | Mecanismo |
|---|---|---|
| Hoje até Wave 11+ | Manual: Opus + Maurício no chat | Opus produz checklist; Maurício decide; Opus deposita addendum em WEEKLY-UPDATES.md |
| Pós Wave 11+ | Comando `hbn weekly-review` na CLI | Automação agendada; PR draft com addendum; humano aprova merge |

## Checklist por semana

### 1. Fichas com `proxima-revisao` vencida ou próxima (≤7 dias)

- Listar slugs em atraso ou próximos do prazo
- Para cada uma: verificar se há mudança real desde última revisão (release novo, security advisory, abandono do mantenedor, paper acadêmico relevante)
- Atualizar `ultima-revisao` no frontmatter com nota do que mudou (ou "sem mudanças relevantes")
- Recolocar `proxima-revisao` conforme cadência sugerida pelo estado:
  - `in-radar`: trimestral
  - `under-analysis`: mensal
  - `convergence-mapped`: trimestral
  - `candidate`: mensal
  - `phagocytosed`: gerido fora (Camadas 1-8)
  - `archived`: anual

### 2. Tecnologias em `under-analysis` há mais de 90 dias sem progresso

- Decisão forçada: avançar para `convergence-mapped` OU regredir para `in-radar` OU arquivar
- Sem decisão = inércia → arquivar com motivo "análise estagnada"

### 3. Tecnologias em `in-radar` há mais de 180 dias sem nenhuma evidência adicional

- Sinal de que entrou no radar mas perdeu relevância
- Decisão: arquivar OU adicionar evidência nova com justificativa de mantença

### 4. Mudanças relevantes detectadas em fontes externas

Para cada tecnologia ativa, verificar (manual hoje; automação RSS/atom feeds depois):
- Repositório GitHub: novos releases, mudança de licença, abandono (último commit > 6 meses)
- Security advisories (CVE, GHSA)
- Mudança de mantenedor / aquisição corporativa
- Novos casos de uso publicados ou comparativos relevantes

### 5. Tecnologias `phagocytosed` que deveriam ser deprecadas

- Verificar se o uso real continua ou se foi substituída
- Marcar `archived` com motivo se substituída

### 6. Decisões pendentes para Maurício

- Listar transições propostas que precisam de aprovação humana
- Marker `🟡 HBN NEEDS HUMAN DECISION` no addendum

## Output esperado por semana

Addendum em `usehbn/radar/WEEKLY-UPDATES.md` seguindo o template definido lá. Markers V2 obrigatórios:

- `⚪ HBN AUDIT-ONLY` — revisão é leitura, sem edição estrutural
- `🟡 HBN NEEDS HUMAN DECISION` — se houver transições propostas
- `🟢 HBN CHECKPOINT CLEAN` — semana sem atraso e sem decisões pendentes
- `🔵 HBN HANDOFF READY` — fim da revisão, Opus devolve bastão para Maurício

## Hooks de automação (Wave 11+)

Comandos `hbn` previstos:

| Comando | Função |
|---|---|
| `hbn radar overdue` | Lista fichas com `proxima-revisao` vencida |
| `hbn radar stale --days 90` | Lista fichas em `under-analysis` há mais de N dias |
| `hbn radar check-upstream` | Para cada ficha, busca último release no GitHub e compara com `ultima-revisao` |
| `hbn weekly-review --dry-run` | Simula revisão sem escrever; mostra preview do addendum |
| `hbn weekly-review --commit` | Roda revisão completa, escreve addendum, abre PR draft |

## Política de "tirar do radar"

Maurício pediu (mensagem 2026-05-02): "depois da leitura algumas iremos tirar do radar provisoriamente, focando nos pontos principais".

**Tirar do radar = transição para `archived` com motivo `foco-estrategico-temporario`**.

Reentrada permitida a qualquer momento se contexto mudar. Addendum semanal sempre lista `archived` recentes para mantê-las visíveis (não somem do mapa mental).

Sugestões de arquivamento estratégico por categoria estão no addendum 2026-05-02 do WEEKLY-UPDATES.md (decisão #1 pendente para Maurício).

## Versão

- v1.0 — 2026-05-02 — protocolo inicial após pedido explícito de acompanhamento semanal.
