---
titulo: Fagocitose VBA — padroes empiricos descobertos pelo protocolo usehbn
diataxis: explanation
hbn-track: knowledge
hbn-status: active
audiencia: ambos
versao-protocolo: usehbn 0.2.0
data: 2026-05-01
fonte: projeto Credenciamento V12.0.0203 (caso de uso)
---

# Fagocitose VBA — padrões empíricos descobertos pelo protocolo usehbn

> **Conceito de fagocitose (Mauricio Junqueira Zanin, 2026-05-01):** o
> protocolo usehbn, ao operar iterativamente sobre uma tecnologia
> antiga e mal-documentada, vai **incorporando micro-pílulas de
> conhecimento** descobertas por interação testada e idempotente. Cada
> bug encontrado vira lição canônica. Cada lição empilha-se em uma
> base de dados de padrões. Com sucessivas iterações, o protocolo se
> aproxima das bordas da tecnologia embarcada até "fagocitá-la
> completamente" — convertendo conhecimento implícito de décadas em
> base estruturada e auditável.

## Por que esse documento existe

O VBA (Visual Basic for Applications) é uma tecnologia comercialmente
viva desde 1993 mas com documentação oficial fragmentada. Existem
peculiaridades, antipadrões e armadilhas que são "folclore" entre
desenvolvedores experientes mas raramente documentados de forma
acessível para IAs ou times novos.

Este documento captura padrões VBA descobertos empiricamente durante
o projeto Credenciamento V12.0.0203 (sistema municipal de
credenciamento). Cada padrão veio de um bug real, foi diagnosticado
por interação iterativa, validado por gates objetivos (compile +
trio mínimo + smoke), e destilado para reutilização em outros
projetos.

## Estrutura de cada padrão

Cada padrão segue o formato canônico HBN:

| Campo | Significado |
|---|---|
| Hipótese | O que normalmente se assume sobre a tecnologia |
| Tese | Verdade empírica descoberta (geralmente "FALSO") |
| Evidência | Bug real + log + contexto onde apareceu |
| Mitigação | Como evitar/contornar — código ou processo |

Padrões com prefixo `L` são **técnicos** (limitações da tecnologia).
Padrões com prefixo `M` são **meta** (sobre o processo de
desenvolvimento).

---

## L1 — `cm.DeleteLines + cm.AddFromString` in-place não é determinístico no Excel for Mac via SMB

| Campo | Valor |
|---|---|
| Hipótese | Editar in-place o `CodeModule` de um módulo .bas é equivalente a Remove + Import |
| Tese | **FALSO** no Excel for Mac com workbook em SMB share. `DeleteLines` deixa resíduo intermitente; `AddFromString` empilha em cima e duplica código |
| Evidência | V2 v5-v13 sofreu 13 hotfixes. `Util_Conversao.CountOfLines = 160` quando esperado 94. Compile manual subsequente falha com "Método ou membro de dados não encontrado" |
| Mitigação | Use **`Remove + Import`** sempre para módulos .bas. Use `DeleteLines + AddFromString` apenas para forms (onde Remove perderia o `.frx`) e mesmo assim com loop até `CountOfLines = 0` antes do `AddFromString` |

## L2 — Auto-import de importador é armadilha

| Campo | Valor |
|---|---|
| Hipótese | Importador VBA pode estar listado no próprio manifesto |
| Tese | **FALSO**. Quando um módulo se auto-importa, ele está executando código enquanto seu próprio bytecode está sendo substituído. Estado indefinido |
| Mitigação | Importador NÃO está no manifesto. Bootstrap externo + guard explícito que recusa qualquer item cujo nome canônico seja o do próprio importador |

## L3 — Modos Fresh e Estabilizado precisam de caminhos distintos

| Campo | Valor |
|---|---|
| Hipótese | Um único fluxo de import serve para workbook vazio e workbook já com componentes |
| Tese | **FALSO**. Em workbook fresh: tipos podem ser importados normalmente e forms via `.frm + .frx` direto. Em workbook estabilizado: tipos são tabu (skip se hash bate, abort se diverge) e forms via `.code-only.txt` para preservar `.frx` do designer |
| Mitigação | Importador detecta modo automaticamente (`VBComponents.Count <= limiar` = Fresh). Cada modo tem caminho próprio |

## L4 — UNC path mangling com normalização ingênua

| Campo | Valor |
|---|---|
| Hipótese | Colapsar separadores duplicados (`\\`) num path Windows é seguro |
| Tese | **FALSO** quando o path é UNC. Prefixo `\\Mac\Home\...` SÃO duas backslashes legítimas. Loop `Do While InStr "\\"` destrói o prefixo |
| Mitigação | Detectar prefixo UNC antes do colapso, salvar em variável separada, fazer colapso no resto, restaurar prefixo no fim |

## L5 — `Application.VBE.ActiveVBProject.Compile` não é API estável no Excel Windows

| Campo | Valor |
|---|---|
| Hipótese | A propriedade `.Compile` do VBProject é pública e funciona programaticamente |
| Tese | **FALSO** no Excel Windows recente (Office 365 Build 2024+). Lança erro 438 "Object doesn't support this property or method" mesmo com workbook em estado compilável |
| Mitigação | Compile vira **gate manual** do operador (Depurar > Compilar VBAProject). Validação automática de cada item via `CountOfLines` ainda dá sinal de saúde |

## L6 — `Attribute` per-symbol em `.frm` não funciona via `cm.AddFromString`

| Campo | Valor |
|---|---|
| Hipótese | Conteúdo de `.code-only.txt` extraído de um `.frm` é diretamente injetável via `cm.AddFromString` |
| Tese | **FALSO**. `.frm` exporta linhas como `Attribute mTxt.VB_VarHelpID = -1` que são válidas no formato `.frm` (processadas por `VBComponents.Import` direto). Quando passadas para `cm.AddFromString` num módulo de form, o parser dispara "Erro de sintaxe" |
| Mitigação | Strip qualquer linha começando com `Attribute ` antes de passar pro `AddFromString`. VBE regenera os defaults quando precisar |

## L7 — Workbook em estado `[executando]` desabilita menu Compilar

| Campo | Valor |
|---|---|
| Hipótese | O menu `Depurar > Compilar VBAProject` fica habilitado sempre que há código VBA |
| Tese | **FALSO**. Após qualquer execução parcial (incluindo macros que terminaram com erro fatal não tratado), o VBE marca o projeto como `[executando]` e desabilita TODO o menu Depurar incluindo Compilar |
| Mitigação | Procedimento operacional sempre começa com `Executar > Redefinir` (botão quadrado azul ou `Ctrl+Pause/Break`) antes de tentar Compilar |

## L8 — Validação `CountOfLines` deve ser contra conteúdo TRANSFORMADO, não raw

| Campo | Valor |
|---|---|
| Hipótese | Após `cm.AddFromString conteudo`, o `cm.CountOfLines` deve igualar o número de linhas do arquivo source bruto |
| Tese | **FALSO** quando há transformações intermediárias |
| Mitigação | Conta `linhasEsperadas` a partir do conteúdo já limpo (após strip), não do arquivo bruto |

## L9 — `MkDir` aninhado falha se pasta-pai não existir

| Campo | Valor |
|---|---|
| Hipótese | `MkDir "backups\vba\<ts>-V3-FULL"` cria recursivamente as pastas pai |
| Tese | **FALSO** em VBA. `MkDir` só cria o último nível |
| Mitigação | Helper `IV3_GarantirPasta` que (a) checa via `Dir` se pasta existe, (b) cria com MkDir, (c) tolera Err 75/58, (d) cria cada nível separadamente |

## L10 — Standard module em VBA não é qualificável como `Modulo.Funcao(...)` em todas as versões

| Campo | Valor |
|---|---|
| Hipótese | Em VBA, `Standard_Module.PublicFunction(...)` deve sempre funcionar (análogo a `Class.Method`) |
| Tese | **FALSO** em algumas versões/contextos do Excel VBA. Standard modules não são referenciáveis como objeto. Member access `.Funcao` em standard module pode dar erro de compile "Método ou membro de dados não encontrado" mesmo com a Public Function existindo |
| Evidência | Microdelta 1.3 (Onda 10 Credenciamento) injetou `strikesAtuais = Repo_Avaliacao.ContarStrikesPorEmpresa(os.EMP_ID, notaMin)` em Svc_Avaliacao. Import OK, mas Compile manual falhou destacando `.ContarStrikesPorEmpresa`. Verificação revelou: nenhuma outra chamada do projeto qualifica `Repo_Avaliacao.<algo>` em código (só em comentários) |
| Mitigação | Para standard modules, sempre usar chamada DIRETA: `ContarStrikesPorEmpresa(...)`. Manter qualificação apenas em chamadas a Class modules. Se houver conflito de nome, renomear função ou usar prefixos (padrão IV3_, MLB_, etc.) |

**Reforço L10 (descoberto em Microdelta 1.5):** essa regra precisa
ser aplicada em CADA extração de bloco da `src/vba/`, mesmo quando o
mesmo padrão já apareceu em microdelta anterior. O VBE da fonte
aceita qualificação `Repo_Avaliacao.ContarStrikesPorEmpresa` localmente
(porque o módulo já está compilado), mas o destino (workbook em outra
sessão de compile) pode rejeitar. Em Microdelta 1.5 o bloco
`TV2_RunStrikes` herdou 4 ocorrências do mesmo padrão errôneo; foram
corrigidas em fix1.

**Checklist obrigatório quando extrair bloco de src/vba para espelho
minimalista:** rodar `grep -n "Modulo\.Funcao" <arquivo>` para qualquer
standard module mencionado. Substituir por chamada direta. Bumpar
build label apropriado.

## L11 — Defaults novos em getters quebram testes legados que dependem do estado natural

