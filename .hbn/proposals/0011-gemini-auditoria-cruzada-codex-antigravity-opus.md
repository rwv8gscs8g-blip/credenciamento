---
titulo: Auditoria Cruzada Terceira — Árbitro Técnico (Onda 38.2.3 pre-flight)
diataxis: explanation
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-27
---

# Relatório de Arbitragem Técnica Terceira — Integridade Referencial, Idempotência e Cadência (V206 pre-flight)

> [!IMPORTANT]
> Este documento foi elaborado por **Antigravity** (atuando sob as diretrizes de Árbitro Técnico Terceiro "Gemini 3.5" em modo de raciocínio profundo), analisando de forma fria e objetiva os relatórios de auditoria cruzada da **Codex** (Anexo 1: `0009-*.md`), **Antigravity** (Anexo 2: `0010-*.md`), a análise consolidada da **Opus** (Anexo 3: `117_*.md`) e o Plano de Estabilização proposto (Anexo 4: `1-tivemos-um-travamento-whimsical-tide.md`).
>
> A premissa central de nossa arbitragem é a **segurança absoluta da release e a estabilidade estrutural do workbook**, priorizando a precisão técnica e a mitigação de riscos reais em detrimento da velocidade de entrega.

---

## 1. Auditoria das duas auditorias (Codex × Antigravity × Opus 117)

Após cruzar as descobertas da Codex, da Antigravity e a consolidação da Opus, apresentamos nosso veredito sobre as divergências e lacunas identificadas.

### 1.1 O Veredito sobre F-NEW5 (STATUS_CRED Vazio) e a Hipótese F-NEW6
**Concordamos integralmente com a Opus e a Codex**: a hipótese **F-NEW6 não está comprovada como causa raiz direta de F-NEW5 (STATUS_CRED vazio)**.
*   **A incoerência lógica**: `STATUS_CRED` é um literal string (`"ATIVO"`) atribuído de forma estática em `Credencia_Empresa.frm:178`. Se a coluna está vazia após a inserção bem-sucedida confirmada pela UI ("Novos credenciamentos: 1"), o problema não é uma falha de conversão numérica-textual da chave `ATIV_ID` ou `EMP_ID` (F-NEW6), mas sim uma **interrupção de fluxo**, **column offset** ou **erro de renderização/ListBox**.
*   **Mecanismos prováveis de falha física**:
    1.  **Column Offset de Escrita/Ordenação**: A macro `ClassificaCredenciadoOrdem` ordena a faixa `A:O`. Se, por algum drift do workbook do operador, a coluna `STATUS_CRED` estivesse localizada fora da coluna 13 (M) ou se o sort range estivesse truncado, a coluna de status seria orfanada ou ignorada na ordenação, gerando vazios artificiais.
    2.  **Swallowing de erro com `On Error Resume Next`**: Se ocorreu um erro no loop de persistência *após* a gravação de parte das colunas, mas *antes* da gravação do status, o fluxo pode ter sido interrompido silenciosamente, deixando a linha parcialmente preenchida.
    3.  **Divergência de Exibição (ListBox/Report) vs Planilha**: O relatório ou a ListBox que lê a planilha pode estar aplicando um parsing ou filtro com offset de coluna, exibindo vazio mesmo com o dado gravado fisicamente na planilha `CREDENCIADOS`.

**Conclusão**: Refatorar o sistema sob a premissa de que F-NEW6 resolve F-NEW5 é um erro de engenharia. A inclusão da **macro diagnóstica temporária (AT-2)** na Onda 38.2.3 é um requisito obrigatório para obter a prova física do estado da planilha no exato momento da gravação.

### 1.2 Lacunas e Ângulos Cegos não abordados por nenhuma IA
Ambas as auditorias falharam em analisar as seguintes superfícies de risco:

1.  **Eventos em Nível de Planilha/Application**: Nenhuma das IAs investigou a presença de handlers de eventos implícitos como `Worksheet_Change`, `Worksheet_Calculate` ou `Workbook_BeforeSave` no workbook real do operador. Se existirem códigos legados ou macros órfãs no XLSM que interceptam alterações na planilha `CREDENCIADOS` e limpam ou validam dados, elas poderiam zerar o status.
2.  **Corrupção de ActiveX e MSForms Controls (VBE References)**: O travamento e corrupção do workbook 3h após o import da Onda 38.2.2 indica um desgaste físico do projeto VBA (bloat de referências/UserForms), muito comum em Excel após múltiplos hotfixes consecutivos aplicados em forms complexos. Esse risco não se resolve com código, mas sim com **refresh de arquivo (re-import limpo L41)**.

