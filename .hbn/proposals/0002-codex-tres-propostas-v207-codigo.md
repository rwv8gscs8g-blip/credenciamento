---
titulo: Três Propostas V207 — auditoria Codex de código
diataxis: explanation
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-26
---

# Três Propostas V207 — auditoria Codex de código

Premissa comum às três propostas: a planilha Excel continua sendo porta de entrada, porta de saída, formato de auditoria e mecanismo de independencia tecnologica do municipio. Nenhuma proposta deve transformar o SaaS futuro em aprisionamento. O municipio deve conseguir exportar, auditar e operar seus dados por workbook.

# Proposta 1 — VBA monolítico estabilizado

## Resumo executivo (3 linhas)

Manter a arquitetura principal em VBA/Excel, corrigindo os gargalos com refatoracao interna conservadora.
O objetivo e fechar V207 com cadastros testaveis, escrita em bloco, reload preguiçoso e wrappers seguros, sem mudar o modelo operacional.
E a proposta de menor ruptura e melhor alinhamento com a planilha como produto offline completo.

## Escopo (módulos tocados)

- `src/vba/Menu_Principal.frm`
- `src/vba/Credencia_Empresa.frm`
- `src/vba/Cadastro_Servico.frm`
- `src/vba/Preencher.bas`
- `src/vba/Repo_Empresa.bas`
- novo `src/vba/Repo_Entidade.bas`
- novo `src/vba/Svc_Cadastro.bas` ou familia `Svc_Cadastro_*`
- `src/vba/Util_Excel_Performance.bas`
- `src/vba/Util_Planilha.bas`
- testes em `Teste_V2_Engine.bas`, `Teste_V2_Roteiros.bas`, `Teste_Validacao_Release.bas`
- espelhos correspondentes em `local-ai/vba_import/`

## Mudanças estruturais

- Criar uma camada minima de cadastro sem reescrever o sistema:
  - `Svc_CadastroEmpresa_Cadastrar`
  - `Svc_CadastroEntidade_Cadastrar`
  - `Svc_CadastroServico_Cadastrar`
  - `Svc_Credenciamento_CredenciarAtividade`
- Mover escrita direta de `Menu_Principal.frm`, `Credencia_Empresa.frm` e `Cadastro_Servico.frm` para repos/servicos.
- Trocar escritas celula-a-celula por escrita de array 1 x N em rotas de cadastro.
- Trocar `PreencherServicoFormatado` de `AddItem` por `lst.List = array`.
- Implementar `Util_MaxIdOperacional(nomeAba)` pair-aware para EMPRESAS/ENTIDADE com inativas.
- Corrigir `NumberFormat="@"` antes de qualquer ID novo.
- Medir tempos por etapa nos cadastros: persistencia, classifica, reload, save.
- Implementar lazy reload quando o item novo pode ser anexado sem reconstruir lista inteira.
- Endurecer `Util_Excel_Performance`: handler antes do primeiro flag, shape validation, stack simples de profundidade.

## Mudanças em Mod_Types.bas (TABU LIBERADO PARA V207 — pode propor)

Opcional, mas recomendada:

- `Public Type TEstadoExcel`
  - `screenUpdating As Boolean`
  - `calculation As XlCalculation`
  - `enableEvents As Boolean`
  - `displayAlerts As Boolean`
  - `ativo As Boolean`
- `Public Type TDadosEmpresaCadastro`
- `Public Type TDadosEntidadeCadastro`
- `Public Type TDadosServicoCadastro`
- `Public Type TResultCadastro`
  - inclui `sucesso`, `mensagem`, `idGerado`, `linha`, `acao` (`created/updated/noop/duplicate`).

Se a equipe quiser risco minimo, pode manter DTOs como argumentos simples em V207.0 e mover para `Mod_Types.bas` em V207.1.

## Mudanças em Importador_V3.bas (TABU LIBERADO PARA V207 — pode propor)

Nenhuma obrigatoria.

Melhoria opcional:

- Tratar `BUMP_NO_CHANGE` como sucesso quando o valor ja esta correto, registrando `BUMP_NO_OP` em vez de falha.
- Adicionar validacao explicita de `.frm` + `.code-only.txt` para forms tocados, aplicando M9/L22/L24.

## Bateria de testes nova necessária

- `E2E_CADASTROS`:
  - cadastrar empresa;
  - cadastrar entidade;
  - cadastrar servico/atividade;
  - credenciar empresa em atividade;
  - validar ID, AR1, zero padding, linha no fim, reload de lista e save.
- `E2E_MONOTONIA_ID`:
  - AR1 zerado com dados ativos;
  - maior ID em aba inativa;
  - linhas deletadas e gaps historicos.
- `PERF_CADASTROS_LITE`:
  - telemetria por etapa, sem gate duro no primeiro ciclo.
- `UI_SMOKE_FORMS_ESTATICOS`:
  - controles estaticos do designer, sem depender de controles dinamicos.

## Estimativa de custo (ondas, complexidade)

- 4 a 6 ondas curtas.
- Complexidade media.
- Risco controlavel se cada form for tocado em ciclo proprio com PHAGOCYTOSIS aplicado.

Sequencia sugerida:

1. V207.0: tipos/estado Excel + `Util_MaxIdOperacional`.
2. V207.1: `Svc_CadastroEmpresa` + testes.
3. V207.2: `Svc_CadastroEntidade` + F-NEW3.
4. V207.3: servico/atividade + credenciamento.
5. V207.4: `Preencher.bas` performance residual.
6. V207.5: limpeza de duplicacao e docs de import.

## Estimativa de speedup em PC antigo (vs baseline atual)

- Cadastro de empresa/entidade: 3x a 8x se o gargalo dominante for reload e escrita celula-a-celula.
- Import/listas de servico: 2x a 6x.
- Reset/import CNAE: 5x a 15x se migrar para escrita em bloco.

Estimativas dependem de benchmark real; a primeira entrega deve medir antes de prometer meta fixa.

## Riscos

- `.frm` e `.frx` sao superficie sensivel; reimport indevido pode quebrar designer.
- Extrair servicos sem testes pode apenas mover bugs de lugar.
- Lazy reload pode deixar UI visualmente fora de ordem se `Classifica*` for indispensavel.
- `Mod_Types.bas` vira ponto de conflito se receber muitos DTOs de uma vez.

## Como rollback se der errado

- Cada onda deve ter delta V3 pequeno e backup do Importador.
- Rollback por commit e por backup do workbook da onda.
- Se um form falhar, reverter apenas o form e seu `.code-only.txt`.
- Manter anchor funcional V206 `ee75b30` como referencia de comportamento.

## Por que esta proposta vs as outras 2

Escolher esta proposta se a prioridade for estabilizar o produto Excel com baixo risco e sem dependencia externa. Ela entrega ganho real para municipios que usam a planilha offline. A desvantagem e que prepara menos para SaaS do que a Proposta 2 e nao elimina as limitacoes estruturais do VBA como a Proposta 3 tenta fazer.

# Proposta 2 — Camadas VBA para ponte SaaS

## Resumo executivo (3 linhas)

Separar UI, regra de negocio e persistencia dentro do proprio VBA, criando uma arquitetura mais limpa sem abandonar Excel.
A planilha continua operacional e auditavel, mas os contratos ficam proximos de uma futura API.
E o melhor equilibrio entre estabilizacao V207 e preparacao real para SaaS sem reescrita imediata.

## Escopo (módulos tocados)

- `src/vba/Menu_Principal.frm`
- `src/vba/Credencia_Empresa.frm`
- `src/vba/Cadastro_Servico.frm`
- `src/vba/Repo_Empresa.bas`
- novo `src/vba/Repo_Entidade.bas`
- novo `src/vba/Repo_Servico.bas`
- novo `src/vba/Repo_CadastroAudit.bas`
- novo `src/vba/Svc_CadastroEmpresa.bas`
- novo `src/vba/Svc_CadastroEntidade.bas`
- novo `src/vba/Svc_CadastroServico.bas`
- novo `src/vba/Svc_CredenciamentoCadastro.bas`
- `src/vba/Mod_Types.bas`
- `src/vba/Importador_V3.bas` em microdelta dedicado, se aprovado
- testes e docs correspondentes

