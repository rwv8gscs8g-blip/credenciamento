# Changelog

Este projeto adota o espírito do Keep a Changelog. As mudanças aqui registradas
tratam apenas da linha pública oficial.

## [Unreleased]

### Adicionado

- contrato explícito de release com tag, diretório de evidência e chave pública de teste em `src/vba/App_Release.bas`
- camada de versionamento seguro com `release oficial`, `canal ativo`, `próxima release alvo` e `assinatura do build`
- rastreabilidade visual do pacote importado com `build importado`, `origem do build` e `pacote gerado em`
- novo cenário V2 `EXP_001` para validar expiração de Pre-OS com punição e retomada correta da fila
- proposta canônica `CS_*` para a Sprint 2 incorporada ao índice público e ao plano executável
- primeiro lote canônico `CS_00..CS_08` automatizado na V2
- cenário canônico `CS_22` automatizado para validar associação estável entre atividade e serviço em emissões repetidas
- cenários canônicos `CS_11` e `CS_13` automatizados para validar suspensão manual e reativação automática por prazo vencido
- cenários canônicos `CS_14`, `CS_16` e `CS_20` automatizados para validar suspensão por nota, retorno ordenado após prazo vencido e filtro cadastral de empresa inativa
- cenário canônico `CS_17` automatizado para validar giro longo `A,B,C,A,B,C,A` sem travamento e com integridade da fila
- cenário canônico `CS_18` automatizado para validar transições inválidas de OS concluída com rejeição auditável
- cenário canônico `CS_21` automatizado para validar completude mínima das famílias críticas do `AUDIT_LOG`
- cenários canônicos `CS_23` e `CS_24` automatizados para validar ida e volta de empresa e entidade entre cadastros ativos/inativos sem duplicidade semântica
- cenário `SMK_007` reforçado para validar auditoria mínima de fechamento e ausência de suspensão indevida em avaliação satisfatória
- cenário `ATM_001` reforçado para validar rollback multi-aba sem mutação residual em `EMPRESAS` e `CREDENCIADOS`, com mensagem legível de rollback
- cenário `STR_001` reforçado para validar IDs canônicos `001,002,003`, ausência de duplicidade semântica no item e quantidade final estável de credenciamentos
- extração inicial da montagem do payload de avaliação para `Svc_Avaliacao.bas`, reduzindo acoplamento no `Menu_Principal.frm`
- primeira extração da orquestração de emissão para `Svc_PreOS.bas` e `Svc_OS.bas`, reduzindo parsing e defaults locais no `Menu_Principal.frm`
- defaults da avaliação carregados diretamente da `CAD_OS`, com justificativa obrigatória quando houver edição de empenho, data, quantidade ou valor pré-preenchidos
- consistência da média da avaliação entre confirmação, persistência e impressão, usando um único cálculo canônico com duas casas decimais
- relatório imprimível da última execução V2 em `RPT_TESTES_V2`, com impressão opcional
- área documental `docs/testes/` para padronizar a narrativa humana das baterias de teste
- trilha cumulativa da suíte V2 em `TESTE_TRILHA` e `AUDIT_TESTES`
- limpeza opcional dos artefatos anteriores da V1 antes da nova execução
- fluxo da V1 unificado para um único ponto de impressão e sem exportação lateral no relatório
- limpeza opcional ampliada para remover artefatos V1/V2 e snapshots `SNAPV2_*`
- workflow de governança ampliado para verificar coerência entre versão, status oficial, tag, changelog e pacote de evidências
- documentação pública da esteira de release e evidência em `docs/GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md`
- plano executável da Sprint 2 para fortalecimento incremental dos testes e redução de dependência da interface
- primeira fatia de `C3` incorporada: relatórios simples do `Menu_Principal` agora reutilizam helper comum de configuração de página
- padronização inicial dos relatórios com título acentuado, nome do relatório no rodapé e referência auditável automática para impressão

### Alterado

- endurecimento do `verify-docs.yml` para a linha pública pós-lançamento da `V12.0.0202`
- tela `Sobre` do sistema para diferenciar visualmente a release oficial `V12.0.0202` da próxima release alvo `V12.0.0203`
- tela `Sobre` reduzida para evitar truncamento do `MsgBox` do VBA e exibir o commit exato do pacote importado
- bateria oficial V1 passa a exportar CSV automático apenas quando houver falhas
- modo de execução da V1 renomeado na interface para distinguir `RÁPIDA` de `ASSISTIDA`, mantendo a mesma bateria com diferença apenas de pausa visual
- V1 automatizada deixa de sincronizar `CHECKLIST_136` ao vivo e passa a usar apenas `RESULTADO_QA` como saída automática
- `CHECKLIST_136` passa a ser tratada como planilha manual opcional, desacoplada da bateria automatizada
- modo `ASSISTIDA` da V1 com delay reduzido e rolagem reposicionada para manter a linha atual mais abaixo na tela
- mensagens finais e relatório da V1 deixam de destacar `MANUAL` quando a execução é 100% automática
- `Audit_Log` ganha a família `Validacao Rejeitada`
- `Audit_Log` passa a diferenciar inativação e reativação de empresa vs entidade na descrição legível do evento
- `Svc_Avaliacao` passa a registrar `Avaliacao Registrada` de forma explícita e sempre auditável
- backlog explícito para revisão futura da UX dos testes assistidos antes do fechamento da versão

### Validado

- build `88107f1` importado em workbook de homologação, com `Sobre` exibindo commit, branch e data de geração do pacote
- compilação limpa confirmada por operador humano no build `88107f1`
- Bateria Oficial V1 rápida validada em 2026-04-26 com `OK=171` e `FALHA=0`
- V2 Smoke validado em 2026-04-26 com `OK=14`, `FALHA=0` e sem CSV de falhas
- V2 Canônica validada em 2026-04-26 com `OK=20`, `FALHA=0` e sem CSV de falhas

### Adiado

- promoção de `APP_RELEASE_ATUAL` para `V12.0.0203` até o fechamento formal da release
- desacoplamento total tela a tela da interface operacional
- reescrita do importador automático e revisão estrutural de `Mod_Types.bas`
- redesign visual completo dos testes assistidos e padronização visual profunda dos relatórios

## [V12.0.0202] - 2026-04-19

### Corrigido

- estabilização da chamada `AvaliarOS(...)` em workbooks restritivos
- consolidação da compilação após a linha de hotfixes da série `0194-0202`
- neutralização final do helper público de proteção de abas na árvore publicada

### Validado

- compilação limpa por operador humano
- bateria oficial recente sem falhas bloqueantes
- evidência pública da bateria oficial publicada em `auditoria/evidencias/V12.0.0202/`
- evidência fresca da V2 validada por operador humano e publicada no mesmo diretório
- auditoria positiva de pontos fortes consolidada em `auditoria/19_AUDITORIA_PONTOS_FORTES_V12_0202.md`

### Observações

- linha oficial registrada em [obsidian-vault/releases/STATUS-OFICIAL.md](obsidian-vault/releases/STATUS-OFICIAL.md)
- linha pública oficial promovida no `main`
- fechamento residual concentrado em homologação jurídica humana e automação adicional de governança
