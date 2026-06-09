---
titulo: Parecer Claude Opus 4.8 — Auditoria cruzada pos-0165/0166
diataxis: status
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-09
---

# Parecer Claude Opus 4.8 — Auditoria cruzada pos-0165/0166

> Auditoria arquiteto-auditor externo (Cadencia D Estendida, chat novo, estado
> reconstruido por `Read`/`git`/`grep`, nunca por memoria). Foco no que o par
> adversarial Antigravity Gemini 3.5 — [`0167_PARECER_ANTIGRAVITY_GEMINI35_ADVERSARIAL.md`](0167_PARECER_ANTIGRAVITY_GEMINI35_ADVERSARIAL.md)
> deixou de cobrir: **rastreabilidade e conformidade do protocolo HBN no
> fechamento 0165/0166** (perguntas 1, 2 e 3 do prompt). A parte
> comportamental/PDF/UX foi verificada de forma independente e converge com o
> parecer Antigravity; nao a duplico, apenas referencio e calibro severidade.

---

## 1. Findings (severidade primeiro)

### FORTE-1 — ERP da onda 0166 nao existe: 0166 esta formalmente ABERTA

O proprio readback 0166 exige, no `validation_plan`, quatro gates `audit_post`
cuja evidencia mora em `.hbn/results/0166-exec-onda-38-2-35-limpeza-worktree-pos-0165.json`
(commit local criado, escopo conferido, worktree limpo). **Esse arquivo nao
existe** e nunca foi commitado.

Evidencia:
- `.hbn/readbacks/0166-rb-onda-38-2-35-limpeza-worktree-pos-0165.json` L102-124
  (gates) e L69-77 (`implementation_plan.after_hearback` ultimo passo:
  "Registrar ERP 0166 com hash do commit e status final do worktree").
- `test -f .hbn/results/0166-...json` → `NO - 0166 ERP MISSING`.
- `git log --all -- .hbn/results/0166-exec-onda-38-2-35-limpeza-worktree-pos-0165.json`
  → vazio (nunca esteve em historico).
- `ls .hbn/results/ | grep 0166` → vazio; so existe o ERP 0165.

Impacto: viola `AGENTS.md` (Working pattern, passo 4 "Termina com **ERP**") e
"Contratos executaveis", item 4 ("Produzir ERP ... ao fechar"). Sem ERP, o
fechamento de 0166 nao tem o artefato que amarra o commit `945039d` ao gate
humano e ao estado final do worktree. Nota: ha tensao galinha-ovo conhecida (o
ERP precisa registrar o hash do proprio commit de limpeza), o que **obriga** o
ERP a vir em commit de follow-up — exatamente o passo que faltou. Remediavel sem
tocar codigo de dominio.

### FORTE-2 — Relay com frontmatter estagnado e sem bloco 0166

O relay [`.hbn/relay/INDEX.md`](../../../.hbn/relay/INDEX.md) tem bloco GATE para
0165 (topo, L11-31) mas **nenhum bloco para a onda 0166**, e o frontmatter de
governanca esta desatualizado em relacao ao estado real:

- L7 `proxima-acao`: ainda afirma "0165 permanece sem commit proprio" — **falso**
  apos `945039d`, que commitou justamente os artefatos de 0165 (`grep -n "0166" .hbn/relay/INDEX.md` → vazio; `git show --name-only 945039d` lista todos os artefatos 0165).
- L4-5 `proprietario-bastao`/`ciclo-ativo`: a prosa narrativa termina em 38.2.32/0163;
  nao menciona 0164 (fechada), 0165 (fechada) nem 0166 (limpeza). O bloco GATE de
  0164/0165 existe no corpo, mas a "verdade rapida" do frontmatter contradiz o corpo.

Impacto: viola a regra permanente de higiene documental recorrente
(`AGENTS.md` L184-187; knowledge 0011). Qualquer IA que assuma o bastao pelo
frontmatter (que e o atalho canonico "quem tem o bastao agora") parte de um
estado falso.

