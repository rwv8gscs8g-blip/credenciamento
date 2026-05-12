---
titulo: Protocolo de Homologação Humana V12.0.0204
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-12
---

# PROTOCOLO DE HOMOLOGAÇÃO HUMANA V12.0.0204
## Regras de Negócio, Testes Automatizados, Testes Manuais e Critérios de Liberação

---

## CAPA

| Campo | Valor |
|---|---|
| Nome do sistema | Sistema de Credenciamento e Rodízio de Pequenos Reparos |
| Versão oficial | V12.0.0204 |
| Build importado | `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |
| Data de referência do protocolo | 2026-05-12 |
| Status oficial da versão | VALIDADO |
| Gate automático final aprovado | `VR_20260511_175849` (com evidência paralela de publicação `VR_20260511_154433`) |
| Sintaxe canônica aprovada | `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` |
| Público-alvo do documento | Testador humano externo ao desenvolvimento, sem acesso ao Editor VBA e sem necessidade de conhecimento interno do projeto |
| Mantenedor técnico | Luís Maurício Junqueira Zanin |
| Criação histórica da planilha | Sergio Cintra |
| Licença pública | TPGL v1.1 (conversão automática para Apache 2.0 após 4 anos) |

### Identificação da homologação (preencher)

| Campo | Preenchimento |
|---|---|
| Nome do testador |  |
| Organização / município |  |
| E-mail do testador |  |
| Data de início da homologação |  |
| Data de encerramento da homologação |  |
| Máquina utilizada (Windows + Excel + versão) |  |
| Local físico do teste |  |
| Pessoa que entregou o arquivo `.xlsm` |  |
| Pasta onde estão salvas as evidências |  |
| Assinatura do testador |  |

---

## CONTROLE DO DOCUMENTO

| Versão do documento | Versão do sistema | Responsável técnico | Responsável pela homologação | Data | Status | Observações |
|---|---|---|---|---|---|---|
| 1.0 | V12.0.0204 | Luís Maurício Junqueira Zanin | (a ser preenchido pelo testador externo) | 2026-05-12 | EM HOMOLOGAÇÃO | Documento canônico de homologação humana V204; complementa o Roteiro Manual V204 (`docs/reference/testes/07_ROTEIRO_TESTE_MANUAL_V204.md`) e o Guia Humano V204 (`docs/tutorials/GUIA_TESTES_HUMANOS_V204.md`) |
|  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |

---

## SUMÁRIO

1. Finalidade do documento
2. Escopo da homologação
3. Preparação do ambiente Windows
4. Regras de negócio canônicas da V12.0.0204
5. Mapa dos testes automatizados
6. Validação da qualidade dos próprios testes
7. Roteiro de testes manuais exaustivo
8. Matriz Regra → Teste automático → Teste manual → Evidência
9. Checklist de liberação para produção
10. Modelo de relatório final do testador
11. Modelo de bug report
12. Itens não cobertos pelos testes automatizados
13. Novos testes propostos para V12.0.0205
14. Anexos
15. Lacunas finais e recomendação de evolução V12.0.0205

---

## 1. FINALIDADE DO DOCUMENTO

Este documento é o **protocolo único e auditável** de homologação humana da **V12.0.0204**. Ele substitui, para fins de decisão de produção, a leitura solta de roteiros, regras e guias parciais.

Sua função é:

1. permitir que **um testador humano externo**, sem acesso ao código VBA, sem Janela Imediata, sem Editor VBA, sem importação de módulos e sem conhecimento do histórico de ondas, valide a release **apenas pela interface do Excel**;
2. produzir **evidências preenchíveis** suficientes para sustentar a decisão formal de:
   - **APROVAR para produção**;
   - **APROVAR COM RESSALVAS**; ou
   - **REPROVAR**;
3. **rastrear cada regra de negócio** até pelo menos uma forma de validação (automática, manual ou declarada como lacuna);
4. preservar a separação entre o que está coberto por teste automático verde e o que ainda exige observação humana;
5. fornecer modelo formal de **bug report** e **relatório final**.

Este protocolo é **complementar** ao gate automatizado: o teste automático verde é apenas a **primeira etapa**. A homologação humana é obrigatória antes de qualquer decisão de liberação pública. Um gate automático aprovado **não substitui** o roteiro manual descrito aqui.

---

## 2. ESCOPO DA HOMOLOGAÇÃO

### 2.1 O que será testado

- **Identidade do arquivo**: que o `.xlsm` recebido é realmente a V12.0.0204 com o build final `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`.
- **Liberação de macros**: que a planilha abre num ambiente Windows com Excel Desktop após desbloqueio do arquivo, habilitação de edição e habilitação de conteúdo.
- **Bateria automática** (Sexteto Mínimo) pela **Central de Testes**, sem abrir VBE: V1, V2 Smoke, V2 Canônica, E2E Strikes, IntegridadeBase e bloco adversarial Onda 23 (Adversarial UI, Transaction Interrupt, Boundary Dates).
- **Fluxos manuais críticos** pela interface da planilha:
  - cadastros (entidade, empresa, atividade, serviço);
  - credenciamento;
  - rodízio (seleção da empresa apta);
  - emissão de Pré-OS, aceite, recusa, expiração e conversão em OS;
  - conclusão de OS;
  - avaliação (nota mínima, justificativa, strike);
  - suspensão por strikes e reativação manual/automática;
  - Limpar Base e reuso municipal.
- **Auditoria operacional** mínima: presença de eventos relevantes em `AUDIT_LOG`, `RPT_LIMPEZA_TOTAL` e `VALIDACAO_RELEASE`.

### 2.2 O que NÃO será testado

- **Código-fonte VBA** linha a linha.
- **Editor VBA** ou Janela Imediata como caminho de validação.
- **Importação de módulos VBA** (`Importador V3`) — operação restrita ao mantenedor.
- **Performance sob carga real de produção** (testes de stress longos).
- **Compatibilidade exaustiva** com diferentes versões/locales de Excel além de Windows + Excel Desktop padrão (Excel para Mac, Excel Online, Excel 2010 e anteriores estão **fora** do escopo da V204).
- **Penetração de segurança** do projeto VBA (a proteção do projeto VBA reduz edição casual, mas **não** é criptografia forte).
- **Reimportação de pacotes** (responsabilidade do mantenedor antes de gerar o `.xlsm` final).

### 2.3 Premissas

1. O testador recebe o `.xlsm` **pronto e protegido** pelo mantenedor, com o build final importado, compilação limpa e proteção do projeto VBA aplicada.
2. O testador executa o ciclo em uma máquina **Windows 10 ou 11** com **Excel Desktop** instalado.
3. O testador tem permissão local para salvar o `.xlsm` e gerar arquivos auxiliares (CSV de evidência, prints).
4. O testador tem acesso ao **botão Sobre**, ao **botão Central de Testes** e aos formulários operacionais da planilha sem necessidade de senha do projeto VBA.
5. O testador **não** dispõe de senha de Limpar Base por padrão; o mantenedor pode informá-la separadamente quando o roteiro M-12 a M-14 fizer parte do escopo.

### 2.4 Ambiente esperado

| Item | Valor mínimo aceitável |
|---|---|
| Sistema operacional | Windows 10 (build atualizado) ou Windows 11 |
| Aplicação | Microsoft Excel Desktop (não Web, não Mac) |
| Idioma do Excel | Português Brasil ou Inglês US (preferencial PT-BR) |
| Política de macros | Permitida para arquivos locais habilitados pelo usuário |
| Espaço em disco | Mínimo de 200 MB livres na pasta de testes |
| Permissão de escrita | Necessária na pasta onde o `.xlsm` está salvo (para gravação de CSV de evidência) |
| Resolução de tela | Mínimo 1280×720 para acomodar formulários e mensagens |
| Acesso de rede | Não exigido para rodar a bateria oficial |

### 2.5 Responsabilidades do testador

1. Conferir identidade do arquivo (botão **Sobre**) antes de qualquer execução.
2. Executar o **Sexteto Mínimo** pela Central de Testes e capturar evidência.
3. Executar os fluxos manuais obrigatórios deste protocolo, registrando data, hora, resultado, prints e observações.
4. Classificar anomalias por severidade (P0/P1/P2/P3) usando os critérios da Seção 7.
5. Preencher o relatório final (Seção 10) e os bug reports (Seção 11) ao encerrar o ciclo.
6. **Não** reabrir, importar ou editar código VBA. Se o roteiro pedir isso como caminho principal, registrar como inconsistência documental.
7. Recusar arquivo cujo projeto VBA esteja aberto para edição casual, salvo escopo formal de auditoria de código.

### 2.6 Responsabilidades do mantenedor

1. Entregar `.xlsm` com build final importado, compilação limpa e proteção do projeto VBA aplicada.
2. Garantir que o botão **Sobre** exibe o triplet correto: versão V12.0.0204, status VALIDADO, build `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`.
3. Anexar este protocolo, o roteiro manual V204, o guia humano V204 e os how-to de liberação de macros e Sexteto.
4. Definir a pasta canônica de evidências (`auditoria/evidencias/V12.0.0204/` ou equivalente acordada com o testador).
5. Responder por qualquer ressalva P0/P1 antes de promover a versão a produção.

---

## 3. PREPARAÇÃO DO AMBIENTE WINDOWS

### 3.1 Passo a passo

1. **Receber o arquivo `.xlsm`** por canal acordado com o mantenedor (e-mail interno, OneDrive, pen drive corporativo, etc.). Confirmar nome e tamanho do arquivo.
2. **Salvar o arquivo em uma pasta local**, por exemplo `Documentos\Homologacao_V204\`. Evitar pastas sincronizadas com nuvens que travem a planilha durante macros.
3. **Desbloquear o arquivo no Windows**:
   - clicar com o botão direito no `.xlsm`;
   - abrir **Propriedades**;
   - na aba **Geral**, marcar **Desbloquear** (se aparecer);
   - clicar em **Aplicar** e **OK**.
4. **Habilitar edição**:
   - abrir o `.xlsm` no Excel Desktop;
   - se aparecer a barra amarela **Modo de Exibição Protegido**, clicar em **Habilitar Edição**.
5. **Habilitar conteúdo**:
   - se aparecer a barra amarela **Aviso de Segurança** sobre macros, clicar em **Habilitar Conteúdo**.
6. **Confirmar que macros rodam**: a tela inicial do sistema deve aparecer com os botões padrão (Cadastros, Central de Testes, Sobre, etc.).
7. **Confirmar botão Sobre**: clicar em **Sobre** e ler o conteúdo da janela.
8. **Confirmar build**: a janela **Sobre** deve mostrar `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`.
9. **Confirmar status VALIDADO**: a janela **Sobre** deve mostrar `Status oficial: VALIDADO` e `Release oficial: V12.0.0204`.
10. **Se o arquivo abrir bloqueado** (macros silenciosamente desativadas, mensagem de origem não confiável): fechar o Excel, repetir a etapa 3 (desbloqueio), fechar novamente, reabrir.
11. **Se política corporativa bloquear macros via GPO**: solicitar ao administrador uma **pasta confiável** para a homologação ou um perfil temporário com permissão de macros para o arquivo específico. Documentar a solicitação como anomalia P0 caso o teste não possa continuar.

### 3.2 Tabela preenchível — Preparação do ambiente

| Item | Esperado | Resultado | Evidência | Observação |
|---|---|---|---|---|
| Arquivo recebido | `.xlsm` íntegro |  |  |  |
| Arquivo desbloqueado no Windows | Caixa **Desbloquear** marcada ou ausente |  |  |  |
| Habilitar Edição | Clicado com sucesso |  |  |  |
| Habilitar Conteúdo | Clicado com sucesso |  |  |  |
| Tela inicial abriu | Botões padrão visíveis |  |  |  |
| Botão **Sobre** abre | Janela exibe versão, status e build |  |  |  |
| Versão exibida | V12.0.0204 |  |  |  |
| Status exibido | VALIDADO |  |  |  |
| Build exibido | `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |  |  |  |
| Macros funcionando | Botões respondem sem erro |  |  |  |
| Política corporativa | Não bloqueia (ou pasta confiável definida) |  |  |  |

### 3.3 Critério de saída desta etapa

A etapa de preparação só pode ser considerada **APROVADA** se todas as linhas da tabela acima tiverem resultado positivo. Caso contrário, suspender o teste e registrar a divergência como **P0** (não é possível validar a release).

---

## 4. REGRAS DE NEGÓCIO CANÔNICAS DA V12.0.0204

Esta seção lista, em forma normativa, todas as regras que a release **não pode** violar. Para cada regra, são apresentados: descrição, deveres (DEVE) e proibições (NÃO PODE), exemplos de comportamento certo e errado, severidade da falha, testes automatizados que cobrem, testes manuais que cobrem, evidência mínima e lacunas conhecidas.

A numeração `RN-XX` é canônica para a V204 e mantém ligação direta com a [matriz de cobertura V204](04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md) e a [matriz de rastreabilidade V204](06_MATRIZ_RASTREABILIDADE_TESTES_V204.md).

### REGRA RN-01 — Credenciamento depende de empresa, entidade, atividade e serviço válidos

- **Descrição normativa**: Uma empresa só pode participar do rodízio quando estiver cadastrada, ativa e credenciada para uma atividade/serviço existente. O credenciamento não pode ser criado sem que entidade, empresa, atividade (CNAE) e serviço já existam e sejam consistentes entre si.
- **O sistema DEVE**:
  - aceitar cadastro de empresa, entidade, atividade e serviço pela interface;
  - bloquear credenciamento órfão (sem empresa, sem atividade ou sem serviço);
  - listar empresa apenas como elegível depois de credenciamento válido;
  - manter chave referencial entre `EMPRESAS`, `ATIVIDADES`, `CAD_SERV` e `CREDENCIADOS`.
- **O sistema NÃO PODE**:
  - permitir credenciamento sem empresa cadastrada;
  - permitir credenciamento apontando para atividade ou serviço inexistente;
  - aceitar empresa duplicada (mesmo CNPJ) sem aviso explícito.
- **Exemplo de comportamento correto**: cadastrar a empresa "Alfa Ltda." (CNPJ `11.111.111/0001-11`), cadastrar serviço "Manutenção predial" para uma atividade CNAE existente, vincular Alfa ao serviço → empresa aparece como elegível para indicação.
- **Exemplo de comportamento incorreto**: clicar em "Credenciar" com lista vazia e o sistema gravar um credenciamento sem empresa.
- **Severidade se falhar**: **P0** (risco de selecionar empresa inexistente em rodízio real).
- **Testes automatizados que cobrem**: V1 Bateria Oficial (regressão histórica), V2 Canônica (cenários canônicos), `MIG_009` (Smoke), `CS_INT_01..05` (IntegridadeBase).
- **Testes manuais que cobrem**: M-02 (entidade), M-03 (empresa), M-04/M-05 (serviço), M-06 (credenciamento).
- **Evidência mínima**: CSV do Sexteto + print das telas de cadastro + listagem da aba `CREDENCIADOS` mostrando a chave canônica.
- **Lacunas conhecidas**: validação manual exaustiva de **todas** as combinações `(empresa × atividade × serviço)` é inviável; o roteiro testa o caminho canônico determinístico.

### REGRA RN-02 — Cadastro de entidade

- **Descrição normativa**: Toda demanda de Pré-OS deve ser originada por uma entidade cadastrada. O sistema deve permitir cadastrar e listar entidades sem duplicar.
- **DEVE**: aceitar nome de entidade único; impedir duplicidade aparente (mesma chave/identificação); permitir consultar entidades cadastradas.
- **NÃO PODE**: registrar duas entidades idênticas como ativas simultaneamente; permitir Pré-OS sem entidade.
- **Comportamento correto**: cadastrar "Secretaria Municipal de Teste V204" → entidade aparece nas listas; tentar cadastrar a mesma novamente → sistema avisa duplicidade ou bloqueia.
- **Comportamento incorreto**: cadastrar duas entidades com o mesmo nome sem aviso.
- **Severidade**: **P1**.
- **Automatizado**: V1, V2 Canônica.
- **Manual**: M-02.
- **Evidência mínima**: print da aba `ENTIDADE` antes e depois do cadastro.
- **Lacunas**: regras anti-duplicidade dependem de padronização do nome/CNPJ; "lacuna a validar" se o nome muda só por acentuação ou espaços.

### REGRA RN-03 — Cadastro de empresa

- **Descrição normativa**: Empresa identificada por razão social e CNPJ deve poder ser cadastrada, listada e ter seu status (ATIVA/INATIVA/SUSPENSA) corretamente refletido.
- **DEVE**: aceitar CNPJ e razão social; refletir status atual em `EMPRESAS`; permitir reativação via fluxo controlado.
- **NÃO PODE**: aceitar CNPJ vazio; permitir alteração de status sem trilha de auditoria.
- **Severidade**: **P0** (empresa fantasma quebra rodízio).
- **Automatizado**: V1, V2 Canônica, IntegridadeBase.
- **Manual**: M-03.
- **Evidência**: print de `EMPRESAS` antes e depois.
- **Lacunas**: validação de CNPJ por dígito verificador é "lacuna a validar"; testar manualmente com CNPJ inválido proposital.

