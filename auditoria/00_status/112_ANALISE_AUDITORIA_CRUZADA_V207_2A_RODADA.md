---
titulo: 112 — Análise consolidada 2ª rodada auditoria cruzada V12.0.0207 (Codex + Antigravity)
diataxis: explanation
hbn-track: meta (ato cognitivo sem readback safe_track)
hbn-status: pendente_hearback_mauricio
audiencia: ambos
versao-sistema: V12.0.0207
data: 2026-05-26
sucessor-de: 111_ANALISE_AUDITORIA_CRUZADA_V207.md
---

# 112 — Análise consolidada 2ª rodada auditoria cruzada V206→V207

**Data**: 2026-05-26 ~16:00 BRT
**Sessão**: Claude Opus 4.7 sucessora pós-handoff 1526 (raiz canônica `/Users/macbookpro/Projetos/Credenciamento`)
**Trigger**: 4 arquivos `.hbn/proposals/0005-0008-*.md` entregues por Codex (commit `039b2ec`) + Antigravity (commit `32e1bad`)
**Entradas**:
- [`0005-codex-refinamento-arquitetural-v207.md`](../../.hbn/proposals/0005-codex-refinamento-arquitetural-v207.md) (~35KB — refinamento profundo I+II, 9 ondas detalhadas)
- [`0006-codex-recomendacao-alternativa-i-ou-ii.md`](../../.hbn/proposals/0006-codex-recomendacao-alternativa-i-ou-ii.md) (~7.5KB — recomendação)
- [`0007-antigravity-refinamento-arquitetural-v207.md`](../../.hbn/proposals/0007-antigravity-refinamento-arquitetural-v207.md) (~16KB — refinamento sistêmico)
- [`0008-antigravity-recomendacao-alternativa-i-ou-ii.md`](../../.hbn/proposals/0008-antigravity-recomendacao-alternativa-i-ou-ii.md) (~6KB — recomendação)

---

## 1. Veredito consolidado em 1 frase

**Codex e Antigravity convergem 100% em: Alternativa II (Opção 4 híbrida) com os 3 mesmos guard-rails sistêmicos invioláveis (Fase-Lock + Invalidação Stateless + Callback Explícito).** Opus 4.7 endossa a recomendação. Decisão final aguarda hearback explícito de Mauricio.

## 2. Convergências (8 pontos — base sólida da 2ª rodada)

| # | Convergência | Codex | Antigravity |
|---|---|---|---|
| 1 | **Recomendação primária = Alternativa II** | Explícita §1 (com fase-lock obrigatório) | Explícita §1 ("fortemente recomenda") |
| 2 | **Fadiga operacional 12-17 ondas é o calcanhar de Aquiles da Alternativa I** | §1.7 + §3 ("fadiga de operador alta") | §2.1 ("redução ~50% sobrecarga operacional") |
| 3 | **F-NEW4 perceptual está no reload cell-a-cell de ListBoxes, não em Repos** | §2.2 lista 8 ListBox prioritárias (EMP/C/CR/A/H/OS/AV_Lista) | §2.2 ("reload cell-a-cell continuaria mesmo após gravação em bloco") |
| 4 | **Os 3 guard-rails sistêmicos são contratos invioláveis** | §2.4 + §2.7 (fase-lock crítico, marcador TX_PENDING persistente, snapshot antes de writeback) | §3 (Fase-Lock + Invalidação Stateless + Callback Explícito) |
| 5 | **V207.5 deve ser cache read-only com flag de fallback** | §2.1 onda V207.5 + §4 edge cases | §3 + §2.7 ("complexidade interna 2 fontes de verdade") |
| 6 | **E2E_CADASTROS é gate de entrada (V207.1), não débito final** | §1.1 onda V207.1 com 10 cenários nomeados | §2.4 ("RVS ganha suíte E2E_CADASTROS=10/0") |
| 7 | **Alternativa III (EDRA/eventos) é descartada para V207** | §5 (III-G só como gate de bifurcação operacional, não nova arquitetura) | §4 (EDRA tem curva alta + risco de loop assíncrono) |
| 8 | **Tag `v12.0.0207-base-monolito` no Git como anchor de fase-lock** | Implícito em "freeze V207.4" + anchor de rollback por onda | Explícita §3 guard-rail 1 |

