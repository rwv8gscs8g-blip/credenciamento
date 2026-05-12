---
titulo: Prompt de Auditoria Cruzada — 6 modulos do useHBN entregues 2026-05-09
tipo: prompt-de-auditoria-cruzada
audiencia: ia (Antigravity / Codex Heavy / Gemini)
data: 2026-05-09
licenca: AGPLv3
modulo-relacionado: Auditoria Cruzada (Modulo 6)
escopo: Tarefa 1 + Tarefa 7 da sessao Antigravity de continuidade pos-2026-05-06
relacao-com-prompt-anterior: este prompt e mais estreito que PROMPT-AUDITORIA-ANTIGRAVITY.md (generico). Foca apenas nos arquivos novos/atualizados desta sessao. O prompt generico permanece valido para auditoria do protocolo como um todo.
---

# Prompt de Auditoria — Antigravity sobre os 6 modulos novos do useHBN

## Como usar

Mauricio submete o conteudo deste arquivo ao Antigravity (ou Codex
Heavy variant, ou Gemini) anexando os arquivos listados em
"Materiais". Output esperado: relatorio estruturado de auditoria
critica focada nos artefatos especificos desta sessao. Opus consume
o relatorio como referencia critica antes de avancar para Tarefa 5
(refator V2) e Tarefa 6 (prompt unificado Codex).

Esta auditoria e **focada e tecnica**, nao filosofica. O Antigravity
ja teve oportunidade de auditar os principios e o modelo arquitetural
no prompt anterior (PROMPT-AUDITORIA-ANTIGRAVITY.md). Aqui o foco e
a qualidade declarativa dos 6 modulos publicos recem-formalizados.

---

## TEXTO DO PROMPT (cole no Antigravity apos anexar os materiais)

