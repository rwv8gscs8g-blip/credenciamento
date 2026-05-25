---
titulo: Onda 38 — MD33 restart Relatorios OS por Empresa e Empresas por Servico
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-25
---

# Onda 38 — MD33 restart Relatorios

## Contexto

A Onda 38 retoma a correcao MD33 sobre a base V5 limpa validada na Onda
37.4. A auditoria de codigo confirmou que o bug nao estava nos forms
`Rel_OSEmpresa.frm` e `Rel_Emp_Serv.frm`, mas nos handlers de
`Menu_Principal.frm` e no lookup feito por `Preencher.bas`.

## Bug corrigido

- `Btn_Rel_OS_Empresa_Click` chamava `PreenchimentoRelatorioOSEmpresa` antes
  de criar a instancia `Rel_OSEmpresa` exibida.
- `Rel_EmpXServ_Click` chamava `PreenchimentoRel_EmpXServ` antes de criar a
  instancia `Rel_Emp_Serv` exibida.
- `UserForm_Initialize` fazia preaquecimento de
  `PreenchimentoRelatorioOSEmpresa`, podendo criar instancia invisivel.
- `PreenchimentoRelatorioOSEmpresa` podia criar formulario fallback via
  `ControleFormulario(..., True)`.

## Solucao aplicada

- Os dois handlers agora descartam instancia anterior do mesmo form com
  `UI_DescartarFormVisivel`.
- Os dois handlers criam a instancia com `VBA.UserForms.Add`, preservando o
  padrao do projeto e registrando a instancia em `VBA.UserForms`.
- O preenchimento passa a ocorrer depois da criacao da instancia exibida.
- `Rel_EmpXServ_Click` preserva o ciclo de vida legado apos `.Show`, sem
  `Unload` imediato, para evitar fechamento instantaneo caso o form opere como
  modeless no workbook.
- `PreenchimentoRelatorioOSEmpresa` nao cria mais fallback invisivel.
- `PreenchimentoRel_EmpXServ` explicita lookup sem criacao de nova instancia.
- O preaquecimento de `PreenchimentoRelatorioOSEmpresa` no initialize do menu
  foi removido.

## Arquivos alterados

| Arquivo | Papel |
|---|---|
| `src/vba/Menu_Principal.frm` | Corrige ordem dos handlers e remove preaquecimento |
| `src/vba/Preencher.bas` | Evita criacao/lookup incorreto de instancia |
| `src/vba/App_Release.bas` | Carimbo `e43352f+ONDA38.MD33-restart-relatorios` |
| `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38-MD33-RESTART.txt` | Manifesto delta importavel |
| `local-ai/vba_import/001-modulo/AAU-Preencher.bas` | Espelho importavel |
| `local-ai/vba_import/001-modulo/AAX-App_Release.bas` | Espelho importavel |
| `local-ai/vba_import/002-formularios/AAM-Menu_Principal.frm` | Espelho importavel |
| `local-ai/vba_import/002-formularios/AAM-Menu_Principal.code-only.txt` | Code-only gerado |
| `.hbn/readbacks/0096-onda38-md33-restart-rel-os-rel-emp-serv-exec.json` | Readback sucessor para ativar scope-lock |

## Comando de importacao

```vb
ImportarPacoteV3_Delta "ONDA38-MD33-RESTART", "e43352f+ONDA38.MD33-restart-relatorios"
```

Resultado esperado:

```text
M=2 | F=1 | err=0 | skip=0
```

## Gates locais

| Gate | Resultado |
|---|---|
| `bash local-ai/scripts/publicar_vba_import_v2.sh --apply` | OK — 3 arquivos aplicados, G8 OK, G7 OK |
| `bash local-ai/scripts/publicar_vba_import_v2.sh --check` | OK — vba_import 100% sincronizado com src/vba |
| `bash scripts/hbn-guards/hbn-guards-runner.sh` | pendente apos criacao do 0096 |

## Observacao de governanca

O guard `assert-scope-lock.sh` escolhe o ultimo readback numerico em
`.hbn/readbacks/`. Como a Onda 36.1 criou `0095-onda36-1-knowledge-0014-fim-sessao.json`
apos o planejamento da Onda 38, Opus e Gemini/Antigravity recomendaram criar
um readback sucessor para reativar o scope correto.

Resolucao aplicada: `0096-onda38-md33-restart-rel-os-rel-emp-serv-exec.json`
herda o escopo da Onda 38 e passa a ser o readback ativo para commit.

## Gates humanos pendentes

1. Importar pelo comando delta acima.
2. Executar `Depurar > Compilar VBAProject`.
3. Executar `CT_ValidarRelease_TrioMinimo`.
4. Confirmar assinatura preservada: `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0`.
5. Confirmar `RO_Lista` com pelo menos 1 empresa quando ha dados canonicos.
6. Confirmar `SV_CR_Lista` com pelo menos 1 servico quando ha dados canonicos.
7. Durante `Rel_Emp_Serv`, relatar se o menu fica bloqueado ou clicavel para
   registrar se a exibicao efetiva e modal ou modeless no workbook.

## Fora de escopo

- Nenhum `Rel_*.frm` ou `.frx` foi tocado.
- Nenhum servico blindado foi tocado.
- Nenhum contador RVS foi alterado intencionalmente.
- Nenhum PDF foi implementado nesta onda.
