---
titulo: Bootstrap de readback — abertura de onda safe_track sem burlar assert-scope-lock
data: 2026-05-26
autoria: claude-opus-4-7 (Onda 38.2.1)
aplica-a: Toda IA que abra readback safe_track sob o protocolo HBN com pre-commit `assert-scope-lock.sh`
revisar-em: 2026-08-26
---

# Bootstrap de readback — o problema da abertura

## Contexto

O guard `scripts/hbn-guards/assert-scope-lock.sh` (Onda 36, contratos
executáveis) elege o readback ATIVO como o último arquivo numérico em
`.hbn/readbacks/` e aplica duas regras:

1. Se `track == safe_track` e `human_status != confirmed` → **bloqueia
   o commit**, independente do que está staged.
2. Se `track == safe_track` e `human_status == confirmed` → bloqueia
   commit cujos arquivos staged escapem de `scope.files_allowed`.

A regra (1) protege contra execução prematura de onda sem hearback. É
correta para commits de **código de produção** (qualquer coisa em
`src/vba/` ou `local-ai/vba_import/`).

## O incidente bootstrap

Em 2026-05-26, durante a abertura da Onda 38.2.1 (Opus assumindo bastão
de Codex), surgiu o catch-22:

- IA cria `.hbn/readbacks/0105-onda38-2-1-revert-filtros-menu.json` com
  `human_status: pending` (correto: aguarda hearback humano).
- IA atualiza `.hbn/relay/INDEX.md` para flipar bastão e anunciar a
  onda (correto: torna a transferência pública).
- IA tenta committar esses 2 arquivos → guard bloqueia porque "ativo
  é 0105, track=safe_track, human_status=pending".
- Resultado: o readback que **define** a regra do escopo fica fora do
  git até o hearback chegar. O relay/INDEX no remoto continua
  apontando para o bastão anterior, possivelmente por horas/dias.

## Workaround usado nesta onda

Não committar a abertura. Deixar `readbacks/0105.json` e o diff do
`relay/INDEX.md` no working tree, apresentar ao operador o conteúdo em
chat, esperar hearback `confirmed`, atualizar `human_status` para
`confirmed` no JSON, e só então committar tudo junto (abertura +
execução).

**Custo:** o estado de "onda em revisão" não fica versionado. Em
sessões assíncronas (operador responde no dia seguinte), o repo no
remoto exibe estado inconsistente: relay/INDEX antigo, sem rastro
público do readback proposto.

## Diagnóstico

O guard atual não distingue dois tipos de commit safe_track:

| Tipo | Conteúdo staged | Decisão correta |
|---|---|---|
| **abertura** | só `.hbn/readbacks/NNNN-*.json` (próprio) + `.hbn/relay/INDEX.md` (bloco da própria onda) | **permitir** mesmo com `human_status: pending` |
| **execução** | qualquer arquivo de `scope.files_allowed` que não seja só os 2 acima | **bloquear** se `human_status != confirmed` |

Como o guard hoje só vê (track, human_status), ele aplica a regra mais
restritiva a ambos, colocando o operador num catch-22 lógico.

## Proposta de melhoria (versão protocolar)

Adicionar à `assert-scope-lock.sh`, antes da checagem (1):

```bash
# Excecao bootstrap: se TODOS os arquivos staged forem o readback ativo
# (proprio) ou .hbn/relay/INDEX.md, permite commit mesmo com pending.
STAGED_LIST="$(git diff --cached --name-only --diff-filter=ACMR)"
RB_BASENAME="$(basename "$ACTIVE_RB" .json)"
BOOTSTRAP_OK=1
while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    case "$f" in
        ".hbn/readbacks/${RB_BASENAME}.json") ;;
        ".hbn/relay/INDEX.md") ;;
        *) BOOTSTRAP_OK=0; break ;;
    esac
done <<< "$STAGED_LIST"

if [[ "$BOOTSTRAP_OK" == "1" && "$TRACK" == "safe_track" && "$HUMAN_STATUS" != "confirmed" ]]; then
    guard_ok "Bootstrap de readback: apenas readback proprio + relay/INDEX.md staged. Permitindo abertura PENDING."
    exit 0
fi
```

Riscos de adoção:

- **Risco:** alguém burla incluindo conteúdo malicioso no
  `relay/INDEX.md`. **Mitigação:** o relay tem revisão humana porque é
  lido no início de toda sessão; alterações fora do bloco da própria
  onda ficam visíveis no diff e são revertidas no hearback.
- **Risco:** o readback do bootstrap esquece de evoluir para `confirmed`
  e a execução é tentada com `pending`. **Mitigação:** o guard (1)
  continua valendo para o commit de execução; só a abertura é
  permitida.

## Alternativas avaliadas e descartadas

1. **`HBN_GUARDS_BYPASS=1` + nota em `.hbn/bypasses/`** — funciona mas
   deixa rastro de bypass para cada abertura de onda, o que polui a
   evidência. Bypass é para emergência, não para fluxo normal.
2. **Marcar abertura como `track: fast_track`** — mente sobre a
   natureza da onda. fast_track é doc-only; safe_track é
   código-de-produção. A onda em si é safe_track desde o primeiro
   bit.
3. **Criar `track: readback_open` novo** — duplica enum e exige
   migração de schema; pesado para o ganho.

## Quando aplicar esta lição

- IA aplicando: ao abrir qualquer readback safe_track novo, antes de
  pedir hearback, verificar se o repo tem o guard atualizado. Se
  ainda não tem, usar o workaround "deixar no working tree até
  hearback".
- Operador aplicando: revisar e mergear a melhoria proposta no
  `assert-scope-lock.sh` em ciclo de manutenção do protocolo HBN
  (não urgente, mas elimina fricção operacional recorrente).

## Lições paralelas relevantes

- `.hbn/knowledge/0013-contratos-executaveis.md` — origem dos guards.
- `.hbn/knowledge/0014-protocolo-fim-de-sessao.md` — handoff em
  transferência de bastão.

## Onda de origem

Onda 38.2.1 (Opus, 2026-05-26), bastão transferido provisoriamente
Codex → Claude Opus 4.7 para estabilização da V12.0.0206. Mauricio
pediu explicitamente em chat que esta observação fosse documentada
como lição para incorporação no protocolo HBN.
