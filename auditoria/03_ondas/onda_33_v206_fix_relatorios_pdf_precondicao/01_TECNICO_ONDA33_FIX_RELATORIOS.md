---
titulo: Técnico Onda 33 V206 — Correção dos Relatórios Antes do PDF
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-24
autor: Codex
---

# Onda 33 — Correção dos Relatórios Antes do PDF

> **Status em 2026-05-24:** MD33 pausada. As tres tentativas de importacao
> passaram pelo Importador V3, mas fecharam o Excel no compile manual. Nao usar
> a planilha contaminada nem os manifestos fix1/fix2 para homologacao.

## Contexto

A consolidação PDF/UI V206 determinou que os relatórios `Rel_OSEmpresa` e
`Rel_Emp_Serv` devem ser corrigidos antes do motor PDF. O risco confirmado era
gerar PDFs válidos de telas vazias, porque o menu preenchia uma instância de
formulário e exibia outra.

## Escopo Executado

- `MICRO62-V206-MD33-0` e `MICRO62-V206-MD33-0-fix1` foram reprovados no gate
  humano porque o compile VBE fechou o Excel.
- Fix2 final: `Menu_Principal.frm` volta ao padrão estável e não entra no novo
  pacote de importação.
- `Rel_OSEmpresa.frm` passa a preencher `RO_Lista` no próprio
  `UserForm_Initialize`.
- `Rel_Emp_Serv.frm` passa a preencher `SV_CR_Lista` no próprio
  `UserForm_Initialize`.
- `PreenchimentoRelatorioOSEmpresa` e `PreenchimentoRel_EmpXServ` aceitam
  parâmetro opcional `frmJaAberto` para popular a instância exibida.
- O espelho local de importação foi gerado em
  `local-ai/vba_import/`.
- O procedimento canônico de importação está em
  [`05_PROCEDIMENTO_IMPORT_MICRO62_FIX2.md`](05_PROCEDIMENTO_IMPORT_MICRO62_FIX2.md).

## Arquivos Alterados

| Arquivo | Papel |
|---|---|
| `src/vba/Menu_Principal.frm` | Revertido ao padrão estável; não é importado no fix2 |
| `src/vba/Preencher.bas` | Fonte de verdade dos preenchimentos com parâmetro opcional |
| `src/vba/Rel_OSEmpresa.frm` | Autopreenchimento do relatório de OS por empresa |
| `src/vba/Rel_Emp_Serv.frm` | Autopreenchimento do relatório de empresas por serviço |
| `local-ai/vba_import/001-modulo/AAU-Preencher.bas` | Espelho importável local, ignorado pelo git |
| `local-ai/vba_import/002-formularios/AAK-Rel_Emp_Serv.frm` | Espelho importável local, ignorado pelo git |
| `local-ai/vba_import/002-formularios/AAL-Rel_OSEmpresa.frm` | Espelho importável local, ignorado pelo git |
| `auditoria/03_ondas/onda_33_v206_fix_relatorios_pdf_precondicao/04_MANIFESTO_MICRO62_FIX1.txt` | Cópia auditável do manifesto fix1 |
| `auditoria/03_ondas/onda_33_v206_fix_relatorios_pdf_precondicao/06_MANIFESTO_MICRO62_FIX2.txt` | Cópia auditável do manifesto fix2 |

Nenhum serviço blindado foi alterado.

## Roteiros de Teste Correspondentes

### ASS_REL_OS_EMP_LISTA

1. Importar `AAU-Preencher.bas` e `AAL-Rel_OSEmpresa.frm` no workbook de
   homologação.
2. Abrir o `Menu_Principal`.
3. Acionar o relatório de Ordens de Serviço por Empresa.
4. Confirmar que a janela `Rel_OSEmpresa` abre com `RO_Lista` preenchida quando
   a base tem empresas cadastradas.
5. Selecionar uma empresa e confirmar que o fluxo existente de relatório
   continua operacional.

Aceite: a tela não abre vazia quando há dados canônicos e não surge instância
fantasma anterior.

### ASS_REL_EMP_SERV_LISTA

1. Importar `AAU-Preencher.bas` e `AAK-Rel_Emp_Serv.frm` no workbook de
   homologação.
2. Abrir o `Menu_Principal`.
3. Acionar o relatório de Empresas Credenciadas por Serviço.
4. Confirmar que a janela `Rel_Emp_Serv` abre com `SV_CR_Lista` preenchida
   quando a base tem serviços cadastrados.
5. Selecionar um serviço e confirmar que o fluxo existente de relatório
   continua operacional.

