# 16. Auditoria de Publicacao Publica — V12.0.0202

Origem: auditoria tecnica complementar consolidada
Escopo: Pedido A (estrutura publica, seguranca, governanca, documentacao, compliance) + Pedido B (arquitetura de testes, confiabilidade, esteira incremental).
Linha auditada: `V12.0.0202`.
Branch corrente do working tree: `codex/v180-stable-reset` (ainda nao e o `main` publico).
Data: 2026-04-19.

> **Nota de atualizacao:** o eixo de licenciamento deste documento foi
> superado pela adocao publica da TPGL v1.1, consolidada em
> [17_PARECER_LICENCIAMENTO_TPGL_v1_1.md](17_PARECER_LICENCIAMENTO_TPGL_v1_1.md)
> e no arquivo [LICENSE](../LICENSE).
> As recomendacoes de governanca, estrutura e testes permanecem uteis como
> backlog tecnico.

Esta auditoria e prescritiva e executavel. Cada achado tem proposta de correcao, prioridade e gancho com a sprint correspondente no bloco 07. O bloco 09 entrega um roteiro executivo de implementacao sem ambiguidade.

---

## 00_VEREDITO_GERAL

**Veredito:** PUBLICAR COM RESSALVAS BLOQUEANTES.

A engenharia da `V12.0.0202` esta solida o suficiente para ser exposta: codigo VBA organizado, separacao por camadas (`Repo_*`, `Svc_*`, `Util_*`, `Teste_*`), bateria oficial verde, status canonico de release definido em `obsidian-vault/releases/STATUS-OFICIAL.md`, e material operacional local corretamente fora do `git`. A higiene tecnica e real.

A superficie publica, no entanto, ainda nao esta pronta para suportar a leitura de "matriz de seguranca, documentacao e governanca de repositorio publico maduro". Cinco classes de problema sao bloqueantes:

