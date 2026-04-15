# Estrategia de Retomada — V12.0.0106+

**Data:** 10/04/2026
**Base Operacional:** V12-093 (PlanilhaCredenciamento-Homologacao.xlsm)
**Status:** COMPILADA E FUNCIONAL
**Proxima Release:** V12.0.0106

---

## 1. DIAGNOSTICO: Por que o erro "Nome repetido: TConfig" persiste

### 1.1 O que foi descartado (comprovado por evidencia)

| Hipotese | Teste Realizado | Resultado |
|----------|-----------------|-----------|
| Ghost types no binario (vbaProject.bin corrupto) | Workbook virgem sem VBA | Erro persiste → DESCARTADA |
| Encoding UTF-8 vs CP1252 | Convertemos todos .bas/.frm para CP1252 | Erro persiste → DESCARTADA |
| EOF/CRLF incorreto | Normalizado CRLF+CRLF em todos | Erro persiste → DESCARTADA |
| VB_Name duplicado nos .bas | Verificado: 28 nomes unicos em 28 arquivos | DESCARTADA |
| Definicao duplicada de Public Type | Grep completo: TConfig definido APENAS em Mod_Types.bas | DESCARTADA |
| Colon patterns (Dim X As T: X = v) | Grep completo: ZERO colon patterns no vba_export atual | DESCARTADA |
| Operacoes FileSystem nativas (MkDir/Kill/Dir) | Grep completo: ZERO ocorrencias | DESCARTADA |

### 1.2 O que sabemos com certeza

- **V12-093 COMPILA** — mesmos 12 tipos, mesmo Mod_Types.bas (identico byte a byte), mesmo encoding UTF-8, mesmos formularios
- **V12-093 tem 27 modulos .bas + 13 .frm** e funciona
- **A versao quebrada tem 28 modulos .bas + 13 .frm** (um modulo a mais: Util_CNAE.bas) e AppContext renomeado para Mod_AppContext

### 1.3 Diferenca exata entre V12-093 (funciona) e V12-105 (quebrada)

Arquivos IDENTICOS (sem nenhuma alteracao):
Mod_Types.bas, Classificar.bas, Const_Colunas.bas, Central_Testes.bas, Central_Testes_Relatorio.bas, ErrorBoundary.bas, Funcoes.bas, Preencher.bas, Repo_Avaliacao.bas, Repo_Credenciamento.bas, Repo_Empresa.bas, Repo_PreOS.bas, Svc_Avaliacao.bas, Svc_PreOS.bas, Svc_Rodizio.bas, Teste_UI_Guiado.bas, Treinamento_Painel.bas, Util_Config.bas, Util_Conversao.bas, Util_Planilha.bas, Variaveis.bas e todos os 13 formularios (.frm) exceto 4.

Arquivos MODIFICADOS:
- Auto_Open.bas — adicionada chamada CNAE no InicializarSistema
- Audit_Log.bas — pequena modificacao (+174 bytes)
- Repo_OS.bas — pequena modificacao (+306 bytes)
- Svc_OS.bas — pequena modificacao (+8 bytes)
- Teste_Bateria_Oficial.bas — pequena modificacao (+163 bytes)
- Cadastro_Servico.frm — adicionado filtro de busca (+1200 bytes)
- Reativa_Empresa.frm — adicionado filtro de busca (+1402 bytes)
- Reativa_Entidade.frm — adicionado filtro de busca (+1324 bytes)
- Menu_Principal.frm — modificacao minima (+8 bytes, MAS ainda tem 2 colon patterns da V12-093)

Arquivos NOVOS (nao existem na V12-093):
- Util_CNAE.bas — modulo inteiro novo
- Mod_AppContext.bas — renomeado de AppContext.bas (VB_Name alterado)

Arquivo REMOVIDO:
- AppContext.bas — substituido por Mod_AppContext.bas

### 1.4 Hipotese mais provavel (nao confirmada)

O erro "Nome repetido: TConfig" e um **erro cascata falso** do compilador VBA. Conforme documentado em REGRAS_COMPILACAO_VBA.md, o VBA reporta este erro especifico quando o problema REAL esta em outro modulo. A causa provavel e uma das seguintes, que devem ser testadas UMA POR UMA:

1. **Rename de AppContext → Mod_AppContext** pode causar conflito interno no compilador se algum modulo/form ainda referencia `AppContext.XXX` com o nome antigo
2. **Util_CNAE.bas** pode conter algum padrao que o compilador VBA do Windows interpreta diferente do esperado
3. **Interacao entre os .frm modificados** e os novos modulos pode gerar o cascata

O plano de microevolucao vai isolar qual mudanca causa o problema.

---

## 2. DECISAO: Retomada pela V12-093

### Base operacional
- **Arquivo:** `PlanilhaCredenciamento-Homologacao.xlsm` (raiz do projeto)
- **Confirmado:** Hash identico ao V12-093 original
- **VBA:** 27 modulos + 13 formularios, COMPILA sem erros
- **Tamanho:** 1.6 MB (vbaProject.bin = 6.2 MB interno — grande mas funcional)

### O que funciona na V12-093 (testado e homologado)
- Compilacao VBA limpa
- Auto_Open → Menu_Principal
- Credenciamento de empresa (form completo)
- Alteracao/Inativacao/Reativacao de empresa
- Cadastro de servico
- Entidade e vinculacao
- Rodizio de empresas (algoritmo completo)
- Pre-OS (emissao, aceite, recusa, expiracao)
- OS (criacao, conclusao)
- Avaliacao com suspensao automatica
- Audit Log
- Central de Testes (menu V11)
- Bateria automatizada (~60 testes)
- Relatorios com auto-filtro
- Campos de busca em Menu_Principal (empresa e entidade)

### O que FALTA implementar (originalmente na V12-105)
1. CNAE: importacao automatica de base de servicos (Util_CNAE.bas)
2. Filtros de busca em: Reativa_Empresa, Reativa_Entidade, Cadastro_Servico
3. Melhorias menores em Audit_Log, Repo_OS, Svc_OS
4. Testes adicionais em Teste_Bateria_Oficial

---

## 3. PROPOSTA ANTI-REGRESSAO

### 3.1 Problema identificado

Nos ultimos 3 meses, multiplas IAs (Cursor, GPT-5.2, Claude, Gemini) trabalharam no projeto sem contexto compartilhado. Cada uma:
- Fez modificacoes sem entender o impacto no compilador VBA
- Reintroduziu bugs ja corrigidos (colon patterns, chamadas nao qualificadas)
- Pediu reimportacoes cegas sem diagnostico
- Nao respeitou as regras documentadas em REGRAS_COMPILACAO_VBA.md

### 3.2 Solucao: Obsidian como Base de Conhecimento Centralizada

**Por que Obsidian:**
- Markdown puro (versionavel com Git)
- Links bidirecionais entre documentos (backlinks)
- Graph view para visualizar dependencias
- Templates para padronizar documentacao
- Plugins: Dataview (queries em docs), Git (sync automatico), Kanban (backlog visual)
- Funciona offline, sem dependencia de cloud
- Integravel com Claude via MCP ou copiar-colar de contexto

**Estrutura proposta do vault Obsidian:**

```
Credenciamento-Vault/
├── 00-Dashboard.md                    ← Pagina inicial com status
├── 01-Arquitetura/
│   ├── Visao-Geral.md
│   ├── Modulos.md                     ← Lista de todos modulos com status
│   ├── Formularios.md
│   ├── Tipos.md                       ← Todos os Public Types
│   └── Fluxos-Negocio.md
├── 02-Regras/
│   ├── Regras-Compilacao-VBA.md       ← Killer patterns, obrigatorio
│   ├── Regras-Governanca.md           ← 1 arquivo por iteracao, etc
│   └── Checklist-Pre-Deploy.md        ← Verificacoes antes de importar
├── 03-Releases/
│   ├── V12-093.md                     ← Base estavel
│   ├── V12-106.md                     ← Proxima release
│   └── Template-Release.md
├── 04-Backlog/
│   ├── CNAE-Import.md
│   ├── Filtros-Busca-Forms.md
│   ├── Impressao-Relatorios.md
│   └── Testes-UI-Navegacao.md
├── 05-Bugs-Resolvidos/
│   ├── Nome-Repetido-TConfig.md       ← Historico completo
│   ├── Colon-Patterns.md
│   └── Ghost-Types.md
└── 06-Handoff/
    ├── Contexto-Para-IA.md            ← Prompt base para qualquer IA
    └── Historico-Decisoes.md
```

