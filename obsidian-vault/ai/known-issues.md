---
titulo: Issues Conhecidos
ultima-atualizacao: 2026-04-12
autor-ultima-alteracao: Claude Opus 4.6
tags: [vivo, bug]
versao-sistema: V12.0.0145
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

### CargaInicialCNAE roda desnecessariamente
- **Local**: Preencher.bas, linha 1555
- **Impacto**: CargaInicialCNAE_SeNecessario executa em todo PreenchimentoListaAtividade
- **Solucao proposta**: Verificar flag antes de executar

### Modulos temporarios pendentes de limpeza
- **Modulos**: Emergencia_CNAE, Emergencia_CNAE1/2/3, Importar_Agora
- **Acao**: Remover do VBE apos estabilizacao da importacao CNAE

## Resolvidos (ultimas 5 versoes)

### CNAE com formato inconsistente (V12.0.0144)
- Importacao emergencial usava formato com pontos (01.62-8/02)
- Fix: NormalizarCNAE extrai digitos e formata como DDDD-D/DD

### ATIVIDADES vazia apos ResetarECarregarCNAE (V12.0.0142-143)
- Dados limpos antes de validar CSV; protecao restaurada entre clear e import
- Fix: Reescrita com pre-validacao (V143), depois ImportarCNAE_Emergencia (V144)

### 34 colon patterns causando modulos invisiveis (V12.0.0022-025)
- Detalhes completos em [[REGRAS]]

## Documentos Relacionados

- [[REGRAS]] — Killers e prevencao
- [[ESTADO-ATUAL]] — Status do sistema
