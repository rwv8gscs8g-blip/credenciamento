---
titulo: Padronizacao obrigatoria de encoding, line endings e EOF para arquivos .frm e .bas
data: 2026-04-28
autoria: Claude Opus 4.7 (Cowork) na Onda 6 hotfix v4, com diagnostico provocado por Mauricio
aplica-a: todo arquivo .frm e .bas em src/vba/ e em local-ai/vba_import/
revisar-em: fechamento estavel da V12.0.0203
status: vigente — root cause comprovada na hotfix v4
fonte-historica: local-ai/obsidian-vault/historico/ai-context-legacy/known_issues.md secao 2.0 (regressao recorrente EOF invalido)
relacionados:
  - 0002-regra-ouro-vba-import.md
  - 0005-bug-form-importado-como-modulo.md
---

# Padronizacao obrigatoria — encoding, line endings, EOF

## TL;DR

Todo arquivo `.frm` **E** `.bas` versionado neste repositorio **DEVE** ter:

1. **Line endings: CRLF** (Windows, `\r\n`)
2. **Encoding: UTF-8 ou Windows-1252** ASCII puro nos comentarios — **proibido em-dash (`—` U+2014), ellipsis (`…` U+2026), smart quotes (`' " ` U+2018-U+201F`)**
3. **EOF: termina com 3 CRLFs** apos a ultima `End Sub`/`End Function` (i.e., `\r\n\r\n\r\n`) — equivalente a "ultima linha + **duas linhas em branco extras OBRIGATORIAS**"
4. **Cabecalho FRM (forms apenas):** linhas 1-15 imutaveis seguindo template canonico

## A regra das duas linhas em branco extras (REGRA DURA)

**Esta regra e inegociavel e foi reforcada por Mauricio no hotfix v4
(2026-04-28) apos investigacao da regressao recorrente:**

> "todo .bas e .frm publicado para `vba_import/` deve usar CRLF e deve
> terminar com **uma linha vazia extra no EOF**" — `local-ai/obsidian-vault/historico/ai-context-legacy/known_issues.md` secao 2.0

A regra original falava de "uma linha vazia extra"; a observacao pratica
nos forms que funcionam (Altera_Empresa, Fundo_Branco, Limpar_Base, etc.)
mostra **3 CRLFs trailing** (`\r\n\r\n\r\n`) — equivalente a `End Sub` +
2 linhas em branco no fim do arquivo.

**Em bytes:**
- `End Sub\r\n` (linha do `End Sub` propriamente dita)
- `\r\n` (1a linha em branco extra)
- `\r\n` (2a linha em branco extra)

Se faltar qualquer um desses 2 `\r\n` extras, o VBE pode (em
combinacao com em-dashes ou outros caracteres unicode) tratar o arquivo
como modulo padrao em vez de form, ou nao reconhecer membros publicos
ao importar (sintoma classico: "Metodo ou membro de dados nao encontrado").

**Toda IA que gere ou modifique `.bas`/`.frm` DEVE garantir essas 2 linhas
em branco extras antes de salvar.** Nao confiar em "o editor ja faz isso" —
diferentes editores (VS Code, vim, nano, awk, sed) tratam EOF de forma
diferente. **Verificar com `tail -c 6 <arquivo> | xxd` e confirmar que retorna
exatamente `0d0a0d0a0d0a`.**

## Por que essa regra existe

Foi descoberta empiricamente na **Onda 6 hotfix v4 (2026-04-28)** quando
o operador relatou que `Configuracao_Inicial.frm` era importado como
**modulo padrao** no VBE (em vez de formulario), gerando erro de
compilacao "Invalido fora de um procedimento".

O `.frm` tinha 3 anomalias simultaneas:

| Anomalia | Configuracao_Inicial (bugado) | Forms que funcionam |
|---|---|---|
| Line endings | LF (Unix) | CRLF (Windows) |
| EOF apos `End Function` | `\n\n\n` (3 LFs apenas) | `\r\n\r\n\r\n` (3 CRLFs) |
| Em-dashes (U+2014) em comentarios | 7 | 0 (Cadastro_Servico) ou ate 7 mas com CRLF (Menu_Principal) |

A combinacao **LF + em-dash UTF-8 (3 bytes) + EOF anomalo** confunde o
parser do VBE, que esperar Windows-1252. O VBE entao trata o `.frm`
como texto generico — e cria modulo padrao com cabecalho FRM como
codigo solto.

Em-dash sozinho nao e suficiente (`Menu_Principal.frm` tem 7 em-dashes
em CRLF e funciona). LF sozinho nao e suficiente (`Cadastro_Servico.frm`
e LF e funciona). Mas a **combinacao** quebra.

## Padrao canonico

### `.frm` valido (exemplo dos primeiros bytes)

```
00000000: 5645 5253 494f 4e20 352e 3030 0d0a       VERSION 5.00.\r\n
0000000e: 4265 6769 6e20 7b...                     Begin {...
```

Note `\r\n` (CRLF, bytes `0d 0a`), nao apenas `\n` (LF, byte `0a`).

### `.bas` valido (sem cabecalho FRM)

```
00000000: 4174 7472 6962 7574 6520 5642 5f4e 616d  Attribute VB_Nam
00000010: 6520 3d20 22                             e = "...
```

Tambem com CRLF.

### EOF padrao

Os ultimos 8 bytes devem ser:

```
xxxxxxxx: ?? ?? ?? ?? 0d 0a 0d 0a 0d 0a            ........
                       \r \n \r \n \r \n
```

Onde `?? ?? ?? ??` sao os ultimos 4 bytes de `End Sub` (`Sub\r\n`) ou
`End Function` (`tion\r\n`). Total: 3 CRLFs trailing.

## Como verificar (script de auditoria)

```bash
# Verifica todos os .frm em src/vba/ contra o padrao
for f in src/vba/*.frm; do
    # 1. Check line endings: deve ser CRLF
    if file "$f" | grep -qv "CRLF"; then
        echo "VIOLATED: $f nao tem CRLF"
    fi
    # 2. Check em-dash: deve ter zero
    count=$(grep -c $'\xe2\x80\x94' "$f" 2>/dev/null)
    if [ "$count" != "0" ]; then
        echo "WARNING: $f tem $count em-dash(es) — risco se combinado com LF"
    fi
    # 3. Check EOF: ultimos 6 bytes devem ser \r\n\r\n\r\n
    eof=$(tail -c 6 "$f" | xxd -p)
    if [ "$eof" != "0d0a0d0a0d0a" ]; then
        echo "VIOLATED: $f EOF nao e 3 CRLFs (atual: $eof)"
    fi
done
```

Esse script entra como vetor **G7** da camada Glasswing na Onda 7
(ainda a implementar).

## Como remediar quando violado

### Opcao A — manual (no editor de texto Windows)

1. Abrir o `.frm` no Notepad++.
2. Menu > Edit > EOL Conversion > Windows (CR LF).
3. Find > Replace > Habilitar regex > buscar `—` > substituir por `-`
   (hyphen-minus ASCII).
4. Ir para o final do arquivo. Garantir que apos `End Sub`/`End Function`
   haja exatamente 2 linhas em branco (i.e., 3 quebras de linha).
5. Salvar.

### Opcao B — script automatizado (entregar como `local-ai/scripts/normalizar_frm.sh` na Onda 7)

Pseudocodigo:

```
para cada .frm:
    le bytes
    substitui em-dash UTF-8 (0xe2 0x80 0x94) por hyphen ASCII (0x2d)
    decodifica utf-8
    normaliza line endings: tudo para LF primeiro
    rstrip + adiciona 1 LF
    adiciona 2 LFs extras (total 3 LFs trailing)
    converte LF para CRLF
    grava em utf-8
```

Implementacao de referencia foi usada na Onda 6 hotfix v4 — ver bash
session do dia 2026-04-28 ~22h.

## Caracteres unicode proibidos em `.frm`/`.bas`

| Caracter | Codepoint | Substituto ASCII |
|---|---|---|
| `—` (em-dash) | U+2014 | `-` (hyphen-minus) |
| `–` (en-dash) | U+2013 | `-` |
| `…` (ellipsis) | U+2026 | `...` |
| `'` (right single quote) | U+2019 | `'` |
| `'` (left single quote) | U+2018 | `'` |
| `"` (left double quote) | U+201C | `"` |
| `"` (right double quote) | U+201D | `"` |
| `«` `»` (chevrons) | U+00AB U+00BB | use `<<` `>>` ou `"` `"` |
| `→` `←` `↑` `↓` (arrows) | U+2190..2193 | use `->` `<-` `^` `v` |
| BOM | U+FEFF | NUNCA — apagar |

Caracteres acentuados latinos (`á`, `é`, `ç`, `ã`, `ó`, etc.) sao
**permitidos** porque tem 1 byte em Windows-1252 e 2 bytes em UTF-8 —
tipicamente nao quebram parser do VBE em nivel estrutural (apenas
podem aparecer como caracter "estranho" na visualizacao, mas o
formulario carrega).

## Politica permanente para IA

Toda IA que **gere** ou **modifique** `.frm`/`.bas`:

1. Antes de salvar, executar verificacao acima.
2. Substituir caracteres proibidos por equivalentes ASCII.
3. Normalizar EOF para 3 CRLFs.
4. Confirmar com `file <arquivo>` que retorna `with CRLF line terminators`.

Toda IA que **revise** uma onda antes de declarar fechada:

1. Rodar script de auditoria (secao "Como verificar").
2. Reportar violacoes na resposta como entrada da tabela canonica
   (regra 12) listando o `.frm`/`.bas` afetado e a acao remediadora.

## Como o operador detecta

Sintomas no Excel/VBE quando um `.frm` foi importado com encoding/EOF
errado:

- "Erro de compilacao: Invalido fora de um procedimento" no momento
  de compilar.
- O form aparece em **`Modulos`** (nao em `Formulários`) no Project
  Explorer.
- A janela de codigo do "form" (que virou modulo) comeca com
  `VERSION 5.00`, `Begin {GUID}`, `Caption =`, `End`,
  `Attribute VB_*`.

Recuperacao operacional documentada em
[`0005-bug-form-importado-como-modulo.md`](0005-bug-form-importado-como-modulo.md)
secao "Como recuperar quando o bug ja aconteceu".

## Historico de violacoes detectadas

| Data | Arquivo | Anomalia | Resolvido em |
|---|---|---|---|
| 2026-04-28 | `Configuracao_Inicial.frm` | LF + 3 LFs trailing + 7 em-dashes UTF-8 | Onda 6 hotfix v4 |
| 2026-04-28 | `Mod_Limpeza_Base.bas` | LF + 1 LF trailing + 6 em-dashes UTF-8 (causou erro "Metodo ou membro de dados nao encontrado" ao Preencher chamar `LimpaBaseTotalReset`) | Onda 6 hotfix v5 |
| 2026-04-28 | `Preencher.bas` | LF + 1 LF trailing + 17 em-dashes UTF-8 | Onda 6 hotfix v5 |
| 2026-04-28 | `App_Release.bas` | LF + 1 em-dash | Onda 6 hotfix v5 (preventivo, esta na lista de import da Onda 5) |

## Divida tecnica conhecida (a tratar na Onda 7)

15 outros `.bas` em `src/vba/` ainda estao em LF (Unix) e podem
produzir bug similar quando reimportados:

`Auto_Open.bas`, `Central_Testes.bas`, `Central_Testes_Relatorio.bas`,
`Central_Testes_V2.bas`, `Emergencia_CNAE.bas`, `Mod_Types.bas` (TABU
ate Onda 9), `Svc_Avaliacao.bas`, `Svc_Transacao.bas`,
`Teste_Bateria_Oficial.bas`, `Teste_V2_Engine.bas`, `Teste_V2_Roteiros.bas`,
`Teste_Validacao_Release.bas`, `Treinamento_Painel.bas`, `Util_Filtro_Lista.bas`.

A Onda 7 deve entregar `local-ai/scripts/normalizar_bas_frm.sh` que
processa todos em batch + script de auditoria que detecta regressao
(impedir commit se algum `.bas`/`.frm` voltar a violar a regra).

## Referencias

- `local-ai/obsidian-vault/historico/ai-context-legacy/known_issues.md`
  secao 2.0 — primeira documentacao (bug "Nome repetido" relacionado a
  EOF, sintoma diferente mas mesma regra de fundo).
- `local-ai/vba_import/000-REGRA-OURO.md` — Regra de Ouro do pacote.
- `.hbn/knowledge/0005-bug-form-importado-como-modulo.md` — bug
  conhecido do form virar modulo.
- `auditoria/03_ondas/onda_05_form_deterministico/38_PROCEDIMENTO_IMPORT.md`
  secao 02.4 — passos de saneamento operador.
