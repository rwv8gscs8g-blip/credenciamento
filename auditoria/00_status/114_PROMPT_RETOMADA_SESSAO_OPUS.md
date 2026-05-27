# Prompt de retomada — sessão Opus 4.7 sucessora (Onda 38.2.3)

> Copie e cole o bloco abaixo no primeiro turno da próxima sessão Opus.

---

✅ HBN ACTIVE

Você é Claude Opus 4.7 assumindo continuidade do bastão V12.0.0206 do
Sistema de Credenciamento. A sessão anterior (2026-05-26 17:30 → 2026-05-27
04:30 BRT, ~11h, ~95% contexto) entregou **ONDA38.2.2 PARCIAL** com 5
hotfixes consecutivos (`c9bcd41` → `f855d0b` → `88b347b` → `854c392` →
`255d3bc` → `a51b191`) e produziu 5 lições candidatas L33-L38 +
2 lições novas L39 (nomenclatura sem "FREEZE" até homologação) + L40
(meta-validação dos testes obrigatória).

**Diretivas Mauricio vigentes (2026-05-27 04:30 BRT):**

1. NÃO faremos freeze V206 nesta onda. Tirar "FREEZE" do nome até
   homologação. Convenção: build label `<HEAD>+ONDA<N>` ou
   `<HEAD>+ONDA<N>.fix<NN>`.
2. Ondas 38.2.3, 38.2.4, 38.2.5 (e até quantas necessárias) até validar
   tela-a-tela completo.
3. Meta-validação dos testes obrigatória — testes devem cobrir fluxos
   NOVOS, não apenas fixtures pré-validadas (RVS verde é necessário mas
   insuficiente).
4. V207 ADIADA até V206 homologada com suite E2E completa.

Bastão **permanece com você** (Opus 4.7). Próxima onda = **38.2.3 focada
em F-NEW5 (BUG CRÍTICO rodízio) + F-FILTRO-1 (OS/Aval) + teste E2E novo**.

**Raiz canônica**: `/Users/macbookpro/Projetos/Credenciamento`
**Branch**: `codex/v12-0-0206-planejamento`
**HEAD**: `927ea58` (consolidação ONDA38.2.2 + handoff fim-sessão)
**Anchor V206 funcional**: `ee75b30` + RVS Trio APROVADO `VR_20260526_102200`
**Anchor de rollback ONDA38.2.2**: `179bac5`

## Leitura obrigatória inicial (na ordem)

1. `.hbn/relay/INDEX.md` — estado vivo (já atualizado para "EM VALIDAÇÃO ITERATIVA")
2. `.hbn/messages/20260527-0430-handoff-fim-sessao-opus.md` — handoff completo (LER §2 findings + §3 diretivas + §4 próxima ação)
3. `auditoria/03_ondas/onda_38_2_2/38_2_2_TECNICO.md` — especialmente **§9 timeline 5 hotfixes**, **§10 findings abertos** (F-NEW5 crítico + F-FILTRO-1..4), **§11 roadmap até freeze**
4. `.hbn/protocol-evolutions/20260526-1810-onda-38-2-2-proposals.md` — L33-L40 candidatas (decidir Promover/Adiar/Rejeitar para cada)
5. `src/vba/Credencia_Empresa.frm` linhas 74-235 — bloco `CR_Credenciar_Click` (onde STATUS_CRED é gravado e suspeitamos ser sobrescrito)
6. Knowledge `.hbn/knowledge/0014` + `0015` + `0016` + `0017`
7. `AGENTS.md` + `CLAUDE.md`

## Comando único de verificação ao retomar

```bash
cd /Users/macbookpro/Projetos/Credenciamento && \
git log --oneline -10 && \
git status -s && \
bash scripts/hbn-guards/hbn-guards-runner.sh
```

**Esperado**:
- HEAD em `927ea58`
- Working tree LIMPO (nenhum arquivo modificado)
- Guards 5/5 verde
- `git log -10` mostra: 927ea58 → 38f1b0d → a51b191 → 36fb856 → 255d3bc → 7bfd821 → 854c392 → 88b347b → f855d0b → c9bcd41 → 179bac5

## Primeira ação (após leitura obrigatória)

**Investigar F-NEW5 (bug crítico do rodízio)**:

1. **Validação preliminar com Mauricio** — pedir para ele rodar no Imediato:

```vba
? Sheets("CREDENCIADOS").Cells(<linha_emp5_em_algodao>, COL_CRED_STATUS).Value
' Esperado: "ATIVO"
' Provavelmente vazio (sintoma do bug)
```

