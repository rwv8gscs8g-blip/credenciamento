---
titulo: Procedimento de Importacao MICRO53
diataxis: how-to
hbn-track: safe_track
hbn-status: active
audiencia: humano
versao-sistema: V12.0.0204
data: 2026-05-11
---

# Procedimento de Importacao MICRO53

## Pre-condicao

Na janela imediata do VBE:

```vba
?GetBuildImportado
```

Esperado antes do delta:

```text
f7aa84f+v12.0.0204-rc1
```

## Importar

Na janela imediata:

```vba
ImportarPacoteV3_Delta "MICRO53", "f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix"
```

Manifesto: `local-ai/vba_import/000-MANIFESTO-V3-DELTA-MICRO53.txt`.

Esperado do Importador V3: `M=5 | F=1 | err=0 | skip=0`.

## Gate manual obrigatorio

1. VBE > Depurar > Compilar VBAProject.
2. Janela imediata:

```vba
?GetBuildImportado
```

Esperado:

```text
f7aa84f+ONDA25.MD25.5-limpar-cad-serv-fix
```

3. Rodar:

```vba
TV2_RunSmoke False
```

Esperado: `OK=34 | FALHA=0 | MANUAL=4`, com `MIG_009` aprovado.

4. Teste manual:
   - Configuracoes Iniciais > Limpar Base.
   - Confirmar que `ATIVIDADES (CNAE)` e `CONFIG` permanecem preservadas.
   - Confirmar que `CAD_SERV` fica sem linhas de dados.
   - Abrir Cadastro de Servico e confirmar que nao ocorre o erro "O objeto e obrigatorio".

5. Rodar Sexteto Minimo.

Sintaxe esperada:

```text
V1=171/0+V2_Smoke=34/0+V2_Canonica=24/0+E2E_Strikes=76/0+IntegridadeBase=4/0+Onda23Adv=27/0
```

## Criterio de aprovacao

MICRO53 so libera retomada do MICRO54 se compile, Smoke, teste manual e Sexteto
passarem. Se qualquer item falhar, nao salvar como ancora publica; reportar o
erro e voltar para RCA curta.
