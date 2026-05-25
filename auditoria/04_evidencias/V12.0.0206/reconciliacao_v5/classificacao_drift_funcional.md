---
titulo: Onda 37.1 — Subclassificacao dos drift funcionais V5 vs src/vba
diataxis: status
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
---

# Subclassificacao dos drift funcionais V5 vs src/vba

## Contexto

A V5 e a unica versao conhecida que compila. Portanto, `src/vba/` nao pode ser
tratado automaticamente como origem importavel quando diverge da V5. Esta
matriz reclassifica os 28 arquivos marcados como `diferenca_funcional` na
Onda 37.

## Criterio

- `drift_md33_descartar`: tocado apenas por commits da cadeia MD33 frustrada
  apos `f24e535`.
- `drift_legitimo_anterior_v5`: sem commit em `src/vba/` apos `f24e535`; o
  drift vem de commits anteriores ja contidos em ondas/releases fechadas, mas
  nao refletidos no workbook V5.
- `drift_misto`: mistura commits MD33 e commits de outra origem apos V205.
- `drift_inesperado_investigar`: commit apos V205 sem trilha em onda fechada.

## Resultado

| Subclasse | Qtde | Decisao |
|---|---:|---|
| `drift_md33_descartar` | 3 | Candidato a reverter para o estado equivalente a V5 em Onda 37.2 safe_track. |
| `drift_legitimo_anterior_v5` | 25 | Nao reverter automaticamente; exigir analise por onda/arquivo antes de qualquer import. |
| `drift_misto` | 0 | Nenhum. |
| `drift_inesperado_investigar` | 0 | Nenhum; nenhum 🟡 por arquivo foi necessario nesta classe. |

## Commits pos-V205 que tocaram src/vba

| Commit | Data | Mensagem | Arquivos |
|---|---|---|---|
| `0b7c4e8` | 2026-05-24 | `fix: consolidate v206 canonical project root` | `App_Release.bas`, `Menu_Principal.frm` |
| `7ba5d97` | 2026-05-24 | `fix: stabilize v206 report import compile gate` | `Menu_Principal.frm`, `Preencher.bas` |
| `031e077` | 2026-05-24 | `fix: avoid menu import for v206 report gate` | `Menu_Principal.frm`, `Rel_Emp_Serv.frm`, `Rel_OSEmpresa.frm` |
| `0d3893f` | 2026-05-24 | `fix: pause v206 report gate and reset clean baseline` | `Importador_V3.bas`, `Preencher.bas`, `Rel_Emp_Serv.frm`, `Rel_OSEmpresa.frm` |

## Arquivos drift_md33_descartar

🟠 SOURCE DRIFT DETECTED — estes arquivos representam quebra do invariante
"`src/vba/` representa estado importavel que compila". A proxima onda pode
propor reversao documentalmente controlada, mas esta Onda 37.1 nao executa
reversao.

| Arquivo | Commits pos-V205 | Evidencia |
|---|---|---|
| `Importador_V3.bas` | `0d3893f` | `auditoria/00_status/100_PAUSA_REBASE_PLANILHA_LIMPA_V206_CODEX.md` registra que a alteracao textual/operacional no Importador V3 veio do ciclo reprovado e que V5 substituiu a rota anterior. |
| `Menu_Principal.frm` | `0b7c4e8`, `7ba5d97`, `031e077` | `auditoria/03_ondas/onda_33_v206_fix_relatorios_pdf_precondicao/01_TECNICO_ONDA33_FIX_RELATORIOS.md` registra que Menu Principal saiu do pacote fix2, mas commits anteriores deixaram drift funcional frente a V5. |
| `Preencher.bas` | `7ba5d97`, `0d3893f` | A mesma trilha MD33/fix1/fix2 registra tentativas de ajustar preenchimento de relatorios que nao passaram no compile humano. |

## Arquivos drift_legitimo_anterior_v5

Gate 4: para cada arquivo abaixo, o ultimo commit que tocou `src/vba/` antes
ou em `f24e535` foi cruzado contra uma linha fechada: V203/V204/V205 com gate
publico, ou onda documentada em `auditoria/03_ondas/`/`.hbn/results/`.

