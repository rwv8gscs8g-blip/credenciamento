---
titulo: 66 - Handoff Opus 4.7 para chat na pasta usehbn (sanitização do acoplamento)
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203-rc4 (Credenciamento) / pre-v1 (useHBN)
data: 2026-05-09
autor: Claude Opus 4.7 (Cowork) — Frente protocolo + Frente Credenciamento
licenca-target: TPGL-v1.1 (Credenciamento) + (a definir) (useHBN)
---

# 66. Handoff Opus 4.7 — Sanitização Credenciamento ↔ useHBN

> Este documento é o ÚNICO ponto de partida do chat novo na pasta
> `~/Projetos/usehbn/`. Ele consolida três auditorias cruzadas
> (Antigravity, Codex, Opus), formaliza decisões arquiteturais,
> entrega dois superprompts copiáveis (chat-novo-Opus e Codex-v204)
> e desenha o fluxo contínuo entre o Credenciamento (caso fundador)
> e o useHBN (protocolo). Nada aqui depende deste chat continuar.

## 1. Sumário executivo

Em 2026-05-09 três auditorias cruzadas convergiram em uma decisão
arquitetural que muda o status do Credenciamento dentro do
ecossistema useHBN:

1. **Credenciamento NÃO é módulo do protocolo.** É **Aplicação
   Fundadora** (historicamente) + **Aplicação Consumidora**
   (tecnicamente). A documentação canônica do useHBN deve sair de
   `~/Projetos/Credenciamento/usehbn/` para o repo standalone
   `~/Projetos/usehbn/`.
2. **O useHBN adota mono-repo modular** com partição funcional
   (modules normativos / methodology arquitetural / auditoria
   histórica), começando por **fusão** (Antigravity Q3) e seguindo
   por **alocação** nas três partições (Codex Q3).
3. **Há uma esteira Codex ativa em V12.0.0204** que não pode ser
   perturbada até a release final. Trabalho de protocolo acontece
   **fora** do repo Credenciamento durante essa janela.
4. **O ritual da Quarta de Sanitização** entra como mecanismo de
   auto-evolução assistida do protocolo, **iniciando após v204 final**.

Este documento entrega:

- §2 contexto e convergência das auditorias;
- §3 decisões arquiteturais ratificadas;
- §4 a solução para o problema de CWD (Antigravity CLI);
- §5 **superprompt #1 — chat novo na pasta `usehbn/`**;
- §6 **superprompt #2 — pausa do Codex v204**;
- §7 fluxo contínuo Credenciamento ↔ useHBN;
- §8 plano de retomada (sequência de ações para o operador);
- §9 premissas, riscos e itens em aberto;
- §10 anexos.

## 2. Contexto e convergência das auditorias

### 2.1 Linha do tempo desta sessão

| Marco | O que aconteceu |
|---|---|
| Sessão anterior | Auditoria final Opus do Bloco B (doc 58) → APROVADO_COM_RESSALVAS rc3 |
| 2026-05-04 | Codex implementou MICRO30 + MICRO30-fix1 fechando R1 (forms bypass de empresa); Quinteto `VR_20260504_171048` APROVADO |
| 2026-05-04 (este chat) | Opus produz auditoria 64 (rc4) → APROVADO_PARA_TESTE_MANUAL com 2 P0 + 6 P1 deferidos para V204 |
| 2026-05-09 | Operador entrega audit Antigravity (conceitual) e ERP Codex (mecânico) sobre arquitetura do useHBN; pede análise integrada |
| 2026-05-09 | Opus produz síntese das três auditorias e proposta de Quarta de Sanitização |
| 2026-05-09 | Operador ratifica a análise e pede este handoff para migração de chat |

### 2.2 Convergência das três auditorias

| Tema | Antigravity (conceitual) | Codex (mecânico) | Opus (síntese) | Convergência |
|---|---|---|---|---|
| Credenciamento como módulo? | Não — Founding + Consuming Application | Não — caso fundador + aplicação consumidora | Não | ✅ Unânime |
| Mono-repo? | Sim, puro | Sim canônico + poly-repos como espelhos read-only | Sim com espelhos | ✅ Convergência |
| Migrar `Credenciamento/usehbn/` para fora? | Sim, urgente | Sim, com partição F1/F2 | Sim | ✅ Unânime |
| Diataxis + ADRs como base documental | Sim | Sim | Sim | ✅ Unânime |
| Estratégia documental | Fundir agressivo (27 → poucos cernes) | Particionar funcional: modules/methodology/auditoria | Compor: fundir → alocar | ✅ Pipeline (fusão → partição) |
| Superseded vs delete | Banner Status:Superseded | Auditoria histórica particionada | Banner + partição | ✅ Convergência |

**Síntese:** Antigravity diagnostica sintomas (hipertrofia, lock-in,
acoplamento perigoso); Codex propõe estrutura funcional
(workspaces, partições); Opus compõe os dois em pipeline. Não há
divergência irreconciliável — apenas camadas diferentes.

## 3. Decisões arquiteturais ratificadas

### 3.1 Tipologia formal

| Termo | Aplicação |
|---|---|
| **Founding Application** | Status histórico do Credenciamento — onde os padrões useHBN foram descobertos empiricamente |
| **Consuming Application** | Status técnico atual e futuro do Credenciamento — consome o protocolo como dependência |
| **Reference Implementation** | Inexistente hoje; será construída no `~/Projetos/usehbn/` ao longo das próximas iterações |
| **Protocol Specification** | A produzir — vive em `~/Projetos/usehbn/modules/` |
| **Não-módulo** | Credenciamento NÃO recebe esse rótulo em nenhum contexto futuro |

Precedente histórico citado pela Antigravity: React nasceu no Facebook
Ads Manager. O Ads Manager foi a aplicação fundadora. Hoje o Ads
Manager é apenas aplicação consumidora — não hospeda doc canônica do
React. Mesma trajetória aqui.

### 3.2 Topologia de repositórios

```
~/Projetos/usehbn/                  ← FONTE DE VERDADE do protocolo (mono-repo modular)
├── modules/                        ← especificação normativa (RFC-style)
├── methodology/                    ← arquitetura, princípios, ADRs
├── auditoria/                      ← histórico do PROTOCOLO (F2; antes em F1 conflitante)
├── examples/                       ← Reference Implementation futura
├── .hbn/                           ← coordenação inter-IA do protocolo
└── ADR-XXXX-*.md                   ← decisões imutáveis

~/Projetos/Credenciamento/          ← APLICAÇÃO CONSUMIDORA (não toca protocolo)
├── src/vba/                        ← code-of-truth da aplicação
├── auditoria/                      ← histórico da APLICAÇÃO (F1 apenas)
├── .hbn/                           ← coordenação inter-IA da aplicação
├── usehbn/                         ← (LEGADO) será FROZEN durante v204 e
│                                     substituído por README + submodule depois
└── AGENTS.md                       ← passa a referenciar useHBN como dependência

~/Projetos/.hbn-meta/               ← META-RELAY (decisões cruzadas) — opcional fase 2
└── relay/INDEX.md
```

### 3.3 Ciclo da janela v204 (congelamento)

