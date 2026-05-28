---
titulo: Opus 4.7 — REAUDITORIA cruzada GATE-A2 (AT-2 diagnóstico F-NEW5) Onda 38.2.3
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
auditor: claude-opus-4-7 (chat novo, contexto fresco — 2ª passagem Opus)
gate: GATE-A2
alvo: proposta 0016 (Codex) + CSV DIAG_FNEW5_20260527_200546 + CSV TesteV2_STRIKES_E2E_Falhas_TV2_20260527_202518
template: PROMPT_ARQUITETO §12.A
relaciona-se: 0017 (Opus 1ª passagem) + 0018 (Antigravity) — esta NÃO os substitui; soma 3 FORTES não capturados
---

# Reauditoria GATE-A2 — AT-2 diagnóstico F-NEW5 (Onda 38.2.3)

> 2ª passagem Opus em contexto fresco, Cadência D Estendida. Codex diagnosticou
> (proposta `0016`); este chat audita sem implementar. **Esta reauditoria não
> revoga 0017 nem 0018** — converge no veredito central (aprovar GATE-A2,
> residual = F-NEW6) e **acrescenta 3 FORTES** que as duas auditorias anteriores
> não capturaram, mais um ajuste de severidade. Toda conclusão foi reproduzida
> independentemente por leitura de fonte (`Svc_PreOS.bas`, `Repo_PreOS.bas`,
> `Credencia_Empresa.frm`, `Teste_V2_Roteiros.bas`, `Util_Planilha.bas`,
> `Preencher.bas`, `Const_Colunas.bas`) cruzada com os dois CSVs.

## 1. Veredito

**APROVAR o GATE-A2 e AUTORIZAR a AT-3 — sem BLOQUEADOR novo, com 3 FORTES e 3 MARGINAIS.**

O diagnóstico do Codex está **tecnicamente correto e empiricamente sustentado**:

- **F-NEW5 (status stale em `Credencia_Empresa`) não reproduziu neste fluxo** —
  confirmado lendo a instrumentação, não só o CSV. O `STATUS_CRED=ATIVO` é
  estado **persistido na planilha**, relido após `ClassificaCredenciadoOrdem` +
  `AtualizarListaEmpresaMenuAtual`, exatamente onde a hipótese de staleness
  apontava.
- **A falha residual das 11 linhas é F-NEW6**, com causa-raiz no **único ponto
  de gravação vivo**: `Svc_PreOS.EmitirPreOS:195` grava `EMP_ID` em célula
  `General` sem `NumberFormat="@"`; o Excel coage `"001"`→`1`;
  `Repo_PreOS.BuscarPorId:83` relê `CStr(1)="1"`; a asserção estrita falha. Não é
  "dupla seleção" — é coerção textual.

Nenhum FORTE bloqueia **começar** a AT-3 (fix de código, não roda import).
Permanece o **BLOQ-1 herdado de 0014** — `AAI-Credencia_Empresa.code-only.txt`
stale — que veta o **GATE-A4 (import)**, não a AT-3. (0017/0018 afirmam que o
Codex já o resolveu no commit `143edf9`; **não pude confirmar** com o material
entregue a este chat — registrar como pendência de verificação no GATE-A4.)

## 2. BLOQUEADORES (veto)

**Nenhum BLOQUEADOR novo introduzido por este gate.**

### BLOQ-1 (carry-forward de 0014) — code-only de `Credencia_Empresa` veta GATE-A4, não AT-3

A auditoria GATE-A1 (`0014` §2) registrou o `.code-only.txt` de
`Credencia_Empresa` quebrado pelo mesmo bug do P0-1, exigindo
`--apply --only Credencia_Empresa.frm` + re-auditoria antes do import. Aplica-se
ao **GATE-A4**, não à AT-3. Se de fato já resolvido (`143edf9`), exige
re-auditoria do artefato regenerado antes do GATE-A4 — não tomar como concluído
sem evidência byte-a-byte.

## 3. FORTES (incorporar ou justificar por escrito)

### FORTE-1 — A AT-3 deve ser **write-side primária**; o normalizador em `BuscarPorId` cobre só 1 de ~7 leitores

A proposta 0016 §4 (e os vereditos 0017/0018) tratam write-side e read-side da
AT-3 como pares simétricos. Mapeei os leitores de `COL_PREOS_EMP_ID` (grep em
`src/vba`):

