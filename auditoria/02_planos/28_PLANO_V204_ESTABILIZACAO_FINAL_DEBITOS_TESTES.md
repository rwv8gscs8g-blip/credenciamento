---
titulo: 28 - Plano V204 Estabilizacao Final Debitos e Testes
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-04
---

# 28. Plano V204 - Estabilizacao Final, Debitos e Testes

Este plano abre a linha `V12.0.0204` como sucessora da `V12.0.0203-rc4`.
A V203 rc4 sera usada para testes manuais formais e vitrine publica de
documentacao/auditabilidade. A V204 deve ser a candidata a producao.

## 1. Premissa

V203 rc4 esta verde no Quinteto (`VR_20260504_171048`), mas nao deve ir
para producao enquanto existirem debitos tecnicos conhecidos sem decisao
formal.

## 2. Debitos iniciais da V204

| ID | Tema | Severidade inicial | Motivo |
|---|---|---|---|
| `INT-CAD-OS-REF-ORFA` | referencias orfas em `CAD_OS` | P1 | integridade de dados |
| `DT-FRENTE1-GRAVARSTATUSEMPRESA-SILENT` | falha silenciosa em status | P1 | mascara erro operacional |
| `DT-FRENTE1-REATIV-NOOP-ATIVA` | reativar empresa ativa | P2 | comportamento pouco explicito |
| `DT-FRENTE1-BACKFILL-AUDIT` | migracao auditavel de historico | P1 | bases antigas podem ter campo vazio |
| `DT-FRENTE1-CONTARSTRIKES-ERRO-MUDO` | contador pode falhar sem origem | P1 | diagnostico insuficiente |
| `DT-FRENTE1-FORMS-BYPASS-REATIV` | forms podem burlar service | P1 | regra pode depender da entrada |
| `DT-FRENTE1-REENTRADA-UI` | duplo clique/reentrada | P2 | risco de duplicidade |
| `DT-FRENTE1-MENSAGENS-VAGAS` | mensagens sem origem | P2 | suporte e auditoria piores |

## 3. Esteira proposta

| Onda | Objetivo | Gate minimo |
|---|---|---|
| V204-01 | auditoria cruzada e triagem P0/P1/P2 | docs 64/65 recebidos |
| V204-02 | integridade de dados e orfaos `CAD_OS` | IntegridadeBase ampliada |
| V204-03 | endurecer `GravarStatusEmpresa` e logs | V2 Canonica verde |
| V204-04 | reativacao: no-op, forms e backfill | E2E Strikes verde |
| V204-05 | reentrada UI e confirmacoes destrutivas | testes assistidos |
| V204-06 | mensagens de erro e observabilidade | Quinteto verde |
| V204-07 | matriz combinatoria e stress | nova bateria V204 verde |
| V204-08 | fechamento candidato a producao | auditoria cruzada final |

## 4. Evolucao das baterias

| Bateria | Evolucao V204 |
|---|---|
| V1 rapida | manter como regressao historica |
| V2 Smoke | adicionar sanity de build/importador |
| V2 Canonica | expandir cenarios de forms e backfill |
| E2E Strikes | cobrir datas vazias, iguais e invalidas |
| IntegridadeBase | detectar orfaos, duplicidades e colunas desalinhadas |
| Manual assistido | roteiros UI com prints e criterio de aceite |
| Combinatoria | matriz status x data x origem x base |

## 5. Criterios para V204 final

1. Zero P0 aberto.
2. Zero P1 sem decisao humana formal.
3. Quinteto verde.
4. Bateria combinatoria V204 verde.
5. Auditoria cruzada Opus e Antigravity sem bloqueio.
6. Manual testado por operador.
7. Documentacao publica limpa no GitHub.
8. Documentacao interna preservada localmente.

## 6. Material que deve alimentar a V204

1. `auditoria/00_status/64_AUDITORIA_OPUS_V203_RC4_E_V204_2026_05_04.md`
2. `auditoria/00_status/65_AUDITORIA_ANTIGRAVITY_V203_RC4_E_V204_2026_05_04.md`
3. `auditoria/00_status/66_SINTESE_AUDITORIA_CRUZADA_V203_RC4_E_ABERTURA_V204_2026_05_04.md`
4. `docs/reference/testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V203.md`
5. `docs/reference/testes/05_ROTEIRO_TESTE_MANUAL_V203_RC4.md`

## 7. Regra de governanca

Nenhum debito conhecido deve ser escondido por sucesso de bateria. Bateria
verde prova ausencia de regressao nos cenarios executados; nao prova
ausencia de risco fora da cobertura. A V204 deve converter cada risco
conhecido em teste, correcao, ou decisao formal de aceite.
