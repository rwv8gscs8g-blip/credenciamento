# PROMPT — Auditoria Cruzada Onda QA-V3

**Destinatários:** Codex (instância paralela na esteira V204) + Antigravity (Gemini 3.5)
**Solicitante:** Mauricio (gestor) via Claude Opus 4.7
**Data:** 2026-05-27
**Modelo origem:** Claude Opus 4.7 (1M context)

---

## 1. INSTRUÇÃO DE MÁXIMA PRIORIDADE

Você está sendo convocado como **auditor independente**. Sua função NÃO é implementar nada. NÃO é elogiar. NÃO é "ajudar". É **encontrar problemas** nos artefatos abaixo antes que eles cheguem à linha de produção do projeto Credenciamento.

Você foi escolhido especificamente porque o autor original (Claude Opus 4.7) pode ter pontos cegos. Sua função é ser o segundo par de olhos crítico. Se você não encontrar nada para criticar, você falhou a tarefa — porque artefatos extensos sempre têm gaps.

---

## 2. CONTEXTO MÍNIMO

Sistema: **Credenciamento e Rodízio para prefeituras municipais**, planilha Excel `.xlsm` com macros VBA. Migração futura para SaaS web prevista.

Versão atual: V12.0.0206 em estabilização. Próxima onda planejada: **QA-V3 (Plataforma de Testes)**, objetivo de incrementar maturidade da bateria de testes e produzir guia definitivo para humanos certificadores.

Histórico relevante:
- Bateria atual = 336 testes (V1 monolítica 171 + V2 modular 165).
- Incidente 2026-05-27: corrupção de workbook em Onda 38.2.2 — pendência de decisão A (seguir) vs B (rollback).
- Estabilização V206 ainda em curso.

---

## 3. ARTEFATOS PARA AUDITORIA

Três documentos foram produzidos pelo Claude Opus 4.7 durante a sessão de 2026-05-27 e estão em `auditoria/03_ondas/onda_QA_V3/`:

### A. `GUIA_DEFINITIVO_TESTES_V3_DRAFT.md`
Guia mestre de testes — substitui o "Guia de Testes V12.0.0202 + Ondas 1-4" anterior. Audiência simultânea: QA, operadores, gestores, auditores e IAs implementadoras. Contém:
- Resumo executivo (§0) com variáveis, dimensões, papéis humanos
- Visão geral do sistema (§1)
- Glossário canônico (§2) — termos de domínio + termos V3
- 32 Regras de Negócio (§3) — RN-01 a RN-22 herdadas + RN-23 a RN-32 novas
- Capítulo dedicado ao Rodízio (§4) com algoritmo formal e 10 invariantes
- Setup do ambiente (§5) — atualizado para 5 empresas
- Roteiros de teste (§6) — 23 cenários V202 + 18 novos V3 = 41 totais
- Arquitetura V3 (§7) — Engine, Populadores, DSL, Reporters, Tutorial, Menu
- PDF e Pasta de Auditoria (§8) — nomenclatura, estrutura, CSV companion, compactação
- Gerador de Tutorial (§9) — 4 modos, MVP em paralelo
- Mapa de cobertura (§10)
- Critérios de aceite (§11) — 14 critérios
- Reporte de bugs (§12)
- FAQ (§13)
- 8 Apêndices

### B. `SUPERPROMPT_ONDA_QA_V3.md`
Prompt operacional para IAs implementadoras (Codex, Opus, outras). Detalha:
- Contexto e leituras obrigatórias
- Objetivo global da onda
- Não-objetivos (limites duros)
- Metas prioritárias (Qualidade > Velocidade, Segurança > Velocidade, Profundidade > Velocidade)
- Regra de Ouro
- Cadência e coordenação
- 10 sprints (QA-V3.1 a QA-V3.10) com entregáveis e critérios de aceitação
- Proibições específicas
- Checkpoints de parada
- Definição de Pronto (DoD)

### C. Este documento (`PROMPT_AUDITORIA_CRUZADA.md`)
O que você está lendo.

---

## 4. SUA TAREFA

Leia A e B em profundidade. **Procure os problemas listados nos itens 4.1 a 4.10 abaixo.** Para cada problema encontrado, responda no formato §5.

### 4.1 Inconsistências lógicas no guia

- Há regras de negócio (RN-XX) que contradizem outras?
- Há cenários (CS-XX) que testam comportamentos contraditórios?
- O algoritmo do rodízio (§4.2) é consistente com as RN que o referenciam?
- Os 10 invariantes (§4.3) são realmente invariantes ou alguns são deriváveis dos outros?

### 4.2 Gaps de cobertura