### MARGINAL-1 — Commit 945039d: titulo e granularidade nao espelham 0166

`945039d` tem titulo `chore(hbn): consolida onda 0165 pre-os vencidas`, mas
**funcionalmente e o commit da onda 0166** (limpeza/consolidacao pos-0165): ele
carrega os readback/hearback de 0166 e os artefatos 0165. Quem procurar "o commit
de 0166" por mensagem nao acha. Alem disso, 0165 nunca teve commit proprio — foi
absorvido pela limpeza 0166. Aceitavel pela natureza housekeeping, mas a mensagem
deveria citar ambas as ondas (`0165 + 0166`). Evidencia: `git show --stat 945039d`.

### MARGINAL-2 — 0166 sem documento tecnico

`AGENTS.md` L134-135 pede UM tecnico por onda. 0166 nao tem
`auditoria/03_ondas/onda_38_2_35.../0166_TECNICO.md` (a pasta 38_2_35 contem
apenas os pareceres de auditoria desta onda cruzada). Defensavel por ser onda de
git-hygiene cujo readback+ERP bastariam — mas o ERP tambem falta (ver FORTE-1).

### MARGINAL-3 — Dois commits locais nao publicados (b33ec4e, 945039d)

Branch `codex/v12-0-0206-planejamento` esta `ahead 2` de origin
(`git status -sb`). `b33ec4e` foi `[bypass-hbn-guards]` (nota em
`.hbn/bypasses/20260608-153628-checkpoint-ondas-0153-0164.md`); `945039d` passou
os guards sem bypass. Push e deliberadamente nao-feito (0166 non_goals). Nao e
bloqueador — push e humano-gated pelo firewall 0022 — mas o handoff deve registrar
que o remoto esta defasado em 2 commits, sendo 1 deles via bypass.

### Findings comportamentais (Antigravity) — calibracao independente

Reverifiquei por amostragem e concordo com a classificacao MARGINAL do parecer
Antigravity, com duas notas:
- **C16 espacamento distribuido no PDF** e **rodape "V12.0.0205"**: ambos sao
  **pre-existentes** (heranca de 0163/0164 e da convencao de versionamento sem
  FREEZE — `APP_RELEASE_ATUAL` aponta para a release oficial vigente), **nao
  introduzidos por 0165/0166**. Logo nao impactam o fechamento auditado aqui;
  entram como backlog tela-a-tela.
- **Mascaramento de "OS EM EXECUCAO" sob suspensao global** (Antigravity §1.3/§6):
  concordo que e o mais "denso" dos MARGINAIS — beira FORTE em UX — mas tambem e
  comportamento herdado de 0163/0164, fora do delta 0165. Recomendo trata-lo como
  onda propria (ver §5, Onda B).

---

## 2. VETO_AVANCO

**VETO_AVANCO: NAO**

A substancia da onda 0165 esta integra e validada (ver §3). As lacunas FORTE-1 e
FORTE-2 sao de **rastreabilidade documental**, remediaveis por uma micro-onda de
higiene doc-only sem tocar codigo de dominio, e nao corrompem workbook nem
invalidam o gate humano ja observado. Os findings comportamentais sao MARGINAIS e
herdados. Portanto: **a validacao tela a tela da V12.0.0206 pode prosseguir**,
**condicionada** a executar a Onda A (§5) — fechar 0166 com ERP + sanear o relay —
como primeiro passo, antes de abrir nova onda de feature.

Nao e veto porque nenhum finding e BLOQUEADOR (seguranca/correcao/regressao): o
codigo de producao do relatorio esta correto e provado read-only; o gate humano
import/compile/TV2 passou; nao houve mudanca de regra de negocio.

---

## 3. Evidencia por arquivo/linha/comando (o que foi auditado)

