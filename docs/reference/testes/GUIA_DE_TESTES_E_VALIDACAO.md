---
titulo: Guia de Testes e Validacao
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-08
---

# Guia de Testes e Validacao

Este guia padroniza os nomes operacionais das baterias de teste da linha
V12.0.0206. Os nomes antigos por quantidade de suites ficam preservados apenas
como identificadores internos de macros e evidencias historicas.

## Nomes Operacionais

| Nome operacional | Macro principal | Escopo | Quando rodar | Tempo observado |
|---|---|---|---|---|
| Sanidade Operacional V1 | `BO_RodarBateriaOficial` | bateria oficial rapida, regras basicas e rastreabilidade | smoke manual ou antes de checkpoint | cerca de 2 a 5 min |
| Verificacao Rapida V2 | `TV2_RunSmoke` | smoke automatizado V2 | apos mudanca pequena de codigo compartilhado | cerca de 30 s |
| Regressao Funcional Canonica | `TV2_RunCanonicoFundacao` | cenarios canonicos de negocio | apos mudanca em regra de negocio | cerca de 10 min |
| Fluxo Critico de Rodizio e Strikes | `TV2_RunRodizioStrikesEndToEnd` | rodizio, strikes, suspensao e retorno | apos mudanca em `Svc_Rodizio`, `Svc_Avaliacao` ou CONFIG | alto, rodar por checkpoint |
| Integridade de Base | `TV2_RunIntegridadeBase` | sanidade estrutural de dados | antes de validacao completa | medio |
| Cenarios Adversariais | `TV2_RunAdversarial_UI`, `TV2_RunTransaction_Interrupt`, `TV2_RunBoundary_Dates` | UI, transacao interrompida e datas de borda | checkpoint de estabilidade | medio |
| Impressao Residual | `TV2_RunImpressaoResidual` | regressao de impressao e template | apos mudanca visual ou de preenchimento | curto |
| Punicoes em Dias | `TV2_RunPunicoesDias` | suspensao por nota, recusa e prazo em dias | apos mudanca em punicoes ou relatorios de status | curto |
| Tela Inicial | `TV2_RunTelaInicial` | entrada do sistema, atalhos institucionais, menu lateral, Central, Sair e X | validacao dirigida desta tela | curto |
| Configuracoes Iniciais | `TV2_RunTelaConfiguracoesIniciais` | campo editavel, persistencia, ajuda, botoes, atalhos de menu, rotas laterais e fechamento seguro | validacao dirigida desta tela | curto |
| Cenarios de Configuracao e Novo Periodo | `TV2_RunConfigCenariosNovoPeriodo` | matriz destrutiva de persistencia, consumo por regras, copia da planilha e CSV | homologacao controlada apos mudanca em CONFIG ou Novo Periodo | curto a medio |
| Relatorios Tela a Tela | `TV2_RunTelaRelatorios` | status da empresa, disponibilidade, datas de suspensao, nome do servico, formatacao e limpeza da aba temporaria | validacao dirigida dos relatorios | curto |
| Relatorios Suspensoes e Strikes | `TV2_RunRelatoriosSuspensoesStrikesReset` | status normalizado, disponibilidade operacional, strikes por nota baixa, strikes por recusa/prazo, avisos em impressos e contrato de reset | apos mudanca em relatorios, suspensoes ou reset de periodo/base | curto |
| Validacao Completa da Release (VCR) | `CT_ValidarRelease_Completa` | todas as suites oficiais de liberacao | checkpoint forte e pre-release | mais de 1 h no fluxo atual |

## Regra de Nomenclatura

VCR significa **Validacao Completa da Release**. A sigla antiga RVS nao deve ser
usada em novas telas, prompts operacionais ou mensagens ao operador. Quando
aparecer em evidencias antigas, deve ser lida como identificador historico.

CSV nao e nome de teste nem nome de gate. `.csv` e apenas o formato de arquivo
usado para evidencias exportadas.

## Cadencia Recomendada

Para desenvolvimento tela a tela:

1. Importar delta pelo Importador V3.
2. Compilar no VBE.
3. Rodar o teste dirigido da tela ou da regra afetada.
4. Executar smoke V2 quando a mudanca tocar codigo compartilhado.
5. Rodar a VCR apenas em checkpoint forte, antes de fechar lote, antes de
   mudanca de bastao ou antes de declarar estabilidade de release.

