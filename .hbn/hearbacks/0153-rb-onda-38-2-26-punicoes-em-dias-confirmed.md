---
titulo: Hearback 0153 — punicoes em dias e relatorios transparentes
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-06
---

# Hearback 0153 — confirmado

Mauricio confirmou em chat: `aprovado, pode seguir 0153`.

Escopo aprovado:

- Padronizar suspensoes em dias para strike/nota, recusa, expiracao de prazo e suspensao manual.
- Remover fallback silencioso para meses.
- Manter `Mod_Types.bas` intocado.
- Corrigir interface, persistencia, migracao idempotente e testes.
- Incluir nos relatorios informacao clara de empresas suspensas, dias restantes, data de retorno e itens/servicos com empresas ativas/aptas ou suspensas.

Condicao de aceite: a onda nao pode ser aprovada se os relatorios ocultarem
`STATUS_GLOBAL`, dias restantes, retorno previsto ou se algum item/servico ficar
sem alerta quando nao houver empresa apta para o rodizio.
