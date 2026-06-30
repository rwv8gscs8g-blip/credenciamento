---
titulo: Consent capsules
slug: consent-capsules
categoria: conhecimento-estruturado
estado: candidate
data-entrada: 2026-05-02
ultima-revisao: 2026-05-06 (APROVADA por Maurício como primeira tecnologia de migração Python → Rust)
proxima-revisao: 2026-06-06 (após POC R-A em Python concluído)
fonte-radar: "local-ai/Time_AI/2026-05-02-V203-fechamento/103b-Codex-Protocolo-usehbn-Propostas.md (proposta D)"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: proposta interna useHBN; conteúdo por cápsula declara license-target individual
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
arvore-hbn: development-branch (em transição); alvo: stable-trunk (Rust)
papel-no-protocolo: tecnologia de assinatura, compatibilidade e redução de erros — veículo canônico de promoção entre as 3 árvores
recomendacao-opus: APROVADA — plano de migração em 5 fases (R-A a R-E) em auditoria/00_status/42_ROADMAP_CONSENT_CAPSULES_RUST.md
decisao-final: APROVADA — primeira tecnologia a percorrer fluxo estruturado Python → Rust como demonstração viva do modelo das 3 Árvores
---

# Consent capsules

## Por que está no radar

Consent capsules é a infraestrutura essencial para promover lições do Credenciamento (L1-L18, M1-M7) ao repositório público `usehbn-phago` mantendo: privacidade, rastreabilidade, conformidade legal e reversibilidade. **Sem cápsulas, nada cruza a fronteira TPGL → AGPLv3 com segurança.**

Diferente das outras 4 fichas analisadas hoje, esta não é tecnologia externa — é **proposta a implementar dentro do useHBN**, originada pelo Codex (proposta D em `103b-Codex-Protocolo-usehbn-Propostas.md`).

Fonte inicial: Codex 103b § 2 + tese 38 §10.

## Resumo da tecnologia

Cada artefato que cruza fronteira (do Credenciamento privado para o useHBN público) viaja como **cápsula autocontida** — diretório versionado contendo:

```text
capsule-NNN/
├── lesson.md              # conteúdo (a lição em si)
├── evidence.json          # refs + hashes das evidências locais
├── redaction-map.json     # tokens/strings substituídos antes de promover
├── consent.json           # quem autorizou, quando, escopo da licença
├── license-target.txt     # AGPLv3 (público) ou outro
└── hashes.json            # SHA-256 de cada arquivo (integridade)
```

Princípios da cápsula:
1. **Unidade atômica de transferência** — nada cruza fronteira sem cápsula completa
2. **Auditável individualmente** — cada cápsula é assinatura legível
3. **Modelo viral opt-in** — usuário consente cápsula a cápsula, não acordo blanket
4. **Reversível** — futuro: revogação por hash da cápsula despromove conteúdo
5. **Editor-agnóstica** — JSON + Markdown; ferramenta-neutra

Diferencial vs alternativas:
- vs **commit direto público**: cápsula força explicitação de consentimento, redação e licença
- vs **CLA blanket**: cápsula é granular (cada lição tem decisão própria) e reversível
- vs **SBOM (Software Bill of Materials)**: SBOM é descrição de software; cápsula é descrição de transferência consensual de conhecimento
- vs **Verifiable Credentials W3C**: VC tem foco em credenciais de identidade; cápsula reaproveita o espírito (declaração assinada) para conhecimento operacional

Licença: proposta interna useHBN. Mantenedor inicial: Codex 103 + Opus + Maurício. Maturidade: conceito em desenho — schema ainda não formalizado.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | Cápsula preserva original local intacto; só uma cópia sanitizada cruza fronteira. Original sobrevive em Credenciamento. |
| 2 | Documentar antes de executar | sim | Cada cápsula documenta consentimento, escopo, redação ANTES de qualquer publicação. Não há promoção implícita. |
| 3 | Testar antes de refatorar | sim | Hashes detectam alteração; cápsula é unidade testável (validar schema, completude, redação). `hbn capsule validate` é trivial. |
| 4 | Explicar antes de automatizar | sim | Cápsula é o documento de explicação. Automação só após cápsula validada por humano. P4 satisfeito por design. |
| 5 | Humano no controle por padrão | sim | `consent.json` exige humano explícito (Maurício) para cada cápsula. Sem consentimento, sem promoção. Match P5 fundamental. |
| 6 | Toda evolução deve ser reversível | sim | Cápsula pode ser despromovida (revogação futura); local original nunca foi tocado, então rollback é trivial. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | O `lesson.md` preserva contexto, fonte e racional do Credenciamento; identidade do learning original mantida via referências em `evidence.json`. |
| 8 | O protocolo importa mais que a ferramenta | sim | Cápsula é spec; pode ser implementada em Python, Rust, manualmente. Ferramenta-agnóstica. Match arquitetural perfeito. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | Cápsula é convenção textual (JSON + Markdown); sem framework dependente. Sobrevive a qualquer ferramenta de implementação. |
| 10 | Segurança e não-regressão > velocidade | sim | Deliberadamente lenta — força revisão manual de cada cápsula. Match P10 fundamental: nenhuma promoção rápida. |

**Convergência média: 10/10 sim, 0/10 parcial, 0/10 não.** Encaixe arquitetural perfeito (junto com uv).

## Divergências e riscos

