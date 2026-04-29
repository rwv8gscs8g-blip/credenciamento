Attribute VB_Name = "Const_Colunas"
Option Explicit

' ============================================================
' Constantes de mapeamento V10
' Gerado por Claude Opus 4.6 - NÃO editar manualmente.
' Referência: doc/Time_AI/001-Sprint0-Contrato-de-Dados-V10.md
' ============================================================

' --- Nomes das Abas ---
Public Const SHEET_CONFIG As String = "CONFIG"
Public Const SHEET_EMPRESAS As String = "EMPRESAS"
Public Const SHEET_EMPRESAS_INATIVAS As String = "EMPRESAS_INATIVAS"
Public Const SHEET_ENTIDADE As String = "ENTIDADE"
Public Const SHEET_ENTIDADE_INATIVOS As String = "ENTIDADE_INATIVOS"
Public Const SHEET_ATIVIDADES As String = "ATIVIDADES"
Public Const SHEET_CAD_SERV As String = "CAD_SERV"
' V12.0.0203 ONDA 2 - prefixo das abas-snapshot de CAD_SERV criadas
' antes de cada reset CNAE. O nome final fica
' "CAD_SERV_SNAPSHOT_yyyymmdd_hhnnss" para preservar historico
' reaproveitavel manualmente caso a re-vinculacao posterior precise
' de fonte de verdade do estado anterior.
Public Const SHEET_PREFIX_CAD_SERV_SNAP As String = "CAD_SERV_SNAPSHOT_"
Public Const SHEET_CREDENCIADOS As String = "CREDENCIADOS"
Public Const SHEET_PREOS As String = "PRE_OS"
Public Const SHEET_CAD_OS As String = "CAD_OS"
Public Const SHEET_AUDIT As String = "AUDIT_LOG"
Public Const SHEET_RELATORIO As String = "RELATORIO"

' --- Constantes Gerais ---
Public Const LINHA_DADOS As Long = 2          ' Primeira linha de dados (linha 1 = cabeçalho)
Public Const COL_CONTADOR_AR As Long = 44     ' Coluna AR (contador de ID)

' --- Aba CONFIG (linha 1 = cabeçalho, linha 2 = valores) ---
Public Const COL_CFG_GESTOR As Long = 1           ' A
Public Const COL_CFG_LOGO As Long = 2             ' B
Public Const COL_CFG_MUNICIPIO As Long = 3        ' C
Public Const COL_CFG_PRAZO_PREOS As Long = 4      ' D
Public Const COL_CFG_MAX_RECUSAS As Long = 5      ' E
Public Const COL_CFG_MESES_SUSPENSAO As Long = 6  ' F
Public Const COL_CFG_VERSAO As Long = 7           ' G
Public Const COL_CFG_PASTA_DOCS As Long = 8       ' H
Public Const COL_CFG_UF As Long = 9               ' I
Public Const COL_CFG_SECRETARIA As Long = 10      ' J
Public Const COL_CFG_NOTA_MINIMA As Long = 11     ' K
' --- V12.0.0203 ONDA 1: regra de strikes na avaliacao ---
' Numero de avaliacoes com media abaixo de COL_CFG_NOTA_MINIMA antes de suspender.
' Default em Util_Config.GetMaxStrikes(): 3.
Public Const COL_CFG_MAX_STRIKES As Long = 12          ' L
' Quantidade de dias da suspensao automatica disparada por strikes.
' Default em Util_Config.GetDiasSuspensaoStrike(): 90.
Public Const COL_CFG_DIAS_SUSPENSAO_STRIKE As Long = 13 ' M
Public Const LINHA_CFG_VALORES As Long = 2        ' Linha dos valores na CONFIG

