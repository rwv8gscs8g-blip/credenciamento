---
titulo: 63 - Prompt auditoria Antigravity V203 rc4 e V204
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0203
data: 2026-05-04
---

# 63. Prompt - Auditoria Antigravity V203 rc4 e proposta V204

Voce e Antigravity em modo auditoria adversarial da `V12.0.0203-rc4`.
Nao implemente codigo. Nao edite `src/vba`. Seu objetivo e encontrar
regressoes, lacunas de teste, risco de seguranca e falhas combinatorias
que Codex e Opus possam ter deixado passar.

## Output obrigatorio

Escreva em:

`auditoria/00_status/65_AUDITORIA_ANTIGRAVITY_V203_RC4_E_V204_2026_05_04.md`

## Decisao obrigatoria

Use uma destas decisoes:

1. `APROVADO_PARA_TESTE_MANUAL`
2. `APROVADO_COM_RESSALVAS`
3. `REPROVADO`
4. `BLOQUEADO`

Nao aprove producao. A V203 rc4 e uma release de teste manual formal.

## Leia em ordem

1. `AGENTS.md`
2. `.hbn/knowledge/0001-regras-v203-inegociaveis.md`
3. `.hbn/knowledge/0002-regra-ouro-vba-import.md`
4. `.hbn/knowledge/0003-glasswing-style-preventive-security.md`
5. `auditoria/00_status/55_AUDITORIA_ANTIGRAVITY_2026_05_04.md`
6. `auditoria/00_status/56_QA_CODEX_2026_05_04.md`
7. `auditoria/00_status/58_AUDITORIA_OPUS_FINAL_BLOCO_B_2026_05_04.md`
8. `auditoria/00_status/59_AUDITORIA_ANTIGRAVITY_FINAL_BLOCO_B_2026_05_04.md`
9. `auditoria/03_ondas/onda_18_reativ_strikes/70_FECHAMENTO_ONDA_18.md`
10. `docs/reference/testes/02_MAPA_TESTES_V203_QUINTETO.md`
11. `docs/reference/testes/03_CATALOGO_CENARIOS_V2_V203.md`
12. `docs/reference/testes/04_MATRIZ_COBERTURA_REGRAS_NEGOCIO_V203.md`
13. `docs/reference/testes/05_ROTEIRO_TESTE_MANUAL_V203_RC4.md`
14. `auditoria/evidencias/V12.0.0203/TesteV2_CANONICO_Falhas_TV2_20260504_164403.csv`
15. `auditoria/evidencias/V12.0.0203/ValidacaoReleaseQuinteto_V12_0_0203_VR_20260504_171048.csv`

## Foco adversarial

1. Procure `On Error Resume Next` que possa mascarar erro.
2. Procure `sucesso = True` apos subrotina que pode falhar silenciosa.
3. Procure mutacao de estado global em funcoes de nome aparentemente
   neutro.
4. Procure actions destrutivas sem confirmacao suficiente.
5. Procure dependencia de ordem de chamada nao documentada.
6. Procure formulario que permita reentrada por duplo clique.
7. Procure ordenacao que esqueca colunas apos a `U`.
8. Procure qualquer drift entre regra de negocio e teste.

## Analise combinatoria requerida

Monte uma matriz com:

1. entidade existe/nao existe;
2. empresa ativa/inativa/suspensa;
3. `DT_ULT_REATIV` vazia/preenchida/invalida;
4. OS aberta/fechada/cancelada;
5. avaliacao antes/igual/depois da reativacao;
6. operador via service/form/menu;
7. base limpa/base migrada/base com orfaos.

## Saida esperada

1. Decisao executiva.
2. Achados P0/P1/P2 com path:linha.
3. Lacunas de teste por regra de negocio.
4. Riscos de seguranca preventiva.
5. Avaliacao da cobertura combinatoria.
6. Comparativo V202 -> V203 rc4.
7. Proposta detalhada de baterias V204.
8. Proposta detalhada de evolucoes V204.
9. Markers HBN finais.
