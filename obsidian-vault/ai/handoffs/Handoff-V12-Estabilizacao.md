# Handoff V12 - Estabilizacao Estrutural

Data: 2026-04-12  
Projeto: `/Users/macbookpro/Projetos/Credenciamento`  
Fonte de verdade: `vba_export/`  
Artefato gerado para importacao: `vba_import/`  
Release de trabalho mais recente no repositorio: `V12.0.0141`

## 1. Regras operacionais que NAO podem ser quebradas

1. A fonte de verdade do VBA e sempre `vba_export/`.
2. `vba_import/` e artefato gerado. Nunca editar manualmente sem espelhar a mudanca em `vba_export/`.
3. Toda release funcional deve ter nota correspondente em `obsidian-vault/releases/`.
4. O numero da versao exibido ao usuario vem de `vba_export/App_Release.bas`.
5. Toda iteracao deve terminar com:
   - checklist estatico
   - republicacao de `vba_import/`
   - compilacao manual no Excel
6. O usuario esta validando manualmente no Excel a cada passo. O fluxo real e incremental e controlado.

## 2. Como o projeto esta sendo estabilizado

O processo atual nao e de feature solta. E de estabilizacao arquitetural ponto a ponto, tela a tela, com foco em:

1. compilar sempre
2. reduzir comportamento automatico implicito
3. mover comportamento estavel para estrutura fixa de formulario e planilha
4. preservar regra de negocio antes de embelezar interface
5. documentar cada decisao em release note e handoff

### Principio central adotado

- `ATIVIDADES` = baseline estrutural permanente de CNAEs/atividades
- `CAD_SERV` = associacao operacional manual de servicos aos CNAEs

Isso e critico. Uma IA nova nao deve voltar a auto-gerar servicos ficticios em `CAD_SERV` como clone de `ATIVIDADES`, porque isso viola a regra de negocio.

## 3. O que ja foi estabilizado

### 3.1 Bateria oficial

- A bateria oficial foi estabilizada ate ficar com `0 falhas`.
- Foi implementada exportacao de:
  - CSV completo
  - CSV somente com falhas
- O formato preferencial para analise futura e:
  1. CSV de falhas
  2. mensagem fatal exata
  3. CSV completo apenas se necessario

### 3.2 Filtros e reativacao

Ja foram estabilizados e validados manualmente:

- filtro de empresas
- filtro de entidades
- inativacao/reativacao de empresas
- inativacao/reativacao de entidades

### 3.3 Release metadata

- `App_Release.bas` e a fonte unica de metadata da release
- `Menu_Principal.frm` consome essa metadata
- release notes em `obsidian-vault/releases/` sao o historico oficial da linha V12

## 4. Estado atual da estabilizacao de CNAE e servicos

### 4.1 O problema que foi identificado

O sistema estava misturando duas camadas:

- baseline estrutural de CNAEs (`ATIVIDADES`)
- cadastro operacional de servicos (`CAD_SERV`)

O erro anterior de arquitetura foi este:

- carregar CNAEs em `ATIVIDADES`
- depois reconstruir `CAD_SERV` automaticamente usando a propria descricao da atividade como se fosse servico

Isso gerava:

- tela de manutencao de servicos com dados artificiais
- filtro que nao ajudava a localizar CNAE real
- risco de distorcer a regra de rodizio

### 4.2 Decisao de negocio consolidada

Esta decisao veio do usuario e precisa ser respeitada:

1. os CNAEs reais devem ficar persistidos na planilha
2. usuarios em outras maquinas nao podem depender do CSV na raiz
3. a associacao de servicos aos CNAEs sera feita manualmente
4. essa associacao manual e a chave para o rodizio

Em outras palavras:

- `ATIVIDADES` deve ser permanente e persistida
- `CAD_SERV` nao deve ser preenchida automaticamente com servicos ficticios

## 5. Ultima iteracao implementada no codigo (`V12.0.0139`)

Arquivos alterados:

- `vba_export/Preencher.bas`
- `vba_export/Util_Planilha.bas`
- `vba_export/Menu_Principal.frm`
- `vba_export/App_Release.bas`
- `obsidian-vault/releases/V12.0.0139.md`

Objetivo dessa iteracao:

1. parar de auto-gerar servicos em `CAD_SERV`
2. limpar `CAD_SERV` no reset estrutural para associacao manual
3. exibir CNAE na tela de manutencao de servicos
4. filtrar servicos por `CNAE + atividade + servico`
5. limpar filtros residuais em abas estruturais

### Mudancas tecnicas aplicadas

#### `Preencher.bas`

- `LinhaServicoPassaFiltroCred` passou a considerar CNAE
- foi criada `BuscarCnaeAtividade`
- `PreenchimentoServico` passou a considerar CNAE no filtro
- `ResetarECarregarCNAE_Padrao` deixou de chamar reconstrucao automatica de `CAD_SERV`
- foi criada `LimparCadServParaAssociacaoManual`
- `PreencherManutencaoValor` passou a:
  - aceitar filtro opcional
  - exibir CNAE
  - filtrar por CNAE/atividade/servico

