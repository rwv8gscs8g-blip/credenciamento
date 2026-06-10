---
titulo: Manual Operacional Tela a Tela
diataxis: tutorial
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0205
data: 2026-06-08
---

# Manual Operacional Tela a Tela

Este manual sera ampliado conforme cada tela for validada. A Tela Inicial e o
ponto de entrada do operador; Configuracoes Iniciais define os parametros do
rodizio, das recusas, dos prazos e das punicoes por nota; Relatorios mostra o
estado operacional consolidado para conferencia humana.

## Tela Inicial

### Finalidade

A Tela Inicial e a pagina de entrada do `Menu_Principal`. Ela centraliza os
atalhos institucionais, a entrada em Configuracoes Iniciais, a Central de Testes
e as rotas laterais do sistema. Ela nao e um cadastro proprio.

### Como Abre

| Entrada | Comportamento |
|---|---|
| Abertura do workbook | chama `Auto_Open`, reaplica protecoes criticas e abre o `Menu_Principal` |
| Macro `IniciarSistema` | executa o mesmo inicializador usado na abertura |
| Botao visual Iniciar Sistema | shape da planilha com `OnAction=IniciarSistema` |

Durante a abertura, a protecao critica segue coberta pela validacao BL4
dedicada. No fluxo da Tela Inicial, o sistema tenta carga inicial de CNAE se a
aba `ATIVIDADES` estiver vazia, verifica pendencias de backfill de
`DT_ULT_REATIV` e entao mostra o menu. A abertura em si nao salva parametros de
negocio; o salvamento automatico so ocorre se a carga CNAE importar registros
estruturais.

### Comandos

| Comando | O que faz | Persistencia/impacto |
|---|---|---|
| Inicio | volta para a pagina inicial (`PAGINAS=0`) | sem salvamento |
| Sobre | mostra release, build, autoria, licenca e objetivo do rodizio | sem salvamento |
| GitHub | abre o repositorio oficial ou mostra URL para acesso manual | abre navegador externo |
| Central de Testes | avisa que treinamento altera dados reais e pede confirmacao | pode disparar testes/treinamento se confirmado |
| Configuracoes Iniciais | abre a tela `Configuracao_Inicial` em modo modal | parametros sao salvos apenas dentro daquela tela |
| Menu lateral | navega para cadastros, rodizio, OS, avaliacao, servicos e relatorios | cada pagina pode carregar listas/filtros |
| Sair | pergunta antes de fechar e fecha sem salvar automaticamente | edicoes nao salvas podem ser descartadas |
| X da janela | usa fechamento padrao do formulario | sem handler customizado de bloqueio |

### Fluxo Operacional

1. Abrir o workbook ou clicar em Iniciar Sistema.
2. Aguardar o Menu Principal aparecer na Tela Inicial.
3. Conferir versao e build pelo botao Sobre quando necessario.
4. Usar Configuracoes Iniciais para parametros de negocio.
5. Usar o menu lateral para cadastros, rodizio, emissao, avaliacao, servicos e
   relatorios.
6. Entrar na Central de Testes somente em base apropriada e apos confirmar o
   aviso de treinamento.
7. Salvar manualmente o workbook antes de Sair quando quiser preservar edicoes
   ainda nao salvas.

### Criterios de Aprovacao da Tela

A Tela Inicial esta aprovada quando:

- `Auto_Open`, `IniciarSistema` e o shape visual convergem para o mesmo fluxo;
- a abertura preserva protecao critica, carga CNAE e diagnostico de backfill;
- a pagina inicial carrega como `PAGINAS=0`;
- Sobre, GitHub, Central de Testes e Configuracoes Iniciais continuam ligados
  aos handlers esperados;
- a Central de Testes exige confirmacao antes do fluxo de treinamento;
- o menu lateral preserva as rotas principais;
- Sair confirma fechamento e nao salva automaticamente;
- o X nao esta bloqueado por `QueryClose` customizado;
- `TV2_RunTelaInicial` retorna sem falhas.

## Configuracoes Iniciais

### Finalidade

A tela Configuracoes Iniciais define os parametros gerais do sistema e as regras
que afetam diretamente o rodizio. Os valores salvos nessa tela sao consumidos
por rotinas de Pre-OS, avaliacao, suspensao e retorno de empresas ao rodizio.

