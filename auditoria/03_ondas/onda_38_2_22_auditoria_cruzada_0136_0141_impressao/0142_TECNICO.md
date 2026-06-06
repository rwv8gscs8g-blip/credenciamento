---
titulo: Relatório de Auditoria Cruzada - Ondas 0136 a 0141 e Resíduos de Impressão
diataxis: onda
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-03
---

# Relatório Técnico 0142 - Auditoria Cruzada e Resíduos de Impressão V12.0.0206

Este relatório formaliza a auditoria sistêmica independente sobre as ondas executadas recentemente (0136 a 0141) e detalha a análise dos resíduos críticos de impressão visualizados nos PDFs (001, 002 e 003) gerados a partir do workbook de referência.

---

## 1. Sumário Executivo

A auditoria cruzada confirma que a estratégia adotada nas ondas 0136 a 0141 blindou com sucesso o *motor* de regras do sistema (como a correção de `BO_330` na Onda 38.2.18-fix1, a resolução de demandantes por módulos em 38.2.19-fix1 e as defesas em `Svc_Avaliacao` na Onda 38.2.21), contornando os riscos de instabilidade do VBE causados pela importação de formulários de grande porte.

No entanto, há uma **crise silenciosa de integridade visual e documental**: a aprovação integral dos gates RVS (como `VR_20260602_182253` verde com 0 falhas) é **estruturalmente cega** aos defeitos físicos nos PDFs de OS, Pré-OS e Avaliação. Os testes de impressão validam apenas funções auxiliares em memória e tokens estáticos no arquivo de código, falhando em inspecionar o preenchimento das células reais nos templates do Excel.

Como consequência, persistem **2 BLOQUEADORES visuais/documentais** (informações críticas faltantes ou zeradas no papel oficial) e **2 MARGINAIS estéticos**, os quais impedem a declaração de freeze da V12.0.0206.

---

## 2. Reconciliação dos Riscos e Re-análise do Parecer 0024

Abaixo, mapeamos o status atual dos riscos originalmente levantados no **Parecer 0024** confrontando com o estado entregue até a Onda 0141:

| Código | Item do Parecer 0024 / L43 | Status na Onda 0141 | Risco Residual | Observações / Causa da Permanência |
| :--- | :--- | :--- | :--- | :--- |
| **BL-1** | TextBoxes NotaCorte/MaxStrikes/DiasSuspensao ausentes do painel Config | **PENDENTE** | **ALTO** | O formulário `Configuracao_Inicial` e seu `.frx` não foram editados por conta da blindagem contra importação de forms. O motor usa defaults seguros, mas a interface não exibe os campos. |
| **BL-2** | Entidades fora de ordem (`.Header = xlGuess`) | **RESOLVIDO** | **ZERO** | `xlGuess` foi completamente removido e substituído por `xlNo` em `Classificar.bas:18` e `:248`. |
| **BL-3** | Inativação não-atômica de Entidade | **RESOLVIDO** | **ZERO** | Lógica de rollback e transação adicionada ao componente `Altera_Entidade.frm`. |
| **BL-4** | Proteção não-persistente das células | **RESOLVIDO** | **ZERO** | `Auto_Open` instrumentado para gravar marcadores persistentes no workbook e restaurar proteção. |
| **BL-5** | Clamp da nota de avaliação na impressão | **PARCIAL** | **MÉDIO** | A regra de clamp foi centralizada, mas o texto da avaliação continua desalinhado física e visualmente no template. |
| **BL-6** | Local de prestação em branco na OS impressa | **RESOLVIDO (CÓDIGO)** | **BAIXO** | Código corrigido para preencher `F18` com `END_ENTIDADE`. Resta homologação de layout. |
| **BL-7** | Dados em branco na Pré-OS impressa | **RESOLVIDO (CÓDIGO)** | **BAIXO** | Normalizador de ID resolve prefixos ("PROVISÓRIA"). Resta homologação de layout. |

---

## 3. Achados por Severidade (Resíduos de Impressão e Gates)

### 3.1 BLOQUEADORES (3)

#### Achado #01 (Sistêmico / Testes) - Falso Positivo nos Gates de Impressão (Falso Verde)
* **Sintoma:** Os gates de homologação V2/RVS retornam verde para a suíte de impressão, mas os PDFs são gerados com campos vazios e valores incorretos.
* **Causa-raiz:** Os testes em `Teste_V2_Roteiros.bas` (como `TV2_RunImpressaoIntegridade`) não lêem os valores gravados nas planilhas do Excel. Eles apenas validam se funções de normalização em memória funcionam (`Preencher_NotaAvaliacaoImpressaSegura`) ou se as strings de gravação aparecem no código-fonte (`TV2_EST_LogComponenteContemTokens` procurando por `ws.Range("F18").Value = END_ENTIDADE`). Nenhuma célula física é inspecionada pós-escrita.
* **Impacto:** Qualquer regressão em layout de template físico passa invisível pelo RVS.

#### Achado #02 (Visual / Domínio) - IMP_AVALIA: Demandante Gravado na Célula Incorreta (L8 vs L9:P15)
* **Sintoma:** O quadro Demandante no PDF da Avaliação (`003.pdf`) fica completamente vazio.
* **Causa-raiz:** No arquivo `Preencher.bas` (linha 3339, sub `PreencherAvaliacaoOS`), o código grava as informações da Entidade na célula `L8`:
  `ws.Range("L8").Value = Desc_entidade & " - " & cont_entidade & " - " & telcont_entidade`
  No entanto, no layout do template físico da aba `IMP_AVALIA`, o campo Demandante é a célula mesclada `L9:P15`. A célula `L8` está fora do campo visível ou oculta.
