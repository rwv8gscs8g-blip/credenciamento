---
titulo: Relay HBN — coordenacao inter-IA do Credenciamento
versao-protocolo: HBN 0.3.1 + Cura Onda 36 (contratos executáveis)
proprietario-bastao: Codex (Onda 38 em pause aguardando hearback Mauricio para readback 0094 com scope expandido — bug confirmado em Menu_Principal.frm+Preencher.bas, NAO em Rel_*). Opus encerrou Onda 36.1 (knowledge 0014 protocolo fim-de-sessao) com auto-aplicacao em .hbn/messages/20260525-0100-handoff-fim-sessao-opus.md. Disponivel para nova ativacao manual do PROMPT_ARQUITETO em Trilha A item A3 (CI semanal) ou A4 (revisao bypasses).
ciclo-ativo: V12.0.0206 em planejamento. V12.0.0205 permanece congelada como release oficial; V12.0.0206 deve absorver ajustes incrementais, testes manuais residuais, PDF automático robusto e pequenos débitos técnicos sem reabrir regras RN-01 a RN-17. Camada de protocolo executável adicionada pela Onda 36 antes de qualquer retomada.
ancora-estavel-atual: V12-202-Z011-onda17-fechada (INTOCAVEL ate aprovacao operador) — build f7aa84f+ONDA17.MD2-bloco-a-fechamento-onda17, Quinteto VR_20260503_234443 APROVADO V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0+IntegridadeBase=3/0; Quarteto VR_20260504_000004 APROVADO sintaxe IDENTICA ao MD-17.1.e V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=65/0 MANUAL=5.
proxima-acao: Mauricio salvar workbook V5 (Cmd+S no Excel apos compile OK + smoke APROVADO), depois commit Onda 37.3+37.4, push, e abrir NOVA sessao Codex usando auditoria/00_status/107_SUPERPROMPT_CODEX_RETOMADA_ONDA_38_PDF.md. Codex retoma com base V5 limpa + carimbo ONDA37.4-teste-delta-noop, usando exclusivamente ImportarPacoteV3_Delta (knowledge 0018).
ultima-atualizacao: 2026-05-25T01:00:00-0300 (Onda 36.1 fechada; knowledge 0014 protocolo fim-de-sessao publicado e auto-aplicado; handoff Opus em .hbn/messages/20260525-0100; Codex em hold no readback 0094 da Onda 38)
---

## Onda 37.3 EM EXECUCAO — Reset src/vba para V5 (Opus, bastao recebido de Codex)

| Campo | Valor |
|---|---|
| Track | safe_track (reset estrutural de src/vba e local-ai/vba_import) |
| Readback | [readbacks/0093-onda37-3-reset-src-vba-para-v5.json](../readbacks/0093-onda37-3-reset-src-vba-para-v5.json) |
| Hearback | confirmed (Mauricio em chat 2026-05-24 apos falha de compile pos-37.2) |
| ERP | [results/0093-exec-onda37-3-reset-src-vba-para-v5.json](../results/0093-exec-onda37-3-reset-src-vba-para-v5.json) — delivered_for_human_gate |
| Doc tecnico | [auditoria/03_ondas/onda_37_3_reset_src_vba_v5/37_3_TECNICO.md](../../auditoria/03_ondas/onda_37_3_reset_src_vba_v5/37_3_TECNICO.md) |
| Backup pre-reset | [backup_pre_reset/](../../auditoria/03_ondas/onda_37_3_reset_src_vba_v5/backup_pre_reset/) (66 arquivos + manifest SHA-256) |
| Manifest incoming V5 | [manifest_incoming_v5.sha256.csv](../../auditoria/03_ondas/onda_37_3_reset_src_vba_v5/manifest_incoming_v5.sha256.csv) (64 arquivos validados) |
| Estado src/vba apos reset | 64 arquivos = paridade exata com export V5 (verificado via diff -rq vazio) |
| Workbook V5 .xlsm | INTACTO no disco (operador fechou sem salvar) |
| local-ai/incoming/ | INTACTO (read-only) |
| Bastao apos compile OK | volta para Codex (Onda 38 = MD33-restart correto sobre base V5 limpa) |



## Onda 37.2 ENTREGUE PARA GATE HUMANO — Reversao drift MD33 (Codex)

| Campo | Valor |
|---|---|
| Track | safe_track (toca VBA e pacote importavel declarado) |
| Readback | [readbacks/0092-onda37-2-reversao-md33.json](../readbacks/0092-onda37-2-reversao-md33.json) |
| Hearback | confirmed — Mauricio informou aprovacao do readback 0092 no chat |
| ERP | [results/0092-exec-onda37-2-reversao-md33.json](../results/0092-exec-onda37-2-reversao-md33.json) |
| Doc tecnico | [37_2_TECNICO.md](../../auditoria/03_ondas/onda_37_2_reversao_md33/37_2_TECNICO.md) |
| Procedimento | [37_2_PROCEDIMENTO_IMPORT.md](../../auditoria/03_ondas/onda_37_2_reversao_md33/37_2_PROCEDIMENTO_IMPORT.md) |

### Resultado Onda 37.2

- `src/vba/Importador_V3.bas`, `src/vba/Menu_Principal.frm` e
  `src/vba/Preencher.bas` foram restaurados ao estado equivalente ao export
  V5.
- Espelhos declarados em `local-ai/vba_import/` foram atualizados para o gate
  humano; a importacao operacional deve vir somente dessa pasta.
- `local-ai/incoming/`, `backups/vba/`, workbook V5 e `Menu_Principal.frx`
  permaneceram intactos.
- ERP esta em `delivered_for_human_gate`, com compile VBE pendente de
  confirmacao humana.

🟠 SOURCE DRIFT DETECTED: a reversao corrige o drift MD33 descartavel em
`src/vba/`, mas a confirmacao final depende do VBE detectar se ha qualquer
dessincronizacao residual entre `.frm` e `.frx`.

## Onda 37.1 EXECUTADA — Decisoes de drift e licoes MD33 (Codex)

| Campo | Valor |
|---|---|
| Track | fast_track (documental, sem tocar VBA) |
| Readback | [readbacks/0091-onda37-1-decisoes-drift.json](../readbacks/0091-onda37-1-decisoes-drift.json) |
| Hearback | confirmed — Mauricio informou aprovacao e criacao do readback com auditoria Opus |
| ERP | [results/0091-exec-onda37-1-decisoes-drift.json](../results/0091-exec-onda37-1-decisoes-drift.json) |
| Matriz | [classificacao_drift_funcional.md](../../auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/classificacao_drift_funcional.md) |
| Doc tecnico | [37_1_TECNICO.md](../../auditoria/03_ondas/onda_37_1_decisoes_drift/37_1_TECNICO.md) |
| Proposta | [PROPOSTA_ONDA_37_2_SAFE_TRACK.md](../../auditoria/03_ondas/onda_37_1_decisoes_drift/PROPOSTA_ONDA_37_2_SAFE_TRACK.md) |

### Resultado Onda 37.1

