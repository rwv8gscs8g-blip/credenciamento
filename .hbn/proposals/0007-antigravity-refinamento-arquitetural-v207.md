---
titulo: Refinamento Arquitetural V12.0.0207 — Antigravity (2ª rodada)
diataxis: explanation
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0207
data: 2026-05-26
---

# Refinamento Arquitetural V12.0.0207 — Antigravity (2ª rodada)

> [!IMPORTANT]
> Este documento representa o refinamento técnico sistêmico da segunda rodada de auditoria cruzada sobre a transição **V12.0.0206 → V12.0.0207**. Nenhuma modificação foi aplicada ao código-fonte; o escopo limita-se à modelagem das duas alternativas selecionadas pelo operador em conjunto com o relatório consolidado Opus `111_ANALISE_AUDITORIA_CRUZADA_V207.md`.

---

## 1. Alternativa I — Caminho 1 → Caminho 2 puro (sequencial)

A Alternativa I prevê uma progressão rigorosamente linear e conservadora: a **V207** estabiliza as regras e a gravação no monolito clássico (Caminho 1), e a **V208** introduz a persistência desacoplada in-memory baseada em dirty-checking (Caminho 2).

```text
┌──────────────────────────────────────┐     ┌──────────────────────────────────────┐
│       V207 (Caminho 1 Enxuto)        │  ─> │     V208 (Caminho 2 Completo)        │
│  - Modularização + Escrita Bloco     │     │  - ORM Primitivo VBA + In-Memory     │
│  - Cobertura E2E Bateria Cadastros   │     │  - Dirty-checking transacional       │
└──────────────────────────────────────┘     └──────────────────────────────────────┘
```

### 1.1 Impacto na metodologia HBN (Knowledges novas)
Esta abordagem sequencial gerará pelo menos duas novas diretrizes de governança em `.hbn/knowledge/`:
1.  **`knowledge/0019-disciplina-transicional-de-contratos.md`**: Regras de pareamento entre o módulo `Svc_*` e o `Repo_*` correspondente. Estabelece que nenhuma rotina lógica pode chamar `ws.Range` diretamente, mesmo na V207 (fase de transição).
2.  **`knowledge/0020-evitacao-de-vazamento-de-instancia-dto.md`**: Diretrizes para o ciclo de vida dos objetos de dados em memória na V208, proibindo referências circulares entre instâncias de `TEmpresa` e coleções de rodízio que impeçam a liberação de memória pelo garbage collector do VBA.

### 1.2 Impacto na documentação Diataxis
A documentação Diataxis é impactada em duas etapas distintas:
*   **Em V207**:
    *   `docs/reference/`: Atualização da especificação das baterias de teste com a nova suíte `E2E_CADASTROS`.
    *   `docs/tutorials/`: Inclusão de tutoriais detalhando como os novos wrappers de performance afetam a gravação em bloco.
*   **Em V208**:
    *   `docs/explanation/`: Injeção de artigo de fundo detalhando a mecânica do ORM primitivo, explicando o funcionamento da transição de memória e da sincronização "dirty-checking".

### 1.3 Impacto no instalador/distribuição
*   **V207**: Zero impacto estrutural. O `Importador_V3` continua realizando a compilação por pacotes `.bas` textuais sem modificações além do `BUMP_NO_OP` para mitigar o loop de bump.
*   **V208**: O manifesto de importação ganha alta densidade de arquivos devido à fragmentação do Caminho 2 (DTOs, Coleções, Adapters). O Importador V3 deve ser estendido para validar a ordem exata de injeção das classes (Class Modules) antes de injetar os módulos padrão, prevenindo falhas de inicialização de tipos.

### 1.4 Impacto na auditoria (Audit_Log, evidências, RVS)
*   O `Audit_Log` é mantido centralizado e sequencial.
*   **RVS**: Os contadores da bateria oficial de validação estendem-se apenas na V207 devido à nova suíte `E2E_CADASTROS` (`V1=171/0 + V2_Smoke=34/0 + V2_Canonica=24/0 + E2E_CADASTROS=10/0`). O resultado RVS permanece idêntico na V208, apenas validando que a mudança em memória não quebrou os asserts históricos.

