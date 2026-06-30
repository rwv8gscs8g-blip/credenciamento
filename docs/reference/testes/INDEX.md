---
titulo: Índice da Bateria de Testes
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-21
---

# Índice da Bateria de Testes

Esta área consolida a leitura humana e institucional da bateria de testes.

## Trilha V12.0.0205 oficial

> A V205 adota nomenclatura profissional sem renomear símbolos VBA internos.
> O Gate de Validação de Release (RVS) é a rota oficial da validação de
> produção e preserva a mesma guarda funcional da V204.

- [NOMENCLATURA_BATERIAS_V205.md](NOMENCLATURA_BATERIAS_V205.md) — equivalência histórica RVS/SRC/BRL
- [ESPEC_PDF_AUTOMATICO_V205.md](ESPEC_PDF_AUTOMATICO_V205.md) — PDF manual na V205 e motor automático diferido para V206
- [09_MATRIZ_COBERTURA_TESTES_V205.md](09_MATRIZ_COBERTURA_TESTES_V205.md) — cobertura de testes e evidências da V205
- [10_BATERIAS_TESTES_DISPONIVEIS_V206.md](10_BATERIAS_TESTES_DISPONIVEIS_V206.md) — catálogo atualizado das baterias disponíveis na linha V206
- [../../how-to/COMO_RODAR_GATE_RELEASE_V205.md](../../how-to/COMO_RODAR_GATE_RELEASE_V205.md) — roteiro técnico do Gate RVS
- [../../../auditoria/evidencias/V12.0.0205/INDEX.md](../../../auditoria/evidencias/V12.0.0205/INDEX.md) — evidências da V205

## Trilha histórica V12.0.0204

- [../../tutorials/GUIA_TESTES_HUMANOS_V204.md](../../tutorials/GUIA_TESTES_HUMANOS_V204.md)
- [../../tutorials/GUIA_TESTES_HUMANOS_V204.docx](../../tutorials/GUIA_TESTES_HUMANOS_V204.docx)
- [../../how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md](../../how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md)
- [../../how-to/COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.md](../../how-to/COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.md)
- [../regras/REGRAS_DE_NEGOCIO_V204.md](../regras/REGRAS_DE_NEGOCIO_V204.md)
- [04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md](04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md)
- [06_MATRIZ_RASTREABILIDADE_TESTES_V204.md](06_MATRIZ_RASTREABILIDADE_TESTES_V204.md)
- [07_ROTEIRO_TESTE_MANUAL_V204.md](07_ROTEIRO_TESTE_MANUAL_V204.md)
- [../../../auditoria/evidencias/V12.0.0204/INDEX.md](../../../auditoria/evidencias/V12.0.0204/INDEX.md)

## Documentos-base

- [00_MODELO_DOCUMENTAL_DOS_TESTES.md](00_MODELO_DOCUMENTAL_DOS_TESTES.md)
- [01_EVIDENCIAS_E_RELATORIOS_DE_TESTE.md](01_EVIDENCIAS_E_RELATORIOS_DE_TESTE.md)
- [03_CATALOGO_CENARIOS_V2_V203.md](03_CATALOGO_CENARIOS_V2_V203.md)
- [../../../auditoria/01_regras_e_governanca/21_AUDITORIA_UNIFICADA_TESTES_V12_0203.md](../../../auditoria/01_regras_e_governanca/21_AUDITORIA_UNIFICADA_TESTES_V12_0203.md)

## Histórico V203

- [02_MAPA_TESTES_V203_QUINTETO.md](02_MAPA_TESTES_V203_QUINTETO.md)
- [04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V203.md](04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V203.md)
- [05_ROTEIRO_TESTE_MANUAL_V203_RC4.md](05_ROTEIRO_TESTE_MANUAL_V203_RC4.md)

Esses documentos preservam a trilha rc4/Quinteto, mas não são o roteiro de
teste vigente da V12.0.0205.

## Escopo atual

- Bateria Oficial V1: regressão funcional consolidada em `RESULTADO_QA`
- Suíte V2: `SMOKE`, `CANONICO`, `STRESS` e assistidos em `RESULTADO_QA_V2`
- Gate consolidado V205 final:
  `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`
- Suítes adversariais que compõem o bloco Onda 23:
  `ADVERSARIAL_UI=12/0/0`, `TRANSACAO_INTERRUPT=6/0/0`,
  `BOUNDARY_DATES=9/0/0`
- Evidência final V205: `VR_20260523_215637` em
  `auditoria/evidencias/V12.0.0205/`.
- Débito V206 aceito: automatizar PDF com motor robusto e tratamento de erro,
  mantendo fallback manual na V205.
- Débito V207 planejado: code review profundo, performance e componentização.
- Proposta canônica aprovada:
  [../../explanation/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md](../../explanation/PROPOSTA_TESTES_V2_CENARIO_CANONICO.md)
- Auditoria estratégica histórica:
  [../../../auditoria/01_regras_e_governanca/21_AUDITORIA_UNIFICADA_TESTES_V12_0203.md](../../../auditoria/01_regras_e_governanca/21_AUDITORIA_UNIFICADA_TESTES_V12_0203.md)

## Objetivo desta área

- explicar para humanos o que cada família de testes prova
- padronizar a narrativa semântica dos cenários
- registrar o contrato de evidência, exportação e relatório
- permitir que outras IAs e futuros mantenedores ampliem a suíte sem perder coerência
