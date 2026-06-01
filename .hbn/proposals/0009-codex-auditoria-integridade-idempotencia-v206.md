---
titulo: Auditoria Codex - integridade referencial e idempotencia V206
diataxis: explanation
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Auditoria Codex - integridade referencial e idempotencia V206

## 1. Veredito tecnico

Auditoria read-only, sem implementacao. A raiz canonica foi validada antes da leitura: `pwd` e `git rev-parse --show-toplevel` apontaram para `/Users/macbookpro/Projetos/Credenciamento`; a branch local observada foi `codex/v12-0-0206-planejamento`.

Minha conclusao e que a hipotese F-NEW6 procede, mas precisa ser refinada:

- Para `DIAG_PREOS_INTEGRITY`, a causa e direta: `Svc_PreOS.EmitirPreOS` grava IDs em `PRE_OS` sem `NumberFormat = "@"` e `Repo_PreOS.BuscarPorId` hidrata com `CStr` puro. Isso explica `EMP_PRESEL=001` e `EMP_PREOS=1`.
- A mesma classe de erro existe em `Repo_PreOS`, `Repo_OS`, `Svc_OS` ao preencher `PREOS_OS_ID`, fixtures e rotas historicas de `Preencher.bas`.
- Para F-NEW5, a mesma classe pode afetar IDs de `CREDENCIADOS`, `CAD_SERV` e `ATIVIDADES`, mas ela nao explica sozinha `STATUS_CRED` vazio. O codigo-fonte inspecionado grava `STATUS_CRED_ATIVO` em `Credencia_Empresa.frm:178`, depois registra auditoria e so entao incrementa o contador de novos credenciamentos. Nao encontrei rotina em `src/vba/` que limpe `COL_CRED_STATUS`, e `ClassificaCredenciadoOrdem` apenas ordena a faixa `A:O`.
- Portanto F-NEW5 tem dois vetores candidatos: uma falha real de integridade de IDs em colunas de credenciamento ou servico, mais uma divergencia workbook/import/espelho ou escrita parcial ainda nao evidenciada para o status vazio.

O drift `Cadastro_Servico.frm` vs `.code-only.txt` e independente da causa de dados: e quebra de disciplina M9/L22-L24. Deve ser corrigido por ressincronizacao do espelho importavel antes de novo RVS, mas nao e a raiz do mismatch `001` vs `1`.

## 2. Analise dos 3 vetores

### 2.1 V2_SMOKE drift em `Cadastro_Servico.frm`

O RVS apontou divergencia estrutural entre `.frm` e `.code-only.txt`. A versao fonte tem alteracoes recentes em pontos de gravacao de ID: atividade nova em `src/vba/Cadastro_Servico.frm:127-132` e servico novo em `src/vba/Cadastro_Servico.frm:164-167`.

O ponto relevante nao e a diferenca de 128 caracteres em si, mas a consequencia operacional: o Importador V3 pode importar um espelho `.code-only.txt` diferente do `.frm` auditado. Se o workbook validado recebeu codigo stale, qualquer analise apenas de `src/vba/Cadastro_Servico.frm` deixa de ser prova suficiente do comportamento em tela.

Conclusao: corrigir com resync `publicar_vba_import_v2.sh --apply` em onda propria, seguindo PHAGOCYTOSIS M9 e L22-L24. E uma correcao pequena, mas deve anteceder nova validacao porque invalida a confianca no pacote importado.

### 2.2 `DIAG_PREOS_INTEGRITY`

O caminho reprodutivel esta claro:

