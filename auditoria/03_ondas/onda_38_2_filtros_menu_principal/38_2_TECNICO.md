---
titulo: Onda 38.2 — Filtros do Menu Principal
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-25
---

# Onda 38.2 — Filtros do Menu Principal

## Contexto

Após a estabilização dos relatórios da Onda 38.1.5, Mauricio solicitou
verificação tela a tela dos filtros visíveis na interface antes de avançar para
o motor de PDF automático. Os prints foram fornecidos em
`local-ai/incoming/filtros/` e usados somente como evidência read-only.

O diagnóstico confirmou que o `Menu_Principal.frm` tinha handlers
`mTxtFiltro*_Change`, mas não tinha declarações `Private WithEvents` para esses
ponteiros. Sem a declaração, o vínculo de evento fica implícito/inconfiável e
os filtros podem não responder.

## Mapeamento confirmado

| Tela no Menu Principal | Controle confirmado |
|---|---|
| Cadastro de Entidades | `TextBox16` |
| Cadastro de Empresas | `TextBox17` |
| Atribuição de Serviço | `TextBox18` |
| Emite Solicitação de Serviço | `TextBox19` |
| Avaliação / Encerramento | `TextBox20` |
| Cadastro e Alteração de Serviço | `TextBox21` |
| Atribuição de Empresa | `TextBox22` |

Também foram observados filtros em `Cadastro_Servico.frm`,
`Credencia_Empresa.frm`, `Reativa_Empresa.frm` e `Reativa_Entidade.frm`. Esses
forms ficam como limpeza posterior porque a Onda 38.2 foca o menu e evita tocar
outros `.frm` antes do refatoramento V207.

## Implementação

- `Menu_Principal.frm`
  - Adiciona `Private WithEvents` para os sete ponteiros de filtro do menu.
  - Vincula explicitamente `TextBox16` a `TextBox22`, mantendo nomes canônicos
    como primeira tentativa e nomes legados como fallback.
  - Mantém `TextBox17_Change` como fallback legado, mas evita double-call quando
    `mTxtFiltroEmpresa` já está vinculado.
  - Adiciona handlers para `mTxtFiltroPreOS_Change` e
    `mTxtFiltroAvaliacao_Change`.

- `Preencher.bas`
  - `PreencherPreencheOS(Optional filtro As String = "")` passa a filtrar a
    lista `OS_Lista` quando chamado com termo.
  - `PreencherAvaliarOS(Optional filtro As String = "")` passa a filtrar a
    lista `AV_Lista` quando chamado com termo.
  - Chamadas sem argumento preservam comportamento anterior.

- `App_Release.bas`
  - `APP_BUILD_IMPORTADO = "a6ad842+ONDA38.2-filtros-menu"`.

## Fora do escopo

- Nenhum `.frx` foi tocado.
- Nenhum controle foi renomeado no VBE.
- Nenhum serviço blindado (`Svc_*`) foi tocado.
- Não houve alteração de regra de negócio, cálculo ou contador RVS.

## Débitos registrados para V207

- Remover heurísticas de descoberta de filtros por posição visual:
  `UI_PegarTextBoxBuscaTopoDireita` e `UI_PegarTextBoxBuscaDaLista`.
- Trocar controles `TextBox16` etc. por nomes canônicos no designer quando o
  refatoramento permitir tocar `.frx` de forma controlada.
- Mapear botões encontrados por caption (`UI_EncontrarBotaoPorTextos`) para
  ponteiros explícitos.
- Reduzir `CallByName` em fluxos de UI por adapters/presenters tipados.
- Executar passagem final antes do freeze V206: tela a tela, botão a botão,
  validando filtros, comandos e pontos candidatos à V207.

## Gate humano esperado

1. Importar somente via delta:
   `ImportarPacoteV3_Delta "ONDA38-2-FILTROS-MENU", "a6ad842+ONDA38.2-filtros-menu"`.
2. Compilar no VBE.
3. Rodar `CT_ValidarRelease_TrioMinimo`.
4. Testar no Menu Principal os filtros `TextBox16` a `TextBox22`.