### REGRA RN-04 — Unicidade de CNPJ

- **Descrição normativa**: Não pode haver duas empresas ativas com o mesmo CNPJ.
- **DEVE**: detectar e bloquear cadastro de CNPJ já existente em `EMPRESAS` ativa.
- **NÃO PODE**: aceitar duplicidade silenciosa; permitir CNPJ duplicado entre `EMPRESAS` e `EMPRESAS_INATIVAS` sem critério de reativação.
- **Severidade**: **P0**.
- **Automatizado**: V1 (cobertura por regressão), V2 Canônica.
- **Manual**: M-03 (cadastrar empresa duplicada).
- **Evidência**: print da mensagem de bloqueio.
- **Lacunas**: tolerância a formatação (com/sem pontuação) é "lacuna a validar".

### REGRA RN-05 — Cadastro de atividade (CNAE)

- **Descrição normativa**: Atividades CNAE compõem a base estrutural; devem existir na aba `ATIVIDADES` e ser referenciáveis por serviços.
- **DEVE**: preservar `ATIVIDADES` durante Limpar Base; permitir consulta; impedir vinculação a CNAE inexistente.
- **NÃO PODE**: zerar `ATIVIDADES` em Limpar Base; aceitar serviço sem atividade.
- **Severidade**: **P0** (perda de CNAE inutiliza a planilha para o município).
- **Automatizado**: Smoke `MIG_009` (preservação em Limpar Base), V2 Canônica.
- **Manual**: M-12 (validar preservação após Limpar Base).
- **Evidência**: print de `ATIVIDADES` antes e depois do Limpar Base.
- **Lacunas**: re-importação de CNAE corrigido a partir do `doc/` é responsabilidade do mantenedor — "lacuna a validar" para testador externo.

### REGRA RN-06 — Vínculo CNAE/atividade

- **Descrição normativa**: Serviço deve apontar para atividade CNAE válida.
- **DEVE**: validar a existência da atividade antes de criar o serviço; manter o vínculo em `CAD_SERV`.
- **NÃO PODE**: aceitar serviço apontando para CNAE inexistente.
- **Severidade**: **P1**.
- **Automatizado**: V2 Canônica `CS_22` (associação estável atividade↔serviço).
- **Manual**: M-05 (cadastrar serviço inválido).
- **Evidência**: print da mensagem de bloqueio ao tentar serviço inválido.
- **Lacunas**: nenhuma identificada além das já cobertas.

### REGRA RN-07 — Cadastro de serviço

- **Descrição normativa**: Serviços compõem o catálogo executável da planilha; o cadastro de serviço deve abrir, aceitar entrada válida e listar o serviço criado.
- **DEVE**: abrir formulário sem erro `O objeto é obrigatório`; aceitar nome e atividade válidos; gravar em `CAD_SERV` com cabeçalho canônico.
- **NÃO PODE**: travar com falha VBA; aceitar serviço sem nome.
- **Severidade**: **P1**.
- **Automatizado**: Smoke `MIG_009` (cabeçalho canônico após Limpar Base), V2 Canônica.
- **Manual**: M-04 (abrir tela), M-05 (cadastrar serviço novo).
- **Evidência**: print do formulário **Cadastra e Altera Serviço** + linha gravada em `CAD_SERV`.
- **Lacunas**: nenhuma.

### REGRA RN-08 — Serviço duplicado

- **Descrição normativa**: Serviço com mesmo nome para a mesma atividade deve ser tratado como duplicidade.
- **DEVE**: bloquear ou sinalizar duplicidade; manter integridade de chave.
- **NÃO PODE**: aceitar dois serviços idênticos como ativos para a mesma atividade.
- **Severidade**: **P2** (não bloqueia rodízio, mas polui catálogo).
- **Automatizado**: parcial via V2 Canônica.
- **Manual**: M-05 (tentar duplicar serviço).
- **Evidência**: print da mensagem.
- **Lacunas**: regra anti-duplicidade exata para serviços é "lacuna a validar" — confirmar comportamento real e registrar.

### REGRA RN-09 — Serviço sem atividade válida

- **Descrição normativa**: Cadastro de serviço apontando para atividade inexistente deve ser rejeitado.
- **DEVE**: validar e bloquear.
- **NÃO PODE**: criar serviço órfão em `CAD_SERV`.
- **Severidade**: **P1**.
- **Automatizado**: IntegridadeBase `CS_INT_01..05` (detecção pós-fato).
- **Manual**: M-05 (cadastro com atividade inexistente).
- **Evidência**: print do bloqueio.
- **Lacunas**: o teste automático cobre **detecção**, não necessariamente **prevenção** prévia — "lacuna a validar" no caminho manual.

### REGRA RN-10 — Credenciamento de empresa

- **Descrição normativa**: O credenciamento vincula empresa apta a um serviço/atividade.
- **DEVE**: criar entrada em `CREDENCIADOS`; refletir status `ATIVO`; permitir consultar.
- **NÃO PODE**: criar credenciamento órfão; permitir status `ATIVO` sem empresa ativa.
- **Severidade**: **P0**.
- **Automatizado**: V2 Canônica, E2E Strikes.
- **Manual**: M-06.
- **Evidência**: linha em `CREDENCIADOS`.
- **Lacunas**: nenhuma.

### REGRA RN-11 — Fila de rodízio

- **Descrição normativa**: O sistema deve manter ordem de fila por atividade/serviço e avançar de forma equitativa, sem favorecer empresa específica.
- **DEVE**: selecionar a empresa apta da vez; preservar posição quando empresa é pulada por impedimento legítimo; avançar após recusa, expiração ou conclusão.
- **NÃO PODE**: ignorar empresa apta; selecionar fora da ordem; quebrar a fila ao reativar empresa.
- **Severidade**: **P0**.
- **Automatizado**: V2 Canônica, E2E Strikes (76 asserts), Boundary Dates.
- **Manual**: M-07, M-10, M-11.
- **Evidência**: print da aba `PRE_OS` mostrando sequência canônica `A → B → C → A → B → C`; AUDIT_LOG com `EVT_SELECAO`.
- **Lacunas**: cenários com mais de 5 empresas em rotação completa são automatizados (`CS_E2E_5EMPS`); rotações com 10+ empresas seguem como "lacuna a validar" para inspeção visual.

### REGRA RN-12 — Empresa apta

- **Descrição normativa**: Empresa apta é aquela com `STATUS=ATIVA`, sem OS aberta, sem Pré-OS pendente e fora de janela de suspensão.
- **DEVE**: refletir a aptidão em tempo real; recalcular após reativação.
- **NÃO PODE**: indicar empresa não apta.
- **Severidade**: **P0**.
- **Automatizado**: V2 Canônica, E2E Strikes.
- **Manual**: M-07.
- **Evidência**: aba `RPT_DIAG_RODIZIO` (gerada pelo diagnóstico interno) + `PRE_OS`.
- **Lacunas**: efeitos cruzados (atividade A apta e atividade B impedida) são "lacuna a validar" sob estresse manual.

### REGRA RN-13 — Empresa inativa

- **Descrição normativa**: Empresa em `EMPRESAS_INATIVAS` não pode ser selecionada no rodízio.
- **DEVE**: pular empresa inativa preservando a ordem dos demais.
- **NÃO PODE**: gerar Pré-OS para inativa.
- **Severidade**: **P0**.
- **Automatizado**: V2 Canônica `CS_20` (filtro cadastral), E2E Strikes.
- **Manual**: M-10.
- **Evidência**: print da aba antes e depois.
- **Lacunas**: nenhuma.

### REGRA RN-14 — Empresa suspensa

- **Descrição normativa**: Empresa com `DT_FIM_SUSP` no futuro é considerada suspensa e deve ser pulada.
- **DEVE**: reconhecer suspensão ativa; retornar empresa quando o prazo vence.
- **NÃO PODE**: indicar empresa em suspensão.
- **Severidade**: **P0**.
- **Automatizado**: E2E Strikes `CS_E2E_D_PULA_SUSP` e `CS_E2E_E_VOLTA_*`, Boundary Dates.
- **Manual**: M-10, M-11.
- **Evidência**: `EMPRESAS` mostra `DT_FIM_SUSP` correta; AUDIT_LOG mostra `EVT_SUSPENSAO`.
- **Lacunas**: nenhuma além de bordas temporais cobertas por `BOUNDARY_DATES`.

### REGRA RN-15 — Empresa com Pré-OS pendente

- **Descrição normativa**: Empresa com Pré-OS aguardando aceite ou conversão deve ser bloqueada para nova indicação no mesmo contexto.
- **DEVE**: detectar Pré-OS pendente e pular.
- **NÃO PODE**: gerar Pré-OS dupla simultânea para a mesma empresa no mesmo serviço.
- **Severidade**: **P0**.
- **Automatizado**: V2 Canônica, E2E Strikes.
- **Manual**: M-07/M-08.
- **Evidência**: print da aba `PRE_OS`.
- **Lacunas**: nenhuma.

### REGRA RN-16 — Empresa com OS aberta

- **Descrição normativa**: Empresa com OS `EM_EXECUCAO` deve bloquear nova indicação no contexto correspondente.
- **DEVE**: pular empresa com OS aberta.
- **NÃO PODE**: emitir nova Pré-OS para empresa enquanto OS estiver pendente no mesmo contexto.
- **Severidade**: **P0**.
- **Automatizado**: V2 Canônica, E2E Strikes, IntegridadeBase.
- **Manual**: M-07/M-08.
- **Evidência**: print `CAD_OS`.
- **Lacunas**: contexto "atividade vs serviço" para bloqueio é "lacuna a validar" no manual — registrar comportamento real.

### REGRA RN-17 — Emissão de Pré-OS

- **Descrição normativa**: A indicação de uma empresa para um serviço gera Pré-OS com status `AGUARDANDO_ACEITE`.
- **DEVE**: gravar `PRE_OS` com ID único e vínculos; registrar evento em AUDIT_LOG.
- **NÃO PODE**: emitir Pré-OS sem vínculo válido.
- **Severidade**: **P1**.
- **Automatizado**: V2 Canônica, Smoke.
- **Manual**: M-07, M-08.
- **Evidência**: linha em `PRE_OS`.
- **Lacunas**: nenhuma.

### REGRA RN-18 — Aceite de Pré-OS

- **Descrição normativa**: O aceite da Pré-OS deve mudar seu status para `CONVERTIDA_OS` e gerar OS vinculada.
- **DEVE**: criar OS em `CAD_OS` com `STATUS=EM_EXECUCAO`; preservar a chave da Pré-OS de origem.
- **NÃO PODE**: criar OS órfã; deixar Pré-OS em estado intermediário inconsistente.
- **Severidade**: **P0**.
- **Automatizado**: V2 Canônica, E2E Strikes.
- **Manual**: M-08.
- **Evidência**: `CAD_OS` + AUDIT_LOG `EVT_OS_GERADA`.
- **Lacunas**: nenhuma.

### REGRA RN-19 — Recusa de Pré-OS

- **Descrição normativa**: A recusa de Pré-OS marca o status `RECUSADA` e avança a fila para a próxima empresa apta. Recusas acumuladas além de `MAX_RECUSAS` em janela controlada podem disparar punição.
- **DEVE**: registrar recusa em AUDIT_LOG; avançar fila; aplicar punição conforme configuração.
- **NÃO PODE**: deixar fila parada após recusa; mascarar falha de fila após recusa punível.
- **Severidade**: **P0**.
- **Automatizado**: E2E Strikes, V2 Canônica.
- **Manual**: M-07 (estendido).
- **Evidência**: AUDIT_LOG mostra `EVT_RECUSA` + `EVT_AVANCO_FILA`.
- **Lacunas**: ciclo completo até `MAX_RECUSAS` exato (3) sob operação manual real é "lacuna a validar" exploratoriamente.

### REGRA RN-20 — Expiração de Pré-OS

- **Descrição normativa**: Pré-OS não decidida no prazo (`DIAS_DECISAO`) deve expirar e avançar a fila, registrando evento auditável.
- **DEVE**: expirar Pré-OS quando o prazo vence; gerar `EVT_EXPIRACAO`; avançar a fila.
- **NÃO PODE**: deixar Pré-OS em `AGUARDANDO_ACEITE` indefinidamente.
- **Severidade**: **P1**.
- **Automatizado**: Smoke `EXP_001`, E2E Strikes.
- **Manual**: ver Seção 7 (cenário CM-12).
- **Evidência**: AUDIT_LOG `EVT_EXPIRACAO` + `PRE_OS.STATUS=EXPIRADA`.
- **Lacunas**: simulação manual de expiração depende de alterar data do sistema — "lacuna a validar" para o testador externo; aceitar como **coberto automático**.

### REGRA RN-21 — Conversão de Pré-OS em OS

- **Descrição normativa**: Pré-OS aceita gera OS com vínculo rastreável à demanda original.
- **DEVE**: criar OS preservando chaves; transição atômica (Onda 21/MICRO35 rollback).
- **NÃO PODE**: criar OS sem chave; deixar Pré-OS pendente após conversão.
- **Severidade**: **P0**.
- **Automatizado**: V2 Canônica, E2E Strikes, IntegridadeBase.
- **Manual**: M-08.
- **Evidência**: `CAD_OS` + `PRE_OS.STATUS=CONVERTIDA_OS`.
- **Lacunas**: nenhuma.

### REGRA RN-22 — OS aberta

- **Descrição normativa**: OS em execução deve refletir status `EM_EXECUCAO` e bloquear nova indicação no contexto correto.
- **DEVE**: persistir status; refletir bloqueio no rodízio.
- **NÃO PODE**: aceitar conclusão sem preencher campos obrigatórios.
- **Severidade**: **P0**.
- **Automatizado**: V2 Canônica.
- **Manual**: M-07/M-08.
- **Evidência**: `CAD_OS`.
- **Lacunas**: nenhuma.

### REGRA RN-23 — Conclusão de OS

- **Descrição normativa**: A conclusão deve transitar OS para `CONCLUIDA` e permitir avaliação.
- **DEVE**: gravar data de fechamento; permitir avaliar uma única vez (`OS_JA_AVALIADA=NAO/SIM`).
- **NÃO PODE**: permitir avaliação dupla da mesma OS sem rejeição explícita.
- **Severidade**: **P0**.
- **Automatizado**: V2 Canônica `CS_18` (transições inválidas), E2E Strikes.
- **Manual**: ver cenário CM-15.
- **Evidência**: `CAD_OS.DT_FECHAMENTO` + AUDIT_LOG.
- **Lacunas**: nenhuma.

### REGRA RN-24 — Avaliação

- **Descrição normativa**: A avaliação de uma OS concluída deve calcular média e registrar nota, justificativa (se aplicável), strike (se nota baixa) e auditoria.
- **DEVE**: usar nota mínima da CONFIG (`NOTA_MINIMA`); registrar `Avaliacao Registrada`; aplicar strike quando média for menor que `NOTA_MINIMA`.
- **NÃO PODE**: deixar avaliação silenciosa; recalcular média com fórmulas divergentes entre confirmação, persistência e impressão.
- **Severidade**: **P0**.
- **Automatizado**: E2E Strikes `CS_AVAL_001..007`, Smoke `MIG_008`, Boundary Dates `DATE_BND_008/009`.
- **Manual**: M-09.
- **Evidência**: AUDIT_LOG `Avaliacao Registrada` + linha do strike em `STRIKES_TOTAL`/`STRIKES_PUNICAO` (MICRO48).
- **Lacunas**: nenhuma.

### REGRA RN-25 — Nota mínima

- **Descrição normativa**: A nota mínima configurada em `CONFIG` (default `NOTA_MINIMA=5.0`) governa a fronteira entre avaliação positiva e negativa.
- **DEVE**: persistir parâmetro; aceitar valor configurado; aplicar comparação consistente.
- **NÃO PODE**: aceitar valor inválido (negativo, vazio); reduzir parâmetro sem aviso.
- **Severidade**: **P1**.
- **Automatizado**: Smoke `MIG_008` (CONFIG inválida) + `CFG_001..002`.
- **Manual**: ver CM-16 (Configurações Iniciais).
- **Evidência**: `CONFIG` + AUDIT_LOG `CONFIG_INVALIDA`.
- **Lacunas**: valores extremos (`0`, `10`) são "lacuna a validar" exploratoriamente.

### REGRA RN-26 — Justificativa de divergência

- **Descrição normativa**: Avaliação que altera campos pré-preenchidos (empenho, data, quantidade, valor) deve exigir justificativa.
- **DEVE**: exigir justificativa obrigatória; registrar em AUDIT_LOG.
- **NÃO PODE**: aceitar alteração sem justificativa.
- **Severidade**: **P1**.
- **Automatizado**: V2 Canônica (parcial).
- **Manual**: M-09 (cenário com divergência).
- **Evidência**: print da mensagem solicitando justificativa.
- **Lacunas**: cobertura combinatória de campos divergentes é "lacuna a validar".

