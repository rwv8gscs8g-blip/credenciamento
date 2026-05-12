---
titulo: Princípio do Minimalismo de Cadeia — filtro operacional para adoção de tecnologias
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-06
autor: articulado por Luís Maurício Junqueira Zanin (hearback Typer 2026-05-06); formalizado por Claude Opus 4.7 (Frente 2)
licenca-target: usehbn (AGPLv3)
status-protocolo: princípio operacional vigente; candidato a P11 constitucional na próxima revisão da tese 38
revisar-em: cada decisão de arquivamento por motivo "minimalismo"
marcador: 🟦
---

# Princípio do Minimalismo de Cadeia

## Declaração

Tecnologias adotadas pelo useHBN **minimizam dependências transitivas**, **preferem código compilado e otimizado** sobre conveniência ergonômica, e **não capturam responsabilidades de interface estética** — que serão mediadas pelas IAs consumidoras do output.

## Origem — articulação operacional de Maurício

Em 2026-05-06, após estudo profundo de Typer via Notebook LM, Maurício articulou a seguinte filosofia operacional como justificativa para arquivar Typer:

> "O risco de dependências é grande e a queda de performance pode ser concreta em sistemas concretos. Desenvolvedores puristas desistiriam de usar o useHBN pelo simples preconceito de estar acumulando dependências. A ideia é retirar dependências e compilar. Enquanto Tree-sitter trabalhar com Rust e código otimizado, Typer pode virar uma caixa de pandora. As próprias IAs vão entregar tecnologia e visualização rica sem os custos de colocar isso no projeto. As IAs vão ler código puro, não precisam de coisas ricas. Logo, limpar o ambiente e focar em melhorias incrementais sucessivas, mesmo nos microssegundos, será fundamental para a sustentação da tecnologia. Precisamos de uma base sólida, robusta, auditável, sem perdas estéticas que farão a saída ao usuário final ser mediada pela própria IA como interface, não precisando isso no terminal."

Este documento captura essa filosofia como **princípio operacional** vigente — filtro adicional aplicado a toda decisão de adoção de tecnologia daqui em diante.

## Formulação canônica

> **Princípio do Minimalismo de Cadeia**: tecnologias adotadas pelo useHBN devem **minimizar a cadeia transitiva de dependências**, **preferir código compilado e otimizado** sobre conveniência ergonômica, e **não capturar responsabilidades de interface estética** — que serão mediadas pelas IAs consumidoras do output.

## Quatro axiomas derivados

### Axioma 1 — Cadeia curta vence ergonomia

Entre duas tecnologias funcionalmente equivalentes, prefira a com menor número de dependências transitivas, mesmo que a outra tenha API mais agradável. Cada dependência transitiva é dívida futura: atualização, vulnerabilidade, abandono.

### Axioma 2 — Compilado vence interpretado, quando possível

Tecnologias escritas em Rust, Go, C++ otimizado têm vantagem sobre puramente interpretadas — não pelo benchmark único, mas pelo **acúmulo de microssegundos** ao longo de operações repetidas. Em sistema concreto, microssegundos viram segundos viram minutos.

### Axioma 3 — IA é a camada estética

Output do useHBN no terminal pode (deve) ser **cru, estruturado, auditável** — sem cores, tabelas Rich, animações. A camada estética é responsabilidade da IA que consome o output (Claude, Codex, Gemini, futuros agentes). Carregar bibliotecas de UI dentro do projeto é **redundante** e adiciona dívida sem benefício para o público real (IAs).

### Axioma 4 — Devs puristas são audiência crítica

A primeira onda de adopters do useHBN será de **desenvolvedores que se importam com cadeia de dependências**. Aceitar dependências por conveniência alienará essa audiência por **preconceito legítimo** (não irracional). Manter footprint mínimo é decisão de marketing tanto quanto técnica.

## Aplicação prática

### Pergunta de filtro para qualquer tecnologia candidata

Antes de promover qualquer tecnologia de `under-analysis` para `convergence-mapped`, responda:

1. **Quantas dependências transitivas?** Se > 3, justificar caso a caso.
2. **A tecnologia é compilada (Rust/Go/C) ou puramente interpretada?** Compilada é sinal positivo.
3. **A tecnologia trafega responsabilidade de interface estética para o projeto?** Se sim (cores, tabelas, progress bars), sinal de alerta.
4. **Existe alternativa zero-deps ou stdlib?** Se sim, exigir comparativo objetivo.
5. **Devs puristas reagiriam mal?** Se sim, considerar custo de marketing.

