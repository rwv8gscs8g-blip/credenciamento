# 04. Auditoria de Segurança e Integridade — V12.0.0189

Escopo: superfícies de risco não-funcionais — proteção de planilha, atomicidade de gravações, superfície exposta por macros, fronteira entre VBA e arquivos externos (CSVs de teste, backups), rastreabilidade.

---

## 1. Proteção de planilha

**Senha:** a senha padrão da planilha estava visível em comentários e chamadas diretas de `Unprotect` em vários pontos (ex.: `Util_Planilha.bas`, `Repo_*`, `Emergencia_CNAE*`).

**Avaliação honesta:** proteção de planilha Excel é uma **barreira ergonômica**, não um controle de segurança. Contra ator motivado ela não resiste. Contra usuário final operador ela reduz o risco de edição acidental. Manter a senha hardcoded é tolerável enquanto o sistema é desktop-only, **mas** é uma dívida a liquidar antes de qualquer publicação pública do workbook.

**Recomendação:**

1. Centralizar a senha em um helper único (ou módulo dedicado de segurança) para facilitar troca e evitar exposição literal.
2. Documentar explicitamente em `REGRAS.md` que essa senha **não é um segredo criptográfico**, apenas um gate de UX.
3. Se o workbook for compartilhado fora da equipe, trocar a senha a cada entrega.

---

## 2. Atomicidade de gravações em múltiplas abas

**Risco identificado (já citado em 02, seção 4):** `IncrementarRecusa` toca `CREDENCIADOS` e `EMPRESAS`. Uma falha entre as duas gravações deixa estados divergentes, e não há log de reconciliação.

Outras operações com o mesmo padrão:

| Operação | Abas tocadas | Risco de divergência |
|----------|--------------|----------------------|
| `EmitirPreOS` | `PRE_OS`, `CREDENCIADOS` (POSICAO_FILA) | Médio |
| `EmitirOS` | `CAD_OS`, `PRE_OS` (status) | Médio |
| `CancelarOS` | `CAD_OS`, `CREDENCIADOS` (ult. OS) | Baixo |
| `AvaliarOS` | `CAD_OS` (status), `CREDENCIADOS` (recusas se aplicável), `EMPRESAS` (recusas) | **Alto** |
| `Suspender` | `EMPRESAS` (status), `CREDENCIADOS` (status_cred em cascata?) | Médio |
| `Reativa_Empresa` | `EMPRESAS`, `EMPRESAS_INATIVAS` | Médio |

**Mitigação de baixo custo imediata:** em cada operação multi-aba, gravar em um log `AUDIT` (já existe `SHEET_AUDIT` em `Const_Colunas.bas`) **antes** de iniciar e **depois** de terminar, com um `id_operacao`. Se o "antes" existir sem "depois", a próxima execução reconcilia.

**Mitigação estrutural (médio prazo):** padrão `UnitOfWork` — criar módulo `Svc_Transacao.bas` que abra um escopo, acumule writes em memória e só commit ao final. Se falhar, reverte. Backlog C2.

---

## 3. Superfície exposta por macros destrutivas

Macros com efeito colateral destrutivo disponíveis via Alt+F8:

- `ImportarCNAE_Emergencia` (reseta `ATIVIDADES` e recarrega)
- `Emergencia_CNAE`, `Emergencia_CNAE1`, `Emergencia_CNAE2`, `Emergencia_CNAE3`
- `Importar_Agora`
- `ResetarECarregarCNAE`
- Macros `CT2_*` que chamam `TV2_ResetBaseOperacional` (apagam operacional)
- `CT_IniciarBateria` (legada) — também apaga dados operacionais

**Risco real:** um operador sem contexto pode executar `Importar_Agora` pensando que é benigno. O `ESTADO-ATUAL.md` já lista esses módulos como "temporários — remover após estabilização", mas em 0189 eles continuam ativos.

**Mitigações:**

1. Marcar todos os `Public Sub` destrutivos como `Private` e expor apenas via um hub (ex.: um form de administração com confirmação explícita).
2. Adicionar prefixo `_ADMIN_` ou `_DESTRUTIVO_` nos nomes para sinalização visual no Alt+F8.
3. Exigir confirmação dupla (`MsgBox vbYesNo` + digitação de palavra-chave) antes de reset operacional.

Backlog H1.

---

## 4. Rastreabilidade e governança

**Bom:**

- `obsidian-vault/ai/GOVERNANCA.md` mantém tabela de releases com autor, data, status.
- `App_Release.bas` centraliza versão, timestamp e autor.
- Hashes de integridade possíveis via `sha256sum *.bas *.frm > obsidian-vault/ai/HASHES.md`.
- Rollback preservado em `backups/rollback-post-v180-2026-04-17/`.