**Ambiente (pre-flight)** — todos retornaram a raiz canonica:
```
pwd                         → /Users/macbookpro/Projetos/Credenciamento
git rev-parse --show-toplevel → /Users/macbookpro/Projetos/Credenciamento
git status -sb              → ## codex/v12-0-0206-planejamento...origin [ahead 2]
                             ?? auditoria/03_ondas/onda_38_2_35_.../
git worktree list           → unico worktree na raiz canonica (sem /tmp)
```

**Pergunta 1 — commit 945039d consolidou 0165 corretamente: SIM (com ressalva
de nomeacao).** `git show --stat 945039d` (23 arquivos) cobre o conjunto coerente:
HBN (readback/hearback/ERP 0165 + readback/hearback 0166 + relay), CHANGELOG,
tecnico/procedimento 0165, manual, guia, manifesto V3 e o espelho fonte↔import
(`src/vba/*` + `local-ai/vba_import/001-modulo/AAX|ABF|ABG|ABU`). Sem `[bypass]`
no titulo → passou os guards (scope-lock contra 0166, que lista todos esses paths
em `files_allowed`). Ressalva: MARGINAL-1.

**Pergunta 4 — contrato "relatorio de Pre-OS vencidas e informativo": CORRETO,
verificado na fonte (never delegate understanding).**
- `src/vba/Menu_Principal.frm` L3497-3621: `Private Sub PRE_OS_Vencidas_Click()`
  monta cabecalhos, filtra `AGUARDANDO_ACEITE` vencidas (`statusPre <> "AGUARDANDO_ACEITE" → ProximoPre`, L3553),
  define `PrintArea` e chama `PrintOut` (L3602-3604), e limpa a area (L3607/3615).
  **Nao** ha `ExpirarPreOS`/`RecusarPreOS`/`AvancarFila` no corpo.
- A unica chamada destrutiva proxima — `Call ExpirarPreOSSelecionada` (L3682) —
  pertence a **outra** subrotina, `BT_PREOS_EXPIRAR_Click` (L3680-3686),
  confirmada por delimitacao de `End Sub`/`Private Sub` via `awk`. O contrato esta
  certo e o teste estatico cerca exatamente o trecho 3497→3623.
- Teste presente: `src/vba/Teste_V2_Roteiros.bas` L1887
  (`REL_TELA_11_PREOS_VENCIDAS_IMPRESSAO_SEM_EXPIRAR`).
- ERP/gate humano: `0165-exec-...json` L43-49 → import `M=3|F=0|err=0|skip=0`,
  compile limpo, `TV2_20260608_161110` `OK=11|FALHA=0|MANUAL=0`; PDFs 072-078
  revisados (L50-79). CHANGELOG L8-23 e build label `App_Release.bas` L270
  (`b33ec4e+ONDA38.2.34-PREOS-VENCIDAS-RELATORIO`) coerentes.

**Pergunta 2 — protocolo HBN cumprido no fechamento/limpeza 0166: PARCIAL.**
Cumprido: readback 0166 com `human_status: confirmed` (L135-138) + hearback
(.json/.md em `.hbn/hearbacks/`), commit local criado, worktree limpo, sem
reset/revert/stash/push, escopo respeitado. **Nao cumprido: ERP 0166 ausente**
(FORTE-1) e relay nao refletido (FORTE-2).

**Pergunta 3 — ERP 0166 / relay / rastreabilidade / status real de handoff:**
ERP 0166 inexistente (FORTE-1); relay sem bloco 0166 e frontmatter estagnado
(FORTE-2). Rastreabilidade do commit OK (hashes batem); status real de handoff:
**0165 fechada e auditada; 0166 funcionalmente feita mas formalmente aberta por
falta de ERP**. Quem assume o bastao deve ler o corpo do relay, nao o frontmatter.

---

## 4. Checklist anti-vies (Cadencia D §12.4) — o que tentei refutar no meu proprio parecer

