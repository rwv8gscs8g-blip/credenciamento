# 18. Auditoria de Publicação Oficial — Linha Pública V12.0.0202

**Versão auditada:** `V12.0.0202`
**Branch técnica auditada:** `codex/v180-stable-reset` (head em `4d8929f`)
**Branch padrão remota (`origin/main`):** ainda **não recebeu o corte público**
**Licença pública vigente:** TPGL v1.1
**Modelo público:** source-available, auditável, com conversão automática para Apache License 2.0 quatro anos após cada publicação
**Data desta auditoria:** 2026-04-20
**Revisor:** Claude (auditoria automatizada profunda, sob supervisão do mantenedor)

---

## 00. Veredito Executivo

**Decisão:** **PUBLICAR COM RESSALVAS BLOQUEANTES.**

A linha técnica está honesta, o pacote institucional está acima da média, a licença TPGL v1.1 está bem fundamentada e a estrutura de testes é proporcional. O repositório está em condição de virar a linha oficial pública assim que **quatro pendências de saneamento** forem fechadas:

1. mover o conteúdo da branch `codex/v180-stable-reset` para `main`, porque hoje quem visita o GitHub vê a árvore antiga;
2. criar a tag git `v12.0.0202` correspondendo ao commit publicado;
3. tratar a senha de proteção de abas hoje embutida no código (token institucional anterior, ofuscado por `ChrW$`) — trocar a string ou explicitar formalmente que é um token operacional sem valor de segredo;
4. publicar evidência mínima da Bateria Oficial e da V2 da release atual, ainda que como CSV exportado, para sustentar o status `VALIDADO`.

Sem esses quatro pontos, o repositório passa por uma auditoria positiva no que diz respeito ao **conteúdo**, mas falha em **coerência narrativa, rastreabilidade de release e higiene mínima de segurança operacional**. Com esses quatro pontos resolvidos, recomendo seguir para nova auditoria externa independente em até **duas sprints curtas** (estimativa: cinco a sete dias úteis de trabalho focado).

---

## 01. Explicação para Humanos Não Técnicos

Esta seção é escrita para quem precisa decidir se este repositório está pronto para virar a linha pública oficial sem necessariamente entender de programação ou de licenças.

### O que está bom

O repositório já se comporta como um repositório institucional sério. Ele tem todos os documentos públicos esperados: explicação geral do projeto (README), licença formal (LICENSE), termo para quem quiser contribuir (CLA), política de segurança (SECURITY), guia de contribuição (CONTRIBUTING), código de conduta (CODE_OF_CONDUCT), histórico de mudanças (CHANGELOG), documentação técnica (docs/), trilha de auditoria (auditoria/) e um arquivo central de status oficial das versões. A licença escolhida — TPGL v1.1 — foi formalizada com parecer técnico-jurídico próprio (documento 17 da auditoria) e empacotada em um documento institucional Word. Isso é incomum em repositórios públicos: a maioria dos projetos abertos só publica um arquivo `LICENSE` e nenhuma justificativa.

A estrutura de código também já está bem organizada em camadas (`Svc_*` para regras de negócio, `Repo_*` para persistência, `Util_*` para utilidades, `Teste_*` para testes), o que ajuda qualquer auditor externo a entender por onde começar a leitura.

### O que ainda é frágil

A principal fragilidade não está no que foi feito, e sim no que ainda não foi publicado da maneira correta. A versão arrumada do repositório existe numa branch técnica chamada `codex/v180-stable-reset`. A branch principal do GitHub, chamada `main`, ainda contém a versão antiga, com material interno de trabalho que o próprio plano de corte (documento 15 da auditoria) já decidiu retirar. Em outras palavras: alguém que entre no GitHub agora vê a árvore antiga, não a árvore arrumada. Isso precisa ser resolvido antes de qualquer comunicação pública dizer que a linha oficial está disponível.

Em segundo lugar, falta uma "etiqueta" formal (tag git) marcando que o commit atual é a `V12.0.0202`. Hoje, o último marco etiquetado é uma versão antiga, da família `V12.0.0166`. Para um auditor, é como ter uma certidão dizendo que o documento existe, mas sem registro no cartório. Resolver isso é um comando único de git.

Em terceiro lugar, há um detalhe pequeno mas importante de segurança operacional: o sistema usa uma senha para proteger as abas do Excel, e essa senha está disfarçada dentro do código por uma técnica que qualquer pessoa minimamente familiar com programação consegue desfazer em segundos. O que é discutível não é a técnica em si — a documentação de segurança é honesta ao dizer que essa proteção não vale como criptografia — mas sim o **valor** escolhido para a senha, que carregava nome institucional. Isso pode dar margem a leituras equivocadas sobre vínculo institucional.

Em quarto lugar, o status público das versões diz que a `V12.0.0202` está validada, com bateria de testes verde. Isso é verdade dentro do ambiente do mantenedor, mas o repositório público hoje **não publica evidência objetiva** dessa validação — alguém que precisar conferir tem que confiar na palavra do mantenedor. Para uma trilha de auditoria pública madura, isso ainda é frouxo.

### O que isso significa na prática

Estamos a poucos dias de trabalho de um repositório que pode ser usado como referência por outros municípios, por auditores externos, por procuradorias e por professores. Mas, **hoje**, se alguém abrir o link público, encontra uma versão que não bate com o que está sendo descrito como linha oficial. Isso causaria, em uma auditoria externa séria, um achado bloqueante de "narrativa-versus-realidade", que é mais grave do que qualquer falha técnica isolada — porque indica falta de governança da publicação.

A boa notícia é que **nenhum desses problemas exige refatoração de código, mudança de licença, ou nova rodada de regras de negócio**. Tudo o que falta é higiene de publicação, etiqueta de versão, neutralização cosmética da senha e exportação de evidência.

---

## 02. Pontos Positivos

Esta seção lista, sem inflação, o que o repositório efetivamente entrega bem. Cada item é seguido da explicação do porquê isso é importante.

### 2.1 Pacote institucional público completo