- `src/vba/Teste_V2_Roteiros.bas:3666-3678` chama `SelecionarEmpresa` e registra `EMP_PRESEL`.
- `src/vba/Teste_V2_Roteiros.bas:3696` chama `EmitirPreOS`.
- `src/vba/Svc_PreOS.bas:189-205` grava `PRE_OS` diretamente, incluindo `COL_PREOS_ID`, `COL_PREOS_ENT_ID`, `COL_PREOS_COD_SERV`, `COL_PREOS_EMP_ID`, `COL_PREOS_ATIV_ID` e `COL_PREOS_OS_ID`, sem formatar essas celulas como texto.
- `src/vba/Repo_PreOS.bas:78-83` encontra a linha com `IdsIguais`, mas hidrata `PREOS_ID`, `ENT_ID`, `ATIV_ID`, `SERV_ID` e `EMP_ID` via `CStr` direto.
- `src/vba/Teste_V2_Roteiros.bas:3705-3714` compara `pre.EMP_ID = empPresel` por igualdade textual direta.

Se Excel converte `"001"` em numero `1`, `IdsIguais` ainda consegue localizar a linha, mas a hidratacao devolve `"1"`. Isso preserva algumas buscas e quebra diagnosticos, mensagens, logs, chaves compostas e qualquer comparacao textual direta posterior.

### 2.3 F-NEW5: rodizio sem empresas para credenciamento novo

O fluxo de credenciamento manual escreve a linha em `CREDENCIADOS`:

- `src/vba/Credencia_Empresa.frm:133-155` monta `ativId`, `servId` e `codAtivServ`.
- `src/vba/Credencia_Empresa.frm:164-180` grava a linha nova.
- Apenas `COL_CRED_ID` recebe `NumberFormat = "@"` em `src/vba/Credencia_Empresa.frm:165`.
- `COL_CRED_COD_ATIV_SERV`, `COL_CRED_EMP_ID` e `COL_CRED_ATIV_ID` sao gravados sem formatacao textual em `src/vba/Credencia_Empresa.frm:167-175`.
- `COL_CRED_STATUS` recebe `STATUS_CRED_ATIVO` em `src/vba/Credencia_Empresa.frm:178`.

O rodizio le credenciamentos por `Repo_Credenciamento.BuscarFila`, que usa `IdsIguais` em `src/vba/Repo_Credenciamento.bas:39`; isso reduz o risco de falha por `001` vs `1` na selecao por atividade. Depois `Svc_Rodizio.SelecionarEmpresa` rejeita linhas cujo `cred.STATUS_CRED <> STATUS_CRED_ATIVO` em `src/vba/Svc_Rodizio.bas:72`.

Logo, se `STATUS_CRED` realmente esta vazio no workbook apos a UI confirmar `Novos credenciamentos: 1`, o problema nao esta explicado apenas por `NumberFormat`. As hipoteses mais provaveis sao:

- o workbook executou codigo diferente do `.frm` auditado por drift de importacao;
- a linha observada no relatorio nao e a mesma linha gravada pelo clique, por ordenacao, filtro ou reload;
- houve erro/rollback parcial nao capturado entre escrita de colunas e exibicao do relatorio;
- algum artefato fora de `src/vba/` ou estado do workbook esta alterando a coluna, embora nao haja evidencia disso no codigo lido.

Recomendacao imediata: antes de mexer em regra de rodizio, rodar macro de diagnostico que registre, logo apos `CR_Credenciar_Click`, linha, `CRED_ID`, `COD_ATIV_SERV`, `EMP_ID`, `ATIV_ID`, `STATUS_CRED`, `VarType` e `NumberFormat` das colunas criticas.

## 3. Mapa de gravacao de IDs

