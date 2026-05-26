---
titulo: Três Propostas V207 — Visão Sistêmica e Transição SaaS
diataxis: explanation
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-26
---

# Três Propostas V207 — Visão Sistêmica e Transição SaaS

> [!IMPORTANT]
> Este documento formula três caminhos arquiteturais alternativos para a versão **V12.0.0207** do Sistema de Credenciamento. Todos os caminhos respeitam o **PRINCÍPIO ESTRATÉGICO NÃO NEGOCIÁVEL**: a planilha Excel (.xlsm) deve continuar operando como porta de entrada e saída de dados, garantindo a soberania tecnológica e a independência do município contra aprisionamento tecnológico (vendor lock-in) sob qualquer modelo SaaS futuro.

---

# Proposta A — Paradigma Monolítico Estabilizado (VBA Puro e Modular)

## Resumo executivo
Esta proposta mantém o motor da aplicação 100% contido dentro da planilha Excel (`.xlsm`) usando VBA clássico. O foco é a **reestruturação interna rigorosa**, encapsulando formulários UI, extraindo a camada de manipulação de células para Repositórios puros e implementando uma bateria robusta de testes E2E de gravação/cadastro diretamente em VBA.

## Visão estratégica
Consolida a ferramenta offline existente como o produto final definitivo para pequenos e médios municípios que não demandam infraestrutura em nuvem, eliminando dependências externas (servidores, APIs) e mantendo o custo de manutenção operacional do município próximo a zero.

## Impacto na arquitetura (camadas)
*   **Interface (UI)**: Acoplamento reduzido. Todos os UserForms (`Menu_Principal.frm`, `Rel_OSEmpresa.frm`) são limpos de rotinas mutadoras diretas. Eles apenas capturam o input do usuário e invocam funções de `Svc_*`.
*   **Regras de Negócio (`Svc_*`)**: Envelopamento de todas as regras funcionais. Inclusão dos módulos `Svc_Logger` (gerenciamento unificado de logs) e `Svc_ValidacaoEntrada` (sanitização de inputs centralizada antes da persistência).
*   **Persistência (`Repo_*`)**: Transição completa para gravação em bloco (S2 - escrita via arrays) em vez de escrita célula-a-célula, otimizando a performance em computadores antigos sem necessidade de desligar eventos de forma insegura.

## Impacto no instalador/distribuição
Preserva o `Importador_V3.bas` atual e o ecossistema `local-ai/vba_import/`. É criado um novo módulo `Util_Instalador_Defesas` que valida a presença de referências (como a biblioteca *ActiveX Data Objects* ou *VBA Extensibility*) e executa um subconjunto rápido de testes unitários (smoke tests) após a importação, impedindo que o operador salve uma planilha cujo compile VBE tenha crashado de forma invisível.

## Impacto na documentação Diataxis
Foco no enriquecimento das pastas `docs/tutorials/` e `docs/how-to/` para o operador municipal. O manual do programador (Diataxis Reference) é atualizado com o mapeamento completo dos novos métodos das classes de Repositório.

## Impacto na migração SaaS futura
*   *Dificuldade*: Média-Alta. Como toda a lógica ainda roda em VBA acoplado ao modelo de objetos do Excel, a transição para SaaS exigirá uma reescrita completa do motor de negócios em outra linguagem (ex.: TypeScript/Node.js).
*   *Facilitador*: A separação rigorosa entre UI e Regras nos módulos `Svc_*` servirá como um "mapa rodoviário" limpo para os desenvolvedores que forem reescrever o sistema na nuvem.

## Impacto na garantia de independência tecnológica do município
*   **Soberania**: Máxima. O município tem a propriedade e o controle de 100% da aplicação em um único arquivo local. 
*   **Zero Lock-In**: A planilha é autossuficiente e funciona perfeitamente offline e de forma vitalícia sem depender de nenhum contrato de serviço de nuvem.

