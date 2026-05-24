---
titulo: Auditoria PDF/UI V206 — Claude Opus
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Claude Opus
escopo: auditoria estratégica de jornada humana e desenho técnico de PDFs/UI da V206 incremental
prompt-de-origem: chat 2026-05-24 (Mauricio → Claude Opus, “Prompt de Auditoria PDF/UI V206”)
base-tecnica: v12.0.0205 / commit f24e535 / VR_20260523_215637
proxima-etapa: hearback humano dos pontos P0/P1 antes da Onda 31 começar a escrever código
---

# 95. Auditoria PDF/UI V206 — Claude Opus

## 1. Veredito Executivo

**APROVADO COM AJUSTES P1 INCREMENTAIS.** A decisão humana sobre estrutura de
pastas e padrão de nomes resolve corretamente a jornada do operador e do
auditor. A arquitetura PDF deve nascer centralizada em um módulo novo
`Util_PDF.bas`, isolada do RVS e iniciada com log obrigatório desde o primeiro
microdelta. O achado do Codex sobre os dois relatórios (Rel_OSEmpresa e
Rel_Emp_Serv) está **confirmado por leitura direta do código** e merece
correção própria antes do motor PDF, no mesmo padrão da correção histórica de
`Credencia_Empresa`. A camada de testes por simulação deve começar em VBA
determinístico (TV2_UI_*) e só depois explorar automação externa de cliques.

Nenhum P0 que justifique tocar `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`,
`Svc_OS.bas` ou `Svc_PreOS.bas`. Nenhum P0 que altere RN-01 a RN-17. Nenhum P0
que mova `doc/`.

Assinatura RVS V205 a preservar literalmente em qualquer entrega V206:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

## 2. Avaliação da Nomenclatura de PDFs

Padrão aprovado:

```text
<TIPO>_<NUMERO_DOCUMENTO>_CNPJ_<CNPJ_LIMPO>_<AAAAMMDD_HHNNSS>.pdf
```

### Pontos fortes

- `TIPO` em prefixo permite agrupamento visual e filtro fácil no Finder.
- `NUMERO_DOCUMENTO` zero-padded (`000123`) garante ordenação léxica correta
  e leitura imediata pelo operador.
- `CNPJ_LIMPO` (14 dígitos sem máscara) é estável, mecânico, indexável e
  fecha o documento ao titular sem ambiguidade.
- `AAAAMMDD_HHNNSS` ordena cronologicamente no Finder.

### Ajustes recomendados (P1)

