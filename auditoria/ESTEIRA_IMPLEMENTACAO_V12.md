# ESTEIRA DE IMPLEMENTAÇÃO V12 — PACOTE COMPLETO DE HANDOFFS

**Versão do Sistema:** V12.0.0166 (atual) → V12.0.0170 (alvo)
**Data:** 15 de abril de 2026
**Autor:** Claude Opus 4.6 (Arquiteto/Especificador)
**Executores:** Cursor (implementação), Codex (validação), Gemini/Antigravity (documentação), Opus (review final)

---

## SEÇÃO 0: CONGELAMENTO E PUBLICAÇÃO DA VERSÃO ATUAL

### 0.1 Objetivo

Congelar V12.0.0166 como baseline de referência antes de qualquer alteração. Esta versão será publicada no GitHub e enviada para testes humanos em ambiente de aceitação. O congelamento garante que qualquer regressão seja detectável comparando contra esta linha de base.

### 0.2 Comandos para o humano executar (na ordem)

```bash
cd ~/Projetos/Credenciamento

# 1. Garantir que vba_export/ está atualizado (exportar do Excel se necessário)
# Abrir o Excel, salvar o arquivo .xlsm, e copiar código para vba_export/
# (usar Importador_VBA.bas para garantir compatibilidade)

# 2. Publicar pacote de importação
bash scripts/publicar_vba_import.sh

# 3. Tag de congelamento
git add -A
git commit -m "FREEZE: V12.0.0166 — baseline para auditoria e testes humanos"
git tag v12.0.0166-freeze
git push origin main --tags

# 4. Criar branch de evolução
git checkout -b evolucao/v12.0.0170-esteira
```

### 0.3 Validação do congelamento

Executar os seguintes comandos para confirmar:

```bash
# Verificar que o commit foi criado
git log --oneline -1
# Esperado: "FREEZE: V12.0.0166 — baseline para auditoria e testes humanos"

# Verificar que a tag existe
git tag | grep v12.0.0166-freeze
# Esperado: v12.0.0166-freeze

# Verificar que o branch foi criado
git branch | grep evolucao/v12.0.0170-esteira
# Esperado: evolucao/v12.0.0170-esteira (com asterisco, pois está checked out)

# Verificar que nenhuma alteração pendente existe
git status
# Esperado: "On branch evolucao/v12.0.0170-esteira" + "nothing to commit"
```

### 0.4 Repositório remoto

Após push, o GitHub deve conter:
- Tag `v12.0.0166-freeze` apontando para o commit de congelamento
- Branch `main` atualizado
- Branch `evolucao/v12.0.0170-esteira` visível para checkout local

---

## SEÇÃO 1: PROMPT PARA O CURSOR — HANDOFF A (Interface Determinística)

### 1.1 Contexto e objetivo

O Menu_Principal.frm (form principal da aplicação) ainda contém vestígios de uma camada de compatibilidade de botões criada em versões anteriores. Essa camada usa WithEvents com Property Get indiretos (exemplo: `mBtnEmpresaCadastroNav` referencia a Property `BtnEmpresaCadastro`, que retorna o controle do designer `B_MEI`). Esta indireção adiciona complexidade sem benefício prático e mascara a ligação real entre handlers e controles físicos.

Objetivo desta tarefa: remover essa camada de indireção, usando nomes diretos dos botões do designer, enquanto preserva toda a lógica de negócio e mantém os filtros de texto (TextBox) que são legítimos e necessários.

### 1.2 Especificação de handoff — COPIAR E COLAR NO CURSOR

```
TAREFA: Remover os últimos vestígios de criação heurística de botões no Menu_Principal.frm

VERSÃO DESEJADA NO APP_RELEASE: V12.0.0167

O QUE MUDAR (comportamento):
- Antes: Menu_Principal.frm referencia 5 variáveis WithEvents (mBtnCredenciarEmpresa, 
  mBtnEmpresaCadastroNav, mBtnEmpresaRodizioNav, mBtnEmpresaAvaliacaoNav, 
  mBtnReativaEmpresa) que são ligadas a botões do designer via InicializarCompatibilidadeEmpresa() 
  usando Property Get indiretos (BtnEmpresaCadastro→B_MEI, BtnEmpresaRodizio→B_DesignarMEI, 
  BtnEmpresaAvaliacao→B_AvaliaMEI). Também há 5 filtros TextBox criados via WithEvents 
  (mTxtFiltroRodizio, mTxtFiltroServico, mTxtFiltroEmpresa, mTxtFiltroEntidade, mTxtFiltroCadServ).

- Depois: Os handlers de botão devem usar diretamente os nomes do designer (B_MEI_Click, 
  B_DesignarMEI_Click, B_AvaliaMEI_Click) sem camada de indireção. As variáveis WithEvents 
  dos botões (mBtnCredenciarEmpresa, mBtnEmpresaCadastroNav, mBtnEmpresaRodizioNav, 
  mBtnEmpresaAvaliacaoNav, mBtnReativaEmpresa) e suas Property Get devem ser removidas. 
  Os TextBox de filtro devem continuar funcionando (são legítimos como WithEvents ligados a 
  controles do designer se existirem no designer, OU podem ser mantidos se criados dinamicamente 
  — não quebrar filtros). O InicializarCompatibilidadeEmpresa() deve ser removido ou simplificado 
  para só ligar os TextBox.

ARQUIVOS (só estes, em vba_export/):
- Menu_Principal.frm (arquivo principal de alteração)
- App_Release.bas (bump versão para V12.0.0167)

FORA DE ESCOPO (não mexer):
- Mod_Types.bas
- Const_Colunas.bas
- Svc_*.bas
- Repo_*.bas
- Qualquer outro .frm que não seja Menu_Principal
- NÃO reimportar todos os módulos
- NÃO alterar VB_Name de nenhum módulo
- NÃO criar botões novos no .frm (isso requer o designer do Excel)
- NÃO alterar a lógica de negócio dos handlers (só a forma como são ligados)

CONTEXTO IMPORTANTE:
- Os botões B_MEI, B_DesignarMEI, B_AvaliaMEI EXISTEM no designer do form (são físicos)
- Os nomes são legados (MEI era o termo anterior para Empresa)
- A camada de compatibilidade (Property Get BtnEmpresaCadastro → B_MEI) foi criada para dar 
  nomes semânticos, mas adiciona indireção desnecessária
- Se algum handler usa mBtnEmpresaCadastroNav_Click, mover a lógica para B_MEI_Click 
  (ou delegar via Call)
- Os botões BT_PREOS_REJEITAR, BT_PREOS_EXPIRAR e BT_OS_CANCELAR foram removidos do 
  Controls.Add na V12.0.0155 e DEVEM existir no designer — se o código referencia eles como 
  controles físicos, manter
- mBtnCredenciarEmpresa busca botão por caption "CREDENCIA" — se existir um botão físico 
  com esse name no designer, usar direto; se não existir, manter o WithEvents mas documentar 
  que precisa de migração futura no designer

MUDANÇAS ESPERADAS (checklist):
□ Variáveis WithEvents dos botões removidas (mBtnCredenciarEmpresa, mBtnEmpresaCadastroNav, 
  mBtnEmpresaRodizioNav, mBtnEmpresaAvaliacaoNav, mBtnReativaEmpresa)
□ Property Get BtnEmpresaCadastro, BtnEmpresaRodizio, BtnEmpresaAvaliacao, etc. removidas
□ Sub InicializarCompatibilidadeEmpresa() removido ou reduzido a só inicializar TextBox
□ Handlers B_MEI_Click, B_DesignarMEI_Click, B_AvaliaMEI_Click existem e contêm a lógica anterior
□ Handlers de botões legados (se existiam) consolidados nos handlers diretos
□ TextBox filtros mantidos e funcionando
□ Zero erro na compilação

VALIDAR DEPOIS:
1. No VBE: Depurar > Compilar VBAProject (zero erros)
2. Abrir Menu_Principal: verificar que todas as 8 páginas navegam corretamente
3. Página de Cadastro Empresa: botão B_MEI funciona
4. Página de Rodízio: botão B_DesignarMEI funciona, filtro funciona
5. Página de Avaliação: botão B_AvaliaMEI funciona
6. Página de OS: botões BT_PREOS_REJEITAR, BT_PREOS_EXPIRAR, BT_OS_CANCELAR funcionam

ROLLBACK:
git checkout -- vba_export/Menu_Principal.frm vba_export/App_Release.bas

RELEASE NOTE (criar em obsidian-vault/releases/):
Arquivo: V12.0.0167.md
Conteúdo: "Simplificação da camada de compatibilidade de botões no Menu_Principal. Removida 
indireção WithEvents→Property Get para botões físicos do designer. Filtros de texto mantidos. 
Zero alteração em lógica de negócio."
```

