# RELATÓRIO DE DECISÃO — BASE CNAE V12

**Data de geração**: 2026-04-04 09:18:09

## 1. Fonte Oficial Usada

- **API REST oficial do IBGE/CONCLA**
- **URL**: `https://servicodados.ibge.gov.br/api/v2/cnae/subclasses`
- **Versão**: CNAE Subclasses 2.3 (vigente desde janeiro de 2019)
- **Gestão**: IBGE + Subcomissão Técnica para a CNAE-Subclasses (coordenada pela Receita Federal)
- **Base legal**: Resolução Concla (migração de 2.2 para 2.3 a partir de 01/01/2019)

## 2. Motivo da Escolha da Fonte

A API REST do IBGE (`servicodados.ibge.gov.br`) é a fonte oficial primária e programática para dados de CNAE no Brasil. Retorna dados estruturados em JSON com hierarquia completa (Seção → Divisão → Grupo → Classe → Subclasse), incluindo observações e atividades econômicas. Foi preferida sobre o arquivo XLS estático por ser:

- Sempre atualizada
- Estruturada e parseável
- Reproduzível por script

## 3. Estrutura Original dos Dados

Cada registro da API contém:

```json
{
  "id": "6201501",
  "descricao": "DESENVOLVIMENTO DE PROGRAMAS DE COMPUTADOR SOB ENCOMENDA",
  "classe": {
    "id": "62015",
    "descricao": "...",
    "grupo": {
      "id": "620",
      "divisao": {
        "id": "62",
        "secao": { "id": "J", "descricao": "..." }
      }
    }
  },
  "atividades": [...],
  "observacoes": [...]
}
```

Hierarquia: **Seção** (21) → **Divisão** (87) → **Grupo** (285) → **Classe** (673) → **Subclasse** (~1332)

## 4. Regras de Limpeza/Normalização

1. **Código CNAE**: convertido de ID numérico puro (ex: `6201501`) para formato legível brasileiro (ex: `62.01-5/01`)
2. **Descrição**: convertida para MAIÚSCULAS (padrão oficial CNAE)
3. **Espaços**: removidos espaços duplos, quebras de linha e tabs
4. **Duplicidades**: removidas por chave (código + descrição)
5. **Ordenação**: por código CNAE crescente
6. **ID sequencial**: gerado de 1 a N para uso no sistema
7. **Nível utilizado**: Subclasse (5º nível) — é o mais granular e o utilizado em cadastros da Administração Pública

## 5. Critério de Classificação "Serviços"

Para a base recomendada de serviços, foram aplicados os seguintes critérios:

### Incluídas integralmente (por seção CNAE):

| Seção | Divisões | Descrição |
|-------|----------|-------------------------------------------------------|
| D | 35 | Eletricidade e gás |
| E | 36-39 | Água, esgoto, gestão de resíduos |
| F | 41-43 | Construção |
| H | 49-53 | Transporte, armazenagem e correio |
| I | 55-56 | Alojamento e alimentação |
| J | 58-63 | Informação e comunicação |
| K | 64-66 | Atividades financeiras e seguros |
| L | 68 | Atividades imobiliárias |
| M | 69-75 | Atividades profissionais e técnicas |
| N | 77-82 | Atividades administrativas e serviços complementares |
| O | 84 | Administração pública |
| P | 85 | Educação |
| Q | 86-88 | Saúde humana e serviços sociais |
| R | 90-93 | Artes, cultura, esporte e recreação |
| S | 94-96 | Outras atividades de serviços |
| T | 97 | Serviços domésticos |
| U | 99 | Organismos internacionais |

### Parcialmente incluída:

| Seção | Divisão | Critério |
|-------|---------|--------|
| G (Comércio) | 45 | Apenas reparação de veículos |

### Excluídas (salvo exceções por descrição):

| Seção | Descrição | Motivo |
|-------|-----------|--------|
| A | Agricultura, pecuária, pesca | Não é serviço para municípios |
| B | Indústrias extrativas | Não é serviço |
| C | Indústrias de transformação | Não é serviço |
| G (46-47) | Comércio atacadista/varejista | Puramente comercial |

### Exceção por padrão na descrição:

Subclasses de seções excluídas que contenham na descrição termos como MANUTENÇÃO, REPARAÇÃO, INSTALAÇÃO, SERVIÇO, CONSULTORIA, ASSESSORIA ou ASSISTÊNCIA TÉCNICA foram incluídas na base de serviços.

## 6. Quantidade Final de Registros

| Base | Registros |
|------|-----------|
| Completa (todas as subclasses) | 1332 |
| Recomendada (serviços) | 612 |

### Distribuição por seção (base de serviços):

