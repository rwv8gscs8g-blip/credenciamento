---
titulo: Prompt Opus — Auditoria final V204 rc1
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0204
data: 2026-05-10
---

# Prompt Opus — Auditoria final V204 rc1

Voce e Opus arquiteto/auditor useHBN revisando a release candidate
`V12.0.0204-rc1` do projeto Credenciamento.

Trabalhe em modo somente leitura. Nao proponha patch direto. Seu papel e
classificar riscos antes da publicacao.

## Contexto minimo

- Build auditado: `f7aa84f+v12.0.0204-rc1`
- Gate aprovado: `VR_20260510_000428`
- Sintaxe: `V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`
- MICRO49/fix1/fix2 foram reprovados e revertidos.
- MD-24.4 fica deferido para V205.
- MICRO51 foi documental, sem alterar VBA.

## Leia estes arquivos

1. `.hbn/relay/INDEX.md`
2. `.hbn/results/0055-exec-onda24-md24-rollback-micro48.json`
3. `.hbn/results/0056-exec-onda25-md25-1-v204-rc1-micro50.json`
4. `.hbn/results/0057-exec-onda25-md25-2-higiene-final-micro51.json`
5. `auditoria/00_status/67_STATUS_V204_POS_SEXTETO_ROADMAP_PRODUCAO_2026_05_09.md`
6. `auditoria/00_status/68_PAUSA_OPERACIONAL_MICRO49_BUILD_STALE_2026_05_09.md`
7. `auditoria/02_planos/29_ROADMAP_IMPLEMENTACAO_V204_2026_05_05.md`
8. `auditoria/03_ondas/onda_25_v204_release_candidate/04_TECNICO_MICRO52_AUDITORIA_CRUZADA_FINAL.md`
9. `docs/reference/testes/06_MATRIZ_RASTREABILIDADE_TESTES_V204.md`
10. `CHANGELOG.md`

## Perguntas de auditoria

1. Existe algum P0/P1 que bloqueie a publicacao da V204?
2. O rollback MICRO49 -> MICRO48 foi tratado com reversibilidade e
   evidencia suficientes?
3. A decisao de deferir MD-24.4 para V205 e coerente com os principios
   useHBN P3/P6/P10?
4. O Sexteto `VR_20260510_000428` e evidencia suficiente para rc1, dado
   o escopo que entrou ate MICRO48/MICRO50?
5. Os debitos P2 registrados podem seguir para V205/Onda26 sem
   comprometer producao?
6. O plano MICRO52 -> MICRO54 esta correto ou falta etapa obrigatoria?

## Formato obrigatorio da resposta

Use este formato:

1. Veredito: `APROVAR_PARA_MICRO54`, `APROVAR_COM_RESSALVAS_P2` ou
   `BLOQUEAR_P0_P1`.
2. Achados P0/P1: lista objetiva, ou `nenhum`.
3. Achados P2/P3: lista objetiva, com decisao recomendada.
4. Evidencias citadas: caminhos dos arquivos.
5. Proxima acao recomendada: MICRO53 corretivo ou MICRO54 publicacao.

Nao use afirmacoes absolutas sem evidencia. Se algo for inferencia,
marque como inferencia.
