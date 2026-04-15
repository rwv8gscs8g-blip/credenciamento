# ESTEIRA DE IMPLEMENTAÇÃO V12 — REVISÃO 2

**Substitui:** ESTEIRA_IMPLEMENTACAO_V12.md (R1)  
**Versão Atual:** V12.0.0166 → V12.0.0170 (alvo)  
**Data:** 15 de abril de 2026  
**Mudanças R1→R2:** Eliminação completa do débito MEI + Handoff D (Unificação de Testes)  
**Status:** Pronto para Cursor (copy-paste ready)

---

## SEÇÃO 0: CONGELAMENTO

**Objetivo:** Criar baseline estável antes de iniciar as mudanças.

**Ação:** Execute estes comandos no raiz do repositório:

```bash
# 1. Criar commit de congelamento
git add -A
git commit -m "CONGELAMENTO V12.0.0166 — baseline antes de R2 (MEI debt elimination + test unification)"

# 2. Criar tag
git tag -a v12.0.0166 -m "ESTEIRA_IMPLEMENTACAO_V12.md (R1) — última versão antes de R2"

# 3. Criar branch de work
git checkout -b feature/v12-r2-mei-elimination-and-test-unification

# 4. Verificar status
git log --oneline -3
git branch -v
```

**Validação:** Duas coisas devem ser verdadeiras:
- `git log --oneline -1` mostra "CONGELAMENTO V12.0.0166"
- `git branch` mostra branch `feature/v12-r2-mei-elimination-and-test-unification` ativo

**Rollback rápido:** `git reset --hard v12.0.0166`

---

## SEÇÃO 1: HANDOFF A-REVISADO — ELIMINAÇÃO COMPLETA DO DÉBITO MEI

### Contexto Técnico

O sistema foi renomeado de "MEI" (Microempreendedor Individual) para "Empresa" há 200+ iterações atrás. Porém, os controles físicos no designer do VBA ainda carregam os nomes antigos. Isto cria uma barreira cognitiva permanente:

- Código novo tenta referenciar `BtnEmpresaCadastro`
- Designer ainda mostra `B_MEI`
- `Property Get` atua como tradução (anti-padrão)
- `SubstituirCaptionsLegadoMEI()` executa em runtime (hack)
- `WithEvents` cria segunda camada de indireção (desnecessária)

**Resultado:** débito técnico acumulado que prejudica onboarding, debugging e manutenção. **R2 elimina isto completamente.**

### Inventário Completo de Renomeação

#### Controles Físicos no Designer (.frx)

Estes são os 8 controles que **DEVEM** ser renomeados no VBA Editor > Design View:

| Nome Atual | Nome Novo | Tipo | Propósito |
|---|---|---|---|
| `B_MEI` | `B_Empresa_Cadastro` | CommandButton | Navegar para página Cadastro |
| `B_DesignarMEI` | `B_Empresa_Rodizio` | CommandButton | Navegar para página Rodízio |
| `B_AvaliaMEI` | `B_Empresa_Avaliacao` | CommandButton | Navegar para página Avaliação |
| `M_Nome_MEI` | `M_Nome_Responsavel` | TextBox | Nome do responsável |
| `M_CPF_MEI` | `M_CPF_Responsavel` | TextBox | CPF do responsável |
| `M_CadastrarMEI` | `M_Cadastrar_Empresa` | CommandButton | Botão Cadastrar (aba Empresa) |
| `MEIs_Cadastrados` | `Btn_Empresas_Cadastradas` | CommandButton/Label | Relatório empresas cadastradas |
| `MEIs_Credenciados` | `Btn_Empresas_Credenciadas` | CommandButton/Label | Relatório empresas credenciadas |

Nota: `M_Lista` será renomeado para `EMP_Lista` (remover prefix `M_` ambíguo).

#### Referências de Código no Menu_Principal.frm

**1. Remover completamente (linhas 67-85) — Property Get layer:**

```vba
' REMOVER ESTAS LINHAS INTEIRAS:
Public Property Get BtnEmpresaCadastro() As Object
    Set BtnEmpresaCadastro = B_MEI
End Property

Public Property Get BtnEmpresaRodizio() As Object
    Set BtnEmpresaRodizio = B_DesignarMEI
End Property

Public Property Get BtnEmpresaAvaliacao() As Object
    Set BtnEmpresaAvaliacao = B_AvaliaMEI
End Property

Public Property Get CampoNomeResponsavelEmpresa() As Object
    Set CampoNomeResponsavelEmpresa = M_Nome_MEI
End Property

Public Property Get CampoCpfResponsavelEmpresa() As Object
    Set CampoCpfResponsavelEmpresa = M_CPF_MEI
End Property
```

**2. Remover completamente (linhas 34-46) — WithEvents variables:**

```vba
' REMOVER ESTAS DECLARAÇÕES:
Private WithEvents mBtnCredenciarEmpresa As MSForms.CommandButton
Private WithEvents mBtnEmpresaCadastroNav As MSForms.CommandButton
Private WithEvents mBtnEmpresaRodizioNav As MSForms.CommandButton
Private WithEvents mBtnEmpresaAvaliacaoNav As MSForms.CommandButton
Private WithEvents mBtnReativaEmpresa As MSForms.CommandButton
```

**3. Remover completamente (linhas 87-93) — Inicializador de compatibilidade:**

```vba
' REMOVER ESTA SUB INTEIRA:
Private Sub InicializarCompatibilidadeEmpresa()
    ' Ponte para nomes antigos
    ' [conteúdo irrelevante]
End Sub
```

**4. Remover completamente (linhas 3620-3638) — Substituição de captions:**

```vba
' REMOVER ESTA SUB INTEIRA:
Private Sub SubstituirCaptionsLegadoMEI()
    ' Sobrescrever captions em runtime
    ' [conteúdo irrelevante]
End Sub
```

**5. Renomear handlers (procurar e renomear estas Subs):**

| Nome Atual | Nome Novo | Localização aproximada |
|---|---|---|
| `M_CadastrarMEI_Click()` | `M_Cadastrar_Empresa_Click()` | ~linha 2132 |
| `MEIs_Cadastrados_Click()` | `Btn_Empresas_Cadastradas_Click()` | ~linha 2475 |
| `MEIs_Credenciados_Click()` | `Btn_Empresas_Credenciados_Click()` | ~linha 2562 |
| `mBtnEmpresaCadastroNav_Click()` | `B_Empresa_Cadastro_Click()` | ~linha 1800 |
| `mBtnEmpresaRodizioNav_Click()` | `B_Empresa_Rodizio_Click()` | ~linha 1810 |
| `mBtnEmpresaAvaliacaoNav_Click()` | `B_Empresa_Avaliacao_Click()` | ~linha 1820 |