| Aba/coluna | Pontos de gravacao | `NumberFormat="@"` antes? | Canoniza com `Pad3`/equiv.? | Hidratacao suscetivel |
|---|---|---:|---:|---|
| `EMPRESAS!COL_EMP_ID` | `Repo_Empresa.Inserir` em `src/vba/Repo_Empresa.bas:258-263`; cadastro alternativo em `src/vba/Menu_Principal.frm:2271-2278`; fixtures em `src/vba/Teste_V2_Engine.bas:1132` e `src/vba/Teste_Bateria_Oficial.bas:1761`; copia ativa/inativa em `src/vba/Altera_Empresa.frm:494` e `src/vba/Reativa_Empresa.frm:314` | Sim nos dois caminhos recentes de producao; copia preserva formato; fixtures nao | Sim via `ProximoId`; fixtures usam helpers proprios | `Repo_Empresa.LerEmpresa` hidrata `EMP_ID` com `CStr` em `src/vba/Repo_Empresa.bas:26` |
| `ENTIDADE!COL_ENT_ID` | Cadastro em `src/vba/Menu_Principal.frm:1623-1635`; copia ativa/inativa em `src/vba/Altera_Entidade.frm:198` e `src/vba/Svc_Entidade.bas:109`; fixture em `src/vba/Teste_V2_Engine.bas:1093` | Sim no cadastro atual; copia preserva formato; fixtures nao | Sim via `Format(...,"000")`/helpers | Leituras variam; `Svc_Entidade` normaliza chave em helper proprio, mas nao ha helper geral de hidratacao textual |
| `ATIVIDADES!COL_ATIV_ID` | `Cadastro_Servico.frm:127-132`; `Preencher.bas:1676`; reset/import em `Preencher.bas:2420`, `Preencher.bas:2870`, `Preencher.bas:3070`, CSV V3 em `Preencher.bas:3640-3641`; fixtures em `Teste_V2_Engine.bas:1073`, `Teste_V2_Engine.bas:3136`, `Teste_Bateria_Oficial.bas:1692` | Sim em `Cadastro_Servico` e CSV V3; nao nos caminhos legados/fixtures citados | Geralmente sim por `ProximoId`/`Format`, mas disperso | Leitura de atividades e filtros ainda misturam `CStr`, `Pad3` local e `IdsIguais` |
| `CAD_SERV!COL_SERV_ID` | `Cadastro_Servico.frm:164-166`; `Preencher.bas:2918`; fixtures em `Teste_V2_Engine.bas:1073-1074`, `Teste_Bateria_Oficial.bas:960-961`, `Teste_Bateria_Oficial.bas:1697-1698` | Sim no servico novo de `Cadastro_Servico`; nao nos caminhos historicos/fixtures | Sim ou literal `"001"` nos seeds; disperso | Comparacoes por `IdsIguais` em partes do servico, mas ha `Pad3` local direto em `Cadastro_Servico.frm:288` |
| `CAD_SERV!COL_SERV_ATIV_ID` | `Cadastro_Servico.frm:167`; `Preencher.bas:2919`; fixtures citadas acima | Nao no caminho novo de servico | Valor vem de `ativId`, mas sem helper de escrita | Se Excel armazenar como numero, hidratacao/comparacao textual direta pode divergir |
| `CREDENCIADOS!COL_CRED_ID` | `Credencia_Empresa.frm:164-166`; fixtures em `Teste_V2_Engine.bas:1183-1192`, `Teste_Bateria_Oficial.bas:1827-1836` | Sim no caminho UI; fixtures nao | Sim via `ProximoId`/helpers | `Repo_Credenciamento.LerCredenciamento` usa `CStr` em `src/vba/Repo_Credenciamento.bas:392` |
| `CREDENCIADOS!COL_CRED_COD_ATIV_SERV` | `Credencia_Empresa.frm:167`; fixtures | Nao | Montado como `ativId & servId`; sem helper de cod composto | `Repo_Credenciamento.LerCredenciamento` usa `CStr` em `src/vba/Repo_Credenciamento.bas:395` |
| `CREDENCIADOS!COL_CRED_EMP_ID` | `Credencia_Empresa.frm:168`; fixtures | Nao | `empId` ja deveria estar textual, mas nao e garantido | `Repo_Credenciamento.LerCredenciamento` usa `CStr` em `src/vba/Repo_Credenciamento.bas:393` |
| `CREDENCIADOS!COL_CRED_ATIV_ID` | `Credencia_Empresa.frm:175`; `Svc_Rodizio.RestaurarCredenciamentosEmpresa` em `src/vba/Svc_Rodizio.bas:564-570`; inativacao marca `"X"` em `src/vba/Altera_Empresa.frm:525-528`; fixtures | Nao | `Pad3` antes no credenciamento; restauracao usa `Left$(codItem,3)`; `"X"` e sentinela | `Repo_Credenciamento.LerCredenciamento` usa `CStr` em `src/vba/Repo_Credenciamento.bas:394` |
| `PRE_OS!COL_PREOS_ID`, `ENT_ID`, `COD_SERV`, `EMP_ID`, `ATIV_ID`, `OS_ID` | `Svc_PreOS.EmitirPreOS` em `src/vba/Svc_PreOS.bas:189-205`; `Repo_PreOS.Inserir` em `src/vba/Repo_PreOS.bas:28-41`; `Svc_OS.EmitirOS` preenche `COL_PREOS_OS_ID` em `src/vba/Svc_OS.bas:171-173` | Nao | `PREOS_ID` vem de `ProximoId`; FKs dependem do caller; `ExtrairIdsCodServico` nao garante `Pad3` em `src/vba/Svc_PreOS.bas:497-510` | `Repo_PreOS.BuscarPorId` hidrata com `CStr` em `src/vba/Repo_PreOS.bas:78-83`; `Svc_OS.LerPreOSCompleto` tambem usa `CStr` em `src/vba/Svc_OS.bas:431-439` |
| `CAD_OS!COL_OS_ID`, `ENT_ID`, `COD_SERV`, `EMP_ID`, `ATIV_ID`, `PREOS_ID` | `Repo_OS.Inserir` em `src/vba/Repo_OS.bas:27-42`; fixtures em `Teste_V2_Engine.bas:3462-3480` | Nao | `OS_ID` vem de `ProximoId`; FKs dependem do caller | `RepoOS_BuscarPorId` hidrata com `CStr` em `src/vba/Repo_OS.bas:79-92` |
| `AVALIACOES` | Nao encontrei aba/constantes `AVALIACOES` no mapeamento vigente. Avaliacoes persistem em `CAD_OS` via `Repo_Avaliacao.Inserir` em `src/vba/Repo_Avaliacao.bas:31-79` | N/A | N/A | Risco passa por `CAD_OS.OS_ID` e `CAD_OS.EMP_ID`, nao por aba separada |
| `AUDIT_LOG!COL_AUDIT_ID` e `COL_AUDIT_ID_AFETADO` | `Audit_Log.RegistrarEvento` em `src/vba/Audit_Log.bas:104-110`; chamadas em `Svc_PreOS`, `Svc_OS`, `Svc_Avaliacao`, `Svc_Rodizio`, `Credencia_Empresa`, `Repo_Credenciamento`, `Svc_Transacao` | Nao | `AUDIT_ID` e `linha-1`; `ID_AFETADO` recebe string do caller, inclusive valores nao numericos como `"CAD_OS"` ou `"CONFIG"` | `RepoEmpresa_UltimaReativacaoAudit` usa `IdsIguais` em `src/vba/Repo_Empresa.bas:595-600`; outros consumidores podem ler texto cru |

