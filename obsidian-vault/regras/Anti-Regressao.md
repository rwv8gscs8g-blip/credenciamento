# Protocolo Anti-Regressao

Relacionado: [[Governanca]], [[Orquestracao-IAs]], [[Bug-Nome-Repetido-TConfig]]

---

## Por que este documento existe

Entre janeiro e abril de 2026, o projeto sofreu regressao sistematica causada por:

1. Multiplas IAs (Cursor, GPT-5.2, Claude, Gemini) trabalhando sem contexto compartilhado
2. Cada IA refazendo decisoes ja tomadas e reintroduzindo bugs corrigidos
3. Ciclos de "delete tudo e reimporta" sem diagnostico previo
4. Ausencia de versionamento rigoroso no codigo VBA

**Resultado:** 3 meses perdidos em um erro ("Nome repetido: TConfig") que era um falso cascata causado por mudancas nao controladas.

---

## Mecanismos de Protecao

### 1. Git como barreira de regressao

Todo codigo que compila e commitado com tag. Se uma mudanca quebrar a compilacao:
```bash
git checkout v12.0.XXXX -- vba_export/ArquivoQueQuebrou.bas
```
Isso restaura INSTANTANEAMENTE o arquivo para o ultimo estado que compilava.

### 2. Uma mudanca por vez

Nunca modificar dois arquivos na mesma iteracao. Se a compilacao quebrar, sabemos EXATAMENTE qual mudanca causou o problema. Sem ambiguidade.

### 3. Obsidian como memoria persistente

Cada decisao arquitetural, cada bug resolvido, cada regra aprendida esta documentada neste vault. Quando uma nova IA assume o projeto, ela le 01-CONTEXTO-IA.md e tem acesso a todo o historico sem depender de contexto de sessao.

### 4. Checklist automatizado

O [[Checklist-Pre-Deploy]] roda verificacoes automaticas que detectam os killer patterns ANTES da importacao. Nenhum deploy sem checklist verde.

### 5. Modulos de teste isolaveis

Se o core nao compilar, os modulos de teste podem ser removidos temporariamente para isolar o problema. Sao 5 modulos que NAO afetam o fluxo de producao:
- Central_Testes.bas
- Central_Testes_Relatorio.bas
- Teste_Bateria_Oficial.bas
- Teste_UI_Guiado.bas
- Treinamento_Painel.bas

### 6. Proibicao de renomear VB_Name

Renomear o Attribute VB_Name de um modulo e a operacao mais perigosa do projeto. Requer:
- Teste isolado em workbook virgem
- Atualizacao de TODAS as referencias em outros modulos e forms
- Confirmacao de compilacao
- Rollback imediato se falhar

---

## Sinais de Alerta (parar e investigar)

- Erro "Nome repetido encontrado" -> NAO e encoding, NAO e ghost types. E erro cascata. Identificar qual modulo foi modificado por ultimo.
- Mais de 2 reimportacoes na mesma sessao -> algo fundamental esta errado. Parar e diagnosticar.
- IA sugerindo "apagar tudo e reimportar" -> rejeitar. Exigir diagnostico especifico.
- Arquivo .bas com LF (Unix) em vez de CRLF -> converter antes de importar.
- vbaProject.bin crescendo alem de 1 MB sem adicao de modulos -> possivel corrupcao, gerar workbook limpo.
