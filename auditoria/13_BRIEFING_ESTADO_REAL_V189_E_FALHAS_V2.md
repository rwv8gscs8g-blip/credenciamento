# Briefing Operacional para Auditoria Externa

## Estado da versão

- Base retomada: `V12.0.0180`
- Versão atual analisada: `V12.0.0189`
- Branch: `codex/v180-stable-reset`
- Status documental: `EM_VALIDACAO`

## Situação atual da V2

A bateria V2 foi criada para ser:

- paralela à bateria legada
- mais semântica
- mais rastreável
- mais amigável para operação humana assistida
- mais adequada a CSVs de falha e automação futura

Os módulos principais são:

- [Central_Testes_V2.bas](/Users/macbookpro/Projetos/Credenciamento/vba_export/Central_Testes_V2.bas)
- [Teste_V2_Engine.bas](/Users/macbookpro/Projetos/Credenciamento/vba_export/Teste_V2_Engine.bas)
- [Teste_V2_Roteiros.bas](/Users/macbookpro/Projetos/Credenciamento/vba_export/Teste_V2_Roteiros.bas)

## Diagnóstico técnico já conhecido

### 1. Problema anterior da V2

Antes da `V12.0.0189`, a V2 falhava principalmente porque exigia da fila uma propriedade que o sistema não promete:

- renumerar `POSICAO_FILA` para `1..N` após cada giro

O contrato real do sistema, conforme o código, é:

- a fila mantém ordem relativa correta
- os IDs são únicos
- `POSICAO_FILA` continua crescente
- a fila não precisa voltar a `1..N`

Ponto relevante:

- [Repo_Credenciamento.bas](/Users/macbookpro/Projetos/Credenciamento/vba_export/Repo_Credenciamento.bas)
- [Svc_Rodizio.bas](/Users/macbookpro/Projetos/Credenciamento/vba_export/Svc_Rodizio.bas)

### 2. Problema atual da V2

Após o ajuste da semântica da fila, as falhas passaram a ser fatais logo na montagem do cenário determinístico.

CSV mais recente indica:

- `EMPRESAS=4`
- `ENTIDADE=4`
- `CREDENCIADOS=4`
- `PRE_OS=1`
- `CAD_OS=1`

Ou seja: o cenário determinístico da V2 está detectando resíduos estruturais depois do reset.

Ainda não está confirmado se isso é:

- falha real de limpeza
- falha de contagem da V2
- resíduo do workbook
- combinação desses fatores

## Hipótese forte

A bateria legada conta linhas usando a coluna-chave correta de cada aba, via `CountA`, enquanto a V2 ainda usa uma contagem baseada em `UltimaLinhaAba` e primeira linha de dados.

Isso pode gerar:

- falso positivo de linhas existentes
- leitura errada quando a coluna A ou a aba preserva resíduo fora da chave real

Arquivos relevantes:

- [Teste_Bateria_Oficial.bas](/Users/macbookpro/Projetos/Credenciamento/vba_export/Teste_Bateria_Oficial.bas)
- [Teste_V2_Engine.bas](/Users/macbookpro/Projetos/Credenciamento/vba_export/Teste_V2_Engine.bas)
- [Util_Planilha.bas](/Users/macbookpro/Projetos/Credenciamento/vba_export/Util_Planilha.bas)

## Lacunas UI -> serviço ainda abertas

As regras abaixo ainda não parecem totalmente centralizadas em serviços:

### `Svc_PreOS`

Possível lacuna:

- entidade inválida
- quantidade não positiva

Referências:

- [Svc_PreOS.bas](/Users/macbookpro/Projetos/Credenciamento/vba_export/Svc_PreOS.bas)
- [Menu_Principal.frm](/Users/macbookpro/Projetos/Credenciamento/vba_export/Menu_Principal.frm)

### `Svc_OS`

Possível lacuna:

- data prevista inválida

Referências:

- [Svc_OS.bas](/Users/macbookpro/Projetos/Credenciamento/vba_export/Svc_OS.bas)
- [Menu_Principal.frm](/Users/macbookpro/Projetos/Credenciamento/vba_export/Menu_Principal.frm)

### `Svc_Avaliacao`

Possível lacuna:

- divergência sem justificativa

Referências:

- [Svc_Avaliacao.bas](/Users/macbookpro/Projetos/Credenciamento/vba_export/Svc_Avaliacao.bas)
- [Menu_Principal.frm](/Users/macbookpro/Projetos/Credenciamento/vba_export/Menu_Principal.frm)

## O que a auditoria externa precisa responder

1. A V2 está errando na limpeza ou na medição?
2. A V1 resolve melhor esse ponto?
3. Quais regras de negócio ainda dependem indevidamente da UI?
4. A documentação atual ainda está aderente ao código?
5. Quais baterias complementares são necessárias para aprovar uma nova versão estável?
6. O que precisa acontecer para a V2 substituir a V1?