### REGRA RN-27 — Strike

- **Descrição normativa**: Cada avaliação com `MEDIA < NOTA_MINIMA` registra 1 strike na empresa.
- **DEVE**: contar strikes em `STRIKES_TOTAL` (bruto histórico) e `STRIKES_PUNICAO` (janela pós-reativação); aplicar conforme RN-28.
- **NÃO PODE**: zerar strikes sem evento explícito de reativação; contar strikes em duplicata.
- **Severidade**: **P0**.
- **Automatizado**: E2E Strikes `CS_AVAL_001..007`, `CS_REATIV_AUDIT_DUAL_COUNTER` (MICRO48).
- **Manual**: M-09, M-11.
- **Evidência**: AUDIT_LOG com `STRIKES_TOTAL=N` e `STRIKES_PUNICAO=M`.
- **Lacunas**: nenhuma.

### REGRA RN-28 — Suspensão por strikes

- **Descrição normativa**: Quando `STRIKES_PUNICAO >= MAX_STRIKES`, a empresa é suspensa por `DIAS_SUSPENSAO_STRIKE` dias.
- **DEVE**: aplicar suspensão atômica; gravar `DT_FIM_SUSP`; registrar AUDIT_LOG `EVT_SUSPENSAO`.
- **NÃO PODE**: suspender com valores de CONFIG inválidos; deixar empresa "suspensa-apta" inconsistente.
- **Severidade**: **P0**.
- **Automatizado**: E2E Strikes, Smoke `MIG_008`, Boundary Dates.
- **Manual**: M-10.
- **Evidência**: `EMPRESAS.STATUS=SUSPENSA_GLOBAL`, `DT_FIM_SUSP`.
- **Lacunas**: nenhuma.

### REGRA RN-29 — Contagem total de strikes

- **Descrição normativa**: O contador `STRIKES_TOTAL` é histórico bruto e nunca é zerado por reativação.
- **DEVE**: preservar histórico após reativação; expor em AUDIT_LOG.
- **NÃO PODE**: zerar histórico em reativação automática ou manual.
- **Severidade**: **P0**.
- **Automatizado**: `CS_REATIV_HISTORICO_TOTAL_PRESERVADO`, `CS_REATIV_AUDIT_DUAL_COUNTER`.
- **Manual**: M-11.
- **Evidência**: AUDIT_LOG mostrando histórico preservado.
- **Lacunas**: nenhuma.

### REGRA RN-30 — Contagem punitiva pós-reativação

- **Descrição normativa**: O contador `STRIKES_PUNICAO` considera apenas avaliações com `DT_FECHAMENTO > DT_ULT_REATIV`.
- **DEVE**: filtrar avaliações na janela pós-reativação; usar para decisão de suspensão.
- **NÃO PODE**: punir empresa por strikes anteriores à reativação.
- **Severidade**: **P0**.
- **Automatizado**: `CS_REATIV_JANELA_EXCLUI_HISTORICO`, `CS_E2E_REATIV2STRIKES`, `CS_REATIV_BORDA_*`.
- **Manual**: M-11 (estendido).
- **Evidência**: AUDIT_LOG dual counter.
- **Lacunas**: nenhuma; bordas temporais cobertas por Boundary Dates.

### REGRA RN-31 — Reativação manual

- **Descrição normativa**: A reativação manual via formulário deve mover a empresa de `EMPRESAS_INATIVAS` para `EMPRESAS` e gravar `DT_ULT_REATIV`.
- **DEVE**: gravar `DT_ULT_REATIV` (coluna U); zerar recusas; limpar `DT_FIM_SUSP`; registrar `EVT_REATIVACAO`.
- **NÃO PODE**: reativar sem `DT_ULT_REATIV`; reativar empresa já ativa silenciosamente.
- **Severidade**: **P0**.
- **Automatizado**: E2E Strikes `CS_REATIV_DT_ULT_REATIV_GRAVADA`, `CS_23`.
- **Manual**: M-11.
- **Evidência**: `EMPRESAS.DT_ULT_REATIV` preenchida + AUDIT_LOG.
- **Lacunas**: nenhuma.

### REGRA RN-32 — Reativação automática

- **Descrição normativa**: Suspensão por prazo vencido deve disparar reativação automática quando a empresa é selecionada pela próxima vez.
- **DEVE**: reabilitar empresa cujo `DT_FIM_SUSP <= hoje`; registrar evento; preencher `DT_ULT_REATIV`.
- **NÃO PODE**: manter empresa suspensa após prazo; pular reativação silenciosa.
- **Severidade**: **P0**.
- **Automatizado**: `CS_E2E_E_VOLTA_*`, `CS_E2E_F_REATIVA1`, `CS_11/13/16`.
- **Manual**: ver cenário CM-22.
- **Evidência**: AUDIT_LOG + `EMPRESAS`.
- **Lacunas**: simulação manual de prazo vencido depende de manipular data ou cenário canônico — "lacuna a validar" via testador externo; aceitar como **coberto automático**.

### REGRA RN-33 — Preservação de posição na fila

- **Descrição normativa**: Reativação e suspensão não devem corromper a ordem de fila.
- **DEVE**: preservar posição quando empresa é pulada por impedimento; reentrar na ordem após reativação.
- **NÃO PODE**: reordenar fila por reativação.
- **Severidade**: **P1**.
- **Automatizado**: E2E Strikes (rotações `A→B→C`).
- **Manual**: M-07/M-11.
- **Evidência**: sequência da aba `PRE_OS`.
- **Lacunas**: nenhuma.

### REGRA RN-34 — Bloqueio total sem travamento

- **Descrição normativa**: Quando nenhuma empresa está apta, o sistema deve responder com `SEM_CREDENCIADOS_APTOS` sem travar.
- **DEVE**: retornar motivo legível; não fechar Excel; não estourar VBA.
- **NÃO PODE**: deixar a planilha congelada; exibir erro fatal.
- **Severidade**: **P0**.
- **Automatizado**: V2 Canônica, E2E Strikes.
- **Manual**: M-10 (forçar todas inaptas).
- **Evidência**: print da mensagem.
- **Lacunas**: nenhuma.

### REGRA RN-35 — Integridade de referências

- **Descrição normativa**: A base não pode acumular referências órfãs nem dados sem chave em `CAD_OS`.
- **DEVE**: detectar órfãs reais; permitir limpeza auditável de resíduos legados sem chave.
- **NÃO PODE**: misturar resíduos legados (sem `OS_ID`) com órfãs reais.
- **Severidade**: **P1**.
- **Automatizado**: IntegridadeBase `CS_INT_01..05` (4/0 no Sexteto).
- **Manual**: ver CM-30 (revisão do `RPT_INT_*`).
- **Evidência**: relatório de integridade.
- **Lacunas**: histórico anterior à V204 é débito controlado (DT-MIGRACAO).

### REGRA RN-36 — Dados órfãos

- **Descrição normativa**: Resíduos sem chave em `CAD_OS` devem ser tratáveis como limpeza auditável via comando dedicado (`RepoOS_MigrarRefOrfaLegado`).
- **DEVE**: separar resíduos sem `OS_ID` de OS reais com `EMP_ID/ATIV_ID` inválidos; permitir limpeza explícita.
- **NÃO PODE**: deletar OS reais com falha referencial em modo silencioso.
- **Severidade**: **P1**.
- **Automatizado**: IntegridadeBase.
- **Manual**: revisão do relatório `INT-CAD-OS-REF-ORFA`.
- **Evidência**: relatório `RPT_INT_CAD_OS_REF_ORFA`.
- **Lacunas**: comando `RepoOS_MigrarRefOrfaLegado` é operação do mantenedor — fora do escopo do testador externo.

### REGRA RN-37 — Auditoria obrigatória em AUDIT_LOG

- **Descrição normativa**: Toda ação com efeito de estado deve registrar evento auditável em `AUDIT_LOG`.
- **DEVE**: registrar família, entidade, ID, descrição legível, usuário e timestamp.
- **NÃO PODE**: omitir evento; gravar evento sem descrição.
- **Severidade**: **P0**.
- **Automatizado**: V2 Canônica `CS_21` (completude mínima das famílias).
- **Manual**: M-09, M-11 (verificação amostral).
- **Evidência**: `AUDIT_LOG` filtrado por família.
- **Lacunas**: cobertura granular por campo é "lacuna a validar" exploratória.

### REGRA RN-38 — Limpar Base

- **Descrição normativa**: Limpar Base deve remover dados operacionais e preservar a base estrutural.
- **DEVE**: limpar `EMPRESAS`, `EMPRESAS_INATIVAS`, `ENTIDADE`, `ENTIDADE_INATIVOS`, `CREDENCIADOS`, `CAD_SERV`, `PRE_OS`, `CAD_OS`, `AUDIT_LOG`, `RELATORIO`; preservar `ATIVIDADES` e `CONFIG`; gerar `RPT_LIMPEZA_TOTAL`.
- **NÃO PODE**: zerar CNAE/`ATIVIDADES`; perder `CONFIG`; deixar `CAD_SERV` com lixo.
- **Severidade**: **P0**.
- **Automatizado**: Smoke `MIG_009`.
- **Manual**: M-12, M-13, M-14.
- **Evidência**: `RPT_LIMPEZA_TOTAL`.
- **Lacunas**: nenhuma.

### REGRA RN-39 — Preservação de CNAE

- **Descrição normativa**: Limpar Base **não pode** tocar em `ATIVIDADES`.
- **DEVE**: deixar a aba intacta antes/depois da operação.
- **NÃO PODE**: limpar ou reescrever `ATIVIDADES`.
- **Severidade**: **P0**.
- **Automatizado**: Smoke `MIG_009`.
- **Manual**: M-12.
- **Evidência**: print antes/depois.
- **Lacunas**: nenhuma.

### REGRA RN-40 — Limpeza de CAD_SERV

- **Descrição normativa**: Limpar Base deve zerar `CAD_SERV` preservando o cabeçalho canônico para permitir novo cadastro de serviços (reuso municipal).
- **DEVE**: zerar dados; manter cabeçalho; permitir abrir Cadastro de Serviço sem erro.
- **NÃO PODE**: deixar resíduos; corromper cabeçalho; quebrar a tela de Cadastro de Serviço.
- **Severidade**: **P0**.
- **Automatizado**: Smoke `MIG_009`.
- **Manual**: M-13, M-14.
- **Evidência**: print da aba `CAD_SERV` + tela de Cadastro de Serviço.
- **Lacunas**: nenhuma.

### REGRA RN-41 — Preservação de CONFIG

- **Descrição normativa**: Parâmetros operacionais (NOTA_MINIMA, MAX_STRIKES, DIAS_SUSPENSAO_STRIKE, MAX_RECUSAS, DIAS_DECISAO, PERIODO_SUSPENSAO_MESES, municipio, GESTOR_NOME) devem ser preservados em Limpar Base.
- **DEVE**: deixar `CONFIG` intacta.
- **NÃO PODE**: zerar `CONFIG`.
- **Severidade**: **P0**.
- **Automatizado**: V2 Canônica + Smoke.
- **Manual**: M-12.
- **Evidência**: print `CONFIG` antes/depois.
- **Lacunas**: nenhuma.

### REGRA RN-42 — Reutilização da planilha por outro município

- **Descrição normativa**: Após Limpar Base, a planilha deve aceitar nova configuração de município, novos cadastros e novos serviços sem lixo acumulado.
- **DEVE**: aceitar reuso completo; manter estabilidade.
- **NÃO PODE**: travar Cadastro de Serviço por instância oculta; arrastar dados antigos.
- **Severidade**: **P0**.
- **Automatizado**: Smoke `MIG_009`.
- **Manual**: M-13, M-14.
- **Evidência**: novo município cadastrado em `CONFIG` (manual) + serviço novo criado.
- **Lacunas**: troca de município via `Configuracao_Inicial` é "lacuna a validar" exploratória (testador externo confirma o caminho).

### REGRA RN-43 — Segurança de ações destrutivas

- **Descrição normativa**: Ações destrutivas (Limpar Base) exigem senha mascarada via formulário dedicado (`Limpar_Base.frm` com guarda).
- **DEVE**: pedir senha em campo mascarado; registrar tentativa autorizada/negada em AUDIT_LOG.
- **NÃO PODE**: aceitar token literal exposto no form; gravar senha em claro.
- **Severidade**: **P0**.
- **Automatizado**: `UI_ADV_012_LIMPAR_BASE_SEM_SENHA_CLARA` (Adversarial UI).
- **Manual**: M-12 (observar campo mascarado).
- **Evidência**: print do formulário + AUDIT_LOG `OPERACAO=LIMPAR_BASE`.
- **Lacunas**: nenhuma.

### REGRA RN-44 — Reentrada de botões

- **Descrição normativa**: Cliques repetidos em fluxos mutadores não podem corromper estado.
- **DEVE**: aplicar guarda de reentrada; manter idempotência.
- **NÃO PODE**: duplicar Pré-OS, OS ou cadastros por duplo clique.
- **Severidade**: **P0**.
- **Automatizado**: Adversarial UI `UI_ADV_001` (12 asserts ao todo).
- **Manual**: ver cenário CM-26.
- **Evidência**: AUDIT_LOG sem duplicidade.
- **Lacunas**: cobertura visual real depende de teste exploratório de UI.

### REGRA RN-45 — Transação interrompida

- **Descrição normativa**: Fluxo transacional interrompido deve rejeitar estado parcial e preservar consistência.
- **DEVE**: aplicar commit ou rollback atômico; ser idempotente em rollback duplo; preservar transação externa quando aninhada.
- **NÃO PODE**: deixar estado parcial; sobrescrever transação externa.
- **Severidade**: **P0**.
- **Automatizado**: Transaction Interrupt `TX_INT_001..006`.
- **Manual**: não exigido como fluxo manual obrigatório; cobertura por automação.
- **Evidência**: CSV da suíte.
- **Lacunas**: interrupção física do Excel (kill -9) **não é coberta** automaticamente; "lacuna a validar" exploratória opcional.

### REGRA RN-46 — Bordas de data

- **Descrição normativa**: Datas em bordas operacionais (vazia, hoje, ontem, 31/02, ano bissexto válido/inválido, ano curto, data igual/diferente em avaliação) não devem quebrar cálculo nem causar erro fatal.
- **DEVE**: aplicar default controlado para data vazia; rejeitar `ontem` em OS; aceitar bissexto válido; rejeitar bissexto inválido; tratar avaliação com data equivalente.
- **NÃO PODE**: estourar VBA; aceitar ano impossível.
- **Severidade**: **P1**.
- **Automatizado**: Boundary Dates `DATE_BND_001..009` (9 asserts).
- **Manual**: não exigido como fluxo manual obrigatório.
- **Evidência**: CSV da suíte.
- **Lacunas**: comportamento por **locale/timezone** do Windows é "lacuna a validar" manualmente.

### REGRA RN-47 — Interface de testes sem VBE

- **Descrição normativa**: O testador deve poder validar a release apenas pela interface (botão **Sobre**, botão **Central de Testes**, formulários).
- **DEVE**: expor Sexteto Mínimo como `[1]` na Central V2; gerar evidência CSV pela própria UI; permitir ler `VALIDACAO_RELEASE`.
- **NÃO PODE**: exigir Janela Imediata; exigir comandos VBA; exigir Importador V3.
- **Severidade**: **P1** (impede homologação humana se violada).
- **Automatizado**: `UI_ADV_011_SEXTETO_GATE_EXPOSTO`.
- **Manual**: este protocolo inteiro.
- **Evidência**: prints + CSV.
- **Lacunas**: nenhuma para o caminho oficial; melhorias de mensageria deferidas para V205.

---

## 5. MAPA DOS TESTES AUTOMATIZADOS

A bateria automatizada da V12.0.0204 está consolidada no **Sexteto Mínimo** (`CT_ValidarRelease_SextetoMinimo`), exposto como `[1]` na Central V2.

Cada bateria abaixo segue formato padronizado. Os totais correspondem à sintaxe canônica aprovada:

`V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`

### TESTE AUTOMATIZADO TA-01 — V1 Bateria Oficial