' --- Aba EMPRESAS (e EMPRESAS_INATIVAS) ---
Public Const COL_EMP_ID As Long = 1               ' A
Public Const COL_EMP_CNPJ As Long = 2             ' B
Public Const COL_EMP_RAZAO As Long = 3            ' C
Public Const COL_EMP_INSCR_MUN As Long = 4        ' D
Public Const COL_EMP_RESPONSAVEL As Long = 5      ' E
Public Const COL_EMP_CPF_RESP As Long = 6         ' F
Public Const COL_EMP_ENDERECO As Long = 7         ' G
Public Const COL_EMP_BAIRRO As Long = 8           ' H
Public Const COL_EMP_MUNICIPIO As Long = 9        ' I
Public Const COL_EMP_CEP As Long = 10             ' J
Public Const COL_EMP_UF As Long = 11              ' K
Public Const COL_EMP_TEL_FIXO As Long = 12        ' L
Public Const COL_EMP_TEL_CEL As Long = 13         ' M
Public Const COL_EMP_EMAIL As Long = 14           ' N
Public Const COL_EMP_EXPERIENCIA As Long = 15     ' O
Public Const COL_EMP_STATUS_GLOBAL As Long = 16   ' P
Public Const COL_EMP_DT_FIM_SUSP As Long = 17     ' Q
Public Const COL_EMP_QTD_RECUSAS As Long = 18     ' R
Public Const COL_EMP_DT_CAD As Long = 19          ' S
Public Const COL_EMP_DT_ULT_ALT As Long = 20      ' T

' --- Aba ENTIDADE (e ENTIDADE_INATIVOS) ---
Public Const COL_ENT_ID As Long = 1               ' A
Public Const COL_ENT_CNPJ As Long = 2             ' B
Public Const COL_ENT_NOME As Long = 3             ' C
Public Const COL_ENT_TEL_FIXO As Long = 4         ' D
Public Const COL_ENT_TEL_CEL As Long = 5         ' E
Public Const COL_ENT_EMAIL As Long = 6            ' F
Public Const COL_ENT_ENDERECO As Long = 7         ' G
Public Const COL_ENT_BAIRRO As Long = 8           ' H
Public Const COL_ENT_MUNICIPIO As Long = 9        ' I
Public Const COL_ENT_CEP As Long = 10             ' J
Public Const COL_ENT_UF As Long = 11              ' K
Public Const COL_ENT_CONT1_NOME As Long = 12      ' L
Public Const COL_ENT_CONT1_FONE As Long = 13      ' M
Public Const COL_ENT_CONT1_FUNCAO As Long = 14    ' N
Public Const COL_ENT_CONT2_NOME As Long = 15      ' O
Public Const COL_ENT_CONT2_FONE As Long = 16      ' P
Public Const COL_ENT_CONT2_FUNCAO As Long = 17    ' Q
Public Const COL_ENT_CONT3_NOME As Long = 18      ' R
Public Const COL_ENT_CONT3_FONE As Long = 19      ' S
Public Const COL_ENT_CONT3_FUNCAO As Long = 20    ' T
Public Const COL_ENT_INFO_ADIC As Long = 21       ' U
Public Const COL_ENT_DT_CAD As Long = 22          ' V

' --- Aba ATIVIDADES ---
Public Const COL_ATIV_ID As Long = 1              ' A
Public Const COL_ATIV_CNAE As Long = 2            ' B
Public Const COL_ATIV_DESCRICAO As Long = 3       ' C

' --- Aba CAD_SERV ---
Public Const COL_SERV_ID As Long = 1              ' A
Public Const COL_SERV_ATIV_ID As Long = 2         ' B
Public Const COL_SERV_ATIV_DESC As Long = 3       ' C
Public Const COL_SERV_DESCRICAO As Long = 4       ' D
Public Const COL_SERV_VALOR_UNIT As Long = 5      ' E
Public Const COL_SERV_RESERVA1 As Long = 6        ' F
Public Const COL_SERV_RESERVA2 As Long = 7        ' G
Public Const COL_SERV_RESERVA3 As Long = 8        ' H
Public Const COL_SERV_DT_CAD As Long = 9          ' I

' --- Aba CREDENCIADOS ---
Public Const COL_CRED_ID As Long = 1              ' A
Public Const COL_CRED_COD_ATIV_SERV As Long = 2   ' B
Public Const COL_CRED_EMP_ID As Long = 3          ' C
Public Const COL_CRED_CNPJ As Long = 4            ' D
Public Const COL_CRED_RAZAO As Long = 5           ' E
Public Const COL_CRED_POSICAO As Long = 6         ' F
Public Const COL_CRED_ULT_OS As Long = 7          ' G
Public Const COL_CRED_DT_ULT_OS As Long = 8       ' H
Public Const COL_CRED_INATIVO_FLAG As Long = 9    ' I
Public Const COL_CRED_ATIV_ID As Long = 10        ' J
Public Const COL_CRED_RECUSAS As Long = 11        ' K
Public Const COL_CRED_EXPIRACOES As Long = 12     ' L
Public Const COL_CRED_STATUS As Long = 13         ' M
Public Const COL_CRED_DT_ULT_IND As Long = 14    ' N
Public Const COL_CRED_DT_CRED As Long = 15       ' O

