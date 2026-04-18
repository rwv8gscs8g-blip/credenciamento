# Handoff V12.0.0189 - Validacao do Opus e Plano de Execucao

Data: 2026-04-17
Projeto: `/Users/macbookpro/Projetos/Credenciamento`
Branch atual: `codex/v180-stable-reset`
Versao atual do codigo: `V12.0.0196`
Status: Fase 1 validada no Excel; Fase 2 validada funcionalmente; Fase 3 iniciada com atomicidade minima em recusa/avanco

## 1. Objetivo deste handoff

Este documento consolida:

1. a validacao tecnica da auditoria externa produzida em `auditoria/V12.0.0189_SUBSTITUTIVA/`
2. os pontos em que a auditoria do Opus esta correta
3. os pontos em que ela precisa de refinamento antes da implementacao
4. o plano incremental aprovado para as proximas versoes
5. instrucoes suficientemente detalhadas para uma IA menos capaz executar microevolucoes sem perder contexto

Este handoff deve ser lido antes de qualquer alteracao na V12.0.0190+.

---

## 2. Veredito sobre a auditoria do Opus

### 2.1 O que esta confirmado

Os seguintes pontos da auditoria externa batem com o codigo real:

1. a `V2` esta falhando hoje no bootstrap do cenario deterministico, nao no fluxo de regra de negocio em si
2. ha desalinhamento entre a forma como a `V1` mede/conta dados e a forma como a `V2` mede/conta dados
3. a `V1` usa estrategia mais robusta para contagem por aba:
   - `BA_CountLinhas` usa `CountA` na coluna-chave da aba
   - ver `vba_export/Teste_Bateria_Oficial.bas`
4. a `V2` ainda usa contagem aritmetica baseada em `UltimaLinhaAba`
   - ver `vba_export/Teste_V2_Engine.bas`
5. a `V2` herdou um `ClearSheet` estruturalmente parecido com a `V1`, mas a combinacao atual de:
   - amplitude de limpeza limitada por coluna A / linha 1
   - contagem por `UltimaLinhaAba`
   - validacao estrutural mais estrita
   aumenta o risco de falso positivo
6. as lacunas `UI -> servico` continuam reais:
   - `MIG_001` em `Svc_PreOS`
   - `MIG_002` em `Svc_OS`
   - `MIG_003` em `Svc_Avaliacao`

### 2.2 O que esta correto, mas precisa de ajuste de implementacao

O Opus acertou a direcao do conserto, mas alguns trechos precisam ser refinados antes de virar codigo:

1. `TV2_CountRows` nao deve usar sempre `LINHA_DADOS`
   - para `EMPRESAS`, a primeira linha de dados depende de `PrimeiraLinhaDadosEmpresas()`
   - a implementacao correta deve reutilizar `TV2_PrimeiraLinhaDados(nomeAba)`
2. `TV2_NextDataRow` tambem nao deve fixar `LINHA_DADOS`
   - deve respeitar a primeira linha real da aba
3. o mapa de `TV2_ColunaChave` nao deve cobrir so 5 abas
   - idealmente deve cobrir ao menos:
     - `SHEET_EMPRESAS`
     - `SHEET_EMPRESAS_INATIVAS`
     - `SHEET_ENTIDADE`
     - `SHEET_ENTIDADE_INATIVOS`
     - `SHEET_CREDENCIADOS`
     - `SHEET_PREOS`
     - `SHEET_CAD_OS`
     - `SHEET_AUDIT`
4. o problema nao esta provado como sendo "On Error Resume Next global"
   - o `On Error Resume Next` em `TV2_ClearSheet` existe apenas no bloco de delecao de `ListObjects`
   - o defeito principal hoje parece ser mais de semantica de medicao/limpeza do que de mascaramento geral de erro
5. `TV2_ClearSheet` deve endurecer a amplitude de limpeza
   - mas sem quebrar abas protegidas, tabelas e contadores
   - a mudanca deve ser conservadora e compatível com o padrao da `V1`

### 2.3 O que ainda nao esta provado

Estes pontos nao devem ser tratados como fato consumado sem homologacao:

1. que o resíduo atual seja 100% falso positivo de contagem
2. que nao exista sobra real nas abas operacionais do workbook
3. que `UsedRange` sozinho resolva todos os residuos
4. que a correcao B1+B2 baste para deixar toda a `V2` aprovada

