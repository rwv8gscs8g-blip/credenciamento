# Superprompt Claude Opus 4.7

## Objetivo

Você vai atuar como auditor técnico principal do sistema de credenciamento em VBA/Excel, na versão `V12.0.0189`, com foco em realidade operacional, segurança, regras de negócio, consistência documental e eficácia da bateria de testes.

Sua missão não é produzir opinião genérica. Sua missão é produzir uma auditoria técnica profunda, rastreável e acionável, suficiente para:

1. substituir e complementar a última auditoria relevante feita sobre a base `V12.0.0166`
2. validar se as regras de negócio estão realmente protegidas no código e não apenas na interface
3. validar se a documentação atual descreve a realidade do sistema
4. comparar, em profundidade, a bateria legada (`V1`) e a nova bateria (`V2`)
5. avaliar a análise combinatória dos testes e propor cobertura complementar com mais segurança
6. gerar insumos objetivos para que a próxima versão estável seja desenvolvida e estabilizada por outro agente

## Contexto obrigatório

- Projeto: sistema VBA/Excel de credenciamento, rodízio, emissão de Pré-OS, emissão de OS, avaliação de OS e relatórios
- Base estável retomada: `V12.0.0180`
- Versão atual em análise: `V12.0.0189`
- Branch de trabalho: `codex/v180-stable-reset`
- Pasta principal de código: `vba_export/`
- Pasta principal de auditoria: `auditoria/`
- Estado da release/documentação:
  - `obsidian-vault/ai/ESTADO-ATUAL.md`
  - `obsidian-vault/ai/GOVERNANCA.md`
  - `obsidian-vault/releases/V12.0.0189.md`
- Bateria legada:
  - `vba_export/Teste_Bateria_Oficial.bas`
- Bateria V2:
  - `vba_export/Central_Testes_V2.bas`
  - `vba_export/Teste_V2_Engine.bas`
  - `vba_export/Teste_V2_Roteiros.bas`
- Regras de serviço e dependências:
  - `vba_export/Svc_Rodizio.bas`
  - `vba_export/Svc_PreOS.bas`
  - `vba_export/Svc_OS.bas`
  - `vba_export/Svc_Avaliacao.bas`
  - `vba_export/Repo_Credenciamento.bas`
  - `vba_export/Repo_OS.bas`
  - `vba_export/Repo_PreOS.bas`
  - `vba_export/Repo_Avaliacao.bas`
  - `vba_export/Repo_Empresa.bas`
  - `vba_export/Menu_Principal.frm`
  - `vba_export/Util_Planilha.bas`
- Auditorias já existentes para usar como base, confrontar e eventualmente corrigir:
  - `auditoria/00_SUMARIO_EXECUTIVO.md`
  - `auditoria/01_MAPA_ARQUITETURA.md`
  - `auditoria/02_AUDITORIA_INTERFACE_DETERMINISTICA.md`
  - `auditoria/03_AUDITORIA_REGRAS_DE_NEGOCIO.md`
  - `auditoria/04_MATRIZ_MESTRE_DE_TESTES.md`
  - `auditoria/05_AUDITORIA_COMBINATORIA_DE_COBERTURA.md`
  - `auditoria/06_AUDITORIA_MATEMATICA_E_ARREDONDAMENTO.md`
  - `auditoria/07_PADRONIZACAO_DO_TREINAMENTO_E_EXECUCAO_ASSISTIDA.md`
  - `auditoria/08_PLANO_DE_MICRODESENVOLVIMENTO_ANTI_REGRESSAO.md`
  - `auditoria/09_LACUNAS_ASSUNCOES_RISCOS_E_PRIORIDADES.md`
  - `auditoria/10_RELATORIO_ESTRATEGIA_TESTES_V2_PARA_APROVACACAO.md`
  - `auditoria/11_MAPA_TESTES_V2_EXECUTAVEL.md`

## Estado real já conhecido e que você deve validar

Não assuma isso como verdade final. Trate como hipóteses fortemente indicadas pelo código e pelas últimas execuções.

1. Parte relevante das regras de negócio ainda está na interface, não nos serviços.
2. A migração UI -> serviço ainda não está completa.
3. A bateria V2 melhorou em rastreabilidade e semântica, mas ainda depende dessa migração para ser completamente conclusiva.
4. O contrato real da fila não garante renumeração canônica `1..N` após cada giro; ele garante ordem relativa correta e `POSICAO_FILA` crescente.
5. As últimas falhas da `V2.0189` mudaram de padrão:
   - antes: falhas estruturais de asserção em `SMK_007` e `STR_001`
   - agora: falha fatal logo no bootstrap do cenário determinístico
6. Últimos CSVs de falha mostram:
   - `EMPRESAS=4`
   - `ENTIDADE=4`
   - `CREDENCIADOS=4`
   - `PRE_OS=1`
   - `CAD_OS=1`
7. Isso pode significar uma destas possibilidades, e você deve decidir com base no código:
   - reset incompleto da V2
   - contagem incorreta da V2
   - resíduo estrutural do workbook que a V2 está interpretando como dado real
   - combinação das três coisas

## Tarefas obrigatórias

### 1. Diagnóstico profundo do estado do sistema

Faça uma leitura crítica do código e diga, com clareza:

- o que está de fato estável
- o que está funcional, mas com risco
- o que está incorreto
- o que está mal testado
- o que está apenas documentado, mas não garantido pelo código

### 2. Segurança e integridade operacional

Faça uma auditoria específica das regras de segurança e integridade, incluindo:

