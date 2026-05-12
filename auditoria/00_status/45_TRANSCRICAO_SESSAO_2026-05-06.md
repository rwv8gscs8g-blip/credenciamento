---
titulo: 45 - Transcrição completa da sessão Cowork de 2026-05-06 — madrugada riquíssima de avanços do useHBN
diataxis: status
hbn-track: knowledge
hbn-status: active
audiencia: ambos (Maurício para retomada; IAs futuras para contexto)
versao-sistema: V12.0.0203
data: 2026-05-06
autor: Claude Opus 4.7 (Frente 2 — registro)
licenca-target: TPGL v1.1
proposito: registro PERMANENTE da sessão de quarta-feira que produziu trinca de princípios operacionais + modelo das 3 árvores + decisão Rust + arquitetura de módulos + auditoria cruzada + plano V2
status: documento de tracking interno; serve para retomada de contexto em sessões futuras quando contexto for perdido
---

# 45 — Transcrição da Sessão de 2026-05-06

## Por que este documento existe

Sessão de quarta-feira 2026-05-06 produziu volume **excepcional** de inovações arquiteturais para o useHBN. Maurício observou que minha capacidade de carregar todo o contexto entre reaberturas pode falhar — então este documento serve como **registro canônico permanente** da sessão. Contém:

- Estado de início da sessão
- Sequência de decisões tomadas
- Citações operacionais de Maurício preservadas literalmente (fonte primária)
- Princípios articulados
- Modelos arquiteturais formalizados
- Decisões críticas
- Erros que cometi e correções que recebi
- Lista completa de documentos produzidos
- Próximos passos previstos

Sessões futuras (Opus, Codex, Antigravity) podem consumir este documento como **single source of truth** para retomar o trabalho sem perda de contexto.

## Estado no início da sessão (2026-05-06 manhã)

Vinha de sessão anterior (2026-05-02) com decisão de Maurício de estudar 5 tecnologias do radar via Notebook LM antes de implementar:

1. Tree-sitter (parsing real)
2. Typer (CLI Python)
3. uv (gerenciador Python)
4. OpenTelemetry (observabilidade)
5. Consent Capsules (proposta interna)

Tinha sido feito um master document para Notebook LM (5 capítulos com superprompts por tecnologia) + proposta de plano de incorporação progressiva.

## Sequência cronológica de decisões

### Decisão #1 — Tree-sitter APROVADA (manhã)

Após estudo via Notebook LM, Maurício aprovou Tree-sitter como **tecnologia fundadora** do módulo de fagocitose, com 3 papéis simultâneos:

- (a) Ferramenta técnica — parsing real de código legado
- (b) Linguagem comum — ASTs e queries S-expression como notação canônica
- (c) Justificativa de adoção — argumento "porquê useHBN"

Citação operacional Maurício:

> "Tree sitter pareceu-me absolutamente fundamental, quero que fique no radar. Preciso aprender mais sobre LR parser e sobre GLR parser. Há um longo caminho de conhecimento mas as arquiteturas estão completamente aderentes com a evolução pretendida no longo prazo e no uso coletivo pela comunidade."

E após estudo concluído:

> "Quero que apresente um plano detalhado de incorporação da metodologia no processo, na documentação, na construção da arquitetura de forma evolutiva. Essa pode partir do processo de radar para a fagocitose e incorporação como parte do ferramental de justificativa do porque utilizar o useHBN. Que por hora vai propor essa linguagem do tree-sitter como forma de comunicação da ferramenta sobre a orquestração do useHBN."

Plano em 6 fases (A-F) aprovado: Promoção radar → POC isolado → Integração protocolar → Documentação pública → Adoção operacional → Promoção pública via cápsula.

### Decisão #2 — Typer ARQUIVADA + Princípio do Minimalismo de Cadeia formalizado (manhã)

Maurício rejeitou Typer com filosofia operacional pioneira (citação):