O repositório publica simultaneamente: `README.md`, `LICENSE`, `CLA.md`, `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `CHANGELOG.md`, `docs/INDEX.md`, `docs/ARQUITETURA.md`, `docs/COMPLIANCE_CMMI_ISO.md`, `docs/licenca/README.md`, `auditoria/INDEX.md`, e templates de PR e de issue (incluindo um template específico para reporte privado de segurança).

**Por que importa:** auditores e gestores públicos esperam encontrar essa lista mínima. Sua presença, com conteúdo real e não placeholder, é o primeiro filtro de seriedade. Repositórios oficiais municipais brasileiros raramente têm sequer metade desses arquivos.

### 2.2 Licença formalizada com parecer próprio

A TPGL v1.1 não é uma licença improvisada: foi precedida por um parecer técnico-jurídico de quase 56 mil bytes (`auditoria/17`), um documento institucional Word de 25 páginas A4, e tem cobertura de ordenamento brasileiro (Lei 9.609/98, 9.610/98, 12.527/11, 13.709/18, 13.140/15, 14.133/21).

**Por que importa:** uma licença sem parecer é um ato unilateral fácil de contestar. Uma licença com parecer público e fundamentação cláusula a cláusula é uma posição defensável em qualquer fórum técnico ou jurídico. Para um gestor público que precise adotar o software, ter o parecer disponível antecipa metade da diligência interna.

### 2.3 Posicionamento público coerente como source-available

Toda a comunicação pública (`README.md`, `CONTRIBUTING.md`, `docs/licenca/README.md`, `MANIFEST.md`, `00-DASHBOARD.md`) afirma de forma explícita que o projeto **não** é open source pela definição da OSI, e que a abertura completa virá pela conversão automática para Apache 2.0. Não há resquício de narrativa indevida.

**Por que importa:** marketing-as-open-source é um risco reputacional grande para projetos source-available. Aqui, a coerência narrativa elimina esse risco.

### 2.4 Estrutura de código por camadas explícitas

Os módulos VBA estão organizados em camadas claras: interface (`*.frm`), serviço (`Svc_*.bas`), repositório (`Repo_*.bas`), utilidade (`Util_*.bas`), tipos (`Mod_Types.bas`, `AAA_Types.bas`, `Const_Colunas.bas`), infraestrutura (`AppContext.bas`, `Audit_Log.bas`, `ErrorBoundary.bas`, `App_Release.bas`). A documentação de arquitetura descreve essas camadas e a responsabilidade de cada uma.

**Por que importa:** isso é o que separa um amontoado de macros de um sistema. Em revisão de código, um auditor consegue olhar para `Svc_PreOS.bas` sabendo o que esperar e onde achar a regra; consegue olhar para `Repo_OS.bas` sabendo que ali mora a persistência. Em VBA, isso é raro.

### 2.5 Cobertura proporcional de testes

O repositório tem aproximadamente **6.361 linhas de testes** contra **3.921 linhas de produção** nos módulos centrais (`Svc_*`, `Repo_*`, `Util_*`, `Audit_Log`, `ErrorBoundary`, `AppContext`, `App_Release`). Razão de 162%. A Bateria Oficial está dividida em cinco blocos lógicos (Preparação, Cenário Literal, Expansão, Regressão Técnica, Combinatória, Exportação e Reset). A V2 tem uma engine separada com baseline canônica, fixtures, snapshot operacional, catálogo semântico e quatro tipos de log (`OK`, `FALHA`, `INFO`, `MANUAL_ASSISTIDO`).

**Por que importa:** em projetos VBA, a média histórica é "testar é abrir o Excel e clicar". Aqui há catálogo, baseline, snapshot e log estruturado. Isso vale como linha de partida séria para qualquer trilha de qualidade incremental.

### 2.6 Trilha de auditoria pública vivendo no próprio repositório

A pasta `auditoria/` contém documentos do tipo "auditoria de publicação", "parecer de licenciamento", "fechamento de backlog", "matriz mestre de testes", "auditoria de regras de negócio". Esses documentos não são notas internas: são documentos públicos da própria evolução do sistema, com numeração estável, índice e regra de leitura.

**Por que importa:** isso é o coração de uma trilha CMMI/ISO. Em vez de pedir auditor externo para reconstruir a história, o repositório já entrega a história contada pelo próprio mantenedor, com data e versão. O próximo auditor herda esse trabalho.

### 2.7 Política de governança de versões em arquivo canônico

`obsidian-vault/releases/STATUS-OFICIAL.md` declara, com tabela explícita, qual versão é a `VALIDADA`, quais são `SUPERADAS`, quais foram `REVERTIDAS`, quais permanecem como `HISTORICO_INTERNO`. Há regra de uso explícita ("nenhuma release deve permanecer sem status oficial").

**Por que importa:** evita ambiguidade do tipo "qual versão devo usar". Para integradores externos, esse é o documento que orienta a decisão. Tê-lo como arquivo canônico (e não só como release notes esparsas) é boa prática.

### 2.8 Honestidade sobre maturidade

`docs/COMPLIANCE_CMMI_ISO.md` mapeia adesão a práticas de CMMI e ISO, mas declara explicitamente: *"Ele não afirma certificação formal."* O parecer técnico-jurídico de licença declara: *"Este documento não constitui aconselhamento jurídico formal."* O sumário executivo da auditoria declara que ainda há trabalho a fazer.

**Por que importa:** em comunicação pública, a tentação é inflar maturidade. Aqui, há autoavaliação honesta. Para um auditor externo, é sinal de cultura de governança, não apenas de conformidade aparente.

### 2.9 .gitignore alinhado à decisão de corte público

O `.gitignore` exclui `.xlsm`, `.xlsx`, arquivos temporários do Excel (`~$*`), `.DS_Store`, `BKP_forms/`, `local-ai/`, `backup_bateria_oficial/`, `historico/`, `tests/evidencias/`, `evidence/`, `*.log`, `*.gguf` (modelos de IA local), `obsidian-vault/.obsidian/`. A planilha operacional `PlanilhaCredenciamento-Homologacao.xlsm` está presente no disco mas **não está rastreada** pelo git. Isso significa que a decisão de "não publicar lógica operacional privada" não vive só na documentação: ela é aplicada pela infraestrutura.

**Por que importa:** uma decisão escrita só vale o que vale a sua aplicação. Aqui, o `.gitignore` é o cumprimento real da promessa do `15_PLANO_LINHA_CORTE_PUBLICA`.

### 2.10 Workflow mínimo de verificação de documentação

O workflow `verify-docs.yml` valida, em cada pull request e em cada push para `main` e `codex/v180-stable-reset`, a presença dos arquivos institucionais mínimos e a coerência do `auditoria/INDEX.md` (todo arquivo `.md` em `auditoria/` precisa aparecer no índice).

**Por que importa:** é simples, mas remove a classe inteira de regressões "alguém apagou o LICENSE sem perceber" e "alguém adicionou um parecer e esqueceu de listar no índice". Para a maturidade desejada, esse workflow deve crescer (ver seção 5 e seção 7), mas o ponto de partida está bem.

---

## 03. Problemas e Riscos

A tabela abaixo é o catálogo principal de achados. A coluna **Gravidade** segue quatro níveis explícitos:

- **BLOQUEANTE:** impede chamar o repositório de "linha pública oficial" enquanto não for resolvido.
- **ALTO:** não impede a publicação, mas representa risco material (jurídico, reputacional, de segurança ou de auditoria) que deve ser fechado em curtíssimo prazo.
- **MÉDIO:** melhoria recomendada, fechável dentro do mesmo ciclo de publicação.
- **BAIXO:** refino futuro, fechável quando a equipe tiver banda.

| ID | Achado | Gravidade | Impacto prático | Explicação simples | Correção recomendada | Prazo |
|---|---|---|---|---|---|---|
| **F-01** | A branch `codex/v180-stable-reset` é a árvore arrumada, mas `origin/main` ainda contém a árvore antiga (`HANDOFF.md`, `incoming/`, `scripts/`, `vba_export/`, `vba_import/`, `.cursorrules`, `ESTRATEGIA-V12-106.md`). | **BLOQUEANTE** | Quem visita o GitHub público vê a versão antiga; toda a narrativa do `README` e do `STATUS-OFICIAL` aponta para uma realidade que ainda não foi promovida. Auditoria externa identificaria "narrativa-versus-realidade". | A branch técnica está pronta. A branch que vira o cartão de visita público ainda não foi atualizada. | Mergear `codex/v180-stable-reset` em `main` (preferencialmente como `git push --force-with-lease` controlado, após backup da `main` antiga em tag de arquivo, por exemplo `archive/main-pre-corte-2026-04-20`). | 1 dia |
| **F-02** | Não existe tag git para `V12.0.0202`. Última tag é `v12.0.0166`. | **BLOQUEANTE** | Sem tag, o commit que sustenta o status `VALIDADO` não tem âncora estável; release notes apontam para arquivo, não para um identificador git. Para CMMI CM (configuration management), isso é falha de baseline. | A versão é declarada em arquivo, mas o git não conhece esse marco. | Após F-01, criar tag `v12.0.0202` no commit do main resultante e fazer `git push --tags`. Considerar criar release no GitHub com link para `obsidian-vault/releases/V12.0.0202.md`. | 1 dia |
| **F-03** | Senha de proteção de abas embutida em `Util_Planilha.bas` como `Util_SenhaProtecaoPadrao()` retornando token institucional anterior, ofuscado por `ChrW$`. Decodificável em segundos. | **ALTO** | Riscos cumulativos: (a) leitor pode inferir vínculo institucional indevido pelo nome; (b) a "ofuscação" passa falsa sensação de segredo; (c) `SECURITY.md` afirma que a senha não deve aparecer em texto literal — a regra é cumprida ao pé da letra (não há string literal), mas é violada em espírito (o valor é trivialmente reconstruível). | Está honesto na política, mas o nome escolhido para a senha pode ser lido como afirmação institucional. | Trocar o valor para token neutro (ex.: `cred_v12_pub`), atualizar o `Util_SenhaProtecaoPadrao()` e o `SECURITY.md`. Alternativamente: tornar a senha configurável via parâmetro lido de uma constante interna **não publicada** em `local-ai/`. | 2 dias |
| **F-04** | Não há evidência objetiva, no repositório público, de execução recente da Bateria Oficial e da V2. O status `VALIDADO` repousa em afirmação textual ("compilação limpa por operador humano", "bateria oficial recente sem falhas"). | **ALTO** | Para um auditor externo, isso é insuficiente: para CMMI VER e ISO 9001 9.1, exige-se evidência registrada, não testemunho. O .xlsm operacional não está no repositório (correto), mas então é necessário publicar o **export** mínimo das execuções. | A bateria roda em ambiente local; o resultado não chega ao GitHub. | Adicionar diretório `auditoria/evidencias/V12.0.0202/` contendo CSVs exportados pela `TV2_ExportarUltimaExecucaoCSVs` e pela bateria oficial, com hash SHA-256 anotado no próprio CSV ou em `evidencias/MANIFEST.md`. | 3 dias |
| **F-05** | `LICENSE` em PT-BR está sem acentuação gráfica (48 ocorrências de palavras como "licenca", "publica", "definicao", "conversao"). Restante da documentação institucional (README, CLA, SECURITY, CONTRIBUTING, CODE_OF_CONDUCT) está acentuado corretamente. | **ALTO** | Em uma licença escrita em português do Brasil, a falta de acentos não invalida o instrumento, mas: (a) compromete leitura por procuradoria e por advogados não familiarizados com origem do texto; (b) é incoerente com o resto da documentação; (c) prejudica indexação e busca. | Texto formal em PT-BR sem acento parece rascunho. Está completo, mas não polido. | Reescrever o `LICENSE` em PT-BR com acentuação gráfica plena, mantendo a estrutura, numeração e conteúdo idênticos. Validar contra o texto institucional do `TPGL_v1_1_DOCUMENTO_INSTITUCIONAL.docx`, que já está acentuado. | 2 dias |
| **F-06** | `CHANGELOG.md` registra apenas a entrada `V12.0.0202`. Versões `VALIDADA` anteriores citadas no `STATUS-OFICIAL` (`V12.0.0190`, `V12.0.0191`, `V12.0.0180`) e marcos `SUPERADA`/`REVERTIDA` não aparecem. | **MÉDIO** | Quem chega no repositório sem contexto não consegue reconstruir a evolução pelo CHANGELOG. Keep a Changelog 1.1.0 espera continuidade. Para CMMI CM, é evidência fraca de versionamento. | A história existe nos arquivos de release, mas não está consolidada onde o leitor externo procura primeiro. | Reescrever `CHANGELOG.md` com pelo menos as entradas de `V12.0.0180` em diante, sintetizando cada uma em 2-4 bullets. Pode citar o respectivo arquivo de release como fonte. | 3 dias |
| **F-07** | Os testes vivem dentro de `src/vba/` (`Teste_Bateria_Oficial.bas`, `Teste_V2_*`, `Teste_UI_Guiado.bas`, `Central_Testes*`). Não há separação `src/` ↔ `tests/`. | **MÉDIO** | Dificulta leitura externa: "src/" deveria ser produção. Em uma busca por dependências reais, testes acabam aparecendo como código de aplicação. Para integradores, é fonte de confusão. | Em VBA puro a importação é por arquivo, não por pasta — então a separação física não muda o comportamento, só a legibilidade. | Mover `Teste_*.bas` e `Central_Testes*.bas` para `tests/vba/` (mantendo no .xlsm operacional onde já estão). Ajustar `docs/ARQUITETURA.md`, `auditoria/04_MATRIZ_MESTRE_DE_TESTES.md` e `verify-docs.yml`. | 5 dias |
| **F-08** | `obsidian-vault/00-DASHBOARD.md` está público e contém sintaxe Obsidian (`[[releases/STATUS-OFICIAL]]`) que **não funciona como link no GitHub**, e expõe detalhes operacionais ("Ambiente: Windows 10+, Excel 2019/2021/365", "Planilha: PlanilhaCredenciamento-Homologacao.xlsm"). É citado pelo `docs/INDEX.md` como leitura recomendada. | **MÉDIO** | Leitor externo encontra link quebrado e ruído operacional. `MANIFEST.md` já redireciona para `docs/INDEX.md`, mas o dashboard ainda é citado em `docs/INDEX.md`. | É um arquivo pensado para o Obsidian, indevidamente exposto como leitura pública. | Decidir entre: (a) remover `00-DASHBOARD.md` da publicação e ajustar `docs/INDEX.md`; ou (b) reescrevê-lo em markdown padrão (com `[texto](link)` em vez de `[[link]]`) e remover detalhes operacionais. | 3 dias |
| **F-09** | Pasta `doc/` (legado, dados CNAE) coexiste com `docs/` (institucional). Diferença é apenas o "s". | **MÉDIO** | Confunde leitor. Em ferramentas de busca/explore do GitHub, aparecem em ordem alfabética colados, indistinguíveis. | Convenção comum hoje é `docs/` para documentação institucional e `data/` ou `reference/` para dados estruturais. | Renomear `doc/` para `data/` (ou `reference/`). Atualizar `README.md`, `docs/INDEX.md` e qualquer referência interna. | 3 dias |
| **F-10** | Numeração da pasta `auditoria/` tem buracos (00, 03, 04, 14, 15, 16, 17). | **BAIXO** | Visualmente confuso para auditor externo. `INDEX.md` já alerta ("a ausência de numeração contínua não implica ausência de documento"), mas a explicação não substitui a impressão. | Os documentos 01, 02, 05–13 ficaram em material local. Faltam para fechar a história pública. | Renumerar os documentos públicos para sequência contínua (00, 01, 02, …), mantendo o índice. Alternativa: preservar numeração histórica e adicionar nota explícita de equivalência no `INDEX.md` (ex.: "01–02 e 05–13 são internos; reservados para evitar colisão de identificador"). | 5 dias |
| **F-11** | `App_Release.bas` define `APP_GITHUB_RELEASE_NOTES_URL = "/tree/main/obsidian-vault/releases"`. Como `main` ainda é a árvore antiga (F-01), o link embutido no VBA aponta para diretório que **não existe** no `main` público. | **MÉDIO** | Ao executar o sistema, o link "Ver release notes" leva o usuário a um 404. | Promessa do binário não é cumprida pela árvore pública. | Após F-01, validar manualmente o link. Considerar trocar para apontar para uma tag (`/tree/v12.0.0202/obsidian-vault/releases`) — isso fixa o link e evita arrastar regressões futuras. | 1 dia (após F-01) |
| **F-12** | `CLA.md` cláusula 7 menciona "instrumento complementar assinado pelo representante legal" para contribuições institucionais, mas o repositório **não publica template** desse instrumento. | **MÉDIO** | Empresa ou órgão público que queira contribuir não tem ponto de partida. Manter sem template limita contribuição institucional ou abre espaço para arranjos ad-hoc não rastreáveis. | A licença já abriu o canal, mas não entregou o formulário. | Criar `docs/legal/CLA_INSTITUCIONAL_TEMPLATE.md` com seção de identificação da pessoa jurídica, identificação do representante legal, cláusulas espelhando o CLA pessoal, espaço para assinatura. | 5 dias |
| **F-13** | Não há matriz de rastreabilidade pública entre **regra de negócio** e **teste**. `auditoria/03_AUDITORIA_REGRAS_DE_NEGOCIO.md` enumera regras (rodízio, Pre-OS, OS, avaliação). `auditoria/04_MATRIZ_MESTRE_DE_TESTES.md` enumera camadas. Não há mapeamento "regra X é coberta pela suíte Y, caso Z". | **MÉDIO** | Para CMMI VER, é o ponto central. Sem matriz, "cobertura" é declarativa, não verificável. | A informação existe na cabeça do mantenedor; não está no repositório. | Adicionar `auditoria/19_MATRIZ_RASTREABILIDADE_REGRA_TESTE.md` com tabela: regra → caso de teste (`BA_TesteSuspensaoPorRecusa`, `TV2_RunSmoke`, etc.) → arquivo. | 7 dias |
| **F-14** | Não há catálogo público formal de **invariantes**. Há funções como `TV2_FilaTemOrdemIntegra` que claramente verificam invariantes, mas o conjunto não está listado em parte alguma. | **MÉDIO** | Para evolução futura (shadow mode, comparador V1×V2 — itens D1 e D2 do `14_FECHAMENTO_BACKLOG`), o conjunto de invariantes formais é insumo essencial. Hoje, esse conjunto vive disperso no código. | O sistema **tem** invariantes; só não as **lista**. | Adicionar `auditoria/20_INVARIANTES_DO_DOMINIO.md` com pelo menos: INV-01 fila por atividade ordenada por POSICAO_FILA; INV-02 estado da empresa exclusivo (ATIVA / SUSPENSA / INATIVA); INV-03 transições válidas de Pre-OS; INV-04 transições válidas de OS; INV-05 média de avaliação consistente; INV-06 audit log monotônico; INV-07 hash de release. | 7 dias |
| **F-15** | Workflow `verify-docs.yml` verifica apenas presença de arquivos. Não há linter VBA, não há gate de CHANGELOG, não há gate de coerência entre `STATUS-OFICIAL` e `App_Release.bas`. | **BAIXO** | Regressões silenciosas em CHANGELOG, em coerência de versão, em renomeações de arquivo passam pelo CI. Não é bloqueante, mas é teto baixo. | O CI atual é mínimo. Pode crescer sem grande esforço. | Adicionar checks: (a) `App_Release.bas` contém `APP_RELEASE_ATUAL = "VX.Y.ZZZZ"` igual à versão mais nova `VALIDADA` do `STATUS-OFICIAL`; (b) `CHANGELOG.md` contém entrada para essa versão; (c) lint regex VBA para padrões proibidos (ex.: senhas literais, paths Windows hardcoded). | 7 dias |
| **F-16** | Branch local `feature/v12-r2-mei-elimination-and-test-unification` permanece. | **BAIXO** | Não polui o público diretamente, mas é higiene de repositório. Se ela existir também em `origin`, polui. | Branch antiga, possivelmente obsoleta. | Verificar `git branch -r` no remoto. Se existir, deletar com `git push origin --delete feature/v12-r2-mei-elimination-and-test-unification`. Localmente: `git branch -D`. | 1 dia |
| **F-17** | `Central_Testes_Relatorio.bas` exibe `contato@mauriciozanin.com` em mensagens da bateria. | **BAIXO** | É decisão consciente do mantenedor expor canal. O risco é apenas de spam ou recebimento de prints aleatórios. Não é problema de compliance. | Endereço pessoal é exposto ao operador da bateria. | Avaliar se mantém. Se mantém, considerar migrar para alias institucional (`suporte@…`, `seguranca@…`) ou para canal de issue privada do GitHub. | Refino |
| **F-18** | Tags antigas (`v12.0.0107`, `v12.0.0108`, `v12.0.0111`, `v12.0.0166`) ainda existem no remoto. Conteúdo dessas versões pode incluir material hoje considerado privado. | **BAIXO** | Quem fizer `git checkout v12.0.0107` pode ver árvore antiga. Não vaza segredo, mas pode contradizer a narrativa atual. | Tags são imutáveis e mostram a verdade do passado, que pode incluir o que se quer não-público hoje. | Auditar conteúdo de cada tag antiga. Se houver material privado, considerar (a) deletar tag (`git push origin :refs/tags/X`) e refazer com base limpa; ou (b) deixar como história, deixando claro no `README` que a árvore atual é o corte público. | 7 dias |
| **F-19** | Crédito no `README.md`: "Criação da Planilha: Sergio Cintra". Não há registro público de cessão/licenciamento desse autor inicial à TPGL v1.1. | **MÉDIO** | Para o rigor de cadeia de direitos exigido pela Lei 9.610, é desejável documentar formalmente que a obra original foi cedida ou que o segundo autor tem autorização para licenciar. Não é bloqueante na prática, mas é fragilidade jurídica latente. | A história é antiga; falta o documento. | Documentar formalmente a cessão (anexo a `auditoria/`, ou nota em `docs/legal/`) ou, se houver coautoria contínua, ajustar o aviso de copyright e o CLA para refletir os dois titulares. | Refino, mas idealmente fechado antes de adoção institucional |
| **F-20** | `auditoria/17_PARECER_LICENCIAMENTO_TPGL_v1_1.md` começa com "**Objeto:** Licença TPGL v1.0, proposta como…". O nome do arquivo é v1.1. O parecer **é** sobre a v1.1 — mas o cabeçalho ainda lê o objeto inicial (a v1.0 que foi analisada). | **BAIXO** | Pequeno descompasso entre título e introdução. Leitor apressado pode pensar que o parecer está desatualizado. | Texto refletia o histórico da análise. | Ajustar a primeira linha para "**Objeto:** Análise crítica da TPGL v1.0 e proposição da TPGL v1.1, licença customizada inspirada na Business Source License 1.1 (BSL)…". | 1 dia |

### Síntese de gravidade

- **BLOQUEANTES (devem fechar antes de chamar de "linha pública oficial"):** F-01, F-02. F-03 e F-04 estão no limite — eu os classifiquei como ALTO porque são fecháveis em poucas horas e cada um deles isoladamente seria justificável como bloqueante por um auditor mais rigoroso.
- **ALTOS (devem fechar dentro do mesmo ciclo de publicação):** F-03, F-04, F-05.
- **MÉDIOS:** F-06, F-07, F-08, F-09, F-11, F-12, F-13, F-14, F-19.
- **BAIXOS / refino:** F-10, F-15, F-16, F-17, F-18, F-20.

---

## 04. Auditoria da Licença e Governança

### 4.1 TPGL v1.1

A licença está sólida na sua forma corrente. O parecer 17 e o documento institucional já cobrem a justificação técnico-jurídica em profundidade. Adicionalmente:

A licença declara explicitamente, na cláusula 14.5, que **não** é open source pela definição da OSI. Isso é exatamente o esperado e fecha qualquer ambiguidade comunicacional. A cláusula 10 (Data de Conversão) institui o prazo de 4 anos para Apache 2.0, posicionando o projeto como source-available com promessa formal de abertura, não como source-available indefinido. Para um leitor jurídico, isso é a diferença entre BSL madura e shared-source ad nutum.

A cláusula 9 (LGPD) protege o licenciante de responsabilização por tratamento de dados que ele **não** controla. Está corretamente formulada. A cláusula 11 (Rescisão e Cura) tem prazo de 30 dias e cláusula de auto-cura espontânea (11.5), o que é favorável tanto ao licenciante (em conformidade com art. 422 do Código Civil) quanto ao licenciado (não há rescisão automática sem oportunidade de saneamento).

**Lacuna principal:** o texto do `LICENSE` no repositório está em PT-BR sem acentuação (achado F-05). O parecer e o documento institucional já têm versão acentuada. Para o instrumento que efetivamente vincula o licenciado, a versão acentuada é a versão correta.

### 4.2 CLA

O CLA está correto na forma e cobre as exigências centrais (autoria, originalidade, cessão patrimonial nos termos do art. 49 da Lei 9.610, preservação dos direitos morais, licença de patente com cessação ofensiva, formas rastreáveis de aceite). A cláusula 7 menciona instrumento complementar para contribuições institucionais, mas não publica esse template — gap operacional (F-12).

**Para o público auditor jurídico:** o CLA é defensável e segue a linha do CLA do Apache, com adaptações para a realidade brasileira. Não há cláusula de cessão moral (correto, isso seria nulo), e a cessão patrimonial está corretamente limitada ao "máximo permitido pela Lei 9.610/98 art. 49".

### 4.3 README público

O `README.md` posiciona o repositório de forma exemplar para um projeto source-available brasileiro. Em particular: declara explicitamente (no parágrafo "Posicionamento público") que o modelo é source-available, que a licença é TPGL v1.1, que a conversão para Apache 2.0 ocorre em 4 anos por release, que contribuições exigem CLA. Declara explicitamente o que **não** é (open source pela OSI) e o que o repositório **não** publica como narrativa principal (workflows internos, sincronização local, automações privadas).

Este é o único achado positivo de comunicação clara em projetos public-interest brasileiros que examinei. Mantém-se.

### 4.4 Documentação institucional

`docs/ARQUITETURA.md`, `docs/COMPLIANCE_CMMI_ISO.md`, `docs/licenca/README.md`, `docs/INDEX.md` cobrem o pacote esperado de uma trilha institucional. O `COMPLIANCE_CMMI_ISO` é especialmente honesto ao mapear cada referência (CMMI CM, VER, VAL, MA, PPQA, DAR; ISO 9001 8.3, 9.1; ISO 27001 A.5, A.8, A.12) ao status real ("adotada" / "parcial"), sem inflar.

**Sugestão de melhoria:** o `docs/` poderia receber um `docs/GLOSSARIO.md` curto, definindo termos como "Bateria Oficial", "V2", "smoke", "stress", "assistido", "shadow mode", "rodízio", "Pre-OS", "OS", "atividade", "credenciamento". Isso ajudaria leitores de fora do domínio (especialmente jurídicos e gestores).

### 4.5 Riscos reputacionais e jurídicos

**Reputacional:**
- (R-01) **F-03** — a senha anterior podia ser lida como afirmação de vínculo institucional indevido. Em uma comunicação pública, isso pode gerar atrito.
- (R-02) **F-19** — coautoria de Sergio Cintra sem documento de cessão pode dar margem a contestação se a obra original tiver valor reconhecido. Hoje é fragilidade latente, não problema concreto.
- (R-03) **F-01** — defasagem entre `main` público e branch arrumada gera percepção de "narrativa-realidade desalinhada" se observada por terceiros antes da promoção.

**Jurídico:**
- (R-04) **F-05** — `LICENSE` em PT-BR sem acentos. Não invalida (o texto continua compreensível, a vontade do licenciante está clara), mas em uma disputa com terceiro pode ser explorado retoricamente como "rascunho".
- (R-05) **F-12** — ausência de template de CLA institucional pode dificultar adoção formal por órgão público que exige instrumento assinado.
- (R-06) ausência de adoção formal por algum município ou órgão público até hoje (não documentada). Não é risco em si, mas a primeira adoção formal pública será o teste real do instrumento. Recomenda-se que esse primeiro caso passe por homologação jurídica humana, conforme já advertido no parecer 17.

**Conclusão da seção 04:** licença e governança estão acima da média, mas **F-05 (acentuação do LICENSE)**, **F-12 (template CLA institucional)** e **F-19 (cessão original)** devem ser fechados antes de qualquer adoção institucional pública.

---

## 05. Auditoria dos Testes

### 5.1 Cobertura

Em volume, a cobertura é forte: 6.361 linhas de teste contra 3.921 linhas de produção nos módulos centrais. A Bateria Oficial tem cinco blocos sequenciais (Preparação, Cenário Literal, Expansão, Regressão Técnica, Combinatória, Exportação). A V2 tem engine, roteiros (smoke, stress, assistido), catálogo semântico, baseline canônica, snapshot.

Em cobertura **declarada**, as seguintes regras estão tratadas: rodízio (fila por atividade, filtro por credenciamento ativo, suspensão global, reativação automática, inatividade global, OS aberta na mesma atividade, Pre-OS pendente, avanço com ou sem punição), Pre-OS (emissão condicionada, aceite, recusa, expiração, transições inválidas), OS (emissão condicionada, validação de previsão de término, persistência), avaliação (10 notas, média, divergência, justificativa, suspensão automática), auditoria (eventos críticos em `AUDIT_LOG`).

Em cobertura **rastreável**, falta a matriz regra→teste (achado F-13).

### 5.2 Confiabilidade

A V2 oferece baseline determinística (resolvida em V12.0.0190), assertion pós-reset (resolvida em V12.0.0190), snapshot pré-reset (resolvido). Há quatro estados de log (`OK`, `FALHA`, `INFO`, `MANUAL_ASSISTIDO`) que permitem distinguir falha real de evento informacional ou de necessidade de validação humana.

A Bateria Oficial registra resultado em `RESULTADO_QA` com formatação. `Central_Testes_Relatorio` produz relatórios A4 imprimíveis (`RPT_ROTEIRO`, `RPT_BATERIA`, `RPT_CK136`, `RPT_CONSOLIDADO`).

Confiabilidade declarativa: alta. Confiabilidade verificável publicamente: limitada — porque o resultado das execuções não é publicado (achado F-04).

### 5.3 Arquitetura da esteira

A esteira atual é, em camadas:

- **Bateria Oficial (`Teste_Bateria_Oficial.bas`):** suíte central, 2.414 linhas, cinco blocos.
- **V2 Engine (`Teste_V2_Engine.bas`):** infraestrutura de testes, 1.628 linhas, com helpers de fixtures, snapshot, log estruturado, baseline canônica.
- **V2 Roteiros (`Teste_V2_Roteiros.bas`):** suítes executáveis (`TV2_RunSmoke`, `TV2_RunStress`).
- **UI Guiado (`Teste_UI_Guiado.bas`):** roteiro humano de testes visuais.
- **Central de Testes (`Central_Testes.bas`, `Central_Testes_V2.bas`):** orquestração.
- **Central de Relatórios (`Central_Testes_Relatorio.bas`):** geração de relatórios imprimíveis.

A esteira **alvo** descrita em `auditoria/16_AUDITORIA_OPUS` propõe seis camadas (L1 contratos+invariantes, L2 unit, L3 integração, L4 cenários, L5 stress+shadow, L6 assistido). Hoje, a implementação cobre L4, L5 e L6. L1, L2 e L3 são **implícitos** dentro da Bateria Oficial e da V2 — não estão isolados. Para um auditor exigente, isso é "cobertura correta, granularidade ainda não madura".

### 5.4 Rastreabilidade

A rastreabilidade em **auditoria** (eventos do sistema → `AUDIT_LOG`) é boa: enum `eTipoEvento` com 15 tipos cobertos, enum `eEntidadeAfetada` com 7 tipos. Os repositórios chamam o audit log nos pontos críticos.

A rastreabilidade em **testes** (regra de negócio → caso de teste) **não existe formalmente** (achado F-13). A informação está na cabeça do mantenedor, mas não no repositório.

A rastreabilidade em **versão** (commit → tag → release) está parcialmente quebrada: a release V12.0.0202 não tem tag git correspondente (F-02).

### 5.5 Qualidade da evidência

Hoje, a evidência das execuções de teste vive em abas internas do `.xlsm` operacional (`RESULTADO_QA`, `HISTORICO_QA`, `RESULTADO_QA_V2`, `HISTORICO_QA_V2`, `CATALOGO_CENARIOS_V2`, `ROTEIRO_ASSISTIDO_V2`). Esse `.xlsm` **não é publicado** (correto pela política de corte público).

Consequência: **a evidência objetiva da bateria oficial e da V2 não chega ao GitHub**. O status `VALIDADO` é declarativo, não verificável (achado F-04).

A função `TV2_ExportarUltimaExecucaoCSVs` existe e poderia gerar exportações para publicação. Não é usada com essa finalidade hoje.

### 5.6 Lacunas críticas

Em ordem de prioridade:

1. **D1 — Comparador automatizado V1×V2** (auditoria/14, ABERTO): sem comparador, não é possível detectar divergência entre as duas suítes em uma rodada.
2. **D2 — Shadow mode contínuo** (auditoria/14, ABERTO): rodar V2 em sombra da V1 em produção é o caminho para detectar regressões de comportamento real, não só de teste.
3. **E1 — Edge cases e stress complementar** (auditoria/14, ABERTO).
4. **C2 — `Svc_Transacao` amplo** (auditoria/14, PARCIAL): rollback amplo em PreOS/OS/Avaliação ainda incompleto. Risco prático: estado parcial em fluxos críticos.
5. **H1 — Isolamento de módulos destrutivos** (auditoria/14, PARCIAL): superfície administrativa ampla; faxina final pendente.
6. **H4 — Hash/versão no cabeçalho dos CSVs** (auditoria/14, ABERTO): fundamental para evidência verificável.
7. **F-13 — Matriz regra→teste**: faltando.
8. **F-14 — Catálogo formal de invariantes**: faltando.

### 5.7 Maturidade da trilha para auditoria, certificação e liberação pública

Na **forma atual**, a trilha:

- **suporta** auditoria interna do mantenedor;
- **suporta parcialmente** auditoria externa (faltam evidências publicadas e matriz de rastreabilidade);
- **não suporta** certificação formal CMMI 3 / ISO 9001 / ISO 27001 sem complementos.

Com os achados F-04, F-13, F-14 e os itens D1, D2 do backlog Opus fechados, a trilha sustenta auditoria externa positiva sem ressalvas materiais. Para certificação formal, há trabalho adicional (não escopo desta auditoria).

---

## 06. Critério de Maturidade

Avaliação por padrão. Sem inflação. Cada item é classificado como **APROXIMA**, **PARCIAL**, **DISTANTE** em relação à prática esperada.

### 6.1 CMMI Nível 3 (referenciais selecionados)

| Área de processo | Estado | Evidência | Comentário |
|---|---|---|---|
| **CM — Configuration Management** | PARCIAL | `STATUS-OFICIAL.md`, `App_Release.bas` | Falta tag git para a release atual (F-02) e CHANGELOG completo (F-06). Sem isso, baseline existe na narrativa mas não no SCM. |
| **VER — Verification** | PARCIAL | Bateria Oficial, V2, `auditoria/04` | Cobertura presente. Falta matriz regra→teste (F-13) e evidências publicadas (F-04). |
| **VAL — Validation** | APROXIMA | `V12.0.0202.md`, validação humana documentada | Validação por operador humano registrada. Para nível 3, falta protocolo formal escrito de aceitação. |
| **MA — Measurement and Analysis** | DISTANTE | Sem métricas publicadas | `COMPLIANCE_CMMI_ISO.md` marca como "parcial". Não há séries históricas de métricas (cobertura, defeitos, tempo médio entre regressões). |
| **PPQA — Process and Product Quality Assurance** | PARCIAL | Pasta `auditoria/` | Auditorias periódicas existem como artefatos. Falta cadência declarada e auditor independente. |
| **DAR — Decision Analysis and Resolution** | PARCIAL | Pareceres (auditoria/16, 17) | Decisões maiores (licença, corte público) têm parecer escrito. Decisões menores não. |
| **RD/RM — Requirements Development/Management** | DISTANTE | Implícito em `auditoria/03` | Regras de negócio listadas, não há rastreabilidade formal de mudança de requisito. |

**Veredito CMMI 3:** o projeto **se aproxima** das práticas de nível 2 plenamente e de partes do nível 3 (CM, VER, VAL, PPQA, DAR). Para nível 3 completo, faltam MA (medição) e RD/RM (requisitos rastreáveis). É realista falar em "aderência incremental a nível 3", como o `COMPLIANCE_CMMI_ISO.md` já faz, mas **não em certificação**.

### 6.2 ISO 9001 (controles selecionados)

| Cláusula | Estado | Evidência | Comentário |
|---|---|---|---|
| **8.3 Design and development controls** | APROXIMA | Releases, CHANGELOG (parcial), matriz de testes | Estrutura presente. CHANGELOG incompleto (F-06) é o principal gap. |
| **9.1 Performance evaluation** | PARCIAL | Bateria oficial declarada, sem evidência publicada | Falta evidência publicada (F-04). |
| **9.2 Internal audit** | APROXIMA | Pasta `auditoria/` | Auditorias internas existem e são publicadas. Falta cadência fixa. |
| **9.3 Management review** | DISTANTE | Sem registro público | Não há ata pública de revisão por liderança. |
| **10.2 Nonconformity and corrective action** | PARCIAL | Auditoria/14 (Backlog Opus) | Há rastreio de não-conformidades (itens A1–H5). Falta política formal de tratamento. |

**Veredito ISO 9001:** alguns controles bem cobertos, outros ausentes. Pré-certificação possível com investimento dirigido em 9.3 e 10.2.

### 6.3 ISO/IEC 27001 (controles selecionados)

| Controle | Estado | Evidência | Comentário |
|---|---|---|---|
| **A.5 Políticas de segurança da informação** | APROXIMA | `LICENSE`, `SECURITY.md`, `CONTRIBUTING.md` | Pacote completo. |
| **A.6 Organização da segurança** | DISTANTE | — | Sem papéis de segurança explícitos no repositório. |
| **A.8 Gestão de ativos** | PARCIAL | `.gitignore`, separação local↔público | Boa separação. Falta inventário formal. |
| **A.9 Controle de acesso** | PARCIAL | CODEOWNERS, política de PR | Estrutura mínima presente. |
| **A.12 Operações** | PARCIAL | `Audit_Log`, `ErrorBoundary`, proteção de abas | Em código. Falta política operacional escrita. |
| **A.14 Aquisição/desenvolvimento/manutenção** | PARCIAL | `CONTRIBUTING.md`, `CHANGELOG.md` | Falta política formal de hardening. |
| **A.16 Gestão de incidentes** | APROXIMA | `SECURITY.md` com SLA | Bom. |
| **A.18 Conformidade** | PARCIAL | `COMPLIANCE_CMMI_ISO.md` | Mapeamento existe; falta verificação independente. |

**Veredito ISO 27001:** o pacote público tem boas fundações em A.5, A.16. Para certificação, falta amadurecer A.6, A.8 (inventário), A.9 (política formal), A.12, A.14 (hardening explícito), A.18 (auditoria externa). Está **distante**, mas com base utilizável.

### 6.4 Síntese geral

O repositório está hoje em uma posição **incomum em projetos brasileiros de interesse público**: tem o **pacote institucional típico de um projeto sério** (LICENSE com parecer, SECURITY com SLA, CLA, CODE_OF_CONDUCT, CONTRIBUTING, CHANGELOG), tem uma **trilha de auditoria contínua publicada** (pasta `auditoria/`), tem uma **estrutura de código em camadas claras** e tem uma **estrutura de testes proporcional**.

Mas ele ainda **não tem** o que distingue um projeto que se candidata a referência institucional: evidências publicadas de execução de teste, matriz de rastreabilidade regra→teste, métricas históricas, política operacional escrita, auditor externo independente. O `COMPLIANCE_CMMI_ISO.md` é honesto sobre isso.

Com **F-01, F-02, F-03, F-04** fechados (as quatro pendências do veredito), o repositório está pronto para servir como **referência prática** (alguém pode adotar o modelo, copiar o pacote institucional, adaptar a licença). Para servir como **referência certificada**, falta o trabalho adicional descrito acima.

---

## 07. Plano de Melhoria

Backlog em sprints curtas, organizadas por dependência. Cada sprint tem objetivo, escopo, dependência, risco, critério de aceite e indicação se bloqueia publicação ou não.

### Sprint 0 — Saneamento de publicação (BLOQUEANTE; 1–2 dias)

**Objetivo:** transformar `codex/v180-stable-reset` na linha pública oficial em `main`, com tag e checkpoint reproduzível.

**Escopo:**
- Arquivar `main` atual em tag de segurança (ex.: `archive/main-pre-corte-2026-04-20`).
- Promover `codex/v180-stable-reset` para `main` (estratégia: merge no-fast-forward com resumo do corte, OU reset controlado com `--force-with-lease`).
- Criar tag `v12.0.0202` no commit final.
- Push de tags.
- Validar que `App_Release.bas` aponta para link funcionando.
- Resolver F-20 (ajustar primeira linha de `auditoria/17`).

**Dependência:** nenhuma.

**Risco:** alto se feito sem backup da `main` antiga. Mitigação: tag de arquivo antes da operação, e operação sob revisão humana.

**Critério de aceite:**
- `git ls-tree origin/main` mostra a árvore arrumada.
- `git tag -l | grep v12.0.0202` retorna a tag.
- `App_Release.bas` link clicável vai para a pasta de releases existente.
- `feature/v12-r2-mei-elimination-and-test-unification` deletada local e remoto (F-16).

**Bloqueia publicação?** Sim. Esta sprint é o desbloqueio.

### Sprint 1 — Higiene mínima de segurança e licença (ALTO; 2–3 dias)

**Objetivo:** fechar os achados ALTOS que comprometem leitura institucional.

**Escopo:**
- F-03: trocar valor de `Util_SenhaProtecaoPadrao()` por token neutro. Atualizar `SECURITY.md` para descrever o token como "operacional, não criptográfico, podendo ser publicado". Compilar e revalidar bateria.
- F-05: reescrever `LICENSE` em PT-BR com acentuação plena, mantendo conteúdo idêntico ao do `TPGL_v1_1_DOCUMENTO_INSTITUCIONAL.docx`. Verificar com `diff` semântico contra o doc institucional.
- F-04: rodar Bateria Oficial e V2 (smoke + stress + assistido) na árvore arrumada. Exportar resultados via `TV2_ExportarUltimaExecucaoCSVs`. Salvar em `auditoria/evidencias/V12.0.0202/` com `MANIFEST.md` listando arquivos e SHA-256.

**Dependência:** Sprint 0 concluída (para que a árvore arrumada seja a árvore validada).

**Risco:** F-03 muda comportamento de senha — toda planilha em produção que confiava no valor antigo precisa rodar `Util_DesprotegerAbaComTentativas` na transição. Mitigação: incluir fallback no array `Util_SenhasTentativaProtecao` durante o ciclo de transição, ou planejar migração coordenada.

**Critério de aceite:**
- `grep` pelo valor institucional anterior em `src/vba/` retorna 0; `grep -E "ChrW.*[0-9]+" src/vba/Util_Planilha.bas` mostra apenas o novo token.
- `LICENSE` tem acentos plenos; `grep -c "licenca\|publica" LICENSE` retorna número significativamente menor (palavras com acento agora são "licença", "pública").
- `auditoria/evidencias/V12.0.0202/MANIFEST.md` existe com SHA-256 dos CSVs publicados.

**Bloqueia publicação?** Sim, em conjunto. Não chamar de "linha oficial pública madura" antes de fechar.

### Sprint 2 — Coerência narrativa e governança (MÉDIO; 3–5 dias)

**Objetivo:** fechar os achados de coerência narrativa.

**Escopo:**
- F-06: reescrever `CHANGELOG.md` com entradas de V12.0.0180 em diante, sintetizando a evolução. Cada entrada com link para o respectivo arquivo de release em `obsidian-vault/releases/` ou `obsidian-vault/releases/historico/`.
- F-08: decidir entre remover `obsidian-vault/00-DASHBOARD.md` da publicação ou reescrever em markdown padrão sem detalhes operacionais. Atualizar `docs/INDEX.md` em conformidade.
- F-09: renomear `doc/` para `data/` (ou `reference/`). Atualizar todas as referências.
- F-10: renumerar pasta `auditoria/` para sequência contínua (sugestão: 00, 01, 02, …) **ou** documentar formalmente a equivalência no INDEX.
- F-11: validar link em `App_Release.bas` (já feito implicitamente pela Sprint 0). Considerar trocar para apontar para tag.
- F-12: criar `docs/legal/CLA_INSTITUCIONAL_TEMPLATE.md`.
- F-19: documentar formalmente cessão/licenciamento da obra original de Sergio Cintra (em anexo a auditoria/ ou em `docs/legal/`).

**Dependência:** Sprint 0 e Sprint 1.

**Risco:** F-09 (renomear `doc/` → `data/`) quebra qualquer link interno externo. Mitigação: manter redirecionamento `doc/README.md` apontando para `data/` por um ciclo.

**Critério de aceite:**
- `CHANGELOG.md` tem entradas para V12.0.0180, V12.0.0190, V12.0.0191, V12.0.0202.
- `docs/INDEX.md` não cita mais o dashboard Obsidian (ou cita em forma reescrita).
- `data/` (ou `reference/`) é o novo nome da pasta legada.
- `auditoria/INDEX.md` está coerente com a numeração escolhida.
- `docs/legal/CLA_INSTITUCIONAL_TEMPLATE.md` existe.
- `docs/legal/CESSAO_OBRA_ORIGINAL.md` (ou equivalente) existe.

**Bloqueia publicação?** Não. É melhoria que define se o repositório atende a leitura externa de gestor / auditor / jurídico.

### Sprint 3 — Maturidade de testes e rastreabilidade (MÉDIO; 5–7 dias)

**Objetivo:** fechar os principais achados de testes e rastreabilidade.

**Escopo:**
- F-07: mover `Teste_*.bas` e `Central_Testes*.bas` para `tests/vba/`. Atualizar documentação. Atualizar `verify-docs.yml` para conhecer a nova estrutura.
- F-13: criar `auditoria/19_MATRIZ_RASTREABILIDADE_REGRA_TESTE.md` com tabela explícita: regra de negócio → função de teste → arquivo → camada. Mínimo: 30 entradas cobrindo as regras centrais listadas em `auditoria/03`.
- F-14: criar `auditoria/20_INVARIANTES_DO_DOMINIO.md` com pelo menos INV-01 a INV-07 documentadas.
- D1 (Opus): implementar comparador automatizado V1×V2.
- D2 (Opus): institucionalizar shadow mode (modo de operação que executa V2 em paralelo da V1 em ambiente controlado, comparando resultados).
- H4 (Opus): adicionar hash/versão ao cabeçalho dos CSVs exportados pela bateria.

**Dependência:** Sprint 1 (para ter evidência de baseline para a matriz).

**Risco:** Sprint mais longa. F-07 pode quebrar imports VBA se não houver atenção. D1 e D2 são trabalho real de engenharia.

**Critério de aceite:**
- `tests/vba/` existe e contém os arquivos de teste; `src/vba/` não tem mais arquivos `Teste_*.bas`.
- `auditoria/19` cobre ≥ 30 regras com mapeamento explícito.
- `auditoria/20` lista INV-01 a INV-07.
- Comparador V1×V2 executável e documentado.
- Shadow mode disponível como modo opcional documentado.
- CSVs exportados contêm hash do commit, versão e data no cabeçalho.

**Bloqueia publicação?** Não. Mas eleva substancialmente a maturidade verificável.

### Sprint 4 — Endurecimento de CI e refinos (BAIXO; 5–7 dias)

**Objetivo:** elevar o teto do CI e fechar refinos.

**Escopo:**
- F-15: estender `verify-docs.yml` com checks de coerência de versão, presença no CHANGELOG, lint regex VBA (proibir senhas literais, paths hardcoded).
- F-17: avaliar canal de contato em `Central_Testes_Relatorio`. Se mantém pessoal, documentar consentimento; se troca para institucional, ajustar.
- F-18: auditar conteúdo de tags antigas. Decidir se mantém como história ou se republica em base limpa.
- C2 (Opus, parcial): expandir `Svc_Transacao` para fluxos completos de PreOS/OS/Avaliação.
- H1 (Opus, parcial): isolamento final de módulos destrutivos.
- H2 (Opus, ABERTO): centralização de caminhos hardcoded.
- Adicionar `docs/GLOSSARIO.md` com termos do domínio.
- Adicionar `docs/COMO_LER_ESTE_REPOSITORIO_EM_10_MINUTOS.md` como porta de entrada para auditor externo apressado.
- Considerar diagrama de arquitetura visual (PNG ou SVG) em `docs/arquitetura/`.

**Dependência:** Sprints 0–3.

**Risco:** baixo individualmente, mas é a sprint mais longa porque tem muitos itens pequenos.

**Critério de aceite:**
- CI roda checks adicionais e falha em PRs que violem.
- Glossário e guia de leitura existem.
- C2, H1, H2 marcados como RESOLVIDOS no `auditoria/14`.

**Bloqueia publicação?** Não. É refino para próxima auditoria.

### Sprint 5 — Reauditoria externa (após Sprints 0–3; 1–2 semanas calendário)

**Objetivo:** receber auditor externo independente sobre a árvore consolidada.

**Escopo:** disponibilizar todos os artefatos das Sprints 0–4. Acompanhar achados externos. Iterar.

**Dependência:** Sprints 0, 1, e idealmente 2 e 3.

**Bloqueia publicação?** Não, mas é o critério para chamar a publicação de "auditada por terceiro independente" (e não apenas "auto-auditada").

---

## 08. Checklist de Auditoria Final

Lista objetiva para a próxima auditoria final positiva. Cada item deve ser respondido com Sim/Não/Parcial e evidência.

### Estrutura pública

- [ ] `main` aponta para a árvore arrumada (não para a árvore antiga).
- [ ] Tag git `v12.0.0202` existe no commit publicado.
- [ ] Não há branches mortas (`feature/v12-r2-mei-elimination-and-test-unification` removida).
- [ ] `git ls-files | wc -l` retorna número estável e auditável (≤ 100 arquivos).

### Pacote institucional

- [ ] `README.md` declara explicitamente o modelo source-available e o link para `LICENSE`, `CLA`, `SECURITY`.
- [ ] `LICENSE` em PT-BR com acentuação gráfica plena.
- [ ] `CLA.md` presente, acentuado, com cláusula de cessão patrimonial e preservação de direitos morais.
- [ ] `docs/legal/CLA_INSTITUCIONAL_TEMPLATE.md` existe.
- [ ] `SECURITY.md` presente, com SLA explícito.
- [ ] `CONTRIBUTING.md` exige CLA.
- [ ] `CODE_OF_CONDUCT.md` presente.
- [ ] `CHANGELOG.md` com pelo menos 3 entradas (`V12.0.0180`, `V12.0.0190`, `V12.0.0202`).

### Documentação técnica

- [ ] `docs/INDEX.md` cita apenas arquivos existentes.
- [ ] `docs/ARQUITETURA.md` descreve as camadas e está coerente com `src/vba/`.
- [ ] `docs/COMPLIANCE_CMMI_ISO.md` mapeia adesão sem inflar.
- [ ] `docs/licenca/README.md` descreve a TPGL v1.1 e cita o documento institucional Word.
- [ ] `docs/GLOSSARIO.md` existe e cobre termos do domínio.

### Auditoria pública

- [ ] `auditoria/INDEX.md` numerado e coerente.
- [ ] `auditoria/19_MATRIZ_RASTREABILIDADE_REGRA_TESTE.md` cobre ≥ 30 regras.
- [ ] `auditoria/20_INVARIANTES_DO_DOMINIO.md` lista INV-01 a INV-07.
- [ ] `auditoria/evidencias/V12.0.0202/` contém CSVs da bateria oficial e da V2 com hashes.

### Segurança

- [ ] `Util_SenhaProtecaoPadrao()` retorna token neutro (não nome de instituição).
- [ ] `SECURITY.md` reflete a decisão real sobre a senha.
- [ ] Nenhum email pessoal exposto sem consentimento explícito.
- [ ] `.gitignore` contínua excluindo `.xlsm`, `local-ai/`, `BKP_forms/`, `backups/`.
- [ ] Tags antigas auditadas: confirmado que não vazam material hoje considerado privado.

### Testes

- [ ] Testes vivem em `tests/vba/`, separados de `src/vba/`.
- [ ] CSVs publicados contêm hash de commit e versão no cabeçalho.
- [ ] Comparador V1×V2 executável.
- [ ] Shadow mode documentado e disponível.
- [ ] `Svc_Transacao` cobre PreOS/OS/Avaliação amplamente.

### CI / Governança

- [ ] `verify-docs.yml` valida coerência de versão, CHANGELOG, lint regex.
- [ ] `App_Release.bas` link aponta para diretório válido em `main`.
- [ ] `STATUS-OFICIAL.md` linka para tags git correspondentes.
- [ ] Auditor externo independente realizou rodada na árvore arrumada.

### Critério de fechamento

A próxima auditoria final positiva exige: **todos os itens BLOQUEANTES e ALTOS desta lista marcados Sim**, MÉDIOS marcados **Sim ou Parcial com plano**, BAIXOS marcados **Sim, Parcial ou Roadmap**.

---

## 09. Prompt para Implementação

O bloco abaixo é um prompt completo, autocontido, sem ambiguidades, para um agente técnico (humano ou IA) executar as Sprints 0 e 1 desta auditoria sem retrabalho. Ele se restringe ao que é **bloqueante e alto**. As demais sprints podem usar este modelo como referência.

```
Contexto: você vai executar as Sprints 0 e 1 da Auditoria 18 do
repositório Credenciamento (linha V12.0.0202).

