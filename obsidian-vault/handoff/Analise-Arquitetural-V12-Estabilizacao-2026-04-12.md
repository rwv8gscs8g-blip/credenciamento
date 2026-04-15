# Análise Arquitetural Completa — Estabilização V12

Data: 2026-04-12
Release de referência: V12.0.0140
Autor: Claude Opus 4.6 (sessão de continuidade técnica)

---

## 1. Resumo Executivo

O sistema de credenciamento municipal em Excel VBA está na fase de estabilização da linha V12. A bateria de testes oficial está zerada em falhas, filtros de empresas/entidades funcionam, reativação/inativação estão estáveis, e o pipeline de release com `App_Release.bas` como fonte única está consolidado.

O problema recente concentra-se no bloco CNAE/Serviços. Houve uma sequência de 4 iterações (V12.0.0135 → V12.0.0140) tentando estabilizar a baseline estrutural de CNAEs. As decisões de negócio estavam corretas (ATIVIDADES = baseline permanente, CAD_SERV = associação manual), mas a implementação acumulou fragilidades:

1. V12.0.0135 ainda sincronizava CAD_SERV automaticamente a partir de ATIVIDADES (violação parcial da regra).
2. V12.0.0138 corrigiu o bug de importação ID/CNAE, mas reintroduziu reconstrução automática de CAD_SERV.
3. V12.0.0139 finalmente removeu a auto-geração em CAD_SERV e adicionou filtro CNAE na manutenção, mas introduziu criação dinâmica de controles e chamadas qualificadas que causaram erro de compilação.
4. V12.0.0140 corrigiu apenas a compilação (chamadas diretas), mas o usuário reportou tela vazia/inconsistente e possível travamento.

A hipótese principal para o travamento é a combinação de: (a) criação dinâmica de TextBox para filtro em `Filtros_CriarDinamico` + ligação `WithEvents` a `mTxtFiltroCadServ`, (b) chamada a `PreencherManutencaoValor` durante `UserForm_Initialize` com CAD_SERV vazio após reset, e (c) `BuscarCnaeAtividade` fazendo loop linear em ATIVIDADES para cada linha de CAD_SERV, criando complexidade O(n×m) que com 597 registros pode travar.

---

## 2. Diagnóstico do Estado Atual

### 2.1 O que está correto e estável

| Componente | Status | Evidência |
|---|---|---|
| Bateria oficial | Zero falhas | Teste_Bateria_Oficial.bas com exportação CSV |
| Filtro de empresas | Estável | mTxtFiltroEmpresa + PreenchimentoEmpresa |
| Filtro de entidades | Estável | mTxtFiltroEntidade + PreenchimentoEntidade |
| Inativação/reativação empresas | Estável | Validado manualmente |
| Inativação/reativação entidades | Estável | Validado manualmente |
| App_Release.bas como fonte única | Estável | Menu_Principal consome AppRelease_* |
| Pipeline release + vba_import | Estável | publicar_vba_import.sh funcional |
| Cadastro_Servico.frm (modal) | Funcional | Lista ATIVIDADES, cria em CAD_SERV |

### 2.2 Decisões corretas tomadas nas iterações recentes

1. ATIVIDADES = baseline estrutural permanente de CNAEs (V12.0.0135).
2. Eliminar fallback para atividades fictícias (V12.0.0135).
3. Não depender do CSV na máquina final do usuário (V12.0.0135).
4. Corrigir confusão ID vs CNAE no importador (V12.0.0138).
5. Limpar CAD_SERV para associação manual (V12.0.0139).
6. Adicionar filtro por CNAE na manutenção de serviços (V12.0.0139).
7. Usar chamadas diretas em vez de qualificadas (V12.0.0140).

### 2.3 Decisões que introduziram fragilidade

**Fragilidade 1 — V12.0.0138 reintroduziu auto-geração de CAD_SERV:**
A release note diz: "ResetarECarregarCNAE_Padrao agora recria CAD_SERV a partir de ATIVIDADES". Isso contradiz a regra de negócio que foi depois corrigida em V12.0.0139. Porém essa oscilação criou instabilidade na base de dados entre iterações.

