---
titulo: Drift G7 residual pré-Onda 12 — inventário pós-rc1
diataxis: reference
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203-rc1 (closure)
data: 2026-05-02
autor: Claude Opus 4.7 (Cowork) — Frente 1 Credenciamento
licenca-target: TPGL-v1.1 (Credenciamento)
---

# Drift G7 residual pré-Onda 12 — inventário pós-rc1

## Contexto

Após Onda 11 (V12.0.0203-rc1 closure) entregar Quarteto Mínimo verde,
permanecem 23 arquivos `.bas` divergentes entre `src/vba/` e
`local-ai/vba_import/001-modulo/`, mais 2 arquivos presentes apenas
em `src/vba/` (não estão no pacote canônico). Este drift residual é
o débito **D1** do roadmap [27_ROADMAP_REINCORPORACAO_INCREMENTAL_V203](../../00_status/27_ROADMAP_REINCORPORACAO_INCREMENTAL_V203.md):
hotfixes V2 históricos das Ondas 1-8 que avançaram em `src/vba/` mas
não foram publicados para o pacote canônico de produção.

A Onda 11 deliberadamente **não** sincronizou esses arquivos para
preservar o ancora estável `V12-202-Z` + permitir reincorporação
incremental e validada nas Ondas 12-16.

## Marcador HBN

🟠 **HBN SOURCE DRIFT DETECTED** — registrado e documentado, *não
bloqueia rc1* porque (a) os 6 arquivos do domínio strikes foram
sincronizados na MD-0; (b) os demais não são consumidos pelo gate
oficial Quarteto.

## Inventário (snapshot 2026-05-02 pós-MD-3.1)

### Arquivos divergentes (23)

| Arquivo | hash src/vba (12 chars) | hash canônico (12 chars) | Provável origem |
|---|---|---|---|
| `AppContext.bas` | `09feb2806094` | `587b369faf8e` | Hotfix V2 Onda 5+ |
| `Audit_Log.bas` | `88ca42d1a800` | `efe5b44bd79d` | Hotfix V2 |
| `Auto_Open.bas` | `3c773da4134e` | `4e8db67c1933` | Hotfix V2 |
| `Central_Testes.bas` | `a5ccc1866086` | `38cdd2eaf3da` | Hotfix V2 |
| `Central_Testes_Relatorio.bas` | `2dbf4ea22945` | `0a4e615af44a` | Hotfix V2 |
| `Central_Testes_V2.bas` | `de37ed2c7e8e` | `5b33730b7655` | Onda 7 (IDM_*/RDZ_*) + Onda 2/4 ([15]-[19]) + MD-3.1 ([20] em ambos) |
| `ErrorBoundary.bas` | `09477f06cf3c` | `f66829350322` | Hotfix V2 |
| `Funcoes.bas` | `87d20a32dab8` | `8ce18a2e0b4a` | Hotfix V2 (Onda 2 CNAE?) |
| **`Mod_Types.bas`** ⚠️ | `7c365006d105` | `f5baf96c1768` | **TABU — só Onda 9 plena com aprovação explícita** |
| `Preencher.bas` | `f7f05caf0e18` | `4433391fb499` | Hotfix V2 (Onda 5 deterministico) |
| `Repo_Credenciamento.bas` | `ae34ad060c66` | `8ab1253ec260` | Hotfix V2 |
| `Repo_Empresa.bas` | `a7fe8b5fe909` | `62f83fae1e1a` | Hotfix V2 |
| `Repo_OS.bas` | `23404f42e7ef` | `9c771fae2bad` | Hotfix V2 |
| `Repo_PreOS.bas` | `d16611f1fcbc` | `7ee197cfa5d0` | Hotfix V2 |
| `Svc_OS.bas` | `a088b31f7ed5` | `061bb7dc7482` | Hotfix V2 |
| `Svc_Transacao.bas` | `4b7a746b5fe7` | `f083708cc202` | Hotfix V2 |
| `Teste_Bateria_Oficial.bas` | `7d5057bba297` | `3009878c11d4` | Hotfix V2 (Onda 1 strikes parcial?) |
| `Teste_UI_Guiado.bas` | `cae8ef068ed0` | `f835d374057a` | Hotfix V2 |
| `Teste_V2_Engine.bas` | `969ad9960ce5` | `49f8e75328cd` | Onda 7 (IDM_*/RDZ_*) |
| `Treinamento_Painel.bas` | `f396549353ea` | `d9741b26c1ef` | Hotfix V2 |
| `Util_Conversao.bas` | `30ea554d300a` | `573486b45dde` | Hotfix V2 |
| `Util_Filtro_Lista.bas` | `1efe33d18a81` | `44fa9ee19761` | Hotfix V2 (v9, citado em ROADMAP 27) |
| `Util_Planilha.bas` | `ed34caeb511d` | `dcb656d086c3` | Hotfix V2 |

