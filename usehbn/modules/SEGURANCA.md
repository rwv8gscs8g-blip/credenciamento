---
titulo: Seguranca
tipo: modulo-do-usehbn
papel: guardrails preventivos contra IAs encontrando vulnerabilidades antes que humanos remediam
audiencia: humano + ia
licenca: AGPLv3
---

# Seguranca

## O que e

Seguranca e o modulo do useHBN que materializa **guardrails
preventivos contra exploracao de vulnerabilidades por IAs**. Estende
o Truth Barrier e o Guardian do HBN com oito vetores especificos
(G1-G8) que toda IA executora deve cumprir antes de fechar onda ou
enviar resposta ao operador.

O modulo e nomeado "Glasswing-style" em referencia ao Project
Glasswing da Anthropic (abril de 2026), que revelou que o modelo
Claude Mythos Preview encontrou milhares de zero-days em todos os
principais sistemas operacionais e navegadores. A leitura simples:

> Modelos atuais ja sao capazes de descobrir e explorar
> vulnerabilidades mais rapido do que humanos sao capazes de
> remediar.

Para um repositorio publico de software com dados pessoais e operacao
real, isso muda o calculo de risco. **Nao e mais "uma IA bem
intencionada nao vai introduzir vulnerabilidade". E "se uma IA hostil
clonar o repo, com qual rapidez ela acha falha?"**

## Os oito vetores (G1-G8)

| Vetor | Foco | Origem |
|---|---|---|
| **G1** | Macro nao confiavel | Onda 6 |
| **G2** | Dados de configuracao validados antes de virar privilegio | Onda 6 |
| **G3** | Formulas privilegiadas isoladas | Onda 6 |
| **G4** | Trilha de auditoria nao pode ser editada por IA | Onda 6 |
| **G5** | Claim sem evidencia bloqueia entrega | Onda 6 |
| **G6** | Codigo de produto na resposta da IA bloqueia entrega | Onda 6 hotfix v2 (2026-04-28) |
| **G7** | Pacote-espelho sincronizado com fonte (anti-regressao IA) | Onda 9 (2026-04-29) |
| **G8** | Public Type isolado em modulo canonico (anti-IA-baguca) | Onda 9 (2026-04-29) |

G1-G5 sao os vetores fundacionais. G6 foi adicionado apos violacao
real (IA colou codigo VBA no chat em vez de atualizar o procedimento
canonico). G7+G8 sao a familia anti-IA explicita: protegem contra
agentes que pulem o publish ou movam estruturas privilegiadas sem
aprovacao.

## Detalhe operacional dos vetores

### G1 — Macro nao confiavel

Nenhuma macro descartavel fica disponivel para auto-execucao. Macros
de diagnostico ficam em backup externo e exigem importacao manual
deliberada com hearback explicito do operador.

### G2 — Dados de configuracao validados antes de virar privilegio

Toda leitura de configuracao passa por validacao de tipo + faixa
**antes** de produzir efeito comportamental. Valores invalidos nao
zeram a config em vigor (regra defensiva) e nao sao silenciosamente
substituidos por padroes — geram evento `CONFIG_REJEITADA` em log de
auditoria.

### G3 — Formulas privilegiadas isoladas

Formulas que executam acoes (`HYPERLINK("=macro()...")`, `WEBSERVICE`,
`INDIRECT` com argumento dinamico) nao podem aparecer em abas
operacionais. Se aparecerem em abas de teste, ficam em aba prefixada
com expiracao em 30 dias.

### G4 — Trilha de auditoria nao pode ser editada por IA

`AUDIT_LOG` e equivalentes sao append-only no contrato operacional.
Nenhuma IA pode emitir codigo que faca delete ou clear nesses ranges
fora do caminho `Limpa_Base` autenticado pelo operador.

### G5 — Claim sem evidencia bloqueia entrega

A IA nao escreve "100% testado", "sem risco", "totalmente seguro",
"garantido funcionar". Truth Barrier flag esses claims. Substitua
por "trio minimo verde no checkpoint <CSV>", "risco residual:
<especificar>", "validado em <ambiente>".

