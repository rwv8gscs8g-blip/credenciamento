---
titulo: Auditoria Cruzada GATE-A4/L43 V12.0.0206 — Estabilização e Roadmap V206/V207
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-29
---

# Auditoria Cruzada — GATE-A4/L43 da V12.0.0206 — por Antigravity (chat novo)

## 1. Veredito
**BLOQUEAR** o freeze da versão **V12.0.0206** até que os **BLOQUEADORES** técnicos levantados nesta auditoria cruzada sejam sanados. A aprovação do RVS final (`VR_20260529_223908`) é um sinal verde para a consistência dos dados internos e execução das macros canônicas, mas o relatório humano `Primeiro GATE-USO-PROLONGADO L43.pdf` revela regressões graves de designer (arquivos `.frx`), falhas de integridade transacional na UI e problemas de performance no macOS que inviabilizam o uso estável em produção.

---

## 2. BLOQUEADORES (impedem o progresso e o freeze)

### 2.1 Regressão dos Campos de Strikes e Dias de Punição no Designer (`Configuracao_Inicial.frx`)
* **Descrição**: Os campos de parametrização da regra de strikes e dias de punição (`TxtNotaCorte`, `TxtMaxStrikes`, `TxtDiasSuspensao`) desapareceram completamente da interface visual de Configurações Iniciais. A causa é que o arquivo binário de layout `.frx` associado ao `Configuracao_Inicial.frm` foi sobrescrito por uma versão legada que não contém estes controles. Como os códigos de inicialização e salvamento estão encapsulados sob `On Error Resume Next`, o runtime não quebra, mas os campos retornam vazios (vazios na leitura e vazios na escrita), fazendo com que as regras de negócio de strikes e punição fiquem congeladas com os valores padrões da CONFIG e inacessíveis para alteração pelo usuário.
* **Evidência**: `Configuracao_Inicial.frm` linhas 96-98 e 332-334 e Relatório L43 pág. 11.
* **Remediação Proposta**: Reintegrar no designer VBE os controles do tipo `TextBox` com os nomes canônicos e estáticos `TxtNotaCorte`, `TxtMaxStrikes` e `TxtDiasSuspensao` nas posições corretas do UserForm `Configuracao_Inicial` e republicar o espelho em `local-ai/vba_import/`.

### 2.2 Falha de Integridade Transacional na Inativação de Entidades / Duplicidade de Estados (`Altera_Entidade.frm`)
* **Descrição**: Ao inativar uma entidade, o formulário realiza a cópia da linha ativa para a aba `ENTIDADE_INATIVOS` e depois a exclui da aba ativa `ENTIDADE`. Contudo, o código não verifica o retorno da função `Util_PrepararAbaParaEscrita` ao desproteger a aba ativa `wsEnt`. Se a desproteção falhar, a exclusão em `Util_ExcluirLinhaSegura` falhará silenciosamente ou lançará um erro, mas a cópia para inativas já terá sido feita. O registro permanece duplicado (existindo como ativo e inativo ao mesmo tempo). Isso quebra o validador de reativação que bloqueia reativações futuras com a mensagem: *"Reativacao bloqueada: ja existe entidade ativa com o mesmo ID ou CNPJ na linha 2"*.
* **Evidência**: `Altera_Entidade.frm` linhas 196-221 e Relatório L43 pág. 16.
* **Remediação Proposta**: Implementar uma verificação rígida no retorno de `Util_PrepararAbaParaEscrita` e, caso a exclusão da aba ativa falhe, realizar a reversão (rollback) deletando a linha recém-copiada da aba de inativas.

### 2.3 Regressão Crítica de Classificação por Ordenação com `.Header = xlGuess` (`Classificar.bas`)
* **Descrição**: Nas rotinas de ordenação de entidades e serviços, o parâmetro `.Header` do objeto `Sort` do Excel está definido como `xlGuess`. Isso faz com que o Excel tente "adivinhar" se a primeira linha de dados (linha 2) é um cabeçalho. Em dados reais (como nos testes E2E do L43), o Excel decide que a linha 2 é um cabeçalho e a exclui do sorteio, mantendo-a fixada no topo e fazendo com que novos registros fiquem em posições erráticas (ex.: entidades recém-cadastradas aparecendo no topo e misturadas na fila).
* **Evidência**: `Classificar.bas` linhas 18 (`ClassificaEntidade`) e 248 (`ClassificaServico`).
* **Remediação Proposta**: Alterar explicitamente `.Header = xlGuess` para `.Header = xlNo` em ambos os locais, garantindo que toda a faixa de dados (da linha 2 em diante) participe do sorteio.

