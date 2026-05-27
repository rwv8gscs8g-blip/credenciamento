---
titulo: Opus 4.7 — auditoria cruzada GATE-A1 (AT-1 gerador code-only) Onda 38.2.3
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
auditor: claude-opus-4-7 (chat novo, contexto fresco)
gate: GATE-A1
alvo: commit local ad14aa3
template: PROMPT_ARQUITETO §12.A
---

# Auditoria GATE-A1 — AT-1 gerador code-only (Onda 38.2.3)

> Auditoria arquitetural em contexto fresco, Cadência D Estendida. Codex
> implementou (commit `ad14aa3`); este chat audita sem implementar. Toda
> conclusão abaixo foi reproduzida independentemente via leitura de fonte +
> execução read-only do gerador e comparação byte-a-byte dos artefatos.

## 1. Veredito

**APROVAR o fix do gerador (AT-1) — com 1 BLOQUEADOR diferido ao GATE-A4 e 3 FORTES.**

A correção do gerador (`publicar_vba_import_v2.py`) está **tecnicamente
correta e completa para o escopo declarado** (Cadastro_Servico): o drift de
`AAD-Cadastro_Servico.code-only.txt` está **zerado** e as declarações
module-level + `WithEvents` + atributo per-symbol foram preservadas. Reproduzi
o `gamma_equal=True` por comparação byte-a-byte independente.

O BLOQUEADOR **não impede AT-2 (diagnóstico F-NEW5) nem AT-3 (fix PreOS)** —
nenhum dos dois roda import. Ele **impede o GATE-A4 (import L41 2 fases)**:
o pacote ainda embarca um `AAI-Credencia_Empresa.code-only.txt` quebrado pelo
**mesmo bug** que motivou o AT-1, e esse artefato será consumido no import
Estabilizado. O fix do gerador não auto-cura artefatos já emitidos.

## 2. BLOQUEADORES (veto)

### BLOQ-1 — `AAI-Credencia_Empresa.code-only.txt` está quebrado (mesmo bug do P0-1); veto ao GATE-A4

**Evidência (reproduzida).** Comparando o `.code-only.txt` versionado/em-disco
contra a saída do gerador NOVO a partir do `.frm` atual:

| Form | code-only atual | gerador novo | match |
|---|---:|---:|:--:|
| Cadastro_Servico | 10636 | 10636 | ✅ |
| **Credencia_Empresa** | **14104** | **14400** | ❌ |
| ProgressBar | 1806 | 1825 | ❌ |
| (demais 10 forms) | — | — | ✅ |

O code-only atual de Credencia_Empresa **começa direto em
`Private Sub UserForm_Initialize()`** — perdeu todo o cabeçalho module-level
que o gerador antigo truncou:

```
Option Explicit
Private Const STATUS_CRED_ATIVO As String = "ATIVO"
Private mEmpIdSelecionado As String
Private mCnpjSelecionado As String
Private mRazaoSelecionada As String
Private WithEvents mTxtFiltroCredLista As MSForms.TextBox
Attribute mTxtFiltroCredLista.VB_VarHelpID = -1
```

O corpo do form **referencia** `mTxtFiltroCredLista`
(`If Not mTxtFiltroCredLista Is Nothing` em `CR_EnsureFiltroListaDinamico`) e
os estados `mEmpIdSelecionado/mCnpjSelecionado/mRazaoSelecionada`. Importado
em modo Estabilizado **sem** a declaração `WithEvents` e sem `Option Explicit`,
o resultado é falha de compilação ou erro de runtime ("Object required") —
exatamente a classe de falha F-NEW que a Onda 38.2.3 quer eliminar.

**Remediação.** Antes do GATE-A4: `--apply --only Credencia_Empresa.frm`
(análogo ao que o AT-1 fez para Cadastro_Servico), seguido de re-auditoria do
artefato regenerado. Incluir ProgressBar (ver MARG-2) no mesmo passe.

**Escopo do veto.** Aplica-se ao **GATE-A4 (import)**, não a AT-2/AT-3. O
readback 0114 deliberadamente restringiu o AT-1 a Cadastro_Servico e proibiu
tocar outros forms; portanto o AT-1 está conforme. Mas a onda não pode chegar
ao import com o pacote nesse estado.

## 3. FORTES (incorporar ou justificar por escrito)

### FORTE-1 — Ponto cego do guard: `--check`/pre-commit não valida paridade de code-only