' --- Aba PRE_OS ---
Public Const COL_PREOS_ID As Long = 1             ' A
Public Const COL_PREOS_ENT_ID As Long = 2         ' B
Public Const COL_PREOS_COD_SERV As Long = 3       ' C
Public Const COL_PREOS_EMP_ID As Long = 4         ' D
Public Const COL_PREOS_DT_EMISSAO As Long = 5     ' E
Public Const COL_PREOS_DT_LIMITE As Long = 6      ' F
Public Const COL_PREOS_ATIV_ID As Long = 7        ' G
Public Const COL_PREOS_DT_EM_OS As Long = 8       ' H
Public Const COL_PREOS_QT_EST As Long = 9         ' I
Public Const COL_PREOS_VL_EST As Long = 10        ' J
Public Const COL_PREOS_VL_UNIT As Long = 11       ' K
Public Const COL_PREOS_STATUS As Long = 12        ' L
Public Const COL_PREOS_MOTIVO As Long = 13        ' M
Public Const COL_PREOS_OS_ID As Long = 14         ' N

' --- Aba CAD_OS ---
Public Const COL_OS_ID As Long = 1                ' A
Public Const COL_OS_ENT_ID As Long = 2            ' B
Public Const COL_OS_COD_SERV As Long = 3          ' C
Public Const COL_OS_EMP_ID As Long = 4            ' D
Public Const COL_OS_EMPENHO As Long = 5           ' E
Public Const COL_OS_DT_EMISSAO As Long = 6        ' F
Public Const COL_OS_DT_PREV_FIM As Long = 7       ' G
Public Const COL_OS_DT_FECHAMENTO As Long = 8     ' H
Public Const COL_OS_QT_EST As Long = 9            ' I
Public Const COL_OS_VL_TOTAL As Long = 10         ' J
Public Const COL_OS_QT_EXEC As Long = 11          ' K
Public Const COL_OS_VL_EXEC As Long = 12          ' L
Public Const COL_OS_DT_PAGTO As Long = 13         ' M
Public Const COL_OS_NOTA_01 As Long = 14          ' N
Public Const COL_OS_NOTA_02 As Long = 15          ' O
Public Const COL_OS_NOTA_03 As Long = 16          ' P
Public Const COL_OS_NOTA_04 As Long = 17          ' Q
Public Const COL_OS_NOTA_05 As Long = 18          ' R
Public Const COL_OS_NOTA_06 As Long = 19          ' S
Public Const COL_OS_NOTA_07 As Long = 20          ' T
Public Const COL_OS_NOTA_08 As Long = 21          ' U
Public Const COL_OS_NOTA_09 As Long = 22          ' V
Public Const COL_OS_NOTA_10 As Long = 23          ' W
Public Const COL_OS_MEDIA As Long = 24            ' X
Public Const COL_OS_OBSERVACOES As Long = 25      ' Y
Public Const COL_OS_ATIV_ID As Long = 26          ' Z
Public Const COL_OS_PREOS_ID As Long = 27         ' AA
Public Const COL_OS_STATUS As Long = 28           ' AB
Public Const COL_OS_VL_UNIT As Long = 29          ' AC
Public Const COL_OS_JUSTIF_DIV As Long = 30       ' AD

' --- Aba AUDIT_LOG ---
Public Const COL_AUDIT_ID As Long = 1             ' A
Public Const COL_AUDIT_DT As Long = 2             ' B
Public Const COL_AUDIT_USUARIO As Long = 3        ' C
Public Const COL_AUDIT_TIPO As Long = 4           ' D
Public Const COL_AUDIT_TIPO_DESC As Long = 5      ' E
Public Const COL_AUDIT_ENTIDADE As Long = 6       ' F
Public Const COL_AUDIT_ID_AFETADO As Long = 7     ' G
Public Const COL_AUDIT_ANTES As Long = 8          ' H
Public Const COL_AUDIT_DEPOIS As Long = 9         ' I

' --- NOTA V12-CLEAN ---
' Funcoes UltimaLinhaAba, ProximoId e PrimeiraLinhaDadosEmpresas
' foram movidas para Util_Planilha.bas (modulo de constantes nao deve conter logica).
' IdsIguais centralizada em Util_Planilha.bas.


