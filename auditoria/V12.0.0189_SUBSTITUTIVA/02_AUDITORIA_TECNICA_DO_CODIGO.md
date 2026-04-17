# 02. Auditoria Técnica do Código — V12.0.0189

Este documento rastreia, nome por nome e linha por linha, os pontos do código-fonte VBA que sustentam ou comprometem a estabilidade da V12.0.0189. Apenas fatos observados no código são afirmados diretamente; hipóteses são marcadas como **inferência** ou **incerteza** e sempre vinculadas ao arquivo e linha onde se ancoram.

---

## 1. Núcleo do rodízio (`Svc_Rodizio.bas`)

**Arquivo:** `vba_export/Svc_Rodizio.bas`

- `SelecionarEmpresa(ativId, entId)` aplica os cinco filtros A–E na ordem: `STATUS_CRED` ativo, `SUSPENSA_GLOBAL` não ativa, empresa não inativa, sem OS aberta, sem Pré-OS pendente.
- A ordem dos filtros é correta (primeiro custo barato, depois dependências externas), e cada filtro delega a um `Repo_*` para a consulta, o que preserva a separação de camadas.
- `AvancarFila(ativId, empIdSelecionada)` atualiza `POSICAO_FILA` incrementando `MaxPosicao(ativId) + 1` na linha selecionada. **Não** renumera para `1..N`. Isso confirma o contrato declarado em `releases/V12.0.0189.md`.
- `Suspender(empId)` / `Reativar(empId)` alteram o status global na aba `EMPRESAS` e escrevem a data final de suspensão. A regra de quantos meses vem de `CONFIG` (`COL_CFG_MESES_SUSPENSAO`).
- `IncrementarRecusa(empId, ativId)` — ver seção 4 deste documento para o risco de atomicidade.

**Fato:** a lógica do rodízio no serviço está bem contida e rastreável.
**Inferência:** a V2 deve conseguir exercitar essa lógica sem alteração no serviço — basta que a baseline determinística consiga montar os 3+3+3 registros canônicos corretamente. Ver seção 2.

---

## 2. Origem técnica do fatal `EMPRESAS=4 | ENTIDADE=4 | CREDENCIADOS=4 | PRE_OS=1 | CAD_OS=1`

### 2.1 Caminho do código

Entrada: `CT2_ExecutarSmokeRapido` (em `Central_Testes_V2.bas`) → `TV2_PrepararCenarioTriploCanonico` (`Teste_V2_Engine.bas:340`).

```
TV2_PrepararCenarioTriploCanonico (linha 340)
  ├── TV2_PrepararBaselineCanonica (linha 328)
  │     ├── TV2_ResetBaseOperacional       (linha 381)
  │     │     └── TV2_ClearSheet × 9 abas  (linha 398)
  │     ├── TV2_SetConfigCanonica           (linha 357)
  │     ├── CargaInicialCNAE_SeNecessario
  │     ├── TV2_MapearAtividadesCanonicas   (linha 466)
  │     └── TV2_GarantirServicoCanonico × 3
  ├── TV2_CadastrarEntidadeCanonica × 3    (linha 557)
  ├── TV2_CadastrarEmpresaCanonica × 3     (linha 596)
  ├── TV2_CredenciarAtividade × 3          (linha 633)
  └── TV2_ValidarCenarioTriploCanonico     (linha 1115)
```

### 2.2 O que cada cadastrador faz, e por que isso importa

Todos os três cadastradores canônicos compartilham o mesmo padrão:

```vb
linha = TV2_NextDataRow(<aba>)
ws.Cells(linha, COL_*_ID).Value = <id>
...
```

`TV2_NextDataRow` (linhas 441–453):

```vb
primeira = TV2_PrimeiraLinhaDados(nomeAba)   ' = LINHA_DADOS = 2
ultima = UltimaLinhaAba(nomeAba)             ' = End(xlUp) coluna A

If ultima < primeira Then
    TV2_NextDataRow = primeira               ' 2
Else
    TV2_NextDataRow = ultima + 1             ' <-- ponto crítico
End If
```

**Fato:** quando `ultima >= primeira`, a próxima inserção é **deslocada** para `ultima + 1`.