### Campos

| Campo | O que significa | Regra operacional |
|---|---|---|
| Area Gestora do Rodizio | orgao ou area responsavel pela operacao | texto institucional exibido em telas e documentos |
| Municipio | municipio da gestao | texto institucional exibido em telas e documentos |
| Prazo de Validade Pre-OS | quantidade de dias para resposta da Pre-OS | deve ser inteiro de 1 a 3650 |
| Apos N recusa(s) ou expiracao de prazo, suspender por N dia(s) | limite de recusas/prazos vencidos e dias de suspensao | ambos devem ser inteiros positivos; a suspensao e medida em dias |
| Nota abaixo de | nota minima que gera strike | aceita nota de 0 a 10 conforme validacao da regra |
| Apos N strike(s), suspender por N dia(s) | quantidade de strikes e dias de suspensao por nota | ambos devem ser inteiros positivos; a suspensao e medida em dias |

### Botoes

| Botao | Acao |
|---|---|
| Ajuda | abre a pagina HBN de ajuda desta tela |
| Iniciar Novo Periodo | executa o fluxo de novo periodo conforme regra existente |
| Limpar Base | executa limpeza administrativa controlada |
| Salvar Parametros | valida e grava os campos na aba CONFIG |

### Novo Periodo Versus Limpar Base

`Iniciar Novo Periodo` e o fluxo de passagem de exercicio. Ele cria a pasta e a
copia da planilha, limpa `PRE_OS` e `CAD_OS` e zera os contadores AR dessas
abas. Ele preserva `EMPRESAS`, `CREDENCIADOS`, `CONFIG` e `AUDIT_LOG`; por isso
uma empresa suspensa continua suspensa no novo periodo.

`Limpar Base` e o fluxo para recomecar a operacao em outro municipio ou em base
administrativa limpa. Ele apaga cadastros, credenciamentos, `PRE_OS`, `CAD_OS`,
`AUDIT_LOG` e a aba temporaria de relatorio, preservando apenas `ATIVIDADES`
(CNAE) e `CONFIG`. Como a empresa e a trilha operacional sao apagadas, nenhuma
suspensao anterior deve permanecer.

Uma empresa suspensa deixa de ficar suspensa quando o prazo final vence e o
rodizio tenta seleciona-la novamente, pois o motor reativa automaticamente se
`DT_FIM_SUSP` for menor ou igual a data atual. Tambem pode haver reativacao por
fluxo manual proprio de reativacao. Zerar strikes no inicio de um novo periodo
nao deve ser confundido com reativar empresa suspensa; essa anistia precisa de
opcao propria e ainda nao faz parte da interface.

### Entradas, Saidas e Menus

| Origem | Comportamento esperado |
|---|---|
| Menu inicial > Configuracoes Iniciais | abre a tela Configuracoes Iniciais em modo modal |
| Menu inicial > Sobre | mostra informacoes de release, build e autoria |
| Menu inicial > GitHub | abre o repositorio oficial ou informa o link para acesso manual |
| Menu inicial > Central de Testes | abre a Central de Testes apos confirmacao de uso quando aplicavel |
| Menu lateral | preserva rotas de Inicio, cadastros, rodizio, impressao, avaliacao, servicos, relatorios e sair |
| X da janela | fecha a tela sem handler customizado que bloqueie a saida |

### Como Operar

1. Conferir Area Gestora e Municipio.
2. Informar o prazo da Pre-OS em dias.
3. Informar o limite de recusas ou expiracao de prazo.
4. Informar por quantos dias a empresa fica suspensa ao atingir esse limite.
5. Informar nota minima, limite de strikes e dias de suspensao por strike.
6. Clicar em Salvar Parametros.
7. Reabrir a tela em caso de duvida e conferir se os valores persistiram.

### Criterios de Aprovacao da Tela

A tela Configuracoes Iniciais esta aprovada quando:

- o campo de dias por recusa/prazo esta editavel;
- os dias por recusa/prazo persistem na CONFIG;
- a interface fala sempre em dias para recusa/prazo e para strikes;
- o botao Ajuda abre a documentacao HBN;
- os botoes Salvar Parametros, Iniciar Novo Periodo e Limpar Base tem handlers
  rastreaveis;