**Fragilidade 2 — V12.0.0139 alterou muitos componentes simultaneamente:**
Arquivos alterados: Preencher.bas, Util_Planilha.bas, Menu_Principal.frm, App_Release.bas. Mudanças incluíram: nova função `BuscarCnaeAtividade`, nova função `LimparCadServParaAssociacaoManual`, novo controle dinâmico `mTxtFiltroCadServ`, reestruturação de `PreencherManutencaoValor`, e reestruturação de `H_Lista_Click`. Esse change-set foi grande demais para uma única iteração de estabilização.

**Fragilidade 3 — Criação dinâmica de controle + WithEvents na inicialização:**
`Filtros_CriarDinamico` cria `TxtFiltroCadServDin` em runtime e atribui a `mTxtFiltroCadServ` (Private WithEvents). Esse controle dispara `mTxtFiltroCadServ_Change` ao ser inicializado, que chama `PreencherManutencaoValor`. Se CAD_SERV estiver vazio (pós-reset), a lista aparece vazia. Se houver dados, o loop `BuscarCnaeAtividade` é O(n×m).

**Fragilidade 4 — Performance de `BuscarCnaeAtividade`:**
Esta função faz um loop linear pela aba ATIVIDADES para cada linha de CAD_SERV. Em `PreencherManutencaoValor`, é chamada 3 vezes por linha (uma para contagem, uma para preenchimento do array, outra no filtro). Com 597 CNAEs em ATIVIDADES e qualquer quantidade em CAD_SERV, isso gera milhares de leituras de célula.

### 2.4 Diferenciação das camadas

| Camada | Escopo | Estado |
|---|---|---|
| Baseline estrutural (ATIVIDADES) | CNAEs persistidos, importados do CSV canônico | Funcional, mas filtros residuais podem esconder dados |
| Cadastro operacional (CAD_SERV) | Associação manual CNAE→serviço | Correto no código, mas vazio após reset (by design) |
| Comportamento da UI | Página "CADASTRA E ALTERA SERVIÇO" no Menu_Principal | Instável: lista vazia, filtro sem dados, possível travamento |
| Testes automatizados | Bateria oficial | Estável, mas não cobre bloco CNAE/serviços |

### 2.5 Violações ou riscos à regra de negócio

1. **V12.0.0138** recriava CAD_SERV automaticamente — violação direta. Corrigido em V12.0.0139.
2. **ReinstalarCadServEstruturalPorAtividades** ainda existe no código (linhas ~2050-2106 de Preencher.bas). Embora não seja mais chamada por ResetarECarregarCNAE_Padrao, sua existência é um risco de regressão — uma IA futura pode chamá-la inadvertidamente.
3. **CargaInicialCNAE_SeNecessario** (linha 1843) chama `SincronizarDescricoesCadServComAtividades`. Isso é aceitável (apenas atualiza descrições, não cria serviços), mas o nome é confuso e pode levar uma IA futura a confundir "sincronizar descrições" com "recriar serviços".

---

## 3. Diagnóstico do Travamento do Excel

### 3.1 Hipótese principal: loop de inicialização com criação dinâmica de controles

A sequência de execução ao abrir o workbook é:

```
Auto_Open
  → ProtegerAbasCriticas
  → CargaInicialCNAE_SeNecessario (se ATIVIDADES vazia)
  → Menu_Principal.Show
    → UserForm_Initialize
      → PreencherManutencaoValor  ← 1ª chamada (população da lista)
      → PreenchimentoListaAtividade  ← popula Cadastro_Servico.SV_Lista
      → Filtros_CriarDinamico
        → Cria TxtFiltroCadServDin (Controls.Add)
        → Atribui a mTxtFiltroCadServ (WithEvents)
        → [possível disparo de mTxtFiltroCadServ_Change]
          → PreencherManutencaoValor  ← 2ª chamada (redundante)
```