### 1.3 Esteira pós-Cursor para Handoff A

Após o Cursor enviar os arquivos alterados:

```
VALIDAR NO CODEX:
1. Receber: vba_export/Menu_Principal.frm (versão alterada) + este handoff
2. Tarefas Codex:
   - Verifique se a implementação respeita o contrato
   - Liste qualquer variável WithEvents que foi removida
   - Confirme que o handler correspondente ainda existe com a mesma lógica
   - Confirme que nenhuma lógica de negócio foi alterada
   - Procure por referências a "BtnEmpresa" que não foram consolidadas
3. Resultado esperado: lista de confirmações (sim/não/achado) com detalhes

Se Codex APROVA:
→ Seguir para Handoff B

Se Codex encontra problemas:
→ Devolver para Cursor com os achados específicos
```

### 1.4 Review final do Opus

Após Codex aprovar:

```
VALIDAR NO OPUS:
1. Receber: git diff vba_export/Menu_Principal.frm vba_export/App_Release.bas
2. Tarefas Opus:
   - Este diff respeita o handoff?
   - Há regressão detectável (ex: handler deletado, lógica alterada)?
   - Os nomes dos handlers correspondem aos botões do designer?
3. Se tudo OK: marcar como "PRONTO PARA COMMIT"
```

---

## SEÇÃO 2: PROMPT PARA O CURSOR — HANDOFF B (Política de Arredondamento)

### 2.1 Contexto e objetivo

Atualmente, a média de avaliação é calculada, persistida, comparada, impressa e auditada de formas diferentes:
- **Cálculo:** `media = soma / 10#` (Double exato, ex: 4.9)
- **Comparação:** `media < notaMin` usa valor exato (sem arredondamento)
- **Persistência:** armazenado como Double puro no banco (sem arredondamento aplicado)
- **Impressão:** truncado com `Fix(media * 100) / 100` (ex: 4.95 vira 4.95, mas 4.949 vira 4.94)
- **Auditoria:** `Format$(media, "0.00")` que efetivamente ARREDONDA (ex: 4.945 vira 4.95)

Resultado: o valor que determina a suspensão (exato) pode diferir do valor impresso (truncado) e do valor auditado (arredondado). Isso viola o princípio de consistência e causa confusão em auditorias.

Objetivo: unificar toda a cadeia para usar `Round(media, 2)` como valor canônico. O valor é arredondado UMA VEZ no cálculo, e então reutilizado em todas as etapas posteriores (comparação, persistência, impressão, auditoria).

### 2.2 Especificação de handoff — COPIAR E COLAR NO CURSOR

```
TAREFA: Unificar a política de arredondamento da média de avaliação em toda a cadeia: 
cálculo, persistência, comparação, exibição, impressão e auditoria.

VERSÃO DESEJADA NO APP_RELEASE: V12.0.0168

O QUE MUDAR (comportamento):
- Antes:
  * Svc_Avaliacao.bas linha 72: media = soma / 10# (Double exato, ex: 4.9)
  * Svc_Avaliacao.bas linha 96: compara media < notaMin (usa valor exato)
  * Repo_Avaliacao.bas linha 62: persiste MEDIA_NOTAS como Double puro
  * Preencher.bas linha 2755: trunca com Fix(media * 100) / 100 para impressão
  * Svc_Avaliacao.bas linha 119: audit log usa Format$(media, "0.00") que ARREDONDA
  * Resultado: valor de decisão (exato), valor impresso (truncado) e valor auditado 
    (arredondado) podem divergir

- Depois:
  * Toda a cadeia deve usar Round(media, 2) como valor canônico
  * Svc_Avaliacao.bas: após calcular media = soma / 10#, aplicar media = Round(media, 2)
  * A comparação media < notaMin continua usando o valor arredondado (2 casas)
  * Repo_Avaliacao.bas: persiste o valor já arredondado (não muda a lógica, só o valor 
    que recebe)
  * Preencher.bas: substituir Fix(media * 100) / 100 por simplesmente usar o valor 
    recebido (já arredondado em 2 casas), mantendo NumberFormat "0.00"
  * Audit log: Format$(media, "0.00") agora é consistente porque media já está arredondado

ARQUIVOS (só estes, em vba_export/):
- Svc_Avaliacao.bas (adicionar Round após cálculo da média)
- Preencher.bas (remover Fix truncation, usar valor direto)
- App_Release.bas (bump para V12.0.0168)

FORA DE ESCOPO (não mexer):
- Mod_Types.bas
- Repo_Avaliacao.bas (não precisa mudar — recebe valor já arredondado)
- Repo_OS.bas
- Const_Colunas.bas
- Util_Config.bas (GetNotaMinimaAvaliacao não muda)
- Qualquer .frm

MUDANÇAS EXATAS:

1. Em Svc_Avaliacao.bas, APÓS a linha "media = soma / 10#" (atualmente linha 72), ADICIONAR:
   ```vba
   media = Round(media, 2)
   ```

2. Em Preencher.bas, no Sub PreencherAvaliacaoOS, SUBSTITUIR o bloco (linhas ~2752-2758):
   ```vba
   ' Regra crítica: a impressão deve refletir exatamente a pontuação obtida,
   ' com 2 casas decimais e sem arredondar para cima (evita punições indevidas).
   If media >= 0 Then
       media2 = Fix(media * 100) / 100
   Else
       media2 = -Fix(Abs(media) * 100) / 100
   End If
   ws.Range("N37").Value = media2
   ```
   
   POR:
   ```vba
   ' Regra V12.0.0168: a media ja chega arredondada em 2 casas por Svc_Avaliacao.
   ' Nao aplicar truncamento adicional. Valor impresso = valor de decisao = valor auditado.
   ws.Range("N37").Value = media
   ```
   
   (manter ws.Range("N37").NumberFormat = "0.00" na linha seguinte)

3. Em App_Release.bas, alterar:
   ```vba
   Public Const APP_RELEASE_ATUAL As String = "V12.0.0168"
   ```

MUDANÇAS ESPERADAS (checklist):
□ Round(media, 2) presente em Svc_Avaliacao.bas após soma / 10#
□ Bloco Fix() removido de Preencher.bas
□ media2 não é mais usada (ou usada apenas em legado)
□ ws.Range("N37").Value = media (sem ajuste adicional)
□ APP_RELEASE_ATUAL alterado para V12.0.0168
□ Zero erro na compilação

VALIDAR DEPOIS:
1. Depurar > Compilar VBAProject (zero erros)
2. Executar bateria oficial (opção 4 da Central de Testes) — modo rápido
3. Verificar que testes BO_120 (avaliação) passam
4. Teste manual: avaliar uma OS com notas que somem 49 (média 4.9):
   - Verificar que a empresa É suspensa (4.9 < 5.0)
   - Verificar que a impressão mostra "4.90"
   - Verificar que o audit log mostra "MEDIA=4.90"
5. Teste manual: avaliar uma OS com notas que somem 50 (média 5.0):
   - Verificar que a empresa NÃO é suspensa (5.0 não é < 5.0)
6. Teste manual: avaliar uma OS com notas que somem 35 (média 3.5):
   - Verificar que a empresa É suspensa (3.5 < 5.0)
   - Verificar que a impressão mostra "3.50"

ROLLBACK:
git checkout -- vba_export/Svc_Avaliacao.bas vba_export/Preencher.bas vba_export/App_Release.bas

RELEASE NOTE (criar em obsidian-vault/releases/):
Arquivo: V12.0.0168.md
Conteúdo: "Unificação da política de arredondamento: toda a cadeia (cálculo → persistência 
→ comparação → impressão → auditoria) agora usa Round(media, 2). Eliminada divergência entre 
Fix() na impressão e Format$() na auditoria. Valor de decisão = valor impresso = valor auditado."
```

