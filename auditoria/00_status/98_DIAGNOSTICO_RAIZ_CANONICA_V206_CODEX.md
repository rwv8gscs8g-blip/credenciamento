---
titulo: Diagnostico Raiz Canonica V206 — Codex
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Diagnostico Raiz Canonica V206 — Codex

## Veredito

P0 confirmado e corrigido antes de avancar a V12.0.0206.

A unica raiz local de verdade para desenvolvimento, auditoria, HBN, backups
operacionais e importacao VBA passa a ser:

```text
/Users/macbookpro/Projetos/Credenciamento
```

O worktree errado `/private/tmp/cred-v205` foi removido. A branch
`codex/v12-0-0206-planejamento` agora esta ativa na pasta do projeto.

## O que falhou

O protocolo HBN/usehbn tinha readback, ERP e relay, mas nao tinha uma guarda
executavel de raiz absoluta. A IA aceitou como valido um worktree que tinha a
branch correta, mas estava no lugar errado:

```text
/private/tmp/cred-v205
```

Isso quebrou a premissa operacional do workbook. A Janela Imediata mostrou:

```text
?ThisWorkbook.Path
\\Mac\Home\Projetos\Credenciamento

ImportarPacoteV3_Status
MANIFESTO ESPERADO:
  \\Mac\Home\Projetos\Credenciamento\local-ai\vba_import\000-MANIFESTO-V3-PHASE1.txt
  STATUS: presente
```

Logo, qualquer delta escrito em `/private/tmp/cred-v205/local-ai/vba_import`
seria invisivel para o Importador V3. Pela mesma razao, backups obrigatorios
gerados pelo workbook ficam abaixo da pasta do projeto, nao no tmp.

## Causa raiz

1. A branch `codex/v12-0-0206-planejamento` estava presa no worktree temporario.
2. A pasta canonica estava em `main` antigo (`9275640`) e tratava os arquivos
   modernos como untracked.
3. Os readbacks V206 registraram `worktree: /private/tmp/cred-v205`, mas o
   protocolo nao bloqueou essa condicao como P0.
4. O preflight anterior validava branch e arquivos, mas nao comparava
   `pwd`, `git rev-parse --show-toplevel` e `ThisWorkbook.Path`.

## Correcao aplicada

- Criado resgate visivel em
  `backups/raiz_canonica/20260524_134722/`.
- Colisoes locais da pasta canonica foram preservadas em
  `backups/raiz_canonica/20260524_134722/pre_switch_collisions/`.
- O worktree `/private/tmp/cred-v205` foi removido.
- A pasta `/Users/macbookpro/Projetos/Credenciamento` foi alternada para
  `codex/v12-0-0206-planejamento`.
- Os deltas V206 ja aprovados foram reaplicados na pasta canonica.
- `AGENTS.md` passou a declarar a raiz canonica obrigatoria.
- Criada a regra HBN
  `.hbn/knowledge/0012-raiz-canonica-projeto.md`.
- Readback/ERP 0082 foram anotados com a correcao de raiz canonica.
- Criado readback/ERP 0083 para esta correcao P0.

## Regra permanente

Toda IA deve executar antes de editar:

```bash
pwd
git rev-parse --show-toplevel
git status --short --branch
git worktree list
```

Aceite:

- `pwd` = `/Users/macbookpro/Projetos/Credenciamento`
- `git rev-parse --show-toplevel` =
  `/Users/macbookpro/Projetos/Credenciamento`
- branch V206 ativa na pasta canonica
- nenhum worktree V206 em `/private/tmp`

Se falhar, a IA deve parar e abrir P0 HBN. Nao pode produzir entregavel fora da
pasta do projeto.

## GitHub

A repercussao correta no GitHub e simples: commits e pushes da V12.0.0206 devem
partir da pasta canonica, na branch `codex/v12-0-0206-planejamento`. A release
oficial continua sendo V12.0.0205/tag `v12.0.0205`; este P0 nao altera a tag
nem a assinatura de nao regressao da V205.

## Importador V3

Com a raiz corrigida, o pacote importavel volta a ficar no caminho esperado pelo
workbook:

```text
\\Mac\Home\Projetos\Credenciamento\local-ai\vba_import\
```

Para o MD-33.0, o comando na Janela Imediata sera:

```vb
ImportarPacoteV3_Delta "MICRO62-V206-MD33-0", "a17c332+ONDA33.MD33.0-fix-relatorios"
```

Antes disso, rode:

```vb
ImportarPacoteV3_Status
```

O manifesto esperado do delta deve existir em:

```text
\\Mac\Home\Projetos\Credenciamento\local-ai\vba_import\000-MANIFESTO-V3-DELTA-MICRO62-V206-MD33-0.txt
```

## Fora de escopo

- Nao foi implementado motor PDF.
- Nao foram alteradas RN-01 a RN-17.
- Nao foram alterados contadores do RVS.
- Nao foi incluido teste de PDF nas seis baterias do RVS.
- `doc/` nao foi movido nem reorganizado.
- `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas` e `Svc_PreOS.bas` nao
  foram tocados.

## Proximo gate

1. Operador abre o workbook em `\\Mac\Home\Projetos\Credenciamento`.
2. Executa `ImportarPacoteV3_Status`.
3. Executa:

```vb
ImportarPacoteV3_Delta "MICRO62-V206-MD33-0", "a17c332+ONDA33.MD33.0-fix-relatorios"
```

4. Compila no VBE.
5. Roda `TV2_RunSmoke`.
6. Executa `ASS_REL_OS_EMP_LISTA` e `ASS_REL_EMP_SERV_LISTA`.
7. Com gate humano verde, a Onda 34 pode iniciar o motor PDF central.
