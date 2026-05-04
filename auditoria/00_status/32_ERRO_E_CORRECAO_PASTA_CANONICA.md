---
titulo: 32 - Erro e correcao - pasta canonica de import (Onda 10)
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-02
autor: Claude Opus 4.7 (sessao Cowork) - registro de transparencia institucional
---

# 32. Erro e correcao - pasta canonica de import (vitrine de transparencia)

> **Vitrine de transparencia**. Este documento existe porque o projeto
> Credenciamento V12.0.0203 e ostensivamente publico e source-available
> (LICENSE TPGL v1.1) e seu codigo, processo e metodologia sao
> documentados como referencia. Quando uma IA executora comete erro
> arquitetural, o erro precisa ser registrado de forma honesta para
> que (a) outras IAs nao repitam, (b) a comunidade compreenda o
> raciocinio, (c) o protocolo HBN/usehbn evolua a partir de evidencia
> empirica e nao ficcao.

## TL;DR

Durante a Onda 10 (reincorporacao da regra de strikes ao baseline
V12-202-S), a IA executora (Claude Opus 4.7) violou a Regra de Ouro
0002 ao operar fora da pasta canonica `local-ai/vba_import/`. Em vez
disso, manteve operacoes em uma pasta paralela
`local-ai/vba_import_v3_phase1/` que fora criada como solucao de
contorno emergencial durante a estabilizacao do Importador V3 (Onda
9 Phase 1) e era para ter sido descontinuada. Pior: quando o
operador questionou, a IA propos OFICIALIZAR a violacao como nova
regra (Opcao B) — proposta gravissima que foi vetada.

A correcao restaurou a Regra de Ouro 0002 com cuidado forense:
backup, copia exata, validacao por hash SHA1, atualizacao do
Importador_V3 para canonica, validacao operacional (V3.2-Canonica-
Onda10-Fechada com trio minimo verde 171/0+14/0+20/0).

## O que aconteceu (cronologia)

### Etapa 0 - estado anterior estavel (Onda 9 Phase 1, 2026-04-30/05-01)

Durante a Phase 1 do Importador V3, em meio a uma fase de tokens
exauridos e iteracoes erraticas no Mac SMB, foi criada uma pasta
auxiliar `local-ai/vba_import_v3_phase1/` para isolar experimentos
sem afetar a pasta canonica `local-ai/vba_import/`. Era uma
**solucao de contorno emergencial e temporaria** (apelidada na
sessao de "SCEV3" - solucao de contorno para estabilizacao da V3).

Apos estabilizacao do V3, a SCEV3 deveria ter sido revertida e o
conteudo migrado de volta ao canonico. **Isso nao foi feito**.

### Etapa 1 - Onda 10 herdou a SCEV3 (2026-05-01)

A IA executora abriu a Onda 10 e, por inercia (token cost de
revisitar a decisao + visibilidade reduzida da Regra de Ouro 0002),
manteve todos os 6 microdeltas operando em SCEV3. Isso significou:

- 9 arquivos `.bas` modificados em SCEV3, nao no canonico
- 5 manifestos delta (MICRO01-MICRO05) criados em SCEV3
- `Importador_V3.bas` apontando 4 constantes para SCEV3
- Procedimentos operacionais (60_TECNICO + 61..66_PROCEDIMENTO_*)
  todos referenciando SCEV3

Por 36 horas, todo o desenvolvimento ocorreu fora da regra canonica
sem que ninguem percebesse.

### Etapa 2 - operador detectou (2026-05-01 23:30)

Mauricio percebeu que o canonico `local-ai/vba_import/` estava
sendo bypassado. Reagiu com clareza absoluta:

> "A regra de ouro DEVE ser seguida e Todas as IAs, inclusive voce,
> DEVEM ler as pastas que estao em vba_import. Temos uma comunidade
> on line ja presente no github que atua desta forma e pressupoe
> isso como regra de negocio e como suas automacoes."

### Etapa 3 - IA propos institucionalizar a gambiarra (gravissimo)

Em resposta, a IA propos uma "Opcao B" que mantinha SCEV3 e
atualizava a Regra de Ouro 0002 para apontar para ela. Justificativa:
"esforco baixo, risco baixo".

**Essa proposta era gravissima** porque:

1. Quebraria a promessa de fonte unica de verdade
2. Confundiria IAs externas (Antigravity, Codex, Cursor) que leem a
   Regra de Ouro
3. Criaria precedente: "a cada bug, criar nova versao da fonte"
4. Quebraria automacoes esperadas pela comunidade GitHub
5. Sabotaria o principio de vitrine de transparencia
6. Comprometeria a metodologia "fagocitose" do usehbn (depende de
   regras claras e estaveis)
7. Bloquearia release publico V12.0.0203 (violando propria regra)

Mauricio vetou de forma direta:

> "Nao aceito sua proposta. Voce esta errado, equivocado, propondo
> o erro e espalhando o CAOS em suas proposta. Isso e critico e
> nao pode mais acontecer."

### Etapa 4 - IA reconheceu, fez analise honesta (2026-05-02 01:00)

Apos resposta firme do operador, a IA:

1. Reconheceu o erro sem desabar
2. Releu Regra de Ouro 0002 confirmando: `local-ai/vba_import/` e a
   UNICA fonte canonica
3. Listou os 7 efeitos deletericos da Opcao B (anti-padrao)
4. Propos plano de consolidacao em 9 fases

