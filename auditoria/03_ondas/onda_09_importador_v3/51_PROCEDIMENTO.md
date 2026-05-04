---
titulo: Onda 9 V3 — Procedimento operador (Phase 0 + Phase 1)
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0203
data: 2026-04-30
---

# Procedimento Onda 9 V3 — Phase 0 + Phase 1 (operador)

> Tempo estimado total: ~25 minutos. Faca em uma sessao continua para
> nao perder estado de cache do VBE entre passos.

## Pre-requisitos

- Excel for Mac aberto, mas SEM nenhum workbook do projeto aberto.
- VBOM habilitado: `Excel > Preferences > Security > Trust Center >
  Trust access to VBA project object model`. Se nao estiver, marque,
  feche o Excel completamente, reabra.
- Arvore `local-ai/vba_import/` presente em `~/Projetos/Credenciamento/`
  (deve estar — esta versionada). Confirme com `ls`.
- Pasta `V12-202-R/` intacta em `~/Projetos/Credenciamento/V12-202-R/`.

## Phase 0 — Restaurar baseline limpo (5 min)

### 0.1 Copia para a raiz do projeto (ao lado da pasta vba_import_v3_phase1/)

No Terminal:

```bash
cp "/Users/macbookpro/Projetos/Credenciamento/V12-202-R/29_04_2026 02_22_53PlanilhaCredenciamento-Homologacao.xlsm" \
   /Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-V3-test.xlsm
```

Abra `/Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-V3-test.xlsm`
no Excel (do disco LOCAL — NAO da pasta SMB `\\Mac\Home\...`).
Habilite macros se solicitado.

> **Por que esta pasta?** O Importador V3 procura `local-ai/vba_import_v3_phase1/`
> ao lado do .xlsm. Como a pasta de import esta em
> `/Users/macbookpro/Projetos/Credenciamento/local-ai/vba_import_v3_phase1/`,
> o workbook precisa estar em `/Users/macbookpro/Projetos/Credenciamento/`.

### 0.2 Confirmar baseline verde

Vai em `Desenvolvedor > Visual Basic` (ou Alt+F11). No Imediato (Ctrl+G):

```
?GetBuildImportado
```

Esperado: `f7aa84f+ONDA05-em-homologacao`.

Rode no Imediato:

```
CT_ValidarRelease_TrioMinimo
```

Esperado: trio minimo verde (V1=171/0, V2 Smoke=14/0, V2 Canonica=20/0).

> **Gate Phase 0:** se trio nao for verde, PARE. Algo esta errado com o
> baseline ou com o ambiente local. Reportar antes de avancar.

### 0.3 Salvar uma copia de seguranca

```bash
cp /Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-V3-test.xlsm \
   /Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-V3-PRE-IMPORT.xlsm
```

Esta copia e seu seguro de rollback se Phase 1 quebrar tudo.

## Phase 1 — Instalar V3 e re-importar o conjunto que ja compila (20 min)

### 1.1 Importar Bootstrap V3

No VBE com `PlanilhaCredenciamento-V3-test.xlsm` aberto:

1. `File > Import File`
2. Navegar ate `/Users/macbookpro/Projetos/Credenciamento/local-ai/vba_import_v3_phase1/Importador_V3_Bootstrap.bas`
3. Importar

Verifique que aparece o modulo `Importador_V3_Bootstrap` na arvore do VBE.

> **Atencao:** existe um `Importador_V3_Bootstrap.bas` em duas pastas
> (`local-ai/vba_import/` e `local-ai/vba_import_v3_phase1/`). Use sempre
> a versao em `vba_import_v3_phase1/` — e a que aponta para o pacote correto.

### 1.3 Rodar Bootstrap_V3

No Imediato (Ctrl+G):

```
Bootstrap_V3
```

Resultado esperado: MsgBox "Importador_V3 instalado com sucesso" com
~849 linhas. Aparece modulo `Importador_V3` na arvore.

> **Gate 1.3:** se Bootstrap falhar (VBOM, caminho errado, etc.), pare e
> reporte. Nao avance.

### 1.4 Status check

No Imediato:

```
ImportarPacoteV3_Status
```

Esperado:

