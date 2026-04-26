---
titulo: Parecer Opus — Fechamento, Documentacao e Governanca da V12.0.0203
natureza-do-documento: parecer estrategico de auditoria, organizacao documental e governanca de IAs
versao-oficial-vigente: V12.0.0202
linha-alvo: V12.0.0203
branch: codex/v12-0-0203-governanca-testes
build-ancora-validado: 88107f1
data: 2026-04-26
autor: Claude Opus 4.7 (sessao Cowork)
solicitante: Luis Mauricio Junqueira Zanin
escopo: auditoria documental, governanca entre IAs, plano de fechamento da 0203, sem refatoracao de codigo
---

# 23. Parecer Opus — Fechamento, Documentacao e Governanca da V12.0.0203

## 00. Veredito Executivo

A V12.0.0203 esta em **fase de fechamento**, nao em expansao. O trio minimo de validacao (V1 rapida `OK=171`, V2 Smoke `OK=14`, V2 Canonica `OK=20`) ja foi atingido no build `88107f1`, a auditoria 21 ja consolidou o veredito tecnico, a auditoria 22 ja registra feito/pendente/adiado, e o handoff em `local-ai/root/HANDOFF.md` ja esta alinhado com o checkpoint. O que falta nao e descobrir o que esta verde — e **carimbar o que ja esta verde como release**, atualizando manifesto, evidencias, changelog e tag.

Nao e o momento de iniciar a documentacao detalhada de todos os testes. A auditoria 21 ja entregou matriz de cobertura, dicionario semantico e veredito de unificacao. Documentar exaustivamente cada cenario antes de fechar a 0203 abriria uma frente longa que disputa atencao com o fechamento, e corre o risco de ficar desatualizada se houver qualquer microcorrecao adicional. A documentacao narrada de todos os testes e a primeira tarefa **pos-0203**, ja com a release oficial estavel servindo de espelho.

A organizacao atual de documentos esta **aceitavel mas com saneamento pequeno pendente**. Nao ha duplicacao grave. A pasta `doc/` e quase toda dado bruto de CNAE e nao colide com `docs/`. O `local-ai/` ja esta gitignored e nao polui o GitHub publico. Os tres pontos que precisam de toque sao: (i) deixar explicito no `docs/INDEX.md` que `doc/` e dado bruto e nao documentacao; (ii) consolidar o ponteiro publico das auditorias 0203 no `README.md`; (iii) acrescentar um arquivo de fechamento da 0203 (este documento ja inicia esse ponteiro).

A prioridade imediata, em uma frase: **rodar mais uma vez o trio minimo, escrever o documento `auditoria/24_FECHAMENTO_V12_0203.md`, publicar a evidencia em `auditoria/evidencias/V12.0.0203/`, atualizar `App_Release`, `STATUS-OFICIAL`, release note, `CHANGELOG.md` e tag `v12.0.0203`, e so depois abrir a frente de documentacao narrada de todos os testes**.

## 01. Estado Real da V12.0.0203

### 01.1 O que ja foi feito

- governanca de release ampliada para diferenciar release oficial, canal ativo, proxima release alvo e build importado, conforme `docs/GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md`;
- tela `Sobre` exibe commit importado, branch e data de geracao do pacote, com texto encurtado para evitar truncamento de `MsgBox`;
- familia canonica V2 consolidada (`CS_00..CS_22`, mais `CS_23` e `CS_24`), com primeiro, segundo e terceiro lotes ja validados em workbook;
- V2 Smoke reforcado com `EXP_001`, `MIG_001..MIG_004`, `MUT_001`, `ATM_001` e `SMK_007` enriquecido;
- V1 rapida e assistida unificadas semanticamente: mesma bateria, diferenca apenas de pausa visual;
- CSV automatico passou a ser sinal de falha;
- abas antigas e snapshots `SNAPV2_*` limpas via opcao explicita;
- trilha cumulativa `TESTE_TRILHA` e `AUDIT_TESTES` separa narrativa da suite de auditoria operacional;
- primeiras fatias de desacoplamento entregues em avaliacao, emissao de Pre-OS/OS e configuracao de pagina dos relatorios;
- microcorrecoes de compilacao por tipos/instancias implicitas resolvidas localmente, sem tocar `Mod_Types.bas`.

### 01.2 O que esta validado por testes

- compilacao limpa no build `88107f1`;
- Bateria Oficial V1 rapida em 2026-04-26: `OK=171`, `FALHA=0`;
- V2 Smoke em 2026-04-26: `OK=14`, `FALHA=0`, sem CSV de falhas;
- V2 Canonica em 2026-04-26: `OK=20`, `FALHA=0`, sem CSV de falhas;
- cobertura do modelo de negocio em 58 de 59 regras catalogadas (R-48 transacao aninhada e a unica lacuna teorica remanescente).

### 01.3 O que ainda esta pendente para fechar a 0203

- consolidar manifesto/evidencia formal da `V12.0.0203` em `auditoria/evidencias/V12.0.0203/`;
- atualizar `src/vba/App_Release.bas` para `APP_RELEASE_ATUAL = "V12.0.0203"`, `APP_RELEASE_STATUS = "VALIDADO"`, `APP_BUILD_IMPORTADO` igual ao commit do pacote final;
- atualizar `obsidian-vault/releases/STATUS-OFICIAL.md` movendo `V12.0.0203` de `DESENVOLVIMENTO` para `VALIDADA` e marcando `V12.0.0202` como `SUPERADA`;
- criar release note em `obsidian-vault/releases/V12.0.0203.md`;
- mover o bloco `[Unreleased]` do `CHANGELOG.md` para `[V12.0.0203] - YYYY-MM-DD`;
- criar tag `v12.0.0203` apos compilacao confirmada;
- atualizar `obsidian-vault/00-DASHBOARD.md` para refletir nova release oficial;
- rodar mais uma vez o trio minimo no build de fechamento e arquivar os CSVs de evidencia (mesmo verdes, dessa vez com a evidencia carimbada);
- atualizar `auditoria/INDEX.md` e `docs/INDEX.md` para incluir `24_FECHAMENTO_V12_0203.md` e `RELEASE_V12_0_0203.md`.