### Arquivos presentes apenas em src/vba (2)

| Arquivo | Status | Destino |
|---|---|---|
| `Emergencia_CNAE.bas` | só src/vba — citado em D5 do ROADMAP 27 | Onda 12 (CNAE) decide se entra no pacote |
| `Importador_V2.bas` | só src/vba — legacy v13 buggy (removido do canônico em Onda 9 V3 Phase 1) | **NÃO REINTEGRAR** — manter só como histórico |

## Recomendações por arquivo (para Ondas 12-16)

### Onda 12 (Reincorporação Onda 2 — CNAE snapshot/dedup)

Avaliar diff dos seguintes (provável origem CNAE):

- `Funcoes.bas` (utilitários CNAE)
- `Emergencia_CNAE.bas` (entrada nova ou descartar)
- `Central_Testes_V2.bas` — preservar `[15]-[19]` do src/vba que já têm
  CNAE/Diag/CFG/IDM/RDZ; aplicar diff só em código não-menu se houver

### Onda 13 (Reincorporação Onda 3 — CNAE dedup automático)

Refinamento da Onda 12. Diff incremental sobre `Funcoes.bas` se
diff persistir.

### Onda 14 (Reincorporação Onda 4 — Diag rodízio + form)

- `Util_Config.bas` — já sincronizado na MD-0 da Onda 11
- `AppContext.bas` (provavelmente)
- Possível form `Configuracao_Inicial.frm`

### Onda 15 (Phase A.6 — auditoria caso-a-caso divergentes residuais)

Loop sobre os arquivos restantes da tabela acima (Repo_*, Svc_*,
ErrorBoundary, Util_Conversao, Util_Planilha, Audit_Log, Auto_Open,
Treinamento_Painel, Central_Testes, Central_Testes_Relatorio).
Diff caso-a-caso. Se hotfix V2 traz melhoria validável → reincorporar
com microdelta + gate Quarteto. Se hotfix V2 é cruft sem evidência →
copiar canônico → src/vba para encerrar drift.

### Onda 16 (Reincorporação Onda 7 — IDM_*/RDZ_*)

- `Teste_V2_Engine.bas` (5 cenários V2 Canonica novos esperados)
- `Teste_V2_Roteiros.bas` — já sincronizado na MD-0 da Onda 11
- Possível `Svc_Rodizio.bas` (já sincronizado)

### TABU — `Mod_Types.bas`

`Mod_Types.bas` está em drift mas **não pode ser tocado** fora da
Onda 9 plena com aprovação explícita do operador (regra V203 #9).

**Estratégia recomendada:**

1. NÃO sincronizar `Mod_Types.bas` em nenhuma Onda 12-16.
2. Se diff de outro arquivo depender de mudança em `Mod_Types`
   (UDT nova, campo novo), abrir Onda 9b com plano dedicado e
   pedir hearback explícito.
3. Glasswing G8 protege contra `Public Type` solto fora de
   `Mod_Types.bas` — manter como está.

## Procedimento canônico para reincorporar 1 arquivo

Para cada arquivo a reincorporar nas Ondas 12-16:

1. Pre-flight L14: `shasum src/vba/<arquivo>` vs canônico; ler ambas
   versões e listar diff.
2. Avaliar se diff representa melhoria validável ou cruft.
3. Se melhoria: criar microdelta dedicado (manifesto delta novo) +
   gate Quarteto verde + bump build.
4. Se cruft: copiar canônico → src/vba (encerra drift).
5. Pós-validação: `shasum src/vba/<arquivo>` == canônico.
6. Atualizar este documento removendo a entrada (ou marcando
   "RESOLVIDO" com microdelta de origem).

## Marcadores HBN V2 sugeridos por Onda 12+

Incluir no readback de cada onda:

```json
{
  "drift_g7_baseline": "auditoria/03_ondas/onda_11_v203_rc1_closure/DRIFT_G7_RESIDUAL_PRE_ONDA12.md",
  "drift_g7_arquivos_em_escopo": ["..."],
  "drift_g7_arquivos_intocados": ["..."]
}
```

## Versão

- v1.0 — 2026-05-02 — inventário inicial pós-rc1.
