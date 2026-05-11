---
titulo: 67 - Status V204 Pos-Sexteto e Roadmap para Producao
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-09
---

# 67. Status V204 Pos-Sexteto e Roadmap para Producao

## 1. Estado Atual

| Eixo | Status | Evidencia |
|---|---|---|
| Onda 22 dados legados | Fechada | MICRO37-40 aprovados |
| Onda 23 baterias adversariais | Fechada | MICRO41-45 aprovados |
| Onda 24 hardening | Fechada com ressalva | MICRO46-48 aprovados; MICRO49 reprovado e revertido |
| Gate vigente | Sexteto | `VR_20260510_000428` |
| Suite adversarial UI | Verde | `ADVERSARIAL_UI=12/0/0` em `TV2_20260509_141117` |
| Sexteto | Verde | `V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` |
| Build atual | V204 rc1 | `f7aa84f+v12.0.0204-rc1` |

Conclusao: a V204 chegou a rc1 com Sexteto verde. Ainda nao esta pronta
para producao porque restam auditoria cruzada final, aceite explicito do
operador e publicacao/tag.

## 2. O Que Falta nas Baterias de Testes

| Prioridade | Ponto | Acao recomendada | Bloqueia producao? |
|---|---|---|---|
| P0 | Tornar o Sexteto o gate oficial de fechamento | Usar `CT_ValidarRelease_SextetoMinimo` em todos os microdeltas daqui para frente | Sim |
| P0 | Alinhar evidencia V204 | Caminho corrigido em MICRO50: CSV esta em `auditoria/evidencias/V12.0.0204` | Atendido |
| P1 | Congelar baseline de contagens | Baseline rc1: `171/33/24/76/4/27` | Sim |
| P1 | Testes adversariais apos hardening Onda 24 | Cada correcao funcional deve incluir assert novo ou atualizar assert existente | Sim |
| P2 | Relatorio humano das suites | Melhorar leitura de `RESULTADO_QA_V2` e matriz de rastreabilidade para auditor humano | Nao, mas recomendado |

## 3. Bordas Ainda Pendentes

As bordas automatizadas de data e strikes estao cobertas pela Onda 22/23.
Faltam bordas de producao que dependem de UI, ambiente ou politica:

| Area | Lacuna | Proposta |
|---|---|---|
| UI destrutiva | `Limpar_Base` ainda tem senha hardcoded e acao altamente sensivel | MD-24.1: mitigar senha hardcoded, melhorar confirmacao e teste assistido |
| Configuracao | Config invalida precisa falhar com mensagem clara e evento de auditoria | MD-24.2: validar e registrar falha configuracional |
| Avaliacao | Operador precisa enxergar contador bruto vs contador punitivo pos-reativacao | MD-24.3: evento dual-counter |
| Rodizio | `SelecionarEmpresa` tem side-effects de fila/reativacao que precisam ficar explicitos | Deferido para V205 apos MICRO49/MICRO49-fix1/MICRO49-fix2 reprovados |
| Ambiente | Locale/timezone Windows e permissao de export CSV ainda sao manual-assistidos | Checklist Onda 25 |

## 4. Melhorias de Regressao Ainda Necessarias

1. Reexecutar Sexteto apos cada microdelta da Onda 24.
2. Guardar evidencia CSV do Sexteto em `auditoria/evidencias/V12.0.0204`.
3. Atualizar matriz `regra -> cenario -> assert -> evidencia` sempre que
   um teste mudar.
4. Criar um checklist de regressao manual para os fluxos destrutivos:
   limpar base, reativar empresa, reativar entidade, avaliar OS, emitir OS.
5. Revalidar `RPT_BUGS_CONHECIDOS`: nenhum P0/P1 aberto pode seguir para
   producao; P2 precisa ter aceite explicito.

## 5. Roadmap Recomendado a Partir de Agora

### Onda 24 - Hardening Funcional e Usabilidade

| Micro | Tema | Gate |
|---|---|---|
| MICRO46 | MD-24.1 `Limpar_Base` seguro: senha hardcoded, confirmacao e guard | Sexteto + teste assistido |
| MICRO47 | MD-24.2 configuracao invalida: mensagem clara + evento | Sexteto |
| MICRO48 | MD-24.3 avaliacao com dual-counter bruto/punitivo | Sexteto + E2E Strikes |
| MICRO49/fix1/fix2 | MD-24.4 `SelecionarEmpresa`: side-effects explicitos | Reprovado por compile crash/build stale; rollback para MICRO48 ratificado |

### Onda 25 - Release Candidate V204

| Micro | Tema | Gate |
|---|---|---|
| MICRO50 | Bump `v12.0.0204-rc1`, evidence dir V204 e release notes | Aprovado em `VR_20260510_000428` |
| MICRO51 | Higiene documental final, debitos aceitos e checklist de publicacao | Concluido como delta documental |
| MICRO52 | Auditoria cruzada final Opus + Antigravity | Sem P0/P1 |
| MICRO53 | Correcoes finais das auditorias, se houver | Sexteto |
| MICRO54 | Tag/push GitHub e pacote candidato a producao | Aprovacao operador |

### Onda 26 - Documentacao, RAG e Lapidacao

Nao deve bloquear a release tecnica se a Onda 25 estiver verde, mas deve
entrar logo depois:

1. Checklist canonico de higiene documental por fase.
2. Estrategia Obsidian/RAG para navegação por humanos e IAs.
3. Faxina de duplicidades, indices e docs obsoletos.
4. Auditoria documental cruzada.

## 6. Criterio Minimo Para Submeter a Producao

| Criterio | Status atual |
|---|---|
| Sexteto verde | Atendido em `VR_20260510_000428` |
| Onda 24 hardening concluida | Atendido com ressalva: MD-24.4 deferido para V205 |
| Evidencias V204 alinhadas | Atendido no caminho; filename historico registrado como P2 |
| CHANGELOG e release notes V204 completos | Parcial: rc1 atualizado, release notes publicas pendentes |
| RPT_BUGS_CONHECIDOS sem P0/P1 aberto | Pendente |
| Auditoria cruzada final sem P0/P1 | Pendente |
| GitHub limpo com tag/release | Pendente |
| Plano de rollback e ancora final | Pendente |

## 7. Parecer

A recomendacao agora e nao abrir novas features de negocio antes da
publicacao. A prioridade deve ser auditoria cruzada final, triagem de
P0/P1 e release notes publicas. MD-24.4 e os residuos strict ficam
registrados como debito tecnico para V205/Onda 26.