Rodei `publicar_vba_import_v2.py check` (read-only): ele reporta
**`AAI-Credencia_Empresa.frm` e `AAB-ProgressBar.frm` como `in_sync`**, e
acusa drift **apenas** em `AAX-App_Release.bas`. O `--check` compara somente
os bytes normalizados `src .frm ↔ pkg .frm`; o `.code-only.txt` é apenas
gerado-se-ausente (bloco sob `mode=='apply'`), **nunca** comparado contra a
saída atual do gerador. Logo o artefato quebrado de Credencia_Empresa
**passa limpo no guard**. A afirmação do bypass AAX ("HBN guards foram rodados
manualmente e passaram") **não cobre** o drift de code-only — é uma garantia
falsa para o GATE-A1. Recomendação: adicionar ao `--check` uma checagem de
paridade que rode `gerar_code_only_txt` e compare com o `.code-only.txt`
existente, antes do AT-4.

### FORTE-2 — `--apply` completo não auto-cura code-only stale (self-healing gap)

Em `process_file`, no ramo `in_sync` de `.frm`, o code-only só é regenerado se
`sync_existing_code_only OR not exists`. Como `sync_existing_code_only =
bool(only)`, um **publish completo (`--apply` sem `--only`)** regenera code-only
apenas quando **ausente** — nunca quando presente-porém-stale. Consequência: a
frota de forms com code-only obsoleto (AAI, ProgressBar) **não é curada** por
um publish global; cada um exige `--only`. Isso é o reverso da virtude do
`--only` (ver §5): conservador o bastante para não vazar escopo, conservador
demais para auto-reparar. Recomendação: antes do AT-4, rodar `--only` form-a-form
nos forms afetados, ou adicionar um modo explícito "resync-all-code-only" com
salvaguarda.

### FORTE-3 — code-only de import é parcialmente gitignored/untracked

`.gitignore:40` ignora `local-ai/`. Hoje **AAD/AAK/AAL/AAM** code-only e o
script estão tracked (force-add histórico) e foram persistidos em `ad14aa3`;
mas **AAI/AAB/AAA/AAC/AAE/AAF/AAG/AAH/AAJ** estão untracked. O artefato
quebrado de Credencia_Empresa vive **só em disco** — drift invisível ao git e
a qualquer revisão por PR. Mesmo após regenerar via `--only`, o resultado não
será versionado a menos que `git add -f` (como AAD). A política de tracking dos
code-only que entram no import deve ser **consistente** (ou todos tracked, ou
todos gerados deterministicamente no import e nenhum tracked). Corrige também a
imprecisão da proposta 0013 §5 (ver §6).

## 4. MARGINAIS (nice-to-have)

- **MARG-1 — `gamma=9307` não reproduzível pelo método documentado.** A
  proposta 0013 cita `len_frm_gamma=len_co_gamma=9307`. Minhas medições do
  corpo injetável de Cadastro_Servico: 10566 (CRLF) / 10273 (LF) / 10636
  (bytes do code-only). O **`gamma_equal=True` é verdadeiro** (confirmado por
  comparação byte-a-byte), mas o número 9307 não bate com nenhuma métrica
  reproduzível a partir da fonte. Documentar a fórmula exata do `gamma` para
  torná-lo auditável.
- **MARG-2 — ProgressBar code-only sem `Option Explicit`** (drift de 19 bytes =
  `Option Explicit\r\n\r\n`). Form blindado, baixo impacto, mas deve entrar no
  resync do BLOQ-1/FORTE-2.
- **MARG-3 — Build label do AAX contém "FREEZE"**
  (`a51b191+ONDA38.2.2-V206-FREEZE`). Aqui refere-se ao freeze da 38.2.2 (rótulo
  já carimbado no workbook do operador, coerente com knowledge 0016: deixar o
  valor da onda anterior, o V3 faz o bump). Aceitável e unstaged, mas é um trap
  latente vs. o invariante "sem sufixo FREEZE antes do GATE-FREEZE" — vigiar
  quando o AAX for finalmente republicado.
- **MARG-4 — trailing whitespace no fim do AAX** (linha `     ` após os 3 CRLF)
  viola regra 13; será corrigido por `normalize_bytes` na republicação. Deferir
  junto ao tratamento do AAX (knowledge 0016).

## 5. Convergências com o trabalho auditado (todas verificadas)

1. **Gerador preserva module-level + `WithEvents`.** O caminho principal (L22)
   retorna tudo **após `Attribute VB_Exposed`**, capturando `Option Explicit`,
   `Private`/`Public`/`Const`, `WithEvents` e o atributo per-symbol. Para
   Cadastro_Servico a saída do gerador bate **byte-a-byte** com o code-only
   versionado (`gen == code-only`, 10636 == 10636).
2. **code-only coerente com o `.frm`.** As 3 linhas de contrato
   (`mIgnorarFiltro`, `WithEvents mTxtBuscaTopo`, `Attribute …VB_VarHelpID`)
   estão presentes e na ordem correta; o restante do corpo é idêntico.
3. **Manter `Attribute …VB_VarHelpID` no code-only é compatível com o
   Importador V3.** `IV3_LimparAtributosCodeOnly`
   (`Importador_V3.bas:1057-1086`) remove qualquer linha cujo `LTrim` comece
   (case-insensitive) com `"attribute "` antes do `AddFromString`, e a
   validação agressiva de `CountOfLines` é computada sobre o **conteúdo já
   limpo** (`linhasEsperadas` a partir de `conteudo` pós-strip, linhas 900-910)
   — sem false-failure. O VBE regenera o default `VB_VarHelpID = -1`. Seguro.
   (Importador_V3.bas é tabu; foi apenas **lido**, não editado.)
4. **`--only` evita vazamento de escopo.** Verificado: com `only` setado, (a) o
   laço pula arquivos não-alvo e (b) `atualizar_manifesto`/`atualizar_build_doc`
   são pulados (`if args.mode=='apply' and not only`). O diff do `ad14aa3` ficou
   restrito aos `files_allowed` do readback 0114 (script + AAD code-only +
   docs/readback/proposal); nenhum manifesto/build/outro-form foi tocado.

## 6. Divergências reais

- **Proposta 0013 §5** afirma "`local-ai/` é ignorado por `.gitignore`; …
  precisarão de `git add -f`". Impreciso: `local-ai/` é ignorado, **mas** o
  script e os code-only AAD/AAK/AAL/AAM já estão **tracked** e o `ad14aa3` os
  persistiu sem necessidade de ação manual adicional. O efeito final (commit
  persistido) está correto; a descrição do mecanismo, não. Liga-se ao FORTE-3
  (inconsistência de tracking).
- Sem divergência técnica de mérito quanto ao fix do gerador em si — concordo
  integralmente com o desenho L22 e com o caminho `--only`.

## 7. Riscos não cobertos

1. **(principal)** Artefato quebrado de Credencia_Empresa consumido no AT-4 →
   reintrodução de falha F-NEW no import V206 (BLOQ-1).
2. Guard com ponto cego (FORTE-1) pode mascarar regressões futuras de code-only
   em qualquer form cujo `.frm` permaneça in_sync mas cujo code-only fique
   stale.
3. code-only untracked (FORTE-3) → drift não detectável em CI/PR; regeneração
   via `--only` não versionada por padrão.
4. Aplicação da lição L44 (knowledge 0020): este achado **confirma** L44 — o
   diff "cosmético" só foi desmascarado inspecionando o **pipeline gerador** e
   comparando a saída do gerador com os artefatos de TODOS os forms, não só o
   alvo. Recomendo registrar Credencia_Empresa como segunda evidência empírica
   de L44.

## 8. Próxima ação

- **Codex pode prosseguir a AT-2 e AT-3** (não bloqueados).
- **Antes do GATE-A4 (import):** fechar **BLOQ-1** — `--apply --only
  Credencia_Empresa.frm` (+ ProgressBar) e re-auditar; idealmente fechar
  **FORTE-1** (paridade code-only no `--check`) e **FORTE-2** (modo resync) para
  que o guard volte a ser uma garantia real antes do import.
- **AAX bypass: ACEITÁVEL.** Documentado em `.hbn/bypasses/20260527-1414-…`,
  autorizado pelo hearback `confirmed` no readback 0114, escopo estreito (só
  permite o commit apesar de drift preexistente), AAX permanece **unstaged** e
  fora do `ad14aa3`, coerente com knowledge 0016. **Ressalva:** a justificativa
  do bypass apoia-se em "guards rodados manualmente e passaram", o que — por
  FORTE-1 — não cobre o drift de code-only; aceitar o bypass não deve ser lido
  como atestado de pacote import-safe.
- **Checklist anti-viés §12.4:** não se aplica — não há recomendação de
  passagem de bastão; permaneço auditor, Codex segue implementador. Sem
  auto-indicação.

---
Auditor: Claude Opus 4.7 · contexto fresco · GATE-A1 · alvo `ad14aa3`
