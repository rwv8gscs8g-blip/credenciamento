---
titulo: Consolidação PDF/UI V206 — Codex
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# 97. Consolidação PDF/UI V206 — Codex

## 1. Veredito consolidado

**Aprovado para implementação incremental, com P1 obrigatórios antes do motor
PDF.** A auditoria cruzada confirma que a estrutura humana aprovada pelo
operador é adequada, mas a V12.0.0206 precisa executar a correção dos dois
relatórios antes de qualquer PDF automático de relatório.

Não há P0 novo. Permanecem bloqueios absolutos: RN-01 a RN-17, contadores RVS,
`doc/`, `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas`,
`Svc_PreOS.bas` e renomeações internas VBA.

Entradas lidas para esta consolidação:

- `95_AUDITORIA_PDF_UI_V206_CLAUDE_OPUS.md`, recebido em
  `/Users/macbookpro/Projetos/Credenciamento/auditoria/00_status/`.
- `96_AUDITORIA_ADVERSARIAL_PDF_UI_V206_GEMINI.md`, recebido em
  `/Users/macbookpro/Projetos/Credenciamento/auditoria/00_status/`.
- `auditoria/00_status/92_PROMPT_AUDITORIA_PDF_UI_V206_CLAUDE_OPUS.md`.
- `auditoria/00_status/93_PROMPT_AUDITORIA_ADVERSARIAL_PDF_UI_V206_GEMINI.md`.
- `auditoria/00_status/94_PROMPT_CONSOLIDACAO_PDF_UI_V206_CODEX.md`.
- `auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md`.
- `auditoria/03_ondas/onda_31_v206_higiene_documental/01_TECNICO_ONDA31_HIGIENE_DOCUMENTAL.md`.
- `docs/reference/testes/ESPEC_PDF_AUTOMATICO_V205.md`.
- `auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md`.
- `auditoria/02_planos/25_PLANO_HARDENING_POS_0203.md`.

## 2. Decisões finais

1. **Onda 33 começa pelo bug dos relatórios.** `Rel_OSEmpresa` e
   `Rel_Emp_Serv` hoje podem exibir instância vazia porque o menu popula uma
   instância e mostra outra. Esse bug deve ser corrigido antes do PDF para não
   gerar arquivos válidos com conteúdo em branco.
2. **Motor PDF em módulo novo.** A implementação deve criar `Util_PDF.bas`,
   isolando responsabilidades de pasta, nome, exportação, validação, fallback e
   log. Não incorporar o motor em `Util_Config.bas`.
3. **PDF é camada de apresentação.** O motor não reabre regra de negócio e não
   toca os serviços blindados. Pré-OS, OS e avaliação já persistidas não são
   desfeitas se o PDF falhar.
4. **RVS fica intocado.** PDF e UI simulada terão suites complementares
   isoladas, sem contadores novos nas seis baterias do RVS.
5. **Raiz de saída tem regra híbrida.** A preferência humana é criar
   `Documentos_Gerados/` ao lado da planilha. Para evitar vazamento no git, o
   resolver só usa esse caminho quando o workbook está salvo, a pasta é
   gravável e o caminho não está dentro do repositório. Caso contrário, usa a
   raiz canônica em `Documents/Documentos_Gerados/`.
6. **Log CSV é obrigatório desde o primeiro PDF real.**
   `Documentos_Gerados/_LOG/RPT_PDFs_EMITIDOS.csv` nasce junto com o gerador,
   em modo append-only.
7. **Timestamp final é sempre `AAAAMMDD_HHNNSS`.** Exemplos com minuto apenas
   ficam rejeitados na V206.
8. **Testes por clique começam determinísticos em VBA.** Automação externa por
   clique real fica fora do escopo V206, salvo novo hearback explícito.

## 3. Arquitetura proposta

### 3.1 Módulo `Util_PDF.bas`

API pública mínima para implementação:

| Entrada pública | Responsabilidade | Retorno esperado |
|---|---|---|
| `Util_PDF_MontarNome` | Normalizar tipo, número, titular, timestamp e extensão | nome canônico sem caminho |
| `Util_PDF_ResolverRaiz` | Resolver raiz operacional segura | caminho raiz ou erro explicável |
| `Util_PDF_ResolverPasta` | Criar/retornar subpasta por tipo | caminho final de pasta |
| `Util_PDF_GerarPlanilhaComoPDF` | Exportar `Worksheet` preparada com `ExportAsFixedFormat` | `TResult` com caminho/status |
| `Util_PDF_ValidarArquivo` | Validar existência, tamanho e assinatura `%PDF` | booleano/`TResult` |
| `Util_PDF_LogarEmissao` | Registrar linha append-only no CSV | `TResult` |
| `Util_PDF_FallbackManual` | Montar mensagem humana de fallback | texto/mensagem controlada |

