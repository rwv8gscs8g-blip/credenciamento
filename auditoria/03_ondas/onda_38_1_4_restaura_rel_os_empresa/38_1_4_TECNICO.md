---
titulo: Onda 38.1.4 — Restauracao Rel_OSEmpresa
diataxis: onda
hbn-track: safe_track
hbn-status: active
audiencia: ambos
versao-sistema: V12.0.0206
data: 2026-05-25
---

# Onda 38.1.4 — Restauracao Rel_OSEmpresa

## Contexto

A Onda 38.1.3 importou com sucesso (`M=1 | F=1 | err=0 | skip=0`), mas o
Excel fechou durante o compile manual no VBE. Mauricio tentou reimportar o
delta antigo `ONDA38-1-2-REL-OS-EMPRESA-BOTAO`; o import tambem passou, mas o
compile continuou falhando.

Diagnostico: manifesto delta antigo nao e snapshot. Ele aponta para o arquivo
vivo em `local-ai/vba_import/`. Como `AAL-Rel_OSEmpresa.frm` ainda continha o
codigo da 38.1.3, o delta antigo reimportou o conteudo novo com nome antigo.

## Implementacao

Esta onda restaura `Rel_OSEmpresa.frm` ao conteudo do commit `35775b3`, que foi
o ultimo estado validado por import, compile, RVS e PDF funcional.

Removido do form:

- `Dim Var8 As Variant`;
- atribuicao direta de `Var8` como `Variant`;
- chamada `Util_Conversao.ToDouble(Var8)`;
- formatacao decimal da coluna H adicionada na 38.1.3.

Preservado:

- `B_RelMEIOS_Click`;
- `B_RelEmpresaOS_Click`;
- rotina central `AcionarRelatorioOSEmpresa`;
- fluxo funcional da 38.1.2.

## Licao aprendida

Registrada em `.hbn/knowledge/0009-licoes-importador-v3-phase1.md` como L11:
manifesto delta aponta para arquivo vivo, nao para snapshot historico.

Rollback funcional deve ser feito por delta novo de restauracao, com o conteudo
realmente restaurado em `src/vba/` e `local-ai/vba_import/`.

## Gate humano

Comando unico de import:

```vb
ImportarPacoteV3_Delta "ONDA38-1-4-RESTAURA-REL-OS-EMPRESA", "8d5e2e6+ONDA38.1.4-restaura-rel-os-empresa"
```

Resultado esperado:

- `M=1 | F=1 | err=0 | skip=0`
- compile VBE limpo, sem fechar Excel
- `CT_ValidarRelease_TrioMinimo` aprovado sem mudanca de contadores

Se o compile fechar o Excel novamente, nao salvar o workbook e parar a linha de
importacao de forms ate auditoria adversarial.
