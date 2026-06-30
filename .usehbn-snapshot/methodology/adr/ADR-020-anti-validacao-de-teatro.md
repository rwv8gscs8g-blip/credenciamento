---
adr-id: ADR-020
titulo: Anti-Validação-de-Teatro — guard só dá PASS sobre substância verificada, e nenhum guard ativa sem teste negativo verde
status: ACCEPTED
data-deposito: 2026-06-10
id-global: 20260610-64
path: methodology/adr/ADR-020-anti-validacao-de-teatro.md
autor: claude-fable-5 (arquiteto useHBN, corrente E)
cross-ia-required: Codex + Antigravity (endurece guards que eles mesmos auditaram — P10)
hearback-status: confirmado por Maurício (readback 0002, 2026-06-10)
prioridade: P0 (fecha a classe de bug provada pela auditoria cruzada 0021/0022)
temperatura: quente
tier-desta-mudanca: T2 (normativo — ADR + alteração de 3 guards + suite de testes)
aplica-a: todos os guards do protocolo, atuais e futuros
relacionado: [ADR-017 (freeze-gate), ADR-018 (role-family), ADR-011 (registry-line), .hbn/results/0021-cross-ia-codex-corrente-d.json (F-01..F-03), .hbn/results/0022-cross-ia-antigravity-corrente-d.md (F-01..F-03 + "validação de teatro"), guards/tests/run-guard-tests.sh]
evidencia-motivadora: |
  A auditoria cruzada da corrente D provou 3 bugs da MESMA classe: G-FAM
  aceitou hearback_ref apontando arquivo inexistente (exit 0); G-REG aprovou
  path não registrado por colisão de substring (grep -F); G-FRZ divergiu da
  spec no caso na-justificado. O Antigravity nomeou o risco: "validação de
  teatro" — o humano confia no ✓ da máquina enquanto a checagem valida FORMA
  (chave presente, substring casou), não SUBSTÂNCIA (arquivo existe, está
  confirmado, cobre a exceção). É a citação fantasma: referência formalmente
  perfeita para documento que não existe.

# ADR-020 — Anti-Validação-de-Teatro

## O problema, em linguagem humana

Um guard que passa sem verificar o que afirma verificar é PIOR que guard
nenhum: ele fabrica confiança. Sem guard, o humano confere; com guard de
teatro, o humano delega a um ✓ vazio. A Truth Barrier já proíbe a IA de
alegar "testado" sem evidência; este ADR aplica a mesma barreira aos
próprios guards.

## Decisão 1 — Truth Barrier para guards

Um guard só retorna PASS se verificou a SUBSTÂNCIA que afirma verificar.
Operacionalmente:

- Toda referência a artefato (`hearback_ref`, evidência, path citado) é
  DEREFERENCIADA: o arquivo existe, é legível, e o conteúdo satisfaz o
  contrato (ex.: `status: confirmed`).
- Casamento de path/linha é EXATO (coluna inteira de tabela, token
  delimitado) — nunca substring.
- "Cobre a exceção" é checagem estruturada, não presença de string: o
  hearback que cobre exceções declara `excecoes_cobertas` (lista), com
  entradas `{tipo: "familia", entre: [apelidoA, apelidoB]}` ou
  `{tipo: "papel", modelo: <apelido>, papel: <papel>}`. O guard exige a
  entrada exata; hearback confirmado SEM a entrada não cobre nada.

## Decisão 2 — Nenhum guard ativa sem teste negativo verde

Regra estrutural: NENHUM guard entra no runner (`hbn-guards-runner.sh`) sem
pelo menos um TESTE NEGATIVO verde — fixture que prova que ele BLOQUEIA o
caso ruim. Teste positivo sozinho é teatro de segunda ordem (prova que o
guard não atrapalha, não que protege). A suíte vive em `guards/tests/`
(`run-guard-tests.sh` + `fixtures/`), com, por guard: ≥1 caso-bom
(esperado: passa) e ≥1 caso-ruim (esperado: bloqueia). Ativação no runner
cita a saída verde da suíte como evidência no hearback — sem suíte verde, a
ativação é inválida mesmo com hearback.

## Decisão 3 — Aplicação imediata aos 3 bugs provados

- `assert-role-family.sh`: dereferencia `hearback_ref` (existe + status
  confirmed + `excecoes_cobertas` contém a exceção exata). Ref presente mas
  inválida = BLOQUEADOR, nunca fallback silencioso.
- `assert-registry-line.sh`: casamento exato de coluna no REGISTRY; cobertura
  ampliada para `core/*.md`, `.hbn/models/*.json`, `.github/workflows/*` e
  órfãos em `docs/prompts/`.
- `freeze-gate.sh`: critério `obrigatorio=true` com `status=na` passa SOMENTE
  se a justificativa cita hearback VERIFICÁVEL (arquivo existente,
  status confirmed) — alinhando guard×spec×schema no contrato da spec §2.4.

## Consequências

Positivas: a classe "✓ vazio" vira erro de teste, reproduzível por qualquer
auditor (`bash guards/tests/run-guard-tests.sh`); o custo de burlar um guard
sobe de "gerar string plausível" para "forjar artefato confirmado no repo" —
visível em diff. Negativas: guards ficam mais lentos (I/O de dereferência) e
mais estritos que o uso legado (linhas de REGISTRY combinadas não contam
como linha do artefato — 1 artefato por linha daqui pra frente); hearbacks
que cobrem exceção precisam do campo estruturado. Custo aceito: é
exatamente o atrito que separa evidência de teatro.

## DONE-check

`bash guards/tests/run-guard-tests.sh` verde, incluindo os 3 casos-ruins
históricos (hearback inexistente, substring de path, na-sem-hearback) — cada
um BLOQUEADO pelo guard endurecido.

## Versão

- v1.0 — 2026-06-10 — claude-fable-5, corrente E — depósito inicial.
- v1.1 — 2026-06-10 — codex, consolidação — ACCEPTED por hearback humano no readback 0002, sem ativar guards no runner.
