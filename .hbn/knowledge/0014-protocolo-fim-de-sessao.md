---
titulo: Protocolo de fim-de-sessão — handoff obrigatório a 50% de contexto ou em transferência de bastão
data: 2026-05-25
autoria: claude-opus-4-7 (Onda 36.1)
aplica-a: Toda IA que opere em sessão longa (Opus, Codex, Gemini, Cursor, qualquer)
revisar-em: 2026-08-25
---

# Protocolo de fim-de-sessão

## Regra

Toda IA que opere em sessão longa **produz handoff de fim-de-sessão em
`.hbn/messages/AAAAMMDD-HHmm-handoff-fim-sessao-<agente>.md`** ao detectar
qualquer gatilho abaixo, ANTES de qualquer outra ação naquele turno.

Sem handoff registrado, a sessão sucessora começa cega — exatamente o gap
vivido na sessão Onda 37 (2026-05-24), onde recuperação dependeu de memória
humana e re-leitura de ~15 documentos.

## Gatilhos (qualquer um dispara)

1. Operador pede: "stop", "fim de sessão", "save state", "vamos pausar".
2. Contagem de turnos > 30 (heurística simples).
3. Token usage estimado > 50% do contexto da IA.
4. Transferência de bastão entre agentes (ex.: Codex → Opus, Opus → Codex).
5. Final natural de onda safe_track após ERP fechado.

## Conteúdo mínimo do handoff (12 itens)

```yaml
---
titulo: Handoff fim-de-sessão <agente> <AAAA-MM-DD HH:MM>
agente: claude-opus-4-7 | codex | gemini | ...
sessao_inicio: AAAA-MM-DD HH:MM
sessao_fim: AAAA-MM-DD HH:MM
gatilho: operador_pediu | turnos_30 | contexto_50 | bastao | erp_fechado
---

## 1. Onda em curso
## 2. Último readback (ID + status)
## 3. Último ERP (ID + outcome)
## 4. Hearbacks pendentes (lista)
## 5. Sinais HBN abertos (🟡 🟠 🔵 sem resposta)
## 6. Próxima ação obrigatória (1 frase verb-imperativo)
## 7. Arquivos no scope ativo (paths)
## 8. Decisões tomadas em chat mas não documentadas em .md (lista)
## 9. Riscos abertos (não fechados pelo rollback_plan)
## 10. Leituras obrigatórias do sucessor (paths em ordem)
## 11. Comando único para validar estado ao retomar
## 12. Sinal 🔵 HBN HANDOFF READY
```

## Aplicação inicial

Esta knowledge nasce na Onda 36.1. **Gate 4 do readback 0095 exige que a
própria sessão Opus que criou esta regra produza o primeiro handoff real
em `.hbn/messages/20260525-XXXX-handoff-fim-sessao-opus.md` antes de
fechar o ERP 0095.** Auto-aplicação imediata.

## Não-gatilhos (não disparar handoff)

- Chat curto (< 5 turnos) puramente conversacional.
- Operador apenas confirmando comando sem nova decisão.
- Sessão em modo `audit-only` sem produção de readback novo.

## Como o sucessor consome o handoff

Mensagem zero do chat sucessor deve ser:

```
Leia .hbn/messages/<arquivo-handoff-mais-recente-do-meu-agente>.md
e siga o item "Próxima ação obrigatória" + "Leituras obrigatórias".
Não tome nenhuma outra ação antes de confirmar item por item.
```

## Como evoluir

- Adicionar novo gatilho: ADR + atualização desta knowledge + bump no
  changelog.
- Mudar conteúdo mínimo: cuidado com retrocompatibilidade — handoffs
  antigos devem permanecer parseáveis pelo schema atual.
- Schema formal (`.hbn/schemas/handoff.schema.json`) fica como débito
  técnico para onda futura quando volume de handoffs justificar.

## Referências

- `auditoria/03_ondas/onda_36_1_knowledge_fim_sessao/36_1_TECNICO.md`
- `.hbn/messages/` (todos handoffs de sessão produzidos)
- `/Users/macbookpro/Projetos/Credenciamento/.hbn/knowledge/0013-contratos-executaveis.md`
- PROMPT_ARQUITETO_USEHBN_AUTONOMO.md §7 (origem do conceito)