| Leitor | Leitura | Tolera "1"? |
|---|---|---|
| `Repo_PreOS.BuscarPorId:83` | `CStr` → (normalizador proposto) | sim, se normalizado |
| `Repo_PreOS.TemPreOSPendenteNaAtividade:142` | `IdsIguais` | sim (já tolera) |
| `Svc_PreOS.LerPreOS:426` | `CStr` cru | **mostra "1"** |
| `Svc_OS.bas:439` | `CStr` cru | **mostra "1"** |
| `Menu_Principal.frm:1927/2865/3205` | `SafeListVal` (sem pad) | **exibe "1"** na UI |
| `Preencher.bas:935/1614` | `SafeListVal` | **mostra "1"** |

O normalizador em `BuscarPorId` conserta **apenas a 1ª linha**. A correção que
protege **todos** os leitores e o dado-em-repouso é a **write-side**
(`NumberFormat="@"` antes de `EmitirPreOS:195`). Recomendo: write-side como fix
**primário** (causa-raiz, ponto único), normalizador como defesa-em-profundidade
— **não** como o conserto principal. Risco se invertido: teste verde, sintoma
visível persistindo na UI.

### FORTE-2 — `Repo_PreOS.Inserir:38` é gêmeo dormente do mesmo bug

`Repo_PreOS.Inserir` (L38) tem a gravação idêntica não protegida
(`ws.Cells(linha, COL_PREOS_EMP_ID).Value = p.EMP_ID` sem `NumberFormat="@"`) e
**sem chamadores** em `src/vba` hoje (grep por `.Inserir` retornou só a
definição). Cópia latente que reintroduz F-NEW6 quando alguém religar o caminho
— espírito da **L44** (knowledge 0020). Incorporar `NumberFormat="@"` em
`Inserir:38` no mesmo passe da AT-3, **ou** remover a função se confirmada morta,
com justificativa escrita.

### FORTE-3 — Decidir explicitamente o destino das linhas PRE_OS já persistidas como `1`

Linhas de PRE_OS gravadas antes do fix guardam `1` na célula. Como **todo
matching usa `IdsIguais`** (`Util_Planilha:651` e cópias por form — caminho
numérico `CLng(Val)` trata `1==001`), essas linhas **continuam casando**
corretamente no rodízio, na pendência e na conversão em OS. O impacto fica em
**leitores crus**: `Svc_OS:439`, `LerPreOS`, e a exibição de UI via
`SafeListVal`, que mostram `1`. A AT-3 deve declarar por escrito: (a)
backfill/reformatação one-time de `PRE_OS!D`, ou (b) aceite consciente do legado
por confiar no `IdsIguais`. Sem isso, o GATE-VAL-TELA-A-TELA pode reabrir o tema
como "bug de exibição".

## 4. MARGINAIS (nice-to-have)

- **MARG-1 — Rótulo da asserção enganoso.** `DIAG_PREOS_INTEGRITY` diz "Detecta
  dupla seleção divergente entre observador e EmitirPreOS interno"
  (`Teste_V2_Roteiros.bas:3713`). Não há dupla seleção: observador e
  `EmitirPreOS` interno escolhem `001` via o mesmo `SelecionarEmpresa`; a
  divergência é a coerção `001→1` na gravação. Corrigir para "integridade
  textual de EMP_ID em PRE_OS". A asserção usar `=` cru (não `IdsIguais`) é
  **correto por design** — é sonda de integridade, deve ser estrita.
- **MARG-2 — Diagnóstico F-NEW5 é n=1, caso mais simples.** CSV:
  `ADICIONADOS=1; IGNORADOS=0; TOTAL_SERV=1; LIST_INDEX=4`. Suficiente para "não
  reproduziu **neste fluxo**", insuficiente para encerrar F-NEW5 como classe.
  Vigiar multi-serviço, `IGNORADOS>0` e re-sort/reload com lista maior antes do
  GATE-USO-PROLONGADO.
- **MARG-3 — Ajuste de severidade vs 0017/0018: a coerção em
  `CREDENCIADOS.ATIV_ID` é MARGINAL, não FORTE.** As duas auditorias anteriores
  elevaram a FORTE-1 o achado `ATIV_ID_VAL=1331; Double; General` do CSV.
  Concordo que é a mesma classe F-NEW6, mas **classifico como MARGINAL** neste
  gate porque o composto `COD_ATIV_SERV=1331002` está protegido (`String/@`) e é
  a **chave usada no matching**, e a atividade em jogo não tem zero à esquerda.
  É um item de varredura sistêmica futura, não um FORTE que condicione a AT-3.
  (Divergência de severidade honesta entre auditores; Mauricio arbitra.)

## 5. Convergências com o trabalho auditado (todas verificadas)

