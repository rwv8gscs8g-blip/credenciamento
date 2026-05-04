# Modelo Documental dos Testes

Este é o modelo canônico de documentação dos testes do projeto.

## Regra

Todo documento de testes novo ou revisado deve seguir, no mínimo, esta estrutura:

1. leitura do cenário
2. matriz de estados
3. decomposição em blocos
4. catálogo de cenários
5. para cada cenário:
   - pré-condição
   - ação
   - resultado esperado
   - razão

## Motivo

Essa estrutura foi adotada porque traduz o teste técnico em linguagem humana sem perder precisão operacional. Ela serve tanto para:

- operadores e gestores públicos
- auditorias e validação institucional
- mantenedores técnicos
- IAs que precisem ampliar ou revisar a suíte

## Contrato mínimo por cenário

Todo cenário deve deixar explícito:

- qual parte do modelo de negócio está sendo validada
- qual estado inicial é assumido
- qual ação concreta é executada
- qual saída observável prova o sucesso ou a falha
- por que esse cenário existe e qual regressão ele impede

## Saídas desejáveis

Sempre que possível, a documentação deve apontar:

- aba de evidência esperada
- evento mínimo de auditoria
- efeito esperado na fila, no cadastro, na `PRE_OS`, na `OS` ou na avaliação
- relação com outros cenários da mesma família

## Referência atual

O documento que serve como referência-base deste padrão é:

- [../PROPOSTA_TESTES_V2_CENARIO_CANONICO.md](../PROPOSTA_TESTES_V2_CENARIO_CANONICO.md)