### 01.4 O que deve ser explicitamente adiado

- documentacao narrada cenario a cenario de toda a bateria;
- proposta arquitetural completa de portal unico das centrais de teste (PT-01..PT-03 da auditoria 21);
- desacoplamento total tela a tela do `Menu_Principal.frm`;
- reescrita do importador automatico;
- revisao estrutural de `Mod_Types.bas`;
- redesign visual completo dos relatorios e exportacao automatica de PDF com nome controlado;
- prova arquitetural da regra R-48 (transacao aninhada);
- unificacao fisica V1/V2 no codigo.

### 01.5 Riscos ainda existentes

- janela de tentacao para abrir nova frente antes do fechamento ser carimbado; o risco e voltar a ser "quase pronto" por mais uma semana;
- divergencia entre `local-ai/incoming/vba-forms/Mod_Types.bas` e `src/vba/Mod_Types.bas` se algum operador reimportar fora do pacote canonico;
- acumulo de pastas `V12-202-*/` na raiz com snapshots de `.xlsm`; nao e risco de codigo mas e risco de ruido visual no repositorio;
- ausencia de documentacao narrada amplia o custo de onboarding de uma proxima IA, mas e risco controlado enquanto a auditoria 21 estiver vigente.

## 02. Auditoria da Estrutura Atual de Documentacao

A leitura abaixo respeita o estado real do disco em 2026-04-26 e nao propoe nenhuma movimentacao de arquivo nesta sessao.

### 02.1 `docs/`

- funcao atual: documentacao publica oficial, INDEX.md, governanca de release, arquitetura, compliance, proposta canonica V2, area `docs/testes/` para padronizacao narrativa, area `docs/licenca/` e `docs/legal/`;
- problema encontrado: cresceu sem categoria interna explicita; INDEX.md ainda lista `doc/` como se fosse documentacao;
- funcao recomendada: continuar como destino publico canonico da documentacao;
- destino: **publico no GitHub**, mantida.

### 02.2 `doc/`

- funcao atual: dados brutos e normalizados de CNAE (`cnae-fonte-bruta/`, `cnae-normalizado/`), 4.1 MB de CSV/dados de referencia;
- problema encontrado: nome confunde com `docs/` por afinidade ortografica; nao e documentacao, e dado de referencia;
- funcao recomendada: renomear para `data/cnae/` ou `docs/dados/cnae/` em algum momento futuro;
- destino: **publico no GitHub** (dados de referencia podem ser publicos), mas com saneamento de nome adiado para pos-0203.

### 02.3 `auditoria/`

- funcao atual: auditorias publicas numeradas 00 a 22, mais `evidencias/V12.0.0202/`;
- problema encontrado: nenhum critico; numeracao com lacunas (saltos entre 04 e 14, etc.) ja explicada pelo proprio INDEX;
- funcao recomendada: manter como trilha publica de auditoria;
- destino: **publico no GitHub**, mantida.

### 02.4 `obsidian-vault/`

- funcao atual: dashboard publico, manifest, `releases/STATUS-OFICIAL.md`, release notes publicas, `releases/historico/`;
- problema encontrado: pequeno (292 KB), mistura dashboard institucional com release notes; `.obsidian/` ja gitignored;
- funcao recomendada: manter como ponte de leitura institucional publica e fonte canonica do status oficial;
- destino: **publico no GitHub**, mantido.

### 02.5 `local-ai/`

- funcao atual: vault interno completo, prompts, scripts, vba_export e vba_import, incoming, historico interno;
- problema encontrado: nenhum no eixo publicacao porque ja esta no `.gitignore`;
- funcao recomendada: continuar como repositorio interno de contexto de IAs e operacoes locais;
- destino: **interno**, nunca publico.

### 02.6 `local-ai/auditoria/`

- funcao atual: prompts e pareceres internos numerados 01 a 33, planos da esteira, instrucoes operacionais;
- problema encontrado: numeracao desconectada da numeracao publica `auditoria/`; sem subdivisao entre `prompts/`, `pareceres/`, `planos/`;
- funcao recomendada: manter mas adotar subpastas conceituais sem mover arquivos agora;
- destino: **interno**.

### 02.7 `local-ai/obsidian-vault/`

- funcao atual: vault Obsidian interno (regras, ai/, handoff/, backlog, historico, releases internos com 136 arquivos);
- problema encontrado: duplica visualmente `obsidian-vault/` publico, o que pode confundir; mas e o vault interno legitimo;
- funcao recomendada: manter como vault de contexto interno para IAs;
- destino: **interno**.

### 02.8 `local-ai/root/`

- funcao atual: HANDOFF.md vigente, `.cursorrules` e estrategia historica `ESTRATEGIA-V12-106.md`;
- problema encontrado: nome `root` e confuso; o conteudo e handoff e regras, nao raiz;
- funcao recomendada: manter como esta neste ciclo (renomear so pos-0203);
- destino: **interno**.

### 02.9 `local-ai/incoming/`