### 2.4 Ausência do Local de Prestação (Endereço) e Detalhes na OS e Pré-OS (`Preencher.bas` / `Menu_Principal.frm`)
* **Descrição**:
  1. **Na Pré-OS**: O preenchimento da Pré-OS invoca `GarantirDadosPreOSParaImpressao(N_OS)`. Contudo, `N_OS` é formatado como uma string composta (ex.: `"PROVISÓRIA - 003"`), enquanto a busca na base `PRE_OS` exige o ID numérico bruto (ex.: `"003"`). A busca falha silenciosamente, saindo no `If linhaPre = 0 Then Exit Sub`, e deixa o campo de Local (`F18`) e todos os detalhes do demandante em branco na planilha de impressão.
  2. **Na OS**: No clique do botão `BE_ImprimeOS_Click`, o loop que busca os contatos da entidade na planilha carrega os dados `cont_entidade` e `telcont_entidade`, mas omite completamente a variável `END_ENTIDADE`.
* **Evidência**: `Preencher.bas` linhas 1061 e 1607, `Menu_Principal.frm` linhas 461-468 e Relatório L43 pág. 30.
* **Remediação Proposta**:
  - Passar o ID gerado real (`res.IdGerado`) para `GarantirDadosPreOSParaImpressao` na emissão da Pré-OS.
  - Carregar `END_ENTIDADE = SafeListVal(wsEnt.Cells(idxEnt, COL_ENT_ENDERECO).Value)` no loop de carregamento da OS.

---

## 3. FORTES (alta prioridade, devem ser incorporados)

### 3.1 Omissão de Campos de Contato e InfoAD no ListBox Principal (`Preencher.bas`)
* **Descrição**: Ao selecionar uma entidade na listbox `C_Lista` da tela principal de Cadastro de Entidades, os campos de contatos (Contato 1, Fone 1, Função 1, etc.), Bairro e Informações Adicionais (`C_InfoAD`) não são recarregados para as caixas de texto correspondentes (TextBox). O usuário tem a falsa impressão de que esses dados foram deletados da planilha. No entanto, ao efetuar duplo clique e abrir o form `Altera_Entidade`, os dados aparecem corretamente porque a listbox de fato contém todas as colunas. A falha está na sub-rotina de atribuição do evento click da lista.
* **Evidência**: `Preencher.bas` em `C_Lista_Click` (só popula 9 dos 22 campos da entidade).
* **Remediação Proposta**: Atualizar `C_Lista_Click` para ler e preencher todos os 22 campos a partir das colunas correspondentes da listbox.

### 3.2 Otimização do Loop e Remoção do Recalc/Save Duplo no Cadastro (`ProgressBar.frm`)
* **Descrição**: A lentidão de 24 segundos no cadastro de entidades deve-se ao loop inútil de delay com busy wait (`timedelay` com tight loop sobre `DateTime.Timer`), que causa 100% de CPU no macOS, e ao salvamento síncrono redundante (`ThisWorkbook.Save`) executado de forma embutida na barra de progresso no percentual de 90%, logo após o formulário mestre já ter salvado com sucesso via `Util_SalvarWorkbookSeguro`.
* **Evidência**: `ProgressBar.frm` em `CalculateData` (linha 70) e `timedelay` (linhas 87-101).
* **Remediação Proposta**:
  - Remover o `Save` síncrono de dentro da barra de progresso.
  - Substituir o busy wait de `timedelay` por um controle determinístico sem loops ou reduzir o número de passos síncronos no macOS.