1. **Licenca ausente.** Sem `LICENSE`, o repositorio publicado e juridicamente ambiguo: por padrao, `all rights reserved` se aplica e usuarios externos nao tem direito de uso. Isso quebra qualquer narrativa de "auditavel e aberto".
2. **Pacote minimo de governanca ausente.** Falta `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `CHANGELOG.md`, `CODEOWNERS`, `.github/` (issue templates, PR template, workflows).
3. **Branch publicacao errada.** O HEAD esta em `codex/v180-stable-reset`. O corte publico precisa ser feito sobre `main`, com tag `v12.0.0202` assinada e branch protegida.
4. **Estrutura de testes acoplada ao `src/vba/`.** `Teste_*.bas` (`6361` linhas) convive com producao, sem separacao logica nem rastreabilidade entre regra de negocio e caso de teste. Sem essa separacao, qualquer pretensao CMMI nivel 3 / ISO cai.
5. **Auditoria com numeracao inconsistente.** `auditoria/` salta de `04` para `14`, e o `MANIFEST.md` cita arquivos canonicos sem indice ordenado. Para um leitor externo, o conjunto parece incompleto.

Nenhuma destas pendencias exige reescrever codigo. Sao 1-2 sprints curtas de governanca documental e reorganizacao fisica do repositorio. Apos elas, o repositorio sustenta com credibilidade a narrativa de "pronto para trilha CMMI 3 / ISO / repositorio source-available maduro".

Decisao recomendada: **nao abrir publicacao agora**. Executar o plano do bloco 07 (sprints S0–S3 sao bloqueantes; S4–S9 evoluem confiabilidade). Tag `v12.0.0202-public` so deve ser publicada apos checklist do bloco 08.

---

## 01_ESTRUTURA_PUBLICA_E_DOCUMENTACAO

### 1.1 Diagnostico da arvore atual

A arvore publica proposta esta majoritariamente correta, mas com seis problemas estruturais:

| # | Problema | Evidencia |
|---|---|---|
| 1 | Codigo de teste mora dentro de `src/vba/` junto com producao | `src/vba/Teste_Bateria_Oficial.bas`, `Teste_V2_*`, `Central_Testes*` somam 6361 linhas |
| 2 | Nao existe `tests/` ou `src/vba/tests/` separado | nenhum diretorio dedicado |
| 3 | Documentacao de release vive dentro de `obsidian-vault/` | `obsidian-vault/releases/V12.0.0202.md` deveria ser `docs/releases/` ou `CHANGELOG.md` |
| 4 | `auditoria/` tem numeracao com salto (00, 03, 04, 14, 15) | confunde o leitor externo, sugere arquivos faltando |
| 5 | `obsidian-vault/MANIFEST.md` aponta para si proprio como fonte canonica | duplica o papel do `README.md` e do indice oficial |
| 6 | Arquivos auxiliares de bateria (CSV) gerados na raiz | `BateriaOficial_*.csv` na raiz, embora gitignorados, poluem o working tree |

### 1.2 Matriz de achados (Pedido A)

| ID | Item | Gravidade | Risco | Proposta de correcao | Prioridade | Sprint |
|---|---|---|---|---|---|---|
| A-01 | Sem `LICENSE` | Critica | Juridico: repositorio default e proprietario; impede uso, fork ou redistribuicao | Adicionar `LICENSE` TPGL v1.1 e `CLA.md` | P0 | S0 |
| A-02 | Sem `SECURITY.md` | Alta | Sem canal de divulgacao responsavel de vulnerabilidades; inadequado para compliance | Criar `SECURITY.md` com canal e SLA | P0 | S1 |
| A-03 | Sem `CONTRIBUTING.md` | Alta | Sem regra clara de PR, branch, commit; risco de contribuicoes desorganizadas | Criar `CONTRIBUTING.md` com fluxo, conventional commits, gates | P0 | S1 |
| A-04 | Sem `CODE_OF_CONDUCT.md` | Media | Esperado em projetos publicos maduros | Adotar codigo de conduta objetivo | P1 | S1 |
| A-05 | Sem `CHANGELOG.md` na raiz | Alta | Historico fragmentado em `obsidian-vault/releases/` | Criar `CHANGELOG.md` (Keep a Changelog 1.1.0) com aponte para releases canonicas | P0 | S1 |
| A-06 | Sem `CODEOWNERS` | Media | Sem responsabilidade definida sobre paths sensiveis | Criar `.github/CODEOWNERS` cobrindo `src/vba/`, `auditoria/`, `tests/` | P1 | S2 |
| A-07 | Sem `.github/` (templates, workflows) | Alta | Sem PR template, issue template, CI | Criar `.github/PULL_REQUEST_TEMPLATE.md`, `ISSUE_TEMPLATE/{bug,feature,security}.yml`, `workflows/lint.yml` | P1 | S2 |
| A-08 | Branch atual nao e `main` | Critica | Risco de publicar a partir de branch lateral, perdendo PR history | Reset/merge de `codex/v180-stable-reset` para `main`, criar tag `v12.0.0202` | P0 | S0 |
| A-09 | Testes misturados com producao | Alta | Acoplamento, dificulta CMMI nivel 3 (separacao process/product) | Mover `Teste_*` e `Central_Testes*` para `src/vba/tests/` (mantendo importacao no projeto VBA) | P1 | S3 |
| A-10 | Numeracao inconsistente em `auditoria/` | Media | Aparenta documentos faltando | Renomear para sequencia continua (`01`, `02`, `03`, `04`, `05`, `06`) e criar `auditoria/INDEX.md` | P1 | S2 |
| A-11 | `obsidian-vault/MANIFEST.md` redundante | Baixa | Duplicidade documental | Remover `MANIFEST.md` e absorver no `README.md`/`docs/INDEX.md` | P2 | S2 |
| A-12 | `obsidian-vault/` mistura release notes com vault editorial | Media | Leitor externo nao precisa do vault; releases sao canonicas | Mover `releases/` para `docs/releases/`; deixar `obsidian-vault/` apenas se for util internamente, ou remover do publico | P1 | S2 |
| A-13 | `BateriaOficial_*.csv` gerados na raiz | Baixa | Polui working tree mesmo gitignorado | Configurar `Teste_Bateria_Oficial` para escrever em `evidencias/bateria/` (subpasta gitignorada) | P2 | S4 |
| A-14 | `~$PlanilhaCredenciamento-Homologacao.xlsm` (lock file Excel) presente | Baixa | Indica sessao Excel aberta na hora do snapshot; nao deveria circular | Limpar antes de snapshots; reforcar `.gitignore` (ja cobre via `~$*.xls*`) | P2 | S0 |
| A-15 | `.DS_Store` na raiz e em subpastas (gitignored mas existente em disco) | Baixa | Ruido visual em listings | `find . -name .DS_Store -delete` antes do corte publico | P2 | S0 |
| A-16 | `README.md` afirma "200+ cenarios automatizados" sem evidencia linkavel | Media | Numero precisa ser substanciavel; risco reputacional | Publicar `auditoria/COBERTURA.md` com contagem real por modulo/release | P1 | S3 |
| A-17 | `src/vba/.frx` (UserForm resources) tracked como binario | Aceitavel | Necessario para UserForms; degrada diff | Manter, documentar em `CONTRIBUTING.md` que `.frx` sao binarios esperados | P3 | S2 |
| A-18 | Releases historicas (`obsidian-vault/releases/historico/`, 53 arquivos) | Media | Bom para rastreabilidade; ruim se entrarem na publicacao sem indice | Criar `docs/releases/historico/INDEX.md` ou mover para tag/branch `historico` | P1 | S2 |
| A-19 | Senha de protecao referida como "centralizada e nao exposta literal" | Media | Falta contrato escrito de como ela e injetada | Documentar em `SECURITY.md` o mecanismo (env, helper) sem revelar valor | P0 | S1 |
| A-20 | Ausencia de `docs/ARQUITETURA.md` | Media | Leitor externo nao tem mapa de modulos | Criar diagrama textual de camadas (Repo/Svc/Util/UI/Teste) | P1 | S3 |

### 1.3 Estrutura recomendada do repositorio publico

Arvore alvo (apos sprints S0–S3):

```
.
├── LICENSE                          (NOVO — S0)
├── README.md                        (REVISAR — S1)
├── CHANGELOG.md                     (NOVO — S1)
├── CONTRIBUTING.md                  (NOVO — S1)
├── CODE_OF_CONDUCT.md               (NOVO — S1)
├── SECURITY.md                      (NOVO — S1)
├── .gitignore                       (manter)
├── .github/
│   ├── CODEOWNERS                   (NOVO — S2)
│   ├── PULL_REQUEST_TEMPLATE.md     (NOVO — S2)
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.yml
│   │   ├── feature_request.yml
│   │   └── security_report.yml
│   └── workflows/
│       ├── lint-vba.yml             (NOVO — S6, opcional)
│       └── verify-docs.yml          (NOVO — S2)
├── docs/
│   ├── INDEX.md                     (NOVO — S2, substitui MANIFEST.md)
│   ├── ARQUITETURA.md               (NOVO — S3)
│   ├── REGRAS_DE_NEGOCIO.md         (= auditoria/03 hoje, mover/linkar)
│   ├── ESTRATEGIA_DE_TESTES.md      (= auditoria/04 hoje, mover/linkar)
│   ├── COMPLIANCE_CMMI_ISO.md       (NOVO — S5)
│   └── releases/
│       ├── INDEX.md
│       ├── V12.0.0202.md
│       ├── STATUS-OFICIAL.md
│       └── historico/
│           └── INDEX.md
├── src/
│   └── vba/
│       ├── core/                    (Repo_*, Svc_*, Util_*, AppContext, Audit_Log, ErrorBoundary)
│       ├── ui/                      (*.frm, *.frx, Menu_Principal, Configuracao_Inicial...)
│       ├── domain/                  (Mod_Types, Const_Colunas, Variaveis, AAA_Types)
│       └── tests/                   (Teste_*, Central_Testes*, Teste_UI_Guiado)
├── tests/
│   ├── README.md                    (mapa de baterias)
│   ├── matriz/                      (CSV/MD da matriz de cenarios)
│   ├── evidencias/                  (gitignorado, gerado em runtime)
│   └── checklists/
├── auditoria/
│   ├── INDEX.md                     (NOVO)
│   ├── 01_SUMARIO_EXECUTIVO.md      (renumerar atual 00)
│   ├── 02_REGRAS_DE_NEGOCIO.md      (renumerar atual 03)
│   ├── 03_MATRIZ_MESTRE_DE_TESTES.md (renumerar atual 04)
│   ├── 04_FECHAMENTO_BACKLOG_OPUS.md (renumerar atual 14)
│   ├── 05_PLANO_LINHA_CORTE.md      (renumerar atual 15)
│   └── 06_AUDITORIA_PUBLICACAO_V12_0202.md (este documento, renumerar de 16 para 06)
└── doc/
    └── cnae-normalizado/             (manter — dados estruturais publicos)