Em outras palavras:

- B1+B2 sao o primeiro passo correto
- mas a homologacao no Excel continua obrigatoria

---

## 3. Diagnostico tecnico aprofundado

### 3.1 Problema central da V2 na 0189

A `V2` hoje mistura dois contratos diferentes:

1. `Reset/limpeza` por amplitude calculada com base em coluna A / linha 1
2. `Validacao estrutural` que assume contagem precisa de registros operacionais

Isso e fragil porque:

1. a coluna A nem sempre e a melhor coluna semantica da aba
2. a primeira linha de dados nao e uniforme entre todas as abas
3. a `V1` ja resolveu essa medicao de forma melhor e mais semantica

### 3.2 Porque a V1 e referencia melhor neste ponto

A `V1` tem tres caracteristicas corretas que a `V2` deve absorver:

1. define `coluna-chave` por aba
2. define `primeira linha de dados` por aba
3. conta registros reais por `CountA`, e nao por diferenca aritmetica de linha

Isso esta em:

- `vba_export/Teste_Bateria_Oficial.bas`
- `BA_ColunaChave`
- `BA_PrimeiraLinhaDados`
- `BA_CountLinhas`

### 3.3 Diagnostico tecnico mais provavel

Probabilidade alta:

1. `TV2_CountRows` esta superestimando linhas em abas operacionais
2. `TV2_ClearSheet` pode nao estar cobrindo toda a area operacional efetivamente usada
3. a combinacao das duas coisas produz o fatal `EMPRESAS=4 | ENTIDADE=4 | CREDENCIADOS=4 | PRE_OS=1 | CAD_OS=1`

### 3.4 Diagnostico tecnico menos provavel, mas possivel

1. existir sobra real na planilha, especialmente se a ultima execucao foi interrompida
2. haver algum `ListObject` ou resíduo fora da area que a `V2` hoje limpa
3. protecao de aba impedir limpeza completa em uma das planilhas

### 3.5 Conclusao tecnica operacional

A proxima versao nao deve atacar ainda:

- UI
- atomicidade profunda
- shadow mode
- novos edge cases

Antes disso, ela deve destravar a `V2` com semantica de reset/contagem correta.

---

## 4. Plano de execucao recomendado

## Fase 0 - Sem desenvolvimento ainda

Objetivo:

- aprovar este plano
- nao alterar regras de negocio antes de estabilizar a baseline da V2

Saida esperada:

- plano aprovado pelo revisor humano

## Fase 1 - V12.0.0190

Objetivo:

- destravar a baseline deterministica da V2

Escopo:

1. reimplementar `TV2_CountRows`
2. criar `TV2_ColunaChave`
3. reimplementar `TV2_NextDataRow`
4. endurecer `TV2_ClearSheet`
5. adicionar assert pos-reset em `TV2_ResetBaseOperacional`
6. atualizar:
   - `App_Release.bas`
   - `obsidian-vault/ai/GOVERNANCA.md`
   - `obsidian-vault/ai/ESTADO-ATUAL.md`
   - `obsidian-vault/releases/V12.0.0190.md`

Critério de aceite:

1. `CT2_ExecutarSmokeRapido` nao falha com fatal estrutural
2. `CT2_ExecutarSmokeAssistido` nao falha com fatal estrutural
3. `CT2_ExecutarStress` nao falha com fatal estrutural
4. `CT2_ExecutarStressAssistido` nao falha com fatal estrutural

Observacao:

- nesta fase, falha semantica de negocio ainda pode existir
- o que precisa sumir e o fatal de baseline

### Status da Fase 1

Implementado na `V12.0.0190`:

1. `TV2_CountRows` migrou para `CountA` por coluna-chave semantica
2. `TV2_ColunaChave` foi criada para alinhar medicao entre abas operacionais
3. `TV2_NextDataRow` passou a consultar a coluna-chave real da aba
4. `TV2_ClearSheet` passou a expandir a area de limpeza por coluna A, coluna-chave e `UsedRange`
5. `TV2_ResetBaseOperacional` passou a falhar cedo se alguma aba operacional nao zerar

Pendente:

1. compilar a `V12.0.0190` no Excel
2. executar os quatro fluxos `CT2_*`
3. confirmar que o fatal estrutural desapareceu