| Campo | Valor |
|---|---|
| Hipótese | Adicionar uma feature nova com getter (`GetMaxStrikes`) e default conservador (3) é compatível com testes legados que rodam em estado natural (sem pré-setup) |
| Tese | **FALSO** quando a feature nova é consultada em caminho crítico de produção (`Svc_Avaliacao` consulta `GetMaxStrikes`). Testes legados como `Bateria_Oficial.BO_330c_NotaMin_4_Suspende` rodam em CONFIG sem pré-setup, então o getter cai no default. Se default ≠ valor que reproduz comportamento legado, teste quebra |
| Evidência | Microdelta 1.5 fix1 da Onda 10 Credenciamento: TV2_RunSmoke (suite V2) passou 14/0 porque `TV2_PrepararBaselineCanonica` grava CONFIG MAX_STRIKES=1 antes. Mas V1 (Bateria_Oficial) rodou em CONFIG natural — `GetMaxStrikes` caiu no default 3 — bloco 7b de `Svc_Avaliacao` não suspendeu no 1° strike — `BO_330c_NotaMin_4_Suspende` falhou com mensagem "nota minima nao suspende" |
| Mitigação | **Defaults dos getters devem reproduzir o comportamento legado** quando CONFIG está vazia. Apenas quando o operador EXPLICITAMENTE configurar via UI deve o comportamento mudar para o valor "novo conservador". No caso Credenciamento: `GetMaxStrikes` default 3→1 (legado: 1° strike suspende). `GetDiasSuspensaoStrike` default 90→0 (legado: fallback meses). Operador override via `Configuracao_Inicial.frm` |

**Regra geral:** novo getter para feature condicional deve ter default
= valor-legado, não default = valor-novo-recomendado. Caso contrário,
qualquer teste que rode em estado natural quebra silenciosamente.

**Anti-padrão a evitar:**
```
Public Function GetNovaConfig() As Long
    ' ...
    falha:
        GetNovaConfig = NOVO_VALOR_RECOMENDADO  ' ← QUEBRA TESTES LEGADOS
End Function
```

**Padrão correto:**
```
Public Function GetNovaConfig() As Long
    ' ...
    falha:
        GetNovaConfig = VALOR_QUE_REPRODUZ_COMPORTAMENTO_ANTERIOR  ' ← preserva legado
End Function
```

**Validação que prova:** rodar suíte legada (V1/Bateria_Oficial) em
estado natural antes e depois da introdução do getter. Se algum teste
legado quebra, o default precisa mudar.

## L12 — Filtros defensivos do tipo `valor > 0` excluem casos limite legítimos

| Campo | Valor |
|---|---|
| Hipótese | Adicionar filtro `mediaVal > 0` em loop de varredura é uma boa prática defensiva contra dados não-preenchidos |
| Tese | **FALSO** quando o valor zero é semanticamente válido. Filtros que excluem zero quando `0` representa um caso real do domínio (nota mínima possível, contagem zero, etc.) introduzem bug silencioso no caso de borda |
| Evidência | Microdelta 1.5 fix3 da Onda 10 Credenciamento: `Repo_Avaliacao.ContarStrikesPorEmpresa` tinha filtro `mediaVal > 0# And mediaVal < notaCorte` para contar strikes (avaliações com media abaixo da nota mínima). `BO_330d_NotaMin_0_Suspende` testa especificamente todas-as-notas-zero (média = 0). Antes da Onda 1 esse caso suspendia (regra simples `media < notaMin`). Com o filtro `> 0` introduzido, media=0 não contava como strike, empresa não suspendia, teste falhava |
| Mitigação | Remover o `> 0`. A proteção contra valores não-numéricos já está garantida por `IsNumeric(mediaCelula)` antes do `CDbl`. A proteção contra linha não-avaliada já está garantida por `statusVal = STATUS_OS_CONCLUIDA`. Filtro `> 0` era redundante e introduziu falso negativo |

**Regra geral:** filtros defensivos não devem ser construídos por
intuição (`> 0` "pra evitar zero"). Cada filtro deve ter uma defesa
específica contra um cenário específico. Se a única defesa real é
contra texto vazio ou não-numérico, use `IsNumeric` ou
`Trim$(...) <> ""`. Se é contra status inválido, use o filtro de
status. **Não combine** os dois filtros em uma única expressão como
`> 0 And < N` — isso esconde a intenção e cria falsos negativos.

**Anti-padrão a evitar:**
```
If mediaVal > 0# And mediaVal < notaCorte Then  ' ← exclui zero legítimo
```

**Padrão correto:**
```
If IsNumeric(mediaCelula) Then        ' ← protege contra texto vazio
    mediaVal = CDbl(mediaCelula)
    If mediaVal < notaCorte Then       ' ← teste semântico real
        ...
    End If
End If
```

**Validação que prova:** testes de borda (zero, valor negativo se
permitido, valor exato no limite) devem ser exercidos
explicitamente em suíte oficial. No caso Credenciamento:
`BO_330b_NotaMin_5_NaoSuspende` (limite), `BO_330c_NotaMin_4_Suspende`
(abaixo do limite), `BO_330d_NotaMin_0_Suspende` (zero), `BO_330e_NotaMin_10_NaoSuspende`
(máximo) — todos juntos formam o cinturão de testes que pega
filtros defensivos errôneos.

## L13 — Testes end-to-end via fluxo natural são mais robustos que helpers de unidade que tentam enganar o sistema

| Campo | Valor |
|---|---|
| Hipótese | É possível testar uma feature condicional (ex: regra de strikes que depende de rodízio + avaliação + suspensão) via helpers de unidade que invocam diretamente as APIs internas, "simulando" a sequência de eventos |
| Tese | **FALSO** quando o fluxo real depende de mecanismos sistêmicos como rodízio (que decide qual entidade atender). Helpers que tentam "forçar" uma empresa específica via `EmitirPreOS(empId, ...)` falham porque a API não recebe `empId` — quem decide é o rodízio. Resultado: helper acha que está atendendo EMP1 três vezes, mas na verdade atende EMP1, EMP2, EMP3 (uma cada) |
| Evidência | Microdelta 1.5 fix1 da Onda 10 Credenciamento: `TV2_ConsumirStrikeEmpresa("001", 3)` chamado 3 vezes esperando 3 strikes para EMP1. Cenários `CS_AVAL_002/003/004/007` falharam (4/7) porque rodízio distribuía indicações entre as 3 empresas, e `ContarStrikesPorEmpresa("001")` só via 1 strike (a primeira indicação real para EMP1) |
| Mitigação | Substituir helpers de unidade por **suite end-to-end com cenário isolado** (`TV2_RunRodizioStrikesEndToEnd`). Cria atividade nova + 3 empresas dedicadas + credencia em ordem definida. Executa rodadas completas do rodízio com notas pré-distribuídas por empresa. O sistema funciona naturalmente; o teste apenas observa e valida. Resultado em fix4: TV2_RunStrikes (7 cenários quebrados) substituído por TV2_RunRodizioStrikesEndToEnd (~14 asserts, 100% verde, idempotente) |

**Anti-padrão a evitar:**
```
' "Forçar" empresa via parâmetro que não existe na API real
TV2_ConsumirStrikeEmpresa "001", 3, ...   ' empresa "001" não respeitada pelo rodízio
TV2_ConsumirStrikeEmpresa "001", 3, ...   ' atende EMP2 na verdade
TV2_ConsumirStrikeEmpresa "001", 3, ...   ' atende EMP3 na verdade
' ContarStrikes("001") = 1 (esperado 3) → teste falha por desconhecer rodízio
```

**Padrão correto:**
```
' Cenário isolado com fluxo natural
TV2_E2E_PrepararCenario   ' cria ATIV/SERV/EMPs dedicados
For i = 1 To 3
    TV2_E2E_RodadaCompleta NOTA_BAIXA, NOTA_ALTA, NOTA_ALTA  ' 1 volta do rodízio
    ASSERT EMP1.strikes = i  ' mecanismo nativo distribui corretamente
Next i
```

**Benefícios da abordagem end-to-end:**
- **Idempotência:** reset inicial garante mesmo resultado em N execuções
- **Manutenibilidade:** quando a regra de produção muda, suite quebra de forma diagnóstica (não por bug do helper)
- **Pedagógico:** suite vira manual executável da regra de negócio
- **Preparação para UI:** testes end-to-end por fluxo natural são o precursor de testes via interface (botões, formulários) — próxima fase do projeto Credenciamento
- **Auditabilidade:** cada `LogAssert` aparece em `RESULTADO_QA_V2` com timestamp + ID único

**Validação que prova:** rodar a mesma suite end-to-end 100 vezes em
sequência e confirmar resultado idêntico em todas. Se algum bit
mudar, há estado residual (não idempotente) ou bug de produção.

**Manipulação aceitável vs. inaceitável em testes end-to-end:**
- ✅ Manipular `DT_FIM_SUSP` para simular passagem de tempo (não viola fluxo de negócio)
- ✅ Cadastrar atividade/serviço/empresa novos para isolar (não viola rodízio)
- ❌ Manipular `COL_CRED_DT_ULT_IND` para forçar empresa no topo (viola integridade do rodízio)
- ❌ Chamar `Reativar()` manualmente quando o sistema deveria fazer automaticamente (esconde bug de reativação automática)

## L14 — Pre-flight check obrigatório de assinaturas e tipos UDT antes de gerar código novo

| Campo | Valor |
|---|---|
| Hipótese | É possível gerar código novo confiando na memória do que parece "óbvio" sobre nomes de campos UDT, assinatura de helpers e visibilidade (Public/Private) de funções compartilhadas |
| Tese | **FALSO**. Cada projeto VBA tem convenções idiossincráticas (lowercase vs CapitalCase em campos UDT, prefixos de visibilidade não óbvios, helpers Private em módulos vizinhos). Confiar na memória produz ciclo de erros encadeados |
| Evidência | Microdelta 1.5 da Onda 10 Credenciamento: implementação inicial da suite end-to-end teve **8 fixes encadeados** (fix1 → fix8) por falta de pre-flight. Cada fix descobriu um novo erro de assinatura/tipo: `Repo_Avaliacao.ContarStrikesPorEmpresa` (qualificação inválida — L10), defaults errados em getters (L11), filtro `> 0` incorreto (L12), `TV2_LogInfo` faltando 4º arg, `emp.DT_FIM_SUSPENSAO` (campo era `DT_FIM_SUSP`), `sel.Sucesso/EMP_ID` (TRodizioResultado tem `encontrou` e `Empresa.EMP_ID`), `TV2_NextDataRow` Private em outro módulo. Cada fix custou ~1 ciclo de operador (import + compile + relatar erro) |
| Mitigação | Antes de gerar QUALQUER código que use APIs internas, executar **pre-flight check obrigatório** que valida: (a) assinatura completa de cada Sub/Function chamada (incluindo número de args, tipos, opcionalidade); (b) campos exatos de cada UDT acessado (incluindo case correto e nome literal); (c) visibilidade Public/Private de cada símbolo cross-module |