> "A Typer não foi aprovada, ela pode sair do radar. O risco de dependências é grande e a queda de performance pode ser concreta em sistemas concretos. Desenvolvedores puristas desistiriam de usar o useHBN pelo simples preconceito de estar acumulando dependências. A ideia é retirar dependências e compilar. Enquanto Tree-sitter trabalhar com Rust e código otimizado, Typer pode virar uma caixa de pandora. As próprias IAs vão entregar tecnologia e visualização rica sem os custos de colocar isso no projeto. As IAs vão ler código puro, não precisam de coisas ricas. Logo, limpar o ambiente e focar em melhorias incrementais sucessivas, mesmo nos microssegundos, será fundamental para a sustentação da tecnologia. Precisamos de uma base sólida, robusta, auditável, sem perdas estéticas que farão a saída ao usuário final ser mediada pela própria IA como interface, não precisando isso no terminal."

Esta articulação **cunhou o Princípio do Minimalismo de Cadeia** — primeiro dos 3 princípios operacionais formalizados nesta sessão. 4 axiomas:

1. Cadeia curta vence ergonomia
2. Compilado vence interpretado
3. IA é a camada estética
4. Devs puristas são audiência crítica

Marker proposto: 🟦 HBN MINIMALIST GATE.

### Decisão #3 — uv ARQUIVADA + Princípio do Substrato Sólido + Decisão Rust (tarde)

Em sequência, Maurício rejeitou uv com inversão arquitetural radical (citação):

> "Se a grande vantagem é que [uv] foi escrito em Rust, para uma linguagem compilada, por que não voltamos nossa base de comunicação criando uma linguagem com alicerces sólidos em Rust, Go, Swift ou outra linguagem moderna que permita uma reconstrução estrutural profunda e sólida? Em seis meses a fricção do processo de desenvolvimento será superado pela escrita de código por IAs, como estamos fazendo agora. Logo, a interface de abstração é a de utilizarmos o máximo de linguagem compilada com microestruturas documentadas e de comportamento seguro. Precisamos evitar o spaghetti code e a metástase de dependências."

Citação adicional sobre decisões arquiteturais sólidas:

> "Se Linus fosse escrever o Linux em Python, provavelmente o sistema não estaria de pé. As decisões arquiteturais sólidas e o uso radical de tecnologias que se tornem estáveis com obsessão em microperformance trará um impacto gigantesco frente à proliferação de código compilado e sujo, com milhões de linhas de código para fazer coisas simples como as IAs estão deixando. Estamos gerando o lixo que deverá ser escavado pelas gerações futuras para entender a lógica do nosso código estruturado."

E sobre código limpo + lógica formal portável:

> "O código tem de ser limpo, otimizado, organizado e legível, por IAs e por humanos. Complicar a legibilidade, clareza e performance por poder contar apenas com capacidade de processamento de máquina para suprir isso é um erro arquitetural. A busca de eficiência, eficácia e efetividade deve estar no caminho do código, não vinculado à limitação do operador ou da tecnologia. Padrões limpos e eficazes de compilação rápida e processamento lógico vão ser mais fáceis de entender e manter. O simples e robusto deve prevalecer ao sofisticado, se isso trouxer instabilidade. As coisas devem simplesmente funcionar, porque estão certas e foram colocadas na ordem certa. Podendo ser transcritas para qualquer linguagem que exista ou venha ser inventada. Lógica formal não vai ficar presa a armadilhas ou insuficiências da linguagem. Precisamos atacar a raiz dos problemas. Voltar à origem da computação binária, se necessário, para lapidar os caminhos entre zeros e uns. As otimizações devem levar em consideração o contexto e o uso sucessivo em looping. Então não podem jogar recurso fora com má programação."

Esta articulação **cunhou o Princípio do Substrato Sólido** — segundo dos 3 princípios operacionais. 5 axiomas:

1. Compilado vence interpretado para o substrato
2. Eficiência no caminho do código
3. Lógica formal transcende a linguagem corrente
4. Simples robusto > sofisticado instável
5. Legibilidade dual (IA + humano)

Marker proposto: 🟪 HBN SUBSTRATO GATE.

Maurício pediu comparativo de linguagens. Apresentei Rust, Go, Zig, Swift, OCaml + 5 secundárias. Recomendação primária Opus: **Rust**.

### Decisão #4 — Princípio AI-as-Language-Abstraction + Modelo das 3 Árvores + Rust adotada formalmente (tarde)

Em mensagem fundadora, Maurício articulou o paradigma mais radical da sessão (citação):

