---
titulo: State-report spec — Relato de Estado fixo (≤10 linhas) antes de todo bastão
diataxis: reference
status: accepted
temperatura: quente
id-global: 20260610-202750-fable-5-spec-state-report
path: core/state-report-spec.md
versao: 0.1.1   # FIX cross-audit 0030 F-02 (heading exato) + 0031 F-03 (parser do chapéu por campo)
data: 2026-06-10
autoria: claude-fable-5 (consolidação ADR-024)
hearback-status: confirmed
relacionado: [ADR-024 (Decisões 4 e 6), ADR-022, core/relay-spec.md (guard-state-fresh — o G-RLT o estende), core/pointer-spec.md, knowledge 0002]
---

# State-report spec

## §1 Forma fixa (≤10 linhas, ADR-022)

Impresso no chat E refletido no handoff antes de TODO bastão, qualquer
chapéu:

```
RELATO DE ESTADO — <apelido> · <chapeu_atual> · <created_at ISO8601>
STATE: ultima_atualizacao=<valor EXATO do arquivo> · bastão → <próximo dono> · contexto ~<n>% do threshold
SINAIS: <abertos novos/fechados nesta sessão; demais permanecem no STATE>
FEITO: <1 linha — entregável com status proposed/adotado>
PENDENTE: <1 linha — o que NÃO foi feito e onde está declarado>
PONTEIROS: <1+ linhas no formato da pointer-spec>
PRÓXIMA AÇÃO: <atômica; STRING IDÊNTICA ao proxima_acao do STATE>
PARA O HUMANO: <comando único + expectativa + fallback (knowledge 0002)>
```

## §2 Regras anti-teatro

1. Cada linha deriva de LER o STATE pós-atualização do disco — não da
   memória da sessão. A linha STATE cita o `ultima_atualizacao` EXATO:
   valor que só existe no arquivo novo; divergência denuncia relato de
   memória (ADR-020).
2. `PRÓXIMA AÇÃO` é igualdade EXATA de string com `STATE.proxima_acao` —
   não paráfrase.
3. `PONTEIROS` seguem a pointer-spec (gerados do disco).
4. Quando o chapéu é `conversacional-orquestrador`, o handoff
   correspondente contém a seção `## Decisões informais (cápsula)`
   (ADR-024 Decisão 6) — ainda que vazia com "nenhuma".

## §3 Relação com o guard-state-fresh

O `guard-state-fresh` (relay-spec) garante o STATE coerente com o handoff;
o G-RLT garante o RELATO coerente com o STATE. Juntos fecham o triângulo
chat × handoff × STATE.

## §4 Guard G-RLT (`assert-report-fresh`) — spec, FORA do runner

Gatilho: commit que toca handoff em `.hbn/messages/` (staged; HEAD em CI).

1. BLOQUEADOR: handoff sem bloco `RELATO DE ESTADO`.
2. BLOQUEADOR: `PRÓXIMA AÇÃO` do relato ≠ `proxima_acao` do STATE staged
   (`git show :.hbn/relay/STATE.md` — lição staged-skew).
3. BLOQUEADOR: `ultima_atualizacao` citado no relato ≠ o do STATE staged.
4. BLOQUEADOR: chapéu orquestrador sem o heading EXATO
   `^## Decisões informais \(cápsula\)$` no handoff — substring solta
   `(cápsula)` em qualquer linha NÃO satisfaz (cross-audit 0030 F-02).
   Header do relato fora da forma fixa §1 (chapéu não extraível por
   campo `·`) também BLOQUEIA (cross-audit 0031 F-03).
5. AVISO: bloco com >10 linhas (inflação de relato).

Casos de teste (estilo `guards/tests/run-guard-tests.sh`, repo git
descartável):

```
check "rlt: relato íntegro, proxima_acao idêntica, cápsula presente"   pass
check "rlt: handoff sem bloco RELATO DE ESTADO"                        block
check "rlt: proxima_acao parafraseada (≠ string do STATE)"             block
check "rlt: ultima_atualizacao de memória (≠ STATE staged)"            block
check "rlt: orquestrador sem seção cápsula"                            block
check "rlt: '(cápsula)' fora do heading exato (teatro)"                block  # 0030 F-02
check "rlt: STATE bom só na working tree; staged velho (skew)"         block
check "rlt: relato de 12 linhas"                                       pass-com-aviso
```

