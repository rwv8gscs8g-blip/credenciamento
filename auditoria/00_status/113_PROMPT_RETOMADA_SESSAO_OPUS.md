# Prompt de retomada — sessão Opus 4.7 sucessora (continuação onda 38.2.2 V206 puro freeze)

> Copie e cole o bloco abaixo no primeiro turno da próxima sessão Opus.

---

✅ HBN ACTIVE

Você é Claude Opus 4.7 assumindo continuidade do bastão V12.0.0206 do
Sistema de Credenciamento. A sessão anterior (2026-05-26 ~16:00 → ~17:30,
~1h30) consolidou a 2ª rodada de auditoria cruzada V207 em
[`112_ANALISE_AUDITORIA_CRUZADA_V207_2A_RODADA.md`](112_ANALISE_AUDITORIA_CRUZADA_V207_2A_RODADA.md),
recebeu de Mauricio decisão **Alternativa II-bis confirmada** (V207
commitment full V207.0-V207.8 sem cláusula de escape), pushou commit
`179bac5`, abriu readback `0111-onda-38-2-2-v206-puro-filtros-envelopamento-quickwins-freeze`
**(human_status: confirmed)** e executou PARCIALMENTE:

- **Etapa A 100%** (3 .bas no working tree): Util_Planilha + Util_Sanear_Contadores + Repo_Empresa
- **Etapa B 20%** (1 sub do Menu_Principal): bloco entidade `Sub C_Cadastrar_Click` COMPLETO em estado consistente
- **FALTA**: bloco empresa-alt + 7 handlers filtros + Preencher.bas + Credencia_Empresa.frm + Cadastro_Servico.frm + manifesto + 38_2_2_TECNICO.md + INDEX + CHANGELOG + sync + commit único + gates humanos + freeze

Bastão **permanece com você** (Opus 4.7). Readback 0111 ATIVO, NÃO reabrir.

**Raiz canônica**: `/Users/macbookpro/Projetos/Credenciamento`
**Branch**: `codex/v12-0-0206-planejamento` (sincronizada com origin)
**HEAD**: `179bac5`
**Anchor V206 funcional**: `ee75b30` + RVS Trio APROVADO `VR_20260526_102200`

## Leitura obrigatória inicial (na ordem)

1. `.hbn/relay/INDEX.md` — estado vivo (pré-handoff; ainda aponta para "🔵 PENDING HEARBACK MAURICIO" — já resolvido em chat anterior, INDEX será atualizado no commit final)
2. `.hbn/messages/20260526-1730-handoff-fim-sessao-opus.md` — handoff completo (LER COMPLETO, especialmente §6 + §7 + §11)
3. `.hbn/readbacks/0111-onda-38-2-2-v206-puro-filtros-envelopamento-quickwins-freeze.json` — readback CONFIRMED, 5 alvos atômicos (AT-1..AT-5), 10 gates humanos, ordem_de_execucao 16 passos
4. `auditoria/00_status/112_ANALISE_AUDITORIA_CRUZADA_V207_2A_RODADA.md` — contexto V207 (Alternativa II-bis confirmada)
5. `auditoria/03_ondas/onda_38_2_filtros_menu_principal/38_2_TECNICO.md` — mapeamento dos 7 TextBox (linhas 27-35) + cronograma tela-a-tela (linha 79)
6. `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` capítulos **M9 (688), L22 (931), L23 (978), L24 (1012), M15 (1045), M16 (1072), M17 (1103)** — releitura OBRIGATÓRIA antes de tocar Credencia_Empresa.frm e Cadastro_Servico.frm
7. `.hbn/knowledge/0014` + `0015` + `0016` + `0017`
8. `AGENTS.md` + `CLAUDE.md`

## Comando único de verificação ao retomar

```bash
cd /Users/macbookpro/Projetos/Credenciamento && \
git log --oneline -5 && \
git status -s && \
bash scripts/hbn-guards/hbn-guards-runner.sh
```

**Esperado**:
- HEAD em `179bac5`
- Working tree:
  - ` M src/vba/Menu_Principal.frm` (bloco entidade B1+B4 COMPLETO)
  - ` M src/vba/Repo_Empresa.bas` (A3 completo)
  - ` M src/vba/Util_Planilha.bas` (A1 completo)
  - ` M src/vba/Util_Sanear_Contadores.bas` (A2 completo)
  - ` M local-ai/vba_import/001-modulo/AAX-App_Release.bas` (knowledge 0016)
  - `?? .hbn/messages/20260526-1730-handoff-fim-sessao-opus.md`
  - `?? auditoria/00_status/113_PROMPT_RETOMADA_SESSAO_OPUS.md`
  - `?? auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260526_153113.csv`

**Se guards reprovam** (provável — scope.files_allowed do 0111 não inclui `.hbn/messages/**` nem `auditoria/00_status/113_*`):

