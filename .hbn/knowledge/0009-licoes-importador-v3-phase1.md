---
titulo: 0009 — Licoes aprendidas Importador V3 Phase 1
diataxis: explanation
hbn-track: knowledge
hbn-status: knowledge
audiencia: ambos
versao-sistema: V12.0.0203
data: 2026-05-01
---

# 0009 — Licoes aprendidas Importador V3 Phase 1

> Este documento e parte do protocolo de **fagocitose HBN**: cada vez que
> uma classe de bug aparece no codigo real, transformamos o conhecimento
> em formato canonico (hipotese / tese / evidencia / mitigacao) para
> impedir regressao em ciclos futuros.

## Por que existe

Entre 2026-04-29 e 2026-05-01 o projeto viveu **20 iteracoes** de
importador VBA: 13 hotfixes na V2 (que nao convergiram, ver
`IMPORTADOR_V2_DIAGNOSTICO_RETOMADA.md`) + 7 fixes na V3 do zero
(que convergiram em ~6 horas com cada fix baseado em evidencia
empirica do log).

A diferenca entre os dois ciclos e o que precisa virar memoria
institucional. As 9 licoes abaixo cobrem **todas** as classes de bug
que apareceram. Se um importador V4 (ou um importador para outro
projeto) reaparecer e violar alguma destas licoes, o documento aqui
e a referencia canonica para reverter.

## L1 — `cm.DeleteLines + cm.AddFromString` in-place nao e deterministico no Excel for Mac via SMB

| Campo | Valor |
|---|---|
| Hipotese | Editar in-place o `CodeModule` de um modulo .bas e equivalente a Remove + Import |
| Tese | **FALSO** no Excel for Mac com workbook em SMB share. `DeleteLines` deixa residuo intermitente; `AddFromString` empilha em cima e duplica codigo |
| Evidencia | V2 v5-v13 sofreu 13 hotfixes. `Util_Conversao.CountOfLines = 160` quando esperado 94. Compile manual subsequente falha com "Metodo ou membro de dados nao encontrado" |
| Mitigacao | V3 usa **`Remove + Import`** sempre para modulos .bas. So usa `DeleteLines + AddFromString` para forms (onde Remove perderia o `.frx`) e mesmo assim com loop ate `CountOfLines = 0` antes do `AddFromString` |

## L2 — Auto-import de importador e armadilha

| Campo | Valor |
|---|---|
| Hipotese | Importador VBA pode estar listado no proprio manifesto |
| Tese | **FALSO**. Quando um modulo se auto-importa, ele esta executando codigo enquanto seu proprio bytecode esta sendo substituido. Estado indefinido |
| Evidencia | V2 inicialmente tinha `Importador_V2.bas` no manifesto. Cada hotfix dependia de re-import. Resultado: comportamento erratico, com `Importador_V2.CodeModule.CountOfLines` divergindo do disco apos run |
| Mitigacao | V3 NAO esta no manifesto. Ha um `Importador_V3_Bootstrap.bas` separado (descartavel) que o operador importa **uma vez** manualmente, e um guard explicito em `IV3_ProcessarItem` recusa qualquer item cujo nome canonico seja `Importador_V3` ou `Importador_V3_Bootstrap` |

## L3 — Modos Fresh e Estabilizado precisam de caminhos distintos

| Campo | Valor |
|---|---|
| Hipotese | Um unico fluxo de import serve para workbook vazio e workbook ja com componentes |
| Tese | **FALSO**. Em workbook fresh: Mod_Types pode ser importado normalmente como AAA, e forms via `.frm + .frx` direto. Em workbook estabilizado: Mod_Types e tabu (skip se hash bate, abort se diverge) e forms via `.code-only.txt` para preservar `.frx` do designer |
| Evidencia | V2 tentava unificar e falhava intermitentemente — Mod_Types sempre tabu mesmo em fresh nao tinha sentido |
| Mitigacao | V3 detecta modo automaticamente (`VBComponents.Count <= 5` = Fresh) com flag explicita override. Cada modo tem caminho proprio em `IV3_ImportarModulo` e `IV3_ImportarForm` |

## L4 — UNC path mangling com normalizacao ingenua

