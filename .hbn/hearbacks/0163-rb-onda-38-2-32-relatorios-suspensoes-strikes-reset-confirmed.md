---
titulo: Hearback 0163 Relatorios Suspensoes Strikes Reset
diataxis: status
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0205
data: 2026-06-08
---

# Hearback 0163

Mauricio confirmou que o comportamento atual dos botoes esta correto:

- **Iniciar Novo Periodo** preserva cadastros, credenciamentos e suspensoes ativas.
- **Limpar Base** apaga a base operacional para comecar um municipio novo, incluindo suspensoes porque remove as empresas e o historico operacional.

Autorizacao: aplicar a onda 38.2.32 para normalizar relatorios, documentar/testar esse contrato, incluir strikes por nota baixa e recusas/prazo nos relatorios e adicionar aviso operacional nos impressos de PRE_OS, OS e Avaliacao.

Restricoes mantidas: sem VCR neste microdelta, sem restaurar 0155, sem tocar em Mod_Types.bas, Importador_V3.bas, Auto_Open.bas ou ThisWorkbook.