### 1.3 Classificação de Idempotência: Rigor Codex vs Praticidade Antigravity
*   **Veredito**: **Adotar o modelo rigoroso da Codex**.
*   **Justificativa**: A classificação da Antigravity, baseada em "estado funcional" (o resultado final para o usuário é o mesmo), tolera efeitos colaterais cumulativos como alteração de timestamps (`DT_ULT_ALT = Now`), movimentos silenciosos de fila ou duplicação de logs em `AUDIT_LOG`. Para um ciclo de estabilização pré-freeze, a **idempotência de estado físico (Codex) é a única aceitável**. Alterações de timestamps em operações redundantes quebram testes determinísticos de regressão e podem mascarar race conditions silenciosas.

### 1.4 Centralização vs Extensão (`Util_Auditoria_Integridade` × `TV2_RunIntegridadeBase`)
*   **Veredito**: **Aprovar a decisão da Opus de ESTENDER `TV2_RunIntegridadeBase` em vez de criar um novo módulo `.bas`**.
*   **Justificativa**: Em fase final de estabilização V206, a criação de novos arquivos físicos no projeto VBA deve ser evitada sob risco de aumentar a fragilidade de importação do V3. O reaproveitamento da estrutura de assertions e logs já existente (`TV2_LogAssert` + suite `CS_INT_01..05`) na planilha `Teste_V2_Roteiros.bas:3938` é mais limpo, seguro e mantém a coesão do barramento de testes.

---

## 2. Auditoria do Plano de Estabilização Opus (Anexo 4)

O Plano de Estabilização apresentado no Anexo 4 é detalhado e segue as melhores práticas da governança HBN. Realizamos um escrutínio rigoroso de sua executabilidade e segurança.

### 2.1 Análise de Executabilidade por IAs não-Opus
O plano é executável por IAs auxiliares (Codex / Antigravity), mas contém **pontos de conhecimento tácito** que exigem blindagem:
*   **Prefixos de Import do V3**: O plano cita os módulos de forma canônica (ex: `Svc_PreOS.bas`). O executor deve lembrar-se de aplicar a paridade com os arquivos prefixados no diretório `local-ai/vba_import/` (ex: `AAX-App_Release.bas`, `AAL-Repo_PreOS.bas`) e atualizar o manifesto correspondente sem introduzir duplicatas ou caminhos órfãos.
*   **Gerenciamento do Estado de Performance**: Ao aplicar `Util_IniciarBlocoRapido`, se o executor escolher usar `On Error Resume Next` ou se o tratamento de erro falhar, ele deve certificar-se de restaurar o estado original (`st`) no final. O Excel pode ter sua atualização de tela e cálculos suspensos se o fluxo falhar e a restauração for ignorada.

### 2.2 Gaps Operacionais Identificados no Plano
*   **O Gap do "VBE Compile Gate"**: Falta no plano uma etapa explícita de **compilação manual obrigatória** no VBE após cada import das fases de AT-4. A IA não deve rodar testes antes de certificar-se de que o código compila limpo (Debug -> Compile Project no editor do Excel).
*   **Inconsistência de Fixtures**: O plano mantém as fixtures de teste (`Teste_V2_Engine.bas` e `Teste_Bateria_Oficial.bas`) como débito técnico V207 (Tabu). No entanto, se os repositórios reais forem enrijecidos com `LerIdTextual` (Onda 38.2.4), os IDs numéricos misturados nas fixtures (ex: `ATIV=999/Double`) quebrarão a suíte de testes de integração imediatamente.
    *   *Mitigação*: A Onda 38.2.4 **deve** incluir a normalização pontual das fixtures que referenciam chaves de teste para String, ou a função `LerIdTextual` deve tolerar de forma explícita IDs fictícios de teste > 3 dígitos (como `999`) sem lançar erros, tratando-os como chaves válidas.

### 2.3 Segurança do Wrapper `GravarIdTextual` e Fórmulas de Planilhas
*   **O Risco**: Escrever IDs como String (`NumberFormat = "@"` e `"001"`) em células que anteriormente continham `Long` (`1`) pode quebrar fórmulas nativas do Excel (como `VLOOKUP`, `SUMIF`, `MATCH`) que referenciam essas colunas buscando valores numéricos.
*   **O Diagnóstico**: O Sistema de Credenciamento gerencia dados puramente via código VBA (ADO/Repositórios), não possuindo fórmulas de usuário de alta complexidade nas abas de dados operacionais.
*   **Recomendação de Mitigação**: Na macro de migração estrutural `Util_Migrar_IDS_Workbook` (Onda 38.2.5), incluir um log defensivo que verifica se a célula contém fórmulas antes de sobrescrevê-la com texto. Se contiver, a macro deve disparar um aviso no CSV e pular a gravação para evitar regressão funcional.