**Protocolo de pre-flight check (obrigatório):**

```bash
# 1. Para cada Sub/Function chamada no código novo:
grep -B1 -A10 "Function NomeFunc\|Sub NomeFunc" <modulos relevantes>

# 2. Para cada UDT acessado (emp.X, sel.Y, res.Z):
sed -n '/^Public Type TNome/,/^End Type/p' <Mod_Types>

# 3. Para cada chamada cross-module:
grep "^Public" <modulo origem> | grep "NomeSimbolo"

# 4. Listar TODOS os símbolos referenciados no código novo
#    e verificar que cada um existe em algum módulo do baseline:
grep -oE "\b[A-Z][A-Za-z_0-9]+\b" <novo_codigo> | sort -u | \
  while read sym; do
    if ! grep -q "\b$sym\b" <baseline>/*.bas; then
      echo "AUSENTE: $sym"
    fi
  done
```

**Sinal claro de violação:** se você está corrigindo erros encadeados
(fix1, fix2, fix3...) no MESMO microdelta, o pre-flight não foi feito.
Cada fix consome tempo do operador; pre-flight é gratuito.

**Anti-padrão a evitar:**
```
' Gerar codigo confiando na memoria, sem grep de validacao:
strikesAtuais = Repo_Avaliacao.ContarStrikesPorEmpresa(...)  ' qualificacao invalida (L10)
emp.DT_FIM_SUSPENSAO  ' campo nao existe (era DT_FIM_SUSP)
sel.Sucesso  ' campo nao existe (era encontrou)
TV2_NextDataRow(...)  ' Private em outro modulo (era TV2_E2E_NextDataRow local)
```

**Padrão correto:**
```
' Antes de escrever cada linha, validar com grep:
grep "Sub|Function NomeChamada" <modulos>  → confirma assinatura
sed -n "/Type TUDT/,/End Type/p" Mod_Types  → confirma campos exatos
grep "^Public.*NomeFunc" <modulo>  → confirma visibilidade cross-module

' Resultado: codigo gerado compila no primeiro try (sem fix1-fix8)
```

**Validação que prova:** próxima suite end-to-end deve compilar
LIMPO no primeiro import V3, sem necessidade de fixes encadeados.
Se quebrar, é porque pre-flight não foi feito.

## L15 — Pasta de importação deve ser semanticamente homogênea (apenas artefatos vigentes de import)

| Campo | Valor |
|---|---|
| Hipótese | É natural deixar tudo relacionado a importação (vigente + descontinuado + documentação + ferramentas históricas + logs) na mesma pasta `vba_import/` para "manter junto" |
| Tese | **FALSO**. Pasta com mistura semântica vira fonte de confusão e erros silenciosos. IAs novas não distinguem o que é vigente vs descontinuado vs documentação. Operadores podem importar arquivo errado por engano (armadilha de path). Manifestos precisam de comentários `# EXCLUI:` para neutralizar arquivos órfãos — isso é cheiro de design ruim |
| Evidência | Projeto Credenciamento V12.0.0203 — pasta `local-ai/vba_import/` tinha (até consolidação Onda 10): `Importador_VBA.bas` (importador legado V1), `Importar_Agora.bas` (script descontinuado), 9 arquivos `.log` órfãos em `002-formularios/`, `AAW-Emergencia_CNAE.bas` (decidido fora do release), `ABK-Importador_V2.bas` (descontinuado em Onda 9). Cada item exigiu menção explícita `# EXCLUI:` no manifesto canônico. Operador (Mauricio, 2026-05-02): "isso pode preservar o erro" |
| Mitigação | **Pasta de importação contém APENAS:** `.bas` vigentes, `.frm`/`.frx`/`.code-only.txt` vigentes, manifestos ativos, regra de ouro (a regra do próprio sistema). **TUDO MAIS migra para outras pastas semânticas:** importadores históricos → `auditoria/<versao>/_historico_importadores_legados/`. Documentação geral → `docs/`. Logs → `/tmp/` ou `auditoria/logs/`. Macros descartáveis → fora do repo. README explicativo → migrar para `docs/` ou manter no canônico SE for sucinto e direto à regra |

**Anti-padrão a evitar:**
```
local-ai/vba_import/
├── 000-REGRA-OURO.md            ✓ (regra do sistema)
├── README.md                    ✗ (documentação geral, vai para docs/)
├── 000-LEIA-ME-PRIMEIRO.md      ✗ (idem)
├── 001-modulo/
│   ├── AAA-Mod_Types.bas        ✓
│   ├── AAW-Emergencia_CNAE.bas  ✗ (descontinuado, vai para historico/)
│   └── ABK-Importador_V2.bas    ✗ (legacy, vai para historico/)
├── 002-formularios/
│   ├── AAA-Fundo_Branco.frm     ✓
│   └── AAA-Fundo_Branco.log     ✗ (log orfao, fora do repo)
├── Importador_VBA.bas           ✗ (importador legado, vai para historico/)
└── Importar_Agora.bas           ✗ (script descontinuado, vai para historico/)
```

**Padrão correto:**
```
local-ai/vba_import/
├── 000-REGRA-OURO.md            (regra de import — única doc justificada aqui)
├── 000-MANIFESTO-V3-PHASE1.txt  (manifesto vigente)
├── 000-MANIFESTO-V3-DELTA-*.txt (manifestos delta vigentes)
├── 000-MAPA-PREFIXOS.txt        (mapeamento prefixo → modulo)
├── 001-modulo/
│   └── AAA-...AAZ-...ABK-*.bas  (apenas os 36 vigentes)
├── 002-formularios/
│   └── AAA-...AAM-*.frm/.frx/.code-only.txt (apenas os 39 vigentes)
└── Importador_V3_Bootstrap.bas  (bootstrap vigente do importador)

# Demais arquivos vivem em locais semanticamente apropriados:
auditoria/<versao>/_historico_importadores_legados/Importador_VBA.bas
auditoria/<versao>/_historico_importadores_legados/Importar_Agora.bas
docs/explanation/README-vba_import.md   (se houver doc explicativa)
```

**Regra geral:** se uma IA nova entrar no projeto e ler o conteúdo
da pasta de importação, o que ela vê DEVE ser exatamente o que será
importado. Sem ruído, sem ambiguidade, sem necessidade de filtro
mental. **Pasta de import = lista de coisas para importar. Ponto.**

**Benefício de manutenção:** manifestos não precisam mais carregar
listas `# EXCLUI:` para neutralizar lixo. Se está na pasta, está no
manifesto. Reduz superfície de erro.

**Validação que prova:** rodar `ls local-ai/vba_import/001-modulo/`
e contar contra `wc -l 000-MANIFESTO-V3-PHASE1.txt` (ou equivalente).
Se a quantidade de arquivos físicos = quantidade de entradas M| no
manifesto, a pasta está limpa.

---

## Padrões meta (M)

## M1 — Hotfix sem evidência perpetua o problema

V2 acumulou 13 hotfixes em 4 horas, cada um corrigindo um sintoma sem
atacar a causa raiz. Resultado: workbook em estado pior + operador
exausto. V3 fez 7 fixes em ~6 horas, **cada um baseado em log
empírico** da execução anterior.

**Regra:** se um fix não tem evidência direta no log do run anterior,
NÃO escreve. Pede mais log.

## M2 — Strict validation com fail-fast é melhor que masking

V2 usava `On Error Resume Next` global que mascarava todas as falhas.
V3 elimina OERN global. Cada erro vira log + abort.

**Regra:** OERN apenas em blocos curtos com motivo justificado em
comentário. Nunca em scope de função inteira.

## M3 — Diagnóstico verboso é mais barato que debug

V3 imprime no `Imediato` cada passo. Quando algo falha, o operador
cola o log e a IA tem evidência exata.

**Regra:** todo importador VBA deve logar antes de cada operação
crítica, incluindo paths montados, valores esperados vs obtidos, e
códigos de erro completos.

## M4 — `[executando]` no título e bloqueio de menus precisa estar no procedimento

Três execuções consecutivas de Phase 1 quase travaram porque o
operador não tinha como saber que precisava resetar antes de compilar
(menu Compilar greyed out e não mostra mensagem).

**Regra:** procedimentos operacionais incluem o que NÃO está
intuitivo na UI do produto.

## M5 — Toda transformação em pipeline precisa de validação consistente

**Regra:** se `apply(transform(source))` é o que vai pra produção,
então `validate(transform(source))` é o que valida.

## M6 — Smoke ad-hoc no Imediato com retorno UDT é antipadrão

Em Microdelta 1.2 (Onda 10) a IA propôs como smoke check os comandos
`?Modulo.Funcao(...).Sucesso` e variantes com `Call`. Resultado: dois
ciclos de erro improdutivos por causa de limitações do VBA com acesso
a membro de UDT em retorno direto de função na janela Imediato.

**Regra:** Smoke check de qualquer microdelta passa pela suite
oficial (`TV2_RunSmoke` no caso Credenciamento). Nunca inventar smoke
ad-hoc no Imediato. Cada onda nova ACRESCENTA cenários à suite — a
infraestrutura de teste evolui junto com a produção.

**Benefício operacional:** suite oficial (~30s) substitui smoke ad-hoc
+ economiza tempo do operador. Validações pesadas (~12min) só são
rodadas UMA VEZ ao final de cada onda completa.

**Benefício arquitetural:** o objetivo declarado da iteração é
melhorar e evoluir os testes progressivamente. Cada microdelta que
ADICIONA cenários é avanço direto desse objetivo.

---