### 2.3 Esteira pós-Cursor para Handoff B

```
VALIDAR NO CODEX:
1. Receber: Svc_Avaliacao.bas + Preencher.bas (alterados) + este handoff
2. Tarefas Codex:
   a) Confirme que Round(media, 2) foi adicionado APÓS soma/10# e ANTES da comparação 
      com notaMin
   b) Confirme que o bloco Fix() foi removido de Preencher.bas
   c) Liste todos os pontos onde 'media' é usada e confirme que nenhum caminho escapa 
      do arredondamento
   d) Procure por referencias a "media2" que ainda existem (se existem, avisar que 
      pode ser codigo morto)
3. Resultado esperado: lista de confirmações com detalhes

Se Codex APROVA:
→ Seguir para Handoff C

Se Codex encontra problema (ex: media não arredonda em algum lugar):
→ Devolver para Cursor com detalhes do caminho não coberto
```

---

## SEÇÃO 3: PROMPT PARA O CURSOR — HANDOFF C (Reconciliação Documentação)

### 3.1 Contexto e objetivo

A documentação em `obsidian-vault/arquitetura/` descreve o sistema de forma idealizada, mas pode estar desatualizada ou diferente do código real em `vba_export/`. Exemplos de divergências comuns:
- Descrição de TResult com campo genérico "Dados As Variant" quando o código real tem "IdGerado As String"
- Algoritmo descrito como "score-based" quando é realmente "fila por POSICAO_FILA com filtros"
- SaaS layer mencionado como ativo quando ainda está em fase de planejamento
- Contagem de módulos e forms desatualizada

Objetivo: atualizar 3 arquivos arquiteturais para refletir o código real e servir como fonte de verdade para futuros desenvolvedores.

### 3.2 Especificação de handoff — COPIAR E COLAR NO CURSOR

```
TAREFA: Atualizar os 3 arquivos de documentação arquitetural para refletir o código real 
(V12.0.0168+)

VERSÃO DESEJADA NO APP_RELEASE: não bump (só documentação)

O QUE MUDAR (comportamento):
- Antes: Documentação descreve TResult com "Dados As Variant", algoritmo "score-based", 
  SaaS layer, ErrorBoundary ativo, contagem de 27 módulos
- Depois: Documentação reflete o código real: TResult.IdGerado As String, algoritmo 
  POSICAO_FILA com filtros A-E, SaaS marcado como "planejado/futuro", ErrorBoundary marcado 
  como "pouco usado", contagem correta de módulos (~32)

ARQUIVOS (só estes, em obsidian-vault/arquitetura/):
- Visao-Geral.md
- Fluxos-de-Negocio.md
- Formularios.md

FORA DE ESCOPO (não mexer):
- Qualquer arquivo em vba_export/
- Qualquer arquivo em obsidian-vault/releases/
- Qualquer arquivo em obsidian-vault/ai/

MUDANÇAS ESPECÍFICAS:

1. Em Visao-Geral.md:
   a) No diagrama "EXCEL VBA (.xlsm)": alterar "27 Modulos" para "~32 Modulos" e 
      "7 Planilhas" para "12 Planilhas"
   b) Na seção Mod_Types.bas: substituir o bloco de código que mostra TResult com 
      "Dados As Variant" pelo seguinte:
      ```vba
      Public Type TResult
          Sucesso     As Boolean
          Mensagem    As String
          CodigoErro  As Long
          IdGerado    As String
      End Type
      ```
   c) Atualizar TEmpresa para incluir campos reais (extrair de Mod_Types.bas):
      EMP_ID, cnpj, RAZAO_NOME, CONTATO_TEL, CONTATO_EMAIL, endereco, bairro, 
      municipio, uf, cep, STATUS_GLOBAL, DT_FIM_SUSP, QTD_RECUSAS, DT_CAD, DT_ULT_ALT
   d) Na seção Svc_Rodizio: substituir o pseudocódigo "score-based" pela descrição real: 
      "Algoritmo de fila por POSICAO_FILA com 5 filtros sequenciais (A: STATUS_CRED, 
      B: suspensão global, C: inatividade, D: OS aberta, E: Pre-OS pendente)"
   e) Na seção SaaS Layer: adicionar nota "STATUS: PLANEJADO — não implementado no VBA atual"
   f) Na seção ErrorBoundary: adicionar nota "STATUS: módulo existe mas é pouco utilizado 
      na prática; tratamento de erro é feito localmente em cada Svc_*.bas"

2. Em Fluxos-de-Negocio.md:
   a) No Fluxo 3 (Criar OS): substituir "Svc_Rodizio.ProximaEmpresaParaOS(atividadeId)" 
      por "Svc_Rodizio.SelecionarEmpresa(ATIV_ID)" e descrever os 5 filtros
   b) No Fluxo 5 (Avaliar): atualizar para 10 notas (0-10), soma/10, comparação com notaMin, 
      suspensão automática
   c) Adicionar nota sobre a política de arredondamento V12.0.0168: Round(media, 2) 
      em toda a cadeia
   d) Revisar sequência de chamadas para corresponder ao código real em Svc_*.bas

3. Em Formularios.md:
   a) Na seção Menu_Principal: mencionar que botões BT_PREOS_REJEITAR, BT_PREOS_EXPIRAR, 
      BT_OS_CANCELAR devem existir no designer (migração V12.0.0155)
   b) Na seção Configuracao_Inicial: adicionar COL_CFG_NOTA_MINIMA (coluna K) 
      como parâmetro configurável
   c) Atualizar contagem total de forms (quantos .frm realmente existem)
   d) Atualizar linhas de código estimadas

MUDANÇAS ESPERADAS (checklist):
□ Nenhuma menção a "Dados As Variant" em TResult
□ Nenhuma menção a "score-based" sem contexto
□ Nenhuma menção a "27 módulos" (deve ser ~32)
□ SaaS Layer marcado como "PLANEJADO"
□ ErrorBoundary marcado como "POUCO UTILIZADO"
□ Fluxos de Negócio refletem código real (nomes de funções correspondem)
□ Descrição de Menu_Principal reflete V12.0.0167 (botões diretos, sem Property Get)

VALIDAR DEPOIS:
1. Ler cada arquivo e procurar por inconsistências (ex: função chamada que não existe, 
   campo que não está em TResult)
2. Comparar nomes de funções em Fluxos-de-Negocio.md com nomes reais em Svc_*.bas
3. Verificar que TEmpresa em Visao-Geral.md tem campos que correspondem a COLUNA_* 
   em Const_Colunas.bas

ROLLBACK:
git checkout -- obsidian-vault/arquitetura/Visao-Geral.md obsidian-vault/arquitetura/Fluxos-de-Negocio.md obsidian-vault/arquitetura/Formularios.md
```

### 3.3 Esteira pós-Cursor para Handoff C

