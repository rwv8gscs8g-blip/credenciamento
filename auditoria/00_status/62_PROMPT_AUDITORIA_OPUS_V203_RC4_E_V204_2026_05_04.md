---
titulo: 62 - Prompt auditoria Opus V203 rc4 e V204
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0203
data: 2026-05-04
---

# 62. Prompt - Auditoria Opus V203 rc4 e proposta V204

Voce e Claude Opus 4.7 em modo auditoria cruzada final da
`V12.0.0203-rc4` e planejamento tecnico da `V12.0.0204`. Nao implemente
codigo. Nao edite `src/vba`. Sua saida deve ser um unico documento
markdown escrito no caminho indicado abaixo.

## Output obrigatorio

Escreva em:

`auditoria/00_status/64_AUDITORIA_OPUS_V203_RC4_E_V204_2026_05_04.md`

## Decisao obrigatoria

Use uma destas decisoes:

1. `APROVADO_PARA_TESTE_MANUAL`
2. `APROVADO_COM_RESSALVAS`
3. `REPROVADO`
4. `BLOQUEADO`

Nao use decisao de producao. A V203 rc4 nao esta autorizada para
producao.

## Leia em ordem

1. `AGENTS.md`
2. `.hbn/knowledge/0001-regras-v203-inegociaveis.md`
3. `.hbn/knowledge/0002-regra-ouro-vba-import.md`
4. `.hbn/knowledge/0003-glasswing-style-preventive-security.md`
5. `CHANGELOG.md`
6. `auditoria/00_status/56_QA_CODEX_2026_05_04.md`
7. `auditoria/00_status/58_AUDITORIA_OPUS_FINAL_BLOCO_B_2026_05_04.md`
8. `auditoria/00_status/59_AUDITORIA_ANTIGRAVITY_FINAL_BLOCO_B_2026_05_04.md`
9. `auditoria/03_ondas/onda_17_test_first/70_FECHAMENTO_ONDA_17.md`
10. `auditoria/03_ondas/onda_18_reativ_strikes/70_FECHAMENTO_ONDA_18.md`
11. `docs/reference/testes/02_MAPA_TESTES_V203_QUINTETO.md`
12. `docs/reference/testes/03_CATALOGO_CENARIOS_V2_V203.md`
13. `docs/reference/testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V203.md`
14. `docs/reference/testes/05_ROTEIRO_TESTE_MANUAL_V203_RC4.md`
15. `auditoria/evidencias/V12.0.0203/ValidacaoReleaseQuinteto_V12_0_0203_VR_20260504_171048.csv`

## Codigo alvo

Audite com path:linha sempre que apontar achado:

1. `src/vba/Svc_Rodizio.bas`
2. `src/vba/Svc_Avaliacao.bas`
3. `src/vba/Repo_Empresa.bas`
4. `src/vba/Repo_Avaliacao.bas`
5. `src/vba/Classificar.bas`
6. `src/vba/Reativa_Empresa.frm`
7. `src/vba/Reativa_Entidade.frm`
8. `src/vba/Menu_Principal.frm`
9. `src/vba/Teste_V2_Roteiros.bas`
10. `src/vba/Teste_V2_Engine.bas`
11. `src/vba/Teste_Validacao_Release.bas`
12. `src/vba/App_Release.bas`

## Perguntas obrigatorias

1. As regras de negocio de rodizio, avaliacao, suspensao e reativacao
   estao coerentes?
2. A correcao da coluna `DT_ULT_REATIV` cobre cadastro, leitura,
   reativacao, classificacao e regressao?
3. Existe algum caminho em UI que ainda burla a regra de servico?
4. A bateria Quinteto e suficiente para liberar teste manual?
5. O mapa de testes explica bem o que e coberto e o que nao e?
6. Quais combinacoes ainda faltam para afirmar robustez de producao?
7. Quais debitos tecnicos devem bloquear a V204 final se nao forem
   resolvidos?

## Analise combinatoria requerida

Avalie ao menos estes eixos:

1. status empresa: ativa, inativa, suspensa;
2. datas: vazia, anterior a reativacao, igual a reativacao, posterior;
3. strikes: zero, um, dois, tres, quatro;
4. origem: service direto, form, teste canonico;
5. base: limpa, migrada, com referencia orfa;
6. operador: clique unico, duplo clique, cancelamento.

## Estrutura do documento final

1. Decisao executiva.
2. Achados P0/P1/P2 com path:linha.
3. Validacao das regras de negocio.
4. Validacao de seguranca e Glasswing.
5. Avaliacao dos mapas de teste.
6. Analise combinatoria de cobertura.
7. Comparativo V202 -> V203 rc4.
8. Debitos que devem entrar na V204.
9. Proposta detalhada de ondas V204.
10. Markers HBN finais.