- `drift_md33_descartar=3`: `Importador_V3.bas`, `Menu_Principal.frm`, `Preencher.bas`.
- `drift_legitimo_anterior_v5=25`: sem commits pos-V205; cruzados contra linhas/ondas fechadas.
- `drift_misto=0`.
- `drift_inesperado_investigar=0`; nenhum arquivo exigiu decisao humana individual nessa classe.
- ADRs produzidos: remocao futura de `Importador_V2.bas` e pendencia documentada de `Emergencia_CNAE.bas` fora da V206.

🟠 SOURCE DRIFT DETECTED: a cadeia MD33 deixou `src/vba/` com drift que nao representa a unica ancora compilavel conhecida (V5). A correcao deve ser uma nova onda safe_track, nao import direto.


## Onda 37 EXECUTADA — Reconciliacao V5 vs src/vba (Codex)

| Campo | Valor |
|---|---|
| Track | safe_track (evidencia/auditoria, sem tocar VBA) |
| Readback | [readbacks/0090-onda37-reconciliacao-v5.json](../readbacks/0090-onda37-reconciliacao-v5.json) |
| Hearback | confirmed — Mauricio informou aprovacao de Opus (audit) e Mauricio (hearback) no chat de 2026-05-24 |
| ERP | [results/0090-exec-onda37-reconciliacao-v5.json](../results/0090-exec-onda37-reconciliacao-v5.json) |
| Evidencia | [manifest.sha256.csv](../../auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/manifest.sha256.csv) |
| Classificacao | [classificacao.md](../../auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/classificacao.md) |
| Doc tecnico | [37_TECNICO.md](../../auditoria/03_ondas/onda_37_reconciliacao_v5/37_TECNICO.md) |

### Resultado Onda 37

- `src/vba/`: 66 arquivos analisados.
- Export V5: 64 arquivos analisados.
- Classes: `igual=8`, `drift_export_benigno=28`, `diferenca_funcional=28`, `ausente_no_workbook=0`, `obsoleto_no_repo=1`, `precisa_decisao_humana=1`.
- `Altera_Entidade.frm/.frx` estao presentes no export atual da V5; isso corrige o metadata drift do handoff anterior.
- `Importador_V2.bas` classificado como `obsoleto_no_repo` com referencia documental de nao reintegracao.
- `Emergencia_CNAE.bas` classificado como `precisa_decisao_humana`.

🟡 HBN NEEDS HUMAN DECISION: decidir o destino de `Emergencia_CNAE.bas` antes de qualquer onda que mexa em pacote importavel ou remocao de arquivo.


## Onda 36 FECHADA — Cura do Protocolo (Claude Opus 4.7)

| Campo | Valor |
|---|---|
| Track | safe_track (governança, sem tocar VBA) |
| Readback | [readbacks/0089-onda36-cura-protocolo-opus.json](../readbacks/0089-onda36-cura-protocolo-opus.json) |
| Hearback | confirmed — confirmado antes da retomada da Onda 37 |
| ERP | [results/0089-exec-onda36-cura-protocolo-opus.json](../results/0089-exec-onda36-cura-protocolo-opus.json) |
| Auditoria-mãe | [auditoria/00_status/105_AUDITORIA_HANDOFF_V206_V207_USEHBN_CLAUDE_OPUS.md](../../auditoria/00_status/105_AUDITORIA_HANDOFF_V206_V207_USEHBN_CLAUDE_OPUS.md) |
| Devolutiva ao Codex | [auditoria/00_status/106_DEVOLUTIVA_OPUS_PROMPT_RETOMADA_CODEX_V206.md](../../auditoria/00_status/106_DEVOLUTIVA_OPUS_PROMPT_RETOMADA_CODEX_V206.md) |
| Roadmap protocolo | [auditoria/02_planos/34_ROADMAP_PROTOCOLO_90_DIAS_OPUS.md](../../auditoria/02_planos/34_ROADMAP_PROTOCOLO_90_DIAS_OPUS.md) |
| Plano arquivamento | [auditoria/02_planos/35_PLANO_ARQUIVAMENTO_LOCAL_AI_E_V12_PASTAS.md](../../auditoria/02_planos/35_PLANO_ARQUIVAMENTO_LOCAL_AI_E_V12_PASTAS.md) |
| Knowledge nova | [knowledge/0013-contratos-executaveis.md](../knowledge/0013-contratos-executaveis.md) |

### Entregáveis Onda 36 (todos prontos)

- `.hbn/canonical-root` — path canônico declarativo
- `.hbn/forbidden-paths.txt` — paths legacy bloqueados em commits novos
- `.hbn/schemas/` — readback + hearback + audit-pre + audit-post + README
- `scripts/hbn-guards/` — 5 guards + lib + runner + install + README
- `AGENTS.md` — seção "Contratos executáveis" + lista de leitura atualizada
- `.hbn/knowledge/0013-contratos-executaveis.md` — regra permanente
- 4 documentos canônicos (105, 106, 34, 35)

### Próxima ação após hearback Onda 36

Bastão passa para **Codex**, em sessão nova, para executar **Onda 37 — Reconciliação V5 vs src/vba** sob o novo contrato. Prompt em [auditoria/00_status/106_DEVOLUTIVA_OPUS_PROMPT_RETOMADA_CODEX_V206.md](../../auditoria/00_status/106_DEVOLUTIVA_OPUS_PROMPT_RETOMADA_CODEX_V206.md). Codex precisa produzir `.hbn/readbacks/0090-onda37-reconciliacao-v5.json` e aguardar hearback antes de qualquer execução.



## P0 corrigido — raiz canonica do projeto

Em 2026-05-24 foi identificado que a branch
`codex/v12-0-0206-planejamento` estava sendo executada no worktree
`/private/tmp/cred-v205`, enquanto o workbook e o Importador V3 apontavam para
`\\Mac\Home\Projetos\Credenciamento`. Isso quebrava a fonte unica de verdade:
os deltas V206 existiam no tmp, mas o operador e o backup obrigatorio do
workbook liam a pasta do projeto.

Correcao aplicada:

- `/private/tmp/cred-v205` foi removido como worktree ativo.
- A branch `codex/v12-0-0206-planejamento` agora esta em
  `/Users/macbookpro/Projetos/Credenciamento`.
- Os deltas V206 feitos no tmp foram resgatados e reaplicados na pasta
  canonica.
- Evidencias de resgate e colisao ficaram em
  `backups/raiz_canonica/20260524_134722/`.
- A regra permanente foi registrada em
  [`.hbn/knowledge/0012-raiz-canonica-projeto.md`](../knowledge/0012-raiz-canonica-projeto.md)
  e em [`AGENTS.md`](../../AGENTS.md).

Preflight obrigatorio para qualquer IA:

```bash
pwd
git rev-parse --show-toplevel
git status --short --branch
git worktree list
```

Se `pwd` ou `git rev-parse --show-toplevel` forem diferentes de
`/Users/macbookpro/Projetos/Credenciamento`, a IA deve parar e registrar P0.

## Anchor V5 — reinicio operacional V206

Em 2026-05-24, o operador descartou a rota de `V12-0206-Preparacao` porque a
planilha tambem nao compilava. A nova ancora operacional local e:

```text
/Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-Homologacao-V5.xlsm
```

