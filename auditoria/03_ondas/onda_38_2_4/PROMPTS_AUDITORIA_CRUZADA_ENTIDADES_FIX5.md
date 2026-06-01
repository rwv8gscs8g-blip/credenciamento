---
titulo: Prompts Auditoria Cruzada — Entidades e Padrao de Seguranca V206
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-05-31
---

# Prompts Auditoria Cruzada — Entidades e Padrao de Seguranca V206

## Decisao recomendada sobre o timing do protocolo

Recomendacao Codex: **fazer a auditoria cruzada agora, com o protocolo HBN vigente**, e tratar o FAQ HBN como pauta formal da proxima evolucao do protocolo, nao como criterio retroativo desta auditoria.

Motivo:

- A Onda 38.2.4 ja tem readback 0120 confirmado, escopo fechado, import/compile/TV2/D5/RVS aprovados.
- Mudar o protocolo antes da auditoria criaria um alvo movel e atrasaria a verificacao da entrega ja feita.
- O FAQ HBN e uma evolucao correta, mas deve entrar como regra de processo antes de propagar este padrao para outros campos e antes do freeze final V206, nao como reabertura artificial do D5.
- Os prompts abaixo ja pedem aos auditores que avaliem a proposta do FAQ HBN como criterio futuro anti-regressao, sem transformar isso em bloqueador automatico da Onda 38.2.4.

Sequencia recomendada:

1. Rodar as duas auditorias cruzadas abaixo.
2. Consolidar BLOQUEADORES/FORTES/MARGINAIS.
3. Se nao houver BLOQUEADOR, fechar Onda 38.2.4 com ERP 0120.
4. Antes de propagar o padrao para outros campos e antes do freeze V206, abrir uma onda meta de evolucao do protocolo para FAQ HBN.

## Output esperado

- Antigravity + Gemini 3.5: `.hbn/proposals/0025-antigravity-gemini-auditoria-entidades-padrao-seguranca-v206.md`
- Claude Opus 4.8: `.hbn/proposals/0026-opus48-auditoria-entidades-padrao-seguranca-v206.md`

## PROMPT 1 — Antigravity com Gemini 3.5