- **Nome técnico**: `BO_RodarBateriaOficial` (módulo `Teste_Bateria_Oficial`)
- **Nome exibido ao humano**: "V1 — Bateria Oficial Rápida"
- **Onde é executado na interface**: Central de Testes → V2 → `[1] Sexteto Mínimo` (rodada como parte do gate); ou Central V2 → `Bateria V1` (rodada isolada).
- **Objetivo**: regressão histórica ampla, com 171 asserts cobrindo blocos 0 a 5 (preparação, cenário literal, expansão, regressão técnica, combinatória, exportação/reset).
- **O que valida**: cadastros, baseline determinístico, configurações canônicas, rodízio em cenário literal, expansão para múltiplas empresas, regressão de bugs históricos da linha V12, fluxos combinatórios e exportação CSV.
- **O que NÃO valida**: cenários adversariais novos (Onda 23), bordas de data, integridade pós-migração legada.
- **Quantidade esperada de OK**: 171.
- **Quantidade esperada de falhas**: 0.
- **Resultado esperado**: `V1=171/0`.
- **Regras de negócio cobertas**: RN-01 a RN-37 (cobertura ampla mas não exclusiva).
- **Evidência gerada**: aba `RESULTADO_QA`; CSV `TesteOficial_Falhas_*.csv` apenas se houver falha.
- **Como interpretar aprovação**: 171 asserts `OK`, nenhum `FALHA`, e `RESUMO` da aba `RESULTADO_QA` consistente.
- **Como interpretar reprovação**: qualquer `FALHA > 0` é bloqueante. Inspecionar a linha em `RESULTADO_QA` e o CSV gerado.
- **Quando repetir**: sempre no gate completo; após qualquer correção em código VBA.
- **Complemento manual obrigatório**: M-02 a M-09 do roteiro manual.

### TESTE AUTOMATIZADO TA-02 — V2 Smoke

- **Nome técnico**: `TV2_RunSmoke` (módulo `Teste_V2_Roteiros`)
- **Nome exibido ao humano**: "V2 — Smoke Rápido"
- **Onde é executado na interface**: Sexteto Mínimo; ou Central V2 → opção dedicada.
- **Objetivo**: sanidade curta dos fluxos críticos, com 34 asserts cobrindo `SMK_001..007`, `EXP_001`, `MIG_001..009`, `MUT_001`, `ATM_001/002`.
- **O que valida**: emissão de Pré-OS, aceite, recusa, expiração, mutação isolada, atomicidade transacional, configuração de strikes (`MIG_008`), Limpar Base com CNAE preservado e CAD_SERV zerado (`MIG_009`).
- **O que NÃO valida**: cenários canônicos longos, E2E de strikes, integridade exaustiva.
- **Quantidade esperada de OK**: 34.
- **Quantidade esperada de falhas**: 0 (`MANUAL` esperado: 4 — assistidos não obrigatórios para o gate).
- **Resultado esperado**: `V2_Smoke=34/0`.
- **Regras de negócio cobertas**: RN-17, RN-19, RN-20, RN-21, RN-25, RN-38, RN-39, RN-40, RN-45.
- **Evidência gerada**: aba `TESTE_V2`; CSV `TesteV2_SMOKE_Falhas_*.csv` se houver falha.
- **Como interpretar aprovação**: 34 OK, 0 FALHA. `MANUAL=4` é aceitável e não bloqueia o gate.
- **Como interpretar reprovação**: qualquer FALHA bloqueia.
- **Quando repetir**: sempre no gate; após mudança em CONFIG, Limpar Base ou caminho de Pré-OS.
- **Complemento manual obrigatório**: M-04 a M-09, M-12 a M-14.

### TESTE AUTOMATIZADO TA-03 — V2 Canônica

- **Nome técnico**: `TV2_RunCanonica` (composição de `CS_00..CS_24`)
- **Nome exibido ao humano**: "V2 — Canônica"
- **Onde é executado na interface**: Sexteto Mínimo; ou Central V2.
- **Objetivo**: validar fluxo canônico determinístico em 24 cenários `CS_*` cobrindo cadastros, rodízio, recusa, aceite, suspensão manual, reativação automática, transições inválidas, completude de AUDIT_LOG, ida/volta de empresa e entidade.
- **O que valida**: comportamento esperado em condições normais; RN-01 a RN-24, RN-31, RN-32, RN-33, RN-37.
- **O que NÃO valida**: estresse, bordas extremas, UI mutadora.
- **Quantidade esperada de OK**: 24.
- **Quantidade esperada de falhas**: 0.
- **Resultado esperado**: `V2_Canonica=24/0`.
- **Evidência gerada**: aba `TESTE_V2`.
- **Como interpretar aprovação**: 24/0.
- **Como interpretar reprovação**: qualquer FALHA bloqueia.
- **Quando repetir**: sempre no gate.
- **Complemento manual obrigatório**: M-02 a M-11.

### TESTE AUTOMATIZADO TA-04 — E2E Strikes

- **Nome técnico**: `TV2_RunRodizioStrikesEndToEnd` (76 asserts)
- **Nome exibido ao humano**: "E2E — Rodízio com Strikes"
- **Onde é executado na interface**: Sexteto Mínimo; ou Central V2 → `Strikes na avaliação`.
- **Objetivo**: ciclo end-to-end de rodízio + avaliação + strikes + suspensão + reativação, incluindo bordas temporais e dual counter.
- **O que valida**: RN-11 a RN-14, RN-19 (recusa), RN-22 a RN-32 (avaliação, strike, suspensão, reativação), bordas temporais (`CS_REATIV_BORDA_*`), preservação de histórico (`CS_REATIV_HISTORICO_TOTAL_PRESERVADO`), janela punitiva (`CS_REATIV_JANELA_EXCLUI_HISTORICO`), dual counter (`CS_REATIV_AUDIT_DUAL_COUNTER`), legado vazio (`CS_REATIV_LEGADO_VAZIO`), rotações com 5 empresas (`CS_E2E_5EMPS`).
- **O que NÃO valida**: integridade da base pós-migração; UI mutadora.
- **Quantidade esperada de OK**: 76.
- **Quantidade esperada de falhas**: 0.
- **Resultado esperado**: `E2E_Strikes=76/0`.
- **Evidência gerada**: aba `TESTE_V2`.
- **Como interpretar aprovação**: 76/0.
- **Como interpretar reprovação**: bloqueante.
- **Quando repetir**: sempre no gate.
- **Complemento manual obrigatório**: M-09, M-10, M-11.

### TESTE AUTOMATIZADO TA-05 — IntegridadeBase

- **Nome técnico**: `TV2_RunIntegridadeBase`
- **Nome exibido ao humano**: "Integridade da Base"
- **Onde é executado na interface**: Sexteto Mínimo.
- **Objetivo**: auditoria passiva da base, detectando órfãs reais, resíduos legados e datas inválidas.
- **O que valida**: `CS_INT_01..05` — RN-12, RN-35, RN-36.
- **O que NÃO valida**: comportamento dinâmico (rodízio, avaliação).
- **Quantidade esperada de OK**: 4 (read-only; o quinto é informativo).
- **Quantidade esperada de falhas**: 0.
- **Resultado esperado**: `IntegridadeBase=4/0`.
- **Evidência gerada**: aba `TESTE_V2` + relatórios `INT-CAD-OS-REF-ORFA`.
- **Como interpretar aprovação**: 4/0.
- **Como interpretar reprovação**: investigar relatório de integridade.
- **Quando repetir**: sempre no gate; após Limpar Base; após reabertura de workbook antigo.
- **Complemento manual obrigatório**: revisão visual do relatório `RPT_INT_*` (cenário CM-30).

### TESTE AUTOMATIZADO TA-06 — Adversarial UI (Onda 23)

- **Nome técnico**: `TV2_RunAdversarial_UI`
- **Nome exibido ao humano**: "Adversarial — UI"
- **Onde é executado na interface**: Sexteto Mínimo.
- **Objetivo**: validar guardas de reentrada, ações destrutivas com confirmação e gate exposto na Central.
- **O que valida**: `UI_ADV_001..012` — RN-13, RN-43, RN-44, RN-47.
- **O que NÃO valida**: estética visual ou ergonomia.
- **Quantidade esperada de OK**: 12.
- **Quantidade esperada de falhas**: 0.
- **Resultado esperado**: `ADVERSARIAL_UI=12/0/0`.
- **Evidência gerada**: aba `TESTE_V2`.
- **Como interpretar aprovação**: 12/0.
- **Como interpretar reprovação**: bloqueante.
- **Quando repetir**: sempre no gate.
- **Complemento manual obrigatório**: cenários CM-26 (reentrada) e M-12 (senha mascarada).

### TESTE AUTOMATIZADO TA-07 — Transaction Interrupt (Onda 23)

- **Nome técnico**: `TV2_RunTransaction_Interrupt`
- **Nome exibido ao humano**: "Adversarial — Transação Interrompida"
- **Onde é executado na interface**: Sexteto Mínimo.
- **Objetivo**: cobertura de commit/rollback/aninhamento de `Svc_Transacao`.
- **O que valida**: `TX_INT_001..006` — RN-45.
- **O que NÃO valida**: interrupção física do Excel.
- **Quantidade esperada de OK**: 6.
- **Quantidade esperada de falhas**: 0.
- **Resultado esperado**: `TRANSACAO_INTERRUPT=6/0/0`.
- **Evidência gerada**: aba `TESTE_V2`.
- **Como interpretar aprovação**: 6/0.
- **Como interpretar reprovação**: bloqueante.
- **Quando repetir**: sempre no gate.
- **Complemento manual obrigatório**: não exigido; suíte automatizada.

### TESTE AUTOMATIZADO TA-08 — Boundary Dates (Onda 23)

- **Nome técnico**: `TV2_RunBoundary_Dates`
- **Nome exibido ao humano**: "Adversarial — Bordas de Data"
- **Onde é executado na interface**: Sexteto Mínimo.
- **Objetivo**: parser de data de OS e normalização de data na avaliação em bordas críticas.
- **O que valida**: `DATE_BND_001..009` — RN-46.
- **O que NÃO valida**: timezone/locale exótico do Windows.
- **Quantidade esperada de OK**: 9.
- **Quantidade esperada de falhas**: 0.
- **Resultado esperado**: `BOUNDARY_DATES=9/0/0`.
- **Evidência gerada**: aba `TESTE_V2`.
- **Como interpretar aprovação**: 9/0.
- **Como interpretar reprovação**: bloqueante.
- **Quando repetir**: sempre no gate.
- **Complemento manual obrigatório**: lacuna a validar exploratoriamente (locale).

### TESTE AUTOMATIZADO TA-09 — Onda23Adv (consolidado)

- **Nome técnico**: bloco agregado Onda 23 = `ADVERSARIAL_UI + TRANSACAO_INTERRUPT + BOUNDARY_DATES`
- **Nome exibido ao humano**: "Onda 23 — Bloco Adversarial"
- **Onde é executado na interface**: Sexteto Mínimo.
- **Objetivo**: agregar os três testes adversariais como sexta dimensão do gate.
- **O que valida**: união de RN-13, RN-43, RN-44, RN-45, RN-46, RN-47.
- **Quantidade esperada de OK**: 27 (12 + 6 + 9).
- **Quantidade esperada de falhas**: 0.
- **Resultado esperado**: `Onda23Adv=27/0`.
- **Evidência**: agregado pelo Sexteto.
- **Aprovação**: 27/0.
- **Reprovação**: qualquer falha bloqueia.
- **Quando repetir**: sempre.
- **Complemento manual**: cenários CM-26 a CM-29.

### TESTE AUTOMATIZADO TA-10 — Sexteto Mínimo (gate consolidado)

- **Nome técnico**: `CT_ValidarRelease_SextetoMinimo`
- **Nome exibido ao humano**: "Sexteto Mínimo" *(rótulo histórico; renomeação para nomenclatura profissional é débito V205)*
- **Onde é executado na interface**: Central de Testes → V2 → `[1] Sexteto Mínimo`.
- **Objetivo**: gate único de release V204; agrega V1, V2 Smoke, V2 Canônica, E2E Strikes, IntegridadeBase e Onda23Adv.
- **O que valida**: união completa dos testes acima; RN-01 a RN-47 (cobertura agregada).
- **Quantidade esperada de OK por componente**: `171/34/24/76/4/27`.
- **Quantidade esperada de falhas**: 0 em todos.
- **Resultado esperado**: `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.
- **Regras cobertas**: a cobertura é a união. Veja Seção 8.
- **Evidência gerada**: aba `VALIDACAO_RELEASE`; CSV `ValidacaoReleaseSexteto_V12_0_0204_VR_<timestamp>.csv` em `auditoria/evidencias/V12.0.0204/`.
- **Como interpretar aprovação**: `RESULTADO_GERAL=APROVADO` com sintaxe igual à canônica.
- **Como interpretar reprovação**: comparar a sintaxe campo a campo; qualquer divergência é bloqueante.
- **Quando repetir**: antes de qualquer decisão de homologação humana e após qualquer correção.
- **Complemento manual obrigatório**: TODO o roteiro manual (Seção 7) deste protocolo.

---

## 6. VALIDAÇÃO DA QUALIDADE DOS PRÓPRIOS TESTES

Antes de confiar no resultado do Sexteto, o testador deve verificar se o ambiente de teste é íntegro e se a execução foi válida. Um Sexteto verde **não substitui** essa validação.

### 6.1 Checklist de qualidade do gate automático

| Verificação | Como validar | Aprovado? | Evidência | Observação |
|---|---|---|---|---|
| O build exibido bate com o build esperado? | Clicar em **Sobre** e ler `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |  |  |  |
| O resultado geral é APROVADO? | Aba `VALIDACAO_RELEASE` → linha `RESULTADO_GERAL` |  |  |  |
| A sintaxe bate com a esperada? | Comparar string com `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` |  |  |  |
| O CSV foi gerado? | Verificar pasta `auditoria/evidencias/V12.0.0204/` |  |  |  |
| A execução não fechou o Excel? | Observação direta durante a rodada |  |  |  |
| Nenhum erro VBA apareceu? | Observação direta (sem MsgBox `Erro fatal`) |  |  |  |
| O teste foi iniciado pela interface? | Sim, via **Central de Testes** → `[2] Central V2` → `[1] Sexteto` (e não pela Janela Imediata) |  |  |  |
| O número de OK por componente bate com o esperado? | `V1=171, Smoke=34, Canonica=24, E2E=76, Integridade=4, Onda23Adv=27` |  |  |  |
| Houve `MANUAL` adicional no Smoke além de 4? | Esperado: `MANUAL=4` (informativo) |  |  |  |
| A aba `VALIDACAO_RELEASE` ficou íntegra? | Conferir as 14 linhas do bloco copiável |  |  |  |
| O timestamp `VALIDACAO_ID` ficou registrado? | Conferir nome do CSV gerado |  |  |  |
| O texto `RESULTADO_GERAL=APROVADO` está visível? | Procurar na aba `VALIDACAO_RELEASE` |  |  |  |

### 6.2 Sinais de teste automático suspeito

- Sexteto rodou em menos de 3 minutos (muito rápido para 234 asserts) → **suspeito**, registrar como anomalia P2 e repetir.
- Sexteto exibiu mensagem de aviso sobre falha mas terminou como APROVADO → **suspeito**, abrir aba `VALIDACAO_RELEASE` e ler linha por linha.
- CSV não gerado → **suspeito**, repetir com permissão de escrita confirmada.
- Excel travou ou foi forçado a encerrar → **inválido**, o gate deve ser refeito do zero.

### 6.3 Reforço final

Teste automático verde **não significa** que a versão está apta para produção. Significa apenas que o caminho automatizado coberto está aprovado. A decisão de produção depende da homologação humana descrita na Seção 7 e do checklist de liberação da Seção 9.

---

## 7. ROTEIRO DE TESTES MANUAIS EXAUSTIVO

Esta seção descreve, em ordem operacional, todos os cenários manuais que o testador deve executar após o Sexteto verde. Cada cenário traz pré-condições, passos, resultado esperado e tabela preenchível.

Os identificadores **CM-XX** são canônicos deste protocolo e referenciam, quando possível, os identificadores **M-XX** do roteiro técnico oficial (`docs/reference/testes/07_ROTEIRO_TESTE_MANUAL_V204.md`).

### Critérios de severidade (referência usada em todos os cenários)

| Severidade | Critério |
|---|---|
| P0 | Perda/corrupção de dados, falha de compilação, fechamento inesperado do Excel, regra de negócio crítica violada |
| P1 | Regra de negócio errada, rodízio incorreto, Limpar Base descumpre contrato, erro VBA em fluxo principal, evidência principal ausente |
| P2 | Mensagem confusa, evidência incompleta, comportamento correto mas pouco claro, navegação dificultada |
| P3 | Texto, alinhamento visual, ergonomia menor |

### CM-01 — Abrir o arquivo

- **Regra de negócio validada**: RN-47.
- **Obrigatoriedade**: obrigatório.
- **Objetivo**: confirmar que a planilha abre num ambiente Windows preparado.
- **Pré-condições**: `.xlsm` recebido e salvo em pasta local.
- **Dados de teste**: nenhum.
- **Passos pela interface**:
  1. Abrir o `.xlsm` clicando duas vezes no Windows Explorer.
  2. Observar a tela inicial do Excel Desktop.
- **Resultado esperado visual**: barra superior do Excel exibindo o nome do arquivo; nenhuma janela de erro.
- **Resultado esperado nas abas**: a aba inicial do sistema aparece, com botões padrão.
- **Resultado esperado no AUDIT_LOG**: nenhum.
- **Critério de aprovação**: a planilha abre sem erro.
- **Critério de reprovação**: erro de macro, mensagem corrompida, Excel fecha sozinho (P0).
- **Evidências a coletar**: print da tela inicial.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado: APROVADO / REPROVADO / BLOQUEADO |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug, se houver |  |

