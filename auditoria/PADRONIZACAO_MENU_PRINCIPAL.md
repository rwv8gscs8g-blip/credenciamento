# Padronização — `Menu_Principal` (plano mestre)

**Versão de referência:** V12.0.0173  
**Objetivo:** uma única convenção de **(Name)** no designer, alinhada ao **VBA**, sem heurísticas fantasma, pronta para GitHub e para evolução dos demais formulários.

---

## 1. Por que este documento existe

- O **Caption** é o texto para o usuário; o **(Name)** é o contrato com o código.
- Hoje ainda coexistem **`TextBox16` / `TextBox17` / …**, fallbacks **`TxtFiltro*Din`** criados com `Controls.Add`, e **`WithEvents` declarados mas não ligados** (`mTxtFiltroRodizio`, `mTxtFiltroServico`) — isso gera duplicidade de eventos e dificulta manutenção.
- Este arquivo é o **roteiro página a página**. Marque cada linha quando concluir no VBA Editor + **Compilar**.

---

## 2. Convenção proposta (obrigatória após a faxina)

| Tipo | Padrão | Exemplos |
|------|--------|----------|
| MultiPage | `PAGINAS` | (manter) |
| Página (tab) | `Pag_<Área>` | `Pag_Inicio`, `Pag_Entidade`, `Pag_Empresa`, `Pag_Rodizio`, `Pag_ImprimeOS`, `Pag_Avaliacao`, `Pag_CadServ`, `Pag_Relatorios` | ok
| Lista principal | `LST_<contexto>` ou nome já estável | `C_Lista`, `EMP_Lista`, `A_Lista`, `H_Lista`, `OS_Lista`, `AV_Lista` — **não** voltar a `M_Lista` |
| Filtro (busca) | `TxtFiltro_<Contexto>` | Ver tabela §5 |
| Label de filtro | `LblFiltro_<Contexto>` | `LblFiltro_Empresa` |
| Botões de barra | `B_<ação>` | `B_Empresa_Cadastro`, `B_Relatorios`, … |
| Botões físicos Pre-OS/OS | `BT_<contexto>_<ação>` | `BT_PREOS_REJEITAR`, `BT_OS_CANCELAR` |
| Relatório OS por empresa | `Btn_Rel_OS_Empresa` | (já alinhado na V12.0.0170) |
| Campo nome empresa (OS) | `TXT_OS_NomeEmpresa` | (já alinhado) |

**Regra:** um **(Name)** por controle; nunca dois controles com o mesmo nome.

### 2.1 Captions: ASCII nas abas do MultiPage (política opcional)

Em alguns ambientes (VBA no Mac, versões específicas do Excel), editar **Caption** de páginas do `MultiPage` com **acentos** (ex.: `Rodízio`, `Relatórios`) pode **instabilizar o IDE** (fechamento do Excel). O **`(Name)`** das páginas (`Pag_Rodizio`, etc.) já é interno e não depende de acento.

- **Política recomendada para estabilidade:** manter **Caption** das **abas** em **ASCII** (sem acentos): `Rodizio`, `Relatorios`, `Avaliacao`, …  
- **Onde usar PT-BR com acento com segurança:** títulos **grandes** dentro da página (labels azuis, textos explicativos), testando **um controle por vez** se notar crash ao salvar.

Isso não substitui a convenção de **(Name)**; é só uma regra de **produção segura** no designer.

---

## 3. Mapa do `PAGINAS` (índice → uso)

| `PAGINAS.Value` | Área funcional | Navegação (sidebar) | Notas |
|-----------------|----------------|---------------------|--------|
| 0 | Tela inicial | `B_Home` | Atalhos / treinamento |
| 1 | Entidade | `B_Entidade` | Lista `C_Lista`; filtro **`TxtFiltro_Entidade`** (fix busca **Me**, V12.0.0173) |
| 2 | Empresas | `B_Empresa_Cadastro` | Lista `EMP_Lista` |
| 3 | Rodízio / atribuição | `B_Empresa_Rodizio` | Listas atividade/serviço/entidade rodízio; filtros `TextBox18`, `TextBox22` |
| 4 | Pré-OS / OS | `B_Emite_OS` | `OS_Lista`, `TXT_OS_NomeEmpresa`, ações `BT_*` |
| 5 | Avaliação de OS | `B_Empresa_Avaliacao` | `AV_Lista` |
| 6 | Cadastro de serviços (manutenção) | `B_CAD_SERV` | `H_Lista` |
| 7 | Relatórios | `B_Relatorios` | Botões `Btn_*`; `Btn_Rel_OS_Empresa` |

