---
titulo: Especificação PDF Automático V205
diataxis: reference
hbn-track: safe_track
hbn-status: active
audiencia: ia
versao-sistema: V12.0.0205
data: 2026-05-21
---

# Especificação de PDF e Fallback Manual — V12.0.0205

## Decisão

A V12.0.0205 não implementa automação VBA de PDF. O PDF automático fica
especificado para V12.0.0206. A V205 usa fallback manual guiado para evitar
runtime errors dependentes do ambiente local do Excel.

## Fallback Manual V205

1. Executar o Gate de Validação de Release (RVS).
2. Abrir a aba `VALIDACAO_RELEASE`.
3. Usar o fluxo nativo do Excel: `Arquivo > Exportar > Criar PDF/XPS`.
4. Salvar em `auditoria/evidencias/V12.0.0205/pdf/`.
5. Nomear como `V2_VALIDACAO_HUMANA_RVS_V12_0_0205_<VALIDATION_ID>.pdf`.
6. Abrir o PDF e verificar visualmente:
   - status `APROVADO` legível;
   - `validation_id` legível;
   - nenhuma coluna relevante cortada;
   - versão V12.0.0205 presente quando aplicável.
7. Registrar o `sha256` no manifesto de evidências.

## Escopo V206

A V12.0.0206 poderá implementar um motor VBA com `ExportAsFixedFormat` se
houver:

- tratamento explícito de erro;
- teste de arquivo gerado;
- validação de tamanho maior que zero;
- validação de assinatura `%PDF-`;
- fallback visível para operador;
- suíte própria que não contamine a guarda funcional RVS.
