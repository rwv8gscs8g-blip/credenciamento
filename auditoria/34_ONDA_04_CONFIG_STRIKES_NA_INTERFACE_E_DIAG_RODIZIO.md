---
titulo: ONDA 4 — Wire-up da regra de strikes na Configuracao_Inicial + diagnostico de rodizio
natureza-do-documento: documento tecnico de microevolucao com escopo, codigo, testes, gate e analise do bug do rodizio
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
branch: codex/v12-0-0203-governanca-testes
data: 2026-04-28
autor: Claude Opus 4.7 (sessao Cowork — executor)
solicitante: Luis Mauricio Junqueira Zanin
plano-mestre: auditoria/27_PLANO_ESTEIRA_OPUS_RELEASE_V203.md
documento-irmao-procedimento: auditoria/35_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_04.md
---

# 34. ONDA 4 — Wire-up da regra de strikes + Diagnostico de rodizio

## 00. Sintese

Fecha o ciclo da regra de strikes (iniciada na Onda 1) ligando os 3
campos do `Configuracao_Inicial.frm` ja criados no designer pelo
operador a aba `CONFIG`. Adiciona helper de diagnostico do rodizio
(`Diag_RodizioStatus`) para investigar pulos do rodizio em tempo real,
2 cenarios `CFG_001..002` e 2 opcoes novas na Central V2 (`[16]` e
`[17]`).

A onda nao toca em `Mod_Types.bas`, nao toca em `Audit_Log.bas`, nao
mexe no `.frx` (apenas no codigo dentro do `.frm`), nao usa o script
`publicar_vba_import.sh`, nao usa `Importador_VBA.bas`.

## 01. Diagnostico do "sem empresas disponiveis" reportado em 28/04

### 01.1 Cenario relatado

Apos rodar Onda 3 + V2 Canonica, operador cadastrou 3 empresas, emitiu
1 Pre-OS e tentou nova emissao na mesma atividade. Sistema respondeu
"Nao foi possivel emitir a Pre-OS: nao ha empresas disponiveis para
esta atividade." Isso impede testes manuais sucessivos.

### 01.2 Causa raiz mais provavel

O **estado do workbook esta contaminado pelo final da V2 Canonica**:

1. `TV2_PrepararCenarioTriploCanonico` reseta a base **antes** de cada
   cenario, mas nao **depois**. O ultimo cenario (CS_24) deixa a base
   no estado em que terminou.
2. Cenarios como `CS_14` (suspensao por nota baixa) e `CS_18`
   (transicoes invalidas de OS concluida) usam Empresa 002 e Empresa
   003 e podem deixa-las suspensas, com OS aberta ou com Pre-OS
   pendente que nao foram limpas.
3. Com a config canonica `MAX_STRIKES=1` + `DIAS_SUSPENSAO_STRIKE=0`,
   uma avaliacao com nota 4 suspende imediatamente por
   `PERIODO_SUSPENSAO_MESES=1` mes — empresa fica fora do rodizio
   por ate 30 dias.
4. Quando o operador cadastra "3 empresas novas" em cima dessa base,
   ou usa as proprias empresas canonicas remanescentes, alguma delas
   esta em FILTRO_A, FILTRO_B, FILTRO_D ou FILTRO_E.

### 01.3 Solucoes desta onda

- **`Diag_RodizioStatus(ATIV_ID)`**: roda em segundos, lista cada
  empresa credenciada e o motivo exato pelo qual cada uma esta sendo
  pulada. Permite resolver no minuto seguinte.
- **`[16] Diag rodizio` na Central V2**: atalho amigavel.
- **Solucao operacional imediata** (nao precisa instalar a Onda 4):
  abrir `Configuracao_Inicial > Limpar Base` (ja existente, ja
  preserva ATIVIDADES e CAD_SERV — `CNAE_006` provou) e cadastrar 3
  empresas manualmente.

## 02. Escopo

Entra:

- 3 helpers privados em `Configuracao_Inicial.frm`
  (`CI_BuscarTextBoxPorLabel`, `CI_TextoTextBoxPorLabel`,
  `CI_DefinirTextoTextBoxPorLabel`);
- ampliacao do `B_Parametros_Click`: leitura e gravacao das 3 colunas
  novas em CONFIG;