Estado atual:
- Branch atual: codex/v180-stable-reset (head ~4d8929f).
- Branch padrão remota: main (ainda contém árvore antiga: HANDOFF.md,
  incoming/, scripts/, vba_export/, vba_import/, .cursorrules,
  ESTRATEGIA-V12-106.md).
- Última tag: v12.0.0166. Não há tag v12.0.0202.
- Senha de proteção embutida em src/vba/Util_Planilha.bas:
  Util_SenhaProtecaoPadrao() retorna ChrW$ codes que decodificam
  para um token institucional anterior.
- LICENSE em PT-BR sem acentos.
- Sem evidência publicada de bateria oficial / V2 da release atual.
- auditoria/17 começa com "Objeto: Licença TPGL v1.0..." (deve ser v1.1).

Objetivo: fechar os achados F-01, F-02, F-03, F-04, F-05 e F-20
descritos no documento auditoria/18_AUDITORIA_PUBLICACAO_OFICIAL_V12_0202.md.

Não faça nada que não esteja explicitamente listado abaixo. Se
encontrar dúvida, pare e pergunte ao mantenedor humano.

Tarefa 1 (F-01) — Promover árvore arrumada para main.
1.1 git fetch --all --tags
1.2 git checkout main
1.3 git tag archive/main-pre-corte-2026-04-20  # backup
1.4 git push origin archive/main-pre-corte-2026-04-20
1.5 git checkout codex/v180-stable-reset
1.6 git push --force-with-lease origin codex/v180-stable-reset:main
1.7 Validar: git ls-tree origin/main mostra a árvore arrumada.
    Listar e comparar com git ls-tree origin/codex/v180-stable-reset:
    devem ser idênticos.

