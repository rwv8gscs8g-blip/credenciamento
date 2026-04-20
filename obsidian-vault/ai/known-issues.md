---
titulo: Issues Conhecidos
ultima-atualizacao: 2026-04-19
autor-ultima-alteracao: GPT-5 (Codex)
tags: [vivo, bug]
versao-sistema: V12.0.0202
---

# Issues Conhecidos

## Ativos

### Performance: ProximoId faz protect/unprotect por linha
- **Local**: Util_Planilha.bas, funcao ProximoId
- **Impacto**: Lento em importacoes grandes (600+ linhas)
- **Workaround**: ImportarCNAE_Emergencia contorna usando acesso direto

### Performance: AtividadeJaExiste usa varredura O(n^2)
- **Local**: Preencher.bas
- **Impacto**: Lento ao verificar duplicatas em 612 atividades
- **Solucao proposta**: Usar Dictionary para lookup O(1)

### V2 ainda precisa de evidencia fresca para nova auditoria
- **Local**: Central_Testes_V2 / Teste_V2_Engine / Teste_V2_Roteiros
- **Impacto**: nova auditoria externa ainda pode apontar falta de comprovacao recente da suite V2
- **Acao**: rerodar smoke, stress e assistido apos a faxina do repositorio

### Repositorio publico ainda nao esta racionalizado
- **Local**: README, dashboard, historico e documentos internos
- **Impacto**: ruido desnecessario para leitura publica, compliance e onboarding tecnico
- **Acao**: concluir a linha de corte publica e retirar material operacional interno da superficie versionada

### Importador ainda nao e o fluxo oficial
- **Local**: Importador_VBA / Importar_Agora
- **Impacto**: atualizacao do workbook ainda depende de operacao assistida
- **Acao**: estabilizar o sistema primeiro e reescrever o importador depois, como reset/reimportacao deterministica

## Resolvidos (ultimas 5 versoes)

### Compilacao quebrada por chamadas qualificadas / modulos faltantes (V12.0.0196-0202)
- Sequencia de hotfixes encerrou a arvore de compilacao
- Resultado: V12.0.0202 compilada e bateria oficial recente verde

### Baseline deterministica da V2 (V12.0.0190)
- Contagem e reset passaram a operar por coluna-chave semantica
- Resultado: bootstrap fatal da V2 foi eliminado

### Migracoes UI -> servico prioritarias (V12.0.0191)
- `MIG_001`, `MIG_002`, `MIG_003` e `MIG_004` sairam da UI critica e ficaram assertivos no servico

## Documentos Relacionados

- [[REGRAS]] — Killers e prevencao
- [[ESTADO-ATUAL]] — Status do sistema