- funcao atual: `vba-forms/` com export real do workbook (Mod_Types, Menu_Principal.frm/.frx, Altera/Reativa Entidade, README);
- problema encontrado: papel de "referencia operacional do workbook real" ja documentado; risco e algum operador usar como fonte de importacao;
- funcao recomendada: manter como referencia, com aviso continuo de "nao usar como fonte de importacao manual";
- destino: **interno**.

### 02.10 `local-ai/vba_import/`

- funcao atual: pacote local de deploy, ordenado, gerado via `publicar_vba_import.sh` a partir de `src/vba/`;
- problema encontrado: nenhum, e a fonte de importacao manual canonica;
- funcao recomendada: manter;
- destino: **interno**.

### 02.11 `src/vba/`

- funcao atual: fonte da verdade publica do codigo VBA (60 arquivos);
- problema encontrado: nenhum estrutural; o codigo carrega o seu proprio risco arquitetural ja descrito na auditoria 21;
- funcao recomendada: continuar como fonte unica de edicao;
- destino: **publico no GitHub**, mantida.

## 03. Mapa de Saneamento Documental

| Caminho atual | Problema | Caminho canonico proposto | Acao | Risco | Prioridade | IA responsavel |
|---|---|---|---|---|---|---|
| `doc/cnae-fonte-bruta/`, `doc/cnae-normalizado/` | nome `doc/` colide visualmente com `docs/`; conteudo e dado, nao documentacao | `docs/dados/cnae/fonte-bruta/`, `docs/dados/cnae/normalizado/` | mover **apos** fechamento da 0203 | medio (paths usados por scripts ou planilhas precisam ser auditados antes) | baixa | Codex |
| `docs/INDEX.md` linha "[doc](../doc)" | aponta para dado como se fosse codigo/documentacao | substituir por nota "dados de referencia em `doc/` (CNAE)" | editar em micro PR | baixo | media | Codex |
| Raiz com `V12-202-E..K/` | snapshots de `.xlsm` de homologacao acumulam na raiz | `backups/homologacao/V12-202-X/` (interno, ja gitignored) | mover **apos** 0203 | baixo (xlsm ja gitignored) | media | Codex |
| `local-ai/auditoria/` plano | mistura prompts, pareceres e planos sem subdivisao | `local-ai/auditoria/prompts/`, `pareceres/`, `planos/` | criar subpastas no proximo ciclo, sem mover historico | baixo | baixa | Claude Opus |
| `local-ai/root/` | nome ambiguo | `local-ai/handoff/` | renomear pos-0203 | baixo | baixa | Codex |
| `obsidian-vault/00-DASHBOARD.md` | menciona V12.0.0202 como versao vigente | atualizar para V12.0.0203 no fechamento | edicao no fechamento | baixo | alta no fechamento | Codex |
| `auditoria/INDEX.md` | falta apontar `23_PARECER_OPUS_*` (este doc) e o futuro `24_FECHAMENTO_V12_0203.md` | adicionar entradas no fechamento | edicao | baixo | alta no fechamento | Codex |
| `docs/INDEX.md` secao "Releases e status" | precisa apontar nova release `V12.0.0203.md` | adicionar entrada no fechamento | edicao | baixo | alta no fechamento | Codex |
| `CHANGELOG.md` `[Unreleased]` | precisa virar `[V12.0.0203] - YYYY-MM-DD` | mover bloco | baixo | alta no fechamento | Codex |

## 04. Estrutura Final Recomendada Para o GitHub Publico

```text
.
├── README.md
├── LICENSE
├── CLA.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── CHANGELOG.md
├── PlanilhaCredenciamento-Homologacao.xlsm    # gitignored
├── .github/                                   # workflows publicos
├── src/
│   └── vba/                                   # fonte da verdade
├── docs/                                      # documentacao publica
│   ├── INDEX.md
│   ├── ARQUITETURA.md
│   ├── COMPLIANCE_CMMI_ISO.md
│   ├── ESTRATEGIA_DE_ATUACAO.md
│   ├── GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md
│   ├── GUIA_DE_ACESSO_A_MATERIAIS_OPERACIONAIS.md
│   ├── PROPOSTA_TESTES_V2_CENARIO_CANONICO.md
│   ├── RELEASE_V12_0_0203.md                  # novo, criado no fechamento
│   ├── testes/
│   │   ├── INDEX.md
│   │   ├── 00_MODELO_DOCUMENTAL_DOS_TESTES.md
│   │   ├── 01_EVIDENCIAS_E_RELATORIOS_DE_TESTE.md
│   │   ├── 02_CATALOGO_BATERIA_OFICIAL_V1.md  # pos-0203
│   │   ├── 03_CATALOGO_SMOKE_V2.md            # pos-0203
│   │   ├── 04_CATALOGO_ASSISTIDOS.md          # pos-0203
│   │   └── 05_DICIONARIO_INTERFACE.md         # pos-0203
│   ├── licenca/
│   ├── legal/
│   └── dados/
│       └── cnae/                              # renomear pos-0203 (era doc/)
├── auditoria/
│   ├── INDEX.md
│   ├── 00..22*.md
│   ├── 23_PARECER_OPUS_FECHAMENTO_E_ORGANIZACAO_V12_0203.md
│   ├── 24_FECHAMENTO_V12_0203.md              # novo, fechamento formal
│   └── evidencias/
│       ├── V12.0.0202/
│       └── V12.0.0203/                        # novo, evidencia da 0203
├── obsidian-vault/
│   ├── 00-DASHBOARD.md
│   ├── MANIFEST.md
│   └── releases/
│       ├── STATUS-OFICIAL.md
│       ├── V12.0.0202.md
│       ├── V12.0.0203.md                      # novo
│       └── historico/
└── (gitignored: local-ai/, backups/, V12-202-*/, *.xlsm, *.csv de bateria)
```