## Mapa de regras de negócio preservadas/movidas/reescritas
*   *Preservadas*: RN-01 a RN-17 lógicas (strikes, rodízio, bloqueios).
*   *Movidas*: A rotina de geração de IDs monotônicos é movida do `Util_Planilha` para o novo módulo `Svc_ValidacaoEntrada`.
*   *Reescritas*: Geração física e renderização dos relatórios em PDF (RN-17) reescrita com tratamento robusto contra interrupções de spooler de impressora.

## Cobertura de auditoria (mapas, evidências, trilhas)
O `Audit_Log` é estendido para gravar não apenas ações bem-sucedidas de estado, mas também tentativas de cadastro inválidas barradas pelo `Svc_ValidacaoEntrada` (com código de erro e payload original). Os logs passam a incluir o hash do CPF/CNPJ do operador ativo para auditoria de responsabilidade.

## Como rollback se der errado
Fácil e imediato. Como o código está todo contido em arquivos Git locais e pacotes textuais importáveis em `local-ai/vba_import/`, basta resetar a branch para a âncora anterior e reimportar o manifesto estável.

## Por que esta proposta vs as outras 2
Esta proposta é a de **menor risco técnico a curto prazo** e custo nulo de infraestrutura, sendo a escolha ideal caso o foco do município seja a manutenção puramente local offline, sem ambição de expansão web nos próximos 24 meses.

---

# Proposta B — Arquitetura de Transição In-Memory (VBA Desacoplado de Células)

## Resumo executivo
Esta proposta introduz uma **camada de abstração de dados (DAL)** na planilha. O VBA deixa de interagir diretamente com as células do Excel durante a execução das regras de negócio. Toda a base de dados (empresas, OS, strikes) é carregada para estruturas de dados em memória (Arrays e coleções de Dicionários tipados em runtime) ao abrir o form. As regras rodam em memória e as mudanças são gravadas nas abas em uma única operação transacional em bloco.

```text
┌──────────────┐      Ler tudo 1x      ┌───────────────────┐
│  Abas Excel  ├──────────────────────>│ Dados em Memória  │
│ (Persistência│                       │(Arrays/Dictionar.)│
│   e Células) │<──────────────────────┤                   │
└──────────────┘      Gravar 1x        └─────────┬─────────┘
                    (Transação em                │
                       bloco)                    ▼
                                       ┌───────────────────┐
                                       │   VBA Services    │
                                       │    (Stateless)    │
                                       └───────────────────┘
```

## Visão estratégica
Desacopla a inteligência do sistema do "Grid físico" do Excel, transformando a planilha em um mero "banco de dados tabular offline". Isso resolve definitivamente os problemas de performance (F-NEW4) e prepara a aplicação para uma migração instantânea para SaaS, uma vez que a lógica em memória é facilmente portável.

## Impacto na arquitetura (camadas)
*   **Interface (UI)**: Os UserForms são alimentados instantaneamente a partir das coleções em memória, eliminando a lentidão catastrófica de reload de ListBox (F-NEW4).
*   **Regras de Negócio (`Svc_*`)**: Funcionam de forma 100% limpa, operando sobre coleções de objetos de negócio estruturados, sem dependência de comandos `ws.Cells()` ou `Range()`.
*   **Persistência (`Repo_*`)**: Atua como um ORM (Object-Relational Mapper) primitivo em VBA. Carrega dados das abas no bootstrap e escreve de volta aplicando uma lógica de "dirty checking" (apenas grava linhas modificadas) com suporte a rollback transacional nativo em memória.

## Impacto no instalador/distribuição
Preserva a distribuição por manifesto. Exige a inclusão de um módulo de boot (`Mod_Bootstrap_Memory.bas`) para inicializar o cache de memória na abertura do workbook.

## Impacto na documentação Diataxis
A pasta `docs/explanation/` ganha um novo artigo técnico detalhando o ciclo de vida dos dados em memória e a estratégia de sincronização transacional para evitar conflitos de gravação.