Origem declarada:

```text
/Users/macbookpro/Projetos/Credenciamento/V12-205-OficialCongelada
```

Confirmacoes humanas:

- `?ThisWorkbook.Path` retornou `\\Mac\Home\Projetos\Credenciamento`;
- `ImportarPacoteV3_Status` encontrou o manifesto em `local-ai\vba_import`;
- `GetReleaseTag` retornou `v12.0.0205`;
- `GetReleaseAtual` retornou `V12.0.0205`;
- `GetReleaseAlvo` retornou `V12.0.0206`;
- `GetBuildImportado` retornou
  `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix`;
- Gate RVS `VR_20260524_164612` APROVADO com assinatura
  `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.

Status canonico:

- a V5 e workbook local ignorado pelo Git;
- `src/vba/` segue como fonte versionada da verdade;
- `local-ai/vba_import/` segue como unica fonte operacional de import;
- antes de qualquer novo microdelta, exportar V5 para
  `local-ai/incoming/V206_ANCHOR_V5_20260524/` e comparar contra `src/vba/`;
- nao usar os manifestos MD33/fix1/fix2 reprovados na V5.

Referencia: [`../../auditoria/00_status/101_ANCHOR_V5_REINICIO_V206_CODEX.md`](../../auditoria/00_status/101_ANCHOR_V5_REINICIO_V206_CODEX.md).

## Bastao Claude Opus 4.7 — auditoria antes de executar

Em 2026-05-24, apos o export bruto da V5, o operador solicitou passagem de
bastao para Claude Opus 4.7 revisar o handoff, ajustar o protocolo de entrada
useHBN e propor barreiras reais entre IAs antes de qualquer nova implementacao.

Documentos de entrada:

- [`../../auditoria/00_status/102_HANDOFF_CLAUDE_OPUS_47_V206_V207_USEHBN_CODEX.md`](../../auditoria/00_status/102_HANDOFF_CLAUDE_OPUS_47_V206_V207_USEHBN_CODEX.md)
- [`../../auditoria/00_status/103_PROMPT_AUDITORIA_CLAUDE_OPUS_47_HANDOFF_V206_V207_USEHBN.md`](../../auditoria/00_status/103_PROMPT_AUDITORIA_CLAUDE_OPUS_47_HANDOFF_V206_V207_USEHBN.md)
- [`../../auditoria/00_status/104_PROMPT_RETOMADA_CODEX_V206_NOVO_CONTEXTO.md`](../../auditoria/00_status/104_PROMPT_RETOMADA_CODEX_V206_NOVO_CONTEXTO.md)
- [`../../auditoria/02_planos/33_ROADMAP_V207_CODE_REVIEW_REFORMULACAO.md`](../../auditoria/02_planos/33_ROADMAP_V207_CODE_REVIEW_REFORMULACAO.md)

Codex nao deve retomar implementacao funcional ate que exista:

```text
auditoria/00_status/105_AUDITORIA_HANDOFF_V206_V207_USEHBN_CLAUDE_OPUS.md
```

e o operador aprove a devolutiva.

## V12.0.0205 — ciclo ativo de estabilização

| Campo | Valor |
|---|---|
| Branch | `main` após tag `v12.0.0205` |
| Base canônica | `e43352f` |
| Versão oficial anterior | `V12.0.0204` |
| Status V205 | VALIDADO/OFICIAL congelada para produção; compile VBE pós-MICRO61 e Gate RVS final aprovados |
| Guard funcional | `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` |
| Evidência final | `VR_20260523_215637` |
| Readback | [`../../auditoria/00_status/76_READBACK_ABERTURA_V205_CODEX.md`](../../auditoria/00_status/76_READBACK_ABERTURA_V205_CODEX.md) |
| Roadmap | [`../../auditoria/02_planos/30_ROADMAP_V205_PRODUCAO.md`](../../auditoria/02_planos/30_ROADMAP_V205_PRODUCAO.md) |
| ERPs | [`../results/0069-exec-onda26-v205-md26-1-governanca-tooling-abertura.json`](../results/0069-exec-onda26-v205-md26-1-governanca-tooling-abertura.json), [`../results/0070-exec-onda27-v205-md27-1-rvs-labels-csv-prefix.json`](../results/0070-exec-onda27-v205-md27-1-rvs-labels-csv-prefix.json), [`../results/0073-exec-onda28-v205-md28-2-rvs-aprovado.json`](../results/0073-exec-onda28-v205-md28-2-rvs-aprovado.json), [`../results/0075-exec-onda29-v205-md29-2-af3-freeze.json`](../results/0075-exec-onda29-v205-md29-2-af3-freeze.json), [`../results/0076-exec-onda29-v205-md29-3-freeze-publicacao.json`](../results/0076-exec-onda29-v205-md29-3-freeze-publicacao.json) |

### Limites do bastão V205

- Permitido: documentação, índices, CI/CD de consistência, labels de UI,
  prefixos/pastas de evidência e metadados de fechamento.
- Bloqueado: lógica de rodízio, persistência, cálculo, avaliação, OS,
  renomeação de símbolos VBA, PDF automático via VBA e refatoração estrutural.
- Fechamento oficial: Gate RVS final e compile VBE pós-MICRO61 aprovados. A
  V12.0.0205 está pronta para tag/publicação e a próxima linha é V12.0.0206.

## V12.0.0206 — ciclo de planejamento

| Campo | Valor |
|---|---|
| Branch | `codex/v12-0-0206-planejamento` |
| Base | `v12.0.0205` / commit `f24e535` |
| Status | Roadmap aprovado; Onda 31 documental executada; Onda 32 consolidou auditoria cruzada PDF/UI; Onda 33 pausada apos tres imports OK e compile crash; retomada reancorada na V5 derivada de V12-205-OficialCongelada com RVS aprovado |
| Roadmap preliminar | [`../../auditoria/02_planos/31_ROADMAP_V206_PRELIMINAR.md`](../../auditoria/02_planos/31_ROADMAP_V206_PRELIMINAR.md) |
| Roadmap consolidado | [`../../auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md`](../../auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md) |
| Readback | [`../../auditoria/00_status/83_READBACK_ABERTURA_V206_CODEX.md`](../../auditoria/00_status/83_READBACK_ABERTURA_V206_CODEX.md) |
| Prompts planejamento | [`../../auditoria/00_status/84_PROMPT_PLANEJAMENTO_V206_CLAUDE_OPUS.md`](../../auditoria/00_status/84_PROMPT_PLANEJAMENTO_V206_CLAUDE_OPUS.md), [`../../auditoria/00_status/85_PROMPT_PLANEJAMENTO_V206_GEMINI_ANTIGRAVITY.md`](../../auditoria/00_status/85_PROMPT_PLANEJAMENTO_V206_GEMINI_ANTIGRAVITY.md), [`../../auditoria/00_status/91_PROMPT_RETOMADA_CODEX_V206_NOVO_CHAT.md`](../../auditoria/00_status/91_PROMPT_RETOMADA_CODEX_V206_NOVO_CHAT.md) |
| PDF/UI | [`../../auditoria/00_status/92_PROMPT_AUDITORIA_PDF_UI_V206_CLAUDE_OPUS.md`](../../auditoria/00_status/92_PROMPT_AUDITORIA_PDF_UI_V206_CLAUDE_OPUS.md), [`../../auditoria/00_status/93_PROMPT_AUDITORIA_ADVERSARIAL_PDF_UI_V206_GEMINI.md`](../../auditoria/00_status/93_PROMPT_AUDITORIA_ADVERSARIAL_PDF_UI_V206_GEMINI.md), [`../../auditoria/00_status/94_PROMPT_CONSOLIDACAO_PDF_UI_V206_CODEX.md`](../../auditoria/00_status/94_PROMPT_CONSOLIDACAO_PDF_UI_V206_CODEX.md), [`../../auditoria/00_status/97_CONSOLIDACAO_PDF_UI_V206_CODEX.md`](../../auditoria/00_status/97_CONSOLIDACAO_PDF_UI_V206_CODEX.md) |
| Anchor V5 | [`../../auditoria/00_status/101_ANCHOR_V5_REINICIO_V206_CODEX.md`](../../auditoria/00_status/101_ANCHOR_V5_REINICIO_V206_CODEX.md) |

### Limites preliminares V206

- Permitido: PDF automático robusto, ajustes manuais, evidências, Importador V3,
  documentação e pequenos débitos técnicos.
- Bloqueado: code review profundo, performance estrutural, componentização,
  preparação SaaS e renomeações internas amplas; esses itens ficam para
  V12.0.0207 salvo nova decisão humana.

> ⚠️ **REGRA INVIOLAVEL (M11 destilada 2026-05-03)**: A IA le `src/vba/`
> (fonte de verdade — AGENTS.md §62-63) e transporta para
> `local-ai/vba_import/` (espelho com prefixos). NUNCA o inverso.
> Cada microdelta valida `shasum src/vba/X == shasum local-ai/vba_import/<prefixo>-X`
> antes de declarar gate. Esta regra ja causou regressao em
> 2026-05-02 (lição M11) e em 2026-05-02 ondas anteriores
> (auditoria 32). Ver `auditoria/00_status/43c_LICAO_FONTE_DE_VERDADE_VS_ESPELHO.md`.

## Onda 11 FECHADA — V12.0.0203-rc1 (2026-05-02 06:50 BRT)

> ✅ **PUBLICADA NO GITHUB** — tag `v12.0.0203-rc1` em
> `https://github.com/rwv8gscs8g-blip/credenciamento`. Validacao
> Quarteto pos-import: `VR_20260502_063028 = APROVADO`
> com sintaxe `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0`.

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0011-onda11-v203-rc1-closure.json](../readbacks/0011-onda11-v203-rc1-closure.json) |
| Hearback | confirmed (Q1-Q7' aprovados em chat 2026-05-02; "Pode comecar a implementacao" + "Confirmo e aprovo de Q5 a Q7. Pode implementar") |
| ERP | [results/0011-exec-onda11.json](../results/0011-exec-onda11.json) |
| Fechamento | [auditoria/03_ondas/onda_11_v203_rc1_closure/70_FECHAMENTO_ONDA_11.md](../../auditoria/03_ondas/onda_11_v203_rc1_closure/70_FECHAMENTO_ONDA_11.md) |
| Drift G7 residual (D1) | [auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md](../../auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md) — 23 arquivos divergentes para Ondas 12-16 caso-a-caso |
| Origem | Cadeia Antigravity → Codex (2026-05-02) revelou drift G7 entre src/vba e local-ai/vba_import nos 6 modulos do dominio strikes |
| Renumeracao | Onda 11 corretiva (esta) substitui Onda 11 original (CNAE), que vira Onda 12+ |
| Deadline hard | Domingo 2026-05-03 23:59 BRT |
| **Deadline atendido** | **sim — fechada em 2026-05-02** |
| **Status microdeltas** | **8/8 ENTREGUES** — ver tabela abaixo |
| **Build label final** | `f7aa84f+v12.0.0203-rc1` |
| **APP_RELEASE_TAG** | `v12.0.0203-rc1` |
| **APP_RELEASE_STATUS** | `RELEASE_CANDIDATE` |
| **APP_RELEASE_TEST_KEY** | `quarteto-2026-05-02` (Quarteto = gate oficial conforme Q7 operador) |
| **Gate oficial** | `CT_ValidarRelease_QuartetoMinimo` (V1+V2_Smoke+V2_Canonica+E2E_Strikes) |
| **Validacao final** | `VR_20260502_054314` = APROVADO; sintaxe `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0` |
| Ancora estavel atual | **V12-202-Z** (backup operador apos MD-2.3 verde) — build `f7aa84f+ONDA11.MD2-3-DT3-cleanup-config-incremental` |
| Validacao intermediaria | VR_20260502_034422 = APROVADO (V1=171/0 + V2 Smoke=14/0 + V2 Canonica=20/0); TV2_20260502_040156 = E2E STRIKES 64/0 |
| **Pendente operador** | ✅ CONCLUÍDO 2026-05-02 06:50 — Quarteto APROVADO `VR_20260502_063028`, tag `v12.0.0203-rc1` publicada em `https://github.com/rwv8gscs8g-blip/credenciamento` |
| **Onda 11 fisicamente fechada** | 2026-05-02 06:50 BRT |
| Protocolo HBN | V2 vigente — ver [knowledge/0005-protocolo-markers-v2.md](../knowledge/0005-protocolo-markers-v2.md) |
| Cadeia Antigravity → Codex (esta sessao) | local-ai/Time_AI/2026-05-02-V203-fechamento/ (gitignored) |
| Phagocytosis decisao | Proposta A + campos de capsule da D — chat-novo-usehbn implementa em paralelo a partir de 2026-05-02 |
| DT-6 NOVO | Validacao UI Configuracao_Inicial parametrizada — V12.0.0204; spec em auditoria/00_status/36_SPEC_DT6_Validacao_UI_Configuracao_V12_0204.md |
| Automacao semanal | Wave 11+ (segunda 2026-05-04): Typer + uv + GitHub Actions + signed commits PR-only |
| Fora de escopo | DT-2, DT-4 (Ondas 13+); DT-5 PDFs (V12.0.0204); DT-6 (V12.0.0204); reincorporacao Ondas 2-8 originais (Ondas 12+) |

### Microdeltas Onda 11 — entregues (8/8 + tag pendente)

| ID | Tema | Build label | Validacao | Status |
|---|---|---|---|---|
| **MD-0** | Drift G7 sync — 6 arquivos canonicos copiados de volta para src/vba | (sem bump — sincronizacao) | shasum 6/6 match | ✅ APROVADO |
| **MD-1** | Instrumentacao E2E DT-3 — 5 markers DIAG_* por rodada em TV2_E2E_AtenderProximaEmpresa | `ONDA11.MD1-DT3-diagnostic-incremental` | TV2_RunSmoke 14/0 + E2E rodou capturando evidencia | ✅ APROVADO |
| **MD-2** | Fix A (Select Case tolerante a padding "1"↔"001") + Fix B (CONFIG MAX_STRIKES=3, DIAS=90 no contexto E2E) | `ONDA11.MD2-DT3-fix-test-helper-incremental` | E2E 12 falhas → 1 falha (regressao reduzida) | ✅ APROVADO |
| **MD-2.2** | Asserts da verdade matematica — Etapa E sem loop, valores reais (1, 3, 3) com comentario-vacina | `ONDA11.MD2-2-DT3-asserts-fatos-incremental` | E2E 64/0 (primeira vez); trio falhou por vazamento CONFIG → MD-2.3 | ✅ APROVADO |
| **MD-2.3** | Anti-vazamento de CONFIG — helper TV2_E2E_RestaurarConfigBaseline em sucesso + falha | `ONDA11.MD2-3-DT3-cleanup-config-incremental` | VR_20260502_034422 trio APROVADO (171/0+14/0+20/0) + E2E 64/0 | ✅ APROVADO |
| **MD-3** | DT-1 release gate honesty — `CT_ValidarRelease_QuartetoMinimo` (V1+V2_Smoke+V2_Canonica+E2E_Strikes) | `ONDA11.MD3-DT1-quarteto-release-gate-incremental` | **VR_20260502_054314 = APROVADO; sintaxe `V1=171/0+V2_Smoke=14/0+V2_Canonica=20/0+E2E_Strikes=64/0`** | ✅ APROVADO |
| **MD-3.1** | Visibilidade Quarteto no menu Central V2 (opcao [20]) | `ONDA11.MD3-1-DT1-quarteto-menu-incremental` | manifesto MICRO11 entregue; pendente import operador | ✅ ENTREGUE |
| **MD-4** | CSVs antigos da raiz movidos para `auditoria/04_evidencias/V12.0.0203/` | (sem bump — file-only) | 3 CSVs movidos | ✅ APROVADO |
| **MD-5** | rc1 bump (TAG/STATUS/EVIDENCE_DIR/TEST_KEY) + CHANGELOG + L16-L18+M7 em PHAGOCYTOSIS + ERP + 70_FECHAMENTO + DRIFT_G7_RESIDUAL | `f7aa84f+v12.0.0203-rc1` | manifesto MICRO12 entregue; pendente import operador | ✅ ENTREGUE |

### Pendente operador para fechamento físico

| Acao | Esforço | Files |
|---|---|---|
| Importar MICRO11 (MD-3.1 menu) + MICRO12 (rc1 bump) no workbook | ~5min | manifestos `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO{11,12}.txt` |
| Compile manual + Quarteto verde | ~12min | `CT_ValidarRelease_QuartetoMinimo` |
| Salvar como `V12-202-AB-onda11-rc1` | ~1min | workbook ancora rc1 |
| `git tag v12.0.0203-rc1` + `git push origin v12.0.0203-rc1` | ~1min | git |
| **MD-5** | V12.0.0203-rc1: bump APP_RELEASE_TAG/STATUS/EVIDENCE_DIR + CHANGELOG + L16-L18+M7 em PHAGOCYTOSIS + ERP `0011-exec-onda11.json` + `auditoria/03_ondas/onda_11_v203_rc1_closure/70_FECHAMENTO_ONDA_11.md` | ~60min | AAX-App_Release.bas + 5+ docs |
| Tag git | `git tag v12.0.0203-rc1` + push (operador) | ~5min | git |

### Licoes destiladas nesta sessao (a registrar em PHAGOCYTOSIS no MD-5)

- **L16** — Anti-vazamento de CONFIG entre suites (toda mudanca de estado em CONFIG por suite deve ser revertida em try/finally simulado)
- **L17** — Instrumentacao cirurgica antes de fixar (DIAG_* logs por etapa revelam causa raiz sem ciclos de hotfix encadeados)
- **L18** — Determinismo > narrativa pedagogica (testes devem refletir fatos do sistema, nao premissas idealizadas)
- **M7** — Auditor de espelho deve hashar src vs canonical antes de RCA (erro do Antigravity virou marker `🟠 SOURCE DRIFT DETECTED`)

## Transicao 2026-05-02 — Sessao original encerra; 2 chats paralelos abrem

| Frente | Bastao | Foco | Prompt de abertura |
|---|---|---|---|
| **1 — Credenciamento** | Claude Opus 4.7 (continuacao) | Fechar V12.0.0203-rc1 (MD-3+MD-4+MD-5+tag) + Ondas 12-19 + FECH conforme roadmap original | `local-ai/Time_AI/2026-05-02-V203-fechamento/200-PROMPT-CHAT-NOVO-CREDENCIAMENTO.md` |
| **2 — usehbn / Fagocitose** | Claude Opus 4.7 = arquiteto senior + validador; Codex = executor em esteiras incrementais; Mauricio = palavra final em decisoes complexas | Bootstrap HBN Phagocytosis Protocol v0.1 (modulo VBA primeiro alvo) + protocolo vivo | `local-ai/Time_AI/2026-05-02-V203-fechamento/201-PROMPT-CHAT-NOVO-USEHBN.md` |

Sincronizacao entre frentes: via arquivos no repo (`.hbn/`, `auditoria/`, `usehbn/`). Sem bloqueio mutuo.

# Relay HBN — Credenciamento

## Bastao atual

| Campo | Valor |
|---|---|
| Proprietario | Claude Opus 4.7 (Cowork) |
| Concedido por | Luis Mauricio Junqueira Zanin |
| Data de concessao | 2026-04-28 |
| Validade | ate fechamento estavel da V12.0.0203 no GitHub |
| Reverte para | Codex (apoio) + Claude Opus em modo auditoria |
| Modo de operacao atual | **CONSULTIVO CONTROLADO** (alterado 2026-04-28 apos violacao G6 — saiu do modo "execucao maxima") |
| Justificativa | retrabalho da Onda 5 nao estabilizada; concentracao em uma IA reduz risco de perda de contexto durante a estabilizacao |

## Onda 10 EM EXECUCAO — Reincorporacao Onda 1 (strikes)

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0010-onda10-reincorporacao-onda01.json](../readbacks/0010-onda10-reincorporacao-onda01.json) |
| Hearback | confirmed (5 pontos aprovados em chat 2026-05-01) |
| Microdelta atual | **N/A — Onda 10 FECHADA na canonica em 2026-05-02 com debito DT-3 documentado** |
| ERP | [results/0010-exec-onda10.json](../results/0010-exec-onda10.json) |
| Validacao final | `VR_20260501_233424` (V1=171/0, V2 Smoke=14/0, V2 Canonica=20/0) APROVADO |
| Build label final | `f7aa84f+ONDA10-canonica-fechada-com-debito-strikes` |
| Pasta canonica | `local-ai/vba_import/` (RESTAURADA — Regra de Ouro 0002 reafirmada) |
| Solucao de contorno | `local-ai/vba_import_v3_phase1/` arquivada em `auditoria/04_evidencias/V12.0.0203/_historico_v3_phase1_descontinuado_20260502/` |
| Politica de teste | **TV2_RunSmoke por microdelta + trio mínimo 1x ao final da onda** (oficializado 2026-05-01 18:44) |
| Princípio arquitetural | Testes via interface oficial (TV2_Run*), idempotentes, evoluindo junto com codigo de producao. **Sem smoke ad-hoc no Imediato.** |
| Estrategia de espelho | **A — minimalista** (espelho = baseline + delta da onda; src/vba intocado em Phase A.5; hotfixes residuais para Phase A.6) |
| Microdeltas planejados | 1.0 → 1.1 → 1.2 → 1.4 → 1.3 → 1.5 (ordem com 1.4 antes de 1.3 para preservar config canonica) |
| Build label apos 1.0 | `f7aa84f+ONDA10.MICRO00-V3-Delta-Capability-incremental` |
| Build label final apos 1.5 | `f7aa84f+ONDA10-aprovada` |
| Ancora pos-onda10 | V12-202-T-onda10 |
| Doc tecnico | [auditoria/03_ondas/onda_10_reincorporacao_onda01/](../../auditoria/03_ondas/onda_10_reincorporacao_onda01/) |
| Achado Phase A | Ondas 1-4 estao **PARCIALMENTE** no baseline (so infra/producao parcial; suites/diag/menus ausentes). Onda 5 CONFIRMADA. |
| Estrategia | Reincorporacao progressiva via microdeltas, cada um com gate compile + trio + bump build incremental. |