```
VALIDAR NO GEMINI/ANTIGRAVITY:
1. Receber: os 3 arquivos atualizados
2. Tarefas Gemini:
   - Revise a clareza e a completude da documentação
   - O público-alvo é um desenvolvedor que nunca viu o sistema
   - Há lacunas (ex: função mencionada mas não explicada)?
   - Há termos técnicos sem explicação?
   - Há contradições internas?
   - Sugira melhorias de redação
3. Resultado esperado: lista de melhorias com justificativas
```

---

## SEÇÃO 4: PROMPT PARA O GEMINI/ANTIGRAVITY — Documentação e Material para Humanos

### 4.1 Contexto e objetivo

Depois que a documentação arquitetural for reconciliada (Handoff C), o Gemini cria ou atualiza documentos de nível superior:
- Um guia em linguagem clara para funcionários municipais (não-técnico)
- Atualização do README.md principal
- Glossário de termos técnicos
- Organização de notas de versão
- Registro desta auditoria e esteira no histórico de decisões

### 4.2 Especificação de handoff — COPIAR E COLAR NO GEMINI

```
TAREFA: Produzir documentação de alto nível e material para humanos não-técnicos

VERSÃO DO SISTEMA: V12.0.0170 (alvo)

CONTEXTO:
- Sistema de credenciamento municipal de empresas (VBA + Excel)
- Versão congelada: V12.0.0166 (no GitHub)
- Alterações em progresso: V12.0.0167 (interface), V12.0.0168 (arredondamento)
- Público-alvo final: funcionários municipais, gestores, auditores

O QUE PRODUZIR:

1. GUIA_DO_SISTEMA_PARA_HUMANOS.md (novo arquivo em obsidian-vault/)
   Objetivo: explicar o sistema em português claro, SEM jargão técnico
   Seções obrigatórias:
   
   a) Introdução (o que é, por que existe)
      - Explicar que é um sistema para gerenciar quais empresas podem fazer negócios 
        com a prefeitura
      - Mencionar os 3 tipos de credencial: MEI, Rodízio, Avaliação de Desempenho
   
   b) As 8 páginas do Menu Principal (explicar o que cada uma faz)
      - Página 1: Cadastro de Empresas (adicionar/editar informações básicas)
      - Página 2: Rodízio (controlar a ordem de seleção das empresas para trabalhos)
      - Página 3: Avaliação (dar notas de 0-10 baseadas em comportamento/desempenho)
      - Página 4: Ordens de Serviço (criar trabalhos, designar empresas, fazer pagamento)
      - Página 5: Credenciais (visualizar status de cada empresa)
      - Página 6: Configurações (parâmetros do sistema)
      - Página 7: Testes e Diagnóstico (para uso de TI/auditoria)
      - Página 8: Importar/Exportar Dados
   
   b) Fluxo de um credenciamento (passo a passo)
      - Empresa registra no sistema
      - Sistema verifica se já tem credencial ativa
      - Se não, empresa entra em fila
      - Sistema seleciona empresa da fila (por rodízio/desempenho)
      - Empresa cria trabalhos e recebe pagamento
      - Sistema monitora desempenho (notas de avaliação)
      - Se desempenho ruim (média < 5.0), empresa é suspensa
      - Empresa pode apelar ou melhorar para sair da suspensão
   
   c) Como gerar relatórios
      - Quais são os 5 tipos de relatório disponíveis
      - Como filtrar por data, empresa, atividade
      - Como exportar para Excel/PDF
   
   d) Troubleshooting comum
      - "Por que a minha empresa sumiu da lista?"
      - "Por que não consigo criar uma OS?"
      - "Como faço para apelar uma suspensão?"
      - Respostas simples e acionáveis
   
   e) Quem contatar em caso de problemas
      - Estrutura de suporte

2. README.md (atualizar arquivo raiz)
   Objetivo: visão geral do repositório para novos desenvolvedores
   Seções obrigatórias:
   
   a) Badge de status: "Versão Atual: V12.0.0170 | Linguagem: VBA/Excel | Status: Produção"
   b) Descrição do projeto (1 parágrafo)
   c) Requisitos (Excel 2016+, VBA enabled, etc.)
   d) Como clonar e rodar (3-4 passos)
   e) Estrutura de pastas (explicar vba_export/, obsidian-vault/, auditoria/, scripts/)
   f) Como contribuir (submeter handoff para revisão, não committar código direto)
   g) Link para documentação técnica (obsidian-vault/arquitetura/)
   h) Histórico de versões (últimas 5) com links
   i) Licença

3. obsidian-vault/GLOSSARIO.md (novo arquivo)
   Objetivo: dicionário de termos técnicos usados em toda documentação
   Formato: termo | definição | exemplo
   Incluir:
   - TResult: tipo estruturado de retorno de funções
   - WithEvents: padrão VBA para capturar eventos de objetos
   - MEI: sigla legada para "Microempresa ou Empresa Individual"
   - POSICAO_FILA: campo que ordena empresas para seleção
   - Round(x, 2): arredondar para 2 casas decimais
   - Suspensão: empresa temporariamente inativa por desempenho ruim
   - Rodízio: sistema de fila para seleção justa de empresas
   - Avaliação: processo de dar notas 0-10 ao desempenho
   - OS (Ordem de Serviço): trabalho atribuído a uma empresa
   - Audit log: registro de todas as alterações para rastreamento
   - etc. (mínimo 20 termos)

4. obsidian-vault/arquitetura/ÍNDICE.md (novo arquivo)
   Objetivo: mapa de navegação da documentação
   Conteúdo:
   - Lista todos os arquivos em arquitetura/, ai/, releases/
   - Explicar para qual público cada um é
   - Sugerir ordem de leitura (iniciante → intermediário → avançado)
   - Exemplo:
     * Iniciante: GUIA_DO_SISTEMA_PARA_HUMANOS.md
     * Desenvolvedor novo: Visao-Geral.md + Fluxos-de-Negocio.md
     * Arquiteto: Arquitetura-Detalhada.md + Audit logs em auditoria/
     * Auditor: ESTEIRA_IMPLEMENTACAO_V12.md + releases/

5. obsidian-vault/ai/bastao/0003-2026-04-15-Auditoria-Opus.md (novo arquivo)
   Objetivo: documentar esta auditoria e o handoff
   Conteúdo obrigatório:
   
   a) Data e versões envolvidas
      Data: 15 de abril de 2026
      Versão congelada: V12.0.0166
      Versão alvo: V12.0.0170
      Executor: Claude Opus 4.6
   
   b) Decisões arquiteturais documentadas
      - Decisão 1: Remover camada de compatibilidade de botões (Handoff A)
        Rationale: indireção desnecessária mascara ligações reais
        Impacto: zero na lógica, +clareza no código
      
      - Decisão 2: Unificar política de arredondamento (Handoff B)
        Rationale: divergência entre valor de decisão, impressão e auditoria
        Impacto: confiabilidade em auditorias, consistência End-to-End
      
      - Decisão 3: Reconciliar documentação com código (Handoff C)
        Rationale: documentação desatualizada é pior que não ter
        Impacto: novos devs conseguem ler código com segurança
   
   c) Riscos identificados
      - Risco: regressão em funcionalidade de Menu_Principal
        Mitigação: Codex valida antes de commit
      
      - Risco: teste manual pode perder casos de rodízio complexo
        Mitigação: executar bateria oficial de testes (BO_120+)
   
   d) Próximos passos recomendados
      - Depois de V12.0.0170: auditar sistema de suspensão (Ver fluxo Avaliação)
      - Depois de V12.0.0170: implementar SaaS layer (planejado, fora do escopo)
      - Depois de V12.0.0170: cobertura de testes unit (atualmente integração)

VALIDAÇÕES OBRIGATÓRIAS:
1. Ler cada seção de GUIA_DO_SISTEMA_PARA_HUMANOS.md e confirmar que um funcionário 
   municipal (sem experiência técnica) consegue entender
2. Confirmar que README.md tem instruções copy-paste que funcionam (clonar, importar VBA)
3. Confirmar que GLOSSARIO.md cobre todos os termos usados em Visao-Geral.md, 
   Fluxos-de-Negocio.md, Formularios.md
4. Confirmar que ÍNDICE.md existe e navega para todos os arquivos mencionados

FORMATO:
- Markdown puro, sem requisitos especiais
- Português técnico claro (evitar jargão quando possível)
- Listas com bullet points quando apropriado
- Blocos de código VBA apenas quando necessário (ex: exemplo de chamada de função)
- Links internos para outros arquivos (ex: [[Visao-Geral.md]])

ROLLBACK:
git checkout -- obsidian-vault/
git rm obsidian-vault/GUIA_DO_SISTEMA_PARA_HUMANOS.md obsidian-vault/arquitetura/ÍNDICE.md \
        obsidian-vault/arquitetura/GLOSSARIO.md obsidian-vault/ai/bastao/0003-2026-04-15-Auditoria-Opus.md
```

