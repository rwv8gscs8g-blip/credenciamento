---
titulo: Procedimento de Importacao 0174 — aviso operacional no corpo dos impressos
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-06-09
---

# Procedimento De Importacao 0174

## Pre-condicoes

- Workbook na raiz `\\Mac\Home\Projetos\Credenciamento`.
- 0173 ja importada, compilada e validada por `TV2_RunRelatoriosSuspensoesStrikesReset` com `OK=13 | FALHA=0 | MANUAL=0`.
- Nao salvar o workbook se import ou compile falhar.

## Comando

Na Janela Imediata do VBE:

```text
ImportarPacoteV3_Delta "ONDA38_2_41_AVISO_OPERACIONAL_CORPO_LEGIVEL", "ac47059+ONDA38.2.41-AVISO-CORPO-LEGIVEL"
```

## Resultado Esperado Do Importador

```text
M=4 | F=0 | err=0 | skip=0
```

## Gate Manual

1. VBE > Depurar > Compilar VBAProject.
2. Janela Imediata:

```text
TV2_RunRelatoriosSuspensoesStrikesReset
```

Resultado esperado:

```text
OK=14 | FALHA=0 | MANUAL=0
```

3. Gerar PDFs equivalentes aos cenarios revisados em 009-021.
4. Conferir visualmente:

- Pre-OS e OS: `C16` limpo, aviso operacional em `B24`;
- Avaliacao: `C16` limpo, diagnostico operacional em `B40` Observacoes;
- sem frase espremida no cabecalho;
- sem residuo visual entre impressoes.

## Rollback

Se o import ou compile falhar, nao salvar o workbook. Restaurar o backup
indicado pelo Importador V3 e anexar o print/resultado para abrir fix.

Se o TV2 falhar, anexar resultado/CSV e nao rodar VCR.

Se a revisao visual reprovar `B24`, manter V206 sem freeze e abrir nova decisao
humana sobre ajuste de template ou campo alternativo.