PRIMEIRO Edit no readback 0111 antes de qualquer outra ação:

```json
// adicionar em scope.files_allowed:
".hbn/messages/20260526-1730-handoff-fim-sessao-opus.md",
"auditoria/00_status/113_PROMPT_RETOMADA_SESSAO_OPUS.md",
".hbn/protocol-evolutions/**"
```

Re-rodar guards — 5/5 verdes esperados.

## Sequência de execução (continuação do readback 0111)

### Imediato (1-2 turnos)

1. **B4-empresa-alt**: Editar `Sub M_Cadastrar_Empresa_Click` em Menu_Principal.frm (linhas 2181-2298). Aplicar **MESMO PADRÃO** do bloco entidade já entregue (referência: linhas 1592-~1693). Padrão:
   - Adicionar `Dim estadoExcel As TEstadoExcel` + `Dim blocoRapidoIniciado As Boolean` aos Dims
   - `blocoRapidoIniciado = False` no início
   - `estadoExcel = Util_IniciarBlocoRapido()` + `blocoRapidoIniciado = True` LOGO APÓS as validações iniciais (após `MsgBox "Deseja realmente continuar..."` na linha ~2230) e ANTES de `PrepararAbaParaEscrita`
   - `Util_FinalizarBlocoRapido estadoExcel : blocoRapidoIniciado = False` antes de cada `Exit Sub` que ocorrer APÓS Iniciar (Exit Sub do PrepararAbaParaEscrita + Exit Sub final)
   - `.NumberFormat = "@"` na coluna A ANTES de `Cells(linhaNovaEmp, COL_EMP_ID).Value = novoID` (linha 2246) — AT-3 F-NEW3 sistemático
   - `If blocoRapidoIniciado Then Util_FinalizarBlocoRapido estadoExcel` no handler `erro_carregamento` (linha 2285+)

2. **B2-filtros**: Editar Menu_Principal.frm adicionando 7 handlers estáticos:
   ```vba
   Private Sub TextBox16_Change()    ' Cadastro de Entidades
       Preencher.Preencher_FiltrarPorBoxEstatico "entidade", CStr(TextBox16.Text)
   End Sub
   Private Sub TextBox17_Change()    ' Cadastro de Empresas
       Preencher.Preencher_FiltrarPorBoxEstatico "empresa", CStr(TextBox17.Text)
   End Sub
   ' ... 18: atrib_servico, 19: os, 20: aval, 21: cad_servico, 22: atrib_empresa
   ```
   Manter handlers dinâmicos `mTxtFiltro*_Change` como FALLBACK (não remover; é débito V207 conforme 38_2_TECNICO.md §70-78). Cuidado com double-call: padrão da Onda 38.2 §48 — evitar double-call quando mTxtFiltro já vinculado.

3. **B3-Preencher**: Adicionar em `src/vba/Preencher.bas`:
   ```vba
   Public Sub Preencher_FiltrarPorBoxEstatico(ByVal nomeContexto As String, ByVal termo As String)
       Select Case LCase$(Trim$(nomeContexto))
           Case "entidade":      Call PreenchimentoEntidade(termo)      ' ou similar
           Case "empresa":       Call PreenchimentoEmpresa(termo)
           Case "atrib_servico": Call PreenchimentoCRServico(termo)
           Case "os":            Call PreencherPreencheOS(termo)
           Case "aval":          Call PreencherAvaliarOS(termo)
           Case "cad_servico":   Call PreenchimentoServico(termo)
           Case "atrib_empresa": Call PreenchimentoCREmpresa(termo)
       End Select
   End Sub
   ```
   Confirmar assinaturas exatas de `Preenchimento*` por grep antes de editar (alguns recebem `Optional filtro` + alguns são `Public` outros `Private`).

### Curto prazo (3-5 turnos)

4. **B5-Credencia_Empresa.frm**: Releitura PHAGOCYTOSIS (especialmente L22+L24+M17) + ler bloco de cadastrar credenciamento ~linha 153 + aplicar mesmo padrão Dim+IniciarBlocoRapido+NumberFormat+Finalizar.

5. **B6-Cadastro_Servico.frm**: Releitura PHAGOCYTOSIS + ler 2 blocos (servico ~linha 112 + atividade ~linha 143) + aplicar padrão em AMBOS, **cuidado com Worksheet correto** (SHEET_CAD_SERV vs SHEET_ATIVIDADES) para o NumberFormat.

6. **B7**: Confirmar `src/vba/App_Release.bas` INALTERADO (knowledge 0016).

### Finalização (5-8 turnos)

7. Rodar `local-ai/scripts/publicar_vba_import_v2.sh --apply` (sync src/vba → vba_import; AAX volta para label antigo; 4 .bas + 3 .frm + .frx delta gerados)

8. Rodar `--check` (shasum match)

9. Criar `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-2-2-V206-FREEZE.txt` com 7 entradas M (4 .bas + 3 .frm) + 1 BUMP AAX

