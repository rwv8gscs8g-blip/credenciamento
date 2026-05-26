---
titulo: Auditoria Codex — V12.0.0206 estado atual
diataxis: explanation
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-26
---

# Auditoria Codex — V12.0.0206 estado atual

## 1. Escopo auditado

Auditoria read-only sobre a estabilizacao V12.0.0206, com foco nas tres ondas recentes:

- Onda 38.2.1, commit `e9bcf42`: revert forward-only dos filtros do `Menu_Principal`.
- Onda 38.2.1-AR1, commit `ffc8e8a` + hotfix `9592e0f` + fechamento `433f25c`: saneamento de contadores AR1.
- Onda 38.2.1-AR1-FIX2-PERF, commit `ee75b30` + fechamento `067f2dc`: ID monotonico e wrapper de performance LITE.

Estado local observado antes da auditoria:

- Raiz canonica: `/Users/macbookpro/Projetos/Credenciamento`.
- Branch: `codex/v12-0-0206-planejamento`.
- HEAD local observado: `8c03e34`, posterior ao `067f2dc` citado no prompt, por commits documentais da Onda 0110.
- Codigo `src/vba/` sem diff entre `ee75b30..HEAD`.
- Worktree tinha modificacao preexistente nao minha em `local-ai/vba_import/001-modulo/AAX-App_Release.bas`, coerente com BUMP do Importador V3 para `ad5b487+ONDA38.2.1-AR1-FIX2-PERF`; nao foi tocada nesta auditoria.

Arquivos de codigo auditados diretamente:

- `src/vba/Util_Planilha.bas`
- `src/vba/Util_Sanear_Contadores.bas`
- `src/vba/Util_Excel_Performance.bas`
- `src/vba/Repo_Empresa.bas`
- `src/vba/Menu_Principal.frm`
- `src/vba/Repo_Credenciamento.bas`
- `src/vba/Repo_OS.bas`
- `src/vba/Repo_PreOS.bas`
- `src/vba/Repo_Avaliacao.bas`
- `src/vba/Preencher.bas`
- Suites de gate em `Teste_Bateria_Oficial.bas`, `Teste_V2_Engine.bas` e `Teste_Validacao_Release.bas`.

## 2. Mudanças validadas