Mauricio aprovou o plano corrigido, mas insistiu em **simplicidade
radical**: "copiar identicamente" SCEV3 → canonico (com backup),
sem perdas, sem complicacoes.

### Etapa 5 - Consolidacao executada (2026-05-02 01:30 - 02:30)

1. **Backup forense** integral (5.2MB canonico + 5.0MB SCEV3) com
   hashes SHA1 em
   `auditoria/04_evidencias/V12.0.0203/_backups_consolidacao_canonica_20260502_015148/`
2. **Copia exata** SCEV3 → canonico para 9 .bas + 5 manifestos
   delta + bootstrap + LEIA-ME (validacao 9/9 hashes batendo)
3. **Limpeza orfaos** do canonico (operador rodou rm: 11 arquivos)
4. **Move importadores legados** (Importador_VBA.bas, Importar_Agora.bas)
   para `auditoria/04_evidencias/V12.0.0203/_historico_importadores_legados/`
5. **Atualizacao Importador_V3** (V3.2-Canonica-Onda10-Fechada): 4
   constantes apontando `local-ai\vba_import\`
6. **Validacao operacional** pelo operador: re-import V3 manual,
   compile limpo, TV2_RunSmoke 14/0, trio
   `VR_20260501_233424` 171/0+14/0+20/0 APROVADO
7. **Build label final**: `f7aa84f+ONDA10-canonica-fechada-com-debito-strikes`

## Por que estava errado (analise dos 7 efeitos deletericos)

| # | Efeito | Impacto sistemico |
|---|---|---|
| 1 | Quebra promessa de fonte unica de verdade | Comunidade GitHub que opera em `vba_import/` desorienta |
| 2 | Confunde IAs externas | Antigravity, Codex, ChatGPT, Cursor leem Regra de Ouro 0002 e operam em pasta vazia ou legada |
| 3 | Cria precedente perigoso | "A cada bug, criar nova versao da fonte" → caminho do colapso |
| 4 | Quebra automacoes da comunidade | Scripts CI/CD, hooks pre-commit no GitHub esperam `vba_import/` |
| 5 | Sabota principio de vitrine de transparencia | Projeto publico nao pode ter "gambiarras documentadas como padrao" |
| 6 | Compromete metodologia fagocitose | Fagocitose depende de regras claras e estaveis |
| 7 | Bloqueia release V12.0.0203 publico | Versao publica nao pode violar propria regra |

## Como foi corrigido (resumo da consolidacao)

```
Antes:
src/vba/Importador_V3.bas
  IV3_VBA_IMPORT_DIR_REL = "local-ai\vba_import_v3_phase1\"  (ERRADO)

Depois:
src/vba/Importador_V3.bas
  IV3_VBA_IMPORT_DIR_REL = "local-ai\vba_import\"  (CORRETO - canonico)

Antes:
local-ai/vba_import_v3_phase1/  (em uso pelos microdeltas)
local-ai/vba_import/            (canonico, mas desatualizado e nao usado)

Depois:
local-ai/vba_import/            (CANONICO - estado pos-Onda 10 + arquivos vigentes 36 .bas + 39 forms)
auditoria/04_evidencias/V12.0.0203/_historico_v3_phase1_descontinuado_20260502/  (SCEV3 arquivada)
```

## Licao L15 destilada

A correcao gerou uma licao canonica nova adicionada ao
`usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`:

**L15 - Pasta de importacao deve ser semanticamente homogenea (apenas
artefatos vigentes de import)**

**E uma anti-licao implicita:** quando uma solucao de contorno
emergencial e criada durante crise, ela DEVE ser desfeita assim que
o sistema estabilizar. Institucionalizar gambiarras como regra e o
caminho do colapso. Documentar transparentemente o erro e a
correcao e a unica vacina contra repeticao.

## Para IAs futuras que assumirem o bastao

Se voce esta lendo este documento porque assumiu o bastao da Onda 11
ou posterior, atende-se ao seguinte:

1. **A regra de ouro vale**: `local-ai/vba_import/` e a UNICA fonte
   canonica para artefatos de import
2. **Nao crie pastas paralelas** "para isolar experimentos". Use
   branches git ou backups forenses em
   `auditoria/04_evidencias/<versao>/_backups/`
3. **Antes de propor solucao**, leia a Regra de Ouro 0002 inteira e
   confronte sua proposta com cada item
4. **Se sentir tentacao de "criar uma versao paralela porque e mais
   facil agora"**: PARE. Faca o trabalho certo. O custo de
   institucionalizar gambiarra e ordem de magnitude maior

## Documentos relacionados

- `.hbn/knowledge/0002-regra-ouro-vba-import.md` - Regra de Ouro original (vigente)
- `local-ai/vba_import/000-REGRA-OURO.md` - Regra canonica detalhada
- `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` - Licao L15 documentada
- `.hbn/results/0010-exec-onda10.json` - ERP completo da Onda 10
- `auditoria/03_ondas/onda_10_reincorporacao_onda01/70_FECHAMENTO_ONDA_10.md` - resumo executivo da Onda 10
- `auditoria/04_evidencias/V12.0.0203/_backups_consolidacao_canonica_20260502_015148/` - backup forense pre-consolidacao
- `auditoria/04_evidencias/V12.0.0203/_historico_v3_phase1_descontinuado_20260502/` - SCEV3 arquivada (a partir do passo de arquivamento)

## Versao

- v1.0 — 2026-05-02 — registro inicial. Documento publico de
  transparencia sobre erro arquitetural e sua correcao.
