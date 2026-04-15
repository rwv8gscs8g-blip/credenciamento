---
titulo: Prompt para Claude Opus 4.6 in Excel
versao: V12.0.0147
data: 2026-04-13
autor: Claude Opus 4.6 (Cowork)
tags: [prompt, opus, excel, relatorios, testes]
---

# Prompt para Claude Opus 4.6 in Excel

> Cole este prompt inteiro no Claude in Excel ao abrir a planilha PlanilhaCredenciamento-Homologacao.xlsm.
> Ele orienta a IA a corrigir e melhorar relatorios, formularios e testes.

---

## CONTEXTO DO SISTEMA

Voce esta trabalhando em uma planilha Excel (.xlsm) de **Sistema de Credenciamento Municipal** com rodizio de empresas prestadoras de servico. O sistema usa VBA com formularios modais (UserForms), abas de dados protegidas e abas de impressao de relatorios.

**Versao atual**: V12.0.0147
**Modulos VBA**: 28 .bas + 13 .frm
**Abas de dados**: ATIVIDADES, CAD_SERV, EMPRESAS, ENTIDADES, CREDENCIADOS, CAD_PREOS, CAD_OS, CAD_AVALIACAO, AUDITORIA
**Abas de impressao/relatorio**: EMITE_PREOS, EMITE_OS, IMP_AVALIA, RPT_BATERIA, RPT_ROTEIRO, RPT_CK136, RPT_CONSOLIDADO, RESULTADO_QA, CHECKLIST_136, ROTEIRO_RAPIDO, HISTORICO_TESTES
**Abas de relatorio de dados**: Rel_Emp_Serv, Rel_OSEmpresa (e possivelmente outras Rel_*)

## REGRAS INVIOLAVEIS

1. **NUNCA** usar colon patterns: `Dim x As Long: x = 4` (corrompe VBA)
2. **NUNCA** usar `MkDir`, `Kill`, `Dir()` nativos (usar FSO late-binding)
3. **NUNCA** modificar `Mod_Types.bas` (Public Types)
4. **NUNCA** renomear modulos (Attribute VB_Name)
5. **NUNCA** usar `Chr()` com valores > 255 — usar `ChrW()` para Unicode
6. **NUNCA** usar `.Select`, `.Activate`, `ActiveCell`, `ActiveSheet` (formularios modais)
7. **SEMPRE** usar `Util_PrepararAbaParaEscrita` / `Util_RestaurarProtecaoAba` para desproteger/reproteger
8. **SEMPRE** usar `ChrW$()` para acentos em VBA: ChrW$(231)=c, ChrW$(227)=a, ChrW$(233)=e, ChrW$(225)=a, ChrW$(243)=o, ChrW$(250)=u, ChrW$(211)=O, ChrW$(199)=C, ChrW$(195)=A
9. Senhas de protecao: "", "sebrae2024", "SEBRAE2024"

## TAREFA 1: MELHORAR RELATORIOS DE IMPRESSAO

### 1.1 Aba EMITE_PREOS (Pre Solicitacao de Servico)
**Problemas identificados:**
- O texto "PROVISORIA" aparece correto agora (corrigido ChrW$(211)), mas verifique se todos os textos com acentos estao usando ChrW$()
- Layout e legibilidade: verificar se bordas, fontes e espacamentos estao profissionais
- Campos vazios (Endereco, Telefone, e-mail) devem ter linhas/bordas visiveis mesmo vazios

### 1.2 Aba EMITE_OS (Solicitacao de Servico - 2 paginas)
**Problemas identificados:**
- Pagina 2 (FECHAMENTO): campo "Nota Total" esta VAZIO — a media nao e calculada/exibida
- Empenho aparece incompleto ("EMP-20260413-") sem numero final
- Verificar se todas as celulas de notas (N27:N36) e a media (N37) estao formatadas
- A segunda assinatura diz "ASSINATURA DO DEMANDANTE" duas vezes — deveria ser "ASSINATURA DO PRESTADOR DE SERVICOS" na segunda

### 1.3 Aba IMP_AVALIA (Avaliacao de Servico)
**Problemas identificados:**
- Campo "Nota Total" ao lado de "N. do Empenho" esta VAZIO — a funcao PreencherAvaliacaoOS em Preencher.bas usa `media` que agora recebe valor de `mediaLocal`
- Verificar se `ws.Range("N37").Value = Format(media, "##,#")` funciona corretamente
- O formato "##,#" pode nao exibir valores como 6.6 corretamente — considerar "#0.0" ou "0.0"

### 1.4 Abas Rel_Emp_Serv e Rel_OSEmpresa (Relatorios tabulares)
**Problemas identificados nos PDFs:**

**Relatorio de Empresas Cadastradas:**
- Dados aparecem em barras azuis escuras com texto dificil de ler (contraste ruim)
- Colunas alem de CNPJ e Nome ficam vazias mas ocupam espaco
- Falta cabecalho de colunas visivel
- Falta titulo com data/versao

**Relatorio de Entidades Cadastradas:**
- Cabecalho existe mas dados (Local 1, 2, 3) nao mostram CNPJ, Razao Social etc
- Formatacao muito espacada, colunas desproporcionais
- Cores de fundo inconsistentes entre linhas