### Microdeltas concluidos da Onda 10

| ID | Tema | Validacao | Build label | Status |
|---|---|---|---|---|
| 1.0 | Extensao V3 capacidade delta + bump auto | VR_20260501_173310 (171/0+14/0+20/0) | `f7aa84f+ONDA10.MICRO00-V3-Delta-Capability-incremental` | ✅ APROVADO 2026-05-01 17:44 |
| 1.1 | Repo_Avaliacao.ContarStrikesPorEmpresa | VR_20260501_180949 (171/0+14/0+20/0) | `f7aa84f+ONDA10.MICRO01-Repo_Avaliacao-incremental` | ✅ APROVADO 2026-05-01 18:19 |
| 1.2 | Svc_Rodizio.Suspender params opcionais | TV2_20260501_184237 SMOKE 14/0 | `f7aa84f+ONDA10.MICRO02-Svc_Rodizio-incremental` | ✅ APROVADO 2026-05-01 18:44 |
| 1.4 | TV2_SetConfigCanonica grava MAX_STRIKES e DIAS_SUSPENSAO_STRIKE | TV2_20260501_185512 SMOKE 14/0 | `f7aa84f+ONDA10.MICRO04-Teste_V2_Engine-incremental` | ✅ APROVADO 2026-05-01 18:55 |
| 1.3 | Svc_Avaliacao bloco 7b strikes ATIVO em producao (regra integrada) | TV2_20260501_194706 SMOKE 14/0 | `f7aa84f+ONDA10.MICRO03-Svc_Avaliacao-fix1-incremental` | ✅ APROVADO 2026-05-01 19:47 |