## Como o protocolo usehbn fagocita tecnologias antigas

O ciclo de fagocitose tem 5 etapas:

1. **Encontro** — IA atua em código legacy. Bug aparece.
2. **Diagnóstico iterativo** — log + interação testada com operador
   humano. Iteração número N produz hipótese.
3. **Validação idempotente** — gate objetivo (compile + suite
   oficial). Hipótese aceita ou descartada.
4. **Destilação canônica** — bug confirmado vira padrão (formato L/M
   acima). Vai pro knowledge do projeto.
5. **Propagação para protocolo** — padrão promovido para o documento
   canônico do usehbn (este arquivo). Disponível para qualquer
   projeto que use o protocolo no futuro.

Cada padrão fagocitado **reduz a borda inexplorada** da tecnologia
embarcada. Após N iterações, IAs novas podem operar com segurança em
áreas que antes exigiam horas de trial-and-error.

## Estado atual da fagocitose VBA

Coberto até 2026-05-01:

- **Importação programática de código** (L1, L2, L3, L4, L8, L10)
- **Limitações da API do VBE** (L5, L6, L7)
- **Sistema de arquivos via VBA** (L9)
- **Antipadrões de processo** (M1-M6)

Bordas ainda inexploradas (futuras ondas trazem mais):

- Performance de import com workbooks grandes (>100 módulos)
- Comportamento em Excel for Linux via Wine
- Interação com Outlook automation (`Outlook.Application`)
- Forms com ActiveX controls de terceiros
- Recursos novos do Office 365 (`LAMBDA`, `LET`, etc.)

## Manutenção deste documento

Cada projeto que use o protocolo usehbn e descubra novo padrão deve:

1. Documentar a lição no formato canônico no knowledge local
2. Após validação por gate objetivo (suite oficial verde), promover
   para este documento
3. Atualizar a seção "Estado atual da fagocitose"
4. Citar no commit message o número da lição (`[fagocitose] L11
   adicionada — descricao curta`)

Manutainer atual: Mauricio Junqueira Zanin + Claude Opus 4.7 (Cowork).

## Documentos relacionados

- `INTEGRATION-VBA-IMPORTER.md` — padrão arquitetural do importador
- `INTEGRATION-GLASSWING.md` — vetores de cybersegurança preventiva
- `INTEGRATION-CLA-CONTROLLED-ACCESS.md` — quando manter tooling restrito
- `CASE-STUDY-CREDENCIAMENTO.md` — caso de uso completo

---

## Apêndice — Lições e meta-lições da Onda 11 (V12.0.0203-rc1, 2026-05-02)

> Append-only conforme protocolo de fagocitose. Preserva L1-L15 +
> M1-M6 originais. Promovidas para este documento após gate objetivo
> verde no Quarteto Mínimo (`VR_20260502_054314` = APROVADO).

### L16 — Anti-vazamento de CONFIG entre suites

**Contexto.** A suite E2E (`TV2_RunRodizioStrikesEndToEnd`) precisava
escrever `MAX_STRIKES=3` e `DIAS_SUSPENSAO_STRIKE=90` na aba
`CONFIG` para forçar comportamento parametrizado em 3 voltas de
fluxo natural. A regra de produção lê via
`Util_Config.GetMaxStrikes` direto da aba — não há *config sandbox*.

**Sintoma.** Após a suite E2E rodar e passar 64/0, a `V1 Bateria
Oficial` rodou logo depois com 4 falhas em testes legados
(`BO_330c/d/f/g`) que esperavam comportamento padrão
(`MAX_STRIKES=1`). Causa: CONFIG ficou contaminada com os valores
da suite anterior.

**Anti-padrão.** Suite que muda estado global (CONFIG, abas
operacionais, AUDIT_LOG) e não restaura ao final, contaminando a
próxima suite que rode no mesmo workbook.

**Padrão.** Toda suite que mude CONFIG deve restaurar baseline em
*ambos* os caminhos: sucesso *e* falha (try/finally simulado em
VBA via `On Error GoTo` + label `falha:` que chama o helper de
restauração antes do `Exit Sub`/`End Sub`). Helper canônico:
`TV2_E2E_RestaurarConfigBaseline` grava `MAX_STRIKES=1`,
`DIAS_SUSPENSAO_STRIKE=0` (legado) com `On Error Resume Next` local
(cleanup helper não pode quebrar suite chamadora).

**Generalização.** Qualquer suite que escreva em estado compartilhado
(CONFIG, parâmetros operacionais, abas auxiliares) precisa de helper
de restore + chamadas redundantes nos dois caminhos. Equivale a
`try/finally` em linguagens com construct nativo.

### L17 — Instrumentação cirúrgica antes de fixar

**Contexto.** DT-3 (12 falhas em E2E Strikes) tinha N hipóteses
plausíveis: padding de IDs, ordem de seleção, persistência de
CAD_OS, lookup em ContarStrikesPorEmpresa, vazamento CONFIG, etc.
Tentar fixar uma hipótese por vez sem evidência objetiva levaria a
ciclos de hotfix encadeados (cada fix expõe próxima causa, sem
fechamento garantido).

**Anti-padrão.** "Tentar fix → rodar suite → ver outra falha →
tentar outro fix". Caminho do pessimismo: cada iteração custa ~2 min
de suite + risco de mascarar causa raiz.

**Padrão.** Antes de qualquer fix em região com múltiplas hipóteses,
adicionar marcadores `DIAG_*` por etapa (PRESEL, PREOS,
PREOS_INTEGRITY, OS, AVAL_POS) que registram *fato observável* (qual
EMP, qual ID, qual estado). Operador roda 1x; CSV revela exatamente
em qual etapa a expectativa diverge da realidade. Causa raiz é
*observada*, não *adivinhada*.

**Generalização.** Em código com efeito colateral em múltiplas
camadas (rodízio → preselecionar → emitir → avaliar → strikes →
suspender), a fronteira entre as camadas precisa ter marcadores
explícitos antes de RCA. Custo: 5-10 linhas de log por região.
Benefício: 1 ciclo em vez de N.

### L18 — Determinismo > narrativa pedagógica

**Contexto.** O cenário E2E foi desenhado pedagogicamente: "EMP1
acumula strikes em 3 voltas, suspende, espera DT_FIM_SUSP, reativa".
Os asserts iniciais refletiam essa narrativa: "loop até suspender,
verifica que a contagem está N". Mas o *fato real* do sistema é
determinístico: na Etapa E (após N voltas), strike count == N
exatamente, suspensão acontece em N=MAX_STRIKES. Fato real ≠
narrativa idealizada (ex.: padding de IDs causava "ATIV=999" virar
"999" em algumas chamadas e "0999" em outras, quebrando narrativa
mas não a lógica determinística).

**Anti-padrão.** Asserts que descrevem narrativa pedagógica do que o
operador *acha* que vai acontecer. Eles passam quando narrativa
casa com fato; falham quando narrativa idealiza demais.

**Padrão.** Asserts que verificam *fatos do sistema*: valores
exatos esperados após operação, com comentário-vacina explicando
*por que* aquele valor (não a narrativa). Exemplo na Etapa E
da E2E: "após 3 voltas, strike count = 3 exato" + comentário "3
porque MAX_STRIKES=3 em CONFIG e cada nota baixa incrementa 1".

**Generalização.** Tests refletem comportamento determinístico do
sistema, não roteiro pedagógico. Comentários-vacina (em vez de
nomes pedagógicos) protegem contra futura tentação de "humanizar"
o teste e voltar à narrativa.

### M7 — Auditor de espelho deve hashar src vs canonical antes de RCA

**Contexto.** Antigravity (IA terceira na cadeia 2026-05-02) tentou
diagnosticar DT-3 lendo `src/vba/Teste_V2_Roteiros.bas`. Diagnóstico
errado: a versão em `src/vba` não tinha os fixes acumulados das
MD-1/2 (apenas o canônico em `local-ai/vba_import/` tinha). Drift G7
não detectado a tempo desperdiçou 1 ciclo de RCA.

**Anti-padrão (meta).** Iniciar análise de causa raiz lendo
"qualquer cópia disponível" do código sem verificar primeiro qual é
o canônico vigente vs versão divergente.

**Padrão (meta).** Auditor (humano ou IA terceira) que vai propor fix
sobre código deve, em pre-flight, calcular `shasum src/vba/<arquivo>`
e `shasum local-ai/vba_import/001-modulo/<prefixo>-<arquivo>`. Se
divergem, marcar 🟠 `HBN SOURCE DRIFT DETECTED` e parar antes do RCA.
Suprimir hipóteses até drift ser resolvido (sync ou divergência
documentada como D1).

**Generalização.** Em qualquer projeto com fonte canônica + espelhos
(import packages, build artifacts, distros), pre-flight de drift é
gate obrigatório de RCA. Padrão de marker visual `🟠 SOURCE DRIFT
DETECTED` ajuda IAs a parar antes de propagar diagnóstico contra
código errado.

### Estado atual da fagocitose após Onda 11

Lições estabelecidas: **L1-L20** (20 padrões positivos).
Meta-lições: **M1-M11** (11 anti-padrões de processo).

Bordas validadas adicionais (Onda 11):

- **Cleanup de estado compartilhado** (L16) — try/finally simulado em VBA
- **Instrumentação pré-RCA** (L17) — marcadores `DIAG_*` por região de fronteira
- **Asserts factuais** (L18) — sistemas deterministas exigem testes deterministas
- **Pre-flight de drift** (M7) — auditor que pula é fonte de RCA defeituosa

---

## Apêndice — Lições Onda 16 (V12.0.0203 → fechamento parcial 2026-05-03)

> Append-only. Onda 16 entregou MD-16.1 (textos Central V12+V2), MD-16.2
> (DURACAO_MS), MD-16.3 fix1 (EVOLUCAO_TESTES). MDs 16.4-16.6 foram
> cancelados após sequência de regressões (4 imports iterativos no mesmo
> form em ~3h corromperam o workbook). Lições destiladas das falhas:

### L19 — InputBox/MsgBox grandes precisam de variável `prompt` acumulada

