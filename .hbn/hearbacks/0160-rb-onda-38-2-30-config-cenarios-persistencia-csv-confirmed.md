---
titulo: Hearback 0160 - Configuracoes Iniciais cenarios CSV
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-06-07
---

# Hearback 0160 - Configuracoes Iniciais cenarios CSV

Mauricio confirmou o readback 0160 com ajuste de escopo: como se trata de um
mapa de testes, a suite pode ser destrutiva desde que avise que vai destruir os
dados para criar cenarios deterministicos e idempotentes.

Autorizado implementar:

- persistencia matricial de Configuracoes Iniciais;
- execucao do fluxo de Novo Periodo;
- criacao da pasta `V12-0-0206-Onda-38-2-30`;
- copia da planilha nessa pasta;
- CSV de evidencia dos cenarios na mesma pasta;
- campos suficientes no CSV para demonstrar ordem, fila, valores esperados,
  valores gravados, consumo por getters e resultado de cada cenario.

Mantidos os limites:

- nao gerar PDF nesta onda;
- nao restaurar a 0155;
- nao tocar em `Mod_Types.bas`, `Importador_V3.bas`, `Auto_Open.bas` ou
  `ThisWorkbook`;
- nao rodar VCR neste microdelta.
