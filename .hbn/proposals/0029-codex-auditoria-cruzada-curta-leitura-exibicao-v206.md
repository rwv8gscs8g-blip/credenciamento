---
titulo: Auditoria cruzada curta - Onda 38.2.7 leitura e exibicao
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0205
data: 2026-05-31
---

# Auditoria cruzada curta - Onda 38.2.7

## Veredito

Sem bloqueador local identificado para importar o delta
`ONDA38_2_7_LEITURA_EXIBICAO`, condicionado a compile manual limpo e
`TV2_RunLeituraExibicao` com `OK=5 | FALHA=0 | MANUAL=0`.

## Conferencias

- `Menu_Principal.C_Lista_Click` agora atualiza os campos visiveis que antes so
  eram populados no duplo clique de edicao.
- `EntidadeLista_MontarColumnWidths` e `EmpresaLista_MontarColumnWidths`
  mostram ID antes do CNPJ sem alterar `.frx`.
- `PreencherPreencheOS` aceita filtro opcional e o dispatcher do contexto `os`
  passa o termo do `TextBox19`.
- A suite dirigida adicionada em `Teste_V2_Roteiros.bas` valida os tokens
  necessarios sem executar baseline canonico V2, evitando sobrescrever
  municipio/gestor da aba `CONFIG`.

## Ressalvas

- Os PDFs anexos mostram problemas reais de layout/bordas e campo de empenho
  estreito; isso fica fora da 38.2.7 e deve ter readback proprio.
- O retorno para `Municipio de Testes V2` foi rastreado ao baseline V2 em
  `Teste_V2_Engine.bas`; a correcao exige onda CONFIG/FT-11, fora do escopo
  deste delta.
- O worktree ja continha arquivos sujos de ondas anteriores; esta auditoria
  avalia apenas os arquivos permitidos pelo readback 0123.