```text
Voce e o Antigravity operando com Gemini 3.5 em uma sessao nova de AUDITORIA CRUZADA ADVERSARIAL da Onda 38.2.4 do Sistema de Credenciamento V12.0.0206.

ATIVE RACIOCINIO PROFUNDO / EXTENDED THINKING. Veracidade tecnica > consenso. Nao implemente codigo. Nao edite arquivos, exceto se voce tiver acesso local e for salvar SOMENTE o relatorio final no output_path indicado.

REPOSITORIO
/Users/macbookpro/Projetos/Credenciamento

BRANCH
codex/v12-0-0206-planejamento

HEAD OBSERVADO
fd45a5d

OUTPUT_PATH
.hbn/proposals/0025-antigravity-gemini-auditoria-entidades-padrao-seguranca-v206.md

CONTEXTO

A Onda 38.2.4, sob readback 0120, entregou a estabilizacao da funcionalidade de Entidades e das abas criticas associadas. Esta entrega deve ser auditada nao apenas como fix pontual, mas como candidato a PADRAO DE SEGURANCA E USO a propagar para os outros campos/fluxos do aplicativo onde se aplique.

Status reportado por Mauricio:
- Fix5 importado via Importador V3.
- Compile manual VBE aprovado.
- TV2_RunIntegridadeEstado aprovado: execucao TV2_20260531_013557, OK=8, FALHA=0, MANUAL=0.
- D5 manual aprovado: ENTIDADE_INATIVOS limpa, edicao direta bloqueada nas planilhas criticas, tentativa de colar imagem bloqueada corretamente.
- RVS completo pos-Fix5 aprovado: VR_20260531_092609.
- Build: fd45a5d+ONDA38.2.4-ESTADO-FIX5-OBJETOS-ABAS.
- CSV: auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260531_092609.csv
- SHA-256 do CSV: ee0bbd9840cce362592aa856ee9224b921ff8467fdc8aea8dc1e5ee240c48056

ARQUIVOS A LER, NESTA ORDEM

1. AGENTS.md
2. .hbn/relay/INDEX.md
3. .hbn/readbacks/0120-rb-onda-38-2-4-integridade-estado.json
4. .hbn/hearbacks/0120-rb-onda-38-2-4-integridade-estado-confirmed.json
5. auditoria/03_ondas/onda_38_2_4/README.md
6. auditoria/03_ondas/onda_38_2_4/GATE_IMPORT_TV2_RESULTADO.md
7. auditoria/03_ondas/onda_38_2_4/GATE_D2_ORDENACAO.md
8. auditoria/03_ondas/onda_38_2_4/GATE_D3_ENTIDADE_ATOMICA.md
9. auditoria/03_ondas/onda_38_2_4/GATE_D4_PROTECAO_ABAS.md
10. auditoria/03_ondas/onda_38_2_4/GATE_D5_OBJETOS_ABAS_CRITICAS.md
11. auditoria/03_ondas/onda_38_2_4/RVS_FINAL.md
12. auditoria/03_ondas/onda_38_2_4/MAPA_TESTES_ENTIDADES_V206.md
13. auditoria/03_ondas/onda_38_2_4/REVALIDACAO_MANUAL_ENTIDADES.md
14. auditoria/03_ondas/onda_38_2_4/OBSERVACOES_MANUAIS_ENTIDADES.md
15. auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260531_092609.csv
16. .hbn/proposals/0022-opus-auditoria-gate-a4-l43-v206.md
17. .hbn/proposals/0023-antigravity-auditoria-gate-a4-l43-v206.md
18. .hbn/proposals/0024-Opus3-4-MAX-auditoria-gate-a4-l43-v206.md
19. src/vba/Classificar.bas
20. src/vba/Altera_Entidade.frm
21. src/vba/Util_Planilha.bas
22. src/vba/Teste_V2_Roteiros.bas
23. local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_4_ESTADO_FIX5_OBJETOS_ABAS.txt
24. local-ai/vba_import/001-modulo/AAE-Util_Planilha.bas
25. local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas
26. local-ai/vba_import/001-modulo/AAX-App_Release.bas

TAREFA

Produza uma auditoria completa da entrega da funcionalidade de Entidades, cobrindo obrigatoriamente:

1. VEREDITO EXECUTIVO
   - A Onda 38.2.4 pode ser considerada aprovada para fechar ERP 0120?
   - Ha algum BLOQUEADOR que impeça fechar a onda?
   - Ha FORTES que devem virar ajuste antes da propagacao do padrao?
   - Confirmar explicitamente: isto NAO e freeze V206.

2. AUDITORIA DO ESCOPO ENTREGUE
   Avalie, com file:line quando possivel:
   - Remocao de xlGuess em Classificar.bas.
   - Inativacao atomica/rollback em Altera_Entidade.frm.
   - Tratamento da ultima linha de ListObject em Util_Planilha.bas.
   - Protecao de abas criticas, incluindo cells locked, ProtectContents e ProtectDrawingObjects.
   - Limpeza de Shapes/objetos residuais em abas criticas.
   - TV2_RunIntegridadeEstado e seus 8 cenarios.
   - Espelho local-ai/vba_import versus fonte.
   - Manifesto Fix5 e build label.

3. PADRAO DE SEGURANCA E USO A PROPAGAR
   Esta entrega sera usada como padrao para outros campos/fluxos do aplicativo. Audite se o padrao esta bom o suficiente:
   - Ordenacao deterministica, nunca xlGuess em ranges operacionais sem cabecalho real.
   - Transacao atomica para mover registros ativo/inativo.
   - Protecao reaplicavel de abas criticas.
   - Bloqueio de edicao direta e bloqueio de objetos.
   - Limpeza/saneamento idempotente antes de validar.
   - Teste automatico dirigido + checklist manual curto + RVS final.
   - Quais partes podem ser generalizadas como helper/padrao?
   - Quais partes devem permanecer especificas de Entidades?
   - Riscos de propagar cegamente para Empresas, Servicos, Credenciamentos, PRE_OS, CAD_OS e relatorios.

4. AUDITORIA DA PROPOSTA DE TESTE AUTOMATIZADO
   Avalie a proposta atual de teste da funcionalidade de Entidades:
   - MAPA_TESTES_ENTIDADES_V206 e suficiente?
   - TV2_RunIntegridadeEstado e robusto ou ainda e muito textual/token-based?
   - Quais cenarios manuais atuais devem virar teste automatizado?
   - Proponha um desenho de teste automatizado para ciclo de vida de Entidades:
     a. cadastrar entidade;
     b. editar campos completos;
     c. inativar;
     d. confirmar ausencia em ativas e presenca em inativas;
     e. reativar;
     f. confirmar exclusividade ativa/inativa;
     g. validar ordenacao;
     h. validar protecao contra edicao direta/objeto quando tecnicamente automatizavel.
   - Diga o que deve ser V2, o que deveria ser V3/UI-driven, e o que ainda exige teste assistido por limitação do VBE/Excel.

5. FAQ HBN — AVALIACAO COMO PROTOCOLO FUTURO, NAO COMO GATE RETROATIVO
   Mauricio anunciou um processo futuro chamado FAQ HBN:
   - Nenhum FAQ HBN existe sem mapa de testes que funcione e tenha passado.
   - Cada item de FAQ ganha ate 100% de maturidade:
     a. Regra de Negocio documentada = 25%;
     b. Comprovacao da Arquitetura = 25%;
     c. Evidencia do Codigo = 25%;
     d. Mapa de Testes aprovado = 25%.
   - O FAQ HBN sera anti-regressao e devera repercutir em cada release aprovada.

   Perguntas para voce responder:
   - A entrega de Entidades ja tem um FAQ HBN candidato? Qual seria o nome?
   - Quais dos 4 criterios ela ja possui com evidencia real?
   - Qual percentual de maturidade voce atribuiria hoje?
   - Que evidencias faltam para chegar a 100%?
   - Esse novo protocolo deve bloquear o fechamento da Onda 38.2.4 agora? Ou deve entrar na proxima evolucao do useHBN antes da propagacao para outros fluxos?

6. CLASSIFICACAO DE ACHADOS
   Classifique cada achado como:
   - BLOQUEADOR: impede fechar a Onda 38.2.4.
   - FORTE: deve incorporar ou justificar antes de propagar o padrao.
   - MARGINAL: pode ficar para V207 ou melhoria futura.

7. CHECKLIST ANTI-VIES
   Responda explicitamente:
   - Voce se autoindicaria para implementar algo? Sim/nao e por que.
   - Qual evidencia objetiva sustenta sua recomendacao?
   - Onde seu modelo pode estar enviesado?
   - Qual mitigacao recomenda?

8. RECOMENDACAO FINAL PARA MAURICIO
   Escolha uma:
   - A. Fechar Onda 38.2.4 e abrir ERP 0120 agora.
   - B. Fechar Onda 38.2.4 apenas apos ajustes FORTES documentais/testes.
   - C. Bloquear Onda 38.2.4 por BLOQUEADOR.

FORMATO DO OUTPUT

Markdown tecnico em portugues.
Comece com frontmatter:
---
titulo: Auditoria Antigravity Gemini — Entidades e Padrao de Seguranca V206
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-31
papel-autor: Antigravity + Gemini 3.5 — auditoria cruzada adversarial
escopo: Onda 38.2.4 Entidades, protecao de abas criticas, D5, RVS pos-Fix5, padrao de seguranca e teste automatizado
output_path: .hbn/proposals/0025-antigravity-gemini-auditoria-entidades-padrao-seguranca-v206.md
---

Sub 6000 palavras.
Use tabelas onde ajudam.
Use file:line ao referenciar codigo.
Nao implemente.
Nao proponha V207 amplo, exceto como destino de achados MARGINAIS.
Se discordar de Codex/Opus/Antigravity anteriores, diga claramente.
```

