---
titulo: Status V204 Publicacao
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-11
---

# Status V204 Publicacao — 2026-05-11

## Decisao

V12.0.0204 esta promovida como release oficial publica. A vitrine humana foi
atualizada em MICRO56 para permitir teste externo reprodutivel.

## Ancora validada

| Campo | Valor |
|---|---|
| Build final | `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2` |
| Compile VBE | OK, informado pelo operador |
| Smoke final | `TV2_20260511_131824` — OK=34, FALHA=0, MANUAL=4 |
| Testes manuais finais | OK, informado pelo operador |
| Gate final | `VR_20260511_154433` — APROVADO |
| Gate adicional pos-App_Release | `VR_20260511_175849` — APROVADO |
| Sintaxe final | `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0` |

## Escopo absorvido

- MICRO31 a MICRO48: hardening funcional, testes e rastreabilidade V204.
- MICRO49/MD-24.4: reprovado e revertido formalmente para MICRO48.
- MICRO50: rc1 a partir da base limpa.
- MICRO51/MICRO52: higiene e auditoria cruzada sem P0/P1.
- MICRO53-fix2: correcao do contrato de Limpar Base para limpar `CAD_SERV`
  preservando `ATIVIDADES` e recriando baseline canonica no Smoke.
- MICRO54: publicacao documental e promocao de metadados para V12.0.0204.
- MICRO55: `App_Release` final alinhado a V12.0.0204 VALIDADO/OFICIAL.
- MICRO56: pacote humano de teste externo, com liberacao de macros Windows,
  how-to do Sexteto, roteiro manual V204 e matriz de cobertura de regras V204.

## Debitos aceitos para V12.0.0205

| ID | Debito | Destino |
|---|---|---|
| D-V205-TAXONOMIA-TESTES | Renomear "Sexteto" para nomenclatura profissional de teste de software | Auditoria cruzada V205 |
| D-V205-MD24-4 | Retomar documentacao dos side-effects de `SelecionarEmpresa` sem reaproveitar MICRO49 | Microdelta limpo V205 |
| D-STRICT-G1-G2-G5 | Lapidar falhas historicas nao criticas do `glasswing-checks.sh --strict` | Onda 26 / V205 |
| D-MICRO50-CSV-FILENAME | Prefixo historico `V12_0_0203` no CSV dentro da pasta correta V12.0.0204 | Higiene documental V205 |

## Publico vs interno

Publico:

- README, CHANGELOG, release note V12.0.0204, STATUS-OFICIAL, matriz de testes
  e CSVs de evidencia V12.0.0204.
- guias humanos V204: liberar macros no Windows, rodar Sexteto e roteiro manual
  de homologacao.

Interno/auditavel:

- readbacks, ERPs, relay HBN, RCA MICRO49, manifestos V3 e detalhes de
  execucao incremental.

## Proxima acao

Publicar a vitrine MICRO56 no GitHub/main e iniciar a preparacao da auditoria
cruzada Opus/Antigravity para a V12.0.0205.