### 3.3 Regras de versionamento

1. **Git no vault Obsidian** — commit automatico a cada mudanca (plugin Obsidian Git)
2. **Git no projeto VBA** — commit em vba_export/ a cada release que compila
3. **Nunca editar vba_export sem release note** — toda mudanca tem V12.0.XXXX
4. **Tag Git por release** — `git tag v12.0.0106` apos confirmacao de compilacao
5. **Branch por feature** — isolar mudancas experimentais

### 3.4 Checklist Pre-Deploy (obrigatorio antes de qualquer importacao)

```bash
# 1. Colon patterns (deve retornar VAZIO)
grep -rn "Dim .* As .*:.*=" vba_export/*.bas vba_export/*.frm

# 2. FileSystem nativo (deve retornar VAZIO)
grep -rn "MkDir\|^\s*Kill \| Dir(" vba_export/*.bas vba_export/*.frm

# 3. VB_Names duplicados (deve retornar VAZIO)
grep -rh "Attribute VB_Name" vba_export/*.bas vba_export/*.frm | sort | uniq -d

# 4. Tipos duplicados (deve retornar VAZIO)
grep -rn "Public Type" vba_export/*.bas | awk -F: '{print $NF}' | sort | uniq -d

# 5. Encoding check (todos devem ser CRLF)
file vba_export/*.bas vba_export/*.frm | grep -v "CRLF"
```

---

## 4. PLANO DE MICRODESENVOLVIMENTO

### Principios
- **1 mudanca por iteracao**
- **Compilacao obrigatoria** apos cada mudanca
- **Se nao compilar: reverter imediatamente** e documentar
- **Release note** para cada iteracao
- **Backup antes de cada mudanca** (copiar .xlsm)

### Fase 0 — Estabilizacao Imediata (HOJE)

| Passo | Acao | Validacao |
|-------|------|-----------|
| 0.1 | Confirmar que PlanilhaCredenciamento-Homologacao.xlsm abre e compila | Depurar > Compilar = OK |
| 0.2 | Rodar Auto_Open → Menu_Principal abre | Visual |
| 0.3 | Testar credenciamento basico de empresa | Form funciona |
| 0.4 | Testar Pre-OS + Rodizio | Fluxo completo |
| 0.5 | Marcar como V12.0.0106 — "Base Estavel Retomada" | Release note |

### Fase 1 — Funcionalidades Criticas (1 por iteracao)

| Release | Mudanca | Arquivo | Risco |
|---------|---------|---------|-------|
| V12.0.0107 | CNAE: adicionar Util_CNAE.bas ao projeto | Util_CNAE.bas (NOVO) | MEDIO — modulo novo, testar compilacao isolada |
| V12.0.0108 | CNAE: integrar chamada em Auto_Open.bas | Auto_Open.bas (MODIFICAR) | BAIXO — apenas adicionar chamada |
| V12.0.0109 | Filtro busca em Reativa_Empresa.frm | Reativa_Empresa.frm (MODIFICAR) | BAIXO — alteracao em form existente |
| V12.0.0110 | Filtro busca em Reativa_Entidade.frm | Reativa_Entidade.frm (MODIFICAR) | BAIXO — alteracao em form existente |
| V12.0.0111 | Filtro busca em Cadastro_Servico.frm | Cadastro_Servico.frm (MODIFICAR) | BAIXO — alteracao em form existente |
| V12.0.0112 | Melhorias Audit_Log.bas | Audit_Log.bas (MODIFICAR) | BAIXO — pequena modificacao |
| V12.0.0113 | Melhorias Repo_OS.bas | Repo_OS.bas (MODIFICAR) | BAIXO — pequena modificacao |
| V12.0.0114 | Melhorias Svc_OS.bas | Svc_OS.bas (MODIFICAR) | BAIXO — pequena modificacao |
| V12.0.0115 | Testes adicionais | Teste_Bateria_Oficial.bas (MODIFICAR) | BAIXO — apenas testes |