## Modo de operacao

**Consultivo controlado** (vigente desde hotfix v2 da Onda 6):

- Leitura ampla permitida (Read, Glob, Grep em todo o repo).
- Escrita pequena: cada arquivo modificado e escrita atomica, com
  hearback explicito para mudancas em arquivos canonicos
  (`.hbn/knowledge/`, `auditoria/01_regras_e_governanca/`,
  `usehbn/agents/`, `CLAUDE.md`).
- **Verificacao G6 obrigatoria** antes de enviar resposta ao Mauricio:
  scan da resposta por padroes VBA (`Private Sub`, `Public Sub`,
  `Public Function`, `Dim ... As`, `Range(...)`, `Sheets(...)`,
  `Cells(...)`, `Application.X`). Se houver match, pausar, mover para
  arquivo, atualizar procedimento, reenviar.
- Comandos shell para o operador continuam permitidos (sao operacionais,
  nao deliverable).
- Modo "execucao maxima" anterior (Onda 6 fase 1-2) provou produzir
  violacao — descontinuado.

## Ciclo encerrado mais recente

**ONDA 9 V3 — Phase 1 APROVADA** (2026-05-01 12:25)

| Campo | Valor |
|---|---|
| Track | safe_track |
| Readback | [readbacks/0009-onda09-v3-phase1.json](../readbacks/0009-onda09-v3-phase1.json) |
| Hearback | confirmed (3 OKs explicitos + 7 ciclos iterativos validados) |
| ERP | [results/0009-exec-onda09-v3-phase1.json](../results/0009-exec-onda09-v3-phase1.json) |
| Trio minimo | VR_20260501_121550 — V1=171/0 + V2 Smoke=14/0 + V2 Canonica=20/0 — APROVADO |
| Compile manual | passou limpo apos remocao do Importador_V2 legado |
| Engine | `src/vba/Importador_V3.bas` (1095 linhas) |
| Pacote isolado | `local-ai/vba_import_v3_phase1/` (LEIA-ME + manifesto + 35M + 13F) |
| Bootstrap | `local-ai/vba_import_v3_phase1/Importador_V3_Bootstrap.bas` |
| Doc tecnico | [auditoria/03_ondas/onda_09_importador_v3/50_TECNICO.md](../../auditoria/03_ondas/onda_09_importador_v3/50_TECNICO.md) |
| Procedimento | [auditoria/03_ondas/onda_09_importador_v3/51_PROCEDIMENTO.md](../../auditoria/03_ondas/onda_09_importador_v3/51_PROCEDIMENTO.md) |
| Licoes aprendidas | [knowledge/0009-licoes-importador-v3-phase1.md](../knowledge/0009-licoes-importador-v3-phase1.md) (L1-L9 + M1-M5) |
| Ancora | `V12-202-S/` — primeira versao com V3 como importador oficial + compile limpo + trio verde |
| Fixes acumulados | 7 (todos baseados em evidencia empirica do log, nenhum chute) |