1. **F-NEW5 não reproduziu — confirmado na fonte, não só no CSV.**
   `Credencia_Empresa.frm:188` grava `COL_CRED_STATUS = STATUS_CRED_ATIVO`; a
   captura (L217-220, fase `POS_RELOAD_PRE_VALIDACAO`) ocorre **após**
   `ClassificaCredenciadoOrdem`+`AtualizarListaEmpresaMenuAtual` (L215-216) e
   **antes** de `ValidarPersistenciaCredenciamento` (L223). O registrador
   re-localiza a linha varrendo a planilha (`DIAG_FNEW5_LocalizarCred`,
   L433-449) e lê a célula direto (`DIAG_FNEW5_CamposCelula` →
   `ws.Cells(...).Value`, L459) — **não** é eco de struct em memória.
2. **A falha residual é F-NEW6, não F-NEW5** — outra coluna
   (`COL_PREOS_EMP_ID`), outro módulo (`Svc_PreOS`/`Repo_PreOS`), sintoma de
   coerção textual desconexo do status de credenciamento.
3. **Causa-raiz exatamente onde o Codex aponta** — `EmitirPreOS:195` (caminho
   vivo, chamado pelo teste em `Teste_V2_Roteiros.bas:3696`) + `BuscarPorId:83`.
   As 11 linhas idênticas do CSV RVS são a mesma sonda disparando 11×.
4. **Observação de UI marginal procede** — lista branca momentânea em
   `Cadastro_Servico` é GATE-USO-PROLONGADO, não bloqueia GATE-A2.

## 6. Divergências reais

- **Ênfase, não mérito (vs 0016/0017/0018):** divirjo na **hierarquia** do fix —
  write-side em `EmitirPreOS:195` é primário (protege ~7 leitores +
  dado-em-repouso); normalizador em `BuscarPorId` cobre 1 leitor (FORTE-1).
- **Escopo:** 0016 não cita `Repo_PreOS.Inserir:38` nem o legado (fora do recorte
  do AT-2, mas deve entrar no AT-3 — FORTE-2/3).
- **Severidade (vs 0017/0018):** `CREDENCIADOS.ATIV_ID` é MARGINAL para mim, não
  FORTE (MARG-3).
- **Sem divergência** na conclusão central: F-NEW5 não reproduziu; residual =
  F-NEW6; aprovar GATE-A2; autorizar AT-3.

## 7. Riscos não cobertos

1. **(principal)** Se a AT-3 priorizar o normalizador de leitura, leitores crus
   (`Svc_OS:439`, UI via `SafeListVal`) **seguem exibindo `1`** mesmo com o teste
   verde (FORTE-1).
2. `Repo_PreOS.Inserir:38` religado no futuro reintroduz F-NEW6 silenciosamente
   (FORTE-2 / L44).
3. F-NEW5 declarado encerrado como **classe** a partir de n=1 (MARG-2).
4. **L44 reforçada (knowledge 0020):** o "diff cosmético" `001` vs `1` só foi
   corretamente classificado inspecionando o **pipeline de gravação/leitura**
   (EmitirPreOS→célula→BuscarPorId) e o conjunto de leitores, não a linha isolada
   do CSV. Recomendo registrar F-NEW6/PRE_OS como evidência empírica adicional de
   L44.

## 8. Próxima ação

- **Codex pode prosseguir à AT-3** (não bloqueada), com 3 ajustes de recorte:
  (a) **write-side primário** `NumberFormat="@"` em `EmitirPreOS:195` (FORTE-1);
  (b) tratar **`Repo_PreOS.Inserir:38`** no mesmo passe — fix ou remoção
  justificada (FORTE-2); (c) **decidir e documentar** o destino das linhas
  PRE_OS legadas (FORTE-3). Normalizador em `BuscarPorId` = defesa-em-profundidade.
- **Antes do GATE-A4 (import):** confirmar/refazer o resync de
  `AAI-Credencia_Empresa.code-only.txt` (BLOQ-1 de 0014) + re-auditoria.
- **MARGINAIS:** corrigir o rótulo de `DIAG_PREOS_INTEGRITY` (MARG-1); manter
  F-NEW5 sob vigilância multi-serviço (MARG-2); agendar varredura de IDs em
  `General` incl. `CREDENCIADOS.ATIV_ID` (MARG-3) — nenhum bloqueia a AT-3.
- **Checklist anti-viés §12.4:** não se aplica — não há recomendação de passagem
  de bastão neste gate. Permaneço auditor; Codex segue implementador; sem
  auto-indicação.

---
Auditor: Claude Opus 4.7 · contexto fresco (2ª passagem) · GATE-A2 · alvo
proposta `0016` + CSVs DIAG_FNEW5 / STRIKES_E2E
