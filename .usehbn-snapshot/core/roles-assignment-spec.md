---
titulo: Roles-assignment spec — atribuição de chapéus por onda, checável por máquina
diataxis: reference
status: accepted
temperatura: quente
id-global: 20260610-46
versao: 0.1.0
data: 2026-06-10
autoria: claude-fable-5 (arquiteto useHBN, corrente D)
hearback-status: confirmado por Maurício (readback 0002, 2026-06-10)
relacionado: [ADR-018, ADR-015 (perfis), core/relay-spec.md (STATE), core/cadence-d.md (P1/P2/P4), guards/assert-role-family.sh]
---

# Roles-assignment spec

## §1 Papel = contrato; modelo = quem veste

Papel (implementador, auditor-cruzado, auditor-arquiteto, consolidador,
humano) é um contrato definido em `agents/role-templates.md`. A ATRIBUIÇÃO —
qual modelo veste qual chapéu NESTA onda — é dado vivo e por isso mora no
STATE, nunca em doc estático.

## §2 O campo `atribuicao` do STATE

```yaml
atribuicao:
  chapeu_atual: auditor-arquiteto      # papel da janela dona do bastão AGORA
  implementador: codex                 # apelido de .hbn/models/<apelido>.json
  auditores: [opus-4-8, gemini-3-5]    # apelidos; ≥1 (idealmente 2-3, P2)
  gravada_em: "2026-06-10T12:00:00-03:00"
  hearback_ref: null                   # hearback que cobre exceções, se houver
```

Regras: (a) todo apelido precisa ter perfil em `.hbn/models/`; (b) o papel
atribuído precisa constar em `papeis_aptos` do perfil (ADR-015) — atribuir
fora disso exige `hearback_ref`; (c) `chapeu_atual` é a resposta inequívoca
a "que chapéu esta janela veste?" — quem retoma lê ANTES de escrever
qualquer coisa; (d) mudança de atribuição = atualização do STATE no mesmo
commit do handoff (rito já vigente do relay-spec). O campo foi adotado no
readback 0002; ondas seguintes devem preenchê-lo.

## §3 Invariante anti-groupthink (guard)

`bash guards/assert-role-family.sh <atribuicao.json>` valida:

1. **BLOQUEADOR**: `fornecedor(auditor) == fornecedor(implementador)` para
   qualquer auditor — auditoria cruzada de mesma família é groupthink
   estrutural (Anthropic × OpenAI × Google). Só passa com `hearback_ref`
   explícito cobrindo a exceção.
2. **BLOQUEADOR**: papel atribuído ausente de `papeis_aptos` sem `hearback_ref`.
3. **AVISO** (não bloqueia): auditores todos do mesmo fornecedor entre si;
   implementador e arquiteto da mesma família.

O guard lê os perfis (`fornecedor`, `papeis_aptos`) — nunca uma tabela
paralela, para não criar segunda fonte de verdade.

## §4 Papéis fixos da fase atual (decisão Maurício, corrente D, 2026-06-10)

Opus/Cowork = auditor/validador fixo; janelas Fable não se auditam entre si;
Maurício = gate humano de todo hearback. Registrado aqui como estado, não
como lei eterna — muda por hearback.

## §5 FUTURO (especificado, NÃO construído — decisão expressa)

Wrappers de terminal `fast_track` para papel de leitura/auditoria: um
comando por papel (ex.: `hbn-audit <path>`) que abre sessão JÁ vestindo o
chapéu (read-list do papel, só leitura, sem write). Orquestração por CLI
(atribuir ondas, disparar auditores) é SPEC FUTURA: exige ADR próprio +
hearback; nenhum código deve ser escrito a partir desta seção.
