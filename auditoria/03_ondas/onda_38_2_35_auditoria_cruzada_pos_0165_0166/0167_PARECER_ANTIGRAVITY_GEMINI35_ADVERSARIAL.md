---
titulo: Parecer Antigravity Gemini 3.5 — Auditoria adversarial pos-0165/0166
diataxis: status
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-09
---

# Parecer Antigravity Gemini 3.5 — Auditoria adversarial pos-0165/0166

Parecer técnico de auditoria adversarial pós-conclusão da Onda 0165 (Pre-OS vencidas: relatório e impressão) e do fechamento 0166 (limpeza de worktree), avaliando o comportamento operacional, mensagens, relatórios, PDFs, testes e riscos para a validação tela a tela da release **V12.0.0206**.

---

## 1. Findings (BLOQUEADOR / FORTE / MARGINAL)

### MARGINAL: Defeito visual de espaçamento distribuído de caracteres em formulários PDF impressos
- **Descrição**: O texto explicativo do status operacional no topo dos formulários impressos (Pré-OS, OS e Avaliação) é impresso com espaços excessivos e artificiais entre as letras (ex: `Status da empres a nes ta data: s tatus =ATIVA; dis ponibilidade=...`). Isso ocorre porque a célula `C16` (ou o intervalo `C16:N16`) nas planilhas de template (`EMITE_PREOS`, `EMITE_OS` e `AVALIA_SERV`) possui alinhamento horizontal definido como "Justificado" ou "Distribuído" no Excel, o que força o renderizador de PDF a esticar o texto para preencher toda a largura da célula. Em contrapartida, o aviso impresso na caixa de observações (`B40` na aba de Avaliação) é renderizado com espaçamento normal.
- **Impacto**: Dificulta a legibilidade humana do aviso de auditoria nos PDFs impressos. Não afeta a lógica do rodízio.

### MARGINAL: Cobertura de testes dirigida apenas a contrato estático (Token-based)
- **Descrição**: O teste `REL_TELA_11_PREOS_VENCIDAS_IMPRESSAO_SEM_EXPIRAR` valida a ausência de mutações no relatório por meio do helper `TV2_EST_LogTrechoContrato`. Este helper analisa de forma estática o arquivo fonte `Menu_Principal.frm` no repositório. Embora garanta a integridade estrutural e previna regressões em tempo de desenvolvimento, ele não executa a macro em runtime para validar cenários de proteção de planilhas ou indisponibilidade de impressoras locais.
- **Impacto**: Limitação de cobertura em tempo de execução.

### MARGINAL: Ocultamento de estado operacional secundário sob suspensão global
- **Descrição**: O método `RRS_DisponibilidadeOperacionalEmpresa` calcula a disponibilidade seguindo uma hierarquia estrita onde a suspensão global (`STATUS_EMP_SUSPENSA`) precede as verificações de documentos pendentes. Se uma empresa com OS em andamento ou Pré-OS pendente for suspensa no cadastro, o status exibido no relatório será `"SUSPENSA ATE ..."` ou `"REATIVAVEL - PRAZO VENCIDO"`.
- **Impacto**: O operador perde a visibilidade de que há uma OS ativa em andamento para aquela empresa apenas olhando o status de disponibilidade.

### MARGINAL: Versão antiga ("V12.0.0205") exibida no rodapé dos relatórios da V12.0.0206
- **Descrição**: O rodapé dos relatórios impressos exibe o literal `V12.0.0205` (ex: `Ref EMPRESAS_CADASTRADAS_20260608_161212 | V12.0.0205`). Isso é causado pelo fato de o código ler a constante `APP_RELEASE_ATUAL` de `App_Release.bas` (que aponta para a release oficial vigente). A promoção da versão para `V12.0.0206` só ocorrerá ao fim do ciclo de homologação.
- **Impacto**: Risco de confusão para auditores externos analisando artefatos gerados na branch de desenvolvimento.

---

## 2. VETO_AVANCO

**VETO_AVANCO: NAO**

### Racional
A análise adversarial do código e dos PDFs (`072.pdf` a `078.pdf`) comprova que o fluxo do relatório de Pré-OS vencidas é estritamente **read-only** e não realiza qualquer mutação operacional. O teste dirigido estático protege o código contra regressões futuras, e a documentação no manual operacional instrui adequadamente o usuário. Os findings detectados são de natureza visual ou de legibilidade de status secundários (classificados como **MARGINAL**), não havendo impedimentos técnicos ou comportamentais críticos que justifiquem o veto ao avanço do projeto para a homologação tela a tela.