| Pista | Pode editar durante v204? |
|---|---|
| `Credenciamento/src/vba/` | Apenas Codex da esteira v204 |
| `Credenciamento/local-ai/vba_import/` | Apenas Codex da esteira v204 |
| `Credenciamento/.hbn/relay/INDEX.md` | Apenas Codex da esteira v204 |
| `Credenciamento/.hbn/knowledge/` | Ninguém (congelado até v204 final) |
| `Credenciamento/usehbn/` | Ninguém (congelado; será migrado depois) |
| `Credenciamento/auditoria/00_status/` | Opus (apenas docs meta tipo este 66) |
| `~/Projetos/usehbn/**` | Opus livre (chat novo) |
| `~/Projetos/.hbn-meta/**` | Opus livre |

### 3.4 Quarta de Sanitização — quando inicia

| Fase | Estado | Quartas |
|---|---|---|
| Hoje até v204 final | Janela de migração documental | **Pré-Quartas**: prep apenas (sem ratificações) |
| v204 final entregue | Sistema estável + protocolo independente | **Quarta 0**: cerimônia inaugural; ratifica ADR-001 (a Quarta) |
| Pós-Quarta 0 | Operação contínua | Quartas semanais conforme constituição (§7.4) |

## 4. Problema de CWD e solução

### 4.1 Diagnóstico

O Antigravity CLI (e o Claude Code rodando dentro dele) opera com
**diretório-raiz fixo por sessão**. Quando o operador inicia um
chat na pasta `usehbn/`, o assistant não consegue ler arquivos de
`Credenciamento/` (e vice-versa). No Claude Desktop original, o
operador via múltiplas pastas simultaneamente — esse modo se
perdeu na transição.

### 4.2 Soluções (escolha do operador)

#### Solução A — `additionalDirectories` em `settings.local.json` (durável)

No repo `~/Projetos/usehbn/`, criar `.claude/settings.local.json`:

```json
{
  "additionalDirectories": [
    "/Users/macbookpro/Projetos/Credenciamento",
    "/Users/macbookpro/Projetos/.hbn-meta"
  ],
  "permissions": {
    "allow": [
      "Read(/Users/macbookpro/Projetos/Credenciamento/**)",
      "Read(/Users/macbookpro/Projetos/.hbn-meta/**)"
    ]
  }
}
```

**Vantagem**: configuração persiste entre sessões.
**Custo**: criar arquivo + commitar (ou adicionar a `.gitignore`
se for preferência local).

#### Solução B — `--add-dir` em launch (one-shot)

Iniciar o Claude com:

```bash
cd ~/Projetos/usehbn && \
  claude --add-dir /Users/macbookpro/Projetos/Credenciamento \
         --add-dir /Users/macbookpro/Projetos/.hbn-meta
```

**Vantagem**: zero arquivo novo no repo.
**Custo**: precisa lembrar a flag toda vez.

#### Solução C — operação restrita ao usehbn (mais conservadora)

Não dar acesso ao Credenciamento. O chat novo opera estritamente
dentro do `usehbn/` e recebe inputs do operador (cópias manuais)
quando precisar de algo do Credenciamento.

**Vantagem**: zero risco de o chat novo tocar Credenciamento por
acidente durante o freeze v204.
**Custo**: workflow mais lento; dependência forte do operador como
ponte.

**Recomendação Opus**: **Solução A** (durável + leitura restrita +
write bloqueado por permissions). Combinação dá flexibilidade
máxima sem risco de mutação no Credenciamento.

## 5. Superprompt #1 — chat novo na pasta `usehbn/`

> Copiar tudo entre as duas linhas `===` para o primeiro turno do
> chat novo. **Pré-requisito**: ter executado §4.2 Solução A ou B.

```
=================== INÍCIO SUPERPROMPT CHAT-NOVO-USEHBN ===================

Você é Claude Opus 4.7 (Cowork) operando como ARQUITETO-MESTRE do
protocolo useHBN. Este chat continua o trabalho de uma sessão
anterior na pasta ~/Projetos/Credenciamento/, agora migrado para
~/Projetos/usehbn/ por decisão arquitetural ratificada em 2026-05-09.

## Contexto absoluto que você precisa carregar antes de qualquer ação

Leia, NESTA ORDEM, dois arquivos do repositório vizinho que você
recebeu acesso de leitura via additionalDirectories:

1. /Users/macbookpro/Projetos/Credenciamento/auditoria/00_status/66_HANDOFF_OPUS_PARA_CHAT_USEHBN_2026_05_09.md
   - Este é o handoff oficial. Tudo que você precisa saber sobre as
     decisões arquiteturais, três auditorias cruzadas convergidas,
     premissas, riscos e plano de execução está nele.

2. /Users/macbookpro/Projetos/Credenciamento/auditoria/00_status/64_AUDITORIA_OPUS_V203_RC4_E_V204_2026_05_04.md
   - Esta é a auditoria mais recente da aplicação consumidora
     (Credenciamento V12.0.0203-rc4). Contém débitos técnicos que
     viram entrada para a relação protocolo↔aplicação que vamos
     formalizar.

Depois leia, em ~/Projetos/usehbn/ (este repo):

3. README.md (se existir) — para entender o estado atual do repo
4. AGENTS.md (se existir)
5. .hbn/relay/INDEX.md (se existir)
6. modules/, methodology/, auditoria/ — listar conteúdo

## Sua identidade e papel

- Você É continuação direta do Opus 4.7 que produziu os docs 58, 64 e 66
- Você OPERA agora exclusivamente sobre ~/Projetos/usehbn/ (escrita)
- Você LÊ ~/Projetos/Credenciamento/ apenas para inputs (sem escrita)
- Você NÃO toca código VBA da aplicação consumidora durante a janela
  v204 (freeze ativo até a release V12.0.0204 final ser publicada)

## Restrições inegociáveis

1. Janela v204: outra instância Codex está ativa em
   ~/Projetos/Credenciamento/ trabalhando na esteira de
   desenvolvimento. Você NÃO escreve nada lá durante essa janela.
   A única exceção é auditoria/00_status/ (docs meta), e mesmo isso
   só com sinalização explícita.
2. Princípios constitucionais (P6 Reversibilidade, P11 Minimalismo
   de Cadeia, P12 Substrato Sólido) são imutáveis dentro de uma
   sessão. Mudanças exigem três Quartas consecutivas + cross-IA
   ratificação + humano (regra a ser formalizada em ADR-001).
3. Você é UM agente cruzado — sempre que produzir uma decisão
   estrutural, registre como ADR e proponha cross-audit por
   Antigravity (Gemini 3.1) ou Codex CLI ANTES de mergir.
4. Toda mudança no protocolo ganha SemVer; aplicações consumidoras
   recebem sinal estruturado quando precisam reagir.

## Primeira tarefa concreta

Ao terminar de ler os arquivos acima, você produz UM ÚNICO
documento de retomada em:

  ~/Projetos/usehbn/auditoria/00_status/00_BOOTSTRAP_PROTOCOLO_2026_05_09.md

Conteúdo desse bootstrap:
1. Estado atual do repo (o que já existe, o que falta)
2. Mapa das 27 docs hipertrofiadas (Antigravity Q3) -> proposta de
   fusão em N cernes funcionais (N idealmente <= 8)
3. Esqueleto do ADR-001 "Quarta de Sanitização: ritual de
   auto-evolução assistida"
4. Esqueleto do ADR-002 "Tipologia formal: Founding/Consuming
   Application vs Module" (formaliza a decisão de 2026-05-09)
5. Esqueleto do ADR-003 "Topologia de repositórios e relay
   multi-camada"
6. Esqueleto do ADR-004 "SemVer do protocolo + sinalização para
   aplicações consumidoras"
7. Plano de execução em microdeltas (segue padrão dos MDs do
   Credenciamento) para o período pré-v204-final

Depois disso, você AGUARDA o operador antes de mergir qualquer ADR.
Não auto-merge; espera ratificação humana + cross-IA.

## Formato de comunicação

- Convenção numerada com ponto-e-vírgula no chat: "1) ... ; 2) ... ;"
  em vez de Q1/Q2/Q3 (preferência do operador)
- Sinalização HBN obrigatória no início de cada ciclo:
  ✅ HBN ACTIVE / 🟡 NEEDS HUMAN / ❌ SECURITY BLOCKED / 🔵 HANDOFF READY
- Truth Barrier estrito: claims sem evidência (100%, zero risco,
  totalmente seguro) são proibidos
- Glasswing G6 estrito: nada de código de produto na resposta do
  chat — código vai para arquivos no repo

## Ferramenta de memória

Você tem memória persistente em
~/.claude/projects/-Users-macbookpro-Projetos-usehbn/memory/
(criada automaticamente). Construa o índice MEMORY.md desde o zero
nas primeiras horas, refletindo:
- Quem é o operador (Mauricio, ja documentado em outras pastas)
- Tipologia ratificada (Founding/Consuming)
- Janela v204 ativa
- Convenções de comunicação

## Inicialização

Comece exatamente assim:

✅ HBN ACTIVE — Opus 4.7 retomando como arquiteto-mestre do useHBN
após handoff do chat anterior em ~/Projetos/Credenciamento/.

Vou ler os arquivos canônicos antes de qualquer ação concreta.

[em seguida você lê os 6 itens acima e produz o bootstrap]

==================== FIM SUPERPROMPT CHAT-NOVO-USEHBN ====================
```