---

## SEÇÃO 5: PROMPT PARA O CODEX — Validação Independente

### 5.1 Contexto e objetivo

O Codex é o validador independente. Após cada implementação do Cursor, o Codex recebe os arquivos alterados + a especificação de handoff (este documento) e verifica se a implementação respeita o contrato, está livre de regressões óbvias e segue boas práticas.

### 5.2 Especificação de handoff — COPIAR E COLAR NO CODEX

```
TAREFA: Validar implementação independentemente contra handoff

CICLO: Acontece após CADA handoff (A, B, C)

PROTOCOLOS DE ENTRADA (você recebe):
1. Este documento (ESTEIRA_IMPLEMENTACAO_V12.md) — contém a especificação
2. Arquivo(s) alterado(s) pelo Cursor
3. Mensagem com versão alvo esperada

PROTOCOLO DE VALIDAÇÃO:

Etapa 1: Comparação contra Especificação
-----------
Para cada item em "MUDANÇAS ESPERADAS (checklist)" da seção de handoff:
   a) Verificar que a mudança foi implementada exatamente como descrito
   b) Listar locação exata no código (número da linha, se possível)
   c) Confirmar com "✓ OK" ou "✗ FALHA"

Exemplo (para Handoff A):
   Validação A.1: Variáveis WithEvents dos botões removidas
      ✓ mBtnCredenciarEmpresa — removido (linha anterior: 45)
      ✓ mBtnEmpresaCadastroNav — removido (linha anterior: 46)
      ✗ mBtnEmpresaRodizioNav — AINDA PRESENTE NA LINHA 47
      Status: FALHA — uma variável não foi removida

Etapa 2: Regressions Check
-----------
Para cada mudança, procurar por regressões:
   a) Se foi removida uma variável, procurar por referencias "órfãs" a ela
   b) Se foi removido um handler, procurar por chamadas a ele
   c) Se foi alterada uma lógica, procurar por paths que ainda usam comportamento antigo

Exemplo (para Handoff B):
   Regressão B.1: Round(media, 2) adicionado?
      ✓ Adicionado em Svc_Avaliacao.bas linha 73, logo após soma/10#
   
   Regressão B.2: Fix() removido de Preencher.bas?
      ✓ Bloco Fix() removido (linhas 2752-2758 no original)
      ? media2 ainda declarada na linha 2740 — é código morto?
      Status: AVISO — revisar se media2 é necessário
   
   Regressão B.3: App_Release bumped?
      ✓ APP_RELEASE_ATUAL = "V12.0.0168"

Etapa 3: Lógica de Negócio Não Alterada
-----------
Comparar comportamento antes/depois usando a lógica do handoff:
   a) Listar todos os handlers/subs que contêm lógica de negócio
   b) Para cada um, confirmar que o corpo do código não foi alterado 
      (apenas chamadas foram refeitas/consolidadas)
   c) Se há alteração lógica, solicitar justificativa

Exemplo (para Handoff A):
   Validação A.2: Lógica de handlers preservada
      Sub B_MEI_Click():
         Antes: chamava mBtnEmpresaCadastroNav_Click() (indireção)
         Depois: contém a lógica diretamente (mesma lógica, sem indireção)
         ✓ Lógica preservada, forma simplificada
      
      Sub B_DesignarMEI_Click():
         Antes: nao existia
         Depois: criado por consolidação de mBtnEmpresaRodizioNav_Click
         ✓ Lógica consolidada, não alterada

Etapa 4: Relatório Estruturado
-----------
Produzir relatório em formato fixo:

VALIDAÇÃO DE [HANDOFF X] — [DATA]
=====================================
Arquivo(s) validado(s): [lista]
Versão alvo: [V12.0.0.XXX]

RESULTADO GERAL: [✓ APROVADO | ⚠ AVISO | ✗ REPROVADO]

Seção 1: Comparação contra Especificação
-----------
Mudança 1: [descrição]
  ✓ OK — detalhes
  
Mudança 2: [descrição]
  ✓ OK — detalhes

Seção 2: Regressões Detectadas
-----------
Regressão A: [descrição]
  ✓ Nenhuma — ou ✗ DETECTADA — detalhes e linha
  
Regressão B: [descrição]
  ✓ Nenhuma — ou ✗ DETECTADA — detalhes e linha

Seção 3: Lógica de Negócio
-----------
Função F1():
  ✓ Preservada — detalhes
  
Função F2():
  ⚠ AVISO: Comportamento diferente — [explicar]
  Solução sugerida: [ação corretiva]

CONCLUSÃO
-----------
Implementação: [✓ PRONTA PARA COMMIT | ⚠ PRONTA COM AVISOS | ✗ REJEITAR COM CORREÇÕES]
Próximo passo: [se APROVADO: "Enviar para Opus review"; se REJEITADO: "Devolver ao Cursor"]
Detalhes de correção (se aplicável): [lista de correções necessárias]

TONE E ETIQUETA:
- Ser técnico, não crítico
- Focar em fatos (linha X, função Y)
- Se encontrar problema, sugerir solução específica
- Sempre listar referências de linha/função para facilitar Cursor corrigir
```

---

## SEÇÃO 6: SEQUÊNCIA COMPLETA DA ESTEIRA

### 6.1 Ordem de Execução

A esteira é sequencial. Cada fase depende da conclusão da fase anterior. Os handoffs de documentação (C) podem ser paralelizados com handoffs de código (A, B), mas devem ser consolidados antes de Handoff D (revisão final).

### 6.2 Fases Detalhadas

#### FASE 0: CONGELAMENTO (humano)

| Etapa | Comando/Ação | Responsável | Esperado |
|-------|--------------|-------------|----------|
| 0.1   | Exportar VBA do Excel para vba_export/ | Humano | Todos os .bas, .frm atualizados |
| 0.2   | bash scripts/publicar_vba_import.sh | Humano | Pacote de importação publicado |
| 0.3   | git add -A && git commit -m "FREEZE: V12.0.0166" | Humano | Commit criado |
| 0.4   | git tag v12.0.0166-freeze && git push | Humano | Tag visível no GitHub |
| 0.5   | git checkout -b evolucao/v12.0.0170-esteira | Humano | Branch criado localmente |
| **Status** | | | **V12.0.0166 CONGELADA, PRONTA PARA TESTES** |

---

#### FASE 1: HANDOFF C — DOCUMENTAÇÃO (paralelo com Fase 2)

| Etapa | Ação | Responsável | Esperado |
|-------|------|-------------|----------|
| 1.1   | Cursor executa Handoff C (Seção 3) | Cursor | 3 arquivos .md atualizados |
| 1.2   | git add && git commit -m "V12-DOC: Reconciliação documentação vs código" | Humano | Commit criado |
| 1.3   | Gemini/Antigravity executa prompt (Seção 4) | Gemini | 4 arquivos novos + 1 README atualizado |
| 1.4   | git add && git commit -m "V12-DOC: Guia para humanos + glossário + índice" | Humano | Documentação consolidada |
| **Status** | | | **DOCUMENTAÇÃO ATUALIZADA, ZERO RISCO** |