1. **Padronizar timestamp em 6 dígitos `HHNNSS` em todos os exemplos.** Os
   exemplos do prompt mostram `..._20260524_1530` (4 dígitos). Dois PDFs no
   mesmo minuto colidiriam o nome. Padronizar `HHNNSS` evita colisão e
   alinha com o helper já existente em
   [Util_Config.bas:362](src/vba/Util_Config.bas#L362)
   (`Format$(Now, "yyyymmdd_hhnnss")`).
2. **Tratar PDFs sem CNPJ específico.** Relatórios agregados (ex.: Pré-OS
   vencidas de todas as empresas) não têm CNPJ. Sugestão:
   - Quando há CNPJ titular do documento: usar `CNPJ_<14d>`.
   - Quando o documento é agregado: trocar o slot por `TODOS` (mantém a
     posição fixa no nome). Exemplos:
     - `REL_PREOS_VENCIDAS_TODOS_20260524_161005.pdf`
     - `REL_OS_ABERTAS_TODOS_20260524_161020.pdf`
   - Quando o documento é de uma entidade demandante (não de empresa),
     usar `ENT_<id_padded>` no lugar de `CNPJ_<...>` para preservar o
     contrato de “quem é o titular do documento”.
3. **Sufixo opcional de versão de release no nome do PDF de validação.**
   Em `Validacao/`, recomendar:
   `RVS_VALIDACAO_RELEASE_<VALIDATION_ID>_V12_0_0206_<AAAAMMDD_HHNNSS>.pdf`
   para evitar confusão entre PDFs de releases diferentes na mesma pasta.
4. **CNPJ deve passar por sanitização explícita** (`Replace(., ".", "")`,
   `Replace(., "/", "")`, `Replace(., "-", "")`) e validação mínima (14
   dígitos numéricos). Caso falhe, fallback `CNPJ_INVALIDO_<id_doc>` em vez
   de gerar nome corrompido.
5. **Limite prático de comprimento.** Nomes ficam entre 55 e 75 caracteres,
   bem abaixo dos limites do macOS/HFS+ (255) e do NTFS (255). Sem
   ajuste necessário; apenas registrar como invariante no spec da Onda 33.

### Aceitação

Com os ajustes acima, a nomenclatura está pronta para virar contrato de
especificação na Onda 33. **Sem necessidade de revisão arquitetural.**

## 3. Avaliação da Estrutura de Pastas

Estrutura aprovada:

```text
Documentos_Gerados/
  Pre-OS/
  OS/
  Avaliacoes/
  Relatorios/
  Validacao/
  Testes_UI/<RUN_ID>/
```

### Pontos fortes

- Espelha exatamente o vocabulário operacional do sistema (Pré-OS, OS,
  Avaliação, Relatório, Validação de Release).
- Separa **artefatos de execução real** (`Pre-OS/`, `OS/`, `Avaliacoes/`,
  `Relatorios/`) de **artefatos de release** (`Validacao/`) e de
  **artefatos de teste** (`Testes_UI/<RUN_ID>/`). Esta tripla separação é
  ótima para o auditor não confundir um PDF de exercício com um PDF
  real.
- `Testes_UI/<RUN_ID>/` isola rodadas de simulação por execução, evitando
  poluição cruzada e permitindo limpeza segura.

### Ajustes recomendados (P1)

1. **Localização raiz precisa ficar fora do repositório git.** PDFs de
   produção contêm dados reais (CNPJ, valores, notas) e não devem ser
   versionados. Sugestão de raiz:
   - **macOS/Excel**: `~/Documents/Documentos_Gerados/` (preferência
     humana, fácil para o operador).
   - **Windows**: `%USERPROFILE%\Documents\Documentos_Gerados\`.
   - Caminho deve ser configurável em `CONFIG` (nova chave
     `PASTA_DOCS_GERADOS`) com default acima e validação `On Error` no
     primeiro uso. Util_PDF.bas cria a pasta com `MkDir` se ausente e
     registra evento em `AUDIT_LOG`.
   - **Não usar `auditoria/evidencias/V12.0.0206/pdf/`** para PDFs de
     produção; aquela pasta é evidência de release, não artefato
     operacional. PDFs de `Validacao/` podem opcionalmente ser **copiados**
     para `auditoria/evidencias/V12.0.0206/pdf/` no fechamento da release
     (cópia, não fonte).
2. **Adicionar `.DS_Store`/`Thumbs.db` ao `.gitignore` da raiz canônica**
   caso o operador eventualmente versione algum PDF de exemplo.
3. **Reservar slot `_LOG/` dentro de `Documentos_Gerados/`** para o log
   `RPT_PDFs_EMITIDOS.csv` (ver §5). Mantém o log próximo dos artefatos
   sem misturá-los com os PDFs reais.
4. **Convenção de subpasta por ano-mês opcional para alto volume.** Em
   produção real, `Documentos_Gerados/OS/2026-05/` pode ajudar o
   operador. Sugestão de feature flag em `CONFIG`: `DOCS_AGRUPAR_AAAA_MM`
   default `FALSE` na V206, `TRUE` opcional via UI. Implementação fica
   para V207 se a Onda 35 indicar necessidade.

## 4. Recomendação de Arquitetura do Motor PDF

**Centralizar em `Util_PDF.bas` novo, não incorporar em `Util_Config.bas`.**

### Justificativa

- `Util_Config.bas` já tem 485 linhas misturando helpers de release, helpers
  de relatório (`Rel_TituloExibicao`, `Rel_NomeArquivoSugerido`,
  `Rel_ConfigurarPagina`), helpers de CNAE e helpers de configuração geral.
  Adicionar PDF aumentaria o acoplamento e dificultaria isolamento de teste.
- A spec DT-5 [(35_SPEC_DT5_PDFs_V12_0204.md)](auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md)
  já previa um módulo `Util_PDF.bas`. A V206 deve seguir essa linha sem
  revisitar a decisão.
- Módulo separado permite suíte de teste isolada (`Teste_V2_PDF.bas`) que
  não contamina nem o RVS, nem `Teste_V2_Engine.bas`.

### API pública mínima sugerida para Onda 33-34

```vba
' Geração de PDF a partir de uma worksheet preparada.
Public Function Util_PDF_GerarPDF( _
    ByVal ws As Worksheet, _
    ByVal caminhoCompleto As String, _
    ByVal titulo As String, _
    Optional ByVal orientacao As XlPageOrientation = xlLandscape) As TResult

' Constrói nome canônico do PDF a partir de tipo+numero+CNPJ.
Public Function Util_PDF_MontarNome( _
    ByVal tipo As String, _
    ByVal numeroDocumento As String, _
    ByVal cnpjLimpo As String) As String

' Resolve pasta-alvo (cria se ausente) a partir do tipo.
Public Function Util_PDF_ResolverPasta(ByVal tipo As String) As String

' Registra emissão no log RPT_PDFs_EMITIDOS.csv.
Public Sub Util_PDF_LogarEmissao( _
    ByVal tipo As String, _
    ByVal numeroDocumento As String, _
    ByVal cnpjLimpo As String, _
    ByVal caminho As String, _
    ByVal hashPdf As String, _
    ByVal status As String)
```

### Mecanismo

- `Workbook.ExportAsFixedFormat Type:=xlTypePDF` (nativo, sem dependência
  externa).
- `On Error GoTo` em todas as funções públicas; mensagem amigável de
  fallback “Não foi possível gerar o PDF automaticamente. Use Arquivo >
  Exportar > Criar PDF e salve em <pasta sugerida>.”.
- Validação pós-geração obrigatória: arquivo existe, tamanho > 0,
  primeiros 4 bytes `%PDF`. Sem essas três checagens, geração não conta
  como sucesso. Espelha o que Gemini já recomendou na auditoria
  adversarial.
- **Sem dependência de Word.Application**; tudo via Excel nativo.

### Acoplamento com `Rel_ConfigurarPagina`

Reutilizar `Rel_ConfigurarPagina` existente para cabeçalho/rodapé. Adicionar
helper `Util_PDF_ConfigurarFooterCanonico(ws, resumoLinha)` para gravar a
linha `RESUMO: [N OSes] [M strikes] [K suspensoes] [STATUS=...]` exigida pela
spec DT-5, sem alterar a função histórica.

## 5. Recomendação para o Log `RPT_PDFs_EMITIDOS`

**Obrigatório desde o primeiro microdelta de PDF.** Não aceitar microdelta
separado para o log.

### Justificativa

- Sem log, não há trilha auditável; o sistema gera PDFs invisíveis ao
  Audit_Log.
- Custo de implementação é baixíssimo: append CSV linha por geração.
- Espelha o padrão já adotado em `RPT_BUGS_RESOLVIDOS` e
  `AUDIT_LOG`: rastreabilidade nasce junto com a feature.

### Esquema mínimo CSV

```text
TIMESTAMP,TIPO,NUMERO_DOC,CNPJ,CAMINHO,SHA1_PDF,STATUS,BUILD_LABEL,USUARIO
```

- `TIMESTAMP` ISO-8601 local com fuso.
- `STATUS` ∈ {`OK`, `FALLBACK_MANUAL`, `ERRO_<categoria>`}.
- `BUILD_LABEL` lido de `APP_BUILD_IMPORTADO`.
- `USUARIO` lido de `Environ$("USERNAME")` quando disponível, senão
  `DESCONHECIDO`.

Localização: `Documentos_Gerados/_LOG/RPT_PDFs_EMITIDOS.csv`. Append-only.
**Não criar aba `RPT_PDFs_EMITIDOS` no workbook** — o log fica fora da
planilha para não inflar o `.xlsm` e não interferir no RVS.

Complementarmente, registrar evento de alto nível em `Audit_Log.Registrar`
(`PDF_EMITIDO` com payload `tipo|numero|status`).

## 6. Recomendação para os Dois Relatórios Citados

### Achado do Codex — confirmado por leitura direta

[Menu_Principal.frm:3105-3115](src/vba/Menu_Principal.frm#L3105-L3115):

```vba
Private Sub Btn_Rel_OS_Empresa_Click()
    On Error GoTo falha
    Dim frmRelOSEmpresa As Object
    Call PreenchimentoRelatorioOSEmpresa            ' (1) popula instância A
    Set frmRelOSEmpresa = VBA.UserForms.Add("Rel_OSEmpresa") ' (2) cria instância B vazia
    frmRelOSEmpresa.Show vbModal                    ' (3) exibe B (vazia)
    ...
```

[Menu_Principal.frm:3216-3224](src/vba/Menu_Principal.frm#L3216-L3224):

```vba
Private Sub Rel_EmpXServ_Click()
    Dim frmRelEmpServ As Object
    Call PreenchimentoRel_EmpXServ                  ' (1) tenta popular; com criarSeAusente=False,
                                                     '     se nenhuma instância existe, retorna Nothing
    Set frmRelEmpServ = VBA.UserForms.Add("Rel_Emp_Serv") ' (2) cria B vazia
    frmRelEmpServ.Show                               ' (3) exibe B (vazia)
End Sub
```

`PreenchimentoRelatorioOSEmpresa` ([Preencher.bas:1385](src/vba/Preencher.bas#L1385))
chama `ControleFormulario("Rel_OSEmpresa", "RO_Lista", True)` — com
`criarFormulario=True`, cria instância A através de `FormularioAberto`
([Preencher.bas:166](src/vba/Preencher.bas#L166)); essa A fica em
`VBA.UserForms` mas é uma instância **diferente** daquela criada pelo
`Btn_Rel_OS_Empresa_Click`. A instância exibida (B) nasce vazia.

`PreenchimentoRel_EmpXServ` ([Preencher.bas:1433](src/vba/Preencher.bas#L1433))
**não** passa `criarFormulario=True`; se nenhuma instância de
`Rel_Emp_Serv` existir, o `ControleFormulario` retorna `Nothing`, o
`SV_CR_Lista` nunca é populado e o `UserForms.Add` subsequente exibe um
formulário em branco.

**Bug confirmado em ambos os relatórios.** Mesmo padrão que foi corrigido
em `Credencia_Empresa_Click` em
[Menu_Principal.frm:646-741](src/vba/Menu_Principal.frm#L646-L741) (vide
comentário-vacina nas linhas 648-652).

### Recomendação P0 (escopo de UI, sem tocar serviços)

**Opção (a) escolhida: criar a instância primeiro e popular a instância
exibida.** Aplicar o mesmo padrão da correção histórica de
`Credencia_Empresa`, sem refatorar `PreenchimentoRel_*`:

```vba
Private Sub Btn_Rel_OS_Empresa_Click()
    On Error GoTo falha
    Dim frmRelOSEmpresa As Object
    Dim frmExistente As Object

    ' Fechar instâncias fantasma (padrão Credencia_Empresa)
    On Error Resume Next
    For Each frmExistente In VBA.UserForms
        If typeName(frmExistente) = "Rel_OSEmpresa" Then Unload frmExistente
    Next frmExistente
    On Error GoTo falha

    Set frmRelOSEmpresa = VBA.UserForms.Add("Rel_OSEmpresa")
    Call PreenchimentoRelatorioOSEmpresa    ' agora encontra a única instância existente
    frmRelOSEmpresa.Show vbModal
    Exit Sub
falha:
    MsgBox "Erro ao abrir relatorio OS por Empresa: " & Err.Description, vbCritical, "Relatorio"
End Sub
```

Mesma transformação aplica-se a `Rel_EmpXServ_Click`.

`FormularioAberto` já prefere instância visível e cai em fallback para a
primeira existente, então funciona mesmo antes do `Show`.

### Por que **não** opção (b), (c) ou outro desenho

- **(b) `PreenchimentoRel_*` receber instância opcional** é mais limpo a
  longo prazo, mas exige alterar assinatura pública, atualizar todos os
  callers e mexer em ~50 linhas distribuídas. Vira escopo médio. Fica
  para V207 como cleanup, junto com revisão geral dos demais
  `Preenchimento*`.
- **(c) migrar geração do relatório para rotina independente de form**
  acopla mudança estrutural à correção de bug. Viola a regra V206 de
  manter changes incrementais.
- **Mover população para `UserForm_Initialize` do próprio form** seria o
  desenho mais natural OOP, mas extrai código de `Preencher.bas` para o
  `.frm` — refator que cabe em V207, não em V206.

### Ordem dentro da V206

**Corrigir os dois relatórios ANTES do motor PDF.** Justificativa:

- Higiene de UI deve preceder hook PDF; gerar PDF de um formulário vazio
  produziria PDF vazio e mascarando o bug.
- Microdelta dedicado a UI (sem motor PDF junto) facilita o gate (Smoke
  + cenário assistido `ASS_REL_OS_EMP_LISTA` e `ASS_REL_EMP_SERV_LISTA`)
  sem novidade arquitetural concorrente.

Sugestão: encaixar na **Onda 33** como microdelta MD-33.0 (antes da spec
final do motor PDF), classificado como **P1 de UI**, com
escopo de 1 arquivo (`Menu_Principal.frm`).

### Limpeza correlata sugerida

Remover (ou marcar como dispensável) a linha
[Menu_Principal.frm:3354](src/vba/Menu_Principal.frm#L3354):

```vba
Call PreenchimentoRelatorioOSEmpresa
```

dentro do `UserForm_Initialize` do `Menu_Principal`. Esse pré-aquecimento
cria uma instância fantasma de `Rel_OSEmpresa` na inicialização do menu
que **não é usada por ninguém** depois do fix acima. Risco baixo,
benefício alto (elimina instância invisível na sessão).

## 7. Recomendação para Testes por Simulação de Cliques

### Princípio

**Começar por uma camada VBA determinística antes de qualquer automação
externa.** Razões:

- VBA pode chamar handlers de evento diretamente
  (`frm.Btn_X_Click`, `frm.RO_Lista_Click`, etc.) sem precisar de Win32
  SendInput, AppleScript ou Selenium-like. Determinismo total, zero
  flake.
- Não introduz dependência externa antes da V207.
- Encaixa no padrão `Teste_V2_*` existente, com mesma infra de coleta de
  evidência.
- Não contamina o RVS — vira `TV2_UI_*` em suíte própria, com seu
  contador isolado.

### Desenho V206 (Onda 36)

1. Novo módulo `Teste_V2_UI.bas` com prefixo de teste `TV2_UI_*`.
2. Cada teste:
   - Garante baseline (`TV2_SetConfigCanonica` + dados mínimos).
   - Cria instância do form alvo via `VBA.UserForms.Add("<Nome>")` mas
     **não chama `.Show`** (evita modal travar a suíte). Chama os
     handlers via `frm.NomeDoHandler_Click` (handlers que forem
     `Private` precisam ser temporariamente `Public` ou expostos por
     `Sub` pública do form — escolher caso a caso por mínimo impacto).
   - Faz asserts em controles (`frm.RO_Lista.ListCount`, `frm.RO_Lista.List(0, 2)`,
     etc.).
   - Faz `Unload frm` no fim.
3. Suíte isolada com macro `TV2_UI_RunAll`; não entra no RVS.
4. Cenários mínimos V206:
   - `TV2_UI_REL_OS_EMP_LISTA_NAO_VAZIA`
   - `TV2_UI_REL_EMP_SERV_LISTA_NAO_VAZIA`
   - `TV2_UI_PREOS_VENCIDAS_FILTRO_DATA`
   - `TV2_UI_VALIDACAO_RELEASE_PRESENTE`

### V207 (fora de escopo V206)

- Automação externa por clique real (Excel COM via Python `pywin32` ou
  AppleScript no macOS). Útil para validar pipeline visual de
  `frm.Show`, modal/non-modal, foco, etc. Mas: maior custo, maior flake,
  requer infra fora do `.xlsm`. **Não cabe em V206.**

### Desenho simplificador para futura automação

Para preparar a camada externa (V207), recomenda-se na V206 que cada
handler `Private Sub Btn_X_Click` ganhe uma versão pública de fachada
`Public Sub UI_Btn_X(Optional ByVal silenciarMsgBox As Boolean = False)`
quando tocada por outro motivo. **Não criar fachadas só para teste agora**
(viola anti-padrão "não adicionar abstração para uso futuro"). Apenas
quando o handler for tocado por outra razão, aproveitar para expor.

## 8. Riscos e Mitigação

| Risco | Severidade | Mitigação |
|---|---|---|
| Teste de PDF contamina contadores RVS e quebra a assinatura V205 | **P0** | Suíte PDF em módulo separado `Teste_V2_PDF.bas`, macro própria, não invocada por `CT_ValidarRelease_*`. Gate RVS deve falhar explicitamente se um novo contador aparecer. |
| ExportAsFixedFormat falha por ausência de driver de PDF em ambiente local | P1 | Try/catch obrigatório + fallback manual visível ao operador. Validação `%PDF-` pós-geração. Registrar `FALLBACK_MANUAL` no log. |
| Pasta `Documentos_Gerados/` cresce sem limite | P2 | Documentar política de retenção na jornada humana V206. Implementação de rotação fica para V207. |
| PDF contém dados reais (CNPJ, valores) e é versionado por engano | P1 | Raiz canônica **fora** do repo git (ver §3.1). Adicionar `Documentos_Gerados/` ao `.gitignore` defensivamente, mesmo que a pasta nunca vá pra raiz do repo. |
| Correção dos dois relatórios introduz regressão em fluxo de impressão | P1 | Cenário assistido obrigatório por relatório + Smoke verde. Não fechar Onda 33 sem hearback humano de “lista preencheu e impressão funcionou”. |
| `UserForm_Initialize` do Menu_Principal removido quebra alguma dependência oculta | P2 | grep prévio por outros consumidores de `Rel_OSEmpresa` na inicialização. Se houver, manter a chamada mas anexar comentário; senão, remover. |
| Log `RPT_PDFs_EMITIDOS.csv` corrompe por escrita concorrente | P3 | Excel VBA single-threaded; risco real apenas se múltiplas instâncias do workbook estiverem abertas simultaneamente. Mitigação: write com retry + lock arquivo via `Open ... For Append` com `On Error`. |
| Camada `TV2_UI_*` exige expor handlers privados como públicos | P2 | Expor apenas quando o handler já vai ser tocado por outro motivo na onda; caso contrário, escrever teste via reprodução do efeito (ex.: chamar `PreenchimentoRel_*` direto após `UserForms.Add` e assertar `ListCount`). |
| Renomear símbolo `Sexteto`/`Quinteto` na esteira do Importador V3 | **P0** | **Bloqueado.** V206 só atualiza mensagens de UI orientando “Gate RVS” sem mexer em nomes de funções/macros. Renomeação interna fica para V207. |

## 9. Cadência Sugerida de Ondas 32 a 37

A sequência abaixo respeita o Roadmap Consolidado
[(02_planos/32_ROADMAP_V206_CONSOLIDADO.md)](auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md)
e detalha microdeltas dentro de cada onda. Mantém Onda 30 (planejamento) e
Onda 31 (higiene documental) como o Codex já consolidou; ajusta o conteúdo
de 32 a 37 para incorporar os achados desta auditoria.

### Onda 32 — Importador V3 e mensagens operacionais

**Sem mudança em relação ao Roadmap Consolidado.** Apenas atualização de
textos legados de Importador V3 (`Trio`/`Quarteto`/`Sexteto` → orientação
“Gate RVS”). Gate: compile VBE + V2 Smoke. **Bloqueado** renomear símbolos
internos VBA.

### Onda 33 — Spec PDF isolado + fix dos dois relatórios

- **MD-33.0 — Fix Rel_OSEmpresa e Rel_Emp_Serv (UI)**. Microdelta de 1
  arquivo (`Menu_Principal.frm`). Aplicar padrão Credencia_Empresa.
  Remover `Call PreenchimentoRelatorioOSEmpresa` redundante de
  `UserForm_Initialize`. Gate: compile + Smoke + cenário assistido
  `ASS_REL_OS_EMP_LISTA` + `ASS_REL_EMP_SERV_LISTA`. **P1 obrigatório.**
- **MD-33.1 — Spec final do motor PDF V206**. Documento
  `docs/reference/testes/ESPEC_PDF_AUTOMATICO_V206.md` consolidando esta
  auditoria + decisão do operador. Incluir esquema do log
  `RPT_PDFs_EMITIDOS.csv`, contrato de `Util_PDF.bas`, política de
  retenção e raiz canônica `~/Documents/Documentos_Gerados/`. Gate:
  hearback humano.
- **MD-33.2 — Esqueleto Util_PDF.bas com helpers puros**. Apenas
  `Util_PDF_MontarNome`, `Util_PDF_ResolverPasta`,
  `Util_PDF_LogarEmissao` (sem geração). Testes determinísticos em
  `Teste_V2_PDF.bas` (novo). Gate: compile + suíte PDF isolada.

### Onda 34 — Motor PDF robusto + hook em VALIDACAO_RELEASE

- **MD-34.0 — `Util_PDF_GerarPDF` com ExportAsFixedFormat + validação
  `%PDF-` + fallback manual**. Gate: compile + suíte PDF isolada + RVS
  inteiro verde (assinatura V205 imutável).
- **MD-34.1 — Hook em VALIDACAO_RELEASE.** Substitui o fluxo manual da
  V205. Gera para `Documentos_Gerados/Validacao/` com nome canônico.
  Gate: RVS + 1 PDF de release validado por hearback humano.

### Onda 35 — Jornada humana V206 + hooks PDF nos fluxos de negócio

- **MD-35.0 — Hook PDF em Pré-OS, OS e Avaliação.** **NÃO altera lógica
  de negócio**. Apenas botão “Salvar PDF” ou chamada automática
  pós-evento (a definir no MD-35.0a por hearback). Gate: cenário
  assistido por fluxo + RVS verde.
- **MD-35.1 — Hook PDF em Relatórios.** Adiciona “Salvar como PDF” aos 4
  relatórios principais. Reutiliza `Util_PDF_GerarPDF` com `ws` =
  `SHEET_RELATORIO` já preparada. Gate: cenário assistido por relatório.
- **MD-35.2 — Atualização da jornada humana**. Atualiza
  `docs/tutorials/JORNADA_VALIDACAO_HUMANA_V206.md` (ou cria) com fluxo
  PDF, checklist de hash, triagem P0/P1/P2/P3 e localização da pasta
  canônica. Gate: dry-run humano.

### Onda 36 — Camada `TV2_UI_*` (simulação determinística) + débitos pequenos

- **MD-36.0 — `Teste_V2_UI.bas` com 4 cenários mínimos** (§7). Gate:
  suíte isolada verde + RVS verde.
- **MD-36.1 — Débitos pequenos nominais.** Lista nominal aprovada por
  hearback antes de abrir o microdelta. Sem reescrita de
  `Svc_*`/`Repo_*`. Gate: teste específico do débito + RVS se tocar
  código.

### Onda 37 — RC e freeze V206

- App_Release bump, release note, evidências V206, auditoria cruzada
  final (Opus + Antigravity), tag `v12.0.0206`. Gate: RVS completo +
  AF1/AF2/AF3 V206 + hearback final humano.

## 10. Classificação Consolidada P0/P1/P2/P3

### P0 (nenhum no escopo desta auditoria)

Nenhum achado P0. Os bloqueios P0 declarados pelo prompt (não tocar
`Svc_*.bas`, não alterar RN-01..RN-17, não mover `doc/`, não contaminar
RVS, não renomear símbolos internos VBA) continuam válidos e nenhuma
recomendação desta auditoria os viola.

### P1 (incremental obrigatório dentro da V206)

- **P1-01 — Fix Rel_OSEmpresa e Rel_Emp_Serv** (§6). Onda 33 MD-33.0.
- **P1-02 — Padronizar timestamp PDF em `HHNNSS` (6 dígitos)** (§2.1).
  Onda 33 MD-33.1.
- **P1-03 — Tratar PDFs sem CNPJ titular com slot `TODOS`/`ENT_<id>`**
  (§2.2). Onda 33 MD-33.1.
- **P1-04 — Raiz canônica `~/Documents/Documentos_Gerados/`, fora do repo
  git** (§3.1). Onda 33 MD-33.1.
- **P1-05 — Log `RPT_PDFs_EMITIDOS.csv` obrigatório desde o primeiro
  microdelta de PDF** (§5). Onda 33 MD-33.2.
- **P1-06 — Validação `%PDF-` + fallback manual visível** (§4 e §8).
  Onda 34 MD-34.0.

### P2 (incremental recomendado, não bloqueante)

- **P2-01 — Sufixo de versão release no nome de PDFs de Validação**
  (§2.3). Onda 33 MD-33.1.
- **P2-02 — Sanitização de CNPJ + fallback `CNPJ_INVALIDO_<id>`**
  (§2.4). Onda 33 MD-33.2.
- **P2-03 — Slot `_LOG/` dentro de `Documentos_Gerados/`** (§3.3). Onda
  33 MD-33.2.
- **P2-04 — Remover `Call PreenchimentoRelatorioOSEmpresa` de
  `UserForm_Initialize` do Menu_Principal** (§6, "Limpeza correlata").
  Onda 33 MD-33.0.
- **P2-05 — Suíte `TV2_UI_*` com 4 cenários determinísticos** (§7). Onda
  36 MD-36.0.

### P3 (oportunidade futura, idealmente V207)

- **P3-01 — Refator `PreenchimentoRel_*` para receber instância
  opcional** (§6, opção b). V207.
- **P3-02 — Feature flag `DOCS_AGRUPAR_AAAA_MM`** (§3.4). V207.
- **P3-03 — Política de retenção e rotação de `Documentos_Gerados/`**
  (§8 risco 3). V207.
- **P3-04 — Automação externa de clique real (V207)** (§7).
- **P3-05 — Word.Application automation para layout rico** (vide spec
  DT-5). V207+.

## 11. Conferência Final de Blindagens

- RN-01 a RN-17 → **não tocadas**.
- Doc/ → **não movido**.
- `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas`,
  `Svc_PreOS.bas` → **não alterados** por nenhuma recomendação.
- Símbolos internos VBA → **não renomeados**.
- Teste de PDF → **fora das seis sub-baterias do RVS**, em módulo e suíte
  próprios.
- Pareceres prévios (88 Opus, 89 Gemini, 90 Codex) → **respeitados**;
  esta auditoria refina sem revogar.
- Decisão humana sobre estrutura de pastas e nomes de PDF →
  **incorporada e aprovada com ajustes P1 não-disruptivos**.

## 12. Próxima Ação Recomendada

1. Hearback humano dos itens **P1** (especialmente P1-01 a P1-06).
2. Abrir Onda 31 (higiene documental) conforme Codex já planejou.
3. Onda 33 começa com **MD-33.0 (fix dos dois relatórios)** antes do
   spec do motor PDF.
4. Manter Codex como implementador, Opus e Antigravity como auditores
   finais nas Ondas 34, 35 e 37, alinhado à Cadência D documentada na
   memória pessoal.