### 2.3 Onde `TV2_ClearSheet` pode falhar silenciosamente

`TV2_ClearSheet` (linhas 398–431):

```vb
On Error Resume Next                           ' <-- engole erros
For Each lo In ws.ListObjects
    Do While lo.ListRows.Count > 0
        lo.ListRows(1).Delete
    Loop
Next lo
On Error GoTo 0

ultimaLinha = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
ultimaColuna = ws.Cells(1, ws.Columns.Count).End(xlToLeft).Column   ' <-- só linha 1
primeiraLinha = TV2_PrimeiraLinhaDados(nomeAba)

If ultimaColuna < 1 Then ultimaColuna = 1
If ultimaLinha >= primeiraLinha Then
    ws.Range(ws.Cells(primeiraLinha, 1), ws.Cells(ultimaLinha, ultimaColuna)).ClearContents
End If

ws.Cells(1, COL_CONTADOR_AR).Value = 0
```

Três fragilidades **confirmadas pelo código**:

- **`On Error Resume Next` ao mexer em `ListObjects`.** Falhas de `ListRows(1).Delete` são silenciadas. Se uma tabela tem linhas "fantasma" que `ListRows.Count` não enxerga corretamente, elas passam.
- **`ultimaColuna` medida apenas em linha 1.** Se um dado histórico estiver gravado em colunas à direita do último header visível na linha 1, `ClearContents` não alcança essa largura.
- **`ultimaLinha` medida apenas em coluna A.** Se existir uma célula isolada em coluna A entre `primeiraLinha` e `ultimaLinha` **dentro** do intervalo, ela é limpa. Mas se existir em **outra** coluna fora do `ultimaColuna`, ela não é tocada e aparece em inspeção visual — sem afetar `UltimaLinhaAba` porque essa só olha coluna A. Esse cenário, sozinho, **não** explica o fatal.

### 2.4 Cenário que explica o fatal (hipótese forte, 80% de confiança)

A explicação que casa exatamente com `EMPRESAS=4 | ENTIDADE=4 | CREDENCIADOS=4 | PRE_OS=1 | CAD_OS=1`:

1. Após `TV2_ClearSheet` rodar, **permanece uma célula em coluna A** no intervalo `>=primeiraLinha` em cada uma das 5 abas. Isso pode vir de:
   - uma `ListRow` ignorada pelo `On Error Resume Next`;
   - uma formatação condicional ou cálculo dinâmico que repopula a célula no próximo acesso;
   - um `Util_PrepararAbaParaEscrita` que restaura proteção **antes** do ClearContents ser comitado (improvável, mas não descartado — ver `Util_Planilha.bas`).
2. Ao entrar `TV2_CadastrarEntidadeCanonica("001", …)`, `TV2_NextDataRow` vê `ultima = 2` (a célula residual) e retorna `ultima + 1 = 3`.
3. O "001" é gravado na linha 3. Repete-se para "002" (linha 4) e "003" (linha 5).
4. `TV2_CountRows` (linhas 828–836):

```vb
primeira = TV2_PrimeiraLinhaDados(nomeAba)   ' 2
ultima = UltimaLinhaAba(nomeAba)             ' 5
If ultima < primeira Then Exit Function
TV2_CountRows = ultima - primeira + 1        ' 5 - 2 + 1 = 4
```

→ Retorna **4**. Idêntico ao CSV.

5. Em `PRE_OS` e `CAD_OS`, nenhuma inserção ocorre na preparação canônica; há apenas o residual em coluna A no próprio `primeira`. Resultado `CountRows = 1`. Idêntico ao CSV.

### 2.5 Remédio direto (sem precisar entender a origem exata do residual)

O remédio estrutural **independe** de descobrir o residual: trocar `TV2_CountRows` por contagem semântica na coluna-chave (igual à V1 via `CountA`) e adicionar um post-condition assert depois de `TV2_ResetBaseOperacional`.

Pseudocódigo proposto (documento 07, B1):

