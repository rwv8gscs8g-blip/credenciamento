# Fluxos de Negocio Principais

---

## Fluxo 1: Credenciar Empresa (Setup Inicial)

**Atores**: Admin Prefeitura
**Tempo**: 5-10 minutos
**Resultado**: Empresa pronta para receber ordens de servico

```
1. ADMIN ABRE MENU_PRINCIPAL
   └─ Auto_Open ja executou, contexto OK

2. ADMIN CLICA "CREDENCIAR EMPRESA"
   └─ Abre form Credencia_Empresa

3. ADMIN PREENCHE DADOS
   └─ CNPJ (validado em real-time)
   └─ Nome (nao pode vazio)
   └─ Endereco (nao pode vazio)
   └─ Contato (telefone ou email)
   └─ Validacoes sao visuais (cor verde/vermelho)

4. ADMIN CLICA "OK"
   └─ Form chama:
      └─ Util_Conversao.ValidarEmpresa(emp) — validacoes finais
      └─ Repo_Credenciamento.CriarEmpresa(emp) — insere em DB
      └─ Audit_Log.LogOperacao("INSERT", "Credencia_Empresa", ...) — loga
   └─ Se sucesso:
      └─ MsgBox "Empresa criada com ID 5"
      └─ Form fecha
   └─ Se erro:
      └─ ErrorBoundary captura erro
      └─ MsgBox com erro detalhado
      └─ Form fica aberta para retry

5. EMPRESA AGORA ATIVA NO SISTEMA
   └─ Pode ter entidades associadas (matriz, filiais)
   └─ Pode ser credenciada em atividades
   └─ Pronta para receber ordens de servico

FIM
```

---

## Fluxo 2: Credenciar Empresa em Atividade

**Atores**: Admin Prefeitura
**Tempo**: 2-3 minutos
**Resultado**: Empresa pode receber ordens para tipo de servico X

```
1. ADMIN CLICA "CADASTRAR SERVICO"
   └─ Abre form Cadastro_Servico

2. ADMIN DIGITA NOME DO SERVICO
   └─ Exemplo: "Reparos de eletrica residencial"

3. ADMIN CLICA "CLASSIFICAR AUTOMATICAMENTE"
   └─ ProgressBar mostra progresso
   └─ Chama Classificar.ClassificarServico(nome)
      └─ Testa padroes regex: "eletri" → ELETRICA
      └─ Retorna classificacao proposta
   └─ Label mostra: "Classificacao Detectada: ELETRICA"

4. ADMIN CONFIRMA OU ALTERA CLASSIFICACAO
   └─ Se OK: nada fazer
   └─ Se alterar: dropdown oferece opcoes (ENCANAMENTO, LIMPEZA, etc)

5. ADMIN SELECIONA EMPRESAS PARA ALCAR
   └─ Grid popula com todas empresas ativas
   └─ Admin seleciona checkbox para empresas que podem fazer este servico
   └─ Exemplo: Empresa A, Empresa C, Empresa D selecionadas

6. ADMIN CLICA "REGISTRAR SERVICO E ALOCAR"
   └─ Form chama:
      └─ Repo_Credenciamento.CriarAtividade({Nome, Classificacao, Ativo=True})
         └─ Insere nova atividade em planilha
      └─ Para cada empresa selecionada:
         └─ Repo_Credenciamento.CriarCredenciamento({EmpresaId, AtividadeId})
            └─ Insere relacionamento empresa-atividade
      └─ Audit_Log registra: criacao de atividade + X alocacoes
   └─ MsgBox "Atividade criada, alocada para 3 empresas"
   └─ Form fecha

7. ATIVIDADE AGORA ATIVA
   └─ 3 empresas podem receber ordens para "Reparos de eletrica"
   └─ Svc_Rodizio usara estas 3 para alcar proxima ordem

FIM
```

---

## Fluxo 3: Criar e Emitir Ordem de Servico

**Atores**: Operador Prefeitura
**Tempo**: 5 minutos
**Resultado**: Ordem de servico emitida para empresa executar