```text
Antigravity, peco auditoria cruzada estreita sobre 6 modulos publicos
do useHBN que acabam de ser formalizados como arquivos individuais em
usehbn/modules/. Os modulos eram declarados como intencao desde
2026-05-06; foram materializados em arquivos no padrao RADAR.md em
2026-05-09 (sessao Cowork de continuidade pos-Cowork anterior).

Esta nao e auditoria do protocolo useHBN inteiro — e auditoria estreita
de 8 artefatos especificos (6 modulos + 1 INDEX + 2 addendums). Ja
existe auditoria generica preparada (ver
PROMPT-AUDITORIA-ANTIGRAVITY.md); nao reproduza esse escopo aqui.

CONTEXTO RAPIDO

useHBN e um protocolo aberto multi-braco para coordenacao humano-IA.
Foi corrigido em 2026-05-06 que useHBN NAO e apenas um sistema de
fagocitose — fagocitose e um modulo entre 6. Nesta sessao 2026-05-09:

1. 6 arquivos novos foram criados em usehbn/modules/ no padrao
   declarativo de RADAR.md (que serve como template)
2. INDEX.md em usehbn/modules/ lista os 7 (6 novos + RADAR como
   infraestrutura de observacao)
3. Addendum em usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md
   adiciona cross-links para os 6 novos arquivos sem reescrever
   secoes existentes
4. Addendum em .hbn/knowledge/0005-protocolo-markers-v2.md formaliza
   11 marcadores novos (3 dos principios operacionais + 5 das 3
   arvores + 3 da auditoria cruzada). Total: 21 marcadores canonicos.

Hard constraints da sessao anterior internalizadas:
- CONSTRAINT 1: nunca substituir conteudo rico — sempre append
- CONSTRAINT 2: citacoes operacionais de Mauricio sao fonte primaria
  e devem ser preservadas literalmente como blocos `>`
- CONSTRAINT 3: separacao tracking interno (auditoria/00_status/) vs
  declaracao publica (usehbn/methodology/, usehbn/modules/) — modulos
  publicos em tom declarativo, nao narrativo de processo
- CONSTRAINT 4: useHBN nao e fagocitose; fagocitose e UM modulo entre 6
- CONSTRAINT 7: Opus e arquiteto/validador; Codex executa; Mauricio
  decide

OITO AREAS DE FOCO

1. TOM DECLARATIVO (CONSTRAINT 3)

   Cada um dos 6 modulos esta em tom DECLARATIVO (principio como spec)
   ou em tom NARRATIVO (historia de como surgiu)?
   
   Aponte trechos especificos onde o tom escorrega para narrativa de
   processo ("nos decidimos", "X articulou em Y data", "depois que
   Mauricio explicou"). Esses sao defeitos.
   
   Exemplo do tom correto: ver RADAR.md (template canonico) — abre com
   "Radar e o modulo de observacao de tecnologias do useHBN" e segue
   declarativo ate o fim.

2. CITACOES OPERACIONAIS PRESERVADAS (CONSTRAINT 2)

   Os 6 modulos contem citacoes diretas de Mauricio em blocos `>`?
   
   Onde aplicavel, as citacoes estao **literais** ou foram parafraseadas
   "para serem mais concisas"? Parafraseamento de citacoes operacionais
   e defeito grave porque destroi a fonte primaria.
   
   Compare com fonte primaria nos arquivos canonicos linkados (ex.: a
   citacao Mauricio 2026-05-06 sobre Consent Capsules deve aparecer
   identica em CAPSULAS-DE-CONSENTIMENTO.md e na ficha
   usehbn/radar/_per-technology/consent-capsules.md).

3. useHBN ≠ FAGOCITOSE (CONSTRAINT 4)

   FAGOCITOSE.md trata o tema como UM modulo entre 6 ou se posiciona
   como tema central do useHBN?
   
   Aponte qualquer trecho que sugira "useHBN = sistema de fagocitose".
   E qualquer trecho onde os outros 5 modulos sao tratados como
   "auxiliares" da fagocitose em vez de pares.

4. ESTRUTURA DE 8 BLOCOS (TEMPLATE RADAR.md)

   Cada modulo tem:
   - Frontmatter YAML (titulo, tipo, papel, audiencia, licenca)
   - "O que e" (definicao declarativa)
   - Componentes/Estados/Vetores (nomenclatura adaptada)
   - Movimento/Fluxo (diagrama ASCII)
   - Filtros/Gates (tabela com pergunta-chave + acao)
   - Marcadores
   - Conexao com outros modulos
   - Como adotar em outro projeto
   
   Algum dos 8 blocos esta fraco em algum dos 6 modulos? Onde
   especificamente? Algum bloco foi omitido?

5. CROSS-LINKS BIDIRECIONAIS

   Cada modulo cita os outros 5 na tabela "Conexao com outros modulos"?
   Os links sao reciprocos — modulo A liga a B implica B liga a A?
   
   Especificamente: o INDEX.md captura corretamente o mapa de
   dependencias entre os 7 modulos (6 novos + RADAR)?

6. MAPEAMENTO MARKERS → MODULO DE ORIGEM

   MARCADORES.md tem tabela canonica de 21 marcadores com modulo de
   origem. Esse mapeamento e coerente?
   
   Especificamente: o reuso de emoji (✅ tanto em "HBN ACTIVE" quanto
   em "HBN CROSS-AUDIT APPROVED"; 🟡 tanto em "HBN NEEDS HUMAN DECISION"
   quanto em "HBN CROSS-AUDIT ITERATION") esta justificado e a
   desambiguacao via label completo e robusta? Ou cria confusao
   operacional?

7. SOBREPOSICAO ENTRE MODULOS

   Os 6 modulos cobrem eixos disjuntos ou ha sobreposicao?
   
   Suspeitas plausiveis:
   - Coordenacao inter-IA e Auditoria Cruzada parecem proximas — ambas
     tratam de fluxo entre IAs. A separacao se justifica?
   - Seguranca e Capsulas ambas tratam de assinatura. A separacao se
     justifica?
   - Marcadores e transversal — atrapalha entender o conjunto ou e a
     escolha certa?
   
   Onde houver sobreposicao real, sugira refator (junte/divida).

8. LACUNAS CRITICAS

   Algo essencial que os 6 modulos deveriam cobrir e nao cobrem?
   
   Suspeitas plausiveis:
   - Nao ha modulo de licenciamento/governanca (CLA, contribuicoes
     externas) — e isso um modulo separado ou sub-tema de Capsulas?
   - Nao ha modulo de retencao/decommissioning (despromocao
     operacional) — e isso parte de Fagocitose ou separado?
   - O RADAR esta listado em INDEX.md como "infraestrutura de
     observacao" e nao como modulo numerado — essa decisao se sustenta?

OUTPUT ESPERADO

Documento estruturado com:

1. Sumario executivo (1 paragrafo de avaliacao geral dos 8 artefatos)
2. Por modulo (6 secoes — uma para cada modulo novo): pontos fortes
   especificos, pontos fracos especificos, sugestoes pontuais
3. Avaliacao do INDEX.md (mapa de dependencias coerente?)
4. Avaliacao dos 2 addendums (USEHBN-MODULES-ARCHITECTURE +
   0005-protocolo-markers-v2): respeitam append-only? cross-links
   formados corretamente?
5. Avaliacao dos 21 marcadores como conjunto (coerencia interna?
   redundancia? lacuna?)
6. Sugestoes concretas de iteracao (5-15 mudancas com paths
   especificos e justificativa)
7. Veredito: ✅ aprovado para fechamento / 🟡 iteracao requerida em N
   pontos / ❌ retornar para re-execucao

TOM REQUERIDO

Sincero. Critico. Sem florear. Sem necessidade de proteger sentimentos.
Quero saber onde os 6 modulos estao mal escritos, onde reproducem
defeitos da sessao anterior, onde o tom escorregou para narrativa,
onde citacoes foram cortadas, onde cross-links estao quebrados.

Se algum modulo estiver excelente, diga em uma frase e siga adiante.
Se algum estiver com defeito, gaste palavras explicando por que.

Use linguagem tecnica direta. Aponte paths e linhas especificas.
Cite trechos concretos como evidencia (nao "FAGOCITOSE.md tem tom
narrativo"; sim "FAGOCITOSE.md linha 87 ‘depois que Mauricio
explicou em 2026-05-06’ e narrativa de processo, deveria ser
‘O modulo cobre F0-F5...’").

REFERENCIA CRUZADA

Compare cada modulo com o template RADAR.md (que ja foi auditado
informalmente no prompt anterior e considerado bem formado). Onde os
novos modulos divergem do template em qualidade, aponte.

NAO USE LINGUAGEM DE PRODUTO

Evite vocabulario de marketing tech (disruptivo, revolucionario,
inovador). Use linguagem tecnica direta. Se algo e incremental, chame
de incremental. Se algo e ruim, chame de ruim.
```

