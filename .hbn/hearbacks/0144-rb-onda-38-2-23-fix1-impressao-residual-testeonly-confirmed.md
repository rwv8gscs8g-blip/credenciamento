---
titulo: Hearback 0144 - fix1 impressao residual testeonly
diataxis: status
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-03
---

# Hearback 0144 - fix1 impressao residual testeonly

Mauricio confirmou:

```text
ok faça a correção do fix 1 e faremos um rerun test.
```

Escopo confirmado:

- corrigir o falso negativo `IR_03_AVALIACAO_DEMANDANTE_L9P15`;
- validar como criterio de aceite o range visual real `IMP_AVALIA!L9:P15`;
- manter `L8` apenas como detalhe diagnostico;
- gerar pacote V3 fix1 test-only;
- nao alterar `Preencher.bas`, `Auto_Open.bas`, `Mod_Types.bas`,
  `Importador_V3.bas`, UserForms, `.frx`, `Teste_V2_Engine.bas` ou
  `Teste_V2_Roteiros.bas`;
- manter `V12.0.0205` oficial e `V12.0.0206` em validacao iterativa, sem
  freeze.