## §5 Relato de ENTRADA — rito de entrada checável (onda 0006 I-10; §5.3 do desenho)

O contrato do warm boot já existia em DOUTRINA
(`core/orchestrator-profile-spec.md` §3: a janela que entra LÊ o vigente).
Este parágrafo cria o lado CHECÁVEL — a regra mora aqui, e não no
orchestrator-profile, porque o relato de entrada é uma variante do Relato
de Estado e o G-RLT já é o guard desta spec (decisão registrada, I-10).

1. Handoff de ENTRADA de janela declara `tipo: entrada` no front-matter e
   contém o heading EXATO `## RELATO DE LEITURA`.
2. Sob o heading, UM item por artefato da read-list lida, e CADA item
   contém ≥1 citação `arquivo:linha` (padrão `path:NN`) — citação é a
   prova de leitura do disco (Truth Barrier; a regra que o Codex exerceu
   ao PARAR na referência quebrada 0019).
3. Enforcement: G-RLT regra 6 — `tipo: entrada` sem o heading = BLOQUEADOR;
   heading presente com item sem citação `arquivo:linha` = BLOQUEADOR;
   bloco vazio = BLOQUEADOR. Handoff sem `tipo: entrada` não é afetado
   (mudança mínima; o rito de saída segue §1-§4).

```
check "rlt: tipo entrada sem RELATO DE LEITURA"                        block
check "rlt: entrada com item sem citação arquivo:linha"                block
check "rlt: entrada íntegra (itens com arquivo:linha)"                 pass
```

## §6 Campo `bastao_token_sha256` — token de posse do bastão (onda 0006 I-13, v2)

O STATE pode declarar `bastao_token_sha256: <hex>` no front-matter: sha256
do TOKEN DE POSSE do bastão. O token é gerado pelo HUMANO
(`openssl rand -hex 16`), entregue SÓ à janela detentora, e vive APENAS no
arquivo local `.git/hbn-baton-token` (dentro de `.git/` — jamais
versionável por construção: o Git não rastreia o próprio `.git/`). O
SEGREDO NUNCA ENTRA NO HISTÓRICO: o commit carrega só o trailer
`HBN-Token-FP: <8 hex>` — fingerprint público (primeiros 8 hex do sha256
do token), que rastreia QUAL token assinou cada commit sem revelá-lo.

Com o campo presente (não-vazio), todo commit local exige, via guard
`assert-baton-token.sh` no hook commit-msg (instalação no header do guard;
hook TOLERANTE a guard ausente no worktree):

1. arquivo `.git/hbn-baton-token` presente, com sha256(conteúdo) igual a
   `bastao_token_sha256` do STATE STAGED (prova de posse);
2. trailer `HBN-Token-FP:` igual aos primeiros 8 hex do campo (rastro).

O QUE O G-TOK PROVA: que quem commitou tinha, naquele momento e naquele
clone, o arquivo de token entregue pelo humano. Replay por leitura do log
é impossível: o log só tem o fingerprint, e o fingerprint não abre o hook.

O QUE O G-TOK NÃO PROVA: (a) posse EXCLUSIVA — qualquer processo com
leitura de `.git/` na mesma máquina lê o token; (b) identidade do agente —
identidade é assunto do G-HRB/assinatura SSH (ADR-023), não deste guard;
(c) em CI (`HBN_DIFF_BASE`) prova apenas CONSISTÊNCIA do fingerprint de
cada commit do range com o hash do STATE em HEAD — o runner de CI não tem
(nem deve ter) o arquivo de token; rotação no meio de um push fará commits
pré-rotação reprovarem contra o hash de HEAD (limitação declarada).

Campo ausente ou VAZIO = exigência inativa (rampa de adoção; o hash entra
no STATE na CERIMÔNIA DE TOKEN, executada APÓS o último cherry-pick —
runbook da tabela de aprovação v2); `HBN_REQUIRE_BATON_TOKEN=1` (política
de CI) torna o campo obrigatório. ROTAÇÃO obrigatória a cada passagem de
bastão: arquivo novo + hash novo no MESMO commit do handoff (o token
antigo deixa de validar no instante em que o hash novo é staged).

```
check "tok: campo presente + ARQUIVO .git/hbn-baton-token ausente"     block
check "tok: arquivo com token ERRADO"                                  block
check "tok: fingerprint do trailer ≠ hash do STATE"                    block
check "tok: arquivo correto + fingerprint correto"                     pass
```
