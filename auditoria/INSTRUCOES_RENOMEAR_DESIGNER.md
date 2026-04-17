# Renomear controles no VBA Designer (guia rápido)

**Versão:** V12.0.0176

## Documento principal

O roteiro completo — **página a página**, **filtros**, **propostas de (Name)** e **plano de integração** com o código — está em:

**[`PADRONIZACAO_MENU_PRINCIPAL.md`](PADRONIZACAO_MENU_PRINCIPAL.md)**

Use este arquivo apenas como **referência operacional** (como clicar no editor).

---

## Passo a passo no Excel / VBA

1. **Alt+F11** → projeto → formulário (ex.: `Menu_Principal`) → **Exibir** → **Objeto** (modo Design).
2. Selecione o controle na superfície do form (lista, caixa de texto, botão).
3. **F4** → janela **Propriedades** → campo **(Name)** → digite o nome acordado em `PADRONIZACAO_MENU_PRINCIPAL.md` → **Enter**.
4. Ajuste o **Caption** se for texto exibido ao usuário (não precisa coincidir com o `(Name)`).
5. **Depurar → Compilar VBAProject** (zero erros).
6. Salvar o `.xlsm`.

---

## O que já foi concluído (Menu — não repetir)

- Barra lateral: `B_Empresa_Cadastro`, `B_Empresa_Rodizio`, `B_Empresa_Avaliacao`, etc.
- Lista de empresas: `EMP_Lista` (substitui `M_Lista`).
- Área OS / relatório: `TXT_OS_NomeEmpresa`, `Btn_Rel_OS_Empresa` (evita crash por nome duplicado).
- Páginas do MultiPage: captions sem “MEI” (ex.: Empresa, Rodizio, Avaliacao) e `(Name)` tipo `Pag_*` conforme seu print.

**Pendente de padronização global:** filtros `TextBox17`/`18`/`22` e fallbacks `TxtFiltro*Din` — ver **§5 e §6** do documento mestre. **Entidade:** no designer, renomear **`TextBox16`** → **`TxtFiltro_Entidade`** (código já aceita — V12.0.0172).

**Captions das abas do MultiPage:** opcionalmente **ASCII** (sem acentos) para evitar instabilidade do IDE — ver **§2.1** em `PADRONIZACAO_MENU_PRINCIPAL.md`.

---

## Exportar para o repositório

Ao fechar um marco estável:

1. Exportar `Menu_Principal.frm` + `Menu_Principal.frx` para **`incoming/vba-forms/`** (ou confiar no merge feito pelo Cursor em `vba_export/`).
2. Garantir **CRLF** e linha em branco final nos `.frm`/`.bas` exportados (regra do projeto).

---

## Outros formulários

Depois do `Menu_Principal`, seguir a mesma metodologia (inventário → proposta → designer → compilar). Nomes legados típicos em **`Altera_Empresa`**: ver secção **Altera_Empresa** no histórico em `PADRONIZACAO_MENU_PRINCIPAL.md` §8 e notas de release anteriores.