### 1.5 Impacto na visão do usuário-final
*   **Em V207**: O gestor do município percebe uma melhora sutil de velocidade nos cadastros (cerca de ~3-5x mais rápido em decorrência da gravação em bloco), mas a ListBox do Menu Principal (reload cell-a-cell) continua apresentando pequenos engasgos.
*   **Em V208**: O ganho de velocidade é radical (30-50x), eliminando qualquer latência residual do Excel.

### 1.6 Impacto na preparação SaaS futura
Esta alternativa é excelente para o SaaS. A V207 separa as regras de negócio de forma nítida, e a V208 encapsula os dados em DTOs portáveis. Quando a equipe de backend reescrever o sistema, a lógica de objetos da V208 poderá ser transposta quase linha por linha para TypeScript ou Python.

### 1.7 Riscos sistêmicos (Governança, code-doc rot, fricção)
*   > [!CAUTION]
    > **Risco de Fricção do Operador (Fadiga de Deploy)**: A maior fragilidade da Alternativa I é o número total de ondas (12 a 17 ondas em duas versões distintas). O operador humano (Mauricio) terá de realizar entre 12 e 17 ciclos manuais de `ImportarPacoteV3_Delta` e compile VBE. Isso aumenta drasticamente a probabilidade de falhas operacionais, loops de conflito de importação e fadiga de testes.
*   *Code-Doc Rot*: Alto risco de a documentação da V207 ficar obsoleta ou gerar confusão semântica ao ser sobreposta pelas profundas mudanças conceituais da V208 em um curto espaço de tempo.

---

## 2. Alternativa II — Opção 4 híbrida (Caminho 1 + in-memory parcial)

A Alternativa II propõe um único ciclo de release (**V207** com 7 a 9 ondas), combinando a modularização monolítica enxuta (ondas V207.0 a V207.4) com a injeção cirúrgica de cache em memória **estritamente nas ListBoxes grandes e lentas do Menu Principal** (ondas V207.5 a V207.7) — resolvendo 80% do bottleneck percebido pelo usuário sem reescrever todo o acesso a dados.

```text
                               ┌────────────────────────────────┐
                               │     V207 (Opção 4 Híbrida)     │
                               │  Ondas 0..4: Monolito Enxuto   │
                               │  Ondas 5..7: Cache cirúrgico   │
                               └────────────────────────────────┘
```

### 2.1 Impacto na metodologia HBN (Knowledges novas)
1.  **`knowledge/0019-limites-do-hibridismo.md`**: Regra permanente que define as fronteiras do cache em memória. Proíbe expressamente o uso de cache em rotinas de persistência (como `Repo_OS.Inserir`), limitando-o exclusivamente a consultas de visualização de listas (ListBoxes).
2.  **`knowledge/0020-invalidação-estateless.md`**: Padrão declarativo obrigatório para sincronização de dados (ver §2.8).

### 2.2 Impacto na documentação Diataxis
*   **Altamente simplificada**: Toda a transição ocorre em uma única versão (V207). 
*   `docs/explanation/`: Um único artigo esclarece o mecanismo de "caching reativo de tela".
*   `docs/tutorials/`: O manual do operador é atualizado apenas uma vez, reduzindo a sobrecarga de treinamento de releases sucessivos.

### 2.3 Impacto no instalador/distribuição
Muito menor. A consolidação em uma única release reduz a fricção de distribuição de arquivos de manifesto para os municípios. O `Importador_V3` roda apenas 7-9 vezes no total, reduzindo o risco de corrupção do VBE decorrente de sucessivas reinjeções.

### 2.4 Impacto na auditoria (Audit_Log, evidências, RVS)
*   O `Audit_Log` registra explicitamente a inicialização e a invalidação do cache de listas (`CACHE_LOADED`, `CACHE_INVALIDATED`).
*   **RVS**: A bateria de testes ganha a suíte `E2E_CADASTROS` e asserts dedicados que verificam a consistência das ListBoxes (se a lista reflete a inclusão imediatamente).

