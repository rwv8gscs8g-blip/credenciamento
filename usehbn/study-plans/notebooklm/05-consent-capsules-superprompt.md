---
titulo: Superprompt Notebook LM — Consent Capsules (W3C VC, JWS, GDPR adjacentes)
diataxis: how-to
hbn-track: knowledge
audiencia: humano
data: 2026-05-02
licenca-target: usehbn (AGPLv3)
---

# Superprompt Notebook LM — Consent Capsules

## Como usar

⚠️ **Diferente das outras 4 tecnologias**: Consent Capsules é proposta INTERNA do useHBN. Não há documentação oficial de Consent Capsules para fazer upload. O notebook usa **referências adjacentes** (W3C VC, JWS, SBOM, GDPR, Sigstore) para informar o design final.

1. Crie notebook: "useHBN — Consent Capsules design (referências adjacentes)"
2. Upload das fontes adjacentes
3. Cole "CONTEXTO" detalhado descrevendo a proposta
4. Gere Audio Overview que sintetiza referências e propõe design

---

## CONTEXTO PARA COLAR

```text
ATENÇÃO: este notebook é diferente. Não estou estudando uma tecnologia existente bem documentada — estou DESENHANDO uma proposta nova chamada "Consent Capsules" usando ideias de tecnologias adjacentes como inspiração. As fontes que vou enviar são essas referências adjacentes (W3C Verifiable Credentials, JSON Web Signatures, SBOM CycloneDX, GDPR consent patterns, Sigstore). Quero que o Notebook LM me ajude a sintetizar lições dessas tradições e aplicá-las ao desenho de Consent Capsules.

PROPOSTA "CONSENT CAPSULES" (do que estou falando):

Originada pelo Codex em proposta D dentro do projeto useHBN. Problema concreto: tenho um projeto privado (Credenciamento, licença TPGL v1.1, com dados sensíveis) que produz lições e padrões valiosos para um projeto público (usehbn-phago, AGPLv3). Como promover lições do privado para o público mantendo:

- Privacidade (sem vazar dados sensíveis)
- Rastreabilidade (audit trail completo)
- Conformidade legal (TPGL → AGPLv3 transition)
- Reversibilidade (revogação se necessário)
- Granularidade (cada lição tem decisão própria — não acordo blanket)

DESIGN PROPOSTO: cada lição vira "cápsula" — diretório versionado com 6 arquivos:
1. lesson.md — conteúdo sanitizado da lição
2. evidence.json — refs e hashes das evidências locais
3. redaction-map.json — substituições aplicadas
4. consent.json — quem autorizou, quando, escopo
5. license-target.txt — licença alvo (AGPLv3, etc.)
6. hashes.json — SHA-256 de cada arquivo (integridade)

QUERO ENTENDER:

(a) **W3C Verifiable Credentials** — modelo de declaração assinada (issuer, subject, proof). Como aplicar a "Maurício autoriza promoção de L18"?

(b) **JSON Web Signatures (JWS)** — formato compacto para assinar payloads JSON. Como assinar consent.json com chave privada de Maurício?

(c) **SBOM CycloneDX** — inventário declarativo de componentes de software. Que campos do schema posso reaproveitar para descrever cápsula?

(d) **GDPR consent patterns** — granularidade, revogação, propósito. O que aprender sobre consentimento humano que se aplica a "consentimento para promover lição"?

(e) **Sigstore + cosign** — assinatura de artefatos OSS via short-lived certs (sem gerenciar chaves). Aplicável ao caso useHBN?

(f) **DCO (Developer Certificate of Origin)** — Linux usa para autoria simples ("eu confirmo que tenho direito de contribuir"). Inspiração para consent.json?

OS 10 PRINCÍPIOS DO useHBN:
1. Preservar antes de transformar
2. Documentar antes de executar
3. Testar antes de refatorar
4. Explicar antes de automatizar
5. Humano no controle por padrão
6. Toda evolução deve ser reversível
7. Nenhuma tecnologia fagocitada perde sua identidade
8. O protocolo importa mais que a ferramenta
9. Frameworks são descartáveis; princípios são permanentes
10. Segurança e não-regressão > velocidade

Consent capsules encarna especialmente P5 (humano explícito por cápsula), P6 (revogabilidade), P10 (deliberadamente lento).

DESAFIO PARA O NOTEBOOK LM: ajudar a desenhar o schema final dos 6 arquivos da cápsula, sintetizando lições de W3C VC, JWS, SBOM e GDPR — sem inventar do zero, mas adaptando padrões maduros.
```

---

## FONTES PARA UPLOAD

### Verifiable Credentials (3)

