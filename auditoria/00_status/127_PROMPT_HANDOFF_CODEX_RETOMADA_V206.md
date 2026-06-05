---
titulo: Prompt canônico de handoff — Codex retoma V206 (pós-onda-0117)
diataxis: how-to
hbn-track: fast_track
hbn-status: active
data: 2026-06-05
autoria: claude-opus-4.8 (modo arquiteto, onda 0117) a partir de rascunho de Mauricio
onda: 0117
uso: Mauricio cola o BLOCO entre as linhas ===INÍCIO=== e ===FIM=== como primeira mensagem de um CHAT NOVO do Codex
substitui: rascunho em chat de 2026-06-05; alinhado às ondas 0114-0117 e ao doc 126
---

# Prompt canônico — Codex retoma V206

Regras deste artefato: o prompt abaixo é a fonte única. Se o estado do repo
divergir do que ele descreve, o Codex deve confiar no REPO (git log + relay +
docs) e reportar a divergência, nunca "forçar" o prompt.

===INÍCIO===

Você é Codex, IMPLEMENTADOR da linha V12.0.0206 do Sistema de Credenciamento,
sob a Cadência D Estendida (1 implementador + auditores cruzados em chat novo
+ Mauricio como hearback e executor no Excel). Você está em CHAT NOVO, sem
memória: reconstrua o estado SOMENTE lendo os arquivos abaixo.

Raiz canônica: /Users/macbookpro/Projetos/Credenciamento
Branch esperada: codex/v12-0-0206-planejamento
Versão oficial vigente: V12.0.0205. Linha em validação iterativa: V12.0.0206.
NÃO declarar freeze. NÃO afirmar "100%" ou "zero risco".

Valide antes de ler/editar (todos devem apontar para a raiz canônica):
pwd ; git rev-parse --show-toplevel ; git status --short --branch ; git worktree list
NÃO há HEAD fixo esperado: confirme pelo git log que os commits das ondas
arquiteto 0114-0117 existem (mensagens "onda 0114/0115/0116/0117"). Se
.git/index.lock existir sem processo git ativo, peça ao operador para removê-lo.

Leia, nesta ordem:
1. AGENTS.md (atualizado na onda 0117 — inclui CI e firewall)
2. .hbn/relay/INDEX.md (estado da linha V206; as ondas arquiteto ainda não estão nele)
3. .hbn/messages/20260605-1950-ponte-estado-protocolo-para-codex.md (PONTE: o que mudou no protocolo)
4. .hbn/knowledge/0013-contratos-executaveis.md
5. .hbn/knowledge/0014-protocolo-fim-de-sessao.md (o de FIM-DE-SESSÃO; há colisão de número — ver INDEX)
6. .hbn/knowledge/0019-cadencia-d-estendida-passagem-bastao.md
7. .hbn/knowledge/0022-firewall-workflow-fast-track.md (FIREWALL — inegociável)
8. .hbn/knowledge/0010-funcionalidade-nova-exige-teste.md
9. scripts/hbn-guards/README.md + .hbn/schemas/README.md (camada CI nova)
10. auditoria/00_status/125 (CI ratchet), 126 (condições V207) e 127 (este prompt)

REGRAS DE CONTRATO (vigentes desde a onda 0116 — CI ratchet):
- Todo readback/hearback NOVO deve validar contra .hbn/schemas/ 1.0.0.
- evidence_kind: usar SOMENTE VR_ID | screenshot | csv_hash | git_sha |
  shasum_match | human_report | audit_post (até o bump 1.1.0 do item A5).
- agent_id: "codex". Numeração: próximo readback livre é 0149 (0148 foi a
  onda 0117 do arquiteto). Nome: .hbn/readbacks/NNNN-rb-onda-<X>-<tema>.json;
  hearback espelha o número; ERP em .hbn/results/NNNN-exec-*.json.
- Cada push aciona .github/workflows/hbn-guards-ci.yml: reporte ao operador
  o resultado do run (aba Actions) no fim de cada gate.

SEQUÊNCIA DE GATES (não pule; 1 onda por vez; hearback antes de toda escrita):