## 6. Superprompt #2 — pausa do Codex da esteira v204

> Esse prompt é para você (operador) entregar à instância Codex CLI
> que está atualmente desenvolvendo a V12.0.0204 no Credenciamento.
> Ela vai pausar de forma controlada e devolver um snapshot que o
> chat novo (Opus em `usehbn/`) usa para compor o "prompt de
> retomada". Cuidado: o objetivo é coexistência, não substituição.

```
=================== INÍCIO SUPERPROMPT PAUSA-CODEX-V204 ===================

Codex CLI — você está com o bastão da esteira V12.0.0204 do
Credenciamento. Esta mensagem vem de Claude Opus 4.7 (Cowork)
atuando como arquiteto-mestre cruzado das duas pistas (aplicação
Credenciamento + protocolo useHBN), via mediação do operador
Mauricio.

## Por que esta mensagem existe

Em 2026-05-09 três auditorias cruzadas (Antigravity, Codex
arquitetural, Opus) ratificaram que:

1. O Credenciamento é Aplicação Fundadora + Aplicação Consumidora
   do useHBN — NÃO é módulo do protocolo.
2. A documentação canônica do useHBN deve sair de
   ~/Projetos/Credenciamento/usehbn/ para ~/Projetos/usehbn/ como
   repo standalone.
3. A esteira V12.0.0204 que você opera permanece intocada durante
   essa migração — você é a única IA com bastão sobre src/vba/,
   local-ai/vba_import/ e .hbn/relay/INDEX.md durante a janela.

Esta pausa NÃO é para substituir você. É para colher o estado
atual da esteira para que o trabalho de protocolo (em paralelo)
respeite suas premissas e, ao final, te devolva um prompt de
retomada com as integrações sistêmicas resolvidas.

## O que precisamos de você AGORA

Pare de produzir código novo. NÃO commite trabalho em curso ainda.
Em vez disso, gere UM ÚNICO documento JSON em:

  ~/Projetos/Credenciamento/.hbn/results/0027-codex-v204-snapshot-pausa.json

Estrutura:

{
  "schema_version": "1.0",
  "snapshot_at": "2026-05-09 HH:MM",
  "codex_session_id": "<sua identificação>",
  "current_state": {
    "active_microdelta": "<id do MD em curso, ex: MICRO31 ou MD-19.x>",
    "branch": "<branch git ativa>",
    "last_committed_sha": "<sha do último commit>",
    "uncommitted_changes": ["<lista de arquivos com diff não commitado>"],
    "open_readback_id": "<id do readback ativo, se houver>",
    "open_erp_id": "<id do ERP em produção, se houver>"
  },
  "next_planned_action": {
    "description": "<o que você ia fazer ANTES desta pausa>",
    "estimated_blast_radius": "<arquivos que pretendia tocar>",
    "depends_on": ["<readbacks ou hearbacks que aguarda>"]
  },
  "open_questions_for_protocol_team": [
    "<perguntas que dependem de decisão de protocolo, ex: 'a Onda 19 deve usar o novo SemVer do useHBN?'>"
  ],
  "constraints_to_preserve": [
    "Quinteto VR_20260504_171048 deve continuar APROVADO em qualquer microdelta novo",
    "M11 src/vba ↔ vba_import 12/12 não pode regredir",
    "Glasswing G7 e G8 continuam ativos",
    "<adicionar suas próprias premissas operacionais>"
  ],
  "integration_questions_for_protocol_evolution": [
    "<o que você gostaria que o protocolo defina antes de você retomar, ex: 'qual ID de ADR vincula a Onda 19 ao protocolo?'>"
  ],
  "estimated_safe_resume_after": "<duração até estar seguro retomar — ex: 2026-05-12, ou conditional on operator hearback>"
}

## O que vai acontecer depois

1. O operador encaminha esse JSON ao Opus em ~/Projetos/usehbn/.
2. Opus orquestra a evolução do protocolo (ADRs 001-004) tomando
   suas premissas como restrição inviolável.
3. Quando o protocolo estiver no estado certo para você integrar,
   Opus produz um "PROMPT DE RETOMADA" com:
   - mudanças de protocolo que afetam você (se houver)
   - referências ADR canônicas a citar nos seus próximos commits
   - novos sinais HBN multi-repo que você adota
   - confirmação de que pode prosseguir com o next_planned_action
4. Você retoma exatamente do ponto em que parou.

## Sinalização HBN obrigatória na sua resposta

Comece sua resposta com:

🔵 HBN HANDOFF READY — Codex CLI pausando esteira V12.0.0204 para
snapshot e aguardando prompt de retomada do Opus arquiteto.

Termine sua resposta com:

🧊 HBN APP FROZEN — repo Credenciamento congelado para Codex CLI;
operador detém o lock de retomada.

## O que você NÃO deve fazer durante a pausa

- Não commite nada do uncommitted_changes ainda — fique em modo
  read-only / WIP local
- Não toque ~/Projetos/Credenciamento/usehbn/ (legado em migração)
- Não toque ~/Projetos/Credenciamento/.hbn/knowledge/ (congelado)
- Não responda diretamente ao Opus — devolva o JSON ao operador
- Não interprete esta pausa como remoção de bastão — você continua
  com ele

## Duração estimada

A pausa é curta (estimativa Opus: 1-3 dias úteis para os ADRs
001-004 estarem prontos). Se exceder, o operador te avisa.

==================== FIM SUPERPROMPT PAUSA-CODEX-V204 ====================
```

