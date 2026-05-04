---
titulo: 05 - Plano Executivo Onda 16 (refatoração testes + filtros padronizados + UI clicada + PDFs auditáveis com CNPJ)
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
prioridade: alta
versao-sistema: V12.0.0203-rc1 (alvo: rc2 ou V12.0.0204-base)
data: 2026-05-02
autor: Claude Opus 4.7 (Frente 1 Credenciamento) — síntese sobre proposta Antigravity v4
licenca-target: TPGL-v1.1 (Credenciamento)
status: aguardando aprovação operador
---

# Onda 16 — Plano Executivo (Frente 1 sobre proposta Antigravity v4)

> Este documento é o plano executivo da Onda 16. Substitui os
> superprompts v1-v4 e a resposta Antigravity v4 enquanto base de
> implementação. Após aprovação do operador, vira `readback`
> formal `0012-onda16-testes-refatoracao.json` e Frente 1
> implementa em iteração longa única + microdeltas colaborativos
> (filtros tela-a-tela).

## 0. Avaliação da resposta Antigravity v4

### 5 acertos a preservar

1. **Estrutura canônica entregue** — 10 seções + 3 apêndices conforme solicitado.
2. **Diagnóstico correto do padrão `Altera_Entidade.frm` como modelo limpo** vs `Altera_Empresa.frm` com dívida heurística residual. Convenção observada: handlers `<NomeControle>_Click()` direto.
3. **DAG Mermaid** dos 9 microdeltas (16.1 → 16.9) coerente.
4. **Reconhecimento explícito de constraints C1-C10** no §2 da resposta.
5. **Arquitetura sólida do `Util_PDF`**: hash isolado de timestamp em metadata interno + nomeação humano-legível + sufixo `_NN` em colisão.

### 4 pontos fracos a refinar pela Frente 1

1. **7 documentos `🟠 SOURCE NOT REACHED`** (mesmo problema da v1):
   - `70_FECHAMENTO_ONDA_11.md`
   - `DRIFT_G7_RESIDUAL_PRE_ONDA12.md`
   - `0011-exec-onda11.json`
   - `36_SPEC_DT6`
   - `27_ROADMAP`
   - `00_PRORROGACAO.md` (CNAE)

   A Frente 1 já tem leitura desses arquivos no contexto desta sessão — incorporo o que falta na §3 abaixo.

2. **Apêndice A preliminar e incompleto** — só 5 forms listados. Inventário completo dos 13 forms precisa ser feito empiricamente.

3. **Pseudocódigo dos helpers `TUI_*` ausente** — Antigravity citou nomes mas não desenhou contrato.

4. **Q1-QN para hearback do operador foram esquecidas** — refaço aqui as decisões em aberto.

### Veredito

A v4 é **direcionalmente correta e útil como base**, mas **tatícamente incompleta**. Frente 1 incorpora a v4 e refina/completa. Plano executivo abaixo é o que efetivamente vamos implementar.

## 1. Estado pré-Onda 16 (ponto de partida)

| Campo | Valor |
|---|---|
| Versão atual | V12.0.0203-rc1 (publicada GitHub 2026-05-02) |
| Build label | `f7aa84f+v12.0.0203-rc1` |
| Workbook ancora | `V12-202-AB-onda11-rc1` |
| Gate oficial | `CT_ValidarRelease_QuartetoMinimo` (V1+V2_Smoke+V2_Canonica+E2E_Strikes) |
| Última validação | `VR_20260502_063028` = APROVADO (171/0+14/0+20/0+64/0) |
| Drift G7 residual | 23 arquivos divergentes (D1) preservados intencionalmente para Ondas 12-16 caso-a-caso |

## 2. Escopo da Onda 16 (5 áreas + 1 colaborativa)

### Área A — Texto da Central V12 + Central V2

Mensagens reorganizadas com Quarteto destacado como gate oficial. Sem novo form. Apenas texto do `InputBox`.

### Área B — Coluna `DURACAO_MS` em `RESULTADO_QA_V2`

Nova coluna populada via `Timer * 1000` no `TV2_FinalizarExecucao`. Threshold em `CONFIG`.

### Área C — Aba `EVOLUCAO_TESTES`

Sheet nova com sparkline + indicador de regressão. Acessível por opção `[21]` na Central V2.

### Área D — `Util_PDF.bas` (com CNPJ no nome — refinamento desta sessão)

Geração automática de PDFs com nome humano-legível incluindo CNPJ da empresa. Hash determinístico em metadata interno.

### Área E — Cobertura UI completa (V1+V2 + handlers de forms operacionais)