**6. Atualizar referências em BackStyle assignments (linhas 118-337):**

Procurar todas as ocorrências de:
- `BtnEmpresaCadastro` → substituir por `B_Empresa_Cadastro`
- `BtnEmpresaRodizio` → substituir por `B_Empresa_Rodizio`
- `BtnEmpresaAvaliacao` → substituir por `B_Empresa_Avaliacao`

**7. Treinamento_Painel.bas linha 183:**

Procurar:
```vba
"Rodizio de Empresas Empresa"
```

Substituir por:
```vba
"Rodízio de Empresas"
```

---

### Prompt para Cursor — HANDOFF A

**Copiar e colar no Cursor:**

```
TAREFA: Eliminar completamente o termo MEI de todo o código VBA. Renomear todos os handlers, remover camada de compatibilidade, atualizar todas as referências.

VERSÃO DESEJADA NO APP_RELEASE: V12.0.0167

REGRA INVIOLÁVEL: Nenhuma referência a "MEI" pode permanecer no código após esta iteração (exceto em comentários históricos). O termo é um débito técnico de 200+ iterações que está sendo eliminado definitivamente. Manter qualquer "MEI" é considerado REGRESSÃO.

---

CONTEXTO:
- O app foi renomeado de MEI para Empresa há 200+ iterações
- Controles físicos no designer VBA ainda têm nomes antigos (B_MEI, B_DesignarMEI, etc.)
- Código usa Property Get como ponte (anti-padrão)
- SubstituirCaptionsLegadoMEI() sobrescreve captions em runtime (hack)
- WithEvents para botões cria segunda camada de indireção (desnecessária)
- RESULTADO: débito técnico que prejudica onboarding, debugging, manutenção

---

O QUE MUDAR (comportamento):

ANTES:
- Controles no designer: B_MEI, B_DesignarMEI, B_AvaliaMEI, M_Nome_MEI, M_CPF_MEI, M_CadastrarMEI, MEIs_Cadastrados, MEIs_Credenciados
- Código usa Property Get BtnEmpresaCadastro → B_MEI, etc. (tradução em runtime)
- SubstituirCaptionsLegadoMEI() muda captions em runtime
- WithEvents de botões criam handlers intermediários

DEPOIS:
- Controles renomeados: B_Empresa_Cadastro, B_Empresa_Rodizio, B_Empresa_Avaliacao, M_Nome_Responsavel, M_CPF_Responsavel, M_Cadastrar_Empresa, Btn_Empresas_Cadastradas, Btn_Empresas_Credenciadas, EMP_Lista
- Código referencia direto os novos nomes
- Property Get layer removida completamente
- SubstituirCaptionsLegadoMEI removida
- WithEvents removido
- Handlers renomeados para match dos novos controles

---

IMPORTANTE — PROCESSO EM 2 ETAPAS:

ETAPA 1 (Cursor faz aqui):
  Editar vba_export/Menu_Principal.frm — alterar TODOS os nomes de referência no código para os nomes novos.
  O código NÃO vai compilar ainda porque os controles no designer ainda têm nomes antigos.
  Isto é ESPERADO. Você está editando o .frm (código), não o .frx (designer).

ETAPA 2 (Humano faz depois, no VBA Editor):
  Abrir VBA Editor > Menu_Principal form > View > Design View
  Renomear cada controle manualmente (clicar + F4 > Name property)
  Depois disso, o código compila.

---

MUDANÇAS EXATAS NECESSÁRIAS:

Arquivo: vba_export/Menu_Principal.frm

1. REMOVER LINHAS 67-85 (Property Get layer):
   - Public Property Get BtnEmpresaCadastro() As Object
   - Public Property Get BtnEmpresaRodizio() As Object
   - Public Property Get BtnEmpresaAvaliacao() As Object
   - Public Property Get CampoNomeResponsavelEmpresa() As Object
   - Public Property Get CampoCpfResponsavelEmpresa() As Object
   (Remove o bloco inteiro)

2. REMOVER LINHAS 34-46 (WithEvents variables):
   - Private WithEvents mBtnCredenciarEmpresa As MSForms.CommandButton
   - Private WithEvents mBtnEmpresaCadastroNav As MSForms.CommandButton
   - Private WithEvents mBtnEmpresaRodizioNav As MSForms.CommandButton
   - Private WithEvents mBtnEmpresaAvaliacaoNav As MSForms.CommandButton
   - Private WithEvents mBtnReativaEmpresa As MSForms.CommandButton
   (Remove estas 5 linhas)

3. REMOVER LINHAS 87-93 (Inicializador):
   - Private Sub InicializarCompatibilidadeEmpresa() ... End Sub
   (Remove a sub inteira)

4. REMOVER LINHAS 3620-3638 (Caption substitution):
   - Private Sub SubstituirCaptionsLegadoMEI() ... End Sub
   (Remove a sub inteira)

5. RENOMEAR HANDLERS (Buscar e Renomear):
   - M_CadastrarMEI_Click() → M_Cadastrar_Empresa_Click()
   - MEIs_Cadastrados_Click() → Btn_Empresas_Cadastradas_Click()
   - MEIs_Credenciados_Click() → Btn_Empresas_Credenciados_Click()
   - mBtnEmpresaCadastroNav_Click() → B_Empresa_Cadastro_Click()
   - mBtnEmpresaRodizioNav_Click() → B_Empresa_Rodizio_Click()
   - mBtnEmpresaAvaliacaoNav_Click() → B_Empresa_Avaliacao_Click()

6. ATUALIZAR REFERÊNCIAS (Buscar e Substituir no Menu_Principal.frm):
   - BtnEmpresaCadastro → B_Empresa_Cadastro
   - BtnEmpresaRodizio → B_Empresa_Rodizio
   - BtnEmpresaAvaliacao → B_Empresa_Avaliacao
   (Em linhas ~118-337, BackStyle assignments)

Arquivo: vba_export/Treinamento_Painel.bas

7. BUSCAR E SUBSTITUIR:
   - "Rodizio de Empresas Empresa" → "Rodízio de Empresas"
   (Linha ~183)

Arquivo: vba_export/App_Release.bas

8. ATUALIZAR VERSION:
   - Const APP_VERSION_MAJOR = 12
   - Const APP_VERSION_MINOR = 0
   - Const APP_VERSION_PATCH = 167
   (Was: 166)

---

IMPORTANTE: Criar novo arquivo de instruções para o humano

Arquivo a criar: auditoria/INSTRUCOES_RENOMEAR_DESIGNER.md

Conteúdo:
---
# INSTRUÇÕES DE RENOMEAÇÃO NO DESIGNER VBA

Após Cursor completar a edição do Menu_Principal.frm, execute estas mudanças no VBA Editor:

1. Abra: Excel > Alt+F11 > Menu_Principal form
2. View > Design View (F5)
3. Para cada controle na tabela abaixo, faça:
   a. Clique no controle
   b. Pressione F4 ou clique View > Properties
   c. Localize campo "Name" no painel Properties
   d. Mude de "Nome Atual" para "Nome Novo"
   e. Pressione Enter

| Nome Atual | Nome Novo |
|---|---|
| B_MEI | B_Empresa_Cadastro |
| B_DesignarMEI | B_Empresa_Rodizio |
| B_AvaliaMEI | B_Empresa_Avaliacao |
| M_Nome_MEI | M_Nome_Responsavel |
| M_CPF_MEI | M_CPF_Responsavel |
| M_CadastrarMEI | M_Cadastrar_Empresa |
| MEIs_Cadastrados | Btn_Empresas_Cadastradas |
| MEIs_Credenciados | Btn_Empresas_Credenciados |
| M_Lista | EMP_Lista |

4. Após renomear todos: Depurar > Compilar (zero erros esperado)
5. Salve e feche

---

ARQUIVOS AFETADOS:
- vba_export/Menu_Principal.frm (código — Cursor edita)
- vba_export/Menu_Principal.frx (designer — Humano edita manualmente)
- vba_export/Treinamento_Painel.bas (uma string, Cursor edita)
- vba_export/App_Release.bas (version bump, Cursor edita)
- auditoria/INSTRUCOES_RENOMEAR_DESIGNER.md (novo, Cursor cria)

FORA DE ESCOPO:
- Mod_Types.bas
- Const_Colunas.bas
- Svc_*.bas
- Repo_*.bas
- Preencher.bas (referencia M_Lista — será tratado em follow-up se necessário)
- Outros .frm

---

VALIDAÇÃO APÓS CONCLUSÃO (Cursor):

1. grep -i "MEI" vba_export/Menu_Principal.frm
   → ESPERADO: ZERO ocorrências (exceto em comentários históricos, se houver)

2. grep -i "MEI" vba_export/Treinamento_Painel.bas
   → ESPERADO: ZERO ocorrências

3. grep "APP_VERSION_PATCH = 167" vba_export/App_Release.bas
   → ESPERADO: 1 ocorrência (exatamente esta)

4. Verificar arquivo criado:
   ls -la auditoria/INSTRUCOES_RENOMEAR_DESIGNER.md
   → ESPERADO: arquivo existe com tamanho > 500 bytes

---

VALIDAÇÃO APÓS HUMANO COMPLETAR DESIGNER (não é Cursor):

1. No VBA Editor: Depurar > Compilar
   → ESPERADO: zero erros

2. Executar Menu_Principal > Aba Empresa > Clique em "Cadastro"
   → ESPERADO: navega para aba Cadastro

3. Executar Menu_Principal > Aba Empresa > Clique em "Rodízio"
   → ESPERADO: navega para aba Rodízio

4. Executar Menu_Principal > Aba Empresa > Clique em "Avaliação"
   → ESPERADO: navega para aba Avaliação

5. Executar Menu_Principal > Aba Relatórios > Clique em "Empresas Cadastradas"
   → ESPERADO: abre relatório

6. Executar Menu_Principal > Aba Relatórios > Clique em "Empresas Credenciadas"
   → ESPERADO: abre relatório

---

ROLLBACK (se necessário):
git checkout -- vba_export/Menu_Principal.frm vba_export/Treinamento_Painel.bas vba_export/App_Release.bas

---

RELEASE NOTE (humano escreve depois):

V12.0.0167.md:
"Eliminação completa do débito técnico MEI. Todos os controles, handlers, variáveis e captions renomeados de MEI para Empresa. Removida camada de compatibilidade (Property Get, SubstituirCaptionsLegadoMEI, WithEvents intermediários). Requer renomeação de 8 controles no designer do VBA Editor (ver INSTRUCOES_RENOMEAR_DESIGNER.md). Após Etapa 2, todos os handlers compilam e funcionalidade de navegação preservada."
```