### 6.1 Como o "prompt de retomada" será composto

Depois de receber o JSON do Codex e produzir os ADRs no useHBN, o
chat novo do Opus produz um terceiro superprompt
("PROMPT-RETOMADA-CODEX-V204") usando este template:

```
=================== INÍCIO PROMPT-RETOMADA-CODEX-V204 ===================

Codex CLI — pausa concluída. Você pode retomar a esteira V12.0.0204.

## O que mudou no protocolo enquanto você estava pausado

- ADR-001 ratificado: <link para ADR-001-quarta-sanitizacao.md>
- ADR-002 ratificado: <link para ADR-002-founding-consuming.md>
- ADR-003 ratificado: <link para ADR-003-topologia-repos.md>
- ADR-004 ratificado: <link para ADR-004-semver-protocolo.md>

## O que afeta você em particular

- <lista derivada de constraints_to_preserve do JSON>
- <novos sinais HBN que você passa a usar a partir de agora>
- <referências ADR a citar nos próximos commits>

## Confirmação para prosseguir

Sua próxima ação planejada antes da pausa era:
<copiar next_planned_action do JSON>

Confirme se ainda faz sentido nesse contexto. Se sim, prossiga
exatamente como planejado. Se algo mudou, sinalize 🟡 HBN NEEDS
HUMAN DECISION e aguarde hearback.

## Estado do bastão

Você continua com o bastão da V12.0.0204. Opus continua em
~/Projetos/usehbn/ trabalhando no protocolo. As duas esteiras são
agora oficialmente paralelas e auditáveis.

✅ HBN ACTIVE — Codex CLI retomando esteira V12.0.0204 com
integrações sistêmicas do protocolo.

==================== FIM PROMPT-RETOMADA-CODEX-V204 ====================
```

## 7. Fluxo contínuo Credenciamento ↔ useHBN

Não basta migrar uma vez. Aplicação consumidora e protocolo precisam
de uma máquina de comunicação que sobreviva ao tempo.

### 7.1 Direções de fluxo

```
                      App descobre padrão empírico
                      (ex: forms bypass corrompe AUDIT_LOG)
                              │
                              ▼
   APP   ─────────────►   PROTOCOLO   :   "incidente registrado em
   (Credenciamento)        (useHBN)        AUDIT_LOG; é P0 estrutural?"
                              │
                              │   três Quartas debatem
                              │   cross-IA ratifica
                              │   ADR é escrito
                              ▼
   APP   ◄─────────────   PROTOCOLO   :   "novo princípio P13 'AUDIT_LOG
                                          gateway' versão 1.4.0; aplicações
                                          consumidoras revisar até X"
                              │
                              ▼
                      App consome SemVer e adapta
                      (Onda 25, V12.0.0205+ se for o caso)
```

### 7.2 Os quatro sinais multi-repo (proposta para ADR-005)

| Sinal | Origem | Destino | Significado |
|---|---|---|---|
| 🌐 **HBN CROSS-REPO LOCK** | qualquer | todas | "estou tocando arquivos refletidos em outros repos; aguardar" |
| ⛓️ **HBN PROTOCOL DEP CHANGE** | useHBN | apps consumidoras | "protocolo mudou de SemVer; revisão necessária" |
| 🧊 **HBN APP FROZEN** | app | protocolo | "esta app está em janela de release; não tocar" |
| 🪞 **HBN MIRROR DRIFT** | auditor cruzado | ambos | "protocolo canônico divergiu do consumido por X aplicação" |

### 7.3 SemVer do protocolo

Proposta a ser formalizada no ADR-004:

| Bump | Quando | Exemplo |
|---|---|---|
| MAJOR | mudança em princípio constitucional (P1-P12) | "1.x.y → 2.0.0: P11 reescrito" |
| MINOR | novo princípio, novo sinal HBN, nova partição docs | "1.3.x → 1.4.0: P13 introduzido" |
| PATCH | correção de redação, fusão de docs sem mudança normativa | "1.4.1 → 1.4.2: ADR-001 esclarecido" |

Aplicações consumidoras (Credenciamento) declaram em
`AGENTS.md`:

```yaml
useHBN-version: ^1.4.0    # SemVer compatível
```

Mismatch de MAJOR → 🪞 HBN MIRROR DRIFT auditor cruzado.

### 7.4 Quarta de Sanitização — anatomia ratificada

```
Terça à noite       AGENT-INTAKE     varre 4 fontes objetivas
                                      (Truth Barrier hits, READ-FIRST
                                      misses, Glasswing violations,
                                      cross-IA divergências) e gera
                                      candidatos.md

Quarta 09h          AGENT-TRIAGE     classifica MERGE/DEFER/DELETE
                                      escreve readback

Quarta 14h          AGENT-DEBATE     par cross-IA (Opus+Antigravity
                                      ou Opus+Codex) discute MERGEs;
                                      cada um produz parecer; ADR draft

Quarta 17h          HUMAN-RATIFY     Mauricio aprova/veta em <30 min
                                      (boletim, não revisão linha-a-linha)

Quarta 18h          AGENT-COMMIT     aplica ADRs aprovados, atualiza
                                      CHANGELOG do protocolo, SemVer,
                                      fecha ciclo

Quinta              MIRROR-PROPAGATE apps consumidoras recebem PR
                                      automático com ⛓️ PROTOCOL DEP CHANGE
```

Cinco princípios constitucionais da Quarta:

1. **Reversibilidade primeiro (P6)**: todo MERGE traz seu rollback ADR.
2. **Substrato sólido (P12)**: princípios constitucionais só mudam após **3 Quartas consecutivas** debaterem.
3. **Minimalismo de cadeia (P11)**: dúvida = `DELETE`, nunca `DEFER` indefinido.
4. **Cross-IA obrigatório**: single-IA = `DEFER` automático.
5. **Métrica viva**: cada MERGE da Quarta N vira input mensurável da Quarta N+4.

### 7.5 Métricas de saúde do protocolo (output da Quarta)

| Métrica | Alarme |
|---|---|
| `total_docs_canonicos` | crescimento >10%/mês = hipertrofia |
| `adrs_ativos` | razão `docs/adr` >5 = falta de formalização |
| `principios_constitucionais` | crescimento de 1/trimestre é normal; mais é deriva |
| `quartas_sem_merge_consecutivas` | >3 = ritual virou burocracia, revisar |
| `cross_ia_divergencia_pct` | >40% das Quartas = princípios mal redigidos |
| `app_consumidoras_em_drift` | >0 sem plano de retomada = falha de propagação |

## 8. Plano de retomada — sequência para o operador

