---
titulo: Superprompt Codex — retomada da V206 a partir da Onda 38
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-05-25
autor: claude-opus-4-7
papel: arquiteto-principal (devolvendo bastao para Codex)
sucede: 106_DEVOLUTIVA_OPUS_PROMPT_RETOMADA_CODEX_V206.md
sessao: ABRIR NOVA SESSAO CODEX (chat antigo da Onda 37 esta saturado)
---

# Superprompt Codex — retomada V206 a partir da Onda 38

## Para Mauricio (humano)

**Abrir NOVA sessão Codex.** A sessão antiga (que rodou Onda 37, 37.1, 37.2)
tem instruções desatualizadas (procedimento 37_2_PROCEDIMENTO_IMPORT.md
recomendava `ImportarPacoteV3()` completo) e está saturada de contexto da
crise de compile. Cole literalmente da seção `## Prompt para colar no Codex`
abaixo no chat novo.

**Antes de abrir o Codex, garanta**:

```
cd /Users/macbookpro/Projetos/Credenciamento
```

```
git status --short
```

(Esperado: workbook salvo + Onda 37.3 + 37.4 commitadas e pushadas; nenhum
arquivo VBA pendente).

```
bash scripts/hbn-guards/hbn-guards-runner.sh
```

(Esperado: 5/5 ✓).

```
git log --oneline -6
```

(Esperado: ver commit `fix(v206): onda 37.3 reset src/vba para estado V5
funcional` + Onda 37 + 37.1 + 37.2 + 36 antes).

---

## Prompt para colar no Codex (NOVA sessão)

