---
titulo: Procedimento de importacao — Onda 38.2.42
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0206
data: 2026-06-09
---

# Procedimento de Importacao 0175

## Antes de Importar

Confirmar no VBE:

```vb
?ThisWorkbook.Path
ImportarPacoteV3_Status
```

Caminho esperado:

```text
\\Mac\Home\Projetos\Credenciamento
```

## Comando

```vb
ImportarPacoteV3_Delta "ONDA38_2_42_AVISO_RODAPE_RELATORIOS_LARGOS", "8d84a23+ONDA38.2.42-AVISO-RODAPE-REL-LARGOS"
```

## Resultado Esperado

```text
modo=Estabilizado | dryRun=False | M=5 | F=0 | err=0 | skip=0
```

## Gate Manual

1. `VBE > Depurar > Compilar VBAProject`.
2. Imediato:

```vb
TV2_RunRelatoriosSuspensoesStrikesReset
```

Resultado esperado:

```text
OK=16 | FALHA=0 | MANUAL=0
```

## Revisao Visual

Gerar PDFs equivalentes aos anexos 022-030.

Critérios:

- Pre-OS/OS: `C16` limpo, `B24` sem aviso, `B30:K30` com aviso legivel.
- Avaliacao: diagnostico completo continua em `B40` Observacoes.
- Relatorios: a tabela deve usar mais largura horizontal da pagina.

## Rollback

Se import, compile ou TV2 falharem, nao salvar o workbook. Restaurar o backup
informado pelo Importador V3 e anexar a evidencia da falha para nova onda.