VBA tem limite empírico ~25 line continuations consecutivas (`_`) no
mesmo statement. Excedeu → erro 40192 "Erro de definição de aplicativo
ou de objeto" no Importador V3. Padrão correto:

```text
Dim prompt As String
prompt = "linha 1" & vbCrLf
prompt = prompt & "linha 2" & vbCrLf
... (cresce livremente)
op = InputBox(prompt, "Titulo", "default")
```

### L20 — Hash determinístico em VBA: `Double` + módulo manual, nunca `Long`

Algoritmos com multiplicação acumulada (DJB2, FNV) estouram `Long`
signed (max 2³¹-1) após poucas iterações. Solução:

```text
Const MOD32 = 4294967296#  ' 2^32
Dim h As Double
h = h * 33# + CDbl(AscW(c))
If h >= MOD32 Then h = h - (Int(h / MOD32) * MOD32)
```

Erro Overflow (Err 6) propagado para handlers `On Error Resume Next`
mascara `Err.Number=0` → diagnóstico fica cego. Marker: cenário com
`Err=0 Desc=""` em handler genérico aponta para overflow silenciado.

### M8 — Suite de gate de release deve cobrir TODA superfície que pode regredir

Quarteto (V1+V2_Smoke+V2_Canonica+E2E_Strikes) **não exercita UI
guiado**. Refatorações em forms passaram pelo gate sem detectar
regressão de filtro de busca (lista vazia ao abrir). Solução:
estender gate com suite UI (`TV2_RunUiFiltros`) cobrindo cada
filtro do projeto antes de qualquer mexida em form.

### M9 — Forms VBA têm DOIS espelhos no pacote canônico — manter sincronia obrigatória

Cada form em `local-ai/vba_import/002-formularios/` tem **2 arquivos
de código**: `.frm` (com cabeçalho do designer) e `.code-only.txt`
(espelho de código puro para reimport seguro sem tocar `.frx`).
Importador V3 modo Estabilizado **prefere `.code-only.txt`**. Edição
em `.frm` sem propagar para `.code-only.txt` (ou vice-versa) faz V3
importar versão errada silenciosamente. Pre-flight L14 deve incluir
comparação dos dois lados antes de declarar gate.

### M10 — Cap de 1 import por form por dia, com gate verde entre cada

Iteração rápida de imports no mesmo form (4× em ~3h) deixa estado
interno do workbook inconsistente. Sintomas: erro de automação
"Objeto chamado foi desconectado de seus clientes", crashes de Excel
ao compilar, refs WithEvents quebradas. **Mitigação**: limitar a
1 import por form por dia (após gate verde da onda anterior). Em
caso de regressão, voltar a backup e replanejar — não iterar mais.

### M11 — Primazia documentada deve ser honrada mesmo sob iteração rápida

`AGENTS.md §62-63` é inequívoco: **`src/vba/` é fonte de verdade**;
`local-ai/vba_import/` é **espelho com prefixos**. Sob pressão de
microdeltas, IA pode pegar atalho de editar primeiro o canônico em
`local-ai/vba_import/` e copiar para `src/vba/` — exatamente o
**inverso** do documentado. Cada vez que isso acontece, normaliza
um caminho que deveria ser exceção e erode a regra silenciosamente.

Esta é a mesma classe de regressão de
[`auditoria/00_status/32_ERRO_E_CORRECAO_PASTA_CANONICA.md`](../../auditoria/00_status/32_ERRO_E_CORRECAO_PASTA_CANONICA.md)
da Onda 10 (criar pasta paralela), apenas em outra dimensão (inverter
primazia entre pastas existentes).

**Mitigação obrigatória**: pre-flight L14 em cada microdelta começa
com `Read src/vba/<arquivo>` antes de qualquer edição. Passo 2
(espelhar para `local-ai/vba_import/`) é checklist explícito no
procedimento de import. Hash de validação valida **`shasum
src/vba/X == shasum local-ai/vba_import/<prefixo>-X`** com `src/vba/`
como lado autoritativo.

### Estado atual da fagocitose após Onda 16

Lições estabelecidas: **L1-L20** (20 padrões positivos).
Meta-lições: **M1-M11** (11 anti-padrões de processo).

---

## Apêndice — Lições Onda 17 (V12.0.0203 → MD-17.1.b fechada com fix2 em 2026-05-03)

> Append-only. Onda 17 entregou MD-17.1.a (Engine FixtureFactory +
> namespacing + RestaurarConfigBaseline generalizado + TV2_NextDataRow
> Public) e MD-17.1.b (5 cenários novos com débito DT-17-REATIV-STRIKES
> documentado AMARELO). Quarteto VR_20260503_031425 APROVADO com
> sintaxe `V1=171/0+V2_Smoke=14/0+V2_Canonica=23/0+E2E_Strikes=65/0`.
> Lições destiladas das falhas e descobertas:

### L21 — Helpers VBA antigos com coerção via `Val()` invalidam convenções alfanuméricas posteriores

**Contexto.** Em MD-17.1.a, `TV2_FixtureFactory` foi criada gerando
ATIV_ID alfanumérico `"F_<escopo>_<seq>"` para isolar fixtures por
namespace. Pre-flight L14 verificou assinatura de `TV2_CredenciarAtividade`
mas **não auditou o que ela faz internamente** com o ATIV_ID recebido.

**Sintoma.** Quarteto reprovado em VR_20260503_020405. 4 cenários FF
(CS_BORDA_MAX2/MAX5/NOTA_ZERO + CS_E2E_5EMPS) com `STRIKES=0,
STATUS=ATIVA` apesar de receber notas baixas em múltiplas voltas.

**Causa raiz.** `TV2_CredenciarAtividade` chama internamente
`TV2_Pad3(ativId)` (Engine §1875): `Format$(CLng(Val(valor)), "000")`.
Para `ativId="F_SBM2_01"`, `Val()` retorna `0`. COL_CRED_ATIV_ID
gravado como `"000"`. SelecionarEmpresa busca por ATIV_ID original e
não encontra nenhuma empresa apta. Nenhum ciclo executa. Nenhum strike.

**Anti-padrão.** Pre-flight L14 que verifica apenas assinatura de
funções chamadas, sem auditar comportamento interno com argumentos
do tipo introduzido pela nova convenção.

**Padrão.** Pre-flight L14 reforçado: para cada função chamada com
argumento de **tipo/formato novo** (alfanumérico onde antes era
numérico, etc.), seguir o caminho do argumento dentro da função
chamada e verificar se há **coerções implícitas** (`Val`, `CLng`,
`CDbl`, `CStr`, `Format$`, etc.) que possam alterá-lo silenciosamente.

**Validação que prova.** Em MD-17.1.b-fix1, ATIV_ID em FixtureFactory
passou a ser numérico (3 dígitos via hash determinístico do escopo,
faixa 900-979). Compatível com TV2_Pad3. Quarteto VR_20260503_031425
APROVADO com cenários FF executando ciclo real.

### M12 — Smoke testes em janela Imediato só funcionam para símbolos `Public`

**Contexto.** Procedimento de import MD-17.1.a sugeriu smoke teste
opcional via janela Imediato:

```
Dim eo() As String, mo() As String, ao() As String
TV2_FixtureFactory "TFF", 0, 2, 1, eo, mo, ao
?mo(1)
```

**Sintoma.** Operador rodou os comandos mas não capturou outputs
individualmente — colou apenas a sequência de comandos sem os valores
retornados. Bug latente em FixtureFactory passou despercebido na MD-17.1.a;
só foi exposto em MD-17.1.b quando 4 cenários falharam.

**Causa raiz.** Smoke teste em janela Imediato sem assert explícito
mascara bug latente. Procedimento dependia de operador comparar visualmente
output vs. esperado, sem evidência cogente.

Adicionalmente: helpers Private de módulo (como `TV2_FF_HashEscopoParaAtivId`
introduzido em fix1) **não são chamáveis pela janela Imediato** —
gera erro "Sub ou Function não definida" mesmo com a função existindo.
Smoke teste do procedimento fix1 incluiu `?TV2_FF_HashEscopoParaAtivId("SBM2")`
que falhou por design.

**Anti-padrão.** Procedimento de import com smoke teste opcional via
janela Imediato sem (a) asserção de output mínimo nem (b) verificação
de visibilidade Public dos símbolos referenciados.

**Padrão.** Procedimento de import com smoke teste deve:

- Listar **somente** funções `Public` na janela Imediato
- Especificar **valor exato esperado** para cada `?<func>(...)`
- Tornar o smoke obrigatório (não opcional) quando o microdelta
  introduz primitiva que outros microdeltas dependerão
- Se símbolo for Private mas precisar de smoke, criar um wrapper
  Public temporário ou expor via uma suite de teste regular

**Generalização.** Bug latente em primitiva criada em microdelta N só
aparece quando microdelta N+1 a usa em escala. Se o smoke do N for
fraco, o custo recai integralmente em N+1.

### M13 — Janela Imediato é runtime global; helpers Private de módulo são invisíveis

**Contexto.** Mesma raiz de M12 mas formalizada separadamente: a janela
Imediato do VBE executa código no escopo "global" da aplicação. Funções
declaradas como `Private` em qualquer módulo NÃO são acessíveis da
janela Imediato — apenas funções `Public`.

**Anti-padrão.** Recomendar `?<helper_private>(args)` em procedimento.

**Padrão.** Listar apenas `Public Sub`/`Public Function` em smoke testes.
Para validar helpers Private, usá-los via uma função Public que os
chame internamente, ou via cenário de teste regular.

### M14 — Plano de fix em onda multi-microdelta deve cobrir TODAS as opções de rollback (CRÍTICA)

**Contexto.** Em MD-17.1.b-fix1, IA executora ofereceu duas opções de
rollback ao operador (Opção A: restaurar workbook salvo em microdelta
N-1; Opção B: sobrescrever no estado atual N). Recomendou textualmente
Opção A. Mas o **manifesto do fix1** foi montado mentalmente assumindo
Opção B (com Roteiros já importado), incluindo apenas Engine + App_Release.