- ampliacao do `UserForm_Initialize`: popular os 3 textboxes com os
  valores atuais lidos via getters em `Util_Config`;
- helper publico `Diag_RodizioStatus(ATIV_ID)` em `Svc_Rodizio.bas`;
- helper publico `Diag_RodizioStatusInteractive()` em `Svc_Rodizio.bas`;
- nova suite `TV2_RunCfg` com cenarios `CFG_001..002`;
- 2 opcoes novas na Central V2: `[16]` e `[17]`.

Nao entra (vai para ondas seguintes):

- captura automatica do estado do workbook apos cada execucao da
  V2 Canonica (cleanup pos-suite);
- botao "Setup Manual: 3 empresas + 3 entidades + credenciamentos
  prontos" (helper de criacao rapida para teste manual);
- redesign visual da tela `Configuracao_Inicial.frm`.

## 03. Arquivos modificados

| Arquivo | Mudanca |
|---|---|
| `src/vba/App_Release.bas` | carimbo `f7aa84f+ONDA04-em-homologacao`, data `2026-04-28 06:30` |
| `src/vba/Svc_Rodizio.bas` | +`Diag_RodizioStatus`, +`Diag_RodizioStatusInteractive` |
| `src/vba/Configuracao_Inicial.frm` | `B_Parametros_Click` ampliado, `UserForm_Initialize` ampliado, +3 helpers heuristicos |
| `src/vba/Teste_V2_Roteiros.bas` | +`TV2_RunCfg` (`CFG_001..002`) |
| `src/vba/Central_Testes_V2.bas` | +opcoes `[16]` e `[17]`, +`CT2_ExecutarCfg` |
| `auditoria/34_ONDA_04_CONFIG_STRIKES_NA_INTERFACE_E_DIAG_RODIZIO.md` | este documento |
| `auditoria/35_PROCEDIMENTO_IMPORT_MANUAL_SEGURO_ONDA_04.md` | procedimento manual de import com cuidado especial para `.frm` |
| `CHANGELOG.md` | entrada `[Unreleased]` ampliada |
| `auditoria/INDEX.md` | indexa 34 e 35 |

**Nao tocados**: `Mod_Types.bas`, `Audit_Log.bas`, `Importador_VBA.bas`,
`Const_Colunas.bas`, `Preencher.bas`, `Util_Config.bas`, qualquer
`.frx`, qualquer `Repo_*.bas`, demais `Svc_*.bas`.

## 04. Heuristica de busca por Label adjacente

A logica nao depende do nome do TextBox criado no designer. Funciona
em 2 passos:

1. **Encontrar o Label**: itera sobre todos os controles do formulario,
   procura o primeiro `Label` cujo `Caption` (UCase) contenha a
   palavra-chave (ex.: `"AVALIA"`, `"MENORES"`, `"INABILITADA"`).
2. **Encontrar o TextBox vizinho**: dentre todos os `TextBox`, escolhe
   o que esta na **mesma linha** (diferenca de `Top` <= altura do
   Label) e mais proximo lateralmente da borda direita do Label.

Funciona com qualquer nome de TextBox que o operador tenha dado no
designer. So depende de:

- existir um Label com Caption contendo `"avalia"` (ex.: "avaliacoes");
- existir um Label com Caption contendo `"menores"` (ex.: "menores que");
- existir um Label com Caption contendo `"inabilitada"` ou `"dias"`.

Validacao defensiva: se nada for achado, o helper retorna string
vazia ou nao faz nada. **A configuracao atual em CONFIG nao e
sobrescrita por valor invalido** — campos vazios ou fora da faixa
preservam o valor anterior.

## 05. Faixas de validacao no `B_Parametros_Click`

| Coluna | Faixa permitida | Comportamento fora da faixa |
|---|---|---|
| `COL_CFG_NOTA_MINIMA` | (0, 10] | preserva valor anterior |
| `COL_CFG_MAX_STRIKES` | [1, 50] | preserva valor anterior |
| `COL_CFG_DIAS_SUSPENSAO_STRIKE` | [0, 3650] | preserva valor anterior |

`DIAS_SUSPENSAO_STRIKE = 0` aciona o fallback historico em meses
(`PERIODO_SUSPENSAO_MESES`) — ja documentado na Onda 1.

## 06. Cenarios `TV2_RunCfg`