1. *Hipotese favoravel: "o ERP 0166 existe e eu nao achei".* Refutada por tres
   vias independentes: `test -f`, `ls .hbn/results/ | grep 0166`, e
   `git log --all -- <path>` (nunca existiu em historico). Nao e erro de busca.
2. *Hipotese contraria (auto-inflar severidade): "ERP ausente e BLOQUEADOR".*
   Refutada: 0166 e housekeeping git; a substancia (0165) esta validada e o commit
   passou guards. Rebaixei para FORTE — nao veta avanco, mas exige remediacao.
3. *Hipotese: "o relatorio talvez chame expiracao indiretamente".* Tentei refutar
   lendo a fonte e mapeando o `Call ExpirarPreOSSelecionada` (L3682); confirmei que
   pertence a `BT_PREOS_EXPIRAR_Click`, nao a `PRE_OS_Vencidas_Click`. Contrato
   correto — convergente com Antigravity §3.
4. *Hipotese: "o frontmatter do relay esta certo e eu li uma versao antiga".*
   Refutada: o frontmatter L7 vem do proprio `945039d` (relay foi +32 linhas nesse
   commit) e ainda diz "0165 permanece sem commit proprio" — estagnado no ato.
5. *Vies de papel (auditor que so quer achar culpa):* checei o lado positivo —
   readback/hearback/escopo/guards de 0166 estao corretos; reconheco o acerto e
   isolo o unico passo faltante (ERP), em vez de condenar a onda inteira.
6. *Vies de complementaridade (achar so o que o par nao achou):* reverifiquei os
   MARGINAIS comportamentais do Antigravity por amostragem antes de aceita-los, e
   acrescentei a calibracao "pre-existente vs introduzido por 0165" que muda a
   conclusao de fechamento (eles nao pesam no gate 0165/0166).

---

## 5. Proximas ondas sugeridas (propor, nao implementar)

### Onda A — Fechar 0166 (ERP) + higiene de relay  [PRE-REQUISITO do avanco]
- **Objetivo**: produzir `.hbn/results/0166-exec-onda-38-2-35-limpeza-worktree-pos-0165.json`
  registrando hash `945039d`, escopo conferido e worktree limpo; adicionar bloco
  GATE 0166 no relay e atualizar o frontmatter (`proxima-acao`, `ciclo-ativo`,
  `ultima-atualizacao`) para o estado real (0164/0165 fechadas, 0166 fechada).
- **Risco**: baixo (doc-only). Tensao galinha-ovo: ERP referencia `945039d`, logo
  vai em commit de follow-up — desenhar para isso.
- **Arquivos provaveis**: `.hbn/results/0166-...json` (novo), `.hbn/relay/INDEX.md`.
  Eventualmente `auditoria/03_ondas/onda_38_2_35.../0166_TECNICO.md` curto.
- **Gate humano**: hearback do readback de higiene; guards verde no Terminal do
  operador; commit local. Sem import/compile/TV2 (nao toca VBA).

### Onda B — Disponibilidade composta sob suspensao (UX de relatorio)
- **Objetivo**: quando empresa suspensa tiver OS em execucao/Pre-OS pendente,
  exibir estado composto (ex.: `SUSPENSA ATE ... | OS EM EXECUCAO`) em vez de
  ocultar o secundario. Endereca Antigravity §1.3/§6 e meu MARGINAL comportamental.
- **Risco**: medio — mexe em regra de leitura (`Rel_Rodizio_Status.bas`,
  `RRS_DisponibilidadeOperacionalEmpresa` L151-158) consumida por varios relatorios;
  exige teste V2 dirigido novo e regressao de `TV2_RunTelaRelatorios`.
- **Arquivos provaveis**: `src/vba/Rel_Rodizio_Status.bas`, `src/vba/Teste_V2_Roteiros.bas`,
  espelhos `local-ai/vba_import/001-modulo/`, manual/guia.