Observacao: fixtures V1/V2 continuam como debito V207 se a decisao for nao tocar nelas em estabilizacao V206. Mesmo assim, elas influenciam o workbook de teste e ja demonstram mistura de `String` e `Double`.

## 4. Mapa de comparacoes fora de `Util_Planilha.IdsIguais`

Principais candidatos a comportamento divergente:

| Ponto | Tipo | Comentario |
|---|---|---|
| `src/vba/Menu_Principal.frm:3035-3047` | funcao privada `IdsIguais` | Duplica a semantica central. Chamadas em buscas de entidade/empresa/credenciamento no proprio form. Mesmo quando correta hoje, e drift risk. |
| `src/vba/Preencher.bas:1564-1577` | funcao privada `IdsIguais` | Duplica a semantica central em rotina historica de preenchimento/importacao. |
| `src/vba/Credencia_Empresa.frm:388-401` | `IdsIguaisCred` privado | Duplica a semantica central; usado em `CredJaExiste`, listagem e contagens em `src/vba/Credencia_Empresa.frm:152`, `305`, `333`, `347`, `372`. |
| `src/vba/Cadastro_Servico.frm:288` | `Pad3(...) = Pad3(...)` | Tolerante para numeros, mas nao passa pelo contrato central e depende de `Pad3` que recebe `Long`. |
| `src/vba/Teste_V2_Roteiros.bas:3714` | igualdade direta | E a falha atual: compara `pre.EMP_ID = empPresel` depois de hidratacao `CStr`. |
| `src/vba/Teste_Bateria_Oficial.bas:2239-2240` | helper de fixture | `BA_IdsIguaisCanonico` nao e o helper central. Serve como teste, mas pode divergir do produto. |
| `src/vba/Teste_Bateria_Oficial.bas:1854`, `1923`, `2008`, `2018` | helper de fixture | Comparacoes de EMP_ID fora do helper central. |