O problema central é que `UserForm_Initialize` roda inteiramente sob `On Error Resume Next`, o que engole erros silenciosamente. Se `PreencherManutencaoValor` falha parcialmente ou entra em loop lento, o formulário não exibe o erro — simplesmente trava ou exibe página vazia.

### 3.2 Evidências no código

1. **Linha 3546 de Menu_Principal.frm**: `On Error Resume Next` abrange toda a inicialização. Qualquer erro na cadeia de chamadas é engolido.

2. **Linhas 4043-4052**: Criação dinâmica de `TxtFiltroCadServDin`. O `Controls.Add` em runtime em um UserForm com `On Error Resume Next` pode gerar comportamento imprevisível se o controle já existir de uma sessão anterior ou se o binário `.frx` não tiver espaço para o novo controle.

3. **`BuscarCnaeAtividade` é chamada em loop triplo**: Em `PreencherManutencaoValor` (linha 2578, 2594, implícita no filtro), para cada linha de CAD_SERV. Cada chamada percorre ATIVIDADES inteira. Se houver 100 serviços × 597 atividades × 3 passagens = ~179.100 leituras de célula. Com leitura individual de `ws.Cells(linha, col).Value`, isso é extremamente lento no Excel VBA.

4. **H_Lista_Click (linha 1082)**: `H_Atividade = H_Lista.Column(3)` — acessa coluna index 3, que no layout novo é "Atividade Descrição". Mas a atribuição original era posição diferente. Se a estrutura de colunas de H_Lista mudou na V12.0.0139 sem atualizar H_Lista_Click, o clique na lista vai atribuir valores errados aos campos H_Atividade e H_Servico.

5. **Layout de colunas de H_Lista**: `PreencherManutencaoValor` define `.ColumnWidths = "30; 0; 85; 180; 330; 65; 0; 0; 0; 70"` com 10 colunas. O array preenche: (1) ID_SERV, (2) ATIV_ID (oculto), (3) CNAE, (4) ATIV_DESC, (5) SERV_DESC, (6) VALOR, (7-9) reservas, (10) DT_CAD. Mas `H_Lista_Click` lê `Column(3)` como atividade e `Column(4)` como serviço — isso está **correto** no layout novo (Column index começa em 0: col0=ID, col1=ATIV_ID, col2=CNAE, col3=ATIV_DESC, col4=SERV_DESC, col5=VALOR). Verificação: sem bug aqui.

### 3.3 Hipótese secundária: filtro residual em aba CAD_SERV

Quando `ResetarECarregarCNAE_Padrao` é executado, ele chama `Util_LimparFiltrosAba(wsAtiv)` para ATIVIDADES, mas não chama para CAD_SERV antes de `LimparCadServParaAssociacaoManual`. Embora `LimparCadServParaAssociacaoManual` chame `Util_LimparFiltrosAba(wsServ)` internamente (linha 2118), se o ClearContents falhar parcialmente por causa de ListObject ou proteção, dados fantasma podem permanecer.

### 3.4 Hipótese terciária: corrupção do .frx por criação dinâmica

`Controls.Add` em um UserForm cria controles que ficam persistidos no binário `.frx` quando o workbook é salvo. Na próxima abertura, o controle "TxtFiltroCadServDin" já existe no `.frx`, mas o código tenta criá-lo novamente. A guarda `UI_PegarTextBoxBuscaDaLista` e `UI_TextBoxSeExisteRecursivo` tentam evitar duplicação, mas se o nome mudar ou a busca falhar, controles duplicados podem acumular e causar instabilidade.

### 3.5 Conclusão do diagnóstico de travamento

**Causa mais provável**: combinação de (a) performance quadrática de `BuscarCnaeAtividade` dentro de `PreencherManutencaoValor` + (b) chamada dupla durante inicialização (uma explícita em `UserForm_Initialize`, outra via `mTxtFiltroCadServ_Change` disparada por `Filtros_CriarDinamico`) + (c) `On Error Resume Next` engolindo erros e impedindo diagnóstico.

