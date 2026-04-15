# Prompt para OpenAI Codex / Claude Sonnet

Copiar TODO o conteudo abaixo e colar como prompt.

---

## PASSO 0 — GITHUB (executar primeiro se o repositorio nao existir)

O repositorio remoto precisa ser criado/configurado. Execute:

```bash
cd ~/Desktop/Credenciamento   # ou onde estiver a pasta do projeto

# Verificar se gh CLI esta instalado
gh --version || brew install gh

# Autenticar (se necessario)
gh auth login

# Criar repositorio (se nao existir)
gh repo create credenciamento --public --source=. --remote=origin --push

# Ou se o repo ja existe mas o remote esta errado:
git remote set-url origin https://github.com/SEU_USUARIO/credenciamento.git
git push origin main --tags
```

Se o push funcionar, prossiga para o Passo 1.

---

## PASSO 1 — CONTEXTO DO PROJETO

Sistema Excel VBA (.xlsm) de gestao de credenciamento municipal. Fonte de verdade: `vba_export/`.

**Linha atual de trabalho:** V12.0.0140
**Observacao:** a linha V12 avancou muito alem do baseline 0111. Antes de editar qualquer arquivo, ler:
- `obsidian-vault/arquitetura/Release-Compilacao.md`
- `obsidian-vault/arquitetura/Roadmap-Estabilizacao-V12.md`
- `obsidian-vault/handoff/Handoff-V12-Estabilizacao-2026-04-12.md`
- release notes mais recentes em `obsidian-vault/releases/`
**Modulos/Formularios:** conferir sempre o estado real em `vba_export/`; nao confiar nesta contagem do prompt sem validar no repositorio.

## PASSO 2 — REGRAS ABSOLUTAS

1. Trabalhar com UM change-set coeso por iteracao
2. NUNCA usar `Dim x As T: x = valor` na mesma linha — SEMPRE separar em duas linhas
3. NUNCA usar MkDir, Kill, Dir() nativo
4. NUNCA renomear Attribute VB_Name
5. NUNCA remover funcoes/subs Public existentes
6. Preferir chamadas qualificadas, mas respeitar a compatibilidade real do workbook.
   Observacao critica: este projeto ja apresentou erro de compilacao com chamadas como `Preencher.AlgumaRotina` dentro de formularios.
   Se o compilador destacar `Metodo ou membro de dados nao encontrado` em modulo padrao qualificado, usar chamada direta.
7. Apos cada iteracao: rodar checklist, regenerar `vba_import/` e compilar no Excel

**Change-set padrao permitido:**
- arquivo funcional principal
- `App_Release.bas` quando houver bump de versao ou ajuste de metadata
- release note/documentacao operacional
- artefatos gerados em `vba_import/`

## PASSO 3 — CHECKLIST (rodar antes de entregar cada arquivo)

```bash
cd Credenciamento/
grep -rn "Dim .* As .*:.*=" vba_export/*.bas vba_export/*.frm     # DEVE ser VAZIO
grep -rn "MkDir\|^\s*Kill \| Dir(" vba_export/*.bas vba_export/*.frm  # DEVE ser VAZIO
grep -rh "Attribute VB_Name" vba_export/*.bas vba_export/*.frm | sort | uniq -d  # DEVE ser VAZIO
```

## PASSO 4 — FOCO ATUAL

O roteiro atual nao e mais o pacote inicial de 0108-0110. O foco atual e:

1. estabilizacao estrutural de `ATIVIDADES` e `CAD_SERV`
2. persistencia da baseline CNAE na planilha
3. associacao manual de servicos aos CNAEs
4. filtros e listas do `Menu_Principal`
5. manutencao da bateria oficial com zero falhas

### Regra de negocio critica

- `ATIVIDADES` = baseline estrutural permanente de CNAEs
- `CAD_SERV` = associacao manual de servicos aos CNAEs

Nao auto-gerar servicos em `CAD_SERV` a partir de `ATIVIDADES`.