> "A IA que estou utilizando é fluente em Rust, logo, eu sou fluente em Rust. Se eu estou utilizando uma IA como camada de abstração para o desenvolvimento, então o acesso ao código ou ao ferramental não é relevante, pois não vou digitar o código, vou lê-lo sim, mas vou ter camadas de interpretação da própria IA para apresentar os gargalos críticos. Se a estrutura da linguagem forçar até a linha de microgerenciamento da memória, então minha capacidade de articulação e demanda é o do microgerenciamento de memória. Posso chegar até à linguagem de máquina. Esse é o paradigma da utilização da IA como abstração de linguagem. Ela é a única camada de interação real, as demais são ferramentas e linguagens, com suas dificuldades e limitações, principalmente porque foram escritas por humanos sem a possibilidade de ler tudo. Nós temos a capacidade de abstração então não precisamos repetir padrões ruins por cadeias de dependências que não são mais reais."

> "As coisas podem ser reescritas do zero e encapsuladas do zero quase em linguagem de máquina, com dependência zero, para entender a lógica de negócio e funcionamento. A arquitetura pode crescer multitrading se fugirmos dos erros comuns. Podemos usar o useHBN para documentar o que aconteceu e reproduzi-lo para entendermos a lógica de funcionamento e de linguagem. Essa antiga linguagem exporta uma regra de negócio e essa regra de negócio pode ser compilada em uma nova linguagem, mais segura e efetiva. A documentação da regra de negócio clara é codificação semântica do futuro que vai ser construído em software (que venha a ser criado). Então ela tem de ser direta, estruturada, e não ambígua. A não ambiguidade gera construções sem dependências."

> "Eu sou fluente em todas as linguagens que a minha interface de abstração fala (LLMs, IAs ou o que venha a substituir). E o raciocínio humano se sobrepõe a elas. Logo, a linguagem final tem de ser legível por humanos, que dominem a linguagem."

E na mesma mensagem, articulou o **modelo das 3 árvores** (citação):

> "Vamos criar árvores de abstração. A árvore estável é em Rust, compilada, ou compilada em outra linguagem e pode ficar ligada em máquinas por décadas sem travar. A árvore de desenvolvimento vai ter processos de migração de linguagens mais abertas para a escolha da linguagem compilada padrão (por hora Rust). A árvore de exploração e estudo pode ser qualquer linguagem, mesmo as não compiladas, como Python e outras, para associação e conexão com as bordas das diferentes tecnologias. Quando a lógica estiver madura, migra a funcionalidade e migra a tecnologia. Como os frameworks podem ser substituídos (inclusive as linguagens) essa é uma forma de amadurecimento e experimentação. Deixando aberta para o novo, e para os avanços, mas uma rocha sólida para a estabilidade."

Esta articulação **cunhou simultaneamente**:

1. Princípio AI-as-Language-Abstraction (terceiro operacional, candidato a P13). 5 axiomas:
   - IA é a camada de interação primária
   - Fluência transitiva
   - Acesso ≠ digitação
   - Liberação de cadeias legacy
   - Legibilidade humana persiste como filtro final
   - Marker: 🟧 HBN AI-ABSTRACTION GATE

2. Modelo das 3 Árvores (modelo arquitetural):
   - 🪨 Árvore Estável (Rust, décadas sem travar)
   - 🔧 Árvore de Desenvolvimento (migração progressiva)
   - 🌱 Árvore de Exploração e Estudo (qualquer linguagem)
   - Markers: 🌱 EXPLORATION SEED, 🔧 DEV BRANCH, 🪨 STABLE TRUNK, 🟫 TREE TRANSITION

3. Decisão formal: **Rust como linguagem-base** do substrato comum dos módulos do useHBN.

### Decisão #5 — Consent Capsules APROVADA + migração imediata Python → Rust (tarde)

Maurício declarou (citação):

> "Consent Capsules absolutamente fundamental, aderente à nossa tecnologia, deve ser incorporado como tecnologia do fluxo do useHBN e deve ser o primeiro projeto com fluxo estruturado para conversar para uma modelo em Rust, que evolua da linguagem atual para um repositório que trate as características da segurança. Absolutamente fundamental. Pode ser uma tecnologia de assinatura, de compatibilidade e redução de erros, bem em linha com os objetivos da linguagem de declarar o que está em funcionamento e em controle. Pode aprovar e planejar os próximos roadmaps para migração e desenvolvimento da tecnologia em rust. Vamos também preparar para a documentação da versão V2 do useHBN assim que finalizarmos a análise dessas 5 tecnologias."