### CM-02 — Liberar macros

- **Regra**: RN-47.
- **Obrigatoriedade**: obrigatório.
- **Objetivo**: garantir que macros executam.
- **Pré-condições**: arquivo desbloqueado no Windows (Seção 3).
- **Passos**:
  1. Se a barra **Modo de Exibição Protegido** aparecer, clicar em **Habilitar Edição**.
  2. Se a barra **Aviso de Segurança** aparecer, clicar em **Habilitar Conteúdo**.
- **Resultado esperado visual**: a tela inicial do sistema mostra todos os botões clicáveis.
- **Resultado esperado nas abas**: nenhuma aba protegida com erro.
- **AUDIT_LOG**: nenhum.
- **Aprovação**: botões respondem.
- **Reprovação**: macros bloqueadas (P0 — bloqueia teste).

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-03 — Confirmar Sobre

- **Regra**: RN-47.
- **Obrigatoriedade**: obrigatório.
- **Objetivo**: confirmar identidade da release.
- **Pré-condições**: macros liberadas.
- **Passos**:
  1. Clicar em **Sobre** na tela inicial.
  2. Ler o conteúdo.
  3. Conferir as três linhas críticas:
     - `Release oficial: V12.0.0204`;
     - `Status oficial: VALIDADO`;
     - `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`.
  4. Fechar em **OK**.
- **Resultado visual**: janela `Sobre` com triplet correto.
- **AUDIT_LOG**: nenhum.
- **Aprovação**: triplet correto.
- **Reprovação**: divergência em qualquer linha → **P0**, suspender homologação.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-04 — Rodar Sexteto Mínimo

- **Regra**: RN-47 + suporte a todas as demais.
- **Obrigatoriedade**: obrigatório.
- **Objetivo**: executar o gate automatizado e produzir evidência CSV.
- **Pré-condições**: macros liberadas; Sobre confirmado.
- **Passos**:
  1. Clicar em **Central de Testes**.
  2. Se aparecer **Modo Treinamento**, clicar em **Sim**.
  3. Se aparecer a janela **Central de Testes V12 / Transição**, escolher **[2] Central de Testes V2**.
  4. Na **Central V2**, escolher **[1] Sexteto Mínimo**.
  5. Aguardar a execução (aproximadamente 12 a 15 minutos).