```
Você é Codex retomando o ciclo V12.0.0206 do Sistema de Credenciamento em
sessão NOVA. O ciclo passou pelas Ondas 36 (Cura do Protocolo), 37
(Reconciliação V5), 37.1 (Diagnóstico drift MD33), 37.2 (Reversão drift
MD33 — falhou no compile por uso indevido de ImportarPacoteV3 completo),
37.3 (Reset src/vba para V5 puro executado por Claude Opus 4.7 como
arquiteto temporário) e 37.4 (Microdelta NOOP que validou
ImportarPacoteV3_Delta).

Estado atual confirmado por gate humano:
- Workbook V5 salvo com APP_BUILD_IMPORTADO = e43352f+ONDA37.4-teste-delta-noop
- Compile VBE passa limpo
- CT_ValidarRelease_TrioMinimo APROVADO: V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0
  (VR_20260524_235715)
- src/vba/ tem 64 arquivos (exatamente o conteudo do export V5)
- Importador_V2.bas e Emergencia_CNAE.bas REMOVIDOS (ADRs da Onda 37.1)
- 25 arquivos drift_legitimo_anterior_v5 NAO estao no src/vba — historico
  git preserva, podem ser reimportados caso a caso se necessario

Bastao transferido de Claude Opus 4.7 para Codex em 2026-05-25.

=== PASSO 0 — Pre-flight obrigatorio ===

Execute, sem pular nenhum:

  pwd
  git rev-parse --show-toplevel
  git status --short --branch
  git log --oneline --decorate --max-count=8
  git worktree list
  bash scripts/hbn-guards/hbn-guards-runner.sh
  cat .hbn/canonical-root

Pre-condicoes:
- pwd = /Users/macbookpro/Projetos/Credenciamento
- git toplevel = mesmo path
- Branch ativa = codex/v12-0-0206-planejamento
- Sem worktree em /tmp ou areas volateis
- hbn-guards-runner retorna exit 0 com 5/5 verdes
- .hbn/canonical-root contem o path canonico

Se qualquer pre-condicao falhar, PARE e emita:
  🟡 HBN NEEDS HUMAN DECISION
  Pre-condicoes nao satisfeitas: [listar]
  Aguardando Mauricio.

=== PASSO 1 — Leitura obrigatoria (na ordem, com resumo de 3 linhas cada) ===

  1. AGENTS.md — secao 'Contratos executaveis'
  2. .hbn/relay/INDEX.md — estado atual do bastao
  3. .hbn/knowledge/0012-raiz-canonica-projeto.md
  4. .hbn/knowledge/0013-contratos-executaveis.md
  5. .hbn/knowledge/0018-uso-delta-vs-completo.md  <-- REGRA NOVA L33
  6. auditoria/00_status/107_SUPERPROMPT_CODEX_RETOMADA_ONDA_38_PDF.md (este arquivo)
  7. auditoria/03_ondas/onda_37_3_reset_src_vba_v5/37_3_TECNICO.md
  8. auditoria/03_ondas/onda_37_3_reset_src_vba_v5/37_4_TESTE_DELTA_NOOP.md
  9. auditoria/04_evidencias/V12.0.0206/reconciliacao_v5/classificacao_drift_funcional.md
  10. auditoria/01_regras_e_governanca/L26_LICOES_MD33_TENTATIVAS_FRUSTRADAS.md
  11. auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md
  12. auditoria/00_status/97_CONSOLIDACAO_PDF_UI_V206_CODEX.md
  13. local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO60-V205-MD27-1.txt
      (exemplo de manifesto delta recente)
  14. local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA37-4-TESTE-NOOP.txt
      (manifesto NOOP que validou o fluxo)
  15. src/vba/Importador_V3.bas linhas 130-285 (assinaturas das funcoes do importador)

=== PASSO 2 — Regra-mae deste ciclo ===

Toda alteracao funcional em VBA importada no workbook usa
EXCLUSIVAMENTE ImportarPacoteV3_Delta(nomeDelta, buildLabel).

Anti-padrao PROIBIDO: ImportarPacoteV3() completo. Razao: gera fantasma
de cache de compile no VBE quando workbook ja tem componentes. Detalhe
em .hbn/knowledge/0018-uso-delta-vs-completo.md.

Para cada onda safe_track:

  a) Editar arquivo(s) em src/vba/ (mudanca pequena, 1-5 arquivos).
  b) Editar src/vba/App_Release.bas (APP_BUILD_IMPORTADO + GERADO_EM).
  c) Criar local-ai/vba_import/000-MANIFESTO-V3-DELTA-<NOME>.txt listando
     apenas os arquivos tocados + sempre incluir AAX-App_Release.bas
     como ultimo item (carimbo).
  d) Emitir readback safe_track conforme .hbn/schemas/readback.schema.json
     com scope.files_allowed limitado aos arquivos tocados + manifesto +
     hbn artifacts + auditoria/03_ondas/onda_<NN>/**.
  e) PARAR e pedir hearback a Mauricio (atualizar human_status para
     confirmed apos aprovacao).
  f) Apos hearback: rodar bash local-ai/scripts/publicar_vba_import_v2.sh
     --apply (G7 verde), bash scripts/hbn-guards/hbn-guards-runner.sh (5/5).
  g) git add ... && git commit -m "...".
  h) git push origin codex/v12-0-0206-planejamento.
  i) Devolver para Mauricio o comando UNICO de import na Janela Imediata:
        ImportarPacoteV3_Delta "<NOME>", "<buildLabel>"
     + 1 frase de expectativa (M=N | F=M | err=0).
  j) Pedir a Mauricio: compile manual (Depurar > Compilar VBAProject) +
     CT_ValidarRelease_TrioMinimo (ou superior).
  k) ERP fica delivered_for_human_gate ate Mauricio reportar compile +
     smoke OK; entao fechamos ERP com gates_evidence pass.

Padrao de comunicacao com Mauricio: cada instrucao para terminal/VBE em
um bloco de codigo ATOMICO, sem comentario inline. Audit fica nos .md;
chat tem 1 comando + 1 expectativa + 1 fallback (L27 + L28).

=== PASSO 3 — Roadmap das proximas ondas ===

| Onda | Tema | Estimativa | Arquivos tocados |
|---|---|---|---|
| **38** | MD33-restart correto — corrigir handlers de Rel_OSEmpresa e Rel_Emp_Serv (bug: handlers criam instancia vazia depois do preenchimento ocorrer em outra instancia) | 1-2 microdeltas | Rel_OSEmpresa.frm, Rel_Emp_Serv.frm, AAX-App_Release.bas |
| **39** | Util_PDF.bas — motor central PDF (contrato em auditoria/00_status/97_CONSOLIDACAO_PDF_UI_V206_CODEX.md) | 1 microdelta | Util_PDF.bas (novo), AAX-App_Release.bas |
| **40.1** | Integracao PDF em Pre-OS | 1 microdelta | Repo_PreOS.bas, AAX |
| **40.2** | Integracao PDF em OS | 1 microdelta | Repo_OS.bas, AAX |
| **40.3** | Integracao PDF em Avaliacao | 1 microdelta | Repo_Avaliacao.bas, AAX |
| **40.4** | Integracao PDF em Relatorios | 1 microdelta | Rel_*.frm + AAX |
| **41** | Bateria isolada simulacao UI/PDF (FORA do RVS) | 1 microdelta | Teste_V2_UI.bas (novo), AAX |
| **42** | Jornada humana V206 + freeze + tag v12.0.0206 | doc-only | docs/, auditoria/, CHANGELOG, tag git |

Cada onda gera readback proprio. PARAR a cada onda para hearback.

Regras DURAS mantidas:
- Nao alterar RN-01 a RN-17
- Nao alterar contadores RVS (V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0)
- Nao incluir testes PDF nas 6 baterias do RVS
- Nao mover doc/
- Nao tocar Svc_Rodizio.bas, Svc_Avaliacao.bas, Svc_OS.bas, Svc_PreOS.bas
  salvo P0 explicito + hearback humano dedicado
- Nao renomear simbolos VBA
- Importacao: SEMPRE via ImportarPacoteV3_Delta (knowledge 0018)
- Fonte versionada: src/vba/
- Fonte operacional de import: local-ai/vba_import/
- local-ai/incoming/ e read-only (evidence, nao fonte de import)
- backups/vba/ e evidencia/diagnostico, nao fonte de import

=== PASSO 4 — Onda 38 (primeira a executar) ===

Foco: corrigir o bug confirmado nas auditorias 95/96:
- Rel_OSEmpresa: handler cria instancia vazia depois do preenchimento
- Rel_Emp_Serv: mesmo padrao

Hipotese de correcao (sujeita a auditoria que voce fara primeiro):
Em geral o padrao certo em VBA UserForm e:
  Dim frm As Rel_OSEmpresa
  Set frm = New Rel_OSEmpresa
  Call frm.Preencher(dados)
  frm.Show vbModal
  Unload frm
  Set frm = Nothing

Em vez de:
  Rel_OSEmpresa.Preencher(dados)  <- cria instancia default vazia
  Rel_OSEmpresa.Show               <- mostra outra instancia

Antes de propor readback, leia o codigo atual em
src/vba/Rel_OSEmpresa.frm e src/vba/Rel_Emp_Serv.frm e identifique
EXATAMENTE a linha onde o pattern errado esta. Se sua hipotese diverge
do que vai encontrar, ajuste — NAO copie textualmente o que esta acima.

Saida esperada na primeira resposta do Codex:
1. Listar 14 documentos lidos com resumo de 3 linhas cada.
2. Confirmar pre-flight 8/8.
3. Auditoria das linhas exatas do bug em Rel_OSEmpresa.frm e Rel_Emp_Serv.frm.
4. Propor readback 0094 safe_track com scope MINIMO (somente os 2 .frm + AAX).
5. Apresentar o readback em chat + criar arquivo
   .hbn/readbacks/0094-onda38-md33-restart-rel-os-rel-emp-serv.json com
   human_status: pending.
6. PARAR e pedir hearback de Mauricio.

🟡 HBN NEEDS HUMAN DECISION sempre que descobrir algo inesperado
(symbol ausente, drift novo, dependencia nao mapeada). NAO TOMAR DECISAO
UNILATERAL.

=== PASSO 5 — Apos Onda 38 fechada ===

Continuar 39 -> 40.1 -> 40.2 -> 40.3 -> 40.4 -> 41 -> 42 em ondas
microdelta separadas, cada uma com readback + hearback + ERP.

Onda 42 fecha V12.0.0206 com tag git assinada + release pública.

=== PASSO 6 — Sinais HBN obrigatorios ===

- ✅ HBN ACTIVE — protocolo engajado
- 🟡 HBN NEEDS HUMAN DECISION — aguardando Mauricio
- ❌ HBN SECURITY BLOCKED SUGGESTION — recusa por seguranca
- 🔵 HBN HANDOFF READY — pacote pronto para Mauricio
- 🔍 GROUPTHINK ALARM — concordou demais sem questionar
- 🪞 MIRROR DRIFT — reciclou linguagem sem agregar
- 🟠 SOURCE DRIFT DETECTED — drift novo entre fontes
- 🟢 GATE PASSED — gate humano confirmado

Cada turno significativo abre com pelo menos um.

=== Lembrete final ===

A V12.0.0206 tem ENTREGA URGENTE. O cronograma e 38 -> 39 -> 40.1 -> ...
-> 42 ate ter PDFs automaticos funcionando + Rel_* corrigidos. Cada onda
microdelta de 1-5 arquivos. Sem 'big bang' de import. Sem ImportarPacoteV3
completo.

Mauricio confiou em voce o caminho final da V206. Bastao aceito.
```

