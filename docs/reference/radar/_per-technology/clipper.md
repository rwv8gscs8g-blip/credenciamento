---
titulo: Clipper
slug: clipper
categoria: legado
estado: in-radar
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02 (E1.1 — Codex análise individual)
proxima-revisao: 2026-08-02
fonte-radar: "auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: proprietária histórica; Harbour open source
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: true
---

# Clipper

## Por que está no radar

A entrada aparece nas fontes do radar como linguagem/compilador xBase DOS. Interesse específico do useHBN: avaliar se Clipper ajuda a preservar, explicar e validar tecnologias sem substituir o protocolo por uma ferramenta.

Fonte inicial: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219`. Estado atual: `in-radar`.

## Resumo da tecnologia

Clipper é linguagem/compilador xBase DOS. Tecnicamente, PRG, DBF, índices, telas texto e lógica comercial local. Recursos centrais:
- PRG
- DBF
- índices
- telas texto
- work areas

Diferencial para o radar: permite estudar linguagem/compilador xBase DOS com evidência concreta, mantendo a decisão de adoção fora da ferramenta. O posicionamento é útil quando reduz ambiguidade operacional; é inadequado quando cria dependência que o HBN não consegue reverter.

Licença: proprietária histórica; Harbour open source. Mantenedor: Harbour/xHarbour comunidade. Maturidade: legado xBase.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | Preserva o comportamento original ao manter PRG como fonte de verdade antes de qualquer tradução. Sinal E1.1: PRG. |
| 2 | Documentar antes de executar | parcial | Precisa documentar runtime, arquivos e convenções; em Clipper, DBF costuma esconder regra de negócio. Sinal E1.1: DBF. |
| 3 | Testar antes de refatorar | parcial | Testes de caracterização devem cobrir índices antes de refactor. Sinal E1.1: índices. |
| 4 | Explicar antes de automatizar | sim | Explicação vem do mapa de eventos, dados e efeitos colaterais de clipper. Sinal E1.1: telas texto. |
| 5 | Humano no controle por padrão | parcial | Controle humano é parcial porque execução legacy costuma tocar dados reais; backups e hearback ficam fora do runtime. Sinal E1.1: work areas. |
| 6 | Toda evolução deve ser reversível | parcial | Reversibilidade exige exportar ambiente e artefatos; sem isso, rollback vira restauração manual. Sinal E1.1: clipper. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | A identidade é forte: Clipper continua sendo Clipper, mesmo com ponte para outra linguagem. Sinal E1.1: clipper. |
| 8 | O protocolo importa mais que a ferramenta | sim | O protocolo HBN envolve clipper; a tecnologia estudada não dita o método. Sinal E1.1: clipper. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | Os princípios sobrevivem a qualquer migração; a ficha deve extrair padrões, não vender reescrita. Sinal E1.1: clipper. |
| 10 | Segurança e não-regressão > velocidade | parcial | Segurança exige leitura estática e dados sintéticos antes de executar clipper. Sinal E1.1: clipper. |

**Convergência média: 5/10 sim, 5/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: Harbour/xHarbour comunidade. Exit exige manter artefatos e decisões fora da ferramenta.
- **Velocidade de evolução**: legado xBase; pinagem ou revisão periódica é obrigatória antes de uso operacional.
- **Custo operacional**: envolve treinamento, manutenção e possível infraestrutura/serviço além do repositório.
- **Lock-in técnico**: médio se linguagem/compilador xBase DOS virar fonte de verdade; baixo se ficar como camada auxiliar documentada.
- **Compatibilidade AGPLv3**: proprietária histórica; Harbour open source; confirmar licença de código e termos de serviço antes de incorporar implementação.

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

- [Referência oficial/base](https://harbour.github.io/)
- Documentação técnica: `usehbn/docs/INTEGRATION-VBA-IMPORTER.md`
- Referência complementar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219`