---

#### FASE 2: HANDOFF B — ARREDONDAMENTO (pode ser paralelo com Fase 1)

| Etapa | Ação | Responsável | Esperado |
|-------|------|-------------|----------|
| 2.1   | Cursor executa Handoff B (Seção 2) | Cursor | 3 arquivos .bas alterados |
| 2.2   | Humano importa 3 arquivos no VBE | Humano | Código importado |
| 2.3   | Depurar > Compilar (zero erros) | Humano | Compilação bem-sucedida |
| 2.4   | Executar bateria oficial (BO_120+) | Humano | Testes passam |
| 2.5   | Codex valida implementação (Seção 5) | Codex | Relatório de validação |
| 2.6   | Se OK: git commit -m "V12.0.0168: Arredondamento" | Humano | Commit criado |
| 2.7   | Se FALHA: Cursor corrige → volta a 2.1 | Cursor | Iteração até OK |
| **Status** | | | **V12.0.0168 PRONTA (arredondamento implementado)** |

---

#### FASE 3: HANDOFF A — INTERFACE (sequencial após Fase 2)

| Etapa | Ação | Responsável | Esperado |
|-------|------|-------------|----------|
| 3.1   | Cursor executa Handoff A (Seção 1) | Cursor | 2 arquivos .frm/.bas alterados |
| 3.2   | Humano importa 2 arquivos no VBE | Humano | Código importado |
| 3.3   | Depurar > Compilar (zero erros) | Humano | Compilação bem-sucedida |
| 3.4   | Teste manual: navegar 8 páginas Menu_Principal | Humano | Navegação OK, botões OK |
| 3.5   | Codex valida implementação (Seção 5) | Codex | Relatório de validação |
| 3.6   | Se OK: git commit -m "V12.0.0167: Simplificação interface" | Humano | Commit criado |
| 3.7   | Se FALHA: Cursor corrige → volta a 3.1 | Cursor | Iteração até OK |
| **Status** | | | **V12.0.0167 PRONTA (interface simplificada)** |

---

#### FASE 4: REVIEW FINAL (Opus)

| Etapa | Ação | Responsável | Esperado |
|-------|------|-------------|----------|
| 4.1   | Opus recebe: git log -10 + git diff v12.0.0166..HEAD | Humano/Opus | Contexto completo |
| 4.2   | Opus verifica: contrato, regressão, doc | Opus | Relatório final |
| 4.3   | Se OK: "PRONTO PARA PUBLICAÇÃO" | Opus | Aprovação |
| 4.4   | git tag v12.0.0170 && git push --tags | Humano | V12.0.0170 no GitHub |
| **Status** | | | **V12.0.0170 PUBLICADA** |

---

### 6.3 Diagrama de Fluxo (ASCII)

```
CONGELAMENTO (V12.0.0166)
        ↓
        ├─→ HANDOFF C (Doc) → Codex valida → Gemini aprimora → Commit
        │
        ├─→ HANDOFF B (Round) → Humano testa → Codex valida → Commit (V12.0.0168)
        │                                           ↓
        │                                    Se FALHA → Cursor corrige
        │
        └─→ HANDOFF A (Interface) → Humano testa → Codex valida → Commit (V12.0.0167)
                                          ↓
                                   Se FALHA → Cursor corrige
        
        Todos OK
        ↓
        OPUS REVIEW (git diff v12.0.0166..HEAD)
        ↓
        PUBLICAÇÃO (v12.0.0170)
```

---

### 6.4 Dependências de Versão

```
V12.0.0166 (baseline congelada)
    ↓
V12.0.0168 (Handoff B: arredondamento)
    ↓
V12.0.0167 (Handoff A: interface)
    ↓
V12.0.0170 (Publicação: docs + B + A consolidados)

NOTA: As versões não são criadas sequencialmente na ordem numérica.
      Isso reflete que B foi desenvolvido antes de A ser iniciado.
      Quando publicamos V12.0.0170, ela contém AMBAS as mudanças.
```

---

## SEÇÃO 7: SOBRE O IMPORTADOR E O ERRO TConfig

### 7.1 O que é TConfig

`TConfig` é um tipo estruturado (UDT — User Defined Type) definido em `Mod_Types.bas`:

```vba
Public Type TConfig
    ChaveConfig   As String
    Valor         As Variant
End Type
```

Este tipo é usado em toda a aplicação para armazenar e acessar configurações (nota mínima, parâmetros de rodízio, etc.).

### 7.2 O Erro "Duplicate Module TConfig"

O erro "Duplicate Module TConfig" (ou variações: "Conflicting Definitions", "Name Already Used in Project") ocorre quando:

1. **Causa Raiz:** O arquivo `.xlsm` contém múltiplos módulos ou tipos com definições de `TConfig` em duplicidade. Exemplos:
   - Módulo `Mod_Types` tem `Public Type TConfig`
   - Módulo legado `AAA_Types` TAMBÉM tem `Public Type TConfig`
   - Resultado: VBE vê 2 definições diferentes → conflito

2. **Por que acontece:** Versões antigas do sistema (V11.x, V12.0.0155-) tinham módulos legados (`AAA_Types`, `AAA_Types1`, `Mod_Types1`, `Mod_Types2`) que foram consolidados em `Mod_Types`, mas alguns `.xlsm` ainda conservam as cópias antigas.

### 7.3 Solução: O Importador_VBA.bas

O arquivo `Importador_VBA.bas` (que já existe em `vba_export/`) foi desenvolvido especificamente para resolver este problema:

**Linhas 46-52:** Purge de módulos legados
```vba
' Remover módulos legados que causam conflito com TConfig
On Error Resume Next
ThisWorkbook.VBProject.VBComponents.Remove ThisWorkbook.VBProject.VBComponents("AAA_Types")
ThisWorkbook.VBProject.VBComponents.Remove ThisWorkbook.VBProject.VBComponents("AAA_Types1")
ThisWorkbook.VBProject.VBComponents.Remove ThisWorkbook.VBProject.VBComponents("Mod_Types1")
ThisWorkbook.VBProject.VBComponents.Remove ThisWorkbook.VBProject.VBComponents("Mod_Types2")
ThisWorkbook.VBProject.VBComponents.Remove ThisWorkbook.VBProject.VBComponents("AppContext1")
ThisWorkbook.VBProject.VBComponents.Remove ThisWorkbook.VBProject.VBComponents("Util_CNAE")
On Error GoTo 0
```

**Linha 60:** Force Mod_Types import FIRST
```vba
' Garantir que Mod_Types é importado primeiro (para definir TConfig antes dos demais)
ImportarModulo(codepath & "Mod_Types.bas", ThisWorkbook.VBProject)
```

**Linhas após 60:** Importação sequencial de todos os demais módulos

**Função Diagnostico_TConfig() (linhas ~200+):** Post-import validation
```vba
Public Sub Diagnostico_TConfig()
    ' Verificar se TConfig está bem definido e se não há duplicatas
    ' Retornar relatório
End Sub
```

### 7.4 Conclusão: Importador NÃO precisa de mudanças

O `Importador_VBA.bas` **já resolve** o problema de TConfig. Não é necessário alterar o importador para os handoffs V12.0.0167, V12.0.0168, V12.0.0170.

### 7.5 Recomendação para usuários finais

Se um usuário final (ou teste humano) encontrar erro TConfig:

**Passo 1:** Usar uma NOVA planilha `.xlsm` (nunca usada antes, ou criada a partir de template limpo)

**Passo 2:** Abrir o VBE, ir para Tools > References e confirmar que não há referências para módulos removidos

