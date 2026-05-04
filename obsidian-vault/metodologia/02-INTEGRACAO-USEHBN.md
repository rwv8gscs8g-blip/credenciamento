---
titulo: Integracao com o usehbn
ultima-atualizacao: 2026-04-28
diataxis: explanation
hbn-track: fast_track
audiencia: ambos
versao-sistema: V12.0.0203
---

# Integracao com o usehbn

> Por que o Credenciamento adotou o protocolo HBN como base de
> coordenacao inter-IA, e o que isso significa na pratica.

## Resumo em uma frase

O Credenciamento e o **primeiro projeto production-scale do mundo a
compor HBN com Diataxis, llms.txt, AGENTS.md e camada Glasswing-style**
em uma metodologia documental unificada para projetos de software
publico.

## O que e o usehbn

[Human Brain Net (HBN)](https://usehbn.org) e um protocolo aberto para
engenharia de software assistida por IA. Foi criado por Luis Mauricio
Junqueira Zanin, autor tambem deste sistema de Credenciamento.

O HBN parte de uma disciplina simples: **trabalho assistido por IA
deve permanecer legivel, revisavel, e governavel por humanos**.

## Por que o Credenciamento adotou

Antes da Onda 6 (28/04/2026), o Credenciamento sofria de tres problemas
classicos da engenharia assistida por IA:

1. **Bastao implicito.** Diferentes IAs (Claude Opus, Codex) editavam
   codigo em sequencia sem registro estruturado de quem podia editar
   quando. Resultado: Onda 1-5 do V12.0.0203 foi feita por Claude Opus
   sem permissao formal — um erro custoso que motivou esta Onda 6.

2. **Drift entre intent e implementacao.** A IA recebia "estabilize a
   `0203`" e devolvia 5 ondas funcionais com 5 macros descartaveis,
   1 modulo novo, e duplicacao documental. Sem readback explicito, o
   drift virou acumulo.

3. **Claims sem evidencia.** Documentacao de ondas anteriores incluia
   frases como "100% testado" sem link para CSV. HBN's Truth Barrier,
   se tivesse sido aplicado, teria flag-ado essas frases na hora.

A integracao com HBN, formalizada na Onda 6, resolve os tres.

## O que muda no projeto

### `.hbn/` agora e parte do repositorio

```
.hbn/
├── relay/             <- bastao + ciclo ativo (atualizado a cada onda)
├── relay-archive/     <- ondas resolvidas
├── knowledge/         <- decisoes reutilizaveis (regras V203, regra de ouro, Glasswing)
├── readbacks/         <- snapshots antes de execucao safe_track
├── results/           <- ERPs vinculados a readbacks
└── reports/           <- saidas humanas concisas
```

### Toda onda passa por readback + hearback

Antes (pre-HBN):

> Mauricio: "estabilize a 0203"  
> Claude: [edita 5 ondas, gera 5 macros, duplicacao etc.]

Depois (com HBN):

> Mauricio: "estabilize a 0203"  
> Claude: [gera readback explicito em .hbn/readbacks/]  
> Claude: "✅ HBN ACTIVE — entendi X, invariantes Y, plano Z. Ok?"  
> Mauricio: "ok" (ou ajusta)  
> Claude: [executa, registra ERP em .hbn/results/]

A pequena friccao adicional do readback se paga em 1 ciclo evitado de
retrabalho.

### Bastao explicito em `.hbn/relay/INDEX.md`

```yaml
proprietario-bastao: Claude Opus 4.7 (Cowork)
ciclo-ativo: ONDA 6
proxima-acao: ...
```

IAs sem bastao operam em modo auditoria. Tentativas de tomar bastao
sem hearback explicito sao bloqueadas.

### Truth Barrier + Guardian + Glasswing

Tres camadas em sequencia:

1. **Truth Barrier** (HBN core) — flag claims sem evidencia.
2. **Guardian** (HBN core) — flag intents arriscados.
3. **Glasswing** (extensao project-specific) — flag 5 vetores
   concretos do dominio VBA/Excel/credenciamento publico.

Toda violacao bloqueia o fechamento da onda.

## O que NAO muda

- Codigo VBA continua sendo a fonte de verdade.
- Build continua manual no VBE.
- Bateria oficial V1+V2 continua sendo o gate de promocao.
- Licenca, governanca, e fluxo publico nao sao tocados.

A integracao e **adicao de estrutura coordenacional**, nao substituicao
de nada que ja funcionava.

## Custo da adocao

Onda 6 inteira (consolidacao + integracao + 4 docs novos no usehbn): 1
sessao de chat com Claude Opus 4.7 em modo execucao maxima. Sem
alteracao de codigo VBA. Reversivel via `git reset --hard
pre-onda-06-2026-04-28`.

## Beneficio mensuravel

Tres metricas a serem auditadas pos-V12.0.0203 publica:

1. Tempo medio para uma IA nova entrar no projeto e fazer acao
   correta. Meta: < 5 minutos.
2. Numero de retrabalhos por baton conflict. Meta: 0 nas Ondas 7-9.
3. Numero de claims-sem-evidencia em documentacao publicada. Meta: 0.

## Como o usehbn evolui a partir daqui

A integracao Credenciamento alimenta o usehbn de tres formas:

1. **Case study real** documentado em
   `usehbn/docs/CASE-STUDY-CREDENCIAMENTO.md`.
2. **Validacao de categoria A** das integracoes Diataxis/llms.txt/
   AGENTS.md/Glasswing — o usehbn formalizou o protocolo
   `EVOLUTION-POLICY.md` que governa essas adopcoes.
3. **Pressao de evolucao** — bugs e limitacoes encontrados em uso real
   alimentam roadmap publico do usehbn.

Em outras palavras: o Credenciamento testa o usehbn em producao, e o
usehbn aprende. A relacao e simbiotica e auditavel.

## Referencia

- usehbn home: https://usehbn.org
- usehbn case study: `usehbn/docs/CASE-STUDY-CREDENCIAMENTO.md`
- Adopted external protocols: `usehbn/README.md` secao "Adopted
  External Protocols"