2 suites novas: `TV2_RunUiCentralV2` (dispatcher) + `TV2_RunUiCobertura` (handlers `*_Click()` de cada form).

### Área F — Padronização cirúrgica de filtros (colaborativa)

Estender padrão `Altera_Entidade.frm` (handlers diretos) aos demais forms com filtro. Limpar heurística residual em `Altera_Empresa.frm`. Tela-a-tela com prints do operador.

## 3. Convenções canônicas (aprovadas pelo operador via Q1-Q5)

### 3.1 Filtros — extensão do padrão Empresa↔Entidade

**Modelo canônico:** `Altera_Entidade.frm` (handlers diretos sem heurística).

**Convenção de nomes** (já em uso parcial — extensão decidida):

| Tipo de controle | Prefixo | Exemplo (Entidade) | Exemplo (Empresa moderno) |
|---|---|---|---|
| Botão "Alterar" | `B_` | `B_Altera_Entidade` | (manter `M_Alterar` se já existe) |
| Botão "Cancelar/Inativar" | `C_` | `C_Inativa_Entidade` | (manter como está) |
| Textbox de campo | `M_` | (a aplicar) | `M_Empresa` |
| Botão modernizado WithEvents | `mBtn` | (não usar — já tem B_/C_) | `mBtnInativarEmpresa` |
| **Combobox de filtro** | `cmb_filtro_` | `cmb_filtro_entidade` | `cmb_filtro_empresa` |
| **Textbox de busca** | `txt_busca_` | `txt_busca_entidade` | `txt_busca_empresa` |
| **Listbox de resultados** | `lst_` | `lst_resultados_entidade` | `lst_resultados_empresa` |
| **Botão "Aplicar filtro"** | `B_filtrar_` | `B_filtrar_entidade` | `B_filtrar_empresa` |
| **Botão "Limpar filtro"** | `C_filtrar_` | `C_filtrar_entidade` | `C_filtrar_empresa` |

**Regras:**
- Nomes existentes (`B_<Acao>`, `C_<Acao>`, `M_<Campo>`, `mBtn<Func>`) **continuam onde já estão** (zero churn). Convivência permitida.
- Novos controles de filtro adotam prefixos `cmb_filtro_`, `txt_busca_`, `lst_`, `B_filtrar_`, `C_filtrar_` (extensão coerente com B_/C_/M_).
- Handlers sempre `<NomeControle>_Click()` direto. **Sem `For Each ctl In container.Controls`. Sem `InStr(.Caption)`. Sem `Controls(varname)`. Sem `.Top`/`.Left` para tomada de decisão.**

### 3.2 Nomeação canônica de PDFs (com CNPJ — novo refinamento)

**Padrão:** `<TIPO>_<ENTIDADE_ID>_<CNPJ>_<DATA>[_NN].pdf`

| Tipo | Padrão | Exemplo |
|---|---|---|
| PRE_OS | `PREOS_<PREOS_ID>_<CNPJ>_<DATA>.pdf` | `PREOS_PRE-2025-001_12345678000199_2026-05-02.pdf` |
| OS | `OS_<OS_ID>_<CNPJ>_<DATA>.pdf` | `OS_2025-001_12345678000199_2026-05-02.pdf` |
| Avaliação | `AVAL_<OS_ID>_<CNPJ>_<DATA>.pdf` | `AVAL_2025-001_12345678000199_2026-05-02.pdf` |
| Ciclo (1 por empresa) | `CICLO_<EMP_CNPJ>_<EXEC_ID>_<DATA>.pdf` | `CICLO_12345678000199_TV2_20260502_063028_2026-05-02.pdf` |
| Ciclo resumo geral (todas empresas) | `CICLO_RESUMO_<EXEC_ID>_<DATA>.pdf` | `CICLO_RESUMO_TV2_20260502_063028_2026-05-02.pdf` |

**Regras de formação:**
- **CNPJ limpo**: só dígitos, sem `.`, `/`, `-`. Ex.: `12345678000199`. Helper: `Util_NormalizarDocumentoChave(cnpj)` já existente em `AAE-Util_Planilha.bas`.
- **Data**: formato `YYYY-MM-DD` (ordenável).
- **Sufixo `_NN`**: aplicado apenas se houver colisão no mesmo dia para o mesmo arquivo. Ex.: `OS_2025-001_12345678000199_2026-05-02_02.pdf`.
- **Hash não vai no nome** — hash do payload determinístico vai em metadata interno do PDF (rodapé) + sheet `RPT_PDFS_GERADOS`.
- **Diretório**: `auditoria/04_evidencias/V12.0.0203/pdfs/<EXECUCAO_ID>/`.

