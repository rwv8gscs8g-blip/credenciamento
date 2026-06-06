---
titulo: Hearback 0140 - UX IniciarSistema code-only
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-02
---

# Hearback 0140 - UX IniciarSistema code-only

Mauricio confirmou:

```text
confirmo o readback 0140-rb-onda-38-2-20-ux-iniciar-sistema-codeonly
```

Escopo confirmado:

- criar modulo padrao `UX_IniciarSistema.bas` para instalar/atualizar atalho
  visual de planilha apontando para `IniciarSistema`;
- criar modulo V2 isolado `Teste_V2_UX_IniciarSistema.bas`;
- atualizar `App_Release.bas`;
- gerar pacote V3 `M=3/F=0`;
- manter intocados `Auto_Open`, `ThisWorkbook`, UserForms, `.frx`,
  `Svc_Avaliacao`, `Preencher`, `Mod_Types`, `Importador_V3`,
  `Teste_V2_Engine` e `Teste_V2_Roteiros`.
