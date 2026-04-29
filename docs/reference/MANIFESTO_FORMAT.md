# Especificacao do MANIFESTO V2

> Diataxis: Reference (especificacao formal).
> Para visao conceitual, ver [`docs/explanation/IMPORTADOR_V2.md`](../explanation/IMPORTADOR_V2.md).
> Para passo a passo, ver [`docs/how-to/COMO_IMPORTAR_PACOTE_VBA.md`](../how-to/COMO_IMPORTAR_PACOTE_VBA.md).

## Localizacao

```
local-ai/vba_import/000-MANIFESTO-IMPORTACAO.txt
```

Pacote `local-ai/` e CLA-controlado e gitignored. Auditores externos
podem inspecionar **esta especificacao** publicamente; o conteudo do
arquivo em si e distribuido apenas a contribuidores com CLA assinado.

## Encoding e EOL

| Atributo | Valor |
|---|---|
| Encoding | UTF-8 sem BOM |
| EOL | CRLF (`\r\n`) |
| Final do arquivo | 3 CRLFs (regra 13 V203) |
| Caracteres unicode | nao permitidos em comentarios (em-dash, en-dash, ellipsis sao normalizados pelo publish) |

Validacao automatica em `publicar_vba_import_v2.py` (CLA-controlado) +
`glasswing-checks.sh G7+G8`.

## Sintaxe

### Linhas de comentario

Linhas iniciadas por `#` sao comentarios.

```
# Manifesto V2 do pacote VBA - fonte de verdade para Importador_V2.bas
```

### Linhas de cabecalho de grupo

```
# GRUPO_<NOME> - <descricao breve>
```

`<NOME>` e um dos 9 grupos canonicos (ver abaixo). A descricao apos o
hifen e livre.

### Linhas de item

Formato:

```
<TIPO>|<caminho relativo ao vba_import>
```

Onde:

- `<TIPO>` e exatamente um caractere: `M` (modulo `.bas`) ou `F`
  (formulario `.frm`).
- `<caminho relativo>` usa `/` como separador. Sera convertido
  internamente para `Application.PathSeparator` na execucao.

Exemplos:

```
M|001-modulo/AAA-Mod_Types.bas
M|001-modulo/AAB-Const_Colunas.bas
F|002-formularios/AAA-Fundo_Branco.frm
```

### Separador de grupo

**Linha em branco** separa grupos. O parser
(`IV2_LerManifesto`) usa exclusivamente isso para segmentar.

## Estrutura completa esperada

```
# Manifesto V2 do pacote VBA - fonte de verdade para Importador_V2.bas
# Formato: M|caminho relativo .bas  ou  F|caminho relativo .frm
# Linhas comecando com # sao comentarios.
# Linhas em branco separam GRUPOS.
# Importador_V2 valida compilacao apos cada grupo.
# Atualizado automaticamente por publicar_vba_import_v2.sh
# Ultima atualizacao: <YYYY-MM-DD HH:MM:SS>

# GRUPO_TYPES - sempre primeiro (Public Type isolado em Mod_Types - Glasswing G8). Importador_V2 trata como TABU: pula se hash bate, aborta se diverge.
M|001-modulo/AAA-Mod_Types.bas

# GRUPO_BASE - constantes, identidade, utils basicos
M|001-modulo/AAB-Const_Colunas.bas
...

# GRUPO_INFRA - logging, contexto, error, transacao
...

# GRUPO_REPOS - repositorios CRUD que tocam abas
...

# GRUPO_SERVICES - logica de negocio
...

# GRUPO_DOMAIN - operacoes que tocam varias abas
...

# GRUPO_RELEASE - identidade do build
M|001-modulo/AAX-App_Release.bas

# GRUPO_STARTUP - entry point
M|001-modulo/AAY-Auto_Open.bas

# GRUPO_TESTS - cenarios automatizados
...

# GRUPO_FORMS - apos todos os modulos (workbook estabilizado usa .code-only.txt)
F|002-formularios/AAA-Fundo_Branco.frm
...
```

## Os 9 grupos canonicos

A ordem e **significativa**. Importador_V2 processa em ordem de cima
para baixo, validando compilacao apos cada grupo (em modo real).