`TResult` já existe em `Mod_Types.bas`, então o motor deve reaproveitar o tipo
canônico em vez de criar um contrato paralelo. Isso não altera `Mod_Types.bas`.

### 3.2 Ordem interna do motor

1. Resolver metadados mínimos: tipo, número do documento, titular, worksheet e
   pasta alvo.
2. Montar nome canônico.
3. Criar pasta, incluindo pais intermediários.
4. Exportar com `ExportAsFixedFormat`, sem abrir visualizador do PDF.
5. Validar arquivo no sistema de arquivos.
6. Registrar log CSV apenas após validação de sucesso. Falhas também devem ser
   registradas quando a pasta de log estiver disponível.
7. Retornar `TResult` para a camada de UI decidir a mensagem ao operador.

### 3.3 Onde o motor pode ser chamado

Chamadas permitidas na V206:

- handlers de interface que já imprimem ou montam relatórios;
- rotinas de apresentação em `Preencher.bas` que hoje chamam `PrintOut`;
- formulários de relatório depois que a aba `RELATORIO` estiver preparada;
- testes isolados `Teste_V2_PDF.bas` e `Teste_V2_UI.bas`.

Chamadas proibidas na V206:

- `Svc_Rodizio.bas`;
- `Svc_Avaliacao.bas`;
- `Svc_OS.bas`;
- `Svc_PreOS.bas`;
- qualquer rotina que mude RN-01 a RN-17;
- qualquer suíte ou agregador que altere a assinatura RVS.

## 4. Contrato de nomes e pastas

Estrutura aprovada:

```text
Documentos_Gerados/
  Pre-OS/
  OS/
  Avaliacoes/
  Relatorios/
  Validacao/
  Testes_UI/<RUN_ID>/
  _LOG/
```

Nome canônico:

```text
<TIPO>_<NUMERO_DOCUMENTO>_<TITULAR>_<AAAAMMDD_HHNNSS>.pdf
```

Para documentos com CNPJ, `<TITULAR>` deve ser:

```text
CNPJ_<CNPJ_LIMPO>
```

Exemplos válidos:

- `PREOS_000123_CNPJ_12345678000199_20260524_153022.pdf`
- `OS_000456_CNPJ_12345678000199_20260524_153103.pdf`
- `AVALIACAO_OS_000456_CNPJ_12345678000199_20260524_153215.pdf`
- `REL_OS_POR_EMPRESA_000456_CNPJ_12345678000199_20260524_153330.pdf`
- `REL_EMPRESAS_POR_SERVICO_000012_TODOS_20260524_153445.pdf`
- `RVS_VALIDACAO_RELEASE_V12_0_0206_VR_20260524_153500.pdf`

### 4.1 Sanitização

- `TIPO`: caixa alta, ASCII, sem acentos, espaços convertidos para `_`,
  somente letras, números e `_`.
- `NUMERO_DOCUMENTO`: quando numérico, zero-padding mínimo de 6 dígitos. Quando
  legado não numérico, sanitizar e manter valor auditável.
- `CNPJ_LIMPO`: somente 14 dígitos. Remover `.`, `/`, `-`, espaços e qualquer
  caractere não numérico.
- CNPJ ausente em relatório agregado: usar `TODOS`.
- Documento titularizado por entidade, sem CNPJ de empresa: usar `ENT_<id>`.
- CNPJ corrompido em documento que deveria ter empresa: usar
  `CNPJ_INVALIDO_<NUMERO_DOCUMENTO>` e registrar alerta no log.

### 4.2 Raiz ao lado da planilha

Resolver de raiz:

1. Se houver configuração futura `PASTA_DOCS_GERADOS` válida e gravável, usar
   essa pasta.
2. Se o workbook estiver salvo, `ThisWorkbook.Path` for gravável e não estiver
   dentro do repositório git, usar
   `<ThisWorkbook.Path>/Documentos_Gerados/`.
