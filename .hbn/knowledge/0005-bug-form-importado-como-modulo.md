---
titulo: Bug conhecido — formulario importado como modulo no VBE
data: 2026-04-28
autoria: documentado por Claude Opus 4.7 (Cowork) na Onda 6 hotfix v3, apontado por Luis Mauricio Junqueira Zanin
aplica-a: toda IA que documente procedimento de import VBA + todo operador que importe `.frm` no Excel
revisar-em: fechamento da V12.0.0203
status: vigente — bug do VBE, nao pode ser corrigido pelo projeto, apenas evitado e detectado
fonte-historica: local-ai/obsidian-vault/regras/Importador-VBA.md (macro Verificar_SemDuplicidade)
---

# Bug conhecido — formulario `.frm` importado vira modulo no VBE

## Resumo em uma frase

Quando voce faz `File > Import` no VBE apontando para um arquivo `.frm`,
o Excel pode criar um **modulo padrao** (com cabecalho FRM `VERSION 5.00`,
`Begin {GUID}`, `End`, `Attribute VB_*` como codigo solto) em vez de um
formulario, e isso quebra a compilacao com **"Invalido fora de um procedimento"**.

> **Root cause comprovada (2026-04-28 hotfix v4):** o bug acima e
> ESPECIFICAMENTE provocado quando o `.frm` viola
> [`0006-padronizacao-encoding-line-endings-frm.md`](0006-padronizacao-encoding-line-endings-frm.md):
> line endings LF (Unix) em vez de CRLF (Windows), combinado com
> caracteres unicode multibyte (em-dash `—` U+2014) em comentarios e
> EOF anomalo (3 LFs trailing). Forms com CRLF + EOF correto + ASCII puro
> nao manifestam o bug, mesmo com em-dashes. A regra preventiva
> permanente esta em 0006.

## Quando esse bug se manifesta

| Cenario | Comportamento do VBE |
|---|---|
| `.frm` importado, ja existe form com mesmo nome no projeto | VBE cria `Form1`, `Form2`... (fantasma com sufixo) |
| `.frm` importado, `.frx` correspondente AUSENTE na mesma pasta | VBE cria **modulo padrao** com cabecalho FRM como codigo solto |
| `.frm` importado, `.frx` em pasta diferente do `.frm` | VBE pode criar modulo padrao OU form sem layout |
| `.frm` renomeado como `.code-only.txt` e importado | VBE nao reconhece extensao -> cria modulo padrao com tudo dentro |
| `.code-only.txt` importado via `File > Import` | VBE nao deveria importar `.txt`, mas em algumas versoes cria modulo |
| Conflito de nome com modulo existente | VBE cria nome com sufixo (`Configuracao_Inicial1`) |

Ou seja: **`File > Import` apontando para arquivo de formulario e
inseguro em workbook estabilizado**. So funciona em workbook vazio ou
quando o `.frx` esta exatamente do lado e nenhum conflito existe.

## Por que o sintoma e "Invalido fora de um procedimento"

O `.frm` tem cabecalho que **nao e codigo VBA**:

- `VERSION 5.00`
- `Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} <NomeDoForm>`
- `Caption = ...`
- `ClientHeight = ...`
- `End`
- `Attribute VB_Name = "..."`
- `Attribute VB_GlobalNameSpace = False` ... etc.

Em um formulario, esses metadados sao gerenciados pelo VBE invisivelmente.
Em um modulo padrao, qualquer coisa que nao seja `Sub`/`Function`/`Type`/`Const`/etc.
fora de um procedimento gera o erro **"Invalido fora de um procedimento"**.

## Como detectar

Sintomas observaveis no Project Explorer (esquerda do VBE):

1. Um item chamado `<NomeDoForm>` aparece na pasta **`Modulos`** alem da
   pasta `Formulários`.
2. Itens com sufixo numerico em `Formulários`: `<NomeDoForm>1`,
   `<NomeDoForm>2`, etc.
3. Ao abrir o codigo do form, a primeira linha visivel comeca com
   `VERSION 5.00`, `Begin {GUID}`, `Caption =`, `End`, ou
   `Attribute VB_Name = ...`.
4. Compilacao falha em qualquer modulo, mas o cursor pula para o
   `Configuracao_Inicial` ou form afetado.

Diagnostico programatico (no Immediate `Ctrl+G`):