| Seção | Descrição | Qtd |
|-------|-----------|-----|
| A | AGRICULTURA, PECUÁRIA, PRODUÇÃO FLORESTAL, PESCA E | 7 |
| C | INDÚSTRIAS DE TRANSFORMAÇÃO | 55 |
| D | ELETRICIDADE E GÁS | 8 |
| E | ÁGUA, ESGOTO, ATIVIDADES DE GESTÃO DE RESÍDUOS E D | 14 |
| F | CONSTRUÇÃO | 47 |
| G | COMÉRCIO; REPARAÇÃO DE VEÍCULOS AUTOMOTORES E MOTO | 31 |
| H | TRANSPORTE, ARMAZENAGEM E CORREIO | 70 |
| I | ALOJAMENTO E ALIMENTAÇÃO | 16 |
| J | INFORMAÇÃO E COMUNICAÇÃO | 47 |
| K | ATIVIDADES FINANCEIRAS, DE SEGUROS E SERVIÇOS RELA | 65 |
| L | ATIVIDADES IMOBILIÁRIAS | 6 |
| M | ATIVIDADES PROFISSIONAIS, CIENTÍFICAS E TÉCNICAS | 40 |
| N | ATIVIDADES ADMINISTRATIVAS E SERVIÇOS COMPLEMENTAR | 54 |
| O | ADMINISTRAÇÃO PÚBLICA, DEFESA E SEGURIDADE SOCIAL | 9 |
| P | EDUCAÇÃO | 23 |
| Q | SAÚDE HUMANA E SERVIÇOS SOCIAIS | 53 |
| R | ARTES, CULTURA, ESPORTE E RECREAÇÃO | 28 |
| S | OUTRAS ATIVIDADES DE SERVIÇOS | 37 |
| T | SERVIÇOS DOMÉSTICOS | 1 |
| U | ORGANISMOS INTERNACIONAIS E OUTRAS INSTITUIÇÕES EX | 1 |

## 7. Riscos e Ambiguidades

1. **Divisão 45 (Comércio e reparação de veículos)**: Incluída integralmente na base de serviços. Algumas subclasses podem ser predominantemente comerciais (venda de veículos). Para uso estrito, considerar filtrar manualmente.

2. **Seção F (Construção)**: Incluída integralmente. A construção civil é uma prestação de serviço, mas alguns municípios podem preferir separá-la.

3. **Serviços em seções industriais**: Subclasses de manutenção e reparação dentro da Seção C foram incluídas por exceção. Verificar se fazem sentido no contexto do município.

4. **Versão da API**: A documentação do IBGE menciona migração para 2.3 desde 2019. A API pode retornar versão ligeiramente diferente da esperada. Conferir campo de resposta se necessário.

### Casos cinzentos incluídos por padrão na descrição:

| CNAE | Descrição | Seção Original |
|------|-----------|----------------|
| 01.61-0/01 | SERVIÇO DE PULVERIZAÇÃO E CONTROLE DE PRAGAS AGRÍCOLAS | A - AGRICULTURA, PECUÁRIA, PRODUÇÃ |
| 01.61-0/02 | SERVIÇO DE PODA DE ÁRVORES PARA LAVOURAS | A - AGRICULTURA, PECUÁRIA, PRODUÇÃ |
| 01.61-0/03 | SERVIÇO DE PREPARAÇÃO DE TERRENO, CULTIVO E COLHEITA | A - AGRICULTURA, PECUÁRIA, PRODUÇÃ |
| 01.62-8/01 | SERVIÇO DE INSEMINAÇÃO ARTIFICIAL DE ANIMAIS | A - AGRICULTURA, PECUÁRIA, PRODUÇÃ |
| 01.62-8/02 | SERVIÇO DE TOSQUIAMENTO DE OVINOS | A - AGRICULTURA, PECUÁRIA, PRODUÇÃ |
| 01.62-8/03 | SERVIÇO DE MANEJO DE ANIMAIS | A - AGRICULTURA, PECUÁRIA, PRODUÇÃ |
| 01.70-9/00 | CAÇA E SERVIÇOS RELACIONADOS | A - AGRICULTURA, PECUÁRIA, PRODUÇÃ |
| 10.13-9/02 | PREPARAÇÃO DE SUBPRODUTOS DO ABATE | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 10.51-1/00 | PREPARAÇÃO DO LEITE | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 13.11-1/00 | PREPARAÇÃO E FIAÇÃO DE FIBRAS DE ALGODÃO | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 13.12-0/00 | PREPARAÇÃO E FIAÇÃO DE FIBRAS TÊXTEIS NATURAIS, EXCETO ALGOD | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 13.40-5/99 | OUTROS SERVIÇOS DE ACABAMENTO EM FIOS, TECIDOS, ARTEFATOS TÊ | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 16.10-2/05 | SERVIÇO DE TRATAMENTO DE MADEIRA REALIZADO SOB CONTRATO | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 18.21-1/00 | SERVIÇOS DE PRÉ IMPRESSÃO | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 18.22-9/01 | SERVIÇOS DE ENCADERNAÇÃO E PLASTIFICAÇÃO | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 18.22-9/99 | SERVIÇOS DE ACABAMENTOS GRÁFICOS, EXCETO ENCADERNAÇÃO E PLAS | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 23.30-3/05 | PREPARAÇÃO DE MASSA DE CONCRETO E ARGAMASSA PARA CONSTRUÇÃO | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 25.39-0/01 | SERVIÇOS DE USINAGEM, TORNEARIA E SOLDA | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 25.39-0/02 | SERVIÇOS DE TRATAMENTO E REVESTIMENTO EM METAIS | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 25.99-3/01 | SERVIÇOS DE CONFECÇÃO DE ARMAÇÕES METÁLICAS PARA A CONSTRUÇÃ | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 25.99-3/02 | SERVIÇO DE CORTE E DOBRA DE METAIS | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 32.50-7/06 | SERVIÇOS DE PRÓTESE DENTÁRIA | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 32.50-7/09 | SERVIÇO DE LABORATÓRIO ÓPTICO | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 33.11-2/00 | MANUTENÇÃO E REPARAÇÃO DE TANQUES, RESERVATÓRIOS METÁLICOS E | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 33.12-1/02 | MANUTENÇÃO E REPARAÇÃO DE APARELHOS E INSTRUMENTOS DE MEDIDA | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 33.12-1/03 | MANUTENÇÃO E REPARAÇÃO DE APARELHOS ELETROMÉDICOS E ELETROTE | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 33.12-1/04 | MANUTENÇÃO E REPARAÇÃO DE EQUIPAMENTOS E INSTRUMENTOS ÓPTICO | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 33.13-9/01 | MANUTENÇÃO E REPARAÇÃO DE GERADORES, TRANSFORMADORES E MOTOR | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 33.13-9/02 | MANUTENÇÃO E REPARAÇÃO DE BATERIAS E ACUMULADORES ELÉTRICOS, | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| 33.13-9/99 | MANUTENÇÃO E REPARAÇÃO DE MÁQUINAS, APARELHOS E MATERIAIS EL | C - INDÚSTRIAS DE TRANSFORMAÇÃO |
| ... | *(mais 32 registros)* | ... |