### Decisão exemplar — Typer (arquivada 2026-05-06)

| Critério | Typer | Resultado |
|---|---|---|
| Dependências transitivas | 7 (Click + typing-extensions + Rich + markdown-it-py + mdurl + pygments + shellingham) | ❌ alto |
| Compilada? | Não — Python puro sobre Click (Python puro) | ❌ |
| Captura interface estética? | Sim — Rich integrado para tabelas, cores | ❌ |
| Alternativa zero-deps? | Sim — argparse (stdlib) ou Click puro (1 dep BSD-3, zero transitivas) | ❌ alternativa existe |
| Reação devs puristas? | "Mais 25 MB para parsear linha de comando? Sério?" | ❌ negativa |

**Decisão**: ARQUIVADA. Para CLI hbn, voltar a Click puro ou argparse. Decisão final no prompt unificado ao Codex.

### Decisão exemplar — Tree-sitter (em análise)

| Critério | Tree-sitter | Resultado |
|---|---|---|
| Dependências transitivas | 0 (runtime C standalone; bindings Python finos) | ✅ baixo |
| Compilada? | Sim — runtime C; gramáticas compiladas para C | ✅ |
| Captura interface estética? | Não — produz AST/CST, formato cru estruturado | ✅ |
| Alternativa zero-deps? | Regex stdlib é alternativa, mas qualidade muito inferior | ✅ ganho técnico justifica |
| Reação devs puristas? | "Parser real em C? Com error recovery? Excelente." | ✅ positiva |

**Decisão**: aguardando conclusão da análise das 4 outras + prompt unificado.

## Conexão com os 10 princípios constitucionais existentes

O Minimalismo de Cadeia **reforça** vários princípios existentes:

| Princípio existente | Como Minimalismo de Cadeia reforça |
|---|---|
| **P9 — Frameworks descartáveis** | Cadeia curta = exit barrato; cadeia longa = lock-in de fato (mesmo se licença permitir) |
| **P8 — Protocolo > ferramenta** | Output cru estruturado é **protocolo**; output formatado é **ferramenta** |
| **P10 — Segurança e não-regressão > velocidade** | Menos dependências = menor superfície de ataque; código compilado = menos surpresas em runtime |
| **P3 — Testar antes de refatorar** | Footprint pequeno facilita testes determinísticos |
| **P4 — Explicar antes de automatizar** | Output cru pede explicação humana; rich UI pode esconder o que fez |

## Casos onde se aplica

- Adoção de bibliotecas externas em qualquer árvore
- Escolha de framework para CLI, parsing, observabilidade, etc.
- Avaliação de propostas que aumentem footprint do projeto
- Filtro padrão na transição `convergence-mapped` → `candidate`

## Lê com

- Substrato Sólido (qualidade intrínseca do código próprio)
- IA como Camada (justifica delegar interface à IA)
- Modelo das Três Árvores (filtros mais rigorosos na Estável)

## Possível promoção a P11 constitucional

Atualmente este é princípio **operacional** (vigente, filtro de decisão). Para virar **constitucional** (parte dos 10 princípios), precisa:

1. **3+ aplicações documentadas** em decisões reais (Typer arquivada é a primeira; precisamos de 2 mais)
2. **Adendo formal à tese 38** com voto explícito de Maurício
3. **Incorporação à constituição do `usehbn-phago`** (PRINCIPLES.md)

Por enquanto, fica como princípio operacional vigente registrado neste documento + nota explícita em cada arquivamento por motivo "minimalismo".

## Sinais de alerta para revisão deste princípio

O Princípio do Minimalismo de Cadeia deveria ser revisado se:

- IAs pararem de ser camada de interface (improvável, mas possível)
- Custo de microssegundos for empiricamente refutado em casos do useHBN
- Devs puristas mostrarem-se irrelevantes como audiência (vs adoção mainstream)
- Surgir tecnologia híbrida que oferece UI rica via opt-in zero-deps quando desativada

## Marcador HBN V2 derivado (proposta)

Adendum proposto ao `0005-protocolo-markers-v2.md`:

| Marker | Quando usar |
|---|---|
| `🟦 HBN MINIMALIST GATE` | Decisão de adoção/arquivamento que invocou explicitamente o Princípio do Minimalismo de Cadeia |

Permite rastrear quantas decisões já foram tomadas sob este princípio.

## Versão

- v1.0 — 2026-05-06 — formalização inicial após arquivamento de Typer.
- v1.1 — 2026-05-06 — adição da seção "Declaração" no topo como síntese forte (sem perda do conteúdo original).
