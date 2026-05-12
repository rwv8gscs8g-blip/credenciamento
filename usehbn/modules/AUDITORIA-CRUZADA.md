---
titulo: Auditoria Cruzada
tipo: modulo-do-usehbn
papel: validacao multi-IA antes do fechamento de decisoes criticas
audiencia: humano + ia
licenca: AGPLv3
---

# Auditoria Cruzada

## O que e

Auditoria Cruzada e o modulo do useHBN que **submete decisoes
criticas a validacao por multiplas IAs antes do fechamento**. Cada
esteira de desenvolvimento (especificacao, implementacao, promocao
publica) passa por uma etapa formal onde IAs distintas revisam o
output umas das outras, registram divergencias e apresentam sintese
ao operador.

A motivacao e operacional, nao filosofica:

> "Antes do desenvolvimento vamos fazer a auditoria cruzada entre as
> IAs para documentar todos os processos de pedir solucoes antes de
> fecharmos a esteira de desenvolvimento."
>
> — Mauricio, 2026-05-06

Sem auditoria cruzada, o useHBN seria refem da IA que primeiro tocou
o problema. Com auditoria cruzada, decisoes ganham robustez,
documentacao fica completa, vieses individuais de IAs sao
neutralizados, e o operador decide com mais informacao.

## As IAs envolvidas

| IA | Papel tipico |
|---|---|
| **Claude Opus (Cowork/Antigravity)** | Arquiteto + validador |
| **Codex CLI (OpenAI)** | Executor de tarefas estruturais |
| **Antigravity (Codex Heavy)** | Diagnostico arquitetural; revisao pesada |
| **Gemini Pro/Ultra** | Revisao de design; critica de longo prazo |
| **Notebook LM** | Sintese de fontes externas; estudo profundo |
| **Outras IAs** | Permeabilidade similar ao Radar — entram conforme surgirem |

O operador e sempre o decisor final. As IAs auditam, sugerem, divergem
— ele aprova, itera ou arquiva.

## Os sete tipos de pedido de solucao

Cada esteira gera multiplos "pedidos de solucao" — momentos em que uma
IA pede a outra (ou ao operador) algo. Tipos canonizados:

| Tipo | Quem pede para quem | Exemplo |
|---|---|---|
| **Spec request** | Operador → Opus | "Monte plano detalhado de incorporacao" |
| **Implementation request** | Opus → Codex | "Implemente conforme spec X" |
| **Validation request** | Opus → outra IA | "Audite os arquivos entregues" |
| **Synthesis request** | Operador → Opus + Notebook LM | "Sintetize os 5 estudos em prompt unificado" |
| **Critique request** | Operador → Gemini | "Critique a arquitetura proposta" |
| **Diagnostic request** | Operador → Antigravity | "Diagnostique drift na cadeia X" |
| **Decision request** | Opus → Operador | "Aprove ou rejeite esta promocao" |

Cada pedido vira entrada estruturada em
`audit-trail/<esteira>/<pedido_id>.yaml` com campos canonicos: `de`,
`para`, `tipo`, `data`, `artefato_pedido`, `contexto`,
`alternativas_consideradas`, `opcao_escolhida`, `racional`,
`trade_offs_aceitos`, `ia_responsavel`, `revisor_cruzado`,
`maurício_decisao`, `gate_de_fechamento`.

## Fluxo das oito etapas

```text
1. ABERTURA da esteira (operador abre; Opus desenha spec)
   │
   ▼
2. PEDIDOS DE SOLUCAO (cada um documentado em audit-trail)
   │
   ▼
3. EXECUCAO (Codex/Opus implementa conforme spec)
   │
   ▼
4. VALIDACAO INTERNA (Opus auto-valida)
   │
   ▼
5. AUDITORIA CRUZADA (IAs revisam output umas das outras)  ◄── etapa nova
   │
   ▼
6. SINTESE DE AUDITORIA (Opus consolida e apresenta ao operador)
   │
   ▼
7. DECISAO OPERADOR (aprova / itera / arquiva)
   │
   ▼
8. FECHAMENTO da esteira (capsula de auditoria + ERP)
```

## Etapa 5 detalhada — auditoria cruzada propriamente dita

### Quem audita quem

| Tipo de esteira | Auditor primario | Auditor secundario (cruzado) |
|---|---|---|
| Implementacao Rust de modulo | Codex (implementa) | Opus (arquitetura) + Gemini (design) |
| Spec arquitetural de modulo | Opus (escreve) | Gemini (design) + Codex (viabilidade) |
| Documentacao V2 do useHBN | Opus (escreve) | Notebook LM (sintese externa) + Gemini (critica) |
| Capsulas de promocao publica | Opus (monta) | Operador (decisao final) + Codex (validacao tecnica) |
| Analise de tecnologia para Radar | Opus (analise individual) | Notebook LM (estudo do operador) |

### O que cada auditor verifica

**Opus auditando Codex:**
- Aderencia a spec original
- Principios constitucionais respeitados (P1-P10 + P11-P13 operacionais)
- Cadeia de dependencias dentro do minimo aceitavel
- Documentacao completa, testes presentes e verdes

**Codex auditando Opus:**
- Viabilidade de implementacao da spec
- Edge cases nao considerados
- Trade-offs explicitados
- Compatibilidade com tooling Rust/Python existente

**Gemini auditando arquitetura:**
- Padroes similares em projetos open-source maduros
- Riscos de longo prazo (5+ anos) nao considerados
- Alternativas arquiteturais nao exploradas
- Cobertura dos principios constitucionais