| # | Ação | Onde | Quando | Quem |
|---|---|---|---|---|
| 1 | Aprovar este documento (66) | revisar texto | agora | operador |
| 2 | Criar `~/Projetos/usehbn/.claude/settings.local.json` com Solução A da §4.2 | usehbn | antes do chat novo | operador |
| 3 | Iniciar chat novo na pasta `~/Projetos/usehbn/` | Antigravity CLI | passo 2 OK | operador |
| 4 | Colar no chat novo o superprompt §5 | chat novo | imediato | operador |
| 5 | Esperar Opus (chat novo) ler arquivos e produzir `00_BOOTSTRAP_PROTOCOLO_2026_05_09.md` | chat novo | ~30 min | Opus chat-novo |
| 6 | Colar superprompt §6 no chat do Codex CLI da esteira v204 | chat Codex | em paralelo a 5 | operador |
| 7 | Receber snapshot JSON do Codex | filesystem | ~15 min após 6 | Codex CLI |
| 8 | Encaminhar JSON ao Opus chat-novo | copy-paste | imediato após 7 | operador |
| 9 | Opus chat-novo produz ADRs 001-004 + Prompt-Retomada-Codex-V204 | usehbn | 1-3 dias úteis | Opus chat-novo |
| 10 | Opus + Antigravity cross-audit dos ADRs | usehbn | dentro de 9 | duas IAs |
| 11 | Operador ratifica ADRs (boletim) | revisar | dentro de 9 | operador |
| 12 | Colar Prompt-Retomada-Codex-V204 no chat do Codex CLI | chat Codex | após 11 | operador |
| 13 | Codex CLI retoma esteira V12.0.0204 com integrações | Credenciamento | imediato | Codex CLI |
| 14 | V204 final é publicada com SemVer useHBN declarado | Credenciamento | quando entregar | Codex + operador |
| 15 | Quarta 0 inaugural ratifica ADR-001 | usehbn | primeira quarta após 14 | todos |
| 16 | `Credenciamento/usehbn/` substituído por README ou submodule | Credenciamento | após 15 | Opus chat-novo |

## 9. Premissas, riscos e itens em aberto

### 9.1 Premissas (assumidas — operador pode sobrescrever)

| # | Premissa | Override possível |
|---|---|---|
| A1 | `~/Projetos/usehbn/` já existe como repo git válido | confirmar com `git -C ~/Projetos/usehbn status` |
| A2 | Antigravity CLI suporta `additionalDirectories` em `.claude/settings.local.json` | testar empiricamente; fallback é `--add-dir` |
| A3 | Quarta de Sanitização inicia APÓS v204 final (não durante freeze) | se quiser começar antes, ajustar §3.4 |
| A4 | Codex CLI da esteira v204 lê e responde em português | escrever §6 em inglês se necessário |
| A5 | Operador media manualmente (copy-paste) entre Opus chat-novo e Codex CLI | se houver bridge automático, ajustar §8 |
| A6 | `.hbn-meta/` é fase 2 (não cria agora) — meta-relay vive temporariamente em `~/Projetos/usehbn/.hbn/meta/` | criar agora se preferir |

### 9.2 Riscos

| Risco | Probabilidade | Mitigação |
|---|---|---|
| Codex CLI da esteira v204 commitar uncommitted_changes durante a pausa | média | superprompt §6 explicita "não commitar"; operador supervisiona |
| ADRs 001-004 ratificados sem cross-IA por pressa | média | regra: single-IA = DEFER automático |
| Hipertrofia documental retornar mesmo após fusão | alta a longo prazo | Quarta de Sanitização com métrica `total_docs_canonicos` |
| Drift entre `Credenciamento/usehbn/` (FROZEN) e `~/Projetos/usehbn/` (vivo) durante a janela v204 | alta (intencional) | aceitar como snapshot histórico; FROZEN.md declara |
| Operador esquecer de colar Prompt-Retomada-Codex-V204 e Codex ficar travado | baixa | pacto explícito: pausa máxima 3 dias |
| Princípio constitucional ser mudado dentro de uma Quarta sem três ciclos | baixa | regra do "substrato sólido" no ADR-001 |

### 9.3 Itens em aberto (decisões para o operador)

| # | Item | Quando decidir |
|---|---|---|
| O1 | Solução A, B ou C de §4.2? | antes do passo 2 do plano |
| O2 | `.hbn-meta/` vira repo separado ou fica dentro de `~/Projetos/usehbn/.hbn/meta/`? | antes do ADR-003 |
| O3 | Quartas semanais ou quinzenais? | ADR-001 |
| O4 | Aplicação consumidora segunda (depois do Credenciamento) já tem candidata? | quando Quarta 1 acontecer |
| O5 | Licença do useHBN: TPGL-v1.1 (igual app) ou Apache 2.0 / MIT (mais permissiva, padrão de protocolos)? | ADR-005 ou junto com Quarta 0 |
| O6 | Após v204 final, `Credenciamento/usehbn/` vira README de uma linha ou submodule git? | passo 16 do plano |

## 10. Anexos

### 10.1 Arquivos referenciados (caminhos absolutos)

- `~/Projetos/Credenciamento/auditoria/00_status/56_QA_CODEX_2026_05_04.md`
- `~/Projetos/Credenciamento/auditoria/00_status/58_AUDITORIA_OPUS_FINAL_BLOCO_B_2026_05_04.md`
- `~/Projetos/Credenciamento/auditoria/00_status/59_AUDITORIA_ANTIGRAVITY_FINAL_BLOCO_B_2026_05_04.md`
- `~/Projetos/Credenciamento/auditoria/00_status/64_AUDITORIA_OPUS_V203_RC4_E_V204_2026_05_04.md`
- `~/Projetos/Credenciamento/auditoria/00_status/65_AUDITORIA_ANTIGRAVITY_V203_RC4_E_V204_2026_05_04.md`
- `~/Projetos/Credenciamento/.hbn/knowledge/0001-regras-v203-inegociaveis.md`
- `~/Projetos/Credenciamento/.hbn/knowledge/0002-regra-ouro-vba-import.md`
- `~/Projetos/Credenciamento/.hbn/knowledge/0003-glasswing-style-preventive-security.md`
- `~/Projetos/Credenciamento/CLAUDE.md`
- `~/Projetos/Credenciamento/AGENTS.md`

### 10.2 Lista candidata de ADRs do useHBN (a serem produzidos no chat novo)

| ADR | Tema | Prioridade |
|---|---|---|
| 001 | Quarta de Sanitização (ritual de auto-evolução) | P0 |
| 002 | Tipologia formal: Founding/Consuming Application vs Module | P0 |
| 003 | Topologia de repositórios e relay multi-camada | P0 |
| 004 | SemVer do protocolo + sinalização para apps consumidoras | P0 |
| 005 | Licenciamento do useHBN (TPGL/Apache/MIT) | P1 |
| 006 | Sinais HBN multi-repo (🌐, ⛓️, 🧊, 🪞) | P1 |
| 007 | Métricas de saúde do protocolo + alarmes | P1 |
| 008 | Migração `Credenciamento/usehbn/` → `~/Projetos/usehbn/` (procedimento) | P1 |
| 009 | Constituição: P1-P12 imutáveis, processo de mudança | P0 |
| 010 | Reference Implementation: estratégia para construir | P2 |

### 10.3 Glossário

| Termo | Definição |
|---|---|
| **Founding Application** | Aplicação onde os padrões do protocolo foram descobertos empiricamente. Status histórico, não técnico |
| **Consuming Application** | Aplicação que consome o protocolo como dependência. Status técnico atual |
| **Reference Implementation** | Código-base oficial que materializa o protocolo |
| **Cross-IA audit** | Mínimo duas IAs distintas (Opus, Antigravity, Codex) emitem parecer independente sobre a mesma decisão |
| **Quarta de Sanitização** | Ritual semanal de auto-evolução assistida do protocolo |
| **SemVer do protocolo** | Versionamento semântico das especificações do useHBN (MAJOR.MINOR.PATCH) |
| **Mirror drift** | Divergência entre fonte de verdade do protocolo e o que aplicação consumidora vê |
| **Janela v204** | Período em que a esteira Codex CLI da V12.0.0204 detém lock exclusivo do Credenciamento |