Nao recomendo trocar tudo mecanicamente no mesmo microdelta. Primeiro deve existir helper oficial de leitura/escrita textual. Depois, substituir comparacoes por camadas, com teste por dominio.

## 5. Idempotencia das operacoes safe_track

Definicao usada: rodar a mesma operacao duas vezes consecutivas, sem mudanca de input, deve deixar o mesmo estado final e nao produzir efeito colateral cumulativo. Para `AUDIT_LOG`, trato duplicacao de log como quebra de idempotencia observavel, ainda que o estado de negocio nao duplique.

| Operacao | Idempotente hoje? | Onde quebra | Severidade |
|---|---:|---|---|
| `Repo_Empresa.Inserir` | Nao | Sempre gera novo ID e nova linha em `src/vba/Repo_Empresa.bas:258-280`; duplicidade depende de validacao externa. | Alta |
| `Repo_Empresa.Atualizar` | Parcial | Atualiza mesma linha, mas `COL_EMP_DT_ULT_ALT = Now` em `src/vba/Repo_Empresa.bas:360` muda em repeticao. | Media |
| `Repo_Empresa.GravarStatusEmpresa` | Parcial | Mesmo status fica igual, mas `DT_ULT_ALT` muda em `src/vba/Repo_Empresa.bas:119`; reativacao/suspensao podem gerar logs fora do repo. | Media |
| `Credencia_Empresa.CR_Credenciar_Click` | Parcial | `CredJaExiste` evita duplicar linha existente, mas a rotina grava varios servicos em loop; falha parcial deixa subconjunto gravado e repeticao pode completar estado diferente. | Media/Alta |
| `Cadastro_Servico.S_Cadastrar_SV_Click` | Parcial | `ServicoJaExiste` e `AtividadeJaExiste` reduzem duplicacao, mas atividade criada antes de falha no servico muda o segundo run. | Media |
| `Svc_PreOS.EmitirPreOS` | Nao | Chama rodizio, registra indicacao e grava nova `PRE_OS` em `src/vba/Svc_PreOS.bas:189-205`. Repeticao pode avancar fila ou criar pendencias. | Alta |
| `Svc_OS.EmitirOS` | Parcial | Depois de sucesso, segunda chamada tende a bloquear por status da Pre-OS; se falhar apos criar OS e antes de concluir fila, fica estado parcial nao reversivel por retry. | Alta |
| `Svc_Avaliacao.RegistrarAvaliacao`/`AvaliarOS` | Nao estrita | Sucesso conclui OS; segunda chamada rejeita por status e pode duplicar auditoria de rejeicao em `src/vba/Svc_Avaliacao.bas:287-292`. Falha apos persistir avaliacao e antes de avancar fila tambem e critica. | Alta |
| `Svc_Rodizio.AvancarFila` | Nao | Move final em `src/vba/Svc_Rodizio.bas:190-195` e `Repo_Credenciamento.MoverFinal` altera posicao/data em `src/vba/Repo_Credenciamento.bas:138-150`; recusas incrementam contadores. | Alta |
| `Svc_Rodizio.SelecionarEmpresa` | Nao | Nao e leitura pura: pode reativar suspensao expirada, mover fila em OS/PreOS pendente e registrar indicacao em `src/vba/Svc_Rodizio.bas:90`, `112`, `132`. | Alta |
| `Util_Sanear_Contadores.SanearContadoresAR1` | Sim, por desenho | Guarda monotonica em `src/vba/Util_Sanear_Contadores.bas:149-160`; repeticao preserva AR1 apos primeiro saneamento. | Baixa |
| `IniciarSistema`/`Auto_Open` | Parcial | `src/vba/Auto_Open.bas:9-18` protege abas, chama `CargaInicialCNAE_SeNecessario(False)` e verifica backfill pendente. Deve ser idempotente se esses helpers forem, mas pode mutar workbook no open. | Media |