**Operador auditando sintese:**
- Aderencia a intencao declarada
- Coerencia com decisoes anteriores
- Aprovacao final (palavra do operador)

### Output da auditoria cruzada

Documento padrao em `audit-trail/<esteira>/CROSS-AUDIT-REPORT.md`:

```markdown
# Auditoria Cruzada — Esteira <ID>

## Auditores
- Primario: <IA + papel>
- Cruzado 1: <IA + papel>
- Cruzado 2: <IA + papel>

## Itens consensuais ✅
- [item 1] — todos auditores concordam

## Itens divergentes 🟡
- [item X] — Opus diz A; Codex diz B; sintese sugere C

## Sugestoes de iteracao antes de fechar
1. ...

## Veredito da auditoria
- ✅ aprovado para fechamento
- 🟡 iteracao requerida em N pontos
- ❌ retornar para Etapa 3 (re-execucao)

## Decisao do operador pos-auditoria
[a preencher apos hearback]
```

## Filtros / Gates

| Gate | Pergunta-chave | Acao se falha |
|---|---|---|
| Quando convocar | A decisao e arquitetural, muda principio ou promove arvore? | sim → convocar; nao → registrar como decisao trivial em log |
| Auditor cruzado disponivel | Existe segunda IA disponivel para revisar? | nao → adiar fechamento; convocar Notebook LM ou Gemini se necessario |
| Documentacao do pedido | Cada pedido de solucao tem entrada em audit-trail? | nao → preencher antes de prosseguir |
| Consenso vs divergencia | Auditores convergem em pelo menos 80% dos itens? | nao → iteracao 🟡; sim → ✅ |
| Decisao do operador | O operador autorizou o fechamento? | nao → iterar ou arquivar; sim → emitir capsula de auditoria |

## Marcadores

| Marcador | Quando aplica |
|---|---|
| 🔍 HBN CROSS-AUDIT IN PROGRESS | Etapa 5 em curso |
| 🤝 HBN CROSS-AUDIT APPROVED | auditoria concluiu com consenso |
| ⚖️ HBN CROSS-AUDIT ITERATION | divergencias detectadas; iteracao requerida |
| 🟣 HBN PEER REVIEW REQUESTED | etapa inicial de pedido de auditoria |
| 🌳 HBN MODULE BOUNDARY | auditoria toca multiplos modulos do useHBN |

## Capsula de auditoria — output canonico

Cada esteira fechada gera uma capsula via modulo `CAPSULAS-DE-CONSENTIMENTO`:

- `lesson.md` — o que foi aprendido na esteira
- `evidence.json` — refs e hashes do codigo + audit-trail
- `redaction-map.json` — substituicoes aplicadas (se promocao publica)
- `consent.json` — assinatura do operador + assinaturas das IAs auditoras (futuro)
- `license-target.txt` — licenca alvo
- `hashes.json` — integridade

A **capsula de auditoria cruzada** vira o veiculo padrao de conclusao
de esteira. Reforca o papel de Capsulas como infraestrutura transversal.

## Conexao com outros modulos

| Modulo | Relacao |
|---|---|
| Capsulas de Consentimento | Cada auditoria fechada emite capsula assinada pelas IAs auditoras |
| Coordenacao inter-IA | Auditoria roda sobre handoffs registrados; mensageria e canal de pedidos cruzados |
| Fagocitose | Promocoes F3→F4 e F4→F5 exigem auditoria cruzada como gate |
| Seguranca | Validacao multi-IA aplica os 8 vetores como gate explicito |
| Marcadores | Etapas da auditoria tem markers especificos (🔄 ✅ 🟡) |
| Radar | Promocoes de estado (`convergence-mapped` → `candidate`) podem invocar auditoria cruzada |

## Como adotar Auditoria Cruzada em outro projeto

Para replicar este modulo em projeto externo com 2+ IAs disponiveis:

1. Identificar as IAs participantes e seus papeis (auditor primario,
   cruzado, especialista)
2. Criar pasta `audit-trail/` com subpastas por esteira
3. Adotar template canonico para pedidos de solucao (YAML com campos
   listados acima)
4. Definir tabela "quem audita quem" por tipo de esteira
5. Adotar template canonico para `CROSS-AUDIT-REPORT.md`
6. Estabelecer gates (quando convocar, quorum minimo de auditores,
   criterios de aprovacao)
7. Integrar com modulo `CAPSULAS-DE-CONSENTIMENTO`: toda auditoria
   fechada emite capsula
8. Cross-link com `MARCADORES` para usar markers de auditoria
   (🔄 ✅ 🟡 🟣)
9. Treinar IAs participantes para o protocolo: auditar nao e apenas
   "dar opiniao"; e seguir o template

A auditoria cruzada nao depende de ferramenta especifica. Depende de
disciplina de templates + cultura de divergencia documentada.

## Conexao com decisoes ja tomadas

- **Principio AI-Language-Abstraction** — auditoria cruzada e pratica
  viva deste principio (multiplas IAs validam mutuamente)
- **Modelo das 3 Arvores** — auditoria cruzada e gate de transicao
  entre Desenvolvimento e Estavel
- **Markers V2** — gates da auditoria expressos com markers
- **Permeabilidade do Radar** — novas IAs podem entrar como auditoras
  conforme aparecem

## Estado vivo

Especificacao completa do protocolo em
[CROSS-IA-AUDIT-PROTOCOL.md](../methodology/CROSS-IA-AUDIT-PROTOCOL.md).
Primeira aplicacao prevista: fechamento da fase R-A do Consent
Capsules (auto-referencial — a primeira capsula sera a auditoria da
propria implementacao inicial das capsulas).
