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
- workflow de governança ampliado para verificar coerência entre versão, status oficial, tag, changelog e pacote de evidências
- documentação pública da esteira de release e evidência em `docs/GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md`
- plano executável da Sprint 2 para fortalecimento incremental dos testes e redução de dependência da interface

### Alterado

- endurecimento do `verify-docs.yml` para a linha pública pós-lançamento da `V12.0.0202`
- tela `Sobre` do sistema para diferenciar visualmente a release oficial `V12.0.0202` da próxima release alvo `V12.0.0203`
- tela `Sobre` reduzida para evitar truncamento do `MsgBox` do VBA e exibir o commit exato do pacote importado

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