- escrita parcial e risco de estado inconsistente
- atomicidade das operações entre planilhas
- rollback inexistente ou insuficiente
- dependência de validação na interface
- fragilidade por proteção/desproteção de abas
- riscos de duplicidade, persistência residual e leituras imprecisas
- riscos nas contagens, identificadores, ordem de fila e consistência entre abas

Quero que você identifique:

- onde o sistema pode corromper estado
- onde o sistema pode aceitar operação inválida
- onde o sistema pode falhar silenciosamente
- onde a auditoria atual não está cobrindo um risco real

### 3. Regras de negócio

Mapeie as regras de negócio reais do sistema, e para cada uma informe:

- regra
- onde está implementada
- se está em serviço, repositório, interface ou distribuída
- se a implementação está adequada
- se a validação é completa
- se a regra está sendo testada pela bateria V1
- se a regra está sendo testada pela bateria V2
- lacuna atual
- prioridade de correção

Dê atenção máxima a:

- rodízio
- filtros de aptidão
- recusa e expiração
- suspensão e reativação
- integridade entre Pré-OS, OS e Avaliação
- divergência entre orçado e executado
- dependências de entidade, atividade, serviço, quantidade, datas e justificativas

### 4. Auditoria documental completa

Você deve validar a aderência entre:

- código
- documentação viva
- releases
- auditorias anteriores
- matriz de testes

Quero que você aponte:

- documentos corretos e aderentes
- documentos parcialmente corretos
- documentos defasados
- documentos contraditórios entre si
- documentação que precisa ser substituída

### 5. Auditoria complementar substitutiva da V166

Produza uma auditoria complementar robusta, capaz de substituir a referência antiga da `V12.0.0166`.

Essa nova auditoria deve:

- refletir o estado real atual
- incorporar a bateria V1 e a V2
- considerar a migração UI -> serviço
- considerar análise combinatória
- considerar testes automáticos, assistidos, smoke, regressão, determinístico e stress
- ser tecnicamente utilizável para aprovação de desenvolvimento

### 6. Análise comparativa V1 x V2

Faça uma comparação profunda entre a bateria antiga e a nova.

Quero que você diga:

- o que a V1 faz melhor
- o que a V2 faz melhor
- o que a V2 ainda não provou
- o que a V1 cobre e a V2 perdeu
- o que a V2 tornou mais auditável
- se já existe base para aposentadoria da V1
- o que falta para a V2 substituir a V1 com segurança

### 7. Análise combinatória

Valide a análise combinatória dos testes de forma séria, não superficial.

Quero que você:

- identifique fatores combinatórios reais
- proponha classes de equivalência
- proponha cenários de pares, tríades e combinações críticas
- diga o que é inviável testar exaustivamente
- diga o que é obrigatório cobrir
- proponha uma matriz combinatória segura e operacional

Você deve considerar pelo menos:

- status de empresa
- status de credenciamento
- estado da fila
- existência de Pré-OS
- existência de OS
- situação da atividade
- entidade válida/inválida
- quantidade válida/inválida
- datas válidas/inválidas
- avaliação válida/inválida
- suspensão e reativação
- divergência com e sem justificativa
- persistência residual no workbook

### 8. Proposta de baterias complementares

Proponha baterias complementares para elevar a segurança do sistema.

Separe em:

- smoke
- regressão funcional
- determinístico estrutural
- assistido humano
- stress
- consistência / integridade / auditoria
- migração UI -> serviço

Para cada bateria proposta, diga:

- objetivo
- pré-condição
- o que precisa existir no cenário
- o que deve ser executado
- o que deve ser validado
- o que falha se houver regressão
- prioridade

### 9. Diagnóstico específico das falhas atuais da V2

Analise profundamente o motivo do fatal atual da V2.

Você deve responder objetivamente:

- a falha atual é de reset, contagem, cenário ou regra?
- a contagem da V2 está tecnicamente correta?
- a bateria legada já resolveu esse problema de forma melhor?
- qual desenho deve ser adotado na V2 para evitar falso positivo?
- quais mudanças mínimas e quais mudanças ideais devem ser feitas?

### 10. Backlog técnico priorizado

Ao final, monte um backlog em ordem estrita de execução:

- bloqueadores de estabilização
- correções estruturais
- migrações UI -> serviço
- melhorias de teste
- melhorias de documentação
- melhorias opcionais

Para cada item, classifique:

- criticidade
- impacto
- risco
- esforço
- dependências

## Formato obrigatório de saída

Entregue exatamente os seguintes blocos, em documentos completos e objetivos:

1. `Relatório Executivo`
2. `Auditoria Técnica do Código`
3. `Matriz de Regras de Negócio`
4. `Auditoria de Segurança e Integridade`
5. `Análise Comparativa V1 x V2`
6. `Análise Combinatória e Cobertura`
7. `Plano de Baterias Complementares`
8. `Auditoria Complementar Substitutiva da V166`
9. `Backlog Priorizado para a Próxima Estabilização`
10. `Prompt Objetivo para Codex executar a próxima fase`

## Regras de qualidade da sua resposta

- não seja genérico
- não invente cobertura inexistente
- não trate hipótese como fato sem sinalizar
- separe claramente:
  - fatos confirmados pelo código
  - inferências plausíveis
  - pontos ainda incertos
- cite arquivos e linhas sempre que possível
- privilegie a realidade do código sobre a intenção da documentação
- se encontrar contradição entre documento e código, priorize o código e registre a divergência
- não proponha “reescrever tudo”
- proponha uma trilha evolutiva segura, incremental e operacional

## Critério de sucesso

Sua resposta deve permitir que outro agente pegue o bastão e implemente a próxima estabilização com baixo risco, alta rastreabilidade e alta chance de aprovação.
