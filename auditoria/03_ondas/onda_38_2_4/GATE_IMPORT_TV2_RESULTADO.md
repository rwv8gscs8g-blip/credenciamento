---
titulo: Gate Import e TV2 — Onda 38.2.4
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-31
---

# Gate Import e TV2 — Onda 38.2.4

## Resultado

Status: APROVADO para import/compile ate Fix4; Fix5 preparado e pendente de execucao.

## Fase 1 — Modulos

Comando executado por Mauricio:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_INTEGRIDADE_ESTADO_F1_MODULOS", "fd45a5d+ONDA38.2.4-ESTADO-F1-MODULOS"
```

Resultado reportado:

- backup V3: `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260530_112008-V3-FULL`
- `M=4 | F=0 | err=0 | skip=0`
- componentes importados:
  - `Classificar`
  - `Util_Planilha`
  - `Teste_V2_Roteiros`
  - `App_Release`
- compile manual VBE: APROVADO

## Fase 2 — Form

Comando executado por Mauricio:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_INTEGRIDADE_ESTADO_F2_FORMS", "fd45a5d+ONDA38.2.4-ESTADO-F2-FORMS"
```

Resultado reportado:

- backup V3: `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260530_112059-V3-FULL`
- `M=1 | F=1 | err=0 | skip=0`
- componentes importados:
  - `Altera_Entidade` via `AAE-Altera_Entidade.code-only.txt`
  - `App_Release`
- compile manual VBE: APROVADO

## Suite dirigida

Macro executada:

```vb
TV2_RunIntegridadeEstado
```

Resultado reportado:

- execucao: `TV2_20260530_112240`
- `OK=3 | FALHA=0 | MANUAL=0`
- CSV de falhas: nao exportado por ausencia de falhas

## Interpretacao

A microvalidacao da Onda 38.2.4 passou:

- `CS_EST_01_CLASSIFICAR_SEM_XLGUESS`: verde
- `CS_EST_02_ENTIDADE_INATIVACAO_ATOMICA`: verde
- `CS_EST_03_PROTECAO_ABAS_CRITICAS`: verde

## Fix1 — Entidade

Comando executado por Mauricio:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_ESTADO_FIX1_ENTIDADE", "fd45a5d+ONDA38.2.4-ESTADO-FIX1-ENTIDADE"
```

Resultado reportado:

- backup V3: `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260530_145332-V3-FULL`
- `M=2 | F=1 | err=0 | skip=0`
- compile manual VBE: APROVADO
- RVS completo posterior: `VR_20260530_145839`, APROVADO

Observacao: `TV2_RunIntegridadeEstado` reportou `OK=3 | FALHA=1`, com falha textual em `CS_EST_04` por token `ActiveCell` presente em comentario historico do form.

## Fix2 — Token TV2

Comando executado por Mauricio:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_ESTADO_FIX2_TV2_TOKEN", "fd45a5d+ONDA38.2.4-ESTADO-FIX2-TV2-TOKEN"
```

Resultado reportado:

- backup V3: `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260530_153715-V3-FULL`
- `M=1 | F=1 | err=0 | skip=0`
- compile manual VBE: APROVADO
- `TV2_RunIntegridadeEstado`: execucao `TV2_20260530_153820`, `OK=4 | FALHA=0 | MANUAL=0`
- CSV de falhas: nao exportado por ausencia de falhas

## Interpretacao Final

A microvalidacao automatizada da Onda 38.2.4 passou apos Fix2:

- `CS_EST_01_CLASSIFICAR_SEM_XLGUESS`: verde
- `CS_EST_02_ENTIDADE_INATIVACAO_ATOMICA`: verde
- `CS_EST_03_PROTECAO_ABAS_CRITICAS`: verde
- `CS_EST_04_ENTIDADE_INATIVACAO_SEM_ENTIREROW_COPY`: verde

## Fix3 — Ultima Linha de Tabela

Aberto apos revalidacao manual pos-Fix2 detectar erro ao inativar a ultima entidade ativa:

> As linhas de Cabecalho e de Insercao de uma tabela que nao contenha dados nao podem ser excluidas.

Diagnostico: `Util_ExcluirLinhaSegura` deletava a `ListRow`; quando a tabela tem so uma linha de dados, o Excel recusa a exclusao da estrutura da tabela. O fix preserva a tabela e limpa o conteudo da unica linha.

Comando preparado:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_ESTADO_FIX3_LAST_ROW_TABLE", "fd45a5d+ONDA38.2.4-ESTADO-FIX3-LAST-ROW-TABLE"
```

Esperado:

- import: `M=3 | F=0 | err=0 | skip=0`;
- compile manual VBE: APROVADO;
- `TV2_RunIntegridadeEstado`: `OK=5 | FALHA=0 | MANUAL=0`.

Resultado reportado por Mauricio:

- backup V3: `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260530_162157-V3-FULL`
- `M=3 | F=0 | err=0 | skip=0`
- componentes importados:
  - `Util_Planilha`
  - `Teste_V2_Roteiros`
  - `App_Release`
- compile manual VBE: APROVADO
- `TV2_RunIntegridadeEstado`: execucao `TV2_20260530_162347`, `OK=5 | FALHA=0 | MANUAL=0`
- CSV de falhas: nao exportado por ausencia de falhas

## Interpretacao Pos-Fix3

A microvalidacao automatizada da Onda 38.2.4 passou apos Fix3:

- `CS_EST_01_CLASSIFICAR_SEM_XLGUESS`: verde
- `CS_EST_02_ENTIDADE_INATIVACAO_ATOMICA`: verde
- `CS_EST_03_PROTECAO_ABAS_CRITICAS`: verde
- `CS_EST_04_ENTIDADE_INATIVACAO_SEM_ENTIREROW_COPY`: verde
- `CS_EST_05_EXCLUIR_LINHA_UNICA_TABELA`: verde

O gate nao fecha a onda sozinho. O RVS completo pos-Fix3 passou, mas a confirmacao manual de protecao de abas criticas falhou: foi possivel editar `ENTIDADE`, `ENTIDADE_INATIVOS` e `PRE_OS` diretamente.

## Fix4 — Protecao Efetiva de Abas Criticas

Aberto apos reteste manual D4 detectar que nenhuma aba critica estava protegida contra escrita direta do operador, mesmo com RVS completo aprovado.

Comando preparado:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_ESTADO_FIX4_PROTECAO_ABAS", "fd45a5d+ONDA38.2.4-ESTADO-FIX4-PROTECAO-ABAS"
```

