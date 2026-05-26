# 109 — Evolução manual do protocolo HBN (PROMPT_ARQUITETO v1.2 → v1.3 + Knowledge 0017)

**Data**: 2026-05-26
**Sessão**: Claude Opus (Cowork, fora do repo) entre handoff 0108 e abertura da próxima sessão Opus
**Autorização**: Mauricio Zanin em chat — *"todas as IAS estão paradas aguardando para começarmos uma nova etapa (...) é o momento adequado para fazermos uma evolução manual"*
**Tipo**: Onda fast_track doc-only — readback `0110-evolucao-protocolo-v13-knowledge-0017.json`
**Princípio violado/aprendido**: Knowledge 0014 + lição "handoff aos 50%" — sessão anterior fechou a 90% de contexto e produziu handoff sob fadiga; esta evolução incorpora aprendizado no próprio protocolo

---

## Por que existe este registro fora do `.hbn/`

O `/Users/macbookpro/Projetos/PROMPT_ARQUITETO_USEHBN_AUTONOMO.md` vive
**fora** do repo Credenciamento (é compartilhado entre os projetos do
Mauricio). O §11 do próprio prompt determina:

> Sempre registrando em `auditoria/00_status/` do Credenciamento (mesmo
> o prompt vivendo fora dele — Credenciamento é a "casa-mãe" do protocolo).

Este documento é o cumprimento desse requisito para a v1.3.

## O que mudou (4 alvos atômicos)

### 1. `PROMPT_ARQUITETO_USEHBN_AUTONOMO.md` v1.2 → v1.3 (FORA do repo)

Path: `/Users/macbookpro/Projetos/PROMPT_ARQUITETO_USEHBN_AUTONOMO.md`

Mudanças:

- **§2 (pré-flight)** — novo passo **F**: lista propostas pendentes em
  `.hbn/protocol-evolutions/*.md` para consumo pelo arquiteto sucessor.
- **§7 (fim-de-sessão)** — novo **Passo 5**: toda IA que assina 🔵
  produz também o artefato de evolução do protocolo; sem ele, o handoff
  é incompleto.
- **§7.3 (NOVO)** — ~140 linhas formalizando "Auto-evolução do protocolo
  a cada handoff". Define:
  - Princípio: a IA que retoma encontra um protocolo mais lapidado que
    a IA que o deixou.
  - Alvos atômicos: prompt, knowledge, guard, schema, CI workflow,
    backlog.
  - Estrutura do arquivo `.hbn/protocol-evolutions/AAAAMMDD-HHmm-onda<N>-proposals.md`.
  - Como o arquiteto sucessor consome (consolida / rejeita / adia).
  - Cadência M0 (manual, agora) → M1 (scheduled task de meta-protocolo
    a cada 12h, futura).
  - Restrições: nunca toca código de domínio; nunca aplica no mesmo
    turno em que propõe; nunca "reescreve o prompt inteiro".
- **§11 (versionamento)** — linha 1.3 no changelog com origem (sessão
  Opus 2026-05-26 11:18 a 90% de contexto + lição de Mauricio sobre
  handoff aos 50%).
- **Cabeçalho** — "Para quem é" agora referencia explicitamente §7.3
  para qualquer IA produzindo handoff.

### 2. `.hbn/knowledge/0017-handoff-aos-50-pct-contexto.md` (NOVO, dentro do repo)

Knowledge canônica nova formalizando a lição:

- Regra dura: handoff inicia aos 50% de contexto consumido.
- Orçamento 50/30/20: 50% trabalho substantivo, 30% redação dos 3
  artefatos de handoff, 20% buffer para ajuste final.
- Gatilhos secundários (knowledge 0014 expandido).
- Heurísticas de auto-medição honesta do contexto.
- Cláusula de exceção (com documentação obrigatória da exceção).
- Como o sucessor consome esta knowledge.
- Origem documentada (sessão 1118 + lição Mauricio + sessão de
  evolução manual).
- Como verificar (grep + sinais subjetivos).

### 3. `auditoria/00_status/108_PROMPT_RETOMADA_SESSAO_OPUS.md` (atualizado)

