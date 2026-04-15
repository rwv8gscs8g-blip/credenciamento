# Backlog: CNAE Import (V12.0.0108)

**Status**: Em Planejamento
**Target Version**: V12.0.0108
**Prioridade**: ALTA
**Esforco Estimado**: 3-4 horas

---

## Objetivo

Adicionar modulo Util_CNAE.bas que importa dados de tabela CNAE (Classificacao Nacional de Atividades Economicas) de arquivo CSV. Permite usuarios enriquecer cadastro de atividades com dados fiscais oficiais.

---

## Requisitos

### Funcional
- [ ] Importar CSV com format: CODIGO,NOME,DESCRICAO
- [ ] Validar CNAE codigo format (6 digitos)
- [ ] Inserir atividades em planilha Atividade
- [ ] Log cada insercao em AuditLog
- [ ] Oferecer button em Menu_Principal para import
- [ ] Mostrar progressBar enquanto importa
- [ ] Relatorio de resumo: X atividades importadas, Y duplicadas

### Nao Funcional
- [ ] Performance: 10k linhas em <5 segundos
- [ ] Zero dependencias externas (apenas VBA nativo)
- [ ] Isolado: nenhuma mudanca em outros modulos

---

## Especificacao

### API

```vba
' Em Util_CNAE.bas
Public Function ImportarCNAE(arquivo As String) As TResult
  ' Entrada: path do arquivo CSV
  ' Processo:
  '   1. Abrir arquivo (Scripting.FileSystemObject)
  '   2. Ler linhas
  '   3. Para cada linha: CNAE_CODIGO, NOME, DESCRICAO
  '   4. Validar codigo (6 digitos)
  '   5. Buscar se atividade ja existe (por nome)
  '   6. Se nao existe: criar TAtividade novo, inserir
  '   7. Se existe: skip (duplicada)
  '   8. Log cada insercao em AuditLog
  ' Saida: TResult com contador de importadas e duplicadas
  
  ' Pseudo-codigo
  Dim fso As Object, file As Object
  Set fso = CreateObject("Scripting.FileSystemObject")
  Set file = fso.OpenTextFile(arquivo, 1) ' 1=ForReading
  
  Dim contadorImportadas As Long, contadorDuplicadas As Long
  contadorImportadas = 0
  contadorDuplicadas = 0
  
  Dim linha As String
  Do Until file.AtEndOfStream
    linha = file.ReadLine()
    
    ' Parse CSV
    Dim partes As Variant
    partes = Split(linha, ",")
    If UBound(partes) < 2 Then GoTo ProxLinha
    
    Dim codigo As String, nome As String, descricao As String
    codigo = Trim(partes(0))
    nome = Trim(partes(1))
    descricao = Trim(partes(2))
    
    ' Validar
    If Len(codigo) <> 6 Or Not IsNumeric(codigo) Then GoTo ProxLinha
    
    ' Buscar duplicada
    Dim ativExiste As Boolean
    ativExiste = (BuscadorAtividadePorNome(nome) IsNot Nothing)
    
    If ativExiste Then
      contadorDuplicadas = contadorDuplicadas + 1
    Else
      Dim ativ As TAtividade
      ativ.Nome = codigo & " - " & nome
      ativ.Descricao = descricao
      ativ.Ativo = True
      
      Repo_Credenciamento.CriarAtividade(ativ)
      Audit_Log.LogOperacao("CNAE_IMPORTADA", "Util_CNAE", "CNAE " & codigo)
      contadorImportadas = contadorImportadas + 1
    End If
    
ProxLinha:
  Loop
  
  file.Close()
  Set file = Nothing
  Set fso = Nothing
  
  ' Resultado
  ImportarCNAE.Sucesso = True
  ImportarCNAE.Mensagem = contadorImportadas & " atividades importadas, " & contadorDuplicadas & " duplicadas"
  ImportarCNAE.Dados = contadorImportadas
End Function
```

### CSV Format

```
CNAE_CODIGO,NOME,DESCRICAO
430011,Construcao de projetos de infraestrutura para transportes,Construcao de projetos de infraestrutura para transportes
430012,Construcao de outras obras de infraestrutura,Construcao de outras obras de infraestrutura
...
7022000,Consultoria em gestao empresarial,Consultoria em gestao empresarial
7030000,Servicos de traducao,Servicos de traducao
...
```

Fonte: tableauontax.cnae.gov.br (CNAE oficial Brazil)

---

## Implementacao