Roadmap em 5 fases (R-A → R-E) materializado em ~10 semanas:

- R-A: Spec final + POC Python (1 semana)
- R-B: Tradução Rust 1:1 (1-2 semanas)
- R-C: Refinamentos idiomáticos Rust (2-3 semanas)
- R-D: Promoção à Árvore Estável (2-3 semanas)
- R-E: Adoção em V2 useHBN (1 semana)

Cadeia mínima Rust selecionada: serde, sha2, ed25519-dalek, chrono.

### Decisão #6 — OpenTelemetry APROVADA + correção fundamental sobre módulos (tarde)

Maurício declarou aprovação (citação):

> "Open telemetry vai fazer parte do protocolo. Tem completa aderência. Podemos fazer uma evolução rica em termos de processo. Coloque a promoção de 'no radar' para em processo de fagocitose. Vamos analisar e incorporar progressivamente a evolução e as bordas da tecnologia até incorporá-la completamente, montarmos mapas de teste e criarmos alternativas em Rust mais rápidas e estáveis para funcionarem como padrão de mercado. Elas poderão utilizar integração com o consent capsules que já estarão em rust."

E apresentou **correção crítica** do meu entendimento do que é o useHBN (citação):

> "Atenção Claude. A useHBN é um conjunto de intenções declaradas que ainda não estão desenvolvidas, então começamos o estudo para desenvolver um primeiro braço do useHBN que seria o módulo de fagocitose. Ou seja, esse é um braço e aconteceu e por isso estamos indo nesta linha de estudo. O protocolo é mais do que isso e pressupõe a chamada, a segurança, a forma como as IAs estão interagindo e a passagem do bastão. Apenas gastamos energia na construção do módulo de fagocitose, para ele vamos contar muito em particular com o Tree-sitter. Mas existe muita coisa a ser construída nos braços da tecnologia que por hora estão apenas declaradas como intenção, mas que irão crescer (não podemos dizer que o useHBN é apenas um sistema de fagocitose de software como você citou na documentação)."

Esta correção é **crucial** — meu entendimento estava errado. useHBN é multi-braço:

| # | Módulo | Status |
|---|---|---|
| 1 | Fagocitose tecnológica segura | em desenvolvimento (1º braço ativo) |
| 2 | Consent Capsules — assinatura de código | em migração imediata |
| 3 | Coordenação inter-IA / chamada / passagem de bastão | declarado; parcialmente operacional |
| 4 | Segurança (Glasswing-style) | declarado |
| 5 | Markers V2 / protocolo de comunicação semântica | em uso operacional informal |
| 6 | Auditoria Cruzada entre IAs | declarado nesta sessão |

Maurício também pediu (citação):

> "Podemos considerar o Consent Capsules como um outro módulo à parte de assinatura de código, que vai ser utilizado pelos outros módulos por padrão. Além disso, antes do desenvolvimento vamos fazer a auditoria cruzada entre as IAs para documentar todos os processos de pedir soluções antes de fecharmos a esteira de desenvolvimento."

E:

> "Faça uma proposta de melhoria do site de forma mais rica e motivacional do usehbn.org para ficar mais fácil o entendimento e o caminho que estamos seguindo."

E:

> "Apresente a proposta para aprovação e implementação imediata."

### Crítica #1 — Tom dos documentos (tarde-noite)

Maurício criticou o tom dos documentos que produzi (citação):

> "Os documentos não estão bom, precisam ter uma linguagem mais clara, forte, da própria metodologia, não uma 'narrativa dos bugs' mas uma declaração de princípios forte com tudo consolidado. Os nomes dos títulos precisam fazer sentido. Os módulos precisam ser explicados, como por exemplo o radar, e como ele funciona. O fato de termos analisado é uma informação do projeto. Preciso que você separe o que é a evolução do projeto e a declaração pública para outros seguirem. Temos de garantir exatamente a separação que estamos falando que o protocolo faz e não está feito. Refaça uma faxina completa nos documentos e revise. Faça um prompt para pedirmos uma auditoria sincera do Antigravity para você ler e tomar como referência antes de avançarmos."