**Sintoma.** Operador seguiu recomendação (Opção A). Restaurou
workbook MD-17.1.a, importou MICRO17-fix1, rodou Quarteto.
VR_20260503_025114 APROVADO mas com sintaxe `V2_Canonica=20/0+E2E_Strikes=64/0`
(números pré-MD-17.1.b). Os 5 cenários novos da MD-17.1.b não foram
executados. **Quarteto verde mas validando estado incompleto.**

**Causa raiz.** Recomendação textual da IA e o pacote técnico do fix
ficaram **incoerentes**. IA assumiu uma escolha do operador que era
diferente da que ela mesma havia recomendado. Falha de revisão
de coerência interna do plano.

**Custo real.** ~30 minutos de trabalho extra do operador (madrugada,
2:50—3:30 BRT em 2026-05-03). 2 sequências completas de import + Quarteto
necessárias. Tokens desperdiçados. Documentação completa em
[`auditoria/00_status/45_ERRO_E_CORRECAO_FIX1_INCOMPLETO_MD17_1_b.md`](../../auditoria/00_status/45_ERRO_E_CORRECAO_FIX1_INCOMPLETO_MD17_1_b.md).

**Anti-padrão.** Quando IA oferece N opções de rollback ao operador,
montar pacote do fix considerando apenas UMA das opções (geralmente a
"que daria menos trabalho do código novo a importar").

**Padrão.** Pacote do fix em onda multi-microdelta DEVE incluir **todos
os arquivos modificados desde o último checkpoint estável** anterior ao
microdelta com falha — mesmo que algumas dessas modificações já estejam
no estado atual em algumas opções de rollback. V3 sobrescreve
idempotente; o custo de incluir um arquivo "redundante" é zero, mas o
custo de NÃO incluir é um round inteiro extra.

**Pre-flight obrigatório M14 (checklist mental antes de gerar manifesto de fix):**

1. Listar todos os arquivos modificados desde o último checkpoint
   estável anterior ao microdelta com falha:
   `git diff <checkpoint>..HEAD -- src/vba/ local-ai/vba_import/`
2. Para cada opção de rollback que vai oferecer:
   - Em qual estado o workbook fica após o rollback?
   - Quais arquivos da lista NÃO estão refletidos nesse estado?
   - Esses arquivos PRECISAM estar no manifesto do fix.
3. União dos arquivos a importar = união entre todas as opções de rollback.
4. Manifesto do fix DEVE conter essa união.

**Validação que prova M14 aplicada.** No final da execução do fix:

- Sintaxe do Quarteto bate com a esperada **exata** (não apenas
  RESULTADO_GERAL=APROVADO)
- Cada cenário novo introduzido nas microdeltas anteriores aparece com
  o status esperado em RESULTADO_QA_V2

**Marker HBN V2 candidato.** `🟠 HBN ROLLBACK PLAN INCOMPLETE` — IA
detecta durante geração de plano de rollback que o pacote do fix não
cobre todas as opções oferecidas. Análogo a `🟠 HBN SOURCE DRIFT
DETECTED` mas para inconsistência interna do plano de fix.

### Estado atual da fagocitose após Onda 17 (parcial — MD-17.1.b fechada)

Lições estabelecidas: **L1-L21** (21 padrões positivos).
Meta-lições: **M1-M14** (14 anti-padrões de processo, 3 novos nesta onda
expondo gaps de pre-flight L14, fragilidade do smoke ad-hoc, e
incoerência texto-pacote em planos de fix).

Bordas validadas adicionais (Onda 17 MD-17.1.a + MD-17.1.b):

- **Hash determinístico para namespacing numérico** (L21) — coerções
  ocultas via `Val()` exigem números puros nas APIs antigas
- **Smoke obrigatório com asserção** (M12) — bug latente em primitiva
  criada em N só aparece quando N+1 usa em escala
- **Visibilidade Public de smoke** (M13) — janela Imediato não enxerga
  helpers Private
- **Coerência texto-pacote em fix multi-microdelta** (M14) — recomendação
  e pacote técnico devem cobrir o caminho recomendado

---

## Apêndice — Lições Onda 17 MD-17.1.c real (V12.0.0203 → fechada em 2026-05-03 com fix3)

> Append-only. MD-17.1.c real introduziu `TV2_RunUiSmokeReadOnly` (smoke
> read-only de UI) cobrindo 4 forms × 5 verificações (V1-V5). Foram 3
> rounds de fix (fix1, fix2, fix3) ANTES do Quarteto verde, por bugs
> específicos sobre UI VBA que NÃO estavam destilados nas Ondas 11-16.
> Este apêndice oficializa essas lições para evitar erros recorrentes.

### READ-FIRST checklist para trabalho em UI/forms VBA

Antes de qualquer microdelta que toque suite de UI smoke, leia:

- **M9** (sync .frm/.code-only.txt — agora ampliada por L22+L24)
- **L22** (estrutura interna .frm vs .code-only.txt)
- **L23** (controles dinâmicos via Me.Controls.Add)
- **L24** (gamma textual VBA precisa skip linhas vazias)
- **M15** (V3 cm.AddFromString pode falhar Err=50132)
- **M16** (reproduzir algoritmo VBA em bash/python antes de import)
- **M17** (derivar canônico de UI requer leitura completa)

### L22 — Estrutura .frm vs .code-only.txt difere por bloco de cabeçalho de form

**Contexto.** `.frm` exportado pelo VBE tem cabeçalho de 11+ linhas
ANTES do código:

```text
VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} <FormName>
   Caption         =   "..."
   ClientHeight    =   ...
   ClientLeft      =   ...
   ClientTop       =   ...
   ClientWidth     =   ...
   OleObjectBlob   =   "<FormName>.frx":0000
   StartUpPosition =   ...
End
Attribute VB_Name = "<FormName>"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
<código aqui>
```

`.code-only.txt` começa **direto no código** (sem cabeçalho, sem 5
`Attribute VB_<formattr>`). Tamanho ~170 chars de diferença sistemática
nos 4 forms do Credenciamento.

**Anti-padrão.** Comparar `.frm` raw com `.code-only.txt` raw, ou
cortar `.frm` em `Attribute VB_Name` (inclui os 5 form attrs no diff).

**Padrão.** Para alinhar para comparação textual: cortar `.frm` APÓS
`Attribute VB_Exposed` (última linha do bloco header):

```text
p = InStr(1, raw, "Attribute VB_Exposed", vbBinaryCompare)
eolPos = InStr(p, raw, vbLf)
codigo = Mid$(raw, eolPos + 1)
```

Fallback se form mínimo sem todos 5 attrs: tentar `Attribute VB_Name`.

**Generalização.** Qualquer ferramenta que compare `.frm` exportado vs
`.code-only.txt` espelhado precisa pular o bloco de header. Aplicável
a: smoke testes (V4 da TV2_RunUiSmokeReadOnly), CI/CD validations,
auditorias de drift M9.

### L23 — Controles dinâmicos via Me.Controls.Add não são detectáveis por smoke read-only

**Contexto.** Em `Credencia_Empresa.frm`, `CR_EnsureFiltroListaDinamico`
(chamado por `UserForm_Initialize`) cria o textbox de filtro
dinamicamente:

```text
Set mTxtFiltroCredLista = Me.Controls("TxtFiltro_CredenciamentoServico")
If mTxtFiltroCredLista Is Nothing Then Set mTxtFiltroCredLista = Me.Controls("CR_TxtFiltroListaDin")
If mTxtFiltroCredLista Is Nothing Then
    Set mTxtFiltroCredLista = Me.Controls.Add("Forms.TextBox.1", "TxtFiltro_CredenciamentoServico", True)
End If
```

Como NEM `TxtFiltro_CredenciamentoServico` NEM `CR_TxtFiltroListaDin`
existem no `.frx` estático, o textbox só passa a existir DEPOIS do
form ser instanciado e Initialize rodar. Smoke read-only (sem
instanciar form, apenas via `VBE.VBComponents(...).Designer.Controls`)
**NUNCA vê esses controles**.

**Anti-padrão.** Incluir nomes de controles dinâmicos em `canControles`
hardcoded da TV2_RunUiSmokeReadOnly. V1 falha com FALTANTES.

**Padrão.** Detectar dinâmicos via grep `Me.Controls.Add` no `.frm`
correspondente. Excluir esses nomes do canônico de smoke read-only.
Para verificar dinâmicos, criar suite separada (Onda 18+) que instancia
o form e roda Initialize, depois enumera controles.

**Generalização.** Smoke read-only só pode validar superfície ESTÁTICA
do `.frx`. Lógica de UI dinâmica (controles criados em Initialize,
mostradas/ocultadas, etc.) requer suite com instanciação real.
Documentar em comentário inline no canControles quais nomes são
estáticos vs por que não estão lá.

### L24 — Comparação textual VBA precisa skip linhas vazias para absorver trailing whitespace

**Contexto.** `.frm` e `.code-only.txt` salvos pelo VBE/script de
export podem ter número diferente de trailing newlines (típico:
`.frm` tem 5-6 `\n` no final, `.code-only.txt` tem 3). Diff
sistemático de 2-3 chars por arquivo entre versões "logicamente
idênticas".

**Anti-padrão.** Normalização gamma que preserva linhas em branco no
acumulador. Trailing `\n` viram empty lines preservadas, causando
diff residual mesmo quando código real é idêntico.

**Padrão.** Adicionar à normalização gamma:

```text
linha = RTrim$(linha)
If linha <> "" Then  ' skip linhas vazias apos RTrim
    ' ... aplicar lower-case fora de strings, etc
    acc = acc & linha & vbLf
End If
```

Linhas em branco no meio do código também não mudam significado VBA
— skip é seguro semanticamente.

**Generalização.** Qualquer comparação textual entre arquivos VBA
(diff, hash, content equality) deve normalizar trailing whitespace e
linhas vazias. Aplicável a:
- Comparação `.frm` vs `.code-only.txt` (V4 smoke)
- Comparação `src/vba/` vs `local-ai/vba_import/` (M11 audit)
- Validação pos-import V3
- Diff pré-commit em git

### M15 — V3 cm.AddFromString pode falhar Err=50132 sem causa raiz isolada