### 2.5 Impacto na visão do usuário-final
**Excelente**: O gestor do município percebe o speedup máximo percebido (10-20x) imediatamente na V207. A inicialização de telas e o salvamento de cadastros tornam-se fluidos e instantâneos, sem a necessidade de esperar pelo desenvolvimento e homologação de uma versão V208.

### 2.6 Impacto na preparação SaaS futura
*   *Dificuldade*: Ligeiramente inferior à Alternativa I pura. Como a camada de cache em memória é aplicada cirurgicamente nas telas (camada de UI), a camada de persistência (`Repo_*`) ainda mantém alguns acoplamentos com coordenadas de células.
*   *Mitigação*: A extração das regras de negócios para os módulos `Svc_*` (ondas 0 a 4) permanece intacta, o que atende à necessidade de portabilidade da lógica.

### 2.7 Riscos sistêmicos (Governança, code-doc rot, fricção)
*   **Risco de Incoerência de Cache**: O maior risco sistêmico é a UI exibir dados desatualizados (ex.: uma empresa suspensa continuar aparecendo como ativa na ListBox porque a invalidação do cache falhou).
*   **Complexidade Interna**: O código dos UserForms lidará com duas fontes de verdade híbridas (a memória para exibir e a planilha para gravar).

### 2.8 Risco específico do híbrido: Contratos imaturos antes do in-memory
O maior perigo da Alternativa II é a IA tentar implementar o cache de listas (ondas V207.5+) enquanto a separação das regras lógicas nos módulos `Svc_*` e Repos (ondas V207.0 a V207.4) ainda estiver incompleta ou com bugs residuais. 

Para anular esse risco, institui-se três **Guard-rails Sistêmicos de Barreira**:

> [!CAUTION]
> **Guard-rail 1 — Barreira de Fase (Fase-Lock)**: As ondas de caching de listas (V207.5+) só poderão ser iniciadas após a homologação formal do Gate de Liberação das ondas 0-4. O Git deve ser carimbado com uma tag interna (ex.: `v12.0.0207-base-monolito`) e o RVS com a nova bateria `E2E_CADASTROS` deve estar 100% verde. **Proibido abrir branches ou comitar código de cache em paralelo.**

> [!CAUTION]
> **Guard-rail 2 — Padrão de Invalidação Stateless**: Para evitar drifts de dados na memória cache, o cache de listas do `Menu_Principal` não deve tentar atualizar "cirurgicamente" um único item alterado em sua coleção local. Em vez disso, qualquer chamada de invalidação de cache (ex.: `Cache_Invalidate("EMPRESAS")`) deve forçar a reconstrução total da coleção em memória lendo dinamicamente da planilha. Isso garante que o cache permaneça idempotente e imune a inconsistências de mutação parcial.

> [!CAUTION]
> **Guard-rail 3 — Registro Explicito de Callback**: Toda operação de gravação nos repositórios (`Repo_*.bas`) que afete os dados exibidos na tela deve invocar expressamente a rotina de invalidação da UI (ex.: `Menu_Principal.InvalidarCache(tipoAba)`), sob pena de falha mecânica no analisador estático de código.

---

## 3. Comparação sistêmica das duas alternativas

| Critério Sistêmico | Alternativa I (Linear V207→V208) | Alternativa II (Opção 4 Híbrida V207) |
|---|---|---|
| **Aderência ao Universal Migration Format** | Total (Camada de dados 100% isolada em DTOs na V208). | Parcial (Dados isolados na memória apenas para UI; repos ainda lêem abas na V207). |
| **Cobertura da Doc-Delta Pattern** | Exige manutenção documental dupla em dois ciclos de releases (mais trabalhoso). | Manutenção documental simplificada e contida em um único ciclo V207. |
| **Custo de Fricção e Deploy** | **Crítico**: Exige 12-17 importações/smoke-tests manuais por parte do operador Mauricio. | **Otimizado**: Reduz o esforço do operador para 7-9 ciclos em uma única versão. |
| **Taxa de Speedup Perceptível na V207** | Baixa (~3-5x cadastros; sem ganho em listas). | Alta (10-20x com listas em cache em memória instantâneas). |
| **Risco de Incoerência de Dados** | Muito Baixo (sem cache híbrido). | Médio (mitigado pelos Guard-rails 1, 2 e 3 do §2.8). |

