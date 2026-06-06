---
titulo: Hearback 0141 - formularios residuais code-only
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-02
---

# Hearback 0141 - formularios residuais code-only

Mauricio confirmou:

```text
confirmo o readback 0141-rb-onda-38-2-21-formularios-residuais-codeonly
```

Escopo confirmado:

- retomar estabilizacao de formularios por modulos code-only;
- ler UserForms e `incoming/` apenas como referencia;
- nao importar nem editar `.frm`/`.frx`;
- manter intocados `Auto_Open`, `ThisWorkbook`, `Mod_Types`,
  `Importador_V3`, `Teste_V2_Engine` e `Teste_V2_Roteiros`;
- gerar pacote V3 e teste V2 dirigido se a leitura confirmar alteracao
  necessaria.