**Contexto.** Tentativa MD-17.1.c-pre (regenerar 4 `.code-only.txt` a
partir de `.frm` via re-import V3) falhou com `Err=50132` em
`cm.AddFromString` no primeiro form (`Reativa_Entidade`). Mesmo após
`IV3_LimparAtributosCodeOnly`. Causa raiz NÃO foi isolada com
confiança em tempo razoável.

**Anti-padrão (meta).** Insistir em regenerar `.code-only.txt` a
partir de `.frm` quando V3 falha de forma não-determinística. Cada
tentativa custa import + compile + Quarteto = ~15min, sem garantia
de sucesso.

**Padrão (meta).** Quando V3 cm.AddFromString falhar Err=50132:
1. Reverter para versão funcional do `.code-only.txt` (mesmo que
   tenha drift cosmético com `.frm`)
2. Adotar comparação tolerante (gamma) em vez de exigir match exato
3. Documentar tentativa revertida + razão (M15 candidata destilada
   nesta MD)
4. NÃO tentar regenerar novamente sem isolar causa raiz primeiro

**Generalização.** Algumas APIs de tooling têm modos de falha
inesperados. Se 1-2 tentativas não isolam causa raiz, escolher
**workaround tolerante** em vez de gastar mais ciclos perseguindo o
modo exato de falha. Documentar como débito de pesquisa para revisita
futura quando o ambiente mudar (versão Excel, Office update, etc.).

### M16 — Reproduzir algoritmo VBA exato em bash/python ANTES do import acelera isolamento de bugs sutis

**Contexto.** MD-17.1.c real teve 3 rounds de fix (fix1+fix2+fix3) por
bugs sutis em validação textual. Cada round = 1 import + compile +
Quarteto = ~15min do operador. Após o segundo fix falhar com diff
residual de apenas 2-3 chars, reproduzi o algoritmo VBA exato em
python via bash (preservando trailing empty splits, mesma ordem de
operações). **Em 5 minutos isolei a causa raiz** (trailing newlines)
sem custo do operador.

**Anti-padrão (meta).** Implementar algoritmo de validação textual em
VBA, importar, deixar operador rodar Quarteto, ver falha, fix
incremental, repetir. 3+ rounds quando bug é sutil e VBA não tem
debugger ergonômico para esse tipo de problema.

**Padrão (meta).** Para qualquer algoritmo de validação textual nova
(comparação de arquivos, normalização, parsing):
1. Implementar versão de referência em python/bash que é fiel ao
   algoritmo VBA (mesma sintaxe, mesma ordem, mesmo handling de
   edge cases)
2. Rodar contra dados reais do projeto em local
3. Validar GAMMA MATCH (ou comportamento esperado) em todos os casos
4. SÓ depois implementar em VBA + import + Quarteto
5. Se VBA falhar no Quarteto, comparar saída VBA vs python para
   isolar diferença de implementação rapidamente

**Generalização.** Aplicável a qualquer algoritmo lógico em ambiente
sem debugger ergonômico (VBA, batch scripts, AppleScript). O custo
do round-trip operador-IA é o motivo: cada round desperdiça operador.
Reproduzir externamente cobre 80% dos bugs antes do operador tocar.

### M17 — Derivar canônico de UI VBA requer leitura COMPLETA do .frm + grep dinâmicos

**Contexto.** MD-17.1.c original derivou canônico de controles via
grep simples em `.frm`: `Me.Controls("...")`, `WithEvents <var>`,
event handlers `<Name>_<Evento>`. Resultado: 3 dos 4 forms tiveram V1
falhar porque incluí nomes de variáveis VBA `WithEvents` (que NÃO
são controles) e omiti caminhos dinâmicos via `Me.Controls.Add`.

**Anti-padrão (meta).** Derivar canônico via grep parcial e prosseguir
sem validar contra runtime real ou contra leitura completa do `.frm`.
WithEvents `<var>` parece nome de controle mas é variável; controles
dinâmicos não aparecem em grep estrutural.

**Padrão (meta).** Derivação de canônico de UI estática:

1. Ler `.frm` COMPLETO (não apenas grep parcial)
2. Identificar `WithEvents <var> As MSForms.X` — esses são VARIÁVEIS,
   excluir de canControles
3. Identificar `Set <var> = Me.Controls("<actual_name>")` — `<actual_name>`
   é o controle (incluir)
4. Identificar `Me.Controls.Add(...)` — controle DINÂMICO, excluir de
   canControles de smoke read-only
5. Identificar event handlers `<ControlName>_<Evento>` — `<ControlName>`
   é o controle (incluir; mas confirmar contra (4) — pode ser dinâmico)
6. Para forms críticos, primeira execução do smoke V2 (set equality
   STRICT=False) revela extras/faltantes; baseline empírico via op
   colado em CSV de OBS

**Generalização.** Análise estática de código VBA tem 3 camadas:
- (a) declarações de variáveis (não são entidades de runtime)
- (b) referências a controles via `Me.Controls("...")` (estáticos
  conhecidos)
- (c) criação dinâmica via `Me.Controls.Add` (não-introspectáveis sem
  Initialize)

Ferramentas de smoke read-only só cobrem (b). Camadas (a)+(c) exigem
disciplina de leitura ou suite com instanciação real.

### Estado atual da fagocitose após Onda 17 MD-17.1.c real (fechada com fix3)

Lições estabelecidas: **L1-L24** (24 padrões positivos, 3 novos nesta
MD expondo nuances UI VBA + comparação textual).
Meta-lições: **M1-M17** (17 anti-padrões de processo, 3 novos nesta
MD expondo: erro de regeneração não-determinística, valor de
reprodução externa de algoritmo VBA, e disciplina de derivação
canônica de UI).

Bordas validadas adicionais (Onda 17 MD-17.1.c real, 3 rounds fix):

- **Estrutura .frm vs .code-only.txt** (L22) — 5 attributes de form
  no .frm que .code-only.txt não tem
- **Controles dinâmicos** (L23) — `Me.Controls.Add` em runtime
  invisível para smoke read-only
- **Trailing whitespace gamma** (L24) — skip linhas vazias é
  obrigatório para alinhamento textual VBA
- **Workaround tolerante para Err=50132** (M15) — quando V3 falha
  não-deterministicamente, gamma tolerante > regeneração
- **Reprodução bash/python** (M16) — algoritmo VBA replicado
  externamente isola bugs sutis em minutos vs múltiplos rounds
- **Disciplina canônico UI** (M17) — derivação requer leitura
  completa + 3 camadas (variáveis, estáticos, dinâmicos)

**Marker HBN V2 candidato.** `🟣 HBN GAMMA OFFLINE VALIDATED` — IA
declara que algoritmo de validação textual foi reproduzido em
bash/python e GAMMA MATCH antes do operador rodar. Análogo a
`🟢 HBN CHECKPOINT CLEAN` mas para confiança em validação nova.

---

## Apêndice — Lições Onda 17 MD-17.1.d (V12.0.0203 → fechadas em 2026-05-03 chat 2 Opus 4.7)

> Append-only. MD-17.1.d.I (perf gamma conservador), MD-17.1.d.II (visibility
> alfa — status bar rica), MD-17.1.d.III (hotfix V1_RAPIDA + msg CSV).
> Quarteto verde em todos. Idempotência empírica confirmada via Run 2
> consecutivo no MD-17.1.d.I (Q-MD17.1.d.I.A confirmou análise estática:
> zero formulas + zero Worksheet_Change handlers).

### L25 — Application.Calculation/ScreenUpdating/EnableEvents salvar-e-restaurar com handler garantido

**Contexto.** Speed-up de batch operations via `Application.Calculation =
xlCalculationManual + ScreenUpdating = False + EnableEvents = False`. Risco:
se erro fatal interrompe execução antes do restore, Excel fica travado em
modo manual (operador não consegue usar workbook).

**Anti-padrão.** Setar Application.* sem handler de restore garantido. Se
algum Sub falhar entre Init e Finalizar, restore não roda.

**Padrão.** Pares `TV2_PerfModeOn` / `TV2_PerfModeRestore` encapsulados em
helpers Private. `TV2_FinalizarExecucao` adiciona `On Error GoTo erro_fatal_handler`
no início; bloco `erro_fatal_handler:` SEMPRE chama `TV2_PerfModeRestore`.
`TV2_PerfModeRestore` usa `On Error Resume Next` para não mascarar erros
downstream se restore falhar parcialmente.

**Pre-flight obrigatório de idempotência antes de aplicar perf gamma:**

```text
1. grep -rn '\.Formula\|\.FormulaR1C1' src/vba/Repo_*.bas src/vba/Svc_*.bas
   -> deve retornar 0 (Calculation manual safe)
2. grep -rn 'Worksheet_Change\|Workbook_Change\|Worksheet_Calculate' src/vba/
   -> deve retornar 0 (apenas Auto_Open na abertura) (EnableEvents=False safe)
3. Validacao operacional: rodar Quarteto 2x consecutivos e comparar
   contagens OK/FALHA/MANUAL (idempotencia empirica)
4. ?Application.Calculation pos-execucao deve retornar -4135
   (xlCalculationAutomatic) — confirma restore
```

### L26 — StatusBar update SEMPRE em testes (não só em modo visual)

**Contexto.** Modo "rápido" (silencioso) em testes V2 e Bateria_Oficial
não atualizava `Application.StatusBar` durante execução. Operador rodava
Quarteto e via "V2 [SMOKE] iniciando" estático por 13 minutos —
sensação de "Quarteto travado".

**Anti-padrão.** `If gDelayVisualMs > 0 Then ...; Application.StatusBar = ...; ...`
envolvendo TODA a atualização visual. Em modo rápido, status bar fica obsoleta.

**Padrão.** Separar StatusBar update (custo trivial ~5ms) das operações
caras de modo visual (.Activate, .Select, coloração de células,
Application.Wait):

```text
' StatusBar update SEMPRE (custo trivial)
Application.StatusBar = "..."

' Modo visual: apenas operações caras
If gDelayVisualMs > 0 Then
    ws.Activate
    ws.Cells(...).Select
    ' colorir, scroll, etc.
End If
```

