# Pasta `vba_import/` — deploy numerado para o Excel

> **LEIA PRIMEIRO:** [`000-REGRA-OURO.md`](000-REGRA-OURO.md) — regra
> absoluta do projeto. Espelho operacional para IAs em
> [`../../.hbn/knowledge/0002-regra-ouro-vba-import.md`](../../.hbn/knowledge/0002-regra-ouro-vba-import.md).

## Convencao do repositorio (obrigatoria)

| Pasta | Papel |
|---|---|
| `../src/vba/` | **Fonte publica da verdade** para edicao de `.bas`, `.frm` e `.frx`. Toda alteracao de codigo termina aqui. |
| `vba_export/` | **Espelho operacional local** gerado a partir de `../src/vba/`, usado apenas para montagem do pacote. |
| `vba_import/` | **Saida organizada** para importacao no VBA Editor. Prefixos alfabeticos, ordem em `000-ORDEM-IMPORTACAO.txt`, mapa em `000-MAPA-PREFIXOS.txt`. **Nao editar a mao** estes arquivos como fonte primaria. |

## Layout obrigatorio (pos-Onda 6)

```
local-ai/vba_import/
├── 000-REGRA-OURO.md              <- LEIA PRIMEIRO (texto canonico completo)
├── 000-MANIFESTO-IMPORTACAO.txt   <- contrato canonico
├── 000-MAPA-PREFIXOS.txt          <- prefixo -> nome canonico
├── 000-ORDEM-IMPORTACAO.txt       <- documentacao da ordem
├── 000-BUILD-IMPORTAR-SEMPRE.txt  <- carimbo do build atual
├── README.md                      <- este arquivo
│
├── 001-modulo/                    <- TODOS os .bas oficiais com prefixo AAX-
├── 002-formularios/               <- .frm + .frx + .code-only.txt
├── 003-objetos/                   <- objetos de planilha (raros)
│
├── Importador_VBA.bas             <- ferramenta historica (ate Onda 9)
└── Importar_Agora.bas             <- atalho conveniente
```

> **Mudanca da Onda 6 (2026-04-28):** macros descartaveis nao moram mais
> na raiz de `vba_import/`. As 5 macros que estavam aqui (Diag_Imediato,
> Diag_Simples, Limpa_Base_Total, Reset_CNAE_Total, Set_Config_Strikes_Padrao)
> foram movidas para
> `Projetos/backups/credenciamento/macros_descartaveis_v0203/` com mapa
> de retorno (ver Glasswing G1).

## Como alinhar `vba_import/` apos mudanca em `src/vba/`

> **AVISO:** O script `local-ai/scripts/publicar_vba_import.sh` foi
> **descontinuado em 28/04/2026**. A manutencao deste pacote e MANUAL
> ate o Importador_VBA reescrito (Onda 9).

Procedimento manual para cada arquivo modificado em `src/vba/`:

1. **Copiar** para `local-ai/vba_import/` na pasta correta com prefixo:

   ```bash
   cp src/vba/Mod_Limpeza_Base.bas \
      local-ai/vba_import/001-modulo/ABJ-Mod_Limpeza_Base.bas
   ```

2. **Conferir hash** entre as duas copias:

   ```bash
   md5sum src/vba/Mod_Limpeza_Base.bas \
          local-ai/vba_import/001-modulo/ABJ-Mod_Limpeza_Base.bas
   ```

3. **Atualizar** `000-MANIFESTO-IMPORTACAO.txt` (linha `M|001-modulo/AAX-Nome.bas`).
4. **Atualizar** `000-MAPA-PREFIXOS.txt` (entrada `AAX-Nome.bas => Nome.bas`).
5. **Atualizar** `000-BUILD-IMPORTAR-SEMPRE.txt` com o novo `APP_BUILD`.
6. **Para forms:** gerar `.code-only.txt` correspondente:

   ```bash
   tail -n +16 src/vba/MeuForm.frm > \
       local-ai/vba_import/002-formularios/AAX-MeuForm.code-only.txt
   ```

## Ordem de import no Excel

Use a ordem definida em:

- `vba_import/000-ORDEM-IMPORTACAO.txt`
- `vba_import/000-MAPA-PREFIXOS.txt`

Em microevolucoes, costuma bastar importar apenas os arquivos modificados
(por exemplo `AAZ-Central_Testes.bas`).

### Regra operacional

- importar primeiro os modulos `.bas`
- importar formularios `.frm` apenas depois dos modulos
- manter o `.frx` correspondente junto do formulario

### `Mod_Types.bas`

Em workbooks ja estabilizados, **nao** reimportar `AAA-Mod_Types.bas`
em microevolucao. Esse modulo so e tocado deliberadamente na **Onda 9**
(reescrita do Importador_VBA), com plano dedicado e aprovacao previa.

A referencia operacional do workbook real fica em
`local-ai/incoming/vba-forms/Mod_Types.bas`. Se houver divergencia, o
export de `incoming` e fonte de verdade — nao para reimportar
automaticamente, mas para comparar e orientar decisoes de estabilizacao.

## Nota sobre IAs

Toda IA que editar `../src/vba/` DEVE, antes de instruir o operador a
importar:

1. Ler `000-REGRA-OURO.md` e `.hbn/knowledge/0002-regra-ouro-vba-import.md`.
2. Espelhar o arquivo modificado em `local-ai/vba_import/` na pasta
   correta com o prefixo certo.
3. Conferir hash `md5sum` antes de declarar entrega completa.
4. Atualizar manifesto, mapa e build.
5. Para forms, gerar `.code-only.txt`.

A IA que entrega micro-evolucao com codigo APENAS em `src/vba/` (sem
espelhar em `vba_import/`) entrega trabalho **incompleto** — o operador
nao consegue importar.

O script `publicar_vba_import.sh` esta proibido. A IA que rodar esse
script viola a Regra de Ouro.
