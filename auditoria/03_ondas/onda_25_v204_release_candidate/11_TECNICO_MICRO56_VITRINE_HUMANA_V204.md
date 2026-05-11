---
titulo: MICRO56 — Vitrine Humana V204
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-11
---

# MICRO56 — Vitrine Humana V204

## Objetivo

Fechar o bloqueio documental P1 apontado pelas auditorias cruzadas
Antigravity/Opus: a vitrine publica da V12.0.0204 ainda orientava o testador
humano para documentos V203/rc4 e para a macro historica do Quinteto.

## Escopo

MICRO56 e exclusivamente documental. Nao altera VBA, nao cria pacote V3 e nao
move a tag `v12.0.0204`.

## Entregas

- Guia publico de liberacao de macros no Windows.
- How-to canonico da V204 para `CT_ValidarRelease_SextetoMinimo`.
- Roteiro manual V204 com foco em reuso municipal, Limpar Base e `CAD_SERV`.
- Matriz humana de cobertura de regras de negocio V204.
- Arquivamento semantico dos documentos V203/Quinteto/rc4 como historicos.
- Indices publicos atualizados.
- Evidencia intermediaria de falha Smoke movida para pasta explicativa.
- DOCX V202 solto na raiz arquivado em area historica.

## Decisao

Os documentos V203 foram preservados por rastreabilidade, mas deixam de ser o
caminho dourado da vitrine. A trilha publica atual passa a ser:

1. `docs/how-to/COMO_LIBERAR_MACROS_NO_WINDOWS.md`
2. `docs/how-to/COMO_RODAR_SEXTETO_VALIDACAO_RELEASE.md`
3. `docs/reference/testes/07_ROTEIRO_TESTE_MANUAL_V204.md`
4. `docs/reference/testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V204.md`
5. `docs/reference/testes/06_MATRIZ_RASTREABILIDADE_TESTES_V204.md`

## Gate documental

- Build de referencia: `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2`
- Gate final de publicacao: `VR_20260511_154433`
- Gate adicional pos-MICRO55: `VR_20260511_175849`
- Sintaxe: `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`

## Debitos aceitos

- A taxonomia publica "Sexteto" sera renomeada na V12.0.0205.
- O prefixo historico `V12_0_0203` no nome do CSV sera corrigido na V12.0.0205.