### Passo 1: Criar Util_CNAE.bas (ISOLADO)
- [ ] Implementar ImportarCNAE() function
- [ ] Implementar helper ValidarCodigo()
- [ ] Implementar helper BuscadorAtividadePorNome()
- [ ] Testar compilacao (Debug > Compile)
- [ ] Testar com arquivo CSV pequeno (10 linhas)

### Passo 2: Integrar em Menu_Principal (ITERACAO PROXIMA)
- [ ] Adicionar Button "Importar CNAE"
- [ ] Button abre FileDialog para selecionar CSV
- [ ] Chama Util_CNAE.ImportarCNAE()
- [ ] Mostra ProgressBar enquanto importa
- [ ] Mostra resultado (X importadas, Y duplicadas)

### Passo 3: Adicionar Teste (ITERACAO PROXIMA)
- [ ] Teste_ImportarCNAE() em Teste_Bateria_Oficial.bas
- [ ] Criar arquivo CSV de teste (5 linhas)
- [ ] Assert: contadorImportadas == 5
- [ ] Assert: contadorDuplicadas == 0 (primeira execucao)
- [ ] Executar novamente: contadorDuplicadas == 5 (duplicadas agora)

---

## Decisions e Consideracoes

### Por Que CSV e Nao Baixar Direto de tableauontax API?
- CSV: simples, usuario controla quando importa, zero dependencias externas
- API: real-time, mas requer conexao internet, timeout risk, authentication

**Escolha**: CSV
**Racional**: Usuarios podem baixar uma vez, importar multiplas vezes. Offline-first approach.

### Por Que Validar CNAE Codigo (6 Digitos)?
- tableauontax padrao: CNAE sempre 6 digitos numericos
- Validacao: detecta linhas corrompidas ou headers acidentais

### Por Que Skip Duplicadas em Lugar de Update?
- Duplicada = mesmo nome ja existe
- Update seria: sobrescrever descricao? Nao, pode quebrar relacionamentos
- Skip: safe, usuario pode deletar e reimportar se quiser atualizar

### Performance: 10k Linhas em 5 Segundos?
- 1 linha = read + parse + validate + insert = ~0.5ms
- 10k linhas = ~5 segundos (aceitavel)
- Otimizacao futuro: batch inserts (Util_Planilha.InserirLote)

---

## Arquivo CSV Exemplo

```csv
CNAE_CODIGO,NOME,DESCRICAO
2331100,Reparacoes de maquinas industriais,Reparacoes de maquinas industriais
2340100,Tratamento e reciclagem de residuos nao perigosos,Tratamento e reciclagem de residuos nao perigosos
4330000,Limpeza de edificos e remanejamento de residuos,Limpeza de edificos e remanejamento de residuos
...
```

(Usuarios baixam de tableauontax.cnae.gov.br)

---

## Release Notes Template (V12.0.0108)

```markdown
## V12.0.0108 - Import CNAE

### Novas Funcionalidades
- Adicionar modulo Util_CNAE.bas com funcao ImportarCNAE()
- Import de dados CNAE de arquivo CSV
- Novo button em Menu_Principal: "Importar CNAE"

### Modulos Alterados
- Util_CNAE.bas (novo)

### Modulos NAO Alterados
- Menu_Principal form mudanca futura (V12.0.0109)

### Testes
- Teste_ImportarCNAE: PASSOU

### Notas
- Isolado. Nenhuma integracao com Auto_Open ainda.
- Proxima iteracao (V12.0.0109): integrar em Menu_Principal
- Proxima iteracao (V12.0.0110): integrar em Cadastro_Servico para auto-sugerir CNAE
```

---

## Dados de Entrada

### Arquivo CSV CNAE Completo
- Tamanho: ~1.5MB
- Linhas: ~18.000 atividades
- Encoding: UTF-8
- Delimiter: comma
- Header: CNAE_CODIGO,NOME,DESCRICAO

Disponivel em: https://www.gov.br/infraestrutura/pt-br/assuntos/cnae

---

## Success Criteria

- [ ] Funcao ImportarCNAE implementada
- [ ] Compilacao OK
- [ ] Teste unitario passa
- [ ] Performance: 10k linhas em <5 segundos
- [ ] AuditLog log cada insercao
- [ ] Release note criada
- [ ] Git commit feito

---

## Links Relacionados

- [[releases/V12.0.0107]] - Release anterior
- [[arquitetura/Modulos-VBA]] - Detalhes Util_CNAE
- [[regras/Compilacao-VBA]] - Regras para desenvolvimento

---

**Status**: Ready for Implementation
**Prioridade**: ALTA (melhora UX)
**Próximo**: V12.0.0109 (integrar em Menu_Principal)
