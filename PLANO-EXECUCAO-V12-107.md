# PLANO DE EXECUCAO — Reestruturacao Completa + V12.0.0107

**Data:** 10/04/2026
**Autor:** Claude Opus 4.6
**Para aprovacao de:** Mauricio
**Objetivo:** Executar em uma unica passagem a reestruturacao total do projeto, produzir handoff para IAs subsequentes, e entregar V12.0.0107 pronta para microevolucoes.

---

## VISAO GERAL

```
ESTADO ATUAL                          ESTADO FINAL
─────────────────                     ──────────────────
Git: 208 arquivos sujos               Git: commit limpo V12.0.0107
Obsidian: nao existe                  Obsidian: vault completo
Docs: espalhados em ai-context/       Docs: Obsidian vault organizado
Versao: "V12-093" informal            Versao: V12.0.0107 oficial
Handoff: HANDOFF.md basico            Handoff: prompts prontos por IA
SaaS: nao documentado                 SaaS: arquitetura preparada
```

---

## ETAPAS DE EXECUCAO (ordem sequencial)

### ETAPA 1 — Criar Vault Obsidian (estrutura de pastas + conteudo)

**O que:** Criar a pasta `obsidian-vault/` na raiz do projeto que funciona simultaneamente como:
- Vault Obsidian (abrir no app para navegar com backlinks e graph view)
- Documentacao versionada no Git (markdown puro)
- Contexto para qualquer IA (ler arquivos diretamente)

**Estrutura:**

```
obsidian-vault/
├── .obsidian/                          ← Config do Obsidian (templates, plugins)
│   ├── app.json
│   ├── appearance.json
│   └── templates/
│       ├── Template-Release-Note.md
│       ├── Template-Iteracao.md
│       └── Template-Bug-Report.md
│
├── 00-DASHBOARD.md                     ← Pagina inicial com status do projeto
├── 01-CONTEXTO-IA.md                   ← Prompt base que TODA IA deve ler primeiro
│
├── arquitetura/
│   ├── Visao-Geral.md                  ← O que e o sistema, para quem, por que
│   ├── Modulos-VBA.md                  ← Lista de 27 modulos com responsabilidade
│   ├── Formularios.md                  ← Lista de 13 forms com funcionalidade
│   ├── Tipos-Publicos.md              ← Os 12 Public Types com campos
│   ├── Fluxos-de-Negocio.md           ← Rodizio, Pre-OS, OS, Avaliacao
│   ├── Mapa-Dependencias.md           ← Quem chama quem
│   └── SaaS-Roadmap.md                ← Visao de migracao Excel→SaaS
│
├── regras/
│   ├── Compilacao-VBA.md               ← Killer patterns (colon, MkDir, Dir)
│   ├── Governanca.md                   ← 1 arquivo por iteracao, backup, etc
│   ├── Checklist-Pre-Deploy.md         ← Verificacoes obrigatorias
│   ├── Anti-Regressao.md              ← Protocolo para evitar ciclos
│   └── Orquestracao-IAs.md            ← Como diferentes IAs colaboram
│
├── releases/
│   ├── V12.0.0107.md                   ← Release inaugural do novo ciclo
│   └── (futuras releases aqui)
│
├── backlog/
│   ├── CNAE-Import.md                  ← V12.0.0108
│   ├── Filtros-Busca-Forms.md          ← V12.0.0109-111
│   ├── Impressao-Relatorios.md         ← Futuro
│   ├── Testes-UI-Navegacao.md          ← Futuro
│   └── SaaS-Fase1.md                  ← Futuro
│
├── historico/
│   ├── Bug-Nome-Repetido-TConfig.md    ← Documentacao completa do bug
│   ├── Colon-Patterns.md              ← 34 patterns que quebraram compilacao
│   └── Decisoes-Arquiteturais.md      ← Por que cada decisao foi tomada
│
└── handoff/
    ├── Prompt-Codex.md                 ← Prompt completo para OpenAI Codex
    ├── Prompt-Sonnet.md                ← Prompt completo para Claude Sonnet
    ├── Prompt-Opus.md                  ← Prompt completo para Claude Opus
    └── Prompt-Generico.md             ← Prompt para qualquer IA
```

**Por que Obsidian e nao outra ferramenta:**
- Markdown puro = Git-friendly, IA-friendly, humano-friendly
- Backlinks entre documentos = navegacao por relacoes (ex: clicar em "TConfig" leva ao doc de tipos)
- Graph view = visualizar dependencias entre modulos/docs
- Funciona offline, sem assinatura
- Plugins disponiveis: Git (auto-commit), Dataview (queries), Kanban (backlog)

---

### ETAPA 2 — Preparar Git para commit limpo

**O que:** Reorganizar o repositorio Git para o commit inaugural V12.0.0107.

