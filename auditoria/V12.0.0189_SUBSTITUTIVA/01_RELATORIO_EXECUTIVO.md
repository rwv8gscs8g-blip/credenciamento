# 01. Relatório Executivo — V12.0.0189 (Substitutiva V166)

**Versão analisada:** `V12.0.0189`
**Branch:** `codex/v180-stable-reset`
**Data:** 2026-04-17
**Papel:** Auditor externo (Claude Opus 4.7), sob supervisão humana (Maurício).
**Escopo:** estado real do código, lacunas UI→Serviço, origem da falha fatal da bateria V2 e plano de estabilização.

---

## 1. Diagnóstico em uma frase

A V12.0.0189 é uma base **estruturalmente saudável** no núcleo de serviços e repositório, mas **ainda não é promovível**, porque:

1. a bateria V2 bloqueia na baseline determinística (`Cenario triplo V2 inconsistente: EMPRESAS=4 | ENTIDADE=4 | CREDENCIADOS=4 | PRE_OS=1 | CAD_OS=1`) antes mesmo de exercitar regras de rodízio/OS;
2. três regras de negócio críticas (`ENT_ID` válido em Pré-OS, `DT_PREV_TERMINO` em OS, justificativa de divergência em Avaliação) continuam implementadas apenas na `Menu_Principal.frm` e não nos `Svc_*`;
3. a central V1 é o único caminho de teste estável hoje e depende de operador humano atento para distinguir falso-positivo de falha real.

A V2 está **tecnicamente correta em intenção**, mas sua contagem de linhas e seu reset de abas são **frágeis a resíduos** em uma planilha que vem de anos de uso.

---

## 2. O que está confirmado (fatos, não inferência)

**Contrato da fila consolidado.** `Repo_Credenciamento.bas` e `Svc_Rodizio.bas` preservam ordem relativa, IDs únicos e `POSICAO_FILA` monotonicamente crescente. Não há (nem deveria haver) renumeração canônica para `1..N`. A V12.0.0189 corrigiu a V2 para deixar de exigir isso (ver `releases/V12.0.0189.md`).

**Serviços dominam o domínio.** `Svc_Rodizio`, `Svc_PreOS`, `Svc_OS` e `Svc_Avaliacao` contêm a lógica central correta, têm testes dedicados (V1 e V2) e usam `IdsIguais` centralizado (`vba_export/Util_Planilha.bas:516`).

**Reset V2 usa heurística frágil.** `TV2_ClearSheet` (`vba_export/Teste_V2_Engine.bas:398`) limpa o intervalo `(primeira, 1) → (ultimaLinha, ultimaColuna)`, mas `ultimaColuna = ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column` é medido **apenas na linha 1**. Se uma linha de dados antiga tiver conteúdo em colunas à direita do último header atual, esse conteúdo **não é limpo**.

**Contagem V2 é aritmética sobre coluna A.** `TV2_CountRows` (`vba_export/Teste_V2_Engine.bas:828`) usa `UltimaLinhaAba(nomeAba) - primeira + 1`, e `UltimaLinhaAba` (`vba_export/Util_Planilha.bas:478`) sempre consulta `End(xlUp)` da **coluna 1**. Qualquer "buraco" ou célula residual na coluna A desloca o resultado.

**Bateria legada (V1) usa contagem semântica.** `Teste_Bateria_Oficial.bas` conta por `CountA` na coluna-chave real de cada aba. Isso é naturalmente imune a resíduos em colunas erradas e a offsets por cabeçalho.

**Release 0189 entregou o prometido.** Alinhou `STR_001` e os checks estruturais ao contrato real da fila; reorganizou a central V2 em automático + assistido; preservou rollback em `backups/rollback-post-v180-2026-04-17/`.

---

## 3. O que a V2 ainda está medindo errado (causa raiz forte, 80% de confiança)

O fatal `EMPRESAS=4 | ENTIDADE=4 | CREDENCIADOS=4` aparece mesmo com a preparação inserindo apenas **3** registros por aba (`vba_export/Teste_V2_Engine.bas:340-355`).

Hipótese consolidada (ver documento 02 para rastreio):

