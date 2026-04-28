---
titulo: Regra de Ouro do pacote vba_import (consolidacao)
data: 2026-04-28
autoria: consolidacao da regra original em local-ai/vba_import/000-REGRA-OURO.md
aplica-a: toda IA que edita .bas ou .frm em src/vba/
revisar-em: fechamento estavel da V12.0.0203
status: vigente
fonte-canonica: local-ai/vba_import/000-REGRA-OURO.md
---

# Regra de Ouro do pacote `vba_import` (consolidacao para IAs)

> Este e o resumo operacional. A versao canonica completa, com layout
> obrigatorio e exemplos detalhados, esta em
> [`local-ai/vba_import/000-REGRA-OURO.md`](../../local-ai/vba_import/000-REGRA-OURO.md).

## A regra em uma frase

**Tudo o que vai ser importado para o workbook `.xlsm` precisa estar em
`local-ai/vba_import/`, na pasta correspondente ao tipo de componente,
com prefixo alfabetico que define a ordem de import.**

## Tres tipos de arquivos importaveis

| Tipo | Pasta | Exemplo | Acao |
|---|---|---|---|
| A — Modulo oficial | `001-modulo/` | `AAB-Const_Colunas.bas` | substituir conteudo no VBE |
| B — Formulario oficial | `002-formularios/` | `AAA-Fundo_Branco.frm` + `.frx` + `.code-only.txt` | substituir codigo via Ctrl+A |
| C — Macro descartavel | (NAO MAIS NA RAIZ) | era `Diag_Imediato.bas` etc. | descartado em V12.0.0203 ONDA 6 |

> **Mudanca da Onda 6 (2026-04-28):** as 5 macros descartaveis que estavam
> na raiz de `vba_import/` (Diag_Imediato, Diag_Simples, Limpa_Base_Total,
> Reset_CNAE_Total, Set_Config_Strikes_Padrao) foram movidas para
> `Projetos/backups/credenciamento/macros_descartaveis_v0203/` (fora do
> repo). Diag_Imediato sera reintroduzido na Onda 7 como cenario de
> teste automatizado da familia `RDZ_*` (rodizio em loop), respeitando
> as regras V203. Detalhes em
> [`Projetos/backups/credenciamento/macros_descartaveis_v0203/MAPA_DE_RETORNO.md`](../../../backups/credenciamento/macros_descartaveis_v0203/MAPA_DE_RETORNO.md).

## Checklist obrigatorio por entrega

Antes de declarar onda fechada, a IA deve ter:

- [ ] Cada `.bas` modificado em `src/vba/` espelhado em
      `001-modulo/AAX-Nome.bas` com **hash md5sum batendo**.
- [ ] Cada `.frm` modificado em `src/vba/` espelhado em
      `002-formularios/AAX-Nome.frm` com hash batendo.
- [ ] Para forms cujo codigo foi alterado, gerar `.code-only.txt`.
- [ ] Modulos NOVOS adicionados a `000-MANIFESTO-IMPORTACAO.txt` E
      `000-MAPA-PREFIXOS.txt`.
- [ ] `000-BUILD-IMPORTAR-SEMPRE.txt` atualizado com novo APP_BUILD.
- [ ] `App_Release.bas` (em `001-modulo/AAX-App_Release.bas`) atualizado.
- [ ] `auditoria/03_ondas/onda_NN_<TEMA>/<NN+1>_PROCEDIMENTO_IMPORT.md`
      lista o caminho com prefixo de cada arquivo a importar.

## Proibido (regra V203)

| Acao | Razao |
|---|---|
| Importar `.bas` direto de `src/vba/` no VBE | hash + ordem nao garantidos |
| Importar `.bas` direto de `local-ai/incoming/` | export do workbook real, nao do build oficial |
| Subir modulo novo sem entrada no manifesto + mapa | quebra automacao futura |
| Reimportar `Mod_Types.bas` em microevolucao | regressao historica documentada — Onda 9 |
| Reimportar `.frm` (Import File) em workbook estabilizado | sobrescreve `.frx` e perde renomeacoes do designer |
| Rodar `local-ai/scripts/publicar_vba_import.sh` | descontinuado em 28/04/2026 |
| Macro descartavel na raiz de `vba_import/` | desde Onda 6 — sai do repo |

## Como verificar

```bash
# 1. Hash bate em todos os modulos:
for f in src/vba/*.bas; do
  base=$(basename "$f")
  pkg=$(ls local-ai/vba_import/001-modulo/A??-$base 2>/dev/null)
  if [ -z "$pkg" ]; then echo "FALTA EM PACOTE: $base"; continue; fi
  if ! diff -q "$f" "$pkg" > /dev/null; then echo "HASH DIVERGE: $base"; fi
done

# 2. Nenhuma macro descartavel na raiz de vba_import:
ls local-ai/vba_import/*.bas | grep -v -E "(Importador_VBA|Importar_Agora)\.bas$" | head -1
# (deve retornar vazio)

# 3. Importador_VBA.bas existe so como ferramenta historica ate Onda 9:
test -f local-ai/vba_import/Importador_VBA.bas && echo "OK presente"
```