Tarefa 2 (F-02) — Tag de release.
2.1 git tag -a v12.0.0202 -m "V12.0.0202 — linha pública oficial"
2.2 git push origin v12.0.0202
2.3 No GitHub: criar release com link para
    obsidian-vault/releases/V12.0.0202.md.

Tarefa 3 (F-03) — Senha de proteção.
3.1 Editar src/vba/Util_Planilha.bas:
    - Renomear o helper Util_SenhaProtecaoPadrao para um valor neutro,
      por exemplo "cred_v12_pub", mantendo a forma ChrW$ se quiser
      manter coerência com o padrão atual (mas isso é opcional).
    - Atualizar Util_SenhasTentativaProtecao para incluir o valor
      antigo durante o ciclo de transição, para que
      planilhas existentes continuem desprotegíveis.
3.2 Editar SECURITY.md:
    - Substituir o parágrafo "Senha de proteção das abas" por texto que
      reconheça a senha como token operacional não-secreto (publicável,
      mas mantido fora de literais para prevenção de mero copy-paste).
3.3 Recompilar VBA. Rodar bateria oficial e V2 (smoke + stress).
    Exportar evidência para a Tarefa 5.

Tarefa 4 (F-05) — LICENSE acentuado.
4.1 Abrir docs/licenca/TPGL_v1_1_DOCUMENTO_INSTITUCIONAL.docx
    (extrair texto plano).
