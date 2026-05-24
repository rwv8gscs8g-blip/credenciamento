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

## Contexto

A consolidação PDF/UI V206 determinou que os relatórios `Rel_OSEmpresa` e
`Rel_Emp_Serv` devem ser corrigidos antes do motor PDF. O risco confirmado era
gerar PDFs válidos de telas vazias, porque o menu preenchia uma instância de
formulário e exibia outra.

## Escopo Executado

- `Btn_Rel_OS_Empresa_Click` agora cria `Rel_OSEmpresa` antes de chamar
  `PreenchimentoRelatorioOSEmpresa`.
- `Rel_EmpXServ_Click` agora cria `Rel_Emp_Serv` antes de chamar
  `PreenchimentoRel_EmpXServ`.
- Fix1 pós-incidente: os handlers passam a instância criada diretamente para o
  preenchimento, no mesmo padrão de `PreenchimentoCRServico`, evitando varredura
  por `VBA.UserForms`.
- Cada handler valida `ListCount` antes de exibir o formulário e mostra mensagem
  informativa se não houver dados.
- A chamada redundante a `PreenchimentoRelatorioOSEmpresa` no
  `UserForm_Initialize` do `Menu_Principal` foi removida, porque criava
  instância invisível de `Rel_OSEmpresa` durante a abertura do menu.
- `PreenchimentoRelatorioOSEmpresa` e `PreenchimentoRel_EmpXServ` aceitam
  parâmetro opcional `frmJaAberto` para popular a instância exibida.
- O espelho local de importação foi gerado em
  `local-ai/vba_import/002-formularios/AAM-Menu_Principal.frm`.
- O procedimento canônico de importação está em
  [`03_PROCEDIMENTO_IMPORT_MICRO62_FIX1.md`](03_PROCEDIMENTO_IMPORT_MICRO62_FIX1.md).

## Arquivos Alterados

| Arquivo | Papel |
|---|---|
| `src/vba/Menu_Principal.frm` | Fonte de verdade da correção |
| `src/vba/Preencher.bas` | Fonte de verdade dos preenchimentos com parâmetro opcional |
| `local-ai/vba_import/002-formularios/AAM-Menu_Principal.frm` | Espelho importável local, ignorado pelo git |
| `local-ai/vba_import/001-modulo/AAU-Preencher.bas` | Espelho importável local, ignorado pelo git |
| `auditoria/03_ondas/onda_33_v206_fix_relatorios_pdf_precondicao/04_MANIFESTO_MICRO62_FIX1.txt` | Cópia auditável do manifesto fix1 |

Nenhum serviço blindado foi alterado.

## Roteiros de Teste Correspondentes

### ASS_REL_OS_EMP_LISTA

1. Importar `AAM-Menu_Principal.frm` no workbook de homologação.
2. Abrir o `Menu_Principal`.
3. Acionar o relatório de Ordens de Serviço por Empresa.
4. Confirmar que a janela `Rel_OSEmpresa` abre com `RO_Lista` preenchida quando
   a base tem empresas cadastradas.
5. Selecionar uma empresa e confirmar que o fluxo existente de relatório
   continua operacional.

Aceite: a tela não abre vazia quando há dados canônicos e não surge instância
fantasma anterior.

### ASS_REL_EMP_SERV_LISTA

1. Importar `AAM-Menu_Principal.frm` no workbook de homologação.
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
| Ordem estática `UserForms.Add` antes de `PreenchimentoRelatorioOSEmpresa` | OK |
| Ordem estática `UserForms.Add` antes de `PreenchimentoRel_EmpXServ` | OK |
| Hash `src/vba/Menu_Principal.frm` = espelho `AAM-Menu_Principal.frm` | OK |
| Hash `src/vba/Preencher.bas` = espelho `AAU-Preencher.bas` | OK |
| `git diff --check` | OK |
| Link scan dos documentos tocados | `BROKEN_LINKS 0` |
| Diff em `Svc_*.bas`, `doc/` e contadores RVS | vazio |

## Gates Do Operador

- Compile VBE após importar `AAU-Preencher.bas` e `AAM-Menu_Principal.frm`.
- Comando de importação:
  `ImportarPacoteV3_Delta "MICRO62-V206-MD33-0-fix1", "ONDA33.MD33.0-fix1-compile-crash"`.
- `TV2_RunSmoke` verde.
- Executar `ASS_REL_OS_EMP_LISTA`.
- Executar `ASS_REL_EMP_SERV_LISTA`.

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

Após import fix1, compile VBE, Smoke e confirmação humana dos dois roteiros
assistidos, a V12.0.0206 pode abrir a Onda 34 para o motor PDF central em
`Util_PDF.bas`.
