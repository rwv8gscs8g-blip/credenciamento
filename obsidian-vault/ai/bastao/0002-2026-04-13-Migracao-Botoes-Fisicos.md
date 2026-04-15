---
titulo: "Migracao de Botoes Heuristicos para Fisicos"
data: 2026-04-13
autor: "IA (Cursor)"
versao-sistema: V12.0.0149
status: EM_ANDAMENTO
---

## Objetivo

Eliminar criacao de botoes por heuristica (runtime) e vincular todas as acoes a botoes fisicos do `Menu_Principal` (designer do VBA), garantindo simplicidade, rastreabilidade e robustez.

## Escopo inicial (Menu_Principal)

### 1) Botoes hoje criados via `Controls.Add` (devem virar fisicos)

- `BT_PREOS_REJEITAR` (acao: `RejeitarPreOSSelecionada`)
- `BT_PREOS_EXPIRAR` (acao: `ExpirarPreOSSelecionada`)
- `BT_OS_CANCELAR` (acao: `CancelarOSSelecionada`)

### 2) Botoes fisicos hoje ligados por heuristica de Caption (devem virar referencia por Name)

- Credenciar empresa (hoje: busca por caption contendo "CREDENCIA")
- Reativar empresa (hoje: busca por caption contendo "REATIVA" e "EMPRESA")

**Padrao proposto de Name (fixo, rastreavel)**:
- `BT_CREDENCIAR_EMPRESA`
- `BT_REATIVA_EMPRESA`

## Estrategia segura (em etapas)

### Etapa A (segura / retrocompat)

No codigo do `Menu_Principal.frm`:
- tentar ligar primeiro por **Name** (novo padrao)
- se nao existir ainda (designer nao alterado), cair para heuristica atual (caption) / criacao via `Controls.Add`

Resultado esperado: nenhuma regressao; pronto para o humano criar os botoes no designer sem pressa.

### Etapa B (mudanca no designer pelo humano)

No VBE (designer do `Menu_Principal`):
- criar os botoes fisicos com os **Names** acima
- posicionar ao lado dos botoes base (conforme UI atual)
- conferir captions e estilo

Validar: `Debug > Compilar` e exercitar os fluxos Pre-OS/OS.

### Etapa C (limpeza definitiva)

Depois que os botoes fisicos existirem e estiverem validados:
- remover `Controls.Add` e o reposicionamento calculado
- remover busca por caption (e eventualmente as funcoes `UI_EncontrarBotaoPorCaption/Textos`)

## Checklist da iteracao

- [ ] Auditoria: nenhum colon pattern / FileSystem nativo / VB_Name duplicado
- [ ] Codigo em `vba_export/` apenas
- [ ] Publicar deploy via `bash scripts/publicar_vba_import.sh` (gera `vba_import/001-modulo/` + `vba_import/002-formularios/` + manifesto)
- [ ] Importar **formularios** preferencialmente de `vba_import/002-formularios/` (nao confiar em copias soltas em `001-modulo/`)
- [ ] Bump de versao em `vba_export/App_Release.bas`
- [ ] Release note + GOVERNANCA + ESTADO-ATUAL (se houve alteracao de codigo)
- [ ] Importacao manual no VBE apenas dos modulos alterados
- [ ] Debug > Compilar (zero erros)
- [ ] Teste funcional: Pre-OS e OS (acoes aceitar/rejeitar/expirar/cancelar)

## Progresso (2026-04-13)

- Removida a heuristica de criacao dos botoes da Tela Inicial (Central/Sobre/GitHub) em `Menu_Principal.frm` (V12.0.0154).
- Removidos `Controls.Add` / `WithEvents` das acoes Pre-OS/OS (`BT_PREOS_*`, `BT_OS_CANCELAR`) em `Menu_Principal.frm` (V12.0.0155). Botoes devem existir no designer.
- V12.0.0156: export do Excel pode sobrescrever `vba_export` com codigo antigo — reaplicar limpeza no repo; `AlinharCabecalhosListaEmpresa` deixa de alterar captions (fonte unica no designer).