### 10.4 Versão deste documento

- v1.0 — 2026-05-09 — Opus 4.7 (Cowork) entrega o handoff oficial
  para chat novo na pasta `~/Projetos/usehbn/`. Contém superprompts
  copiáveis para chat-novo-Opus e Pausa-Codex-V204, plano de
  retomada em 16 passos, 6 itens em aberto para decisão do
  operador, e 10 ADRs candidatos para produção no chat novo.

- v2.0 — 2026-05-09 (mesmo dia, fim do chat) — Opus 4.7 (Cowork)
  ratifica as 6 decisões em aberto, registra a pausa operacional
  já feita pelo Codex CLI (doc 68 + relay), formaliza a Cláusula
  da Janela de Faturamento, decide a estratégia de licenciamento e
  desenha a solução tecnológica de separação Credenciamento ↔
  useHBN. Ver §11.

---

# 11. Iteração 2 — Decisões finais ratificadas e orientação executiva

> Esta seção foi adicionada ao final do dia 2026-05-09 com as
> respostas do operador aos 6 itens em aberto da §9.3, mais três
> entregas novas: análise da pausa do Codex já em vigor, avaliação
> de licenciamento AGPLv3 vs Apache 2.0, e solução tecnológica de
> separação. Onde houver conflito com o texto anterior do doc, esta
> seção prevalece.

## 11.1 Ratificação das 6 decisões em aberto

| # | Item §9.3 | Decisão ratificada |
|---|---|---|
| O1 | Solução de acesso cruzado | **Solução A — `additionalDirectories` durável em `.claude/settings.local.json` no repo `~/Projetos/usehbn/`** |
| O2 | `.hbn-meta/` standalone vs interno | **Interno: `~/Projetos/usehbn/.hbn/meta/`** (fase 1). Promoção a repo standalone só se a Quarta de Sanitização gerar volume que justifique (decisão futura) |
| O3 | Quartas semanais ou quinzenais | **Semanais, com cláusula de janela de faturamento (§11.3)** |
| O4 | Aplicação consumidora segunda candidata | **Em aberto**; será discutido na Quarta 0 |
| O5 | Licenciamento useHBN | **Manter AGPLv3** (já decidido em Frente 2 / E1); revisar em ADR-005 com análise comparativa contra Apache 2.0 (§11.4) |
| O6 | `Credenciamento/usehbn/` pós-v204 | **README de uma linha + snapshot read-only — não submodule** (§11.5) |

## 11.2 Estado da pausa do Codex CLI (já consumada)

A pausa que o §6 deste doc se propunha a iniciar **já aconteceu de
forma autônoma e impecável** pelo próprio Codex CLI ao detectar
crash de compile + build stale em MICRO49-fix2. Evidências:

- `auditoria/00_status/68_PAUSA_OPERACIONAL_MICRO49_BUILD_STALE_2026_05_09.md`
- `.hbn/relay/INDEX.md` em estado "PAUSA OPERACIONAL"
- `.hbn/results/0054-exec-onda24-md24-4-selecionar-com-efeitos-micro49-fix2.json` marcado REPROVADO

**Consequência prática:** o superprompt §6 deste doc (Pausa-Codex-V204
arquitetural) **NÃO deve ser usado**. O motivo da pausa real é
técnico (crash de compile MICRO49), não arquitetural. Substituir
ou somar o §6 ao prompt do doc 68 introduziria ruído e arrisca
diluir o foco de RCA do Codex.