---

## 4. Edge cases sistêmicos não cobertos pela 1ª rodada

### 4.1 Cenário: Um município decide sair (exportar) antes da V207 terminar
*   *O Problema*: Se um município demandar o uso offline completo durante o desenvolvimento intermediário (ex.: na onda V207.3), ele receberá um código com repositórios e serviços parcialmente desacoplados, mas sem a otimização final.
*   *A Solução Arquitetural*: A branch `codex/v12-0-0206-planejamento` deve sempre manter a integridade operacional a cada commit de fechamento de onda ERP. O "monolito intermediário" deve ser funcionalmente equivalente em todas as regras RN-01 a RN-17, garantindo que o município possa ejetar a planilha e trabalhar offline a qualquer momento.

### 4.2 Cenário: Migração de Workbooks históricos (V204/V205) para o formato V207
*   *O Problema*: Planilhas antigas ativas nos municípios contêm dados salvos em abas com estruturas que podem sofrer pequenos drifts visuais ou de cabeçalho.
*   *A Solução Arquitetural*: O manifesto da V207 deve incluir uma onda de boot em `Util_Sanear_Contadores` que não apenas saneia IDs (como na V206), mas executa uma rotina automática de **Reconciliação e Upgrade de Esquema**:
    1.  Verifica se a coluna U (`DT_ULT_REATIV`) existe em `EMPRESAS`. Se ausente, insere a coluna e executa o backfill de dados.
    2.  Verifica e força o formato numérico da coluna A (`NumberFormat="@"`) em todas as 7 abas para corrigir permanentemente o F-NEW3 de dados históricos.

### 4.3 Cenário: Compatibilidade de PDFs gerados na V206
*   *O Problema*: A mudança de renderização de PDF para ser robusta contra erros de spooler não deve alterar as dimensões da `PrintArea` nem o layout estético da aba `RELATORIO` homologada em V205.
*   *A Solução Arquitetural*: A rotina de PDF da V207 deve herdar os mesmos parâmetros de formatação estática e largura de coluna definidos nos formulários `.frm` estáveis. A robustez deve limitar-se ao tratamento de exceções do sistema operacional (spooler de impressora offline ou PDF bloqueado por outra instância de visualização), sem tocar no motor de desenho estético.

---

## 5. Alternativa III sistêmica — Arquitetura de Despacho Reativo por Eventos (EDRA)

Se as duas alternativas acima apresentarem riscos de acoplamento UI-Persistência ou incoerência de dados de cache, a Antigravity propõe a **Alternativa III (EDRA - Event-Driven Reactive Architecture)**:

```text
┌─────────────────┐     Evento de Mutação     ┌─────────────────────────┐
│ Repo_Empresa    ├──────────────────────────>│ Util_Event_Dispatcher   │
│ (Grava na Aba)  │                           └────────────┬────────────┘
└─────────────────┘                                        │
                                                           │ Notifica
                                                           ▼
                                              ┌─────────────────────────┐
                                              │ Menu_Principal (UI)     │
                                              │ - Reseta e reconstrói   │
                                              │   cache de listas       │
                                              └─────────────────────────┘
```

*   **O Conceito**: Introduzir um despachante de eventos simples em VBA (`Util_Event_Dispatcher.bas`).
*   **Mecânica**: 
    1.  O `Menu_Principal.frm` registra-se no dispatcher durante o `UserForm_Initialize`.
    2.  Qualque rotina mutadora nos repositórios (`Repo_Empresa.bas`) dispara um evento centralizado: `Dispatcher.Trigger "EMPRESAS_ALTERADAS"`.
    3.  A UI escuta o evento e dispara autonomamente seu reload stateless em memória de forma assíncrona.
*   **Vantagem**: Desacoplamento absoluto. Os Repos não precisam conhecer a existência do `Menu_Principal` (o que viola a arquitetura de camadas). Eles apenas notificam a mutação ao barramento.
*   **Desvantagem**: Introduce um paradigma orientado a eventos em VBA, o que aumenta a curva de aprendizado e exige testes de depuração mais rigorosos pelo operador.