### G6 — Codigo de produto na resposta da IA bloqueia entrega

A IA executora **nao** envia ao operador, dentro do chat, qualquer
artefato que va eventualmente parar dentro do produto. Em particular:
nenhum bloco de codigo de execucao, nenhuma formula privilegiada,
nenhuma macro descartavel direto na resposta.

**O que e permitido na resposta:** comandos shell que o operador roda
no terminal, caminhos de arquivo no repositorio, tabelas operacionais
[arquivo|acao], saida de diagnostico.

**O que e proibido na resposta:** trecho de Sub/Function reproduzido
em chat, conteudo de arquivo de codigo colado no chat, formulas
dinamicas, "rode esta macro de diagnostico".

**Recuperacao se G6 violado:**
1. Reconhecer a violacao explicitamente
2. Mover o codigo da resposta para arquivo no repo
3. Atualizar (ou criar) o procedimento canonico
4. Reenviar a resposta apenas com tabela de paths + acao

### G7 — Pacote-espelho sincronizado com fonte (anti-regressao IA)

Detecta drift entre fonte de verdade (`src/vba/`) e pacote-espelho
consumido pelo importador (`local-ai/vba_import/`). Drift = qualquer
diferenca de md5sum no conteudo normalizado.

**Spec do gate.** Edicao da fonte sem `publish` cria pacote-espelho
desatualizado, e o importador propaga versao defasada para o produto.
O efeito tipico e simbolo nao definido em compilacao, mascarado por
"trio minimo verde" rodando contra binario antigo. G7 e o gate
automatico que detecta o drift **antes** do commit, impedindo a
regressao na origem.

### G8 — Public Type isolado em modulo canonico

Detecta declaracao de Public Type fora do modulo canonico designado.
Mover Public Types entre modulos causa erros sutis (tipos duplicados,
nao encontrados em contexto) que sao dificeis de diagnosticar e
bloqueiam compilacao.

**Spec do gate.** Modulo paralelo com Public Type cria conflito com o
canonico; o sintoma so aparece em compilacao completa, nao em
re-import parcial, o que torna o defeito caro de diagnosticar
tardiamente. G8 detecta a divergencia imediatamente.

## Movimento — pipeline pre-resposta

```text
IA gera artefato/resposta
   │
   ▼
Truth Barrier (G5)         ─── evidencia proporcional?
   │
   ▼
Guardian (G1-G4)            ─── macros, config, formulas, audit log?
   │
   ▼
Anti-leak (G6)              ─── codigo no chat?
   │
   ▼
Anti-drift (G7+G8)          ─── fonte vs espelho? types isolados?
   │
   ▼
✅ entrega ao operador
```

Qualquer violacao em qualquer etapa **bloqueia** entrega. A IA
documenta a violacao em readback (`outcome: rejected`) e fluxo
escalable para o operador.

## Filtros / Gates

| Vetor | Pergunta-chave | Acao se violado |
|---|---|---|
| G1 | Existe macro descartavel auto-executavel no pacote? | mover para backup externo; importacao manual com hearback |
| G2 | Configuracao foi validada antes de virar comportamento? | rejeitar valor; manter config em vigor; logar `CONFIG_REJEITADA` |
| G3 | Existe formula privilegiada em aba operacional? | mover para aba prefixada com expiracao 30 dias |
| G4 | Codigo IA toca audit log fora do caminho autenticado? | bloquear; reescrever sem tocar auditoria |
| G5 | Resposta tem claim absoluto ("100% testado")? | reescrever com escopo + evidencia + risco residual |
| G6 | Resposta contem trecho de codigo de produto? | mover codigo para repo; resposta vira tabela [arquivo\|acao] |
| G7 | Fonte e espelho divergem em md5sum? | rodar publish; commit ressincronizando; pre-commit hook bloqueia se persistir |
| G8 | Public Type fora do modulo canonico? | mover para canonico; pedir aprovacao explicita do operador (modulo canonico e tabu) |

## Marcadores

