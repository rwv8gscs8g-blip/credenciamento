---
titulo: Plano de Melhoria de Testes V206-V207
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-30
---

# Plano de Melhoria de Testes V206-V207

## Problema

O RVS completo continua necessario como gate de release, mas ficou caro para iteracao de estabilizacao: Mauricio reportou aproximadamente 45 minutos por execucao completa. Alem disso, o RVS aprovado nao detectou bugs reais de UI, protecao de abas, objetos colados e exibicao incompleta.

Conclusao: o RVS nao deve ser removido, mas precisa deixar de ser o unico sinal de qualidade durante microfixes.

## Fase Recomendada Antes do Freeze V206

Abrir uma micro-onda de melhoria de testes, depois dos BLOQUEADORES funcionais atuais:

- objetivo: reduzir tempo de feedback por modulo;
- escopo: testes e documentacao de QA, sem alterar regra de negocio;
- criterio: cada bug bloqueador L43 deve ter um teste automatico ou assistido associado;
- nao-objetivo: substituir o RVS completo como gate final.

## Gates Modulares

Manter o RVS completo para freeze e gates maiores, mas usar suites menores entre microfixes:

| Gate | Uso | Meta |
|---|---|---|
| `TV2_RunIntegridadeEstado` | Entidades, inativacao, protecao de abas | Rodar apos cada fix de estado |
| `TV2_RunEntidadesExaustivo` | Futuro mapa completo de Entidades | Cobrir os 25 itens do mapa manual |
| `TV2_RunProtecaoAbasCriticas` | Futuro gate dedicado de seguranca Excel | Validar Locked, ProtectContents, objetos e pos-RVS |
| `TV2_RunUIPersistencia` | Futuro gate de UI | Comparar modal, tela principal e planilha |
| RVS completo | Gate de release | Rodar em fechamento de onda e freeze |

## Evidencia e Tempo

Cada suite modular deve registrar:

- `execucao_id`;
- build label;
- tempo de inicio e fim;
- OK/FALHA/MANUAL;
- CSV de falhas quando houver;
- snapshot minimo pre/pos quando tocar dados.

Isso permite saber qual suite ficou lenta e evita rodar 45 minutos para validar uma correcao de 1 arquivo.

## Conversao dos Testes Manuais de Entidades

O mapa `MAPA_TESTES_ENTIDADES_V206.md` passa a ser a base de um roteiro exaustivo por modulo. A prioridade e automatizar primeiro:

- ciclo primeira/intermediaria/ultima linha;
- exclusividade ativa/inativa;
- protecao de abas e objetos;
- persistencia modal versus planilha;
- divergencia entre tela principal e dados completos.

## Preparacao V207

Para V207, a melhoria de testes deve acompanhar a proposta arquitetural de cadastro canonico com status:

- uma tabela canonica por entidade de dominio;
- status ativo/inativo como campo, nao como copia fisica de linha entre abas;
- historico de transicoes em tabela separada;
- interface Excel preservada como fachada operacional;
- invariantes verificaveis antes da migracao para SaaS.

Essa arquitetura deve ser auditada em ciclo proprio. Nao deve entrar na estabilizacao V206 salvo como documentacao e decisao futura.

## Criterios de Aceite

- RVS completo permanece obrigatorio para gate final.
- Cada microfix novo roda pelo menos uma suite modular dirigida.
- Cada BLOQUEADOR L43 tem teste associado ou roteiro manual auditavel.
- A duracao das suites passa a ser medida e registrada.
- Nenhuma suite modular pode mascarar falha do RVS; ela serve para feedback rapido, nao para reduzir rigor.