## PROMPT 2 — Claude Opus 4.8

```text
Voce e Claude Opus 4.8 em uma sessao nova de AUDITORIA ARQUITETURAL COMPLETA da Onda 38.2.4 do Sistema de Credenciamento V12.0.0206.

Papel: auditor-consolidador independente. Voce nao e o implementador. Sua funcao e decidir se a entrega de Entidades pode fechar a Onda 38.2.4 e se ela e um padrao seguro para propagacao futura.

ATIVE MODO RACIOCINIO MAXIMO / EXTENDED THINKING. Estabilizacao tecnica > velocidade. Veracidade > diplomacia. Nao implemente codigo. Nao edite arquivos, exceto se voce tiver acesso local e for salvar SOMENTE o relatorio final no output_path indicado.

REPOSITORIO
/Users/macbookpro/Projetos/Credenciamento

BRANCH
codex/v12-0-0206-planejamento

HEAD OBSERVADO
fd45a5d

OUTPUT_PATH
.hbn/proposals/0026-opus48-auditoria-entidades-padrao-seguranca-v206.md

CONTEXTO ESSENCIAL

V12.0.0205 permanece release oficial. V12.0.0206 esta em estabilizacao iterativa.

O L43/GATE-A4 revelou bloqueadores reais em uso prolongado. As auditorias 0022, 0023 e 0024 convergiram que RVS verde nao libera freeze. A Onda 38.2.4 foi aberta sob readback 0120 para atacar o cluster de Entidades/Integridade de Estado:
- ordenacao deterministica;
- inativacao atomica;
- protecao de abas criticas;
- objetos residuais em abas criticas;
- suite dirigida TV2_RunIntegridadeEstado.

Status atual reportado por Mauricio:
- Fix5 importado via Importador V3.
- Compile manual VBE aprovado.
- TV2_RunIntegridadeEstado aprovado: TV2_20260531_013557, OK=8, FALHA=0, MANUAL=0.
- D5 manual aprovado: ENTIDADE_INATIVOS limpa, edicao direta bloqueada nas planilhas criticas, tentativa de colar imagem bloqueada corretamente.
- RVS completo pos-Fix5 aprovado: VR_20260531_092609.
- Build: fd45a5d+ONDA38.2.4-ESTADO-FIX5-OBJETOS-ABAS.
- CSV: auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260531_092609.csv
- SHA-256: ee0bbd9840cce362592aa856ee9224b921ff8467fdc8aea8dc1e5ee240c48056

ARQUIVOS A LER, NESTA ORDEM

1. AGENTS.md
2. .hbn/relay/INDEX.md
3. .hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md
4. .hbn/readbacks/0120-rb-onda-38-2-4-integridade-estado.json
5. .hbn/hearbacks/0120-rb-onda-38-2-4-integridade-estado-confirmed.json
6. auditoria/03_ondas/onda_38_2_4/README.md
7. auditoria/03_ondas/onda_38_2_4/GATE_IMPORT_TV2_RESULTADO.md
8. auditoria/03_ondas/onda_38_2_4/GATE_D2_ORDENACAO.md
9. auditoria/03_ondas/onda_38_2_4/GATE_D3_ENTIDADE_ATOMICA.md
10. auditoria/03_ondas/onda_38_2_4/GATE_D4_PROTECAO_ABAS.md
11. auditoria/03_ondas/onda_38_2_4/GATE_D5_OBJETOS_ABAS_CRITICAS.md
12. auditoria/03_ondas/onda_38_2_4/RVS_FINAL.md
13. auditoria/03_ondas/onda_38_2_4/MAPA_TESTES_ENTIDADES_V206.md
14. auditoria/03_ondas/onda_38_2_4/REVALIDACAO_MANUAL_ENTIDADES.md
15. auditoria/03_ondas/onda_38_2_4/OBSERVACOES_MANUAIS_ENTIDADES.md
16. auditoria/03_ondas/onda_38_2_4/V207_NOTA_ARQUITETURA_STATUS_CANONICO.md
17. auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260531_092609.csv
18. .hbn/proposals/0022-opus-auditoria-gate-a4-l43-v206.md
19. .hbn/proposals/0023-antigravity-auditoria-gate-a4-l43-v206.md
20. .hbn/proposals/0024-Opus3-4-MAX-auditoria-gate-a4-l43-v206.md
21. src/vba/Classificar.bas
22. src/vba/Altera_Entidade.frm
23. src/vba/Util_Planilha.bas
24. src/vba/Teste_V2_Roteiros.bas
25. local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_4_ESTADO_FIX5_OBJETOS_ABAS.txt
26. local-ai/vba_import/001-modulo/AAE-Util_Planilha.bas
27. local-ai/vba_import/001-modulo/ABG-Teste_V2_Roteiros.bas
28. local-ai/vba_import/001-modulo/AAX-App_Release.bas

TAREFA

Produza uma auditoria completa, com estes blocos obrigatorios:

1. VEREDITO
   - A Onda 38.2.4 pode fechar ERP 0120?
   - A entrega esta apta a ser padrao de seguranca/uso para outros fluxos?
   - O que ainda impede freeze V206, se algo impedir?
   - Separe claramente: "fechar Onda 38.2.4" vs "tagar V12.0.0206".

2. AUDITORIA TECNICA DA ENTREGA DE ENTIDADES
   Verifique com file:line:
   - Classificar.bas: eliminacao de xlGuess e impacto em entidades/servicos.
   - Altera_Entidade.frm: atomicidade de inativacao, rollback, ausencia de clipboard/EntireRow/ActiveCell operacional.
   - Util_Planilha.bas: protecao de abas criticas, tentativa de desproteção/restauracao, ListObject ultima linha, Shapes, DrawingObjects, celulas Locked.
   - Teste_V2_Roteiros.bas: TV2_RunIntegridadeEstado, 8 asserts, lacunas do teste.
   - local-ai/vba_import: manifesto, espelhos e App_Release.
   - Evidencias: import/compile/TV2/D5/RVS.

3. PADRAO DE SEGURANCA E USO PARA PROPAGACAO
   Mauricio quer que esta entrega seja o padrao a propagar para outros campos aplicaveis. Avalie:
   - Qual e o padrao em termos de design tecnico?
   - Quais invariantes devem virar regra permanente?
   - Quais helpers podem ser generalizados?
   - Quais comportamentos de UI devem ser exigidos: bloqueio de edicao direta, bloqueio de objeto, protecao persistente, feedback ao operador, reversibilidade?
   - Como aplicar ou nao aplicar em Empresas, Empresas Inativas, Servicos, Credenciamentos, PRE_OS, CAD_OS, relatorios e abas de impressao?
   - Que riscos existem em aplicar protecao/limpeza de Shapes indiscriminadamente?

4. PROPOSTA DE TESTE AUTOMATIZADO DA FUNCIONALIDADE
   Avalie o MAPA_TESTES_ENTIDADES_V206 e a cobertura atual.
   Proponha um teste automatizado alvo para Entidades, com:
   - nome sugerido da suite;
   - pre-condicoes;
   - fixture/base;
   - passos;
   - asserts;
   - rollback/limpeza;
   - criterio de aprovacao;
   - o que deve entrar em V2 agora;
   - o que deve virar V3/UI-driven;
   - o que deve permanecer manual por limite do Excel/VBE.

   O teste deve cobrir, no minimo:
   - cadastrar entidade;
   - editar campos completos;
   - inativar;
   - validar ativa XOR inativa;
   - reativar;
   - validar ordenacao;
   - validar leitura da tela principal versus modal de edicao;
   - validar protecao de abas criticas quando tecnicamente possivel.

5. FAQ HBN COMO PROTOCOLO FUTURO
   Mauricio anunciou o FAQ HBN:
   - nenhum FAQ HBN existe sem mapa de testes que funcione e tenha passado;
   - quatro criterios de maturidade, cada um valendo 25%:
     a. Regra de Negocio;
     b. Comprovacao da Arquitetura;
     c. Evidencia do Codigo;
     d. Mapa de Testes aprovado.

   Analise:
   - Esta entrega de Entidades ja deveria gerar um FAQ HBN candidato?
   - Qual seria o nome do FAQ?
   - Quais dos quatro criterios ja estao evidenciados?
   - Qual maturidade percentual hoje?
   - O que falta para 100%?
   - Esse protocolo deve ser evoluido antes da auditoria atual, ou depois de fechar Onda 38.2.4 e antes de propagar o padrao?

   Importante: FAQ HBN ainda nao e regra vigente. Nao use como bloqueador retroativo sem justificar com risco tecnico real.

6. SEVERIDADES
   Liste achados em:
   - BLOQUEADOR: impede fechar Onda 38.2.4.
   - FORTE: deve incorporar/justificar antes de propagar padrao ou antes do freeze.
   - MARGINAL: pode ficar para V207.

7. CHECKLIST ANTI-VIES E BASTAO
   - Voce se autoindicaria para implementar proximos ajustes? Sim/nao.
   - Quem deve consolidar as auditorias?
   - Quem deve implementar a propagacao do padrao para outros fluxos?
   - Quem deve auditar?
   - Que vies pode haver na sua avaliacao?
   - Como mitigar?

8. DECISAO RECOMENDADA PARA MAURICIO
   Escolha uma:
   - A. Fechar Onda 38.2.4 com ERP 0120 e abrir evolucao FAQ HBN depois.
   - B. Fechar Onda 38.2.4, mas bloquear propagacao do padrao ate ajustes FORTES.
   - C. Nao fechar Onda 38.2.4 por BLOQUEADOR.

   Diga tambem se recomenda:
   - auditoria cruzada agora, depois evolucao do protocolo;
   - ou evolucao do protocolo primeiro e auditoria depois.

FORMATO DO OUTPUT

Markdown tecnico em portugues.
Comece com frontmatter:
---
titulo: Auditoria Opus 4.8 — Entidades e Padrao de Seguranca V206
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-31
papel-autor: Claude Opus 4.8 — auditoria arquitetural independente
escopo: Onda 38.2.4 Entidades, protecao de abas criticas, D5, RVS pos-Fix5, padrao de seguranca, teste automatizado e FAQ HBN futuro
output_path: .hbn/proposals/0026-opus48-auditoria-entidades-padrao-seguranca-v206.md
---

Sub 7000 palavras.
Use tabelas onde util.
Use file:line ao referenciar codigo.
Nao implemente.
Nao abra V207 amplo; cite V207 apenas para destino de MARGINAIS ou arquitetura futura.
Se encontrar erro grave nas evidencias, diga claramente.
```

## Como aplicar

1. Abra uma sessao nova Antigravity com Gemini 3.5 e cole o PROMPT 1.
2. Abra uma sessao nova Claude Opus 4.8 e cole o PROMPT 2.
3. Salve/peça para salvar os outputs nos paths:
   - `.hbn/proposals/0025-antigravity-gemini-auditoria-entidades-padrao-seguranca-v206.md`
   - `.hbn/proposals/0026-opus48-auditoria-entidades-padrao-seguranca-v206.md`
4. Traga os dois resultados para o Codex consolidar BLOQUEADORES/FORTES/MARGINAIS e decidir ERP 0120.