## 3. Divergências reais (2 pontos — decisões finais para Mauricio)

### 3.1 Alternativa III-G (Gate de Bifurcação Controlada)

| | Codex (§5 de 0005) | Antigravity (§4 de 0008) |
|---|---|---|
| Status | "Variação operacional aceitável" | "Sistemicamente descartada" |
| Posição | Reduz aposta antecipada em cache; mas Codex recomenda escolher II direto porque diagnóstico já aponta ListBox | "Curva de aprendizado complexa + custo depuração alto" |
| Aplicabilidade | Se Mauricio quiser adiar decisão até medir V207.4 real | N/A — Antigravity quer decisão antecipada |

**Implicação:** divergência é sobre **timing da decisão**, não sobre arquitetura. Codex dá opção de hedge; Antigravity prefere commitment antecipado. **Sugestão Opus**: tratar III-G como cláusula de escape, não como caminho primário — se V207.4 medir e o gargalo ainda for forte, V207.5 vira automática; se medir e gargalo for marginal, congela V207.4 sem cache.

### 3.2 Knowledges novas a criar

| | Codex | Antigravity |
|---|---|---|
| K0019 proposta | (não nomeia knowledge nova específica; menciona "doc-delta por onda") | `0019-limites-do-hibridismo.md` — proíbe cache em rotinas de persistência |
| K0020 proposta | (não nomeia) | `0020-invalidação-estateless.md` — padrão declarativo obrigatório |

**Implicação:** Antigravity propõe knowledges explícitas; Codex sintetiza em contratos por onda. **Sugestão Opus**: aceitar nomenclatura Antigravity (`0019-limites-hibridismo` + `0020-invalidacao-stateless`) como ondas safe_track doc-only no início de V207.

## 4. Sequência consolidada de ondas V207 (proposta unificada Codex + Antigravity)

A sequência de Codex em [`0005`](../../.hbn/proposals/0005-codex-refinamento-arquitetural-v207.md) §2.1 é a mais detalhada (com IDs de readback e responsável por onda). Antigravity ratifica os blocos 0-4 e 5-7 no §1 de [`0007`](../../.hbn/proposals/0007-antigravity-refinamento-arquitetural-v207.md). Síntese:

| Onda | Readback proposto | Escopo nuclear | Gate humano | Anchor rollback |
|---|---|---|---|---|
| **V207.0** | `0120-rb-v207-0-foundation-idperf` | `Util_MaxIdOperacional` pair-aware + F-NEW3 `NumberFormat="@"` + handler-before-flag + métricas baseline | IDs, AR1, wrapper, formato verdes | `ee75b30` |
| **V207.1** | `0121-rb-v207-1-e2e-cadastros` | Bateria `E2E_CADASTROS` (10 cenários nomeados Codex) executável + baseline F-NEW4 medido | Bateria falha em baseline, passa após V207.4 | V207.0 |
| **V207.2** | `0122-rb-v207-2-svc-empresa` | `Svc_CadastroEmpresa` + rota única `Repo_Empresa` + escrita em bloco + reload preguiçoso | E2E.Empresa verde + Audit_Log mutação | V207.1 |
| **V207.3** | `0123-rb-v207-3-svc-entidade-fnew3` | `Svc_CadastroEntidade` + `Repo_Entidade` + F-NEW3 fechado na origem | ID `005` textual + C_Lista/C_ListaRodizio coerentes | V207.2 |
| **V207.4** | `0124-rb-v207-4-servico-cred-preencher` | `Svc_CadastroServico` + `Svc_CredenciamentoCadastro` + `Preencher.bas` array-based + Repos residuais envelopados | RVS Trio + E2E_CADASTROS + **medição F-NEW4 documentada** | V207.3 |
| **Gate fase-lock** | `0125-rb-v207-gate-cache` | **Decisão humana formal**: abrir cache ou congelar V207.4 | Tag `v12.0.0207-base-monolito` cravada se prosseguir | — |
| **V207.5** | `0126-rb-v207-5-cache-readonly-listas` | Cache read-only de listas críticas (EMP/C/CR/A/H/CR_Lista; OS/AV_Lista se medição confirmar) + flag de fallback | Equivalência de linhas/colunas + fallback funcional | V207.4 |
| **V207.6** | `0127-rb-v207-6-cache-invalidation-dirty` | Invalidação por domínio (EMPRESAS/ENTIDADE/CAD_SERV/CREDENCIAMENTO/PREOS/CAD_OS) + dirty check leve (rowHash+ar1+ultimaLinha+cacheVersion) | Cadastro invalida só domínios certos + edição manual reconstrói | V207.5 |
| **V207.7** | `0128-rb-v207-7-tx-minima-cache` | Writeback transacional mínimo (aba técnica oculta com `TX_PENDING` + snapshot persistente + recovery na abertura) | Erro vivo restaura + crash simulado recuperável | V207.6 |
| **V207.8** | `0129-rb-v207-8-freeze-hibrido` | Docs + thresholds + decisão V208+ | RVS + E2E + teste PC antigo verdes + zero bug crítico | V207.7 |

