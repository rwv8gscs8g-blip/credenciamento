---
titulo: MICRO53 — Correcao Limpar Base CAD_SERV
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-11
---

# MICRO53 — Correcao Limpar Base CAD_SERV

## Decisao

MICRO53 corrige um P1 encontrado na validacao manual final da V12.0.0204-rc1:
o botao Limpar Base preservava `CAD_SERV`, o que impedia preparar uma planilha
limpa para outro municipio. A partir deste delta, o reset preserva apenas
`ATIVIDADES` (CNAE) e `CONFIG`, e limpa `CAD_SERV` com cabecalho canonico.

O delta tambem endurece o caminho de abertura/refresh do Cadastro de Servico
para descartar instancias ocultas de formulario e nao reaproveitar um filtro
stale depois do modal.

## Arquivos alterados

- `src/vba/Mod_Limpeza_Base.bas`: `LimpaBaseTotalReset` inclui `CAD_SERV` na limpeza e remove `CAD_SERV` da lista preservada.
- `src/vba/Preencher.bas`: texto de confirmacao do reset reflete o novo contrato.
- `src/vba/Menu_Principal.frm`: descarte de forms stale e refresh seguro de manutencao de servicos.
- `src/vba/Teste_V2_Engine.bas`: catalogo/roteiro recebem `MIG_009`; reset operacional dos testes passa a limpar `CAD_SERV`.
- `src/vba/Teste_V2_Roteiros.bas`: Smoke recebe assert `MIG_009`.
- `src/vba/App_Release.bas`: build `f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix`.

## Teste novo

`MIG_009` roda dentro de `TV2_RunSmoke`:

- prepara baseline canonica com CNAE e servicos;
- executa `LimpaBaseTotalReset`;
- exige `ATIVIDADES` preservada;
- exige `CAD_SERV` com zero linhas de dados;
- exige relatorio sem `CAD_SERV` em "PRESERVADO".

Contrato esperado do Smoke apos import: `OK=34 | FALHA=0 | MANUAL=4`.

## Gates locais

- `publicar_vba_import_v2.sh --check`: OK, 53 arquivos sincronizados.
- `glasswing-checks.sh G7 G8`: OK.

## Risco residual

O compile e os testes VBA dependem do operador no Excel. O pacote fica
entregue para importacao MICRO53 e so deve liberar MICRO54 se o operador
confirmar compile limpo, Smoke 34/0/4, teste manual do Cadastro de Servico e
Sexteto minimo aprovado.
