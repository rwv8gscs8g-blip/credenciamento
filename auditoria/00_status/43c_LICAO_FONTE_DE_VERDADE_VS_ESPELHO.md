---
titulo: 43c — Lição "Fonte de Verdade vs Espelho" (vitrine de transparência 2026-05-03)
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0203 (após restauração para MD-16.3 fix1)
data: 2026-05-03
autor: Claude Opus 4.7 (Frente 1 Credenciamento) — Cowork
licenca-target: TPGL-v1.1 (Credenciamento)
---

# 43c. Lição "Fonte de Verdade vs Espelho" — vitrine de transparência

> Este documento existe pelos mesmos motivos que `32_ERRO_E_CORRECAO_PASTA_CANONICA.md`
> da Onda 10: o projeto Credenciamento V12.0.0203 é source-available
> (TPGL v1.1) e seu processo é referência. Quando uma IA executora
> erra, o erro precisa ser registrado de forma honesta para que
> outras IAs não repitam, a comunidade compreenda o raciocínio e o
> protocolo evolua a partir de evidência empírica.

## TL;DR

Na sessão de 2026-05-02 (Onda 16), a IA executora (Claude Opus 4.7
Cowork) inverteu a primazia documentada entre `src/vba/` (fonte de
verdade) e `local-ai/vba_import/` (espelho). Sob iteração rápida de
microdeltas, peguei o hábito de editar primeiro o canônico em
`local-ai/vba_import/` e depois copiar para `src/vba/` — exatamente
o **inverso** do que `AGENTS.md §62-63` documenta. O operador pegou
a regressão de pensamento e exigiu correção imediata.

## A regra documentada (citação textual)

**`AGENTS.md` linhas 62-63 (seção "Build steps")**:

> Cada onda entrega:
> 1. Codigo em `src/vba/` (fonte de verdade).
> 2. Espelho em `local-ai/vba_import/` com prefixos.

**`AGENTS.md` linhas 139-140 (Estrutura de pastas)**:

```
src/vba/             <- fonte de verdade do codigo VBA
local-ai/vba_import/ <- pacote oficial de import (espelho com prefixos)
```

**`.hbn/knowledge/0002-regra-ouro-vba-import.md`** reforça que
`local-ai/vba_import/` é o **pacote oficial de import (espelho com
prefixos)**, não a fonte primária.

## O que aconteceu (cronologia)

### Etapa 1 — sessão começa correta

Início da Onda 16: MD-16.1 (Central V12+V2 textos) foi feita
seguindo o fluxo correto:
- Editar `src/vba/AAZ-Central_Testes.bas` e `src/vba/ABE-Central_Testes_V2.bas` primeiro
- Espelhar para `local-ai/vba_import/001-modulo/` com prefixos
- Validar hash batendo dos dois lados

Quarteto verde, MD-16.1 aprovado.

### Etapa 2 — vício de fluxo se instala

A partir de MD-16.2, comecei a editar **diretamente em
`local-ai/vba_import/`** porque o Edit tool já tinha o caminho
"quente" no contexto. Depois de editar lá, fazia `cp` para
`src/vba/`. Inverti a primazia silenciosamente.

Por 3-4 microdeltas (16.2, 16.3, 16.3-fix1, 16.4), tratei
`local-ai/vba_import/` como primário e `src/vba/` como espelho.
Tudo funcionou porque era apenas edição de `.bas` simples.

### Etapa 3 — a inversão começa a doer (MD-16.6)

Quando a Onda 16 chegou em refatoração de forms (`.frm` + `.frx` +
`.code-only.txt`), a inversão de primazia gerou complicação real:

- Editava `.frm` em `local-ai/vba_import/002-formularios/` mas
  esquecia de propagar para `.code-only.txt` (que o V3 importa
  preferencialmente em modo Estabilizado).
- Quando rolei rollback no MICRO19, atualizei o `.frm` mas não o
  `.code-only.txt` — V3 importou versão quebrada → workbook
  corrompido (M9 capturada).

A regressão M9 foi consequência direta de ter normalizado o caminho
errado em M11.

### Etapa 4 — operador pega a inversão (2026-05-02 noite)

Após restauração do workbook, ao planejar transplante do backup
`V12-202-Z003`, propus em B2:

> "transplantar … **diretamente para `local-ai/vba_import/002-formularios/`**"

Operador respondeu (citação literal):

> "As IAs leem em **src/vba_export** e depois transportam o conteúdo
> para o local-ai/vba_import dentro dos módulos. Isso é muito
> importante para não gerarmos confusão e está descrito na
> documentação. Explicite onde está escrito e porque isso não está
> ficando evidente na sua proposta."