**Estimativa Codex**: 45-70 homem-hora-IA, 9-13 sessões Opus+Codex, 7-9 gates humanos.
**Estimativa Antigravity**: convergente ("redução ~50% vs Alternativa I").

## 5. Os 3 Guard-rails Sistêmicos (contratos invioláveis para Alternativa II)

Citação literal Antigravity §3 (Codex ratifica em §2.4 + §2.2 + §1.3 dos contratos):

> **Guard-rail 1 — Barreira de Fase (Fase-Lock)**: As ondas de caching de listas (V207.5+) só poderão ser iniciadas após a homologação formal do Gate de Liberação das ondas 0-4. O Git deve ser carimbado com uma tag interna (ex.: `v12.0.0207-base-monolito`) e o RVS com a nova bateria `E2E_CADASTROS` deve estar 100% verde. **Proibido abrir branches ou comitar código de cache em paralelo.**

> **Guard-rail 2 — Padrão de Invalidação Stateless**: O cache de listas do `Menu_Principal` não deve tentar atualizar "cirurgicamente" um único item alterado em sua coleção local. Qualquer chamada de invalidação de cache (`Cache_Invalidate("EMPRESAS")`) deve forçar a **reconstrução total da coleção em memória lendo dinamicamente da planilha**. Garante idempotência e imunidade a inconsistências de mutação parcial.

> **Guard-rail 3 — Registro Explícito de Callback**: Toda operação de gravação nos repositórios (`Repo_*.bas`) que afete dados exibidos na tela deve invocar expressamente a rotina de invalidação da UI (`Menu_Principal.InvalidarCache(tipoAba)`), sob pena de falha mecânica no analisador estático de código.

Codex adiciona explicitamente um 4º contrato implícito não-numerado mas presente em §2.7:

> **Recovery persistente pós-crash**: Sem marcador `TX_PENDING` em aba técnica oculta + snapshot de ranges afetados, V207.7 não pode existir — V207.5+ permanece read-only e operações mutadoras seguem via repositório direto V207.4. **Rollback puramente em memória só vale enquanto o processo VBA está vivo.**

## 6. Edge cases novos da 2ª rodada (não cobertos pela 1ª)