**ATENCAO ESPECIAL na V12.0.0107:** Se Util_CNAE.bas causar "Nome repetido: TConfig", sabemos que ESTE modulo e o gatilho. Nesse caso, investigar especificamente o que no codigo do Util_CNAE causa o cascata.

### Fase 2 — Funcionalidades Pendentes

| Release | Funcionalidade |
|---------|---------------|
| V12.0.0116+ | Impressao de relatorios (aplicar prompt de formatacao) |
| V12.0.0117+ | Testes de UI: navegacao assistida |
| V12.0.0118+ | Dicas: roteiro rapido interativo |
| V12.0.0119+ | Configuracao expandida (UF, Secretaria, Pasta) |

### Fase 3 — Producao

| Passo | Acao |
|-------|------|
| 3.1 | Bateria completa de testes (~60 cenarios) |
| 3.2 | Testes com dados reais do municipio |
| 3.3 | Gerar versao de producao |
| 3.4 | Documentacao de usuario |

---

## 5. ESTRUTURA LIMPA DO PROJETO

```
Credenciamento/
├── PlanilhaCredenciamento-Homologacao.xlsm  ← PLANILHA ATIVA (V12-093)
├── cnae_servicos_normalizado.csv            ← Base CNAE para importacao
├── ESTRATEGIA-V12-106.md                   ← ESTE DOCUMENTO
├── HANDOFF.md                              ← Contexto para IAs
├── .cursorrules                            ← Regras para Cursor
├── .gitignore
│
├── V12-093/                                ← BACKUP da base estavel
│   ├── *.xlsm                              ← Copia integral
│   └── vba_export_bkp/                     ← Codigo fonte backup
│
├── vba_export/                             ← FONTE DE VERDADE (codigo VBA)
│   ├── *.bas (27 modulos)
│   └── *.frm (13 formularios)
│
├── vba_import/                             ← Pacote de deploy (gerado por script)
├── scripts/                                ← Scripts utilitarios
├── ai-context/                             ← Documentacao tecnica
├── release-notes/                          ← Historico de releases
├── doc/                                    ← Documentacao adicional
└── historico/                              ← Versoes antigas e artefatos descartados
    ├── V12-050/ V12-079/ V12-083/ V12-091/ V12-105-Quebrada/
    ├── versoes/ backup_bateria_oficial/ vba_export_broken_v104/
    └── *.md (documentos historicos)
```

---

## 6. REGRAS PARA QUALQUER IA QUE ASSUMA O PROJETO

1. **LEIA** `REGRAS_COMPILACAO_VBA.md` ANTES de qualquer modificacao
2. **LEIA** este documento (`ESTRATEGIA-V12-106.md`) para entender o contexto
3. **NUNCA** faca mais de 1 modificacao por iteracao
4. **NUNCA** peca reimportacao sem diagnostico completo
5. **NUNCA** renomeie modulos (VB_Name) sem testar compilacao isolada
6. **NUNCA** use colon patterns: `Dim x As T: x = v`
7. **NUNCA** use MkDir, Kill, Dir() nativo — use FSO late-binding
8. **SEMPRE** rode o checklist pre-deploy antes de qualquer importacao
9. **SEMPRE** crie release note para cada mudanca
10. **SEMPRE** faca backup do .xlsm antes de modificar
11. **SE** o erro "Nome repetido" aparecer, **NAO** assuma que e encoding/ghost types — e quase certamente um erro cascata causado por outro modulo
12. **A instrucao "nao apagar declaracoes publicas" e sobre NUNCA remover** funcoes/subs/types Public existentes, pois outros modulos podem depender deles

---

## 7. ACAO IMEDIATA — PARA A REUNIAO DE HOJE

A `PlanilhaCredenciamento-Homologacao.xlsm` na raiz do projeto e a V12-093 funcional e homologada. Ela esta pronta para apresentacao com todas as funcionalidades core:

- Credenciamento completo de empresas
- Rodizio automatico
- Pre-OS e OS
- Avaliacoes e suspensoes
- Auditoria
- Central de testes
- Relatorios

**O que nao estara disponivel na apresentacao:** importacao CNAE automatica e filtros de busca nos formularios de reativacao. Essas funcionalidades serao adicionadas nas proximas microevolucoes (V12.0.0107+).

**Para iniciar:** Abra o arquivo, habilite macros, o menu principal aparecera automaticamente.
