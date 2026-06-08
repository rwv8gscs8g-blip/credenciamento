---
titulo: Onda 38.2.29 — Tela Inicial Menu Principal
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-07
---

# 0159 — Tela Inicial / Menu Principal

## Objetivo

Documentar e validar a Tela Inicial como ponto de entrada do sistema,
cobrindo comandos, persistencia indireta, impactos operacionais, processos
disparados, mensagens e rotas ligadas ao `Menu_Principal`.

## Classificacao HBN

Nao ha defeito de designer confirmado nesta onda. A classificacao aplicada e
**cobertura de comportamento/contrato**:

- sem alteracao em `Menu_Principal.frm` ou `.frx`;
- sem alteracao em `Auto_Open.bas`;
- sem execucao automatizada de Central de Testes, Sair ou fluxos destrutivos;
- validacao por teste V2 dirigido e mapa documental.

### Fix1 apos gate humano

Mauricio importou o primeiro pacote da 0159 com `M=3 | F=0 | err=0 | skip=0`
e compilou limpo, mas `TV2_RunTelaInicial` retornou `OK=12 | FALHA=2 |
MANUAL=0` em `TV2_20260607_094429`. As duas falhas eram `TELAINI_02` e
`TELAINI_03`, ambas por tokens de BL4/`Auto_Open` ausentes no VBE.

A causa nao foi comportamento da Tela Inicial: o teste estava exigindo
contratos de `Auto_Open.bas`, modulo explicitamente fora do delta 0159. O Fix1
mantem `Auto_Open` fora do pacote e ajusta a suite para:

- validar em `TELAINI_02` apenas CNAE, backfill e abertura do `Menu_Principal`;
- validar em `TELAINI_03_PROTECAO_DELEGADA_BL4` que a cobertura de protecao de
  abertura segue delegada a `TV2_RunBL4ProtecaoPersistente`;
- preservar o total de 14 asserts sem acionar VCR, Central, Sair ou fluxos
  destrutivos.

Se aparecer problema de geometria, sobreposicao, alinhamento, tab order,
tamanho de campo ou texto, a correcao deve ser planejada em novo readback de
designer/export. Se aparecer problema de regra, persistencia ou handler, abrir
novo readback de codigo com teste V2 dirigido.

## Comportamento da Tela Inicial

A Tela Inicial e a pagina `0` do `Menu_Principal`. Ela abre por tres entradas:

| Entrada | Comportamento |
|---|---|
| `Auto_Open` | chamado ao abrir o workbook |
| `IniciarSistema` | macro manual/atalho operacional |
| shape `UX_BTN_INICIAR_SISTEMA` | botao visual da planilha com `OnAction=IniciarSistema` |

Na linha de fonte, o inicializador executa:

1. reaplicacao de protecao critica;
2. gravacao de marcadores HBN ocultos no workbook;
3. carga inicial CNAE se `ATIVIDADES` estiver vazia;
4. salvamento seguro apenas se CNAE for importado;
5. diagnostico de backfill `DT_ULT_REATIV`;
6. reaproveitamento ou criacao do `Menu_Principal`.

O gate 0159 nao reimporta `Auto_Open.bas`; por isso a validacao automatizada da
Tela Inicial cobre apenas os contratos seguros do escopo importado e aponta a
protecao de abertura para a suite BL4 dedicada.

## Comandos e Impactos

| Comando | Processo disparado | Salva automaticamente? | Impacto |
|---|---|---:|---|
| Inicio | `PAGINAS.Value = 0` | nao | navegacao visual |
| Sobre | `MsgBox` com `App_Release` | nao | informativo |
| GitHub | `Shell open`/fallback hyperlink | nao | abre navegador externo |
| Central de Testes | confirma treinamento, recolhe menu, abre `CT_AbrirCentral` | depende da opcao escolhida depois | pode alterar dados se confirmado |
| Configuracoes Iniciais | abre `Configuracao_Inicial` modal | nao neste handler | parametros sao tratados pela tela modal |
| Menu lateral | troca paginas 1..7 | depende da pagina | carrega listas, filtros e operacoes de cada area |
| Sair | confirma, mostra progress bar, fecha sem save | nao | edicoes nao salvas podem ser descartadas |
| X | fechamento padrao do UserForm | nao | sem bloqueio customizado |

