---
titulo: Auditoria cruzada GATE-A3 — Onda 38.2.3 — AT-3 PreOS IDs Textuais (Opus)
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
autoria: claude-opus (auditor cruzado, contexto fresco)
gate: GATE-A3
onda: 38.2.3
target_ref: 92e3062
output_lock: L45
relaciona-se: .hbn/proposals/0014-opus-auditoria-gate-a1-onda-38-2-3.md; .hbn/proposals/0017-opus-auditoria-gate-a2-onda-38-2-3.md; .hbn/proposals/0019-opus-reauditoria-gate-a2-onda-38-2-3.md; .hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md; .hbn/protocol-evolutions/20260527-2245-l45-cross-audit-output-lock-formalizacao.md
---

# Auditoria cruzada GATE-A3 — Onda 38.2.3 (AT-3 PreOS IDs Textuais)

> Relatório §12.A. Auditor cruzado independente em contexto fresco (Cadência D
> Estendida, knowledge 0019). Estado reconstruído **somente por Read** sobre o
> `target_ref 92e3062`. Vocabulário de severidade: **BLOQUEADOR / FORTE /
> MARGINAL**. Output lock L45 respeitado: caminho reservado verificado vazio
> antes da escrita; numeração não escolhida pelo auditor.

## Fontes efetivamente lidas

- `AGENTS.md`, `.hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md`,
  `.hbn/protocol-evolutions/20260527-2245-l45-cross-audit-output-lock-formalizacao.md`
- `auditoria/03_ondas/onda_38_2_3/AT3_PROCEDIMENTO_PREOS_IDS.md`,
  `AT3_FIX1_COMPILE_PREOS_WRAPPER.md`, `AT3_FIX2_PREOS_INTEGRITY_ASSERT.md`,
  `AT3_FIX3_PREOS_WRITE_NORMALIZACAO.md`
- `src/vba/Svc_PreOS.bas`, `src/vba/Repo_PreOS.bas`,
  `src/vba/Teste_V2_Roteiros.bas`
- `git diff 911af2f~1..92e3062` (3 commits AT-3: fix1/fix2/fix3) — escopo e diffs
- Espelhos `local-ai/vba_import/001-modulo/{AAQ-Svc_PreOS,AAL-Repo_PreOS,ABG-Teste_V2_Roteiros}.bas`

---

## 1. Veredito

**APROVAR GATE-A3.**

A correção AT-3 resolve F-NEW6 na causa-raiz correta: a escrita primária em
`PRE_OS` (`Svc_PreOS.EmitirPreOS`) agora grava IDs como texto canônico
zero-paddeado (`001`/`002`/`003`), com `NumberFormat="@"` aplicado antes da
gravação, e o teste `DIAG_PREOS_INTEGRITY` foi **fortalecido** (não enfraquecido)
para verificar simultaneamente a célula bruta e o retorno do repositório contra a
expectativa canônica. Nenhum BLOQUEADOR. Há FORTES de cobertura/manutenibilidade
a incorporar ou justificar em onda própria, mas nenhum deles invalida o gate nem
o resultado operacional reportado (compile limpo; `OK=76, FALHA=0, MANUAL=0`).

---

## 2. Bloqueadores (veto)

**Nenhum.**

Os cinco eixos auditados foram reproduzidos por leitura de fonte e nenhum revela
falha de segurança, correção ou regressão que justifique veto.

---

## 3. Fortes (incorporar ou justificar por escrito)

**FORTE-A3.1 — Critério de aceite "1000 não trunca" e "token alfa preservado"
sem teste automatizado.** O `AT3_PROCEDIMENTO_PREOS_IDS.md` declara
explicitamente: *"IDs acima de 999 permanecem completos: 1000 continua 1000; nao
ha truncamento para 000."* Por leitura, `NormalizarIdTextualPreOS`
(`Svc_PreOS.bas:22-65`) satisfaz isso: `Len(s) < 3` → pad; senão devolve `s`
intacto (sem truncar `1000`); primeiro caractere não-dígito → devolve `s` como
está (token alfa preservado). **Porém o E2E `TV2_RunRodizioStrikesEndToEnd` só
exercita EMP_ID 1/2/3** (`Select Case CLng(Val(empPresel))` em
`Teste_V2_Roteiros.bas:3768`). Os ramos `>= 1000` e alfa não têm assert que os
percorra. Para um gate de pré-release público "de alto risco de regressão", um
critério de aceite explícito sem teste correspondente contraria a regra
permanente knowledge 0010 ("funcionalidade nova exige teste"). Recomendação:
acrescentar um caso de unidade que persista/leia um ID `1000` e um token alfa via
o caminho de `PRE_OS`, ou justificar por escrito por que a verificação por
leitura de código é suficiente nesta linha.

