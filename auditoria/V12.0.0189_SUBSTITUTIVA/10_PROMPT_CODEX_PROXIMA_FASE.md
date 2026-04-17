# 10. Prompt Objetivo para Codex Executar a Próxima Fase

> Este documento **é um prompt** — copie, cole e envie ao próximo agente (Codex, GPT-5, Sonnet, Opus, Cursor, etc.) que assumir o bastão de implementação após esta auditoria. Ele está em português, é autossuficiente, e aponta para os artefatos auditados.

---

## Instruções para o próximo agente

Você recebe o bastão do projeto **Sistema de Credenciamento (Excel/VBA)** na versão `V12.0.0189`, branch `codex/v180-stable-reset`. A versão atual está marcada como `EM_VALIDACAO` em `obsidian-vault/ai/GOVERNANCA.md`.

Uma auditoria externa acabou de consolidar o estado real e o plano de estabilização, localizada em `auditoria/V12.0.0189_SUBSTITUTIVA/`. **Leia esses 10 documentos antes de abrir qualquer arquivo de código.** Eles são a melhor fotografia do estado atual do sistema e eliminam a necessidade de reexplorar o codebase do zero.

### Ordem de leitura obrigatória

1. `auditoria/V12.0.0189_SUBSTITUTIVA/01_RELATORIO_EXECUTIVO.md` — contexto.
2. `auditoria/V12.0.0189_SUBSTITUTIVA/02_AUDITORIA_TECNICA_DO_CODIGO.md` — o que está quebrado.
3. `auditoria/V12.0.0189_SUBSTITUTIVA/07_PLANO_BATERIAS_COMPLEMENTARES.md` — as mudanças concretas de código.
4. `auditoria/V12.0.0189_SUBSTITUTIVA/09_BACKLOG_PRIORIZADO.md` — a ordem de execução.
5. Os demais documentos (03, 04, 05, 06, 08) conforme necessidade.

### Ordem de execução obrigatória

Você deve executar os itens na ordem do backlog, em sprints, nunca pular.

**Sprint 1 — destravar a V2:**

1. Aplicar **B1** em `vba_export/Teste_V2_Engine.bas`:
   - Substituir `TV2_CountRows` para usar `Application.WorksheetFunction.CountA` na coluna-chave real da aba (mapa em `TV2_ColunaChave`).
   - Substituir `TV2_NextDataRow` para consultar `End(xlUp)` na **coluna-chave**, não mais na coluna A.
   - Endurecer `TV2_ClearSheet` usando `ws.UsedRange` como referência de amplitude, e não apenas a linha 1 / coluna A.
2. Aplicar **B2** em `TV2_ResetBaseOperacional`: adicionar `Err.Raise` quando `TV2_CountRows <> 0` em qualquer uma das 5 abas operacionais após reset.
3. Incrementar versão para **V12.0.0190** em `vba_export/App_Release.bas`.
4. Adicionar linha no topo de `obsidian-vault/ai/GOVERNANCA.md` com: versão, data (formato YYYY-MM-DD), IA autor, revisor `Mauricio`, status `EM_VALIDACAO`, compila `Pendente`, nota resumindo "Fix baseline V2 — contagem via coluna-chave + assert pós-reset".
5. Atualizar `obsidian-vault/ai/ESTADO-ATUAL.md` marcando a baseline V2 como estável em automático/assistido.
6. Criar `obsidian-vault/releases/V12.0.0190.md` seguindo o padrão das release notes anteriores (ver `V12.0.0189.md`).

### Regras invioláveis

- **Não altere o contrato da fila.** Ordem relativa correta, IDs únicos, `POSICAO_FILA` monotonicamente crescente. Veja `auditoria/V12.0.0189_SUBSTITUTIVA/02...md` seção 1 e `releases/V12.0.0189.md`.
- **Não altere a lógica do `Svc_Rodizio.SelecionarEmpresa`** (filtros A–E). Foi validada e está correta.
- **Não altere a UI** em Sprint 1. A UI só é tocada em Sprint 2 (MIG_*).
- **Não remova módulos de emergência** sem confirmação humana explícita. Eles entram no Sprint 5.
- **Cite arquivos e linhas** em cada alteração explicativa. Exemplo: `Teste_V2_Engine.bas:828`.
- **Separe fato de inferência** nos seus comentários e release notes. Use linguagem do tipo "confirmado no código" vs "hipótese de 80%".
- **Prefira falhar cedo e alto.** Um `Err.Raise` cedo salva horas de debug depois. Não use `On Error Resume Next` sem tomada de decisão explícita.
- **Não quebre a V1.** Ela é o único caminho estável de teste até a V2 destravar.

### Critérios de aceitação do seu turno

Quando o seu turno terminar, os seguintes requisitos devem estar satisfeitos, verificáveis por Maurício:

