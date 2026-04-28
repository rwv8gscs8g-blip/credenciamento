---
titulo: ONDA 6 — Consolidacao documental + integracao HBN/Diataxis/llms.txt/AGENTS.md/Glasswing
natureza-do-documento: documento tecnico unico da Onda 6 (sem split em "tecnico + procedimento")
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
build-ancora-validado: f7aa84f+ONDA05-em-homologacao (sem alteracao nesta onda)
data: 2026-04-28
autor: Claude Opus 4.7 (sessao Cowork)
solicitante: Luis Mauricio Junqueira Zanin
diataxis: onda
hbn-track: safe_track
audiencia: ambos
status: em-execucao (aguardando script de cleanup do operador)
documentos-irmaos:
  - auditoria/40_TRANSICAO_RACIONALIZACAO_E_PROMPT_RETOMADA.md (auditoria honesta que motivou esta onda)
  - .hbn/relay/0001-onda06-consolidacao-documental.md (cycle file)
  - .hbn/readbacks/0001-onda06.json (readback estruturado)
---

# 41. ONDA 6 — Consolidacao documental + integracao metodologica

## 0. Resumo executivo (30 segundos)

A Onda 6 fechou a divida documental do Credenciamento e estabeleceu a
metodologia hibrida HBN-core + Diataxis + llms.txt + AGENTS.md +
Glasswing-style como base permanente do projeto. **Sem alteracao de
codigo VBA.** Build do workbook permanece `f7aa84f+ONDA05-em-homologacao`
— Onda 5 segue em homologacao manual.

Em paralelo, o repositorio `usehbn` recebeu 6 documentos novos
formalizando o Credenciamento como o primeiro case study production-scale
de composicao multi-protocolo. O Credenciamento testa o usehbn em
producao; o usehbn aprende.

## 1. Mandato

Mauricio aprovou em 2026-04-28:

1. **Proposta D** (hibrido): HBN-core + Diataxis + llms.txt + AGENTS.md,
   com ajuste — o usehbn passa a ser a propria solucao mista, incorporando
   abertamente os melhores protocolos.
2. **Bastao de implementacao** concedido a Claude Opus 4.7 (Cowork) ate
   V12.0.0203 estavel no GitHub.
3. **Modo execucao maxima** (tokens) autorizado.
4. **Glasswing/Mythos** da Anthropic referenciado como camada de
   seguranca preventiva.
5. **Onda 5 nao re-aberta** — Onda 6 vem antes do retorno ao codigo.
6. **7 duvidas operacionais aprovadas** (todas as 7 respondidas).
7. **Protocolo de execucao em 12 passos aprovado**.

Fonte: chat de 2026-04-28, registro em
`.hbn/readbacks/0001-onda06.json` com `hearback_status: confirmed`.

## 2. Entregas

### 2.1 Em Credenciamento

#### 2.1.1 Estrutura `.hbn/` HBN-native

```
.hbn/
├── relay/
│   ├── INDEX.md                     <- bastao + ciclo ativo
│   └── 0001-onda06-consolidacao-documental.md
├── relay-archive/                   <- vazio inicial
├── knowledge/
│   ├── INDEX.md
│   ├── 0001-regras-v203-inegociaveis.md
│   ├── 0002-regra-ouro-vba-import.md
│   └── 0003-glasswing-style-preventive-security.md
├── readbacks/
│   └── 0001-onda06.json             <- hearback: confirmed
├── results/
│   └── INDEX.md
└── reports/
    └── INDEX.md
```

#### 2.1.2 Mapas para LLMs