**Fonte do CNPJ:**
- Para PRE_OS, OS, Avaliação: lookup via `EMP_ID` na sheet `EMPRESAS` coluna `COL_EMP_CNPJ` (=2).
- Helper novo (Onda 16): `Util_Empresa_GetCnpjPorId(empId As String) As String` — retorna CNPJ normalizado ou `""` se não encontrado.

### 3.3 Threshold de teste lento

`THRESHOLD_TESTE_LENTO_MS = 500` (Long, ms) — gravado em `CONFIG` na sheet (parametrizável pelo operador via UI).

### 3.4 Schema da sheet `RPT_PDFS_GERADOS`

| Coluna | Nome | Tipo | Descrição |
|---|---|---|---|
| A | EXECUCAO_ID | String | ID da suite que gerou |
| B | TIPO | String | PREOS / OS / AVAL / CICLO / CICLO_RESUMO |
| C | ENTIDADE_ID | String | PRE_OS_ID / OS_ID conforme tipo |
| D | EMP_CNPJ | String | CNPJ normalizado |
| E | CAMINHO | String | Path absoluto |
| F | NOME_ARQUIVO | String | Nome só do arquivo |
| G | HASH_PAYLOAD | String | SHA-1 do payload determinístico |
| H | TAMANHO_BYTES | Long | Tamanho do PDF |
| I | DATA_GERACAO | Date | Timestamp |
| J | OBS | String | Notas opcionais |

### 3.5 Schema da sheet `EVOLUCAO_TESTES`

| Coluna | Nome | Tipo | Descrição |
|---|---|---|---|
| A | EXECUCAO_ID | String | |
| B | SUITE | String | TV2_RunSmoke / TV2_RunCanonicoFundacao / etc. |
| C | DT_EXEC | Date | |
| D | DURACAO_MS | Long | |
| E | OK | Long | |
| F | FALHA | Long | |
| G | MEDIA_5_MS | Long | Média das últimas 5 execuções |
| H | DELTA_PCT | Double | Variação % vs MEDIA_5_MS |
| I | REGRESSAO? | Boolean | TRUE se DURACAO_MS > MEDIA_5_MS * 1.5 |
| J | SPARKLINE | (gráfico embutido) | |

## 4. Microdeltas detalhados

### MD-16.1 — Texto da Central V12 + Central V2

| Campo | Valor |
|---|---|
| Build label | `f7aa84f+ONDA16.MD1-central-textos-incremental` |
| Manifesto | `MICRO13` |
| Arquivos | `AAZ-Central_Testes.bas`, `ABE-Central_Testes_V2.bas` (+ espelhos src/vba) |
| Gate | Quarteto verde + visual OK |
| Esforço | 1h IA + 0.3h Op |
| Colaborativo | Não |

**Mudanças:**

1. `AAZ-Central_Testes.bas` — substituir texto do `InputBox` em `CT_AbrirCentral`:
   - Cabeçalho com build atual via `AppRelease_BuildImportado()`
   - Adicionar `[3] Quarteto Direto` que chama `CT_ValidarRelease_QuartetoMinimo`
   - Reorganizar com seção "🎯 GATES DE RELEASE"
2. `ABE-Central_Testes_V2.bas` — substituir texto do `InputBox` em `CT2_AbrirCentral`:
   - Cabeçalho com build atual + ID do test_key (`quarteto-2026-05-02`)
   - Reorganização hierárquica em 4 seções: gates / suites / visualização / utilitários
   - Quarteto `[20]` com marcador `★★★ OFICIAL`
   - Comentário-vacina sobre `[15]-[19]` (drift D1 — só src/vba)

**Pre-flight L14:** assinaturas dos handlers existentes preservadas. Sem novo `Public Sub`. Sem `Public Type`. C4 OK (não toca `Mod_Types`).

**Plano de rollback:** `git checkout local-ai/vba_import/001-modulo/AAZ-Central_Testes.bas src/vba/Central_Testes.bas ABE-Central_Testes_V2.bas src/vba/Central_Testes_V2.bas` + restaurar workbook V12-202-AB-onda11-rc1.

### MD-16.2 — Coluna `DURACAO_MS` + threshold

| Campo | Valor |
|---|---|
| Build label | `f7aa84f+ONDA16.MD2-duracao-ms-incremental` |
| Manifesto | `MICRO14` |
| Arquivos | `ABF-Teste_V2_Engine.bas` (TV2_FinalizarExecucao + helpers de gravação) + `AAD-Util_Config.bas` (getter `GetThresholdTesteLentoMS`) |
| Gate | Quarteto verde + coluna nova visível em `RESULTADO_QA_V2` |
| Esforço | 1h IA + 0.3h Op |
| Colaborativo | Não |

