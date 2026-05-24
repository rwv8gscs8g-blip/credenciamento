---
titulo: Prompt de Consolidação PDF/UI V206 — Codex
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
saida-prevista: auditoria/00_status/97_CONSOLIDACAO_PDF_UI_V206_CODEX.md
---

# Prompt de Consolidação PDF/UI V206 — Codex

Você é Codex consolidando a auditoria cruzada rápida sobre PDFs automáticos,
relatórios e testes por simulação de cliques da V12.0.0206.

## Entradas Obrigatórias

Leia:

- `auditoria/00_status/95_AUDITORIA_PDF_UI_V206_CLAUDE_OPUS.md`
- `auditoria/00_status/96_AUDITORIA_ADVERSARIAL_PDF_UI_V206_GEMINI.md`
- `auditoria/00_status/92_PROMPT_AUDITORIA_PDF_UI_V206_CLAUDE_OPUS.md`
- `auditoria/00_status/93_PROMPT_AUDITORIA_ADVERSARIAL_PDF_UI_V206_GEMINI.md`
- `auditoria/02_planos/32_ROADMAP_V206_CONSOLIDADO.md`
- `auditoria/03_ondas/onda_31_v206_higiene_documental/01_TECNICO_ONDA31_HIGIENE_DOCUMENTAL.md`
- `docs/reference/testes/ESPEC_PDF_AUTOMATICO_V205.md`
- `auditoria/00_status/35_SPEC_DT5_PDFs_V12_0204.md`
- `auditoria/02_planos/25_PLANO_HARDENING_POS_0203.md`

Se os documentos 95/96 ainda não existirem, pare e solicite os pareceres antes
de consolidar.

## Decisão Humana Já Fechada

A estrutura de pastas e nomes abaixo está aprovada:

```text
Documentos_Gerados/
  Pre-OS/
  OS/
  Avaliacoes/
  Relatorios/
  Validacao/
  Testes_UI/<RUN_ID>/
```

```text
<TIPO>_<NUMERO_DOCUMENTO>_CNPJ_<CNPJ_LIMPO>_<AAAAMMDD_HHNNSS>.pdf
```

## Blindagens

- Não alterar RN-01 a RN-17.
- Não alterar contadores do RVS.
- Não incluir teste de PDF nas seis baterias do RVS.
- Não mover nem reorganizar `doc/`.
- Não tocar `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas` ou
  `Svc_PreOS.bas` salvo P0 explícito e hearback humano.
- Não renomear símbolos internos VBA.
- Toda mudança funcional exige teste correspondente.
- Fonte de verdade é `src/vba/`; `local-ai/vba_import/` é espelho.

## Tarefa de Consolidação

Produza uma especificação executável para as ondas 32 a 37, resolvendo
divergências entre Opus e Gemini.

Cadência-alvo aprovada pelo operador:

| Onda | Tema |
|---|---|
| 32 | Auditoria cruzada PDF/UI e especificação executável |
| 33 | Correção dos relatórios `Rel_Emp_Serv` e `Rel_OSEmpresa` |
| 34 | Motor PDF central, pastas, nomeação, fallback e log |
| 35 | Integração PDF em Pré-OS, OS, Avaliação e Relatórios |
| 36 | Bateria isolada UI/PDF com simulação de cliques |
| 37 | Jornada humana V206 + RC/freeze |

## Questões Que a Consolidação Deve Fechar

1. API pública mínima do motor PDF.
2. Padrão final de nomes e sanitização.
3. Como criar subpastas ao lado da planilha.
4. O que fazer quando workbook ainda não foi salvo.
5. Como validar arquivo gerado: existência, tamanho, assinatura `%PDF-` e log.
6. Como tratar erro/fallback sem bloquear emissão da Pré-OS/OS já persistida.
7. Como corrigir os dois relatórios sem reabrir lógica de negócio.
8. Qual teste acompanha cada mudança funcional.
9. Como a implementação deve expor pontos de entrada para simulação de cliques.
10. Quais gates locais e humanos fecham cada onda.

## Saída Esperada

Crie:

```text
auditoria/00_status/97_CONSOLIDACAO_PDF_UI_V206_CODEX.md
```

Com frontmatter:

```yaml
---
titulo: Consolidação PDF/UI V206 — Codex
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---
```

Estrutura mínima:

1. Veredito consolidado.
2. Decisões finais.
3. Arquitetura proposta.
4. Contrato de nomes e pastas.
5. Correção dos dois relatórios.
6. Plano de testes por simulação de cliques.
7. Ondas 32 a 37 com microdeltas e gates.
8. Bloqueios e itens fora de escopo.
9. Próximo readback para implementação.

Não implemente código neste passo. A consolidação deve preparar um ciclo de
implementação direto, curto e auditável.