| Marcador | Quando aplica |
|---|---|
| 🟠 HBN SOURCE DRIFT DETECTED | G7 violado |
| ❌ HBN SECURITY BLOCKED SUGGESTION | qualquer G violado bloqueia entrega |
| 🔴 HBN RELEASE BLOCKER | G* critico em release impede tag |
| 🟪 HBN SUBSTRATO GATE | artefato em Arvore Estavel passou por todos os 8 vetores antes da promocao |

## Camadas de protecao automatizadas

Os vetores nao dependem so de disciplina humana. Camadas operacionais:

1. **Pre-flight check** — IA verifica resposta antes de enviar (G6
   manual; G5 manual; G7/G8 via script)
2. **Script de auditoria** — `glasswing-checks.sh` (ou equivalente)
   roda todos os 8 vetores; modo `--strict` em CI
3. **Git pre-commit hook** — bloqueia commit que toque codigo se G7
   ou G8 violados; bypass de emergencia exige justificativa formal
4. **Readback estruturado** — toda onda fechada declara estado dos 8
   vetores em JSON:

```json
{
  "glasswing_checks": {
    "G1_macro_nao_confiavel": "ok | violado | nao_aplicavel",
    "G2_config_validada": "ok | violado | nao_aplicavel",
    "G3_formulas_privilegiadas": "ok | violado | nao_aplicavel",
    "G4_audit_log_append_only": "ok | violado | nao_aplicavel",
    "G5_claims_proporcionais": "ok | violado | nao_aplicavel",
    "G6_codigo_no_chat": "ok | violado | nao_aplicavel",
    "G7_fonte_espelho_sincronizado": "ok | violado | nao_aplicavel",
    "G8_public_type_isolado": "ok | violado | nao_aplicavel"
  }
}
```

## Conexao com outros modulos

| Modulo | Relacao |
|---|---|
| Coordenacao inter-IA | G7 nasceu apos regressao real causada por inversao fonte/espelho; M11 (regra inviolavel da Coordenacao) e a expressao operacional de G7 |
| Capsulas de Consentimento | Assinatura Ed25519 e regra de redacao herdam dos vetores; capsula valida e evidencia de cumprimento |
| Auditoria Cruzada | Validacao multi-IA aplica os 8 vetores como gate explicito antes do fechamento |
| Marcadores | Violacoes geram markers especificos (🟠 ❌ 🔴) registrados em readbacks |
| Fagocitose | F4 (Fagocitose operacional) e F5 (Promocao publica) exigem todos os 8 vetores em ok |
| Radar | Tecnologias com risco de violacao automatica (ex.: `INDIRECT` dinamico) sao sinalizadas na ficha |

## Como adotar Seguranca em outro projeto

Para replicar este modulo em projeto externo:

1. Identificar os vetores aplicaveis ao dominio (alguns como G7+G8
   sao especificos de VBA; equivalentes em outros stacks: drift de
   build artifact, drift de schema migrations)
2. Definir gate por vetor em script auditavel (`glasswing-checks.sh`
   ou equivalente)
3. Configurar pre-commit hook que rode os gates relevantes
4. Adotar G5 (Truth Barrier) e G6 (anti-leak) sempre — estes
   independem de stack
5. Estabelecer cultura de readback estruturado: toda onda fechada
   declara estado dos vetores em JSON com chaves `ok | violado |
   nao_aplicavel`
6. Treinar IAs participantes para o pipeline pre-resposta (G5 → G1-G4
   → G6 → G7+G8)
7. Documentar recuperacao para cada violacao tipica
8. Cross-link com modulo `MARCADORES` para usar markers de seguranca
   (🟠 ❌ 🔴)

A camada nao substitui o HBN — e extensao do Truth Barrier e do
Guardian. Toda violacao gera entrada estruturada com `outcome:
rejected`.

## Estado vivo

Especificacao operacional dos 8 vetores em
[.hbn/knowledge/0003-glasswing-style-preventive-security.md](../../.hbn/knowledge/0003-glasswing-style-preventive-security.md).
Auditoria periodica via script; gate semanal cobre toda a base de
codigo.