O que aparece no GitHub: tudo acima exceto o que esta `.gitignore`.

O que nao deve aparecer: `local-ai/`, `local-only/`, `historico/`, `V12-093/`, `BKP_forms/`, `backups/`, `.continue/`, planilhas `.xlsm` e `.xlsx`, CSVs de bateria. Tudo isso ja esta gitignored.

O que deve ser simplificado: o `docs/INDEX.md` deve deixar claro que `auditoria/` e `obsidian-vault/` sao publicos e parte da leitura canonica; e que `doc/` (ou `docs/dados/`) e dado de referencia, nao documentacao.

O que deve ser referencia para outros projetos: `docs/GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md`, `docs/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md`, `auditoria/19_AUDITORIA_PONTOS_FORTES_V12_0202.md` e `auditoria/21_AUDITORIA_UNIFICADA_TESTES_V12_0203.md`. Esses quatro carregam o nucleo metodologico do projeto.

## 05. Estrutura Interna Recomendada Para IAs

Proposta concreta, sem mover arquivo nesta sessao:

```text
local-ai/
├── root/                                # manter neste ciclo; renomear pos-0203 se desejado
│   ├── HANDOFF.md                       # estado atual + bastao corrente
│   └── ESTRATEGIA-V12-106.md            # historico
├── auditoria/
│   ├── INDEX.md                         # criar; mapeia 01..33 por categoria
│   ├── prompts/                         # subpasta conceitual; cria-se quando houver tempo
│   │   └── (prompts 12, 16, 21..33)
│   ├── pareceres/                       # subpasta conceitual
│   ├── planos/                          # ESTEIRA_*, PADRONIZACAO_*
│   └── briefings/                       # 13_BRIEFING_*, 25_BRIEFING_*, 26_BRIEFING_*
├── obsidian-vault/
│   ├── 01-CONTEXTO-IA.md
│   ├── ai/
│   │   ├── ESTADO-ATUAL.md              # vivo, atualizado a cada bastao
│   │   ├── REGRAS.md
│   │   ├── PIPELINE.md
│   │   ├── GOVERNANCA.md
│   │   ├── known-issues.md
│   │   ├── bastao/                      # log do bastao de IA em IA
│   │   ├── handoffs/                    # prompts por IA
│   │   └── prompt-iteracao-segura.md
│   ├── regras/
│   ├── decisoes/                        # opcional; hoje vive em historico/
│   └── releases/                        # release notes internas
├── incoming/
│   └── vba-forms/                       # referencia operacional do workbook
├── vba_export/
├── vba_import/
├── scripts/
└── historico/                           # backups e versoes antigas
```

A criacao das subpastas conceituais em `local-ai/auditoria/prompts/`, `pareceres/`, `planos/`, `briefings/` deve ser feita **sem mover arquivos historicos**. O criterio simples e: arquivos novos a partir de 2026-04-26 nascem na subpasta correta; arquivos antigos so migram quando alguem precisar tocar neles.

## 06. Governanca do Bastao Entre IAs

| IA / agente | Papel | Quando entra | Quando sai | Pode editar | Nao deve tocar | Evidencia ao finalizar |
|---|---|---|---|---|---|---|
| **Codex (GPT-5)** | executor principal de microevolucoes e integracao | sempre que houver microcorrecao aprovada, atualizacao de documento curto, geracao de pacote `vba_import/` | quando entregar arquivo unico, rodar `publicar_vba_import.sh` e registrar no `HANDOFF.md` | `src/vba/*` (1 arquivo por iteracao), `auditoria/`, `docs/`, `CHANGELOG.md`, `obsidian-vault/releases/`, `local-ai/vba_import/` | `Mod_Types.bas` (sem aprovacao expressa), nucleo do rodizio sem bug confirmado, importador automatico, `local-ai/incoming/` como fonte | commit + diff + nota curta no `HANDOFF.md` |
| **Claude Opus (esta sessao e futuras)** | auditor, documentador estrategico, revisor de plano | quando for preciso parecer, organizacao documental, plano de fechamento, revisao semantica de testes | ao entregar parecer em `auditoria/` ou plano em `local-ai/auditoria/planos/` | `auditoria/*.md`, `docs/*.md`, `local-ai/auditoria/`, `local-ai/obsidian-vault/ai/ESTADO-ATUAL.md` | nao edita `src/vba/`, nao gera pacote `vba_import/`, nao altera `App_Release.bas`, nao cria tag | parecer publicado, INDEX atualizado, handoff anotado |
| **Claude Sonnet** | implementacao de feature curta quando autorizada | apenas se Codex estiver indisponivel; tarefa precisa caber em 1 arquivo | ao entregar arquivo + checklist | igual a Codex (escopo restrito) | igual a Codex | igual a Codex |
| **IA de documentacao narrada de testes (futura)** | escrever `docs/testes/02..04.md` apos fechamento da 0203 | apos publicacao da V12.0.0203 e congelamento da bateria | ao entregar 3 catalogos narrados | `docs/testes/02_*.md`, `03_*.md`, `04_*.md`, `docs/testes/INDEX.md` | nao edita `src/vba/`, nao altera roteiros V2 | os 3 documentos publicados e indexados |
| **Humano (Mauricio)** | aprovador final, executor das validacoes manuais (compilar, rodar bateria, conferir Sobre, criar tag) | em todo gate de release e em decisoes de risco | quando der "OK" registrado no commit ou no handoff | qualquer coisa | nada (ele e a fronteira) | nota explicita no handoff |