---

## 4. Roteiro página a página

Para cada página: **Design** → selecionar controle → **F4** → **(Name)** / **Caption** → **Depurar > Compilar**.

### 4.1 Tela inicial (`PAGINAS` = 0)

| Ação | Controles típicos | Status |
|------|-------------------|--------|
| Revisar captions | Botões de apoio (`BT_SOBRE`, `BT_GITHUB`, `BT_CENTRAL_TESTES`, …) | ☐ |
| Nome já sem `CommandButton1` genérico | | ☐ |

### 4.2 Entidade (`PAGINAS` = 1) — em foco

**Padrão do filtro:** **(Name)** = **`TxtFiltro_Entidade`** (Legado: `TextBox16` aceito temporariamente — V12.0.0177) (evento efetivo: `mTxtFiltroEntidade_Change`; `TextBox16_Change` removido no código).

| (Name) | Proposta | Status |
|--------|----------|--------|
| `Pag_Entidade` | `Pag_Entidade` | ☐ Caption conforme §2.1 |
| `C_Lista` | manter | Lista principal |
| `TextBox16` | renomear para **`TxtFiltro_Entidade`** | ☐ no designer |
| Label do filtro | `LblFiltro_Entidade` (se existir; legado `LblFiltroEntDin`) | ☐ |

#### O que o filtro de Entidade pesquisa (contrato)

O texto digitado em **`TxtFiltro_Entidade`** filtra a lista `C_Lista` verificando ocorrência (normalizado em maiúsculas) em:

- **ID da Entidade** (`COL_ENT_ID`)
- **CNPJ** (`COL_ENT_CNPJ`)
- **Nome da Entidade** (`COL_ENT_NOME`)
- **Celular da Entidade** (`COL_ENT_TEL_CEL`) — útil para buscar pelo DDD/WhatsApp
- **Nome do Contato 1** (`COL_ENT_CONT1_NOME`)
- **Telefone do Contato 1** (`COL_ENT_CONT1_FONE`) — útil para busca por WhatsApp

**Campos de edição (prefixo `C_` — conferir nomes e TabOrder):**

| Uso | (Name) típico no código |
|-----|-------------------------|
| CNPJ, nome, telefones, e-mail, endereço | `C_CNPJ`, `C_Entidade`, `C_Tel_Fixo`, `C_Tel_Cel`, `C_Email`, `C_Endereco`, `C_Bairro`, `C_Municipio`, `C_CEP`, `C_UF` |
| Contatos 1–3 | `C_Contato1`…`C_Func_Cont3` |
| Info adicional | `C_InfoAD` |
| Ações | `B_ReativaEntidade` (se aplicável), botão cadastro entidade |

**Próximos passos nesta aba:** após renomear o filtro no designer → **Compilar** → testar busca na lista + abrir `Altera_Entidade` pelo duplo clique. Só então marcar a aba Entidade como “fechada” e ir para **Empresas** (§4.3).

**Bug corrigido (V12.0.0173):** o código procurava o filtro só dentro de `C_Lista.Parent`; o `TxtFiltro_Entidade` no cabeçalho ficava **fora** dessa subárvore → evento não disparava. Agora a busca começa em **`Me`** (form inteiro).

### 4.3 Empresas (`PAGINAS` = 2)

