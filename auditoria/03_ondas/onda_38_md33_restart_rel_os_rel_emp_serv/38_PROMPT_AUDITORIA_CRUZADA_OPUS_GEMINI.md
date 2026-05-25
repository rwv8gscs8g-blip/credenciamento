---
titulo: Prompt Auditoria Cruzada — Onda 38 MD33 restart
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-05-25
---

# Prompt para auditoria cruzada Opus + Gemini 3.5 Antigravity

Voce e auditor externo da Onda 38 do Sistema de Credenciamento V12.0.0206.
Audite a implementacao como revisor adversarial, sem editar arquivos.

## Contexto obrigatorio

Leia, nesta ordem:

1. `.hbn/readbacks/0094-onda38-md33-restart-rel-os-rel-emp-serv.json`
2. `auditoria/03_ondas/onda_38_md33_restart_rel_os_rel_emp_serv/38_TECNICO.md`
3. `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-MD33-RESTART.txt`
4. `src/vba/Menu_Principal.frm`
5. `src/vba/Preencher.bas`
6. `src/vba/App_Release.bas`
7. `auditoria/00_status/95_AUDITORIA_PDF_UI_V206_CLAUDE_OPUS.md`
8. `auditoria/00_status/97_CONSOLIDACAO_PDF_UI_V206_CODEX.md`
9. `.hbn/knowledge/0018-uso-delta-vs-completo.md`

Observacao: Codex detectou que o guard ativo por numeracao e o readback 0095
da Onda 36.1, nao o 0094 da Onda 38. Audite tambem se a implementacao deve
receber um readback sucessor 0096 antes de commit/push, para manter
`assert-scope-lock.sh` efetivo.

## Perguntas de auditoria

1. O fix realmente elimina a instancia fantasma dos dois relatorios?
2. A implementacao usa `VBA.UserForms.Add`, nao `New`, nos handlers afetados?
3. `PreenchimentoRelatorioOSEmpresa` deixou de criar fallback invisivel?
4. `PreenchimentoRel_EmpXServ` continua sem criar fallback e agora tem caller
   correto?
5. O delta respeita o scope do readback 0094 e nao toca `Rel_*`, `.frx`,
   `Svc_*`, `Mod_Types` ou `Importador_V3`?
6. O manifesto delta esta correto, pequeno, e tem `AAX-App_Release.bas` como
   ultimo item?
7. Ha risco de `Unload` apos `.Show` fechar imediatamente `Rel_Emp_Serv` caso
   o form seja modeless no workbook? Se sim, classifique severidade e proponha
   mitigacao sem ampliar escopo.
8. Ha qualquer risco de compile VBE em Mac causado por `.frm`/`.frx`,
   `.code-only.txt` ou assinatura das subs?
9. A Onda 38 pode seguir para gate humano de import + compile + TrioMinimo?
10. A governanca HBN permite commit desta implementacao com 0095 como readback
    numericamente ativo, ou deve ser criado/readirecionado um readback 0096?

## Saida esperada

Responda em formato de auditoria:

- `Veredito`: APROVAR / APROVAR COM RESSALVA / BLOQUEAR.
- `P0/P1/P2`: achados com arquivo e linha.
- `Scope`: confirmar diff permitido ou listar vazamento.
- `Import`: confirmar comando delta unico.
- `Gates humanos`: listar exatamente o que Mauricio deve executar.
- `Recomendacao`: se deve corrigir antes do import ou seguir para gate humano.
- `Governanca`: decisao recomendada sobre o conflito 0094/0095 antes de commit.

Nao sugerir `ImportarPacoteV3()` completo. A unica rota permitida e:

```vb
ImportarPacoteV3_Delta "ONDA38-MD33-RESTART", "e43352f+ONDA38.MD33-restart-relatorios"
```