* **Impacto:** O documento oficial é emitido sem a identificação do demandante da OS.

#### Achado #03 (Visual / Domínio) - EMITE_OS: Total Final Zerado no PDF (M63 vs N63:P63)
* **Sintoma:** O total final na página 2 da OS (`002.pdf`) imprime `0` ou `"-"` mesmo para OS com itens contendo valores reais.
* **Causa-raiz:** No template físico da aba `EMITE_OS`, a fórmula de soma está localizada na célula `M63` (que está fora do viewport visual do total). O campo mesclado que de fato exibe o total para impressão é `N63:P63` (ou N63). Além disso, a sub de limpeza (`LimparOS`, linha 1318 de `Preencher.bas`) escreve explicitamente o valor fixo `0` na célula `N63` se ela não possuir fórmula, estagnando o valor.
* **Impacto:** A Ordem de Serviço pública oficial é impressa com valor final de R$ 0,00.

---

### 3.2 MARGINAIS (2)

#### Achado #04 (Visual / Template) - PRE-OS: Bloco Prestador com Bordas Descontínuas e Cinzas
* **Sintoma:** O bloco Prestador de Serviço no PDF da Pré-OS (`001.pdf`) apresenta bordas cinzas claras e visualmente descontinuadas.
* **Causa-raiz:** No template físico `EMITE_PREOS`, as células `C9` e `C11` estão configuradas com cor de borda superior RGB `FFC0C0C0` (cinza), enquanto o padrão usado em `EMITE_OS` é a cor preta padrão (`indexed 64`).
* **Impacto:** Degradada a harmonia visual e o acabamento premium da Pré-OS.

#### Achado #05 (Visual / Template) - IMP_AVALIA: Faixa Vertical "AVALIACAO" sem Borda Esquerda
* **Sintoma:** O PDF de avaliação impresso carece de linha de fechamento vertical na margem esquerda.
* **Causa-raiz:** No template da aba `IMP_AVALIA`, a faixa mesclada vertical de título "AVALIACAO" (linhas `A25:A45`) não possui borda esquerda ativa definida nas propriedades de célula.
* **Impacto:** Quebra estética marginal no layout final.

---

## 4. Próxima Onda Recomendada e Testes Mínimos

### Proposta: Onda 38.2.23 — Integridade e Alinhamento Visual de Impressão

O escopo desta onda deve focar em resolver os desalinhamentos de células de gravação/fórmulas no código e nos templates físicos, além de criar asserts reais na suíte V2 de impressão.

#### Escopo de Arquivos Permitidos (`scope.files_allowed`)
- `src/vba/Preencher.bas` (correção da célula de escrita de L8 para L9 na avaliação, e ajuste de limpeza em N63).
- `src/vba/Teste_V2_Impressao_Residual.bas` (novo módulo isolado de teste de células físicas).
- `src/vba/App_Release.bas` e espelhos correspondentes em `local-ai/vba_import/`.

Alteração física direta do workbook de referência `PlanilhaCredenciamento-Homologacao-V5.xlsm` **não fica autorizada pelo readback 0143**. A próxima onda deve tentar primeiro helper VBA em `Preencher.bas` para alinhar valores e reaplicar bordas críticas. Se isso não bastar, a IA deve parar e pedir decisão humana explícita antes de tocar o `.xlsm`.

#### Testes Mínimos Necessários
1. **TV2_IMP_AssertCelulasReaisOS:** Simula preenchimento de OS e valida via código:
   `Assert ws.Range("N63").Value = ValorEsperado` (confirmando que a célula do total final tem o valor calculado e possui fórmula).
2. **TV2_IMP_AssertCelulasReaisAvaliacao:** Simula o preenchimento de avaliação e valida:
   `Assert ws.Range("L9").Value <> ""` (confirmando que o demandante foi gravado na célula mesclada visível).
3. **TV2_IMP_AssertBordasInstaladas:** Validar programaticamente a presença de linha e cor correta de borda nas abas de impressão.

---

## 5. Recomendação de Handoff e Novo Chat

Pelo critério de fadiga de contexto (regra de 50% de contexto HBN / knowledge 0014), **não deve ser iniciada nenhuma alteração de código ou modificação de workbook no presente chat**.

1. O relatório atual `0142_TECNICO.md` deve ser commitado no Mac pelo operador.
2. O resultado `0142-exec-*.json` deve ser gerado com o status da auditoria concluído.
3. Um **novo chat** deve ser aberto pelo operador sob o bastão da **Onda 38.2.23**, com foco exclusivo em corrigir os desalinhamentos físicos de gravação e criar a cobertura de testes de células reais descrita na seção 4.

## 6. Adendo Codex de Fechamento

Mauricio confirmou o readback `0142` no chat de 2026-06-03. Como a auditoria
recomenda correcao, foi aberto o readback posterior
`0143-rb-onda-38-2-23-impressao-residual-codeonly-template.json`, em
`safe_track` e com `human_status: pending`.

Este adendo corrige a numeracao operacional: a auditoria atual e a Onda
38.2.22; a implementacao residual de impressao fica proposta como Onda
38.2.23 / readback 0143. Nenhuma implementacao esta autorizada ate novo
hearback humano.

A proxima onda deve tentar primeiro uma abordagem code-only por `Preencher.bas`
e modulo V2 isolado. Edicao direta do workbook/template permanece condicao de
parada: se for indispensavel, a IA deve pedir decisao humana explicita antes de
tocar o `.xlsm`.