- [ ] `vba_export/Teste_V2_Engine.bas` tem `TV2_CountRows`, `TV2_NextDataRow` e `TV2_ClearSheet` modificados conforme B1.
- [ ] `TV2_ResetBaseOperacional` contém assert pós-reset conforme B2.
- [ ] `vba_export/App_Release.bas` aponta para V12.0.0190.
- [ ] `obsidian-vault/ai/GOVERNANCA.md` tem linha nova no topo.
- [ ] `obsidian-vault/releases/V12.0.0190.md` criado com: diagnóstico, mudanças, impacto, arquivos tocados.
- [ ] `obsidian-vault/ai/ESTADO-ATUAL.md` atualizado.
- [ ] Mensagem de handoff ao revisor resumindo: o que mudou, o que precisa ser testado (`CT2_ExecutarSmokeRapido` e `CT2_ExecutarSmokeAssistido`), e qual o próximo sprint.

### Exemplo de mudança de código (esqueleto)

```vb
' vba_export/Teste_V2_Engine.bas — substitui TV2_CountRows em ~linha 828

Public Function TV2_CountRows(ByVal nomeAba As String) As Long
    Dim ws As Worksheet
    Dim col As Long
    Dim rng As Range

    Set ws = ThisWorkbook.Sheets(nomeAba)
    col = TV2_ColunaChave(nomeAba)
    Set rng = ws.Range(ws.Cells(LINHA_DADOS, col), ws.Cells(ws.Rows.Count, col))
    TV2_CountRows = Application.WorksheetFunction.CountA(rng)
End Function

Private Function TV2_ColunaChave(ByVal nomeAba As String) As Long
    Select Case UCase$(nomeAba)
        Case UCase$(SHEET_EMPRESAS):     TV2_ColunaChave = COL_EMP_ID
        Case UCase$(SHEET_ENTIDADE):     TV2_ColunaChave = COL_ENT_ID
        Case UCase$(SHEET_CREDENCIADOS): TV2_ColunaChave = COL_CRED_ID
        Case UCase$(SHEET_PREOS):        TV2_ColunaChave = COL_PREOS_ID
        Case UCase$(SHEET_CAD_OS):       TV2_ColunaChave = COL_OS_ID
        Case Else
            TV2_ColunaChave = 1
    End Select
End Function
```

E em `TV2_ResetBaseOperacional`:

```vb
Private Sub TV2_ResetBaseOperacional()
    Dim nome As Variant

    For Each nome In Array( _
        SHEET_EMPRESAS, SHEET_EMPRESAS_INATIVAS, _
        SHEET_ENTIDADE, SHEET_ENTIDADE_INATIVOS, _
        SHEET_CREDENCIADOS, SHEET_PREOS, SHEET_CAD_OS, _
        SHEET_AUDIT, SHEET_RELATORIO)
        TV2_ClearSheet CStr(nome)
    Next nome

    ' Assert pós-reset B2
    Dim operacionais As Variant
    operacionais = Array(SHEET_EMPRESAS, SHEET_ENTIDADE, SHEET_CREDENCIADOS, SHEET_PREOS, SHEET_CAD_OS)
    For Each nome In operacionais
        If TV2_CountRows(CStr(nome)) <> 0 Then
            Err.Raise 1004, "TV2_ResetBaseOperacional", _
                "Aba " & nome & " nao zerou apos reset. Verificar ListObjects, " & _
                "proteção, ou dados fora do UsedRange."
        End If
    Next nome
End Sub
```

### Se você estiver bloqueado

- **Se o `CountA` retornar > 0 depois do reset**, o resíduo é real. Pise no freio, não force. Abra o workbook, selecione a aba problemática, inspecione manualmente `ws.UsedRange` e liste o que resta. Reporte ao revisor antes de tentar "limpar mais".
- **Se a aba tiver ListObject ativa**, entenda como ela é populada antes de mexer. Uma tabela Excel pode ter linhas fantasma que `Cells().ClearContents` não afeta, mas `ListRow.Delete` sim.
- **Se o Excel se recusar a limpar**, é quase certo que a proteção não foi removida. Confirme com `ws.ProtectContents = False` via Immediate Window antes de culpar o VBA.

### Depois do Sprint 1

Siga para o Sprint 2 descrito em `auditoria/V12.0.0189_SUBSTITUTIVA/09_BACKLOG_PRIORIZADO.md`. Cada sprint tem critérios claros de aceitação e uma versão alvo (V12.0.0191, V12.0.0192, ...).

A estabilização completa é atingida quando o checklist final em `09_BACKLOG_PRIORIZADO.md` seção "Critério de saída do backlog" esteja 100% marcado. Nesse ponto o sistema vira candidato à promoção como **V13.0.0000**.

Boa execução. Não pule etapas, não invente contratos, e sempre registre seu rastro em `GOVERNANCA.md`.
