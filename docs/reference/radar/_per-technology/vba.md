---
titulo: VBA
slug: vba
categoria: legado
estado: phagocytosed
data-entrada: 2026-05-02
ultima-revisao: 2026-05-02 (E1.1 — Codex análise individual)
proxima-revisao: 2026-08-02
fonte-radar: "auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219"
licenca-target: usehbn (AGPLv3)
licenca-tecnologia: proprietária Microsoft
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
revisao-humana-pendente: false
---

# VBA

## Por que está no radar

A entrada aparece nas fontes do radar como linguagem Office embutida. Interesse específico do useHBN: avaliar se VBA ajuda a preservar, explicar e validar tecnologias sem substituir o protocolo por uma ferramenta.

Fonte inicial: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219`. Estado atual: `phagocytosed`.

## Resumo da tecnologia

VBA é linguagem Office embutida. Tecnicamente, módulos, classes, forms, eventos e COM dentro de arquivos Office. Recursos centrais:
- módulos BAS
- forms/eventos
- VBE
- COM automation
- workbooks

Diferencial para o radar: permite estudar linguagem Office embutida com evidência concreta, mantendo a decisão de adoção fora da ferramenta. O posicionamento é útil quando reduz ambiguidade operacional; é inadequado quando cria dependência que o HBN não consegue reverter.

Licença: proprietária Microsoft. Mantenedor: Microsoft. Maturidade: maduro e já fagocitado parcialmente.

## Convergência com os 10 princípios useHBN

| # | Princípio | Convergência | Justificativa |
|---|---|---|---|
| 1 | Preservar antes de transformar | sim | Preserva o comportamento original ao manter módulos BAS como fonte de verdade antes de qualquer tradução. Sinal E1.1: módulos BAS. |
| 2 | Documentar antes de executar | parcial | Precisa documentar runtime, arquivos e convenções; em VBA, forms/eventos costuma esconder regra de negócio. Sinal E1.1: forms/eventos. |
| 3 | Testar antes de refatorar | parcial | Testes de caracterização devem cobrir VBE antes de refactor. Sinal E1.1: VBE. |
| 4 | Explicar antes de automatizar | sim | Explicação vem do mapa de eventos, dados e efeitos colaterais de vba. Sinal E1.1: COM automation. |
| 5 | Humano no controle por padrão | parcial | Controle humano é parcial porque execução legacy costuma tocar dados reais; backups e hearback ficam fora do runtime. Sinal E1.1: workbooks. |
| 6 | Toda evolução deve ser reversível | parcial | Reversibilidade exige exportar ambiente e artefatos; sem isso, rollback vira restauração manual. Sinal E1.1: vba. |
| 7 | Nenhuma tecnologia fagocitada perde sua identidade | sim | A identidade é forte: VBA continua sendo VBA, mesmo com ponte para outra linguagem. Sinal E1.1: vba. |
| 8 | O protocolo importa mais que a ferramenta | sim | O protocolo HBN envolve vba; a tecnologia estudada não dita o método. Sinal E1.1: vba. |
| 9 | Frameworks são descartáveis; princípios são permanentes | sim | Os princípios sobrevivem a qualquer migração; a ficha deve extrair padrões, não vender reescrita. Sinal E1.1: vba. |
| 10 | Segurança e não-regressão > velocidade | parcial | Segurança exige leitura estática e dados sintéticos antes de executar vba. Sinal E1.1: vba. |

**Convergência média: 5/10 sim, 5/10 parcial, 0/10 não.**

## Divergências e riscos

- **Vendor risk**: Microsoft. Exit exige manter artefatos e decisões fora da ferramenta.
- **Velocidade de evolução**: maduro e já fagocitado parcialmente; pinagem ou revisão periódica é obrigatória antes de uso operacional.
- **Custo operacional**: envolve treinamento, manutenção e possível infraestrutura/serviço além do repositório.
- **Lock-in técnico**: médio se linguagem Office embutida virar fonte de verdade; baixo se ficar como camada auxiliar documentada.
- **Compatibilidade AGPLv3**: proprietária Microsoft; confirmar licença de código e termos de serviço antes de incorporar implementação.

## O que precisa para avançar de estado

- Definir POC pequeno, reversível e com dados sintéticos.
- Registrar entrada, saída, custo e rollback no ERP da esteira.
- Comparar contra alternativa mais simples baseada em arquivos/protocolo HBN puro.
- Só avançar de `phagocytosed` se o ganho for evidenciado por teste, log ou redução de risco.
- Se houver conteúdo TPGL envolvido, exigir consentimento e redaction-map antes de qualquer promoção pública.

## Histórico de transições

| Data | De | Para | Motivo | Decisor |
|---|---|---|---|---|
| 2026-05-02 | n/a | phagocytosed | Entrada inicial no bootstrap E1 do Radar | Codex CLI, sob spec Opus |
| 2026-05-02 | phagocytosed | phagocytosed | Reescrita de conteúdo (E1.1 — Codex análise individual) | Codex CLI |

## Referências

- [Referência oficial/base](https://learn.microsoft.com/en-us/office/vba/api/overview/)
- Documentação técnica: `usehbn/docs/INTEGRATION-VBA-IMPORTER.md`
- Referência complementar: `auditoria/00_status/38_USEHBN_TESE_FAGOCITOSE_INTEGRADA.md:208-219`