(Para encontrar a linha exata, primeiro rodar:
`? Sheets("CREDENCIADOS").Cells(Rows.Count, 1).End(xlUp).Row` e iterar
pelas últimas linhas com `?Sheets("CREDENCIADOS").Cells(N, COL_CRED_EMP_ID).Value`
para localizar empresa 5 em CULTIVO DE ALGODÃO HERBÁCEO.)

2. **Grep + leitura de código**:

```bash
grep -nE "STATUS_CRED|COL_CRED_STATUS" src/vba/*.bas src/vba/*.frm
grep -nE "ClassificaCredenciadoOrdem" src/vba/*.bas src/vba/*.frm
```

Localizar TODOS os pontos que escrevem em `COL_CRED_STATUS`. Suspeito:
algum sub que roda APÓS o loop em `Credencia_Empresa.CR_Credenciar_Click:189`
está sobrescrevendo (provavelmente `ClassificaCredenciadoOrdem` ou similar).

3. **Aplicar L34** (pre-flight signatures) **+ L38** (enumerar paths)
   ANTES do primeiro Edit — não confiar em hipótese; verificar código real.

4. **Abrir readback** `0112-rb-onda-38-2-3-fix-rodizio-filtros-os-aval`
   com escopo definido após a investigação. Aguardar hearback Mauricio
   antes de qualquer Edit.

## Escopo proposto para Onda 38.2.3 (sugerir no readback)

- **AT-1 38.2.3**: fix F-NEW5 (bug crítico rodízio — STATUS_CRED sobrescrito)
- **AT-2 38.2.3**: F-FILTRO-1 (adicionar `Optional filtro` em
  `PreencherPreencheOS` + `PreencherAvaliarOS` + implementação de filtro)
- **AT-3 38.2.3**: teste E2E novo (cenário cobrindo cadastro atividade
  NOVA → credenciar empresa NOVA → emitir Pre-OS → validar empresa
  selecionada pelo rodízio). Padrão L40: prevenir regressão "trilha fixture".

Onda 38.2.4 (próxima após 38.2.3) cobre F-FILTRO-2/3/4. Onda 38.2.5 é
dedicada à meta-validação dos testes antes do freeze.

## Restrições inalteradas

- ✅ HBN ACTIVE
- Bastão com Opus 4.7 até homologação V206
- "FREEZE" só após GATE-FREEZE aprovado em hearback explícito
- Tabus permanecem (Svc_*, Mod_Types, Importador_V3, Auto_Open, Repos
  não-Empresa, 10 forms blindados, .frx direto)
- Importação operacional somente via `ImportarPacoteV3_Delta`
- Knowledge 0016 vigente: deixar `App_Release.bas` no estado atual; V3
  fará BUMP no import

## Quando atingir ~50% de contexto

Aplicar `knowledge/0014` + `knowledge/0017` + §7 Passo 5 PROMPT_ARQUITETO
v1.3 — produzir 3 artefatos antes de assinar 🔵:

1. **Handoff operacional**: `.hbn/messages/AAAAMMDD-HHmm-handoff-fim-sessao-opus.md`
2. **Prompt de retomada**: `auditoria/00_status/115_PROMPT_RETOMADA_SESSAO_OPUS.md` (sucessor do 114)
3. **Proposta evolução protocolo**: `.hbn/protocol-evolutions/AAAAMMDD-HHmm-onda-38-2-3-proposals.md`

Orçamento 50/30/20 conforme knowledge 0017.

---PROMPT FIM---

## Referências

- Handoff origem: [`.hbn/messages/20260527-0430-handoff-fim-sessao-opus.md`](../../.hbn/messages/20260527-0430-handoff-fim-sessao-opus.md)
- TECNICO ONDA38.2.2: [`auditoria/03_ondas/onda_38_2_2/38_2_2_TECNICO.md`](../03_ondas/onda_38_2_2/38_2_2_TECNICO.md)
- Protocol-evolutions L33-L40: [`.hbn/protocol-evolutions/20260526-1810-onda-38-2-2-proposals.md`](../../.hbn/protocol-evolutions/20260526-1810-onda-38-2-2-proposals.md)
- Relay vivo: [`.hbn/relay/INDEX.md`](../../.hbn/relay/INDEX.md)
- Predecessor (113): [`113_PROMPT_RETOMADA_SESSAO_OPUS.md`](113_PROMPT_RETOMADA_SESSAO_OPUS.md)