**Causa contribuinte**: possível acúmulo de controles dinâmicos no `.frx` entre sessões.

---

## 4. Arquitetura Correta para CNAE + Serviços + Rodízio

### 4.1 Modelo de dados definitivo

```
ATIVIDADES (baseline estrutural permanente)
┌──────────┬──────────┬────────────────────────┐
│ ID (A)   │ CNAE (B) │ DESCRICAO (C)          │
├──────────┼──────────┼────────────────────────┤
│ 001      │ 4321-5   │ Instalação elétrica    │
│ 002      │ 4322-3   │ Instalação hidráulica  │
│ ...      │ ...      │ ...                    │
└──────────┴──────────┴────────────────────────┘
Origem: CSV canônico (importado uma vez, persistido no workbook)
Não deve ser editada manualmente exceto via reset administrativo

CAD_SERV (cadastro operacional manual)
┌──────────┬──────────┬──────────────┬─────────────────────┬──────────┬───┬──────────┐
│ ID (A)   │ ATIV_ID  │ ATIV_DESC(C) │ DESCRICAO (D)       │ VALOR (E)│...│ DT_CAD(I)│
│          │ (B)      │              │                     │          │   │          │
├──────────┼──────────┼──────────────┼─────────────────────┼──────────┼───┼──────────┤
│ 001      │ 001      │ Inst.Elétr.  │ Reparo tomada 110V  │ R$ 80,00 │   │ 12/04/26 │
│ 002      │ 001      │ Inst.Elétr.  │ Troca disjuntor     │ R$ 120,00│   │ 12/04/26 │
└──────────┴──────────┴──────────────┴─────────────────────┴──────────┴───┴──────────┘
Origem: cadastro manual pelo usuário via Cadastro_Servico.frm
Relação: N serviços para 1 atividade (via ATIV_ID → ATIVIDADES.ID)

CREDENCIADOS (operacional)
┌──────────┬──────────────┬──────────┬──────┬───────┬─────────┬─────────────┐
│ ID (A)   │ COD_ATIV_SERV│ EMP_ID   │ CNPJ │ RAZAO │ POSICAO │ ATIV_ID (J) │
│          │ (B)          │ (C)      │ (D)  │ (E)   │ (F)     │             │
└──────────┴──────────────┴──────────┴──────┴───────┴─────────┴─────────────┘
Relação com rodízio: ATIV_ID referencia ATIVIDADES.ID
Relação com serviço: COD_ATIV_SERV referencia CAD_SERV.ID
```

### 4.2 Fluxo correto de importação e persistência de CNAEs

```
1. Admin executa ResetarECarregarCNAE_Padrao
2. Sistema limpa ATIVIDADES (ClearContents + reset contador)
3. Sistema limpa CAD_SERV (ClearContents + reset contador)
4. Sistema localiza CSV canônico (LocalizarArquivoCnaePadrao)
5. Sistema importa CNAEs → ATIVIDADES (ImportarCNAE_CSV)
6. Sistema salva workbook (persistência)
7. CAD_SERV fica vazio — preenchimento futuro é manual
```

### 4.3 O que a página "CADASTRA E ALTERA SERVIÇO" deve consumir

A página deve consumir **CAD_SERV diretamente**, com **enriquecimento por CNAE de ATIVIDADES**.

Fluxo de exibição:
```
PreencherManutencaoValor:
  1. Lê CAD_SERV (fonte primária)
  2. Para cada serviço, busca CNAE correspondente em ATIVIDADES via ATIV_ID
  3. Exibe na H_Lista: ID | (ativ_id oculto) | CNAE | Atividade | Serviço | Valor | ... | Data
  4. Filtro busca por texto em CNAE + Atividade + Serviço
```

Isso está correto no código atual. O problema não é a arquitetura de dados da página, é a **performance e a sequência de inicialização**.

