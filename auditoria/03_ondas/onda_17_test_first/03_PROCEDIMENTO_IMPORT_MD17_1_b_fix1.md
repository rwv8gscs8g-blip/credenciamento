---
titulo: Procedimento de import MD-17.1.b-fix1 — ATIV_ID numérico via hash determinístico
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-03
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1
---

# 03 — Procedimento de import MD-17.1.b-fix1 (Onda 17 Test-First)

## Tema

Fix do Quarteto reprovado em `VR_20260503_020405`. Causa raiz: convenção
alfanumérica de `ATIV_ID` em `TV2_FixtureFactory` (criada em MD-17.1.a)
incompatível com `TV2_Pad3` interno do `TV2_CredenciarAtividade` —
`Val("F_SBM2_01")` retorna `0` → `COL_CRED_ATIV_ID` gravado como `"000"`
→ `SelecionarEmpresa` não acha empresa apta → ciclo não executa →
strikes=0 → asserts falham.

**Fix**: `ATIV_ID` agora gerado como número de 3 dígitos via hash
determinístico do escopo (faixa `900-979`). Engine ganha 3 helpers
Private. Roteiros **não** é tocado (transparente para os 5 cenários).

## Pré-condições

| Item | Esperado |
|---|---|
| Workbook | restaurado do backup `20260503_020242-V3-FULL` (estado MD-17.1.a verde, pré-MD-17.1.b) |
| Build pré-fix1 | `f7aa84f+ONDA17.MD1A-fixture-factory-namespacing` |
| Quarteto pré-fix1 | APROVADO `VR_20260503_010329` (validação MD-17.1.a) |
| `src/vba/` ↔ `local-ai/vba_import/` | shasum batendo (2 arquivos do MICRO17-fix1) |

## Hashes confirmados (sha1, src/vba autoritativo M11)

