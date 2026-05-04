---
titulo: Mapa documental do Credenciamento
ultima-atualizacao: 2026-04-28
diataxis: explanation
hbn-track: fast_track
audiencia: ambos
versao-sistema: V12.0.0203
---

# Mapa documental do Credenciamento

> Como a documentacao deste projeto esta organizada, e por que.

## Quatro camadas, quatro audiencias

A documentacao esta dividida em **quatro camadas**, cada uma com uma
audiencia primaria, formato e ciclo de atualizacao distintos.

### Camada 1 — Coordenacao inter-IA (`.hbn/`)

| Audiencia | IAs em ciclo de execucao |
|---|---|
| Formato | Markdown + JSON estruturado |
| Atualizacao | Cada onda |
| Contrato | [HBN protocol 0.2.x](https://usehbn.org) |

Conteudo:

- `relay/INDEX.md` — quem tem o bastao, qual e a proxima acao
- `relay/0001-onda06...md` — ciclo ativo
- `relay-archive/` — ondas resolvidas
- `knowledge/0001..0003-...md` — decisoes reutilizaveis (regras V203,
  regra de ouro, Glasswing)
- `readbacks/0001-onda06.json` — snapshots antes de execucao safe_track
- `results/0001-exec-onda06.json` — ERPs vinculados a readbacks
- `reports/INDEX.md` — saidas humanas concisas

Quem le: toda IA que entrar no projeto, antes de qualquer acao.

### Camada 2 — Documentacao Diataxis (`docs/`)

| Audiencia | Humanos (operadores, contribuidores, auditores externos) |
|---|---|
| Formato | Markdown |
| Atualizacao | A cada release com nova superficie publica |
| Contrato | [Diataxis framework](https://diataxis.fr/) |

Conteudo:

- `docs/tutorials/` — aprender (passo-a-passo, mao na massa)
- `docs/how-to/` — problema concreto (cookbook)
- `docs/reference/` — consulta (regras, API VBA, governanca, testes)
- `docs/explanation/` — entender (arquitetura, decisoes, racional V2)

Quem le: humano que abriu o repo pela primeira vez, ou que precisa
fazer uma acao especifica.

### Camada 3 — Auditoria publica (`auditoria/`)

| Audiencia | Auditores externos, integradores municipais |
|---|---|
| Formato | Markdown numerado cronologicamente |
| Atualizacao | A cada onda + a cada decisao publica |
| Contrato | numeracao continua + frontmatter YAML |

Conteudo (pos-Onda 6):

- `00_status/` — snapshots de estado (22, 24, 26, 40)
- `01_regras_e_governanca/` — regras canonicas (00 inegociaveis, 03
  regras de negocio, 17 licenciamento, etc.)
- `02_planos/` — planos de execucao (15, 20, 25, 27)
- `03_ondas/onda_NN_<tema>/` — documentacao tecnica de cada onda
- `04_evidencias/V12.x.xxxx/` — CSVs e manifestos hashados por release

Quem le: alguem auditando uma decisao tecnica historica.

### Camada 4 — Vitrine institucional (`obsidian-vault/`)

| Audiencia | Humanos institucionais (gestores, terceiros, midia) |
|---|---|
| Formato | Markdown navegavel em Obsidian |
| Atualizacao | A cada onda fechada (cadencia obrigatoria) |
| Contrato | Frontmatter `tags: [vivo|congelado]` + links wiki-style |

Conteudo:

- `00-DASHBOARD.md` — status executivo
- `MANIFEST.md` — manifesto do vault
- `releases/STATUS-OFICIAL.md` — status oficial das versoes
- `releases/V12.0.0202.md` — release atual
- `releases/historico/` — releases anteriores
- `metodologia/` — esta camada (00 mapa, 01 RAG, 02 usehbn, 03 Glasswing)

Quem le: alguem que quer entender o projeto SEM mergulhar em codigo.

## Fluxo de leitura por perfil

### Perfil 1 — IA nova chegando

```
1. AGENTS.md (raiz)
2. .hbn/relay/INDEX.md
3. .hbn/knowledge/0001..0003-*.md
4. (acao especifica) -> docs/how-to/ ou docs/reference/
```

### Perfil 2 — Humano operador

```
1. README.md
2. obsidian-vault/00-DASHBOARD.md
3. docs/tutorials/ (se primeira vez)
4. docs/how-to/<acao> (se sabe o que quer)
```

### Perfil 3 — Auditor externo

```
1. README.md (posicionamento publico)
2. LICENSE + CLA.md + SECURITY.md
3. auditoria/01_regras_e_governanca/00_REGRAS_V203_INEGOCIAVEIS.md
4. auditoria/04_evidencias/V12.0.0202/MANIFEST.md
5. auditoria/03_ondas/onda_NN/ (mergulho tecnico se necessario)
```

### Perfil 4 — LLM em consulta one-shot

```
1. llms.txt (mapa curado)
2. (segue links que matchem com a query)
```

## Frontmatter padrao

Todo `.md` no repositorio deve abrir com:

```yaml
---
titulo: ...
diataxis: tutorial | how-to | reference | explanation | status | onda
hbn-track: fast_track | safe_track
audiencia: humano | ia | ambos
versao-sistema: V12.0.0203
data: AAAA-MM-DD
---
```

Excecoes: arquivos em `auditoria/04_evidencias/` (sao CSVs ou manifestos
ja com schema proprio).

## Anti-padroes documentais

Os seguintes padroes foram banidos na Onda 6:

| Anti-padrao | Consequencia | Substituto |
|---|---|---|
| Mesma regra em 3 lugares | divergencia futura | UM canonico + N referencias |
| Documento "tecnico" + documento "procedimento" + documento "auditoria" para mesma onda | inflacao documental | UM doc por onda |
| Macro descartavel "imediata" em vez de cenario automatizado | bug nao protegido | cenario `IDM_*` ou `RDZ_*` em V2 |
| Claim sem evidencia ("100% testado") | viola Truth Barrier do HBN + Glasswing G5 | claim com link para CSV de evidencia |
| Markdown sem frontmatter | LLM nao consegue filtrar | frontmatter completo |

## Reversibilidade

Todas as quatro camadas sao reversivelmente desmontaveis. Em particular:

- `.hbn/` pode ser apagado e o codigo continua funcionando.
- `docs/` Diataxis pode ser achatado.
- `auditoria/` pode ser flat se o numero historico for preservado.
- `obsidian-vault/` pode ser deletado.

A reversibilidade e proposital: a metodologia e adicao de
expressividade, nao acoplamento.
