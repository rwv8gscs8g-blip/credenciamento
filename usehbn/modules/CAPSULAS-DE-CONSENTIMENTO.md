---
titulo: Capsulas de Consentimento
tipo: modulo-do-usehbn
papel: unidade atomica de transferencia de conhecimento com consentimento assinado
audiencia: humano + ia
licenca: AGPLv3
---

# Capsulas de Consentimento

## O que e

Capsulas de Consentimento sao a infraestrutura do useHBN que permite
**transferir conhecimento entre fronteiras (privado → publico,
projeto → projeto, IA → IA) com assinatura, redacao e licenca
explicitas em cada unidade**. Cada artefato que cruza fronteira viaja
como capsula autocontida.

Sem capsulas, nada cruza a fronteira com seguranca: commits diretos
nao forcam consentimento granular, CLAs blanket nao sao reversiveis,
SBOMs descrevem software mas nao transferencias consensuais. A capsula
e a unidade canonica de promocao no useHBN.

> "Consent Capsules absolutamente fundamental, aderente a nossa
> tecnologia, deve ser incorporado como tecnologia do fluxo do useHBN
> e deve ser o primeiro projeto com fluxo estruturado para conversar
> para uma modelo em Rust, que evolua da linguagem atual para um
> repositorio que trate as caracteristicas da seguranca. Absolutamente
> fundamental. Pode ser uma tecnologia de assinatura, de
> compatibilidade e reducao de erros, bem em linha com os objetivos
> da linguagem de declarar o que esta em funcionamento e em controle."
>
> — Mauricio, 2026-05-06 (aprovacao formal)

A citacao acima fixa o papel ampliado: alem de veiculo de promocao
publica de licoes, capsulas sao **infraestrutura de assinatura,
compatibilidade e reducao de erros** entre componentes do useHBN.

## Estrutura da capsula (seis arquivos)

Cada capsula e um diretorio versionado com seis arquivos canonicos:

```text
capsule-NNN/
├── lesson.md              # conteudo (a licao em si)
├── evidence.json          # refs + hashes das evidencias locais
├── redaction-map.json     # tokens/strings substituidos antes de promover
├── consent.json           # quem autorizou, quando, escopo da licenca
├── license-target.txt     # AGPLv3 (publico) ou outro
└── hashes.json            # SHA-256 de cada arquivo (integridade)
```

Cada arquivo tem schema formal (Pydantic em Python, struct serde em
Rust). Especificacao tecnica completa em
[42_ROADMAP_CONSENT_CAPSULES_RUST.md](../../auditoria/00_status/42_ROADMAP_CONSENT_CAPSULES_RUST.md).

## Os cinco principios da capsula

| # | Principio | O que significa |
|---|---|---|
| 1 | **Unidade atomica de transferencia** | Nada cruza fronteira sem capsula completa; capsula nao se divide |
| 2 | **Auditavel individualmente** | Cada capsula e assinatura legivel; pode ser revisada isoladamente |
| 3 | **Modelo viral opt-in** | Operador consente capsula a capsula, nao acordo blanket |
| 4 | **Reversivel** | Revogacao por hash da capsula despromove o conteudo |
| 5 | **Editor-agnostica** | JSON + Markdown; ferramenta-neutra; sobrevive a qualquer stack |

## Ciclo de vida (type-state)

```text
Draft  →  Validated  →  Signed  →  Promoted
  ↑                                    │
  └─────── (revogacao por hash) ───────┘
```

| Estado | O que ja foi feito | Gate para o proximo |
|---|---|---|
| `Draft` | conteudo redigido em `lesson.md`; rascunho dos 6 arquivos | schema valido + redacao completa |
| `Validated` | schema dos 6 arquivos passa; redacao verificada contra lista canonica de tokens sensiveis | assinatura Ed25519 + hashes SHA-256 calculados |
| `Signed` | `consent.json` assinado; `hashes.json` finalizado; capsula imutavel | `license-target` declarado + autorizacao explicita do operador |
| `Promoted` | capsula publicada no destino (repo publico, outro projeto) | n/a (estado terminal; revogacao retorna a `Draft` com nota) |

A migracao Python → Rust formaliza este ciclo via type-state pattern:
`Capsule<Draft>` so expoe `validate()`; `Capsule<Validated>` so expoe
`sign()`; e assim por diante. Compilador trava transicoes invalidas
em tempo de tipo.

## Gates

| Transicao | Pergunta-chave | Mecanismo |
|---|---|---|
| Draft → Validated | Schema dos 6 arquivos esta correto e a redacao esta completa? | validador automatico (Pydantic / serde) + lista canonica de tokens |
| Validated → Signed | Hashes batem? Consent foi obtido do operador? | SHA-256 + Ed25519 + assinatura humana explicita |
| Signed → Promoted | A licenca de destino foi declarada e o operador autoriza? | `license-target.txt` + autorizacao final |
| Promoted → Draft (revogacao) | Houve solicitacao formal de despromocao? | nota append-only no historico + nova capsula descrevendo motivo |

## Diferencial vs alternativas

