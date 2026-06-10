---
titulo: Procedimento de importacao — Onda 0173
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-06-09
---

# Procedimento de importacao — Onda 0173

## Pre-condicoes

- Workbook aberto no VBE em `\\Mac\Home\Projetos\Credenciamento`.
- Worktree local em `/Users/macbookpro/Projetos/Credenciamento`.
- Ondas 0169 e 0170 ja importadas no workbook de homologacao.
- Nao rodar VCR neste microdelta antes da revisao visual dos novos PDFs.

## Importar pacote

Na Janela Imediata do VBE:

```vb
ImportarPacoteV3_Delta "ONDA38_2_40_C16_AVISO_CURTO_LEGIVEL_FIX1", "349b2b6+ONDA38.2.40-C16-AVISO-CURTO-FIX1"
```

Resultado esperado:

```text
M=5 | F=0 | err=0 | skip=0
```

## Compilar

Executar `Depurar > Compilar VBAProject`.

Resultado esperado: compile limpo.

## Teste dirigido

Na Janela Imediata:

```vb
TV2_RunRelatoriosSuspensoesStrikesReset
```

Resultado esperado:

```text
OK=13 | FALHA=0 | MANUAL=0
```

## Conferencia humana

Gerar novamente PDFs de amostra para Pre-OS, OS e avaliacao. O criterio visual
da 0173 e:

- `C16` mostra resumo operacional curto e legivel em tamanho normal.
- O texto nao aparece espremido nem com letras artificialmente espacadas.
- Quando houver campo de observacoes, o diagnostico completo continua visivel
  ali como complemento.
- A mudanca e informativa: nao expira Pre-OS, nao recusa demanda e nao avanca
  fila.

## Falha

- Se o import falhar, restaurar o backup indicado pelo Importador V3.
- Se o compile falhar, nao salvar o workbook e restaurar o backup.
- Se o TV2 falhar, anexar CSV/log da falha e nao rodar VCR.
- Se o PDF ainda ficar ilegivel, manter V12.0.0206 sem freeze e abrir fix2 com
  decisao humana entre duas linhas ou campo mais amplo.
