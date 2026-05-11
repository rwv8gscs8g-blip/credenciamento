---
titulo: Procedimento de Importacao MICRO55 App Release
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-11
---

# Procedimento de Importacao MICRO55 — App_Release

## Objetivo

Atualizar apenas os metadados exibidos pela tela `Sobre`, alinhando o workbook
ao GitHub publico, ao `STATUS-OFICIAL` e aos mapas de teste V204.

Este delta nao altera regra de negocio, teste, formulario operacional ou
comportamento de producao.

## Pre-condicao

Na janela imediata do VBE:

```vba
?GetBuildImportado
```

Esperado antes do delta:

```text
f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2
```

## Importar

Na janela imediata:

```vba
ImportarPacoteV3_Delta "MICRO55", "f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2"
```

Manifesto: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO55.txt`.

Esperado do Importador V3: `M=1 | F=0 | err=0 | skip=0`.

## Gate manual obrigatorio

1. VBE > Depurar > Compilar VBAProject.
2. Janela imediata:

```vba
?GetBuildImportado
```

Esperado:

```text
f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2
```

3. Abrir a tela `Sobre` pelo sistema.

Esperado:

```text
Release oficial: V12.0.0204
Status oficial: VALIDADO
Canal ativo: OFICIAL
Proxima release alvo: V12.0.0205
Build importado: f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix2
```

## Criterio de aprovacao

MICRO55 esta aprovado se:

- o importador V3 concluir com `M=1 | F=0 | err=0 | skip=0`;
- o compile manual passar limpo;
- `?GetBuildImportado` retornar o build fix2 validado;
- a tela `Sobre` exibir V12.0.0204 / VALIDADO / OFICIAL / alvo V12.0.0205.

Nao e necessario novo Sexteto, porque o delta e exclusivamente metadado de
release. A evidencia funcional final continua sendo `VR_20260511_154433`.