4.2 Substituir o conteúdo de LICENSE pela versão acentuada,
    preservando estrutura, numeração de cláusulas e fim do
    instrumento ("FIM DA TPGL v1.1").
4.3 Validar: grep -c "licença\|pública\|definição\|conversão" LICENSE
    retorna número significativo (> 30); grep -c "licenca\|publica\|
    definicao\|conversao" LICENSE retorna 0 (ou só ocorrências em
    contexto inglês como "BSL").

Tarefa 5 (F-04) — Evidência publicada.
5.1 Criar diretório auditoria/evidencias/V12.0.0202/.
5.2 No Excel, rodar:
    - RunBateriaOficial
    - TV2_RunSmoke
    - TV2_RunStress (12 iterações)
    - TV2_ExportarUltimaExecucaoCSVs
5.3 Copiar os CSVs gerados para auditoria/evidencias/V12.0.0202/.
5.4 Criar auditoria/evidencias/V12.0.0202/MANIFEST.md listando cada
    CSV, com:
    - nome
    - data e hora da execução
    - versão (V12.0.0202)
    - hash de commit (git rev-parse HEAD)
    - SHA-256 do arquivo (sha256sum nome.csv)
5.5 git add auditoria/evidencias/V12.0.0202/ MANIFEST.md
5.6 Commit message:
    "evidencias: publica bateria oficial e V2 da V12.0.0202 (F-04)"