- os atalhos do menu inicial para Sobre, GitHub, Central de Testes e
  Configuracoes Iniciais continuam ligados aos handlers esperados;
- fluxos destrutivos como Limpar Base e Iniciar Novo Periodo exigem confirmacao
  ou validacao dirigida destrutiva explicitamente autorizada em homologacao;
- `TV2_RunTelaConfiguracoesIniciais` retorna sem falhas;
- quando a 0160 for importada, `TV2_RunConfigCenariosNovoPeriodo` cria copia da
  planilha, limpa `PRE_OS`/`CAD_OS` e gera CSV de evidencia sem falhas;
- a VCR passa em checkpoint forte posterior.

### Validacao Destrutiva 0160

`TV2_RunConfigCenariosNovoPeriodo` e um mapa de testes de homologacao. Ele deve
ser tratado como destrutivo porque cria cenarios deterministicos, exercita
regras de negocio e inicia um Novo Periodo para limpar dados gerados durante a
propria suite. Quando rodada manualmente, a macro exibe aviso visual antes de
comecar; em modo silencioso, o aviso fica registrado no log V2 e no CSV.

Antes da limpeza, a macro cria a pasta `V12-0-0206-Onda-38-2-30` no caminho do
workbook e salva uma copia da planilha. Na mesma pasta, grava
`TesteV2_CONFIG_CENARIOS_<execucao>.csv`, contendo:

- numero e ordem do cenario;
- posicao ou resumo da fila quando houver rodizio;
- campo persistido;
- valor esperado e valor observado;
- regra exercitada;
- resultado do assert;
- caminho da pasta, da copia da planilha e do CSV.

Esse CSV substitui o PDF nesta onda. A leitura humana deve confirmar que os
campos de configuracao foram persistidos, que os servicos consumiram os valores
1 e 2 conforme o cenario, que a suspensao por recusa ficou em 1 dia, que a
suspensao por strike ficou em 2 dias e que o Novo Periodo deixou `PRE_OS` e
`CAD_OS` sem registros operacionais depois de salvar a copia. Desde o fix1
0161, a limpeza cobre as colunas finais atuais dos schemas dessas abas e a
validacao conta registros pela coluna-chave.

### Observacoes de Auditoria

O controle visual usado para dias por recusa/prazo tem nome tecnico legado
`TxtMesesSuspensao`. A semantica vigente, a interface e a persistencia agora
tratam esse campo como **dias de suspensao por recusa ou prazo vencido**. O nome
legado do controle nao deve orientar decisao de negocio.

## Relatorios

### Finalidade

A tela de Relatorios permite imprimir e conferir visoes operacionais do
credenciamento. Sempre que uma empresa aparece no relatorio, o operador deve
conseguir saber se ela esta ativa, suspensa ou inativa e se esta disponivel
para nova indicacao naquele momento.

### Relatorios e Campos Esperados

| Relatorio | O que deve mostrar |
|---|---|
| Entidades Cadastradas | tabela formatada com cabecalho, linhas alternadas e bordas |
| Empresas Cadastradas | dados cadastrais, status da empresa, suspensa desde, suspensa ate, ultima reativacao, strikes por nota baixa, strikes por recusa/prazo e resumo operacional |
| Empresas Credenciadas | atividade, servico, empresa, status do credenciamento, status da empresa, suspensao, disponibilidade atual, strikes e resumo operacional |
| Empresas Credenciadas por Servico | atividade, servico e codigo atividade/servico no topo; linhas com status da empresa, disponibilidade atual na atividade, strikes e resumo operacional |
| OS por Empresa | resumo superior da empresa com status, suspensao, dias restantes, retorno previsto, ultima reativacao, disponibilidade atual, strikes e resumo operacional |
| OS Abertas | OS abertas com empresa, status, suspensa desde, suspensa ate, disponibilidade atual, strikes e resumo operacional |
| Pre-OS Vencidas | Pre-OS vencidas com empresa, status, suspensa desde, suspensa ate, disponibilidade atual, strikes e resumo operacional |
| Status do Rodizio por Servico | consolidado tecnico por servico, empresas aptas/suspensas, proximo retorno e alerta |

### Como Interpretar Status

