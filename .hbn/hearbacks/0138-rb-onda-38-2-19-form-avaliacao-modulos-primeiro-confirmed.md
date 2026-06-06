---
titulo: Hearback 0138 - formulario avaliacao modulos primeiro
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0206
data: 2026-06-02
---

# Hearback 0138 - formulario avaliacao modulos primeiro

Mauricio confirmou em chat:

```text
confirmo o readback 0138-rb-onda-38-2-19-form-avaliacao-modulos-primeiro
```

Escopo autorizado:

- retomar a melhoria de avaliacao/demandante por modulos primeiro;
- importar apenas `Svc_Avaliacao`, `Preencher`, `App_Release` e teste V2
  isolado novo;
- nao importar `Menu_Principal.frm`, qualquer UserForm, `.frx`, `ThisWorkbook`,
  `Teste_V2_Engine.bas` ou `Teste_V2_Roteiros.bas` completos.

Permanecem proibidos:

- `Auto_Open.bas`;
- `Mod_Types.bas`;
- `Importador_V3.bas`;
- `Repo_Avaliacao.bas`;
- `Const_Colunas.bas`;
- UserForms e objetos do workbook;
- freeze V206.