3. Se o workbook não estiver salvo, estiver em pasta sem permissão, em caminho
   de rede instável ou dentro do repositório, usar a raiz segura:
   - macOS: `~/Documents/Documentos_Gerados/`;
   - Windows: `%USERPROFILE%\Documents\Documentos_Gerados\`.
4. Se nenhuma raiz puder ser criada, retornar erro explicável e fallback manual
   com o nome sugerido.

### 4.3 Caminhos longos e colisão

- O caminho absoluto final deve ser checado antes da exportação.
- Limite defensivo: 240 caracteres. Acima disso, reduzir partes não essenciais
  do nome preservando `TIPO`, `NUMERO_DOCUMENTO`, `TITULAR` e timestamp.
- Se o arquivo já existir, não sobrescrever. Acrescentar sufixo sequencial
  `_02`, `_03`, etc.
- `Testes_UI/<RUN_ID>/` deve isolar cada rodada de simulação.

## 5. Validação, log e fallback

### 5.1 Validação de arquivo

Um PDF só pode ser declarado `OK` quando todas as condições passarem:

- arquivo existe;
- tamanho maior que zero;
- primeiros bytes do arquivo indicam assinatura `%PDF`;
- caminho gerado bate com o caminho registrado no log.

Falha em qualquer item retorna `TResult.Ok = False` e mensagem operacional.

### 5.2 Log obrigatório

Arquivo:

```text
Documentos_Gerados/_LOG/RPT_PDFs_EMITIDOS.csv
```

Campos mínimos:

```text
TIMESTAMP,TIPO,NUMERO_DOC,TITULAR,CAMINHO,TAMANHO_BYTES,SHA1_PDF,STATUS,BUILD_LABEL,USUARIO,MENSAGEM
```

Estados mínimos:

- `OK`;
- `FALLBACK_MANUAL`;
- `ERRO_PASTA`;
- `ERRO_EXPORTACAO`;
- `ERRO_VALIDACAO`;
- `ERRO_CAMINHO_LONGO`;
- `ERRO_CNPJ_INVALIDO`.

O log deve ser append-only. Se o CSV não puder ser escrito, a UI deve exibir
falha clara e, quando tecnicamente possível, registrar evento de alto nível no
`AUDIT_LOG` sem bloquear a operação principal.

### 5.3 Fallback sem rollback

Se o PDF falhar após Pré-OS, OS ou avaliação já persistida:

- não desfazer o documento operacional;
- não limpar a aba preparada antes de oferecer fallback;
- exibir pasta sugerida e nome sugerido para exportação manual;
- registrar `FALLBACK_MANUAL` se o log estiver disponível;
- manter a mensagem curta e compreensível para operador humano.

## 6. Correção dos dois relatórios

### 6.1 Bug confirmado

Os handlers atuais do menu acionam preenchimento antes de criar/exibir a
instância que o operador vê:

- `Btn_Rel_OS_Empresa_Click` chama `PreenchimentoRelatorioOSEmpresa` e depois
  cria `Rel_OSEmpresa`.
- `Rel_EmpXServ_Click` chama `PreenchimentoRel_EmpXServ` e depois cria
  `Rel_Emp_Serv`.

O resultado é o padrão de instância fantasma: instância A recebe dados,
instância B é exibida vazia.

### 6.2 Correção escolhida

Onda 33 MD-33.0 deve aplicar a opção mais incremental:

1. descarregar instâncias fantasma do mesmo formulário, se existirem;
2. criar a instância que será exibida;
3. chamar a rotina de preenchimento com essa instância já presente em
   `VBA.UserForms`;
4. validar lista não vazia quando houver dados canônicos;
5. exibir a instância populada.

Não alterar assinaturas públicas de `PreenchimentoRel_*` na V206. Não migrar a
geração de relatório para arquitetura nova. Não tocar serviços de negócio.

### 6.3 Limpeza correlata

Auditar a chamada redundante de `PreenchimentoRelatorioOSEmpresa` no
`UserForm_Initialize` de `Menu_Principal`. Se confirmada como preaquecimento
sem consumidor, remover no mesmo MD-33.0. Se houver dependência oculta,
registrar a decisão e manter.

### 6.4 Testes da correção

Cada relatório corrigido exige teste correspondente:

- `TV2_UI_REL_OS_EMP_LISTA_NAO_VAZIA`, isolado fora do RVS;
- `TV2_UI_REL_EMP_SERV_LISTA_NAO_VAZIA`, isolado fora do RVS;
- cenário assistido humano `ASS_REL_OS_EMP_LISTA`;
- cenário assistido humano `ASS_REL_EMP_SERV_LISTA`.

Se a camada `Teste_V2_UI.bas` ainda não existir no MD-33.0, o gate mínimo é:
compile VBE, Smoke, roteiro assistido documentado e readback humano. A suíte
isolada entra formalmente na Onda 36.

## 7. Plano de testes por simulação de cliques

### 7.1 Camada V206

A V206 implementa simulação determinística em VBA, não clique real externo.
O módulo alvo é `Teste_V2_UI.bas`, com prefixo `TV2_UI_*` e runner próprio
`TV2_UI_RunAll`.

Princípios:

- criar instâncias de formulários via VBA;
- evitar `.Show vbModal` em testes automatizados;
- selecionar listas e preencher controles por código;
- chamar wrappers públicos mínimos somente quando o formulário já for tocado
  pela implementação;
- descarregar formulário ao fim de cada cenário;
- registrar resultado em artefato separado, nunca nos contadores RVS.

### 7.2 Pontos de entrada para simplificar testes

Quando um handler for alterado por motivo funcional, ele pode ganhar uma
fachada pública estreita, com nome `UI_<Acao>`, para uso por testes. Não criar
fachadas apenas por antecipação.

Para PDF, a simplificação principal é evitar dependência de clique:

- o handler da UI coleta contexto e chama função pública do motor PDF;
- o teste chama a mesma função pública com worksheet e metadados preparados;
- testes de formulário validam que a UI passa metadados corretos ao motor.

### 7.3 Suites isoladas

| Suite | Módulo | Escopo | Entra no RVS? |
|---|---|---|---|
| PDF puro | `Teste_V2_PDF.bas` | nomes, pastas, validação, log | Não |
| UI determinística | `Teste_V2_UI.bas` | formulários, seleção e geração em `Testes_UI/<RUN_ID>` | Não |
| Assistido humano | roteiro em docs/auditoria | visual, layout, fallback | Não |

## 8. Ondas 32 a 37

### Onda 32 — Auditoria cruzada PDF/UI e especificação executável

Microdeltas:

- **MD-32.1**: criar prompts 92/93 para Opus e Gemini.
- **MD-32.2**: receber e ler pareceres 95/96.
- **MD-32.3**: publicar esta consolidação 97.

Gate:

- prompts e consolidação com frontmatter;
- índices e relay atualizados;
- nenhum código VBA alterado;
- diff vazio em `src/vba/`, `local-ai/vba_import/` e `doc/`;
- hearback humano para abrir Onda 33.

### Onda 33 — Correção dos relatórios `Rel_Emp_Serv` e `Rel_OSEmpresa`

Microdeltas:

- **MD-33.0**: corrigir instância fantasma nos dois relatórios em
  `Menu_Principal.frm`, sem tocar lógica de negócio.
- **MD-33.1**: documentar procedimento de importação e teste assistido da
  correção.
- **MD-33.2**: se já couber sem ampliar escopo, criar testes isolados mínimos
  para listas não vazias; caso contrário, registrar como entrada obrigatória da
  Onda 36.

Gate:

- readback específico antes do código;
- compile VBE pelo operador;
- `TV2_RunSmoke` verde;
- relatórios exibem listas preenchidas pela interface;
- `git diff --name-only` confirma ausência de alteração nos serviços
  blindados;
- espelho `local-ai/vba_import/` atualizado somente após `src/vba/`.

### Onda 34 — Motor PDF central, pastas, nomeação, fallback e log

Microdeltas:

- **MD-34.0**: criar `Util_PDF.bas` com helpers puros de sanitização, nome,
  raiz, pasta e caminho longo.
- **MD-34.1**: implementar log append-only
  `Documentos_Gerados/_LOG/RPT_PDFs_EMITIDOS.csv`.
- **MD-34.2**: implementar exportação `ExportAsFixedFormat`, validação de
  existência/tamanho/%PDF e fallback manual.
- **MD-34.3**: testes isolados `Teste_V2_PDF.bas` para nome, pasta, colisão,
  CNPJ inválido, workbook não salvo, validação de arquivo e log.

Gate:

- compile VBE;
- suíte PDF isolada verde;
- Smoke verde;
- RVS sem novos contadores;
- teste manual de geração em `Validacao/` com PDF aberto pelo operador;
- nenhum PDF operacional versionado no git.

### Onda 35 — Integração PDF em Pré-OS, OS, Avaliação e Relatórios

Microdeltas:

- **MD-35.0**: integrar PDF automático/fallback em Pré-OS após a persistência
  operacional.
- **MD-35.1**: integrar PDF em OS.
- **MD-35.2**: integrar PDF em Avaliação.
- **MD-35.3**: integrar PDF nos relatórios, incluindo os dois corrigidos na
  Onda 33.
- **MD-35.4**: roteiro humano de validação de nomes, pastas, log e fallback.

Gate:

- teste específico por fluxo alterado;
- Smoke após cada microdelta;
- RVS completo se o fluxo crítico for tocado;
- operador confirma que Pré-OS, OS, Avaliação e Relatórios geram PDFs em
  pastas corretas;
- falha de PDF não desfaz documento persistido.

### Onda 36 — Bateria isolada UI/PDF com simulação de cliques

Microdeltas:

- **MD-36.0**: criar `Teste_V2_UI.bas` e runner `TV2_UI_RunAll`.
- **MD-36.1**: simular abertura/preenchimento dos dois relatórios corrigidos.
- **MD-36.2**: simular geração de PDF para Pré-OS, OS e Avaliação em
  `Documentos_Gerados/Testes_UI/<RUN_ID>/`.
- **MD-36.3**: simular geração de PDF dos relatórios e validar log esperado.
- **MD-36.4**: registrar evidência da suíte UI/PDF sem entrar no RVS.

Gate:

- suíte `TV2_UI_*` verde;
- PDFs gerados em run isolado;
- log CSV contém uma linha por PDF esperado;
- nenhum `MsgBox` ou modal trava a execução;
- RVS canônico permanece com assinatura V205.

### Onda 37 — Jornada humana V206 + RC/freeze

Microdeltas:

- **MD-37.0**: atualizar jornada humana V206 com PDF, fallback, logs e
  segurança de pasta.
- **MD-37.1**: atualizar evidências V206, manifestos e checksums.
- **MD-37.2**: bump de `App_Release.bas`, changelog e release note.
- **MD-37.3**: auditoria final cruzada Opus/Gemini.
- **MD-37.4**: RC/freeze e tag `v12.0.0206`.

Gate:

- RVS completo com assinatura preservada;
- AF1/AF2/AF3 V206 concluídos;
- jornada humana validada por operador;
- PDFs e logs operacionais fora do git;
- tag `v12.0.0206` somente após hearback final.

## 9. Bloqueios e itens fora de escopo

Bloqueios V206:

- alterar RN-01 a RN-17;
- alterar contadores do RVS;
- incluir PDF nas seis baterias do RVS;
- mover ou reorganizar `doc/`;
- tocar `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas` ou
  `Svc_PreOS.bas` sem P0 explícito e hearback humano;
- renomear símbolos internos VBA;
- reescrever importador automático;
- alterar `Mod_Types.bas` para criar contrato PDF paralelo;
- automação externa de clique real em Windows/macOS.

Fora de escopo V206, candidatos V207:

- refatorar `PreenchimentoRel_*` para receber instância opcional;
- mover preenchimento para `UserForm_Initialize`;
- automação externa por `pywinauto`, AppleScript ou ferramenta equivalente;
- agrupamento mensal automático por `AAAA-MM`;
- política automatizada de retenção/rotação de PDFs;
- Word automation para layout rico.

## 10. Próximo readback para implementação

Antes de editar código, abrir readback específico:

```text
0082-onda33-v206-md33-0-fix-relatorios-pdf-precondicao.json
```

Esse readback deve declarar:

- escopo exato: `Menu_Principal.frm` e, se necessário, espelho correspondente
  em `local-ai/vba_import/`;
- objetivo: corrigir instância fantasma em `Rel_OSEmpresa` e `Rel_Emp_Serv`;
- testes: compile VBE, Smoke, dois roteiros assistidos e, se viável, testes
  isolados `TV2_UI_*`;
- bloqueios reafirmados: sem `Svc_*`, sem RN, sem RVS, sem PDF ainda;
- critério de saída: os dois relatórios abrem populados pela interface antes
  de qualquer implementação do motor PDF.