Regra de circulacao do bastao: quem termina sua entrega anota em `local-ai/root/HANDOFF.md` o estado deixado, o proximo passo e quem deve pegar o bastao. A proxima IA so trabalha apos ler o HANDOFF e o INDEX da auditoria.

## 07. Modelo Padrao de Documento de Microevolucao

O template abaixo deve viver em `local-ai/auditoria/planos/MODELO_MICROEVOLUCAO.md` (template) e cada microevolucao real publica deve viver em `auditoria/microevolucoes/ME_NNN_*.md` quando a 0203 fechar e essa pratica for adotada. Durante a 0203, o registro pode continuar acontecendo dentro do `CHANGELOG.md` para nao abrir frente nova.

```markdown
---
id: ME-NNN
release-alvo: V12.0.0XXX
build-relacionado: <commit curto>
data: YYYY-MM-DD
ia-responsavel: <Codex | Claude Opus | Claude Sonnet | Humano>
humano-aprovador: Mauricio Zanin
status: <em-andamento | feito | pendente | adiado | rejeitado>
---

# ME-NNN — <titulo curto>

## Objetivo
Uma frase. O que esta microevolucao busca resolver.

## Escopo
O que entra. O que **nao** entra. Diferencie em duas listas curtas.

## Arquivos alterados
- `src/vba/...`
- `docs/...`
- `auditoria/...`

## Regras de negocio afetadas
Liste por codigo (R-XX) usando o catalogo da auditoria 03.

## Riscos
- regressao funcional plausivel
- compilacao
- importacao
- compatibilidade com workbook em homologacao

## Testes obrigatorios
- compilacao limpa
- Bateria Oficial V1 rapida
- V2 Smoke
- V2 Canonica
- (cenarios extras se aplicavel)

## Resultado esperado
Tres a cinco linhas.

## Resultado obtido
Preencher apos execucao. Citar OK/FALHA, build importado, data.

## Decisao
<feito | pendente | adiado | rejeitado>

## Observacoes
Texto livre curto. Link para HANDOFF.
```

## 08. Decisao Metodologica: Documentar Todos os Testes Agora ou Depois?

**Resposta direta: depois.** Primeiro fechar a V12.0.0203, depois iniciar a documentacao narrada cenario a cenario.

### 08.1 Por que nao agora

- a auditoria 21 ja entregou o veredito tecnico, a matriz de cobertura, o dicionario semantico canonico, o plano de unificacao e o catalogo dos cenarios atuais em forma resumida; isso responde 80% das perguntas que a documentacao narrada responderia;
- documentar 150+ cenarios em padrao narrativo canonico (leitura, matriz, blocos, catalogo, pre-condicao/acao/resultado/razao) e tarefa longa, com pelo menos 3 documentos novos (`02_CATALOGO_BATERIA_OFICIAL_V1.md`, `03_CATALOGO_SMOKE_V2.md`, `04_CATALOGO_ASSISTIDOS.md`);
- enquanto a 0203 nao for carimbada, qualquer microcorrecao que entrar invalida partes da documentacao recem-escrita;
- existe uma ordem natural: codigo congelado, tag publicada, depois documentacao escrita sobre o que esta congelado;
- o risco de tentar documentar tudo antes de fechar a release e atrasar o fechamento por semanas e perder a janela atual de "tudo verde, ninguem mexendo".

### 08.2 Por que adiar tem custo controlado

- a auditoria 21 ja serve como leitura institucional unica para gestor, auditor externo e mantenedor tecnico;
- o `docs/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md` ja descreve os cenarios `CS_*` com o padrao narrativo;
- o `docs/testes/00_MODELO_DOCUMENTAL_DOS_TESTES.md` e o `01_EVIDENCIAS_E_RELATORIOS_DE_TESTE.md` ja fixam a regra metodologica;
- uma proxima IA tem informacao suficiente para entender a bateria sem precisar abrir VBA imediatamente.

### 08.3 Escopo minimo agora

- atualizar `docs/testes/INDEX.md` para deixar claro que os tres catalogos narrados (`02`, `03`, `04`) estao planejados para o ciclo pos-0203;
- adicionar um pequeno aviso em cada `docs/testes/` que aponta para a auditoria 21 como leitura provisoria;
- nao iniciar `02_*`, `03_*`, `04_*` durante a 0203.

### 08.4 Preparacao que ja deve estar feita agora

- congelamento do catalogo `CS_*`, `SMK_*`, `STR_*`, `ATM_*`, `EXP_*`, `MIG_*`, `MUT_*`, `ASS_*`, UI-* e P-* (ja feito);
- registro de cada cenario novo no `CHANGELOG.md` por codigo (ja feito);
- dicionario canonico DI-01 a DI-04 publicado na auditoria 21 (ja feito);
- matriz R-01..R-59 versus cenarios cobertos publicada na auditoria 21 (ja feito).

### 08.5 Riscos comparados

- **Risco de documentar tudo agora**: atrasa fechamento, abre frente longa concorrente com a 0203, gera doc desatualizada na primeira microcorrecao seguinte, ocupa Claude Opus quando Codex precisa de revisao tatica.
- **Risco de adiar a documentacao narrada**: aumento marginal do custo de onboarding de uma proxima IA; mitigado pela auditoria 21; reversivel a qualquer momento na semana seguinte ao fechamento.

A decisao recomendada e adiar com data alvo: iniciar `docs/testes/02_*.md` no primeiro dia util apos a tag `v12.0.0203` ser publicada.

## 09. Plano de Documentacao dos Testes