Ponto transversal: `Audit_Log.RegistrarEvento` em `src/vba/Audit_Log.bas:104-110` e append-only. Qualquer operacao repetida que chama auditoria deixa rastro cumulativo. Isso pode ser aceitavel como trilha operacional, mas nao pode ser ignorado em testes de idempotencia.

## 6. Integridade referencial esperada

Invariantes minimas para freeze V206:

| Invariante | Estado atual da cobertura |
|---|---|
| `CREDENCIADOS.EMP_ID` existe em `EMPRESAS.EMP_ID` ou `EMPRESAS_INATIVAS.EMP_ID` | Nao encontrei auditoria completa. Buscas operacionais usam `IdsIguais` em partes, mas nao ha gate global. |
| `CREDENCIADOS.ATIV_ID` existe em `ATIVIDADES.ATIV_ID` | Deve tolerar sentinela `"X"` apenas enquanto empresa esta inativa. Fora disso, `"X"`, vazio ou numero sem canonizacao deve reprovar. |
| `CREDENCIADOS.COD_ATIV_SERV` corresponde a `Pad3(ATIV_ID) & Pad3(SERV_ID)` e existe em `CAD_SERV` | Nao ha verificador global. Risco alto porque `COD_ATIV_SERV` e FK composta gravada sem helper textual. |
| `CREDENCIADOS.STATUS_CRED` e valido | Para empresa ativa e credenciamento operacional, deve ser `ATIVO`, `SUSPENSO` ou estado previsto. Vazio em linha nova deve bloquear freeze. |
| `PRE_OS.EMP_ID`, `PRE_OS.ATIV_ID`, `PRE_OS.COD_SERV` existem e combinacao `(EMP_ID, ATIV_ID)` tem credenciamento `ATIVO` | Nao encontrei auditoria global. A falha atual mostra que a suite detecta um sintoma, nao a matriz completa. |
| `CAD_OS.PREOS_ID` existe em `PRE_OS` e EMP/ATIV/COD_SERV sao coerentes com a Pre-OS | Existe diagnostico parcial em `RepoOS_DiagnosticarReferenciasCADOS` para `CAD_OS.EMP_ID` e `CAD_OS.ATIV_ID`, com normalizacao privada em `src/vba/Repo_OS.bas:274-340` e `477-490`. Nao cobre todo o grafo. |
| Avaliacoes referenciam OS existente | No modelo vigente, avaliacao escreve em `CAD_OS`, nao em aba `AVALIACOES`. A invariante e: OS avaliada deve existir, estar em estado avaliavel antes da escrita e manter EMP_ID/ATIV_ID canonicos. |
| `AUDIT_LOG.ID_AFETADO` e resolvivel | Precisa ser type-aware: ha eventos com IDs operacionais e eventos com tokens como `"CAD_OS"` ou `"CONFIG"`. Um verificador numerico cego geraria falso positivo. |

Macros minimas recomendadas para antes de freeze:

1. `AuditarIdsTextuaisOperacionais`: varrer colunas de ID/FK, emitir CSV com aba, linha, coluna, valor exibido, `VarType`, `NumberFormat`, valor canonico esperado e status.
2. `AuditarIntegridadeCredenciamentos`: validar `CREDENCIADOS` contra `EMPRESAS`/`EMPRESAS_INATIVAS`, `ATIVIDADES`, `CAD_SERV` e dominio de `STATUS_CRED`.
3. `AuditarIntegridadePreOSOS`: validar `PRE_OS` contra credenciamento ativo e `CAD_SERV`; validar `CAD_OS.PREOS_ID` contra `PRE_OS` e consistencia de EMP/ATIV/COD.
4. `AuditarIntegridadeAvaliacoes`: como hoje avaliacao esta em `CAD_OS`, validar status avaliados, notas/strikes e referencias de OS.
5. `AuditarAuditLogReferencias`: validar `ID_AFETADO` conforme `COL_AUDIT_ENTIDADE` e `COL_AUDIT_TIPO`, com lista de excecoes textuais permitidas.

Saida minima: CSV em `auditoria/evidencias/V12.0.0205/csv/` ou pasta V206 equivalente, com falha bloqueando freeze quando houver orfao, status vazio, FK invalida ou ID numerico em coluna canonica textual.

## 7. Plano de correcao em camadas

### Camada 1 - helpers compartilhados de escrita

Introduzir helper unico para gravar ID textual: aplicar `NumberFormat = "@"` antes da escrita e gravar valor canonico. O helper precisa aceitar IDs numericos de 3 digitos e, separadamente, codigos compostos como `COD_ATIV_SERV`. Nao recomendo usar `Pad3(ByVal numero As Long)` diretamente como API publica para qualquer `Variant`, porque ela mascara casos nao numericos e nao expressa sentinelas como `"X"`.

Dependencias: decidir se `Svc_PreOS` e `Svc_OS` podem receber excecao de tabu para linhas de escrita de ID. Sem essa excecao, a raiz de `DIAG_PREOS_INTEGRITY` nao e corrigida na producao, pois `Svc_PreOS.EmitirPreOS` grava `PRE_OS` direto.

### Camada 2 - hidratacao consistente

Criar helper de leitura textual canonica para substituir `CStr(ws.Cells(...).Value)` nos repositorios: `Repo_Empresa`, `Repo_Credenciamento`, `Repo_PreOS`, `Repo_OS` e leitores auxiliares em `Svc_OS`. A regra deve retornar `"001"` quando o conteudo numerico/textual representa ID operacional 1, preservar sentinelas documentadas e falhar de forma auditavel para lixo de dados.

Essa camada tambem deve reduzir helpers duplicados: `Menu_Principal.IdsIguais`, `Preencher.IdsIguais`, `Credencia_Empresa.IdsIguaisCred`, `RepoOS_NormalizarChave` privado e helpers de fixture devem convergir para contrato unico ou ficar explicitamente marcados como fixture-only.

### Camada 3 - auditoria continua

Adicionar macros de auditoria referencial e de tipo como gate antes de RVS e antes de freeze. A auditoria deve ser executavel pelo operador, gerar CSV e retornar falha dura quando encontrar status vazio, FK orfa ou ID operacional gravado como numero em coluna que deveria ser textual.

Ela nao substitui RVS. Ela fecha a lacuna de que RVS atual detecta alguns sintomas por fluxo, mas nao prova integridade global do workbook em uso.

### Camada 4 - migracao de dados legados

O workbook em uso ja contem celulas com mistura `String`/`Double`. A migracao deve ser assistida e auditavel:

- backup do workbook antes de tocar dados;
- CSV pre-migracao com valor, tipo e formato;
- normalizacao apenas de colunas canonicas, preservando sentinelas permitidas (`"X"`, vazios estruturais e tokens de auditoria);
- `NumberFormat = "@"` antes de regravar valor canonico;
- CSV pos-migracao;
- RVS e teste tela-a-tela sobre cadastro novo, Pre-OS, OS, avaliacao e rodizio.