| (Name) atual / fallback | Proposta **(Name)** | Função |
|---------------------------|---------------------|--------|
| `EMP_Lista` | `EMP_Lista` *(manter)* | Lista de empresas |
| `TextBox17` | **`TxtFiltro_Empresa`** | Filtro de busca |
| `TxtFiltroEmpresaDin` | Unificar com o físico | Ver §6 |
| Campos `M_*` cadastro | Já padronizados (`M_CNPJ`, `M_Empresa`, …) | ☐ conferir |

### 4.4 Rodízio (`PAGINAS` = 3)

| (Name) atual | Proposta **(Name)** | Função |
|--------------|---------------------|--------|
| `TextBox18` | **`TxtFiltro_Servico`** (ou `TxtFiltro_AtividadeServico`) | Filtro serviço — usado em `AplicarFiltrosAtribuicao` / `PreenchimentoServico` |
| `TextBox22` | **`TxtFiltro_EntidadeRodizio`** | Filtro entidade no contexto rodízio — `PreenchimentoEntidadeRodizio` |
| `C_ListaRodizio` | manter ou `LST_Rodizio` | Definir um só padrão em iteracao futura |

### 4.5 Imprime OS (`PAGINAS` = 4)

| (Name) | Proposta | Nota |
|--------|----------|------|
| `OS_Lista` | manter | |
| `TXT_OS_NomeEmpresa` | manter | Não reutilizar `OS_Empresa` para botão |
| `BT_PREOS_*`, `BT_OS_*` | manter | Botões físicos |

### 4.6 Avaliação (`PAGINAS` = 5)

| Controle | Ação |
|----------|------|
| `AV_Lista` | Conferir **(Name)** e colunas |

### 4.7 Cadastro / manutenção de serviços (`PAGINAS` = 6)

| (Name) atual / fallback | Proposta **(Name)** | Função |
|---------------------------|---------------------|--------|
| `H_Lista` | manter ou `LST_CadServ` | Lista CNAE/serviço |
| `TxtFiltroCadServDin` | **`TxtFiltro_CadServ`** | Unificar |

### 4.8 Relatórios (`PAGINAS` = 7)

| Controle | Ação |
|----------|------|
| `Btn_Empresas_Cadastradas`, … | Conferir prefixo `Btn_Rel_*` ou `Btn_*` único |
| `Btn_Rel_OS_Empresa` | Já padrão para relatório OS por empresa |

---

## 5. Tabela objetiva — filtros (estado → alvo)

| Local | Name hoje (código) | Name alvo | Arquivos a atualizar após renomear no designer |
|-------|-------------------|-----------|-----------------------------------------------|
| Entidade | (legado removido) | **`TxtFiltro_Entidade`** | **Determinístico (V12.0.0174):** sem fallback/heurística. Se faltar o controle no designer, o menu acusa erro. |
| Empresa | `TextBox17`, `TxtFiltroEmpresaDin` | `TxtFiltro_Empresa` | Idem + `AtualizarListaEmpresaMenuAtual` |
| Rodízio | `TextBox18` | `TxtFiltro_Servico` | `AplicarFiltrosAtribuicao`, `TextBox18_Change` |
| Rodízio | `TextBox22` | `TxtFiltro_EntidadeRodizio` | `TextBox22_Change` |
| Cad serviços | `TxtFiltroCadServDin` | `TxtFiltro_CadServ` | `Filtros_CriarDinamico`, `mTxtFiltroCadServ_Change` |

**Labels:** `LblFiltroEmpDin` → `LblFiltro_Empresa`; `LblFiltroEntDin` → `LblFiltro_Entidade`; `LblFiltroCadServDin` → `LblFiltro_CadServ`.

---

## 6. Dívida técnica a eliminar (próximas iterações de código)

1. **`Filtros_CriarDinamico`:** deixar de criar `TextBox`/`Label` em runtime quando o físico existir com nome definitivo; reduzir `Controls.Add`.
2. **Handlers duplicados:** `TextBox16_Change` removido (Entidade). Ainda existem `mTxtFiltroEmpresa_Change` **e** `TextBox17_Change` — após renomear filtro Empresa, eliminar duplicata.
3. **`mTxtFiltroRodizio` / `mTxtFiltroServico`:** declarados com `WithEvents` e **não atribuídos** em `Filtros_CriarDinamico` — remover ou ligar a `TxtFiltro_Servico` / `TxtFiltro_EntidadeRodizio` após renomear.
4. **`UI_EncontrarBotaoPorTextos`:** mapear usos restantes; substituir por **(Name)** fixo onde possível (`obsidian-vault/ai/mapeamento-botoes.md`).