10. Atualizar `local-ai/vba_import/000-MAPA-PREFIXOS.txt` se algum prefixo novo

11. Criar `auditoria/03_ondas/onda_38_2_2_v206_freeze/38_2_2_TECNICO.md` (template em `auditoria/03_ondas/onda_38_2_1_ar1_fix2_perf/38_2_1_AR1_FIX2_PERF_TECNICO.md`)

12. Atualizar `.hbn/relay/INDEX.md` (cabeçalho proprietario-bastao + ciclo-ativo + proxima-acao + bloco da onda 38.2.2 ENTREGUE; **e** finalizar bloco "🔵 PENDING HEARBACK" anterior marcando Alternativa II-bis como decidida)

13. Atualizar `CHANGELOG.md` com bloco V12.0.0206 completo

14. Rodar guards 5/5 verde

15. Commit ÚNICO incluindo TUDO (etapa A + B + manifesto + tecnico + INDEX + CHANGELOG + handoff + 113 + protocol-evolutions se houver) — mensagem sugerida: `feat(v206-freeze): ONDA38.2.2 — quick wins + filtros nativos + envelopamento .frm + F-NEW3 (handoff fechado)`

16. **Apresentar a Mauricio para gates humanos pós-commit** (sequência 10 gates do readback 0111)

### Gates humanos (1-N turnos com Mauricio)

GATE-IMPORT → GATE-COMPILE → GATE-AT-1 → GATE-AT-2 → GATE-AT-3 → GATE-AT-4 → GATE-AT-5 → GATE-RVS → **GATE-VAL-TELA-A-TELA** (cronograma aprovado, passagem formal pelos 13 forms) → GATE-FREEZE

### Freeze V206 (1 turno)

17. Após TODOS os gates verdes (ou findings menores aceitos por Mauricio): tag `v12.0.0206` (anotada) + ERP `.hbn/results/0111-exec-onda-38-2-2-v206-freeze.json` + atualização final relay/INDEX (🟢 V12.0.0206 FREEZE + ancora-estavel-atual atualizada) + push origin tag (sob aprovação)

## Restrições inalteradas

- ✅ HBN ACTIVE
- Bastão com Claude Opus 4.7 até freeze V12.0.0206
- Sequência: edits restantes → sync → manifesto → docs → guards → commit ÚNICO → gates humanos → freeze
- Atomicidade do delta da onda 38.2.2 = **1 commit primário** abrangendo TUDO (sem WIP partials)
- Tabus V206 permanecem (Svc_*, Mod_Types, Importador_V3, Auto_Open, Repos não-Empresa, 10 forms blindados, .frx direto)
- Importação operacional somente via `ImportarPacoteV3_Delta`
- Knowledge 0016 vigente: deixar App_Release.bas no estado da onda anterior; V3 fará BUMP

## Quando atingir ~50% de contexto

Aplicar `knowledge/0014` + `knowledge/0017` + §7 Passo 5 PROMPT_ARQUITETO v1.3 — produzir 3 artefatos antes de assinar 🔵:

1. **Handoff operacional**: `.hbn/messages/AAAAMMDD-HHmm-handoff-fim-sessao-opus.md`
2. **Prompt de retomada**: `auditoria/00_status/114_PROMPT_RETOMADA_SESSAO_OPUS.md` (sucessor do 113)
3. **Proposta evolução protocolo** (§7.3): `.hbn/protocol-evolutions/AAAAMMDD-HHmm-onda-38-2-2-proposals.md` — **L33 candidata** ("fase .frm > .bas em consumo de contexto") já levantada na sessão anterior, **CRIAR** este arquivo agora se julgar pertinente (alta confiança que sim).

Orçamento 50/30/20 conforme knowledge 0017.

---PROMPT FIM---

## Referências

- Handoff origem desta sessão: [`.hbn/messages/20260526-1730-handoff-fim-sessao-opus.md`](../../.hbn/messages/20260526-1730-handoff-fim-sessao-opus.md)
- Readback ativo: [`.hbn/readbacks/0111-onda-38-2-2-v206-puro-filtros-envelopamento-quickwins-freeze.json`](../../.hbn/readbacks/0111-onda-38-2-2-v206-puro-filtros-envelopamento-quickwins-freeze.json)
- Consolidação 2ª rodada V207: [`112_ANALISE_AUDITORIA_CRUZADA_V207_2A_RODADA.md`](112_ANALISE_AUDITORIA_CRUZADA_V207_2A_RODADA.md)
- Relay vivo: [`.hbn/relay/INDEX.md`](../../.hbn/relay/INDEX.md)
- Cronograma tela-a-tela: [`auditoria/03_ondas/onda_38_2_filtros_menu_principal/38_2_TECNICO.md#L79`](../03_ondas/onda_38_2_filtros_menu_principal/38_2_TECNICO.md#L79)
