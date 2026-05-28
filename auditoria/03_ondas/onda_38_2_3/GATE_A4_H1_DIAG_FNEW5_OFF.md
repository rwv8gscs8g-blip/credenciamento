---
titulo: GATE-A4 H1 — FNEW5 Diagnostico Desligado
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# GATE-A4 H1 — FNEW5 Diagnostico Desligado

## Motivo

AT-2 usou instrumentacao temporaria em `Credencia_Empresa` para diagnosticar F-NEW5. Ao abrir GATE-A4, o gate ainda estava ativo:

```vb
Private Const ATIVAR_DIAG_FNEW5 As Boolean = True
```

Isso nao alterava a regra de negocio, mas gerava CSVs diagnosticos durante credenciamentos normais. Para release e uso prolongado, o diagnostico precisa ficar desligado por padrao.

## Alteracao

Alteracao minima aplicada em tres superficies sincronizadas:

- `src/vba/Credencia_Empresa.frm`
- `local-ai/vba_import/002-formularios/AAI-Credencia_Empresa.frm`
- `local-ai/vba_import/002-formularios/AAI-Credencia_Empresa.code-only.txt`

Novo valor:

```vb
Private Const ATIVAR_DIAG_FNEW5 As Boolean = False
```

O codigo diagnostico permanece no modulo para auditabilidade, mas fica inativo. A remocao definitiva pode ser avaliada no pacote QA V3 ou em onda posterior, se for desejavel reduzir bloat antes do freeze.

## Validacao estatica

`rg` confirma o valor `False` nas tres superficies. A Fase 2 do GATE-A4 reimporta `AAI-Credencia_Empresa.frm` em modo estabilizado, usando o `.code-only.txt` sincronizado.
