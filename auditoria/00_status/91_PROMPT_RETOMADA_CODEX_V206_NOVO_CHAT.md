---
titulo: Prompt de Retomada Codex V12.0.0206 — Novo Chat
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Prompt de Retomada — Codex V12.0.0206

Use este prompt no novo chat Codex para assumir o bastão.

```text
Você é Codex e está assumindo o bastão de desenvolvimento da V12.0.0206 do
Sistema de Credenciamento e Rodízio de Pequenos Reparos.

Contexto obrigatório:

- A V12.0.0205 foi congelada e publicada em GitHub Release/tag `v12.0.0205`.
- Commit base estável: `f24e535 release: freeze v12.0.0205`.
- Evidência final V205: `VR_20260523_215637`.
- Assinatura de não regressão:
  `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.
- A branch de planejamento é `codex/v12-0-0206-planejamento`.
- A grafia canônica é `V12.0.0206`, nunca `V12.0.206`.

Primeiro faça:

1. `git status --short --branch`
2. `git log --oneline --decorate --max-count=5`
3. Leia `AGENTS.md`.
4. Leia `.hbn/relay/INDEX.md`.
5. Leia:
   - `auditoria/00_status/83_READBACK_ABERTURA_V206_CODEX.md`
   - `auditoria/00_status/88_AUDITORIA_PLANEJAMENTO_V206_CLAUDE_OPUS.md`
   - `auditoria/00_status/89_AUDITORIA_ADVERSARIAL_PLANEJAMENTO_V206_GEMINI.md`
   - `auditoria/00_status/90_CONSOLIDACAO_ROADMAP_V206_CODEX.md`
   - `auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md`

Regras duras:

- Não alterar RN-01 a RN-17.
- Não alterar os contadores do RVS.
- Não incluir teste de PDF nas seis baterias do RVS.
- Não mover nem reorganizar `doc/`.
- Não tocar `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas` ou
  `Svc_PreOS.bas` na V12.0.0206 salvo P0 explícito e hearback humano.
- Não renomear símbolos internos VBA.
- Toda mudança funcional exige teste correspondente.
- Fonte de verdade é `src/vba/`; `local-ai/vba_import/` é espelho.

Roadmap consolidado V206:

1. Onda 31 — Higiene documental e evidências.
2. Onda 32 — Importador V3 e mensagens operacionais.
3. Onda 33 — Especificação e teste PDF isolado.
4. Onda 34 — PDF automático robusto.
5. Onda 35 — Jornada humana V206.
6. Onda 36 — Débitos pequenos nominais.
7. Onda 37 — RC e freeze V206.

Tarefa inicial no novo chat:

- Confirmar se o operador aprova o roadmap consolidado.
- Se aprovado, iniciar Onda 31.
- Antes de editar, criar readback/ERP da Onda 31.
- Na Onda 31, não tocar código VBA. Fazer apenas higiene documental,
  evidências, link scan, frontmatter e decisão sobre `MANIFESTO.csv`.

Saída esperada da primeira resposta:

- Status do contexto.
- Arquivos lidos.
- Plano curto da Onda 31.
- Confirmação de que nenhum código será alterado sem hearback humano.
```

