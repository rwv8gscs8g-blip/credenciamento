---
titulo: Diagnostico Imediato do Bug do Rodizio (modulo descartavel)
natureza-do-documento: instrucoes para importar e rodar o modulo Diag_Imediato
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
data: 2026-04-28
autor: Claude Opus 4.7 (sessao Cowork)
---

# 36. Diagnostico Imediato do Bug do Rodizio

## 00. Objetivo

Coletar dados reais sobre o estado de `CREDENCIADOS`, `EMPRESAS`,
`PRE_OS` e `CAD_OS` no momento em que aparece o erro "todas as
empresas aptas desta atividade estao com Pre-OS pendente de aceite",
para confirmar se e bug real ou estado contaminado.

## 01. Onde esta o arquivo

**Arquivo importavel:** `local-ai/vba_import/Diag_Imediato.bas`

Este e um modulo VBA standalone, autocontido, sem dependencia de
nenhum outro codigo da V203. Pode ser importado e removido a qualquer
momento sem afetar o resto do sistema.

> Regra do projeto: **todos os arquivos importaveis ficam em
> `local-ai/vba_import/`**, na raiz dessa pasta para modulos
> avulsos (como este e o `Importador_VBA.bas`) ou em `001-modulo/`
> para o pacote ordenado completo.

## 02. Procedimento

### 02.1 Reproduzir o erro

1. No Excel, reproduza o erro "todas as empresas aptas desta
   atividade estao com Pre-OS pendente de aceite".
2. Quando aparecer a MsgBox, clique OK para fechar.
3. **NAO feche o workbook**, **NAO salve**.

### 02.2 Importar e rodar Diag_Imediato

1. `Alt+F11` para abrir o VBE.
2. `File > Import File...` -> selecionar
   `local-ai/vba_import/Diag_Imediato.bas`.
3. No Project Explorer (`Ctrl+R`), confirmar que apareceu o modulo
   `Diag_Imediato`.
4. Duplo-clique em `Diag_Imediato` para abrir o codigo.
5. Cursor dentro da Sub `Diag_Imediato_Rodizio` e `F5`.
6. Quando o InputBox aparecer, informar o `ATIV_ID` da atividade
   onde o erro acontece (ex.: `001`).
7. Aguardar o MsgBox de conclusao.
8. Voltar para o Excel: vai existir aba `RPT_DIAG_IMEDIATO`.

### 02.3 Enviar o resultado

1. Abrir aba `RPT_DIAG_IMEDIATO`.
2. `Ctrl+A` ou selecionar todo o conteudo.
3. `Ctrl+C`.
4. Colar na resposta do chat (vai virar tabela formatada).

### 02.4 Limpeza

Apos enviar o resultado:

1. VBE > Project Explorer > clique direito em `Diag_Imediato` >
   **Remove Diag_Imediato** > **No** ao "exportar?".
2. O modulo descartavel some do projeto.
3. A aba `RPT_DIAG_IMEDIATO` pode ficar (apenas referencia) ou ser
   apagada manualmente.

## 03. O que vou ler nos 5 blocos do RPT_DIAG_IMEDIATO

| Bloco | Aba consultada | O que diagnostica |
|---|---|---|
| 1 | `CREDENCIADOS` | quantas empresas estao credenciadas na atividade, suas posicoes e `STATUS_CRED` |
| 2 | `EMPRESAS` | `STATUS_GLOBAL` e `DT_FIM_SUSP` de cada empresa |
| 3 | `PRE_OS` | TODAS as Pre-OS na atividade, com STATUS — **aqui aparece se ha Pre-OS duplicada ou perdida** |
| 4 | `CAD_OS` | OS em `EM_EXECUCAO` na atividade |
| 5 | simulacao | a decisao que cada um dos 5 filtros (A..E) tomaria para cada empresa, indicando exatamente qual filtro pega cada uma |

A pista critica esta no **Bloco 3**: se aparecerem **3 ou mais Pre-OS
em `AGUARDANDO_ACEITE` para a mesma atividade depois de 2 emissoes
manuais**, e bug real (sistema duplicou). Se aparecerem so 2 (ou
menos), e outra coisa que o Bloco 5 vai mostrar.

## 04. Apos o diagnostico

Com os dados reais, eu:

1. Confirmo se e bug real ou nao.
2. Se for bug, abro **Onda 5** corrigindo o ponto exato (provavelmente
   em `Svc_PreOS.EmitirPreOS` ou no caminho que move/nao-move a
   empresa apos emissao da Pre-OS).
3. Se nao for bug, documento o caminho determinístico para limpar e
   testar manualmente.

Em qualquer caso, a Onda 5 ja vai entregar:

- `Configuracao_Inicial.frm` SEM heuristica, com nomes canonicos
  ja confirmados pelo Mauricio em 28/04 (`TxtMaxStrikes`,
  `TxtNotaCorte`, `TxtDiasSuspensao`);
- helper `TV2_LimparBaseAposSuite()` chamado por
  `TV2_FinalizarExecucao` — toda suite agora deixa a base limpa
  ao terminar;
- cenario automatizado `RDZ_001` reproduzindo o caso de 3 empresas +
  3 rodizios sucessivos, esperando 3 Pre-OS distintas para 3 empresas
  distintas, sem erro na 3a tentativa.

## 05. Por que esse modulo e seguro

- Standalone: nao depende de nenhum outro modulo da V203;
- Read-only: apenas LE dados de `CREDENCIADOS`, `EMPRESAS`,
  `PRE_OS` e `CAD_OS`. Nao escreve nessas abas;
- Aba `RPT_DIAG_IMEDIATO` e isolada: pode ser apagada a qualquer
  momento sem afetar nada;
- Nao toca em `Mod_Types.bas`, nao toca em `Audit_Log.bas`, nao
  toca em formularios, nao toca em `App_Release.bas`;
- Pode ser importado e removido a qualquer momento — modulo
  descartavel por design.