## Proximas fases

| Fase | Tema | Status |
|---|---|---|
| 1 | V3 alpha — importar baseline | ✅ APROVADA (2026-05-01) |
| 2 | V3 beta — modo Fresh em .xlsx em branco | OPCIONAL — robustece V3 mas nao bloqueia V203 |
| 3 | V3 gamma — renomeacao L2 | DESCARTADA por decisao operador (L1 escolhido) |
| 4 | Auditoria de debitos tecnicos + re-aplicar Ondas 7/8 se delta | EM PLANEJAMENTO |
| F | FECHAMENTO — atualizar build label + tag v12.0.0203 + push GitHub | DEPOIS DE 4 |

## Onda 5 — HOMOLOGADA

| Campo | Valor |
|---|---|
| Status | HOMOLOGADA em 2026-04-28 |
| Validacao | `VR_20260428_231958` em `auditoria/04_evidencias/V12.0.0203/` |
| Build | `f7aa84f+ONDA05-em-homologacao` |
| Trio minimo | V1=171/0, V2 Smoke=14/0, V2 Canonica=20/0 — **APROVADO** |
| Backup ancora | `V12-202-Q/` no diretorio raiz do projeto |

## Ciclo encerrado mais recente

| Campo | Valor |
|---|---|
| Ciclo | ONDA 6 — consolidacao documental + cleanup |
| Track HBN | safe_track |
| Status | ENCERRADO em 2026-04-28 |
| Readback | [readbacks/0001-onda06.json](../readbacks/0001-onda06.json) |
| Hearback | confirmed |
| ERP | [results/0001-exec-onda06.json](../results/0001-exec-onda06.json) |
| Resumo humano | [reports/0001-onda06-summary.md](../reports/0001-onda06-summary.md) |
| Doc tecnico | [auditoria/03_ondas/onda_06_consolidacao_documental/41_TECNICO.md](../../auditoria/03_ondas/onda_06_consolidacao_documental/41_TECNICO.md) |
| Commits | `85d7459` (conteudo) + `7e64622` (estrutural) |
| Ciclo origem | [relay/0001-onda06-consolidacao-documental.md](0001-onda06-consolidacao-documental.md) (sera arquivado em proxima abertura de ciclo) |

