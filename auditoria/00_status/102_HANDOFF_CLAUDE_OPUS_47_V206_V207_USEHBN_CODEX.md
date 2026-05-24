---
titulo: Handoff Claude Opus 4.7 — V206, V207 e Protocolo useHBN
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Handoff Claude Opus 4.7 — V206, V207 e Protocolo useHBN

## Veredito do Bastao

Codex passa o bastao para Claude Opus 4.7 revisar e melhorar o protocolo de
entrada, os documentos de handoff e as barreiras inter-IA antes de retomarmos
qualquer implementacao funcional.

Claude deve tratar este handoff como documento de contexto, nao como ordem
fechada. Se Claude propuser regras mais fortes para useHBN, barreiras reais ou
acordos entre IAs, a retomada por Codex deve respeitar essas regras apos
hearback humano.

## Estado Atual

| Campo | Valor |
|---|---|
| Versao oficial congelada | `V12.0.0205` |
| Tag GitHub | `v12.0.0205` |
| Commit base estavel | `f24e535 release: freeze v12.0.0205` |
| Evidencia final V205 | `VR_20260523_215637` |
| Assinatura V205 | `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` |
| Branch ativa | `codex/v12-0-0206-planejamento` |
| Ultimo commit Codex | `8317d0c docs: anchor v206 restart on V5 workbook` |
| Raiz canonica | `/Users/macbookpro/Projetos/Credenciamento` |
| Workbook anchor V206 | `PlanilhaCredenciamento-Homologacao-V5.xlsm` |
| Origem do workbook anchor | `V12-205-OficialCongelada` |
| Export bruto V5 | `local-ai/incoming/V206_ANCHOR_V5_20260524/` |

## Evidencia da V5

O operador confirmou na Janela Imediata:

```text
?ThisWorkbook.Path
\\Mac\Home\Projetos\Credenciamento

ImportarPacoteV3_Status
MANIFESTO ESPERADO:
  \\Mac\Home\Projetos\Credenciamento\local-ai\vba_import\000-MANIFESTO-V3-PHASE1.txt
  STATUS: presente
MODO DETECTADO: Estabilizado

?GetReleaseTag
v12.0.0205

?GetReleaseAtual
V12.0.0205

?GetReleaseAlvo
V12.0.0206

?GetBuildImportado
e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix
```

RVS na V5:

```text
ID: VR_20260524_164612
Resultado: APROVADO
Sintaxe: V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
CSV: auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260524_164612.csv
```

## Incidentes Encerrados

1. Worktree errado em `/private/tmp/cred-v205`.
   - Corrigido: branch ativa agora esta na raiz canonica.
   - Evidencia: `auditoria/00_status/98_DIAGNOSTICO_RAIZ_CANONICA_V206_CODEX.md`.

2. MD33, fix1 e fix2 importaram, mas o Excel fechou no compile.
   - Decisao: nao usar os pacotes reprovados na V5.
   - Evidencia: `auditoria/00_status/100_PAUSA_REBASE_PLANILHA_LIMPA_V206_CODEX.md`.

3. Orientacao incorreta de restaurar a partir de `backups/vba`.
   - Corrigido no `Importador_V3.bas` e na documentacao.
   - Regra atual: `backups/vba` e evidencia/diagnostico; nunca fonte de import.

4. Rota `V12-0206-Preparacao` tambem reprovada como base.
   - Decisao: substituida por V5 derivada de `V12-205-OficialCongelada`.
   - Evidencia: `auditoria/00_status/101_ANCHOR_V5_REINICIO_V206_CODEX.md`.

## Reconciliação V5 vs src/vba

O operador exportou todos os componentes da V5 para:

```text
local-ai/incoming/V206_ANCHOR_V5_20260524/
```

Preflight Codex:

- `local-ai/incoming/V206_ANCHOR_V5_20260524/`: 62 arquivos.
- `src/vba/`: 66 arquivos `.bas/.frm/.frx`.
- `local-ai/` e ignorado pelo Git, portanto o export nao sera commitado.
- O export bruto serve para comparacao, nao para overwrite automatico.