**FORTE-A3.2 — Lógica de normalização triplicada (risco de drift).** Existem
agora três implementações independentes do mesmo contrato de normalização
mínima-3:
`Svc_PreOS.NormalizarIdTextualPreOS` (write primária),
`Repo_PreOS.NormalizarIdTextual` (read + write dormente) e
`Teste_V2_Roteiros.TV2_NormalizarIdMin3` (expectativa do teste). Produzem o mesmo
resultado para os valores sob teste, mas divergem em implementação
(`Repo_PreOS` é VarType-based e trata negativos/decimais explicitamente; as
outras duas são loop de dígitos). Manutenção futura que corrija uma sem as outras
introduz divergência silenciosa. Recomendação: consolidar num único helper
compartilhado (ex. em `Util_*`) em onda própria, ou justificar a triplicação.

---

## 4. Marginais (nice-to-have)

**MARG-A3.1 — Independência reduzida entre expectativa do teste e produção.** A
expectativa canônica do assert (`empPreselCanon = TV2_NormalizarIdMin3(empPresel)`,
`Teste_V2_Roteiros.bas:3754`) usa um algoritmo **byte-idêntico** ao da escrita de
produção (`NormalizarIdTextualPreOS`). Para os inputs testados (1/2/3) isso é
sólido — o assert também confere a célula **bruta** (`empPreOSBruto`), que não
passa por normalizador (`TV2_EmpIdPreOSBruto` faz só `Trim$(CStr(...))`), logo uma
regressão a `2` cru é capturada. A ressalva é apenas conceitual: um bug latente
comum a ambos algoritmos num input não testado co-falharia em silêncio. Mitigado
de fato pela checagem da célula bruta; registrado por completude.

**MARG-A3.2 — `Repo_PreOS.Inserir` é gêmeo dormente.** Confirmado por grep: não
há caller de `Repo_PreOS.Inserir` em `src/vba/`; a emissão de produção é
exclusivamente `Svc_PreOS.EmitirPreOS` (escrita inline). O `Inserir` já normaliza
(linha 39, `NormalizarIdTextual`), portanto está consistente, mas permanece código
morto. Considerar remoção ou anotação `' DORMENTE` em higiene futura.

---

## 5. Convergências (com 0014 / 0017 / 0019)

- **Write-side primária (FORTE-1 do 0019) — RESOLVIDO.**
  `Svc_PreOS.EmitirPreOS` passou a calcular `entIdTexto/ativIdTexto/servIdTexto/
  empIdTexto/codServTexto` via normalizador e gravá-los (diff em `Svc_PreOS.bas`
  linhas 230-234, 255-258, 261). Era exatamente o gap que o fix2 (só assert) não
  cobria e que o CSV `...220557.csv` (`EMP_PREOS_BRUTO=2 ... NF=@`) expôs.
- **Gêmeo dormente `Repo_PreOS.Inserir:38/39` (FORTE-2 do 0019) — coberto.**
  Normaliza `COD_SERV` e `EMP_ID`; não há regressão de twin.
- **Linhas legadas de `PRE_OS` (FORTE-3 do 0019) — decisão operacional
  registrada.** `AT3_PROCEDIMENTO_PREOS_IDS.md` §"Decisao operacional": Mauricio
  confirmou que os dados atuais são base de testes descartáveis; AT-3 não faz
  backfill. Decisão documentada e auditável — convergente.
- **`CREDENCIADOS.ATIV_ID` (MARG-3 do 0019)** — fora do escopo de AT-3; não tocado;
  permanece como item residual de outra trilha, não bloqueia GATE-A3.

---

## 6. Divergências reais

**Nenhuma divergência material** com as auditorias anteriores. O fix3 implementa o
que 0019 identificou como o residual write-side. A única diferença de ênfase: elevo
a ausência de teste para `>= 1000`/alfa de "verificado por leitura" (0019, tom de
aceitação) para **FORTE** (FORTE-A3.1), por ser pré-release de alto risco de
regressão com critério de aceite explícito sem cobertura — alinhado à knowledge
0010. Não é veto.

---

## 7. Riscos não cobertos

1. **Cobertura de fronteira ausente** (FORTE-A3.1): `ID >= 1000` e tokens
   não-numéricos não são exercitados por nenhum assert no caminho de persistência
   de `PRE_OS`.
