---
titulo: Hearback 0131 - FT-4 credenciamento em lote
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-01
---

# Hearback 0131 - FT-4 credenciamento em lote

Mauricio confirmou em chat:

> confirmo o readback 0131-rb-onda-38-2-15-ft4-credenciamento-lote

Escopo autorizado:

- implementar FT-4 no fluxo real de `Credencia_Empresa.frm`;
- adicionar teste V2 dirigido para sequencia `CRED_ID`/AR1 e tempo de execucao;
- entregar pacote V3, tecnico, ERP, relay e changelog;
- nao tocar `.frx`, `Auto_Open.bas`, `Mod_Types.bas` ou `Importador_V3.bas`;
- nao declarar freeze V206.
