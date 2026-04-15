# Handoff: Sistema de Credenciamento VBA — Cursor Auto

## 1. VISAO GERAL

Sistema de Controle de Rodizio para Credenciamento de Prestadores de Servico, implementado em VBA Excel (.xlsm). Gerencia empresas, atividades (CNAEs), servicos, credenciamento, pre-OS, OS e avaliacoes com rodizio justo.

**Versao atual**: V12.0.0143
**Workbook**: `PlanilhaCredenciamento-Homologacao.xlsm`
**Pasta projeto**: raiz do repositorio (onde esta o .xlsm)

## 2. REGRAS DE NEGOCIO CRITICAS

1. **ATIVIDADES** = baseline estrutural permanente de CNAEs. Importados de `cnae_servicos_normalizado.csv`. NUNCA gerar automaticamente.
2. **CAD_SERV** = associacao MANUAL de servicos a atividades. O usuario cadastra servicos um a um via formulario. NUNCA auto-gerar servicos.
3. **CREDENCIADOS** = credenciamento de empresas POR ATIVIDADE (nao por servico).
4. **Rodizio** opera no nivel de ATIVIDADE via `Svc_Rodizio.bas`.
5. Botao "CADASTRA E ALTERA SERVICO" — NUNCA renomear.
6. Formato CNAE padrao do sistema: `DDDD-D/DD` (ex: `0162-8/02`). Sem pontos.

## 3. ARQUITETURA

### Camadas
```
UI (Forms .frm)
  → Servicos (Svc_*.bas) — logica de negocio
    → Repositorios (Repo_*.bas) — persistencia em abas
      → Utilitarios (Util_*.bas) — operacoes de planilha
        → Constantes (Const_Colunas.bas) — mapeamento de colunas
```

### Abas da planilha
| Aba | Descricao |
|-----|-----------|
| CONFIG | Configuracoes do sistema |
| EMPRESAS | Empresas ativas |
| EMPRESAS_INATIVAS | Empresas inativadas |
| ENTIDADE | Entidades/locais |
| ENTIDADE_INATIVOS | Entidades inativadas |
| ATIVIDADES | CNAEs (baseline estrutural) |
| CAD_SERV | Servicos associados a atividades |
| CREDENCIADOS | Fila de credenciamento |
| PRE_OS | Pre-ordens de servico |
| CAD_OS | Ordens de servico |
| AUDIT_LOG | Log de auditoria |
| RELATORIO | Relatorios |

### Modulos VBA principais
| Modulo | Funcao |
|--------|--------|
| Auto_Open.bas | Bootstrap: ProtegerAbasCriticas → CargaInicialCNAE → Menu_Principal.Show |
| App_Release.bas | Versao e metadata (fonte unica de verdade) |
| Const_Colunas.bas | TODAS as constantes de coluna e nomes de aba |
| Mod_Types.bas | Types de dominio (TResult, TAtividade, TServico, TEmpresa, etc.) |
| Preencher.bas | Populacao de listas, importacao CNAE, cache |
| Menu_Principal.frm | Interface principal (~4100 linhas, multi-page) |
| Cadastro_Servico.frm | Dialog de cadastro de servicos |
| Svc_Rodizio.bas | Algoritmo de rodizio round-robin |
| Svc_PreOS.bas | Emissao de pre-OS |
| Svc_OS.bas | Emissao e cancelamento de OS |
| Repo_Empresa.bas | CRUD de empresas |
| Repo_Credenciamento.bas | CRUD de credenciamento |
| Teste_Bateria_Oficial.bas | Testes automatizados (Blocos 0-5) |
| Emergencia_CNAE.bas | Macro emergencial de importacao CNAE (zero dependencias) |

## 4. FONTE DE VERDADE