**Lacunas:**

- Não há gatilho automático para regenerar `HASHES.md` a cada release. Ele precisa ser executado manualmente, o que torna o hash auditoria *post-hoc* e não bloqueio.
- Nenhuma evidência de assinatura digital do `.xlsm`.
- CSVs de resultado (`TesteV2_*_Falhas_*.csv`) não têm hash nem timestamp do workbook que os gerou. Se o workbook for alterado e a bateria rodada de novo sem commit, a origem do CSV fica ambígua.

**Recomendações:**

1. Gerar `HASHES.md` automaticamente no hook pós-commit.
2. Incluir no cabeçalho de cada CSV de teste o hash MD5 do `.xlsm` + versão `App_Release` + hora UTC.
3. Padronizar nome do CSV para incluir versão: `TesteV2_V12.0.0189_Smoke_Falhas_<timestamp>.csv`.

Backlog D1, D2.

---

## 5. Tratamento de erros — `On Error Resume Next` perigosos

Busca no repositório por `On Error Resume Next` em pontos críticos:

- `TV2_ClearSheet` (`Teste_V2_Engine.bas:412-418`) — dentro do loop de `ListObjects`. Justificativa aceitável: tolerar abas sem ListObjects. Risco real: também tolera erros reais (aba protegida, linha bloqueada).
- `ProximoId` (`Util_Planilha.bas:490-507`) — não usa `On Error`. Se algo falhar após `Unprotect`, a aba fica desprotegida. Mitigação: `On Error GoTo cleanup`.
- `Repo_*` — varreduras com `On Error Resume Next` precisam ser auditadas uma a uma. Fora do escopo deste relatório; deixado como item I5 no backlog.

**Regra sugerida para todo o codebase:**

```vb
On Error Resume Next
<operacao_tolerada>
errNum = Err.Number
Err.Clear
On Error GoTo 0
If errNum <> 0 Then
    ' decidir explicitamente: logar, reraisar, ignorar com aviso
End If
```

Isso obriga a tomada de decisão explícita em cada bloco.

---

## 6. Integridade dos dados de teste (bateria)

**V1 (Teste_Bateria_Oficial):** escreve resultados em `RESULTADO_QA` e relatório `RPT_BATERIA`. Tem dialog de confirmação antes de reset.

**V2 (Teste_V2_*):** escreve em `RESULTADO_QA_V2`, `CATALOGO_CENARIOS_V2`, `ROTEIRO_ASSISTIDO_V2`. **Não** tem dialog de confirmação — o reset é parte da execução automática. Após a V12.0.0187, a V2 exporta CSV apenas quando há falhas, o que é bom para higiene.

**Lacuna:** V2 não grava o estado "antes do reset" em uma aba de snapshot. Se um operador tinha dados não salvos em `EMPRESAS`, eles são perdidos irremediavelmente.

**Mitigação:**

1. Antes do reset da V2, copiar as 5 abas operacionais para `SNAPSHOT_V2_ANTES_<timestamp>`.
2. Limpar snapshots com mais de 7 dias automaticamente.
3. Ou, alternativa mais leve: exigir confirmação humana explícita no `CT2_ExecutarSmokeRapido` quando detectar dados operacionais não-zerados.

Backlog B2 (ver documento 07).

---

## 7. Fronteira VBA ↔ filesystem

Pontos onde o VBA escreve ou lê arquivos fora do workbook:

- CSV de falhas da V2 → salva em `/Users/macbookpro/Projetos/Credenciamento/`.
- `Importar_Agora` / `ImportarCNAE_Emergencia` → leem arquivo de CNAEs (caminho hardcoded?).
- `Auto_Open` → nenhuma escrita em disco.

**Risco:** caminhos hardcoded criam dependência de ambiente. Se o workbook for aberto em outra máquina, a importação quebra.

**Mitigação:** centralizar caminhos em `Const_Colunas.bas` ou em uma aba de configuração. Backlog H2.

---

## 8. Checklist de integridade para promover a V12.0.0189

- [ ] `HASHES.md` regenerado.
- [ ] `App_Release.bas` com versão 0189 e data correta.
- [ ] Nenhum `On Error Resume Next` sem tratamento explícito nos `Svc_*`.
- [ ] Módulos `Emergencia_*` isolados ou removidos.
- [ ] Snapshot pré-reset implementado em V2 ou confirmação explícita.
- [ ] Senha padrão centralizada e sem exposição literal no repositório.
- [ ] CSV de teste inclui hash + versão no cabeçalho.
- [ ] Backup do workbook commitado em `backups/`.

Apenas quando **todos** os itens estiverem marcados a V12.0.0189 deve ser promovida a `VALIDADO`.
