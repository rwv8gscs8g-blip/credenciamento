---
titulo: Gate D4 — Protecao de Abas Criticas
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-30
---

# Gate D4 — Protecao de Abas Criticas

## Resultado

Status: BLOQUEIO DE ESCRITA DIRETA CONFIRMADO POS-FIX4; HIGIENE DE OBJETOS MOVIDA PARA D5.

## Evidencia Automatizada

`TV2_RunIntegridadeEstado` passou apos Fix3 com `OK=5 | FALHA=0 | MANUAL=0`, incluindo `CS_EST_03_PROTECAO_ABAS_CRITICAS`.

O RVS completo pos-Fix3 tambem passou:

- Validacao ID: `VR_20260530_164422`
- Build: `fd45a5d+ONDA38.2.4-ESTADO-FIX3-LAST-ROW-TABLE`
- Resultado: APROVADO

Essas evidencias nao liberam a onda porque o reteste manual D4 mostrou que o workbook continuava editavel diretamente.

## Evidencia Manual Bloqueadora

Mauricio confirmou que, apos RVS aprovado, foi possivel editar diretamente celulas de dados em:

- `ENTIDADE`;
- `ENTIDADE_INATIVOS`;
- `PRE_OS`.

Tambem foi possivel escrever em `ENTIDADE_INATIVOS` e havia objeto/imagem colado na aba, evidenciando que a protecao de objetos tambem nao estava efetiva.

Classificacao: BLOQUEADOR para fechamento da Onda 38.2.4 e para qualquer freeze V206.

## Fix4 Executado

Manifesto:

```text
local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_4_ESTADO_FIX4_PROTECAO_ABAS.txt
```

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_ESTADO_FIX4_PROTECAO_ABAS", "fd45a5d+ONDA38.2.4-ESTADO-FIX4-PROTECAO-ABAS"
```

Resultado reportado por Mauricio:

- backup V3: `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260530_204725-V3-FULL`
- import: `M=3 | F=0 | err=0 | skip=0`
- componentes importados:
  - `Util_Planilha`
  - `Teste_V2_Roteiros`
  - `App_Release`
- compile manual VBE: APROVADO

Mudanca de criterio entregue:

- `Util_ProtegerAbasCriticasVerificado` passa a bloquear todas as celulas das abas criticas antes de proteger.
- `Util_VerificarProtecaoAbasCriticas` passa a exigir `ProtectContents=True` e celulas bloqueadas.
- `Util_RestaurarProtecaoAba` passa a reproteger abas criticas mesmo quando elas iniciaram desprotegidas.
- `TV2_RunIntegridadeEstado` passa a ter `CS_EST_06_PROTECAO_CRITICA_BLOQUEIA_CELULAS`.

## Reteste Manual Pos-Fix4

Mauricio confirmou bloqueio de escrita direta em:

- `ENTIDADE`;
- `ENTIDADE_INATIVOS`;
- `PRE_OS`;
- `CAD_OS`;
- `EMPRESAS`.

Tambem foi confirmado que `ENTIDADE_INATIVOS` ainda contem objeto/imagem residual. A interpretacao tecnica atual e que o objeto provavelmente foi criado antes da protecao efetiva e deve ser removido em microdelta auditavel. A evidencia de bloqueio de escrita direta nao elimina essa divida de higiene do workbook; por isso o tema foi isolado no Gate D5 / Fix5.

## Evidencia RVS Pos-Fix4

RVS completo reportado como aprovado:

- Validacao ID: `VR_20260530_210350`
- Build: `fd45a5d+ONDA38.2.4-ESTADO-FIX4-PROTECAO-ABAS`
- CSV: `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260530_210350.csv`

## Reteste Ainda Obrigatorio

1. Importar e compilar o Fix5 de objetos em abas criticas.
2. Rodar `TV2_RunIntegridadeEstado`; esperado: `OK=8 | FALHA=0 | MANUAL=0`.
3. Confirmar visualmente que `ENTIDADE_INATIVOS` nao contem objeto/imagem residual.
4. Sem desbloquear, tentar editar `ENTIDADE`, `ENTIDADE_INATIVOS`, `PRE_OS`, `CAD_OS` e `EMPRESAS`.
5. Sem desbloquear, tentar colar, mover, redimensionar ou excluir imagem/objeto em `ENTIDADE_INATIVOS` e em uma segunda aba critica.
6. Repetir os passos 4 e 5 imediatamente apos o RVS, se a confirmacao anterior tiver sido feita antes do RVS.

## Criterio de Decisao

Se o passo 3/4 passar antes do RVS mas falhar depois do RVS, a causa provavel passa a ser alguma rotina fora do escopo inicial deixando abas desprotegidas no final das baterias. Nesse caso, parar e pedir hearback para ampliar o readback, possivelmente para `Teste_Validacao_Release.bas` e/ou `Auto_Open.bas`.