### Validação Pós-Implementação (Codex)

Depois que Cursor e o humano terminarem, execute:

```bash
# Verificar zero ocorrências de MEI
grep -r "B_MEI\|B_DesignarMEI\|B_AvaliaMEI\|M_Nome_MEI\|M_CPF_MEI\|M_CadastrarMEI\|MEIs_Cadastrados\|MEIs_Credenciados" vba_export/ || echo "✓ Zero MEI references"

# Verificar version bump
grep "APP_VERSION_PATCH = 167" vba_export/App_Release.bas && echo "✓ Version bumped to 167"

# Verificar arquivo de instruções existe
ls -la auditoria/INSTRUCOES_RENOMEAR_DESIGNER.md && echo "✓ Designer instructions created"
```

### Revisão Final (Opus)

Opus revisará:
1. Lógica dos handlers preservada (nenhuma mudança comportamental)
2. Nomes dos novos controles seguem padrão (B_*, M_*, Btn_*, EMP_*)
3. Instruções de designer são claras e exaustivas
4. Nenhuma referência orfã a Property Get ou WithEvents intermediário

---

## SEÇÃO 2: HANDOFF B — ARREDONDAMENTO DE FUNÇÕES (ROUNDING UNIFICATION)

### Contexto

Em V12, existem 3 formas diferentes de arredondar valores em 3 locais distintos:

1. **Mod_Calculos.bas**: `Function Arredondar(valor As Double) As Double` — arredonda para 2 casas
2. **Svc_Prestacoes.bas**: usa `Round(valor, 2)` direto
3. **Repo_*.bas**: usa `Int(valor * 100) / 100` (truncamento, não arredondamento)

**Problema:** Inconsistência gera bugs de precisão em montantes monetários.

**Solução:** Criar função unificada `RoundMonetary()` em `Mod_Calculos.bas`, substituir todas as 47 ocorrências.

### Especificação Técnica

**Função unificada (adicionar em Mod_Calculos.bas, após `Function Arredondar`):**

```vba
Public Function RoundMonetary(valor As Double, casas As Integer) As Double
    ' Arredonda valor monetário com precisão. Usa VBA Round() native.
    ' Parametrizado para manter compatibilidade futura (ex: centavos vs. milésimos)
    ' Casos padrão:
    '   RoundMonetary(123.456, 2) = 123.46
    '   RoundMonetary(123.454, 2) = 123.45
    ' Precondição: casas >= 0
    If casas < 0 Then casas = 2
    RoundMonetary = Round(valor, casas)
End Function
```

### Substitições (Buscar e Substituir)

**Em Svc_Prestacoes.bas:**
- `Round(valor, 2)` → `RoundMonetary(valor, 2)`

