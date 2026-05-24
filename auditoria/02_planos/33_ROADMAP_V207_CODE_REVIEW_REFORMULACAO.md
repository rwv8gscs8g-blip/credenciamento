---
titulo: Roadmap V207 — Code Review e Reformulacao
diataxis: plano
hbn-track: safe_track
hbn-status: draft
audiencia: ambos
versao-sistema: V12.0.0207
data: 2026-05-24
autor: Codex
---

# Roadmap V207 — Code Review e Reformulacao

## Veredito

A V12.0.0207 deve ser planejada como ciclo de revisão profunda, reformulação
controlada e fortalecimento de governança. Ela não deve competir com a V206.

V206 entrega:

- correção dos dois relatórios;
- PDF automático robusto;
- testes UI/PDF isolados;
- jornada humana;
- RC/freeze.

V207 absorve:

- code review profundo;
- refatorações estruturais;
- revisão de arquitetura;
- endurecimento de protocolo inter-IA;
- redução de dívida técnica ampla.

## Objetivos

1. Auditar o VBA de ponta a ponta sem alterar comportamento.
2. Classificar módulos por risco, acoplamento e tamanho.
3. Mapear formulários, eventos e dependências.
4. Definir uma estratégia de redução de dívida que preserve RN-01..RN-17.
5. Criar barreiras automáticas/semiautomáticas para evitar drift entre workbook,
   `src/vba`, `local-ai/vba_import`, `incoming` e `backups`.
6. Estabelecer contrato formal entre IAs no useHBN.

## Fora de Escopo

Sem novo hearback humano, V207 não pode:

- alterar regras RN-01 a RN-17;
- alterar semântica do rodízio;
- alterar contadores RVS;
- substituir o Excel como plataforma;
- reescrever `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas` ou
  `Svc_PreOS.bas` sem teste e aprovação explícita;
- renomear símbolos públicos/internos em massa.

## Ondas Propostas

| Onda | Tema | Saída |
|---|---|---|
| 38 | Inventário técnico | mapa de módulos, forms, eventos e dependências |
| 39 | Code review estático | achados P0/P1/P2 com linhas e risco |
| 40 | Drift workbook/repo | matriz `src/vba` vs export V5/V206 e política de reconciliação |
| 41 | Testabilidade | proposta de testes de UI, PDF e serviços fora do RVS |
| 42 | Arquitetura de formulários | proposta para reduzir instâncias fantasmas e acoplamento de UI |
| 43 | Importador e empacotamento | barreiras para `vba_import`, `incoming`, `backups` e Git |
| 44 | Refatorações pequenas | mudanças semânticas nulas, uma por microdelta |
| 45 | RC técnico V207 | gate humano e documentação de congelamento |

## Trilhas de Auditoria

### A. Módulos de Serviço

Prioridade de leitura, sem editar inicialmente:

- `Svc_Rodizio.bas`
- `Svc_Avaliacao.bas`
- `Svc_OS.bas`
- `Svc_PreOS.bas`
- `Svc_Transacao.bas`
- `Svc_Entidade.bas`

Saída: mapa de invariantes, entradas, saídas, estados e efeitos colaterais.

### B. UI e Forms

Foco:

- instâncias duplicadas de UserForm;
- `VBA.UserForms.Add` versus instância preenchida;
- `ControleFormulario`;
- controles dinâmicos;
- `.frm` versus `.frx`;
- `.code-only.txt`;
- handlers que dependem de estado global.

Saída: padrão canônico de abertura/preenchimento/exibição.

### C. Importador e Fonte de Verdade

Foco:

- `src/vba/` como fonte versionada;
- `local-ai/vba_import/` como fonte operacional de import;
- `local-ai/incoming/` como export bruto;
- `backups/vba/` como evidência;
- risco de instruções antigas em documentos históricos.

Saída: contrato revisado useHBN + checklist obrigatório.

### D. Testes

Foco:

- RVS permanece fechado;
- novas baterias isoladas para PDF/UI;
- simulação de cliques;
- validação de artefatos gerados;
- logs e evidências.

Saída: plano de testes sem alterar contadores oficiais.

## Gates

Cada onda V207 deve ter:

- readback `.hbn/readbacks/`;
- hearback humano;
- ERP `.hbn/results/`;
- documento técnico único;
- diff restrito;
- validação adequada ao risco;
- nenhuma mudança funcional sem teste.

## Dependências da V206

V207 só deve começar depois de uma destas condições:

1. V206 congelada em RC/freeze; ou
2. decisão humana explícita de pausar V206 e antecipar auditoria V207.

Enquanto V206 estiver ativa, V207 deve operar apenas em planejamento e
auditoria documental.

## Pedido Para Claude Opus 4.7

Revisar este roadmap e propor:

- renumeração de ondas, se necessário;
- barreiras obrigatórias no useHBN;
- critérios de entrada/saída;
- priorização de achados;
- separação exata entre V206 e V207;
- riscos que Codex deve respeitar antes de implementar.