2. **Drift de normalizadores triplicados** (FORTE-A3.2): correção parcial futura
   pode dessincronizar produção, repositório e teste.
3. **Coerção numérica fora de `PRE_OS`**: a auditoria limitou-se a `PRE_OS`
   conforme o gate. Outras abas que recebem `EMP_ID` (ex. `OS`, auditoria) não
   foram reauditadas aqui; `RegistrarEvento` em `EmitirPreOS` agora loga
   `empIdTexto` normalizado, o que é positivo, mas a integridade textual de `OS`
   não faz parte de AT-3.
4. **Verificação operacional não independente**: o auditor não executa VBA;
   o resultado `OK=76/FALHA=0`, o compile limpo e `M=1/F=0/err=0/skip=0` são
   tomados do relato de Mauricio. A trilha (CSVs com hash SHA-256 em
   `auditoria/evidencias/V12.0.0206/csv/`) é consistente com a narrativa dos fixes.

---

## 8. Verificações de integridade realizadas (reprodutíveis)

- **Escopo (eixo 5):** `git diff --stat 911af2f~1..92e3062` toca apenas
  `Svc_PreOS.bas` (+71/−...), `Repo_PreOS.bas` (+4), `Teste_V2_Roteiros.bas`
  (+111/−...) em código, mais docs/HBN/manifests/espelhos. Dentro do escopo AT-3.
- **Compile (eixo 5):** o erro "Método ou membro de dados não encontrado" em
  `Repo_PreOS.BuscarPorId(...)` foi resolvido pelo wrapper público
  `RepoPreOS_BuscarPorId` (padrão `Repo_OS`); as 4 chamadas no teste foram
  trocadas (`2060-2062`, `3784`). Sem mudança de cenário/contador/regra.
- **Import (eixo 5):** espelho `local-ai/vba_import/001-modulo/*` **byte-idêntico**
  ao `src/vba/` correspondente (verificado por `diff`). `M=1` reportado para fix3
  é coerente (só `Svc_PreOS` mudou no fix3).
- **Eixo 3:** `NumberFormat="@"` setado antes da escrita (`Svc_PreOS.bas:248-253`);
  célula `COL_PREOS_EMP_ID` recebe `empIdTexto` (texto `002`/`003`); assert do
  teste confere `empPreOSBruto = empPreselCanon` (bruto `=="002"`).
- **Eixo 4 (mascaramento):** assert ANTIGO era `pre.EMP_ID = empPresel` (repo
  normalizado vs observador cru — comparação que falhava por padding). Assert NOVO
  é `(empPreOSBruto = empPreselCanon And pre.EMP_ID = empPreselCanon)` — **mais
  forte**: regressão a `2` cru → `empPreOSBruto="2" ≠ "002"` → FALHA. Não mascara.

---

## 9. Próxima ação + checklist anti-viés (§12.4)

**Próxima ação recomendada:** declarar GATE-A3 aprovado; agendar para onda própria
(com readback/hearback) a incorporação dos dois FORTES — caso de teste de fronteira
`1000`/alfa e consolidação dos normalizadores. Em seguida, prosseguir ao RVS Trio
conforme gate operacional (`AT3_PROCEDIMENTO_PREOS_IDS.md` §Pos-import passo 4).

**Checklist anti-viés de bastão (§12.4):**

- **Auto-indicação?** Não. Não me indico para implementar os FORTES; sou auditor
  e não devo implementar o que auditei (separação de papéis, knowledge 0019 §1).
- **Evidência objetiva apresentada:** diffs git citados por linha, espelho
  byte-idêntico verificado, ausência de caller de `Inserir` confirmada por grep,
  assert reproduzido por leitura. Conclusões reproduzíveis por leitura de fonte.
- **Viés reconhecido:** sou da mesma família de modelo que produziu 0014/0017/0019;
  contexto fresco reduz mas não elimina viés de convergência. Recomendo que o 2º
  auditor cruzado (contexto independente) confirme especialmente FORTE-A3.1
  (cobertura de fronteira), que é onde divirjo em severidade das auditorias
  anteriores.
- **Mitigação:** Mauricio pesa evidência objetiva acima de auto-avaliação; manter
  o 2º auditor independente antes de fechar.

---

Auditor: Opus · contexto fresco · GATE-A3 / Onda 38.2.3 / AT-3 PreOS IDs ·
target_ref 92e3062 · sem toque em código VBA · output lock L45 respeitado.