- **Gate humano**: readback+hearback; import V3; compile; TV2 dirigido; revisao de
  PDFs. Nao tocar `.frx`/forms.

### Onda C — Defeito visual C16 (espacamento distribuido nos impressos)
- **Objetivo**: corrigir o alinhamento "Distribuido/Justificado" da celula de
  aviso operacional (`C16`/`C16:N16`) em `EMITE_PREOS`/`EMITE_OS`/`AVALIA_SERV`
  para que o aviso imprima legivel. Antigravity §1.1/§6.
- **Risco**: medio — e formatacao de template (workbook), territorio onde a memoria
  do projeto registra que bordas/formatos sao reaplicados por VBA em runtime
  (`Preencher`/`Preencher_EscreverAvisoOperacional` L1650-1660). Decidir se a
  correcao e code-only (reaplicar `HorizontalAlignment = xlLeft`) ou de template.
- **Arquivos provaveis**: `src/vba/Preencher.bas` + teste V2 de formato; possivel
  ajuste de template manual sob gate humano.
- **Gate humano**: readback+hearback; import/compile/TV2; **conferencia visual de
  PDF obrigatoria** (defeito so detectavel no impresso).

### Onda D — Checkpoint forte (VCR) antes do freeze 206
- **Objetivo**: rodar VCR/Sexteto completo apos A-C, consolidando a bateria
  tela-a-tela; e o gate que as ondas recentes vem adiando ("reservar VCR para
  checkpoint forte").
- **Risco**: baixo tecnico, alto custo de tempo (>1h). E pre-condicao de freeze.
- **Gate humano**: VCR APROVADO + evidencia CSV; decisao de freeze 206 e do Mauricio.

> Ordem recomendada: **A (obrigatoria) → C → B → D**. C antes de B porque C e
> isolado e de baixa logica; B mexe em regra compartilhada e merece o relatorio ja
> visualmente limpo. As lacunas de cobertura automatizada apontadas pelo Antigravity
> (§5: impressora ausente, planilha protegida com senha nao-padrao, volume massivo)
> entram como itens de roteiro de teste manual da Onda D, nao como ondas proprias.

---

## 6. Handoff para Codex implementador

- **Estado real**: 0165 FECHADA e auditada (contrato informativo correto, gate
  humano verde). 0166 funcionalmente concluida (commit `945039d`, worktree limpo)
  mas **formalmente ABERTA**: falta o ERP e o relay nao reflete 0166.
- **Bastao**: segue com Codex (implementador V206). Auditoria cruzada desta onda =
  Claude Opus 4.8 (este parecer, foco protocolo) + Antigravity Gemini 3.5 (foco
  comportamento/PDF). Ambos: **VETO_AVANCO NAO**.
- **Acao imediata e unica antes de qualquer feature**: executar **Onda A** —
  abrir readback de higiene, gerar ERP 0166 com hash `945039d`, sanear relay
  (bloco 0166 + frontmatter), em commit de follow-up. Doc-only; sem VBA.
- **Anti-vies de bastao (§12.4)**: nao me auto-indico como implementador (sou
  auditor; nao implemento — regra Cadencia D §1). Evidencia objetiva para Codex
  seguir: continuidade de contexto da linha 0153-0166 e papel de implementador V206
  ja estabelecido. Mauricio arbitra.
- **Firewall 0022**: a Onda A e doc-only mas a escrita/commit continua humano-aplicada
  e hearback-gated; nenhum passo desta auditoria aplicou nada no workbook nem
  commitou. Push dos 2 commits locais (incl. 1 via bypass) permanece decisao humana.
- **Nao tocar** (reafirmado): `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas`,
  `ThisWorkbook`, `.frx`/forms; nao rodar VCR fora da Onda D.

---

*Auditoria conduzida sem editar codigo, sem git de escrita, sem VCR. Unico
artefato produzido: este parecer.*