## Impacto na migração SaaS futura
*   *Dificuldade*: Baixíssima. Como a lógica de negócios opera sobre estruturas de dados em memória (que emulam tabelas relacionais), a tradução para código TypeScript/Node.js ou Python que consome um banco de dados SQL (PostgreSQL/MySQL) é direta e quase mecânica.

## Impacto na garantia de independência tecnológica do município
*   **Soberania**: Preservada. A planilha continua funcionando localmente de forma autônoma. O modelo de dados em memória garante que o Excel física e visualmente continue sendo o banco de dados editável pelo usuário.
*   **Portabilidade**: Excepcional. O município pode extrair a base a qualquer momento bastando salvar uma cópia do arquivo `.xlsm`.

## Mapa de regras de negócio preservadas/movidas/reescritas
*   *Preservadas*: RN-01 a RN-17.
*   *Reescritas*: Toda a camada `Repo_*` é reescrita para manipular dicionários lógicos de dados em vez de referências físicas de ranges de células.

## Cobertura de auditoria (mapas, evidências, trilhas)
Os logs de auditoria passam a rastrear a latência das operações de carga e escrita (`LOAD_TIME_MS`, `COMMIT_TIME_MS`), gerando métricas claras de performance que provam a eficácia da abstração em in-memory.

## Como rollback se der errado
Se a escrita em bloco falhar ou sofrer interrupção por falta de energia, o banco de dados em memória aborta o commit e restaura a integridade das abas a partir do snapshot de abertura da transação. O histórico do Git permite reverter a engine de persistência sem tocar na lógica dos serviços.

## Por que esta proposta vs as outras 2
Esta proposta é o **equilíbrio perfeito entre soberania offline e preparação real para a nuvem**. Ela acelera o sistema em até 50x em computadores antigos, mantendo a planilha como interface principal enquanto remove o débito técnico clássico do acoplamento de células do VBA.

---

# Proposta C — Planilha como Cliente Fino Híbrido (COM Bridge / API-First)

## Resumo executivo
Esta proposta transforma a planilha `.xlsm` em uma **casca de interface rica offline-first (Thin Client)**. A inteligência operacional e a persistência real dos dados são externalizadas para um pequeno backend local instalado na máquina do município (ex.: um executável empacotado em Go, Python ou Rust rodando como serviço local e usando banco SQLite), com o qual a planilha se comunica via chamadas HTTP locais (WinHTTP) ou COM Bridge.

```text
┌──────────────────────────────────────┐
│  Planilha Excel local (.xlsm)        │
│  - Apenas UI / Visualização          │
│  - Exportação de Emergência          │
└──────────────────┬───────────────────┘
                   │
                   │ WinHTTP (API Local/Nuvem)
                   ▼
┌──────────────────────────────────────┐
│  Local Backend Service (SQLite / Go) │
│  - Lógica Real de Negócio e Fila     │
│  - Sincronização opcional com SaaS   │
└──────────────────────────────────────┘
```

## Visão estratégica
Posiciona o projeto na **fronteira final da modernização**. A planilha vira um painel de visualização e entrada de dados amigável, enquanto a engenharia real de software é executada fora do ecossistema do Excel. Isso permite a migração transparente e instantânea para um SaaS na nuvem, bastando mudar a URL de comunicação do backend local para o servidor web.

## Impacto na arquitetura (camadas)
*   **Interface (UI)**: Preservada no Excel. Os UserForms enviam payloads JSON para o backend local e renderizam a resposta.
*   **Regras de Negócio (`Svc_*`)**: Movidas integralmente para o backend externo (escritas em linguagem moderna como Go/TypeScript/Python), garantindo tipagem estática, testabilidade E2E real e isolamento total de processos.
*   **Persistência (`Repo_*`)**: Executada em banco de dados SQLite local na máquina do município (ou Postgres na nuvem se online). O Excel deixa de ter abas como tabelas vivas (elas passam a ser apenas espelhos atualizados por dumps de leitura rápidos).