| Campo | Valor |
|---|---|
| Hipotese | Colapsar separadores duplicados (`\\`) num path Windows e seguro |
| Tese | **FALSO** quando o path e UNC. Prefixo `\\Mac\Home\...` SAO duas backslashes legitimas. Loop `Do While InStr "\\"` destroi o prefixo, transformando `\\Mac\Home\` em `\Mac\Home\` |
| Evidencia | Log de Phase 1 run #2 mostrou `\Mac\Home\Projetos\...` em vez de `\\Mac\Home\...` apos passar pela normalizacao |
| Mitigacao | V3 detecta prefixo UNC antes do colapso, salva em variavel separada, faz colapso no resto, restaura prefixo no fim. Implementado em `IV3_ProcessarItem` |

## L5 — `Application.VBE.ActiveVBProject.Compile` nao e API estavel no Excel Windows

| Campo | Valor |
|---|---|
| Hipotese | A propriedade `.Compile` do VBProject e publica e funciona programaticamente |
| Tese | **FALSO** no Excel Windows recente (Office 365 Build 2024+). Lanca erro 438 "Object doesn't support this property or method" mesmo com workbook em estado compilavel. O menu manual `Depurar > Compilar VBAProject` continua funcionando |
| Evidencia | V3 Fix #4 chamava `Application.VBE.ActiveVBProject.Compile`. Log: `[V3 COMPILE FAIL] err=438 \| desc='O objeto nao aceita esta propriedade ou metodo' \| src='VBAProject'`. Mesmo apos remover Importador_V3 e re-instalar, compile manual passava mas programatico falhava |
| Mitigacao | V3 Fix #6 removeu `compile-after-each-group` do fluxo principal. Compile vira gate manual: operador roda `Depurar > Compilar VBAProject` no fim. Validacao automatica de cada item via `CountOfLines` ainda da sinal de saude |

## L6 — `Attribute` per-symbol em `.frm` nao funciona via `cm.AddFromString`

| Campo | Valor |
|---|---|
| Hipotese | Conteudo de `.code-only.txt` extraido de um `.frm` e diretamente injetavel via `cm.AddFromString` |
| Tese | **FALSO**. `.frm` exporta linhas como `Attribute mTxt.VB_VarHelpID = -1` que sao validas no formato `.frm` (processadas por `VBComponents.Import` direto). Quando passadas para `cm.AddFromString` num modulo de form, o parser do VBA esta em modo codigo normal e dispara "Erro de sintaxe" |
| Evidencia | Phase 1 run #3 importou 13 forms com `[V3 OK] FORM_ESTAB_OK` mas compile manual subsequente mostrou `Erro de sintaxe` em `Attribute mTxtFiltroCredLista.VB_VarHelpID = -1` no form `Credencia_Empresa` |
| Mitigacao | V3 Fix #7 adiciona `IV3_LimparAtributosCodeOnly` que strip qualquer linha comecando com `Attribute ` antes de passar pro `AddFromString`. VBE regenera os defaults quando precisar |

## L7 — Workbook em estado `[executando]` desabilita menu Compilar

| Campo | Valor |
|---|---|
| Hipotese | O menu `Depurar > Compilar VBAProject` fica habilitado sempre que ha codigo VBA |
| Tese | **FALSO**. Apos qualquer execucao parcial (incluindo macros que terminaram com erro fatal nao tratado), o VBE marca o projeto como `[executando]` e desabilita TODO o menu Depurar incluindo Compilar |
| Evidencia | Phase 1 run #2 imagem do menu Depurar com TODAS as opcoes greyed out. Titulo da janela mostrava `[executando]` |
| Mitigacao | Procedimento operacional sempre comeca com `Executar > Redefinir` (botao quadrado azul ou `Ctrl+Pause/Break`) antes de tentar Compilar. Documentado em `51_PROCEDIMENTO.md` Phase 1 passo "1.0 Reset" |

## L8 — Validacao `CountOfLines` deve ser contra conteudo TRANSFORMADO, nao raw

| Campo | Valor |
|---|---|
| Hipotese | Apos `cm.AddFromString conteudo`, o `cm.CountOfLines` deve igualar o numero de linhas do arquivo source bruto |
| Tese | **FALSO** quando ha transformacoes intermediarias. Se V3 strip Attributes (Fix #7), o conteudo passado para AddFromString tem MENOS linhas que o arquivo bruto. Validacao contra arquivo bruto gera false-failure |
| Evidencia | Apos Fix #7, primeira reexecucao iria reportar `linhasEsperadas=350 linhasReais=320 diff=30` em forms que tinham 30 Attribute lines stripadas |
| Mitigacao | V3 conta `linhasEsperadas` a partir do conteudo ja limpo (apos strip), nao do arquivo bruto. Implementado em `IV3_ImportarForm` validacao final |

## L10 — Standard module em VBA nao e qualificavel como `Modulo.Funcao(...)` em todas as versoes

| Campo | Valor |
|---|---|
| Hipotese | Em VBA, `Standard_Module.PublicFunction(...)` deve sempre funcionar (analogo a `Class.Method`) |
| Tese | **FALSO** em algumas versoes/contextos do Excel VBA. Standard modules nao sao referenciaveis como objeto. Member access `.Funcao` em standard module pode dar erro de compile "Metodo ou membro de dados nao encontrado" mesmo com a Public Function existindo |
| Evidencia | Microdelta 1.3 (Onda 10) injetou `strikesAtuais = Repo_Avaliacao.ContarStrikesPorEmpresa(os.EMP_ID, notaMin)` em Svc_Avaliacao. Import OK, mas Compile manual falhou destacando `.ContarStrikesPorEmpresa`. Verificacao revelou: nenhuma outra chamada do projeto qualifica `Repo_Avaliacao.<algo>` em codigo (so em comentarios). Padrao do projeto = chamada direta |
| Mitigacao | Para standard modules, sempre usar chamada DIRETA: `ContarStrikesPorEmpresa(os.EMP_ID, notaMin)` em vez de `Repo_Avaliacao.ContarStrikesPorEmpresa(...)`. Funcao publica unica no projeto resolve sem conflito. Se houver conflito de nome, renomear funcao ou usar prefixos (padrao IV3_, MLB_, etc.) |

**Regra para extracao de codigo da src/vba:** quando copiar bloco de
src/vba para o espelho, REMOVER qualificacao `Modulo.` em chamadas a
standard modules. Manter qualificacao apenas em chamadas a Class
modules.

## L9 — `MkDir` aninhado falha se pasta-pai nao existir

| Campo | Valor |
|---|---|
| Hipotese | `MkDir "backups\vba\<ts>-V3-FULL"` cria recursivamente as pastas pai |
| Tese | **FALSO** em VBA. `MkDir` so cria o ultimo nivel; se `backups\vba\` nao existir, falha com Err 76 "Path not found". V2 mascarava com `On Error Resume Next` global, V3 inicialmente herdou sem perceber |
| Evidencia | Phase 1 run #1: `Backup pre-import falhou. Abortando.` em workbook recem-restaurado onde a pasta `backups/` nunca tinha sido criada |
| Mitigacao | V3 Fix #4 adiciona `IV3_GarantirPasta` que (a) checa via `Dir` se pasta existe, (b) cria com MkDir, (c) tolera Err 75 (ja existe) e Err 58 (file already exists) re-checando via Dir, (d) loga falhas reais. `IV3_FazerBackupCompleto` chama o helper para cada nivel separadamente: `backups/`, `backups/vba/`, `backups/vba/<ts>-V3-FULL/` |

## Licoes meta — sobre o processo

### M1 — Hotfix sem evidencia perpetua o problema

V2 acumulou 13 hotfixes em 4 horas, cada um corrigindo um sintoma sem
atacar a causa raiz. Resultado: workbook em estado pior + operador
exausto. V3 fez 7 fixes em ~6 horas, **cada um baseado em log empirico**
da execucao anterior. Nenhum fix foi palpite.

**Regra:** se um fix nao tem evidencia direta no log do run anterior, NAO
escreve. Pede mais log.

### M2 — Strict validation com fail-fast e melhor que masking

V2 usava `On Error Resume Next` global que mascarava todas as falhas.
V3 elimina OERN global. Cada erro vira log + abort. Sintomas que V2
escondia ate gerarem corrupcao silenciosa, V3 expoe na primeira
execucao.

**Regra:** OERN apenas em blocos curtos com motivo justificado em
comentario. Nunca em scope de funcao inteira.

### M3 — Diagnostico verboso e mais barato que debug

V3 imprime no `Imediato` cada passo (`[V3 BACKUP] paths:`, `[V3 OK]
GRUPO_INICIO`, `[V3 COMPILE FAIL] err=438 desc=...`). Quando algo falha,
o operador cola o log e a IA tem evidencia exata do que aconteceu.

**Regra:** todo importador VBA deve logar antes de cada operacao
critica, incluindo paths montados, valores esperados vs obtidos, e
codigos de erro completos.

### M4 — `[executando]` no titulo e bloqueio de menus precisa estar no procedimento

Tres execucoes consecutivas de Phase 1 quase travaram porque o
operador nao tinha como saber que precisava resetar antes de compilar
(menu Compilar greyed out e nao mostra mensagem). Esse tipo de
quirk de UI precisa estar no procedimento operacional explicito,
nao na cabeca da IA.

**Regra:** procedimentos operacionais incluem o que NAO esta
intuitivo na UI do produto.

### M5 — Toda transformacao em pipeline precisa de validacao consistente

Quando V3 introduziu strip de Attribute (Fix #7), a validacao por
`CountOfLines` ainda comparava com o arquivo bruto — gerava false-
failure. Lesson: cada vez que voce transforma o conteudo entre
"source" e "applied", a validacao precisa ser contra o conteudo
applied, nao o source.

**Regra:** se `apply(transform(source))` e o que vai pra producao,
entao `validate(transform(source))` e o que valida.

### M6 — Smoke ad-hoc no Imediato com retorno UDT e antipadrao

Em Microdelta 1.2 (Onda 10) a IA propos como smoke check os comandos
`?Svc_Rodizio.Suspender("EMP_INEXISTENTE_TESTE").Sucesso` e variantes
com `Call`. Resultado: dois ciclos de erro improdutivos por causa de
limitacoes do VBA com acesso a membro de UDT em retorno direto de
funcao na janela Imediato. O operador (Mauricio, 2026-05-01 18:35)
trouxe a observacao filosofica:

> "Se usarmos sempre a interface de testes da propria plataforma
> podemos ter idempotencia inclusive nos testes e podemos ir
> melhorando e evoluindo os testes progressivamente, que e o
> objetivo dessa versao inclusive."

**Regra:** Smoke check de qualquer microdelta passa pela suite
oficial (`TV2_RunSmoke` por padrao). Nunca inventar smoke ad-hoc no
Imediato. Cada onda nova ACRESCENTA cenarios a suite — Onda 10
adiciona TV2_RunStrikes, Onda 11 adiciona TV2_RunCnae, etc. A
infraestrutura de teste evolui junto com a producao, fortalecendo
auditabilidade.

**Beneficio operacional:** TV2_RunSmoke (~30s) substitui smoke
ad-hoc + economiza tempo do operador. Trio minimo (~12min) so e
rodado UMA VEZ ao final de cada onda completa, nao a cada
microdelta. Estimativa de economia por onda: de ~72min para
~14min30s.

**Beneficio arquitetural:** A V12.0.0203 tem como objetivo formal
melhorar e evoluir os testes progressivamente. Cada microdelta que
ADICIONA cenarios de teste (Microdelta 1.4 grava defaults canonicos
de strikes; Microdelta 1.5 adiciona suite TV2_RunStrikes inteira) e
um avanco direto desse objetivo. Microdeltas que SO mexem em
producao podem usar TV2_RunSmoke porque a suite ja exercita
caminhos basicos.

**Como aplicar em Phase A.5 (Ondas 10-13):** todo microdelta termina
com `TV2_RunSmoke 14/0`. Onda inteira termina com trio mínimo + a
nova suite que aquela onda adicionou (ex.: Onda 10 termina com trio
+ TV2_RunStrikes 7/0).

## Como esta documentacao deve ser usada

1. **Onboarding de IA nova:** ler este doc INTEIRO antes de tocar
   qualquer importador VBA neste projeto.
2. **Onboarding de outro projeto VBA:** L1-L9 sao genericas o
   suficiente para servir de check-list em qualquer importador.
3. **Antes de propor fix em V3:** se a causa do bug nao bate com L1-L9
   ou M1-M5, OK propor; se bate com alguma das licoes ja documentadas,
   primeiro re-aplicar a mitigacao existente.
4. **Apos cada onda futura:** revisar este documento e adicionar
   licoes novas em L10+, M6+ se aparecerem padroes novos.

## Documentos relacionados

- `.hbn/relay/IMPORTADOR_V2_DIAGNOSTICO_RETOMADA.md` — historia bruta dos 13 hotfixes V2
- `.hbn/knowledge/0008-importador-v2-arquitetura.md` — 5 contratos
- `auditoria/03_ondas/onda_09_importador_v3/50_TECNICO.md` — V3 Phase 1 design
- `auditoria/03_ondas/onda_09_importador_v3/51_PROCEDIMENTO.md` — passo-a-passo operador
- `local-ai/vba_import/000-REGRA-OURO.md` — regra de ouro de import

## Versao

- v1.0 — 2026-05-01 — criacao inicial cobrindo L1-L9 + M1-M5 (7 fixes V3 + 13 hotfixes V2 sintetizados)
