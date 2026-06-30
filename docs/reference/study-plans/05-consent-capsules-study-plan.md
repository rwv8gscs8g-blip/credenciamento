---
titulo: Plano de Estudo Profundo — Consent Capsules (proposta interna useHBN)
diataxis: tutorial
hbn-track: knowledge
hbn-status: active
audiencia: humano
data: 2026-05-02
tempo-estimado: 4-6 horas (incluindo Notebook LM)
licenca-target: usehbn (AGPLv3)
ficha-radar: ../radar/_per-technology/consent-capsules.md
---

# Plano de Estudo Profundo — Consent Capsules

## Por que estudar profundo

Maurício: "O consent Capsules também parece adequado e fundamental."

Diferente das outras 4 tecnologias, esta é **proposta interna do useHBN** — não há documentação externa para consultar; precisamos construir o conceito a partir de referências adjacentes (W3C VC, JWS, GDPR, SBOM). Este plano sintetiza o que outras comunidades já fizeram em domínios próximos para informar o design final.

## Visão geral em 3 níveis

### Nível 1 — uma frase
Consent capsules são pacotes autocontidos (lesson + evidence + redaction-map + consent + license-target + hashes) que permitem promover conhecimento de um repo privado para um repo público mantendo privacidade, rastreabilidade e reversibilidade.

### Nível 2 — um parágrafo
Originada pelo Codex (proposta D em `103b-Codex-Protocolo-usehbn-Propostas.md`), a ideia responde ao problema concreto do useHBN: como o caso Credenciamento (TPGL v1.1, dados sensíveis) pode contribuir lições e padrões ao repo público `usehbn-phago` (AGPLv3) sem vazar informação ou perder rastreabilidade. A solução: cada lição vira **cápsula** — diretório versionado com 6 arquivos (lesson.md, evidence.json, redaction-map.json, consent.json, license-target.txt, hashes.json) — auditável individualmente, revogável, opt-in granular.

### Nível 3 — visão arquitetural
Consent capsules é a aplicação dos princípios constitucionais do useHBN ao problema de **fronteira entre repos com licenças/privacidades distintas**. Inspirada em três tradições: W3C Verifiable Credentials (declaração assinada de propriedade), SBOM/CycloneDX (descrição estruturada de software), GDPR consent management (granular + revogável). Diferente das três por escopo: é sobre **conhecimento operacional**, não sobre identidade ou software ou dados pessoais.

## Pré-requisitos

| Pré-req | Por que importa |
|---|---|
| Conceito de assinatura criptográfica | Hashes garantem integridade |
| JSON Schema | Para spec dos arquivos da cápsula |
| Pydantic (Python) | Implementação Python provável |
| Conceito de licença OSS | TPGL vs AGPLv3 vs MIT etc. |
| Git workflows | Promoção via PR é natural |

## Conceitos fundamentais

### Bloco A — Componentes da cápsula (1.5h)

```text
capsule-NNN/
├── lesson.md              # Conteúdo da lição (sanitizado)
├── evidence.json          # Refs e hashes das evidências locais
├── redaction-map.json     # Substituições aplicadas
├── consent.json           # Quem autorizou, quando, escopo
├── license-target.txt     # Licença alvo (AGPLv3, MIT, etc.)
└── hashes.json            # SHA-256 de cada arquivo
```

Schema preliminar (Pydantic-style):

```python
class Lesson(BaseModel):
    id: str               # ex.: "L18"
    title: str            # ex.: "Determinismo > narrativa pedagógica"
    body: str             # markdown sanitizado
    origin_project: str   # ex.: "credenciamento"
    origin_wave: str      # ex.: "11"

class Evidence(BaseModel):
    files: list[EvidenceRef]  # [{path, sha256}]

class RedactionMap(BaseModel):
    substitutions: list[Substitution]  # [{original, replacement, reason}]

class Consent(BaseModel):
    authorizer: str        # ex.: "maurício"
    authorized_at: datetime
    scope: str             # ex.: "AGPLv3-public-permanent"
    revocable_until: datetime | None

class LicenseTarget(BaseModel):
    target: Literal["AGPLv3", "MIT", "Apache-2.0", "TPGL-v1.1"]

class Hashes(BaseModel):
    files: dict[str, str]  # filename -> sha256
```

