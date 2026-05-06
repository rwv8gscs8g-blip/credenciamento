---
titulo: Funcionalidade nova exige teste correspondente
diataxis: reference
hbn-track: safe_track
hbn-status: knowledge
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-06
autoria: decisao operacional de Luis Mauricio Junqueira Zanin, registrada por Codex CLI apos MICRO36 verde
aplica-a: toda IA e todo contribuidor humano que implemente ou proponha mudanca funcional no Credenciamento
revisar-em: fechamento publico da V12.0.0204
status: vigente
---

# Funcionalidade Nova Exige Teste Correspondente

## Regra

Toda funcionalidade nova deve ser entregue com um teste que consiga
validar o comportamento criado. A regra vale para:

1. regra de negocio nova;
2. fluxo novo ou alterado de UI;
3. comportamento novo de `Svc_*`, `Repo_*`, `Util_*` ou infraestrutura;
4. correcoes que mudem contrato observavel;
5. novo debito tecnico fechado por comportamento verificavel.

## Padrao de entrega

O teste deve entrar no mesmo microdelta da funcionalidade. Se o teste
ficar para depois, a entrega fica incompleta e deve ser marcada como
debito tecnico explicito, com justificativa e prazo.

Preferencia de cobertura:

1. automatizado em V2 Smoke, V2 Canonica, E2E ou IntegridadeBase;
2. automatizado em V1 quando a regra ja pertencer a Bateria Oficial;
3. assistido/manual quando a validacao depender de interacao visual ou
   limitacao do VBE/Excel.

Quando for assistido/manual, a IA deve registrar:

1. cenario em catalogo ou roteiro de testes;
2. procedimento de execucao humano;
3. evidencia esperada;
4. criterio objetivo de aprovacao/reprovacao.

## Como aplicar

Antes de propor um microdelta, responder:

1. Qual comportamento novo sera criado?
2. Qual cenario valida esse comportamento?
3. Em qual suite ele entra?
4. O contador esperado do Quinteto muda?
5. A documentacao de procedimento foi atualizada?

Exemplo aprovado: `MICRO36` criou a rejeicao de transacao aninhada em
`Svc_Transacao` e, no mesmo microdelta, adicionou `ATM_002` ao Smoke.
O gate esperado mudou de `V2_Smoke=28/0` para `V2_Smoke=29/0`.

## Como verificar

Para cada arquivo de codigo alterado, procurar no diff do mesmo commit:

1. alteracao de teste automatizado ou roteiro assistido correspondente;
2. ajuste de catalogo/roteiro quando o contador ou escopo de teste mudou;
3. atualizacao do procedimento de importacao com gate esperado;
4. registro em `CHANGELOG.md` quando o comportamento for publico.

Se nao houver teste correspondente, a IA deve bloquear a propria entrega
com `HBN NEEDS HUMAN DECISION` ou documentar o debito tecnico antes de
seguir.