Comecei a refazer documentos com tom declaratório (sem narrativa de processo). Refiz 3 princípios + criei módulo RADAR + criei prompt para Antigravity.

### Crítica #2 — Eu destruí em vez de complementar (tarde-noite)

Maurício corrigiu (citação):

> "Onde estão os princípios? Tínhamos os princípios era para somar mais. Você está destruindo a força da versão original. Quero apenas que complemente com os avanços de hoje. Não destrua o passado, siga os princípios. Olhe o áudio como está bom e como analisar justamente esses princípios que você destruiu."

Erro grave reconhecido: eu reescrevi os 3 princípios cortando as citações operacionais (fonte primária), os axiomas detalhados, as implicações, as conexões. Isso eliminou evidência histórica e força argumentativa.

### Reparação #1 — Restauração com complemento (este momento da sessão)

Restaurei os 3 princípios operacionais com TODA a versão original preservada + adição de "Declaração" no topo como síntese forte. Não cortei nada. Apenas somei.

### Pedido #2 — Documentar a sessão + prompt para análise do site (este momento)

Maurício pediu (citação):

> "Volte tudo. Complemente. Você destruiu os melhores insights do projeto. Documente tudo o que está no chat e informe se preciso criar outro prompt para você entender. Escreva tudo o que está no chat de hoje que foi uma madrugada riquíssima e você está se prendendo em contexto."

> "Salve os documentos escritos hoje na máquina. Textualmente para termos um md e crie um prompt para analisarmos o site como está atualmente e INCLUIRMOS os avanços previstos no chat e analisados corretamente."

Este documento **45** responde ao pedido de transcrição. Prompt de análise do site sendo criado em paralelo (`PROMPT-ANALISE-SITE-USEHBN-ORG.md`).

## Decisões consolidadas (status final 2026-05-06 noite)

### As 5 tecnologias estudadas

| # | Tecnologia | Decisão | Estado radar | Documento |
|---|---|---|---|---|
| 1 | Tree-sitter | ✅ APROVADA — 6 fases A-F | `in-radar` | (plano em prompt unificado pendente) |
| 2 | Typer | ❌ ARQUIVADA — minimalismo | `archived` | ficha + 41 |
| 3 | uv | ❌ ARQUIVADA — substrato sólido | `archived` | ficha + 41 |
| 4 | OpenTelemetry | ✅ APROVADA — fagocitose progressiva | `candidate` | ficha + 41 |
| 5 | Consent Capsules | ✅ APROVADA — migração imediata | `candidate` | ficha + 41 + 42 (roadmap R-A→R-E) |
| — | Rust | ✅ DECLARADA linguagem-base | `phagocytosed` (stack-fundacional) | ficha rust.md |

### Os 3 princípios operacionais formalizados (todos hoje)

| # | Princípio | Marker | Documento canônico | 1ª aplicação |
|---|---|---|---|---|
| P11 candidato | Minimalismo de Cadeia | 🟦 | `MINIMALISM-PRINCIPLE.md` | arquivamento Typer |
| P12 candidato | Substrato Sólido | 🟪 | `SUBSTRATO-SOLIDO-PRINCIPLE.md` | arquivamento uv |
| P13 candidato | AI-Language-Abstraction | 🟧 | `AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md` | decisão Rust apesar de Maurício nunca ter digitado |

### O modelo arquitetural novo

`THREE-TREES-ARCHITECTURE.md` — 🪨 Estável + 🔧 Desenvolvimento + 🌱 Exploração. Aplica-se a cada módulo (não só fagocitose).

### A correção fundamental sobre estrutura

useHBN é **multi-braço**: 6 módulos declarados. Documento canônico: `USEHBN-MODULES-ARCHITECTURE.md`.

### Os 11 markers V2 propostos

🟦 MINIMALIST · 🟪 SUBSTRATO · 🟧 AI-ABSTRACTION · 🌱 EXPLORATION SEED · 🔧 DEV BRANCH · 🪨 STABLE TRUNK · 🟫 TREE TRANSITION · 🌳 MODULE BOUNDARY · 🔄 CROSS-AUDIT IN PROGRESS · ✅ CROSS-AUDIT APPROVED · 🟡 CROSS-AUDIT ITERATION

## Documentos produzidos hoje (lista completa)

### Princípios operacionais (3)