## Fase 2 - V12.0.0191

Objetivo:

- migrar regras `UI -> servico`

Escopo:

1. `MIG_001` em `Svc_PreOS`
2. `MIG_002` em `Svc_OS`
3. `MIG_003` em `Svc_Avaliacao`
4. converter `MIG_*` da V2 de manual para assertivo

Critério de aceite:

1. entradas invalidas falham no servico
2. UI continua amigavel
3. V2 passa a registrar `PASS/FAIL` assertivo nesses cenarios

### Status da Fase 2

Implementado na `V12.0.0191`:

1. `Svc_PreOS.EmitirPreOS` passou a rejeitar `ENT_ID` inexistente/inativa
2. `Svc_PreOS.EmitirPreOS` passou a rejeitar `QT_ESTIMADA <= 0`
3. `Svc_OS.EmitirOS` passou a rejeitar `DT_PREV_TERMINO < Date`
4. `Svc_Avaliacao.AvaliarOS` passou a rejeitar `QtExecutada <= 0`
5. `Svc_Avaliacao.AvaliarOS` passou a exigir `justifDiv` quando houver divergencia entre executado e orcado
6. `Teste_V2_Roteiros.TV2_RunSmoke` converteu `MIG_001`, `MIG_002` e `MIG_003` em cenarios automatizados
7. `Teste_V2_Engine` atualizou catalogo e roteiro assistido para refletir a nova automacao

Pendente:

1. compilar a `V12.0.0191` no Excel
2. validar `CT2_ExecutarSmokeRapido` e `CT2_ExecutarSmokeAssistido` com `MIG_*` verdes
3. validar `CT2_ExecutarStress` e `CT2_ExecutarStressAssistido` para confirmar que a migracao nao abriu regressao lateral

## Hotfix estrutural - V12.0.0192

Objetivo:

- evitar restauracao silenciosa de linhas antigas ou conflitantes em `ENTIDADE_INATIVOS` e `EMPRESAS_INATIVAS`

Diagnostico:

1. o problema observado em entidade nao apontou principalmente para formatacao de ID
2. a fragilidade estava em duas escolhas operacionais:
   - inativacao acumulando duplicidades antigas em `*_INATIVOS`
   - reativacao escolhendo a linha mais antiga, nao a mais recente
3. em base historica com resíduo, isso pode restaurar uma linha semanticamente errada

Implementado na `V12.0.0192`:

1. inativacao de entidade remove duplicidades antigas da mesma chave antes de copiar a linha atual
2. inativacao de empresa recebe o mesmo endurecimento
3. listas de inativos passam a preferir a linha mais recente por chave

## Fase 3 - V12.0.0195

Objetivo:

- reduzir o principal risco confirmado de mutacao parcial entre abas

Escopo implementado na `V12.0.0195`:

1. novo `Svc_Transacao.bas` para registrar writes e executar rollback minimo
2. `Repo_Credenciamento.IncrementarRecusa` agora faz rollback se a segunda escrita falhar
3. `Svc_Rodizio.AvancarFila` agora restaura a fila se a recusa falhar apos o movimento
4. `Audit_Log.RegistrarEvento` passou a preparar/restaurar `AUDIT_LOG`
5. `Util_Planilha.ProximoId` ganhou cleanup explicito
6. `Teste_V2_Roteiros.TV2_RunSmoke` ganhou `ATM_001`
7. `Svc_Transacao` passou a registrar abertura, commit e rollback em `AUDIT_LOG`
8. `Teste_V2_Engine` passou a gerar snapshot unico das 5 abas operacionais antes do primeiro reset V2 da execucao

Pendente:

1. compilar a `V12.0.0195` no Excel
2. validar `ATM_001` no smoke rapido/assistido
3. validar a criacao dos snapshots `SNAPV2_*`
4. ampliar atomicidade para `PreOS`, `OS` e `Avaliacao` em release seguinte
5. reativacao passa a usar a linha mais recente por chave
6. reativacao bloqueia quando houver conflito semantico real entre linhas da mesma chave

Critério de aceite:

1. inativar e reativar entidade em base limpa preserva a linha correta
2. inativar e reativar empresa em base limpa preserva a linha correta
3. base com duplicidade historica nao restaura linha antiga silenciosamente
4. conflito real em `*_INATIVOS` bloqueia com mensagem de integridade