### Bloco B — Inspirações conceituais (2h)

#### B1 — W3C Verifiable Credentials (1h)

[W3C VC Data Model 2.0](https://www.w3.org/TR/vc-data-model-2.0/)

- Conceito: declaração assinada por emissor sobre sujeito (ex.: "John tem PhD")
- Estrutura: `issuer`, `credentialSubject`, `proof`
- Aplicação a cápsulas: `consent.json` é credencial do tipo "Maurício autoriza promoção da lição L18"

#### B2 — JSON Web Signatures (JWS) (30 min)

[RFC 7515](https://www.rfc-editor.org/rfc/rfc7515)

- Formato compacto: header.payload.signature (Base64URL)
- Algoritmos: HS256 (HMAC), RS256 (RSA), ES256 (ECDSA)
- Aplicação: assinar `consent.json` com chave pessoal do Maurício

#### B3 — SBOM CycloneDX (30 min)

[CycloneDX](https://cyclonedx.org/)

- Inventário estruturado de componentes de software
- Inspiração para schema da cápsula (formato declarativo, hashes, refs)

#### B4 — GDPR consent patterns (30 min)

- Granular: consentimento por finalidade
- Revogável: usuário pode retirar
- Auditável: log de quem consentiu o quê e quando
- Aplicação: cápsulas refletem mesmo espírito (granular, revogável, auditável)

### Bloco C — Workflow de cápsula (1h)

```text
Lesson em Credenciamento (TPGL)
        ↓
[Maurício decide promover]
        ↓
Codex/Opus monta esqueleto da cápsula
        ↓
Sanitiza conteúdo (redaction-map)
        ↓
Maurício revisa e assina (consent.json)
        ↓
hbn capsule validate
        ↓
hbn capsule promote → PR no usehbn-phago
        ↓
Merge no usehbn-phago (AGPLv3)
        ↓
Cápsula audit-trail permanente
        ↓
[opcional futuro: revogação por hash]
```

### Bloco D — Padrões adjacentes a evitar (30 min)

| Padrão | Por que NÃO adotar |
|---|---|
| **CLA blanket** | Não-granular; uma decisão cobre tudo futuro — fere P5/P6 |
| **Copyright assignment** | Transfere propriedade; useHBN quer só licenciar |
| **GDPR-style "click to accept"** | Genérico demais; cápsula precisa contexto específico |
| **Open Source Initiative process** | Burocrático demais para lições incrementais |

## Fontes primárias

### Documentação interna
- `local-ai/Time_AI/2026-05-02-V203-fechamento/103b-Codex-Protocolo-usehbn-Propostas.md` § 2 — proposta D original
- `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:257-270` — síntese
- `usehbn/radar/_per-technology/consent-capsules.md` — ficha do radar (atualizada)

### Documentação externa
- [W3C Verifiable Credentials Data Model 2.0](https://www.w3.org/TR/vc-data-model-2.0/)
- [W3C VC Implementation Guide](https://www.w3.org/TR/vc-imp-guide/)
- [IETF RFC 7515 — JWS](https://www.rfc-editor.org/rfc/rfc7515)
- [IETF RFC 8785 — JSON Canonicalization Scheme](https://www.rfc-editor.org/rfc/rfc8785) — útil para hashing canônico
- [CycloneDX Specification](https://cyclonedx.org/specification/overview/)
- [SLSA Framework](https://slsa.dev/) — supply chain integrity (inspiração)

### Casos relevantes
- [Sigstore](https://www.sigstore.dev/) — assinatura de artefatos OSS (referência futura)
- [in-toto](https://in-toto.io/) — supply chain attestations
- [DCO (Developer Certificate of Origin)](https://developercertificate.org/) — uma forma simples de "consent" usada por Linux

## Fontes secundárias

### Artigos
- [Manu Sporny — Verifiable Credentials Explainer](https://www.w3.org/2017/vc/WG/) — visão didática
- [Sigstore + cosign tutorial](https://docs.sigstore.dev/cosign/overview/) — assinatura prática
- [SLSA blog posts](https://slsa.dev/blog) — patterns

### Privacidade
- [Privacy by Design (Cavoukian, 2009)](https://gpsbydesigncentre.com/) — 7 princípios
- [GDPR consent guidelines (EDPB)](https://edpb.europa.eu/) — granularidade

## Hands-on exercises

### Exercício 1 — Schema Pydantic (1h)
Implementar os 6 modelos Pydantic em `src/hbn_phago/capsules/schema.py`. Validar com casos válidos e inválidos.

### Exercício 2 — Cápsula manual (1h)
Construir manualmente uma cápsula `capsule-001-L18-determinismo/` para a lição L18 do Credenciamento (determinismo > narrativa pedagógica). Inclui:
- Reescrever `lesson.md` removendo referências específicas
- Listar evidence files (com hashes via `sha256sum`)
- Documentar substituições no redaction-map
- Preencher consent.json com Maurício como autorizador
- license-target = AGPLv3
- hashes.json calculado

### Exercício 3 — Validator (1h)
Escrever `hbn capsule validate <path>` que:
- Verifica todos os 6 arquivos presentes
- Schema válido por arquivo
- Hashes batem com conteúdo
- Substituições no redaction-map foram aplicadas em lesson.md (busca por strings originais)

### Exercício 4 — JWS para consent (45 min)
- Gerar par de chaves Maurício (Ed25519)
- Assinar `consent.json` com chave privada
- Anexar assinatura como `consent.jws`
- Validador verifica assinatura

### Exercício 5 — Promoção via PR (45 min)
- Cápsula validada vai como PR no `usehbn-phago/lessons/`
- Template de PR descreve cápsula
- Merge requer revisão (mesmo de Maurício)

## Perguntas para aprofundamento

1. Granularidade ideal de uma cápsula: 1 lição? 1 padrão? 1 ondulação?
2. Como lidar com cápsulas que dependem de outras (dependency graph)?
3. Revogação: como garantir consistência se cápsula já foi forkeada?
4. Cápsula reversa: import de lições externas no Credenciamento?
5. Multilíngua: cápsula tem lesson_pt-BR.md e lesson_en.md?
6. Versionamento de cápsulas (cápsula evolui ao longo do tempo)?
7. Como cápsula interage com semantic conventions OTel (tracear promoção)?
8. Modelo econômico: futuro pagamento pela cápsula? Atribution?
9. Comparativo com Conventional Commits ou Changesets para changelogs?
10. Uso de Tree-sitter para gerar `evidence.json` automaticamente do código?

## Conexão com os 10 princípios useHBN

| Princípio | Como Consent Capsules encarna |
|---|---|
| **P1 — Preservar antes de transformar** | Original local nunca tocado; só cópia sanitizada |
| **P2 — Documentar antes de executar** | Cápsula é doc completa antes de qualquer publicação |
| **P5 — Humano no controle** | consent.json exige Maurício explícito |
| **P6 — Reversibilidade** | Revogação por hash; original sempre intacto |
| **P8 — Protocolo > ferramenta** | Cápsula é spec textual; ferramenta-agnóstica |
| **P10 — Segurança** | Deliberadamente lenta; revisão manual obrigatória |

## Critérios de "estudei o suficiente"

- [ ] Explicar componentes da cápsula em 5 minutos
- [ ] Diferenciar de W3C VC, JWS, SBOM, CLA
- [ ] Construir 1 cápsula real (L18) manualmente
- [ ] Validar cápsula com schema Pydantic
- [ ] Decidir granularidade ideal (gate G4 do roadmap)

## Sequência sugerida (5 horas distribuídas)

1. **Hora 1** — Documentação interna (proposta D + tese 38 § 257-270)
2. **Hora 2** — W3C VC + JWS (referências adjacentes)
3. **Hora 3** — Notebook LM podcast (gerado pelo superprompt)
4. **Hora 4** — Exercícios 1-2 (schema + cápsula manual)
5. **Hora 5** — Exercícios 3-5 + perguntas

## Versão

- v1.0 — 2026-05-02 — plano inicial.