## Teste V2 Criado

Foi adicionada a suite `TV2_RunTelaInicial`, com 14 cenarios:

| Cenario | Cobre |
|---|---|
| `TELAINI_01_ENTRADAS_CANONICAS` | `Auto_Open`, `IniciarSistema`, `AbrirMenu` |
| `TELAINI_02_PROCESSOS_DE_ABERTURA` | CNAE, backfill e abertura do menu |
| `TELAINI_03_PROTECAO_DELEGADA_BL4` | cobertura BL4 dedicada para protecao de abertura |
| `TELAINI_04_ATALHO_VISUAL_INICIAR` | shape visual e `OnAction` |
| `TELAINI_05_INICIALIZACAO_PAGINA_ZERO` | `UserForm_Initialize` e pagina inicial |
| `TELAINI_06_HOME_ESTADO_VISUAL` | Home volta para `PAGINAS=0` |
| `TELAINI_07_SOBRE_RELEASE_REGRA` | mensagem Sobre e `App_Release` |
| `TELAINI_08_GITHUB_FALLBACK_URL` | GitHub e fallback Mac/Windows/hyperlink |
| `TELAINI_09_CENTRAL_TESTES_GUARD` | aviso/confirmacao de treinamento |
| `TELAINI_10_CENTRAL_OPCOES` | VCR, Central V2 e Bateria Oficial |
| `TELAINI_11_CONFIGURACOES_MODAL` | abertura modal de Configuracoes Iniciais |
| `TELAINI_12_ROTAS_LATERAIS` | paginas 1..7 do menu lateral |
| `TELAINI_13_SAIR_CONFIRMA_SEM_SAVE` | Sair com confirmacao e sem save automatico |
| `TELAINI_14_X_NAO_BLOQUEADO` | ausencia de `QueryClose` bloqueando X |

## Mapa de Cobertura

| Ponto descrito | Cobertura 0159 | Observacao |
|---|---|---|
| Entrada pelo workbook | `TELAINI_01`, `TELAINI_02` | contrato estatico; Auto_Open nao foi tocado |
| Entrada pelo shape | `TELAINI_04` | tambem coberto por `TV2_RunUXIniciarSistemaCodeOnly` |
| Protecao na abertura | `TELAINI_03_PROTECAO_DELEGADA_BL4` | BL4 continua como suite comportamental especifica |
| Carga CNAE | `TELAINI_02` | nao importa CNAE durante esta suite |
| Backfill `DT_ULT_REATIV` | `TELAINI_02` | `MIG_005` segue cobrindo comportamento de migracao |
| Tela inicial pagina 0 | `TELAINI_05`, `TELAINI_06` | contrato de inicializacao e Home |
| Sobre | `TELAINI_07` | sem exibir MsgBox no teste |
| GitHub | `TELAINI_08` | sem abrir navegador no teste |
| Central de Testes | `TELAINI_09`, `TELAINI_10` | sem confirmar treinamento no teste |
| Configuracoes Iniciais | `TELAINI_11` | 0158 cobre a tela modal |
| Menu lateral | `TELAINI_12` | sem navegar por clique real |
| Sair | `TELAINI_13` | sem fechar workbook no teste |
| X | `TELAINI_14` | ausencia de bloqueio customizado |

## Arquivos Alterados

- `src/vba/Teste_V2_Roteiros.bas`
- `src/vba/Teste_V2_Engine.bas`
- `src/vba/App_Release.bas`
- `docs/tutorials/MANUAL_OPERACIONAL_TELA_A_TELA.md`
- `docs/reference/testes/GUIA_DE_TESTES_E_VALIDACAO.md`
- artefatos HBN e espelhos em `local-ai/vba_import/`

## Gate Esperado

1. Importar o delta V3 da 0159.
2. Compilar o VBAProject no VBE.
3. Rodar `TV2_RunTelaInicial`.
4. Esperado: `OK=14 | FALHA=0 | MANUAL=0`.
5. Nao rodar VCR neste microdelta.