Arquivos presentes em `src/vba/` e ausentes no export V5:

```text
Altera_Entidade.frm
Altera_Entidade.frx
Emergencia_CNAE.bas
Importador_V2.bas
```

Arquivos comuns cujo conteudo normalizado por CRLF bate:

```text
Auto_Open.bas
Central_Testes.bas
Central_Testes_V2.bas
Classificar.bas
Const_Colunas.bas
ErrorBoundary.bas
Mod_Limpeza_Base.bas
Mod_Types.bas
```

Arquivos comuns com diferenca textual normalizada precisam de classificacao,
incluindo `Importador_V3.bas`, `App_Release.bas`, `Menu_Principal.frm`,
`Preencher.bas`, relatorios, repositorios, servicos e testes. Isso nao autoriza
substituir `src/vba/` pelo export V5; exige auditoria de drift.

## V12.0.0206 — Escopo Proposto

Objetivo: evoluir a partir da V205 congelada sem reabrir regras de negocio.

### Fase 1 — Reconciliacao V5

1. Auditar drift entre `local-ai/incoming/V206_ANCHOR_V5_20260524/` e
   `src/vba/`.
2. Classificar cada divergencia:
   - diferenca esperada de export VBE;
   - drift historico benigno;
   - diferenca operacional real;
   - arquivo obsoleto em `src/vba/`;
   - arquivo ausente indevidamente no workbook.
3. Propor decisao humana antes de qualquer pacote de import.

### Fase 2 — MD33-restart: formularios de relatorio

Problema confirmado nas auditorias 95/96:

- `Rel_OSEmpresa`
- `Rel_Emp_Serv`

Bug: handlers criam instancia vazia depois do preenchimento ocorrer em outra
instancia. Correção anterior falhou no workbook contaminado; na V5 deve ser
reprojetada em pacote pequeno, com teste isolado e sem tocar `Svc_*`.

Gates:

- import via `local-ai/vba_import` apenas;
- compile ou gate equivalente sem fechamento do Excel;
- smoke/validador de UI isolado;
- nenhuma alteracao nos contadores do RVS.

### Fase 3 — Onda 34: motor PDF central

Criar `Util_PDF.bas` novo, isolado da regra de negocio.

Contrato aprovado pelo operador:

```text
Documentos_Gerados/
  Pre-OS/
  OS/
  Avaliacoes/
  Relatorios/
  Validacao/
  Testes_UI/<RUN_ID>/

<TIPO>_<NUMERO_DOCUMENTO>_CNPJ_<CNPJ_LIMPO>_<AAAAMMDD_HHNNSS>.pdf
```

Requisitos:

- raiz ao lado da planilha;
- se workbook nao estiver salvo, fallback manual claro;
- criar subpastas automaticamente;
- sanitizar nome, CNPJ e tipo;
- validar arquivo por existencia, tamanho e assinatura `%PDF-`;
- registrar `RPT_PDFs_EMITIDOS.csv`;
- fallback manual visivel sem bloquear Pre-OS/OS ja persistida;
- testes isolados fora do RVS.

### Fase 4 — Integracao PDF

Integrar em etapas:

1. Pre-OS.
2. OS.
3. Avaliacao.
4. Relatorios.

Cada etapa exige teste correspondente. PDF nao entra nas seis baterias do RVS.

### Fase 5 — Simulacao UI/PDF

Criar bateria isolada para simulacao de cliques/fluxos, provavelmente em
`Teste_V2_UI.bas` ou modulo equivalente, sem alterar contadores RVS.

## Regras Duras Mantidas na V206

- Nao alterar RN-01 a RN-17.
- Nao alterar contadores RVS.
- Nao incluir teste PDF nas seis baterias do RVS.
- Nao mover nem reorganizar `doc/`.
- Nao tocar `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas` ou
  `Svc_PreOS.bas` salvo P0 explicito e hearback humano.