---

## Materiais a anexar (Mauricio faz upload destes ao Antigravity)

### Os 6 modulos novos

- `usehbn/modules/FAGOCITOSE.md`
- `usehbn/modules/CAPSULAS-DE-CONSENTIMENTO.md`
- `usehbn/modules/COORDENACAO-INTER-IA.md`
- `usehbn/modules/SEGURANCA.md`
- `usehbn/modules/AUDITORIA-CRUZADA.md`
- `usehbn/modules/MARCADORES.md`

### Indice consolidado

- `usehbn/modules/INDEX.md`

### Template canonico (para comparacao)

- `usehbn/modules/RADAR.md`

### Addendums

- `usehbn/methodology/USEHBN-MODULES-ARCHITECTURE.md` (apenas a secao
  `## 2026-05-09 addendum` no fim e nova; o resto e original de
  2026-05-06)
- `.hbn/knowledge/0005-protocolo-markers-v2.md` (apenas a secao
  `## 2026-05-09 weekly addendum` no fim e nova; o resto e original
  de 2026-05-02)

### Insumos primarios (para verificar preservacao de citacoes)

- `usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md` (insumo de FAGOCITOSE)
- `usehbn/methodology/INCORPORATION-PROGRESSIVE-PLAN.md` (insumo de FAGOCITOSE)
- `usehbn/radar/_per-technology/consent-capsules.md` (insumo de CAPSULAS — citacao Mauricio 2026-05-06 nas linhas 119-121)
- `usehbn/methodology/INTER-CHAT-COORDINATION.md` (insumo de COORDENACAO)
- `.hbn/knowledge/0003-glasswing-style-preventive-security.md` (insumo de SEGURANCA)
- `usehbn/methodology/CROSS-IA-AUDIT-PROTOCOL.md` (insumo de AUDITORIA — citacao Mauricio 2026-05-06 nas linhas 19-22)

### Hard constraints (contexto do auditor)

- Os CONSTRAINTS 1-7 que governaram a sessao estao no prompt de
  retomada da sessao Antigravity 2026-05-09 (nao publico — mas o
  auditor pode verificar evidencia de aderencia indireta a partir
  dos arquivos)

---

## Como Opus integrara o relatorio

1. Leitura completa do relatorio
2. Para cada item ❌ ou 🟡: avaliar gravidade e custo de correcao
3. Itens ✅: arquivar como reforco de confianca
4. Sugestoes concretas: priorizar por modulo e implementar antes de
   avancar para Tarefa 5 (refator V2)
5. Documento de sintese: `usehbn/audits/RELATORIO-ANTIGRAVITY-MODULOS-<data>.md`
6. Mauricio decide quais sugestoes acatar

## Marcador

🔄 HBN CROSS-AUDIT IN PROGRESS — auditoria cruzada em curso sobre
artefatos da Tarefa 1 + Tarefa 7 da sessao 2026-05-09.

Ao receber retorno do Antigravity:
- ✅ HBN CROSS-AUDIT APPROVED — se consenso forte e divergencias
  pequenas
- 🟡 HBN CROSS-AUDIT ITERATION — se divergencias substantivas que
  pedem nova rodada