**Generalização.** Visibility ≠ visual. StatusBar é canal de comunicação
operador-engine sem custo perceptível em qualquer modo. Aplicado em
TV2_LogLinha (MD-17.1.d.II) e Teste_Bateria_Oficial.bas linha 1502
(MD-17.1.d.III).

### L27 — Confirmação de geração de arquivo antes de mostrar caminho em UX

**Contexto.** MsgBox final de `CT_ValidarRelease_*` mostrava
`"CSV resumo:" & csvResumo`. Operador procurou em local errado e teve
sensação de "passa imagem errada". CSV de fato existia (verificado:
949 bytes em path correto). UX ambígua.

**Anti-padrão.** Mostrar caminho de arquivo gerado sem verificar `Dir() <> ""`.
Operador tem dúvida se o arquivo foi mesmo gerado.

**Padrão.** Verificar `Dir(caminho) <> ""` antes de exibir e mostrar status
explícito:

```text
If Len(caminho) > 0 And Dir(caminho) <> "" Then
    msg = "CSV resumo (gerado):" & vbCrLf & caminho
ElseIf Len(caminho) > 0 Then
    msg = "CSV resumo NAO GERADO em:" & vbCrLf & caminho & vbCrLf & _
          "(verificar permissoes ou erro de I/O)"
Else
    msg = "CSV resumo: nao exportado (caminho vazio)"
End If
```

**Generalização.** Toda UX que mostra caminho de arquivo gerado deve
incluir status de geração para evitar ambiguidade.

### M18 — Hotfix de UX trivial não exige hearback formal completo

**Contexto.** MD-17.1.d.III foi 2 fixes pontuais (visibility V1_RAPIDA + msg
CSV) descobertos via feedback do operador pós-MD-17.1.d.II. IA criou nova
task #11 e executou direto sem readback formal — apenas hearback de
escrita-em-código antes do import.

**Anti-padrão (meta).** Bloquear hotfix trivial atrás de readback formal
completo (overhead protocolar para mudanças cirúrgicas em pontos isolados).

**Padrão (meta).** Hotfix qualifica como "trivial" se:
1. Causa raiz isolada via grep/leitura sem ambiguidade
2. Fix em 1-3 arquivos, total <50 linhas
3. Sem mudança de assinatura ou semântica
4. Sem efeito em business logic (só UX/visibility)
5. Pode reusar marcadores M14 + análise de idempotência da MD anterior

Para hotfix trivial: pular readback formal, ir direto para edits + hearback
de escrita-em-código + manifesto + procedimento. Operador autoriza no chat
("Incorpore isso na próxima mudança do roadmap").

### M19 — Numeração de subtarefas (.I, .II, .III) reduz fragmentação de tasklist

**Contexto.** MD-17.1.d original era "perf gamma" (1 task). Foi expandida
para .I (perf), .II (visibility), .III (hotfix UX). Manter numeração
hierárquica (X.Y.Z.N) em vez de criar IDs novos (MD-17.1.d, MD-17.1.e,
MD-17.1.f) preserva agrupamento lógico no roadmap.

**Padrão.** Quando MD original gera sub-MDs:
- Original: MD-N
- Sub-tarefas: MD-N.I, MD-N.II, MD-N.III
- Hotfix posterior: MD-N.IV ou MD-N.fix1 (preserva contexto)

### Estado atual da fagocitose após Onda 17 MD-17.1.d (chat 2 Opus 4.7 fechado)

Lições estabelecidas: **L1-L27** (27 padrões positivos, 3 novos em MD-17.1.d).
Meta-lições: **M1-M19** (19 anti-padrões de processo, 2 novos em MD-17.1.d).

Bordas validadas adicionais (Onda 17 MD-17.1.d.I/II/III):

- **Perf gamma com restore garantido** (L25) — handler `erro_fatal_handler`
  + helpers `TV2_PerfModeOn`/`Restore` evitam Excel travado
- **StatusBar SEMPRE em testes** (L26) — custo trivial, payoff alto em UX
- **Confirmação de geração antes de mostrar path** (L27) — UX clara para
  operador
- **Hotfix trivial sem readback formal** (M18) — protocolo enxuto
- **Numeração hierárquica de sub-MDs** (M19) — agrupamento lógico no roadmap

Onda 17 chat 2 fechou: MD-17.1.c real, MD-17.1.d.I, MD-17.1.d.II, MD-17.1.d.III.
Backlog Onda 17: MD-17.1.e, MD-17.2, MD-17.3, MD-17.4, MD-17.5.
Backlog crítico: Onda 18 (DT-17-REATIV-STRIKES, libera release público).
Débito técnico: MD-17.1.d.I.b (γ profundo, alvo Quarteto <10min).

---

## Apêndice — Lições Onda 17+18 fechamento rc3 (2026-05-04)

> Append-only. Onda 17 Bloco A fechou o Quinteto + IntegridadeBase;
> Onda 18 Bloco B resolveu DT-17-REATIV-STRIKES e fechou o débito de
> statusbar hint. Quinteto final: `VR_20260504_070441`, sintaxe
> `V1=171/0+V2_Smoke=27/0+V2_Canonica=23/0+E2E_Strikes=71/0+IntegridadeBase=3/0`.

### M20 — Manifesto V3 delta exige bloco `GRUPO_...` com linhas `M|`/`F|` no fim

**Contexto.** O V3 lê manifestos por grupos. Manifestos com conteúdo
explicativo mas sem bloco final `# GRUPO_...` seguido dos itens importáveis
podem ser interpretados como vazios/malformados.

**Anti-padrão.** Escrever manifesto narrativo e esquecer o bloco operacional
final.

**Padrão.** Todo delta importável termina com:

```text
# GRUPO_DELTA_<ID>_<TEMA>
M|001-modulo/<prefixo>-Modulo.bas
F|002-formularios/<prefixo>-Form.frm
```

**Evidência.** `MICRO24`, `MICRO25-fix2`, `MICRO26`, `MICRO27` e
`MICRO28` importaram corretamente usando o bloco final.

### M21 — Transição programada bate chat fadigado em MD grande

**Contexto.** MDs grandes exigem leitura extensa de código, decisão de
escopo e implementação. Tentar fechar tudo no mesmo contexto aumenta risco
de regressão por fadiga.

**Padrão.** Para MD com leitura dominante ou estimativa >2h:
1. chat N faz scoping e registra handoff;
2. chat N+1 implementa com contexto limpo;
3. readback/ERP preservam continuidade.

**Evidência.** Onda 17 separou scoping e implementação de Bloco A; Onda 18
recebeu bastão por doc 57 e fechou quatro microdeltas sem regressão.

### M22 — Caminho C híbrido é eficiente para bloco homogêneo de risco

**Contexto.** Havia três alternativas: microdeltas estritos, mega-onda ou
Caminho C híbrido. O Bloco A agrupava mudanças homogêneas de teste/auditoria.

**Padrão.** Quando o risco é homogêneo e o gate é forte, agrupar em pacote
Caminho C reduz overhead sem perder controle: scoping claro, manifesto único,
rollback documentado e Quinteto como gate.

**Evidência.** Bloco A `MICRO24` entregou IntegridadeBase + Quinteto +
Central V2 com Quinteto e Quarteto verdes. Bloco B repetiu a cadência com
microdeltas curtos por risco específico.

### M23 — IntegridadeBase é padrão reutilizável de auditoria passiva

**Contexto.** Bugs reais podem ser detectados sem alterar lógica de produção.
O sistema precisa registrar o achado sem bloquear o gate quando a ocorrência
é dívida conhecida.

**Padrão.** Suite de auditoria passiva:
1. varre abas operacionais em modo read-mostly;
2. escreve somente em `RESULTADO_QA_V2` e `RPT_*`;
3. usa `TV2_LogManual` para amarelo não bloqueante;
4. registra/upserta bug em relatório por `BUG_ID`.

**Evidência.** `TV2_RunIntegridadeBase` detectou `INT-CAD-OS-REF-ORFA`,
registrou `DT-17-REATIV-STRIKES`, e depois moveu DT-17 para
`RPT_BUGS_RESOLVIDOS` sem regressão.

### L28 — Regra dos 50% de contexto para agentes HBN

**Contexto.** Sessões longas degradam qualidade de leitura e aumentam risco
de "estado fantasma" no raciocínio do agente.

**Padrão.** Agente deve sinalizar `🟡 HBN CONTEXT FATIGUE INCOMING` antes da
degradação, idealmente em 40-45% do contexto, e iniciar handoff natural até
50%.

**Evidência.** Regra formalizada pelo operador em 2026-05-04 durante a
passagem de bastão Opus → Codex.

### L29 — Bastão simétrico precisa de declaração, relay e lock

**Contexto.** Em operação multi-IA, ausência de posse explícita do bastão
gera risco de duas IAs editarem a mesma frente.

**Padrão.** Transferência válida exige:
1. declaração pública de recebimento;
2. atualização de `.hbn/relay/INDEX.md`;
3. lock `.hbn/locks/bastao-frente<N>.lock`;
4. doc de transição referenciado.

**Evidência.** Frente 1 passou de Opus 4.7 para Codex CLI via doc 57, relay
e lock formal antes do Bloco B.

### M24 — Cadência D: Codex implementador, Opus/Antigravity auditores

**Contexto.** O operador escolheu Codex para implementação por maior
assertividade prática em código VBA, mantendo Opus e Antigravity como
auditores finais.

**Padrão.** Cadência D:
1. Codex assume bastão técnico e implementa microdeltas;
2. operador roda imports/compilações/gates no Excel;
3. Opus + Antigravity auditam o fechamento antes da promoção final.

**Evidência.** Bloco B Onda 18 fechou `MICRO25-fix2` a `MICRO28` com
Quinteto verde em cada checkpoint e sem regressão de sintaxe.

### Estado atual da fagocitose após Onda 17+18 rc3

Lições estabelecidas: **L1-L29**.
Meta-lições: **M1-M24**.

Próximo passo: auditoria cruzada final (Opus + Antigravity) antes de
promover `v12.0.0203-rc3` para `v12.0.0203` final.