- `AGENTS.md` (raiz) — entrada canonica padrao
  [agents.md](https://agents.md/). Substitui a fragmentacao
  CLAUDE.md/.cursorrules/.codex/.copilotignore.
- `llms.txt` (raiz) — mapa curado padrao
  [llmstxt.org](https://llmstxt.org/).
- `llms-full.txt` (raiz) — indice exaustivo de `.md` versionados.

#### 2.1.3 Reorganizacao `auditoria/`

```
auditoria/
├── 00_status/                       <- 00, 22, 24, 26
├── 01_regras_e_governanca/          <- 00_REGRAS_V203_INEGOCIAVEIS (NOVO), 03, 04, 14, 16, 17, 18, 19, 21, 23
├── 02_planos/                       <- 15, 20, 25, 27
├── 03_ondas/
│   ├── onda_01_strikes/             <- 28, 29
│   ├── onda_02_cnae_snapshot/       <- 30, 31
│   ├── onda_03_cnae_dedup/          <- 32, 33
│   ├── onda_04_config_strikes/      <- 34, 35, 36
│   ├── onda_05_form_deterministico/ <- 37, 38
│   └── onda_06_consolidacao_documental/ <- 41 (este arquivo)
├── 04_evidencias/                   <- V12.0.0202/, V12.0.0203/ (movido de auditoria/evidencias/)
├── 40_TRANSICAO_*.md                <- na raiz (sumario cronologico)
└── INDEX.md                         <- atualizado com nova estrutura
```

Numeracao historica preservada como prefixo dentro das subpastas.
Auditoria/39 apagado (consolidado em auditoria/40 secao 4.1, em
local-ai/vba_import/000-REGRA-OURO.md, e em
.hbn/knowledge/0002-regra-ouro-vba-import.md).

#### 2.1.4 Reorganizacao `docs/` em quadrantes Diataxis

```
docs/
├── tutorials/                       <- (a popular nas Ondas 7-9)
├── how-to/
│   └── GUIA_DE_ACESSO_A_MATERIAIS_OPERACIONAIS.md
├── reference/
│   ├── COMPLIANCE_CMMI_ISO.md
│   ├── GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md
│   ├── testes/                      <- migrado de docs/testes
│   ├── licenca/                     <- migrado de docs/licenca
│   └── legal/                       <- migrado de docs/legal
├── explanation/
│   ├── ARQUITETURA.md
│   └── PROPOSTA_TESTES_V2_CENARIO_CANONICO.md
└── INDEX.md                         <- Diataxis-aware
```

#### 2.1.5 Refinamentos

- `CLAUDE.md`: minimal, aponta para `AGENTS.md`. Tabu de `Mod_Types.bas`
  reformulado como "intervencao planejada na Onda 9 com plano dedicado".
- `local-ai/vba_import/README.md`: referencia consolidada a Regra de Ouro,
  nota sobre macros descartaveis fora do pacote oficial.
- `obsidian-vault/00-DASHBOARD.md`: revivido (Opcao A), atualizado para
  Ondas 1-5 + Onda 6, cadencia obrigatoria de update por onda fechada.
- `CHANGELOG.md`: entrada Onda 6 detalhada.
- `README.md`: superficie publica continua valida; mantido sem mudanca
  estrutural (alteracao apenas em links pos-reorganizacao).

#### 2.1.6 Vault Obsidian — metodologia (4 documentos novos)

```
obsidian-vault/metodologia/
├── 00-MAPA-DOCUMENTAL.md            <- 4 camadas, 4 audiencias
├── 01-COMO-A-IA-LE-ESTE-REPO.md     <- guia para o RAG
├── 02-INTEGRACAO-USEHBN.md          <- por que adotamos
└── 03-PROTOCOLO-GLASSWING.md        <- 5 vetores aplicados
```

#### 2.1.7 Cleanup operacional fora do repo

Movidos para `/Users/macbookpro/Projetos/backups/credenciamento/`:

- `backup_bateria_oficial/` (~66 MB)
- `V12-202-{L,M,N,O,P}/` (~15 MB)
- `BKP_forms/` (~1.7 MB)
- `backups/` -> `legacy-backups/` (~36 KB)
- `macros_descartaveis_v0203/` com 5 `.bas` (Diag_Imediato, Diag_Simples,
  Limpa_Base_Total, Reset_CNAE_Total, Set_Config_Strikes_Padrao)

`MAPA_DE_RETORNO.md` em
`Projetos/backups/credenciamento/MAPA_DE_RETORNO.md` documenta como
restaurar artefatos especificos se preciso.

#### 2.1.8 Script de cleanup operacional

`local-ai/scripts/onda06-cleanup.sh` — necessario porque o sandbox
Cowork nao permite `rm`/`mv`/`git rm`/`git mv` no fuse mount. Mauricio
roda no Terminal.app local em ~30 segundos. Idempotente.

### 2.2 Em usehbn (paralelo)

#### 2.2.1 6 documentos novos

```
usehbn/docs/
├── EVOLUTION-POLICY.md              <- categorias A/B/C, hard limits
├── INTEGRATION-DIATAXIS.md          <- categoria A
├── INTEGRATION-LLMS-TXT.md          <- categoria A
├── INTEGRATION-AGENTS-MD.md         <- categoria A
├── INTEGRATION-GLASSWING.md         <- categoria A (extensao project-specific)
└── CASE-STUDY-CREDENCIAMENTO.md     <- vitrine real
```

#### 2.2.2 README.md atualizado

Nova secao "Adopted External Protocols" antes da secao Governance.
Tabela com 4 integracoes formalizadas + link para o case study
Credenciamento.

#### 2.2.3 CHANGELOG.md atualizado

Entrada `Unreleased` lista os 6 documentos novos como integracoes
categoria A formalizadas.

## 3. Decisoes registradas

### 3.1 Bastao de implementacao

Concedido a Claude Opus 4.7 (Cowork) ate V12.0.0203 estavel no GitHub.
Reverte para Codex (apoio) + Claude Opus em modo auditoria apos a
release publica.

Justificativa: a fragmentacao por baton conflict nas Ondas 1-5 (5
macros descartaveis, 1 modulo novo, 13 docs duplicados, mandato de
edicao manual) custou retrabalho. Concentracao de bastao em uma IA
durante a estabilizacao reduz risco de novo drift.

Ratificacao explicita por hearback do Mauricio em 2026-04-28.

### 3.2 Adopcao Diataxis + llms.txt + AGENTS.md como permanente

Categoria A no contrato `usehbn/docs/EVOLUTION-POLICY.md`. Reversivel,
mas documentada como permanente para a linha V12.0.0203+.

### 3.3 Glasswing-style preventive security

5 vetores domain-specific (G1-G5) documentados em
`.hbn/knowledge/0003-glasswing-style-preventive-security.md`. Onda 7
entregara `local-ai/scripts/glasswing-checks.sh` automatizando G1 e
G5; G2-G4 sao verificados por inspecao manual ate la.

### 3.4 Frontmatter YAML obrigatorio

Todo `.md` versionado neste repositorio deve abrir com `titulo`,
`diataxis`, `hbn-track`, `audiencia`, `versao-sistema`, `data`. Onda 6
adicionou frontmatter em todos os documentos novos. Retrofit dos
documentos existentes em `auditoria/` e `docs/` e tarefa da Onda 7
(opcional) ou Onda 9 (junto com docs narradas dos testes).

### 3.5 macros descartaveis fora de `vba_import/`

Regra absoluta a partir da Onda 6: macros descartaveis na raiz de
`vba_import/` quebram a Regra de Ouro. Diag_Imediato sera reintroduzido
na Onda 7 como cenario `RDZ_DIAG_001` automatizado.

### 3.6 `Mod_Types.bas` — proibicao reformulada

A "proibicao absoluta" anterior bloqueava trabalho legitimo. Nova
formulacao: intervencao planejada na **Onda 9** com plano dedicado e
aprovacao previa do Mauricio.

### 3.7 Repositorio publico < 10 MB

Meta de tamanho para a release V12.0.0203. Atual com Onda 6 fechada
(antes do operador rodar o cleanup script): ~80 MB de backups ainda
locais; depois do script: < 10 MB.

## 4. Invariantes preservados

- Codigo VBA em `src/vba/` NAO foi tocado.
- `Mod_Types.bas` NAO foi tocado.
- Build do workbook permanece `f7aa84f+ONDA05-em-homologacao`.
- Onda 5 nao foi re-aberta.
- Trio minimo nao foi re-executado nesta onda (responsabilidade do
  operador no workbook).
- Nenhum push para origin.

## 5. Out-of-scope (deixado para ondas futuras)

- Cenarios IDM_* + RDZ_* automatizados — Onda 7.
- Heuristica zero em todos os 13 forms — Onda 8.
- Reescrita Importador_VBA + auditoria Mod_Types — Onda 9.
- Promocao da V12.0.0203 para release oficial — fechamento, apos Onda 9.
- Push para origin — decisao de Mauricio.

## 6. Riscos residuais

| Risco | Mitigacao |
|---|---|
| Script de cleanup falha parcialmente | script e idempotente; rodar de novo |
| Algum link cruzado nao detectado quebrado | grep amplo no checklist final + git status mostra orfaos |
| Frontmatter YAML invalido em algum arquivo novo | validacao manual em SAMPLE de 3 arquivos antes de aplicar (feita) |
| Onda 5 ainda em homologacao confunde IAs futuras | `.hbn/relay/INDEX.md` deixa claro que Onda 5 e residual |
| Vault Obsidian volta a desatualizar | cadencia obrigatoria documentada no proprio dashboard |

## 7. Procedimento operacional de fechamento

Mauricio executa, na seguinte ordem, no Terminal.app local:

```bash
cd /Users/macbookpro/Projetos/Credenciamento

# 1. Conferir o que sera alterado:
bash local-ai/scripts/onda06-cleanup.sh --dry-run

# 2. Executar:
bash local-ai/scripts/onda06-cleanup.sh

# 3. Conferir resultado:
git status
ls auditoria/
ls docs/

# 4. Commit isolado:
git add -A
git commit -m "onda(06): consolidacao documental + integracao HBN/Diataxis/llms.txt/AGENTS.md/Glasswing

doc-only (sem alteracao de codigo VBA). build f7aa84f+ONDA05-em-homologacao mantido.
Detalhes em auditoria/03_ondas/onda_06_consolidacao_documental/41_TECNICO.md

Co-Authored-By: Claude Opus 4.7 (Cowork) <noreply@anthropic.com>"

# 5. NAO push para origin sem revisao final.

# 6. Em caso de regret:
git reset --hard pre-onda-06-2026-04-28
```

## 8. Verificacao final

Apos o operador rodar o script + commitar:

```bash
# 8.1 Hash bate em todos os modulos:
for f in src/vba/*.bas; do
  base=$(basename "$f")
  pkg=$(ls local-ai/vba_import/001-modulo/A??-$base 2>/dev/null)
  [ -n "$pkg" ] && diff -q "$f" "$pkg" || echo "DIVERGE: $base"
done

# 8.2 Nenhuma referencia a auditoria/39:
grep -rn "auditoria/39_" .

# 8.3 Nenhuma macro descartavel na raiz de vba_import:
ls local-ai/vba_import/*.bas | grep -v -E "(Importador_VBA|Importar_Agora)\.bas$"

# 8.4 Tamanho do repo publico:
du -sh . --exclude=.git
# Alvo: < 10 MB

# 8.5 Trio minimo ainda valido (executar no workbook do operador):
# - Teste_Validacao_Release.CT_ValidarRelease_TrioMinimo
# - Conferir CSV em auditoria/04_evidencias/V12.0.0203/
```

## 9. Proximos passos

Apos confirmacao do operador:

1. Atualizar `.hbn/results/0002-exec-onda06.json` com ERP final
   (`outcome: executed`, `human_status: confirmed`).
2. Mover `.hbn/relay/0001-onda06-consolidacao-documental.md` para
   `.hbn/relay-archive/0001-onda06-consolidacao-documental.md`.
3. Atualizar `.hbn/relay/INDEX.md` com proximo ciclo (Onda 7 ou
   homologacao residual da Onda 5).
4. Aguardar mandato explicito do Mauricio para abrir Onda 7.

## 10. Conclusao

A Onda 6 entregou consolidacao documental e a integracao metodologica
de 4 protocolos abertos com o HBN como base. O Credenciamento agora e
uma vitrine real do `usehbn` em producao, e o `usehbn` recebeu seu
primeiro contrato formal de evolucao (`docs/EVOLUTION-POLICY.md`).

Sem alteracao de codigo. Build do workbook intocado. Onda 5 segue em
homologacao do Mauricio. O caminho para o fechamento publico da
V12.0.0203 esta agora estruturado em 4 ondas restantes: 5 (homologacao
residual), 7, 8, 9, fechamento publico.

Bastao com Claude Opus 4.7 (Cowork) ate la.