Tarefa 6 (F-20) — Cabeçalho do parecer 17.
6.1 Editar auditoria/17_PARECER_LICENCIAMENTO_TPGL_v1_1.md, primeira
    linha após o título:
    De:
      **Objeto:** Licença TPGL v1.0, proposta como licença...
    Para:
      **Objeto:** Análise crítica da TPGL v1.0 e proposição da TPGL
      v1.1, licença customizada inspirada na Business Source License
      1.1 (BSL), aplicável ao Sistema de Credenciamento e Rodízio
      (V12.0.0202).

Tarefa 7 — Higiene de branch.
7.1 git push origin --delete feature/v12-r2-mei-elimination-and-test-unification
    (se existir no remoto)
7.2 git branch -D feature/v12-r2-mei-elimination-and-test-unification
    (local)

Tarefa 8 — Verificação final.
8.1 git ls-tree origin/main: árvore arrumada.
8.2 git tag -l v12.0.0202: presente.
8.3 grep pelo valor institucional anterior em `src/vba/`: zero ocorrências.
8.4 grep "licenca" LICENSE: zero ocorrências (ou só em contexto BSL/EN).
8.5 ls auditoria/evidencias/V12.0.0202/: ao menos 3 CSVs e MANIFEST.md.
8.6 head -5 auditoria/17_PARECER_LICENCIAMENTO_TPGL_v1_1.md: cabeçalho
    novo presente.