### 4.4 Correção necessária: cache de CNAE por atividade

`BuscarCnaeAtividade` deve ser substituída por uma versão com cache Dictionary:

```vba
' Módulo-level no Preencher.bas
Private mCacheCnaeAtiv As Object  ' Dictionary: ChaveId(ATIV_ID) → CNAE

Private Sub CarregarCacheCnaeAtividade()
    Dim wsAtiv As Worksheet
    Dim ultima As Long
    Dim linha As Long
    Dim chave As String
    
    Set mCacheCnaeAtiv = CreateObject("Scripting.Dictionary")
    Set wsAtiv = ThisWorkbook.Sheets(SHEET_ATIVIDADES)
    ultima = UltimaLinhaAba(SHEET_ATIVIDADES)
    If ultima < LINHA_DADOS Then Exit Sub
    
    For linha = LINHA_DADOS To ultima
        chave = ChaveId(wsAtiv.Cells(linha, COL_ATIV_ID).Value)
        If chave <> "" Then
            mCacheCnaeAtiv(chave) = SafeListVal(wsAtiv.Cells(linha, COL_ATIV_CNAE).Value)
        End If
    Next linha
End Sub

Private Function BuscarCnaeAtividade(ByVal ativId As Variant) As String
    Dim chaveBusca As String
    chaveBusca = ChaveId(ativId)
    If chaveBusca = "" Then Exit Function
    
    If mCacheCnaeAtiv Is Nothing Then CarregarCacheCnaeAtividade
    If mCacheCnaeAtiv.Exists(chaveBusca) Then
        BuscarCnaeAtividade = CStr(mCacheCnaeAtiv(chaveBusca))
    End If
End Function

' Invalidar cache quando ATIVIDADES mudar
Public Sub InvalidarCacheCnaeAtividade()
    Set mCacheCnaeAtiv = Nothing
End Sub
```

Isso reduz a complexidade de O(n×m) para O(n+m) — dramático com 597 atividades.

### 4.5 Uso dos dados no rodízio

O rodízio opera sobre CREDENCIADOS, que referencia ATIVIDADES.ID via COL_CRED_ATIV_ID. O fluxo é:

```
Svc_Rodizio.ProximaEmpresaParaOS(atividadeId)
  → Busca em CREDENCIADOS onde ATIV_ID = atividadeId
  → Filtra por empresas ativas e credenciamento ativo
  → Aplica algoritmo de score (média de avaliações, OS recentes)
  → Retorna empresa com maior prioridade
```

A associação manual em CAD_SERV é o que determina QUAIS serviços existem para uma atividade. O credenciamento em CREDENCIADOS amarra empresa → atividade. O rodízio seleciona empresa dentro de uma atividade.

Portanto: ATIVIDADES → CAD_SERV → CREDENCIADOS → Rodízio. A cadeia está correta no modelo. Não há necessidade de alterar a arquitetura do rodízio.

---

## 5. Plano Incremental de Estabilização

### Iteração A — Estabilizar inicialização do Menu_Principal (URGENTE)

**Objetivo**: Eliminar o risco de travamento na abertura.

**Mudanças**:
1. Em `Preencher.bas`: implementar cache Dictionary para `BuscarCnaeAtividade` (conforme seção 4.4).
2. Em `Preencher.bas`: chamar `InvalidarCacheCnaeAtividade` em `ResetarECarregarCNAE_Padrao` e `CargaInicialCNAE_SeNecessario` após importação.
3. Em `Menu_Principal.frm` → `UserForm_Initialize`: mover `Filtros_CriarDinamico` para ANTES das chamadas de preenchimento, mas SEM permitir que `mTxtFiltroCadServ_Change` dispare durante inicialização. Usar flag `mIgnorarFiltro` (já existe no Cadastro_Servico — adotar padrão similar).
4. Verificar que `H_Lista_Click` lê colunas corretas após reestruturação da V12.0.0139.

**Arquivos no change-set**: Preencher.bas, Menu_Principal.frm, App_Release.bas.