| Path | Status |
|---|---|
| `usehbn/methodology/MINIMALISM-PRINCIPLE.md` | restaurado completo + síntese declarativa |
| `usehbn/methodology/SUBSTRATO-SOLIDO-PRINCIPLE.md` | restaurado completo + síntese declarativa |
| `usehbn/methodology/AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md` | restaurado completo + síntese declarativa |

### Modelos arquiteturais (2)

| Path | Status |
|---|---|
| `usehbn/methodology/THREE-TREES-ARCHITECTURE.md` | criado completo |
| `usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md` | criado completo (correção sobre estrutura multi-braço) |

### Comparativo + decisão (2)

| Path | Status |
|---|---|
| `usehbn/methodology/LANGUAGE-PLATFORM-COMPARISON.md` | criado com decisão Rust marcada |
| `usehbn/radar/_per-technology/rust.md` | criado (estado phagocytosed) |

### Auditoria cruzada (1)

| Path | Status |
|---|---|
| `usehbn/methodology/CROSS-IA-AUDIT-PROTOCOL.md` | criado completo |

### Módulos (1 — exemplo de tom declarativo)

| Path | Status |
|---|---|
| `usehbn/modules/RADAR.md` | criado declarativo |

### Site (1)

| Path | Status |
|---|---|
| `usehbn/site/PROPOSTA-MELHORIA-USEHBN-ORG.md` | criado completo |

### Auditoria externa (1)

| Path | Status |
|---|---|
| `usehbn/audits/PROMPT-AUDITORIA-ANTIGRAVITY.md` | criado completo |

### Roadmaps + tracking interno (5)

| Path | Status |
|---|---|
| `auditoria/00_status/41_DECISOES_5_TECNOLOGIAS_EM_CURSO.md` | atualizado com todas as 5 decisões |
| `auditoria/00_status/42_ROADMAP_CONSENT_CAPSULES_RUST.md` | criado com roadmap R-A→R-E |
| `auditoria/00_status/43_PLANO_DOCUMENTACAO_V2_USEHBN.md` | criado com plano V2 |
| `auditoria/00_status/44_CORRECAO_USEHBN_E_CONSOLIDACAO.md` | criado com 7 blocos de aprovação |
| `auditoria/00_status/45_TRANSCRICAO_SESSAO_2026-05-06.md` | este documento |

### Fichas de tecnologias atualizadas (4)

| Path | Status |
|---|---|
| `usehbn/radar/_per-technology/typer.md` | archived |
| `usehbn/radar/_per-technology/uv.md` | archived |
| `usehbn/radar/_per-technology/opentelemetry.md` | candidate |
| `usehbn/radar/_per-technology/consent-capsules.md` | candidate |

### Tracking compartilhado (3)

| Path | Status |
|---|---|
| `usehbn/radar/REGISTRY.md` | atualizado com novas linhas (rust, typer/uv archived, OTel/CC candidate) |
| `usehbn/radar/WEEKLY-UPDATES.md` | 5 addendums hoje |
| `.hbn/relay/INDEX.md` | atualizado com sessão 2026-05-06 |

**Total: 22 documentos criados/atualizados nesta sessão.**

## Próximos passos previstos (após esta sessão)

1. Validação por Maurício do tom dos princípios restaurados
2. Análise do site usehbn.org pelo IA designada (prompt em `PROMPT-ANALISE-SITE-USEHBN-ORG.md`)
3. Submissão do prompt Antigravity para auditoria crítica
4. Geração de prompt unificado ao Codex para implementação
5. Início R-A do roadmap Consent Capsules (POC Python)
6. F2 da V2 do useHBN (primeira redação completa)

## Como retomar contexto a partir deste documento

Sessão futura (Opus, Codex, Antigravity ou outra IA) deve:

1. Ler este documento integralmente
2. Ler `usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md` (estrutura correta)
3. Ler os 3 princípios operacionais
4. Ler `THREE-TREES-ARCHITECTURE.md`
5. Ler `auditoria/00_status/41` (decisões em curso)
6. Ler `auditoria/00_status/44` (consolidação para aprovação)
7. Ler `usehbn/radar/REGISTRY.md` (estado atual do radar)

Com isso, qualquer IA reentra na sessão com contexto completo da madrugada de 2026-05-06.

## Versão

- v1.0 — 2026-05-06 — registro permanente da sessão.
