---
titulo: Importador V3 — Visão Conceitual
diataxis: explanation
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0204
data: 2026-05-12
---

# Importador V3 — Visão Conceitual

O Importador V3 é o mecanismo operacional usado pelo mantenedor para aplicar
pacotes controlados de módulos VBA no workbook `.xlsm`. Ele não é parte do
caminho do testador humano externo: quem apenas homologa a planilha deve usar a
interface do Excel, o botão **Sobre** e a **Central de Testes**.

## Papel na V12.0.0204

Na V12.0.0204, o Importador V3 foi usado para aplicar microdeltas auditáveis,
sempre com backup prévio e gate manual de compilação no VBE pelo operador.

O contrato prático é:

1. o pacote declara um manifesto V3;
2. o importador cria backup completo do projeto VBA;
3. aplica os módulos declarados;
4. registra eventos em log;
5. exige compilação manual posterior;
6. o build só é aceito quando `GetBuildImportado` e os testes batem com o
   esperado.

## Relação com a vitrine pública

O repositório público expõe código, regras, evidências e documentação. O pacote
operacional de importação pertence ao fluxo de manutenção controlado e não é o
caminho principal do testador humano.

Essa separação evita que uma pessoa interessada em apenas validar a release
confunda a homologação por interface com a manutenção técnica do VBA.

## Lições da V204

A V204 consolidou uma regra prática: um microdelta só é absorvido quando o
workbook importado prova o build esperado após importação e passa pelos gates
correspondentes. Importar com log OK não basta se o build efetivo permanecer
stale ou se a compilação falhar.

## Documento histórico

A visão do Importador V2 foi preservada em
[_historico/IMPORTADOR_V2.md](_historico/IMPORTADOR_V2.md).