| Arquivo | Ultimo commit ate V205 | Linha/onda fechada associada |
|---|---|---|
| `Audit_Log.bas` | `94773eb` — release prepare V12.0.0203 rc4 | Linha V203 fechada e herdada por V204/V205; ver relay e releases posteriores. |
| `Central_Testes_Relatorio.bas` | `844361e` — Onda 6 hotfix de sincronizacao | Onda 6 encerrada em `.hbn/relay/INDEX.md` e `.hbn/results/0001-exec-onda06.json`. |
| `Configuracao_Inicial.frm` | `fb929b8` — release V12.0.0204 | Release V204 publicada e herdada pela V205. |
| `Configuracao_Inicial.frx` | `94773eb` — release prepare V12.0.0203 rc4 | Linha V203 fechada e herdada por V204/V205. |
| `Menu_Principal.frx` | `94773eb` — release prepare V12.0.0203 rc4 | Linha V203 fechada e herdada por V204/V205. |
| `Repo_Avaliacao.bas` | `66e93ea` — fix smoke DT_ULT_REATIV | Onda 22/V204 dados legados, docs em `auditoria/03_ondas/onda_22_v204_dados_legados/`. |
| `Repo_Credenciamento.bas` | `94773eb` — release prepare V12.0.0203 rc4 | Linha V203 fechada e herdada por V204/V205. |
| `Repo_Empresa.bas` | `b8013f7` — invalid DT_ULT_REATIV strikes | Onda 22/V204 dados legados, docs em `auditoria/03_ondas/onda_22_v204_dados_legados/`. |
| `Repo_OS.bas` | `c1d8a78` — CAD_OS orphan refs | Onda 22/V204 dados legados, docs em `auditoria/03_ondas/onda_22_v204_dados_legados/`. |
| `Repo_PreOS.bas` | `94773eb` — release prepare V12.0.0203 rc4 | Linha V203 fechada e herdada por V204/V205. |
| `Svc_Avaliacao.bas` | `fb929b8` — release V12.0.0204 | Release V204 publicada e herdada pela V205. |
| `Svc_Entidade.bas` | `7420090` — Onda 20 UI reactivation guards | Onda 20/V204, docs em `auditoria/03_ondas/onda_20_v204_p0_ui/`. |
| `Svc_OS.bas` | `7a9d23d` — cumulative OS package | Onda 21/V204 transacional, docs em `auditoria/03_ondas/onda_21_v204_transacional/`. |
| `Svc_PreOS.bas` | `94773eb` — release prepare V12.0.0203 rc4 | Linha V203 fechada e herdada por V204/V205. |
| `Svc_Rodizio.bas` | `62edfb3` — Onda 21 status persistence | Onda 21/V204 transacional, docs em `auditoria/03_ondas/onda_21_v204_transacional/`. |
| `Svc_Transacao.bas` | `87e49ac` — reject nested transactions | Onda 21/V204 transacional, docs em `auditoria/03_ondas/onda_21_v204_transacional/`. |
| `Teste_Bateria_Oficial.bas` | `94773eb` — release prepare V12.0.0203 rc4 | Linha V203 fechada e herdada por V204/V205. |
| `Teste_UI_Guiado.bas` | `844361e` — Onda 6 hotfix de sincronizacao | Onda 6 encerrada em `.hbn/relay/INDEX.md` e `.hbn/results/0001-exec-onda06.json`. |
| `Teste_V2_Engine.bas` | `fb929b8` — release V12.0.0204 | Release V204 publicada e herdada pela V205. |
| `Teste_V2_Roteiros.bas` | `3165549` — production audit V205 | Auditoria final V205 em `auditoria/00_status/80_AUDITORIA_FINAL_POSITIVA_V205_CLAUDE_OPUS.md`. |
| `Teste_Validacao_Release.bas` | `3165549` — production audit V205 | Auditoria final V205 em `auditoria/00_status/80_AUDITORIA_FINAL_POSITIVA_V205_CLAUDE_OPUS.md`. |
| `Treinamento_Painel.bas` | `844361e` — Onda 6 hotfix de sincronizacao | Onda 6 encerrada em `.hbn/relay/INDEX.md` e `.hbn/results/0001-exec-onda06.json`. |
| `Util_Config.bas` | `fb929b8` — release V12.0.0204 | Release V204 publicada e herdada pela V205. |
| `Util_Conversao.bas` | `844361e` — Onda 6 hotfix de sincronizacao | Onda 6 encerrada em `.hbn/relay/INDEX.md` e `.hbn/results/0001-exec-onda06.json`. |
| `Variaveis.bas` | `94773eb` — release prepare V12.0.0203 rc4 | Linha V203 fechada e herdada por V204/V205. |

## Conclusao

Nao houve `drift_inesperado_investigar`. O risco operacional imediato esta
concentrado nos tres arquivos `drift_md33_descartar`. Os 25 demais exigem
analise fina porque podem indicar que a V5 foi exportada de workbook
intermediario, nao necessariamente que `src/vba/` esteja errado.