- **Resultado visual**: barra de status atualizada; mensagem final com resultado.
- **Resultado nas abas**: `VALIDACAO_RELEASE` preenchida; CSV gerado em `auditoria/evidencias/V12.0.0204/`.
- **AUDIT_LOG**: eventos da execução podem aparecer dependendo do escopo.
- **Aprovação**: `RESULTADO_GERAL=APROVADO` e sintaxe = `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.
- **Reprovação**: qualquer divergência → **P0** ou **P1** dependendo da componente.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-05 — Validar resultado do Sexteto

- **Regra**: RN-47.
- **Obrigatoriedade**: obrigatório.
- **Objetivo**: confirmar resultado pela aba `VALIDACAO_RELEASE` e CSV.
- **Pré-condições**: CM-04 executado.
- **Passos**:
  1. Abrir a aba `VALIDACAO_RELEASE`.
  2. Ler as 14 linhas do bloco copiável.
  3. Conferir `RESULTADO_GERAL=APROVADO`.
  4. Conferir cada componente individual.
  5. Abrir a pasta `auditoria/evidencias/V12.0.0204/` e localizar o CSV gerado.
- **Resultado**: bloco íntegro; CSV salvo.
- **Aprovação**: sintaxe canônica + CSV salvo.
- **Reprovação**: divergência ou ausência de CSV → **P1**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-06 — Cadastrar entidade

- **Regra**: RN-02.
- **Obrigatoriedade**: obrigatório.
- **Objetivo**: validar cadastro de entidade.
- **Pré-condições**: Sexteto verde.
- **Dados de teste**: "Secretaria Municipal de Teste V204".
- **Passos**:
  1. Abrir o menu de cadastros.
  2. Selecionar **Cadastrar Entidade**.
  3. Preencher o nome.
  4. Confirmar.
  5. Conferir a aba `ENTIDADE`.
- **Resultado visual**: mensagem de sucesso.
- **Resultado nas abas**: linha nova em `ENTIDADE`.
- **AUDIT_LOG**: `EVT_CADASTRO_ENTIDADE`.
- **Aprovação**: entidade aparece sem erro.
- **Reprovação**: erro VBA → P0; não aparece → P1.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-07 — Tentar entidade duplicada

- **Regra**: RN-02.
- **Obrigatoriedade**: complementar.
- **Objetivo**: confirmar bloqueio de duplicidade.
- **Dados**: cadastrar de novo "Secretaria Municipal de Teste V204".
- **Passos**: repetir CM-06 com o mesmo nome.
- **Resultado**: o sistema deve avisar duplicidade (ou impedir).
- **Aprovação**: aviso/recusa.
- **Reprovação**: duplicidade silenciosa → **P1**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-08 — Cadastrar empresa

- **Regra**: RN-03.
- **Obrigatoriedade**: obrigatório.
- **Dados**: "Empresa Teste Alfa Ltda.", CNPJ `11.111.111/0001-11`.
- **Passos**:
  1. Abrir **Cadastrar Empresa**.
  2. Preencher razão social, CNPJ e atividade.
  3. Confirmar.
  4. Conferir `EMPRESAS`.
- **Resultado**: empresa cadastrada, status `ATIVA`.
- **AUDIT_LOG**: `EVT_CADASTRO_EMPRESA`.
- **Aprovação**: sucesso.
- **Reprovação**: erro VBA → P0; ausência → P1.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-09 — Tentar empresa duplicada

- **Regra**: RN-04.
- **Obrigatoriedade**: obrigatório.
- **Dados**: cadastrar de novo com mesmo CNPJ.
- **Passos**: repetir CM-08.
- **Resultado**: bloqueio explícito.
- **Aprovação**: bloqueio.
- **Reprovação**: aceita duplicidade → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-10 — Cadastrar serviço válido

- **Regra**: RN-07, RN-06.
- **Obrigatoriedade**: obrigatório.
- **Dados**: serviço "Manutenção predial V204" vinculado a uma atividade CNAE existente.
- **Passos**:
  1. Abrir **Cadastra e Altera Serviço**.
  2. Confirmar que a tela abre sem erro `O objeto é obrigatório` (proteção MICRO53-fix2).
  3. Preencher nome e atividade.
  4. Confirmar.
  5. Conferir `CAD_SERV`.
- **Resultado**: serviço aparece.
- **AUDIT_LOG**: cadastro registrado.
- **Aprovação**: sucesso.
- **Reprovação**: erro VBA → P0; ausência → P1.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-11 — Tentar serviço duplicado

- **Regra**: RN-08.
- **Obrigatoriedade**: complementar.
- **Dados**: mesmo nome de serviço para mesma atividade.
- **Passos**: repetir CM-10.
- **Resultado**: comportamento esperado (bloqueio ou aviso). **Lacuna a validar**: confirmar resposta real e registrar.
- **Aprovação**: comportamento consistente.
- **Reprovação**: erro VBA → P0.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-12 — Tentar serviço com atividade inválida

- **Regra**: RN-09.
- **Obrigatoriedade**: complementar.
- **Dados**: serviço apontando para atividade inexistente (CNAE fictício).
- **Passos**: tentar criar.
- **Resultado**: bloqueio.
- **Aprovação**: bloqueado.
- **Reprovação**: aceita órfão → **P1**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-13 — Credenciar empresa

- **Regra**: RN-10.
- **Obrigatoriedade**: obrigatório.
- **Dados**: vincular "Alfa" ao serviço "Manutenção predial V204".
- **Passos**:
  1. Abrir **Credenciar Empresa**.
  2. Selecionar empresa e serviço.
  3. Confirmar.
  4. Conferir `CREDENCIADOS`.
- **Resultado**: credenciamento ativo.
- **AUDIT_LOG**: `EVT_CADASTRO_CRED`.
- **Aprovação**: sucesso.
- **Reprovação**: ausência → P1.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-14 — Emitir primeira Pré-OS

- **Regra**: RN-11, RN-17.
- **Obrigatoriedade**: obrigatório.
- **Pré-condições**: entidade, empresa, serviço e credenciamento criados.
- **Passos**:
  1. Cadastrar segunda empresa "Beta" e terceira "Gama", credenciar todas no mesmo serviço.
  2. Abrir **Solicitar Pré-OS**.
  3. Selecionar entidade, atividade, serviço.
  4. Confirmar.
  5. Conferir aba `PRE_OS`.
- **Resultado**: sistema deve escolher a empresa apta da vez (provavelmente Alfa) e gravar Pré-OS com status `AGUARDANDO_ACEITE`.
- **AUDIT_LOG**: `EVT_SELECAO` + `EVT_PRE_OS_GERADA`.
- **Aprovação**: empresa escolhida é apta; ordem de fila respeitada.
- **Reprovação**: empresa errada → **P0**; sem indicação → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-15 — Aceitar Pré-OS

- **Regra**: RN-18, RN-21.
- **Obrigatoriedade**: obrigatório.
- **Pré-condições**: CM-14 concluído.
- **Passos**:
  1. Abrir a Pré-OS gerada.
  2. Aceitar.
  3. Conferir `CAD_OS` (OS criada, status `EM_EXECUCAO`).
  4. Conferir `PRE_OS.STATUS=CONVERTIDA_OS`.
- **AUDIT_LOG**: `EVT_OS_GERADA`.
- **Aprovação**: conversão rastreável.
- **Reprovação**: OS órfã → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-16 — Converter Pré-OS em OS

- **Regra**: RN-21.
- **Obrigatoriedade**: obrigatório.
- **Objetivo**: validar atomicidade da conversão (Onda 21/MICRO35 rollback).
- **Passos**: o aceite (CM-15) já realiza a conversão; verificar que não há `PRE_OS` em estado intermediário inconsistente.
- **Resultado**: nenhuma Pré-OS órfã; OS rastreável à origem.
- **Aprovação**: integridade.
- **Reprovação**: estado parcial → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-17 — Confirmar avanço da fila

- **Regra**: RN-11, RN-33.
- **Obrigatoriedade**: obrigatório.
- **Passos**:
  1. Concluir e avaliar OS de Alfa (CM-23 a seguir).
  2. Emitir nova Pré-OS para o mesmo serviço.
  3. Confirmar que a próxima empresa selecionada é Beta (e não Alfa novamente).
- **Resultado**: ordem `A → B → C → A`.
- **Aprovação**: ordem respeitada.
- **Reprovação**: ordem incorreta → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-18 — Emitir segunda Pré-OS

- **Regra**: RN-11.
- **Obrigatoriedade**: obrigatório.
- **Passos**: repetir CM-14 imediatamente após CM-17. Sistema deve escolher Beta.
- **Aprovação**: Beta selecionada.
- **Reprovação**: empresa errada → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-19 — Bloquear empresa com OS aberta

- **Regra**: RN-16.
- **Obrigatoriedade**: obrigatório.
- **Pré-condições**: Beta com OS aberta.
- **Passos**: tentar emitir nova Pré-OS no mesmo serviço sem concluir a OS atual. Confirmar que Beta é pulada e a próxima apta (Gama) é selecionada.
- **Aprovação**: Beta pulada.
- **Reprovação**: Beta selecionada → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-20 — Recusar Pré-OS

- **Regra**: RN-19.
- **Obrigatoriedade**: obrigatório.
- **Passos**:
  1. Emitir Pré-OS para Gama.
  2. Recusar (caminho da interface).
  3. Conferir `PRE_OS.STATUS=RECUSADA`.
  4. Emitir nova Pré-OS — deve escolher a próxima apta (rota canônica).
- **Aprovação**: recusa avança fila.
- **Reprovação**: fila parada → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-21 — Expirar Pré-OS

- **Regra**: RN-20.
- **Obrigatoriedade**: complementar (cobertura automatizada por `EXP_001`).
- **Lacuna a validar**: simulação manual de expiração requer manipular data ou aguardar prazo. Para o testador externo, **aceitar como coberto automático** e marcar como "lacuna manual".
- **Aprovação**: confirmar via aba `PRE_OS.STATUS=EXPIRADA` se o cenário canônico permitir.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado: APROVADO / N/A (lacuna manual) |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-22 — Bloquear empresa com Pré-OS pendente

- **Regra**: RN-15.
- **Obrigatoriedade**: obrigatório.
- **Passos**: com Beta com Pré-OS `AGUARDANDO_ACEITE`, tentar emitir nova Pré-OS no mesmo serviço → Beta deve ser pulada.
- **Aprovação**: bloqueio.
- **Reprovação**: nova indicação para Beta → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-23 — Concluir OS

- **Regra**: RN-23.
- **Obrigatoriedade**: obrigatório.
- **Passos**:
  1. Abrir OS de Alfa.
  2. Concluir.
  3. Conferir `CAD_OS.STATUS=CONCLUIDA` e `DT_FECHAMENTO`.
- **AUDIT_LOG**: `EVT_OS_CONCLUIDA`.
- **Aprovação**: status correto.
- **Reprovação**: erro VBA → P0.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-24 — Avaliar prestador com nota aprovada

- **Regra**: RN-24, RN-25, RN-37.
- **Obrigatoriedade**: obrigatório.
- **Passos**:
  1. Avaliar OS de Alfa com nota >= NOTA_MINIMA (default 5.0).
  2. Não fornecer justificativa de divergência.
  3. Conferir `AUDIT_LOG` linha `Avaliacao Registrada`.
- **Aprovação**: sem strike; sem suspensão.
- **Reprovação**: strike incorreto → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-25 — Avaliar prestador com nota baixa

- **Regra**: RN-24, RN-27.
- **Obrigatoriedade**: obrigatório.
- **Passos**:
  1. Para uma nova rodada com Beta, concluir OS e avaliar com média menor que NOTA_MINIMA (ex.: 3.0).
  2. Conferir AUDIT_LOG: `STRIKES_TOTAL` incrementou; `STRIKES_PUNICAO` incrementou.
- **Aprovação**: 1 strike registrado.
- **Reprovação**: silêncio → P0.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-26 — Validar strike 1

- **Regra**: RN-27.
- **Obrigatoriedade**: obrigatório.
- **Passos**: CM-25.
- **Aprovação**: `STRIKES_PUNICAO=1`.
- **Reprovação**: contagem errada → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-27 — Validar strike 2

- **Regra**: RN-27.
- **Obrigatoriedade**: obrigatório.
- **Passos**: nova rodada para Beta com nota baixa; avaliar; conferir `STRIKES_PUNICAO=2`.
- **Aprovação**: 2 strikes.
- **Reprovação**: P0.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-28 — Validar suspensão no strike 3

- **Regra**: RN-28.
- **Obrigatoriedade**: obrigatório.
- **Passos**: terceira rodada para Beta com nota baixa.
- **Resultado**: Beta passa a `STATUS=SUSPENSA_GLOBAL`, `DT_FIM_SUSP` preenchida com `hoje + DIAS_SUSPENSAO_STRIKE`.
- **Aprovação**: suspensão automática.
- **Reprovação**: P0.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-29 — Validar suspensão por configuração inválida

- **Regra**: RN-25, RN-28.
- **Obrigatoriedade**: complementar.
- **Passos**:
  1. Abrir **Configurações Iniciais**.
  2. Tentar gravar `MAX_STRIKES=0` ou `DIAS_SUSPENSAO_STRIKE=-1`.
  3. Confirmar bloqueio com mensagem clara (MICRO47).
  4. Conferir AUDIT_LOG `CONFIG_INVALIDA`.
- **Aprovação**: bloqueio + auditoria.
- **Reprovação**: aceita valor inválido → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-30 — Validar reativação manual

- **Regra**: RN-31.
- **Obrigatoriedade**: obrigatório.
- **Passos**:
  1. Abrir **Reativar Empresa**.
  2. Selecionar Beta.
  3. Confirmar.
  4. Conferir: Beta volta a `EMPRESAS` como `ATIVA`; `DT_ULT_REATIV` preenchida; `DT_FIM_SUSP` limpa; recusas zeradas; AUDIT_LOG `EVT_REATIVACAO`.
- **Aprovação**: estado correto.
- **Reprovação**: `DT_ULT_REATIV` vazia → **P0** (DT-17 reincidente).

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-31 — Validar reativação automática por prazo vencido

- **Regra**: RN-32.
- **Obrigatoriedade**: complementar (cobertura automatizada por `CS_E2E_E_VOLTA_*`).
- **Lacuna a validar**: simulação manual exige manipular data. Para o testador externo, **aceitar como coberto automático**.
- **Aprovação**: N/A ou confirmação visual se o cenário canônico permitir.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado: APROVADO / N/A (lacuna manual) |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-32 — Validar dual counter de avaliação

- **Regra**: RN-29, RN-30.
- **Obrigatoriedade**: obrigatório (após CM-30).
- **Passos**:
  1. Para Beta reativada, conferir AUDIT_LOG: nas avaliações pós-reativação, `STRIKES_PUNICAO` deve estar reiniciado a partir de zero, mas `STRIKES_TOTAL` deve manter histórico.
- **Aprovação**: dual counter correto.
- **Reprovação**: histórico perdido ou janela punitiva não reiniciada → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-33 — Validar preservação de histórico total

- **Regra**: RN-29.
- **Obrigatoriedade**: obrigatório.
- **Passos**: revisar avaliações antigas em AUDIT_LOG após reativação; confirmar que continuam visíveis e somam no `STRIKES_TOTAL`.
- **Aprovação**: histórico intacto.
- **Reprovação**: P0.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-34 — Validar janela punitiva pós-reativação

- **Regra**: RN-30.
- **Obrigatoriedade**: obrigatório.
- **Passos**: após CM-30, registrar nova avaliação baixa para Beta. `STRIKES_PUNICAO` deve ir a 1, e não 3.
- **Aprovação**: janela punitiva reiniciada corretamente.
- **Reprovação**: punição imediata → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-35 — Validar empresa inativa

- **Regra**: RN-13.
- **Obrigatoriedade**: obrigatório.
- **Passos**:
  1. Inativar Gama via tela apropriada.
  2. Emitir nova Pré-OS no serviço.
  3. Confirmar que Gama é pulada.
- **Aprovação**: Gama ignorada.
- **Reprovação**: P0.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-36 — Validar entidade inativa

- **Regra**: RN-02 (negativo).
- **Obrigatoriedade**: complementar.
- **Passos**:
  1. Inativar entidade de teste.
  2. Tentar emitir Pré-OS para essa entidade.
- **Resultado**: bloqueio.
- **Aprovação**: bloqueio.
- **Reprovação**: aceita inativa → **P1**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-37 — Validar bloqueio total sem travamento

- **Regra**: RN-34.
- **Obrigatoriedade**: obrigatório.
- **Passos**:
  1. Inativar/suspender todas as empresas credenciadas do serviço.
  2. Tentar emitir Pré-OS.
- **Resultado**: mensagem `SEM_CREDENCIADOS_APTOS` ou equivalente; Excel não trava.
- **Aprovação**: mensagem amigável.
- **Reprovação**: Excel trava ou erro VBA → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-38 — Validar reabilitação em cadeia

- **Regra**: RN-31, RN-32, RN-33.
- **Obrigatoriedade**: complementar.
- **Passos**:
  1. Reativar todas as empresas inativadas.
  2. Emitir nova Pré-OS.
- **Resultado**: ordem de fila preservada.
- **Aprovação**: rotação esperada.
- **Reprovação**: ordem incorreta → **P1**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-39 — Validar múltiplas atividades

- **Regra**: RN-01, RN-06.
- **Obrigatoriedade**: complementar.
- **Passos**: cadastrar segundo serviço para atividade diferente; credenciar Alfa nos dois serviços; emitir Pré-OS em cada um.
- **Resultado**: independência entre filas.
- **Aprovação**: cada fila opera isolada.
- **Reprovação**: vazamento de estado → **P1**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-40 — Validar OS aberta bloqueia somente o contexto correto

- **Regra**: RN-16 (escopo).
- **Obrigatoriedade**: complementar.
- **Lacuna a validar**: a granularidade do bloqueio (por atividade vs serviço vs global) precisa ser confirmada pelo testador no cenário real.
- **Passos**: com Alfa com OS aberta em serviço A, tentar emitir Pré-OS em serviço B.
- **Resultado**: comportamento real observado. Registrar.
- **Aprovação**: comportamento consistente com regra documentada.
- **Reprovação**: comportamento ambíguo ou erro VBA → **P1** + nota documental.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-41 — Validar integridade da base

- **Regra**: RN-35, RN-36.
- **Obrigatoriedade**: complementar.
- **Passos**:
  1. Após executar todos os cenários, repetir o Sexteto.
  2. Conferir IntegridadeBase = `4/0`.
  3. Abrir `RPT_INT_*` se existir; revisar visualmente.
- **Aprovação**: integridade preservada.
- **Reprovação**: novas órfãs → **P1**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-42 — Validar relatório de auditoria

- **Regra**: RN-37.
- **Obrigatoriedade**: obrigatório.
- **Passos**:
  1. Abrir `AUDIT_LOG`.
  2. Conferir presença de famílias: `EVT_CADASTRO`, `EVT_SELECAO`, `EVT_PRE_OS_GERADA`, `EVT_OS_GERADA`, `EVT_OS_CONCLUIDA`, `Avaliacao Registrada`, `EVT_SUSPENSAO`, `EVT_REATIVACAO`, `EVT_TRANSACAO`.
- **Aprovação**: famílias presentes para as ações executadas.
- **Reprovação**: ausência → **P1**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-43 — Validar Limpar Base

- **Regra**: RN-38, RN-43.
- **Obrigatoriedade**: obrigatório.
- **Pré-condições**: senha de Limpar Base fornecida pelo mantenedor.
- **Passos**:
  1. Abrir **Configurações Iniciais** → **Limpar Base**.
  2. Confirmar que o campo de senha aparece mascarado.
  3. Digitar a senha.
  4. Confirmar.
  5. Conferir `RPT_LIMPEZA_TOTAL`.
  6. Conferir AUDIT_LOG `OPERACAO=LIMPAR_BASE; AUTORIZADA=True`.
- **Aprovação**: limpeza autorizada com relatório.
- **Reprovação**: senha aceita em claro → **P0**; limpeza sem autorização → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-44 — Confirmar que CNAE permanece

- **Regra**: RN-39.
- **Obrigatoriedade**: obrigatório.
- **Passos**: abrir `ATIVIDADES`; confirmar dados CNAE intactos.
- **Aprovação**: intacto.
- **Reprovação**: zerado → **P0** (planilha inutilizável para município).

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-45 — Confirmar que CAD_SERV é limpo

- **Regra**: RN-40.
- **Obrigatoriedade**: obrigatório.
- **Passos**: abrir `CAD_SERV`; confirmar cabeçalho canônico, sem dados.
- **Aprovação**: zerado com cabeçalho.
- **Reprovação**: dados residuais → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-46 — Cadastrar serviço novo após Limpar Base

- **Regra**: RN-42.
- **Obrigatoriedade**: obrigatório.
- **Passos**:
  1. Abrir **Cadastra e Altera Serviço**.
  2. Cadastrar novo serviço (ex.: "Manutenção elétrica V204 — Município X").
- **Aprovação**: cadastro funciona sem erro.
- **Reprovação**: erro `O objeto é obrigatório` → **P0** (regressão MICRO53-fix2).

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-47 — Executar o sistema como se fosse outro município

- **Regra**: RN-42.
- **Obrigatoriedade**: complementar.
- **Passos**:
  1. Abrir **Configurações Iniciais**.
  2. Alterar nome do município, gestor, e parâmetros.
  3. Confirmar.
  4. Recriar entidade, empresa e serviço com identidades diferentes.
  5. Emitir uma Pré-OS.
- **Aprovação**: reuso completo sem lixo residual.
- **Reprovação**: dados antigos aparecem → **P1**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-48 — Repetir Sexteto após testes manuais

- **Regra**: RN-47 (regressão).
- **Obrigatoriedade**: obrigatório.
- **Passos**: executar novamente o Sexteto Mínimo após todos os fluxos manuais.
- **Aprovação**: continua aprovado com a mesma sintaxe canônica.
- **Reprovação**: qualquer regressão → **P0/P1**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-49 — Conferir que não houve regressão

- **Regra**: RN-47.
- **Obrigatoriedade**: obrigatório.
- **Passos**: comparar CSV do Sexteto rodado em CM-48 com o do CM-04. Sintaxe deve ser idêntica.
- **Aprovação**: idêntica.
- **Reprovação**: divergência → bug.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

### CM-50 — Reentrada em fluxos mutadores (duplo clique)

- **Regra**: RN-44.
- **Obrigatoriedade**: complementar (cobertura automatizada `UI_ADV_001`).
- **Passos**: em **Solicitar Pré-OS**, dar duplo clique rápido no botão **Confirmar**. Confirmar que apenas uma Pré-OS é gerada.
- **Aprovação**: idempotência.
- **Reprovação**: duplicidade → **P0**.

| Campo | Preenchimento do testador |
|---|---|
| Data/hora |  |
| Testador |  |
| Resultado |  |
| Evidência anexada |  |
| Print da tela |  |
| Aba conferida |  |
| Linha de AUDIT_LOG conferida |  |
| Observações |  |
| ID de bug |  |

---

## 8. MATRIZ REGRA → TESTE AUTOMÁTICO → TESTE MANUAL → EVIDÊNCIA

| Regra | Teste automático | Teste manual | Evidência automática | Evidência manual | Cobertura | Lacuna |
|---|---|---|---|---|---|---|
| RN-01 Credenciamento exige base | V1, V2 Canônica, IntegridadeBase, `MIG_009` | CM-06 a CM-13 | CSV Sexteto | Prints + AUDIT_LOG | Coberto automático + manual | — |
| RN-02 Cadastro entidade | V1, V2 Canônica | CM-06, CM-07 | CSV | Prints | Coberto automático + manual | Acentuação/espaços (P2) |
| RN-03 Cadastro empresa | V1, V2 Canônica, IntegridadeBase | CM-08 | CSV | Prints | Coberto automático + manual | — |
| RN-04 Unicidade CNPJ | V1, V2 Canônica | CM-09 | CSV | Print bloqueio | Coberto automático + manual | Tolerância de formatação (P2) |
| RN-05 Cadastro atividade (CNAE) | Smoke `MIG_009`, V2 Canônica | CM-44 | CSV | Print preservação | Coberto automático + manual | — |
| RN-06 Vínculo CNAE/atividade | V2 Canônica `CS_22` | CM-12 | CSV | Print bloqueio | Coberto automático + manual | — |
| RN-07 Cadastro serviço | V2 Canônica, Smoke `MIG_009` | CM-10 | CSV | Print da tela | Coberto automático + manual | — |
| RN-08 Serviço duplicado | V2 Canônica (parcial) | CM-11 | CSV | Print | Parcial | Confirmar comportamento real (P2) |
| RN-09 Serviço sem atividade | IntegridadeBase | CM-12 | CSV | Print | Coberto automático + manual | — |
| RN-10 Credenciamento | V2 Canônica, E2E Strikes | CM-13 | CSV | Print | Coberto automático + manual | — |
| RN-11 Fila de rodízio | V2 Canônica, E2E Strikes, Boundary Dates | CM-14, CM-17, CM-18 | CSV | Print sequência | Coberto automático + manual | Rotações >5 (P2) |
| RN-12 Empresa apta | V2 Canônica, E2E Strikes | CM-14 | CSV | Print | Coberto automático + manual | Cruzamento de atividades (P2) |
| RN-13 Empresa inativa | V2 Canônica `CS_20`, E2E Strikes | CM-35 | CSV | Print | Coberto automático + manual | — |
| RN-14 Empresa suspensa | E2E Strikes, Boundary Dates | CM-28 | CSV | Print | Coberto automático + manual | — |
| RN-15 Pré-OS pendente | V2 Canônica, E2E Strikes | CM-22 | CSV | Print | Coberto automático + manual | — |
| RN-16 OS aberta | V2 Canônica, E2E Strikes, IntegridadeBase | CM-19, CM-40 | CSV | Print | Coberto automático + manual | Granularidade contexto (P2) |
| RN-17 Emissão Pré-OS | V2 Canônica, Smoke | CM-14 | CSV | Print | Coberto automático + manual | — |
| RN-18 Aceite Pré-OS | V2 Canônica, E2E Strikes | CM-15 | CSV | Print | Coberto automático + manual | — |
| RN-19 Recusa Pré-OS | E2E Strikes, V2 Canônica | CM-20 | CSV | Print | Coberto automático + manual | Ciclo até MAX_RECUSAS (P2) |
| RN-20 Expiração Pré-OS | Smoke `EXP_001`, E2E Strikes | CM-21 (lacuna) | CSV | N/A | Coberto automático | Manual lacuna (lacuna a validar) |
| RN-21 Conversão Pré-OS em OS | V2 Canônica, E2E Strikes, IntegridadeBase | CM-15, CM-16 | CSV | Print | Coberto automático + manual | — |
| RN-22 OS aberta | V2 Canônica | CM-19 | CSV | Print | Coberto automático + manual | — |
| RN-23 Conclusão OS | V2 Canônica `CS_18`, E2E Strikes | CM-23 | CSV | Print | Coberto automático + manual | — |
| RN-24 Avaliação | E2E Strikes `CS_AVAL_001..007`, Smoke `MIG_008`, Boundary Dates `DATE_BND_008/009` | CM-24, CM-25 | CSV | Print | Coberto automático + manual | — |
| RN-25 Nota mínima | Smoke `MIG_008`, `CFG_001..002` | CM-29 | CSV | Print | Coberto automático + manual | Valores extremos (P2) |
| RN-26 Justificativa de divergência | V2 Canônica (parcial) | CM-24 (variação) | CSV | Print | Parcial | Combinatória (P2) |
| RN-27 Strike | E2E Strikes, `CS_REATIV_AUDIT_DUAL_COUNTER` | CM-26, CM-27 | CSV | AUDIT_LOG | Coberto automático + manual | — |
| RN-28 Suspensão por strikes | E2E Strikes, Smoke `MIG_008`, Boundary Dates | CM-28 | CSV | AUDIT_LOG | Coberto automático + manual | — |
| RN-29 Strikes total preservado | `CS_REATIV_HISTORICO_TOTAL_PRESERVADO` | CM-33 | CSV | AUDIT_LOG | Coberto automático + manual | — |
| RN-30 Janela punitiva | `CS_REATIV_JANELA_EXCLUI_HISTORICO`, Boundary Dates | CM-34 | CSV | AUDIT_LOG | Coberto automático + manual | — |
| RN-31 Reativação manual | E2E Strikes `CS_REATIV_DT_ULT_REATIV_GRAVADA`, `CS_23` | CM-30 | CSV | AUDIT_LOG | Coberto automático + manual | — |
| RN-32 Reativação automática | `CS_E2E_E_VOLTA_*`, `CS_11/13/16` | CM-31 (lacuna) | CSV | N/A | Coberto automático | Manual lacuna (lacuna a validar) |
| RN-33 Preservação de posição | E2E Strikes | CM-17, CM-38 | CSV | Print | Coberto automático + manual | — |
| RN-34 Bloqueio total sem travar | V2 Canônica, E2E Strikes | CM-37 | CSV | Print mensagem | Coberto automático + manual | — |
| RN-35 Integridade referências | IntegridadeBase `CS_INT_01..05` | CM-41 | CSV | Print relatório | Coberto automático + manual | Histórico pré-V204 (P2) |
| RN-36 Dados órfãos | IntegridadeBase, MICRO38 | CM-41 | CSV | Relatório `RPT_INT_*` | Coberto automático + manual | Migração legado (P2) |
| RN-37 Auditoria AUDIT_LOG | V2 Canônica `CS_21`, V1 | CM-42 | CSV | AUDIT_LOG | Coberto automático + manual | Granularidade campo (P2) |
| RN-38 Limpar Base | Smoke `MIG_009` | CM-43 | CSV | `RPT_LIMPEZA_TOTAL` | Coberto automático + manual | — |
| RN-39 Preservar CNAE | Smoke `MIG_009` | CM-44 | CSV | Print `ATIVIDADES` | Coberto automático + manual | — |
| RN-40 Limpar CAD_SERV | Smoke `MIG_009` | CM-45 | CSV | Print `CAD_SERV` | Coberto automático + manual | — |
| RN-41 Preservar CONFIG | V2 Canônica + Smoke | CM-43 | CSV | Print `CONFIG` | Coberto automático + manual | — |
| RN-42 Reuso municipal | Smoke `MIG_009` | CM-46, CM-47 | CSV | Print | Coberto automático + manual | Troca de município via UI (P2) |
| RN-43 Segurança ações destrutivas | `UI_ADV_012` | CM-43 | CSV | Print campo mascarado | Coberto automático + manual | — |
| RN-44 Reentrada de botões | `UI_ADV_001` (12 asserts) | CM-50 | CSV | Print | Coberto automático + manual | UI visual exploratória (P3) |
| RN-45 Transação interrompida | `TX_INT_001..006` | — | CSV | N/A | Coberto automático | Interrupção física (lacuna) |
| RN-46 Bordas de data | `DATE_BND_001..009` | — | CSV | N/A | Coberto automático | Locale/timezone (lacuna) |
| RN-47 Interface sem VBE | `UI_ADV_011_SEXTETO_GATE_EXPOSTO` | CM-01 a CM-05 | CSV | Prints | Coberto automático + manual | Mensageria (V205) |

### Legenda de cobertura

- **Coberto automático + manual** — regra é validada por suíte automatizada **e** por roteiro manual deste protocolo.
- **Coberto automático** — regra é validada por suíte; manual marcado como lacuna controlada (cenário automatizável apenas).
- **Coberto manual** — regra exige validação manual (nenhuma na V204; reservado para regras de UX/comportamento dependente de teclado/mouse).
- **Parcial** — cobertura parcial, com lacuna explícita.
- **Não coberto** — nenhum na V204; quando ocorrer, registrar como débito V205.

---

## 9. CHECKLIST DE LIBERAÇÃO PARA PRODUÇÃO

Este checklist é o **gate humano final** que decide se a V12.0.0204 pode ser liberada para produção em municípios reais.

| Critério | Obrigatório? | Resultado (APROVADO/REPROVADO/N/A) | Evidência | Responsável | Observação |
|---|---|---|---|---|---|
| Arquivo `.xlsm` correto recebido | Sim |  |  |  |  |
| Macros liberadas no Windows | Sim |  |  |  |  |
| Botão **Sobre** mostra `V12.0.0204` | Sim |  |  |  |  |
| Botão **Sobre** mostra `VALIDADO` | Sim |  |  |  |  |
| Botão **Sobre** mostra build `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` | Sim |  |  |  |  |
| Sexteto Mínimo executado pela interface | Sim |  |  |  |  |
| Sintaxe canônica = `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` | Sim |  |  |  |  |
| `RESULTADO_GERAL=APROVADO` em `VALIDACAO_RELEASE` | Sim |  |  |  |  |
| CSV de evidência identificado na pasta canônica | Sim |  |  |  |  |
| Todos os cenários obrigatórios (CM-01 a CM-05, CM-06, CM-08, CM-09, CM-10, CM-13, CM-14, CM-15, CM-17, CM-18, CM-19, CM-20, CM-22, CM-23, CM-24, CM-25, CM-26, CM-27, CM-28, CM-30, CM-32, CM-33, CM-34, CM-37, CM-42, CM-43, CM-44, CM-45, CM-46, CM-48, CM-49) aprovados | Sim |  |  |  |  |
| Nenhum P0 aberto | Sim |  |  |  |  |
| Nenhum P1 aberto | Sim |  |  |  |  |
| P2 aceitos formalmente pelo mantenedor | Sim (se houver) |  |  |  |  |
| P3 registrados como melhoria | Não |  |  |  |  |
| Limpar Base aprovado (CM-43 a CM-47) | Sim |  |  |  |  |
| Regras críticas RN-01, RN-11, RN-16, RN-22, RN-24, RN-28, RN-30, RN-31, RN-34, RN-38, RN-39, RN-40, RN-43 aprovadas | Sim |  |  |  |  |
| Relatório final do testador (Seção 10) assinado | Sim |  |  |  |  |
| Bug reports formais (Seção 11) anexados quando houver | Sim (condicional) |  |  |  |  |

### Regra de decisão final

| Cenário | Decisão |
|---|---|
| Todos os obrigatórios marcados APROVADO | **APROVAR PARA PRODUÇÃO** |
| Algum obrigatório REPROVADO com P0 ou P1 | **REPROVAR** |
| Obrigatórios APROVADOS mas P2 documentados sem resolução | **APROVAR COM RESSALVAS** |
| Bloqueio P0 ainda em aberto (sem fix) | **REPROVAR** sempre |

---

## 10. MODELO DE RELATÓRIO FINAL DO TESTADOR

O relatório final é o documento que sustenta a decisão de liberação. Deve ser preenchido pelo testador após todos os cenários.

```
RELATÓRIO FINAL DE HOMOLOGAÇÃO V12.0.0204
==========================================