- **Codigo**: `vba_export/` — SEMPRE editar aqui
- **Importacao**: `vba_import/` — artefato gerado (copiar de vba_export)
- **NUNCA** depender de CSV no ambiente do usuario final
- **NUNCA** usar chamadas qualificadas a modulos standard (ex: `Preencher.MyFunc` FALHA, usar `MyFunc` diretamente)

## 5. PIPELINE DE RELEASE

```
1. Editar arquivo em vba_export/
2. Copiar para vba_import/: cp vba_export/Arquivo.bas vba_import/Arquivo.bas
3. Atualizar APP_RELEASE_ATUAL em App_Release.bas
4. No Excel VBE: Arquivo > Importar Arquivo > selecionar de vba_import/
5. Debug > Compilar VBAProject
6. Testar manualmente
7. Criar release note em obsidian-vault/releases/
```

## 6. PADROES DE CODIGO VBA

### Protecao de abas
```vba
Dim estavaProtegida As Boolean
Dim senhaProtecao As String
If Not Util_PrepararAbaParaEscrita(ws, estavaProtegida, senhaProtecao) Then Exit Sub
' ... escrever ...
Call Util_RestaurarProtecaoAba(ws, estavaProtegida, senhaProtecao)
```

### IDs
- Formato "001", "002", etc (3 digitos, texto)
- Contador em coluna AR (44) linha 1 de cada aba
- Funcao: `ProximoId(nomeAba)` — incrementa e retorna

### Comparacao de IDs
- SEMPRE usar `IdsIguais(a, b)` — trata "001" = 1 = "1"

### Erros
- Forms usam `On Error Resume Next` (engole erros silenciosamente)
- Modulos de servico usam `On Error GoTo erro_xxx`
- ErrorBoundary.bas para transacoes seguras

### Filtros dinamicos (Menu_Principal)
- WithEvents: mTxtFiltroEmpresa, mTxtFiltroEntidade, mTxtFiltroCadServ
- Flag `mInicializando` previne eventos durante init
- mTxtFiltroRodizio e mTxtFiltroServico: declarados mas SEM handler (pendente)

### Cache CNAE
- Dictionary `mCacheCnaeAtiv` em Preencher.bas
- `CarregarCacheCnaeAtividade()` / `InvalidarCacheCnaeAtividade()`
- Invalidar apos qualquer alteracao em ATIVIDADES

## 7. COLUNAS CRITICAS

### ATIVIDADES (3 colunas)
| Col | Const | Conteudo |
|-----|-------|----------|
| A(1) | COL_ATIV_ID | ID texto "001" |
| B(2) | COL_ATIV_CNAE | CNAE formato DDDD-D/DD |
| C(3) | COL_ATIV_DESCRICAO | Descricao da atividade |
| AR(44) | COL_CONTADOR_AR | Contador de IDs (linha 1) |

### CAD_SERV (9 colunas)
| Col | Const | Conteudo |
|-----|-------|----------|
| A(1) | COL_SERV_ID | ID do servico |
| B(2) | COL_SERV_ATIV_ID | ID da atividade (FK) |
| C(3) | COL_SERV_ATIV_DESC | Descricao da atividade |
| D(4) | COL_SERV_DESCRICAO | Descricao do servico |
| E(5) | COL_SERV_VALOR_UNIT | Valor unitario |
| I(9) | COL_SERV_DT_CAD | Data de cadastro |

### CREDENCIADOS (15 colunas)
| Col | Const | Conteudo |
|-----|-------|----------|
| A(1) | COL_CRED_ID | ID credenciamento |
| B(2) | COL_CRED_COD_ATIV_SERV | Codigo atividade/servico |
| C(3) | COL_CRED_EMP_ID | ID empresa |
| F(6) | COL_CRED_POSICAO | Posicao no rodizio |
| J(10) | COL_CRED_ATIV_ID | ID atividade (FK) |
| M(13) | COL_CRED_STATUS | Status (ATIVO/INATIVO) |

## 8. ESTADO ATUAL DO SISTEMA