```

O que **manter** sem mudanca: `src/vba/` (conteudo, nao a organizacao), `doc/cnae-*`, `.gitignore` (apos completar a entrada truncada), `obsidian-vault/releases/V12.0.0202.md` e `STATUS-OFICIAL.md` (mover para `docs/releases/`).

O que **mover para historico interno** (fora do publico ou em branch separada): `obsidian-vault/.obsidian/`, `obsidian-vault/releases/historico/` se nao houver indice publico, material operacional local nao publicado, `backup_bateria_oficial/`, `BKP_forms/`, `backups/`, `~$*.xlsm`.

O que **remover do tracking**: nada novo (ja esta limpo). Apenas executar `find . -name .DS_Store -delete` no working tree antes de qualquer push de demo.

### 1.4 Pacote minimo de governanca publica

Arquivos obrigatorios na raiz (todos novos, listados em ordem de criacao):

1. `LICENSE` — texto integral da licenca escolhida (ver bloco 02).
2. `README.md` — atualizado com badges (license, release, status), hero (ver bloco 03), TL;DR de seguranca, link para `docs/INDEX.md`.
3. `CHANGELOG.md` — Keep a Changelog 1.1.0; entrada inicial `[V12.0.0202] — 2026-04-19` com Added/Changed/Fixed; aponta para `docs/releases/`.
4. `CONTRIBUTING.md` — fluxo de PR, conventional commits, naming `feature/*`, `fix/*`, `docs/*`, gate de bateria oficial verde, gate de revisao por CODEOWNER.
5. `CODE_OF_CONDUCT.md` — Contributor Covenant 2.1 com email de contato.
6. `SECURITY.md` — politica de divulgacao responsavel, canal privado institucional, SLA de 7 dias para triagem, descricao de como a senha de protecao e injetada (sem expor valor), escopo de vulnerabilidades aceitas.

Arquivos obrigatorios em `.github/`:

7. `CODEOWNERS` — `src/vba/core/ @<owner>`, `src/vba/tests/ @<owner>`, `auditoria/ @<owner>`, `docs/ @<owner>`, `LICENSE @<owner>`, `SECURITY.md @<owner>`.
8. `PULL_REQUEST_TEMPLATE.md` — checklist: tipo de mudanca, escopo, evidencia de bateria oficial, link de release, breaking change, atualizacao de CHANGELOG.
9. `ISSUE_TEMPLATE/bug_report.yml`, `feature_request.yml`, `security_report.yml`.

Arquivos obrigatorios em `docs/`:

10. `docs/INDEX.md` — substitui `obsidian-vault/MANIFEST.md`. Lista canonica navegavel.
11. `docs/ARQUITETURA.md` — diagrama textual de camadas, contrato entre `Svc_*` e `Repo_*`, papel de `AppContext`, `Audit_Log`, `ErrorBoundary`.
12. `docs/COMPLIANCE_CMMI_ISO.md` — mapa de praticas adotadas vs. CMMI nivel 3 PA's e ISO 9001/27001 controles.

---

## 02_SEGURANCA_GOVERNANCA_E_LICENCA

### 2.1 Licenca — eixo superado por decisao posterior

Esta secao foi superada pela adocao publica da **TPGL v1.1**.

Parametros vigentes:

- licenca publica `source-available`
- contribuicoes publicas condicionadas a `CLA.md`
- repositorio apresentado como auditavel, e nao como software livre/open source
- conversao automatica de cada release para Apache License 2.0 apos 4 anos

O racional tecnico-juridico completo passou a ser o documento
`auditoria/17_PARECER_LICENCIAMENTO_TPGL_v1_1.md`.

Riscos de manter sem licenca:

- **Juridico:** sem `LICENSE`, vale `all rights reserved` por default. Qualquer municipio que rodar a planilha esta tecnicamente sem outorga formal; em caso de litigio futuro (raro mas possivel), o municipio pode ser obrigado a remover. Isso anula o discurso de "doacao a municipios".
- **Reputacional:** repositorio publico sem `LICENSE` e percebido como amador ou inseguro. GitHub avisa o usuario com banner amarelo.
- **Adocao:** organizacoes corporativas e governamentais bloqueiam adocao de codigo sem licenca explicita.

Pacote minimo para coerencia juridica: `LICENSE`, `NOTICE` (apenas se Apache), credito autoral preservado em cabecalho de modulos VBA chave (proposta: cabecalho com `'  Sistema de Credenciamento - V12.0.0202` + linha de licenca curta).

### 2.2 Governanca — pacote alvo

**Branch protection (configuracao no GitHub):**

- `main` protegido: PR obrigatorio, ao menos 1 review, status checks obrigatorios (gate de docs e gate de teste quando houver), bloqueio de force-push, bloqueio de delete, signed commits exigidos para CODEOWNERS.
- Tags assinadas (`git tag -s v12.0.0202 -m "..."`) para releases.
- `CODEOWNERS` por path conforme item 1.4.

**Versionamento:**

- Semver adaptado: `V<MAJOR>.<MINOR>.<PATCH>` (ja em uso). Documentar em `CONTRIBUTING.md` quando subir cada nivel.
- Conventional Commits para mensagens (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`).

**Auditoria de mudanca:**

- Cada release publicada gera tag, entrada no `CHANGELOG.md`, arquivo em `docs/releases/`, e atualizacao do `STATUS-OFICIAL.md`.
- Hash SHA-256 do `.xlsm` publicado deve ser registrado na tag e no release notes (prepara o terreno para o item de evidencia em testes — bloco 06).

### 2.3 Seguranca — exposicao e mitigacoes

| Risco | Estado atual | Mitigacao |
|---|---|---|
| Senha de protecao em texto claro no codigo | Mitigado parcialmente (centralizada em helper) | Documentar em `SECURITY.md` o mecanismo de injecao; se hoje esta hardcoded em helper, mover para constante alimentada por `Workbook.Open` lendo planilha oculta nao versionada |
| Macros maliciosas em fork | Risco inerente a `.xlsm` | Nao publicar `.xlsm` no repositorio. Usuario gera/baixa `.xlsm` via release com hash SHA-256 verificavel |
| Vazamento de dados de municipios em CSV de bateria | Baixo (CSV gitignorado), mas presente no working tree | Mover saida para `tests/evidencias/`, gitignorar pasta inteira, sanitizar dados de teste (nomes ficticios) |
| Ausencia de canal de divulgacao | Sim | `SECURITY.md` com canal e SLA de 7 dias para triagem, 90 dias para correcao |
| Dependencias externas | Material operacional local nao publicado | Manter fora da superficie publica; documentar em `docs/ARQUITETURA.md` apenas o que integra o produto publico |
| Protecao de abas baseada em senha unica | Funcional, mas fragil para auditoria | Documentar em `SECURITY.md` que protecao Excel e barreira operacional, nao seguranca criptografica |

### 2.4 Material que ainda parece privado ou operacional demais

Apos a faxina:

- `obsidian-vault/MANIFEST.md` tem tom de bastao operacional ("este arquivo substitui o manifesto legado"). Reescrever ou eliminar.
- `obsidian-vault/00-DASHBOARD.md` tinha autoria nao humana no front-matter. Para publico, manter so o responsavel humano.
- `auditoria/14_FECHAMENTO_BACKLOG_OPUS_V12_0202.md` cita "auditoria Opus" sem contexto para um leitor externo. Renumerar e inserir um paragrafo de abertura situando o que foi a auditoria Opus.
- `obsidian-vault/releases/historico/` (53 arquivos) precisa de `INDEX.md` ou ser movido para branch `historico` separado.

---

## 03_PROPOSTA_DE_HERO_E_APRESENTACAO_PUBLICA

Texto pronto para colar no topo do `README.md`, abaixo do titulo. Formal, enxuto, comunica auditabilidade sem floreio.

```markdown
# Sistema de Credenciamento e Rodizio de Pequenos Reparos

> Planilha Excel/VBA, auditavel e gratuita, para municipios brasileiros gerirem
> credenciamento, rodizio equitativo, ordens de servico e avaliacao de
> prestadores de pequenos reparos. Ferramenta autonoma, doada aos municipios
> como porta de entrada da metodologia Sebrae de rodizio de credenciamento.

[![Release](https://img.shields.io/badge/release-V12.0.0202-blue)](docs/releases/V12.0.0202.md)
[![Status](https://img.shields.io/badge/status-VALIDADO-brightgreen)](docs/releases/STATUS-OFICIAL.md)
[![Licenca](https://img.shields.io/badge/licenca-TPGL%20v1.1-6f42c1)](LICENSE)
[![Bateria Oficial](https://img.shields.io/badge/bateria%20oficial-verde-brightgreen)](auditoria/03_MATRIZ_MESTRE_DE_TESTES.md)
[![Compliance](https://img.shields.io/badge/compliance-CMMI%20L3%20%2F%20ISO%20track-blue)](docs/COMPLIANCE_CMMI_ISO.md)

## Por que existe

Municipios pequenos precisam de uma ferramenta simples, transparente e
auditavel para distribuir servicos de pequenos reparos entre prestadores
credenciados de forma equitativa, com regra clara de rodizio, fila por
atividade, suspensao automatica por baixo desempenho e historico completo
de eventos. Esta planilha entrega essa capacidade sem custo, sem dependencia
de servidor, e com codigo VBA inteiramente aberto a inspecao.

## O que torna confiavel

- **Codigo-fonte source-available e auditavel.** Todo o VBA esta em [`src/vba/`](src/vba/) e tem
  diff completo no Git.
- **Bateria de testes oficial.** Cobertura automatizada documentada em
  [`auditoria/03_MATRIZ_MESTRE_DE_TESTES.md`](auditoria/03_MATRIZ_MESTRE_DE_TESTES.md),
  com gates explicitos antes de cada release.
- **Status canonico de release.** Toda versao tem classificacao formal
  (`VALIDADA`, `SUPERADA`, `REVERTIDA`) em [`docs/releases/STATUS-OFICIAL.md`](docs/releases/STATUS-OFICIAL.md).
- **Trilha de auditoria.** Eventos criticos sao registrados em `AUDIT_LOG`;
  release notes, hashes SHA-256 do `.xlsm` e evidencia de bateria sao
  publicados a cada tag.
- **Politica de seguranca.** Canal de divulgacao responsavel definido em
  [`SECURITY.md`](SECURITY.md); senha de protecao das abas e injetada por
  helper, nunca exposta literal no repositorio.
- **Trilha de maturidade.** Estrutura preparada para se aproximar de praticas
  CMMI nivel 3 e ISO 9001/27001, conforme [`docs/COMPLIANCE_CMMI_ISO.md`](docs/COMPLIANCE_CMMI_ISO.md).

## Comecando

Baixe o `.xlsm` da [release mais recente](../../releases/latest), valide o
hash SHA-256 contra o publicado em release notes, abra no Excel
2019/2021/365 com macros habilitadas, e configure municipio e gestor em
**Config. Inicial**.

## Arquitetura, regras e testes

| Topico | Documento |
|---|---|
| Visao geral de arquitetura | [`docs/ARQUITETURA.md`](docs/ARQUITETURA.md) |
| Regras de negocio | [`docs/REGRAS_DE_NEGOCIO.md`](docs/REGRAS_DE_NEGOCIO.md) |
| Estrategia de testes | [`docs/ESTRATEGIA_DE_TESTES.md`](docs/ESTRATEGIA_DE_TESTES.md) |
| Status oficial das versoes | [`docs/releases/STATUS-OFICIAL.md`](docs/releases/STATUS-OFICIAL.md) |
| Compliance | [`docs/COMPLIANCE_CMMI_ISO.md`](docs/COMPLIANCE_CMMI_ISO.md) |
| Como contribuir | [`CONTRIBUTING.md`](CONTRIBUTING.md) |
| Politica de seguranca | [`SECURITY.md`](SECURITY.md) |
| Codigo de conduta | [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) |
| Historico de mudancas | [`CHANGELOG.md`](CHANGELOG.md) |

## Creditos

- Concepcao original: Sergio Cintra
- Engenharia atual: Luís Maurício Junqueira Zanin

## Licenca

[TPGL v1.1](LICENSE). O codigo-fonte publicado e source-available,
auditavel e converte automaticamente para Apache License 2.0 apos
4 anos de cada release.
```

---

## 04_DIAGNOSTICO_DOS_TESTES

### 4.1 Inventario

| Camada hoje | Modulo | Linhas | Funcao declarada |
|---|---|---|---|
| Bateria Oficial | `Teste_Bateria_Oficial.bas` | 2.414 | Prova de regressao principal |
| V2 — engine | `Teste_V2_Engine.bas` | 1.628 | Baseline deterministica, harness V2 |
| V2 — roteiros | `Teste_V2_Roteiros.bas` | 291 | Cenarios encadeados (smoke, stress) |
| Central | `Central_Testes.bas` | 732 | Orquestracao de execucoes manuais |
| Central V2 | `Central_Testes_V2.bas` | 76 | Orquestracao da V2 |
| Relatorio | `Central_Testes_Relatorio.bas` | 1.101 | Geracao de RESULTADO_QA, contadores, dashboard |
| Assistido | `Teste_UI_Guiado.bas` | 119 | Apoio ao operador humano |
| **Total** | — | **6.361** | — |

### 4.2 Forcas atuais

1. Existem ja **tres camadas distintas** (oficial, V2, assistido) com responsabilidades separadas — base solida para a esteira em camadas.
2. Existe **dashboard ao vivo** (`RESULTADO_QA`) com contadores, ja aceito pelo operador humano — boa fundacao para evidencia visual.
3. Existe **baseline deterministica V2** validada (V12.0.0190) — pre-condicao indispensavel para shadow mode futuro.
4. Existe **rastreabilidade nominal** entre release e teste no `STATUS-OFICIAL.md` e nos fechamentos de backlog.
5. **Migracao UI -> servico fechada** no nucleo principal — testes podem agora atacar `Svc_*` sem esbarrar em `Form_*`.
6. **Atomicidade minima e snapshot pre-reset** ja implementados — pre-condicoes para invariantes.

### 4.3 Falhas que ainda permitem regressao silenciosa

| ID | Falha | Por que importa |
|---|---|---|
| T-01 | Sem comparador automatizado V1 x V2 (item D1 do backlog Opus) | Mudancas em `Svc_*` podem divergir de V1 sem alertar |
| T-02 | Sem shadow mode continuo (D2) | Sem comparacao em fundo, regressao demora a aparecer |
| T-03 | Stress complementar e edge cases abertos (E1) | Cenarios raros (fila com 1 elemento, todas suspensas, multi-atividade) sem cobertura |
| T-04 | Transacao ampla parcial (C2) | Falhas no meio de PreOS/OS/Avaliacao podem deixar estado inconsistente |
| T-05 | Sem hash/versao no cabecalho dos CSVs (H4) | Evidencia de bateria nao tem prova de qual codigo gerou; perda de rastreabilidade forense |
| T-06 | Sem matriz de invariantes explicitos | Propriedades do tipo "soma de fila == 1" ou "nenhuma OS sem PreOS" nao sao testadas como invariantes |
| T-07 | Sem matriz de cobertura por regra | Nao existe documento que diga "regra X esta coberta pelo teste Y na release Z" |
| T-08 | Sem CI minimo | Toda execucao depende de operador humano abrir Excel |
| T-09 | Sem gate formal pre-tag | A decisao de subir status para `VALIDADA` e manual, sem checklist assinado |
| T-10 | Bateria oficial gera CSV na raiz, sem versionamento de schema | Mudancas no formato podem quebrar consumidores externos |
| T-11 | Sem teste de contrato entre `Svc_*` e `Repo_*` | Mudancas de assinatura podem passar batidas se a UI nao chamar o caminho |
| T-12 | Sem teste de propriedades para o rodizio | Propriedade `apos N execucoes, distribuicao por atividade tende a uniforme dentro de tolerancia` nao e testada |
| T-13 | Tests acoplados ao workbook ativo | Falta isolamento via workbook de fixture limpo a cada run |
| T-14 | Sem versionamento da matriz de testes | `04_MATRIZ_MESTRE_DE_TESTES.md` nao tem changelog proprio; mudou junto com codigo, perde-se a evolucao |

### 4.4 Diagnostico em uma linha

A estrutura de testes tem solo firme para sustentar `V12.0.0202`, mas opera no regime "verificacao" (rodar e ver) e nao "garantia" (gates, invariantes, evidencia assinada). Para alcancar maturidade alvo (CMMI 3 / ISO track / publicacao reputavel), o salto necessario e **adicionar camadas de garantia formal** (contrato, invariantes, propriedades, shadow), formalizar **gates por release**, e produzir **evidencia versionada e hashada**.

---

## 05_ARQUITETURA_ALVO_DA_ESTEIRA_DE_TESTES

### 5.1 Piramide de seis camadas

```
              ┌────────────────────────────────────────────┐
        L6    │ Homologacao Assistida (humano + RESULTADO_QA) │   gate manual de release
              ├────────────────────────────────────────────┤
        L5    │ Stress Deterministico + Shadow V1 x V2       │   gate automatico de robustez
              ├────────────────────────────────────────────┤
        L4    │ Cenarios de Negocio (Bateria Oficial)        │   gate de regressao
              ├────────────────────────────────────────────┤
        L3    │ Integracao Svc_* x Repo_*                    │   gate de fluxo
              ├────────────────────────────────────────────┤
        L2    │ Unidade de Servico (Svc_* puros, Util_*)     │   gate rapido
              ├────────────────────────────────────────────┤
        L1    │ Contratos e Invariantes                      │   gate base
              └────────────────────────────────────────────┘
```

| Camada | Objeto sob teste | Modulo VBA correspondente | Frequencia | Bloqueia release? |
|---|---|---|---|---|
| L1 Contratos | Tipos (`Mod_Types`, `AAA_Types`), constantes (`Const_Colunas`), assinaturas publicas de `Svc_*` | `Teste_L1_Contratos.bas` (NOVO) | Toda execucao | Sim |
| L1 Invariantes | Propriedades persistentes do dominio (fila integra, OS sem PreOS = 0, suma de notas) | `Teste_L1_Invariantes.bas` (NOVO) | Toda execucao + apos qualquer reset | Sim |
| L2 Unidade | Funcoes puras de `Svc_Rodizio`, `Svc_PreOS`, `Svc_OS`, `Svc_Avaliacao`, `Util_*` | `Teste_L2_Unidade.bas` (NOVO, pode aproveitar conteudo de `Teste_V2_Engine`) | Toda execucao | Sim |
| L3 Integracao | `Svc_* -> Repo_* -> Planilha` em workbook fixture isolado | `Teste_L3_Integracao.bas` (NOVO) | Toda execucao | Sim |
| L4 Cenarios | Bateria oficial atual (fluxo end-to-end por cenario) | `Teste_Bateria_Oficial.bas` (manter) | Pre-tag | Sim |
| L5 Stress + Shadow | Stress deterministico + comparador V1 x V2 | `Teste_L5_Stress.bas` + `Teste_L5_Shadow.bas` (NOVO) | Pre-tag e diario opcional | Sim para tag publica |
| L6 Assistido | Roteiro humano no Excel real | `Teste_UI_Guiado.bas` (manter, expandir) | Pre-publicacao publica | Sim para publicacao |

### 5.2 Esteira incremental

Pipeline logico (executavel em parte automatico, em parte manual com checklist):

```
PR aberto
  └─► L1 Contratos + L1 Invariantes (sub-segundo)
       └─► L2 Unidade (segundos)
            └─► L3 Integracao (1-2 min)
                 ├─► [PASS] tag interno `pr-ok`, libera review humano
                 └─► [FAIL] bloqueia merge

Merge em main
  └─► L4 Bateria Oficial completa
       └─► gera CSV de evidencia em tests/evidencias/<sha>/
            └─► [PASS] tag interno `main-green`

Pre-tag de release
  └─► L4 + L5 (stress + shadow V1 x V2)
       └─► gera evidence pack: CSV bateria, CSV stress, diff shadow, hash xlsm
            └─► gate humano (CODEOWNER + operador)
                 └─► L6 (assistido) com checklist do bloco 06
                      └─► tag assinada v<MAJOR.MINOR.PATCH> + atualizacao STATUS-OFICIAL
```

### 5.3 Chaves de evolucao por release

Cada release deve carregar tres chaves no `App_Release.bas`:

```vb
Public Const APP_RELEASE_VERSION    As String = "V12.0.0203"
Public Const APP_RELEASE_TEST_KEY   As String = "L1+L2+L3+L4+L5+L6"  ' camadas exigidas
Public Const APP_RELEASE_EVIDENCE   As String = "evidence/v12.0.0203/" ' caminho relativo do pacote
```

A chave `APP_RELEASE_TEST_KEY` formaliza qual conjunto de camadas a release exige. Releases de hotfix podem reduzir (`L1+L2+L3+L4`); releases candidatas a publica exigem o conjunto completo. Auditoria externa pode ler a chave e validar contra a evidencia anexa.

### 5.4 Modelo de evidencia por release

Pacote `evidence/<versao>/` (gitignored para nao inchar repo, mas anexado a tag GitHub):

```
evidence/V12.0.0203/
├── manifest.json                  # versao, sha xlsm, sha src/vba/, datas, operador, host
├── bateria_oficial.csv            # CSV padrao + cabecalho hashado
├── bateria_oficial_falhas.csv
├── stress.csv
├── shadow_v1_v2_diff.csv          # diff por cenario, vazio se identicos
├── invariantes.csv                # cada invariante: nome, status, contagem
├── checklist_assistido.md         # marcas + assinatura do operador humano
└── xlsm.sha256                    # hash do .xlsm publicado
```

`manifest.json` deve incluir `git rev-parse HEAD`, `tree-hash` de `src/vba/`, e `Application.Version` do Excel usado.

### 5.5 Modelo de shadow mode

Shadow comparador V1 x V2:

1. Ambos os engines (V1 = caminho original, V2 = caminho novo) executam o mesmo cenario sobre fixture identico (snapshot pre-reset garantido).
2. Cada engine produz vetor de saida normalizado (lista de IDs em ordem de selecao do rodizio, lista de PreOS criados, decisoes de avaliacao, etc.).
3. Comparador (`Teste_L5_Shadow.bas`) verifica igualdade campo a campo. Diferencas vao para `shadow_v1_v2_diff.csv`.
4. Diff vazio = chave `SHADOW=GREEN` no `manifest.json`. Diff nao vazio bloqueia tag publica.

### 5.6 Modelo de stress e invariantes

Stress deterministico:

- Geradores parametricos: N empresas (10, 100, 1000), M atividades (1, 50), K execucoes (100, 1000, 10000) com seed fixo.
- Mede tempo, contagens, e valida invariantes em cada checkpoint (a cada 100 execucoes).

Invariantes (todos hard-fail):

- `INV-01` Para qualquer atividade, `count(empresas em fila ativa) >= 0` (sanidade).
- `INV-02` Nenhuma OS existe sem PreOS valida que a antecede.
- `INV-03` Soma de avaliacoes por OS = numero de itens avaliaveis dessa OS.
- `INV-04` Empresa suspensa nao aparece como vencedora de rodizio.
- `INV-05` `POSICAO_FILA` e unica por atividade entre empresas ativas.
- `INV-06` Reativacao automatica acontece se e somente se data atual >= fim_suspensao.
- `INV-07` Apos N=1000 execucoes uniformes, distribuicao por empresa tem desvio <= tolerancia X% (propriedade do rodizio equitativo).

### 5.7 Modelo de homologacao assistida

`Teste_UI_Guiado.bas` evolui para script de roteiro com `checklist_assistido.md` gerado:

```
[ ] Abrir planilha em Excel limpo
[ ] Configurar municipio "Cidade Teste" e gestor "Operador QA"
[ ] Importar 612 CNAEs e validar contagem
[ ] Cadastrar 3 empresas em 1 atividade
[ ] Executar 10 ciclos de PreOS->OS->Avaliacao
[ ] Verificar dashboard RESULTADO_QA com contadores esperados
[ ] Fechar Excel sem erros
Operador: ________________
Data: ________________
Assinatura (rubrica): ________________
```

---

## 06_GATES_E_EVIDENCIAS_DE_RELEASE

### 6.1 Matriz de gates

| Gate | Quando | Camadas exigidas | Evidencia gerada | Bloqueia? | Quem aprova |
|---|---|---|---|---|---|
| G1 — PR | A cada PR | L1 + L2 | log textual em PR | Sim para merge | Reviewer |
| G2 — Merge `main` | Apos merge | L1+L2+L3 | `evidencias/<sha>/integracao.csv` | Sim para preparar tag | Automatico |
| G3 — Tag candidata | Antes de tag | L1+L2+L3+L4 | `evidence/<versao>/bateria_oficial.csv` + `xlsm.sha256` | Sim para tag | CODEOWNER |
| G4 — Tag publica | Antes de mover STATUS para `VALIDADA` | G3 + L5 (stress + shadow) | `shadow_v1_v2_diff.csv` vazio + stress sem invariante violado | Sim para promover a publica | CODEOWNER + Operador |
| G5 — Publicacao | Antes de subir tag para release publica GitHub | G4 + L6 assistido | `checklist_assistido.md` assinado | Sim para publicar | Mantenedor humano |

### 6.2 Modelo de auditoria de regressao

Para cada release `V_n`:

1. Re-executar L1+L2+L3+L4 sobre `V_{n-1}` e `V_n` em fixture identico.
2. Gerar `regression_diff.csv` comparando `bateria_oficial.csv` de `V_{n-1}` e `V_n`.
3. Toda diferenca exige justificativa anotada em `docs/releases/V_n.md` na secao `Diferencas vs V_{n-1}`.
4. Releases de hotfix devem ter `regression_diff.csv` vazio em todos os cenarios fora do escopo do hotfix.

### 6.3 Versionamento da evidencia

- Cabecalho dos CSVs ganha 4 linhas de metadata: `# version=V12.0.0203`, `# sha_src=<hash>`, `# generated_at=<ISO>`, `# operator=<id>`.
- `manifest.json` da release referencia hash de cada CSV.
- Hash do `.xlsm` publicado e incluido na descricao da release GitHub e em `docs/releases/V_n.md`.

---

## 07_PLANO_DE_MICROEVOLUCOES

Sprints curtos (cada um deve fechar em 1-3 sessoes de trabalho). Dependencias explicitas. Criterios de aceite verificaveis.

### S0 — Faxina pre-publicacao (1 sessao, P0)

**Dependencias:** nenhuma.

**Escopo:**
- Reset de branch: criar `main` a partir de `codex/v180-stable-reset` (ou merge limpo); `git checkout main`.
- `find . -name .DS_Store -delete` no working tree.
- Remover `~$PlanilhaCredenciamento-Homologacao.xlsm` se persistir.
- Completar a ultima linha truncada do `.gitignore` (`# Artefatos locais de automacao/importacao` esta sem entrada efetiva).
- Criar `LICENSE` (TPGL v1.1) na raiz.

**Criterio de aceite:**
- `git status` limpo em `main`.
- `LICENSE` presente, conteudo TPGL v1.1, atribuicao correta.
- `find . -name .DS_Store` retorna vazio.
- GitHub deixa de mostrar banner de "no license".

### S1 — Pacote minimo de governanca (1 sessao, P0)

**Dependencias:** S0.

**Escopo:**
- Criar `README.md` revisado com hero do bloco 03.
- Criar `CHANGELOG.md` (Keep a Changelog 1.1.0) com entrada `[V12.0.0202] — 2026-04-19`.
- Criar `CONTRIBUTING.md` (fluxo PR, commits, branches, gates).
- Criar `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1, email de contato).
- Criar `SECURITY.md` (canal, SLA 7d, mecanismo de senha sem expor valor).

**Criterio de aceite:**
- Os cinco arquivos existem na raiz, validados por preview no GitHub.
- `SECURITY.md` documenta como a senha e injetada em runtime.
- `CHANGELOG.md` tem links validos para `docs/releases/V12.0.0202.md`.

### S2 — Reorganizacao da arvore documental (2 sessoes, P0/P1)

**Dependencias:** S1.

**Escopo:**
- Criar `docs/INDEX.md`, `docs/releases/`, mover `obsidian-vault/releases/V12.0.0202.md` e `STATUS-OFICIAL.md` para `docs/releases/`.
- Criar `docs/releases/historico/INDEX.md` listando os 53 arquivos do historico.
- Criar `.github/CODEOWNERS`, `.github/PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/{bug,feature,security}.yml`.
- Renumerar `auditoria/` para sequencia continua e criar `auditoria/INDEX.md`.
- Decidir destino de `obsidian-vault/`: ou (a) mover para `docs/vault/` apenas com material publico, ou (b) remover do publico (fica em branch `vault-internal`).

**Criterio de aceite:**
- Toda referencia em `README.md` aponta para path em `docs/`.
- `auditoria/INDEX.md` lista todos os documentos da pasta sem saltos.
- `obsidian-vault/MANIFEST.md` deletado, conteudo absorvido em `docs/INDEX.md`.

### S3 — Reorganizacao do `src/vba/` e mapa arquitetural (2 sessoes, P1)

**Dependencias:** S2.

**Escopo:**
- Criar subpastas `src/vba/core/`, `src/vba/ui/`, `src/vba/domain/`, `src/vba/tests/`.
- Mover modulos preservando o projeto VBA importavel (atualizar instrucoes em `CONTRIBUTING.md` para reimport).
- Criar `docs/ARQUITETURA.md` com diagrama textual de camadas.
- Criar `auditoria/COBERTURA.md` listando, por modulo de teste, contagem real de cenarios (substanciar a frase "200+ cenarios" do README ou ajustar o numero).

**Criterio de aceite:**
- Reimport do `src/vba/` em workbook limpo compila sem erros.
- `docs/ARQUITETURA.md` mostra dependencias entre camadas.
- `auditoria/COBERTURA.md` tem numero verificavel.

### S4 — Camada L1: contratos e invariantes (2 sessoes, P1)

**Dependencias:** S3.

**Escopo:**
- Criar `Teste_L1_Contratos.bas` validando assinaturas publicas de `Svc_*`, tipos em `Mod_Types`, constantes em `Const_Colunas`.
- Criar `Teste_L1_Invariantes.bas` com INV-01 ate INV-06 (INV-07 fica para S6).
- Integrar L1 ao `Central_Testes.bas` como suite executavel em sub-segundo.
- Configurar bateria oficial para escrever evidencia em `tests/evidencias/<sha>/`.

**Criterio de aceite:**
- L1 verde sobre `V12.0.0202` (zero violacao).
- `tests/evidencias/` aparece gitignorado.
- Cabecalho dos CSVs da bateria ganha 4 linhas de metadata (versao, sha, datetime, operador).

### S5 — Compliance documental CMMI/ISO (1 sessao, P1)

**Dependencias:** S4.

**Escopo:**
- Criar `docs/COMPLIANCE_CMMI_ISO.md` mapeando praticas adotadas para PA's CMMI nivel 3 (CM, PPQA, MA, OPF, OPD, OT, IPM, RSKM, DAR, VAL, VER) e controles ISO 9001 (8.3, 8.5.1, 9.1) e ISO/IEC 27001 Anexo A (A.5, A.8, A.12).
- Para cada item, citar evidencia concreta no repo (link).
- Marcar explicitamente o que nao esta coberto (transparencia > falsa promessa).

**Criterio de aceite:**
- Tabela com 3 colunas: pratica/controle, evidencia, status (`adotada` / `parcial` / `nao adotada`).
- Texto explicito de que documento e mapa de aproximacao, nao certificacao formal.

### S6 — Camada L5: stress + shadow + propriedades (3 sessoes, P1)

**Dependencias:** S4.

**Escopo:**
- Criar `Teste_L5_Stress.bas` com geradores parametricos (N=10/100/1000, K=100/1000/10000, seed fixo).
- Criar `Teste_L5_Shadow.bas` com comparador V1 x V2 (formaliza item D1/D2 do backlog Opus).
- Adicionar INV-07 (uniformidade do rodizio com tolerancia).
- Gerar `evidence/<versao>/stress.csv` e `shadow_v1_v2_diff.csv`.

**Criterio de aceite:**
- Stress completa N=1000 K=10000 sem violar invariantes.
- `shadow_v1_v2_diff.csv` vazio sobre cenarios de regressao da bateria oficial.
- Tempos de execucao registrados.

### S7 — Gates e chave de evolucao por release (1 sessao, P1)

**Dependencias:** S4, S6.

**Escopo:**
- Adicionar `APP_RELEASE_TEST_KEY` e `APP_RELEASE_EVIDENCE` em `App_Release.bas`.
- Criar `docs/GATES.md` com a matriz do bloco 06.
- Criar template `evidence/<versao>/manifest.json.template`.
- Criar `tests/checklists/L6_assistido.md` (checklist de homologacao humana).

**Criterio de aceite:**
- Release nova nao publica sem chave preenchida.
- Template de manifest e validavel (json schema simples).

### S8 — Workflow de CI minimo (1 sessao, P2, opcional)

**Dependencias:** S2.

**Escopo:**
- `.github/workflows/verify-docs.yml` validando: existe `LICENSE`, existe `CHANGELOG.md`, `auditoria/INDEX.md` lista todos os arquivos da pasta.
- Opcional: `lint-vba.yml` rodando `vba-lint` ou parser sintatico em `src/vba/**/*.bas` (best effort).

**Criterio de aceite:**
- PRs disparam workflows.
- Workflows verdes em `main`.

### S9 — Auditoria de regressao formalizada (1 sessao, P2)

**Dependencias:** S6, S7.

**Escopo:**
- Script (VBA ou shell) que compara `bateria_oficial.csv` da release atual contra a anterior, gera `regression_diff.csv`.
- `docs/releases/<versao>.md` ganha secao obrigatoria `Diferencas vs <anterior>`.

**Criterio de aceite:**
- Release de hotfix produz diff vazio fora do escopo do hotfix.

### Sumario de prioridade e bloqueio

| Sprint | Prioridade | Bloqueia publicacao? | Tempo estimado |
|---|---|---|---|
| S0 | P0 | Sim | 1 sessao |
| S1 | P0 | Sim | 1 sessao |
| S2 | P0/P1 | Sim | 2 sessoes |
| S3 | P1 | Nao (mas recomendado antes da publicacao) | 2 sessoes |
| S4 | P1 | Nao | 2 sessoes |
| S5 | P1 | Nao | 1 sessao |
| S6 | P1 | Nao | 3 sessoes |
| S7 | P1 | Nao | 1 sessao |
| S8 | P2 | Nao | 1 sessao |
| S9 | P2 | Nao | 1 sessao |

**Caminho minimo para publicacao publica responsavel:** S0 → S1 → S2 (subset documental) → checklist do bloco 08.
**Caminho recomendado para "matriz de seguranca, governanca e maturidade":** S0 → S1 → S2 → S3 → S4 → S5.
**Caminho completo para nova auditoria externa final:** S0 → S9.

---

## 08_CHECKLIST_FINAL_DE_PUBLICACAO

Marcar item por item antes de empurrar `main` publico e abrir tag `v12.0.0202`.

**Branch e versionamento:**
- [ ] HEAD esta em `main`, nao em branch lateral.
- [ ] `App_Release.APP_RELEASE_VERSION = "V12.0.0202"`.
- [ ] Tag local `v12.0.0202` criada e assinada (`git tag -s`).
- [ ] `STATUS-OFICIAL.md` declara `V12.0.0202` como `VALIDADA`.

**Higiene do working tree:**
- [ ] `git status` limpo.
- [ ] Nenhum `.DS_Store` em disco.
- [ ] Nenhum `~$*.xlsm` (lock) presente.
- [ ] Nenhum `*.xlsm` rastreado pelo git.
- [ ] Nenhum CSV de bateria rastreado pelo git.
- [ ] artefatos operacionais locais, `backup_bateria_oficial/`, `BKP_forms/` e `backups/` nao tracked.

**Pacote minimo de governanca presente:**
- [ ] `LICENSE` (TPGL v1.1) na raiz.
- [ ] `README.md` revisado com hero novo, badges e links validos.
- [ ] `CHANGELOG.md` com entrada `V12.0.0202`.
- [ ] `CONTRIBUTING.md` com fluxo, commits, gates.
- [ ] `CODE_OF_CONDUCT.md` (Contributor Covenant 2.1).
- [ ] `SECURITY.md` com canal e SLA, e descricao do mecanismo de senha.
- [ ] `.github/CODEOWNERS` cobrindo `src/`, `auditoria/`, `docs/`, `LICENSE`, `SECURITY.md`.
- [ ] `.github/PULL_REQUEST_TEMPLATE.md`.
- [ ] `.github/ISSUE_TEMPLATE/` com 3 templates.

**Documentacao publica coerente:**
- [ ] `docs/INDEX.md` lista todos os documentos canonicos.
- [ ] `auditoria/INDEX.md` sem saltos de numeracao.
- [ ] `docs/releases/V12.0.0202.md` e `STATUS-OFICIAL.md` no lugar.
- [ ] `obsidian-vault/MANIFEST.md` removido (substituido por `docs/INDEX.md`).
- [ ] Todo link interno em `README.md` valida (manualmente ou via `verify-docs.yml`).

**Codigo e testes:**
- [ ] `src/vba/` compila limpo em workbook recem-aberto.
- [ ] Bateria oficial verde sobre `V12.0.0202`, evidencia salva em `evidence/V12.0.0202/`.
- [ ] Hash SHA-256 do `.xlsm` publicado registrado em release notes.
- [ ] Comentarios de cabecalho em `Svc_*`, `Repo_*` e `Teste_*` carregam citacao curta coerente com a linha publica vigente.

**Branch protection no GitHub:**
- [ ] `main` protegido (PR obrigatorio, 1 review minimo, status checks, no force-push).
- [ ] Tags assinadas exigidas para releases.
- [ ] Workflows do `.github/workflows/` ativos.

**Comunicacao publica:**
- [ ] Descricao do repositorio GitHub atualizada com 1 frase do hero.
- [ ] Topics do repo definidos (`excel`, `vba`, `gov`, `municipios`, `credenciamento`, `rodizio`, `auditoria`, `source-available`).
- [ ] About > Website apontando para documento canonico (`docs/INDEX.md` ou pagina externa).

---

## 09_ROTEIRO_EXECUTIVO_DE_IMPLEMENTACAO

Sequencia recomendada para executar as sprints S0, S1 e S2 sem tocar no
codigo VBA:

1. **S0 — faxina pre-publicacao**
   - garantir `main` como branch de publicacao
   - limpar `.DS_Store`, lockfiles de Excel e ruido local
   - concluir `.gitignore`
   - publicar `LICENSE`
2. **S1 — pacote minimo de governanca**
   - revisar `README.md`
   - criar `CHANGELOG.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`,
     `SECURITY.md`
   - formalizar `CLA.md`
3. **S2 — reorganizacao documental**
   - criar `docs/INDEX.md`
   - consolidar `.github/`
   - criar `auditoria/INDEX.md`
   - alinhar referencias cruzadas

### Riscos de conflito

1. Mudancas de path podem quebrar links em `README.md` e nas auditorias.
   Mitigacao: revisar todos os links ao final de cada sprint.
2. `obsidian-vault/MANIFEST.md` ainda pode ser citado por documentos vivos.
   Mitigacao: substituir referencias pelo `docs/INDEX.md`.
3. `.gitignore` incompleto pode deixar escapar artefatos locais.
   Mitigacao: validar o comportamento de ignore antes do commit.
4. Renumeracao agressiva em `auditoria/` pode quebrar referencias externas.
   Mitigacao: priorizar `auditoria/INDEX.md` e evitar churn desnecessario.

### Criterio de encerramento por sprint

**S0**
- `git status` limpo
- `LICENSE` presente
- nenhum `.DS_Store` no working tree
- `.gitignore` completo

**S1**
- `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md` e
  `SECURITY.md` presentes
- links publicos consistentes
- `SECURITY.md` descreve o mecanismo de protecao sem revelar valor sensivel

**S2**
- `docs/INDEX.md`, `.github/*` e `auditoria/INDEX.md` presentes
- links canonicos consistentes
- superficie publica coerente com a linha TPGL/source-available

---

Fim do documento.