Essa cadencia evita gastar mais de uma hora em cada microajuste e ainda mantem
rastreabilidade: cada tela ganha teste proprio e a VCR confirma o conjunto em
momentos de maior risco.

## Evidencias

Toda execucao de VCR deve registrar:

- ID da validacao;
- build importado;
- resultado APROVADO ou REPROVADO;
- sintaxe agregada das suites;
- arquivo `.csv` de evidencia, quando exportado;
- primeira falha e acao de correcao quando houver reprovacao.

Para testes dirigidos, a evidencia minima e o ID `TV2_...`, o total OK/FALHA e
o CSV de falhas quando a suite reprovar.

## Tela Inicial

A validacao dirigida desta tela cobre:

- entradas canonicas `Auto_Open`, `IniciarSistema`, `AbrirMenu` e shape visual;
- processos disparados na abertura no escopo da tela: carga CNAE, backfill e
  abertura do `Menu_Principal`;
- delegacao da protecao critica de abertura para a suite dedicada
  `TV2_RunBL4ProtecaoPersistente`;
- inicializacao do `Menu_Principal` na pagina 0;
- comando Inicio e estado visual esperado;
- conteudo minimo do Sobre com dados de `App_Release`;
- GitHub com fallback Mac/Windows/hyperlink;
- Central de Testes com aviso de treinamento e opcoes principais;
- abertura modal de Configuracoes Iniciais;
- rotas laterais principais;
- contrato do comando Sair com confirmacao e sem save automatico;
- ausencia de bloqueio customizado no fechamento pelo X.

Central de Testes e Sair nao devem ser acionados automaticamente pelo teste
dirigido. Eles sao cobertos por contrato estatico e validacao manual segura
quando necessario.

## Configuracoes Iniciais

A validacao dirigida desta tela cobre:

- campo de dias por recusa/prazo editavel e sem sobreposicao;
- persistencia em `DIAS_SUSPENSAO_RECUSA_PRAZO`;
- disponibilidade do botao Ajuda e do HTML HBN;
- handlers dos botoes Ajuda, Salvar Parametros, Iniciar Novo Periodo e Limpar Base;
- confirmacoes e delegacoes seguras para fluxos administrativos;
- atalhos do menu inicial para Configuracoes Iniciais, Central de Testes, Sobre e GitHub;
- rotas laterais principais do sistema;
- ausencia de bloqueio customizado no fechamento pelo X.

Fluxos destrutivos nao devem ser executados automaticamente pelo teste dirigido
de tela `TV2_RunTelaConfiguracoesIniciais`. Eles sao cobertos por contrato
estatico, caminho de confirmacao e validacao manual controlada quando
necessario.

## Cenarios de Configuracao e Novo Periodo

A suite `TV2_RunConfigCenariosNovoPeriodo` e uma excecao operacional
autorizada pelo hearback 0160. Ela e destrutiva por desenho, deve ser rodada
somente em base de homologacao e registra aviso antes de preparar cenarios
deterministicos e idempotentes.

A suite cobre:

- existencia dos controles de gestor, municipio, prazo de Pre-OS, recusas,
  dias de suspensao por recusa/prazo, nota de corte, strikes e dias de
  suspensao por nota;
- round-trip pela UI com todos os numericos em `1`;
- round-trip pela UI com todos os numericos em `2`;
- gestor e municipio contendo o build `293e44c+ONDA38.2.30-CONFIG-CENARIOS-CSV`;
- consumo da configuracao por recusa/prazo com suspensao de 1 dia;
- consumo da configuracao por nota/strike com duas notas 1, corte 2 e suspensao
  de 2 dias;
- criacao da pasta `V12-0-0206-Onda-38-2-30`;
- copia da planilha antes da limpeza;
- limpeza deterministica de `PRE_OS` e `CAD_OS` para iniciar Novo Periodo;
- gravacao de `TesteV2_CONFIG_CENARIOS_<execucao>.csv` na mesma pasta.

Desde o fix1 0161, a limpeza de Novo Periodo cobre a extensao real dos schemas
de `PRE_OS` e `CAD_OS`, e a validacao pos-limpeza conta registros pela
coluna-chave. Assim, residuos tecnicos em colunas auxiliares nao viram falso
registro operacional, e residuos reais com ID continuam reprovando o teste.