**Passo 3:** Usar `Importador_VBA.bas` para importar todo o código:
```vba
Sub ImportarTudo()
    Call Importador_VBA.ImportarTodosOsModulos(caminho_para_vba_export)
    Call Importador_VBA.Diagnostico_TConfig()
End Sub
```

**Passo 4:** Se erro persistir, contatar suporte (é um problema de binário corrompido no .xlsm, não de código)

### 7.6 Risco: Mudanças no Importador

**NÃO recomendamos** pedir ao Codex que modifique `Importador_VBA.bas`, porque:

1. Qualquer mudança pode quebrar o mecanismo de purge/recovery
2. O importador é um "código de resgate" — deve ser estável e bem-testado
3. Se há problemas na importação, é melhor corrigir em `Mod_Types.bas` ou consolidar módulos legados, não mexer no importador

**Se encontrar bug no importador:** Documentar como issue, revisar com Opus antes de alterar

---

## SEÇÃO 8: INSTRUÇÕES PARA TESTES HUMANOS

### 8.1 Pré-requisitos

| Item | Requisito | Verificação |
|------|-----------|-------------|
| Excel | 2016 ou superior | `Help > About Microsoft Excel` |
| VBA | Habilitado | `File > Options > Trust Center > Macro Settings` = `Enable all macros` |
| .xlsm | Limpo (sem código antigo) | Abrir VBE (`Alt+F11`), verificar que não há módulos `AAA_*` ou `Mod_Types1` |
| Arquivo base | Clone do repositório | `git clone` + `git checkout v12.0.0166-freeze` |

### 8.2 Procedimento de Teste Manual V12.0.0168 (Arredondamento)

```
Teste A: Compilação
---------
1. Abrir Excel com .xlsm
2. Pressionar Alt+F11 (abrir VBE)
3. Selecionar menu Debug > Compile VBAProject
4. Esperado: zero erros

Teste B: Avaliação com Média 4.9 (Deve Suspender)
---------
1. Ir para página "Avaliação" no Menu_Principal
2. Selecionar uma OS (ou criar nova)
3. Dar as seguintes notas: 5+5+5+5+5+5+5+5+4+9 = 49 pontos
   (Soma = 49, Média = 49/10 = 4.9)
4. Clicar "Confirmar Avaliação"
5. Verificar campo "Média": deve mostrar "4.90"
6. Verificar que a empresa foi marcada como "SUSPENSA"
7. Abrir relatório de auditoria: deve constar "MEDIA=4.90"

Teste C: Avaliação com Média 5.0 (Não Deve Suspender)
---------
1. Ir para página "Avaliação" no Menu_Principal
2. Selecionar uma OS diferente (ou criar nova)
3. Dar as seguintes notas: 5+5+5+5+5+5+5+5+5+5 = 50 pontos
   (Soma = 50, Média = 50/10 = 5.0)
4. Clicar "Confirmar Avaliação"
5. Verificar campo "Média": deve mostrar "5.00"
6. Verificar que a empresa NÃO foi marcada como "SUSPENSA"

Teste D: Impressão de OS
---------
1. Gerar impressão de uma OS que foi avaliada no Teste B
2. Abrir PDF resultante
3. Procurar campo de "Média": deve mostrar "4.90" (não "4.94" ou truncado)
4. Confirmar que valor impresso = valor no relatório

Teste E: Bateria Oficial
---------
1. Ir para página "Testes e Diagnóstico"
2. Selecionar "Executar Bateria Oficial (Modo Rápido)"
3. Aguardar conclusão
4. Resultado esperado: "BO_120 PASSOU", "BO_121 PASSOU" (testes de avaliação)
5. Se algum teste falha: anotar o código (ex: "BO_120 FALHOU: média 4.9 não suspendeu")
```

### 8.3 Procedimento de Teste Manual V12.0.0167 (Interface)

```
Teste A: Compilação
---------
(idem a V12.0.0168)

Teste B: Menu_Principal Navegação
---------
1. Abrir o form "Menu_Principal"
2. Verificar que há 8 abas (Cadastro, Rodízio, Avaliação, OS, Credenciais, Config, 
   Testes, Importar/Exportar)
3. Clicar em cada aba, verificar que a página muda corretamente
4. Não deve haver erro "Object not found" ou similar

Teste C: Botões de Cadastro Empresa
---------
1. Ir para aba "Cadastro Empresa"
2. Procurar botão com label "CADASTRAR EMPRESA" ou similar (name: B_MEI)
3. Clicar nele → deve abrir form de cadastro ou realizar ação esperada
4. Não deve haver erro "Object variable not set" ou similar

Teste D: Botões de Rodízio
---------
1. Ir para aba "Rodízio"
2. Procurar botão (name: B_DesignarMEI)
3. Clicar nele → deve executar seleção de próxima empresa
4. Verificar que filtro de texto (TextBox Filtro) ainda funciona 
   (digitar texto, empresa lista filtra)

Teste E: Botões de Avaliação
---------
1. Ir para aba "Avaliação"
2. Procurar botão (name: B_AvaliaMEI)
3. Clicar nele → deve abrir form ou realizar ação esperada

Teste F: Botões de OS (Rejeitar/Expirar/Cancelar)
---------
1. Ir para aba "OS"
2. Procurar botões BT_PREOS_REJEITAR, BT_PREOS_EXPIRAR, BT_OS_CANCELAR
3. Clicar em cada um → devem executar ação esperada
4. Não deve haver erro ao clicar
```

---

## SEÇÃO 9: ROLLBACK PROCEDURES

Se em qualquer fase encontrar regressão grave que não consegue ser corrigida rapidamente, os seguintes comandos permitem voltar a V12.0.0166 congelada:

### 9.1 Rollback Total

```bash
cd ~/Projetos/Credenciamento

# Descartar todas as mudanças locais
git reset --hard v12.0.0166-freeze

# Voltar ao branch principal
git checkout main

# Deletar branch de evolução
git branch -D evolucao/v12.0.0170-esteira

# Reimportar código no Excel
# (usar Importador_VBA para trazer v12.0.0166 puro)
```

### 9.2 Rollback Seletivo (por arquivo)

```bash
# Rollback de arquivo específico (ex: Menu_Principal.frm)
git checkout v12.0.0166-freeze -- vba_export/Menu_Principal.frm

# Rollback de documentação
git checkout v12.0.0166-freeze -- obsidian-vault/arquitetura/

# Depois reimportar no Excel
```

### 9.3 Recuperação de Commit Local Acidental

Se um commit foi feito antes de estar pronto:

```bash
# Ver últimos commits
git log --oneline -5

# Desfazer o commit mantendo as mudanças locais
git reset --soft HEAD~1

# Agora você pode refazer o commit ou descartar com: git reset --hard HEAD
```

---

## SEÇÃO 10: CHECKLIST DE CONCLUSÃO

Use esta checklist para confirmar que cada fase foi completada com sucesso:

### FASE 0: Congelamento

- [ ] V12.0.0166 congelada em tag `v12.0.0166-freeze`
- [ ] Branch `evolucao/v12.0.0170-esteira` criado e checked out
- [ ] `git status` mostra "nothing to commit"
- [ ] `git log --oneline -1` mostra "FREEZE: V12.0.0166"

### FASE 1: Handoff C + Documentação

- [ ] Cursor completou Handoff C (3 arquivos .md atualizados)
- [ ] Codex validou documentação (sem inconsistências)
- [ ] Gemini completou prompt (4 arquivos novos + README atualizado)
- [ ] `git log --oneline -3` mostra commits de documentação
- [ ] README.md atualizado com badge de versão e estrutura de pastas

### FASE 2: Handoff B (Arredondamento)

