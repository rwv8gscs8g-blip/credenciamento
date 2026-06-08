---
titulo: Procedimento de Import — 0159 Tela Inicial Menu Principal
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0205
data: 2026-06-07
---

# Procedimento de Import — 0159

## Escopo

Delta test-only + build label para validar a Tela Inicial/Menu_Principal por
teste V2 dirigido.

Este procedimento ja incorpora o Fix1 da 0159: o primeiro gate humano importou
e compilou, mas `TV2_RunTelaInicial` retornou `OK=12 | FALHA=2 | MANUAL=0`
porque a suite cobrava tokens BL4 de `Auto_Open`, modulo fora do delta. O Fix1
remove esse acoplamento e delega a cobertura de protecao para a suite BL4
dedicada.

## Comando

No VBE, executar:

```vb
ImportarPacoteV3_Delta "ONDA38_2_29_TELA_INICIAL", "293e44c+ONDA38.2.29-FIX1-TELA-INICIAL"
```

## Resultado Esperado do Importador

```text
M=3 | F=0 | err=0 | skip=0
```

## Pos-Import

1. VBE > Depurar > Compilar VBAProject.
2. Se o compile falhar, nao salvar o workbook e restaurar o backup V3.
3. Se o compile passar, executar na Janela Imediata:

```vb
TV2_RunTelaInicial
```

Resultado esperado:

```text
OK=14 | FALHA=0 | MANUAL=0
```

## Nao Executar Neste Microdelta

- VCR.
- clique real em Central de Testes.
- clique real em Sair.
- qualquer fluxo destrutivo.

## Arquivos Importados

- `001-modulo/AAX-App_Release.bas`
- `001-modulo/ABF-Teste_V2_Engine.bas`
- `001-modulo/ABG-Teste_V2_Roteiros.bas`