| Etapa | Documento sugerido | Status agora | Prioridade | IA responsavel | Criterio de aceite |
|---|---|---|---|---|---|
| V1 rapida | `docs/testes/02_CATALOGO_BATERIA_OFICIAL_V1.md` | adiado para pos-0203 | alta apos fechamento | IA de documentacao narrada (Claude Opus em modo doc) | todos os blocos `BO_*` narrados nas 5 rubricas, com tabela bloco -> regra -> arquivo VBA |
| V1 assistida / lenta | inclusa em `04_CATALOGO_ASSISTIDOS.md` | adiado | media apos fechamento | IA de documentacao narrada | distincao explicita entre rapida e assistida; rubricas adaptadas a verificacao humana |
| V2 Smoke | `docs/testes/03_CATALOGO_SMOKE_V2.md` | adiado | alta apos fechamento | IA de documentacao narrada | `SMK_001..SMK_007`, `EXP_001`, `ATM_001`, `MIG_001..004`, `MUT_001` narrados |
| V2 Canonica | ja em `docs/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md` | feito (forma de proposta) | revisao leve apos fechamento | Claude Opus | reler e marcar como "incorporado e vigente" no INDEX, sem reescrever |
| Stress (`STR_001`) | secao em `03_CATALOGO_SMOKE_V2.md` | adiado | media | IA de documentacao narrada | invariantes provadas e ampliacoes registradas |
| Funcao (R-01..R-59) | matriz ja publicada na auditoria 21 secao 03 | feito | manter | Claude Opus em revisoes futuras | manter referencia, nao duplicar |
| Interface desacoplada (futura) | `docs/testes/06_INTERFACE_DESACOPLADA.md` | nao existe; criar pos-0203 quando portal unico for entregue | baixa | Claude Opus + Codex | apos PT-01..PT-03 da auditoria 21 |
| Dicionario de interface | `docs/testes/05_DICIONARIO_INTERFACE.md` | proposto na auditoria 21 | media apos fechamento | Claude Opus | publicado e referenciado pelos catalogos |

Regra para todos esses documentos: padrao narrativo canonico do `docs/testes/00_MODELO_DOCUMENTAL_DOS_TESTES.md`. Sem excecao.

## 10. Roadmap de Microevolucoes Para Fechar a V12.0.0203

### 10.1 Obrigatorio antes de fechar

1. reexecutar o trio minimo (V1 rapida, V2 Smoke, V2 Canonica) no build final candidato, salvar CSVs em `auditoria/evidencias/V12.0.0203/`;
2. atualizar `src/vba/App_Release.bas`: `APP_RELEASE_ATUAL = "V12.0.0203"`, `APP_RELEASE_STATUS = "VALIDADO"`, `APP_RELEASE_CANAL = "OFICIAL"`, `APP_BUILD_IMPORTADO` igual ao commit final, `APP_RELEASE_EVIDENCE_DIR = "auditoria/evidencias/V12.0.0203/"`;
3. criar `auditoria/24_FECHAMENTO_V12_0203.md` consolidando feito/pendente/adiado e citando este parecer 23;
4. criar `auditoria/evidencias/V12.0.0203/MANIFEST.md` com hash dos CSVs e citacao do build, branch e validador humano;
5. criar `obsidian-vault/releases/V12.0.0203.md` com objetivo, escopo, validacao e link para evidencia;
6. atualizar `obsidian-vault/releases/STATUS-OFICIAL.md` (V12.0.0203 -> VALIDADA, V12.0.0202 -> SUPERADA);
7. mover bloco `[Unreleased]` do `CHANGELOG.md` para `[V12.0.0203] - YYYY-MM-DD`;
8. atualizar `obsidian-vault/00-DASHBOARD.md`;
9. atualizar `auditoria/INDEX.md` e `docs/INDEX.md`;
10. publicar tag `v12.0.0203` apos compilacao confirmada.

### 10.2 Recomendado se nao gerar risco

- escrever este parecer em formato breve no `obsidian-vault/releases/V12.0.0203.md` (resumo institucional, nao tecnico);
- adicionar ao `verify-docs.yml` a checagem de presenca do diretorio `auditoria/evidencias/V12.0.0203/` quando a tag `v12.0.0203` for criada;
- atualizar `local-ai/obsidian-vault/ai/ESTADO-ATUAL.md` para refletir que a 0203 foi publicada.

### 10.3 Apenas se nao gerar risco

- mover snapshots `V12-202-*` da raiz para `backups/homologacao/` (ja gitignored, baixissimo risco);
- ajustar `docs/INDEX.md` para chamar `doc/` de "dados de referencia" sem renomear a pasta.

### 10.4 Nao fazer agora

- iniciar `docs/testes/02_*.md`, `03_*.md`, `04_*.md`;
- portal unico de testes (PT-01..PT-03);
- desacoplamento total tela a tela;
- redesign visual completo dos relatorios;
- mexer em `Mod_Types.bas`;
- prova arquitetural da R-48;
- renomear `doc/` para `docs/dados/cnae/`;
- reescrever importador automatico.

## 11. Backlog Pos-0203

- documentacao narrada dos testes (`docs/testes/02..05.md`);
- portal unico das centrais de teste (PT-01..PT-03 da auditoria 21);
- desacoplamento total tela a tela do `Menu_Principal.frm`;
- revisao controlada do importador automatico;
- revisao controlada de `Mod_Types.bas`, com plano de teste isolado;
- UX dos testes assistidos (D1 da auditoria 20);
- unificacao mais forte V1/V2 sob dicionario canonico;
- exportacao automatica de PDF com nome controlado tipo `EMPRESAS_CREDENCIADAS_YYYYMMDD_HHMMSS.pdf`;
- padronizacao visual profunda dos relatorios (auditoria do prompt 33 ja preparada);
- log de relatorios emitidos;
- renomear `doc/` para `docs/dados/cnae/`;
- mover `V12-202-*/` para `backups/homologacao/`;
- prova arquitetural da regra R-48 (transacao aninhada);
- atualizacao do `verify-docs.yml` com checagem de hash do pacote de evidencias.

