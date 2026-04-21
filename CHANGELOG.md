# Changelog

Este projeto adota o espírito do Keep a Changelog. As mudanças aqui registradas
tratam apenas da linha pública oficial.

## [Unreleased]

### Adicionado

- contrato explícito de release com tag, diretório de evidência e chave pública de teste em `src/vba/App_Release.bas`
- workflow de governança ampliado para verificar coerência entre versão, status oficial, tag, changelog e pacote de evidências
- documentação pública da esteira de release e evidência em `docs/GOVERNANCA_DE_RELEASE_E_EVIDENCIA.md`
- plano executável da Sprint 2 para fortalecimento incremental dos testes e redução de dependência da interface

### Alterado

- endurecimento do `verify-docs.yml` para a linha pública pós-lançamento da `V12.0.0202`

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