## Ondas previstas (a partir desta)

| Onda | Tema | Status |
|---|---|---|
| 6 | consolidacao documental + cleanup + integracao Diataxis/llms.txt/AGENTS.md/HBN | EM EXECUCAO |
| 5 (resgate) | homologacao final do form deterministico + Limpa_Base robusta (ja entregue, em homologacao manual) | EM HOMOLOGACAO |
| 7 | familia IDM_* + RDZ_* (idempotencia + rodizio em loop) | PROXIMA APOS ONDA 6 |
| 8 | heuristica zero em todos os 13 forms | DEPOIS DA 7 |
| 9 | reescrita do Importador_VBA + auditoria de Mod_Types (com aprovacao explicita) | DEPOIS DA 8 |
| FECHAMENTO | tag v12.0.0203, push GitHub, release publica | DEPOIS DA 9 |

## Proxima acao explicita

**Aprovacao do roadmap V203 final** (ver tabela "Proximas fases" acima).

Recomendacao Claude:
1. **Auditoria de debitos tecnicos** (~30 min Claude) — diff src/vba vs V12-202-S, lista de divergencias se houver
2. **Atualizar carimbo de build** em `App_Release.bas` para `f7aa84f+ONDA09-V3-PHASE1-aprovada` (1 commit)
3. **Phase 2 (opcional)** — robustecer V3 com run em `.xlsx` Fresh
4. **Phase 4 sequencial** — re-rodar trio + V2 Canonica completo + auditar Ondas 7/8 se delta
5. **FECHAMENTO** — tag v12.0.0203 + push GitHub

Aguardando hearback do Mauricio sobre ordem.

## Standard HBN markers

Esta sessao usa os marcadores visiveis do adapter HBN:

- `✅ HBN ACTIVE` — protocolo engajado
- `❌ HBN SECURITY BLOCKED SUGGESTION` — gate de seguranca
- `🟡 HBN NEEDS HUMAN DECISION` — aprovacao requerida

---

# Frente 2 — usehbn / Sprint 0 (aberta 2026-05-02)

> Seção append-only adicionada pela Frente 2 conforme protocolo
> `usehbn/methodology/INTER-CHAT-COORDINATION.md`. Não substitui nem
> edita conteúdo da Frente 1 acima.

## Bastão Frente 2

| Campo | Valor |
|---|---|
| Proprietário arquiteto | Claude Opus 4.7 (Cowork — sessão Frente 2 aberta 2026-05-02) |
| Proprietário executor | Codex CLI (delegação por esteiras) |
| Autoridade final | Luís Maurício Junqueira Zanin |
| Modo de operação | ⚪ HBN AUDIT-ONLY para Opus (orquestra, valida; não codifica). Codex em modo executor para esteiras aprovadas. |
| Foco | Bootstrap `hbn-phago` (HBN Phagocytosis Protocol v0.1) — esteira E1 = Radar Bootstrap |
| Repo destino | `~/Projetos/usehbn-phago/` (alternativa b — local separado, AGPLv3 limpo, futura promoção a repo público) |

## Histórico de esteiras Frente 2

### Esteira E1 — Radar Bootstrap (FECHADA — aprovada com débito)

| Campo | Valor |
|---|---|
| ID | E1 — Radar Bootstrap |
| Status | ✅ APROVADA com débito DT-FRENTE2-01 (templates genéricos nas 53 fichas — endereçado em E1.1) |
| Spec | `local-ai/Time_AI/2026-05-02-V203-fechamento/300-SPRINT-0-HBN-PHAGO-CODEX.md` |
| ERP | [`local-ai/Time_AI/codex-erps/2026-05-02_E1-radar-bootstrap.json`](../../local-ai/Time_AI/codex-erps/2026-05-02_E1-radar-bootstrap.json) |
| Resultado | 55 fichas + REGISTRY + MATRIX + repo `~/Projetos/usehbn-phago/` (LICENSE AGPLv3) |
| Validação Opus | V1-V12 verdes (estrutura); A1 amarelo (justificativas template — endereçado em E1.1) |
| Hearback Maurício | "sim para todas as quatro" — 2026-05-02 |

### Esteira E1.1 — Radar Content Deepening (FECHADA — aprovada com débito DT-FRENTE2-02)

| Campo | Valor |
|---|---|
| ID | E1.1 — Radar Content Deepening |
| Status | ✅ APROVADA com débito DT-FRENTE2-02 (justificativas template por categoria — não-bloqueante) |
| Spec | `local-ai/Time_AI/2026-05-02-V203-fechamento/302-ESTEIRA-E1-1-RADAR-CONTENT-DEEPENING.md` |
| ERP | [`2026-05-02_E1-1-radar-deepening.json`](../../local-ai/Time_AI/codex-erps/2026-05-02_E1-1-radar-deepening.json) |
| Resultado | 43 fichas reescritas (templates por categoria) + 10 arquivadas + REGISTRY/MATRIX regenerados + relatório `auditoria/00_status/40` |
| Validação Opus | V1-V3, V7-V15 verdes; V4/V5/V6 amarelos (templates persistentes — não-bloqueante) |
| Hearback Maurício | aprovado 2026-05-02 + decisão estratégica: análise profunda migra para Opus sob demanda |
| Mensagem fechamento | [`.hbn/messages/2026-05-02_06_de-opus_para-codex.md`](../messages/2026-05-02_06_de-opus_para-codex.md) |

### Análise profunda Opus (5 fichas — sob demanda, FECHADA)

| Campo | Valor |
|---|---|
| ID | A5 — Análise Profunda 5 Fichas (Opus) |
| Status | ✅ ENTREGUE |
| Fichas | tree-sitter, typer, uv, opentelemetry, consent-capsules |
| Resultado | 5 reescritas in-place com análise individual real, referências reais, recomendações de promoção |
| Recomendações | tree-sitter → `convergence-mapped` (9/10); opentelemetry → `convergence-mapped` (8/10); consent-capsules → `candidate` (10/10) |
| Confirmações | typer + uv → `candidate` em 2026-05-04 conforme programado (10/10 e 8/10 respectivamente) |

### Permeabilidade do radar formalizada (FECHADA)