1. **[W3C Verifiable Credentials Data Model 2.0](https://www.w3.org/TR/vc-data-model-2.0/)** — spec authoritative
2. **[W3C VC Implementation Guide](https://www.w3.org/TR/vc-imp-guide/)** — guia prático
3. **[Manu Sporny — Verifiable Credentials Explainer (vídeo ou blog)](https://www.w3.org/2017/vc/WG/)** — visão didática

### Cryptographic primitives (2)

4. **[IETF RFC 7515 — JSON Web Signatures](https://www.rfc-editor.org/rfc/rfc7515)** — assinatura JSON
5. **[IETF RFC 8785 — JSON Canonicalization Scheme](https://www.rfc-editor.org/rfc/rfc8785)** — para hashing canônico

### Software Bill of Materials (1)

6. **[CycloneDX Specification](https://cyclonedx.org/specification/overview/)** — schema declarativo

### Privacy patterns (2)

7. **[GDPR Article 7 — Conditions for consent](https://gdpr-info.eu/art-7-gdpr/)** — granularidade, revogabilidade
8. **[GDPR consent guidelines (EDPB)](https://edpb.europa.eu/sites/default/files/files/file1/edpb_guidelines_202005_consent_en.pdf)** — guia prático

### Supply chain integrity (2)

9. **[Sigstore documentation](https://docs.sigstore.dev/)** — assinatura OSS sem gerenciar chaves
10. **[SLSA Framework](https://slsa.dev/)** — supply chain integrity levels

### Ethos prática (1)

11. **[Developer Certificate of Origin](https://developercertificate.org/)** — modelo Linux para autoria simples

---

## PERGUNTAS PARA GERAÇÃO

```text
Deep Dive de 35-40 minutos sobre Consent Capsules — sintetizando referências adjacentes em uma proposta coerente.

BLOCO 1 — Mapa das tradições (10 min)
1. W3C VC: o que é declaração assinada digital, qual estrutura?
2. JWS: como funciona assinatura JSON, qual algoritmo escolher (HS256, RS256, ES256)?
3. SBOM CycloneDX: que campos importam para descrever artefatos?
4. GDPR: o que torna consentimento "válido" (granular, informado, revogável)?
5. Sigstore: por que assinar sem gerenciar chaves muda o jogo?

BLOCO 2 — Mapeamento conceitual (10 min)
6. Como cada referência inspira partes do schema da cápsula?
7. lesson.md: que campos? Markdown padrão ou frontmatter rico?
8. evidence.json: como modelar refs+hashes (inspirar em SBOM)?
9. redaction-map.json: schema mínimo (substituições + razão)?
10. consent.json: schema (inspirar em VC + GDPR)?
11. license-target.txt: por que arquivo separado (não dentro de consent)?
12. hashes.json: por que arquivo separado (integridade vs identidade)?

BLOCO 3 — Decisões críticas (10 min)
13. JWS para consent.json — qual algoritmo (sugestão Ed25519)?
14. Maurício gerencia chave própria? Como?
15. Granularidade ideal: 1 lição = 1 cápsula? Ou agrupamentos?
16. Revogação prática: como retirar cápsula promovida sem reescrever história git?
17. Versionamento: cápsula evolui ao longo do tempo (capsule-001-v2)?

BLOCO 4 — Implementação Python (8 min)
18. Pydantic models para cada um dos 6 arquivos — sketch
19. Validação cruzada (hashes batem com conteúdo, redactions aplicadas)
20. CLI minimal: hbn capsule create / validate / promote / revoke

DESEJO ESPECIAL: dediquem 5 min do bloco 2 ao consent.json especificamente — porque é a pedra angular de todo o esquema.
```

---

## PERSONA DE AUDIÊNCIA

```text
Audiência: arquiteto técnico desenhando primitiva nova. Conhece JSON, REST, hashing básico (SHA-256). Não é criptógrafo — quer aprender JWS o suficiente para implementar bem, sem virar especialista. Está construindo proposta original mas valoriza ENORMEMENTE não reinventar a roda — quer extrair o melhor de tradições maduras (W3C, IETF, GDPR). Tom: didático nas cripto/privacy, decisivo na síntese de design; ofereça opiniões claras quando perguntado.
```

---

## OUTPUTS SOLICITADOS

- [ ] Audio Overview (~35-40 min)
- [ ] Briefing document com TABELA mapeando cada arquivo da cápsula → referências inspiradoras
- [ ] Mind map: relações entre VC, JWS, SBOM, GDPR, Sigstore, DCO e Consent Capsules
- [ ] FAQ específico sobre granularidade, revogação, versionamento

## Versão

- v1.0 — 2026-05-02 — superprompt inicial. Caráter de design (não estudo).