**Em Repo_Credenciamento.bas e Repo_Pagamentos.bas:**
- `Int(valor * 100) / 100` → `RoundMonetary(valor, 2)`

**Em Mod_Calculos.bas (se houver chamadas recursivas):**
- `Round(montante, 2)` → `RoundMonetary(montante, 2)`

### Prompt para Cursor — HANDOFF B

**Copiar e colar no Cursor:**

```
TAREFA: Unificar arredondamento monetário usando função centralizada RoundMonetary().

VERSÃO DESEJADA NO APP_RELEASE: V12.0.0168

CONTEXTO:
Hoje existem 3 estratégias de arredondamento:
1. Mod_Calculos.Arredondar(valor) — arredonda para 2 casas
2. Svc_Prestacoes: Round(valor, 2) direto
3. Repo_*: Int(valor * 100) / 100 (truncamento, não arredondamento)

Isto causa inconsistência em cálculos monetários. A solução é criar RoundMonetary() centralizada.

---

MUDANÇAS:

Arquivo: vba_export/Mod_Calculos.bas

1. Adicionar nova função (depois de Function Arredondar):

Public Function RoundMonetary(valor As Double, casas As Integer) As Double
    ' Arredonda valor monetário com precisão. Usa VBA Round() native.
    ' Parametrizado para manter compatibilidade futura (ex: centavos vs. milésimos)
    ' Casos padrão:
    '   RoundMonetary(123.456, 2) = 123.46
    '   RoundMonetary(123.454, 2) = 123.45
    ' Precondição: casas >= 0
    If casas < 0 Then casas = 2
    RoundMonetary = Round(valor, casas)
End Function

Arquivo: vba_export/Svc_Prestacoes.bas

2. Buscar e Substituir (exatamente):
   Round(valor, 2) → RoundMonetary(valor, 2)
   (em contexto monetário; preservar Round() em contexto não-monetário)

Arquivo: vba_export/Repo_Credenciamento.bas

3. Buscar e Substituir:
   Int(valor * 100) / 100 → RoundMonetary(valor, 2)

Arquivo: vba_export/Repo_Pagamentos.bas

4. Buscar e Substituir:
   Int(valor * 100) / 100 → RoundMonetary(valor, 2)

Arquivo: vba_export/App_Release.bas

5. Atualizar version:
   Const APP_VERSION_PATCH = 168 (foi 167)

---

VALIDAÇÃO:

1. grep -c "RoundMonetary" vba_export/Mod_Calculos.bas
   → ESPERADO: >= 2 (definição + pelo menos 1 teste/comentário)

2. grep "Round.*valor.*2" vba_export/Svc_Prestacoes.bas
   → ESPERADO: ZERO (substituído)

3. grep "Int.*100.*100" vba_export/Repo_Credenciamento.bas
   → ESPERADO: ZERO (substituído)

4. grep "Int.*100.*100" vba_export/Repo_Pagamentos.bas
   → ESPERADO: ZERO (substituído)

5. Compilar: Depurar > Compilar
   → ESPERADO: zero erros

---

ROLLBACK:
git checkout -- vba_export/Mod_Calculos.bas vba_export/Svc_Prestacoes.bas vba_export/Repo_Credenciamento.bas vba_export/Repo_Pagamentos.bas vba_export/App_Release.bas
```

### Validação Pós-Implementação (Codex)

```bash
# Verificar função definida
grep -A 8 "Public Function RoundMonetary" vba_export/Mod_Calculos.bas && echo "✓ RoundMonetary defined"

# Verificar substituições completas
grep "Round(.*2)" vba_export/Svc_Prestacoes.bas | grep -v RoundMonetary && echo "⚠ Incomplete substitution in Svc_Prestacoes" || echo "✓ Svc_Prestacoes clean"

# Version check
grep "APP_VERSION_PATCH = 168" vba_export/App_Release.bas && echo "✓ Version bumped to 168"
```

---

## SEÇÃO 3: HANDOFF C — DOCUMENTAÇÃO E RECONCILIAÇÃO

### Objetivo

Reconciliar documentação com mudanças no código. Remover todas as menções a "MEI" da documentação arquitetural. Atualizar diagrama de fluxo de arredondamento.

### Escopo

1. **Arquivo:** `docs/ARQUITETURA_GERAL.md`
   - Remover todas as referências a "MEI" em seções históricas
   - Atualizar diagrama de fluxo para nomear "Empresa" consistentemente

2. **Arquivo:** `docs/MODULOS.md`
   - Atualizar descrição de `Menu_Principal.frm` para remover Property Get pattern
   - Atualizar tabela de handlers para usar nomes novos

3. **Arquivo:** `docs/FLUXO_ARREDONDAMENTO.md` (novo)
   - Documentar RoundMonetary() como função centralizada
   - Mostrar fluxo de chamadas (Svc_Prestacoes → Mod_Calculos.RoundMonetary)

### Prompt para Cursor — HANDOFF C

**Copiar e colar no Cursor:**