**Critério de sucesso**: Excel abre sem travamento. Página "CADASTRA E ALTERA SERVIÇO" exibe lista (vazia se CAD_SERV vazio, com dados se houver).

### Iteração B — Validar ciclo completo CNAE → Serviço manual

**Objetivo**: Confirmar a regra de negócio end-to-end.

**Mudanças**:
1. Executar `ResetarECarregarCNAE_Padrao` no Excel.
2. Confirmar ATIVIDADES persistida com 597 registros.
3. Confirmar CAD_SERV vazio.
4. Abrir `Cadastro_Servico.frm`, selecionar atividade, cadastrar serviço manualmente.
5. Confirmar refletido na página "CADASTRA E ALTERA SERVIÇO" com CNAE visível.
6. Confirmar filtro funcional por CNAE/atividade/serviço.

**Arquivos no change-set**: Nenhum (ou mínimos ajustes se necessário). App_Release.bas se houver bump.

**Critério de sucesso**: Fluxo completo funciona sem erro. Filtro responde rápido.

### Iteração C — Estabilizar filtros e buscas em todas as telas

**Objetivo**: Garantir que todos os filtros dinâmicos (empresas, entidades, serviços) funcionam de forma robusta.

**Mudanças**:
1. Revisar `Filtros_CriarDinamico` para eliminar risco de controles duplicados: verificar se controle existe antes de criar, usando nome fixo e busca robusta.
2. Adicionar flag `mInicializando` em `UserForm_Initialize` que impede disparos de `_Change` durante criação de controles.
3. Testar cada filtro isoladamente.

**Arquivos no change-set**: Menu_Principal.frm, App_Release.bas.

**Critério de sucesso**: Filtros funcionam em empresas, entidades e serviços. Nenhum disparo acidental durante inicialização.

### Iteração D — Estabilização visual das telas

**Objetivo**: Corrigir problemas visuais sem quebrar funcionalidade.

**Mudanças**:
1. Revisar duplicidade visual no cadastro de empresas.
2. Revisar captions e alinhamentos corrigidos por código.
3. Fixar labels/captions diretamente no formulário quando seguro (sem quebrar treinamento).

**Arquivos no change-set**: Menu_Principal.frm, App_Release.bas.

**Critério de sucesso**: Telas visualmente corretas. Treinamento existente continua válido.

### Iteração E — Eliminação progressiva de legado MEI/MPE

**Objetivo**: Remover referências legadas sem quebrar treinamento em produção.

**Mudanças**:
1. Mapear todos os pontos com referência a MEI/MPE.
2. Substituir apenas onde o Caption/Label não afeta treinamento.
3. Documentar o que precisa esperar próxima janela de treinamento.

**Arquivos no change-set**: Menu_Principal.frm, possíveis módulos auxiliares, App_Release.bas.

**Critério de sucesso**: Bateria oficial continua zerada. Funcionalidades existentes intactas.

### Iteração F — Ampliar testes automatizados para CNAE/serviços

**Objetivo**: Cobrir o bloco CNAE/serviços na bateria oficial.

**Mudanças**:
1. Adicionar testes em `Teste_Bateria_Oficial.bas`:
   - ATIVIDADES deve ter dados após carga (count >= LINHA_DADOS).
   - `BuscarCnaeAtividade` retorna valor válido para atividade existente.
   - `PreencherManutencaoValor` executa sem erro com CAD_SERV vazio.
   - `PreencherManutencaoValor` executa sem erro com CAD_SERV populado.
   - Cadastro manual de serviço via `Cadastro_Servico.frm` reflete em CAD_SERV.

**Arquivos no change-set**: Teste_Bateria_Oficial.bas, App_Release.bas.

**Critério de sucesso**: Novos testes passam. Testes existentes continuam passando.

### Iteração G — Momento para melhoria de interface (pós-estabilização)

**NÃO iniciar antes que as iterações A–F estejam concluídas e validadas.**