- Nao renomear simbolos internos VBA.
- Toda mudanca funcional exige teste correspondente.
- Fonte de verdade versionada: `src/vba/`.
- Fonte operacional de importacao: `local-ai/vba_import/`.
- `local-ai/incoming/` e somente export bruto para comparacao.
- `backups/vba/` e somente evidencia/diagnostico.

## V12.0.0207 — Handoff de Code Review e Reformulacao

V207 deve absorver o que deliberadamente fica fora da V206.

Escopo recomendado:

1. Code review profundo de `src/vba/`.
2. Inventario de formularios, eventos, dependencias e pontos de acoplamento.
3. Revisao arquitetural do importador, espelhos e drift workbook/repo.
4. Reformulacao controlada de testes UI e simulacao externa, se aprovada.
5. Revisao de modulos legados e simbolos obsoletos.
6. Plano de reducao de tamanho/risco em `Preencher.bas`, `Util_Config.bas` e
   formularios grandes.
7. Protocolo formal inter-IA com barreiras automatizaveis.
8. Estrategia de migracao para futuro sem depender de edicao manual no VBE.

Fora da V207 sem novo hearback:

- alterar regras RN-01..RN-17;
- alterar semantica de rodizio;
- reescrever servicos centrais sem bateria nova;
- trocar linguagem/plataforma.

## Protocolo useHBN — Pontos para Claude Avaliar

Propostas abertas para Claude Opus 4.7 revisar, endurecer ou substituir:

1. **Preflight obrigatorio e bloqueante**
   - `pwd`
   - `git rev-parse --show-toplevel`
   - `git status --short --branch`
   - `git worktree list`
   - `ImportarPacoteV3_Status` quando houver workbook.

2. **Barreira de origem**
   - IA so escreve entregaveis em `/Users/macbookpro/Projetos/Credenciamento`.
   - Qualquer `/private/tmp` vira P0 automatico.

3. **Barreira de importacao**
   - Nenhuma IA pode orientar import a partir de `src/vba`, `incoming` ou
     `backups`.
   - Excel importa somente de `local-ai/vba_import`.

4. **Barreira de drift**
   - Se houver export VBE em `incoming`, nenhuma mudanca funcional pode
     prosseguir antes de classificar divergencias relevantes.

5. **Barreira de ownership entre IAs**
   - Claude: auditoria, protocolo, riscos e propostas.
   - Codex: implementacao incremental apos hearback.
   - Gemini/Antigravity: auditoria adversarial quando solicitado.
   - Nenhuma IA deve criar pacote funcional sem readback/ERP atualizado.

6. **Barreira de status**
   - `.hbn/relay/INDEX.md` deve sempre apontar para uma unica proxima acao.
   - Documentos superados devem ser marcados como historico, nao apagados.

## Pedido a Claude Opus 4.7

Leia os documentos listados abaixo, audite este handoff, corrija omissoes e
proponha melhorias no protocolo antes de devolver para Codex executar:

- `AGENTS.md`
- `.hbn/relay/INDEX.md`
- `.hbn/knowledge/0002-regra-ouro-vba-import.md`
- `.hbn/knowledge/0012-raiz-canonica-projeto.md`
- `auditoria/00_status/97_CONSOLIDACAO_PDF_UI_V206_CODEX.md`
- `auditoria/00_status/101_ANCHOR_V5_REINICIO_V206_CODEX.md`
- este arquivo
- `auditoria/02_planos/33_ROADMAP_V207_CODE_REVIEW_REFORMULACAO.md`
- `auditoria/00_status/103_PROMPT_AUDITORIA_CLAUDE_OPUS_47_HANDOFF_V206_V207_USEHBN.md`
- `auditoria/00_status/104_PROMPT_RETOMADA_CODEX_V206_NOVO_CONTEXTO.md`

Claude deve devolver:

1. parecer sobre consistencia do handoff;
2. ajustes ao protocolo useHBN;
3. barreiras reais obrigatorias antes da V206;
4. decisao sobre como reconciliar export V5 vs `src/vba`;
5. plano ajustado para Codex retomar em novo chat.