1. Ao entrar em `TV2_PrepararCenarioTriploCanonico`, `TV2_ResetBaseOperacional` chama `TV2_ClearSheet` para `EMPRESAS`, `ENTIDADE`, `CREDENCIADOS`, `PRE_OS`, `CAD_OS`, etc.
2. Em pelo menos uma das abas, a **linha 1** tem menos colunas preenchidas do que as linhas de dados históricas, então `ultimaColuna` calculado em linha 1 não cobre a amplitude real dos dados — **mas** o `Range` começa em coluna 1, e o dano real é que o `ClearContents` reduz o raio lateral sem afetar o índice de linha.
3. A origem mais plausível do "+1" é que, **antes** do `TV2_ClearSheet` ser chamado pela primeira vez, a aba tem pelo menos uma linha fantasma com conteúdo **apenas em coluna à direita** do escopo limpo, e que esse resíduo se manifesta como **uma célula em col A** após o próximo `Util_PrepararAbaParaEscrita` (desproteção que re-avalia ranges com formatação). Essa é a explicação aderente aos três pontos compatíveis (contagem +1 em EMPRESAS/ENTIDADE/CREDENCIADOS e +1 em PRE_OS/CAD_OS que deveriam estar zeradas).
4. Em `TV2_NextDataRow` (`Teste_V2_Engine.bas:441-453`), como `ultima >= primeira`, o cadastro canônico começa em `ultima + 1`, empurrando as 3 empresas para linhas 3, 4, 5 em vez de 2, 3, 4. Resultado: `ultima - primeira + 1 = 5 - 2 + 1 = 4`. Alinhado com o CSV.

Causas alternativas plausíveis (ordem de verificação):

- **Residual genuíno em coluna A** fora do intervalo limpo por `ClearSheet` (ex.: linha posterior a `UltimaLinhaAba` que é pulada porque `End(xlUp)` parou antes).
- **`Util_PrepararAbaParaEscrita` retorna `True` mas com desproteção incompleta** (um `Range` bloqueado invisível), e o `ClearContents` é silenciosamente ignorado pelo Excel.
- **`ListObjects`/tabelas dinâmicas** com linhas excedentes no loop `Do While lo.ListRows.Count > 0 ... lo.ListRows(1).Delete` (`Teste_V2_Engine.bas:413-417`) — o `On Error Resume Next` imediatamente antes engole falhas silenciosamente.

**Todas as três causas convergem para o mesmo remédio** (ver documento 07, ensaios C1 a C5).

---

## 4. Lacunas UI → Serviço (confirmadas no código)

| ID | Regra | Onde vive hoje | Onde deveria viver | Arquivos |
|----|-------|----------------|--------------------|----------|
| MIG_001 | `ENT_ID` existente e ativo em Pré-OS | `Menu_Principal.frm` | `Svc_PreOS.EmitirPreOS` | `vba_export/Svc_PreOS.bas`, `vba_export/Menu_Principal.frm` |
| MIG_002 | `DT_PREV_TERMINO` >= `DT_EMISSAO` em OS | `Menu_Principal.frm` | `Svc_OS.EmitirOS` | `vba_export/Svc_OS.bas`, `vba_export/Menu_Principal.frm` |
| MIG_003 | Justificativa obrigatória quando `QT_EXECUTADA <> QT_ESTIMADA` | `Menu_Principal.frm` | `Svc_Avaliacao.AvaliarOS` | `vba_export/Svc_Avaliacao.bas`, `vba_export/Menu_Principal.frm` |

A V2 **já tem cenários `MIG_*` marcados como `LogManual`**, isto é, aguardando a migração dessas regras para o serviço para então deixarem de ser só informativos e virarem assertivos. Sem a migração, não há como a V2 substituir a V1 com segurança.

---

## 5. Risco Top 5 (priorizado)

1. **Contagem estrutural V2 frágil.** Qualquer resíduo ou formatação em coluna A invalida a baseline. Bloqueia a promoção da V2. Ver documento 02, seção 2.
2. **`IncrementarRecusa` sem atomicidade.** Escreve em `CREDENCIADOS` e `EMPRESAS` sem rollback; se a segunda gravação falhar, o sistema fica em estado divergente. Ver documento 02, seção 4.
3. **Três regras críticas só na UI.** Sem MIG_001/002/003, qualquer integração headless (testes V2, CLI futuro, SaaS) quebra a regra de negócio silenciosamente.
4. **`ProximoId` protege/desprotege por chamada.** Em lotes grandes fica caro e, em falha intermediária, a aba pode permanecer desprotegida.
5. **Módulos de emergência (`Emergencia_CNAE*`, `Importar_Agora`) ainda presentes.** Superfície ampla para ações destrutivas; risco de execução acidental.