- **Vendor risk**: ZERO — é proposta interna useHBN
- **Velocidade de evolução**: alta enquanto schema está em desenho; depois estabiliza
- **Custo operacional**: cada cápsula tem overhead manual (montagem, redação, consentimento). Se forem muitas lições (50+), vira gargalo — precisa CLI helper (`hbn capsule create --from-lesson L18`)
- **Lock-in técnico**: ZERO — spec textual
- **Risco de privacy leak**: redação incompleta vaza informação. "Esquecer" um valor sensível em prompt embedded no `lesson.md` é falha humana. Mitigação: lista canônica de tokens sensíveis verificada por gate antes de promoção
- **Risco de friction excessivo**: cápsula muito burocrática desincentiva contribuição. Equilíbrio: mínimo viável de campos obrigatórios (consent + redaction + license-target)
- **Compatibilidade AGPLv3**: cada cápsula declara `license-target` — AGPLv3 padrão para promoção pública

## O que precisa para avançar de estado

Para `candidate` (recomendação Opus):
- Spec formal de cada arquivo da cápsula (schemas JSON usando Pydantic; template `lesson.md`)
- POC manual: 1 cápsula real promovendo L18 (determinismo > narrativa) do Credenciamento → `usehbn-phago` com:
  - `lesson.md` reescrito sanitizado (sem nomes específicos do projeto)
  - `evidence.json` apontando para commits Credenciamento (hash + path)
  - `redaction-map.json` listando substituições feitas
  - `consent.json` com Maurício como autorizador
  - `license-target.txt` = `AGPLv3`
  - `hashes.json` calculado
- Definir interface CLI: `hbn capsule create`, `hbn capsule validate`, `hbn capsule promote`
- Definir política de revogação (futura)

Para `phagocytosed`:
- Implementação na CLI hbn (Wave 11+)
- Primeiras 3-5 cápsulas reais promovidas com sucesso (L1-L18 + M1-M7 do Credenciamento)
- Documentação pública em `usehbn-phago/docs/` sobre como contribuir via cápsula

## Histórico de transições

| Data | De | Para | Motivo | Decisor |
|---|---|---|---|---|
| 2026-05-02 | n/a | under-analysis | Entrada inicial no bootstrap E1 do Radar | Codex CLI, sob spec Opus |
| 2026-05-02 | under-analysis | under-analysis | Reescrita E1.1 (Codex — análise template) | Codex CLI |
| 2026-05-02 | under-analysis | under-analysis | Análise profunda Opus — recomenda promoção a candidate | Claude Opus 4.7 (Frente 2) |
| **2026-05-06** | **under-analysis** | **candidate** | **Maurício aprovou após estudo NotebookLM: tecnologia "absolutamente fundamental, aderente à nossa tecnologia, deve ser incorporado como tecnologia do fluxo do useHBN". Papel ampliado: tecnologia de assinatura, compatibilidade e redução de erros. Designada como PRIMEIRO PROJETO com fluxo estruturado de migração Python → Rust no modelo das 3 Árvores. Roadmap formal em `auditoria/00_status/42_ROADMAP_CONSENT_CAPSULES_RUST.md`.** | **Maurício (palavra final)** |

## Nota de aprovação — racional Maurício 2026-05-06

Após estudo profundo via NotebookLM, Maurício declarou (citação operacional):

> "Consent Capsules absolutamente fundamental, aderente à nossa tecnologia, deve ser incorporado como tecnologia do fluxo do useHBN e deve ser o primeiro projeto com fluxo estruturado para conversar para uma modelo em Rust, que evolua da linguagem atual para um repositório que trate as características da segurança. Absolutamente fundamental. Pode ser uma tecnologia de assinatura, de compatibilidade e redução de erros, bem em linha com os objetivos da linguagem de declarar o que está em funcionamento e em controle."

Implicações operacionais:

- **Papel ampliado**: além de "veículo de promoção pública de lições" (escopo original da proposta D), Consent Capsules ganha papel de **infraestrutura de assinatura, compatibilidade e redução de erros** entre componentes do useHBN.
- **Primeiro projeto demonstrador** do modelo das 3 Árvores: começa em Python (Exploração/Desenvolvimento) e migra para Rust (Estável) em fluxo estruturado de 5 fases (R-A a R-E).
- **Conexão com decisão Rust** (2026-05-06 manhã): Consent Capsules é a primeira manifestação concreta da Árvore Estável. Sucesso da migração informa o fluxo de migração das demais tecnologias (incluindo Tree-sitter eventualmente).
- **Conexão com V2 do useHBN**: Consent Capsules entra como núcleo da documentação V2 a ser preparada após análise da última tecnologia (OpenTelemetry).

## Referências

- [`103b-Codex-Protocolo-usehbn-Propostas.md` § 2 (proposta D)](../../../local-ai/Time_AI/2026-05-02-V203-fechamento/103b-Codex-Protocolo-usehbn-Propostas.md) — proposta original
- [`38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:257-270`](../../../auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md) — síntese
- [W3C Verifiable Credentials Data Model 2.0](https://www.w3.org/TR/vc-data-model-2.0/) — modelo conceitual mais amplo (declaração assinada de propriedade)
- [W3C Privacy Community Group](https://privacycg.github.io/) — patterns de consentimento granular
- [IETF RFC 7515 (JWS — JSON Web Signatures)](https://www.rfc-editor.org/rfc/rfc7515) — base para autenticidade futura de cápsulas
- [TPGL v1.1 do Credenciamento](../../../AGENTS.md) — licença origem
- [SBOM CycloneDX](https://cyclonedx.org/) — referência para schema de inventário (não é cápsula, mas inspira campos)
- Fonte interna primária: `local-ai/Time_AI/2026-05-02-V203-fechamento/103b-Codex-Protocolo-usehbn-Propostas.md`