**Mudanças:**

1. `Util_Config.bas` — novo getter `Public Function GetThresholdTesteLentoMS() As Long` (lê `CONFIG.<linha_threshold>`, fallback 500).
2. `Teste_V2_Engine.bas`:
   - Em `TV2_IniciarExecucao`: guardar `Module_TimerInicio = Timer`.
   - Em `TV2_FinalizarExecucao`: calcular `duracaoMs = (Timer - Module_TimerInicio) * 1000` e gravar em coluna nova.
3. `RESULTADO_QA_V2`:
   - Adicionar header `DURACAO_MS` em coluna seguinte às atuais.
   - Cor condicional: verde < threshold/2, amarelo < threshold, vermelho >= threshold.

**Pre-flight L14:** confirmar que `TV2_IniciarExecucao` e `TV2_FinalizarExecucao` são as únicas portas de entrada/saída de execução V2. Confirmar coluna seguinte em `RESULTADO_QA_V2` está livre.

### MD-16.3 — Aba `EVOLUCAO_TESTES` + sparkline + opção `[21]`

| Campo | Valor |
|---|---|
| Build label | `f7aa84f+ONDA16.MD3-evolucao-testes-incremental` |
| Manifesto | `MICRO15` |
| Arquivos | `ABF-Teste_V2_Engine.bas` (hook adicional), `ABE-Central_Testes_V2.bas` (opção [21]), módulo novo `ABL-Util_Evolucao.bas` |
| Gate | Quarteto verde + sparkline visível + regressão detectada em cenário de teste |
| Esforço | 1.5h IA + 0.5h Op |
| Colaborativo | Não |

**Mudanças:**

1. Módulo novo `ABL-Util_Evolucao.bas`:
   - `Util_Evolucao_RegistrarExecucao(execucaoId, suite, duracaoMs, ok, falha)` — append em `EVOLUCAO_TESTES`.
   - `Util_Evolucao_CalcularMedia5(suite) As Long` — média móvel.
   - `Util_Evolucao_AbrirEMostrar()` — chama por opção `[21]`.
   - `Util_Evolucao_CriarSparkline(rangeOrigem, rangeDestino)` — usa `SparklineGroups.Add` (verificar Mac).
2. `Teste_V2_Engine.bas` em `TV2_FinalizarExecucao`: chamar `Util_Evolucao_RegistrarExecucao` após gravar em `RESULTADO_QA_V2`.
3. `Central_Testes_V2.bas`: adicionar `Case "21"` → `Util_Evolucao_AbrirEMostrar`.

**Pre-flight L14:** verificar API `SparklineGroups.Add` em Excel for Mac (testes em casos anteriores indicam que existe mas com limitações).

**Risco:** sparkline Mac pode falhar — mitigação: fallback para gráfico simples de linha se Sparkline indisponível.

### MD-16.4 — `Util_PDF.bas` (com CNPJ no nome)

| Campo | Valor |
|---|---|
| Build label | `f7aa84f+ONDA16.MD4-util-pdf-cnpj-incremental` |
| Manifesto | `MICRO16` |
| Arquivos | Módulo novo `ABM-Util_PDF.bas`, módulo novo `AAW-Util_Empresa.bas` (helper CNPJ), `ABG-Teste_V2_Roteiros.bas` (suite nova `TV2_RunPdfDeterminismo`), `ABE-Central_Testes_V2.bas` (opção [22]), espelhos src/vba |
| Gate | Quarteto verde + suite `TV2_RunPdfDeterminismo` passa 5/0 + PDFs gerados em `auditoria/04_evidencias/V12.0.0203/pdfs/<EXEC_ID>/` |
| Esforço | 2.5h IA + 0.5h Op |
| Colaborativo | Não |

**Mudanças:**

1. Módulo novo `Util_Empresa.bas`:
   - `Public Function Util_Empresa_GetCnpjPorId(empId As String) As String` — lookup em `EMPRESAS!B`.
   - Reusa `Util_NormalizarDocumentoChave` para limpar dígitos.