| Arquivo | sha1 |
|---|---|
| `src/vba/Teste_V2_Engine.bas` ↔ `local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas` | `aaba688613257d32fec66e76437eeac5d699478c` |
| `src/vba/App_Release.bas` ↔ `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | `48f0e5e98eed89e34a73a461f8e9728a6d7e0177` |

CRLF preservado. **Engine balanceado**: 59 Sub / 64 Function. **Roteiros NÃO tocado.**

## Mudanças resumo

| Arquivo | Tipo | Linhas |
|---|---|---|
| `Teste_V2_Engine.bas` | TV2_FixtureFactory: ATIV_ID via hash; TV2_LimparNamespace: chama helper novo; +3 helpers Private (TV2_FF_HashEscopoParaAtivId, TV2_FF_LimparAtividadesEscopo, TV2_FF_LimparLinhaPorIdExato) | 2956 → 3069 (+113) |
| `App_Release.bas` | bump APP_BUILD_IMPORTADO + GERADO_EM | 194 → 200 (+6) |
| `Teste_V2_Roteiros.bas` | **NÃO tocado** — `idsAtivsOut(i)` agora vem como `"920"` ou similar; cenários consomem transparentemente | 2269 (sem mudança) |

## Mapa de hash dos escopos usados

| Escopo | hashBase | Faixa de ATIV_ID gerada (k=0..qtdAtivs-1) |
|---|---|---|
| `SBM2` | (calculado em runtime, faixa 900-979) | `Format$(hashBase, "000")` único |
| `SBM5` | idem | idem |
| `SNZE` | idem | idem |
| `SR2S` | idem | idem |
| `S5E` | idem | idem |

`TV2_LimparNamespace` chamado antes de `TV2_FixtureFactory` mitiga
qualquer colisão hipotética entre escopos.

## Procedimento operacional

### Passo 0 — Restaurar backup pré-MD-17.1.b (CRÍTICO)

O workbook após o import malsucedido da MD-17.1.b contém código
quebrado. Antes de importar o fix, **restaurar do backup** que o
próprio Importador V3 gerou:

```
\\Mac\Home\Projetos\Credenciamento\backups\vba\20260503_020242-V3-FULL
```

Após restaurar, confirmar no Imediato:

```
?GetBuildImportado
```

Esperado: `f7aa84f+ONDA17.MD1A-fixture-factory-namespacing` (estado
pré-MD-17.1.b, MD-17.1.a verde).

### Passo 1 — Resetar VBE (sempre, L7)

VBE: `Executar > Redefinir` (ou Ctrl+Pause/Break).

### Passo 2 — Rodar import V3 fix1

Janela Imediato:

```
ImportarPacoteV3_Delta "MICRO17-fix1", "f7aa84f+ONDA17.MD1B-fix1-ativid-numerico-hash"
```

Importa 2 arquivos:

- `001-modulo/ABF-Teste_V2_Engine.bas` (Engine com helpers de hash)
- `001-modulo/AAX-App_Release.bas` (bump build)

### Passo 3 — Compile manual

VBE: `Depurar > Compilar VBAProject`. Esperado: zero erros.

### Passo 4 — Validar build importado

```
?GetBuildImportado
```

Esperado: `f7aa84f+ONDA17.MD1B-fix1-ativid-numerico-hash`.

### Passo 5 — Smoke teste do hash (sanity opcional)

Janela Imediato:

```
?TV2_FF_HashEscopoParaAtivId("SBM2")
```

Esperado: número entre 900 e 979 (determinístico para "SBM2").

### Passo 6 — Quarteto Mínimo (gate principal)

```
CT_ValidarRelease_QuartetoMinimo
```

Esperado:

- `RESULTADO_GERAL = APROVADO`
- `V1=171/0` (regressão zero V1)
- `V2_Smoke=14/0` (regressão zero Smoke)
- `V2_Canonica=23/0` (eram 20; +3 cenários novos passando agora)
- `E2E_Strikes=66/0` (eram 64; +1 cenário verde, +1 AMARELO contado em MANUAL=1)

### Passo 7 — Verificar AMARELO de fato testado

Abrir `RESULTADO_QA_V2`. Filtrar `CS_E2E_REATIV2STRIKES`.

Esperado **agora** (diferente da MD-17.1.b sem fix1):

- STATUS = `MANUAL_ASSISTIDO` (amarelo)
- OBTIDO mostra `STRIKES_TOTAL_HISTORICO > 0` (ciclo executou de fato!)
- STATUS_POS_REATIV_E_1NOTA = `SUSPENSA_GLOBAL` (validando o débito real)
- OBS aponta `auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md`

Esse é o resultado correto: **AMARELO documentando débito real, com
ciclo executado de fato**.

### Passo 8 — Salvar workbook

Salvar como `V12-202-Z003-onda17-md1b-fix1` **somente após Quarteto APROVADO**.

### Passo 9 — Reportar VR ao Claude

Cole no chat:

1. `?GetBuildImportado`
2. `VR_<timestamp>` do Quarteto + sintaxe completa
3. Status do `CS_E2E_REATIV2STRIKES` em RESULTADO_QA_V2 (esperado: AMARELO com ciclo real)

## Critérios de sucesso MD-17.1.b-fix1

1. Compile manual passa limpo.
2. `GetBuildImportado` = `f7aa84f+ONDA17.MD1B-fix1-ativid-numerico-hash`.
3. `CT_ValidarRelease_QuartetoMinimo` APROVADO.
4. 4 cenários FixtureFactory verdes (CS_BORDA_MAX2/MAX5/NOTA_ZERO + CS_E2E_5EMPS).
5. CS_E2E_REATIV2STRIKES AMARELO **com ciclo real executado** (`STRIKES_TOTAL_HISTORICO > 0`).
6. `V2_Canonica=23/0` e `E2E_Strikes=66/0` (ou similar).

Cumpridos os 6: MD-17.1.b fechado, próximo é MD-17.1.c.

## Rollback

Se Quarteto reprovar novamente:

```
git restore src/vba/Teste_V2_Engine.bas
git restore src/vba/App_Release.bas
git restore local-ai/vba_import/001-modulo/ABF-Teste_V2_Engine.bas
git restore local-ai/vba_import/001-modulo/AAX-App_Release.bas
rm local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO17-fix1.txt
rm auditoria/03_ondas/onda_17_test_first/03_PROCEDIMENTO_IMPORT_MD17_1_b_fix1.md
```

Restaurar backup `20260503_020242-V3-FULL`. Reportar evidência —
provavelmente cap M10 (3 fix-attempts) já atingido, replanejar MD-17.1.b
com hearback Opus.

## Lição candidata para PHAGOCYTOSIS (a destilar em MD-17.5)

**L21**: helpers VBA antigos podem ter coerção numérica silenciosa via
`Val()` que invalida convenções alfanuméricas adotadas posteriormente.
Pre-flight L14 deve verificar não só assinaturas dos chamados diretos,
mas também **o que cada chamado faz internamente com argumentos
passados** quando convenções de naming são introduzidas. Assinatura é
contrato; coerção interna é armadilha.

**M12** (meta): smoke testes em janela Imediato sem print explícito
(`?mo(1)`) podem mascarar bugs latentes. CS_E2E_5EMPS executando contra
fixture quebrada documentou exatamente isso — débito DT-17.1.a-1 da
MD-17.1.a (smoke FixtureFactory sem evidência visual) revelou o bug
apenas no uso real em MD-17.1.b. Ação: smoke deve sempre incluir
asserção de output mínimo.

## Documentos relacionados

- [`.hbn/readbacks/0013-onda17-test-first.json`](../../../.hbn/readbacks/0013-onda17-test-first.json)
- [`local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO17-fix1.txt`](../../../local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO17-fix1.txt)
- [`auditoria/00_status/44_DEBITO_DT_17_REATIV_STRIKES.md`](../../00_status/44_DEBITO_DT_17_REATIV_STRIKES.md)
- [`auditoria/03_ondas/onda_17_test_first/01_PROCEDIMENTO_IMPORT_MD17_1_a.md`](01_PROCEDIMENTO_IMPORT_MD17_1_a.md)
- [`auditoria/03_ondas/onda_17_test_first/02_PROCEDIMENTO_IMPORT_MD17_1_b.md`](02_PROCEDIMENTO_IMPORT_MD17_1_b.md) (versão pré-fix1; quarteto reprovado)

## Versão

- v1.0 — 2026-05-03 — fix1 inicial.
