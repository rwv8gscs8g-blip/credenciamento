# Mapa de Dependencias entre Modulos

Relacionado: [[Modulos-VBA]], [[Tipos-Publicos]], [[Compilacao-VBA]]

---

## Camadas de Dependencia

```
CAMADA 0 (zero dependencias):
  Mod_Types.bas          <- Define todos os 12 Public Types
  Const_Colunas.bas      <- Define todas as constantes de abas e colunas

CAMADA 1 (depende apenas da camada 0):
  Util_Conversao.bas     <- Usa constantes
  Util_Planilha.bas      <- Usa constantes
  Funcoes.bas            <- Usa constantes, TResult
  ErrorBoundary.bas      <- Independente
  Variaveis.bas          <- Independente (variaveis globais legadas)

CAMADA 2 (depende das camadas 0-1):
  Util_Config.bas        <- Usa TConfig, constantes
  Audit_Log.bas          <- Usa constantes, Util_Planilha
  AppContext.bas          <- Usa TAppContext

CAMADA 3 (repositorios — depende das camadas 0-2):
  Repo_Credenciamento.bas <- Usa TCredenciamento, TResult, Util_Planilha, Audit_Log
  Repo_PreOS.bas          <- Usa TPreOS, TResult, Util_Planilha, Audit_Log
  Repo_OS.bas             <- Usa TOS, TResult, Util_Planilha, Audit_Log
  Repo_Avaliacao.bas      <- Usa TAvaliacao, TResult, Util_Planilha, Audit_Log
  Repo_Empresa.bas        <- Usa TEmpresa, TResult, Util_Planilha, Audit_Log

CAMADA 4 (servicos — depende das camadas 0-3):
  Svc_Rodizio.bas         <- Usa Repo_Credenciamento, Repo_Empresa, Util_Config, TConfig
  Svc_PreOS.bas           <- Usa Repo_PreOS, Repo_Credenciamento, Util_Config
  Svc_OS.bas              <- Usa Repo_OS, Repo_PreOS, Svc_PreOS
  Svc_Avaliacao.bas       <- Usa Repo_Avaliacao, Repo_Empresa

CAMADA 5 (interface — depende de tudo):
  Classificar.bas         <- Usa Repo_Credenciamento, Funcoes
  Preencher.bas           <- Usa todos os Repos, Funcoes, Variaveis
  Auto_Open.bas           <- Usa Util_Planilha (protecao de abas)
  
CAMADA 6 (testes — descartaveis para compilacao do core):
  Central_Testes.bas
  Central_Testes_Relatorio.bas
  Teste_Bateria_Oficial.bas
  Teste_UI_Guiado.bas
  Treinamento_Painel.bas
```

## Formularios e Dependencias

```
Menu_Principal.frm       <- Usa Svc_Rodizio, Svc_PreOS, Svc_OS, Preencher, Classificar
Configuracao_Inicial.frm <- Usa Util_Config, Util_Planilha
Credencia_Empresa.frm    <- Usa Repo_Credenciamento, Preencher
Altera_Empresa.frm       <- Usa Repo_Empresa, Preencher
Reativa_Empresa.frm      <- Usa Repo_Empresa
Altera_Entidade.frm      <- Usa Repo_Credenciamento, Preencher
Reativa_Entidade.frm     <- Usa Repo_Credenciamento
Cadastro_Servico.frm     <- Usa Repo_Credenciamento, Preencher
Limpar_Base.frm          <- Usa Util_Planilha
Rel_Emp_Serv.frm         <- Usa Preencher
Rel_OSEmpresa.frm        <- Usa Preencher
ProgressBar.frm          <- Independente (UI only)
Fundo_Branco.frm         <- Independente (UI only)
```

## Regra de Compilacao

O VBA compila modulos em ordem ALFABETICA pelo VB_Name. Todos os tipos devem estar definidos em Mod_Types.bas (que comeca com "M", compilado antes de "R", "S", "U" etc.). O unico risco e se um modulo com nome alfabeticamente anterior a "Mod_Types" tentar usar um tipo — exemplo: AppContext (letra "A") usa TAppContext. Isso funciona na V12-093 porque o VBA resolve tipos em duas passagens (declaracoes primeiro, depois codigo).