2. Módulo novo `Util_PDF.bas`:
   - `Public Function Util_PDF_GerarPdfPreOS(preosId, execucaoId) As String` (retorna caminho).
   - `Public Function Util_PDF_GerarPdfOS(osId, execucaoId) As String`.
   - `Public Function Util_PDF_GerarPdfAvaliacao(osId, execucaoId) As String`.
   - `Public Function Util_PDF_GerarPdfCicloPorEmpresa(execucaoId, empId) As String`.
   - `Public Function Util_PDF_GerarPdfCicloResumo(execucaoId) As String`.
   - `Public Function Util_PDF_HashPayloadDeterministico(caminho) As String`.
   - `Public Sub Util_PDF_RegistrarEmRpt(caminho, tipo, entidadeId, cnpj, hashPayload, tamanho)`.
   - Implementação: gera PDF via `ExportAsFixedFormat Type:=xlTypePDF` em planilha temporária `TEMP_PDF_GEN`.
   - Header: build label, exec_id, timestamp RFC 3339.
   - Footer: `HASH_PAYLOAD: <sha1>` + `RESUMO: TIPO=X EMP=cnpj ENT=id`.
3. `Teste_V2_Roteiros.bas` — suite nova:
   - `Public Sub TV2_RunPdfDeterminismo(Optional silencioso As Boolean = False)` — orquestra 5 cenários.
   - `CT_PDF_001` — gera baseline conhecido, hash payload = X.
   - `CT_PDF_002` — gera novo cenário idêntico, hash deve = X.
   - `CT_PDF_003` — muda 1 strike, hash deve diferir.
   - `CT_PDF_004` — nome arquivo segue regex `^(PREOS|OS|AVAL|CICLO|CICLO_RESUMO)_[^_]+_\d{14}_\d{4}-\d{2}-\d{2}(_\d{2})?\.pdf$`.
   - `CT_PDF_005` — idempotência: gerar 2x mesma OS no mesmo dia → arquivos com sufixo `_01`, `_02`.
4. `Central_Testes_V2.bas`: opção `[22] PDFs gerados (auditoria/04_evidencias/V12.0.0203/pdfs/)` → `Util_PDF_AbrirPasta`.
5. Hooks opcionais (decidir Q4):
   - `Svc_Avaliacao.AvaliarOS` — gerar PDF da avaliação após cada nota lançada.
   - `TV2_RunRodizioStrikesEndToEnd` — gerar PDFs ao final do ciclo.

**Sheet `RPT_PDFS_GERADOS`:** criada automaticamente em primeira chamada via helper `Util_PDF_AssegurarSheetRpt()`.

**Pre-flight L14:**
- `ExportAsFixedFormat` disponível em Excel for Mac — confirmado por testes anteriores.
- `EMPRESAS!B` (= `COL_EMP_CNPJ`) já está populado nos cenários de teste.
- Helper `Util_NormalizarDocumentoChave` em `Util_Planilha.bas` já existe (não duplicar).

**Risco:** geração de PDF lenta em macOS (>5s/arquivo) — mitigação: gerar só ao final do ciclo, não por OS individual; opcional via flag.

### MD-16.5 — Filtros Fase 1: inventário + padrão consolidado

| Campo | Valor |
|---|---|
| Build label | (sem bump — file-only) |
| Manifesto | n/a (entrega documental) |
| Arquivos | `auditoria/03_ondas/onda_16_testes_refatoracao/06_INVENTARIO_FILTROS.md` |
| Gate | Tabela canônica entregue + operador valida convenção |
| Esforço | 1h IA + 0.3h Op |
| Colaborativo | Sim (operador valida tabela) |

**Mudanças:**

1. Inventário empírico dos 13 forms + análise por form:
   - Tem filtro? (combobox/textbox/listbox de busca)
   - Convenção atual?
   - Heurística residual presente?
   - Ajuste necessário?
2. Convenção consolidada (já documentada em §3.1 deste plano).
3. Ordem de revisão MD-16.6 (do mais simples ao mais complexo).

### MD-16.6 — Filtros Fase 2: revisão tela-a-tela colaborativa

| Campo | Valor |
|---|---|
| Build label | `f7aa84f+ONDA16.MD6-<NN>-<form>-incremental` (1 por tela) |
| Manifesto | `MICRO17`, `MICRO18`, `MICRO19`, ... (1 por tela) |
| Arquivos | 1 form `.frm` por tela + `.code-only.txt` se necessário |
| Gate | Quarteto verde + filtro idempotente após cada tela |
| Esforço | 1h IA × N telas + 0.5h Op × N telas |
| **Colaborativo** | **Sim — interativo, operador entrega print** |

**Fluxo por tela:**

1. Operador tira print da tela mostrando controles de filtro.
2. Frente 1 analisa print + código atual + propõe ajuste mínimo (renomear handlers, remover funções heurísticas, garantir nome canônico do botão).
3. Frente 1 entrega manifesto MICRO + procedimento.
4. Operador importa + roda Quarteto + bateria nova `FRM_<form>_filtro_idempotente`.
5. Verde → próxima tela.