```
Call Verificar_SemDuplicidade
```

(Definido em `Importador_VBA.bas`, ver `local-ai/obsidian-vault/regras/Importador-VBA.md` secao 8.)

## Como evitar (regra preventiva V203)

**Regra inegociavel:** em workbook estabilizado (i.e., qualquer workbook
em homologacao apos a primeira release), **nao usar `File > Import` para
arquivos `.frm`**. O `.frx` correspondente ja foi customizado pelo gestor
no designer; reimport sobrescreve `.frx` (perde renomeacoes de controles)
ou cria modulo bugado.

Caminho correto (exclusivo) para atualizar codigo de form:

1. Abrir o form pelo Project Explorer (duplo-clique).
2. `F7` (Visualizar Codigo) abre a janela de codigo atras do form.
3. `Ctrl+A` + `Delete` na janela de codigo.
4. `Ctrl+V` colando do `.code-only.txt` correspondente em
   `local-ai/vba_import/002-formularios/AAX-NomeForm.code-only.txt`
   (que ja vem **puro**, sem cabecalho FRM).
5. `Ctrl+S` + `Debug > Compile VBAProject`.

`File > Import` so e seguro:

- Em workbook NOVO/limpo, ou
- Para modulos `.bas` cujo nome NAO existe ainda no projeto, ou
- Para modulos `.bas` apos remover (clique direito > Remove > No) o
  modulo de mesmo nome.

## Como recuperar quando o bug ja aconteceu

Se voce ja importou erroneamente, **antes** de tentar compilar de novo:

1. Project Explorer > pasta **`Modulos`** > **clique direito** no item
   com nome de form (ex.: `Configuracao_Inicial`) > **`Remove
   Configuracao_Inicial...`** > **No** (nao exportar).
2. Project Explorer > pasta **`Formulários`** > para cada item com
   sufixo (`Configuracao_Inicial1`, `Configuracao_Inicial2`...): **clique
   direito** > **`Remove ...`** > **No**.
3. Confirmar que apenas `Configuracao_Inicial` (sem sufixo) restou em
   `Formulários`.
4. Salvar workbook (`Ctrl+S`).
5. Compilar (`Debug > Compile VBAProject`). Deve passar agora.
6. So entao seguir o procedimento correto de substituicao de codigo
   atras do form (secao "Como evitar" acima).

Se o passo 5 falhar com "Nome repetido: TConfig" ou similar, ver
`local-ai/obsidian-vault/regras/Importador-VBA.md` secao 7.

## Por que esse bug nao foi corrigido no projeto

O bug esta no **VBE do Excel**, nao no codigo do projeto. Microsoft
nao corrigiu em 20+ anos. A unica defesa e:

1. Procedimentos rigorosos (este documento).
2. Macro `Verificar_SemDuplicidade` no `Importador_VBA.bas`.
3. `.gitignore` ja exclui copias de seguranca de forms.
4. Pacote `vba_import/` com prefixos alfabeticos para distinguir
   formulario (`002-formularios/`) de modulo (`001-modulo/`) — que
   ajuda visualmente mas nao impede o operador de errar.

## Como verificar

Apos qualquer import de pacote, antes de declarar onda fechada:

1. Project Explorer aberto. Conferir visualmente que:
   - `Formulários` tem N itens (N = numero esperado, sem sufixos).
   - `Modulos` NAO tem nenhum item com nome igual a algum form.
2. `Debug > Compile VBAProject` passa sem erro.
3. (Opcional, robusto) Rodar `Call Verificar_SemDuplicidade` no Immediate.

Se algum item com nome de form aparecer em `Modulos`, o bug se
manifestou. Aplicar recuperacao acima.

## Referencias

- `local-ai/obsidian-vault/regras/Importador-VBA.md` — manual
  operacional do importador (define `Verificar_SemDuplicidade`).
- `local-ai/vba_import/Importador_VBA.bas` — codigo-fonte do
  importador (linhas com `purge de fantasmas`).
- `local-ai/vba_import/000-REGRA-OURO.md` — secao "O que esta
  proibido" inclui "Reimportar `.frm` em workbook estabilizado".
- `auditoria/03_ondas/onda_05_form_deterministico/38_PROCEDIMENTO_IMPORT.md`
  secao 02.4 — referencia explicita a este documento.