- Seção "⚠️ Atenção — janela de melhoria do protocolo entre sessões"
  agora afirma que a evolução para v1.3 **já aconteceu** (não "pode ter
  acontecido"), com instrução obrigatória de leitura do §7.3.
- Seção "Quando atingir ~40-50% de contexto" agora exige TRÊS artefatos
  no handoff: (1) handoff operacional, (2) prompt de retomada 109,
  (3) **proposta de evolução do protocolo** em
  `.hbn/protocol-evolutions/`. Inclui orçamento de contexto 50/30/20
  derivado da fadiga real desta linha do tempo.

### 4. `.hbn/knowledge/INDEX.md` (atualizado)

- Linha nova: "Handoff aos 50% de contexto — orçamento obrigatório de
  qualidade" apontando para `0017-handoff-aos-50-pct-contexto.md`.
- Data `ultima-atualizacao` bumped para 2026-05-26.

## O que NÃO mudou (escopo explícito)

- Nenhum código de domínio (`src/vba/`, `local-ai/vba_import/`,
  `Svc_*`, `Mod_Types`, `Importador_V3`, `.frm`).
- Nenhuma onda V206 aberta ou alterada.
- Nenhuma knowledge 0001-0016 modificada.
- Nenhum schema (`.hbn/schemas/*.schema.json`) alterado.
- Nenhum guard (`scripts/hbn-guards/*.sh`) alterado.
- Backlog §4 do PROMPT_ARQUITETO mantido (Trilha A1-A5 etc. continuam
  com texto da v1.0 — refresh fica para próxima onda dedicada).

## Próximas evoluções recomendadas (não nesta onda)

1. **Schema JSON formal** para `.hbn/protocol-evolutions/` — depois de
   validarmos o formato markdown em uso real por 1-2 sessões.
2. **Refresh do backlog §4** do PROMPT_ARQUITETO — está congelado em
   Onda 36 (Trilha A1-A5) enquanto o projeto está em 38.2.1-AR1-FIX2-PERF.
   Sem o refresh, scheduled-task arquiteto propõe ondas obsoletas.
3. **Scheduled task M1** de meta-protocolo a cada 12h consumindo
   `.hbn/protocol-evolutions/` — separada da scheduled task de 6h que
   consome backlog §4.
4. **Primeira aplicação prática do §7.3** — produzir o primeiro
   `.hbn/protocol-evolutions/...md` real (esta própria sessão pode
   fazer isso como exemplo trabalhado, mas Mauricio priorizou knowledge
   0017 primeiro).

## Sequência de versionamento (executada por Mauricio do Mac)

```
cd /Users/macbookpro/Projetos/Credenciamento
```

```
git add .hbn/knowledge/0017-handoff-aos-50-pct-contexto.md .hbn/knowledge/INDEX.md .hbn/readbacks/0110-evolucao-protocolo-v13-knowledge-0017.json .hbn/relay/INDEX.md auditoria/00_status/108_PROMPT_RETOMADA_SESSAO_OPUS.md auditoria/00_status/109_EVOLUCAO_MANUAL_PROTOCOLO_OPUS_V13.md
```

```
git commit -m "docs(hbn): evolucao protocolo v13 + knowledge 0017 handoff 50pct" -m "PROMPT_ARQUITETO_USEHBN_AUTONOMO.md (fora do repo) bumped v1.2 -> v1.3 com auto-evolucao do protocolo a cada handoff (par.7.3 + Passo 5 do par.7 + passo F do par.2 pre-flight). Knowledge 0017 nova formalizando handoff aos 50pct de contexto com orcamento 50/30/20. Prompt de retomada 108 atualizado para exigir 3 artefatos no proximo handoff. Registro fora do .hbn em 109_EVOLUCAO_MANUAL_PROTOCOLO_OPUS_V13.md. Readback fast_track 0110. Autorizado por Mauricio em chat 2026-05-26 pos-handoff 0108."
```

```
git push origin codex/v12-0-0206-planejamento
```

## ERP

A produzir como `.hbn/results/0110-exec-evolucao-protocolo-v13.json`
após o push, registrando: commit hash final, output dos 5 guards,
output do push. Pode ser feito pela própria sessão Opus que abrir o
prompt 108 atualizado, antes de iniciar a auditoria cruzada (~1
minuto de overhead).

## Lições novas para `.hbn/protocol-evolutions/` (futuras propostas)

L29 (candidata): toda evolução manual do `PROMPT_ARQUITETO` (fora do
repo) deve produzir documento espelho em `auditoria/00_status/NNN_EVOLUCAO_*`
no Credenciamento conforme §11. Esta sessão cumpriu manualmente —
formalizar como gate no §7.3 quando alvo for `prompt_arquiteto`.

L30 (candidata): guard `assert-canonical-root.sh` bloqueia commits de
sessões Cowork que rodam em sandbox com path montado diferente. Hoje a
sessão Cowork deixa working tree pronto e Mauricio commita do Mac. Não
é fricção crítica (modelo "IA propõe, humano commita" é coerente com
HBN), mas vale registrar como característica conhecida do ambiente.
