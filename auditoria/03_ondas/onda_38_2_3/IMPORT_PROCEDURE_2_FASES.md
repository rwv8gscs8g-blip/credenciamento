---
titulo: IMPORT_PROCEDURE_2_FASES — GATE-A4 Onda 38.2.3
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-28
---

# IMPORT_PROCEDURE_2_FASES — GATE-A4 Onda 38.2.3

## Objetivo

Aplicar L41: importar a Onda 38.2.3 em duas fases no workbook operacional, com compile manual e RVS Trio entre fases. A IA nao opera Excel; Mauricio executa no VBE.

## Pre-flight obrigatorio

1. Confirmar que o workbook aberto esta em `\\Mac\Home\Projetos\Credenciamento`.
2. Na Janela Imediata:

```vb
?ThisWorkbook.Path
ImportarPacoteV3_Status
```

3. Se o caminho nao for `\\Mac\Home\Projetos\Credenciamento`, parar.
4. Salvar copia/backup operacional antes de iniciar.
5. Usar somente manifestos em `\\Mac\Home\Projetos\Credenciamento\local-ai\vba_import\`.

## Fase 1 — Modulos

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_3_A4_F1_MODULOS", "<sha_gate_a4>+ONDA38.2.3-A4-F1-MODULOS"
```

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_3_A4_F1_MODULOS.txt`

Esperado:

- `M=4 | F=0 | err=0`
- `Debug > Compile VBAProject` limpo
- RVS Trio intermediario aprovado:
  - `TV2_RunSmoke`
  - `TV2_RunIntegridadeBase`
  - `TV2_RunRodizioStrikesEndToEnd`

Se compile falhar, nao salvar o workbook. Restaurar o backup indicado pelo Importador V3.

### Resultado executado

- Import V3: `M=4 | F=0 | err=0 | skip=0`.
- Backup V3: `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260528_011548-V3-FULL`.
- Compile manual: aprovado.
- RVS: `VR_20260528_063131`, APROVADO.
- CSV: `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260528_063131.csv`.

## Fase 2 — Forms

Executar somente se Fase 1 passou compile e RVS Trio.

Comando:

```vb
ImportarPacoteV3_Delta "ONDA38_2_3_A4_F2_FORMS", "<sha_gate_a4>+ONDA38.2.3-A4-F2-FORMS"
```

Manifesto:

`local-ai/vba_import/000-MANIFESTO-V3-DELTA-ONDA38_2_3_A4_F2_FORMS.txt`

Esperado:

- `M=1 | F=2 | err=0`
- `Debug > Compile VBAProject` limpo
- RVS Trio final aprovado:
  - `TV2_RunSmoke`
  - `TV2_RunIntegridadeBase`
  - `TV2_RunRodizioStrikesEndToEnd`

A Fase 2 tambem desliga o diagnostico temporario F-NEW5 em `Credencia_Empresa` (`ATIVAR_DIAG_FNEW5=False`).

### Resultado executado

- Import V3: `M=1 | F=2 | err=0 | skip=0`.
- Backup V3: `\\Mac\Home\Projetos\Credenciamento\backups\vba\20260528_083042-V3-FULL`.
- Compile manual: aprovado.
- RVS: `VR_20260528_090314`, APROVADO.
- CSV: `auditoria/evidencias/V12.0.0205/csv/ValidacaoReleaseRVS_V12_0_0205_VR_20260528_090314.csv`.

## GATE-USO-PROLONGADO L43

Depois da Fase 2 verde, exercitar o workbook por pelo menos 30 minutos:

- cadastrar atividade e servico;
- cadastrar empresa;
- credenciar empresa em servico;
- emitir Pre-OS;
- tentar emitir segunda Pre-OS quando houver bloqueio esperado;
- consultar relatorios;
- fechar e reabrir workbook;
- repetir uma operacao simples apos reabertura.

Registrar o resultado em `GATE_USO_PROLONGADO_REPORT.md`.

## Saida do GATE-A4

GATE-A4 so pode ser considerado entregue quando todos os itens abaixo estiverem verdadeiros:

- Fase 1 importou, compilou e passou RVS completo. **Concluido.**
- Fase 2 importou, compilou e passou RVS completo. **Concluido.**
- Uso prolongado de 30 minutos teve zero erro e zero travamento.
- RVS Trio final pos-uso foi aprovado.
- Evidencias CSV/relatorios foram preservadas em `auditoria/evidencias/V12.0.0206/csv/`.
- Opus e Antigravity auditaram o GATE-A4 em chats novos usando output lock L45.

## Observacao sobre AAX

`ImportarPacoteV3_Delta` reescreve `local-ai/vba_import/001-modulo/AAX-App_Release.bas` antes de processar o manifesto. Esse drift operacional ja e conhecido (knowledge 0016) e nao deve ser staged automaticamente. Se os guards bloquearem commit por esse drift, usar bypass HBN documentado.