## 12. Fronteiras de Risco

Sem autorizacao explicita do humano, nao tocar em:

- `src/vba/Mod_Types.bas`;
- nucleo do rodizio (`Svc_Rodizio.bas`), salvo bug comprovado;
- `Svc_PreOS.bas`, `Svc_OS.bas`, `Svc_Avaliacao.bas`, salvo bug comprovado;
- `Svc_Transacao.bas`, salvo correcao isolada e curta;
- `Importador_VBA.bas` e `local-ai/vba_import/Importar_Agora.bas`;
- estrutura de formularios `.frm` e seus `.frx`, salvo correcoes pontuais (pequenos textos, defaults, navegacao bloqueante);
- ordem de importacao em `local-ai/vba_import/000-ORDEM-IMPORTACAO.txt`;
- mudancas que exijam reimportacao ampla sem necessidade.

Regra simples: se a microcorrecao precisa abrir mais de um arquivo da lista acima, ela ja saiu da fronteira segura e deve virar um plano formal para o pos-0203.

## 13. Artefatos Propostos

| Arquivo | Finalidade | Publico/Interno | Quem escreve | Quem revisa | Vai para o GitHub |
|---|---|---|---|---|---|
| `auditoria/23_PARECER_OPUS_FECHAMENTO_E_ORGANIZACAO_V12_0203.md` | este parecer | publico | Claude Opus | Mauricio | sim |
| `auditoria/24_FECHAMENTO_V12_0203.md` | fechamento formal da release, consolidando feito/pendente/adiado e link para evidencia | publico | Codex (esqueleto) + Claude Opus (revisao) | Mauricio | sim |
| `auditoria/evidencias/V12.0.0203/MANIFEST.md` | manifesto hashado da evidencia | publico | Codex | Mauricio | sim |
| `auditoria/evidencias/V12.0.0203/*.csv` | CSVs do trio minimo no build final | publico | gerado pela bateria | Mauricio | sim |
| `docs/RELEASE_V12_0_0203.md` | nota de release publica orientada a leitor externo | publico | Claude Opus | Mauricio | sim |
| `obsidian-vault/releases/V12.0.0203.md` | release note institucional | publico | Claude Opus + Codex | Mauricio | sim |
| `local-ai/root/HANDOFF.md` | atualizar bastao para apontar Codex como responsavel pelo carimbo de release | interno | Codex | Mauricio | nao |
| `local-ai/auditoria/34_PARECER_ORGANIZACAO_DOCUMENTAL_V12_0203.md` | versao interna deste parecer com notas operacionais (opcional) | interno | Claude Opus | — | nao |
| `local-ai/obsidian-vault/ai/ESTADO-ATUAL.md` | atualizar para refletir 0203 fechada apos a tag | interno | Codex | Mauricio | nao |
| `local-ai/auditoria/planos/MODELO_MICROEVOLUCAO.md` | template de microevolucao da secao 07 | interno | Claude Opus | Mauricio | nao |
| `docs/testes/02_CATALOGO_BATERIA_OFICIAL_V1.md` | catalogo narrado V1 | publico | IA pos-0203 | Mauricio | sim, **pos-0203** |
| `docs/testes/03_CATALOGO_SMOKE_V2.md` | catalogo narrado Smoke V2 | publico | IA pos-0203 | Mauricio | sim, **pos-0203** |
| `docs/testes/04_CATALOGO_ASSISTIDOS.md` | catalogo narrado assistidos | publico | IA pos-0203 | Mauricio | sim, **pos-0203** |
| `docs/testes/05_DICIONARIO_INTERFACE.md` | dicionario de interface | publico | Claude Opus | Mauricio | sim, **pos-0203** |

## 14. Criterios de Aceite

A documentacao e a governanca da 0203 estao prontas para fechamento quando:

1. `auditoria/22_STATUS_MICROEVOLUCOES_V12_0203.md` continua valido como checkpoint atual e foi referenciado por `auditoria/24_FECHAMENTO_V12_0203.md`;
2. `auditoria/23_PARECER_OPUS_FECHAMENTO_E_ORGANIZACAO_V12_0203.md` (este documento) esta publicado e indexado no `auditoria/INDEX.md` e no `docs/INDEX.md`;
3. `auditoria/24_FECHAMENTO_V12_0203.md` existe, lista feito/pendente/adiado e cita o build final, o validador humano, a data e a tag;
4. `auditoria/evidencias/V12.0.0203/MANIFEST.md` existe e os CSVs do trio minimo estao arquivados;
5. `src/vba/App_Release.bas` aponta para `V12.0.0203`, `VALIDADO`, `OFICIAL`, com `APP_BUILD_IMPORTADO` igual ao commit final;
6. `obsidian-vault/releases/STATUS-OFICIAL.md` reflete a transicao 0202 -> SUPERADA, 0203 -> VALIDADA;
7. `obsidian-vault/releases/V12.0.0203.md` existe;
8. `obsidian-vault/00-DASHBOARD.md` aponta a nova release oficial;
9. `CHANGELOG.md` tem secao `[V12.0.0203]`;
10. tag `v12.0.0203` criada e publicada;
11. `local-ai/root/HANDOFF.md` deixa claro que o bastao volta para o repouso ate o inicio da documentacao narrada pos-0203;
12. nenhuma frente de risco aberta sem necessidade (Mod_Types intocado, importador intocado, nucleo do rodizio intocado, formularios sem reimportacao ampla);
13. uma proxima IA consegue continuar lendo apenas: `auditoria/24_FECHAMENTO_V12_0203.md`, `auditoria/22_STATUS_MICROEVOLUCOES_V12_0203.md`, `auditoria/23_PARECER_OPUS_FECHAMENTO_E_ORGANIZACAO_V12_0203.md`, `auditoria/21_AUDITORIA_UNIFICADA_TESTES_V12_0203.md`, `docs/GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md` e `local-ai/root/HANDOFF.md`.