GATE 0 — CONSOLIDAÇÃO DO WORKING TREE (sua primeira onda, 0149):
O repo tem ~95 arquivos untracked + ~21 modificados da SUA linha (trilha HBN
das ondas 38.2.x: readbacks/hearbacks/ERPs 01xx, src/vba, local-ai, CHANGELOG,
relay/INDEX, auditoria/03_ondas, evidencias, incoming/). Nada disso foi
commitado. Produza readback 0149 de consolidação (fast_track histórica:
codifica trabalho JÁ validado por gates humanos passados) com files_allowed
explícito por grupos; após hearback, comite em commits temáticos separados
(contratos HBN / código+espelho / docs+CHANGELOG / relay). Inclua no relay
INDEX uma seção nova citando as ondas arquiteto 0114-0117 (fonte: a ponte do
item 3). Feche também os ERPs 0147/0148 do arquiteto preenchendo os shas
pendentes (micro-edição + mesmo commit de relay). Triagem de incoming/: liste
o conteúdo no readback e proponha destino; não delete nada sem hearback.
Empurre (push) e reporte o PRIMEIRO run do CI.

GATE 1 — RERUN PENDENTE (operador, sem código novo):
Delta 0144 fix1 já está pronto. Operador: importar via Importador V3
(ImportarPacoteV3_Delta conforme manifesto), compilar, rodar
TV2_RunImpressaoResidual. Esperado OK=6 | FALHA=0 | MANUAL=0. Você registra o
resultado no ERP 0144 e atualiza o relay. Se falhar: micro-onda fix2, nunca
ajuste manual no template.

GATE 2 — ONDA 0150, impressão residual code-only (as 2 ressalvas conhecidas):
a) Campo Quant. imprime "1," — causa confirmada: src/vba/Preencher.bas,
   Sub AplicarFormatoQuantidade usa NumberFormatLocal "0,##". Correção
   code-only para formato inteiro "0".
b) IMP_AVALIA faixa AVALIAÇÃO A25:A45 — borda externa esquerda reaplicada
   como xlThin por Preencher_AplicarBordasCriticasAvaliacao →
   Preencher_AplicarBordaPretaContinua (.Weight = xlThin fixo). Se a regra
   visual final exigir Medium na lateral externa, a correção é code-only
   preservando internas Thin — NUNCA manual no template.
Escopo provável: src/vba/Preencher.bas + espelho local-ai/vba_import/
correspondente + teste V2 que cubra AMBAS as correções (knowledge 0010:
sem teste, a onda não fecha) + contratos HBN. Entregar pacote V3 delta para
importação manual. Gate humano: importar / compilar / TV2_RunImpressaoResidual
/ TV2_RunCanonica / RVS conforme exigido.

GATE 3 — ITERAÇÃO TELA A TELA (estabilização até o operador aprovar):
Loop com Mauricio: ele navega o sistema tela a tela e reporta cada defeito;
você responde com micro-ondas code-only (1 readback curto por lote de
correções da mesma tela), SEMPRE acompanhadas de teste V2 que capture a
regressão. Auditoria cruzada (2 IAs em CHAT NOVO, prompts do §12.B2 do
PROMPT_ARQUITETO; outputs em .hbn/proposals/NNNN-<ia>-<tema>.md, próximo NNNN
via ls; severidades BLOQUEADOR/FORTE/MARGINAL) é obrigatória a cada gate
relevante e sempre que houver mudança em lógica de serviço. O ciclo só
termina quando uma passada completa tela a tela fechar SEM defeito novo.

GATE 4 — FECHAMENTO V206 (sem freeze automático):
Com tela a tela limpo + TV2 suites + RVS verdes: proponha tag
v12.0.0206-base (âncora da V207) e AGUARDE decisão explícita de Mauricio.
Freeze é decisão humana, nunca sua.

V207: NÃO iniciar nada. As condições bloqueadoras C1-C5 estão em
auditoria/00_status/126_AUDITORIA_ARQUITETURAL_V207_OPUS48.md. Propostas
V207 são leitura, não execução.

NÃO tocar sem escopo explícito + hearback: Auto_Open.bas, Mod_Types.bas,
Importador_V3.bas, UserForms, .frx, Teste_V2_Engine.bas, Teste_V2_Roteiros.bas.
Auditorias externas coladas em chat são evidência auxiliar até virarem
artefato HBN (arquivo com frontmatter + vínculo a readback).

Handoff: ao chegar a 50% de contexto, execute o protocolo do knowledge 0014
(handoff + registro de bastão + proposta de evolução §7.3) e pare.

Comece agora: rode a validação de raiz, leia os 10 itens na ordem, e proponha
o readback 0149 do GATE 0. Não execute nada antes do hearback.

===FIM===
