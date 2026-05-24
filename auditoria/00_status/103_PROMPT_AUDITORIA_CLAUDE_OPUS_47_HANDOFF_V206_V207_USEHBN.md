---
titulo: Prompt Claude Opus 4.7 — Auditoria do Handoff V206/V207/useHBN
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Prompt Claude Opus 4.7 — Auditoria do Handoff V206/V207/useHBN

Voce e Claude Opus 4.7 assumindo o bastao de auditoria do Sistema de
Credenciamento e Rodizio de Pequenos Reparos.

## Objetivo

Auditar o handoff Codex, melhorar o protocolo de entrada useHBN e propor
barreiras reais entre IAs antes de qualquer nova implementacao funcional da
V12.0.0206.

Voce nao deve implementar codigo VBA neste passo.

## Contexto Obrigatorio

- V12.0.0205 esta congelada e publicada em GitHub Release/tag `v12.0.0205`.
- Commit base estavel: `f24e535 release: freeze v12.0.0205`.
- Evidencia final V205: `VR_20260523_215637`.
- Assinatura V205:
  `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.
- Branch ativa: `codex/v12-0-0206-planejamento`.
- Ultimo commit Codex: `8317d0c docs: anchor v206 restart on V5 workbook`.
- Grafia canonica: `V12.0.0206`, nunca `V12.0.206`.
- Raiz canonica local:
  `/Users/macbookpro/Projetos/Credenciamento`.

## Regras Duras

- Nao alterar RN-01 a RN-17.
- Nao alterar contadores do RVS.
- Nao incluir teste de PDF nas seis baterias do RVS.
- Nao mover nem reorganizar `doc/`.
- Nao tocar `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas` ou
  `Svc_PreOS.bas` na V12.0.0206 salvo P0 explicito e hearback humano.
- Nao renomear simbolos internos VBA.
- Toda mudanca funcional exige teste correspondente.
- Fonte versionada da verdade: `src/vba/`.
- Fonte operacional de importacao: `local-ai/vba_import/`.
- `local-ai/incoming/` e export bruto para comparacao, nao import.
- `backups/vba/` e evidencia/diagnostico, nao import.

## Leitura Obrigatoria

Leia, nesta ordem:

1. `AGENTS.md`
2. `.hbn/relay/INDEX.md`
3. `.hbn/knowledge/0002-regra-ouro-vba-import.md`
4. `.hbn/knowledge/0012-raiz-canonica-projeto.md`
5. `auditoria/00_status/101_ANCHOR_V5_REINICIO_V206_CODEX.md`
6. `auditoria/00_status/102_HANDOFF_CLAUDE_OPUS_47_V206_V207_USEHBN_CODEX.md`
7. `auditoria/00_status/97_CONSOLIDACAO_PDF_UI_V206_CODEX.md`
8. `auditoria/03_ondas/onda_33_v206_fix_relatorios_pdf_precondicao/01_TECNICO_ONDA33_FIX_RELATORIOS.md`
9. `auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md`
10. `auditoria/02_planos/33_ROADMAP_V207_CODE_REVIEW_REFORMULACAO.md`
11. `auditoria/00_status/104_PROMPT_RETOMADA_CODEX_V206_NOVO_CONTEXTO.md`

## Estado da V5

Workbook anchor:

```text
/Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-Homologacao-V5.xlsm
```

Origem declarada:

```text
/Users/macbookpro/Projetos/Credenciamento/V12-205-OficialCongelada
```

Evidencias:

- `ThisWorkbook.Path = \\Mac\Home\Projetos\Credenciamento`
- manifesto V3 presente em `local-ai\vba_import`
- `GetReleaseTag = v12.0.0205`
- `GetReleaseAtual = V12.0.0205`
- `GetReleaseAlvo = V12.0.0206`
- `GetBuildImportado = e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix`
- RVS `VR_20260524_164612` APROVADO com assinatura V205 congelada.

Export bruto V5:

```text
local-ai/incoming/V206_ANCHOR_V5_20260524/
```

Preflight Codex encontrou:

- 62 arquivos no export V5;
- 66 arquivos em `src/vba`;
- ausentes no export V5:
  `Altera_Entidade.frm`, `Altera_Entidade.frx`, `Emergencia_CNAE.bas`,
  `Importador_V2.bas`;
- varios arquivos comuns com diff textual normalizado, exigindo classificacao
  antes de qualquer overwrite ou novo pacote.

## Tarefas de Auditoria

1. Verificar se o handoff esta consistente e suficiente.
2. Corrigir omissoes, ambiguidades e riscos.
3. Propor barreiras useHBN obrigatorias para:
   - raiz canonica;
   - fonte de verdade;
   - local de importacao;
   - export bruto;
   - backups;
   - passagem de bastao;
   - readback/ERP;
   - drift workbook/repo.
4. Propor acordo formal entre IAs:
   - Claude Opus: auditoria/protocolo;
   - Codex: implementacao incremental apos hearback;
   - Gemini/Antigravity: auditoria adversarial quando solicitado.
5. Revisar a separacao V206 versus V207.
6. Propor plano exato para reconciliar export V5 contra `src/vba`.
7. Ajustar ou substituir o prompt de retomada Codex, se necessario.

## Saida Esperada

Crie um documento novo:

```text
auditoria/00_status/105_AUDITORIA_HANDOFF_V206_V207_USEHBN_CLAUDE_OPUS.md
```

Com frontmatter:

```yaml
---
titulo: Auditoria Handoff V206/V207/useHBN — Claude Opus 4.7
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Claude Opus 4.7
---
```

Estrutura minima:

- Veredito.
- Achados P0/P1/P2.
- Ajustes obrigatorios no protocolo useHBN.
- Barreiras reais recomendadas.
- Separacao V206/V207.
- Plano de reconciliacao V5 vs `src/vba`.
- Prompt ajustado para Codex retomar.
- Gates humanos antes de implementacao.

## Importante

Este prompt esta aberto a sua revisao. Se voce concluir que alguma regra
proposta por Codex deve ser endurecida, simplificada ou substituida, proponha a
mudanca explicitamente e aguarde hearback humano antes de qualquer execucao
funcional.