## Mudanças estruturais

- UI forms deixam de escrever em planilha diretamente.
- `Svc_*` viram fronteira de caso de uso:
  - validam entrada;
  - chamam repos;
  - registram auditoria;
  - decidem reload/resultado para UI.
- `Repo_*` fazem persistencia pura e previsivel:
  - nada de `MsgBox`;
  - nada de acesso a controles;
  - retornam `TResult`.
- `Preencher.bas` vira camada de view model/listas, nao de regra.
- Criar contratos de import/export CSV/JSON a partir dos mesmos DTOs, preservando planilha como formato de migracao.
- Prefixar APIs publicas para evitar nomes genericos globais: `RepoEmpresa_Inserir`, `RepoEntidade_Inserir`, etc.
- Criar adaptadores:
  - `AdapterExcel_*` para persistir em planilha;
  - no futuro, `AdapterApi_*` para SaaS.

## Mudanças em Mod_Types.bas (TABU LIBERADO PARA V207 — pode propor)

Recomendado:

- Consolidar DTOs de cadastro:
  - `TDadosEmpresa`
  - `TDadosEntidade`
  - `TDadosServico`
  - `TDadosCredenciamento`
- Consolidar resultados:
  - `TResultadoOperacao`
  - `TResultadoCadastro`
  - `TResultadoValidacao`
- Adicionar `TEstadoExcel` ou `TContextoExecucao`.
- Adicionar tipos de export/migracao:
  - `TRegistroExportacao`
  - `TResumoMigracao`

Regra: mudanca em `Mod_Types.bas` deve ser pequena por onda. Nao fazer um "mega type dump".

## Mudanças em Importador_V3.bas (TABU LIBERADO PARA V207 — pode propor)

Propostas especificas:

- `BUMP_NO_CHANGE` vira `BUMP_NO_OP` quando constantes ja batem com target.
- Manifesto V3 aceita bloco `DEPENDENCIAS` para indicar ordem de modulos novos, evitando import fora de ordem quando `Mod_Types.bas` muda.
- Validador pre-import verifica se `Mod_Types.bas` foi importado antes de modulos que referenciam tipos novos.
- Para `.frm`, exigir par `.frm + .code-only.txt` e registrar hash gamma no log do import.
- Modo `audit-only` para simular ordem, tipos e presenca de simbolos sem tocar workbook.

Essas mudancas devem acontecer em onda isolada porque `Importador_V3.bas` e load-bearing.

## Bateria de testes nova necessária

- `E2E_CADASTROS` completa.
- `UNIT_SVC_CADASTRO`:
  - validacao de CNPJ;
  - duplicidade;
  - campos obrigatorios;
  - resultado `created/noop/duplicate`.
- `CONTRACT_REPO`:
  - repos sem `MsgBox`;
  - repos retornam `TResult`;
  - repos nao chamam forms.
- `EXPORT_IMPORT_ROUNDTRIP`:
  - exporta dados para CSV/JSON;
  - reimporta em workbook limpo;
  - compara contagens, IDs e chaves.
- `IMPORTADOR_V3_SAFE`:
  - `BUMP_NO_OP`;
  - ordem de `Mod_Types`;
  - `.frm/.code-only` gamma match.

## Estimativa de custo (ondas, complexidade)

- 7 a 10 ondas.
- Complexidade media-alta.
- Exige disciplina de contratos, mas ainda opera dentro de Excel/VBA.

Sequencia sugerida:

1. Tipos e prefixos de API.
2. `Svc_CadastroEmpresa` + `RepoEmpresa` como rota unica.
3. `Svc_CadastroEntidade` + `RepoEntidade`.
4. `Svc_CadastroServico` + `RepoServico`.
5. `Svc_CredenciamentoCadastro`.
6. `Preencher.bas` como view model/cache.
7. Import/export roundtrip.
8. Importador V3 hardening.
9. Remocao de globais obsoletos.
10. Docs de arquitetura e migracao.

