---
titulo: ImportarPacoteV3_Delta é caminho default; ImportarPacoteV3 completo só em emergência
data: 2026-05-25
autoria: claude-opus-4-7 (após Onda 37.2 a 37.4)
aplica-a: Toda IA e operador que toque o workbook V12.0.0206+
revisar-em: 2026-08-25
---

# L33 — Uso de _Delta vs Importador completo

## Regra permanente

**Toda alteração funcional em código VBA do Credenciamento é importada no
workbook via `ImportarPacoteV3_Delta(nomeDelta, buildLabel)` com manifesto
delta pequeno, NUNCA via `ImportarPacoteV3()` completo.**

## Por que existe esta regra

Em 2026-05-24, durante a Onda 37.2 (reversão dos 3 arquivos drift_md33_descartar
ao estado V5), o procedimento usou `ImportarPacoteV3()` completo. O importador
re-importou os 34 módulos + 13 forms inteiros. O compile manual VBE falhou com
"Método ou membro de dados não encontrado" em `Util_Conversao.ToLong` chamado
de `Util_Planilha.ProximoContador` — apesar de a função existir e ser pública
em runtime (`?Util_Conversao.ToLong("123")` na Janela Imediata retornou `123`).

Causa raiz: o VBE manteve **referências stale** dos módulos reimportados.
Fantasma de cache de compile que só limpa fechando Excel sem salvar e
reabrindo.

A Onda 37.4 (teste NOOP) validou que `ImportarPacoteV3_Delta("ONDA37-4-TESTE-NOOP", "e43352f+ONDA37.4-teste-delta-noop")` importou 1 arquivo com `M=1 | F=0 | err=0 | skip=0`, compile passou limpo, `CT_ValidarRelease_TrioMinimo`
seguiu APROVADO com mesmos contadores `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0`.

## Quando usar cada função do Importador V3

| Função | Quando | Comportamento |
|---|---|---|
| `ImportarPacoteV3_Delta(nomeDelta, buildLabel)` | **DEFAULT** — toda onda funcional | Importa só os arquivos listados em `000-MANIFESTO-V3-DELTA-<nomeDelta>.txt` + bump auto de APP_BUILD_IMPORTADO |
| `ImportarPacoteV3_DeltaC4(nomeDelta, buildLabel)` | Onda 18 MICRO25 (delta C4 pré-aprovado) | Igual ao Delta, mas permite reimportar Mod_Types |
| `ImportarPacoteV3()` | **EMERGÊNCIA ou Fresh workbook** | Importa pacote completo (34 mod + 13 forms). **Gera fantasma de cache no VBE.** |
| `ImportarPacoteV3_Fresh()` | Workbook em branco | Igual ao completo + força import de Mod_Types primeiro |
| `ImportarPacoteV3_DryRun()` | Validar manifesto sem aplicar | Não toca workbook |
| `ImportarPacoteV3_Status()` | Diagnóstico | Mostra estado, não importa |
| `IV3_BumpBuildLabel(buildLabel)` | Bump standalone de carimbo | Só altera APP_BUILD_IMPORTADO + reimport AAX-App_Release.bas |

## Padrão histórico do projeto

`local-ai/vba_import/` tem **70+ manifestos delta** MICRO01..MICRO62 com fixes.
Cada microdelta funcional histórico foi 1-5 arquivos. O `ImportarPacoteV3()`
completo praticamente nunca foi usado em produção — sempre `_Delta`.

## Como construir um microdelta novo (referência)

1. Editar manualmente `src/vba/<arquivo>.bas` com a mudança funcional.
2. Editar `src/vba/App_Release.bas` atualizando `APP_BUILD_IMPORTADO`,
   `APP_BUILD_BRANCH`, `APP_BUILD_GERADO_EM` (o `_Delta` também faz bump
   auto via parâmetro `buildLabel`, mas manter em src/vba evita drift G7).
3. Criar `local-ai/vba_import/000-MANIFESTO-V3-DELTA-<NOME>.txt` listando
   apenas os arquivos tocados (ver formato em MICRO11 ou MICRO60-V205-MD27-1).
   **Sempre incluir `AAX-App_Release.bas` como último item** (carimbo).
4. Rodar `bash local-ai/scripts/publicar_vba_import_v2.sh --apply` para
   sincronizar espelho `local-ai/vba_import/` (G7 verde).
5. Rodar `bash scripts/hbn-guards/hbn-guards-runner.sh` (5/5).
6. Commit via readback HBN.
7. No VBE Janela Imediata: `ImportarPacoteV3_Delta "<NOME>", "<buildLabel>"`.
8. `Depurar → Compilar VBAProject` (gate manual humano).
9. `CT_ValidarRelease_TrioMinimo` ou superior (gate de regressão).
10. Se passar: salvar workbook, fechar ERP.

## Débito técnico — investigar em onda V207

O `ImportarPacoteV3()` completo precisa ser investigado:

- Por que gera fantasma de cache no VBE quando workbook já tem os componentes?
- Há diferença operacional entre fechar/reabrir Excel após o completo vs após
  o `_Delta`?
- Existe macro `IV3_LimparCache` ou similar que pode ser invocada antes do
  completo para evitar o stale reference?
- Documentar uso restrito (Fresh workbook ou recovery emergencial) e remover
  do menu da Central de Testes para evitar uso acidental.

Esta investigação fica para onda da V12.0.0207 (code review profundo).

## Penalidade por violação

Toda IA que sugerir `ImportarPacoteV3()` completo em onda safe_track normal
(não-emergência, não-fresh) viola esta knowledge e fica sujeita a:

- Bloqueio do readback no audit pré (auditor adversarial deve sinalizar).
- Reabertura obrigatória do readback com escopo refeito via `_Delta`.

## Referências

- `auditoria/03_ondas/onda_37_3_reset_src_vba_v5/37_4_TESTE_DELTA_NOOP.md`
- `src/vba/Importador_V3.bas` (linhas 130-285)
- `local-ai/vba_import/000-MANIFESTO-V3-PHASE1.txt` (manifesto completo)
- `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO11.txt` (exemplo histórico)
- `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO60-V205-MD27-1.txt` (mais recente)
- `local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA37-4-TESTE-NOOP.txt` (validador)
