# Mapeamento de Botoes — Heuristicos vs Fisicos

**Versao**: V12.0.0149
**Objetivo**: Eliminar botoes criados por heuristica e vincular todos aos botoes fisicos do formulario.

---

## BOTOES HEURISTICOS (criados em runtime via Controls.Add)

Estes botoes sao criados programaticamente no UserForm_Initialize e devem ser ELIMINADOS, migrando sua funcionalidade para botoes fisicos existentes ou novos no designer do form.

| # | Nome Variavel | Nome Controle | Caption | Acao | Criado em |
|---|--------------|---------------|---------|------|-----------|
| 1 | mBtnTreino | BT_TREINO_PRINCIPAL | Central de Testes | CT_AbrirCentral() | Treinamento_CriarBotao() |
| 2 | mBtnSobre | BT_SOBRE | Sobre | MsgBox com info sistema | Sobre_CriarBotao() |
| 3 | mBtnGitHub | BT_GITHUB | GitHub | Abre URL do repo | GitHub_CriarBotao() |
| 4 | mBtnPreOSRejeitar | BT_PREOS_REJEITAR | Rejeitar Pre-OS | RejeitarPreOSSelecionada() | InicializarAcoesPreOS() |
| 5 | mBtnPreOSExpirar | BT_PREOS_EXPIRAR | Expirar Pre-OS | ExpirarPreOSSelecionada() | InicializarAcoesPreOS() |
| 6 | mBtnOSCancelar | BT_OS_CANCELAR | Cancelar OS | CancelarOSSelecionada() | InicializarAcoesOS() |

### BOTOES LIGADOS POR HEURISTICA (UI_EncontrarBotaoPorCaption)

Estes botoes EXISTEM fisicamente no form, mas sao localizados em runtime por busca de caption. Devem ser migrados para referencia direta.

| # | Nome Variavel | Busca por Caption | Acao |
|---|--------------|-------------------|------|
| 7 | mBtnCredenciarEmpresa | "CREDENCIA" | Credencia_Empresa_Click() |
| 8 | mBtnReativaEmpresa | "REATIVA" + "EMPRESA" | Abre Reativa_Empresa form |
| 9 | mBtnEmpresaCadastroNav | texto MEI > EMPRESA | Navega para pag. cadastro |
| 10 | mBtnEmpresaRodizioNav | texto MEI > EMPRESA | Navega para pag. rodizio |
| 11 | mBtnEmpresaAvaliacaoNav | texto MEI > EMPRESA | Navega para pag. avaliacao |

**Padrao de migracao (Name fixo recomendado)**:
- Credenciar: `BT_CREDENCIAR_EMPRESA`
- Reativar: `BT_REATIVA_EMPRESA`

---

## BOTOES FISICOS EXISTENTES (form designer)

| # | Nome Controle | Caption | Handler | Pagina |
|---|--------------|---------|---------|--------|
| 1 | B_Home | Home/Inicial | B_Home_Click() | 0 |
| 2 | B_Config_Inicial | Config. Inicial | B_Config_Inicial_Click() | modal |
| 3 | B_Entidade | Entidades | B_Entidade_Click() | 1 |
| 4 | B_MEI (renomeado) | CADASTRA EMPRESA | via mBtnEmpresaCadastroNav | 2 |
| 5 | B_DesignarMEI (renomeado) | INDICA EMPRESA P/ SERVICO | via mBtnEmpresaRodizioNav | 3 |
| 6 | B_Emite_OS | Emite OS | B_Emite_OS_Click() | 4 |
| 7 | B_AvaliaMEI (renomeado) | AVALIA PRESTADOR | via mBtnEmpresaAvaliacaoNav | 5 |
| 8 | B_CAD_SERV | Cad. Servicos | B_CAD_SERV_Click() | 6 |
| 9 | B_Relatorios | Relatorios | B_Relatorios_Click() | 7 |
| 10 | B_PreOS | Emitir Pre-OS | B_PreOS_Click() | acao |
| 11 | B_ReativaEntidade | Reativa Entidade | B_ReativaEntidade_Click() | acao |

---

## BOTOES EM ABAS DE PLANILHA (Shapes com OnAction)

| # | Prefixo | Aba | Botoes | Acoes |
|---|---------|-----|--------|-------|
| 1 | CT_BTN_ | ROTEIRO_RAPIDO / CHECKLIST_136 | Menu, Relatorio, Central | CT_AbrirMenuPrincipal, CTR_GerarRelatorioChecklist136, CT_AbrirCentral |
| 2 | QA_BTN_ | RESULTADO_QA | Menu, Relatorio, Central | CT_AbrirMenuPrincipal, CTR_GerarRelatorioBateria, CT_AbrirCentral |

---

## PLANO DE MIGRACAO

### Prioridade 1: Eliminar botoes heuristicos (#1-6)
Para cada um, criar o botao fisico equivalente no designer do form:
- Abrir Menu_Principal no VBA Editor > Designer
- Adicionar CommandButton no local correto
- Definir Name, Caption, ForeColor, BackColor
- Criar handler _Click() direto
- Remover o codigo de criacao heuristica e a variavel WithEvents

### Prioridade 2: Eliminar buscas por caption (#7-11)
- Referenciar o controle pelo Name direto em vez de buscar por caption
- Remover SubstituirCaptionsLegadoMEI() e InicializarCompatibilidadeEmpresa()
- Remover UI_EncontrarBotaoPorCaption() e UI_EncontrarBotaoPorTextos()

**Etapa segura (retrocompat)**:
- Enquanto o designer nao tiver os botoes novos, o codigo pode manter fallback por caption.

### Prioridade 3: Manter botoes de planilha (#shapes)
- Estes sao validos (criados por VBA em abas dinamicas como RESULTADO_QA)
- NAO precisam ser eliminados pois as abas sao recriadas a cada execucao

### Impacto estimado
- ~200 linhas de codigo de criacao heuristica podem ser removidas
- ~50 linhas de busca por caption podem ser removidas
- Cada botao fisico precisa de ~5 linhas de handler
- Economia liquida: ~200 linhas de codigo morto

### Risco
- O form .frx (binario) precisa ser editado no designer do VBA Editor
- NAO e possivel fazer esta migracao por texto — requer acesso ao designer do form
- Recomendacao: fazer em etapas, validando cada botao migrado antes do proximo