**Acoes:**
1. Atualizar `.gitignore` para incluir: `historico/`, `V12-093/`, `.DS_Store`, `*.xlsm`
2. Mover conteudo relevante de `ai-context/` para dentro do `obsidian-vault/`
3. Manter `ai-context/` como link simbolico ou redirect para `obsidian-vault/` (compatibilidade)
4. Limpar release-notes antigas (manter no obsidian-vault/historico)
5. Staging seletivo: apenas arquivos da nova estrutura

**Estrutura final no Git:**

```
credenciamento/
├── .gitignore
├── .cursorrules
├── README.md                           ← NOVO: visao geral do projeto para GitHub
├── HANDOFF.md                          ← Contexto rapido
├── cnae_servicos_normalizado.csv
├── vba_export/                         ← FONTE DE VERDADE (27 .bas + 13 .frm)
├── vba_import/                         ← Pacote de deploy (gitignored ou gerado)
├── scripts/
│   └── publicar_vba_import.sh
├── obsidian-vault/                     ← TODA documentacao aqui
│   └── (estrutura completa acima)
└── doc/                                ← Documentos auxiliares
```

---

### ETAPA 3 — Documentar arquitetura SaaS-ready

**O que:** Adicionar no obsidian-vault a visao de que a planilha e porta de entrada/saida para um SaaS futuro.

**Conteudo do `SaaS-Roadmap.md`:**
- Principio: dados 100% normalizados na planilha = prontos para migracao
- Mapeamento: aba Excel → tabela SQL (EMPRESAS→empresas, ENTIDADE→entidades, etc.)
- API de importacao: planilha → SaaS (upload + parse)
- API de exportacao: SaaS → planilha (download .xlsm com dados do usuario)
- Garantia de reversibilidade: usuario sempre pode voltar para planilha
- Apontamento para pasta do SaaS (voce indica o caminho)

---

### ETAPA 4 — Criar prompts de handoff para cada IA

**O que:** Documentos prontos para copiar-colar que dao contexto completo a qualquer IA.

**Prompt Codex (OpenAI):**
- Focado em: modificar 1 arquivo .bas por vez, rodar checklist, gerar release note
- Inclui: regras de compilacao, estrutura do projeto, ultimo estado
- Formato: prompt unico de ~2000 tokens

**Prompt Sonnet/Opus (Claude):**
- Focado em: analise mais profunda, refatoracao, documentacao
- Inclui: tudo do Codex + contexto de negocio + anti-regressao
- Formato: prompt com arquivo de contexto

**Prompt Generico:**
- Para qualquer IA (Gemini, GPT, etc.)
- Minimo necessario para nao quebrar o projeto

---

### ETAPA 5 — Commit e push V12.0.0107

**O que:** Commit inaugural do novo ciclo com TUDO organizado.

**Mensagem de commit:**
```
feat(v12.0.0107): reestruturacao completa do projeto

- Base estavel V12-093 (compilada e homologada)
- Vault Obsidian com documentacao completa
- Regras anti-regressao para orquestracao multi-IA
- Arquitetura SaaS-ready documentada
- Prompts de handoff para Codex/Sonnet/Opus
- Historico organizado, workspace limpo
```

---

### ETAPA 6 — Validacao final

**O que:** Verificar que tudo esta consistente.

- [ ] vba_export/ identico a V12-093 (ja confirmado)
- [ ] Obsidian vault abre corretamente no app
- [ ] Git push sucesso
- [ ] Prompts de handoff testados (leitura)
- [ ] Dashboard do Obsidian reflete estado real

---

## SOBRE A IMPLEMENTACAO

**Quem faz o que:**

| Etapa | Executor | Motivo |
|-------|----------|--------|
| 1. Vault Obsidian | Claude Opus (eu, agora) | Tenho acesso direto aos arquivos e conhecimento completo do projeto |
| 2. Git cleanup | Claude Opus (eu, agora) | Precisa de acesso ao filesystem |
| 3. SaaS-Roadmap | Claude Opus (eu, agora) | Documentacao baseada no que discutimos |
| 4. Prompts handoff | Claude Opus (eu, agora) | Eu conheco o contexto melhor que qualquer outra IA neste momento |
| 5. Git commit/push | Claude Opus (eu, agora) | Tudo pronto, commit unico |
| 6. Validacao | Mauricio | Abrir Obsidian, verificar no GitHub |
| V12.0.0108+ | Codex/Sonnet via prompt | Microevolucoes com handoff |

**Estimativa:** Consigo executar as etapas 1-5 nesta sessao. Voce valida (etapa 6) e depois usa os prompts para dar continuidade com qualquer IA.

---

## DECISAO NECESSARIA

Antes de executar, preciso de:

1. **Aprovacao do plano acima** — posso executar tudo de uma vez?
2. **Caminho da pasta SaaS** — voce mencionou que pode apontar. Qual o caminho?
3. **GitHub push** — posso fazer push direto para `main` ou prefere que eu crie uma branch `v12.0.0107-restructure`?

Aguardo seu OK para executar.
