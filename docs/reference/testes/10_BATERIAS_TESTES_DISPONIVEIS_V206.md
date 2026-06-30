---
titulo: Baterias de Testes Disponiveis V206
diataxis: reference
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-18
---

# Baterias de Testes Disponiveis - V12.0.0206

Este documento consolida as baterias de teste disponiveis no projeto em
2026-06-18. Ele preserva a V12.0.0205 como linha oficial validada e registra a
ampliacao observada na V12.0.0206 em validacao iterativa.

## Estado de versao

| Item | Estado |
|---|---|
| Release oficial | `V12.0.0205` |
| Gate oficial V205 | RVS, evidencia `VR_20260523_215637` |
| Linha atual analisada | `V12.0.0206` em validacao iterativa |
| Build importado atual | `8078e73+ONDA38.2.43-AVISO-2LINHAS-REL-ZOOM` |
| Execucao dos testes | Sempre pelo operador humano no workbook Excel |

Agentes de IA podem preparar, documentar e auditar os testes. Eles nao devem
executar Excel, VBE, TV2, RVS ou VCR diretamente.

## Gates de release

| Nome publico | Nome historico | Simbolo VBA preservado | Papel | Status |
|---|---|---|---|---|
| RVS - Gate de Validacao de Release | Sexteto Minimo | `CT_ValidarRelease_SextetoMinimo` | Gate oficial V205 com V1, V2 Smoke, V2 Canonica, E2E Strikes, IntegridadeBase e Onda23Adv | Oficial V205 |
| VCR - Validacao Completa de Release | Completa | `CT_ValidarRelease_Completa` / alias de `CT_ValidarRelease_SextetoMinimo` na linha atual | Gate consolidado atual; na V206 pode incluir complementos como ImpressaoResidual e PunicoesDias | V206 iterativo |
| SRC - Suite de Regressao Consolidada | Quinteto | `CT_ValidarRelease_QuintetoMinimo` | Regressao consolidada sem o bloco adversarial Onda 23 | Compatibilidade |
| BRL - Bateria Rapida Legada | Quarteto Direto | `CT_ValidarRelease_QuartetoMinimo` | Gate historico menor, mantido para compatibilidade | Legado |
| Trio | Trio Minimo | `CT_ValidarRelease_TrioMinimo` / `VR_ValidarReleaseTrioMinimo` | V1, V2 Smoke e V2 Canonica | Diagnostico rapido |

Gate V205 oficial:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