| Campo | Significado |
|---|---|
| Status Empresa | situacao global do cadastro: ativa, suspensa ou inativa |
| Suspensa Desde | data do ultimo evento de suspensao encontrado no `AUDIT_LOG`; se nao houver registro, aparece `SEM REGISTRO` |
| Suspensa Ate | data final prevista da suspensao; se nao houver data, aparece `INDEFINIDA` |
| Ultima Reativacao | data gravada em `DT_ULT_REATIV`; vazia quando nunca houve reativacao registrada |
| Disponibilidade Atual | leitura operacional na data do relatorio: `DISPONIVEL`, `SUSPENSA ATE dd/mm/aaaa`, `REATIVAVEL - PRAZO VENCIDO`, `OS EM EXECUCAO`, `PRE-OS PENDENTE`, `CREDENCIAMENTO INATIVO` ou equivalente. Quando uma empresa suspensa tambem esta ocupada na atividade, o texto pode ser composto, como `SUSPENSA ATE dd/mm/aaaa; OS EM EXECUCAO` ou `SUSPENSA ATE dd/mm/aaaa; PRE-OS PENDENTE` |
| Strikes Nota Baixa | quantidade de strikes derivados de avaliacoes abaixo da nota minima; quando o novo periodo preserva uma suspensao mas limpa `CAD_OS`, o relatorio pode usar o ultimo evento de suspensao por strike no `AUDIT_LOG` |
| Strikes Recusa/Prazo | quantidade atual de recusas ou expiracoes de prazo acumuladas no cadastro da empresa |
| Resumo Operacional | texto consolidado com status, disponibilidade, data final de suspensao e strikes |

Credenciamento ativo nao significa automaticamente empresa disponivel. Uma
empresa ativa pode aparecer como `PRE-OS PENDENTE` ou `OS EM EXECUCAO` quando
ja esta ocupada na mesma atividade.
Quando a empresa esta suspensa, a suspensao continua sendo o bloqueio
principal; o complemento `; OS EM EXECUCAO` ou `; PRE-OS PENDENTE` apenas revela
que existe ocupacao adicional na mesma atividade.

Nos documentos impressos de Pre-OS, OS e avaliacao, o sistema tambem deve
incluir aviso operacional em `C16`. Esse ponto e um resumo curto para leitura
visual, com status, disponibilidade e contadores `NB` e `RP`; ele nao deve
ficar espremido por `ShrinkToFit` nem com letras artificialmente espacadas por
alinhamento distribuido do template. Quando o documento possui campo de
observacoes, o diagnostico completo continua ali como complemento de auditoria.

### Relatorio de Pre-OS Vencidas

O relatorio de Pre-OS Vencidas e uma consulta operacional. Ele identifica
Pre-OS com status `AGUARDANDO_ACEITE` cujo prazo ja venceu e imprime a lista
para analise humana. Gerar ou imprimir esse relatorio nao expira a Pre-OS, nao
recusa a demanda e nao avanca a fila do rodizio.

O fluxo correto e:

1. Abrir Relatorios > Pre-OS Vencidas.
2. Conferir ou imprimir as pendencias vencidas.
3. Voltar para a tela de indicacao/Pre-OS.
4. Selecionar a Pre-OS vencida e executar a acao manual de expirar, quando
   essa for a decisao administrativa.
5. Emitir nova Pre-OS se a demanda ainda deve ser atendida por outro prestador.

Esse comportamento preserva auditoria: o relatorio mostra o problema, mas a
mutacao destrutiva continua dependendo de comando explicito do operador.

### Criterios de Aprovacao da Tela

A tela Relatorios esta aprovada quando:

- relatorios com empresas exibem status operacional e datas de suspensao;
- relatorios com empresas exibem strikes por nota baixa, strikes por
  recusa/prazo, disponibilidade atual e resumo operacional;
- Empresa Credenciada por Servico identifica o servico tratado no topo;
- Entidades, Empresas, OS e Pre-OS usam formatacao tabular consistente;
- Pre-OS Vencidas imprime pendencias vencidas sem expirar automaticamente,
  recusar ou avancar fila;
- a aba temporaria `RELATORIO` e limpa apos impressao, falta de dados ou erro;
- `TV2_RunTelaRelatorios` retorna sem falhas;
- `TV2_RunRelatoriosSuspensoesStrikesReset` retorna sem falhas;
- validacao visual humana dos relatorios principais nao encontra truncamento
  critico ou ausencia de status.