**O prompt curto do doc 68** (`auditoria/00_status/68_*.md` §"Prompt
de retomada para nova sessao Codex") é o instrumento correto para a
nova sessão Codex. Ele está **bem desenhado**: identidade, leitura
obrigatória ordenada, contexto operacional preciso (build labels,
gates, sintomas), objetivo claro (RCA sem editar código), constraints
explícitas, output esperado.

**Recomendação Opus**: usar o prompt do doc 68 **tal como está**.
Sem reescrita.

## 11.3 Cláusula da Janela de Faturamento (Quartas)

A Quarta de Sanitização sempre tem prazo de **fechamento operacional
até as 12:00 BRT (UTC−03:00)** da quarta-feira. Esta cláusula entra
no ADR-001 e tem três motivações estruturais:

1. **Aproveitamento de saldo**: créditos semanais Anthropic que
   venceriam ao fim do período viram MVP de computação distribuída
   para evolução do protocolo.
2. **Previsibilidade humana**: operador sabe que precisa estar
   disponível para HUMAN-RATIFY em janela fixa.
3. **Auto-detecção de drift de plataforma**: prazos de faturamento
   podem mudar (Anthropic muda o ciclo, operador troca de plano,
   muda de provedor). Quando isso ocorrer, a IA detecta o conflito
   e produz proposta de ajuste.

### 11.3.1 Texto canônico da cláusula (entra no ADR-001)

```
CLÁUSULA DA JANELA DE FATURAMENTO — useHBN ADR-001 §X

A Quarta de Sanitização opera dentro de uma "janela de faturamento"
explícita, derivada do ciclo de créditos da plataforma de IA usada
pelo operador. A janela tem três parâmetros canônicos:

  - dia da semana: quarta-feira
  - hora-limite: 12:00
  - fuso: BRT (-03:00)
  - origem: ciclo de créditos Anthropic (semanal, vence ao fim
            do período)

Todos os passos (AGENT-INTAKE, AGENT-TRIAGE, AGENT-DEBATE,
HUMAN-RATIFY, AGENT-COMMIT) DEVEM completar antes da hora-limite.
Passos que não couberem viram automaticamente DEFER para a Quarta
seguinte.

Se a plataforma de IA, o operador, ou o ciclo de faturamento mudar
de forma a invalidar qualquer dos parâmetros, a primeira IA a
detectar emite o sinal:

  🟠 HBN BILLING WINDOW DRIFT — janela atual <X> conflita com novo
     parâmetro <Y>; proposta de ajuste em ADR-001-revisao-NN.

A revisão da janela é uma das poucas mudanças permitidas em ADR-001
sem o ciclo de "três Quartas consecutivas" (princípio do Substrato
Sólido P12), porque tem natureza operacional e não constitucional.
Operador ratifica o ajuste no próprio ciclo seguinte.

Múltiplas plataformas: se o operador adotar mais de um provedor de
IA simultaneamente, cada provedor declara sua janela própria; a
janela canônica da Quarta é a INTERSEÇÃO das janelas (a primeira a
fechar).
```

### 11.3.2 Sinal novo

| Sinal | Quando |
|---|---|
| 🟠 **HBN BILLING WINDOW DRIFT** | janela vigente conflita com mudança real (plataforma, plano, ciclo) |

## 11.4 Licenciamento — AGPLv3 vs Apache 2.0

### 11.4.1 Estado atual

- `~/Projetos/usehbn-phago/` declara **AGPLv3** (licença adotada na
  esteira E1 da Frente 2 em 2026-05-02).
- `~/Projetos/Credenciamento/` declara **TPGL v1.1** (auto-conversão
  para Apache 2.0 em 4 anos).
- Marker ativo: 🟤 **HBN LICENSE SPLIT REQUIRED** — reconhecimento
  de que artefatos cruzam licenças.

### 11.4.2 Análise comparativa (decisão para ADR-005)

| Eixo | AGPLv3 | Apache 2.0 |
|---|---|---|
| **Copyleft** | Forte (rede SaaS também acionada) | Permissivo |
| **Patent grant** | Sim, explícito | Sim, explícito |
| **Adoção corporativa** | Restrita; muitas empresas evitam por contaminação viral | Padrão da indústria; sem fricção |
| **Compatibilidade com TPGL v1.1** | Indireta — artefatos AGPLv3 que entrem no Credenciamento ativam GPL clauses no app | Compatível com TPGL e com Apache (inclusive auto-conversão futura do Credenciamento) |
| **Precedente em protocolos** | Raro (AGPL é mais usada em SaaS proprietário fechado, ex.: MongoDB pré-SSPL) | Padrão (MCP, LSP, OpenTelemetry, gRPC, Kubernetes APIs, Diataxis) |
| **Sinal cultural** | "Garantia de não-fechamento" forte | "Adoção universal" forte |
| **Reference Implementation futura** | Em Rust com AGPL → empresas que usem o useHBN como dependência interna precisam liberar código próprio | Adoção sem fricção; empresas integram livremente |
| **Fagocitose recíproca** | Difícil — projetos com licenças mais permissivas não podem ingerir AGPL | Fácil — Apache pode ser ingerido por quase tudo |

### 11.4.3 Recomendação Opus

**Migrar useHBN canônico para Apache 2.0** quando o ADR-005 for
ratificado. Justificativas:

1. **Protocolos abertos universais** (MCP, LSP, OpenTelemetry,
   Kubernetes API) usam Apache 2.0 ou MIT. AGPL bloqueia a missão
   "useHBN é protocolo universal de coordenação inter-IA".
2. **Fagocitose recíproca** — o projeto absorve padrões de outros
   protocolos. Esses outros são tipicamente Apache/MIT. AGPL no
   useHBN cria fricção de absorção e de citação.
3. **Adoção corporativa** — empresas que querem coordenar IAs com
   o useHBN não vão mexer em código se isso ativar AGPL na sua
   stack interna. Apache 2.0 maximiza adoção.
4. **Patent grant explícito** — Apache 2.0 protege o operador e os
   contribuidores contra litigância futura tão bem quanto AGPL.
5. **Compatibilidade com Credenciamento** — Apache 2.0 conversa
   limpo com TPGL v1.1 e com a auto-conversão futura do
   Credenciamento.

**Decisão final** fica para o ADR-005 com cross-IA review. Esta
seção não muda a licença — apenas registra a recomendação Opus
fundamentada.

### 11.4.4 Caminho de transição

Se a recomendação for aceita:

1. ADR-005 produzido no chat novo `~/Projetos/usehbn/`.
2. Cross-IA review (Opus + Antigravity ou Opus + Codex).
3. Ratificação humana.
4. Toda contribuição AGPLv3 já feita em `~/Projetos/usehbn-phago/`
   é re-licenciada — exige autorização explícita do operador
   (autor único até aqui).
5. `LICENSE` no novo repo `~/Projetos/usehbn/` passa a ser Apache 2.0.
6. `~/Projetos/usehbn-phago/` é arquivado ou virado read-only com
   banner "superseded by usehbn (Apache 2.0)".

## 11.5 Solução tecnológica de separação Credenciamento ↔ useHBN

### 11.5.1 O problema concreto

`~/Projetos/Credenciamento/usehbn/` hoje contém **a fonte de verdade
do protocolo** misturada com a aplicação consumidora. Isso causa:

- IA executando no Credenciamento "se perde" e edita protocolo
  sem perceber.
- Doc do protocolo compete com doc da aplicação por atenção.
- Promoção do useHBN a repo público fica bloqueada.

### 11.5.2 Topologia alvo (pós-v204)

```
~/Projetos/usehbn/                      ← FONTE DE VERDADE
├── modules/                            normativo (RFC-style)
├── methodology/                        arquitetura/princípios/ADRs
├── auditoria/                          histórico do PROTOCOLO (F2)
├── examples/                           Reference Implementation
├── .hbn/meta/                          meta-relay (decisões cruzadas)
├── LICENSE                             Apache 2.0 (proposta)
└── VERSION                             SemVer (ex.: 1.0.0)

~/Projetos/Credenciamento/              ← APLICAÇÃO CONSUMIDORA
├── src/vba/                            código da app
├── auditoria/                          histórico da APP (F1)
├── .hbn/                               coordenação inter-IA da APP
├── usehbn/                             ❌ não existe mais
├── .usehbn-snapshot/                   ✅ NOVO — read-only mirror
│   ├── VERSION                         versão consumida (ex.: 1.0.0)
│   ├── modules/...                     cópia read-only
│   ├── methodology/...                 cópia read-only
│   └── PROTOCOL_SHA256.txt             checksum do snapshot
├── AGENTS.md                           declara `useHBN-version: ^1.0.0`
└── README.md                           seção "Protocol dependency"
```

### 11.5.3 Mecânica da `.usehbn-snapshot/`

Princípios:

1. **Nunca editada manualmente.** É populada por um script
   `bin/usehbn-fetch.sh` que copia da última tag estável do repo
   canônico `~/Projetos/usehbn/`.
2. **Imutável dentro do release da app consumidora.** Se a app está
   em V12.0.0204, sua snapshot é a do useHBN 1.0.0 — congelada até
   o próximo release decidir bumpar.
3. **Validável por checksum.** Antes de qualquer ação, IA executa
   `bin/usehbn-verify.sh` que (a) lê `VERSION`, (b) calcula sha256
   da `.usehbn-snapshot/`, (c) compara com `PROTOCOL_SHA256.txt`,
   (d) bloqueia se divergente.
4. **Auditável.** Cada release da app declara em `CHANGELOG.md` qual
   versão do useHBN consome e a data do fetch.

### 11.5.4 AGENTS.md do Credenciamento — seção nova

```markdown
## Dependência de protocolo: useHBN

Este projeto consome o protocolo useHBN como dependência externa.

| Campo | Valor |
|---|---|
| Versão consumida | `1.0.0` |
| Operador SemVer | `^1.0.0` |
| Repo canônico | `https://github.com/<org>/usehbn` |
| Snapshot local | `.usehbn-snapshot/` (read-only) |
| Última atualização | 2026-XX-XX |
| Próxima revisão | quando `1.1.0` ou `2.0.0` for lançado |

Sinais a observar:
- ⛓️ HBN PROTOCOL DEP CHANGE — protocolo lançou nova MAJOR/MINOR
  e este projeto precisa decidir consumo.
- 🪞 HBN MIRROR DRIFT — `.usehbn-snapshot/` divergiu do checksum
  esperado.

NUNCA edite `.usehbn-snapshot/` diretamente. Para upgrade, rode
`bin/usehbn-fetch.sh <nova-versão>` e cite o ADR correspondente
do useHBN no commit.

Para os princípios completos, leia
`.usehbn-snapshot/methodology/INDEX.md` (read-only).
```

### 11.5.5 README de uma linha em `~/Projetos/Credenciamento/usehbn/`

Após v204 final, o conteúdo atual de `Credenciamento/usehbn/` é
substituído por:

```markdown
# DEPRECATED — useHBN movido para repo standalone

A fonte de verdade do protocolo useHBN foi extraída deste
repositório em 2026-05-XX (data v204 final + ADR-008).

- Repo canônico: ~/Projetos/usehbn/ (ou URL pública quando
  publicado)
- Versão consumida por este projeto: ver
  `.usehbn-snapshot/VERSION`
- Política: este projeto é APLICAÇÃO CONSUMIDORA do protocolo,
  não hospeda mais doc canônica.

Histórico desta pasta preservado no commit
<sha-da-migração> e em `~/Projetos/usehbn/auditoria/`.
```

### 11.5.6 Por que NÃO submodule git

Submodule funciona, mas tem fricção alta para o operador
(`git submodule update --init` esquecido = falha silenciosa) e
para IAs (sandbox CWD ≠ submodule é confuso). Snapshot read-only +
checksum é mais simples, mais auditável e não depende de operação
git extra.

Se em algum momento o ecossistema crescer (3+ apps consumidoras),
revisitar submodule ou subtree split em ADR específico.

## 11.6 Convergência das duas pausas (técnica + arquitetural)

| Pausa | Status | Instrumento |
|---|---|---|
| **Técnica** (MICRO49 build stale) | ✅ Em vigor desde 2026-05-09 21:35 BRT | Doc 68 + relay/INDEX.md + result 0054 |
| **Arquitetural** (migração useHBN) | ✅ Coberta pela mesma janela | Este doc 66 |

**Sequência canônica de retomada:**

1. **Operador** abre nova sessão Codex CLI. Cola o prompt do doc 68
   (não o §6 deste doc). Codex faz RCA do MICRO49.
2. **Codex (nova sessão)** registra parecer em
   `.hbn/results/0055-exec-onda24-md24-4-rca-micro49.json` (ou
   próximo número disponível). Decisão: rollback MICRO48 ou plano
   MICRO49-fix3.
3. **Operador** abre chat novo na pasta `~/Projetos/usehbn/`. Cola o
   superprompt §5 deste doc.
4. **Opus chat-novo** lê (a) o handoff (este doc 66), (b) o resultado
   do RCA do Codex em `.hbn/results/0055-*.json`, (c) o estado atual
   do useHBN. Produz `00_BOOTSTRAP_PROTOCOLO_2026_05_09.md` e os
   ADRs 001-008.
5. **Opus chat-novo** compõe o "Prompt-Retomada-Codex-V204" levando
   em conta tanto a decisão técnica do Codex quanto os ADRs novos.
   O prompt cita explicitamente: ADR-002 (tipologia), ADR-003
   (topologia), ADR-008 (migração), e a decisão técnica do Codex.
6. **Operador** cola o Prompt-Retomada no chat Codex. Codex retoma a
   esteira V12.0.0204 com integrações sistêmicas declaradas.
7. **Operador** ratifica entregas em ambos os chats.

Os passos 1 e 3 podem ser **paralelos** — não há bloqueio mútuo.

## 11.7 Plano de retomada atualizado (substitui §8)

| # | Ação | Onde | Responsável |
|---|---|---|---|
| 1 | Aprovar este doc 66 v2.0 e fechar este chat | aqui | operador |
| 2 | Criar `~/Projetos/usehbn/.claude/settings.local.json` com Solução A (§4.2) | usehbn | operador |
| 3 | Abrir nova sessão Codex CLI; colar prompt curto do doc 68 §"Prompt de retomada" | Codex | operador |
| 4 | Codex faz RCA, registra parecer em `.hbn/results/0055-*.json` | Credenciamento | Codex (nova sessão) |
| 5 | Em paralelo, abrir chat novo na pasta `~/Projetos/usehbn/` | Antigravity | operador |
| 6 | Colar superprompt §5 deste doc | chat usehbn | operador |
| 7 | Opus chat-novo produz `00_BOOTSTRAP_PROTOCOLO_2026_05_09.md` + ADRs 001-008 | usehbn | Opus chat-novo |
| 8 | Cross-IA review dos ADRs | usehbn | Opus + Antigravity ou + Codex |
| 9 | Operador ratifica ADRs (boletim) | revisar | operador |
| 10 | Opus chat-novo lê o resultado RCA do Codex (passo 4) e compõe Prompt-Retomada-Codex-V204 com ADRs + decisão técnica | usehbn | Opus chat-novo |
| 11 | Operador cola Prompt-Retomada no chat Codex (mesma sessão do passo 3 ou nova, conforme orientação Opus) | Codex | operador |
| 12 | Codex retoma esteira V12.0.0204 com integrações sistêmicas | Credenciamento | Codex |
| 13 | V204 final é publicada com `useHBN-version: ^1.0.0` declarado em AGENTS.md | Credenciamento | Codex + operador |
| 14 | Quarta 0 inaugural ratifica ADR-001 (a Quarta) e cláusula da Janela de Faturamento | usehbn | Opus + operador |
| 15 | `Credenciamento/usehbn/` substituído por README depreciado (§11.5.5) + `.usehbn-snapshot/` populada (§11.5.3) | Credenciamento | Opus chat-novo (com hearback) |
| 16 | ADR-005 (licenciamento) — proposta Apache 2.0 entra na 2ª ou 3ª Quarta | usehbn | Opus + cross-IA |

## 11.8 Encerramento do bastão deste chat

A partir da aprovação operacional desta seção §11, este chat é
**oficialmente fechado**. Nenhum trabalho novo deve ser pedido a
este Opus 4.7 (Cowork) operando em CWD `~/Projetos/Credenciamento/`.

| Estado | Valor |
|---|---|
| Bastão F1 (Credenciamento V204) | ✅ Codex CLI (sessão pausada operacionalmente) — retomado em nova sessão via prompt doc 68 |
| Bastão F2 (useHBN protocolo) | ✅ transfere para Opus 4.7 chat novo em `~/Projetos/usehbn/` via superprompt §5 deste doc |
| Bastão meta (decisões cruzadas) | ✅ co-detido pelos dois chats, sincronizado via `.hbn/meta/` futura |
| Doc canônico de transição | ✅ este doc 66 v2.0 |
| Itens em aberto pós-encerramento | O4 (segunda app consumidora candidata) — para Quarta 0 |

✅ HBN ACTIVE — encerramento ordenado deste chat
🔵 HBN HANDOFF READY — pacote completo entregue para os dois sucessores
🧊 HBN APP FROZEN — Credenciamento congelado para Codex CLI da nova sessão
⚪ HBN AUDIT-ONLY — Opus chat-atual encerra sem ação operacional adicional
🟣 HBN PEER REVIEW — auditoria cruzada Antigravity + Codex já materializada nos docs 65 e 67
🟤 HBN LICENSE SPLIT REQUIRED — TPGL/AGPL — proposta de unificação Apache 2.0 em ADR-005

### Versão final

- v2.0 — 2026-05-09 — Opus 4.7 (Cowork) entrega o handoff final
  com 6 decisões ratificadas, Cláusula da Janela de Faturamento
  formalizada, recomendação Apache 2.0 fundamentada, solução
  tecnológica de separação via `.usehbn-snapshot/`, e plano de
  retomada em 16 passos. Este chat encerra o bastão.