### 3.3 Otimização das Operações de Desproteção em Lote no Credenciamento (`Credencia_Empresa.frm`)
* **Descrição**: O credenciamento por atividade varre a tabela `CAD_SERV` e, para cada serviço elegível não cadastrado, invoca `ProximoId(SHEET_CREDENCIADOS)`. Isso desprotege e protege a planilha `CREDENCIADOS` repetidamente para cada iteração do loop, além de varrer a planilha inteira a cada passo para achar posições e deduplicar. Se uma atividade contiver 10 a 20 serviços, a interface trava por até 10 segundos no Mac.
* **Evidência**: `Credencia_Empresa.frm` em `CR_Credenciar_Click` (linhas 161-205).
* **Remediação Proposta**: Desproteger a aba `CREDENCIADOS` uma única vez antes de iniciar o loop de gravação dos serviços e restaurar a proteção após a conclusão de todo o lote.

### 3.4 Stall de 1-2 minutos no Acesso ao GitHub no Mac (`Menu_Principal.frm`)
* **Descrição**: Ao clicar no botão do GitHub, o sistema tenta usar `Application.FollowHyperlink` e `ThisWorkbook.FollowHyperlink`. No macOS, esses métodos síncronos falham ou travam a thread do Excel aguardando timeouts ou avisos de segurança por 1 a 2 minutos. Somente após esses travamentos ocorre a queda no bloco fallback com `Shell "open ..."` que abre a página web instantaneamente.
* **Evidência**: `Menu_Principal.frm` em `AbrirURLExterna` (linhas 3510-3530).
* **Remediação Proposta**: Verificar a plataforma no início de `AbrirURLExterna` e, se for Mac, invocar diretamente o comando `Shell "open ..."` sem tentar os hyperlinks internos do Excel.

### 3.5 Bug de Formatação de Notas da Avaliação na Impressão (`Preencher.bas`)
* **Descrição**: As notas na OS e na avaliação aparecem formatadas como `98,0` em vez de `9.8` ou `10.0` no relatório impresso. A causa é o uso da string de formatação `Format(value, "##,#")` em vez de uma formatação decimal explícita (ex.: `Format(value, "0.0")`), além da falta de uma validação defensiva que limite e trunque a nota a 10 no banco antes de gravar em `Repo_Avaliacao`.
* **Evidência**: `Preencher.bas` linhas 3259-3268 e Relatório L43 pág. 31.
* **Remediação Proposta**: Substituir a string de formatação nos 10 campos e introduzir o teto defensivo `If nota > 10 Then nota = 10` em `Repo_Avaliacao.Inserir`.

---

## 4. MARGINAIS (nice-to-have, podem entrar no V206 se houver tempo ou ficam para o V207)

### 4.1 Interface de Limpeza e Novo Cadastro ("Limpar Campos")
* **Descrição**: A falta de um botão de limpeza rápida obriga o usuário a apagar manualmente as caixas de texto campo por campo antes de preencher uma nova empresa ou entidade.
* **Evidência**: Relatório L43 pág. 23.
* **Remediação Proposta**: Adicionar um botão "Limpar" nos formulários `Menu_Principal` e `Credencia_Empresa` que limpe os campos com `Empty`.

### 4.2 Sobreposição Visual de Filtros Dinâmicos em `Credencia_Empresa.frm`
* **Descrição**: A caixa de texto dinâmica adicionada por `Controls.Add` para busca de serviços se sobrepõe com a lista e as legendas no UserForm, gerando layout inadequado.
* **Evidência**: `Credencia_Empresa.frm` em `CR_EnsureFiltroListaDinamico` e Relatório L43 pág. 24.
* **Remediação Proposta**: Criar a caixa de texto de filtro de forma estática no designer VBE do formulário, removendo a necessidade de criação dinâmica em runtime.

---

## 5. Convergências com o trabalho original auditado
1. **Regras de Strikes Estáveis no Motor**: O RVS prova que o motor rodízio de strikes passa sem falhas em cenários de dados puros (`E2E_STRIKES=76/0`). As regras internas estão robustas e coerentes.
2. **Preservação de Proteção e IDs no Core**: A lógica monotonica `Util_MaxIdOperacional` impede a renumeração errônea de IDs mesmo com inativas.

---