| # | Nome | Conteudo | Por que nesta posicao |
|---|---|---|---|
| 1 | `GRUPO_TYPES` | `Mod_Types.bas` | Define `Public Type` usados por todo o resto |
| 2 | `GRUPO_BASE` | constantes, util_*, funcoes basicas, variaveis | Modulos sem dependencia de servicos |
| 3 | `GRUPO_INFRA` | logging, contexto, error boundary, transacao | Plumbing que servicos consomem |
| 4 | `GRUPO_REPOS` | repositorios CRUD por entidade | Tocam abas; consumem types + base + infra |
| 5 | `GRUPO_SERVICES` | logica de negocio por dominio | Consomem repos |
| 6 | `GRUPO_DOMAIN` | operacoes que cruzam dominios | Consomem services |
| 7 | `GRUPO_RELEASE` | `App_Release` (identidade do build) | Independente, pode ser ultimo dos modulos |
| 8 | `GRUPO_STARTUP` | `Auto_Open` (entry point) | Roda no boot do workbook |
| 9 | `GRUPO_TESTS` | cenarios automatizados (V1, V2, ...) | Consomem todo o resto |
| 10 | `GRUPO_FORMS` | formularios `.frm/.frx` | Apos TODOS os modulos |

> Observacao: o `Importador_V2.bas` em si **nao** entra no manifesto. E
> a propria ferramenta de import; importar a si mesmo durante a propria
> execucao seria recursivo. Quando precisa atualizar, faz-se por
> Arquivo > Importar manual no VBE.

## Convencao de prefixos

Cada arquivo no pacote (e no manifesto) tem prefixo de 3 letras para
ordenacao alfabetica robusta:

- `AAA-` ... `AAZ-`, depois `ABA-` ... `ABZ-`, etc.
- 26^3 = 17576 slots.

Mapeamento completo em `local-ai/vba_import/000-MAPA-PREFIXOS.txt`.

Funcao do prefixo:

1. **Ordenacao em sistemas de arquivos** que listam alfabeticamente.
2. **Fallback humano** quando o Importador V2 falha — operador pode
   importar manualmente em ordem alfabetica e ja respeita topologia.
3. **Auditabilidade** — auditor consegue saber a ordem esperada sem
   abrir o manifesto.

## Geracao automatica

O manifesto **nao** e editado manualmente. E regenerado a cada execucao
de:

```
bash local-ai/scripts/publicar_vba_import_v2.sh --apply
```

O script:

1. Le `src/vba/*.bas` e `src/vba/*.frm`.
2. Aplica normalizacao (UTF-8, CRLF, EOF=3 CRLFs, ASCII puro nos
   comentarios).
3. Copia para `local-ai/vba_import/001-modulo/<prefixo>-<nome>.bas` ou
   `local-ai/vba_import/002-formularios/<prefixo>-<nome>.frm`.
4. Regenera `000-MANIFESTO-IMPORTACAO.txt` agrupando arquivos pelo
   `GRUPOS_MODULOS` dict (definido no proprio script).
5. Regenera `000-MAPA-PREFIXOS.txt`.
6. Atualiza `000-BUILD-INFO.txt` com hash do conjunto.
7. Roda Glasswing G7+G8 ao final.

Resultado: o manifesto reflete **exatamente** o estado de `src/vba/`
no momento do publish.

## Validacao do manifesto

| Verificacao | Onde |
|---|---|
| Encoding UTF-8 + CRLF + EOF=3 CRLFs | `publicar_vba_import_v2.py` |
| ASCII puro em comentarios | `publicar_vba_import_v2.py` (normaliza em-dash, en-dash, ellipsis) |
| Hash sincronizado com src/vba | Glasswing G7 (`md5sum`) |
| Public Type so em Mod_Types | Glasswing G8 |
| Sem violacao em commit | git pre-commit hook |
| Parsing correto | `IV2_LerManifesto` (binary read + EOL normalize) |

## Compatibilidade

- Excel 2016+ (Windows e Mac).
- VBA 7.x.
- VBOM habilitado.

Nao depende de bibliotecas externas. Toda a logica esta em VBA puro
+ scripts bash/python.

## Versionamento

Versao do manifesto = versao do release (V12.0.0203 atual). Mudancas
quebraveis no formato pedem incremento de versao do produto e
atualizacao desta especificacao.

Historico em `CHANGELOG.md` raiz.