```
1. OPERADOR ABRE MENU_PRINCIPAL

2. OPERADOR CLICA "CRIAR ORDEM DE SERVICO"
   └─ Abre submenu:
      └─ "Nova Pre-Ordem"
      └─ "Converter Pre-Ordem em OS"
      └─ "Ver Ordens Existentes"

3. OPERADOR CLICA "NOVA PRE-ORDEM"
   └─ Form oferece dropdowns:
      └─ Dropdown "Selecionar Atividade" (ex: "Reparos de eletrica")
      └─ Button "Alcar Proxima Empresa"

4. OPERADOR CLICA "ALCAR PROXIMA EMPRESA"
   └─ Form chama:
      └─ Svc_Rodizio.ProximaEmpresaParaOS(atividadeId)
         └─ Internamente:
            └─ Svc_Rodizio.AplicarRodizio(atividadeId)
            └─ Calcula score para cada empresa credenciada
            └─ Retorna empresa com maior score (melhor prioridade)
      └─ Exemplo: Empresa A tem media 4.5 e 2 OS recentes → prioridade alta
      └─ Label popula: "Proxima Empresa: Empresa A (Prioridade: 95/100)"

5. OPERADOR CONFIRMA E CLICA "CRIAR PRE-OS"
   └─ Form chama:
      └─ Svc_PreOS.CriarPreOSParaEmpresa(empresaId, atividadeId)
         └─ Valida:
            └─ Empresa existe? Ativo?
            └─ Atividade existe? Ativo?
            └─ Credenciamento existe?
         └─ Se tudo OK:
            └─ Cria TPreOS novo
            └─ Insere em planilha PreOS com Status="RASCUNHO"
            └─ Log: "PRE_OS_CRIADA"
      └─ MsgBox "Pre-OS 123 criada com status RASCUNHO"
   └─ Form oferece opcoes:
      └─ "Revisar Pre-OS antes de emitir"
      └─ "Emitir Ordem Agora"

6. OPERADOR CLICA "EMITIR ORDEM AGORA" (ou faz Revisar depois)
   └─ Form chama:
      └─ Svc_PreOS.ValidarPreOSAntesDaOS(preOSId)
         └─ Validacoes finais: dados intactos? Relacionamentos OK?
      └─ Se validacao OK:
         └─ Svc_OS.ConverterPreOSEmOS(preOSId)
            └─ Chama Svc_OS.GerarNumeroOS()
               └─ PREFEITURA="SAO_PAULO" (de Util_Config)
               └─ YYYYMMDD="20260410" (Today)
               └─ SEQUENCIA=1 (primeiro do dia), 2, 3, ...
               └─ Resultado: "SAO_PAULO-20260410-00001"
            └─ Cria TOS novo
            └─ Insere em planilha OS com Status="EMITIDA"
            └─ Atualiza PreOS: Status="CONVERTIDA"
            └─ Log: "OS_CRIADA"
      └─ MsgBox "Ordem emitida! Numero: SAO_PAULO-20260410-00001"

7. ORDEM AGORA EMITIDA
   └─ Empresa recebe notification (futuro)
   └─ Operador pode imprimir ordem para enviar fisicamente
   └─ Status="EMITIDA" (pronta para empresa comear)

FIM
```

---

## Fluxo 4: Empresas Executa e Conclui Servico

**Atores**: Empresa (fora do sistema)
**Tempo**: Variavel (dias/semanas)
**Resultado**: Servico concluido, pronto para avaliacao

```
1. EMPRESA RECEBE ORDEM (fisicamente ou por email)
   └─ Numero: SAO_PAULO-20260410-00001

2. EMPRESA EXECUTA SERVICO
   └─ (fora do sistema, no terreno)

3. EMPRESA MARCA COMO CONCLUIDA
   └─ Via Menu_Principal > "Relatorios" > "Ordens por Empresa"
   └─ Seleciona empresa
   └─ Grid mostra ordens
   └─ Em coluna "Status", dropdown permite mudar:
      └─ EMITIDA → EM_PROGRESSO (comecou)
      └─ EM_PROGRESSO → CONCLUIDA (terminou)
      └─ CONCLUIDA ← EMITIDA (cancelada, se houver problema)

4. OPERADOR CLICA "CONCLUIDA"
   └─ Form chama:
      └─ Svc_OS.ConcluirOS(osId, dataConclusao=Today)
         └─ Atualiza TOS:
            └─ Status="CONCLUIDA"
            └─ DataConclusao=20260410
         └─ Salva em planilha
         └─ Log: "OS_CONCLUIDA"
      └─ MsgBox "Ordem SAO_PAULO-20260410-00001 concluida"

5. OS AGORA PRONTA PARA AVALIACAO
   └─ Status="CONCLUIDA"
   └─ Historico completo ja loggado

FIM
```

---

## Fluxo 5: Avaliar Servico Executado

**Atores**: Admin/Gestor Prefeitura
**Tempo**: 2-3 minutos
**Resultado**: Avaliacao registrada, media empresa atualizada