## 15. Prompt/Handoff Para a Proxima IA

```text
Voce esta assumindo o bastao do projeto Credenciamento na linha V12.0.0203,
release oficial vigente V12.0.0202.

Estado atual:
- build ancora 88107f1 validado em 2026-04-26;
- compilacao limpa, V1 rapida OK=171/FALHA=0, V2 Smoke OK=14/FALHA=0,
  V2 Canonica OK=20/FALHA=0;
- a 0203 esta em fase de fechamento, nao de expansao;
- documentacao narrada de todos os testes esta deliberadamente adiada
  para pos-0203.

NAO mexer em (sem autorizacao expressa de Mauricio):
- src/vba/Mod_Types.bas
- src/vba/Importador_VBA.bas
- nucleo do rodizio (Svc_Rodizio.bas) sem bug comprovado
- Svc_PreOS, Svc_OS, Svc_Avaliacao sem bug comprovado
- estrutura de formularios .frm/.frx sem correcao pontual aprovada
- ordem de importacao em local-ai/vba_import/

Fazer primeiro (em ordem):
1. ler este HANDOFF inteiro;
2. ler auditoria/22_STATUS_MICROEVOLUCOES_V12_0203.md;
3. ler auditoria/23_PARECER_OPUS_FECHAMENTO_E_ORGANIZACAO_V12_0203.md;
4. conferir o build atual exibido na tela Sobre do workbook;
5. rodar mais uma vez o trio minimo de testes;
6. arquivar CSVs em auditoria/evidencias/V12.0.0203/;
7. atualizar src/vba/App_Release.bas para V12.0.0203/VALIDADO/OFICIAL;
8. criar obsidian-vault/releases/V12.0.0203.md;
9. atualizar obsidian-vault/releases/STATUS-OFICIAL.md;
10. mover bloco [Unreleased] do CHANGELOG.md para [V12.0.0203];
11. criar tag v12.0.0203 apos confirmacao humana;
12. atualizar auditoria/INDEX.md, docs/INDEX.md, obsidian-vault/00-DASHBOARD.md.

Arquivos de referencia:
- auditoria/21_AUDITORIA_UNIFICADA_TESTES_V12_0203.md (auditoria estrategica)
- auditoria/22_STATUS_MICROEVOLUCOES_V12_0203.md (checkpoint)
- auditoria/23_PARECER_OPUS_FECHAMENTO_E_ORGANIZACAO_V12_0203.md (este parecer)
- docs/GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md (regra de carimbo)
- local-ai/vba_import/README.md (regra de pacote)
- local-ai/obsidian-vault/regras/Orquestracao-IAs.md (papeis)

Testes obrigatorios antes da tag:
- compilacao limpa
- V1 rapida verde
- V2 Smoke verde
- V2 Canonica verde

Quem esta com o bastao agora: Codex, com Mauricio como aprovador final.
Claude Opus permanece em modo de revisao e parecer; nao executa codigo
nem cria tag.

Como devolver o bastao:
- editar local-ai/root/HANDOFF.md anotando data, build, status do trio
  minimo, qual arquivo foi publicado e qual o proximo passo;
- se ficou pendencia, listar como "pendente" e nao como "feito";
- se a tag foi publicada, anotar e marcar a 0203 como VALIDADA.

Pos-0203 (somente apos a tag):
- iniciar docs/testes/02_CATALOGO_BATERIA_OFICIAL_V1.md;
- iniciar docs/testes/03_CATALOGO_SMOKE_V2.md;
- iniciar docs/testes/04_CATALOGO_ASSISTIDOS.md;
- iniciar docs/testes/05_DICIONARIO_INTERFACE.md;
- avaliar saneamento de doc/ -> docs/dados/cnae/;
- avaliar movimentacao de V12-202-*/ para backups/homologacao/.
```

## 16. Conclusao

Recomendacao final: **adiar a documentacao completa dos testes** ate apos a tag `v12.0.0203` ser publicada. A janela atual e curta e valiosa, e deve ser usada para carimbar a release.

Proxima microevolucao a executar: **rodar uma ultima vez o trio minimo no build final candidato e atualizar `src/vba/App_Release.bas` para `V12.0.0203` validada**. Essa microevolucao tem escopo de um unico arquivo VBA mais a evidencia, respeita a fronteira de risco e fecha o ciclo.

Documento a criar primeiro: `auditoria/24_FECHAMENTO_V12_0203.md`. Ele e o irmao operacional deste parecer; cita-o, consolida o fechamento e ancora o manifesto da evidencia.

IA com o bastao agora: **Codex**, sob aprovacao de Mauricio. Claude Opus permanece em modo parecer/auditoria, sem editar codigo, sem tocar em pacote de importacao e sem criar tag. Apos a publicacao da 0203, o bastao passa a uma sessao dedicada de **documentacao narrada dos testes** (Claude Opus em modo doc), com escopo restrito aos arquivos `docs/testes/02..05.md`.
