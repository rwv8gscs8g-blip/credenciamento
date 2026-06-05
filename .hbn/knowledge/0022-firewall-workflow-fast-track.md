---
titulo: Firewall — orquestração automática/workflows só em fast_track; escrita safe_track é humano-aplicada
data: 2026-06-05
autoria: claude-opus (modo arquiteto, onda 0115/G1); decisão de Mauricio no hearback 0145
aplica-a: toda IA, todo run autônomo, todo workflow/orquestração automática (Dynamic Workflows, scheduled tasks, subagentes, fan-out) operando em qualquer projeto sob o protocolo HBN
revisar-em: 2026-12-05
---

# Firewall — workflows só `fast_track`; escrita `safe_track` é humana

> **Esta é a fonte canônica única da regra.** O PROMPT_ARQUITETO (Trilha G) e o
> levantamento `.hbn/protocol-evolutions/20260601-1048-*.md` (§13) apenas
> apontam para cá. Não duplicar o texto (anti-padrão da cópia divergente).

## A regra

Orquestração automática — Dynamic Workflows, scheduled tasks, fan-out de
subagentes, qualquer run que prossiga sem hearback humano a cada passo — é
permitida no HBN **somente** para trabalho de **leitura, análise, auditoria e
diagnóstico** (`fast_track`, doc-only).

A **escrita `safe_track`** — `src/vba/`, `local-ai/vba_import/`, qualquer
código de domínio, e a **aplicação no Excel** — permanece:

1. **Humano-aplicada**: Mauricio é o ponto de execução (Importador V3, compile,
   TV2, RVS). Nenhum run autônomo aplica nada no workbook.
2. **Hearback-gated**: readback com `human_status: confirmed` antes de qualquer
   escrita, uma onda por vez.
3. **Fora de qualquer run autônomo**: nem como "passo final" de um workflow,
   nem via bypass, nem por exceção de conveniência.

## Por quê

O domínio (VBA num workbook vivo que já corrompeu — V206) torna a escrita
errada **catastrófica e de detecção tardia**. O gate humano é a razão de
existir do protocolo; a autonomia de workflows não pode erodi-lo. Origem:
princípio-firewall do levantamento bastão×Dynamic-Workflows (§0), confirmado
como **princípio permanente** por Mauricio em 2026-06-05 (hearback 0145,
decisão 2 de 4). Motivação declarada: proteger o refatoramento da V12.0.0207
contra regressões e processos descontrolados.

## Consequências práticas

- Piloto G2/EW-3 (auditoria cruzada via workflow Claude-only): **permitido** —
  é leitura/auditoria, doc-only, com cruzada multi-modelo em paralelo como
  controle e critério P9.
- Scheduled task do arquiteto (§5 do prompt mestre): **permitida** — produz
  readback e para; nunca executa sem hearback.
- Workflow que proponha "aplicar o delta automaticamente no Excel" ou commitar
  código de domínio: **violação** — responder com ❌ HBN SECURITY BLOCKED
  SUGGESTION e parar.
- Violação observada por qualquer IA deve ser registrada em
  `.hbn/protocol-evolutions/` como incidente.

## Como verificar

A regra está formalizada e referenciada (deve retornar este arquivo + Trilha G):

```
grep -rl "firewall" /Users/macbookpro/Projetos/Credenciamento/.hbn/knowledge/ /Users/macbookpro/Projetos/PROMPT_ARQUITETO_USEHBN_AUTONOMO.md
```

Decisão de origem (deve conter "FIREWALL EW-1: Confirmar"):

```
grep -o "FIREWALL EW-1[^.]*" /Users/macbookpro/Projetos/Credenciamento/.hbn/hearbacks/0145-consolidacao-evolucoes-backlog.json
```