---

## 3. Evidências de Código e Arquivo/Linha

- **Relatório Read-only (Sem Mutação)**:
  - No arquivo [Menu_Principal.frm](file:///Users/macbookpro/Projetos/Credenciamento/src/vba/Menu_Principal.frm#L3497-L3621), a subrotina `PRE_OS_Vencidas_Click` manipula apenas a ordenação (`ClassificaDataPreOS` / `ClassificaPreOS`), formatação de células e o método de impressão (`wsRel.Range(...).PrintOut`). Nenhuma chamada a `ExpirarPreOS`, `RecusarPreOS` ou `AvancarFila` é realizada.
- **Query Helpers no Relatório**:
  - No arquivo [Menu_Principal.frm](file:///Users/macbookpro/Projetos/Credenciamento/src/vba/Menu_Principal.frm#L3572-L3584), todas as colunas de status da empresa chamam funções do módulo `Rel_Rodizio_Status.bas` (ex: `Rel_StatusEmpresaTexto`, `Rel_SuspensaDesdeEmpresaTexto`, `Rel_DisponibilidadeEmpresaTexto`, etc.).
  - No arquivo [Rel_Rodizio_Status.bas](file:///Users/macbookpro/Projetos/Credenciamento/src/vba/Rel_Rodizio_Status.bas#L126-L174), as funções como `RRS_DisponibilidadeOperacionalEmpresa` são puras e realizam apenas leitura de planilhas (`LerEmpresa`, `TemOSAbertaNaAtividade`, `TemPreOSPendenteNaAtividade`).
- **Defeito de Espaçamento no PDF (C16)**:
  - No arquivo [Preencher.bas](file:///Users/macbookpro/Projetos/Credenciamento/src/vba/Preencher.bas#L1650-L1660), o método `Preencher_EscreverAvisoOperacional` insere o aviso operacional na célula `C16` e aplica `ShrinkToFit = True`. No entanto, como o alinhamento da célula é distribuído horizontalmente nas planilhas físicas de template, a impressão gera textos esticados (espaçamento distorcido), visível nos PDFs `075.pdf` (L13), `076.pdf` (L13) e `078.pdf` (L13).
- **Contrato de Teste Estático**:
  - No arquivo [Teste_V2_Roteiros.bas](file:///Users/macbookpro/Projetos/Credenciamento/src/vba/Teste_V2_Roteiros.bas#L1887-L1897), o teste `REL_TELA_11_PREOS_VENCIDAS_IMPRESSAO_SEM_EXPIRAR` utiliza `TV2_EST_LogTrechoContrato` para analisar o conteúdo do arquivo `Menu_Principal.frm` entre as linhas delimitadoras `Private Sub PRE_OS_Vencidas_Click()` e `Private Sub Rel_EmpXServ_Click()`.
- **Hierarquia de Disponibilidade**:
  - No arquivo [Rel_Rodizio_Status.bas](file:///Users/macbookpro/Projetos/Credenciamento/src/vba/Rel_Rodizio_Status.bas#L151-L158), o status `STATUS_EMP_SUSPENSA` retorna imediatamente `"SUSPENSA ATE ..."` ou `"REATIVAVEL"`, ignorando as verificações posteriores de `"OS EM EXECUCAO"` ou `"PRE-OS PENDENTE"`.

---

## 4. Testes Manuais Recomendados (Validação Tela a Tela)

1. **Validação de Impressora Padrão**:
   - Executar o clique no botão **Pré-OS Vencidas** em um computador sem impressoras configuradas (ou com a impressora em modo offline) para assegurar que a subrotina não resulte em travamento total do Excel e que a aba temporária `RELATORIO` seja limpa corretamente após a exibição do erro.
2. **Conferência de Alinhamento nos Templates**:
   - Abrir manualmente os templates `EMITE_PREOS`, `EMITE_OS` e `AVALIA_SERV`, selecionar a célula `C16`, abrir a janela "Formatar Células" e alterar o alinhamento horizontal de "Distribuído (Justificado)" para "Esquerda (Recuo)" ou "Centralizado". Em seguida, gerar novas PDFs e comprovar que o aviso do status da empresa foi impresso sem espaços excessivos entre as letras.
3. **Verificação de Suspensão com Pré-OS Pendente**:
   - Simular um cenário onde uma empresa possui uma Pré-OS pendente e recebe uma suspensão (por strikes ou manual). Gerar o relatório de **Pré-OS Vencidas** e conferir se ela aparece na lista com o status de disponibilidade `"SUSPENSA ATE ..."` e se o operador consegue rastrear a pendência da Pré-OS.
4. **Verificação de Novo Período sem Anistia**:
   - Preencher a base com empresas suspensas, executar o comando **Iniciar Novo Período** no painel de Configurações Iniciais e garantir visualmente que:
     - As planilhas `PRE_OS` e `CAD_OS` foram limpas.
     - O contador de ID de Pré-OS/OS foi resetado para 0.
     - As empresas suspensas continuam registradas como suspensas e não podem receber Pré-OS ou participar do rodízio no novo período (sem anistia implícita).

---

## 5. Lacunas de Cobertura Automatizada

1. **Teste de Impressão Física/PDF**:
   - Não há teste automatizado capaz de capturar falhas no motor de renderização de PDF do Excel ou no envio do documento à fila de impressão. A integridade visual das bordas e do espaçamento das fontes permanece 100% dependente da validação humana (inspeção dos PDFs gerados).
2. **Mock de Estado de Planilha Protegida**:
   - Não há teste automatizado que verifique se as subrotinas de relatório lidam corretamente com planilhas que já estejam protegidas por senha diferente da padrão do sistema, o que causaria erro de runtime na chamada `Util_PrepararAbaParaEscrita`.
3. **Teste de Limite de Páginas do Relatório**:
   - Não há teste automatizado que simule um volume massivo de registros no relatório (ex: 500 Pré-OS vencidas) para validar se a quebra de página e a área de impressão (`wsRel.PageSetup.PrintArea`) são delimitadas sem truncamento de dados ou estouro de memória.

---

## 6. Riscos de UX / Mensagem / PDF

- **Divergência de Versão (V12.0.0205 vs V12.0.0206)**:
  - Relatórios impressos mostram o literal da release oficial (`V12.0.0205`), mas estão sendo executados sob a branch da `V12.0.0206`. Isso cria uma inconsistência documental em auditorias se o operador não for alertado.
- **Espaçamento de Letras nos Formulários**:
  - A formatação distribuída da célula `C16` nos impressos prejudica a estética do sistema, passando uma impressão de desorganização visual ou falha de codificação (mojibake visual) em documentos enviados a parceiros externos.
- **Visibilidade de OS ativa em Empresas Suspensas**:
  - Apresentar apenas `"SUSPENSA ATE ..."` na disponibilidade operacional de uma empresa que possui uma OS ativa (em execução) pode induzir o operador ao erro de acreditar que a empresa está inativa/sem serviços correntes, esquecendo-se de cobrar a finalização dos reparos em andamento.

---

## 7. Checklist Anti-Viés (Hipóteses Favoráveis Derrubadas)

Durante a auditoria, foram testadas e derrubadas as seguintes hipóteses favoráveis:

1. *Hipótese: O teste dirigido `REL_TELA_11` valida o comportamento de impressão dinamicamente.*
   - **Derrubada**: Ao inspecionar `TV2_EST_LogTrechoContrato` e o seu consumo em `Teste_V2_Roteiros.bas`, constatou-se que o teste realiza apenas uma busca de substrings de texto nos arquivos `.frm` locais do repositório, não executando nenhuma rotina de impressão em runtime. Trata-se de um teste estático de conformidade sintática.
2. *Hipótese: O aviso impresso nos formulários possui o mesmo espaçamento em todas as áreas.*
   - **Derrubada**: Ao analisar o texto extraído de `077.pdf` (Avaliação), constatou-se que o aviso em `C16` (L19) está distorcido por espaçamento, enquanto o mesmo texto inserido na caixa de observações `B40` (L55-56) está com a formatação normal. A causa é o alinhamento da célula do template, e não a string montada pelo VBA.
3. *Hipótese: O relatório de Pré-OS vencidas auto-limpa a base operacional em Novo Período.*
   - **Derrubada**: A rotina de Novo Período em `Configuracao_Inicial.frm` realiza a limpeza de `PRE_OS` e `CAD_OS`, mas não limpa o histórico de suspensões em `EMPRESAS` ou `AUDIT_LOG`. A persistência das punições foi testada e confirmada como um comportamento intencional para evitar anistias indevidas.