- Quais comportamentos do sistema NÃO estão cobertos nem por V202 nem pelos novos cenários V3?
- Cite especificamente cenários que faltam, com justificativa.
- Pense em: race conditions, falhas externas (disco cheio, lock de arquivo), edge cases numéricos (overflow de contador, datas inválidas), erros de operador (entrada não-numérica em campo numérico), etc.

### 4.3 Problemas semânticos em terminologia

- Termos usados de forma ambígua entre seções?
- Termos novos em V3 que colidem com termos existentes em V1/V2?
- Glossário (§2) está completo? Há termos usados sem definir?

### 4.4 Problemas no contrato do rodízio (§4)

- O algoritmo (§4.2) tem alguma ambiguidade que poderia produzir não-determinismo na implementação?
- O passo de "reativação automática" dentro da função de escolha (RN-08) é seguro? Pode produzir efeitos colaterais indesejados em concorrência (mesmo single-thread)?
- A ordem de iteração `ASC por POSICAO_FILA` é suficiente para determinismo? Há tie-breakers necessários (ex.: 2 empresas com mesma POSICAO_FILA por bug histórico)?

### 4.5 Problemas em RN-23 (Validação CNPJ) e RN-24 (Integridade Referencial)

- A função `ValidarCNPJ` algoritmicamente correta? Especifique: deve usar mod-11 sobre os 12 primeiros dígitos com pesos [5,4,3,2,9,8,7,6,5,4,3,2] e [6,5,4,3,2,9,8,7,6,5,4,3,2]?
- CNPJs de teste tipo "11.111.111/1111-11" — quais EXATAMENTE são válidos? Cite 3 CNPJs sintaticamente formados mas matematicamente inválidos para teste.
- A verificação de integridade referencial (RN-24) pode ser custosa em planilha grande. Há estratégia de cache ou incremento?

### 4.6 Problemas em RN-27, RN-28, RN-29 (Expirar/Rejeitar Pré-OS)

- A "equivalência de punição" (RN-29) está bem fundamentada? Ou é decisão arbitrária do código atual que poderia ser questionada?
- O texto do guia (§4.6 do GUIA, dentro de RN-29) levanta a pergunta de design "faz sentido punição ser idêntica?" — qual é sua resposta como auditor independente?
- CS-29 (idempotência protetiva) — a mensagem `STATUS_INVALIDO` é suficiente, ou deveria identificar especificamente "Pré-OS já está em status X, não pode ser expirada/rejeitada"?

### 4.7 Problemas em arquitetura V3 (§7)

- A camada "Populadores idempotentes" (§7.4) está coerente com a Sub `TV2_PrepararCenarioTriploCanonico` que ela envelopa? Esta última é idempotente?
- A DSL de Receitas (§7.3) tem schema completo? Falta coluna importante?
- O Modo Tutorial em workbook paralelo (§7.5 / Sprint QA-V3.5) — risco de drift entre workbooks?
- Menu V3 hierárquico (§7.7) — 38 opções é muita? Pouca? Há categorização melhor?

### 4.8 Problemas em PDF e Pasta de Auditoria (§8)

- Nomenclatura `SIGLA_ID_TIMESTAMP` (§8.2) pode colidir entre tipos? (Ex.: dois PRESS para mesma empresa no mesmo segundo?)
- Estrutura de pasta (§8.3) cobre todos os tipos de evidência relevantes para auditoria legal?
- CSV companion (§8.4) — schema cobre todas as informações que IA auditora precisaria sem abrir PDFs?
- Compactação `.zip` (§8.5) — tamanho estimado realista? Há risco de pasta exceder limite?

### 4.9 Problemas no superprompt (B)

- As 10 sprints estão na ordem correta? Há dependências invertidas?
- Sprint 5 (Tutorial) tem 13 dias — muito tempo investido em algo não-crítico? Poderia ser diferida?
- "Definição de Pronto" (DoD) é mensurável? Qual critério é subjetivo demais?
- Os "Checkpoints de parada" cobrem todos os riscos críticos?

### 4.10 Riscos transversais

- Esta onda QA-V3, paralela à estabilização V206, tem risco de colisão de bastão?
- O documento será 100+ páginas no Word — será efetivamente lido por humanos certificadores? Há risco de o documento virar artefato burocrático em vez de manual operacional?
- A premissa "V3 envelopa, não substitui" — há cenário em que isso falha? (Ex.: bug no engine V3 derruba V1/V2 também?)
- Migração SaaS futura — alguma decisão V3 cria atrito para essa migração?

---

## 5. FORMATO DA RESPOSTA

Para CADA problema encontrado, responda neste formato:

```
### ACHADO [ID curto, ex.: A-RDZ-001]

**Severidade:** CRÍTICO / ALTO / MÉDIO / BAIXO
**Categoria:** [da seção 4 deste prompt — ex.: 4.4]
**Localização:** [arquivo + §seção + linha aproximada]

**Descrição:**
[2-5 linhas explicando o problema]

**Por que é problema:**
[2-4 linhas — consequência se não resolvido]

**Recomendação:**
[1-3 linhas — proposta de correção concreta]

**Confiança:** [Alta / Média / Baixa — quão certo você está]
```

Ao final, inclua:

```
### SUMÁRIO

- Total de achados: NN
- Por severidade: X CRÍTICOS, Y ALTOS, Z MÉDIOS, W BAIXOS
- Áreas mais frágeis (top 3):
- Áreas mais sólidas (top 3):
- Recomendação geral:
```

---

## 6. CRITÉRIO DE QUALIDADE DA SUA AUDITORIA

Você terá feito boa auditoria se:

✅ Encontrar pelo menos **3 achados CRÍTICOS ou ALTOS** que o autor original não previu.
✅ Cada achado tem localização específica (não "o documento todo").
✅ Cada recomendação é acionável (não "considerar revisar").
✅ Você diferenciar **decisões arquiteturais defensáveis mas discutíveis** de **erros objetivos**.
✅ Você apontar **omissões** (algo que falta) além de **erros** (algo que está errado).

Você terá feito MÁ auditoria se:

❌ Resposta começa com "O documento está muito bem estruturado..."
❌ Achados são genéricos ("falta clareza em alguns pontos")
❌ Nenhum achado CRÍTICO ou ALTO (improvável em documento desta extensão)
❌ Você sugerir mudanças que contradizem explicitamente as decisões do gestor (B1-B11 estão consolidadas no GUIA — você pode questionar a fundamentação, mas precisa reconhecer que foi decisão consciente)

---

## 7. RESTRIÇÕES DA AUDITORIA

- **NÃO escreva código.** Apenas critique.
- **NÃO proponha reescritas inteiras.** Aponte problemas pontuais com recomendações pontuais.
- **NÃO assuma contexto que você não tem.** Se algo não está claro no documento, registre como achado "FALTA DE CLAREZA".
- **NÃO duplique achados.** Se o mesmo problema aparece em múltiplos lugares, registre 1× com lista de ocorrências.

---

## 8. CONTEXTO ESPECÍFICO POR DESTINATÁRIO

### 8.1 Para Codex (instância V204)

Você está trabalhando em pipeline paralelo no protocolo HBN/V204. Sua auditoria desta onda QA-V3 deve focar em:
- **Compatibilidade com protocolo HBN** — algum item viola convenções de readback/hearback/relay?
- **Risco de colisão com bastão V204** — esta onda QA-V3 pode bloquear ou ser bloqueada por V204?
- **Coerência com governança HBN-native** — `.hbn/knowledge/`, `.hbn/proposals/`, etc.

### 8.2 Para Antigravity Gemini 3.5

Você é a IA externa convocada como auditor. Sua auditoria deve focar em:
- **Lacunas de raciocínio** que IAs internas (Claude/Codex) podem ter compartilhado por viés similar.
- **Comparação com padrões da indústria** — testes em produtos públicos com requisitos legais (licitação, conformidade).
- **Migração SaaS** — sua perspectiva sobre se este guia sobreviveria intacto à migração para web.

---

## 9. DEADLINE E ENTREGÁVEL

- **Deadline:** sem prazo rígido, mas resposta esperada antes da próxima sessão do gestor (sessão em curso 2026-05-27 noite; resposta esperada até manhã 2026-05-28).
- **Entregável:** sua resposta completa em markdown, mesmo formato do §5, retornada ao gestor.
- **O gestor consolidará** sua resposta com a do outro auditor e devolverá a consolidação ao Claude Opus 4.7 para integração final no documento.

---

## 10. NOTA FINAL

O autor original (Claude Opus 4.7) escreveu este artefato em uma única sessão, com investigação técnica do código mas sem revisão por par. Confiança própria estimada do autor: ~75%. Há ~25% de espaço para erros materiais. Sua tarefa é estreitar esse intervalo.

Boa auditoria.

---

## ANEXO — Estado do bastão no momento do envio

- Branch: `codex/v12-0-0206-planejamento`
- Estabilização V206 em curso (Mauricio decidiu não congelar V206 sem resolver lentidão em PCs antigos)
- Incidente 2026-05-27 (corrupção workbook V206 pós-Onda 38.2.2) pendente: decisão A vs B
- Esta onda QA-V3 NÃO é prioritária sobre estabilização V206 — apenas planejamento futuro
- Auditoria cruzada é não-bloqueante; suas conclusões alimentam decisão do gestor