| Edge case | Origem | Mitigação proposta |
|---|---|---|
| **Concorrência: macro rodando enquanto cadastra** | Codex §4 | Flag global curta por domínio + desabilitar botões mutadores + sem `DoEvents` em transação |
| **Crash em meio à transação memória→célula** | Codex §4 + Antigravity §2.7 | Marcador persistente `TX_PENDING` em aba oculta + recovery na abertura seguinte |
| **Migração workbooks V204/V205 com dados parciais** | Codex §4 + Antigravity §4.2 | Onda boot `Util_Sanear_Contadores` + rotina automática "Reconciliação e Upgrade de Esquema" |
| **PCs Windows 7/8 memória limitada** | Codex §4 (com testes 1x/5x/10x base sintética) | Cache por domínio + fallback automático em `Out of memory` + dicionário late-bound |
| **Edição manual de aba durante cadastro** | Codex §4 + Antigravity §2.7 | Dirty checking trata edição como conflito; aborta operação mutadora + reconstrói cache |
| **Proteção de abas e restauração Excel** | Codex §4 | Handler armado antes de alterar flags + restauração em sucesso/erro/rollback |
| **Múltiplos workbooks abertos (`ActiveWorkbook` ≠ `ThisWorkbook`)** | Codex §4 | Cache/Repos/Svc usam `ThisWorkbook` sempre; testes confirmam não-escrita em arquivo errado |
| **`.frm/.frx` drift na importação V207** | Codex §4 | Validar abertura UserForm + compile após cada toque em `.frm`; evitar controles novos se módulo basta |
| **Sair de município durante V207 intermediário** | Antigravity §4.1 | Cada commit ERP de onda mantém integridade operacional RN-01..RN-17; ejeção sempre possível |
| **PDFs gerados em V206 não devem mudar layout em V207** | Antigravity §4.3 | Rotina PDF V207 herda parâmetros `PrintArea`/largura coluna V205; robustez só no tratamento de exceções de spooler |

## 7. Knowledges + Quick wins independentes da decisão V207

**Knowledges novas (safe_track doc-only, prioridade antes de V207.0):**
- `knowledge/0018-doc-delta-pattern.md` — proposto por Antigravity §3.3 da 1ª rodada (já em [`111`](111_ANALISE_AUDITORIA_CRUZADA_V207.md) §8.1)
- `knowledge/0019-limites-do-hibridismo.md` — proibir cache em rotinas de persistência (`Repo_*.Inserir/Atualizar/Excluir`); limitar a leituras de ListBox
- `knowledge/0020-invalidacao-stateless.md` — padrão declarativo de invalidação por reconstrução total

**Quick wins V206 (Onda 38.2.2 paralela — independem da decisão V207):**
- Item 68 Codex (sev. alto): `Util_MaxIdOperacional(nomeAba)` pair-aware EMPRESAS+EMPRESAS_INATIVAS / ENTIDADE+ENTIDADE_INATIVOS
- Item 69 Codex (sev. médio): instalar `On Error GoTo` ANTES de `Util_IniciarBlocoRapido` em 5 callers (`Repo_Empresa.bas:80,242,319,476` + `Util_Sanear_Contadores.bas:44`)
- Fix F-NEW3 sistemático: `Range.NumberFormat = "@"` em coluna A de TODAS as abas operacionais (entidade, empresa, credenciamento, atividade, servico)
- Filtros nativos `TextBox16..22_Change` no `Menu_Principal.frm` (revert da onda 38.2.1 + função filtro pura)
- Envelopamento `Util_Excel_Performance` em cadastros `.frm` (Menu_Principal entidade/empresa-alt + Credencia_Empresa + Cadastro_Servico)

## 8. Recomendação Opus 4.7 final

**Endorso a Alternativa II com os 3 guard-rails sistêmicos como contratos invioláveis.**

Razões:

1. **Convergência massiva 2 IAs auxiliares + 4 fatores do projeto** (memórias `project_papel_opus_4_7_ate_v203_estavel`, `project_credenciamento_aplicacao_fundadora`, `project_v206_estabilizacao_findings_f4_f5`, `feedback_protocolo_validacao_cruzada_ias`).
2. **F-NEW4 perceptual é UX**, não microperformance — e a Alternativa II ataca onde o usuário sente (reload cell-a-cell de ListBox).
3. **Fadiga operacional 12-17 ondas vs 7-9** é argumento prático decisivo para o pipeline atual (Opus arquiteto + Codex executor + Mauricio operador VBE manual).
4. **Universal Migration Format preservado**: cache é derivado da planilha + pode ser desligado por flag + planilha continua fonte de verdade.
5. **Os 3 guard-rails neutralizam o risco principal** (incoerência cache/planilha) com contratos mecânicos auditáveis no commit.

