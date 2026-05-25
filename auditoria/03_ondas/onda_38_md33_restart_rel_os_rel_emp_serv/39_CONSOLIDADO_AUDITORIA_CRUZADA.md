---
titulo: Consolidado Auditoria Cruzada — Onda 38 MD33 restart
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-25
---

# Consolidado Auditoria Cruzada — Onda 38

## Veredito consolidado

**Aprovado com ajustes obrigatorios antes de commit/import.** Opus e
Gemini/Antigravity aprovaram o desenho central da correcao: os handlers
precisam criar a instancia via `VBA.UserForms.Add` antes do preenchimento e
`Preencher.bas` nao deve criar fallback invisivel.

## Achados e resolucoes

| Achado | Auditor | Decisao | Status |
|---|---|---|---|
| `Rel_EmpXServ_Click` poderia fechar imediatamente se `.Show` fosse efetivamente modeless e houvesse `Unload` logo apos | Gemini/Antigravity | Remover `Unload frmRelEmpServ` e `Set frmRelEmpServ = Nothing`; preservar lifecycle legado apos `.Show` | Resolvido |
| Guard ativo era `0095`, nao `0094`, por numeracao de readbacks | Opus + Gemini/Antigravity | Criar readback sucessor `0096-onda38-md33-restart-rel-os-rel-emp-serv-exec.json` | Resolvido |
| `37_2_PROCEDIMENTO_IMPORT.md` estava modificado fora do scope 0094 | Opus | Reverter arquivo antes de stage | Resolvido |
| Locks Git vazios `.git/index.lock` e `.git/refs/stash.lock` | Opus | Remover locks; `git stash list` vazio, sem `stash drop` | Resolvido |

## Estado apos ajustes

- `Rel_EmpXServ_Click` mantem `frmRelEmpServ.Show` sem descarregar a instancia
  imediatamente depois.
- `0096` e o readback ativo para permitir que `assert-scope-lock.sh` valide o
  escopo real da Onda 38.
- O vazamento documental da Onda 37.2 foi revertido.
- Locks Git vazios foram removidos.

## Proximo gate

1. Validar espelho com `publicar_vba_import_v2.sh --check`.
2. Rodar `scripts/hbn-guards/hbn-guards-runner.sh` com 0096 ativo.
3. Stagear somente os arquivos permitidos no 0096.
4. Commitar e entregar para gate humano de import/compile/TrioMinimo.

