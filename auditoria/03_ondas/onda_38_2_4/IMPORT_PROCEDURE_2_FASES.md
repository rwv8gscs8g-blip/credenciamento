---
titulo: Procedimento de Import — Onda 38.2.4
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-05-30
---

# Procedimento de Import — Onda 38.2.4

## Preflight

No VBE, confirme:

```vb
?ThisWorkbook.Path
ImportarPacoteV3_Status
```

Esperado: workbook em `\\Mac\Home\Projetos\Credenciamento`.

## Fase 1 — Modulos

Janela Imediata:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_INTEGRIDADE_ESTADO_F1_MODULOS", "<sha_onda_38_2_4>+ONDA38.2.4-ESTADO-F1-MODULOS"
```

Esperado:

- Importador V3: `M=4 | F=0 | err=0 | skip=0`;
- VBE > Depurar > Compilar VBAProject passa limpo.

Observacao: `TV2_RunIntegridadeEstado` deve ser executado apos a Fase 2, porque valida tambem o componente `Altera_Entidade` importado no VBE.

## Fase 2 — Form

Janela Imediata:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_INTEGRIDADE_ESTADO_F2_FORMS", "<sha_onda_38_2_4>+ONDA38.2.4-ESTADO-F2-FORMS"
```

Esperado:

- Importador V3: `M=1 | F=1 | err=0 | skip=0`;
- VBE > Depurar > Compilar VBAProject passa limpo;
- Janela Imediata:

```vb
TV2_RunIntegridadeEstado
```

Esperado: `OK=3 | FALHA=0`.

## RVS Pos-Fase 2

Executar o Gate de Validacao de Release completo pela interface.

Esperado:

- RVS `APROVADO`;
- CSV resumo preservado em `auditoria/evidencias/V12.0.0205/csv/` ou no caminho real informado pelo workbook.

## Fix1 — Inativacao do Primeiro Item de Entidade

Aberto apos revalidacao manual detectar erro na inativacao do primeiro item ativo da lista de entidades.

Janela Imediata:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_ESTADO_FIX1_ENTIDADE", "fd45a5d+ONDA38.2.4-ESTADO-FIX1-ENTIDADE"
```

Esperado:

- Importador V3: `M=2 | F=1 | err=0 | skip=0`;
- VBE > Depurar > Compilar VBAProject passa limpo;
- Janela Imediata:

```vb
TV2_RunIntegridadeEstado
```

Esperado: `OK=4 | FALHA=0`.

Racional do fix:

- substituir `EntireRow.Copy` por copia de faixa A:V por valor/formato;
- preservar `Err.Description` antes do bloco defensivo `On Error Resume Next`;
- ordenar `ENTIDADE` ainda no periodo de escrita controlada.

## Fix2 — Token Textual da Suite Dirigida

Aberto apos `TV2_RunIntegridadeEstado` reportar `OK=3 | FALHA=1` no cenario `CS_EST_04_ENTIDADE_INATIVACAO_SEM_ENTIREROW_COPY`.

A falha era textual: o form importado ainda continha `ActiveCell` em comentario historico, embora o fluxo runtime ja estivesse sem `ActiveCell`, `Selection.Copy` e `EntireRow.Copy`.

Janela Imediata:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_ESTADO_FIX2_TV2_TOKEN", "fd45a5d+ONDA38.2.4-ESTADO-FIX2-TV2-TOKEN"
```

Esperado:

- Importador V3: `M=1 | F=1 | err=0 | skip=0`;
- VBE > Depurar > Compilar VBAProject passa limpo;
- Janela Imediata:

```vb
TV2_RunIntegridadeEstado
```

Esperado: `OK=4 | FALHA=0`.

## Fix3 — Ultima Linha de Tabela

Aberto apos revalidacao manual detectar erro ao inativar a ultima entidade ativa remanescente. A causa e especifica de tabela Excel: excluir a unica linha de dados de um `ListObject` pode ser recusado como exclusao de linha de cabecalho/insercao.

Janela Imediata:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_ESTADO_FIX3_LAST_ROW_TABLE", "fd45a5d+ONDA38.2.4-ESTADO-FIX3-LAST-ROW-TABLE"
```

Esperado:

- Importador V3: `M=3 | F=0 | err=0 | skip=0`;
- VBE > Depurar > Compilar VBAProject passa limpo;
- Janela Imediata:

```vb
TV2_RunIntegridadeEstado
```

Esperado: `OK=5 | FALHA=0`.

Racional do fix:

- `Util_ExcluirLinhaSegura` continua deletando linhas normais de `ListObject`;
- quando resta uma unica linha de dados, o helper limpa o conteudo da linha e preserva a estrutura da tabela;
- a suite dirigida passa a validar explicitamente esse contrato.

## Fix4 — Protecao Efetiva de Abas Criticas

Aberto apos revalidacao manual detectar que abas criticas ainda aceitavam escrita direta.

Janela Imediata:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_ESTADO_FIX4_PROTECAO_ABAS", "fd45a5d+ONDA38.2.4-ESTADO-FIX4-PROTECAO-ABAS"
```

Esperado:

- Importador V3: `M=3 | F=0 | err=0 | skip=0`;
- VBE > Depurar > Compilar VBAProject passa limpo;
- `TV2_RunIntegridadeEstado`: suite sem falhas;
- edicao direta bloqueada nas abas criticas.

## Fix5 — Objetos em Abas Criticas

Aberto apos Fix4 bloquear escrita direta, mas ainda restar imagem/objeto em `ENTIDADE_INATIVOS`.

Janela Imediata:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_ESTADO_FIX5_OBJETOS_ABAS", "fd45a5d+ONDA38.2.4-ESTADO-FIX5-OBJETOS-ABAS"
```

Esperado:

- Importador V3: `M=3 | F=0 | err=0 | skip=0`;
- VBE > Depurar > Compilar VBAProject passa limpo;
- Janela Imediata:

```vb
TV2_RunIntegridadeEstado
```

Esperado: `OK=8 | FALHA=0 | MANUAL=0`.

Observacao: a limpeza de objetos residuais ocorre dentro da suite dirigida, via `Util_LimparObjetosAbasCriticas`, e a protecao e reaplicada em seguida.

## Revalidacao Manual Dirigida

Validar na interface somente o escopo da Onda 38.2.4:

- cadastro/listagem de entidades em base populada nao colapsa apos ordenacao;
- inativar o primeiro item ativo de `ENTIDADE`;
- reativar o mesmo item;
- inativar um item intermediario ou final;
- inativar a ultima entidade ativa remanescente;
- confirmar que a entidade movida nao fica simultaneamente em `ENTIDADE` e `ENTIDADE_INATIVOS`;
- abas criticas permanecem protegidas contra edicao direta pelo operador apos o ciclo normal de abertura com macros.
- `ENTIDADE_INATIVOS` nao contem imagem residual apos `TV2_RunIntegridadeEstado`;
- inserir, colar, mover ou excluir imagem/objeto nas abas criticas fica bloqueado pelo Excel.

Se qualquer etapa falhar, nao avancar para a proxima onda; preservar print/CSV e trazer o erro para Codex.
