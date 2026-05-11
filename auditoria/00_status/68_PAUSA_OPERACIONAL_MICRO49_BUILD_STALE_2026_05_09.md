---
titulo: Pausa operacional MICRO49 — compile crash e build stale
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-09
---

# Pausa operacional MICRO49 — compile crash e build stale

## Estado observado

1. MICRO49, MICRO49-fix1 e MICRO49-fix2 importaram com log V3 OK, mas o comando manual `VBE > Depurar > Compilar VBAProject` fechou o Excel.
2. Apos reabertura/recovery, `GetBuildImportado` retornou `f7aa84f+ONDA24.MD24.3-avaliacao-dual-counter`, nao o build esperado `f7aa84f+ONDA24.MD24.4-selecionar-com-efeitos-fix2`.
3. `TV2_RunSmoke False` retornou `OK=33 | FALHA=0 | MANUAL=4`, consistente com o ultimo ponto verde MICRO48/MD24.3, nao com uma absorcao efetiva do MICRO49.
4. A conclusao operacional e que o workbook recuperado nao deve ser tratado como portador do MICRO49-fix2, mesmo que o importador tenha reportado sucesso antes do crash.

## Ultimo ponto verde

| Marco | Build | Gate |
|---|---|---|
| MICRO48 / MD-24.3 | `f7aa84f+ONDA24.MD24.3-avaliacao-dual-counter` | E2E TV2_20260509_172616 + Sexteto VR_20260509_173629 |

## Decisao recomendada

1. Pausar a Onda 24 antes do MICRO50.
2. Nao salvar workbook recuperado como se fosse MICRO49.
3. Abrir nova sessao Codex para RCA curta e sem alteracao de producao ate confirmar a causa do fechamento no compile.
4. Preferir rollback operacional para MICRO48/MD24.3 como base de continuidade.
5. Se a nova sessao insistir em MD-24.4, entregar microdelta cumulativo minimo, com primeiro gate obrigatorio `GetBuildImportado` antes de qualquer teste.

## Ajuste proposto ao protocolo usehbn

Regra candidata para oficializacao na Onda 26 documental:

> Um microdelta so e considerado absorvido pelo workbook quando, apos import e eventual reabertura, `GetBuildImportado` retorna exatamente o build esperado. Se Excel fechar durante compile, qualquer teste subsequente executado em build anterior e evidencia de rollback/recovery, nao aprovacao do microdelta.

## Prompt de retomada para nova sessao Codex

```text
Voce e Codex CLI assumindo uma pausa operacional da Frente 1 Credenciamento V12.0.0204 em /Users/macbookpro/Projetos/Credenciamento.

Primeira linha obrigatoria:
✅ HBN ACTIVE — Codex CLI, Frente 1 Credenciamento, 2026-05-09 (V204 / Onda 24 pausa MICRO49) — PAUSA OPERACIONAL RECEBIDA

Leia antes de qualquer acao:
1. AGENTS.md
2. .hbn/relay/INDEX.md
3. .hbn/knowledge/0001-regras-v203-inegociaveis.md
4. .hbn/knowledge/0002-regra-ouro-vba-import.md
5. .hbn/knowledge/0003-glasswing-style-preventive-security.md
6. .hbn/knowledge/0010-regra-funcionalidade-nova-exige-teste.md
7. .hbn/knowledge/0011-regra-higiene-documental-recorrente.md
8. auditoria/00_status/67_STATUS_V204_POS_SEXTETO_ROADMAP_PRODUCAO_2026_05_09.md
9. auditoria/00_status/68_PAUSA_OPERACIONAL_MICRO49_BUILD_STALE_2026_05_09.md
10. .hbn/results/0051-exec-onda24-md24-3-avaliacao-dual-counter-micro48.json
11. .hbn/results/0052-exec-onda24-md24-4-selecionar-com-efeitos-micro49.json
12. .hbn/results/0053-exec-onda24-md24-4-selecionar-com-efeitos-micro49-fix1.json
13. .hbn/results/0054-exec-onda24-md24-4-selecionar-com-efeitos-micro49-fix2.json

Contexto operacional:
- Ultimo ponto verde confiavel: MICRO48 / MD-24.3, build f7aa84f+ONDA24.MD24.3-avaliacao-dual-counter.
- Gates verdes do MICRO48: E2E TV2_20260509_172616 e Sexteto VR_20260509_173629.
- MICRO49, MICRO49-fix1 e MICRO49-fix2 importaram com log V3 OK, mas o compile manual fechou o Excel.
- Apos recovery, ?GetBuildImportado retornou f7aa84f+ONDA24.MD24.3-avaliacao-dual-counter.
- TV2_RunSmoke False retornou 33/0/4, consistente com MICRO48, nao com absorcao efetiva do MICRO49.

Objetivo da nova sessao:
1. Fazer RCA sem editar codigo inicialmente.
2. Comparar src/vba e local-ai/vba_import para os arquivos dos MICRO49*: Svc_Rodizio.bas, Teste_V2_Engine.bas, Teste_V2_Roteiros.bas, App_Release.bas.
3. Verificar se o pacote MICRO49 introduz algum padrao conhecido de compile crash no VBE, incluindo nome publico novo, assinatura conflitante, formulario/evento residual, line endings, atributo invisivel, referencia quebrada, ou arquivo espelho divergente.
4. Propor uma decisao: rollback formal para MICRO48 e deferir MD-24.4, ou microdelta MICRO49-fix3 cumulativo minimo.
5. Antes de qualquer novo microdelta, registrar readback HBN e pedir hearback.

Constraints:
- Nao avançar MICRO50.
- Nao editar src/vba nem local-ai/vba_import sem readback/hearback.
- src/vba e fonte de verdade; local-ai/vba_import e espelho.
- CRLF preservado.
- Toda funcionalidade nova exige teste novo ou justificativa explicita de nao funcionalidade.
- Se o Excel fechar durante compile, o microdelta e reprovado ate prova contraria; teste em build anterior nao aprova delta.

Output esperado:
- Parecer curto: causa provavel, evidencias, decisao recomendada.
- Se houver patch proposto, entregar plano MICRO49-fix3 ou rollback MICRO48 com manifestos e gates.
- Atualizar relay/results apenas apos decisao.
```
