---
titulo: Indice da Bateria de Testes
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-11
---

# Indice da Bateria de Testes

Esta área consolida a leitura humana e institucional da bateria de testes.

## Trilha canonica V12.0.0204

- [../../tutorials/GUIA_TESTES_HUMANOS_V204.md](../../tutorials/GUIA_TESTES_HUMANOS_V204.md)
- [../../how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md](../../how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md)
- [../../how-to/COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.md](../../how-to/COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.md)
- [04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md](04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md)
- [06_MATRIZ_RASTREABILIDADE_TESTES_V204.md](06_MATRIZ_RASTREABILIDADE_TESTES_V204.md)
- [07_ROTEIRO_TESTE_MANUAL_V204.md](07_ROTEIRO_TESTE_MANUAL_V204.md)

## Documentos-base

- [00_MODELO_DOCUMENTAL_DOS_TESTES.md](00_MODELO_DOCUMENTAL_DOS_TESTES.md)
- [01_EVIDENCIAS_E_RELATORIOS_DE_TESTE.md](01_EVIDENCIAS_E_RELATORIOS_DE_TESTE.md)
- [03_CATALOGO_CENARIOS_V2_V203.md](03_CATALOGO_CENARIOS_V2_V203.md)
- [../../auditoria/21_AUDITORIA_UNIFICADA_TESTES_V12_0203.md](../../auditoria/21_AUDITORIA_UNIFICADA_TESTES_V12_0203.md)

## Historico V203

- [02_MAPA_TESTES_V203_QUINTETO.md](02_MAPA_TESTES_V203_QUINTETO.md)
- [04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V203.md](04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V203.md)
- [05_ROTEIRO_TESTE_MANUAL_V203_RC4.md](05_ROTEIRO_TESTE_MANUAL_V203_RC4.md)

Esses documentos preservam a trilha rc4/Quinteto, mas nao sao o roteiro de
teste vigente da V12.0.0204.

## Escopo atual

- Bateria Oficial V1: regressão funcional consolidada em `RESULTADO_QA`
- Suíte V2: `SMOKE`, `CANONICO`, `STRESS` e assistidos em `RESULTADO_QA_V2`
- Gate consolidado V204 final:
  `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`
- Suites adversariais que compoem o bloco Onda 23:
  `ADVERSARIAL_UI=12/0/0`, `TRANSACAO_INTERRUPT=6/0/0`,
  `BOUNDARY_DATES=9/0/0`
- Evidencia final V204: `VR_20260511_154433` em
  `auditoria/evidencias/V12.0.0204/`.
- Debito V205 aceito: renomear a taxonomia publica de "Sexteto" para
  nomenclatura profissional de engenharia de software, sem alterar o contrato
  historico da V204.
- Debito V205 aceito: simplificar a Central de Testes para que a validacao
  completa de release seja a primeira opcao clara para humanos.
- Proposta canônica aprovada: [../PROPOSTA_TESTES_V2_CENARIO_CANONICO.md](../PROPOSTA_TESTES_V2_CENARIO_CANONICO.md)
- Auditoria estratégica vigente: [../../auditoria/21_AUDITORIA_UNIFICADA_TESTES_V12_0203.md](../../auditoria/21_AUDITORIA_UNIFICADA_TESTES_V12_0203.md)

## Objetivo desta área

- explicar para humanos o que cada família de testes prova
- padronizar a narrativa semântica dos cenários
- registrar o contrato de evidência, exportação e relatório
- permitir que outras IAs e futuros mantenedores ampliem a suíte sem perder coerência