```
1. GESTOR ABRE "RELATORIOS" > "ORDENS POR EMPRESA"
   └─ Seleciona empresa (ex: Empresa A)
   └─ Grid mostra todas ordens (EMITIDA, EM_PROGRESSO, CONCLUIDA)

2. GESTOR LOCALIZA ORDEM CONCLUIDA
   └─ Coluna "Status" mostra "CONCLUIDA"
   └─ Coluna "Nota Avaliacao" está vazia (ainda nao avaliada)

3. GESTOR CLICA "AVALIAR" BUTTON NA LINHA
   └─ Dialog abre:
      └─ Label: "Ordem: SAO_PAULO-20260410-00001"
      └─ Label: "Empresa: Empresa A"
      └─ Spinner "Nota" (1-5)
      └─ TextBox "Comentario" (opcional)

4. GESTOR SELECIONA NOTA
   └─ Spinner ou RadioButtons: 1, 2, 3, 4, 5
   └─ Exemplo: Seleciona 4 (bom)

5. GESTOR DIGITA COMENTARIO (OPCIONAL)
   └─ Exemplo: "Equipe atenciosa, trabalho bem feito, recomendado"

6. GESTOR CLICA "SALVAR"
   └─ Dialog chama:
      └─ Validacoes:
         └─ Nota entre 1 e 5? Sim
         └─ OS Status="CONCLUIDA"? Sim
         └─ OS ja tem avaliacao? Nao (pode criar)
      └─ Svc_Avaliacao.RegistrarAvaliacao(osId, nota=4.0, comentario)
         └─ Cria TAvaliacao novo
         └─ Insere em planilha Avaliacao
         └─ Log: "AVALIACAO_REGISTRADA"
         └─ Chama AtualizarMediaEmpresa(empresaId=1)
            └─ Calcula media de TODAS avaliacoes:
               └─ OS1: nota 4.0
               └─ OS2: nota 5.0
               └─ OS3: nota 3.0
               └─ Media = (4+5+3)/3 = 4.0
            └─ Resultado: Empresa A agora tem media 4.0
      └─ MsgBox "Avaliacao registrada. Media Empresa A: 4.0/5"
   └─ Dialog fecha
   └─ Grid atualiza: coluna "Nota Avaliacao" agora mostra 4.0

7. PROXIMA ALOCACAO CONSIDERA MEDIA
   └─ Svc_Rodizio.AplicarRodizio() para esta atividade
   └─ Empresa A agora tem score: (100 - 0) + 10 + 5 = 115 (media 4.0)
   └─ Se havia Empresa B com media 2.0: score = (100 - 20) + (-10) + 5 = 75
   └─ Proxima ordem vai para Empresa A (melhor performance)

FIM
```

---

## Fluxo 6: Relatorios e Analytics

**Atores**: Admin/Gestor
**Tempo**: 1-2 minutos
**Resultado**: Dados para decisoes strategicas

```
1. GESTOR CLICA "RELATORIOS"
   └─ Menu oferece:
      └─ "Empresas por Atividade"
      └─ "Ordens por Periodo"
      └─ "Avaliacoes por Empresa"

2. GESTOR CLICA "EMPRESAS POR ATIVIDADE"
   └─ Abre form Rel_Emp_Serv
   └─ Grid mostra:
      └─ Colunas: EmpresaId, Nome, Atividade, Classificacao, DataCredenciamento
      └─ Exemplo:
         └─ 1, Empresa A, Reparos Eletrica, ELETRICA, 2026-01-15
         └─ 1, Empresa A, Limpeza, LIMPEZA, 2026-01-20
         └─ 2, Empresa B, Encanamento, ENCANAMENTO, 2026-02-01

3. GESTOR APLICA FILTROS
   └─ TextBox "Buscar Empresa": digita "A" → grid filtra
   └─ Dropdown "Classificacao": seleciona "ELETRICA" → grid filtra
   └─ Resultado: Apenas Empresa A com ELETRICA

4. GESTOR CLICA "EXPORTAR CSV"
   └─ File dialog pede salvar em:
      └─ Documents/Relatorios/Rel_EmpServ_20260410_143022.csv
   └─ CSV gerado com dados visibilizados
   └─ Usuario pode abrir em Excel, passar para gestor superior

5. GESTOR CLICA "IMPRIMIR"
   └─ Print dialog abre
   └─ Usuario pode imprimir grid
   └─ Papel mostra data, empresa, atividade

FIM
```

---

## Fluxo 7: Sincronizacao Excel → SaaS (Futuro)

**Atores**: Admin, SaaS Backend
**Tempo**: 1-2 minutos
**Resultado**: Dados Excel replicados em banco SaaS

