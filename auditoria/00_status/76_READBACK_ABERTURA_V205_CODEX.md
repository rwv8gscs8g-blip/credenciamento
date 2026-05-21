---
titulo: Readback Abertura V205 Codex
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-05-21
autor: Codex
---

# Readback de Abertura — V12.0.0205

Codex assume a V12.0.0205 em branch limpa criada a partir de `e43352f`, com
escopo aprovado pela cadeia SP1/SP2/SP3.

## Decisão consolidada

A V12.0.0205 é uma release de estabilização para produção. Ela pode tocar VBA
apenas em pontos textuais, UX de teste, evidência/exportação e metadados de
release. Regras de negócio permanecem congeladas.

## O que entra na V205

- saneamento do CI/CD stale;
- crosswalk de nomenclatura das baterias;
- melhoria de labels e ordem da Central de Testes;
- prefixo CSV V205 para evidências novas;
- Jornada de Validação Humana;
- Dossiê de Release em Markdown com DOCX/PDF derivados;
- pasta canônica de evidências V205;
- roadmap e registros de governança.

## O que fica fora da V205

- automação VBA de PDF;
- renomeação de símbolos VBA;
- refatoração profunda;
- performance;
- componentização;
- preparação SaaS.

## Gates da V205

1. Compilação VBE limpa.
2. Guarda funcional com a sintaxe V204 preservada:
   `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.
3. Gate complementar V205: CI/CD, evidências, manifesto, Jornada, Dossiê e
   hashes.
4. Nenhuma alteração semântica em RN-01 a RN-17.

## Pendências humanas

- Validar a nomenclatura RVS/SRC/BRL.
- Confirmar que a Jornada V205 pode funcionar como homologação interna caso o
  retorno externo da V204 demore.
- Confirmar que PDF automático VBA fica bloqueado até V206.
