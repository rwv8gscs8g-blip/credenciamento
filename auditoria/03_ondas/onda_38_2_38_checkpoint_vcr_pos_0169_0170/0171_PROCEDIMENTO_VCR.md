---
titulo: Procedimento VCR — Onda 0171
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-06-08
---

# Procedimento VCR — Onda 0171

## 1. Confirmar ordem dos pacotes

Se a 0169 ainda nao foi aplicada no workbook, importar primeiro:

```vb
ImportarPacoteV3_Delta "ONDA38_2_36_C16_AVISO_OPERACIONAL_PDF", "37486b7+ONDA38.2.36-C16-AVISO-OPERACIONAL"
```

Esperado:

```text
M=4 | F=0 | err=0 | skip=0
```

Depois importar a 0170:

```vb
ImportarPacoteV3_Delta "ONDA38_2_37_DISPONIBILIDADE_COMPOSTA_SUSPENSAO", "10c1750+ONDA38.2.37-DISPONIBILIDADE-COMPOSTA"
```

Esperado:

```text
M=4 | F=0 | err=0 | skip=0
```

## 2. Compilar

Executar `Depurar > Compilar VBAProject`.

Esperado: compile limpo.

## 3. Testes dirigidos antes da VCR

Na Janela Imediata:

```vb
TV2_RunTelaRelatorios
```

Esperado:

```text
OK=11 | FALHA=0 | MANUAL=0
```

Na Janela Imediata:

```vb
TV2_RunRelatoriosSuspensoesStrikesReset
```

Esperado:

```text
OK=12 | FALHA=0 | MANUAL=0
```

## 4. Conferencia visual minima

Antes da VCR, conferir quando aplicavel:

- aviso operacional em `C16` legivel nos impressos, sem letras artificialmente
  espacadas;
- relatorios/avisos com empresa suspensa e ocupada mostrando suspensao mais
  ocupacao, por exemplo `SUSPENSA ATE dd/mm/aaaa; OS EM EXECUCAO`;
- relatorio de Pre-OS Vencidas continua informativo, sem expirar, recusar ou
  avancar fila automaticamente.

## 5. Rodar VCR

Rodar a Validacao Completa da Release pela Central de Testes ou pela macro:

```vb
CT_ValidarRelease_Completa
```

Esperado: VCR aprovada.

## 6. Evidencia para colar no proximo chat

Informar:

- resultado dos imports 0169/0170;
- compile;
- IDs e contagens dos dois TV2 dirigidos;
- ID e resultado da VCR;
- caminho do CSV de evidencia quando houver;
- primeira falha se qualquer etapa reprovar.

## 7. Criterio de parada

Se qualquer teste dirigido falhar, nao rodar VCR. Se a VCR reprovar, nao
congelar a V12.0.0206; abrir nova onda com a primeira falha concreta.