#### `Util_Planilha.bas`

- foi criada `Util_LimparFiltrosAba`

#### `Menu_Principal.frm`

- foi criado `mTxtFiltroCadServ`
- `H_Lista_Click` foi ajustado para a nova estrutura da lista
- `Filtros_CriarDinamico` agora cria/liga filtro na lista de manutencao de servicos
- `mTxtFiltroCadServ_Change` chama `PreencherManutencaoValor`
- `B_CAD_SERV_Click` e `Cad_Servico_Click` passaram a reaplicar a lista de manutencao com filtro

## 6. O que o usuario viu no Excel

### Comportamentos observados e confirmados

1. a macro `ResetarECarregarCNAE_Padrao` executou e informou `597 registros`
2. imediatamente depois, a aba `ATIVIDADES` parecia vazia no topo
3. depois de fechar/abrir novamente, os CNAEs passaram a aparecer
4. a pagina `CADASTRA E ALTERA SERVICO` mostrava lista com atividade/servico, mas:
   - sem numero do CNAE
   - com filtro superior sem efeito util
   - com sinais de mistura entre estrutura CNAE e servico operacional

### Diagnostico consolidado

- a aparencia de “aba vazia” e consistente com filtro residual de tabela/aba
- a tela de manutencao ainda estava lendo `CAD_SERV`
- a tela modal `Cadastro_Servico` ja estava mais correta que a pagina interna, porque lista `ID + CNAE + descricao` de `ATIVIDADES`

## 7. Ultimo erro de compilacao identificado

O erro real foi capturado pelo usuario no `Menu_Principal.frm`, em `Cad_Servico_Click`.

Linha destacada:

- `Call Preencher.PreenchimentoListaAtividade`

Diagnostico:

- este workbook rejeita algumas chamadas qualificadas a modulos padrao dentro de formularios
- o erro aparece como `Metodo ou membro de dados nao encontrado`
- essa mesma familia de problema ja tinha aparecido antes com `Preencher.CargaInicialCNAE_SeNecessario`

Correcao aplicada em `V12.0.0140`:

- trocar chamadas novas qualificadas por chamadas diretas:
  - `PreenchimentoListaAtividade`
  - `PreencherManutencaoValor`

Se a proxima IA receber novo erro de compilacao parecido, o primeiro teste deve ser:

1. verificar se a chamada esta qualificada por nome de modulo padrao
2. testar a versao direta sem prefixo do modulo

## 8. Pacote correto para importar na iteracao `V12.0.0140`

Se a proxima IA quiser reproduzir o estado do repositorio, o pacote minimo e:

- `vba_import/001-modulo/006-Util_Planilha.bas`
- `vba_import/001-modulo/021-Preencher.bas`
- `vba_import/001-modulo/024-App_Release.bas`
- `vba_import/002-formularios/Menu_Principal.frm`

E manter `vba_import/002-formularios/Menu_Principal.frx` ao lado do `.frm`.

## 9. Roadmap tecnico imediato

### Etapa A - Fechar compilacao da `V12.0.0139`

1. importar o pacote minimo acima
2. recompilar
3. so se houver novo erro, capturar a nova linha destacada

### Etapa B - Validar regra de negocio de servicos

1. rodar `ResetarECarregarCNAE_Padrao`
2. confirmar `ATIVIDADES` persistida com CNAEs reais
3. confirmar `CAD_SERV` vazio apos reset estrutural
4. abrir `Cadastro_Servico`
5. selecionar atividade/CNAE e cadastrar servico manualmente
6. confirmar refletido na pagina `CADASTRA E ALTERA SERVICO`

### Etapa C - Estabilizacao visual da pagina de servicos

1. exibir CNAE de forma clara na lista
2. garantir filtro superior funcional
3. eliminar qualquer dado estrutural ficticio remanescente

### Etapa D - Proximas passadas de UI fixa

1. revisar campos ainda “corrigidos por codigo”
2. corrigir duplicidade visual no cadastro de empresas
3. estabilizar textos/labels direto no formulario quando isso nao quebrar treinamento existente

## 10. O que NAO fazer

1. nao renomear o botao lateral `CADASTRA E ALTERA SERVICO`
2. nao recriar `CAD_SERV` automaticamente a partir de `ATIVIDADES`
3. nao depender do CSV da raiz na maquina final do usuario
4. nao tratar release note fora de `obsidian-vault/releases/`
5. nao editar apenas `vba_import/`

## 11. Forma correta de continuidade por outra IA

1. ler este handoff
2. ler:
   - `obsidian-vault/arquitetura/Release-Compilacao.md`
   - `obsidian-vault/releases/V12.0.0135.md`
   - `obsidian-vault/releases/V12.0.0138.md`
   - `obsidian-vault/releases/V12.0.0139.md`
3. pedir ao usuario a linha exata do erro de compilacao da `V12.0.0139`
4. corrigir
5. recompilar
6. seguir com a validacao manual de `ATIVIDADES` e `CAD_SERV`