| ID | Pre-condicao | Acao | Resultado esperado |
|---|---|---|---|
| `CFG_001` | CONFIG com `NOTA_MINIMA=5`, `MAX_STRIKES=3`, `DIAS_SUSPENSAO_STRIKE=90` | chamar os 3 getters em `Util_Config` | retornam exatamente os valores escritos |
| `CFG_002` | CONFIG com `NOTA_MINIMA=6`, `MAX_STRIKES=5`, `DIAS_SUSPENSAO_STRIKE=30` | chamar os 3 getters | retornam exatamente os novos valores |

Os cenarios fazem **backup do estado original e restauram ao final**,
para nao contaminar suites seguintes.

## 07. `Diag_RodizioStatus` em detalhe

### 07.1 Saida (aba `RPT_DIAG_RODIZIO`)

| Coluna | Conteudo |
|---|---|
| A | POSICAO na fila |
| B | EMP_ID |
| C | STATUS_CRED |
| D | STATUS_GLOBAL |
| E | DT_FIM_SUSP (formatada ou "(limpa)") |
| F | OS aberta? (SIM/nao) |
| G | Pre-OS pendente? (SIM/nao) |
| H | Decisao prevista (`APTA` / `FILTRO_A..E` / `SEM_EMPRESA` / `APTA_REATIVAVEL`) |
| I | Explicacao em texto livre |

### 07.2 Como usar para resolver "sem empresas disponiveis"

1. Reproduzir o erro na interface.
2. Sair do formulario sem fechar o workbook.
3. Central V2 → opcao `[16]` → informar o `ATIV_ID` (ex.: `001`).
4. Abrir `RPT_DIAG_RODIZIO`.
5. Olhar a coluna H: a decisao de cada empresa explica o pulo.
6. Coluna I: explicacao detalhada.

## 08. Riscos e mitigacoes

| Risco | Mitigacao |
|---|---|
| Heuristica nao achar TextBox certo | algoritmo procura mesma linha + mais proximo lateralmente; testado mentalmente contra a tela mostrada pelo operador (Labels "avaliacoes menores que", "inabilitada por (dias)" cercam os TextBoxes) |
| Operador apagar campo e zerar a config | validacao defensiva: faixa minima >= valor positivo; valor vazio NAO grava |
| `Diag_RodizioStatus` poluir o workbook com aba | aba `RPT_DIAG_RODIZIO` e reutilizada (limpa a cada chamada); operador apaga manualmente quando nao precisar mais |
| `Diag_RodizioStatus` chamar `LerEmpresa` em base contaminada | helper trata gracefully `linhaEmp = 0` (registra `SEM_EMPRESA`) |

## 09. Importacao da Onda 4 — cuidado especial com `.frm`

Esta onda toca o `Configuracao_Inicial.frm`. **A regra para `.frm` e
diferente da dos `.bas`**: o `.frm` referencia um `.frx` binario e a
sincronia entre os dois e crucial. **NAO use `File > Import`** para
o `Configuracao_Inicial.frm` — voce ja fez ajustes no `.frx` (3
TextBoxes novos) que nao estao no `src/vba/Configuracao_Inicial.frx`
do repositorio.

O caminho seguro esta em `auditoria/35`: editar **somente o codigo**
dentro do VBE, mantendo o designer atual intacto.

## 10. Decisoes de produto registradas

- regra de strikes ja entregue na Onda 1 e agora **configuravel via
  interface** na Onda 4;
- defaults na primeira abertura do formulario sao
  `MAX_STRIKES=3`, `NOTA_MINIMA=5.0`, `DIAS_SUSPENSAO_STRIKE=90`
  (vindo dos getters em `Util_Config`);
- bloqueio do salvamento por valor invalido **nao** entra nesta onda
  (a validacao apenas preserva o valor anterior);
- redesign visual do formulario fica para pos-V12.0.0203.

## 11. Proxima onda

Apos OK desta onda, sigo para a **ONDA 5** dedicada a fechar duas
fronteiras pendentes:
- helper "Setup Manual: cenario de teste limpo" para popular a base
  operacional com 3 empresas, 3 entidades e credenciamentos prontos
  (resolve a friccao da V2 Canonica deixar base contaminada);
- ou cenario E2E `CS_25_CREDENCIAMENTO_ENDtoEND` (PE-10 do parecer 25),
  conforme prioridade do Mauricio.
