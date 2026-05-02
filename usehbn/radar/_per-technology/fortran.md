---
titulo: Fortran
slug: fortran
categoria: legado
estado: in-radar
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02 (E1.1 — Codex análise individual)
proxima-revisao: 2026-08-02
fonte-radar: "auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: linguagem/especificação; compiladores variam
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
---

# Fortran

## Por que está no radar

A entrada aparece nas fontes do radar como linguagem científica compilada. Interesse específico do useHBN: avaliar se Fortran ajuda a preservar, explicar e validar tecnologias sem substituir o protocolo por uma ferramenta.

Fonte inicial: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219`. Estado atual: `in-radar`.

## Resumo da tecnologia

Fortran é linguagem científica compilada. Tecnicamente, arrays, módulos, subrotinas e toolchains numéricos de alta performance. Recursos centrais:
- arrays
- subrotinas
- módulos
- HPC
- coarrays/OpenMP

Diferencial para o radar: permite estudar linguagem científica compilada com evidência concreta, mantendo a decisão de adoção fora da ferramenta. O posicionamento é útil quando reduz ambiguidade operacional; é inadequado quando cria dependência que o HBN não consegue reverter.

Licença: linguagem/especificação; compiladores variam. Mantenedor: ISO/IEC + comunidade. Maturidade: HPC maduro.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | Preserva o comportamento original ao manter arrays como fonte de verdade antes de qualquer tradução. Sinal E1.1: arrays. |
| 2 | Documentar antes de executar | parcial | Precisa documentar runtime, arquivos e convenções; em Fortran, subrotinas costuma esconder regra de negócio. Sinal E1.1: subrotinas. |
| 3 | Testar antes de refatorar | parcial | Testes de caracterização devem cobrir módulos antes de refactor. Sinal E1.1: módulos. |
| 4 | Explicar antes de automatizar | sim | Explicação vem do mapa de eventos, dados e efeitos colaterais de fortran. Sinal E1.1: HPC. |
| 5 | Humano no controle por padrão | parcial | Controle humano é parcial porque execução legacy costuma tocar dados reais; backups e hearback ficam fora do runtime. Sinal E1.1: coarrays/OpenMP. |
| 6 | Toda evolução deve ser reversível | parcial | Reversibilidade exige exportar ambiente e artefatos; sem isso, rollback vira restauração manual. Sinal E1.1: fortran. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | A identidade é forte: Fortran continua sendo Fortran, mesmo com ponte para outra linguagem. Sinal E1.1: fortran. |
| 8 | O protocolo importa mais que a ferramenta | sim | O protocolo HBN envolve fortran; a tecnologia estudada não dita o método. Sinal E1.1: fortran. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | Os princípios sobrevivem a qualquer migração; a ficha deve extrair padrões, não vender reescrita. Sinal E1.1: fortran. |
| 10 | Segurança e não-regressão > velocidade | parcial | Segurança exige leitura estática e dados sintéticos antes de executar fortran. Sinal E1.1: fortran. |

**Convergência média: 5/10 sim, 5/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: ISO/IEC + comunidade. Exit exige manter artefatos e decisões fora da ferramenta.
- **Velocidade de evolução**: HPC maduro; pinagem ou revisão periódica é obrigatória antes de uso operacional.
- **Custo operacional**: envolve treinamento, manutenção e possível infraestrutura/serviço além do repositório.
- **Lock-in técnico**: médio se linguagem científica compilada virar fonte de verdade; baixo se ficar como camada auxiliar documentada.
- **Compatibilidade AGPLv3**: linguagem/especificação; compiladores variam; confirmar licença de código e termos de serviço antes de incorporar implementação.

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

- [Referência oficial/base](https://fortran-lang.org/)
- Documentação técnica: `usehbn/docs/INTEGRATION-VBA-IMPORTER.md`
- Referência complementar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219`