## Impacto no instalador/distribuição
Introduz a necessidade de um **instalador modular do sistema** (`mod_Instalador` / executável de setup do Windows). Este instalador instala a planilha e configura o serviço do backend local silenciosamente, configurando o runtime e as portas de rede locais.

## Impacto na documentação Diataxis
Transição radical. O manual de instalação vira o documento Diataxis mais importante. A documentação técnica passa a cobrir os contratos das rotas da API local (OpenAPI/Swagger).

## Impacto na migração SaaS futura
*   *Dificuldade*: Zero. A aplicação *já é* uma aplicação de arquitetura web/SaaS rodando em localhost. A migração para nuvem consiste apenas em alterar a string de conexão na configuração da planilha para apontar para o servidor web de produção.

## Impacto na garantia de independência tecnológica do município
Para cumprir rigorosamente o **PRINCÍPIO DE NÃO APRISIONAMENTO TECNOLÓGICO**, a Proposta C adota a **Estratégia de Dutos Reversíveis (Reverse Duto)**:

> [!CAUTION]
> **Estratégia de Soberania (Duto Reverso)**: Se o município decidir cancelar a assinatura do SaaS ou desinstalar o backend local, o sistema ativa a função **"Ejetar Monolito"**. 
> O backend gera uma exportação final completa que reconstrói dinamicamente todas as abas históricas do Excel e injeta no código do workbook os módulos VBA puramente monolíticos correspondentes à Proposta A. 
> A planilha "desperta" como um monolito autônomo funcional, garantindo que o município continue a operação offline vitalícia de forma imediata e independente de qualquer software ou servidor externo.

## Mapa de regras de negócio preservadas/movidas/reescritas
*   *Preservadas*: O comportamento das regras RN-01 a RN-17.
*   *Reescritas*: Toda a lógica de regras e persistência é reescrita na linguagem moderna do backend externo. O VBA da planilha é reduzido a chamadas de rede e parser básico de JSON.

## Cobertura de auditoria (mapas, evidências, trilhas)
Máxima rastreabilidade. Logs de transações de banco de dados reais (ACID), backups diários automatizados do arquivo SQLite e trilhas de auditoria imutáveis integradas no backend.

## Como rollback se der errado
O backend local realiza snapshots automáticos antes de cada operação crítica de importação ou atualização de versão, permitindo restaurar o estado do banco de dados SQLite com um clique no painel administrativo da planilha.

## Por que esta proposta vs as outras 2
Esta é a **proposta definitiva para transição SaaS**. Ela resolve todos os problemas de performance, segurança e testabilidade herdados do VBA, enquanto honra com maestria o compromisso ético de não aprisionar os dados do município através da ejeção do monolito.

---

# Matriz de Decisão Comparativa (Visão Sistêmica)

| Critério | Proposta A (Monolito VBA) | Proposta B (In-Memory) | Proposta C (Híbrida/API) |
|---|---|---|---|
| **Custo de Desenvolvimento** | Baixo | Médio | Alto |
| **Risco de Regressão a Curto Prazo** | Muito Baixo | Médio | Alto |
| **Speedup de Performance** | ~2x a 5x | ~30x a 50x | Máximo (Instantâneo) |
| **Facilidade de Migração SaaS** | Baixa | Alta | Instantânea |
| **Garantia de Soberania Offline** | Nativa | Nativa | Via Ejeção de Monolito |
| **Custo de Infraestrutura** | Zero | Zero | Baixo (SQLite Local) / Variável (Cloud) |
| **Legado VBA Remanescente** | 100% | ~40% (apenas UI/Bootstrap) | ~10% (apenas UI Bridge) |
| **Complexidade de Distribuição** | Nula (Mapeamento V3) | Nula (Mapeamento V3) | Alta (Exige Setup do Windows) |