- [ ] Cursor completou Handoff B (3 arquivos .bas alterados)
- [ ] Humano importou em VBE e compilou (zero erros)
- [ ] Bateria oficial executada (BO_120+ passaram)
- [ ] Teste manual: Média 4.9 suspende empresa
- [ ] Teste manual: Média 5.0 não suspende empresa
- [ ] Codex validou (relatório de aprovação gerado)
- [ ] `git log --oneline` mostra "V12.0.0168: Arredondamento"

### FASE 3: Handoff A (Interface)

- [ ] Cursor completou Handoff A (Menu_Principal.frm + App_Release.bas)
- [ ] Humano importou em VBE e compilou (zero erros)
- [ ] Teste manual: 8 abas navegáveis
- [ ] Teste manual: botões funcionam (B_MEI, B_DesignarMEI, B_AvaliaMEI)
- [ ] Teste manual: filtros TextBox funcionam
- [ ] Codex validou (relatório de aprovação gerado)
- [ ] `git log --oneline` mostra "V12.0.0167: Simplificação interface"

### FASE 4: Review Final (Opus)

- [ ] Opus recebeu git diff v12.0.0166..HEAD
- [ ] Opus confirmou: contrato respeitado, zero regressão, docs atualizadas
- [ ] `git tag v12.0.0170` criada
- [ ] `git push origin main --tags` executado
- [ ] Tag `v12.0.0170` visível no GitHub

### PUBLICAÇÃO

- [ ] GitHub mostra V12.0.0170 como release mais recente
- [ ] Branch `main` aponta para v12.0.0170
- [ ] vba_export/ contém código V12.0.0170 (versão lida do .xlsm)
- [ ] obsidian-vault/ contém docs V12.0.0170 (reconciliadas com código)
- [ ] README.md reflete V12.0.0170

---

## SEÇÃO 11: CONTATOS E ESCALAÇÃO

| Situação | Responsável | Ação |
|----------|-------------|------|
| Erro em Handoff A (Cursor) | Cursor | Ler erro, corrigir, submeter novamente para Codex |
| Erro em Handoff B (Cursor) | Cursor | Idem |
| Regressão detectada (Codex) | Codex | Gerar relatório detalhado, devolver a Cursor com linhas específicas |
| Decisão arquitetural questionada | Opus | Revisar handoff, confirmar decisão ou solicitar alteração |
| Divergência Documentação-Código | Gemini | Reconciliar, documentar em ÍNDICE.md qual versão é fonte de verdade |
| Erro TConfig em .xlsm | Humano | Usar Importador_VBA, testar com .xlsm novo, contatar suporte se persistir |
| Blockers na esteira | Todos | Escalacionar para Opus (arquiteto) para arbitragem |

---

## APÊNDICE A: Estrutura de Diretórios do Repositório

```
~/Projetos/Credenciamento/
├── README.md                          # Visão geral + instruções (ATUALIZAR)
├── .gitignore                         # Ignorar .xlsm, .xlsx, .tmp
├── .git/                              # Repositório Git
│
├── vba_export/                        # Código-fonte em VBA (único source of truth)
│   ├── Mod_Types.bas                  # Tipos estruturados (TResult, TEmpresa, etc.)
│   ├── Const_Colunas.bas              # Constantes de colunas do Excel
│   ├── Svc_Avaliacao.bas              # Lógica de avaliação
│   ├── Svc_Rodizio.bas                # Lógica de rodízio
│   ├── Svc_OS.bas                     # Lógica de Ordem de Serviço
│   ├── Repo_Avaliacao.bas             # Persistência de avaliações
│   ├── Repo_OS.bas                    # Persistência de OS
│   ├── Preencher.bas                  # Geração de impressões
│   ├── Util_Config.bas                # Utilitários de configuração
│   ├── Importador_VBA.bas             # Importador com purge de legado (NÃO ALTERAR)
│   ├── ErrorBoundary.bas              # Tratamento de erro (pouco usado)
│   ├── Menu_Principal.frm             # Form principal (8 páginas)
│   ├── ... (outros .frm)
│   └── App_Release.bas                # Versão atual (bump aqui)
│
├── obsidian-vault/                    # Documentação (para humanos e devs)
│   ├── README.md                      # Índice de documentação
│   ├── GUIA_DO_SISTEMA_PARA_HUMANOS.md  # Para funcionários municipais (NOVO)
│   │
│   ├── arquitetura/                   # Para desenvolvedores
│   │   ├── Visao-Geral.md             # Diagrama + tipos + módulos (ATUALIZAR)
│   │   ├── Fluxos-de-Negocio.md       # Fluxos de cada funcionalidade (ATUALIZAR)
│   │   ├── Formularios.md             # Catálogo de forms (ATUALIZAR)
│   │   ├── GLOSSARIO.md               # Dicionário de termos (NOVO)
│   │   ├── ÍNDICE.md                  # Guia de navegação (NOVO)
│   │   └── Arquitetura-Detalhada.md   # (se existir)
│   │
│   ├── releases/                      # Notas de versão
│   │   ├── V12.0.0166.md              # Release notes (baseline)
│   │   ├── V12.0.0167.md              # Release notes (interface) (NOVO)
│   │   ├── V12.0.0168.md              # Release notes (arredondamento) (NOVO)
│   │   └── V12.0.0170.md              # Release notes (publicação) (NOVO)
│   │
│   ├── ai/                            # Histórico de decisões arquiteturais
│   │   ├── bastao/                    # Notas de auditoria
│   │   │   ├── 0001-2026-03-XX-...md
│   │   │   ├── 0002-2026-04-01-...md
│   │   │   └── 0003-2026-04-15-Auditoria-Opus.md  # Esta auditoria (NOVO)
│   │   └── ... (outras notas)
│   │
│   └── (outros)
│
├── auditoria/                         # Relatórios e checklists
│   ├── ESTEIRA_IMPLEMENTACAO_V12.md   # Este arquivo
│   ├── ... (outros relatórios)
│   └── CHECKLIST_FINAL.md             # Checklist de conclusão
│
├── scripts/                           # Utilitários para build/deploy
│   ├── publicar_vba_import.sh         # Exporta vba_export para pacote
│   ├── ... (outros scripts)
│   └── README.sh                      # Como usar os scripts
│
└── (outros arquivos/diretórios conforme necessário)
```

---

## APÊNDICE B: Glossário Rápido de Termos Usados Neste Documento

| Termo | Significado |
|-------|------------|
| **V12.0.0166** | Versão congelada (baseline de referência) |
| **V12.0.0167** | Versão com Handoff A (simplificação interface) |
| **V12.0.0168** | Versão com Handoff B (arredondamento) |
| **V12.0.0170** | Versão publicada (consolidação de todas as mudanças) |
| **Handoff A** | Tarefa: remover indireção WithEvents em Menu_Principal |
| **Handoff B** | Tarefa: unificar política de arredondamento |
| **Handoff C** | Tarefa: reconciliar documentação com código |
| **Cursor** | Agente executor de código (implementação) |
| **Codex** | Agente validador (verificar contrato + regressão) |
| **Gemini/Antigravity** | Agente de documentação (guias para humanos) |
| **Opus** | Agente arquiteto (decisões, review final) |
| **git tag** | Marcador de versão no repositório (ex: v12.0.0166-freeze) |
| **git branch** | Ramificação de desenvolvimento (ex: evolucao/v12.0.0170-esteira) |
| **TConfig** | Tipo estruturado que causa erro se duplicado (já resolvido em Importador_VBA) |
| **WithEvents** | Padrão VBA para capturar eventos de objetos |
| **Round(x, 2)** | Arredondar para 2 casas decimais |
| **Suspensão** | Estado quando empresa tem desempenho ruim (média < 5.0) |
| **Rodízio** | Sistema de fila para seleção justa de empresas |

---

**FIM DO DOCUMENTO — ESTEIRA COMPLETA DE V12.0.0166 → V12.0.0170**