Somente após estabilização completa considerar:
1. Prompt interno de melhoria de interface.
2. Reestruturação visual de telas.
3. Mudanças estéticas que não afetem treinamento.

---

## 6. Modelo Padrão de Iteração

### 6.1 Estrutura de cada iteração

```
ITERAÇÃO V12.0.XXXX
├── Objetivo: [1 frase clara]
├── Tipo: ESTRUTURAL | FUNCIONAL | VISUAL
├── Arquivos no change-set:
│   ├── [arquivo funcional principal]
│   ├── App_Release.bas (se bump de versão)
│   └── obsidian-vault/releases/V12.0.XXXX.md
├── Checklist técnico obrigatório
├── Checklist de compilação
├── Checklist de validação humana
└── Critério de passagem
```

### 6.2 Checklist técnico obrigatório (antes de entregar)

- [ ] A edição foi feita APENAS em vba_export/.
- [ ] O change-set é coeso (máximo 2-3 arquivos funcionais + App_Release.bas + release note).
- [ ] Não há chamadas qualificadas a módulo padrão (ex: `Preencher.MinhaFuncao`). Todas as chamadas externas a módulos padrão usam nome direto.
- [ ] Não há padrão `Dim ... : ... =` em nenhum arquivo alterado.
- [ ] Não há `Option Explicit` faltando em nenhum arquivo alterado.
- [ ] Todas as variáveis usadas estão declaradas com Dim.
- [ ] Não foi criado fallback silencioso que mascare erro (verificar `On Error Resume Next` desnecessários).
- [ ] A função `ReinstalarCadServEstruturalPorAtividades` NÃO foi chamada em nenhum novo código.
- [ ] CAD_SERV NÃO é preenchido automaticamente a partir de ATIVIDADES em nenhum novo fluxo.
- [ ] Nenhum botão lateral foi renomeado.

### 6.3 Checklist de compilação

- [ ] Executar `bash scripts/publicar_vba_import.sh` sem erro.
- [ ] Abrir o .xlsm no Excel.
- [ ] Ir em Alt+F11 → Debug → Compile VBA Project.
- [ ] Compilação conclui silenciosamente (sem erro).
- [ ] Se houver erro: capturar linha exata, corrigir no repositório, repetir.

### 6.4 Checklist de validação humana

- [ ] Menu principal abre sem travamento.
- [ ] Página de empresas exibe lista corretamente.
- [ ] Página de entidades exibe lista corretamente.
- [ ] Página "CADASTRA E ALTERA SERVIÇO" exibe lista (ou mensagem vazia se CAD_SERV vazio).
- [ ] Filtros de busca respondem em todas as telas.
- [ ] Rodar bateria oficial: resultado = zero falhas.

### 6.5 Quando atualizar App_Release.bas

Atualizar SEMPRE que houver bump de versão, ou seja, em TODA iteração que altere código funcional. Somente não atualizar quando a iteração for puramente documental.

### 6.6 Quando gerar release note

SEMPRE que houver alteração de código. O release note vai em `obsidian-vault/releases/V12.0.XXXX.md` e deve conter: objetivo, arquivos alterados, impacto esperado, e qualquer decisão de trade-off.

### 6.7 Quando republicar vba_import

SEMPRE que houver alteração em qualquer arquivo de vba_export/. O script `publicar_vba_import.sh` deve ser executado e o resultado commitado.

### 6.8 Classificação do tipo de iteração

| Tipo | Critério | Exemplo |
|---|---|---|
| ESTRUTURAL | Altera modelo de dados, fluxo de persistência, ou regra de negócio | Implementar cache de CNAE, alterar importador |
| FUNCIONAL | Altera comportamento de UI ou fluxo operacional sem mudar modelo | Corrigir filtro, ajustar inicialização de formulário |
| VISUAL | Altera apenas aparência sem mudar dados ou fluxo | Ajustar caption, alinhar controle, mudar cor |

---

## 7. Passagem de Bastão para a Próxima IA

### 7.1 Por onde retomar