| Alternativa | O que falta nela | O que a capsula adiciona |
|---|---|---|
| Commit direto publico | Consentimento implicito; sem redacao formal | Forca consent.json e redaction-map.json |
| CLA blanket | Acordo unico cobre tudo; nao reversivel | Granular por capsula; revogacao por hash |
| SBOM (CycloneDX) | Descreve software, nao transferencia | Modelo conceitual de transferencia consensual |
| Verifiable Credentials W3C | Foco em identidade pessoal | Reaproveita espirito (declaracao assinada) para conhecimento operacional |

## Riscos e mitigacoes

- **Privacy leak por redacao incompleta**: lista canonica de tokens
  sensiveis verificada por gate antes de assinatura
- **Friction excessivo desincentiva contribuicao**: minimo viavel de
  campos obrigatorios (consent + redaction + license-target);
  helpers CLI (`hbn capsule create --from-lesson L18`) reduzem
  overhead
- **Compatibilidade de licenca**: cada capsula declara
  `license-target` explicitamente; AGPLv3 padrao para publico
- **Vendor risk**: zero — proposta interna useHBN, sem dependencia
  externa critica
- **Lock-in tecnico**: zero — spec textual; implementacao em Python
  inicialmente, Rust no destino

## Marcadores

| Marcador | Quando aplica |
|---|---|
| 🟫 HBN TREE TRANSITION | capsula migra entre arvores (Python → Rust em R-A → R-D) |
| 🟡 HBN NEEDS HUMAN DECISION | capsula em `Validated` aguardando assinatura do operador |
| ✅ HBN ACTIVE | capsula em `Signed` ou `Promoted`, em uso real |
| 🟤 HBN LICENSE SPLIT REQUIRED | capsula declara `license-target` distinto da licenca-mae do projeto |
| 🟪 HBN SUBSTRATO GATE | capsula migrou para implementacao Rust (Arvore Estavel) |

## Conexao com outros modulos

| Modulo | Relacao |
|---|---|
| Fagocitose | Cada transicao F3→F4 e F4→F5 emite capsula; F5 (promocao publica) e capsula em estado `Promoted` |
| Coordenacao inter-IA | Handoffs entre IAs podem ser registrados como mini-capsulas (lesson + evidence + consent); readbacks tem estrutura similar |
| Seguranca | Assinatura Ed25519 e regra de redacao herdam dos vetores G1-G8; capsula valida e evidencia de cumprimento |
| Auditoria Cruzada | Decisao auditada e registrada em capsula assinada por todas as IAs participantes |
| Marcadores | Estados da capsula tem markers especificos; revogacao gera evento marcado |
| Radar | Tecnologia em `phagocytosed` gera capsula de "fundamentos" no momento da incorporacao |

## Como adotar Capsulas em outro projeto

Para replicar este modulo em projeto externo:

1. Adotar os seis arquivos canonicos (`lesson.md`, `evidence.json`,
   `redaction-map.json`, `consent.json`, `license-target.txt`,
   `hashes.json`) como spec
2. Implementar validador (Python com Pydantic; Rust com serde) que
   verifica schema, redacao e hashes
3. Configurar lista canonica de tokens sensiveis para o projeto
4. Definir politica de licenca-target padrao (AGPLv3 sugerido para
   software livre publico)
5. Integrar com workflow de release: nada e publicado sem capsula
   assinada
6. Manter historico append-only de revogacoes (nunca apagar capsulas
   antigas)
7. Cross-link com modulo `MARCADORES` para usar markers da familia
   capsula (🟫 🟡 ✅ 🟤)

A capsula e convencao textual; pode ser implementada em qualquer
linguagem. O contrato e o conjunto dos seis arquivos e seus schemas,
nao uma biblioteca especifica.

## Migracao Python → Rust (primeira aplicacao)

Capsulas de Consentimento atua como **primeiro projeto demonstrador
do modelo das 3 Arvores**. Roadmap em 5 fases (R-A a R-E) detalhado em
[42_ROADMAP_CONSENT_CAPSULES_RUST.md](../../auditoria/00_status/42_ROADMAP_CONSENT_CAPSULES_RUST.md):

| Fase | Foco | Arvore |
|---|---|---|
| R-A | Spec final + POC Python + capsula real (L18 do Credenciamento) | Exploracao |
| R-B | Traducao 1:1 para Rust (byte-a-byte identica) | Desenvolvimento |
| R-C | Refinamentos idiomaticos Rust (type-state, serde) | Desenvolvimento |
| R-D | Promocao a Arvore Estavel (uso operacional, capsula publica) | Estavel |
| R-E | Documentacao V2 do useHBN incluindo Capsulas como nucleo | n/a (publica) |

Cadeia minima de dependencias Rust: `serde` + `sha2` + `ed25519-dalek`
+ `chrono` (~10 crates transitivas), compativel com o Principio
Minimalismo de Cadeia.

## Estado atual (snapshot vivo)

Mantido na ficha do Radar
[consent-capsules.md](../radar/_per-technology/consent-capsules.md).
Estado: `candidate` (aprovada 2026-05-06). Proximo marco: inicio da
fase R-A (POC Python + capsula L18 real).