**Relatorio de Empresas Credenciadas:**
- Melhor formatado, mas colunas "ULTIMA OS" e "DATA ULT. OS" estao vazias
- Posicao Fila mostra valores altos (5, 7) — verificar se e esperado
- Layout legivel mas poderia ter alternancia de cores nas linhas

**Relatorio de OS Abertas:**
- Linha fantasma: linha 0 com "SERVICO" e R$ 0,00 (lixo — nao deveria aparecer)
- Verificar filtro que exclui linhas vazias/invalidas

### Acoes para cada relatorio:
1. Corrigir formatacao de cores (usar branco/cinza claro alternado, texto preto)
2. Ajustar larguras de coluna proporcionalmente ao conteudo
3. Adicionar cabecalho com titulo, data, versao
4. Corrigir acentuacao usando ChrW$()
5. Excluir linhas com dados vazios/invalidos
6. Formatar valores monetarios como "R$ #.##0,00"

## TAREFA 2: MELHORAR FORMULARIOS (USERFORMS)

### Verificacoes gerais nos formularios:
1. Todos os textos com acentos devem usar ChrW$() — nunca Chr() com valores > 127
2. Labels descritivos devem ter fonte legivel (minimo 9pt)
3. ListBoxes devem ter ColumnWidths proporcionais ao conteudo
4. Botoes devem ter tooltips (ControlTipText) descritivos
5. Cores de fundo consistentes entre formularios

### Formularios prioritarios:
- **Menu_Principal.frm**: formulario principal (~4100 linhas) — focar em legibilidade
- **Cadastro_Servico.frm**: cadastro de servicos
- **Credencia_Empresa.frm**: credenciamento

## TAREFA 3: MELHORAR E CONSOLIDAR TESTES

### Estado atual dos testes:
- **Teste_Bateria_Oficial.bas**: 99 funcoes, ~200 testes em 5 blocos (0-5)
- **Teste_UI_Guiado.bas**: 2 funcoes (teste manual assistido)
- **Central_Testes.bas**: 15 funcoes (UI da central)
- **Central_Testes_Relatorio.bas**: 13 funcoes (geracao de relatorios)

### O que melhorar:

**3.1 Visualizacao lenta (modo visual):**
- O modo lento atual usa `gDelayVisualMs = 450` com DoEvents
- MELHORAR: aumentar delay para 1500-2000ms no modo visual
- ADICIONAR: uma aba "TESTE_LIVE" ou usar RESULTADO_QA em tempo real mostrando:
  - Linha 1-3: Cabecalho fixo com contadores (OK/FALHA/TOTAL)
  - Linha 4: Teste atual em execucao (nome + descricao)
  - Linhas 5+: Historico dos ultimos N testes executados
  - Atualizar via `ws.Cells().Value = ...` + `DoEvents` a cada teste
  - Scroll automatico para manter o teste atual visivel

**3.2 Interface visivel durante execucao:**
- Usar a aba RESULTADO_QA como dashboard ao vivo
- Adicionar `Application.Goto ws.Cells(linhaAtual, 1)` para scroll
- Formatar linha atual com cor destaque (amarelo) que avanca
- Manter contadores no topo da aba (merged cells, fonte grande)

**3.3 Resultado visual no Excel e CSV:**
- Formatar RESULTADO_QA apos execucao: cores OK=verde, FALHA=vermelho, MANUAL=amarelo
- CSV deve incluir cabecalho, data/hora, versao, resumo no topo
- Encoding do CSV deve ser UTF-8 BOM para acentos

**3.4 Consolidacao em teste unico:**
- Manter RunBateriaOficial como ponto de entrada unico
- Incorporar os testes de Teste_UI_Guiado como subconjunto (bloco 6)
- Incorporar validacoes do CHECKLIST_136 como bloco 7
- Manter a numeracao sequencial existente (BO_xxx)

## TAREFA 4: CORRECOES JA APLICADAS (VERIFICAR)

Estas correcoes ja foram feitas no codigo fonte (vba_export/). Verifique se estao funcionando na planilha:

1. **Svc_Avaliacao.bas**: Adicionado `AvancarFila(os.EMP_ID, os.ATIV_ID, False, "AVALIACAO_CONCLUIDA")` apos avaliar OS — corrige bug onde empresas nao voltavam a fila apos ciclo completo de rodizio
2. **Menu_Principal.frm**: Adicionado `media = mediaLocal` antes de `AV_Total.Value = mediaLocal` — corrige Nota Total vazia no relatorio de avaliacao
3. **Menu_Principal.frm**: Corrigido `Chr(211)` para `ChrW(211)` em "PROVISORIA" — corrige mojibake
4. **Central_Testes_Relatorio.bas**: Corrigido todos `Chr(8212)` para `ChrW(8212)` — corrige Erro 5 na geracao do relatorio da bateria

## FORMATO DE ENTREGA

Ao concluir cada tarefa:
1. Liste as alteracoes feitas (modulo, funcao, linha)
2. Compile (Debug > Compilar VBAProject) — ZERO erros
3. Execute a Bateria de Testes via Central de Testes
4. Gere todos os relatorios para verificar formatacao
5. Incremente a versao em App_Release.bas se necessario