**Telas previstas (ordem provisória):**

1. `Limpar_Base.frm` (sem heurística; mais simples).
2. `Reativa_Empresa.frm` (filtro de empresas inativas).
3. `Reativa_Entidade.frm` (idem).
4. `Cadastro_Servico.frm` (filtro CNAE).
5. `Credencia_Empresa.frm` (busca empresa).
6. `Rel_Emp_Serv.frm` (combos hierárquicos).
7. `Rel_OSEmpresa.frm` (combos hierárquicos).
8. `Altera_Empresa.frm` (limpeza heurística residual — mais complexo).

`Altera_Entidade.frm` é template (não toca). Forms sem filtro (`Fundo_Branco`, `ProgressBar`, `Configuracao_Inicial`, `Menu_Principal`) ficam fora.

### MD-16.7 — Suite `TV2_RunUiCentralV2`

| Campo | Valor |
|---|---|
| Build label | `f7aa84f+ONDA16.MD7-ui-central-v2-incremental` |
| Manifesto | `MICRO20` |
| Arquivos | `ABG-Teste_V2_Roteiros.bas` (suite nova) + `ABE-Central_Testes_V2.bas` (opção `[23]`) |
| Gate | Quarteto verde + suite passa 100% (16 cenários) |
| Esforço | 1.5h IA + 0.5h Op |
| Colaborativo | Não |

**Mudanças:**

1. Suite nova:
   - `Public Sub TV2_RunUiCentralV2(Optional silencioso As Boolean = False)`.
   - 1 cenário por opção da Central V2 (16+ cenários).
   - Cada cenário chama via `Application.Run "<sub>"` em modo silencioso e valida estado pós (sheet atualizada, AUDIT_LOG, etc.).
   - Cenários: `UI_CV2_001_SmokeRapido`, `UI_CV2_002_SmokeAssistido`, ..., `UI_CV2_020_Quarteto`.
2. Helper privado `TUI_ValidarHandlerExecutado(handlerName, sheetEsperada)`.
3. `Central_Testes_V2.bas`: opção `[23] Validação UI Central V2` → `TV2_RunUiCentralV2`.

### MD-16.8 — Suite `TV2_RunUiCobertura` (handlers de forms operacionais)

| Campo | Valor |
|---|---|
| Build label | `f7aa84f+ONDA16.MD8-ui-cobertura-incremental` |
| Manifesto | `MICRO21` |
| Arquivos | Módulo novo `ABN-Teste_UI_Engine.bas` + `ABG-Teste_V2_Roteiros.bas` (suite + cenários) + `ABE-Central_Testes_V2.bas` (opção `[24]`) |
| Gate | Quarteto verde + suite passa cobertura mínima |
| Esforço | 3h IA + 1h Op |
| Colaborativo | Parcial (operador valida cobertura por form) |

**Mudanças:**

1. Módulo novo `Teste_UI_Engine.bas`:
   - `Public Sub TUI_AcionarBotao(formName As String, btnName As String, Optional valorPreenchimento As Variant)`.
   - `Public Sub TUI_PreencherCampo(formName As String, ctrlName As String, valor As String)`.
   - `Public Function TUI_FormularioAberto(formName As String) As Boolean`.
   - `Public Sub TUI_FecharFormulario(formName As String)`.
   - Implementação: `frm.Show vbModeless` + `Application.Run "<form>.<btn>_Click"` + assertions.
2. Suite `TV2_RunUiCobertura`:
   - 1 cenário por handler `*_Click()` exposto em forms operacionais (após MD-16.6).
   - Reusa fixtures V1/V2 existentes — preenche campos via `TUI_PreencherCampo`, dispara via `TUI_AcionarBotao`, valida assertions.
   - Cenários: `UI_<form>_<handler>_<NNN>`.
3. `Central_Testes_V2.bas`: opção `[24] Validação UI Cobertura forms` → `TV2_RunUiCobertura`.

**Cobertura mínima:** cada form com handler `*_Click()` válido tem ao menos 1 cenário (ex.: Empresa: `UI_AlteraEmp_001_AlterarOk`, `UI_AlteraEmp_002_InativarOk`; Entidade: `UI_AlteraEnt_001_AlterarOk`, etc.).

### MD-16.9 — Bump v12.0.0203-rc2 + fechamento