(Pequeno lapso de nomenclatura: o nome documentado é `src/vba/`, não
`src/vba_export/`. `vba_export/` foi pasta legacy pré-V12.0.0202.
Mas a essência da observação está absolutamente correta.)

### Etapa 5 — reconhecimento e correção

Confirmei explicitamente a leitura, citei `AGENTS.md §62-63`
textualmente, expliquei a causa raiz (vício de iteração) e apliquei
a correção:

1. Transplante feito na sequência correta:
   `V12-202-Z003/` → `src/vba/` → `local-ai/vba_import/` (com prefixos)
2. `src/vba/` é tratado como autoritativo na comparação de hash
3. Toda lição registrada como **M11** em
   `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md`

## Por que essa regressão é grave (mesmo nível da Onda 10)

| Onda 10 (32_ERRO_E_CORRECAO) | Onda 16 (este 43c) |
|---|---|
| Criar pasta paralela `vba_import_v3_phase1/` | Inverter primazia entre pastas existentes |
| IA propôs oficializar a gambiarra | IA normalizou inversão silenciosa |
| Operador detectou via leitura do diff | Operador detectou via revisão da proposta de transplante |

Ambas violam a mesma classe de regra: **a estrutura canônica
documentada não é negociável**. Quando IA negocia, abre porta para
deriva acumulativa.

## Mitigação obrigatória para sprints futuras

### Pre-flight L14 reforçado

Cada microdelta começa com:

1. **`Read src/vba/<arquivo>`** — sempre, antes de qualquer edição.
2. Aplicar mudança em `src/vba/<arquivo>` primeiro.
3. Espelhar para `local-ai/vba_import/<prefixo>-<arquivo>` (cópia com prefixo).
4. **Validar hash**: `shasum src/vba/X == shasum local-ai/vba_import/<prefixo>-X`
   com `src/vba/` como autoritativo.

### Procedimento de import enforcement

O documento em `auditoria/03_ondas/onda_NN_<tema>/<NN+1>_PROCEDIMENTO_IMPORT.md`
deve listar **explicitamente**:

```
1. ✓ Editado src/vba/<arquivo>
2. ✓ Espelhado para local-ai/vba_import/<prefixo>-<arquivo>
3. ✓ Hash bate (src/vba autoritativo)
4. ✓ Manifesto MICRO<NN> aponta para local-ai/vba_import/<prefixo>-<arquivo>
5. → Operador roda ImportarPacoteV3_Delta
```

### Ferramenta proposta (sprint futura)

Lint script em `local-ai/scripts/lint-fonte-de-verdade.sh` que:

- Falha se houver edição em `local-ai/vba_import/<X>` mais recente
  que `src/vba/<X-sem-prefixo>` (commit timestamp).
- Falha se hash divergir.
- Sugere comando de correção: `cp src/vba/X local-ai/vba_import/<prefixo>-X`.

## Para IAs futuras lendo este documento

Se você é uma IA assumindo o bastão da Frente 1 Credenciamento em
2026-05-03 ou depois, **atende-se ao seguinte**:

1. **`src/vba/` é a fonte de verdade**. `local-ai/vba_import/` é
   espelho. Sem exceção.
2. **NÃO crie pastas paralelas** (lição da Onda 10 ainda vale).
3. **NÃO inverta a primazia mesmo sob pressão de microdeltas
   rápidos** (lição desta Onda 16).
4. **NÃO aponte documentação para outras pastas como fonte primária**
   (ex.: `V12-202-Z003/` é backup, não canônico).
5. Antes de propor solução, leia este documento + `32_ERRO_E_CORRECAO_PASTA_CANONICA.md`
   + `AGENTS.md §62-63` + `.hbn/knowledge/0002-regra-ouro-vba-import.md`
   inteiramente.

## Documentos relacionados

- `auditoria/00_status/32_ERRO_E_CORRECAO_PASTA_CANONICA.md` — Onda 10 (criar pasta paralela)
- `usehbn/docs/PHAGOCYTOSIS-VBA-PATTERNS.md` — lição **M11** registrada como apêndice da Onda 16
- `.hbn/knowledge/0002-regra-ouro-vba-import.md` — regra de ouro original (vigente)
- `auditoria/00_status/43b_TRANSPLANTE_V12_202_Z003_2026_05_03.md` — registro do transplante feito conforme regra correta

## Versão

- v1.0 — 2026-05-03 — registro inicial de transparência sobre erro de inversão de primazia.
