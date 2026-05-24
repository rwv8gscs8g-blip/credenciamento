---
titulo: Auditoria Adversarial do Planejamento V12.0.0206 — Gemini 3.5
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Gemini 3.5 via Antigravity
papel: auditor adversarial de planejamento e análise estratégica
cadeia-auditoria: V205-Freeze -> V206-Abertura-Codex -> V206-P2-Gemini-Adversarial -> V206-P3-Codex-Consolidacao
---

# Auditoria Adversarial de Planejamento — V12.0.0206

## Veredito Adversarial

O planejamento preliminar da **V12.0.0206** está **aprovado com restrições e
blindagem de segurança**.

A divisão em ondas e as premissas gerais estão consistentes, mas há riscos
latentes de contaminação de escopo e uma vulnerabilidade específica no desenho
do PDF automático: o teste de PDF não pode contaminar o Gate RVS nem mudar sua
assinatura numérica.

V12.0.0206 deve permanecer como ciclo de estabilização incremental
pós-produção e automação de entrega, sem code review destrutivo e sem alteração
semântica de RN-01 a RN-17.

## Achados

### P0 — Risco de Quebra do Gate RVS

**R-P0-01 — Contaminação de contadores RVS pelo teste de PDF.**

Se o teste de PDF for inserido em uma das seis sub-baterias do RVS ou alterar
o peso numérico do gate, a assinatura
`V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`
será corrompida.

Mitigação: o teste de PDF deve ser complementar, isolado e não participante dos
contadores RVS. Pode ser script externo, linter ou macro separada que não altera
as seis baterias oficiais.

### P1 — Refatoração Disfarçada

**R-P1-01 — Débitos técnicos como escopo escondido.**

Onda 35 não pode permitir reescrita de `Svc_Rodizio.bas`, `Repo_OS.bas` ou
outros módulos de negócio sob o argumento de limpeza.

Mitigação: débitos V206 devem ser nominais, pequenos e autorizados. Módulos de
negócio e persistência ficam bloqueados salvo P0 explícito.

### P2 — Confusão `docs/` vs `doc/`

`docs/` é documentação pública Diataxis. `doc/` contém dados estáticos/CNAE
usados pela planilha. A V206 não deve mover nem reorganizar `doc/`.

### P3 — Mensagens de UI Legadas

Mensagens do Importador V3 ainda podem induzir o operador a Trio/Quarteto. A
Onda de Importador deve corrigir mensagens ativas para orientar sempre ao Gate
RVS.

## Escopo Permitido em V12.0.0206

- PDF automático da aba `VALIDACAO_RELEASE` com `ExportAsFixedFormat`, handler
  de erro, criação de pasta e fallback manual.
- Atualização de mensagens do Importador V3 para RVS.
- Jornada humana V206 com checklist de hash e triagem P0/P1/P2/P3.
- Higiene documental fina e link scan.
- Alinhamento de `MANIFEST.md` e `MANIFESTO.csv`.

## Escopo Bloqueado Para V12.0.0207

- Renomeação interna de símbolos VBA.
- Componentização física de módulos.
- Reorganização de `doc/`.
- Performance estrutural.
- SaaS/multi-tenant/API.

## Requisitos Obrigatórios Antes de Codificar

- R-01: teste PDF isolado, sem alterar RVS.
- R-02: rotina PDF deve criar `auditoria/evidencias/V12.0.0206/pdf/`.
- R-03: não editar lógica mutadora em `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`,
  `Svc_OS.bas` e `Svc_PreOS.bas` na V206.

## Ordem Sugerida por Gemini

Gemini aceita a sequência preliminar, mas reforça a blindagem:

1. Planejamento.
2. PDF automático isolado.
3. Jornada humana.
4. Importador V3.
5. Higiene documental.
6. Débitos UX/UI estritos.
7. RC/freeze.

## Recomendação Final

Aprovar o planejamento sob blindagem, gravar este relatório e consolidar o
roadmap no Codex antes de qualquer implementação. Recomenda-se abrir novo chat
limpo para executar a primeira onda de código.