1. Identificação
   Testador (nome completo):
   Organização:
   E-mail / contato:
   Data de início:
   Data de encerramento:
   Total de horas dedicadas:

2. Identificação do arquivo testado
   Nome do arquivo .xlsm:
   Tamanho do arquivo:
   Hash MD5/SHA (se aplicável):
   Origem do recebimento:
   Versão exibida em Sobre:           V12.0.0204
   Status exibido em Sobre:           VALIDADO
   Build exibido em Sobre:            f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2

3. Ambiente
   Sistema operacional:
   Versão Excel:
   Idioma Excel:
   Locale Windows:
   Política de macros:

4. Resumo dos testes automáticos
   Sexteto VALIDACAO_ID (CSV):
   V1:                     ___ / ___
   V2 Smoke:               ___ / ___
   V2 Canônica:            ___ / ___
   E2E Strikes:            ___ / ___
   IntegridadeBase:        ___ / ___
   Onda23Adv:              ___ / ___
   RESULTADO GERAL:        APROVADO / REPROVADO

5. Resumo dos testes manuais
   Total de cenários (CM-XX) executados:
   Aprovados:
   Reprovados:
   Bloqueados:
   Lacunas declaradas:

6. Bugs encontrados
   Total de bugs:
   P0:
   P1:
   P2:
   P3:
   IDs (lista):

7. Severidades concentradas
   P0 abertos:
   P0 resolvidos:
   P1 abertos:
   P1 resolvidos:

8. Riscos identificados
   (Lista livre de riscos não materializados em bug, mas com potencial)

9. Lacunas declaradas
   (Lista de cenários "lacuna a validar" assumidos)

10. Decisão recomendada
    [ ] APROVAR PARA PRODUÇÃO
    [ ] APROVAR COM RESSALVAS
    [ ] REPROVAR

11. Justificativa da decisão
    (Texto livre — mínimo 5 linhas explicando a decisão)

12. Recomendações
    (Texto livre)

13. Anexos
    [ ] CSV Sexteto
    [ ] Prints das telas
    [ ] Bug reports formais
    [ ] Relatório RPT_LIMPEZA_TOTAL
    [ ] Trilha AUDIT_LOG (amostra)

14. Assinatura
    Testador (nome):
    Data:
    Local:
    Assinatura:

    Recebido por (mantenedor):
    Data:
    Assinatura:
```

---

## 11. MODELO DE BUG REPORT

Para cada anomalia, preencher um relatório formal:

| Campo | Descrição |
|---|---|
| ID | (preenchido pelo testador, ex.: `BUG-V204-001`) |
| Título | (resumo curto) |
| Severidade | P0 / P1 / P2 / P3 |
| Cenário | (CM-XX correspondente ou descrição livre) |
| Passos para reprodução | (numerados) |
| Resultado obtido | (o que aconteceu) |
| Resultado esperado | (o que deveria acontecer) |
| Evidência | (print, CSV, linha de AUDIT_LOG) |
| Frequência | (sempre / intermitente / única vez) |
| Impacto operacional | (texto) |
| Regra de negócio violada | (RN-XX) |
| Anexo | (caminho/nome do arquivo de evidência) |
| Build | `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |
| Versão | V12.0.0204 |
| Data/hora | (preencher) |
| Testador | (preencher) |
| Observações adicionais | (texto livre) |

### Tabela preenchível de bugs (resumo)

| ID | Severidade | Cenário | Regra | Status | Data | Anexo |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |
|  |  |  |  |  |  |  |

---

## 12. ITENS NÃO COBERTOS PELOS TESTES AUTOMATIZADOS

Esta seção lista, explicitamente, tudo que os testes automáticos da V204 não cobrem ou cobrem apenas parcialmente. O testador humano deve dar atenção especial a esses pontos.

### 12.1 Lista declarada

| Item | Risco | Por que não está coberto | Teste humano necessário | Evidência necessária | Recomendação V205 |
|---|---|---|---|---|---|
| Interrupção física do Excel durante transação | Estado parcial sob falha de processo | Suíte automatizada cobre interrupção lógica, não física | Cenário exploratório com `taskkill` (fora do escopo do testador externo) | Print do estado antes/depois | Implementar `TX_PHYSICAL_INTERRUPT` em V205 |
| Locale/timezone diferente do PT-BR padrão | Bordas de data podem se comportar diferente | Boundary Dates roda no locale do workbook em teste | Repetir bateria em Excel com locale `en-US` | CSV em ambos os locales | Adicionar matriz de locale automatizada |
| Engenharia reversa do projeto VBA | Edição maliciosa de macros | Proteção VBA é técnica de redução, não criptográfica | Validar bloqueio na entrega | Print da tentativa de abrir VBE | Investigar `Workbook_Open` com checksum |
| Política corporativa de macros (GPO) | Bloqueio total de macros | Depende de ambiente do usuário | Confirmar política na máquina alvo | Documentação do administrador | Documentar canal de pasta confiável |
| Performance sob estresse longo (>1h, milhares de OS) | Degradação ou estouro de memória | Stress curto rodado, longo deferido | Cenário longo manual | Print de tempo + memória | `TV2_RunStress` ampliado |
| Compatibilidade Excel Mac/Online | Aplicação não suportada | Escopo é Windows Desktop | Não exigido na V204 | Declaração de escopo | Avaliar matriz V205 |
| Engenharia reversa do CNAE | Erro humano carregando CNAE corrompido | Atribuição do mantenedor | Conferir base CNAE íntegra | Print `ATIVIDADES` | Auto-validação de CNAE em V205 |
| UX granular de mensagens | Confusão do operador | Cobertura é funcional, não cognitiva | Avaliação exploratória do testador | Anotações livres | Mensageria V205 |
| Granularidade de bloqueio por contexto (atividade vs serviço) | Bloqueio em contexto errado | Cobertura é canônica; cenário CM-40 cobre exploratoriamente | Cenário CM-40 + observação | Print + AUDIT_LOG | Documentar comportamento exato em V205 |
| Cenários combinatórios além de 5 empresas | Quebra de fila em pools maiores | E2E cobre `CS_E2E_5EMPS`, não 10+ | Manual exploratório | Print sequência | `CS_E2E_10EMPS` em V205 |
| Validação semântica de CNPJ | CNPJ inválido aceito | Cobertura por chave, não por dígito | CM-08 com CNPJ inválido | Print | Validador de CNPJ V205 |
| Re-execução em ambiente sem permissão de escrita | CSV não gerado, gate sem evidência | Depende de ambiente | Confirmar permissão na máquina | Tentativa documentada | Diagnóstico de permissão V205 |
| Acentuação/codificação UTF-8 em dados de teste | Mojibake em campos | Conhecido para nomes com Ç, Ã, etc. | Cadastrar entidade com acentuação | Print da aba | Normalização determinística (parcialmente em `CorrigirMojibakeBasico`) |
| Recusa cumulativa até MAX_RECUSAS exato | Punição por excesso de recusas | Cobertura por unidade; ciclo completo de 3 é "lacuna a validar" manual | Sequência de 3 recusas em CM-20 estendido | Print + AUDIT_LOG | `CS_E2E_MAX_RECUSAS` V205 |

### 12.2 Itens reservados como "lacuna a validar" durante a homologação humana

- CM-11 (serviço duplicado) — comportamento real precisa ser observado e registrado.
- CM-21 (expiração de Pré-OS) — sem manipulação manual de data.
- CM-31 (reativação automática) — sem manipulação manual de data.
- CM-40 (bloqueio de OS aberta por contexto) — granularidade do bloqueio.

---

## 13. NOVOS TESTES PROPOSTOS PARA V12.0.0205

Cada proposta segue formato padronizado para entrada em backlog da V205.

### Proposta TP-01 — Renomear taxonomia "Sexteto/Quinteto/Quarteto"

- **ID sugerido**: V205-TAX-01
- **Nome**: Renomeação de gates para nomenclatura profissional
- **Objetivo**: substituir nomes lúdicos por termos como "Release Gate", "Smoke Suite", "Canonical Suite", "E2E Suite", "Integrity Suite", "Adversarial Suite".
- **Regra coberta**: RN-47 (UX).
- **Tipo**: documentação + UI.
- **Prioridade**: alta.
- **Motivo**: ambiente municipal/auditoria pública valoriza termos profissionais.
- **Critério de aprovação**: nova nomenclatura visível na Central e na evidência CSV.
- **Impacto esperado**: reduz fricção em apresentações externas; preserva rastreabilidade histórica.

### Proposta TP-02 — Reordenar e simplificar a Central de Testes

- **ID sugerido**: V205-UI-01
- **Nome**: Central de Testes "primeira opção é o gate completo"
- **Objetivo**: que `[1]` seja o gate de release sem janela intermediária `[2] Central V2`.
- **Regra**: RN-47.
- **Tipo**: UI.
- **Prioridade**: alta.
- **Motivo**: reduz cliques, evita confusão com "Quarteto Direto".
- **Critério de aprovação**: testador externo chega ao gate em ≤ 2 cliques.
- **Impacto**: maior conformidade do roteiro humano.

### Proposta TP-03 — Teste por interface clicável (UI-test framework)

- **ID sugerido**: V205-UI-02
- **Nome**: Framework de teste de UI clicável
- **Objetivo**: simular cliques reais em formulários via UIAutomation/AutoHotkey ou similar.
- **Regra**: RN-44, RN-47.
- **Tipo**: UI / integração.
- **Prioridade**: média.
- **Motivo**: hoje `UI_ADV_*` é read-only; cliques reais aumentam confiança.
- **Critério**: suíte rodando sob orquestrador externo.
- **Impacto**: cobertura UI dobra.

### Proposta TP-04 — Teste visual de formulários

- **ID sugerido**: V205-UI-03
- **Nome**: Snapshot visual + diff de formulários
- **Objetivo**: capturar baseline visual e detectar regressão.
- **Regra**: RN-44, RN-47.
- **Tipo**: UI.
- **Prioridade**: média.
- **Motivo**: bugs visuais (truncamento de MsgBox, labels cortados) hoje são detectados só por humanos.
- **Critério**: relatório de diff visual.
- **Impacto**: redução de retrabalho.

### Proposta TP-05 — Teste de navegação sem VBE

- **ID sugerido**: V205-UI-04
- **Nome**: Cenário automatizado de "homologação humana"
- **Objetivo**: orquestrar o caminho `Sobre → Central → Sexteto → relatório` automaticamente, validando que cada passo está acessível pela UI.
- **Regra**: RN-47.
- **Tipo**: integração.
- **Prioridade**: alta.
- **Motivo**: garante que o caminho exposto ao testador permanece consistente entre releases.
- **Critério**: suíte verde sem invocar Janela Imediata.
- **Impacto**: previne degradação do guia humano.

### Proposta TP-06 — Teste de proteção do arquivo final

- **ID sugerido**: V205-SEC-01
- **Nome**: Auditoria de proteção VBA na entrega
- **Objetivo**: verificar, antes do envio, que o projeto VBA está protegido contra edição casual.
- **Regra**: RN-43, RN-47.
- **Tipo**: segurança.
- **Prioridade**: alta.
- **Motivo**: garante hand-off seguro.
- **Critério**: assert automatizado falhando se proteção VBA não estiver aplicada.
- **Impacto**: gate de entrega.

### Proposta TP-07 — Teste de arquivo baixado do GitHub no Windows

- **ID sugerido**: V205-SEC-02
- **Nome**: Smoke de "abrir arquivo recém-baixado"
- **Objetivo**: simular fluxo do testador real (download + desbloqueio + abertura).
- **Regra**: RN-47.
- **Tipo**: integração.
- **Prioridade**: média.
- **Motivo**: hoje o desbloqueio é manual.
- **Critério**: passo a passo automatizado por PowerShell + Excel COM.
- **Impacto**: detecta regressão de Mark-of-the-Web.

### Proposta TP-08 — Teste de política de macro bloqueada

- **ID sugerido**: V205-SEC-03
- **Nome**: Cenário de macro bloqueada
- **Objetivo**: confirmar que a mensagem do sistema é compreensível quando macros estão bloqueadas.
- **Regra**: RN-47.
- **Tipo**: UI / integração.
- **Prioridade**: média.
- **Motivo**: hoje testador depende de documentação externa.
- **Critério**: mensagem padrão.
- **Impacto**: experiência do testador.

### Proposta TP-09 — Teste de reuso municipal após Limpar Base

- **ID sugerido**: V205-RUS-01
- **Nome**: Teste completo de reuso municipal
- **Objetivo**: validar Limpar Base + nova configuração + novo município + novo serviço + nova Pré-OS automaticamente.
- **Regra**: RN-38, RN-42.
- **Tipo**: E2E.
- **Prioridade**: alta.
- **Motivo**: hoje CM-46/CM-47 são manuais.
- **Critério**: cenário verde sem intervenção humana.
- **Impacto**: amplia confiabilidade do reuso.

### Proposta TP-10 — Pacote de homologação como documentação + planilha

- **ID sugerido**: V205-DOC-01
- **Nome**: Pacote "documentação + planilha" unificado
- **Objetivo**: empacotar protocolo, planilha, guias e modelos em um único `.zip` versionado por release.
- **Regra**: RN-47.
- **Tipo**: documentação.
- **Prioridade**: média.
- **Motivo**: reduz risco de testador receber pacote incompleto.
- **Critério**: pipeline gera pacote junto com release.
- **Impacto**: padronização de hand-off.