| Onda | Mudanca | Avaliacao | Evidencia / comentario |
|---|---|---|---|
| 38.2.1 | `Menu_Principal.frm` e `Preencher.bas` restaurados do anchor funcional para remover regressao dos filtros 38.2 | OK | ERP 0105 registra import `M=2/F=1/err=0/skip=0`, compile limpo, erro 424 eliminado e RVS Trio `VR_20260526_024718` aprovado. |
| 38.2.1 | Reversao deixou filtros novos fora do escopo, preservando apenas comportamento estavel anterior | OK | Decisao correta para estabilizacao. Filtros restantes viraram F3/38.2.2. |
| 38.2.1 | Gate de cadastro empresa detectou ID `001` duplicado | BUG | Nao foi regressao do revert, mas bug latente por AR1 dessincronizado. Enderecado pela AR1. |
| 38.2.1 | Cadastro de entidade aparecendo no topo | BUG | Sintoma provavel do mesmo AR1 dessincronizado em `ENTIDADE`. Enderecado pela AR1. |
| 38.2.1-AR1 | Novo `Util_Sanear_Contadores.bas` saneia AR1 das 7 abas que usam `ProximoId` | OK | `SanearContadoresAR1` percorre EMPRESAS, ENTIDADE, ATIVIDADES, CAD_SERV, PRE_OS, CAD_OS, CREDENCIADOS. ERP 0106: `ok=7 falhas=0`. |
| 38.2.1-AR1 | EMPRESAS e ENTIDADE consideram abas inativas como sources | OK | Boa resposta a risco levantado por Mauricio: `EMPRESAS_INATIVAS` e `ENTIDADE_INATIVOS` entram no max sem receber escrita. |
| 38.2.1-AR1 | Algoritmo original podia decrescer AR1 para `max(coluna A)` | BUG | ERP 0106 registrou `CREDENCIADOS!AR1 6 -> 4`. F5 corretamente tratado na FIX2. |
| 38.2.1-AR1 | Hotfix BUMP_NO_CHANGE e knowledge 0016 | OK | Diagnostico do Importador V3 correto: nao pre-setar `APP_BUILD_IMPORTADO` igual ao target. |
| 38.2.1-AR1-FIX2-PERF | `SanearAR1EmAbaPareada` ganhou guarda monotonica | OK | `src/vba/Util_Sanear_Contadores.bas:144-155` preserva AR1 quando `maxId < valorAnterior`. Gate real validou `CREDENCIADOS!AR1 8 -> 8`. |
| 38.2.1-AR1-FIX2-PERF | `Util_MaxIdNaColunaA` promovido para Public | OK | `src/vba/Util_Planilha.bas:536-561`. Remove duplicacao e permite defesa em `ProximoId`. |
| 38.2.1-AR1-FIX2-PERF | `ProximoId` salta para `max(coluna A)` se AR1 estiver atrasado | OK com DÚVIDA | `src/vba/Util_Planilha.bas:568-593` cobre backup com AR1 baixo e dados ativos. Dúvida: para EMPRESAS/ENTIDADE a defesa nao olha abas inativas. |
| 38.2.1-AR1-FIX2-PERF | Novo `Util_Excel_Performance.bas` com wrapper de Application flags | OK com DÚVIDA | Funciona e respeita G8 usando `Variant`. Dúvida: helper e callers ainda nao têm contrato robusto contra falha antes de instalar handler. |
| 38.2.1-AR1-FIX2-PERF | `Repo_Empresa` envelopado em 4 rotinas | DÚVIDA | O wrapper esta bem pareado, mas a rota de cadastro no `Menu_Principal.frm:2242-2269` escreve direto em `EMPRESAS`, entao parte relevante da UI nao passa por `Repo_Empresa.Inserir`. |
| 38.2.1-AR1-FIX2-PERF | Decisao `Variant` no lugar de `Public Type TEstadoExcel` | OK para V206 | Foi a melhor solucao sob G8 e tabu de `Mod_Types.bas`. Para V207, um `Public Type` em `Mod_Types.bas` ou um contexto encapsulado e mais limpo. |
| 38.2.1-AR1-FIX2-PERF | RVS Trio `VR_20260526_102200` aprovado | OK | Boa evidencia de nao regressao em suites atuais. Nao cobre E2E real de cadastros via UI. |

## 3. Pontos soltos identificados