```
=== ImportarPacoteV3_Status (V3.0-Phase1) ===
(nenhum import V3 executado nesta sessao)

MANIFESTO ESPERADO:
  /Users/macbookpro/Projetos/Credenciamento/local-ai/vba_import_v3_phase1/000-MANIFESTO-V3-PHASE1.txt
  STATUS: presente

MODO DETECTADO: Estabilizado
  (Estabilizado se VBComponents.Count > 5; Fresh caso contrario)
```

> **Gate 1.4:** modo deve ser **Estabilizado**. Se vier "Fresh", o
> baseline esta errado (workbook quase vazio). Reportar.

### 1.5 DryRun

No Imediato:

```
ImportarPacoteV3_DryRun
```

Resultado esperado: MsgBox confirmando OK com `M=35 | F=13 | err=0 | skip=0`
(ou `M=34 | F=13 | err=0 | skip=1` se Mod_Types for pulado em
modo Estabilizado — ambos aceitaveis).

Veja a aba `IMPORT_LOG_V3` (criada na primeira execucao). Deve ter
linhas para cada item com STATUS=OK e EVENTO=DRYRUN_ITEM.

> **Gate 1.5:** dryRun precisa rodar limpo antes do real. Se houver
> qualquer FALHA na coluna STATUS, parar e reportar.

### 1.6 Real

No Imediato:

```
ImportarPacoteV3
```

Aguarde. Pode demorar ~3-5 minutos (35 modulos + 13 forms + compile
por grupo + log).

Resultado esperado: MsgBox "Importador V3 concluiu OK" com
`M=35 F=13 err=0 skip<=1`.

> **Gate 1.6:** se houver qualquer FALHA na MsgBox ou na aba
> `IMPORT_LOG_V3`, V3 ja restaurou nada (a v1 nao implementa restore
> automatico). Voce restaura manualmente: feche sem salvar, abra a copia
> de seguranca de 0.3.

### 1.7 Compile manual

`Debug > Compile VBAProject`.

Esperado: nenhum erro.

> **Gate 1.7:** compile precisa ser limpo. Se houver erro de "Method or
> data member not found" (sintoma classico do bug V2), V3 nao resolveu
> o problema. Reportar imediatamente com print do erro e da linha.

### 1.8 Trio minimo

No Imediato:

```
CT_ValidarRelease_TrioMinimo
```

Esperado: V1=171/0, V2 Smoke=14/0, V2 Canonica=20/0. Status APROVADO.

> **Gate 1.8 (final):** trio verde = Phase 1 APROVADA. Salve o workbook
> com `Cmd+S` (ja esta no caminho final). Para promover, renomeie:
>
> ```bash
> mv /Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-V3-test.xlsm \
>    /Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-Homologacao-V3.xlsm
> ```

## Apos sucesso

Reporte de volta ao Claude:

- Conteudo da MsgBox final do `ImportarPacoteV3`
- Print da aba `IMPORT_LOG_V3` (ou export como CSV)
- Resultado do trio minimo (CSV em `auditoria/04_evidencias/V12.0.0203/`)
- Hash do workbook resultante (`shasum -a 256`)

Claude vai gerar o ERP em `.hbn/results/0009-exec-onda09-v3-phase1.json`
e abrir Phase 2.

## Em caso de falha

1. NAO tente hotfix iterativo (foi o que travou a V2 por 4h).
2. Feche workbook **sem salvar**.
3. Restaure de `/Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-V3-PRE-IMPORT.xlsm`.
4. Reporte ao Claude:
   - Em que Gate falhou (1.3, 1.4, 1.5, 1.6, 1.7, 1.8)?
   - Conteudo completo da `IMPORT_LOG_V3` (CSV se possivel)
   - Conteudo da janela Imediata
   - Print da arvore do VBE

Claude analisa, abre readback de correcao, e SO entao propoe fix.

## O que NAO fazer

- Nao tente importar Importador_V3 direto (ele nao se auto-importa).
  Sempre use Bootstrap.
- Nao rode `ImportarPacoteV3` sem antes ter rodado `_Status` e `_DryRun`.
- Nao salve o workbook entre falhas — pode mascarar estado corrompido
  no disco e impedir rollback limpo.
- Nao mova o `local-ai/vba_import_v3_phase1/` para outra pasta — V3 usa caminho
  relativo a `ThisWorkbook.Path`.
- Nao misture com `local-ai/vba_import/` (esse e do V2 legado). Para Phase 1
  use exclusivamente `vba_import_v3_phase1/`.