### Funcionando
- Abertura do sistema (Menu_Principal)
- Importacao de CNAEs (via Emergencia_CNAE.bas)
- Cadastro de Servicos (Cadastro_Servico.frm)
- Busca/filtro de atividades na lista SV_Lista
- Testes automatizados (Blocos 0-5)

### Problemas conhecidos
1. **CNAE duplicado**: Ao reimportar CNAEs, se houver dados residuais de importacao anterior com formato diferente (01.62-8/02 vs 0162-8/02), aparecem duplicatas. Solucao: rodar `ImportarCNAE_Emergencia` (V2, normaliza formato).
2. **ResetarECarregarCNAE_Padrao**: A versao complexa tem falhas silenciosas encadeadas (ProximoId por-linha, AtividadeJaExiste O(n²), ciclos de protecao). Usar `ImportarCNAE_Emergencia` como alternativa confiavel.
3. **Filtros sem handler**: mTxtFiltroRodizio e mTxtFiltroServico declarados em Menu_Principal mas sem _Change handler.
4. **On Error Resume Next em UserForm_Initialize**: Erros durante inicializacao de forms sao engolidos silenciosamente.

### Pendente
1. Implementar handlers para mTxtFiltroRodizio e mTxtFiltroServico
2. Expandir Bloco6 de testes para cobrir CNAE/servicos
3. Melhorar feedback visual em testes (StatusBar + DoEvents)
4. Formatacao visual do Menu_Principal (apos estabilizacao funcional)

## 9. MODELO DE ITERACAO SIMPLES

Cada iteracao deve seguir este ciclo:

```
1. EDITAR: alterar UM arquivo em vba_export/
2. COPIAR: cp vba_export/Arquivo.bas vba_import/Arquivo.bas
3. VERSIONAR: incrementar APP_RELEASE_ATUAL em App_Release.bas
4. IMPORTAR: no VBE, importar de vba_import/
5. COMPILAR: Debug > Compilar VBAProject
6. TESTAR: executar funcionalidade alterada manualmente
7. RELEASE NOTE: criar em obsidian-vault/releases/
```

**Regras de iteracao**:
- Uma funcionalidade por iteracao
- Nunca alterar mais de 2 arquivos por iteracao
- Sempre compilar antes de testar
- Se falhar compilacao, reverter e investigar
- Se falhar teste, corrigir na proxima iteracao (nunca acumular bugs)

## 10. PARA CURSOR AUTO

### Prompt inicial sugerido
```
Voce esta trabalhando no Sistema de Credenciamento VBA Excel.
Leia doc/Time_AI/HANDOFF_CURSOR_AUTO.md para contexto completo.
Fonte de verdade do codigo: vba_export/
Constantes de colunas: vba_export/Const_Colunas.bas
Types de dominio: vba_export/Mod_Types.bas

Regras:
- Editar APENAS em vba_export/
- Copiar para vba_import/ apos editar
- Incrementar versao em App_Release.bas
- NUNCA usar chamadas qualificadas (Modulo.Funcao) — usar Funcao diretamente
- NUNCA auto-gerar servicos em CAD_SERV
- NUNCA renomear botao "CADASTRA E ALTERA SERVICO"
- Formato CNAE: DDDD-D/DD (ex: 0162-8/02)
- IDs: texto "001", "002" (3 digitos)
- Comparar IDs com IdsIguais()
- Protecao: Util_PrepararAbaParaEscrita / Util_RestaurarProtecaoAba
```

### Tarefas prioritarias para proximas iteracoes
1. Implementar handler `mTxtFiltroRodizio_Change` em Menu_Principal.frm
2. Implementar handler `mTxtFiltroServico_Change` em Menu_Principal.frm
3. Adicionar Bloco6 em Teste_Bateria_Oficial.bas (testes CNAE/servicos)
4. Melhorar `PreenchimentoListaAtividade` para performance (eliminar dupla varredura)
5. Adicionar validacao no Cadastro_Servico para impedir servico sem descricao