## Estimativa de speedup em PC antigo (vs baseline atual)

- Cadastros: 3x a 10x, principalmente por rota unica + escrita em bloco + reload controlado.
- Listagens: 2x a 5x com cache/view model.
- Operacoes batch: 5x a 15x onde houver escrita por array.

O ganho pode ser menor que a Proposta 1 no curto prazo porque parte do custo vai para separacao estrutural.

## Riscos

- Risco de abrir escopo demais e tocar muitos modulos ao mesmo tempo.
- `Mod_Types.bas` pode causar falha de compile global se mal ordenado.
- `Importador_V3.bas` e sensivel; mudancas devem ser provadas por testes locais e gate manual.
- Camadas mal desenhadas podem virar apenas wrappers finos sem reduzir acoplamento.

## Como rollback se der errado

- Feature flag simples: forms podem voltar a chamar rota antiga enquanto servico novo fica inativo.
- Cada servico novo entra primeiro em paralelo, usado apenas por teste, depois vira rota principal.
- `Importador_V3` deve ter rollback proprio e nao ser misturado com mudanca de cadastro.
- Workbook backup por delta V3 e commit atomico por camada.

## Por que esta proposta vs as outras 2

Escolher esta proposta se V207 deve preparar SaaS sem perder a planilha como produto. Ela e mais cara que a Proposta 1, mas cria contratos transportaveis. E menos disruptiva que a Proposta 3 porque nao exige runtime externo nem operacao de servidor.

# Proposta 3 — Backend/API progressivo com Excel soberano

## Resumo executivo (3 linhas)

Extrair gradualmente regras e persistencia para um runtime externo, mantendo Excel como cliente, auditoria e formato de migracao.
O workbook deixa de ser o unico motor, mas continua capaz de exportar/importar dados completos e operar em modo offline reduzido.
E a aposta de longo prazo para SaaS, com maior custo e maior potencial de escala.

## Escopo (módulos tocados)

- Novo diretorio de backend, por exemplo `backend/` ou `services/credenciamento-api/`.
- `src/vba/Api_Client.bas` novo.
- `src/vba/Adapter_Excel.bas` novo.
- `src/vba/Adapter_Api.bas` novo.
- `src/vba/Svc_*` fronteira de casos de uso.
- `src/vba/Mod_Types.bas`.
- `src/vba/Importador_V3.bas` para empacotar clientes/adaptadores.
- Rotas de cadastro nos forms.
- Export/import de planilha.
- Testes VBA e testes do backend.

## Mudanças estruturais

- Criar uma API local/remota com contratos equivalentes aos casos de uso:
  - cadastrar empresa;
  - cadastrar entidade;
  - cadastrar servico;
  - credenciar empresa;
  - emitir Pre-OS/OS;
  - registrar avaliacao;
  - exportar/importar snapshot completo.
- Excel passa a ter dois adaptadores:
  - `Adapter_Excel`: opera diretamente nas abas, modo offline/soberano.
  - `Adapter_Api`: chama backend e sincroniza resultado para abas.
- Backend usa banco transacional, mas sempre exporta workbook/CSV completo.
- Workbook mantem schema de auditoria: IDs, AR1 ou sequencias, logs e evidencias devem ser reconstituiveis.
- Introduzir "modo municipio soberano": se SaaS indisponivel, o operador consegue exportar dados e seguir via planilha.

## Mudanças em Mod_Types.bas (TABU LIBERADO PARA V207 — pode propor)

Necessarias:

- DTOs serializaveis:
  - `TApiEmpresa`
  - `TApiEntidade`
  - `TApiServico`
  - `TApiCredenciamento`
  - `TApiPreOS`
  - `TApiOS`
  - `TApiAvaliacao`
- `TApiResponse`
  - `sucesso`
  - `statusCode`
  - `mensagem`
  - `payload`
  - `requestId`