Esperado:

- import: `M=3 | F=0 | err=0 | skip=0`;
- compile manual VBE: APROVADO;
- `TV2_RunIntegridadeEstado`: `OK=6 | FALHA=0 | MANUAL=0`;
- reteste manual D4 imediato: edicao direta bloqueada em `ENTIDADE`, `ENTIDADE_INATIVOS` e `PRE_OS`;
- RVS completo pos-Fix4 aprovado;
- reteste manual D4 pos-RVS: edicao direta continua bloqueada.

Resultado reportado por Mauricio:

- backup V3: `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260530_204725-V3-FULL`
- `M=3 | F=0 | err=0 | skip=0`
- componentes importados:
  - `Util_Planilha`
  - `Teste_V2_Roteiros`
  - `App_Release`
- compile manual VBE: APROVADO
- reteste manual D4: bloqueio confirmado em `ENTIDADE`, `ENTIDADE_INATIVOS`, `PRE_OS`, `CAD_OS` e `EMPRESAS`
- RVS completo pos-Fix4: `VR_20260530_210350`, APROVADO

Pendencia: Fix5 de limpeza de objeto residual autorizado e preparado. Rodar novamente `TV2_RunIntegridadeEstado` apos Fix5.

## Fix5 — Objetos em Abas Criticas

Aberto apos reteste manual pos-Fix4 confirmar bloqueio de escrita direta, mas ainda encontrar objeto/imagem residual em `ENTIDADE_INATIVOS`.

Comando preparado:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_ESTADO_FIX5_OBJETOS_ABAS", "fd45a5d+ONDA38.2.4-ESTADO-FIX5-OBJETOS-ABAS"
```

Esperado:

- import: `M=3 | F=0 | err=0 | skip=0`;
- compile manual VBE: APROVADO;
- `TV2_RunIntegridadeEstado`: `OK=8 | FALHA=0 | MANUAL=0`;
- reteste manual D5: sem imagem residual em `ENTIDADE_INATIVOS`;
- reteste manual D5: edicao direta e objetos bloqueados nas abas criticas;
- RVS completo pos-Fix5 aprovado.

Observacao: a limpeza do objeto residual ocorre durante `TV2_RunIntegridadeEstado`, por meio de `Util_LimparObjetosAbasCriticas`, e a protecao e reaplicada em seguida.

Resultado reportado por Mauricio em 2026-05-31:

- workbook path: `\\Mac\Home\Projetos\Credenciamento`
- backup V3: `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260531_013500-V3-FULL`
- `M=3 | F=0 | err=0 | skip=0`
- componentes importados:
  - `Util_Planilha` (914 linhas)
  - `Teste_V2_Roteiros` (4958 linhas)
  - `App_Release` (406 linhas)
- compile manual VBE: APROVADO
- `TV2_RunIntegridadeEstado`: execucao `TV2_20260531_013557`, `OK=8 | FALHA=0 | MANUAL=0`
- CSV de falhas: nao exportado por ausencia de falhas

## Interpretacao Pos-Fix5

A microvalidacao automatizada da Onda 38.2.4 passou apos Fix5:

- `CS_EST_01_CLASSIFICAR_SEM_XLGUESS`: verde
- `CS_EST_02_ENTIDADE_INATIVACAO_ATOMICA`: verde
- `CS_EST_03_PROTECAO_ABAS_CRITICAS`: verde
- `CS_EST_04_ENTIDADE_INATIVACAO_SEM_ENTIREROW_COPY`: verde
- `CS_EST_05_EXCLUIR_LINHA_UNICA_TABELA`: verde
- `CS_EST_06_PROTECAO_CRITICA_BLOQUEIA_CELULAS`: verde
- `CS_EST_07_OBJETOS_ABAS_CRITICAS`: verde
- `CS_EST_08_OBJETOS_ABAS_CRITICAS_ZERO`: verde

O gate automatizado nao fecha a onda sozinho. O reteste manual D5 e o RVS completo pos-Fix5 foram executados depois desta suite e passaram:

- `ENTIDADE_INATIVOS` limpa, sem imagem/objeto residual;
- edicao direta bloqueada nas abas criticas testadas;
- colagem de imagem/objeto bloqueada corretamente;
- RVS completo pos-Fix5 `VR_20260531_092609` aprovado no build `fd45a5d+ONDA38.2.4-ESTADO-FIX5-OBJETOS-ABAS`.

Com isso, a evidencia de import/TV2/D5/RVS da Onda 38.2.4 esta pronta para auditoria cruzada curta pos-onda. Isso ainda nao declara freeze V206.