---

## 6. Recomendação executiva

Para fechar a V12.0.0189 como versão **promovível**, é necessário, na ordem:

1. **Corrigir a baseline V2** (documento 07, Plano C): trocar `TV2_CountRows` para usar a coluna-chave real de cada aba, via `CountA`, com assertion adicional de que a aba está realmente zerada após `ClearSheet`.
2. **Migrar MIG_001, MIG_002, MIG_003** para os `Svc_*` correspondentes, deixando a UI apenas como consumidora da mensagem de erro do serviço (documento 09, itens B1–B3).
3. **Rodar V1 e V2 em shadow mode** por 3 a 5 sprints para comparar resultados antes de decommissionar V1 (documento 05, seção 4).
4. **Remover módulos de emergência** após confirmação de importador oficial estável (documento 09, item H1).

Com esses quatro pontos, a V2 cobre o pacote mínimo e se torna candidata a substituir a V1 sem perda de cobertura.

---

## 7. Respostas diretas ao briefing

- **A V2 está errando na limpeza ou na medição?** Ambas, e uma alimenta a outra. A limpeza (`TV2_ClearSheet`) tem bordas frágeis; a medição (`TV2_CountRows`) amplifica qualquer bordo não limpo. O remédio estrutural é trocar a medição para semântica por coluna-chave (igual à V1) e endurecer a limpeza com assertion pós-reset.
- **A V1 resolve melhor esse ponto?** Sim, por contagem via `CountA` na coluna-chave. É a razão de a V1 continuar estável mesmo com ruído histórico. Ver documento 05.
- **Quais regras de negócio ainda dependem indevidamente da UI?** MIG_001, MIG_002, MIG_003 (tabela na seção 4).
- **A documentação atual ainda está aderente ao código?** Em grande parte sim. `ESTADO-ATUAL.md` reflete o que está no código; `GOVERNANCA.md` tem trilha coerente até 0189. Ajustes pontuais em V166..V180 listados no documento 04.
- **Quais baterias complementares são necessárias para aprovar uma nova versão estável?** Ver documento 07. Resumo: baseline-fixer (B1), pós-reset-assert (B2), migração-gated (B3), shadow V1×V2 (B4), stress CNAE (B5).
- **O que precisa acontecer para a V2 substituir a V1?** Corrigir B1+B2, migrar MIG_001..003, rodar B4 por 3 a 5 sprints sem divergência, então decommissionar V1.

---

## 8. Documentos de apoio nesta auditoria substitutiva

| # | Arquivo | Responde |
|---|---------|----------|
| 02 | `02_AUDITORIA_TECNICA_DO_CODIGO.md` | rastreio linha-a-linha da falha V2 e dos pontos críticos do core |
| 03 | `03_MATRIZ_REGRAS_DE_NEGOCIO.md` | regras domínio por domínio, com local atual × local correto |
| 04 | `04_AUDITORIA_SEGURANCA_E_INTEGRIDADE.md` | senha padrao exposta, atomicidade, módulos destrutivos |
| 05 | `05_ANALISE_COMPARATIVA_V1_V2.md` | V1 vs V2 em cobertura, precisão e custo humano |
| 06 | `06_ANALISE_COMBINATORIA_E_COBERTURA.md` | matriz de casos cobertos vs lacunas combinatórias |
| 07 | `07_PLANO_BATERIAS_COMPLEMENTARES.md` | baterias B1..B5 detalhadas |
| 08 | `08_AUDITORIA_SUBSTITUTIVA_V166.md` | substitui o relatório de auditoria da V12.0.0166 |
| 09 | `09_BACKLOG_PRIORIZADO.md` | backlog em ordem de execução |
| 10 | `10_PROMPT_CODEX_PROXIMA_FASE.md` | prompt objetivo para o próximo agente |