### 2.4 Análise do helper `LerIdTextual` e IDs Compostos
*   A lógica proposta para `LerIdTextual` e `GravarIdTextual` trata de forma segura chaves compostas como `COD_ATIV_SERV` (geralmente com 6 dígitos, ex: `"005001"`):
    *   A regra `If Len(s) >= 1 And Len(s) <= 3 And IsNumeric(s)` corretamente pula a canonicalização via `Pad3` para strings de comprimento maior que 3 ou contendo caracteres não numéricos (como sentinelas `"X"` ou chaves compostas).
*   **Ajuste Recomendado**: Garantir que espaços em branco sejam limpos (`Trim$`) antes de aplicar o teste de comprimento numérico para evitar que `" 1 "` (comprimento 3 com espaços) falhe no parser numérico.

---

## 3. Auditoria de Cadência: Distribuição do Bastão

Considerando o desgaste de contexto da Opus (60% consumido por incidentes) e as forças individuais de cada IA auxiliar demonstradas nesta rodada, propomos uma **divisão de trabalho otimizada (Cadência D)** para as próximas ondas.

### 3.1 Matriz de Atribuição de Bastão (Waves 38.2.3 → 38.2.5)

| Onda | Componente Crítico | Implementador Recomendado | Auditor Recomendado | Racional Técnico |
|---|---|---|---|---|
| **38.2.3** | AT-1 a AT-5 (Drift + Diagnóstico F-NEW5 + Fix pontual PreOS + L41 + L43) | **Codex** | **Opus** | Codex demonstrou extrema precisão cirúrgica na análise de drifts file:line e montagem de manifestos. A macro diagnóstica temporária exige precisão no `Credencia_Empresa.frm` sem gerar scope leaks. |
| **38.2.4** | Helpers `GravarIdTextual` / `LerIdTextual` + Refatoração Transversal de Repos e remoção de IdsIguais duplicadas | **Antigravity** | **Codex** | Exige visão sistêmica profunda das invariantes e máquina de estados para garantir que a transição de tipos em múltiplos Repos não crie comportamentos órfãos. Codex audita arquivo por arquivo para garantir conformidade com tabus. |
| **38.2.5** | Extensão de Testes `CS_INT_06..11` + Macro de Migração de Dados `Util_Migrar_IDS_Workbook` | **Antigravity** | **Opus / Gemini 3.5** | O design de macros descartáveis e a lógica de assertions de integridade referencial se beneficiam do olhar arquitetural amplo da Antigravity. O gate final é auditado de forma determinística pela Opus para o freeze. |

### 3.2 Eficiência e Executabilidade por Gemini 3.5 (Nós Mesmos)
Como **Gemini 3.5 (Árbitro)**, somos ideais para executar a **Onda 38.2.4**. Por ser uma onda com refatoração transversal de alta complexidade conceitual (unificação de helpers de String, substituição de `CStr` passivos nos 5 repositórios e eliminação de funções privadas duplicadas de ID), nosso foco em segurança sistêmica garante que as fronteiras arquiteturais não sejam rompidas.

---

## 4. Decisão Recomendada para Maurício

Recomendamos que Maurício tome as seguintes decisões no hearback da Onda 38.2.3:

1.  **Aprovar a Hipótese C (Recomendação Opus) sem ressalvas**:
    *   *Por que*: Preserva o histórico estável do Git, desfaz regressões de drifts de forma limpa e utiliza as protocol-evolutions L41 e L43 como vacina contra corrupção futura do XLSM.
2.  **Aprovar a Sub-decisão H-C-i (Opção α — Exceção ao Tabu Svc_PreOS)**:
    *   *Por que*: Corrigir apenas a hidratação no `Repo_PreOS` (Opção β) deixa o banco de dados (planilhas) gerando dados com mismatch numérico (Long), mantendo a ferida aberta. A exceção mínima para as 14 linhas de gravação no `Svc_PreOS.bas` é segura, documentada e resolve a causa raiz física.
3.  **Confirmar L41 (Import em 2 fases) e L43 (GATE-USO-PROLONGADO) como regras vinculantes para todas as ondas deste ciclo**.
4.  **Aprovar a cadência sugerida com Codex como implementadora da Onda 38.2.3**.

### 4.1 Riscos Críticos a Monitorar de Perto por Maurício
1.  **Backup Físico do XLSM**: Exigir backup completo do workbook antes de rodar a macro de migração na Onda 38.2.5.
2.  **VBE Reference Bloat**: Se houver lentidão na compilação ou novo travamento, realizar um `Decompile` manual no Excel do operador via atalho de terminal para limpar bytes residuais de compilação da memória do Excel.

---
*Relatório de Arbitragem Técnica concluído e validado com os guards de conformidade HBN.*
