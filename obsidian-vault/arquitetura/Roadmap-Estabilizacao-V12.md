# Roadmap de Estabilizacao V12

Status: em execucao  
Ultima release registrada: `V12.0.0141`

## 1. Objetivo desta trilha

Estabilizar o sistema VBA sem regressao funcional, garantindo:

1. compilacao recorrente no Excel
2. aderencia a regra de negocio
3. reducao de comportamento implicito gerado por codigo
4. persistencia dos dados estruturais na planilha final
5. base de testes automatica confiavel e reproduzivel

## 2. Frentes de trabalho

### Frente A - Compilacao e release

Objetivo:

- toda iteracao precisa compilar no Excel
- toda iteracao precisa ser documentada

Estado:

- `App_Release.bas` consolidado como fonte da versao
- releases oficiais registradas em `obsidian-vault/releases/`
- `vba_import/` tratado como artefato gerado

Proximos passos:

1. manter microiteracoes de compilacao quando necessario
2. evitar chamadas qualificadas de modulo padrao em pontos onde o workbook rejeita essa forma

### Frente B - Bateria oficial

Objetivo:

- transformar a bateria oficial na referencia unica de estabilidade automatica

Estado:

- bateria oficial zerada em falhas
- exportacao de CSV completo e CSV de falhas implementada

Proximos passos:

1. melhorar visualmente a indicacao da linha em execucao
2. ampliar os testes para integridade e filtros em cada tela estabilizada
3. futuramente gerar relatorio enxuto somente com falhas para handoff entre IAs

### Frente C - Dados estruturais

Objetivo:

- persistir baseline canonica dentro da planilha

Estado:

- `ATIVIDADES` definida como baseline estrutural permanente
- carga administrativa do CSV canonicamente suportada

Proximos passos:

1. validar exibicao consistente da aba `ATIVIDADES` apos reset e reabertura
2. garantir que filtros residuais nao escondam a baseline
3. confirmar persistencia em workbook distribuido para outras maquinas

### Frente D - Regra de negocio de servicos

Objetivo:

- manter a associacao manual entre CNAE e servicos

Estado:

- a regra foi explicitada pelo usuario
- foi descartada a estrategia de auto-gerar servicos a partir dos CNAEs

Proximos passos:

1. confirmar `CAD_SERV` vazio apos reset estrutural
2. confirmar cadastro manual via `Cadastro_Servico.frm`
3. garantir que a pagina `CADASTRA E ALTERA SERVICO` reflita apenas associacoes reais
4. exibir CNAE de forma clara na manutencao
5. validar impacto no rodizio

### Frente E - Estabilizacao visual dos formularios

Objetivo:

- substituir correcoes heuristicas por estrutura estavel no formulario sempre que viavel

Estado:

- varios filtros ja foram estabilizados com controles fisicos ou ligacoes robustas

Proximos passos:

1. revisar pagina de servicos
2. revisar duplicidade visual em cadastro de empresas
3. revisar captions e alinhamentos ainda corrigidos por codigo
4. retirar debito tecnico de `MEI` progressivamente, sem quebrar treinamento em producao

## 3. Ordem recomendada da proxima iteracao

1. compilar `V12.0.0140`
2. validar `ResetarECarregarCNAE_Padrao`
3. abrir `Cadastro_Servico.frm`
4. cadastrar um servico manual em um CNAE real
5. validar exibicao e filtro na pagina `CADASTRA E ALTERA SERVICO`
6. so depois seguir para ajuste visual da pagina de empresas

## 4. Criterio de sucesso desta fase

Esta fase de estabilizacao sera considerada concluida quando:

1. a bateria oficial continuar com zero falhas
2. `ATIVIDADES` persistir corretamente entre aberturas
3. `CAD_SERV` refletir somente associacoes manuais reais
4. os filtros das telas principais funcionarem
5. o rodizio operar sobre base coerente e auditavel