A próxima iteração deve ser a **Iteração A** (seção 5): estabilizar a inicialização do Menu_Principal.

Ações concretas:
1. Implementar cache Dictionary em `BuscarCnaeAtividade` no `Preencher.bas`.
2. Adicionar flag de inicialização no `Menu_Principal.frm` que impede disparos de `_Change` em controles dinâmicos durante `UserForm_Initialize`.
3. Chamar `InvalidarCacheCnaeAtividade` após qualquer operação que altere ATIVIDADES.
4. Compilar, importar, validar.

### 7.2 O que NÃO mexer ainda

1. NÃO alterar `Cadastro_Servico.frm` — está funcional e estável.
2. NÃO alterar `Teste_Bateria_Oficial.bas` — ampliar testes somente na Iteração F.
3. NÃO alterar layout de colunas de H_Lista — o layout da V12.0.0139 está correto.
4. NÃO remover `ReinstalarCadServEstruturalPorAtividades` ainda — apenas garantir que não é chamada. Remoção segura pode ser feita na Iteração E.
5. NÃO mexer em filtros de empresas/entidades — estão estáveis.
6. NÃO renomear botão "CADASTRA E ALTERA SERVIÇO".

### 7.3 Primeiro experimento seguro

Antes de alterar código, testar no Excel atual:
1. Abrir o .xlsm com a V12.0.0140 importada.
2. Se abrir sem travar: navegar até "CADASTRA E ALTERA SERVIÇO" e verificar se a lista está vazia ou com dados.
3. Se travar: o problema é confirmado como sendo de inicialização — prosseguir direto com a Iteração A.

### 7.4 Primeiro risco a evitar

**NÃO adicionar mais chamadas a funções de preenchimento durante `UserForm_Initialize` sem cache.** Qualquer função que leia ATIVIDADES em loop deve usar o cache Dictionary.

**NÃO criar mais controles dinâmicos com `Controls.Add` sem garantia de que o controle não existe previamente no `.frx`.**

### 7.5 Critério objetivo de passagem

A iteração passa quando:
1. Excel abre sem travamento ou recuperação de documento.
2. `Depurar > Compilar VBAProject` conclui sem erro.
3. Página "CADASTRA E ALTERA SERVIÇO" exibe a lista (vazia ou com dados, conforme estado de CAD_SERV).
4. Bateria oficial continua com zero falhas.
5. `ResetarECarregarCNAE_Padrao` executa, reporta quantidade correta, e a planilha salva.

### 7.6 Resumo de arquivos e localizações críticas

| Arquivo | Papel | Risco |
|---|---|---|
| `Preencher.bas` | Toda lógica de preenchimento de listas e CNAE | Alto — núcleo funcional |
| `Menu_Principal.frm` | UI principal, inicialização, controles dinâmicos | Alto — ponto de travamento |
| `Cadastro_Servico.frm` | Modal de cadastro de serviço | Baixo — estável |
| `App_Release.bas` | Metadata de versão | Baixo — rotina |
| `Util_Planilha.bas` | Utilitários de aba/proteção | Baixo — estável |
| `Auto_Open.bas` | Bootstrap do sistema | Médio — chama CargaInicialCNAE |
| `Const_Colunas.bas` | Constantes de mapeamento | Baixo — não alterar |
| `Teste_Bateria_Oficial.bas` | Testes automatizados | Baixo — expandir depois |

### 7.7 Regras invioláveis (repetição intencional para clareza)

1. ATIVIDADES = baseline estrutural permanente. Nunca gerar atividades fictícias.
2. CAD_SERV = associação manual. Nunca auto-gerar serviços a partir de ATIVIDADES.
3. Fonte de verdade = vba_export/. Nunca editar apenas vba_import/.
4. Toda iteração termina com compilação no Excel + release note.
5. O botão "CADASTRA E ALTERA SERVIÇO" não muda de nome.
6. CSV de CNAE é fonte de importação administrativa, não dependência runtime.