| Ponto | Arquivo:linha | Severidade | Descricao | Proposta de fix |
|---|---:|---|---|---|
| F-NEW3 | `src/vba/Menu_Principal.frm:1622` | cosmetico | ID de entidade e gravado com `Format(ContCodigo, "000")`, mas sem `NumberFormat="@"`; em ListObject/coluna General, Excel pode reclassificar `"005"` como `5`. | Antes de gravar ID novo em todas as rotas de cadastro, aplicar `.Cells(linha, colId).NumberFormat = "@"` e depois `.Value = Format$(id, "000")`. Cobrir entidade, empresa, credenciamento, atividade e servico. |
| ProximoId incompleto para inativos | `src/vba/Util_Planilha.bas:586-588` | alto | A defesa em profundidade usa apenas `Util_MaxIdNaColunaA(nomeAba)`. Se `EMPRESAS!AR1` ou `ENTIDADE!AR1` for corrompido para baixo e o maior ID estiver na aba inativa, `ProximoId` pode gerar ID duplicado contra `EMPRESAS_INATIVAS` ou `ENTIDADE_INATIVOS`. | Criar helper pair-aware, por exemplo `Util_MaxIdOperacional(nomeAba)`, com mapa `EMPRESAS -> EMPRESAS+EMPRESAS_INATIVAS` e `ENTIDADE -> ENTIDADE+ENTIDADE_INATIVOS`; usar em `ProximoId` e em `Sanear`. |
| Wrapper inicia antes do handler | `src/vba/Repo_Empresa.bas:80`, `242`, `319`, `476`; `src/vba/Util_Sanear_Contadores.bas:44` | medio | Callers chamam `Util_IniciarBlocoRapido()` antes de `On Error GoTo`. Se o helper falhar apos desligar algum flag, o handler local nao restaura. Risco raro, mas exatamente no tipo de helper que deve ser a prova de falha. | Instalar `On Error GoTo erro` antes de iniciar o bloco, ou mover a tolerancia para dentro do helper com rollback interno em caso de falha parcial. |
| Estado `Variant` sem validacao estrutural | `src/vba/Util_Excel_Performance.bas:67-76` | baixo | `Util_FinalizarBlocoRapido` aceita qualquer array e usa `On Error Resume Next`. Um array com shape errado pode restaurar parcialmente ou esconder erro de contrato. | Em V206, validar `LBound=0` e `UBound>=3`. Em V207, trocar por `TEstadoExcel` em `Mod_Types.bas` ou por stack/contexto privado. |
| `Repo_Empresa.Inserir` parece fora da rota principal de UI | `src/vba/Repo_Empresa.bas:218`; `src/vba/Menu_Principal.frm:2242-2269` | alto | `rg` nao encontrou chamada a `Repo_Empresa.Inserir` na UI; o cadastro de empresa do Menu Principal gera ID e grava 19 colunas direto. Isso explica por que o speedup reportado ficou em cerca de 2x apesar do wrapper no repo. | Curto prazo: envelopar tambem `Menu_Principal.frm` com wrapper. V207: mover a rota de cadastro de empresa para `Svc_CadastroEmpresa.Cadastrar` usando `Repo_Empresa.Inserir` como unica persistencia. |
| Cadastro entidade ainda direto na UI | `src/vba/Menu_Principal.frm:1611-1676` | medio | A rotina `C_Cadastrar_Click` mistura validacao, `ProximoId`, escrita em 22 celulas, limpeza de UI, classificacao, reload de listas, save e mensagens. E dificil testar, otimizar e tornar idempotente. | Extrair servico `Svc_CadastroEntidade.Cadastrar`, repo `Repo_Entidade.Inserir` e deixar o form apenas coletar input e exibir resultado. |
| Reload pesado depois de cadastro | `src/vba/Menu_Principal.frm:1667-1669`; `2438-2451` | medio | Entidade chama `ClassificaEntidade`, `AtualizarListaEntidadeMenuAtual` e `PreenchimentoEntidadeRodizio`; empresa chama `ClassificaEmpresa`, `AtualizarListaEmpresaMenuAtual` e `PreenchimentoCRServico`. Cada reload reconstrói listas completas. | Lazy reload: inserir/atualizar apenas o item novo quando a ordenacao permitir; quando classificar for inevitavel, suspender UI e medir cada etapa. |
| `PreencherServicoFormatado` usa `AddItem` por linha | `src/vba/Preencher.bas:3193-3225` | medio | Essa rotina ainda preenche ListBox item a item, enquanto outras ja usam array 2D. Em PC antigo, `AddItem` por linha e gargalo conhecido. | Substituir por montagem de array e atribuir `lst.List = itens`. Se a rotina estiver obsoleta, marcar como legacy e retirar da rota ativa. |
| Loops de atividade ainda escrevem celula a celula | `src/vba/Preencher.bas:2391-2437`, `2862-2873`, `3064-3073` | medio | Reset/import de CNAE e insercao importada percorrem linhas escrevendo cada celula. Parte ja evita `ProximoId` por linha, mas nao usa escrita em bloco para grandes cargas. | Para V207, parsear CSV para array 2D e fazer um unico write por faixa; manter status bar a cada bloco, nao por celula. |
| Repos nao envelopados | `src/vba/Repo_PreOS.bas:29-47`, `src/vba/Repo_OS.bas:27-44`, `src/vba/Repo_Avaliacao.bas:52-79`, `src/vba/Repo_Credenciamento.bas:147-150` | baixo/medio | Rotinas de persistencia relevantes continuam com escritas sequenciais sem wrapper. Elas nao foram foco do gate de cadastro, mas pesam em fluxos de OS/avaliacao. | Aplicar wrapper com padrao corrigido e, quando houver mais de 5 colunas, migrar para escrita por array/faixa. |
| Handlers de erro perdem contexto original | `src/vba/Repo_Empresa.bas:285-292`, `361-368` | baixo | `Inserir` e `Atualizar` nao salvam `Err.Number/Description` antes de tentar restaurar protecao. Se a restauracao gerar outro erro, a mensagem final pode apontar para a falha errada. | Copiar o padrao de `GravarStatusEmpresa`: salvar numero e mensagem imediatamente no label de erro, depois restaurar. |
| Teste fixture nao testa rota real | `src/vba/Teste_V2_Engine.bas:1081-1155`, `1158-1200` | medio | Fixtures V2 criam entidade/empresa/credenciamento por escrita direta e ajustam contador manualmente. Isso testa o modelo de dados, mas nao testa `Menu_Principal.frm`, `ProximoId` real, wrappers, NumberFormat, save e reload. | Criar bateria `E2E_CADASTROS` com rotas reais ou servicos extraidos equivalentes; nao depender apenas de fixtures. |
| Infraestrutura dinamica legada de filtros ainda existe | `src/vba/Menu_Principal.frm:3679-3766` | medio | A versao atual ainda contem `Controls.Add` e heuristicas de busca para filtros dinamicos legados. A regressao 38.2 veio da tentativa posterior com `WithEvents`, mas a superficie ainda e fragil para 38.2.2. | Em 38.2.2, remover caminho dinamico para os filtros novos e usar apenas controles estaticos do designer + handlers nativos. Validar `.frm` e `.code-only.txt` conforme M9/L22-L24. |

