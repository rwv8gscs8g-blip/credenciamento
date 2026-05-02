---
titulo: Delphi
slug: delphi
categoria: legado
estado: in-radar
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02 (E1.1 — Codex análise individual)
proxima-revisao: 2026-08-02
fonte-radar: "auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: proprietária (IDE/RTL comercial)
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
---

# Delphi

## Por que está no radar

A entrada aparece nas fontes do radar como RAD Object Pascal. Interesse específico do useHBN: avaliar se Delphi ajuda a preservar, explicar e validar tecnologias sem substituir o protocolo por uma ferramenta.

Fonte inicial: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219`. Estado atual: `in-radar`.

## Resumo da tecnologia

Delphi é RAD Object Pascal. Tecnicamente, VCL/FMX, forms, components, events, datasets e compilador nativo. Recursos centrais:
- VCL/FMX
- forms
- components
- datasets
- compilação nativa

Diferencial para o radar: permite estudar RAD Object Pascal com evidência concreta, mantendo a decisão de adoção fora da ferramenta. O posicionamento é útil quando reduz ambiguidade operacional; é inadequado quando cria dependência que o HBN não consegue reverter.

Licença: proprietária (IDE/RTL comercial). Mantenedor: Embarcadero. Maturidade: desktop corporativo maduro.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | Preserva o comportamento original ao manter VCL/FMX como fonte de verdade antes de qualquer tradução. Sinal E1.1: VCL/FMX. |
| 2 | Documentar antes de executar | parcial | Precisa documentar runtime, arquivos e convenções; em Delphi, forms costuma esconder regra de negócio. Sinal E1.1: forms. |
| 3 | Testar antes de refatorar | parcial | Testes de caracterização devem cobrir components antes de refactor. Sinal E1.1: components. |
| 4 | Explicar antes de automatizar | sim | Explicação vem do mapa de eventos, dados e efeitos colaterais de delphi. Sinal E1.1: datasets. |
| 5 | Humano no controle por padrão | parcial | Controle humano é parcial porque execução legacy costuma tocar dados reais; backups e hearback ficam fora do runtime. Sinal E1.1: compilação nativa. |
| 6 | Toda evolução deve ser reversível | parcial | Reversibilidade exige exportar ambiente e artefatos; sem isso, rollback vira restauração manual. Sinal E1.1: delphi. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | A identidade é forte: Delphi continua sendo Delphi, mesmo com ponte para outra linguagem. Sinal E1.1: delphi. |
| 8 | O protocolo importa mais que a ferramenta | sim | O protocolo HBN envolve delphi; a tecnologia estudada não dita o método. Sinal E1.1: delphi. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | Os princípios sobrevivem a qualquer migração; a ficha deve extrair padrões, não vender reescrita. Sinal E1.1: delphi. |
| 10 | Segurança e não-regressão > velocidade | parcial | Segurança exige leitura estática e dados sintéticos antes de executar delphi. Sinal E1.1: delphi. |

**Convergência média: 5/10 sim, 5/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: Embarcadero. Exit exige manter artefatos e decisões fora da ferramenta.
- **Velocidade de evolução**: desktop corporativo maduro; pinagem ou revisão periódica é obrigatória antes de uso operacional.
- **Custo operacional**: envolve treinamento, manutenção e possível infraestrutura/serviço além do repositório.
- **Lock-in técnico**: médio se RAD Object Pascal virar fonte de verdade; baixo se ficar como camada auxiliar documentada.
- **Compatibilidade AGPLv3**: proprietária (IDE/RTL comercial); confirmar licença de código e termos de serviço antes de incorporar implementação.

## O que precisa para avançar de estado

- Definir POC pequeno, reversível e com dados sintéticos.
- Registrar entrada, saída, custo e rollback no ERP da esteira.
- Comparar contra alternativa mais simples baseada em arquivos/protocolo HBN puro.
- Só avançar de `in-radar` se o ganho for evidenciado por teste, log ou redução de risco.
- Se houver conteúdo TPGL envolvido, exigir consentimento e redaction-map antes de qualquer promoção pública.

## Histórico de transições

| Data | De | Para | Motivo | Decisor |
|---|---|---|---|---|
| 2026-05-02 | n/a | in-radar | Entrada inicial no bootstrap E1 do Radar | Codex CLI, sob spec Opus |
| 2026-05-02 | in-radar | in-radar | Reescrita de conteúdo (E1.1 — Codex análise individual) | Codex CLI |

## Referências

- [Referência oficial/base](https://docwiki.embarcadero.com/RADStudio/)
- Documentação técnica: `usehbn/docs/INTEGRATION-VBA-IMPORTER.md`
- Referência complementar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219`