Checkpoint V206 registrado:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0+ImpressaoResidual=7/0+PunicoesDias=8/0
```

## Menu da Central de Testes V2

A `Central_Testes_V2.bas` expõe uma rota operacional por menu. Os rotulos
abaixo representam a intencao funcional de cada opcao.

| Opcao | Bateria | Papel |
|---:|---|---|
| 1 | RVS / Gate oficial | Validacao completa de release na linha V205/V206 |
| 2 | SRC | Regressao consolidada |
| 3 | BRL | Bateria rapida legada |
| 4 | Trio | Diagnostico rapido V1 + Smoke + Canonica |
| 5 | V1 Bateria Oficial | Regressao funcional ampla |
| 6 | V2 Smoke | Fumaca, integridade minima e cenarios criticos |
| 7 | V2 Suite Canonica | Fluxos canonicos de negocio |
| 8 | V2 Stress | Carga e robustez basica |
| 9 | V2 Filtros | Cobertura de filtros |
| 10 | V2 E2E Strikes | Penalidade, reativacao e janela punitiva |
| 11 | V2 Adversarial UI | Uso adversarial de interface |
| 12 | V2 Transacao Interrupt | Interrupcao e rollback transacional |
| 13 | V2 Boundary Dates | Datas de fronteira |
| 14 | Abrir resultado V2 | Apoio de leitura de resultado |
| 15 | Catalogo V2 | Consulta de catalogo |
| 16 | Historico V2 | Consulta historica |
| 17 | Trilha V2 | Consulta de trilha |
| 18 | Audit Testes | Consulta de auditoria |
| 19 | Evolucao Testes | Consulta de evolucao |
| 20 | Roteiro Assistido | Apoio a validacao humana |
| 21 | Limpar testes antigos | Higiene operacional de artefatos de teste |

## Baterias nucleares

| Bateria | Macro publica | Evidencia / destino usual | Cobertura |
|---|---|---|---|
| Bateria Oficial V1 | `RunBateriaOficial` / rota pela Central | `RESULTADO_QA` | Regressao ampla de comportamento historico |
| V2 Smoke | `TV2_RunSmoke` | `RESULTADO_QA_V2` | Sanidade basica, cenarios criticos e UI smoke read-only integrada |
| V2 Canonica | `TV2_RunCanonicoFundacao` | `RESULTADO_QA_V2` | Fluxos canonicos de credenciamento, avaliacao e rodizio |
| V2 Stress | `TV2_RunStress` | `RESULTADO_QA_V2` | Stress funcional controlado |
| V2 Filtros | `TV2_RunFiltros` | `RESULTADO_QA_V2` | Regras de filtro e selecao |
| E2E Strikes | `TV2_RunRodizioStrikesEndToEnd` | `RESULTADO_QA_V2` | Penalidades, reativacao, janelas e contadores |
| IntegridadeBase | `TV2_RunIntegridadeBase` | `RESULTADO_QA_V2` | Varredura estrutural de base |
| Onda23Adv - UI | `TV2_RunAdversarial_UI` | `RESULTADO_QA_V2` | Entradas adversariais em interface |
| Onda23Adv - Transacao | `TV2_RunTransaction_Interrupt` | `RESULTADO_QA_V2` | Interrupcao e rollback |
| Onda23Adv - Datas | `TV2_RunBoundary_Dates` | `RESULTADO_QA_V2` | Datas limite e janelas temporais |

## Suites dirigidas e complementares

| Macro publica | Frente coberta | Observacao |
|---|---|---|
| `TV2_RunUiSmokeReadOnly` | Fumaca visual sem escrita | Integrada ao Smoke em leituras atuais |
| `TV2_RunPersistenciaPainel` | Persistencia de painel | Apoio a integridade de interface |
| `TV2_RunIntegridadeEstado` | Integridade de estado | Suite estrutural historica |
| `TV2_RunConfigCenariosNovoPeriodo` | Configuracoes de novo periodo | Usada em V206 para persistencia e CSV |
| `TV2_RunTelaConfiguracoesIniciais` | Tela de configuracoes iniciais | Cobertura tela a tela |
| `TV2_RunTelaInicial` | Tela inicial e menu principal | Cobertura operacional inicial |
| `TV2_RunTelaRelatorios` | Tela de relatorios | Cobertura visual e funcional |
| `TV2_RunRelatoriosSuspensoesStrikesReset` | Relatorios de suspensoes, strikes e reset | Frente V206 com asserts ampliados |
| `TV2_RunImpressaoIntegridade` | Integridade de impressao | Apoio a validacao de relatorios |
| `TV2_RunImpressaoResidual` | Impressao residual | Complemento V206, checkpoint com `7/0` |
| `TV2_RunPunicoesDias` | Punicoes por dias | Complemento V206, checkpoint com `8/0` |
| `TV2_RunLeituraExibicao` | Leitura e exibicao | Consistencia de exibicao |
| `TV2_RunConfigBaselineSeguro` | Baseline seguro de configuracao | Guarda de configuracao |
| `TV2_RunConfigSnapshotV2` | Snapshot de configuracao | Comparacao e rastreabilidade |
| `TV2_RunPerformanceUXBasica` | Performance e UX basica | Sinalizacao operacional |
| `TV2_RunBehavioralizacaoC1` | Behavioralizacao C1 | Suite dirigida de comportamento |
| `TV2_RunFT4CredenciamentoLote` | Credenciamento em lote | Suite dirigida FT4 |
| `TV2_RunBL4ProtecaoPersistente` | Protecao persistente | Suite dirigida BL4 |
| `TV2_RunFormulariosAvaliacaoDemandante` | Formularios de avaliacao/demandante | Cobertura de formulario |
| `TV2_RunFormAvaliacaoModulos` | Modulos do formulario de avaliacao | Complemento modular |
| `TV2_RunFormulariosResiduaisCodeOnly` | Formularios residuais code-only | Guarda contra drift em forms |
| `TV2_RunUXIniciarSistemaCodeOnly` | UX de iniciar sistema | Guarda code-only |
| `TV2_RunBO330Diagnostico` | Diagnostico BO330 | Suite dirigida de diagnostico |

## Evidencias e locais de consulta

| Artefato | Papel |
|---|---|
| `RESULTADO_QA` | Saida da Bateria Oficial V1 |
| `RESULTADO_QA_V2` | Saida das suites V2 |
| `VALIDACAO_RELEASE` | Registro consolidado do gate de release |
| `AUDIT_TESTES` | Auditoria de execucao de testes |
| `TESTE_TRILHA` | Trilha de execucao |
| `RPT_*` | Relatorios e paineis gerados no workbook |
| `auditoria/evidencias/V12.0.0205/` | Evidencias versionadas da V205 oficial |

Na V205, a evidencia principal e `VR_20260523_215637`. Na V206, os checkpoints
registrados em auditoria servem como evidencias iterativas, mas nao substituem
o gate humano final de freeze.

## Regra operacional

Para uma validacao de release:

1. o operador importa o pacote no workbook pelo VBE quando houver pacote novo;
2. compila manualmente no VBE;
3. executa a bateria indicada pela Central de Testes;
4. confere o resultado consolidado e os CSVs gerados;
5. registra `VR_ID`, manifesto, prints ou PDFs quando exigido;
6. atualiza a auditoria/HBN apenas depois de confirmar o resultado.

Para uma correcao incremental V206, a suite minima deve ser definida no
readback da onda. Funcionalidade nova, regra nova, fluxo novo de UI ou
comportamento novo de servico exige teste correspondente no mesmo microdelta,
conforme a regra permanente HBN.

## Leitura para prestacao de contas

A ampliacao de testes entre abril e maio comprova trabalho tecnico em tres
dimensoes:

- maior quantidade de asserts automatizados;
- melhor separacao entre gates rapidos, regressao consolidada e gate oficial;
- cobertura de riscos antes pouco verificaveis, como transacao interrompida,
  datas de fronteira, reativacao, strikes, integridade de base e relatorios.

O gate oficial V205 e o marco de producao. Os complementos V206 demonstram
continuidade de melhoria e devem ser citados como linha em validacao ate novo
freeze humano.