## 4. Idempotência das rotinas críticas

### SanearContadoresAR1

Status: convergente e praticamente idempotente.

`SanearContadoresAR1` e idempotente quando dados e AR1 nao mudam entre execucoes: a primeira execucao eleva AR1 ate o maior ID conhecido e a segunda regrava o mesmo valor. A guarda monotonica em `src/vba/Util_Sanear_Contadores.bas:144-147` impede regressao quando linhas foram deletadas.

Limite: se AR1 estiver inflado por erro humano, a rotina preserva o valor alto. Isso e uma escolha segura contra reuso de IDs, mas nao e uma cura completa de contador errado. Se V207 quiser detectar esse caso, deve registrar alerta quando `valorAnterior > maxId + margem`, sem reduzir automaticamente.

### Util_IniciarBlocoRapido / Util_FinalizarBlocoRapido

Status: `Finalizar` e idempotente com o mesmo estado; o par completo nao e idempotente por natureza.

`Util_FinalizarBlocoRapido st` pode ser chamado repetidamente com o mesmo `st` e deve restaurar os mesmos valores. Ja `Util_IniciarBlocoRapido` captura o estado corrente; duas chamadas seguidas antes de finalizar geram dois estados diferentes. Isso exige disciplina de stack.

Como tornar mais robusto:

- Criar `TEstadoExcel` em `Mod_Types.bas` na V207.
- Incluir `ativo As Boolean` e, idealmente, um `nivel` ou token.
- Centralizar profundidade em modulo privado: o primeiro `Iniciar` salva o estado real, chamadas aninhadas apenas incrementam contador, e o ultimo `Finalizar` restaura.
- Instalar handler antes de qualquer mutacao de `Application`.

### Repo_Empresa.Inserir / Atualizar / GravarStatusEmpresa

Status: nao idempotentes no sentido estrito.

- `Inserir` nunca deve ser idempotente sem chave idempotente externa: cada chamada gera novo ID e nova linha.
- `Atualizar` seria quase idempotente para os campos de cadastro, mas sempre atualiza `DT_ULT_ALT = Now` em `src/vba/Repo_Empresa.bas:352`, entao duas chamadas iguais produzem timestamps diferentes.
- `GravarStatusEmpresa` tambem grava `DT_ULT_ALT = Now` em `src/vba/Repo_Empresa.bas:117`, logo nao e idempotente estrito.

Como tornar:

- Para `Inserir`, usar chave natural/operacional (`CNPJ` normalizado + namespace) para retornar registro existente em chamadas repetidas, ou separar `Criar` de `Upsert`.
- Para `Atualizar` e `GravarStatusEmpresa`, so alterar `DT_ULT_ALT` se algum campo efetivamente mudou, ou aceitar `dtOperacao` explicito vindo de uma transacao.
- Registrar no `TResult` se houve `created`, `updated`, `noop` ou `duplicate`.

### ProximoId

Status: nao idempotente por definicao, mas deve ser monotonicamente seguro.

Cada chamada incrementa AR1 e retorna novo ID. Isso e correto para gerador de sequencia, mas significa que erro apos `ProximoId` pode deixar gap de ID. Gap e aceitavel; reuso nao e.

Como tornar mais seguro:

- Tornar o max pair-aware para EMPRESAS/ENTIDADE, incluindo inativas.
- Separar `ReservarProximoId` de `ConfirmarIdUsado` apenas se o projeto aceitar complexidade transacional.
- Registrar evento quando `ProximoId` detecta `maxIdReal > AR1`, pois isso indica corrupcao ou restore.

## 5. Cobertura de testes

### O que Trio e Sexteto cobrem

O Trio atual cobre:

- V1 rapida: regressao ampla de regras historicas.
- V2 Smoke: fluxo rapido de motor e contratos basicos.
- V2 Canonica: cenarios canonicos de rodizio, Pre-OS, OS, avaliacao e integridade de fila.

O Sexteto amplia com:

- E2E Strikes.
- IntegridadeBase.
- Onda23Adv, com checks adversariais de superficie UI/documental.

Evidencia recente:

- Sexteto `VR_20260526_035523`: aprovado no predecessor AR1.
- Trio `VR_20260526_102200`: aprovado apos FIX2-PERF.

### O que nao cobre

Nao ha cobertura automatizada suficiente para:

- Cadastrar empresa real pelo `Menu_Principal.frm`.
- Cadastrar entidade real pelo `C_Cadastrar_Click`.
- Cadastrar servico/atividade pelo `Cadastro_Servico.frm`.
- Credenciar empresa via `Credencia_Empresa.frm`.
- Validar `NumberFormat="@"` na coluna ID apos extensao de ListObject.
- Validar reload incremental ou ausencia de reload pesado.
- Validar tempo de cadastro em PC antigo.
- Validar que `Repo_Empresa.Inserir` e a rota real de UI sao a mesma rota.
- Validar wrappers de `Application` em caso de erro.

As fixtures de `Teste_V2_Engine.bas:1081-1155` e `1158-1200` escrevem direto nas abas e ajustam AR1 manualmente. Elas sao uteis para estado canonico, mas nao exercitam a jornada humana.

### Bateria proposta: E2E_CADASTROS

Nome proposto: `TV2_RunE2E_Cadastros` ou `CT_ValidarCadastrosE2E`.

Cenarios minimos:

| ID | Fluxo | Esperado |
|---|---|---|
| CAD_EMP_001 | Cadastrar empresa por rota real de UI/servico extraido | Nova linha em EMPRESAS, ID `max+1`, `AR1=max`, CNPJ normalizado, `STATUS_GLOBAL=ATIVA`, `DT_ULT_ALT` preenchido, lista atualizada. |
| CAD_EMP_002 | Repetir CNPJ | Nao cria segunda linha; mensagem/resultado de duplicidade. |
| CAD_ENT_001 | Cadastrar entidade | Nova linha no fim, ID com zero padding preservado como texto, `AR1=max`, lista entidade e rodizio atualizadas. |
| CAD_SERV_001 | Cadastrar atividade+servico | ATIVIDADES e CAD_SERV consistentes, IDs formatados, `CAD_SERV.ATIV_ID` aponta para atividade. |
| CAD_CRED_001 | Credenciar empresa em atividade com N servicos | Cria N linhas em CREDENCIADOS, posicoes sequenciais, sem duplicar se rodar de novo. |
| CAD_MONO_001 | Zerar AR1 com dados ativos e cadastrar | `ProximoId` salta para `max+1`; nao gera `001`. |
| CAD_MONO_002 | Maior ID em aba inativa e AR1 corrompido baixo | Novo cadastro nao reusa ID da inativa. Este teste so passa apos fix pair-aware. |
| CAD_FORMAT_001 | Conferir NumberFormat da coluna A apos cadastro | Valor visual e persistido permanece `005`, nao `5`. |
| CAD_PERF_001 | Cronometrar cadastro com e sem reload completo | Registra tempos por etapa: persistencia, classifica, reload, save. Nao usar como gate duro no inicio; usar como telemetria. |
| CAD_ROLLBACK_001 | Simular erro apos `ProximoId` | Confirma que nao reusa ID, que protecao e Application flags foram restaurados, e que mensagem preserva erro original. |