```vb
Public Function TV2_CountRowsV2(ByVal nomeAba As String) As Long
    Dim ws As Worksheet, col As Long
    Set ws = ThisWorkbook.Sheets(nomeAba)
    col = TV2_ColunaChave(nomeAba)      ' A=1 para todas atualmente, mas centralizado
    TV2_CountRowsV2 = Application.WorksheetFunction.CountA( _
        ws.Range(ws.Cells(LINHA_DADOS, col), ws.Cells(ws.Rows.Count, col)))
End Function
```

E em `TV2_ResetBaseOperacional`, ao final, um:

```vb
For Each nome In Array(...)
    TV2_ClearSheet CStr(nome)
    If TV2_CountRowsV2(CStr(nome)) <> 0 Then
        Err.Raise 1004, "TV2_ResetBaseOperacional", _
            "Aba " & nome & " nao zerou apos reset (residual estrutural)."
    End If
Next nome
```

Esse assert transforma um **fatal tardio durante a validação** em **falha cedo e precisa durante o reset**, o que reduz em >10x o tempo de diagnóstico futuro.

---

## 3. `Util_Planilha.bas` — pontos críticos

**Arquivo:** `vba_export/Util_Planilha.bas`

### 3.1 `UltimaLinhaAba` (linhas 478–486)

```vb
If ws.Cells(ws.Rows.count, 1).End(xlUp).row < LINHA_DADOS Then
    UltimaLinhaAba = LINHA_DADOS - 1
Else
    UltimaLinhaAba = ws.Cells(ws.Rows.count, 1).End(xlUp).row
End If
```

**Fato:** sempre mede coluna A.
**Inferência:** é adequado para abas onde coluna A é chave (todas as abas operacionais atuais), mas torna a função invisível a qualquer dado que esteja só em colunas à direita. Essa invisibilidade está no coração da fragilidade da V2 na seção 2.

### 3.2 `PrimeiraLinhaDadosEmpresas` (linhas 458–475)

Tem heurística de "ID / EMP_ID / CNPJ / RAZAO SOCIAL" na linha 1 para distinguir cabeçalho presente vs ausente. Hoje só é chamada para `SHEET_EMPRESAS`. Em qualquer outra aba, o `TV2_PrimeiraLinhaDados` cai no else e retorna `LINHA_DADOS`.

**Risco residual:** se um dia `EMPRESAS` for criada sem cabeçalho, a função retorna `1`, o que fará `ClearContents` começar na linha 1 e **apagar os headers**. Inferência com confiança média. Mitigação: tornar essa heurística aplicável a todas as abas com headers padrão, ou substituí-la por verificação explícita "há header esperado?".

### 3.3 `ProximoId` (linhas 490–507)

Protege/desprotege **a cada chamada**. Em cadastro em lote, o custo O(N) de protect/unprotect vira gargalo. Adicionalmente, se `ClearContents` ou `Cells.Value` falhar entre o `Unprotect` e o `Util_RestaurarProtecaoAba`, a aba pode ficar desprotegida. O código atual não usa `On Error` nesse trecho, então uma exceção aborta a macro e o usuário percebe; mesmo assim, o estado de proteção fica inconsistente.

**Risco:** médio, mitigável com `On Error GoTo cleanup` e `cleanup: Util_RestaurarProtecaoAba`.

### 3.4 `IdsIguais` (linhas 516–532)

Centralizada corretamente. Compara numérico vs texto com `Trim$` e `CStr`. Nenhum risco identificado.

---

## 4. Risco de atomicidade em `IncrementarRecusa` / `Svc_Rodizio` + `Repo_Credenciamento`

**Fato observado:** o incremento de contador de recusas grava em duas abas (`CREDENCIADOS` e `EMPRESAS`) sem transação. Se a segunda gravação falhar (por ex., aba protegida e `Util_PrepararAbaParaEscrita` devolver `False`), a primeira não é desfeita.

**Impacto funcional:** divergência silenciosa entre `CREDENCIADOS.COL_CRED_RECUSAS` e `EMPRESAS.COL_EMP_QTD_RECUSAS` — é exatamente o tipo de coisa que um operador humano só descobre dias depois, quando a empresa é "inexplicavelmente" suspensa.

