---
titulo: Gate D5 — Objetos em Abas Criticas
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-31
---

# Gate D5 — Objetos em Abas Criticas

## Objetivo

Remover objetos residuais de abas criticas e garantir que a protecao de planilha tambem cubra objetos (`DrawingObjects=True`). Este gate complementa o D4: D4 confirmou bloqueio de escrita direta em celulas; D5 fecha a higiene e a protecao de imagens, shapes e objetos colados.

## Manifesto

```text
local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_4_ESTADO_FIX5_OBJETOS_ABAS.txt
```

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_4_ESTADO_FIX5_OBJETOS_ABAS", "fd45a5d+ONDA38.2.4-ESTADO-FIX5-OBJETOS-ABAS"
```

Resultado esperado:

- import V3: `M=3 | F=0 | err=0 | skip=0`;
- VBE > Depurar > Compilar VBAProject: aprovado;
- `TV2_RunIntegridadeEstado`: `OK=8 | FALHA=0 | MANUAL=0`;
- nenhum CSV de falhas da suite dirigida.

## Resultado Automatizado

Status: APROVADO em 2026-05-31.

- workbook path: `\\Mac\Home\Projetos\Credenciamento`
- backup V3: `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260531_013500-V3-FULL`
- import V3: `M=3 | F=0 | err=0 | skip=0`
- compile manual VBE: APROVADO
- `TV2_RunIntegridadeEstado`: execucao `TV2_20260531_013557`, `OK=8 | FALHA=0 | MANUAL=0`
- CSV de falhas: nao exportado por ausencia de falhas

## Cobertura Entregue

- `Util_LimparObjetosAbasCriticas` remove `Shapes` existentes nas abas criticas e reaplica protecao.
- `Util_VerificarObjetosAbasCriticas` valida `Shapes.Count = 0` e `ProtectDrawingObjects=True`.
- `Util_VerificarProtecaoAbasCriticas` passa a reprovar aba critica que esteja protegida sem proteger objetos.
- `TV2_RunIntegridadeEstado` adiciona assert estrutural para limpeza/verificacao de objetos.

## Reteste Manual Obrigatorio

Status: APROVADO em 2026-05-31.

1. Confirmar que o objeto/imagem residual em `ENTIDADE_INATIVOS` desapareceu apos `TV2_RunIntegridadeEstado`.
2. Tentar editar celula de dados em `ENTIDADE`, `ENTIDADE_INATIVOS`, `PRE_OS`, `CAD_OS` e `EMPRESAS`.
3. Tentar colar ou inserir imagem/objeto em `ENTIDADE_INATIVOS`.
4. Tentar mover, redimensionar ou excluir objeto em uma aba critica, se houver objeto disponivel no momento do teste.
5. Rodar RVS completo pos-Fix5.
6. Repetir os passos 2 a 4 imediatamente apos o RVS.

Resultado reportado por Mauricio:

- `ENTIDADE_INATIVOS` limpa, sem imagem/objeto residual.
- Edicao direta bloqueada nas planilhas criticas testadas.
- Tentativa de colar imagem bloqueada corretamente.
- Mensagem esperada do Excel observada: celula/grafico em planilha protegida ou impossibilidade de colar dados.
- RVS completo pos-Fix5 aprovado: `VR_20260531_092609`.

Reteste `ENT_MAN_23` pos-RVS reportado por Mauricio em 2026-05-31 12:22:

- `?ThisWorkbook.Path`: `\\Mac\Home\Projetos\Credenciamento`
- `?GetBuildImportado()`: `fd45a5d+ONDA38.2.4-ESTADO-FIX5-OBJETOS-ABAS`
- `?Format(Now, "yyyy-mm-dd hh:nn:ss")`: `2026-05-31 12:22:07`
- Bloqueio confirmado em `ENTIDADE`, `ENTIDADE_INATIVOS`, `PRE_OS`, `CAD_OS`, `EMPRESAS` e aba de empresas inativas, conforme telas reportadas.
- Tentativa de colagem/alteracao continua bloqueada por protecao de planilha ou impossibilidade de colar dados.

## RVS Pos-Fix5

Status: APROVADO em 2026-05-31.

- Validacao ID: `VR_20260531_092609`
- Build: `fd45a5d+ONDA38.2.4-ESTADO-FIX5-OBJETOS-ABAS`
- CSV: `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260531_092609.csv`
- SHA-256 do CSV: `ee0bbd9840cce362592aa856ee9224b921ff8467fdc8aea8dc1e5ee240c48056`

Sintaxe:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

## Criterio de Aceite

O Gate D5 passa somente se:

- o teste dirigido retorna `OK=8 | FALHA=0 | MANUAL=0`;
- nao restam objetos residuais em abas criticas;
- o operador nao consegue editar celulas nem objetos sem desbloqueio intencional;
- o RVS completo pos-Fix5 passa e nao remove a protecao aplicada.

Se qualquer tentativa manual permitir escrita, colagem ou movimentacao de objeto em aba critica, a Onda 38.2.4 permanece bloqueada.

Status final do D5: APROVADO. A auditoria cruzada curta pos-onda foi concluida por Antigravity/Gemini e Opus 4.8 sem BLOQUEADOR incondicional. A Onda 38.2.4 pode fechar o ERP 0120; isso ainda nao declara freeze V206 nem libera propagacao automatica do padrao para outros campos.