| Campo | Valor |
|---|---|
| Build label | `f7aa84f+v12.0.0203-rc2` |
| Manifesto | `MICRO22` |
| Arquivos | `AAX-App_Release.bas` + `CHANGELOG.md` + `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` (L19+L20+L21) + `.hbn/results/0012-exec-onda16.json` + `auditoria/03_ondas/onda_16_testes_refatoracao/70_FECHAMENTO_ONDA_16.md` |
| Gate | Quarteto verde + tag git `v12.0.0203-rc2` |
| Esforço | 1h IA + 0.3h Op |
| Colaborativo | Não |

**Mudanças:**

1. `App_Release.bas`:
   - `APP_BUILD_IMPORTADO = "f7aa84f+v12.0.0203-rc2"`.
   - `APP_RELEASE_TAG = "v12.0.0203-rc2"`.
   - `APP_BUILD_GERADO_EM` atualizado.
2. `CHANGELOG.md` — entrada `[v12.0.0203-rc2] — 2026-MM-DD` resumindo Onda 16.
3. `PHAGOCYTOSIS` — append-only L19+L20+L21 (preserva L1-L18 + M1-M7).
4. ERP `0012-exec-onda16.json`.
5. `70_FECHAMENTO_ONDA_16.md`.
6. Operador roda `git tag v12.0.0203-rc2` + `git push origin v12.0.0203-rc2`.

## 5. Lições novas (PHAGOCYTOSIS L19-L21)

### L19 — Menu de testes: clareza categórica

Padrão: gates de release destacados, suites separadas de visualização separadas de utilitários, com tempo estimado por opção. Operadores e IAs identificam em 1 leitura qual opção rodar.

### L20 — PDF como fixture determinística com nomeação humano-legível

Nome do arquivo carrega entidade + identificador + CNPJ + data — operador localiza visualmente sem abrir. Hash do payload determinístico vai em metadata interno (rodapé do PDF + sheet `RPT_PDFS_GERADOS`), não no nome. Validação por hash de payload + comparação de tamanho em bytes; sem OCR.

### L21 — Estender padrão existente vs criar nova convenção

Quando o operador já tem padrão emergente (Altera_Entidade limpo, Altera_Empresa com dívida residual), a IA detecta o padrão e estende cirurgicamente — sem reinventar. Custo de adoção menor; respeito a decisões de design já tomadas.

## 6. Cronograma sugerido

| Fase | Microdeltas | Esforço IA | Esforço Op | Modo |
|---|---|---|---|---|
| Fase 1 — Quick wins (UI textual + métricas) | MD-16.1, MD-16.2, MD-16.3 | 3.5h | 1.1h | Sequencial |
| Fase 2 — PDFs com CNPJ | MD-16.4 | 2.5h | 0.5h | Sequencial |
| Fase 3 — Padronização filtros | MD-16.5 + MD-16.6 (~5-8 telas) | 1h + 5-8h | 0.3h + 2.5-4h | **Colaborativo** |
| Fase 4 — Cobertura UI | MD-16.7, MD-16.8 | 4.5h | 1.5h | Sequencial |
| Fase 5 — Fechamento | MD-16.9 | 1h | 0.3h | Sequencial |
| **Total** | **9 microdeltas** | **~17-20h IA** | **~6-7.5h Op** | mix |

Cronograma físico provável: **3-5 sessões** ao longo de **1-2 semanas**, dependendo do ritmo dos prints da Fase 3.

## 7. Riscos + mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|---|---|---|---|
| Sparkline VBA Mac falha (MD-16.3) | Média | Médio | Fallback para gráfico de linha simples. |
| `ExportAsFixedFormat` lento >5s/arquivo (MD-16.4) | Média | Baixo | Gerar só ao final do ciclo + flag opcional. |
| `frm.Show vbModeless` rouba foco no Mac (MD-16.7/8) | Média | Médio | Documentar workaround + usar `Application.ScreenUpdating = False`. |
| Operador não consegue tirar print de form raro (MD-16.6) | Baixa | Alto (bloqueia tela) | Fallback: análise via doc histórico do form + decisão Q. |
| `RPT_PDFS_GERADOS` cria problema com legado de `RESULTADO_QA_V2` | Baixa | Médio | Sheet nova é isolada — sem JOIN com legado. |
| CNPJ não populado em fixture de teste (MD-16.4) | Média | Baixo | Validar `EMPRESAS!B` populado antes de gerar PDF; fallback `"00000000000000"` documentado. |
| Antigravity v4 7 documentos `🟠 SOURCE NOT REACHED` | Já materializado | Baixo (Frente 1 leu) | Frente 1 incorpora o que falta direto neste plano. |

## 8. Critério de fechamento Onda 16

A Onda 16 fica APROVADA quando:

- [ ] Quarteto Mínimo verde após cada microdelta importado
- [ ] Sintaxe canônica continua: `V1=171/0+V2_Smoke=14/0+V2_Canonica≥20/0+E2E_Strikes=64/0`
- [ ] Suite `TV2_RunPdfDeterminismo` passa 5/0
- [ ] Suite `TV2_RunUiCentralV2` passa 16+/0 (N = opções da Central)
- [ ] Suite `TV2_RunUiCobertura` passa cobertura mínima (1 cenário por handler `*_Click()` exposto)
- [ ] PDFs gerados em `auditoria/04_evidencias/V12.0.0203/pdfs/<EXEC_ID>/` com nome canônico contendo CNPJ
- [ ] `RPT_PDFS_GERADOS` populada com hash payload
- [ ] `EVOLUCAO_TESTES` populada com sparklines
- [ ] Filtros padronizados em todos os forms com filtro (Fase 3 completa)
- [ ] `Altera_Empresa.frm` sem heurística residual (`Buscar*`, `For Each ctl In container.Controls`)
- [ ] CHANGELOG com entrada `v12.0.0203-rc2`
- [ ] PHAGOCYTOSIS com L19+L20+L21 append-only
- [ ] Tag git `v12.0.0203-rc2` em GitHub

## 9. 🟡 HBN NEEDS HUMAN DECISION — Q1-Q5 antes de readback

| # | Pergunta | Default proposto |
|---|---|---|
| **Q1** | Estratégia de PDF de Ciclo de rodízio (múltiplas empresas): (a) **1 PDF resumo geral** (`CICLO_RESUMO_<EXEC_ID>_<DATA>.pdf`); (b) **1 PDF por empresa** (`CICLO_<CNPJ>_<EXEC_ID>_<DATA>.pdf`); (c) **ambos** | **Opção (c) ambos** — resumo geral 1× + 1 por empresa. Auditoria forense exige granularidade por empresa, e resumo geral é útil para vista executiva. |
| **Q2** | Convenção definitiva: aceitar **convivência** entre `B_/C_/M_` (Entidade) e `mBtn*/M_` (Empresa moderno), com novos controles de filtro adotando `cmb_filtro_/txt_busca_/lst_/B_filtrar_/C_filtrar_`? | **Sim, conviver** — zero churn em código existente; novos controles seguem extensão. Empresa só limpa heurística residual; nomes existentes ficam. |
| **Q3** | Cobertura UI mínima MD-16.8: **todos handlers `*_Click()`** ou **apenas botões críticos de regra de negócio** (Salvar, Inativar, Reativar, Avaliar)? | **Apenas botões críticos** — começamos com cobertura mínima e ampliamos em ondas futuras. Critério: handler que muda estado em sheet operacional ou AUDIT_LOG. |
| **Q4** | Hooks automáticos do `Util_PDF` em produção: gerar PDF (a) **somente em testes** (suite); (b) **também em ambiente operacional** (a cada Avaliação); (c) **opcional via flag** | **Opção (c) opcional via flag** em CONFIG (`PDFS_AUTOMATICOS = TRUE/FALSE`). Default FALSE — operador habilita quando quiser auditoria forense em produção. |
| **Q5** | **Aprovação geral do plano para iniciar implementação?** | Aguardo sua resposta. |

## 10. Próximas ações após aprovação

1. Frente 1 gera `.hbn/readbacks/0012-onda16-testes-refatoracao.json` formal.
2. Frente 1 inicia MD-16.1 (Quick win, baixo risco) e entrega para operador validar.
3. Operador valida + aprova → Frente 1 segue para MD-16.2.
4. Sequência segue até Fase 3 (filtros), onde modo colaborativo entra (operador prints).
5. Onda 16 fecha com `git tag v12.0.0203-rc2`.

## 11. Marcadores HBN V2 ativos neste plano

- 🔵 HBN HANDOFF READY — plano detalhado para implementação
- 🟢 HBN CHECKPOINT CLEAN — todos os pre-flights L14 mapeados
- 🟡 HBN NEEDS HUMAN DECISION — Q1-Q5 acima
- 🟤 HBN LICENSE SPLIT REQUIRED — TPGL Credenciamento; helpers genéricos `TUI_*` + `Util_PDF` candidatos a promoção AGPLv3 com consentimento

## Versão

- v1.0 — 2026-05-02 — plano executivo inicial baseado em Antigravity v4 + refinamentos Frente 1 (CNPJ no nome do PDF, completação dos 7 SOURCE NOT REACHED, pseudocódigo dos helpers TUI, schemas das sheets novas).

— Frente 1 Credenciamento (Claude Opus 4.7 Cowork), 2026-05-02