Recomendacao: primeiro implementar a bateria contra servicos extraidos, nao contra cliques reais no form. Depois adicionar smoke assistido para confirmar que os forms chamam os mesmos servicos.

## 6. Gargalos de performance residuais

### Repo_Empresa

O wrapper aplicado em `Repo_Empresa` esta correto como microdelta, mas parece atingir pouco a jornada humana atual:

- `Repo_Empresa.Inserir` esta em `src/vba/Repo_Empresa.bas:218-294`.
- A rota de cadastro do Menu Principal grava direto em `src/vba/Menu_Principal.frm:2242-2269`.
- `GravarStatusEmpresa` e usado por `Svc_Rodizio`, entao o wrapper beneficia suspensao/reativacao automatica, nao necessariamente cadastro humano.

Conclusao: o speedup de cerca de 2x reportado por Mauricio e coerente com uma otimizacao parcial. O gargalo central permanece no form e nos reloads.

### Cadastros `.frm`

Rotas pesadas ainda diretas:

- Entidade: `src/vba/Menu_Principal.frm:1611-1676`.
- Empresa: `src/vba/Menu_Principal.frm:2242-2269`.
- Credenciamento: `src/vba/Credencia_Empresa.frm:141-181`.
- Servico/atividade: `src/vba/Cadastro_Servico.frm:112-150`.

Essas rotas misturam escrita, UI, save e reload. Envelopar com `Util_Excel_Performance` ajuda, mas a melhoria maior vem de:

- escrever linha inteira por array/faixa;
- evitar reload completo quando um append simples basta;
- extrair regra/persistencia para servico testavel;
- medir etapa por etapa.

### Preencher.bas

Pontos bons:

- Varias listas ja fazem duas passadas e usam `lst.List = array`, como `PreenchimentoEntidade` em `src/vba/Preencher.bas:466-512` e `PreenchimentoEmpresa` em `733-782`.

Pontos residuais:

- `PreencherServicoFormatado` ainda usa `AddItem` por linha em `src/vba/Preencher.bas:3193-3225`.
- `PreenchimentoListaAtividade` le `ATIVIDADES` duas vezes em `1736-1788`; aceitavel para 1.300 linhas, mas pode ser cacheado se filtros ficarem vivos.
- Reset/import de CNAE escreve celula a celula em `2391-2437`.
- Sincronizacao de descricoes e rotinas de CNAE seguem loops de planilha, alguns inevitaveis, mas candidatos a array.

### Reload de ListBox apos cadastro

Reloads atuais tendem a reconstruir listas completas:

- Entidade: `ClassificaEntidade`, `AtualizarListaEntidadeMenuAtual`, `PreenchimentoEntidadeRodizio`.
- Empresa: `ClassificaEmpresa`, `AtualizarListaEmpresaMenuAtual`, `PreenchimentoCRServico`.
- Servico: `ClassificaServico`, `PreenchimentoListaAtividade`, `PreencherServicoFormatado`, `PreenchimentoServico`, `PreenchimentoCRServico`.

Proposta pragmatica:

1. Medir tempo por etapa com `Timer`.
2. Aplicar wrapper no bloco inteiro do form.
3. Trocar `AddItem` residual por arrays.
4. Implementar lazy reload quando o cadastro e append e a ordenacao nao precisa mudar.
5. Quando a ordenacao precisa mudar, fazer reload unico, nao tres reloads sequenciais.

## 7. Variáveis globais e acoplamentos

Principais acoplamentos observados:

- `src/vba/Variaveis.bas:8-15` expoe `ContCodigo`, `nLinhas`, `linha`, `Coluna`, `cont`, `NItem` como globais. `Preencher.bas` ainda reseta `cont` e `NItem` em varias rotinas.
- `src/vba/Variaveis.bas:24-38` expoe estado de UI/relatorio como `Gestor_Empresa`, `M_NomeEmpresa`, `Desc_Ativi`, `Desc_Serv`, `entidade`, `Desc_entidade`, etc.
- `Menu_Principal.frm` ainda concentra cadastro, navegacao, filtros, relatorio, estado de avaliacao e chamada de testes.
- Existem varios `Inserir` publicos em repos diferentes (`Repo_Empresa`, `Repo_OS`, `Repo_PreOS`, `Repo_Avaliacao`). Em VBA standard modules, isso aumenta risco de chamada ambigua ou acoplamento por nome global.
- `Application.ScreenUpdating`, `Calculation`, `EnableEvents` e `DisplayAlerts` agora tem wrapper, mas continuam sendo estado global compartilhado.

Recomendacao V207:

- Reduzir globais de loop para variaveis locais.
- Introduzir DTOs claros para cadastro (`TDadosEmpresa`, `TDadosEntidade`, etc.) em `Mod_Types.bas`.
- Criar servicos de cadastro como unica fronteira entre UI e repos.
- Prefixar funcoes publicas de repos (`RepoEmpresa_Inserir`, `RepoEntidade_Inserir`) para evitar nomes genericos globais.

## 8. Aderência a CLAUDE.md / AGENTS.md / Glasswing G7/G8

### AGENTS.md

A auditoria respeitou:

- raiz canonica;
- leitura previa obrigatoria;
- nenhuma edicao em codigo;
- nenhum uso de workbook ou VBE;
- nenhuma claim de seguranca sem evidencia;
- frontmatter obrigatorio nos `.md` novos.

Ponto operacional: a instrucao do prompt pediu salvar apenas os dois `.md` em `.hbn/proposals`; por isso esta auditoria nao criou readback/ERP proprio.

### CLAUDE.md

Tabus V206 preservados:

- `Mod_Types.bas` nao foi tocado pela estabilizacao recente.
- `Importador_V3.bas` nao foi tocado.
- `Svc_*` blindados nao foram tocados nas ondas auditadas.
- `.frm/.frx` ficaram fora da FIX2-PERF; a Onda 38.2.1 tocou `.frm` apenas para revert aprovado.

Para V207, o tabu de `Mod_Types.bas` e `Importador_V3.bas` pode ser reavaliado, mas apenas como proposta e com ciclo proprio.

### Glasswing G7/G8

- G8 detectou corretamente a tentativa inicial de `Public Type TEstadoExcel` fora de `Mod_Types.bas`.
- A solucao `Variant array(0..3)` em `Util_Excel_Performance` e aceitavel para V206.
- Para V207, a alternativa mais limpa e mover o tipo para `Mod_Types.bas` ou encapsular estado em helper privado.
- G7 esta sensivel ao espelho `AAX-App_Release.bas`; havia divergencia preexistente do BUMP do V3, mas como esta auditoria nao stageou VBA, o pre-commit nao deve rodar G7/G8.

### PHAGOCYTOSIS M9/L22-L24/M15-M17

Para qualquer 38.2.2 que toque `Menu_Principal.frm`:

- manter `.frm` e `.code-only.txt` sincronizados;
- comparar pulando header do form;
- evitar `Controls.Add` para controles que precisam ser smokeados como estaticos;
- normalizar trailing whitespace;
- nao insistir em reimport `.code-only` se V3 falhar com Err 50132 sem causa isolada;
- reproduzir validadores textuais fora do VBA antes de import;
- ler o `.frm` completo antes de derivar canonico de UI.

Conclusao: a V206 esta funcionalmente estabilizada no anchor `ee75b30`, mas ainda tem tres dividas de codigo que nao devem entrar no freeze como "resolvidas": F-NEW3 formato de ID, F-NEW4 performance residual, e F-NEW4-DT ausencia de E2E real de cadastros. A decisao Variant foi correta para V206; para V207, deve ser substituida por contrato tipado ou contexto de performance com profundidade.