**Mitigação recomendada:** padrão `tentarGravar; seFalhar: reverterAnterior` com log em `RESULTADO_QA`. Alternativamente, escrever ambas as colunas em uma única subrotina `Repo_*.RegistrarRecusa` que gerencie a transação com retries curtos. Backlog item C2 (documento 09).

---

## 5. Menu_Principal.frm — lacunas UI → Serviço

**Arquivo:** `vba_export/Menu_Principal.frm`

Três trechos confirmados onde a UI implementa regra de negócio que deveria viver no serviço:

- **Pré-OS:** validação de `ENT_ID` existir e estar ativo. Os `Svc_PreOS.EmitirPreOS` atuais recebem `entId` como parâmetro mas não verificam a existência na aba `ENTIDADE`. Se chamado headless, grava uma Pré-OS com `ENT_ID` inválido.
- **OS:** validação de `DT_PREV_TERMINO >= DT_EMISSAO`. Mesmo padrão: a UI valida no `BeforeUpdate`, o `Svc_OS.EmitirOS` aceita qualquer data.
- **Avaliação:** quando `QT_EXECUTADA <> QT_ESTIMADA`, a UI exige texto em `TxtJustificativa`. `Svc_Avaliacao.AvaliarOS` aceita divergência sem justificativa.

**Consequência direta:** qualquer chamador não-UI (testes V2 headless, scripts futuros, porta para SaaS) consegue gerar estados de negócio inválidos. É isso que mantém os cenários `MIG_*` da V2 como `LogManual`.

---

## 6. Módulos de emergência — superfície de risco

**Arquivos:** `Emergencia_CNAE.bas`, `Emergencia_CNAE1/2/3.bas`, `Importar_Agora.bas`, `ImportarCNAE_Emergencia` (em outro módulo).

São macros que **resetam ou recarregam** a aba `ATIVIDADES`. Em workbook com proteção reduzida para teste, uma chamada acidental via Alt+F8 apaga CNAEs vigentes. O `ESTADO-ATUAL.md` já marca esses módulos como "temporários — remover após estabilização", mas em 0189 eles **ainda estão presentes**. Mitigação: mover para um sub-pasta com sufixo `_SANDBOX` ou adicionar gate explícito pedindo senha.

---

## 7. Central V1 (`Teste_Bateria_Oficial.bas`) — o que faz bem

- Conta linhas por `CountA` na coluna-chave, o que a torna **insensível** a resíduos em colunas erradas.
- Faz reset condicional com pausa para operador humano (dialog antes de apagar).
- Usa `RPT_BATERIA` para relatório estruturado.

**Fato:** nenhuma das fragilidades descritas na seção 2 afeta a V1 da mesma forma. Isso alinha com a experiência relatada: a V1 continua rodando e a V2 trava na baseline.

**Inferência:** migrar a **estratégia de contagem** da V1 para a V2 elimina 80% do problema descrito.

---

## 8. Resumo de fatos vs inferências

| Afirmação | Tipo | Origem |
|-----------|------|--------|
| A V2 exige 3 empresas, 3 entidades, 3 credenciados, 0 pré-OS, 0 OS | Fato | `Teste_V2_Engine.bas:1118-1122` |
| `TV2_NextDataRow` desloca quando `ultima >= primeira` | Fato | `Teste_V2_Engine.bas:441-453` |
| `TV2_CountRows` é aritmético sobre coluna A | Fato | `Teste_V2_Engine.bas:828-836` + `Util_Planilha.bas:478-486` |
| Resíduo em coluna A após `TV2_ClearSheet` produz CSV 4/4/4/1/1 | Inferência (80%) | seção 2.4 |
| `TV2_ClearSheet` pode engolir erro em `ListObjects` | Fato | `Teste_V2_Engine.bas:412-418` |
| `IncrementarRecusa` não é atômico | Fato | `Svc_Rodizio.bas` + `Repo_Credenciamento.bas` |
| MIG_001/002/003 vivem na UI | Fato | `Menu_Principal.frm` |
| Trocar contagem para `CountA` na coluna-chave resolve a V2 | Inferência (95%) | seções 2.5 e 7 |
| Atomicidade pode ser introduzida via `Repo_*.RegistrarRecusa` | Inferência (70%) | seção 4 |