## 8. Sequencia de ondas proposta

| Onda | Objetivo | Escopo recomendado | Observacao |
|---|---|---|---|
| 38.2.3-A | Recuperar confianca operacional e resolver F-NEW5 primeiro | Diagnostico do credenciamento novo no workbook real; confirmar linha gravada, status, tipos e formatos; corrigir causa direta do `STATUS_CRED` vazio se confirmada; ressincronizar `Cadastro_Servico.frm` e `.code-only.txt` | Nao iniciar refatoracao de IDs antes de saber por que o status aparece vazio. |
| 38.2.3-B | Corrigir `DIAG_PREOS_INTEGRITY` com menor superficie | Aplicar helper textual somente nos pontos de `PRE_OS`/`CAD_OS` necessarios e ajustar hidratacao de `Repo_PreOS`/`Repo_OS` | Se `Svc_PreOS`/`Svc_OS` seguirem tabu absoluto, registrar decisao humana: a raiz nao e corrigivel sem tocar seus pontos diretos de escrita. |
| 38.2.4 | Sistematizar helpers | Camada 1 e Camada 2 em Repos e UIs nao blindadas, com substituicao controlada de `CStr` e duplicatas de `IdsIguais` | Fazer em safe_track com readback de paths allowed, porque toca comportamento transversal. |
| 38.2.5 | Auditoria e migracao | Macros de integridade, CSV pre/pos e migracao de dados legados no workbook do operador | Rodar RVS e roteiro tela-a-tela apos a migracao. |
| Freeze V206 | Aceite | RVS aprovado, auditorias de integridade sem falhas, F-NEW5 retestado com atividade/servico/empresa novos nao-fixture | Nao antecipar cache, ORM ou `Svc_Cadastro*`; isso fica V207. |

## 9. Riscos e mitigacoes

| Risco | Mitigacao |
|---|---|
| Corrigir apenas `PRE_OS` e deixar `CAD_OS`/audit/logs com mesmo padrao | Tratar escrita e leitura como contrato transversal, nao como hotfix isolado. |
| Trocar comparacoes por helper novo e introduzir regressao silenciosa | Primeiro adicionar auditoria e testes; depois substituir por dominio. |
| Migracao reescrever tokens que nao sao IDs | Helper precisa ser type-aware e ter lista de colunas/sentinelas. Nao normalizar `AUDIT_LOG.ID_AFETADO` cegamente. |
| F-NEW5 ser causado por workbook stale, nao por fonte atual | Antes de implementar, comparar pacote importado, `.frm`, `.code-only.txt` e dump imediato pos-clique. |
| `Svc_*` blindados impedirem correcao da raiz | Pedir hearback explicito para excecao minima nas linhas de escrita/leitura de IDs, ou aceitar mitigacao parcial documentada. |
| RVS fixture continuar mascarando fluxo real | Incluir teste nao-fixture: criar atividade, servico, credenciar empresa, emitir Pre-OS, OS e avaliar usando dados novos da sessao. |

## 10. Divergencia relevante com Antigravity

O arquivo paralelo `0010-antigravity-auditoria-integridade-idempotencia-v206.md` ja existe no workspace. Minha divergencia tecnica principal e a seguinte: eu nao considero provado que F-NEW6 explica integralmente o `STATUS_CRED` vazio. A classe de erro `NumberFormat`/`CStr` explica o mismatch `001` vs `1` e pode quebrar relacionamentos em credenciamento, mas `STATUS_CRED` e uma coluna de estado textual, nao um ID. No fonte auditado, ela e preenchida explicitamente antes da confirmacao de sucesso. Portanto, a Onda 38.2.3 deve tratar F-NEW5 como incidente de duas frentes: integridade de IDs e verificacao do estado real importado no workbook.