Critério de aceite: todos os itens da Tarefa 8 retornam Sim.

Reportar ao mantenedor humano:
- diff resumido das mudanças;
- log da bateria oficial e da V2;
- confirmação de que main agora aponta para árvore arrumada;
- link da nova release no GitHub.

Não fazer:
- não trocar a licença por MIT/Apache/GPL;
- não recolocar workflows privados de IA, lógica de importação/
  exportação privada, handoffs ou prompts internos no GitHub;
- não excluir auditoria/16, auditoria/17 ou docs/licenca/;
- não alterar a estrutura de camadas do código VBA;
- não remover o disclaimer de homologação humana do parecer 17.
```

---

## Encerramento

Esta auditoria foi conduzida com base no **estado real** do repositório em 2026-04-20, na branch `codex/v180-stable-reset` (head `4d8929f`), e contrastada com a árvore atualmente publicada em `origin/main` e com toda a documentação institucional descrita.

A linha técnica é boa, o pacote institucional é acima da média, a licença é defensável. As pendências reais são poucas, são pequenas e são resolvíveis em duas sprints curtas. Não há motivo, ao final dessas sprints, para que o repositório não sirva como referência prática para outros projetos GovTech brasileiros que precisem articular **transparência pública**, **sustentabilidade do mantenedor** e **abertura futura formalizada**.

Recomendo, ao final do ciclo, repetir esta auditoria como rotina semestral, mantendo a numeração contínua na pasta `auditoria/`.

---

*Documento produzido como parte da trilha pública de auditoria. Este documento é insumo técnico-organizacional. Decisões formais sobre publicação, adoção institucional e homologação jurídica permanecem da alçada do mantenedor humano e, quando aplicável, de procuradoria ou advogado(a) com prática em propriedade intelectual.*