## 6. Divergências (argumento técnico)
* **Divergência**: O RVS aprovado sinaliza que o build está apto para liberação. Esta auditoria **diverge radicalmente** dessa conclusão por entender que o RVS automatizado não captura defeitos de layout, corrupção de arquivos `.frx` (controles fantasmas), timeouts síncronos de rede específicos de Mac e bugs transacionais que ocorrem apenas em fluxos manuais múltiplos (inativações). A aprovação do RVS é necessária, mas não suficiente.

---

## 7. Riscos não cobertos
* **Risco de Corrupção de Estado Global**: A persistência manual forçada por dentro de loops pode corromper o arquivo `.xlsm` caso o usuário force o encerramento do Excel durante o processamento.
* **Risco de Segurança nos Comandos Shell**: O uso de `Shell` no Mac é necessário para contornar o timeout, mas requer tratamento defensivo contra injeção de parâmetros em URLs.

---

## 8. Recomendação de próxima ação e Roadmap de Estabilização

Proposta de divisão do escopo em 2 ondas focadas no Codex para atingir a V12.0.0206 validada de fato:

```mermaid
grid
  Onda_38.2.4["Onda 38.2.4: Estabilização de Designer e Integridade UI (Bloqueadores)"]
  Onda_38.2.5["Onda 38.2.5: Correção de Performance e Tempos macOS (Fortes)"]
  Release_V206["Release Freeze V12.0.0206"]
```

### Onda 38.2.4: Estabilização de Designer e Integridade UI (Foco: Bloqueadores)
* **Objetivo**: Sanar todas as quebras críticas que colapsam a planilha ou impedem o uso de regras parametrizadas.
* **Escopo**:
  - Corrigir `.frx` de `Configuracao_Inicial.frm` trazendo os textboxes de strikes e dias de punição.
  - Implementar verificação transacional rígida com exclusão segura em `Altera_Entidade.frm`.
  - Trocar `.Header = xlGuess` para `xlNo` em `Classificar.bas`.
  - Corrigir a chamada de `GarantirDadosPreOSParaImpressao` usando `res.IdGerado` na Pré-OS e ler `END_ENTIDADE` no preenchimento da OS.
* **Testes Esperados**:
  - Cadastro, inativação e reativação múltipla manual de entidades no VBE sem duplicidade.
  - Parametrizar strikes para 2 e conferir o bloqueio de indicação no rodízio de forma determinística na UI.

### Onda 38.2.5: Correção de Performance e Tempos macOS (Foco: Fortes + UX)
* **Objetivo**: Garantir que as telas carreguem e respondam em menos de 1 segundo e que os relatórios impressos fiquem perfeitos.
* **Escopo**:
  - Popular todos os 22 campos de detalhe no evento `C_Lista_Click`.
  - Desproteger `CREDENCIADOS` apenas uma vez fora do loop em `Credencia_Empresa.frm`.
  - Corrigir `timedelay` e remover o save duplo em `ProgressBar.frm`.
  - Ignorar `FollowHyperlink` no Mac e direcionar direto para o comando shell.
  - Ajustar a formatação de notas na avaliação para `"0.0"`.

### Não-Objetivos (Ficam para V207)
* Reestruturação em banco ou cache síncrono in-memory (deve aguardar o freeze absoluto da V206).
* Redesenho geral das cores e bordas da OS (exige aprovação de template do usuário).

### Checklist Anti-Viés de Bastão (P4)
1. **Declaração de Auto-Indicação**: A Antigravity não se auto-indica para a implementação. Como auditor sistêmico e máquina de estados, o papel natural de execução pertence ao **Codex**, que já lidera as implementações da Onda 38.2.3.
2. **Evidência Objetiva**: O Codex possui os manifests ativos na branch, compilou o RVS com êxito na Fase 2 e conhece intimamente a estrutura dos formulários e repositórios afetados.
3. **Reconhecimento do Viés**: A recomendação do Codex evita o overhead de transferência de lógica de domínio e mantém a consistência da escrita iniciada na V206.
4. **Mitigação**: O Codex deve agir sob scope estrito das duas ondas propostas e a Antigravity fará a auditoria adversarial focada nos diffs de designer e segurança nos comandos shell de Mac.

🔵 HBN HANDOFF READY — Relatório de auditoria e roadmap prontos para análise de Mauricio e Codex.