**Cláusula de escape recomendada** (sub-versão da III-G Codex): se na medição V207.4 o reload pós-cadastro estiver abaixo do limiar humano (a definir, sugestão ~1.5s em PC antigo), congelar em V207.4 e **NÃO abrir V207.5+**. A tag `v12.0.0207-base-monolito` vira tag oficial V207 e V207.5+ é deferido para release futura. Isso preserva a opcionalidade que Codex sugere em §5.

## 9. Decisão pendente → hearback Mauricio

Mauricio precisa decidir entre 3 hipóteses (sugestão Opus em negrito):

- ✅ **(II) Alternativa II com os 3 guard-rails + cláusula de escape V207.4 — RECOMENDADA**
- ⚠ (II-bis) Alternativa II sem cláusula de escape (commitment full V207.0-V207.8)
- ❌ (I) Alternativa I (Caminho 1 puro V207 + V208 sequencial) — rejeitada por ambas IAs auxiliares
- ❌ (III) Alternativa III-G ou EDRA — rejeitadas

**Sinalização HBN**: aguardando 🟢 HBN CONFIRMED Mauricio sobre hipótese (II) ou (II-bis). Sem confirmação explícita, nenhuma onda de código V207 abre.

## 10. Próximos passos pós-hearback

### Caminho confirmado II (com ou sem escape)

1. **Onda safe_track doc-only consolidando knowledges 0018+0019+0020** (1 readback único, fast_track de docs)
2. **Readback `0120-rb-v207-0-foundation-idperf`** abre primeira onda V207 substantiva (quick wins + base defensiva)
3. Sequência prosseguindo pelos IDs `0121-0129` conforme tabela §4

### Em paralelo (independente da decisão V207)

**Onda 38.2.2 V206 puro** — escopo independente, pré-trabalho PHAGOCYTOSIS consolidado (M9, L22-L24, M15-M17), pode abrir já com readback `0111-rb-onda-38-2-2-v206-puro-quick-wins-filtros-envelopamento-fnew3`:
- Itens 68/69 Codex + F-NEW3 sistemático + filtros nativos + envelopamento .frm
- Anchor: `ee75b30` (anchor V206 funcional inalterado)
- Gate humano: RVS Trio + cadastros manuais + filtros funcionais
- **Aproveitamento crítico**: contexto Opus desta sessão ainda limpo (~25% consumido), capaz de conduzir readback+execução+gate completos da 38.2.2 sem handoff.

## 11. Anchor de rollback

- **HEAD após esta sessão**: a definir após commit consolidação (será sucessor de `32e1bad`)
- **Build operacional V206 inalterado**: `ad5b487+ONDA38.2.1-AR1-FIX2-PERF` (workbook do operador)
- **RVS Trio APROVADO**: `VR_20260526_102200`
- **Tag V205 oficial**: `v12.0.0205` (release congelada)
- 4 arquivos `.hbn/proposals/0005-0008-*` versionados em `039b2ec` (Codex) + `32e1bad` (Antigravity)

## 12. Memory updates desta análise

- **Convergência 2ª rodada**: Codex+Antigravity unânimes em Alternativa II com 3 guard-rails. Decisão V207 essencialmente travada; só pendência é hipótese II vs II-bis (com/sem cláusula de escape V207.4).
- **Knowledges novas confirmadas**: 0018 (Doc-Delta), 0019 (Limites Hibridismo), 0020 (Invalidação Stateless) — entram em onda safe_track doc-only ANTES de V207.0.
- **Padrão `TX_PENDING` em aba técnica oculta**: contrato emergente para sobreviver crashes de Excel durante writeback transacional cache-originado.
- **III-G como cláusula de escape, não caminho primário**: incorporada na recomendação Opus como guard-rail adicional (congelar em V207.4 se medição mostrar gargalo marginal).
- **Onda 38.2.2 V206 puro independente** continua disponível para abertura imediata em paralelo.

---

🔵 HBN PENDING HEARBACK — Mauricio decide entre II e II-bis antes de qualquer ação V207. Onda 38.2.2 V206 puro pode abrir em paralelo sob aprovação explícita.