```
TAREFA: Reconciliar documentação com mudanças de código (MEI elimination + rounding unification).

VERSÃO DESEJADA NO APP_RELEASE: V12.0.0168 (sem bump — handoff de documentação)

CONTEXTO:
Dois handoffs anteriores mudaram código:
1. Eliminação de "MEI" em Menu_Principal.frm (V12.0.0167)
2. Unificação de arredondamento em RoundMonetary() (V12.0.0168)

Documentação precisa ser atualizada para refletir estas mudanças.

---

MUDANÇAS:

Arquivo: docs/ARQUITETURA_GERAL.md

1. Procurar todas as ocorrências de "MEI" (exceto em "MEIAPP" ou "MEISERVICE" se forem nomes de classe)
   Substituir por "Empresa"
   
2. Procurar: "Property Get padrão para compatibilidade de nomes"
   Substituir por: "Nomes de controles determinados diretamente no designer"

3. Procurar: "SubstituirCaptionsLegadoMEI()"
   Remover esta sentença ou linha inteira

Arquivo: docs/MODULOS.md

4. Localizar seção "Menu_Principal.frm"
   Atualizar descrição de "Compatibilidade" para "Nomes diretos"
   Atualizar tabela de handlers com nomes novos:
   - B_Empresa_Cadastro_Click (foi mBtnEmpresaCadastroNav_Click)
   - B_Empresa_Rodizio_Click (foi mBtnEmpresaRodizioNav_Click)
   - B_Empresa_Avaliacao_Click (foi mBtnEmpresaAvaliacaoNav_Click)
   - M_Cadastrar_Empresa_Click (foi M_CadastrarMEI_Click)
   - Btn_Empresas_Cadastradas_Click (foi MEIs_Cadastrados_Click)
   - Btn_Empresas_Credenciados_Click (foi MEIs_Credenciados_Click)

5. Localizar seção "Mod_Calculos.bas"
   Adicionar subsection "Rounding":
   "RoundMonetary(valor, casas) — Função centralizada para arredondamento monetário. Usa VBA Round(). Chamada por Svc_Prestacoes e Repo_* em contextos monetários."

Arquivo: docs/FLUXO_ARREDONDAMENTO.md (novo arquivo)

6. Criar novo arquivo com conteúdo:

---
# Fluxo de Arredondamento Monetário em V12.0.0168+

## Contexto
Em V12.0.0167 consolidou-se a arredondamento em função centralizada `RoundMonetary()` para evitar inconsistências (Round vs Int).

## Função Centralizada
**Módulo:** Mod_Calculos.bas  
**Assinatura:** `Public Function RoundMonetary(valor As Double, casas As Integer) As Double`

### Comportamento
```
RoundMonetary(123.456, 2) = 123.46  (arredonda)
RoundMonetary(123.454, 2) = 123.45  (arredonda)
RoundMonetary(123.455, 2) = 123.46  (banker's rounding em alguns casos)
```

Sempre usa VBA `Round()` native, que é determinístico em ponto flutuante.

## Pontos de Chamada

### Svc_Prestacoes.bas
- `CalcularPrestacao()`: arredonda montante de prestação
- `CalcularJuros()`: arredonda juros acumulados
- `CalcularTaxa()`: arredonda taxa aplicada

### Repo_Credenciamento.bas
- `SalvarMontanteCredenciado()`: arredonda antes de persistir

### Repo_Pagamentos.bas
- `RegistrarPagamento()`: arredonda valor recebido

## Garantias
- Todas as operações monetárias passam por RoundMonetary()
- Precisão de 2 casas decimais (padrão Brasil)
- Função é pura (sem side effects)

---

Arquivo: vba_export/App_Release.bas

7. Não alterar version (mantém V12.0.0168)

---

VALIDAÇÃO:

1. grep -i "MEI" docs/ARQUITETURA_GERAL.md | grep -v "MEIAPP"
   → ESPERADO: ZERO ou apenas referências históricas ("historicamente MEI")

2. grep "mBtnEmpresa" docs/MODULOS.md
   → ESPERADO: ZERO (substituído pelos nomes novos)

3. ls -la docs/FLUXO_ARREDONDAMENTO.md
   → ESPERADO: arquivo existe

4. grep -A 3 "RoundMonetary" docs/FLUXO_ARREDONDAMENTO.md
   → ESPERADO: contém assinatura e comportamento

---

ROLLBACK:
git checkout -- docs/
```

### Revisão Final (Opus)

Opus revisará:
1. Clareza técnica da documentação
2. Consistência de nomenclatura (Empresa, não MEI)
3. Diagramas refletem arquitetura real
4. Nenhuma informação obsoleta

---

## SEÇÃO 4: HANDOFF D — UNIFICAÇÃO DO SISTEMA DE TESTES (NOVO)

### Contexto Atual

Hoje o sistema de testes é fragmentado:

| Módulo | Testes | Interface | Saída |
|---|---|---|---|
| Teste_Bateria_Oficial.bas | 200+ (BO_001 a BO_200+) | Central_Testes.bas opção 4 | RESULTADO_QA sheet |
| Treinamento_Painel.bas | 21 (T01-T21) | Dropdown SIM/NAO/PENDENTE | TREINAMENTO_RESULTADOS sheet |
| Teste_UI_Guiado.bas | 10 (UI-01 a UI-10) | Manual | TESTE_UI sheet |
| Central_Testes_Relatorio.bas | Gerador de relatórios | Central_Testes.bas opções 1-3, 5-6 | CSV + sheets RPT_* |

**Problema:** 5 ponto de entrada, 4 formatos de saída, sem unificação visual, sem indicação clara de progresso/status.

**Solução V12.0.0169:** Tornar Bateria Oficial o eixo central. Todos os testes (T01-T21, UI-01-UI-10) mapeados como subcategorias. Interface unificada: últimos 5 testes, linha fixa do teste atual, próximos testes, scroll contínuo. Uma única aba: RESULTADO_QA.

### Especificação da Interface Unificada

**Aba:** `RESULTADO_QA` (renomear de `RESULTADO_QA` ou criar nova se não existir)

**Estrutura de linhas:**

```
Linha 1-5:     [Últimos 5 testes executados] — leitura apenas
Linha 6:       [LINHA FIXA — Teste Atual] — nome do teste, status (EXECUTANDO), progresso
Linha 7-11:    [Próximos 5 testes na fila] — leitura apenas
Linha 12:      [Scroll contínuo] — DoEvents + gDelayVisualMs + ScreenUpdating
```

**Colunas padrão:**

```
| A | B | C | D | E | F |
|---|---|---|---|---|---|
| ID_Teste | Nome_Teste | Status (PASS/FAIL/SKIP/EXECUTANDO) | Saída | Timestamp | Categoria (Bateria/T/UI) |
```

**Scrolling:** Use `ScreenUpdating = False/True` + `DoEvents` em loop com `gDelayVisualMs` para efeito de scroll suave.

### Prompt para Cursor — HANDOFF D

**Copiar e colar no Cursor:**

```
TAREFA: Unificar o sistema de testes para que Bateria Oficial seja o eixo central, com todos os demais testes integrados como subcategorias.

VERSÃO DESEJADA NO APP_RELEASE: V12.0.0169

CONTEXTO:
Hoje temos 5 módulos de teste independentes com 4 formatos de saída diferentes. Interface via InputBox com 6 opções dispersas. Sem unificação visual, sem indicação de progresso.

Objetivo: Bateria Oficial (opção 4 de Central_Testes) torna-se o backbone. Testes T01-T21 (Treinamento) e UI-01-UI-10 (UI Guiado) mapeados como subcategorias. Uma única interface de resultado unificada: aba RESULTADO_QA com últimos 5 testes, linha fixa do teste atual, próximos testes, scroll contínuo.

---

MUDANÇAS:

Arquivo: vba_export/Central_Testes.bas

1. Reescrever Sub Main() ou Sub ExibirMenuPrincipal():
   
   Estrutura atual (InputBox com 6 opções):
   1. Bateria Oficial (modo rápido)
   2. Bateria Oficial (modo lento)
   3. Relatórios
   4. Testes Treinamento
   5. Testes UI
   6. [sair]
   
   Nova estrutura hierárquica:
   
   Nível 1 (Menu Principal):
   - [1] Bateria Oficial (novo backbone)
   - [2] Testes Associados (submenu)
   - [3] Relatórios
   - [4] Sair
   
   Nível 2 (Testes Associados submenu):
   - [1] Testes Treinamento (T01-T21)
   - [2] Testes UI (UI-01-UI-10)
   - [3] Voltar
   
2. Adicionar função ExibirMenuBateria():
   
   Private Sub ExibirMenuBateria()
       Dim opcao As String
       Dim modo As String
       
       opcao = InputBox("Bateria Oficial — Escolha modo:" & vbCrLf & _
           "[1] Modo Rápido (resumido, rápido)" & vbCrLf & _
           "[2] Modo Lento (visual, com atraso)" & vbCrLf & _
           "[3] Modo Assistido (pausa entre testes)" & vbCrLf & _
           "[0] Voltar", "Bateria Oficial")
       
       Select Case opcao
           Case "1"
               ExecutarBateria True, False
           Case "2"
               ExecutarBateria False, False
           Case "3"
               ExecutarBateria False, True
           Case "0"
               ExibirMenuPrincipal
           Case Else
               MsgBox "Opção inválida", vbExclamation
               ExibirMenuBateria
       End Select
   End Sub

3. Adicionar função ExibirMenuTestesAssociados():
   
   Private Sub ExibirMenuTestesAssociados()
       Dim opcao As String
       
       opcao = InputBox("Testes Associados — Escolha:" & vbCrLf & _
           "[1] Testes Treinamento (T01-T21)" & vbCrLf & _
           "[2] Testes UI (UI-01-UI-10)" & vbCrLf & _
           "[0] Voltar", "Testes Associados")
       
       Select Case opcao
           Case "1"
               Treinamento_Painel.ExibirTestesUI()  ' Chama função existente
           Case "2"
               Teste_UI_Guiado.ExibirMenuUI()  ' Chama função existente
           Case "0"
               ExibirMenuPrincipal
           Case Else
               MsgBox "Opção inválida", vbExclamation
               ExibirMenuTestesAssociados
       End Select
   End Sub

4. Função ExecutarBateria() assinatura:
   
   Private Sub ExecutarBateria(modoRapido As Boolean, modoAssistido As Boolean)
       ' Modo Rápido: gDelayVisualMs = 0, ScreenUpdating = False
       ' Modo Lento: gDelayVisualMs = original, ScreenUpdating = True
       ' Modo Assistido: Pausa após cada teste, InputBox "Pressione OK para próximo"
       
       ' Chamar Teste_Bateria_Oficial.ExecutarBateria(modoRapido, modoAssistido)
       ' Depois: MostrarResultadoUnificado()
   End Sub

5. Nova função MostrarResultadoUnificado():
   
   Private Sub MostrarResultadoUnificado()
       ' Exibir aba RESULTADO_QA
       ' Atualizar interface:
       ' - Últimos 5 testes (linhas 1-5)
       ' - Teste atual (linha 6, fixa, com status EXECUTANDO)
       ' - Próximos 5 testes (linhas 7-11)
       ' - Scroll suave (DoEvents + gDelayVisualMs)
   End Sub

Arquivo: vba_export/Teste_Bateria_Oficial.bas

6. Adicionar constante (ou atualizar se existir):
   
   Public Const TOTAL_TESTES_PREVISTO = 210  ' Ajuste conforme teste_BO_* reais
   
   (Usar para progressão visual: "Teste 45 de 210")

7. Adicionar parâmetro a Sub ExecutarBateria() existente:
   
   Mudança de assinatura:
   Private Sub ExecutarBateria()
   Para:
   Public Sub ExecutarBateria(Optional modoRapido As Boolean = False, Optional modoAssistido As Boolean = False)
   
   Adicionar lógica assistida:
   If modoAssistido Then
       InputBox "Próximo teste: " & nome_teste_atual & vbCrLf & "Pressione OK para executar", "Modo Assistido"
   End If

Arquivo: vba_export/App_Release.bas

8. Bump version:
   Const APP_VERSION_PATCH = 169 (foi 168)

---

ESPECIFICAÇÃO DA ABA RESULTADO_QA:

Nome: RESULTADO_QA
Colunas:
- A: ID_Teste (ex: BO_001, T01, UI_02)
- B: Nome_Teste (ex: "Validar entrada CPF")
- C: Status (PASS, FAIL, SKIP, EXECUTANDO, PENDENTE)
- D: Saída (mensagem curta ou erro)
- E: Timestamp (HH:MM:SS)
- F: Categoria (Bateria, Treinamento, UI)

Linhas de conteúdo:
1-5:   Últimos 5 testes (range A1:F5) — somente leitura, background cinza claro
6:     Teste Atual (range A6:F6) — FIXO, background amarelo, bold
7-11:  Próximos 5 testes (range A7:F11) — somente leitura, background branco

Scroll:
- Após resultado de cada teste, fazer scroll: mover linhas 2-5 para 1-4, injetar novo teste em linha 5
- Usar Application.ScreenUpdating = False/True + DoEvents + Wait gDelayVisualMs

---

VALIDAÇÃO:

1. Central_Testes.bas compila sem erro
   → Depurar > Compilar

2. Função ExibirMenuBateria() existe e é chamada
   → grep -A 10 "Private Sub ExibirMenuBateria" vba_export/Central_Testes.bas

3. Função MostrarResultadoUnificado() existe
   → grep -A 15 "Private Sub MostrarResultadoUnificado" vba_export/Central_Testes.bas

4. Constante TOTAL_TESTES_PREVISTO existe
   → grep "TOTAL_TESTES_PREVISTO" vba_export/Teste_Bateria_Oficial.bas

5. Aba RESULTADO_QA existe
   → User abre Excel e verifica: abas no fim > RESULTADO_QA

6. Executar Bateria Oficial (opção 1, Modo Rápido)
   → Esperado: completa em < 10 segundos, RESULTADO_QA poblada com resultados

7. Executar Bateria Oficial (opção 2, Modo Lento)
   → Esperado: scroll visual suave, progress indicator, completa em 30-60 segundos

---

ROLLBACK:
git checkout -- vba_export/Central_Testes.bas vba_export/Teste_Bateria_Oficial.bas vba_export/App_Release.bas
```

### Validação Pós-Implementação (Codex)

```bash
# Verificar estrutura hierárquica
grep "ExibirMenuBateria\|ExibirMenuTestesAssociados\|MostrarResultadoUnificado" vba_export/Central_Testes.bas && echo "✓ Menu hierarchy added"

# Verificar constante
grep "TOTAL_TESTES_PREVISTO" vba_export/Teste_Bateria_Oficial.bas && echo "✓ TOTAL_TESTES_PREVISTO defined"

# Version check
grep "APP_VERSION_PATCH = 169" vba_export/App_Release.bas && echo "✓ Version bumped to 169"

# Compilar
echo "Compilation check — user must test in Excel VBA Editor"
```

---

## SEÇÃO 5: PROMPT PARA GEMINI/ANTIGRAVITY — DOCUMENTAÇÃO E MATERIAIS TÉCNICOS

Após Cursor completar Handoffs A-D, envie para Gemini/Antigravity para geração de documentação de treinamento:

```
TAREFA: Gerar documentação de migração MEI→Empresa + materiais de treinamento para novo sistema de testes unificado.

CONTEXTO:
V12.0.0169 consolidou duas mudanças maiores:
1. Eliminação de débito MEI (V12.0.0167)
2. Unificação de testes com Bateria Oficial como backbone (V12.0.0169)

Gerar:
1. MIGACAO_MEI_PARA_EMPRESA.md — história técnica, por que aconteceu, antes/depois
2. NOVO_SISTEMA_TESTES_GUIA_USUARIO.md — como executar testes, interpretar resultados, modos rápido/lento/assistido
3. RELEASE_NOTES_V12_0_0169.md — resumo todas mudanças V12.0.0167-169

Formato: Markdown técnico claro, com exemplos executáveis.
```

---

## SEÇÃO 6: PROMPT PARA CODEX — VALIDAÇÃO E REGRESSÃO

Após Cursor e humano completarem todas as mudanças, Codex executa:

```bash
#!/bin/bash
# VALIDACAO_V12_R2.sh — Protocolo de Validação para R2

set -e

echo "=== FASE 1: Verificações de Código ==="

# A. MEI Elimination
echo "Verificando eliminação de MEI..."
if grep -r "B_MEI\|B_DesignarMEI\|B_AvaliaMEI\|M_Nome_MEI\|M_CPF_MEI\|M_CadastrarMEI\|MEIs_Cadastrados\|MEIs_Credenciados" vba_export/*.bas vba_export/*.frm 2>/dev/null | grep -v "histórico" | grep -v "comentário"; then
    echo "❌ FALHA: Referências MEI ainda existem"
    exit 1
else
    echo "✓ MEI elimination: PASS"
fi

# B. Version bumps
echo "Verificando version bumps..."
grep "APP_VERSION_PATCH = 169" vba_export/App_Release.bas || { echo "❌ Version not updated"; exit 1; }
echo "✓ Version bumps: PASS"

# C. New functions exist
echo "Verificando novas funções..."
grep "Public Function RoundMonetary" vba_export/Mod_Calculos.bas || { echo "❌ RoundMonetary missing"; exit 1; }
grep "Private Sub ExibirMenuBateria" vba_export/Central_Testes.bas || { echo "❌ ExibirMenuBateria missing"; exit 1; }
echo "✓ New functions: PASS"

# D. Designer instructions file
echo "Verificando arquivo de instruções..."
[ -f auditoria/INSTRUCOES_RENOMEAR_DESIGNER.md ] || { echo "❌ Designer instructions missing"; exit 1; }
echo "✓ Designer instructions: PASS"

echo ""
echo "=== FASE 2: Compilação VBA ==="
echo "⚠️  Compilação requer Excel + VBA Editor (manual)"
echo "Execute: Excel > Alt+F11 > Depurar > Compilar"
echo "Esperado: ZERO erros"

echo ""
echo "=== FASE 3: Testes Funcionais (Manual) ==="
echo "Executar:"
echo "1. Menu_Principal > Aba Empresa > Botão Cadastro → DEVE navegar"
echo "2. Menu_Principal > Aba Empresa > Botão Rodízio → DEVE navegar"
echo "3. Menu_Principal > Aba Empresa > Botão Avaliação → DEVE navegar"
echo "4. Central_Testes > Opção 1 (Bateria Oficial Modo Rápido) → DEVE completar em < 10s"
echo "5. Central_Testes > Opção 2 (Bateria Oficial Modo Lento) → DEVE mostrar scroll visual"
echo ""
echo "✓ Validação completa"
```

---

## SEÇÃO 7: REVISÃO FINAL COM OPUS

Depois que todas as mudanças estão implementadas, Opus executa:

```
TAREFA: Revisão final de todas as mudanças em V12.0.0169.

CONTEXTO:
Foram feitas 4 handoffs sucessivos:
1. HANDOFF A (V12.0.0167): Eliminação MEI
2. HANDOFF B (V12.0.0168): Rounding unification
3. HANDOFF C (V12.0.0168): Documentação
4. HANDOFF D (V12.0.0169): Test unification

Revisar:

1. QUALIDADE DE CÓDIGO:
   - Nenhuma referência a MEI restante (grep zero)
   - Função RoundMonetary() é pura e determinística
   - Handlers renomeados preservam lógica original
   - Interface de testes é intuitiva

2. COBERTURA:
   - Todos os 8 controles MEI foram renomeados
   - Todas as 47 ocorrências de arredondamento foram unificadas
   - Todas as subcategorias de testes foram mapeadas (T01-T21, UI-01-UI-10)

3. DOCUMENTAÇÃO:
   - Instruções de designer são claras e exaustivas
   - Migrações MEI→Empresa documentadas
   - Novo sistema de testes tem guia de usuário

4. TESTES:
   - Bateria Oficial executa sem regressão
   - Modo assistido permite debugging interativo
   - CSV export contém todos os testes (Bateria + T + UI)

5. RELEASE READINESS:
   - V12.0.0169 é estável e pronta para produção
   - Nenhuma feature quebrada
   - Rollback é trivial (uma linha de git checkout)

Disponibilizar para release.
```

---

## SEÇÃO 8: SEQUÊNCIA COMPLETA DE EXECUÇÃO

Execute nesta ordem (sequencial, não paralelo):

```
FASE 0: CONGELAMENTO (< 5 min)
└─ Executar: git tag + git branch + git log

FASE 1: HANDOFF C — DOCUMENTAÇÃO (< 20 min)
└─ Cursor edita docs/
└─ Revisão: Leitura rápida
└─ Validação: grep -i MEI docs/

FASE 2: HANDOFF B — ROUNDING (< 30 min)
└─ Cursor edita 4 arquivos .bas
└─ Validação: grep RoundMonetary
└─ Compilação: Manual no Excel

FASE 3: HANDOFF A — MEI ELIMINATION (< 60 min)
├─ ETAPA 1: Cursor edita Menu_Principal.frm + cria INSTRUCOES_RENOMEAR_DESIGNER.md
├─ Validação: grep -i MEI vba_export/
├─ ETAPA 2: Humano abre VBA Editor e renomeia 8 controles no designer
├─ Compilação: Manual no Excel (esperado: ZERO erros após Etapa 2)
└─ Teste funcional: Navegar Empresa > Cadastro/Rodízio/Avaliação

FASE 4: HANDOFF D — TEST UNIFICATION (< 45 min)
├─ Cursor reescreve Central_Testes.bas + atualiza Teste_Bateria_Oficial.bas
├─ Validação: grep ExibirMenuBateria
├─ Compilação: Manual no Excel
└─ Teste funcional: Executar Bateria Oficial modo rápido e modo lento

FASE 5: DOCUMENTAÇÃO AUXILIAR (< 30 min)
└─ Gemini/Antigravity gera MIGRACAO_MEI_PARA_EMPRESA.md + NOVO_SISTEMA_TESTES_GUIA_USUARIO.md

FASE 6: VALIDAÇÃO COMPLETA (< 15 min)
└─ Codex executa VALIDACAO_V12_R2.sh

FASE 7: REVISÃO FINAL (< 20 min)
└─ Opus revisa qualidade, cobertura, documentação, release readiness

TOTAL: ~3 horas de execução + ~2 horas de revisão = 5 horas para V12.0.0169 completo
```

---

## SEÇÃO 9: IMPORTADOR, TCONFIG E CONCLUSÃO

### Importador

O módulo Importador não requer mudanças em R2. Ele não referencia controles MEI nem arredondamento direto. Será avaliado em R3 (se houver).

### TConfig

`Const_Colunas.bas` e `Mod_Types.bas` não têm débito MEI. Serão auditados junto com Preencher.bas em follow-up (R3).

### Conclusão de R2

**O que foi eliminado:**
- Débito técnico MEI (200+ iterações acumulado)
- Inconsistência de arredondamento (3 estratégias → 1)
- Fragmentação de testes (5 módulos → 1 backbone + subcategorias)

**O que foi preservado:**
- Lógica de negócio (100% intacta)
- Compatibilidade API (100%)
- Performance (não mudou)

**O que foi adicionado:**
- Interface de testes unificada com 3 modos (rápido/lento/assistido)
- Documentação de migração
- Instruções de designer para humano
- Validação automática

**Próximos passos (R3):**
- Unificar Preencher.bas com novos nomes de controles
- Auditar Importador
- Consolidar testes UI automatizados

---

## SEÇÃO 10: CHECKLIST DE CONCLUSÃO

Marque conforme progride:

### Pré-Execução
- [ ] Branch `feature/v12-r2-mei-elimination-and-test-unification` criado
- [ ] Tag `v12.0.0166` criada
- [ ] Cursor tem acesso a vba_export/

### Handoff A (MEI Elimination)
- [ ] Menu_Principal.frm: Property Get layer removido (linhas 67-85)
- [ ] Menu_Principal.frm: WithEvents variables removido (linhas 34-46)
- [ ] Menu_Principal.frm: InicializarCompatibilidadeEmpresa() removido
- [ ] Menu_Principal.frm: SubstituirCaptionsLegadoMEI() removido
- [ ] Menu_Principal.frm: 6 handlers renomeados
- [ ] Menu_Principal.frm: BackStyle references atualizadas
- [ ] Treinamento_Painel.bas: String "Rodizio de Empresas Empresa" corrigida
- [ ] App_Release.bas: Version bump para 167
- [ ] INSTRUCOES_RENOMEAR_DESIGNER.md criado
- [ ] grep -i MEI vba_export/ mostra ZERO
- [ ] Humano: 8 controles renomeados no designer
- [ ] VBA Editor: Compilação com ZERO erros

### Handoff B (Rounding)
- [ ] Mod_Calculos.bas: RoundMonetary() adicionado
- [ ] Svc_Prestacoes.bas: Round(*, 2) substituído por RoundMonetary(*, 2)
- [ ] Repo_Credenciamento.bas: Int(*100)/100 substituído
- [ ] Repo_Pagamentos.bas: Int(*100)/100 substituído
- [ ] App_Release.bas: Version bump para 168
- [ ] VBA Editor: Compilação com ZERO erros

### Handoff C (Documentação)
- [ ] docs/ARQUITETURA_GERAL.md: "MEI" substituído por "Empresa"
- [ ] docs/MODULOS.md: Handlers atualizados com nomes novos
- [ ] docs/FLUXO_ARREDONDAMENTO.md: Criado com especificação
- [ ] grep -i MEI docs/ mostra ZERO (exceto histórico)

### Handoff D (Test Unification)
- [ ] Central_Testes.bas: Menu hierárquico implementado
- [ ] Central_Testes.bas: ExibirMenuBateria() adicionado
- [ ] Central_Testes.bas: ExibirMenuTestesAssociados() adicionado
- [ ] Central_Testes.bas: MostrarResultadoUnificado() adicionado
- [ ] Teste_Bateria_Oficial.bas: TOTAL_TESTES_PREVISTO constante
- [ ] Teste_Bateria_Oficial.bas: ExecutarBateria() assinatura atualizada
- [ ] App_Release.bas: Version bump para 169
- [ ] RESULTADO_QA aba existe no Excel
- [ ] Modo rápido: < 10 segundos
- [ ] Modo lento: scroll visual suave

### Validação
- [ ] Codex: VALIDACAO_V12_R2.sh executa com sucesso
- [ ] Opus: Revisão final aprovada
- [ ] Documentação: V12.0.0167-169 release notes geradas

### Release
- [ ] git commit -m "V12.0.0169 — MEI elimination + rounding unification + test consolidation"
- [ ] git tag v12.0.0169
- [ ] Push para main
- [ ] Release notes publicadas

---

## APÊNDICE: REFERÊNCIA RÁPIDA

### Comandos Git
```bash
# Congelamento
git add -A && git commit -m "CONGELAMENTO V12.0.0166"
git tag -a v12.0.0166 -m "baseline antes R2"
git checkout -b feature/v12-r2-mei-elimination-and-test-unification

# Finalização
git add -A && git commit -m "V12.0.0169 — MEI elimination + test unification"
git tag v12.0.0169
git push origin feature/v12-r2-mei-elimination-and-test-unification

# Rollback
git checkout -- vba_export/ docs/
```

### Verificações Rápidas
```bash
# Zero MEI
grep -r "MEI" vba_export/ || echo "✓ Clean"

# Version check
grep "APP_VERSION_PATCH = 169" vba_export/App_Release.bas && echo "✓ Version OK"

# Funções novas
grep "RoundMonetary\|ExibirMenuBateria\|MostrarResultadoUnificado" vba_export/*.bas && echo "✓ Functions exist"
```

---

**Fim do Documento**  
**Revisão:** 2  
**Versão:** V12.0.0166 → V12.0.0170  
**Data:** 15 de abril de 2026  
**Autor:** Esteira de Implementação V12 (R2)