---

## 7. Integração código ↔ documentação

| Artefato | Função |
|----------|--------|
| `vba_export/Menu_Principal.frm` | Fonte de verdade do comportamento |
| `vba_export/Preencher.bas` | `ControleFormulario`, `AtualizarLista*`, `PreenchimentoEmpresa` |
| Este arquivo | Checklist de **(Name)** e ordem de execução |
| `obsidian-vault/ai/mapeamento-botoes.md` | Histórico heurística → físico (atualizar ao fechar tarefas) |

**Correção V12.0.0171:** `PreenchimentoEmpresa` passou a usar `EMP_Lista` (antes referenciava `M_Lista` fantasma).

**Correção V12.0.0172:** filtro Entidade — nome canônico **`TxtFiltro_Entidade`**; fallback legado `TextBox16` / `TxtFiltroEntidadeDin`; criação dinâmica usa `TxtFiltro_Entidade` + `LblFiltro_Entidade`.

**Correção V12.0.0173:** ligação do filtro — busca recursiva a partir de **`Me`**, não só `C_Lista.Parent` (filtro no cabeçalho). **`Reativa_Entidade`:** nome sugerido **`TxtFiltro_ReativaEntidade`**.

---

## 8. Próximo alvo após `Menu_Principal`

Ordem sugerida: `Altera_Empresa` → `Credencia_Empresa` → `Reativa_Empresa` → `Cadastro_Servico` → `Rel_*` → demais.

Para cada um: mesmo método — inventário **(Name)**, proposta, um PR/commit por form.

---

## 9. Exportação para o repositório (`incoming/vba-forms`)

| Quando exportar | O quê |
|-----------------|-------|
| Ao **concluir** um lote de renomeações no designer **e** compilar sem erros | `Menu_Principal.frm` + `Menu_Principal.frx` |
| Opcional | Copiar para `incoming/vba-forms/` para o Cursor incorporar em `vba_export/` |
| **Sempre** após aceitar o pacote no Git | Rodar `scripts/publicar_vba_import.sh` para atualizar `vba_import/` |

**Sim:** ao final de cada marco estável (Menu inteiro padronizado), **exporte** para `incoming/vba-forms` e avise no commit para manter Excel ↔ repo alinhados.

---

## 10. Aparência (UI definitiva)

- Depois que **(Name)** estiver estável: revisar **alinhamento**, **fontes**, **tab order**, **Larguras de coluna** (`ColumnWidths`) por lista, e **ícones** dos botões de barra.
- Evitar sobrescrever **Caption** em massa no `UserForm_Initialize` (preferir designer).

---

**Checklist rápido de sessão**

1. Backup do `.xlsm`.  
2. Renomear lote (uma página).  
3. Compilar.  
4. Testar fluxo da página.  
5. Exportar `.frm`/`.frx` → `incoming/vba-forms` → merge no repo.  
6. Marcar seções neste documento.
e avise no commit para manter Excel ↔ repo alinhados.

---

## 10. Aparência (UI definitiva)

- Depois que **(Name)** estiver estável: revisar **alinhamento**, **fontes**, **tab order**, **Larguras de coluna** (`ColumnWidths`) por lista, e **ícones** dos botões de barra.
- Evitar sobrescrever **Caption** em massa no `UserForm_Initialize` (preferir designer).

---

**Checklist rápido de sessão**

1. Backup do `.xlsm`.  
2. Renomear lote (uma página).  
3. Compilar.  
4. Testar fluxo da página.  
5. Exportar `.frm`/`.frx` → `incoming/vba-forms` → merge no repo.  
6. Marcar seções neste documento.