### Proposta TP-11 — Validador semântico de CNPJ

- **ID sugerido**: V205-VAL-01
- **Nome**: Cadastro de empresa com validação de dígito verificador de CNPJ
- **Objetivo**: bloquear CNPJ formalmente inválido.
- **Regra**: RN-04.
- **Tipo**: unitário.
- **Prioridade**: média.
- **Motivo**: detecta erro humano de digitação.
- **Critério**: cenário `CS_VAL_CNPJ_001..003`.
- **Impacto**: integridade.

### Proposta TP-12 — Cenário E2E com 10+ empresas

- **ID sugerido**: V205-E2E-01
- **Nome**: `CS_E2E_10EMPS` rotação ampla
- **Objetivo**: validar rodízio com pool maior.
- **Regra**: RN-11, RN-33.
- **Tipo**: E2E.
- **Prioridade**: média.
- **Motivo**: cenário real de município médio.
- **Critério**: rotação determinística.
- **Impacto**: confiabilidade ampliada.

### Proposta TP-13 — Cobertura de locale/timezone

- **ID sugerido**: V205-LOC-01
- **Nome**: Boundary Dates em locale en-US
- **Regra**: RN-46.
- **Tipo**: integração.
- **Prioridade**: alta.
- **Motivo**: máquinas reais podem ter locale diverso.
- **Critério**: suíte rodando em pt-BR e en-US.
- **Impacto**: previne bugs invisíveis.

### Proposta TP-14 — Cobertura de divergência de avaliação

- **ID sugerido**: V205-EVAL-01
- **Nome**: Matriz de justificativa obrigatória
- **Regra**: RN-26.
- **Tipo**: unitário.
- **Prioridade**: média.
- **Motivo**: cobre combinatória de campos divergentes.
- **Critério**: assert por campo divergente.
- **Impacto**: integridade.

---

## 14. ANEXOS

### Anexo A — Glossário

| Termo | Definição |
|---|---|
| AUDIT_LOG | Aba que registra todas as ações com efeito de estado |
| Pré-OS | Solicitação prévia de OS, aguardando aceite ou recusa |
| OS | Ordem de Serviço |
| CNAE | Classificação Nacional de Atividades Econômicas |
| CONFIG | Aba de parâmetros operacionais (nota mínima, max strikes, etc.) |
| Strike | Marca de avaliação negativa que pode levar à suspensão |
| Dual counter | Par de contadores (`STRIKES_TOTAL` + `STRIKES_PUNICAO`) que separa histórico bruto e janela punitiva |
| Sexteto | Nome histórico do gate de release V204 (V1 + Smoke + Canônica + E2E Strikes + IntegridadeBase + Onda23Adv) |
| Quinteto | Cinco primeiras dimensões do Sexteto, sem Onda23Adv |
| Quarteto | Quatro primeiras dimensões (V1 + Smoke + Canônica + E2E Strikes) |
| Central de Testes | Botão da tela inicial que abre o menu de baterias |
| Central V2 | Sub-menu de baterias V2 |
| Build importado | Identificador do pacote VBA aplicado ao workbook |
| `f7aa84f` | Hash curto do commit base da árvore V204 |
| MICRO-XX | Identificador de microdelta dentro de uma onda |
| Onda | Bloco lógico de ondas de trabalho (Onda 21 a Onda 25 compõem a V204) |
| HBN | Human Brain Net — protocolo de coordenação inter-IA usado no projeto |
| Importador V3 | Ferramenta interna do mantenedor para reimportar VBA — fora do escopo do testador |

### Anexo B — Dados fictícios sugeridos

| Tipo | Valor sugerido |
|---|---|
| Entidade | Secretaria Municipal de Teste V204 |
| Empresa A | Empresa Teste Alfa Ltda. |
| Empresa B | Empresa Teste Beta Ltda. |
| Empresa C | Empresa Teste Gama Ltda. |
| Empresa D (opcional) | Empresa Teste Delta Ltda. |
| Empresa E (opcional) | Empresa Teste Épsilon Ltda. |
| CNPJ A | `11.111.111/0001-11` |
| CNPJ B | `22.222.222/0001-22` |
| CNPJ C | `33.333.333/0001-33` |
| CNAE de exemplo | escolher um existente em `ATIVIDADES` |
| Serviço A | Manutenção predial V204 |
| Serviço B | Manutenção elétrica V204 |
| Valor de OS | `100,00` |
| Nota baixa | `3,0` |
| Nota aprovada | `8,0` |
| Justificativa de divergência | "Ajuste de empenho — homologação V204" |
| Senha de Limpar Base | (informada pelo mantenedor — não publicar) |

### Anexo C — Tabela de evidências esperadas

| Tipo de evidência | Onde se gera | Quando coletar |
|---|---|---|
| CSV Sexteto | `auditoria/evidencias/V12.0.0204/` | CM-04, CM-48 |
| `VALIDACAO_RELEASE` | Aba da planilha | CM-05 |
| `RPT_LIMPEZA_TOTAL` | Aba da planilha | CM-43 |
| `RESULTADO_QA` | Aba da planilha | execução da V1 |
| `TESTE_V2` | Aba da planilha | execuções V2 |
| `AUDIT_LOG` | Aba da planilha | continuamente |
| Print da tela inicial | Captura manual | CM-01 |
| Print do botão Sobre | Captura manual | CM-03 |
| Print de cada cenário CM-XX | Captura manual | conforme cenário |
| CSV de falhas (apenas se houver falha) | Pasta de evidências | conforme suíte |

### Anexo D — Severidade P0/P1/P2/P3

| Severidade | Definição | Exemplo |
|---|---|---|
| **P0** | Bloqueante — risco direto a dados, fechamento do Excel, falha em regra crítica, corrupção, perda de evidência | Excel fecha durante Sexteto; CNAE zerado em Limpar Base; OS gerada sem chave |
| **P1** | Bloqueante de produção mas reversível — regra de negócio errada com escopo limitado | Recusa não avança fila; auditoria ausente em fluxo principal; mensagem de erro genérica em vez de específica |
| **P2** | Não bloqueante — comportamento correto mas confuso | Texto da Central com nome histórico "Sexteto"; ordem das opções pouco intuitiva |
| **P3** | Cosmético — texto, alinhamento, ergonomia menor | Label desalinhado; espaço duplo em mensagem; cor de fundo |

### Anexo E — Lista de abas relevantes

| Aba | Papel |
|---|---|
| `ATIVIDADES` | Base CNAE — preservada em Limpar Base |
| `CAD_SERV` | Serviços cadastrados — zerada em Limpar Base |
| `EMPRESAS` | Empresas ativas |
| `EMPRESAS_INATIVAS` | Empresas inativas |
| `ENTIDADE` | Entidades demandantes |
| `ENTIDADE_INATIVOS` | Entidades inativas |
| `CREDENCIADOS` | Vínculos empresa↔serviço/atividade |
| `PRE_OS` | Pré-ordens de serviço |
| `CAD_OS` | OS efetivas |
| `AUDIT_LOG` | Trilha auditável |
| `RELATORIO` | Relatórios operacionais |
| `CONFIG` | Parâmetros do sistema |
| `RESULTADO_QA` | Saída da V1 Bateria Oficial |
| `TESTE_V2` | Saída das suítes V2 |
| `VALIDACAO_RELEASE` | Saída do gate consolidado (Sexteto) |
| `RPT_LIMPEZA_TOTAL` | Relatório da última operação Limpar Base |
| `RPT_DIAG_RODIZIO` | Diagnóstico de fila (gerado por `Diag_RodizioStatus`) |
| `RPT_BUGS_CONHECIDOS` | Bugs conhecidos do projeto |
| `RPT_BUGS_RESOLVIDOS` | Bugs resolvidos |
| `RPT_INT_*` | Relatórios de IntegridadeBase |

### Anexo F — Lista de mensagens esperadas

| Contexto | Mensagem (texto canônico ou trecho) |
|---|---|
| Sobre | `Release oficial: V12.0.0204` |
| Sobre | `Status oficial: VALIDADO` |
| Sobre | `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |
| Modo Treinamento | Pergunta padrão "Deseja entrar em Modo Treinamento?" |
| Sexteto concluído | "Sexteto concluído. ..." com sintaxe canônica |
| VALIDACAO_RELEASE | `RESULTADO_GERAL=APROVADO` |
| Limpar Base | "PRESERVADO (nao tocado): - ATIVIDADES (CNAE), - CONFIG" no `RPT_LIMPEZA_TOTAL` |
| Configuração inválida | Mensagem com prefixo `CONFIG_INVALIDA` na auditoria |
| Sem empresa apta | `SEM_CREDENCIADOS_APTOS` (motivo registrado) |
| Reativação | `EVT_REATIVACAO` em AUDIT_LOG |

### Anexo G — Lista de mensagens que indicam bug

| Mensagem | Tipo de bug |
|---|---|
| `Erro fatal na bateria oficial:` | Falha de gate (P0) |
| `O objeto é obrigatório` | Cadastro de serviço quebrado (P0, regressão MICRO53-fix2) |
| `Erro de compilação:` em qualquer abertura | Build corrompido (P0) |
| `Subscrito fora do intervalo` em qualquer formulário | Bug VBA (P0/P1) |
| `Application-defined or object-defined error` | Bug VBA (P0/P1) |
| Excel fecha sozinho | P0 absoluto |
| `FATAL` em qualquer linha de `VALIDACAO_RELEASE` | Gate falhou (P0) |

### Anexo H — Referência dos CSVs oficiais

| Arquivo | Significado |
|---|---|
| `ValidacaoReleaseSexteto_V12_0_0204_VR_20260511_175849.csv` | **Evidência canônica final** (após App_Release MICRO55) |
| `ValidacaoReleaseSexteto_V12_0_0204_VR_20260511_154433.csv` | **Evidência de publicação** (gate do anúncio) |
| `ValidacaoReleaseSexteto_V12_0_0203_VR_20260511_175849.csv` | Nome histórico do mesmo CSV (prefixo `V12_0_0203` preservado por compatibilidade) |
| `ValidacaoReleaseSexteto_V12_0_0203_VR_20260511_154433.csv` | Nome histórico do CSV de publicação |
| `ValidacaoReleaseSexteto_V12_0_0203_VR_20260511_132806.csv` | Gate intermediário (após correção de Limpar Base) |
| `ValidacaoReleaseSexteto_V12_0_0203_VR_20260510_000428.csv` | Gate rc1 anterior |
| `intermediarios/TesteV2_SMOKE_Falhas_TV2_20260511_125944.csv` | Falha intermediária resolvida |

Observação: os nomes de arquivo com `V12_0_0203` correspondem a CSVs gerados antes da renomeação canônica MICRO58; o conteúdo, a pasta e os gates documentados são da V12.0.0204. A correção definitiva do prefixo é débito V205.

---

## 15. Lacunas finais e recomendação de evolução V12.0.0205

Esta seção fecha o protocolo declarando, com transparência total, o que ainda depende de validação humana, o que não tem cobertura automática suficiente, o que precisa ser construído como teste novo, o que precisa melhorar na interface de testes e o que impediria, em homologação, a liberação para produção.

### 15.1 Regras que ainda dependem de validação humana

- **RN-08 Serviço duplicado** — comportamento exato precisa ser confirmado pelo testador (CM-11).
- **RN-19 Recusa de Pré-OS** — ciclo completo até `MAX_RECUSAS=3` cobertura por unidade, mas a sequência ininterrupta de 3 recusas em UI real é "lacuna a validar".
- **RN-20 Expiração de Pré-OS** — depende de manipulação de data; aceitar **coberto automático** com declaração formal de lacuna manual.
- **RN-26 Justificativa de divergência** — combinatória de campos divergentes não é exaustiva; exige observação manual.
- **RN-32 Reativação automática por prazo vencido** — depende de manipulação de data; aceitar **coberto automático**.
- **RN-40/RN-42 Reuso municipal** — CM-46 e CM-47 dependem de operação manual após Limpar Base.
- **RN-44 Reentrada de botões** — automatizado read-only; teste com cliques reais é "lacuna a validar".
- **RN-46 Bordas de data** — testes adicionais com locale `en-US` são "lacuna a validar".

### 15.2 Regras com cobertura automática insuficiente para sustentar produção sem revisão humana

- **RN-08** (serviço duplicado): cobertura parcial — exige revisão humana.
- **RN-16** (granularidade de bloqueio por OS aberta): "lacuna a validar" no CM-40.
- **RN-26** (justificativa): cobertura parcial.
- **RN-35/RN-36** (integridade pós-migração): histórico anterior à V204 segue como débito controlado.
- **RN-45** (transação física interrompida): apenas lógica.
- **RN-46** (datas em locale diverso): apenas no locale do workbook em teste.

### 15.3 Testes novos que devem ser implementados na V205

Resumo do que foi proposto na Seção 13:

1. **V205-TAX-01** — renomear taxonomia profissional.
2. **V205-UI-01** — Central de Testes reordenada.
3. **V205-UI-02** — framework de teste UI clicável.
4. **V205-UI-03** — snapshot visual de formulários.
5. **V205-UI-04** — cenário automatizado de homologação humana.
6. **V205-SEC-01** — auditoria de proteção VBA na entrega.
7. **V205-SEC-02** — smoke de arquivo recém-baixado do GitHub.
8. **V205-SEC-03** — cenário de macro bloqueada.
9. **V205-RUS-01** — teste completo de reuso municipal.
10. **V205-DOC-01** — pacote "documentação + planilha" empacotado por release.
11. **V205-VAL-01** — validador semântico de CNPJ.
12. **V205-E2E-01** — `CS_E2E_10EMPS` rotação ampla.
13. **V205-LOC-01** — Boundary Dates em locale en-US.
14. **V205-EVAL-01** — matriz de justificativa obrigatória.

### 15.4 Melhorias de interface de testes que devem ser feitas

- Tornar a primeira opção da Central de Testes diretamente o gate de release, sem janela intermediária `[2] Central V2`.
- Renomear "Sexteto Mínimo" para "Release Gate V204" (ou nomenclatura combinada na V205).
- Remover/rebaixar a opção antiga **Quarteto Direto** como gate.
- Simplificar a mensagem de **Modo Treinamento**.
- Exibir, na própria UI, descrição curta do que cada bateria faz.
- Padronizar texto de evidência em linguagem de testador humano (ex.: "Evidência salva em: `caminho/...`").
- Imprimir o CSV gerado na mensagem final, abrindo a pasta automaticamente.
- Garantir que `VALIDACAO_RELEASE` tenha cabeçalho de coluna mais legível para impressão.

### 15.5 Pontos que impediriam a liberação para produção se falharem no teste humano

Os seguintes itens são **bloqueantes**: se qualquer um falhar na homologação humana, a versão deve ser **REPROVADA**, independentemente do Sexteto estar verde.

1. **CM-03 Botão Sobre divergente** — qualquer divergência em versão, status ou build → **P0**.
2. **CM-04 Sexteto Mínimo reprovado** — sintaxe canônica fora do esperado → **P0**.
3. **CM-09 Empresa duplicada aceita** → **P0**.
4. **CM-14 Rodízio escolhe empresa errada** → **P0**.
5. **CM-15/CM-16 Aceite/conversão produz OS órfã** → **P0**.
6. **CM-19/CM-22 OS aberta ou Pré-OS pendente não bloqueia nova indicação** → **P0**.
7. **CM-25/CM-26/CM-27/CM-28 Strike/suspensão silenciosos ou incorretos** → **P0**.
8. **CM-30 Reativação sem `DT_ULT_REATIV`** → **P0** (regressão DT-17).
9. **CM-32/CM-33/CM-34 Dual counter de avaliação errado** → **P0**.
10. **CM-37 Excel trava com mensagem fatal** → **P0**.
11. **CM-43 Limpar Base aceita senha em claro** → **P0**.
12. **CM-44 CNAE zerado em Limpar Base** → **P0** (planilha inutilizável).
13. **CM-45 CAD_SERV não zera** → **P0**.
14. **CM-46 Cadastro de Serviço com erro `O objeto é obrigatório`** → **P0** (regressão MICRO53-fix2).
15. **CM-48/CM-49 Sexteto regrediu após testes manuais** → **P0**.

### 15.6 Critério final

Um testador humano externo seguindo este protocolo, sem abrir o Editor VBA, sem usar a Janela Imediata e sem editar código, deve conseguir validar a funcionalidade observável da V12.0.0204 e produzir evidência suficiente para aprovar ou reprovar a liberação para produção.

A decisão final é responsabilidade humana e cabe ao testador formalizá-la no relatório da Seção 10, com anexos de evidências do Sexteto (CSV), prints das telas críticas, AUDIT_LOG amostrado e bug reports formais (quando houver).

A versão V12.0.0204 é considerada **VALIDADA** no eixo automatizado a partir do gate `VR_20260511_175849` (com paralelo `VR_20260511_154433`). A homologação humana descrita aqui é o último passo antes da decisão pública de produção.

---

**Fim do Protocolo de Homologação Humana V12.0.0204.**
