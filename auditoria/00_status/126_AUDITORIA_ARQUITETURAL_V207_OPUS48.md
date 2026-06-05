---
titulo: Auditoria arquitetural definitiva — propostas V12.0.0207 (Claude Opus 4.8)
diataxis: explanation
hbn-track: fast_track
hbn-status: active
data: 2026-06-05
autoria: claude-opus-4.8 (modo arquiteto, onda 0117) em consulta a Mauricio
onda: 0117
readback: .hbn/readbacks/0148-rb-onda-0117-organizacao-handoff-codex.json
docs-auditados: 33_ROADMAP (02_planos), proposals 0002/0004/0005, 00_status 105/111/112, onda_38_2_4/PLANO_MELHORIA_TESTES + V207_NOTA_ARQUITETURA_STATUS_CANONICO
---

# Auditoria arquitetural V207 — veredito Opus 4.8

> **Este documento NÃO é autorização de início da V207.** É a auditoria
> definitiva pedida por Mauricio em 2026-06-05, com condições bloqueadoras.
> Análises anteriores eram do Opus 4.7; esta revisão usa o estado atual do
> protocolo (ondas 0114-0117: firewall 0022, CI ratchet, scope-lock por commit).

## 1. Veredito

**APROVAR COM CONDIÇÕES** o plano principal — Alternativa II ("Opção 4
híbrida") consolidada em `112_ANALISE_AUDITORIA_CRUZADA_V207_2A_RODADA.md` e
refinada em `.hbn/proposals/0005-codex-refinamento-arquitetural-v207.md`:
V207.0-V207.4 monolito limpo (Svc_Cadastro* + Repos + escrita em bloco) →
medição → V207.5-V207.7 cache read-only com guard-rails → freeze V207.8.

A arquitetura é sólida: o Fase-Lock (tag intermediária + E2E verde antes do
cache), a Invalidação Stateless (reconstrução total, nunca cirúrgica) e o
Callback Explícito são exatamente os contratos que impedem o híbrido de
virar bagunça. A cláusula de escape (congelar em V207.4 se o ganho for
marginal) é maturidade rara em plano de refator.

## 2. CONDIÇÕES BLOQUEADORAS (nenhuma onda V207 abre antes de TODAS fecharem)

| # | Condição | Como fechar |
|---|---|---|
| C1 | **Hearback formal da Alternativa II inexistente como artefato.** A decisão de Mauricio está em prosa nos docs 111/112 ("pendente_hearback") | Criar `.hbn/hearbacks/NNNN-decisao-alternativa-ii-v207.json` com status confirmed assinado por Mauricio |
| C2 | **V206 não está fechada.** Working tree com 95 untracked + 21 modified (trilha HBN 38.2.x não commitada), rerun 0144 pendente, validação tela a tela não concluída | GATE 0 + GATE 1 + iteração tela a tela do doc 127; ao final, tag `v12.0.0206-base` como âncora global de rollback da V207 |
| C3 | **Baseline de testes ANTES de refatorar.** Os 10 cenários E2E_CADASTROS (CAD_EMP_001..CAD_ROLLBACK_001, proposal 0005) devem ser implementados e ficar VERDES contra o monolito ATUAL antes de qualquer mudança de código | V207.0 redefinida como onda test-first (knowledge 0010 + 0013); o plano 0005 põe testes junto das ondas — esta auditoria EXIGE baseline antes |
| C4 | **Rollback por onda incompleto + escape sem número.** Proposal 0005 define anchors só para a Alternativa I; cláusula III-G fala em "~1.5s" sem formalização | Cada onda V207.N declara anchor de rollback no readback; macro de benchmark padronizada roda no hardware real do operador ao fim da V207.4 — ganho projetado < limiar acordado em hearback ⇒ congela em V207.4 |
| C5 | **Contratos V207 nasceriam inválidos no CI.** O ratchet (onda 0116) valida contratos novos contra schema 1.0.0, cujo enum `evidence_kind` não cobre a prática recente (doc 125: 80 rb + 11 hb fora) | Recomendado: executar item A5 (bump 1.1.0 — insumo pronto no doc 125) ANTES da V207.0; alternativa mínima: contratos V207 usam somente o enum 1.0.0 |

## 3. FORTES (incorporar ou justificar por escrito)

1. **Status canônico (V207_NOTA_ARQUITETURA_STATUS_CANONICO) NÃO entra na
   V207.** Trocar o modelo de dados (cópia física de linhas → campo STATUS +
   histórico append-only) no meio do refator de serviços duplica o risco de
   regressão e contraria o critério de Mauricio ("menor regressão possível").
   Destino: design note para V208, com onda própria de migração reversível e
   dual-read transitório. É a única peça das propostas que esta auditoria
   **remove** do escopo V207.
2. **Numeração canônica = V207.0-V207.8** (docs 112/0005). O doc
   33_ROADMAP (ondas 38-45) fica superseded — acrescentar 1 linha de
   apontamento quando o doc 33 for tocado de novo (não exige onda agora).
3. **Divergência de speedup (Codex 3-10x × Antigravity 30-50x): não decidir
   por argumento.** A medição da C4 resolve empiricamente. Registrar como
   pergunta aberta nos readbacks da V207.4, não como conflito.
4. **UserForms/.frx continuam tabu nas ondas V207.0-V207.4.** Onde o plano
   0005 toca `Menu_Principal.frm` (rotas, linhas citadas), a entrega é
   obrigatoriamente `.code-only.txt` + Importador V3 + compile + teste —
   nunca edição de `.frx` (knowledge 0005/0006/0020).
5. **Cadência D plena por gate** (§12 do PROMPT_ARQUITETO + knowledge 0019):
   2 auditores cruzados em CHAT NOVO por gate relevante, outputs em
   `.hbn/proposals/NNNN-<ia>-<tema>.md`, severidades BLOQUEADOR/FORTE/
   MARGINAL, consolidação por árbitro (§12.B3), conflito BLOQUEADOR×
   BLOQUEADOR → Mauricio. O firewall 0022 proíbe rodar qualquer onda V207
   como workflow autônomo de escrita.

## 4. Riscos que o plano ainda não cobre (acrescentados por esta auditoria)

- **Volumetria real**: medir tamanho efetivo das abas (linhas × colunas) antes
  da V207.5 para dimensionar o cache; cache projetado no escuro é a maior
  fonte de surpresa da fase 2.
- **Operador editando aba durante transação em memória**: TX_PENDING cobre
  crash, não cobre edição concorrente humana — exige 1 parágrafo de regra
  operacional no manual do operador (doc humano, não código).
- **Fadiga de 9-13 sessões**: usar gates intra-onda (§12.3, 3-6 por onda) e
  handoff a 50% de contexto (knowledge 0014/0017) — sem exceção heroica.

## 5. Sequência mínima segura (recomendação final)

```
V206 tela a tela fechada → tag v12.0.0206-base → A5 (schema 1.1.0) →
C1 hearback formal → V207.0 test-first (E2E baseline verde) →
V207.1-V207.4 (monolito, anchors por onda) → medição C4 →
[escape: congela em V207.4] OU [V207.5-V207.7 cache com Fase-Lock] →
V207.8 freeze SOMENTE com E2E + TV2 suites + RVS + tela a tela verdes +
hearback explícito de Mauricio (nunca "100%"/"zero risco").
```

## 6. Sinal HBN

🔵 HBN HANDOFF READY — auditoria definitiva pronta. Condições C1-C5 são o
gate de abertura da V207; o doc 127 operacionaliza o caminho até lá.