---

## Sobre cronograma e expectativas de entrega

**Ordem dos passos a partir de agora**:

1. **Esta noite ou amanhã cedo** — Mauricio salva workbook + commit 37.3+37.4 + push (≤30 min).
2. **Amanhã** — Mauricio abre nova sessão Codex com prompt acima → Codex executa Onda 38 (correção Rel_*). Estimativa: 2-4 h de ciclo (readback, hearback, edit, publicar, commit, import, compile, smoke, ERP).
3. **Mesmo dia** — Onda 39 (Util_PDF.bas, motor central): 4-6 h.
4. **Dia seguinte** — Ondas 40.1, 40.2, 40.3, 40.4 (integração PDF, uma por consumidor): 1-3 h cada. Pode rodar em paralelo se você tiver fôlego.
5. **Mais 1 dia** — Onda 41 (simulação UI/PDF fora do RVS): 2-4 h.
6. **Último dia** — Onda 42 (jornada humana + freeze + tag v12.0.0206): 2-3 h.

**Total realista**: 4-6 dias de trabalho dedicado se cada onda tiver hearback rápido. Compactável para 2-3 dias se você estiver disponível para hearback contínuo.

## O que VOCÊ precisa fazer agora (ordem)

Comandos atômicos:

```
cd /Users/macbookpro/Projetos/Credenciamento
```

**No Excel**: Cmd+S no workbook para salvar com o novo carimbo `e43352f+ONDA37.4-teste-delta-noop`. Fecha Excel.

```
git status --short
```

```
bash local-ai/scripts/publicar_vba_import_v2.sh --apply
```

```
bash scripts/hbn-guards/hbn-guards-runner.sh
```

```
git add src/vba/ local-ai/vba_import/ auditoria/03_ondas/onda_37_3_reset_src_vba_v5/ .hbn/readbacks/0093-onda37-3-reset-src-vba-para-v5.json .hbn/results/0093-exec-onda37-3-reset-src-vba-para-v5.json .hbn/knowledge/0018-uso-delta-vs-completo.md .hbn/relay/INDEX.md auditoria/00_status/107_SUPERPROMPT_CODEX_RETOMADA_ONDA_38_PDF.md CHANGELOG.md
```

```
git diff --cached --stat | tail -10
```

```
git commit -m "fix(v206): onda 37.3 reset src/vba V5 + onda 37.4 valida ImportarPacoteV3_Delta"
```

```
git push origin codex/v12-0-0206-planejamento
```

Cola o output dos últimos 3 comandos aqui. Eu confirmo que tudo fechou e te dou GO para abrir nova sessão Codex com este superprompt.
