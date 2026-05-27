---
titulo: Codex AT-1 — gerador code-only preserva declaracoes WithEvents
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Codex AT-1 — gerador code-only

## 1. Veredito

GATE-A1 pronto para auditoria cruzada.

O BLOQUEADOR P0-1 da auditoria Codex 0012 foi tratado no gerador: `local-ai/scripts/publicar_vba_import_v2.py` agora deriva `.code-only.txt` cortando o `.frm` após `Attribute VB_Exposed`, preservando declarações module-level e atributos per-symbol como `Attribute mTxtBuscaTopo.VB_VarHelpID = -1`.

## 2. Mudanças

- `gerar_code_only_txt` deixa de procurar apenas a primeira `Sub/Function` como ponto inicial.
- O caminho principal passa a seguir a regra L22: código começa após `Attribute VB_Exposed`.
- O fallback para forms mínimos foi reforçado para aceitar atributos per-symbol durante o scan reverso.
- Foi adicionado `--only <arquivo>` para permitir publish direcionado em microdeltas safe_track.
- Em `apply --only`, o script regenera `.code-only.txt` existente do form processado sem atualizar manifesto/build globais.
- `AAD-Cadastro_Servico.code-only.txt` foi regenerado com `mIgnorarFiltro`, `mTxtBuscaTopo` e o atributo `VB_VarHelpID` preservados.

## 3. Evidência local

Comando executado:

```text
bash local-ai/scripts/publicar_vba_import_v2.sh --apply --only Cadastro_Servico.frm
```

Resultado:

```text
[applied] 1 arquivo(s):
  AAD-Cadastro_Servico.frm (code_only_gen)
```

Paridade gamma pós-AT-1:

| Métrica | Valor |
|---|---:|
| `gamma_equal` | `True` |
| `len_frm_gamma` | `9307` |
| `len_co_gamma` | `9307` |

Presença das declarações no code-only:

| Linha | Conteúdo esperado |
|---:|---|
| 1 | `Private mIgnorarFiltro As Boolean` |
| 2 | `Private WithEvents mTxtBuscaTopo As MSForms.TextBox` |
| 3 | `Attribute mTxtBuscaTopo.VB_VarHelpID = -1` |

## 4. Escopo preservado

Nenhum arquivo `src/vba/**` foi alterado.

O publish foi direcionado para `Cadastro_Servico.frm` para não regenerar outros forms fora do readback 0114. A medição prévia detectou que um algoritmo "corrigir todos os code-only existentes" também afetaria `AAB-ProgressBar.code-only.txt` e `AAI-Credencia_Empresa.code-only.txt`; esses arquivos ficaram fora do escopo e não foram tocados nesta entrega.

## 5. Riscos para auditores

- `local-ai/` é ignorado por `.gitignore`; para commit local do GATE-A1, os arquivos de pacote/script precisarão de `git add -f` ou de uma decisão operacional equivalente.
- O Importador V3 já limpa linhas `Attribute ...` antes de `AddFromString`; manter atributos per-symbol no `.code-only.txt` é coerente com o comparador gamma e com os code-only existentes de outros forms.
- O `--only` é deliberadamente conservador: evita tocar manifesto/build em microdelta, mas não substitui o publish completo quando uma onda precisar sincronizar todo o pacote.

## 6. Próxima ação

Mauricio deve levar esta entrega para Opus + Antigravity em chats novos, usando o template §12.A. Codex só deve prosseguir para AT-2 após a auditoria cruzada do GATE-A1 e hearback consolidado.