## 8. Recomendação de Manutenção Futura

1. **Rodar este script periodicamente** (semestral ou anual) para capturar eventuais atualizações da CNAE.
2. **Versionar os artefatos** gerados no Git do projeto.
3. **Manter o JSON bruto** como evidência de origem.
4. **Se a API mudar de versão**, ajustar a URL base neste script.
5. **Para inclusão de novas subclasses** pelo IBGE, re-executar o script e fazer diff com a versão anterior.

---

## Melhorias Recomendadas para Busca de CNAE

### Problema Atual

O cadastro de serviço depende de selecionar uma atividade/CNAE de uma lista com ~800+ itens. Uma ComboBox ou ListBox simples torna a seleção impraticável.

### Recomendação 1: TextBox de Busca Incremental (Preferida)

Implementar um TextBox onde o usuário digita parte do código ou da descrição, e uma ListBox abaixo filtra em tempo real.

**Vantagens:**
- UX familiar (tipo busca Google)
- Funciona bem com VBA legado (evento `Change` do TextBox)
- Permite busca por código E por descrição
- Performático: filtrar ~1300 registros em VBA é trivial

**Implementação sugerida:**

```vba
' No UserForm de cadastro de serviço:
' - TextBox: txtBuscaCNAE
' - ListBox: lstCNAE (2 colunas: CNAE, DESCRICAO)
'
' Private Sub txtBuscaCNAE_Change()
'     FiltrarCNAE txtBuscaCNAE.Value
' End Sub
'
' Sub FiltrarCNAE(termo As String)
'     Dim ws As Worksheet
'     Set ws = Sheets("ATIVIDADES")
'     lstCNAE.Clear
'     For Each row In ws.UsedRange.Rows
'         If InStr(1, row.Cells(1,2) & " " & row.Cells(1,3), termo, vbTextCompare) > 0 Then
'             lstCNAE.AddItem row.Cells(1,2)
'             lstCNAE.List(lstCNAE.ListCount-1, 1) = row.Cells(1,3)
'         End If
'     Next
' End Sub
```

### Recomendação 2: ListBox Filtrada por Seção

Adicionar um ComboBox com as seções CNAE (ex: "J - Informação e comunicação") que filtra a ListBox principal. Menos flexível que busca por texto, mas útil como complemento.

### Recomendação 3: Busca por Código E Descrição

Combinar as duas abordagens: o TextBox aceita tanto código (ex: "62.01") quanto texto (ex: "software"). Isso é possível com um único `InStr` que concatena código e descrição.

### Abordagem Mais Segura para VBA Legado

A **Recomendação 1** (TextBox + ListBox filtrada) é a mais segura porque:

- Usa apenas controles nativos do MSForms
- Não depende de ActiveX externo
- Não requer referências adicionais
- Funciona em todas as versões do Excel (2007+)
- Performático com ~1300 registros
- Mínimo risco de quebra

### NÃO implementar nesta passagem

Esta entrega foca exclusivamente na **base de dados pronta**. A melhoria de UX deve ser implementada em uma próxima passagem, após validação da base.