```
1. ADMIN ABRE MENU_PRINCIPAL

2. ADMIN CLICA "SINCRONIZAR COM SAAS"
   └─ Form pede autenticacao:
      └─ Email (ex: admin@prefeitura.com.br)
      └─ Senha

3. ADMIN DIGITA CREDENCIAIS
   └─ Form valida contra SaaS (futuro)
   └─ Se OK: mostra progressBar

4. SISTEMA COLETA DADOS
   └─ Lê planilhas: Empresa, Entidade, Atividade, OS, Avaliacao, AuditLog
   └─ Converte para JSON
   └─ Payload exemplo:
      ```json
      {
        "tenant_id": "prefeitura-sao-paulo-123",
        "timestamp": "2026-04-10T14:30:00Z",
        "data": {
          "empresas": [
            {"id": 1, "nome": "Empresa A", "cnpj": "..."},
            {"id": 2, "nome": "Empresa B", "cnpj": "..."}
          ],
          "ordens_servico": [
            {"id": 1, "numero": "SAO_PAULO-20260410-00001", "status": "CONCLUIDA"},
            {"id": 2, "numero": "SAO_PAULO-20260410-00002", "status": "EMITIDA"}
          ],
          "avaliacoes": [
            {"id": 1, "os_id": 1, "nota": 4.0, "comentario": "..."}
          ]
        }
      }
      ```

5. SISTEMA ENVIA PARA SAAS
   └─ POST /api/sync/import (endpoint SaaS)
   └─ Headers: Authorization: Bearer {token}
   └─ Body: JSON acima

6. SAAS PROCESSA
   └─ Valida tenant_id e usuario permissoes
   └─ Para cada tabela em "data":
      └─ UPSERT em Postgres (insert se novo, update se existe)
      └─ Comparacao por chave unica: CNPJ para empresas, numero para OS
   └─ Log de sincronizacao
   └─ Retorna resposta:
      ```json
      {
        "sucesso": true,
        "mensagem": "Sincronizado com sucesso",
        "registros_processados": {
          "empresas": 5,
          "ordens": 12,
          "avaliacoes": 8
        }
      }
      ```

7. EXCEL MOSTRA RESULTADO
   └─ ProgressBar completa
   └─ MsgBox "Sincronizacao OK: 5 empresas, 12 ordens, 8 avaliacoes"
   └─ Log em AuditLog: "SYNC_SAAS_ENVIADO"

8. SAAS DASHBOARD ATUALIZA
   └─ Dashboard Next.js carrega dados novos
   └─ Usuarios SaaS veem dados atualizados
   └─ Podem criar relatorios, analytics, etc

FIM
```

---

## Fluxo 8: Gestao de Erro em Compilacao (Troubleshooting)

**Atores**: Developer
**Tempo**: 15-60 minutos (dependendo causa)
**Resultado**: Bug resolvido, release nota criada

```
1. DEVELOPER FIZA MUDANCA EM VBA
   └─ Exemplo: adicionar Util_CNAE.bas novo

2. DEVELOPER IMPORTA EM EXCEL
   └─ Alt+F11 → Visual Basic Editor
   └─ File > Import File → vba_export/Util_CNAE.bas

3. DEVELOPER COMPILA
   └─ Debug > Compile VBA Project
   └─ RESULTADO: ERRO!
      └─ "Variavel nao definida: TextBox1"

4. DEVELOPER INVESTIGA
   └─ Abrir arquivo Util_CNAE.bas no editor
   └─ Procura por TextBox1
   └─ Encontra: "TextBox1.Value = result" mas nenhuma declaracao

5. DEVELOPER CORRIGE
   └─ Edita vba_export/Util_CNAE.bas:
      └─ Adiciona: Dim textBox1 As String
      └─ Ou renomeia: .Value → .Caption

6. DEVELOPER REIMPORTA
   └─ File > Import File (select Util_CNAE.bas de novo)
   └─ Confirma sobrescrita

7. DEVELOPER COMPILA NOVAMENTE
   └─ Debug > Compile VBA Project
   └─ RESULTADO: OK (silencioso, sem erros)

8. DEVELOPER TESTA
   └─ Menu_Principal > Central_Testes > "Teste_Util_CNAE"
   └─ Resulta: PASSOU

9. DEVELOPER CRIA RELEASE NOTE
   └─ releases/V12.0.0108.md

10. DEVELOPER COMITA
    └─ git add vba_export/Util_CNAE.bas releases/V12.0.0108.md
    └─ git commit -m "V12.0.0108: Adicionar Util_CNAE (import CNAE)"
    └─ git push origin main

FIM
```

---

**Todos fluxos documentados**
**Ultima Atualizacao**: 2026-04-10
