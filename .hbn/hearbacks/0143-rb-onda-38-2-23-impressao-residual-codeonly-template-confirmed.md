---
titulo: Hearback 0143 - impressao residual code-only template
diataxis: status
hbn-track: fast_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-03
---

# Hearback 0143 - impressao residual code-only template

Mauricio confirmou:

```text
aprovado pode implementar.
```

Escopo confirmado:

- executar a onda 38.2.23 de impressao residual;
- usar abordagem code-only/template por VBA;
- corrigir demandante visual de `IMP_AVALIA`, total visual de `EMITE_OS`
  e bordas criticas isoladas pela auditoria 0142;
- adicionar teste V2 isolado, chamado diretamente por `TV2_RunImpressaoResidual`;
- nao tocar `Auto_Open.bas`, `Mod_Types.bas`, `Importador_V3.bas`,
  UserForms, `.frx`, `Teste_V2_Engine.bas` ou `Teste_V2_Roteiros.bas`;
- manter `V12.0.0205` como release oficial e `V12.0.0206` em validacao
  iterativa, sem freeze.