- `TSyncSnapshot`
  - versao do schema;
  - data;
  - contagens;
  - hashes por aba.

Como VBA nao tem JSON ergonomico nativo, os tipos precisam ser simples e acompanhados por serializadores pequenos e testados.

## Mudanças em Importador_V3.bas (TABU LIBERADO PARA V207 — pode propor)

Necessarias se o backend entrar no pacote:

- Manifesto aceita artefatos nao-VBA controlados, como schema JSON, cliente API gerado ou arquivo de configuracao.
- Preflight valida que endpoints/configuracoes obrigatorias existem, mas sem segredos no repo.
- Importador registra versao do contrato API no `App_Release`.
- Modo `offline-only` deve continuar importavel sem backend.

Nao recomendar empacotar binarios grandes pelo V3. Melhor versionar cliente VBA e schema, e instalar backend por fluxo separado.

## Bateria de testes nova necessária

- Testes backend:
  - unitarios de regra;
  - testes de API;
  - migracao de snapshot;
  - idempotencia por chave de requisicao.
- Testes VBA:
  - `Adapter_Excel` preserva comportamento atual;
  - `Adapter_Api` trata sucesso, erro, timeout e modo offline;
  - export/import roundtrip entre workbook e backend.
- Testes de soberania:
  - exportar todos os dados do SaaS para planilha;
  - abrir planilha sem servidor;
  - validar contagens, IDs, auditoria e relatorios.
- Testes E2E_CADASTROS continuam obrigatorios.

## Estimativa de custo (ondas, complexidade)

- 12 a 20 ondas para uma primeira versao confiavel.
- Complexidade alta.
- Exige decisao de stack, operacao, seguranca, migração, suporte e governanca de dados.

Sequencia sugerida:

1. Definir contrato de dados e export/import.
2. Criar backend minimo apenas para cadastros.
3. Criar `Adapter_Api` em modo experimental.
4. Rodar dual-write auditavel: Excel escreve e backend confere, sem ser fonte primaria.
5. Promover backend para fonte primaria em um fluxo pequeno.
6. Manter export workbook obrigatorio em todos os gates.
7. Migrar Pre-OS/OS/avaliacao apenas depois de cadastros estarem estaveis.

## Estimativa de speedup em PC antigo (vs baseline atual)

- Cadastros simples: 2x a 6x se rede/backend forem rapidos; pode ser pior em conexao ruim.
- Operacoes batch e relatorios: 5x a 20x quando movidas para banco/API.
- Abertura/reload do workbook: melhora so se listas forem paginadas/cacheadas; caso contrario Excel ainda paga custo de renderizacao.

Essa proposta deve medir latencia e offline desde o primeiro prototipo.

## Riscos

- Maior risco de aprisionamento se export/import nao for tratado como contrato constitucional.
- Backend aumenta superficie de seguranca, deploy, backup e suporte.
- Excel + API pode gerar divergencia se dual-write nao for cuidadosamente auditado.
- Reescrever regra de negocio fora do VBA pode introduzir divergencias silenciosas.
- Municipio com infraestrutura limitada pode depender mais do modo offline do que do SaaS.

## Como rollback se der errado

- Nunca remover `Adapter_Excel`.
- Backend entra primeiro como sombra/validador, nao como fonte primaria.
- Feature flag por workbook: `MODO_PERSISTENCIA=EXCEL|API|DUAL`.
- Export completo antes de cada migracao.
- Se API falhar, workbook volta a `EXCEL` e continua operando com dados locais.
- Contrato de dados versionado e teste roundtrip obrigatorio antes de promover qualquer fluxo.

## Por que esta proposta vs as outras 2

Escolher esta proposta se a meta estrategica for SaaS real e escala multi-municipio. Ela e a melhor para produto de longo prazo, mas e a pior para estabilizacao curta. So deve ser escolhida se Mauricio aceitar que V207 vira uma linha de arquitetura e migracao, nao apenas uma linha de performance/correcoes.