## Fase 3 - V12.0.0192+

Objetivo:

- aumentar seguranca e profundidade de cobertura

Escopo:

1. atomicidade
2. edge cases
3. shadow mode V1 x V2
4. roteiro assistido ampliado
5. stress real

---

## 5. Ordem exata de alteracao na Fase 1

Uma IA menor deve seguir esta ordem sem improvisar.

### Passo 1

Ler:

- `auditoria/V12.0.0189_SUBSTITUTIVA/07_PLANO_BATERIAS_COMPLEMENTARES.md`
- `auditoria/V12.0.0189_SUBSTITUTIVA/09_BACKLOG_PRIORIZADO.md`
- este handoff

### Passo 2

Abrir:

- `vba_export/Teste_V2_Engine.bas`

### Passo 3

Alterar somente:

1. `TV2_CountRows`
2. `TV2_NextDataRow`
3. `TV2_ClearSheet`
4. `TV2_ResetBaseOperacional`

### Passo 4

Nao alterar:

1. `Svc_Rodizio`
2. `Menu_Principal.frm`
3. `Teste_V2_Roteiros.bas`

Exceto se for estritamente necessario para compilar.

### Passo 5

Atualizar versao e documentacao de release.

### Passo 6

Publicar `vba_import/` a partir de `vba_export/`.

### Passo 7

Pedir validacao humana no Excel.

---

## 6. Regras inviolaveis para a proxima IA

1. `vba_export/` continua sendo a fonte de verdade
2. nao editar `vba_import/` manualmente
3. nao alterar contrato da fila
4. nao mudar regras de negocio enquanto a baseline da V2 ainda falha estruturalmente
5. nao aposentar a V1
6. nao tratar a auditoria do Opus como verdade absoluta
7. registrar sempre:
   - versao
   - impacto
   - criterio de aceite
   - risco residual

---

## 7. Handoff para IA menos capaz

Se a proxima IA tiver contexto limitado, entregue exatamente estes arquivos:

1. `auditoria/V12.0.0189_SUBSTITUTIVA/00_INDEX.md`
2. `auditoria/V12.0.0189_SUBSTITUTIVA/07_PLANO_BATERIAS_COMPLEMENTARES.md`
3. `auditoria/V12.0.0189_SUBSTITUTIVA/09_BACKLOG_PRIORIZADO.md`
4. `auditoria/V12.0.0189_SUBSTITUTIVA/10_PROMPT_CODEX_PROXIMA_FASE.md`
5. `obsidian-vault/ai/handoffs/Handoff-V12-0189-Opus-Validacao-E-Plano.md`

E dar a seguinte instrução:

"Implemente apenas a Fase 1 da V12.0.0190. Nao mexa em regra de negocio. Nao mexa em UI. Corrija apenas a semantica de reset/contagem da V2 e atualize a release/documentacao."

---

## 8. O que deve ser pedido ao humano apos a Fase 1

O operador deve:

1. importar os modulos alterados
2. compilar o projeto VBA
3. rodar:
   - `CT2_ExecutarSmokeRapido`
   - `CT2_ExecutarSmokeAssistido`
   - `CT2_ExecutarStress`
   - `CT2_ExecutarStressAssistido`
4. enviar:
   - CSVs de falha, se existirem
   - observacao visual da navegacao assistida

Se nao houver fatal estrutural, a Fase 2 pode comecar.

---

## 9. Pendencias abertas apos a aprovacao deste plano

1. confirmar no Excel se o fatal estrutural some com a correcao de baseline
2. medir se o problema era:
   - contagem
   - limpeza
   - ambas
3. migrar `MIG_001`, `MIG_002`, `MIG_003`
4. decidir se a V2 pode entrar em shadow mode formal com a V1

---

## 10. Resumo executivo para quem assumir o bastao

O proximo desenvolvimento nao deve ser "mexer em tudo".
O proximo desenvolvimento deve ser:

1. corrigir a medicao e o reset da V2
2. validar no Excel
3. so depois migrar regras da interface para os servicos

A auditoria externa do Opus foi util e, no essencial, correta na direcao.
Mas a implementacao deve seguir este handoff, nao copiar literalmente os snippets sem ajustar `TV2_PrimeiraLinhaDados` e o mapa completo de colunas-chave.