O CSV e a evidencia humana provisoria enquanto nao existe gerador de PDF para
este fluxo. Ele deve deixar visiveis a ordem do cenario, a posicao na fila, os
campos persistidos, valores esperados, valores observados, resultado e caminhos
da pasta/copia/CSV.

## Relatorios Tela a Tela

A suite `TV2_RunTelaRelatorios` cobre a revisao dirigida dos relatorios. Ela
nao imprime automaticamente e nao altera a base; valida contratos estruturais
do pacote fonte e importavel.

A suite cobre:

- helpers publicos de status humano, suspensao, reativacao e disponibilidade
  operacional;
- Empresa Credenciada por Servico com nome da atividade/servico e status da
  empresa;
- OS por Empresa com resumo de status, suspensa desde, suspensa ate, retorno e
  ultima reativacao;
- Entidades Cadastradas com formatacao padrao de relatorio;
- Empresas Cadastradas com status, datas de suspensao, ultima reativacao,
  strikes e resumo operacional;
- Empresas Credenciadas com status de credenciamento, status global e
  disponibilidade atual;
- OS Abertas com status, datas de suspensao, disponibilidade e strikes por
  empresa;
- Pre-OS Vencidas com status, datas de suspensao, disponibilidade e strikes por
  empresa;
- contrato de Pre-OS Vencidas como relatorio informativo: imprime pendencias
  vencidas sem chamar expiracao, recusa ou avanco de fila;
- limpeza da aba temporaria `RELATORIO` e da area de impressao em caminhos de
  sucesso, falta de dados e erro;
- diagnostico de Status do Rodizio por Servico com empresas suspensas e proximo
  retorno.

Resultado esperado apos import/compile:

```text
TV2_RunTelaRelatorios
OK=11 | FALHA=0 | MANUAL=0
```

Quando houver falha, anexar o CSV de falhas e nao rodar VCR nesse microdelta.

## Relatorios Suspensoes e Strikes

A suite `TV2_RunRelatoriosSuspensoesStrikesReset` complementa a revisao tela a
tela. Ela nao imprime automaticamente e nao executa fluxos destrutivos; valida o
contrato estrutural que deve ser conferido depois pelo operador nos PDFs.

A suite cobre:

- helpers de strikes por nota baixa e por recusa/prazo;
- helpers de disponibilidade operacional por atividade, incluindo OS em
  execucao e Pre-OS pendente;
- fallback de auditoria para empresa que continua suspensa apos Novo Periodo;
- Empresas Cadastradas e Empresas Credenciadas com colunas de strikes e
  resumo operacional;
- OS Abertas ignorando linhas sem N.O.S. real ou N.O.S. zero;
- Pre-OS Vencidas com status, disponibilidade, strikes e resumo operacional;
- Empresas Credenciadas por Servico com nome do servico, status,
  disponibilidade, strikes e resumo operacional;
- OS por Empresa com resumo superior de status, retorno, disponibilidade,
  strikes e resumo operacional;
- `Status da empresa nesta data` em impressos de Pre-OS, OS e avaliacao;
- `C16` limpo nos impressos, evitando frase comprimida no cabecalho;
- aviso operacional no corpo de Pre-OS/OS em `B24`, com `WrapText` e sem
  `ShrinkToFit`;
- diagnostico completo da avaliacao preservado em `B40` Observacoes;
- limpeza de `B24` em `LimparOS` e `LimparPREOS` para evitar residuo entre
  impressoes sucessivas;
- disponibilidade composta sob suspensao, mostrando `OS EM EXECUCAO` ou
  `PRE-OS PENDENTE` como complemento sem liberar a empresa para rodizio;
- contrato de Novo Periodo: limpa `PRE_OS`/`CAD_OS`, preserva cadastros,
  configuracao e auditoria, portanto preserva suspensoes;
- contrato de Limpar Base: apaga empresas, credenciamentos, operacao e
  auditoria, portanto remove suspensoes anteriores para novo municipio.

Resultado esperado apos import/compile:

```text
TV2_RunRelatoriosSuspensoesStrikesReset
OK=14 | FALHA=0 | MANUAL=0
```
