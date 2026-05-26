# Prompt de retomada — sessão Claude Opus V12.0.0206 (pós-handoff 2026-05-26)

> **Como usar:** Mauricio copia o bloco abaixo (entre as linhas `---PROMPT---`)
> e cola no primeiro turno de uma nova sessão Claude Opus 4.7 no repositório
> `/Users/macbookpro/Projetos/Credenciamento`. A nova IA tem contexto limpo
> e recebe o que precisa para continuar.

---PROMPT---

✅ HBN ACTIVE

Você é Claude Opus 4.7 assumindo a continuidade do bastão V12.0.0206 do
Sistema de Credenciamento. A sessão anterior (2026-05-26 ~14:30 → ~04:25)
fechou 4 ondas e produziu um handoff completo. Bastão **permanece com você**;
esta é uma sessão sucessora com contexto limpo.

**Raiz canônica:** `/Users/macbookpro/Projetos/Credenciamento`
**Branch:** `codex/v12-0-0206-planejamento`
**Data de retomada:** 2026-05-27 (ou data atual)
**Anchor funcional V206:** commit `433f25c` (Sexteto APROVADO em
`VR_20260526_035523`)

## Leitura obrigatória inicial (na ordem)

Leia, **antes de qualquer ação**:

1. `.hbn/relay/INDEX.md` — estado vivo
2. `.hbn/messages/20260526-0425-handoff-fim-sessao-opus.md` — handoff
   completo da sessão anterior (12 itens + análise técnica F4 e F5)
3. `.hbn/results/0106-exec-onda38-2-1-ar1-sanear-contadores.json` —
   último ERP, contém os findings F1–F5
4. `.hbn/knowledge/0014-protocolo-fim-de-sessao.md`
5. `.hbn/knowledge/0015-readback-opening-bootstrap.md`
6. `.hbn/knowledge/0016-bump-build-label-anti-conflito.md`
7. `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` — capítulos M9, L22, L23,
   L24, M15, M16, M17 (pré-trabalho da Onda 38.2.2)
8. `AGENTS.md` — regras de operação

Verifique o estado:

```bash
cd /Users/macbookpro/Projetos/Credenciamento && \
git log --oneline -8 && \
git status -s && \
bash scripts/hbn-guards/hbn-guards-runner.sh
```

Esperado:
- HEAD em commit de handoff
- Working tree limpo
- 5/5 guards verdes

## Estado consolidado ao iniciar

**Fechadas:** Onda 38.2.1 (revert filtros) + Onda 38.2.1-AR1 (saneamento
contadores AR1) + hotfix BUMP + 2 knowledges novas (0015, 0016).

**Findings ativos em aberto (do ERP 0106):**

- **F1** (cadastro empresa ID 001) → ✅ RESOLVIDO
- **F2** (entidade no topo) → ✅ RESOLVIDO
- **F3** (filtros faltantes) → próxima onda 38.2.2
- **F4** (lentidão cadastros) → **promovido para V206** (era V207)
- **F5** (chave estável + deleção de linhas) → **promovido para análise
  arquitetural V206** (era V207)
- F-NEW1/F-NEW2 (cobertura inativas) → não testados por ausência de
  dados; lógica pronta

## Diretrizes Mauricio (decisões 2026-05-26)

- **Estabilizar V206 primeiro** (cadastros corretos + performance +
  filtros + PDF) antes de qualquer evolução arquitetural.
- **Antes do freeze**: passagem assistida tela-a-tela.
- **Caminho A** (AR1 antes de 38.2.2) seguiu como previsto.
- **F4 lentidão** → resolver agora para uso em PCs antigos.
- **F5 chave estável** → trazer alternativas (CNPJ vs ID monotônico vs
  soft delete) com base no comportamento do código que permite deleção
  de linhas/colunas. **Análise feita no handoff item 13.B-D.**
- **Validação exaustiva** de inabilitação/reabilitação/rodízio antes
  do freeze.

## Sua primeira ação (1 frase)

Apresente um plano de execução para uma das 3 candidatas e peça aprovação
do Mauricio:

- **(A)** Onda 38.2.1-AR1-FIX2 (~5 linhas, urgente) — algoritmo
  monotônico em `Util_Planilha.ProximoId` e
  `Util_Sanear_Contadores.SanearContadoresAR1`. Resolve risco R1
  (reuso de IDs) definitivamente.
- **(B)** Onda 38.2.x-perf — wrapper `Util_Excel_Performance.bas` +
  aplicar em rotinas de cadastro (`Repo_Empresa.Inserir`,
  `Repo_Empresa.Atualizar`, etc.). Resolve F4 (lentidão em PCs antigos).
- **(C)** Onda 38.2.2 — filtros nativos do Menu_Principal (handlers
  `TextBoxNN_Change` + função filtro pura), **com pré-trabalho
  deep-dive PHAGOCYTOSIS** já feito antes do readback.

**Recomendação Opus**: (A) primeiro (microdelta trivial elimina risco),
depois (B), depois (C). (A) + (B) podem até ser combinadas em 1
microdelta se ambas tocarem só `Util_*.bas` e `App_Release.bas`.

Mauricio decide a ordem.

## Restrições inalteradas

- ✅ HBN ACTIVE
- Bastão com Claude Opus 4.7 até freeze V12.0.0206
- Codex retorna como auditor adversarial pós-implementação
- Sequência: readback (PENDING) → hearback (confirmed) → execução → commit
- Não tocar: `Mod_Types.bas`, `Importador_V3.bas`, serviços blindados
  (`Svc_Rodizio`, `Svc_Avaliacao`, `Svc_OS`, `Svc_PreOS`), `local-ai/incoming/**`
- `Util_Planilha.bas` está na lista forbidden do readback 0106 — para
  alterar (caminho A), abrir readback novo com escopo expandido
- Importação operacional somente via `ImportarPacoteV3_Delta` (jamais
  completo)
- Knowledge 0016 vigente: deixar `App_Release.bas` no estado da onda
  anterior; deixar o Importador V3 fazer o BUMP

## Quando atingir ~50% de contexto

Aplicar `knowledge/0014-protocolo-fim-de-sessao` — produzir novo handoff
em `.hbn/messages/AAAAMMDD-HHmm-handoff-fim-sessao-opus.md` e novo
prompt em `auditoria/00_status/<N>_PROMPT_RETOMADA_SESSAO_OPUS.md`.

---PROMPT---

## Referências

- Handoff origem: [`.hbn/messages/20260526-0425-handoff-fim-sessao-opus.md`](../../.hbn/messages/20260526-0425-handoff-fim-sessao-opus.md)
- ERP último fechado: [`.hbn/results/0106-exec-onda38-2-1-ar1-sanear-contadores.json`](../../.hbn/results/0106-exec-onda38-2-1-ar1-sanear-contadores.json)
- Readback de handoff: [`.hbn/readbacks/0107-handoff-fim-sessao-opus.json`](../../.hbn/readbacks/0107-handoff-fim-sessao-opus.json)
- Relay: [`.hbn/relay/INDEX.md`](../../.hbn/relay/INDEX.md)
- Knowledge 0014: [`.hbn/knowledge/0014-protocolo-fim-de-sessao.md`](../../.hbn/knowledge/0014-protocolo-fim-de-sessao.md)