| Campo | Valor |
|---|---|
| Doc | [`usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`](../../usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md) — seção "Permeabilidade" |
| Cobertura | 5 vias de entrada, regras de baixo atrito, anti-ruído, reentrada de archived, filtro de impacto |
| Origem | pedido Maurício 2026-05-02 (lógica de permeabilidade para novas tecnologias) |

### Sessão 2026-05-06 — análise das 5 tecnologias + reorientação arquitetural radical

| Campo | Valor |
|---|---|
| ID | A5-EVOLUÇÃO — análise das 5 tecnologias do radar (4 de 5 concluídas) |
| Decisões fechadas | **TODAS AS 5**: Tree-sitter APROVADA; Typer ARQUIVADA; uv ARQUIVADA; Consent Capsules APROVADA (migração imediata); **OpenTelemetry APROVADA (fagocitose progressiva)** |
| **Correção fundamental** | **useHBN é MULTI-BRAÇO; fagocitose é apenas UM dos 6 módulos. Doc canônico: `USEHBN-MODULES-ARCHITECTURE.md`** |
| **Documento de aprovação consolidado** | **`auditoria/00_status/44_CORRECAO_USEHBN_E_CONSOLIDACAO.md` — 7 blocos de decisão pendentes para Maurício** |
| **Auditoria Cruzada IAs (Módulo 6)** | **declarada em `CROSS-IA-AUDIT-PROTOCOL.md`** |
| **Proposta site** | **`usehbn/site/PROPOSTA-MELHORIA-USEHBN-ORG.md`** |
| Decisão arquitetural maior | **Rust como linguagem-base do useHBN** (Árvore Estável); **Consent Capsules como primeira migração estruturada Python → Rust** |
| Princípios operacionais formalizados | Minimalismo de Cadeia (P11 candidato); Substrato Sólido (P12 candidato); AI-Language-Abstraction (P13 candidato) |
| Modelo arquitetural novo | **3 Árvores — Estável (Rust), Desenvolvimento (transição), Exploração (qualquer linguagem)** |
| Markers V2 novos propostos (7) | 🟦 MINIMALIST, 🟪 SUBSTRATO, 🟧 AI-ABSTRACTION, 🌱 EXPLORATION SEED, 🔧 DEV BRANCH, 🪨 STABLE TRUNK, 🟫 TREE TRANSITION |
| Documentos canônicos novos (8) | `MINIMALISM-PRINCIPLE.md`, `SUBSTRATO-SOLIDO-PRINCIPLE.md`, `AI-LANGUAGE-ABSTRACTION-PRINCIPLE.md`, `THREE-TREES-ARCHITECTURE.md`, `LANGUAGE-PLATFORM-COMPARISON.md`, `42_ROADMAP_CONSENT_CAPSULES_RUST.md`, `43_PLANO_DOCUMENTACAO_V2_USEHBN.md` + ficha `rust.md` |
| Status | ⏳ apenas análise OpenTelemetry pendente antes do prompt unificado ao Codex e início efetivo R-A |
| Sucessor | `auditoria/00_status/42_PROMPT_UNIFICADO_CODEX.md` (renomear para evitar conflito com 42 atual) ou novo número — a ser criado após decisão #5 |
| V2 useHBN | em planejamento; F1 esboço pronto em `43_PLANO_DOCUMENTACAO_V2_USEHBN.md`; F2 inicia após análise OTel |

## Sistema de revisão semanal (ativado nesta sessão)

| Componente | Path |
|---|---|
| Log append-only | [`usehbn/radar/WEEKLY-UPDATES.md`](../../usehbn/radar/WEEKLY-UPDATES.md) |
| Protocolo | [`usehbn/methodology/RADAR-WEEKLY-REVIEW-PROTOCOL.md`](../../usehbn/methodology/RADAR-WEEKLY-REVIEW-PROTOCOL.md) |
| Frequência | Toda quarta-feira 11:45 BRT |
| Próxima revisão | 2026-05-06 (quarta) |
| Modo | Manual (Opus + Maurício) até Wave 11+; depois `hbn weekly-review` automatizado |

## Decisões registradas no hearback 2026-05-02

| # | Decisão | Status |
|---|---|---|
| 1 | Arquivar 10 tecnologias | Codex executa em E1.1 |
| 2 | Promover MCP → `convergence-mapped` | ✅ Opus executou (ficha atualizada) |
| 3 | Acionar Codex para E1.1 | ✅ Mensagem 04 depositada |
| 4 | Stack CLI (Typer, uv, GH Actions, Signed commits) → `candidate` em 2026-05-04 | Agendado |

## Documentos canônicos da Frente 2 (criados nesta sessão)

| Path | Função |
|---|---|
| [`usehbn/methodology/INTER-CHAT-COORDINATION.md`](../../usehbn/methodology/INTER-CHAT-COORDINATION.md) | Protocolo de coexistência F1 ↔ F2 (particionamento de paths, mensageria, soft-locks) |
| [`usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md`](../../usehbn/methodology/RADAR-PHAGOCYTOSIS-PIPELINE.md) | Camada 0 — Radar formalizada (estados, transições, schema de ficha) |
| `local-ai/Time_AI/2026-05-02-V203-fechamento/300-SPRINT-0-HBN-PHAGO-CODEX.md` | Spec executável da esteira E1 (Codex) |
| `local-ai/Time_AI/2026-05-02-V203-fechamento/301-PROTOCOLO-PINGPONG-OPUS-CODEX.md` | Protocolo Opus ↔ Codex (handoff, ERP, validação, iteração) |
| [`.hbn/messages/2026-05-02_01_de-frente2_para-frente1.md`](../messages/2026-05-02_01_de-frente2_para-frente1.md) | Mensagem informativa de abertura para a Frente 1 |

## Particionamento de paths vigente

Detalhes em `usehbn/methodology/INTER-CHAT-COORDINATION.md`. Resumo:

- **Frente 2 escreve em**: `usehbn/methodology/`, `usehbn/radar/`, `usehbn/constitution/` (Sprint 1+), `local-ai/Time_AI/2026-05-02-V203-fechamento/3*.md`, `auditoria/00_status/` (numeração 38-42), `.hbn/messages/`, `.hbn/locks/`, `.hbn/knowledge/0010+.md`, repo externo `~/Projetos/usehbn-phago/`
- **Frente 2 NÃO toca**: tudo o que pertence à Frente 1 (`src/vba/`, `local-ai/vba_import/`, `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`, `auditoria/03_ondas/`, `App_Release.bas`, `CHANGELOG.md`, `.hbn/readbacks/0011-*`, `.hbn/results/0011-*`, `auditoria/00_status/` numeração 33-37)
- **Append-only compartilhado**: este `.hbn/relay/INDEX.md` (Frente 2 só adiciona seção própria no fim)

## Markers V2 ativos no abrir da Frente 2

- `✅ HBN ACTIVE` — Frente 2 engajada
- `⚪ HBN AUDIT-ONLY` — Opus orquestra; Codex tem bastão executor
- `🔵 HBN HANDOFF READY` — pacote pronto para release ao Codex (aguardando hearback final)
- `🟤 HBN LICENSE SPLIT REQUIRED` — artefatos cruzam TPGL (Credenciamento) e AGPLv3 (usehbn-phago)
