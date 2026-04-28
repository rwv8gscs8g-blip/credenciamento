---
titulo: Regras V203 Inegociaveis (versao auditavel publica)
data: 2026-04-28
autoria: consolidacao da auditoria/40 secao 6, ratificada por Mauricio em 2026-04-28
aplica-a: linha V12.0.0203
status: vigente
fonte-canonica: este arquivo (publico) + .hbn/knowledge/0001-regras-v203-inegociaveis.md (operacional)
---

# Regras V203 Inegociaveis

> Constituicao operacional da V12.0.0203. Mudancas exigem release oficial
> com migration plan. Espelho operacional para IAs em
> [`.hbn/knowledge/0001-regras-v203-inegociaveis.md`](../../.hbn/knowledge/0001-regras-v203-inegociaveis.md).

## As 10 regras

1. **Bastao de implementacao** — definido por release. Quem nao tem bastao
   audita, propoe, mas nao edita codigo.
2. **Regra de Ouro do pacote** — tudo importavel mora em `vba_import/`,
   nas pastas com prefixo alfabetico, conforme manifesto. Sem excecao.
3. **Heuristica zero na interface** — controles acessados por nome
   canonico hardcoded. Nada de `InStr(Caption)`, `Top`, `Left`,
   `For Each ctl`.
4. **Idempotencia obrigatoria** — em operacoes administrativas
   (Limpa_Base, Reset_CNAE, snapshot, dedup).
5. **AUDIT_LOG cobre toda acao com efeito de estado** — ausencia de
   evento e bug.
6. **Posicao de fila e imutavel sem motivo operacional declarado** —
   recusa, conclusao com avanco. Suspensao nao move posicao.
7. **Empresa nao e penalizada duas vezes** — apos cumprir suspensao,
   volta a posicao original.
8. **Sem novos modulos arquiteturais ate `0203` fechada** — mudanca
   funcional vai num modulo existente, ou e adiada.
9. **`Mod_Types.bas` pode ser tocado APENAS na Onda 9** — com plano
   documentado e aprovado.
10. **Nenhum arquivo importavel fora de `vba_import/`** — sem excecao.

## Auditoria de cumprimento

Detalhes operacionais e procedimentos de verificacao na versao espelho
em `.hbn/knowledge/0001-regras-v203-inegociaveis.md`. Resumo: toda onda
fechada deve responder textualmente as 10 perguntas correspondentes.

## Historico

- **2026-04-28** — versao 1.0, ratificada na Onda 6 (consolidacao
  documental). Origem: `auditoria/40_TRANSICAO_RACIONALIZACAO_E_PROMPT_RETOMADA.md`,
  secao 6.