Aceite: a tela não abre vazia quando há dados canônicos e não depende de
preenchimento em instância oculta.

## Gates Locais

| Validação | Resultado |
|---|---|
| `Menu_Principal.frm` fora do manifesto fix2 | OK |
| Hash `src/vba/Preencher.bas` = espelho `AAU-Preencher.bas` | OK |
| Hash `src/vba/Rel_OSEmpresa.frm` = espelho `AAL-Rel_OSEmpresa.frm` | OK |
| Hash `src/vba/Rel_Emp_Serv.frm` = espelho `AAK-Rel_Emp_Serv.frm` | OK |
| `git diff --check` | OK |
| Link scan dos documentos tocados | `BROKEN_LINKS 0` |
| Diff em `Svc_*.bas`, `doc/` e contadores RVS | vazio |

## Gates Do Operador

Gates antigos de MD33/fix1/fix2 estao reprovados.

O gate de rebase por `V12-0206-Preparacao` tambem foi superado: o operador
informou que aquela planilha nao compilava. A nova ancora e a V5 derivada da
V12.0.0205 oficial congelada:

```text
/Users/macbookpro/Projetos/Credenciamento/PlanilhaCredenciamento-Homologacao-V5.xlsm
```

Evidencia da V5:

- `?ThisWorkbook.Path` retornou `\\Mac\Home\Projetos\Credenciamento`;
- `ImportarPacoteV3_Status` encontrou o manifesto em `local-ai\vba_import`;
- `GetReleaseTag` retornou `v12.0.0205`;
- `GetReleaseAtual` retornou `V12.0.0205`;
- `GetReleaseAlvo` retornou `V12.0.0206`;
- `GetBuildImportado` retornou
  `e43352f+ONDA27.MD27.1-rvs-labels-csv-prefix`;
- Gate RVS `VR_20260524_164612` APROVADO com assinatura
  `V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0`.

Antes de qualquer novo microdelta, exportar componentes da V5 para
`local-ai/incoming/V206_ANCHOR_V5_20260524/` e comparar contra `src/vba/`.

## Incidente Pós-Import e Fix1

O operador importou `MICRO62-V206-MD33-0` com sucesso (`M=0 | F=1 | err=0 |
skip=0`), mas o compile manual do VBE ficou preso e fechou o Excel. Ao reabrir,
o comportamento se repetiu.

Diagnóstico consolidado:

- o importador V3 usou a raiz correta do projeto;
- o backup obrigatório foi criado em `backups/vba/20260524_145103-V3-FULL`;
- a falha é gate de compilação pós-import, portanto `MICRO62-V206-MD33-0` não é
  aceito como aprovado;
- `MICRO62-V206-MD33-0-fix1` reduz o delta para o padrão de referência direta
  de formulário e importa também `Preencher.bas`, mantendo assinatura coerente
  entre chamador e preenchimento.

## Incidente Pós-Fix1 e Fix2

O operador importou `MICRO62-V206-MD33-0-fix1` com sucesso (`M=1 | F=1 |
err=0 | skip=0`), mas o compile manual do VBE fechou o Excel novamente.

Diagnóstico consolidado:

- o segundo backup obrigatório foi criado em
  `backups/vba/20260524_151252-V3-FULL`;
- os formulários `Rel_OSEmpresa.frm` e `Rel_Emp_Serv.frm` exportados do backup
  diferem do fonte quase somente por whitespace;
- o novo pacote deve evitar completamente novo import de `Menu_Principal.frm`;
- o fix2 importa apenas `AAU-Preencher.bas`, `AAK-Rel_Emp_Serv.frm` e
  `AAL-Rel_OSEmpresa.frm`, com resultado esperado `M=1 | F=2 | err=0 | skip=0`.

## Limites Observados

- Não foi implementado motor PDF.
- Não houve alteração em RN-01 a RN-17.
- Não houve alteração em contadores RVS.
- Não foi incluído teste PDF nas seis baterias do RVS.
- `doc/` não foi movido nem reorganizado.
- `Svc_Rodizio.bas`, `Svc_Avaliacao.bas`, `Svc_OS.bas` e `Svc_PreOS.bas` não
  foram alterados.
- Não houve renomeação de símbolo interno VBA.

## Próxima Ação

Apos comparacao da V5 contra `src/vba/`, a V12.0.0206 pode preparar um novo
MD33-restart para corrigir os dois relatorios. A Onda 34/PDF permanece
bloqueada ate o anchor V5 estar reconciliado.
