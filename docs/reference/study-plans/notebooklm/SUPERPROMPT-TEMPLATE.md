---
titulo: Template Superprompt para Notebook LM — uso geral
diataxis: how-to
hbn-track: knowledge
hbn-status: active
audiencia: humano
data: 2026-05-02
licenca-target: usehbn (AGPLv3)
---

# Template Superprompt para Notebook LM

## O que é Notebook LM e como usar

[Notebook LM](https://notebooklm.google.com/) é a ferramenta da Google que ingere fontes (PDFs, links, texto colado) e gera:
- **Audio Overviews** (podcasts no formato "Deep Dive" — 2 hosts conversando, ~25-40 min)
- **Briefing documents** estruturados
- **Mind maps**
- **Notes** organizadas
- **Q&A** baseado nas fontes

Cada Notebook é um workspace com fontes específicas. Pode ter até 50 fontes por notebook (varia por plano).

## Anatomia de um superprompt para Notebook LM

Diferente de um prompt direto a LLM, com Notebook LM você:

1. **Cria um notebook** com tema específico
2. **Faz upload das fontes** (PDFs baixados, links, texto colado)
3. **Cola o superprompt** no chat do notebook como instrução de personalização
4. **Solicita os outputs desejados** (Audio Overview, Briefing, etc.)

O superprompt instrui o Notebook LM sobre:
- Quem é a audiência (você + o useHBN)
- Quais perguntas devem guiar a análise
- Que tom adotar
- Quais conexões fazer entre fontes
- Que profundidade técnica buscar

## Estrutura padrão de superprompt useHBN

Cada superprompt nesta pasta segue esta estrutura:

```markdown
# Superprompt para Notebook LM — <Tecnologia X>

## Contexto a fornecer ao Notebook LM
(cole isso na primeira mensagem do chat após criar o notebook)

[parágrafo sobre useHBN]
[parágrafo sobre por que estuda esta tecnologia]
[parágrafo sobre os 10 princípios constitucionais]
[parágrafo sobre o caso real do Credenciamento]

## Fontes a fazer upload
(baixe/cole estas fontes no notebook)

### Fontes obrigatórias
- [PDF/Link 1] — descrição
- [PDF/Link 2] — descrição
- ...

### Fontes complementares (escolher 2-3)
- [PDF/Link X] — descrição
- ...

## Perguntas que o Notebook LM deve endereçar
(cole após upload das fontes — ajuda guiar Audio Overview e Briefing)

1. [Pergunta fundamental 1]
2. [Pergunta fundamental 2]
...

## Outputs solicitados
- [ ] Audio Overview (Deep Dive) — 25-40 min
- [ ] Briefing document
- [ ] Mind map
- [ ] FAQ

## Persona de audiência
(opcional — Notebook LM aceita personalização do tom)

"Audiência: arquiteto de software técnico construindo protocolo de evolução de tecnologias legadas. Tom: técnico mas acessível, com analogias quando útil. Foco em decisões arquiteturais, tradeoffs e implicações de longo prazo, não em tutoriais step-by-step."
```

## Como copiar/colar para Notebook LM

### Passo 1: Criar notebook
- Acesse https://notebooklm.google.com/
- Click em "+ New notebook"
- Nomeie como "useHBN — <Tecnologia>"

### Passo 2: Upload de fontes
- Click "Add source"
- Para cada fonte da lista do superprompt:
  - URL? Cole link
  - PDF? Faça upload do arquivo
  - Texto? Cole no campo "Paste text"
- Aguarde indexação (geralmente 1-2 min para fontes grandes)

### Passo 3: Personalização (Customize)
- No painel do notebook, procure "Customize" ou similar
- Cole o "Contexto a fornecer ao Notebook LM" aí

### Passo 4: Gerar Audio Overview
- No painel direito (Studio), click "Audio Overview" → "Customize"
- Cole as "Perguntas que o Notebook LM deve endereçar"
- Adicione persona se desejar
- Click "Generate"

### Passo 5: Gerar outputs adicionais
- Briefing document: clique no botão correspondente
- Mind map: idem
- FAQ: idem

## Boas práticas

### Para podcast de qualidade

- **Não inunde com fontes** — 5-10 fontes bem escolhidas > 50 fontes superficiais
- **Inclua contexto institucional** — Notebook LM produz melhor quando entende propósito
- **Indique conflitos esperados** — "Fonte A diz X, fonte B diz Y, queremos discussão"
- **Defina audiência** — muda dramaticamente o tom

### Para briefings úteis

- **Liste perguntas concretas** — Notebook LM responde estruturalmente
- **Solicite estrutura específica** — "Resumo executivo + 3 seções: O Quê / Por Quê / Como"

### Limites a conhecer

- Notebook LM **não cita fontes externas** que não foram uploadeadas
- Pode confabular ocasionalmente (mas menos que LLMs gerais — fontes constrange)
- Audio Overviews têm vieses dos hosts virtuais (otimistas demais às vezes)
- Limite de tokens por notebook (~25M em planos pagos)

## Padrões úteis para diferentes tipos de aprendizagem

### Imersão técnica profunda
- 8-10 fontes oficiais (docs, specs, código)
- 2-3 fontes secundárias (vídeos, blogs)
- Audio Overview com persona "engenheiro sênior"
- Perguntas focadas em internals e tradeoffs

### Visão de mercado
- 3-5 fontes do produto
- 5-8 comparativos e análises
- Audio Overview persona "analista de tecnologia"
- Perguntas focadas em adoção, vendor risk, alternativas

### Aprendizagem conceitual (acadêmica)
- 1-2 papers seminais
- 2-3 livros (capítulos relevantes em PDF)
- Audio Overview persona "estudante de pós-graduação"
- Perguntas focadas em fundamentos e história

## Versão

- v1.0 — 2026-05-02 — template inicial.
