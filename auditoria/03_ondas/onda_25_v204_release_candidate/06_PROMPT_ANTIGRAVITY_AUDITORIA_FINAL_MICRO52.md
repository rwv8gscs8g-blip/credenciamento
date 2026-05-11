---
titulo: Prompt Antigravity — Auditoria adversarial final V204 rc1
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0204
data: 2026-05-10
---

# Prompt Antigravity — Auditoria adversarial final V204 rc1

Voce e Antigravity em modo auditoria adversarial final para a release
candidate `V12.0.0204-rc1` do projeto Credenciamento.

Trabalhe em modo somente leitura. Nao edite arquivos. Procure
bloqueadores reais de release: regressao funcional, evidencia
insuficiente, risco de import/compile, divergencia `src/vba` vs
`local-ai/vba_import`, ou claim documental sem base.

## Contexto minimo

- Build auditado: `f7aa84f+v12.0.0204-rc1`
- Gate aprovado: `VR_20260510_000428`
- Sintaxe: `V1=171/0+V2_Smoke=33/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`
- CSV: `auditoria/evidencias/V12.0.0204/ValidacaoReleaseSexteto_V12_0_0203_VR_20260510_000428.csv`
- MICRO49/fix1/fix2 foram reprovados por compile crash/build stale e
  revertidos formalmente.
- MICRO50 e MICRO51 nao devem carregar MD-24.4.

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
11. `auditoria/evidencias/V12.0.0204/ValidacaoReleaseSexteto_V12_0_0203_VR_20260510_000428.csv`

## Ataques esperados

1. Verifique se algum arquivo ou doc ainda trata MICRO49/fix como
   aprovado.
2. Verifique se o build rc1 pode estar carregando mudanca de MD-24.4 por
   acidente documental ou de espelho.
3. Verifique se o CSV V204 e suficiente apesar do filename historico
   `V12_0_0203`.
4. Verifique se ha P0/P1 aberto em status, roadmap, changelog ou matriz
   que ainda bloqueie release.
5. Verifique se G7/G8 aparecem como requisito satisfeito nos registros
   corretos.
6. Verifique se a promocao para tag/release exige novo Excel gate ou se
   `VR_20260510_000428` basta.

## Formato obrigatorio da resposta

Use este formato:

1. Veredito: `APROVAR_PARA_MICRO54`, `APROVAR_COM_RESSALVAS_P2` ou
   `BLOQUEAR_P0_P1`.
2. Bloqueadores P0/P1: lista objetiva, ou `nenhum`.
3. Riscos P2/P3: lista objetiva, com destino sugerido.
4. Evidencias: caminhos e IDs de validacao.
5. Teste/gate adicional exigido: `nenhum`, `Sexteto`, ou descricao
   precisa.

Nao aceite como aprovado algo que dependa de build anterior. Se achar
que uma evidencia pertence a MICRO48 e nao a rc1, marque como bloqueio.
