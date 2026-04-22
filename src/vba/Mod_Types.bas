Attribute VB_Name = "Mod_Types"
Option Explicit

' Tipos publicos do sistema de credenciamento.
' ATENCAO: o nome "Mod_Types" deve ser mantido. O erro "Nome repetido: TConfig"
' NAO e causado pelo nome do modulo — e causado por corrupcao no binario do
' projeto VBA dentro do .xlsm. A solucao e usar uma planilha com projeto limpo
' (nunca reimportar TODOS os modulos do zero num .xlsm existente).
'
' Resultado genérico de serviços (Svc_*)
Public Type TResult
    Sucesso     As Boolean
    Mensagem    As String
    CodigoErro  As Long
    IdGerado    As String    ' ID do registro criado (PREOS_ID, OS_ID, etc.)
End Type

' Atividade (CNAE / fila de rodízio)
Public Type TAtividade
    ATIV_ID     As String
    CNAE_COD    As String
    ATIV_NOME   As String
    ATIV_STATUS As String    ' "ATIVA" | "INATIVA"
    DT_CAD      As Date
    DT_ULT_ALT  As Date
    usuario     As String
End Type

' Serviço pertencente a uma atividade
Public Type TServico
    SERV_ID     As String
    ATIV_ID     As String    ' FK → TAtividade
    SERV_NOME   As String
    UNID_MEDIDA As String
    VALOR_UNIT  As Currency  ' Sempre numérico
    SERV_STATUS As String    ' "ATIVO" | "INATIVO"
    DT_CAD      As Date
    DT_ULT_ALT  As Date
    usuario     As String
End Type

' Empresa (prestador Empresa)
Public Type TEmpresa
    EMP_ID          As String
    cnpj            As String
    RAZAO_NOME      As String
    CONTATO_TEL     As String
    CONTATO_EMAIL   As String
    endereco        As String
    bairro          As String
    municipio       As String
    uf              As String
    cep             As String
    STATUS_GLOBAL   As String    ' "ATIVA" | "INATIVA" | "SUSPENSA_GLOBAL"
    DT_FIM_SUSP     As Date      ' 0 = sem suspensão
    QTD_RECUSAS     As Long      ' contador global (apoio à auditoria)
    DT_CAD          As Date
    DT_ULT_ALT      As Date
End Type

' Credenciamento de empresa em atividade (fila)
Public Type TCredenciamento
    CRED_ID         As String
    EMP_ID          As String    ' FK → TEmpresa
    ATIV_ID         As String    ' FK → TAtividade
    COD_SERVICO     As String    ' concatenação ATIV_ID & SERV_ID se necessário
    STATUS_CRED     As String    ' "ATIVO" | "INATIVO" | "SUSPENSO_LOCAL"
    POSICAO_FILA    As Long      ' posição numérica no rodízio
    DT_ULTIMA_IND   As Date      ' data da última indicação
    QTD_RECUSAS     As Long      ' recusas nesta atividade
    QTD_EXPIRACOES  As Long
    TEM_OS_ABERTA   As Boolean   ' calculado em runtime
    DT_CRED         As Date
    DT_ULT_ALT      As Date
End Type

' Entidade (local de execução: escola, órgão etc.)
Public Type TEntidade
    ENT_ID      As String
    ENT_NOME    As String
    cnpj        As String
    TEL_FIXO    As String
    TEL_CEL     As String
    email       As String
    endereco    As String
    bairro      As String
    municipio   As String
    cep         As String
    uf          As String
    CONTATO1    As String
    FONE_CONT1  As String
    CONTATO2    As String
    FONE_CONT2  As String
    CONTATO3    As String
    FONE_CONT3  As String
    STATUS_ENT  As String    ' "ATIVA" | "INATIVA"
    DT_CAD      As Date
    DT_ULT_ALT  As Date
End Type

' Pré‑Solicitação de Serviço (Pré‑OS / Pré‑SS)
Public Type TPreOS
    PREOS_ID         As String    ' sequencial visível "001", "002"...
    ATIV_ID          As String
    SERV_ID          As String
    ENT_ID           As String
    EMP_ID           As String    ' empresa selecionada pelo rodízio
    QT_ESTIMADA      As Double
    VALOR_UNIT       As Currency  ' fotografado no momento
    VALOR_ESTIMADO   As Currency  ' = QT_ESTIMADA * VALOR_UNIT
    DT_GERACAO       As Date
    DT_LIMITE_ACEITE As Date
    STATUS_PREOS     As String    ' "AGUARDANDO_ACEITE"|"RECUSADA"|"EXPIRADA"|"CONVERTIDA_OS"
    MOTIVO_STATUS    As String
End Type

' Ordem de Serviço
Public Type TOS
    OS_ID              As String
    PREOS_ID           As String    ' FK → TPreOS
    EMP_ID             As String
    ATIV_ID            As String
    SERV_ID            As String
    ENT_ID             As String
    QT_ESTIMADA        As Double
    QT_CONFIRMADA      As Double
    VALOR_UNIT         As Currency
    VALOR_TOTAL_OS     As Currency  ' = QT_CONFIRMADA * VALOR_UNIT
    NUM_EMPENHO        As String
    DT_EMISSAO         As Date
    DT_PREV_TERMINO    As Date
    STATUS_OS          As String    ' "EM_EXECUCAO"|"CONCLUIDA"|"CANCELADA"
    JUSTIF_DIVERGENCIA As String
    DT_FECHAMENTO      As Date
End Type

' Avaliação da OS (10 critérios)
Public Type TAvaliacao
    AVAL_ID      As String
    OS_ID        As String    ' FK → TOS
    avaliador    As String
    notas(1 To 10) As Integer
    SOMA_NOTAS   As Long
    MEDIA_NOTAS  As Double
    Observacao   As String
    DT_AVAL      As Date
End Type

' Payload normalizado para submissão de avaliação a partir da UI.
Public Type TAvaliacaoPayload
    OS_ID               As String
    avaliador           As String
    notas(1 To 10)      As Integer
    QtExecutada         As Double
    Observacao          As String
    JustifDivergencia   As String
    MediaNotas          As Double
End Type

' Configuração global (prazo, limites etc.)
Public Type TConfig
    DIAS_DECISAO            As Long
    MAX_RECUSAS             As Long
    PERIODO_SUSPENSAO_MESES As Long
    GESTOR_NOME             As String
    municipio               As String
    CAM_LOGO                As String
End Type

' Resultado detalhado de rodízio
Public Type TRodizioResultado
    encontrou      As Boolean
    Empresa        As TEmpresa
    Credenciamento As TCredenciamento
    MotivoFalha    As String    ' ex.: "SEM_CREDENCIADOS"
End Type

' Container mestre de estado transitorio.
' DEVE ficar neste modulo (apos todos os tipos que referencia)
' para evitar erro "Nome repetido" causado pela ordem alfabetica
' de compilacao do VBA (AppContext < Mod_Types).
Public Type TAppContext
    PreOS_Corrente        As TPreOS
    OS_Corrente           As TOS
    Empresa_Selecionada   As TEmpresa
    Entidade_Selecionada  As TEntidade
    Config                As TConfig
    IsPreOSValida         As Boolean
    IsOSValida            As Boolean
    IsEmpresaValida       As Boolean
    IsEntidadeValida      As Boolean
End Type