## PASSO 5 — HISTORICO INICIAL (legado)

### V12.0.0108 — Filtro de busca em Reativa_Empresa.frm

**Objetivo:** Adicionar campo de busca incremental (TextBox) que filtra a ListBox de empresas inativas em tempo real.

**Arquivo a modificar:** `vba_export/Reativa_Empresa.frm`

**Referencia:** O arquivo `obsidian-vault/backlog/reference-code/Reativa_Empresa_V105_com_filtro.frm` contem uma versao anterior que JA TINHA o filtro funcionando. Use como referencia para extrair APENAS o codigo de filtro. As diferencas principais sao:

1. Declaracao de variavel `Private WithEvents mTxtBusca As MSForms.TextBox`
2. Funcao `UI_TextBoxSeExiste` que busca controle por nome
3. Funcao `UI_PegarTextBoxBuscaTopoDireita` que localiza o TextBox de busca
4. No `UserForm_Initialize`: inicializar mTxtBusca e popular a lista
5. Evento `mTxtBusca_Change`: filtrar RM_Lista com base no texto digitado

**ATENCAO:** O TextBox de busca deve ser adicionado visualmente no form designer do VBA Editor (nao pode ser criado por codigo). O codigo VBA apenas CONECTA ao controle existente via `WithEvents`. Instrucao para o usuario: antes de importar o .frm, garantir que o form tem um TextBox no topo.

**Como implementar:**
1. Ler o arquivo atual `vba_export/Reativa_Empresa.frm`
2. Ler o arquivo de referencia com filtro
3. Adicionar APENAS o codigo de filtro ao form atual, sem alterar a logica existente
4. NAO alterar o header do form (VERSION, Begin...End, Attributes)
5. Manter toda a logica original de RM_Lista_DblClick intacta
6. Rodar checklist
7. Criar release note `obsidian-vault/releases/V12.0.0108.md`
8. Git: `git add vba_export/Reativa_Empresa.frm && git commit -m "feat(v12.0.0108): filtro busca Reativa_Empresa" && git tag v12.0.0108`

**Compilacao:** Apos importar no Excel, Depurar > Compilar. Se der erro, reverter IMEDIATAMENTE com `git checkout v12.0.0107 -- vba_export/Reativa_Empresa.frm`

---

### V12.0.0109 — Filtro de busca em Reativa_Entidade.frm

Mesma logica de V12.0.0108, mas para `Reativa_Entidade.frm`.
Referencia: `obsidian-vault/backlog/reference-code/Reativa_Entidade_V105_com_filtro.frm`
ListBox: `R_Lista` (entidades inativas)

---

### V12.0.0110 — Filtro de busca em Cadastro_Servico.frm

Mesma logica, para `Cadastro_Servico.frm`.
Referencia: `obsidian-vault/backlog/reference-code/Cadastro_Servico_V105_com_filtro.frm`
ListBox: `SV_Lista` (servicos/atividades)

---

## TIPOS DISPONIVEIS (em Mod_Types.bas, NAO redefinir)

TResult, TConfig, TEmpresa, TEntidade, TCredenciamento, TPreOS, TOS, TAvaliacao, TAtividade, TServico, TRodizioResultado, TAppContext

## FUNCOES DISPONIVEIS PARA PREENCHER LISTAS

- `PreenchimentoEmpresa_Inativo` — popula lista de empresas inativas (Preencher.bas)
- `PreenchimentoEntidadeInativa` — popula lista de entidades inativas (Preencher.bas)
- `PreenchimentoServico` — popula lista de servicos (Preencher.bas)
- `ControleFormulario(nomeForm, nomeControle)` — localiza controle em form (Preencher.bas)
- `UltimaLinhaAba(nomeAba)` — retorna ultima linha com dados (Util_Planilha.bas)

## GIT APOS CADA ITERACAO

```bash
git add vba_export/ARQUIVO_MODIFICADO
git commit -m "feat(vXX.X.XXXX): descricao"
git tag v12.0.XXXX
git push origin main --tags
```
