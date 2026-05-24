---
titulo: Prompt Retomada Codex V206 — Novo Contexto
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Prompt Retomada Codex V206 — Novo Contexto

Voce e Codex retomando a V12.0.0206 do Sistema de Credenciamento e Rodizio de
Pequenos Reparos em uma janela de contexto nova.

## Antes de Fazer Qualquer Coisa

Execute:

```bash
pwd
git rev-parse --show-toplevel
git status --short --branch
git log --oneline --decorate --max-count=8
git worktree list
```

Todos os caminhos devem apontar para:

```text
/Users/macbookpro/Projetos/Credenciamento
```

Se aparecer `/private/tmp` ou outra raiz, pare e registre P0.

## Contexto Base

- V12.0.0205 esta congelada e publicada em GitHub Release/tag `v12.0.0205`.
- Commit base estavel: `f24e535 release: freeze v12.0.0205`.
- Evidencia final V205: `VR_20260523_215637`.
- Assinatura V205:
  `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.
- Branch ativa: `codex/v12-0-0206-planejamento`.
- Ultimo commit conhecido antes deste prompt: `8317d0c docs: anchor v206 restart on V5 workbook`.
- Grafia canonica: `V12.0.0206`.

## Leitura Obrigatoria

Leia:

1. `AGENTS.md`
2. `.hbn/relay/INDEX.md`
3. `.hbn/knowledge/0002-regra-ouro-vba-import.md`
4. `.hbn/knowledge/0012-raiz-canonica-projeto.md`
5. `auditoria/00_status/101_ANCHOR_V5_REINICIO_V206_CODEX.md`
6. `auditoria/00_status/102_HANDOFF_CLAUDE_OPUS_47_V206_V207_USEHBN_CODEX.md`
7. `auditoria/00_status/105_AUDITORIA_HANDOFF_V206_V207_USEHBN_CLAUDE_OPUS.md`
   se existir.
8. `auditoria/00_status/97_CONSOLIDACAO_PDF_UI_V206_CODEX.md`
9. `auditoria/03_ondas/onda_33_v206_fix_relatorios_pdf_precondicao/01_TECNICO_ONDA33_FIX_RELATORIOS.md`
10. `auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md`

Se o documento 105 do Claude ainda nao existir, pare e solicite a devolutiva
da auditoria antes de implementar.

## Regras Duras

- Nao alterar RN-01 a RN-17.
- Nao alterar contadores RVS.
- Nao incluir teste de PDF nas seis baterias do RVS.
- Nao mover nem reorganizar `doc/`.
- Nao tocar `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas` ou
  `Svc_PreOS.bas` salvo P0 explicito e hearback humano.
- Nao renomear simbolos internos VBA.
- Toda mudanca funcional exige teste correspondente.
- Fonte versionada da verdade: `src/vba/`.
- Fonte operacional de importacao: `local-ai/vba_import/`.
- `local-ai/incoming/` e export bruto para comparacao, nao import.
- `backups/vba/` e evidencia/diagnostico, nao import.

## Anchor V5

Workbook operacional local:

```text
/Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-Homologacao-V5.xlsm
```

Origem declarada:

```text
/Users/macbookpro/Projetos/Credenciamento/V12-205-OficialCongelada
```

Confirmado pelo operador:

- `ThisWorkbook.Path = \\Mac\Home\Projetos\Credenciamento`
- manifesto V3 presente;
- `GetReleaseTag = v12.0.0205`
- `GetReleaseAtual = V12.0.0205`
- `GetReleaseAlvo = V12.0.0206`
- `GetBuildImportado = e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix`
- RVS `VR_20260524_164612` APROVADO.

Export bruto:

```text
local-ai/incoming/V206_ANCHOR_V5_20260524/
```

Preflight anterior:

- 62 arquivos exportados da V5;
- 66 arquivos em `src/vba`;
- ausentes na V5: `Altera_Entidade.frm`, `Altera_Entidade.frx`,
  `Emergencia_CNAE.bas`, `Importador_V2.bas`;
- diversos arquivos comuns diferem mesmo apos normalizar CRLF;
- nao fazer overwrite automatico.

## Tarefa Inicial Ao Retomar

Nao implementar PDF ainda.

1. Incorporar a devolutiva do Claude Opus 4.7.
2. Criar readback/ERP para a reconciliacao V5.
3. Auditar drift entre `local-ai/incoming/V206_ANCHOR_V5_20260524/` e
   `src/vba/`.
4. Produzir matriz de classificacao:
   - igual;
   - diferenca export/VBE benigna;
   - diferenca funcional;
   - ausente no workbook;
   - obsoleto no repo;
   - precisa de decisao humana.
5. Somente apos hearback preparar novo MD33-restart para corrigir:
   - `Rel_OSEmpresa`;
   - `Rel_Emp_Serv`.

## Roadmap V206 Depois da Reconciliacao

1. MD33-restart: correcao dos dois relatorios, com teste isolado.
2. Onda 34: `Util_PDF.bas` com pastas, nomes, validacao `%PDF-`, log e fallback.
3. Onda 35: integracao PDF em Pre-OS, OS, Avaliacao e Relatorios.
4. Onda 36: simulacao UI/PDF isolada, fora do RVS.
5. Onda 37: jornada humana, RC e freeze.

## V207

Nao executar V207 neste prompt. Apenas respeitar a separacao:

- V206 = entrega incremental PDF/relatorios/jornada.
- V207 = code review profundo e reformulacao, conforme
  `auditoria/02_planos/33_ROADMAP_V207_CODE_REVIEW_REFORMULACAO.md`.

## Saida Esperada da Primeira Resposta Codex

- Status do contexto.
- Arquivos lidos.
- Se o documento 105 do Claude existe.
- Plano curto de reconciliacao V5.
- Confirmacao de que nenhum VBA funcional sera alterado sem hearback humano.
